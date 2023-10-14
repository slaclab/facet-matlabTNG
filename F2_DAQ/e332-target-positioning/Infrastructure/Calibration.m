classdef Calibration < handle
    %CALIBRATION Summary of this class goes here
    %   Detailed explanation goes here

    properties
        pvEngine
    end

    properties(Constant)
        pvNameTemplate = "SIOC:SYS1:ML03:AO%03d";
        pvNumberStart = 651;
    end

    methods
        function obj = Calibration(pvEngine)
            %CALIBRATION Construct an instance of this class
            %   Detailed explanation goes here
            obj.pvEngine = pvEngine;
        end

        function setCalibrationPoint(obj, pointNumber, hole, lat, vert)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            pvs = obj.getPVs(pointNumber);
            obj.pvEngine.put(pvs.hole, hole);
            obj.pvEngine.put(pvs.lat, lat);
            obj.pvEngine.put(pvs.vert, vert);
        end
        function pvs = getPVs(obj, point)
            %CALIBRATIONPVS Defines the PV names for the coordinate
            %transformation calibration points. "pointNumber" is the number of the
            %calibration point.
            offset = point - 1;

            pvs = [];
            pvs.hole = sprintf(obj.pvNameTemplate, obj.pvNumberStart + offset * 3);
            pvs.lat = sprintf(obj.pvNameTemplate, obj.pvNumberStart + offset * 3 + 1);
            pvs.vert = sprintf(obj.pvNameTemplate, obj.pvNumberStart + offset * 3 + 2);
        end

        function calibrationPoint = getCalibrationPoint(obj, point)
            pvs = obj.getPVs(point);
            calibrationPoint.hole = obj.pvEngine.get(pvs.hole);
            calibrationPoint.lat = obj.pvEngine.get(pvs.lat);
            calibrationPoint.vert = obj.pvEngine.get(pvs.vert);
        end
        function calibrationPoints = getCalibration(obj, numPoints)
            %GETCALIBRATION Retrieves the coordinate transform
            %calibration points from PVs. The calibration points in PVs are tuples of
            %three PVs with hole number / lat / vert. pvGet is a callable to retrieve
            %the PV value.
            arguments
                obj
                numPoints (1,1) {mustBeInteger};
            end
            for point = 1:numPoints
                calibrationPoints(point) = obj.getCalibrationPoint(point);
            end

        end
    end
end

