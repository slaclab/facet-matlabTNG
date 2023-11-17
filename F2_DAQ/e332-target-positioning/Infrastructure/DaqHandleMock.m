classdef DaqHandleMock
    %MOCKDAQHANDLE Mock daqhandle
    
    methods
        function dispMessage(obj, message)
            %DAQHANDLEMOCK Construct an instance of this class
            %   Detailed explanation goes here
            fprintf('daqhandle message: %s\n', message);
        end
    end
end

