classdef F2_FeedbackApp < handle & F2_common
  %F2_FEEDBACKAPP Support for FACET-II Feedback application
  
  events
    PVUpdated 
  end
  properties
    SetpointConversion cell = {[0 1] [0 1] [0 1] [0 1] [0 1] [0 1]} % polynomial conversion coefficents for setpoint display mm-> MeV if using energy BPMs 
    SettingsGui % Settings applciation GUI pointer
    SettingsGui_whichFeedback uint8 = 0 ;
    RateLimit=0.1;
  end
  properties(SetObservable, AbortSet)
    Enabled uint16 = 0 % Feedback enabled bit
    UseOrbitFit logical = [false true false false false false] % Use orbit fit data for feedback energy determination, else just use energy BPMs and design dispersion values    
    FeedbackCoefficients cell = {0.06*0.1 0.01 0.01 0.01 0.01 0.01} % Feedback coefficients for each feedback
    FeedbackControlLimits cell = {[5 28] [-180 0] [5 60] [10 63] [-180 0] [-180 180]}
    FeedbackSetpointLimits cell ={[-5 5] [-15 15] [-10 10] [0 100] [-10 10] [-100 100]}
    SetpointFilterCoefficients cell ={[0.001 0.1] [0.001 0.1] [0.001 0.1] [0.001 0.1] [0.001 0.1] [0.001 0.1]} % low/high frequency settings for filtering
    SetpointFilterTypes string {mustBeMember(SetpointFilterTypes,["notch" "pass"])} = ["pass" "pass" "pass" "pass" "pass" "pass"]
    SetpointDoFilter logical = [false false false false false] % apply filtering to feedback setpoints?
    SetpointOffsets = [0 0 0 0 0 20] % Offsets to apply to feedback setpoints
    SetpointDeadbands cell = {[-0.2 0.2] [-0.2 0.2] [-0.2 0.2] [-0.01 0.01] [-0.1 0.1] [50 51]} % mm
    TMITLimits cell = {[0.1 50] [0.1 50] [0.1 50] [0.1 50] [0.1 50] [0.1 50]} % Limit feedback operation to these TMIT readings (Nele * 1e9)
    BC20E_mkb string {mustBeMember(BC20E_mkb,["S20_ENERGY_3AND4","S20_ENERGY_4AND5","S20_ENERGY_4AND6" "S20_ENERGY_3AND5"])} = "S20_ENERGY_3AND4"
    BC14E_mkb string {mustBeMember(BC14E_mkb,["BC14_ENERGY_4AND5","BC14_ENERGY_5AND6","BC14_ENERGY_4AND6"])} = "BC14_ENERGY_4AND5"
  end
  properties(Dependent)
    FeedbacksEnabled string % List of feedbacks enabled (tests Enabled bit)
    BC20E_ControlDevs string % Klystrons used for BC20E feedback
    BC20E_ControlStatusPV string % Status PVs used for BC20E feedback
    BC14E_ControlDevs string % Klystrons used for BC14E feedback
    BC14E_ControlStatusPV string % Status PVs used for BC14E feedback
  end
  properties(SetAccess=private,Transient)
    guihan
    Feedbacks fbSISO
    pvlist
    pvs
    Disp_DL1 % DL1 BPM dispersion
    Disp_BC11 % BC11 BPM dispersion
    Disp_BC14 % BC14 BPM dispersion
    Disp_BC20 % BC20 BPM dispersion
    RunningStatus
    Rfb(4,2) % transverse feedbacks response matrices
    LM % Lucretia live model
    ANG2BDES(1,4) % Angle to bdes corrector conversions
  end
  properties(Access=private)
    is_shutdown logical = false
    to % Running timer object
    pvcntx % context object
    fbinit logical = false % set to true after Feedbacks initialized the first time (data PVs set to run mode)
  end
  properties(Constant)
    UseFeedbacks logical = [true true true true true true]
    FeedbacksAvailable string = ["DL1E" "BC14E" "BC11E" "BC11BL" "BC20E" "BC14BL"]
    FeedbackEnabledPV string = "SIOC:SYS1:ML00:AO856"
    DL1E_GainPV string = "SIOC:SYS1:ML00:AO857"
    DL1E_OffsetPV string = "SIOC:SYS1:ML00:AO858"
    BC14E_GainPV string = "SIOC:SYS1:ML00:AO897"
    BC14E_OffsetPV string = "SIOC:SYS1:ML00:AO898"
    BC11E_GainPV string = "SIOC:SYS1:ML01:AO206"
    BC11E_OffsetPV string = "SIOC:SYS1:ML01:AO207"
    BC11BL_GainPV string = "SIOC:SYS1:ML01:AO220"
    BC11BL_OffsetPV string = "SIOC:SYS1:ML01:AO221"
    BC20E_OffsetPV string = "SIOC:SYS1:ML01:AO234"
    BC20E_GainPV string = "SIOC:SYS1:ML01:AO235"
    BC14BL_GainPV string = "SIOC:SYS1:ML01:AO246"
    BC14BL_OffsetPV string = "SIOC:SYS1:ML01:AO247"
    FbRunningPV string = "F2:WATCHER:FEEDBACKS_STAT"
    FbStatusPV string = "SIOC:SYS1:ML00:AO859" ;
    GuiUpdateRate = 1 % rate to limit GUI updates
    ControlMonitorPV string = "SIOC:SYS1:ML01:AO"+(257:262)  % PVs to mirror feedback control output
  end
  methods
    function obj = F2_FeedbackApp(guihan)
      %F2_FEEDBACKAPP
      %F2_FeedbackApp([guihan])
      global BEAMLINE
      if exist('guihan','var')
        obj.guihan = guihan ;
        drawnow
      end
      
      % Load model, get design dispersions to set conversion values
      load(F2_common.LucretiaLattice,'BEAMLINE','Initial');
      dl1bpm = findcells(BEAMLINE,'Name','BPM10731') ;
      bc20bpm = findcells(BEAMLINE,'Name','M1E') ;
      bc14bpm = findcells(BEAMLINE,'Name','BPM14801') ;
      bc11bpm = findcells(BEAMLINE,'Name','BPM11333') ;
      [~,T]=GetTwiss(1,bc20bpm,Initial.x.Twiss,Initial.y.Twiss);
      obj.Disp_DL1 = T.etax(dl1bpm) ;
      obj.Disp_BC11 = T.etax(bc11bpm) ;
      obj.Disp_BC14 = T.etax(bc14bpm) ;
      obj.Disp_BC20 = T.etax(bc20bpm) ;
      
      % Generate app pv links
      cntx=PV.Initialize(PVtype.EPICS);
      obj.pvcntx = cntx;
      obj.pvlist = [PV(cntx,'Name',"FeedbackEnable",'pvname',obj.FeedbackEnabledPV,'monitor',true,'mode',"rw");
        PV(cntx,'Name',"L0BStat1",'pvname',"KLYS:LI10:41:FAULTSEQ_STATUS",'monitor',true) ;
        PV(cntx,'Name',"L0BStat2",'pvname',"KLYS:LI10:41:BEAMCODE10_TSTAT",'monitor',true) ;
        PV(cntx,'Name',"Watchdog",'pvname',obj.FbRunningPV) ;
        PV(cntx,'Name',"UseOrbitFit",'pvname',"SIOC:SYS1:ML01:AO267",'monitor',true) ] ;
      if obj.UseFeedbacks(1)
        obj.pvlist = [obj.pvlist;
        PV(cntx,'Name',"E_DL1",'pvname',"SIOC:SYS1:ML00:AO892",'monitor',true) ;
        PV(cntx,'Name',"DL1E_Gain",'pvname',obj.DL1E_GainPV,'monitor',true,'mode','rw') ;
        PV(cntx,'Name',"DL1E_Offset",'pvname',obj.DL1E_OffsetPV,'monitor',true,'mode','rw');
        PV(cntx,'Name',"DL1E_ControlLimitLo",'pvname',"SIOC:SYS1:ML00:AO937",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"DL1E_ControlLimitHi",'pvname',"SIOC:SYS1:ML00:AO938",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"DL1E_SetpointLimitLo",'pvname',"SIOC:SYS1:ML00:AO939",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"DL1E_SetpointLimitHi",'pvname',"SIOC:SYS1:ML00:AO940",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"DL1E_SetpointFilterFreq",'pvname',"SIOC:SYS1:ML00:AO941",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"DL1E_SetpointDeadbandLo",'pvname',"SIOC:SYS1:ML00:AO942",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"DL1E_SetpointDeadbandHi",'pvname',"SIOC:SYS1:ML00:AO943",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"DL1E_TMITLo",'pvname',"SIOC:SYS1:ML00:AO944",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"DL1E_TMITHi",'pvname',"SIOC:SYS1:ML00:AO945",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"DL1E_JitterON",'pvname',"SIOC:SYS1:ML01:AO217",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"DL1E_JitterAMP",'pvname',"SIOC:SYS1:ML01:AO218",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"FB_JitterOnTime",'pvname',"SIOC:SYS1:ML01:AO219",'monitor',true,'mode',"rw")];
      end
      if obj.UseFeedbacks(2)
        obj.pvlist= [obj.pvlist;
        PV(cntx,'Name',"E_BC14",'pvname',"SIOC:SYS1:ML00:AO894",'monitor',true) ;
        PV(cntx,'Name',"BC14E_Gain",'pvname',obj.BC14E_GainPV,'monitor',true,'mode','rw') ;
        PV(cntx,'Name',"BC14E_Offset",'pvname',obj.BC14E_OffsetPV,'monitor',true,'mode','rw');
        PV(cntx,'Name',"BC14E_ControlLimitLo",'pvname',"SIOC:SYS1:ML00:AO946",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC14E_ControlLimitHi",'pvname',"SIOC:SYS1:ML00:AO947",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC14E_SetpointLimitLo",'pvname',"SIOC:SYS1:ML00:AO948",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC14E_SetpointLimitHi",'pvname',"SIOC:SYS1:ML00:AO949",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC14E_SetpointFilterFreq",'pvname',"SIOC:SYS1:ML01:AO201",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC14E_SetpointDeadbandLo",'pvname',"SIOC:SYS1:ML01:AO202",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC14E_SetpointDeadbandHi",'pvname',"SIOC:SYS1:ML01:AO203",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC14E_TMITLo",'pvname',"SIOC:SYS1:ML01:AO204",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC14E_TMITHi",'pvname',"SIOC:SYS1:ML01:AO205",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC14E_mkname",'pvname',"SIOC:SYS1:ML01:AO245.DESC",'monitor',true,'mode',"rw") ];
      end
      if obj.UseFeedbacks(3)
        obj.pvlist = [obj.pvlist;
        PV(cntx,'Name',"E_BC11",'pvname',"SIOC:SYS1:ML00:AO893",'monitor',true) ;
        PV(cntx,'Name',"BC11E_Gain",'pvname',obj.BC11E_GainPV,'monitor',true,'mode','rw') ;
        PV(cntx,'Name',"BC11E_Offset",'pvname',obj.BC11E_OffsetPV,'monitor',true,'mode','rw');
        PV(cntx,'Name',"BC11E_ControlLimitLo",'pvname',"SIOC:SYS1:ML01:AO208",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC11E_ControlLimitHi",'pvname',"SIOC:SYS1:ML01:AO209",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC11E_SetpointLimitLo",'pvname',"SIOC:SYS1:ML01:AO210",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC11E_SetpointLimitHi",'pvname',"SIOC:SYS1:ML01:AO211",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC11E_SetpointFilterFreq",'pvname',"SIOC:SYS1:ML01:AO212",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC11E_SetpointDeadbandLo",'pvname',"SIOC:SYS1:ML01:AO213",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC11E_SetpointDeadbandHi",'pvname',"SIOC:SYS1:ML01:AO214",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC11E_TMITLo",'pvname',"SIOC:SYS1:ML01:AO215",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC11E_TMITHi",'pvname',"SIOC:SYS1:ML01:AO216",'monitor',true,'mode',"rw")];
      end
      if obj.UseFeedbacks(4)
        obj.pvlist = [obj.pvlist;
        PV(cntx,'Name',"BC11BL_Gain",'pvname',obj.BC11BL_GainPV,'monitor',true,'mode','rw') ;
        PV(cntx,'Name',"BC11BL_Offset",'pvname',obj.BC11BL_OffsetPV,'monitor',true,'mode','rw');
        PV(cntx,'Name',"BC11BL_ControlLimitLo",'pvname',"SIOC:SYS1:ML01:AO222",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC11BL_ControlLimitHi",'pvname',"SIOC:SYS1:ML01:AO223",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC11BL_SetpointLimitLo",'pvname',"SIOC:SYS1:ML01:AO224",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC11BL_SetpointLimitHi",'pvname',"SIOC:SYS1:ML01:AO225",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC11BL_SetpointFilterFreq",'pvname',"SIOC:SYS1:ML01:AO226",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC11BL_SetpointDeadbandLo",'pvname',"SIOC:SYS1:ML01:AO227",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC11BL_SetpointDeadbandHi",'pvname',"SIOC:SYS1:ML01:AO228",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC11BL_TMITLo",'pvname',"SIOC:SYS1:ML01:AO229",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC11BL_TMITHi",'pvname',"SIOC:SYS1:ML01:AO230",'monitor',true,'mode',"rw")];
      end
      if obj.UseFeedbacks(5)
        obj.pvlist = [obj.pvlist;
        PV(cntx,'Name',"E_BC20",'pvname',"SIOC:SYS1:ML00:AO895",'monitor',true) ;
        PV(cntx,'Name',"BC20E_Gain",'pvname',obj.BC20E_GainPV,'monitor',true,'mode','rw') ;
        PV(cntx,'Name',"BC20E_Offset",'pvname',obj.BC20E_OffsetPV,'monitor',true,'mode','rw');
        PV(cntx,'Name',"BC20E_ControlLimitLo",'pvname',"SIOC:SYS1:ML01:AO233",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC20E_ControlLimitHi",'pvname',"SIOC:SYS1:ML01:AO236",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC20E_SetpointLimitLo",'pvname',"SIOC:SYS1:ML01:AO237",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC20E_SetpointLimitHi",'pvname',"SIOC:SYS1:ML01:AO238",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC20E_SetpointFilterFreq",'pvname',"SIOC:SYS1:ML01:AO239",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC20E_SetpointDeadbandLo",'pvname',"SIOC:SYS1:ML01:AO240",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC20E_SetpointDeadbandHi",'pvname',"SIOC:SYS1:ML01:AO241",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC20E_TMITLo",'pvname',"SIOC:SYS1:ML01:AO242",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC20E_TMITHi",'pvname',"SIOC:SYS1:ML01:AO243",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC20E_Control1",'pvname',"LI19:KLYS:31:PDES",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC20E_Control2",'pvname',"LI19:KLYS:41:PDES",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC20E_mkname",'pvname',"SIOC:SYS1:ML01:AO244.DESC",'monitor',true,'mode',"rw") ];
      end
      if obj.UseFeedbacks(6)
        obj.pvlist = [obj.pvlist;
        PV(cntx,'Name',"BC14BL_Gain",'pvname',obj.BC14BL_GainPV,'monitor',true,'mode','rw') ;
        PV(cntx,'Name',"BC14BL_Offset",'pvname',obj.BC14BL_OffsetPV,'monitor',true,'mode','rw');
        PV(cntx,'Name',"BC14BL_ControlLimitLo",'pvname',"SIOC:SYS1:ML01:AO248",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC14BL_ControlLimitHi",'pvname',"SIOC:SYS1:ML01:AO249",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC14BL_SetpointLimitLo",'pvname',"SIOC:SYS1:ML01:AO250",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC14BL_SetpointLimitHi",'pvname',"SIOC:SYS1:ML01:AO251",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC14BL_SetpointFilterFreq",'pvname',"SIOC:SYS1:ML01:AO252",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC14BL_SetpointDeadbandLo",'pvname',"SIOC:SYS1:ML01:AO253",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC14BL_SetpointDeadbandHi",'pvname',"SIOC:SYS1:ML01:AO254",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC14BL_TMITLo",'pvname',"SIOC:SYS1:ML01:AO255",'monitor',true,'mode',"rw");
        PV(cntx,'Name',"BC14BL_TMITHi",'pvname',"SIOC:SYS1:ML01:AO256",'monitor',true,'mode',"rw")];
      end
      
      % Attach feedback running status PV
      obj.pvlist(end+1) = PV(cntx,'Name',"FB_RUNNING",'pvname',obj.FbRunningPV,'monitor',true) ;
      
      % Get design L1/L2/L3 phases
%       obj.pvlist(end+1) = PV(cntx,'Name',"L1DesignPhase",'pvname',F2_klys.DesignPhasesPV(1),'monitor',true) ;
%       obj.pvlist(end+1) = PV(cntx,'Name',"L2DesignPhase",'pvname',F2_klys.DesignPhasesPV(2),'monitor',true) ;
%       obj.pvlist(end+1) = PV(cntx,'Name',"L3DesignPhase",'pvname',F2_klys.DesignPhasesPV(3),'monitor',true) ;
      
      % Make pv list structure
      obj.pvs=struct(obj.pvlist);
      
      % Generate feedback objects
      for ifb=find(obj.UseFeedbacks)
        try
          disp(sprintf('initializing %s feedback',obj.FeedbacksAvailable(ifb)))
          obj.FeedbackGen(ifb);
        catch ME
          if ~isempty(obj.guihan)
            errordlg(sprintf('Error initializing %s feedback, see command window',obj.FeedbacksAvailable(ifb)),'Feedback init error');
          end
          throw(ME);
        end
      end
      
      % If GUI being used, suppres local writing to control value operations, that is handled by watcher version
      if ~isempty(obj.guihan)
        for ifb=find(obj.UseFeedbacks)
          obj.Feedbacks(ifb).WriteEnable = false ;
        end
      end
      
      % set enable bits
      obj.Enabled = caget(obj.pvs.FeedbackEnable) ;
      
      caget(obj.pvlist); notify(obj,"PVUpdated"); % Initialize states
      
      % Timer to keep watchdog PV updated
      % (in gui mode this just keeps the BC20E controls updated)
      obj.to=timer('Period',1,'ExecutionMode','fixedRate','TimerFcn',@(~,~) obj.RunningTimer);
      start(obj.to);
      
      % Logger
      if isempty(obj.guihan)
        diary('/u1/facet/physics/log/matlab/F2_Feedback.log');
      end
      
      % Disable de-selected feedback controls
      if ~isempty(obj.guihan)
        swname=["Switch" "Switch_2" "Switch_5" "Switch_6" "Switch_4" "Switch_7"];
        for ifb=find(~obj.UseFeedbacks)
          obj.guihan.(swname(ifb)).Enable = false ;
        end
      end
      
      obj.pvwatcher;
      obj.statewatcher;
      
      % Set event watchers and start PV updaters
      addlistener(obj,'PVUpdated',@(~,~) obj.pvwatcher) ;
      for ifb=find(obj.UseFeedbacks)
        addlistener(obj.Feedbacks(ifb),'StateChange', @(~,~) obj.statewatcher) ;
      end
      run(obj.pvlist,false,1,obj,'PVUpdated');
      
      % Start data collecting and feedback processing on all feedback objects
      for ifb=find(obj.UseFeedbacks)
        obj.Feedbacks(ifb).Run;
      end
      obj.fbinit=true;
      
      % Link data updater methods to each feedback object for updating GUI display
      if ~isempty(obj.guihan)
        if obj.UseFeedbacks(1)
          addlistener(obj.Feedbacks(1),'DataUpdated',@(~,~) obj.DL1Updated) ;
        end
        if obj.UseFeedbacks(2)
          addlistener(obj.Feedbacks(2),'DataUpdated',@(~,~) obj.BC14Updated) ;
        end
        if obj.UseFeedbacks(3)
          addlistener(obj.Feedbacks(3),'DataUpdated',@(~,~) obj.BC11Updated) ;
        end
        if obj.UseFeedbacks(4)
          addlistener(obj.Feedbacks(4),'DataUpdated',@(~,~) obj.BC11BLUpdated) ;
        end
        if obj.UseFeedbacks(5)
          addlistener(obj.Feedbacks(5),'DataUpdated',@(~,~) obj.BC20Updated) ;
        end
        if obj.UseFeedbacks(6)
          addlistener(obj.Feedbacks(6),'DataUpdated',@(~,~) obj.BC14BLUpdated) ;
        end
      end
      
    end
    function SettingsGuiLink(obj,gh,cmd)
      %DL1ESETTINGSGUI Attach or remove links to settings GUI Edit fields
      fn=fieldnames(gh);
      for ifn=1:length(fn)
        if cmd=="Attach"
          obj.pvs.(fn{ifn}).guihan = gh.(fn{ifn});
        elseif cmd=="Detach"
          obj.pvs.(fn{ifn}).guihan = [] ;
        end
      end
    end
    function RunningTimer(obj)
      %RUNNINGTIMER Keep watchdog PV updated
      if ~isempty(obj.guihan) % for GUI application, force BC20E controls to be updated as BPMS don't update if no TMIT
        obj.BC20Updated;
        return
      end
      caput(obj.pvs.Watchdog,'RUNNING');
      % Write to status PV bit to indicate if not running
      newval=lcaGet(char(obj.FbStatusPV));
      for ifb=find(obj.UseFeedbacks)
        if obj.Feedbacks(ifb).state>0
          newval=bitset(newval,ifb,0);
        else
          newval=bitset(newval,ifb,1);
        end
      end
      lcaPutNoWait(char(obj.FbStatusPV),newval);
    end
    function DL1Updated(obj)
      if obj.is_shutdown
        return
      end
      ifb=1;
      
      % Controls values
      obj.guihan.EditField_2.Value = obj.Feedbacks(ifb).ControlVal ;
      obj.guihan.Gauge_3.Value = obj.Feedbacks(ifb).ControlVal ;
      obj.guihan.Gauge_3.ScaleColors = [1,0,0;1,0,0;0.39,0.83,0.07] ;
      obj.guihan.Gauge_3.ScaleColorLimits = [0,obj.FeedbackControlLimits{ifb}(1);obj.FeedbackControlLimits{ifb}(2),obj.FeedbackControlLimits{ifb}(2)+10;obj.FeedbackControlLimits{ifb}(1),obj.FeedbackControlLimits{ifb}(2)] ;
      obj.guihan.Gauge_3.Limits = [0,obj.FeedbackControlLimits{ifb}(2)+10] ;
      if obj.Feedbacks(ifb).ControlVal >= obj.FeedbackControlLimits{ifb}(2) || obj.Feedbacks(ifb).ControlVal <= obj.FeedbackControlLimits{ifb}(1)
        obj.guihan.EditField_2.BackgroundColor='red';
      else
        obj.guihan.EditField_2.BackgroundColor='white';
      end
      
      % Setpoint update
      val = obj.Feedbacks(1).SetpointVal ;
      if isempty(val) || isnan(val) || isinf(val)
        obj.guihan.Gauge.Value = 0 ;
        obj.guihan.EditField.BackgroundColor = 'black' ;
        obj.guihan.EditField.Value = 0 ;
        obj.guihan.Gauge.BackgroundColor = 'black' ;
        drawnow limitrate
        return
      end
      offs = obj.SetpointOffsets(1) ;
      valrel = double(val - offs) ;
      db = obj.SetpointDeadbands{1} ;
      lims = obj.FeedbackSetpointLimits{1} ;
      obj.guihan.Gauge.BackgroundColor = 'white' ;
      if valrel > db(1) && valrel < db(2)
        obj.guihan.Gauge.Value = 50*(valrel/range(db)) ;
        obj.guihan.EditField.BackgroundColor = [0.47,0.67,0.19] ;
      elseif val > lims(1) && valrel<db(1)
        obj.guihan.Gauge.Value = -75 + 50*(1-abs(val)/abs(lims(1)-db(1))) ;
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
      obj.guihan.EditField.Value = val;
      drawnow limitrate
    end
    function BC14Updated(obj)
      if obj.is_shutdown
        return
      end
      ifb=2;
      val = obj.Feedbacks(ifb).SetpointVal ;
      if isempty(val) || isnan(val) || isinf(val)
        obj.guihan.Gauge_6.Value = 0 ;
        obj.guihan.EditField_5.BackgroundColor = 'black' ;
        obj.guihan.EditField_5.Value = 0 ;
        obj.guihan.Gauge_6.BackgroundColor = 'black' ;
      else
        offs = obj.SetpointOffsets(ifb) ;
        valrel = double(val - offs) ;
        db = obj.SetpointDeadbands{ifb} ;
        lims = obj.FeedbackSetpointLimits{ifb} ;
        obj.guihan.Gauge_6.BackgroundColor = 'white' ;
        if valrel > db(1) && valrel < db(2)
          obj.guihan.Gauge_6.Value = 50*(valrel/range(db)) ;
          obj.guihan.EditField_5.BackgroundColor = [0.47,0.67,0.19] ;
        elseif val > lims(1) && valrel<db(1)
          obj.guihan.Gauge_6.Value = -75 + 50*(1-abs(val)/abs(lims(1)-db(1))) ;
          obj.guihan.EditField_5.BackgroundColor = [0.94,0.94,0.94] ;
        elseif val < lims(2) && val > lims(1)
          obj.guihan.Gauge_6.Value = 25 + 50*abs(val)/abs(lims(2)-db(2)) ;
          obj.guihan.EditField_5.BackgroundColor = [0.94,0.94,0.94] ;
        elseif val<lims(1)
          obj.guihan.Gauge_6.Value = 90 ;
          obj.guihan.EditField_5.BackgroundColor = [0.85,0.33,0.10] ;
        else
          obj.guihan.Gauge_6.Value = -90 ;
          obj.guihan.EditField_5.BackgroundColor = [0.85,0.33,0.10] ;
        end
        obj.guihan.EditField_5.Value = val;
      end
      if isempty(obj.Feedbacks(ifb).ControlReadVar(1).val)
        caget(obj.Feedbacks(ifb).ControlReadVar(1));
      end
      obj.guihan.EditField_6.Value = obj.Feedbacks(ifb).ControlReadVar(1).val{1} ;
      obj.guihan.Gauge_16.Value = obj.Feedbacks(ifb).ControlReadVar(1).val{1} ;
      obj.guihan.Gauge_17.Value = -obj.Feedbacks(ifb).ControlReadVar(1).val{1} ;
      if obj.Feedbacks(ifb).ControlReadVar.val{1} >= obj.FeedbackControlLimits{ifb}(2) || obj.Feedbacks(ifb).ControlReadVar.val{1} <= obj.FeedbackControlLimits{ifb}(1)
        obj.guihan.EditField_6.BackgroundColor='red';
      else
        obj.guihan.EditField_6.BackgroundColor='white';
      end
      drawnow limitrate
    end
    function BC11Updated(obj)
      if obj.is_shutdown
        return
      end
      ifb=3;
      val = obj.Feedbacks(ifb).SetpointVal ;
      if isempty(val) || isnan(val) || isinf(val)
        obj.guihan.Gauge_8.Value = 0 ;
        obj.guihan.EditField_11.BackgroundColor = 'black' ;
        obj.guihan.EditField_11.Value = 0 ;
        obj.guihan.Gauge_8.BackgroundColor = 'black' ;
      else
        offs = obj.SetpointOffsets(ifb) ;
        valrel = double(val - offs) ;
        db = obj.SetpointDeadbands{ifb} ;
        lims = obj.FeedbackSetpointLimits{ifb} ;
        obj.guihan.Gauge_8.BackgroundColor = 'white' ;
        if valrel > db(1) && valrel < db(2)
          obj.guihan.Gauge_8.Value = 50*(valrel/range(db)) ;
          obj.guihan.EditField_11.BackgroundColor = [0.47,0.67,0.19] ;
        elseif val > lims(1) && valrel<db(1)
          obj.guihan.Gauge_8.Value = -75 + 50*(1-abs(val)/abs(lims(1)-db(1))) ;
          obj.guihan.EditField_11.BackgroundColor = [0.94,0.94,0.94] ;
        elseif val < lims(2) && val > lims(1)
          obj.guihan.Gauge_8.Value = 25 + 50*abs(val)/abs(lims(2)-db(2)) ;
          obj.guihan.EditField_11.BackgroundColor = [0.94,0.94,0.94] ;
        elseif val<lims(1)
          obj.guihan.Gauge_8.Value = -90 ;
          obj.guihan.EditField_11.BackgroundColor = [0.85,0.33,0.10] ;
        else
          obj.guihan.Gauge_8.Value = 90 ;
          obj.guihan.EditField_11.BackgroundColor = [0.85,0.33,0.10] ;
        end
        obj.guihan.EditField_11.Value = val;
      end
      obj.guihan.EditField_12.Value = obj.Feedbacks(ifb).ControlVal ;
      obj.guihan.Gauge_9.Value = obj.Feedbacks(ifb).ControlVal ;
      obj.guihan.Gauge_9.ScaleColors = [1,0,0;1,0,0;0.39,0.83,0.07] ;
      obj.guihan.Gauge_9.ScaleColorLimits = [-10,obj.FeedbackControlLimits{ifb}(1);obj.FeedbackControlLimits{ifb}(2),obj.FeedbackControlLimits{ifb}(2)+10;obj.FeedbackControlLimits{ifb}(1),obj.FeedbackControlLimits{ifb}(2)] ;
      obj.guihan.Gauge_9.Limits = [0,obj.FeedbackControlLimits{ifb}(2)+10] ;
      if obj.Feedbacks(ifb).ControlVal >= obj.FeedbackControlLimits{ifb}(2) || obj.Feedbacks(ifb).ControlVal <= obj.FeedbackControlLimits{ifb}(1)
        obj.guihan.EditField_12.BackgroundColor='red';
      else
        obj.guihan.EditField_12.BackgroundColor='white';
      end
      drawnow limitrate
    end
    function BC11BLUpdated(obj)
      if obj.is_shutdown
        return
      end
      ifb=4;
      % Controls values
      obj.guihan.EditField_14.Value = obj.Feedbacks(ifb).ControlVal ;
      obj.guihan.Gauge_11.Value = obj.Feedbacks(ifb).ControlVal ;
      obj.guihan.Gauge_11.ScaleColors = [1,0,0;1,0,0;0.39,0.83,0.07] ;
      obj.guihan.Gauge_11.ScaleColorLimits = [obj.FeedbackControlLimits{ifb}(1)-10,obj.FeedbackControlLimits{ifb}(1);obj.FeedbackControlLimits{ifb}(2),obj.FeedbackControlLimits{ifb}(2)+10;obj.FeedbackControlLimits{ifb}(1),obj.FeedbackControlLimits{ifb}(2)] ;
      obj.guihan.Gauge_11.Limits = [obj.FeedbackControlLimits{ifb}(1)-10,obj.FeedbackControlLimits{ifb}(2)+10] ;
      if obj.Feedbacks(ifb).ControlVal >= obj.FeedbackControlLimits{ifb}(2) || obj.Feedbacks(ifb).ControlVal <= obj.FeedbackControlLimits{ifb}(1)
        obj.guihan.EditField_14.BackgroundColor='red';
      else
        obj.guihan.EditField_14.BackgroundColor='white';
      end
      
      % Setpoint update
      val = obj.Feedbacks(ifb).SetpointVal ;
      if isempty(val) || isnan(val) || isinf(val)
        obj.guihan.Gauge_10.Value = 0 ;
        obj.guihan.EditField_13.BackgroundColor = 'black' ;
        obj.guihan.EditField_13.Value = 0 ;
        obj.guihan.Gauge_10.BackgroundColor = 'black' ;
        drawnow limitrate
        return
      end
      offs = obj.SetpointOffsets(ifb) ;
      valrel = double(val - offs) ;
      db = obj.SetpointDeadbands{ifb} ;
      lims = obj.FeedbackSetpointLimits{ifb} ;
      obj.guihan.Gauge_10.BackgroundColor = 'white' ;
      if valrel > db(1) && valrel < db(2)
        obj.guihan.Gauge_10.Value = 50*(valrel/range(db)) ;
        obj.guihan.EditField_13.BackgroundColor = [0.47,0.67,0.19] ;
      elseif val > lims(1) && valrel<db(1)
        obj.guihan.Gauge_10.Value = -75 + 50*abs(val)/abs(lims(1)-(offs-db(1))) ;
        obj.guihan.EditField_13.BackgroundColor = [0.94,0.94,0.94] ;
      elseif val < lims(2) && val > lims(1)
        obj.guihan.Gauge_10.Value = 25 + 50*abs(val)/abs(lims(2)-db(2)) ;
        obj.guihan.EditField_13.BackgroundColor = [0.94,0.94,0.94] ;
      elseif val<lims(1)
        obj.guihan.Gauge_10.Value = -90 ;
        obj.guihan.EditField_13.BackgroundColor = [0.85,0.33,0.10] ;
      else
        obj.guihan.Gauge_10.Value = 90 ;
        obj.guihan.EditField_13.BackgroundColor = [0.85,0.33,0.10] ;
      end
      obj.guihan.EditField_13.Value = val;
      drawnow limitrate
    end
    function BC20Updated(obj)
      if obj.is_shutdown
        return
      end
      ifb=5;
      val = obj.Feedbacks(ifb).SetpointVal ;
      if isempty(val) || isnan(val) || isinf(val)
        obj.guihan.Gauge_7.Value = 0 ;
        obj.guihan.EditField_8.BackgroundColor = 'black' ;
        obj.guihan.EditField_8.Value = 0 ;
        obj.guihan.Gauge_7.BackgroundColor = 'black' ;
      else
        offs = obj.SetpointOffsets(ifb) ;
        valrel = double(val - offs) ;
        db = obj.SetpointDeadbands{ifb} ;
        lims = obj.FeedbackSetpointLimits{ifb} ;
        obj.guihan.Gauge_7.BackgroundColor = 'white' ;
        if valrel > db(1) && valrel < db(2)
          obj.guihan.Gauge_7.Value = 50*(valrel/range(db)) ;
          obj.guihan.EditField_8.BackgroundColor = [0.47,0.67,0.19] ;
        elseif val > lims(1) && valrel<db(1)
          obj.guihan.Gauge_7.Value = -75 + 50*(1-abs(val)/abs(lims(1)-db(1))) ;
          obj.guihan.EditField_8.BackgroundColor = [0.94,0.94,0.94] ;
        elseif val < lims(2) && val > lims(1)
          obj.guihan.Gauge_7.Value = 25 + 50*abs(val)/abs(lims(2)-db(2)) ;
          obj.guihan.EditField_8.BackgroundColor = [0.94,0.94,0.94] ;
        elseif val<lims(1)
          obj.guihan.Gauge_7.Value = 90 ;
          obj.guihan.EditField_8.BackgroundColor = [0.85,0.33,0.10] ;
        else
          obj.guihan.Gauge_7.Value = -90 ;
          obj.guihan.EditField_8.BackgroundColor = [0.85,0.33,0.10] ;
        end
        obj.guihan.EditField_8.Value = val;
      end
      if isempty(obj.Feedbacks(ifb).ControlReadVar(1).val)
        caget(obj.Feedbacks(ifb).ControlReadVar(1));
      end
      obj.guihan.EditField_17.Value = caget(obj.Feedbacks(ifb).ControlReadVar(1)) ;
      obj.guihan.Gauge_19.Value = obj.Feedbacks(ifb).ControlReadVar(1).val{1} ;
      obj.guihan.Gauge_20.Value = -obj.Feedbacks(ifb).ControlReadVar(1).val{1} ;
      if obj.Feedbacks(ifb).ControlReadVar(1).val{1} >= obj.FeedbackControlLimits{ifb}(2) || obj.Feedbacks(ifb).ControlReadVar(1).val{1} <= obj.FeedbackControlLimits{ifb}(1)
        obj.guihan.EditField_17.BackgroundColor='red';
      else
        obj.guihan.EditField_17.BackgroundColor='white';
      end
      drawnow limitrate
    end
    function BC14BLUpdated(obj)
      if obj.is_shutdown
        return
      end
      ifb=6;
      % Controls values
      obj.guihan.EditField_16.Value = obj.Feedbacks(ifb).ControlReadVar(1).val{1} ;
      obj.guihan.Gauge_13.Value = obj.Feedbacks(ifb).ControlReadVar(1).val{1} ;
      obj.guihan.Gauge_13.ScaleColors = [1,0,0;1,0,0;0.39,0.83,0.07] ;
      obj.guihan.Gauge_13.ScaleColorLimits = [obj.FeedbackControlLimits{ifb}(1)-10,obj.FeedbackControlLimits{ifb}(1);obj.FeedbackControlLimits{ifb}(2),obj.FeedbackControlLimits{ifb}(2)+10;obj.FeedbackControlLimits{ifb}(1),obj.FeedbackControlLimits{ifb}(2)] ;
      obj.guihan.Gauge_13.Limits = [obj.FeedbackControlLimits{ifb}(1)-10,obj.FeedbackControlLimits{ifb}(2)+10] ;
      if obj.Feedbacks(ifb).ControlReadVar(1).val{1} >= obj.FeedbackControlLimits{ifb}(2) || obj.Feedbacks(ifb).ControlReadVar(1).val{1} <= obj.FeedbackControlLimits{ifb}(1)
        obj.guihan.EditField_16.BackgroundColor='red';
      else
        obj.guihan.EditField_16.BackgroundColor='white';
      end
      
      % Setpoint update
      val = obj.Feedbacks(ifb).SetpointVal ;
      if isempty(val) || isnan(val) || isinf(val)
        obj.guihan.Gauge_12.Value = 0 ;
        obj.guihan.EditField_15.BackgroundColor = 'black' ;
        obj.guihan.EditField_15.Value = 0 ;
        obj.guihan.Gauge_12.BackgroundColor = 'black' ;
        drawnow limitrate
        return
      end
      offs = obj.SetpointOffsets(ifb) ;
      valrel = double(val - offs) ;
      db = obj.SetpointDeadbands{ifb} ;
      lims = obj.FeedbackSetpointLimits{ifb} ;
      obj.guihan.Gauge_12.BackgroundColor = 'white' ;
      if valrel > db(1) && valrel < db(2)
        obj.guihan.Gauge_12.Value = 50*(valrel/range(db)) ;
        obj.guihan.EditField_15.BackgroundColor = [0.47,0.67,0.19] ;
      elseif val > lims(1) && valrel<db(1)
        obj.guihan.Gauge_12.Value = -75 + 50*abs(val)/abs(lims(1)-(offs-db(1))) ;
        obj.guihan.EditField_15.BackgroundColor = [0.94,0.94,0.94] ;
      elseif val < lims(2) && val > lims(1)
        obj.guihan.Gauge_12.Value = 25 + 50*abs(val)/abs(lims(2)-db(2)) ;
        obj.guihan.EditField_15.BackgroundColor = [0.94,0.94,0.94] ;
      elseif val<lims(1)
        obj.guihan.Gauge_12.Value = -90 ;
        obj.guihan.EditField_15.BackgroundColor = [0.85,0.33,0.10] ;
      else
        obj.guihan.Gauge_12.Value = 90 ;
        obj.guihan.EditField_15.BackgroundColor = [0.85,0.33,0.10] ;
      end
      obj.guihan.EditField_15.Value = val;
      drawnow limitrate
    end
    function statewatcher(obj)
      if obj.is_shutdown
        return
      end
      if ~isempty(obj.guihan)
        gh=["StatusLamp" "StatusLamp_2" "StatusLamp_5" "StatusLamp_6" "StatusLamp_4" "StatusLamp_7"];
        ght=["NotRunningButton"  "NotRunningButton_5" "NotRunningButton_3" "NotRunningButton_4" "NotRunningButton_6" "NotRunningButton_7"];
        for ifb=find(obj.UseFeedbacks)
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
      for ifb=find(obj.UseFeedbacks)
        fprintf('%s= %d\n',obj.FeedbacksAvailable(ifb),obj.Feedbacks(ifb).state);
      end
      % Setpoint conversion to energy units
      if obj.UseFeedbacks(1)
        E_DL1 = obj.pvs.E_DL1.val{1} ; % GeV
        obj.SetpointConversion{1}(2) = E_DL1 / obj.Disp_DL1 ; % mm -> MeV
      end
      if obj.UseFeedbacks(2)
        E_BC14 = obj.pvs.E_BC14.val{1} ; % GeV
        obj.SetpointConversion{2}(2) = E_BC14 / obj.Disp_BC14 ; % mm -> MeV
      end
      if obj.UseFeedbacks(3)
        E_BC11 = obj.pvs.E_BC11.val{1} ; % GeV
        obj.SetpointConversion{3}(2) = E_BC11 / obj.Disp_BC11 ; % mm -> MeV
      end
      if obj.UseFeedbacks(5)
        E_BC20 = obj.pvs.E_BC20.val{1} ; % GeV
        obj.SetpointConversion{5}(2) = E_BC20 / obj.Disp_BC20 ; % mm -> MeV
      end
      obj.UseOrbitFit = dec2bin(obj.pvs.UseOrbitFit.val{1},length(obj.UseOrbitFit))=='1' ;
    end
    function pvwatcher(obj)
      if obj.is_shutdown
        return
      end
      
      obj.Enabled = obj.pvs.FeedbackEnable.val{1} ;
      % Check L0B klystron status and deactivate feedback if not OK
      if string(obj.pvs.L0BStat1.val{1}) ~= "OK" || string(obj.pvs.L0BStat2.val{1}) ~= "Activated"
        obj.Enabled=bitset(obj.Enabled,1,0);
      end
      % Update feedback settings
      fbn=["DL1E" "BC14E" "BC11E" "BC11BL" "BC20E" "BC14BL"];
      sp=obj.SetpointOffsets;
      for ifb=find(obj.UseFeedbacks)
        sp(ifb) = obj.pvs.(fbn(ifb)+"_Offset").val{1} ;
        obj.FeedbackCoefficients{ifb}(1) = obj.pvs.(fbn(ifb)+"_Gain").val{1} ;
        obj.SetpointDeadbands{ifb} = [obj.pvs.(fbn(ifb)+"_SetpointDeadbandLo").val{1} obj.pvs.(fbn(ifb)+"_SetpointDeadbandHi").val{1}] ;
        obj.TMITLimits{ifb} = [obj.pvs.(fbn(ifb)+"_TMITLo").val{1} obj.pvs.(fbn(ifb)+"_TMITHi").val{1}] ;
        obj.FeedbackSetpointLimits{ifb} = [obj.pvs.(fbn(ifb)+"_SetpointLimitLo").val{1} obj.pvs.(fbn(ifb)+"_SetpointLimitHi").val{1}] ;
        obj.FeedbackControlLimits{ifb} = [obj.pvs.(fbn(ifb)+"_ControlLimitLo").val{1} obj.pvs.(fbn(ifb)+"_ControlLimitHi").val{1}] ;
      end
      obj.SetpointOffsets=sp;
      % Re-generate feedback objects if desired control devices changed
      if obj.UseFeedbacks(5)
        obj.BC20E_mkb = obj.pvs.BC20E_mkname.val{1} ;
      end
      if obj.UseFeedbacks(2)
        obj.BC14E_mkb = obj.pvs.BC14E_mkname.val{1} ;
      end
      % Feedback Jitter Settings
      if obj.UseFeedbacks(1)
        if ~isempty(obj.guihan)
          obj.guihan.FeedbackJitterButton.Value = logical(obj.pvs.DL1E_JitterON.val{1}) ;
          obj.guihan.JitAmpEdit.Value = obj.pvs.DL1E_JitterAMP.val{1} ;
          obj.guihan.JitterTimeoutMenu.Text = sprintf('Jitter Timeout = %d min',obj.pvs.FB_JitterOnTime.val{1}) ;
        end
        if logical(obj.pvs.DL1E_JitterON.val{1})
          obj.Feedbacks(1).Jitter = obj.pvs.DL1E_JitterAMP.val{1} ;
          obj.Feedbacks(1).JitterTimeout = obj.pvs.FB_JitterOnTime.val{1} ;
        else
          obj.Feedbacks(1).Jitter = 0 ;
        end
      end
      % Feedback running status (is headless FB script running?)
      if ~isempty(obj.guihan) 
        for ifb=find(obj.UseFeedbacks)
          obj.Feedbacks(ifb).Running = obj.pvs.FB_RUNNING.val{1} == "RUNNING" ;
        end
        if obj.UseFeedbacks(1) && obj.guihan.FeedbackJitterButton.Value
          obj.guihan.fbstat.Text = "Warning: DL1 Energy Feedback in JITTER Mode" ;
          obj.guihan.fbstat.FontColor = [0.85,0.33,0.10] ;
        elseif obj.pvs.FB_RUNNING.val{1} == "RUNNING"
          obj.guihan.fbstat.Text = "OK: MATLAB Watcher Process Running" ;
          obj.guihan.fbstat.FontColor = [0.47,0.67,0.19] ;
        else
          obj.guihan.fbstat.Text = "MATLAB Watcher Process STOPPED - All Feedbacks OFF" ;
          obj.guihan.fbstat.FontColor = [0.85,0.33,0.10] ;
        end
        drawnow limitrate
      end
    end
    function FeedbackGen(obj,ifb)
      isenabled=bitget(obj.Enabled,ifb);
      obj.Enabled=bitset(obj.Enabled,ifb,0);
      switch ifb
        case 1 % DL10 E
          DL1_Control=PV(obj.pvcntx,'name',"Control",'pvname',"KLYS:LI10:41:SFB_ADES",'mode',"rw"); % max = 37 MW
          if obj.UseOrbitFit(1)
            DL1_Setpoint=PV(obj.pvcntx,'name',"Setpoint",'pvname',"SIOC:SYS1:ML01:AO606",'monitor',true,'conv',1e3); % keV
          else
            DL1_Setpoint=PV(obj.pvcntx,'name',"Setpoint",'pvname',"BPMS:IN10:731:X1H",'monitor',true,'conv',obj.SetpointConversion{1}(2)*1e3); % keV from energy BPM
          end
          B=BufferData('Name',"DL1EnergyBPM",'DoFilter',obj.SetpointDoFilter(1),...
            'FilterType',obj.SetpointFilterTypes(1),'MaxDataRate',obj.RateLimit,'autoenable',false);
          B.FilterInterval = obj.SetpointFilterCoefficients{1} ;
          B.DataPV = DL1_Setpoint ;
          obj.Feedbacks(1) = fbSISO(DL1_Control,B) ;
          obj.Feedbacks(1).SetpointInDeadbandPV = "SIOC:SYS1:ML01:AO266" ;
          obj.Feedbacks(1).Kp = obj.FeedbackCoefficients{1}(1);
          obj.Feedbacks(1).ControlLimits = obj.FeedbackControlLimits{1} ;
          obj.Feedbacks(1).SetpointLimits = obj.FeedbackSetpointLimits{1} ;
          obj.Feedbacks(1).SetpointDES = obj.SetpointOffsets(1) ;
          obj.Feedbacks(1).QualVar = PV(obj.pvcntx,'name',"FB1_TMIT",'pvname',"BPMS:IN10:731:TMIT1H",'conv',1e-9) ;
          obj.Feedbacks(1).ControlStatusVar{1} = PV(obj.pvcntx,'name',"FB1_ControlStatus1",'pvname',"KLYS:LI10:41:FAULTSEQ_STATUS") ;
          obj.Feedbacks(1).ControlStatusGood{1} = {'OK'} ;
          obj.Feedbacks(1).ControlStatusVar{2} = PV(obj.pvcntx,'name',"FB1_ControlStatus2",'pvname',"KLYS:LI10:41:SFB_ADIS") ;
          obj.Feedbacks(1).ControlStatusGood{2} = {'Enabled'} ;
          obj.Feedbacks(1).ControlStatusVar{3} = PV(obj.pvcntx,'name',"FB1_ControlStatus3",'pvname',"SIOC:SYS1:ML01:AO607") ;
          obj.Feedbacks(1).ControlStatusGood{3} = {1} ;
          obj.Feedbacks(1).LimitRate=obj.RateLimit;
          obj.Feedbacks(1).LimitEventRate=obj.RateLimit;
%           obj.Feedbacks(1).StatusPV = PV(obj.pvcntx,'name',"fbstatus",'pvname',obj.FbStatusPV,'mode',"rw") ;
%           obj.Feedbacks(1).StatusPV_bit = 0 ;
          obj.Feedbacks(1).ControlMonitorPV = obj.ControlMonitorPV(1) ;
          %         obj.Feedbacks(1).Debug=1;
        case 2 % BC14E
          mkname=caget(obj.pvs.BC14E_mkname); obj.BC14E_mkb=string(mkname); % fetch multiknob choice from PV
          BC14_Control = SCP_MKB(obj.BC14E_mkb) ;
          BC14_ReadControl = PV(obj.pvcntx,'name',"ControlRB",'pvname',obj.BC14E_ControlDevs(1)) ;
          if obj.UseOrbitFit(2)
            BC14_Setpoint=PV(obj.pvcntx,'name',"Setpoint",'pvname',"SIOC:SYS1:ML01:AO618",'monitor',true); % MeV
          else
            BC14_Setpoint=PV(obj.pvcntx,'name',"Setpoint",'pvname',"BPMS:LI14:801:X1H",'monitor',true,'conv',obj.SetpointConversion{2}(2)); % MeV
          end
          B=BufferData('Name',"BC14EnergyBPM",'DoFilter',obj.SetpointDoFilter(5),...
            'FilterType',obj.SetpointFilterTypes(5),'MaxDataRate',obj.RateLimit,'autoenable',false);
          B.DataPV = BC14_Setpoint ;
          obj.Feedbacks(2) = fbSISO({BC14_ReadControl,BC14_Control},B) ;
          obj.Feedbacks(2).SetpointInDeadbandPV = "SIOC:SYS1:ML01:AO264" ;
          obj.Feedbacks(2).WriteRateMax = 3 ; % limit update rate
          obj.Feedbacks(2).Kp = obj.FeedbackCoefficients{2}(1);
          obj.Feedbacks(2).ControlLimits = obj.FeedbackControlLimits{2} ;
          obj.Feedbacks(2).SetpointLimits = obj.FeedbackSetpointLimits{2} ;
          obj.Feedbacks(2).SetpointDES = obj.SetpointOffsets(2) ;
          obj.Feedbacks(2).QualVar = PV(obj.pvcntx,'name',"FB2_TMIT",'pvname',"BPMS:LI14:801:TMIT1H",'conv',1e-9) ;
          obj.Feedbacks(2).ControlStatusVar{1} = PV(obj.pvcntx,'name',"FB2_ControlStatus1",'pvname',...
            obj.BC14E_ControlStatusPV(1)+":ONBEAM10.RVAL", 'pvdatatype', "float" ) ;
          obj.Feedbacks(2).ControlStatusGood{1} = {1} ;
          obj.Feedbacks(2).ControlStatusVar{2} = PV(obj.pvcntx,'name',"FB2_ControlStatus2",'pvname',...
            obj.BC14E_ControlStatusPV(2)+":ONBEAM10.RVAL", 'pvdatatype', "float" ) ;
          obj.Feedbacks(2).ControlStatusGood{2} = {1} ;
          obj.Feedbacks(2).ControlStatusVar{3} = PV(obj.pvcntx,'name',"FB2_ControlStatus3",'pvname',...
            obj.BC14E_ControlStatusPV(1)+":STATUS", 'pvdatatype', "float" ) ;
          obj.Feedbacks(2).ControlStatusGood{3} = {50 80} ;
          obj.Feedbacks(2).ControlStatusVar{4} = PV(obj.pvcntx,'name',"FB2_ControlStatus4",'pvname',...
            obj.BC14E_ControlStatusPV(2)+":STATUS", 'pvdatatype', "float" ) ;
          obj.Feedbacks(2).ControlStatusGood{4} = {50 80} ;
          % obj.Feedbacks(2).ControlStatusVar{5} = PV(obj.pvcntx,'name',"FB2_ControlStatus5",'pvname',"SIOC:SYS1:ML01:AO264") ;
          % obj.Feedbacks(2).ControlStatusGood{5} = {1} ;
          obj.Feedbacks(2).LimitRate=obj.RateLimit;
          obj.Feedbacks(2).LimitEventRate=obj.RateLimit;
%           obj.Feedbacks(2).StatusPV = PV(obj.pvcntx,'name',"fbstatus",'pvname',obj.FbStatusPV,'mode',"rw") ;
%           obj.Feedbacks(2).StatusPV_bit = 1 ;
          obj.Feedbacks(2).ControlMonitorPV = obj.ControlMonitorPV(2) ;
%           obj.Feedbacks(2).Debug=1;
        case 3 % BC11E
          % BC11_Control = [...
          %   PV(obj.pvcntx,'name',"Control",'pvname',"KLYS:LI11:11:AREQ",'mode',"rw") ...
          %   PV(obj.pvcntx,'name',"Control",'pvname',"KLYS:LI11:21:AREQ",'mode',"rw") ...
          %   ];
          BC11_Control = PV(obj.pvcntx,'name',"Control",'pvname',"KLYS:LI11:21:AREQ",'mode',"rw");
          if obj.UseOrbitFit(3)
            BC11_Setpoint=PV(obj.pvcntx,'name',"Setpoint",'pvname',"SIOC:SYS1:ML01:AO612",'monitor',true,'conv',1e3); % keV
          else
            BC11_Setpoint=PV(obj.pvcntx,'name',"Setpoint",'pvname',"BPMS:LI11:333:X1H",'monitor',true,'conv',obj.SetpointConversion{3}(2)*1e3); % keV
          end
          B=BufferData('Name',"BC11EnergyBPM",'DoFilter',obj.SetpointDoFilter(2),...
            'FilterType',obj.SetpointFilterTypes(2),'MaxDataRate',obj.RateLimit,'autoenable',false);
          B.DataPV = BC11_Setpoint ;
          obj.Feedbacks(3) = fbSISO(BC11_Control,B,"double") ;
          obj.Feedbacks(3).SetpointInDeadbandPV = "SIOC:SYS1:ML01:AO263" ;
          obj.Feedbacks(3).Kp = obj.FeedbackCoefficients{3}(1);
          obj.Feedbacks(3).ControlLimits = obj.FeedbackControlLimits{3} ;
          obj.Feedbacks(3).SetpointLimits = obj.FeedbackSetpointLimits{3} ;
          obj.Feedbacks(3).SetpointDES = obj.SetpointOffsets(3) ;
          obj.Feedbacks(3).QualVar = PV(obj.pvcntx,'name',"FB3_TMIT",'pvname',"BPMS:LI11:333:TMIT1H",'conv',1e-9) ;
          obj.Feedbacks(3).ControlStatusVar{1} = PV(obj.pvcntx,'name',"FB3_ControlStatus",'pvname',...
            "FCUDKLYS:LI11:1:ONBEAM10.RVAL", 'pvdatatype', "float" ) ;
          obj.Feedbacks(3).ControlStatusGood{1} = {1} ;
          obj.Feedbacks(3).ControlStatusVar{2} = PV(obj.pvcntx,'name',"FB3_ControlStatus",'pvname',...
            "FCUDKLYS:LI11:2:ONBEAM10 .RVAL", 'pvdatatype', "float" ) ;
          obj.Feedbacks(3).ControlStatusGood{2} = {1} ;
          obj.Feedbacks(3).ControlStatusVar{3} = PV(obj.pvcntx,'name',"FB3_ControlStatus3",'pvname',...
            "FCUDKLYS:LI11:1:STATUS ", 'pvdatatype', "float" ) ;
          obj.Feedbacks(3).ControlStatusGood{3} = {50 80} ;
          obj.Feedbacks(3).ControlStatusVar{4} = PV(obj.pvcntx,'name',"FB3_ControlStatus4",'pvname',...
            "FCUDKLYS:LI11:2:STATUS ", 'pvdatatype', "float" ) ;
          obj.Feedbacks(3).ControlStatusGood{4} = {50 80} ;
          % obj.Feedbacks(3).ControlStatusVar{5} = PV(obj.pvcntx,'name',"FB3_ControlStatus5",'pvname',"SIOC:SYS1:ML01:AO263") ;
          % obj.Feedbacks(3).ControlStatusGood{5} = {1} ;
          obj.Feedbacks(3).LimitRate=obj.RateLimit;
          obj.Feedbacks(3).LimitEventRate=obj.RateLimit;
%           obj.Feedbacks(3).StatusPV = PV(obj.pvcntx,'name',"fbstatus",'pvname',obj.FbStatusPV,'mode',"rw") ;
%           obj.Feedbacks(3).StatusPV_bit = 2 ;
          obj.Feedbacks(3).ControlMonitorPV = obj.ControlMonitorPV(3) ;
          %         obj.Feedbacks(3).Debug=1;
        case 4 % BC11 BLEN
          BC11_Control = [...
            PV(obj.pvcntx,'name',"Control",'pvname',"KLYS:LI11:11:PREQ",'mode',"rw") ...
            PV(obj.pvcntx,'name',"Control",'pvname',"KLYS:LI11:21:PREQ",'mode',"rw") ...
            ];
          % BC11_Control = PV(obj.pvcntx,'name',"Control",'pvname',"KLYS:LI11:21:PREQ",'mode',"rw");
          BC11_Setpoint = PV(obj.pvcntx,'name',"Setpoint",'pvname',"BLEN:LI11:359:BZ11359B_S_SUM",'monitor',true); % raw waveform integral
          B=BufferData('Name',"BC11_BunchLength",'DoFilter',obj.SetpointDoFilter(4),...
            'FilterType',obj.SetpointFilterTypes(4),'MaxDataRate',obj.RateLimit,'autoenable',false);
          B.DataPV = BC11_Setpoint ;
          obj.Feedbacks(4) = fbSISO(BC11_Control,B,"double") ;
          obj.Feedbacks(4).Kp = obj.FeedbackCoefficients{4}(1);
          obj.Feedbacks(4).ControlLimits = obj.FeedbackControlLimits{4} ;
          obj.Feedbacks(4).SetpointLimits = obj.FeedbackSetpointLimits{4} ;
          obj.Feedbacks(4).SetpointDES = obj.SetpointOffsets(4) ;
          obj.Feedbacks(4).QualVar = PV(obj.pvcntx,'name',"FB4_TMIT",'pvname',"BPMS:LI11:358:TMIT1H",'conv',1e-9) ;
          obj.Feedbacks(4).ControlStatusVar{1} = PV(obj.pvcntx,'name',"FB4_ControlStatus1",'pvname',...
            "FCUDKLYS:LI11:1:ONBEAM10.RVAL " , 'pvdatatype', "float" ) ;
          obj.Feedbacks(4).ControlStatusGood{1} = {1} ;
          obj.Feedbacks(4).ControlStatusVar{2} = PV(obj.pvcntx,'name',"FB4_ControlStatus2",'pvname',...
            "FCUDKLYS:LI11:2:ONBEAM10.RVAL", 'pvdatatype', "float" ) ;
          obj.Feedbacks(4).ControlStatusGood{2} = {1} ;
          obj.Feedbacks(4).ControlStatusVar{3} = PV(obj.pvcntx,'name',"FB4_ControlStatus3",'pvname',...
            "FCUDKLYS:LI11:1:STATUS ", 'pvdatatype', "float" ) ;
          obj.Feedbacks(4).ControlStatusGood{3} = {50 80} ;
          obj.Feedbacks(4).ControlStatusVar{4} = PV(obj.pvcntx,'name',"FB4_ControlStatus4",'pvname',...
            "FCUDKLYS:LI11:2:STATUS ", 'pvdatatype', "float" ) ;
          obj.Feedbacks(4).ControlStatusGood{4} = {50 80} ;
          obj.Feedbacks(4).ControlStatusVar{5} = PV(obj.pvcntx,'name',"BC11E_In-deadband",'pvname',"SIOC:SYS1:ML01:AO263") ;
          obj.Feedbacks(4).ControlStatusGood{5} = {1} ;
          obj.Feedbacks(4).LimitRate=obj.RateLimit;
          obj.Feedbacks(4).LimitEventRate=obj.RateLimit;
%           obj.Feedbacks(4).StatusPV = PV(obj.pvcntx,'name',"fbstatus",'pvname',obj.FbStatusPV,'mode',"rw") ;
%           obj.Feedbacks(4).StatusPV_bit = 3 ;
          obj.Feedbacks(4).ControlMonitorPV = obj.ControlMonitorPV(4) ;
          %       obj.Feedbacks(4).Debug=1;
        case 5 % BC20E
          mkname=caget(obj.pvs.BC20E_mkname); obj.BC20E_mkb=string(mkname); % fetch multiknob choice from PV
          BC20_Control = SCP_MKB(obj.BC20E_mkb) ;
          BC20_ReadControl = PV(obj.pvcntx,'name',"ControlRB",'pvname',obj.BC20E_ControlDevs(1)) ;
          if obj.UseOrbitFit(5)
            BC20_Setpoint=PV(obj.pvcntx,'name',"Setpoint",'pvname',"SIOC:SYS1:ML01:AO624",'monitor',true);
          else
            BC20_Setpoint=PV(obj.pvcntx,'name',"Setpoint",'pvname',"BPMS:LI20:2050:X57",'monitor',true,'conv',obj.SetpointConversion{5}(2)); % MeV
          end
          B=BufferData('Name',"BC20EnergyBPM",'DoFilter',obj.SetpointDoFilter(5),...
            'FilterType',obj.SetpointFilterTypes(5),'MaxDataRate',obj.RateLimit,'autoenable',false);
          B.DataPV = BC20_Setpoint ;
          obj.Feedbacks(5) = fbSISO({BC20_ReadControl,BC20_Control},B) ;
          obj.Feedbacks(5).SetpointInDeadbandPV = "SIOC:SYS1:ML01:AO265" ;
          obj.Feedbacks(5).WriteRateMax = 3 ; % limit update rate
          obj.Feedbacks(5).Kp = obj.FeedbackCoefficients{5}(1);
          obj.Feedbacks(5).ControlLimits = obj.FeedbackControlLimits{5} ;
          obj.Feedbacks(5).SetpointLimits = obj.FeedbackSetpointLimits{5} ;
          obj.Feedbacks(5).SetpointDES = obj.SetpointOffsets(5) ;
          obj.Feedbacks(5).QualVar = PV(obj.pvcntx,'name',"FB5_TMIT",'pvname',"BPMS:LI20:2050:TMIT57",'conv',1e-9) ;
          obj.Feedbacks(5).ControlStatusVar{1} = PV(obj.pvcntx,'name',"FB5_ControlStatus1",'pvname',...
            obj.BC20E_ControlStatusPV(1)+":ONBEAM10.RVAL", 'pvdatatype', "float" ) ;
          obj.Feedbacks(5).ControlStatusGood{1} = {1} ;
          obj.Feedbacks(5).ControlStatusVar{2} = PV(obj.pvcntx,'name',"FB5_ControlStatus2",'pvname',...
            obj.BC20E_ControlStatusPV(2)+":ONBEAM10.RVAL", 'pvdatatype', "float" ) ;
          obj.Feedbacks(5).ControlStatusGood{2} = {1} ;
          obj.Feedbacks(5).ControlStatusVar{3} = PV(obj.pvcntx,'name',"FB5_ControlStatus3",'pvname',...
            obj.BC20E_ControlStatusPV(1)+":STATUS", 'pvdatatype', "float" ) ;
          obj.Feedbacks(5).ControlStatusGood{3} = {50 80} ;
          obj.Feedbacks(5).ControlStatusVar{4} = PV(obj.pvcntx,'name',"FB5_ControlStatus4",'pvname',...
            obj.BC20E_ControlStatusPV(2)+":STATUS", 'pvdatatype', "float" ) ;
          obj.Feedbacks(5).ControlStatusGood{4} = {50 80} ;
          % obj.Feedbacks(5).ControlStatusVar{5} = PV(obj.pvcntx,'name',"FB5_ControlStatus5",'pvname',"SIOC:SYS1:ML01:AO625") ;
          % obj.Feedbacks(5).ControlStatusGood{5} = {1} ;
          obj.Feedbacks(5).LimitRate=obj.RateLimit;
          obj.Feedbacks(5).LimitEventRate=obj.RateLimit;
%           obj.Feedbacks(5).StatusPV = PV(obj.pvcntx,'name',"fbstatus",'pvname',obj.FbStatusPV,'mode',"rw") ;
%           obj.Feedbacks(5).StatusPV_bit = 4 ;
          obj.Feedbacks(5).InvertControlVal = true ;
          obj.Feedbacks(5).ControlMonitorPV = obj.ControlMonitorPV(5) ;
%           obj.Feedbacks(5).Debug=1;
        case 6 % BC14 BLEN
          Control = SCP_MKB("l2_phase") ;
          ReadControl = PV(obj.pvcntx,'name',"ControlRB",'pvname',"LI11:SBST:1:PDES") ;
%           Setpoint = PV(obj.pvcntx,'name',"Setpoint",'pvname',"BLEN:LI14:888:BIMAX",'monitor',true); % Processed output
          Setpoint = PV(obj.pvcntx,'name',"Setpoint",'pvname',"BLEN:LI14:888:BZ14888B_S_SUM",'monitor',true,'conv',1e-3); % Raw waveform integral
          B=BufferData('Name',"BC14_BunchLength",'DoFilter',obj.SetpointDoFilter(4),...
            'FilterType',obj.SetpointFilterTypes(4),'MaxDataRate',obj.RateLimit,'autoenable',false);
          B.DataPV = Setpoint ;
          obj.Feedbacks(6) = fbSISO({ReadControl,Control},B) ;
          obj.Feedbacks(6).WriteRateMax = 3 ; % limit update rate
          obj.Feedbacks(6).InvertControlVal = true ;
          obj.Feedbacks(6).Kp = obj.FeedbackCoefficients{6}(1);
          obj.Feedbacks(6).ControlLimits = obj.FeedbackControlLimits{6} ;
          obj.Feedbacks(6).SetpointLimits = obj.FeedbackSetpointLimits{6} ;
          obj.Feedbacks(6).SetpointDES = obj.SetpointOffsets(6) ;
          obj.Feedbacks(6).QualVar = PV(obj.pvcntx,'name',"FB6_TMIT",'pvname',"BPMS:LI14:891:TMIT1H",'conv',1e-9) ;
          obj.Feedbacks(6).LimitRate=obj.RateLimit;
          obj.Feedbacks(6).LimitEventRate=obj.RateLimit;
          obj.Feedbacks(6).ControlStatusVar{1} = PV(obj.pvcntx,'name',"BC14E_In-deadband",'pvname',"SIOC:SYS1:ML01:AO264") ;
          obj.Feedbacks(6).ControlStatusGood{1} = {1} ;
%           obj.Feedbacks(6).StatusPV = PV(obj.pvcntx,'name',"fbstatus",'pvname',obj.FbStatusPV,'mode',"rw") ;
%           obj.Feedbacks(6).StatusPV_bit = 5 ;
          obj.Feedbacks(6).ControlMonitorPV = obj.ControlMonitorPV(6) ;
          %       obj.Feedbacks(6).Debug=1;
      end
      obj.Enabled=bitset(obj.Enabled,ifb,isenabled);
    end
    function shutdown(obj)
      try
        obj.is_shutdown = true ;
        FB = obj ;
        save(sprintf('%s/F2_Feedback.mat',obj.confdir),'FB');
        if isempty(obj.guihan)
          obj.Enabled=0; % register stopped status in PV
          stop(obj.to);
        end
        stop(obj.pvlist);
        for ifb=find(obj.UseFeedbacks)
          obj.Feedbacks(ifb).shutdown;
        end
      catch ME
        fprintf(2,'Shutdown error:\n');
        warning(ME.message);
      end
    end
  end
  % Set/get and private methods
  methods
    function set.TMITLimits(obj,val)
      disp('Changing TMIT Limits:');
      celldisp(val);
      obj.TMITLimits = val ;
      for ifb=find(obj.UseFeedbacks)
        obj.Feedbacks(ifb).QualLimits = obj.TMITLimits{ifb} ;
      end
    end
    function set.SetpointDeadbands(obj,val)
      disp('Changing Deadband Limits:');
      celldisp(val);
      obj.SetpointDeadbands = val ;
      for ifb=find(obj.UseFeedbacks)
        obj.Feedbacks(ifb).SetpointDeadband = obj.SetpointDeadbands{ifb} ;
      end
    end
    function set.SetpointDoFilter(obj,val)
      disp('Changing Filter Use Selection:');
      disp(val);
      obj.SetpointDoFilter = val ;
      for ifb=find(obj.UseFeedbacks)
        obj.Feedbacks(ifb).SetpointVar.DoFilter = obj.SetpointDoFilter(ifb) ;
      end
    end
    function set.SetpointFilterTypes(obj,val)
      disp('Changing Setpoint Filter Types:');
      disp(val);
      obj.SetpointFilterTypes = val ;
      for ifb=find(obj.UseFeedbacks)
        obj.Feedbacks(ifb).SetpointVar.FilterType = obj.SetpointFilterTypes(ifb) ;
      end
    end
    function set.SetpointFilterCoefficients(obj,val)
      disp('Changing Setpoint Filter Coefficients:');
      celldisp(val)
      obj.SetpointFilterCoefficients = val ;
      for ifb=find(obj.UseFeedbacks)
        newtime = ceil(2/obj.SetpointFilterCoefficients{ifb}(2)/60) ;
        if newtime > 2 % min 2 minutes buffer
          obj.Feedbacks(ifb).SetpointVar.BufferTime = newtime ;
        end
        obj.Feedbacks(ifb).SetpointVar.FilterInterval = obj.SetpointFilterCoefficients{ifb} ;
      end
    end
    function set.FeedbackSetpointLimits(obj,val)
      disp('Changing Feedback Setpoint Limits:');
      celldisp(val);
      obj.FeedbackSetpointLimits = val ;
      for ifb=find(obj.UseFeedbacks)
        obj.Feedbacks(ifb).SetpointLimits = obj.FeedbackSetpointLimits{ifb} ;
      end
    end
    function set.FeedbackControlLimits(obj,val)
      disp('Changing Feedback Control Limits:');
      celldisp(val);
      obj.FeedbackControlLimits = val ;
      for ifb=find(obj.UseFeedbacks)
        obj.Feedbacks(ifb).ControlLimits = obj.FeedbackControlLimits{ifb} ;
        if ~isempty(obj.guihan)
          if isa(obj.Feedbacks(ifb).ControlVar,'PV')
            obj.Feedbacks(ifb).ControlVar(1).limits = [obj.Feedbacks(ifb).ControlLimits].*0.98 ;
          end
        end
      end
    end
    function set.FeedbackCoefficients(obj,val)
      disp('Changing Feedback Coefficients:')
      celldisp(val);
      obj.FeedbackCoefficients = val ;
      for ifb=find(obj.UseFeedbacks)
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
      obj.SetpointOffsets=val;
      disp('Changing Setpoint Offsets:');
      disp(val);
      if ~isempty(obj.guihan)
        gh = ["SetpointEditField" "SetpointEditField_2" "SetpointEditField_5" "SetpointEditField_6" "SetpointEditField_4" "SetpointEditField_7"];
      end
      for ifb=find(obj.UseFeedbacks)
        obj.Feedbacks(ifb).SetpointDES =  obj.SetpointOffsets(ifb) ;
        if ~isempty(obj.guihan)
          obj.guihan.(gh(ifb)).Value = double(obj.SetpointOffsets(ifb)) ;
        end
      end
    end
    function set.Enabled(obj,val)
      disp('Changing Feedback Enabled Status:');
      disp(val);
      if ~isempty(obj.guihan)
        switchid=["Switch" "Switch_2" "Switch_5" "Switch_6" "Switch_4" "Switch_7"];
      end
      obj.Enabled=uint16(val);
      for ifb=find(obj.UseFeedbacks)
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
      for ifb=find(obj.UseFeedbacks)
        fprintf('%s= %d\n',obj.FeedbacksAvailable(ifb),bitget(obj.Enabled,ifb));
      end
    end
    function feedbacks = get.FeedbacksEnabled(obj)
      feedbacks=string([]);
      for ifb=find(obj.UseFeedbacks)
        if bitget(obj.Enabled,ifb)
          feedbacks(end+1)=obj.FeedbacksAvailable(ifb);
        end
      end
    end
    function set.BC14E_mkb(obj,mkname)
      fprintf('Re-generating BC14E Feedback with MKB: %s ...\n',mkname);
      obj.BC14E_mkb = mkname ;
      if ~isempty(obj.guihan)
        switch obj.BC14E_mkb
          case "BC14_ENERGY_4AND5"
            obj.guihan.BC14_C1Lab.Text = "LI14:KLYS:41:PDES";
            obj.guihan.BC14_C2Lab.Text = "LI14:KLYS:51:PDES";
            obj.guihan.DropDown_2.Value = "BC14_ENERGY_4AND5" ;
            caput(obj.pvs.BC14E_mkname,'BC14_ENERGY_4AND5');
          case "BC14_ENERGY_5AND6"
            obj.guihan.BC14_C1Lab.Text = "LI14:KLYS:51:PDES";
            obj.guihan.BC14_C2Lab.Text = "LI14:KLYS:61:PDES";
            obj.guihan.DropDown_2.Value = "BC14_ENERGY_5AND6" ;
            caput(obj.pvs.BC14E_mkname,'BC14_ENERGY_5AND6');
          case "BC14_ENERGY_4AND6"
            obj.guihan.BC14_C1Lab.Text = "LI14:KLYS:41:PDES";
            obj.guihan.BC14_C2Lab.Text = "LI14:KLYS:61:PDES";
            obj.guihan.DropDown_2.Value = "BC14_ENERGY_4AND6" ;
            caput(obj.pvs.BC14E_mkname,'BC14_ENERGY_4AND6');
        end
      end
      try
        obj.FeedbackGen(2);
      catch ME
        if ~isempty(obj.guihan)
          errordlg('Error initializing BC14E feedback, see command window','Feedback init error');
        end
        throw(ME)
      end
      if obj.fbinit
        obj.Feedbacks(2).Run;
      end
    end
    function devs = get.BC14E_ControlDevs(obj)
      switch obj.BC14E_mkb
        case "BC14_ENERGY_4AND5"
          devs = ["LI14:KLYS:41:PDES" "LI14:KLYS:51:PDES"] ;
        case "BC14_ENERGY_5AND6"
          devs = ["LI14:KLYS:51:PDES" "LI14:KLYS:61:PDES"] ;
        case "BC14_ENERGY_4AND6"
          devs = ["LI14:KLYS:41:PDES" "LI14:KLYS:61:PDES"] ;
      end
    end
    function pv = get.BC14E_ControlStatusPV(obj)
      switch obj.BC14E_mkb
        case "BC14_ENERGY_4AND5"
          pv = ["FCUDKLYS:LI14:4" "FCUDKLYS:LI14:5"] ;
        case "BC14_ENERGY_5AND6"
          pv = ["FCUDKLYS:LI14:5" "FCUDKLYS:LI14:6"] ;
        case "BC14_ENERGY_4AND6"
          pv = ["FCUDKLYS:LI14:4" "FCUDKLYS:LI14:6"] ;
      end
    end
    function set.BC20E_mkb(obj,mkname)
      fprintf('Re-generating BC20E Feedback with MKB: %s ...\n',mkname);
      obj.BC20E_mkb = mkname ;
      if ~isempty(obj.guihan)
        switch obj.BC20E_mkb
          case "S20_ENERGY_3AND4"
            obj.guihan.BC20_C1Lab.Text = "LI19:KLYS:31:PDES";
            obj.guihan.BC20_C2Lab.Text = "LI19:KLYS:41:PDES";
            obj.guihan.DropDown.Value = "S20_ENERGY_3AND4" ;
            caput(obj.pvs.BC20E_mkname,'S20_ENERGY_3AND4');
          case "S20_ENERGY_3AND5"
            obj.guihan.BC20_C1Lab.Text = "LI19:KLYS:31:PDES";
            obj.guihan.BC20_C2Lab.Text = "LI19:KLYS:51:PDES";
            obj.guihan.DropDown.Value = "S20_ENERGY_3AND5" ;
            caput(obj.pvs.BC20E_mkname,'S20_ENERGY_3AND5');
          case "S20_ENERGY_4AND5"
            obj.guihan.BC20_C1Lab.Text = "LI19:KLYS:41:PDES";
            obj.guihan.BC20_C2Lab.Text = "LI19:KLYS:51:PDES";
            obj.guihan.DropDown.Value = "S20_ENERGY_4AND5" ;
            caput(obj.pvs.BC20E_mkname,'S20_ENERGY_4AND5');
          case "S20_ENERGY_4AND6"
            obj.guihan.BC20_C1Lab.Text = "LI19:KLYS:41:PDES";
            obj.guihan.BC20_C2Lab.Text = "LI19:KLYS:61:PDES";
            obj.guihan.DropDown.Value = "S20_ENERGY_4AND6" ;
            caput(obj.pvs.BC20E_mkname,'S20_ENERGY_4AND6');
        end
      end
      try
        obj.FeedbackGen(5);
      catch ME
        if ~isempty(obj.guihan)
          errordlg('Error initializing BC20E feedback, see command window','Feedback init error');
        end
        throw(ME)
      end
      if obj.fbinit
        obj.Feedbacks(5).Run;
      end
    end
    function devs = get.BC20E_ControlDevs(obj)
      switch obj.BC20E_mkb
        case "S20_ENERGY_3AND4"
          devs = ["LI19:KLYS:31:PDES" "LI19:KLYS:41:PDES"] ;
        case "S20_ENERGY_3AND5"
          devs = ["LI19:KLYS:31:PDES" "LI19:KLYS:51:PDES"] ;
        case "S20_ENERGY_4AND5"
          devs = ["LI19:KLYS:41:PDES" "LI19:KLYS:51:PDES"] ;
        case "S20_ENERGY_4AND6"
          devs = ["LI19:KLYS:41:PDES" "LI19:KLYS:61:PDES"] ;
      end
    end
    function pv = get.BC20E_ControlStatusPV(obj)
      switch obj.BC20E_mkb
        case "S20_ENERGY_3AND4"
          pv = ["FCUDKLYS:LI19:3" "FCUDKLYS:LI19:4"] ;
        case "S20_ENERGY_3AND5"
          pv = ["FCUDKLYS:LI19:3" "FCUDKLYS:LI19:5"] ;
        case "S20_ENERGY_4AND5"
          pv = ["FCUDKLYS:LI19:4" "FCUDKLYS:LI19:5"] ;
        case "S20_ENERGY_4AND6"
          pv = ["FCUDKLYS:LI19:4" "FCUDKLYS:LI19:6"] ;
      end
    end
    function set.UseOrbitFit(obj,use)
      if length(use)~=length(obj.UseOrbitFit)
        error('Must use logical vector same length as # available feedbacks');
      end
      idiff = find(obj.UseOrbitFit~=use) ;
      obj.UseOrbitFit=use;
      if ~any(idiff)
        return
      end
      caput(obj.pvs.UseOrbitFit,bin2dec(num2str(use)));
      for ifb=idiff
        try
          obj.FeedbackGen(ifb);
        catch ME
          if ~isempty(obj.guihan)
            errordlg('Error initializing feedback, see command window','Feedback init error');
          end
          throw(ME)
        end
        if obj.fbinit
          obj.Feedbacks(ifb).Run;
        end
        if obj.UseOrbitFit(ifb)
          fprintf('Feedback %d Using Orbit Fitting.\n',ifb);
        else
          fprintf('Feedback %d NOT Using Orbit Fitting.\n',ifb);
        end
      end
    end
  end
end