classdef F2_Matching_exported < matlab.apps.AppBase

  % Properties that correspond to app components
  properties (Access = public)
    FACETIIOpticsMatchingUIFigure   matlab.ui.Figure
    SettingsMenu                    matlab.ui.container.Menu
    ModelMenu                       matlab.ui.container.Menu
    UsearchivematchingdatadateMenu  matlab.ui.container.Menu
    UsecurrentlivemodelMenu         matlab.ui.container.Menu
    UsedesignmodelMenu              matlab.ui.container.Menu
    PlotMenu                        matlab.ui.container.Menu
    ShowlegendMenu                  matlab.ui.container.Menu
    TabGroup                        matlab.ui.container.TabGroup
    MagnetsTab                      matlab.ui.container.Tab
    UITable                         matlab.ui.control.Table
    QuadScanFitTab                  matlab.ui.container.Tab
    UIAxes                          matlab.ui.control.UIAxes
    UIAxes_2                        matlab.ui.control.UIAxes
    XAnalyticFitemitbmagPanel       matlab.ui.container.Panel
    GridLayout                      matlab.ui.container.GridLayout
    EditField                       matlab.ui.control.NumericEditField
    EditField_2                     matlab.ui.control.NumericEditField
    XModelFitemitbmagPanel          matlab.ui.container.Panel
    GridLayout_2                    matlab.ui.container.GridLayout
    EditField_3                     matlab.ui.control.NumericEditField
    EditField_4                     matlab.ui.control.NumericEditField
    YAnalyticFitemitbmagPanel       matlab.ui.container.Panel
    GridLayout_3                    matlab.ui.container.GridLayout
    EditField_5                     matlab.ui.control.NumericEditField
    EditField_6                     matlab.ui.control.NumericEditField
    YModelFitemitbmagPanel_2        matlab.ui.container.Panel
    GridLayout_4                    matlab.ui.container.GridLayout
    EditField_7                     matlab.ui.control.NumericEditField
    EditField_8                     matlab.ui.control.NumericEditField
    ProfileFitMethodButtonGroup     matlab.ui.container.ButtonGroup
    GaussianButton                  matlab.ui.control.RadioButton
    AsymmetricGaussianButton        matlab.ui.control.RadioButton
    OpticsPlotTab                   matlab.ui.container.Tab
    UIAxes2                         matlab.ui.control.UIAxes
    UIAxes2_2                       matlab.ui.control.UIAxes
    MessagesPanel                   matlab.ui.container.Panel
    TextArea                        matlab.ui.control.TextArea
    OptimizerDropDownLabel          matlab.ui.control.Label
    OptimizerDropDown               matlab.ui.control.DropDown
    MatchingQuadsSpinnerLabel       matlab.ui.control.Label
    MatchingQuadsSpinner            matlab.ui.control.Spinner
    ProfileMeasurementDevicePanel   matlab.ui.container.Panel
    DropDown                        matlab.ui.control.DropDown
    TwissProfileDevicePanel         matlab.ui.container.Panel
    UITable2                        matlab.ui.control.Table
    WritetoPVsButton                matlab.ui.control.Button
    TwissFitMethodButtonGroup       matlab.ui.container.ButtonGroup
    AnalyticButton                  matlab.ui.control.RadioButton
    ModelButton                     matlab.ui.control.RadioButton
    DoMatchingButton                matlab.ui.control.Button
    SetMatchingQuadsButton          matlab.ui.control.Button
    GetQuadScanDataandfitTwissPanel  matlab.ui.container.Panel
    GetDatafromCorrPlotorEmitGUIButton  matlab.ui.control.Button
    UseXDataButton                  matlab.ui.control.StateButton
    UseYDataButton                  matlab.ui.control.StateButton
    UndoButton                      matlab.ui.control.Button
    ModelDatePanel                  matlab.ui.container.Panel
    ModelDateEditField              matlab.ui.control.EditField
  end

  
  properties (Access = public)
    aobj % Accompanying application object F2_MatchingApp
  end
  
  methods (Access = public)
    
    function message(app,txt,iserr)
      app.TextArea.Value = txt ;
      if exist('iserr','var') && iserr
        app.TextArea.FontColor='red';
      else
        app.TextArea.FontColor = 'black' ;
      end
    end
  end
  

  % Callbacks that handle component events
  methods (Access = private)

    % Code that executes after component creation
    function startupFcn(app)
      app.message("Loading and initializing model...");
      app.DropDown.Enable=false;
      app.GetDatafromCorrPlotorEmitGUIButton.Enable=false;
      app.DoMatchingButton.Enable=false;
      drawnow
      try
        app.aobj = F2_MatchingApp(app) ;
      catch ME
        app.message(["Error initializing model...";string(ME.message)],true);
        return
      end
      app.DropDown.Enable=true;
      app.GetDatafromCorrPlotorEmitGUIButton.Enable=true;
      app.DoMatchingButton.Enable=true;
      app.DropDownValueChanged ; % populates table
      app.message(["Loading and initializing model...","Done."]);
    end

    % Value changed function: DropDown
    function DropDownValueChanged(app, event)
      value = app.DropDown.Value;
      if string(value) == "<Select From Below>"
        return
      end
      if value ~= app.aobj.ProfName || (exist('event','var') && event.PreviousValue == "<Select From Below>")
        try
          app.message("Processing new profile monitor data...");
          drawnow
          app.aobj.ProfName = value ;
        catch ME
           app.message(["Error selecting profile monitor", string(ME.message)],true) ;
           return
        end
      end
      app.message(["Processing new profile monitor data...";"Done."]);
      tab = app.aobj.MagnetTable ;
      app.UITable.Data = tab ; app.UITable.ColumnName=tab.Properties.VariableNames;
      doedit = false(1,length(tab.Properties.VariableNames)); doedit(end)=true;
      app.UITable.ColumnEditable=doedit; 
      tab = app.aobj.TwissTable ;
      app.UITable2.Data = tab ; app.UITable2.ColumnName=tab.Properties.VariableNames;
      app.TabGroupSelectionChanged;
    end

    % Selection change function: TabGroup
    function TabGroupSelectionChanged(app, event)
      selectedTab = app.TabGroup.SelectedTab;
      switch selectedTab
        case app.QuadScanFitTab
          app.aobj.PlotQuadScanData;
        case app.OpticsPlotTab
          app.aobj.PlotTwiss;
      end
    end

    % Button pushed function: GetDatafromCorrPlotorEmitGUIButton
    function GetDatafromCorrPlotorEmitGUIButtonPushed(app, event)
      app.message("Requesting data transfer from Correlation Plot Software...");
      drawnow
      try
        didload=app.aobj.LoadQuadScanData;
        if ~didload
          app.message("Data loading aborted",true);
          return
        end
        app.aobj.FitQuadScanData;
      catch ME
        app.message(["No quad scan data transfer performed...";string(ME.message)],true);
        return
      end
      if ~ismember(app.aobj.ProfName,string(app.DropDown.Items)) % Add profile monitor to list if it isn't there
        app.DropDown.Items=[string(app.DropDown.Items) app.aobj.ProfName];
      end
      app.DropDown.Value=app.aobj.ProfName;
      app.DropDownValueChanged ; % populates tables
      app.message(["Requesting data transfer from Correlation Plot Software...";"Done."]);
    end

    % Value changed function: UseXDataButton
    function UseXDataButtonValueChanged(app, event)
      value = app.UseXDataButton.Value;
      if value && app.UseYDataButton.Value
        str="XY" ;
      else
        str="X" ;
        if ~value
          app.UseYDataButton.Value=true;
        end
      end
      app.aobj.DimSelect=str;
    end

    % Value changed function: UseYDataButton
    function UseYDataButtonValueChanged(app, event)
      value = app.UseYDataButton.Value;
      if value && app.UseXDataButton.Value
        str="XY" ;
      else
        str="Y" ;
        if ~value
          app.UseXDataButton.Value=true;
        end
      end
      app.aobj.DimSelect=str;
    end

    % Value changed function: MatchingQuadsSpinner
    function MatchingQuadsSpinnerValueChanged(app, event)
      value = app.MatchingQuadsSpinner.Value;
      app.aobj.NumMatchQuads = value ;
      app.DropDownValueChanged ; % populates tables
    end

    % Value changed function: OptimizerDropDown
    function OptimizerDropDownValueChanged(app, event)
      value = app.OptimizerDropDown.Value;
      app.aobj.Optimizer = value ;
    end

    % Button pushed function: WritetoPVsButton
    function WritetoPVsButtonPushed(app, event)
      app.aobj.WriteEmitData;
      app.message("Emittance data written to PVs");
    end

    % Button pushed function: DoMatchingButton
    function DoMatchingButtonPushed(app, event)
      app.message("Running matching job, see matlab window for details...");
      drawnow
      app.aobj.UseMatchQuad = app.UITable.Data{:,end} ;
      try
        app.aobj.DoMatch;
      catch ME
        app.message(["Matching Error...";string(ME.message)],true);
        return
      end
      app.DropDownValueChanged ; % populates tables
      app.message(["Running matching job, see matlab window for details..."; "Done."]);
    end

    % Button pushed function: SetMatchingQuadsButton
    function SetMatchingQuadsButtonPushed(app, event)
      app.message("Setting matching quads...");
      drawnow
      try
        msg=app.aobj.WriteMatchingQuads;
      catch ME
        app.message(["Error writing matching quads...";string(ME.message)],true);
        return
      end
      app.DropDownValueChanged ; % populates tables
      if contains(string(msg),'!')
        app.message(["Setting matching quads...";"Completed with errors, see command window."],true);
        fprintf(2,'%s',msg);
      else
        app.message(["Setting matching quads...";"Done."]);
      end
    end

    % Button pushed function: UndoButton
    function UndoButtonPushed(app, event)
      app.message("Restoring matching quads...");
      drawnow
      try
        msg=app.aobj.RestoreMatchingQuads;
      catch ME
        app.message(["Error restoring matching quads...";string(ME.message)],true);
        return
      end
      app.DropDownValueChanged ; % populates tables
      if contains(string(msg),'!')
        app.message(["Restoring matching quads...";"Completed with errors, see command window."],true);
        fprintf(2,'%s',msg);
      else
        app.message(["Restoring matching quads...";"Done."]);
      end
    end

    % Menu selected function: UsearchivematchingdatadateMenu
    function UsearchivematchingdatadateMenuSelected(app, event)
      app.message(["Model will update from archive data corresponding to data date";"Updating Model..."]);
      app.UsearchivematchingdatadateMenu.Checked = true ;
      app.UsecurrentlivemodelMenu.Checked = false ;
      app.UsedesignmodelMenu.Checked = false ;
      drawnow
      try
        app.aobj.ModelSource = "Archive" ;
      catch ME
        app.message(["Error updating model...";string(ME.message)],true);
        return
      end
      app.DropDownValueChanged ; % populates tables
      app.message(["Model will update from archive data corresponding to data date";"Updating Model... Done."]);
    end

    % Menu selected function: UsecurrentlivemodelMenu
    function UsecurrentlivemodelMenuSelected(app, event)
      app.message(["Model will update from current live data";"Updating Model..."]);
      app.UsearchivematchingdatadateMenu.Checked = false ;
      app.UsecurrentlivemodelMenu.Checked = true ;
      app.UsedesignmodelMenu.Checked = false ;
      drawnow
      try
        app.aobj.ModelSource = "Live" ;
      catch ME
        app.message(["Error updating model...";string(ME.message)],true);
        return
      end
      app.DropDownValueChanged ; % populates tables
      app.message(["Model will update from current live data";"Updating Model... Done."]);
    end

    % Menu selected function: UsedesignmodelMenu
    function UsedesignmodelMenuSelected(app, event)
      app.message(["Design Model will be used";"Updating Model..."]);
      app.UsearchivematchingdatadateMenu.Checked = false ;
      app.UsecurrentlivemodelMenu.Checked = false ;
      app.UsedesignmodelMenu.Checked = true ;
      drawnow
      try
        app.aobj.ModelSource = "Design" ;
      catch ME
        app.message(["Error updating model...";string(ME.message)],true);
        return
      end
      app.DropDownValueChanged ; % populates tables
      app.message(["Design Model will be used";"Updating Model... Done."]);
    end

    % Menu selected function: ShowlegendMenu
    function ShowlegendMenuSelected(app, event)
      if app.ShowlegendMenu.Checked
        app.ShowlegendMenu.Checked=false;
      else
        app.ShowlegendMenu.Checked=true;
      end
      app.aobj.ShowPlotLegend=app.ShowlegendMenu.Checked;
      app.DropDownValueChanged ; % populates tables
    end

    % Selection changed function: TwissFitMethodButtonGroup
    function TwissFitMethodButtonGroupSelectionChanged(app, event)
      selectedButton = app.TwissFitMethodButtonGroup.SelectedObject;
      switch selectedButton
        case app.AnalyticButton
          app.aobj.TwissFitSource="Analytic";
        case app.ModelButton
          app.aobj.TwissFitSource="Model";
      end
      app.DropDownValueChanged ; % populates tables
    end

    % Selection changed function: ProfileFitMethodButtonGroup
    function ProfileFitMethodButtonGroupSelectionChanged(app, event)
      selectedButton = app.ProfileFitMethodButtonGroup.SelectedObject;
      switch selectedButton
        case app.GaussianButton
          app.aobj.ProfFitMethod="Gaussian";
        case app.AsymmetricGaussianButton
          app.aobj.ProfFitMethod="Asymmetric";
      end
      app.message("Re-fitting data...");
      drawnow
      app.aobj.FitQuadScanData ; %
      app.DropDownValueChanged ; % populates tables
      app.message(["Re-fitting data...";"Done."]);
    end
  end

  % Component initialization
  methods (Access = private)

    % Create UIFigure and components
    function createComponents(app)

      % Create FACETIIOpticsMatchingUIFigure and hide until all components are created
      app.FACETIIOpticsMatchingUIFigure = uifigure('Visible', 'off');
      app.FACETIIOpticsMatchingUIFigure.Position = [100 100 1009 597];
      app.FACETIIOpticsMatchingUIFigure.Name = 'FACET-II Optics Matching';
      app.FACETIIOpticsMatchingUIFigure.Resize = 'off';

      % Create SettingsMenu
      app.SettingsMenu = uimenu(app.FACETIIOpticsMatchingUIFigure);
      app.SettingsMenu.Text = 'Settings';

      % Create ModelMenu
      app.ModelMenu = uimenu(app.SettingsMenu);
      app.ModelMenu.Text = 'Model';

      % Create UsearchivematchingdatadateMenu
      app.UsearchivematchingdatadateMenu = uimenu(app.ModelMenu);
      app.UsearchivematchingdatadateMenu.MenuSelectedFcn = createCallbackFcn(app, @UsearchivematchingdatadateMenuSelected, true);
      app.UsearchivematchingdatadateMenu.Text = 'Use archive matching data date';

      % Create UsecurrentlivemodelMenu
      app.UsecurrentlivemodelMenu = uimenu(app.ModelMenu);
      app.UsecurrentlivemodelMenu.MenuSelectedFcn = createCallbackFcn(app, @UsecurrentlivemodelMenuSelected, true);
      app.UsecurrentlivemodelMenu.Checked = 'on';
      app.UsecurrentlivemodelMenu.Text = 'Use current live model';

      % Create UsedesignmodelMenu
      app.UsedesignmodelMenu = uimenu(app.ModelMenu);
      app.UsedesignmodelMenu.MenuSelectedFcn = createCallbackFcn(app, @UsedesignmodelMenuSelected, true);
      app.UsedesignmodelMenu.Text = 'Use design model';

      % Create PlotMenu
      app.PlotMenu = uimenu(app.FACETIIOpticsMatchingUIFigure);
      app.PlotMenu.Text = 'Plot';

      % Create ShowlegendMenu
      app.ShowlegendMenu = uimenu(app.PlotMenu);
      app.ShowlegendMenu.MenuSelectedFcn = createCallbackFcn(app, @ShowlegendMenuSelected, true);
      app.ShowlegendMenu.Checked = 'on';
      app.ShowlegendMenu.Text = 'Show legend';

      % Create TabGroup
      app.TabGroup = uitabgroup(app.FACETIIOpticsMatchingUIFigure);
      app.TabGroup.SelectionChangedFcn = createCallbackFcn(app, @TabGroupSelectionChanged, true);
      app.TabGroup.Position = [255 122 752 472];

      % Create MagnetsTab
      app.MagnetsTab = uitab(app.TabGroup);
      app.MagnetsTab.Title = 'Magnets';

      % Create UITable
      app.UITable = uitable(app.MagnetsTab);
      app.UITable.ColumnName = {'Column 1'; 'Column 2'; 'Column 3'; 'Column 4'};
      app.UITable.RowName = {};
      app.UITable.Interruptible = 'off';
      app.UITable.Position = [4 8 744 439];

      % Create QuadScanFitTab
      app.QuadScanFitTab = uitab(app.TabGroup);
      app.QuadScanFitTab.Title = 'Quad Scan Fit';

      % Create UIAxes
      app.UIAxes = uiaxes(app.QuadScanFitTab);
      title(app.UIAxes, '')
      xlabel(app.UIAxes, 'X')
      ylabel(app.UIAxes, 'Y')
      app.UIAxes.Position = [10 225 557 214];

      % Create UIAxes_2
      app.UIAxes_2 = uiaxes(app.QuadScanFitTab);
      title(app.UIAxes_2, '')
      xlabel(app.UIAxes_2, 'X')
      ylabel(app.UIAxes_2, 'Y')
      app.UIAxes_2.Position = [10 8 557 211];

      % Create XAnalyticFitemitbmagPanel
      app.XAnalyticFitemitbmagPanel = uipanel(app.QuadScanFitTab);
      app.XAnalyticFitemitbmagPanel.Title = 'X Analytic Fit (emit/bmag)';
      app.XAnalyticFitemitbmagPanel.Position = [575 353 164 66];

      % Create GridLayout
      app.GridLayout = uigridlayout(app.XAnalyticFitemitbmagPanel);
      app.GridLayout.RowHeight = {'1x'};

      % Create EditField
      app.EditField = uieditfield(app.GridLayout, 'numeric');
      app.EditField.ValueDisplayFormat = '%.2f';
      app.EditField.Editable = 'off';
      app.EditField.HorizontalAlignment = 'center';
      app.EditField.Layout.Row = 1;
      app.EditField.Layout.Column = 2;

      % Create EditField_2
      app.EditField_2 = uieditfield(app.GridLayout, 'numeric');
      app.EditField_2.ValueDisplayFormat = '%.2f';
      app.EditField_2.Editable = 'off';
      app.EditField_2.HorizontalAlignment = 'center';
      app.EditField_2.Layout.Row = 1;
      app.EditField_2.Layout.Column = 1;

      % Create XModelFitemitbmagPanel
      app.XModelFitemitbmagPanel = uipanel(app.QuadScanFitTab);
      app.XModelFitemitbmagPanel.Title = 'X Model Fit (emit/bmag)';
      app.XModelFitemitbmagPanel.Position = [576 271 164 66];

      % Create GridLayout_2
      app.GridLayout_2 = uigridlayout(app.XModelFitemitbmagPanel);
      app.GridLayout_2.RowHeight = {'1x'};

      % Create EditField_3
      app.EditField_3 = uieditfield(app.GridLayout_2, 'numeric');
      app.EditField_3.ValueDisplayFormat = '%.2f';
      app.EditField_3.Editable = 'off';
      app.EditField_3.HorizontalAlignment = 'center';
      app.EditField_3.Layout.Row = 1;
      app.EditField_3.Layout.Column = 2;

      % Create EditField_4
      app.EditField_4 = uieditfield(app.GridLayout_2, 'numeric');
      app.EditField_4.ValueDisplayFormat = '%.2f';
      app.EditField_4.Editable = 'off';
      app.EditField_4.HorizontalAlignment = 'center';
      app.EditField_4.Layout.Row = 1;
      app.EditField_4.Layout.Column = 1;

      % Create YAnalyticFitemitbmagPanel
      app.YAnalyticFitemitbmagPanel = uipanel(app.QuadScanFitTab);
      app.YAnalyticFitemitbmagPanel.Title = 'Y Analytic Fit (emit/bmag)';
      app.YAnalyticFitemitbmagPanel.Position = [575 111 164 66];

      % Create GridLayout_3
      app.GridLayout_3 = uigridlayout(app.YAnalyticFitemitbmagPanel);
      app.GridLayout_3.RowHeight = {'1x'};

      % Create EditField_5
      app.EditField_5 = uieditfield(app.GridLayout_3, 'numeric');
      app.EditField_5.ValueDisplayFormat = '%.2f';
      app.EditField_5.Editable = 'off';
      app.EditField_5.HorizontalAlignment = 'center';
      app.EditField_5.Layout.Row = 1;
      app.EditField_5.Layout.Column = 2;

      % Create EditField_6
      app.EditField_6 = uieditfield(app.GridLayout_3, 'numeric');
      app.EditField_6.ValueDisplayFormat = '%.2f';
      app.EditField_6.Editable = 'off';
      app.EditField_6.HorizontalAlignment = 'center';
      app.EditField_6.Layout.Row = 1;
      app.EditField_6.Layout.Column = 1;

      % Create YModelFitemitbmagPanel_2
      app.YModelFitemitbmagPanel_2 = uipanel(app.QuadScanFitTab);
      app.YModelFitemitbmagPanel_2.Title = 'Y Model Fit (emit/bmag)';
      app.YModelFitemitbmagPanel_2.Position = [576 29 164 66];

      % Create GridLayout_4
      app.GridLayout_4 = uigridlayout(app.YModelFitemitbmagPanel_2);
      app.GridLayout_4.RowHeight = {'1x'};

      % Create EditField_7
      app.EditField_7 = uieditfield(app.GridLayout_4, 'numeric');
      app.EditField_7.ValueDisplayFormat = '%.2f';
      app.EditField_7.Editable = 'off';
      app.EditField_7.HorizontalAlignment = 'center';
      app.EditField_7.Layout.Row = 1;
      app.EditField_7.Layout.Column = 2;

      % Create EditField_8
      app.EditField_8 = uieditfield(app.GridLayout_4, 'numeric');
      app.EditField_8.ValueDisplayFormat = '%.2f';
      app.EditField_8.Editable = 'off';
      app.EditField_8.HorizontalAlignment = 'center';
      app.EditField_8.Layout.Row = 1;
      app.EditField_8.Layout.Column = 1;

      % Create ProfileFitMethodButtonGroup
      app.ProfileFitMethodButtonGroup = uibuttongroup(app.QuadScanFitTab);
      app.ProfileFitMethodButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ProfileFitMethodButtonGroupSelectionChanged, true);
      app.ProfileFitMethodButtonGroup.Title = 'Profile Fit Method';
      app.ProfileFitMethodButtonGroup.Position = [576 188 164 75];

      % Create GaussianButton
      app.GaussianButton = uiradiobutton(app.ProfileFitMethodButtonGroup);
      app.GaussianButton.Text = 'Gaussian';
      app.GaussianButton.Position = [11 29 74 22];

      % Create AsymmetricGaussianButton
      app.AsymmetricGaussianButton = uiradiobutton(app.ProfileFitMethodButtonGroup);
      app.AsymmetricGaussianButton.Text = 'Asymmetric Gaussian';
      app.AsymmetricGaussianButton.Position = [11 7 140 22];
      app.AsymmetricGaussianButton.Value = true;

      % Create OpticsPlotTab
      app.OpticsPlotTab = uitab(app.TabGroup);
      app.OpticsPlotTab.Title = 'Optics Plot';

      % Create UIAxes2
      app.UIAxes2 = uiaxes(app.OpticsPlotTab);
      title(app.UIAxes2, '')
      xlabel(app.UIAxes2, 'X')
      ylabel(app.UIAxes2, 'Y')
      app.UIAxes2.Position = [11 13 731 319];

      % Create UIAxes2_2
      app.UIAxes2_2 = uiaxes(app.OpticsPlotTab);
      title(app.UIAxes2_2, '')
      xlabel(app.UIAxes2_2, 'X')
      ylabel(app.UIAxes2_2, 'Y')
      app.UIAxes2_2.Position = [25 334 696 107];

      % Create MessagesPanel
      app.MessagesPanel = uipanel(app.FACETIIOpticsMatchingUIFigure);
      app.MessagesPanel.Title = 'Messages';
      app.MessagesPanel.Position = [255 8 752 74];

      % Create TextArea
      app.TextArea = uitextarea(app.MessagesPanel);
      app.TextArea.Position = [6 9 739 36];

      % Create OptimizerDropDownLabel
      app.OptimizerDropDownLabel = uilabel(app.FACETIIOpticsMatchingUIFigure);
      app.OptimizerDropDownLabel.HorizontalAlignment = 'right';
      app.OptimizerDropDownLabel.Position = [71 316 57 22];
      app.OptimizerDropDownLabel.Text = 'Optimizer';

      % Create OptimizerDropDown
      app.OptimizerDropDown = uidropdown(app.FACETIIOpticsMatchingUIFigure);
      app.OptimizerDropDown.Items = {'fminsearch', 'lsqnonlin'};
      app.OptimizerDropDown.ValueChangedFcn = createCallbackFcn(app, @OptimizerDropDownValueChanged, true);
      app.OptimizerDropDown.Position = [143 316 100 22];
      app.OptimizerDropDown.Value = 'lsqnonlin';

      % Create MatchingQuadsSpinnerLabel
      app.MatchingQuadsSpinnerLabel = uilabel(app.FACETIIOpticsMatchingUIFigure);
      app.MatchingQuadsSpinnerLabel.HorizontalAlignment = 'right';
      app.MatchingQuadsSpinnerLabel.Position = [24 347 104 22];
      app.MatchingQuadsSpinnerLabel.Text = '# Matching Quads';

      % Create MatchingQuadsSpinner
      app.MatchingQuadsSpinner = uispinner(app.FACETIIOpticsMatchingUIFigure);
      app.MatchingQuadsSpinner.Limits = [4 15];
      app.MatchingQuadsSpinner.ValueDisplayFormat = '%d';
      app.MatchingQuadsSpinner.ValueChangedFcn = createCallbackFcn(app, @MatchingQuadsSpinnerValueChanged, true);
      app.MatchingQuadsSpinner.Interruptible = 'off';
      app.MatchingQuadsSpinner.Position = [143 347 100 22];
      app.MatchingQuadsSpinner.Value = 4;

      % Create ProfileMeasurementDevicePanel
      app.ProfileMeasurementDevicePanel = uipanel(app.FACETIIOpticsMatchingUIFigure);
      app.ProfileMeasurementDevicePanel.Title = 'Profile Measurement Device';
      app.ProfileMeasurementDevicePanel.Position = [11 543 238 50];

      % Create DropDown
      app.DropDown = uidropdown(app.ProfileMeasurementDevicePanel);
      app.DropDown.Items = {'<Select From Below>', 'PROF:IN10:571', 'PROF:LI11:335', 'PROF:LI11:375'};
      app.DropDown.ValueChangedFcn = createCallbackFcn(app, @DropDownValueChanged, true);
      app.DropDown.Interruptible = 'off';
      app.DropDown.Position = [13 3 214 22];
      app.DropDown.Value = '<Select From Below>';

      % Create TwissProfileDevicePanel
      app.TwissProfileDevicePanel = uipanel(app.FACETIIOpticsMatchingUIFigure);
      app.TwissProfileDevicePanel.Title = 'Twiss @ Profile Device';
      app.TwissProfileDevicePanel.Position = [8 7 238 298];

      % Create UITable2
      app.UITable2 = uitable(app.TwissProfileDevicePanel);
      app.UITable2.ColumnName = {'Param'; 'Meas.'; 'Match'; 'Design'};
      app.UITable2.ColumnWidth = {55, 55, 55, 55};
      app.UITable2.RowName = {};
      app.UITable2.ColumnEditable = [false false false false];
      app.UITable2.Position = [9 62 224 210];

      % Create WritetoPVsButton
      app.WritetoPVsButton = uibutton(app.TwissProfileDevicePanel, 'push');
      app.WritetoPVsButton.ButtonPushedFcn = createCallbackFcn(app, @WritetoPVsButtonPushed, true);
      app.WritetoPVsButton.Position = [151 4 81 53];
      app.WritetoPVsButton.Text = 'Write to PVs';

      % Create TwissFitMethodButtonGroup
      app.TwissFitMethodButtonGroup = uibuttongroup(app.TwissProfileDevicePanel);
      app.TwissFitMethodButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @TwissFitMethodButtonGroupSelectionChanged, true);
      app.TwissFitMethodButtonGroup.Title = 'Twiss Fit Method';
      app.TwissFitMethodButtonGroup.Position = [9 5 136 52];

      % Create AnalyticButton
      app.AnalyticButton = uiradiobutton(app.TwissFitMethodButtonGroup);
      app.AnalyticButton.Text = 'Analytic';
      app.AnalyticButton.Position = [7 6 65 22];

      % Create ModelButton
      app.ModelButton = uiradiobutton(app.TwissFitMethodButtonGroup);
      app.ModelButton.Text = 'Model';
      app.ModelButton.Position = [77 6 52 22];
      app.ModelButton.Value = true;

      % Create DoMatchingButton
      app.DoMatchingButton = uibutton(app.FACETIIOpticsMatchingUIFigure, 'push');
      app.DoMatchingButton.ButtonPushedFcn = createCallbackFcn(app, @DoMatchingButtonPushed, true);
      app.DoMatchingButton.Interruptible = 'off';
      app.DoMatchingButton.Position = [259 88 175 27];
      app.DoMatchingButton.Text = 'Do Matching';

      % Create SetMatchingQuadsButton
      app.SetMatchingQuadsButton = uibutton(app.FACETIIOpticsMatchingUIFigure, 'push');
      app.SetMatchingQuadsButton.ButtonPushedFcn = createCallbackFcn(app, @SetMatchingQuadsButtonPushed, true);
      app.SetMatchingQuadsButton.Interruptible = 'off';
      app.SetMatchingQuadsButton.Enable = 'off';
      app.SetMatchingQuadsButton.Position = [447 88 130 27];
      app.SetMatchingQuadsButton.Text = 'Set Matching Quads';

      % Create GetQuadScanDataandfitTwissPanel
      app.GetQuadScanDataandfitTwissPanel = uipanel(app.FACETIIOpticsMatchingUIFigure);
      app.GetQuadScanDataandfitTwissPanel.Title = 'Get Quad Scan Data and fit Twiss';
      app.GetQuadScanDataandfitTwissPanel.Position = [11 377 238 98];

      % Create GetDatafromCorrPlotorEmitGUIButton
      app.GetDatafromCorrPlotorEmitGUIButton = uibutton(app.GetQuadScanDataandfitTwissPanel, 'push');
      app.GetDatafromCorrPlotorEmitGUIButton.ButtonPushedFcn = createCallbackFcn(app, @GetDatafromCorrPlotorEmitGUIButtonPushed, true);
      app.GetDatafromCorrPlotorEmitGUIButton.Interruptible = 'off';
      app.GetDatafromCorrPlotorEmitGUIButton.Position = [14 39 210 31];
      app.GetDatafromCorrPlotorEmitGUIButton.Text = 'Get Data from Corr Plot or Emit GUI';

      % Create UseXDataButton
      app.UseXDataButton = uibutton(app.GetQuadScanDataandfitTwissPanel, 'state');
      app.UseXDataButton.ValueChangedFcn = createCallbackFcn(app, @UseXDataButtonValueChanged, true);
      app.UseXDataButton.Text = 'Use X Data';
      app.UseXDataButton.Position = [15 9 100 23];
      app.UseXDataButton.Value = true;

      % Create UseYDataButton
      app.UseYDataButton = uibutton(app.GetQuadScanDataandfitTwissPanel, 'state');
      app.UseYDataButton.ValueChangedFcn = createCallbackFcn(app, @UseYDataButtonValueChanged, true);
      app.UseYDataButton.Text = 'Use Y Data';
      app.UseYDataButton.Position = [123 9 100 23];
      app.UseYDataButton.Value = true;

      % Create UndoButton
      app.UndoButton = uibutton(app.FACETIIOpticsMatchingUIFigure, 'push');
      app.UndoButton.ButtonPushedFcn = createCallbackFcn(app, @UndoButtonPushed, true);
      app.UndoButton.Interruptible = 'off';
      app.UndoButton.Enable = 'off';
      app.UndoButton.Position = [589 88 87 27];
      app.UndoButton.Text = 'Undo';

      % Create ModelDatePanel
      app.ModelDatePanel = uipanel(app.FACETIIOpticsMatchingUIFigure);
      app.ModelDatePanel.Title = 'Model Date';
      app.ModelDatePanel.Position = [11 485 238 48];

      % Create ModelDateEditField
      app.ModelDateEditField = uieditfield(app.ModelDatePanel, 'text');
      app.ModelDateEditField.Editable = 'off';
      app.ModelDateEditField.Position = [7 3 222 22];
      app.ModelDateEditField.Value = 'LIVE';

      % Show the figure after all components are created
      app.FACETIIOpticsMatchingUIFigure.Visible = 'on';
    end
  end

  % App creation and deletion
  methods (Access = public)

    % Construct app
    function app = F2_Matching_exported

      % Create UIFigure and components
      createComponents(app)

      % Register the app with App Designer
      registerApp(app, app.FACETIIOpticsMatchingUIFigure)

      % Execute the startup function
      runStartupFcn(app, @startupFcn)

      if nargout == 0
        clear app
      end
    end

    % Code that executes before app deletion
    function delete(app)

      % Delete UIFigure when app is deleted
      delete(app.FACETIIOpticsMatchingUIFigure)
    end
  end
end