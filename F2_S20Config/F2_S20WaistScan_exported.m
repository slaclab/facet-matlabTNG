classdef F2_S20WaistScan_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        FACETIISector20ConfiguratorUIFigure  matlab.ui.Figure
        PlotMenu                        matlab.ui.container.Menu
        ShowlegendMenu                  matlab.ui.container.Menu
        DetachPlotMenu                  matlab.ui.container.Menu
        OptimizerMenu                   matlab.ui.container.Menu
        UseConstraintsMenu              matlab.ui.container.Menu
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
        ScanparametersPanel             matlab.ui.container.Panel
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
        MatchLabel_2                    matlab.ui.control.Label
        BMATCH_Q5FF                     matlab.ui.control.NumericEditField
        BMATCH_Q4FF                     matlab.ui.control.NumericEditField
        BMATCH_Q3FF                     matlab.ui.control.NumericEditField
        BMATCH_Q2FF                     matlab.ui.control.NumericEditField
        BMATCH_Q1FF                     matlab.ui.control.NumericEditField
        BMATCH_Q0FF                     matlab.ui.control.NumericEditField
        BMATCH_Q0D                      matlab.ui.control.NumericEditField
        BMATCH_Q1D                      matlab.ui.control.NumericEditField
        BMATCH_Q2D                      matlab.ui.control.NumericEditField
        UpdateButton                    matlab.ui.control.Button
        getBSListButt                   matlab.ui.control.Button
        RelativeWaistParameterscmPanel  matlab.ui.container.Panel
        StartLabel                      matlab.ui.control.Label
        StopLabel                       matlab.ui.control.Label
        StepsLabel                      matlab.ui.control.Label
        StartEditField                  matlab.ui.control.NumericEditField
        StopEditField                   matlab.ui.control.NumericEditField
        StepsEditField                  matlab.ui.control.NumericEditField
        ScanValuesTextArea              matlab.ui.control.TextArea
        Log                             matlab.ui.control.TextArea
        TwissParameterPlotPanel         matlab.ui.container.Panel
        UIAxes                          matlab.ui.control.UIAxes
        UIAxes2                         matlab.ui.control.UIAxes
        MatchingPanel_2                 matlab.ui.container.Panel
        SpectrometerParametersPanel     matlab.ui.container.Panel
        EnergyGeVEditFieldLabel         matlab.ui.control.Label
        EnergyEditField                 matlab.ui.control.NumericEditField
        ZObjectmEditFieldLabel          matlab.ui.control.Label
        ZObjectEditField                matlab.ui.control.NumericEditField
        ZImagemEditFieldLabel           matlab.ui.control.Label
        ZImageEditField                 matlab.ui.control.NumericEditField
        M12EditFieldLabel               matlab.ui.control.Label
        M12EditField                    matlab.ui.control.NumericEditField
        M34EditFieldLabel               matlab.ui.control.Label
        M34EditField                    matlab.ui.control.NumericEditField
        ZobDropDown                     matlab.ui.control.DropDown
        ZimDropDown                     matlab.ui.control.DropDown
        CalcButton                      matlab.ui.control.Button
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
    end

  
  properties (Access = public)
    appS20 % F2_S20WaistScanApp object
    appSpec
  
  end
  
  properties (Access = private)
    XYSelect logical = false % true when first X/Y pair selected (either desired beta or waist offset)
    trim1 logical = true
    scan_vals
  end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
