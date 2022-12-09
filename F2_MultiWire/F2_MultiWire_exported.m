classdef F2_MultiWire_exported < matlab.apps.AppBase

  % Properties that correspond to app components
  properties (Access = public)
    F2_MultiWireUIFigure      matlab.ui.Figure
    WS1Axes                   matlab.ui.control.UIAxes
    WS2Axes                   matlab.ui.control.UIAxes
    WS3Axes                   matlab.ui.control.UIAxes
    WS4Axes                   matlab.ui.control.UIAxes
    LinacDropDownLabel        matlab.ui.control.Label
    LinacDropDown             matlab.ui.control.DropDown
    ScanAllButton             matlab.ui.control.Button
    Label                     matlab.ui.control.Label
    ScanW1                    matlab.ui.control.Button
    WSAppButton               matlab.ui.control.Button
    Label_2                   matlab.ui.control.Label
    RMSfitumEditFieldLabel    matlab.ui.control.Label
    WS1Sigma                  matlab.ui.control.NumericEditField
    ScanW2                    matlab.ui.control.Button
    RMSfitumEditField_2Label  matlab.ui.control.Label
    WS2Sigma                  matlab.ui.control.NumericEditField
    ScanW3                    matlab.ui.control.Button
    RMSfitumEditField_3Label  matlab.ui.control.Label
    WS3Sigma                  matlab.ui.control.NumericEditField
    ScanW4                    matlab.ui.control.Button
    RMSfitumEditField_4Label  matlab.ui.control.Label
    WS4Sigma                  matlab.ui.control.NumericEditField
    ButtonGroup               matlab.ui.container.ButtonGroup
    XButton                   matlab.ui.control.RadioButton
    YButton                   matlab.ui.control.RadioButton
    UButton                   matlab.ui.control.RadioButton
    Button                    matlab.ui.control.Button
  end

  
  properties (Access = public)
    UpdateObj % Object to notify of updated data
    UpdateMethod % Method to call when data is updated
    WS F2_WirescanApp
    WSApp
    plane string = "x"
    Sigma(1,4)
    SigmaErr(1,4)
    LLM % LucretiaLiveModel obj
  end
  
  properties (Access = private)
    
  end
  
  methods (Access = public)
    
    function RemoteScan(app)
      app.ScanAllButtonPushed();
    end
    
    function RemoteSet(app)
