classdef F2_Aligner_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        ImageAxes                   matlab.ui.control.UIAxes
        SteeringPanel               matlab.ui.container.Panel
        UpButton                    matlab.ui.control.Button
        DownButton                  matlab.ui.control.Button
        LeftButton                  matlab.ui.control.Button
        RightButton                 matlab.ui.control.Button
        StepsizerevsEditFieldLabel  matlab.ui.control.Label
        StepsizerevsEditField       matlab.ui.control.NumericEditField
        CamerasettingsPanel         matlab.ui.container.Panel
        CameraDropDownLabel         matlab.ui.control.Label
        CameraDropDown              matlab.ui.control.DropDown
        Lamp_3                      matlab.ui.control.Lamp
        ExposuretimeEditFieldLabel  matlab.ui.control.Label
        ExposuretimeEditField       matlab.ui.control.NumericEditField
        StartButton                 matlab.ui.control.Button
        StopButton                  matlab.ui.control.Button
        BitdepthSpinnerLabel        matlab.ui.control.Label
        BitdepthSpinner             matlab.ui.control.Spinner
        TargetPanel                 matlab.ui.container.Panel
        HorizontalEditFieldLabel    matlab.ui.control.Label
        HorizontalEditField         matlab.ui.control.NumericEditField
        VerticalEditFieldLabel      matlab.ui.control.Label
        VerticalEditField           matlab.ui.control.NumericEditField
        RadiusEditFieldLabel        matlab.ui.control.Label
        RadiusEditField             matlab.ui.control.NumericEditField
        ShowcentroidfitCheckBox     matlab.ui.control.CheckBox
        ShowtraceCheckBox           matlab.ui.control.CheckBox
    end

    
    properties (Access = private)
        aligner % Description
        updateBool = 0;
    end
    
    methods (Access = private)
        
        function setDropDown(app)
            listOfCameras = app.aligner.getCameras();
            app.CameraDropDown.Items = listOfCameras;
            
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.aligner = F2_aligner_control(app);
            
            app.setDropDown();
            
        end

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
            app.updateBool = 1;
            app.Lamp_3.Color = [0 1 0];
            while app.updateBool
                camera = app.CameraDropDown.Value();
                app.aligner.updateImage(camera);
                pause(0.3)
            end
            
        end

        % Button pushed function: StopButton
        function StopButtonPushed(app, event)
            app.updateBool = 0;
            app.Lamp_3.Color = [1 0 0];
        end

        % Value changed function: CameraDropDown
        function CameraDropDownValueChanged(app, event)
            newCamera = app.CameraDropDown.Value;
            app.aligner.updateGUI(newCamera); 
        end

        % Button pushed function: LeftButton
        function LeftButtonPushed(app, event)
            app.aligner.moveHorN();
        end

        % Button pushed function: RightButton
        function RightButtonPushed(app, event)
            app.aligner.moveHorP();
        end

        % Button pushed function: UpButton
        function UpButtonPushed(app, event)
            app.aligner.moveVerN();
        end

        % Button pushed function: DownButton
        function DownButtonPushed(app, event)
            app.aligner.moveVerP();
        end

        % Value changed function: ExposuretimeEditField
        function ExposuretimeEditFieldValueChanged(app, event)
            value = app.ExposuretimeEditField.Value;
            app.aligner.setExposure(value); 
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            delete(app)
            exit;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 751 907];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create ImageAxes
            app.ImageAxes = uiaxes(app.UIFigure);
            title(app.ImageAxes, 'Title')
            xlabel(app.ImageAxes, 'X')
            ylabel(app.ImageAxes, 'Y')
            app.ImageAxes.FontSize = 14;
            app.ImageAxes.Position = [25 14 706 589];

            % Create SteeringPanel
            app.SteeringPanel = uipanel(app.UIFigure);
            app.SteeringPanel.Title = 'Steering';
            app.SteeringPanel.Position = [457 624 272 265];

            % Create UpButton
            app.UpButton = uibutton(app.SteeringPanel, 'push');
            app.UpButton.ButtonPushedFcn = createCallbackFcn(app, @UpButtonPushed, true);
            app.UpButton.Position = [88 218 100 23];
            app.UpButton.Text = 'Up';

            % Create DownButton
            app.DownButton = uibutton(app.SteeringPanel, 'push');
            app.DownButton.ButtonPushedFcn = createCallbackFcn(app, @DownButtonPushed, true);
            app.DownButton.Position = [88 163 100 23];
            app.DownButton.Text = 'Down';

            % Create LeftButton
            app.LeftButton = uibutton(app.SteeringPanel, 'push');
            app.LeftButton.ButtonPushedFcn = createCallbackFcn(app, @LeftButtonPushed, true);
            app.LeftButton.Position = [10 190 100 23];
            app.LeftButton.Text = 'Left';

            % Create RightButton
            app.RightButton = uibutton(app.SteeringPanel, 'push');
            app.RightButton.ButtonPushedFcn = createCallbackFcn(app, @RightButtonPushed, true);
            app.RightButton.Position = [166 190 100 23];
            app.RightButton.Text = 'Right';

            % Create StepsizerevsEditFieldLabel
            app.StepsizerevsEditFieldLabel = uilabel(app.SteeringPanel);
            app.StepsizerevsEditFieldLabel.HorizontalAlignment = 'right';
            app.StepsizerevsEditFieldLabel.Position = [12 123 87 22];
            app.StepsizerevsEditFieldLabel.Text = 'Step size [revs]';

            % Create StepsizerevsEditField
            app.StepsizerevsEditField = uieditfield(app.SteeringPanel, 'numeric');
            app.StepsizerevsEditField.Position = [10 102 97 22];

            % Create CamerasettingsPanel
            app.CamerasettingsPanel = uipanel(app.UIFigure);
            app.CamerasettingsPanel.Title = 'Camera settings';
            app.CamerasettingsPanel.Position = [28 781 407 112];

            % Create CameraDropDownLabel
            app.CameraDropDownLabel = uilabel(app.CamerasettingsPanel);
            app.CameraDropDownLabel.HorizontalAlignment = 'right';
            app.CameraDropDownLabel.Position = [11 61 49 22];
            app.CameraDropDownLabel.Text = 'Camera';

            % Create CameraDropDown
            app.CameraDropDown = uidropdown(app.CamerasettingsPanel);
            app.CameraDropDown.Items = {'HeNeNear', 'HeNeFar', 'B0', 'B1', 'B2', 'B3', 'B4', 'B5', 'B6'};
            app.CameraDropDown.ValueChangedFcn = createCallbackFcn(app, @CameraDropDownValueChanged, true);
            app.CameraDropDown.Position = [75 61 100 22];
            app.CameraDropDown.Value = 'HeNeNear';

            % Create Lamp_3
            app.Lamp_3 = uilamp(app.CamerasettingsPanel);
            app.Lamp_3.Position = [185 62 20 20];
            app.Lamp_3.Color = [1 0 0];

            % Create ExposuretimeEditFieldLabel
            app.ExposuretimeEditFieldLabel = uilabel(app.CamerasettingsPanel);
            app.ExposuretimeEditFieldLabel.HorizontalAlignment = 'right';
            app.ExposuretimeEditFieldLabel.Position = [213 61 83 22];
            app.ExposuretimeEditFieldLabel.Text = 'Exposure time';

            % Create ExposuretimeEditField
            app.ExposuretimeEditField = uieditfield(app.CamerasettingsPanel, 'numeric');
            app.ExposuretimeEditField.ValueChangedFcn = createCallbackFcn(app, @ExposuretimeEditFieldValueChanged, true);
            app.ExposuretimeEditField.Position = [308 61 83 22];

            % Create StartButton
            app.StartButton = uibutton(app.CamerasettingsPanel, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.Position = [19 16 100 23];
            app.StartButton.Text = 'Start';

            % Create StopButton
            app.StopButton = uibutton(app.CamerasettingsPanel, 'push');
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);
            app.StopButton.Position = [135 16 100 23];
            app.StopButton.Text = 'Stop';

            % Create BitdepthSpinnerLabel
            app.BitdepthSpinnerLabel = uilabel(app.CamerasettingsPanel);
            app.BitdepthSpinnerLabel.HorizontalAlignment = 'right';
            app.BitdepthSpinnerLabel.Position = [268 16 50 23];
            app.BitdepthSpinnerLabel.Text = 'Bitdepth';

            % Create BitdepthSpinner
            app.BitdepthSpinner = uispinner(app.CamerasettingsPanel);
            app.BitdepthSpinner.Limits = [2 16];
            app.BitdepthSpinner.Position = [332 16 46 22];
            app.BitdepthSpinner.Value = 12;

            % Create TargetPanel
            app.TargetPanel = uipanel(app.UIFigure);
            app.TargetPanel.Title = 'Target';
            app.TargetPanel.Position = [28 645 405 124];

            % Create HorizontalEditFieldLabel
            app.HorizontalEditFieldLabel = uilabel(app.TargetPanel);
            app.HorizontalEditFieldLabel.HorizontalAlignment = 'center';
            app.HorizontalEditFieldLabel.Position = [31 70 61 22];
            app.HorizontalEditFieldLabel.Text = 'Horizontal';

            % Create HorizontalEditField
            app.HorizontalEditField = uieditfield(app.TargetPanel, 'numeric');
            app.HorizontalEditField.Position = [11 49 100 22];

            % Create VerticalEditFieldLabel
            app.VerticalEditFieldLabel = uilabel(app.TargetPanel);
            app.VerticalEditFieldLabel.HorizontalAlignment = 'center';
            app.VerticalEditFieldLabel.Position = [152 70 46 22];
            app.VerticalEditFieldLabel.Text = 'Vertical';

            % Create VerticalEditField
            app.VerticalEditField = uieditfield(app.TargetPanel, 'numeric');
            app.VerticalEditField.Position = [128 49 100 22];

            % Create RadiusEditFieldLabel
            app.RadiusEditFieldLabel = uilabel(app.TargetPanel);
            app.RadiusEditFieldLabel.HorizontalAlignment = 'center';
            app.RadiusEditFieldLabel.Position = [296 70 44 22];
            app.RadiusEditFieldLabel.Text = 'Radius';

            % Create RadiusEditField
            app.RadiusEditField = uieditfield(app.TargetPanel, 'numeric');
            app.RadiusEditField.Position = [268 49 100 22];
            app.RadiusEditField.Value = 150;

            % Create ShowcentroidfitCheckBox
            app.ShowcentroidfitCheckBox = uicheckbox(app.TargetPanel);
            app.ShowcentroidfitCheckBox.Enable = 'off';
            app.ShowcentroidfitCheckBox.Text = 'Show centroid fit';
            app.ShowcentroidfitCheckBox.Position = [21 14 112 22];

            % Create ShowtraceCheckBox
            app.ShowtraceCheckBox = uicheckbox(app.TargetPanel);
            app.ShowtraceCheckBox.Enable = 'off';
            app.ShowtraceCheckBox.Text = 'Show trace';
            app.ShowtraceCheckBox.Position = [154 14 83 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_Aligner_exported

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