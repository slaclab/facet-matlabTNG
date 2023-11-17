classdef PVEngineLca < PVEngine
    %PVENGINELCA PV interface via lcaget/lcaput
    
    methods
        function val = get(obj, pvName)
            val = lcaGet(char(pvName));
        end
        function put(obj, pvName, val)
            lcaPutNoWait(char(pvName), val);
        end
        function val = readback(obj, pvName)
            val = obj.get(pvName);% + ".RBV");
        end
    end
end

