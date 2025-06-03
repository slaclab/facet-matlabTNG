classdef F2_OvenWatcher_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        OvenWatcher                    matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        StatusButton                   matlab.ui.control.Button
        GridLayout2                    matlab.ui.container.GridLayout
        PressureStatusesLabel          matlab.ui.control.Label
        IPPressureEditFieldLabel       matlab.ui.control.Label
        IPPressure                     matlab.ui.control.NumericEditField
        LimitsLoHiLabel                matlab.ui.control.Label
        LowerThreshold                 matlab.ui.control.NumericEditField
        UpperThreshold                 matlab.ui.control.NumericEditField
        ThermocoupleStatusesLabel      matlab.ui.control.Label
        TC4                            matlab.ui.control.NumericEditField
        TC4EditFieldLabel              matlab.ui.control.Label
        TC3                            matlab.ui.control.NumericEditField
        TC3EditFieldLabel              matlab.ui.control.Label
        TC2                            matlab.ui.control.NumericEditField
        TC2EditFieldLabel              matlab.ui.control.Label
        TC1                            matlab.ui.control.NumericEditField
        TC1EditFieldLabel              matlab.ui.control.Label
        TC5                            matlab.ui.control.NumericEditField
        TC5EditFieldLabel              matlab.ui.control.Label
        TC6                            matlab.ui.control.NumericEditField
        TC6EditFieldLabel              matlab.ui.control.Label
        TC7                            matlab.ui.control.NumericEditField
        TC7EditFieldLabel              matlab.ui.control.Label
        TC8                            matlab.ui.control.NumericEditField
        TC8EditField_2Label            matlab.ui.control.Label
        HighLimitLabel                 matlab.ui.control.Label
        TC1highLimit                   matlab.ui.control.NumericEditField
        TC4highLimit                   matlab.ui.control.NumericEditField
        TC3highLimit                   matlab.ui.control.NumericEditField
        TC2highLimit                   matlab.ui.control.NumericEditField
        TC5highLimit                   matlab.ui.control.NumericEditField
        TC6highLimit                   matlab.ui.control.NumericEditField
        TC7highLimit                   matlab.ui.control.NumericEditField
        TC8highLimit                   matlab.ui.control.NumericEditField
        ReadbacksLabel                 matlab.ui.control.Label
        ThermocoupleSetPointsLabel     matlab.ui.control.Label
        CurrenttempsassetpointsButton  matlab.ui.control.Button
        TorrovenButton4                matlab.ui.control.Button
        TorrovenButton5                matlab.ui.control.Button
        GridLayout3                    matlab.ui.container.GridLayout
        UIAxes                         matlab.ui.control.UIAxes
        UIAxes2                        matlab.ui.control.UIAxes
        GridLayout4                    matlab.ui.container.GridLayout
        OvenmovesLabel                 matlab.ui.control.Label
        NumberMoves                    matlab.ui.control.NumericEditField
        RecountButton                  matlab.ui.control.Button
        GridLayout5                    matlab.ui.container.GridLayout
        TimeEditFieldLabel             matlab.ui.control.Label
        Time                           matlab.ui.control.EditField
    end

    
    properties (Access = private)
        aobj % Descriptionapp.flow_rateSP_history
        LoopFlag logical = false % Flag indicating the PID loop is running 
        pressure_history = nan(1,3600);
        TC_history = nan(600,8);
        time = nan(1,3600);
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
                    app.StatusButton.BackgroundColor = [1 0 0];
        %            start(app.uibTimer);
                end
                if app.IPPressure.Value > app.UpperThreshold.Value
                    app.StatusButton.BackgroundColor = [1 0 0];
                end

                if app.IPPressure.Value > app.LowerThreshold.Value
                   if app.IPPressure.Value < app.UpperThreshold.Value
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
            
            
            TCcurrent = [app.TC4.Value, app.TC3.Value, app.TC2.Value, app.TC1.Value, app.TC5.Value, app.TC6.Value, app.TC7.Value, app.TC8.Value];
            TClimits = [app.TC4highLimit.Value, app.TC3highLimit.Value, app.TC2highLimit.Value, app.TC1highLimit.Value, app.TC5highLimit.Value, app.TC6highLimit.Value, app.TC7highLimit.Value, app.TC8highLimit.Value];
            TCsetpoint = lcaGetSmart(["SIOC:SYS1:ML02:AO525", ...
                "SIOC:SYS1:ML02:AO524", ...
                "SIOC:SYS1:ML02:AO523", ...
                "SIOC:SYS1:ML02:AO522", ...
                "SIOC:SYS1:ML02:AO526", ...
                "SIOC:SYS1:ML02:AO527", ...
                "SIOC:SYS1:ML02:AO528", ... 
                "SIOC:SYS1:ML02:AO529"]);
            
            app.TC_history = [TCcurrent; app.TC_history(1:end-1,:)];
            
            x = TCpos;
            y = app.TC_history;
            scatter(app.UIAxes, repmat(x', size(y,1), 1), reshape(y',[],1), 36,  [ linspace(0, 1, size(y(:),1))' linspace(0, 1, size(y(:),1))' linspace(1, 1, size(y(:),1))'], 'filled')
            hold(app.UIAxes, 'on')
            
            hCurrent = plot(app.UIAxes, TCpos, TCcurrent, 'bo-','MarkerFaceColor','b');
            
            %plot(app.UIAxes, TCpos, Tref_4_1, 'r.-');
            %plot(app.UIAxes, TCpos, Tref_6_1, 'g.-');
            hSP = plot(app.UIAxes, TCpos, TCsetpoint, 'g.-');
            
            xlim(app.UIAxes, [1 7.5])
            
            
            xticks(app.UIAxes, TCpos)
            xticklabels(app.UIAxes, TC)
            
            plot(app.UIAxes, TCpos, TClimits, 'r:');
                        
            yl = ylim(app.UIAxes);
            hLimits = fill(app.UIAxes, [TCpos(1) TCpos TCpos(end)], [yl(2) TClimits (yl(2))], 'r', 'FaceAlpha', 0.3, 'EdgeColor', 'none');

            leg = legend(app.UIAxes, [hCurrent hSP hLimits], {'Oven temps', 'Setpoints', 'High limits'}, 'Location', 'South')
            leg.Box = 'Off'
            
            hold(app.UIAxes, 'off')

            
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
            app.LoopFlag = true;
            
            pause(5)
            
            
            while app.LoopFlag
                app.doPlots();
                
                [tempStatus, txtTemp] = checkTemps(app);
                [pressureStatus, txtPressure] = checkPressure(app);
                
                
                if ~pressureStatus && ~tempStatus
                    app.StatusButton.BackgroundColor = colorFlash(app);%[1 0 0];
                    app.StatusButton.Text = [txtPressure '  and  ' txtTemp];
                elseif ~pressureStatus
                    app.StatusButton.BackgroundColor = colorFlash(app);%[1 0 0];
                    app.StatusButton.Text = txtPressure;
                elseif ~tempStatus
                    app.StatusButton.BackgroundColor = colorFlash(app);%[1 0 0];
                    app.StatusButton.Text = txtTemp;
                else
                    app.StatusButton.BackgroundColor = [0 1 0];
                    app.StatusButton.Text = '';
                end
                
                app.Time.Value = datestr(now);
                
                pause(1);
                
            end
        end
        
        
        function col = colorFlash(app)
            if app.col == 0
                col = [1 1 0];
                app.col = 1;
            else
                col = [1 0 0];
                app.col = 0;
            end
        end
        
        
        function [pressureStatus, txt] = checkPressure(app)
            
            % Reset to white
            app.LowerThreshold.BackgroundColor = [1 1 1];
            app.UpperThreshold.BackgroundColor = [1 1 1];
            
            % Initialize pressure status as true (indicating all is good)
            pressureStatus = true; % pressure is all good.
            txt = '';
            
            if app.IPPressure.Value > app.UpperThreshold.Value
                app.UpperThreshold.BackgroundColor = [1 0 0];
                txt = 'High Pressure!';
                pressureStatus = false;
            end
            
            if app.IPPressure.Value < app.LowerThreshold.Value
                app.LowerThreshold.BackgroundColor  = [1 0 0];
                txt = 'Low Pressure!';
                pressureStatus = false;
            end

            
        end
        
        
        function [tempStatus, txt] = checkTemps(app)
                        
            conditions = [
                app.TC1.Value < app.TC1highLimit.Value,
                app.TC2.Value < app.TC2highLimit.Value,
                app.TC3.Value < app.TC3highLimit.Value,
                app.TC4.Value < app.TC4highLimit.Value,
                app.TC5.Value < app.TC5highLimit.Value,
                app.TC6.Value < app.TC6highLimit.Value,
                app.TC7.Value < app.TC7highLimit.Value,
                app.TC8.Value < app.TC8highLimit.Value
                ];
            
            % Initialize tempStatus to true
            tempStatus = true;
            txt = '';
            
            % Loop through each TC and update the background color based on the condition
                       
            for i = 1:length(conditions)
                % Check if the condition is false
                if ~conditions(i)
                    % Set the background color to red if the condition is false
                    app.(['TC', num2str(i), 'highLimit']).BackgroundColor = [1 0 0];
                    tempStatus = false; % Change tempStatus to false if any condition fails
                    txt = 'Oven Temperature High!';
                else
                    % Set the background color to black if the condition is true
                    app.(['TC', num2str(i), 'highLimit']).BackgroundColor = [1 1 1];
                end
            end
            
        end
        
        function closeApp(app)
            % Perform any necessary cleanup here
            disp('Cleaning up before closing the app...');
            
            % Optionally, you can check if the app is valid
            if isvalid(app)
                
                app.LoopFlag = false;
                % Stop any ongoing processes or timers
                % For example, if you have a timer:
                % stop(app.MyTimer);
                
                % You can also save any necessary data or state here
            end
            
            % Delete the app object
            delete(app.OvenWatcher); % This will close the window
        end
        
        
        function setTCsetpoints(app,val)

            % These need more lengths, pressures added
            if length(val)==1
                switch val
                    case 0
                        val = [  433.9037   766.2682   836.5607  841.3602  840.9602  835.8607  736.7713  399.5074]';
                    case 4
                        val = [434 767 836 841 841 836 737 400]';
                    case 5
                        val = [430 767 850 855 854 846 735 395]';  
                    otherwise
                        disp('Invalid entry to setTCsetpoints');
                        return
                end
            end
            
            lcaPutSmart(["SIOC:SYS1:ML02:AO525", ...
                "SIOC:SYS1:ML02:AO524", ...
                "SIOC:SYS1:ML02:AO523", ...
                "SIOC:SYS1:ML02:AO522", ...
                "SIOC:SYS1:ML02:AO526", ...
                "SIOC:SYS1:ML02:AO527", ...
                "SIOC:SYS1:ML02:AO528", ... 
                "SIOC:SYS1:ML02:AO529"], val);
            
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.aobj=F2_OvenWatcherApp(app);
            
            %To close without error
            app.OvenWatcher.CloseRequestFcn = @(src, event) closeApp(app);
            
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
            
            
            
            [~, ~, union_times, union_values] = history(PVs, [dateStart dateEnd]);
            
            ind = ~sum(isnan(union_values),2);
            
            t = union_times(ind);
            motor = union_values(ind,1);
            pos_sum = union_values(ind,2);
                        
            t = (t-t(1))*60*24;
            
            [pks_pos_sum,locs_pos_sum] = findpeaks(pos_sum,t);
            
            app.NumberMoves.Value = sum(pks_pos_sum==2);
            %app.LastUpdate.Text = datestr(dateEnd, 'mmm-dd HH:MM');

        end

        % Button pushed function: CurrenttempsassetpointsButton
        function CurrenttempsassetpointsButtonPushed(app, event)
            vals = [app.TC1.Value, app.TC2.Value, app.TC3.Value, app.TC4.Value, app.TC5.Value, app.TC6.Value, app.TC7.Value, app.TC8.Value]';
            setTCsetpoints(app, vals);
        end

        % Button pushed function: TorrovenButton4
        function TorrovenButton4Pushed(app, event)
            setTCsetpoints(app, 4);
        end

        % Button pushed function: TorrovenButton5
        function TorrovenButton5Pushed(app, event)
            setTCsetpoints(app, 5);
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
            app.GridLayout.ColumnWidth = {257, '100x'};
            app.GridLayout.RowHeight = {'5x', '25x', '1x'};

            % Create StatusButton
            app.StatusButton = uibutton(app.GridLayout, 'push');
            app.StatusButton.FontSize = 32;
            app.StatusButton.Layout.Row = 1;
            app.StatusButton.Layout.Column = [1 2];
            app.StatusButton.Text = 'Status';

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'3x', '3x', '3x'};
            app.GridLayout2.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout2.Layout.Row = 2;
            app.GridLayout2.Layout.Column = 1;

            % Create PressureStatusesLabel
            app.PressureStatusesLabel = uilabel(app.GridLayout2);
            app.PressureStatusesLabel.FontWeight = 'bold';
            app.PressureStatusesLabel.Layout.Row = 1;
            app.PressureStatusesLabel.Layout.Column = [1 2];
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

            % Create LimitsLoHiLabel
            app.LimitsLoHiLabel = uilabel(app.GridLayout2);
            app.LimitsLoHiLabel.Layout.Row = 3;
            app.LimitsLoHiLabel.Layout.Column = 1;
            app.LimitsLoHiLabel.Text = 'Limits (Lo/Hi)';

            % Create LowerThreshold
            app.LowerThreshold = uieditfield(app.GridLayout2, 'numeric');
            app.LowerThreshold.Layout.Row = 3;
            app.LowerThreshold.Layout.Column = 2;

            % Create UpperThreshold
            app.UpperThreshold = uieditfield(app.GridLayout2, 'numeric');
            app.UpperThreshold.Layout.Row = 3;
            app.UpperThreshold.Layout.Column = 3;

            % Create ThermocoupleStatusesLabel
            app.ThermocoupleStatusesLabel = uilabel(app.GridLayout2);
            app.ThermocoupleStatusesLabel.FontWeight = 'bold';
            app.ThermocoupleStatusesLabel.Layout.Row = 4;
            app.ThermocoupleStatusesLabel.Layout.Column = [1 2];
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

            % Create HighLimitLabel
            app.HighLimitLabel = uilabel(app.GridLayout2);
            app.HighLimitLabel.HorizontalAlignment = 'center';
            app.HighLimitLabel.Layout.Row = 5;
            app.HighLimitLabel.Layout.Column = 3;
            app.HighLimitLabel.Text = 'High Limit';

            % Create TC1highLimit
            app.TC1highLimit = uieditfield(app.GridLayout2, 'numeric');
            app.TC1highLimit.Layout.Row = 9;
            app.TC1highLimit.Layout.Column = 3;

            % Create TC4highLimit
            app.TC4highLimit = uieditfield(app.GridLayout2, 'numeric');
            app.TC4highLimit.Layout.Row = 6;
            app.TC4highLimit.Layout.Column = 3;

            % Create TC3highLimit
            app.TC3highLimit = uieditfield(app.GridLayout2, 'numeric');
            app.TC3highLimit.Layout.Row = 7;
            app.TC3highLimit.Layout.Column = 3;

            % Create TC2highLimit
            app.TC2highLimit = uieditfield(app.GridLayout2, 'numeric');
            app.TC2highLimit.Layout.Row = 8;
            app.TC2highLimit.Layout.Column = 3;

            % Create TC5highLimit
            app.TC5highLimit = uieditfield(app.GridLayout2, 'numeric');
            app.TC5highLimit.Layout.Row = 10;
            app.TC5highLimit.Layout.Column = 3;

            % Create TC6highLimit
            app.TC6highLimit = uieditfield(app.GridLayout2, 'numeric');
            app.TC6highLimit.Layout.Row = 11;
            app.TC6highLimit.Layout.Column = 3;

            % Create TC7highLimit
            app.TC7highLimit = uieditfield(app.GridLayout2, 'numeric');
            app.TC7highLimit.Layout.Row = 12;
            app.TC7highLimit.Layout.Column = 3;

            % Create TC8highLimit
            app.TC8highLimit = uieditfield(app.GridLayout2, 'numeric');
            app.TC8highLimit.Layout.Row = 13;
            app.TC8highLimit.Layout.Column = 3;

            % Create ReadbacksLabel
            app.ReadbacksLabel = uilabel(app.GridLayout2);
            app.ReadbacksLabel.HorizontalAlignment = 'center';
            app.ReadbacksLabel.Layout.Row = 5;
            app.ReadbacksLabel.Layout.Column = 2;
            app.ReadbacksLabel.Text = 'Readbacks';

            % Create ThermocoupleSetPointsLabel
            app.ThermocoupleSetPointsLabel = uilabel(app.GridLayout2);
            app.ThermocoupleSetPointsLabel.FontWeight = 'bold';
            app.ThermocoupleSetPointsLabel.Layout.Row = 14;
            app.ThermocoupleSetPointsLabel.Layout.Column = [1 2];
            app.ThermocoupleSetPointsLabel.Text = 'Thermocouple Set Points:';

            % Create CurrenttempsassetpointsButton
            app.CurrenttempsassetpointsButton = uibutton(app.GridLayout2, 'push');
            app.CurrenttempsassetpointsButton.ButtonPushedFcn = createCallbackFcn(app, @CurrenttempsassetpointsButtonPushed, true);
            app.CurrenttempsassetpointsButton.Layout.Row = 15;
            app.CurrenttempsassetpointsButton.Layout.Column = [1 3];
            app.CurrenttempsassetpointsButton.Text = 'Current temps as set points';

            % Create TorrovenButton4
            app.TorrovenButton4 = uibutton(app.GridLayout2, 'push');
            app.TorrovenButton4.ButtonPushedFcn = createCallbackFcn(app, @TorrovenButton4Pushed, true);
            app.TorrovenButton4.Layout.Row = 16;
            app.TorrovenButton4.Layout.Column = 1;
            app.TorrovenButton4.Text = '4 Torr oven';

            % Create TorrovenButton5
            app.TorrovenButton5 = uibutton(app.GridLayout2, 'push');
            app.TorrovenButton5.ButtonPushedFcn = createCallbackFcn(app, @TorrovenButton5Pushed, true);
            app.TorrovenButton5.Layout.Row = 17;
            app.TorrovenButton5.Layout.Column = 1;
            app.TorrovenButton5.Text = '5 Torr oven';

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

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.ColumnWidth = {'2x', '1x', '2x'};
            app.GridLayout4.RowHeight = {'1x'};
            app.GridLayout4.Padding = [10 0 10 0];
            app.GridLayout4.Layout.Row = 3;
            app.GridLayout4.Layout.Column = 1;

            % Create OvenmovesLabel
            app.OvenmovesLabel = uilabel(app.GridLayout4);
            app.OvenmovesLabel.Layout.Row = 1;
            app.OvenmovesLabel.Layout.Column = 1;
            app.OvenmovesLabel.Text = '# Oven moves:';

            % Create NumberMoves
            app.NumberMoves = uieditfield(app.GridLayout4, 'numeric');
            app.NumberMoves.Editable = 'off';
            app.NumberMoves.Layout.Row = 1;
            app.NumberMoves.Layout.Column = 2;

            % Create RecountButton
            app.RecountButton = uibutton(app.GridLayout4, 'push');
            app.RecountButton.ButtonPushedFcn = createCallbackFcn(app, @RecountButtonPushed, true);
            app.RecountButton.Layout.Row = 1;
            app.RecountButton.Layout.Column = 3;
            app.RecountButton.Text = 'Recount';

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.GridLayout);
            app.GridLayout5.ColumnWidth = {'1x', '1x', '2x'};
            app.GridLayout5.RowHeight = {'1x'};
            app.GridLayout5.Padding = [10 0 10 0];
            app.GridLayout5.Layout.Row = 3;
            app.GridLayout5.Layout.Column = 2;

            % Create TimeEditFieldLabel
            app.TimeEditFieldLabel = uilabel(app.GridLayout5);
            app.TimeEditFieldLabel.HorizontalAlignment = 'right';
            app.TimeEditFieldLabel.Layout.Row = 1;
            app.TimeEditFieldLabel.Layout.Column = 2;
            app.TimeEditFieldLabel.Text = 'Time';

            % Create Time
            app.Time = uieditfield(app.GridLayout5, 'text');
            app.Time.Layout.Row = 1;
            app.Time.Layout.Column = 3;

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