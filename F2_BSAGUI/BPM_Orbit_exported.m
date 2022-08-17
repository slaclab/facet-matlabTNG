classdef BPM_Orbit_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        BPMOrbitUIFigure        matlab.ui.Figure
        GridLayout              matlab.ui.container.GridLayout
        UIAxes                  matlab.ui.control.UIAxes
        PulseSlider             matlab.ui.control.Slider
        CloseButton             matlab.ui.control.Button
        ButtonGroup             matlab.ui.container.ButtonGroup
        XButton                 matlab.ui.control.ToggleButton
        YButton                 matlab.ui.control.ToggleButton
        TMITButton              matlab.ui.control.ToggleButton
        GridLayout2             matlab.ui.container.GridLayout
        PulseNumEditFieldLabel  matlab.ui.control.Label
        PulseNumEditField       matlab.ui.control.NumericEditField
        NextPulse               matlab.ui.control.Button
        LastPulse               matlab.ui.control.Button
        Play                    matlab.ui.control.Button
        Pause                   matlab.ui.control.Button
        BeamLine                matlab.ui.container.ButtonGroup
        HXRButton               matlab.ui.control.RadioButton
        SXRButton               matlab.ui.control.RadioButton
    end

    
    properties (Access = public)
        BG_mdl % BSA_GUI model object holding app data and state
        orbit_mdl % BPM_Orbit model object holding app data and state
        play % 1 if 'play' is on, 0 if static
        play_rate % rate at which orbit plot changes
        orbitPlot % plot object for primary orbit plot
        orbitPlot_2 % plot object for plot using asterisks for points
        current_coor = 'X' % currently selected plot coordinate ('X', 'Y', or 'TMIT')
        
        STDERR = 2
        
        % Listeners
        plotOrbitListener
        processBPMSListener
    end
    
    methods (Access = private)
        
        function errorMessage(app, ex, callbackMessage)
            err = ex.stack(1);
            file = err.file; funcname = err.name; linenum = num2str(err.line);
            file = strsplit(file, '/'); file = file{end};
            loc = sprintf('File: %s   Function: %s   Line: %s', file, funcname, linenum);
            uiwait(errordlg(...
                    lprintf(app.STDERR, '%s%c%s%c%s', callbackMessage, newline, ex.message, newline, loc)));
        end
        
        function process_bpms(app)
            % set slider and pulse label
            app.PulseSlider.Limits=[1,length(app.orbit_mdl.pulses)];
            app.PulseNumEditField.Limits=app.PulseSlider.Limits;
            app.PulseSlider.Value = app.orbit_mdl.pulse_num;
            app.PulseNumEditField.Value = app.orbit_mdl.pulse_num;
        end
        
        function plot_orbit(app)
            % Create the initial orbit plot. This function is called on
            % initialization, and changes in the beam line or the plot
            % coordinate
            
            % Determine selected coordinate and retrieve the appropriate
            % data struct
            app.current_coor = app.ButtonGroup.SelectedObject.Text;
            bpms = app.orbit_mdl.(app.current_coor);
            bpm_idx = bpms.bpm_idx;
            bpm_names = bpms.bpm_names;
            bpm_data = bpms.bpm_data;
            bpm_num=1:length(bpm_idx);
            
            % Determine selected pulse num
            pulse_num=round(app.PulseSlider.Value);
            pulse_data=bpm_data(:,pulse_num);
            active_bpms = ~isnan(pulse_data);
            hold(app.UIAxes,'off')
            app.orbitPlot = plot(app.UIAxes,bpm_num(active_bpms),pulse_data(active_bpms),'-');
            hold(app.UIAxes)
            app.orbitPlot_2 = plot(app.UIAxes,bpm_num(active_bpms),pulse_data(active_bpms), '*');
            app.UIAxes.YLabel.String = bpms.label;
            
            % Determine what sort of time stamp is available. This accounts
            % for different BSA data formats over the years. All new BSA
            % files should have a full time_stamps array
            try
               ts = app.orbit_mdl.time_stamps(pulse_num);
            catch
               ts = app.orbit_mdl.t_stamp;
            end
            try
                ts = datetime(ts, 'ConvertFrom', 'posixtime');
                app.UIAxes.Title.String = strcat('Orbit - ', string(ts));
            catch
                % If no time stamp is available, set the plot title to the
                % name of the loaded file
                s = app.BG_mdl.fileName;
                app.UIAxes.Title.String = ['Orbit - ', s(10:length(s)-4)];
            end
            
            dt=app.orbitPlot_2.DataTipTemplate;
            dt.DataTipRows(1).Value = bpm_names(active_bpms);
            dt.DataTipRows(1).Label = '';
            lim = max(abs(bpm_data),[],'all');
            if strcmp(bpms.label,'TMIT') % TMIT limits and labels different than X/Y
                dt.DataTipRows(2).Label = 'TMIT';
                app.UIAxes.YLim = [0,lim];
            else
                dt.DataTipRows(2).Label='Pos: ';
                app.UIAxes.YLim = [-10,10];
            end
            
            drawnow();
        end
        
        function update_orbit(app)
            % Update the orbit plot with the new pulse value. This is
            % called when there is no change in beam line or plot variable,
            % only the pulse num
            
            % Get data for current coordinate
            bpms = app.orbit_mdl.(app.current_coor);
            bpm_data = bpms.bpm_data;
            %bpm_idx = bpms.bpm_idx;
            %bpm_names = bpms.bpm_names;
            bpm_num=1:size(bpm_data,1);
            
            % Determine pulse num based on slider value
            pulse_num = round(app.PulseSlider.Value);
            pulse_data = bpm_data(:,pulse_num);
            active_bpms = ~isnan(pulse_data);
            
            % Same as in 'plot_orbit' function, some gymnastics required
            % for the different BSA file formats of versions past
            try
                ts = app.orbit_mdl.time_stamps(pulse_num);
            catch
                ts = app.orbit_mdl.t_stamp;
            end
            try
                ts = datetime(ts, 'ConvertFrom', 'posixtime');
                if isempty(ts)
                    s = app.BG_mdl.fileName;
                    title_string = ['Orbit - ', s(10:length(s)-4)];
                else
                    title_string = strcat('Orbit - ', string(ts));
                end
                app.UIAxes.Title.String = title_string;
            catch 
            end
            
            % update the values for the plot
            app.orbitPlot.XData = bpm_num(active_bpms);
            app.orbitPlot_2.XData = bpm_num(active_bpms);
            app.orbitPlot.YData = pulse_data(active_bpms);
            app.orbitPlot_2.YData = pulse_data(active_bpms);
            drawnow();
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, BG_mdl)
            app.BG_mdl = BG_mdl;
            app.orbit_mdl = BSA_GUI_orbitmodel(app, app.BG_mdl);
            
            app.plotOrbitListener = addlistener(app.orbit_mdl, 'plotOrbit', @(~,~)app.plot_orbit);
            app.processBPMSListener = addlistener(app.orbit_mdl, 'processBPMS', @(~,~)app.process_bpms);
            
            orbitInit(app.orbit_mdl);
            
            % check if BR eDef, if so make the toggle button visible
            app.BeamLine.Visible = app.BG_mdl.isBR & ~strcmp(app.BG_mdl.sys, 'SYS1');
            
            
        end

        % Selection changed function: ButtonGroup
        function ButtonGroupSelectionChanged(app, event)
            try
                plot_orbit(app);
            catch ex
                errorMessage(app, ex, 'Error plotting orbit');
            end
        end

        % Value changed function: PulseSlider
        function PulseSliderValueChanged(app, event)
            old_pulse = app.PulseNumEditField.Value;
            try
                app.PulseNumEditField.Value = round(app.PulseSlider.Value); % slider values are continuous
                update_orbit(app) % change plot to new pulse
            catch ex
                errorMessage(app, ex, 'Error changing pulse.')
                app.PulseSlider.Value = old_pulse;
                app.PulseNumEditField.Value = old_pulse;
            end
        end

        % Value changed function: PulseNumEditField
        function PulseNumEditFieldValueChanged(app, event)
            old_pulse = app.PulseSlider.Value;
            try
                app.PulseSlider.Value = app.PulseNumEditField.Value;
                update_orbit(app) % change plot to new pulse
            catch ex
                errorMessage(app, ex, 'Error changing pulse.')
                app.PulseSlider.Value = old_pulse;
                app.PulseNumEditField.Value = old_pulse;
            end
        end

        % Button pushed function: NextPulse
        function NextPulseButtonPushed(app, event)
            % when play button is hselectedit, the next button becomes the increase
            % rate button
            try
                if app.play
                    app.orbit_mdl.play_rate = app.orbit_mdl.play_rate - app.orbit_mdl.play_rate/10; % arbitrary rate change per button selection
                    return
                end
            catch ex
                errorMessage(app, ex, 'Error increasing play rate.');
            end
            
            next_pulse = app.PulseNumEditField.Value + 1;
            
            % ensure next pulse is still within limits, update slider and
            % edit field, plot the new orbit
            try
                if next_pulse <= app.PulseNumEditField.Limits(2)
                    app.PulseNumEditField.Value = next_pulse;
                    app.PulseSlider.Value = next_pulse;
                    update_orbit(app);
                end
            catch ex
                errorMessage(app, ex, 'Error incrementing pulse.')
                app.PulseNumEditField.Value = next_pulse - 1;
                app.PulseSlider.Value = next_pulse - 1;
            end
        end

        % Button pushed function: LastPulse
        function LastPulseButtonPushed(app, event)
            % when play button is selected, the last button becomes the
            % decrease rate button
            try
                if app.play
                    app.orbit_mdl.play_rate = app.orbit_mdl.play_rate + app.orbit_mdl.play_rate/10; % arbitrary rate change per button selection
                    return
                end
            catch ex
                errorMessage(app, ex, 'Error decreasing play rate.');
            end
            
            last_pulse = app.PulseNumEditField.Value - 1;
            
            % ensure next pulse is still within limits, update slider and
            % edit field, plot the new orbit
            try
                if last_pulse >= app.PulseNumEditField.Limits(1)
                    app.PulseNumEditField.Value = last_pulse;
                    app.PulseSlider.Value = last_pulse;
                    update_orbit(app);
                end
            catch ex
                errorMessage(app, ex, 'Error decrementing pulse.')
                app.PulseNumEditField.Value = last_pulse + 1;
                app.PulseSlider.Value = last_pulse + 1;
            end
        end

        % Button pushed function: Play
        function PlayButtonPushed(app, event)
            % execute 'play' of orbit over time
            app.play=1;
            
            % change 'Next' and 'Last' buttons to 'Faster' and 'Slower'
            app.NextPulse.Text = 'Faster';
            app.LastPulse.Text = 'Slower';
            
            % While still within limits, update the plot to the next pulse 
            try
                while app.play
                    update_orbit(app)
                    drawnow limitrate;
                    pause(app.orbit_mdl.play_rate) % modulate rate at which next orbit is plotted
                    pulse = app.PulseNumEditField.Value;
                    if pulse == app.PulseSlider.Limits(2)
                        app.play = 0;
                        break
                    end
                    app.PulseNumEditField.Value = pulse + 1;
                    app.PulseSlider.Value = pulse + 1;
                end
            catch ex
                errorMessage(app, ex, 'Error displaying orbit time series.');
            end
            
            % reset buttons
            app.NextPulse.Text = '+';
            app.LastPulse.Text = '-';
        end

        % Button pushed function: Pause
        function PauseButtonPushed(app, event)
            app.play = 0;
        end

        % Selection changed function: BeamLine
        function BeamLineSelectionChanged(app, event)
            % Check what the beam line is being changed to, cache the pulse
            % num last examined on the previous line
            beamLine = app.BeamLine.SelectedObject.Text;
            pulsenum = app.PulseNumEditField.Value;
            try
                beamLineChanged(app.orbit_mdl, beamLine, pulsenum);
            catch ex
                errorMessage(app, ex, 'Error changing beam line.');
            end
        end

        % Button pushed function: CloseButton
        function CloseButtonPushed(app, event)
            delete(app)
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create BPMOrbitUIFigure and hide until all components are created
            app.BPMOrbitUIFigure = uifigure('Visible', 'off');
            app.BPMOrbitUIFigure.Position = [100 100 822 565];
            app.BPMOrbitUIFigure.Name = 'BPM Orbit';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.BPMOrbitUIFigure);
            app.GridLayout.ColumnWidth = {'1x', '2x', '3x', '3x', '3x', '3x', '2x', 100};
            app.GridLayout.RowHeight = {'1x', '1x', '1.16x', 40, '0.25x', 27};
            app.GridLayout.ColumnSpacing = 4.28571428571429;
            app.GridLayout.RowSpacing = 10.4285714285714;
            app.GridLayout.Padding = [4.28571428571429 10.4285714285714 4.28571428571429 10.4285714285714];

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout);
            title(app.UIAxes, 'Orbit')
            xlabel(app.UIAxes, 'BPM  #')
            ylabel(app.UIAxes, '')
            app.UIAxes.FontSize = 14;
            app.UIAxes.Layout.Row = [1 3];
            app.UIAxes.Layout.Column = [1 7];

            % Create PulseSlider
            app.PulseSlider = uislider(app.GridLayout);
            app.PulseSlider.ValueChangedFcn = createCallbackFcn(app, @PulseSliderValueChanged, true);
            app.PulseSlider.Layout.Row = 4;
            app.PulseSlider.Layout.Column = [2 7];
            app.PulseSlider.Value = 1;

            % Create CloseButton
            app.CloseButton = uibutton(app.GridLayout, 'push');
            app.CloseButton.ButtonPushedFcn = createCallbackFcn(app, @CloseButtonPushed, true);
            app.CloseButton.FontSize = 16;
            app.CloseButton.Layout.Row = 6;
            app.CloseButton.Layout.Column = 8;
            app.CloseButton.Text = 'Close';

            % Create ButtonGroup
            app.ButtonGroup = uibuttongroup(app.GridLayout);
            app.ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ButtonGroupSelectionChanged, true);
            app.ButtonGroup.BorderType = 'none';
            app.ButtonGroup.BackgroundColor = [0.9412 0.9412 0.9412];
            app.ButtonGroup.Layout.Row = 2;
            app.ButtonGroup.Layout.Column = 8;

            % Create XButton
            app.XButton = uitogglebutton(app.ButtonGroup);
            app.XButton.Text = 'X';
            app.XButton.FontSize = 16;
            app.XButton.Position = [10 98 51 27];
            app.XButton.Value = true;

            % Create YButton
            app.YButton = uitogglebutton(app.ButtonGroup);
            app.YButton.Text = 'Y';
            app.YButton.FontSize = 16;
            app.YButton.Position = [10 71 51 27];

            % Create TMITButton
            app.TMITButton = uitogglebutton(app.ButtonGroup);
            app.TMITButton.Text = 'TMIT';
            app.TMITButton.FontSize = 16;
            app.TMITButton.Position = [10 45 51 27];

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.Layout.Row = 1;
            app.GridLayout2.Layout.Column = 2;

            % Create PulseNumEditFieldLabel
            app.PulseNumEditFieldLabel = uilabel(app.GridLayout);
            app.PulseNumEditFieldLabel.HorizontalAlignment = 'right';
            app.PulseNumEditFieldLabel.FontSize = 16;
            app.PulseNumEditFieldLabel.Layout.Row = 5;
            app.PulseNumEditFieldLabel.Layout.Column = 4;
            app.PulseNumEditFieldLabel.Text = 'Pulse Num:';

            % Create PulseNumEditField
            app.PulseNumEditField = uieditfield(app.GridLayout, 'numeric');
            app.PulseNumEditField.ValueChangedFcn = createCallbackFcn(app, @PulseNumEditFieldValueChanged, true);
            app.PulseNumEditField.HorizontalAlignment = 'left';
            app.PulseNumEditField.FontSize = 16;
            app.PulseNumEditField.Layout.Row = 5;
            app.PulseNumEditField.Layout.Column = 5;
            app.PulseNumEditField.Value = 1;

            % Create NextPulse
            app.NextPulse = uibutton(app.GridLayout, 'push');
            app.NextPulse.ButtonPushedFcn = createCallbackFcn(app, @NextPulseButtonPushed, true);
            app.NextPulse.FontSize = 16;
            app.NextPulse.FontWeight = 'bold';
            app.NextPulse.Layout.Row = 6;
            app.NextPulse.Layout.Column = 5;
            app.NextPulse.Text = '+';

            % Create LastPulse
            app.LastPulse = uibutton(app.GridLayout, 'push');
            app.LastPulse.ButtonPushedFcn = createCallbackFcn(app, @LastPulseButtonPushed, true);
            app.LastPulse.FontSize = 16;
            app.LastPulse.FontWeight = 'bold';
            app.LastPulse.Layout.Row = 6;
            app.LastPulse.Layout.Column = 4;
            app.LastPulse.Text = '-';

            % Create Play
            app.Play = uibutton(app.GridLayout, 'push');
            app.Play.ButtonPushedFcn = createCallbackFcn(app, @PlayButtonPushed, true);
            app.Play.FontSize = 16;
            app.Play.FontWeight = 'bold';
            app.Play.Layout.Row = 6;
            app.Play.Layout.Column = 6;
            app.Play.Text = 'Play';

            % Create Pause
            app.Pause = uibutton(app.GridLayout, 'push');
            app.Pause.ButtonPushedFcn = createCallbackFcn(app, @PauseButtonPushed, true);
            app.Pause.FontSize = 16;
            app.Pause.FontWeight = 'bold';
            app.Pause.Layout.Row = 6;
            app.Pause.Layout.Column = 3;
            app.Pause.Text = 'Pause';

            % Create BeamLine
            app.BeamLine = uibuttongroup(app.GridLayout);
            app.BeamLine.SelectionChangedFcn = createCallbackFcn(app, @BeamLineSelectionChanged, true);
            app.BeamLine.BorderType = 'none';
            app.BeamLine.Visible = 'off';
            app.BeamLine.Layout.Row = 1;
            app.BeamLine.Layout.Column = 8;
            app.BeamLine.FontSize = 16;

            % Create HXRButton
            app.HXRButton = uiradiobutton(app.BeamLine);
            app.HXRButton.Text = 'HXR';
            app.HXRButton.FontSize = 16;
            app.HXRButton.Position = [11 34 58 22];
            app.HXRButton.Value = true;

            % Create SXRButton
            app.SXRButton = uiradiobutton(app.BeamLine);
            app.SXRButton.Text = 'SXR';
            app.SXRButton.FontSize = 16;
            app.SXRButton.Position = [11 14 65 22];

            % Show the figure after all components are created
            app.BPMOrbitUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = BPM_Orbit_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.BPMOrbitUIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.BPMOrbitUIFigure)
        end
    end
end