classdef F2_Feedback_exported < matlab.apps.AppBase

  % Properties that correspond to app components
  properties (Access = public)
    FACETIIFeedbackUIFigure       matlab.ui.Figure
    StripchartsMenu               matlab.ui.container.Menu
    DL1EnergyMenu                 matlab.ui.container.Menu
    BC11EnergyMenu                matlab.ui.container.Menu
    BC11BLENMenu                  matlab.ui.container.Menu
    BC14EnergyMenu                matlab.ui.container.Menu
    BC14BLENMenu                  matlab.ui.container.Menu
    BC20EnergyMenu                matlab.ui.container.Menu
    SettingsMenu                  matlab.ui.container.Menu
    DL1EnergyFeedbackMenu         matlab.ui.container.Menu
    BC11EnergyFeedbackMenu        matlab.ui.container.Menu
    BC11BLENFeedbackMenu          matlab.ui.container.Menu
    BC14EnergyFeedbackMenu        matlab.ui.container.Menu
    BC14BLENFeedbackMenu          matlab.ui.container.Menu
    BC20EnergyFeedbackMenu        matlab.ui.container.Menu
    DisplayEnergyUnitsMenu        matlab.ui.container.Menu
    JitterTimeoutMenu             matlab.ui.container.Menu
    DL10EnergyFeedbackPanel       matlab.ui.container.Panel
    SetpointEditField             matlab.ui.control.NumericEditField
    mmLabel_5                     matlab.ui.control.Label
    Gauge                         matlab.ui.control.LinearGauge
    StatusLamp                    matlab.ui.control.Lamp
    Switch                        matlab.ui.control.Switch
    Gauge_3                       matlab.ui.control.LinearGauge
    KLYSIN1041SFB_ADESLabel       matlab.ui.control.Label
    BPMSIN10731X1HLabel           matlab.ui.control.Label
    EditField                     matlab.ui.control.NumericEditField
    EditField_2                   matlab.ui.control.NumericEditField
    NotRunningButton              matlab.ui.control.Button
    FeedbackJitterButton          matlab.ui.control.StateButton
    ADESJitterAmplitudeEditFieldLabel  matlab.ui.control.Label
    JitAmpEdit                    matlab.ui.control.NumericEditField
    BC14EnergyFeedbackPanel       matlab.ui.container.Panel
    SetpointEditField_2           matlab.ui.control.NumericEditField
    mmLabel_4                     matlab.ui.control.Label
    Switch_2                      matlab.ui.control.Switch
    StatusLamp_2                  matlab.ui.control.Lamp
    BC14_C1Lab                    matlab.ui.control.Label
    BC14_C2Lab                    matlab.ui.control.Label
    BPMSLI14801X1HLabel           matlab.ui.control.Label
    EditField_5                   matlab.ui.control.NumericEditField
    EditField_6                   matlab.ui.control.NumericEditField
    NotRunningButton_5            matlab.ui.control.Button
    Gauge_16                      matlab.ui.control.NinetyDegreeGauge
    Gauge_17                      matlab.ui.control.NinetyDegreeGauge
    Gauge_6                       matlab.ui.control.LinearGauge
    MKBLabel_2                    matlab.ui.control.Label
    DropDown_2                    matlab.ui.control.DropDown
    BC20EnergyFeedbackPanel       matlab.ui.container.Panel
    SetpointEditField_4           matlab.ui.control.NumericEditField
    mmLabel_7                     matlab.ui.control.Label
    Switch_4                      matlab.ui.control.Switch
    StatusLamp_4                  matlab.ui.control.Lamp
    BPMSLI202050X57Label          matlab.ui.control.Label
    EditField_8                   matlab.ui.control.NumericEditField
    NotRunningButton_6            matlab.ui.control.Button
    MKBLabel                      matlab.ui.control.Label
    DropDown                      matlab.ui.control.DropDown
    BC20_C1Lab                    matlab.ui.control.Label
    BC20_C2Lab                    matlab.ui.control.Label
    Gauge_19                      matlab.ui.control.NinetyDegreeGauge
    Gauge_20                      matlab.ui.control.NinetyDegreeGauge
    EditField_17                  matlab.ui.control.NumericEditField
    Gauge_7                       matlab.ui.control.LinearGauge
    BC11EnergyFeedbackPanel       matlab.ui.container.Panel
    SetpointEditField_5           matlab.ui.control.NumericEditField
    mmLabel_6                     matlab.ui.control.Label
    StatusLamp_5                  matlab.ui.control.Lamp
    Switch_5                      matlab.ui.control.Switch
    Gauge_9                       matlab.ui.control.LinearGauge
    KLYSLI111121SSSB_ADESLabel    matlab.ui.control.Label
    BPMSLI11333X1HLabel           matlab.ui.control.Label
    EditField_11                  matlab.ui.control.NumericEditField
    EditField_12                  matlab.ui.control.NumericEditField
    NotRunningButton_3            matlab.ui.control.Button
    Gauge_8                       matlab.ui.control.LinearGauge
    BC11BunchLengthFeedbackPanel  matlab.ui.container.Panel
    SetpointEditField_6           matlab.ui.control.NumericEditField
    eguLabel                      matlab.ui.control.Label
    Gauge_10                      matlab.ui.control.LinearGauge
    StatusLamp_6                  matlab.ui.control.Lamp
    Switch_6                      matlab.ui.control.Switch
    Gauge_11                      matlab.ui.control.LinearGauge
    KLYSLI111121SSSB_PDESLabel    matlab.ui.control.Label
    BLENLI11359Label              matlab.ui.control.Label
    EditField_13                  matlab.ui.control.NumericEditField
    EditField_14                  matlab.ui.control.NumericEditField
    NotRunningButton_4            matlab.ui.control.Button
    BC14BunchLengthFeedbackPanel  matlab.ui.container.Panel
    SetpointEditField_7           matlab.ui.control.NumericEditField
    fsLabel                       matlab.ui.control.Label
    Gauge_13                      matlab.ui.control.LinearGauge
    L2PHASELabel                  matlab.ui.control.Label
    BLENLI14888Label              matlab.ui.control.Label
    EditField_15                  matlab.ui.control.NumericEditField
    EditField_16                  matlab.ui.control.NumericEditField
    StatusLamp_7                  matlab.ui.control.Lamp
    NotRunningButton_7            matlab.ui.control.Button
    Switch_7                      matlab.ui.control.Switch
    Gauge_12                      matlab.ui.control.LinearGauge
    FeedbackWatcherProcessStatusPanel  matlab.ui.container.Panel
    fbstat                        matlab.ui.control.Label
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
      disp('Setting DL FB Enable...');
      value = string(app.Switch.Value) == "On" ;
      caput(app.aobj.pvs.FeedbackEnable,double(bitset(app.aobj.Enabled,1,double(value))));
      disp('Done.');
    end

    % Menu selected function: DL1EnergyMenu
    function DL1EnergyMenuSelected(app, event)
      !StripTool /u1/facet/tools/StripTool/config/FB_DL1_E.stp &
    end

    % Menu selected function: DL1EnergyFeedbackMenu
    function DL1EnergyFeedbackMenuSelected(app, event)
      app.DL1EnergyFeedbackMenu.Enable = false ;
      DL1E_Settings(app.aobj);
      drawnow;
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
      app.aobj.SetpointOffsets(2) = value ;
    end

    % Menu selected function: BC14EnergyMenu
    function BC14EnergyMenuSelected(app, event)
      !StripTool /u1/facet/tools/StripTool/config/FB_BC14_E.stp &
    end

    % Menu selected function: BC14EnergyFeedbackMenu
    function BC14EnergyFeedbackMenuSelected(app, event)
      app.BC14EnergyFeedbackMenu.Enable = false ;
      BC14E_Settings(app.aobj);
      drawnow
    end

    % Value changed function: Switch_2
    function Switch_2ValueChanged(app, event)
      value = string(app.Switch_2.Value) == "On" ;
      caput(app.aobj.pvs.FeedbackEnable,double(bitset(app.aobj.Enabled,2,value)));
    end

    % Menu selected function: BC11EnergyFeedbackMenu
    function BC11EnergyFeedbackMenuSelected(app, event)
      app.BC11EnergyFeedbackMenu.Enable = false ;
      BC11E_Settings(app.aobj);
      drawnow
    end

    % Value changed function: Switch_5
    function Switch_5ValueChanged(app, event)
      value = string(app.Switch_5.Value) == "On" ;
      caput(app.aobj.pvs.FeedbackEnable,double(bitset(app.aobj.Enabled,3,value)));
    end

    % Value changed function: SetpointEditField_5
    function SetpointEditField_5ValueChanged(app, event)
      value = app.SetpointEditField_5.Value;
      if app.aobj.GuiEnergyUnits
        value = (value - app.aobj.SetpointConversion{3}(1)) / app.aobj.SetpointConversion{3}(2) ;
      end
      caput(app.aobj.pvs.BC11E_Offset,value) ;
      app.aobj.SetpointOffsets(3) = value ;
    end

    % Menu selected function: BC11EnergyMenu
    function BC11EnergyMenuSelected(app, event)
      !StripTool /u1/facet/tools/StripTool/config/FB_BC11_E.stp &
    end

    % Menu selected function: JitterTimeoutMenu
    function JitterTimeoutMenuSelected(app, event)
      resp=str2double(inputdlg('Enter Jitter Timeout (min)','Jitter Timeout',1,{'2'}));
      if ~isempty(resp)
        app.JitterTimeoutMenu.Text = sprintf('Jitter Timeout = %d min',round(resp)) ;
        caput(app.aobj.pvs.FB_JitterOnTime,resp);
      end
    end

    % Value changed function: FeedbackJitterButton
    function FeedbackJitterButtonValueChanged(app, event)
      value = app.FeedbackJitterButton.Value;
      caput(app.aobj.pvs.DL1E_JitterON,double(value));
    end

    % Value changed function: JitAmpEdit
    function JitAmpEditValueChanged(app, event)
      value = app.JitAmpEdit.Value;
      caput(app.aobj.pvs.DL1E_JitterAMP,double(value));
    end

    % Value changed function: Switch_6
    function Switch_6ValueChanged(app, event)
      value = string(app.Switch_6.Value) == "On" ;
      caput(app.aobj.pvs.FeedbackEnable,double(bitset(app.aobj.Enabled,4,value)));
    end

    % Menu selected function: BC11BLENFeedbackMenu
    function BC11BLENFeedbackMenuSelected(app, event)
      app.BC11BLENFeedbackMenu.Enable = false ;
      BC11BL_Settings(app.aobj);
      drawnow
    end

    % Value changed function: DropDown
    function DropDownValueChanged(app, event)
      value = app.DropDown.Value;
      app.aobj.BC20E_mkb = value ;
    end

    % Menu selected function: BC20EnergyFeedbackMenu
    function BC20EnergyFeedbackMenuSelected(app, event)
      app.BC20EnergyFeedbackMenu.Enable = false ;
      BC20E_Settings(app.aobj);
      drawnow
    end

    % Value changed function: DropDown_2
    function DropDown_2ValueChanged(app, event)
      value = app.DropDown_2.Value;
      app.aobj.BC14E_mkb = value ;
    end

    % Value changed function: Switch_4
    function Switch_4ValueChanged(app, event)
      value = string(app.Switch_4.Value) == "On" ;
      caput(app.aobj.pvs.FeedbackEnable,double(bitset(app.aobj.Enabled,5,value)));
    end

    % Value changed function: SetpointEditField_4
    function SetpointEditField_4ValueChanged(app, event)
      value = app.SetpointEditField_4.Value;
      if app.aobj.GuiEnergyUnits
        value = (value - app.aobj.SetpointConversion{5}(1)) / app.aobj.SetpointConversion{5}(2) ;
      end
      caput(app.aobj.pvs.BC20E_Offset,value) ;
      app.aobj.SetpointOffsets(5) = value ;
    end

    % Value changed function: SetpointEditField_6
    function SetpointEditField_6ValueChanged(app, event)
      value = app.SetpointEditField_6.Value;
      caput(app.aobj.pvs.BC11BL_Offset,value) ;
      app.aobj.SetpointOffsets(4) = value ;
    end

    % Value changed function: SetpointEditField_7
    function SetpointEditField_7ValueChanged(app, event)
      value = app.SetpointEditField_7.Value;
      caput(app.aobj.pvs.BC14BL_Offset,value) ;
      app.aobj.SetpointOffsets(6) = value ;
      
    end

    % Menu selected function: BC20EnergyMenu
    function BC20EnergyMenuSelected(app, event)
      !StripTool /u1/facet/tools/StripTool/config/FB_BC20_E.stp &
    end

    % Menu selected function: BC14BLENFeedbackMenu
    function BC14BLENFeedbackMenuSelected(app, event)
      app.BC14BLENFeedbackMenu.Enable = false ;
      BC14BL_Settings(app.aobj);
      drawnow
    end

    % Menu selected function: BC11BLENMenu
    function BC11BLENMenuSelected(app, event)
      !StripTool /u1/facet/tools/StripTool/config/FB_BC11_BLEN.stp &
    end

    % Menu selected function: BC14BLENMenu
    function BC14BLENMenuSelected(app, event)
      !StripTool /u1/facet/tools/StripTool/config/FB_BC14_BLEN.stp &
    end

    % Value changed function: Switch_7
    function Switch_7ValueChanged(app, event)
      value = string(app.Switch_7.Value) == "On" ;
      caput(app.aobj.pvs.FeedbackEnable,double(bitset(app.aobj.Enabled,6,value)));
    end
  end

  % Component initialization
  methods (Access = private)

    % Create UIFigure and components
    function createComponents(app)

      % Create FACETIIFeedbackUIFigure and hide until all components are created
      app.FACETIIFeedbackUIFigure = uifigure('Visible', 'off');
      app.FACETIIFeedbackUIFigure.Position = [100 100 991 649];
      app.FACETIIFeedbackUIFigure.Name = 'FACET-II Feedback';
      app.FACETIIFeedbackUIFigure.Resize = 'off';
      app.FACETIIFeedbackUIFigure.CloseRequestFcn = createCallbackFcn(app, @FACETIIFeedbackUIFigureCloseRequest, true);

      % Create StripchartsMenu
      app.StripchartsMenu = uimenu(app.FACETIIFeedbackUIFigure);
      app.StripchartsMenu.Text = 'Stripcharts';

      % Create DL1EnergyMenu
      app.DL1EnergyMenu = uimenu(app.StripchartsMenu);
      app.DL1EnergyMenu.MenuSelectedFcn = createCallbackFcn(app, @DL1EnergyMenuSelected, true);
      app.DL1EnergyMenu.Text = 'DL1 Energy';

      % Create BC11EnergyMenu
      app.BC11EnergyMenu = uimenu(app.StripchartsMenu);
      app.BC11EnergyMenu.MenuSelectedFcn = createCallbackFcn(app, @BC11EnergyMenuSelected, true);
      app.BC11EnergyMenu.Text = 'BC11 Energy';

      % Create BC11BLENMenu
      app.BC11BLENMenu = uimenu(app.StripchartsMenu);
      app.BC11BLENMenu.MenuSelectedFcn = createCallbackFcn(app, @BC11BLENMenuSelected, true);
      app.BC11BLENMenu.Text = 'BC11 BLEN';

      % Create BC14EnergyMenu
      app.BC14EnergyMenu = uimenu(app.StripchartsMenu);
      app.BC14EnergyMenu.MenuSelectedFcn = createCallbackFcn(app, @BC14EnergyMenuSelected, true);
      app.BC14EnergyMenu.Text = 'BC14 Energy';

      % Create BC14BLENMenu
      app.BC14BLENMenu = uimenu(app.StripchartsMenu);
      app.BC14BLENMenu.MenuSelectedFcn = createCallbackFcn(app, @BC14BLENMenuSelected, true);
      app.BC14BLENMenu.Text = 'BC14 BLEN';

      % Create BC20EnergyMenu
      app.BC20EnergyMenu = uimenu(app.StripchartsMenu);
      app.BC20EnergyMenu.MenuSelectedFcn = createCallbackFcn(app, @BC20EnergyMenuSelected, true);
      app.BC20EnergyMenu.Text = 'BC20 Energy';

      % Create SettingsMenu
      app.SettingsMenu = uimenu(app.FACETIIFeedbackUIFigure);
      app.SettingsMenu.Text = 'Settings';

      % Create DL1EnergyFeedbackMenu
      app.DL1EnergyFeedbackMenu = uimenu(app.SettingsMenu);
      app.DL1EnergyFeedbackMenu.MenuSelectedFcn = createCallbackFcn(app, @DL1EnergyFeedbackMenuSelected, true);
      app.DL1EnergyFeedbackMenu.Text = 'DL1 Energy Feedback ...';

      % Create BC11EnergyFeedbackMenu
      app.BC11EnergyFeedbackMenu = uimenu(app.SettingsMenu);
      app.BC11EnergyFeedbackMenu.MenuSelectedFcn = createCallbackFcn(app, @BC11EnergyFeedbackMenuSelected, true);
      app.BC11EnergyFeedbackMenu.Text = 'BC11 Energy Feedback...';

      % Create BC11BLENFeedbackMenu
      app.BC11BLENFeedbackMenu = uimenu(app.SettingsMenu);
      app.BC11BLENFeedbackMenu.MenuSelectedFcn = createCallbackFcn(app, @BC11BLENFeedbackMenuSelected, true);
      app.BC11BLENFeedbackMenu.Text = 'BC11 BLEN Feedback...';

      % Create BC14EnergyFeedbackMenu
      app.BC14EnergyFeedbackMenu = uimenu(app.SettingsMenu);
      app.BC14EnergyFeedbackMenu.MenuSelectedFcn = createCallbackFcn(app, @BC14EnergyFeedbackMenuSelected, true);
      app.BC14EnergyFeedbackMenu.Text = 'BC14 Energy Feedback ...';

      % Create BC14BLENFeedbackMenu
      app.BC14BLENFeedbackMenu = uimenu(app.SettingsMenu);
      app.BC14BLENFeedbackMenu.MenuSelectedFcn = createCallbackFcn(app, @BC14BLENFeedbackMenuSelected, true);
      app.BC14BLENFeedbackMenu.Text = 'BC14 BLEN Feedback...';

      % Create BC20EnergyFeedbackMenu
      app.BC20EnergyFeedbackMenu = uimenu(app.SettingsMenu);
      app.BC20EnergyFeedbackMenu.MenuSelectedFcn = createCallbackFcn(app, @BC20EnergyFeedbackMenuSelected, true);
      app.BC20EnergyFeedbackMenu.Text = 'BC20 Energy Feedback...';

      % Create DisplayEnergyUnitsMenu
      app.DisplayEnergyUnitsMenu = uimenu(app.SettingsMenu);
      app.DisplayEnergyUnitsMenu.MenuSelectedFcn = createCallbackFcn(app, @DisplayEnergyUnitsMenuSelected, true);
      app.DisplayEnergyUnitsMenu.Text = 'Display Energy Units';

      % Create JitterTimeoutMenu
      app.JitterTimeoutMenu = uimenu(app.SettingsMenu);
      app.JitterTimeoutMenu.MenuSelectedFcn = createCallbackFcn(app, @JitterTimeoutMenuSelected, true);
      app.JitterTimeoutMenu.Text = 'Jitter Timeout = 2 min';

      % Create DL10EnergyFeedbackPanel
      app.DL10EnergyFeedbackPanel = uipanel(app.FACETIIFeedbackUIFigure);
      app.DL10EnergyFeedbackPanel.ForegroundColor = [0.9294 0.6941 0.1255];
      app.DL10EnergyFeedbackPanel.Title = 'DL10 Energy Feedback';
      app.DL10EnergyFeedbackPanel.FontWeight = 'bold';
      app.DL10EnergyFeedbackPanel.Position = [22 384 472 182];

      % Create SetpointEditField
      app.SetpointEditField = uieditfield(app.DL10EnergyFeedbackPanel, 'numeric');
      app.SetpointEditField.ValueChangedFcn = createCallbackFcn(app, @SetpointEditFieldValueChanged, true);
      app.SetpointEditField.HorizontalAlignment = 'center';
      app.SetpointEditField.Position = [17 93 100 29];

      % Create mmLabel_5
      app.mmLabel_5 = uilabel(app.DL10EnergyFeedbackPanel);
      app.mmLabel_5.FontSize = 16;
      app.mmLabel_5.Position = [123 95 48 28];
      app.mmLabel_5.Text = 'mm';

      % Create Gauge
      app.Gauge = uigauge(app.DL10EnergyFeedbackPanel, 'linear');
      app.Gauge.Limits = [-100 100];
      app.Gauge.MajorTicks = [-100 -60 -20 20 60 100];
      app.Gauge.MajorTickLabels = {''};
      app.Gauge.MinorTicks = [-100 -92 -84 -76 -68 -60 -52 -44 -36 -28 -20 -12 -4 4 12 20 28 36 44 52 60 68 76 84 92 100];
      app.Gauge.ScaleColors = [1 0 0;1 0 0;0.3922 0.8314 0.0745];
      app.Gauge.ScaleColorLimits = [-100 -75;75 100;-25 25];
      app.Gauge.FontSize = 10;
      app.Gauge.Position = [185 78 125 29];

      % Create StatusLamp
      app.StatusLamp = uilamp(app.DL10EnergyFeedbackPanel);
      app.StatusLamp.Position = [8 129 29 29];
      app.StatusLamp.Color = [0 0 0];

      % Create Switch
      app.Switch = uiswitch(app.DL10EnergyFeedbackPanel, 'slider');
      app.Switch.ValueChangedFcn = createCallbackFcn(app, @SwitchValueChanged, true);
      app.Switch.Interruptible = 'off';
      app.Switch.Position = [64 54 62 28];

      % Create Gauge_3
      app.Gauge_3 = uigauge(app.DL10EnergyFeedbackPanel, 'linear');
      app.Gauge_3.FontSize = 10;
      app.Gauge_3.Position = [333 78 125 29];
      app.Gauge_3.Value = 40;

      % Create KLYSIN1041SFB_ADESLabel
      app.KLYSIN1041SFB_ADESLabel = uilabel(app.DL10EnergyFeedbackPanel);
      app.KLYSIN1041SFB_ADESLabel.Position = [323 106 148 22];
      app.KLYSIN1041SFB_ADESLabel.Text = 'KLYS:IN10:41:SFB_ADES';

      % Create BPMSIN10731X1HLabel
      app.BPMSIN10731X1HLabel = uilabel(app.DL10EnergyFeedbackPanel);
      app.BPMSIN10731X1HLabel.Position = [189 105 119 22];
      app.BPMSIN10731X1HLabel.Text = 'BPMS:IN10:731:X1H';

      % Create EditField
      app.EditField = uieditfield(app.DL10EnergyFeedbackPanel, 'numeric');
      app.EditField.Editable = 'off';
      app.EditField.HorizontalAlignment = 'center';
      app.EditField.FontSize = 10;
      app.EditField.BackgroundColor = [0.4667 0.6745 0.1882];
      app.EditField.Position = [185 52 125 22];

      % Create EditField_2
      app.EditField_2 = uieditfield(app.DL10EnergyFeedbackPanel, 'numeric');
      app.EditField_2.ValueDisplayFormat = '%11.6g';
      app.EditField_2.Editable = 'off';
      app.EditField_2.HorizontalAlignment = 'center';
      app.EditField_2.FontSize = 10;
      app.EditField_2.Position = [334 52 125 22];

      % Create NotRunningButton
      app.NotRunningButton = uibutton(app.DL10EnergyFeedbackPanel, 'push');
      app.NotRunningButton.FontSize = 8;
      app.NotRunningButton.FontWeight = 'bold';
      app.NotRunningButton.Position = [44 130 418 23];
      app.NotRunningButton.Text = 'Not Running';

      % Create FeedbackJitterButton
      app.FeedbackJitterButton = uibutton(app.DL10EnergyFeedbackPanel, 'state');
      app.FeedbackJitterButton.ValueChangedFcn = createCallbackFcn(app, @FeedbackJitterButtonValueChanged, true);
      app.FeedbackJitterButton.Interruptible = 'off';
      app.FeedbackJitterButton.Text = 'Feedback Jitter OFF';
      app.FeedbackJitterButton.FontWeight = 'bold';
      app.FeedbackJitterButton.Position = [17 10 168 31];

      % Create ADESJitterAmplitudeEditFieldLabel
      app.ADESJitterAmplitudeEditFieldLabel = uilabel(app.DL10EnergyFeedbackPanel);
      app.ADESJitterAmplitudeEditFieldLabel.HorizontalAlignment = 'right';
      app.ADESJitterAmplitudeEditFieldLabel.Position = [213 15 128 22];
      app.ADESJitterAmplitudeEditFieldLabel.Text = 'ADES Jitter Amplitude:';

      % Create JitAmpEdit
      app.JitAmpEdit = uieditfield(app.DL10EnergyFeedbackPanel, 'numeric');
      app.JitAmpEdit.ValueChangedFcn = createCallbackFcn(app, @JitAmpEditValueChanged, true);
      app.JitAmpEdit.Position = [356 15 60 22];
      app.JitAmpEdit.Value = 0.1;

      % Create BC14EnergyFeedbackPanel
      app.BC14EnergyFeedbackPanel = uipanel(app.FACETIIFeedbackUIFigure);
      app.BC14EnergyFeedbackPanel.ForegroundColor = [0 0 1];
      app.BC14EnergyFeedbackPanel.Title = 'BC14 Energy Feedback';
      app.BC14EnergyFeedbackPanel.FontWeight = 'bold';
      app.BC14EnergyFeedbackPanel.Position = [22 149 473 227];

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

      % Create BC14_C1Lab
      app.BC14_C1Lab = uilabel(app.BC14EnergyFeedbackPanel);
      app.BC14_C1Lab.Position = [233 119 116 22];
      app.BC14_C1Lab.Text = 'KLYS:LI14:41:PDES';

      % Create BC14_C2Lab
      app.BC14_C2Lab = uilabel(app.BC14EnergyFeedbackPanel);
      app.BC14_C2Lab.Position = [348 119 116 22];
      app.BC14_C2Lab.Text = 'KLYS:LI14:51:PDES';

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
      app.EditField_6.Position = [284 5 125 22];

      % Create NotRunningButton_5
      app.NotRunningButton_5 = uibutton(app.BC14EnergyFeedbackPanel, 'push');
      app.NotRunningButton_5.FontSize = 8;
      app.NotRunningButton_5.FontWeight = 'bold';
      app.NotRunningButton_5.Position = [51 175 414 24];
      app.NotRunningButton_5.Text = 'Not Running';

      % Create Gauge_16
      app.Gauge_16 = uigauge(app.BC14EnergyFeedbackPanel, 'ninetydegree');
      app.Gauge_16.Limits = [-180 0];
      app.Gauge_16.Orientation = 'southwest';
      app.Gauge_16.ScaleDirection = 'counterclockwise';
      app.Gauge_16.Position = [257 31 90 90];
      app.Gauge_16.Value = -60;

      % Create Gauge_17
      app.Gauge_17 = uigauge(app.BC14EnergyFeedbackPanel, 'ninetydegree');
      app.Gauge_17.Limits = [0 180];
      app.Gauge_17.Orientation = 'southeast';
      app.Gauge_17.ScaleDirection = 'counterclockwise';
      app.Gauge_17.Position = [347 31 90 90];
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

      % Create MKBLabel_2
      app.MKBLabel_2 = uilabel(app.BC14EnergyFeedbackPanel);
      app.MKBLabel_2.Position = [224 145 34 22];
      app.MKBLabel_2.Text = 'MKB:';

      % Create DropDown_2
      app.DropDown_2 = uidropdown(app.BC14EnergyFeedbackPanel);
      app.DropDown_2.Items = {'BC14_ENERGY_4AND5', 'BC14_ENERGY_5AND6', 'BC14_ENERGY_4AND6'};
      app.DropDown_2.ValueChangedFcn = createCallbackFcn(app, @DropDown_2ValueChanged, true);
      app.DropDown_2.Position = [269 145 189 22];
      app.DropDown_2.Value = 'BC14_ENERGY_4AND5';

      % Create BC20EnergyFeedbackPanel
      app.BC20EnergyFeedbackPanel = uipanel(app.FACETIIFeedbackUIFigure);
      app.BC20EnergyFeedbackPanel.ForegroundColor = [0.7176 0.2745 1];
      app.BC20EnergyFeedbackPanel.Title = 'BC20 Energy Feedback';
      app.BC20EnergyFeedbackPanel.FontWeight = 'bold';
      app.BC20EnergyFeedbackPanel.Position = [502 7 472 265];

      % Create SetpointEditField_4
      app.SetpointEditField_4 = uieditfield(app.BC20EnergyFeedbackPanel, 'numeric');
      app.SetpointEditField_4.ValueChangedFcn = createCallbackFcn(app, @SetpointEditField_4ValueChanged, true);
      app.SetpointEditField_4.HorizontalAlignment = 'center';
      app.SetpointEditField_4.Position = [17 153 109 29];

      % Create mmLabel_7
      app.mmLabel_7 = uilabel(app.BC20EnergyFeedbackPanel);
      app.mmLabel_7.FontSize = 16;
      app.mmLabel_7.Position = [130 157 41 22];
      app.mmLabel_7.Text = 'mm';

      % Create Switch_4
      app.Switch_4 = uiswitch(app.BC20EnergyFeedbackPanel, 'slider');
      app.Switch_4.Orientation = 'vertical';
      app.Switch_4.ValueChangedFcn = createCallbackFcn(app, @Switch_4ValueChanged, true);
      app.Switch_4.Position = [17 43 32 72];

      % Create StatusLamp_4
      app.StatusLamp_4 = uilamp(app.BC20EnergyFeedbackPanel);
      app.StatusLamp_4.Position = [8 198 31 31];
      app.StatusLamp_4.Color = [0 0 0];

      % Create BPMSLI202050X57Label
      app.BPMSLI202050X57Label = uilabel(app.BC20EnergyFeedbackPanel);
      app.BPMSLI202050X57Label.Position = [93 84 122 22];
      app.BPMSLI202050X57Label.Text = 'BPMS:LI20:2050:X57';

      % Create EditField_8
      app.EditField_8 = uieditfield(app.BC20EnergyFeedbackPanel, 'numeric');
      app.EditField_8.Editable = 'off';
      app.EditField_8.HorizontalAlignment = 'center';
      app.EditField_8.FontSize = 10;
      app.EditField_8.Position = [88 30 128 22];

      % Create NotRunningButton_6
      app.NotRunningButton_6 = uibutton(app.BC20EnergyFeedbackPanel, 'push');
      app.NotRunningButton_6.FontSize = 8;
      app.NotRunningButton_6.FontWeight = 'bold';
      app.NotRunningButton_6.Position = [47 203 417 25];
      app.NotRunningButton_6.Text = 'Not Running';

      % Create MKBLabel
      app.MKBLabel = uilabel(app.BC20EnergyFeedbackPanel);
      app.MKBLabel.Position = [217 165 34 22];
      app.MKBLabel.Text = 'MKB:';

      % Create DropDown
      app.DropDown = uidropdown(app.BC20EnergyFeedbackPanel);
      app.DropDown.Items = {'S20_ENERGY_3AND4', 'S20_ENERGY_4AND5'};
      app.DropDown.ValueChangedFcn = createCallbackFcn(app, @DropDownValueChanged, true);
      app.DropDown.Position = [262 165 189 22];
      app.DropDown.Value = 'S20_ENERGY_3AND4';

      % Create BC20_C1Lab
      app.BC20_C1Lab = uilabel(app.BC20EnergyFeedbackPanel);
      app.BC20_C1Lab.HorizontalAlignment = 'right';
      app.BC20_C1Lab.Position = [204 131 127 22];
      app.BC20_C1Lab.Text = 'LI19:KLYS:31:PDES';

      % Create BC20_C2Lab
      app.BC20_C2Lab = uilabel(app.BC20EnergyFeedbackPanel);
      app.BC20_C2Lab.Position = [338 131 127 22];
      app.BC20_C2Lab.Text = 'LI19:KLYS:41:PDES';

      % Create Gauge_19
      app.Gauge_19 = uigauge(app.BC20EnergyFeedbackPanel, 'ninetydegree');
      app.Gauge_19.Limits = [-180 0];
      app.Gauge_19.Orientation = 'southwest';
      app.Gauge_19.ScaleDirection = 'counterclockwise';
      app.Gauge_19.Position = [245 43 90 90];
      app.Gauge_19.Value = -60;

      % Create Gauge_20
      app.Gauge_20 = uigauge(app.BC20EnergyFeedbackPanel, 'ninetydegree');
      app.Gauge_20.Limits = [0 180];
      app.Gauge_20.Orientation = 'southeast';
      app.Gauge_20.ScaleDirection = 'counterclockwise';
      app.Gauge_20.Position = [335 43 90 90];
      app.Gauge_20.Value = 60;

      % Create EditField_17
      app.EditField_17 = uieditfield(app.BC20EnergyFeedbackPanel, 'numeric');
      app.EditField_17.Editable = 'off';
      app.EditField_17.HorizontalAlignment = 'center';
      app.EditField_17.FontSize = 10;
      app.EditField_17.Position = [273 15 125 22];

      % Create Gauge_7
      app.Gauge_7 = uigauge(app.BC20EnergyFeedbackPanel, 'linear');
      app.Gauge_7.Limits = [-100 100];
      app.Gauge_7.MajorTicks = [-100 -60 -20 20 60 100];
      app.Gauge_7.MajorTickLabels = {''};
      app.Gauge_7.MinorTicks = [-100 -92 -84 -76 -68 -60 -52 -44 -36 -28 -20 -12 -4 4 12 20 28 36 44 52 60 68 76 84 92 100];
      app.Gauge_7.ScaleColors = [1 0 0;1 0 0;0.3922 0.8314 0.0745];
      app.Gauge_7.ScaleColorLimits = [-100 -75;75 100;-25 25];
      app.Gauge_7.FontSize = 10;
      app.Gauge_7.Position = [88 56 125 29];

      % Create BC11EnergyFeedbackPanel
      app.BC11EnergyFeedbackPanel = uipanel(app.FACETIIFeedbackUIFigure);
      app.BC11EnergyFeedbackPanel.ForegroundColor = [0.851 0.3255 0.098];
      app.BC11EnergyFeedbackPanel.Title = 'BC11 Energy Feedback';
      app.BC11EnergyFeedbackPanel.FontWeight = 'bold';
      app.BC11EnergyFeedbackPanel.Position = [502 428 472 138];

      % Create SetpointEditField_5
      app.SetpointEditField_5 = uieditfield(app.BC11EnergyFeedbackPanel, 'numeric');
      app.SetpointEditField_5.ValueChangedFcn = createCallbackFcn(app, @SetpointEditField_5ValueChanged, true);
      app.SetpointEditField_5.HorizontalAlignment = 'center';
      app.SetpointEditField_5.Position = [17 49 100 29];

      % Create mmLabel_6
      app.mmLabel_6 = uilabel(app.BC11EnergyFeedbackPanel);
      app.mmLabel_6.FontSize = 16;
      app.mmLabel_6.Position = [123 50 58 29];
      app.mmLabel_6.Text = 'mm';

      % Create StatusLamp_5
      app.StatusLamp_5 = uilamp(app.BC11EnergyFeedbackPanel);
      app.StatusLamp_5.Position = [5 82 31 31];
      app.StatusLamp_5.Color = [0 0 0];

      % Create Switch_5
      app.Switch_5 = uiswitch(app.BC11EnergyFeedbackPanel, 'slider');
      app.Switch_5.ValueChangedFcn = createCallbackFcn(app, @Switch_5ValueChanged, true);
      app.Switch_5.Position = [66 12 62 28];

      % Create Gauge_9
      app.Gauge_9 = uigauge(app.BC11EnergyFeedbackPanel, 'linear');
      app.Gauge_9.FontSize = 10;
      app.Gauge_9.Position = [334 33 126 29];
      app.Gauge_9.Value = 40;

      % Create KLYSLI111121SSSB_ADESLabel
      app.KLYSLI111121SSSB_ADESLabel = uilabel(app.BC11EnergyFeedbackPanel);
      app.KLYSLI111121SSSB_ADESLabel.HorizontalAlignment = 'center';
      app.KLYSLI111121SSSB_ADESLabel.Position = [298 61 175 22];
      app.KLYSLI111121SSSB_ADESLabel.Text = 'KLYS:LI11:11&21:SSSB_ADES';

      % Create BPMSLI11333X1HLabel
      app.BPMSLI11333X1HLabel = uilabel(app.BC11EnergyFeedbackPanel);
      app.BPMSLI11333X1HLabel.Position = [178 61 117 22];
      app.BPMSLI11333X1HLabel.Text = 'BPMS:LI11:333:X1H';

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

      % Create Gauge_8
      app.Gauge_8 = uigauge(app.BC11EnergyFeedbackPanel, 'linear');
      app.Gauge_8.Limits = [-100 100];
      app.Gauge_8.MajorTicks = [-100 -60 -20 20 60 100];
      app.Gauge_8.MajorTickLabels = {''};
      app.Gauge_8.MinorTicks = [-100 -92 -84 -76 -68 -60 -52 -44 -36 -28 -20 -12 -4 4 12 20 28 36 44 52 60 68 76 84 92 100];
      app.Gauge_8.ScaleColors = [1 0 0;1 0 0;0.3922 0.8314 0.0745];
      app.Gauge_8.ScaleColorLimits = [-100 -75;75 100;-25 25];
      app.Gauge_8.FontSize = 10;
      app.Gauge_8.Position = [185 33 125 29];

      % Create BC11BunchLengthFeedbackPanel
      app.BC11BunchLengthFeedbackPanel = uipanel(app.FACETIIFeedbackUIFigure);
      app.BC11BunchLengthFeedbackPanel.ForegroundColor = [0.851 0.3255 0.098];
      app.BC11BunchLengthFeedbackPanel.Title = 'BC11 Bunch Length Feedback';
      app.BC11BunchLengthFeedbackPanel.FontWeight = 'bold';
      app.BC11BunchLengthFeedbackPanel.Position = [502 281 472 138];

      % Create SetpointEditField_6
      app.SetpointEditField_6 = uieditfield(app.BC11BunchLengthFeedbackPanel, 'numeric');
      app.SetpointEditField_6.ValueChangedFcn = createCallbackFcn(app, @SetpointEditField_6ValueChanged, true);
      app.SetpointEditField_6.HorizontalAlignment = 'center';
      app.SetpointEditField_6.Position = [17 47 100 29];
      app.SetpointEditField_6.Value = 0.4;

      % Create eguLabel
      app.eguLabel = uilabel(app.BC11BunchLengthFeedbackPanel);
      app.eguLabel.FontSize = 16;
      app.eguLabel.Position = [130 50 32 22];
      app.eguLabel.Text = 'egu';

      % Create Gauge_10
      app.Gauge_10 = uigauge(app.BC11BunchLengthFeedbackPanel, 'linear');
      app.Gauge_10.Limits = [0.1 1];
      app.Gauge_10.FontSize = 10;
      app.Gauge_10.Position = [184 30 126 33];
      app.Gauge_10.Value = 0.4;

      % Create StatusLamp_6
      app.StatusLamp_6 = uilamp(app.BC11BunchLengthFeedbackPanel);
      app.StatusLamp_6.Position = [7 82 32 32];
      app.StatusLamp_6.Color = [0 0 0];

      % Create Switch_6
      app.Switch_6 = uiswitch(app.BC11BunchLengthFeedbackPanel, 'slider');
      app.Switch_6.ValueChangedFcn = createCallbackFcn(app, @Switch_6ValueChanged, true);
      app.Switch_6.Position = [66 10 62 28];

      % Create Gauge_11
      app.Gauge_11 = uigauge(app.BC11BunchLengthFeedbackPanel, 'linear');
      app.Gauge_11.Limits = [0 10];
      app.Gauge_11.FontSize = 10;
      app.Gauge_11.Position = [334 29 126 33];

      % Create KLYSLI111121SSSB_PDESLabel
      app.KLYSLI111121SSSB_PDESLabel = uilabel(app.BC11BunchLengthFeedbackPanel);
      app.KLYSLI111121SSSB_PDESLabel.HorizontalAlignment = 'center';
      app.KLYSLI111121SSSB_PDESLabel.Position = [296.5 63 175 22];
      app.KLYSLI111121SSSB_PDESLabel.Text = 'KLYS:LI11:11&21:SSSB_PDES';

      % Create BLENLI11359Label
      app.BLENLI11359Label = uilabel(app.BC11BunchLengthFeedbackPanel);
      app.BLENLI11359Label.HorizontalAlignment = 'center';
      app.BLENLI11359Label.Position = [186 61 88 22];
      app.BLENLI11359Label.Text = 'BLEN:LI11:359';

      % Create EditField_13
      app.EditField_13 = uieditfield(app.BC11BunchLengthFeedbackPanel, 'numeric');
      app.EditField_13.Editable = 'off';
      app.EditField_13.HorizontalAlignment = 'center';
      app.EditField_13.FontSize = 10;
      app.EditField_13.Position = [184 6 126 22];

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
      app.BC14BunchLengthFeedbackPanel.Position = [22 7 473 133];

      % Create SetpointEditField_7
      app.SetpointEditField_7 = uieditfield(app.BC14BunchLengthFeedbackPanel, 'numeric');
      app.SetpointEditField_7.ValueChangedFcn = createCallbackFcn(app, @SetpointEditField_7ValueChanged, true);
      app.SetpointEditField_7.HorizontalAlignment = 'center';
      app.SetpointEditField_7.Position = [17 48 100 29];
      app.SetpointEditField_7.Value = 50;

      % Create fsLabel
      app.fsLabel = uilabel(app.BC14BunchLengthFeedbackPanel);
      app.fsLabel.FontSize = 16;
      app.fsLabel.Position = [128 53 25 22];
      app.fsLabel.Text = 'fs';

      % Create Gauge_13
      app.Gauge_13 = uigauge(app.BC14BunchLengthFeedbackPanel, 'linear');
      app.Gauge_13.Limits = [-180 180];
      app.Gauge_13.FontSize = 10;
      app.Gauge_13.Position = [334 30 126 35];

      % Create L2PHASELabel
      app.L2PHASELabel = uilabel(app.BC14BunchLengthFeedbackPanel);
      app.L2PHASELabel.HorizontalAlignment = 'center';
      app.L2PHASELabel.Position = [338 63 120 22];
      app.L2PHASELabel.Text = 'L2 PHASE';

      % Create BLENLI14888Label
      app.BLENLI14888Label = uilabel(app.BC14BunchLengthFeedbackPanel);
      app.BLENLI14888Label.HorizontalAlignment = 'center';
      app.BLENLI14888Label.Position = [192 64 113 22];
      app.BLENLI14888Label.Text = 'BLEN:LI14:888';

      % Create EditField_15
      app.EditField_15 = uieditfield(app.BC14BunchLengthFeedbackPanel, 'numeric');
      app.EditField_15.Editable = 'off';
      app.EditField_15.HorizontalAlignment = 'center';
      app.EditField_15.FontSize = 10;
      app.EditField_15.Position = [185 7 125 22];

      % Create EditField_16
      app.EditField_16 = uieditfield(app.BC14BunchLengthFeedbackPanel, 'numeric');
      app.EditField_16.Editable = 'off';
      app.EditField_16.HorizontalAlignment = 'center';
      app.EditField_16.FontSize = 10;
      app.EditField_16.Position = [334 7 125 22];

      % Create StatusLamp_7
      app.StatusLamp_7 = uilamp(app.BC14BunchLengthFeedbackPanel);
      app.StatusLamp_7.Position = [5 80 30 30];
      app.StatusLamp_7.Color = [0 0 0];

      % Create NotRunningButton_7
      app.NotRunningButton_7 = uibutton(app.BC14BunchLengthFeedbackPanel, 'push');
      app.NotRunningButton_7.FontSize = 8;
      app.NotRunningButton_7.FontWeight = 'bold';
      app.NotRunningButton_7.Position = [46 86 417 22];
      app.NotRunningButton_7.Text = 'Not Running';

      % Create Switch_7
      app.Switch_7 = uiswitch(app.BC14BunchLengthFeedbackPanel, 'slider');
      app.Switch_7.ValueChangedFcn = createCallbackFcn(app, @Switch_7ValueChanged, true);
      app.Switch_7.Position = [51 11 62 28];

      % Create Gauge_12
      app.Gauge_12 = uigauge(app.BC14BunchLengthFeedbackPanel, 'linear');
      app.Gauge_12.Limits = [-100 100];
      app.Gauge_12.MajorTicks = [-100 -60 -20 20 60 100];
      app.Gauge_12.MajorTickLabels = {''};
      app.Gauge_12.MinorTicks = [-100 -92 -84 -76 -68 -60 -52 -44 -36 -28 -20 -12 -4 4 12 20 28 36 44 52 60 68 76 84 92 100];
      app.Gauge_12.ScaleColors = [1 0 0;1 0 0;0.3922 0.8314 0.0745];
      app.Gauge_12.ScaleColorLimits = [-100 -75;75 100;-25 25];
      app.Gauge_12.FontSize = 10;
      app.Gauge_12.Position = [186 32 125 32];

      % Create FeedbackWatcherProcessStatusPanel
      app.FeedbackWatcherProcessStatusPanel = uipanel(app.FACETIIFeedbackUIFigure);
      app.FeedbackWatcherProcessStatusPanel.Title = 'Feedback Watcher Process Status';
      app.FeedbackWatcherProcessStatusPanel.Position = [22 573 951 67];

      % Create fbstat
      app.fbstat = uilabel(app.FeedbackWatcherProcessStatusPanel);
      app.fbstat.HorizontalAlignment = 'center';
      app.fbstat.FontSize = 18;
      app.fbstat.FontWeight = 'bold';
      app.fbstat.FontColor = [0.851 0.3294 0.102];
      app.fbstat.Position = [231 12 509 23];
      app.fbstat.Text = 'MATLAB Watcher Process STOPPED - All Feedbacks OFF';

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