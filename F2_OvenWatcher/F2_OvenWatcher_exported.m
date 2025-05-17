classdef F2_OvenWatcher_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        OvenWatcher                   matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        StatusButton                  matlab.ui.control.Button
        GridLayout2                   matlab.ui.container.GridLayout
        PressureStatusesLabel         matlab.ui.control.Label
        IPPressureEditFieldLabel      matlab.ui.control.Label
        IPPressure                    matlab.ui.control.NumericEditField
        LowerThresholdEditFieldLabel  matlab.ui.control.Label
        LowerThreshold                matlab.ui.control.NumericEditField
        UpperThresholdEditFieldLabel  matlab.ui.control.Label
        UpperThreshold                matlab.ui.control.NumericEditField
        ThermocoupleStatusesLabel     matlab.ui.control.Label
        TC4                           matlab.ui.control.NumericEditField
        TC4EditFieldLabel             matlab.ui.control.Label
        TC3                           matlab.ui.control.NumericEditField
        TC3EditFieldLabel             matlab.ui.control.Label
        TC2                           matlab.ui.control.NumericEditField
        TC2EditFieldLabel             matlab.ui.control.Label
        TC1                           matlab.ui.control.NumericEditField
        TC1EditFieldLabel             matlab.ui.control.Label
        TC5                           matlab.ui.control.NumericEditField
        TC5EditFieldLabel             matlab.ui.control.Label
        TC6                           matlab.ui.control.NumericEditField
        TC6EditFieldLabel             matlab.ui.control.Label
        TC7                           matlab.ui.control.NumericEditField
        TC7EditFieldLabel             matlab.ui.control.Label
        TC8                           matlab.ui.control.NumericEditField
        TC8EditField_2Label           matlab.ui.control.Label
        NumberofovenmovesLabel        matlab.ui.control.Label
        NumberEditFieldLabel          matlab.ui.control.Label
        NumberMoves                   matlab.ui.control.NumericEditField
        LastupdateLabel               matlab.ui.control.Label
        LastUpdate                    matlab.ui.control.Label
        RecountButton                 matlab.ui.control.Button
        GridLayout3                   matlab.ui.container.GridLayout
        UIAxes                        matlab.ui.control.UIAxes
        UIAxes2                       matlab.ui.control.UIAxes
        TimeEditFieldLabel            matlab.ui.control.Label
        Time                          matlab.ui.control.EditField
    end

    
    properties (Access = private)
        aobj % Descriptionapp.flow_rateSP_history
        LoopFlag logical = false % Flag indicating the PID loop is running 
        pressure_history = nan(1,3600);
        time = nan(1,3600);
        %uibTimer = timer('Period',.2, 'ExecutionMode','fixedDelay',...
        %               'TimerFcn',@(~,~)set(app.StatusButton, 'BackgroundColor', rand(1,3)));
        col = 1; % Description
    end
    
    methods (Access = private)
        
        function StartLoop(app)
            
            app.LoopFlag = true;
            while app.LoopFlag
                n = n+1;
                
                %% Add the PID loop here
                disp(datestr(now))
                pause(1)
                
                if app.IPPressure.Value < app.LowerThreshold.Value
                    app.StatusButton.BackgroundColor = [1 0 0]
        %            start(app.uibTimer);
                end
                if app.IPPressure.Value > app.UpperThreshold.Value
                    app.StatusButton.BackgroundColor = [1 0 0];
                end

                if app.IPPressure.Value > app.LowerThreshold.Value
                   if app.IPPressure.Value < app.UpperThreshold.Value
                       stop(app.uibTimer); 
                       app.StatusButton.BackgroundColor = [0 1 0];
                   end
                end
                
                
                if ~app.LoopFlag
                    break;
                end
            end    
        end
        
        
        
        function StopLoop(app)
            app.LoopFlag = false;
            
        end
        
        function doPlots(app)
            
            app.time = [now, app.time(1:end-1)];
            app.pressure_history = [app.IPPressure.Value, app.pressure_history(1:end-1)];
            plot(app.UIAxes2, (app.time - app.time(1))*24*60, app.pressure_history, 'b')
            hold(app.UIAxes2, 'on')
            xl = xlim(app.UIAxes2);
            plot(app.UIAxes2, xl, app.LowerThreshold.Value*[1 1], 'r--', ...
                              xl, app.UpperThreshold.Value*[1 1], 'r--');
            hold(app.UIAxes2, 'off')
            
            
            TCpos = [1 2 3 4 4.5 5.5 6.5 7.5];
            TC = [4 3 2 1 5 6 7 8];
            Tref_4_1 = [443.7 770.1 838.1 842.8 842 839.4 761 426.7];
            Tref_4_2 = [481 808 841 845 844 843 799 461];
            
            Tref_6_1 = [451 778 862 869 868 863 768 436];
            Tref_6_3 = [495 822 864 871 870 868 825 482];
            
            plot(app.UIAxes, TCpos, [app.TC4.Value, app.TC3.Value, app.TC2.Value, app.TC1.Value, app.TC5.Value, app.TC6.Value, app.TC7.Value, app.TC8.Value], 'bo-','MarkerFaceColor','b');
            %plot(app.UIAxes, TCpos, Tref_4_1, 'r.-');
            hold(app.UIAxes, 'on')
            plot(app.UIAxes, TCpos, Tref_4_1, 'r.-');
            %plot(TCpos, Tref_4_2, 'g.-');
            
            plot(app.UIAxes, TCpos, Tref_6_1, 'g.-');
            xlim(app.UIAxes, [1 7.5])
            hold(app.UIAxes, 'off')
            
            xticks(app.UIAxes, TCpos)
            xticklabels(app.UIAxes, TC)

            
