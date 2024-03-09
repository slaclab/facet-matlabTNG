classdef F2_MultiWire_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        F2_MultiWireUIFigure      matlab.ui.Figure
        GridLayout5               matlab.ui.container.GridLayout
        Panel                     matlab.ui.container.Panel
        GridLayout                matlab.ui.container.GridLayout
        WS1Axes                   matlab.ui.control.UIAxes
        ScanW1                    matlab.ui.control.Button
        RMSfitumEditFieldLabel    matlab.ui.control.Label
        WS1Sigma                  matlab.ui.control.NumericEditField
        WS1Time                   matlab.ui.control.EditField
        SkewKurtosisLabel         matlab.ui.control.Label
        WS1Skew                   matlab.ui.control.NumericEditField
        WS1Kurt                   matlab.ui.control.NumericEditField
        Panel_2                   matlab.ui.container.Panel
        GridLayout4               matlab.ui.container.GridLayout
        WS2Axes                   matlab.ui.control.UIAxes
        ScanW2                    matlab.ui.control.Button
        RMSfitumEditField_2Label  matlab.ui.control.Label
        WS2Sigma                  matlab.ui.control.NumericEditField
        WS2Time                   matlab.ui.control.EditField
        SkewKurtosisLabel_2       matlab.ui.control.Label
        WS2Skew                   matlab.ui.control.NumericEditField
        WS2Kurt                   matlab.ui.control.NumericEditField
        Panel_4                   matlab.ui.container.Panel
        GridLayout2               matlab.ui.container.GridLayout
        WS3Axes                   matlab.ui.control.UIAxes
        ScanW3                    matlab.ui.control.Button
        RMSfitumEditField_3Label  matlab.ui.control.Label
        WS3Sigma                  matlab.ui.control.NumericEditField
        WS3Time                   matlab.ui.control.EditField
        SkewKurtosisLabel_3       matlab.ui.control.Label
        WS3Skew                   matlab.ui.control.NumericEditField
        WS3Kurt                   matlab.ui.control.NumericEditField
        Panel_3                   matlab.ui.container.Panel
        GridLayout3               matlab.ui.container.GridLayout
        WS4Axes                   matlab.ui.control.UIAxes
        ScanW4                    matlab.ui.control.Button
        RMSfitumEditField_4Label  matlab.ui.control.Label
        WS4Sigma                  matlab.ui.control.NumericEditField
        WS4Time                   matlab.ui.control.EditField
        SkewKurtosisLabel_4       matlab.ui.control.Label
        WS4Skew                   matlab.ui.control.NumericEditField
        WS4Kurt                   matlab.ui.control.NumericEditField
        Panel_5                   matlab.ui.container.Panel
        GridLayout6               matlab.ui.container.GridLayout
        ButtonGroup               matlab.ui.container.ButtonGroup
        XButton                   matlab.ui.control.RadioButton
        YButton                   matlab.ui.control.RadioButton
        UButton                   matlab.ui.control.RadioButton
        ScanAllButton             matlab.ui.control.Button
        WSAppButton               matlab.ui.control.Button
        Button                    matlab.ui.control.Button
        LinacDropDownLabel        matlab.ui.control.Label
        LiancDropDown             matlab.ui.control.DropDown
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
%       app.LiancDropDownValueChanged();
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
            app.(sprintf('WS%dTime',iws)).Value = app.WS(iws).scanTimestamp ;
            app.(sprintf('WS%dSkew',iws)).Value = app.WS(iws).fitdata.skew ;
            app.(sprintf('WS%dKurt',iws)).Value = app.WS(iws).fitdata.kurt ;
            app.Sigma(iws) = app.WS(iws).fitdata.sigma ;
            app.SigmaErr(iws) = app.WS(iws).fitdata.sigmaErr ;
          else
            app.(sprintf('WS%dSigma',iws)).Value = 0 ;
            app.Sigma(iws) = 0 ;
            app.SigmaErr(iws) = 0 ;
          end
        end
      end
      switch app.LiancDropDown.Value
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
        app.LiancDropDown.Value = linac ;
        app.plane=dim;
      end
      drawnow;
      app.LiancDropDownValueChanged;
        end

        % Value changed function: LiancDropDown
        function LiancDropDownValueChanged(app, event)
      value = app.LiancDropDown.Value;
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
      app.LiancDropDownValueChanged;
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
            switch app.LiancDropDown.Value
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
            
            hdr = 'Multi-Wire Measurements:';
            ws_msmt = '[%s] %s = %.3f um\t (skew=%.3f, kurt=%.3f)\t ts: %s';
            sig = sprintf('sig%s', app.plane);
            ws1 = sprintf(ws_msmt, ttxt{1}, sig, app.WS1Sigma.Value, app.WS1Skew.Value, app.WS1Kurt.Value, app.WS1Time.Value);
            ws2 = sprintf(ws_msmt, ttxt{2}, sig, app.WS2Sigma.Value, app.WS2Skew.Value, app.WS2Kurt.Value, app.WS2Time.Value);
            ws3 = sprintf(ws_msmt, ttxt{3}, sig, app.WS3Sigma.Value, app.WS3Skew.Value, app.WS3Kurt.Value, app.WS3Time.Value);
            ws4 = sprintf(ws_msmt, ttxt{4}, sig, app.WS4Sigma.Value, app.WS4Skew.Value, app.WS4Kurt.Value, app.WS4Time.Value);
            
            logmsg = sprintf('%s\n  %s\n  %s\n  %s\n  %s\n', hdr, ws1, ws2, ws3, ws4);

            drawnow;
            pause(1);
            util_printLog2020(fh, 'title',sprintf('%s Multi-Wire Scan (%c)',app.LiancDropDown.Value,char(app.plane)),'author','F2_MultiWire.m','text',logmsg);
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
            app.F2_MultiWireUIFigure.Position = [100 100 900 850];
            app.F2_MultiWireUIFigure.Name = 'F2_MultiWire';
            app.F2_MultiWireUIFigure.CloseRequestFcn = createCallbackFcn(app, @F2_MultiWireUIFigureCloseRequest, true);

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.F2_MultiWireUIFigure);
            app.GridLayout5.ColumnWidth = {'9.74x', '9.54x'};
            app.GridLayout5.RowHeight = {80, '4x', '4x'};

            % Create Panel
            app.Panel = uipanel(app.GridLayout5);
            app.Panel.Layout.Row = 2;
            app.Panel.Layout.Column = 1;

            % Create GridLayout
            app.GridLayout = uigridlayout(app.Panel);
            app.GridLayout.ColumnWidth = {'1x', '1x', '0.5x', '0.5x'};
            app.GridLayout.RowHeight = {'1x', 'fit', 'fit'};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [5 5 5 5];

            % Create WS1Axes
            app.WS1Axes = uiaxes(app.GridLayout);
            title(app.WS1Axes, 'Wire 1')
            xlabel(app.WS1Axes, 'X')
            ylabel(app.WS1Axes, 'Y')
            app.WS1Axes.Layout.Row = 1;
            app.WS1Axes.Layout.Column = [1 4];

            % Create ScanW1
            app.ScanW1 = uibutton(app.GridLayout, 'push');
            app.ScanW1.ButtonPushedFcn = createCallbackFcn(app, @ScanW1ButtonPushed, true);
            app.ScanW1.Interruptible = 'off';
            app.ScanW1.Layout.Row = 2;
            app.ScanW1.Layout.Column = 1;
            app.ScanW1.Text = 'Scan';

            % Create RMSfitumEditFieldLabel
            app.RMSfitumEditFieldLabel = uilabel(app.GridLayout);
            app.RMSfitumEditFieldLabel.HorizontalAlignment = 'right';
            app.RMSfitumEditFieldLabel.Layout.Row = 2;
            app.RMSfitumEditFieldLabel.Layout.Column = 2;
            app.RMSfitumEditFieldLabel.Text = 'RMS fit (um):';

            % Create WS1Sigma
            app.WS1Sigma = uieditfield(app.GridLayout, 'numeric');
            app.WS1Sigma.ValueDisplayFormat = '%.1f';
            app.WS1Sigma.Editable = 'off';
            app.WS1Sigma.Layout.Row = 2;
            app.WS1Sigma.Layout.Column = [3 4];

            % Create WS1Time
            app.WS1Time = uieditfield(app.GridLayout, 'text');
            app.WS1Time.Editable = 'off';
            app.WS1Time.Layout.Row = 3;
            app.WS1Time.Layout.Column = 1;

            % Create SkewKurtosisLabel
            app.SkewKurtosisLabel = uilabel(app.GridLayout);
            app.SkewKurtosisLabel.HorizontalAlignment = 'right';
            app.SkewKurtosisLabel.Layout.Row = 3;
            app.SkewKurtosisLabel.Layout.Column = 2;
            app.SkewKurtosisLabel.Text = 'Skew / Kurtosis:';

            % Create WS1Skew
            app.WS1Skew = uieditfield(app.GridLayout, 'numeric');
            app.WS1Skew.Editable = 'off';
            app.WS1Skew.Layout.Row = 3;
            app.WS1Skew.Layout.Column = 3;

            % Create WS1Kurt
            app.WS1Kurt = uieditfield(app.GridLayout, 'numeric');
            app.WS1Kurt.Editable = 'off';
            app.WS1Kurt.Layout.Row = 3;
            app.WS1Kurt.Layout.Column = 4;

            % Create Panel_2
            app.Panel_2 = uipanel(app.GridLayout5);
            app.Panel_2.Layout.Row = 2;
            app.Panel_2.Layout.Column = 2;

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.Panel_2);
            app.GridLayout4.ColumnWidth = {'1x', '1x', '0.5x', '0.5x'};
            app.GridLayout4.RowHeight = {'1x', 23, 'fit'};
            app.GridLayout4.ColumnSpacing = 5;
            app.GridLayout4.RowSpacing = 5;
            app.GridLayout4.Padding = [5 5 5 5];

            % Create WS2Axes
            app.WS2Axes = uiaxes(app.GridLayout4);
            title(app.WS2Axes, 'Wire 2')
            xlabel(app.WS2Axes, 'X')
            ylabel(app.WS2Axes, 'Y')
            app.WS2Axes.Layout.Row = 1;
            app.WS2Axes.Layout.Column = [1 4];

            % Create ScanW2
            app.ScanW2 = uibutton(app.GridLayout4, 'push');
            app.ScanW2.ButtonPushedFcn = createCallbackFcn(app, @ScanW2ButtonPushed, true);
            app.ScanW2.Interruptible = 'off';
            app.ScanW2.Layout.Row = 2;
            app.ScanW2.Layout.Column = 1;
            app.ScanW2.Text = 'Scan';

            % Create RMSfitumEditField_2Label
            app.RMSfitumEditField_2Label = uilabel(app.GridLayout4);
            app.RMSfitumEditField_2Label.HorizontalAlignment = 'right';
            app.RMSfitumEditField_2Label.Layout.Row = 2;
            app.RMSfitumEditField_2Label.Layout.Column = 2;
            app.RMSfitumEditField_2Label.Text = 'RMS fit (um):';

            % Create WS2Sigma
            app.WS2Sigma = uieditfield(app.GridLayout4, 'numeric');
            app.WS2Sigma.ValueDisplayFormat = '%.1f';
            app.WS2Sigma.Editable = 'off';
            app.WS2Sigma.Layout.Row = 2;
            app.WS2Sigma.Layout.Column = [3 4];

            % Create WS2Time
            app.WS2Time = uieditfield(app.GridLayout4, 'text');
            app.WS2Time.Editable = 'off';
            app.WS2Time.Layout.Row = 3;
            app.WS2Time.Layout.Column = 1;

            % Create SkewKurtosisLabel_2
            app.SkewKurtosisLabel_2 = uilabel(app.GridLayout4);
            app.SkewKurtosisLabel_2.HorizontalAlignment = 'right';
            app.SkewKurtosisLabel_2.Layout.Row = 3;
            app.SkewKurtosisLabel_2.Layout.Column = 2;
            app.SkewKurtosisLabel_2.Text = 'Skew / Kurtosis:';

            % Create WS2Skew
            app.WS2Skew = uieditfield(app.GridLayout4, 'numeric');
            app.WS2Skew.Editable = 'off';
            app.WS2Skew.Layout.Row = 3;
            app.WS2Skew.Layout.Column = 3;

            % Create WS2Kurt
            app.WS2Kurt = uieditfield(app.GridLayout4, 'numeric');
            app.WS2Kurt.Editable = 'off';
            app.WS2Kurt.Layout.Row = 3;
            app.WS2Kurt.Layout.Column = 4;

            % Create Panel_4
            app.Panel_4 = uipanel(app.GridLayout5);
            app.Panel_4.Layout.Row = 3;
            app.Panel_4.Layout.Column = 1;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.Panel_4);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '0.5x', '0.5x'};
            app.GridLayout2.RowHeight = {'1x', 23, 'fit'};
            app.GridLayout2.ColumnSpacing = 5;
            app.GridLayout2.RowSpacing = 5;
            app.GridLayout2.Padding = [5 5 5 5];

            % Create WS3Axes
            app.WS3Axes = uiaxes(app.GridLayout2);
            title(app.WS3Axes, 'Wire 3')
            xlabel(app.WS3Axes, 'X')
            ylabel(app.WS3Axes, 'Y')
            app.WS3Axes.Layout.Row = 1;
            app.WS3Axes.Layout.Column = [1 4];

            % Create ScanW3
            app.ScanW3 = uibutton(app.GridLayout2, 'push');
            app.ScanW3.ButtonPushedFcn = createCallbackFcn(app, @ScanW3ButtonPushed, true);
            app.ScanW3.Interruptible = 'off';
            app.ScanW3.Layout.Row = 2;
            app.ScanW3.Layout.Column = 1;
            app.ScanW3.Text = 'Scan';

            % Create RMSfitumEditField_3Label
            app.RMSfitumEditField_3Label = uilabel(app.GridLayout2);
            app.RMSfitumEditField_3Label.HorizontalAlignment = 'right';
            app.RMSfitumEditField_3Label.Layout.Row = 2;
            app.RMSfitumEditField_3Label.Layout.Column = 2;
            app.RMSfitumEditField_3Label.Text = 'RMS fit (um):';

            % Create WS3Sigma
            app.WS3Sigma = uieditfield(app.GridLayout2, 'numeric');
            app.WS3Sigma.ValueDisplayFormat = '%.1f';
            app.WS3Sigma.Editable = 'off';
            app.WS3Sigma.Layout.Row = 2;
            app.WS3Sigma.Layout.Column = [3 4];

            % Create WS3Time
            app.WS3Time = uieditfield(app.GridLayout2, 'text');
            app.WS3Time.Editable = 'off';
            app.WS3Time.Layout.Row = 3;
            app.WS3Time.Layout.Column = 1;

            % Create SkewKurtosisLabel_3
            app.SkewKurtosisLabel_3 = uilabel(app.GridLayout2);
            app.SkewKurtosisLabel_3.HorizontalAlignment = 'right';
            app.SkewKurtosisLabel_3.Layout.Row = 3;
            app.SkewKurtosisLabel_3.Layout.Column = 2;
            app.SkewKurtosisLabel_3.Text = 'Skew / Kurtosis:';

            % Create WS3Skew
            app.WS3Skew = uieditfield(app.GridLayout2, 'numeric');
            app.WS3Skew.Editable = 'off';
            app.WS3Skew.Layout.Row = 3;
            app.WS3Skew.Layout.Column = 3;

            % Create WS3Kurt
            app.WS3Kurt = uieditfield(app.GridLayout2, 'numeric');
            app.WS3Kurt.Editable = 'off';
            app.WS3Kurt.Layout.Row = 3;
            app.WS3Kurt.Layout.Column = 4;

            % Create Panel_3
            app.Panel_3 = uipanel(app.GridLayout5);
            app.Panel_3.Layout.Row = 3;
            app.Panel_3.Layout.Column = 2;

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.Panel_3);
            app.GridLayout3.ColumnWidth = {'1x', '1x', '0.5x', '0.5x'};
            app.GridLayout3.RowHeight = {'1x', 23, 'fit'};
            app.GridLayout3.ColumnSpacing = 5;
            app.GridLayout3.RowSpacing = 5;
            app.GridLayout3.Padding = [5 5 5 5];

            % Create WS4Axes
            app.WS4Axes = uiaxes(app.GridLayout3);
            title(app.WS4Axes, 'Wire 4')
            xlabel(app.WS4Axes, 'X')
            ylabel(app.WS4Axes, 'Y')
            app.WS4Axes.Layout.Row = 1;
            app.WS4Axes.Layout.Column = [1 4];

            % Create ScanW4
            app.ScanW4 = uibutton(app.GridLayout3, 'push');
            app.ScanW4.ButtonPushedFcn = createCallbackFcn(app, @ScanW4ButtonPushed, true);
            app.ScanW4.Interruptible = 'off';
            app.ScanW4.Layout.Row = 2;
            app.ScanW4.Layout.Column = 1;
            app.ScanW4.Text = 'Scan';

            % Create RMSfitumEditField_4Label
            app.RMSfitumEditField_4Label = uilabel(app.GridLayout3);
            app.RMSfitumEditField_4Label.HorizontalAlignment = 'right';
            app.RMSfitumEditField_4Label.Layout.Row = 2;
            app.RMSfitumEditField_4Label.Layout.Column = 2;
            app.RMSfitumEditField_4Label.Text = 'RMS fit (um):';

            % Create WS4Sigma
            app.WS4Sigma = uieditfield(app.GridLayout3, 'numeric');
            app.WS4Sigma.ValueDisplayFormat = '%.1f';
            app.WS4Sigma.Editable = 'off';
            app.WS4Sigma.Layout.Row = 2;
            app.WS4Sigma.Layout.Column = [3 4];

            % Create WS4Time
            app.WS4Time = uieditfield(app.GridLayout3, 'text');
            app.WS4Time.Editable = 'off';
            app.WS4Time.Layout.Row = 3;
            app.WS4Time.Layout.Column = 1;

            % Create SkewKurtosisLabel_4
            app.SkewKurtosisLabel_4 = uilabel(app.GridLayout3);
            app.SkewKurtosisLabel_4.HorizontalAlignment = 'right';
            app.SkewKurtosisLabel_4.Layout.Row = 3;
            app.SkewKurtosisLabel_4.Layout.Column = 2;
            app.SkewKurtosisLabel_4.Text = 'Skew / Kurtosis:';

            % Create WS4Skew
            app.WS4Skew = uieditfield(app.GridLayout3, 'numeric');
            app.WS4Skew.Editable = 'off';
            app.WS4Skew.Layout.Row = 3;
            app.WS4Skew.Layout.Column = 3;

            % Create WS4Kurt
            app.WS4Kurt = uieditfield(app.GridLayout3, 'numeric');
            app.WS4Kurt.Editable = 'off';
            app.WS4Kurt.Layout.Row = 3;
            app.WS4Kurt.Layout.Column = 4;

            % Create Panel_5
            app.Panel_5 = uipanel(app.GridLayout5);
            app.Panel_5.Layout.Row = 1;
            app.Panel_5.Layout.Column = [1 2];

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.Panel_5);
            app.GridLayout6.ColumnWidth = {60, 'fit', 200, '1x', 150, 200, 30, 30};
            app.GridLayout6.Padding = [10 9 10 9];

            % Create ButtonGroup
            app.ButtonGroup = uibuttongroup(app.GridLayout6);
            app.ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ButtonGroupSelectionChanged, true);
            app.ButtonGroup.Layout.Row = 1;
            app.ButtonGroup.Layout.Column = 3;

            % Create XButton
            app.XButton = uiradiobutton(app.ButtonGroup);
            app.XButton.Text = 'X';
            app.XButton.Position = [10 2 50 22];
            app.XButton.Value = true;

            % Create YButton
            app.YButton = uiradiobutton(app.ButtonGroup);
            app.YButton.Text = 'Y';
            app.YButton.Position = [71 2 50 22];

            % Create UButton
            app.UButton = uiradiobutton(app.ButtonGroup);
            app.UButton.Text = 'U';
            app.UButton.Position = [141 2 50 22];

            % Create ScanAllButton
            app.ScanAllButton = uibutton(app.GridLayout6, 'push');
            app.ScanAllButton.ButtonPushedFcn = createCallbackFcn(app, @ScanAllButtonPushed, true);
            app.ScanAllButton.Interruptible = 'off';
            app.ScanAllButton.BackgroundColor = [0 1 0];
            app.ScanAllButton.FontWeight = 'bold';
            app.ScanAllButton.Layout.Row = 2;
            app.ScanAllButton.Layout.Column = [1 2];
            app.ScanAllButton.Text = 'Scan All';

            % Create WSAppButton
            app.WSAppButton = uibutton(app.GridLayout6, 'push');
            app.WSAppButton.ButtonPushedFcn = createCallbackFcn(app, @WSAppButtonButtonPushed, true);
            app.WSAppButton.Layout.Row = 2;
            app.WSAppButton.Layout.Column = 3;
            app.WSAppButton.Text = 'Show Wirescanner GUI';

            % Create Button
            app.Button = uibutton(app.GridLayout6, 'push');
            app.Button.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.Button.Interruptible = 'off';
            app.Button.Icon = 'logbook.gif';
            app.Button.Layout.Row = [1 2];
            app.Button.Layout.Column = [7 8];
            app.Button.Text = '';

            % Create LinacDropDownLabel
            app.LinacDropDownLabel = uilabel(app.GridLayout6);
            app.LinacDropDownLabel.HorizontalAlignment = 'right';
            app.LinacDropDownLabel.FontWeight = 'bold';
            app.LinacDropDownLabel.Layout.Row = 1;
            app.LinacDropDownLabel.Layout.Column = 1;
            app.LinacDropDownLabel.Text = 'Linac:';

            % Create LiancDropDown
            app.LiancDropDown = uidropdown(app.GridLayout6);
            app.LiancDropDown.Items = {'L2', 'L3'};
            app.LiancDropDown.ValueChangedFcn = createCallbackFcn(app, @LiancDropDownValueChanged, true);
            app.LiancDropDown.FontWeight = 'bold';
            app.LiancDropDown.Layout.Row = 1;
            app.LiancDropDown.Layout.Column = 2;
            app.LiancDropDown.Value = 'L2';

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