classdef F2_SchottkyScanApp < handle
    events
        PVUpdated % PV object list notifies this event after each set of monitored PVs have finished updating
    end
    properties
        pvlist PV
        pvs
        guihan
        data
        devlist
        devconv
        scan_param
        message
        nMsg
        mode
        scan_state
        abort_state
        machine_state
        dummy_mode
    end
    properties(Hidden)
        listeners
    end
    properties(Constant)
        maxbeat=1e7 % max heartbeat count, wrap to zero
    end
    
    methods
        
        function obj = F2_SchottkyScanApp(apph)
            
            % initialize object and add PVs to be monitored
            context = PV.Initialize(PVtype.EPICS_labca) ;
            obj.pvlist=[...
                PV(context,'name',"Instance",'pvname',"SIOC:SYS1:ML00:AO401",'mode',"rw",'monitor',true); % Number of times code is run
                PV(context,'name',"State",'pvname',"SIOC:SYS1:ML00:AO402",'mode',"rw",'monitor',true); % Current scan state
                
                PV(context,'name',"KLYS_21_PDES",'pvname',"KLYS:LI10:21:PDES",'monitor',true,'mode',"rw"); % KLYS LI10 21 PDES
                PV(context,'name',"KLYS_21_PHAS",'pvname',"KLYS:LI10:21:PHAS",'monitor',true); % KLYS LI10 21 PHAS
                %PV(context,'name',"KLYS_21_SLED_PHAS",'pvname',"KLYS:LI10:21:SLED_PHAS",'monitor',true); % KLYS LI10 21 SLED PHAS (I think it is same as one above)
                PV(context,'name',"GUN_21_PHAS",'pvname',"ACCL:LI10:21:PHASE_W0CH6",'monitor',true); % Gun PHAS
                PV(context,'name',"KLYS_21_OFFSET",'pvname',"KLYS:LI10:21:T5:PREQ_OFFSET",'monitor',true); % Offset between 2-1 PDES and PHAS
                PV(context,'name',"SFB_ENABLE",'pvname',"KLYS:LI10:21:SFB_PDIS",'monitor',true); % Slow feedback on/off
                PV(context,'name',"SFB_PDES",'pvname',"KLYS:LI10:21:SFB_PDES",'monitor',true); % Slow feedback setpoint
                
                PV(context,'name',"LaserEnergy",'pvname',"LASR:LT10:930:PWR",'monitor',true); % IN10 laser power meter
                PV(context,'name',"BPM_221_TMIT",'pvname',"BPMS:IN10:221:TMIT",'monitor',true,'mode',"rw"); % BPM IN10 221 charge meas
                PV(context,'name',"FCQ",'pvname',"SIOC:SYS1:ML00:AO850",'monitor',true,'mode',"rw"); % output faraday cup charge meas
                PV(context,'name',"QE",'pvname',"SIOC:SYS1:ML00:AO840",'monitor',true,'mode',"rw"); % output faraday cup QE meas
                PV(context,'name',"fcupInOut",'pvname',"FARC:IN10:241:PNEUMATIC",'monitor',true,'mode',"rw"); % Faraday cup in/out state
                PV(context,'name',"fcupStats",'pvname',"FARC:IN10:241:TGT_STS",'monitor',true,'mode',"rw"); % Faraday cup in/out status
                PV(context,'name',"pmonInOut",'pvname',"PROF:IN10:241:PNEUMATIC",'monitor',true,'mode',"rw"); % PR10241 in/out state
                PV(context,'name',"pmonStats",'pvname',"PROF:IN10:241:TGT_STS",'monitor',true,'mode',"rw"); % PR10241 in/out status
                ] ;
            pset(obj.pvlist,'debug',0) ;
            obj.pvs = struct(obj.pvlist);
            
            % Dear Diary, My name is Schottky Scan and I am 0x00 old today
            diary('/u1/facet/physics/log/matlab/F2_SchottkyScan.log');
            inst = caget(obj.pvs.Instance);
            caput(obj.pvs.Instance,inst+1);
            obj.nMsg = 0;
            obj.addMessage(sprintf('Started instance %d.',inst+1));
            
            obj.dummy_mode = false;
            if obj.dummy_mode
                obj.addMessage('Running in dummy mode.');
            end
            
            % initialize meas devices
            obj.devlist = {'BPM 221',   'BPM_221_TMIT';
                           'FC1',       'FCQ'        };           
            obj.devconv = [1.602e-19*1e12, 1e3]; % convert # e- to pC for BPM, convert nC to pC for FC
            
            % Associate class with GUI
            obj.guihan=apph;
            
            % Set GUI callbacks for phase PVs
            %obj.pvs.KLYS_21_PHAS.guihan = apph.KLYSPHASEditField ;
            %obj.pvs.KLYS_21_PDES.guihan = apph.KLYSPDESEditField ;
            obj.pvs.GUN_21_PHAS.guihan = apph.GUNPHASEditField ;
            obj.pvs.SFB_PDES.guihan = apph.GUNPDESEditField ;
            
            
            % Set GUI callbacks for FC cup in/out
            obj.pvs.fcupStats.guihan = apph.InStateLamp ;
            
            % Set scan state false
            obj.scan_state = false;
            obj.abort_state = false;
            obj.mode = "IDLE";
            
            % Get initial state
            obj.getInitState();
            
            
            obj.machine_state.phas_tol = apph.PhaseToldegEditField.Value;
            %obj.machine_state.pdes = obj.machine_state.init_phas;
            if obj.dummy_mode; obj.machine_state.phas_tol = 100; end
            
            % Get state of Faraday cup
            obj.getFcupState();
            
            % Get initial measurement device
            obj.measDev();
            
            % Get initial scan params
            %obj.getScanParams();
            
            % Start listening for PV updates
            obj.listeners = addlistener(obj,'PVUpdated',@(~,~) obj.loop) ;
            run(obj.pvlist,false,0.1,obj,'PVUpdated');                
                
        end
        
        function loop(obj)
            % function where stuff happens
            persistent lastMEAS lastPHAS pdes_count
            
            
            
            
            switch obj.mode
                case "IDLE"
                    
                    % do nothing
                    
                case "PHASE_SETTING" % Waiting for Klystron (PDES - PHAS) < tol 
                    
                    %if abs(obj.machine_state.pdes - obj.pvs.KLYS_21_PDES.val{1}) > obj.machine_state.phas_tol
                    if abs(obj.machine_state.klys_pdes - obj.pvs.KLYS_21_PDES.val{1}) > obj.machine_state.phas_tol
                        
                        if isempty(pdes_count); pdes_count = 1; else; pdes_count = pdes_count+1; end
                        
                        if pdes_count > 5
                        
                            obj.addMessage('PDES not set. Aborting.');
                            obj.scan_state = false;
                            obj.mode = "IDLE";
                            obj.guihan.SettingPhaseLamp.Enable = false;
                            pdes_count = 0;
                        end
                    end
                    
                    if isempty(lastPHAS) || lastPHAS ~= obj.pvs.GUN_21_PHAS.val{1}
                        
                        pdes_count = 0;
                        
                        if obj.abort_state; obj.abort(); end
                        
                        %lastPHAS = obj.pvs.KLYS_21_PHAS.val{1};
                        lastPHAS = obj.pvs.GUN_21_PHAS.val{1};
            
                        %delta = abs(obj.pvs.KLYS_21_PHAS.val{1} - obj.pvs.KLYS_21_PDES.val{1});
                        if lastPHAS < 0
                            gun_phase = lastPHAS + 360;
                        else
                            gun_phase = lastPHAS;
                        end
                        delta = abs(gun_phase - obj.scan_param.step_vals(obj.scan_param.step));
                        
