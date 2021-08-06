classdef F2_Matching_exported < matlab.apps.AppBase

  % Properties that correspond to app components
  properties (Access = public)
    FACETIIOpticsMatchingUIFigure   matlab.ui.Figure
    SettingsMenu                    matlab.ui.container.Menu
    ModelMenu                       matlab.ui.container.Menu
    UsearchivematchingdatadateMenu  matlab.ui.container.Menu
    UsecurrentlivemodelMenu         matlab.ui.container.Menu
    UsedesignmodelMenu              matlab.ui.container.Menu
    TabGroup                        matlab.ui.container.TabGroup
    MagnetsTab                      matlab.ui.container.Tab
    UITable                         matlab.ui.control.Table
    QuadScanPlotTab                 matlab.ui.container.Tab
    UIAxes                          matlab.ui.control.UIAxes
    UIAxes_2                        matlab.ui.control.UIAxes
    OpticsPlotTab                   matlab.ui.container.Tab
    UIAxes2                         matlab.ui.control.UIAxes
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
    WriteTwissMeastoPVButton        matlab.ui.control.Button
    DoMatchingButton                matlab.ui.control.Button
    SetMatchingQuadsButton          matlab.ui.control.Button
    GetQuadScanDataandfitTwissPanel  matlab.ui.container.Panel
    GetDatafromCorrPlotButton       matlab.ui.control.Button
    UseXDataButton                  matlab.ui.control.StateButton
    UseYDataButton                  matlab.ui.control.StateButton
    UndoButton                      matlab.ui.control.Button
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
      drawnow
      app.aobj = F2_MatchingApp(app) ;
      app.message(["Loading and initializing model...","Done."]);
      app.DropDownValueChanged ; % populates tables
    end

    % Value changed function: DropDown
    function DropDownValueChanged(app, event)
      value = app.DropDown.Value;
      if value ~= app.aobj.ProfName
        try
          app.aobj.ProfName = value ;
        catch ME
           app.message(["Error selecting profile monitor", string(ME.message)],true) ;
           return
        end
      end
      app.UITable.Data = app.aobj.MagnetTable ;
      app.UITable2.Data = app.aobj.TwissTable ;
      app.TabGroupSelectionChanged;
    end

    % Selection change function: TabGroup
    function TabGroupSelectionChanged(app, event)
      selectedTab = app.TabGroup.SelectedTab;
      switch selectedTab
        case app.QuadScanPlotTab
          app.aobj.PlotQuadScanData;
        case app.OpticsPlotTab
          app.aobj.PlotTwiss;
      end
    end

    % Button pushed function: GetDatafromCorrPlotButton
    function GetDatafromCorrPlotButtonPushed(app, event)
      app.message("Requesting data transfer from Correlation Plot Software...");
      drawnow
      try
        app.aobj.LoadQuadScanData;
      catch ME
        app.message(["No quad scan data transfer performed...";string(ME.message)],true);
        return
      end
      app.message(["Requesting data transfer from Correlation Plot Software...";"Done."]);
      if ~ismember(app.aobj.ProfName,string(app.DropDown.Items)) % Add profile monitor to list if it isn't there
        app.DropDown.Items=[string(app.DropDown.Items);app.aobj.ProfName];
        app.DropDown.Value=app.aobj.ProfName;
      end
      app.DropDownValueChanged ; % populates tables
    end

    % Value changed function: UseXDataButton
    function UseXDataButtonValueChanged(app, event)
      value = app.UseXDataButton.Value;
      if value && app.UseYDataButton.Value
        str="XY" ;
      else
        str="X" ;
        if ~value
          app.UseXDataButton.Value=true;
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
          app.UseYDataButton.Value=true;
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

    % Button pushed function: WriteTwissMeastoPVButton
    function WriteTwissMeastoPVButtonPushed(app, event)
      app.aobj.WriteEmitData;
      if ~app.UseXDataButton.Value
        app.message("Emittance data for X only written",true);
      elseif ~app.UseYDataButton.Value
        app.message("Emittance data for Y only written",true);
      else
        app.message("Emittance data written to PVs");
      end
    end

    % Button pushed function: DoMatchingButton
    function DoMatchingButtonPushed(app, event)
      app.message("Running matching job, see matlab window for details...");
      drawnow
      try
        app.aobj.DoMatch;
      catch ME
        app.message(["Matching Error...";string(ME.message)]);
        return
      end
      app.message(["Running matching job, see matlab window for details..."; "Done."]);
      app.DropDownValueChanged ; % populates tables
    end

    % Button pushed function: SetMatchingQuadsButton
    function SetMatchingQuadsButtonPushed(app, event)
      app.message("Setting matching quads...");
      drawnow
      try
        msg=app.WriteMatchQuads;
      catch ME
        app.message(["Error writing matching quads...";string(ME.message)]);
        return
      end
      if startsWith(string(msg),'!')
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
        msg=app.WriteMatchQuads;
      catch ME
        app.message(["Error writing matching quads...";string(ME.message)]);
        return
      end
      if startsWith(string(msg),'!')
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
      app.message(["Design Model will be used";"Updating Model... Done."]);
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
      app.UsearchivematchingdatadateMenu.Checked = 'on';
      app.UsearchivematchingdatadateMenu.Text = 'Use archive matching data date';

      % Create UsecurrentlivemodelMenu
      app.UsecurrentlivemodelMenu = uimenu(app.ModelMenu);
      app.UsecurrentlivemodelMenu.MenuSelectedFcn = createCallbackFcn(app, @UsecurrentlivemodelMenuSelected, true);
      app.UsecurrentlivemodelMenu.Text = 'Use current live model';

      % Create UsedesignmodelMenu
      app.UsedesignmodelMenu = uimenu(app.ModelMenu);
      app.UsedesignmodelMenu.MenuSelectedFcn = createCallbackFcn(app, @UsedesignmodelMenuSelected, true);
      app.UsedesignmodelMenu.Text = 'Use design model';

      % Create TabGroup
      app.TabGroup = uitabgroup(app.FACETIIOpticsMatchingUIFigure);
      app.TabGroup.SelectionChangedFcn = createCallbackFcn(app, @TabGroupSelectionChanged, true);
      app.TabGroup.Position = [255 87 752 507];

      % Create MagnetsTab
      app.MagnetsTab = uitab(app.TabGroup);
      app.MagnetsTab.Title = 'Magnets';

      % Create UITable
      app.UITable = uitable(app.MagnetsTab);
      app.UITable.ColumnName = {'Column 1'; 'Column 2'; 'Column 3'; 'Column 4'};
      app.UITable.RowName = {};
      app.UITable.Position = [4 2 744 480];

      % Create QuadScanPlotTab
      app.QuadScanPlotTab = uitab(app.TabGroup);
      app.QuadScanPlotTab.Title = 'Quad Scan Plot';

      % Create UIAxes
      app.UIAxes = uiaxes(app.QuadScanPlotTab);
      title(app.UIAxes, '')
      xlabel(app.UIAxes, 'X')
      ylabel(app.UIAxes, 'Y')
      app.UIAxes.Position = [10 243 733 230];

      % Create UIAxes_2
      app.UIAxes_2 = uiaxes(app.QuadScanPlotTab);
      title(app.UIAxes_2, '')
      xlabel(app.UIAxes_2, 'X')
      ylabel(app.UIAxes_2, 'Y')
      app.UIAxes_2.Position = [10 7 733 230];

      % Create OpticsPlotTab
      app.OpticsPlotTab = uitab(app.TabGroup);
      app.OpticsPlotTab.Title = 'Optics Plot';

      % Create UIAxes2
      app.UIAxes2 = uiaxes(app.OpticsPlotTab);
      title(app.UIAxes2, '')
      xlabel(app.UIAxes2, 'X')
      ylabel(app.UIAxes2, 'Y')
      app.UIAxes2.Position = [11 1 731 469];

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
      app.OptimizerDropDownLabel.Position = [71 348 57 22];
      app.OptimizerDropDownLabel.Text = 'Optimizer';

      % Create OptimizerDropDown
      app.OptimizerDropDown = uidropdown(app.FACETIIOpticsMatchingUIFigure);
      app.OptimizerDropDown.Items = {'fminsearch', 'lsqnonlin'};
      app.OptimizerDropDown.ValueChangedFcn = createCallbackFcn(app, @OptimizerDropDownValueChanged, true);
      app.OptimizerDropDown.Position = [143 348 100 22];
      app.OptimizerDropDown.Value = 'lsqnonlin';

      % Create MatchingQuadsSpinnerLabel
      app.MatchingQuadsSpinnerLabel = uilabel(app.FACETIIOpticsMatchingUIFigure);
      app.MatchingQuadsSpinnerLabel.HorizontalAlignment = 'right';
      app.MatchingQuadsSpinnerLabel.Position = [24 382 104 22];
      app.MatchingQuadsSpinnerLabel.Text = '# Matching Quads';

      % Create MatchingQuadsSpinner
      app.MatchingQuadsSpinner = uispinner(app.FACETIIOpticsMatchingUIFigure);
      app.MatchingQuadsSpinner.Limits = [4 15];
      app.MatchingQuadsSpinner.ValueDisplayFormat = '%d';
      app.MatchingQuadsSpinner.ValueChangedFcn = createCallbackFcn(app, @MatchingQuadsSpinnerValueChanged, true);
      app.MatchingQuadsSpinner.Position = [143 382 100 22];
      app.MatchingQuadsSpinner.Value = 4;

      % Create ProfileMeasurementDevicePanel
      app.ProfileMeasurementDevicePanel = uipanel(app.FACETIIOpticsMatchingUIFigure);
      app.ProfileMeasurementDevicePanel.Title = 'Profile Measurement Device';
      app.ProfileMeasurementDevicePanel.Position = [11 521 238 63];

      % Create DropDown
      app.DropDown = uidropdown(app.ProfileMeasurementDevicePanel);
      app.DropDown.Items = {'PROF:IN10:571'};
      app.DropDown.ValueChangedFcn = createCallbackFcn(app, @DropDownValueChanged, true);
      app.DropDown.Position = [13 11 214 22];
      app.DropDown.Value = 'PROF:IN10:571';

      % Create TwissProfileDevicePanel
      app.TwissProfileDevicePanel = uipanel(app.FACETIIOpticsMatchingUIFigure);
      app.TwissProfileDevicePanel.Title = 'Twiss @ Profile Device';
      app.TwissProfileDevicePanel.Position = [8 93 238 241];

      % Create UITable2
      app.UITable2 = uitable(app.TwissProfileDevicePanel);
      app.UITable2.ColumnName = {'Param'; 'Meas.'; 'Match'; 'Design'};
      app.UITable2.ColumnWidth = {55, 55, 55, 55};
      app.UITable2.RowName = {'beta_x'; 'alpha_x'; 'beta_y'; 'alpha_y'};
      app.UITable2.ColumnEditable = [false false false false];
      app.UITable2.Position = [8 32 224 183];

      % Create WriteTwissMeastoPVButton
      app.WriteTwissMeastoPVButton = uibutton(app.TwissProfileDevicePanel, 'push');
      app.WriteTwissMeastoPVButton.ButtonPushedFcn = createCallbackFcn(app, @WriteTwissMeastoPVButtonPushed, true);
      app.WriteTwissMeastoPVButton.Position = [41.5 5 148 23];
      app.WriteTwissMeastoPVButton.Text = 'Write Twiss  Meas. to PV';

      % Create DoMatchingButton
      app.DoMatchingButton = uibutton(app.FACETIIOpticsMatchingUIFigure, 'push');
      app.DoMatchingButton.ButtonPushedFcn = createCallbackFcn(app, @DoMatchingButtonPushed, true);
      app.DoMatchingButton.Position = [39 52 175 35];
      app.DoMatchingButton.Text = 'Do Matching';

      % Create SetMatchingQuadsButton
      app.SetMatchingQuadsButton = uibutton(app.FACETIIOpticsMatchingUIFigure, 'push');
      app.SetMatchingQuadsButton.ButtonPushedFcn = createCallbackFcn(app, @SetMatchingQuadsButtonPushed, true);
      app.SetMatchingQuadsButton.Enable = 'off';
      app.SetMatchingQuadsButton.Position = [23 11 119 35];
      app.SetMatchingQuadsButton.Text = 'Set Matching Quads';

      % Create GetQuadScanDataandfitTwissPanel
      app.GetQuadScanDataandfitTwissPanel = uipanel(app.FACETIIOpticsMatchingUIFigure);
      app.GetQuadScanDataandfitTwissPanel.Title = 'Get Quad Scan Data and fit Twiss';
      app.GetQuadScanDataandfitTwissPanel.Position = [11 415 238 98];

      % Create GetDatafromCorrPlotButton
      app.GetDatafromCorrPlotButton = uibutton(app.GetQuadScanDataandfitTwissPanel, 'push');
      app.GetDatafromCorrPlotButton.ButtonPushedFcn = createCallbackFcn(app, @GetDatafromCorrPlotButtonPushed, true);
      app.GetDatafromCorrPlotButton.Position = [14 39 210 31];
      app.GetDatafromCorrPlotButton.Text = 'Get Data from Corr Plot';

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
      app.UndoButton.Enable = 'off';
      app.UndoButton.Position = [152 11 87 35];
      app.UndoButton.Text = 'Undo';

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