classdef F2_phasing_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        banner                  matlab.ui.control.Label
        ax                      matlab.ui.control.UIAxes
        labelTitle              matlab.ui.control.Label
        mainControlPanel        matlab.ui.container.Panel
        layoutControl           matlab.ui.container.GridLayout
        scanButton              matlab.ui.control.Button
        abortButton             matlab.ui.control.Button
        undoButton              matlab.ui.control.Button
        applyButton             matlab.ui.control.Button
        logbookButton           matlab.ui.control.Button
        helpButton              matlab.ui.control.Button
        ScanConfigurationPanel  matlab.ui.container.Panel
        layoutConfig            matlab.ui.container.GridLayout
        NstepsEditFieldLabel    matlab.ui.control.Label
        editNSteps              matlab.ui.control.NumericEditField
        rangeEditFieldLabel     matlab.ui.control.Label
        editRange               matlab.ui.control.NumericEditField
        KlysoffsetLabel         matlab.ui.control.Label
        editOffset              matlab.ui.control.NumericEditField
        NsamplesEditFieldLabel  matlab.ui.control.Label
        editNSamples            matlab.ui.control.NumericEditField
        selectZigzag            matlab.ui.control.CheckBox
        selectSLCBuff           matlab.ui.control.CheckBox
        SBSToffsetLabel         matlab.ui.control.Label
        editSBOffset            matlab.ui.control.NumericEditField
        selectSim               matlab.ui.control.CheckBox
        resultPanel             matlab.ui.container.Panel
        layoutResult            matlab.ui.container.GridLayout
        PDESEditFieldLabel      matlab.ui.control.Label
        initPDES                matlab.ui.control.NumericEditField
        PHASEditFieldLabel      matlab.ui.control.Label
        initPHAS                matlab.ui.control.NumericEditField
        GOLDEditFieldLabel      matlab.ui.control.Label
        initGOLD                matlab.ui.control.NumericEditField
        KPHREditField_2Label    matlab.ui.control.Label
        initKPHR                matlab.ui.control.NumericEditField
        finalPDES               matlab.ui.control.NumericEditField
        finalPHAS               matlab.ui.control.NumericEditField
        finalGOLD               matlab.ui.control.NumericEditField
        finalKPHR               matlab.ui.control.NumericEditField
        InitialLabel            matlab.ui.control.Label
        NewLabel                matlab.ui.control.Label
        updateInitButton        matlab.ui.control.Button
        CurrentLabel            matlab.ui.control.Label
        currentPDES             matlab.ui.control.NumericEditField
        currentPHAS             matlab.ui.control.NumericEditField
        currentGOLD             matlab.ui.control.NumericEditField
        currentKPHR             matlab.ui.control.NumericEditField
        updateCurrentButton     matlab.ui.control.Button
        Panel                   matlab.ui.container.Panel
        selectLinac             matlab.ui.control.DropDown
        KlystronLabel           matlab.ui.control.Label
        selectSector            matlab.ui.control.DropDown
        selectKlys              matlab.ui.control.DropDown
        klysActiveLamp          matlab.ui.control.Lamp
        EEditFieldLabel         matlab.ui.control.Label
        beamEnergy              matlab.ui.control.NumericEditField
        MeVLabel                matlab.ui.control.Label
        QEditFieldLabel         matlab.ui.control.Label
        bunchCharge             matlab.ui.control.NumericEditField
        pCLabel                 matlab.ui.control.Label
        specBPM                 matlab.ui.control.EditField
        EditFieldLabel          matlab.ui.control.Label
        bpmDispersion           matlab.ui.control.NumericEditField
        mmLabel                 matlab.ui.control.Label
        fEditFieldLabel         matlab.ui.control.Label
        beamRate                matlab.ui.control.NumericEditField
        HzLabel                 matlab.ui.control.Label
        BPMLabel                matlab.ui.control.Label
        Panel_2                 matlab.ui.container.Panel
        message                 matlab.ui.control.Label
        StatusLabel             matlab.ui.control.Label
    end

    
    properties (Access = private)
        N_elec % TMIT at BPM10221
        
        linac_map % array mask mapping sector,klys pairs to linac numbers
        target % struct with current linac/sector/klys params
        linac  % struct with linac params
        
        S % holds F2_phasescan obj
        
        % flags for catching abort rquests
        ABORT_REQUEST = false;  
        SCAN_ABORTED = false;
        
        % flag for determining if a scan if finished
        SCAN_READY = false;
        successful_scan = false;
    end
    
    methods (Access = private)
        
        % disables all interactive components, called during callback
        % execution in hopes of protecting user from self
        function enable_controls(app, state)
            app.scanButton.Enable = state;
            app.applyButton.Enable = state;
            app.abortButton.Enable = state;
            app.undoButton.Enable = state;
            app.helpButton.Enable = state;
            app.logbookButton.Enable = state;
            app.selectLinac.Enable = state;
            app.selectSector.Enable = state;
            app.selectKlys.Enable = state;
            app.editRange.Enable = state;
            app.editNSteps.Enable = state;
            app.editNSamples.Enable = state;
            app.selectZigzag.Enable = state;
            app.selectSim.Enable = state;
            app.updateCurrentButton.Enable = state;
            app.updateInitButton.Enable = state;
        end
 
        % associate each linac with an int labelling its linac region
        % L0: 10-3, 10-4
        % L1: 11-1, 11-2
        % L2: 11-4 - 14-8
        % L3: 15-1 - 19-6
        function construct_klys_map(app)
            % literal indexing wastes ~11*8 elements, but who cares lol
            %app.linac_map = zeros(20, 8);
            app.linac_map = NaN(20,8);
            app.linac_map(10,3:4) = 0;
            app.linac_map(11,1:2) = 1;
            app.linac_map(11,4:8) = 2;
            app.linac_map(12:14,:) = 2;
            app.linac_map(15:19,:) = 3;
            
            % 14-7, 15-2, and 19-7,8 do not exist, set back to NaN
            app.linac_map(14,7) = NaN;
            app.linac_map(15,2) = NaN;
            app.linac_map(19,7:8) = NaN;
        end

        % get klystron status to determine if station is on beam
        function update_klys_stat(app)
            app.klysActiveLamp.Color = [0.3 0.3 0.3];
            
            [act, ~,~,~,~,~] = control_klysStatGet(app.target.klys_str, 10);
            % TO DO: replace with manual inspection of HSTA (?)
            
            disp(app.target.klys_str);
            disp(act);
            
            % enable scan button and set active light green for stations on
            % beam, otherwise leave scan button disabled and set the light
            % to black or red if the station is off-beam or MNT/TBR/ARU
            lamp_color = [0.3 0.3 0.3];
            app.SCAN_READY = false;
            
            if bitget(act, 1)
                lamp_color = [0.0 1.0 0.0];
                msg = 'Ready to scan %s.';
                app.SCAN_READY = true;
            elseif bitget(act, 2)
                msg = '%s is not triggering on accelerate time.';
            elseif bitget(act, 3)
                lamp_color = [1.0 0.0 0.0];
                msg = '%s is OFF/MNT.';
            end
            
            app.klysActiveLamp.Color = lamp_color;
            app.message.Text = sprintf(msg, app.target.klys_str);
        end
        
        % get current klystron PDES, PHAS, GOLD & KPHR
        function update_klys_phase_params(app)
            [PACT, PDES, ~, ~, KPHR, GOLD] = control_phaseGet(app.target.klys_str);
            app.initPDES.Value = PDES;
            app.initPHAS.Value = PACT;
            app.initGOLD.Value = GOLD;
            app.initKPHR.Value = KPHR;
        end
        
        % helper to update chrge, rate energy in one line
        function update_operating_point(app)
            app.update_klys_phase_params();
            app.N_elec              = app.S.beam.N_elec;
            app.bunchCharge.Value   = app.S.beam.Q;
            app.beamRate.Value      = app.S.beam.f;
            app.beamEnergy.Value    = app.S.beam.E_design;
            app.specBPM.Value       = app.S.beam.BPM;
            app.bpmDispersion.Value = app.S.beam.eta;
        end
        
        % populate app.S.in struct from GUI
        function get_scan_inputs(app)
            app.S.in.dPhi = app.editRange.Value;
            app.S.in.N_steps = app.editNSteps.Value;
            app.S.in.N_samples = app.editNSamples.Value;
            app.S.in.klys_offset = app.editOffset.Value;
            app.S.in.sbst_offset = app.editSBOffset.Value;
            app.S.in.zigzag = app.selectZigzag.Value;
            app.S.in.simulation = app.selectSim.Value;
            app.S.in.phi_set = app.initPDES.Value;
            app.S.in.PDES = app.initPDES.Value;
            app.S.in.PHAS = app.initPHAS.Value;
            app.S.in.GOLD = app.initGOLD.Value;
            app.S.in.KPHR = app.initKPHR.Value;
            
            app.S.undo.PDES = app.S.in.PDES;
            app.S.undo.PHAS = app.S.in.PHAS;
            app.S.undo.GOLD = app.S.in.GOLD;
            app.S.undo.KPHR = app.S.in.KPHR;
            
            app.S.compute_scan_range();
            app.S.init_msmt();
        end
        
        % collect N samples of EPICS BPM data (x + TMIT)
        function bpm_data = collect_BPM_data(app)
            
            N_samp = app.editNSamples.Value;
            bpm_data = zeros(N_samp, 2);
            PV_x = app.linac.bpm_x_PVs(app.target.linac);
            PV_TMIT = app.linac.bpm_tmit_PVs(app.target.linac);

            % need to monkey this str back into a cell array for lcaMonitor
            PV_x = {sprintf('%s', PV_x)};
           
            lcaSetMonitor(PV_x);
            for i = 1:app.editNSamples.Value
                
                % ABORT CHECK
                if app.ABORT_REQUEST, app.SCAN_ABORTED = true; break; end
                
                %lcaNewMonitorWait(PV_x);
                pause(0.1);
                xpos = lcaGetSmart(PV_x);
                tmit = lcaGetSmart(PV_TMIT);
                bpm_data(i,2) = tmit;

                % bpm data with <80% or >110% expected TMIT are discarded
                if (tmit > 0.8*app.N_elec) && (tmit < 1.5*app.N_elec)
                    bpm_data(i,1) = xpos;
                else
                    bpm_data(i,1) = NaN;
                end
            end
        end
        
        % subroutine to correct energy in L1 before phase scans
        function SSSB_energy_correction(app)

        	pos_tolerance = 0.1;   % BPM tolerance in mm
        	max_iters     = 1000;  % iteration cap to prevent runaway
            
        	if strcmp(app.target.klys_str, '11-1')
        		klys = 21;
        		klys_str = '11-2';
        	else
        		klys = 11;
        		klys_str = '11-1';
        	end
            
            app.message.Text(sprintf('Correcting L1 energy with %s...', klys_str));
            
        	PV_ADES = sprintf('KLYS:LI11:%d1:SSSB_ADES', klys);
        	ADES_init = lcaGetSmart(PV_ADES);
        	ADES_current = ADES_init;
            
            [xraw, ~] = app.collect_BPM_data();
            x = nanmean(xraw);

            i = 0;
        	while (i < max_iters) && (abs(x) >= pos_tolerance)
                i = i + 1;
                
                % default step of 0.1MeV, 0.5MeV when further off-energy
                % dispersion is negative at BC11, so sign(x) <-> sign(dE)
                amp_step = 0.1;
                if abs(x) > 1.0, amp_step = 0.5; end
                lcaPutSmart(PV_ADES, ADES_current + sign(x)*amp_step);
                
                ADES_current = lcaGetSmart(PV_ADES);
                [xraw, ~] = app.collect_BPM_data();
                x = nanmean(xraw);
            end

        end
        
        % helper to correctly label x/y axis
        function label_plot(app, axis)
            title(axis, sprintf('Phase scan: %s  %s', app.target.klys_str, app.S.start_time));
            xlabel(axis, ['\phi ' app.target.klys_str], 'Interpreter','tex')
            yyaxis(axis,'left');
            yl = sprintf('%s [mm]', app.linac.bpm_x_PVs(app.target.linac));
            ylabel(axis, yl, 'Interpreter','tex');
            yyaxis(axis,'right');
            ylabel(axis, sprintf('\\Delta E [MeV]'), 'Interpreter', 'tex');
        end
        
        % set up axes, labels before phase scanning
        function stage_plot(app)
            hold(app.ax,"off");
            app.label_plot(app.ax);
        end
        
        % generate final phase scan plot for logbook
        function fig = make_plot(app)
            fig = figure('position',[500,500,800,600]);
            axis = axes;
            axis.FontSize = 12;
            hold(axis, "on");
            
            % plot raw measurement + fit for position and energy
            yyaxis(axis,'left');
            errorbar(axis, app.S.msmt.PHI, app.S.msmt.X, app.S.msmt.X_err, '.k', 'MarkerSize', 10);
            plot(axis, app.S.fit.range, app.S.fit.X, '-', 'Color',"#0072bd", 'LineWidth',2);
            
            yyaxis(axis,'right');
            errorbar(axis, app.S.msmt.PHI, app.S.msmt.dE, app.S.msmt.dE_err,...
                '.', 'Color',"#7e2f8e", 'MarkerSize',10);
            plot(axis, app.S.fit.range, app.S.fit.dE, '-', 'Color',"#d95319", 'LineWidth',2);
            
            % vertical lines for phase setpoint & measurement
            xline(axis, app.S.in.phi_set, '--', 'Color',"#666666", 'LineWidth',2)
            xline(axis, -1*app.S.fit.phi_meas, '--g', 'LineWidth',2);

            app.label_plot(axis);
            shg
        end
        
        % main phase scan code for L2, L3 (SLC) klystrons
        function phase_scan(app)
            
            app.successful_scan = false;
            
            init_phase = app.initPDES.Value;
            app.S.in.phi_set = init_phase;
            if app.target.linac == 1
                init_phase = app.initKPHR.Value;
            end
            
            % (0) verify that TD11 is in if scanning L1
            if app.target.linac < 2
                TD11_in = strcmp(lcaGetSmart('DUMP:LI11:390:TGT_STS'), 'IN');
                if ~TD11_in
                    app.message.Text = 'TD-11 is not inserted. Scan aborted.';
                    return
                end
            end
            
            % (3) disable relevant longitudinal feedbacks before scanning
            if ~app.S.in.simulation, app.S.disable_feedbacks(); end
            
            app.stage_plot();
            
            % fake phase error & amplitude for testing
            if app.S.in.simulation
                err = 80.0*randn();
                A_test = sign(app.linac.dispersion(app.target.linac)) * 5.0;
            end
            
            dE_dx = app.S.E_design / app.S.eta;
            N_steps = app.S.in.N_steps;
                        
            % (4) iterate over each phase setting
            for i = 1:N_steps
                
                step_str = sprintf('[%d/%d]', i, N_steps);
                phi_i = app.S.in.range(i);
                
                % ABORT CHECK (1/3)
                if app.ABORT_REQUEST, app.SCAN_ABORTED = true; break; end

                % (4.1) set phase
                app.message.Text = sprintf('%s Setting %s phase = %.1f deg ...', ...
                    step_str, app.target.klys_str, phi_i ...
                    );
                if app.S.in.simulation, pause(0.05);
                else
                    [PACT, OK] = app.S.set_phase(phi_i);
                end
                
                % ABORT CHECK (2/3)
                if app.ABORT_REQUEST, app.SCAN_ABORTED = true; break; end
                
                % (4.2) collect BPM data
                app.message.Text = sprintf('%s Collecting BPM data ...', step_str);
                % fake data for simulation
                if app.S.in.simulation
                    app.S.msmt.X(i) = A_test * (cosd(phi_i - init_phase + err) + 0.02*randn());
                    app.S.msmt.X_err(i) = 0.5*rand();
                    app.S.msmt.PHI(i) = phi_i - init_phase;
                else
                    bpm_data = app.collect_BPM_data();
                    app.S.msmt.X(i) = nanmean(bpm_data(:,1));
                    app.S.msmt.X_err(i) = nanstd(bpm_data(:,1));
                    app.S.msmt.PHI(i) = phi_i - init_phase;
                end
                
                % (4.3) compute (estimated) energy error
                app.S.msmt.dE(i) = dE_dx * app.S.msmt.X(i);
                app.S.msmt.dE_err(i) = dE_dx * app.S.msmt.X_err(i);

                % ABORT CHECK (3/3)
                if app.ABORT_REQUEST, app.SCAN_ABORTED = true; break; end
                
                % (4.4) update plot
                hold(app.ax,"off");
                yyaxis(app.ax,'left');
                errorbar(app.ax, app.S.msmt.PHI(1:i), app.S.msmt.X(1:i), app.S.msmt.X_err(1:i), ...
                    '.k', 'MarkerSize', 10);
                yyaxis(app.ax,'right');
                errorbar(app.ax, app.S.msmt.PHI(1:i), app.S.msmt.dE(1:i), app.S.msmt.dE_err(1:i),...
                    '.', 'Color',"#7e2f8e", 'MarkerSize',10);
                hold(app.ax,"on");
                
            end
            
            % no fitting/plotting if the scan was aborted
            if app.SCAN_ABORTED, return; end
            
            % (5) fit BPM data and calculate beam phase error and energy
            app.S.beam_phase_fit();

            app.successful_scan = true;
            
            %fprintf('phi set  = %.1f deg\n', app.S.in.phi_set);
            %fprintf('phi act  = %.2f deg\n', err);
            %fprintf('phi meas = %.2f deg\n', app.S.fit.phi_meas);
            %fprintf('est. dE  = %.2f MeV\n', app.S.fit.E0);
            %fprintf('\n');
            %disp(app.S.fit);
            
            % (6) plot fit and scan result
            hold(app.ax,"on");
            yyaxis(app.ax,'right');
            plot(app.ax, app.S.fit.range, app.S.fit.dE, '-', 'Color',"#d95319", 'LineWidth',2);
            yyaxis(app.ax,'left');
            plot(app.ax, app.S.fit.range, app.S.fit.X, '-', 'Color',"#0072bd", 'LineWidth',2);
            xline(app.ax, app.S.in.phi_set, '--', 'Color',"#666666", 'LineWidth',2)
            xline(app.ax, -1*app.S.fit.phi_meas, '--g', 'LineWidth',2);
            
            app.message.Text = 'Scan completed.';
            
            % (7) restore initial phase setting
            if ~app.S.in.simulation, app.S.set_phase(init_phase); end
            
        end
 
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.target = struct;
            app.linac = struct;
            
            app.target.linac = 1;
            app.target.sector = 11;
            app.target.klys = 1;
            app.target.klys_str = '11-1';
            
            % X, TMIT PVs for each spectrometer BPM
            app.linac.bpm_x_PVs = [ ...
                "BPMS:LI11:333:X" "BPMS:LI14:801:X" "BPMS:LI20:2050:X57" ...
                ];
            app.linac.bpm_tmit_PVs = [ ...
                "BPMS:LI11:333:TMIT" "BPMS:LI14:801:TMIT" "BPMS:LI20:2050:TMIT" ...
                ];
            % bend magnet strength to get beam energy milestone
            app.linac.energy_PVs = [ ...
                "BEND:LI11:331:BACT" "BEND:LI14:720:BACT" "LI20:LGPS:1990:BACT" ...
                ];
            % initialize scan object in case there isn't one already held
            % TO DO: is this when to prompt user before old scan deletion ??
            app.S = F2_phasescan(app.target.linac, app.target.sector, app.target.klys);
            
            app.construct_klys_map();
            app.update_klys_stat();
            app.update_operating_point();
            
            % re-label plot axes
            app.label_plot(app.ax);
            
            disableDefaultInteractivity(app.ax);
        end

        % Value changed function: selectLinac
        function selectLinacValueChanged(app, event)
            app.target.linac = uint8(str2double(app.selectLinac.Value(end)));
        
            % update list of sectors, default target: 1st sector
            [~,s] = find(app.linac_map' == app.target.linac);
            app.selectSector.Items = string(unique(s));
            app.selectSector.Value = string(s(1));
            app.selectSectorValueChanged(event);
            
            % modify default scan params for L1, disable gold/offset box
            if app.target.linac == 1
                app.editRange.Value = 20;
                app.editNSteps.Value = 15;
            else
                app.editRange.Value = 60;
                app.editNSteps.Value = 9;
            end
        end

        % Value changed function: selectSector
        function selectSectorValueChanged(app, event)
            app.target.sector = uint8(str2double(app.selectSector.Value));
            
            % update klys list, default target: 1st klys
            [k,s] = find(app.linac_map' == app.target.linac);
            available_klys = [];
            for i = 1:size(k)
                if s(i) == app.target.sector
                    available_klys(end+1) = k(i);
                end
            end
            app.selectKlys.Items = string(available_klys);
            app.selectKlys.Value = string(available_klys(1));
            app.selectKlysValueChanged(event);
            
            % for L2-3 subbooster PDES, populate sbst offset accordingly
            app.editSBOffset.Value = 0;
            if app.target.linac ~= 1    
                p_sbst = lcaGetSmart(sprintf("LI%d:SBST:1:PDES", app.target.sector));
                if abs(p_sbst) > 0, app.editSBOffset.Value = -1 * p_sbst; end
            end
            
        end

        % Value changed function: selectKlys
        function selectKlysValueChanged(app, event)
            app.enable_controls(false); 
            app.message.Text = 'Checking klystron status ...'; drawnow;

            app.target.klys = uint8(str2double(app.selectKlys.Value));
            app.target.klys_str = sprintf('%d-%d',app.target.sector,app.target.klys);
            app.scanButton.Text = sprintf('Scan %s', app.target.klys_str);
            
            % once user selects a klystron check if it is on beam time
            % and grab it's current phase settings
            app.update_klys_stat();
            app.update_klys_phase_params();
            
            % populate offset field based on PDES
            offset = 0;
            if abs(app.initPDES.Value) > 0, offset = -1 * app.initPDES.Value; end
            app.editOffset.Value = offset;
            
            % initialize scan object in case there isn't one already held
            % TO DO: is this when to prompt user before old scan deletion ??
            app.S = F2_phasescan(app.target.linac, app.target.sector, app.target.klys);
            
            app.update_operating_point();
            
            % re-label plot axes
            app.label_plot(app.ax);
            
            app.enable_controls(true);
            
            % disable undo/gold/logbook buttons
            app.scanButton.Enable = app.SCAN_READY;
            app.abortButton.Enable = false;
            app.undoButton.Enable = false;
            app.applyButton.Enable = false;
            app.logbookButton.Enable = false;
            
        end

        % Button pushed function: scanButton
        function scanButtonPushed(app, event)
            app.enable_controls(false); drawnow;
            app.abortButton.Enable = true;
            app.helpButton.Enable = true;
            app.scanButton.Text = 'Scanning...';
            
            % initialize scan object
            app.S = F2_phasescan(app.target.linac, app.target.sector, app.target.klys);
            app.get_scan_inputs();
            
            % run the scan!
            app.phase_scan();

            % if the scan was aborted DO STUFF!!! (???)
            if app.SCAN_ABORTED
                app.message.Text = sprintf('%s scan aborted.', app.target.klys_str);
                app.ABORT_REQUEST = false;
                app.SCAN_ABORTED = false;
            end
            
            app.enable_controls(true);
            app.scanButton.Enable = true;
            app.abortButton.Enable = false;
            app.undoButton.Enable = true;
            app.applyButton.Enable = app.successful_scan;
            app.logbookButton.Enable = app.successful_scan;
            
            app.scanButton.Text = sprintf('Scan %s', app.target.klys_str);
        end

        % Button pushed function: applyButton
        function applyButtonPushed(app, event)
            app.message.Text = 'Applying phase correction ...';
            app.enable_controls(false);
            if abs(app.S.fit.phi_meas) > 20.0
                resp = questdlg('Large (>20deg) phase change. Set measured zero phase?');
                if ~strcmp(resp, 'Yes')
                    app.message.Text = 'Phase correction declined.';
                    app.enable_controls(true);
                    app.abortButton.Enable = false;
                    return
                end
            end
            
            % to correct phase subtract phi_meas from the initial phase setting
            phi_init = app.S.in.PDES;
            if app.target.linac == 1, phi_init = app.S.in.KPHR; end
            phi_zero = phi_init - app.S.fit.phi_meas;
            fprintf('phi init = %.1f, phi final = %.1f\n', phi_init, phi_zero);
            
            app.S.out.GOLD = app.S.in.GOLD - app.S.fit.phi_meas;
            if app.target.linac == 1
                app.S.out.KPHR = app.in.KPHR - app.S.fit.phi_meas;
            end
            
            app.S.set_phase(phi_zero);
            disp('set phase');
            app.message.Text = sprintf('%s set to measured zero phase.', app.target.klys_str);
            pause(2)
            [PACT, PDES, GOLD] = control_phaseGold(app.target.klys_str, app.S.in.phi_set);
            disp(PACT);
            disp(PDES);
            disp(GOLD);
            app.message.Text = sprintf('%s phase reGOLDed to %.1f.', app.target.klys_str, phi_zero);
            pause(3)
            if abs(app.S.in.phi_set) > 0
                [PACT, OK] = control_phaseSet(app.target.klys_str, 0.0);
                app.message.Text = sprintf('%s restored to on-crest phase', app.target.klys_str);
            end
            
            app.enable_controls(true);
        end

        % Button pushed function: logbookButton
        function logbookButtonPushed(app, event)
            fig = app.make_plot();
            opts.title = sprintf('Phase Scan: %s', app.target.klys_str);
            opts.author = 'FACET-II Phase Scan GUI';
            util_printLog(fig, opts);
            app.message.Text = 'Plot posted to physics elog.';
        end

        % Button pushed function: abortButton
        function abortButtonPushed(app, event)
            app.ABORT_REQUEST = true;
            app.message.Text = 'ABORT REQUESTED';
        end

        % Button pushed function: undoButton
        function undoButtonPushed(app, event)
            app.message.Text = 'Undoing scan ...';
            pause(3)
            app.message.Text = sprintf('%s phase settings restored.', app.target.klys_str);
        end

        % Button pushed function: helpButton
        function helpButtonPushed(app, event)
            prev_msg = app.message.Text;
            app.message.Text = 'Opening MCC wiki ...';
            system("firefox https://aosd.slac.stanford.edu/wiki/index.php/FACET-II_Phase_Scan_GUI &");
            pause(3)
            app.message.Text = prev_msg;
        end

        % Button pushed function: updateInitButton
        function updateInitButtonPushed(app, event)
            app.update_klys_phase_params();
        end

        % Button pushed function: updateCurrentButton
        function updateCurrentButtonPushed(app, event)
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1000 650];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.Resize = 'off';
            app.UIFigure.BusyAction = 'cancel';
            app.UIFigure.Interruptible = 'off';

            % Create banner
            app.banner = uilabel(app.UIFigure);
            app.banner.BackgroundColor = [1 0.5843 0.2353];
            app.banner.Position = [1 641 1000 10];
            app.banner.Text = {''; ''};

            % Create ax
            app.ax = uiaxes(app.UIFigure);
            title(app.ax, 'Title')
            xlabel(app.ax, '\phi')
            ylabel(app.ax, {'\Delta x (BPMS:LI11:333:X)'; ''})
            app.ax.FontSize = 14;
            app.ax.Position = [380 20 600 510];

            % Create labelTitle
            app.labelTitle = uilabel(app.UIFigure);
            app.labelTitle.FontSize = 20;
            app.labelTitle.FontWeight = 'bold';
            app.labelTitle.FontAngle = 'italic';
            app.labelTitle.Position = [21 601 960 40];
            app.labelTitle.Text = 'Linac RF Phase Scans';

            % Create mainControlPanel
            app.mainControlPanel = uipanel(app.UIFigure);
            app.mainControlPanel.Position = [21 521 340 80];

            % Create layoutControl
            app.layoutControl = uigridlayout(app.mainControlPanel);
            app.layoutControl.ColumnWidth = {'1x', '1x', '1x'};
            app.layoutControl.ColumnSpacing = 5;
            app.layoutControl.RowSpacing = 5;
            app.layoutControl.Padding = [4 4 4 4];

            % Create scanButton
            app.scanButton = uibutton(app.layoutControl, 'push');
            app.scanButton.ButtonPushedFcn = createCallbackFcn(app, @scanButtonPushed, true);
            app.scanButton.BackgroundColor = [0 1 0];
            app.scanButton.FontSize = 16;
            app.scanButton.FontWeight = 'bold';
            app.scanButton.Layout.Row = 1;
            app.scanButton.Layout.Column = 1;
            app.scanButton.Text = 'Scan 11-1';

            % Create abortButton
            app.abortButton = uibutton(app.layoutControl, 'push');
            app.abortButton.ButtonPushedFcn = createCallbackFcn(app, @abortButtonPushed, true);
            app.abortButton.BackgroundColor = [1 0 0];
            app.abortButton.FontSize = 16;
            app.abortButton.FontWeight = 'bold';
            app.abortButton.FontColor = [1 1 1];
            app.abortButton.Enable = 'off';
            app.abortButton.Layout.Row = 2;
            app.abortButton.Layout.Column = 1;
            app.abortButton.Text = 'Abort';

            % Create undoButton
            app.undoButton = uibutton(app.layoutControl, 'push');
            app.undoButton.ButtonPushedFcn = createCallbackFcn(app, @undoButtonPushed, true);
            app.undoButton.BackgroundColor = [0.9373 0.9608 0.5373];
            app.undoButton.FontSize = 16;
            app.undoButton.FontWeight = 'bold';
            app.undoButton.Enable = 'off';
            app.undoButton.Layout.Row = 2;
            app.undoButton.Layout.Column = 2;
            app.undoButton.Text = 'Undo';

            % Create applyButton
            app.applyButton = uibutton(app.layoutControl, 'push');
            app.applyButton.ButtonPushedFcn = createCallbackFcn(app, @applyButtonPushed, true);
            app.applyButton.BackgroundColor = [1 0.5843 0.2353];
            app.applyButton.FontSize = 16;
            app.applyButton.FontWeight = 'bold';
            app.applyButton.Enable = 'off';
            app.applyButton.Layout.Row = 1;
            app.applyButton.Layout.Column = 2;
            app.applyButton.Text = 'Apply';

            % Create logbookButton
            app.logbookButton = uibutton(app.layoutControl, 'push');
            app.logbookButton.ButtonPushedFcn = createCallbackFcn(app, @logbookButtonPushed, true);
            app.logbookButton.BackgroundColor = [0.251 0.8706 0.9608];
            app.logbookButton.FontSize = 16;
            app.logbookButton.FontWeight = 'bold';
            app.logbookButton.Enable = 'off';
            app.logbookButton.Layout.Row = 1;
            app.logbookButton.Layout.Column = 3;
            app.logbookButton.Text = 'Logbook';

            % Create helpButton
            app.helpButton = uibutton(app.layoutControl, 'push');
            app.helpButton.ButtonPushedFcn = createCallbackFcn(app, @helpButtonPushed, true);
            app.helpButton.FontSize = 16;
            app.helpButton.FontWeight = 'bold';
            app.helpButton.Layout.Row = 2;
            app.helpButton.Layout.Column = 3;
            app.helpButton.Text = 'Help';

            % Create ScanConfigurationPanel
            app.ScanConfigurationPanel = uipanel(app.UIFigure);
            app.ScanConfigurationPanel.Title = 'Scan Configuration';
            app.ScanConfigurationPanel.FontWeight = 'bold';
            app.ScanConfigurationPanel.FontSize = 16;
            app.ScanConfigurationPanel.Position = [21 231 341 150];

            % Create layoutConfig
            app.layoutConfig = uigridlayout(app.ScanConfigurationPanel);
            app.layoutConfig.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.layoutConfig.RowHeight = {'1x', '1x', '1x', '1x'};
            app.layoutConfig.ColumnSpacing = 5;
            app.layoutConfig.RowSpacing = 5;
            app.layoutConfig.Padding = [4 4 4 4];

            % Create NstepsEditFieldLabel
            app.NstepsEditFieldLabel = uilabel(app.layoutConfig);
            app.NstepsEditFieldLabel.HorizontalAlignment = 'right';
            app.NstepsEditFieldLabel.FontSize = 14;
            app.NstepsEditFieldLabel.Layout.Row = 2;
            app.NstepsEditFieldLabel.Layout.Column = [1 3];
            app.NstepsEditFieldLabel.Text = 'N steps';

            % Create editNSteps
            app.editNSteps = uieditfield(app.layoutConfig, 'numeric');
            app.editNSteps.FontSize = 14;
            app.editNSteps.Layout.Row = 2;
            app.editNSteps.Layout.Column = [4 5];
            app.editNSteps.Value = 15;

            % Create rangeEditFieldLabel
            app.rangeEditFieldLabel = uilabel(app.layoutConfig);
            app.rangeEditFieldLabel.HorizontalAlignment = 'right';
            app.rangeEditFieldLabel.FontSize = 14;
            app.rangeEditFieldLabel.Layout.Row = 1;
            app.rangeEditFieldLabel.Layout.Column = [1 3];
            app.rangeEditFieldLabel.Text = '+/- range';

            % Create editRange
            app.editRange = uieditfield(app.layoutConfig, 'numeric');
            app.editRange.FontSize = 14;
            app.editRange.Layout.Row = 1;
            app.editRange.Layout.Column = [4 5];
            app.editRange.Value = 20;

            % Create KlysoffsetLabel
            app.KlysoffsetLabel = uilabel(app.layoutConfig);
            app.KlysoffsetLabel.HorizontalAlignment = 'right';
            app.KlysoffsetLabel.FontSize = 14;
            app.KlysoffsetLabel.Layout.Row = 2;
            app.KlysoffsetLabel.Layout.Column = [7 9];
            app.KlysoffsetLabel.Text = 'Klys offset';

            % Create editOffset
            app.editOffset = uieditfield(app.layoutConfig, 'numeric');
            app.editOffset.Editable = 'off';
            app.editOffset.FontSize = 14;
            app.editOffset.Layout.Row = 2;
            app.editOffset.Layout.Column = [10 11];

            % Create NsamplesEditFieldLabel
            app.NsamplesEditFieldLabel = uilabel(app.layoutConfig);
            app.NsamplesEditFieldLabel.HorizontalAlignment = 'right';
            app.NsamplesEditFieldLabel.FontSize = 14;
            app.NsamplesEditFieldLabel.Layout.Row = 3;
            app.NsamplesEditFieldLabel.Layout.Column = [1 3];
            app.NsamplesEditFieldLabel.Text = 'N samples';

            % Create editNSamples
            app.editNSamples = uieditfield(app.layoutConfig, 'numeric');
            app.editNSamples.FontSize = 14;
            app.editNSamples.Layout.Row = 3;
            app.editNSamples.Layout.Column = [4 5];
            app.editNSamples.Value = 20;

            % Create selectZigzag
            app.selectZigzag = uicheckbox(app.layoutConfig);
            app.selectZigzag.Text = 'Zigzag';
            app.selectZigzag.FontSize = 14;
            app.selectZigzag.Layout.Row = 4;
            app.selectZigzag.Layout.Column = [4 6];

            % Create selectSLCBuff
            app.selectSLCBuff = uicheckbox(app.layoutConfig);
            app.selectSLCBuff.Enable = 'off';
            app.selectSLCBuff.Text = 'SLC buffer acquisition';
            app.selectSLCBuff.FontSize = 14;
            app.selectSLCBuff.Layout.Row = 4;
            app.selectSLCBuff.Layout.Column = [7 12];

            % Create SBSToffsetLabel
            app.SBSToffsetLabel = uilabel(app.layoutConfig);
            app.SBSToffsetLabel.HorizontalAlignment = 'right';
            app.SBSToffsetLabel.FontSize = 14;
            app.SBSToffsetLabel.Layout.Row = 1;
            app.SBSToffsetLabel.Layout.Column = [7 9];
            app.SBSToffsetLabel.Text = 'SBST offset';

            % Create editSBOffset
            app.editSBOffset = uieditfield(app.layoutConfig, 'numeric');
            app.editSBOffset.Editable = 'off';
            app.editSBOffset.FontSize = 14;
            app.editSBOffset.Layout.Row = 1;
            app.editSBOffset.Layout.Column = [10 11];

            % Create selectSim
            app.selectSim = uicheckbox(app.layoutConfig);
            app.selectSim.Text = 'Simulated scan';
            app.selectSim.FontSize = 14;
            app.selectSim.Layout.Row = 3;
            app.selectSim.Layout.Column = [7 11];
            app.selectSim.Value = true;

            % Create resultPanel
            app.resultPanel = uipanel(app.UIFigure);
            app.resultPanel.Title = 'Phase Control Settings';
            app.resultPanel.FontWeight = 'bold';
            app.resultPanel.FontSize = 16;
            app.resultPanel.Position = [21 21 341 200];

            % Create layoutResult
            app.layoutResult = uigridlayout(app.resultPanel);
            app.layoutResult.ColumnWidth = {'1x', '1x', '1x', '1x', '1x'};
            app.layoutResult.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x'};
            app.layoutResult.ColumnSpacing = 5;
            app.layoutResult.RowSpacing = 5;
            app.layoutResult.Padding = [4 4 4 4];

            % Create PDESEditFieldLabel
            app.PDESEditFieldLabel = uilabel(app.layoutResult);
            app.PDESEditFieldLabel.HorizontalAlignment = 'right';
            app.PDESEditFieldLabel.FontSize = 14;
            app.PDESEditFieldLabel.Layout.Row = 2;
            app.PDESEditFieldLabel.Layout.Column = 1;
            app.PDESEditFieldLabel.Text = 'PDES';

            % Create initPDES
            app.initPDES = uieditfield(app.layoutResult, 'numeric');
            app.initPDES.ValueDisplayFormat = '%.1f';
            app.initPDES.Editable = 'off';
            app.initPDES.FontSize = 14;
            app.initPDES.Layout.Row = 2;
            app.initPDES.Layout.Column = 2;

            % Create PHASEditFieldLabel
            app.PHASEditFieldLabel = uilabel(app.layoutResult);
            app.PHASEditFieldLabel.HorizontalAlignment = 'right';
            app.PHASEditFieldLabel.FontSize = 14;
            app.PHASEditFieldLabel.Layout.Row = 3;
            app.PHASEditFieldLabel.Layout.Column = 1;
            app.PHASEditFieldLabel.Text = 'PHAS';

            % Create initPHAS
            app.initPHAS = uieditfield(app.layoutResult, 'numeric');
            app.initPHAS.ValueDisplayFormat = '%.1f';
            app.initPHAS.Editable = 'off';
            app.initPHAS.FontSize = 14;
            app.initPHAS.Layout.Row = 3;
            app.initPHAS.Layout.Column = 2;

            % Create GOLDEditFieldLabel
            app.GOLDEditFieldLabel = uilabel(app.layoutResult);
            app.GOLDEditFieldLabel.HorizontalAlignment = 'right';
            app.GOLDEditFieldLabel.FontSize = 14;
            app.GOLDEditFieldLabel.Layout.Row = 4;
            app.GOLDEditFieldLabel.Layout.Column = 1;
            app.GOLDEditFieldLabel.Text = 'GOLD';

            % Create initGOLD
            app.initGOLD = uieditfield(app.layoutResult, 'numeric');
            app.initGOLD.ValueDisplayFormat = '%.1f';
            app.initGOLD.Editable = 'off';
            app.initGOLD.FontSize = 14;
            app.initGOLD.Layout.Row = 4;
            app.initGOLD.Layout.Column = 2;

            % Create KPHREditField_2Label
            app.KPHREditField_2Label = uilabel(app.layoutResult);
            app.KPHREditField_2Label.HorizontalAlignment = 'right';
            app.KPHREditField_2Label.FontSize = 14;
            app.KPHREditField_2Label.Layout.Row = 5;
            app.KPHREditField_2Label.Layout.Column = 1;
            app.KPHREditField_2Label.Text = 'KPHR';

            % Create initKPHR
            app.initKPHR = uieditfield(app.layoutResult, 'numeric');
            app.initKPHR.ValueDisplayFormat = '%.1f';
            app.initKPHR.Editable = 'off';
            app.initKPHR.FontSize = 14;
            app.initKPHR.Layout.Row = 5;
            app.initKPHR.Layout.Column = 2;

            % Create finalPDES
            app.finalPDES = uieditfield(app.layoutResult, 'numeric');
            app.finalPDES.ValueDisplayFormat = '%.1f';
            app.finalPDES.Editable = 'off';
            app.finalPDES.FontSize = 14;
            app.finalPDES.Layout.Row = 2;
            app.finalPDES.Layout.Column = 4;

            % Create finalPHAS
            app.finalPHAS = uieditfield(app.layoutResult, 'numeric');
            app.finalPHAS.ValueDisplayFormat = '%.1f';
            app.finalPHAS.Editable = 'off';
            app.finalPHAS.FontSize = 14;
            app.finalPHAS.Layout.Row = 3;
            app.finalPHAS.Layout.Column = 4;

            % Create finalGOLD
            app.finalGOLD = uieditfield(app.layoutResult, 'numeric');
            app.finalGOLD.ValueDisplayFormat = '%.1f';
            app.finalGOLD.Editable = 'off';
            app.finalGOLD.FontSize = 14;
            app.finalGOLD.Layout.Row = 4;
            app.finalGOLD.Layout.Column = 4;

            % Create finalKPHR
            app.finalKPHR = uieditfield(app.layoutResult, 'numeric');
            app.finalKPHR.ValueDisplayFormat = '%.1f';
            app.finalKPHR.Editable = 'off';
            app.finalKPHR.FontSize = 14;
            app.finalKPHR.Layout.Row = 5;
            app.finalKPHR.Layout.Column = 4;

            % Create InitialLabel
            app.InitialLabel = uilabel(app.layoutResult);
            app.InitialLabel.HorizontalAlignment = 'center';
            app.InitialLabel.FontSize = 14;
            app.InitialLabel.FontWeight = 'bold';
            app.InitialLabel.Layout.Row = 1;
            app.InitialLabel.Layout.Column = 2;
            app.InitialLabel.Text = 'Initial';

            % Create NewLabel
            app.NewLabel = uilabel(app.layoutResult);
            app.NewLabel.HorizontalAlignment = 'center';
            app.NewLabel.FontSize = 14;
            app.NewLabel.FontWeight = 'bold';
            app.NewLabel.Layout.Row = 1;
            app.NewLabel.Layout.Column = 4;
            app.NewLabel.Text = 'New';

            % Create updateInitButton
            app.updateInitButton = uibutton(app.layoutResult, 'push');
            app.updateInitButton.ButtonPushedFcn = createCallbackFcn(app, @updateInitButtonPushed, true);
            app.updateInitButton.FontSize = 14;
            app.updateInitButton.Layout.Row = 6;
            app.updateInitButton.Layout.Column = 2;
            app.updateInitButton.Text = 'Update';

            % Create CurrentLabel
            app.CurrentLabel = uilabel(app.layoutResult);
            app.CurrentLabel.HorizontalAlignment = 'center';
            app.CurrentLabel.FontSize = 14;
            app.CurrentLabel.FontWeight = 'bold';
            app.CurrentLabel.Layout.Row = 1;
            app.CurrentLabel.Layout.Column = 3;
            app.CurrentLabel.Text = 'Current';

            % Create currentPDES
            app.currentPDES = uieditfield(app.layoutResult, 'numeric');
            app.currentPDES.ValueDisplayFormat = '%.1f';
            app.currentPDES.Editable = 'off';
            app.currentPDES.FontSize = 14;
            app.currentPDES.Layout.Row = 2;
            app.currentPDES.Layout.Column = 3;

            % Create currentPHAS
            app.currentPHAS = uieditfield(app.layoutResult, 'numeric');
            app.currentPHAS.ValueDisplayFormat = '%.1f';
            app.currentPHAS.Editable = 'off';
            app.currentPHAS.FontSize = 14;
            app.currentPHAS.Layout.Row = 3;
            app.currentPHAS.Layout.Column = 3;

            % Create currentGOLD
            app.currentGOLD = uieditfield(app.layoutResult, 'numeric');
            app.currentGOLD.ValueDisplayFormat = '%.1f';
            app.currentGOLD.Editable = 'off';
            app.currentGOLD.FontSize = 14;
            app.currentGOLD.Layout.Row = 4;
            app.currentGOLD.Layout.Column = 3;

            % Create currentKPHR
            app.currentKPHR = uieditfield(app.layoutResult, 'numeric');
            app.currentKPHR.ValueDisplayFormat = '%.1f';
            app.currentKPHR.Editable = 'off';
            app.currentKPHR.FontSize = 14;
            app.currentKPHR.Layout.Row = 5;
            app.currentKPHR.Layout.Column = 3;

            % Create updateCurrentButton
            app.updateCurrentButton = uibutton(app.layoutResult, 'push');
            app.updateCurrentButton.ButtonPushedFcn = createCallbackFcn(app, @updateCurrentButtonPushed, true);
            app.updateCurrentButton.FontSize = 14;
            app.updateCurrentButton.Layout.Row = 6;
            app.updateCurrentButton.Layout.Column = 3;
            app.updateCurrentButton.Text = 'Update';

            % Create Panel
            app.Panel = uipanel(app.UIFigure);
            app.Panel.Position = [21 391 341 120];

            % Create selectLinac
            app.selectLinac = uidropdown(app.Panel);
            app.selectLinac.Items = {'L0', 'L1', 'L2', 'L3'};
            app.selectLinac.ValueChangedFcn = createCallbackFcn(app, @selectLinacValueChanged, true);
            app.selectLinac.FontSize = 14;
            app.selectLinac.FontWeight = 'bold';
            app.selectLinac.Position = [39 86 49 23];
            app.selectLinac.Value = 'L1';

            % Create KlystronLabel
            app.KlystronLabel = uilabel(app.Panel);
            app.KlystronLabel.HorizontalAlignment = 'right';
            app.KlystronLabel.FontSize = 14;
            app.KlystronLabel.FontWeight = 'bold';
            app.KlystronLabel.Position = [119 87 71 23];
            app.KlystronLabel.Text = {'Klystron: '; ''};

            % Create selectSector
            app.selectSector = uidropdown(app.Panel);
            app.selectSector.Items = {'11'};
            app.selectSector.ValueChangedFcn = createCallbackFcn(app, @selectSectorValueChanged, true);
            app.selectSector.FontSize = 14;
            app.selectSector.Position = [190 86 50 23];
            app.selectSector.Value = '11';

            % Create selectKlys
            app.selectKlys = uidropdown(app.Panel);
            app.selectKlys.Items = {'1', '2'};
            app.selectKlys.ValueChangedFcn = createCallbackFcn(app, @selectKlysValueChanged, true);
            app.selectKlys.FontSize = 14;
            app.selectKlys.Position = [243 86 40 23];
            app.selectKlys.Value = '1';

            % Create klysActiveLamp
            app.klysActiveLamp = uilamp(app.Panel);
            app.klysActiveLamp.Position = [295 86 22.9333333333333 22.9333333333333];

            % Create EEditFieldLabel
            app.EEditFieldLabel = uilabel(app.Panel);
            app.EEditFieldLabel.HorizontalAlignment = 'right';
            app.EEditFieldLabel.FontSize = 14;
            app.EEditFieldLabel.FontAngle = 'italic';
            app.EEditFieldLabel.Position = [11 47 27 22];
            app.EEditFieldLabel.Text = 'E =';

            % Create beamEnergy
            app.beamEnergy = uieditfield(app.Panel, 'numeric');
            app.beamEnergy.ValueDisplayFormat = '%.0f';
            app.beamEnergy.Editable = 'off';
            app.beamEnergy.FontSize = 14;
            app.beamEnergy.Position = [40 47 48 22];
            app.beamEnergy.Value = 10000;

            % Create MeVLabel
            app.MeVLabel = uilabel(app.Panel);
            app.MeVLabel.FontSize = 14;
            app.MeVLabel.Position = [91 47 34 22];
            app.MeVLabel.Text = 'MeV';

            % Create QEditFieldLabel
            app.QEditFieldLabel = uilabel(app.Panel);
            app.QEditFieldLabel.HorizontalAlignment = 'right';
            app.QEditFieldLabel.FontSize = 14;
            app.QEditFieldLabel.FontAngle = 'italic';
            app.QEditFieldLabel.Position = [131 17 28 22];
            app.QEditFieldLabel.Text = 'Q =';

            % Create bunchCharge
            app.bunchCharge = uieditfield(app.Panel, 'numeric');
            app.bunchCharge.ValueDisplayFormat = '%.0f';
            app.bunchCharge.Editable = 'off';
            app.bunchCharge.FontSize = 14;
            app.bunchCharge.Position = [162 17 48 22];
            app.bunchCharge.Value = 2000;

            % Create pCLabel
            app.pCLabel = uilabel(app.Panel);
            app.pCLabel.HorizontalAlignment = 'center';
            app.pCLabel.FontSize = 14;
            app.pCLabel.Position = [211 17 25 22];
            app.pCLabel.Text = 'pC';

            % Create specBPM
            app.specBPM = uieditfield(app.Panel, 'text');
            app.specBPM.Editable = 'off';
            app.specBPM.FontSize = 14;
            app.specBPM.Position = [171 46 155 22];
            app.specBPM.Value = 'BPMS:LI11:333:X';

            % Create EditFieldLabel
            app.EditFieldLabel = uilabel(app.Panel);
            app.EditFieldLabel.HorizontalAlignment = 'right';
            app.EditFieldLabel.FontSize = 14;
            app.EditFieldLabel.FontAngle = 'italic';
            app.EditFieldLabel.Position = [11 17 25 22];
            app.EditFieldLabel.Text = 'ÿ =';

            % Create bpmDispersion
            app.bpmDispersion = uieditfield(app.Panel, 'numeric');
            app.bpmDispersion.ValueDisplayFormat = '%.0f';
            app.bpmDispersion.Editable = 'off';
            app.bpmDispersion.FontSize = 14;
            app.bpmDispersion.Position = [40 17 48 22];
            app.bpmDispersion.Value = 1000;

            % Create mmLabel
            app.mmLabel = uilabel(app.Panel);
            app.mmLabel.FontSize = 14;
            app.mmLabel.Position = [91 17 29 22];
            app.mmLabel.Text = 'mm';

            % Create fEditFieldLabel
            app.fEditFieldLabel = uilabel(app.Panel);
            app.fEditFieldLabel.HorizontalAlignment = 'right';
            app.fEditFieldLabel.FontSize = 14;
            app.fEditFieldLabel.FontAngle = 'italic';
            app.fEditFieldLabel.Position = [243 17 25 22];
            app.fEditFieldLabel.Text = 'f =';

            % Create beamRate
            app.beamRate = uieditfield(app.Panel, 'numeric');
            app.beamRate.ValueDisplayFormat = '%.0f';
            app.beamRate.Editable = 'off';
            app.beamRate.FontSize = 14;
            app.beamRate.Position = [271 17 30 22];
            app.beamRate.Value = 30;

            % Create HzLabel
            app.HzLabel = uilabel(app.Panel);
            app.HzLabel.HorizontalAlignment = 'center';
            app.HzLabel.FontSize = 14;
            app.HzLabel.Position = [301 16 25 22];
            app.HzLabel.Text = 'Hz';

            % Create BPMLabel
            app.BPMLabel = uilabel(app.Panel);
            app.BPMLabel.HorizontalAlignment = 'center';
            app.BPMLabel.FontSize = 14;
            app.BPMLabel.Position = [131 46 40 22];
            app.BPMLabel.Text = 'BPM:';

            % Create Panel_2
            app.Panel_2 = uipanel(app.UIFigure);
            app.Panel_2.Position = [381 571 547 30];

            % Create message
            app.message = uilabel(app.Panel_2);
            app.message.BackgroundColor = [0.9804 0.9804 0.9804];
            app.message.FontSize = 16;
            app.message.FontColor = [0 0 1];
            app.message.Position = [71 1 473 28];
            app.message.Text = 'Hello there!';

            % Create StatusLabel
            app.StatusLabel = uilabel(app.Panel_2);
            app.StatusLabel.FontSize = 16;
            app.StatusLabel.FontWeight = 'bold';
            app.StatusLabel.Position = [11 1 60 28];
            app.StatusLabel.Text = 'Status:';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_phasing_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end