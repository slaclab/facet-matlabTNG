classdef scanFunc_GASJET_ON_OFF
    properties
        pvlist PV
        pvs
        initial_control
        initial_readback
        daqhandle
        freerun = true
    end
    properties(Constant)
        control_PV = "SIOC:SYS1:ML01:AO035"
        readback_PV = "SIOC:SYS1:ML01:AO035"
        set_PV = "TRIG:LI20:EX01:FP1_TCTL";
        tolerance = 0.01;
    end
    
    methods 
        
        function obj = scanFunc_GASJET_ON_OFF(daqhandle)
            
            % Check if scanfunc called by DAQ
            if exist('daqhandle','var')
                obj.daqhandle=daqhandle;
                obj.freerun = false;
            end
                    
            context = PV.Initialize(PVtype.EPICS_labca);
            obj.pvlist=[...
                PV(context,'name',"control",'pvname',obj.control_PV,'mode',"rw",'monitor',true); % Control PV
                PV(context,'name',"readback",'pvname',obj.readback_PV,'mode',"r",'monitor',true); % Readback PV
                PV(context,'name',"set",'pvname',obj.set_PV,'mode',"r",'monitor',true); % Set PV
                ];
            pset(obj.pvlist,'debug',0);
            obj.pvs = struct(obj.pvlist);
            
            obj.initial_control = caget(obj.pvs.control);
            obj.initial_readback = caget(obj.pvs.readback);
            
        end
        
        function delta = set_value(obj,value)
            % This function controls the gas jet, which wants a text value,
            % by setting a matlab PV and then using that PV to determine
            % whether to write "Enabled" or "Disabled" to the actual PV
            % that controls the gas jet.
            
            % Write to the EPICS PV 
            caput(obj.pvs.control,value);
            obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.control.name, value));
            
            % If the input value is odd, the gas jet should be turned on.
            if mod(round(value),2) == 1
                caput(obj.pvs.set, "Enabled");
                disp("Gas Jet Enabled")
            % If the input value is even, the gas jet should be turned off.
            elseif mod(round(value),2) == 0
                caput(obj.pvs.set, "Disabled");
                disp("Gas Jet Disabled")
            end
            
            current_value = caget(obj.pvs.readback);
            
            while abs(current_value - value) > obj.tolerance
                current_value = caget(obj.pvs.readback);
                pause(0.1);
            end
            
            delta = current_value - value;
            obj.daqhandle.dispMessage(sprintf('%s readback is %0.2f', obj.pvs.readback.name, current_value));
            
        end
        
        function restoreInitValue(obj)
            obj.daqhandle.dispMessage('Restoring initial value');
            obj.set_value(obj.initial_control);
        end
        
    end
    
end