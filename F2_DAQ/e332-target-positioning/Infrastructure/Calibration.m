classdef Calibration < handle
    %CALIBRATION Summary of this class goes here
    %   Detailed explanation goes here

    properties
        pvEngine
    end

    properties(Constant)
        pvNameTemplate = "SIOC:SYS1:ML03:AO%03d";
        pvNumberStart = 661;
    end

    methods
        function obj = Calibration(pvEngine)
            %CALIBRATION Construct an instance of this class
            %   Detailed explanation goes here
            obj.pvEngine = pvEngine;
        end

        function setCalibration(obj, targetNumber, calibrationData)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            calibrationPV = @(offset) sprintf(obj.pvNameTemplate, obj.pvNumberStart + offset + 7 * (targetNumber - 1)) ;

            obj.pvEngine.put(calibrationPV(0), calibrationData.targetTypeNumber);

            obj.pvEngine.put(calibrationPV(1), calibrationData.hole(1));
            obj.pvEngine.put(calibrationPV(2), calibrationData.lat(1));
            obj.pvEngine.put(calibrationPV(3), calibrationData.vert(1));

            obj.pvEngine.put(calibrationPV(4), calibrationData.hole(2));
            obj.pvEngine.put(calibrationPV(5), calibrationData.lat(2));
            obj.pvEngine.put(calibrationPV(6), calibrationData.vert(2));
        end

        function calibrationData = getCalibration(obj, targetNumber)
            calibrationPV = @(offset) sprintf(obj.pvNameTemplate, obj.pvNumberStart + offset + 7 * (targetNumber - 1)) ;

            calibrationData.targetTypeNumber = obj.pvEngine.get(calibrationPV(0));

            calibrationData.hole(1) = obj.pvEngine.get(calibrationPV(1));
            calibrationData.lat(1) = obj.pvEngine.get(calibrationPV(2));
            calibrationData.vert(1) = obj.pvEngine.get(calibrationPV(3));
            
            calibrationData.hole(2) = obj.pvEngine.get(calibrationPV(4));
            calibrationData.lat(2) = obj.pvEngine.get(calibrationPV(5));
            calibrationData.vert(2) = obj.pvEngine.get(calibrationPV(6));
        end

    end
end

