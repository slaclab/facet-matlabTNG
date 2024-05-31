classdef E332TargetArea < handle
    %E332TARGETAREA Summary of this class goes here
    %   Detailed explanation goes here

    properties
        target
        parameters
        pvEngine
        targetAreaNumber
    end

    methods
        function obj = E332TargetArea(targetAreaNumber, pvEngine)
            %E332TARGET Construct an instance of this class
            arguments
                targetAreaNumber (1,1) {mustBeNumeric} = 1;
                pvEngine (1,1) PVEngine = PVEngineLca()
            end
            obj.pvEngine = pvEngine;

            % Get target parameters from PV's
            obj.parameters = PVStorage.getTargetAreaSection(pvEngine, targetAreaNumber);
            obj.targetAreaNumber = targetAreaNumber;

            obj.target = E332Target(obj.parameters.associatedTarget, pvEngine);
        end

        function position = getHolePosition(obj, holeNumber)
            rows = obj.parameters.point2Row - obj.parameters.point1Row + 1;
            cols = obj.parameters.point2Col - obj.parameters.point1Col + 1;

            row = mod(holeNumber - 1, rows);
            col = floor((holeNumber - 1) / rows);

            if (mod(col, 2) == 1)
                row = rows - 1 - row;
            end

            col = col + obj.parameters.point1Col;
            row = row + obj.parameters.point1Row + 1;

            targetHoleNumber = obj.target.targetDefinition.holeNumberFromRowCol(row, col);
            targetPosition = obj.target.getHolePosition(targetHoleNumber);

            position.hole = holeNumber;
            position.lat = targetPosition.lat;
            position.vert = targetPosition.vert;
            position.targetHole = targetHoleNumber;
        end

        function position = getNextHolePosition(obj)
            targetAreaSection = PVStorage.getTargetAreaSection(obj.pvEngine, obj.targetAreaNumber);
            holeNumber = targetAreaSection.lastHole + 1;
            position = obj.getHolePosition(holeNumber);
        end

        function setLastHolePosition(obj, holeNumber)
            targetAreaSection = PVStorage.getTargetAreaSection(obj.pvEngine, obj.targetAreaNumber);
            targetAreaSection.lastHole = holeNumber;
            PVStorage.setTargetAreaSection(obj.pvEngine, obj.targetAreaNumber, targetAreaSection);
        end

        function position = getCurrentHolePosition(obj)
            targetAreaSection = PVStorage.getTargetAreaSection(obj.pvEngine, obj.targetAreaNumber);
            holeNumber = targetAreaSection.lastHole;
            position = obj.getHolePosition(holeNumber);
        end

        function setCurrentHolePosition(obj, holeNumber)
            targetAreaSection = PVStorage.getTargetAreaSection(obj.pvEngine, obj.targetAreaNumber);
            targetAreaSection.lastHole = holeNumber;
            PVStorage.setTargetAreaSection(obj.pvEngine, obj.targetAreaNumber, targetAreaSection);
        end

        function numHoles = getNumberOfHoles(obj)
            rows = obj.parameters.point2Row - obj.parameters.point1Row + 1;
            cols = obj.parameters.point2Col - obj.parameters.point1Col + 1;
            numHoles = rows * cols;
        end
    end
end

