classdef F2_S20Config_exported < matlab.apps.AppBase

  % Properties that correspond to app components
  properties (Access = public)
    FACETIISector20ConfiguratorUIFigure  matlab.ui.Figure
    PlotMenu                        matlab.ui.container.Menu
    ShowlegendMenu                  matlab.ui.container.Menu
    DetachPlotMenu                  matlab.ui.container.Menu
    HelpMenu                        matlab.ui.container.Menu
    ThereisnohelpforyouMenu         matlab.ui.container.Menu
    IPPrimaryWaistLocationPanel     matlab.ui.container.Panel
    ListBox                         matlab.ui.control.ListBox
    InitialParametersBEGFF20Panel   matlab.ui.container.Panel
    BeamEnergyGeVPanel              matlab.ui.container.Panel
    E0                              matlab.ui.control.NumericEditField
    dEEPanel                        matlab.ui.container.Panel
    dE                              matlab.ui.control.NumericEditField
    DispersionmmmradDxDxDyDyPanel   matlab.ui.container.Panel
    Dx                              matlab.ui.control.NumericEditField
    Dxp                             matlab.ui.control.NumericEditField
    Dy                              matlab.ui.control.NumericEditField
    Dyp                             matlab.ui.control.NumericEditField
    NEmit_xNEmit_yBeta_XmBeta_YmAlpha_XAlpha_yPanel  matlab.ui.container.Panel
    betax                           matlab.ui.control.NumericEditField
    betay                           matlab.ui.control.NumericEditField
    alphax                          matlab.ui.control.NumericEditField
    alphay                          matlab.ui.control.NumericEditField
    emitx                           matlab.ui.control.NumericEditField
    emity                           matlab.ui.control.NumericEditField
    InitialParameterSourceDataButtonGroup  matlab.ui.container.ButtonGroup
    DesignButton                    matlab.ui.control.RadioButton
    L3Button                        matlab.ui.control.RadioButton
    IPButton                        matlab.ui.control.RadioButton
    UserButton                      matlab.ui.control.RadioButton
    DropDown                        matlab.ui.control.DropDown
    MatchingPanel                   matlab.ui.container.Panel
    BetaFunctionsatIPLocationPanel  matlab.ui.container.Panel
    GridLayout2                     matlab.ui.container.GridLayout
    unitscmLabel                    matlab.ui.control.Label
    BETA_YLabel                     matlab.ui.control.Label
    DesiredLabel                    matlab.ui.control.Label
    CurrentLabel                    matlab.ui.control.Label
    MatchLabel                      matlab.ui.control.Label
    BetaX_DES                       matlab.ui.control.NumericEditField
    BetaY_DES                       matlab.ui.control.NumericEditField
    BetaX_CUR                       matlab.ui.control.NumericEditField
    BetaY_CUR                       matlab.ui.control.NumericEditField
    BetaX_MATCH                     matlab.ui.control.NumericEditField
    BetaY_MATCH                     matlab.ui.control.NumericEditField
    BETA_XLabel                     matlab.ui.control.Label
    DownstreamIPMatchConditionsPanel  matlab.ui.container.Panel
    DropDown_2                      matlab.ui.control.DropDown
    DropDown_3                      matlab.ui.control.DropDown
    PrimaryIPWaistShiftcmPanel      matlab.ui.container.Panel
    WaistX_dzACT                    matlab.ui.control.NumericEditField
    WaistX_dzDES                    matlab.ui.control.NumericEditField
    WaistY_dzACT                    matlab.ui.control.NumericEditField
    WaistY_dzDES                    matlab.ui.control.NumericEditField
    ACTLabel                        matlab.ui.control.Label
    DESLabel                        matlab.ui.control.Label
    XLabel                          matlab.ui.control.Label
    YLabel                          matlab.ui.control.Label
    DoMatchButton                   matlab.ui.control.Button
    WaistDESButton                  matlab.ui.control.Button
    TRIMQUADSButton                 matlab.ui.control.Button
    IntegratedQuadrupoleStrengthsBDESkGPanel  matlab.ui.container.Panel
    GridLayout4                     matlab.ui.container.GridLayout
    Q5FFLabel                       matlab.ui.control.Label
    Q4FFLabel                       matlab.ui.control.Label
    Q3FFLabel                       matlab.ui.control.Label
    Q2FFLabel                       matlab.ui.control.Label
    Q1FFLabel                       matlab.ui.control.Label
    Q0FFLabel                       matlab.ui.control.Label
    Q0DLabel                        matlab.ui.control.Label
    Q1DLabel                        matlab.ui.control.Label
    Q2DLabel                        matlab.ui.control.Label
    BDESLabel                       matlab.ui.control.Label
    MatchLabel_2                    matlab.ui.control.Label
    BDES_Q5FF                       matlab.ui.control.NumericEditField
    BDES_Q4FF                       matlab.ui.control.NumericEditField
    BDES_Q3FF                       matlab.ui.control.NumericEditField
    BDES_Q2FF                       matlab.ui.control.NumericEditField
    BDES_Q1FF                       matlab.ui.control.NumericEditField
    BDES_Q0FF                       matlab.ui.control.NumericEditField
    BDES_Q0D                        matlab.ui.control.NumericEditField
    BDES_Q1D                        matlab.ui.control.NumericEditField
    BDES_Q2D                        matlab.ui.control.NumericEditField
    BMATCH_Q5FF                     matlab.ui.control.NumericEditField
    BMATCH_Q4FF                     matlab.ui.control.NumericEditField
    BMATCH_Q3FF                     matlab.ui.control.NumericEditField
    BMATCH_Q2FF                     matlab.ui.control.NumericEditField
    BMATCH_Q1FF                     matlab.ui.control.NumericEditField
    BMATCH_Q0FF                     matlab.ui.control.NumericEditField
    BMATCH_Q0D                      matlab.ui.control.NumericEditField
    BMATCH_Q1D                      matlab.ui.control.NumericEditField
    BMATCH_Q2D                      matlab.ui.control.NumericEditField
    ShowTableButton                 matlab.ui.control.Button
    UpdateButton                    matlab.ui.control.Button
    TCAVConfigButton                matlab.ui.control.Button
    TwissParameterPlotPanel         matlab.ui.container.Panel
    UIAxes                          matlab.ui.control.UIAxes
    UIAxes2                         matlab.ui.control.UIAxes
  end

  
  properties (Access = public)
    aobj % F2_S20ConfigApp object
  end
  
  properties (Access = private)
    XYSelect logical = false % true when first X/Y pair selected (either desired beta or waist offset)
    trim1 logical = true
  end
  

  % Callbacks that handle component events
  methods (Access = private)

    % Code that executes after component creation
    function startupFcn(app)
      app.aobj = F2_S20ConfigApp(app) ;
    end

    % Value changed function: ListBox
    function ListBoxValueChanged(app, event)
      value = app.ListBox.Value;
      % Strip waist location info from name
      value = regexprep(value,'\s+','') ;
      value = regexprep(value,'<--W_x&y','') ;
      value = regexprep(value,'<--W_x','') ;
      value = regexprep(value,'<--W_y','') ;
      % Set desired IP location
      app.aobj.WaistDesName = value ;
    end

    % Value changed function: Dx, Dxp, Dy, Dyp, alphax, alphay, 
    % betax, betay, emitx, emity
    function emitxValueChanged(app, event)
      app.UserButton.Value = true;
      parvals = [app.betax.Value app.betay.Value app.alphax.Value app.alphay.Value app.emitx.Value app.emity.Value app.Dx.Value app.Dxp.Value app.Dy.Value app.Dyp.Value] ;
      app.aobj.UserParams = parvals ;
      app.aobj.InitialOption="User"; % Causes all GUI fields to update if editing non-User parameters
      caput(app.aobj.pvs.UserBetax,parvals(1));
      caput(app.aobj.pvs.UserBetay,parvals(2));
      caput(app.aobj.pvs.UserAlphax,parvals(3));
      caput(app.aobj.pvs.UserAlphay,parvals(4));
      caput(app.aobj.pvs.UserNEmitx,parvals(5));
      caput(app.aobj.pvs.UserNEmity,parvals(6));
      caput(app.aobj.pvs.UserDispx,parvals(7));
      caput(app.aobj.pvs.UserDispxp,parvals(8));
      caput(app.aobj.pvs.UserDispx,parvals(9));
      caput(app.aobj.pvs.UserDispxp,parvals(10));
    end

    % Selection changed function: 
    % InitialParameterSourceDataButtonGroup
    function InitialParameterSourceDataButtonGroupSelectionChanged(app, event)
      selectedButton = app.InitialParameterSourceDataButtonGroup.SelectedObject;
      switch selectedButton
        case app.DesignButton
          app.aobj.InitialOption="Design";
        case app.L3Button
          app.aobj.InitialOption="L3";
        case app.UserButton
          app.aobj.InitialOption="User";
        case app.IPButton
          app.aobj.InitialOption="IP";
      end
    end

    % Value changed function: DropDown
    function DropDownValueChanged(app, event)
      value = app.DropDown.Value;
      app.aobj.InitialIPOption = value ;
    end

    % Value changed function: E0
    function E0ValueChanged(app, event)
      value = app.E0.Value;
      app.aobj.E_override = true ;
      app.aobj.E0=value;
    end

    % Value changed function: dE
    function dEValueChanged(app, event)
      value = app.dE.Value;
      app.aobj.dE=value;
    end

    % Value changed function: BetaX_DES
    function BetaX_DESValueChanged(app, event)
      value = app.BetaX_DES.Value;
      if ~app.XYSelect
        app.BetaY_DES.Value = value ;
        app.XYSelect = true ;
      else
        app.XYSelect = false ;
      end
      app.aobj.BetaDES = [app.BetaX_DES.Value app.BetaY_DES.Value].*1e-2 ;
    end

    % Value changed function: BetaY_DES
    function BetaY_DESValueChanged(app, event)
      value = app.BetaY_DES.Value;
      if ~app.XYSelect
        app.BetaX_DES.Value = value ;
        app.XYSelect = true ;
      else
        app.XYSelect = false ;
      end
      app.aobj.BetaDES = [app.BetaX_DES.Value app.BetaY_DES.Value].*1e-2 ;
    end

    % Value changed function: DropDown_2
    function DropDown_2ValueChanged(app, event)
      value = app.DropDown_2.Value;
      app.aobj.WaistDesNameDS = value ;
    end

    % Value changed function: DropDown_3
    function DropDown_3ValueChanged(app, event)
      value = app.DropDown_3.Value;
      switch string(value)
        case "SFQED"
          app.aobj.isSFQED=true; app.aobj.isKracken=false;
        case "Kracken"
          app.aobj.isSFQED=false; app.aobj.isKracken=true;
        otherwise
          app.aobj.isSFQED=false; app.aobj.isKracken=false;
      end
    end

    % Button pushed function: DoMatchButton
    function DoMatchButtonPushed(app, event)
      app.XYSelect=false;
      app.DoMatchButton.Enable=false; drawnow;
      try
        app.aobj.MatchFFS;
      catch ME
        errordlg('Error when running matching routine- see console output','Match Error');
        app.DoMatchButton.Enable=true;
        throw(ME);
      end
      app.DoMatchButton.Enable=true;
    end

    % Button pushed function: WaistDESButton
    function WaistDESButtonPushed(app, event)
      app.XYSelect=false;
      app.WaistDESButton.Enable=false; drawnow;
      try
        app.aobj.MatchWaist;
      catch ME
        errordlg('Error whilst matching new waist location- see console output window','Waist Match Error');
        app.WaistDESButton.Enable=true;
        throw(ME);
      end
      app.WaistDESButton.Enable=true;
    end

    % Button pushed function: ShowTableButton
    function ShowTableButtonPushed(app, event)
      app.aobj.Table;
    end

    % Value changed function: WaistX_dzDES
    function WaistX_dzDESValueChanged(app, event)
      value = app.WaistX_dzDES.Value;
      if ~app.XYSelect
        app.WaistY_dzACT.Value = value ;
        app.XYSelect=false;
      else
        app.XYSelect=true;
      end
      app.aobj.WaistShiftDES=[app.WaistX_dzDES.Value app.WaistY_dzDES.Value];
    end

    % Value changed function: WaistY_dzDES
    function WaistY_dzDESValueChanged(app, event)
      value = app.WaistY_dzDES.Value;
      if ~app.XYSelect
        app.WaistX_dzACT.Value = value ;
        app.XYSelect=false;
      else
        app.XYSelect=true;
      end
      app.aobj.WaistShiftDES=[app.WaistX_dzDES.Value app.WaistY_dzDES.Value];
    end

    % Button pushed function: TRIMQUADSButton
    function TRIMQUADSButtonPushed(app, event)
      app.TRIMQUADSButton.Enable=false; drawnow;
      app.aobj.TrimQuads();
      if app.trim1
        app.aobj.TrimQuads();
        app.trim1=false;
      end
      app.aobj.PlotToLog;
      app.TRIMQUADSButton.Enable=true; drawnow;
    end

    % Button pushed function: UpdateButton
    function UpdateButtonPushed(app, event)
      
      app.aobj.PVwatchdog;
    end

    % Menu selected function: ShowlegendMenu
    function ShowlegendMenuSelected(app, event)
      if app.ShowlegendMenu.Checked
        legend(app.UIAxes2,'off');
        app.ShowlegendMenu.Checked=false;
        app.aobj.showlegend=false;
      else
        legend(app.UIAxes2,'on');
        app.ShowlegendMenu.Checked=true;
        app.aobj.showlegend=true;
      end
    end

    % Menu selected function: DetachPlotMenu
    function DetachPlotMenuSelected(app, event)
      fh=figure;
      app.aobj.Plot(fh);
    end

    % Button pushed function: TCAVConfigButton
    function TCAVConfigButtonPushed(app, event)
      app.ListBox.Value = "DSOTR" ;
      app.DropDown_2.Value = "DTOTR" ;
      app.BetaX_DES.Value = 6 ;
      app.BetaY_DES.Value = 6 ;
      app.ListBoxValueChanged;
      app.DropDown_2ValueChanged;
      app.BetaX_DESValueChanged;
      app.BetaY_DESValueChanged;
    end
  end

  % Component initialization
  methods (Access = private)

    % Create UIFigure and components
    function createComponents(app)

      % Create FACETIISector20ConfiguratorUIFigure and hide until all components are created
      app.FACETIISector20ConfiguratorUIFigure = uifigure('Visible', 'off');
      app.FACETIISector20ConfiguratorUIFigure.Position = [100 100 836 900];
      app.FACETIISector20ConfiguratorUIFigure.Name = 'FACET-II Sector 20 Configurator';
      app.FACETIISector20ConfiguratorUIFigure.Resize = 'off';

      % Create PlotMenu
      app.PlotMenu = uimenu(app.FACETIISector20ConfiguratorUIFigure);
      app.PlotMenu.Text = 'Plot';

      % Create ShowlegendMenu
      app.ShowlegendMenu = uimenu(app.PlotMenu);
      app.ShowlegendMenu.MenuSelectedFcn = createCallbackFcn(app, @ShowlegendMenuSelected, true);
      app.ShowlegendMenu.Checked = 'on';
      app.ShowlegendMenu.Text = 'Show legend';

      % Create DetachPlotMenu
      app.DetachPlotMenu = uimenu(app.PlotMenu);
      app.DetachPlotMenu.MenuSelectedFcn = createCallbackFcn(app, @DetachPlotMenuSelected, true);
      app.DetachPlotMenu.Text = 'Detach Plot';

      % Create HelpMenu
      app.HelpMenu = uimenu(app.FACETIISector20ConfiguratorUIFigure);
      app.HelpMenu.Text = 'Help';

      % Create ThereisnohelpforyouMenu
      app.ThereisnohelpforyouMenu = uimenu(app.HelpMenu);
      app.ThereisnohelpforyouMenu.Text = 'There is no help for you...';

      % Create IPPrimaryWaistLocationPanel
      app.IPPrimaryWaistLocationPanel = uipanel(app.FACETIISector20ConfiguratorUIFigure);
      app.IPPrimaryWaistLocationPanel.Title = 'IP Primary Waist Location';
      app.IPPrimaryWaistLocationPanel.FontWeight = 'bold';
      app.IPPrimaryWaistLocationPanel.Position = [9 9 159 882];

      % Create ListBox
      app.ListBox = uilistbox(app.IPPrimaryWaistLocationPanel);
      app.ListBox.ValueChangedFcn = createCallbackFcn(app, @ListBoxValueChanged, true);
      app.ListBox.Position = [8 9 141 846];

      % Create InitialParametersBEGFF20Panel
      app.InitialParametersBEGFF20Panel = uipanel(app.FACETIISector20ConfiguratorUIFigure);
      app.InitialParametersBEGFF20Panel.Title = 'Initial Parameters @ BEGFF20';
      app.InitialParametersBEGFF20Panel.FontWeight = 'bold';
      app.InitialParametersBEGFF20Panel.Position = [175 742 653 149];

      % Create BeamEnergyGeVPanel
      app.BeamEnergyGeVPanel = uipanel(app.InitialParametersBEGFF20Panel);
      app.BeamEnergyGeVPanel.Title = 'Beam Energy [GeV]';
      app.BeamEnergyGeVPanel.Position = [11 8 130 53];

      % Create E0
      app.E0 = uieditfield(app.BeamEnergyGeVPanel, 'numeric');
      app.E0.ValueDisplayFormat = '%.3f';
      app.E0.ValueChangedFcn = createCallbackFcn(app, @E0ValueChanged, true);
      app.E0.HorizontalAlignment = 'center';
      app.E0.Position = [9 6 108 22];
      app.E0.Value = 10;

      % Create dEEPanel
      app.dEEPanel = uipanel(app.InitialParametersBEGFF20Panel);
      app.dEEPanel.Title = 'dE/E [%]';
      app.dEEPanel.Position = [150 8 100 53];

      % Create dE
      app.dE = uieditfield(app.dEEPanel, 'numeric');
      app.dE.ValueDisplayFormat = '%.3f';
      app.dE.ValueChangedFcn = createCallbackFcn(app, @dEValueChanged, true);
      app.dE.HorizontalAlignment = 'center';
      app.dE.Position = [9 6 78 22];
      app.dE.Value = 1.2;

      % Create DispersionmmmradDxDxDyDyPanel
      app.DispersionmmmradDxDxDyDyPanel = uipanel(app.InitialParametersBEGFF20Panel);
      app.DispersionmmmradDxDxDyDyPanel.Title = 'Dispersion [mm/mrad] (Dx,D''x,Dy,D''y)';
      app.DispersionmmmradDxDxDyDyPanel.Position = [398 69 239 53];

      % Create Dx
      app.Dx = uieditfield(app.DispersionmmmradDxDxDyDyPanel, 'numeric');
      app.Dx.ValueDisplayFormat = '%.3f';
      app.Dx.ValueChangedFcn = createCallbackFcn(app, @emitxValueChanged, true);
      app.Dx.HorizontalAlignment = 'center';
      app.Dx.Position = [8 6 48 22];

      % Create Dxp
      app.Dxp = uieditfield(app.DispersionmmmradDxDxDyDyPanel, 'numeric');
      app.Dxp.ValueDisplayFormat = '%.3f';
      app.Dxp.ValueChangedFcn = createCallbackFcn(app, @emitxValueChanged, true);
      app.Dxp.HorizontalAlignment = 'center';
      app.Dxp.Position = [64 6 48 22];

      % Create Dy
      app.Dy = uieditfield(app.DispersionmmmradDxDxDyDyPanel, 'numeric');
      app.Dy.ValueDisplayFormat = '%.3f';
      app.Dy.ValueChangedFcn = createCallbackFcn(app, @emitxValueChanged, true);
      app.Dy.HorizontalAlignment = 'center';
      app.Dy.Position = [120 6 48 22];

      % Create Dyp
      app.Dyp = uieditfield(app.DispersionmmmradDxDxDyDyPanel, 'numeric');
      app.Dyp.ValueDisplayFormat = '%.3f';
      app.Dyp.ValueChangedFcn = createCallbackFcn(app, @emitxValueChanged, true);
      app.Dyp.HorizontalAlignment = 'center';
      app.Dyp.Position = [175 6 48 22];

      % Create NEmit_xNEmit_yBeta_XmBeta_YmAlpha_XAlpha_yPanel
      app.NEmit_xNEmit_yBeta_XmBeta_YmAlpha_XAlpha_yPanel = uipanel(app.InitialParametersBEGFF20Panel);
      app.NEmit_xNEmit_yBeta_XmBeta_YmAlpha_XAlpha_yPanel.Title = 'NEmit_x, NEmit_y, Beta_X [m], Beta_Y [m], Alpha_X, Alpha_y';
      app.NEmit_xNEmit_yBeta_XmBeta_YmAlpha_XAlpha_yPanel.Position = [11 69 379 53];

      % Create betax
      app.betax = uieditfield(app.NEmit_xNEmit_yBeta_XmBeta_YmAlpha_XAlpha_yPanel, 'numeric');
      app.betax.ValueDisplayFormat = '%.3f';
      app.betax.ValueChangedFcn = createCallbackFcn(app, @emitxValueChanged, true);
      app.betax.HorizontalAlignment = 'center';
      app.betax.Position = [136 5 48 22];
      app.betax.Value = 1;

      % Create betay
      app.betay = uieditfield(app.NEmit_xNEmit_yBeta_XmBeta_YmAlpha_XAlpha_yPanel, 'numeric');
      app.betay.ValueDisplayFormat = '%.3f';
      app.betay.ValueChangedFcn = createCallbackFcn(app, @emitxValueChanged, true);
      app.betay.HorizontalAlignment = 'center';
      app.betay.Position = [196 5 48 22];
      app.betay.Value = 1;

      % Create alphax
      app.alphax = uieditfield(app.NEmit_xNEmit_yBeta_XmBeta_YmAlpha_XAlpha_yPanel, 'numeric');
      app.alphax.ValueDisplayFormat = '%.3f';
      app.alphax.ValueChangedFcn = createCallbackFcn(app, @emitxValueChanged, true);
      app.alphax.HorizontalAlignment = 'center';
      app.alphax.Position = [256 5 48 22];

      % Create alphay
      app.alphay = uieditfield(app.NEmit_xNEmit_yBeta_XmBeta_YmAlpha_XAlpha_yPanel, 'numeric');
      app.alphay.ValueDisplayFormat = '%.3f';
      app.alphay.ValueChangedFcn = createCallbackFcn(app, @emitxValueChanged, true);
      app.alphay.HorizontalAlignment = 'center';
      app.alphay.Position = [316 5 48 22];

      % Create emitx
      app.emitx = uieditfield(app.NEmit_xNEmit_yBeta_XmBeta_YmAlpha_XAlpha_yPanel, 'numeric');
      app.emitx.ValueDisplayFormat = '%.3f';
      app.emitx.ValueChangedFcn = createCallbackFcn(app, @emitxValueChanged, true);
      app.emitx.HorizontalAlignment = 'center';
      app.emitx.Position = [14 5 48 22];
      app.emitx.Value = 5;

      % Create emity
      app.emity = uieditfield(app.NEmit_xNEmit_yBeta_XmBeta_YmAlpha_XAlpha_yPanel, 'numeric');
      app.emity.ValueDisplayFormat = '%.3f';
      app.emity.ValueChangedFcn = createCallbackFcn(app, @emitxValueChanged, true);
      app.emity.HorizontalAlignment = 'center';
      app.emity.Position = [75 5 48 22];
      app.emity.Value = 5;

      % Create InitialParameterSourceDataButtonGroup
      app.InitialParameterSourceDataButtonGroup = uibuttongroup(app.InitialParametersBEGFF20Panel);
      app.InitialParameterSourceDataButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @InitialParameterSourceDataButtonGroupSelectionChanged, true);
      app.InitialParameterSourceDataButtonGroup.Title = 'Initial Parameter Source Data';
      app.InitialParameterSourceDataButtonGroup.Position = [259 7 378 54];

      % Create DesignButton
      app.DesignButton = uiradiobutton(app.InitialParameterSourceDataButtonGroup);
      app.DesignButton.Text = 'Design';
      app.DesignButton.Position = [11 7 61 22];
      app.DesignButton.Value = true;

      % Create L3Button
      app.L3Button = uiradiobutton(app.InitialParameterSourceDataButtonGroup);
      app.L3Button.Enable = 'off';
      app.L3Button.Text = 'L3';
      app.L3Button.Position = [78 7 36 22];

      % Create IPButton
      app.IPButton = uiradiobutton(app.InitialParameterSourceDataButtonGroup);
      app.IPButton.Enable = 'off';
      app.IPButton.Text = 'IP:';
      app.IPButton.Position = [129 7 36 22];

      % Create UserButton
      app.UserButton = uiradiobutton(app.InitialParameterSourceDataButtonGroup);
      app.UserButton.Text = 'User';
      app.UserButton.Position = [305 6 48 22];

      % Create DropDown
      app.DropDown = uidropdown(app.InitialParameterSourceDataButtonGroup);
      app.DropDown.Items = {'USTHz', 'USOTR', 'IPOTR1', 'IPOTR1P', 'IPOTR2', 'DSOTR', 'WDSOTR', 'PRDMP'};
      app.DropDown.ValueChangedFcn = createCallbackFcn(app, @DropDownValueChanged, true);
      app.DropDown.Enable = 'off';
      app.DropDown.Position = [175 7 112 22];
      app.DropDown.Value = 'IPOTR1';

      % Create MatchingPanel
      app.MatchingPanel = uipanel(app.FACETIISector20ConfiguratorUIFigure);
      app.MatchingPanel.Title = 'Matching';
      app.MatchingPanel.FontWeight = 'bold';
      app.MatchingPanel.Position = [175 378 653 356];

      % Create BetaFunctionsatIPLocationPanel
      app.BetaFunctionsatIPLocationPanel = uipanel(app.MatchingPanel);
      app.BetaFunctionsatIPLocationPanel.Title = 'Beta Functions at IP Location';
      app.BetaFunctionsatIPLocationPanel.Position = [10 145 280 180];

      % Create GridLayout2
      app.GridLayout2 = uigridlayout(app.BetaFunctionsatIPLocationPanel);
      app.GridLayout2.ColumnWidth = {'1x', '1x', '1x'};
      app.GridLayout2.RowHeight = {'1x', '1x', '1x', '1x'};

      % Create unitscmLabel
      app.unitscmLabel = uilabel(app.GridLayout2);
      app.unitscmLabel.HorizontalAlignment = 'center';
      app.unitscmLabel.Layout.Row = 1;
      app.unitscmLabel.Layout.Column = 1;
      app.unitscmLabel.Text = '[units=cm]';

      % Create BETA_YLabel
      app.BETA_YLabel = uilabel(app.GridLayout2);
      app.BETA_YLabel.HorizontalAlignment = 'center';
      app.BETA_YLabel.FontWeight = 'bold';
      app.BETA_YLabel.Layout.Row = 1;
      app.BETA_YLabel.Layout.Column = 3;
      app.BETA_YLabel.Text = 'BETA_Y';

      % Create DesiredLabel
      app.DesiredLabel = uilabel(app.GridLayout2);
      app.DesiredLabel.HorizontalAlignment = 'center';
      app.DesiredLabel.FontWeight = 'bold';
      app.DesiredLabel.Layout.Row = 2;
      app.DesiredLabel.Layout.Column = 1;
      app.DesiredLabel.Text = 'Desired:';

      % Create CurrentLabel
      app.CurrentLabel = uilabel(app.GridLayout2);
      app.CurrentLabel.HorizontalAlignment = 'center';
      app.CurrentLabel.FontWeight = 'bold';
      app.CurrentLabel.Layout.Row = 3;
      app.CurrentLabel.Layout.Column = 1;
      app.CurrentLabel.Text = 'Current:';

      % Create MatchLabel
      app.MatchLabel = uilabel(app.GridLayout2);
      app.MatchLabel.HorizontalAlignment = 'center';
      app.MatchLabel.FontWeight = 'bold';
      app.MatchLabel.Layout.Row = 4;
      app.MatchLabel.Layout.Column = 1;
      app.MatchLabel.Text = 'Match:';

      % Create BetaX_DES
      app.BetaX_DES = uieditfield(app.GridLayout2, 'numeric');
      app.BetaX_DES.Limits = [2 20000];
      app.BetaX_DES.ValueDisplayFormat = '%.2f';
      app.BetaX_DES.ValueChangedFcn = createCallbackFcn(app, @BetaX_DESValueChanged, true);
      app.BetaX_DES.Interruptible = 'off';
      app.BetaX_DES.HorizontalAlignment = 'center';
      app.BetaX_DES.Layout.Row = 2;
      app.BetaX_DES.Layout.Column = 2;
      app.BetaX_DES.Value = 50;

      % Create BetaY_DES
      app.BetaY_DES = uieditfield(app.GridLayout2, 'numeric');
      app.BetaY_DES.Limits = [2 20000];
      app.BetaY_DES.ValueDisplayFormat = '%.2f';
      app.BetaY_DES.ValueChangedFcn = createCallbackFcn(app, @BetaY_DESValueChanged, true);
      app.BetaY_DES.Interruptible = 'off';
      app.BetaY_DES.HorizontalAlignment = 'center';
      app.BetaY_DES.Layout.Row = 2;
      app.BetaY_DES.Layout.Column = 3;
      app.BetaY_DES.Value = 50;

      % Create BetaX_CUR
      app.BetaX_CUR = uieditfield(app.GridLayout2, 'numeric');
      app.BetaX_CUR.ValueDisplayFormat = '%.2f';
      app.BetaX_CUR.Editable = 'off';
      app.BetaX_CUR.HorizontalAlignment = 'center';
      app.BetaX_CUR.FontColor = [1 0 0];
      app.BetaX_CUR.Layout.Row = 3;
      app.BetaX_CUR.Layout.Column = 2;

      % Create BetaY_CUR
      app.BetaY_CUR = uieditfield(app.GridLayout2, 'numeric');
      app.BetaY_CUR.ValueDisplayFormat = '%.2f';
      app.BetaY_CUR.Editable = 'off';
      app.BetaY_CUR.HorizontalAlignment = 'center';
      app.BetaY_CUR.FontColor = [1 0 0];
      app.BetaY_CUR.Layout.Row = 3;
      app.BetaY_CUR.Layout.Column = 3;

      % Create BetaX_MATCH
      app.BetaX_MATCH = uieditfield(app.GridLayout2, 'numeric');
      app.BetaX_MATCH.ValueDisplayFormat = '%.2f';
      app.BetaX_MATCH.Editable = 'off';
      app.BetaX_MATCH.HorizontalAlignment = 'center';
      app.BetaX_MATCH.FontColor = [1 0 0];
      app.BetaX_MATCH.Layout.Row = 4;
      app.BetaX_MATCH.Layout.Column = 2;

      % Create BetaY_MATCH
      app.BetaY_MATCH = uieditfield(app.GridLayout2, 'numeric');
      app.BetaY_MATCH.ValueDisplayFormat = '%.2f';
      app.BetaY_MATCH.Editable = 'off';
      app.BetaY_MATCH.HorizontalAlignment = 'center';
      app.BetaY_MATCH.FontColor = [1 0 0];
      app.BetaY_MATCH.Layout.Row = 4;
      app.BetaY_MATCH.Layout.Column = 3;

      % Create BETA_XLabel
      app.BETA_XLabel = uilabel(app.GridLayout2);
      app.BETA_XLabel.HorizontalAlignment = 'center';
      app.BETA_XLabel.FontWeight = 'bold';
      app.BETA_XLabel.Layout.Row = 1;
      app.BETA_XLabel.Layout.Column = 2;
      app.BETA_XLabel.Text = 'BETA_X';

      % Create DownstreamIPMatchConditionsPanel
      app.DownstreamIPMatchConditionsPanel = uipanel(app.MatchingPanel);
      app.DownstreamIPMatchConditionsPanel.Title = 'Downstream IP Match Conditions';
      app.DownstreamIPMatchConditionsPanel.Position = [299 247 203 78];

      % Create DropDown_2
      app.DropDown_2 = uidropdown(app.DownstreamIPMatchConditionsPanel);
      app.DropDown_2.Items = {'WDSOTR', 'DTOTR', 'PGAM1', 'CNEAR', 'PDUMP'};
      app.DropDown_2.ValueChangedFcn = createCallbackFcn(app, @DropDown_2ValueChanged, true);
      app.DropDown_2.Position = [6 30 179 22];
      app.DropDown_2.Value = 'PDUMP';

      % Create DropDown_3
      app.DropDown_3 = uidropdown(app.DownstreamIPMatchConditionsPanel);
      app.DropDown_3.Items = {'Re-Image IP', 'SFQED', 'Kracken'};
      app.DropDown_3.ValueChangedFcn = createCallbackFcn(app, @DropDown_3ValueChanged, true);
      app.DropDown_3.Position = [7 4 179 22];
      app.DropDown_3.Value = 'Re-Image IP';

      % Create PrimaryIPWaistShiftcmPanel
      app.PrimaryIPWaistShiftcmPanel = uipanel(app.MatchingPanel);
      app.PrimaryIPWaistShiftcmPanel.Title = 'Primary IP Waist Shift [cm]';
      app.PrimaryIPWaistShiftcmPanel.Position = [299 145 203 97];

      % Create WaistX_dzACT
      app.WaistX_dzACT = uieditfield(app.PrimaryIPWaistShiftcmPanel, 'numeric');
      app.WaistX_dzACT.Editable = 'off';
      app.WaistX_dzACT.HorizontalAlignment = 'center';
      app.WaistX_dzACT.Position = [38 33 78 22];

      % Create WaistX_dzDES
      app.WaistX_dzDES = uieditfield(app.PrimaryIPWaistShiftcmPanel, 'numeric');
      app.WaistX_dzDES.ValueChangedFcn = createCallbackFcn(app, @WaistX_dzDESValueChanged, true);
      app.WaistX_dzDES.HorizontalAlignment = 'center';
      app.WaistX_dzDES.Position = [38 6 78 22];

      % Create WaistY_dzACT
      app.WaistY_dzACT = uieditfield(app.PrimaryIPWaistShiftcmPanel, 'numeric');
      app.WaistY_dzACT.Editable = 'off';
      app.WaistY_dzACT.HorizontalAlignment = 'center';
      app.WaistY_dzACT.Position = [119 33 78 22];

      % Create WaistY_dzDES
      app.WaistY_dzDES = uieditfield(app.PrimaryIPWaistShiftcmPanel, 'numeric');
      app.WaistY_dzDES.ValueChangedFcn = createCallbackFcn(app, @WaistY_dzDESValueChanged, true);
      app.WaistY_dzDES.HorizontalAlignment = 'center';
      app.WaistY_dzDES.Position = [119 6 78 22];

      % Create ACTLabel
      app.ACTLabel = uilabel(app.PrimaryIPWaistShiftcmPanel);
      app.ACTLabel.Position = [6 33 29 22];
      app.ACTLabel.Text = 'ACT';

      % Create DESLabel
      app.DESLabel = uilabel(app.PrimaryIPWaistShiftcmPanel);
      app.DESLabel.Position = [4 7 30 22];
      app.DESLabel.Text = 'DES';

      % Create XLabel
      app.XLabel = uilabel(app.PrimaryIPWaistShiftcmPanel);
      app.XLabel.Position = [72 54 25 22];
      app.XLabel.Text = 'X';

      % Create YLabel
      app.YLabel = uilabel(app.PrimaryIPWaistShiftcmPanel);
      app.YLabel.Position = [154 54 25 22];
      app.YLabel.Text = 'Y';

      % Create DoMatchButton
      app.DoMatchButton = uibutton(app.MatchingPanel, 'push');
      app.DoMatchButton.ButtonPushedFcn = createCallbackFcn(app, @DoMatchButtonPushed, true);
      app.DoMatchButton.Interruptible = 'off';
      app.DoMatchButton.FontSize = 16;
      app.DoMatchButton.FontWeight = 'bold';
      app.DoMatchButton.Position = [519 296 118 26];
      app.DoMatchButton.Text = 'Do Match';

      % Create WaistDESButton
      app.WaistDESButton = uibutton(app.MatchingPanel, 'push');
      app.WaistDESButton.ButtonPushedFcn = createCallbackFcn(app, @WaistDESButtonPushed, true);
      app.WaistDESButton.Interruptible = 'off';
      app.WaistDESButton.FontSize = 16;
      app.WaistDESButton.FontWeight = 'bold';
      app.WaistDESButton.Position = [519 264 118 26];
      app.WaistDESButton.Text = 'Waist -> DES';

      % Create TRIMQUADSButton
      app.TRIMQUADSButton = uibutton(app.MatchingPanel, 'push');
      app.TRIMQUADSButton.ButtonPushedFcn = createCallbackFcn(app, @TRIMQUADSButtonPushed, true);
      app.TRIMQUADSButton.Interruptible = 'off';
      app.TRIMQUADSButton.FontSize = 16;
      app.TRIMQUADSButton.FontWeight = 'bold';
      app.TRIMQUADSButton.Enable = 'off';
      app.TRIMQUADSButton.Position = [519 149 118 40];
      app.TRIMQUADSButton.Text = 'TRIM QUADS';

      % Create IntegratedQuadrupoleStrengthsBDESkGPanel
      app.IntegratedQuadrupoleStrengthsBDESkGPanel = uipanel(app.MatchingPanel);
      app.IntegratedQuadrupoleStrengthsBDESkGPanel.Title = 'Integrated Quadrupole Strengths (BDES) [kG]';
      app.IntegratedQuadrupoleStrengthsBDESkGPanel.Position = [9 6 638 132];

      % Create GridLayout4
      app.GridLayout4 = uigridlayout(app.IntegratedQuadrupoleStrengthsBDESkGPanel);
      app.GridLayout4.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
      app.GridLayout4.RowHeight = {'1x', '1x', '1x'};

      % Create Q5FFLabel
      app.Q5FFLabel = uilabel(app.GridLayout4);
      app.Q5FFLabel.HorizontalAlignment = 'center';
      app.Q5FFLabel.FontWeight = 'bold';
      app.Q5FFLabel.Layout.Row = 1;
      app.Q5FFLabel.Layout.Column = 2;
      app.Q5FFLabel.Text = 'Q5FF';

      % Create Q4FFLabel
      app.Q4FFLabel = uilabel(app.GridLayout4);
      app.Q4FFLabel.HorizontalAlignment = 'center';
      app.Q4FFLabel.FontWeight = 'bold';
      app.Q4FFLabel.Layout.Row = 1;
      app.Q4FFLabel.Layout.Column = 3;
      app.Q4FFLabel.Text = 'Q4FF';

      % Create Q3FFLabel
      app.Q3FFLabel = uilabel(app.GridLayout4);
      app.Q3FFLabel.HorizontalAlignment = 'center';
      app.Q3FFLabel.FontWeight = 'bold';
      app.Q3FFLabel.Layout.Row = 1;
      app.Q3FFLabel.Layout.Column = 4;
      app.Q3FFLabel.Text = 'Q3FF';

      % Create Q2FFLabel
      app.Q2FFLabel = uilabel(app.GridLayout4);
      app.Q2FFLabel.HorizontalAlignment = 'center';
      app.Q2FFLabel.FontWeight = 'bold';
      app.Q2FFLabel.Layout.Row = 1;
      app.Q2FFLabel.Layout.Column = 5;
      app.Q2FFLabel.Text = 'Q2FF';

      % Create Q1FFLabel
      app.Q1FFLabel = uilabel(app.GridLayout4);
      app.Q1FFLabel.HorizontalAlignment = 'center';
      app.Q1FFLabel.FontWeight = 'bold';
      app.Q1FFLabel.Layout.Row = 1;
      app.Q1FFLabel.Layout.Column = 6;
      app.Q1FFLabel.Text = 'Q1FF';

      % Create Q0FFLabel
      app.Q0FFLabel = uilabel(app.GridLayout4);
      app.Q0FFLabel.HorizontalAlignment = 'center';
      app.Q0FFLabel.FontWeight = 'bold';
      app.Q0FFLabel.Layout.Row = 1;
      app.Q0FFLabel.Layout.Column = 7;
      app.Q0FFLabel.Text = 'Q0FF';

      % Create Q0DLabel
      app.Q0DLabel = uilabel(app.GridLayout4);
      app.Q0DLabel.HorizontalAlignment = 'center';
      app.Q0DLabel.FontWeight = 'bold';
      app.Q0DLabel.Layout.Row = 1;
      app.Q0DLabel.Layout.Column = 8;
      app.Q0DLabel.Text = 'Q0D';

      % Create Q1DLabel
      app.Q1DLabel = uilabel(app.GridLayout4);
      app.Q1DLabel.HorizontalAlignment = 'center';
      app.Q1DLabel.FontWeight = 'bold';
      app.Q1DLabel.Layout.Row = 1;
      app.Q1DLabel.Layout.Column = 9;
      app.Q1DLabel.Text = 'Q1D';

      % Create Q2DLabel
      app.Q2DLabel = uilabel(app.GridLayout4);
      app.Q2DLabel.HorizontalAlignment = 'center';
      app.Q2DLabel.FontWeight = 'bold';
      app.Q2DLabel.Layout.Row = 1;
      app.Q2DLabel.Layout.Column = 10;
      app.Q2DLabel.Text = 'Q2D';

      % Create BDESLabel
      app.BDESLabel = uilabel(app.GridLayout4);
      app.BDESLabel.HorizontalAlignment = 'center';
      app.BDESLabel.FontWeight = 'bold';
      app.BDESLabel.Layout.Row = 2;
      app.BDESLabel.Layout.Column = 1;
      app.BDESLabel.Text = 'BDES:';

      % Create MatchLabel_2
      app.MatchLabel_2 = uilabel(app.GridLayout4);
      app.MatchLabel_2.HorizontalAlignment = 'center';
      app.MatchLabel_2.FontWeight = 'bold';
      app.MatchLabel_2.Layout.Row = 3;
      app.MatchLabel_2.Layout.Column = 1;
      app.MatchLabel_2.Text = 'Match:';

      % Create BDES_Q5FF
      app.BDES_Q5FF = uieditfield(app.GridLayout4, 'numeric');
      app.BDES_Q5FF.Editable = 'off';
      app.BDES_Q5FF.HorizontalAlignment = 'center';
      app.BDES_Q5FF.Layout.Row = 2;
      app.BDES_Q5FF.Layout.Column = 2;

      % Create BDES_Q4FF
      app.BDES_Q4FF = uieditfield(app.GridLayout4, 'numeric');
      app.BDES_Q4FF.Editable = 'off';
      app.BDES_Q4FF.HorizontalAlignment = 'center';
      app.BDES_Q4FF.Layout.Row = 2;
      app.BDES_Q4FF.Layout.Column = 3;

      % Create BDES_Q3FF
      app.BDES_Q3FF = uieditfield(app.GridLayout4, 'numeric');
      app.BDES_Q3FF.Editable = 'off';
      app.BDES_Q3FF.HorizontalAlignment = 'center';
      app.BDES_Q3FF.Layout.Row = 2;
      app.BDES_Q3FF.Layout.Column = 4;

      % Create BDES_Q2FF
      app.BDES_Q2FF = uieditfield(app.GridLayout4, 'numeric');
      app.BDES_Q2FF.Editable = 'off';
      app.BDES_Q2FF.HorizontalAlignment = 'center';
      app.BDES_Q2FF.Layout.Row = 2;
      app.BDES_Q2FF.Layout.Column = 5;

      % Create BDES_Q1FF
      app.BDES_Q1FF = uieditfield(app.GridLayout4, 'numeric');
      app.BDES_Q1FF.Editable = 'off';
      app.BDES_Q1FF.HorizontalAlignment = 'center';
      app.BDES_Q1FF.Layout.Row = 2;
      app.BDES_Q1FF.Layout.Column = 6;

      % Create BDES_Q0FF
      app.BDES_Q0FF = uieditfield(app.GridLayout4, 'numeric');
      app.BDES_Q0FF.Editable = 'off';
      app.BDES_Q0FF.HorizontalAlignment = 'center';
      app.BDES_Q0FF.Layout.Row = 2;
      app.BDES_Q0FF.Layout.Column = 7;

      % Create BDES_Q0D
      app.BDES_Q0D = uieditfield(app.GridLayout4, 'numeric');
      app.BDES_Q0D.Editable = 'off';
      app.BDES_Q0D.HorizontalAlignment = 'center';
      app.BDES_Q0D.Layout.Row = 2;
      app.BDES_Q0D.Layout.Column = 8;

      % Create BDES_Q1D
      app.BDES_Q1D = uieditfield(app.GridLayout4, 'numeric');
      app.BDES_Q1D.Editable = 'off';
      app.BDES_Q1D.HorizontalAlignment = 'center';
      app.BDES_Q1D.Layout.Row = 2;
      app.BDES_Q1D.Layout.Column = 9;

      % Create BDES_Q2D
      app.BDES_Q2D = uieditfield(app.GridLayout4, 'numeric');
      app.BDES_Q2D.Editable = 'off';
      app.BDES_Q2D.HorizontalAlignment = 'center';
      app.BDES_Q2D.Layout.Row = 2;
      app.BDES_Q2D.Layout.Column = 10;

      % Create BMATCH_Q5FF
      app.BMATCH_Q5FF = uieditfield(app.GridLayout4, 'numeric');
      app.BMATCH_Q5FF.Editable = 'off';
      app.BMATCH_Q5FF.HorizontalAlignment = 'center';
      app.BMATCH_Q5FF.Layout.Row = 3;
      app.BMATCH_Q5FF.Layout.Column = 2;

      % Create BMATCH_Q4FF
      app.BMATCH_Q4FF = uieditfield(app.GridLayout4, 'numeric');
      app.BMATCH_Q4FF.Editable = 'off';
      app.BMATCH_Q4FF.HorizontalAlignment = 'center';
      app.BMATCH_Q4FF.Layout.Row = 3;
      app.BMATCH_Q4FF.Layout.Column = 3;

      % Create BMATCH_Q3FF
      app.BMATCH_Q3FF = uieditfield(app.GridLayout4, 'numeric');
      app.BMATCH_Q3FF.Editable = 'off';
      app.BMATCH_Q3FF.HorizontalAlignment = 'center';
      app.BMATCH_Q3FF.Layout.Row = 3;
      app.BMATCH_Q3FF.Layout.Column = 4;

      % Create BMATCH_Q2FF
      app.BMATCH_Q2FF = uieditfield(app.GridLayout4, 'numeric');
      app.BMATCH_Q2FF.Editable = 'off';
      app.BMATCH_Q2FF.HorizontalAlignment = 'center';
      app.BMATCH_Q2FF.Layout.Row = 3;
      app.BMATCH_Q2FF.Layout.Column = 5;

      % Create BMATCH_Q1FF
      app.BMATCH_Q1FF = uieditfield(app.GridLayout4, 'numeric');
      app.BMATCH_Q1FF.Editable = 'off';
      app.BMATCH_Q1FF.HorizontalAlignment = 'center';
      app.BMATCH_Q1FF.Layout.Row = 3;
      app.BMATCH_Q1FF.Layout.Column = 6;

      % Create BMATCH_Q0FF
      app.BMATCH_Q0FF = uieditfield(app.GridLayout4, 'numeric');
      app.BMATCH_Q0FF.Editable = 'off';
      app.BMATCH_Q0FF.HorizontalAlignment = 'center';
      app.BMATCH_Q0FF.Layout.Row = 3;
      app.BMATCH_Q0FF.Layout.Column = 7;

      % Create BMATCH_Q0D
      app.BMATCH_Q0D = uieditfield(app.GridLayout4, 'numeric');
      app.BMATCH_Q0D.Editable = 'off';
      app.BMATCH_Q0D.HorizontalAlignment = 'center';
      app.BMATCH_Q0D.Layout.Row = 3;
      app.BMATCH_Q0D.Layout.Column = 8;

      % Create BMATCH_Q1D
      app.BMATCH_Q1D = uieditfield(app.GridLayout4, 'numeric');
      app.BMATCH_Q1D.Editable = 'off';
      app.BMATCH_Q1D.HorizontalAlignment = 'center';
      app.BMATCH_Q1D.Layout.Row = 3;
      app.BMATCH_Q1D.Layout.Column = 9;

      % Create BMATCH_Q2D
      app.BMATCH_Q2D = uieditfield(app.GridLayout4, 'numeric');
      app.BMATCH_Q2D.Editable = 'off';
      app.BMATCH_Q2D.HorizontalAlignment = 'center';
      app.BMATCH_Q2D.Layout.Row = 3;
      app.BMATCH_Q2D.Layout.Column = 10;

      % Create ShowTableButton
      app.ShowTableButton = uibutton(app.MatchingPanel, 'push');
      app.ShowTableButton.ButtonPushedFcn = createCallbackFcn(app, @ShowTableButtonPushed, true);
      app.ShowTableButton.Interruptible = 'off';
      app.ShowTableButton.FontSize = 16;
      app.ShowTableButton.Position = [519 232 118 26];
      app.ShowTableButton.Text = 'Show Table';

      % Create UpdateButton
      app.UpdateButton = uibutton(app.MatchingPanel, 'push');
      app.UpdateButton.ButtonPushedFcn = createCallbackFcn(app, @UpdateButtonPushed, true);
      app.UpdateButton.Interruptible = 'off';
      app.UpdateButton.Visible = 'off';
      app.UpdateButton.Position = [528 198 100 23];
      app.UpdateButton.Text = 'Update';

      % Create TCAVConfigButton
      app.TCAVConfigButton = uibutton(app.MatchingPanel, 'push');
      app.TCAVConfigButton.ButtonPushedFcn = createCallbackFcn(app, @TCAVConfigButtonPushed, true);
      app.TCAVConfigButton.Position = [518 196 118 26];
      app.TCAVConfigButton.Text = 'TCAV Config';

      % Create TwissParameterPlotPanel
      app.TwissParameterPlotPanel = uipanel(app.FACETIISector20ConfiguratorUIFigure);
      app.TwissParameterPlotPanel.Title = 'Twiss Parameter Plot';
      app.TwissParameterPlotPanel.FontWeight = 'bold';
      app.TwissParameterPlotPanel.Position = [175 8 653 359];

      % Create UIAxes
      app.UIAxes = uiaxes(app.TwissParameterPlotPanel);
      title(app.UIAxes, '')
      xlabel(app.UIAxes, '')
      ylabel(app.UIAxes, '')
      app.UIAxes.XTick = [];
      app.UIAxes.YTick = [];
      app.UIAxes.Position = [48 257 597 78];

      % Create UIAxes2
      app.UIAxes2 = uiaxes(app.TwissParameterPlotPanel);
      title(app.UIAxes2, '')
      xlabel(app.UIAxes2, 'X')
      ylabel(app.UIAxes2, 'Y')
      app.UIAxes2.Position = [1 6 650 267];

      % Show the figure after all components are created
      app.FACETIISector20ConfiguratorUIFigure.Visible = 'on';
    end
  end

  % App creation and deletion
  methods (Access = public)

    % Construct app
    function app = F2_S20Config_exported

      % Create UIFigure and components
      createComponents(app)

      % Register the app with App Designer
      registerApp(app, app.FACETIISector20ConfiguratorUIFigure)

      % Execute the startup function
      runStartupFcn(app, @startupFcn)

      if nargout == 0
        clear app
      end
    end

    % Code that executes before app deletion
    function delete(app)

      % Delete UIFigure when app is deleted
      delete(app.FACETIISector20ConfiguratorUIFigure)
    end
  end
end