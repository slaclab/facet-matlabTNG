classdef fbSISO < handle
  %FBSISO Generic SISO feedback class
  
  events
    DataUpdated
  end
  properties
    Method string {mustBeMember(Method,"PID")} = "PID"
    Kp {mustBeNonNegative} = 1
    Ki {mustBeNonnegative} = 0
    Kd {mustBeNonnegative} = 0
    LimitRate uint16 = 0 % Limit data acquisition rate if >0 [seconds]
    ControlLimits(1,2) = [-inf,inf] % Limits for ControlVal
    SetpointLimits(1,2) = [-inf,inf] % Limits to setpoint (saturates on limits)
    ControlVal % current control variable value (local)
    SetpointVal % current setpoint value (local)
    SetpointDES = 0 % desired setpoint value
    Enable logical = false
  end
  properties(Dependent)
    state uint8 % overall feedback state; 0=running 1=stopped 2= error
    statestr string % state description
  end
  properties(SetAccess=private)
    Running logical = false
    ControlVar % control variable (PV object)
    SetpointVar % setpoint variable to use (PV or BufferData object)
    ControlState uint8 = 3 % 0=OK, 1=limit low, 2=limit high, 3=Error
    SetpointState uint8 = 3 % 0=OK, 1=limit low, 2=limit high, 3=Error
  end
  properties(Access=private)
    listener
  end
  
  methods
    function obj = fbSISO(controlPV,setpoint)
      %FBSISO
      % FB = fbSISO(controlPV,setpointPV)
      % FB = fbSISO(controlPV,SetPointBufferDataObject)
      if ~exist('controlPV','var') || ~isa(controlPV,'PV')
        error('Must provide PV object for control variable');
      end
      if controlPV.mode ~= "rw"
        error('Control Variable PV does not have write permission');
      end
      if ~exist('setpoint','var') || (~isa(setpoint,'PV') && ~isa(setpoint,'BufferData'))
        error('Must provide either PV or BufferData object for setpoint variable');
      end
      obj.SetpointVar = setpoint ;
      obj.ControlVar = controlPV ;
      obj.listener = addlistener(obj,'DataUpdated',@(~,~) obj.ProcDataUpdated) ;
    end
  end
  % set/get and private methods
  methods
    function set.Enable(obj,val)
      if logical(val)==obj.Enable
        return
      end
      obj.Enable=logical(val);
      if obj.Enable
        if isa(obj.SetpointVar,'PV')
          obj.listener = run(obj.SetpointVar,false,1/0.01,obj,'DataUpdated');
        else
          obj.SetpointVar.Enable=true;
        end
      else
        if isa(obj.SetpointVar,'PV')
          stop(obj.SetpointVar);
        else
          obj.SetpointVar.Enable=false;
        end
        obj.Running=false;
      end
    end
  end
  methods(Access=private)
    function ProcDataUpdated(obj)
      persistent lasttic
      % Reject new values if LimitRate set and not enough time elapsed since last reading
      if obj.LimitRate>0 && ~isempty(lasttic) && toc(lasttic)<obj.LimitRate
        lasttic=tic;
        return;
      elseif obj.LimitRate>0
        lasttic=tic;
      end
      try
        % Read control variable and check status
        obj.ControlState = 0 ;
        obj.ControlVal = caget(obj.ControlVar) ;
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
        if isnan(obj.SetpointVal)
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
        % Error if control variable out of bounds and/or error state
        if obj.ControlState>0
          error('Control Variable in error state');
        end
        % Error if setpoint in error state (at limits OK, keep it saturated here)
        if obj.SetpointState>2
          error('Setpoint Variable in error state');
        end
        % Process the feedback if enabled
        if obj.Enable
          dc = GetFeedback(obj) ;
          caput(obj.ControlVar,obj.ControlVal+dc) ;
        end
        obj.Running=true;
      catch ME
        obj.Running=false;
        fprintf(2,'%s\n',ME.message);
      end
    end
    function dc = GetFeedback(obj)
      %GETFEEDBACK Get neww control variable offset
      if obj.SetpointState<3
        switch obj.Method
          case "PID"
            if obj.Ki>0 || obj.Kd>0
              error('I and D parts of PID controller not yet implemented');
            end
            dc = (obj.SetpointVal-obj.SetpointDES) * obj.Kp ;
          otherwise
            error('This feedback method not yet implemented');
        end
      end
    end
  end
end

