classdef F2_RADFET_GUI_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        CameraDropDownLabel             matlab.ui.control.Label
        CameraDropDown                  matlab.ui.control.DropDown
        RADFETDropDownLabel             matlab.ui.control.Label
        RADFETDropDown                  matlab.ui.control.DropDown
        StartDateDatePickerLabel        matlab.ui.control.Label
        StartDatePicker                 matlab.ui.control.DatePicker
        EndDateDatePickerLabel          matlab.ui.control.Label
        EndDatePicker                   matlab.ui.control.DatePicker
        UIAxes                          matlab.ui.control.UIAxes
        PrinttoeLogButton               matlab.ui.control.Button
        PlotButton                      matlab.ui.control.Button
        CameraRebootsandRadiationLabel  matlab.ui.control.Label
        TimeRangeWarning                matlab.ui.control.Label
    end

    
    properties (Access = private)
        aobj % app support object
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.aobj = F2_RADFET_GUIApp(app);
        end

        % Value changed function: CameraDropDown
        function CameraDropDownValueChanged(app, event)
            value = app.CameraDropDown.Value;
            app.aobj.populateRADFET();
        end

        % Button pushed function: PlotButton
        function PlotButtonPushed(app, event)
            anyEmptyFields = isnat(app.StartDatePicker.Value) ||...
                isnat(app.EndDatePicker.Value);
            if ~anyEmptyFields
                app.TimeRangeWarning.Visible = false;
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
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 562 561];
            app.UIFigure.Name = 'MATLAB App';

            % Create CameraDropDownLabel
            app.CameraDropDownLabel = uilabel(app.UIFigure);
            app.CameraDropDownLabel.HorizontalAlignment = 'right';
            app.CameraDropDownLabel.Position = [31 460 48 22];
            app.CameraDropDownLabel.Text = 'Camera';

            % Create CameraDropDown
            app.CameraDropDown = uidropdown(app.UIFigure);
            app.CameraDropDown.Items = {'LBG LFOV', 'DTOTR2', 'PRDMP', 'GAMMA2', 'GAMMA1', 'LFOV'};
            app.CameraDropDown.ValueChangedFcn = createCallbackFcn(app, @CameraDropDownValueChanged, true);
            app.CameraDropDown.Position = [94 460 157 22];
            app.CameraDropDown.Value = 'LBG LFOV';

            % Create RADFETDropDownLabel
            app.RADFETDropDownLabel = uilabel(app.UIFigure);
            app.RADFETDropDownLabel.HorizontalAlignment = 'right';
            app.RADFETDropDownLabel.Position = [301 460 53 22];
            app.RADFETDropDownLabel.Text = 'RADFET';

            % Create RADFETDropDown
            app.RADFETDropDown = uidropdown(app.UIFigure);
            app.RADFETDropDown.Items = {'RADF:LI20:1:C:1:DOSE', 'RADF:LI20:1:D:1:DOSE', 'RADF:LI20:2:A:1:DOSE', 'RADF:LI20:2:B:1:DOSE', 'RADF:LI20:2:C:1:DOSE', 'RADF:LI20:2:D:1:DOSE'};
            app.RADFETDropDown.Position = [369 460 162 22];
            app.RADFETDropDown.Value = 'RADF:LI20:1:C:1:DOSE';

            % Create StartDateDatePickerLabel
            app.StartDateDatePickerLabel = uilabel(app.UIFigure);
            app.StartDateDatePickerLabel.HorizontalAlignment = 'right';
            app.StartDateDatePickerLabel.Position = [31 420 60 22];
            app.StartDateDatePickerLabel.Text = 'Start Date';

            % Create StartDatePicker
            app.StartDatePicker = uidatepicker(app.UIFigure);
            app.StartDatePicker.ValueChangedFcn = createCallbackFcn(app, @DatePickerValueChanged, true);
            app.StartDatePicker.Position = [106 420 145 22];

            % Create EndDateDatePickerLabel
            app.EndDateDatePickerLabel = uilabel(app.UIFigure);
            app.EndDateDatePickerLabel.HorizontalAlignment = 'right';
            app.EndDateDatePickerLabel.Position = [301 420 56 22];
            app.EndDateDatePickerLabel.Text = 'End Date';

            % Create EndDatePicker
            app.EndDatePicker = uidatepicker(app.UIFigure);
            app.EndDatePicker.ValueChangedFcn = createCallbackFcn(app, @DatePickerValueChanged, true);
            app.EndDatePicker.Position = [372 420 159 22];

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, '')
            xlabel(app.UIAxes, '')
            ylabel(app.UIAxes, '')
            app.UIAxes.Position = [31 62 500 260];

            % Create PrinttoeLogButton
            app.PrinttoeLogButton = uibutton(app.UIFigure, 'push');
            app.PrinttoeLogButton.ButtonPushedFcn = createCallbackFcn(app, @PrinttoeLogButtonPushed, true);
            app.PrinttoeLogButton.BackgroundColor = [0 1 1];
            app.PrinttoeLogButton.Position = [381 20 100 22];
            app.PrinttoeLogButton.Text = 'Print to eLog';

            % Create PlotButton
            app.PlotButton = uibutton(app.UIFigure, 'push');
            app.PlotButton.ButtonPushedFcn = createCallbackFcn(app, @PlotButtonPushed, true);
            app.PlotButton.Position = [31 350 100 22];
            app.PlotButton.Text = 'Plot';

            % Create CameraRebootsandRadiationLabel
            app.CameraRebootsandRadiationLabel = uilabel(app.UIFigure);
            app.CameraRebootsandRadiationLabel.FontSize = 24;
            app.CameraRebootsandRadiationLabel.Position = [111 512 347 30];
            app.CameraRebootsandRadiationLabel.Text = 'Camera Reboots and Radiation';

            % Create TimeRangeWarning
            app.TimeRangeWarning = uilabel(app.UIFigure);
            app.TimeRangeWarning.HorizontalAlignment = 'right';
            app.TimeRangeWarning.FontWeight = 'bold';
            app.TimeRangeWarning.FontColor = [1 0 0];
            app.TimeRangeWarning.Visible = 'off';
            app.TimeRangeWarning.Position = [35 390 115 22];
            app.TimeRangeWarning.Text = 'Select a time range';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_RADFET_GUI

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