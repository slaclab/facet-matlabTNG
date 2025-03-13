classdef scanFunc_E320_LASER_TIME_Scan_EOS
    properties
        pvlist PV
        pvs
        initial_control
        initial_readback
        daqhandle
        freerun = true
        
        initial_control_EOS
        initial_readback_EOS
    end
    properties(Constant)

        control_PV = "OSC:LA20:10:FS_TGT_TIME"
        readback_PV = "OSC:LA20:10:FS_CTR_TIME"
        tolerance = 0.01;
        
        control_PV_EOS = "XPS:LI20:MC02:M5";
        readback_PV_EOS = "XPS:LI20:MC02:M5.RBV";
        tolerance_EOS = 0.01;
    end
    
    methods 
        
        function obj = scanFunc_E320_LASER_TIME_Scan_EOS(daqhandle)
            
            % Check if scanfunc called by DAQ
            if exist('daqhandle','var')
                obj.daqhandle=daqhandle;
                obj.freerun = false;
            end
        
            context = PV.Initialize(PVtype.EPICS_labca);
            obj.pvlist=[...
                PV(context,'name',"control",'pvname',obj.control_PV,'mode',"rw",'monitor',true); % Control PV
                PV(context,'name',"readback",'pvname',obj.readback_PV,'mode',"r",'monitor',true); % Readback PV
                PV(context,'name',"control_EOS",'pvname',obj.control_PV_EOS,'mode',"rw",'monitor',true); % Control PV EOS
                PV(context,'name',"readback_EOS",'pvname',obj.readback_PV_EOS,'mode',"r",'monitor',true); % Readback PV EOS
                ];
            pset(obj.pvlist,'debug',0);
            obj.pvs = struct(obj.pvlist);
            
            obj.initial_control = caget(obj.pvs.control);
            obj.initial_readback = caget(obj.pvs.readback);
            
            obj.initial_control_EOS = caget(obj.pvs.control_EOS);
            obj.initial_readback_EOS = caget(obj.pvs.readback_EOS);
            
        end
        
        function EOS_motor_updated = EOS_updated(obj, laser_time)
            EOS_motor_updated = obj.initial_control_EOS + 3e8/2 * (laser_time - obj.initial_control) ;
        end
        
        function delta = set_value(obj,value)
            EOS_pos_updated = obj.EOS_updated(value);
            
            
            caput(obj.pvs.control,value);
            caput(obj.pvs.control_EOS, EOS_pos_updated);
            
            obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.control.name, value));
            obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.control_EOS.name, EOS_pos_updated));
            
            current_value = caget(obj.pvs.readback);
            current_value_EOS = caget(obj.pvs.readback_EOS);
            
            while max(([current_value current_value_EOS]- [value EOS_pos_updated]) > [obj.tolerance obj.tolerance_EOS])
                current_value = caget(obj.pvs.readback);
                current_value_EOS = caget(obj.pvs.readback_EOS);
                pause(0.1);
            end
            
            delta = current_value(1) - value;
            obj.daqhandle.dispMessage(sprintf('%s readback is %0.2f', obj.pvs.readback.name, current_value));
            obj.daqhandle.dispMessage(sprintf('%s readback is %0.2f', obj.pvs.readback_EOS.name, current_value_EOS));
            
        end
        
        function restoreInitValue(obj)
            obj.daqhandle.dispMessage('Restoring initial value');
            obj.set_value(obj.initial_control);
        end
        
    end
    
end