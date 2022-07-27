classdef cStepper < handle
    %cStepper handles epics stepper motors
    %   
    %  CONSTRUCTOR: 
    %       cStepper(PV):
    %       PV is the motor PV string, e.g. ''
    %       
    %
    %  FUNCTIONS:
    %      flipIn():
    %           Flips the flipper into the beam path
    %
    %
    
    properties
        PV
        
    end
    
    methods
        function s = cStepper(PV)
            %CSTEPPER Constructor for stepper
            
            s.PV = PV;
        end
        
        function move(s, target)
            
            lcaPutSmart(s.PV, target);
            motorVal = s.getRBV();
            
            while ~(abs(motorVal - target) < 0.01)
                motorVal = s.getRBV();
            end
            
        end
        
        function motorVal = getRBV(s)
            motorVal = lcaGetSmart([s.PV,'.RBV']);
        end
        
        function desc = getDesc(s)
            desc = lcaGetSmart([s.PV,'.DESC']);
            desc = desc{1};
        end
        
        function printstr = print(s)
            RBV = s.getRBV();
            motordesc = s.getDesc();
            motorname = s.PV();
            printstr = sprintf('| %s | %s | %.2f', motordesc, motorname, RBV);
        end
        
    end
end

