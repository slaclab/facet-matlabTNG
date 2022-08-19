classdef F2_LCP_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        ProbeflippersPanel              matlab.ui.container.Panel
        Probeline0HeNeSwitchLabel       matlab.ui.control.Label
        Probeline0HeNeSwitch            matlab.ui.control.Switch
        ProbelineSwitchLabel            matlab.ui.control.Label
        ProbelineSwitch                 matlab.ui.control.Switch
        MainflippersPanel               matlab.ui.container.Panel
        CompressorNFFFSwitchLabel       matlab.ui.control.Label
        CompressorNFFFSwitch            matlab.ui.control.Switch
        PBNFFFSwitchLabel               matlab.ui.control.Label
        PBNFFFSwitch                    matlab.ui.control.Switch
        CompressorBeamBlockSwitchLabel  matlab.ui.control.Label
        CompressorBeamBlockSwitch       matlab.ui.control.Switch
        LasertimingPanel                matlab.ui.container.Panel
        EOSMainEditFieldLabel_2         matlab.ui.control.Label
        EOSMainEditField_2              matlab.ui.control.NumericEditField
        MainbeamsyncLimitsLabel_2       matlab.ui.control.Label
        EOSMainEditFieldLabel_3         matlab.ui.control.Label
        EOSMainEditField_3              matlab.ui.control.NumericEditField
        MainbeamsyncLimitsLabel_3       matlab.ui.control.Label
        EOSMainEditFieldLabel_4         matlab.ui.control.Label
        EOSMainEditField_4              matlab.ui.control.NumericEditField
        MainbeamsyncLimitsLabel_4       matlab.ui.control.Label
        MasterdelaylinePanel            matlab.ui.container.Panel
        SetEditField_2Label_4           matlab.ui.control.Label
        SetMDLEditField                 matlab.ui.control.NumericEditField
        Minlongestpath74Label           matlab.ui.control.Label
        Maxshortestpath76Label          matlab.ui.control.Label
        MDLRBVLabel                     matlab.ui.control.Label
        EOSPanel                        matlab.ui.container.Panel
        EOSND2SwitchLabel               matlab.ui.control.Label
        EOSND2Switch                    matlab.ui.control.Switch
        IonizerPanel                    matlab.ui.container.Panel
        IonizerblockSwitch_2Label       matlab.ui.control.Label
        IonizerblockSwitch_2            matlab.ui.control.Switch
        IonizerND2SwitchLabel           matlab.ui.control.Label
        IonizerND2Switch                matlab.ui.control.Switch
        ShadowgraphyPanel               matlab.ui.container.Panel
        ShadowgraphyblockSwitchLabel    matlab.ui.control.Label
        ShadowgraphyblockSwitch         matlab.ui.control.Switch
        Shadowgraphy1ND5Label           matlab.ui.control.Label
        Shadowgraphy1ND5Switch          matlab.ui.control.Switch
        Shadowgraphy2ND2SwitchLabel     matlab.ui.control.Label
        Shadowgraphy2ND2Switch          matlab.ui.control.Switch
        UpdateGUIButton                 matlab.ui.control.Button
        LasershuttersPanel              matlab.ui.container.Panel
        HeNeflipperSwitchLabel          matlab.ui.control.Label
        HeNeflipperSwitch               matlab.ui.control.Switch
        CWlaserSwitchLabel              matlab.ui.control.Label
        CWlaserSwitch                   matlab.ui.control.Switch
        EPSShutterSwitchLabel           matlab.ui.control.Label
        EPSShutterSwitch                matlab.ui.control.Switch
        IPOTR1Panel                     matlab.ui.container.Panel
        IPOTR1OvensideSwitchLabel       matlab.ui.control.Label
        IPOTR1OvensideSwitch            matlab.ui.control.Switch
        IPOTR1ND9SwitchLabel            matlab.ui.control.Label
        IPOTR1ND9Switch                 matlab.ui.control.Switch
        IPOTR2Panel                     matlab.ui.container.Panel
        IPOTR2ND9SwitchLabel            matlab.ui.control.Label
        IPOTR2ND9Switch                 matlab.ui.control.Switch
        IPOTR2ND2SwitchLabel            matlab.ui.control.Label
        IPOTR2ND2Switch                 matlab.ui.control.Switch
        IPOTR2BlueSwitchLabel           matlab.ui.control.Label
        IPOTR2BlueSwitch                matlab.ui.control.Switch
        PrintmotorpositionsButton       matlab.ui.control.Button
        PrintflipperstatusButton        matlab.ui.control.Button
        E320Panel                       matlab.ui.container.Panel
        MOMAGND2SwitchLabel             matlab.ui.control.Label
        MOMAGND2Switch                  matlab.ui.control.Switch
        LaserenergyPanel                matlab.ui.container.Panel
        LaserattenuatorPanel            matlab.ui.container.Panel
        SetEditFieldLabel               matlab.ui.control.Label
        SetLaserEditField               matlab.ui.control.NumericEditField
        Max119Label                     matlab.ui.control.Label
        Min74Label                      matlab.ui.control.Label
        LaserRBVLabel                   matlab.ui.control.Label
        MinimumenergyButton             matlab.ui.control.Button
        ProbeattenuatorPanel            matlab.ui.container.Panel
        SetEditField_2Label             matlab.ui.control.Label
        SetProbeEditField               matlab.ui.control.NumericEditField
        Max82Label                      matlab.ui.control.Label
        Min37Label                      matlab.ui.control.Label
        ProbeRBVLabel                   matlab.ui.control.Label
        LaseraperturePanel              matlab.ui.container.Panel
        SetEditField_2Label_3           matlab.ui.control.Label
        SetLIrisEditField               matlab.ui.control.NumericEditField
        mmmin5Label                     matlab.ui.control.Label
        mm40Label                       matlab.ui.control.Label
        LIrisRBVLabel                   matlab.ui.control.Label
        mmmax60Label                    matlab.ui.control.Label
        LaserpolarizationPanel          matlab.ui.container.Panel
        SetEditField_2Label_2           matlab.ui.control.Label
        SetLPolEditField                matlab.ui.control.NumericEditField
        SpolPulsed50Label               matlab.ui.control.Label
        PpolCW95Label                   matlab.ui.control.Label
        LPolRBVLabel                    matlab.ui.control.Label
    end

    
    properties (Access = private)
        LCP % Laser Control Panel class
    end
    
    methods (Access = private)
        function updateGUI(app)
            app.setFlipperStatus();
            app.setMotorStatus();
        end
        
        function setMotorStatus(app)
            %Delay stages
            
            % Laser attenuator
            RBV = app.LCP.SMotorList.LaserAttenuator.getRBV();
            app.LaserRBVLabel.Text = sprintf('RBV: %.2f', RBV );
            app.SetLaserEditField.Value = RBV;
            
            % Probe attenuator
            RBV = app.LCP.SMotorList.ProbeAttenuator.getRBV();
            app.ProbeRBVLabel.Text = sprintf('RBV: %.2f', RBV );
            app.SetProbeEditField.Value = RBV;
            
            % Laser polarization
            RBV = app.LCP.SMotorList.LPol.getRBV();
            app.LPolRBVLabel.Text = sprintf('RBV: %.2f', RBV );
            app.SetLPolEditField.Value = RBV;
            
            % Laser iris
            RBV = app.LCP.SMotorList.LIris.getRBV();
            app.LIrisRBVLabel.Text = sprintf('RBV: %.2f', RBV );
            app.SetLIrisEditField.Value = RBV;
            
            % Master Delay Line
            RBV = app.LCP.SMotorList.MDL.getRBV();
            app.MDLRBVLabel.Text = sprintf('RBV: %.2f', RBV );
            app.SetMDLEditField.Value = RBV;
        end
        
        function setFlipperStatus(app)
            %CW Shutter
            app.EPSShutterSwitch.Value = app.LCP.blockList.CWIR.getState();
            
            %HeNe Shutter
            app.EPSShutterSwitch.Value = app.LCP.blockList.HeNe.getState();
            
            %Compressor block
            app.CompressorBeamBlockSwitch.Value = app.LCP.blockList.Comp.getState();
            
            %EPSShutter 
            app.EPSShutterSwitch.Value = app.LCP.blockList.EPSShutter.getState();
            
            %Probeline0
            app.Probeline0HeNeSwitch.Value = app.LCP.filterList.Probeline0HeNe.getState();
            
            %Probe block
            app.ProbelineSwitch.Value = app.LCP.blockList.probeBlock.getState();
            
            %EOS
            app.EOSND2Switch.Value = app.LCP.filterList.EOSND2.getState();
            
            %E320
            app.MOMAGND2Switch.Value = app.LCP.filterList.E320MOMAG.getState();
            
            %Ionizer
            app.IonizerblockSwitch_2.Value = app.LCP.blockList.ionizer.getState();
            app.IonizerND2Switch.Value = app.LCP.filterList.ionizerND2.getState();
            
            %Shadowgraphy 
            app.Shadowgraphy1ND5Switch.Value = app.LCP.filterList.shadow1.getState()
            app.Shadowgraphy2ND2Switch.Value = app.LCP.filterList.shadow2.getState();
            app.ShadowgraphyblockSwitch.Value = app.LCP.blockList.shadowgraphy.getState();
            
            %Main beam
            app.CompressorNFFFSwitch.Value = app.LCP.filterList.CompNFF.getState();
            app.PBNFFFSwitch.Value = app.LCP.filterList.PBNFF.getState();
            
            %IPOTRs
            app.IPOTR1ND9Switch.Value = app.LCP.filterList.IPOTR1ND9.getState();
            app.IPOTR1OvensideSwitch.Value  = app.LCP.filterList.IPOTR1P.getState();
            
            app.IPOTR2ND9Switch.Value  = app.LCP.filterList.IPOTR2ND9.getState();
            app.IPOTR2ND2Switch.Value  = app.LCP.filterList.IPOTR2ND2.getState();
            app.IPOTR2BlueSwitch.Value  = app.LCP.filterList.IPOTR2Blue.getState();
            
        end
        
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.LCP = cLCP(app);
            app.updateGUI();
        end

        % Value changed function: ProbelineSwitch
        function ProbelineSwitchValueChanged(app, event)
            app.LCP.blockList.probeBlock.flip();
            app.updateGUI();
        end

        % Value changed function: EOSND2Switch
        function EOSND2SwitchValueChanged(app, event)
            app.LCP.filterList.EOSND2.flip();
            app.updateGUI();
        end

        % Value changed function: IonizerblockSwitch_2
        function IonizerblockSwitch_2ValueChanged(app, event)
            app.LCP.blockList.ionizer.flip();
            app.updateGUI();
        end

        % Value changed function: IonizerND2Switch
        function IonizerND2SwitchValueChanged(app, event)
            app.LCP.filterList.ionizerND2.flip();
            app.updateGUI();
        end

        % Value changed function: ShadowgraphyblockSwitch
        function ShadowgraphyblockSwitchValueChanged(app, event)
            app.LCP.blockList.shadowgraphy.flip();
            app.updateGUI();
        end

        % Value changed function: Shadowgraphy1ND5Switch
        function Shadowgraphy1ND5SwitchValueChanged(app, event)
            app.LCP.filterList.shadow1.flip();
            app.updateGUI();
        end

        % Value changed function: Shadowgraphy2ND2Switch
        function Shadowgraphy2ND2SwitchValueChanged(app, event)
            app.LCP.filterList.shadow2.flip();
            app.updateGUI();
        end

        % Value changed function: Probeline0HeNeSwitch
        function Probeline0HeNeSwitchValueChanged(app, event)
            app.LCP.filterList.Probeline0HeNe.flip();
            app.updateGUI();
        end

        % Value changed function: CompressorNFFFSwitch
        function CompressorNFFFSwitchValueChanged(app, event)
            app.LCP.filterList.CompNFF.flip();
            app.updateGUI();
        end

        % Value changed function: PBNFFFSwitch
        function PBNFFFSwitchValueChanged(app, event)
            app.LCP.filterList.PBNFF.flip();
            app.updateGUI();
        end

        % Value changed function: EPSShutterSwitch
        function EPSShutterSwitchValueChanged(app, event)
            app.LCP.blockList.EPSShutter.flip();
            app.updateGUI();
        end

        % Button pushed function: UpdateGUIButton
        function UpdateGUIButtonPushed(app, event)
            app.updateGUI();
        end

        % Value changed function: CWlaserSwitch
        function CWlaserSwitchValueChanged(app, event)
            app.LCP.blockList.CWIR.flip();
            app.updateGUI();
        end

        % Value changed function: HeNeflipperSwitch
        function HeNeflipperSwitchValueChanged(app, event)
            app.LCP.blockList.HeNe.flip();
            app.updateGUI();
        end

        % Value changed function: IPOTR2ND9Switch
        function IPOTR2ND9SwitchValueChanged(app, event)
            app.LCP.filterList.IPOTR2ND9.flip();
            app.updateGUI();
        end

        % Value changed function: IPOTR1ND9Switch
        function IPOTR1ND9SwitchValueChanged(app, event)
            app.LCP.filterList.IPOTR1ND9.flip();
            app.updateGUI();
        end

        % Value changed function: SetLaserEditField
        function SetLaserEditFieldValueChanged(app, event)
            value = app.SetLaserEditField.Value;
            app.LCP.SMotorList.LaserAttenuator.move(value);
            app.updateGUI();
        end

        % Value changed function: SetProbeEditField
        function SetProbeEditFieldValueChanged(app, event)
            value = app.SetProbeEditField.Value;
            app.LCP.SMotorList.ProbeAttenuator.move(value);
            app.updateGUI();
        end

        % Value changed function: IPOTR2ND2Switch
        function IPOTR2ND2SwitchValueChanged(app, event)
            app.LCP.filterList.IPOTR2ND2.flip();
            app.updateGUI();
        end

        % Value changed function: IPOTR2BlueSwitch
        function IPOTR2BlueSwitchValueChanged(app, event)
            app.LCP.filterList.IPOTR2Blue.flip();
            app.updateGUI();
        end

        % Value changed function: IPOTR1OvensideSwitch
        function IPOTR1OvensideSwitchValueChanged(app, event)
            app.LCP.filterList.IPOTR1P.flip();
            app.updateGUI();
        end

        % Value changed function: CompressorBeamBlockSwitch
        function CompressorBeamBlockSwitchValueChanged(app, event)
            app.LCP.blockList.Comp.flip();
            app.updateGUI();
        end

        % Value changed function: MOMAGND2Switch
        function MOMAGND2SwitchValueChanged(app, event)
            app.LCP.filterList.E320MOMAG.flip();
            app.updateGUI();
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            delete(app)
            disp('Remember to uncomment the exit command')
            exit;
        end

        % Value changed function: SetLPolEditField
        function SetLPolEditFieldValueChanged(app, event)
            value = app.SetLPolEditField.Value;
            app.LCP.SMotorList.LPol.move(value);
            app.updateGUI();
        end

        % Value changed function: SetLIrisEditField
        function SetLIrisEditFieldValueChanged(app, event)
            value = app.SetLIrisEditField.Value;
            app.LCP.SMotorList.LIris.move(value);
            app.updateGUI();
        end

        % Button pushed function: PrintmotorpositionsButton
        function PrintmotorpositionsButtonPushed(app, event)
            addpath('/usr/local/facet/tools/matlabTNG/common/')
            
            info_str = sprintf(['| Motor Name | Motor PV | RBV \n']);
            mat_line = app.LCP.printSMotorList();
            
            info_str = [info_str mat_line];
            
            info_str = sprintf([info_str '\n' '\n']);
            
            figure(99);
            ax = axes();
            set(ax, 'Visible', 'off');
            set(gcf,'Position',[10 10 10 10]);
            util_printLog2020(99,'title','Laser Control Panel Motor Values',...
            'author','Laser Control Panel','text',info_str);
            clf(99), close(99);
        end

        % Button pushed function: PrintflipperstatusButton
        function PrintflipperstatusButtonPushed(app, event)
            addpath('/usr/local/facet/tools/matlabTNG/common/')
            
            info_str = sprintf(['| Flipper Name | Flipper PV | Status \n']);
            mat_line = app.LCP.printFilterList();
            mat_line2 =  app.LCP.printBlockList();
            
            info_str = [info_str mat_line, mat_line2];
            
            info_str = sprintf([info_str '\n' '\n']);
            
            figure(99);
            ax = axes();
            set(ax, 'Visible', 'off');
            set(gcf,'Position',[10 10 10 10]);
            util_printLog2020(99,'title','Laser Control Panel flipper status',...
            'author','Laser Control Panel','text',info_str);
            clf(99), close(99);
        end

        % Value changed function: SetMDLEditField
        function SetMDLEditFieldValueChanged(app, event)
            value = app.SetMDLEditField.Value;
            app.LCP.SMotorList.MDL.move(value);
            app.updateGUI();
        end

        % Button pushed function: MinimumenergyButton
        function MinimumenergyButtonPushed(app, event)
            app.LCP.SMotorList.LaserAttenuator.move(74);
            app.updateGUI();
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1101 730];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create ProbeflippersPanel
            app.ProbeflippersPanel = uipanel(app.UIFigure);
            app.ProbeflippersPanel.Title = 'Probe flippers';
            app.ProbeflippersPanel.Position = [662 512 140 192];

            % Create Probeline0HeNeSwitchLabel
            app.Probeline0HeNeSwitchLabel = uilabel(app.ProbeflippersPanel);
            app.Probeline0HeNeSwitchLabel.HorizontalAlignment = 'center';
            app.Probeline0HeNeSwitchLabel.Position = [20 142 100 22];
            app.Probeline0HeNeSwitchLabel.Text = 'Probeline0 HeNe';

            % Create Probeline0HeNeSwitch
            app.Probeline0HeNeSwitch = uiswitch(app.ProbeflippersPanel, 'slider');
            app.Probeline0HeNeSwitch.Items = {'In', 'Out'};
            app.Probeline0HeNeSwitch.ValueChangedFcn = createCallbackFcn(app, @Probeline0HeNeSwitchValueChanged, true);
            app.Probeline0HeNeSwitch.Position = [44 111 45 20];
            app.Probeline0HeNeSwitch.Value = 'In';

            % Create ProbelineSwitchLabel
            app.ProbelineSwitchLabel = uilabel(app.ProbeflippersPanel);
            app.ProbelineSwitchLabel.HorizontalAlignment = 'center';
            app.ProbelineSwitchLabel.Position = [37 72 58 22];
            app.ProbelineSwitchLabel.Text = 'Probeline';

            % Create ProbelineSwitch
            app.ProbelineSwitch = uiswitch(app.ProbeflippersPanel, 'slider');
            app.ProbelineSwitch.Items = {'In', 'Out'};
            app.ProbelineSwitch.ValueChangedFcn = createCallbackFcn(app, @ProbelineSwitchValueChanged, true);
            app.ProbelineSwitch.Position = [43 41 45 20];
            app.ProbelineSwitch.Value = 'In';

            % Create MainflippersPanel
            app.MainflippersPanel = uipanel(app.UIFigure);
            app.MainflippersPanel.Title = 'Main flippers';
            app.MainflippersPanel.Position = [181 453 125 251];

            % Create CompressorNFFFSwitchLabel
            app.CompressorNFFFSwitchLabel = uilabel(app.MainflippersPanel);
            app.CompressorNFFFSwitchLabel.HorizontalAlignment = 'center';
            app.CompressorNFFFSwitchLabel.Position = [21 113 75 30];
            app.CompressorNFFFSwitchLabel.Text = {'Compressor '; 'NF FF'};

            % Create CompressorNFFFSwitch
            app.CompressorNFFFSwitch = uiswitch(app.MainflippersPanel, 'slider');
            app.CompressorNFFFSwitch.Items = {'In', 'Out'};
            app.CompressorNFFFSwitch.ValueChangedFcn = createCallbackFcn(app, @CompressorNFFFSwitchValueChanged, true);
            app.CompressorNFFFSwitch.Position = [35 90 45 20];
            app.CompressorNFFFSwitch.Value = 'In';

            % Create PBNFFFSwitchLabel
            app.PBNFFFSwitchLabel = uilabel(app.MainflippersPanel);
            app.PBNFFFSwitchLabel.HorizontalAlignment = 'center';
            app.PBNFFFSwitchLabel.Position = [40 45 38 30];
            app.PBNFFFSwitchLabel.Text = {'PB'; 'NF FF'};

            % Create PBNFFFSwitch
            app.PBNFFFSwitch = uiswitch(app.MainflippersPanel, 'slider');
            app.PBNFFFSwitch.Items = {'In', 'Out'};
            app.PBNFFFSwitch.ValueChangedFcn = createCallbackFcn(app, @PBNFFFSwitchValueChanged, true);
            app.PBNFFFSwitch.Position = [35 22 45 20];
            app.PBNFFFSwitch.Value = 'In';

            % Create CompressorBeamBlockSwitchLabel
            app.CompressorBeamBlockSwitchLabel = uilabel(app.MainflippersPanel);
            app.CompressorBeamBlockSwitchLabel.HorizontalAlignment = 'center';
            app.CompressorBeamBlockSwitchLabel.Position = [22 184 75 30];
            app.CompressorBeamBlockSwitchLabel.Text = {'Compressor '; 'Beam Block'};

            % Create CompressorBeamBlockSwitch
            app.CompressorBeamBlockSwitch = uiswitch(app.MainflippersPanel, 'slider');
            app.CompressorBeamBlockSwitch.Items = {'In', 'Out'};
            app.CompressorBeamBlockSwitch.ValueChangedFcn = createCallbackFcn(app, @CompressorBeamBlockSwitchValueChanged, true);
            app.CompressorBeamBlockSwitch.Position = [35 161 45 20];
            app.CompressorBeamBlockSwitch.Value = 'In';

            % Create LasertimingPanel
            app.LasertimingPanel = uipanel(app.UIFigure);
            app.LasertimingPanel.Title = 'Laser timing ';
            app.LasertimingPanel.Position = [604 20 474 364];

            % Create EOSMainEditFieldLabel_2
            app.EOSMainEditFieldLabel_2 = uilabel(app.LasertimingPanel);
            app.EOSMainEditFieldLabel_2.HorizontalAlignment = 'right';
            app.EOSMainEditFieldLabel_2.Enable = 'off';
            app.EOSMainEditFieldLabel_2.Position = [303 62 34 22];
            app.EOSMainEditFieldLabel_2.Text = 'E324';

            % Create EOSMainEditField_2
            app.EOSMainEditField_2 = uieditfield(app.LasertimingPanel, 'numeric');
            app.EOSMainEditField_2.Position = [352 62 100 22];

            % Create MainbeamsyncLimitsLabel_2
            app.MainbeamsyncLimitsLabel_2 = uilabel(app.LasertimingPanel);
            app.MainbeamsyncLimitsLabel_2.Enable = 'off';
            app.MainbeamsyncLimitsLabel_2.Position = [314 18 100 30];
            app.MainbeamsyncLimitsLabel_2.Text = {'Main beam sync: '; 'Limits:'};

            % Create EOSMainEditFieldLabel_3
            app.EOSMainEditFieldLabel_3 = uilabel(app.LasertimingPanel);
            app.EOSMainEditFieldLabel_3.HorizontalAlignment = 'right';
            app.EOSMainEditFieldLabel_3.Enable = 'off';
            app.EOSMainEditFieldLabel_3.Position = [298 135 42 22];
            app.EOSMainEditFieldLabel_3.Text = 'Ionizer';

            % Create EOSMainEditField_3
            app.EOSMainEditField_3 = uieditfield(app.LasertimingPanel, 'numeric');
            app.EOSMainEditField_3.Position = [355 135 100 22];

            % Create MainbeamsyncLimitsLabel_3
            app.MainbeamsyncLimitsLabel_3 = uilabel(app.LasertimingPanel);
            app.MainbeamsyncLimitsLabel_3.Enable = 'off';
            app.MainbeamsyncLimitsLabel_3.Position = [317 91 100 30];
            app.MainbeamsyncLimitsLabel_3.Text = {'Main beam sync: '; 'Limits:'};

            % Create EOSMainEditFieldLabel_4
            app.EOSMainEditFieldLabel_4 = uilabel(app.LasertimingPanel);
            app.EOSMainEditFieldLabel_4.HorizontalAlignment = 'right';
            app.EOSMainEditFieldLabel_4.Enable = 'off';
            app.EOSMainEditFieldLabel_4.Position = [96 62 88 22];
            app.EOSMainEditFieldLabel_4.Text = 'Shadowgraphy';

            % Create EOSMainEditField_4
            app.EOSMainEditField_4 = uieditfield(app.LasertimingPanel, 'numeric');
            app.EOSMainEditField_4.Position = [199 62 100 22];

            % Create MainbeamsyncLimitsLabel_4
            app.MainbeamsyncLimitsLabel_4 = uilabel(app.LasertimingPanel);
            app.MainbeamsyncLimitsLabel_4.Enable = 'off';
            app.MainbeamsyncLimitsLabel_4.Position = [161 18 100 30];
            app.MainbeamsyncLimitsLabel_4.Text = {'Main beam sync: '; 'Limits:'};

            % Create MasterdelaylinePanel
            app.MasterdelaylinePanel = uipanel(app.LasertimingPanel);
            app.MasterdelaylinePanel.Title = 'Master delay line';
            app.MasterdelaylinePanel.Position = [22 120 124 207];

            % Create SetEditField_2Label_4
            app.SetEditField_2Label_4 = uilabel(app.MasterdelaylinePanel);
            app.SetEditField_2Label_4.HorizontalAlignment = 'right';
            app.SetEditField_2Label_4.Position = [23 147 25 22];
            app.SetEditField_2Label_4.Text = 'Set';

            % Create SetMDLEditField
            app.SetMDLEditField = uieditfield(app.MasterdelaylinePanel, 'numeric');
            app.SetMDLEditField.Limits = [-74 76];
            app.SetMDLEditField.ValueChangedFcn = createCallbackFcn(app, @SetMDLEditFieldValueChanged, true);
            app.SetMDLEditField.Position = [62 147 52 22];

            % Create Minlongestpath74Label
            app.Minlongestpath74Label = uilabel(app.MasterdelaylinePanel);
            app.Minlongestpath74Label.Position = [8 73 109 30];
            app.Minlongestpath74Label.Text = {'Min (longest path): '; '-74'};

            % Create Maxshortestpath76Label
            app.Maxshortestpath76Label = uilabel(app.MasterdelaylinePanel);
            app.Maxshortestpath76Label.Position = [6 37 115 30];
            app.Maxshortestpath76Label.Text = {'Max (shortest path): '; '76'};

            % Create MDLRBVLabel
            app.MDLRBVLabel = uilabel(app.MasterdelaylinePanel);
            app.MDLRBVLabel.Position = [21 117 85 22];
            app.MDLRBVLabel.Text = 'RBV: ';

            % Create EOSPanel
            app.EOSPanel = uipanel(app.UIFigure);
            app.EOSPanel.Title = 'EOS';
            app.EOSPanel.Position = [689 405 107 96];

            % Create EOSND2SwitchLabel
            app.EOSND2SwitchLabel = uilabel(app.EOSPanel);
            app.EOSND2SwitchLabel.HorizontalAlignment = 'center';
            app.EOSND2SwitchLabel.Position = [21 46 58 22];
            app.EOSND2SwitchLabel.Text = 'EOS ND2';

            % Create EOSND2Switch
            app.EOSND2Switch = uiswitch(app.EOSPanel, 'slider');
            app.EOSND2Switch.Items = {'In', 'Out'};
            app.EOSND2Switch.ValueChangedFcn = createCallbackFcn(app, @EOSND2SwitchValueChanged, true);
            app.EOSND2Switch.Position = [27 15 45 20];
            app.EOSND2Switch.Value = 'In';

            % Create IonizerPanel
            app.IonizerPanel = uipanel(app.UIFigure);
            app.IonizerPanel.Title = 'Ionizer';
            app.IonizerPanel.Position = [957 525 107 179];

            % Create IonizerblockSwitch_2Label
            app.IonizerblockSwitch_2Label = uilabel(app.IonizerPanel);
            app.IonizerblockSwitch_2Label.HorizontalAlignment = 'center';
            app.IonizerblockSwitch_2Label.Position = [15 121 74 22];
            app.IonizerblockSwitch_2Label.Text = 'Ionizer block';

            % Create IonizerblockSwitch_2
            app.IonizerblockSwitch_2 = uiswitch(app.IonizerPanel, 'slider');
            app.IonizerblockSwitch_2.Items = {'In', 'Out'};
            app.IonizerblockSwitch_2.ValueChangedFcn = createCallbackFcn(app, @IonizerblockSwitch_2ValueChanged, true);
            app.IonizerblockSwitch_2.Position = [29 90 45 20];
            app.IonizerblockSwitch_2.Value = 'In';

            % Create IonizerND2SwitchLabel
            app.IonizerND2SwitchLabel = uilabel(app.IonizerPanel);
            app.IonizerND2SwitchLabel.HorizontalAlignment = 'center';
            app.IonizerND2SwitchLabel.Position = [17 46 70 22];
            app.IonizerND2SwitchLabel.Text = 'Ionizer ND2';

            % Create IonizerND2Switch
            app.IonizerND2Switch = uiswitch(app.IonizerPanel, 'slider');
            app.IonizerND2Switch.Items = {'In', 'Out'};
            app.IonizerND2Switch.ValueChangedFcn = createCallbackFcn(app, @IonizerND2SwitchValueChanged, true);
            app.IonizerND2Switch.Position = [29 15 45 20];
            app.IonizerND2Switch.Value = 'In';

            % Create ShadowgraphyPanel
            app.ShadowgraphyPanel = uipanel(app.UIFigure);
            app.ShadowgraphyPanel.Title = 'Shadowgraphy';
            app.ShadowgraphyPanel.Position = [807 455 136 250];

            % Create ShadowgraphyblockSwitchLabel
            app.ShadowgraphyblockSwitchLabel = uilabel(app.ShadowgraphyPanel);
            app.ShadowgraphyblockSwitchLabel.HorizontalAlignment = 'center';
            app.ShadowgraphyblockSwitchLabel.Position = [8 196 120 22];
            app.ShadowgraphyblockSwitchLabel.Text = 'Shadowgraphy block';

            % Create ShadowgraphyblockSwitch
            app.ShadowgraphyblockSwitch = uiswitch(app.ShadowgraphyPanel, 'slider');
            app.ShadowgraphyblockSwitch.Items = {'In', 'Out'};
            app.ShadowgraphyblockSwitch.ValueChangedFcn = createCallbackFcn(app, @ShadowgraphyblockSwitchValueChanged, true);
            app.ShadowgraphyblockSwitch.Position = [44 165 45 20];
            app.ShadowgraphyblockSwitch.Value = 'In';

            % Create Shadowgraphy1ND5Label
            app.Shadowgraphy1ND5Label = uilabel(app.ShadowgraphyPanel);
            app.Shadowgraphy1ND5Label.HorizontalAlignment = 'center';
            app.Shadowgraphy1ND5Label.Position = [6.5 124 123 22];
            app.Shadowgraphy1ND5Label.Text = 'Shadowgraphy1 ND5';

            % Create Shadowgraphy1ND5Switch
            app.Shadowgraphy1ND5Switch = uiswitch(app.ShadowgraphyPanel, 'slider');
            app.Shadowgraphy1ND5Switch.Items = {'In', 'Out'};
            app.Shadowgraphy1ND5Switch.ValueChangedFcn = createCallbackFcn(app, @Shadowgraphy1ND5SwitchValueChanged, true);
            app.Shadowgraphy1ND5Switch.Position = [42 93 45 20];
            app.Shadowgraphy1ND5Switch.Value = 'In';

            % Create Shadowgraphy2ND2SwitchLabel
            app.Shadowgraphy2ND2SwitchLabel = uilabel(app.ShadowgraphyPanel);
            app.Shadowgraphy2ND2SwitchLabel.HorizontalAlignment = 'center';
            app.Shadowgraphy2ND2SwitchLabel.Position = [6 57 123 22];
            app.Shadowgraphy2ND2SwitchLabel.Text = 'Shadowgraphy2 ND2';

            % Create Shadowgraphy2ND2Switch
            app.Shadowgraphy2ND2Switch = uiswitch(app.ShadowgraphyPanel, 'slider');
            app.Shadowgraphy2ND2Switch.Items = {'In', 'Out'};
            app.Shadowgraphy2ND2Switch.ValueChangedFcn = createCallbackFcn(app, @Shadowgraphy2ND2SwitchValueChanged, true);
            app.Shadowgraphy2ND2Switch.Position = [42 26 45 20];
            app.Shadowgraphy2ND2Switch.Value = 'In';

            % Create UpdateGUIButton
            app.UpdateGUIButton = uibutton(app.UIFigure, 'push');
            app.UpdateGUIButton.ButtonPushedFcn = createCallbackFcn(app, @UpdateGUIButtonPushed, true);
            app.UpdateGUIButton.Position = [37 16 100 23];
            app.UpdateGUIButton.Text = 'Update GUI';

            % Create LasershuttersPanel
            app.LasershuttersPanel = uipanel(app.UIFigure);
            app.LasershuttersPanel.Title = 'Laser shutters';
            app.LasershuttersPanel.Position = [30 451 139 254];

            % Create HeNeflipperSwitchLabel
            app.HeNeflipperSwitchLabel = uilabel(app.LasershuttersPanel);
            app.HeNeflipperSwitchLabel.HorizontalAlignment = 'center';
            app.HeNeflipperSwitchLabel.Position = [33 196 74 22];
            app.HeNeflipperSwitchLabel.Text = 'HeNe flipper';

            % Create HeNeflipperSwitch
            app.HeNeflipperSwitch = uiswitch(app.LasershuttersPanel, 'slider');
            app.HeNeflipperSwitch.Items = {'In', 'Out'};
            app.HeNeflipperSwitch.ValueChangedFcn = createCallbackFcn(app, @HeNeflipperSwitchValueChanged, true);
            app.HeNeflipperSwitch.Position = [45 165 45 20];
            app.HeNeflipperSwitch.Value = 'In';

            % Create CWlaserSwitchLabel
            app.CWlaserSwitchLabel = uilabel(app.LasershuttersPanel);
            app.CWlaserSwitchLabel.HorizontalAlignment = 'center';
            app.CWlaserSwitchLabel.Position = [43 125 55 22];
            app.CWlaserSwitchLabel.Text = 'CW laser';

            % Create CWlaserSwitch
            app.CWlaserSwitch = uiswitch(app.LasershuttersPanel, 'slider');
            app.CWlaserSwitch.Items = {'In', 'Out'};
            app.CWlaserSwitch.ValueChangedFcn = createCallbackFcn(app, @CWlaserSwitchValueChanged, true);
            app.CWlaserSwitch.Position = [45 94 45 20];
            app.CWlaserSwitch.Value = 'In';

            % Create EPSShutterSwitchLabel
            app.EPSShutterSwitchLabel = uilabel(app.LasershuttersPanel);
            app.EPSShutterSwitchLabel.HorizontalAlignment = 'center';
            app.EPSShutterSwitchLabel.Position = [33 55 71 22];
            app.EPSShutterSwitchLabel.Text = 'EPS Shutter';

            % Create EPSShutterSwitch
            app.EPSShutterSwitch = uiswitch(app.LasershuttersPanel, 'slider');
            app.EPSShutterSwitch.Items = {'In', 'Out'};
            app.EPSShutterSwitch.ValueChangedFcn = createCallbackFcn(app, @EPSShutterSwitchValueChanged, true);
            app.EPSShutterSwitch.Position = [45 24 45 20];
            app.EPSShutterSwitch.Value = 'In';

            % Create IPOTR1Panel
            app.IPOTR1Panel = uipanel(app.UIFigure);
            app.IPOTR1Panel.Title = 'IPOTR1';
            app.IPOTR1Panel.Position = [351 514 133 188];

            % Create IPOTR1OvensideSwitchLabel
            app.IPOTR1OvensideSwitchLabel = uilabel(app.IPOTR1Panel);
            app.IPOTR1OvensideSwitchLabel.HorizontalAlignment = 'center';
            app.IPOTR1OvensideSwitchLabel.Position = [16 131 106 22];
            app.IPOTR1OvensideSwitchLabel.Text = 'IPOTR1 Oven side';

            % Create IPOTR1OvensideSwitch
            app.IPOTR1OvensideSwitch = uiswitch(app.IPOTR1Panel, 'slider');
            app.IPOTR1OvensideSwitch.Items = {'In', 'Out'};
            app.IPOTR1OvensideSwitch.ValueChangedFcn = createCallbackFcn(app, @IPOTR1OvensideSwitchValueChanged, true);
            app.IPOTR1OvensideSwitch.Position = [45 100 45 20];
            app.IPOTR1OvensideSwitch.Value = 'In';

            % Create IPOTR1ND9SwitchLabel
            app.IPOTR1ND9SwitchLabel = uilabel(app.IPOTR1Panel);
            app.IPOTR1ND9SwitchLabel.HorizontalAlignment = 'center';
            app.IPOTR1ND9SwitchLabel.Position = [27 65 76 22];
            app.IPOTR1ND9SwitchLabel.Text = 'IPOTR1 ND9';

            % Create IPOTR1ND9Switch
            app.IPOTR1ND9Switch = uiswitch(app.IPOTR1Panel, 'slider');
            app.IPOTR1ND9Switch.Items = {'In', 'Out'};
            app.IPOTR1ND9Switch.ValueChangedFcn = createCallbackFcn(app, @IPOTR1ND9SwitchValueChanged, true);
            app.IPOTR1ND9Switch.Position = [41 34 45 20];
            app.IPOTR1ND9Switch.Value = 'In';

            % Create IPOTR2Panel
            app.IPOTR2Panel = uipanel(app.UIFigure);
            app.IPOTR2Panel.Title = 'IPOTR2';
            app.IPOTR2Panel.Position = [493 447 118 254];

            % Create IPOTR2ND9SwitchLabel
            app.IPOTR2ND9SwitchLabel = uilabel(app.IPOTR2Panel);
            app.IPOTR2ND9SwitchLabel.HorizontalAlignment = 'center';
            app.IPOTR2ND9SwitchLabel.Position = [19 205 76 22];
            app.IPOTR2ND9SwitchLabel.Text = 'IPOTR2 ND9';

            % Create IPOTR2ND9Switch
            app.IPOTR2ND9Switch = uiswitch(app.IPOTR2Panel, 'slider');
            app.IPOTR2ND9Switch.Items = {'In', 'Out'};
            app.IPOTR2ND9Switch.ValueChangedFcn = createCallbackFcn(app, @IPOTR2ND9SwitchValueChanged, true);
            app.IPOTR2ND9Switch.Position = [33 174 45 20];
            app.IPOTR2ND9Switch.Value = 'In';

            % Create IPOTR2ND2SwitchLabel
            app.IPOTR2ND2SwitchLabel = uilabel(app.IPOTR2Panel);
            app.IPOTR2ND2SwitchLabel.HorizontalAlignment = 'center';
            app.IPOTR2ND2SwitchLabel.Position = [19 135 76 22];
            app.IPOTR2ND2SwitchLabel.Text = 'IPOTR2 ND2';

            % Create IPOTR2ND2Switch
            app.IPOTR2ND2Switch = uiswitch(app.IPOTR2Panel, 'slider');
            app.IPOTR2ND2Switch.Items = {'In', 'Out'};
            app.IPOTR2ND2Switch.ValueChangedFcn = createCallbackFcn(app, @IPOTR2ND2SwitchValueChanged, true);
            app.IPOTR2ND2Switch.Position = [33 104 45 20];
            app.IPOTR2ND2Switch.Value = 'In';

            % Create IPOTR2BlueSwitchLabel
            app.IPOTR2BlueSwitchLabel = uilabel(app.IPOTR2Panel);
            app.IPOTR2BlueSwitchLabel.HorizontalAlignment = 'center';
            app.IPOTR2BlueSwitchLabel.Position = [21 68 76 22];
            app.IPOTR2BlueSwitchLabel.Text = 'IPOTR2 Blue';

            % Create IPOTR2BlueSwitch
            app.IPOTR2BlueSwitch = uiswitch(app.IPOTR2Panel, 'slider');
            app.IPOTR2BlueSwitch.Items = {'In', 'Out'};
            app.IPOTR2BlueSwitch.ValueChangedFcn = createCallbackFcn(app, @IPOTR2BlueSwitchValueChanged, true);
            app.IPOTR2BlueSwitch.Position = [35 37 45 20];
            app.IPOTR2BlueSwitch.Value = 'In';

            % Create PrintmotorpositionsButton
            app.PrintmotorpositionsButton = uibutton(app.UIFigure, 'push');
            app.PrintmotorpositionsButton.ButtonPushedFcn = createCallbackFcn(app, @PrintmotorpositionsButtonPushed, true);
            app.PrintmotorpositionsButton.Position = [322 16 126 23];
            app.PrintmotorpositionsButton.Text = 'Print motor positions';

            % Create PrintflipperstatusButton
            app.PrintflipperstatusButton = uibutton(app.UIFigure, 'push');
            app.PrintflipperstatusButton.ButtonPushedFcn = createCallbackFcn(app, @PrintflipperstatusButtonPushed, true);
            app.PrintflipperstatusButton.Position = [342 474 112 23];
            app.PrintflipperstatusButton.Text = 'Print flipper status';

            % Create E320Panel
            app.E320Panel = uipanel(app.UIFigure);
            app.E320Panel.Title = 'E320';
            app.E320Panel.Position = [957 405 107 96];

            % Create MOMAGND2SwitchLabel
            app.MOMAGND2SwitchLabel = uilabel(app.E320Panel);
            app.MOMAGND2SwitchLabel.HorizontalAlignment = 'center';
            app.MOMAGND2SwitchLabel.Position = [9.5 46 82 22];
            app.MOMAGND2SwitchLabel.Text = 'MO MAG ND2';

            % Create MOMAGND2Switch
            app.MOMAGND2Switch = uiswitch(app.E320Panel, 'slider');
            app.MOMAGND2Switch.Items = {'In', 'Out'};
            app.MOMAGND2Switch.ValueChangedFcn = createCallbackFcn(app, @MOMAGND2SwitchValueChanged, true);
            app.MOMAGND2Switch.Position = [27 15 45 20];
            app.MOMAGND2Switch.Value = 'In';

            % Create LaserenergyPanel
            app.LaserenergyPanel = uipanel(app.UIFigure);
            app.LaserenergyPanel.Title = 'Laser energy';
            app.LaserenergyPanel.Position = [30 65 550 245];

            % Create LaserattenuatorPanel
            app.LaserattenuatorPanel = uipanel(app.LaserenergyPanel);
            app.LaserattenuatorPanel.Title = 'Laser attenuator';
            app.LaserattenuatorPanel.Position = [12 9 124 207];

            % Create SetEditFieldLabel
            app.SetEditFieldLabel = uilabel(app.LaserattenuatorPanel);
            app.SetEditFieldLabel.HorizontalAlignment = 'right';
            app.SetEditFieldLabel.Position = [23 147 25 22];
            app.SetEditFieldLabel.Text = 'Set';

            % Create SetLaserEditField
            app.SetLaserEditField = uieditfield(app.LaserattenuatorPanel, 'numeric');
            app.SetLaserEditField.Limits = [70 122];
            app.SetLaserEditField.ValueChangedFcn = createCallbackFcn(app, @SetLaserEditFieldValueChanged, true);
            app.SetLaserEditField.Position = [62 147 52 22];
            app.SetLaserEditField.Value = 74;

            % Create Max119Label
            app.Max119Label = uilabel(app.LaserattenuatorPanel);
            app.Max119Label.Position = [20 80 55 22];
            app.Max119Label.Text = 'Max: 119';

            % Create Min74Label
            app.Min74Label = uilabel(app.LaserattenuatorPanel);
            app.Min74Label.Position = [20 59 45 22];
            app.Min74Label.Text = 'Min: 74';

            % Create LaserRBVLabel
            app.LaserRBVLabel = uilabel(app.LaserattenuatorPanel);
            app.LaserRBVLabel.Position = [21 117 85 22];
            app.LaserRBVLabel.Text = 'RBV: ';

            % Create MinimumenergyButton
            app.MinimumenergyButton = uibutton(app.LaserattenuatorPanel, 'push');
            app.MinimumenergyButton.ButtonPushedFcn = createCallbackFcn(app, @MinimumenergyButtonPushed, true);
            app.MinimumenergyButton.Position = [12 28 106 23];
            app.MinimumenergyButton.Text = 'Minimum energy';

            % Create ProbeattenuatorPanel
            app.ProbeattenuatorPanel = uipanel(app.LaserenergyPanel);
            app.ProbeattenuatorPanel.Title = 'Probe attenuator';
            app.ProbeattenuatorPanel.Position = [147 9 124 207];

            % Create SetEditField_2Label
            app.SetEditField_2Label = uilabel(app.ProbeattenuatorPanel);
            app.SetEditField_2Label.HorizontalAlignment = 'right';
            app.SetEditField_2Label.Position = [23 147 25 22];
            app.SetEditField_2Label.Text = 'Set';

            % Create SetProbeEditField
            app.SetProbeEditField = uieditfield(app.ProbeattenuatorPanel, 'numeric');
            app.SetProbeEditField.Limits = [34 85];
            app.SetProbeEditField.ValueChangedFcn = createCallbackFcn(app, @SetProbeEditFieldValueChanged, true);
            app.SetProbeEditField.Position = [62 147 52 22];
            app.SetProbeEditField.Value = 37;

            % Create Max82Label
            app.Max82Label = uilabel(app.ProbeattenuatorPanel);
            app.Max82Label.Position = [20 80 48 22];
            app.Max82Label.Text = 'Max: 82';

            % Create Min37Label
            app.Min37Label = uilabel(app.ProbeattenuatorPanel);
            app.Min37Label.Position = [20 59 45 22];
            app.Min37Label.Text = 'Min: 37';

            % Create ProbeRBVLabel
            app.ProbeRBVLabel = uilabel(app.ProbeattenuatorPanel);
            app.ProbeRBVLabel.Position = [21 117 85 22];
            app.ProbeRBVLabel.Text = 'RBV: ';

            % Create LaseraperturePanel
            app.LaseraperturePanel = uipanel(app.LaserenergyPanel);
            app.LaseraperturePanel.Title = 'Laser aperture';
            app.LaseraperturePanel.Position = [282 9 124 207];

            % Create SetEditField_2Label_3
            app.SetEditField_2Label_3 = uilabel(app.LaseraperturePanel);
            app.SetEditField_2Label_3.HorizontalAlignment = 'right';
            app.SetEditField_2Label_3.Position = [23 147 25 22];
            app.SetEditField_2Label_3.Text = 'Set';

            % Create SetLIrisEditField
            app.SetLIrisEditField = uieditfield(app.LaseraperturePanel, 'numeric');
            app.SetLIrisEditField.Limits = [-60 -5];
            app.SetLIrisEditField.ValueChangedFcn = createCallbackFcn(app, @SetLIrisEditFieldValueChanged, true);
            app.SetLIrisEditField.Position = [62 147 52 22];
            app.SetLIrisEditField.Value = -40;

            % Create mmmin5Label
            app.mmmin5Label = uilabel(app.LaseraperturePanel);
            app.mmmin5Label.Position = [14 80 89 22];
            app.mmmin5Label.Text = '5 mm (min) : -5 ';

            % Create mm40Label
            app.mm40Label = uilabel(app.LaseraperturePanel);
            app.mm40Label.Position = [14 59 66 22];
            app.mm40Label.Text = '40 mm: -40';

            % Create LIrisRBVLabel
            app.LIrisRBVLabel = uilabel(app.LaseraperturePanel);
            app.LIrisRBVLabel.Position = [21 117 85 22];
            app.LIrisRBVLabel.Text = 'RBV: ';

            % Create mmmax60Label
            app.mmmax60Label = uilabel(app.LaseraperturePanel);
            app.mmmax60Label.Position = [14 37 100 22];
            app.mmmax60Label.Text = '60 mm (max): -60';

            % Create LaserpolarizationPanel
            app.LaserpolarizationPanel = uipanel(app.LaserenergyPanel);
            app.LaserpolarizationPanel.Title = 'Laser polarization';
            app.LaserpolarizationPanel.Position = [416 9 124 207];

            % Create SetEditField_2Label_2
            app.SetEditField_2Label_2 = uilabel(app.LaserpolarizationPanel);
            app.SetEditField_2Label_2.HorizontalAlignment = 'right';
            app.SetEditField_2Label_2.Position = [23 147 25 22];
            app.SetEditField_2Label_2.Text = 'Set';

            % Create SetLPolEditField
            app.SetLPolEditField = uieditfield(app.LaserpolarizationPanel, 'numeric');
            app.SetLPolEditField.Limits = [47 98];
            app.SetLPolEditField.ValueChangedFcn = createCallbackFcn(app, @SetLPolEditFieldValueChanged, true);
            app.SetLPolEditField.Position = [62 147 52 22];
            app.SetLPolEditField.Value = 50;

            % Create SpolPulsed50Label
            app.SpolPulsed50Label = uilabel(app.LaserpolarizationPanel);
            app.SpolPulsed50Label.Position = [14 80 109 22];
            app.SpolPulsed50Label.Text = 'S-pol (Pulsed) : 50 ';

            % Create PpolCW95Label
            app.PpolCW95Label = uilabel(app.LaserpolarizationPanel);
            app.PpolCW95Label.Position = [20 59 85 22];
            app.PpolCW95Label.Text = 'P-pol (CW): 95';

            % Create LPolRBVLabel
            app.LPolRBVLabel = uilabel(app.LaserpolarizationPanel);
            app.LPolRBVLabel.Position = [21 117 85 22];
            app.LPolRBVLabel.Text = 'RBV: ';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_LCP_exported

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