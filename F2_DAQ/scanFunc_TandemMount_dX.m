classdef scanFunc_TandemMount_dX
    properties
        pvlist PV
        pvs
        initial_control1
        initial_readback1
        initial_control2
        initial_readback2
        daqhandle
        freerun = true
    end
    properties(Constant)
        control_PV = "XPS:LI20:MC03:M4"
        readback_PV = "XPS:LI20:MC03:M4.RBV"
        control_PV2 = "XPS:LI20:MC04:M3"
        readback_PV2 = "XPS:LI20:MC04:M3.RBV"
        tolerance = 0.01;
    end
    
    methods 
        
        function obj = scanFunc_TandemMount_dX(daqhandle)
            
            % Check if scanfunc called by DAQ
            if exist('daqhandle','var')
                obj.daqhandle=daqhandle;
                obj.freerun = false;
            end
                    
            context = PV.Initialize(PVtype.EPICS_labca);
            obj.pvlist=[...
                PV(context,'name',"control1",'pvname',obj.control_PV,'mode',"rw",'monitor',true); % Control PV
                PV(context,'name',"readback1",'pvname',obj.readback_PV,'mode',"r",'monitor',true); % Readback PV
                PV(context,'name',"control2",'pvname',obj.control_PV2,'mode',"rw",'monitor',true); % Control PV
                PV(context,'name',"readback2",'pvname',obj.readback_PV2,'mode',"r",'monitor',true); % Readback PV
                ];
            pset(obj.pvlist,'debug',0);
            obj.pvs = struct(obj.pvlist);
            
            obj.initial_control1 = caget(obj.pvs.control1);
            obj.initial_readback1 = caget(obj.pvs.readback1);
            obj.initial_control2 = caget(obj.pvs.control2);
            obj.initial_readback2 = caget(obj.pvs.readback2);
            
        end
        
        function delta = set_value(obj,value)
            
         
            caput(obj.pvs.control1,obj.initial_readback1+value);
            caput(obj.pvs.control2,obj.initial_readback2+value);
            
            obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f, and %s to %0.2f', obj.pvs.control1.name, obj.initial_readback1+value, obj.pvs.control2.name, obj.initial_readback2+value));
            
            current_value1 = caget(obj.pvs.readback1)-obj.initial_readback1;
            current_value2 = caget(obj.pvs.readback2)-obj.initial_readback2;
            
            while max(abs(current_value1 - value),abs(current_value2 - value))  > obj.tolerance
                current_value1 = caget(obj.pvs.readback1)-obj.initial_readback1;
                current_value2 = caget(obj.pvs.readback2)-obj.initial_readback2;
                pause(0.1);
            end
            
            delta = max(abs(current_value1 - value),abs(current_value2 - value));
            obj.daqhandle.dispMessage(sprintf('%s and %s readbacks are %0.2f and %0.2f', obj.pvs.readback1.name, obj.pvs.readback2.name, caget(obj.pvs.readback1), caget(obj.pvs.readback2)));
            
        end
        
        function restoreInitValue(obj)
            obj.daqhandle.dispMessage('Restoring initial values');
            caput(obj.pvs.control1,obj.initial_readback1);
            caput(obj.pvs.control2,obj.initial_readback2);
        end
        
    end
    
end