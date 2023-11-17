classdef UnityTransform < CoordinateTransform
    %UNITYTRANSFORM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = public)
        requiredCalibrationCoordinates = 0
    end
    
    methods
        function calibrate(obj, in, out)
            %UNITYTRANSFORM Construct an instance of this class
            %   Detailed explanation goes here
        end
        
        function out = transform(obj, in)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            out = in;
        end
    end
end

