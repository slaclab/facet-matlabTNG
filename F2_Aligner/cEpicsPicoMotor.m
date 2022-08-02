classdef cEpicsPicoMotor < handle
    
    properties
        PV
        humanName = '';
        debug = 1; 
        RBVtol = 1e-5 
    end
    
        
    methods (Access = public)
        %Constructor
        function s = cEpicsPicoMotor(picoPV)
            s.PV = picoPV;
        end
    end
    
    methods (Access = public)
        
        function move(s, revs)
            %MOVE(revs)
            % Moves the picomotor revs revolutions
            % Checks that the motor is alive
            % Checks that motor position and RBV are the same
            
            if ~s.isAlive()
                s.logMe(sprintf("Motor %s not responding, won't move\n", s.PV));
                return
            end
            
            RBVVal = s.getRBV();
            targetVal = RBVVal + revs;
            
            s.logMe(sprintf('Starting to move: %s\n',s.PV) )
            
            lcaPutSmart([ s.PV, ':MOTOR'], targetVal);
            
            % wait until move is finished
            while ~ismembertol( RBVVal, targetVal, s.RBVtol)
                RBVVal = lcaGetSmart([ s.PV, ':MOTOR.RBV']);
                pause(.1);
            end
            
            s.logMe(sprintf('Finished moving: %s\n',s.PV));
        end

    end
    
    methods (Access = private)
        
        function logMe(s, text)
            if s.debug 
                fprintf('This is %s:%s \n %s\n', s.humanName, s.PV, text);
            end
        end
        
        function lifeSign = isAlive(s)
            % Check that the picomotor is alive
            motorStatus = lcaGetSmart([s.PV,':MOTOR_TYPE']);
            lifeSign = ~contains(motorStatus{1}, 'No motor');
        end
        
        function RBVVal = getRBV(s)
            % Checks that motor value equals RBV value and sets the motor
            % value to RBV if it is not, return RBV value
            
            RBVVal = lcaGetSmart([ s.PV, ':MOTOR.RBV']);
            setVal = lcaGetSmart([ s.PV, ':MOTOR']);
            
            if ~ismembertol( RBVVal, setVal, s.RBVtol)
                if s.debug, disp('Warning: RBV value not equal to set value\n'), end
                lcaPutSmart([ s.PV, ':MOTOR'], RBVVal);
            end
        end
        
    end
    
end