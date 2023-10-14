classdef PVEngineMock < PVEngine
    %MOCKPVENGINE PV mock engine
   
    
    properties
        verbose (1,1) logical
        readbackDelay (1,1) duration
    end
    properties(Access=public)
        % Not using 'dictionary' because Matlab lacks 20 years behind...
        pvs = struct('name', {}, 'time', {}, 'currentValue', {}, 'previousValue', {})
    end

    methods
        function obj = PVEngineMock(readbackDelay, verbose)
            arguments
                readbackDelay (1,1) duration = duration(0, 0, 2);
                verbose (1,1) logical = false;
            end
            obj.readbackDelay = readbackDelay;
            obj.verbose = verbose;
        end

        function value = get(obj, pvName)
            idx = obj.findPv(pvName);
            if idx == -1
                idx = obj.initPv(pvName);
            end

            value = obj.pvs(idx).currentValue;

            if obj.verbose
                fprintf("Getting PV 'pvName': %f\n", value);
            end
        end
        function put(obj, pvName, value)
            idx = obj.findPv(pvName);
            pvIsCreated = idx == -1;
            if idx == -1
                idx = obj.initPv(pvName);
            end

            if pvIsCreated
                previousValue = value;
            else
                previousValue = obj.pvs(idx).currentValue;
            end

            obj.pvs(idx).time = datetime("now");
            obj.pvs(idx).currentValue = value;
            obj.pvs(idx).previousValue = previousValue;
            
            if obj.verbose
                fprintf("Setting PV '%s': %f\n", pvName, value);
            end
        end
        function value = readback(obj, pvName)
            idx = obj.findPv(pvName);
            if idx == -1
                idx = obj.initPv(pvName);
            end

            pvData = obj.pvs(idx);
            value = interp1([datetime("yesterday"), pvData.time, pvData.time + obj.readbackDelay, datetime("tomorrow")], ...
                [pvData.previousValue, pvData.previousValue, pvData.currentValue, pvData.currentValue], ...
                datetime("now"));
            if obj.verbose
                fprintf("Getting PV '%s': %f\n", pvName, value);
            end
        end
    end
    methods(Access=protected)
        function idx = initPv(obj, pvName)
            % INIT Initializes a PV.
            idx = obj.findPv(pvName);
            if idx == -1
                idx = length(obj.pvs) + 1;
            end
            obj.pvs(idx).pvName = pvName;
            obj.pvs(idx).time = datetime("now");
            obj.pvs(idx).currentValue = 0;
            obj.pvs(idx).previousValue = 0;
        end

        function idx = findPv(obj, pvName)
            % FINDPV Finds the index of the pv in obj.pvs and returns -1 if
            % not existing.
            idx = -1;
            for i = 1:length(obj.pvs)
                if obj.pvs(i).pvName == pvName
                    idx = i;
                    break;
                end
            end
        end

    end
end

