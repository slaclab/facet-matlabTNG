classdef (Abstract) TargetDefinition < handle
    %Abstract target class to calculate convert hole number to coordinates

    properties(Abstract, SetAccess=private, GetAccess=public)
        numberOfHoles
    end

    methods (Abstract)      
        getHolePosition(obj, holeNumber)
            % Returns the lateral and vertical position of a given hole
            % number. Hole numbers start from 1.

        holeNumberFromString(str)
            % Returns the hole number from a string
    end

    
end

