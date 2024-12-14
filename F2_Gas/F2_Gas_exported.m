classdef F2_Gas_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        Gas                             matlab.ui.Figure
        GridLayout2                     matlab.ui.container.GridLayout
        UIAxes                          matlab.ui.control.UIAxes
        UIAxes_2                        matlab.ui.control.UIAxes
        Zoom                            matlab.ui.control.Button
        Panel                           matlab.ui.container.Panel
        GridLayout                      matlab.ui.container.GridLayout
        GasParametersLabel              matlab.ui.control.Label
        PIDParametersLabel              matlab.ui.control.Label
        AdaptiveCheckBox                matlab.ui.control.CheckBox
        TargetpressureEditFieldLabel    matlab.ui.control.Label
        TargetpressureEditField         matlab.ui.control.NumericEditField
        IPpressureRBVEditFieldLabel     matlab.ui.control.Label
        IPpressureRBVEditField          matlab.ui.control.NumericEditField
        MFCSetPointEditFieldLabel       matlab.ui.control.Label
        MFCSetPointEditField            matlab.ui.control.NumericEditField
        FlowRateRBVEditFieldLabel       matlab.ui.control.Label
        FlowRateRBVEditField            matlab.ui.control.NumericEditField
        DerivcontributesEditFieldLabel  matlab.ui.control.Label
        DerivcontributesEditField       matlab.ui.control.NumericEditField
        IntContributesEditFieldLabel    matlab.ui.control.Label
        IntContributesEditField         matlab.ui.control.NumericEditField
        PropcontributesEditFieldLabel   matlab.ui.control.Label
        PropcontributesEditField        matlab.ui.control.NumericEditField
        GammaKdEditFieldLabel           matlab.ui.control.Label
        GammaKdEditField                matlab.ui.control.NumericEditField
        GammaKiEditFieldLabel           matlab.ui.control.Label
        GammaKiEditField                matlab.ui.control.NumericEditField
        GammaKpEditFieldLabel           matlab.ui.control.Label
        GammaKpEditField                matlab.ui.control.NumericEditField
        DeriviativeKdEditFieldLabel     matlab.ui.control.Label
        DeriviativeKdEditField          matlab.ui.control.NumericEditField
        IntegralKiEditFieldLabel        matlab.ui.control.Label
        IntegralKiEditField             matlab.ui.control.NumericEditField
        ProportionalKpEditFieldLabel    matlab.ui.control.Label
        ProportionalKpEditField         matlab.ui.control.NumericEditField
        PIDSwitchLabel                  matlab.ui.control.Label
        PIDSwitch                       matlab.ui.control.Switch
        EPSStatusLampLabel              matlab.ui.control.Label
        EPSStatusLamp                   matlab.ui.control.Lamp
    end

    
    properties (Access = private)
        aobj % Descriptionapp.flow_rateSP_history
        LoopFlag logical = false % Flag indicating the PID loop is running 
        pressure_history = nan(1,3600);
        target_pressure_history = nan(1,3600);
        flow_rateSP_history = nan(1,3600);        
        flow_rate_history = nan(1,3600);
        time = nan(1,3600);
        Xlimits = [-5 0; -10 0; -20 0; -60 0]; % plot limits
        Nxlim = 2;
    end
    
    methods (Access = private)
        
        function StartLoop(app)
            