%       app.LinacDropDownValueChanged();
      app.ButtonGroupSelectionChanged();
      drawnow
    end
    
    function PlotData(app,iwire)
      if ~exist('iwire','var')
        iwire=1:4;
      end
      for iws=iwire
        cla(app.(sprintf('WS%dAxes',iws))); reset(app.(sprintf('WS%dAxes',iws)));
      end
      if isempty(app.WS)
        return
      end
      for iws=iwire
        app.WS(iws).ProcData(app.(sprintf('WS%dAxes',iws)),1) ;
        if ~isempty(app.WS(iws).fitdata)
          if ~isempty(app.WS(iws).fitdata)
            app.(sprintf('WS%dSigma',iws)).Value = app.WS(iws).fitdata.sigma ;
            app.Sigma(iws) = app.WS(iws).fitdata.sigma ;
            app.SigmaErr(iws) = app.WS(iws).fitdata.sigmaErr ;
          else
            app.(sprintf('WS%dSigma',iws)).Value = 0 ;
            app.Sigma(iws) = 0 ;
            app.SigmaErr(iws) = 0 ;
          end
        end
      end
      switch app.LinacDropDown.Value
        case "L2"
          app.WS1Axes.Title.String = 'WIRE:LI11:444' ; 
          app.WS2Axes.Title.String = 'WIRE:LI11:614' ; 
          app.WS3Axes.Title.String = 'WIRE:LI11:744' ;
          app.WS4Axes.Title.String = 'WIRE:LI12:214' ;
        case "L3"
          app.WS1Axes.Title.String = 'WIRE:LI18:944' ;
          app.WS2Axes.Title.String = 'WIRE:LI19:144' ;
          app.WS3Axes.Title.String = 'WIRE:LI19:244' ;
          app.WS4Axes.Title.String = 'WIRE:LI19:344' ;
      end
      if ~isempty(app.UpdateObj)
        app.UpdateObj.(app.UpdateMethod) ;
      end
    end
    
    function ScanWire(app,iwire)
      app.(sprintf("ScanW%d",iwire)).Enable=false;
      drawnow
      try
        if ~isempty(app.WSApp) && isprop(app.WSApp,'UpdateObj')
          app.WSApp.aobj = app.WS(iwire) ; app.WSApp.aobj.AttachGUI(app.WSApp) ;
          app.WSApp.aobj.guiupdate; app.WSApp.aobj.ProcData;
          app.WSApp.RemoteStartScan();
        else
          app.WS(iwire).StartScan(app.(sprintf("WS%dAxes",iwire))) ;
        end
      catch ME
        app.(sprintf("ScanW%d",iwire)).Enable=true;
        errordlg(sprintf('Wirescanner %d failure',iwire),'Wirescan Failed');
        throw(ME);
      end
      app.(sprintf("ScanW%d",iwire)).Enable=true;
      drawnow
    end
    
    function DataUpdate(app,iwire)
      app.PlotData(iwire);
    end
    
    function LinkUpdate(app,~)
      if ~isempty(app.WSApp) && isprop(app.WSApp,'UpdateObj')
        for iwire=1:4
          if app.WSApp.plane==app.plane && "WIRE:"+string(app.WSApp.WIREDropDown.Value) == string(app.(sprintf('WS%dAxes',iwire)).Title.String)
            app.WSApp.aobj = app.WS(iwire) ;
            app.WSApp.aobj.UpdatePar{1} = iwire ; app.WSApp.aobj.AttachGUI(app.WSApp) ;
          end
        end
      end
    end
    
    function RemoteInitFcn(app,LLM,linac,dim)
       app.startupFcn(LLM, linac, dim) ;
    end
    
    function UpdatePlane(app)
      %UPDATEPLANE Call after changing measurement plane remotely
      app.ButtonGroupSelectionChanged;
    end
  end
  

  % Callbacks that handle component events
  methods (Access = private)

    % Code that executes after component creation
    function startupFcn(app, LLM, linac, dim)
      
      if exist('LLM','var') && isempty(app.LLM)
        app.LLM=LLM;
      else
        app.LLM=F2_LiveModelApp;
      end
      if exist('linac','var')
        app.LinacDropDown.Value = linac ;
        app.plane=dim;
      end
      drawnow;
      app.LinacDropDownValueChanged;
    end

    % Value changed function: LinacDropDown
    function LinacDropDownValueChanged(app, event)
      value = app.LinacDropDown.Value;
      if ~isempty(app.WS)
        delete(app.WS);
      end
      path(path,'../F2_Wirescan');
      for iws=1:4
        if length(app.WS)>=iws
          delete(app.WS);
        end
      end
      switch value
        case "L2"
          app.WS1Axes.Title.String = 'WIRE:LI11:444' ; 
          app.WS2Axes.Title.String = 'WIRE:LI11:614' ; 
          app.WS3Axes.Title.String = 'WIRE:LI11:744' ;
          app.WS4Axes.Title.String = 'WIRE:LI12:214' ;
          for iws=1:4; app.WS(iws) = F2_WirescanApp(app.LLM,iws+1,app.plane) ; end
        case "L3"
          app.WS1Axes.Title.String = 'WIRE:LI18:944' ;
          app.WS2Axes.Title.String = 'WIRE:LI19:144' ;
          app.WS3Axes.Title.String = 'WIRE:LI19:244' ;
          app.WS4Axes.Title.String = 'WIRE:LI19:344' ;
          for iws=1:4; app.WS(iws) = F2_WirescanApp(app.LLM,iws+5,app.plane) ; end
      end
      for iws=1:4
        app.WS(iws).UpdateObj=app;
        app.WS(iws).UpdateMethod=["DataUpdate" "LinkUpdate"];
        app.WS(iws).UpdatePar={iws,0};
      end
      app.PlotData;
      if ~isempty(app.WSApp) && isprop(app.WSApp,'UpdateObj')
        app.WSApp.aobj = app.WS(1) ; app.WSApp.aobj.AttachGUI(app.WSApp) ;
        app.WSApp.aobj.guiupdate; app.WSApp.aobj.ProcData;
      end
    end

    % Button pushed function: ScanW1
    function ScanW1ButtonPushed(app, event)
      app.ScanWire(1);
    end

    % Button pushed function: WSAppButton
    function WSAppButtonButtonPushed(app, event)
      if isempty(app.WSApp) || ~isprop(app.WSApp,'UpdateObj')
        path(path,'../F2_Wirescan');
        app.WSApp=F2_Wirescan(app.WS(1).LLM,app.WS(1).wiresel,app.WS(1).plane);
        app.WSApp.aobj = app.WS(1) ; app.WSApp.aobj.AttachGUI(app.WSApp) ;
        app.WSApp.aobj.guiupdate; app.WSApp.aobj.ProcData;
      end
    end

    % Selection changed function: ButtonGroup
    function ButtonGroupSelectionChanged(app, event)
      selectedButton = app.ButtonGroup.SelectedObject;
      app.plane = lower(string(selectedButton.Text)) ;
      app.LinacDropDownValueChanged;
    end

    % Button pushed function: ScanW2
    function ScanW2ButtonPushed(app, event)
      app.ScanWire(2);
    end

    % Button pushed function: ScanW3
    function ScanW3ButtonPushed(app, event)
      app.ScanWire(3);
    end

    % Button pushed function: ScanW4
    function ScanW4ButtonPushed(app, event)
      app.ScanWire(4);
    end

    % Button pushed function: ScanAllButton
    function ScanAllButtonPushed(app, event)
      app.ScanAllButton.Enable=false;
      drawnow
      try
        app.ScanW1ButtonPushed;
        app.ScanW2ButtonPushed;
        app.ScanW3ButtonPushed;
        app.ScanW4ButtonPushed;
      catch ME
        app.ScanAllButton.Enable=true;
        throw(ME);
      end
      app.ScanAllButton.Enable=true;
    end

    % Button pushed function: Button
    function ButtonPushed(app, event)
      fh=figure;
      switch app.LinacDropDown.Value
        case "L2"
          ttxt={'WIRE:LI11:444' 'WIRE:LI11:614' 'WIRE:LI11:744' 'WIRE:LI12:214'} ;
        case "L3"
          ttxt = {'WIRE:LI18:944' 'WIRE:LI19:144' 'WIRE:LI19:244' 'WIRE:LI19:344' } ;
      end
      for iwire=1:4
        ah=subplot(2,2,iwire);
        app.WS(iwire).ProcData(ah,1) ;
        title(ah,ttxt{iwire});
      end
      txt = "Multi-Wire Measurements:\n" + ttxt{1} + " = " + app.WS1Sigma.Value + " (um)\n" + ttxt{2} + " = " + app.WS2Sigma.Value + " (um)\n" ;
      txt = txt + ttxt{3} + " = " + app.WS3Sigma.Value + " (um)\n" + ttxt{4} + " = " + app.WS2Sigma.Value + " (um)\n";
      txt=sprintf(char(txt));
      drawnow;
      pause(1);
      util_printLog2020(fh, 'title',sprintf('%s Multi-Wire Scan (%c)',app.LinacDropDown.Value,char(app.plane)),'author','F2_MultiWire.m','text',txt);
      drawnow;
      pause(1);
      delete(fh);
    end

    % Close request function: F2_MultiWireUIFigure
    function F2_MultiWireUIFigureCloseRequest(app, event)
      
      if ~isempty(app.WSApp)
        try
          delete(app.WSApp);
        catch
        end
      end
      delete(app);
    end
  end

  % Component initialization
  methods (Access = private)

    % Create UIFigure and components
    function createComponents(app)

      % Create F2_MultiWireUIFigure and hide until all components are created
      app.F2_MultiWireUIFigure = uifigure('Visible', 'off');
      app.F2_MultiWireUIFigure.Position = [100 100 883 841];
      app.F2_MultiWireUIFigure.Name = 'F2_MultiWire';
      app.F2_MultiWireUIFigure.CloseRequestFcn = createCallbackFcn(app, @F2_MultiWireUIFigureCloseRequest, true);

      % Create WS1Axes
      app.WS1Axes = uiaxes(app.F2_MultiWireUIFigure);
      title(app.WS1Axes, 'Wire 1')
      xlabel(app.WS1Axes, 'X')
      ylabel(app.WS1Axes, 'Y')
      app.WS1Axes.Position = [10 453 422 321];

      % Create WS2Axes
      app.WS2Axes = uiaxes(app.F2_MultiWireUIFigure);
      title(app.WS2Axes, 'Wire 2')
      xlabel(app.WS2Axes, 'X')
      ylabel(app.WS2Axes, 'Y')
      app.WS2Axes.Position = [446 453 422 321];

      % Create WS3Axes
      app.WS3Axes = uiaxes(app.F2_MultiWireUIFigure);
      title(app.WS3Axes, 'Wire 3')
      xlabel(app.WS3Axes, 'X')
      ylabel(app.WS3Axes, 'Y')
      app.WS3Axes.Position = [10 64 422 321];

      % Create WS4Axes
      app.WS4Axes = uiaxes(app.F2_MultiWireUIFigure);
      title(app.WS4Axes, 'Wire 4')
      xlabel(app.WS4Axes, 'X')
      ylabel(app.WS4Axes, 'Y')
      app.WS4Axes.Position = [446 64 422 321];

      % Create LinacDropDownLabel
      app.LinacDropDownLabel = uilabel(app.F2_MultiWireUIFigure);
      app.LinacDropDownLabel.HorizontalAlignment = 'right';
      app.LinacDropDownLabel.Position = [70 805 38 22];
      app.LinacDropDownLabel.Text = 'Linac:';

      % Create LinacDropDown
      app.LinacDropDown = uidropdown(app.F2_MultiWireUIFigure);
      app.LinacDropDown.Items = {'L2', 'L3'};
      app.LinacDropDown.ValueChangedFcn = createCallbackFcn(app, @LinacDropDownValueChanged, true);
      app.LinacDropDown.Position = [123 805 100 22];
      app.LinacDropDown.Value = 'L2';

      % Create ScanAllButton
      app.ScanAllButton = uibutton(app.F2_MultiWireUIFigure, 'push');
      app.ScanAllButton.ButtonPushedFcn = createCallbackFcn(app, @ScanAllButtonPushed, true);
      app.ScanAllButton.Interruptible = 'off';
      app.ScanAllButton.Position = [528 804 100 23];
      app.ScanAllButton.Text = 'Scan All';

      % Create Label
      app.Label = uilabel(app.F2_MultiWireUIFigure);
      app.Label.HorizontalAlignment = 'center';
      app.Label.Position = [31 779 836 22];
      app.Label.Text = '-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------';

      % Create ScanW1
      app.ScanW1 = uibutton(app.F2_MultiWireUIFigure, 'push');
      app.ScanW1.ButtonPushedFcn = createCallbackFcn(app, @ScanW1ButtonPushed, true);
      app.ScanW1.Interruptible = 'off';
      app.ScanW1.Position = [70 418 100 23];
      app.ScanW1.Text = 'Scan';

      % Create WSAppButton
      app.WSAppButton = uibutton(app.F2_MultiWireUIFigure, 'push');
      app.WSAppButton.ButtonPushedFcn = createCallbackFcn(app, @WSAppButtonButtonPushed, true);
      app.WSAppButton.Position = [650 804 142 23];
      app.WSAppButton.Text = 'Show Wirescanner GUI';

      % Create Label_2
      app.Label_2 = uilabel(app.F2_MultiWireUIFigure);
      app.Label_2.HorizontalAlignment = 'center';
      app.Label_2.Position = [31 391 836 22];
      app.Label_2.Text = '-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------';

      % Create RMSfitumEditFieldLabel
      app.RMSfitumEditFieldLabel = uilabel(app.F2_MultiWireUIFigure);
      app.RMSfitumEditFieldLabel.HorizontalAlignment = 'right';
      app.RMSfitumEditFieldLabel.Position = [211 418 75 22];
      app.RMSfitumEditFieldLabel.Text = 'RMS fit (um):';

      % Create WS1Sigma
      app.WS1Sigma = uieditfield(app.F2_MultiWireUIFigure, 'numeric');
      app.WS1Sigma.ValueDisplayFormat = '%.1f';
      app.WS1Sigma.Position = [301 418 91 22];

      % Create ScanW2
      app.ScanW2 = uibutton(app.F2_MultiWireUIFigure, 'push');
      app.ScanW2.ButtonPushedFcn = createCallbackFcn(app, @ScanW2ButtonPushed, true);
      app.ScanW2.Interruptible = 'off';
      app.ScanW2.Position = [506 418 100 23];
      app.ScanW2.Text = 'Scan';

      % Create RMSfitumEditField_2Label
      app.RMSfitumEditField_2Label = uilabel(app.F2_MultiWireUIFigure);
      app.RMSfitumEditField_2Label.HorizontalAlignment = 'right';
      app.RMSfitumEditField_2Label.Position = [642 418 75 22];
      app.RMSfitumEditField_2Label.Text = 'RMS fit (um):';

      % Create WS2Sigma
      app.WS2Sigma = uieditfield(app.F2_MultiWireUIFigure, 'numeric');
      app.WS2Sigma.ValueDisplayFormat = '%.1f';
      app.WS2Sigma.Position = [732 418 91 22];

      % Create ScanW3
      app.ScanW3 = uibutton(app.F2_MultiWireUIFigure, 'push');
      app.ScanW3.ButtonPushedFcn = createCallbackFcn(app, @ScanW3ButtonPushed, true);
      app.ScanW3.Interruptible = 'off';
      app.ScanW3.Position = [70 24 100 23];
      app.ScanW3.Text = 'Scan';

      % Create RMSfitumEditField_3Label
      app.RMSfitumEditField_3Label = uilabel(app.F2_MultiWireUIFigure);
      app.RMSfitumEditField_3Label.HorizontalAlignment = 'right';
      app.RMSfitumEditField_3Label.Position = [211 24 75 22];
      app.RMSfitumEditField_3Label.Text = 'RMS fit (um):';

      % Create WS3Sigma
      app.WS3Sigma = uieditfield(app.F2_MultiWireUIFigure, 'numeric');
      app.WS3Sigma.ValueDisplayFormat = '%.1f';
      app.WS3Sigma.Position = [301 24 91 22];

      % Create ScanW4
      app.ScanW4 = uibutton(app.F2_MultiWireUIFigure, 'push');
      app.ScanW4.ButtonPushedFcn = createCallbackFcn(app, @ScanW4ButtonPushed, true);
      app.ScanW4.Interruptible = 'off';
      app.ScanW4.Position = [506 24 100 23];
      app.ScanW4.Text = 'Scan';

      % Create RMSfitumEditField_4Label
      app.RMSfitumEditField_4Label = uilabel(app.F2_MultiWireUIFigure);
      app.RMSfitumEditField_4Label.HorizontalAlignment = 'right';
      app.RMSfitumEditField_4Label.Position = [642 24 75 22];
      app.RMSfitumEditField_4Label.Text = 'RMS fit (um):';

      % Create WS4Sigma
      app.WS4Sigma = uieditfield(app.F2_MultiWireUIFigure, 'numeric');
      app.WS4Sigma.ValueDisplayFormat = '%.1f';
      app.WS4Sigma.Position = [732 24 91 22];

      % Create ButtonGroup
      app.ButtonGroup = uibuttongroup(app.F2_MultiWireUIFigure);
      app.ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ButtonGroupSelectionChanged, true);
      app.ButtonGroup.Position = [259 801 241 30];

      % Create XButton
      app.XButton = uiradiobutton(app.ButtonGroup);
      app.XButton.Text = 'X';
      app.XButton.Position = [11 4 58 22];
      app.XButton.Value = true;

      % Create YButton
      app.YButton = uiradiobutton(app.ButtonGroup);
      app.YButton.Text = 'Y';
      app.YButton.Position = [88 4 65 22];

      % Create UButton
      app.UButton = uiradiobutton(app.ButtonGroup);
      app.UButton.Text = 'U';
      app.UButton.Position = [172 4 65 22];

      % Create Button
      app.Button = uibutton(app.F2_MultiWireUIFigure, 'push');
      app.Button.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed, true);
      app.Button.Interruptible = 'off';
      app.Button.Icon = 'logbook.gif';
      app.Button.Position = [838 797 40 40];
      app.Button.Text = '';

      % Show the figure after all components are created
      app.F2_MultiWireUIFigure.Visible = 'on';
    end
  end

  % App creation and deletion
  methods (Access = public)

    % Construct app
    function app = F2_MultiWire_exported(varargin)

      % Create UIFigure and components
      createComponents(app)

      % Register the app with App Designer
      registerApp(app, app.F2_MultiWireUIFigure)

      % Execute the startup function
      runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

      if nargout == 0
        clear app
      end
    end

    % Code that executes before app deletion
    function delete(app)

      % Delete UIFigure when app is deleted
      delete(app.F2_MultiWireUIFigure)
    end
  end
end