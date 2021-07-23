classdef F2_Orbit_exported < matlab.apps.AppBase

  % Properties that correspond to app components
  properties (Access = public)
    FACETIIOrbitToolUIFigure     matlab.ui.Figure
    BPMsPanel                    matlab.ui.container.Panel
    ListBox                      matlab.ui.control.ListBox
    CorrectorsPanel              matlab.ui.container.Panel
    ListBox_2                    matlab.ui.control.ListBox
    ListBox_3                    matlab.ui.control.ListBox
    TabGroup                     matlab.ui.container.TabGroup
    OrbitTab                     matlab.ui.container.Tab
    UIAxes                       matlab.ui.control.UIAxes
    CalcCorrectionButton         matlab.ui.control.Button
    DoCorrectionButton           matlab.ui.control.Button
    USEXButton                   matlab.ui.control.StateButton
    USEYButton                   matlab.ui.control.StateButton
    UIAxes_2                     matlab.ui.control.UIAxes
    CorrectionSolverButtonGroup  matlab.ui.container.ButtonGroup
    lscovButton                  matlab.ui.control.RadioButton
    pinvButton                   matlab.ui.control.RadioButton
    lsqminnormButton             matlab.ui.control.RadioButton
    TolEditFieldLabel            matlab.ui.control.Label
    TolEditField                 matlab.ui.control.NumericEditField
    TolPlotButton                matlab.ui.control.Button
    CorrectorsTab                matlab.ui.container.Tab
    GridLayout2                  matlab.ui.container.GridLayout
    UIAxes2                      matlab.ui.control.UIAxes
    UIAxes3                      matlab.ui.control.UIAxes
    DispersionTab                matlab.ui.container.Tab
    SVDPlotsTab                  matlab.ui.container.Tab
    RegionSelectPanel            matlab.ui.container.Panel
    GridLayout                   matlab.ui.container.GridLayout
    INJButton                    matlab.ui.control.StateButton
    L0Button                     matlab.ui.control.StateButton
    DL1Button                    matlab.ui.control.StateButton
    L1Button                     matlab.ui.control.StateButton
    BC11Button                   matlab.ui.control.StateButton
    L2Button                     matlab.ui.control.StateButton
    BC14Button                   matlab.ui.control.StateButton
    L3Button                     matlab.ui.control.StateButton
    BC20Button                   matlab.ui.control.StateButton
    FFSButton                    matlab.ui.control.StateButton
    SPECTButton                  matlab.ui.control.StateButton
    AcquireOrbitButton           matlab.ui.control.Button
    NPulseEditFieldLabel         matlab.ui.control.Label
    NPulseEditField              matlab.ui.control.NumericEditField
    PlotRangeDropDownLabel       matlab.ui.control.Label
    PlotRangeDropDown            matlab.ui.control.DropDown
    NReadEditFieldLabel          matlab.ui.control.Label
    NReadEditField               matlab.ui.control.NumericEditField
    UpdateLiveModelButton        matlab.ui.control.Button
  end

  
  properties (Access = public)
    aobj % F2_OrbitApp object
  end
  
  methods (Access = public)
    
    function updateplots(app)
      app.TabGroupSelectionChanged;
    end
  end
  

  % Callbacks that handle component events
  methods (Access = private)

    % Code that executes after component creation
    function startupFcn(app)
      app.aobj = F2_OrbitApp(app) ;
      app.INJButtonValueChanged(); % Populates BPM and corrector list boxes
    end

    % Value changed function: BC11Button, BC14Button, 
    % BC20Button, DL1Button, FFSButton, INJButton, L0Button, 
    % L1Button, L2Button, L3Button, SPECTButton
    function INJButtonValueChanged(app, event)
      value = [app.INJButton.Value app.L0Button.Value app.DL1Button.Value app.L1Button.Value ...
        app.BC11Button.Value app.L2Button.Value app.BC14Button.Value app.L3Button.Value ...
        app.BC20Button.Value app.FFSButton.Value app.SPECTButton.Value] ;
