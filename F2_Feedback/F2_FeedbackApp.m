classdef F2_FeedbackApp < handle & F2_common
  events
    PVUpdated 
  end
  properties
    SetpointConversion cell = {[0 1]} % polynomial conversion coefficents for setpoint display (lowest order first)
    GuiEnergyUnits logical = true % Display BPM readings as energy, else raw BPM orbit readings
  end
  properties(SetObservable)
    Enabled uint16 = 0 % Feedback enabled bit
    FeedbackCoefficients cell = {0.06*0.1} % Feedback coefficients for each feedback
    FeedbackControlLimits cell = {[5 40]}
    FeedbackSetpointLimits cell ={[-5e-3 5e-3]}
    SetpointFilterCoefficients cell ={[0.001 0.1]} % low/high frequency settings for filtering
    SetpointFilterTypes string {mustBeMember(SetpointFilterTypes,["notch" "pass"])} = "pass"
    SetpointDoFilter = true % apply filtering to feedback setpoints?
    SetpointOffsets = 0 % Offsets to apply to feedback setpoints
    SetpointDeadbands cell = {[-1e-5 1e-5]}
    TMITLimits cell = {[5e8 5e10]} % Limit feedback operation to these TMIT readings
  end
  properties(Dependent)
    FeedbacksEnabled string % List of feedbacks enabled
  end
  properties(SetAccess=private,Transient)
    guihan
    Feedbacks fbSISO
    pvlist
    pvs
    Disp_DL1 % DL1 dispersion
  end
  properties(Access=private)
    is_shutdown logical = false
  end
  properties(Constant)
    FeedbacksAvailable string = "DL1_E"
    FeedbackEnabledPV string = "SIOC:SYS1:ML00:AO856"
    FeedbackSetpointsPV string = "SIOC:SYS1:ML00:FWF22"
    DL1E_GainPV string = "SIOC:SYS1:ML00:AO857"
    DL1E_OffsetPV string = "SIOC:SYS1:ML00:AO858"
  end
  methods
    function obj = F2_FeedbackApp(guihan)
      %F2_FEEDBACKAPP
      %F2_FeedbackApp([guihan])
      global BEAMLINE
      if exist('guihan','var')
        obj.guihan = guihan ;        
      end
      % Load previously saved state
      if exist(sprintf('%s/F2_Feedback.mat',obj.confdir),'file')
        load(sprintf('%s/F2_Feedback.mat',obj.confdir),'FB');
        obj.FeedbackCoefficients = FB.FeedbackCoefficients ;
        obj.SetpointFilterCoefficients = FB.SetpointFilterCoefficients ;
        obj.SetpointDoFilter = FB.SetpointDoFilter ;
        obj.SetpointOffsets = FB.SetpointOffsets ;
        obj.FeedbackControlLimits = FB.FeedbackControlLimits ;
        obj.FeedbackSetpointLimits = FB.FeedbackSetpointLimits ;
        obj.SetpointFilterTypes = FB.SetpointFilterTypes ;
      end
      % Load model, get dispersions to set conversion values
      load(sprintf('%s/FACET2e/FACET2e.mat',F2_common.modeldir),'BEAMLINE','Initial');
      dl1bpm = findcells(BEAMLINE,'Name','BPM10731') ;
      [~,T]=GetTwiss(1,dl1bpm,Initial.x.Twiss,Initial.y.Twiss);
      obj.Disp_DL1 = T.etax(end) ;
      
      % Generate app pv links
      cntx=PV.Initialize(PVtype.EPICS);
      obj.pvlist = [PV(cntx,'Name',"FeedbackEnable",'pvname',obj.FeedbackEnabledPV,'monitor',true,'mode',"rw");
        PV(cntx,'Name',"FeedbackSetpoints",'pvname',obj.FeedbackSetpointsPV,'monitor',true,'mode',"rw",'nmax',length(obj.FeedbacksAvailable)) ;
        PV(cntx,'Name',"L0BStat1",'pvname',"KLYS:LI10:41:FAULTSEQ_STATUS",'monitor',true) ;
        PV(cntx,'Name',"L0BStat2",'pvname',"KLYS:LI10:41:BEAMCODE10_TSTAT",'monitor',true) ;
        PV(cntx,'Name',"E_DL1",'pvname',"SIOC:SYS1:ML00:AO892",'monitor',true) ;
        PV(cntx,'Name',"DL1E_Gain",'pvname',obj.DL1E_GainPV,'monitor',true) ;
        PV(cntx,'Name',"DL1E_Offset",'pvname',obj.DL1E_OffsetPV,'monitor',true)] ;
      obj.pvs=struct(obj.pvlist);
      
      % Generate feedback links
      % DL1 energy feedback
      DL1_Control=PV(cntx,'name',"Control",'pvname',"KLYS:LI10:41:ADES",'mode',"rw");
      if ~isempty(obj.guihan)
        DL1_Control.guihan = [guihan.EditField_2 guihan.Gauge_3] ;
        DL1_Control.limits = obj.FeedbackControlLimits{1}.*0.98 ;
      end
