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
        IOnDelayLabel                   matlab.ui.control.Label
        IonDelayEditField               matlab.ui.control.NumericEditField
        IonDelayLimitLabel              matlab.ui.control.Label
        ElectroniclaserdelayPanel       matlab.ui.container.Panel
        SetEditField_2Label_5           matlab.ui.control.Label
        SetMDLEditField_2               matlab.ui.control.NumericEditField
        Overlaparound1256nsLabel        matlab.ui.control.Label
        MDLRBVLabel_2                   matlab.ui.control.Label
        IonDelayRBV                     matlab.ui.control.Label
        LaserTimingRBVLabel             matlab.ui.control.Label
        LaserTimingSetLabel             matlab.ui.control.Label
        ShadDelayLabel                  matlab.ui.control.Label
        ShadDelayEditField              matlab.ui.control.NumericEditField
        ShadDelayLimitLabel             matlab.ui.control.Label
        ShadDelayRBV                    matlab.ui.control.Label
        E324DelayLabel                  matlab.ui.control.Label
        E324DelayEditField              matlab.ui.control.NumericEditField
        E324DelayLimitLabel             matlab.ui.control.Label
        E324DelayRBV                    matlab.ui.control.Label
        MDLLabel                        matlab.ui.control.Label
        MDLEditField                    matlab.ui.control.NumericEditField
        MDLLimitLabel                   matlab.ui.control.Label
        MDLRBV                          matlab.ui.control.Label
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
        UpdateGUINotupdatingautomaticallyButton  matlab.ui.control.Button
        LasershuttersPanel              matlab.ui.container.Panel
        HeNeflipperSwitchLabel          matlab.ui.control.Label
        HeNeflipperSwitch               matlab.ui.control.Switch
        CWlaserSwitchLabel              matlab.ui.control.Label
        CWlaserSwitch                   matlab.ui.control.Switch
        EPSShutterSwitchLabel           matlab.ui.control.Label
        EPSShutterSwitch                matlab.ui.control.Switch
        IPOTR1Panel                     matlab.ui.container.Panel
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
        MOMAGND3SwitchLabel             matlab.ui.control.Label
        MOMAGND3Switch                  matlab.ui.control.Switch
        MOMAGND2SwitchLabel             matlab.ui.control.Label
        MOMAGND2Switch                  matlab.ui.control.Switch
        LaserenergyPanel                matlab.ui.container.Panel
        LaserAttenuatorRBV              matlab.ui.control.Label
        LaserAttenuatorLabel            matlab.ui.control.Label
        LaserAttenuatorEditField        matlab.ui.control.NumericEditField
        LaserAttenuatorLimitLabel       matlab.ui.control.Label
        MinimumenergyButton             matlab.ui.control.Button
        ProbeAttenuatorLimitLabel       matlab.ui.control.Label
        MinimumenergyButton_2           matlab.ui.control.Button
        ProbeAttenuatorRBV              matlab.ui.control.Label
        ProbeAttenuatorLabel            matlab.ui.control.Label
        ProbeAttenuatorEditField        matlab.ui.control.NumericEditField
        LIrisLimitLabel                 matlab.ui.control.Label
        LIrisRBVLabel                   matlab.ui.control.Label
        LIrisRBV                        matlab.ui.control.Label
        LaserIrisLabel                  matlab.ui.control.Label
        LIrisEditField                  matlab.ui.control.NumericEditField
        LPolLimitLabel                  matlab.ui.control.Label
        LPolRBVLabel                    matlab.ui.control.Label
        LPolRBV                         matlab.ui.control.Label
        LaserPolarizationLabel          matlab.ui.control.Label
        LPolEditField                   matlab.ui.control.NumericEditField
        EnergysettingEditFieldLabel     matlab.ui.control.Label
        EnergysettingEditField          matlab.ui.control.NumericEditField
        GoButton                        matlab.ui.control.Button
        LensmountPanel                  matlab.ui.container.Panel
        LensLongLabel                   matlab.ui.control.Label
        LensLongEditField               matlab.ui.control.NumericEditField
        LensLongLimitLabel              matlab.ui.control.Label
        LensRBVLabel                    matlab.ui.control.Label
        LensSetLabel                    matlab.ui.control.Label
        LensVertLabel                   matlab.ui.control.Label
        LensVertEditField               matlab.ui.control.NumericEditField
        LensVertLimitLabel              matlab.ui.control.Label
        LensHorLabel                    matlab.ui.control.Label
        LensHorEditField                matlab.ui.control.NumericEditField
        LensHorLimitLabel               matlab.ui.control.Label
        LensLongRBV                     matlab.ui.control.Label
        LensVertRBV                     matlab.ui.control.Label
        LensHorRBV                      matlab.ui.control.Label
        TargetmountPanel                matlab.ui.container.Panel
        TargetVertLabel                 matlab.ui.control.Label
        TargetVertEditField             matlab.ui.control.NumericEditField
        TargetVertLimitLabel            matlab.ui.control.Label
        TargetVertRBV                   matlab.ui.control.Label
        TargetRBVLabel                  matlab.ui.control.Label
        TargetSetLabel                  matlab.ui.control.Label
        TargetHorLabel                  matlab.ui.control.Label
        TargetHorEditField              matlab.ui.control.NumericEditField
        TargetHorLimitLabel             matlab.ui.control.Label
        TargetHorRBV                    matlab.ui.control.Label
        GasJetLongLabel                 matlab.ui.control.Label
        GasJetLongEditField             matlab.ui.control.NumericEditField
        GasJetLongLimitLabel            matlab.ui.control.Label
        GasJetLongRBV                   matlab.ui.control.Label
        USHMPBM2Panel                   matlab.ui.container.Panel
        USHMRBV                         matlab.ui.control.Label
        USHMLabel                       matlab.ui.control.Label
        USHMEditField                   matlab.ui.control.NumericEditField
        USHMLimitLabel                  matlab.ui.control.Label
        USHMPBM2RBVLabel                matlab.ui.control.Label
        USHMPBM2SetLabel                matlab.ui.control.Label
        VacuumGratingLabel              matlab.ui.control.Label
        VacuumGratingEditField          matlab.ui.control.NumericEditField
        VacuumGratingLimitLabel         matlab.ui.control.Label
        VacuumGratingRBV                matlab.ui.control.Label
        EOSPanel                        matlab.ui.container.Panel
        EOSRot1Label                    matlab.ui.control.Label
        EOSRot1EditField                matlab.ui.control.NumericEditField
        EOSRot1LimitLabel               matlab.ui.control.Label
        EOSRot1RBV                      matlab.ui.control.Label
        EOSRBVLabel                     matlab.ui.control.Label
        EOSSetLabel                     matlab.ui.control.Label
        EOSND2SwitchLabel               matlab.ui.control.Label
        EOSND2Switch                    matlab.ui.control.Switch
        EOSRot2Label                    matlab.ui.control.Label
        EOSRot2EditField                matlab.ui.control.NumericEditField
        EOSRot2LimitLabel               matlab.ui.control.Label
        EOSRot2RBV                      matlab.ui.control.Label
        EOSRot3Label                    matlab.ui.control.Label
        EOSRot3EditField                matlab.ui.control.NumericEditField
        EOSRot3LimitLabel               matlab.ui.control.Label
        EOSRot3RBV                      matlab.ui.control.Label
        EOSRot4Label                    matlab.ui.control.Label
        EOSRot4EditField                matlab.ui.control.NumericEditField
        EOSRot4LimitLabel               matlab.ui.control.Label
        EOSRot4RBV                      matlab.ui.control.Label
        EOSAssemblyLabel                matlab.ui.control.Label
        EOSAssemblyEditField            matlab.ui.control.NumericEditField
        EOSAssemblyLimitLabel           matlab.ui.control.Label
        EOSAssemblyRBV                  matlab.ui.control.Label
        EOSCrystalSpacingLabel          matlab.ui.control.Label
        EOSCrystalSpacingEditField      matlab.ui.control.NumericEditField
        EOSCrystalSpacingLimitLabel     matlab.ui.control.Label
        EOSCrystalSpacingRBV            matlab.ui.control.Label
        EOSCam1Label                    matlab.ui.control.Label
        EOSCam1EditField                matlab.ui.control.NumericEditField
        EOSCam1LimitLabel               matlab.ui.control.Label
        EOSCam1RBV                      matlab.ui.control.Label
        EOSCam2Label                    matlab.ui.control.Label
        EOSCam2EditField                matlab.ui.control.NumericEditField
        EOSCam2LimitLabel               matlab.ui.control.Label
        EOSCam2RBV                      matlab.ui.control.Label
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
            app.LCP.updateGUImotor('LaserAttenuator');
            
            % Probe attenuator
            app.LCP.updateGUImotor('ProbeAttenuator');
            
            % Laser polarization
            app.LCP.updateGUImotor('LPol');
            
            % Laser iris
            app.LCP.updateGUImotor('LIris');
            
            %Target mount
            app.LCP.updateGUImotor('TargetVert');
            app.LCP.updateGUImotor('TargetHor');
            app.LCP.updateGUImotor('GasJetLong');
            
            % Lens mount
            app.LCP.updateGUImotor('LensLong');
            app.LCP.updateGUImotor('LensHor');
            app.LCP.updateGUImotor('LensVert');
            
            % Delay lines
            app.LCP.updateGUImotor('MDL');
            app.LCP.updateGUImotor('IonDelay');
            app.LCP.updateGUImotor('ShadDelay');
            app.LCP.updateGUImotor('E324Delay');
            
            % USHM
            app.LCP.updateGUImotor('USHM');
            % Vacuum grating
            app.LCP.updateGUImotor('VacuumGrating');
            
            % EOS
            app.LCP.updateGUImotor('EOSRot1');
            app.LCP.updateGUImotor('EOSRot2');
            app.LCP.updateGUImotor('EOSRot3');
            app.LCP.updateGUImotor('EOSRot4');
            app.LCP.updateGUImotor('EOSAssembly');
            app.LCP.updateGUImotor('EOSCam2');
            app.LCP.updateGUImotor('EOSCam1');
            app.LCP.updateGUImotor('EOSCrystalSpacing');
        end
        
        function setFlipperStatus(app)
            %CW Shutter
            app.CWlaserSwitch.Value = app.LCP.blockList.CWIR.getState();
            
            %HeNe Shutter
            app.HeNeflipperSwitch.Value = app.LCP.blockList.HeNe.getState();
            
            %Compressor block
            %app.CompressorBeamBlockSwitch.Value = app.LCP.blockList.Comp.getState();
            
            %EPSShutter 
            app.EPSShutterSwitch.Value = app.LCP.blockList.EPSShutter.getState();
            
            %Probeline0
            app.Probeline0HeNeSwitch.Value = app.LCP.filterList.Probeline0HeNe.getState();
            
            %Probe block
            app.ProbelineSwitch.Value = app.LCP.blockList.probeBlock.getState();
            
            %EOS
            app.EOSND2Switch.Value = app.LCP.filterList.EOSND2.getState();
            
            %E320
            app.MOMAGND3Switch.Value = app.LCP.filterList.E320MOMAG.getState();
            app.MOMAGND2Switch.Value  = app.LCP.filterList.E320MOMAG2.getState();
            
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

        % Button pushed function: 
        % UpdateGUINotupdatingautomaticallyButton
        function UpdateGUINotupdatingautomaticallyButtonPushed(app, event)
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

        % Value changed function: LaserAttenuatorEditField
        function LaserAttenuatorEditFieldValueChanged(app, event)
            value = app.LaserAttenuatorEditField.Value;
            app.LCP.SMotorList.LaserAttenuator.move(value);
            app.updateGUI();
        end

        % Value changed function: ProbeAttenuatorEditField
        function ProbeAttenuatorEditFieldValueChanged(app, event)
            value = app.ProbeAttenuatorEditField.Value;
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

        % Value changed function: MOMAGND2Switch
        function MOMAGND2SwitchValueChanged(app, event)
            app.LCP.filterList.E320MOMAG2.flip();
            app.updateGUI();
        end

        % Value changed function: CompressorBeamBlockSwitch
        function CompressorBeamBlockSwitchValueChanged(app, event)
            %app.LCP.blockList.Comp.flip();
            %app.updateGUI();
        end

        % Value changed function: MOMAGND3Switch
        function MOMAGND3SwitchValueChanged(app, event)
            app.LCP.filterList.E320MOMAG.flip();
            app.updateGUI();
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            delete(app)
            disp('Remember to uncomment the exit command')
            exit;
        end

        % Value changed function: LPolEditField
        function LPolEditFieldValueChanged(app, event)
            value = app.LPolEditField.Value;
            app.LCP.SMotorList.LPol.move(value);
            app.updateGUI();
        end

        % Value changed function: LIrisEditField
        function LIrisEditFieldValueChanged(app, event)
            value = app.LIrisEditField.Value;
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

        % Callback function
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

        % Value changed function: MDLEditField
        function MDLEditFieldValueChanged(app, event)
            value = app.MDLEditField.Value;
            app.LCP.SMotorList.MDL.move(value);
            app.updateGUI();
        end

        % Button pushed function: MinimumenergyButton_2
        function MinimumenergyButton_2Pushed(app, event)
            app.LCP.SMotorList.ProbeAttenuator.move(37);
            app.updateGUI();
        end

        % Value changed function: TargetVertEditField
        function TargetVertEditFieldValueChanged(app, event)
            value = app.TargetVertEditField.Value;
            app.LCP.SMotorList.TargetVert.move(value);
            app.updateGUI();
        end

        % Value changed function: TargetHorEditField
        function TargetHorEditFieldValueChanged(app, event)
            value = app.TargetHorEditField.Value;
            app.LCP.SMotorList.TargetHor.move(value);
            app.updateGUI();
        end

        % Value changed function: GasJetLongEditField
        function GasJetLongEditFieldValueChanged(app, event)
            value = app.GasJetLongEditField.Value;
            app.LCP.SMotorList.GasJetLong.move(value);
            app.updateGUI();
        end

        % Button pushed function: GoButton
        function GoButtonPushed(app, event)
            value = app.EnergysettingEditField.Value;
            app.LCP.SMotorList.LaserAttenuator.move(value);
            app.updateGUI();
        end

        % Value changed function: LensLongEditField
        function LensLongEditFieldValueChanged(app, event)
            value = app.LensLongEditField.Value;
            app.LCP.SMotorList.LensLong.move(value);
            app.updateGUI();
        end

        % Value changed function: LensVertEditField
        function LensVertEditFieldValueChanged(app, event)
            value = app.LensVertEditField.Value;
            app.LCP.SMotorList.LensVert.move(value);
            app.updateGUI();
        end

        % Value changed function: LensHorEditField
        function LensHorEditFieldValueChanged(app, event)
            value = app.LensHorEditField.Value;
            app.LCP.SMotorList.LensHor.move(value);
            app.updateGUI();
        end

        % Value changed function: USHMEditField
        function USHMEditFieldValueChanged(app, event)
            value = app.USHMEditField.Value;
            app.LCP.SMotorList.USHM.move(value);
            app.updateGUI();
        end

        % Value changed function: VacuumGratingEditField
        function VacuumGratingEditFieldValueChanged(app, event)
            value = app.VacuumGratingEditField.Value;
            app.LCP.SMotorList.VacuumGrating.move(value);
            app.updateGUI();
        end

        % Value changed function: IonDelayEditField
        function IonDelayEditFieldValueChanged(app, event)
            value = app.IonDelayEditField.Value;
            app.LCP.SMotorList.IonDelay.move(value);
            app.updateGUI();
        end

        % Value changed function: ShadDelayEditField
        function ShadDelayEditFieldValueChanged(app, event)
            value = app.ShadDelayEditField.Value;
            app.LCP.SMotorList.ShadDelay.move(value);
            app.updateGUI();
        end

        % Value changed function: E324DelayEditField
        function E324DelayEditFieldValueChanged(app, event)
            value = app.E324DelayEditField.Value;
            app.LCP.SMotorList.E324Delay.move(value);
            app.updateGUI();
        end

        % Value changed function: EOSAssemblyEditField
        function EOSAssemblyEditFieldValueChanged(app, event)
            value = app.EOSAssemblyEditField.Value;
            app.LCP.SMotorList.EOSAssembly.move(value);
            app.updateGUI();
        end

        % Value changed function: EOSCrystalSpacingEditField
        function EOSCrystalSpacingEditFieldValueChanged(app, event)
            value = app.EOSCrystalSpacingEditField.Value;
            app.LCP.SMotorList.EOSCrystalSpacing.move(value);
            app.updateGUI();
        end

        % Value changed function: EOSRot3EditField
        function EOSRot3EditFieldValueChanged(app, event)
            value = app.EOSRot3EditField.Value;
            app.LCP.SMotorList.EOSRot3.move(value);
            app.updateGUI();
        end

        % Value changed function: EOSCam1EditField
        function EOSCam1EditFieldValueChanged(app, event)
            value = app.EOSCam1EditField.Value;
            app.LCP.SMotorList.EOSCam1.move(value);
            app.updateGUI();
        end

        % Value changed function: EOSRot4EditField
        function EOSRot4EditFieldValueChanged(app, event)
            value = app.EOSRot4EditField.Value;
            app.LCP.SMotorList.EOSRot4.move(value);
            app.updateGUI();
        end

        % Value changed function: EOSCam2EditField
        function EOSCam2EditFieldValueChanged(app, event)
            value = app.EOSCam2EditField.Value;
            app.LCP.SMotorList.EOSCam2.move(value);
            app.updateGUI();
        end

        % Value changed function: EOSRot1EditField
        function EOSRot1EditFieldValueChanged(app, event)
            value = app.EOSRot1EditField.Value;
            app.LCP.SMotorList.EOSRot1.move(value);
            app.updateGUI();
        end

        % Value changed function: EOSRot2EditField
        function EOSRot2EditFieldValueChanged(app, event)
            value = app.EOSRot2EditField.Value;
            app.LCP.SMotorList.EOSRot2.move(value);
            app.updateGUI();
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1432 760];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create ProbeflippersPanel
            app.ProbeflippersPanel = uipanel(app.UIFigure);
            app.ProbeflippersPanel.Title = 'Probe flippers';
            app.ProbeflippersPanel.Position = [741 543 140 192];

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
            app.MainflippersPanel.Position = [181 484 125 251];

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
            app.CompressorBeamBlockSwitchLabel.Enable = 'off';
            app.CompressorBeamBlockSwitchLabel.Position = [22 184 75 30];
            app.CompressorBeamBlockSwitchLabel.Text = {'Compressor '; 'Beam Block'};

            % Create CompressorBeamBlockSwitch
            app.CompressorBeamBlockSwitch = uiswitch(app.MainflippersPanel, 'slider');
            app.CompressorBeamBlockSwitch.Items = {'In', 'Out'};
            app.CompressorBeamBlockSwitch.ValueChangedFcn = createCallbackFcn(app, @CompressorBeamBlockSwitchValueChanged, true);
            app.CompressorBeamBlockSwitch.Enable = 'off';
            app.CompressorBeamBlockSwitch.Position = [35 161 45 20];
            app.CompressorBeamBlockSwitch.Value = 'In';

            % Create LasertimingPanel
            app.LasertimingPanel = uipanel(app.UIFigure);
            app.LasertimingPanel.Title = 'Laser timing ';
            app.LasertimingPanel.Position = [881 22 254 364];

            % Create IOnDelayLabel
            app.IOnDelayLabel = uilabel(app.LasertimingPanel);
            app.IOnDelayLabel.HorizontalAlignment = 'right';
            app.IOnDelayLabel.Position = [55 226 42 22];
            app.IOnDelayLabel.Text = 'Ionizer';

            % Create IonDelayEditField
            app.IonDelayEditField = uieditfield(app.LasertimingPanel, 'numeric');
            app.IonDelayEditField.ValueChangedFcn = createCallbackFcn(app, @IonDelayEditFieldValueChanged, true);
            app.IonDelayEditField.Position = [112 226 59 22];

            % Create IonDelayLimitLabel
            app.IonDelayLimitLabel = uilabel(app.LasertimingPanel);
            app.IonDelayLimitLabel.Position = [73 201 112 22];
            app.IonDelayLimitLabel.Text = 'Limits: Long:  Short:';

            % Create ElectroniclaserdelayPanel
            app.ElectroniclaserdelayPanel = uipanel(app.LasertimingPanel);
            app.ElectroniclaserdelayPanel.Title = 'Electronic laser delay';
            app.ElectroniclaserdelayPanel.Position = [33 5 201 87];

            % Create SetEditField_2Label_5
            app.SetEditField_2Label_5 = uilabel(app.ElectroniclaserdelayPanel);
            app.SetEditField_2Label_5.HorizontalAlignment = 'right';
            app.SetEditField_2Label_5.Enable = 'off';
            app.SetEditField_2Label_5.Position = [7 36 25 22];
            app.SetEditField_2Label_5.Text = 'Set';

            % Create SetMDLEditField_2
            app.SetMDLEditField_2 = uieditfield(app.ElectroniclaserdelayPanel, 'numeric');
            app.SetMDLEditField_2.Limits = [-74 76];
            app.SetMDLEditField_2.Enable = 'off';
            app.SetMDLEditField_2.Position = [46 36 52 22];

            % Create Overlaparound1256nsLabel
            app.Overlaparound1256nsLabel = uilabel(app.ElectroniclaserdelayPanel);
            app.Overlaparound1256nsLabel.Position = [13 7 161 18];
            app.Overlaparound1256nsLabel.Text = 'Overlap around 1256 ns';

            % Create MDLRBVLabel_2
            app.MDLRBVLabel_2 = uilabel(app.ElectroniclaserdelayPanel);
            app.MDLRBVLabel_2.Position = [105 37 85 22];
            app.MDLRBVLabel_2.Text = 'RBV: ';

            % Create IonDelayRBV
            app.IonDelayRBV = uilabel(app.LasertimingPanel);
            app.IonDelayRBV.Position = [193 225 36 22];

            % Create LaserTimingRBVLabel
            app.LaserTimingRBVLabel = uilabel(app.LasertimingPanel);
            app.LaserTimingRBVLabel.Position = [196 316 30 22];
            app.LaserTimingRBVLabel.Text = 'RBV';

            % Create LaserTimingSetLabel
            app.LaserTimingSetLabel = uilabel(app.LasertimingPanel);
            app.LaserTimingSetLabel.Position = [129 316 25 22];
            app.LaserTimingSetLabel.Text = 'Set';

            % Create ShadDelayLabel
            app.ShadDelayLabel = uilabel(app.LasertimingPanel);
            app.ShadDelayLabel.HorizontalAlignment = 'right';
            app.ShadDelayLabel.Position = [9 174 88 22];
            app.ShadDelayLabel.Text = 'Shadowgraphy';

            % Create ShadDelayEditField
            app.ShadDelayEditField = uieditfield(app.LasertimingPanel, 'numeric');
            app.ShadDelayEditField.ValueChangedFcn = createCallbackFcn(app, @ShadDelayEditFieldValueChanged, true);
            app.ShadDelayEditField.Position = [112 174 59 22];

            % Create ShadDelayLimitLabel
            app.ShadDelayLimitLabel = uilabel(app.LasertimingPanel);
            app.ShadDelayLimitLabel.Position = [73 149 112 22];
            app.ShadDelayLimitLabel.Text = 'Limits: Long: Short: ';

            % Create ShadDelayRBV
            app.ShadDelayRBV = uilabel(app.LasertimingPanel);
            app.ShadDelayRBV.Position = [193 173 36 22];

            % Create E324DelayLabel
            app.E324DelayLabel = uilabel(app.LasertimingPanel);
            app.E324DelayLabel.HorizontalAlignment = 'right';
            app.E324DelayLabel.Position = [63 124 34 22];
            app.E324DelayLabel.Text = 'E324';

            % Create E324DelayEditField
            app.E324DelayEditField = uieditfield(app.LasertimingPanel, 'numeric');
            app.E324DelayEditField.ValueChangedFcn = createCallbackFcn(app, @E324DelayEditFieldValueChanged, true);
            app.E324DelayEditField.Position = [112 124 59 22];

            % Create E324DelayLimitLabel
            app.E324DelayLimitLabel = uilabel(app.LasertimingPanel);
            app.E324DelayLimitLabel.Position = [24 98 147 22];
            app.E324DelayLimitLabel.Text = 'Limits: Long: -74 Short: 76';

            % Create E324DelayRBV
            app.E324DelayRBV = uilabel(app.LasertimingPanel);
            app.E324DelayRBV.Position = [193 123 36 22];

            % Create MDLLabel
            app.MDLLabel = uilabel(app.LasertimingPanel);
            app.MDLLabel.HorizontalAlignment = 'right';
            app.MDLLabel.Position = [19 278 78 22];
            app.MDLLabel.Text = 'Master (EOS)';

            % Create MDLEditField
            app.MDLEditField = uieditfield(app.LasertimingPanel, 'numeric');
            app.MDLEditField.ValueChangedFcn = createCallbackFcn(app, @MDLEditFieldValueChanged, true);
            app.MDLEditField.Position = [112 278 59 22];

            % Create MDLLimitLabel
            app.MDLLimitLabel = uilabel(app.LasertimingPanel);
            app.MDLLimitLabel.Position = [19 253 147 22];
            app.MDLLimitLabel.Text = 'Limits: Long: -74 Short: 76';

            % Create MDLRBV
            app.MDLRBV = uilabel(app.LasertimingPanel);
            app.MDLRBV.Position = [193 277 36 22];

            % Create IonizerPanel
            app.IonizerPanel = uipanel(app.UIFigure);
            app.IonizerPanel.Title = 'Ionizer';
            app.IonizerPanel.Position = [1046 556 107 179];

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
            app.ShadowgraphyPanel.Position = [893 485 136 250];

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

            % Create UpdateGUINotupdatingautomaticallyButton
            app.UpdateGUINotupdatingautomaticallyButton = uibutton(app.UIFigure, 'push');
            app.UpdateGUINotupdatingautomaticallyButton.ButtonPushedFcn = createCallbackFcn(app, @UpdateGUINotupdatingautomaticallyButtonPushed, true);
            app.UpdateGUINotupdatingautomaticallyButton.BackgroundColor = [0 1 0];
            app.UpdateGUINotupdatingautomaticallyButton.Position = [36 32 124 63];
            app.UpdateGUINotupdatingautomaticallyButton.Text = {'Update GUI'; 'Not updating'; 'automatically'};

            % Create LasershuttersPanel
            app.LasershuttersPanel = uipanel(app.UIFigure);
            app.LasershuttersPanel.Title = 'Laser shutters';
            app.LasershuttersPanel.Position = [30 481 139 254];

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
            app.IPOTR1Panel.Position = [31 207 133 188];

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
            app.IPOTR2Panel.Position = [180 167 118 254];

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
            app.PrintmotorpositionsButton.Position = [166 443 126 23];
            app.PrintmotorpositionsButton.Text = 'Print motor positions';

            % Create PrintflipperstatusButton
            app.PrintflipperstatusButton = uibutton(app.UIFigure, 'push');
            app.PrintflipperstatusButton.ButtonPushedFcn = createCallbackFcn(app, @PrintflipperstatusButtonPushed, true);
            app.PrintflipperstatusButton.Position = [38 443 112 23];
            app.PrintflipperstatusButton.Text = 'Print flipper status';

            % Create E320Panel
            app.E320Panel = uipanel(app.UIFigure);
            app.E320Panel.Title = 'E320';
            app.E320Panel.Position = [626 543 107 190];

            % Create MOMAGND3SwitchLabel
            app.MOMAGND3SwitchLabel = uilabel(app.E320Panel);
            app.MOMAGND3SwitchLabel.HorizontalAlignment = 'center';
            app.MOMAGND3SwitchLabel.Position = [10 140 82 22];
            app.MOMAGND3SwitchLabel.Text = 'MO MAG ND3';

            % Create MOMAGND3Switch
            app.MOMAGND3Switch = uiswitch(app.E320Panel, 'slider');
            app.MOMAGND3Switch.Items = {'In', 'Out'};
            app.MOMAGND3Switch.ValueChangedFcn = createCallbackFcn(app, @MOMAGND3SwitchValueChanged, true);
            app.MOMAGND3Switch.Position = [27 109 45 20];
            app.MOMAGND3Switch.Value = 'In';

            % Create MOMAGND2SwitchLabel
            app.MOMAGND2SwitchLabel = uilabel(app.E320Panel);
            app.MOMAGND2SwitchLabel.HorizontalAlignment = 'center';
            app.MOMAGND2SwitchLabel.Position = [11 66 82 22];
            app.MOMAGND2SwitchLabel.Text = 'MO MAG ND2';

            % Create MOMAGND2Switch
            app.MOMAGND2Switch = uiswitch(app.E320Panel, 'slider');
            app.MOMAGND2Switch.Items = {'In', 'Out'};
            app.MOMAGND2Switch.ValueChangedFcn = createCallbackFcn(app, @MOMAGND2SwitchValueChanged, true);
            app.MOMAGND2Switch.Position = [28 35 45 20];
            app.MOMAGND2Switch.Value = 'In';

            % Create LaserenergyPanel
            app.LaserenergyPanel = uipanel(app.UIFigure);
            app.LaserenergyPanel.Title = 'Laser energy';
            app.LaserenergyPanel.Position = [599 25 266 361];

            % Create LaserAttenuatorRBV
            app.LaserAttenuatorRBV = uilabel(app.LaserenergyPanel);
            app.LaserAttenuatorRBV.Position = [206 279 42 22];
            app.LaserAttenuatorRBV.Text = 'RBV: ';

            % Create LaserAttenuatorLabel
            app.LaserAttenuatorLabel = uilabel(app.LaserenergyPanel);
            app.LaserAttenuatorLabel.HorizontalAlignment = 'right';
            app.LaserAttenuatorLabel.Position = [27 279 92 22];
            app.LaserAttenuatorLabel.Text = 'LaserAttenuator';

            % Create LaserAttenuatorEditField
            app.LaserAttenuatorEditField = uieditfield(app.LaserenergyPanel, 'numeric');
            app.LaserAttenuatorEditField.Limits = [70 122];
            app.LaserAttenuatorEditField.ValueChangedFcn = createCallbackFcn(app, @LaserAttenuatorEditFieldValueChanged, true);
            app.LaserAttenuatorEditField.Position = [133 279 52 22];
            app.LaserAttenuatorEditField.Value = 74;

            % Create LaserAttenuatorLimitLabel
            app.LaserAttenuatorLimitLabel = uilabel(app.LaserenergyPanel);
            app.LaserAttenuatorLimitLabel.Position = [24 252 98 22];
            app.LaserAttenuatorLimitLabel.Text = 'Max: 119 Min: 74';

            % Create MinimumenergyButton
            app.MinimumenergyButton = uibutton(app.LaserenergyPanel, 'push');
            app.MinimumenergyButton.ButtonPushedFcn = createCallbackFcn(app, @MinimumenergyButtonPushed, true);
            app.MinimumenergyButton.Position = [133 251 106 23];
            app.MinimumenergyButton.Text = 'Minimum energy';

            % Create ProbeAttenuatorLimitLabel
            app.ProbeAttenuatorLimitLabel = uilabel(app.LaserenergyPanel);
            app.ProbeAttenuatorLimitLabel.Position = [22 129 91 22];
            app.ProbeAttenuatorLimitLabel.Text = 'Max: 82 Min: 37';

            % Create MinimumenergyButton_2
            app.MinimumenergyButton_2 = uibutton(app.LaserenergyPanel, 'push');
            app.MinimumenergyButton_2.ButtonPushedFcn = createCallbackFcn(app, @MinimumenergyButton_2Pushed, true);
            app.MinimumenergyButton_2.Position = [124 129 106 23];
            app.MinimumenergyButton_2.Text = 'Minimum energy';

            % Create ProbeAttenuatorRBV
            app.ProbeAttenuatorRBV = uilabel(app.LaserenergyPanel);
            app.ProbeAttenuatorRBV.Position = [197 157 42 22];
            app.ProbeAttenuatorRBV.Text = 'RBV: ';

            % Create ProbeAttenuatorLabel
            app.ProbeAttenuatorLabel = uilabel(app.LaserenergyPanel);
            app.ProbeAttenuatorLabel.HorizontalAlignment = 'right';
            app.ProbeAttenuatorLabel.Position = [16 157 94 22];
            app.ProbeAttenuatorLabel.Text = 'ProbeAttenuator';

            % Create ProbeAttenuatorEditField
            app.ProbeAttenuatorEditField = uieditfield(app.LaserenergyPanel, 'numeric');
            app.ProbeAttenuatorEditField.Limits = [34 85];
            app.ProbeAttenuatorEditField.ValueChangedFcn = createCallbackFcn(app, @ProbeAttenuatorEditFieldValueChanged, true);
            app.ProbeAttenuatorEditField.Position = [124 157 52 22];
            app.ProbeAttenuatorEditField.Value = 37;

            % Create LIrisLimitLabel
            app.LIrisLimitLabel = uilabel(app.LaserenergyPanel);
            app.LIrisLimitLabel.Position = [31 73 191 22];
            app.LIrisLimitLabel.Text = '5 mm (min) : -5, 60 mm (max): -60 ';

            % Create LIrisRBVLabel
            app.LIrisRBVLabel = uilabel(app.LaserenergyPanel);
            app.LIrisRBVLabel.Position = [153 313 39 22];
            app.LIrisRBVLabel.Text = 'Set';

            % Create LIrisRBV
            app.LIrisRBV = uilabel(app.LaserenergyPanel);
            app.LIrisRBV.Position = [192 100 42 22];
            app.LIrisRBV.Text = 'RBV: ';

            % Create LaserIrisLabel
            app.LaserIrisLabel = uilabel(app.LaserenergyPanel);
            app.LaserIrisLabel.HorizontalAlignment = 'right';
            app.LaserIrisLabel.Position = [50 100 55 22];
            app.LaserIrisLabel.Text = 'Laser Iris';

            % Create LIrisEditField
            app.LIrisEditField = uieditfield(app.LaserenergyPanel, 'numeric');
            app.LIrisEditField.Limits = [-60 -5];
            app.LIrisEditField.ValueChangedFcn = createCallbackFcn(app, @LIrisEditFieldValueChanged, true);
            app.LIrisEditField.Position = [119 100 52 22];
            app.LIrisEditField.Value = -40;

            % Create LPolLimitLabel
            app.LPolLimitLabel = uilabel(app.LaserenergyPanel);
            app.LPolLimitLabel.Position = [36 12 196 22];
            app.LPolLimitLabel.Text = 'S-pol (Pulsed) : 50, P-pol (CW): 95 ';

            % Create LPolRBVLabel
            app.LPolRBVLabel = uilabel(app.LaserenergyPanel);
            app.LPolRBVLabel.Position = [209 313 39 22];
            app.LPolRBVLabel.Text = 'RBV';

            % Create LPolRBV
            app.LPolRBV = uilabel(app.LaserenergyPanel);
            app.LPolRBV.Position = [203 42 42 22];
            app.LPolRBV.Text = 'RBV: ';

            % Create LaserPolarizationLabel
            app.LaserPolarizationLabel = uilabel(app.LaserenergyPanel);
            app.LaserPolarizationLabel.HorizontalAlignment = 'right';
            app.LaserPolarizationLabel.Position = [12 42 104 22];
            app.LaserPolarizationLabel.Text = 'Laser Polarization';

            % Create LPolEditField
            app.LPolEditField = uieditfield(app.LaserenergyPanel, 'numeric');
            app.LPolEditField.Limits = [47 98];
            app.LPolEditField.ValueChangedFcn = createCallbackFcn(app, @LPolEditFieldValueChanged, true);
            app.LPolEditField.Position = [130 42 52 22];
            app.LPolEditField.Value = 50;

            % Create EnergysettingEditFieldLabel
            app.EnergysettingEditFieldLabel = uilabel(app.LaserenergyPanel);
            app.EnergysettingEditFieldLabel.HorizontalAlignment = 'right';
            app.EnergysettingEditFieldLabel.Position = [35 222 83 22];
            app.EnergysettingEditFieldLabel.Text = 'Energy setting';

            % Create EnergysettingEditField
            app.EnergysettingEditField = uieditfield(app.LaserenergyPanel, 'numeric');
            app.EnergysettingEditField.Limits = [70 122];
            app.EnergysettingEditField.Position = [132 222 52 22];
            app.EnergysettingEditField.Value = 74;

            % Create GoButton
            app.GoButton = uibutton(app.LaserenergyPanel, 'push');
            app.GoButton.ButtonPushedFcn = createCallbackFcn(app, @GoButtonPushed, true);
            app.GoButton.Position = [190 222 44 23];
            app.GoButton.Text = 'Go';

            % Create LensmountPanel
            app.LensmountPanel = uipanel(app.UIFigure);
            app.LensmountPanel.Title = 'Lens mount';
            app.LensmountPanel.Position = [1159 259 249 230];

            % Create LensLongLabel
            app.LensLongLabel = uilabel(app.LensmountPanel);
            app.LensLongLabel.HorizontalAlignment = 'right';
            app.LensLongLabel.Position = [8 151 83 22];
            app.LensLongLabel.Text = 'Longitudinal Z';

            % Create LensLongEditField
            app.LensLongEditField = uieditfield(app.LensmountPanel, 'numeric');
            app.LensLongEditField.ValueChangedFcn = createCallbackFcn(app, @LensLongEditFieldValueChanged, true);
            app.LensLongEditField.Position = [106 151 58 22];

            % Create LensLongLimitLabel
            app.LensLongLimitLabel = uilabel(app.LensmountPanel);
            app.LensLongLimitLabel.Position = [109 126 40 22];
            app.LensLongLimitLabel.Text = 'Limits:';

            % Create LensRBVLabel
            app.LensRBVLabel = uilabel(app.LensmountPanel);
            app.LensRBVLabel.Position = [194 184 30 22];
            app.LensRBVLabel.Text = 'RBV';

            % Create LensSetLabel
            app.LensSetLabel = uilabel(app.LensmountPanel);
            app.LensSetLabel.Position = [122 184 25 22];
            app.LensSetLabel.Text = 'Set';

            % Create LensVertLabel
            app.LensVertLabel = uilabel(app.LensmountPanel);
            app.LensVertLabel.HorizontalAlignment = 'right';
            app.LensVertLabel.Position = [34 92 57 22];
            app.LensVertLabel.Text = 'Vertical Y';

            % Create LensVertEditField
            app.LensVertEditField = uieditfield(app.LensmountPanel, 'numeric');
            app.LensVertEditField.ValueChangedFcn = createCallbackFcn(app, @LensVertEditFieldValueChanged, true);
            app.LensVertEditField.Position = [106 92 58 22];

            % Create LensVertLimitLabel
            app.LensVertLimitLabel = uilabel(app.LensmountPanel);
            app.LensVertLimitLabel.Position = [34 67 145 22];
            app.LensVertLimitLabel.Text = 'Limits: 0 - 100 (100 is out)';

            % Create LensHorLabel
            app.LensHorLabel = uilabel(app.LensmountPanel);
            app.LensHorLabel.HorizontalAlignment = 'right';
            app.LensHorLabel.Position = [19 37 72 22];
            app.LensHorLabel.Text = 'Horizontal X';

            % Create LensHorEditField
            app.LensHorEditField = uieditfield(app.LensmountPanel, 'numeric');
            app.LensHorEditField.ValueChangedFcn = createCallbackFcn(app, @LensHorEditFieldValueChanged, true);
            app.LensHorEditField.Position = [106 37 58 22];

            % Create LensHorLimitLabel
            app.LensHorLimitLabel = uilabel(app.LensmountPanel);
            app.LensHorLimitLabel.Position = [109 12 40 22];
            app.LensHorLimitLabel.Text = 'Limits:';

            % Create LensLongRBV
            app.LensLongRBV = uilabel(app.LensmountPanel);
            app.LensLongRBV.Position = [190 151 47 22];

            % Create LensVertRBV
            app.LensVertRBV = uilabel(app.LensmountPanel);
            app.LensVertRBV.Position = [191 92 47 22];

            % Create LensHorRBV
            app.LensHorRBV = uilabel(app.LensmountPanel);
            app.LensHorRBV.Position = [191 37 47 22];

            % Create TargetmountPanel
            app.TargetmountPanel = uipanel(app.UIFigure);
            app.TargetmountPanel.Title = 'Target mount';
            app.TargetmountPanel.Position = [1159 505 249 230];

            % Create TargetVertLabel
            app.TargetVertLabel = uilabel(app.TargetmountPanel);
            app.TargetVertLabel.HorizontalAlignment = 'right';
            app.TargetVertLabel.Position = [42 151 49 22];
            app.TargetVertLabel.Text = 'Vertical ';

            % Create TargetVertEditField
            app.TargetVertEditField = uieditfield(app.TargetmountPanel, 'numeric');
            app.TargetVertEditField.ValueChangedFcn = createCallbackFcn(app, @TargetVertEditFieldValueChanged, true);
            app.TargetVertEditField.Position = [106 151 58 22];

            % Create TargetVertLimitLabel
            app.TargetVertLimitLabel = uilabel(app.TargetmountPanel);
            app.TargetVertLimitLabel.Position = [8 126 168 22];
            app.TargetVertLimitLabel.Text = 'Limits: 0 - 100 (negative is up)';

            % Create TargetVertRBV
            app.TargetVertRBV = uilabel(app.TargetmountPanel);
            app.TargetVertRBV.Position = [184 151 51 22];

            % Create TargetRBVLabel
            app.TargetRBVLabel = uilabel(app.TargetmountPanel);
            app.TargetRBVLabel.Position = [194 184 30 22];
            app.TargetRBVLabel.Text = 'RBV';

            % Create TargetSetLabel
            app.TargetSetLabel = uilabel(app.TargetmountPanel);
            app.TargetSetLabel.Position = [122 184 25 22];
            app.TargetSetLabel.Text = 'Set';

            % Create TargetHorLabel
            app.TargetHorLabel = uilabel(app.TargetmountPanel);
            app.TargetHorLabel.HorizontalAlignment = 'right';
            app.TargetHorLabel.Position = [27 92 64 22];
            app.TargetHorLabel.Text = 'Horizontal ';

            % Create TargetHorEditField
            app.TargetHorEditField = uieditfield(app.TargetmountPanel, 'numeric');
            app.TargetHorEditField.ValueChangedFcn = createCallbackFcn(app, @TargetHorEditFieldValueChanged, true);
            app.TargetHorEditField.Position = [106 92 58 22];

            % Create TargetHorLimitLabel
            app.TargetHorLimitLabel = uilabel(app.TargetmountPanel);
            app.TargetHorLimitLabel.Position = [34 67 96 22];
            app.TargetHorLimitLabel.Text = 'Limits: 0 - (-150) ';

            % Create TargetHorRBV
            app.TargetHorRBV = uilabel(app.TargetmountPanel);
            app.TargetHorRBV.Position = [184 92 51 22];

            % Create GasJetLongLabel
            app.GasJetLongLabel = uilabel(app.TargetmountPanel);
            app.GasJetLongLabel.HorizontalAlignment = 'right';
            app.GasJetLongLabel.Position = [18 37 73 22];
            app.GasJetLongLabel.Text = 'Longitudinal';

            % Create GasJetLongEditField
            app.GasJetLongEditField = uieditfield(app.TargetmountPanel, 'numeric');
            app.GasJetLongEditField.ValueChangedFcn = createCallbackFcn(app, @GasJetLongEditFieldValueChanged, true);
            app.GasJetLongEditField.Position = [106 37 58 22];

            % Create GasJetLongLimitLabel
            app.GasJetLongLimitLabel = uilabel(app.TargetmountPanel);
            app.GasJetLongLimitLabel.Position = [34 13 74 22];
            app.GasJetLongLimitLabel.Text = 'Limits: 0 - 22';

            % Create GasJetLongRBV
            app.GasJetLongRBV = uilabel(app.TargetmountPanel);
            app.GasJetLongRBV.Position = [184 37 51 22];

            % Create USHMPBM2Panel
            app.USHMPBM2Panel = uipanel(app.UIFigure);
            app.USHMPBM2Panel.Title = 'USHM PB M2';
            app.USHMPBM2Panel.Position = [1159 24 251 218];

            % Create USHMRBV
            app.USHMRBV = uilabel(app.USHMPBM2Panel);
            app.USHMRBV.Position = [187 143 51 22];

            % Create USHMLabel
            app.USHMLabel = uilabel(app.USHMPBM2Panel);
            app.USHMLabel.HorizontalAlignment = 'right';
            app.USHMLabel.Position = [53 143 41 22];
            app.USHMLabel.Text = 'USHM';

            % Create USHMEditField
            app.USHMEditField = uieditfield(app.USHMPBM2Panel, 'numeric');
            app.USHMEditField.ValueChangedFcn = createCallbackFcn(app, @USHMEditFieldValueChanged, true);
            app.USHMEditField.Position = [109 143 58 22];

            % Create USHMLimitLabel
            app.USHMLimitLabel = uilabel(app.USHMPBM2Panel);
            app.USHMLimitLabel.Position = [11 118 155 22];
            app.USHMLimitLabel.Text = 'Limits: 0 - 50 (o in, 42.5 out)';

            % Create USHMPBM2RBVLabel
            app.USHMPBM2RBVLabel = uilabel(app.USHMPBM2Panel);
            app.USHMPBM2RBVLabel.Position = [194 171 30 22];
            app.USHMPBM2RBVLabel.Text = 'RBV';

            % Create USHMPBM2SetLabel
            app.USHMPBM2SetLabel = uilabel(app.USHMPBM2Panel);
            app.USHMPBM2SetLabel.Position = [122 171 25 22];
            app.USHMPBM2SetLabel.Text = 'Set';

            % Create VacuumGratingLabel
            app.VacuumGratingLabel = uilabel(app.USHMPBM2Panel);
            app.VacuumGratingLabel.HorizontalAlignment = 'right';
            app.VacuumGratingLabel.Position = [-1 86 96 22];
            app.VacuumGratingLabel.Text = 'Vacuum Grating ';

            % Create VacuumGratingEditField
            app.VacuumGratingEditField = uieditfield(app.USHMPBM2Panel, 'numeric');
            app.VacuumGratingEditField.ValueChangedFcn = createCallbackFcn(app, @VacuumGratingEditFieldValueChanged, true);
            app.VacuumGratingEditField.Position = [110 86 58 22];

            % Create VacuumGratingLimitLabel
            app.VacuumGratingLimitLabel = uilabel(app.USHMPBM2Panel);
            app.VacuumGratingLimitLabel.Position = [12 61 155 22];
            app.VacuumGratingLimitLabel.Text = 'Limits: 0 - 50 (o in, 42.5 out)';

            % Create VacuumGratingRBV
            app.VacuumGratingRBV = uilabel(app.USHMPBM2Panel);
            app.VacuumGratingRBV.Position = [188 86 51 22];

            % Create EOSPanel
            app.EOSPanel = uipanel(app.UIFigure);
            app.EOSPanel.Title = 'EOS';
            app.EOSPanel.Position = [322 124 249 611];

            % Create EOSRot1Label
            app.EOSRot1Label = uilabel(app.EOSPanel);
            app.EOSRot1Label.HorizontalAlignment = 'right';
            app.EOSRot1Label.Position = [36 171 53 30];
            app.EOSRot1Label.Text = {'Ingoing '; 'polarizer'};

            % Create EOSRot1EditField
            app.EOSRot1EditField = uieditfield(app.EOSPanel, 'numeric');
            app.EOSRot1EditField.ValueChangedFcn = createCallbackFcn(app, @EOSRot1EditFieldValueChanged, true);
            app.EOSRot1EditField.Position = [104 179 58 22];

            % Create EOSRot1LimitLabel
            app.EOSRot1LimitLabel = uilabel(app.EOSPanel);
            app.EOSRot1LimitLabel.Position = [107 154 50 22];
            app.EOSRot1LimitLabel.Text = 'Max:';

            % Create EOSRot1RBV
            app.EOSRot1RBV = uilabel(app.EOSPanel);
            app.EOSRot1RBV.Position = [188 179 47 22];

            % Create EOSRBVLabel
            app.EOSRBVLabel = uilabel(app.EOSPanel);
            app.EOSRBVLabel.Position = [194 565 30 22];
            app.EOSRBVLabel.Text = 'RBV';

            % Create EOSSetLabel
            app.EOSSetLabel = uilabel(app.EOSPanel);
            app.EOSSetLabel.Position = [122 565 25 22];
            app.EOSSetLabel.Text = 'Set';

            % Create EOSND2SwitchLabel
            app.EOSND2SwitchLabel = uilabel(app.EOSPanel);
            app.EOSND2SwitchLabel.HorizontalAlignment = 'center';
            app.EOSND2SwitchLabel.Position = [156 54 58 22];
            app.EOSND2SwitchLabel.Text = 'EOS ND2';

            % Create EOSND2Switch
            app.EOSND2Switch = uiswitch(app.EOSPanel, 'slider');
            app.EOSND2Switch.Items = {'In', 'Out'};
            app.EOSND2Switch.ValueChangedFcn = createCallbackFcn(app, @EOSND2SwitchValueChanged, true);
            app.EOSND2Switch.Position = [162 23 45 20];
            app.EOSND2Switch.Value = 'In';

            % Create EOSRot2Label
            app.EOSRot2Label = uilabel(app.EOSPanel);
            app.EOSRot2Label.HorizontalAlignment = 'right';
            app.EOSRot2Label.Enable = 'off';
            app.EOSRot2Label.Position = [26 123 63 22];
            app.EOSRot2Label.Text = 'Waveplate';

            % Create EOSRot2EditField
            app.EOSRot2EditField = uieditfield(app.EOSPanel, 'numeric');
            app.EOSRot2EditField.ValueChangedFcn = createCallbackFcn(app, @EOSRot2EditFieldValueChanged, true);
            app.EOSRot2EditField.Enable = 'off';
            app.EOSRot2EditField.Position = [104 123 58 22];

            % Create EOSRot2LimitLabel
            app.EOSRot2LimitLabel = uilabel(app.EOSPanel);
            app.EOSRot2LimitLabel.Enable = 'off';
            app.EOSRot2LimitLabel.Position = [107 98 50 22];
            app.EOSRot2LimitLabel.Text = 'Max:';

            % Create EOSRot2RBV
            app.EOSRot2RBV = uilabel(app.EOSPanel);
            app.EOSRot2RBV.Enable = 'off';
            app.EOSRot2RBV.Position = [188 123 47 22];

            % Create EOSRot3Label
            app.EOSRot3Label = uilabel(app.EOSPanel);
            app.EOSRot3Label.HorizontalAlignment = 'right';
            app.EOSRot3Label.Position = [32 416 57 22];
            app.EOSRot3Label.Text = 'EOS1 pol';

            % Create EOSRot3EditField
            app.EOSRot3EditField = uieditfield(app.EOSPanel, 'numeric');
            app.EOSRot3EditField.ValueChangedFcn = createCallbackFcn(app, @EOSRot3EditFieldValueChanged, true);
            app.EOSRot3EditField.Position = [104 416 58 22];

            % Create EOSRot3LimitLabel
            app.EOSRot3LimitLabel = uilabel(app.EOSPanel);
            app.EOSRot3LimitLabel.Position = [69 390 91 22];
            app.EOSRot3LimitLabel.Text = 'Max: 38, Min 73';

            % Create EOSRot3RBV
            app.EOSRot3RBV = uilabel(app.EOSPanel);
            app.EOSRot3RBV.Position = [188 416 47 22];

            % Create EOSRot4Label
            app.EOSRot4Label = uilabel(app.EOSPanel);
            app.EOSRot4Label.HorizontalAlignment = 'right';
            app.EOSRot4Label.Position = [32 296 57 22];
            app.EOSRot4Label.Text = 'EOS2 pol';

            % Create EOSRot4EditField
            app.EOSRot4EditField = uieditfield(app.EOSPanel, 'numeric');
            app.EOSRot4EditField.ValueChangedFcn = createCallbackFcn(app, @EOSRot4EditFieldValueChanged, true);
            app.EOSRot4EditField.Position = [104 296 58 22];

            % Create EOSRot4LimitLabel
            app.EOSRot4LimitLabel = uilabel(app.EOSPanel);
            app.EOSRot4LimitLabel.Position = [107 271 50 22];
            app.EOSRot4LimitLabel.Text = 'Max:';

            % Create EOSRot4RBV
            app.EOSRot4RBV = uilabel(app.EOSPanel);
            app.EOSRot4RBV.Position = [188 296 47 22];

            % Create EOSAssemblyLabel
            app.EOSAssemblyLabel = uilabel(app.EOSPanel);
            app.EOSAssemblyLabel.HorizontalAlignment = 'right';
            app.EOSAssemblyLabel.Position = [28 537 61 22];
            app.EOSAssemblyLabel.Text = 'Assembly ';

            % Create EOSAssemblyEditField
            app.EOSAssemblyEditField = uieditfield(app.EOSPanel, 'numeric');
            app.EOSAssemblyEditField.ValueChangedFcn = createCallbackFcn(app, @EOSAssemblyEditFieldValueChanged, true);
            app.EOSAssemblyEditField.Position = [104 537 58 22];

            % Create EOSAssemblyLimitLabel
            app.EOSAssemblyLimitLabel = uilabel(app.EOSPanel);
            app.EOSAssemblyLimitLabel.Position = [72 512 90 22];
            app.EOSAssemblyLimitLabel.Text = 'Out: 50, In: 8.35';

            % Create EOSAssemblyRBV
            app.EOSAssemblyRBV = uilabel(app.EOSPanel);
            app.EOSAssemblyRBV.Position = [188 537 47 22];

            % Create EOSCrystalSpacingLabel
            app.EOSCrystalSpacingLabel = uilabel(app.EOSPanel);
            app.EOSCrystalSpacingLabel.HorizontalAlignment = 'right';
            app.EOSCrystalSpacingLabel.Position = [39 473 50 30];
            app.EOSCrystalSpacingLabel.Text = {'Crystal'; 'Spacing'};

            % Create EOSCrystalSpacingEditField
            app.EOSCrystalSpacingEditField = uieditfield(app.EOSPanel, 'numeric');
            app.EOSCrystalSpacingEditField.ValueChangedFcn = createCallbackFcn(app, @EOSCrystalSpacingEditFieldValueChanged, true);
            app.EOSCrystalSpacingEditField.Position = [104 481 58 22];

            % Create EOSCrystalSpacingLimitLabel
            app.EOSCrystalSpacingLimitLabel = uilabel(app.EOSPanel);
            app.EOSCrystalSpacingLimitLabel.Position = [107 456 50 22];
            app.EOSCrystalSpacingLimitLabel.Text = 'Max:';

            % Create EOSCrystalSpacingRBV
            app.EOSCrystalSpacingRBV = uilabel(app.EOSPanel);
            app.EOSCrystalSpacingRBV.Position = [188 481 47 22];

            % Create EOSCam1Label
            app.EOSCam1Label = uilabel(app.EOSPanel);
            app.EOSCam1Label.HorizontalAlignment = 'right';
            app.EOSCam1Label.Enable = 'off';
            app.EOSCam1Label.Position = [27 355 62 30];
            app.EOSCam1Label.Text = {'EOS1 '; 'translation'};

            % Create EOSCam1EditField
            app.EOSCam1EditField = uieditfield(app.EOSPanel, 'numeric');
            app.EOSCam1EditField.ValueChangedFcn = createCallbackFcn(app, @EOSCam1EditFieldValueChanged, true);
            app.EOSCam1EditField.Enable = 'off';
            app.EOSCam1EditField.Position = [104 363 58 22];

            % Create EOSCam1LimitLabel
            app.EOSCam1LimitLabel = uilabel(app.EOSPanel);
            app.EOSCam1LimitLabel.Enable = 'off';
            app.EOSCam1LimitLabel.Position = [107 338 50 22];
            app.EOSCam1LimitLabel.Text = 'Max:';

            % Create EOSCam1RBV
            app.EOSCam1RBV = uilabel(app.EOSPanel);
            app.EOSCam1RBV.Position = [188 363 47 22];

            % Create EOSCam2Label
            app.EOSCam2Label = uilabel(app.EOSPanel);
            app.EOSCam2Label.HorizontalAlignment = 'right';
            app.EOSCam2Label.Enable = 'off';
            app.EOSCam2Label.Position = [27 231 62 30];
            app.EOSCam2Label.Text = {'EOS2'; 'translation'};

            % Create EOSCam2EditField
            app.EOSCam2EditField = uieditfield(app.EOSPanel, 'numeric');
            app.EOSCam2EditField.ValueChangedFcn = createCallbackFcn(app, @EOSCam2EditFieldValueChanged, true);
            app.EOSCam2EditField.Enable = 'off';
            app.EOSCam2EditField.Position = [104 239 58 22];

            % Create EOSCam2LimitLabel
            app.EOSCam2LimitLabel = uilabel(app.EOSPanel);
            app.EOSCam2LimitLabel.Enable = 'off';
            app.EOSCam2LimitLabel.Position = [107 214 50 22];
            app.EOSCam2LimitLabel.Text = 'Max:';

            % Create EOSCam2RBV
            app.EOSCam2RBV = uilabel(app.EOSPanel);
            app.EOSCam2RBV.Position = [188 239 47 22];

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