%       ele1=find(value,1);
%       if isempty(ele1)
%         value(1)=true;
%         app.INJButton.Value=true;
%       end
%       ele2=find(~value,1)-1;
%       if isempty(ele2)
%         ele2=length(value);
%       elseif ele2<ele1
%         ele2=length(value);
%       end
%       value=false(1,length(value)); value(ele1:ele2)=true;
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
      drawnow
      app.aobj.UseRegion = value ;
      app.ListBox.Items = app.aobj.bpmnames(app.aobj.usebpm) ;
      app.ListBox.ItemsData = app.aobj.bpmid(app.aobj.usebpm) ;
      app.ListBox.Value = app.ListBox.ItemsData ;
      app.ListBox_2.Items = app.aobj.xcornames(app.aobj.usexcor) ;
      app.ListBox_2.ItemsData = app.aobj.xcorid(app.aobj.usexcor) ;
      app.ListBox_2.Value = app.ListBox_2.ItemsData ;
      app.ListBox_3.Items = app.aobj.ycornames(app.aobj.useycor) ;
      app.ListBox_3.ItemsData = app.aobj.ycorid(app.aobj.useycor) ;
      app.ListBox_3.Value = app.ListBox_3.ItemsData ;
      app.TabGroupSelectionChanged;
    end

    % Selection change function: TabGroup
    function TabGroupSelectionChanged(app, event)
      switch app.TabGroup.SelectedTab
        case app.OrbitTab
          if ~isempty(app.aobj.BPMS.xdat)
            app.aobj.plotbpm([app.UIAxes app.UIAxes_2]);
          end
        case app.CorrectorsTab
          app.aobj.plotcor([app.UIAxes2 app.UIAxes3]);
        case app.DispersionTab
        case app.SVDPlotsTab
      end
      drawnow
    end

    % Button pushed function: AcquireOrbitButton
    function AcquireOrbitButtonPushed(app, event)
      app.AcquireOrbitButton.Enable=false;
      app.NReadEditField.Value=0;
      drawnow
      try
        app.aobj.acquire(app.NPulseEditField.Value);
        app.ListBox.Value = app.aobj.bpmid(app.aobj.usebpm) ;
        app.NReadEditField.Value = double(app.aobj.BPMS.nread) ;
        app.TabGroupSelectionChanged();
        app.AcquireOrbitButton.Enable=true; drawnow;
      catch ME
        errordlg(sprintf('Failed to acquire new BPM values: %s',ME.message));
        app.AcquireOrbitButton.Enable=true; drawnow;
      end
    end

    % Value changed function: PlotRangeDropDown
    function PlotRangeDropDownValueChanged(app, event)
      value = app.PlotRangeDropDown.Value;
      app.aobj.BPMS.plotscale=str2double(value);
      app.TabGroupSelectionChanged;
    end

    % Value changed function: ListBox
    function ListBoxValueChanged(app, event)
      value = app.ListBox.Value;
      app.aobj.usebpm=true(size(app.aobj.usebpm));
      app.aobj.usebpm(~ismember(app.aobj.bpmid,value)) = false ;
      if ~isempty(app.aobj.BPMS.readid)
        app.aobj.usebpm(~ismember(app.aobj.bpmid,app.aobj.BPMS.readid))=false;
      end
      app.TabGroupSelectionChanged;
    end

    % Value changed function: ListBox_2
    function ListBox_2ValueChanged(app, event)
      value = app.ListBox_2.Value;
      app.aobj.usexcor(~ismember(app.aobj.xcorid,value)) = false ;
    end

    % Value changed function: ListBox_3
    function ListBox_3ValueChanged(app, event)
      value = app.ListBox_3.Value;
      app.aobj.useycor(~ismember(app.aobj.ycorid,value)) = false ;
    end

    % Value changed function: TolEditField
    function TolEditFieldValueChanged(app, event)
      value = app.TolEditField.Value;
      if value>0
        app.aobj.solvtol=value;
      end
    end

    % Button pushed function: TolPlotButton
    function TolPlotButtonPushed(app, event)
      app.aobj.plotqrtol;
    end

    % Button pushed function: CalcCorrectionButton
    function CalcCorrectionButtonPushed(app, event)
      if app.lscovButton.Value
        app.aobj.corsolv="lscov";
      elseif app.pinvButton.Value
        app.aobj.corsolv="pinv";
      elseif app.lsqminnormButton.Value
        app.aobj.corsolv="lsqminnorm";
      end
      try
        app.aobj.corcalc;
      catch ME
        errordlg(sprintf('Calc error:\n%s',ME.message),'Orbit Calc Error');
      end
    end

    % Button pushed function: UpdateLiveModelButton
    function UpdateLiveModelButtonPushed(app, event)
      app.UpdateLiveModelButton.Enable=false;
      drawnow
      try
        app.aobj.LiveModel.UpdateModel;
      catch
        errordlg('Live Model update failed','Live Model Error');
        app.UpdateLiveModelButton.Enable=true;
        drawnow
      end
      app.UpdateLiveModelButton.Enable=true;
      drawnow
    end

    % Value changed function: USEXButton
    function USEXButtonValueChanged(app, event)
      value = app.USEXButton.Value;
      app.aobj.usex=value;
    end

    % Value changed function: USEYButton
    function USEYButtonValueChanged(app, event)
      value = app.USEYButton.Value;
      app.aobj.usey=value;
    end

    % Button pushed function: DoCorrectionButton
    function DoCorrectionButtonPushed(app, event)
      try
        app.aobj.applycalc;
      catch ME
        errordlg(sprintf('Failed to apply orbit correction:\n%s',ME.message),'Correction Error');
      end
    end
  end

  % Component initialization
  methods (Access = private)

    % Create UIFigure and components
    function createComponents(app)

      % Create FACETIIOrbitToolUIFigure and hide until all components are created
      app.FACETIIOrbitToolUIFigure = uifigure('Visible', 'off');
      app.FACETIIOrbitToolUIFigure.Position = [100 100 1223 718];
      app.FACETIIOrbitToolUIFigure.Name = 'FACET-II Orbit Tool';
      app.FACETIIOrbitToolUIFigure.Resize = 'off';

      % Create BPMsPanel
      app.BPMsPanel = uipanel(app.FACETIIOrbitToolUIFigure);
      app.BPMsPanel.Title = 'BPMs';
      app.BPMsPanel.Position = [8 10 163 697];

      % Create ListBox
      app.ListBox = uilistbox(app.BPMsPanel);
      app.ListBox.ItemsData = {'1', '2', '3', '4'};
      app.ListBox.Multiselect = 'on';
      app.ListBox.ValueChangedFcn = createCallbackFcn(app, @ListBoxValueChanged, true);
      app.ListBox.Position = [8 8 147 661];
      app.ListBox.Value = {'1', '2', '3', '4'};

      % Create CorrectorsPanel
      app.CorrectorsPanel = uipanel(app.FACETIIOrbitToolUIFigure);
      app.CorrectorsPanel.Title = 'Correctors';
      app.CorrectorsPanel.Position = [1035 13 174 694];

      % Create ListBox_2
      app.ListBox_2 = uilistbox(app.CorrectorsPanel);
      app.ListBox_2.ItemsData = {'[1,2,3,4]'};
      app.ListBox_2.Multiselect = 'on';
      app.ListBox_2.ValueChangedFcn = createCallbackFcn(app, @ListBox_2ValueChanged, true);
      app.ListBox_2.Position = [11 353 155 313];
      app.ListBox_2.Value = {'[1,2,3,4]'};

      % Create ListBox_3
      app.ListBox_3 = uilistbox(app.CorrectorsPanel);
      app.ListBox_3.Multiselect = 'on';
      app.ListBox_3.ValueChangedFcn = createCallbackFcn(app, @ListBox_3ValueChanged, true);
      app.ListBox_3.Position = [11 5 155 342];
      app.ListBox_3.Value = {'Item 1'};

      % Create TabGroup
      app.TabGroup = uitabgroup(app.FACETIIOrbitToolUIFigure);
      app.TabGroup.SelectionChangedFcn = createCallbackFcn(app, @TabGroupSelectionChanged, true);
      app.TabGroup.Position = [187 44 837 586];

      % Create OrbitTab
      app.OrbitTab = uitab(app.TabGroup);
      app.OrbitTab.AutoResizeChildren = 'off';
      app.OrbitTab.Title = 'Orbit';

      % Create UIAxes
      app.UIAxes = uiaxes(app.OrbitTab);
      title(app.UIAxes, {''; ''})
      xlabel(app.UIAxes, 'X')
      ylabel(app.UIAxes, 'Y')
      app.UIAxes.Position = [8 280 684 259];

      % Create CalcCorrectionButton
      app.CalcCorrectionButton = uibutton(app.OrbitTab, 'push');
      app.CalcCorrectionButton.ButtonPushedFcn = createCallbackFcn(app, @CalcCorrectionButtonPushed, true);
      app.CalcCorrectionButton.Interruptible = 'off';
      app.CalcCorrectionButton.Position = [715 316 100 29];
      app.CalcCorrectionButton.Text = 'Calc Correction';

      % Create DoCorrectionButton
      app.DoCorrectionButton = uibutton(app.OrbitTab, 'push');
      app.DoCorrectionButton.ButtonPushedFcn = createCallbackFcn(app, @DoCorrectionButtonPushed, true);
      app.DoCorrectionButton.Interruptible = 'off';
      app.DoCorrectionButton.Enable = 'off';
      app.DoCorrectionButton.Position = [715 280 100 29];
      app.DoCorrectionButton.Text = 'Do Correction';

      % Create USEXButton
      app.USEXButton = uibutton(app.OrbitTab, 'state');
      app.USEXButton.ValueChangedFcn = createCallbackFcn(app, @USEXButtonValueChanged, true);
      app.USEXButton.Text = 'USE X';
      app.USEXButton.Position = [716 245 100 23];
      app.USEXButton.Value = true;

      % Create USEYButton
      app.USEYButton = uibutton(app.OrbitTab, 'state');
      app.USEYButton.ValueChangedFcn = createCallbackFcn(app, @USEYButtonValueChanged, true);
      app.USEYButton.Text = 'USE Y';
      app.USEYButton.Position = [715 207 100 23];
      app.USEYButton.Value = true;

      % Create UIAxes_2
      app.UIAxes_2 = uiaxes(app.OrbitTab);
      title(app.UIAxes_2, {''; ''})
      xlabel(app.UIAxes_2, 'X')
      ylabel(app.UIAxes_2, 'Y')
      app.UIAxes_2.Position = [11 12 684 249];

      % Create CorrectionSolverButtonGroup
      app.CorrectionSolverButtonGroup = uibuttongroup(app.OrbitTab);
      app.CorrectionSolverButtonGroup.AutoResizeChildren = 'off';
      app.CorrectionSolverButtonGroup.Title = 'Correction Solver';
      app.CorrectionSolverButtonGroup.Position = [705 41 123 147];

      % Create lscovButton
      app.lscovButton = uiradiobutton(app.CorrectionSolverButtonGroup);
      app.lscovButton.Text = 'lscov';
      app.lscovButton.Position = [11 101 58 22];
      app.lscovButton.Value = true;

      % Create pinvButton
      app.pinvButton = uiradiobutton(app.CorrectionSolverButtonGroup);
      app.pinvButton.Text = 'pinv';
      app.pinvButton.Position = [11 79 65 22];

      % Create lsqminnormButton
      app.lsqminnormButton = uiradiobutton(app.CorrectionSolverButtonGroup);
      app.lsqminnormButton.Text = 'lsqminnorm';
      app.lsqminnormButton.Position = [11 58 86 22];

      % Create TolEditFieldLabel
      app.TolEditFieldLabel = uilabel(app.CorrectionSolverButtonGroup);
      app.TolEditFieldLabel.HorizontalAlignment = 'right';
      app.TolEditFieldLabel.Position = [11 34 25 22];
      app.TolEditFieldLabel.Text = 'Tol:';

      % Create TolEditField
      app.TolEditField = uieditfield(app.CorrectionSolverButtonGroup, 'numeric');
      app.TolEditField.ValueChangedFcn = createCallbackFcn(app, @TolEditFieldValueChanged, true);
      app.TolEditField.Position = [50 34 62 22];

      % Create TolPlotButton
      app.TolPlotButton = uibutton(app.CorrectionSolverButtonGroup, 'push');
      app.TolPlotButton.ButtonPushedFcn = createCallbackFcn(app, @TolPlotButtonPushed, true);
      app.TolPlotButton.Position = [11 6 100 23];
      app.TolPlotButton.Text = 'Tol Plot';

      % Create CorrectorsTab
      app.CorrectorsTab = uitab(app.TabGroup);
      app.CorrectorsTab.Title = 'Correctors';

      % Create GridLayout2
      app.GridLayout2 = uigridlayout(app.CorrectorsTab);
      app.GridLayout2.ColumnWidth = {'1x'};

      % Create UIAxes2
      app.UIAxes2 = uiaxes(app.GridLayout2);
      title(app.UIAxes2, '')
      xlabel(app.UIAxes2, 'X')
      ylabel(app.UIAxes2, 'Y')
      app.UIAxes2.Layout.Row = 1;
      app.UIAxes2.Layout.Column = 1;

      % Create UIAxes3
      app.UIAxes3 = uiaxes(app.GridLayout2);
      title(app.UIAxes3, '')
      xlabel(app.UIAxes3, 'X')
      ylabel(app.UIAxes3, 'Y')
      app.UIAxes3.Layout.Row = 2;
      app.UIAxes3.Layout.Column = 1;

      % Create DispersionTab
      app.DispersionTab = uitab(app.TabGroup);
      app.DispersionTab.Title = 'Dispersion';

      % Create SVDPlotsTab
      app.SVDPlotsTab = uitab(app.TabGroup);
      app.SVDPlotsTab.Title = 'SVD Plots';

      % Create RegionSelectPanel
      app.RegionSelectPanel = uipanel(app.FACETIIOrbitToolUIFigure);
      app.RegionSelectPanel.Title = 'Region Select';
      app.RegionSelectPanel.Position = [187 641 835 66];

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
      app.INJButton.Value = true;

      % Create L0Button
      app.L0Button = uibutton(app.GridLayout, 'state');
      app.L0Button.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.L0Button.Interruptible = 'off';
      app.L0Button.Text = 'L0';
      app.L0Button.Layout.Row = 1;
      app.L0Button.Layout.Column = 2;
      app.L0Button.Value = true;

      % Create DL1Button
      app.DL1Button = uibutton(app.GridLayout, 'state');
      app.DL1Button.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.DL1Button.Interruptible = 'off';
      app.DL1Button.Text = 'DL1';
      app.DL1Button.Layout.Row = 1;
      app.DL1Button.Layout.Column = 3;
      app.DL1Button.Value = true;

      % Create L1Button
      app.L1Button = uibutton(app.GridLayout, 'state');
      app.L1Button.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.L1Button.Interruptible = 'off';
      app.L1Button.Text = 'L1';
      app.L1Button.Layout.Row = 1;
      app.L1Button.Layout.Column = 4;
      app.L1Button.Value = true;

      % Create BC11Button
      app.BC11Button = uibutton(app.GridLayout, 'state');
      app.BC11Button.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.BC11Button.Interruptible = 'off';
      app.BC11Button.Text = 'BC11';
      app.BC11Button.Layout.Row = 1;
      app.BC11Button.Layout.Column = 5;
      app.BC11Button.Value = true;

      % Create L2Button
      app.L2Button = uibutton(app.GridLayout, 'state');
      app.L2Button.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.L2Button.Interruptible = 'off';
      app.L2Button.Text = 'L2';
      app.L2Button.Layout.Row = 1;
      app.L2Button.Layout.Column = 6;
      app.L2Button.Value = true;

      % Create BC14Button
      app.BC14Button = uibutton(app.GridLayout, 'state');
      app.BC14Button.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.BC14Button.Interruptible = 'off';
      app.BC14Button.Text = 'BC14';
      app.BC14Button.Layout.Row = 1;
      app.BC14Button.Layout.Column = 7;
      app.BC14Button.Value = true;

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
      app.BC20Button.Value = true;

      % Create FFSButton
      app.FFSButton = uibutton(app.GridLayout, 'state');
      app.FFSButton.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.FFSButton.Interruptible = 'off';
      app.FFSButton.Text = 'FFS';
      app.FFSButton.Layout.Row = 1;
      app.FFSButton.Layout.Column = 10;
      app.FFSButton.Value = true;

      % Create SPECTButton
      app.SPECTButton = uibutton(app.GridLayout, 'state');
      app.SPECTButton.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.SPECTButton.Interruptible = 'off';
      app.SPECTButton.Text = 'SPECT';
      app.SPECTButton.Layout.Row = 1;
      app.SPECTButton.Layout.Column = 11;
      app.SPECTButton.Value = true;

      % Create AcquireOrbitButton
      app.AcquireOrbitButton = uibutton(app.FACETIIOrbitToolUIFigure, 'push');
      app.AcquireOrbitButton.ButtonPushedFcn = createCallbackFcn(app, @AcquireOrbitButtonPushed, true);
      app.AcquireOrbitButton.Interruptible = 'off';
      app.AcquireOrbitButton.Position = [187 13 100 23];
      app.AcquireOrbitButton.Text = 'Acquire Orbit';

      % Create NPulseEditFieldLabel
      app.NPulseEditFieldLabel = uilabel(app.FACETIIOrbitToolUIFigure);
      app.NPulseEditFieldLabel.HorizontalAlignment = 'right';
      app.NPulseEditFieldLabel.Position = [308 14 51 22];
      app.NPulseEditFieldLabel.Text = 'N Pulse:';

      % Create NPulseEditField
      app.NPulseEditField = uieditfield(app.FACETIIOrbitToolUIFigure, 'numeric');
      app.NPulseEditField.ValueDisplayFormat = '%d';
      app.NPulseEditField.Position = [374 14 47 22];
      app.NPulseEditField.Value = 50;

      % Create PlotRangeDropDownLabel
      app.PlotRangeDropDownLabel = uilabel(app.FACETIIOrbitToolUIFigure);
      app.PlotRangeDropDownLabel.HorizontalAlignment = 'right';
      app.PlotRangeDropDownLabel.Position = [691 10 66 22];
      app.PlotRangeDropDownLabel.Text = 'Plot Range';

      % Create PlotRangeDropDown
      app.PlotRangeDropDown = uidropdown(app.FACETIIOrbitToolUIFigure);
      app.PlotRangeDropDown.Items = {'Auto', '5 mm', '4 mm', '3 mm', '2 mm', '1mm'};
      app.PlotRangeDropDown.ItemsData = {'0', '5', '4', '3', '2', '1'};
      app.PlotRangeDropDown.ValueChangedFcn = createCallbackFcn(app, @PlotRangeDropDownValueChanged, true);
      app.PlotRangeDropDown.Position = [772 10 100 22];
      app.PlotRangeDropDown.Value = '0';

      % Create NReadEditFieldLabel
      app.NReadEditFieldLabel = uilabel(app.FACETIIOrbitToolUIFigure);
      app.NReadEditFieldLabel.HorizontalAlignment = 'right';
      app.NReadEditFieldLabel.Position = [436 14 47 22];
      app.NReadEditFieldLabel.Text = 'N Read';

      % Create NReadEditField
      app.NReadEditField = uieditfield(app.FACETIIOrbitToolUIFigure, 'numeric');
      app.NReadEditField.ValueDisplayFormat = '%d';
      app.NReadEditField.Editable = 'off';
      app.NReadEditField.Position = [498 14 47 22];

      % Create UpdateLiveModelButton
      app.UpdateLiveModelButton = uibutton(app.FACETIIOrbitToolUIFigure, 'push');
      app.UpdateLiveModelButton.ButtonPushedFcn = createCallbackFcn(app, @UpdateLiveModelButtonPushed, true);
      app.UpdateLiveModelButton.Interruptible = 'off';
      app.UpdateLiveModelButton.Position = [906 10 118 23];
      app.UpdateLiveModelButton.Text = 'Update Live Model';

      % Show the figure after all components are created
      app.FACETIIOrbitToolUIFigure.Visible = 'on';
    end
  end

  % App creation and deletion
  methods (Access = public)

    % Construct app
    function app = F2_Orbit_exported

      % Create UIFigure and components
      createComponents(app)

      % Register the app with App Designer
      registerApp(app, app.FACETIIOrbitToolUIFigure)

      % Execute the startup function
      runStartupFcn(app, @startupFcn)

      if nargout == 0
        clear app
      end
    end

    % Code that executes before app deletion
    function delete(app)

      % Delete UIFigure when app is deleted
      delete(app.FACETIIOrbitToolUIFigure)
    end
  end
end