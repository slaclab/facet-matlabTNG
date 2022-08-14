classdef F2_OrbitBump_exported < matlab.apps.AppBase

  % Properties that correspond to app components
  properties (Access = public)
    FACETIIOrbitBumpsUIFigure   matlab.ui.Figure
    RegionSelectPanel           matlab.ui.container.Panel
    GridLayout                  matlab.ui.container.GridLayout
    INJButton                   matlab.ui.control.StateButton
    L0Button                    matlab.ui.control.StateButton
    DL1Button                   matlab.ui.control.StateButton
    L1Button                    matlab.ui.control.StateButton
    BC11Button                  matlab.ui.control.StateButton
    L2Button                    matlab.ui.control.StateButton
    BC14Button                  matlab.ui.control.StateButton
    L3Button                    matlab.ui.control.StateButton
    BC20Button                  matlab.ui.control.StateButton
    FFSButton                   matlab.ui.control.StateButton
    SPECTButton                 matlab.ui.control.StateButton
    TargetElementPanel          matlab.ui.container.Panel
    ListBox                     matlab.ui.control.ListBox
    SelectBumpPlaneButtonGroup  matlab.ui.container.ButtonGroup
    HorizontalxButton           matlab.ui.control.ToggleButton
    VerticalyButton             matlab.ui.control.ToggleButton
    ZEditFieldLabel             matlab.ui.control.Label
    ZEditField                  matlab.ui.control.NumericEditField
    CorrectorsResponsePanel     matlab.ui.container.Panel
    ListBox_2                   matlab.ui.control.ListBox
    FudgeFactorsusePanel        matlab.ui.container.Panel
    EditField                   matlab.ui.control.NumericEditField
    EditField_2                 matlab.ui.control.NumericEditField
    EditField_3                 matlab.ui.control.NumericEditField
    FITButton                   matlab.ui.control.Button
    CheckBox                    matlab.ui.control.CheckBox
    CheckBox_2                  matlab.ui.control.CheckBox
    CheckBox_3                  matlab.ui.control.CheckBox
    OrbitPlotPanel              matlab.ui.container.Panel
    PlotAxes                    matlab.ui.control.UIAxes
    BumpControlPanel            matlab.ui.container.Panel
    SetmmEditFieldLabel         matlab.ui.control.Label
    BumpVal                     matlab.ui.control.NumericEditField
    BumpDecr                    matlab.ui.control.Button
    BumpChange                  matlab.ui.control.NumericEditField
    BumpIncr                    matlab.ui.control.Button
    CORReadbackmmLabel          matlab.ui.control.Label
    BumpRdb_cor                 matlab.ui.control.NumericEditField
    RangemmEditFieldLabel       matlab.ui.control.Label
    BumpRange                   matlab.ui.control.EditField
    BPMReadbackmmLabel          matlab.ui.control.Label
    BumpRdb_bpm                 matlab.ui.control.NumericEditField
    GOButton                    matlab.ui.control.Button
    OrbitPanel                  matlab.ui.container.Panel
    ReferenceEditFieldLabel     matlab.ui.control.Label
    ReferenceEditField          matlab.ui.control.EditField
    UpdateRefOrbitButton        matlab.ui.control.Button
    NAveEditFieldLabel          matlab.ui.control.Label
    NAveEditField               matlab.ui.control.NumericEditField
    UpdateButton                matlab.ui.control.StateButton
    CorrectorsPanel             matlab.ui.container.Panel
    GridLayout2                 matlab.ui.container.GridLayout
    BDESkGmLabel                matlab.ui.control.Label
    BACTkGmLabel                matlab.ui.control.Label
    dKickmradLabel              matlab.ui.control.Label
    CoefLabel                   matlab.ui.control.Label
    EditField_4                 matlab.ui.control.NumericEditField
    EditField_6                 matlab.ui.control.NumericEditField
    EditField_7                 matlab.ui.control.NumericEditField
    EditField_8                 matlab.ui.control.NumericEditField
    EditField_10                matlab.ui.control.NumericEditField
    EditField_11                matlab.ui.control.NumericEditField
    EditField_12                matlab.ui.control.NumericEditField
    EditField_14                matlab.ui.control.NumericEditField
    EditField_15                matlab.ui.control.NumericEditField
    EditField_16                matlab.ui.control.NumericEditField
    EditField_17                matlab.ui.control.NumericEditField
    EditField_18                matlab.ui.control.NumericEditField
    BPMsPanel                   matlab.ui.container.Panel
    ListBox_3                   matlab.ui.control.ListBox
    CorrectorControlsButton     matlab.ui.control.Button
  end

  
  properties (Access = public)
    aobj % F2_OrbitBump object
  end
  

  % Callbacks that handle component events
  methods (Access = private)

    % Code that executes after component creation
    function startupFcn(app, LLM)
      drawnow;
      if exist('LLM','var')
        app.aobj = F2_OrbitBumpApp(app,LLM);
      else
        app.aobj = F2_OrbitBumpApp(app) ;
      end
      app.INJButtonValueChanged;
    end

    % Value changed function: BC11Button, BC14Button, 
    % BC20Button, DL1Button, FFSButton, INJButton, L0Button, 
    % L1Button, L2Button, L3Button, SPECTButton
    function INJButtonValueChanged(app, event)
      
      value = [app.INJButton.Value app.L0Button.Value app.DL1Button.Value app.L1Button.Value ...
        app.BC11Button.Value app.L2Button.Value app.BC14Button.Value app.L3Button.Value ...
        app.BC20Button.Value app.FFSButton.Value app.SPECTButton.Value] ;
      if exist('even','var')
        regname=["INJ" "L0" "DL1" "L1" "BC11" "L2" "BC14" "L3" "BC20" "FFS" "SPECT"];
        ibut = find(ismember(regname,string(event.Source.Text))) ;
        if ~any(value)
          value(ibut)=1;
        end
        % Ensure selected regions are contiguous
        ireg=find(value);
        if length(ireg)>1
          for regid=2:length(ireg)
            if (ireg(regid)-ireg(regid-1)) > 1
              if ibut==min(ireg)
                ireg = ireg(1:regid-1) ;
                break ;
              else
                ireg(1:regid-1)=[];
              end
            end
          end
        end
        value=false(size(value));
        value(ireg)=true;
        app.INJButton.Value=value(1);
        app.L0Button.Value=value(2);
        app.DL1Button.Value=value(3);
        app.L1Button.Value=value(4);
        app.BC11Button.Value=value(5);
        app.L2Button.Value=value(6);
        app.BC14Button.Value=value(7);
        app.L3Button.Value=value(8);
        app.BC20Button.Value=value(9);
        app.FFSButton.Value=value(10);
        app.SPECTButton.Value=value(11);
      end
      drawnow
      app.aobj.UseRegion = value ;
      app.aobj.FO.LM.ModelClasses="MONI";
      usereg=false(size(app.aobj.FO.usebpm));
      usereg(~app.aobj.FO.badbpms & ismember(app.aobj.FO.bpmid,app.aobj.FO.LM.ModelID)) = true ;
      app.ListBox_3.Items = app.aobj.FO.bpmnames(usereg) ;
      app.ListBox_3.Value = cellstr(app.aobj.FO.bpmnames(app.aobj.FO.usebpm)) ;
      app.ListBox.Items = cellstr(app.aobj.LM.ModelID+": "+app.aobj.LM.ModelNames) ;
      app.ListBox.ItemsData = app.aobj.LM.ModelID ;
      app.ListBox.Value = app.aobj.targetID ;
      app.TargetElementPanel.Title = "Target = " + app.aobj.targetID + " (" + app.aobj.targetName + ")" ;
      app.ZEditField.Value = app.aobj.targetZ ;
      app.ListBox_2.Items = app.aobj.CORS.LM.ControlNames(:) + " / " + app.aobj.CorResp(:) ;
      app.ListBox_2.ItemsData = 1:length(app.ListBox_2.Items) ;
      app.ListBox_2.Value = app.ListBox_2.ItemsData(app.aobj.usecor) ;
      app.BumpVal.Value=0;
    end

    % Selection changed function: SelectBumpPlaneButtonGroup
    function SelectBumpPlaneButtonGroupSelectionChanged(app, event)
      selectedButton = app.SelectBumpPlaneButtonGroup.SelectedObject;
      switch selectedButton
        case app.HorizontalxButton
          app.aobj.dim="x";
        case app.VerticalyButton
          app.aobj.dim="y";
      end
      app.INJButtonValueChanged();
    end

    % Value changed function: ListBox_3
    function ListBox_3ValueChanged(app, event)
      value = app.ListBox_3.Value;
      app.aobj.FO.usebpm=true(size(app.aobj.FO.usebpm));
      app.aobj.FO.usebpm(~ismember(app.aobj.FO.bpmnames,value)) = false ;
      if ~isempty(app.aobj.FO.BPMS.modelID)
        app.aobj.FO.usebpm(~ismember(app.aobj.FO.bpmid,app.aobj.FO.BPMS.modelID))=false;
      end
    end

    % Value changed function: ListBox
    function ListBoxValueChanged(app, event)
      app.aobj.targetID = app.ListBox.Value ;
      app.ZEditField.Value = app.aobj.targetZ ;
      app.TargetElementPanel.Title = "Target = " + app.aobj.targetName ;
      app.INJButtonValueChanged();
    end

    % Value changed function: ListBox_2
    function ListBox_2ValueChanged(app, event)
      newval = app.ListBox_2.Value;
      val = app.aobj.usecor ;
      if newval < val(2)
        val = [newval val(2:3)];
      elseif newval > val(2)
        val = [val(1:2) newval] ;
      end
      app.ListBox_2.Value = val ;
      drawnow ;
      app.aobj.usecor = val ;
      app.INJButtonValueChanged();
    end

    % Button pushed function: GOButton
    function GOButtonPushed(app, event)
      app.GOButton.Enable=false;
      drawnow;
      try
        app.aobj.SetBump();
        app.GOButton.Enable=true;
      catch
        app.GOButton.Enable=true;
      end
      app.aobj.CORS.ReadB() ;
      app.aobj.ProcCors();
      drawnow;
    end

    % Value changed function: NAveEditField
    function NAveEditFieldValueChanged(app, event)
      value = app.NAveEditField.Value;
      app.aobj.FO.npulse = value ;
    end

    % Value changed function: BumpVal
    function BumpValValueChanged(app, event)
      value = app.BumpVal.Value;
      app.aobj.BumpVal = value.*1e-3 ;
    end

    % Button pushed function: BumpIncr
    function BumpIncrPushed(app, event)
      app.BumpVal.Value = app.BumpVal.Value + app.BumpChange.Value ;
      app.BumpValValueChanged();
      app.GOButtonPushed() ;
    end

    % Button pushed function: BumpDecr
    function BumpDecrPushed(app, event)
      app.BumpVal.Value = app.BumpVal.Value - app.BumpChange.Value ;
      app.BumpValValueChanged();
      app.GOButtonPushed() ;
    end

    % Button pushed function: UpdateRefOrbitButton
    function UpdateRefOrbitButtonPushed(app, event)
      app.aobj.FO.StoreRef();
      app.aobj.FO.UseRefOrbit="local";
      app.ReferenceEditField.Value=datestr(now);
    end

    % Value changed function: UpdateButton
    function UpdateButtonValueChanged(app, event)
      value = app.UpdateButton.Value;
      if value
        app.aobj.StartTimer;
      else
        app.aobj.StopTimer;
      end
    end

    % Callback function
    function PlotButtonPushed(app, event)
      app.PlotButton.Enable=false;
      try
        app.aobj.ProcLoop();
      catch
        app.PlotButton.Enable=true;
      end
      app.PlotButton.Enable=true;
    end

    % Close request function: FACETIIOrbitBumpsUIFigure
    function FACETIIOrbitBumpsUIFigureCloseRequest(app, event)
      try %#ok<TRYNC> 
        app.StopTimer();
      end
      delete(app)
      
    end

    % Button pushed function: CorrectorControlsButton
    function CorrectorControlsButtonPushed(app, event)
      cors=app.aobj.CorControlNames;
      if ~isempty(app.aobj.corapp) && isprop(app.aobj.corapp,'cor1')
        app.aobj.corapp.init(char(cors(1)),char(cors(2)),char(cors(3)));
      else
        app.aobj.corapp = F2_OrbitBump_correctors(char(cors(1)),char(cors(2)),char(cors(3)));
      end
      app.aobj.corapp.obapp = app ;
      drawnow;
    end
  end

  % Component initialization
  methods (Access = private)

    % Create UIFigure and components
    function createComponents(app)

      % Create FACETIIOrbitBumpsUIFigure and hide until all components are created
      app.FACETIIOrbitBumpsUIFigure = uifigure('Visible', 'off');
      app.FACETIIOrbitBumpsUIFigure.Position = [100 100 1392 714];
      app.FACETIIOrbitBumpsUIFigure.Name = 'FACET-II Orbit Bumps';
      app.FACETIIOrbitBumpsUIFigure.CloseRequestFcn = createCallbackFcn(app, @FACETIIOrbitBumpsUIFigureCloseRequest, true);

      % Create RegionSelectPanel
      app.RegionSelectPanel = uipanel(app.FACETIIOrbitBumpsUIFigure);
      app.RegionSelectPanel.Title = 'Region Select';
      app.RegionSelectPanel.Position = [355 638 835 66];

      % Create GridLayout
      app.GridLayout = uigridlayout(app.RegionSelectPanel);
      app.GridLayout.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
      app.GridLayout.RowHeight = {'2x'};

      % Create INJButton
      app.INJButton = uibutton(app.GridLayout, 'state');
      app.INJButton.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.INJButton.Interruptible = 'off';
      app.INJButton.Text = 'INJ';
      app.INJButton.Layout.Row = 1;
      app.INJButton.Layout.Column = 1;

      % Create L0Button
      app.L0Button = uibutton(app.GridLayout, 'state');
      app.L0Button.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.L0Button.Interruptible = 'off';
      app.L0Button.Text = 'L0';
      app.L0Button.Layout.Row = 1;
      app.L0Button.Layout.Column = 2;

      % Create DL1Button
      app.DL1Button = uibutton(app.GridLayout, 'state');
      app.DL1Button.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.DL1Button.Interruptible = 'off';
      app.DL1Button.Text = 'DL1';
      app.DL1Button.Layout.Row = 1;
      app.DL1Button.Layout.Column = 3;

      % Create L1Button
      app.L1Button = uibutton(app.GridLayout, 'state');
      app.L1Button.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.L1Button.Interruptible = 'off';
      app.L1Button.Text = 'L1';
      app.L1Button.Layout.Row = 1;
      app.L1Button.Layout.Column = 4;

      % Create BC11Button
      app.BC11Button = uibutton(app.GridLayout, 'state');
      app.BC11Button.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.BC11Button.Interruptible = 'off';
      app.BC11Button.Text = 'BC11';
      app.BC11Button.Layout.Row = 1;
      app.BC11Button.Layout.Column = 5;

      % Create L2Button
      app.L2Button = uibutton(app.GridLayout, 'state');
      app.L2Button.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.L2Button.Interruptible = 'off';
      app.L2Button.Text = 'L2';
      app.L2Button.Layout.Row = 1;
      app.L2Button.Layout.Column = 6;

      % Create BC14Button
      app.BC14Button = uibutton(app.GridLayout, 'state');
      app.BC14Button.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.BC14Button.Interruptible = 'off';
      app.BC14Button.Text = 'BC14';
      app.BC14Button.Layout.Row = 1;
      app.BC14Button.Layout.Column = 7;

      % Create L3Button
      app.L3Button = uibutton(app.GridLayout, 'state');
      app.L3Button.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.L3Button.Interruptible = 'off';
      app.L3Button.Text = 'L3';
      app.L3Button.Layout.Row = 1;
      app.L3Button.Layout.Column = 8;
      app.L3Button.Value = true;

      % Create BC20Button
      app.BC20Button = uibutton(app.GridLayout, 'state');
      app.BC20Button.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.BC20Button.Interruptible = 'off';
      app.BC20Button.Text = 'BC20';
      app.BC20Button.Layout.Row = 1;
      app.BC20Button.Layout.Column = 9;

      % Create FFSButton
      app.FFSButton = uibutton(app.GridLayout, 'state');
      app.FFSButton.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.FFSButton.Interruptible = 'off';
      app.FFSButton.Text = 'FFS';
      app.FFSButton.Layout.Row = 1;
      app.FFSButton.Layout.Column = 10;

      % Create SPECTButton
      app.SPECTButton = uibutton(app.GridLayout, 'state');
      app.SPECTButton.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.SPECTButton.Interruptible = 'off';
      app.SPECTButton.Text = 'SPECT';
      app.SPECTButton.Layout.Row = 1;
      app.SPECTButton.Layout.Column = 11;

      % Create TargetElementPanel
      app.TargetElementPanel = uipanel(app.FACETIIOrbitBumpsUIFigure);
      app.TargetElementPanel.Title = 'Target Element';
      app.TargetElementPanel.Position = [182 12 163 692];

      % Create ListBox
      app.ListBox = uilistbox(app.TargetElementPanel);
      app.ListBox.ValueChangedFcn = createCallbackFcn(app, @ListBoxValueChanged, true);
      app.ListBox.Interruptible = 'off';
      app.ListBox.Position = [8 129 147 535];

      % Create SelectBumpPlaneButtonGroup
      app.SelectBumpPlaneButtonGroup = uibuttongroup(app.TargetElementPanel);
      app.SelectBumpPlaneButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @SelectBumpPlaneButtonGroupSelectionChanged, true);
      app.SelectBumpPlaneButtonGroup.Title = 'Select Bump Plane';
      app.SelectBumpPlaneButtonGroup.Position = [8 7 147 82];

      % Create HorizontalxButton
      app.HorizontalxButton = uitogglebutton(app.SelectBumpPlaneButtonGroup);
      app.HorizontalxButton.Text = 'Horizontal (x)';
      app.HorizontalxButton.Position = [11 33 123 23];
      app.HorizontalxButton.Value = true;

      % Create VerticalyButton
      app.VerticalyButton = uitogglebutton(app.SelectBumpPlaneButtonGroup);
      app.VerticalyButton.Text = 'Vertical (y)';
      app.VerticalyButton.Position = [11 7 123 23];

      % Create ZEditFieldLabel
      app.ZEditFieldLabel = uilabel(app.TargetElementPanel);
      app.ZEditFieldLabel.HorizontalAlignment = 'right';
      app.ZEditFieldLabel.Position = [10 97 16 22];
      app.ZEditFieldLabel.Text = 'Z:';

      % Create ZEditField
      app.ZEditField = uieditfield(app.TargetElementPanel, 'numeric');
      app.ZEditField.Position = [30 97 122 22];

      % Create CorrectorsResponsePanel
      app.CorrectorsResponsePanel = uipanel(app.FACETIIOrbitBumpsUIFigure);
      app.CorrectorsResponsePanel.Title = 'Correctors / Response';
      app.CorrectorsResponsePanel.Position = [1204 10 174 694];

      % Create ListBox_2
      app.ListBox_2 = uilistbox(app.CorrectorsResponsePanel);
      app.ListBox_2.ItemsData = {'[1,2,3,4]'};
      app.ListBox_2.Multiselect = 'on';
      app.ListBox_2.ValueChangedFcn = createCallbackFcn(app, @ListBox_2ValueChanged, true);
      app.ListBox_2.Interruptible = 'off';
      app.ListBox_2.Position = [11 158 155 505];
      app.ListBox_2.Value = {'[1,2,3,4]'};

      % Create FudgeFactorsusePanel
      app.FudgeFactorsusePanel = uipanel(app.CorrectorsResponsePanel);
      app.FudgeFactorsusePanel.Title = 'Fudge Factors / use';
      app.FudgeFactorsusePanel.Position = [15 9 147 141];

      % Create EditField
      app.EditField = uieditfield(app.FudgeFactorsusePanel, 'numeric');
      app.EditField.Enable = 'off';
      app.EditField.Position = [13 91 92 21];
      app.EditField.Value = 1;

      % Create EditField_2
      app.EditField_2 = uieditfield(app.FudgeFactorsusePanel, 'numeric');
      app.EditField_2.Enable = 'off';
      app.EditField_2.Position = [13 67 92 21];
      app.EditField_2.Value = 1;

      % Create EditField_3
      app.EditField_3 = uieditfield(app.FudgeFactorsusePanel, 'numeric');
      app.EditField_3.Enable = 'off';
      app.EditField_3.Position = [13 43 92 21];
      app.EditField_3.Value = 1;

      % Create FITButton
      app.FITButton = uibutton(app.FudgeFactorsusePanel, 'push');
      app.FITButton.Enable = 'off';
      app.FITButton.Position = [23 11 100 23];
      app.FITButton.Text = 'FIT';

      % Create CheckBox
      app.CheckBox = uicheckbox(app.FudgeFactorsusePanel);
      app.CheckBox.Enable = 'off';
      app.CheckBox.Text = '';
      app.CheckBox.Position = [113 90 25 22];
      app.CheckBox.Value = true;

      % Create CheckBox_2
      app.CheckBox_2 = uicheckbox(app.FudgeFactorsusePanel);
      app.CheckBox_2.Enable = 'off';
      app.CheckBox_2.Text = '';
      app.CheckBox_2.Position = [113 66 25 22];
      app.CheckBox_2.Value = true;

      % Create CheckBox_3
      app.CheckBox_3 = uicheckbox(app.FudgeFactorsusePanel);
      app.CheckBox_3.Enable = 'off';
      app.CheckBox_3.Text = '';
      app.CheckBox_3.Position = [113 42 25 22];
      app.CheckBox_3.Value = true;

      % Create OrbitPlotPanel
      app.OrbitPlotPanel = uipanel(app.FACETIIOrbitBumpsUIFigure);
      app.OrbitPlotPanel.Title = 'Orbit Plot';
      app.OrbitPlotPanel.Position = [356 10 837 386];

      % Create PlotAxes
      app.PlotAxes = uiaxes(app.OrbitPlotPanel);
      title(app.PlotAxes, '')
      xlabel(app.PlotAxes, 'X')
      ylabel(app.PlotAxes, 'Y')
      app.PlotAxes.Position = [11 5 815 354];

      % Create BumpControlPanel
      app.BumpControlPanel = uipanel(app.FACETIIOrbitBumpsUIFigure);
      app.BumpControlPanel.Title = 'Bump Control';
      app.BumpControlPanel.Position = [356 475 382 155];

      % Create SetmmEditFieldLabel
      app.SetmmEditFieldLabel = uilabel(app.BumpControlPanel);
      app.SetmmEditFieldLabel.HorizontalAlignment = 'right';
      app.SetmmEditFieldLabel.Position = [8 99 57 22];
      app.SetmmEditFieldLabel.Text = 'Set (mm):';

      % Create BumpVal
      app.BumpVal = uieditfield(app.BumpControlPanel, 'numeric');
      app.BumpVal.ValueChangedFcn = createCallbackFcn(app, @BumpValValueChanged, true);
      app.BumpVal.Position = [74 99 72 25];

      % Create BumpDecr
      app.BumpDecr = uibutton(app.BumpControlPanel, 'push');
      app.BumpDecr.ButtonPushedFcn = createCallbackFcn(app, @BumpDecrPushed, true);
      app.BumpDecr.Interruptible = 'off';
      app.BumpDecr.Icon = 'larrow.svg';
      app.BumpDecr.Position = [156 96 42 33];
      app.BumpDecr.Text = '';

      % Create BumpChange
      app.BumpChange = uieditfield(app.BumpControlPanel, 'numeric');
      app.BumpChange.HorizontalAlignment = 'center';
      app.BumpChange.Position = [201 98 72 31];
      app.BumpChange.Value = 0.1;

      % Create BumpIncr
      app.BumpIncr = uibutton(app.BumpControlPanel, 'push');
      app.BumpIncr.ButtonPushedFcn = createCallbackFcn(app, @BumpIncrPushed, true);
      app.BumpIncr.Interruptible = 'off';
      app.BumpIncr.Icon = 'rarrow.svg';
      app.BumpIncr.Position = [276 96 42 33];
      app.BumpIncr.Text = '';

      % Create CORReadbackmmLabel
      app.CORReadbackmmLabel = uilabel(app.BumpControlPanel);
      app.CORReadbackmmLabel.HorizontalAlignment = 'right';
      app.CORReadbackmmLabel.Position = [12 67 125 22];
      app.CORReadbackmmLabel.Text = 'COR Readback (mm):';

      % Create BumpRdb_cor
      app.BumpRdb_cor = uieditfield(app.BumpControlPanel, 'numeric');
      app.BumpRdb_cor.ValueDisplayFormat = '%.3f';
      app.BumpRdb_cor.Editable = 'off';
      app.BumpRdb_cor.Position = [146 67 138 25];

      % Create RangemmEditFieldLabel
      app.RangemmEditFieldLabel = uilabel(app.BumpControlPanel);
      app.RangemmEditFieldLabel.HorizontalAlignment = 'right';
      app.RangemmEditFieldLabel.Position = [13 4 76 22];
      app.RangemmEditFieldLabel.Text = 'Range (mm):';

      % Create BumpRange
      app.BumpRange = uieditfield(app.BumpControlPanel, 'text');
      app.BumpRange.HorizontalAlignment = 'center';
      app.BumpRange.FontWeight = 'bold';
      app.BumpRange.Enable = 'off';
      app.BumpRange.Position = [113 4 173 25];

      % Create BPMReadbackmmLabel
      app.BPMReadbackmmLabel = uilabel(app.BumpControlPanel);
      app.BPMReadbackmmLabel.HorizontalAlignment = 'right';
      app.BPMReadbackmmLabel.Position = [13 35 124 22];
      app.BPMReadbackmmLabel.Text = 'BPM Readback (mm):';

      % Create BumpRdb_bpm
      app.BumpRdb_bpm = uieditfield(app.BumpControlPanel, 'numeric');
      app.BumpRdb_bpm.ValueDisplayFormat = '%.3f';
      app.BumpRdb_bpm.Editable = 'off';
      app.BumpRdb_bpm.Position = [146 35 139 25];

      % Create GOButton
      app.GOButton = uibutton(app.BumpControlPanel, 'push');
      app.GOButton.ButtonPushedFcn = createCallbackFcn(app, @GOButtonPushed, true);
      app.GOButton.Interruptible = 'off';
      app.GOButton.Position = [323 97 53 32];
      app.GOButton.Text = 'GO';

      % Create OrbitPanel
      app.OrbitPanel = uipanel(app.FACETIIOrbitBumpsUIFigure);
      app.OrbitPanel.Title = 'Orbit';
      app.OrbitPanel.Position = [356 401 837 68];

      % Create ReferenceEditFieldLabel
      app.ReferenceEditFieldLabel = uilabel(app.OrbitPanel);
      app.ReferenceEditFieldLabel.HorizontalAlignment = 'right';
      app.ReferenceEditFieldLabel.Position = [25 14 65 22];
      app.ReferenceEditFieldLabel.Text = 'Reference:';

      % Create ReferenceEditField
      app.ReferenceEditField = uieditfield(app.OrbitPanel, 'text');
      app.ReferenceEditField.Position = [105 14 308 22];
      app.ReferenceEditField.Value = 'none';

      % Create UpdateRefOrbitButton
      app.UpdateRefOrbitButton = uibutton(app.OrbitPanel, 'push');
      app.UpdateRefOrbitButton.ButtonPushedFcn = createCallbackFcn(app, @UpdateRefOrbitButtonPushed, true);
      app.UpdateRefOrbitButton.Interruptible = 'off';
      app.UpdateRefOrbitButton.Position = [436 14 126 23];
      app.UpdateRefOrbitButton.Text = 'Update Ref Orbit';

      % Create NAveEditFieldLabel
      app.NAveEditFieldLabel = uilabel(app.OrbitPanel);
      app.NAveEditFieldLabel.HorizontalAlignment = 'right';
      app.NAveEditFieldLabel.Position = [580 14 41 22];
      app.NAveEditFieldLabel.Text = 'N Ave:';

      % Create NAveEditField
      app.NAveEditField = uieditfield(app.OrbitPanel, 'numeric');
      app.NAveEditField.ValueDisplayFormat = '%d';
      app.NAveEditField.ValueChangedFcn = createCallbackFcn(app, @NAveEditFieldValueChanged, true);
      app.NAveEditField.Position = [636 14 59 22];
      app.NAveEditField.Value = 5;

      % Create UpdateButton
      app.UpdateButton = uibutton(app.OrbitPanel, 'state');
      app.UpdateButton.ValueChangedFcn = createCallbackFcn(app, @UpdateButtonValueChanged, true);
      app.UpdateButton.Text = 'Update';
      app.UpdateButton.Position = [718 13 100 23];

      % Create CorrectorsPanel
      app.CorrectorsPanel = uipanel(app.FACETIIOrbitBumpsUIFigure);
      app.CorrectorsPanel.Title = 'Correctors';
      app.CorrectorsPanel.Position = [750 475 442 155];

      % Create GridLayout2
      app.GridLayout2 = uigridlayout(app.CorrectorsPanel);
      app.GridLayout2.ColumnWidth = {'1x', '1x', '1x', '1x'};
      app.GridLayout2.RowHeight = {'1x', '1x', '1x', '1x'};

      % Create BDESkGmLabel
      app.BDESkGmLabel = uilabel(app.GridLayout2);
      app.BDESkGmLabel.HorizontalAlignment = 'center';
      app.BDESkGmLabel.FontWeight = 'bold';
      app.BDESkGmLabel.Layout.Row = 1;
      app.BDESkGmLabel.Layout.Column = 1;
      app.BDESkGmLabel.Text = 'BDES (kGm)';

      % Create BACTkGmLabel
      app.BACTkGmLabel = uilabel(app.GridLayout2);
      app.BACTkGmLabel.HorizontalAlignment = 'center';
      app.BACTkGmLabel.FontWeight = 'bold';
      app.BACTkGmLabel.Layout.Row = 1;
      app.BACTkGmLabel.Layout.Column = 2;
      app.BACTkGmLabel.Text = 'BACT (kGm)';

      % Create dKickmradLabel
      app.dKickmradLabel = uilabel(app.GridLayout2);
      app.dKickmradLabel.HorizontalAlignment = 'center';
      app.dKickmradLabel.FontWeight = 'bold';
      app.dKickmradLabel.Layout.Row = 1;
      app.dKickmradLabel.Layout.Column = 3;
      app.dKickmradLabel.Text = 'dKick (mrad)';

      % Create CoefLabel
      app.CoefLabel = uilabel(app.GridLayout2);
      app.CoefLabel.HorizontalAlignment = 'center';
      app.CoefLabel.FontWeight = 'bold';
      app.CoefLabel.Layout.Row = 1;
      app.CoefLabel.Layout.Column = 4;
      app.CoefLabel.Text = 'Coef.';

      % Create EditField_4
      app.EditField_4 = uieditfield(app.GridLayout2, 'numeric');
      app.EditField_4.ValueDisplayFormat = '%.3f';
      app.EditField_4.Editable = 'off';
      app.EditField_4.HorizontalAlignment = 'center';
      app.EditField_4.Layout.Row = 2;
      app.EditField_4.Layout.Column = 1;

      % Create EditField_6
      app.EditField_6 = uieditfield(app.GridLayout2, 'numeric');
      app.EditField_6.ValueDisplayFormat = '%.3f';
      app.EditField_6.Editable = 'off';
      app.EditField_6.HorizontalAlignment = 'center';
      app.EditField_6.Layout.Row = 2;
      app.EditField_6.Layout.Column = 3;

      % Create EditField_7
      app.EditField_7 = uieditfield(app.GridLayout2, 'numeric');
      app.EditField_7.ValueDisplayFormat = '%.3f';
      app.EditField_7.Editable = 'off';
      app.EditField_7.HorizontalAlignment = 'center';
      app.EditField_7.Layout.Row = 2;
      app.EditField_7.Layout.Column = 4;

      % Create EditField_8
      app.EditField_8 = uieditfield(app.GridLayout2, 'numeric');
      app.EditField_8.ValueDisplayFormat = '%.3f';
      app.EditField_8.Editable = 'off';
      app.EditField_8.HorizontalAlignment = 'center';
      app.EditField_8.Layout.Row = 3;
      app.EditField_8.Layout.Column = 1;

      % Create EditField_10
      app.EditField_10 = uieditfield(app.GridLayout2, 'numeric');
      app.EditField_10.ValueDisplayFormat = '%.3f';
      app.EditField_10.Editable = 'off';
      app.EditField_10.HorizontalAlignment = 'center';
      app.EditField_10.Layout.Row = 3;
      app.EditField_10.Layout.Column = 3;

      % Create EditField_11
      app.EditField_11 = uieditfield(app.GridLayout2, 'numeric');
      app.EditField_11.ValueDisplayFormat = '%.3f';
      app.EditField_11.Editable = 'off';
      app.EditField_11.HorizontalAlignment = 'center';
      app.EditField_11.Layout.Row = 3;
      app.EditField_11.Layout.Column = 4;

      % Create EditField_12
      app.EditField_12 = uieditfield(app.GridLayout2, 'numeric');
      app.EditField_12.ValueDisplayFormat = '%.3f';
      app.EditField_12.Editable = 'off';
      app.EditField_12.HorizontalAlignment = 'center';
      app.EditField_12.Layout.Row = 4;
      app.EditField_12.Layout.Column = 1;

      % Create EditField_14
      app.EditField_14 = uieditfield(app.GridLayout2, 'numeric');
      app.EditField_14.ValueDisplayFormat = '%.3f';
      app.EditField_14.Editable = 'off';
      app.EditField_14.HorizontalAlignment = 'center';
      app.EditField_14.Layout.Row = 4;
      app.EditField_14.Layout.Column = 3;

      % Create EditField_15
      app.EditField_15 = uieditfield(app.GridLayout2, 'numeric');
      app.EditField_15.ValueDisplayFormat = '%.3f';
      app.EditField_15.Editable = 'off';
      app.EditField_15.HorizontalAlignment = 'center';
      app.EditField_15.Layout.Row = 4;
      app.EditField_15.Layout.Column = 4;

      % Create EditField_16
      app.EditField_16 = uieditfield(app.GridLayout2, 'numeric');
      app.EditField_16.ValueDisplayFormat = '%.3f';
      app.EditField_16.Editable = 'off';
      app.EditField_16.HorizontalAlignment = 'center';
      app.EditField_16.Layout.Row = 2;
      app.EditField_16.Layout.Column = 2;

      % Create EditField_17
      app.EditField_17 = uieditfield(app.GridLayout2, 'numeric');
      app.EditField_17.ValueDisplayFormat = '%.3f';
      app.EditField_17.Editable = 'off';
      app.EditField_17.HorizontalAlignment = 'center';
      app.EditField_17.Layout.Row = 3;
      app.EditField_17.Layout.Column = 2;

      % Create EditField_18
      app.EditField_18 = uieditfield(app.GridLayout2, 'numeric');
      app.EditField_18.ValueDisplayFormat = '%.3f';
      app.EditField_18.Editable = 'off';
      app.EditField_18.HorizontalAlignment = 'center';
      app.EditField_18.Layout.Row = 4;
      app.EditField_18.Layout.Column = 2;

      % Create BPMsPanel
      app.BPMsPanel = uipanel(app.FACETIIOrbitBumpsUIFigure);
      app.BPMsPanel.Title = 'BPMs';
      app.BPMsPanel.Position = [12 11 158 693];

      % Create ListBox_3
      app.ListBox_3 = uilistbox(app.BPMsPanel);
      app.ListBox_3.Multiselect = 'on';
      app.ListBox_3.ValueChangedFcn = createCallbackFcn(app, @ListBox_3ValueChanged, true);
      app.ListBox_3.Interruptible = 'off';
      app.ListBox_3.Position = [6 6 147 663];
      app.ListBox_3.Value = {'Item 1'};

      % Create CorrectorControlsButton
      app.CorrectorControlsButton = uibutton(app.FACETIIOrbitBumpsUIFigure, 'push');
      app.CorrectorControlsButton.ButtonPushedFcn = createCallbackFcn(app, @CorrectorControlsButtonPushed, true);
      app.CorrectorControlsButton.VerticalAlignment = 'top';
      app.CorrectorControlsButton.FontSize = 8;
      app.CorrectorControlsButton.FontWeight = 'bold';
      app.CorrectorControlsButton.FontColor = [0.851 0.3255 0.098];
      app.CorrectorControlsButton.Position = [1085 612 100 15];
      app.CorrectorControlsButton.Text = 'Corrector Controls';

      % Show the figure after all components are created
      app.FACETIIOrbitBumpsUIFigure.Visible = 'on';
    end
  end

  % App creation and deletion
  methods (Access = public)

    % Construct app
    function app = F2_OrbitBump_exported(varargin)

      % Create UIFigure and components
      createComponents(app)

      % Register the app with App Designer
      registerApp(app, app.FACETIIOrbitBumpsUIFigure)

      % Execute the startup function
      runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

      if nargout == 0
        clear app
      end
    end

    % Code that executes before app deletion
    function delete(app)

      % Delete UIFigure when app is deleted
      delete(app.FACETIIOrbitBumpsUIFigure)
    end
  end
end