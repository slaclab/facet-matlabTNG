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
calibrationData.lat(1) = -97.1;
calibrationData.vert(1) = -3.9;

calibrationData.hole(2) = targetType.holeNumberFromString("C31");
calibrationData.lat(2) = -61.7;
calibrationData.vert(2) = -36;

calibration = Calibration(pvEngine);
calibration.setCalibration(targetNumber, calibrationData);


% Target 2

targetNumber = 2;
targetType = Target_H15_C1_V10();

calibrationData.targetTypeNumber = TargetDefinition.targetNumberByType(targetType);

calibrationData.hole(1) = targetType.holeNumberFromString("C2");
calibrationData.lat(1) = -48.85;
calibrationData.vert(1) = -35.55;

calibrationData.hole(2) = targetType.holeNumberFromString("Z33");
calibrationData.lat(2) = -8.75;
calibrationData.vert(2) = -0.1;

calibration = Calibration(pvEngine);
calibration.setCalibration(targetNumber, calibrationData);



% Target 3


targetNumber = 3;
targetType = Target_H15_C1_V11();

calibrationData.targetTypeNumber = TargetDefinition.targetNumberByType(targetType);

calibrationData.hole(1) = targetType.holeNumberFromString("X4");
calibrationData.lat(1) = -77.484;
calibrationData.vert(1) = -55.42;

calibrationData.hole(2) = targetType.holeNumberFromString("B31");
calibrationData.lat(2) = -41.784;
calibrationData.vert(2) = -87.02;

calibration = Calibration(pvEngine);
calibration.setCalibration(targetNumber, calibrationData);