%                 if app.LoopFlag
%                     % Add new target pressure value at the beginning and remove the last element
%                     app.target_pressure_history = [app.TargetpressureEditField.Value, app.target_pressure_history(1:end-1)];
%                 else
%                     % Add NaN at the beginning and remove the last element
%                     app.target_pressure_history = [nan, app.target_pressure_history(1:end-1)];
%                 end
%                 app.pressure_history = [app.IPpressureRBVEditField.Value, app.pressure_history(1:end-1)];
%                 app.flow_rate_history = [app.FlowRateRBVEditField.Value, app.flow_rate_history(1:end-1)];
%                 app.flow_rateSP_history = [app.MFCSetPointEditField.Value, app.flow_rateSP_history(1:end-1)];
%                 %app.flow_rateSP_history = [app.SP_fakeEditField.Value, app.flow_rateSP_history(1:end-1)];
%             
%             
%                 
% 
%                 plot(app.UIAxes, (app.time - app.time(1))*24*60, app.pressure_history, ...
%                                  (app.time - app.time(1))*24*60, app.target_pressure_history, 'r--');
%                 xlim(app.UIAxes, app.Xlimits(app.Nxlim,:));
%                                 
%                 plot(app.UIAxes_2, (app.time - app.time(1))*24*60, app.flow_rate_history, ...
%                                     (app.time - app.time(1))*24*60, app.flow_rateSP_history, 'r--');
%                 xlim(app.UIAxes_2, app.Xlimits(app.Nxlim,:));
%             
%              %   app.UIAxes.YAxis.TickLabelFormat = '%15g'
%              %   app.UIAxes_2.YAxis.TickLabelFormat = '%15g'
        end
        
        function UpdatePlots(app)
            pause(5)
            while true
                app.doPlots();
                pause(1)
                
                if app.IPPressure.Value < app.LowerThreshold.Value
                    app.StatusButton.BackgroundColor = colorFlash(app);%[1 0 0];
                    app.StatusButton.Text = 'Low Pressure!';
                end
                if app.IPPressure.Value > app.UpperThreshold.Value
                    app.StatusButton.BackgroundColor = colorFlash(app);%[1 0 0];
                    app.StatusButton.Text = 'High Pressure!';
                end
                
                if app.IPPressure.Value > app.LowerThreshold.Value
                    if app.IPPressure.Value < app.UpperThreshold.Value
                        app.StatusButton.BackgroundColor = [0 1 0]
                        app.StatusButton.Text = '';
                    end
                end
                
                app.Time.Value = datestr(now);
            end
        end
        
        
        function col = colorFlash(app)
            if app.col == 0;
                col = [1 1 0];
                app.col = 1;
            else
                col = [1 0 0];
                app.col = 0;
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.aobj=F2_OvenWatcherApp(app);
            
            app.LowerThreshold.Value = lcaGet(char(app.aobj.pvlist(1).pvname))*0.95;
            app.UpperThreshold.Value = lcaGet(char(app.aobj.pvlist(1).pvname))*1.05;
            
            app.RecountButtonPushed();
             
            app.UpdatePlots();
                        
        end

        % Button pushed function: RecountButton
        function RecountButtonPushed(app, event)
            dateEnd = now;
            dateStart  = datenum([2018, 01, 01,   12, 16, 52]);
            
            
            PVs = {'OVEN:LI20:3185:MOTR.RBV',...
                'OVEN:LI20:3185:POSITIONSUM'};
            
            
            
            [time, p1, union_times, union_values] = history(PVs, [dateStart dateEnd]);
            
            ind = ~sum(isnan(union_values),2);
            
            t = union_times(ind);
            motor = union_values(ind,1);
            pos_sum = union_values(ind,2);
                        
            t = (t-t(1))*60*24;
            
            [pks_pos_sum,locs_pos_sum] = findpeaks(pos_sum,t);
            
            app.NumberMoves.Value = sum(pks_pos_sum==2);
            app.LastUpdate.Text = datestr(dateEnd, 'mmm-dd HH:MM');

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create OvenWatcher and hide until all components are created
            app.OvenWatcher = uifigure('Visible', 'off');
            app.OvenWatcher.Position = [100 100 677 698];
            app.OvenWatcher.Name = 'Oven Watcher';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.OvenWatcher);
            app.GridLayout.ColumnWidth = {250, '100x'};
            app.GridLayout.RowHeight = {'5x', '25x', '1x'};

            % Create StatusButton
            app.StatusButton = uibutton(app.GridLayout, 'push');
            app.StatusButton.FontSize = 32;
            app.StatusButton.Layout.Row = 1;
            app.StatusButton.Layout.Column = [1 2];
            app.StatusButton.Text = 'Status';

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'2x', '1x'};
            app.GridLayout2.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout2.Layout.Row = 2;
            app.GridLayout2.Layout.Column = 1;

            % Create PressureStatusesLabel
            app.PressureStatusesLabel = uilabel(app.GridLayout2);
            app.PressureStatusesLabel.FontWeight = 'bold';
            app.PressureStatusesLabel.Layout.Row = 1;
            app.PressureStatusesLabel.Layout.Column = 1;
            app.PressureStatusesLabel.Text = 'Pressure Statuses:';

            % Create IPPressureEditFieldLabel
            app.IPPressureEditFieldLabel = uilabel(app.GridLayout2);
            app.IPPressureEditFieldLabel.Layout.Row = 2;
            app.IPPressureEditFieldLabel.Layout.Column = 1;
            app.IPPressureEditFieldLabel.Text = 'IP Pressure';

            % Create IPPressure
            app.IPPressure = uieditfield(app.GridLayout2, 'numeric');
            app.IPPressure.Layout.Row = 2;
            app.IPPressure.Layout.Column = 2;

            % Create LowerThresholdEditFieldLabel
            app.LowerThresholdEditFieldLabel = uilabel(app.GridLayout2);
            app.LowerThresholdEditFieldLabel.Layout.Row = 3;
            app.LowerThresholdEditFieldLabel.Layout.Column = 1;
            app.LowerThresholdEditFieldLabel.Text = 'Lower Threshold';

            % Create LowerThreshold
            app.LowerThreshold = uieditfield(app.GridLayout2, 'numeric');
            app.LowerThreshold.Layout.Row = 3;
            app.LowerThreshold.Layout.Column = 2;

            % Create UpperThresholdEditFieldLabel
            app.UpperThresholdEditFieldLabel = uilabel(app.GridLayout2);
            app.UpperThresholdEditFieldLabel.Layout.Row = 4;
            app.UpperThresholdEditFieldLabel.Layout.Column = 1;
            app.UpperThresholdEditFieldLabel.Text = 'Upper Threshold';

            % Create UpperThreshold
            app.UpperThreshold = uieditfield(app.GridLayout2, 'numeric');
            app.UpperThreshold.Layout.Row = 4;
            app.UpperThreshold.Layout.Column = 2;

            % Create ThermocoupleStatusesLabel
            app.ThermocoupleStatusesLabel = uilabel(app.GridLayout2);
            app.ThermocoupleStatusesLabel.FontWeight = 'bold';
            app.ThermocoupleStatusesLabel.Layout.Row = 5;
            app.ThermocoupleStatusesLabel.Layout.Column = 1;
            app.ThermocoupleStatusesLabel.Text = 'Thermocouple Statuses:';

            % Create TC4
            app.TC4 = uieditfield(app.GridLayout2, 'numeric');
            app.TC4.Layout.Row = 6;
            app.TC4.Layout.Column = 2;

            % Create TC4EditFieldLabel
            app.TC4EditFieldLabel = uilabel(app.GridLayout2);
            app.TC4EditFieldLabel.Layout.Row = 6;
            app.TC4EditFieldLabel.Layout.Column = 1;
            app.TC4EditFieldLabel.Text = 'TC 4';

            % Create TC3
            app.TC3 = uieditfield(app.GridLayout2, 'numeric');
            app.TC3.Layout.Row = 7;
            app.TC3.Layout.Column = 2;

            % Create TC3EditFieldLabel
            app.TC3EditFieldLabel = uilabel(app.GridLayout2);
            app.TC3EditFieldLabel.Layout.Row = 7;
            app.TC3EditFieldLabel.Layout.Column = 1;
            app.TC3EditFieldLabel.Text = 'TC 3';

            % Create TC2
            app.TC2 = uieditfield(app.GridLayout2, 'numeric');
            app.TC2.Layout.Row = 8;
            app.TC2.Layout.Column = 2;

            % Create TC2EditFieldLabel
            app.TC2EditFieldLabel = uilabel(app.GridLayout2);
            app.TC2EditFieldLabel.Layout.Row = 8;
            app.TC2EditFieldLabel.Layout.Column = 1;
            app.TC2EditFieldLabel.Text = 'TC 2';

            % Create TC1
            app.TC1 = uieditfield(app.GridLayout2, 'numeric');
            app.TC1.Layout.Row = 9;
            app.TC1.Layout.Column = 2;

            % Create TC1EditFieldLabel
            app.TC1EditFieldLabel = uilabel(app.GridLayout2);
            app.TC1EditFieldLabel.Layout.Row = 9;
            app.TC1EditFieldLabel.Layout.Column = 1;
            app.TC1EditFieldLabel.Text = 'TC 1';

            % Create TC5
            app.TC5 = uieditfield(app.GridLayout2, 'numeric');
            app.TC5.Layout.Row = 10;
            app.TC5.Layout.Column = 2;

            % Create TC5EditFieldLabel
            app.TC5EditFieldLabel = uilabel(app.GridLayout2);
            app.TC5EditFieldLabel.Layout.Row = 10;
            app.TC5EditFieldLabel.Layout.Column = 1;
            app.TC5EditFieldLabel.Text = 'TC 5';

            % Create TC6
            app.TC6 = uieditfield(app.GridLayout2, 'numeric');
            app.TC6.Layout.Row = 11;
            app.TC6.Layout.Column = 2;

            % Create TC6EditFieldLabel
            app.TC6EditFieldLabel = uilabel(app.GridLayout2);
            app.TC6EditFieldLabel.Layout.Row = 11;
            app.TC6EditFieldLabel.Layout.Column = 1;
            app.TC6EditFieldLabel.Text = 'TC 6';

            % Create TC7
            app.TC7 = uieditfield(app.GridLayout2, 'numeric');
            app.TC7.Layout.Row = 12;
            app.TC7.Layout.Column = 2;

            % Create TC7EditFieldLabel
            app.TC7EditFieldLabel = uilabel(app.GridLayout2);
            app.TC7EditFieldLabel.Layout.Row = 12;
            app.TC7EditFieldLabel.Layout.Column = 1;
            app.TC7EditFieldLabel.Text = 'TC 7';

            % Create TC8
            app.TC8 = uieditfield(app.GridLayout2, 'numeric');
            app.TC8.Layout.Row = 13;
            app.TC8.Layout.Column = 2;

            % Create TC8EditField_2Label
            app.TC8EditField_2Label = uilabel(app.GridLayout2);
            app.TC8EditField_2Label.Layout.Row = 13;
            app.TC8EditField_2Label.Layout.Column = 1;
            app.TC8EditField_2Label.Text = 'TC 8';

            % Create NumberofovenmovesLabel
            app.NumberofovenmovesLabel = uilabel(app.GridLayout2);
            app.NumberofovenmovesLabel.FontWeight = 'bold';
            app.NumberofovenmovesLabel.Layout.Row = 14;
            app.NumberofovenmovesLabel.Layout.Column = 1;
            app.NumberofovenmovesLabel.Text = 'Number of oven moves:';

            % Create NumberEditFieldLabel
            app.NumberEditFieldLabel = uilabel(app.GridLayout2);
            app.NumberEditFieldLabel.Layout.Row = 15;
            app.NumberEditFieldLabel.Layout.Column = 1;
            app.NumberEditFieldLabel.Text = 'Number';

            % Create NumberMoves
            app.NumberMoves = uieditfield(app.GridLayout2, 'numeric');
            app.NumberMoves.Editable = 'off';
            app.NumberMoves.Layout.Row = 15;
            app.NumberMoves.Layout.Column = 2;

            % Create LastupdateLabel
            app.LastupdateLabel = uilabel(app.GridLayout2);
            app.LastupdateLabel.Layout.Row = 16;
            app.LastupdateLabel.Layout.Column = 1;
            app.LastupdateLabel.Text = 'Last update';

            % Create LastUpdate
            app.LastUpdate = uilabel(app.GridLayout2);
            app.LastUpdate.HorizontalAlignment = 'right';
            app.LastUpdate.Layout.Row = 16;
            app.LastUpdate.Layout.Column = 2;
            app.LastUpdate.Text = '- - -';

            % Create RecountButton
            app.RecountButton = uibutton(app.GridLayout2, 'push');
            app.RecountButton.ButtonPushedFcn = createCallbackFcn(app, @RecountButtonPushed, true);
            app.RecountButton.Layout.Row = 17;
            app.RecountButton.Layout.Column = 2;
            app.RecountButton.Text = 'Recount';

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout);
            app.GridLayout3.ColumnWidth = {'1x'};
            app.GridLayout3.RowHeight = {'2.5x', '1x'};
            app.GridLayout3.Layout.Row = 2;
            app.GridLayout3.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout3);
            title(app.UIAxes, 'Oven TC Profile')
            xlabel(app.UIAxes, 'TC')
            ylabel(app.UIAxes, 'Temp [degC]')
            app.UIAxes.FontSize = 14;
            app.UIAxes.Layout.Row = 1;
            app.UIAxes.Layout.Column = 1;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout3);
            title(app.UIAxes2, 'Pressure History')
            xlabel(app.UIAxes2, 'Time [min]')
            ylabel(app.UIAxes2, 'Pressure [Torr]')
            app.UIAxes2.Layout.Row = 2;
            app.UIAxes2.Layout.Column = 1;

            % Create TimeEditFieldLabel
            app.TimeEditFieldLabel = uilabel(app.GridLayout);
            app.TimeEditFieldLabel.HorizontalAlignment = 'right';
            app.TimeEditFieldLabel.Layout.Row = 3;
            app.TimeEditFieldLabel.Layout.Column = 1;
            app.TimeEditFieldLabel.Text = 'Time';

            % Create Time
            app.Time = uieditfield(app.GridLayout, 'text');
            app.Time.Layout.Row = 3;
            app.Time.Layout.Column = 2;

            % Show the figure after all components are created
            app.OvenWatcher.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_OvenWatcher_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.OvenWatcher)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.OvenWatcher)
        end
    end
end