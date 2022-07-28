classdef F2_SpecLine_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        SpectrometerParametersPanel  matlab.ui.container.Panel
        EnergyGeVEditFieldLabel      matlab.ui.control.Label
        EnergyEditField              matlab.ui.control.NumericEditField
        ZObjectmEditFieldLabel       matlab.ui.control.Label
        ZObjectEditField             matlab.ui.control.NumericEditField
        ZImagemEditFieldLabel        matlab.ui.control.Label
        ZImageEditField              matlab.ui.control.NumericEditField
        M12EditFieldLabel            matlab.ui.control.Label
        M12EditField                 matlab.ui.control.NumericEditField
        M34EditFieldLabel            matlab.ui.control.Label
        M34EditField                 matlab.ui.control.NumericEditField
        CalcButton                   matlab.ui.control.Button
        MagnetValuesPanel            matlab.ui.container.Panel
        Q0DLGPS3141EditFieldLabel    matlab.ui.control.Label
        Q0DBDESEditField             matlab.ui.control.NumericEditField
        Q0DBACTField                 matlab.ui.control.NumericEditField
        BDESLabel                    matlab.ui.control.Label
        BACTLabel                    matlab.ui.control.Label
        Q1DLGPS3261EditFieldLabel    matlab.ui.control.Label
        Q1DBDESEditField             matlab.ui.control.NumericEditField
        Q1DBACTField                 matlab.ui.control.NumericEditField
        Q2DLGPS3091EditFieldLabel    matlab.ui.control.Label
        Q2DBDESEditField             matlab.ui.control.NumericEditField
        Q2DBACTField                 matlab.ui.control.NumericEditField
        TrimButton                   matlab.ui.control.Button
    end

    
    properties (Access = private)
        aobj % Description
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.aobj=F2_SpecLineApp(app);
        end

        % Button pushed function: CalcButton
        function CalcButtonPushed(app, event)
            app.aobj.CalcAndTrim();
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 521 254];
            app.UIFigure.Name = 'MATLAB App';

            % Create SpectrometerParametersPanel
            app.SpectrometerParametersPanel = uipanel(app.UIFigure);
            app.SpectrometerParametersPanel.Title = 'Spectrometer Parameters';
            app.SpectrometerParametersPanel.Position = [2 5 260 250];

            % Create EnergyGeVEditFieldLabel
            app.EnergyGeVEditFieldLabel = uilabel(app.SpectrometerParametersPanel);
            app.EnergyGeVEditFieldLabel.HorizontalAlignment = 'right';
            app.EnergyGeVEditFieldLabel.Position = [42 195 79 22];
            app.EnergyGeVEditFieldLabel.Text = 'Energy (GeV)';

            % Create EnergyEditField
            app.EnergyEditField = uieditfield(app.SpectrometerParametersPanel, 'numeric');
            app.EnergyEditField.ValueDisplayFormat = '%11.4f';
            app.EnergyEditField.Position = [146 195 73 22];

            % Create ZObjectmEditFieldLabel
            app.ZObjectmEditFieldLabel = uilabel(app.SpectrometerParametersPanel);
            app.ZObjectmEditFieldLabel.HorizontalAlignment = 'right';
            app.ZObjectmEditFieldLabel.Position = [50 160 71 22];
            app.ZObjectmEditFieldLabel.Text = 'Z Object (m)';

            % Create ZObjectEditField
            app.ZObjectEditField = uieditfield(app.SpectrometerParametersPanel, 'numeric');
            app.ZObjectEditField.ValueDisplayFormat = '%11.4f';
            app.ZObjectEditField.Position = [146 160 73 22];

            % Create ZImagemEditFieldLabel
            app.ZImagemEditFieldLabel = uilabel(app.SpectrometerParametersPanel);
            app.ZImagemEditFieldLabel.HorizontalAlignment = 'right';
            app.ZImagemEditFieldLabel.Position = [51 126 70 22];
            app.ZImagemEditFieldLabel.Text = 'Z Image (m)';

            % Create ZImageEditField
            app.ZImageEditField = uieditfield(app.SpectrometerParametersPanel, 'numeric');
            app.ZImageEditField.ValueDisplayFormat = '%11.4f';
            app.ZImageEditField.Position = [146 126 73 22];

            % Create M12EditFieldLabel
            app.M12EditFieldLabel = uilabel(app.SpectrometerParametersPanel);
            app.M12EditFieldLabel.HorizontalAlignment = 'right';
            app.M12EditFieldLabel.Position = [92 92 29 22];
            app.M12EditFieldLabel.Text = 'M12';

            % Create M12EditField
            app.M12EditField = uieditfield(app.SpectrometerParametersPanel, 'numeric');
            app.M12EditField.ValueDisplayFormat = '%11.4f';
            app.M12EditField.Position = [146 92 73 22];

            % Create M34EditFieldLabel
            app.M34EditFieldLabel = uilabel(app.SpectrometerParametersPanel);
            app.M34EditFieldLabel.HorizontalAlignment = 'right';
            app.M34EditFieldLabel.Position = [92 58 29 22];
            app.M34EditFieldLabel.Text = 'M34';

            % Create M34EditField
            app.M34EditField = uieditfield(app.SpectrometerParametersPanel, 'numeric');
            app.M34EditField.ValueDisplayFormat = '%11.4f';
            app.M34EditField.Position = [146 58 73 22];

            % Create CalcButton
            app.CalcButton = uibutton(app.SpectrometerParametersPanel, 'push');
            app.CalcButton.ButtonPushedFcn = createCallbackFcn(app, @CalcButtonPushed, true);
            app.CalcButton.BackgroundColor = [0 0.4471 0.7412];
            app.CalcButton.FontSize = 14;
            app.CalcButton.FontWeight = 'bold';
            app.CalcButton.FontColor = [1 1 1];
            app.CalcButton.Position = [76 18 143 24];
            app.CalcButton.Text = 'Calculate and Trim';

            % Create MagnetValuesPanel
            app.MagnetValuesPanel = uipanel(app.UIFigure);
            app.MagnetValuesPanel.Title = 'Magnet Values';
            app.MagnetValuesPanel.Position = [262 5 260 250];

            % Create Q0DLGPS3141EditFieldLabel
            app.Q0DLGPS3141EditFieldLabel = uilabel(app.MagnetValuesPanel);
            app.Q0DLGPS3141EditFieldLabel.HorizontalAlignment = 'right';
            app.Q0DLGPS3141EditFieldLabel.Position = [9 160 104 22];
            app.Q0DLGPS3141EditFieldLabel.Text = 'Q0D (LGPS 3141)';

            % Create Q0DBDESEditField
            app.Q0DBDESEditField = uieditfield(app.MagnetValuesPanel, 'numeric');
            app.Q0DBDESEditField.Position = [121 160 47 22];

            % Create Q0DBACTField
            app.Q0DBACTField = uieditfield(app.MagnetValuesPanel, 'numeric');
            app.Q0DBACTField.Editable = 'off';
            app.Q0DBACTField.Position = [189 160 45 22];

            % Create BDESLabel
            app.BDESLabel = uilabel(app.MagnetValuesPanel);
            app.BDESLabel.FontWeight = 'bold';
            app.BDESLabel.Position = [128 195 39 22];
            app.BDESLabel.Text = 'BDES';

            % Create BACTLabel
            app.BACTLabel = uilabel(app.MagnetValuesPanel);
            app.BACTLabel.FontWeight = 'bold';
            app.BACTLabel.Position = [193 195 39 22];
            app.BACTLabel.Text = 'BACT';

            % Create Q1DLGPS3261EditFieldLabel
            app.Q1DLGPS3261EditFieldLabel = uilabel(app.MagnetValuesPanel);
            app.Q1DLGPS3261EditFieldLabel.HorizontalAlignment = 'right';
            app.Q1DLGPS3261EditFieldLabel.Position = [9 126 104 22];
            app.Q1DLGPS3261EditFieldLabel.Text = 'Q1D (LGPS 3261)';

            % Create Q1DBDESEditField
            app.Q1DBDESEditField = uieditfield(app.MagnetValuesPanel, 'numeric');
            app.Q1DBDESEditField.Position = [121 126 47 22];

            % Create Q1DBACTField
            app.Q1DBACTField = uieditfield(app.MagnetValuesPanel, 'numeric');
            app.Q1DBACTField.Editable = 'off';
            app.Q1DBACTField.Position = [189 126 45 22];

            % Create Q2DLGPS3091EditFieldLabel
            app.Q2DLGPS3091EditFieldLabel = uilabel(app.MagnetValuesPanel);
            app.Q2DLGPS3091EditFieldLabel.HorizontalAlignment = 'right';
            app.Q2DLGPS3091EditFieldLabel.Position = [9 92 104 22];
            app.Q2DLGPS3091EditFieldLabel.Text = 'Q2D (LGPS 3091)';

            % Create Q2DBDESEditField
            app.Q2DBDESEditField = uieditfield(app.MagnetValuesPanel, 'numeric');
            app.Q2DBDESEditField.Position = [121 92 47 22];

            % Create Q2DBACTField
            app.Q2DBACTField = uieditfield(app.MagnetValuesPanel, 'numeric');
            app.Q2DBACTField.Editable = 'off';
            app.Q2DBACTField.Position = [189 92 45 22];

            % Create TrimButton
            app.TrimButton = uibutton(app.MagnetValuesPanel, 'push');
            app.TrimButton.BackgroundColor = [0.6353 0.0784 0.1843];
            app.TrimButton.FontSize = 14;
            app.TrimButton.FontWeight = 'bold';
            app.TrimButton.FontColor = [1 1 1];
            app.TrimButton.Position = [182 18 50 24];
            app.TrimButton.Text = 'Trim';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_SpecLine_exported

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