classdef scanFunc_LaserTime_S20Grating
   properties
       pvlist PV
       pvs
       initial_control
       initial_readback
       daqhandle
       freerun = true
   end
   properties(Constant) % [(grating property)  (laser property)]
       control_PV = ["SIOC:SYS1:ML00CALCOUT070" "SIOC:SYS1:ML00CALCOUT071"]; %["XPS:LI20:MC03:M6" "OSC:LA20:10:FS_TGT_TIME"]
       readback_PV = ["SIOC:SYS1:ML00CALCOUT070" "SIOC:SYS1:ML00CALCOUT071"];% ["XPS:LI20:MC03:M6.RBV" "OSC:LA20:10:FS_CTR_TIME"]
       tolerance = [0.01 0.01]; % (!)
   end
    
   
   methods
       function obj = scanFunc_LaserTime_S20Grating(daqhandle)
          
           if exist('daqhandle', 'var')
               obj.daqhandle=daqhandle;
               obj.freerun = false;
           end
           
           context = PV.Initialize(PVtype.EPICS_labca);
           obj.pvlist=[...
               PV(context,'name',"control_S20Grating",'pvname',obj.control_PV(0),'mode',"rw",'monitor',true);% Control PV S20Grating
               PV(context,'name',"control_LaserTime",'pvname',obj.control_PV(1),'mode',"rw",'monitor',true);% Control PV LaserTime
               PV(context,'name',"readback_S20Grating",'pvname',obj.readback_PV(0),'mode',"r",'monitor',true);% Readback PV S20Grating
               PV(context,'name',"readback_LaserTime",'pvname',obj.readback_PV(1),'mode',"r",'monitor',true);% Readback PV LaserTime
               ]; 
           pset(obj.pvlist,'debug',0);
           obj.pvs = struct(obj.pvlist);
           
           obj.initial_control = [caget(obj.pvs.control_S20Grating) caget(obj.pvs.control_LaserTime)]; 
           obj.initial_readback = [caget(obj.pvs.readback_S20Grating) caget(obj.pvs.readback_LaserTime)];
       end
       
       function laser_time_val = laser_grating_calibration(s20_grating_val)
           slope = 0.6*100*4000/16; % fs/mm
           laser_time_val = caget(obj.pvs.readback_LaserTime) + s20_grating_val*slope;
       end
       
       function delta = set_value(obj,value_grating, value_laser) 
           arguments
               obj scanFunc_LaserTime_S20Grating
               value_grating double
               value_laser double = laser_grating_calibration(value_grating)
           end 
           
           
           caput(obj.pvs.control_S20Grating,value_grating);
           caput(obj.pvs.control_LaserTime,value_laser);
           
           obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.control_S20Grating.name, value_grating));
           obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.control_LaserTime.name, value_laser));
           
           current_value = [caget(obj.pvs.readback_S20Grating) caget(obj.pvs.readback_LaserTime)];
           
           
           while max((current_value - [value_grating value_laser]) > obj.tolerance)
               current_value(0) = caget(obj.pvs.readback_S20Grating);
               current_value(1) = caget(obj.pvs.readback_LaserTime);
               pause(0.1);
           end
           
           delta = current_value - [value_grating value_laser];
           obj.daqhandle.dispMessage(springf('%s readback is %0.2f', obj.pvs.readback_S20Grating.name, current_value(0)));
           obj.daqhandle.dispMessage(springf('%s readback is %0.2f', obj.pvs.readback_LaserTime.name, current_value(1)));
           
       end
       
       function restoreInitValue(obj)
           obj.daqhandle.dispMessage('Restoring initial value');
           obj.set_value(obj.initial_control{:});
       end
    
   end
    
   
end