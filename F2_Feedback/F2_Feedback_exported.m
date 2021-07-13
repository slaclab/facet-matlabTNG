classdef F2_Feedback_exported < matlab.apps.AppBase

  % Properties that correspond to app components
  properties (Access = public)
    FACETIIFeedbackUIFigure       matlab.ui.Figure
    StripchartsMenu               matlab.ui.container.Menu
    DL1EnergyMenu                 matlab.ui.container.Menu
    BC14EnergyMenu                matlab.ui.container.Menu
    SettingsMenu                  matlab.ui.container.Menu
    DL1EnergyFeedbackMenu         matlab.ui.container.Menu
    BC14EnergyFeedbackMenu        matlab.ui.container.Menu
    DisplayEnergyUnitsMenu        matlab.ui.container.Menu
    DL1EnergyFeedbackPanel        matlab.ui.container.Panel
    SetpointEditField             matlab.ui.control.NumericEditField
    mmLabel_5                     matlab.ui.control.Label
    Gauge                         matlab.ui.control.LinearGauge
    StatusLamp                    matlab.ui.control.Lamp
    Switch                        matlab.ui.control.Switch
    Gauge_3                       matlab.ui.control.LinearGauge
    KLYSIN1041ADESLabel           matlab.ui.control.Label
    BPMSIN10731X1HLabel           matlab.ui.control.Label
    EditField                     matlab.ui.control.NumericEditField
    EditField_2                   matlab.ui.control.NumericEditField
    NotRunningButton              matlab.ui.control.Button
    BC14EnergyFeedbackPanel       matlab.ui.container.Panel
    SetpointEditField_2           matlab.ui.control.NumericEditField
    mmLabel_4                     matlab.ui.control.Label
    Switch_2                      matlab.ui.control.Switch
    StatusLamp_2                  matlab.ui.control.Lamp
    BC14KLYS1Label                matlab.ui.control.Label
    BC14KLYS2Label                matlab.ui.control.Label
    BPMSLI14801X1HLabel           matlab.ui.control.Label
    EditField_5                   matlab.ui.control.NumericEditField
    EditField_6                   matlab.ui.control.NumericEditField
    NotRunningButton_5            matlab.ui.control.Button
    Gauge_16                      matlab.ui.control.NinetyDegreeGauge
    Gauge_17                      matlab.ui.control.NinetyDegreeGauge
    Gauge_6                       matlab.ui.control.LinearGauge
    BC20EnergyFeedbackPanel       matlab.ui.container.Panel
    SetpointEditField_4           matlab.ui.control.NumericEditField
    mmLabel_7                     matlab.ui.control.Label
    Switch_4                      matlab.ui.control.Switch
    StatusLamp_4                  matlab.ui.control.Lamp
    Gauge_7                       matlab.ui.control.LinearGauge
    BPMSLI202445X1HLabel          matlab.ui.control.Label
    EditField_8                   matlab.ui.control.NumericEditField
    EditField_9                   matlab.ui.control.NumericEditField
    NotRunningButton_6            matlab.ui.control.Button
    BC14KLYS1Label_2              matlab.ui.control.Label
    BC14KLYS2Label_2              matlab.ui.control.Label
    Gauge_18                      matlab.ui.control.NinetyDegreeGauge
    Gauge_19                      matlab.ui.control.NinetyDegreeGauge
    BC11EnergyFeedbackPanel       matlab.ui.container.Panel
    SetpointEditField_5           matlab.ui.control.NumericEditField
    mmLabel_6                     matlab.ui.control.Label
    Gauge_8                       matlab.ui.control.LinearGauge
    StatusLamp_5                  matlab.ui.control.Lamp
    Switch_5                      matlab.ui.control.Switch
    Gauge_9                       matlab.ui.control.LinearGauge
    L1AMPLLabel                   matlab.ui.control.Label
    BPMSIN10731X1HLabel_3         matlab.ui.control.Label
    EditField_11                  matlab.ui.control.NumericEditField
    EditField_12                  matlab.ui.control.NumericEditField
    NotRunningButton_3            matlab.ui.control.Button
    BC11BunchLengthFeedbackPanel  matlab.ui.container.Panel
    SetpointEditField_6           matlab.ui.control.NumericEditField
    mmLabel_2                     matlab.ui.control.Label
    Gauge_10                      matlab.ui.control.LinearGauge
    StatusLamp_6                  matlab.ui.control.Lamp
    Switch_6                      matlab.ui.control.Switch
    Gauge_11                      matlab.ui.control.LinearGauge
    L1PHASELabel                  matlab.ui.control.Label
    BL11359Label_2                matlab.ui.control.Label
    EditField_13                  matlab.ui.control.NumericEditField
    EditField_14                  matlab.ui.control.NumericEditField
    NotRunningButton_4            matlab.ui.control.Button
    BC14BunchLengthFeedbackPanel  matlab.ui.container.Panel
    SetpointEditField_7           matlab.ui.control.NumericEditField
    mmLabel_3                     matlab.ui.control.Label
    Gauge_12                      matlab.ui.control.LinearGauge
    Switch_7                      matlab.ui.control.Switch
    Gauge_13                      matlab.ui.control.LinearGauge
    L2PHASELabel                  matlab.ui.control.Label
    BL11359Label                  matlab.ui.control.Label
    EditField_15                  matlab.ui.control.NumericEditField
    EditField_16                  matlab.ui.control.NumericEditField
    StatusLamp_7                  matlab.ui.control.Lamp
    NotRunningButton_7            matlab.ui.control.Button
  end

  
  properties (Access = public)
    aobj % Helper App object
  end
  

  % Callbacks that handle component events
  methods (Access = private)

    % Code that executes after component creation
    function startupFcn(app, arg1)
      app.aobj = F2_FeedbackApp(app) ; % generate helper object
    end

    % Value changed function: Switch
    function SwitchValueChanged(app, event)
      value = string(app.Switch.Value) == "On" ;
      caput(app.aobj.pvs.FeedbackEnable,double(bitset(app.aobj.Enabled,1,value)));
    end

    % Menu selected function: DL1EnergyMenu
    function DL1EnergyMenuSelected(app, event)
      !StripTool /u1/facet/tools/StripTool/config/FB_DL1_E.stp &
    end

    % Menu selected function: DL1EnergyFeedbackMenu
    function DL1EnergyFeedbackMenuSelected(app, event)
      app.DL1EnergyFeedbackMenu.Enable = false ;
      DL1E_Settings(app.aobj);
    end

    % Value changed function: SetpointEditField
    function SetpointEditFieldValueChanged(app, event)
      value = app.SetpointEditField.Value;
      if app.aobj.GuiEnergyUnits
        value = (value - app.aobj.SetpointConversion{1}(1)) / app.aobj.SetpointConversion{1}(2) ;
      end
      caput(app.aobj.pvs.DL1E_Offset,value) ;
      app.aobj.SetpointOffsets(1) = value ;
    end

    % Menu selected function: DisplayEnergyUnitsMenu
    function DisplayEnergyUnitsMenuSelected(app, event)
      if app.DisplayEnergyUnitsMenu.Checked
        app.DisplayEnergyUnitsMenu.Checked = false ;
        app.aobj.GuiEnergyUnits = false ;
      else
        app.DisplayEnergyUnitsMenu.Checked = true ;
        app.aobj.GuiEnergyUnits = true ;
      end
      notify(app.aobj,'PVUpdated');
    end

    % Close request function: FACETIIFeedbackUIFigure
    function FACETIIFeedbackUIFigureCloseRequest(app, event)
      app.aobj.shutdown;
      delete(app)
    end

    % Value changed function: SetpointEditField_2
    function SetpointEditField_2ValueChanged(app, event)
      value = app.SetpointEditField_2.Value;
      if app.aobj.GuiEnergyUnits
        value = (value - app.aobj.SetpointConversion{2}(1)) / app.aobj.SetpointConversion{2}(2) ;
      end
      caput(app.aobj.pvs.BC14E_Offset,value) ;
      app.aobj.SetpointOffsets(1) = value ;
    end

    % Menu selected function: BC14EnergyMenu
    function BC14EnergyMenuSelected(app, event)
      !StripTool /u1/facet/tools/StripTool/config/FB_BC14_E.stp &
    end

    % Menu selected function: BC14EnergyFeedbackMenu
    function BC14EnergyFeedbackMenuSelected(app, event)
      app.BC14EnergyFeedbackMenu.Enable = false ;
      BC14E_Settings(app.aobj);
    end

    % Value changed function: Switch_2
    function Switch_2ValueChanged(app, event)
      value = string(app.Switch_2.Value) == "On" ;
      caput(app.aobj.pvs.FeedbackEnable,double(bitset(app.aobj.Enabled,2,value)));
    end
  end

  % Component initialization
  methods (Access = private)

    % Create UIFigure and components
    function createComponents(app)

      % Create FACETIIFeedbackUIFigure and hide until all components are created
      app.FACETIIFeedbackUIFigure = uifigure('Visible', 'off');
      app.FACETIIFeedbackUIFigure.Position = [100 100 983 537];
      app.FACETIIFeedbackUIFigure.Name = 'FACET-II Feedback';
      app.FACETIIFeedbackUIFigure.CloseRequestFcn = createCallbackFcn(app, @FACETIIFeedbackUIFigureCloseRequest, true);

      % Create StripchartsMenu
      app.StripchartsMenu = uimenu(app.FACETIIFeedbackUIFigure);
      app.StripchartsMenu.Text = 'Stripcharts';

      % Create DL1EnergyMenu
      app.DL1EnergyMenu = uimenu(app.StripchartsMenu);
      app.DL1EnergyMenu.MenuSelectedFcn = createCallbackFcn(app, @DL1EnergyMenuSelected, true);
      app.DL1EnergyMenu.Text = 'DL1 Energy';

      % Create BC14EnergyMenu
      app.BC14EnergyMenu = uimenu(app.StripchartsMenu);
      app.BC14EnergyMenu.MenuSelectedFcn = createCallbackFcn(app, @BC14EnergyMenuSelected, true);
      app.BC14EnergyMenu.Text = 'BC14 Energy';

      % Create SettingsMenu
      app.SettingsMenu = uimenu(app.FACETIIFeedbackUIFigure);
      app.SettingsMenu.Text = 'Settings';

      % Create DL1EnergyFeedbackMenu
      app.DL1EnergyFeedbackMenu = uimenu(app.SettingsMenu);
      app.DL1EnergyFeedbackMenu.MenuSelectedFcn = createCallbackFcn(app, @DL1EnergyFeedbackMenuSelected, true);
      app.DL1EnergyFeedbackMenu.Text = 'DL1 Energy Feedback ...';

      % Create BC14EnergyFeedbackMenu
      app.BC14EnergyFeedbackMenu = uimenu(app.SettingsMenu);
      app.BC14EnergyFeedbackMenu.MenuSelectedFcn = createCallbackFcn(app, @BC14EnergyFeedbackMenuSelected, true);
      app.BC14EnergyFeedbackMenu.Text = 'BC14 Energy Feedback ...';

      % Create DisplayEnergyUnitsMenu
      app.DisplayEnergyUnitsMenu = uimenu(app.SettingsMenu);
      app.DisplayEnergyUnitsMenu.MenuSelectedFcn = createCallbackFcn(app, @DisplayEnergyUnitsMenuSelected, true);
      app.DisplayEnergyUnitsMenu.Text = 'Display Energy Units';

      % Create DL1EnergyFeedbackPanel
      app.DL1EnergyFeedbackPanel = uipanel(app.FACETIIFeedbackUIFigure);
      app.DL1EnergyFeedbackPanel.ForegroundColor = [0.9294 0.6941 0.1255];
      app.DL1EnergyFeedbackPanel.Title = 'DL1 Energy Feedback';
      app.DL1EnergyFeedbackPanel.FontWeight = 'bold';
      app.DL1EnergyFeedbackPanel.Position = [18 387 472 138];

      % Create SetpointEditField
      app.SetpointEditField = uieditfield(app.DL1EnergyFeedbackPanel, 'numeric');
      app.SetpointEditField.ValueChangedFcn = createCallbackFcn(app, @SetpointEditFieldValueChanged, true);
      app.SetpointEditField.HorizontalAlignment = 'center';
      app.SetpointEditField.Position = [17 49 100 29];

      % Create mmLabel_5
      app.mmLabel_5 = uilabel(app.DL1EnergyFeedbackPanel);
      app.mmLabel_5.FontSize = 16;
      app.mmLabel_5.Position = [123 51 48 28];
      app.mmLabel_5.Text = 'mm';

      % Create Gauge
      app.Gauge = uigauge(app.DL1EnergyFeedbackPanel, 'linear');
      app.Gauge.Limits = [-100 100];
      app.Gauge.MajorTicks = [-100 -60 -20 20 60 100];
      app.Gauge.MajorTickLabels = {''};
      app.Gauge.MinorTicks = [-100 -92 -84 -76 -68 -60 -52 -44 -36 -28 -20 -12 -4 4 12 20 28 36 44 52 60 68 76 84 92 100];
      app.Gauge.ScaleColors = [1 0 0;1 0 0;0.3922 0.8314 0.0745];
      app.Gauge.ScaleColorLimits = [-100 -75;75 100;-25 25];
      app.Gauge.FontSize = 10;
      app.Gauge.Position = [185 34 125 29];

      % Create StatusLamp
      app.StatusLamp = uilamp(app.DL1EnergyFeedbackPanel);
      app.StatusLamp.Position = [8 85 29 29];
      app.StatusLamp.Color = [0 0 0];

      % Create Switch
      app.Switch = uiswitch(app.DL1EnergyFeedbackPanel, 'slider');
      app.Switch.ValueChangedFcn = createCallbackFcn(app, @SwitchValueChanged, true);
      app.Switch.Position = [66 12 62 28];

      % Create Gauge_3
      app.Gauge_3 = uigauge(app.DL1EnergyFeedbackPanel, 'linear');
      app.Gauge_3.FontSize = 10;
      app.Gauge_3.Position = [333 34 125 29];
      app.Gauge_3.Value = 40;

      % Create KLYSIN1041ADESLabel
      app.KLYSIN1041ADESLabel = uilabel(app.DL1EnergyFeedbackPanel);
      app.KLYSIN1041ADESLabel.Position = [338 64 118 22];
      app.KLYSIN1041ADESLabel.Text = 'KLYS:IN10:41:ADES';

      % Create BPMSIN10731X1HLabel
      app.BPMSIN10731X1HLabel = uilabel(app.DL1EnergyFeedbackPanel);
      app.BPMSIN10731X1HLabel.Position = [192 64 119 22];
      app.BPMSIN10731X1HLabel.Text = 'BPMS:IN10:731:X1H';

      % Create EditField
      app.EditField = uieditfield(app.DL1EnergyFeedbackPanel, 'numeric');
      app.EditField.Editable = 'off';
      app.EditField.HorizontalAlignment = 'center';
      app.EditField.FontSize = 10;
      app.EditField.BackgroundColor = [0.4667 0.6745 0.1882];
      app.EditField.Position = [185 8 125 22];

      % Create EditField_2
      app.EditField_2 = uieditfield(app.DL1EnergyFeedbackPanel, 'numeric');
      app.EditField_2.ValueDisplayFormat = '%11.6g';
      app.EditField_2.Editable = 'off';
      app.EditField_2.HorizontalAlignment = 'center';
      app.EditField_2.FontSize = 10;
      app.EditField_2.Position = [334 8 125 22];

      % Create NotRunningButton
      app.NotRunningButton = uibutton(app.DL1EnergyFeedbackPanel, 'push');
      app.NotRunningButton.FontSize = 8;
      app.NotRunningButton.FontWeight = 'bold';
      app.NotRunningButton.Position = [44 86 418 23];
      app.NotRunningButton.Text = 'Not Running';

      % Create BC14EnergyFeedbackPanel
      app.BC14EnergyFeedbackPanel = uipanel(app.FACETIIFeedbackUIFigure);
      app.BC14EnergyFeedbackPanel.ForegroundColor = [0 0 1];
      app.BC14EnergyFeedbackPanel.Title = 'BC14 Energy Feedback';
      app.BC14EnergyFeedbackPanel.FontWeight = 'bold';
      app.BC14EnergyFeedbackPanel.Position = [18 151 473 227];

      % Create SetpointEditField_2
      app.SetpointEditField_2 = uieditfield(app.BC14EnergyFeedbackPanel, 'numeric');
      app.SetpointEditField_2.ValueChangedFcn = createCallbackFcn(app, @SetpointEditField_2ValueChanged, true);
      app.SetpointEditField_2.HorizontalAlignment = 'center';
      app.SetpointEditField_2.Position = [26 121 100 29];

      % Create mmLabel_4
      app.mmLabel_4 = uilabel(app.BC14EnergyFeedbackPanel);
      app.mmLabel_4.FontSize = 16;
      app.mmLabel_4.Position = [133 121 47 29];
      app.mmLabel_4.Text = 'mm';

      % Create Switch_2
      app.Switch_2 = uiswitch(app.BC14EnergyFeedbackPanel, 'slider');
      app.Switch_2.Orientation = 'vertical';
      app.Switch_2.ValueChangedFcn = createCallbackFcn(app, @Switch_2ValueChanged, true);
      app.Switch_2.Position = [36 24 32 72];

      % Create StatusLamp_2
      app.StatusLamp_2 = uilamp(app.BC14EnergyFeedbackPanel);
      app.StatusLamp_2.Position = [8 171 29 29];
      app.StatusLamp_2.Color = [0 0 0];

      % Create BC14KLYS1Label
      app.BC14KLYS1Label = uilabel(app.BC14EnergyFeedbackPanel);
      app.BC14KLYS1Label.Position = [223 135 116 22];
      app.BC14KLYS1Label.Text = 'KLYS:LI14:41:PDES';

      % Create BC14KLYS2Label
      app.BC14KLYS2Label = uilabel(app.BC14EnergyFeedbackPanel);
      app.BC14KLYS2Label.Position = [338 135 116 22];
      app.BC14KLYS2Label.Text = 'KLYS:LI14:51:PDES';

      % Create BPMSLI14801X1HLabel
      app.BPMSLI14801X1HLabel = uilabel(app.BC14EnergyFeedbackPanel);
      app.BPMSLI14801X1HLabel.Position = [124 72 117 22];
      app.BPMSLI14801X1HLabel.Text = 'BPMS:LI14:801:X1H';

      % Create EditField_5
      app.EditField_5 = uieditfield(app.BC14EnergyFeedbackPanel, 'numeric');
      app.EditField_5.Editable = 'off';
      app.EditField_5.HorizontalAlignment = 'center';
      app.EditField_5.FontSize = 10;
      app.EditField_5.Position = [117 16 125 22];

      % Create EditField_6
      app.EditField_6 = uieditfield(app.BC14EnergyFeedbackPanel, 'numeric');
      app.EditField_6.Editable = 'off';
      app.EditField_6.HorizontalAlignment = 'center';
      app.EditField_6.FontSize = 10;
      app.EditField_6.Position = [274 12 125 22];

      % Create NotRunningButton_5
      app.NotRunningButton_5 = uibutton(app.BC14EnergyFeedbackPanel, 'push');
      app.NotRunningButton_5.FontSize = 8;
      app.NotRunningButton_5.FontWeight = 'bold';
      app.NotRunningButton_5.Position = [51 175 414 24];
      app.NotRunningButton_5.Text = 'Not Running';

      % Create Gauge_16
      app.Gauge_16 = uigauge(app.BC14EnergyFeedbackPanel, 'ninetydegree');
      app.Gauge_16.Limits = [-90 0];
      app.Gauge_16.Orientation = 'southwest';
      app.Gauge_16.ScaleDirection = 'counterclockwise';
      app.Gauge_16.Position = [247 47 90 90];
      app.Gauge_16.Value = -60;

      % Create Gauge_17
      app.Gauge_17 = uigauge(app.BC14EnergyFeedbackPanel, 'ninetydegree');
      app.Gauge_17.Limits = [0 90];
      app.Gauge_17.Orientation = 'southeast';
      app.Gauge_17.ScaleDirection = 'counterclockwise';
      app.Gauge_17.Position = [337 47 90 90];
      app.Gauge_17.Value = 60;

      % Create Gauge_6
      app.Gauge_6 = uigauge(app.BC14EnergyFeedbackPanel, 'linear');
      app.Gauge_6.Limits = [-100 100];
      app.Gauge_6.MajorTicks = [-100 -60 -20 20 60 100];
      app.Gauge_6.MajorTickLabels = {''};
      app.Gauge_6.MinorTicks = [-100 -92 -84 -76 -68 -60 -52 -44 -36 -28 -20 -12 -4 4 12 20 28 36 44 52 60 68 76 84 92 100];
      app.Gauge_6.ScaleColors = [1 0 0;1 0 0;0.3922 0.8314 0.0745];
      app.Gauge_6.ScaleColorLimits = [-100 -75;75 100;-25 25];
      app.Gauge_6.FontSize = 10;
      app.Gauge_6.Position = [116 42 125 29];

      % Create BC20EnergyFeedbackPanel
      app.BC20EnergyFeedbackPanel = uipanel(app.FACETIIFeedbackUIFigure);
      app.BC20EnergyFeedbackPanel.ForegroundColor = [0.4667 0.6745 0.1882];
      app.BC20EnergyFeedbackPanel.Title = 'BC20 Energy Feedback';
      app.BC20EnergyFeedbackPanel.FontWeight = 'bold';
      app.BC20EnergyFeedbackPanel.Position = [498 16 472 217];

      % Create SetpointEditField_4
      app.SetpointEditField_4 = uieditfield(app.BC20EnergyFeedbackPanel, 'numeric');
      app.SetpointEditField_4.HorizontalAlignment = 'center';
      app.SetpointEditField_4.Position = [25 123 100 29];

      % Create mmLabel_7
      app.mmLabel_7 = uilabel(app.BC20EnergyFeedbackPanel);
      app.mmLabel_7.FontSize = 16;
      app.mmLabel_7.Position = [147 126 31 22];
      app.mmLabel_7.Text = 'mm';

      % Create Switch_4
      app.Switch_4 = uiswitch(app.BC20EnergyFeedbackPanel, 'slider');
      app.Switch_4.Orientation = 'vertical';
      app.Switch_4.Enable = 'off';
      app.Switch_4.Position = [47 26 29 65];

      % Create StatusLamp_4
      app.StatusLamp_4 = uilamp(app.BC20EnergyFeedbackPanel);
      app.StatusLamp_4.Position = [8 163 31 31];
      app.StatusLamp_4.Color = [0 0 0];

      % Create Gauge_7
      app.Gauge_7 = uigauge(app.BC20EnergyFeedbackPanel, 'linear');
      app.Gauge_7.Limits = [-100 100];
      app.Gauge_7.FontSize = 10;
      app.Gauge_7.Position = [112 39 126 34];

      % Create BPMSLI202445X1HLabel
      app.BPMSLI202445X1HLabel = uilabel(app.BC20EnergyFeedbackPanel);
      app.BPMSLI202445X1HLabel.Position = [116 71 124 22];
      app.BPMSLI202445X1HLabel.Text = 'BPMS:LI20:2445:X1H';

      % Create EditField_8
      app.EditField_8 = uieditfield(app.BC20EnergyFeedbackPanel, 'numeric');
      app.EditField_8.Editable = 'off';
      app.EditField_8.HorizontalAlignment = 'center';
      app.EditField_8.FontSize = 10;
      app.EditField_8.Position = [113 15 125 22];

      % Create EditField_9
      app.EditField_9 = uieditfield(app.BC20EnergyFeedbackPanel, 'numeric');
      app.EditField_9.Editable = 'off';
      app.EditField_9.HorizontalAlignment = 'center';
      app.EditField_9.FontSize = 10;
      app.EditField_9.Position = [270 27 125 22];

      % Create NotRunningButton_6
      app.NotRunningButton_6 = uibutton(app.BC20EnergyFeedbackPanel, 'push');
      app.NotRunningButton_6.FontSize = 8;
      app.NotRunningButton_6.FontWeight = 'bold';
      app.NotRunningButton_6.Position = [47 168 417 25];
      app.NotRunningButton_6.Text = 'Not Running';

      % Create BC14KLYS1Label_2
      app.BC14KLYS1Label_2 = uilabel(app.BC20EnergyFeedbackPanel);
      app.BC14KLYS1Label_2.Position = [199 145 137 22];
      app.BC14KLYS1Label_2.Text = 'KLYS:LI18:31+41:PDES';

      % Create BC14KLYS2Label_2
      app.BC14KLYS2Label_2 = uilabel(app.BC20EnergyFeedbackPanel);
      app.BC14KLYS2Label_2.Position = [335 145 137 22];
      app.BC14KLYS2Label_2.Text = 'KLYS:LI18:51+61:PDES';

      % Create Gauge_18
      app.Gauge_18 = uigauge(app.BC20EnergyFeedbackPanel, 'ninetydegree');
      app.Gauge_18.Limits = [0 90];
      app.Gauge_18.Orientation = 'southwest';
      app.Gauge_18.Position = [244 57 90 90];
      app.Gauge_18.Value = 60;

      % Create Gauge_19
      app.Gauge_19 = uigauge(app.BC20EnergyFeedbackPanel, 'ninetydegree');
      app.Gauge_19.Limits = [-90 0];
      app.Gauge_19.Orientation = 'southeast';
      app.Gauge_19.Position = [334 57 90 90];
      app.Gauge_19.Value = -60;

      % Create BC11EnergyFeedbackPanel
      app.BC11EnergyFeedbackPanel = uipanel(app.FACETIIFeedbackUIFigure);
      app.BC11EnergyFeedbackPanel.ForegroundColor = [0.851 0.3255 0.098];
      app.BC11EnergyFeedbackPanel.Title = 'BC11 Energy Feedback';
      app.BC11EnergyFeedbackPanel.FontWeight = 'bold';
      app.BC11EnergyFeedbackPanel.Position = [498 387 472 138];

      % Create SetpointEditField_5
      app.SetpointEditField_5 = uieditfield(app.BC11EnergyFeedbackPanel, 'numeric');
      app.SetpointEditField_5.HorizontalAlignment = 'center';
      app.SetpointEditField_5.Position = [17 49 100 29];

      % Create mmLabel_6
      app.mmLabel_6 = uilabel(app.BC11EnergyFeedbackPanel);
      app.mmLabel_6.FontSize = 16;
      app.mmLabel_6.Position = [130 52 31 22];
      app.mmLabel_6.Text = 'mm';

      % Create Gauge_8
      app.Gauge_8 = uigauge(app.BC11EnergyFeedbackPanel, 'linear');
      app.Gauge_8.Limits = [-100 100];
      app.Gauge_8.FontSize = 10;
      app.Gauge_8.Position = [184 32 126 34];

      % Create StatusLamp_5
      app.StatusLamp_5 = uilamp(app.BC11EnergyFeedbackPanel);
      app.StatusLamp_5.Position = [5 82 31 31];
      app.StatusLamp_5.Color = [0 0 0];

      % Create Switch_5
      app.Switch_5 = uiswitch(app.BC11EnergyFeedbackPanel, 'slider');
      app.Switch_5.Enable = 'off';
      app.Switch_5.Position = [66 12 62 28];

      % Create Gauge_9
      app.Gauge_9 = uigauge(app.BC11EnergyFeedbackPanel, 'linear');
      app.Gauge_9.FontSize = 10;
      app.Gauge_9.Position = [334 31 126 35];
      app.Gauge_9.Value = 40;

      % Create L1AMPLLabel
      app.L1AMPLLabel = uilabel(app.BC11EnergyFeedbackPanel);
      app.L1AMPLLabel.HorizontalAlignment = 'center';
      app.L1AMPLLabel.Position = [338 64 120 22];
      app.L1AMPLLabel.Text = 'L1 AMPL';

      % Create BPMSIN10731X1HLabel_3
      app.BPMSIN10731X1HLabel_3 = uilabel(app.BC11EnergyFeedbackPanel);
      app.BPMSIN10731X1HLabel_3.Position = [192 64 119 22];
      app.BPMSIN10731X1HLabel_3.Text = 'BPMS:IN10:731:X1H';

      % Create EditField_11
      app.EditField_11 = uieditfield(app.BC11EnergyFeedbackPanel, 'numeric');
      app.EditField_11.Editable = 'off';
      app.EditField_11.HorizontalAlignment = 'center';
      app.EditField_11.FontSize = 10;
      app.EditField_11.Position = [185 8 125 22];

      % Create EditField_12
      app.EditField_12 = uieditfield(app.BC11EnergyFeedbackPanel, 'numeric');
      app.EditField_12.Editable = 'off';
      app.EditField_12.HorizontalAlignment = 'center';
      app.EditField_12.FontSize = 10;
      app.EditField_12.Position = [334 8 125 22];

      % Create NotRunningButton_3
      app.NotRunningButton_3 = uibutton(app.BC11EnergyFeedbackPanel, 'push');
      app.NotRunningButton_3.FontSize = 8;
      app.NotRunningButton_3.FontWeight = 'bold';
      app.NotRunningButton_3.Position = [48 87 417 22];
      app.NotRunningButton_3.Text = 'Not Running';

      % Create BC11BunchLengthFeedbackPanel
      app.BC11BunchLengthFeedbackPanel = uipanel(app.FACETIIFeedbackUIFigure);
      app.BC11BunchLengthFeedbackPanel.ForegroundColor = [0.851 0.3255 0.098];
      app.BC11BunchLengthFeedbackPanel.Title = 'BC11 Bunch Length Feedback';
      app.BC11BunchLengthFeedbackPanel.FontWeight = 'bold';
      app.BC11BunchLengthFeedbackPanel.Position = [498 240 472 138];

      % Create SetpointEditField_6
      app.SetpointEditField_6 = uieditfield(app.BC11BunchLengthFeedbackPanel, 'numeric');
      app.SetpointEditField_6.HorizontalAlignment = 'center';
      app.SetpointEditField_6.Position = [17 47 100 29];
      app.SetpointEditField_6.Value = 0.4;

      % Create mmLabel_2
      app.mmLabel_2 = uilabel(app.BC11BunchLengthFeedbackPanel);
      app.mmLabel_2.FontSize = 16;
      app.mmLabel_2.Position = [130 50 31 22];
      app.mmLabel_2.Text = 'mm';

      % Create Gauge_10
      app.Gauge_10 = uigauge(app.BC11BunchLengthFeedbackPanel, 'linear');
      app.Gauge_10.Limits = [0.1 1];
      app.Gauge_10.FontSize = 10;
      app.Gauge_10.Position = [184 30 126 35];
      app.Gauge_10.Value = 0.4;

      % Create StatusLamp_6
      app.StatusLamp_6 = uilamp(app.BC11BunchLengthFeedbackPanel);
      app.StatusLamp_6.Position = [7 82 32 32];
      app.StatusLamp_6.Color = [0 0 0];

      % Create Switch_6
      app.Switch_6 = uiswitch(app.BC11BunchLengthFeedbackPanel, 'slider');
      app.Switch_6.Enable = 'off';
      app.Switch_6.Position = [66 10 62 28];

      % Create Gauge_11
      app.Gauge_11 = uigauge(app.BC11BunchLengthFeedbackPanel, 'linear');
      app.Gauge_11.Limits = [-180 180];
      app.Gauge_11.FontSize = 10;
      app.Gauge_11.Position = [334 29 126 35];

      % Create L1PHASELabel
      app.L1PHASELabel = uilabel(app.BC11BunchLengthFeedbackPanel);
      app.L1PHASELabel.HorizontalAlignment = 'center';
      app.L1PHASELabel.Position = [366 62 63 22];
      app.L1PHASELabel.Text = 'L1 PHASE';

      % Create BL11359Label_2
      app.BL11359Label_2 = uilabel(app.BC11BunchLengthFeedbackPanel);
      app.BL11359Label_2.HorizontalAlignment = 'center';
      app.BL11359Label_2.Position = [224 62 55 22];
      app.BL11359Label_2.Text = 'BL11359';

      % Create EditField_13
      app.EditField_13 = uieditfield(app.BC11BunchLengthFeedbackPanel, 'numeric');
      app.EditField_13.Editable = 'off';
      app.EditField_13.HorizontalAlignment = 'center';
      app.EditField_13.FontSize = 10;
      app.EditField_13.Position = [185 6 125 22];

      % Create EditField_14
      app.EditField_14 = uieditfield(app.BC11BunchLengthFeedbackPanel, 'numeric');
      app.EditField_14.Editable = 'off';
      app.EditField_14.HorizontalAlignment = 'center';
      app.EditField_14.FontSize = 10;
      app.EditField_14.Position = [334 6 125 22];

      % Create NotRunningButton_4
      app.NotRunningButton_4 = uibutton(app.BC11BunchLengthFeedbackPanel, 'push');
      app.NotRunningButton_4.FontSize = 8;
      app.NotRunningButton_4.FontWeight = 'bold';
      app.NotRunningButton_4.Position = [44 88 419 22];
      app.NotRunningButton_4.Text = 'Not Running';

      % Create BC14BunchLengthFeedbackPanel
      app.BC14BunchLengthFeedbackPanel = uipanel(app.FACETIIFeedbackUIFigure);
      app.BC14BunchLengthFeedbackPanel.ForegroundColor = [0 0 1];
      app.BC14BunchLengthFeedbackPanel.Title = 'BC14 Bunch Length Feedback';
      app.BC14BunchLengthFeedbackPanel.FontWeight = 'bold';
      app.BC14BunchLengthFeedbackPanel.Position = [18 17 473 125];

      % Create SetpointEditField_7
      app.SetpointEditField_7 = uieditfield(app.BC14BunchLengthFeedbackPanel, 'numeric');
      app.SetpointEditField_7.HorizontalAlignment = 'center';
      app.SetpointEditField_7.Position = [17 46 100 29];
      app.SetpointEditField_7.Value = 0.1;

      % Create mmLabel_3
      app.mmLabel_3 = uilabel(app.BC14BunchLengthFeedbackPanel);
      app.mmLabel_3.FontSize = 16;
      app.mmLabel_3.Position = [130 49 31 22];
      app.mmLabel_3.Text = 'mm';

      % Create Gauge_12
      app.Gauge_12 = uigauge(app.BC14BunchLengthFeedbackPanel, 'linear');
      app.Gauge_12.Limits = [0.01 1];
      app.Gauge_12.FontSize = 10;
      app.Gauge_12.Position = [184 29 126 35];
      app.Gauge_12.Value = 0.1;

      % Create Switch_7
      app.Switch_7 = uiswitch(app.BC14BunchLengthFeedbackPanel, 'slider');
      app.Switch_7.Enable = 'off';
      app.Switch_7.Position = [66 9 62 28];

      % Create Gauge_13
      app.Gauge_13 = uigauge(app.BC14BunchLengthFeedbackPanel, 'linear');
      app.Gauge_13.Limits = [-180 180];
      app.Gauge_13.FontSize = 10;
      app.Gauge_13.Position = [334 28 126 35];

      % Create L2PHASELabel
      app.L2PHASELabel = uilabel(app.BC14BunchLengthFeedbackPanel);
      app.L2PHASELabel.HorizontalAlignment = 'center';
      app.L2PHASELabel.Position = [338 61 120 22];
      app.L2PHASELabel.Text = 'L2 PHASE';

      % Create BL11359Label
      app.BL11359Label = uilabel(app.BC14BunchLengthFeedbackPanel);
      app.BL11359Label.HorizontalAlignment = 'center';
      app.BL11359Label.Position = [192 62 113 22];
      app.BL11359Label.Text = 'BL11359';

      % Create EditField_15
      app.EditField_15 = uieditfield(app.BC14BunchLengthFeedbackPanel, 'numeric');
      app.EditField_15.Editable = 'off';
      app.EditField_15.HorizontalAlignment = 'center';
      app.EditField_15.FontSize = 10;
      app.EditField_15.Position = [185 5 125 22];

      % Create EditField_16
      app.EditField_16 = uieditfield(app.BC14BunchLengthFeedbackPanel, 'numeric');
      app.EditField_16.Editable = 'off';
      app.EditField_16.HorizontalAlignment = 'center';
      app.EditField_16.FontSize = 10;
      app.EditField_16.Position = [334 5 125 22];

      % Create StatusLamp_7
      app.StatusLamp_7 = uilamp(app.BC14BunchLengthFeedbackPanel);
      app.StatusLamp_7.Position = [7 79 23 23];
      app.StatusLamp_7.Color = [0 0 0];

      % Create NotRunningButton_7
      app.NotRunningButton_7 = uibutton(app.BC14BunchLengthFeedbackPanel, 'push');
      app.NotRunningButton_7.FontSize = 8;
      app.NotRunningButton_7.FontWeight = 'bold';
      app.NotRunningButton_7.Position = [36 82 427 18];
      app.NotRunningButton_7.Text = 'Not Running';

      % Show the figure after all components are created
      app.FACETIIFeedbackUIFigure.Visible = 'on';
    end
  end

  % App creation and deletion
  methods (Access = public)

    % Construct app
    function app = F2_Feedback_exported(varargin)

      % Create UIFigure and components
      createComponents(app)

      % Register the app with App Designer
      registerApp(app, app.FACETIIFeedbackUIFigure)

      % Execute the startup function
      runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

      if nargout == 0
        clear app
      end
    end

    % Code that executes before app deletion
    function delete(app)

      % Delete UIFigure when app is deleted
      delete(app.FACETIIFeedbackUIFigure)
    end
  end
end