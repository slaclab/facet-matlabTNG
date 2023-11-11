classdef scanFunc_waist
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
    
    function obj = scanFunc_Spec_waist(daqhandle)
      
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
      
      [BDES_list]=read_BDES_table(); %list of BDES values from the table
      BDES_FF0=BDES_list(value,1); %Magnetic value for quad FF0
      BDES_FF1=BDES_list(value,2); %Magnetic value for quad FF1
      BDES_FF2=BDES_list(value,3); %Magnetic value for quad FF2
      BDES_FF3=BDES_list(value,4); %Magnetic value for quad FF3
      BDES_FF4=BDES_list(value,5); %Magnetic value for quad FF4
      BDES_FF5=BDES_list(value,6); %Magnetic value for quad FF5
      BDES_QS0=BDES_list(value,7); %Magnetic value for spec quad 0
      BDES_QS1=BDES_list(value,8); %Magnetic value for spec quad 1
      BDES_QS2=BDES_list(value,9); %Magnetic value for spec quad 2
      
      caput(obj.pvs.control,value);
      obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.control.name, value));
      
      quadPV.control_PV_FF0  = "LGPS:LI20:3031";
      quadPV.control_PV_FF1  = "LGPS:LI20:3204";
      quadPV.control_PV_FF2  = "LGPS:LI20:1910";
      quadPV.control_PV_FF3  = "LGPS:LI20:3151"; 
      quadPV.control_PV_FF4  = "LGPS:LI20:3311";
      quadPV.control_PV_FF5  = "LGPS:LI20:3011";
      quadPV.control_PV_QS0  = "LGPS:LI20:3141";
      quadPV.control_PV_QS1  = "LGPS:LI20:3261";
      quadPV.control_PV_QS2  = "LGPS:LI20:3091";
      
      quadPV.readback_PV_FF0 = "LGPS:LI20:3031";
      quadPV.readback_PV_FF1 = "LGPS:LI20:3204";
      quadPV.readback_PV_FF2 = "LGPS:LI20:1910";
      quadPV.readback_PV_FF3 = "LGPS:LI20:3150"; 
      quadPV.readback_PV_FF4 = "LGPS:LI20:3311";
      quadPV.readback_PV_FF5 = "LGPS:LI20:3011"; 
      quadPV.readback_PV_QS0  = "LGPS:LI20:3141";
      quadPV.readback_PV_QS1  = "LGPS:LI20:3261";
      quadPV.readback_PV_QS2  = "LGPS:LI20:3091";
      
      [delta] = set_FFS_quads(obj, quadPV,[BDES_FF0, BDES_FF1, BDES_FF2, BDES_FF3, BDES_FF4, BDES_FF5, BDES_QS0, BDES_QS1, BDES_QS2]');
      
    end
    
    function restoreInitValue(obj)
      obj.daqhandle.dispMessage('NOT Restoring initial value. Sorry!');
      
    end
    
  end
  
end