classdef (Abstract) CoordinateTransform < handle
    %COORDINATETRANSFORM Applies a coordinate transformation
    %to map an input to an output point space with a given set of points in
    %input and output space as a calibration.
    
    properties(Abstract, SetAccess = private, GetAccess = public)
        requiredCalibrationCoordinates
    end

    methods (Abstract)    
        calibrate(obj, in, out)
            %Initializes the transformation such that input coordinates will 
            %be transformed into output coodinates using the 'transform' 
            %method. "in" and "out" are (2,:) of x and y values

        transform(obj, in)
            %Transforms raw hole coordinates in a.u. to physical motor positions.
    end
end

