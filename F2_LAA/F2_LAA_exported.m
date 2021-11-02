classdef F2_LAA_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        SelectLaserAlignmentTargetPositionsButtonGroup  matlab.ui.container.ButtonGroup
        OptionsDropDown                 matlab.ui.control.DropDown
        FACETIILaserAutoAlignmentLabel  matlab.ui.control.Label
        LogTextAreaLabel                matlab.ui.control.Label
        LogTextArea                     matlab.ui.control.TextArea
        InitializeReferenceLaserParametersPanel  matlab.ui.container.Panel
        GrabReferencesButton            matlab.ui.control.Button
        ClearReferencesButton           matlab.ui.control.Button
        SelectCamerastoAlignPanel       matlab.ui.container.Panel
        UITable                         matlab.ui.control.Table
        InitiateAutoAlignmentPanel      matlab.ui.container.Panel
        StartAlignmentButton            matlab.ui.control.Button
        PauseAlignmentButton            matlab.ui.control.Button
        StopAlignmentButton             matlab.ui.control.Button
        StatusLampLabel                 matlab.ui.control.Label
        StatusLamp                      matlab.ui.control.Lamp
        IRmodeButton                    matlab.ui.control.Button
        ClearLogButton                  matlab.ui.control.Button
    end

    
    properties (Access = public)
        camerapvs =  {'CAMR:LT20:0001','CAMR:LT20:0002','CAMR:LT20:0003',...
        'CAMR:LT20:0004','CAMR:LT20:0009','CAMR:LT20:0010','CAMR:LT20:0101',...
        'CAMR:LT20:0102','CAMR:LT20:0103','CAMR:LT20:0104','CAMR:LT20:0105',...
        'CAMR:LT20:0106','CAMR:LT20:0107'};% S20 Camera PVs
            
        motorpvs = {'MOTR:LI20:MC06:S3','MOTR:LI20:MC06:M0',...
        'MOTR:LI20:MC06:S4','MOTR:LI20:MC06:S5','MOTR:LI20:MC07:M0',...
        'MOTR:LI20:MC07:S1','MOTR:LI20:MC08:M0','MOTR:LI20:MC08:S2'};%S20 Motor PVs
        
        feedbackOnPVs = {'SIOC:SYS1:ML01:AO170','SIOC:SYS1:ML01:AO171',...
        'SIOC:SYS1:ML01:AO173','SIOC:SYS1:ML01:AO174','SIOC:SYS1:ML01:AO175',...
        'SIOC:SYS1:ML01:AO176','SIOC:SYS1:ML01:AO177','SIOC:SYS1:ML01:AO178'};%Matlab helper PVs for toggling alignment on/off
        
        feedbackExitPV = 'SIOC:SYS1:ML01:AO169';
        feedbackPausePV = 'SIOC:SYS1:ML01:AO179';
        
        sectionNames = {'Pulse Picker and Regen Out','Preamp Near and Far',...
            'HeNe Near and Far','B0 and B1','B2 and B3','B4','B5','B6'}
        fitMethod = 2;% Centroid fit method for profmon_process
        umPerPixel ;
        setPointOption = 1;% 2 = Set desired centroid setpoint from current position, 1 uses pre-defined target position
        feedbackOn = logical([0,0,0,0,0,0,0,0]);
        k_p = [0.1,0.1,0.2,0.05,0.2,0.2,0.2,0.2];% Default Proportional Gains
        k_i = 0.0;% Integral gain term is set to zero for now - can be included later
        refCamSettings = [];
        refSumCts = []; 
        requestedSetpoints = [];
        calibrationMatrices;
        initialMotorValues;
    end
    % Helper functions
    methods (Access = private)
        
        function checkBool = performPreAlignmentChecks(app)
            checkBool = 1;
            data = app.UITable.Data;
            sectionBools = double(table2array(data(:,2)));
            NLaserSections = length(app.feedbackOnPVs);
             if sum(sectionBools)==0
              app.LogTextArea.Value =['Error - No laser cameras selected for alignment ',...
                 app.LogTextArea.Value(:)']  ;
             checkBool = 0;  
            end
            if isempty(app.refCamSettings) || isempty(app.refSumCts)% Exit if no references grabbed
              app.LogTextArea.Value = ...
                  ['Error - no laser references grabbed.',...
                 ' Grab references before starting auto-alignment ',...
                 app.LogTextArea.Value(:)']  ;
             checkBool = 0;
            end
            if isempty(app.requestedSetpoints)% Exit if no setpoints selected
                   app.LogTextArea.Value = ...
                  ['Error - no laser target positions selected.',...
                 ' Select target centroid positions before starting auto-alignment ',...
                 app.LogTextArea.Value(:)']  ;
             checkBool = 0;
            end
        end
        
 
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            t = table(app.sectionNames',app.feedbackOn');
            app.UITable.Data = t; 
            app.umPerPixel = ones(length(app.camerapvs),1);
            app.calibrationMatrices = loadCalibrationMatrices();
            app.initialMotorValues = getMotorValues(app);
                       
        end

        % Cell edit callback: UITable
        function UITableCellEdit(app, event)
            %indices = event.Indices;
            %newData = event.NewData;
        end

        % Button pushed function: GrabReferencesButton
        function GrabReferencesButtonPushed(app, event)
            app.LogTextArea.Value = ['Grabbing Reference Laser Parameters...',...
                app.LogTextArea.Value(:)'];
            drawnow()
            app.setPointOption = app.OptionsDropDown.Value;
            [app.refCamSettings,app.refSumCts,app.requestedSetpoints] = ...
                defineFeedbackSetpoint(app);
            app.LogTextArea.Value = ...
                ['Grabbed Reference Laser Reference Parameters',...
                app.LogTextArea.Value(:)'];
        end

        % Button pushed function: ClearReferencesButton
        function ClearReferencesButtonPushed(app, event)
            app.refCamSettings = [];
            app.refSumCts = [];
            app.requestedSetpoints = [];
            app.LogTextArea.Value = ['Cleared Reference Laser Position and Sum Counts',app.LogTextArea.Value(:)'];
        end

        % Button pushed function: PauseAlignmentButton
        function PauseAlignmentButtonPushed(app, event)
            if lcaGetSmart(app.feedbackExitPV)==1
                app.LogTextArea.Value = [' Cannot pause Auto-Alignment because it is already stopped',app.LogTextArea.Value(:)'];
            else
                lcaPutSmart(app.feedbackPausePV,1);
                app.LogTextArea.Value = ['Auto-Alignment Paused',app.LogTextArea.Value(:)'];
                app.StatusLamp.Color = [1.0 0.41 0.16];
            end
        end

        % Button pushed function: StartAlignmentButton
        function StartAlignmentButtonPushed(app, event)
            lcaPutSmart(app.feedbackExitPV,0);% Set exit PV to zero
            lcaPutSmart(app.feedbackPausePV,0);% Set pause PV to zero
            data = app.UITable.Data;
            sectionBools = double(table2array(data(:,2)));
            NLaserSections = length(app.feedbackOnPVs);
            for n=1:NLaserSections;lcaPut(app.feedbackOnPVs{n},sectionBools(n));end% Set which sections align or not 
            checkBool = performPreAlignmentChecks(app);
            if ~checkBool;return;end% Exit alignment if pre-checks are bad
            app.LogTextArea.Value = ['Starting Auto Alignment',app.LogTextArea.Value(:)'];
            app.StatusLamp.Color = 'Green';
            drawnow()
            while lcaGetSmart(app.feedbackExitPV) ==0% Run the feedback
                if lcaGetSmart(app.feedbackPausePV)==0
                for ij = 1:NLaserSections
                    % Get setpoint and motor pv for the relevant cameras      
                    inputDataStruct.motorpvs = app.motorpvs{ij};
                    
                    if ij<6% Deals with cameras up to and including B3
                        steeringSetpoint = app.requestedSetpoints(1+4*(ij-1):4*ij);
                        inputDataStruct.camerapvs = {app.camerapvs{2*ij-1},app.camerapvs{2*ij}};
                        inputDataStruct.channel_index = [1:4];
                    else% Deals with cameras B4 B5 and B6    
                        steeringSetpoint = [app.requestedSetpoints(21+2*(ij-6)) app.requestedSetpoints(20+2*(ij-5))];
                        inputDataStruct.camerapvs = {app.camerapvs{11+(ij-6)}};
                        if ij==7;inputDataStruct.channel_index = [3,4];
                        else
                            inputDataStruct.channel_index = [1,2];
                        end
                    end
                         
                    % Evaluate the exit condition
                    if evaluateExitCondition(inputDataStruct,app.refSumCts,app.refCamSettings,app.feedbackOnPVs,ij,app)
                        continue;
                    else % Run the feedback
                     app.LogTextArea.Value =  ['Aligning on ',lcaGetSmart([inputDataStruct.camerapvs{1},':NAME']),...
                         app.LogTextArea.Value(:)'];
                      [~,~,~] = ...
                            alignLaserToSetpoint(inputDataStruct,steeringSetpoint,...
                            app.calibrationMatrices{ij},app.k_p(ij),app.k_i,app);    
                            app.LogTextArea.Value = ['Last move made ',...
                                datestr(now), app.LogTextArea.Value(:)'];               
                    end
                    
                end
                else
                    lcaGetSmart(app.feedbackPausePV);                  
                    if lcaGetSmart(app.feedbackExitPV);continue;end %Makes sure you don't get stuck on pause and exit PVs = 1
                end
                drawnow()
            end            
        end

        % Button pushed function: StopAlignmentButton
        function StopAlignmentButtonPushed(app, event)
            lcaPutSmart(app.feedbackExitPV,1)
            app.LogTextArea.Value = ['Auto-Alignment Stopped',app.LogTextArea.Value(:)'];
            app.StatusLamp.Color = 'Red';
        end

        % Value changed function: OptionsDropDown
        function OptionsDropDownValueChanged(app, event)
            value = app.OptionsDropDown.Value;
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            delete(app)
            %exit;
        end

        % Button pushed function: ClearLogButton
        function ClearLogButtonPushed(app, event)
             app.LogTextArea.Value =  ' ';
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 646 515];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create SelectLaserAlignmentTargetPositionsButtonGroup
            app.SelectLaserAlignmentTargetPositionsButtonGroup = uibuttongroup(app.UIFigure);
            app.SelectLaserAlignmentTargetPositionsButtonGroup.Title = '1. Select Laser Alignment Target Positions';
            app.SelectLaserAlignmentTargetPositionsButtonGroup.Position = [31 377 263 80];

            % Create OptionsDropDown
            app.OptionsDropDown = uidropdown(app.SelectLaserAlignmentTargetPositionsButtonGroup);
            app.OptionsDropDown.Items = {'Use Pre-Defined References as Target', 'Use Current Position as Target'};
            app.OptionsDropDown.ItemsData = {'1', '2'};
            app.OptionsDropDown.ValueChangedFcn = createCallbackFcn(app, @OptionsDropDownValueChanged, true);
            app.OptionsDropDown.Position = [7 21 250 22];
            app.OptionsDropDown.Value = '1';

            % Create FACETIILaserAutoAlignmentLabel
            app.FACETIILaserAutoAlignmentLabel = uilabel(app.UIFigure);
            app.FACETIILaserAutoAlignmentLabel.HorizontalAlignment = 'center';
            app.FACETIILaserAutoAlignmentLabel.FontSize = 14;
            app.FACETIILaserAutoAlignmentLabel.FontWeight = 'bold';
            app.FACETIILaserAutoAlignmentLabel.Position = [217 483 218 22];
            app.FACETIILaserAutoAlignmentLabel.Text = 'FACET-II Laser Auto Alignment';

            % Create LogTextAreaLabel
            app.LogTextAreaLabel = uilabel(app.UIFigure);
            app.LogTextAreaLabel.HorizontalAlignment = 'right';
            app.LogTextAreaLabel.Position = [347 264 29 22];
            app.LogTextAreaLabel.Text = 'Log:';

            % Create LogTextArea
            app.LogTextArea = uitextarea(app.UIFigure);
            app.LogTextArea.Position = [347 31 268 229];

            % Create InitializeReferenceLaserParametersPanel
            app.InitializeReferenceLaserParametersPanel = uipanel(app.UIFigure);
            app.InitializeReferenceLaserParametersPanel.Title = '2. Initialize Reference Laser Parameters';
            app.InitializeReferenceLaserParametersPanel.Position = [31 306 265 57];

            % Create GrabReferencesButton
            app.GrabReferencesButton = uibutton(app.InitializeReferenceLaserParametersPanel, 'push');
            app.GrabReferencesButton.ButtonPushedFcn = createCallbackFcn(app, @GrabReferencesButtonPushed, true);
            app.GrabReferencesButton.Position = [11 8 108 23];
            app.GrabReferencesButton.Text = 'Grab References';

            % Create ClearReferencesButton
            app.ClearReferencesButton = uibutton(app.InitializeReferenceLaserParametersPanel, 'push');
            app.ClearReferencesButton.ButtonPushedFcn = createCallbackFcn(app, @ClearReferencesButtonPushed, true);
            app.ClearReferencesButton.Position = [134 8 111 23];
            app.ClearReferencesButton.Text = 'Clear References';

            % Create SelectCamerastoAlignPanel
            app.SelectCamerastoAlignPanel = uipanel(app.UIFigure);
            app.SelectCamerastoAlignPanel.Title = '3. Select Cameras to Align';
            app.SelectCamerastoAlignPanel.Position = [31 29 282 255];

            % Create UITable
            app.UITable = uitable(app.SelectCamerastoAlignPanel);
            app.UITable.ColumnName = {'Laser Cameras'; 'Select'};
            app.UITable.RowName = {};
            app.UITable.ColumnEditable = [false true];
            app.UITable.CellEditCallback = createCallbackFcn(app, @UITableCellEdit, true);
            app.UITable.Position = [13 15 255 208];

            % Create InitiateAutoAlignmentPanel
            app.InitiateAutoAlignmentPanel = uipanel(app.UIFigure);
            app.InitiateAutoAlignmentPanel.Title = '4 Initiate Auto Alignment';
            app.InitiateAutoAlignmentPanel.Position = [345 306 271 151];

            % Create StartAlignmentButton
            app.StartAlignmentButton = uibutton(app.InitiateAutoAlignmentPanel, 'push');
            app.StartAlignmentButton.ButtonPushedFcn = createCallbackFcn(app, @StartAlignmentButtonPushed, true);
            app.StartAlignmentButton.BackgroundColor = [0.3922 0.8314 0.0745];
            app.StartAlignmentButton.FontSize = 14;
            app.StartAlignmentButton.Position = [15 99 121 24];
            app.StartAlignmentButton.Text = 'Start Alignment';

            % Create PauseAlignmentButton
            app.PauseAlignmentButton = uibutton(app.InitiateAutoAlignmentPanel, 'push');
            app.PauseAlignmentButton.ButtonPushedFcn = createCallbackFcn(app, @PauseAlignmentButtonPushed, true);
            app.PauseAlignmentButton.BackgroundColor = [1 0.4118 0.1608];
            app.PauseAlignmentButton.FontSize = 14;
            app.PauseAlignmentButton.Position = [15 56 122 24];
            app.PauseAlignmentButton.Text = 'Pause Alignment';

            % Create StopAlignmentButton
            app.StopAlignmentButton = uibutton(app.InitiateAutoAlignmentPanel, 'push');
            app.StopAlignmentButton.ButtonPushedFcn = createCallbackFcn(app, @StopAlignmentButtonPushed, true);
            app.StopAlignmentButton.BackgroundColor = [1 0 0];
            app.StopAlignmentButton.FontSize = 14;
            app.StopAlignmentButton.Position = [15 9 121 24];
            app.StopAlignmentButton.Text = 'Stop Alignment';

            % Create StatusLampLabel
            app.StatusLampLabel = uilabel(app.InitiateAutoAlignmentPanel);
            app.StatusLampLabel.HorizontalAlignment = 'right';
            app.StatusLampLabel.Position = [171 8 42 22];
            app.StatusLampLabel.Text = 'Status:';

            % Create StatusLamp
            app.StatusLamp = uilamp(app.InitiateAutoAlignmentPanel);
            app.StatusLamp.Position = [228 8 20 20];
            app.StatusLamp.Color = [0.902 0.902 0.902];

            % Create IRmodeButton
            app.IRmodeButton = uibutton(app.InitiateAutoAlignmentPanel, 'push');
            app.IRmodeButton.BackgroundColor = [0.302 0.7451 0.9333];
            app.IRmodeButton.Position = [188 99 72 23];
            app.IRmodeButton.Text = 'IR mode';

            % Create ClearLogButton
            app.ClearLogButton = uibutton(app.UIFigure, 'push');
            app.ClearLogButton.ButtonPushedFcn = createCallbackFcn(app, @ClearLogButtonPushed, true);
            app.ClearLogButton.Position = [515 264 100 23];
            app.ClearLogButton.Text = 'Clear Log';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_LAA_exported

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