%      addpath('F2_SpecLine/');
      app.appS20.aobj = F2_S20WaistScanApp(app) ;
      app.appSpec.aobj = F2_SpecLineCPApp(app);
      
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
      app.appS20.aobj.WaistDesName = value ;
        end

        % Value changed function: Dx, Dxp, Dy, Dyp, alphax, alphay, 
        % betax, betay, emitx, emity
        function emitxValueChanged(app, event)
      app.UserButton.Value = true;
      parvals = [app.betax.Value app.betay.Value app.alphax.Value app.alphay.Value app.emitx.Value app.emity.Value app.Dx.Value app.Dxp.Value app.Dy.Value app.Dyp.Value] ;
      app.appS20.aobj.UserParams = parvals ;
      app.appS20.aobj.InitialOption="User"; % Causes all GUI fields to update if editing non-User parameters
      caput(app.appS20.aobj.pvs.UserBetax,parvals(1));
      caput(app.appS20.aobj.pvs.UserBetay,parvals(2));
      caput(app.appS20.aobj.pvs.UserAlphax,parvals(3));
      caput(app.appS20.aobj.pvs.UserAlphay,parvals(4));
      caput(app.appS20.aobj.pvs.UserNEmitx,parvals(5));
      caput(app.appS20.aobj.pvs.UserNEmity,parvals(6));
      caput(app.appS20.aobj.pvs.UserDispx,parvals(7));
      caput(app.appS20.aobj.pvs.UserDispxp,parvals(8));
      caput(app.appS20.aobj.pvs.UserDispx,parvals(9));
      caput(app.appS20.aobj.pvs.UserDispxp,parvals(10));
        end

        % Selection changed function: 
        % InitialParameterSourceDataButtonGroup
        function InitialParameterSourceDataButtonGroupSelectionChanged(app, event)
      selectedButton = app.InitialParameterSourceDataButtonGroup.SelectedObject;
      switch selectedButton
        case app.DesignButton
          app.appS20.aobj.InitialOption="Design";
        case app.L3Button
          app.appS20.aobj.InitialOption="L3";
        case app.UserButton
          app.appS20.aobj.InitialOption="User";
        case app.IPButton
          app.appS20.aobj.InitialOption="IP";
      end
        end

        % Value changed function: DropDown
        function DropDownValueChanged(app, event)
      value = app.DropDown.Value;
      app.appS20.aobj.InitialIPOption = value ;
        end

        % Value changed function: E0
        function E0ValueChanged(app, event)
      value = app.E0.Value;
      app.appS20.aobj.E_override = true ;
      app.appS20.aobj.E0=value;
        end

        % Value changed function: dE
        function dEValueChanged(app, event)
      value = app.dE.Value;
      app.appS20.aobj.dE=value;
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
      app.appS20.aobj.BetaDES = [app.BetaX_DES.Value app.BetaY_DES.Value].*1e-2 ;
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
      app.appS20.aobj.BetaDES = [app.BetaX_DES.Value app.BetaY_DES.Value].*1e-2 ;
        end

        % Callback function
        function DropDown_2ValueChanged(app, event)
      value = app.DropDown_2.Value;
      app.appS20.aobj.WaistDesNameDS = value ;
        end

        % Callback function
        function DropDown_3ValueChanged(app, event)
      value = app.DropDown_3.Value;
      switch string(value)
        case "SFQED"
          app.appS20.aobj.isSFQED=true; app.appS20.aobj.isKracken=false;
        case "Kracken"
          app.appS20.aobj.isSFQED=false; app.appS20.aobj.isKracken=true;
        otherwise
          app.appS20.aobj.isSFQED=false; app.appS20.aobj.isKracken=false;
      end
        end

        % Button pushed function: DoMatchButton
        function DoMatchButtonPushed(app, event)
      app.XYSelect=false;
      app.DoMatchButton.Enable=false; drawnow;
      try
        app.appS20.aobj.MatchFFS;
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
        app.appS20.aobj.MatchWaist;
      catch ME
        errordlg('Error whilst matching new waist location- see console output window','Waist Match Error');
        app.WaistDESButton.Enable=true;
        throw(ME);
      end
      app.WaistDESButton.Enable=true;
        end

        % Callback function
        function ShowTableButtonPushed(app, event)
      app.appS20.aobj.Table;
        end

        % Value changed function: WaistX_dzDES
        function WaistX_dzDESValueChanged(app, event)
      value = app.WaistX_dzDES.Value;
      if ~app.XYSelect
        app.WaistY_dzDES.Value = value ;
        app.XYSelect=false;
      else
        app.XYSelect=true;
      end
      app.appS20.aobj.WaistShiftDES=[app.WaistX_dzDES.Value app.WaistY_dzDES.Value].*1e-2;
        end

        % Value changed function: WaistY_dzDES
        function WaistY_dzDESValueChanged(app, event)
      value = app.WaistY_dzDES.Value;
      if ~app.XYSelect
        app.WaistX_dzDES.Value = value ;
        app.XYSelect=false;
      else
        app.XYSelect=true;
      end
      app.appS20.aobj.WaistShiftDES=[app.WaistX_dzDES.Value app.WaistY_dzDES.Value].*1e-2;
        end

        % Callback function
        function TRIMQUADSButtonPushed(app, event)
      app.TRIMQUADSButton.Enable=false; drawnow;
      app.appS20.aobj.TrimQuads();
      if app.trim1
        app.appS20.aobj.TrimQuads();
        app.trim1=false;
      end
      app.appS20.aobj.PlotToLog;
      app.TRIMQUADSButton.Enable=true; drawnow;
        end

        % Button pushed function: UpdateButton
        function UpdateButtonPushed(app, event)
      
      app.appS20.aobj.PVwatchdog;
        end

        % Menu selected function: ShowlegendMenu
        function ShowlegendMenuSelected(app, event)
      if app.ShowlegendMenu.Checked
        legend(app.UIAxes2,'off');
        app.ShowlegendMenu.Checked=false;
        app.appS20.aobj.showlegend=false;
      else
        legend(app.UIAxes2,'on');
        app.ShowlegendMenu.Checked=true;
        app.appS20.aobj.showlegend=true;
      end
        end

        % Menu selected function: DetachPlotMenu
        function DetachPlotMenuSelected(app, event)
      fh=figure;
      app.appS20.aobj.Plot(fh);
        end

        % Callback function
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

        % Menu selected function: UseConstraintsMenu
        function UseConstraintsMenuSelected(app, event)
      if app.UseConstraintsMenu.Checked
        app.UseConstraintsMenu.Checked = false ;
      else
        app.UseConstraintsMenu.Checked = true ;
      end
      app.appS20.aobj.OptimConstraints = app.UseConstraintsMenu.Checked ;
        end

        % Value changed function: StepsEditField
        function StartEditFieldValueChanged(app, event)
            start_value = app.StartEditField.Value;
            end_value = app.StopEditField.Value;
            steps_val = app.StepsEditField.Value;
            
            if steps_val == 0
                return
            end
            
            
            app.scan_vals = linspace(start_value,end_value,steps_val);
            scan_str = num2str(app.scan_vals,'%0.2f, ');
            app.ScanValuesTextArea.Value = scan_str;
            
        end

        % Button pushed function: CalcButton
        function CalcButtonPushed(app, event)
            app.appSpec.aobj.Calc(app);
        end

        % Callback function
        function Q0DBCALCEditFieldValueChanged(app, event)
            value = app.Q0DBCALCEditField.Value;
            app.appSpec.aobj.elogtext = sprintf('\n\nCustom spectrometer quad settings:');
        end

        % Callback function
        function Q1DBCALCEditFieldValueChanged(app, event)
            value = app.Q1DBCALCEditField.Value;
            app.appSpec.aobj.elogtext = sprintf('\n\nCustom spectrometer quad settings:');   
        end

        % Callback function
        function Q2DBCALCEditFieldValueChanged(app, event)
            value = app.Q2DBCALCEditField.Value;
            app.appSpec.aobj.elogtext = sprintf('\n\nCustom spectrometer quad settings:');  
        end

        % Button pushed function: getBSListButt
        function getBSListButtButtonPushed(app, event)
            app.getBSListButt.Enable=false; drawnow;
            for idx = 1:length(app.scan_vals)
                app.appS20.aobj.WaistShiftDES=[app.scan_vals(idx) app.scan_vals(idx)].*1e-2;
                if idx==1
                    try
                    app.appS20.aobj.ClearBS;
                    app.appS20.aobj.MatchFFS;
                    catch ME
                    errordlg('Error when running matching routine- see console output','Match Error');
                        throw(ME);
                    end                    
                end
    
                try
                
                app.appS20.aobj.MatchWaist;
                catch ME
                errordlg('Error whilst matching new waist location- see console output window','Waist Match Error');
                app.WaistDESButton.Enable=true;
                throw(ME);
                end
                app.appS20.aobj.writeBS;
                app.appS20.aobj.UpdateLog;
                    
            end
            app.appS20.aobj.PrintFinish;
            app.getBSListButt.Enable=true;
            
        end

        % Callback function
        function testButtonPushed(app, event)
            app.appS20.aobj.test;
        end

        % Value changed function: ZobDropDown
        function ZobDropDownValueChanged(app, event)
            value = app.ZobDropDown.Value;
            
            z = set_Z(app.appSpec.aobj, app, 'ZobDropDown');
            lcaPutSmart('SIOC:SYS1:ML00:CALCOUT052', z);
        end

        % Value changed function: ZimDropDown
        function ZimDropDownValueChanged(app, event)
            value = app.ZimDropDown.Value;
            
            z = set_Z(app.appSpec.aobj, app, 'ZimDropDown');
            lcaPutSmart('SIOC:SYS1:ML00:CALCOUT053', z);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create FACETIISector20ConfiguratorUIFigure and hide until all components are created
            app.FACETIISector20ConfiguratorUIFigure = uifigure('Visible', 'off');
            app.FACETIISector20ConfiguratorUIFigure.Position = [100 100 842 1103];
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

            % Create OptimizerMenu
            app.OptimizerMenu = uimenu(app.FACETIISector20ConfiguratorUIFigure);
            app.OptimizerMenu.Text = 'Optimizer';

            % Create UseConstraintsMenu
            app.UseConstraintsMenu = uimenu(app.OptimizerMenu);
            app.UseConstraintsMenu.MenuSelectedFcn = createCallbackFcn(app, @UseConstraintsMenuSelected, true);
            app.UseConstraintsMenu.Checked = 'on';
            app.UseConstraintsMenu.Text = 'Use Constraints';

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
            app.IPPrimaryWaistLocationPanel.Position = [9 212 159 882];

            % Create ListBox
            app.ListBox = uilistbox(app.IPPrimaryWaistLocationPanel);
            app.ListBox.ValueChangedFcn = createCallbackFcn(app, @ListBoxValueChanged, true);
            app.ListBox.Position = [8 -199 141 1054];

            % Create InitialParametersBEGFF20Panel
            app.InitialParametersBEGFF20Panel = uipanel(app.FACETIISector20ConfiguratorUIFigure);
            app.InitialParametersBEGFF20Panel.Title = 'Initial Parameters @ BEGFF20';
            app.InitialParametersBEGFF20Panel.FontWeight = 'bold';
            app.InitialParametersBEGFF20Panel.Position = [175 945 653 149];

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

            % Create ScanparametersPanel
            app.ScanparametersPanel = uipanel(app.FACETIISector20ConfiguratorUIFigure);
            app.ScanparametersPanel.Title = 'Scan parameters';
            app.ScanparametersPanel.FontWeight = 'bold';
            app.ScanparametersPanel.Position = [175 385 653 264];

            % Create IntegratedQuadrupoleStrengthsBDESkGPanel
            app.IntegratedQuadrupoleStrengthsBDESkGPanel = uipanel(app.ScanparametersPanel);
            app.IntegratedQuadrupoleStrengthsBDESkGPanel.Title = 'Integrated Quadrupole Strengths (BDES) [kG]';
            app.IntegratedQuadrupoleStrengthsBDESkGPanel.Position = [9 8 637 88];

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.IntegratedQuadrupoleStrengthsBDESkGPanel);
            app.GridLayout4.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout4.RowHeight = {'0.6x', '1x'};

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

            % Create MatchLabel_2
            app.MatchLabel_2 = uilabel(app.GridLayout4);
            app.MatchLabel_2.HorizontalAlignment = 'center';
            app.MatchLabel_2.FontWeight = 'bold';
            app.MatchLabel_2.Layout.Row = 2;
            app.MatchLabel_2.Layout.Column = 1;
            app.MatchLabel_2.Text = 'Match:';

            % Create BMATCH_Q5FF
            app.BMATCH_Q5FF = uieditfield(app.GridLayout4, 'numeric');
            app.BMATCH_Q5FF.Editable = 'off';
            app.BMATCH_Q5FF.HorizontalAlignment = 'center';
            app.BMATCH_Q5FF.Layout.Row = 2;
            app.BMATCH_Q5FF.Layout.Column = 2;

            % Create BMATCH_Q4FF
            app.BMATCH_Q4FF = uieditfield(app.GridLayout4, 'numeric');
            app.BMATCH_Q4FF.Editable = 'off';
            app.BMATCH_Q4FF.HorizontalAlignment = 'center';
            app.BMATCH_Q4FF.Layout.Row = 2;
            app.BMATCH_Q4FF.Layout.Column = 3;

            % Create BMATCH_Q3FF
            app.BMATCH_Q3FF = uieditfield(app.GridLayout4, 'numeric');
            app.BMATCH_Q3FF.Editable = 'off';
            app.BMATCH_Q3FF.HorizontalAlignment = 'center';
            app.BMATCH_Q3FF.Layout.Row = 2;
            app.BMATCH_Q3FF.Layout.Column = 4;

            % Create BMATCH_Q2FF
            app.BMATCH_Q2FF = uieditfield(app.GridLayout4, 'numeric');
            app.BMATCH_Q2FF.Editable = 'off';
            app.BMATCH_Q2FF.HorizontalAlignment = 'center';
            app.BMATCH_Q2FF.Layout.Row = 2;
            app.BMATCH_Q2FF.Layout.Column = 5;

            % Create BMATCH_Q1FF
            app.BMATCH_Q1FF = uieditfield(app.GridLayout4, 'numeric');
            app.BMATCH_Q1FF.Editable = 'off';
            app.BMATCH_Q1FF.HorizontalAlignment = 'center';
            app.BMATCH_Q1FF.Layout.Row = 2;
            app.BMATCH_Q1FF.Layout.Column = 6;

            % Create BMATCH_Q0FF
            app.BMATCH_Q0FF = uieditfield(app.GridLayout4, 'numeric');
            app.BMATCH_Q0FF.Editable = 'off';
            app.BMATCH_Q0FF.HorizontalAlignment = 'center';
            app.BMATCH_Q0FF.Layout.Row = 2;
            app.BMATCH_Q0FF.Layout.Column = 7;

            % Create BMATCH_Q0D
            app.BMATCH_Q0D = uieditfield(app.GridLayout4, 'numeric');
            app.BMATCH_Q0D.Editable = 'off';
            app.BMATCH_Q0D.HorizontalAlignment = 'center';
            app.BMATCH_Q0D.Layout.Row = 2;
            app.BMATCH_Q0D.Layout.Column = 8;

            % Create BMATCH_Q1D
            app.BMATCH_Q1D = uieditfield(app.GridLayout4, 'numeric');
            app.BMATCH_Q1D.Editable = 'off';
            app.BMATCH_Q1D.HorizontalAlignment = 'center';
            app.BMATCH_Q1D.Layout.Row = 2;
            app.BMATCH_Q1D.Layout.Column = 9;

            % Create BMATCH_Q2D
            app.BMATCH_Q2D = uieditfield(app.GridLayout4, 'numeric');
            app.BMATCH_Q2D.Editable = 'off';
            app.BMATCH_Q2D.HorizontalAlignment = 'center';
            app.BMATCH_Q2D.Layout.Row = 2;
            app.BMATCH_Q2D.Layout.Column = 10;

            % Create UpdateButton
            app.UpdateButton = uibutton(app.ScanparametersPanel, 'push');
            app.UpdateButton.ButtonPushedFcn = createCallbackFcn(app, @UpdateButtonPushed, true);
            app.UpdateButton.Interruptible = 'off';
            app.UpdateButton.Visible = 'off';
            app.UpdateButton.Position = [528 106 100 23];
            app.UpdateButton.Text = 'Update';

            % Create getBSListButt
            app.getBSListButt = uibutton(app.ScanparametersPanel, 'push');
            app.getBSListButt.ButtonPushedFcn = createCallbackFcn(app, @getBSListButtButtonPushed, true);
            app.getBSListButt.BackgroundColor = [0.4627 0.949 0.1137];
            app.getBSListButt.FontSize = 16;
            app.getBSListButt.FontWeight = 'bold';
            app.getBSListButt.Position = [223 109 214 26];
            app.getBSListButt.Text = 'Get Waist Scan BDES List';

            % Create RelativeWaistParameterscmPanel
            app.RelativeWaistParameterscmPanel = uipanel(app.ScanparametersPanel);
            app.RelativeWaistParameterscmPanel.Title = 'Relative Waist Parameters [cm]';
            app.RelativeWaistParameterscmPanel.Position = [9 105 203 130];

            % Create StartLabel
            app.StartLabel = uilabel(app.RelativeWaistParameterscmPanel);
            app.StartLabel.Position = [9 84 31 22];
            app.StartLabel.Text = 'Start';

            % Create StopLabel
            app.StopLabel = uilabel(app.RelativeWaistParameterscmPanel);
            app.StopLabel.Position = [78 84 30 22];
            app.StopLabel.Text = 'Stop';

            % Create StepsLabel
            app.StepsLabel = uilabel(app.RelativeWaistParameterscmPanel);
            app.StepsLabel.Position = [145 84 36 22];
            app.StepsLabel.Text = 'Steps';

            % Create StartEditField
            app.StartEditField = uieditfield(app.RelativeWaistParameterscmPanel, 'numeric');
            app.StartEditField.Position = [7 63 51 22];

            % Create StopEditField
            app.StopEditField = uieditfield(app.RelativeWaistParameterscmPanel, 'numeric');
            app.StopEditField.Position = [76 63 51 22];

            % Create StepsEditField
            app.StepsEditField = uieditfield(app.RelativeWaistParameterscmPanel, 'numeric');
            app.StepsEditField.ValueChangedFcn = createCallbackFcn(app, @StartEditFieldValueChanged, true);
            app.StepsEditField.Position = [144 63 51 22];

            % Create ScanValuesTextArea
            app.ScanValuesTextArea = uitextarea(app.RelativeWaistParameterscmPanel);
            app.ScanValuesTextArea.Editable = 'off';
            app.ScanValuesTextArea.Enable = 'off';
            app.ScanValuesTextArea.Position = [9 4 183 51];

            % Create Log
            app.Log = uitextarea(app.ScanparametersPanel);
            app.Log.Position = [223 142 421 94];

            % Create TwissParameterPlotPanel
            app.TwissParameterPlotPanel = uipanel(app.FACETIISector20ConfiguratorUIFigure);
            app.TwissParameterPlotPanel.Title = 'Twiss Parameter Plot';
            app.TwissParameterPlotPanel.FontWeight = 'bold';
            app.TwissParameterPlotPanel.Position = [175 15 653 359];

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

            % Create MatchingPanel_2
            app.MatchingPanel_2 = uipanel(app.FACETIISector20ConfiguratorUIFigure);
            app.MatchingPanel_2.Title = 'Matching';
            app.MatchingPanel_2.FontWeight = 'bold';
            app.MatchingPanel_2.Position = [176 656 650 282];

            % Create SpectrometerParametersPanel
            app.SpectrometerParametersPanel = uipanel(app.MatchingPanel_2);
            app.SpectrometerParametersPanel.Title = 'Spectrometer Parameters';
            app.SpectrometerParametersPanel.Position = [8 10 292 243];

            % Create EnergyGeVEditFieldLabel
            app.EnergyGeVEditFieldLabel = uilabel(app.SpectrometerParametersPanel);
            app.EnergyGeVEditFieldLabel.HorizontalAlignment = 'right';
            app.EnergyGeVEditFieldLabel.Position = [9 188 79 22];
            app.EnergyGeVEditFieldLabel.Text = 'Energy (GeV)';

            % Create EnergyEditField
            app.EnergyEditField = uieditfield(app.SpectrometerParametersPanel, 'numeric');
            app.EnergyEditField.ValueDisplayFormat = '%11.4f';
            app.EnergyEditField.Position = [100 188 73 22];

            % Create ZObjectmEditFieldLabel
            app.ZObjectmEditFieldLabel = uilabel(app.SpectrometerParametersPanel);
            app.ZObjectmEditFieldLabel.HorizontalAlignment = 'right';
            app.ZObjectmEditFieldLabel.Position = [17 144 71 22];
            app.ZObjectmEditFieldLabel.Text = 'Z Object (m)';

            % Create ZObjectEditField
            app.ZObjectEditField = uieditfield(app.SpectrometerParametersPanel, 'numeric');
            app.ZObjectEditField.ValueDisplayFormat = '%11.4f';
            app.ZObjectEditField.Position = [100 144 73 22];

            % Create ZImagemEditFieldLabel
            app.ZImagemEditFieldLabel = uilabel(app.SpectrometerParametersPanel);
            app.ZImagemEditFieldLabel.HorizontalAlignment = 'right';
            app.ZImagemEditFieldLabel.Position = [18 99 70 22];
            app.ZImagemEditFieldLabel.Text = 'Z Image (m)';

            % Create ZImageEditField
            app.ZImageEditField = uieditfield(app.SpectrometerParametersPanel, 'numeric');
            app.ZImageEditField.ValueDisplayFormat = '%11.4f';
            app.ZImageEditField.Position = [100 99 73 22];

            % Create M12EditFieldLabel
            app.M12EditFieldLabel = uilabel(app.SpectrometerParametersPanel);
            app.M12EditFieldLabel.HorizontalAlignment = 'right';
            app.M12EditFieldLabel.Position = [59 55 29 22];
            app.M12EditFieldLabel.Text = 'M12';

            % Create M12EditField
            app.M12EditField = uieditfield(app.SpectrometerParametersPanel, 'numeric');
            app.M12EditField.ValueDisplayFormat = '%11.4f';
            app.M12EditField.Position = [100 55 73 22];

            % Create M34EditFieldLabel
            app.M34EditFieldLabel = uilabel(app.SpectrometerParametersPanel);
            app.M34EditFieldLabel.HorizontalAlignment = 'right';
            app.M34EditFieldLabel.Position = [59 11 29 22];
            app.M34EditFieldLabel.Text = 'M34';

            % Create M34EditField
            app.M34EditField = uieditfield(app.SpectrometerParametersPanel, 'numeric');
            app.M34EditField.ValueDisplayFormat = '%11.4f';
            app.M34EditField.Position = [100 11 73 22];

            % Create ZobDropDown
            app.ZobDropDown = uidropdown(app.SpectrometerParametersPanel);
            app.ZobDropDown.Items = {'Select...', 'Custom', 'PIC_CENT', 'FILG', 'FILS', 'IPOTR1P', 'IPOTR1', 'PENT', 'IPWS1', 'PEXT', 'IPOTR2', 'BEWIN2'};
            app.ZobDropDown.ValueChangedFcn = createCallbackFcn(app, @ZobDropDownValueChanged, true);
            app.ZobDropDown.Position = [185 144 82 22];
            app.ZobDropDown.Value = 'Select...';

            % Create ZimDropDown
            app.ZimDropDown = uidropdown(app.SpectrometerParametersPanel);
            app.ZimDropDown.Items = {'Select...', 'Custom', 'EDC_SCREEN', 'DTOTR', 'LFOV', 'CHER', 'PRDMP'};
            app.ZimDropDown.ValueChangedFcn = createCallbackFcn(app, @ZimDropDownValueChanged, true);
            app.ZimDropDown.Position = [185 100 82 22];
            app.ZimDropDown.Value = 'Select...';

            % Create CalcButton
            app.CalcButton = uibutton(app.SpectrometerParametersPanel, 'push');
            app.CalcButton.ButtonPushedFcn = createCallbackFcn(app, @CalcButtonPushed, true);
            app.CalcButton.BackgroundColor = [0 0.4471 0.7412];
            app.CalcButton.FontSize = 14;
            app.CalcButton.FontWeight = 'bold';
            app.CalcButton.FontColor = [1 1 1];
            app.CalcButton.Position = [185 10 97 24];
            app.CalcButton.Text = 'Calculate';

            % Create BetaFunctionsatIPLocationPanel
            app.BetaFunctionsatIPLocationPanel = uipanel(app.MatchingPanel_2);
            app.BetaFunctionsatIPLocationPanel.Title = 'Beta Functions at IP Location';
            app.BetaFunctionsatIPLocationPanel.Position = [311 107 330 146];

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.BetaFunctionsatIPLocationPanel);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'0.6x', '1x', '1x', '1x'};
            app.GridLayout2.ColumnSpacing = 8;
            app.GridLayout2.RowSpacing = 8;

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

            % Create PrimaryIPWaistShiftcmPanel
            app.PrimaryIPWaistShiftcmPanel = uipanel(app.MatchingPanel_2);
            app.PrimaryIPWaistShiftcmPanel.Title = 'Primary IP Waist Shift [cm]';
            app.PrimaryIPWaistShiftcmPanel.Position = [313 10 203 87];

            % Create WaistX_dzACT
            app.WaistX_dzACT = uieditfield(app.PrimaryIPWaistShiftcmPanel, 'numeric');
            app.WaistX_dzACT.Editable = 'off';
            app.WaistX_dzACT.HorizontalAlignment = 'center';
            app.WaistX_dzACT.Position = [38 30 78 22];

            % Create WaistX_dzDES
            app.WaistX_dzDES = uieditfield(app.PrimaryIPWaistShiftcmPanel, 'numeric');
            app.WaistX_dzDES.ValueChangedFcn = createCallbackFcn(app, @WaistX_dzDESValueChanged, true);
            app.WaistX_dzDES.HorizontalAlignment = 'center';
            app.WaistX_dzDES.Position = [38 6 78 22];

            % Create WaistY_dzACT
            app.WaistY_dzACT = uieditfield(app.PrimaryIPWaistShiftcmPanel, 'numeric');
            app.WaistY_dzACT.Editable = 'off';
            app.WaistY_dzACT.HorizontalAlignment = 'center';
            app.WaistY_dzACT.Position = [119 30 78 22];

            % Create WaistY_dzDES
            app.WaistY_dzDES = uieditfield(app.PrimaryIPWaistShiftcmPanel, 'numeric');
            app.WaistY_dzDES.ValueChangedFcn = createCallbackFcn(app, @WaistY_dzDESValueChanged, true);
            app.WaistY_dzDES.HorizontalAlignment = 'center';
            app.WaistY_dzDES.Position = [119 6 78 22];

            % Create ACTLabel
            app.ACTLabel = uilabel(app.PrimaryIPWaistShiftcmPanel);
            app.ACTLabel.Position = [6 30 29 22];
            app.ACTLabel.Text = 'ACT';

            % Create DESLabel
            app.DESLabel = uilabel(app.PrimaryIPWaistShiftcmPanel);
            app.DESLabel.Position = [4 7 30 22];
            app.DESLabel.Text = 'DES';

            % Create XLabel
            app.XLabel = uilabel(app.PrimaryIPWaistShiftcmPanel);
            app.XLabel.Position = [72 53 25 13];
            app.XLabel.Text = 'X';

            % Create YLabel
            app.YLabel = uilabel(app.PrimaryIPWaistShiftcmPanel);
            app.YLabel.Position = [154 52 25 14];
            app.YLabel.Text = 'Y';

            % Create DoMatchButton
            app.DoMatchButton = uibutton(app.MatchingPanel_2, 'push');
            app.DoMatchButton.ButtonPushedFcn = createCallbackFcn(app, @DoMatchButtonPushed, true);
            app.DoMatchButton.Interruptible = 'off';
            app.DoMatchButton.FontSize = 16;
            app.DoMatchButton.FontWeight = 'bold';
            app.DoMatchButton.Position = [525 71 118 26];
            app.DoMatchButton.Text = 'Do Match';

            % Create WaistDESButton
            app.WaistDESButton = uibutton(app.MatchingPanel_2, 'push');
            app.WaistDESButton.ButtonPushedFcn = createCallbackFcn(app, @WaistDESButtonPushed, true);
            app.WaistDESButton.Interruptible = 'off';
            app.WaistDESButton.FontSize = 16;
            app.WaistDESButton.FontWeight = 'bold';
            app.WaistDESButton.Position = [525 41 118 26];
            app.WaistDESButton.Text = 'Waist -> DES';

            % Create TRIMQUADSButton
            app.TRIMQUADSButton = uibutton(app.MatchingPanel_2, 'push');
            app.TRIMQUADSButton.Interruptible = 'off';
            app.TRIMQUADSButton.FontSize = 16;
            app.TRIMQUADSButton.FontWeight = 'bold';
            app.TRIMQUADSButton.Enable = 'off';
            app.TRIMQUADSButton.Position = [525 10 118 27];
            app.TRIMQUADSButton.Text = 'TRIM QUADS';

            % Show the figure after all components are created
            app.FACETIISector20ConfiguratorUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_S20WaistScan_exported

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