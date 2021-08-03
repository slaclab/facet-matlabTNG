classdef use_PV
    properties
        pvlist PV
        pvs
        initial_control
        initial_readback
    end
    
    methods 
        
        function obj = usePV(PV_name)
            
            obj.control_PV = PV_name;
            
            split_pv = strsplit(PV_name,':');
            
            if strcmp(split_pv{end},'BDES') || strcmp(split_pv{end},'BCTRL')
                
                
                
                
        
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