%                         if obj.count == 0
%                             obj.guihan.SettingPhaseLamp.Enable = ~obj.guihan.SettingPhaseLamp.Enable; % flashing lamp
%                         end
                        if delta < obj.machine_state.phas_tol && obj.scan_state
                            obj.mode = "MEASUREMENT";
                            obj.guihan.AcquiringDataLamp.Enable = true;
                        end
                        
                    end
                    
                case "MEASUREMENT" % acquring data
                    
                    if isempty(lastMEAS) || lastMEAS ~= obj.pvs.(obj.data.devStr).val{1}
                        
                        if obj.abort_state; obj.abort(); end
                        
                        lastMEAS = obj.pvs.(obj.data.devStr).val{1};
                        obj.scan_param.shot=obj.scan_param.shot+1;
                    
                        obj.data.Measurements(obj.scan_param.shot,obj.scan_param.step) = obj.data.conv*obj.pvs.(obj.data.devStr).val{1};
                        gun_phase = obj.pvs.GUN_21_PHAS.val{1};
                        if gun_phase < 0
                            gun_phase = gun_phase + 360;
                        end
                        obj.data.GunPhases(obj.scan_param.shot,obj.scan_param.step) = gun_phase;
                        if obj.data.devInd == 2
                            obj.data.QEs(obj.scan_param.shot,obj.scan_param.step) = obj.pvs.QE.val{1};
                        end


                        
