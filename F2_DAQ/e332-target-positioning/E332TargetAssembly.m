classdef E332TargetAssembly < handle
    %E332TARGETASSEMBLY Summary of this class goes here
    %   Detailed explanation goes here

    properties
        targets = {}
        targetAreas = {}
        config

        pvEngineCalibration
        pvEngineMotors
        currentPosition

        tolerance = 0.1
    end

    properties(Constant)
        pvTargetLat = "XPS:LI20:MC05:M2"
        pvTargetVert = "XPS:LI20:MC05:M1"
        pvTargetLatRbv = "XPS:LI20:MC05:M2.RBV"
        pvTargetVertRbv = "XPS:LI20:MC05:M1.RBV"
        % pvTargetLat = "SIOC:SYS1:ML03:AO658"
        % pvTargetVert = "SIOC:SYS1:ML03:AO659"
        % pvTargetLatRbv = "SIOC:SYS1:ML03:AO658"
        % pvTargetVertRbv = "SIOC:SYS1:ML03:AO659"
    end

    methods
        function obj = E332TargetAssembly(pvEngineCalibration, pvEngineMotors)
            arguments
                pvEngineCalibration (1,1) PVEngine = PVEngineLca()
                pvEngineMotors (1,1) PVEngine = PVEngineLca()
            end

            obj.pvEngineCalibration = pvEngineCalibration;
            obj.pvEngineMotors = pvEngineMotors;

            obj.config = PVStorage.getConfigurationSection(obj.pvEngineCalibration);
            for i = 1:obj.config.numTargets
                obj.targets{i} = E332Target(i, obj.pvEngineCalibration);
            end
            for i = 1:obj.config.numTargetAreas
                obj.targetAreas{i} = E332TargetArea(i, obj.pvEngineCalibration);
            end

            currentPosition.hole = 0;
            currentPosition.lat = obj.pvEngineMotors.get(obj.pvTargetLatRbv);
            currentPosition.vert = obj.pvEngineMotors.get(obj.pvTargetVertRbv);
            obj.currentPosition = currentPosition;
        end

        function target = target(obj, targetNumber)
            target = obj.targets{targetNumber};
        end
        function targetArea = targetArea(obj, targetAreaNumber)
            targetArea = obj.targetAreas{targetAreaNumber};
        end



        function distance = moveToHole(obj, holeNumber)
            % First, figure out the target area
            targetArea = floor(holeNumber / 1000) + 1;
            targetHoleNumber = mod(holeNumber, 1000);
            % If holeNumber == 0, use the next hole, otherwise go to
            % specified hole
            if (targetHoleNumber == 0)
                % Get current hole number
                targetPosition = obj.targetAreas{targetArea}.getNextHolePosition();
            else
                targetPosition = obj.targetAreas{targetArea}.getHolePosition(mod(targetHoleNumber, 1000));
            end
            obj.targetAreas{targetArea}.setLastHolePosition(targetPosition.hole);


            % Move the assembly stage
            obj.pvEngineMotors.put(obj.pvTargetLat, targetPosition.lat);
            obj.pvEngineMotors.put(obj.pvTargetVert, targetPosition.vert);

            % Helper function to calculate the distance between two points
            distance = @(x,y) sqrt((x.lat - y.lat).^2 + (x.vert - y.vert).^2);

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

            % Set the return value to the distance from previous to current
            % point
            distance = distance(targetPosition, obj.currentPosition);

            % Update the current point
            obj.currentPosition = targetPosition;

            infoSection = PVStorage.getInformationSection(obj.pvEngineCalibration);
            infoSection.currentTarget = obj.targetAreas{targetArea}.parameters.associatedTarget;
            infoSection.currentTargetArea = targetArea;
            infoSection.currentHole = targetPosition.hole;
            infoSection.currentDaqHole = holeNumber;
        end
        function distance = moveToAreaHole(obj, targetArea, holeNumber)
            % If holeNumber == 0, use the next hole, otherwise go to
            % specified hole
            if (holeNumber == 0)
                % Get current hole number
                targetPosition = obj.targetAreas{targetArea}.getNextHolePosition();
            else
                targetPosition = obj.targetAreas{targetArea}.getHolePosition(mod(holeNumber, 1000));
            end
            obj.targetAreas{targetArea}.setLastHolePosition(targetPosition.hole);
            % Move the assembly stage
            obj.pvEngineMotors.put(obj.pvTargetLat, targetPosition.lat);
            obj.pvEngineMotors.put(obj.pvTargetVert, targetPosition.vert);
        end

        function moveToTargetHole(obj, targetNumber, holeString)
            targetPosition = obj.targets{targetNumber}.getHolePosition(holeString);

            % Move the assembly stage
            obj.pvEngineMotors.put(obj.pvTargetLat, targetPosition.lat);
            obj.pvEngineMotors.put(obj.pvTargetVert, targetPosition.vert);
        end


        function moveOut(obj)
            obj.pvEngineMotors.put(obj.pvTargetLat, obj.config.targetIdlePositionLat);
            obj.pvEngineMotors.put(obj.pvTargetVert, obj.config.targetIdlePositionVert);
        end

        function moveToAl(obj)
            obj.pvEngineMotors.put(obj.pvTargetLat, obj.config.targetAlPositionLat);
            obj.pvEngineMotors.put(obj.pvTargetVert, obj.config.targetAlPositionVert);
        end
    end
end

