classdef scanFunc_dummy
    properties
        pvlist PV
        pvs
        initial_control
        initial_readback
    end
    properties(Constant)
        control_PV = "SIOC:SYS1:ML02:AO399"
        readback_PV = "SIOC:SYS1:ML02:AO399"
        tolerance = 0.01;
    end
    
    methods 
        
        function obj = scanFunc_dummy()
        
            context = PV.Initialize(PVtype.EPICS_labca);
            obj.pvlist=[...
                PV(context,'name',"control",'pvname',obj.control_PV,'mode',"rw",'monitor',true); % Control PV
                PV(context,'name',"readback",'pvname',obj.readback_PV,'mode',"r",'monitor',true); % Readback PV
                ];
            pset(obj.pvlist,'debug',0);
            obj.pvs = struct(obj.pvlist);
            
            obj.initial_control = caget(obj.pvs.control);
            obj.initial_readback = caget(obj.pvs.readback);
            
        end
        
        function delta = set_value(obj,value)
            
            caput(obj.pvs.control,value);
            
            current_value = caget(obj.pvs.readback);
            
            while abs(current_value - value) > obj.tolerance
                current_value = caget(obj.pvs.readback);
                pause(0.1);
            end
            
            delta = current_value - value;
            
        end
        
    end
    
end