%                         if obj.count == 0
%                             obj.guihan.AcquiringDataLamp.Enable = ~obj.guihan.AcquiringDataLamp.Enable; % flashing lamp
%                         end
                        
                        if obj.scan_param.shot == obj.scan_param.n_shots
                            
                            obj.addMessage(sprintf('End scan step %d.',obj.scan_param.step));
                            obj.scan_param.step=obj.scan_param.step+1;
                            
                            % End of scan
                            if obj.scan_param.step > obj.scan_param.n_steps
                                obj.addMessage('End of scan.');
                                obj.guihan.AcquiringDataLamp.Enable = false;
                                obj.scan_state = false;
                                
                                obj.mode = "ANALYZE_DATA";
                                obj.analyzeData();
                                
                                if ~obj.dummy_mode
                                    if obj.machine_state.set_ZC_phas
                                        obj.setZeroCrossing();
                                        if strcmp(obj.machine_state.init_fb_state,'ENABLE')
                                            obj.addMessage('Re-enabling slow feedback.');
                                            caput(obj.pvs.SFB_ENABLE,1);
                                        end
                                    else
                                        obj.restoreInitPhas();
                                        if strcmp(obj.machine_state.init_fb_state,'ENABLE')
                                            obj.addMessage('Re-enabling slow feedback.');
                                            caput(obj.pvs.SFB_ENABLE,1);
                                        end
                                    end
                                end
                                return;
                            end
                            
                            obj.mode = "PHASE_SETTING";
                            obj.guihan.SettingPhaseLamp.Enable = true;
                            obj.scan_param.shot = 0;
                            %if ~obj.dummy_mode; obj.setPhas(obj.scan_param.step_vals(obj.scan_param.step)); end
                            if ~obj.dummy_mode; obj.setPhas(obj.scan_param.pdes_vals(obj.scan_param.step)); end
                            obj.updatePlot();
                            
                        end                        
                    end
            end
            
