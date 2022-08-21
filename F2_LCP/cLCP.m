classdef cLCP  < handle
    
    
    properties
        blockList;
        filterList;
        SMotorList;
        
        EPSShutter;
        GUIh;
        
    end
    
    methods
        function s = cLCP(GUIhandle)
            s.GUIh = GUIhandle;
            s.makeFlipperList
            s.makeSMotorList
        end
        
        
        function makeFlipperList(s)
            % MAKEFLIPPERLIST fills flipper list
            
            
            % blocks
            s.blockList.shadowgraphy = cFlipper('APC:LI20:EX02:24VOUT_2',1);
            s.blockList.ionizer = cFlipper('APC:LI20:EX02:24VOUT_3',1);
            s.blockList.probeBlock = cFlipper('APC:LI20:EX02:24VOUT_4',1);
            s.blockList.EPSShutter = cFlipper('DO:LA20:10:Bo1',-1);
            
            s.blockList.CWIR = cStepperFlipper('XPS:LA20:LS24:M5',0,25);
            s.blockList.HeNe = cStepperFlipper('XPS:LA20:LS24:M3',10,8);
            s.blockList.Comp = cStepperFlipper('XPS:LI20:MC03:M3',299,199);
            
            % filters
            s.filterList.EOSND2 = cFlipper('APC:LI20:EX02:24VOUT_19',1);
            s.filterList.ionizerND2 = cFlipper('APC:LI20:EX02:24VOUT_16',1);
            s.filterList.shadow1 = cFlipper('APC:LI20:EX02:24VOUT_15',1);
            s.filterList.shadow2 = cFlipper('APC:LI20:EX02:24VOUT_17',1);
            
            
            s.filterList.Probeline0HeNe = cFlipper('APC:LI20:EX02:24VOUT_7',-1);
            s.filterList.E320MOMAG = cFlipper('APC:LI20:EX02:24VOUT_8',1);
            
            s.filterList.PBNFF = cFlipper('APC:LI20:EX02:24VOUT_1',1);
            s.filterList.CompNFF = cFlipper('APC:LI20:EX02:24VOUT_18',1);
            
            %IPOTRs
            s.filterList.IPOTR2ND9 = cFlipper('APC:LI20:EX02:24VOUT_10',1);
            s.filterList.IPOTR2ND2 = cFlipper('APC:LI20:EX02:24VOUT_6',1);
            s.filterList.IPOTR2Blue = cFlipper('APC:LI20:EX02:24VOUT_5',-1);
            s.filterList.IPOTR1ND9 = cFlipper('APC:LI20:EX02:24VOUT_14',1);
            s.filterList.IPOTR1P = cFlipper('APC:LI20:EX02:24VOUT_13',1);
            
            
            
        end
        
        function makeSMotorList(s)
            % MAKESMOTORLIST fills stepper motor list
            
            % delayStages
            s.SMotorList.MDL = cStepper('XPS:LI20:MC02:M5');
            s.SMotorList.E324Delay = cStepper('XPS:LI20:MC01:M5');
            s.SMotorList.ShadDelay = cStepper('XPS:LI20:MC05:M6');
            s.SMotorList.IonDelay = cStepper('XPS:LI20:MC05:M8');
            
            % Iris
            s.SMotorList.LIris = cStepper('XPS:LA20:LS24:M4');
            
            % Laser energy
            s.SMotorList.LaserAttenuator = cStepper('XPS:LA20:LS24:M1');
            s.SMotorList.LPol = cStepper('XPS:LA20:LS24:M2');
            s.SMotorList.ProbeAttenuator = cStepper('XPS:LI20:MC01:M2');
            
            % Lens 
            s.SMotorList.LensLong = cStepper('XPS:LI20:MC04:M1');
            s.SMotorList.LensVert = cStepper('XPS:LI20:MC04:M2');
            s.SMotorList.LensHor = cStepper('XPS:LI20:MC04:M3');
            
            % Target stage
            s.SMotorList.TargetVert = cStepper('XPS:LI20:MC05:M1');
            s.SMotorList.TargetHor = cStepper('XPS:LI20:MC05:M2');
            s.SMotorList.GasJetLong = cStepper('XPS:LI20:MC05:M3');
            
            %USHM
            s.SMotorList.USHM = cStepper('XPS:LI20:MC03:M1');
            
            % Main compressor grating
            s.SMotorList.VacuumGrating = cStepper('XPS:LI20:MC03:M6');
            
            % Afterglow injector
            s.SMotorList.AfterglowInjector = cStepper('XPS:LI20:MC01:M1');
            
            % EOS
            s.SMotorList.EOSAssembly = cStepper('XPS:LI20:MC04:M4');
            s.SMotorList.EOSCrystalSpacing = cStepper('XPS:LI20:MC04:M5');
            s.SMotorList.EOSRot1 = cStepper('XPS:LI20:MC04:M8');
            s.SMotorList.EOSRot2 = cStepper('XPS:LI20:MC02:M3');
            s.SMotorList.EOSRot3 = cStepper('XPS:LI20:MC02:M8');
            s.SMotorList.EOSRot4 = cStepper('XPS:LI20:MC04:M7');
            s.SMotorList.EOSCam1 = cStepper('XPS:LI20:MC04:M6');
            s.SMotorList.EOSCam2 = cStepper('XPS:LI20:MC02:M4');
            
            % Ionizer
            s.SMotorList.IonImaging = cStepper('XPS:LI20:MC05:M7');
            
            % Shadowgraphy
            s.SMotorList.ShadImaging = cStepper('XPS:LI20:MC02:M1');
            
            
        end
        
         function updateGUImotor(s, motorName)
            RBV = s.SMotorList.(motorName).getRBV();
            s.GUIh.([motorName, 'RBV']).Text = sprintf('%.2f', RBV );
            s.GUIh.([motorName, 'EditField']).Value = RBV;
         end
        
    end
    
    %% Print methods
    methods
        function filterListStr = printFilterList(s)
            filterListStr = s.printList(s.filterList);
        end
        
        function blockListStr = printBlockList(s)
            blockListStr = s.printList(s.blockList);
        end
        
        function SMotorListStr = printSMotorList(s)
            SMotorListStr = s.printList(s.SMotorList);
        end
        
        function listStr = printList(s, structList)
            listStr = '';
            names = fieldnames(structList);
            for k = 1:length(names)
                listStr = strcat(listStr, structList.(names{k}).print());
                listStr = strcat(listStr, ' \n ');
            end
        end
    end
    
        
        
end