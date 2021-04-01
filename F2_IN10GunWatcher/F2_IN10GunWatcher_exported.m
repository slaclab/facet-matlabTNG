classdef F2_IN10GunWatcher_exported < matlab.apps.AppBase

  % Properties that correspond to app components
  properties (Access = public)
    UIFigure                     matlab.ui.Figure
    GridLayout                   matlab.ui.container.GridLayout
    LeftPanel                    matlab.ui.container.Panel
    MaxPWRMWEditFieldLabel       matlab.ui.control.Label
    MaxPWRMWEditField            matlab.ui.control.NumericEditField
    StateEditFieldLabel          matlab.ui.control.Label
    StateEditField               matlab.ui.control.NumericEditField
    HeartbeatEditFieldLabel      matlab.ui.control.Label
    HeartbeatEditField           matlab.ui.control.NumericEditField
    PowerConversionVMWEditFieldLabel  matlab.ui.control.Label
    PowerConversionVMWEditField  matlab.ui.control.NumericEditField
    GunPwrPVMWPanel              matlab.ui.container.Panel
    GunPwrPVMWGauge              matlab.ui.control.LinearGauge
    EditField                    matlab.ui.control.NumericEditField
    GunPwrScopeMWPanel           matlab.ui.container.Panel
    GunPwrPVMWGauge_2            matlab.ui.control.LinearGauge
    EditField_2                  matlab.ui.control.NumericEditField
    EnableEditFieldLabel         matlab.ui.control.Label
    EnableEditField              matlab.ui.control.NumericEditField
    PowerConversionVOffsetEditFieldLabel  matlab.ui.control.Label
    PowerConversionVOffsetEditField  matlab.ui.control.NumericEditField
    RFONLampLabel                matlab.ui.control.Label
    RFONLamp                     matlab.ui.control.Lamp
    NAVEEditFieldLabel           matlab.ui.control.Label
    NAVEEditField                matlab.ui.control.NumericEditField
    RightPanel                   matlab.ui.container.Panel
    UIAxes                       matlab.ui.control.UIAxes
    QnCFC1Panel                  matlab.ui.container.Panel
    EditField_3                  matlab.ui.control.NumericEditField
    QEFC1Panel                   matlab.ui.container.Panel
    EditField_4                  matlab.ui.control.NumericEditField
    QnCFC2Panel                  matlab.ui.container.Panel
    EditField_5                  matlab.ui.control.NumericEditField
    QEFC2Panel                   matlab.ui.container.Panel
    EditField_6                  matlab.ui.control.NumericEditField
  end

  % Properties that correspond to apps with auto-reflow
  properties (Access = private)
    onePanelWidth = 576;
  end

  
  properties (Access = public)
    aobj % Application helper object
  end
  

  % Callbacks that handle component events
  methods (Access = private)

    % Code that executes after component creation
    function startupFcn(app, arg1)
      app.aobj=F2_IN10GunWatcherApp(app);
    end

    % Changes arrangement of the app based on UIFigure width
    function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {382, 382};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {349, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
    end
  end

  % Component initialization
  methods (Access = private)

    % Create UIFigure and components
    function createComponents(app)

      % Create UIFigure and hide until all components are created
      app.UIFigure = uifigure('Visible', 'off');
      app.UIFigure.AutoResizeChildren = 'off';
      app.UIFigure.Position = [100 100 910 382];
      app.UIFigure.Name = 'MATLAB App';
      app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

      % Create GridLayout
      app.GridLayout = uigridlayout(app.UIFigure);
      app.GridLayout.ColumnWidth = {349, '1x'};
      app.GridLayout.RowHeight = {'1x'};
      app.GridLayout.ColumnSpacing = 0;
      app.GridLayout.RowSpacing = 0;
      app.GridLayout.Padding = [0 0 0 0];
      app.GridLayout.Scrollable = 'on';

      % Create LeftPanel
      app.LeftPanel = uipanel(app.GridLayout);
      app.LeftPanel.Layout.Row = 1;
      app.LeftPanel.Layout.Column = 1;

      % Create MaxPWRMWEditFieldLabel
      app.MaxPWRMWEditFieldLabel = uilabel(app.LeftPanel);
      app.MaxPWRMWEditFieldLabel.HorizontalAlignment = 'right';
      app.MaxPWRMWEditFieldLabel.Position = [26 306 90 22];
      app.MaxPWRMWEditFieldLabel.Text = 'Max PWR (MW)';

      % Create MaxPWRMWEditField
      app.MaxPWRMWEditField = uieditfield(app.LeftPanel, 'numeric');
      app.MaxPWRMWEditField.Position = [131 306 100 22];

      % Create StateEditFieldLabel
      app.StateEditFieldLabel = uilabel(app.LeftPanel);
      app.StateEditFieldLabel.HorizontalAlignment = 'right';
      app.StateEditFieldLabel.Position = [26 274 34 22];
      app.StateEditFieldLabel.Text = 'State';

      % Create StateEditField
      app.StateEditField = uieditfield(app.LeftPanel, 'numeric');
      app.StateEditField.Position = [75 274 49 22];

      % Create HeartbeatEditFieldLabel
      app.HeartbeatEditFieldLabel = uilabel(app.LeftPanel);
      app.HeartbeatEditFieldLabel.HorizontalAlignment = 'right';
      app.HeartbeatEditFieldLabel.Position = [26 242 59 22];
      app.HeartbeatEditFieldLabel.Text = 'Heartbeat';

      % Create HeartbeatEditField
      app.HeartbeatEditField = uieditfield(app.LeftPanel, 'numeric');
      app.HeartbeatEditField.Position = [100 242 100 22];

      % Create PowerConversionVMWEditFieldLabel
      app.PowerConversionVMWEditFieldLabel = uilabel(app.LeftPanel);
      app.PowerConversionVMWEditFieldLabel.HorizontalAlignment = 'right';
      app.PowerConversionVMWEditFieldLabel.Position = [26 210 139 22];
      app.PowerConversionVMWEditFieldLabel.Text = 'Power Conversion V:MW';

      % Create PowerConversionVMWEditField
      app.PowerConversionVMWEditField = uieditfield(app.LeftPanel, 'numeric');
      app.PowerConversionVMWEditField.Position = [180 210 100 22];

      % Create GunPwrPVMWPanel
      app.GunPwrPVMWPanel = uipanel(app.LeftPanel);
      app.GunPwrPVMWPanel.Title = 'Gun Pwr (PV) [MW]';
      app.GunPwrPVMWPanel.Position = [10 59 159 102];

      % Create GunPwrPVMWGauge
      app.GunPwrPVMWGauge = uigauge(app.GunPwrPVMWPanel, 'linear');
      app.GunPwrPVMWGauge.Position = [7 36 145 40];

      % Create EditField
      app.EditField = uieditfield(app.GunPwrPVMWPanel, 'numeric');
      app.EditField.HorizontalAlignment = 'center';
      app.EditField.Position = [7 7 145 22];

      % Create GunPwrScopeMWPanel
      app.GunPwrScopeMWPanel = uipanel(app.LeftPanel);
      app.GunPwrScopeMWPanel.Title = 'Gun Pwr (Scope) [MW]';
      app.GunPwrScopeMWPanel.Position = [180 59 159 102];

      % Create GunPwrPVMWGauge_2
      app.GunPwrPVMWGauge_2 = uigauge(app.GunPwrScopeMWPanel, 'linear');
      app.GunPwrPVMWGauge_2.Position = [7 36 145 40];

      % Create EditField_2
      app.EditField_2 = uieditfield(app.GunPwrScopeMWPanel, 'numeric');
      app.EditField_2.HorizontalAlignment = 'center';
      app.EditField_2.Position = [7 7 145 22];

      % Create EnableEditFieldLabel
      app.EnableEditFieldLabel = uilabel(app.LeftPanel);
      app.EnableEditFieldLabel.HorizontalAlignment = 'right';
      app.EnableEditFieldLabel.Position = [26 338 44 22];
      app.EnableEditFieldLabel.Text = 'Enable';

      % Create EnableEditField
      app.EnableEditField = uieditfield(app.LeftPanel, 'numeric');
      app.EnableEditField.Position = [90 338 38 22];

      % Create PowerConversionVOffsetEditFieldLabel
      app.PowerConversionVOffsetEditFieldLabel = uilabel(app.LeftPanel);
      app.PowerConversionVOffsetEditFieldLabel.HorizontalAlignment = 'right';
      app.PowerConversionVOffsetEditFieldLabel.Position = [26 178 151 22];
      app.PowerConversionVOffsetEditFieldLabel.Text = 'Power Conversion V Offset';

      % Create PowerConversionVOffsetEditField
      app.PowerConversionVOffsetEditField = uieditfield(app.LeftPanel, 'numeric');
      app.PowerConversionVOffsetEditField.Position = [192 178 100 22];
      app.PowerConversionVOffsetEditField.Value = -3.2;

      % Create RFONLampLabel
      app.RFONLampLabel = uilabel(app.LeftPanel);
      app.RFONLampLabel.HorizontalAlignment = 'right';
      app.RFONLampLabel.Position = [240 338 42 22];
      app.RFONLampLabel.Text = 'RF ON';

      % Create RFONLamp
      app.RFONLamp = uilamp(app.LeftPanel);
      app.RFONLamp.Position = [297 338 20 20];

      % Create NAVEEditFieldLabel
      app.NAVEEditFieldLabel = uilabel(app.LeftPanel);
      app.NAVEEditFieldLabel.HorizontalAlignment = 'right';
      app.NAVEEditFieldLabel.Position = [158 17 44 22];
      app.NAVEEditFieldLabel.Text = 'N AVE:';

      % Create NAVEEditField
      app.NAVEEditField = uieditfield(app.LeftPanel, 'numeric');
      app.NAVEEditField.Position = [217 17 100 22];
      app.NAVEEditField.Value = 10;

      % Create RightPanel
      app.RightPanel = uipanel(app.GridLayout);
      app.RightPanel.Layout.Row = 1;
      app.RightPanel.Layout.Column = 2;

      % Create UIAxes
      app.UIAxes = uiaxes(app.RightPanel);
      title(app.UIAxes, 'SCOP:IN10:FC01')
      xlabel(app.UIAxes, 't [ns]')
      ylabel(app.UIAxes, 'V')
      zlabel(app.UIAxes, 'Z')
      app.UIAxes.FontSize = 14;
      app.UIAxes.Position = [7 71 532 289];

      % Create QnCFC1Panel
      app.QnCFC1Panel = uipanel(app.RightPanel);
      app.QnCFC1Panel.Title = 'Q [nC] FC1';
      app.QnCFC1Panel.Position = [14 11 124 53];

      % Create EditField_3
      app.EditField_3 = uieditfield(app.QnCFC1Panel, 'numeric');
      app.EditField_3.Position = [8 6 100 22];

      % Create QEFC1Panel
      app.QEFC1Panel = uipanel(app.RightPanel);
      app.QEFC1Panel.Title = 'QE FC1';
      app.QEFC1Panel.Position = [145 11 124 53];

      % Create EditField_4
      app.EditField_4 = uieditfield(app.QEFC1Panel, 'numeric');
      app.EditField_4.Position = [10 6 100 22];

      % Create QnCFC2Panel
      app.QnCFC2Panel = uipanel(app.RightPanel);
      app.QnCFC2Panel.Title = 'Q [nC] FC2';
      app.QnCFC2Panel.Position = [285 11 124 53];

      % Create EditField_5
      app.EditField_5 = uieditfield(app.QnCFC2Panel, 'numeric');
      app.EditField_5.Position = [8 6 100 22];

      % Create QEFC2Panel
      app.QEFC2Panel = uipanel(app.RightPanel);
      app.QEFC2Panel.Title = 'QE FC2';
      app.QEFC2Panel.Position = [416 11 124 53];

      % Create EditField_6
      app.EditField_6 = uieditfield(app.QEFC2Panel, 'numeric');
      app.EditField_6.Position = [10 6 100 22];

      % Show the figure after all components are created
      app.UIFigure.Visible = 'on';
    end
  end

  % App creation and deletion
  methods (Access = public)

    % Construct app
    function app = F2_IN10GunWatcher_exported(varargin)

      % Create UIFigure and components
      createComponents(app)

      % Register the app with App Designer
      registerApp(app, app.UIFigure)

      % Execute the startup function
      runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

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