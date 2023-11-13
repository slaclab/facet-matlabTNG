classdef RTSTransform < CoordinateTransform
    %Applies a basic coordinate transformation with rotation, scale and
    %translation
    
    properties (SetAccess = private, GetAccess = public)
        requiredCalibrationCoordinates = 2
        calibrated = false
        
        calibrationRotation = 0
        calibrationScale = 1
        calibrationTranslation = [0, 0]

        translation = [0, 0];
    end
    properties (Access = public)
        % Manual offsets for tuning the alignment
        manualTranslation = [0, 0]
    end
    
    methods
        function calibrate(obj, in, out)
            %Initializes the transformation with rotation and translation
            %such that latIn and vertIn will be transformed into latOut and
            %vertOut using the 'transform' method
            arguments
                obj
                in (2,2) {mustBeNumeric}
                out (2,2) {mustBeNumeric}
            end
            
            obj.translation = in(1, :);
            in = in - in(1, :);

            % Scale
            distance = @(x) sqrt(sum((x(2,:) - x(1,:)).^2));
            obj.calibrationScale = distance(out) / distance(in);
            in = in*obj.calibrationScale;
            
            % First, calculate translation to overlap the first in and out
            % points
            obj.calibrationTranslation = out(1,:) - in(1,:);
            

            % Calculate the rotation
            angle = @(x) atan2((x(2,2) - x(1,2)), (x(2,1) - x(1,1)));
            obj.calibrationRotation = angle(out) - angle(in);
        end
        
        function out = transform(obj, in)
            %Transforms raw hole coordinates in a.u. to physical motor positions.
            arguments
                obj
                in (:,2) {mustBeNumeric}
            end
            coords = in - obj.translation;

            % Apply rotation
            angle = atan2(coords(:,2), coords(:,1)) + obj.calibrationRotation;
            length = sqrt(sum(coords.^2, 2));
            coords = [cos(angle), sin(angle)] .* length;

            % Apply scale
            coords = coords * obj.calibrationScale;

            % Apply translation
            coords = coords + obj.calibrationTranslation + obj.manualTranslation;

            out = coords;
        end
    end
end

