classdef BC11BL_Settings_exported < matlab.apps.AppBase

  % Properties that correspond to app components
  properties (Access = public)
    FeedbackSettingsUIFigure       matlab.ui.Figure
    GridLayout                     matlab.ui.container.GridLayout
    LeftPanel                      matlab.ui.container.Panel
    GainEditFieldLabel             matlab.ui.control.Label
    GainEditField                  matlab.ui.control.NumericEditField
    BC11BLENFeedbackSettingsLabel  matlab.ui.control.Label
    ControlVariableL1BLENVernierLimitsPanel  matlab.ui.container.Panel
    EditField                      matlab.ui.control.NumericEditField
    EditField_2                    matlab.ui.control.NumericEditField
    LowLabel                       matlab.ui.control.Label
    HighLabel                      matlab.ui.control.Label
    SetpointBLEN11359SaturationLimitsmmPanel  matlab.ui.container.Panel
    EditField_3                    matlab.ui.control.NumericEditField
    EditField_4                    matlab.ui.control.NumericEditField
    LowLabel_2                     matlab.ui.control.Label
    HighLabel_2                    matlab.ui.control.Label
    SetpointFilterFreqHz0OFFEditFieldLabel  matlab.ui.control.Label
    FilterFreqEditField            matlab.ui.control.NumericEditField
    SetpointBLEN11359DeadbandLimitsmmPanel  matlab.ui.container.Panel
    EditField_5                    matlab.ui.control.NumericEditField
    EditField_6                    matlab.ui.control.NumericEditField
    LowLabel_3                     matlab.ui.control.Label
    HighLabel_3                    matlab.ui.control.Label
    SetpointBPM11358TMITLimitsNe9Panel  matlab.ui.container.Panel
    EditField_7                    matlab.ui.control.NumericEditField
    EditField_8                    matlab.ui.control.NumericEditField
    LowLabel_4                     matlab.ui.control.Label
    HighLabel_4                    matlab.ui.control.Label
    RightPanel                     matlab.ui.container.Panel
    UIAxes                         matlab.ui.control.UIAxes
  end

  % Properties that correspond to apps with auto-reflow
  properties (Access = private)
    onePanelWidth = 576;
  end

  
  properties (Access = private)
    aobj % Feedback application object
  end
  

  % Callbacks that handle component events
  methods (Access = private)

    % Code that executes after component creation
    function startupFcn(app, FeedbackApp)
      app.aobj = FeedbackApp ;
      app.aobj.SettingsGui = app ;
      app.aobj.SettingsGui_whichFeedback = 4 ;
      app.aobj.Feedbacks(4).SetpointVar.axhan=app.UIAxes;
      app.aobj.Feedbacks(4).SetpointVar.StripPlot=true;
      gh.BC11BL_Gain = app.GainEditField ;
      gh.BC11BL_ControlLimitLo = app.EditField ;
      gh.BC11BL_ControlLimitHi = app.EditField_2 ;
      gh.BC11BL_SetpointLimitLo = app.EditField_3 ;
      gh.BC11BL_SetpointLimitHi = app.EditField_4 ;
      gh.BC11BL_SetpointFilterFreq = app.FilterFreqEditField ;
      gh.BC11BL_SetpointDeadbandLo = app.EditField_5 ;
      gh.BC11BL_SetpointDeadbandHi = app.EditField_6 ;
      gh.BC11BL_TMITLo = app.EditField_7 ;
      gh.BC11BL_TMITHi = app.EditField_8 ;
      app.aobj.SettingsGuiLink(gh,"Attach");
      fn=fieldnames(gh);
      for ifn=1:length(fn)
        gh.(fn{ifn}).Value = app.aobj.pvs.(fn{ifn}).val{1} ;
      end
    end

    % Close request function: FeedbackSettingsUIFigure
    function FeedbackSettingsUIFigureCloseRequest(app, event)
      gh.BC11BL_Gain = app.GainEditField ;
      gh.BC11BL_ControlLimitLo = app.EditField ;
      gh.BC11BL_ControlLimitHi = app.EditField_2 ;
      gh.BC11BL_SetpointLimitLo = app.EditField_3 ;
      gh.BC11BL_SetpointLimitHi = app.EditField_4 ;
      gh.BC11BL_SetpointFilterFreq = app.FilterFreqEditField ;
      gh.BC11BL_SetpointDeadbandLo = app.EditField_5 ;
      gh.BC11BL_SetpointDeadbandHi = app.EditField_6 ;
      gh.BC11BL_TMITLo = app.EditField_7 ;
      gh.BC11BL_TMITHi = app.EditField_8 ;
      app.aobj.SettingsGuiLink(gh,"Detach");
      app.aobj.Feedbacks(4).SetpointVar.StripPlot=false;
      app.aobj.Feedbacks(4).SetpointVar.axhan=[];
      app.aobj.SettingsGui=[];
      app.aobj.SettingsGui_whichFeedback = 0 ;
      app.aobj.guihan.BC11EnergyFeedbackMenu.Enable = true ;
      delete(app)
    end

    % Changes arrangement of the app based on UIFigure width
    function updateAppLayout(app, event)
            currentFigureWidth = app.FeedbackSettingsUIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {484, 484};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {293, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
    end
  end

  % Component initialization
  methods (Access = private)

    % Create UIFigure and components
    function createComponents(app)

      % Create FeedbackSettingsUIFigure and hide until all components are created
      app.FeedbackSettingsUIFigure = uifigure('Visible', 'off');
      app.FeedbackSettingsUIFigure.AutoResizeChildren = 'off';
      app.FeedbackSettingsUIFigure.Position = [100 100 891 484];
      app.FeedbackSettingsUIFigure.Name = 'Feedback Settings';
      app.FeedbackSettingsUIFigure.CloseRequestFcn = createCallbackFcn(app, @FeedbackSettingsUIFigureCloseRequest, true);
      app.FeedbackSettingsUIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

      % Create GridLayout
      app.GridLayout = uigridlayout(app.FeedbackSettingsUIFigure);
      app.GridLayout.ColumnWidth = {293, '1x'};
      app.GridLayout.RowHeight = {'1x'};
      app.GridLayout.ColumnSpacing = 0;
      app.GridLayout.RowSpacing = 0;
      app.GridLayout.Padding = [0 0 0 0];
      app.GridLayout.Scrollable = 'on';

      % Create LeftPanel
      app.LeftPanel = uipanel(app.GridLayout);
      app.LeftPanel.Layout.Row = 1;
      app.LeftPanel.Layout.Column = 1;

      % Create GainEditFieldLabel
      app.GainEditFieldLabel = uilabel(app.LeftPanel);
      app.GainEditFieldLabel.HorizontalAlignment = 'right';
      app.GainEditFieldLabel.Position = [76 417 31 22];
      app.GainEditFieldLabel.Text = 'Gain';

      % Create GainEditField
      app.GainEditField = uieditfield(app.LeftPanel, 'numeric');
      app.GainEditField.Position = [122 417 100 22];
      app.GainEditField.Value = 1;

      % Create BC11BLENFeedbackSettingsLabel
      app.BC11BLENFeedbackSettingsLabel = uilabel(app.LeftPanel);
      app.BC11BLENFeedbackSettingsLabel.FontSize = 18;
      app.BC11BLENFeedbackSettingsLabel.FontWeight = 'bold';
      app.BC11BLENFeedbackSettingsLabel.FontColor = [0.851 0.3255 0.098];
      app.BC11BLENFeedbackSettingsLabel.Position = [11 450 272 23];
      app.BC11BLENFeedbackSettingsLabel.Text = 'BC11 BLEN Feedback Settings';

      % Create ControlVariableL1BLENVernierLimitsPanel
      app.ControlVariableL1BLENVernierLimitsPanel = uipanel(app.LeftPanel);
      app.ControlVariableL1BLENVernierLimitsPanel.Title = 'Control Variable: L1 BLEN Vernier Limits';
      app.ControlVariableL1BLENVernierLimitsPanel.Position = [17 322 260 85];

      % Create EditField
      app.EditField = uieditfield(app.ControlVariableL1BLENVernierLimitsPanel, 'numeric');
      app.EditField.HorizontalAlignment = 'center';
      app.EditField.Position = [13 17 100 22];
      app.EditField.Value = -180;

      % Create EditField_2
      app.EditField_2 = uieditfield(app.ControlVariableL1BLENVernierLimitsPanel, 'numeric');
      app.EditField_2.HorizontalAlignment = 'center';
      app.EditField_2.Position = [138 17 100 22];
      app.EditField_2.Value = 180;

      % Create LowLabel
      app.LowLabel = uilabel(app.ControlVariableL1BLENVernierLimitsPanel);
      app.LowLabel.Position = [49 38 28 22];
      app.LowLabel.Text = 'Low';

      % Create HighLabel
      app.HighLabel = uilabel(app.ControlVariableL1BLENVernierLimitsPanel);
      app.HighLabel.Position = [174 38 31 22];
      app.HighLabel.Text = 'High';

      % Create SetpointBLEN11359SaturationLimitsmmPanel
      app.SetpointBLEN11359SaturationLimitsmmPanel = uipanel(app.LeftPanel);
      app.SetpointBLEN11359SaturationLimitsmmPanel.Title = 'Setpoint: BLEN11359 Saturation Limits [mm]';
      app.SetpointBLEN11359SaturationLimitsmmPanel.Position = [17 232 260 85];

      % Create EditField_3
      app.EditField_3 = uieditfield(app.SetpointBLEN11359SaturationLimitsmmPanel, 'numeric');
      app.EditField_3.HorizontalAlignment = 'center';
      app.EditField_3.Position = [13 17 100 22];

      % Create EditField_4
      app.EditField_4 = uieditfield(app.SetpointBLEN11359SaturationLimitsmmPanel, 'numeric');
      app.EditField_4.HorizontalAlignment = 'center';
      app.EditField_4.Position = [138 17 100 22];
      app.EditField_4.Value = 10;

      % Create LowLabel_2
      app.LowLabel_2 = uilabel(app.SetpointBLEN11359SaturationLimitsmmPanel);
      app.LowLabel_2.Position = [49 38 28 22];
      app.LowLabel_2.Text = 'Low';

      % Create HighLabel_2
      app.HighLabel_2 = uilabel(app.SetpointBLEN11359SaturationLimitsmmPanel);
      app.HighLabel_2.Position = [174 38 31 22];
      app.HighLabel_2.Text = 'High';

      % Create SetpointFilterFreqHz0OFFEditFieldLabel
      app.SetpointFilterFreqHz0OFFEditFieldLabel = uilabel(app.LeftPanel);
      app.SetpointFilterFreqHz0OFFEditFieldLabel.HorizontalAlignment = 'right';
      app.SetpointFilterFreqHz0OFFEditFieldLabel.Position = [19 10 138 30];
      app.SetpointFilterFreqHz0OFFEditFieldLabel.Text = {'Setpoint Filter Freq. [Hz]:'; '(0 = OFF)'};

      % Create FilterFreqEditField
      app.FilterFreqEditField = uieditfield(app.LeftPanel, 'numeric');
      app.FilterFreqEditField.Position = [172 18 100 22];
      app.FilterFreqEditField.Value = 0.1;

      % Create SetpointBLEN11359DeadbandLimitsmmPanel
      app.SetpointBLEN11359DeadbandLimitsmmPanel = uipanel(app.LeftPanel);
      app.SetpointBLEN11359DeadbandLimitsmmPanel.Title = 'Setpoint: BLEN11359 Deadband Limits [mm]';
      app.SetpointBLEN11359DeadbandLimitsmmPanel.Position = [17 141 260 85];

      % Create EditField_5
      app.EditField_5 = uieditfield(app.SetpointBLEN11359DeadbandLimitsmmPanel, 'numeric');
      app.EditField_5.HorizontalAlignment = 'center';
      app.EditField_5.Position = [13 17 100 22];
      app.EditField_5.Value = -0.1;

      % Create EditField_6
      app.EditField_6 = uieditfield(app.SetpointBLEN11359DeadbandLimitsmmPanel, 'numeric');
      app.EditField_6.HorizontalAlignment = 'center';
      app.EditField_6.Position = [138 17 100 22];
      app.EditField_6.Value = 0.1;

      % Create LowLabel_3
      app.LowLabel_3 = uilabel(app.SetpointBLEN11359DeadbandLimitsmmPanel);
      app.LowLabel_3.Position = [49 38 28 22];
      app.LowLabel_3.Text = 'Low';

      % Create HighLabel_3
      app.HighLabel_3 = uilabel(app.SetpointBLEN11359DeadbandLimitsmmPanel);
      app.HighLabel_3.Position = [174 38 31 22];
      app.HighLabel_3.Text = 'High';

      % Create SetpointBPM11358TMITLimitsNe9Panel
      app.SetpointBPM11358TMITLimitsNe9Panel = uipanel(app.LeftPanel);
      app.SetpointBPM11358TMITLimitsNe9Panel.Title = 'Setpoint: BPM11358 TMIT Limits [Ne^9]';
      app.SetpointBPM11358TMITLimitsNe9Panel.Position = [17 49 260 85];

      % Create EditField_7
      app.EditField_7 = uieditfield(app.SetpointBPM11358TMITLimitsNe9Panel, 'numeric');
      app.EditField_7.HorizontalAlignment = 'center';
      app.EditField_7.Position = [13 17 100 22];
      app.EditField_7.Value = 0.5;

      % Create EditField_8
      app.EditField_8 = uieditfield(app.SetpointBPM11358TMITLimitsNe9Panel, 'numeric');
      app.EditField_8.HorizontalAlignment = 'center';
      app.EditField_8.Position = [138 17 100 22];
      app.EditField_8.Value = 50;

      % Create LowLabel_4
      app.LowLabel_4 = uilabel(app.SetpointBPM11358TMITLimitsNe9Panel);
      app.LowLabel_4.Position = [49 38 28 22];
      app.LowLabel_4.Text = 'Low';

      % Create HighLabel_4
      app.HighLabel_4 = uilabel(app.SetpointBPM11358TMITLimitsNe9Panel);
      app.HighLabel_4.Position = [174 38 31 22];
      app.HighLabel_4.Text = 'High';

      % Create RightPanel
      app.RightPanel = uipanel(app.GridLayout);
      app.RightPanel.Layout.Row = 1;
      app.RightPanel.Layout.Column = 2;

      % Create UIAxes
      app.UIAxes = uiaxes(app.RightPanel);
      title(app.UIAxes, {'BLEN11359'; ''})
      xlabel(app.UIAxes, 'time [s]')
      ylabel(app.UIAxes, '')
      app.UIAxes.Position = [4 6 588 470];

      % Show the figure after all components are created
      app.FeedbackSettingsUIFigure.Visible = 'on';
    end
  end

  % App creation and deletion
  methods (Access = public)

    % Construct app
    function app = BC11BL_Settings_exported(varargin)

      % Create UIFigure and components
      createComponents(app)

      % Register the app with App Designer
      registerApp(app, app.FeedbackSettingsUIFigure)

      % Execute the startup function
      runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

      if nargout == 0
        clear app
      end
    end

    % Code that executes before app deletion
    function delete(app)

      % Delete UIFigure when app is deleted
      delete(app.FeedbackSettingsUIFigure)
    end
  end
end