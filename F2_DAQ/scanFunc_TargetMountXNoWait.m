classdef scanFunc_TargetMountXNoWait
    properties
        pvlist PV
        pvs
        initial_control
        initial_readback
        daqhandle
        freerun = true
    end
    properties(Constant)
        control_PV = "XPS:LI20:MC05:M2"
        readback_PV = "XPS:LI20:MC05:M2.RBV"
        tolerance = 0.01;
    end
    
    methods 
        
        function obj = scanFunc_TargetMountXNoWait(daqhandle)
            
            % Check if scanfunc called by DAQ
            if exist('daqhandle','var')
                obj.daqhandle=daqhandle;
                obj.freerun = false;
            end
                    
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
            
            %caput(obj.pvs.control,value);
            lcaPutNoWait(obj.control_PV,value);
            obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.control.name, value));
            
            %current_value = caget(obj.pvs.readback);
            current_value = lcaGet(obj.readback_PV);
            
            while abs(current_value - value) > obj.tolerance
                current_value = lcaGet(obj.readback_PV);
                pause(0.01);
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