%       DL1_Control.debug=1;
      DL1_Setpoint=PV(cntx,'name',"Setpoint",'pvname',"BPMS:IN10:731:X1H",'monitor',true,'conv',1e-3);
      B=BufferData('Name',"DL1EnergyBPM",'DoFilter',obj.SetpointDoFilter(1),...
        'FilterType',obj.SetpointFilterTypes(1));
      B.BufferTime = ceil(2/obj.SetpointFilterCoefficients{1}(2)/60) ;
      B.FilterInterval = obj.SetpointFilterCoefficients{1} ;
      B.DataPV = DL1_Setpoint ;
      obj.Feedbacks(1) = fbSISO(DL1_Control,B) ;
      obj.Feedbacks(1).Kp = obj.FeedbackCoefficients{1}(1);
      obj.Feedbacks(1).ControlLimits = obj.FeedbackControlLimits{1} ;
      obj.Feedbacks(1).SetpointLimits = obj.FeedbackSetpointLimits{1} ;
      obj.Feedbacks(1).SetpointDES = obj.SetpointOffsets(1) ;
      obj.Feedbacks(1).QualVar = PV(cntx,'name',"FB1_TMIT",'pvname',"BPMS:IN10:731:TMIT1H") ;
      
      % If GUI being used, suppres local writing to control value operations, that is handled by headless version
      if ~isempty(obj.guihan)
        for ifb=1:length(obj.Feedbacks)
          obj.Feedbacks(ifb).WriteEnable = false ;
        end
      end
      % set enable bits
      obj.Enabled = caget(obj.pvs.FeedbackEnable) ;
      
      % Set event watchers and start PV updaters
      addlistener(obj,'PVUpdated',@(~,~) obj.pvwatcher) ;
      addlistener(obj.Feedbacks(1),'StateChange', @(~,~) obj.statewatcher) ;
      if ~isempty(obj.guihan)
        addlistener(obj.Feedbacks(1),'DataUpdated',@(~,~) obj.DL1Updated) ;
      end
      caget(obj.pvlist); notify(obj,"PVUpdated"); % Initialize states
      run(obj.pvlist,false,0.1,obj,'PVUpdated');
      
      if ~isempty(obj.guihan)
        gainval = obj.pvs.DL1E_Gain.val{1} ;
        obj.guihan.DL1EnergyFeedbckGain0006Menu.Text = "DL1 Energy Feedbck Gain = " + string(gainval) ; 
      end
      
      % Logger
      if isempty(obj.guihan)
        diary('/u1/facet/physics/log/matlab/F2_Feedback.log');
      end
      
    end
    function DL1Updated(obj)
      if obj.is_shutdown
        return
      end
      if ~isempty(obj.guihan)
        ifb=1;
        val = obj.SetpointConversion{ifb}(1) + obj.SetpointConversion{ifb}(2) * obj.Feedbacks(1).SetpointVal ;
        if isnan(val) || isinf(val)
          obj.guihan.Gauge.Value = 0 ;
          obj.guihan.EditField.BackgroundColor = 'black' ;
          obj.guihan.EditField.Value = 0 ;
          obj.guihan.Gauge.BackgroundColor = 'black' ;
          return
        end
        offs = obj.SetpointConversion{ifb}(1) + obj.SetpointConversion{ifb}(2) * obj.SetpointOffsets(1) ;
        valrel = val - offs ;
        db = obj.SetpointConversion{ifb}(1) + obj.SetpointConversion{ifb}(2) .* obj.SetpointDeadbands{1} ;
        lims = sort(obj.SetpointConversion{ifb}(1) + obj.SetpointConversion{ifb}(2) .* obj.FeedbackSetpointLimits{1}); ;
        obj.guihan.Gauge.BackgroundColor = 'white' ;
        if valrel > db(1) && valrel < db(2)
          obj.guihan.Gauge.Value = -25 + 50*(abs(valrel)/range(db)) ;
          obj.guihan.EditField.BackgroundColor = [0.47,0.67,0.19] ;
        elseif val > lims(1) && valrel<db(1)
          obj.guihan.Gauge.Value = -75 + 50*abs(val)/abs(lims(1)-db(1)) ;
          obj.guihan.EditField.BackgroundColor = [0.94,0.94,0.94] ;
        elseif val < lims(2) && val > lims(1)
          obj.guihan.Gauge.Value = 25 + 50*abs(val)/abs(lims(2)-db(2)) ;
          obj.guihan.EditField.BackgroundColor = [0.94,0.94,0.94] ;
        elseif val<lims(1) 
          obj.guihan.Gauge.Value = -90 ;
          obj.guihan.EditField.BackgroundColor = [0.85,0.33,0.10] ;
        else
          obj.guihan.Gauge.Value = 90 ;
          obj.guihan.EditField.BackgroundColor = [0.85,0.33,0.10] ;
        end
        if obj.GuiEnergyUnits
          obj.guihan.EditField.Value = val ;
          obj.guihan.MeVLabel.Text = 'MeV' ;
        else
          obj.guihan.EditField.Value = obj.Feedbacks(1).SetpointVal*1e3 ;
          obj.guihan.MeVLabel.Text = 'mm' ;
        end
        drawnow
      end
    end
    function statewatcher(obj)
      if obj.is_shutdown
        return
      end
      if ~isempty(obj.guihan)
        gh=["StatusLamp" "StatusLamp_3" "StatusLamp_5" "StatusLamp_6" "StatusLamp_2" "StatusLamp_7" "StatusLamp_4"];
        ght=["NotRunningButton"  "NotRunningButton_2" "NotRunningButton_3" "NotRunningButton_4" "NotRunningButton_5" "NotRunningButton_7" "NotRunningButton_6"];
        for ifb=1:length(obj.FeedbacksAvailable)
          switch obj.Feedbacks(ifb).state
            case 0
              obj.guihan.(gh(ifb)).Color = 'green' ;
            case 1
              obj.guihan.(gh(ifb)).Color = 'black' ;
            otherwise
              obj.guihan.(gh(ifb)).Color = 'red' ;
          end
          obj.guihan.(ght(ifb)).Text = obj.Feedbacks(ifb).statestr ;
        end
      end
      fprintf('Feedback status changed:\n');
      for ifb=1:length(obj.FeedbacksAvailable)
        fprintf('%s= %d\n',obj.FeedbacksAvailable(ifb),obj.Feedbacks(ifb).state);
      end
      % Check conversion to MeV consistent with current energy
      E_DL1 = obj.pvs.E_DL1.val{1} ;
      obj.SetpointConversion{1}(2) = 1000 * ( E_DL1 / obj.Disp_DL1 ) ; % m -> MeV
    end
    function pvwatcher(obj)
      if obj.is_shutdown
        return
      end
      obj.Enabled = obj.pvs.FeedbackEnable.val{1} ;
      if ~isequal(obj.pvs.FeedbackSetpoints.val{1},obj.SetpointOffsets)
        obj.SetpointOffsets = obj.pvs.FeedbackSetpoints.val{1} ;
      end
      % Check L0B klystron status and deactivate feedback if not OK
      if string(obj.pvs.L0BStat1.val{1}) ~= "OK" || string(obj.pvs.L0BStat2.val{1}) ~= "Activated"
        obj.Enabled=bitset(obj.Enabled,1,0);
      end
      % Update feedback settings
      obj.FeedbackCoefficients{1}(1) = obj.pvs.DL1E_Gain.val{1} ;
      obj.SetpointOffsets(1) = obj.pvs.DL1E_Offset.val{1}*1e-3 ;
    end
    function shutdown(obj)
      obj.is_shutdown = true ;
      obj.Enabled=0; % register stopped status in PV
      FB = obj ;
      save(sprintf('%s/F2_Feedback.mat',obj.confdir),'FB');
      stop(obj.pvlist);
      for ifb=1:length(obj.FeedbacksAvailable)
        obj.Feedbacks(ifb).shutdown;
      end
    end
  end
  % Set/get and private methods
  methods
    function set.TMITLimits(obj,val)
      if isequal(obj.TMITLimits,val) || length(obj.Feedbacks) ~= length(obj.FeedbacksAvailable)
        return
      end
      disp('Changing TMIT Limits:');
      celldisp(val);
      obj.TMITLimits = val ;
      for ifb=1:length(obj.FeedbacksAvailable)
        obj.Feedbacks(ifb).QualLimits = obj.TMITLimits{ifb} ;
      end
    end
    function set.SetpointDeadbands(obj,val)
      if isequal(obj.SetpointDeadbands,val) || length(obj.Feedbacks) ~= length(obj.FeedbacksAvailable)
        return
      end
      disp('Changing Deadband Limits:');
      celldisp(val);
      obj.SetpointDeadbands = val ;
      for ifb=1:length(obj.FeedbacksAvailable)
        obj.Feedbacks(ifb).SetpointDeadband = obj.SetpointDeadbands{ifb} ;
      end
    end
    function set.SetpointDoFilter(obj,val)
      if isequal(obj.SetpointDoFilter,val) || length(obj.Feedbacks) ~= length(obj.FeedbacksAvailable)
        return
      end
      disp('Changing Filter Use Selection:');
      disp(val);
      obj.SetpointDoFilter = val ;
      for ifb=1:length(obj.FeedbacksAvailable)
        obj.Feedbacks(ifb).ControlVar.DoFilter = obj.SetpointDoFilter(ifb) ;
      end
    end
    function set.SetpointFilterTypes(obj,val)
      if isequal(obj.SetpointFilterTypes,val) || length(obj.Feedbacks) ~= length(obj.FeedbacksAvailable)
        return
      end
      disp('Changing Setpoint Filter Types:');
      disp(val);
      obj.SetpointFilterTypes = val ;
      for ifb=1:length(obj.FeedbacksAvailable)
        obj.Feedbacks(ifb).ControlVar.FilterType = obj.SetpointFilterTypes(ifb) ;
      end
    end
    function set.SetpointFilterCoefficients(obj,val)
      if isequal(obj.SetpointFilterCoefficients,val) || length(obj.Feedbacks) ~= length(obj.FeedbacksAvailable)
        return
      end
      disp('Changing Setpoint Filter Coefficients:');
      celldisp(val)
      obj.SetpointFilterCoefficients = val ;
      for ifb=1:length(obj.FeedbacksAvailable)
        obj.Feedbacks(ifb).ControlVar.FilterInterval = obj.SetpointFilterCoefficients{ifb} ;
      end
    end
    function set.FeedbackSetpointLimits(obj,val)
      if isequal(obj.FeedbackSetpointLimits,val) || length(obj.Feedbacks) ~= length(obj.FeedbacksAvailable)
        return
      end
      disp('Changing Feedback Setpoint Limits:');
      celldisp(val);
      obj.FeedbackSetpointLimits = val ;
      for ifb=1:length(obj.FeedbacksAvailable)
        obj.Feedbacks(ifb).SetpointLimits = obj.FeedbackSetpointLimits{ifb} ;
      end
    end
    function set.FeedbackControlLimits(obj,val)
      if isequal(obj.FeedbackControlLimits,val) || length(obj.Feedbacks) ~= length(obj.FeedbacksAvailable)
        return
      end
      disp('Changing Feedback Control Limits:');
      celldisp(val);
      obj.FeedbackControlLimits = val ;
      for ifb=1:length(obj.FeedbacksAvailable)
        obj.Feedbacks(ifb).ControlLimits = obj.FeedbackControlLimits{ifb} ;
      end
    end
    function set.FeedbackCoefficients(obj,val)
      if isequal(obj.FeedbackCoefficients,val) || length(obj.Feedbacks) ~= length(obj.FeedbacksAvailable)
        return
      end
      disp('Changing Feedback Coefficients:')
      celldisp(val);
      obj.FeedbackCoefficients = val ;
      for ifb=1:length(obj.FeedbacksAvailable)
        if obj.Feedbacks(ifb).Method == "PID"
          obj.Feedbacks(ifb).Kp = obj.FeedbackCoefficients{ifb}(1);
          if length(obj.FeedbackCoefficients{ifb})>1
            obj.Feedbacks(ifb).Ki = obj.FeedbackCoefficients{ifb}(2);
          end
          if length(obj.FeedbackCoefficients{ifb})>2
            obj.Feedbacks(ifb).Kd = obj.FeedbackCoefficients{ifb}(3);
          end
        else
          error('Feedback method not implemented');
        end
      end
    end
    function set.SetpointOffsets(obj,val)
      if isequal(obj.SetpointOffsets,val) || length(obj.Feedbacks) ~= length(obj.FeedbacksAvailable)
        return
      end
      obj.SetpointOffsets=val;
      disp('Changing Setpoint Offsets:');
      disp(val);
      if ~isempty(obj.guihan)
        gh = ["SetpointEditField" "SetpointEditField_3" "SetpointEditField_5" "SetpointEditField_6" "SetpointEditField_2" "SetpointEditField_7" "SetpointEditField_4"];
      end
      for ifb=1:length(obj.FeedbacksAvailable)
        obj.Feedbacks(1).SetpointDES =  obj.SetpointOffsets(ifb) ;
        if ~isempty(obj.guihan)
          if obj.GuiEnergyUnits
            obj.guihan.(gh(ifb)).Value = double(obj.SetpointConversion{ifb}(1) + obj.SetpointConversion{ifb}(2) * obj.SetpointOffsets(ifb)) ;
          else
            obj.guihan.(gh(ifb)).Value = double(obj.SetpointOffsets(ifb)) ;
          end
        end
      end
    end
    function set.Enabled(obj,val)
      if isequal(uint16(val), obj.Enabled) || length(obj.Feedbacks) ~= length(obj.FeedbacksAvailable)
        return
      end
      disp('Changing Feedback Enabled Status:');
      disp(val);
      if ~isempty(obj.guihan)
        switchid=["Switch" "Switch_3" "Switch_5" "Switch_6" "Switch_2" "Switch_7" "Switch_4"];
      end
      obj.Enabled=uint16(val);
      for ifb=1:length(obj.FeedbacksAvailable)
        if bitget(obj.Enabled,ifb)
          obj.Feedbacks(ifb).Enable = true ;
        else
          obj.Feedbacks(ifb).Enable = false ;
        end
        if ~isempty(obj.guihan)
          if bitget(obj.Enabled,ifb)
            obj.guihan.(switchid(ifb)).Value = "On" ;
          else
            obj.guihan.(switchid(ifb)).Value = "Off" ;
          end
        end
      end
      fprintf('Feedback enable status changed:\n');
      for ifb=1:length(obj.FeedbacksAvailable)
        fprintf('%s= %d\n',obj.FeedbacksAvailable(ifb),bitget(obj.Enabled,ifb));
      end
    end
    function feedbacks = get.FeedbacksEnabled(obj)
      feedbacks=string([]);
      for ifb=1:length(obj.FeedbacksAvailable)
        if bitget(obj.Enabled,ifb)
          feedbacks(end+1)=obj.FeedbacksAvailable(ifb);
        end
      end
    end
  end
end