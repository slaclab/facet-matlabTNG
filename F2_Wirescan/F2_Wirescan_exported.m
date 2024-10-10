git statclassdef F2_Wirescan_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        F2_WirescanUIFigure           matlab.ui.Figure
        DataMenu                      matlab.ui.container.Menu
        LoadMenu                      matlab.ui.container.Menu
        SaveAsMenu                    matlab.ui.container.Menu
        ExpertMenu                    matlab.ui.container.Menu
        EDMPanelMenu                  matlab.ui.container.Menu
        GridLayout                    matlab.ui.container.GridLayout
        LeftPanel                     matlab.ui.container.Panel
        MeasurementPanel              matlab.ui.container.Panel
        GridLayout5                   matlab.ui.container.GridLayout
        StartScanButton               matlab.ui.control.Button
        AbortScanButton               matlab.ui.control.Button
        ButtonGroup                   matlab.ui.container.ButtonGroup
        XButton                       matlab.ui.control.RadioButton
        YButton                       matlab.ui.control.RadioButton
        UButton                       matlab.ui.control.RadioButton
        WIREDropDownLabel             matlab.ui.control.Label
        WIREDropDown                  matlab.ui.control.DropDown
        PMTDropDownLabel              matlab.ui.control.Label
        PMTDropDown                   matlab.ui.control.DropDown
        ProcessingPanel               matlab.ui.container.Panel
        GridLayout3                   matlab.ui.container.GridLayout
        FitMethodDropDownLabel        matlab.ui.control.Label
        FitMethodDropDown             matlab.ui.control.DropDown
        WirediameterEditFieldLabel    matlab.ui.control.Label
        WirediameterEditField         matlab.ui.control.NumericEditField
        umLabel_5                     matlab.ui.control.Label
        chargeNormPanel               matlab.ui.container.Panel
        GridLayout6                   matlab.ui.container.GridLayout
        ChargeNormalizationCheckBox   matlab.ui.control.CheckBox
        TOROLabel                     matlab.ui.control.Label
        TORODropDown                  matlab.ui.control.DropDown
        jitterCorPanel                matlab.ui.container.Panel
        GridLayout7                   matlab.ui.container.GridLayout
        BPM1DropDown                  matlab.ui.control.DropDown
        BPM2DropDown                  matlab.ui.control.DropDown
        BPM1Label                     matlab.ui.control.Label
        BPM2Label                     matlab.ui.control.Label
        JitterCorrectionCheckBox      matlab.ui.control.CheckBox
        blenWinPanel                  matlab.ui.container.Panel
        GridLayout8                   matlab.ui.container.GridLayout
        BLENDropDown                  matlab.ui.control.DropDown
        BLENLabel                     matlab.ui.control.Label
        EditField_3                   matlab.ui.control.NumericEditField
        Label                         matlab.ui.control.Label
        EditField_4                   matlab.ui.control.NumericEditField
        BunchLengthWindowingCheckBox  matlab.ui.control.CheckBox
        RightPanel                    matlab.ui.container.Panel
        GridLayout2                   matlab.ui.container.GridLayout
        UIAxes                        matlab.ui.control.UIAxes
        ResultPanel                   matlab.ui.container.Panel
        GridLayout9                   matlab.ui.container.GridLayout
        TimestampEditFieldLabel       matlab.ui.control.Label
        ScanTimestamp                 matlab.ui.control.EditField
        FitWidthLabel                 matlab.ui.control.Label
        ScanWidth                     matlab.ui.control.NumericEditField
        FitCenterLabel                matlab.ui.control.Label
        ScanCenter                    matlab.ui.control.NumericEditField
        KurtosisLabel                 matlab.ui.control.Label
        ScanKurt                      matlab.ui.control.NumericEditField
        Label_5                       matlab.ui.control.Label
        ScanWidthError                matlab.ui.control.NumericEditField
        umLabel_3                     matlab.ui.control.Label
        umLabel_4                     matlab.ui.control.Label
        Label_6                       matlab.ui.control.Label
        ScanCenterError               matlab.ui.control.NumericEditField
        SuccessLampLabel              matlab.ui.control.Label
        ScanSuccessLamp               matlab.ui.control.Lamp
        SkewnessLabel                 matlab.ui.control.Label
        ScanSkew                      matlab.ui.control.NumericEditField
        WireRangePanel                matlab.ui.container.Panel
        GridLayout10                  matlab.ui.container.GridLayout
        UnitsDropDownLabel            matlab.ui.control.Label
        UnitsDropDown                 matlab.ui.control.DropDown
        LowerlimitLabel               matlab.ui.control.Label
        UpperlimitLabel               matlab.ui.control.Label
        EditField                     matlab.ui.control.NumericEditField
        umLabel                       matlab.ui.control.Label
        EditField_2                   matlab.ui.control.NumericEditField
        umLabel_2                     matlab.ui.control.Label
        NptsLabel                     matlab.ui.control.Label
        PulsesEditField               matlab.ui.control.NumericEditField
        LogbookButton                 matlab.ui.control.Button
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    
    properties (Access = public)
        aobj % F2_WirescanApp object
        UpdateObj % Object to notify of updated data
        UpdateMethod % Method to call when data is updated
        plane string
    end
    
    methods (Access = public)
        
        function RemoteStartScan(app)
            app.StartScanButtonPushed();
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, LLM, iwire, dim)
            if exist('LLM','var') && ~isempty(LLM)
                if exist('iwire','var')
                    app.aobj = F2_WirescanApp(LLM,iwire,dim) ;
                else
                    app.aobj = F2_WirescanApp(LLM) ;
                end
            elseif exist('iwire','var')
                app.aobj = F2_WirescanApp([],iwire,dim) ;
            else
                app.aobj = F2_WirescanApp();
            end
            app.aobj.AttachGUI(app); % also updates app GUI fields
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.F2_WirescanUIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {595, 595};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {281, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end

        % Menu selected function: EDMPanelMenu
        function EDMPanelMenuSelected(app, event)
            switch string(app.WIREDropDown.Value)
                case "IN10:561"
                    !edm -x -m "DEV=WIRE:IN10:561,MAD=WS10561,AREA=in10,RATEPV=EVNT:SYS1:1:INJECTRATE" /usr/local/facet/tools/edm/display/ws/wirescannerstart.edl &
                case "LI11:444"
                    !edm -x -m "DEV=WIRE:LI11:444,MAD=WS11444,AREA=li11,RATEPV=EVNT:SYS1:1:INJECTRATE" /usr/local/facet/tools/edm/display/ws/wirescannerstart.edl &
                case "LI11:614"
                    !edm -x -m "DEV=WIRE:LI11:614,MAD=WS11614,AREA=li11,RATEPV=EVNT:SYS1:1:INJECTRATE" /usr/local/facet/tools/edm/display/ws/wirescannerstart.edl &
                case "LI11:744"
                    !edm -x -m "DEV=WIRE:LI11:744,MAD=WS11744,AREA=li11,RATEPV=EVNT:SYS1:1:INJECTRATE" /usr/local/facet/tools/edm/display/ws/wirescannerstart.edl &
                case "LI12:214"
                    !edm -x -m "DEV=WIRE:LI12:214,MAD=WS12214,AREA=li12,RATEPV=EVNT:SYS1:1:INJECTRATE" /usr/local/facet/tools/edm/display/ws/wirescannerstart.edl &
                case "LI18:944"
                    !edm -x -m "DEV=WIRE:LI18:944,MAD=WS18944,AREA=li18,RATEPV=EVNT:SYS1:1:INJECTRATE" /usr/local/facet/tools/edm/display/ws/wirescannerstart.edl &
                case "LI19:144"
                    !edm -x -m "DEV=WIRE:LI19:144,MAD=WS19144,AREA=li19,RATEPV=EVNT:SYS1:1:INJECTRATE" /usr/local/facet/tools/edm/display/ws/wirescannerstart.edl &
                case "LI19:244"
                    !edm -x -m "DEV=WIRE:LI19:244,MAD=WS19244,AREA=li19,RATEPV=EVNT:SYS1:1:INJECTRATE" /usr/local/facet/tools/edm/display/ws/wirescannerstart.edl &
                case "LI19:344"
                    !edm -x -m "DEV=WIRE:LI19:344,MAD=WS19344,AREA=li19,RATEPV=EVNT:SYS1:1:INJECTRATE" /usr/local/facet/tools/edm/display/ws/wirescannerstart.edl &
                case "LI20:3179"
                    !edm -x -m "DEV=WIRE:LI20:3179,MAD=IPWS1,AREA=li20,RATEPV=EVNT:SYS1:1:INJECTRATE" /usr/local/facet/tools/edm/display/ws/wirescannerstart.edl &
                case "LI20:3206"
                    !edm -x -m "DEV=WIRE:LI20:3206,MAD=IPWS3,AREA=li20,RATEPV=EVNT:SYS1:1:INJECTRATE" /usr/local/facet/tools/edm/display/ws/wirescannerstart.edl &
      end
        end

        % Menu selected function: LoadMenu
        function LoadMenuSelected(app, event)
      [fn,pn]=uigetfile(F2C.datadir+"/F2_Wirescan*.mat", 'Pick WS data file');
      if isequal(fn,0)
        return
      end
      app.aobj.confload(fullfile(pn,fn));
        end

        % Menu selected function: SaveAsMenu
        function SaveAsMenuSelected(app, event)
      [fn,pn]=uiputfile(F2C.datadir, 'WS data file');
      if isequal(fn,0)
        return
      end
      app.aobj.confsave(fullfile(pn,fn));
        end

        % Selection changed function: ButtonGroup
        function ButtonGroupSelectionChanged(app, event)
      app.aobj.ResetData;
      cla(app.UIAxes); reset(app.UIAxes);
      selectedButton = app.ButtonGroup.SelectedObject;
      switch selectedButton
        case app.XButton
          app.aobj.plane="x";
          app.plane="x";
        case app.YButton
          app.aobj.plane="y";
          app.plane="y";
        case app.UButton
          app.aobj.plane="u";
          app.plane="u";
      end
      app.aobj.guiupdate;
        end

        % Value changed function: WIREDropDown
        function WIREDropDownValueChanged(app, event)
      app.aobj.ResetData;
      cla(app.UIAxes); reset(app.UIAxes);
      value = app.WIREDropDown.Value;
      app.aobj.wirename = string(value) ;
      app.aobj.guiupdate;
        end

        % Value changed function: PMTDropDown
        function PMTDropDownValueChanged(app, event)
      value = app.PMTDropDown.Value;
      app.aobj.pmtname = value ;
      app.aobj.guiupdate;
      app.aobj.ProcData;
        end

        % Button pushed function: StartScanButton
        function StartScanButtonPushed(app, event)
            app.ScanSuccessLamp.Color='r';
            app.aobj.ResetData;
            cla(app.UIAxes); reset(app.UIAxes); axis(app.UIAxes,'off');
            rectangle(app.UIAxes,'Position',[0,0.4,0/100,0.2],'facecolor','g');axis(app.UIAxes,[0 1 0 1]);
            title(app.UIAxes,'Scan Progress...');
            text(app.UIAxes,max([0 0/100-0.1]),0.5,sprintf('%.1f %%',0));
            drawnow
            try
                app.aobj.StartScan ;
            catch ME
                errordlg("Scan failed - see xterm window","Scan Failed");
                eDefRelease(app.aobj.edef);
                throw(ME);
            end
        end

        % Button pushed function: AbortScanButton
        function AbortScanButtonPushed(app, event)
      app.aobj.AbortScan=true ;
        end

        % Value changed function: JitterCorrectionCheckBox
        function JitterCorrectionCheckBoxValueChanged(app, event)
      value = app.JitterCorrectionCheckBox.Value;
      app.aobj.jittercor = value;
      app.aobj.guiupdate ;
      app.aobj.ProcData;
        end

        % Value changed function: BPM1DropDown
        function BPM1DropDownValueChanged(app, event)
      app.aobj.ResetData;
      cla(app.UIAxes); reset(app.UIAxes);
      value = "BPMS:"+app.BPM1DropDown.Value;
      isel = find(app.aobj.bpms==value);
      if ~isempty(isel)
        app.aobj.bpmsel(1)=isel;
      end
      app.aobj.guiupdate;
        end

        % Value changed function: ChargeNormalizationCheckBox
        function ChargeNormalizationCheckBoxValueChanged(app, event)
      value = app.ChargeNormalizationCheckBox.Value;
      app.aobj.chargenorm = value ;
      app.aobj.guiupdate;
      app.aobj.ProcData;
        end

        % Value changed function: TORODropDown
        function TORODropDownValueChanged(app, event)
      value = app.TORODropDown.Value;
      app.aobj.toroname = value ;
      app.aobj.guiupdate;
      app.aobj.ProcData;
        end

        % Value changed function: BunchLengthWindowingCheckBox
        function BunchLengthWindowingCheckBoxValueChanged(app, event)
      value = app.BunchLengthWindowingCheckBox.Value;
      app.aobj.blenwin = value ;
      app.aobj.guiupdate ;
      app.aobj.ProcData;
        end

        % Value changed function: BLENDropDown
        function BLENDropDownValueChanged(app, event)
      value = app.BLENDropDown.Value;
      app.aobj.blmname = value ;
      app.aobj.guiupdate;
        end

        % Value changed function: EditField_3
        function EditField_3ValueChanged(app, event)
      val1 = app.EditField_3.Value;
      val2 = app.EditField_4.Value;
      app.aobj.blenwin=[val1 val2];
      app.aobj.guiupdate;
        end

        % Value changed function: EditField_4
        function EditField_4ValueChanged(app, event)
      val1 = app.EditField_3.Value;
      val2 = app.EditField_4.Value;
      app.aobj.blenwin=[val1 val2];
      app.aobj.guiupdate;
        end

        % Value changed function: UnitsDropDown
        function UnitsDropDownValueChanged(app, event)
      app.aobj.guiupdate;
        end

        % Value changed function: EditField
        function EditFieldValueChanged(app, event)
      val1 = app.EditField.Value;
      val2 = app.EditField_2.Value;
      switch app.UnitsDropDown.Value
        case "Position"
          app.aobj.pos_range=[val1 val2].*1e-6;
        otherwise
          app.aobj.motor_range=[val1 val2].*1e-6;
      end
      app.aobj.guiupdate;
        end

        % Value changed function: EditField_2
        function EditField_2ValueChanged(app, event)
      val1 = app.EditField.Value;
      val2 = app.EditField_2.Value;
      switch app.UnitsDropDown.Value
        case "Position"
          app.aobj.pos_range=[val1 val2].*1e-6;
        otherwise
          app.aobj.motor_range=[val1 val2].*1e-6;
      end
      app.aobj.guiupdate;
        end

        % Value changed function: PulsesEditField
        function PulsesEditFieldValueChanged(app, event)
      value = app.PulsesEditField.Value;
      app.aobj.npulses = value ;
      app.aobj.guiupdate;
        end

        % Button pushed function: LogbookButton
        function LogbookButtonPushed(app, event)
            fh=figure;
            ahan=axes(fh);
            app.aobj.ProcData(ahan);
            
            ts_str = sprintf('scan completed at: %s', app.ScanTimestamp.Value);
            fit_str = sprintf('fit method: %s', app.aobj.fitmethod);
            ws_msmt_1 = sprintf('  sig%s = %.3f  +/- %.2f um\n  %s = %.3f +/- %.2f um', ...
                app.aobj.plane, app.ScanWidth.Value, app.ScanWidthError.Value, ...
                app.aobj.plane, app.ScanCenter.Value, app.ScanCenterError.Value);
            ws_msmt_2 = sprintf('  skew = %.3f \t kurt = %.3f\t', app.ScanSkew.Value, app.ScanKurt.Value);
            log_msg = sprintf('%s\n%s\n%s\n%s\n', ts_str, fit_str, ws_msmt_1, ws_msmt_2);
            
            util_printLog2020(fh, 'title',sprintf('%s Wire Scan (%c)',char(app.aobj.wirename),char(app.aobj.plane)),'author','F2_Wirescan.m','text',log_msg);
            delete(fh);
        end

        % Value changed function: FitMethodDropDown
        function FitMethodDropDownValueChanged(app, event)
      value = app.FitMethodDropDown.Value;
      switch string(value)
        case "Gaussian"
          app.aobj.fitmethod="gauss";
        case "Asymm Gaussian"
          app.aobj.fitmethod="agauss";
        case "Asymm Gaussian (2)"
          app.aobj.fitmethod="agauss2";
      end
      app.aobj.ProcData;
        end

        % Value changed function: BPM2DropDown
        function BPM2DropDownValueChanged(app, event)
      app.aobj.ResetData;
      cla(app.UIAxes); reset(app.UIAxes);
      value = "BPMS:"+app.BPM2DropDown.Value;
      isel = find(app.aobj.bpms==value);
      if ~isempty(isel)
        app.aobj.bpmsel(2)=isel;
      end
      app.aobj.guiupdate;
        end

        % Close request function: F2_WirescanUIFigure
        function F2_WirescanUIFigureCloseRequest(app, event)
      delete(app)
      
        end

        % Value changed function: WirediameterEditField
        function WirediameterEditFieldValueChanged(app, event)
      value = app.WirediameterEditField.Value;
      app.aobj.WireDiam = value ;
      app.aobj.guiupdate;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create F2_WirescanUIFigure and hide until all components are created
            app.F2_WirescanUIFigure = uifigure('Visible', 'off');
            app.F2_WirescanUIFigure.AutoResizeChildren = 'off';
            app.F2_WirescanUIFigure.Position = [100 100 996 595];
            app.F2_WirescanUIFigure.Name = 'F2_Wirescan';
            app.F2_WirescanUIFigure.CloseRequestFcn = createCallbackFcn(app, @F2_WirescanUIFigureCloseRequest, true);
            app.F2_WirescanUIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create DataMenu
            app.DataMenu = uimenu(app.F2_WirescanUIFigure);
            app.DataMenu.Text = 'Data';

            % Create LoadMenu
            app.LoadMenu = uimenu(app.DataMenu);
            app.LoadMenu.MenuSelectedFcn = createCallbackFcn(app, @LoadMenuSelected, true);
            app.LoadMenu.Text = 'Load...';

            % Create SaveAsMenu
            app.SaveAsMenu = uimenu(app.DataMenu);
            app.SaveAsMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveAsMenuSelected, true);
            app.SaveAsMenu.Text = 'Save As...';

            % Create ExpertMenu
            app.ExpertMenu = uimenu(app.F2_WirescanUIFigure);
            app.ExpertMenu.Text = 'Expert';

            % Create EDMPanelMenu
            app.EDMPanelMenu = uimenu(app.ExpertMenu);
            app.EDMPanelMenu.MenuSelectedFcn = createCallbackFcn(app, @EDMPanelMenuSelected, true);
            app.EDMPanelMenu.Text = 'EDM Panel...';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.F2_WirescanUIFigure);
            app.GridLayout.ColumnWidth = {281, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create MeasurementPanel
            app.MeasurementPanel = uipanel(app.LeftPanel);
            app.MeasurementPanel.Title = 'Measurement';
            app.MeasurementPanel.Position = [7 394 266 190];

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.MeasurementPanel);
            app.GridLayout5.ColumnWidth = {'100x', '100x', '100x'};
            app.GridLayout5.RowHeight = {30, 22, 22, 30, 30};
            app.GridLayout5.RowSpacing = 5.16666666666667;
            app.GridLayout5.Padding = [10 5.16666666666667 10 5.16666666666667];

            % Create StartScanButton
            app.StartScanButton = uibutton(app.GridLayout5, 'push');
            app.StartScanButton.ButtonPushedFcn = createCallbackFcn(app, @StartScanButtonPushed, true);
            app.StartScanButton.BackgroundColor = [0.3922 0.8314 0.0745];
            app.StartScanButton.FontWeight = 'bold';
            app.StartScanButton.Layout.Row = 4;
            app.StartScanButton.Layout.Column = [1 3];
            app.StartScanButton.Text = 'Start Scan';

            % Create AbortScanButton
            app.AbortScanButton = uibutton(app.GridLayout5, 'push');
            app.AbortScanButton.ButtonPushedFcn = createCallbackFcn(app, @AbortScanButtonPushed, true);
            app.AbortScanButton.Interruptible = 'off';
            app.AbortScanButton.BackgroundColor = [0.851 0.3255 0.098];
            app.AbortScanButton.FontWeight = 'bold';
            app.AbortScanButton.FontColor = [1 1 1];
            app.AbortScanButton.Layout.Row = 5;
            app.AbortScanButton.Layout.Column = [1 3];
            app.AbortScanButton.Text = 'Abort Scan';

            % Create ButtonGroup
            app.ButtonGroup = uibuttongroup(app.GridLayout5);
            app.ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ButtonGroupSelectionChanged, true);
            app.ButtonGroup.Layout.Row = 1;
            app.ButtonGroup.Layout.Column = [1 3];

            % Create XButton
            app.XButton = uiradiobutton(app.ButtonGroup);
            app.XButton.Text = 'X';
            app.XButton.FontWeight = 'bold';
            app.XButton.Position = [11 4 58 22];
            app.XButton.Value = true;

            % Create YButton
            app.YButton = uiradiobutton(app.ButtonGroup);
            app.YButton.Text = 'Y';
            app.YButton.FontWeight = 'bold';
            app.YButton.Position = [88 4 65 22];

            % Create UButton
            app.UButton = uiradiobutton(app.ButtonGroup);
            app.UButton.Text = 'U';
            app.UButton.FontWeight = 'bold';
            app.UButton.Position = [172 4 65 22];

            % Create WIREDropDownLabel
            app.WIREDropDownLabel = uilabel(app.GridLayout5);
            app.WIREDropDownLabel.HorizontalAlignment = 'right';
            app.WIREDropDownLabel.FontWeight = 'bold';
            app.WIREDropDownLabel.Layout.Row = 2;
            app.WIREDropDownLabel.Layout.Column = 1;
            app.WIREDropDownLabel.Text = 'WIRE:';

            % Create WIREDropDown
            app.WIREDropDown = uidropdown(app.GridLayout5);
            app.WIREDropDown.Items = {'IN10:561', 'LI11:444', 'LI11:614', 'LI11:744', 'LI12:214', 'LI18:944', 'LI19:144', 'LI19:244', 'LI19:344'};
            app.WIREDropDown.ValueChangedFcn = createCallbackFcn(app, @WIREDropDownValueChanged, true);
            app.WIREDropDown.Layout.Row = 2;
            app.WIREDropDown.Layout.Column = [2 3];
            app.WIREDropDown.Value = 'IN10:561';

            % Create PMTDropDownLabel
            app.PMTDropDownLabel = uilabel(app.GridLayout5);
            app.PMTDropDownLabel.HorizontalAlignment = 'right';
            app.PMTDropDownLabel.FontWeight = 'bold';
            app.PMTDropDownLabel.Layout.Row = 3;
            app.PMTDropDownLabel.Layout.Column = 1;
            app.PMTDropDownLabel.Text = 'PMT:';

            % Create PMTDropDown
            app.PMTDropDown = uidropdown(app.GridLayout5);
            app.PMTDropDown.Items = {'LI19:144'};
            app.PMTDropDown.ValueChangedFcn = createCallbackFcn(app, @PMTDropDownValueChanged, true);
            app.PMTDropDown.Layout.Row = 3;
            app.PMTDropDown.Layout.Column = [2 3];
            app.PMTDropDown.Value = 'LI19:144';

            % Create ProcessingPanel
            app.ProcessingPanel = uipanel(app.LeftPanel);
            app.ProcessingPanel.Title = 'Processing';
            app.ProcessingPanel.Position = [7 24 269 360];

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.ProcessingPanel);
            app.GridLayout3.ColumnWidth = {90, '100x', '100x', '100x', 'fit'};
            app.GridLayout3.RowHeight = {22, 22, 'fit', 'fit', 'fit'};
            app.GridLayout3.ColumnSpacing = 5;
            app.GridLayout3.RowSpacing = 6.42857142857143;
            app.GridLayout3.Padding = [5 6.42857142857143 5 6.42857142857143];

            % Create FitMethodDropDownLabel
            app.FitMethodDropDownLabel = uilabel(app.GridLayout3);
            app.FitMethodDropDownLabel.HorizontalAlignment = 'right';
            app.FitMethodDropDownLabel.FontWeight = 'bold';
            app.FitMethodDropDownLabel.Layout.Row = 1;
            app.FitMethodDropDownLabel.Layout.Column = 1;
            app.FitMethodDropDownLabel.Text = 'Fit Method:';

            % Create FitMethodDropDown
            app.FitMethodDropDown = uidropdown(app.GridLayout3);
            app.FitMethodDropDown.Items = {'Gaussian', 'Asymm Gaussian', 'Asymm Gaussian (2)'};
            app.FitMethodDropDown.ValueChangedFcn = createCallbackFcn(app, @FitMethodDropDownValueChanged, true);
            app.FitMethodDropDown.Layout.Row = 1;
            app.FitMethodDropDown.Layout.Column = [2 4];
            app.FitMethodDropDown.Value = 'Asymm Gaussian (2)';

            % Create WirediameterEditFieldLabel
            app.WirediameterEditFieldLabel = uilabel(app.GridLayout3);
            app.WirediameterEditFieldLabel.HorizontalAlignment = 'right';
            app.WirediameterEditFieldLabel.Layout.Row = 2;
            app.WirediameterEditFieldLabel.Layout.Column = 1;
            app.WirediameterEditFieldLabel.Text = 'Wire diameter:';

            % Create WirediameterEditField
            app.WirediameterEditField = uieditfield(app.GridLayout3, 'numeric');
            app.WirediameterEditField.ValueChangedFcn = createCallbackFcn(app, @WirediameterEditFieldValueChanged, true);
            app.WirediameterEditField.Layout.Row = 2;
            app.WirediameterEditField.Layout.Column = 2;
            app.WirediameterEditField.Value = 60;

            % Create umLabel_5
            app.umLabel_5 = uilabel(app.GridLayout3);
            app.umLabel_5.Layout.Row = 2;
            app.umLabel_5.Layout.Column = 3;
            app.umLabel_5.Text = 'um';

            % Create chargeNormPanel
            app.chargeNormPanel = uipanel(app.GridLayout3);
            app.chargeNormPanel.Layout.Row = 3;
            app.chargeNormPanel.Layout.Column = [1 5];

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.chargeNormPanel);
            app.GridLayout6.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout6.ColumnSpacing = 5;
            app.GridLayout6.RowSpacing = 5;

            % Create ChargeNormalizationCheckBox
            app.ChargeNormalizationCheckBox = uicheckbox(app.GridLayout6);
            app.ChargeNormalizationCheckBox.ValueChangedFcn = createCallbackFcn(app, @ChargeNormalizationCheckBoxValueChanged, true);
            app.ChargeNormalizationCheckBox.Text = 'Charge Normalization';
            app.ChargeNormalizationCheckBox.Layout.Row = 1;
            app.ChargeNormalizationCheckBox.Layout.Column = [1 2];

            % Create TOROLabel
            app.TOROLabel = uilabel(app.GridLayout6);
            app.TOROLabel.HorizontalAlignment = 'right';
            app.TOROLabel.Layout.Row = 2;
            app.TOROLabel.Layout.Column = 1;
            app.TOROLabel.Text = 'TORO:';

            % Create TORODropDown
            app.TORODropDown = uidropdown(app.GridLayout6);
            app.TORODropDown.Items = {'IN10:431', 'IN10:591', 'LI11:360', 'LI14:890', 'LI20:1988', 'LI20:2040', 'LI20:2452', 'LI20:3163', 'LI20:3255'};
            app.TORODropDown.ValueChangedFcn = createCallbackFcn(app, @TORODropDownValueChanged, true);
            app.TORODropDown.Layout.Row = 2;
            app.TORODropDown.Layout.Column = [2 3];
            app.TORODropDown.Value = 'IN10:431';

            % Create jitterCorPanel
            app.jitterCorPanel = uipanel(app.GridLayout3);
            app.jitterCorPanel.Layout.Row = 4;
            app.jitterCorPanel.Layout.Column = [1 5];

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.jitterCorPanel);
            app.GridLayout7.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout7.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout7.ColumnSpacing = 5;
            app.GridLayout7.RowSpacing = 5;

            % Create BPM1DropDown
            app.BPM1DropDown = uidropdown(app.GridLayout7);
            app.BPM1DropDown.Items = {'---'};
            app.BPM1DropDown.ValueChangedFcn = createCallbackFcn(app, @BPM1DropDownValueChanged, true);
            app.BPM1DropDown.Layout.Row = 2;
            app.BPM1DropDown.Layout.Column = [2 3];
            app.BPM1DropDown.Value = '---';

            % Create BPM2DropDown
            app.BPM2DropDown = uidropdown(app.GridLayout7);
            app.BPM2DropDown.Items = {'---'};
            app.BPM2DropDown.ValueChangedFcn = createCallbackFcn(app, @BPM2DropDownValueChanged, true);
            app.BPM2DropDown.Layout.Row = 3;
            app.BPM2DropDown.Layout.Column = [2 3];
            app.BPM2DropDown.Value = '---';

            % Create BPM1Label
            app.BPM1Label = uilabel(app.GridLayout7);
            app.BPM1Label.HorizontalAlignment = 'right';
            app.BPM1Label.Layout.Row = 2;
            app.BPM1Label.Layout.Column = 1;
            app.BPM1Label.Text = 'BPM1:';

            % Create BPM2Label
            app.BPM2Label = uilabel(app.GridLayout7);
            app.BPM2Label.HorizontalAlignment = 'right';
            app.BPM2Label.Layout.Row = 3;
            app.BPM2Label.Layout.Column = 1;
            app.BPM2Label.Text = 'BPM2:';

            % Create JitterCorrectionCheckBox
            app.JitterCorrectionCheckBox = uicheckbox(app.GridLayout7);
            app.JitterCorrectionCheckBox.ValueChangedFcn = createCallbackFcn(app, @JitterCorrectionCheckBoxValueChanged, true);
            app.JitterCorrectionCheckBox.Text = 'Jitter Correction';
            app.JitterCorrectionCheckBox.Layout.Row = 1;
            app.JitterCorrectionCheckBox.Layout.Column = [1 2];

            % Create blenWinPanel
            app.blenWinPanel = uipanel(app.GridLayout3);
            app.blenWinPanel.Layout.Row = 5;
            app.blenWinPanel.Layout.Column = [1 5];

            % Create GridLayout8
            app.GridLayout8 = uigridlayout(app.blenWinPanel);
            app.GridLayout8.ColumnWidth = {'1x', '1x', 'fit', '1x'};
            app.GridLayout8.RowHeight = {22, 22, '1x'};
            app.GridLayout8.ColumnSpacing = 5;
            app.GridLayout8.RowSpacing = 5;

            % Create BLENDropDown
            app.BLENDropDown = uidropdown(app.GridLayout8);
            app.BLENDropDown.Items = {'---'};
            app.BLENDropDown.ValueChangedFcn = createCallbackFcn(app, @BLENDropDownValueChanged, true);
            app.BLENDropDown.Layout.Row = 2;
            app.BLENDropDown.Layout.Column = [2 4];
            app.BLENDropDown.Value = '---';

            % Create BLENLabel
            app.BLENLabel = uilabel(app.GridLayout8);
            app.BLENLabel.HorizontalAlignment = 'right';
            app.BLENLabel.Layout.Row = 2;
            app.BLENLabel.Layout.Column = 1;
            app.BLENLabel.Text = 'BLEN:';

            % Create EditField_3
            app.EditField_3 = uieditfield(app.GridLayout8, 'numeric');
            app.EditField_3.ValueChangedFcn = createCallbackFcn(app, @EditField_3ValueChanged, true);
            app.EditField_3.Layout.Row = 3;
            app.EditField_3.Layout.Column = 2;

            % Create Label
            app.Label = uilabel(app.GridLayout8);
            app.Label.Layout.Row = 3;
            app.Label.Layout.Column = 3;
            app.Label.Text = '---';

            % Create EditField_4
            app.EditField_4 = uieditfield(app.GridLayout8, 'numeric');
            app.EditField_4.ValueChangedFcn = createCallbackFcn(app, @EditField_4ValueChanged, true);
            app.EditField_4.Layout.Row = 3;
            app.EditField_4.Layout.Column = 4;

            % Create BunchLengthWindowingCheckBox
            app.BunchLengthWindowingCheckBox = uicheckbox(app.GridLayout8);
            app.BunchLengthWindowingCheckBox.ValueChangedFcn = createCallbackFcn(app, @BunchLengthWindowingCheckBoxValueChanged, true);
            app.BunchLengthWindowingCheckBox.Enable = 'off';
            app.BunchLengthWindowingCheckBox.Text = 'Bunch Length Windowing';
            app.BunchLengthWindowingCheckBox.Layout.Row = 1;
            app.BunchLengthWindowingCheckBox.Layout.Column = [1 4];

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.RightPanel);
            app.GridLayout2.ColumnWidth = {10, 211, '1x', 351, 10, 76, 10};
            app.GridLayout2.RowHeight = {'1x', 40, 40, 40, 10};
            app.GridLayout2.ColumnSpacing = 2.375;
            app.GridLayout2.RowSpacing = 3.28571428571429;
            app.GridLayout2.Padding = [2.375 3.28571428571429 2.375 3.28571428571429];

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout2);
            title(app.UIAxes, '')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            app.UIAxes.FontSize = 14;
            app.UIAxes.Layout.Row = 1;
            app.UIAxes.Layout.Column = [1 7];

            % Create ResultPanel
            app.ResultPanel = uipanel(app.GridLayout2);
            app.ResultPanel.Title = 'Result';
            app.ResultPanel.Layout.Row = [2 4];
            app.ResultPanel.Layout.Column = 4;
            app.ResultPanel.FontWeight = 'bold';

            % Create GridLayout9
            app.GridLayout9 = uigridlayout(app.ResultPanel);
            app.GridLayout9.ColumnWidth = {'fit', '1x', 'fit', 50, 'fit', '1x', 'fit'};
            app.GridLayout9.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout9.ColumnSpacing = 5;
            app.GridLayout9.RowSpacing = 5;
            app.GridLayout9.Padding = [5 5 5 5];

            % Create TimestampEditFieldLabel
            app.TimestampEditFieldLabel = uilabel(app.GridLayout9);
            app.TimestampEditFieldLabel.HorizontalAlignment = 'right';
            app.TimestampEditFieldLabel.Layout.Row = 3;
            app.TimestampEditFieldLabel.Layout.Column = [4 7];
            app.TimestampEditFieldLabel.Text = 'Timestamp';

            % Create ScanTimestamp
            app.ScanTimestamp = uieditfield(app.GridLayout9, 'text');
            app.ScanTimestamp.Editable = 'off';
            app.ScanTimestamp.HorizontalAlignment = 'right';
            app.ScanTimestamp.Layout.Row = 4;
            app.ScanTimestamp.Layout.Column = [4 7];
            app.ScanTimestamp.Value = 'YYYY-MM-DD hh:mm:ss';

            % Create FitWidthLabel
            app.FitWidthLabel = uilabel(app.GridLayout9);
            app.FitWidthLabel.HorizontalAlignment = 'right';
            app.FitWidthLabel.FontWeight = 'bold';
            app.FitWidthLabel.Layout.Row = 1;
            app.FitWidthLabel.Layout.Column = 1;
            app.FitWidthLabel.Text = 'Fit Width:';

            % Create ScanWidth
            app.ScanWidth = uieditfield(app.GridLayout9, 'numeric');
            app.ScanWidth.ValueDisplayFormat = '%.1f';
            app.ScanWidth.Editable = 'off';
            app.ScanWidth.Layout.Row = 1;
            app.ScanWidth.Layout.Column = 2;

            % Create FitCenterLabel
            app.FitCenterLabel = uilabel(app.GridLayout9);
            app.FitCenterLabel.HorizontalAlignment = 'right';
            app.FitCenterLabel.Layout.Row = 2;
            app.FitCenterLabel.Layout.Column = 1;
            app.FitCenterLabel.Text = 'Fit Center:';

            % Create ScanCenter
            app.ScanCenter = uieditfield(app.GridLayout9, 'numeric');
            app.ScanCenter.ValueDisplayFormat = '%.1f';
            app.ScanCenter.Editable = 'off';
            app.ScanCenter.Layout.Row = 2;
            app.ScanCenter.Layout.Column = 2;

            % Create KurtosisLabel
            app.KurtosisLabel = uilabel(app.GridLayout9);
            app.KurtosisLabel.HorizontalAlignment = 'right';
            app.KurtosisLabel.Layout.Row = 4;
            app.KurtosisLabel.Layout.Column = 1;
            app.KurtosisLabel.Text = 'Kurtosis';

            % Create ScanKurt
            app.ScanKurt = uieditfield(app.GridLayout9, 'numeric');
            app.ScanKurt.Editable = 'off';
            app.ScanKurt.Layout.Row = 4;
            app.ScanKurt.Layout.Column = 2;

            % Create Label_5
            app.Label_5 = uilabel(app.GridLayout9);
            app.Label_5.HorizontalAlignment = 'right';
            app.Label_5.Layout.Row = 1;
            app.Label_5.Layout.Column = 3;
            app.Label_5.Text = '+/-';

            % Create ScanWidthError
            app.ScanWidthError = uieditfield(app.GridLayout9, 'numeric');
            app.ScanWidthError.ValueDisplayFormat = '%.1f';
            app.ScanWidthError.Editable = 'off';
            app.ScanWidthError.Layout.Row = 1;
            app.ScanWidthError.Layout.Column = 4;

            % Create umLabel_3
            app.umLabel_3 = uilabel(app.GridLayout9);
            app.umLabel_3.Layout.Row = 1;
            app.umLabel_3.Layout.Column = 5;
            app.umLabel_3.Text = 'um';

            % Create umLabel_4
            app.umLabel_4 = uilabel(app.GridLayout9);
            app.umLabel_4.Layout.Row = 2;
            app.umLabel_4.Layout.Column = 5;
            app.umLabel_4.Text = 'um';

            % Create Label_6
            app.Label_6 = uilabel(app.GridLayout9);
            app.Label_6.HorizontalAlignment = 'right';
            app.Label_6.Layout.Row = 2;
            app.Label_6.Layout.Column = 3;
            app.Label_6.Text = '+/-';

            % Create ScanCenterError
            app.ScanCenterError = uieditfield(app.GridLayout9, 'numeric');
            app.ScanCenterError.ValueDisplayFormat = '%.1f';
            app.ScanCenterError.Editable = 'off';
            app.ScanCenterError.Layout.Row = 2;
            app.ScanCenterError.Layout.Column = 4;

            % Create SuccessLampLabel
            app.SuccessLampLabel = uilabel(app.GridLayout9);
            app.SuccessLampLabel.HorizontalAlignment = 'right';
            app.SuccessLampLabel.FontWeight = 'bold';
            app.SuccessLampLabel.Layout.Row = 1;
            app.SuccessLampLabel.Layout.Column = 6;
            app.SuccessLampLabel.Text = 'Success';

            % Create ScanSuccessLamp
            app.ScanSuccessLamp = uilamp(app.GridLayout9);
            app.ScanSuccessLamp.Layout.Row = 1;
            app.ScanSuccessLamp.Layout.Column = 7;
            app.ScanSuccessLamp.Color = [1 0 0];

            % Create SkewnessLabel
            app.SkewnessLabel = uilabel(app.GridLayout9);
            app.SkewnessLabel.HorizontalAlignment = 'right';
            app.SkewnessLabel.Layout.Row = 3;
            app.SkewnessLabel.Layout.Column = 1;
            app.SkewnessLabel.Text = 'Skewness:';

            % Create ScanSkew
            app.ScanSkew = uieditfield(app.GridLayout9, 'numeric');
            app.ScanSkew.Editable = 'off';
            app.ScanSkew.Layout.Row = 3;
            app.ScanSkew.Layout.Column = 2;

            % Create WireRangePanel
            app.WireRangePanel = uipanel(app.GridLayout2);
            app.WireRangePanel.Title = 'Wire Range';
            app.WireRangePanel.Layout.Row = [2 4];
            app.WireRangePanel.Layout.Column = 2;

            % Create GridLayout10
            app.GridLayout10 = uigridlayout(app.WireRangePanel);
            app.GridLayout10.ColumnWidth = {'1x', 80, 'fit'};
            app.GridLayout10.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout10.RowSpacing = 5;
            app.GridLayout10.Padding = [5 5 5 5];

            % Create UnitsDropDownLabel
            app.UnitsDropDownLabel = uilabel(app.GridLayout10);
            app.UnitsDropDownLabel.HorizontalAlignment = 'right';
            app.UnitsDropDownLabel.Layout.Row = 1;
            app.UnitsDropDownLabel.Layout.Column = 1;
            app.UnitsDropDownLabel.Text = 'Units:';

            % Create UnitsDropDown
            app.UnitsDropDown = uidropdown(app.GridLayout10);
            app.UnitsDropDown.Items = {'Motor', 'Position'};
            app.UnitsDropDown.ValueChangedFcn = createCallbackFcn(app, @UnitsDropDownValueChanged, true);
            app.UnitsDropDown.Layout.Row = 1;
            app.UnitsDropDown.Layout.Column = 2;
            app.UnitsDropDown.Value = 'Position';

            % Create LowerlimitLabel
            app.LowerlimitLabel = uilabel(app.GridLayout10);
            app.LowerlimitLabel.HorizontalAlignment = 'right';
            app.LowerlimitLabel.Layout.Row = 2;
            app.LowerlimitLabel.Layout.Column = 1;
            app.LowerlimitLabel.Text = 'Lower limit:';

            % Create UpperlimitLabel
            app.UpperlimitLabel = uilabel(app.GridLayout10);
            app.UpperlimitLabel.HorizontalAlignment = 'right';
            app.UpperlimitLabel.Layout.Row = 3;
            app.UpperlimitLabel.Layout.Column = 1;
            app.UpperlimitLabel.Text = 'Upper limit:';

            % Create EditField
            app.EditField = uieditfield(app.GridLayout10, 'numeric');
            app.EditField.ValueDisplayFormat = '%.0f';
            app.EditField.ValueChangedFcn = createCallbackFcn(app, @EditFieldValueChanged, true);
            app.EditField.Layout.Row = 2;
            app.EditField.Layout.Column = 2;

            % Create umLabel
            app.umLabel = uilabel(app.GridLayout10);
            app.umLabel.Layout.Row = 2;
            app.umLabel.Layout.Column = 3;
            app.umLabel.Text = 'um';

            % Create EditField_2
            app.EditField_2 = uieditfield(app.GridLayout10, 'numeric');
            app.EditField_2.ValueDisplayFormat = '%.0f';
            app.EditField_2.ValueChangedFcn = createCallbackFcn(app, @EditField_2ValueChanged, true);
            app.EditField_2.Layout.Row = 3;
            app.EditField_2.Layout.Column = 2;

            % Create umLabel_2
            app.umLabel_2 = uilabel(app.GridLayout10);
            app.umLabel_2.Layout.Row = 3;
            app.umLabel_2.Layout.Column = 3;
            app.umLabel_2.Text = 'um';

            % Create NptsLabel
            app.NptsLabel = uilabel(app.GridLayout10);
            app.NptsLabel.HorizontalAlignment = 'right';
            app.NptsLabel.Layout.Row = 4;
            app.NptsLabel.Layout.Column = 1;
            app.NptsLabel.Text = 'N pts:';

            % Create PulsesEditField
            app.PulsesEditField = uieditfield(app.GridLayout10, 'numeric');
            app.PulsesEditField.ValueChangedFcn = createCallbackFcn(app, @PulsesEditFieldValueChanged, true);
            app.PulsesEditField.Layout.Row = 4;
            app.PulsesEditField.Layout.Column = 2;
            app.PulsesEditField.Value = 100;

            % Create LogbookButton
            app.LogbookButton = uibutton(app.GridLayout2, 'push');
            app.LogbookButton.ButtonPushedFcn = createCallbackFcn(app, @LogbookButtonPushed, true);
            app.LogbookButton.Interruptible = 'off';
            app.LogbookButton.Icon = 'logbook.gif';
            app.LogbookButton.IconAlignment = 'bottom';
            app.LogbookButton.FontWeight = 'bold';
            app.LogbookButton.Layout.Row = [2 3];
            app.LogbookButton.Layout.Column = 6;
            app.LogbookButton.Text = 'Logbook';

            % Show the figure after all components are created
            app.F2_WirescanUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_Wirescan_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.F2_WirescanUIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.F2_WirescanUIFigure)
        end
    end
end