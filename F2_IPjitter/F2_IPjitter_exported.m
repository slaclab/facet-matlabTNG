classdef F2_IPjitter_exported < matlab.apps.AppBase

  % Properties that correspond to app components
  properties (Access = public)
    F2_IPjitterUIFigure   matlab.ui.Figure
    DesignOpticsIPWaistEnergyGeVtoplefteditfieldPanel  matlab.ui.container.Panel
    GridLayout            matlab.ui.container.GridLayout
    XLabel                matlab.ui.control.Label
    YLabel                matlab.ui.control.Label
    NEMITumradLabel       matlab.ui.control.Label
    BETAcmLabel           matlab.ui.control.Label
    Optics_nemitx         matlab.ui.control.NumericEditField
    Optics_nemity         matlab.ui.control.NumericEditField
    Optics_betax          matlab.ui.control.NumericEditField
    Optics_betay          matlab.ui.control.NumericEditField
    SIGMAuradLabel        matlab.ui.control.Label
    SIGMAumLabel          matlab.ui.control.Label
    Optics_sigmax         matlab.ui.control.NumericEditField
    Optics_sigmay         matlab.ui.control.NumericEditField
    Optics_divx           matlab.ui.control.NumericEditField
    Optics_divy           matlab.ui.control.NumericEditField
    Optics_E              matlab.ui.control.NumericEditField
    GetArchiveDataButton  matlab.ui.control.Button
    FitInformationPanel   matlab.ui.container.Panel
    fitinfo               matlab.ui.control.TextArea
    IPReconstructedWaistJitterPlotsPanel  matlab.ui.container.Panel
    GridLayout2           matlab.ui.container.GridLayout
    xax                   matlab.ui.control.UIAxes
    xpax                  matlab.ui.control.UIAxes
    xyax                  matlab.ui.control.UIAxes
    sxax                  matlab.ui.control.UIAxes
    yax                   matlab.ui.control.UIAxes
    ypax                  matlab.ui.control.UIAxes
    xpypax                matlab.ui.control.UIAxes
    syax                  matlab.ui.control.UIAxes
    PulsesPanel           matlab.ui.container.Panel
    npulse                matlab.ui.control.Spinner
    BPMSPanel             matlab.ui.container.Panel
    BPMS1                 matlab.ui.control.DropDown
    BPMS2                 matlab.ui.control.DropDown
    FetchLiveDataButton   matlab.ui.control.Button
  end

  
  properties (Access = public)
    aobj % F2_IPjitterApp object
  end
  
  properties (Access = private)
    lastdate % last time archive viewer date was set (empty if not used yet)
  end
  
  methods (Access = private)
    
    function OpticsCalc(app)
      gamma = app.Optics_E.Value/0.511e-3;
      emitx = 1e-6*app.Optics_nemitx.Value / gamma ;
      emity = 1e-6*app.Optics_nemity.Value / gamma ;
      betax = 1e-2*app.Optics_betax.Value ;
      betay = 1e-2*app.Optics_betay.Value ;
      app.Optics_sigmax.Value = sqrt(emitx*betax)*1e6;
      app.Optics_sigmay.Value = sqrt(emity*betay)*1e6;
      app.Optics_divx.Value = sqrt(emitx/betax)*1e6;
      app.Optics_divy.Value = sqrt(emity/betay)*1e6;
      app.aobj.designsigma = [app.Optics_sigmax.Value app.Optics_sigmay.Value] ;
      app.aobj.designdivergence = [app.Optics_divx.Value app.Optics_divy.Value] ;
    end
  end
  

  % Callbacks that handle component events
  methods (Access = private)

    % Code that executes after component creation
    function startupFcn(app, LLM)
      if exist('LLM','var')
        app.aobj=F2_IPjitterApp(app,LLM);
      else
        app.aobj=F2_IPjitterApp(app);
      end
    end

    % Value changed function: BPMS1
    function BPMS1ValueChanged(app, event)
      value = app.BPMS1.Value;
      if value>=app.BPMS2.Value
        app.BPMS1.Value=app.BPMS2.Value-1;
      end
      app.aobj.bpmid=[app.BPMS1.Value app.BPMS2.Value];
    end

    % Value changed function: BPMS2
    function BPMS2ValueChanged(app, event)
      value = app.BPMS2.Value;
      if value<=app.BPMS1.Value
        app.BPMS2.Value=app.BPMS1.Value+1;
      end
      app.aobj.bpmid=[app.BPMS1.Value app.BPMS2.Value];
    end

    % Value changed function: npulse
    function npulseValueChanged(app, event)
      value = app.npulse.Value;
      app.aobj.npulses=value;
    end

    % Button pushed function: GetArchiveDataButton
    function GetArchiveDataButtonPushed(app, event)
      if isempty(app.lastdate)
        d=uigetdate(now);
      else
        d=uigetdate(app.lastdate);
      end
      if ~isempty(d)
        app.lastdate=d;
        app.fitinfo.Value = "Fetching Archive BPM and magnet data..." ;
        drawnow;
        app.aobj.GetBPMS(datevec(d)) ;
        app.fitinfo.Value = "Processing Archive BPM data..." ;
        drawnow;
        app.aobj.procdata ;
        app.aobj.guiplot ;
      end
    end

    % Value changed function: Optics_E
    function Optics_EValueChanged(app, event)
      app.OpticsCalc;
    end

    % Value changed function: Optics_nemitx
    function Optics_nemitxValueChanged(app, event)
      app.OpticsCalc;
    end

    % Value changed function: Optics_nemity
    function Optics_nemityValueChanged(app, event)
      app.OpticsCalc;
    end

    % Value changed function: Optics_betax
    function Optics_betaxValueChanged(app, event)
      app.OpticsCalc;
    end

    % Value changed function: Optics_betay
    function Optics_betayValueChanged(app, event)
      app.OpticsCalc;
    end

    % Value changed function: Optics_sigmax
    function Optics_sigmaxValueChanged(app, event)
      value = app.Optics_sigmax.Value;
      app.aobj.designsigma(1) = value ;
      gamma = app.Optics_E.Value/0.511e-3;
      emitx = (value*1e-6)^2 / (app.Optics_betax.Value*1e-2) ;
      app.Optics_nemitx.Value = gamma * emitx * 1e6 ;
      app.Optics_divx.Value = 1e6 * sqrt(emitx/(app.Optics_betax.Value*1e-2)) ;
      app.aobj.designdivergence(1) = app.Optics_divx.Value ;
    end

    % Value changed function: Optics_sigmay
    function Optics_sigmayValueChanged(app, event)
      value = app.Optics_sigmay.Value;
      app.aobj.designsigma(2) = value ;
      gamma = app.Optics_E.Value/0.511e-3;
      emity = (value*1e-6)^2 / (app.Optics_betay.Value*1e-2) ;
      app.Optics_nemity.Value = gamma * emity * 1e6 ;
      app.Optics_divy.Value = 1e6 * sqrt(emity/(app.Optics_betay.Value*1e-2)) ;
      app.aobj.designdivergence(2) = app.Optics_divy.Value ;
    end

    % Value changed function: Optics_divx
    function Optics_divxValueChanged(app, event)
      value = app.Optics_divx.Value;
      app.aobj.designdivergence(1) = value ;
      gamma = app.Optics_E.Value/0.511e-3;
      emitx = (value*1e-6)^2 * (app.Optics_betax.Value*1e-2) ;
      app.Optics_nemitx.Value = gamma * emitx * 1e6 ;
      app.Optics_sigmax.Value = 1e6 * sqrt(emitx*app.Optics_betax.Value*1e-2) ;
      app.aobj.designsigma(1) = app.Optics_sigmax.Value ;
    end

    % Value changed function: Optics_divy
    function Optics_divyValueChanged(app, event)
      value = app.Optics_divy.Value;
      app.aobj.designdivergence(2) = value ;
      gamma = app.Optics_E.Value/0.511e-3;
      emity = (value*1e-6)^2 * (app.Optics_betay.Value*1e-2) ;
      app.Optics_nemity.Value = gamma * emity * 1e6 ;
      app.Optics_sigmay.Value = 1e6 * sqrt(emity*app.Optics_betay.Value*1e-2) ;
      app.aobj.designsigma(2) = app.Optics_sigmay.Value ;
    end

    % Button pushed function: FetchLiveDataButton
    function FetchLiveDataButtonPushed(app, event)
      app.fitinfo.Value = "Fetching live BPM data..." ;
      drawnow;
      app.aobj.GetBPMS ;
      app.fitinfo.Value = "Processing live BPM data..." ;
      drawnow;
      app.aobj.procdata ;
      app.aobj.guiplot ;
    end
  end

  % Component initialization
  methods (Access = private)

    % Create UIFigure and components
    function createComponents(app)

      % Create F2_IPjitterUIFigure and hide until all components are created
      app.F2_IPjitterUIFigure = uifigure('Visible', 'off');
      app.F2_IPjitterUIFigure.Position = [100 100 1026 665];
      app.F2_IPjitterUIFigure.Name = 'F2_IPjitter';

      % Create DesignOpticsIPWaistEnergyGeVtoplefteditfieldPanel
      app.DesignOpticsIPWaistEnergyGeVtoplefteditfieldPanel = uipanel(app.F2_IPjitterUIFigure);
      app.DesignOpticsIPWaistEnergyGeVtoplefteditfieldPanel.Title = ' Design Optics @ IP Waist [Energy (GeV) top-left edit field]';
      app.DesignOpticsIPWaistEnergyGeVtoplefteditfieldPanel.Position = [18 11 358 213];

      % Create GridLayout
      app.GridLayout = uigridlayout(app.DesignOpticsIPWaistEnergyGeVtoplefteditfieldPanel);
      app.GridLayout.ColumnWidth = {'1x', '1x', '1x'};
      app.GridLayout.RowHeight = {'1x', '1x', '1x', '1x', '1x'};

      % Create XLabel
      app.XLabel = uilabel(app.GridLayout);
      app.XLabel.HorizontalAlignment = 'center';
      app.XLabel.Layout.Row = 1;
      app.XLabel.Layout.Column = 2;
      app.XLabel.Text = 'X';

      % Create YLabel
      app.YLabel = uilabel(app.GridLayout);
      app.YLabel.HorizontalAlignment = 'center';
      app.YLabel.Layout.Row = 1;
      app.YLabel.Layout.Column = 3;
      app.YLabel.Text = 'Y';

      % Create NEMITumradLabel
      app.NEMITumradLabel = uilabel(app.GridLayout);
      app.NEMITumradLabel.HorizontalAlignment = 'right';
      app.NEMITumradLabel.Layout.Row = 2;
      app.NEMITumradLabel.Layout.Column = 1;
      app.NEMITumradLabel.Text = 'NEMIT (um-rad)';

      % Create BETAcmLabel
      app.BETAcmLabel = uilabel(app.GridLayout);
      app.BETAcmLabel.HorizontalAlignment = 'right';
      app.BETAcmLabel.Layout.Row = 3;
      app.BETAcmLabel.Layout.Column = 1;
      app.BETAcmLabel.Text = 'BETA (cm)';

      % Create Optics_nemitx
      app.Optics_nemitx = uieditfield(app.GridLayout, 'numeric');
      app.Optics_nemitx.Limits = [0.01 1000];
      app.Optics_nemitx.ValueDisplayFormat = '%.1f';
      app.Optics_nemitx.ValueChangedFcn = createCallbackFcn(app, @Optics_nemitxValueChanged, true);
      app.Optics_nemitx.Layout.Row = 2;
      app.Optics_nemitx.Layout.Column = 2;
      app.Optics_nemitx.Value = 5;

      % Create Optics_nemity
      app.Optics_nemity = uieditfield(app.GridLayout, 'numeric');
      app.Optics_nemity.Limits = [0.01 1000];
      app.Optics_nemity.ValueDisplayFormat = '%.1f';
      app.Optics_nemity.ValueChangedFcn = createCallbackFcn(app, @Optics_nemityValueChanged, true);
      app.Optics_nemity.Layout.Row = 2;
      app.Optics_nemity.Layout.Column = 3;
      app.Optics_nemity.Value = 5;

      % Create Optics_betax
      app.Optics_betax = uieditfield(app.GridLayout, 'numeric');
      app.Optics_betax.Limits = [0.01 10000];
      app.Optics_betax.ValueDisplayFormat = '%.1f';
      app.Optics_betax.ValueChangedFcn = createCallbackFcn(app, @Optics_betaxValueChanged, true);
      app.Optics_betax.Layout.Row = 3;
      app.Optics_betax.Layout.Column = 2;
      app.Optics_betax.Value = 50;

      % Create Optics_betay
      app.Optics_betay = uieditfield(app.GridLayout, 'numeric');
      app.Optics_betay.Limits = [0.01 10000];
      app.Optics_betay.ValueDisplayFormat = '%.1f';
      app.Optics_betay.ValueChangedFcn = createCallbackFcn(app, @Optics_betayValueChanged, true);
      app.Optics_betay.Layout.Row = 3;
      app.Optics_betay.Layout.Column = 3;
      app.Optics_betay.Value = 50;

      % Create SIGMAuradLabel
      app.SIGMAuradLabel = uilabel(app.GridLayout);
      app.SIGMAuradLabel.HorizontalAlignment = 'right';
      app.SIGMAuradLabel.Layout.Row = 5;
      app.SIGMAuradLabel.Layout.Column = 1;
      app.SIGMAuradLabel.Text = 'SIGMA'' (urad)';

      % Create SIGMAumLabel
      app.SIGMAumLabel = uilabel(app.GridLayout);
      app.SIGMAumLabel.HorizontalAlignment = 'right';
      app.SIGMAumLabel.Layout.Row = 4;
      app.SIGMAumLabel.Layout.Column = 1;
      app.SIGMAumLabel.Text = 'SIGMA (um)';

      % Create Optics_sigmax
      app.Optics_sigmax = uieditfield(app.GridLayout, 'numeric');
      app.Optics_sigmax.Limits = [0.01 10000];
      app.Optics_sigmax.ValueDisplayFormat = '%6.1f';
      app.Optics_sigmax.ValueChangedFcn = createCallbackFcn(app, @Optics_sigmaxValueChanged, true);
      app.Optics_sigmax.Layout.Row = 4;
      app.Optics_sigmax.Layout.Column = 2;
      app.Optics_sigmax.Value = 11.3;

      % Create Optics_sigmay
      app.Optics_sigmay = uieditfield(app.GridLayout, 'numeric');
      app.Optics_sigmay.Limits = [0.01 10000];
      app.Optics_sigmay.ValueDisplayFormat = '%.1f';
      app.Optics_sigmay.ValueChangedFcn = createCallbackFcn(app, @Optics_sigmayValueChanged, true);
      app.Optics_sigmay.Layout.Row = 4;
      app.Optics_sigmay.Layout.Column = 3;
      app.Optics_sigmay.Value = 11.3;

      % Create Optics_divx
      app.Optics_divx = uieditfield(app.GridLayout, 'numeric');
      app.Optics_divx.Limits = [0.01 10000];
      app.Optics_divx.ValueDisplayFormat = '%6.1f';
      app.Optics_divx.ValueChangedFcn = createCallbackFcn(app, @Optics_divxValueChanged, true);
      app.Optics_divx.Layout.Row = 5;
      app.Optics_divx.Layout.Column = 2;
      app.Optics_divx.Value = 22.6;

      % Create Optics_divy
      app.Optics_divy = uieditfield(app.GridLayout, 'numeric');
      app.Optics_divy.Limits = [0.01 10000];
      app.Optics_divy.ValueDisplayFormat = '%6.1f';
      app.Optics_divy.ValueChangedFcn = createCallbackFcn(app, @Optics_divyValueChanged, true);
      app.Optics_divy.Layout.Row = 5;
      app.Optics_divy.Layout.Column = 3;
      app.Optics_divy.Value = 22.6;

      % Create Optics_E
      app.Optics_E = uieditfield(app.GridLayout, 'numeric');
      app.Optics_E.Limits = [1 17];
      app.Optics_E.ValueDisplayFormat = '%.2f';
      app.Optics_E.ValueChangedFcn = createCallbackFcn(app, @Optics_EValueChanged, true);
      app.Optics_E.HorizontalAlignment = 'center';
      app.Optics_E.Layout.Row = 1;
      app.Optics_E.Layout.Column = 1;
      app.Optics_E.Value = 10;

      % Create GetArchiveDataButton
      app.GetArchiveDataButton = uibutton(app.F2_IPjitterUIFigure, 'push');
      app.GetArchiveDataButton.ButtonPushedFcn = createCallbackFcn(app, @GetArchiveDataButtonPushed, true);
      app.GetArchiveDataButton.Position = [876 22 134 53];
      app.GetArchiveDataButton.Text = 'Get Archive Data';

      % Create FitInformationPanel
      app.FitInformationPanel = uipanel(app.F2_IPjitterUIFigure);
      app.FitInformationPanel.Title = 'Fit Information';
      app.FitInformationPanel.Position = [384 68 476 156];

      % Create fitinfo
      app.fitinfo = uitextarea(app.FitInformationPanel);
      app.fitinfo.Editable = 'off';
      app.fitinfo.Position = [10 8 458 123];
      app.fitinfo.Value = {'Push "Fetch Live Data" button to grab live data or push "Get Archive Data" button to get npulses of data from the archiver.'};

      % Create IPReconstructedWaistJitterPlotsPanel
      app.IPReconstructedWaistJitterPlotsPanel = uipanel(app.F2_IPjitterUIFigure);
      app.IPReconstructedWaistJitterPlotsPanel.Title = 'IP Reconstructed Waist Jitter Plots';
      app.IPReconstructedWaistJitterPlotsPanel.Position = [18 232 991 424];

      % Create GridLayout2
      app.GridLayout2 = uigridlayout(app.IPReconstructedWaistJitterPlotsPanel);
      app.GridLayout2.ColumnWidth = {'1x', '1x', '1x', '1x'};

      % Create xax
      app.xax = uiaxes(app.GridLayout2);
      title(app.xax, 'X^*')
      xlabel(app.xax, '\mum')
      ylabel(app.xax, 'N')
      app.xax.Layout.Row = 1;
      app.xax.Layout.Column = 1;

      % Create xpax
      app.xpax = uiaxes(app.GridLayout2);
      title(app.xpax, 'XANG^*')
      xlabel(app.xpax, '\murad')
      ylabel(app.xpax, 'N')
      app.xpax.Layout.Row = 1;
      app.xpax.Layout.Column = 2;

      % Create xyax
      app.xyax = uiaxes(app.GridLayout2);
      title(app.xyax, 'X^* vs. Y^*')
      xlabel(app.xyax, 'X^* / \mum')
      ylabel(app.xyax, 'Y^* / \mum')
      app.xyax.Layout.Row = 1;
      app.xyax.Layout.Column = 3;

      % Create sxax
      app.sxax = uiaxes(app.GridLayout2);
      title(app.sxax, '\sigma_x vs. z')
      xlabel(app.sxax, 'Z / m - 1000')
      ylabel(app.sxax, '\sigma_x / \mum')
      app.sxax.Layout.Row = 1;
      app.sxax.Layout.Column = 4;

      % Create yax
      app.yax = uiaxes(app.GridLayout2);
      title(app.yax, 'Y^*')
      xlabel(app.yax, '\mum')
      ylabel(app.yax, 'N')
      app.yax.Layout.Row = 2;
      app.yax.Layout.Column = 1;

      % Create ypax
      app.ypax = uiaxes(app.GridLayout2);
      title(app.ypax, 'YANG^*')
      xlabel(app.ypax, '\murad')
      ylabel(app.ypax, 'N')
      app.ypax.Layout.Row = 2;
      app.ypax.Layout.Column = 2;

      % Create xpypax
      app.xpypax = uiaxes(app.GridLayout2);
      title(app.xpypax, 'XANG^* vs. YANG^*')
      xlabel(app.xpypax, 'XANG^* / \murad')
      ylabel(app.xpypax, 'YANG^* / \murad')
      app.xpypax.Layout.Row = 2;
      app.xpypax.Layout.Column = 3;

      % Create syax
      app.syax = uiaxes(app.GridLayout2);
      title(app.syax, '\sigma_y vs. z-')
      xlabel(app.syax, 'Z / m - 1000')
      ylabel(app.syax, '\sigma_y / \mum')
      app.syax.Layout.Row = 2;
      app.syax.Layout.Column = 4;

      % Create PulsesPanel
      app.PulsesPanel = uipanel(app.F2_IPjitterUIFigure);
      app.PulsesPanel.Title = '# Pulses';
      app.PulsesPanel.Position = [876 87 134 63];

      % Create npulse
      app.npulse = uispinner(app.PulsesPanel);
      app.npulse.Limits = [1 10000];
      app.npulse.ValueChangedFcn = createCallbackFcn(app, @npulseValueChanged, true);
      app.npulse.Interruptible = 'off';
      app.npulse.Position = [7 10 120 22];
      app.npulse.Value = 50;

      % Create BPMSPanel
      app.BPMSPanel = uipanel(app.F2_IPjitterUIFigure);
      app.BPMSPanel.Title = 'BPMS';
      app.BPMSPanel.Position = [384 11 476 52];

      % Create BPMS1
      app.BPMS1 = uidropdown(app.BPMSPanel);
      app.BPMS1.Items = {'M1FF / LI20:BPMS:3013', 'M2FF / LI20:BPMS:3036', 'M3FF / LI20:BPMS:3101', 'M4FF / LI20:BPMS:3120', 'M5FF / BPMS:LI20:3156', 'M0EX / BPMS:LI20:3218', 'M1EX / BPMS:LI20:3265', 'M2EX / BPMS:LI20:3315'};
      app.BPMS1.ValueChangedFcn = createCallbackFcn(app, @BPMS1ValueChanged, true);
      app.BPMS1.Position = [9 5 216 22];
      app.BPMS1.Value = 'M5FF / BPMS:LI20:3156';

      % Create BPMS2
      app.BPMS2 = uidropdown(app.BPMSPanel);
      app.BPMS2.Items = {'M2FF / LI20:BPMS:3036', 'M3FF / LI20:BPMS:3101', 'M4FF / LI20:BPMS:3120', 'M5FF / BPMS:LI20:3156', 'M0EX / BPMS:LI20:3218', 'M1EX / BPMS:LI20:3265', 'M2EX / BPMS:LI20:3315', 'M3EX / LI20:BPMS:3340'};
      app.BPMS2.ValueChangedFcn = createCallbackFcn(app, @BPMS2ValueChanged, true);
      app.BPMS2.Position = [252 5 216 22];
      app.BPMS2.Value = 'M0EX / BPMS:LI20:3218';

      % Create FetchLiveDataButton
      app.FetchLiveDataButton = uibutton(app.F2_IPjitterUIFigure, 'push');
      app.FetchLiveDataButton.ButtonPushedFcn = createCallbackFcn(app, @FetchLiveDataButtonPushed, true);
      app.FetchLiveDataButton.Position = [876 162 134 53];
      app.FetchLiveDataButton.Text = 'Fetch Live Data';

      % Show the figure after all components are created
      app.F2_IPjitterUIFigure.Visible = 'on';
    end
  end

  % App creation and deletion
  methods (Access = public)

    % Construct app
    function app = F2_IPjitter_exported(varargin)

      % Create UIFigure and components
      createComponents(app)

      % Register the app with App Designer
      registerApp(app, app.F2_IPjitterUIFigure)

      % Execute the startup function
      runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

      if nargout == 0
        clear app
      end
    end

    % Code that executes before app deletion
    function delete(app)

      % Delete UIFigure when app is deleted
      delete(app.F2_IPjitterUIFigure)
    end
  end
end