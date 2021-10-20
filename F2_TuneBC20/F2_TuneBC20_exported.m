classdef F2_TuneBC20_exported < matlab.apps.AppBase

  % Properties that correspond to app components
  properties (Access = public)
    F2_TuneBC20UIFigure            matlab.ui.Figure
    S1LRPanel                      matlab.ui.container.Panel
    UpperLimitEditFieldLabel       matlab.ui.control.Label
    S1BDES_UpperLimit              matlab.ui.control.NumericEditField
    LowerLimitEditFieldLabel       matlab.ui.control.Label
    S1BDES_LowerLimit              matlab.ui.control.NumericEditField
    BDESEditFieldLabel             matlab.ui.control.Label
    S1BDES                         matlab.ui.control.NumericEditField
    S2LRPanel                      matlab.ui.container.Panel
    UpperLimitEditField_2Label     matlab.ui.control.Label
    S2BDES_UpperLimit              matlab.ui.control.NumericEditField
    LowerLimitEditField_2Label     matlab.ui.control.Label
    S2BDES_LowerLimit              matlab.ui.control.NumericEditField
    BDESEditField_2Label           matlab.ui.control.Label
    S2BDES                         matlab.ui.control.NumericEditField
    S3LRPanel                      matlab.ui.container.Panel
    UpperLimitEditField_3Label     matlab.ui.control.Label
    S3BDES_UpperLimit              matlab.ui.control.NumericEditField
    LowerLimitEditField_3Label     matlab.ui.control.Label
    S3BDES_LowerLimit              matlab.ui.control.NumericEditField
    BDESEditField_3Label           matlab.ui.control.Label
    S3BDES                         matlab.ui.control.NumericEditField
    OptimizationAlgorithmButtonGroup  matlab.ui.container.ButtonGroup
    fminsearchButton               matlab.ui.control.RadioButton
    XoptMOBOButton                 matlab.ui.control.RadioButton
    XoptCNSGAButton                matlab.ui.control.RadioButton
    fminconButton                  matlab.ui.control.RadioButton
    lsqnonlinButton                matlab.ui.control.RadioButton
    ProfileMeasurementButtonGroup  matlab.ui.container.ButtonGroup
    IPOTR1Button_2                 matlab.ui.control.RadioButton
    IPOTR1PButton                  matlab.ui.control.RadioButton
    IPOTR2Button                   matlab.ui.control.RadioButton
    SpotSizeumEditFieldLabel       matlab.ui.control.Label
    SpotSizeEditField              matlab.ui.control.NumericEditField
    NBkgEditFieldLabel             matlab.ui.control.Label
    NBkgEditField                  matlab.ui.control.NumericEditField
    PRDMPButton                    matlab.ui.control.RadioButton
    UIAxes_2                       matlab.ui.control.UIAxes
    WDSOTRButton                   matlab.ui.control.RadioButton
    DSOTRButton                    matlab.ui.control.RadioButton
    UIAxes_3                       matlab.ui.control.UIAxes
    BackgroundMeasurementButtonGroup  matlab.ui.container.ButtonGroup
    PMT3179Button                  matlab.ui.control.RadioButton
    PMT3350Button                  matlab.ui.control.RadioButton
    PMT3360Button                  matlab.ui.control.RadioButton
    BkgEditField                   matlab.ui.control.NumericEditField
    UIAxes                         matlab.ui.control.UIAxes
    PMT3070Button                  matlab.ui.control.RadioButton
    RunControlsPanel               matlab.ui.container.Panel
    RunButton                      matlab.ui.control.Button
    STOPButton                     matlab.ui.control.Button
    StatusLabel                    matlab.ui.control.Label
    StatusText                     matlab.ui.control.TextArea
    ResetBDESButton                matlab.ui.control.Button
    SetOptimizedBDESButton         matlab.ui.control.Button
  end

  
  properties (Access = public)
    aobj % Application object generated at startup
    bkgdata % Store data for BKG scrolling plot
    sxdata % Store data for spot size scrolling plot
  end
  

  % Callbacks that handle component events
  methods (Access = private)

    % Code that executes after component creation
    function startupFcn(app)
      app.aobj = F2_TuneBC20App(app) ;
      % No axis lines or labels for plots
      app.UIAxes.XColor='none'; app.UIAxes.XTick=[]; app.UIAxes.YColor='none'; app.UIAxes.YTick=[];
      app.UIAxes_2.XColor='none'; app.UIAxes_2.XTick=[]; app.UIAxes_2.YColor='none'; app.UIAxes_2.YTick=[];
      app.UIAxes_3.XColor='none'; app.UIAxes_3.XTick=[]; app.UIAxes_3.YColor='none'; app.UIAxes_3.YTick=[];
    end

    % Selection changed function: 
    % BackgroundMeasurementButtonGroup
    function BackgroundMeasurementButtonGroupSelectionChanged(app, event)
      selectedButton = app.BackgroundMeasurementButtonGroup.SelectedObject;
      app.aobj.BkgDevice = string(selectedButton.Text) ;
    end

    % Selection changed function: 
    % OptimizationAlgorithmButtonGroup
    function OptimizationAlgorithmButtonGroupSelectionChanged(app, event)
      selectedButton = app.OptimizationAlgorithmButtonGroup.SelectedObject;
      alg = regexprep(selectedButton.Text,'Xopt - ','');
      app.aobj.OptimAlg = lower(string(alg)) ;
    end

    % Selection changed function: ProfileMeasurementButtonGroup
    function ProfileMeasurementButtonGroupSelectionChanged(app, event)
      selectedButton = app.ProfileMeasurementButtonGroup.SelectedObject;
      app.aobj.ProfDevice = string(selectedButton.Text) ;   
    end

    % Value changed function: NBkgEditField
    function NBkgEditFieldValueChanged(app, event)
      value = app.NBkgEditField.Value;
      app.aobj.Nbkg = uint8(value) ;
    end

    % Button pushed function: RunButton
    function RunButtonPushed(app, event)
      app.sxdata=[]; app.bkgdata=[];
      cla(app.UIAxes); cla(app.UIAxes_2); cla(app.UIAxes_3);
      try
        app.aobj.run ;
      catch ME
        app.StatusText.Value = "Error in optimizer run (see command window for details). Stopped." ;
        drawnow
        throw(ME);
      end
    end

    % Button pushed function: STOPButton
    function STOPButtonPushed(app, event)
      app.StatusText.Value = "Issued STOP command to optimizer..." ; drawnow
      assignin('base','dostop',true);
    end

    % Button pushed function: ResetBDESButton
    function ResetBDESButtonPushed(app, event)
      app.aobj.ResetSextBDES;
    end

    % Button pushed function: SetOptimizedBDESButton
    function SetOptimizedBDESButtonPushed(app, event)
      app.aobj.SetOptSextBDES;
    end

    % Value changed function: S1BDES_UpperLimit
    function S1BDES_UpperLimitValueChanged(app, event)
      app.aobj.S1Limit = [app.S1BDES_LowerLimit.Value app.S1BDES_UpperLimit.Value] ;
    end

    % Value changed function: S1BDES_LowerLimit
    function S1BDES_LowerLimitValueChanged(app, event)
      app.aobj.S1Limit = [app.S1BDES_LowerLimit.Value app.S1BDES_UpperLimit.Value] ;
    end

    % Value changed function: S2BDES_UpperLimit
    function S2BDES_UpperLimitValueChanged(app, event)
      app.aobj.S2Limit = [app.S2BDES_LowerLimit.Value app.S2BDES_UpperLimit.Value] ;
    end

    % Value changed function: S2BDES_LowerLimit
    function S2BDES_LowerLimitValueChanged(app, event)
      app.aobj.S2Limit = [app.S2BDES_LowerLimit.Value app.S2BDES_UpperLimit.Value] ;
    end

    % Value changed function: S3BDES_UpperLimit
    function S3BDES_UpperLimitValueChanged(app, event)
      app.aobj.S3Limit = [app.S3BDES_LowerLimit.Value app.S3BDES_UpperLimit.Value] ;
    end

    % Value changed function: S3BDES_LowerLimit
    function S3BDES_LowerLimitValueChanged(app, event)
      app.aobj.S3Limit = [app.S3BDES_LowerLimit.Value app.S3BDES_UpperLimit.Value] ;
    end
  end

  % Component initialization
  methods (Access = private)

    % Create UIFigure and components
    function createComponents(app)

      % Create F2_TuneBC20UIFigure and hide until all components are created
      app.F2_TuneBC20UIFigure = uifigure('Visible', 'off');
      app.F2_TuneBC20UIFigure.Position = [100 100 813 669];
      app.F2_TuneBC20UIFigure.Name = 'F2_TuneBC20';

      % Create S1LRPanel
      app.S1LRPanel = uipanel(app.F2_TuneBC20UIFigure);
      app.S1LRPanel.Title = 'S1 (L&R)';
      app.S1LRPanel.Position = [22 476 248 177];

      % Create UpperLimitEditFieldLabel
      app.UpperLimitEditFieldLabel = uilabel(app.S1LRPanel);
      app.UpperLimitEditFieldLabel.HorizontalAlignment = 'right';
      app.UpperLimitEditFieldLabel.Position = [33 113 68 22];
      app.UpperLimitEditFieldLabel.Text = 'Upper Limit';

      % Create S1BDES_UpperLimit
      app.S1BDES_UpperLimit = uieditfield(app.S1LRPanel, 'numeric');
      app.S1BDES_UpperLimit.ValueChangedFcn = createCallbackFcn(app, @S1BDES_UpperLimitValueChanged, true);
      app.S1BDES_UpperLimit.BackgroundColor = [1 0.4118 0.1608];
      app.S1BDES_UpperLimit.Position = [116 113 100 22];
      app.S1BDES_UpperLimit.Value = 1200;

      % Create LowerLimitEditFieldLabel
      app.LowerLimitEditFieldLabel = uilabel(app.S1LRPanel);
      app.LowerLimitEditFieldLabel.HorizontalAlignment = 'right';
      app.LowerLimitEditFieldLabel.Position = [33 27 68 22];
      app.LowerLimitEditFieldLabel.Text = 'Lower Limit';

      % Create S1BDES_LowerLimit
      app.S1BDES_LowerLimit = uieditfield(app.S1LRPanel, 'numeric');
      app.S1BDES_LowerLimit.ValueChangedFcn = createCallbackFcn(app, @S1BDES_LowerLimitValueChanged, true);
      app.S1BDES_LowerLimit.BackgroundColor = [1 0.4118 0.1608];
      app.S1BDES_LowerLimit.Position = [116 27 100 22];
      app.S1BDES_LowerLimit.Value = 100;

      % Create BDESEditFieldLabel
      app.BDESEditFieldLabel = uilabel(app.S1LRPanel);
      app.BDESEditFieldLabel.HorizontalAlignment = 'right';
      app.BDESEditFieldLabel.Position = [64 70 38 22];
      app.BDESEditFieldLabel.Text = 'BDES';

      % Create S1BDES
      app.S1BDES = uieditfield(app.S1LRPanel, 'numeric');
      app.S1BDES.ValueDisplayFormat = '%.3f';
      app.S1BDES.Interruptible = 'off';
      app.S1BDES.Position = [117 70 100 22];
      app.S1BDES.Value = 1169.371;

      % Create S2LRPanel
      app.S2LRPanel = uipanel(app.F2_TuneBC20UIFigure);
      app.S2LRPanel.Title = 'S2 (L&R)';
      app.S2LRPanel.Position = [285 476 248 177];

      % Create UpperLimitEditField_2Label
      app.UpperLimitEditField_2Label = uilabel(app.S2LRPanel);
      app.UpperLimitEditField_2Label.HorizontalAlignment = 'right';
      app.UpperLimitEditField_2Label.Position = [33 113 68 22];
      app.UpperLimitEditField_2Label.Text = 'Upper Limit';

      % Create S2BDES_UpperLimit
      app.S2BDES_UpperLimit = uieditfield(app.S2LRPanel, 'numeric');
      app.S2BDES_UpperLimit.ValueChangedFcn = createCallbackFcn(app, @S2BDES_UpperLimitValueChanged, true);
      app.S2BDES_UpperLimit.BackgroundColor = [1 0.4118 0.1608];
      app.S2BDES_UpperLimit.Position = [116 113 100 22];

      % Create LowerLimitEditField_2Label
      app.LowerLimitEditField_2Label = uilabel(app.S2LRPanel);
      app.LowerLimitEditField_2Label.HorizontalAlignment = 'right';
      app.LowerLimitEditField_2Label.Position = [33 27 68 22];
      app.LowerLimitEditField_2Label.Text = 'Lower Limit';

      % Create S2BDES_LowerLimit
      app.S2BDES_LowerLimit = uieditfield(app.S2LRPanel, 'numeric');
      app.S2BDES_LowerLimit.ValueChangedFcn = createCallbackFcn(app, @S2BDES_LowerLimitValueChanged, true);
      app.S2BDES_LowerLimit.BackgroundColor = [1 0.4118 0.1608];
      app.S2BDES_LowerLimit.Position = [116 27 100 22];
      app.S2BDES_LowerLimit.Value = -3000;

      % Create BDESEditField_2Label
      app.BDESEditField_2Label = uilabel(app.S2LRPanel);
      app.BDESEditField_2Label.HorizontalAlignment = 'right';
      app.BDESEditField_2Label.Position = [64 70 38 22];
      app.BDESEditField_2Label.Text = 'BDES';

      % Create S2BDES
      app.S2BDES = uieditfield(app.S2LRPanel, 'numeric');
      app.S2BDES.ValueDisplayFormat = '%.3f';
      app.S2BDES.Interruptible = 'off';
      app.S2BDES.Position = [117 70 100 22];
      app.S2BDES.Value = -2739.522;

      % Create S3LRPanel
      app.S3LRPanel = uipanel(app.F2_TuneBC20UIFigure);
      app.S3LRPanel.Title = 'S3 (L&R)';
      app.S3LRPanel.Position = [550 476 248 177];

      % Create UpperLimitEditField_3Label
      app.UpperLimitEditField_3Label = uilabel(app.S3LRPanel);
      app.UpperLimitEditField_3Label.HorizontalAlignment = 'right';
      app.UpperLimitEditField_3Label.Position = [33 113 68 22];
      app.UpperLimitEditField_3Label.Text = 'Upper Limit';

      % Create S3BDES_UpperLimit
      app.S3BDES_UpperLimit = uieditfield(app.S3LRPanel, 'numeric');
      app.S3BDES_UpperLimit.ValueChangedFcn = createCallbackFcn(app, @S3BDES_UpperLimitValueChanged, true);
      app.S3BDES_UpperLimit.BackgroundColor = [1 0.4118 0.1608];
      app.S3BDES_UpperLimit.Position = [116 113 100 22];

      % Create LowerLimitEditField_3Label
      app.LowerLimitEditField_3Label = uilabel(app.S3LRPanel);
      app.LowerLimitEditField_3Label.HorizontalAlignment = 'right';
      app.LowerLimitEditField_3Label.Position = [33 27 68 22];
      app.LowerLimitEditField_3Label.Text = 'Lower Limit';

      % Create S3BDES_LowerLimit
      app.S3BDES_LowerLimit = uieditfield(app.S3LRPanel, 'numeric');
      app.S3BDES_LowerLimit.ValueChangedFcn = createCallbackFcn(app, @S3BDES_LowerLimitValueChanged, true);
      app.S3BDES_LowerLimit.BackgroundColor = [1 0.4118 0.1608];
      app.S3BDES_LowerLimit.Position = [116 27 100 22];
      app.S3BDES_LowerLimit.Value = -1200;

      % Create BDESEditField_3Label
      app.BDESEditField_3Label = uilabel(app.S3LRPanel);
      app.BDESEditField_3Label.HorizontalAlignment = 'right';
      app.BDESEditField_3Label.Position = [64 70 38 22];
      app.BDESEditField_3Label.Text = 'BDES';

      % Create S3BDES
      app.S3BDES = uieditfield(app.S3LRPanel, 'numeric');
      app.S3BDES.ValueDisplayFormat = '%.3f';
      app.S3BDES.Interruptible = 'off';
      app.S3BDES.Position = [117 70 100 22];
      app.S3BDES.Value = -1069.699;

      % Create OptimizationAlgorithmButtonGroup
      app.OptimizationAlgorithmButtonGroup = uibuttongroup(app.F2_TuneBC20UIFigure);
      app.OptimizationAlgorithmButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @OptimizationAlgorithmButtonGroupSelectionChanged, true);
      app.OptimizationAlgorithmButtonGroup.Title = 'Optimization Algorithm';
      app.OptimizationAlgorithmButtonGroup.Position = [23 168 379 103];

      % Create fminsearchButton
      app.fminsearchButton = uiradiobutton(app.OptimizationAlgorithmButtonGroup);
      app.fminsearchButton.Text = 'fminsearch';
      app.fminsearchButton.Position = [11 55 82 22];
      app.fminsearchButton.Value = true;

      % Create XoptMOBOButton
      app.XoptMOBOButton = uiradiobutton(app.OptimizationAlgorithmButtonGroup);
      app.XoptMOBOButton.Text = 'Xopt - MOBO';
      app.XoptMOBOButton.Position = [137 51 93 22];

      % Create XoptCNSGAButton
      app.XoptCNSGAButton = uiradiobutton(app.OptimizationAlgorithmButtonGroup);
      app.XoptCNSGAButton.Text = 'Xopt - CNSGA';
      app.XoptCNSGAButton.Position = [137 27 100 22];

      % Create fminconButton
      app.fminconButton = uiradiobutton(app.OptimizationAlgorithmButtonGroup);
      app.fminconButton.Text = 'fmincon';
      app.fminconButton.Position = [11 12 65 22];

      % Create lsqnonlinButton
      app.lsqnonlinButton = uiradiobutton(app.OptimizationAlgorithmButtonGroup);
      app.lsqnonlinButton.Enable = 'off';
      app.lsqnonlinButton.Text = 'lsqnonlin';
      app.lsqnonlinButton.Position = [11 34 72 22];

      % Create ProfileMeasurementButtonGroup
      app.ProfileMeasurementButtonGroup = uibuttongroup(app.F2_TuneBC20UIFigure);
      app.ProfileMeasurementButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ProfileMeasurementButtonGroupSelectionChanged, true);
      app.ProfileMeasurementButtonGroup.Title = 'Profile Measurement';
      app.ProfileMeasurementButtonGroup.Position = [412 168 386 295];

      % Create IPOTR1Button_2
      app.IPOTR1Button_2 = uiradiobutton(app.ProfileMeasurementButtonGroup);
      app.IPOTR1Button_2.Text = 'IPOTR1';
      app.IPOTR1Button_2.Position = [35 141 65 22];
      app.IPOTR1Button_2.Value = true;

      % Create IPOTR1PButton
      app.IPOTR1PButton = uiradiobutton(app.ProfileMeasurementButtonGroup);
      app.IPOTR1PButton.Text = 'IPOTR1P';
      app.IPOTR1PButton.Position = [35 117 73 22];

      % Create IPOTR2Button
      app.IPOTR2Button = uiradiobutton(app.ProfileMeasurementButtonGroup);
      app.IPOTR2Button.Text = 'IPOTR2';
      app.IPOTR2Button.Position = [114 141 65 22];

      % Create SpotSizeumEditFieldLabel
      app.SpotSizeumEditFieldLabel = uilabel(app.ProfileMeasurementButtonGroup);
      app.SpotSizeumEditFieldLabel.HorizontalAlignment = 'right';
      app.SpotSizeumEditFieldLabel.Position = [3 15 85 22];
      app.SpotSizeumEditFieldLabel.Text = 'Spot Size (um)';

      % Create SpotSizeEditField
      app.SpotSizeEditField = uieditfield(app.ProfileMeasurementButtonGroup, 'numeric');
      app.SpotSizeEditField.Editable = 'off';
      app.SpotSizeEditField.Position = [103 15 100 22];

      % Create NBkgEditFieldLabel
      app.NBkgEditFieldLabel = uilabel(app.ProfileMeasurementButtonGroup);
      app.NBkgEditFieldLabel.HorizontalAlignment = 'right';
      app.NBkgEditFieldLabel.Position = [50 48 38 22];
      app.NBkgEditFieldLabel.Text = 'N Bkg';

      % Create NBkgEditField
      app.NBkgEditField = uieditfield(app.ProfileMeasurementButtonGroup, 'numeric');
      app.NBkgEditField.Limits = [0 100];
      app.NBkgEditField.ValueChangedFcn = createCallbackFcn(app, @NBkgEditFieldValueChanged, true);
      app.NBkgEditField.Position = [103 48 100 22];
      app.NBkgEditField.Value = 1;

      % Create PRDMPButton
      app.PRDMPButton = uiradiobutton(app.ProfileMeasurementButtonGroup);
      app.PRDMPButton.Text = 'PRDMP';
      app.PRDMPButton.Position = [115 94 66 22];

      % Create UIAxes_2
      app.UIAxes_2 = uiaxes(app.ProfileMeasurementButtonGroup);
      title(app.UIAxes_2, '')
      xlabel(app.UIAxes_2, '')
      ylabel(app.UIAxes_2, '')
      app.UIAxes_2.XTickLabel = '';
      app.UIAxes_2.YTickLabel = '';
      app.UIAxes_2.Position = [4 175 376 93];

      % Create WDSOTRButton
      app.WDSOTRButton = uiradiobutton(app.ProfileMeasurementButtonGroup);
      app.WDSOTRButton.Text = 'WDSOTR';
      app.WDSOTRButton.Position = [35 94 75 22];

      % Create DSOTRButton
      app.DSOTRButton = uiradiobutton(app.ProfileMeasurementButtonGroup);
      app.DSOTRButton.Text = 'DSOTR';
      app.DSOTRButton.Position = [114 117 64 22];

      % Create UIAxes_3
      app.UIAxes_3 = uiaxes(app.ProfileMeasurementButtonGroup);
      title(app.UIAxes_3, '')
      xlabel(app.UIAxes_3, '')
      ylabel(app.UIAxes_3, '')
      app.UIAxes_3.XTickLabel = '';
      app.UIAxes_3.YTickLabel = '';
      app.UIAxes_3.Position = [208 15 166 148];

      % Create BackgroundMeasurementButtonGroup
      app.BackgroundMeasurementButtonGroup = uibuttongroup(app.F2_TuneBC20UIFigure);
      app.BackgroundMeasurementButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @BackgroundMeasurementButtonGroupSelectionChanged, true);
      app.BackgroundMeasurementButtonGroup.Title = 'Background Measurement';
      app.BackgroundMeasurementButtonGroup.Position = [22 277 380 186];

      % Create PMT3179Button
      app.PMT3179Button = uiradiobutton(app.BackgroundMeasurementButtonGroup);
      app.PMT3179Button.Text = 'PMT3179';
      app.PMT3179Button.Position = [104 6 75 22];
      app.PMT3179Button.Value = true;

      % Create PMT3350Button
      app.PMT3350Button = uiradiobutton(app.BackgroundMeasurementButtonGroup);
      app.PMT3350Button.Text = 'PMT3350';
      app.PMT3350Button.Position = [195 6 75 22];

      % Create PMT3360Button
      app.PMT3360Button = uiradiobutton(app.BackgroundMeasurementButtonGroup);
      app.PMT3360Button.Text = 'PMT3360';
      app.PMT3360Button.Position = [286 6 75 22];

      % Create BkgEditField
      app.BkgEditField = uieditfield(app.BackgroundMeasurementButtonGroup, 'numeric');
      app.BkgEditField.Editable = 'off';
      app.BkgEditField.Position = [118 36 142 22];

      % Create UIAxes
      app.UIAxes = uiaxes(app.BackgroundMeasurementButtonGroup);
      title(app.UIAxes, '')
      xlabel(app.UIAxes, '')
      ylabel(app.UIAxes, '')
      app.UIAxes.XTickLabel = '';
      app.UIAxes.YTickLabel = '';
      app.UIAxes.Position = [7 67 361 93];

      % Create PMT3070Button
      app.PMT3070Button = uiradiobutton(app.BackgroundMeasurementButtonGroup);
      app.PMT3070Button.Text = 'PMT3070';
      app.PMT3070Button.Position = [13 7 75 22];

      % Create RunControlsPanel
      app.RunControlsPanel = uipanel(app.F2_TuneBC20UIFigure);
      app.RunControlsPanel.Title = 'Run Controls';
      app.RunControlsPanel.Position = [23 22 775 135];

      % Create RunButton
      app.RunButton = uibutton(app.RunControlsPanel, 'push');
      app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushed, true);
      app.RunButton.BackgroundColor = [0.4667 0.6745 0.1882];
      app.RunButton.FontWeight = 'bold';
      app.RunButton.Position = [15 64 110 35];
      app.RunButton.Text = 'Run';

      % Create STOPButton
      app.STOPButton = uibutton(app.RunControlsPanel, 'push');
      app.STOPButton.ButtonPushedFcn = createCallbackFcn(app, @STOPButtonPushed, true);
      app.STOPButton.Interruptible = 'off';
      app.STOPButton.BackgroundColor = [0.851 0.3255 0.098];
      app.STOPButton.FontWeight = 'bold';
      app.STOPButton.Position = [15 18 110 35];
      app.STOPButton.Text = 'STOP';

      % Create StatusLabel
      app.StatusLabel = uilabel(app.RunControlsPanel);
      app.StatusLabel.HorizontalAlignment = 'right';
      app.StatusLabel.Position = [156 79 42 22];
      app.StatusLabel.Text = 'Status:';

      % Create StatusText
      app.StatusText = uitextarea(app.RunControlsPanel);
      app.StatusText.Position = [213 43 549 60];
      app.StatusText.Value = {'Not running.'};

      % Create ResetBDESButton
      app.ResetBDESButton = uibutton(app.RunControlsPanel, 'push');
      app.ResetBDESButton.ButtonPushedFcn = createCallbackFcn(app, @ResetBDESButtonPushed, true);
      app.ResetBDESButton.BackgroundColor = [0.9294 0.6941 0.1255];
      app.ResetBDESButton.FontWeight = 'bold';
      app.ResetBDESButton.Enable = 'off';
      app.ResetBDESButton.Position = [213 10 119 23];
      app.ResetBDESButton.Text = 'Reset Initial BDES';

      % Create SetOptimizedBDESButton
      app.SetOptimizedBDESButton = uibutton(app.RunControlsPanel, 'push');
      app.SetOptimizedBDESButton.ButtonPushedFcn = createCallbackFcn(app, @SetOptimizedBDESButtonPushed, true);
      app.SetOptimizedBDESButton.BackgroundColor = [0.302 0.7451 0.9333];
      app.SetOptimizedBDESButton.FontWeight = 'bold';
      app.SetOptimizedBDESButton.Enable = 'off';
      app.SetOptimizedBDESButton.Position = [362 10 131 23];
      app.SetOptimizedBDESButton.Text = 'Set Optimized BDES';

      % Show the figure after all components are created
      app.F2_TuneBC20UIFigure.Visible = 'on';
    end
  end

  % App creation and deletion
  methods (Access = public)

    % Construct app
    function app = F2_TuneBC20_exported

      % Create UIFigure and components
      createComponents(app)

      % Register the app with App Designer
      registerApp(app, app.F2_TuneBC20UIFigure)

      % Execute the startup function
      runStartupFcn(app, @startupFcn)

      if nargout == 0
        clear app
      end
    end

    % Code that executes before app deletion
    function delete(app)

      % Delete UIFigure when app is deleted
      delete(app.F2_TuneBC20UIFigure)
    end
  end
end