classdef F2_BSAGUI_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        PVListA                       matlab.ui.control.ListBox
        PVListB                       matlab.ui.control.ListBox
        ResetB                        matlab.ui.control.Button
        ResetA                        matlab.ui.control.Button
        eDefMenu                      matlab.ui.control.DropDown
        AcquireNewDataButton          matlab.ui.control.Button
        SaveDataButton                matlab.ui.control.Button
        SaveDataAsButton              matlab.ui.control.Button
        LoadDataButton                matlab.ui.control.Button
        PSDLow                        matlab.ui.control.NumericEditField
        PSDHigh                       matlab.ui.control.NumericEditField
        PSDRangeLabel                 matlab.ui.control.Label
        NumberActualLabel             matlab.ui.control.Label
        N_Actual                      matlab.ui.control.Label
        DataAqText                    matlab.ui.control.Label
        BSALabel                      matlab.ui.control.Label
        PointRange                    matlab.ui.control.Label
        eDefSetupButton               matlab.ui.control.Button
        Status                        matlab.ui.control.Label
        SearchAEditFieldLabel         matlab.ui.control.Label
        SearchPVA                     matlab.ui.control.EditField
        SearchBEditFieldLabel         matlab.ui.control.Label
        SearchPVB                     matlab.ui.control.EditField
        NumberofPointsEditFieldLabel  matlab.ui.control.Label
        NumberofPointsEditField       matlab.ui.control.NumericEditField
        PlotVarYDropDownLabel         matlab.ui.control.Label
        PlotVarYDropDown              matlab.ui.control.DropDown
        PlotVarXDropDownLabel         matlab.ui.control.Label
        PlotVarXDropDown              matlab.ui.control.DropDown
        CreateNewVariableButton       matlab.ui.control.Button
        PlotButton                    matlab.ui.control.Button
        AdvancedOptionsButton         matlab.ui.control.Button
        PlotOrbitButton               matlab.ui.control.Button
        MIAButton                     matlab.ui.control.Button
        WaitEnoloadCheckBox           matlab.ui.control.CheckBox
        RateLabel                     matlab.ui.control.Label
        LinacSwitch                   matlab.ui.control.Switch
        MultiplotCheckBox             matlab.ui.control.CheckBox
        PulseOffsetEditFieldLabel     matlab.ui.control.Label
        OffsetEditField               matlab.ui.control.NumericEditField
        SCMPSViewerButton             matlab.ui.control.Button
        AcquireSCPCheckBox            matlab.ui.control.CheckBox
    end

    
    properties (Access = public)
        mdl % BSA_GUI_model object containing data and app state
        fileName % name of file to save to
        
        % child apps