%             if ~strcmp(obj.pvs.EPS.val, 'On')
%                 % EPS is tripped, so stop the PID
%                 app.LoopFlag = false;
%                 app.PIDSwitch.Value = 'Off';
%                 return;
%             end
      
            
            current_flow_rate = app.MFCSetPointEditField.Value
            integral_error = 0;
            previous_error = 0;
            dt = 3;
            
            n = 0;
            
            app.LoopFlag = true;
            while app.LoopFlag
                n = n+1;
                
                %% Add the PID loop here
                disp(datestr(now))
                
                % PID Controller Parameters
                Kp = app.ProportionalKpEditField.Value;   % Proportional gain
                Ki = app.IntegralKiEditField.Value;   % Integral gain
                Kd = app.DeriviativeKdEditField.Value;   % Derivative gain
            
                target_pressure = app.TargetpressureEditField.Value; % Desired pressure
                current_pressure = app.IPpressureRBVEditField.Value; % Current pressure reading
               % current_flow_rate = app.MFCSetPointEditField.Value;  % Current flow rate readback
                
                % Compute error
                error = target_pressure - current_pressure;
                
                % Update integral and derivative terms
                integral_error = integral_error + error * dt;
                derivative_error = (error - previous_error) / dt;
                
                % If using Adaptive feedback
                if app.AdaptiveCheckBox.Value
                   gamma_p = app.GammaKpEditField.Value;
                   gamma_i = app.GammaKiEditField.Value;
                   gamma_d = app.GammaKdEditField.Value;
                   
                   % Adaptive control adjustments
                   Kp = Kp + gamma_p * error * current_pressure;
                   Ki = Ki + gamma_i * error * integral_error;
                   Kd = Kd + gamma_d * error * derivative_error;
                   
                   % Update the displayed values
                   app.ProportionalKpEditField.Value = Kp;
                   app.IntegralKiEditField.Value = Ki;
                   app.DeriviativeKdEditField.Value = Kd;
                end
                                
                % PID control output
                pid_output = Kp * error + Ki * integral_error + Kd * derivative_error;
                
                %Update the contribution fields
                app.PropcontributesEditField.Value  = Kp * error;
                app.IntContributesEditField.Value   = Ki * integral_error;
                app.DerivcontributesEditField.Value = Kd * derivative_error;
                
                % Update the flow rate and clamp it within acceptable limits
                new_flow_rate = current_flow_rate + pid_output;
                new_flow_rate = min(max(new_flow_rate, 0), 1000); % Clamp between 0 and max flow rate
               
                % Update the Set Point Edit Field
                %app.MFCSetPointEditField.Value = new_flow_rate;
                % app.SP_fakeEditField.Value = new_flow_rate;
                lcaPut('VMFC:LI20:3205:FLOW_SP', new_flow_rate)
                
                % Update the previous error
                previous_error = error;
                current_flow_rate = new_flow_rate;
                
                
                app.doPlots();
                pause(1)
                
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
                if app.LoopFlag
                    % Add new target pressure value at the beginning and remove the last element
                    app.target_pressure_history = [app.TargetpressureEditField.Value, app.target_pressure_history(1:end-1)];
                else
                    % Add NaN at the beginning and remove the last element
                    app.target_pressure_history = [nan, app.target_pressure_history(1:end-1)];
                end
                app.pressure_history = [app.IPpressureRBVEditField.Value, app.pressure_history(1:end-1)];
                app.flow_rate_history = [app.FlowRateRBVEditField.Value, app.flow_rate_history(1:end-1)];
                app.flow_rateSP_history = [app.MFCSetPointEditField.Value, app.flow_rateSP_history(1:end-1)];
                %app.flow_rateSP_history = [app.SP_fakeEditField.Value, app.flow_rateSP_history(1:end-1)];
            
            
                

                plot(app.UIAxes, (app.time - app.time(1))*24*60, app.pressure_history, ...
                                 (app.time - app.time(1))*24*60, app.target_pressure_history, 'r--');
                xlim(app.UIAxes, app.Xlimits(app.Nxlim,:));
                                
                plot(app.UIAxes_2, (app.time - app.time(1))*24*60, app.flow_rate_history, ...
                                    (app.time - app.time(1))*24*60, app.flow_rateSP_history, 'r--');
                xlim(app.UIAxes_2, app.Xlimits(app.Nxlim,:));
            
             %   app.UIAxes.YAxis.TickLabelFormat = '%15g'
             %   app.UIAxes_2.YAxis.TickLabelFormat = '%15g'
        end
        
        function UpdatePlots(app)
            pause(5)
            while true
                app.doPlots();
                pause(1)
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.aobj=F2_GasApp(app);
            
            app.TargetpressureEditField.Value = lcaGet(char(app.aobj.pvlist(1).pvname)); % Start with the current value as the target value
            
            app.UpdatePlots();
        end

        % Value changed function: PIDSwitch
        function PIDSwitchValueChanged(app, event)
            value = app.PIDSwitch.Value;
            
            switch value
                case 'On'
                    app.StartLoop();
                case 'Off'
                    app.StopLoop();
            end

        end

        % Button pushed function: Zoom
        function ZoomButtonPushed(app, event)
            app.Nxlim = app.Nxlim+1;
            if app.Nxlim>4
                app.Nxlim=1;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create Gas and hide until all components are created
            app.Gas = uifigure('Visible', 'off');
            app.Gas.Position = [100 100 744 654];
            app.Gas.Name = 'Static Fill Gas PID';

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.Gas);
            app.GridLayout2.ColumnWidth = {259.98, '1x', 56.99, '2.55x', 43, 20};
            app.GridLayout2.RowHeight = {'1x', '1x', 22};
            app.GridLayout2.ColumnSpacing = 7.88901646931966;
            app.GridLayout2.RowSpacing = 7.99891510009766;
            app.GridLayout2.Padding = [7.88901646931966 7.99891510009766 7.88901646931966 7.99891510009766];

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout2);
            title(app.UIAxes, 'IP Pressure')
            xlabel(app.UIAxes, 'Time [min]')
            ylabel(app.UIAxes, 'Pressure [Torr]')
            app.UIAxes.Layout.Row = 1;
            app.UIAxes.Layout.Column = [2 6];

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.GridLayout2);
            title(app.UIAxes_2, 'MFC Gas Flow Rates')
            xlabel(app.UIAxes_2, 'Time [min]')
            ylabel(app.UIAxes_2, 'Flow rate')
            app.UIAxes_2.Layout.Row = 2;
            app.UIAxes_2.Layout.Column = [2 6];

            % Create Zoom
            app.Zoom = uibutton(app.GridLayout2, 'push');
            app.Zoom.ButtonPushedFcn = createCallbackFcn(app, @ZoomButtonPushed, true);
            app.Zoom.IconAlignment = 'center';
            app.Zoom.Layout.Row = 3;
            app.Zoom.Layout.Column = 6;
            app.Zoom.Text = ' <> ';

            % Create Panel
            app.Panel = uipanel(app.GridLayout2);
            app.Panel.Layout.Row = [1 3];
            app.Panel.Layout.Column = 1;

            % Create GridLayout
            app.GridLayout = uigridlayout(app.Panel);
            app.GridLayout.ColumnWidth = {105.99, 97.98};
            app.GridLayout.RowHeight = {23, 22, 22, 22, 22, 22, 5, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23};

            % Create GasParametersLabel
            app.GasParametersLabel = uilabel(app.GridLayout);
            app.GasParametersLabel.FontSize = 13;
            app.GasParametersLabel.FontWeight = 'bold';
            app.GasParametersLabel.Layout.Row = 1;
            app.GasParametersLabel.Layout.Column = 1;
            app.GasParametersLabel.Text = 'Gas Parameters';

            % Create PIDParametersLabel
            app.PIDParametersLabel = uilabel(app.GridLayout);
            app.PIDParametersLabel.FontSize = 13;
            app.PIDParametersLabel.FontWeight = 'bold';
            app.PIDParametersLabel.Layout.Row = 8;
            app.PIDParametersLabel.Layout.Column = 1;
            app.PIDParametersLabel.Text = 'PID Parameters';

            % Create AdaptiveCheckBox
            app.AdaptiveCheckBox = uicheckbox(app.GridLayout);
            app.AdaptiveCheckBox.Text = 'Adaptive';
            app.AdaptiveCheckBox.Layout.Row = 13;
            app.AdaptiveCheckBox.Layout.Column = 1;

            % Create TargetpressureEditFieldLabel
            app.TargetpressureEditFieldLabel = uilabel(app.GridLayout);
            app.TargetpressureEditFieldLabel.Layout.Row = 2;
            app.TargetpressureEditFieldLabel.Layout.Column = 1;
            app.TargetpressureEditFieldLabel.Text = 'Target pressure';

            % Create TargetpressureEditField
            app.TargetpressureEditField = uieditfield(app.GridLayout, 'numeric');
            app.TargetpressureEditField.HorizontalAlignment = 'left';
            app.TargetpressureEditField.Layout.Row = 2;
            app.TargetpressureEditField.Layout.Column = 2;

            % Create IPpressureRBVEditFieldLabel
            app.IPpressureRBVEditFieldLabel = uilabel(app.GridLayout);
            app.IPpressureRBVEditFieldLabel.Layout.Row = 3;
            app.IPpressureRBVEditFieldLabel.Layout.Column = 1;
            app.IPpressureRBVEditFieldLabel.Text = 'IP pressure RBV';

            % Create IPpressureRBVEditField
            app.IPpressureRBVEditField = uieditfield(app.GridLayout, 'numeric');
            app.IPpressureRBVEditField.Editable = 'off';
            app.IPpressureRBVEditField.HorizontalAlignment = 'left';
            app.IPpressureRBVEditField.Layout.Row = 3;
            app.IPpressureRBVEditField.Layout.Column = 2;

            % Create MFCSetPointEditFieldLabel
            app.MFCSetPointEditFieldLabel = uilabel(app.GridLayout);
            app.MFCSetPointEditFieldLabel.Layout.Row = 4;
            app.MFCSetPointEditFieldLabel.Layout.Column = 1;
            app.MFCSetPointEditFieldLabel.Text = 'MFC Set Point';

            % Create MFCSetPointEditField
            app.MFCSetPointEditField = uieditfield(app.GridLayout, 'numeric');
            app.MFCSetPointEditField.HorizontalAlignment = 'left';
            app.MFCSetPointEditField.Layout.Row = 4;
            app.MFCSetPointEditField.Layout.Column = 2;

            % Create FlowRateRBVEditFieldLabel
            app.FlowRateRBVEditFieldLabel = uilabel(app.GridLayout);
            app.FlowRateRBVEditFieldLabel.Layout.Row = 5;
            app.FlowRateRBVEditFieldLabel.Layout.Column = 1;
            app.FlowRateRBVEditFieldLabel.Text = 'Flow Rate RBV';

            % Create FlowRateRBVEditField
            app.FlowRateRBVEditField = uieditfield(app.GridLayout, 'numeric');
            app.FlowRateRBVEditField.Editable = 'off';
            app.FlowRateRBVEditField.HorizontalAlignment = 'left';
            app.FlowRateRBVEditField.Layout.Row = 5;
            app.FlowRateRBVEditField.Layout.Column = 2;

            % Create DerivcontributesEditFieldLabel
            app.DerivcontributesEditFieldLabel = uilabel(app.GridLayout);
            app.DerivcontributesEditFieldLabel.HorizontalAlignment = 'right';
            app.DerivcontributesEditFieldLabel.FontColor = [0.502 0.502 0.502];
            app.DerivcontributesEditFieldLabel.Layout.Row = 19;
            app.DerivcontributesEditFieldLabel.Layout.Column = 1;
            app.DerivcontributesEditFieldLabel.Text = 'Deriv contributes';

            % Create DerivcontributesEditField
            app.DerivcontributesEditField = uieditfield(app.GridLayout, 'numeric');
            app.DerivcontributesEditField.Editable = 'off';
            app.DerivcontributesEditField.FontColor = [0.502 0.502 0.502];
            app.DerivcontributesEditField.Layout.Row = 19;
            app.DerivcontributesEditField.Layout.Column = 2;

            % Create IntContributesEditFieldLabel
            app.IntContributesEditFieldLabel = uilabel(app.GridLayout);
            app.IntContributesEditFieldLabel.HorizontalAlignment = 'right';
            app.IntContributesEditFieldLabel.FontColor = [0.502 0.502 0.502];
            app.IntContributesEditFieldLabel.Layout.Row = 18;
            app.IntContributesEditFieldLabel.Layout.Column = 1;
            app.IntContributesEditFieldLabel.Text = 'Int Contributes';

            % Create IntContributesEditField
            app.IntContributesEditField = uieditfield(app.GridLayout, 'numeric');
            app.IntContributesEditField.Editable = 'off';
            app.IntContributesEditField.FontColor = [0.502 0.502 0.502];
            app.IntContributesEditField.Layout.Row = 18;
            app.IntContributesEditField.Layout.Column = 2;

            % Create PropcontributesEditFieldLabel
            app.PropcontributesEditFieldLabel = uilabel(app.GridLayout);
            app.PropcontributesEditFieldLabel.HorizontalAlignment = 'right';
            app.PropcontributesEditFieldLabel.FontColor = [0.502 0.502 0.502];
            app.PropcontributesEditFieldLabel.Layout.Row = 17;
            app.PropcontributesEditFieldLabel.Layout.Column = 1;
            app.PropcontributesEditFieldLabel.Text = 'Prop contributes';

            % Create PropcontributesEditField
            app.PropcontributesEditField = uieditfield(app.GridLayout, 'numeric');
            app.PropcontributesEditField.Editable = 'off';
            app.PropcontributesEditField.FontColor = [0.502 0.502 0.502];
            app.PropcontributesEditField.Layout.Row = 17;
            app.PropcontributesEditField.Layout.Column = 2;

            % Create GammaKdEditFieldLabel
            app.GammaKdEditFieldLabel = uilabel(app.GridLayout);
            app.GammaKdEditFieldLabel.Layout.Row = 16;
            app.GammaKdEditFieldLabel.Layout.Column = 1;
            app.GammaKdEditFieldLabel.Text = 'Gamma Kd';

            % Create GammaKdEditField
            app.GammaKdEditField = uieditfield(app.GridLayout, 'numeric');
            app.GammaKdEditField.HorizontalAlignment = 'left';
            app.GammaKdEditField.Layout.Row = 16;
            app.GammaKdEditField.Layout.Column = 2;
            app.GammaKdEditField.Value = 0.01;

            % Create GammaKiEditFieldLabel
            app.GammaKiEditFieldLabel = uilabel(app.GridLayout);
            app.GammaKiEditFieldLabel.Layout.Row = 15;
            app.GammaKiEditFieldLabel.Layout.Column = 1;
            app.GammaKiEditFieldLabel.Text = 'Gamma Ki';

            % Create GammaKiEditField
            app.GammaKiEditField = uieditfield(app.GridLayout, 'numeric');
            app.GammaKiEditField.HorizontalAlignment = 'left';
            app.GammaKiEditField.Layout.Row = 15;
            app.GammaKiEditField.Layout.Column = 2;
            app.GammaKiEditField.Value = 0.01;

            % Create GammaKpEditFieldLabel
            app.GammaKpEditFieldLabel = uilabel(app.GridLayout);
            app.GammaKpEditFieldLabel.Layout.Row = 14;
            app.GammaKpEditFieldLabel.Layout.Column = 1;
            app.GammaKpEditFieldLabel.Text = 'Gamma Kp';

            % Create GammaKpEditField
            app.GammaKpEditField = uieditfield(app.GridLayout, 'numeric');
            app.GammaKpEditField.HorizontalAlignment = 'left';
            app.GammaKpEditField.Layout.Row = 14;
            app.GammaKpEditField.Layout.Column = 2;
            app.GammaKpEditField.Value = 0.01;

            % Create DeriviativeKdEditFieldLabel
            app.DeriviativeKdEditFieldLabel = uilabel(app.GridLayout);
            app.DeriviativeKdEditFieldLabel.Layout.Row = 12;
            app.DeriviativeKdEditFieldLabel.Layout.Column = 1;
            app.DeriviativeKdEditFieldLabel.Text = 'Deriviative, Kd';

            % Create DeriviativeKdEditField
            app.DeriviativeKdEditField = uieditfield(app.GridLayout, 'numeric');
            app.DeriviativeKdEditField.HorizontalAlignment = 'left';
            app.DeriviativeKdEditField.Layout.Row = 12;
            app.DeriviativeKdEditField.Layout.Column = 2;
            app.DeriviativeKdEditField.Value = 1500;

            % Create IntegralKiEditFieldLabel
            app.IntegralKiEditFieldLabel = uilabel(app.GridLayout);
            app.IntegralKiEditFieldLabel.Layout.Row = 11;
            app.IntegralKiEditFieldLabel.Layout.Column = 1;
            app.IntegralKiEditFieldLabel.Text = 'Integral, Ki';

            % Create IntegralKiEditField
            app.IntegralKiEditField = uieditfield(app.GridLayout, 'numeric');
            app.IntegralKiEditField.HorizontalAlignment = 'left';
            app.IntegralKiEditField.Layout.Row = 11;
            app.IntegralKiEditField.Layout.Column = 2;
            app.IntegralKiEditField.Value = 0.0015;

            % Create ProportionalKpEditFieldLabel
            app.ProportionalKpEditFieldLabel = uilabel(app.GridLayout);
            app.ProportionalKpEditFieldLabel.Layout.Row = 10;
            app.ProportionalKpEditFieldLabel.Layout.Column = 1;
            app.ProportionalKpEditFieldLabel.Text = 'Proportional, Kp';

            % Create ProportionalKpEditField
            app.ProportionalKpEditField = uieditfield(app.GridLayout, 'numeric');
            app.ProportionalKpEditField.HorizontalAlignment = 'left';
            app.ProportionalKpEditField.Layout.Row = 10;
            app.ProportionalKpEditField.Layout.Column = 2;
            app.ProportionalKpEditField.Value = 6;

            % Create PIDSwitchLabel
            app.PIDSwitchLabel = uilabel(app.GridLayout);
            app.PIDSwitchLabel.Layout.Row = 9;
            app.PIDSwitchLabel.Layout.Column = 1;
            app.PIDSwitchLabel.Text = 'PID';

            % Create PIDSwitch
            app.PIDSwitch = uiswitch(app.GridLayout, 'slider');
            app.PIDSwitch.ValueChangedFcn = createCallbackFcn(app, @PIDSwitchValueChanged, true);
            app.PIDSwitch.Layout.Row = 9;
            app.PIDSwitch.Layout.Column = 2;

            % Create EPSStatusLampLabel
            app.EPSStatusLampLabel = uilabel(app.GridLayout);
            app.EPSStatusLampLabel.Layout.Row = 6;
            app.EPSStatusLampLabel.Layout.Column = 1;
            app.EPSStatusLampLabel.Text = 'EPS Status';

            % Create EPSStatusLamp
            app.EPSStatusLamp = uilamp(app.GridLayout);
            app.EPSStatusLamp.Layout.Row = 6;
            app.EPSStatusLamp.Layout.Column = 2;

            % Show the figure after all components are created
            app.Gas.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_Gas_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.Gas)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.Gas)
        end
    end
end