%             obj.count = obj.count + 1;
%             if obj.count > 10
%                 obj.count = 0;
%             end
            
        end
        
        function abort(obj)
            obj.addMessage('Abork!');
            obj.scan_state = false;
            obj.mode = "IDLE";
            obj.guihan.SettingPhaseLamp.Enable = false;
            obj.guihan.AcquiringDataLamp.Enable = false;
            obj.restoreInitPhas();
            if strcmp(obj.machine_state.init_fb_state,'ENABLE') && ~obj.dummy_mode
                obj.addMessage('Re-enabling slow feedback.');
                caput(obj.pvs.SFB_ENABLE,1);
            end
        end
        
        function setPhas(obj,phas)
            obj.machine_state.klys_pdes = phas;
            caput(obj.pvs.KLYS_21_PDES,phas);
            
        end
            
            
            
        
        function restoreInitPhas(obj)
            obj.setPhas(obj.machine_state.init_klys_pdes);
            obj.addMessage(sprintf('Restoring initial PDES: %0.2f',obj.machine_state.init_klys_pdes));
        end
        
        function setPhaseFromScan(obj)
            obj.machine_state.init_sfb_pdes = obj.data.opPhase;
            %obj.setPhas(obj.machine_state.init_phas);
            obj.setPhas(obj.data.opPhase + obj.machine_state.init_delta_PDES);
            caput(obj.pvs.SFB_PDES,obj.data.opPhase);
            obj.addMessage(sprintf('Setting Slow feedback PDES to: %0.2f',obj.machine_state.init_sfb_pdes));
        end
        
        function getFcupState(obj)
            obj.machine_state.fcup_set = caget(obj.pvs.fcupInOut);
            obj.machine_state.fcup_rbv = caget(obj.pvs.fcupStats);
            obj.machine_state.pmon_set = caget(obj.pvs.pmonInOut);
            obj.machine_state.pmon_rbv = caget(obj.pvs.pmonStats);
            
            % my defined state status: 0 = Out+RBV Out, 1 = In+RBV In, 2 = In/Out does not match RBV
            if strcmp(obj.machine_state.fcup_set,'OUT') && strcmp(obj.machine_state.fcup_set,'OUT')
                obj.machine_state.fc_state = 0;
            elseif strcmp(obj.machine_state.fcup_set,'IN') && strcmp(obj.machine_state.fcup_set,'IN')
                obj.machine_state.fc_state = 1;
            else
                obj.machine_state.fc_state = 2;
            end
            
            if strcmp(obj.machine_state.pmon_set,'OUT') && strcmp(obj.machine_state.pmon_set,'OUT')
                obj.machine_state.pm_state = 0;
            elseif strcmp(obj.machine_state.pmon_set,'IN') && strcmp(obj.machine_state.pmon_set,'IN')
                obj.machine_state.pm_state = 1;
            else
                obj.machine_state.pm_state = 2;
            end
            
            
            
        end
        
        function setFcupState(obj,value)
            
            obj.getFcupState();
            
            if strcmp(value,'In')
                
                if obj.machine_state.fc_state == 2
                    obj.addMessage('Warning: Faraday Cup in unknown state.');
                elseif obj.machine_state.pm_state == 1
                    obj.addMessage('Warning: Cannot insert FC. PR10241 target inserted.');
                    caput(obj.pvs.fcupInOut)
                    obj.addMessage('Inserting Faraday Cup.');
                elseif obj.machine_state.pm_state == 2
                    obj.addMessage('Warning: PR10241 target in unknown state.');
                elseif obj.machine_state.pm_state == 0
                    caput(obj.pvs.fcupInOut,1)
                    obj.addMessage('Inserting Faraday Cup.');
                end
                
            end
            
            if strcmp(value,'Out')
                
                if obj.machine_state.fc_state == 2
                    obj.addMessage('Warning: Faraday Cup in unknown state.');
                else
                    caput(obj.pvs.fcupInOut,0)
                    obj.addMessage('Extracting Faraday Cup.');
                end
                
            end
            
        end
        
        function getInitState(obj)
            obj.machine_state.init_sfb_pdes = caget(obj.pvs.SFB_PDES);
            obj.machine_state.init_offset = caget(obj.pvs.KLYS_21_OFFSET);
            obj.machine_state.init_klys_pdes = caget(obj.pvs.KLYS_21_PDES);
            obj.machine_state.klys_pdes = caget(obj.pvs.KLYS_21_PDES);
            obj.machine_state.init_klys_phas = caget(obj.pvs.KLYS_21_PHAS);
            obj.machine_state.init_gun_phas = caget(obj.pvs.GUN_21_PHAS);
            obj.machine_state.init_fb_state = caget(obj.pvs.SFB_ENABLE);
            obj.machine_state.init_klys_gun_delta = obj.machine_state.init_klys_phas - obj.machine_state.init_gun_phas;
            obj.machine_state.init_delta_PDES = obj.machine_state.init_gun_phas - obj.machine_state.init_klys_pdes;
            obj.calcScanPhases();
        end
        
        function calcScanPhases(obj)
            obj.getScanParams();
            %obj.machine_state.init_delta_PDES = obj.machine_state.init_klys_pdes - obj.machine_state.init_sfb_pdes;
            %obj.machine_state.init_delta_PDES = obj.machine_state.init_klys_pdes - obj.machine_state.init_gun_phas;
            if abs(obj.machine_state.init_sfb_pdes - obj.machine_state.init_gun_phas) > 5
                obj.addMessage('Warning: Slow feedback not tracking gun phase');
            end
            obj.scan_param.pdes_vals = obj.scan_param.step_vals - obj.machine_state.init_delta_PDES;
        end
        
        function startScan(obj)
            
            obj.abort_state = false;
            obj.getInitState();
            
            if strcmp(obj.machine_state.init_fb_state,'ENABLE') && ~obj.dummy_mode
                obj.addMessage('Disabling slow feedback.');
                caput(obj.pvs.SFB_ENABLE,0);
            end
            %obj.machine_state.init_phas = caget(obj.pvs.KLYS_21_PDES);
            
            %obj.getScanParams();
            
            obj.addMessage(sprintf('Scan start %0.2f, end %0.2f, steps %d.',...
                obj.scan_param.start,obj.scan_param.end,obj.scan_param.n_steps));
                
            
            obj.data.Measurements = zeros(obj.scan_param.n_shots,obj.scan_param.n_steps);
            obj.data.QEs = zeros(obj.scan_param.n_shots,obj.scan_param.n_steps);
            obj.data.GunPhases = zeros(obj.scan_param.n_shots,obj.scan_param.n_steps);
            
            obj.machine_state.set_ZC_phas = obj.guihan.SetdesiredphaseCheckBox.Value;
            
            obj.scan_state = true;
            obj.mode = "PHASE_SETTING";
            obj.guihan.SettingPhaseLamp.Enable = true;
            %if ~obj.dummy_mode; obj.setPhas(obj.scan_param.step_vals(obj.scan_param.step)); end
            if ~obj.dummy_mode; obj.setPhas(obj.scan_param.pdes_vals(obj.scan_param.step)); end
            
            obj.addMessage('Starting scan.');
            
        end
            
        
        function analyzeData(obj)
            
            obj.data.MeasMeans = mean(obj.data.Measurements);
            obj.data.MeasSTDs = std(obj.data.Measurements);
            obj.data.MeasEOMs = std(obj.data.Measurements)/sqrt(obj.scan_param.n_shots);
            
            obj.data.MeasMeans_QE = mean(obj.data.QEs);
            obj.data.MeasSTDs_QE = std(obj.data.QEs);
            obj.data.MeasEOMs_QE = std(obj.data.QEs)/sqrt(obj.scan_param.n_shots);
            
            obj.data.PhaseMeans = mean(obj.data.GunPhases);
            obj.data.PhaseSTDs = std(obj.data.GunPhases);
            obj.data.PhaseEOMs = std(obj.data.GunPhases)/sqrt(obj.scan_param.n_shots);
            
            obj.calcZeroCrossing();
            
            obj.finalPlot();
            
            
            obj.mode = "IDLE";
            
        end
        
        function calcZeroCrossing(obj)
            % This is a quick and dirty method to find zero crossing
            % It finds the point where the curve gets turnt from zero
            
            maxQ = max(obj.data.MeasMeans);
            thresh = maxQ/60;
            diffQ = diff(obj.data.MeasMeans);
            zc_ind = find(diffQ>thresh,1);
            
            if numel(zc_ind) ~= 1
                obj.addMessage('WARNING: Could not find zero crossing.');
                obj.data.zeroC = obj.scan_param.step_vals(1);
            else
                obj.data.zeroC = obj.scan_param.step_vals(zc_ind);
                obj.addMessage(sprintf('Zero crossing = %0.2f deg.',obj.data.zeroC));
                
            end
            
            if obj.dummy_mode
                obj.data.opPhase = obj.machine_state.init_sfb_pdes+0.1;
            else
                obj.data.opPhase = obj.data.zeroC + obj.guihan.PhaseOffsetEditField.Value;
                obj.addMessage(sprintf('Operational phase = %0.2f deg.',obj.data.opPhase));
            end
            
        end
        
        function setZeroCrossing(obj)
            
            %confFig = uifigure;
            msg = sprintf('Set phase to %0.2f ?',obj.data.opPhase);
            title = 'Update Phase';
            %selection = uiconfirm(confFig,msg,title,'Options',{'Yes','No'},'DefaultOption',2);
            selection = questdlg(msg,title,'No');
            
            if strcmp(selection,'Yes')
                obj.setPhaseFromScan();
            else
                obj.restoreInitPhas();
            end
            
        end
            
        
        function updatePlot(obj)
            
            plotQE = obj.guihan.QEButton.Value;
            
            if plotQE
                plot_data = obj.data.QEs(:,1:obj.scan_param.step-1);
                ylabel_str = 'QE';
            else
                plot_data = obj.data.Measurements(:,1:obj.scan_param.step-1);
                ylabel_str = 'Charge [pC]';
            end

            % This makes x-axis gun readback phase
            x_data = obj.data.GunPhases(:,1:obj.scan_param.step-1);
            
            %plot(obj.guihan.UIAxes,obj.scan_param.step_vals(1:obj.scan_param.step-1),plot_data,'bo','linewidth',2);
            plot(obj.guihan.UIAxes,x_data,plot_data,'bo','linewidth',2);
            
            xlabel(obj.guihan.UIAxes,'Gun Phase [deg]','fontsize',14);
            ylabel(obj.guihan.UIAxes,ylabel_str,'fontsize',14);
            title_str = ['Schottky Scan on ' strrep(obj.data.devName,'_',' ')];
            if obj.dummy_mode; title_str = [title_str ' (Dummy Mode)']; end
            title(obj.guihan.UIAxes,title_str,'fontsize',16);

        end
        
        function finalPlot(obj,fnum)
            
            plotQE = obj.guihan.QEButton.Value;
            %phase_vals = obj.scan_param.step_vals;
            phase_vals = obj.data.PhaseMeans;
            
            if plotQE
                plot_means = obj.data.MeasMeans_QE;
                plot_eoms = obj.data.MeasEOMs_QE;
                max_val = max(obj.data.MeasMeans_QE);
                ylabel_str = 'QE';
            else
                plot_means = obj.data.MeasMeans;
                plot_eoms = obj.data.MeasEOMs;
                max_val = max(obj.data.MeasMeans);
                ylabel_str = 'Charge [pC]';
            end

            if plotQE
            
                if nargin < 2
                    errorbar(obj.guihan.UIAxes,phase_vals,plot_means,plot_eoms,'bo--','linewidth',2);
                    if obj.machine_state.set_ZC_phas
                        hold(obj.guihan.UIAxes,'on');
                        plot(obj.guihan.UIAxes,[obj.data.zeroC obj.data.zeroC],[0 max_val],'r--');
                        plot(obj.guihan.UIAxes,[obj.data.opPhase obj.data.opPhase],[0 max_val],'g--');
                        hold(obj.guihan.UIAxes,'off');
                    end
                    xlabel(obj.guihan.UIAxes,'Gun Phase [deg]','fontsize',14);
                    ylabel(obj.guihan.UIAxes,ylabel_str,'fontsize',14);
                    title_str = ['Schottky Scan on ' strrep(obj.data.devName,'_',' ')];
                    if obj.dummy_mode; title_str = [title_str ' (Dummy Mode)']; end
                    title(obj.guihan.UIAxes,title_str,'fontsize',16);
                else
                    figure(fnum);
                    errorbar(phase_vals,plot_means,plot_eoms,'bo--','linewidth',2);
                    if obj.machine_state.set_ZC_phas
                        hold(gca,'on');
                        plot([obj.data.zeroC obj.data.zeroC],[0 max_val],'r--');
                        plot([obj.data.opPhase obj.data.opPhase],[0 max_val],'g--');
                        hold(gca,'off');
                    end
                    xlabel('Gun Phase [deg]','fontsize',14);
                    ylabel(ylabel_str','fontsize',14);
                    title_str = ['Schottky Scan on ' strrep(obj.data.devName,'_',' ')];
                    if obj.dummy_mode; title_str = [title_str ' (Dummy Mode)']; end
                    title(title_str,'fontsize',16);
                end
                
            else
                
                if nargin < 2
                    
                    errorbar(obj.guihan.UIAxes,phase_vals,plot_means,plot_eoms,'bo--','linewidth',2);
                    if obj.machine_state.set_ZC_phas
                        hold(obj.guihan.UIAxes,'on');
                        plot(obj.guihan.UIAxes,[obj.data.zeroC obj.data.zeroC],[0 max_val],'r--');
                        plot(obj.guihan.UIAxes,[obj.data.opPhase obj.data.opPhase],[0 max_val],'g--');
                        hold(obj.guihan.UIAxes,'off');
                    end
                    xlabel(obj.guihan.UIAxes,'Gun Phase [deg]','fontsize',14);
                    ylabel(obj.guihan.UIAxes,'Charge [pC]','fontsize',14);
                    title_str = ['Schottky Scan on ' strrep(obj.data.devName,'_',' ')];
                    if obj.dummy_mode; title_str = [title_str ' (Dummy Mode)']; end
                    title(obj.guihan.UIAxes,title_str,'fontsize',16);
                    
                else
                    figure(fnum);
                    errorbar(phase_vals,plot_means,plot_eoms,'bo--','linewidth',2);
                    if obj.machine_state.set_ZC_phas
                        hold(gca,'on');
                        plot([obj.data.zeroC obj.data.zeroC],[0 max_val],'r--');
                        plot([obj.data.opPhase obj.data.opPhase],[0 max_val],'g--');
                        hold(gca,'off');
                    end
                    xlabel('Gun Phase [deg]','fontsize',14);
                    ylabel('Charge [pC]','fontsize',14);
                    title_str = ['Schottky Scan on ' strrep(obj.data.devName,'_',' ')];
                    if obj.dummy_mode; title_str = [title_str ' (Dummy Mode)']; end
                    title(title_str,'fontsize',16);
                end
                
            end
                
            
        end
        
        function saveData(obj)
            
            [~,tsi]=lcaGet('PATT:SYS1:1:PULSEID');
            ts = lca2matlabTime(tsi);

            save_obj.data = obj.data;
            save_obj.scan_param = obj.scan_param;
            save_obj.machine_state = obj.machine_state;

            
            [fileName, pathName] = util_dataSave(save_obj, 'SchottkyScan', char(obj.pvs.KLYS_21_PHAS.pvname), ts);
            
            obj.addMessage(['Saving data to ' pathName '/' fileName]);
            
        end
        
        function print2elog(obj)
            
            
            
            obj.addMessage('Printing to eLog.');
            
            obj.finalPlot(1);
            opts.title = 'Schottky Scan';
            opts.author = 'Matlab';
            opts.text = '';
            util_printLog(1,opts);
            
            obj.saveData();
        end
        
        function getScanParams(obj)
            
            if obj.dummy_mode
                obj.scan_param.start = obj.machine_state.init_gun_phas-0.01;
                obj.scan_param.end = obj.machine_state.init_gun_phas+0.01;
            else
                obj.scan_param.start = obj.guihan.PhaseStartEditField.Value;
                obj.scan_param.end = obj.guihan.PhaseEndEditField.Value;
            end
            obj.scan_param.n_steps = obj.guihan.StepsEditField.Value;
            obj.scan_param.n_shots = obj.guihan.ShotsperstepEditField.Value;
            obj.scan_param.step_vals = linspace(obj.scan_param.start,obj.scan_param.end,obj.scan_param.n_steps);

            
            obj.scan_param.step = 1;
            obj.scan_param.shot = 0;
            
        end
        
        function measDev(obj)
            
            % Dev list to match PV List
            gui_ind = strcmp(obj.devlist(:,1),obj.guihan.DiagnosticDropDown.Value);
            obj.data.devInd = gui_ind;
            obj.data.devStr = obj.devlist{gui_ind,2};
            obj.data.devName = obj.devlist{gui_ind,1};
            obj.data.devPV = obj.pvs.(obj.data.devStr).pvname;
            obj.data.conv = obj.devconv(gui_ind);
                        
            obj.addMessage(sprintf('Measurement device set to %s ',obj.data.devStr));
            
        end
            
        
        function addMessage(obj,message)
            
            obj.nMsg = obj.nMsg+1;
            obj.message{obj.nMsg} = message;
            fprintf(['%s (F2_SchottkyScan) ' message '\n'],datestr(now));
            
            msgBoxStr = '';
            if obj.nMsg < 4
                
                for i = 1:obj.nMsg
                    msgBoxStr = sprintf([msgBoxStr obj.message{i} '\n']);
                end
                
            else
                
                for i = (obj.nMsg-2):obj.nMsg
                    msgBoxStr = sprintf([msgBoxStr obj.message{i} '\n']);
                end
            end
            obj.guihan.MessagesTextArea.Value = msgBoxStr;
            
            
        end
        
        function end_watch(obj)
            
            stop(obj.pvlist);
            
        end
        
            
            
    end
end
