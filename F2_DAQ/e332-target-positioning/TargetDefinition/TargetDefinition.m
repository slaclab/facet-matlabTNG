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

        getNumberOfHoles(obj)
    end

    methods (Static)
        function targetType = targetTypeByNumber(number)
            if (number == 0)
                targetType = Target_H15_C1_V10;
            elseif (number == 1)
                targetType = Target_H15_C1_V11;
            end
        end
        function targetNumber = targetNumberByType(type)
            typeStr = class(type);
            if (typeStr == class(Target_H15_C1_V10))
                targetNumber = 0;
            elseif(typeStr == class(Target_H15_C1_V11))
                targetNumber = 1;
            end
        end
    end
    
end

