classdef cLCP  < handle
    
    
    properties
        blockList;
        filterList;
        SMotorList;
        
        EPSShutter;
        
    end
    
    methods
        function s = cLCP(GUIhandle)
            s.makeFlipperList
            s.makeSMotorList
        end
        
        
        function makeFlipperList(s)
            %MAKEFLIPPERLIST fills flipper list
            
            
            % blocks
            s.blockList.shadowgraphy = cFlipper('APC:LI20:EX02:24VOUT_2',1);
            s.blockList.ionizer = cFlipper('APC:LI20:EX02:24VOUT_3',1);
            s.blockList.E324block = cFlipper('APC:LI20:EX02:24VOUT_4',1);
            s.blockList.EPSShutter = cFlipper('DO:LA20:10:Bo1',-1);
            
            s.blockList.CWIR = cStepperFlipper('XPS:LA20:LS24:M5',0,25);
            s.blockList.HeNe = cStepperFlipper('XPS:LA20:LS24:M3',10,8);
            
            % filters
            s.filterList.EOSND2 = cFlipper('APC:LI20:EX02:24VOUT_19',1);
            s.filterList.ionizerND2 = cFlipper('APC:LI20:EX02:24VOUT_16',1);
            s.filterList.shadow1 = cFlipper('APC:LI20:EX02:24VOUT_15',1);
            s.filterList.shadow2 = cFlipper('APC:LI20:EX02:24VOUT_17',1);
            
            
            s.filterList.Probeline0HeNe = cFlipper('APC:LI20:EX02:24VOUT_7',-1);
            
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
            %MAKESMOTORLIST fills stepper motor list
            
            %delayStages
            %s.SMotorList.EOSDelay = 
            s.SMotorList.LaserAttenuator = cStepper('XPS:LA20:LS24:M1');
            s.SMotorList.ProbeAttenuator = cStepper('XPS:LI20:MC01:M2');
            
        end
    end
        
        
end