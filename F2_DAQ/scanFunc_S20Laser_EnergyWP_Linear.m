classdef scanFunc_S20Laser_EnergyWP_Linear
    properties
        pvlist PV
        pvs
        initial_control
        initial_readback
        daqhandle
        freerun = true
    end
    properties(Constant)
        motor_control_PV = "XPS:LA20:LS24:M1"  % WP motor position output
        motor_readback_PV = "XPS:LA20:LS24:M1.RBV"
        
        control_PV = "SIOC:SYS1:ML00:AO976"  %Relative energy input
        readback_PV = "SIOC:SYS1:ML00:AO976"
        
        tolerance = 0.01;
    end
    
    methods 
        
        function obj = scanFunc_S20Laser_EnergyWP_Linear(daqhandle)
            
            % Check if scanfunc called by DAQ
            if exist('daqhandle','var')
                obj.daqhandle=daqhandle;
                obj.freerun = false;
            end
                    
            context = PV.Initialize(PVtype.EPICS_labca);
            obj.pvlist=[...
                PV(context,'name',"motor_control",'pvname',obj.motor_control_PV,'mode',"rw",'monitor',true); % Control PV
                PV(context,'name',"motor_readback",'pvname',obj.motor_readback_PV,'mode',"r",'monitor',true); % Readback PV
                PV(context,'name',"control",'pvname',obj.control_PV,'mode',"rw",'monitor',true); % Control PV
                PV(context,'name',"readback",'pvname',obj.readback_PV,'mode',"r",'monitor',true); % Readback PV
                ];
            pset(obj.pvlist,'debug',0);
            obj.pvs = struct(obj.pvlist);
            
            obj.initial_control = caget(obj.pvs.motor_control);
            obj.initial_readback = caget(obj.pvs.motor_readback);
            
        end
        
        function delta = set_value(obj,value)
            
            WP_Max_phase = lcaGet('SIOC:SYS1:ML00:AO977');
            
            thetaWP = -acosd(sqrt(value))/2 + WP_Max_phase 
            
            caput(obj.pvs.motor_control,thetaWP);
            obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.motor_control.name, thetaWP));
            
            current_value = caget(obj.pvs.motor_readback);
            
            while abs(current_value - thetaWP) > obj.tolerance
                current_value = caget(obj.pvs.motor_readback);
                pause(0.1);
            end
            
            delta = current_value - thetaWP;
            obj.daqhandle.dispMessage(sprintf('%s readback is %0.2f', obj.pvs.motor_readback.name, current_value));
            
        end
        
        function restoreInitValue(obj)
            obj.daqhandle.dispMessage('Restoring initial value');
          
            value = obj.initial_control;
            
            caput(obj.pvs.motor_control,value);
            obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.motor_control.name,value));
            
            current_value = caget(obj.pvs.motor_readback);
            
            while abs(current_value - value) > obj.tolerance
                current_value = caget(obj.pvs.motor_readback);
                pause(0.1);
            end
            
            obj.daqhandle.dispMessage(sprintf('%s readback is %0.2f', obj.pvs.motor_readback.name, current_value));
       
        end
        
    end
    
end