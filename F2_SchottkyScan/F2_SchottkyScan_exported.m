classdef F2_SchottkyScan_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        SchottkyAppUIFigure         matlab.ui.Figure
        GridLayout                  matlab.ui.container.GridLayout
        LeftPanel                   matlab.ui.container.Panel
        DevicePanel                 matlab.ui.container.Panel
        KlystronDropDownLabel       matlab.ui.control.Label
        KlystronDropDown            matlab.ui.control.DropDown
        DiagnosticDropDownLabel     matlab.ui.control.Label
        DiagnosticDropDown          matlab.ui.control.DropDown
        PhaseToldegEditFieldLabel   matlab.ui.control.Label
        PhaseToldegEditField        matlab.ui.control.NumericEditField
        FC1SwitchLabel              matlab.ui.control.Label
        FC1Switch                   matlab.ui.control.Switch
        KLYSPDESEditFieldLabel      matlab.ui.control.Label
        KLYSPDESEditField           matlab.ui.control.NumericEditField
        KLYSPHASEditFieldLabel      matlab.ui.control.Label
        KLYSPHASEditField           matlab.ui.control.NumericEditField
        ScanPanel                   matlab.ui.container.Panel
        PhaseStartEditFieldLabel    matlab.ui.control.Label
        PhaseStartEditField         matlab.ui.control.NumericEditField
        PhaseEndEditFieldLabel      matlab.ui.control.Label
        PhaseEndEditField           matlab.ui.control.NumericEditField
        StepsEditFieldLabel         matlab.ui.control.Label
        StepsEditField              matlab.ui.control.NumericEditField
        ShotsperstepEditFieldLabel  matlab.ui.control.Label
        ShotsperstepEditField       matlab.ui.control.NumericEditField
        StartButton                 matlab.ui.control.Button
        AbortButton                 matlab.ui.control.Button
        RestoreInitPhaseButton      matlab.ui.control.Button
        MessagesTextAreaLabel       matlab.ui.control.Label
        MessagesTextArea            matlab.ui.control.TextArea
        RightPanel                  matlab.ui.container.Panel
        UIAxes                      matlab.ui.control.UIAxes
        PrinttoeLogButton           matlab.ui.control.Button
        SavingEnabledCheckBox       matlab.ui.control.CheckBox
        AnalysisPanel               matlab.ui.container.Panel
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    
    properties (Access = private)
        aobj % Application helper object
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.aobj=F2_SchottkyScanApp(app);

        end

        % Value changed function: DiagnosticDropDown
        function DiagnosticDropDownValueChanged(app, event)
            value = app.DiagnosticDropDown.Value;
            if strcmp(value,'FC1')
                app.FC1Switch.Enable = true;
                app.ShotsperstepEditField.Value = 5;
            else
                app.FC1Switch.Enable = false;
                app.ShotsperstepEditField.Value = 10;
            end
            app.aobj.getFcupState();
            app.aobj.measDev();
        end

        % Close request function: SchottkyAppUIFigure
        function SchottkyAppUIFigureCloseRequest(app, event)
            try
                app.aobj.end_watch();
            catch
                delete(app);
            end
            delete(app)
        end

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
            app.aobj.startScan();
        end

        % Value changed function: PhaseToldegEditField
        function PhaseToldegEditFieldValueChanged(app, event)
            value = app.PhaseToldegEditField.Value;
            app.aobj.machine_state.phas_tol = value;
        end

        % Value changed function: FC1Switch
        function FC1SwitchValueChanged(app, event)
            disp('hi');
            value = app.FC1Switch.Value;
            app.aobj.setFcupState(value);
            

        end

        % Button pushed function: PrinttoeLogButton
        function PrinttoeLogButtonPushed(app, event)
            app.aobj.print2elog();
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.SchottkyAppUIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {616, 616};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {428, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create SchottkyAppUIFigure and hide until all components are created
            app.SchottkyAppUIFigure = uifigure('Visible', 'off');
            app.SchottkyAppUIFigure.AutoResizeChildren = 'off';
            app.SchottkyAppUIFigure.Position = [100 100 880 616];
            app.SchottkyAppUIFigure.Name = 'Schottky App';
            app.SchottkyAppUIFigure.CloseRequestFcn = createCallbackFcn(app, @SchottkyAppUIFigureCloseRequest, true);
            app.SchottkyAppUIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.SchottkyAppUIFigure);
            app.GridLayout.ColumnWidth = {428, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create DevicePanel
            app.DevicePanel = uipanel(app.LeftPanel);
            app.DevicePanel.Title = 'Device';
            app.DevicePanel.Position = [8 363 409 219];

            % Create KlystronDropDownLabel
            app.KlystronDropDownLabel = uilabel(app.DevicePanel);
            app.KlystronDropDownLabel.HorizontalAlignment = 'right';
            app.KlystronDropDownLabel.Position = [18 163 49 22];
            app.KlystronDropDownLabel.Text = 'Klystron';

            % Create KlystronDropDown
            app.KlystronDropDown = uidropdown(app.DevicePanel);
            app.KlystronDropDown.Items = {'KLYS:LI10:21'};
            app.KlystronDropDown.Position = [82 163 119 22];
            app.KlystronDropDown.Value = 'KLYS:LI10:21';

            % Create DiagnosticDropDownLabel
            app.DiagnosticDropDownLabel = uilabel(app.DevicePanel);
            app.DiagnosticDropDownLabel.HorizontalAlignment = 'right';
            app.DiagnosticDropDownLabel.Position = [20 75 63 22];
            app.DiagnosticDropDownLabel.Text = 'Diagnostic';

            % Create DiagnosticDropDown
            app.DiagnosticDropDown = uidropdown(app.DevicePanel);
            app.DiagnosticDropDown.Items = {'BPM 221', 'FC1'};
            app.DiagnosticDropDown.ValueChangedFcn = createCallbackFcn(app, @DiagnosticDropDownValueChanged, true);
            app.DiagnosticDropDown.Position = [98 75 103 22];
            app.DiagnosticDropDown.Value = 'BPM 221';

            % Create PhaseToldegEditFieldLabel
            app.PhaseToldegEditFieldLabel = uilabel(app.DevicePanel);
            app.PhaseToldegEditFieldLabel.HorizontalAlignment = 'right';
            app.PhaseToldegEditFieldLabel.Position = [18 133 92 22];
            app.PhaseToldegEditFieldLabel.Text = 'Phase Tol. [deg]';

            % Create PhaseToldegEditField
            app.PhaseToldegEditField = uieditfield(app.DevicePanel, 'numeric');
            app.PhaseToldegEditField.Limits = [0 180];
            app.PhaseToldegEditField.ValueChangedFcn = createCallbackFcn(app, @PhaseToldegEditFieldValueChanged, true);
            app.PhaseToldegEditField.Position = [125 133 73 22];
            app.PhaseToldegEditField.Value = 0.2;

            % Create FC1SwitchLabel
            app.FC1SwitchLabel = uilabel(app.DevicePanel);
            app.FC1SwitchLabel.HorizontalAlignment = 'center';
            app.FC1SwitchLabel.Position = [111 15 28 22];
            app.FC1SwitchLabel.Text = 'FC1';

            % Create FC1Switch
            app.FC1Switch = uiswitch(app.DevicePanel, 'slider');
            app.FC1Switch.Items = {'Out', 'In'};
            app.FC1Switch.ValueChangedFcn = createCallbackFcn(app, @FC1SwitchValueChanged, true);
            app.FC1Switch.Enable = 'off';
            app.FC1Switch.Position = [107 35 45 20];
            app.FC1Switch.Value = 'Out';

            % Create KLYSPDESEditFieldLabel
            app.KLYSPDESEditFieldLabel = uilabel(app.DevicePanel);
            app.KLYSPDESEditFieldLabel.HorizontalAlignment = 'right';
            app.KLYSPDESEditFieldLabel.Position = [216 163 72 22];
            app.KLYSPDESEditFieldLabel.Text = 'KLYS PDES';

            % Create KLYSPDESEditField
            app.KLYSPDESEditField = uieditfield(app.DevicePanel, 'numeric');
            app.KLYSPDESEditField.Position = [298 163 64 22];

            % Create KLYSPHASEditFieldLabel
            app.KLYSPHASEditFieldLabel = uilabel(app.DevicePanel);
            app.KLYSPHASEditFieldLabel.HorizontalAlignment = 'right';
            app.KLYSPHASEditFieldLabel.Position = [216 133 72 22];
            app.KLYSPHASEditFieldLabel.Text = 'KLYS PHAS';

            % Create KLYSPHASEditField
            app.KLYSPHASEditField = uieditfield(app.DevicePanel, 'numeric');
            app.KLYSPHASEditField.Position = [298 133 64 22];

            % Create ScanPanel
            app.ScanPanel = uipanel(app.LeftPanel);
            app.ScanPanel.Title = 'Scan';
            app.ScanPanel.Position = [8 126 413 203];

            % Create PhaseStartEditFieldLabel
            app.PhaseStartEditFieldLabel = uilabel(app.ScanPanel);
            app.PhaseStartEditFieldLabel.HorizontalAlignment = 'right';
            app.PhaseStartEditFieldLabel.Position = [6 148 68 22];
            app.PhaseStartEditFieldLabel.Text = 'Phase Start';

            % Create PhaseStartEditField
            app.PhaseStartEditField = uieditfield(app.ScanPanel, 'numeric');
            app.PhaseStartEditField.Position = [83 148 50 22];

            % Create PhaseEndEditFieldLabel
            app.PhaseEndEditFieldLabel = uilabel(app.ScanPanel);
            app.PhaseEndEditFieldLabel.HorizontalAlignment = 'right';
            app.PhaseEndEditFieldLabel.Position = [146 148 65 22];
            app.PhaseEndEditFieldLabel.Text = 'Phase End';

            % Create PhaseEndEditField
            app.PhaseEndEditField = uieditfield(app.ScanPanel, 'numeric');
            app.PhaseEndEditField.Position = [220 148 50 22];
            app.PhaseEndEditField.Value = 150;

            % Create StepsEditFieldLabel
            app.StepsEditFieldLabel = uilabel(app.ScanPanel);
            app.StepsEditFieldLabel.HorizontalAlignment = 'right';
            app.StepsEditFieldLabel.Position = [6 115 36 22];
            app.StepsEditFieldLabel.Text = 'Steps';

            % Create StepsEditField
            app.StepsEditField = uieditfield(app.ScanPanel, 'numeric');
            app.StepsEditField.Limits = [2 100];
            app.StepsEditField.Position = [98 115 33 22];
            app.StepsEditField.Value = 21;

            % Create ShotsperstepEditFieldLabel
            app.ShotsperstepEditFieldLabel = uilabel(app.ScanPanel);
            app.ShotsperstepEditFieldLabel.HorizontalAlignment = 'right';
            app.ShotsperstepEditFieldLabel.Position = [142 115 83 22];
            app.ShotsperstepEditFieldLabel.Text = 'Shots per step';

            % Create ShotsperstepEditField
            app.ShotsperstepEditField = uieditfield(app.ScanPanel, 'numeric');
            app.ShotsperstepEditField.Limits = [1 100];
            app.ShotsperstepEditField.Position = [235 115 33 22];
            app.ShotsperstepEditField.Value = 10;

            % Create StartButton
            app.StartButton = uibutton(app.ScanPanel, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.BackgroundColor = [0.7137 0.949 0.7373];
            app.StartButton.FontSize = 16;
            app.StartButton.FontWeight = 'bold';
            app.StartButton.Position = [10 73 100 28];
            app.StartButton.Text = 'Start';

            % Create AbortButton
            app.AbortButton = uibutton(app.ScanPanel, 'push');
            app.AbortButton.BackgroundColor = [0.949 0.7373 0.7137];
            app.AbortButton.FontSize = 16;
            app.AbortButton.FontWeight = 'bold';
            app.AbortButton.Position = [10 33 100 28];
            app.AbortButton.Text = 'Abort';

            % Create RestoreInitPhaseButton
            app.RestoreInitPhaseButton = uibutton(app.ScanPanel, 'push');
            app.RestoreInitPhaseButton.BackgroundColor = [0.7608 0.7608 0.7608];
            app.RestoreInitPhaseButton.FontSize = 16;
            app.RestoreInitPhaseButton.FontWeight = 'bold';
            app.RestoreInitPhaseButton.Position = [251 6 158 28];
            app.RestoreInitPhaseButton.Text = 'Restore Init. Phase';

            % Create MessagesTextAreaLabel
            app.MessagesTextAreaLabel = uilabel(app.LeftPanel);
            app.MessagesTextAreaLabel.HorizontalAlignment = 'right';
            app.MessagesTextAreaLabel.Position = [8 92 61 22];
            app.MessagesTextAreaLabel.Text = 'Messages';

            % Create MessagesTextArea
            app.MessagesTextArea = uitextarea(app.LeftPanel);
            app.MessagesTextArea.Position = [16 24 393 60];

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.RightPanel);
            title(app.UIAxes, 'Schottky Scan')
            xlabel(app.UIAxes, 'KLYS LI10 2-1 Phase [deg] ')
            ylabel(app.UIAxes, 'Charge')
            app.UIAxes.Position = [7 282 432 314];

            % Create PrinttoeLogButton
            app.PrinttoeLogButton = uibutton(app.RightPanel, 'push');
            app.PrinttoeLogButton.ButtonPushedFcn = createCallbackFcn(app, @PrinttoeLogButtonPushed, true);
            app.PrinttoeLogButton.BackgroundColor = [0.8118 1 0.9922];
            app.PrinttoeLogButton.Position = [339 24 100 23];
            app.PrinttoeLogButton.Text = 'Print to eLog';

            % Create SavingEnabledCheckBox
            app.SavingEnabledCheckBox = uicheckbox(app.RightPanel);
            app.SavingEnabledCheckBox.Text = 'Saving Enabled';
            app.SavingEnabledCheckBox.Position = [7 24 109 22];
            app.SavingEnabledCheckBox.Value = true;

            % Create AnalysisPanel
            app.AnalysisPanel = uipanel(app.RightPanel);
            app.AnalysisPanel.Title = 'Analysis';
            app.AnalysisPanel.Position = [7 76 429 169];

            % Show the figure after all components are created
            app.SchottkyAppUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_SchottkyScan_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.SchottkyAppUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.SchottkyAppUIFigure)
        end
    end
end