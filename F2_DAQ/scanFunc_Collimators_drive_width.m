classdef scanFunc_Collimators_drive_width
  properties
    pvlist PV
    pvs
    initial_control
    initial_readback
    daqhandle
    freerun = true
  end
  properties(Constant)
    control_PV  = "SIOC:SYS1:ML00:CALCOUT672"
    readback_PV = "SIOC:SYS1:ML00:CALCOUT672"
    
    tolerance = 0.01;
  end
  
  methods
    
    function obj = scanFunc_Collimators_drive_width(daqhandle)
      
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
      drive_center = lcaGet('SIOC:SYS1:ML00:CALCOUT671');
      drive_width = value; 
      witness_center_req = lcaGet('SIOC:SYS1:ML00:CALCOUT673');
      witness_width = lcaGet('SIOC:SYS1:ML00:CALCOUT674');
      compression = 1;
      
      notch_width = abs(drive_center-witness_center) - drive_width/2 - witness_width/2;
      
      if witness_center_req > drive_center && notch_width > lcaGet('SIOC:SYS1:ML00:AO991') % checking that drive and witness are on the correct sides and notch width is greater than minimum
        [notch_pos, notch_angle, left_jaw_pos, right_jaw_pos] = calc_Collimators(drive_center, drive_width, witness_center_req, witness_width, compression);
        isok = 1;
      else
        isok = 0;
      end
      
      caput(obj.pvs.control,value);
      obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.control.name, value));
      
      notch_pos_PV = 'COLL:LI20:2069:MOTR';
      notch_angle_PV = 'COLL:LI20:2073:MOTR';
      right_jaw_PV = 'COLL:LI20:2086:MOTR';
      left_jaw_PV = 'COLL:LI20:2085:MOTR';
      
      if isok
        lcaPut(notch_pos_PV, notch_pos);
        lcaPut(notch_angle_PV, notch_angle);
        lcaPut(left_jaw_PV, left_jaw_pos);
        lcaPut(right_jaw_PV, right_jaw_pos);
      else
        obj.daqhandle.dispMessage('Invalid configuration, check that drive and witness are appropriately placed and spaced.');
        delta = 100; % How do I stop a DAQ with an error?
      end
      
    end
    
    function restoreInitValue(obj)
      obj.daqhandle.dispMessage('NOT Restoring initial value. Sorry!');
      
    end
    
  end
  
end