pvEngine = PVEngineLca();

points(1).hole = Target_H15_C1_V10.holeNumberFromString("A2");
points(1).lat = -47.15;
points(1).vert = -36.2;

points(2).hole = Target_H15_C1_V10.holeNumberFromString("X33");
points(2).lat = -7.15;
points(2).vert = -0.6;

calibration = Calibration(pvEngine);
for i = 1:length(points)
    point = points(i);
    calibration.setCalibrationPoint(i, point.hole, point.lat, point.vert);
end