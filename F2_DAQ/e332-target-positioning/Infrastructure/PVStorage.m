classdef PVStorage
    %PVLIST Summary of this class goes here
    %   Detailed explanation goes here

    properties(Constant)
        pvFormat = "SIOC:SYS1:ML03:AO%03d"
        pvStart = 651

        pvOffsetInformationSection = 0
        pvOffsetInformationSectionCurrentTarget = 0
        pvOffsetInformationSectionCurrentTargetArea = 1
        pvOffsetInformationSectionCurrentHole = 2
        pvOffsetInformationSectionCurrentDaqHole = 3

        pvOffsetConfigurationSection = 10
        pvOffsetNumTargets = 0
        pvOffsetNumTargetAreas = 1
        pvOffsetTargetIdlePositionLat = 2
        pvOffsetTargetIdlePositionVert = 3
        pvOffsetTargetAlPositionLat = 4
        pvOffsetTargetAlPositionVert = 5
        pvOffsetGlobalOffsetLat = 6
        pvOffsetGlobalOffsetVert = 7

        pvOffsetTargetSection = 20
        pvLengthTargetSection = 10 % Number of pv's per target
        pvNumberTargetSections = 4 % Max. number of target placeholders

        pvOffsetTargetType = 0
        pvOffsetTargetPoint1Hole = 1
        pvOffsetTargetPoint1Lat = 2
        pvOffsetTargetPoint1Vert = 3
        pvOffsetTargetPoint2Hole = 4
        pvOffsetTargetPoint2Lat = 5
        pvOffsetTargetPoint2Vert = 6


        pvOffsetTargetAreaSection = 60
        pvLengthTargetAreaSection = 10
        pvOffsetTargetAreaAssociatedTarget = 0
        pvOffsetTargetAreaNumFoils = 1
        pvOffsetTargetAreaPoint1Col = 2
        pvOffsetTargetAreaPoint1Row = 3
        pvOffsetTargetAreaPoint2Col = 4
        pvOffsetTargetAreaPoint2Row = 5
        pvOffsetTargetAreaLastHole = 6

    end

    methods (Static)

        function informationSection = getInformationSection(pvEngine)
            readValue = @(offset) pvEngine.get(sprintf(PVStorage.pvFormat, PVStorage.pvStart + PVStorage.pvOffsetInformationSection + offset));

            informationSection.currentTarget = readValue(PVStorage.pvOffsetInformationSectionCurrentTarget);
            informationSection.currentTargetArea = readValue(PVStorage.pvOffsetInformationSectionCurrentTargetArea);
            informationSection.currentHole = readValue(PVStorage.pvOffsetInformationSectionCurrentHole);
            informationSection.currentDaqHole = readValue(PVStorage.pvOffsetInformationSectionCurrentDaqHole);
        end
        function setInformationSection(pvEngine, informationSection)
            setValue = @(offset, value) pvEngine.put(sprintf(PVStorage.pvFormat, PVStorage.pvStart + PVStorage.pvOffsetInformationSection + offset), value);

            setValue(PVStorage.pvOffsetInformationSectionCurrentTarget, informationSection.currentTarget);
            setValue(PVStorage.pvOffsetInformationSectionCurrentTargetArea, informationSection.currentTargetArea);
            setValue(PVStorage.pvOffsetInformationSectionCurrentHole, informationSection.currentHole);
        end

        function configurationSection = getConfigurationSection(pvEngine)
            readValue = @(offset) pvEngine.get(sprintf(PVStorage.pvFormat, PVStorage.pvStart + PVStorage.pvOffsetConfigurationSection + offset));

            configurationSection.numTargets = readValue(PVStorage.pvOffsetNumTargets);
            configurationSection.numTargetAreas = readValue(PVStorage.pvOffsetNumTargetAreas);
            configurationSection.targetIdlePositionLat = readValue(PVStorage.pvOffsetTargetIdlePositionLat);
            configurationSection.targetIdlePositionVert = readValue(PVStorage.pvOffsetTargetIdlePositionVert);
            configurationSection.targetAlPositionLat = readValue(PVStorage.pvOffsetTargetAlPositionLat);
            configurationSection.targetAlPositionVert = readValue(PVStorage.pvOffsetTargetAlPositionVert);
            configurationSection.targetGlobalOffsetLat = readValue(PVStorage.pvOffsetGlobalOffsetLat);
            configurationSection.targetGlobalOffsetVert = readValue(PVStorage.pvOffsetGlobalOffsetVert);            
        end

        function setConfigurationSection(pvEngine, configurationSection)
            setValue = @(offset, value) pvEngine.put(sprintf(PVStorage.pvFormat, PVStorage.pvStart + PVStorage.pvOffsetConfigurationSection + offset), value);

            setValue(PVStorage.pvOffsetNumTargets, configurationSection.numTargets);
            setValue(PVStorage.pvOffsetNumTargetAreas, configurationSection.numTargetAreas);
            setValue(PVStorage.pvOffsetTargetIdlePositionLat, configurationSection.targetIdlePositionLat);
            setValue(PVStorage.pvOffsetTargetIdlePositionVert, configurationSection.targetIdlePositionVert);
            setValue(PVStorage.pvOffsetTargetAlPositionLat, configurationSection.targetAlPositionLat);
            setValue(PVStorage.pvOffsetTargetAlPositionVert, configurationSection.targetAlPositionVert);
            setValue(PVStorage.pvOffsetGlobalOffsetLat, configurationSection.targetGlobalOffsetLat);
            setValue(PVStorage.pvOffsetGlobalOffsetVert, configurationSection.targetGlobalOffsetVert);
        end

        function targetSection = getTargetSection(pvEngine, targetNumber)
            readValue = @(offset) pvEngine.get(sprintf(PVStorage.pvFormat, ...
                PVStorage.pvStart + PVStorage.pvOffsetTargetSection + PVStorage.pvLengthTargetSection * (targetNumber - 1) + offset));

            targetSection.type = readValue(PVStorage.pvOffsetTargetType);
            targetSection.point1Hole = readValue(PVStorage.pvOffsetTargetPoint1Hole);
            targetSection.point1Lat = readValue(PVStorage.pvOffsetTargetPoint1Lat);
            targetSection.point1Vert = readValue(PVStorage.pvOffsetTargetPoint1Vert);
            targetSection.point2Hole = readValue(PVStorage.pvOffsetTargetPoint2Hole);
            targetSection.point2Lat = readValue(PVStorage.pvOffsetTargetPoint2Lat);
            targetSection.point2Vert = readValue(PVStorage.pvOffsetTargetPoint2Vert);
        end

        function setTargetSection(pvEngine, targetNumber, targetSection)
            setValue = @(offset, value) pvEngine.put(sprintf(PVStorage.pvFormat, ...
                PVStorage.pvStart + PVStorage.pvOffsetTargetSection + PVStorage.pvLengthTargetSection * (targetNumber - 1) + offset), value);

            setValue(PVStorage.pvOffsetTargetType, targetSection.type);
            setValue(PVStorage.pvOffsetTargetPoint1Hole, targetSection.point1Hole);
            setValue(PVStorage.pvOffsetTargetPoint1Lat, targetSection.point1Lat);
            setValue(PVStorage.pvOffsetTargetPoint1Vert, targetSection.point1Vert);
            setValue(PVStorage.pvOffsetTargetPoint2Hole, targetSection.point2Hole);
            setValue(PVStorage.pvOffsetTargetPoint2Lat, targetSection.point2Lat);
            setValue(PVStorage.pvOffsetTargetPoint2Vert, targetSection.point2Vert);
        end

        function targetAreaSection = getTargetAreaSection(pvEngine, targetAreaNumber)
            readValue = @(offset) pvEngine.get(sprintf(PVStorage.pvFormat, ...
                PVStorage.pvStart + PVStorage.pvOffsetTargetAreaSection + PVStorage.pvLengthTargetAreaSection * (targetAreaNumber - 1) + offset));

            targetAreaSection.associatedTarget = readValue(PVStorage.pvOffsetTargetAreaAssociatedTarget);
            targetAreaSection.numFoils = readValue(PVStorage.pvOffsetTargetAreaNumFoils);
            targetAreaSection.lastHole = readValue(PVStorage.pvOffsetTargetAreaLastHole);
            targetAreaSection.point1Col = readValue(PVStorage.pvOffsetTargetAreaPoint1Col);
            targetAreaSection.point1Row = readValue(PVStorage.pvOffsetTargetAreaPoint1Row);
            targetAreaSection.point2Col = readValue(PVStorage.pvOffsetTargetAreaPoint2Col);
            targetAreaSection.point2Row = readValue(PVStorage.pvOffsetTargetAreaPoint2Row);
        end
        function setTargetAreaSection(pvEngine, targetAreaNumber, targetAreaSection)
            setValue = @(offset, value) pvEngine.put(sprintf(PVStorage.pvFormat, ...
                PVStorage.pvStart + PVStorage.pvOffsetTargetAreaSection + PVStorage.pvLengthTargetAreaSection * (targetAreaNumber - 1) + offset), value);

             setValue(PVStorage.pvOffsetTargetAreaAssociatedTarget, targetAreaSection.associatedTarget);
             setValue(PVStorage.pvOffsetTargetAreaNumFoils, targetAreaSection.numFoils);
             setValue(PVStorage.pvOffsetTargetAreaLastHole, targetAreaSection.lastHole);
             setValue(PVStorage.pvOffsetTargetAreaPoint1Col, targetAreaSection.point1Col);
             setValue(PVStorage.pvOffsetTargetAreaPoint1Row, targetAreaSection.point1Row);
             setValue(PVStorage.pvOffsetTargetAreaPoint2Col, targetAreaSection.point2Col);
             setValue(PVStorage.pvOffsetTargetAreaPoint2Row, targetAreaSection.point2Row);
        end

    end
end

