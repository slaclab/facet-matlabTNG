classdef scanFunc_E320_S20Grating_LaserTime
   properties
       pvlist PV
       pvs
       initial_control
       initial_readback
       daqhandle
       freerun = true
       
       initial_control_laser
       initial_readback_laser
       
       %initial_control_EOS
       %initial_readback_EOS
       
   end
   properties(Constant) 
       control_PV = "XPS:LI20:MC03:M6" 
       readback_PV = "XPS:LI20:MC03:M6.RBV" 
       tolerance = 0.01; % (!)
       
       laser_PV_control = "SIOC:SYS1:ML00:CALCOUT320"%"OSC:LA20:10:FS_TGT_TIME" 
       laser_PV_readback = "SIOC:SYS1:ML00:CALCOUT321"%"OSC:LA20:10:FS_CTR_TIME" 
       laser_tolerance = 0.1;    
       
       
       offset_PV = "SIOC:SYS1:ML00:CALCOUT074";
       slope_PV = "SIOC:SYS1:ML00:CALCOUT081";
       
       %[None of these PVs are reserved in the Matlab PV list, it won't let me edit PV comments]
   end
   
   
   methods
       function obj = scanFunc_E320_S20Grating_LaserTime(daqhandle)
           if exist('daqhandle', 'var')
               obj.daqhandle=daqhandle;
               obj.freerun = false;
           end
           
           context = PV.Initialize(PVtype.EPICS_labca);
           obj.pvlist=[...
               PV(context,'name',"control",'pvname',obj.control_PV,'mode',"rw",'monitor',true);% Control PV S20Grating
               PV(context,'name',"control_LaserTime",'pvname',obj.laser_PV_control,'mode',"rw",'monitor',true);% Control PV LaserTime
               PV(context,'name',"readback",'pvname',obj.readback_PV,'mode',"r",'monitor',true);% Readback PV S20Grating
               PV(context,'name',"readback_LaserTime",'pvname',obj.laser_PV_readback,'mode',"r",'monitor',true);% Readback PV LaserTime
               PV(context,'name',"offset_2D",'pvname',obj.offset_PV,'mode',"r",'monitor',true);% PV for timing offset for 2D scan 
               %PV(context,'name',"control_EOS",'pvname',obj.control_PV_EOS,'mode',"rw",'monitor',true); % Control PV EOS
               %PV(context,'name',"readback_EOS",'pvname',obj.readback_PV_EOS,'mode',"r",'monitor',true); % Readback PV EOS
               ]; 
           pset(obj.pvlist,'debug',0);
           obj.pvs = struct(obj.pvlist);
           
           obj.initial_control = caget(obj.pvs.control); %[caget(obj.pvs.control_S20Grating) caget(obj.pvs.control_LaserTime)]; 
           obj.initial_readback = caget(obj.pvs.readback); %[caget(obj.pvs.readback_S20Grating) caget(obj.pvs.readback_LaserTime)];
           
           obj.initial_control_laser = caget(obj.pvs.control_LaserTime);
           obj.initial_readback_laser = caget(obj.pvs.readback_LaserTime);
           
           %obj.initial_control_EOS = caget(obj.pvs.control_EOS);
           %obj.initial_readback_EOS = caget(obj.pvs.readback_EOS);
           
           
           % Setting the offset to zero by default.
           caput(obj.pvs.offset_2D, 0);
       end 
       

       function laser_time_val = laser_grating_calibration(obj, s20_grating_val)
           slope =  lcaGet(char(obj.slope_PV)); %2.2267e4 * 1e-6; % fs/mm * ns/fs 
           offset = lcaGet(char(obj.offset_PV));
           laser_time_val = obj.initial_control_laser + (s20_grating_val - obj.initial_control)*slope + offset;
       end
       
       %function EOS_motor_updated = EOS_updated(obj, laser_time)
       %    EOS_motor_updated = obj.initial_control_EOS + 3e8/2 * (laser_time - obj.initial_control) ;
       % end
       
       function delta = set_value(obj,value)  
           value_laser = obj.laser_grating_calibration(value);
           
           %EOS_pos_updated = obj.EOS_updated(value_laser);
           
           caput(obj.pvs.control,value);
           caput(obj.pvs.control_LaserTime,value_laser);
           %caput(obj.pvs.control_EOS, EOS_pos_updated);
           
           obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.control.name, value));
           obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.control_LaserTime.name, value_laser));
           %obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.control_EOS.name, EOS_pos_updated));
           
           current_value = [caget(obj.pvs.readback) caget(obj.pvs.readback_LaserTime)];
           %current_value = caget(obj.pvs.readback);
           
           
           %while abs(current_value - value) > obj.tolerance
           while max((current_value - [value value_laser]) > [obj.tolerance obj.laser_tolerance])
               current_value(1) = caget(obj.pvs.readback);
               current_value(2) = caget(obj.pvs.readback_LaserTime);
               %current_value(3) = caget(obj.pvs.readback_EOS);
               pause(0.1);
           end
           
           delta = current_value(1) - value;
           obj.daqhandle.dispMessage(sprintf('%s readback is %0.2f', obj.pvs.readback.name, current_value(1)));
           obj.daqhandle.dispMessage(sprintf('%s readback is %0.2f', obj.pvs.readback_LaserTime.name, current_value(2)));
           %obj.daqhandle.dispMessage(sprintf('%s readback is %0.2f', obj.pvs.readback_EOS.name, current_value_EOS));
           
       end
       
       function restoreInitValue(obj)
           obj.daqhandle.dispMessage('Restoring initial value');
           obj.set_value(obj.initial_control);
           
           % Setting the offset to zero by default.
           caput(obj.pvs.offset_2D, 0);
       end
    
   end
    
   
end