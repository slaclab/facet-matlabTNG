classdef F2_RADFET_GUI_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        CameraRebootsandRadiationLabel  matlab.ui.control.Label
        ConfigurationPanel              matlab.ui.container.Panel
        CameraDropDownLabel             matlab.ui.control.Label
        CameraDropDown                  matlab.ui.control.DropDown
        StartDateDatePickerLabel        matlab.ui.control.Label
        StartDatePicker                 matlab.ui.control.DatePicker
        RADFETDropDownLabel             matlab.ui.control.Label
        RADFETDropDown                  matlab.ui.control.DropDown
        EndDateDatePickerLabel          matlab.ui.control.Label
        EndDatePicker                   matlab.ui.control.DatePicker
        PlotButton                      matlab.ui.control.Button
        TOROIDDropDownLabel             matlab.ui.control.Label
        TOROIDDropDown                  matlab.ui.control.DropDown
        ButtonGroup                     matlab.ui.container.ButtonGroup
        RadiationButton                 matlab.ui.control.RadioButton
        ChargeButton                    matlab.ui.control.RadioButton
        TimeRangeWarning                matlab.ui.control.Label
        PlotPanel                       matlab.ui.container.Panel
        UIAxes                          matlab.ui.control.UIAxes
        PrinttoeLogButton               matlab.ui.control.Button
    end

    
    properties (Access = private)
        aobj % app support object
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.aobj = F2_RADFET_GUIApp(app);
            app.aobj.populate();
            selectedRadioButton = app.ButtonGroup.SelectedObject;
            app.aobj.plotVar = selectedRadioButton.Text;
        end

        % Value changed function: CameraDropDown
        function CameraDropDownValueChanged(app, event)
            value = app.CameraDropDown.Value;
            app.aobj.populate();
        end

        % Button pushed function: PlotButton
        function PlotButtonPushed(app, event)
            anyEmptyFields = isnat(app.StartDatePicker.Value) ||...
                isnat(app.EndDatePicker.Value);
            if ~anyEmptyFields
                app.TimeRangeWarning.Visible = false;
                cla(app.UIAxes)
                app.aobj.getArchiveData();
                app.aobj.plotData();
            else
                app.TimeRangeWarning.Visible = true;
            end
        end

        % Value changed function: EndDatePicker, StartDatePicker
        function DatePickerValueChanged(app, event)
            app.aobj.starttime = datenum(app.StartDatePicker.Value);
            app.aobj.endtime = datenum(app.EndDatePicker.Value);
        end

        % Button pushed function: PrinttoeLogButton
        function PrinttoeLogButtonPushed(app, event)
            app.aobj.exportLogbook()
        end

        % Selection changed function: ButtonGroup
        function ButtonGroupSelectionChanged(app, event)
            selectedButton = app.ButtonGroup.SelectedObject;
            switch selectedButton.Text
                case "Radiation"
                    app.RADFETDropDown.Enable = true;
                    app.TOROIDDropDown.Enable = false;
                case "Charge"
                    app.TOROIDDropDown.Enable = true;
                    app.RADFETDropDown.Enable = false;
            end
            app.aobj.plotVar = selectedButton.Text;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 561 610];
            app.UIFigure.Name = 'MATLAB App';

            % Create CameraRebootsandRadiationLabel
            app.CameraRebootsandRadiationLabel = uilabel(app.UIFigure);
            app.CameraRebootsandRadiationLabel.FontSize = 24;
            app.CameraRebootsandRadiationLabel.Position = [111 561 347 30];
            app.CameraRebootsandRadiationLabel.Text = 'Camera Reboots and Radiation';

            % Create ConfigurationPanel
            app.ConfigurationPanel = uipanel(app.UIFigure);
            app.ConfigurationPanel.Title = 'Configuration';
            app.ConfigurationPanel.Position = [21 338 520 213];

            % Create CameraDropDownLabel
            app.CameraDropDownLabel = uilabel(app.ConfigurationPanel);
            app.CameraDropDownLabel.HorizontalAlignment = 'right';
            app.CameraDropDownLabel.Position = [21 151 48 22];
            app.CameraDropDownLabel.Text = 'Camera';

            % Create CameraDropDown
            app.CameraDropDown = uidropdown(app.ConfigurationPanel);
            app.CameraDropDown.Items = {'LBG LFOV', 'DTOTR2', 'PRDMP', 'GAMMA2', 'GAMMA1', 'LFOV'};
            app.CameraDropDown.ValueChangedFcn = createCallbackFcn(app, @CameraDropDownValueChanged, true);
            app.CameraDropDown.Position = [84 151 157 22];
            app.CameraDropDown.Value = 'LBG LFOV';

            % Create StartDateDatePickerLabel
            app.StartDateDatePickerLabel = uilabel(app.ConfigurationPanel);
            app.StartDateDatePickerLabel.HorizontalAlignment = 'right';
            app.StartDateDatePickerLabel.Position = [21 61 60 22];
            app.StartDateDatePickerLabel.Text = 'Start Date';

            % Create StartDatePicker
            app.StartDatePicker = uidatepicker(app.ConfigurationPanel);
            app.StartDatePicker.ValueChangedFcn = createCallbackFcn(app, @DatePickerValueChanged, true);
            app.StartDatePicker.Position = [96 61 145 22];

            % Create RADFETDropDownLabel
            app.RADFETDropDownLabel = uilabel(app.ConfigurationPanel);
            app.RADFETDropDownLabel.HorizontalAlignment = 'right';
            app.RADFETDropDownLabel.Position = [21 101 53 22];
            app.RADFETDropDownLabel.Text = 'RADFET';

            % Create RADFETDropDown
            app.RADFETDropDown = uidropdown(app.ConfigurationPanel);
            app.RADFETDropDown.Items = {'RADF:LI20:1:C:1:DOSE', 'RADF:LI20:1:D:1:DOSE', 'RADF:LI20:2:A:1:DOSE', 'RADF:LI20:2:B:1:DOSE', 'RADF:LI20:2:C:1:DOSE', 'RADF:LI20:2:D:1:DOSE'};
            app.RADFETDropDown.Position = [89 101 162 22];
            app.RADFETDropDown.Value = 'RADF:LI20:1:C:1:DOSE';

            % Create EndDateDatePickerLabel
            app.EndDateDatePickerLabel = uilabel(app.ConfigurationPanel);
            app.EndDateDatePickerLabel.HorizontalAlignment = 'right';
            app.EndDateDatePickerLabel.Position = [271 61 56 22];
            app.EndDateDatePickerLabel.Text = 'End Date';

            % Create EndDatePicker
            app.EndDatePicker = uidatepicker(app.ConfigurationPanel);
            app.EndDatePicker.ValueChangedFcn = createCallbackFcn(app, @DatePickerValueChanged, true);
            app.EndDatePicker.Position = [342 61 159 22];

            % Create PlotButton
            app.PlotButton = uibutton(app.ConfigurationPanel, 'push');
            app.PlotButton.ButtonPushedFcn = createCallbackFcn(app, @PlotButtonPushed, true);
            app.PlotButton.Position = [21 21 100 22];
            app.PlotButton.Text = 'Plot';

            % Create TOROIDDropDownLabel
            app.TOROIDDropDownLabel = uilabel(app.ConfigurationPanel);
            app.TOROIDDropDownLabel.HorizontalAlignment = 'right';
            app.TOROIDDropDownLabel.Position = [271 101 52 22];
            app.TOROIDDropDownLabel.Text = 'TOROID';

            % Create TOROIDDropDown
            app.TOROIDDropDown = uidropdown(app.ConfigurationPanel);
            app.TOROIDDropDown.Items = {'TORO:LI20:3255:TMIT_PC'};
            app.TOROIDDropDown.Enable = 'off';
            app.TOROIDDropDown.Position = [338 101 162 22];
            app.TOROIDDropDown.Value = 'TORO:LI20:3255:TMIT_PC';

            % Create ButtonGroup
            app.ButtonGroup = uibuttongroup(app.ConfigurationPanel);
            app.ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ButtonGroupSelectionChanged, true);
            app.ButtonGroup.BorderType = 'none';
            app.ButtonGroup.Position = [311 143 170 40];

            % Create RadiationButton
            app.RadiationButton = uiradiobutton(app.ButtonGroup);
            app.RadiationButton.Text = 'Radiation';
            app.RadiationButton.Position = [11 9 73 22];
            app.RadiationButton.Value = true;

            % Create ChargeButton
            app.ChargeButton = uiradiobutton(app.ButtonGroup);
            app.ChargeButton.Text = 'Charge';
            app.ChargeButton.Position = [101 9 65 22];

            % Create TimeRangeWarning
            app.TimeRangeWarning = uilabel(app.ConfigurationPanel);
            app.TimeRangeWarning.HorizontalAlignment = 'right';
            app.TimeRangeWarning.FontWeight = 'bold';
            app.TimeRangeWarning.FontColor = [1 0 0];
            app.TimeRangeWarning.Visible = 'off';
            app.TimeRangeWarning.Position = [201 31 115 22];
            app.TimeRangeWarning.Text = 'Select a time range';

            % Create PlotPanel
            app.PlotPanel = uipanel(app.UIFigure);
            app.PlotPanel.Title = 'Plot';
            app.PlotPanel.Position = [22 21 519 310];

            % Create UIAxes
            app.UIAxes = uiaxes(app.PlotPanel);
            title(app.UIAxes, '')
            xlabel(app.UIAxes, '')
            ylabel(app.UIAxes, '')
            app.UIAxes.Position = [11 50 500 230];

            % Create PrinttoeLogButton
            app.PrinttoeLogButton = uibutton(app.PlotPanel, 'push');
            app.PrinttoeLogButton.ButtonPushedFcn = createCallbackFcn(app, @PrinttoeLogButtonPushed, true);
            app.PrinttoeLogButton.BackgroundColor = [0 1 1];
            app.PrinttoeLogButton.Position = [401 18 100 22];
            app.PrinttoeLogButton.Text = 'Print to eLog';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_RADFET_GUI_exported

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