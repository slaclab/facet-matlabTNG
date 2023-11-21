pvEngine = PVEngineLca();

colCharToInt = @(c) lower(c) - 'a';

% Set the configuration PVs
configurationSection.numTargets = 3;
configurationSection.numTargetAreas = 4;
configurationSection.targetIdlePositionLat = -20;
configurationSection.targetIdlePositionVert = -10;
configurationSection.targetAlPositionLat = 0;
configurationSection.targetAlPositionVert = 5;
PVStorage.setConfigurationSection(pvEngine, configurationSection);

vertOffset = -0.1;
latOffset = 0;

% Target 1

targetNumber = 1;
targetType = Target_H15_C1_V11();

targetSection.type = TargetDefinition.targetNumberByType(targetType);

targetSection.point1Hole = targetType.holeNumberFromString("Y4");
targetSection.point1Lat = -97.3 + latOffset;
targetSection.point1Vert = -4 + vertOffset;

targetSection.point2Hole = targetType.holeNumberFromString("C31");
targetSection.point2Lat = -62+ latOffset;
targetSection.point2Vert = -36.1 + vertOffset;

PVStorage.setTargetSection(pvEngine, targetNumber, targetSection);

% Target 1

targetNumber = 2;
targetType = Target_H15_C1_V10();

targetSection.type = TargetDefinition.targetNumberByType(targetType);

targetSection.point1Hole = targetType.holeNumberFromString("C2");
targetSection.point1Lat = -49.15+ latOffset;
targetSection.point1Vert = -35.55 + vertOffset;

targetSection.point2Hole = targetType.holeNumberFromString("Z33");
targetSection.point2Lat = -8.95+ latOffset;
targetSection.point2Vert = -0.2 + vertOffset;

PVStorage.setTargetSection(pvEngine, targetNumber, targetSection);

% Target 3

target3vertOffset = +3.0;
target3latOffset = 0.5;

targetNumber = 3;
targetType = Target_H15_C1_V11();

targetSection.type = TargetDefinition.targetNumberByType(targetType);

targetSection.point1Hole = targetType.holeNumberFromString("X4");
targetSection.point1Lat = -77.68 + target3vertOffset + latOffset;
targetSection.point1Vert = -55.52 + target3latOffset + vertOffset;

targetSection.point2Hole = targetType.holeNumberFromString("B31");
targetSection.point2Lat = -41.964 + target3vertOffset + latOffset;
targetSection.point2Vert = -87.12 + target3latOffset + vertOffset;

PVStorage.setTargetSection(pvEngine, targetNumber, targetSection);


% Target Area 1
targetAreaNumber = 1;
targetAreaSection = PVStorage.getTargetAreaSection(pvEngine, targetAreaNumber);

targetAreaSection.associatedTarget = 1;
targetAreaSection.numFoils = 111;
targetAreaSection.point1Col = 2;
targetAreaSection.point1Row = colCharToInt('B');
targetAreaSection.point2Col = 35;
targetAreaSection.point2Row = colCharToInt('Y');

% Uncomment if needs to be reset
%targetAreaSection.lastHole = 144;

PVStorage.setTargetAreaSection(pvEngine, targetAreaNumber, targetAreaSection);


% Target Area 2
targetAreaNumber = 2;
targetAreaSection = PVStorage.getTargetAreaSection(pvEngine, targetAreaNumber);

targetAreaSection.associatedTarget = 2;
targetAreaSection.numFoils = 40;
targetAreaSection.point1Col = 2;
targetAreaSection.point1Row = colCharToInt('B');
targetAreaSection.point2Col = 31;
targetAreaSection.point2Row = colCharToInt('Y');

% Uncomment if needs to be reset
%targetAreaSection.lastHole = 0;

PVStorage.setTargetAreaSection(pvEngine, targetAreaNumber, targetAreaSection);


% Target Area 3
targetAreaNumber = 3;
targetAreaSection = PVStorage.getTargetAreaSection(pvEngine, targetAreaNumber);

targetAreaSection.associatedTarget = 3;
targetAreaSection.numFoils = 20;
targetAreaSection.point1Col = 2;
targetAreaSection.point1Row = colCharToInt('B');
targetAreaSection.point2Col = 31;
targetAreaSection.point2Row = colCharToInt('J');

% Uncomment if needs to be reset
%targetAreaSection.lastHole = 0;

PVStorage.setTargetAreaSection(pvEngine, targetAreaNumber, targetAreaSection);


% Target Area 4
targetAreaNumber = 4;
targetAreaSection = PVStorage.getTargetAreaSection(pvEngine, targetAreaNumber);

targetAreaSection.associatedTarget = 3;
targetAreaSection.numFoils = 60;
targetAreaSection.point1Col = 2;
targetAreaSection.point1Row = colCharToInt('Q');
targetAreaSection.point2Col = 31;
targetAreaSection.point2Row = colCharToInt('Y');

% Uncomment if needs to be reset
%targetAreaSection.lastHole = 0;

PVStorage.setTargetAreaSection(pvEngine, targetAreaNumber, targetAreaSection);


