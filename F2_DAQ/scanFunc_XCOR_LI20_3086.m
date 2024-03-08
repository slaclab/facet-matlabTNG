classdef scanFunc_XCOR_LI20_3086
    properties
%         pvlist PV
%         pvs
        initial_control
        initial_readback
        daqhandle
        freerun = true
    end
    properties(Constant)
        control_PV = "LI20:XCOR:3086"
        readback_PV = "LI20:XCOR:3086"
        tolerance = 0.001;
    end
    
    methods 
        
        function obj = scanFunc_XCOR_LI20_3086(daqhandle)
            
            % Check if scanfunc called by DAQ
            if exist('daqhandle','var')
                obj.daqhandle=daqhandle;
                obj.freerun = false;
            end
                    
%             context = PV.Initialize(PVtype.EPICS_labca);
%             obj.pvlist=[...
%                 PV(context,'name',"control",'pvname',obj.control_PV,'mode',"rw",'monitor',true); % Control PV
%                 PV(context,'name',"readback",'pvname',obj.readback_PV,'mode',"r",'monitor',true); % Readback PV
%                 ];
%             pset(obj.pvlist,'debug',0);
%             obj.pvs = struct(obj.pvlist);
            
            obj.initial_control = control_magnetGet(obj.control_PV);
            obj.initial_readback = control_magnetGet(obj.readback_PV);
            
        end 
        
        function delta = set_value(obj,value)
            
            control_magnetSet(obj.control_PV,value);
            obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.control_PV, value));
            
            current_value = control_magnetGet(obj.readback_PV);
            
            while abs(current_value - value) > obj.tolerance
                current_value = control_magnetGet(obj.readback_PV);
                pause(0.4);
            end
            
            delta = current_value - value;
            obj.daqhandle.dispMessage(sprintf('%s readback is %0.2f', obj.readback_PV, current_value));
            
        end
        
        function restoreInitValue(obj)
            obj.daqhandle.dispMessage('Restoring initial value');
            obj.set_value(obj.initial_control);
        end
        
    end
    
end