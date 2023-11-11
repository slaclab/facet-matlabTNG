pvEngine = PVEngineLca();
%pvEngine.verbose = true;

% Set PV with number of targets
numTargets_PV = "SIOC:SYS1:ML03:AO652";
pvEngine.put(numTargets_PV, 3)


% Target 1

targetNumber = 1;
targetType = Target_H15_C1_V11();

calibrationData.targetTypeNumber = TargetDefinition.targetNumberByType(targetType);

calibrationData.hole(1) = targetType.holeNumberFromString("Y4");
calibrationData.lat(1) = -97.3;
calibrationData.vert(1) = -4;

calibrationData.hole(2) = targetType.holeNumberFromString("C31");
calibrationData.lat(2) = -62;
calibrationData.vert(2) = -36.1;

calibration = Calibration(pvEngine);
calibration.setCalibration(targetNumber, calibrationData);


% Target 2

targetNumber = 2;
targetType = Target_H15_C1_V10();

calibrationData.targetTypeNumber = TargetDefinition.targetNumberByType(targetType);

calibrationData.hole(1) = targetType.holeNumberFromString("C2");
calibrationData.lat(1) = -49.15;
calibrationData.vert(1) = -35.55;

calibrationData.hole(2) = targetType.holeNumberFromString("Z33");
calibrationData.lat(2) = -8.95;
calibrationData.vert(2) = -0.2;

calibration = Calibration(pvEngine);
calibration.setCalibration(targetNumber, calibrationData);



% Target 3

offsetX=3.5;
offsetY=0.5;

targetNumber = 3;
targetType = Target_H15_C1_V11();

calibrationData.targetTypeNumber = TargetDefinition.targetNumberByType(targetType);

calibrationData.hole(1) = targetType.holeNumberFromString("X4");
calibrationData.lat(1) = -77.684+offsetX;
calibrationData.vert(1) = -55.52+offsetY;

calibrationData.hole(2) = targetType.holeNumberFromString("B31");
calibrationData.lat(2) = -41.984+offsetX;
calibrationData.vert(2) = -87.12+offsetY;

calibration = Calibration(pvEngine);
calibration.setCalibration(targetNumber, calibrationData);
