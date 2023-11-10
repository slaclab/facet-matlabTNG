pvEngine = PVEngineMock();
pvEngine.verbose = true;

% Set PV with number of targets
numTargets_PV = "SIOC:SYS1:ML03:AO652";
pvEngine.put(numTargets_PV, 3)

% Target 1

targetNumber = 1;
targetType = Target_H15_C1_V10();

calibrationData.targetTypeNumber = TargetDefinition.targetNumberByType(targetType);

calibrationData.hole(1) = targetType.holeNumberFromString("A2");
calibrationData.lat(1) = -47.15;
calibrationData.vert(1) = -36.2;

calibrationData.hole(2) = targetType.holeNumberFromString("X22");
calibrationData.lat(2) = -7.15;
calibrationData.vert(2) = -6.2;

calibration = Calibration(pvEngine);
calibration.setCalibration(targetNumber, calibrationData);


% Target 2

targetNumber = 2;
targetType = Target_H15_C1_V11();

calibrationData.targetTypeNumber = TargetDefinition.targetNumberByType(targetType);

calibrationData.hole(1) = targetType.holeNumberFromString("A2");
calibrationData.lat(1) = 47.15;
calibrationData.vert(1) = 36.2;

calibrationData.hole(2) = targetType.holeNumberFromString("X22");
calibrationData.lat(2) = 7.15;
calibrationData.vert(2) = 6.2;

calibration = Calibration(pvEngine);
calibration.setCalibration(targetNumber, calibrationData);



% Target 3


targetNumber = 3;
targetType = Target_H15_C1_V11();

calibrationData.targetTypeNumber = TargetDefinition.targetNumberByType(targetType);

calibrationData.hole(1) = targetType.holeNumberFromString("A2");
calibrationData.lat(1) = -147.15;
calibrationData.vert(1) = -236.2;

calibrationData.hole(2) = targetType.holeNumberFromString("F19");
calibrationData.lat(2) = -227.15;
calibrationData.vert(2) = -226.2;

calibration = Calibration(pvEngine);
calibration.setCalibration(targetNumber, calibrationData);
