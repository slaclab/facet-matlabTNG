classdef PVEngineCa < PVEngine
    %PVENGINECA PV interface via caget/caput
    
    properties
        context
        pvList
    end

    methods
        function obj = PVEngineCa()
            obj.context = PV.Initialize(PVtype.EPICS_labca);
            obj.pvList = containers.Map;
        end

        function val = get(obj, pvName)
            if ~obj.pvList.isKey(pvName)
                obj.initializePV(pvName);
            end
            val = caget(obj.pvList(pvName));
        end
        function put(obj, pvName, val)
            if ~obj.pvList.isKey(pvName)
                obj.initializePV(pvName);
            end
            caput(obj.pvList(pvName), val);
        end
        function val = readback(obj, pvName)
            val = obj.get(pvName + ".RBV");
        end
    end

    methods(Access = private)
        function initializePV(obj, pvName)
            pv = PV(obj.context, 'name', '', 'pvname', pvName, 'mode', 'rw', 'monitor', true);
            obj.pvList(pvName) = pv;
        end
    end
end

