classdef F2_SchottkyScan_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        SchottkyAppUIFigure           matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        LeftPanel                     matlab.ui.container.Panel
        DevicePanel                   matlab.ui.container.Panel
        KlystronDropDownLabel         matlab.ui.control.Label
        KlystronDropDown              matlab.ui.control.DropDown
        DiagnosticDropDownLabel       matlab.ui.control.Label
        DiagnosticDropDown            matlab.ui.control.DropDown
        PhaseToldegEditFieldLabel     matlab.ui.control.Label
        PhaseToldegEditField          matlab.ui.control.NumericEditField
        FC1SwitchLabel                matlab.ui.control.Label
        FC1Switch                     matlab.ui.control.Switch
        GUNPDESEditFieldLabel         matlab.ui.control.Label
        GUNPDESEditField              matlab.ui.control.NumericEditField
        GUNPHASEditFieldLabel         matlab.ui.control.Label
        GUNPHASEditField              matlab.ui.control.NumericEditField
        InStateLampLabel              matlab.ui.control.Label
        InStateLamp                   matlab.ui.control.Lamp
        SetSlowFeedbackPDESEditFieldLabel  matlab.ui.control.Label
        SetSlowFeedbackPDESEditField  matlab.ui.control.NumericEditField
        SlowFeedbackSwitchLabel       matlab.ui.control.Label
        SlowFeedbackSwitch            matlab.ui.control.Switch
        ChargeFeedbackSwitchLabel     matlab.ui.control.Label
        ChargeFeedbackSwitch          matlab.ui.control.Switch
        StateLampLabel                matlab.ui.control.Label
        SFB_Lamp                      matlab.ui.control.Lamp
        StateLamp_2Label              matlab.ui.control.Label
        CFB_Lamp                      matlab.ui.control.Lamp
        ScanPanel                     matlab.ui.container.Panel
        PhaseStartEditFieldLabel      matlab.ui.control.Label
        PhaseStartEditField           matlab.ui.control.NumericEditField
        PhaseEndEditFieldLabel        matlab.ui.control.Label
        PhaseEndEditField             matlab.ui.control.NumericEditField
        StepsEditFieldLabel           matlab.ui.control.Label
        StepsEditField                matlab.ui.control.NumericEditField
        ShotsperstepEditFieldLabel    matlab.ui.control.Label
        ShotsperstepEditField         matlab.ui.control.NumericEditField
        StartButton                   matlab.ui.control.Button
        AbortButton                   matlab.ui.control.Button
        RestoreInitPhaseButton        matlab.ui.control.Button
        StatusPanel                   matlab.ui.container.Panel
        MessagesTextAreaLabel         matlab.ui.control.Label
        MessagesTextArea              matlab.ui.control.TextArea
        SettingPhaseLampLabel         matlab.ui.control.Label
        SettingPhaseLamp              matlab.ui.control.Lamp
        AcquiringDataLampLabel        matlab.ui.control.Label
        AcquiringDataLamp             matlab.ui.control.Lamp
        RightPanel                    matlab.ui.container.Panel
        UIAxes                        matlab.ui.control.UIAxes
        PrinttoeLogButton             matlab.ui.control.Button
        SaveDataCheckBox              matlab.ui.control.CheckBox
        AnalysisPanel                 matlab.ui.container.Panel
        PlotVariableButtonGroup       matlab.ui.container.ButtonGroup
        ChargeButton                  matlab.ui.control.RadioButton
        QEButton                      matlab.ui.control.RadioButton
        SetdesiredphaseCheckBox       matlab.ui.control.CheckBox
        PhaseOffsetEditFieldLabel     matlab.ui.control.Label
        PhaseOffsetEditField          matlab.ui.control.NumericEditField
        ImplementchangetoButtonGroup  matlab.ui.container.ButtonGroup
        LasertimingButton             matlab.ui.control.RadioButton
        GunRFphaseButton              matlab.ui.control.RadioButton
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
            app.SlowFeedbackSwitch.ItemsData = [0 1];
            app.ChargeFeedbackSwitch.ItemsData = [0 1];

        end

        % Value changed function: DiagnosticDropDown
        function DiagnosticDropDownValueChanged(app, event)
            value = app.DiagnosticDropDown.Value;
            if strcmp(value,'FC1')
                app.FC1Switch.Enable = true;
                app.ShotsperstepEditField.Value = 5;
                app.ChargeButton.Enable = true;
                app.QEButton.Enable = true;
            else
                app.FC1Switch.Enable = false;
                app.ShotsperstepEditField.Value = 10;
                app.ChargeButton.Value = true;
                app.ChargeButton.Enable = false;
                app.QEButton.Enable = false;
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

        % Button pushed function: AbortButton
        function AbortButtonPushed(app, event)
            app.aobj.abort_state = true;
        end

        % Value changed function: PhaseEndEditField, 
        % PhaseStartEditField, ShotsperstepEditField, StepsEditField
        function StepsEditFieldValueChanged(app, event)
            app.aobj.getScanParams();
        end

        % Value changed function: SetSlowFeedbackPDESEditField
        function SetSlowFeedbackPDESEditFieldValueChanged(app, event)
            value = app.SetSlowFeedbackPDESEditField.Value;
            app.aobj.SetPhas(value);
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
            app.KlystronDropDown.Items = {'KLYS:LI10:31'};
            app.KlystronDropDown.Position = [82 163 119 22];
            app.KlystronDropDown.Value = 'KLYS:LI10:31';

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
            app.PhaseToldegEditField.Value = 3;

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

            % Create GUNPDESEditFieldLabel
            app.GUNPDESEditFieldLabel = uilabel(app.DevicePanel);
            app.GUNPDESEditFieldLabel.HorizontalAlignment = 'right';
            app.GUNPDESEditFieldLabel.Position = [288 163 68 22];
            app.GUNPDESEditFieldLabel.Text = 'GUN PDES';

            % Create GUNPDESEditField
            app.GUNPDESEditField = uieditfield(app.DevicePanel, 'numeric');
            app.GUNPDESEditField.Position = [359 163 42 22];

            % Create GUNPHASEditFieldLabel
            app.GUNPHASEditFieldLabel = uilabel(app.DevicePanel);
            app.GUNPHASEditFieldLabel.HorizontalAlignment = 'right';
            app.GUNPHASEditFieldLabel.Position = [287 133 68 22];
            app.GUNPHASEditFieldLabel.Text = 'GUN PHAS';

            % Create GUNPHASEditField
            app.GUNPHASEditField = uieditfield(app.DevicePanel, 'numeric');
            app.GUNPHASEditField.Position = [359 133 42 22];

            % Create InStateLampLabel
            app.InStateLampLabel = uilabel(app.DevicePanel);
            app.InStateLampLabel.HorizontalAlignment = 'right';
            app.InStateLampLabel.FontSize = 10;
            app.InStateLampLabel.Position = [10 36 42 22];
            app.InStateLampLabel.Text = 'In State';

            % Create InStateLamp
            app.InStateLamp = uilamp(app.DevicePanel);
            app.InStateLamp.Position = [59 42 10 10];

            % Create SetSlowFeedbackPDESEditFieldLabel
            app.SetSlowFeedbackPDESEditFieldLabel = uilabel(app.DevicePanel);
            app.SetSlowFeedbackPDESEditFieldLabel.HorizontalAlignment = 'right';
            app.SetSlowFeedbackPDESEditFieldLabel.FontWeight = 'bold';
            app.SetSlowFeedbackPDESEditFieldLabel.Enable = 'off';
            app.SetSlowFeedbackPDESEditFieldLabel.Position = [206 102 149 22];
            app.SetSlowFeedbackPDESEditFieldLabel.Text = 'Set Slow Feedback PDES';

            % Create SetSlowFeedbackPDESEditField
            app.SetSlowFeedbackPDESEditField = uieditfield(app.DevicePanel, 'numeric');
            app.SetSlowFeedbackPDESEditField.Limits = [-180 180];
            app.SetSlowFeedbackPDESEditField.ValueChangedFcn = createCallbackFcn(app, @SetSlowFeedbackPDESEditFieldValueChanged, true);
            app.SetSlowFeedbackPDESEditField.FontWeight = 'bold';
            app.SetSlowFeedbackPDESEditField.Enable = 'off';
            app.SetSlowFeedbackPDESEditField.Position = [359 102 42 22];

            % Create SlowFeedbackSwitchLabel
            app.SlowFeedbackSwitchLabel = uilabel(app.DevicePanel);
            app.SlowFeedbackSwitchLabel.HorizontalAlignment = 'center';
            app.SlowFeedbackSwitchLabel.Enable = 'off';
            app.SlowFeedbackSwitchLabel.Position = [309 51 89 22];
            app.SlowFeedbackSwitchLabel.Text = 'Slow Feedback';

            % Create SlowFeedbackSwitch
            app.SlowFeedbackSwitch = uiswitch(app.DevicePanel, 'slider');
            app.SlowFeedbackSwitch.ItemsData = {'0', '1'};
            app.SlowFeedbackSwitch.Enable = 'off';
            app.SlowFeedbackSwitch.FontSize = 10;
            app.SlowFeedbackSwitch.Position = [331 72 45 20];
            app.SlowFeedbackSwitch.Value = '0';

            % Create ChargeFeedbackSwitchLabel
            app.ChargeFeedbackSwitchLabel = uilabel(app.DevicePanel);
            app.ChargeFeedbackSwitchLabel.HorizontalAlignment = 'center';
            app.ChargeFeedbackSwitchLabel.Enable = 'off';
            app.ChargeFeedbackSwitchLabel.Position = [302 6 103 22];
            app.ChargeFeedbackSwitchLabel.Text = 'Charge Feedback';

            % Create ChargeFeedbackSwitch
            app.ChargeFeedbackSwitch = uiswitch(app.DevicePanel, 'slider');
            app.ChargeFeedbackSwitch.Enable = 'off';
            app.ChargeFeedbackSwitch.FontSize = 10;
            app.ChargeFeedbackSwitch.Position = [331 27 45 20];

            % Create StateLampLabel
            app.StateLampLabel = uilabel(app.DevicePanel);
            app.StateLampLabel.HorizontalAlignment = 'right';
            app.StateLampLabel.FontSize = 10;
            app.StateLampLabel.Position = [247 71 30 22];
            app.StateLampLabel.Text = 'State';

            % Create SFB_Lamp
            app.SFB_Lamp = uilamp(app.DevicePanel);
            app.SFB_Lamp.Position = [284 77 10 10];

            % Create StateLamp_2Label
            app.StateLamp_2Label = uilabel(app.DevicePanel);
            app.StateLamp_2Label.HorizontalAlignment = 'right';
            app.StateLamp_2Label.FontSize = 10;
            app.StateLamp_2Label.Position = [248 26 30 22];
            app.StateLamp_2Label.Text = 'State';

            % Create CFB_Lamp
            app.CFB_Lamp = uilamp(app.DevicePanel);
            app.CFB_Lamp.Position = [285 32 10 10];

            % Create ScanPanel
            app.ScanPanel = uipanel(app.LeftPanel);
            app.ScanPanel.Title = 'Scan';
            app.ScanPanel.Position = [8 213 409 141];

            % Create PhaseStartEditFieldLabel
            app.PhaseStartEditFieldLabel = uilabel(app.ScanPanel);
            app.PhaseStartEditFieldLabel.HorizontalAlignment = 'right';
            app.PhaseStartEditFieldLabel.Position = [6 86 68 22];
            app.PhaseStartEditFieldLabel.Text = 'Phase Start';

            % Create PhaseStartEditField
            app.PhaseStartEditField = uieditfield(app.ScanPanel, 'numeric');
            app.PhaseStartEditField.ValueChangedFcn = createCallbackFcn(app, @StepsEditFieldValueChanged, true);
            app.PhaseStartEditField.Position = [83 86 50 22];
            app.PhaseStartEditField.Value = -20;

            % Create PhaseEndEditFieldLabel
            app.PhaseEndEditFieldLabel = uilabel(app.ScanPanel);
            app.PhaseEndEditFieldLabel.HorizontalAlignment = 'right';
            app.PhaseEndEditFieldLabel.Position = [146 86 65 22];
            app.PhaseEndEditFieldLabel.Text = 'Phase End';

            % Create PhaseEndEditField
            app.PhaseEndEditField = uieditfield(app.ScanPanel, 'numeric');
            app.PhaseEndEditField.ValueChangedFcn = createCallbackFcn(app, @StepsEditFieldValueChanged, true);
            app.PhaseEndEditField.Position = [220 86 50 22];
            app.PhaseEndEditField.Value = 40;

            % Create StepsEditFieldLabel
            app.StepsEditFieldLabel = uilabel(app.ScanPanel);
            app.StepsEditFieldLabel.HorizontalAlignment = 'right';
            app.StepsEditFieldLabel.Position = [6 53 36 22];
            app.StepsEditFieldLabel.Text = 'Steps';

            % Create StepsEditField
            app.StepsEditField = uieditfield(app.ScanPanel, 'numeric');
            app.StepsEditField.Limits = [2 200];
            app.StepsEditField.ValueChangedFcn = createCallbackFcn(app, @StepsEditFieldValueChanged, true);
            app.StepsEditField.Position = [98 53 33 22];
            app.StepsEditField.Value = 42;

            % Create ShotsperstepEditFieldLabel
            app.ShotsperstepEditFieldLabel = uilabel(app.ScanPanel);
            app.ShotsperstepEditFieldLabel.HorizontalAlignment = 'right';
            app.ShotsperstepEditFieldLabel.Position = [142 53 83 22];
            app.ShotsperstepEditFieldLabel.Text = 'Shots per step';

            % Create ShotsperstepEditField
            app.ShotsperstepEditField = uieditfield(app.ScanPanel, 'numeric');
            app.ShotsperstepEditField.Limits = [1 100];
            app.ShotsperstepEditField.ValueChangedFcn = createCallbackFcn(app, @StepsEditFieldValueChanged, true);
            app.ShotsperstepEditField.Position = [235 53 33 22];
            app.ShotsperstepEditField.Value = 10;

            % Create StartButton
            app.StartButton = uibutton(app.ScanPanel, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.BackgroundColor = [0.7137 0.949 0.7373];
            app.StartButton.FontSize = 16;
            app.StartButton.FontWeight = 'bold';
            app.StartButton.Position = [298 86 100 28];
            app.StartButton.Text = 'Start';

            % Create AbortButton
            app.AbortButton = uibutton(app.ScanPanel, 'push');
            app.AbortButton.ButtonPushedFcn = createCallbackFcn(app, @AbortButtonPushed, true);
            app.AbortButton.BackgroundColor = [0.949 0.7373 0.7137];
            app.AbortButton.FontSize = 16;
            app.AbortButton.FontWeight = 'bold';
            app.AbortButton.Position = [298 50 100 28];
            app.AbortButton.Text = 'Abort';

            % Create RestoreInitPhaseButton
            app.RestoreInitPhaseButton = uibutton(app.ScanPanel, 'push');
            app.RestoreInitPhaseButton.BackgroundColor = [0.7608 0.7608 0.7608];
            app.RestoreInitPhaseButton.FontSize = 16;
            app.RestoreInitPhaseButton.FontWeight = 'bold';
            app.RestoreInitPhaseButton.Position = [240 12 158 28];
            app.RestoreInitPhaseButton.Text = 'Restore Init. Phase';

            % Create StatusPanel
            app.StatusPanel = uipanel(app.LeftPanel);
            app.StatusPanel.Title = 'Status';
            app.StatusPanel.Position = [8 13 409 184];

            % Create MessagesTextAreaLabel
            app.MessagesTextAreaLabel = uilabel(app.StatusPanel);
            app.MessagesTextAreaLabel.HorizontalAlignment = 'right';
            app.MessagesTextAreaLabel.Position = [6 79 61 22];
            app.MessagesTextAreaLabel.Text = 'Messages';

            % Create MessagesTextArea
            app.MessagesTextArea = uitextarea(app.StatusPanel);
            app.MessagesTextArea.Position = [14 11 385 60];

            % Create SettingPhaseLampLabel
            app.SettingPhaseLampLabel = uilabel(app.StatusPanel);
            app.SettingPhaseLampLabel.HorizontalAlignment = 'right';
            app.SettingPhaseLampLabel.FontSize = 16;
            app.SettingPhaseLampLabel.FontWeight = 'bold';
            app.SettingPhaseLampLabel.Position = [35 121 111 22];
            app.SettingPhaseLampLabel.Text = 'Setting Phase';

            % Create SettingPhaseLamp
            app.SettingPhaseLamp = uilamp(app.StatusPanel);
            app.SettingPhaseLamp.Enable = 'off';
            app.SettingPhaseLamp.Position = [161 121 20 20];
            app.SettingPhaseLamp.Color = [1 1 0];

            % Create AcquiringDataLampLabel
            app.AcquiringDataLampLabel = uilabel(app.StatusPanel);
            app.AcquiringDataLampLabel.HorizontalAlignment = 'right';
            app.AcquiringDataLampLabel.FontSize = 16;
            app.AcquiringDataLampLabel.FontWeight = 'bold';
            app.AcquiringDataLampLabel.Position = [224 121 119 22];
            app.AcquiringDataLampLabel.Text = 'Acquiring Data';

            % Create AcquiringDataLamp
            app.AcquiringDataLamp = uilamp(app.StatusPanel);
            app.AcquiringDataLamp.Enable = 'off';
            app.AcquiringDataLamp.Position = [358 121 20 20];

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.RightPanel);
            title(app.UIAxes, 'Schottky Scan')
            xlabel(app.UIAxes, 'KLYS LI10-3 Phase [deg] ')
            ylabel(app.UIAxes, 'Charge [pC]')
            app.UIAxes.FontSize = 14;
            app.UIAxes.HandleVisibility = 'off';
            app.UIAxes.Position = [7 282 432 314];

            % Create PrinttoeLogButton
            app.PrinttoeLogButton = uibutton(app.RightPanel, 'push');
            app.PrinttoeLogButton.ButtonPushedFcn = createCallbackFcn(app, @PrinttoeLogButtonPushed, true);
            app.PrinttoeLogButton.BackgroundColor = [0.8118 1 0.9922];
            app.PrinttoeLogButton.Position = [339 24 100 23];
            app.PrinttoeLogButton.Text = 'Print to eLog';

            % Create SaveDataCheckBox
            app.SaveDataCheckBox = uicheckbox(app.RightPanel);
            app.SaveDataCheckBox.Text = 'Save Data';
            app.SaveDataCheckBox.Position = [7 24 79 22];
            app.SaveDataCheckBox.Value = true;

            % Create AnalysisPanel
            app.AnalysisPanel = uipanel(app.RightPanel);
            app.AnalysisPanel.Title = 'Analysis';
            app.AnalysisPanel.Position = [7 76 429 169];

            % Create PlotVariableButtonGroup
            app.PlotVariableButtonGroup = uibuttongroup(app.AnalysisPanel);
            app.PlotVariableButtonGroup.Title = 'Plot Variable';
            app.PlotVariableButtonGroup.Position = [185 63 123 75];

            % Create ChargeButton
            app.ChargeButton = uiradiobutton(app.PlotVariableButtonGroup);
            app.ChargeButton.Enable = 'off';
            app.ChargeButton.Text = 'Charge';
            app.ChargeButton.Position = [11 29 63 22];
            app.ChargeButton.Value = true;

            % Create QEButton
            app.QEButton = uiradiobutton(app.PlotVariableButtonGroup);
            app.QEButton.Enable = 'off';
            app.QEButton.Text = 'QE';
            app.QEButton.Position = [11 7 65 22];

            % Create SetdesiredphaseCheckBox
            app.SetdesiredphaseCheckBox = uicheckbox(app.AnalysisPanel);
            app.SetdesiredphaseCheckBox.Text = 'Set desired phase';
            app.SetdesiredphaseCheckBox.Position = [13 37 121 22];
            app.SetdesiredphaseCheckBox.Value = true;

            % Create PhaseOffsetEditFieldLabel
            app.PhaseOffsetEditFieldLabel = uilabel(app.AnalysisPanel);
            app.PhaseOffsetEditFieldLabel.HorizontalAlignment = 'right';
            app.PhaseOffsetEditFieldLabel.Position = [15 7 74 22];
            app.PhaseOffsetEditFieldLabel.Text = 'Phase Offset';

            % Create PhaseOffsetEditField
            app.PhaseOffsetEditField = uieditfield(app.AnalysisPanel, 'numeric');
            app.PhaseOffsetEditField.Limits = [-180 180];
            app.PhaseOffsetEditField.Position = [97 7 34 22];
            app.PhaseOffsetEditField.Value = 30;

            % Create ImplementchangetoButtonGroup
            app.ImplementchangetoButtonGroup = uibuttongroup(app.AnalysisPanel);
            app.ImplementchangetoButtonGroup.Title = 'Implement change to:';
            app.ImplementchangetoButtonGroup.Position = [15 63 155 75];

            % Create LasertimingButton
            app.LasertimingButton = uiradiobutton(app.ImplementchangetoButtonGroup);
            app.LasertimingButton.Tooltip = {'Changes Vitara target time'};
            app.LasertimingButton.Text = 'Laser timing';
            app.LasertimingButton.Position = [11 29 87 22];
            app.LasertimingButton.Value = true;

            % Create GunRFphaseButton
            app.GunRFphaseButton = uiradiobutton(app.ImplementchangetoButtonGroup);
            app.GunRFphaseButton.Tooltip = {'Change 10-3 phase offset correction (leaves gun phase at 0 deg after change)'};
            app.GunRFphaseButton.Text = 'Gun RF phase';
            app.GunRFphaseButton.Position = [11 7 100 22];

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