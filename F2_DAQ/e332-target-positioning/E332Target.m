classdef E332Target < handle
    %E332TARGET Represents the physical E332 target.
    % This class allows to interface the E305 solid target assembly to move
    % the E332 target holes into the beam axis. It allows to use a PV-based
    % coordinate transform where the hole positions have previously been
    % calibrated.
    
    properties
        targetDefinition
        coordinateTransform
        pvEngineCalibration
        pvEngineMotors
        currentPosition
    end

    properties
        pvTargetLat = "XPS:LI20:MC05:M2"
        pvTargetVert = "XPS:LI20:MC05:M1"
        pvTargetLatRbv = "XPS:LI20:MC05:M2.RBV"
        pvTargetVertRbv = "XPS:LI20:MC05:M1.RBV"


        tolerance = 1e-1;
        
        targetOutPosition = [-150, -50];
        al100umPosition = [-130, -20];
    end
    
    methods
        function obj = E332Target(pvEngine, coordinateTransform, targetDefinition)
            %E332TARGET Construct an instance of this class
            arguments
                pvEngine (1,1) PVEngine = PVEngineLca()
                coordinateTransform (1,1) CoordinateTransform = RTSTransform()
                targetDefinition (1,1) TargetDefinition = Target_H15_C1_V10()
            end
            
            obj.targetDefinition = targetDefinition;
            obj.pvEngineCalibration = pvEngine;
            obj.pvEngineMotors = pvEngine;
            obj.coordinateTransform = coordinateTransform;
            
            if obj.coordinateTransform.requiredCalibrationCoordinates > 0
                % Get the calibration points from PVs
                %calPoints = GetCalibration(2, @(x)obj.pvEngineCalibration.get(x));
                calibration = Calibration(obj.pvEngineCalibration);
                calPoints = calibration.getCalibration(obj.coordinateTransform.requiredCalibrationCoordinates);
                
                % Calculate the raw hole positions for the holes in the
                % calibration data
                holes = [calPoints.hole]';
                positionsCal = [calPoints.lat; calPoints.vert]';
                positionsRaw = obj.targetDefinition.getHolePosition(holes);
                
                obj.coordinateTransform.calibrate(positionsRaw, positionsCal);
            end

            currentPosition.hole = 0;
            currentPosition.lat = obj.pvEngineMotors.get(obj.pvTargetLatRbv);
            currentPosition.vert = obj.pvEngineMotors.get(obj.pvTargetVertRbv);
            obj.currentPosition = currentPosition;

        end

        function position = getHolePosition(obj, holeNumber)
            %GETHOLEPOSITION Returns the hole position.
            % Returns the position of hole with specified hole number.
            pointRaw = obj.targetDefinition.getHolePosition(holeNumber);
            point = obj.coordinateTransform.transform(pointRaw);
            position.hole = holeNumber;
            position.lat = point(1);
            position.vert = point(2);
        end
        
        function moveOut(obj)
            % Move the assembly stage
            obj.pvEngineMotors.put(obj.pvTargetLat, obj.targetOutPosition(1));
            obj.pvEngineMotors.put(obj.pvTargetVert, obj.targetOutPosition(2));
        end
        
        function moveToAl100um(obj)
             % Move the assembly stage
            obj.pvEngineMotors.put(obj.pvTargetLat, obj.al100umPosition(1));
            obj.pvEngineMotors.put(obj.pvTargetVert, obj.al100umPosition(2));
        end
        
        function distance = moveToHole(obj, hole, async)
            %MOVETOHOLE Moves the target to specified hole.
            % Moves the target to a specific hole. "hole" can either be the
            % hole number (numeric value) or a string representing the
            % hole (like "G25").
            % The parameter 'async' specifies whether the function waits
            % for the movement to complete (false) or immediately returns
            % (true)
            arguments
                obj
                hole
                async = false
            end
            % If hole is a string, convert it to the hole number.
            if ischar(hole) || isstring(hole)
                holeNumber = obj.targetDefinition.holeNumberFromString(hole);
            else
                holeNumber = hole;
            end

            % Get position of hole
            targetPosition = obj.getHolePosition(holeNumber);
            
            % Move the assembly stage
            obj.pvEngineMotors.put(obj.pvTargetLat, targetPosition.lat);
            obj.pvEngineMotors.put(obj.pvTargetVert, targetPosition.vert);

            % Helper function to calculate the distance between two points
            distance = @(x,y) sqrt((x.lat - y.lat).^2 + (x.vert - y.vert).^2);
            
            if ~async
                % Wait till movement is completed
                positionReached = false;
                %tic
                while(~positionReached)
                    readback.lat = obj.pvEngineMotors.get(obj.pvTargetLatRbv);
                    readback.vert = obj.pvEngineMotors.get(obj.pvTargetVertRbv);
                    if distance(readback, targetPosition) <= obj.tolerance
                        positionReached = true;
                    end
                end
                %toc
            end

            % Set the return value to the distance from previous to current
            % point
            distance = distance(targetPosition, obj.currentPosition);            
            
            % Update the current point
            obj.currentPosition = targetPosition;
        end
    end
end
