 status
 classdef F2_phasing_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        FACETIIRFPhaseScansUIFigure  matlab.ui.Figure
        banner                       matlab.ui.control.Label
        ax                           matlab.ui.control.UIAxes
        mainControlPanel             matlab.ui.container.Panel
        layoutControl                matlab.ui.container.GridLayout
        scanButton                   matlab.ui.control.Button
        undoButton                   matlab.ui.control.Button
        applyButton                  matlab.ui.control.Button
        logbookButton                matlab.ui.control.Button
        helpButton                   matlab.ui.control.Button
        abortButton                  matlab.ui.control.StateButton
        ScanConfigurationPanel       matlab.ui.container.Panel
        layoutConfig                 matlab.ui.container.GridLayout
        NstepsEditFieldLabel         matlab.ui.control.Label
        editNSteps                   matlab.ui.control.NumericEditField
        rangeEditFieldLabel          matlab.ui.control.Label
        editRange                    matlab.ui.control.NumericEditField
        KlysoffsetLabel              matlab.ui.control.Label
        editOffset                   matlab.ui.control.NumericEditField
        NsamplesEditFieldLabel       matlab.ui.control.Label
        editNSamples                 matlab.ui.control.NumericEditField
        selectZigzag                 matlab.ui.control.CheckBox
        SBSToffsetLabel              matlab.ui.control.Label
        editSBOffset                 matlab.ui.control.NumericEditField
        selectSim                    matlab.ui.control.CheckBox
        resultPanel                  matlab.ui.container.Panel
        layoutResult                 matlab.ui.container.GridLayout
        ControlPhaseLabel            matlab.ui.control.Label
        initPDES                     matlab.ui.control.NumericEditField
        ReadbackPhaseLabel           matlab.ui.control.Label
        initPACT                     matlab.ui.control.NumericEditField
        PhaseOffsetControlLabel      matlab.ui.control.Label
        initPOC                      matlab.ui.control.NumericEditField
        finalPDES                    matlab.ui.control.NumericEditField
        finalPACT                    matlab.ui.control.NumericEditField
        finalPOC                     matlab.ui.control.NumericEditField
        NewLabel                     matlab.ui.control.Label
        CurrentLabel                 matlab.ui.control.Label
        currentPDES                  matlab.ui.control.NumericEditField
        currentPACT                  matlab.ui.control.NumericEditField
        currentPOC                   matlab.ui.control.NumericEditField
        updateCurrentButton          matlab.ui.control.Button
        InitialLabel                 matlab.ui.control.Label
        selectPanel                  matlab.ui.container.Panel
        selectLinac                  matlab.ui.control.DropDown
        KlystronLabel                matlab.ui.control.Label
        selectSector                 matlab.ui.control.DropDown
        selectKlys                   matlab.ui.control.DropDown
        klysActiveLamp               matlab.ui.control.Lamp
        EEditFieldLabel              matlab.ui.control.Label
        beamEnergy                   matlab.ui.control.NumericEditField
        MeVLabel                     matlab.ui.control.Label
        QEditFieldLabel              matlab.ui.control.Label
        bunchCharge                  matlab.ui.control.NumericEditField
        pCLabel                      matlab.ui.control.Label
        specBPM                      matlab.ui.control.EditField
        EditFieldLabel               matlab.ui.control.Label
        bpmDispersion                matlab.ui.control.NumericEditField
        mmLabel                      matlab.ui.control.Label
        fEditFieldLabel              matlab.ui.control.Label
        beamRate                     matlab.ui.control.NumericEditField
        HzLabel                      matlab.ui.control.Label
        BPMLabel                     matlab.ui.control.Label
        messagePanel                 matlab.ui.container.Panel
        message                      matlab.ui.control.Label
        StatusLabel                  matlab.ui.control.Label
        doom1                        matlab.ui.control.Image
        doom2                        matlab.ui.control.Image
        doom3                        matlab.ui.control.Image
        axTMIT                       matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        S F2_phasescan % scan controller
        scan_ready = false;
        images;
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
        end

        % get klystron status to determine if station is on beam
        function update_klys_stat(app)
            app.klysActiveLamp.Color = [0.3 0.3 0.3];
            
            % enable scan button and set active light green for stations on
            % beam, otherwise leave scan button disabled and set the light
            % to black or red if the station is off-beam or MNT/TBR/ARU
            lamp_color = [0.3 0.3 0.3];
            app.scan_ready = false;
            
            if app.S.klys_stat == 1
                lamp_color = [0.0 1.0 0.0];
                msg = 'Ready to scan %s.';
                app.scan_ready = true;
            elseif app.S.klys_stat == 2
                msg = '%s is not triggering on accelerate time.';
            elseif app.S.klys_stat == 3
                lamp_color = [1.0 0.0 0.0];
                msg = '%s is offline (OFF/MNT/TBR/ARU).';
            end
            
            app.klysActiveLamp.Color = lamp_color;
            app.message.Text = sprintf(msg, app.S.klys_str);
        end
        
        % get current klystron PDES, PHAS, GOLD & KPHR
        function update_klys_phase_params(app, initial)
            [PDES, PACT, offset] = app.S.get_phase_settings();
            if initial
                app.initPDES.Value = PDES;
                app.initPACT.Value = PACT;
                app.initPOC.Value = offset;
                app.S.in.PDES = PDES;
                app.S.in.PACT = PACT;
                app.S.in.POC = offset;
            else
                app.currentPDES.Value = PDES;
                app.currentPACT.Value = PACT;
                app.currentPOC.Value = offset;
            end
        end
        
        function label_phase_settings(app)
            % label phase setting tooltips
            [s_ctl, s_rbv, s_offs] = app.S.get_phase_setting_desc();
            app.ControlPhaseLabel.Tooltip = {s_ctl};
            app.ReadbackPhaseLabel.Tooltip = {s_rbv};
            app.PhaseOffsetControlLabel.Tooltip = {s_offs};
        end
        
        % helper to update chrge, rate energy in one line
        function update_operating_point(app)
            app.update_klys_phase_params(true);
            app.update_klys_phase_params(false);
            app.bunchCharge.Value   = app.S.beam.Q;
            app.beamRate.Value      = app.S.beam.f;
            app.beamEnergy.Value    = app.S.beam.E_design;
            app.specBPM.Value       = app.S.BPM;
            app.bpmDispersion.Value = app.S.eta;
        end
        
        % populate app.S.in struct from GUI
        function get_scan_inputs(app)
            app.S.dPhi = app.editRange.Value;
            app.S.N_steps = app.editNSteps.Value;
            app.S.N_samples = app.editNSamples.Value;
            app.S.zigzag = app.selectZigzag.Value;
            app.S.simulation = app.selectSim.Value;  
        end
        
        % generate final phase scan plot for logbook
        function fig = make_plot(app)
            fig = figure('position',[500,500,640,480]);
            axis = axes;
            axis.FontSize = 12;
            app.S.plot_phase_scan(axis, true);
            shg;
        end
 
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.S = F2_phasescan(1,11,1);
            
            app.images = [app.doom1 app.doom2 app.doom3];
            
            app.update_klys_stat();
            app.update_operating_point();
            app.label_phase_settings();
            app.get_scan_inputs();
            %app.editOffset.Value = -1 * app.S.in.phi_set;
            
            % clear & re-label plot axes
            app.S.label_plot(app.ax);
            
            app.S.GUI_attached = true;
            app.S.GUI_ax = app.ax;
            app.S.GUI_axTMIT = app.axTMIT;
            app.S.GUI_abortButton = app.abortButton;
            app.S.GUI_message = app.message;
            
            disableDefaultInteractivity(app.ax);
        end

        % Value changed function: selectLinac
        function selectLinacValueChanged(app, event)
            app.S.linac = uint8(str2double(app.selectLinac.Value(end)));
            
            % update list of sectors, default target: 1st sector
            app.selectSector.Items = string(app.S.sector_map);
            app.selectSector.Value = string(app.S.sector);
            app.editRange.Value = app.S.dPhi;
            app.editNSteps.Value = app.S.N_steps;
            app.selectSectorValueChanged(event);
        end

        % Value changed function: selectSector
        function selectSectorValueChanged(app, event)
            app.S.sector = uint8(str2double(app.selectSector.Value));
            
            % update klys list, default target: 1st klys
            app.selectKlys.Items = string(app.S.klys_map);
            app.selectKlys.Value = string(app.S.klys);
            
            % for L2-3 subbooster PDES, populate sbst offset accordingly
            app.editRange.Value = app.S.dPhi;
            app.editNSteps.Value = app.S.N_steps;
            app.editNSamples.Value = app.S.N_samples;
            app.editSBOffset.Value = 0;
            app.editSBOffset.Enable = false;
            app.SBSToffsetLabel.Enable = false;
            if app.S.linac >= 2 
                app.editSBOffset.Enable = true;
                app.SBSToffsetLabel.Enable = true;
                app.editSBOffset.Value = app.S.sbst_offset;
            end
            
            app.selectKlysValueChanged(event);
        end

        % Value changed function: selectKlys
        function selectKlysValueChanged(app, event)
            app.enable_controls(false); 
            app.message.Text = 'Checking klystron status ...'; drawnow;

            app.S.klys = uint8(str2double(app.selectKlys.Value));
            app.scanButton.Text = sprintf('Scan %s', app.S.klys_str);
            
            % once user selects a klystron check if it is on beam time
            % and grab it's current phase settings
            app.update_klys_stat();
            app.update_klys_phase_params(true);
 
            % initialize scan object in case there isn't one already held
            % TO DO: is this when to prompt user before old scan deletion ??
            app.get_scan_inputs();
                       
            app.editOffset.Value = app.S.klys_offset;
            
            % label phase setting tooltips
            [s_ctl, s_rbv, s_offs] = app.S.get_phase_setting_desc();
            app.ControlPhaseLabel.Tooltip = {s_ctl};
            app.ReadbackPhaseLabel.Tooltip = {s_rbv};
            app.PhaseOffsetControlLabel.Tooltip = {s_offs};
            
            app.update_operating_point();
            
            yyaxis(app.ax,'left');
            cla(app.ax);
            yyaxis(app.ax,'right');
            cla(app.ax);
            cla(app.axTMIT);
            app.S.label_plot(app.ax);
            
            app.enable_controls(true);
            
            % disable undo/gold/logbook buttons
            app.scanButton.Enable = app.scan_ready;
            app.abortButton.Enable = false;
            app.undoButton.Enable = false;
            app.applyButton.Enable = false;
            app.logbookButton.Enable = false;
            
            % kill easter eggs
            app.doom1.Visible = false;
            app.doom2.Visible = false;
            app.doom3.Visible = false;
        end

        % Button pushed function: scanButton
        function scanButtonPushed(app, event)
            app.enable_controls(false); drawnow;
            app.abortButton.Enable = true;
            app.helpButton.Enable = true;
            app.scanButton.Text = 'Scanning...';

            % grab the latest phase settings & config settings from the GUI
            app.update_klys_phase_params(true);
            app.get_scan_inputs();
        
            yyaxis(app.ax,'left');
            cla(app.ax);
            yyaxis(app.ax,'right');
            cla(app.ax);
            cla(app.axTMIT);
                        
            % run the scan!
            try
                app.S.phase_scan();
            catch E
                app.message.Text = 'Scan failed due to Matab runtime error';
                fprintf('Error: %s\n%s\n', E.identifier, E.message);
                app.S.success = false;
                app.S.scan_aborted = true;
            end

            % if the scan was aborted revert phase settings
            if app.S.scan_aborted
                app.message.Text = 'Restoring initial phase settings ...';
                app.S.revert_phase_settings();
                app.S.scan_aborted = false;
                app.update_klys_phase_params(false);
                app.message.Text = sprintf('%s scan aborted.', app.S.klys_str);
            end
            
            % roll dice
            img = app.images(randi(3));
            if rand < 0.05, img.Visible = true; end
            
            % write proposed phase settings to "new" boxes
            if app.S.success
                app.message.Text = 'Scan completed. Press "Apply" to correct phase error.';
                app.finalPOC.Value = app.S.out.POC;
            end
            
            app.enable_controls(true);
            app.scanButton.Enable = true;
            app.scanButton.Text = sprintf('Scan %s', app.S.klys_str);
            app.abortButton.Enable = false;
            app.undoButton.Enable = true;
            app.applyButton.Enable = app.S.success;
            app.logbookButton.Enable = app.S.success;
        end

        % Button pushed function: applyButton
        function applyButtonPushed(app, event)
            app.message.Text = 'Applying phase correction ...';
            app.enable_controls(false);
            if abs(app.S.fit.phi_err) > 20.0
                resp = questdlg('Large (>20deg) phase change. Set measured zero phase?');
                if ~strcmp(resp, 'Yes')
                    app.message.Text = 'Phase correction declined.';
                    app.enable_controls(true);
                    app.abortButton.Enable = false;
                    return
                end
            end
            
            app.S.apply_phase_correction();
            
            app.finalPDES.Value = app.S.out.PDES;
            app.finalPACT.Value = app.S.out.PACT;
            app.finalPOC.Value = app.S.out.POC;
            
            app.update_klys_phase_params(false);
            app.enable_controls(true);
            app.abortButton.Enable = false;
            app.message.Text = 'Phase correction applied.';
        end

        % Button pushed function: logbookButton
        function logbookButtonPushed(app, event)
            fig = app.make_plot();
            opts.author = 'FACET-II Phase Scan GUI';
            opts.title = app.S.scan_name;
            opts.text = app.S.scan_summary;
            util_printLog(fig, opts);
            app.message.Text = 'Sent to fphysics elog.';
        end

        % Value changed function: abortButton
        function abortButtonPushed(app, event)
            app.message.Text = 'SCAN ABORT REQUESTED. Waiting for interrupt...';
        end

        % Button pushed function: undoButton
        function undoButtonPushed(app, event)
            app.message.Text = 'Restoring initial phase settings ...';
            app.S.revert_phase_settings();
            app.update_klys_phase_params(false);
            app.message.Text = sprintf('%s phase settings restored.', app.S.klys_str);
        end

        % Button pushed function: helpButton
        function helpButtonPushed(app, event)
            prev_msg = app.message.Text;
            app.message.Text = 'Opening MCC wiki ...';
            system("firefox https://aosd.slac.stanford.edu/wiki/index.php/FACET-II_Phase_Scan_GUI &");
            pause(3)
            app.message.Text = prev_msg;
        end

        % Button pushed function: updateCurrentButton
        function updateCurrentButtonPushed(app, event)
            app.update_klys_phase_params(false);
        end

        % Value changed function: editRange
        function editRangeValueChanged(app, event)
            app.S.dPhi =  app.editRange.Value;
        end

        % Value changed function: editNSteps
        function editNStepsValueChanged(app, event)
            app.S.N_steps = app.editNSteps.Value;
        end

        % Value changed function: selectZigzag
        function selectZigzagValueChanged(app, event)
            app.S.zigzag = app.selectZigzag.Value;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create FACETIIRFPhaseScansUIFigure and hide until all components are created
            app.FACETIIRFPhaseScansUIFigure = uifigure('Visible', 'off');
            app.FACETIIRFPhaseScansUIFigure.Position = [100 100 1000 580];
            app.FACETIIRFPhaseScansUIFigure.Name = 'FACET-II RF Phase Scans';
            app.FACETIIRFPhaseScansUIFigure.Resize = 'off';

            % Create banner
            app.banner = uilabel(app.FACETIIRFPhaseScansUIFigure);
            app.banner.BackgroundColor = [1 0.5843 0.2353];
            app.banner.Position = [1 571 1000 10];
            app.banner.Text = {''; ''};

            % Create ax
            app.ax = uiaxes(app.FACETIIRFPhaseScansUIFigure);
            title(app.ax, 'Title')
            xlabel(app.ax, '\phi')
            ylabel(app.ax, {'\Delta x (BPMS:LI11:333:X)'; ''})
            app.ax.XGrid = 'on';
            app.ax.YGrid = 'on';
            app.ax.Position = [361 127 619 394];

            % Create mainControlPanel
            app.mainControlPanel = uipanel(app.FACETIIRFPhaseScansUIFigure);
            app.mainControlPanel.Position = [11 351 340 80];

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

            % Create abortButton
            app.abortButton = uibutton(app.layoutControl, 'state');
            app.abortButton.ValueChangedFcn = createCallbackFcn(app, @abortButtonPushed, true);
            app.abortButton.Enable = 'off';
            app.abortButton.Text = 'Abort';
            app.abortButton.BackgroundColor = [1 0 0];
            app.abortButton.FontSize = 16;
            app.abortButton.FontWeight = 'bold';
            app.abortButton.FontColor = [1 1 1];
            app.abortButton.Layout.Row = 2;
            app.abortButton.Layout.Column = 1;

            % Create ScanConfigurationPanel
            app.ScanConfigurationPanel = uipanel(app.FACETIIRFPhaseScansUIFigure);
            app.ScanConfigurationPanel.Title = 'Scan Configuration';
            app.ScanConfigurationPanel.FontWeight = 'bold';
            app.ScanConfigurationPanel.FontSize = 16;
            app.ScanConfigurationPanel.Position = [11 196 340 145];

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
            app.editNSteps.ValueChangedFcn = createCallbackFcn(app, @editNStepsValueChanged, true);
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
            app.editRange.ValueChangedFcn = createCallbackFcn(app, @editRangeValueChanged, true);
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
            app.selectZigzag.ValueChangedFcn = createCallbackFcn(app, @selectZigzagValueChanged, true);
            app.selectZigzag.Text = 'Zigzag';
            app.selectZigzag.FontSize = 14;
            app.selectZigzag.Layout.Row = 3;
            app.selectZigzag.Layout.Column = [7 9];

            % Create SBSToffsetLabel
            app.SBSToffsetLabel = uilabel(app.layoutConfig);
            app.SBSToffsetLabel.HorizontalAlignment = 'right';
            app.SBSToffsetLabel.FontSize = 14;
            app.SBSToffsetLabel.Enable = 'off';
            app.SBSToffsetLabel.Layout.Row = 1;
            app.SBSToffsetLabel.Layout.Column = [7 9];
            app.SBSToffsetLabel.Text = 'SBST offset';

            % Create editSBOffset
            app.editSBOffset = uieditfield(app.layoutConfig, 'numeric');
            app.editSBOffset.Editable = 'off';
            app.editSBOffset.FontSize = 14;
            app.editSBOffset.Enable = 'off';
            app.editSBOffset.Layout.Row = 1;
            app.editSBOffset.Layout.Column = [10 11];

            % Create selectSim
            app.selectSim = uicheckbox(app.layoutConfig);
            app.selectSim.Text = 'Simulated scan';
            app.selectSim.FontSize = 14;
            app.selectSim.Layout.Row = 4;
            app.selectSim.Layout.Column = [7 11];

            % Create resultPanel
            app.resultPanel = uipanel(app.FACETIIRFPhaseScansUIFigure);
            app.resultPanel.Title = 'Phase Control Settings';
            app.resultPanel.FontWeight = 'bold';
            app.resultPanel.FontSize = 16;
            app.resultPanel.Position = [11 11 341 170];

            % Create layoutResult
            app.layoutResult = uigridlayout(app.resultPanel);
            app.layoutResult.ColumnWidth = {130, '1x', '1x', '1x', '0.2x'};
            app.layoutResult.RowHeight = {'1x', '1x', '1x', '1x', '1x'};
            app.layoutResult.ColumnSpacing = 5;
            app.layoutResult.RowSpacing = 5;
            app.layoutResult.Padding = [4 4 4 4];

            % Create ControlPhaseLabel
            app.ControlPhaseLabel = uilabel(app.layoutResult);
            app.ControlPhaseLabel.HorizontalAlignment = 'right';
            app.ControlPhaseLabel.FontSize = 14;
            app.ControlPhaseLabel.Tooltip = {'PVNAME HERE'};
            app.ControlPhaseLabel.Layout.Row = 2;
            app.ControlPhaseLabel.Layout.Column = 1;
            app.ControlPhaseLabel.Text = 'Control Phase';

            % Create initPDES
            app.initPDES = uieditfield(app.layoutResult, 'numeric');
            app.initPDES.ValueDisplayFormat = '%.1f';
            app.initPDES.Editable = 'off';
            app.initPDES.FontSize = 14;
            app.initPDES.Layout.Row = 2;
            app.initPDES.Layout.Column = 2;

            % Create ReadbackPhaseLabel
            app.ReadbackPhaseLabel = uilabel(app.layoutResult);
            app.ReadbackPhaseLabel.HorizontalAlignment = 'right';
            app.ReadbackPhaseLabel.FontSize = 14;
            app.ReadbackPhaseLabel.Tooltip = {'PVNAME HERE'; ''};
            app.ReadbackPhaseLabel.Layout.Row = 3;
            app.ReadbackPhaseLabel.Layout.Column = 1;
            app.ReadbackPhaseLabel.Text = 'Readback Phase';

            % Create initPACT
            app.initPACT = uieditfield(app.layoutResult, 'numeric');
            app.initPACT.ValueDisplayFormat = '%.1f';
            app.initPACT.Editable = 'off';
            app.initPACT.FontSize = 14;
            app.initPACT.Layout.Row = 3;
            app.initPACT.Layout.Column = 2;

            % Create PhaseOffsetControlLabel
            app.PhaseOffsetControlLabel = uilabel(app.layoutResult);
            app.PhaseOffsetControlLabel.HorizontalAlignment = 'right';
            app.PhaseOffsetControlLabel.FontSize = 14;
            app.PhaseOffsetControlLabel.Tooltip = {'PVNAME HERE'; ''};
            app.PhaseOffsetControlLabel.Layout.Row = 4;
            app.PhaseOffsetControlLabel.Layout.Column = 1;
            app.PhaseOffsetControlLabel.Text = 'Phase Offset Control';

            % Create initPOC
            app.initPOC = uieditfield(app.layoutResult, 'numeric');
            app.initPOC.ValueDisplayFormat = '%.1f';
            app.initPOC.Editable = 'off';
            app.initPOC.FontSize = 14;
            app.initPOC.Layout.Row = 4;
            app.initPOC.Layout.Column = 2;

            % Create finalPDES
            app.finalPDES = uieditfield(app.layoutResult, 'numeric');
            app.finalPDES.ValueDisplayFormat = '%.1f';
            app.finalPDES.Editable = 'off';
            app.finalPDES.FontSize = 14;
            app.finalPDES.Layout.Row = 2;
            app.finalPDES.Layout.Column = 4;

            % Create finalPACT
            app.finalPACT = uieditfield(app.layoutResult, 'numeric');
            app.finalPACT.ValueDisplayFormat = '%.1f';
            app.finalPACT.Editable = 'off';
            app.finalPACT.FontSize = 14;
            app.finalPACT.Layout.Row = 3;
            app.finalPACT.Layout.Column = 4;

            % Create finalPOC
            app.finalPOC = uieditfield(app.layoutResult, 'numeric');
            app.finalPOC.ValueDisplayFormat = '%.1f';
            app.finalPOC.Editable = 'off';
            app.finalPOC.FontSize = 14;
            app.finalPOC.Layout.Row = 4;
            app.finalPOC.Layout.Column = 4;

            % Create NewLabel
            app.NewLabel = uilabel(app.layoutResult);
            app.NewLabel.HorizontalAlignment = 'center';
            app.NewLabel.FontSize = 14;
            app.NewLabel.FontWeight = 'bold';
            app.NewLabel.Layout.Row = 1;
            app.NewLabel.Layout.Column = 4;
            app.NewLabel.Text = 'New';

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

            % Create currentPACT
            app.currentPACT = uieditfield(app.layoutResult, 'numeric');
            app.currentPACT.ValueDisplayFormat = '%.1f';
            app.currentPACT.Editable = 'off';
            app.currentPACT.FontSize = 14;
            app.currentPACT.Layout.Row = 3;
            app.currentPACT.Layout.Column = 3;

            % Create currentPOC
            app.currentPOC = uieditfield(app.layoutResult, 'numeric');
            app.currentPOC.ValueDisplayFormat = '%.1f';
            app.currentPOC.Editable = 'off';
            app.currentPOC.FontSize = 14;
            app.currentPOC.Layout.Row = 4;
            app.currentPOC.Layout.Column = 3;

            % Create updateCurrentButton
            app.updateCurrentButton = uibutton(app.layoutResult, 'push');
            app.updateCurrentButton.ButtonPushedFcn = createCallbackFcn(app, @updateCurrentButtonPushed, true);
            app.updateCurrentButton.FontSize = 14;
            app.updateCurrentButton.Layout.Row = 5;
            app.updateCurrentButton.Layout.Column = 3;
            app.updateCurrentButton.Text = 'Update';

            % Create InitialLabel
            app.InitialLabel = uilabel(app.layoutResult);
            app.InitialLabel.HorizontalAlignment = 'center';
            app.InitialLabel.FontSize = 14;
            app.InitialLabel.FontWeight = 'bold';
            app.InitialLabel.Layout.Row = 1;
            app.InitialLabel.Layout.Column = 2;
            app.InitialLabel.Text = 'Initial';

            % Create selectPanel
            app.selectPanel = uipanel(app.FACETIIRFPhaseScansUIFigure);
            app.selectPanel.Position = [11 441 341 120];

            % Create selectLinac
            app.selectLinac = uidropdown(app.selectPanel);
            app.selectLinac.Items = {'L0', 'L1', 'L2', 'L3'};
            app.selectLinac.ValueChangedFcn = createCallbackFcn(app, @selectLinacValueChanged, true);
            app.selectLinac.FontSize = 14;
            app.selectLinac.FontWeight = 'bold';
            app.selectLinac.Position = [39 86 49 23];
            app.selectLinac.Value = 'L1';

            % Create KlystronLabel
            app.KlystronLabel = uilabel(app.selectPanel);
            app.KlystronLabel.HorizontalAlignment = 'right';
            app.KlystronLabel.FontSize = 14;
            app.KlystronLabel.FontWeight = 'bold';
            app.KlystronLabel.Position = [119 87 71 23];
            app.KlystronLabel.Text = {'Klystron: '; ''};

            % Create selectSector
            app.selectSector = uidropdown(app.selectPanel);
            app.selectSector.Items = {'11'};
            app.selectSector.ValueChangedFcn = createCallbackFcn(app, @selectSectorValueChanged, true);
            app.selectSector.FontSize = 14;
            app.selectSector.Position = [190 86 50 23];
            app.selectSector.Value = '11';

            % Create selectKlys
            app.selectKlys = uidropdown(app.selectPanel);
            app.selectKlys.Items = {'1', '2'};
            app.selectKlys.ValueChangedFcn = createCallbackFcn(app, @selectKlysValueChanged, true);
            app.selectKlys.FontSize = 14;
            app.selectKlys.Position = [243 86 40 23];
            app.selectKlys.Value = '1';

            % Create klysActiveLamp
            app.klysActiveLamp = uilamp(app.selectPanel);
            app.klysActiveLamp.Position = [295 86 22.9333333333333 22.9333333333333];

            % Create EEditFieldLabel
            app.EEditFieldLabel = uilabel(app.selectPanel);
            app.EEditFieldLabel.HorizontalAlignment = 'right';
            app.EEditFieldLabel.FontSize = 14;
            app.EEditFieldLabel.FontAngle = 'italic';
            app.EEditFieldLabel.Position = [11 47 27 22];
            app.EEditFieldLabel.Text = 'E =';

            % Create beamEnergy
            app.beamEnergy = uieditfield(app.selectPanel, 'numeric');
            app.beamEnergy.ValueDisplayFormat = '%.0f';
            app.beamEnergy.Editable = 'off';
            app.beamEnergy.FontSize = 14;
            app.beamEnergy.Position = [40 47 48 22];
            app.beamEnergy.Value = 10000;

            % Create MeVLabel
            app.MeVLabel = uilabel(app.selectPanel);
            app.MeVLabel.FontSize = 14;
            app.MeVLabel.Position = [91 47 34 22];
            app.MeVLabel.Text = 'MeV';

            % Create QEditFieldLabel
            app.QEditFieldLabel = uilabel(app.selectPanel);
            app.QEditFieldLabel.HorizontalAlignment = 'right';
            app.QEditFieldLabel.FontSize = 14;
            app.QEditFieldLabel.FontAngle = 'italic';
            app.QEditFieldLabel.Position = [131 17 28 22];
            app.QEditFieldLabel.Text = 'Q =';

            % Create bunchCharge
            app.bunchCharge = uieditfield(app.selectPanel, 'numeric');
            app.bunchCharge.ValueDisplayFormat = '%.0f';
            app.bunchCharge.Editable = 'off';
            app.bunchCharge.FontSize = 14;
            app.bunchCharge.Position = [162 17 48 22];
            app.bunchCharge.Value = 2000;

            % Create pCLabel
            app.pCLabel = uilabel(app.selectPanel);
            app.pCLabel.HorizontalAlignment = 'center';
            app.pCLabel.FontSize = 14;
            app.pCLabel.Position = [211 17 25 22];
            app.pCLabel.Text = 'pC';

            % Create specBPM
            app.specBPM = uieditfield(app.selectPanel, 'text');
            app.specBPM.Editable = 'off';
            app.specBPM.FontSize = 14;
            app.specBPM.Position = [171 46 155 22];
            app.specBPM.Value = 'BPMS:LI11:333:X';

            % Create EditFieldLabel
            app.EditFieldLabel = uilabel(app.selectPanel);
            app.EditFieldLabel.HorizontalAlignment = 'right';
            app.EditFieldLabel.FontSize = 14;
            app.EditFieldLabel.FontAngle = 'italic';
            app.EditFieldLabel.Position = [11 17 25 22];
            app.EditFieldLabel.Text = 'ÿ =';

            % Create bpmDispersion
            app.bpmDispersion = uieditfield(app.selectPanel, 'numeric');
            app.bpmDispersion.ValueDisplayFormat = '%.0f';
            app.bpmDispersion.Editable = 'off';
            app.bpmDispersion.FontSize = 14;
            app.bpmDispersion.Position = [40 17 48 22];
            app.bpmDispersion.Value = 1000;

            % Create mmLabel
            app.mmLabel = uilabel(app.selectPanel);
            app.mmLabel.FontSize = 14;
            app.mmLabel.Position = [91 17 29 22];
            app.mmLabel.Text = 'mm';

            % Create fEditFieldLabel
            app.fEditFieldLabel = uilabel(app.selectPanel);
            app.fEditFieldLabel.HorizontalAlignment = 'right';
            app.fEditFieldLabel.FontSize = 14;
            app.fEditFieldLabel.FontAngle = 'italic';
            app.fEditFieldLabel.Position = [243 17 25 22];
            app.fEditFieldLabel.Text = 'f =';

            % Create beamRate
            app.beamRate = uieditfield(app.selectPanel, 'numeric');
            app.beamRate.ValueDisplayFormat = '%.0f';
            app.beamRate.Editable = 'off';
            app.beamRate.FontSize = 14;
            app.beamRate.Position = [271 17 30 22];
            app.beamRate.Value = 30;

            % Create HzLabel
            app.HzLabel = uilabel(app.selectPanel);
            app.HzLabel.HorizontalAlignment = 'center';
            app.HzLabel.FontSize = 14;
            app.HzLabel.Position = [301 16 25 22];
            app.HzLabel.Text = 'Hz';

            % Create BPMLabel
            app.BPMLabel = uilabel(app.selectPanel);
            app.BPMLabel.HorizontalAlignment = 'center';
            app.BPMLabel.FontSize = 14;
            app.BPMLabel.Position = [131 46 40 22];
            app.BPMLabel.Text = 'BPM:';

            % Create messagePanel
            app.messagePanel = uipanel(app.FACETIIRFPhaseScansUIFigure);
            app.messagePanel.Position = [361 531 570 30];

            % Create message
            app.message = uilabel(app.messagePanel);
            app.message.BackgroundColor = [0.9804 0.9804 0.9804];
            app.message.FontSize = 16;
            app.message.FontColor = [0 0 1];
            app.message.Position = [71 1 498 28];
            app.message.Text = 'If you can read this, GUI initialization did not complete...';

            % Create StatusLabel
            app.StatusLabel = uilabel(app.messagePanel);
            app.StatusLabel.FontSize = 16;
            app.StatusLabel.FontWeight = 'bold';
            app.StatusLabel.Position = [11 1 60 28];
            app.StatusLabel.Text = 'Status:';

            % Create doom1
            app.doom1 = uiimage(app.FACETIIRFPhaseScansUIFigure);
            app.doom1.ScaleMethod = 'fill';
            app.doom1.Visible = 'off';
            app.doom1.VerticalAlignment = 'top';
            app.doom1.Position = [715 1 99 91];
            app.doom1.ImageSource = 'doom.png';

            % Create doom2
            app.doom2 = uiimage(app.FACETIIRFPhaseScansUIFigure);
            app.doom2.ScaleMethod = 'fill';
            app.doom2.Visible = 'off';
            app.doom2.VerticalAlignment = 'bottom';
            app.doom2.Position = [891 517 100 54];
            app.doom2.ImageSource = 'doom2.png';

            % Create doom3
            app.doom3 = uiimage(app.FACETIIRFPhaseScansUIFigure);
            app.doom3.ScaleMethod = 'fill';
            app.doom3.Visible = 'off';
            app.doom3.HorizontalAlignment = 'right';
            app.doom3.VerticalAlignment = 'top';
            app.doom3.Position = [12 197 76 61];
            app.doom3.ImageSource = 'doom3.png';

            % Create axTMIT
            app.axTMIT = uiaxes(app.FACETIIRFPhaseScansUIFigure);
            title(app.axTMIT, '')
            xlabel(app.axTMIT, '')
            ylabel(app.axTMIT, 'Q ratio')
            app.axTMIT.YLim = [0 1.2];
            app.axTMIT.YTick = [0.5 1];
            app.axTMIT.YTickLabel = {'0.5'; '1'};
            app.axTMIT.YGrid = 'on';
            app.axTMIT.Position = [361 11 578 114];

            % Show the figure after all components are created
            app.FACETIIRFPhaseScansUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_phasing_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.FACETIIRFPhaseScansUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.FACETIIRFPhaseScansUIFigure)
        end
    end
end