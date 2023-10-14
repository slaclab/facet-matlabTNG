classdef PVEngine < handle
    %PVENGINE Interface for putting/getting PVs
    
    methods (Abstract)
        get(obj, pvName);
        put(obj, pvName, val);
        readback(obj, pvName);
    end
end

