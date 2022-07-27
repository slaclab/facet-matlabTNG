classdef cStepperFlipper < handle & acFlipper
    %cStepperFlipper handles a block/filter that is driven in and out by a
    %stepper motor and has a set in position and out position
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
        inVal
        outVal
    end
    
    properties (Access = private)
        tol % tolerance level for motor position value to be at position
    end
    
    methods
        function s = cStepperFlipper(PV,inVal, outVal)
            %CSTEPPERFlipper Constructor for stepper
            
            s.PV = PV;
            s.inVal = inVal;
            s.outVal = outVal;
            
            s.tol = 0.01;   % in mm
        end
        
        function sStr = getState(s)
            motorVal = s.getRBV();
            if (abs(motorVal - s.inVal) < s.tol)
                sStr = 'In';
            elseif (abs(motorVal - s.outVal) < s.tol)
                sStr = 'Out';
            else
                sStr = 'Unknown';
            end
        end
        
        function flipIn(s)
            %FLIPIN() Flips the flipper into the laser path
            s.moveStepperMotor(s.inVal);
        end
        
        function flipOut(s)
            %FLIPIN() Flips the flipper into the laser path
            s.moveStepperMotor(s.outVal);
        end
        
        function flip(s)
            %FLIP() Flips the flipper to the opposite state
            % Defaults to in if state is unknown
            stateStr = s.getState();
            if strcmp(stateStr,'In')
                s.flipOut();
            elseif strcmp(stateStr,'Out') || strcmp(stateStr,'Unknown')
                s.flipIn();
            else
                error('3. Something is rotten in the state of Denmark')
            end
        end
        
        function moveStepperMotor(s, target)
            
            lcaPutSmart(s.PV, target);
            motorVal = s.getRBV();
            
            while ~(abs(motorVal - target) < s.tol)
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
        
        function pstr = print(s)
            status = s.getState();
            name = s.getDesc();
            PV = s.PV;
            pstr = sprintf('| %s | %s | %s ', name, PV, status);
        end
        
    end
end
