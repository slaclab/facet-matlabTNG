classdef F2_Wirescan_exported < matlab.apps.AppBase

  % Properties that correspond to app components
  properties (Access = public)
    F2_WirescanUIFigure           matlab.ui.Figure
    DataMenu                      matlab.ui.container.Menu
    LoadMenu                      matlab.ui.container.Menu
    SaveAsMenu                    matlab.ui.container.Menu
    ExpertMenu                    matlab.ui.container.Menu
    EDMPanelMenu                  matlab.ui.container.Menu
    GridLayout                    matlab.ui.container.GridLayout
    LeftPanel                     matlab.ui.container.Panel
    MeasurementPanel              matlab.ui.container.Panel
    WIREDropDownLabel             matlab.ui.control.Label
    WIREDropDown                  matlab.ui.control.DropDown
    StartScanButton               matlab.ui.control.Button
    AbortScanButton               matlab.ui.control.Button
    MeasurementPlaneButtonGroup   matlab.ui.container.ButtonGroup
    XButton                       matlab.ui.control.RadioButton
    YButton                       matlab.ui.control.RadioButton
    UButton                       matlab.ui.control.RadioButton
    PMTDropDownLabel              matlab.ui.control.Label
    PMTDropDown                   matlab.ui.control.DropDown
    ProcessingPanel               matlab.ui.container.Panel
    JitterCorrectionCheckBox      matlab.ui.control.CheckBox
    ChargeNormalizationCheckBox   matlab.ui.control.CheckBox
    BunchLengthWindowingCheckBox  matlab.ui.control.CheckBox
    TORODropDownLabel             matlab.ui.control.Label
    TORODropDown                  matlab.ui.control.DropDown
    BLENDropDownLabel             matlab.ui.control.Label
    BLENDropDown                  matlab.ui.control.DropDown
    BPM1DropDownLabel             matlab.ui.control.Label
    BPM1DropDown                  matlab.ui.control.DropDown
    BPM2DropDownLabel             matlab.ui.control.Label
    BPM2DropDown                  matlab.ui.control.DropDown
    EditField_3                   matlab.ui.control.NumericEditField
    EditField_4                   matlab.ui.control.NumericEditField
    Label                         matlab.ui.control.Label
    Label_2                       matlab.ui.control.Label
    Label_3                       matlab.ui.control.Label
    Label_4                       matlab.ui.control.Label
    FitMethodDropDownLabel        matlab.ui.control.Label
    FitMethodDropDown             matlab.ui.control.DropDown
    RightPanel                    matlab.ui.container.Panel
    UIAxes                        matlab.ui.control.UIAxes
    EditField                     matlab.ui.control.NumericEditField
    EditField_2                   matlab.ui.control.NumericEditField
    UnitsDropDownLabel            matlab.ui.control.Label
    UnitsDropDown                 matlab.ui.control.DropDown
    PulsesEditField               matlab.ui.control.NumericEditField
    ScanSuccessLampLabel          matlab.ui.control.Label
    ScanSuccessLamp               matlab.ui.control.Lamp
    FitWidthumLabel               matlab.ui.control.Label
    ScanWidth                     matlab.ui.control.NumericEditField
    FitCenterumLabel              matlab.ui.control.Label
    ScanCenter                    matlab.ui.control.NumericEditField
    Label_5                       matlab.ui.control.Label
    ScanWidthError                matlab.ui.control.NumericEditField
    Label_6                       matlab.ui.control.Label
    ScanCenterError               matlab.ui.control.NumericEditField
    Button                        matlab.ui.control.Button
    Label_7                       matlab.ui.control.Label
    umLabel                       matlab.ui.control.Label
  end

  % Properties that correspond to apps with auto-reflow
  properties (Access = private)
    onePanelWidth = 576;
  end

  
  properties (Access = public)
    aobj % F2_WirescanApp object
  end
  

  % Callbacks that handle component events
  methods (Access = private)

    % Code that executes after component creation
    function startupFcn(app, LLM, iwire, dim)
      if exist('LLM','var') && ~isempty(LLM)
        if exist('iwire','var')
          app.aobj = F2_WirescanApp(LLM,iwire,dim) ;
        else
          app.aobj = F2_WirescanApp(LLM) ;
        end
      elseif exist('iwire','var')
        app.aobj = F2_WirescanApp([],iwire,dim) ;
      else
        app.aobj = F2_WirescanApp();
      end
      app.aobj.AttachGUI(app); % also updates app GUI fields
    end

    % Changes arrangement of the app based on UIFigure width
    function updateAppLayout(app, event)
            currentFigureWidth = app.F2_WirescanUIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {595, 595};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {297, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
    end

    % Menu selected function: EDMPanelMenu
    function EDMPanelMenuSelected(app, event)
      switch string(app.WIREDropDown.Value)
        case "IN10:561"
          !edm -x -m "DEV=WIRE:IN10:561,MAD=WS10561,AREA=in10,RATEPV=EVNT:SYS1:1:INJECTRATE" /usr/local/facet/tools/edm/display/ws/wirescannerstart.edl &
        case "LI11:444"
          !edm -x -m "DEV=WIRE:LI11:444,MAD=WS11444,AREA=li11,RATEPV=EVNT:SYS1:1:INJECTRATE" /usr/local/facet/tools/edm/display/ws/wirescannerstart.edl &
        case "LI11:614"
          !edm -x -m "DEV=WIRE:LI11:614,MAD=WS11614,AREA=li11,RATEPV=EVNT:SYS1:1:INJECTRATE" /usr/local/facet/tools/edm/display/ws/wirescannerstart.edl &
        case "LI11:744"
          !edm -x -m "DEV=WIRE:LI11:744,MAD=WS11744,AREA=li11,RATEPV=EVNT:SYS1:1:INJECTRATE" /usr/local/facet/tools/edm/display/ws/wirescannerstart.edl &
        case "LI12:214"
          !edm -x -m "DEV=WIRE:LI12:214,MAD=WS12214,AREA=li12,RATEPV=EVNT:SYS1:1:INJECTRATE" /usr/local/facet/tools/edm/display/ws/wirescannerstart.edl &
        case "LI18:944"
          !edm -x -m "DEV=WIRE:LI18:944,MAD=WS18944,AREA=li18,RATEPV=EVNT:SYS1:1:INJECTRATE" /usr/local/facet/tools/edm/display/ws/wirescannerstart.edl &
        case "LI19:144"
          !edm -x -m "DEV=WIRE:LI19:144,MAD=WS19144,AREA=li19,RATEPV=EVNT:SYS1:1:INJECTRATE" /usr/local/facet/tools/edm/display/ws/wirescannerstart.edl &
        case "LI19:244"
          !edm -x -m "DEV=WIRE:LI19:244,MAD=WS19244,AREA=li19,RATEPV=EVNT:SYS1:1:INJECTRATE" /usr/local/facet/tools/edm/display/ws/wirescannerstart.edl &
        case "LI19:344"
          !edm -x -m "DEV=WIRE:LI19:344,MAD=WS19344,AREA=li19,RATEPV=EVNT:SYS1:1:INJECTRATE" /usr/local/facet/tools/edm/display/ws/wirescannerstart.edl &
        case "LI20:3179"
          !edm -x -m "DEV=WIRE:LI20:3179,MAD=IPWS1,AREA=li20,RATEPV=EVNT:SYS1:1:INJECTRATE" /usr/local/facet/tools/edm/display/ws/wirescannerstart.edl &
        case "LI20:3206"
          !edm -x -m "DEV=WIRE:LI20:3206,MAD=IPWS3,AREA=li20,RATEPV=EVNT:SYS1:1:INJECTRATE" /usr/local/facet/tools/edm/display/ws/wirescannerstart.edl &
      end
    end

    % Menu selected function: LoadMenu
    function LoadMenuSelected(app, event)
      [fn,pn]=uigetfile(F2C.datadir+"/F2_Wirescan*.mat", 'Pick WS data file');
      if isequal(fn,0)
        return
      end
      app.aobj.confload(fullfile(pn,fn));
    end

    % Menu selected function: SaveAsMenu
    function SaveAsMenuSelected(app, event)
      [fn,pn]=uiputfile(F2C.datadir, 'WS data file');
      if isequal(fn,0)
        return
      end
      app.aobj.confsave(fullfile(pn,fn));
    end

    % Selection changed function: MeasurementPlaneButtonGroup
    function MeasurementPlaneButtonGroupSelectionChanged(app, event)
      app.aobj.ResetData;
      cla(app.UIAxes); reset(app.UIAxes);
      selectedButton = app.MeasurementPlaneButtonGroup.SelectedObject;
      switch selectedButton
        case app.XButton
          app.aobj.plane="x";
        case app.YButton
          app.aobj.plane="y";
        case app.UButton
          app.aobj.plane="u";
      end
      app.aobj.guiupdate;
    end

    % Value changed function: WIREDropDown
    function WIREDropDownValueChanged(app, event)
      app.aobj.ResetData;
      cla(app.UIAxes); reset(app.UIAxes);
      value = app.WIREDropDown.Value;
      app.aobj.wirename = string(value) ;
      app.aobj.guiupdate;
    end

    % Value changed function: PMTDropDown
    function PMTDropDownValueChanged(app, event)
      app.aobj.ResetData;
      cla(app.UIAxes); reset(app.UIAxes);
      value = app.PMTDropDown.Value;
      app.aobj.pmtname = value ;
      app.aobj.guiupdate;
    end

    % Button pushed function: StartScanButton
    function StartScanButtonPushed(app, event)
      app.ScanSuccessLamp.Color='r';
      app.aobj.ResetData;
      cla(app.UIAxes); reset(app.UIAxes); axis(app.UIAxes,'off');
      rectangle(app.UIAxes,'Position',[0,0.4,0/100,0.2],'facecolor','g');axis(app.UIAxes,[0 1 0 1]);
      title(app.UIAxes,'Scan Progress...');
      text(app.UIAxes,max([0 0/100-0.1]),0.5,sprintf('%.1f %%',0));
      drawnow
      try
        app.aobj.StartScan ;
      catch ME
        errordlg("Scan failed - see xterm window","Scan Failed");
        eDefRelease(app.aobj.edef);
        throw(ME);
      end
    end

    % Button pushed function: AbortScanButton
    function AbortScanButtonPushed(app, event)
      app.aobj.AbortScan=true ;
    end

    % Value changed function: JitterCorrectionCheckBox
    function JitterCorrectionCheckBoxValueChanged(app, event)
      value = app.JitterCorrectionCheckBox.Value;
      app.aobj.jittercor = value;
      app.aobj.guiupdate ;
      app.aobj.ProcData;
    end

    % Value changed function: BPM1DropDown
    function BPM1DropDownValueChanged(app, event)
      app.aobj.ResetData;
      cla(app.UIAxes); reset(app.UIAxes);
      value = "BPMS:"+app.BPM1DropDown.Value;
      isel = find(app.aobj.bpms==value);
      if ~isempty(isel)
        app.aobj.bpmsel(1)=isel;
      end
      app.aobj.guiupdate;
    end

    % Value changed function: ChargeNormalizationCheckBox
    function ChargeNormalizationCheckBoxValueChanged(app, event)
      value = app.ChargeNormalizationCheckBox.Value;
      app.aobj.chargenorm = value ;
      app.aobj.guiupdate;
      app.aobj.ProcData;
    end

    % Value changed function: TORODropDown
    function TORODropDownValueChanged(app, event)
      app.aobj.ResetData;
      cla(app.UIAxes); reset(app.UIAxes);
      value = app.TORODropDown.Value;
      app.aobj.toroname = value ;
      app.aobj.guiupdate;
    end

    % Value changed function: BunchLengthWindowingCheckBox
    function BunchLengthWindowingCheckBoxValueChanged(app, event)
      value = app.BunchLengthWindowingCheckBox.Value;
      app.aobj.blenwin = value ;
      app.aobj.guiupdate ;
      app.aobj.ProcData;
    end

    % Value changed function: BLENDropDown
    function BLENDropDownValueChanged(app, event)
      value = app.BLENDropDown.Value;
      app.aobj.blmname = value ;
      app.aobj.guiupdate;
    end

    % Value changed function: EditField_3
    function EditField_3ValueChanged(app, event)
      val1 = app.EditField_3.Value;
      val2 = app.EditField_4.Value;
      app.aobj.blenwin=[val1 val2];
      app.aobj.guiupdate;
    end

    % Value changed function: EditField_4
    function EditField_4ValueChanged(app, event)
      val1 = app.EditField_3.Value;
      val2 = app.EditField_4.Value;
      app.aobj.blenwin=[val1 val2];
      app.aobj.guiupdate;
    end

    % Value changed function: UnitsDropDown
    function UnitsDropDownValueChanged(app, event)
      app.aobj.guiupdate;
    end

    % Value changed function: EditField
    function EditFieldValueChanged(app, event)
      val1 = app.EditField.Value;
      val2 = app.EditField_2.Value;
      switch app.UnitsDropDown.Value
        case "Position"
          app.aobj.pos_range=[val1 val2].*1e-6;
        otherwise
          app.aobj.motor_range=[val1 val2].*1e-6;
      end
      app.aobj.guiupdate;
    end

    % Value changed function: EditField_2
    function EditField_2ValueChanged(app, event)
      val1 = app.EditField.Value;
      val2 = app.EditField_2.Value;
      switch app.UnitsDropDown.Value
        case "Position"
          app.aobj.pos_range=[val1 val2].*1e-6;
        otherwise
          app.aobj.motor_range=[val1 val2].*1e-6;
      end
      app.aobj.guiupdate;
    end

    % Value changed function: PulsesEditField
    function PulsesEditFieldValueChanged(app, event)
      value = app.PulsesEditField.Value;
      app.aobj.npulses = value ;
      app.aobj.guiupdate;
    end

    % Button pushed function: Button
    function ButtonPushed(app, event)
      fh=figure; ahan=axes(fh);
      app.aobj.ProcData(ahan);
      txt=sprintf('Fit method = %s\nFit Width = %.2f +/- %.2f (um)\nFit Center = %.2f +/- %.2f (um)',...
        app.aobj.fitmethod,app.ScanWidth.Value,app.ScanWidthError.Value,app.ScanCenter.Value,app.ScanCenterError.Value) ;
      util_printLog2020(fh, 'title',sprintf('%s Wire Scan (%c)',char(app.aobj.wirename),char(app.aobj.plane)),'author','F2_Wirescan.m','text',txt);
      delete(fh);
    end

    % Value changed function: FitMethodDropDown
    function FitMethodDropDownValueChanged(app, event)
      value = app.FitMethodDropDown.Value;
      switch string(value)
        case "Gaussian"
          app.aobj.fitmethod="gauss";
        case "Asymmetric Gaussian"
          app.aobj.fitmethod="agauss";
      end
      app.aobj.ProcData;
    end

    % Value changed function: BPM2DropDown
    function BPM2DropDownValueChanged(app, event)
      app.aobj.ResetData;
      cla(app.UIAxes); reset(app.UIAxes);
      value = "BPMS:"+app.BPM2DropDown.Value;
      isel = find(app.aobj.bpms==value);
      if ~isempty(isel)
        app.aobj.bpmsel(2)=isel;
      end
      app.aobj.guiupdate;
    end
  end

  % Component initialization
  methods (Access = private)

    % Create UIFigure and components
    function createComponents(app)

      % Create F2_WirescanUIFigure and hide until all components are created
      app.F2_WirescanUIFigure = uifigure('Visible', 'off');
      app.F2_WirescanUIFigure.AutoResizeChildren = 'off';
      app.F2_WirescanUIFigure.Position = [100 100 996 595];
      app.F2_WirescanUIFigure.Name = 'F2_Wirescan';
      app.F2_WirescanUIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

      % Create DataMenu
      app.DataMenu = uimenu(app.F2_WirescanUIFigure);
      app.DataMenu.Text = 'Data';

      % Create LoadMenu
      app.LoadMenu = uimenu(app.DataMenu);
      app.LoadMenu.MenuSelectedFcn = createCallbackFcn(app, @LoadMenuSelected, true);
      app.LoadMenu.Text = 'Load...';

      % Create SaveAsMenu
      app.SaveAsMenu = uimenu(app.DataMenu);
      app.SaveAsMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveAsMenuSelected, true);
      app.SaveAsMenu.Text = 'Save As...';

      % Create ExpertMenu
      app.ExpertMenu = uimenu(app.F2_WirescanUIFigure);
      app.ExpertMenu.Text = 'Expert';

      % Create EDMPanelMenu
      app.EDMPanelMenu = uimenu(app.ExpertMenu);
      app.EDMPanelMenu.MenuSelectedFcn = createCallbackFcn(app, @EDMPanelMenuSelected, true);
      app.EDMPanelMenu.Text = 'EDM Panel...';

      % Create GridLayout
      app.GridLayout = uigridlayout(app.F2_WirescanUIFigure);
      app.GridLayout.ColumnWidth = {297, '1x'};
      app.GridLayout.RowHeight = {'1x'};
      app.GridLayout.ColumnSpacing = 0;
      app.GridLayout.RowSpacing = 0;
      app.GridLayout.Padding = [0 0 0 0];
      app.GridLayout.Scrollable = 'on';

      % Create LeftPanel
      app.LeftPanel = uipanel(app.GridLayout);
      app.LeftPanel.Layout.Row = 1;
      app.LeftPanel.Layout.Column = 1;

      % Create MeasurementPanel
      app.MeasurementPanel = uipanel(app.LeftPanel);
      app.MeasurementPanel.Title = 'Measurement';
      app.MeasurementPanel.Position = [21 372 260 213];

      % Create WIREDropDownLabel
      app.WIREDropDownLabel = uilabel(app.MeasurementPanel);
      app.WIREDropDownLabel.HorizontalAlignment = 'right';
      app.WIREDropDownLabel.Position = [13 106 39 22];
      app.WIREDropDownLabel.Text = 'WIRE:';

      % Create WIREDropDown
      app.WIREDropDown = uidropdown(app.MeasurementPanel);
      app.WIREDropDown.Items = {'IN10:561', 'LI11:444', 'LI11:614', 'LI11:744', 'LI12:214', 'LI18:944', 'LI19:144', 'LI19:244', 'LI19:344'};
      app.WIREDropDown.ValueChangedFcn = createCallbackFcn(app, @WIREDropDownValueChanged, true);
      app.WIREDropDown.Position = [67 106 144 22];
      app.WIREDropDown.Value = 'IN10:561';

      % Create StartScanButton
      app.StartScanButton = uibutton(app.MeasurementPanel, 'push');
      app.StartScanButton.ButtonPushedFcn = createCallbackFcn(app, @StartScanButtonPushed, true);
      app.StartScanButton.BackgroundColor = [0.4667 0.6745 0.1882];
      app.StartScanButton.FontWeight = 'bold';
      app.StartScanButton.Position = [14 41 229 30];
      app.StartScanButton.Text = 'Start Scan';

      % Create AbortScanButton
      app.AbortScanButton = uibutton(app.MeasurementPanel, 'push');
      app.AbortScanButton.ButtonPushedFcn = createCallbackFcn(app, @AbortScanButtonPushed, true);
      app.AbortScanButton.BackgroundColor = [0.851 0.3255 0.098];
      app.AbortScanButton.FontWeight = 'bold';
      app.AbortScanButton.Position = [14 7 229 30];
      app.AbortScanButton.Text = 'Abort Scan';

      % Create MeasurementPlaneButtonGroup
      app.MeasurementPlaneButtonGroup = uibuttongroup(app.MeasurementPanel);
      app.MeasurementPlaneButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @MeasurementPlaneButtonGroupSelectionChanged, true);
      app.MeasurementPlaneButtonGroup.Title = 'Measurement Plane';
      app.MeasurementPlaneButtonGroup.Position = [10 138 241 48];

      % Create XButton
      app.XButton = uiradiobutton(app.MeasurementPlaneButtonGroup);
      app.XButton.Text = 'X';
      app.XButton.Position = [11 2 58 22];
      app.XButton.Value = true;

      % Create YButton
      app.YButton = uiradiobutton(app.MeasurementPlaneButtonGroup);
      app.YButton.Text = 'Y';
      app.YButton.Position = [88 2 65 22];

      % Create UButton
      app.UButton = uiradiobutton(app.MeasurementPlaneButtonGroup);
      app.UButton.Text = 'U';
      app.UButton.Position = [172 2 65 22];

      % Create PMTDropDownLabel
      app.PMTDropDownLabel = uilabel(app.MeasurementPanel);
      app.PMTDropDownLabel.HorizontalAlignment = 'right';
      app.PMTDropDownLabel.Position = [12 78 32 22];
      app.PMTDropDownLabel.Text = 'PMT:';

      % Create PMTDropDown
      app.PMTDropDown = uidropdown(app.MeasurementPanel);
      app.PMTDropDown.Items = {'LI19:144'};
      app.PMTDropDown.ValueChangedFcn = createCallbackFcn(app, @PMTDropDownValueChanged, true);
      app.PMTDropDown.Position = [59 78 152 22];
      app.PMTDropDown.Value = 'LI19:144';

      % Create ProcessingPanel
      app.ProcessingPanel = uipanel(app.LeftPanel);
      app.ProcessingPanel.Title = 'Processing';
      app.ProcessingPanel.Position = [21 7 260 359];

      % Create JitterCorrectionCheckBox
      app.JitterCorrectionCheckBox = uicheckbox(app.ProcessingPanel);
      app.JitterCorrectionCheckBox.ValueChangedFcn = createCallbackFcn(app, @JitterCorrectionCheckBoxValueChanged, true);
      app.JitterCorrectionCheckBox.Text = 'Jitter Correction';
      app.JitterCorrectionCheckBox.Position = [12 307 108 22];

      % Create ChargeNormalizationCheckBox
      app.ChargeNormalizationCheckBox = uicheckbox(app.ProcessingPanel);
      app.ChargeNormalizationCheckBox.ValueChangedFcn = createCallbackFcn(app, @ChargeNormalizationCheckBoxValueChanged, true);
      app.ChargeNormalizationCheckBox.Text = 'Charge Normalization';
      app.ChargeNormalizationCheckBox.Position = [13 199 142 22];

      % Create BunchLengthWindowingCheckBox
      app.BunchLengthWindowingCheckBox = uicheckbox(app.ProcessingPanel);
      app.BunchLengthWindowingCheckBox.ValueChangedFcn = createCallbackFcn(app, @BunchLengthWindowingCheckBoxValueChanged, true);
      app.BunchLengthWindowingCheckBox.Enable = 'off';
      app.BunchLengthWindowingCheckBox.Text = 'Bunch Length Windowing';
      app.BunchLengthWindowingCheckBox.Position = [13 119 162 22];

      % Create TORODropDownLabel
      app.TORODropDownLabel = uilabel(app.ProcessingPanel);
      app.TORODropDownLabel.HorizontalAlignment = 'right';
      app.TORODropDownLabel.Position = [10 170 42 22];
      app.TORODropDownLabel.Text = 'TORO:';

      % Create TORODropDown
      app.TORODropDown = uidropdown(app.ProcessingPanel);
      app.TORODropDown.Items = {'IN10:431', 'IN10:591', 'LI11:360', 'LI14:890', 'LI20:1988', 'LI20:2040', 'LI20:2452', 'LI20:3163', 'LI20:3255'};
      app.TORODropDown.ValueChangedFcn = createCallbackFcn(app, @TORODropDownValueChanged, true);
      app.TORODropDown.Position = [67 170 153 22];
      app.TORODropDown.Value = 'IN10:431';

      % Create BLENDropDownLabel
      app.BLENDropDownLabel = uilabel(app.ProcessingPanel);
      app.BLENDropDownLabel.HorizontalAlignment = 'right';
      app.BLENDropDownLabel.Position = [11 91 40 22];
      app.BLENDropDownLabel.Text = 'BLEN:';

      % Create BLENDropDown
      app.BLENDropDown = uidropdown(app.ProcessingPanel);
      app.BLENDropDown.Items = {'---'};
      app.BLENDropDown.ValueChangedFcn = createCallbackFcn(app, @BLENDropDownValueChanged, true);
      app.BLENDropDown.Position = [66 91 145 22];
      app.BLENDropDown.Value = '---';

      % Create BPM1DropDownLabel
      app.BPM1DropDownLabel = uilabel(app.ProcessingPanel);
      app.BPM1DropDownLabel.HorizontalAlignment = 'right';
      app.BPM1DropDownLabel.Position = [13 275 41 22];
      app.BPM1DropDownLabel.Text = 'BPM1:';

      % Create BPM1DropDown
      app.BPM1DropDown = uidropdown(app.ProcessingPanel);
      app.BPM1DropDown.Items = {'---'};
      app.BPM1DropDown.ValueChangedFcn = createCallbackFcn(app, @BPM1DropDownValueChanged, true);
      app.BPM1DropDown.Position = [69 275 100 22];
      app.BPM1DropDown.Value = '---';

      % Create BPM2DropDownLabel
      app.BPM2DropDownLabel = uilabel(app.ProcessingPanel);
      app.BPM2DropDownLabel.HorizontalAlignment = 'right';
      app.BPM2DropDownLabel.Position = [13 245 41 22];
      app.BPM2DropDownLabel.Text = 'BPM2:';

      % Create BPM2DropDown
      app.BPM2DropDown = uidropdown(app.ProcessingPanel);
      app.BPM2DropDown.Items = {'---'};
      app.BPM2DropDown.ValueChangedFcn = createCallbackFcn(app, @BPM2DropDownValueChanged, true);
      app.BPM2DropDown.Position = [69 245 100 22];
      app.BPM2DropDown.Value = '---';

      % Create EditField_3
      app.EditField_3 = uieditfield(app.ProcessingPanel, 'numeric');
      app.EditField_3.ValueChangedFcn = createCallbackFcn(app, @EditField_3ValueChanged, true);
      app.EditField_3.Position = [12 61 100 22];

      % Create EditField_4
      app.EditField_4 = uieditfield(app.ProcessingPanel, 'numeric');
      app.EditField_4.ValueChangedFcn = createCallbackFcn(app, @EditField_4ValueChanged, true);
      app.EditField_4.Position = [141 61 100 22];

      % Create Label
      app.Label = uilabel(app.ProcessingPanel);
      app.Label.Position = [120 61 17 22];
      app.Label.Text = '---';

      % Create Label_2
      app.Label_2 = uilabel(app.ProcessingPanel);
      app.Label_2.Position = [11 144 235 22];
      app.Label_2.Text = '---------------------------------------------------------';

      % Create Label_3
      app.Label_3 = uilabel(app.ProcessingPanel);
      app.Label_3.Position = [12 222 235 22];
      app.Label_3.Text = '---------------------------------------------------------';

      % Create Label_4
      app.Label_4 = uilabel(app.ProcessingPanel);
      app.Label_4.Position = [10 34 235 22];
      app.Label_4.Text = '---------------------------------------------------------';

      % Create FitMethodDropDownLabel
      app.FitMethodDropDownLabel = uilabel(app.ProcessingPanel);
      app.FitMethodDropDownLabel.HorizontalAlignment = 'right';
      app.FitMethodDropDownLabel.Position = [13 8 65 22];
      app.FitMethodDropDownLabel.Text = 'Fit Method:';

      % Create FitMethodDropDown
      app.FitMethodDropDown = uidropdown(app.ProcessingPanel);
      app.FitMethodDropDown.Items = {'Gaussian', 'Asymmetric Gaussian'};
      app.FitMethodDropDown.ValueChangedFcn = createCallbackFcn(app, @FitMethodDropDownValueChanged, true);
      app.FitMethodDropDown.Position = [93 8 154 22];
      app.FitMethodDropDown.Value = 'Asymmetric Gaussian';

      % Create RightPanel
      app.RightPanel = uipanel(app.GridLayout);
      app.RightPanel.Layout.Row = 1;
      app.RightPanel.Layout.Column = 2;

      % Create UIAxes
      app.UIAxes = uiaxes(app.RightPanel);
      title(app.UIAxes, '')
      xlabel(app.UIAxes, 'X')
      ylabel(app.UIAxes, 'Y')
      app.UIAxes.Position = [11 105 677 481];

      % Create EditField
      app.EditField = uieditfield(app.RightPanel, 'numeric');
      app.EditField.ValueDisplayFormat = '%.0f';
      app.EditField.ValueChangedFcn = createCallbackFcn(app, @EditFieldValueChanged, true);
      app.EditField.HorizontalAlignment = 'left';
      app.EditField.Position = [162 14 100 22];

      % Create EditField_2
      app.EditField_2 = uieditfield(app.RightPanel, 'numeric');
      app.EditField_2.ValueDisplayFormat = '%.0f';
      app.EditField_2.ValueChangedFcn = createCallbackFcn(app, @EditField_2ValueChanged, true);
      app.EditField_2.Position = [328 14 100 22];

      % Create UnitsDropDownLabel
      app.UnitsDropDownLabel = uilabel(app.RightPanel);
      app.UnitsDropDownLabel.HorizontalAlignment = 'right';
      app.UnitsDropDownLabel.Position = [6 14 36 22];
      app.UnitsDropDownLabel.Text = 'Units:';

      % Create UnitsDropDown
      app.UnitsDropDown = uidropdown(app.RightPanel);
      app.UnitsDropDown.Items = {'Motor', 'Position'};
      app.UnitsDropDown.ValueChangedFcn = createCallbackFcn(app, @UnitsDropDownValueChanged, true);
      app.UnitsDropDown.Position = [57 14 100 22];
      app.UnitsDropDown.Value = 'Position';

      % Create PulsesEditField
      app.PulsesEditField = uieditfield(app.RightPanel, 'numeric');
      app.PulsesEditField.ValueChangedFcn = createCallbackFcn(app, @PulsesEditFieldValueChanged, true);
      app.PulsesEditField.HorizontalAlignment = 'center';
      app.PulsesEditField.Position = [270 14 48 22];
      app.PulsesEditField.Value = 100;

      % Create ScanSuccessLampLabel
      app.ScanSuccessLampLabel = uilabel(app.RightPanel);
      app.ScanSuccessLampLabel.HorizontalAlignment = 'right';
      app.ScanSuccessLampLabel.Position = [473 14 85 22];
      app.ScanSuccessLampLabel.Text = 'Scan Success:';

      % Create ScanSuccessLamp
      app.ScanSuccessLamp = uilamp(app.RightPanel);
      app.ScanSuccessLamp.Position = [573 14 20 20];
      app.ScanSuccessLamp.Color = [1 0 0];

      % Create FitWidthumLabel
      app.FitWidthumLabel = uilabel(app.RightPanel);
      app.FitWidthumLabel.HorizontalAlignment = 'right';
      app.FitWidthumLabel.Position = [27 47 83 22];
      app.FitWidthumLabel.Text = 'Fit Width (um):';

      % Create ScanWidth
      app.ScanWidth = uieditfield(app.RightPanel, 'numeric');
      app.ScanWidth.ValueDisplayFormat = '%.1f';
      app.ScanWidth.Editable = 'off';
      app.ScanWidth.Position = [125 47 59 22];

      % Create FitCenterumLabel
      app.FitCenterumLabel = uilabel(app.RightPanel);
      app.FitCenterumLabel.HorizontalAlignment = 'right';
      app.FitCenterumLabel.Position = [323 47 89 22];
      app.FitCenterumLabel.Text = 'Fit Center (um):';

      % Create ScanCenter
      app.ScanCenter = uieditfield(app.RightPanel, 'numeric');
      app.ScanCenter.ValueDisplayFormat = '%.1f';
      app.ScanCenter.Editable = 'off';
      app.ScanCenter.Position = [417 47 92 22];

      % Create Label_5
      app.Label_5 = uilabel(app.RightPanel);
      app.Label_5.HorizontalAlignment = 'right';
      app.Label_5.Position = [187 47 25 22];
      app.Label_5.Text = '+/-';

      % Create ScanWidthError
      app.ScanWidthError = uieditfield(app.RightPanel, 'numeric');
      app.ScanWidthError.ValueDisplayFormat = '%.1f';
      app.ScanWidthError.Editable = 'off';
      app.ScanWidthError.Position = [227 47 60 22];

      % Create Label_6
      app.Label_6 = uilabel(app.RightPanel);
      app.Label_6.HorizontalAlignment = 'right';
      app.Label_6.Position = [507 47 25 22];
      app.Label_6.Text = '+/-';

      % Create ScanCenterError
      app.ScanCenterError = uieditfield(app.RightPanel, 'numeric');
      app.ScanCenterError.ValueDisplayFormat = '%.1f';
      app.ScanCenterError.Editable = 'off';
      app.ScanCenterError.Position = [547 47 60 22];

      % Create Button
      app.Button = uibutton(app.RightPanel, 'push');
      app.Button.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed, true);
      app.Button.Icon = 'logbook.gif';
      app.Button.Position = [616 11 61 64];
      app.Button.Text = '';

      % Create Label_7
      app.Label_7 = uilabel(app.RightPanel);
      app.Label_7.HorizontalAlignment = 'center';
      app.Label_7.Position = [15 78 657 22];
      app.Label_7.Text = '---------------------------------------------------------------------------------------------------------------------------------------------------------------';

      % Create umLabel
      app.umLabel = uilabel(app.RightPanel);
      app.umLabel.Position = [436 14 25 22];
      app.umLabel.Text = 'um';

      % Show the figure after all components are created
      app.F2_WirescanUIFigure.Visible = 'on';
    end
  end

  % App creation and deletion
  methods (Access = public)

    % Construct app
    function app = F2_Wirescan_exported(varargin)

      % Create UIFigure and components
      createComponents(app)

      % Register the app with App Designer
      registerApp(app, app.F2_WirescanUIFigure)

      % Execute the startup function
      runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

      if nargout == 0
        clear app
      end
    end

    % Code that executes before app deletion
    function delete(app)

      % Delete UIFigure when app is deleted
      delete(app.F2_WirescanUIFigure)
    end
  end
end