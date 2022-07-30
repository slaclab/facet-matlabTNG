classdef F2_SpecLine_exported < matlab.apps.AppBase

  % Properties that correspond to app components
  properties (Access = public)
    UIFigure                     matlab.ui.Figure
    SpectrometerParametersPanel  matlab.ui.container.Panel
    EnergyGeVEditFieldLabel      matlab.ui.control.Label
    EnergyEditField              matlab.ui.control.NumericEditField
    ZObjectmEditFieldLabel       matlab.ui.control.Label
    ZObjectEditField             matlab.ui.control.NumericEditField
    ZImagemEditFieldLabel        matlab.ui.control.Label
    ZImageEditField              matlab.ui.control.NumericEditField
    M12EditFieldLabel            matlab.ui.control.Label
    M12EditField                 matlab.ui.control.NumericEditField
    M34EditFieldLabel            matlab.ui.control.Label
    M34EditField                 matlab.ui.control.NumericEditField
    CalcButton                   matlab.ui.control.Button
    DipoleSwitchLabel            matlab.ui.control.Label
    DipoleSwitch                 matlab.ui.control.Switch
    MagnetValuesPanel            matlab.ui.container.Panel
    Q0DLGPS3141EditFieldLabel    matlab.ui.control.Label
    Q0DBDESEditField             matlab.ui.control.NumericEditField
    Q0DBACTField                 matlab.ui.control.NumericEditField
    BDESLabel                    matlab.ui.control.Label
    BACTLabel                    matlab.ui.control.Label
    Q1DLGPS3261EditFieldLabel    matlab.ui.control.Label
    Q1DBDESEditField             matlab.ui.control.NumericEditField
    Q1DBACTField                 matlab.ui.control.NumericEditField
    Q2DLGPS3091EditFieldLabel    matlab.ui.control.Label
    Q2DBDESEditField             matlab.ui.control.NumericEditField
    Q2DBACTField                 matlab.ui.control.NumericEditField
    TrimButton                   matlab.ui.control.Button
    B5DBACTField                 matlab.ui.control.NumericEditField
    B5DLGPS3330Label             matlab.ui.control.Label
    B5DBDESEditField             matlab.ui.control.NumericEditField
  end

    
    properties (Access = private)
        aobj % Description
    end
    

  % Callbacks that handle component events
  methods (Access = private)

    % Code that executes after component creation
    function startupFcn(app)
            app.aobj=F2_SpecLineApp(app);
            if lcaGetSmart('SIOC:SYS1:ML00:CALCOUT056')
                app.DipoleSwitch.Value = 'With';
            else
                app.DipoleSwitch.Value = 'Without';
            end
    end

    % Button pushed function: CalcButton
    function CalcButtonPushed(app, event)
            app.aobj.CalcAndTrim();
    end

    % Value changed function: DipoleSwitch
    function DipoleSwitchValueChanged(app, event)
      if strcmp(app.DipoleSwitch.Value, 'With')
        lcaPutSmart('SIOC:SYS1:ML00:CALCOUT056', 1);
      else
        lcaPutSmart('SIOC:SYS1:ML00:CALCOUT056', 0);
      end
    end
  end

  % Component initialization
  methods (Access = private)

    % Create UIFigure and components
    function createComponents(app)

      % Create UIFigure and hide until all components are created
      app.UIFigure = uifigure('Visible', 'off');
      app.UIFigure.Position = [100 100 523 334];
      app.UIFigure.Name = 'MATLAB App';

      % Create SpectrometerParametersPanel
      app.SpectrometerParametersPanel = uipanel(app.UIFigure);
      app.SpectrometerParametersPanel.Title = 'Spectrometer Parameters';
      app.SpectrometerParametersPanel.Position = [2 3 260 332];

      % Create EnergyGeVEditFieldLabel
      app.EnergyGeVEditFieldLabel = uilabel(app.SpectrometerParametersPanel);
      app.EnergyGeVEditFieldLabel.HorizontalAlignment = 'right';
      app.EnergyGeVEditFieldLabel.Position = [42 277 79 22];
      app.EnergyGeVEditFieldLabel.Text = 'Energy (GeV)';

      % Create EnergyEditField
      app.EnergyEditField = uieditfield(app.SpectrometerParametersPanel, 'numeric');
      app.EnergyEditField.ValueDisplayFormat = '%11.4f';
      app.EnergyEditField.Position = [146 277 73 22];

      % Create ZObjectmEditFieldLabel
      app.ZObjectmEditFieldLabel = uilabel(app.SpectrometerParametersPanel);
      app.ZObjectmEditFieldLabel.HorizontalAlignment = 'right';
      app.ZObjectmEditFieldLabel.Position = [50 242 71 22];
      app.ZObjectmEditFieldLabel.Text = 'Z Object (m)';

      % Create ZObjectEditField
      app.ZObjectEditField = uieditfield(app.SpectrometerParametersPanel, 'numeric');
      app.ZObjectEditField.ValueDisplayFormat = '%11.4f';
      app.ZObjectEditField.Position = [146 242 73 22];

      % Create ZImagemEditFieldLabel
      app.ZImagemEditFieldLabel = uilabel(app.SpectrometerParametersPanel);
      app.ZImagemEditFieldLabel.HorizontalAlignment = 'right';
      app.ZImagemEditFieldLabel.Position = [51 208 70 22];
      app.ZImagemEditFieldLabel.Text = 'Z Image (m)';

      % Create ZImageEditField
      app.ZImageEditField = uieditfield(app.SpectrometerParametersPanel, 'numeric');
      app.ZImageEditField.ValueDisplayFormat = '%11.4f';
      app.ZImageEditField.Position = [146 208 73 22];

      % Create M12EditFieldLabel
      app.M12EditFieldLabel = uilabel(app.SpectrometerParametersPanel);
      app.M12EditFieldLabel.HorizontalAlignment = 'right';
      app.M12EditFieldLabel.Position = [92 174 29 22];
      app.M12EditFieldLabel.Text = 'M12';

      % Create M12EditField
      app.M12EditField = uieditfield(app.SpectrometerParametersPanel, 'numeric');
      app.M12EditField.ValueDisplayFormat = '%11.4f';
      app.M12EditField.Position = [146 174 73 22];

      % Create M34EditFieldLabel
      app.M34EditFieldLabel = uilabel(app.SpectrometerParametersPanel);
      app.M34EditFieldLabel.HorizontalAlignment = 'right';
      app.M34EditFieldLabel.Position = [92 140 29 22];
      app.M34EditFieldLabel.Text = 'M34';

      % Create M34EditField
      app.M34EditField = uieditfield(app.SpectrometerParametersPanel, 'numeric');
      app.M34EditField.ValueDisplayFormat = '%11.4f';
      app.M34EditField.Position = [146 140 73 22];

      % Create CalcButton
      app.CalcButton = uibutton(app.SpectrometerParametersPanel, 'push');
      app.CalcButton.ButtonPushedFcn = createCallbackFcn(app, @CalcButtonPushed, true);
      app.CalcButton.BackgroundColor = [0 0.4471 0.7412];
      app.CalcButton.FontSize = 14;
      app.CalcButton.FontWeight = 'bold';
      app.CalcButton.FontColor = [1 1 1];
      app.CalcButton.Position = [59 19 143 24];
      app.CalcButton.Text = 'Calculate and Trim';

      % Create DipoleSwitchLabel
      app.DipoleSwitchLabel = uilabel(app.SpectrometerParametersPanel);
      app.DipoleSwitchLabel.HorizontalAlignment = 'center';
      app.DipoleSwitchLabel.FontSize = 14;
      app.DipoleSwitchLabel.FontWeight = 'bold';
      app.DipoleSwitchLabel.Position = [113 90 49 22];
      app.DipoleSwitchLabel.Text = 'Dipole';

      % Create DipoleSwitch
      app.DipoleSwitch = uiswitch(app.SpectrometerParametersPanel, 'slider');
      app.DipoleSwitch.Items = {'Without', 'With'};
      app.DipoleSwitch.ValueChangedFcn = createCallbackFcn(app, @DipoleSwitchValueChanged, true);
      app.DipoleSwitch.Position = [109 63 56 25];
      app.DipoleSwitch.Value = 'Without';

      % Create MagnetValuesPanel
      app.MagnetValuesPanel = uipanel(app.UIFigure);
      app.MagnetValuesPanel.Title = 'Magnet Values';
      app.MagnetValuesPanel.Position = [262 3 260 332];

      % Create Q0DLGPS3141EditFieldLabel
      app.Q0DLGPS3141EditFieldLabel = uilabel(app.MagnetValuesPanel);
      app.Q0DLGPS3141EditFieldLabel.HorizontalAlignment = 'right';
      app.Q0DLGPS3141EditFieldLabel.Position = [15 211 104 22];
      app.Q0DLGPS3141EditFieldLabel.Text = 'Q0D (LGPS 3141)';

      % Create Q0DBDESEditField
      app.Q0DBDESEditField = uieditfield(app.MagnetValuesPanel, 'numeric');
      app.Q0DBDESEditField.Position = [127 211 47 22];

      % Create Q0DBACTField
      app.Q0DBACTField = uieditfield(app.MagnetValuesPanel, 'numeric');
      app.Q0DBACTField.Editable = 'off';
      app.Q0DBACTField.Position = [195 211 45 22];

      % Create BDESLabel
      app.BDESLabel = uilabel(app.MagnetValuesPanel);
      app.BDESLabel.FontWeight = 'bold';
      app.BDESLabel.Position = [134 246 39 22];
      app.BDESLabel.Text = 'BDES';

      % Create BACTLabel
      app.BACTLabel = uilabel(app.MagnetValuesPanel);
      app.BACTLabel.FontWeight = 'bold';
      app.BACTLabel.Position = [199 246 39 22];
      app.BACTLabel.Text = 'BACT';

      % Create Q1DLGPS3261EditFieldLabel
      app.Q1DLGPS3261EditFieldLabel = uilabel(app.MagnetValuesPanel);
      app.Q1DLGPS3261EditFieldLabel.HorizontalAlignment = 'right';
      app.Q1DLGPS3261EditFieldLabel.Position = [15 177 104 22];
      app.Q1DLGPS3261EditFieldLabel.Text = 'Q1D (LGPS 3261)';

      % Create Q1DBDESEditField
      app.Q1DBDESEditField = uieditfield(app.MagnetValuesPanel, 'numeric');
      app.Q1DBDESEditField.Position = [127 177 47 22];

      % Create Q1DBACTField
      app.Q1DBACTField = uieditfield(app.MagnetValuesPanel, 'numeric');
      app.Q1DBACTField.Editable = 'off';
      app.Q1DBACTField.Position = [195 177 45 22];

      % Create Q2DLGPS3091EditFieldLabel
      app.Q2DLGPS3091EditFieldLabel = uilabel(app.MagnetValuesPanel);
      app.Q2DLGPS3091EditFieldLabel.HorizontalAlignment = 'right';
      app.Q2DLGPS3091EditFieldLabel.Position = [15 143 104 22];
      app.Q2DLGPS3091EditFieldLabel.Text = 'Q2D (LGPS 3091)';

      % Create Q2DBDESEditField
      app.Q2DBDESEditField = uieditfield(app.MagnetValuesPanel, 'numeric');
      app.Q2DBDESEditField.Position = [127 143 47 22];

      % Create Q2DBACTField
      app.Q2DBACTField = uieditfield(app.MagnetValuesPanel, 'numeric');
      app.Q2DBACTField.Editable = 'off';
      app.Q2DBACTField.Position = [195 143 45 22];

      % Create TrimButton
      app.TrimButton = uibutton(app.MagnetValuesPanel, 'push');
      app.TrimButton.BackgroundColor = [0.6353 0.0784 0.1843];
      app.TrimButton.FontSize = 14;
      app.TrimButton.FontWeight = 'bold';
      app.TrimButton.FontColor = [1 1 1];
      app.TrimButton.Position = [112 47 50 24];
      app.TrimButton.Text = 'Trim';

      % Create B5DBACTField
      app.B5DBACTField = uieditfield(app.MagnetValuesPanel, 'numeric');
      app.B5DBACTField.Editable = 'off';
      app.B5DBACTField.Position = [195 109 45 22];

      % Create B5DLGPS3330Label
      app.B5DLGPS3330Label = uilabel(app.MagnetValuesPanel);
      app.B5DLGPS3330Label.HorizontalAlignment = 'right';
      app.B5DLGPS3330Label.Position = [16 109 103 22];
      app.B5DLGPS3330Label.Text = 'B5D (LGPS 3330)';

      % Create B5DBDESEditField
      app.B5DBDESEditField = uieditfield(app.MagnetValuesPanel, 'numeric');
      app.B5DBDESEditField.Position = [127 109 47 22];

      % Show the figure after all components are created
      app.UIFigure.Visible = 'on';
    end
  end

  % App creation and deletion
  methods (Access = public)

    % Construct app
    function app = F2_SpecLine_exported

      % Create UIFigure and components
      createComponents(app)

      % Register the app with App Designer
      registerApp(app, app.UIFigure)

      % Execute the startup function
      runStartupFcn(app, @startupFcn)

      if nargout == 0
        clear app
      end
    end

    % Code that executes before app deletion
    function delete(app)

      % Delete UIFigure when app is deleted
      delete(app.UIFigure)
    end
  end
end