classdef F2_LAME_exported < matlab.apps.AppBase

  % Properties that correspond to app components
  properties (Access = public)
    LAMEUIFigure              matlab.ui.Figure
    SolenoidCorrectorPanel    matlab.ui.container.Panel
    SwitchLabel               matlab.ui.control.Label
    Switch                    matlab.ui.control.ToggleSwitch
    dIAEditFieldLabel         matlab.ui.control.Label
    dIAEditField              matlab.ui.control.NumericEditField
    ScreenPositionsPanel      matlab.ui.container.Panel
    dxmmEditFieldLabel        matlab.ui.control.Label
    dxmmEditField             matlab.ui.control.NumericEditField
    dymmEditFieldLabel        matlab.ui.control.Label
    dymmEditField             matlab.ui.control.NumericEditField
    MainSolenoidPanel         matlab.ui.container.Panel
    CurrentAEditFieldLabel    matlab.ui.control.Label
    CurrentAEditField         matlab.ui.control.NumericEditField
    ConstrainFitPanel         matlab.ui.container.Panel
    EnableCheckBox            matlab.ui.control.CheckBox
    EminMeVEditFieldLabel     matlab.ui.control.Label
    EminMeVEditField          matlab.ui.control.NumericEditField
    EmaxMeVEditFieldLabel     matlab.ui.control.Label
    EmaxMeVEditField          matlab.ui.control.NumericEditField
    EnergyFitMeVPanel         matlab.ui.container.Panel
    ClosestLabel              matlab.ui.control.Label
    ClosestEditField          matlab.ui.control.NumericEditField
    UseREditFieldLabel        matlab.ui.control.Label
    UseREditField             matlab.ui.control.NumericEditField
    UseThetaEditFieldLabel    matlab.ui.control.Label
    UseThetaEditField         matlab.ui.control.NumericEditField
    PlotControlsPanel         matlab.ui.container.Panel
    RotateButton              matlab.ui.control.Button
    ZoomButton                matlab.ui.control.Button
    PanButton                 matlab.ui.control.Button
    DetachButton              matlab.ui.control.Button
    ParametersValidLampLabel  matlab.ui.control.Label
    ParametersValidLamp       matlab.ui.control.Lamp
    HelpButton                matlab.ui.control.Button
    FACETIIGunLarmorAngleMeasurementofEnergyLabel  matlab.ui.control.Label
    UIAxes                    matlab.ui.control.UIAxes
  end


    properties (Access = private)
        FD % F2GunDiagnostics object containing lookup data and methods
        isacr=false; % flags running on SLAC ACR computer
        acrdir="/home/fphysics/whitegr/F2_apps/apps"; % ACR home directory
    end

    methods (Access = private)
        
        % Do the lookup table fit using parameters in app
        function dofit(app)
            app.ParametersValidLamp.Color='g';
            try
                app.ClosestEditField.Enable=true;
                app.UseREditField.Enable=true;
                app.UseThetaEditField.Enable=true;
                dx = app.dxmmEditField.Value ;
                dy = app.dymmEditField.Value ;
                corI = app.dIAEditField.Value ;
                solI = app.CurrentAEditField.Value ;
                if app.Switch.Value == "XC10121"
                    ctype='x';
                else
                    ctype='y';
                end
                if app.EnableCheckBox.Value
                    emin = app.EminMeVEditField.Value ;
                    emax = app.EmaxMeVEditField.Value ;
                    [E1,E2,E3]=app.FD.Ecalc(dx,dy,corI,solI,ctype,emin,emax);
                else
                    [E1,E2,E3]=app.FD.Ecalc(dx,dy,corI,solI,ctype);
                end
                app.ClosestEditField.Value = E1 ;
                app.UseREditField.Value = E2 ;
                app.UseThetaEditField.Value = E3 ;
            catch
                app.ParametersValidLamp.Color='r';
                cla(app.UIAxes);
                app.ClosestEditField.Value=0;
                app.UseREditField.Value=0;
                app.UseThetaEditField.Value=0;
                app.ClosestEditField.Enable=false;
                app.UseREditField.Enable=false;
                app.UseThetaEditField.Enable=false;
            end
        end
        
    end


  % Callbacks that handle component events
  methods (Access = private)

    % Code that executes after component creation
    function startupFcn(app, ludatafile)
          if ~isdeployed
              if ~exist('ludatafile','var')
                ludatafile=which('F2_solcaldata.mat');
              end
              if ~exist(ludatafile,'file')
                error('Data file does not exist')
              end
          else
              if exist(app.acrdir,'dir') % control system run directory
                  ludatafile = fullfile(app.acrdir,"F2_solcaldata.mat") ;
                  app.isacr=true;
              else
                  ludatafile = 'F2_solcaldata.mat' ;
              end
          end
          
          % Initialize diagnostics object with provided lookup data file
          app.FD=F2GunDiagnostics(ludatafile); app.FD.verbose=2; app.FD.axhan = app.UIAxes ;
          app.FD.Ecalplot(app.CurrentAEditField.Value);
          
    end

    % Value changed function: Switch
    function SwitchValueChanged(app, event)
            app.dofit;
            
    end

    % Value changed function: dIAEditField
    function dIAEditFieldValueChanged(app, event)
            app.dofit;
            
    end

    % Value changed function: dxmmEditField
    function dxmmEditFieldValueChanged(app, event)
            app.dofit;
    end

    % Value changed function: dymmEditField
    function dymmEditFieldValueChanged(app, event)
            app.dofit;
    end

    % Value changed function: CurrentAEditField
    function CurrentAEditFieldValueChanged(app, event)
            app.dofit;
    end

    % Value changed function: EnableCheckBox
    function EnableCheckBoxValueChanged(app, event)
            app.dofit;
    end

    % Value changed function: EminMeVEditField
    function EminMeVEditFieldValueChanged(app, event)
            app.dofit;
    end

    % Value changed function: EmaxMeVEditField
    function EmaxMeVEditFieldValueChanged(app, event)
            app.dofit;
    end

    % Button pushed function: RotateButton
    function RotateButtonPushed(app, event)
            rotate3d(app.UIAxes,'on');
    end

    % Button pushed function: ZoomButton
    function ZoomButtonPushed(app, event)
            zoom(app.UIAxes,'on');
    end

    % Callback function
    function ResetZoomButtonPushed(app, event)
            zoom(app.UIAxes,'out');
    end

    % Button pushed function: PanButton
    function PanButtonPushed(app, event)
            pan(app.UIAxes,'on');
    end

    % Button pushed function: HelpButton
    function HelpButtonPushed(app, event)
            if app.isacr
                web(fullfile(app.acrdir,"F2_LAME.html"));
            elseif exist('web','dir')
                web('web/F2_LAME.html');
            else
                web('F2_LAME.html');
            end
    end

    % Button pushed function: DetachButton
    function DetachButtonPushed(app, event)
            app.FD.dfh = figure ;
            app.dofit;
    end
  end

  % Component initialization
  methods (Access = private)

    % Create UIFigure and components
    function createComponents(app)

      % Create LAMEUIFigure and hide until all components are created
      app.LAMEUIFigure = uifigure('Visible', 'off');
      app.LAMEUIFigure.Position = [100 100 1069 648];
      app.LAMEUIFigure.Name = 'LAME';

      % Create SolenoidCorrectorPanel
      app.SolenoidCorrectorPanel = uipanel(app.LAMEUIFigure);
      app.SolenoidCorrectorPanel.TitlePosition = 'centertop';
      app.SolenoidCorrectorPanel.Title = 'Solenoid Corrector';
      app.SolenoidCorrectorPanel.Position = [15 501 235 127];

      % Create SwitchLabel
      app.SwitchLabel = uilabel(app.SolenoidCorrectorPanel);
      app.SwitchLabel.HorizontalAlignment = 'center';
      app.SwitchLabel.Position = [100 1 25 22];
      app.SwitchLabel.Text = '';

      % Create Switch
      app.Switch = uiswitch(app.SolenoidCorrectorPanel, 'toggle');
      app.Switch.Items = {'XC10121', 'YC10122'};
      app.Switch.Orientation = 'horizontal';
      app.Switch.ValueChangedFcn = createCallbackFcn(app, @SwitchValueChanged, true);
      app.Switch.Position = [65 59 96 43];
      app.Switch.Value = 'XC10121';

      % Create dIAEditFieldLabel
      app.dIAEditFieldLabel = uilabel(app.SolenoidCorrectorPanel);
      app.dIAEditFieldLabel.HorizontalAlignment = 'right';
      app.dIAEditFieldLabel.Position = [21 22 33 22];
      app.dIAEditFieldLabel.Text = 'dI (A)';

      % Create dIAEditField
      app.dIAEditField = uieditfield(app.SolenoidCorrectorPanel, 'numeric');
      app.dIAEditField.Limits = [0 100];
      app.dIAEditField.ValueChangedFcn = createCallbackFcn(app, @dIAEditFieldValueChanged, true);
      app.dIAEditField.Position = [69 22 100 22];
      app.dIAEditField.Value = 1;

      % Create ScreenPositionsPanel
      app.ScreenPositionsPanel = uipanel(app.LAMEUIFigure);
      app.ScreenPositionsPanel.TitlePosition = 'centertop';
      app.ScreenPositionsPanel.Title = 'Screen Positions';
      app.ScreenPositionsPanel.Position = [15 382 235 110];

      % Create dxmmEditFieldLabel
      app.dxmmEditFieldLabel = uilabel(app.ScreenPositionsPanel);
      app.dxmmEditFieldLabel.HorizontalAlignment = 'right';
      app.dxmmEditFieldLabel.Position = [28 53 50 22];
      app.dxmmEditFieldLabel.Text = 'dx (mm)';

      % Create dxmmEditField
      app.dxmmEditField = uieditfield(app.ScreenPositionsPanel, 'numeric');
      app.dxmmEditField.Limits = [0 1000];
      app.dxmmEditField.ValueChangedFcn = createCallbackFcn(app, @dxmmEditFieldValueChanged, true);
      app.dxmmEditField.Position = [93 53 100 22];
      app.dxmmEditField.Value = 1.01748;

      % Create dymmEditFieldLabel
      app.dymmEditFieldLabel = uilabel(app.ScreenPositionsPanel);
      app.dymmEditFieldLabel.HorizontalAlignment = 'right';
      app.dymmEditFieldLabel.Position = [28 17 50 22];
      app.dymmEditFieldLabel.Text = 'dy (mm)';

      % Create dymmEditField
      app.dymmEditField = uieditfield(app.ScreenPositionsPanel, 'numeric');
      app.dymmEditField.Limits = [0 1000];
      app.dymmEditField.ValueChangedFcn = createCallbackFcn(app, @dymmEditFieldValueChanged, true);
      app.dymmEditField.Position = [93 17 100 22];
      app.dymmEditField.Value = 0.859221;

      % Create MainSolenoidPanel
      app.MainSolenoidPanel = uipanel(app.LAMEUIFigure);
      app.MainSolenoidPanel.TitlePosition = 'centertop';
      app.MainSolenoidPanel.Title = 'Main Solenoid';
      app.MainSolenoidPanel.Position = [15 294 235 73];

      % Create CurrentAEditFieldLabel
      app.CurrentAEditFieldLabel = uilabel(app.MainSolenoidPanel);
      app.CurrentAEditFieldLabel.HorizontalAlignment = 'right';
      app.CurrentAEditFieldLabel.Position = [20 17 64 22];
      app.CurrentAEditFieldLabel.Text = 'Current (A)';

      % Create CurrentAEditField
      app.CurrentAEditField = uieditfield(app.MainSolenoidPanel, 'numeric');
      app.CurrentAEditField.Limits = [90 170];
      app.CurrentAEditField.ValueChangedFcn = createCallbackFcn(app, @CurrentAEditFieldValueChanged, true);
      app.CurrentAEditField.Position = [99 17 100 22];
      app.CurrentAEditField.Value = 160;

      % Create ConstrainFitPanel
      app.ConstrainFitPanel = uipanel(app.LAMEUIFigure);
      app.ConstrainFitPanel.TitlePosition = 'centertop';
      app.ConstrainFitPanel.Title = 'Constrain Fit ?';
      app.ConstrainFitPanel.Position = [15 166 235 120];

      % Create EnableCheckBox
      app.EnableCheckBox = uicheckbox(app.ConstrainFitPanel);
      app.EnableCheckBox.ValueChangedFcn = createCallbackFcn(app, @EnableCheckBoxValueChanged, true);
      app.EnableCheckBox.Text = 'Enable';
      app.EnableCheckBox.Position = [10 75 61 22];

      % Create EminMeVEditFieldLabel
      app.EminMeVEditFieldLabel = uilabel(app.ConstrainFitPanel);
      app.EminMeVEditFieldLabel.HorizontalAlignment = 'right';
      app.EminMeVEditFieldLabel.Position = [53 41 68 22];
      app.EminMeVEditFieldLabel.Text = 'Emin (MeV)';

      % Create EminMeVEditField
      app.EminMeVEditField = uieditfield(app.ConstrainFitPanel, 'numeric');
      app.EminMeVEditField.Limits = [0.1 6.5];
      app.EminMeVEditField.ValueChangedFcn = createCallbackFcn(app, @EminMeVEditFieldValueChanged, true);
      app.EminMeVEditField.Position = [136 41 70 22];
      app.EminMeVEditField.Value = 3.5;

      % Create EmaxMeVEditFieldLabel
      app.EmaxMeVEditFieldLabel = uilabel(app.ConstrainFitPanel);
      app.EmaxMeVEditFieldLabel.HorizontalAlignment = 'right';
      app.EmaxMeVEditFieldLabel.Position = [52 11 70 22];
      app.EmaxMeVEditFieldLabel.Text = 'Emax (MeV)';

      % Create EmaxMeVEditField
      app.EmaxMeVEditField = uieditfield(app.ConstrainFitPanel, 'numeric');
      app.EmaxMeVEditField.Limits = [0.5 7];
      app.EmaxMeVEditField.ValueChangedFcn = createCallbackFcn(app, @EmaxMeVEditFieldValueChanged, true);
      app.EmaxMeVEditField.Position = [137 11 70 22];
      app.EmaxMeVEditField.Value = 6.5;

      % Create EnergyFitMeVPanel
      app.EnergyFitMeVPanel = uipanel(app.LAMEUIFigure);
      app.EnergyFitMeVPanel.TitlePosition = 'centertop';
      app.EnergyFitMeVPanel.Title = 'Energy Fit (MeV)';
      app.EnergyFitMeVPanel.Position = [16 16 234 139];

      % Create ClosestLabel
      app.ClosestLabel = uilabel(app.EnergyFitMeVPanel);
      app.ClosestLabel.HorizontalAlignment = 'right';
      app.ClosestLabel.Position = [33 82 48 22];
      app.ClosestLabel.Text = 'Closest';

      % Create ClosestEditField
      app.ClosestEditField = uieditfield(app.EnergyFitMeVPanel, 'numeric');
      app.ClosestEditField.Editable = 'off';
      app.ClosestEditField.Position = [96 82 102 22];

      % Create UseREditFieldLabel
      app.UseREditFieldLabel = uilabel(app.EnergyFitMeVPanel);
      app.UseREditFieldLabel.HorizontalAlignment = 'right';
      app.UseREditFieldLabel.Position = [38 49 40 22];
      app.UseREditFieldLabel.Text = 'Use R';

      % Create UseREditField
      app.UseREditField = uieditfield(app.EnergyFitMeVPanel, 'numeric');
      app.UseREditField.Editable = 'off';
      app.UseREditField.Position = [96 49 102 22];

      % Create UseThetaEditFieldLabel
      app.UseThetaEditFieldLabel = uilabel(app.EnergyFitMeVPanel);
      app.UseThetaEditFieldLabel.HorizontalAlignment = 'right';
      app.UseThetaEditFieldLabel.Position = [17 16 62 22];
      app.UseThetaEditFieldLabel.Text = 'Use Theta';

      % Create UseThetaEditField
      app.UseThetaEditField = uieditfield(app.EnergyFitMeVPanel, 'numeric');
      app.UseThetaEditField.Editable = 'off';
      app.UseThetaEditField.Position = [97 16 102 22];

      % Create PlotControlsPanel
      app.PlotControlsPanel = uipanel(app.LAMEUIFigure);
      app.PlotControlsPanel.Title = 'Plot Controls';
      app.PlotControlsPanel.Position = [269 20 487 67];

      % Create RotateButton
      app.RotateButton = uibutton(app.PlotControlsPanel, 'push');
      app.RotateButton.ButtonPushedFcn = createCallbackFcn(app, @RotateButtonPushed, true);
      app.RotateButton.Position = [13 12 100 22];
      app.RotateButton.Text = 'Rotate';

      % Create ZoomButton
      app.ZoomButton = uibutton(app.PlotControlsPanel, 'push');
      app.ZoomButton.ButtonPushedFcn = createCallbackFcn(app, @ZoomButtonPushed, true);
      app.ZoomButton.Position = [135 12 100 22];
      app.ZoomButton.Text = 'Zoom';

      % Create PanButton
      app.PanButton = uibutton(app.PlotControlsPanel, 'push');
      app.PanButton.ButtonPushedFcn = createCallbackFcn(app, @PanButtonPushed, true);
      app.PanButton.Position = [254 12 100 22];
      app.PanButton.Text = 'Pan';

      % Create DetachButton
      app.DetachButton = uibutton(app.PlotControlsPanel, 'push');
      app.DetachButton.ButtonPushedFcn = createCallbackFcn(app, @DetachButtonPushed, true);
      app.DetachButton.Position = [369 11 100 22];
      app.DetachButton.Text = 'Detach';

      % Create ParametersValidLampLabel
      app.ParametersValidLampLabel = uilabel(app.LAMEUIFigure);
      app.ParametersValidLampLabel.HorizontalAlignment = 'right';
      app.ParametersValidLampLabel.Position = [908 32 97 22];
      app.ParametersValidLampLabel.Text = 'Parameters Valid';

      % Create ParametersValidLamp
      app.ParametersValidLamp = uilamp(app.LAMEUIFigure);
      app.ParametersValidLamp.Position = [1020 32 20 20];

      % Create HelpButton
      app.HelpButton = uibutton(app.LAMEUIFigure, 'push');
      app.HelpButton.ButtonPushedFcn = createCallbackFcn(app, @HelpButtonPushed, true);
      app.HelpButton.Position = [780 31 100 22];
      app.HelpButton.Text = 'Help';

      % Create FACETIIGunLarmorAngleMeasurementofEnergyLabel
      app.FACETIIGunLarmorAngleMeasurementofEnergyLabel = uilabel(app.LAMEUIFigure);
      app.FACETIIGunLarmorAngleMeasurementofEnergyLabel.HorizontalAlignment = 'center';
      app.FACETIIGunLarmorAngleMeasurementofEnergyLabel.FontSize = 16;
      app.FACETIIGunLarmorAngleMeasurementofEnergyLabel.FontWeight = 'bold';
      app.FACETIIGunLarmorAngleMeasurementofEnergyLabel.FontColor = [0 0.451 0.7412];
      app.FACETIIGunLarmorAngleMeasurementofEnergyLabel.Position = [448 616 414 22];
      app.FACETIIGunLarmorAngleMeasurementofEnergyLabel.Text = 'FACET-II Gun: Larmor Angle Measurement of Energy';

      % Create UIAxes
      app.UIAxes = uiaxes(app.LAMEUIFigure);
      xlabel(app.UIAxes, 'X')
      ylabel(app.UIAxes, 'Y')
      app.UIAxes.Position = [261 98 787 482];

      % Show the figure after all components are created
      app.LAMEUIFigure.Visible = 'on';
    end
  end

  % App creation and deletion
  methods (Access = public)

    % Construct app
    function app = F2_LAME_exported(varargin)

      % Create UIFigure and components
      createComponents(app)

      % Register the app with App Designer
      registerApp(app, app.LAMEUIFigure)

      % Execute the startup function
      runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

      if nargout == 0
        clear app
      end
    end

    % Code that executes before app deletion
    function delete(app)

      % Delete UIFigure when app is deleted
      delete(app.LAMEUIFigure)
    end
  end
end