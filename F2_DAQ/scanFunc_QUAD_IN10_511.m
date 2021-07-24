classdef scanFunc_QUAD_IN10_511
    properties
        pvlist PV
        pvs
    end
    properties(Constant)
        control_PV = "QUAD:IN10:511:BCTRL"
        readback_PV = "QUAD:IN10:511:BACT"
        tolerance = 0.01;
    end
    
    methods 
        
        function obj = scanFunc_QUAD_IN10_511()
        
            context = PV.Initialize(PVtype.EPICS_labca);
            obj.pvlist=[...
                PV(context,'name',"control",'pvname',obj.control_PV,'mode',"rw",'monitor',true); % Control PV
                PV(context,'name',"readback",'pvname',obj.readback_PV,'mode',"r",'monitor',true); % Readback PV
                ];
            pset(obj.pvlist,'debug',0);
            obj.pvs = struct(obj.pvlist);
            
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