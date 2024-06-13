classdef F2_UVVisSpec_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        UIAxes                         matlab.ui.control.UIAxes
        UIAxes2                        matlab.ui.control.UIAxes
        StartButton                    matlab.ui.control.Button
        StopButton                     matlab.ui.control.Button
        TriggerModeDropDownLabel       matlab.ui.control.Label
        TriggerModeDropDown            matlab.ui.control.DropDown
        IntegrationTimemsEditFieldLabel  matlab.ui.control.Label
        IntegrationTimemsEditField     matlab.ui.control.NumericEditField
        ScaleYAxisCheckBox             matlab.ui.control.CheckBox
        YminEditFieldLabel             matlab.ui.control.Label
        YminEditField                  matlab.ui.control.NumericEditField
        YmaxEditFieldLabel             matlab.ui.control.Label
        YmaxEditField                  matlab.ui.control.NumericEditField
        UpdateTimesEditFieldLabel      matlab.ui.control.Label
        UpdateTimesEditField           matlab.ui.control.NumericEditField
        PrinttoelogButton              matlab.ui.control.Button
        NumShotsEditFieldLabel         matlab.ui.control.Label
        NumShotsEditField              matlab.ui.control.EditField
        ScaleYAxisCheckBox_2           matlab.ui.control.CheckBox
        YminEditField_2Label           matlab.ui.control.Label
        YminEditField_2                matlab.ui.control.NumericEditField
        YmaxEditField_2Label           matlab.ui.control.Label
        YmaxEditField_2                matlab.ui.control.NumericEditField
        UseCalibrationCheckBox         matlab.ui.control.CheckBox
        EDCMirrorUTSStagePositionmmOUT150IN41Label  matlab.ui.control.Label
        EDCMirrorUTSStagePositionmmOUT150IN41EditField  matlab.ui.control.NumericEditField
        NDfilterSwitchLabel            matlab.ui.control.Label
        NDfilterSwitch                 matlab.ui.control.ToggleSwitch
        SubtractBkgrCheckBox           matlab.ui.control.CheckBox
        EnergyMeterFlipperOFFINSwitchLabel  matlab.ui.control.Label
        EnergyMeterFlipperOFFINSwitch  matlab.ui.control.ToggleSwitch
    end

    
    properties (Access = public)
        
        Running (1,1) logical {mustBeScalarOrEmpty} = false
        Data = [];
        spectrometerpv = 'SPEC:LI20:EX01:Spectrum';        
        triggerMode = 'SPEC:LI20:EX01:TrigModeSet';
        wavelengths = 'SPEC:LI20:EX01:Wavelengths';
        integrationTime = 'SPEC:LI20:EX01:IntTimeSet';
        updateTime = 'SPEC:LI20:EX01:UpdateTimeSet';
        spectrometerCalibrationFile = 'theoreticalResponseInterp.mat';
        edcutsstagepv = 'XPS:LI20:MC03:M2';
        ndfilterpv = 'APC:LI20:EX02:5VOUT_12';
        energymeterflipperpv = 'APC:LI20:EX02:5VOUT_11'
        spectrumNoiseFloor = [];
    end
    
    methods (Access = private)
        
        function updateEditFiledValues(app)
            app.IntegrationTimemsEditField.Value = lcaGet(app.integrationTime);
            app.UpdateTimesEditField.Value = lcaGet(app.updateTime);
            app.NDfilterSwitch.Value = lcaGet(app.ndfilterpv);
            app.EnergyMeterFlipperOFFINSwitch.Value = lcaGet(app.energymeterflipperpv);
        end
    end
 

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.EDCMirrorUTSStagePositionmmOUT150IN41EditField.Value = ...
                lcaGet(app.edcutsstagepv);
            app.updateEditFiledValues();
            app.spectrumNoiseFloor = 1500; % Empirical value
            
        end

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
            
            % Clear Plot Axes           
            cla(app.UIAxes)
            cla(app.UIAxes2)
            
            % Grab spectrometerCalibration
            spectrometerCalibration = importdata(app.spectrometerCalibrationFile);
            
            % Initialize loop
            app.Running = true;
            specWavelengths = lcaGet(app.wavelengths);
            data = lcaGet(app.spectrometerpv);
            
            % Plot the spectrum and set plot parameters
            plot(app.UIAxes,specWavelengths,data,'k','LineWidth',2);
            xlabel(app.UIAxes,'Wavelength [nm]');
            ylabel(app.UIAxes,'Intensity [a. u.]')
            set(app.UIAxes,'FontSize',18,'LineWidth',2,...
                'XLim',[min(specWavelengths),max(specWavelengths)]);
            set(app.UIAxes2,'FontSize',16,'LineWidth',2)
            
            % Preallocate arrays
            shotNum = 0;

            while app.Running

                % Get New Spectrometer Data
                newData = lcaGet(app.spectrometerpv);
                app.Data = newData;

               % Subtract background and/or use calibration
               if app.SubtractBkgrCheckBox.Value
                   newData = newData-app.spectrumNoiseFloor;
               end
                               
               if app.UseCalibrationCheckBox.Value
                   newData = (newData)./spectrometerCalibration;
               end
               
               % Update the integrated spectrum 

                % Update the integrated spectrum
                if shotNum < 150%app.NumShotsEditField.Value - app will not get the value from this field so assign it manually
                    % Update shot Number
                    shotNum = shotNum + 1;
                    timestamp(shotNum) = now;
                    integratedSpectrum(shotNum) = trapz(newData); 
                else
                    timestamp = circshift(timestamp,-1);
                    timestamp(end) = now;
                    integratedSpectrum = circshift(integratedSpectrum,-1);
                    integratedSpectrum(end) = trapz(newData); 
                end
 
                % Plot new spectrum
                plot(app.UIAxes, specWavelengths,newData,'k');
                
                % Update the integrated Spectral Plot
                ticks = linspace(timestamp(1), now, 4);
                labels = datestr(ticks, 'HH:MM');
 
                plot(app.UIAxes2, timestamp,integratedSpectrum*1e-6,'-*')
                set(app.UIAxes2,'xtick',ticks,'xticklabel',labels);
                set(app.UIAxes2,'xlim',[timestamp(1),now])
                drawnow
                
                % Update edit field values in case they were changed
                % outside the GUI
                app.updateEditFiledValues();
                
            end
        end

        % Button pushed function: StopButton
        function StopButtonPushed(app, event)
            app.Running = false;
        end

        % Value changed function: TriggerModeDropDown
        function TriggerModeDropDownValueChanged(app, event)
            value = app.TriggerModeDropDown.Value;
            lcaPut(app.triggerMode,value);
        end

        % Value changed function: IntegrationTimemsEditField
        function IntegrationTimemsEditFieldValueChanged(app, event)
            value = app.IntegrationTimemsEditField.Value;
            lcaPut(app.integrationTime,value);
        end

        % Value changed function: ScaleYAxisCheckBox
        function ScaleYAxisCheckBoxValueChanged(app, event)
            value = app.ScaleYAxisCheckBox.Value;
            if value
                try
                app.UIAxes.YLim = [app.YminEditField.Value app.YmaxEditField.Value];
                catch
                    warning('Invald Y axis limits');
                end
            else
                app.UIAxes.YLim = [min(app.Data) max(app.Data)];
            end
        end

        % Value changed function: YmaxEditField
        function YmaxEditFieldValueChanged(app, event)
            value = app.YmaxEditField.Value;
            
        end

        % Value changed function: YminEditField
        function YminEditFieldValueChanged(app, event)
            value = app.YminEditField.Value;
            
        end

        % Value changed function: ScaleYAxisCheckBox_2
        function ScaleYAxisCheckBox_2ValueChanged(app, event)
            value = app.ScaleYAxisCheckBox_2.Value;
             if value
                try
                app.UIAxes2.YLim = [app.YminEditField_2.Value app.YmaxEditField_2.Value];
                catch
                    warning('Invald Y axis limits');
                end
            else
                app.UIAxes.YLim = [min(app.Data) max(app.Data)];
            end
        end

        % Value changed function: YminEditField_2
        function YminEditField_2ValueChanged(app, event)
            value = app.YminEditField_2.Value;
            
        end

        % Value changed function: NumShotsEditField
        function NumShotsEditFieldValueChanged(app, event)
            value = app.NumShotsEditField.Value;
            
        end

        % Value changed function: UseCalibrationCheckBox
        function UseCalibrationCheckBoxValueChanged(app, event)
            value = app.UseCalibrationCheckBox.Value;
            
        end

        % Value changed function: 
        % EDCMirrorUTSStagePositionmmOUT150IN41EditField
        function EDCMirrorUTSStagePositionmmOUT150IN41EditFieldValueChanged(app, event)
            value = app.EDCMirrorUTSStagePositionmmOUT150IN41EditField.Value;
            lcaPut(app.edcutsstagepv,value)
        end

        % Button pushed function: PrinttoelogButton
        function PrinttoelogButtonPushed(app, event)
            fh = figure(102);
            newAx = axes;
          
            copyobj(app.UIAxes.Children, newAx);         
            xlabel(newAx,'Wavelength [nm]');
            ylabel(newAx,'Intensity [a. u.]')
            titlestr = sprintf(['UV Vis Spectrometer, ',datestr(now)]);
            title(newAx, titlestr);
            
            %             Print the figure to the logbook           
            %print(fh, '-dpsc2', ['-P','physics-facetlog']);
            util_printLog(fh,'title','EDC UV Vis Spectrum',...
            'author','F2_UVVisSpec');
            close(fh)
            
            % Save spectrum to FACET matlab data directory
            dataToSave = app.Data;
            
            pth = ['/u1/facet/matlab/data/',datestr(now,'yyyy'),'/',...
                datestr(now,'yyyy-mm'),'/',datestr(now,'yyyy-mm-dd'),'/'];
            
            save(strcat(pth,'EDCUVVisSpectrum_',datestr(now,'HH:MM:SS')),'dataToSave');

        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            app.Running = false;
            delete(app)
            exit
        end

        % Value changed function: NDfilterSwitch
        function NDfilterSwitchValueChanged(app, event)
            value = app.NDfilterSwitch.Value;
            lcaPut(app.ndfilterpv,value);   
        end

        % Value changed function: EnergyMeterFlipperOFFINSwitch
        function EnergyMeterFlipperOFFINSwitchValueChanged(app, event)
            value = app.EnergyMeterFlipperOFFINSwitch.Value;
            lcaPut(app.energymeterflipperpv,value); 
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 871 615];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'UV Vis Spectrum')
            xlabel(app.UIAxes, 'Wavelength [nm]')
            ylabel(app.UIAxes, 'Intensity [a.u.]')
            app.UIAxes.Box = 'on';
            app.UIAxes.Position = [243 231 612 385];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.UIFigure);
            title(app.UIAxes2, 'Integrated Spectral Counts')
            xlabel(app.UIAxes2, 'Time')
            ylabel(app.UIAxes2, 'Cts')
            app.UIAxes2.Box = 'on';
            app.UIAxes2.Position = [243 1 613 211];

            % Create StartButton
            app.StartButton = uibutton(app.UIFigure, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.BackgroundColor = [0.4667 0.6745 0.1882];
            app.StartButton.FontSize = 14;
            app.StartButton.FontWeight = 'bold';
            app.StartButton.Position = [42 566 120 32];
            app.StartButton.Text = 'Start';

            % Create StopButton
            app.StopButton = uibutton(app.UIFigure, 'push');
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);
            app.StopButton.BackgroundColor = [0.851 0.3255 0.098];
            app.StopButton.FontSize = 14;
            app.StopButton.FontWeight = 'bold';
            app.StopButton.Position = [43 518 120 32];
            app.StopButton.Text = 'Stop';

            % Create TriggerModeDropDownLabel
            app.TriggerModeDropDownLabel = uilabel(app.UIFigure);
            app.TriggerModeDropDownLabel.HorizontalAlignment = 'right';
            app.TriggerModeDropDownLabel.Position = [29 477 76 22];
            app.TriggerModeDropDownLabel.Text = 'Trigger Mode';

            % Create TriggerModeDropDown
            app.TriggerModeDropDown = uidropdown(app.UIFigure);
            app.TriggerModeDropDown.Items = {'External', 'Software'};
            app.TriggerModeDropDown.ValueChangedFcn = createCallbackFcn(app, @TriggerModeDropDownValueChanged, true);
            app.TriggerModeDropDown.Position = [120 477 83 22];
            app.TriggerModeDropDown.Value = 'External';

            % Create IntegrationTimemsEditFieldLabel
            app.IntegrationTimemsEditFieldLabel = uilabel(app.UIFigure);
            app.IntegrationTimemsEditFieldLabel.HorizontalAlignment = 'right';
            app.IntegrationTimemsEditFieldLabel.Position = [20 381 118 22];
            app.IntegrationTimemsEditFieldLabel.Text = 'Integration Time [ms]';

            % Create IntegrationTimemsEditField
            app.IntegrationTimemsEditField = uieditfield(app.UIFigure, 'numeric');
            app.IntegrationTimemsEditField.ValueChangedFcn = createCallbackFcn(app, @IntegrationTimemsEditFieldValueChanged, true);
            app.IntegrationTimemsEditField.Position = [145 381 56 22];
            app.IntegrationTimemsEditField.Value = 10;

            % Create ScaleYAxisCheckBox
            app.ScaleYAxisCheckBox = uicheckbox(app.UIFigure);
            app.ScaleYAxisCheckBox.ValueChangedFcn = createCallbackFcn(app, @ScaleYAxisCheckBoxValueChanged, true);
            app.ScaleYAxisCheckBox.Text = 'Scale Y Axis';
            app.ScaleYAxisCheckBox.Position = [16 297 89 22];

            % Create YminEditFieldLabel
            app.YminEditFieldLabel = uilabel(app.UIFigure);
            app.YminEditFieldLabel.HorizontalAlignment = 'right';
            app.YminEditFieldLabel.Position = [16 269 33 22];
            app.YminEditFieldLabel.Text = 'Ymin';

            % Create YminEditField
            app.YminEditField = uieditfield(app.UIFigure, 'numeric');
            app.YminEditField.ValueChangedFcn = createCallbackFcn(app, @YminEditFieldValueChanged, true);
            app.YminEditField.Position = [52 269 59 22];
            app.YminEditField.Value = 1400;

            % Create YmaxEditFieldLabel
            app.YmaxEditFieldLabel = uilabel(app.UIFigure);
            app.YmaxEditFieldLabel.HorizontalAlignment = 'right';
            app.YmaxEditFieldLabel.Position = [119 269 36 22];
            app.YmaxEditFieldLabel.Text = 'Ymax';

            % Create YmaxEditField
            app.YmaxEditField = uieditfield(app.UIFigure, 'numeric');
            app.YmaxEditField.ValueChangedFcn = createCallbackFcn(app, @YmaxEditFieldValueChanged, true);
            app.YmaxEditField.Position = [158 269 68 22];
            app.YmaxEditField.Value = 17000;

            % Create UpdateTimesEditFieldLabel
            app.UpdateTimesEditFieldLabel = uilabel(app.UIFigure);
            app.UpdateTimesEditFieldLabel.HorizontalAlignment = 'right';
            app.UpdateTimesEditFieldLabel.Position = [20 351 90 22];
            app.UpdateTimesEditFieldLabel.Text = 'Update Time [s]';

            % Create UpdateTimesEditField
            app.UpdateTimesEditField = uieditfield(app.UIFigure, 'numeric');
            app.UpdateTimesEditField.Position = [141 351 57 22];
            app.UpdateTimesEditField.Value = 0.1;

            % Create PrinttoelogButton
            app.PrinttoelogButton = uibutton(app.UIFigure, 'push');
            app.PrinttoelogButton.ButtonPushedFcn = createCallbackFcn(app, @PrinttoelogButtonPushed, true);
            app.PrinttoelogButton.BackgroundColor = [0.0745 0.6235 1];
            app.PrinttoelogButton.FontSize = 14;
            app.PrinttoelogButton.FontWeight = 'bold';
            app.PrinttoelogButton.Position = [42 30 120 32];
            app.PrinttoelogButton.Text = 'Print to elog';

            % Create NumShotsEditFieldLabel
            app.NumShotsEditFieldLabel = uilabel(app.UIFigure);
            app.NumShotsEditFieldLabel.HorizontalAlignment = 'right';
            app.NumShotsEditFieldLabel.Enable = 'off';
            app.NumShotsEditFieldLabel.Position = [0 188 65 22];
            app.NumShotsEditFieldLabel.Text = 'Num Shots';

            % Create NumShotsEditField
            app.NumShotsEditField = uieditfield(app.UIFigure, 'text');
            app.NumShotsEditField.ValueChangedFcn = createCallbackFcn(app, @NumShotsEditFieldValueChanged, true);
            app.NumShotsEditField.Editable = 'off';
            app.NumShotsEditField.Enable = 'off';
            app.NumShotsEditField.Position = [72 190 45 22];
            app.NumShotsEditField.Value = '100';

            % Create ScaleYAxisCheckBox_2
            app.ScaleYAxisCheckBox_2 = uicheckbox(app.UIFigure);
            app.ScaleYAxisCheckBox_2.ValueChangedFcn = createCallbackFcn(app, @ScaleYAxisCheckBox_2ValueChanged, true);
            app.ScaleYAxisCheckBox_2.Text = 'Scale Y Axis';
            app.ScaleYAxisCheckBox_2.Position = [14 90 89 22];

            % Create YminEditField_2Label
            app.YminEditField_2Label = uilabel(app.UIFigure);
            app.YminEditField_2Label.HorizontalAlignment = 'right';
            app.YminEditField_2Label.Position = [3 158 33 22];
            app.YminEditField_2Label.Text = 'Ymin';

            % Create YminEditField_2
            app.YminEditField_2 = uieditfield(app.UIFigure, 'numeric');
            app.YminEditField_2.ValueChangedFcn = createCallbackFcn(app, @YminEditField_2ValueChanged, true);
            app.YminEditField_2.Position = [44 158 38 22];

            % Create YmaxEditField_2Label
            app.YmaxEditField_2Label = uilabel(app.UIFigure);
            app.YmaxEditField_2Label.HorizontalAlignment = 'right';
            app.YmaxEditField_2Label.Position = [4 126 36 22];
            app.YmaxEditField_2Label.Text = 'Ymax';

            % Create YmaxEditField_2
            app.YmaxEditField_2 = uieditfield(app.UIFigure, 'numeric');
            app.YmaxEditField_2.Position = [44 126 38 22];
            app.YmaxEditField_2.Value = 2;

            % Create UseCalibrationCheckBox
            app.UseCalibrationCheckBox = uicheckbox(app.UIFigure);
            app.UseCalibrationCheckBox.ValueChangedFcn = createCallbackFcn(app, @UseCalibrationCheckBoxValueChanged, true);
            app.UseCalibrationCheckBox.Text = 'Use Calibration';
            app.UseCalibrationCheckBox.Position = [16 324 104 22];

            % Create EDCMirrorUTSStagePositionmmOUT150IN41Label
            app.EDCMirrorUTSStagePositionmmOUT150IN41Label = uilabel(app.UIFigure);
            app.EDCMirrorUTSStagePositionmmOUT150IN41Label.HorizontalAlignment = 'right';
            app.EDCMirrorUTSStagePositionmmOUT150IN41Label.Position = [20 402 120 65];
            app.EDCMirrorUTSStagePositionmmOUT150IN41Label.Text = {'EDC Mirror UTS'; 'Stage Position [mm]'; 'OUT = 150, IN = 41'};

            % Create EDCMirrorUTSStagePositionmmOUT150IN41EditField
            app.EDCMirrorUTSStagePositionmmOUT150IN41EditField = uieditfield(app.UIFigure, 'numeric');
            app.EDCMirrorUTSStagePositionmmOUT150IN41EditField.ValueChangedFcn = createCallbackFcn(app, @EDCMirrorUTSStagePositionmmOUT150IN41EditFieldValueChanged, true);
            app.EDCMirrorUTSStagePositionmmOUT150IN41EditField.Position = [152 423 46 22];

            % Create NDfilterSwitchLabel
            app.NDfilterSwitchLabel = uilabel(app.UIFigure);
            app.NDfilterSwitchLabel.HorizontalAlignment = 'center';
            app.NDfilterSwitchLabel.Position = [197 89 49 22];
            app.NDfilterSwitchLabel.Text = 'ND filter';

            % Create NDfilterSwitch
            app.NDfilterSwitch = uiswitch(app.UIFigure, 'toggle');
            app.NDfilterSwitch.Items = {'OFF', 'ON'};
            app.NDfilterSwitch.ValueChangedFcn = createCallbackFcn(app, @NDfilterSwitchValueChanged, true);
            app.NDfilterSwitch.Position = [211 147 20 45];
            app.NDfilterSwitch.Value = 'OFF';

            % Create SubtractBkgrCheckBox
            app.SubtractBkgrCheckBox = uicheckbox(app.UIFigure);
            app.SubtractBkgrCheckBox.Text = {'Subtract Bkgr'; ''};
            app.SubtractBkgrCheckBox.Position = [125 324 95 22];

            % Create EnergyMeterFlipperOFFINSwitchLabel
            app.EnergyMeterFlipperOFFINSwitchLabel = uilabel(app.UIFigure);
            app.EnergyMeterFlipperOFFINSwitchLabel.HorizontalAlignment = 'center';
            app.EnergyMeterFlipperOFFINSwitchLabel.Position = [121 70 81 42];
            app.EnergyMeterFlipperOFFINSwitchLabel.Text = {'Energy Meter '; 'Flipper'; 'OFF = IN'};

            % Create EnergyMeterFlipperOFFINSwitch
            app.EnergyMeterFlipperOFFINSwitch = uiswitch(app.UIFigure, 'toggle');
            app.EnergyMeterFlipperOFFINSwitch.Items = {'OFF', 'ON'};
            app.EnergyMeterFlipperOFFINSwitch.ValueChangedFcn = createCallbackFcn(app, @EnergyMeterFlipperOFFINSwitchValueChanged, true);
            app.EnergyMeterFlipperOFFINSwitch.Position = [151 148 20 45];
            app.EnergyMeterFlipperOFFINSwitch.Value = 'OFF';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_UVVisSpec_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

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