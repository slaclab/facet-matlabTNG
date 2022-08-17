classdef eDefSetup_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        GridLayout                   matlab.ui.container.GridLayout
        DestinationDropDownLabel     matlab.ui.control.Label
        DestinationDropDown          matlab.ui.control.DropDown
        NumtoAvgEditFieldLabel       matlab.ui.control.Label
        NumtoAvgEditField            matlab.ui.control.NumericEditField
        ReserveeDefButton            matlab.ui.control.Button
        NumPointsLabel               matlab.ui.control.Label
        NumPointsEditField           matlab.ui.control.NumericEditField
        RateLabel                    matlab.ui.control.Label
        Rate                         matlab.ui.control.Label
        TimeoutEditFieldLabel        matlab.ui.control.Label
        TimeoutEditField             matlab.ui.control.NumericEditField
        ConnecttoExistingeDefButton  matlab.ui.control.Button
    end

    
    properties (Access = private)
        BG_mdl % BSA GUI model object holding data and state of app
        destination % user selected beam destination
        STDERR = 2
    end
    
    methods (Access = private)
        
        function activate(app)
            %Correct bug with edit fields on window open
            app.UIFigure.WindowState='minimized';
            drawnow();
            app.UIFigure.WindowState='normal';
            drawnow();
        end
        
        function errorMessage(app, ex, callbackMessage)
            err = ex.stack(1);
            file = err.file; funcname = err.name; linenum = num2str(err.line);
            file = strsplit(file, '/'); file = file{end};
            loc = sprintf('File: %s   Function: %s   Line: %s', file, funcname, linenum);
            uiwait(errordlg(...
                    lprintf(app.STDERR, '%s%c%s%c%s', callbackMessage, newline, ex.message, newline, loc)));
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mdl)
            app.BG_mdl = mdl;
            switch app.BG_mdl.sys
                case 'SYS0'
                    switch app.BG_mdl.linac
                        case 'CU'
                            app.NumPointsEditField.Limits = [0,2800];
                            if app.BG_mdl.HXRBR == 0
                                app.DestinationDropDown.Items = {'SXR'};
                                app.destination = app.DestinationDropDown.Value;
                                rate = lcaGetSmart('PATT:SYS0:12:CUSXR:ACTRATE',1);
                                app.Rate.Text = sprintf('%d Hz', rate);
                            elseif app.BG_mdl.SXRBR == 0
                                app.DestinationDropDown.Items = {'HXR'};
                                app.destination = app.DestinationDropDown.Value;
                                rate = lcaGetSmart('PATT:SYS0:11:CUHXR:ACTRATE',1);
                                app.Rate.Text = sprintf('%d Hz', rate);
                            else
                                app.destination = 'HXR';
                                app.DestinationDropDown.Items = {'HXR', 'SXR', 'Dual'};
                                rate = lcaGetSmart('PATT:SYS0:11:CUHXR:ACTRATE',1);
                                app.Rate.Text = sprintf('%d Hz', rate);
                            end
                        case 'SC'
                            app.NumPointsEditField.Limits = [0,20000];
                            app.DestinationDropDown.Items = getSCTimingActiveDestinations();
                            if isempty(app.DestinationDropDown.Items)
                                app.destination = 'None';
                                app.Rate.Text = 'None';
                            else
                                app.destination = app.DestinationDropDown.Value;
                                rate = getSCTimingActualRate(app.DestinationDropDown.Value);
                                app.Rate.Text = sprintf('%d Hz', rate);
                            end
                    end
                case 'SYS1'
                    app.DestinationDropDown.Items = {'FACET'};
                    app.destination = app.DestinationDropDown.Value;
                    rate = lcaGetSmart('EVNT:SYS1:1:BEAMRATE', 1);
                    app.Rate.Text = sprintf('%d Hz', rate);
                    app.NumPointsEditField.Limits = [0,2800];
            end
            app.NumPointsEditField.Value = app.BG_mdl.numPoints_user;
            % Time activate function to handle edit field glitch
            t = timer('TimerFcn',@(~,~)activate(app),'StartDelay',0.02,'Name','activator');
            start(t)
        end

        % Button pushed function: ReserveeDefButton
        function ReserveeDefButtonPushed(app, event)
            try
                dest = app.DestinationDropDown.Value;
                numPoints = app.NumPointsEditField.Value;
                num2avg = app.NumtoAvgEditField.Value;
                timeout = app.TimeoutEditField.Value;
                
                % Call function in BSA_GUI_model
                reserveeDef(app.BG_mdl, dest, numPoints, num2avg, timeout);
                
                delete(app);
            catch ex
                errorMessage(app, ex, 'Error reserving eDef.');
            end
        end

        % Value changed function: DestinationDropDown
        function DestinationDropDownValueChanged(app, event)
            try
                dest = app.DestinationDropDown.Value;
                switch app.BG_mdl.linac
                    case 'CU'
                        switch dest
                            case 'HXR'
                                rate = lcaGetSmart('PATT:SYS0:11:CUHXR:ACTRATE',1);
                                app.Rate.Text = sprintf('%d Hz', rate);
                            case 'SXR'
                                rate = lcaGetSmart('PATT:SYS0:12:CUSXR:ACTRATE',1);
                                app.Rate.Text = sprintf('%d Hz', rate);
                            case 'Dual'
                                rateHXR = lcaGetSmart('PATT:SYS0:11:CUHXR:ACTRATE',1);
                                rateSXR = lcaGetSmart('PATT:SYS0:12:CUSXR:ACTRATE',1);
                                app.Rate.Text = sprintf('HXR: %d Hz / SXR: %d Hz', rateHXR, rateSXR);
                        end
                    case 'SC'
                        rate = getSCTimingActualRate(dest);
                        app.Rate.Text = sprintf('%d Hz', rate);
                end
                app.destination = dest;
            catch ex
                errorMessage(app, ex, 'Error changing destination.'); 
                app.DestinationDropDown.Value = app.destination;
            end
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            t = timerfind('Name','activator');
            if ~isempty(t)
                delete(t);
            end
            delete(app)
        end

        % Button pushed function: ConnecttoExistingeDefButton
        function ConnecttoExistingeDefButtonPushed(app, event)
            try
                % Call function in BSA_GUI_model
                eDefNumber = inputdlg("EDEF Number", "Connect to eDef");
                eDefNumber = str2double(eDefNumber{1});
                if ~isempty(eDefNumber)
                    connecteDef(app.BG_mdl, eDefNumber);
                    delete(app);
                end
            catch ex
                errorMessage(app, ex, 'Error connecting to eDef.');
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 430 578];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'0.75x', '1x'};
            app.GridLayout.RowHeight = {'1x', '1x', '1x', '1x', '1x', '0.5x', '0.5x'};

            % Create DestinationDropDownLabel
            app.DestinationDropDownLabel = uilabel(app.GridLayout);
            app.DestinationDropDownLabel.HorizontalAlignment = 'center';
            app.DestinationDropDownLabel.FontSize = 20;
            app.DestinationDropDownLabel.Layout.Row = 1;
            app.DestinationDropDownLabel.Layout.Column = 1;
            app.DestinationDropDownLabel.Text = 'Destination';

            % Create DestinationDropDown
            app.DestinationDropDown = uidropdown(app.GridLayout);
            app.DestinationDropDown.Items = {'HXR', 'SXR', 'DUAL'};
            app.DestinationDropDown.ValueChangedFcn = createCallbackFcn(app, @DestinationDropDownValueChanged, true);
            app.DestinationDropDown.FontSize = 20;
            app.DestinationDropDown.Layout.Row = 1;
            app.DestinationDropDown.Layout.Column = 2;
            app.DestinationDropDown.Value = 'HXR';

            % Create NumtoAvgEditFieldLabel
            app.NumtoAvgEditFieldLabel = uilabel(app.GridLayout);
            app.NumtoAvgEditFieldLabel.HorizontalAlignment = 'center';
            app.NumtoAvgEditFieldLabel.FontSize = 20;
            app.NumtoAvgEditFieldLabel.Layout.Row = 3;
            app.NumtoAvgEditFieldLabel.Layout.Column = 1;
            app.NumtoAvgEditFieldLabel.Text = 'Num to Avg';

            % Create NumtoAvgEditField
            app.NumtoAvgEditField = uieditfield(app.GridLayout, 'numeric');
            app.NumtoAvgEditField.FontSize = 20;
            app.NumtoAvgEditField.Layout.Row = 3;
            app.NumtoAvgEditField.Layout.Column = 2;
            app.NumtoAvgEditField.Value = 1;

            % Create ReserveeDefButton
            app.ReserveeDefButton = uibutton(app.GridLayout, 'push');
            app.ReserveeDefButton.ButtonPushedFcn = createCallbackFcn(app, @ReserveeDefButtonPushed, true);
            app.ReserveeDefButton.FontSize = 20;
            app.ReserveeDefButton.Layout.Row = 6;
            app.ReserveeDefButton.Layout.Column = [1 2];
            app.ReserveeDefButton.Text = 'Reserve eDef';

            % Create NumPointsLabel
            app.NumPointsLabel = uilabel(app.GridLayout);
            app.NumPointsLabel.HorizontalAlignment = 'center';
            app.NumPointsLabel.FontSize = 20;
            app.NumPointsLabel.Layout.Row = 2;
            app.NumPointsLabel.Layout.Column = 1;
            app.NumPointsLabel.Text = 'Num Points';

            % Create NumPointsEditField
            app.NumPointsEditField = uieditfield(app.GridLayout, 'numeric');
            app.NumPointsEditField.FontSize = 20;
            app.NumPointsEditField.Layout.Row = 2;
            app.NumPointsEditField.Layout.Column = 2;

            % Create RateLabel
            app.RateLabel = uilabel(app.GridLayout);
            app.RateLabel.HorizontalAlignment = 'center';
            app.RateLabel.FontSize = 20;
            app.RateLabel.Layout.Row = 5;
            app.RateLabel.Layout.Column = 1;
            app.RateLabel.Text = 'Rate';

            % Create Rate
            app.Rate = uilabel(app.GridLayout);
            app.Rate.FontSize = 20;
            app.Rate.Layout.Row = 5;
            app.Rate.Layout.Column = 2;
            app.Rate.Text = '';

            % Create TimeoutEditFieldLabel
            app.TimeoutEditFieldLabel = uilabel(app.GridLayout);
            app.TimeoutEditFieldLabel.HorizontalAlignment = 'center';
            app.TimeoutEditFieldLabel.FontSize = 20;
            app.TimeoutEditFieldLabel.Layout.Row = 4;
            app.TimeoutEditFieldLabel.Layout.Column = 1;
            app.TimeoutEditFieldLabel.Text = 'Timeout';

            % Create TimeoutEditField
            app.TimeoutEditField = uieditfield(app.GridLayout, 'numeric');
            app.TimeoutEditField.Limits = [0 Inf];
            app.TimeoutEditField.FontSize = 20;
            app.TimeoutEditField.Layout.Row = 4;
            app.TimeoutEditField.Layout.Column = 2;
            app.TimeoutEditField.Value = 120;

            % Create ConnecttoExistingeDefButton
            app.ConnecttoExistingeDefButton = uibutton(app.GridLayout, 'push');
            app.ConnecttoExistingeDefButton.ButtonPushedFcn = createCallbackFcn(app, @ConnecttoExistingeDefButtonPushed, true);
            app.ConnecttoExistingeDefButton.FontSize = 20;
            app.ConnecttoExistingeDefButton.Layout.Row = 7;
            app.ConnecttoExistingeDefButton.Layout.Column = [1 2];
            app.ConnecttoExistingeDefButton.Text = 'Connect to Existing eDef';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = eDefSetup_exported(varargin)

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