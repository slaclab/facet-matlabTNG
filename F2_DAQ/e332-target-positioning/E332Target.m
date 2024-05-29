classdef E332Target < handle
    %E332TARGET Represents the physical E332 target.
    % This class allows to interface the E305 solid target assembly to move
    % the E332 target holes into the beam axis. It allows to use a PV-based
    % coordinate transform where the hole positions have previously been
    % calibrated.
    
    properties
        targetDefinition
        coordinateTransform
    end

    properties
        tolerance = 1e-1;
        
        pvsTargetOut = ["SIOC:SYS1:ML03:AO653", "SIOC:SYS1:ML03:AO654"];
        pvsAl100Position = ["SIOC:SYS1:ML03:AO655", "SIOC:SYS1:ML03:AO656"];
    end
    
    methods
        function obj = E332Target(targetNumber, pvEngine, coordinateTransform)
            arguments
                targetNumber (1,1) {mustBeNumeric} = 1;
                pvEngine (1,1) PVEngine = PVEngineLca()
                coordinateTransform (1,1) CoordinateTransform = RTSTransform()
            end
           
            configData = PVStorage.getConfigurationSection(pvEngine);
            offsetLat = configData.targetGlobalOffsetLat;
            offsetVert = configData.targetGlobalOffsetVert;
            targetData = PVStorage.getTargetSection(pvEngine, targetNumber);

            obj.targetDefinition = TargetDefinition.targetTypeByNumber(targetData.type);
            obj.coordinateTransform = coordinateTransform;
            
            holes = [targetData.point1Hole, targetData.point2Hole]';
            positionsCal = [[targetData.point1Lat + offsetLat, targetData.point2Lat + offsetLat]; [targetData.point1Vert + offsetVert, targetData.point2Vert + offsetVert]]';
            positionsRaw = obj.targetDefinition.getHolePosition(holes);
            
            obj.coordinateTransform.calibrate(positionsRaw, positionsCal);
        end

        function position = getHolePosition(obj, hole)
            if ischar(hole) || isstring(hole)
                holeNumber = obj.targetDefinition.holeNumberFromString(hole);
            else
                holeNumber = hole;
            end

            pointRaw = obj.targetDefinition.getHolePosition(holeNumber);
            point = obj.coordinateTransform.transform(pointRaw);
            position.hole = holeNumber;
            position.lat = point(1);
            position.vert = point(2);
        end

        function numHoles = getNumberOfHoles(obj)
            numHoles = obj.targetDefinition.getNumberOfHoles();
        end
    end
end

