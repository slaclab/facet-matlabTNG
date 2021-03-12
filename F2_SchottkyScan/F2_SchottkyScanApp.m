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
            obj.pvs.KLYS_21_PHAS.guihan = apph.KLYSPHASEditField ;
            obj.pvs.KLYS_21_PDES.guihan = apph.KLYSPDESEditField ;
            
            % Set GUI callbacks for FC cup in/out
            %obj.pvs.fcupInOut.guihan = apph.FC1Switch ;
            
            % Set scan state false
            obj.scan_state = false;
            obj.mode = "IDLE";
            
            % Get initial PDES on PHAS tolerance
            obj.machine_state.init_phas = caget(obj.pvs.KLYS_21_PDES);
            obj.machine_state.phas_tol = apph.PhaseToldegEditField.Value;
            
            % Get state of Faraday cup
            obj.getFcupState();
            
            % Get initial measurement device
            obj.measDev();
            
            % Get initial scan params
            obj.getScanParams();
            
            % Start listening for PV updates
            obj.listeners = addlistener(obj,'PVUpdated',@(~,~) obj.loop) ;
            run(obj.pvlist,false,0.1,obj,'PVUpdated');                
                
        end
        
        function loop(obj)
            % function where stuff happens
            persistent lastMEAS lastPHAS
            
            switch obj.mode
                case "IDLE"
                    
                    % do nothing
                    
                case "PHASE_SETTING" % Waiting for Klystron (PDES - PHAS) < tol 
                    
                    if abs(obj.scan_param.step_vals(obj.scan_param.step) - obj.pvs.KLYS_21_PDES.val{1}) > obj.machine_state.phas_tol
                        
                        obj.addMessage('PDES not set. Aborting.');
                        obj.scan_state = false;
                        obj.mode = "IDLE";
                    end
                    
                    if isempty(lastPHAS) || lastPHAS ~= obj.pvs.KLYS_21_PHAS.val{1}
                        
                        lastPHAS = obj.pvs.KLYS_21_PHAS.val{1};
            
                        delta = abs(obj.pvs.KLYS_21_PHAS.val{1} - obj.pvs.KLYS_21_PDES.val{1});
                        if delta < obj.machine_state.phas_tol && obj.scan_state
                            obj.mode = "MEASUREMENT";
                        end
                        
                    end
                    
                case "MEASUREMENT" % acquring data
                    
                    if isempty(lastMEAS) || lastMEAS ~= obj.pvs.(obj.data.devStr).val{1}
                        
                        lastMEAS = obj.pvs.(obj.data.devStr).val{1};
                        obj.scan_param.shot=obj.scan_param.shot+1;
                    
                        obj.data.Measurements(obj.scan_param.shot,obj.scan_param.step) = obj.pvs.(obj.data.devStr).val{1};
                        
                        
                        
                        if obj.scan_param.shot == obj.scan_param.n_shots
                            
                            obj.addMessage(sprintf('End scan step %d.',obj.scan_param.step));
                            obj.scan_param.step=obj.scan_param.step+1;
                            
                            % End of scan
                            if obj.scan_param.step > obj.scan_param.n_steps
                                obj.scan_state = false;
                                obj.mode = "ANALYZE_DATA";
                                obj.analyzeData();
                            end
                            
                            obj.mode = "PHASE_SETTING";
                            obj.scan_param.shot = 0;
                            if ~obj.dummy_mode; caput(obj.pvs.KLYS_21_PDES,obj.scan_param.step_vals(obj.scan_param.step)); end
                            
                            obj.updatePlot();
                            
                        end                        
                    end
            end
            
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
            
            %obj.guihan.
            
            
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
        
        function startScan(obj)
            
            obj.getScanParams();
            
            obj.addMessage(sprintf('Scan start %0.2f, end %0.2f, steps %d.',...
                obj.scan_param.start,obj.scan_param.end,obj.scan_param.n_steps));
            
            obj.data.Measurements = zeros(obj.scan_param.n_shots,obj.scan_param.n_steps);
            
            obj.scan_state = true;
            obj.mode = "PHASE_SETTING";
            if ~obj.dummy_mode; caput(obj.pvs.KLYS_21_PDES,obj.scan_param.step_vals(obj.scan_param.step)); end
            
            obj.addMessage('Starting scan.');
            
        end
            
        
        function analyzeData(obj)
            
            obj.data.MeasMeans = mean(obj.data.Measurements);
            obj.data.MeasSTDs = std(obj.data.Measurements);
            obj.data.MeasEOMs = std(obj.data.Measurements)/sqrt(obj.scan_param.n_shots);
            
            obj.finalPlot();
            obj.saveData();
            
            obj.mode = "IDLE";
            
        end
        
        function updatePlot(obj)
            
            plot(obj.guihan.UIAxes,obj.scan_param.step_vals(1:obj.scan_param.step-1),obj.data.Measurements(:,1:obj.scan_param.step-1),'bo','linewidth',2);
            xlabel('Gun Phase [deg]','fontsize',14);
            ylabel('Charge [pC]','fontsize',14);
            
        end
        
        function finalPlot(obj)
            
            errorbar(obj.scan_param.step_vals,obj.data.MeasMeans,obj.data.MeasEOMs,'bo--','linewidth',2);
            xlabel('Gun Phase [deg]','fontsize',14);
            ylabel('Charge [pC]','fontsize',14);
            
        end
        
        function saveData(obj)
            
            obj.addMessage('Saving data.');
            
        end
        
        function print2elog(obj)
            util_printLog(1)
        end
        
        function getScanParams(obj)
            
            if obj.dummy_mode
                obj.scan_param.start = obj.machine_state.init_phas-0.01;
                obj.scan_param.end = obj.machine_state.init_phas+0.01;
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
            obj.data.devStr = obj.devlist{gui_ind,2};
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
