classdef fbSISO < handle
  %FBSISO Generic SISO feedback class
  
  events
    DataUpdated
    StateChange
  end
  properties
    WriteEnable logical = true % enable writing to PV control
    Method string {mustBeMember(Method,"PID")} = "PID"
    Kp {mustBeNonnegative} = 1
    Ki {mustBeNonnegative} = 0
    Kd {mustBeNonnegative} = 0
    LimitRate uint16 = 0 % Limit data acquisition rate if >0 [seconds]
    ControlLimits(1,2) = [-inf,inf] % Limits for ControlVal
    SetpointLimits(1,2) = [-inf,inf] % Limits to setpoint (saturates on limits)
    QualLimits(1,2) = [-inf,inf] % Limits to place on Setpoint quality control PV
    SetpointDeadband(1,2) = [-eps,eps] % Deadband- only update feeddback when move out of this range of setpoint
    SetpointDES = 0 % desired setpoint value
    ControlVar % control variable (PV object)
    ControlVarType string {mustBeMember(ControlVarType,["single","doublepm"])} = "single" % doublepm = 2 PVs +/- ControlVal
    ControlProto string {mustBeMember(ControlProto,["EPICS","AIDA"])} = "EPICS"
    SetpointVar % setpoint variable to use (PV or BufferData object)
    QualVar % Setpoint Quality control (PV object)
    ControlStatusVar cell % Control variable status PV (can be list)
    ControlStatusGood cell % OK if ControlStatusVar PV evaluates to this (if set) (can be list)
    Running logical = true % Externally controlled running state
    InvertControlVal logical = false % Flip sign on control value before writing (negates the FB gain)
  end
  properties(SetObservable)
    Enable logical = false
  end
  properties(Dependent)
    state uint8 % overall feedback state; 0=running 1=stopped 2= error
    statestr string % state description
  end
  properties(SetAccess=private)
    ControlStatusVal cell
    ControlVal % current control variable value (local)
    SetpointVal % current setpoint value (local)
    QualVal % quality control value
    ControlState uint8 = 3 % 0=OK, 1=limit low, 2=limit high, 3=Error
    SetpointState uint8 = 3 % 0=OK, 1=limit low, 2=limit high, 3=Error
    QualState uint8 = 3 % 0=OK, 1=limit low, 2=limit high, 3=not connected, 4=Error
  end
  properties(Access=private)
    is_shutdown logical = false
  end
  
  methods
    function obj = fbSISO(controlPV,setpoint,qualPV)
      %FBSISO
      % FB = fbSISO(controlPV,setpointPV)
      % FB = fbSISO(controlPV,SetPointBufferDataObject)
      if ~exist('controlPV','var')
        error('Must provide PV object for control variable');
      end
      if ~exist('setpoint','var') || (~isa(setpoint,'PV') && ~isa(setpoint,'BufferData'))
        error('Must provide either PV or BufferData object for setpoint variable');
      end
      obj.SetpointVar = setpoint ;
      obj.ControlVar = controlPV ;
      if length(controlPV)==2
        obj.ControlVarType="doublepm";
      end
      if ~isa(controlPV,'PV')
        obj.ControlProto="AIDA";
      elseif controlPV.mode ~= "rw"
        error('Control Variable PV does not have write permission');
      end
      addlistener(obj,'DataUpdated',@(~,~) obj.ProcDataUpdated) ;
      if isa(obj.SetpointVar,'PV')
        obj.SetpointVar.monitor = true ;
        run(obj.SetpointVar,false,1/0.01,obj,'DataUpdated');
      else % BufferData object
        obj.SetpointVar.Enable=true;
        addlistener(obj.SetpointVar,'PVUpdated',@(~,~) obj.ProcDataUpdated) ;
      end
      % Use quality control PV?
      if exist('qualPV','var') && isa(qualPV,'PV')
        obj.QualVar = qualPV;
      end
    end
    function shutdown(obj)
      obj.is_shutdown = true ;
      if isa(obj.SetpointVar,'PV')
        stop(obj.SetpointVar);
      else
        obj.SetpointVar.shutdown;
      end
    end
  end
  % set/get and private methods
  methods
    function set.Enable(obj,val)
      if logical(val)==obj.Enable
        return
      end
      obj.Enable=logical(val);
    end
    function state = get.state(obj)
      if obj.Enable && obj.Running
        state = uint8(0);
      else
        state = uint8(1);
      end
      if obj.ControlState>0 || obj.SetpointState>2 || obj.QualState==1 || obj.QualState==2
        state = uint8(2);
      end
      % Check validity of data
      data = [obj.ControlVal obj.SetpointVal];
      if any(isnan(data)) || any(isinf(data)) || obj.ControlState == 3 || obj.SetpointState == 3 || obj.QualState == 4
        state=uint8(3);
      end
    end
    function txt = get.statestr(obj)
      if obj.Enable && obj.Running
        txt = "Enabled" ;
      elseif ~obj.Running
        txt = "Not Running" ;
      else
        txt = "Not Enabled" ;
      end
      if obj.state<2
        txt = txt + ", OK" ;
      else
        txt = txt + ", Error" ;
      end
      switch obj.ControlState
        case 1
          txt = txt + ", Control Limit LOW" ;
        case 2
          txt = txt + ", Control Limit HIGH" ;
        case 3
          txt = txt + ", Control Readback INVALID" ;
      end
      switch obj.SetpointState
        case 1
          txt = txt + ", Setpoint Limit LOW" ;
        case 2
          txt = txt + ", Setpoint Limit HIGH" ;
        case 3
          txt = txt + ", Setpoint Readback INVALID" ;
        case 4
          txt = txt + ", Setpoint Readback NOT changing" ;
      end
      switch obj.QualState
        case 1
          txt = txt + ", Quality Control Val LOW" ;
        case 2
          txt = txt + ", Quality Control Val HIGH" ;
        case 4
          txt = txt + ", Quality Control Val INVALID" ;
      end
      data = [obj.ControlVal obj.SetpointVal];
      if any(isnan(data)) || any(isinf(data))
        txt = txt + ", Data invalid" ;
      end
      txt = txt + "." ;
    end
  end
  methods(Access=private)
    function ProcDataUpdated(obj)
      persistent lasttic laststate lastvals valc
      nvals=5; % error if unchanging
      if isempty(lastvals)
        lastvals=linspace(1,nvals,nvals);
        valc=1;
      end
      if obj.is_shutdown
        return
      end
      % Reject new values if LimitRate set and not enough time elapsed since last reading
      if obj.LimitRate>0 && ~isempty(lasttic) && toc(lasttic)<obj.LimitRate
        lasttic=tic;
        return;
      elseif obj.LimitRate>0
        lasttic=tic;
      end
      % Read control variable and check status
      obj.ControlState = 0 ;
      if obj.ControlProto=="EPICS"
        obj.ControlVal = caget(obj.ControlVar(1)) ;
      else
        obj.ControlVal = aidaget(obj.ControlVar(1));
      end
      if isnan(obj.ControlVal)
        obj.ControlState = 3 ;
      end
      if obj.ControlVal<obj.ControlLimits(1)
        obj.ControlState = 1 ;
      end
      if obj.ControlVal>obj.ControlLimits(2)
        obj.ControlState = 2 ;
      end
      % Read setpoint variable and check status
      obj.SetpointState = 0 ;
      if isa(obj.SetpointVar,'PV')
        obj.SetpointVal = obj.SetpointVar.val{1} ;
      else
        obj.SetpointVal = obj.SetpointVar.Value ;
      end
      if isempty(obj.SetpointVal) || isnan(obj.SetpointVal)
        obj.SetpointState = 3 ;
      end
      if obj.SetpointVal < obj.SetpointLimits(1)
        obj.SetpointState = 1 ;
        obj.SetpointVal = obj.SetpointLimits(1) ;
      end
      if obj.SetpointVal > obj.SetpointLimits(2)
        obj.SetpointState = 2 ;
        obj.SetpointVal = obj.SetpointLimits(2) ;
      end 
      % Check for repeating values
      if obj.SetpointState == 0
        lastvals(valc) = obj.SetpointVal ;
        valc=valc+1; 
        if valc>nvals; valc=1; end
        if all(lastvals==lastvals(1))
          obj.SetpointState = 4 ;
        end
      end
      if ~isempty(obj.QualVar)
        obj.QualVal = caget(obj.QualVar) ;
        obj.QualState=0;
        if isnan(obj.QualVal) || isinf(obj.QualVal)
          obj.QualState=4;
        end
        if obj.QualVal < obj.QualLimits(1)
          obj.QualState = uint8(1) ;
        elseif obj.QualVal > obj.QualLimits(2)
          obj.QualState = uint8(2) ;
        end
      end
      if ~isempty(obj.ControlStatusVar)
        for ic=1:length(obj.ControlStatusVar)
          obj.ControlStatusVal{ic} = caget(obj.ControlStatusVar{ic}) ;
          goodstat=obj.ControlStatusGood{ic};
          cs=3;
          for istat=1:length(goodstat)
            if isequal(obj.ControlStatusVal{ic},goodstat{istat})
              cs=0;
              break
            end
          end
          if cs==3
            obj.ControlState = 3 ;
          end
        end
      end
      % Process the feedback if enabled and not in error state
      if obj.state==0
        dc = GetFeedback(obj) ;
        if obj.WriteEnable && abs(dc)>0 && ~isnan(dc) && ~isnan(dc)
          if obj.ControlVarType=="doublepm"
            if obj.ControlProto=="EPICS"
              caput(obj.ControlVar(1),obj.ControlVal+dc) ;
              caput(obj.ControlVar(2),-(obj.ControlVal+dc)) ;
            else
              obj.aidaput(obj.ControlVar(1),obj.ControlVal+dc) ;
              obj.aidaput(obj.ControlVar(2),-(obj.ControlVal+dc)) ;
            end
          else
            if obj.ControlProto=="EPICS"
              caput(obj.ControlVar,obj.ControlVal+dc) ;
            else
              obj.aidaput(obj.ControlVar,obj.ControlVal+dc) ;
            end
          end
        end
      end
      if isempty(laststate) || obj.state ~= laststate
        notify(obj,"StateChange") ;
        laststate=obj.state;
      end
      if ~isa(obj.SetpointVar,'PV')
        notify(obj,"DataUpdated");
      end
    end
    function dc = GetFeedback(obj)
      %GETFEEDBACK Get new control variable offset
      dc=0;
      if obj.SetpointState<3
        switch obj.Method
          case "PID"
            if obj.Ki>0 || obj.Kd>0
              error('I and D parts of PID controller not yet implemented');
            end
            dDES = (obj.SetpointVal-obj.SetpointDES) ;
            if dDES < obj.SetpointDeadband(1) || dDES > obj.SetpointDeadband(2)
              dc = dDES * obj.Kp ;
            end
          otherwise
            error('This feedback method not yet implemented');
        end
        if obj.InvertControlVal
          dc=-dc;
        end
      end
    end
    function aidaput(pv,val)
      aidainit;
      import java.util.Vector;
      import edu.stanford.slac.aida.lib.da.DaObject;
      da = DaObject();
      da.setParam('TRIM','NO');
      try
        da.setDaValue(char(pv),DaValue(java.lang.Float(val)));
      catch ME
        fprintf(2,'Error setting AIDA PV: %s\n',pv);
        fprintf(2,'%s',ME.message)
      end
    end
  end
end

