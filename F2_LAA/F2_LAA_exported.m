classdef F2_LAA_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        SelectLaserAlignmentTargetPositionsButtonGroup  matlab.ui.container.ButtonGroup
        ShowTargetsButton               matlab.ui.control.Button
        FACETIILaserAutoAlignmentLabel  matlab.ui.control.Label
        LogTextAreaLabel                matlab.ui.control.Label
        LogTextArea                     matlab.ui.control.TextArea
        InitializeReferenceLaserParametersPanel  matlab.ui.container.Panel
        GrabReferencesButton            matlab.ui.control.Button
        SelectCamerastoAlignPanel       matlab.ui.container.Panel
        UITable                         matlab.ui.control.Table
        InitiateAutoAlignmentPanel      matlab.ui.container.Panel
        StartAlignmentButton            matlab.ui.control.Button
        StopAlignmentButton             matlab.ui.control.Button
        StatusLampLabel                 matlab.ui.control.Label
        StatusLamp                      matlab.ui.control.Lamp
        IRmodeButton                    matlab.ui.control.Button
        ExpertButton                    matlab.ui.control.Button
        ClearLogButton                  matlab.ui.control.Button
        SetshutterstatusPanel           matlab.ui.container.Panel
        HeNestatusLampLabel             matlab.ui.control.Label
        HeNestatusLamp                  matlab.ui.control.Lamp
        EPSshutterLampLabel             matlab.ui.control.Label
        EPSshutterLamp                  matlab.ui.control.Lamp
        BlockUnblockButton              matlab.ui.control.Button
        BlockUnblockButton_2            matlab.ui.control.Button
        SetcameraexposuresPanel         matlab.ui.container.Panel
        SetExposuresButton              matlab.ui.control.Button
    end

    
    properties (Access = public)
        config = loadPyConfig()
        align
        feedbackExitPV = 'SIOC:SYS1:ML01:AO169';
        maxMisalignmentTolerancePV = 'SIOC:SYS1:ML01:AO200';
        MPANearFarmaxMisalignmentTolerancePV = 'SIOC:SYS1:ML01:AO189';
        disableTimestampCheckForCamerasPV = 'SIOC:SYS1:ML01:AO187';
        fitMethod = 1;% Centroid fit method for profmon_process
        maxMisalignmentTolerance;
        MPANearFarmaxMisalignmentTolerance;
        disableTimestampCheckForCameras;
        
        HeNeBlockTRAPV = 'XPS:LA20:LS24:M3';
        HeNeBlockOut = 8;
        HeNeBlockIn = 10;
        
        EPSShutterPV = 'DO:LA20:10:Bo1';
        EPSShutterBlocked = 'High';
        EPSShutterOpen = 'Low';
        
    end
    % Helper functions
    methods (Access = public)
        
        function checkBool = performPreAlignmentChecks(app)
            % PERFORMPREALIGNMENTCHECKS Warns the user if settings
            % necessary for alignment have not been set.
            
            % Check to make sure a section has been selected for alignment
            checkBool = 1;
            data = app.UITable.Data;
            sectionBools = double(table2array(data(:, 2)));
            if sum(sectionBools) == 0
                app.appendMessage('ERROR - No laser cameras selected');
                checkBool = 0;
            end
            
            checkBool = app.align.checkReferences(checkBool);
        end
        
        % #################################################################
        % #
        % # Functions that implement GUI actions
        % #
        % #################################################################
        function initiateShutterPanel(app)
            app.setHeNeStatus();
            app.setEPSShutterStatus();
        end
        
        function setHeNeStatus(app)
            HeNeVal = lcaGetSmart([app.HeNeBlockTRAPV,'.RBV']);
            if abs(HeNeVal - app.HeNeBlockOut) < 0.001
                app.HeNestatusLamp.Color = [0, 1, 0];
                app.HeNestatusLamp.Tooltip = 'HeNe block is out, HeNe is being sent';
                app.BlockUnblockButton.Text = 'Block';
            elseif  abs(HeNeVal - app.HeNeBlockIn) < 0.001
                app.HeNestatusLamp.Color = [1, 0, 0];
                app.HeNestatusLamp.Tooltip = 'HeNe block is in, HeNe is being blocked';
                app.BlockUnblockButton.Text = 'Unblock';
            else
                app.HeNestatusLamp.Color = [1, 1, 0];
                app.HeNestatusLamp.Tooltip = 'Status unknown';
                app.BlockUnblockButton.Text = 'Block';
            end
        end
        
        function setEPSShutterStatus(app)
            ShutterVal = lcaGetSmart(app.EPSShutterPV);
            if strcmp(ShutterVal,'High')
                app.EPSshutterLamp.Color = [1, 0, 0];
                app.EPSshutterLamp.Tooltip = 'EPS shutter is in';
                app.BlockUnblockButton_2.Text = 'Unblock';
            elseif strcmp(ShutterVal,'Low')
                app.EPSshutterLamp.Color = [0, 1, 0];
                app.EPSshutterLamp.Tooltip = 'EPS shutter is out';
                app.BlockUnblockButton_2.Text = 'Block';
            end
            
        end
        
        function flipEPSShutter(app)
            ShutterVal = lcaGetSmart(app.EPSShutterPV);
            
            if strcmp(ShutterVal, app.EPSShutterBlocked)
                lcaPutSmart(app.EPSShutterPV, app.EPSShutterOpen);
            elseif strcmp(ShutterVal, app.EPSShutterOpen)
                lcaPutSmart(app.EPSShutterPV, app.EPSShutterBlocked);
            end
            
            app.setEPSShutterStatus();
        end
        
        function moveStepperMotor(app, motorPV, motorName, target)
            lcaPutSmart(motorPV, target);
            motorVal = lcaGetSmart([motorPV,'.RBV']);
            app.appendMessage(['Moving motor: ', motorName]);
            
            while ~(abs(motorVal - target) < 0.01)
                motorVal = lcaGetSmart([motorPV,'.RBV']);
                app.setHeNeStatus();
                drawnow;
            end
            app.LogTextArea.Value = ...
                [['Finished moving motor: ', motorName], ...
                app.LogTextArea.Value(:)'] ;
        end
        
        function appendMessage(app, msg)
            % APPENDMESSAGE Appends a message to the log textArea and
            % redraws the text area. Automatically removes lines from the
            % log after 500 lines.
            %
            % Args:
            %     msg: Message to append to the top of the log area.
            
            N = numel(app.LogTextArea.Value);
            % Clear the log after this many lines
            cutoff = 500;
            if N > cutoff
                N = cutoff;
            end
            app.LogTextArea.Value = ...
                [msg, ...
                app.LogTextArea.Value(1:N)'];
            drawnow;
        end
        
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % STARTUPFCN Loads necessary data for the app to run
            
            app.align = AlignerCommon(app);
            % Initialize the table with the section names
            sections = fieldnames(app.config);
            N = numel(sections);
            sectionNames = cell(N,1);
            feedbackOn = false(N,1);
            for i=1:N
                section = app.config.(sections{i});
                sectionNames{i} = section.name;
            end
            t = table(sectionNames, feedbackOn);
            app.UITable.Data = t;
            drawnow;
            % Perform other setup work
            app.align.clearReferences();
            app.config = loadCalibrationMatrices(app.config);
            app.initiateShutterPanel();
        end

        % Button pushed function: GrabReferencesButton
        function GrabReferencesButtonPushed(app, event)
            % GRABREFERENCESBUTTONPUSHED Clears the existing reference
            % parameters and grabs new ones from the cameras.
            
            app.align.clearReferences();
            app.appendMessage('Grabbing Reference Laser Parameters...');
            app.config = defineFeedbackSetpoint(app.config, app.fitMethod);
            app.appendMessage('Grabbed Reference Laser Parameters');
        end

        % Button pushed function: StartAlignmentButton
        function StartAlignmentButtonPushed(app, event)
            % STARTALIGNMENTBUTTON Loops through the sections, checks if
            % each section is valid, if it is aligns them
            
            lcaPutSmart(app.feedbackExitPV, 0);% Set exit PV to zero
            checkBool = performPreAlignmentChecks(app);
            if ~checkBool;return;end% Exit alignment if pre-checks are bad
            app.appendMessage('Starting Auto Alignment');
            app.StatusLamp.Color = 'Green';
            drawnow()
            
            sections = fieldnames(app.config);
            N = numel(sections);
            
            % Only align while the PV says we can
            while lcaGetSmart(app.feedbackExitPV) == 0% Start the feedback
                % Check which sections are selected for alignment, get the value of the gain PV
                % This is in the loop so the user can change the sections while the autoaligner is running
                data = app.UITable.Data;
                sectionBools = double(table2array(data(:,2)));
                for i=1:N
                    section = app.config.(sections{i});
                    section.gain = lcaGetSmart(section.gainPV);
                    lcaPutSmart(section.feedbackOnPV, sectionBools(i));
                    app.config.(sections{i}) = section;
                end
                app.maxMisalignmentTolerance = lcaGetSmart(app.maxMisalignmentTolerancePV);% Update max misalignment tolerance
                app.MPANearFarmaxMisalignmentTolerance = lcaGetSmart(app.MPANearFarmaxMisalignmentTolerancePV);% Update max misalignment tolerance
                app.disableTimestampCheckForCameras = lcaGetSmart(app.disableTimestampCheckForCamerasPV);% Update timestamp check
                
                % Make sure the tolerance PV makes sense
                if any([isnan(app.maxMisalignmentTolerance), ...
                        ~isreal(app.maxMisalignmentTolerance), ...
                        ~isnumeric(app.maxMisalignmentTolerance)])
                    app.appendMessage('Invalid value for max misalignment tolerance. Skipping alignment');
                    continue
                end
                
                % Loop through the sections and align them one at a time
                for i=1:N
                    section = app.config.(sections{i});
                    % Kill the auto-aligner at the current section rather than waiting for all the sections
                    if lcaGetSmart(app.feedbackExitPV) == 0
                        if app.align.evaluateExitCondition(section)
                            continue;
                        else % Run the feedback
                            app.appendMessage(['Aligning on ', section.name]);
                            app.align.alignLaserToSetpoint(section);
                        end
                    else
                        if lcaGetSmart(app.feedbackExitPV)
                            continue
                        end %Makes sure you don't get stuck on pause and exit PVs = 1
                    end
                end
                drawnow()
            end
        end

        % Button pushed function: StopAlignmentButton
        function StopAlignmentButtonPushed(app, event)
            lcaPutSmart(app.feedbackExitPV,1)
            app.appendMessage('Auto-Alignment Stopped');
            app.StatusLamp.Color = 'Red';
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            delete(app)
            disp('Remember to uncomment the exit command')
            exit;
        end

        % Button pushed function: ClearLogButton
        function ClearLogButtonPushed(app, event)
            app.LogTextArea.Value =  ' ';
        end

        % Button pushed function: ShowTargetsButton
        function ShowTargetsButtonPushed(app, event)
            addpath('../F2_LaserMultiProfmon/')
            s20LaserTargetPositionsTable
        end

        % Button pushed function: ExpertButton
        function ExpertButtonPushed(app, event)
            expertSettings_F2_LAA
        end

        % Button pushed function: IRmodeButton
        function IRmodeButtonPushed(app, event)
            lcaPutSmart(app.feedbackExitPV,1)
            app.appendMessage('Auto-Alignment Stopped, Launching IR alignment app');
            app.StatusLamp.Color = 'Red';
            IRmode
        end

        % Button pushed function: BlockUnblockButton
        function BlockUnblockButtonPushed(app, event)
            % Blocks/unblocks the HeNe
            
            HeNeVal = lcaGetSmart(app.HeNeBlockTRAPV);
            
            app.HeNestatusLamp.Color = [1, 1, 0];
            app.HeNestatusLamp.Tooltip = 'Status unknown';
            app.BlockUnblockButton.Text = 'Block';
            drawnow();
            
            if abs(HeNeVal - app.HeNeBlockIn) < 0.001
                target = app.HeNeBlockOut;
            else
                target = app.HeNeBlockIn;
            end
            
            app.moveStepperMotor(app.HeNeBlockTRAPV, 'HeNe block', target);
            app.setHeNeStatus
            drawnow();
            
        end

        % Button pushed function: BlockUnblockButton_2
        function BlockUnblockButton_2Pushed(app, event)
            app.flipEPSShutter();
        end

        % Button pushed function: SetExposuresButton
        function SetExposuresButtonPushed(app, event)
            
            sections = fieldnames(app.config);
            for i=1:numel(sections)
                section = app.config.(sections{i});
                cameras = fieldnames(section.cameras);
                for j=1:numel(cameras)
                    camera = section.cameras.(cameras{j});
                    lcaPutSmart(strcat(camera.cameraPV, ':AcquireTime'), camera.exposure);
                end
            end
            app.appendMessage('Cameras exposure time set');
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 637 729];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create SelectLaserAlignmentTargetPositionsButtonGroup
            app.SelectLaserAlignmentTargetPositionsButtonGroup = uibuttongroup(app.UIFigure);
            app.SelectLaserAlignmentTargetPositionsButtonGroup.Title = '1. Select Laser Alignment Target Positions';
            app.SelectLaserAlignmentTargetPositionsButtonGroup.Position = [35 613 280 59];

            % Create ShowTargetsButton
            app.ShowTargetsButton = uibutton(app.SelectLaserAlignmentTargetPositionsButtonGroup, 'push');
            app.ShowTargetsButton.ButtonPushedFcn = createCallbackFcn(app, @ShowTargetsButtonPushed, true);
            app.ShowTargetsButton.Position = [90 8 100 23];
            app.ShowTargetsButton.Text = 'Show Targets';

            % Create FACETIILaserAutoAlignmentLabel
            app.FACETIILaserAutoAlignmentLabel = uilabel(app.UIFigure);
            app.FACETIILaserAutoAlignmentLabel.HorizontalAlignment = 'center';
            app.FACETIILaserAutoAlignmentLabel.FontSize = 14;
            app.FACETIILaserAutoAlignmentLabel.FontWeight = 'bold';
            app.FACETIILaserAutoAlignmentLabel.Position = [217 697 218 22];
            app.FACETIILaserAutoAlignmentLabel.Text = 'FACET-II Laser Auto Alignment';

            % Create LogTextAreaLabel
            app.LogTextAreaLabel = uilabel(app.UIFigure);
            app.LogTextAreaLabel.HorizontalAlignment = 'right';
            app.LogTextAreaLabel.Position = [345 471 29 22];
            app.LogTextAreaLabel.Text = 'Log:';

            % Create LogTextArea
            app.LogTextArea = uitextarea(app.UIFigure);
            app.LogTextArea.Position = [345 22 268 445];

            % Create InitializeReferenceLaserParametersPanel
            app.InitializeReferenceLaserParametersPanel = uipanel(app.UIFigure);
            app.InitializeReferenceLaserParametersPanel.Title = '4. Initialize Reference Laser Parameters';
            app.InitializeReferenceLaserParametersPanel.Position = [36 348 280 57];

            % Create GrabReferencesButton
            app.GrabReferencesButton = uibutton(app.InitializeReferenceLaserParametersPanel, 'push');
            app.GrabReferencesButton.ButtonPushedFcn = createCallbackFcn(app, @GrabReferencesButtonPushed, true);
            app.GrabReferencesButton.Position = [85 6 108 23];
            app.GrabReferencesButton.Text = 'Grab References';

            % Create SelectCamerastoAlignPanel
            app.SelectCamerastoAlignPanel = uipanel(app.UIFigure);
            app.SelectCamerastoAlignPanel.Title = '5. Select Cameras to Align';
            app.SelectCamerastoAlignPanel.Position = [36 19 280 313];

            % Create UITable
            app.UITable = uitable(app.SelectCamerastoAlignPanel);
            app.UITable.ColumnName = {'Laser Cameras'; 'Select'};
            app.UITable.RowName = {};
            app.UITable.ColumnEditable = [false true];
            app.UITable.Position = [13 17 255 264];

            % Create InitiateAutoAlignmentPanel
            app.InitiateAutoAlignmentPanel = uipanel(app.UIFigure);
            app.InitiateAutoAlignmentPanel.Title = '6. Initiate Auto Alignment';
            app.InitiateAutoAlignmentPanel.Position = [345 534 271 137];

            % Create StartAlignmentButton
            app.StartAlignmentButton = uibutton(app.InitiateAutoAlignmentPanel, 'push');
            app.StartAlignmentButton.ButtonPushedFcn = createCallbackFcn(app, @StartAlignmentButtonPushed, true);
            app.StartAlignmentButton.BackgroundColor = [0.3922 0.8314 0.0745];
            app.StartAlignmentButton.FontSize = 14;
            app.StartAlignmentButton.Position = [15 80 121 24];
            app.StartAlignmentButton.Text = 'Start Alignment';

            % Create StopAlignmentButton
            app.StopAlignmentButton = uibutton(app.InitiateAutoAlignmentPanel, 'push');
            app.StopAlignmentButton.ButtonPushedFcn = createCallbackFcn(app, @StopAlignmentButtonPushed, true);
            app.StopAlignmentButton.BackgroundColor = [1 0 0];
            app.StopAlignmentButton.FontSize = 14;
            app.StopAlignmentButton.Position = [15 42 121 24];
            app.StopAlignmentButton.Text = 'Stop Alignment';

            % Create StatusLampLabel
            app.StatusLampLabel = uilabel(app.InitiateAutoAlignmentPanel);
            app.StatusLampLabel.HorizontalAlignment = 'right';
            app.StatusLampLabel.Position = [176 6 42 22];
            app.StatusLampLabel.Text = 'Status:';

            % Create StatusLamp
            app.StatusLamp = uilamp(app.InitiateAutoAlignmentPanel);
            app.StatusLamp.Position = [233 6 20 20];
            app.StatusLamp.Color = [0.902 0.902 0.902];

            % Create IRmodeButton
            app.IRmodeButton = uibutton(app.InitiateAutoAlignmentPanel, 'push');
            app.IRmodeButton.ButtonPushedFcn = createCallbackFcn(app, @IRmodeButtonPushed, true);
            app.IRmodeButton.BackgroundColor = [0.302 0.7451 0.9333];
            app.IRmodeButton.Position = [181 81 72 23];
            app.IRmodeButton.Text = 'IR mode';

            % Create ExpertButton
            app.ExpertButton = uibutton(app.InitiateAutoAlignmentPanel, 'push');
            app.ExpertButton.ButtonPushedFcn = createCallbackFcn(app, @ExpertButtonPushed, true);
            app.ExpertButton.Position = [183 43 70 23];
            app.ExpertButton.Text = 'Expert...';

            % Create ClearLogButton
            app.ClearLogButton = uibutton(app.UIFigure, 'push');
            app.ClearLogButton.ButtonPushedFcn = createCallbackFcn(app, @ClearLogButtonPushed, true);
            app.ClearLogButton.Position = [510 504 100 23];
            app.ClearLogButton.Text = 'Clear Log';

            % Create SetshutterstatusPanel
            app.SetshutterstatusPanel = uipanel(app.UIFigure);
            app.SetshutterstatusPanel.Title = '2. Set shutter status';
            app.SetshutterstatusPanel.Position = [36 504 280 97];

            % Create HeNestatusLampLabel
            app.HeNestatusLampLabel = uilabel(app.SetshutterstatusPanel);
            app.HeNestatusLampLabel.HorizontalAlignment = 'right';
            app.HeNestatusLampLabel.Position = [26 44 72 22];
            app.HeNestatusLampLabel.Text = 'HeNe status';

            % Create HeNestatusLamp
            app.HeNestatusLamp = uilamp(app.SetshutterstatusPanel);
            app.HeNestatusLamp.Position = [113 44 20 20];
            app.HeNestatusLamp.Color = [1 1 0];

            % Create EPSshutterLampLabel
            app.EPSshutterLampLabel = uilabel(app.SetshutterstatusPanel);
            app.EPSshutterLampLabel.HorizontalAlignment = 'right';
            app.EPSshutterLampLabel.Position = [151 44 69 22];
            app.EPSshutterLampLabel.Text = 'EPS shutter';

            % Create EPSshutterLamp
            app.EPSshutterLamp = uilamp(app.SetshutterstatusPanel);
            app.EPSshutterLamp.Position = [235 44 20 20];

            % Create BlockUnblockButton
            app.BlockUnblockButton = uibutton(app.SetshutterstatusPanel, 'push');
            app.BlockUnblockButton.ButtonPushedFcn = createCallbackFcn(app, @BlockUnblockButtonPushed, true);
            app.BlockUnblockButton.Position = [29 12 100 23];
            app.BlockUnblockButton.Text = 'Block/Unblock';

            % Create BlockUnblockButton_2
            app.BlockUnblockButton_2 = uibutton(app.SetshutterstatusPanel, 'push');
            app.BlockUnblockButton_2.ButtonPushedFcn = createCallbackFcn(app, @BlockUnblockButton_2Pushed, true);
            app.BlockUnblockButton_2.Position = [153 12 100 23];
            app.BlockUnblockButton_2.Text = 'Block/Unblock';

            % Create SetcameraexposuresPanel
            app.SetcameraexposuresPanel = uipanel(app.UIFigure);
            app.SetcameraexposuresPanel.Title = '3. Set camera exposures';
            app.SetcameraexposuresPanel.Position = [36 424 280 64];

            % Create SetExposuresButton
            app.SetExposuresButton = uibutton(app.SetcameraexposuresPanel, 'push');
            app.SetExposuresButton.ButtonPushedFcn = createCallbackFcn(app, @SetExposuresButtonPushed, true);
            app.SetExposuresButton.Position = [89 10 100 23];
            app.SetExposuresButton.Text = 'Set Exposures';

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