%         orbitPlotter
%         advancedOptionsWindow
%         MIAWindow
%         newVarWindow
%         MPSWindow

        STDERR = 2
        
        % listeners
        StatusListener
        AcqStatusListener
        eDefOptionsListener
        PlotOptionsListener
        PVListListener
        NumPointsListener
        BufferRatesListener
        PVListener
        DataAcqListener
        AcqSCPListener
        InitListener
    end
    
    methods (Access = public) % VIEW
        
        function activate(app)
            %Correct bug with edit fields on window open
            app.UIFigure.WindowState='minimized';
            drawnow();
            app.UIFigure.WindowState='normal';
            drawnow();
            app.SearchPVA.Value='';
        end
        
        function cleaneDefs(app)
            % release active eDef and reset eDefMenu items
            [~,i] = setdiff(app.mdl.eDefs, app.eDefMenu.Items);
            app.eDefMenu.Items(i) = app.mdl.eDefs(i);
        end
        
        function deleteWindow(app, window)
            if ~isempty(app.(window))
                delete(app.(window));
            end
        end
        
        function onInit(app)
            if app.mdl.dev
                devInit(app);
            elseif app.mdl.facet
                facetInit(app);
            end
        end
        
        function devInit(app)
            % Adjust interface for use on a development server
            app.AcquireNewDataButton.Text = ['Acquire From' newline 'BSA Datastore'];
            % app.eDefMenu.Items=[{'CUH Datastore'}, {'CUS Datastore'}, app.eDefMenu.Items];
            % uncomment above line to incorporate live buffer reads on dev
            app.eDefMenu.Items = app.mdl.eDefs; % delete once live buffer reads are incorporated
            app.LinacSwitch.Visible = false;
            app.NumberofPointsEditField.Enable = 0;
            app.NumberofPointsEditFieldLabel.Enable = 0;
            app.PointRange.Enable = 0;
            app.PlotVarXDropDown.Items = [app.PlotVarXDropDown.Items,{'PSD Over Time'}];
        end
        
        function facetInit(app)
            % Set interface for use on FACER server
            app.eDefMenu.Items = app.mdl.eDefs; % delete once live buffer reads are incorporated
            app.LinacSwitch.Visible = false;
        end
        
        function externalSave(app,~)
            % Allow another function to save the in app data
            saveData(app.mdl, 0);
        end
        
        function errorMessage(app, ex, callbackMessage)
            err = ex.stack(1);
            file = err.file; funcname = err.name; linenum = num2str(err.line);
            file = strsplit(file, '/'); file = file{end};
            loc = sprintf('File: %s   Function: %s   Line: %s', file, funcname, linenum);
            uiwait(errordlg(...
                    lprintf(app.STDERR, '%s%c%s%c%s', callbackMessage, newline, ex.message, newline, loc)));
        end
        
        function onStatusChanged(app)
            % callback for status  listener
            app.Status.Text = app.mdl.status; 
            drawnow;
        end
        
        function onAcqStatusChanged(app)
            % callback for acquisition status listener
            app.DataAqText.Text = app.mdl.dataAcqStatus;
            drawnow;
        end
        
        function oneDefOptionsChanged(app)
            % callback for eDef menu options listener, changes available
            % eDefs based on current app conditions
            if app.mdl.have_eDef
                cleaneDefs(app);
            end
            app.eDefMenu.Items = app.mdl.eDefs;
            app.eDefMenu.Value = app.mdl.eDefStr;
            onBufferRatesChanged(app); % update buffer rates
        end
        
        function onPlotOptionsChanged(app)
            % callback for plot optinos listener
            app.PlotVarXDropDown.Items = app.mdl.optx;
            app.PlotVarYDropDown.Items = app.mdl.opty;
        end
        
        function onPVListChanged(app)
            app.PVListA.Items = app.mdl.PVListA;
            app.PVListB.Items = app.mdl.PVListB;
            if isempty(app.mdl.PVA) || ~any(contains(app.mdl.PVListA, app.mdl.PVA))
                app.PVListA.Value = {};
            else
                app.PVListA.Value = app.mdl.PVA;
            end
            if isempty(app.mdl.PVB) || ~any(contains(app.mdl.PVListB, app.mdl.PVB))
                app.PVListB.Value = {};
            else
                app.PVListB.Value = app.mdl.PVB;
            end
            onBufferRatesChanged(app);
        end
        
        
        
        function onNumPointsChanged(app)
            % callback for num points listener
            app.NumberofPointsEditField.Value = app.mdl.numPoints_user;
        end
        
        function onBufferRatesChanged(app)
            % call back for buffer raates listener
            app.RateLabel.Text = app.mdl.bufferRatesText;
        end
        
        function onPVChanged(app)
            % callback for selected PV listener
            app.PlotVarYDropDown.Value = app.mdl.currentVar(1);
        end
        
        function onDataAcq(app)
            % callback for data acquired listener
            app.N_Actual.Text = num2str(app.mdl.numPoints_acq);
            app.AcquireNewDataButton.Text = 'Done';
            drawnow();
            pause(1);
            app.AcquireNewDataButton.Text = 'Get Data...';
        end
        
        function onAcqSCPChanged(app)
            app.AcquireSCP.Value = app.mdl.acqSCP;
        end
        
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function InitializeGUI(app)
            app.mdl = BSA_GUI_model(app); % instantiate the model
            
            % add listeners
            app.StatusListener = addlistener(app.mdl, 'StatusChanged', @(~,~)app.onStatusChanged);
            app.AcqStatusListener = addlistener(app.mdl, 'AcqStatusChanged', @(~,~)app.onAcqStatusChanged);
            app.eDefOptionsListener = addlistener(app.mdl, 'eDefOptionsChanged', @(~,~)app.oneDefOptionsChanged);
            app.PlotOptionsListener = addlistener(app.mdl, 'PlotOptionsChanged', @(~,~)app.onPlotOptionsChanged);
            app.PVListListener = addlistener(app.mdl, 'PVListChanged', @(~,~)app.onPVListChanged);
            app.NumPointsListener = addlistener(app.mdl, 'NumPointsChanged', @(~,~)app.onNumPointsChanged);
            app.BufferRatesListener = addlistener(app.mdl, 'BufferRatesChanged', @(~,~)app.onBufferRatesChanged);
            app.PVListener = addlistener(app.mdl, 'PVChanged', @(~,~)app.onPVChanged);
            app.DataAcqListener = addlistener(app.mdl, 'DataAcquired', @(~,~)app.onDataAcq);
            app.AcqSCPListener = addlistener(app.mdl, 'AcqSCPChanged', @(~,~)app.onAcqSCPChanged);
            app.InitListener = addlistener(app.mdl, 'Init', @(~,~)app.onInit);
            
            mdlInit(app.mdl); % populate model with initial conditions
            
            % Time activate function to handle edit field glitch
            t = timer('TimerFcn',@(~,~)activate(app),'StartDelay',0.02,'Name','activator');
            start(t)
        end

        % Button pushed function: AcquireNewDataButton
        function AcquireNewDataButtonPushed(app, event)
            if needseDef(app.mdl)
                warndlg('Please use eDef Setup before Aquire New Data for Private eDefs');
                return;
            end
            if app.mdl.dev
                try
                    BSD_window(app.mdl);
                catch ex
                    errorMessage(app, ex, 'Error loading BSD window.');
                end
            else
                app.AcquireNewDataButton.Text = 'Getting Data...';
                drawnow
                
                try
                    bsagui_getData(app.mdl);
                catch ex                        
                    errorMessage(app, ex, 'Error acquiring data.');
                    app.DataAqText.Text = 'Error acquiring data';
                end
                
                app.AcquireNewDataButton.Text = 'Get Data';
            end
        end

        % Button pushed function: AdvancedOptionsButton
        function AdvancedOptionsButtonPushed(app, event)
            try
                AdvancedOptions(app.mdl);
            catch ex
                errorMessage(app, ex, 'Error launching All Z Menu.');
            end
        end

        % Button pushed function: CreateNewVariableButton
        function CreateNewVariableButtonPushed(app, event)
            try
                createVar(app.mdl);
            catch ex
                errorMessage(app, ex, 'Error launching create variable window.');
            end
        end

        % Value changed function: eDefMenu
        function eDefMenuValueChanged(app, event)
            % Handle private eDef if one was previously set up
            if app.mdl.have_eDef
                cleaneDefs(app);
            end
            eDef = app.eDefMenu.Value;
            isPrivate = contains(eDef, 'Private');
            
            try
                eDefChanged(app.mdl, eDef, isPrivate);
            catch ex
                errorMessage(app, ex, 'Error changing eDef.');
                app.eDefMenu.Value = app.mdl.eDef;
                return
            end
            
            % toggle private eDef buttons
            if isPrivate
                app.eDefSetupButton.Visible='on';
                if app.mdl.lcls
                    app.WaitEnoloadCheckBox.Visible='on';
                end
                app.PVListA.Items = {'Setup private eDef'};
                app.PVListB.Items = {'Setup private eDef'};
            else
                app.eDefSetupButton.Visible='off';
                app.WaitEnoloadCheckBox.Visible='off';
                ResetAButtonPushed(app,event);
                ResetBButtonPushed(app,event);
            end
        end

        % Button pushed function: eDefSetupButton
        function eDefSetupButtonPushed(app, event)
            % function for setting up custom eDef

            % check for active rates
            if app.mdl.facet
                active = app.mdl.facetBR ~= 0;
            else
                if strcmp(app.LinacSwitch.Value, 'SC')
                    dests = getSCTimingActiveDestinations();
                    active = ~isempty(dests);
                else
                    rates = [app.mdl.HXRBR, app.mdl.SXRBR];
                    active = sum(rates ~= 0);
                end
            end
            if ~active
                answer = questdlg('No activae rates for current linac. Would you still like to configure an eDef?',...
                    'No Active Rates',...
                    'Yes', 'No', 'No');
                if strcmp(answer, 'No')
                    return;
                end
            end
            try
                eDefSetup(app.mdl);
            catch ex
                errorMessage(app, ex, 'Error setting up eDef.');
            end
        end

        % Callback function
        function ExportToWorkspaceButtonPushed(app, event)
            try
                exportToWorkspace(app.mdl);
            catch ex
                errorMessage(app, ex, 'Error exporting to workspace.');
            end
        end

        % Value changed function: LinacSwitch
        function LinacSwitchValueChanged(app, event)
            linac = app.LinacSwitch.Value;
            if event == 1
                % event was passed from the "Load" callback, proceed to
                % view changes
            else
                try
                    linacSwitched(app.mdl, linac);
                catch ex
                    errorMessage(app, ex, sprintf('Error switching to %s linac. %s', linac));
                    app.LinacSwitch.Value = app.LinacSwitch.Items(~strcmp(app.LinacSwitch.Items, linac));
                    return
                end
            end

            % change view for current linac
            switch linac
                case 'SC'
                    app.NumberofPointsEditField.Limits = [1,20000];
                    app.NumberofPointsEditField.Value = 20000;
                    app.PointRange.Text = '(1-20000)';
                    
                    if strcmp(app.mdl.eDef, 'Private')
                        app.PVListA.Items = {'Please setup an eDef or select a default'};
                        app.PVListB.Items = {'Please setup an eDef or select a default'};
                    end
                    
                    app.eDefSetupButton.Visible = 'on';
                    %app.PlotOrbitButton.Enable = 'off';
                    app.MIAButton.Enable = 'off';
                    app.WaitEnoloadCheckBox.Enable = 'off';
                    app.SCMPSViewerButton.Visible = 'on';

                case 'CU'
                    app.NumberofPointsEditField.Value = app.mdl.numPoints_user;
                    app.NumberofPointsEditField.Limits = [1,2800];
                    app.PointRange.Text = '(1-2800)';
                    app.PlotOrbitButton.Enable = 'on';
                    app.eDefSetupButton.Visible='off';
                    app.MIAButton.Enable = 'on';
                    app.SCMPSViewerButton.Visible = 'off';
                    app.WaitEnoloadCheckBox.Enable = 'on';
                    app.WaitEnoloadCheckBox.Visible='off';
                    if str2double(app.N_Actual.Text) > 2800
                        app.N_Actual.Text = '';
                    end
            end
            
            app.SearchPVA.Value = '';
            app.SearchPVB.Value = '';
            app.AcquireNewDataButton.Text = 'Acquire New Data';
            app.DataAqText.Text = '';
            app.PlotVarXDropDown.Value = 'Time';
        end

        % Button pushed function: LoadDataButton
        function LoadDataButtonPushed(app, event)
            disp('Loading Data...');
            app.LoadDataButton.Text='Loading Data...';
            pause(1);
            
            try
                [data, app.fileName, ~] = util_dataLoad('File to load', 0, 'BSA-data*.mat');
                
                if isempty(data)
                    app.LoadDataButton.Text='Load Data';
                    app.Status.Text = 'No data found';
                    return
                end
                
                % we need to see if there are any fields missing due to old BSA
                % files having a different format
                loaded = loadFields(app.mdl, data);
            catch ex
                errorMessage(app, ex, 'Error loading file.');
                app.fileName = app.mdl.fileName;
                app.LoadDataButton.Text='Load Data';
                return
            end
            
            if ~loaded, return; end
            
            % Clean up private eDef if one was previously set up
            if ~isempty(app.mdl.eDefNumber)
                cleaneDefs(app);
                app.eDefSetupButton.Visible='off';
                app.WaitEnoloadCheckBox.Visible='off';
            end
            
            ResetAButtonPushed(app);
            ResetBButtonPushed(app);
            
            % toggle appropriate linac
            if ~strcmp(app.mdl.linac, app.LinacSwitch.Value)
                app.LinacSwitch.Value = app.mdl.linac;
                LinacSwitchValueChanged(app, 1);
                onNumPointsChanged(app);
            end
            
            % MIA current only works for CU data
            %app.MIAButton.Enable = strcmp(app.mdl.linac, 'CU');

            app.DataAqText.Text = '';
            app.LoadDataButton.Text='...Done'; drawnow
            pause(1);
            app.LoadDataButton.Text='Load Data';
            
            fprintf('Data loaded from %s\n', app.fileName);
            
            app.eDefMenu.Value = 'BSA File Loaded';
        end

        % Button pushed function: MIAButton
        function MIAButtonPushed(app, event)
            try
                MIA_GUI(app.mdl);
            catch ex
                errorMessage(app, ex, 'Error launching MIA GUI.');
            end

        end

        % Value changed function: NumberofPointsEditField
        function NumberofPointsEditFieldValueChanged(app, event)
            try
                numPoints = app.NumberofPointsEditField.Value;
                numPointsUserChanged(app.mdl, numPoints);
            catch ex
                errorMessage(app, ex, 'Error changing num points.');
                app.NumferofPointsEditField.Value = app.mdl.numPoints_user;
            end
        end

        % Value changed function: OffsetEditField
        function OffsetEditFieldValueChanged(app, event)
            try
                offset = app.OffsetEditField.Value;
                offsetChanged(app.mdl, offset);
            catch ex
                errorMessage(app, ex, 'Error changing offset.');
                app.OffsetEditField.Value = app.mdl.offset;
            end
            
        end

        % Button pushed function: PlotOrbitButton
        function PlotOrbitButtonPushed(app, event)
            try
                BPM_Orbit(app.mdl);
            catch ex
                errorMessage(app, ex, 'Error launching BPM orbit GUI.');
            end
        end

        % Button pushed function: PlotButton
        function PlotButtonPushed(app, event)
            % Collect selected data to plot and direct to the correct
            % plotting function
            app.PlotButton.Text = '...plotting';
            drawnow();
            
            xvar = app.PlotVarXDropDown.Value;
            
            try
                if app.mdl.multiplot
                    yvarlist = app.PlotVarYDropDown.Items;
                    if app.mdl.multiplot_same
                        bsagui_plot(app.mdl, yvarlist, xvar);
                    else
                        for varidx = 1:length(yvarlist)
                            yvar = yvarlist{varidx};
                            bsagui_plot(app.mdl, yvar, xvar);
                        end
                    end
                else
                    yvar = {app.PlotVarYDropDown.Value};
                    bsagui_plot(app.mdl, yvar, xvar);
                end

            catch ex
                errorMessage(app, ex, sprintf('Error with %s plot. %s', xvar));
            end
            app.PlotButton.Text = 'Plot';
            drawnow();
        end

        % Value changed function: PlotVarXDropDown
        function PlotVarXDropDownValueChanged(app, event)
            opt = app.PlotVarXDropDown.Value;
            multiList = [{'Time', 'Index', 'PSD', 'Histogram'}, app.PlotVarYDropDown.Items];
            if any(contains(multiList, opt))
                app.MultiplotCheckBox.Visible = 'on';
            else
                app.MultiplotCheckBox.Visible = 'off';
            end
            
        end

        % Value changed function: PVListA
        function PVListAValueChanged(app, event)
            try
                PV = app.PVListA.Value;
                setPV(app.mdl, PV, "A");
            catch ex
                errorMessage(app, ex, 'Error changing PV A.');
            end
        end

        % Value changed function: PVListB
        function PVListBValueChanged(app, event)
            try
                PV = app.PVListB.Value;
                setPV(app.mdl, PV, "B");
            catch ex
                errorMessage(app, ex, 'Error changing PV B.');
            end
        end

        % Button pushed function: ResetA
        function ResetAButtonPushed(app, event)
            % reset PVA List, PVA, idxA, and plot options to default
            try
                if needseDef(app.mdl)
                    return
                end
                mdlReset(app.mdl, "A");
                app.SearchPVA.Value = '';
            catch ex
                errorMessage(app, ex, 'Error resetting PV A.');
            end
        end

        % Button pushed function: ResetB
        function ResetBButtonPushed(app, event)
            % reset PVA List, PVA, idxA, and plot options to default
            try
                if needseDef(app.mdl)
                    return
                end
                mdlReset(app.mdl, "B");
                app.SearchPVB.Value = '';
            catch ex
                errorMessage(app, ex, 'Error resetting PV B.');
            end
        end

        % Button pushed function: SaveDataButton
        function SaveDataButtonPushed(app, event)
            app.SaveDataButton.Text='Saving Data...';
            drawnow();
            try
                saveData(app.mdl, 0);
                app.SaveDataButton.Text='...Done';
            catch ex
                errorMessage(app, ex, 'Error saving data.');
            end
            drawnow();
            pause(1);
            app.SaveDataButton.Text='Save Data';
        end

        % Button pushed function: SaveDataAsButton
        function SaveDataAsButtonPushed(app, event)
            disp('Saving Data...');
            app.SaveDataAsButton.Text='Saving Data...';
            drawnow();
            try
                saveData(app.mdl, 1);
                app.SaveDataAsButton.Text='...Done';
            catch ex
                errorMessage(app, ex, 'Error saving data.');
            end
            drawnow();
            pause(1);
            app.SaveDataAsButton.Text='Save Data As...';
        end

        % Value changing function: SearchPVA
        function SearchPVAValueChanging(app, event)
            searchString = upper(event.Value);
            try
                searchPVSet(app.mdl, searchString, 'A');
            catch ex
                errorMessage(app, ex, 'Error with root name search.');
            end
        end

        % Value changing function: SearchPVB
        function SearchPVBValueChanging(app, event)
            searchString = upper(event.Value);
            try
                searchPVSet(app.mdl, searchString, 'B');
            catch ex
                errorMessage(app, ex, 'Error with root name search.');
            end
        end

        % Value changed function: PSDHigh
        function PSDHighValueChanged(app, event)
            try
                PSDRangeChanged(app.mdl, app.PSDHigh.Value, 'high');
            catch ex
                errorMessage(app, ex, 'Error setting PSD high.');
            end
        end

        % Value changed function: PSDLow
        function PSDLowValueChanged(app, event)
            try
                PSDRangeChanged(app.mdl, app.PSDLow.Value, 'low');
            catch ex
                errorMessage(app, ex, 'Error setting PSD low.');
            end
        end

        % Value changed function: WaitEnoloadCheckBox
        function WaitEnoloadCheckBoxValueChanged(app, event)
            waitenoload = app.WaitEnoloadCheckBox.Value;
            try
                enoload(app.mdl, waitenoload);
            catch ex
                errorMessage(app, ex, 'Error changing enoload option.');
                app.WaitEnoloadCheckBox.Value = ~waitenoload;
            end
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            try
                mdlClose(app.mdl);
                t = timerfind('Name','activator');
                if ~isempty(t)
                    delete(t);
                end
                util_mlappClose(app)
            catch ex
                answer = questdlg(sprintf('%s%c%cWould you like to force quit?', lprintf(app.STDERR, 'Error quitting app. %s',ex.message), newline, newline),...
                    'Delete App',...
                    'Yes', 'No', 'No');
                if strcmp(answer, 'Yes')
                    delete(app);
                end
            end
        end

        % Value changed function: MultiplotCheckBox
        function MultiplotCheckBoxValueChanged(app, event)
            
            try
                multiplotChanged(app.mdl, app.MultiplotCheckBox.Value);
            catch ex
                errorMessage(app, ex, 'Error changing multiplot setting.');
            end
        end

        % Button pushed function: SCMPSViewerButton
        function SCMPSViewerButtonPushed(app, event)
            try
                MPS_view();
            catch ex
                errorMessage(app, ex, 'Error launching SC MPS Viewer.');
            end
        end

        % Value changed function: AcquireSCPCheckBox
        function AcquireSCPCheckBoxValueChanged(app, event)
            acqSCP =  app.AcquireSCPCheckBox.Value;
            try
                acquireSCP(app.mdl, acqSCP);
            catch ex
                uiwait(errordlg(...
                    lprintf(app.STDERR, 'Error changing acquire SCP option. %s', ex.message)));
                app.AcquireSCPCheckBox.Value = ~acqSCP;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1244 789];
            app.UIFigure.Name = 'BSA_GUI';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            app.UIFigure.Scrollable = 'on';
            app.UIFigure.Tag = 'BSA_GUI';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'0.8x', '0.8x', '0.8x', '0.8x', '0x', '0.8x', '0.8x', '0.8x', '0.8x', '0.3x', '1x', '1x', '0.3x', '1x', '1x'};
            app.GridLayout.RowHeight = {'0.5x', '0.5x', '0.5x', '0.5x', '0.5x', '0.5x', '0.1x', '0.5x', '0.5x', '0.5x', '0.5x', '0.5x', '0.5x', '0.5x', '0.5x', '0.5x', '0.5x', '0.5x', '0.5x', '0.5x', '0.5x', '0.5x'};
            app.GridLayout.ColumnSpacing = 9.4;
            app.GridLayout.RowSpacing = 3.11111111111111;
            app.GridLayout.Padding = [9.4 3.11111111111111 9.4 3.11111111111111];

            % Create PVListA
            app.PVListA = uilistbox(app.GridLayout);
            app.PVListA.Items = {};
            app.PVListA.Multiselect = 'on';
            app.PVListA.ValueChangedFcn = createCallbackFcn(app, @PVListAValueChanged, true);
            app.PVListA.FontSize = 16;
            app.PVListA.Layout.Row = [5 22];
            app.PVListA.Layout.Column = [1 4];
            app.PVListA.Value = {};

            % Create PVListB
            app.PVListB = uilistbox(app.GridLayout);
            app.PVListB.Items = {};
            app.PVListB.Multiselect = 'on';
            app.PVListB.ValueChangedFcn = createCallbackFcn(app, @PVListBValueChanged, true);
            app.PVListB.FontSize = 16;
            app.PVListB.Layout.Row = [5 22];
            app.PVListB.Layout.Column = [6 9];
            app.PVListB.Value = {};

            % Create ResetB
            app.ResetB = uibutton(app.GridLayout, 'push');
            app.ResetB.ButtonPushedFcn = createCallbackFcn(app, @ResetBButtonPushed, true);
            app.ResetB.FontSize = 16;
            app.ResetB.Layout.Row = 3;
            app.ResetB.Layout.Column = 9;
            app.ResetB.Text = 'Reset';

            % Create ResetA
            app.ResetA = uibutton(app.GridLayout, 'push');
            app.ResetA.ButtonPushedFcn = createCallbackFcn(app, @ResetAButtonPushed, true);
            app.ResetA.FontSize = 16;
            app.ResetA.Layout.Row = 3;
            app.ResetA.Layout.Column = 4;
            app.ResetA.Text = 'Reset';

            % Create eDefMenu
            app.eDefMenu = uidropdown(app.GridLayout);
            app.eDefMenu.Items = {'Private', 'CUS1H', 'CUSTH', 'CUSBR', 'CUH1H', '1H', 'TH', 'BR', 'CUHTH', 'CUHBR'};
            app.eDefMenu.Editable = 'on';
            app.eDefMenu.ValueChangedFcn = createCallbackFcn(app, @eDefMenuValueChanged, true);
            app.eDefMenu.FontSize = 16;
            app.eDefMenu.BackgroundColor = [1 1 1];
            app.eDefMenu.Layout.Row = 6;
            app.eDefMenu.Layout.Column = [11 12];
            app.eDefMenu.Value = 'BR';

            % Create AcquireNewDataButton
            app.AcquireNewDataButton = uibutton(app.GridLayout, 'push');
            app.AcquireNewDataButton.ButtonPushedFcn = createCallbackFcn(app, @AcquireNewDataButtonPushed, true);
            app.AcquireNewDataButton.BackgroundColor = [1 1 0.0667];
            app.AcquireNewDataButton.FontSize = 16;
            app.AcquireNewDataButton.FontWeight = 'bold';
            app.AcquireNewDataButton.Layout.Row = [9 10];
            app.AcquireNewDataButton.Layout.Column = [11 12];
            app.AcquireNewDataButton.Text = {'Acquire New '; 'Data'};

            % Create SaveDataButton
            app.SaveDataButton = uibutton(app.GridLayout, 'push');
            app.SaveDataButton.ButtonPushedFcn = createCallbackFcn(app, @SaveDataButtonPushed, true);
            app.SaveDataButton.FontSize = 16;
            app.SaveDataButton.Layout.Row = 12;
            app.SaveDataButton.Layout.Column = [11 12];
            app.SaveDataButton.Text = 'Save Data';

            % Create SaveDataAsButton
            app.SaveDataAsButton = uibutton(app.GridLayout, 'push');
            app.SaveDataAsButton.ButtonPushedFcn = createCallbackFcn(app, @SaveDataAsButtonPushed, true);
            app.SaveDataAsButton.FontSize = 16;
            app.SaveDataAsButton.Layout.Row = 13;
            app.SaveDataAsButton.Layout.Column = [11 12];
            app.SaveDataAsButton.Text = 'Save Data As...';

            % Create LoadDataButton
            app.LoadDataButton = uibutton(app.GridLayout, 'push');
            app.LoadDataButton.ButtonPushedFcn = createCallbackFcn(app, @LoadDataButtonPushed, true);
            app.LoadDataButton.FontSize = 16;
            app.LoadDataButton.Layout.Row = 14;
            app.LoadDataButton.Layout.Column = [11 12];
            app.LoadDataButton.Text = 'Load Data';

            % Create PSDLow
            app.PSDLow = uieditfield(app.GridLayout, 'numeric');
            app.PSDLow.ValueChangedFcn = createCallbackFcn(app, @PSDLowValueChanged, true);
            app.PSDLow.HorizontalAlignment = 'center';
            app.PSDLow.FontSize = 16;
            app.PSDLow.Layout.Row = 20;
            app.PSDLow.Layout.Column = 14;
            app.PSDLow.Value = 58;

            % Create PSDHigh
            app.PSDHigh = uieditfield(app.GridLayout, 'numeric');
            app.PSDHigh.ValueChangedFcn = createCallbackFcn(app, @PSDHighValueChanged, true);
            app.PSDHigh.HorizontalAlignment = 'center';
            app.PSDHigh.FontSize = 16;
            app.PSDHigh.Layout.Row = 20;
            app.PSDHigh.Layout.Column = 15;
            app.PSDHigh.Value = 60;

            % Create PSDRangeLabel
            app.PSDRangeLabel = uilabel(app.GridLayout);
            app.PSDRangeLabel.HorizontalAlignment = 'center';
            app.PSDRangeLabel.FontSize = 16;
            app.PSDRangeLabel.Layout.Row = 19;
            app.PSDRangeLabel.Layout.Column = [14 15];
            app.PSDRangeLabel.Text = 'PSD Range (Hz)';

            % Create NumberActualLabel
            app.NumberActualLabel = uilabel(app.GridLayout);
            app.NumberActualLabel.HorizontalAlignment = 'center';
            app.NumberActualLabel.FontSize = 16;
            app.NumberActualLabel.Layout.Row = 3;
            app.NumberActualLabel.Layout.Column = [14 15];
            app.NumberActualLabel.Text = 'Number Actual';

            % Create N_Actual
            app.N_Actual = uilabel(app.GridLayout);
            app.N_Actual.HorizontalAlignment = 'center';
            app.N_Actual.FontSize = 16;
            app.N_Actual.Layout.Row = 4;
            app.N_Actual.Layout.Column = [14 15];
            app.N_Actual.Text = '0';

            % Create DataAqText
            app.DataAqText = uilabel(app.GridLayout);
            app.DataAqText.HorizontalAlignment = 'center';
            app.DataAqText.FontSize = 16;
            app.DataAqText.Layout.Row = 11;
            app.DataAqText.Layout.Column = [11 12];
            app.DataAqText.Text = '';

            % Create BSALabel
            app.BSALabel = uilabel(app.GridLayout);
            app.BSALabel.HorizontalAlignment = 'center';
            app.BSALabel.FontSize = 24;
            app.BSALabel.FontWeight = 'bold';
            app.BSALabel.Layout.Row = 1;
            app.BSALabel.Layout.Column = [5 6];
            app.BSALabel.Text = 'BSA';

            % Create PointRange
            app.PointRange = uilabel(app.GridLayout);
            app.PointRange.HorizontalAlignment = 'center';
            app.PointRange.VerticalAlignment = 'top';
            app.PointRange.FontSize = 16;
            app.PointRange.Layout.Row = 5;
            app.PointRange.Layout.Column = [11 12];
            app.PointRange.Text = '(1-2800)';

            % Create eDefSetupButton
            app.eDefSetupButton = uibutton(app.GridLayout, 'push');
            app.eDefSetupButton.ButtonPushedFcn = createCallbackFcn(app, @eDefSetupButtonPushed, true);
            app.eDefSetupButton.FontSize = 16;
            app.eDefSetupButton.Visible = 'off';
            app.eDefSetupButton.Layout.Row = 6;
            app.eDefSetupButton.Layout.Column = [14 15];
            app.eDefSetupButton.Text = 'eDef Setup';

            % Create Status
            app.Status = uilabel(app.GridLayout);
            app.Status.FontSize = 16;
            app.Status.Layout.Row = [21 22];
            app.Status.Layout.Column = [11 15];
            app.Status.Text = '';

            % Create SearchAEditFieldLabel
            app.SearchAEditFieldLabel = uilabel(app.GridLayout);
            app.SearchAEditFieldLabel.HorizontalAlignment = 'center';
            app.SearchAEditFieldLabel.FontSize = 16;
            app.SearchAEditFieldLabel.Layout.Row = 3;
            app.SearchAEditFieldLabel.Layout.Column = [2 3];
            app.SearchAEditFieldLabel.Text = 'Search A';

            % Create SearchPVA
            app.SearchPVA = uieditfield(app.GridLayout, 'text');
            app.SearchPVA.ValueChangingFcn = createCallbackFcn(app, @SearchPVAValueChanging, true);
            app.SearchPVA.FontSize = 16;
            app.SearchPVA.Layout.Row = 4;
            app.SearchPVA.Layout.Column = [1 4];
            app.SearchPVA.Value = 'Loading...';

            % Create SearchBEditFieldLabel
            app.SearchBEditFieldLabel = uilabel(app.GridLayout);
            app.SearchBEditFieldLabel.HorizontalAlignment = 'center';
            app.SearchBEditFieldLabel.FontSize = 16;
            app.SearchBEditFieldLabel.Layout.Row = 3;
            app.SearchBEditFieldLabel.Layout.Column = [7 8];
            app.SearchBEditFieldLabel.Text = 'Search B';

            % Create SearchPVB
            app.SearchPVB = uieditfield(app.GridLayout, 'text');
            app.SearchPVB.ValueChangingFcn = createCallbackFcn(app, @SearchPVBValueChanging, true);
            app.SearchPVB.FontSize = 16;
            app.SearchPVB.Layout.Row = 4;
            app.SearchPVB.Layout.Column = [6 9];

            % Create NumberofPointsEditFieldLabel
            app.NumberofPointsEditFieldLabel = uilabel(app.GridLayout);
            app.NumberofPointsEditFieldLabel.HorizontalAlignment = 'right';
            app.NumberofPointsEditFieldLabel.FontSize = 16;
            app.NumberofPointsEditFieldLabel.FontWeight = 'bold';
            app.NumberofPointsEditFieldLabel.Layout.Row = 3;
            app.NumberofPointsEditFieldLabel.Layout.Column = [11 12];
            app.NumberofPointsEditFieldLabel.Text = 'Number of Points';

            % Create NumberofPointsEditField
            app.NumberofPointsEditField = uieditfield(app.GridLayout, 'numeric');
            app.NumberofPointsEditField.Limits = [1 2800];
            app.NumberofPointsEditField.ValueDisplayFormat = '%d';
            app.NumberofPointsEditField.ValueChangedFcn = createCallbackFcn(app, @NumberofPointsEditFieldValueChanged, true);
            app.NumberofPointsEditField.FontSize = 16;
            app.NumberofPointsEditField.Layout.Row = 4;
            app.NumberofPointsEditField.Layout.Column = [11 12];
            app.NumberofPointsEditField.Value = 2800;

            % Create PlotVarYDropDownLabel
            app.PlotVarYDropDownLabel = uilabel(app.GridLayout);
            app.PlotVarYDropDownLabel.HorizontalAlignment = 'center';
            app.PlotVarYDropDownLabel.FontSize = 16;
            app.PlotVarYDropDownLabel.Layout.Row = 8;
            app.PlotVarYDropDownLabel.Layout.Column = [14 15];
            app.PlotVarYDropDownLabel.Text = 'Plot Var Y';

            % Create PlotVarYDropDown
            app.PlotVarYDropDown = uidropdown(app.GridLayout);
            app.PlotVarYDropDown.Items = {};
            app.PlotVarYDropDown.Layout.Row = 9;
            app.PlotVarYDropDown.Layout.Column = [14 15];
            app.PlotVarYDropDown.Value = {};

            % Create PlotVarXDropDownLabel
            app.PlotVarXDropDownLabel = uilabel(app.GridLayout);
            app.PlotVarXDropDownLabel.HorizontalAlignment = 'center';
            app.PlotVarXDropDownLabel.FontSize = 16;
            app.PlotVarXDropDownLabel.Layout.Row = 10;
            app.PlotVarXDropDownLabel.Layout.Column = [14 15];
            app.PlotVarXDropDownLabel.Text = 'Plot Var X';

            % Create PlotVarXDropDown
            app.PlotVarXDropDown = uidropdown(app.GridLayout);
            app.PlotVarXDropDown.Items = {'Time', 'Index', 'PSD', 'Histogram', 'All Z', 'Z PSD', 'Jitter Pie'};
            app.PlotVarXDropDown.ValueChangedFcn = createCallbackFcn(app, @PlotVarXDropDownValueChanged, true);
            app.PlotVarXDropDown.Layout.Row = 11;
            app.PlotVarXDropDown.Layout.Column = [14 15];
            app.PlotVarXDropDown.Value = 'Time';

            % Create CreateNewVariableButton
            app.CreateNewVariableButton = uibutton(app.GridLayout, 'push');
            app.CreateNewVariableButton.ButtonPushedFcn = createCallbackFcn(app, @CreateNewVariableButtonPushed, true);
            app.CreateNewVariableButton.FontSize = 16;
            app.CreateNewVariableButton.Tooltip = {'Calculate a new variable from excisting PVs'};
            app.CreateNewVariableButton.Layout.Row = 17;
            app.CreateNewVariableButton.Layout.Column = [11 12];
            app.CreateNewVariableButton.Text = 'Create New Variable';

            % Create PlotButton
            app.PlotButton = uibutton(app.GridLayout, 'push');
            app.PlotButton.ButtonPushedFcn = createCallbackFcn(app, @PlotButtonPushed, true);
            app.PlotButton.FontSize = 16;
            app.PlotButton.Layout.Row = [14 15];
            app.PlotButton.Layout.Column = [14 15];
            app.PlotButton.Text = 'Plot';

            % Create AdvancedOptionsButton
            app.AdvancedOptionsButton = uibutton(app.GridLayout, 'push');
            app.AdvancedOptionsButton.ButtonPushedFcn = createCallbackFcn(app, @AdvancedOptionsButtonPushed, true);
            app.AdvancedOptionsButton.FontSize = 16;
            app.AdvancedOptionsButton.Layout.Row = 15;
            app.AdvancedOptionsButton.Layout.Column = [11 12];
            app.AdvancedOptionsButton.Text = 'Advanced Options';

            % Create PlotOrbitButton
            app.PlotOrbitButton = uibutton(app.GridLayout, 'push');
            app.PlotOrbitButton.ButtonPushedFcn = createCallbackFcn(app, @PlotOrbitButtonPushed, true);
            app.PlotOrbitButton.FontSize = 16;
            app.PlotOrbitButton.Layout.Row = 18;
            app.PlotOrbitButton.Layout.Column = [11 12];
            app.PlotOrbitButton.Text = 'Plot Orbit';

            % Create MIAButton
            app.MIAButton = uibutton(app.GridLayout, 'push');
            app.MIAButton.ButtonPushedFcn = createCallbackFcn(app, @MIAButtonPushed, true);
            app.MIAButton.FontSize = 16;
            app.MIAButton.Tooltip = {'Model independent analysis, i.e. SVD tools'};
            app.MIAButton.Layout.Row = 16;
            app.MIAButton.Layout.Column = [11 12];
            app.MIAButton.Text = 'MIA';

            % Create WaitEnoloadCheckBox
            app.WaitEnoloadCheckBox = uicheckbox(app.GridLayout);
            app.WaitEnoloadCheckBox.ValueChangedFcn = createCallbackFcn(app, @WaitEnoloadCheckBoxValueChanged, true);
            app.WaitEnoloadCheckBox.Visible = 'off';
            app.WaitEnoloadCheckBox.Text = 'Wait for enoload';
            app.WaitEnoloadCheckBox.FontSize = 16;
            app.WaitEnoloadCheckBox.Layout.Row = 5;
            app.WaitEnoloadCheckBox.Layout.Column = [14 15];

            % Create RateLabel
            app.RateLabel = uilabel(app.GridLayout);
            app.RateLabel.HorizontalAlignment = 'right';
            app.RateLabel.FontSize = 14;
            app.RateLabel.Layout.Row = [1 2];
            app.RateLabel.Layout.Column = [10 15];
            app.RateLabel.Text = '';

            % Create LinacSwitch
            app.LinacSwitch = uiswitch(app.GridLayout, 'slider');
            app.LinacSwitch.Items = {'CU', 'SC'};
            app.LinacSwitch.ValueChangedFcn = createCallbackFcn(app, @LinacSwitchValueChanged, true);
            app.LinacSwitch.FontSize = 20;
            app.LinacSwitch.Layout.Row = 1;
            app.LinacSwitch.Layout.Column = [1 2];
            app.LinacSwitch.Value = 'CU';

            % Create MultiplotCheckBox
            app.MultiplotCheckBox = uicheckbox(app.GridLayout);
            app.MultiplotCheckBox.ValueChangedFcn = createCallbackFcn(app, @MultiplotCheckBoxValueChanged, true);
            app.MultiplotCheckBox.Tooltip = {'Look at "Advanced Options" for multitracing'};
            app.MultiplotCheckBox.Text = 'Multiplot';
            app.MultiplotCheckBox.FontSize = 16;
            app.MultiplotCheckBox.Layout.Row = 12;
            app.MultiplotCheckBox.Layout.Column = 14;

            % Create PulseOffsetEditFieldLabel
            app.PulseOffsetEditFieldLabel = uilabel(app.GridLayout);
            app.PulseOffsetEditFieldLabel.FontSize = 16;
            app.PulseOffsetEditFieldLabel.Layout.Row = 16;
            app.PulseOffsetEditFieldLabel.Layout.Column = 14;
            app.PulseOffsetEditFieldLabel.Text = 'Pulse Offset:';

            % Create OffsetEditField
            app.OffsetEditField = uieditfield(app.GridLayout, 'numeric');
            app.OffsetEditField.ValueChangedFcn = createCallbackFcn(app, @OffsetEditFieldValueChanged, true);
            app.OffsetEditField.HorizontalAlignment = 'center';
            app.OffsetEditField.Layout.Row = 16;
            app.OffsetEditField.Layout.Column = 15;

            % Create SCMPSViewerButton
            app.SCMPSViewerButton = uibutton(app.GridLayout, 'push');
            app.SCMPSViewerButton.ButtonPushedFcn = createCallbackFcn(app, @SCMPSViewerButtonPushed, true);
            app.SCMPSViewerButton.FontSize = 16;
            app.SCMPSViewerButton.Visible = 'off';
            app.SCMPSViewerButton.Layout.Row = 19;
            app.SCMPSViewerButton.Layout.Column = [11 12];
            app.SCMPSViewerButton.Text = 'SC MPS Viewer';

            % Create AcquireSCPCheckBox
            app.AcquireSCPCheckBox = uicheckbox(app.GridLayout);
            app.AcquireSCPCheckBox.ValueChangedFcn = createCallbackFcn(app, @AcquireSCPCheckBoxValueChanged, true);
            app.AcquireSCPCheckBox.Text = 'Acquire SCP';
            app.AcquireSCPCheckBox.FontSize = 16;
            app.AcquireSCPCheckBox.Layout.Row = 8;
            app.AcquireSCPCheckBox.Layout.Column = [11 12];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_BSAGUI_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @InitializeGUI)

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