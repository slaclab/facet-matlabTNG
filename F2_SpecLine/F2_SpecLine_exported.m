classdef F2_SpecLine_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        SpecLineGUIUIFigure          matlab.ui.Figure
        SpectrometerParametersPanel  matlab.ui.container.Panel
        EnergyGeVEditFieldLabel      matlab.ui.control.Label
        EnergyEditField              matlab.ui.control.NumericEditField
        ZObjectmEditFieldLabel       matlab.ui.control.Label
        ZObjectEditField             matlab.ui.control.NumericEditField
        ZImagemEditFieldLabel        matlab.ui.control.Label
        ZImageEditField              matlab.ui.control.NumericEditField
        M12EditFieldLabel            matlab.ui.control.Label
        M12EditField                 matlab.ui.control.NumericEditField
        M34EditFieldLabel            matlab.ui.control.Label
        M34EditField                 matlab.ui.control.NumericEditField
        CalcButton                   matlab.ui.control.Button
        DipoleSwitchLabel            matlab.ui.control.Label
        DipoleSwitch                 matlab.ui.control.Switch
        ZobDropDown                  matlab.ui.control.DropDown
        ZimDropDown                  matlab.ui.control.DropDown
        MagnetValuesPanel            matlab.ui.container.Panel
        Q0DLGPS3141EditFieldLabel    matlab.ui.control.Label
        Q0DBDESEditField             matlab.ui.control.NumericEditField
        Q0DBACTField                 matlab.ui.control.NumericEditField
        BDESLabel                    matlab.ui.control.Label
        BACTLabel                    matlab.ui.control.Label
        Q1DLGPS3261EditFieldLabel    matlab.ui.control.Label
        Q1DBDESEditField             matlab.ui.control.NumericEditField
        Q1DBACTField                 matlab.ui.control.NumericEditField
        Q2DLGPS3091EditFieldLabel    matlab.ui.control.Label
        Q2DBDESEditField             matlab.ui.control.NumericEditField
        Q2DBACTField                 matlab.ui.control.NumericEditField
        TrimButton                   matlab.ui.control.Button
        B5DBACTField                 matlab.ui.control.NumericEditField
        B5DLGPS3330Label             matlab.ui.control.Label
        B5DBDESEditField             matlab.ui.control.NumericEditField
        BCALCLabel                   matlab.ui.control.Label
        Q0DBCALCEditField            matlab.ui.control.NumericEditField
        Q1DBCALCEditField            matlab.ui.control.NumericEditField
        Q2DBCALCEditField            matlab.ui.control.NumericEditField
        B5DBCALCEditField            matlab.ui.control.NumericEditField
        PrinttoELOGButton            matlab.ui.control.Button
        XCOR3276BACTField            matlab.ui.control.NumericEditField
        XCOR3276BDESEditField        matlab.ui.control.NumericEditField
        TrimCorrectorButton          matlab.ui.control.Button
        XCOR3276CheckBox             matlab.ui.control.CheckBox
        XCOR3276BCALCEditField       matlab.ui.control.Spinner
        LogPanel                     matlab.ui.container.Panel
        DisplayLogTextAreaLabel      matlab.ui.control.Label
        LogTextArea                  matlab.ui.control.TextArea
        ClearLogButton               matlab.ui.control.Button
    end

    
    properties (Access = private)
        aobj % Description
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.aobj=F2_SpecLineApp(app);
            if lcaGetSmart('SIOC:SYS1:ML00:CALCOUT056')
                app.DipoleSwitch.Value = 'With';
            else
                app.DipoleSwitch.Value = 'Without';
            end
            
            addpath('../');
            LucretiaInit('/usr/local/facet/tools/Lucretia');
            
        end

        % Button pushed function: CalcButton
        function CalcButtonPushed(app, event)
            app.aobj.Calc(app);
        end

        % Button pushed function: TrimButton
        function TrimButtonPushed(app, event)
             app.aobj.Trim(app);
             
             pause(5);
             PrinttoELOGButtonPushed(app);
        end

        % Button pushed function: TrimCorrectorButton
        function TrimCorrectorButtonPushed(app, event)
            app.aobj.TrimCorr(app);
        end

        % Value changed function: DipoleSwitch
        function DipoleSwitchValueChanged(app, event)
            if strcmp(app.DipoleSwitch.Value, 'With')
                lcaPutSmart('SIOC:SYS1:ML00:CALCOUT056', 1);
            else
                lcaPutSmart('SIOC:SYS1:ML00:CALCOUT056', 0);
            end
        end

        % Callback function
        function GetBACTButtonPushed(app, event)
            magnets={'LI20:LGPS:3141';'LI20:LGPS:3261';'LI20:LGPS:3091'; 'LGPS:LI20:3330'};
            BACT = control_magnetGet(magnets);
            app.Q0DBACTField.Value = BACT(1);
            app.Q1DBACTField.Value = BACT(2);
            app.Q2DBACTField.Value = BACT(3);
            app.B5DBACTField.Value = BACT(4);
        end

        % Value changed function: ZobDropDown
        function ZobDropDownValueChanged(app, event)
            value = app.ZobDropDown.Value;
            
            z = set_Z(app.aobj, app, 'ZobDropDown');
            lcaPutSmart('SIOC:SYS1:ML00:CALCOUT052', z);
        end

        % Value changed function: ZimDropDown
        function ZimDropDownValueChanged(app, event)
            value = app.ZimDropDown.Value;
            
            z = set_Z(app.aobj, app, 'ZimDropDown');
            lcaPutSmart('SIOC:SYS1:ML00:CALCOUT053', z);
        end

        % Button pushed function: ClearLogButton
        function ClearLogButtonPushed(app, event)
            app.LogTextArea.Value = {' '};
        end

        % Button pushed function: PrinttoELOGButton
        function PrinttoELOGButtonPushed(app, event)
            
            M = calc_TransportMatrix(app.aobj, app);
            
            Mtext = strcat(sprintf('\n\nTransport matrix from Zob to Zim at E = %0.2f\n', app.EnergyEditField.Value), ...
                           sprintf('\nM = [ % 05.4f   % 05.4f         0         0\n', M(1, 1:2)),...
                           sprintf('\n      % 05.4f   % 05.4f         0         0\n', M(2, 1:2)),...
                           sprintf('\n            0         0   % 05.4f   % 05.4f\n', M(3, 3:4)),...
                           sprintf('\n            0         0   % 05.4f   % 05.4f ]\n',M(4, 3:4)))
            
            % Make plot of Zob vs E           
            zob = 1992:0.1:1997;
            for i = 1:length(zob)
            E(i) = calc_ObjectPlaneE(app.aobj, app, zob(i));
            end
            
            fh = figure(199);
            clf(fh)
            plot(E, zob)
            xlabel('Energy [GeV]');
            ylabel('Object plane [m]');
            
            
            eles = {'PIC_CENT', 'FILS', 'PENT', 'PEXT', 'BEWIN2'};
            beamline = IPmap(app.aobj, app);
            xl = xlim;
            for i = 1:length(eles)
                indele = find(strcmp(beamline.name, eles{i}),1);
                if indele>0
                    z = beamline.z(indele);
                else
                    z=0;
                end
                text(xl(1), z, [' -' eles{i}], 'Interpreter', 'none');
                
            end
            grid on
            title(sprintf('Imaging to %s, z = %.2f m', app.ZimDropDown.Value, app.ZImageEditField.Value))
            
            set(fh,'Position', [1   1   650   307]);
            set(fh,'color','w');
            
            opts.text = strcat(sprintf('Spectrometer parameters:'), ...
                               app.aobj.elogtext, ...
                               sprintf('\nQ0D = %0.2f Q1D = %0.2f Q2D = %0.2f  B5D36 = %0.2f', app.Q0DBACTField.Value, app.Q1DBACTField.Value, app.Q2DBACTField.Value, app.B5DBACTField.Value), ...
                               Mtext)
            
                           
                           
            opts.title= 'Spectrometer Config Change';
            opts.author= 'F2_SpecLine.m';
            
            util_printLog(fh,opts);
            updateLog(app.aobj, app, 'Printed to FACET elog'); 
                
            close(fh);
            
        end

        % Value changed function: Q0DBCALCEditField
        function Q0DBCALCEditFieldValueChanged(app, event)
            value = app.Q0DBCALCEditField.Value;
            app.aobj.elogtext = sprintf('\n\nCustom spectrometer quad settings:');
        end

        % Value changed function: Q1DBCALCEditField
        function Q1DBCALCEditFieldValueChanged(app, event)
            value = app.Q1DBCALCEditField.Value;
            app.aobj.elogtext = sprintf('\n\nCustom spectrometer quad settings:');            
        end

        % Value changed function: Q2DBCALCEditField
        function Q2DBCALCEditFieldValueChanged(app, event)
            value = app.Q2DBCALCEditField.Value;
            app.aobj.elogtext = sprintf('\n\nCustom spectrometer quad settings:');            
        end

        % Value changed function: XCOR3276CheckBox
        function XCOR3276CheckBoxValueChanged(app, event)
            value = app.XCOR3276CheckBox.Value;
            
            if ~value
                app.XCOR3276BCALCEditField.Visible = 0;
                app.XCOR3276BDESEditField.Visible = 0;
                app.TrimCorrectorButton.Visible = 0;
            else
                app.XCOR3276BCALCEditField.Value = app.XCOR3276BACTField.Value;
                app.XCOR3276BCALCEditField.Visible = 1;
                app.XCOR3276BDESEditField.Visible = 1;
                app.TrimCorrectorButton.Visible = 1;
            end
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create SpecLineGUIUIFigure and hide until all components are created
            app.SpecLineGUIUIFigure = uifigure('Visible', 'off');
            app.SpecLineGUIUIFigure.Position = [100 100 927 352];
            app.SpecLineGUIUIFigure.Name = 'SpecLine GUI';

            % Create SpectrometerParametersPanel
            app.SpectrometerParametersPanel = uipanel(app.SpecLineGUIUIFigure);
            app.SpectrometerParametersPanel.Title = 'Spectrometer Parameters';
            app.SpectrometerParametersPanel.Position = [1 3 292 350];

            % Create EnergyGeVEditFieldLabel
            app.EnergyGeVEditFieldLabel = uilabel(app.SpectrometerParametersPanel);
            app.EnergyGeVEditFieldLabel.HorizontalAlignment = 'right';
            app.EnergyGeVEditFieldLabel.Position = [9 295 79 22];
            app.EnergyGeVEditFieldLabel.Text = 'Energy (GeV)';

            % Create EnergyEditField
            app.EnergyEditField = uieditfield(app.SpectrometerParametersPanel, 'numeric');
            app.EnergyEditField.ValueDisplayFormat = '%11.4f';
            app.EnergyEditField.Position = [100 295 73 22];

            % Create ZObjectmEditFieldLabel
            app.ZObjectmEditFieldLabel = uilabel(app.SpectrometerParametersPanel);
            app.ZObjectmEditFieldLabel.HorizontalAlignment = 'right';
            app.ZObjectmEditFieldLabel.Position = [17 260 71 22];
            app.ZObjectmEditFieldLabel.Text = 'Z Object (m)';

            % Create ZObjectEditField
            app.ZObjectEditField = uieditfield(app.SpectrometerParametersPanel, 'numeric');
            app.ZObjectEditField.ValueDisplayFormat = '%11.4f';
            app.ZObjectEditField.Position = [100 260 73 22];

            % Create ZImagemEditFieldLabel
            app.ZImagemEditFieldLabel = uilabel(app.SpectrometerParametersPanel);
            app.ZImagemEditFieldLabel.HorizontalAlignment = 'right';
            app.ZImagemEditFieldLabel.Position = [18 226 70 22];
            app.ZImagemEditFieldLabel.Text = 'Z Image (m)';

            % Create ZImageEditField
            app.ZImageEditField = uieditfield(app.SpectrometerParametersPanel, 'numeric');
            app.ZImageEditField.ValueDisplayFormat = '%11.4f';
            app.ZImageEditField.Position = [100 226 73 22];

            % Create M12EditFieldLabel
            app.M12EditFieldLabel = uilabel(app.SpectrometerParametersPanel);
            app.M12EditFieldLabel.HorizontalAlignment = 'right';
            app.M12EditFieldLabel.Position = [59 192 29 22];
            app.M12EditFieldLabel.Text = 'M12';

            % Create M12EditField
            app.M12EditField = uieditfield(app.SpectrometerParametersPanel, 'numeric');
            app.M12EditField.ValueDisplayFormat = '%11.4f';
            app.M12EditField.Position = [100 192 73 22];

            % Create M34EditFieldLabel
            app.M34EditFieldLabel = uilabel(app.SpectrometerParametersPanel);
            app.M34EditFieldLabel.HorizontalAlignment = 'right';
            app.M34EditFieldLabel.Position = [59 158 29 22];
            app.M34EditFieldLabel.Text = 'M34';

            % Create M34EditField
            app.M34EditField = uieditfield(app.SpectrometerParametersPanel, 'numeric');
            app.M34EditField.ValueDisplayFormat = '%11.4f';
            app.M34EditField.Position = [100 158 73 22];

            % Create CalcButton
            app.CalcButton = uibutton(app.SpectrometerParametersPanel, 'push');
            app.CalcButton.ButtonPushedFcn = createCallbackFcn(app, @CalcButtonPushed, true);
            app.CalcButton.BackgroundColor = [0 0.4471 0.7412];
            app.CalcButton.FontSize = 14;
            app.CalcButton.FontWeight = 'bold';
            app.CalcButton.FontColor = [1 1 1];
            app.CalcButton.Position = [67 40 143 24];
            app.CalcButton.Text = 'Calculate';

            % Create DipoleSwitchLabel
            app.DipoleSwitchLabel = uilabel(app.SpectrometerParametersPanel);
            app.DipoleSwitchLabel.HorizontalAlignment = 'center';
            app.DipoleSwitchLabel.FontSize = 14;
            app.DipoleSwitchLabel.FontWeight = 'bold';
            app.DipoleSwitchLabel.Position = [122 116 49 22];
            app.DipoleSwitchLabel.Text = 'Dipole';

            % Create DipoleSwitch
            app.DipoleSwitch = uiswitch(app.SpectrometerParametersPanel, 'slider');
            app.DipoleSwitch.Items = {'Without', 'With'};
            app.DipoleSwitch.ValueChangedFcn = createCallbackFcn(app, @DipoleSwitchValueChanged, true);
            app.DipoleSwitch.Position = [118 89 56 25];
            app.DipoleSwitch.Value = 'Without';

            % Create ZobDropDown
            app.ZobDropDown = uidropdown(app.SpectrometerParametersPanel);
            app.ZobDropDown.Items = {'Select...', 'Custom', 'PIC_CENT', 'FILG', 'FILS', 'IPOTR1P', 'IPOTR1', 'PENT', 'IPWS1', 'PEXT', 'IPOTR2', 'BEWIN2'};
            app.ZobDropDown.ValueChangedFcn = createCallbackFcn(app, @ZobDropDownValueChanged, true);
            app.ZobDropDown.Position = [185 260 82 22];
            app.ZobDropDown.Value = 'Select...';

            % Create ZimDropDown
            app.ZimDropDown = uidropdown(app.SpectrometerParametersPanel);
            app.ZimDropDown.Items = {'Select...', 'Custom', 'EDC_SCREEN', 'DTOTR', 'LFOV', 'CHER', 'PRDMP'};
            app.ZimDropDown.ValueChangedFcn = createCallbackFcn(app, @ZimDropDownValueChanged, true);
            app.ZimDropDown.Position = [185 226 82 22];
            app.ZimDropDown.Value = 'Select...';

            % Create MagnetValuesPanel
            app.MagnetValuesPanel = uipanel(app.SpecLineGUIUIFigure);
            app.MagnetValuesPanel.Title = 'Magnet Values';
            app.MagnetValuesPanel.Position = [293 3 377 350];

            % Create Q0DLGPS3141EditFieldLabel
            app.Q0DLGPS3141EditFieldLabel = uilabel(app.MagnetValuesPanel);
            app.Q0DLGPS3141EditFieldLabel.HorizontalAlignment = 'right';
            app.Q0DLGPS3141EditFieldLabel.Position = [14 260 104 22];
            app.Q0DLGPS3141EditFieldLabel.Text = 'Q0D (LGPS 3141)';

            % Create Q0DBDESEditField
            app.Q0DBDESEditField = uieditfield(app.MagnetValuesPanel, 'numeric');
            app.Q0DBDESEditField.Editable = 'off';
            app.Q0DBDESEditField.Position = [223 260 61 22];

            % Create Q0DBACTField
            app.Q0DBACTField = uieditfield(app.MagnetValuesPanel, 'numeric');
            app.Q0DBACTField.Editable = 'off';
            app.Q0DBACTField.Position = [296 260 59 22];

            % Create BDESLabel
            app.BDESLabel = uilabel(app.MagnetValuesPanel);
            app.BDESLabel.FontWeight = 'bold';
            app.BDESLabel.Position = [235 295 39 22];
            app.BDESLabel.Text = 'BDES';

            % Create BACTLabel
            app.BACTLabel = uilabel(app.MagnetValuesPanel);
            app.BACTLabel.FontWeight = 'bold';
            app.BACTLabel.Position = [306 295 39 22];
            app.BACTLabel.Text = 'BACT';

            % Create Q1DLGPS3261EditFieldLabel
            app.Q1DLGPS3261EditFieldLabel = uilabel(app.MagnetValuesPanel);
            app.Q1DLGPS3261EditFieldLabel.HorizontalAlignment = 'right';
            app.Q1DLGPS3261EditFieldLabel.Position = [14 226 104 22];
            app.Q1DLGPS3261EditFieldLabel.Text = 'Q1D (LGPS 3261)';

            % Create Q1DBDESEditField
            app.Q1DBDESEditField = uieditfield(app.MagnetValuesPanel, 'numeric');
            app.Q1DBDESEditField.Editable = 'off';
            app.Q1DBDESEditField.Position = [223 226 61 22];

            % Create Q1DBACTField
            app.Q1DBACTField = uieditfield(app.MagnetValuesPanel, 'numeric');
            app.Q1DBACTField.Editable = 'off';
            app.Q1DBACTField.Position = [296 226 59 22];

            % Create Q2DLGPS3091EditFieldLabel
            app.Q2DLGPS3091EditFieldLabel = uilabel(app.MagnetValuesPanel);
            app.Q2DLGPS3091EditFieldLabel.HorizontalAlignment = 'right';
            app.Q2DLGPS3091EditFieldLabel.Position = [14 192 104 22];
            app.Q2DLGPS3091EditFieldLabel.Text = 'Q2D (LGPS 3091)';

            % Create Q2DBDESEditField
            app.Q2DBDESEditField = uieditfield(app.MagnetValuesPanel, 'numeric');
            app.Q2DBDESEditField.Editable = 'off';
            app.Q2DBDESEditField.Position = [224 192 61 22];

            % Create Q2DBACTField
            app.Q2DBACTField = uieditfield(app.MagnetValuesPanel, 'numeric');
            app.Q2DBACTField.Editable = 'off';
            app.Q2DBACTField.Position = [296 192 59 22];

            % Create TrimButton
            app.TrimButton = uibutton(app.MagnetValuesPanel, 'push');
            app.TrimButton.ButtonPushedFcn = createCallbackFcn(app, @TrimButtonPushed, true);
            app.TrimButton.BackgroundColor = [0.6353 0.0784 0.1843];
            app.TrimButton.FontSize = 14;
            app.TrimButton.FontWeight = 'bold';
            app.TrimButton.FontColor = [1 1 1];
            app.TrimButton.Position = [147 115 62 24];
            app.TrimButton.Text = 'Trim';

            % Create B5DBACTField
            app.B5DBACTField = uieditfield(app.MagnetValuesPanel, 'numeric');
            app.B5DBACTField.Editable = 'off';
            app.B5DBACTField.Position = [296 158 59 22];

            % Create B5DLGPS3330Label
            app.B5DLGPS3330Label = uilabel(app.MagnetValuesPanel);
            app.B5DLGPS3330Label.HorizontalAlignment = 'right';
            app.B5DLGPS3330Label.Position = [15 158 103 22];
            app.B5DLGPS3330Label.Text = 'B5D (LGPS 3330)';

            % Create B5DBDESEditField
            app.B5DBDESEditField = uieditfield(app.MagnetValuesPanel, 'numeric');
            app.B5DBDESEditField.Editable = 'off';
            app.B5DBDESEditField.Position = [223 158 61 22];

            % Create BCALCLabel
            app.BCALCLabel = uilabel(app.MagnetValuesPanel);
            app.BCALCLabel.FontWeight = 'bold';
            app.BCALCLabel.Position = [156 295 47 22];
            app.BCALCLabel.Text = 'BCALC';

            % Create Q0DBCALCEditField
            app.Q0DBCALCEditField = uieditfield(app.MagnetValuesPanel, 'numeric');
            app.Q0DBCALCEditField.ValueChangedFcn = createCallbackFcn(app, @Q0DBCALCEditFieldValueChanged, true);
            app.Q0DBCALCEditField.Position = [139 260 70 22];

            % Create Q1DBCALCEditField
            app.Q1DBCALCEditField = uieditfield(app.MagnetValuesPanel, 'numeric');
            app.Q1DBCALCEditField.ValueChangedFcn = createCallbackFcn(app, @Q1DBCALCEditFieldValueChanged, true);
            app.Q1DBCALCEditField.Position = [139 226 70 22];

            % Create Q2DBCALCEditField
            app.Q2DBCALCEditField = uieditfield(app.MagnetValuesPanel, 'numeric');
            app.Q2DBCALCEditField.ValueChangedFcn = createCallbackFcn(app, @Q2DBCALCEditFieldValueChanged, true);
            app.Q2DBCALCEditField.Position = [139 192 70 22];

            % Create B5DBCALCEditField
            app.B5DBCALCEditField = uieditfield(app.MagnetValuesPanel, 'numeric');
            app.B5DBCALCEditField.Position = [139 158 70 22];

            % Create PrinttoELOGButton
            app.PrinttoELOGButton = uibutton(app.MagnetValuesPanel, 'push');
            app.PrinttoELOGButton.ButtonPushedFcn = createCallbackFcn(app, @PrinttoELOGButtonPushed, true);
            app.PrinttoELOGButton.BackgroundColor = [0 1 0];
            app.PrinttoELOGButton.FontSize = 14;
            app.PrinttoELOGButton.FontWeight = 'bold';
            app.PrinttoELOGButton.Position = [241 115 108 24];
            app.PrinttoELOGButton.Text = 'Print to ELOG';

            % Create XCOR3276BACTField
            app.XCOR3276BACTField = uieditfield(app.MagnetValuesPanel, 'numeric');
            app.XCOR3276BACTField.ValueDisplayFormat = '%0.4f';
            app.XCOR3276BACTField.Editable = 'off';
            app.XCOR3276BACTField.Position = [297 54 59 22];

            % Create XCOR3276BDESEditField
            app.XCOR3276BDESEditField = uieditfield(app.MagnetValuesPanel, 'numeric');
            app.XCOR3276BDESEditField.ValueDisplayFormat = '%0.4f';
            app.XCOR3276BDESEditField.Editable = 'off';
            app.XCOR3276BDESEditField.Visible = 'off';
            app.XCOR3276BDESEditField.Position = [224 54 61 22];

            % Create TrimCorrectorButton
            app.TrimCorrectorButton = uibutton(app.MagnetValuesPanel, 'push');
            app.TrimCorrectorButton.ButtonPushedFcn = createCallbackFcn(app, @TrimCorrectorButtonPushed, true);
            app.TrimCorrectorButton.BackgroundColor = [0.6353 0.0784 0.1843];
            app.TrimCorrectorButton.FontSize = 14;
            app.TrimCorrectorButton.FontWeight = 'bold';
            app.TrimCorrectorButton.FontColor = [1 1 1];
            app.TrimCorrectorButton.Visible = 'off';
            app.TrimCorrectorButton.Position = [147 17 113 24];
            app.TrimCorrectorButton.Text = 'Trim Corrector';

            % Create XCOR3276CheckBox
            app.XCOR3276CheckBox = uicheckbox(app.MagnetValuesPanel);
            app.XCOR3276CheckBox.ValueChangedFcn = createCallbackFcn(app, @XCOR3276CheckBoxValueChanged, true);
            app.XCOR3276CheckBox.Text = '   XCOR 3276';
            app.XCOR3276CheckBox.Position = [21 54 97 22];

            % Create XCOR3276BCALCEditField
            app.XCOR3276BCALCEditField = uispinner(app.MagnetValuesPanel);
            app.XCOR3276BCALCEditField.Step = 0.01;
            app.XCOR3276BCALCEditField.Limits = [-0.065 0.065];
            app.XCOR3276BCALCEditField.ValueDisplayFormat = '%0.4f';
            app.XCOR3276BCALCEditField.Visible = 'off';
            app.XCOR3276BCALCEditField.Position = [142 54 75 22];

            % Create LogPanel
            app.LogPanel = uipanel(app.SpecLineGUIUIFigure);
            app.LogPanel.Title = 'Log';
            app.LogPanel.Position = [670 3 259 350];

            % Create DisplayLogTextAreaLabel
            app.DisplayLogTextAreaLabel = uilabel(app.LogPanel);
            app.DisplayLogTextAreaLabel.HorizontalAlignment = 'right';
            app.DisplayLogTextAreaLabel.Position = [13 298 68 22];
            app.DisplayLogTextAreaLabel.Text = 'Display Log';

            % Create LogTextArea
            app.LogTextArea = uitextarea(app.LogPanel);
            app.LogTextArea.Position = [16 53 230 269];

            % Create ClearLogButton
            app.ClearLogButton = uibutton(app.LogPanel, 'push');
            app.ClearLogButton.ButtonPushedFcn = createCallbackFcn(app, @ClearLogButtonPushed, true);
            app.ClearLogButton.BackgroundColor = [0.6353 0.0784 0.1843];
            app.ClearLogButton.FontSize = 14;
            app.ClearLogButton.FontWeight = 'bold';
            app.ClearLogButton.FontColor = [1 1 1];
            app.ClearLogButton.Position = [166 17 80 24];
            app.ClearLogButton.Text = 'Clear Log';

            % Show the figure after all components are created
            app.SpecLineGUIUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_SpecLine_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.SpecLineGUIUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.SpecLineGUIUIFigure)
        end
    end
end