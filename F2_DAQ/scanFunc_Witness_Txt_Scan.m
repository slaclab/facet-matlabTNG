classdef scanFunc_Witness_Txt_Scan
  properties
    pvlist PV
    pvs
    initial_control
    initial_readback
    daqhandle
    freerun = true
  end
  properties(Constant)
        control_PV = "SIOC:SYS1:ML02:AO399"  %PV from scanDummy
        readback_PV = "SIOC:SYS1:ML02:AO399" %PV from scanDummy
    
    tolerance = 0.01;
  end
  
  methods
    
    function obj = scanFunc_Witness_Txt_Scan(daqhandle)
      
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
      
      [collimators_list]=read_collimators_table(); %list of collimator positions from table
      left_jaw_pos = collimators_list(value, 1);
      notch_pos = collimators_list(value, 2);
      notch_angle = collimators_list(value, 3);
      
      caput(obj.pvs.control,value);
      obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.control.name, value));
      
      left_jaw_PV = 'COLL:LI20:2085:MOTR';
      notch_angle_PV = 'COLL:LI20:2073:MOTR';
      notch_pos_PV = 'COLL:LI20:2069:MOTR';
      
      lcaPutSmart(left_jaw_PV, left_jaw_pos);
      lcaPutSmart(notch_angle_PV, notch_angle);
      lcaPutSmart(notch_pos_PV, notch_pos);
      
      delta = 0;
      
    end
    
    function restoreInitValue(obj)
      obj.daqhandle.dispMessage('NOT Restoring initial value. Sorry!');
      
    end
    
  end
  
end