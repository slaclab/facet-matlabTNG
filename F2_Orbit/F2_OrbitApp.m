classdef F2_OrbitApp < handle & F2_common & matlab.mixin.Copyable
  properties
    bpmid uint16 % Master list of BPM IDs
    xcorid uint16 % Master list of x corrector IDs
    ycorid uint16 % Master list of y corrector IDs
    usebpm logical % Selection (from master list) of BPMs to use - includes user selection
    useregbpm logical % Selection (from master list) of BPMs to use - excludes user selection
    usexcor logical % Selection (from master list) of XCORs to use
    useycor logical % Selection (from master list) of YCORs to use
    bpmnames string % master list of names
    xcornames string % master list of names
    ycornames string % master list of names
    bpmcnames string % master list of control names
    xcorcnames string % master list of control names
    ycorcnames string % master list of control names
    xcorpv % x corrector EPICS BDES PV
    ycorpv % y corrector EPICS BDES PV
    xcormaxpv % x corrector EPICS BDES PV (BMAX)
    ycormaxpv % y corrector EPICS BDES PV (BMAX)
    badbpms logical % flag 'bad' BPMS (no controls or known bad)
    badxcors logical
    badycors logical
    RM % Response matrices X/YCOR -> BPMS [2*nbpm,ncor]
    corsolv string {mustBeMember(corsolv,["lscov","pinv","lsqminnorm","svd","lsqlin"])} = "lsqlin" % solver to use for orbit correction
    solvtol % tolerance for orbit solution QR factorization tolerance (only use if set)
    usex logical = true % apply x corrections when asked?
    usey logical = true % apply y corrections when asked?
    nmode uint8 = inf % # of svd modes to include in correction (for corsolv="svd")
    domodelfit logical = false % If true, correct based on model fit, else, correct based on raw BPM readings
    usebpmbuff logical = true % If true, use buffered BPM data, else use EPICS-based non-synchronous data
    dormsplot logical = false % if true, plot rms data instead of mean orbit
    fitele uint16 % fit element
    CorrectionOffset(4,1) = [0; 0; 0; 0;] % Desired correction offset when using domodelfit (mm/mrad)
    npulse {mustBePositive} = 50 % default/GUI value for number of pulses of BPM data to take
    orbitfitmethod string {mustBeMember(orbitfitmethod,["lscov","backslash"])} = "lscov"
    escandev string {mustBeMember(escandev,["DL10" "BC11" "BC14" "BC20"])} = "DL10"
    escanrange(2,4) = [-2 -3 -20 -60;2 3 20 60] % MeV
    nescan(1,4) = ones(1,4).*7 % Number of energy scan steps to use
    escanfitorder uint8 = 2 % Order of polynomial fit to energy vs. BPM position
    escanplotorder uint8 = 1 % Polynomial order to plot (1= linear dispersion, 2=second-order disperion)
    plotallbpm logical = false 
    doabort logical = false
    DispMeasMethod uint8 {mustBeLessThan(DispMeasMethod,2)} = 1 % 0 = use feedback setpoints and wait for capture signals (slow); 1= same as 0, no wait for capture
  end
  properties(Transient)
    BPMS % Storage for F2_bpms object
    aobj % Storage for GUI application object
    LM % LucretiaModel object
    LiveModel % LiveModel object
  end
  properties(SetAccess=private)
    iswatcher logical = false % Run in watcher mode? (set by constructor)
    cordat_x % XCOR data
    cordat_y % YCOR data
    dtheta_x % calculated x corrector kicks (rad)
    dtheta_y % calculated y corrector kicks (rad)
    xbpm_cor % calculated corrected x bpm vals (mm)
    ybpm_cor % calculated corrected y bpm vals (mm)
    ebpms_disp(1,5) % dispersion at energy BPMS in mm
    DispData % Dispersion data calculated with svddisp method (mm)
    DispData_all % Dispersion data calculated with svddisp method for all BPMs in region (mm)
    DispFit % Fitted [dispersion_x; dispersion_y] at each BPM in selected region calculated with plotdisp method
    DispFitEle(1,5) % Dx,DPx,Dy,DPy @ fitele
    DispCorData % fitted dispersion correction device settings
    DispCorVals
    ConfigName string = "none"
    ConfigDate % datenum of loaded configuration
    escandata cell % Storage for energy scan data
    OrbitFit(1,5) = [nan nan nan nan nan] % Orbit fitted at fitele location [mm/mrad/(dE/E)]
    regid % first and last BEAMLINE element of selected region
    disp0 % dispersion fit at regid(1)
    WatcherTimer
  end
  properties(SetAccess=private,Hidden)
    bdesx_restore % bdes values store when written for undo function
    bdesy_restore % bdes values store when written for undo function
    RefOrbitConfig % {date,id,xref,yref}
    RefOrbitLocal % {date,id,xref,yref}
    EnergyKnobsKlysID % Lucretia KLYSTRON indices for energy knobs
  end
  properties(SetObservable)
    UseRegion(1,11) logical = true(1,11) % ["INJ";"L0";"DL1";"L1";"BC11";"L2";"BC14";"L3";"BC20";"FFS";"SPECTDUMP"]
    calcperformed logical =false
    UseRefOrbit string {mustBeMember(UseRefOrbit,["none","local","config"])} = "none"
  end
  properties(Dependent)
    RefOrbit % Reference orbit [id,xref,yref]
    RefOrbitDate
    Configs
    ConfigsDate
  end
  properties(Constant)
    ebpms string = ["BPM10731" "BPM11333" "BPM14801" "M3E" "M9E"] % energy BPMs for DL1, BC11, BC14 & BC20 (u/s & d/s)
    epicsxcor = ["XC10121" "XC10221" "XC10311" "XC10381" "XC10411" "XC10491" "XC10521" "XC10641" "XC10721" "XC10761" ...
      "XC11104" "XC11140" "XC11202" "XC11272" "XC11304" "XC11398"]
    epicsycor = ["YC10122" "YC10222" "YC10312" "YC10382" "YC10412" "YC10492" "YC10522" "YC10642" "YC10722" "YC10762" ...
      "YC11105" "YC11141" "YC11203" "YC11273" "YC11305" "YC11321" "YC11365" "YC11399" ]
    klys_bsa = "KLYS:LI10:41:FB:FAST_AACT3" % L0B
    klys_cntrl = "KLYS:LI10:41:ADES" % L0B
    OrbitConfigDir string = F2_common.confdir + "/F2_Orbit" ;
    DispDevices string = ["QB10731" "CQ11317" "SQ11340" "CQ11352" "CQ14738" "CQ14866" "SQ1" "S1EL" "S2EL" "S2ER" "S1ER" "S1EL" "S2EL" "S2ER" "S1ER"]
    DispDeviceType uint8 = [1         1         2          1         1         1        2      3       3     3     3       4       4     4     4    ] % 1=quad 2=skew quad 3=sext(x) 4=sext(y)
    DispDeviceReadPV = ["QUAD:IN10:731:BDES" "QUAD:LI11:317:BDES" "QUAD:LI11:340:BDES" "QUAD:LI11:352:BDES" "QUAD:LI14:738:BDES" "QUAD:LI14:866:BDES" "LI20:QUAD:2086:BDES" ...
      "SIOC:ML00:AO551" "SIOC:ML01:AO501" "SIOC:ML01:AO516" "SIOC:ML01:AO566" "SIOC:ML01:AO556" "SIOC:ML01:AO506" "SIOC:ML01:AO521" "SIOC:ML01:AO571"]
    DispDeviceWritePV = ["QUAD:IN10:731:BCTRL" "QUAD:LI11:317:BCTRL" "QUAD:LI11:340:BCTRL" "QUAD:LI11:352:BCTRL" "QUAD:LI14:738:BCTRL" "QUAD:LI14:866:BCTRL" "QUAD:LI20:2086:BDES" ...
      "SIOC:ML00:AO551" "SIOC:ML01:AO501" "SIOC:ML01:AO516" "SIOC:ML01:AO566" "SIOC:ML01:AO556" "SIOC:ML01:AO506" "SIOC:ML01:AO521" "SIOC:ML01:AO571"]
    DispDeviceWriteProto = ["EPICS" "EPICS" "EPICS" "EPICS" "EPICS" "EPICS" "AIDA" "EPICS" "EPICS" "EPICS" "EPICS" "EPICS" "EPICS" "EPICS" "EPICS"]
    WatcherConfs = ["OrbitFit_DL10" "OrbitFit_BC11" "OrbitFit_BC14" "OrbitFit_BC20"] % Which configs to process in watcher mode
    WatcherConfsPV = "SIOC:SYS1:ML01:AO601" % bit pattern to use to select which orbit watchers to process
    EOffsetPV = ["SIOC:SYS1:ML00:AO858" "SIOC:SYS1:ML01:AO207" "SIOC:SYS1:ML00:AO898" "SIOC:SYS1:ML01:AO234"]
    FBDeadbandPV = ["SIOC:SYS1:ML01:AO266" "SIOC:SYS1:ML01:AO263" "SIOC:SYS1:ML01:AO264" "SIOC:SYS1:ML01:AO265"]
    EPV = ["SIOC:SYS1:ML01:AO606" "SIOC:SYS1:ML01:AO612" "SIOC:SYS1:ML01:AO618" "SIOC:SYS1:ML01:AO624"] % Fitted energy offsets @ DL10, BC11, BC14, BC20
  end
  methods
    function obj = F2_OrbitApp(appobj,LLM)
      global BEAMLINE
      warning('off','MATLAB:lscov:RankDefDesignMat');
      warning('off','MATLAB:singularMatrix');
      warning('off','MATLAB:rankDeficientMatrix')
      if exist('LLM','var') && ~isempty(LLM)
        obj.LiveModel = LLM ;
      else
        obj.LiveModel = F2_LiveModelApp ;
      end
      obj.LiveModel.autoupdate = true ;
      addlistener(obj.LiveModel,'ModelUpdated',@(~,~) obj.ProcModelUpdate) ;
      obj.BPMS = F2_bpms(obj.LiveModel.LM) ;
      if exist('appobj','var') && (isa(appobj,'F2_Orbit') || isa(appobj,'F2_Orbit_exported'))
        obj.aobj = appobj ;
      elseif ~exist('appobj','var') || isempty(appobj) || ~appobj % Assume watcher mode if nothing passed as first argument
        obj.iswatcher = true ;
      end
      obj.LM=copy(obj.BPMS.LM); % local copy of LucretiaModel
      obj.LM.UseMissingEle = true ; % don't return info about missing correctors
      obj.LM.ModelClasses="MONI";
      obj.bpmid = obj.LM.ModelID ;
      obj.LM.ModelClasses="XCOR";
      obj.xcorid = obj.LM.ModelID ;
      obj.LM.ModelClasses="YCOR";
      obj.ycorid = obj.LM.ModelID ;
      obj.usebpm = true(size(obj.bpmid)) ;
      obj.usexcor = true(size(obj.xcorid)) ;
      obj.useycor = true(size(obj.ycorid)) ;
      % Flag elements without control names as not in use
      obj.LM.ModelClasses="MONI";
      obj.bpmnames = obj.LM.ModelNames ;
      obj.bpmcnames = obj.LM.ControlNames ;
      obj.badbpms = false(size(obj.bpmid)) ;
      obj.badbpms(obj.LM.ModelNames==obj.LM.ControlNames)=true;
      obj.badbpms(ismember(obj.bpmnames,obj.BPMS.badbpms))=true;
      obj.usebpm(obj.badbpms) = false ;
      obj.xbpm_cor=zeros(size(obj.bpmnames));
      obj.ybpm_cor=zeros(size(obj.bpmnames));
      obj.LM.ModelClasses="XCOR";
      obj.xcornames = obj.LM.ModelNames ;
      obj.xcorcnames = obj.LM.ControlNames ;
      obj.badxcors = false(size(obj.xcorid)) ;
      obj.badxcors(obj.LM.ModelNames==obj.LM.ControlNames)=true;
      obj.usexcor(obj.badxcors) = false ;
      for icor=1:length(obj.xcorcnames)
        obj.xcorpv{icor,1} = char(obj.xcorcnames(icor)+":BDES");
        obj.xcormaxpv{icor,1} = char(obj.xcorcnames(icor)+":BMAX");
      end
      obj.dtheta_x=zeros(size(obj.xcornames)); obj.dtheta_x=obj.dtheta_x(:);
      obj.LM.ModelClasses="YCOR";
      obj.ycornames = obj.LM.ModelNames ;
      obj.ycorcnames = obj.LM.ControlNames ;
      obj.badycors = false(size(obj.ycorid)) ;
      obj.badycors(obj.LM.ModelNames==obj.LM.ControlNames)=true;
      obj.useycor(obj.badycors) = false ;
      for icor=1:length(obj.ycorcnames)
        obj.ycorpv{icor,1} = char(obj.ycorcnames(icor)+":BDES");
        obj.ycormaxpv{icor,1} = char(obj.ycorcnames(icor)+":BMAX");
      end
      obj.dtheta_y=zeros(size(obj.ycornames));obj.dtheta_y=obj.dtheta_y(:);
      % get dispersions at ebpms
      for ibpm=1:length(obj.ebpms)
        bpmind = findcells(BEAMLINE,'Name',char(obj.ebpms(ibpm))) ;
        obj.ebpms_disp(ibpm) = obj.LM.DesignTwiss.etax(bpmind)*1e3 ;
      end
      obj.fitele = length(BEAMLINE) ;
      % Populate Config menu
      if ~isempty(obj.aobj)
        confs=obj.Configs;
        dates=string(datestr(obj.ConfigsDate));
        for iconf=1:length(confs)
          uimenu(obj.aobj.SelectMenu,'Text',confs(iconf)+"  ("+dates(iconf)+")",'Tag',confs(iconf),'MenuSelectedFcn',@(source,event) obj.GuiConfigLoad(event));
        end
      end
      % Start watcher timer function?
      if obj.iswatcher
        obj.StartWatcher ;
      end
    end
    function StartWatcher(obj)
      if isempty(obj.WatcherTimer)
        obj.WatcherTimer = timer('ErrorFcn',@(~,~) obj.ErrWatcher,'ExecutionMode','fixedRate','Period',0.1,'TimerFcn',@(~,~) obj.Watcher) ;
      end
      start(obj.WatcherTimer);
    end
    function ErrWatcher(obj,~)
      F2_common.LogMessage('F2_OrbitApp_Watcher','Error with OrbitApp watcher function, restarting.');
      start(obj.WatcherTimer);
    end
    function Watcher(obj,~)
      %WATCHER Run pre-saved configs in watcher function
      global BEAMLINE
      persistent pobj pvs
      iw = lcaGet(char(obj.WatcherConfsPV)); % bit pattern of configs to process
      lcaPutNoWait('F2:WATCHER:ORBIT_STAT',1); % Write to watcher status PV
      for iproc=1:length(obj.WatcherConfs) 
        % For each config, copy local obj, store another with config name and load
        if bitget(iw,iproc)
          wname=obj.WatcherConfs(iproc);
          if ~isfield(pobj,wname)
            pobj.(wname)=copyobj(obj);
            pobj.(wname).ConfigLoad(wname);
            % Get PV names
            pvs.(wname).x = "SIOC:SYS1:ML01:AO" + (601 + (iproc-1)*6 + 1) ;
            pvs.(wname).xp = "SIOC:SYS1:ML01:AO" + (601 + (iproc-1)*6 + 2) ;
            pvs.(wname).y = "SIOC:SYS1:ML01:AO" + (601 + (iproc-1)*6 + 3) ;
            pvs.(wname).yp = "SIOC:SYS1:ML01:AO" + (601 + (iproc-1)*6 + 4) ;
            pvs.(wname).de = "SIOC:SYS1:ML01:AO" + (601 + (iproc-1)*6 + 5) ;
            pvs.(wname).valid = "SIOC:SYS1:ML01:AO" + (601 + (iproc-1)*6 + 6) ;
          else % Look for changed config and re-load if so
            fd=dir(obj.OrbitConfigDir+"/conf_" + wname + ".mat");
            if fd.datenum > pobj.(wname).ConfigDate
              pobj.(wname).ConfigLoad(wname);
              fprintf('%s Config file changed on disk, re-loading...',datestr(now));
            end
          end
        else
          continue
        end
        % Add BPM reading to buffer
        if obj.BPMS.beamrate==0
          lcaPutNoWait(char(pvs.(wname).valid),0);
          continue
        end
        pobj.(wname).BPMS.read;
        % Fit orbit
        try
          [~,X1]=pobj.(wname).orbitfit;
          if any(isnan(X1))
            error('No valid BPM data in buffer or other orbit fitting error');
          end
          X1(5) = X1(5)*BEAMLINE{pobj.(wname).fitele}.P*1000 ; % Energy error in MeV
        catch ME
          lcaPutNoWait(char(pvs.(wname).valid),0);
          lcaPutNoWait('F2:WATCHER:ORBIT_STAT',1); % Write to watcher status PV
          throw(ME);
        end
        % Write orbit data to PVs
        lcaPutNoWait(cellstr([pvs.(wname).x;pvs.(wname).xp;pvs.(wname).y;pvs.(wname).yp;pvs.(wname).de;pvs.(wname).valid]),[X1(:);1]) ;
        lcaPutNoWait('F2:WATCHER:ORBIT_STAT',1); % Write to watcher status PV
      end
      
    end
    function acquire(obj,npulse)
      %ACQUIRE Get bpm and corrector data
      %acquire([npulse])
      global BEAMLINE
      % Clear data
      obj.DispFit=[];
      obj.DispData=[];
      % BPM data:
      if ~exist('npulse','var')
        npulse=obj.npulse;
      end
      if obj.usebpmbuff
        obj.BPMS.readbuffer(npulse);
      else
        obj.BPMS.readnp(npulse);
      end
      use=false(size(obj.usebpm));
      obj.LM.ModelClasses="MONI";
      use(~obj.badbpms & ismember(obj.bpmid,obj.LM.ModelID)) = true ;
      use(~ismember(obj.bpmid,obj.BPMS.modelID))=false;
      obj.usebpm = obj.usebpm & use ;
      % Corrector data:
      obj.LM.ModelClasses="XCOR";
      id = obj.xcorid ; 
      obj.cordat_x.z = arrayfun(@(x) BEAMLINE{x}.Coordi(3),id) ;
      xv = lcaGet(obj.xcorpv) ; % BDES / kGm
      xvmax = lcaGet(obj.xcormaxpv) ; % BDES / kGm
      P = arrayfun(@(x) BEAMLINE{x}.P,id) ;
      xv = xv ./ obj.LM.GEV2KGM ./ P(:) ; % kick angle
      xvmax = xvmax ./ obj.LM.GEV2KGM ./ P(:) ; % kick angle
      obj.cordat_x.theta = xv ;
      obj.cordat_x.thetamax = xvmax ;
      obj.LM.ModelClasses="YCOR";
      id = obj.ycorid ; 
      obj.cordat_y.z = arrayfun(@(x) BEAMLINE{x}.Coordi(3),id) ;
      yv = lcaGet(obj.ycorpv) ; % BDES / kGm
      yvmax = lcaGet(obj.ycormaxpv) ; % BDES / kGm
      P = arrayfun(@(x) BEAMLINE{x}.P,id) ;
      yv = yv ./ obj.LM.GEV2KGM ./ P(:); % kick angle
      yvmax = yvmax ./ obj.LM.GEV2KGM ./ P(:); % kick angle
      obj.cordat_y.theta=yv;
      obj.cordat_y.thetamax=yvmax;
      obj.calcperformed=false;
      obj.DispData=[];
    end
    function corcalc(obj)
      %CORCALC Calculate orbit correction and store calculation values
      
      if isempty(obj.BPMS.xdat)
        error('No BPM data taken');
      end
      
      % Get orbit at all BPMs
      [xm,ym,xstd,ystd] = obj.GetOrbit ;
      xm=xm.*1e-3; xstd=xstd.*1e-3; ym=ym.*1e-3; ystd=ystd.*1e-3;

      % Form overall response matrix
      obj.getr;
      A = obj.RM ;
      
      % If using model fitting, find solution to correct fitted orbit at end of region
      if obj.domodelfit
        [~,X1] = obj.orbitfit ; X=X1(1:4); X=obj.CorrectionOffset-X(:); X=X.*1e-3;
        ixc = double(obj.xcorid(obj.usexcor)) ; nxc=length(ixc);
        iyc = double(obj.ycorid(obj.useycor)) ;
        icor=[ixc(:); iyc(:)];
        R = zeros(4,length(icor));
        for ncor=1:length(icor)
          if icor(ncor)<=double(obj.fitele-1)
            [~,Rm]=RmatAtoB(icor(ncor),double(obj.fitele-1));
          end
          if ncor<=nxc
            R(1,ncor) = Rm(1,2) ;
            R(2,ncor) = Rm(2,2) ;
            R(3,ncor) = Rm(3,2) ;
            R(4,ncor) = Rm(4,2) ;
          else
            R(1,ncor) = Rm(1,4) ;
            R(2,ncor) = Rm(2,4) ;
            R(3,ncor) = Rm(3,4) ;
            R(4,ncor) = Rm(4,4) ;
          end
        end
        switch obj.corsolv
          case "lscov"
            dcor = lscov(R,X) ;
          case "pinv"
            dcor = R\X ;
          case "lsqminnorm"
            if ~isempty(obj.solvtol)
              dcor = lsqminnorm(R,X,obj.solvtol) ;
            else
              dcor = lsqminnorm(R,X) ;
            end
          case "svd"
            [U,S,V]=svd(R);
            sz=size(S);
            if obj.nmode>=1 && obj.nmode<max(sz)
              S(obj.nmode+1:end,obj.nmode+1:end)=0;
            end
            dcor = pinv(U*S*V') * X ;
          case "lsqlin"
            dxmin = [-obj.cordat_x.thetamax(obj.usexcor); -obj.cordat_y.thetamax(obj.useycor)] - [obj.cordat_x.theta(obj.usexcor); obj.cordat_y.theta(obj.useycor)] ;
            dxmax = [obj.cordat_x.thetamax(obj.usexcor); obj.cordat_y.thetamax(obj.useycor)] - [obj.cordat_x.theta(obj.usexcor); obj.cordat_y.theta(obj.useycor)] ;
            dcor = lsqlin(R,X,[],[],[],[],dxmin,dxmax);
        end
        
      else % Form correction vector to correct all BPMs selected
        
        % Correction vectors
        B = -[xm(:); ym(:)] ;
        W = 1./[xstd(:); ystd(:)].^2 ;
        
        % Generate solution for required corrector kicks (in radians) with requested solver
        switch obj.corsolv
          case "lscov"
            dcor = lscov(A,B,W) ;
          case "pinv"
            dcor = A\B ;
          case "lsqminnorm"
            if ~isempty(obj.solvtol)
              dcor = lsqminnorm(A,B,obj.solvtol) ;
            else
              dcor = lsqminnorm(A,B) ;
            end
          case "svd"
            [U,S,V]=svd(A);
            sz=size(S);
            if obj.nmode>=1 && obj.nmode<max(sz)
              S(obj.nmode+1:end,obj.nmode+1:end)=0;
            end
            dcor = pinv(U*S*V') * B ;
          case "lsqlin"
            dxmin = [-obj.cordat_x.thetamax(obj.usexcor); -obj.cordat_y.thetamax(obj.useycor)] - [obj.cordat_x.theta(obj.usexcor); obj.cordat_y.theta(obj.useycor)] ;
            dxmax = [obj.cordat_x.thetamax(obj.usexcor); obj.cordat_y.thetamax(obj.useycor)] - [obj.cordat_x.theta(obj.usexcor); obj.cordat_y.theta(obj.useycor)] ;
            dcor = lsqlin(A,B,[],[],[],[],dxmin,dxmax);
        end
      end
      
      % Store correction kicks and expected BPM response
      obj.dtheta_x(obj.usexcor) = dcor(1:sum(obj.usexcor)) ; obj.dtheta_x=obj.dtheta_x(:);
      obj.dtheta_y(obj.useycor) = dcor(1+sum(obj.usexcor):end) ; obj.dtheta_y=obj.dtheta_y(:);
      bpm_cor = [xm(:); ym(:)] + A*dcor ;
      obj.xbpm_cor(obj.usebpm) = 1e3.*bpm_cor(1:sum(obj.usebpm)) ;
      obj.ybpm_cor(obj.usebpm) = 1e3.*bpm_cor(1+sum(obj.usebpm):end) ;
      obj.calcperformed=true;
      if ~isempty(obj.aobj)
        obj.aobj.updateplots; % update plots
      end
    end
    function undocor(obj)
      %UNDOCOR Undo correction - put correctors back to previous values
      if obj.usex
        pvnames = obj.xcorcnames(obj.usexcor) ;
        if length(obj.bdesx_restore) ~=length(pvnames)
          error('No horizontal corrector restore data');
        end
        try
          control_magnetSet(pvnames(:),obj.bdesx_restore(:));
        catch ME
          fprintf(2,' !!!!!! error setting X correctors\n%s',ME.message);
        end
      end
      if obj.usey
        pvnames = obj.ycorcnames(obj.useycor) ;
        if length(obj.bdesy_restore) ~=length(pvnames)
          error('No vertical corrector restore data');
        end
        try
          control_magnetSet(pvnames(:),obj.bdesy_restore(:));
        catch ME
          fprintf(2,' !!!!!! error setting Y correctors\n%s',ME.message);
        end
      end
      obj.calcperformed=false;
    end
    function applycalc(obj)
      %APPLYCALC Set corrector magnets using calculated orbit steering data
      global BEAMLINE
      if ~obj.calcperformed
        error('Calculation not performed');
      end
      obj.bdesx_restore=[];
      obj.bdesy_restore=[];
      if obj.usex
        obj.LM.ModelClasses="XCOR";
        id = obj.xcorid(obj.usexcor) ;
        bdes1 = lcaGet(obj.xcorpv(obj.usexcor)) ; % BDES / kGm
        obj.bdesx_restore=bdes1;
        bmax = lcaGet(obj.xcormaxpv(obj.usexcor)) ; % BDES / kGm
        P = arrayfun(@(x) BEAMLINE{x}.P,id) ;
        bdes = bdes1 + obj.dtheta_x(obj.usexcor).*obj.LM.GEV2KGM.*P(:) ;
        pvnames = obj.xcorcnames(obj.usexcor) ;
        try
          control_magnetSet(pvnames(:),bdes(:));
        catch ME
          fprintf(2,' !!!!!! error setting X correctors\n%s',ME.message);
        end
        for icor=1:length(bdes1)
          fprintf('CAPUT: %s = %g -> %g',pvnames(icor),bdes1(icor),bdes(icor));
          if abs(bdes(icor))>bmax(icor)
            fprintf(' !!!!!! exceeds BMAX=%g\n',bmax(icor));
          end
          fprintf('\n');
        end
      end
      if obj.usey
        obj.LM.ModelClasses="YCOR";
        id = obj.ycorid(obj.useycor) ;
        bdes1 = lcaGet(obj.ycorpv(obj.useycor)) ; % BDES / kGm
        obj.bdesy_restore=bdes1;
        bmax = lcaGet(obj.ycormaxpv(obj.useycor)) ; % BDES / kGm
        P = arrayfun(@(x) BEAMLINE{x}.P,id) ;
        bdes = bdes1 + obj.dtheta_y(obj.useycor).*obj.LM.GEV2KGM.* P(:) ;
        pvnames = obj.ycorcnames(obj.useycor) ;
        try
          control_magnetSet(pvnames(:),bdes(:));
        catch ME
          fprintf(2,' !!!!!! error setting Y correctors\n%s',ME.message);
        end
        for icor=1:length(bdes1)
          fprintf('CAPUT: %s = %g -> %g',pvnames(icor),bdes1(icor),bdes(icor));
          if abs(bdes(icor))>bmax(icor)
            fprintf(' !!!!!! exceeds BMAX=%g\n',bmax(icor));
          end
          fprintf('\n');
        end
      end
      obj.calcperformed=false;
    end
    function getr(obj)
      %GETR Get model response matrices between correctors and BPMs
      ixc = double(obj.xcorid(obj.usexcor)) ;
      iyc = double(obj.ycorid(obj.useycor)) ;
      ibpm = double(obj.bpmid(obj.usebpm)) ;
      icor=[ixc; iyc];
      obj.RM = zeros(2*length(ibpm),length(icor));
      for ncor=1:length(icor)
        for nbpm=1:length(ibpm)
          if ibpm(nbpm)>icor(ncor)
            [~,R]=RmatAtoB(icor(ncor),ibpm(nbpm));
            if ismember(icor(ncor),ixc) % XCOR
              obj.RM(nbpm,ncor) = R(1,2) ;
              obj.RM(nbpm+length(ibpm),ncor) = R(3,2) ;
            else % YCOR
              obj.RM(nbpm,ncor) = R(1,4) ;
              obj.RM(nbpm+length(ibpm),ncor) = R(3,4) ;
            end
          end
        end
      end
    end
    function [freq_x,fft_x,freq_y,fft_y,modeamp_x,modeamp_y]=svdfft(obj,imode)
      dat = obj.svdanal(imode) ;
      modeamp_x = dat.xd*dat.Vtx(imode,:)' ;
      Y = fft(modeamp_x) ;
      L = length(modeamp_x);
      freq_x = obj.BPMS.beamrate*(0:(L/2))/L;
      P2 = abs(Y/L);
      P1 = P2(1:L/2+1);
      P1(2:end-1) = 2*P1(2:end-1);
      fft_x = P1;
      modeamp_y = dat.yd*dat.Vty(imode,:)' ;
      Y = fft(modeamp_y) ;
      L = length(modeamp_y);
      freq_y = obj.BPMS.beamrate*(0:(L/2))/L;
      P2 = abs(Y/L);
      P1 = P2(1:L/2+1);
      P1(2:end-1) = 2*P1(2:end-1);
      fft_y = P1;
    end
    function dispdat = svddisp(obj,varargin)
      %dispdat = svddisp()
      global BEAMLINE
      % Get energy
      id = find(ismember(obj.BPMS.modelnames,obj.ebpms)&ismember(obj.BPMS.modelnames,obj.bpmnames(obj.usebpm))) ;
      use_init=obj.usebpm;
      if isempty(id) % Temporarily add last energy bpm in selected region if none among selected BPMs
        usetemp=obj.BPMS.modelID >= obj.regid(1) & obj.BPMS.modelID <= obj.regid(2) ;
        id = find(ismember(obj.BPMS.modelnames,obj.ebpms)&ismember(obj.BPMS.modelnames,obj.bpmnames(usetemp))) ;
        obj.usebpm(id)=true;
      end
      ide = id(end) ;
      nbpm = find(obj.BPMS.modelID >= obj.regid(1) & obj.BPMS.modelID <= obj.regid(2)) ;
      dispx=nan(1,length(obj.bpmid)); dispy=dispx; dispx_err=dispx; dispy_err=dispx;
      dispdat.usebpm=ismember(obj.bpmid,obj.BPMS.modelID(nbpm));
      obj.usebpm=dispdat.usebpm;
      dat = obj.svdresponse(1,ide,10) ; % reconstituted BPM readings using mode most responsive to energy BPM
      xe = dat.xdat(ide,:) ;
      disp = obj.ebpms_disp(ismember(obj.ebpms,obj.BPMS.modelnames(ide)))' ;
      dp =  xe./disp  ; % dP/P @ energy BPMS
      masterID = find(dispdat.usebpm) ;
      for ibpm=1:length(nbpm)
        dp0=dp .* BEAMLINE{obj.BPMS.modelID(ide)}.P / BEAMLINE{obj.BPMS.modelID(nbpm(ibpm))}.P; % assumed dP/P @ BPM location
        gid = ~isnan(obj.BPMS.xdat(nbpm(ibpm),:)) ;
        [q,dq] = noplot_polyfit(dp0(gid),dat.xdat(nbpm(ibpm),gid),1,1) ;
        dispx(masterID(ibpm)) = q(2) ;
        dispx_err(masterID(ibpm)) = dq(2) ;
        gid = ~isnan(obj.BPMS.ydat(nbpm(ibpm),:)) ;
        [q,dq] = noplot_polyfit(dp0(gid),dat.ydat(nbpm(ibpm),gid),1,1) ;
        dispy(masterID(ibpm)) = q(2) ;
        dispy_err(masterID(ibpm)) = dq(2) ;
      end
      dispdat.ebpm=ide;
      dispdat.edisp=disp;
      dispdat.x=dispx;
      dispdat.xerr=dispx_err;
      dispdat.y=dispy;
      dispdat.yerr=dispy_err;
      if nargin>1 && varargin{1}=="all"
        obj.DispData_all = dispdat ;
      else
        obj.DispData = dispdat ;
      end
      obj.usebpm=use_init;
    end
    function DX_f = dispfit(obj,dfitele)
      %DISPFIT Fit BPM dispersion measurements to betatron orbit
      %DX_f = dispfit([fitele])
      % fitele (optional) = element to quote fitted dispersion (default=obj.fitele)
      % DX_f : fitted dispersion values at fitele location (d/s face): [Dx,D'x,Dy,D'y]
      if isempty(obj.DispData)
        return
      end
      dd=obj.DispData;
      use=dd.usebpm & obj.usebpm ;
      id=obj.bpmid(use);
      dispx_err = dd.xerr(use); dispy_err = dd.yerr(use) ;
      
      % Fit model dispersion response from first BPM in the selection
      i0=obj.regid(1);
      A = zeros(length(dd.x(use))+length(dd.y(use)),5) ; A(1,:) = [1 0 0 0 0] ; A(length(dd.x(use))+1,:) = [0 0 1 0 0] ;
      for ibpm=2:length(id)
        [~,R]=RmatAtoB(double(i0),double(id(ibpm)));
        A(ibpm,:) = [R(1,1) R(1,2) R(1,3) R(1,4) R(1,6)];
        A(ibpm+length(dd.x(use)),:) = [R(3,1) R(3,2) R(3,3) R(3,4) R(3,6)];
      end
      
      % - get scale factor that best fits all dispersion values
      dispx=dd.x(use); dispy=dd.y(use);
      if string(obj.orbitfitmethod)=="lscov"
        obj.disp0 = lscov(A,[dispx(:);dispy(:)],1./[dispx_err(:);dispy_err(:)].^2) ;
      else
        obj.disp0 = A \ [dispx(:);dispy(:)] ;
      end
      
      % Store fitted dispersion at each BPM location
      obj.DispFit = A * obj.disp0(:) ;
      
      % Return dispersion fit at fitele location
      if ~exist('dfitele','var')
        dfitele=double(obj.fitele);
      else
        dfitele=double(dfitele);
      end
      if dfitele==id(1)
        R=eye(6);
      else
        [~,R] = RmatAtoB(double(i0),dfitele);
      end
      DX_f = R([1:4 6],[1:4 6]) * obj.disp0(:) ;
      obj.DispFitEle = DX_f ;
      
    end
    function DX_cor = dispcor(obj,varargin)
      %DISPCOR Correct measured dispersion with any correction devices in range
      %DX_cor = dispcor()
      % DX_cor returns fitted dispersion at obj.fitele [Dx,D'x,Dy,D'y]
      % Correction device settings stored in DispCorData property (but not applied)
      %  NaN values in DispCorData property indicate that correction device not used
      global BEAMLINE PS
      
      % Get correction devices in range
      obj.LM.ModelClasses=["QUAD" "SEXT"];
      corsel = find(ismember(obj.DispDevices,obj.LM.ModelNames)) ;
      if isempty(corsel)
        error('No dispersion correction devices within selected range');
      end
      corele = obj.LM.ModelID(ismember(obj.LM.ModelNames,obj.DispDevices(corsel))) ;
      magID=ismember(obj.LiveModel.LEM.Mags.LM.ModelID,corele);
      bmax=obj.LiveModel.LEM.Mags.BMAX(magID)./10;
      
      % Fit correction device changes to cancel dispersion
      if nargin==1 % Launch the minimization algorithm
        % Get fitted dispersion at first device entrance
        DX_f = obj.dispfit(corele(1)-1) ;
        DX_f = DX_f.*1e-3 ;
        
        % Turn any sextupoles into quads
        qref=zeros(1,length(obj.DispDevices));
        n=0;
        for icor=corsel(:)'
          n=n+1;
          if obj.DispDeviceType(icor)>=3
            bmax(n)=1; % max 1mm change for sextupole movers
            for iele=findcells(BEAMLINE,'Name',char(obj.DispDevices(icor)))
              qref(icor) = PS(BEAMLINE{iele}.PS).Ampl ;
              BEAMLINE{iele}.Class='QUAD';
              PS(BEAMLINE{iele}.PS).Ampl=0;
            end
          end
        end
        psind = arrayfun(@(x) BEAMLINE{x}.PS,obj.LM.ModelID(ismember(obj.LM.ModelNames,obj.DispDevices))) ;
        ps_init = arrayfun(@(x) PS(x).Ampl,psind) ;
        try
          xmin = lsqnonlin(@(x) obj.dispcor(x,psind,qref,DX_f),zeros(1,length(corsel)),-bmax,bmax,optimset('Display','iter','MaxFunEvals',1000)) ;
%           xmin = fminsearch(@(x) obj.dispcor(x,psind,qref,DX_f),zeros(1,length(corsel)),optimset('Display','iter','MaxFunEvals',1000)) ;
%           xmin = fmincon(@(x) obj.dispcor(x,psind,qref,DX_f),zeros(1,length(corsel)),[],[],[],[],-bmax,bmax,[],optimset('Display','iter','MaxFunEvals',1000)) ;
        catch ME
          error(ME.identifier,'Dispersion minimization failed: %s',ME.message);
        end
        % Return corrected dispersion estimate at fit location and store correction device settings
        [~,R]=RmatAtoB(corele(1),double(obj.fitele-1));
        DX_cor = R(1:4,1:4) * DX_f.*1e3 ;
        obj.DispCorData=nan(1,length(obj.DispDevices));
        obj.DispCorData(corsel) = xmin ;
        % Turn Sextupoles back again
        for icor=corsel(:)'
          if obj.DispDeviceType(icor)>=3
            for iele=findcells(BEAMLINE,'Name',char(obj.DispDevices(icor)))
              BEAMLINE{iele}.Class='SEXT';
              BEAMLINE{iele}.Tilt=0;
            end
          end
        end
        % Restore initial magnet settings in model
        for n=1:length(psind)
          PS(psind(n)).Ampl = ps_init(n) ;
        end
      else % Process one step of the minimization
        x=varargin{1};
        psind=varargin{2};
        qref=varargin{3};
        DX_f=varargin{4};
        n=1;
        % Set magnets in model
        do_y=false;
        for icor=corsel(:)'
          if obj.DispDeviceType(icor)<3
            PS(psind(n)).Ampl = x(n) ;
          elseif obj.DispDeviceType(icor)==3 
            do_y=true;
            qn = x(n)*qref ; qs = x(n+1)*qref ; % Turn x/y sextupole moves into quad+skew-quad components
            th = atan(-qs/qn)/2 ; C_2 = qn/cos(2*th) ; % Get quad amplitude and rotation angle to generate normal and skew components
            PS(psind(n)).Ampl = C_2 ;
            for iele=PS(psind(n)).Element
              BEAMLINE{iele}.Tilt = th ;
            end
          end
          n=n+1;
        end
        % Transport dispersion function to downstream of last correction element
        i1=corele(1);
%         i2=PS(BEAMLINE{corele(end)}.PS).Element(end);
        i2 = double(obj.fitele-1) ;
        [~,R]=RmatAtoB(i1,i2);
        DX = R(1:4,1:4) * DX_f ;
        if do_y
%           DX_cor = sum(abs(DX(:))) ; % minimize total dispersion
          DX_cor = DX ;
        else
%           DX_cor = sum(abs(DX(1:2))) ; % minimize Dx / D'x
          DX_cor = DX(1:2) ;
        end
      end
    end
    function SetDispcor(obj)
      %SETDISPCOR Apply fitted dispersion correction device settings
      if isempty(obj.DispCorData) || all(isnan(obj.DispCorData))
        error('No valid dispersion correction fit data');
      end
      disp('Applying Dispersion Correction...');
      for icor=1:length(obj.DispDevices)
        if ~isnan(obj.DispCorData(icor))
          val = lcaGet(char(obj.DispDeviceReadPV(icor))) ;
          switch obj.DispDeviceType(icor)
            case {1,2}
              newval = double(val + obj.DispCorData(icor)*10) ; % Convert quad change into BDES units
            case {3,4}
              newval = double(val + obj.DispCorData(icor)*1000) ; % Convert sextupole position change into mm units
          end
          fprintf('%s : %g -> %g\n',char(obj.DispDeviceWritePV(icor)),val,newval);
          if obj.DispDeviceWriteProto(icor) == "EPICS"
            lcaPutNoWait(char(obj.DispDeviceWritePV(icor)),newval) ;
          else
            builder = pvaRequest(char(obj.DispDeviceWritePV(icor))) ;
            builder.with('Trim') ;
            builder.set(newval) ;
          end
        end
      end
    end
    function res = svdcorr(obj,corvec,nmode)
      %SVDCORR Find mode most highly correlated to provided vector
      %results = svdcorr(corvec,nmode)
      %  corvec: vector same length as nread BPMs
      %  nmode: number of highest value eigenmodes to consider
      %  results: reconstituted data from correlated mode
      if length(corvec)~=obj.BPMS.nread
        error('Correlation vector must be same length as # BPM pulses recorded');
      end
      badid=isnan(corvec);
      corvec(badid)=[];
      if isempty(corvec)
        error('All entries are bad in correlation vector');
      end
      dat = obj.svdanal(nmode) ;
      rx=zeros(1,nmode); ry=rx; px=rx; py=rx;
      for imode=1:nmode
        xv = dat.xd*dat.Vtx(imode,:)' ; xv(badid)=[];
        [r,p]=corrcoef(corvec,xv);
        if p<0.05
          rx(imode)=r;
          px(imode)=p;
        end
        yv = dat.yd*dat.Vty(imode,:)' ; yv(badid)=[];
        [r,p]=corrcoef(corvec,yv);
        if p<0.05
          ry(imode)=r;
          py(imode)=p;
        end
      end
      [~,xmode]=max(rx);
      [~,ymode]=max(ry);
      S=zeros(size(dat.Sx)); S(xmode,xmode)=dat.Sx(xmode,xmode);
      res.xdat = dat.Ux*S*dat.Vtx'; res.xdat=res.xdat';
      res.xdat(isnan(obj.BPMS.xdat))=nan; res.ydat(isnan(obj.BPMS.ydat))=nan;
      S=zeros(size(dat.Sy)); S(ymode,ymode)=dat.Sy(ymode,ymode);
      res.ydat = dat.Uy*S*dat.Vty'; res.ydat=res.ydat';
      res.sdat_x = dat.xd*dat.Vtx(xmode,:)' ;
      res.sdat_y = dat.yd*dat.Vty(ymode,:)' ;
      res.xmode=xmode;
      res.ymode=ymode;
      res.rx=rx(xmode); res.px=px(xmode);
      res.ry=ry(ymode); res.py=py(ymode);
    end
    function res = svdresponse(obj,dim,nbpm,nmode)
      %SVDRESPONSE Find mode most whose eigenvectors have the strongest response at given location
      %results = svdresponse(nbpm,nmode)
      %  dim: 1: consider horizontal BPM response 2: consider vertical BPM response
      %  nbpm: index of BPM looking for the stringest response in
      %  nmode: number of highest value eigenmodes to consider
      %  results: reconstituted data from eigenmode with strongest response
      
      % Perform SVD
      xd=obj.BPMS.xdat'; xd(isnan(xd))=0; xd=xd-mean(xd);
      yd=obj.BPMS.ydat'; yd(isnan(yd))=0; yd=yd-mean(yd);
      
      % Check inputs
      sz=size(xd);
      if nbpm<1 || nbpm>sz(2)
        error('Requested BPM index not found');
      end
      
      % Add response BPM to out of plane BPM readings
      if dim==1
        yd(:,end+1) = xd(:,nbpm);
      else
        xd(:,end+1) = yd(:,nbpm);
      end
      [Ux,Sx,Vtx]=svd(xd);
      [Uy,Sy,Vty]=svd(yd);
      
      resp=zeros(2,nmode);
      for imode=1:nmode
        S=zeros(size(Sx)); S(imode,imode)=Sx(imode,imode);
        xmode = Ux * S * Vtx' ;
        S=zeros(size(Sy)); S(imode,imode)=Sy(imode,imode);
        ymode = Uy * S * Vty' ;
        if dim==1
          resp(1,imode) = std(xmode(:,nbpm));
          resp(2,imode) = std(ymode(:,end));
        else
          resp(1,imode) = std(xmode(:,end));
          resp(2,imode) = std(ymode(:,nbpm));
        end
      end
      [~,ixmode]=max(resp(1,:));
      [~,iymode]=max(resp(2,:));
      S=zeros(size(Sx)); S(ixmode,ixmode)=Sx(ixmode,ixmode); 
      res.xdat = Ux * S * Vtx' ; res.xdat=res.xdat';
      if dim==2
        res.xdat=res.xdat(1:end-1,:);
      end
      S=zeros(size(Sy)); S(iymode,iymode)=Sy(iymode,iymode); 
      res.ydat = Uy * S * Vty' ; res.ydat=res.ydat';
      if dim==1
        res.ydat=res.ydat(1:end-1,:);
      end
      res.xmode=ixmode;
      res.ymode=iymode;
    end
    function dat = svdanal(obj,nmode)
      if ~exist('nmode','var') || isempty(nmode) || nmode>length(obj.BPMS.modelnames)
        nmode=length(obj.BPMS.modelnames);
      end
      xd=obj.BPMS.xdat'; xd(isnan(xd))=0; xd=xd-mean(xd);
      yd=obj.BPMS.ydat'; yd(isnan(yd))=0; yd=yd-mean(yd);
      [Ux,Sx,Vtx]=svd(xd);
      [Uy,Sy,Vty]=svd(yd);
      svals=[diag(Sx) diag(Sy)];
      dof{1} = zeros(nmode,length(obj.BPMS.modelnames)); dof{2}=dof{1};
      for ibpm=1:length(obj.BPMS.modelnames)
        [~,Sx1]=svd(xd(:,1:ibpm));
        [~,Sy1]=svd(yd(:,1:ibpm));
        sz=size(Sx1);
        imax=min([nmode sz(2)]);
        dof{1}(1:imax,ibpm)=diag(Sx1(1:imax,1:imax));
        dof{2}(1:imax,ibpm)=diag(Sy1(1:imax,1:imax));
      end
      dat.Ux=Ux; dat.Sx=Sx; dat.Vtx=Vtx;
      dat.Uy=Uy; dat.Sy=Sy; dat.Vty=Vty;
      dat.svals=svals; dat.dof=dof;
      dat.xd=xd; dat.yd=yd;
      if ~isempty(obj.aobj)
        obj.aobj.DropDown.Items = "Mode " + string(1:length(svals)) ;
        obj.aobj.NmodesEditField.Limits=[1,length(svals)];
        if obj.aobj.NmodesEditField.Value > length(svals)
          obj.aobj.NmodesEditField.Value = length(svals) ;
        end
        if ~ismember(obj.aobj.DropDown.Value,obj.aobj.DropDown.Items)
          obj.aobj.DropDown.Value = obj.aobj.DropDown.Items(1) ;
        end
      end
    end
    function [X0,X1] = orbitfit(obj)
      %ORBITFIT Fit an orbit to selected location
      %[X0,X1] = orbitfit()
      % X0: [x,x',y,y',dE/E] at start of region (istart) [mm,mrad]
      % X1: [x,x',y,y',dE/E] at obj.fitele [mm,mrad]
      
      [xm,ym,xstd,ystd,~,id] = obj.GetOrbit ;
      % Treat missing data as 0 with large errors to de-weight fit
      xm(isnan(xm))=0;  xstd(isnan(xstd))=10;
      ym(isnan(ym))=0;  ystd(isnan(ystd))=10;
      % Convert to m/rad units for calculations
      xm=xm.*1e-3; ym=ym.*1e-3; xstd=xstd.*1e-3; ystd=ystd.*1e-3;
      
      A = zeros(length(xm)+length(ym),5) ; A(1,:) = [1 0 0 0 0] ; A(length(xm)+1,:) = [0 0 1 0 0] ;
      for ibpm=2:length(id)
        [~,R]=RmatAtoB(id(1),id(ibpm));
        A(ibpm,:) = [R(1,1) R(1,2) R(1,3) R(1,4) R(1,6)];
        A(ibpm+length(xm),:) = [R(3,1) R(3,2) R(3,3) R(3,4) R(3,6)];
      end
      if obj.dormsplot
        xf = A \ [xstd(:);ystd(:)] ;
      else
        if string(obj.orbitfitmethod)=="lscov"
          xf = lscov(A,[xm(:);ym(:)],1./[xstd(:);ystd(:)].^2) ;
        else
          xf = A \ [xm(:);ym(:)] ;
        end
      end
      i0=obj.regid(1); 
      [~,R] = RmatAtoB(double(i0),double(id(1))); R=R([1:4 6],[1:4 6]);
      X0 = R \ xf ;
      i1=obj.fitele;
      if i0>i1
        error('Desired fit location before start of selected region, aborting.');
      end
      [~,R]=RmatAtoB(double(i0),double(i1)); R=R([1:4 6],[1:4 6]);
      X1 = R * X0 ;
      X1(1:4)=X1(1:4).*1e3; 
      obj.OrbitFit = X1 ;        
      X0(1:4)=X0(1:4).*1e3; 
    end
    function StoreRef(obj)
      %STOREREF Store new reference orbit from existing data
      id = double(obj.BPMS.modelID) ;
      xm = mean(obj.BPMS.xdat,2,'omitnan') ;
      ym = mean(obj.BPMS.ydat,2,'omitnan') ;
      obj.RefOrbitLocal = {now id(:) xm(:) ym(:)} ;
    end
    function ConfigSave(obj,name)
      %CONFIGSAVE Store settings in config file
      %ConfigSave() Overwrite current config file
      %ConfigSave(NewConfigName) Write new config file
      if ~exist('name','var') % default is overwrite current config
        if obj.ConfigName~="none"
          name = obj.ConfigName ;
        else
          return
        end
      end
      fn = obj.OrbitConfigDir+"/conf_" + name + ".mat" ;
      % Get reference orbit to store
      reforbit = obj.RefOrbitLocal ;
      obj.RefOrbitConfig = obj.RefOrbitLocal ;
      % For some bizzarre reason, usebpm, usexcor & useycor all load with false values regardless of their saved state, so use separate variables for these
      OrbitApp=copy(obj);
      usebpm=obj.usebpm; usexcor=obj.usexcor; useycor=obj.useycor; %#ok<PROPLC>
      save(fn,'OrbitApp','reforbit','usebpm','usexcor','useycor');
      obj.ConfigName = name ;
    end
    function ConfigLoad(obj,name)
      %CONFIGLOAD Restore settings from saved config file
      if name=="none"
        return
      end
      if ~ismember(name,obj.Configs)
        error('No matching config file')
      end
      fprintf('Loading configuration file: %s\n',name);
      try
        % usebpm, usexcor & useycor all load with false values regardless of their saved state, so use separate variables for these
        ld = load(obj.OrbitConfigDir+"/conf_" + name + ".mat",'OrbitApp','usebpm','usexcor','useycor','reforbit') ;
        fd = dir(obj.OrbitConfigDir+"/conf_" + name + ".mat") ;
        obj.ConfigDate = fd.datenum ;
      catch ME
        fprintf(2,'Error loading config: %s\n',name);
        throw(ME);
      end
      % Set region
      obj.UseRegion = ld.OrbitApp.UseRegion ;
      % Set BPM list
      obj.usebpm = ismember(obj.bpmnames,ld.OrbitApp.bpmnames(ld.usebpm));
      % Set corrector lists
      obj.usexcor = ismember(obj.xcornames,ld.OrbitApp.xcornames(ld.usexcor));
      obj.useycor = ismember(obj.ycornames,ld.OrbitApp.ycornames(ld.useycor));
      % Clear data
      obj.cordat_x = [] ;
      obj.cordat_y = [] ;
      obj.dtheta_x = [] ;
      obj.dtheta_y = [] ;
      obj.xbpm_cor = [] ;
      obj.ybpm_cor = [] ;
      obj.DispData = [] ;
      obj.DispFit = [] ;
      % Load in reference orbit
      obj.RefOrbitConfig = ld.reforbit ;
      obj.RefOrbitLocal = ld.reforbit ;
      % Load everything else...
      restorelist=["corsolv" "solvtol" "usex" "usey" "nmode" "domodelfit" "usebpmbuff" "dormsplot"  "fitele" "CorrectionOffset" "npulse" "orbitfitmethod" "plotallbpm" "escanrange" "escandev" "nescan" "UseRefOrbit"] ;
      for ilist=1:length(restorelist)
        try
          obj.(restorelist(ilist)) = ld.OrbitApp.(restorelist(ilist)) ;
        catch
          fprintf(2,"Property not found in config file (or inconsistent): %s\n",restorelist(ilist));
        end
      end
      % Set current configuration name
      obj.ConfigName = name ;
    end
    function ConfigDelete(obj,name)
      %CONFIGDELETE Remove a configuration file
      %ConfigDelete() Remove current config file
      %ConfigDelete(ConfigName) Remove named configuration file
      
      if ~exist('name','var;')
        name=obj.ConfigName;
      end
      delete(obj.OrbitConfigDir+"/conf_"+name+".mat") ;
      obj.ConfigName = "none" ;
      
    end
    function GuiConfigLoad(obj,event)
      %GUICONFIGLOAD callback from GUI menu to load a config
      global BEAMLINE
      conf = event.Source.Tag;
      obj.aobj.FACETIIOrbitToolconfignoneUIFigure.Name = sprintf("FACET-II Orbit Tool [config = %s]",conf);
      for imenu=1:length(obj.aobj.SelectMenu.Children)
        obj.aobj.SelectMenu.Children(imenu).Checked=0;
      end
      event.Source.Checked=1;
      obj.ConfigLoad(conf); % Load objecty properties from file
      % Update GUI fields
      % --- Region buttons
      value=obj.UseRegion;
      obj.aobj.INJButton.Value=value(1);
      obj.aobj.L0Button.Value=value(2);
      obj.aobj.DL1Button.Value=value(3);
      obj.aobj.L1Button.Value=value(4);
      obj.aobj.BC11Button.Value=value(5);
      obj.aobj.L2Button.Value=value(6);
      obj.aobj.BC14Button.Value=value(7);
      obj.aobj.L3Button.Value=value(8);
      obj.aobj.BC20Button.Value=value(9);
      obj.aobj.FFSButton.Value=value(10);
      obj.aobj.SPECTButton.Value=value(11);
      % --- Global fields
      obj.aobj.NPulseEditField.Value = obj.npulse ;
      obj.aobj.NReadEditField.Value = 0 ;
      obj.aobj.UseBufferedDataCheckBox.Value = obj.usebpmbuff ;
      obj.WriteGuiListBox(); % Updates BPM & corrector list boxes
      obj.aobj.PlotallCheckBox.Value = obj.plotallbpm ;
      % --- Orbit Tab
      obj.aobj.EditField_13.Value = BEAMLINE{obj.aobj.aobj.fitele}.Name ;
      obj.aobj.EditField_4.Value = obj.CorrectionOffset(1) ;
      obj.aobj.EditField_6.Value = obj.CorrectionOffset(2) ;
      obj.aobj.EditField_8.Value = obj.CorrectionOffset(3) ;
      obj.aobj.EditField_10.Value = obj.CorrectionOffset(4) ;
      obj.aobj.DropDown_5.Value = obj.orbitfitmethod ;
      for n=[3 5 7 9 11]
        obj.aobj.(sprintf('EditField_%d',n)).Value = 0 ;
      end
      switch obj.UseRefOrbit
        case "none"
          obj.aobj.DropDown_4.Value = '1' ;
        case "local"
          obj.aobj.DropDown_4.Value = '2' ;
        case "config"
          obj.aobj.DropDown_4.Value = '3' ;
      end
      obj.aobj.TolEditField.Value = 0 ;
      switch obj.corsolv % string {mustBeMember(corsolv,["lscov","pinv","lsqminnorm","svd","lsqlin"])}
        case "lscov"
          obj.aobj.lscovButton.Value=1;
        case "pinv"
          obj.aobj.pinvButton.Value=1;
        case "lsqminnorm"
          obj.aobj.lsqminnormButton.Value=1;
          if ~isempty(obj.solvtol)
            obj.aobj.TolEditField.Value = obj.solvtol ;
          end
        case "svd"
          obj.aobj.svdButton.Value=1;
          if ~isinf(obj.nmode)
            obj.aobj.TolEditField.Value = obj.nmode ;
          end
        case "lsqlin"
          obj.aobj.lsqlinButton.Value=1;
      end
      obj.aobj.ModelFitButton.Value=obj.domodelfit;
      % --- Dispersion Tab
      obj.aobj.DropDown_6.Value = obj.orbitfitmethod ;
      obj.aobj.EditField_23.Value = BEAMLINE{obj.aobj.aobj.fitele}.Name ;
      %====================================================================
      obj.aobj.updateplots;
      drawnow
    end
    function DoEscan(obj,nbpm)
      %DOESCAN Perform energy scan and extract dispersion function at BPMs by driving feedback setpoint offsets
      %DoEscan(Nbpm)
      % Nbpm: number BPM readings to take per energy scan setting
      
      id = find(ismember(["DL10" "BC11" "BC14" "BC20"],obj.escandev)) ;
      
      % Get initial energy feedback setpoint offsets
      E_init = lcaGet(char(obj.EOffsetPV(id))) ; % MeV
      FB11=SCP_FB; FB11.name="TRANS_LI11"; li11fbstate=FB11.state;
      FB18=SCP_FB; FB18.name="TRANS_LI18"; li18fbstate=FB18.state;
      
      % Get energy knob to scan and desired range
      evals_s = linspace(obj.escanrange(1,id),obj.escanrange(2,id),obj.nescan(id)) ; % Delta-E (MeV)
      evals=evals_s(randperm(length(evals_s))); % Randomize energy ordering
      ntop = floor(length(evals_s)/2) ;
%       nbot = length(evals_s)-ntop ;
      
      % Scan the energy knob
      obj.escandata=cell(length(evals),7);
      disp("Disabling upstream feedbacks...");
      fb_init = lcaGet('SIOC:SYS1:ML00:AO856');
      fb_off = fb_init ;
      fbid = [1 3 2 5];
      if id<4
        for ifb=id+1:4
          fb_off=bitset(fb_off,fbid(ifb),0);
        end
      end
      lcaPut('SIOC:SYS1:ML00:AO856',fb_off);
      if id<4
        FB18.state="Compute" ;
      end
      if id<3
        FB11.state="Compute" ;
      end
      disp("Starting energy scan...");
      try
         % Status display data
        if ~isempty(obj.aobj)
          axtop = obj.aobj.UIAxes5 ; axbot = obj.aobj.UIAxes5_2 ;
          obj.EscanStatPlot(axtop,axbot,evals_s);
        end
        cmd2={[] []};
        for ival=1:length(evals)
          if obj.doabort
            obj.doabort=false;
            error('User abort requested');
          end
          % Show scan status on plot window
          if ~isempty(obj.aobj)
            ipl=find(ismember(evals_s,evals(ival)));
            if ipl>ntop
              cmd=[0 ipl-ntop];
              cmd2{2}=[cmd2{2} ipl-ntop];
            else
              cmd=[ipl 0];
              cmd2{1}=[cmd2{1} ipl];
            end
            obj.EscanStatPlot(axtop,axbot,evals_s,cmd,cmd2,'');
          end
          % Set FB setpoint
          fprintf('Change FB energy offset: Scan # (%d of %d) dE = %g MeV\n',ival,length(evals),evals(ival));
          if id==1 || id==2
            lcaPut(char(obj.EOffsetPV(id)),1000*(E_init+evals(ival))); % keV
          else
            lcaPut(char(obj.EOffsetPV(id)),E_init+evals(ival)); % MeV
          end
          pause(2);
          lcaPut(char(obj.FBDeadbandPV(id)),0);
          % Get BPM data when deadband of FB reached
          while obj.DispMeasMethod==0 && lcaGet(char(obj.FBDeadbandPV(id)))==0
            obj.EscanStatPlot(axtop,axbot,evals_s,cmd,cmd2,sprintf('(Meas = %.2f)',lcaGet(char(obj.EPV(id)))-E_init)); % also does drawnow
            pause(0.1);
            if obj.doabort
              obj.doabort=false;
              cla(axtop); cla(axbot); axtop.reset; axbot.reset;
              drawnow;
              error('User abort requested');
            end
          end
          disp("Geting BPM data...");
          switch obj.DispMeasMethod
            case 0
              obj.BPMS.BufferLen=nbpm;
              obj.BPMS.resetPID();
            case 1
              obj.BPMS.readbuffer(nbpm,true) ; % asyn buffer read request
          end
          while 1
            switch obj.DispMeasMethod
              case 0
                if obj.BPMS.pulseid<nbpm
                  break;
                end
                obj.EscanStatPlot(axtop,axbot,evals_s,cmd,cmd2,sprintf('Reading BPMs...\n( pulse %d/%d )',obj.BPMS.pulseid,nbpm)); % also does drawnow
                if lcaGet(char(obj.FBDeadbandPV(id)))
                  obj.BPMS.read();
                else
                  pause(0.1);
                end
              case 1
                if obj.BPMS.readbuffer(nbpm,true)
                  break;
                end
                obj.EscanStatPlot(axtop,axbot,evals_s,cmd,cmd2,'Reading BPMs...'); % also does drawnow
            end
            if obj.doabort
              obj.doabort=false;
              cla(axtop); cla(axbot); axtop.reset; axbot.reset;
              drawnow;
              error('User abort requested');
            end
          end
          % Process and store data
          [xm,ym,xstd,ystd,use,orbid] = obj.GetOrbit("all");
          xstd(xstd==0)=min(xstd(xstd>0)); ystd(ystd==0)=min(ystd(ystd>0));
          obj.escandata{ival,1}=xm;
          obj.escandata{ival,2}=ym;
          obj.escandata{ival,3}=xstd;
          obj.escandata{ival,4}=ystd;
          obj.escandata{ival,5}=use;
          obj.escandata{ival,6}=orbid;
          obj.escandata{ival,7}=evals(ival);
          if obj.DispMeasMethod>0
            xd=nan(length(use),nbpm); yd=xd;
            xd(ismember(obj.bpmid,obj.BPMS.modelID),1:obj.BPMS.nread) = obj.BPMS.xdat ;
            yd(ismember(obj.bpmid,obj.BPMS.modelID),1:obj.BPMS.nread) = obj.BPMS.ydat ;
            obj.escandata{ival,8}=xd;
            obj.escandata{ival,9}=yd;
          end
          % Show scan status on plot window
          if ~isempty(obj.aobj)
            obj.EscanStatPlot(axtop,axbot,evals_s,[0 0],cmd2,'');
          end
        end
      catch ME
        lcaPut('SIOC:SYS1:ML00:AO856',fb_init);
        FB11.state=li11fbstate; FB18.state=li18fbstate;
        lcaPut(char(obj.EOffsetPV(id)),E_init) ;
        throw(ME);
      end
      disp("Re-Enable Feedbacks...");
      lcaPut('SIOC:SYS1:ML00:AO856',fb_init);
      lcaPut(char(obj.EOffsetPV(id)),E_init) ;
      FB11.state=li11fbstate; FB18.state=li18fbstate;
      disp("Finished energy scan.");
      if ~isempty(obj.aobj)
        cla(axtop); cla(axbot); axtop.reset;axbot.reset;
      end
    end
    function dispdat = ProcEscan(obj)
      %PROCESCAN Process escan data to generate dispersion at BPMs
      switch obj.DispMeasMethod
        case 0
          dispdat = obj.ProcEscan0 ;
        case 1
          dispdat = obj.ProcEscan1 ;
      end
    end
    function dispdat = ProcEscan0(obj)
      %PROCESCAN0 Process escan data to generate dispersion at BPMs
      % This function used for DispMeasMethod=0
      global BEAMLINE
      if isempty(obj.escandata)
        error('No energy scan performed');
      end
      evals = [obj.escandata{:,7}] ; % Delta-E (MeV)
      xvals=nan(length(evals),sum(obj.useregbpm)); yvals=xvals; dxvals=xvals; dyvals=xvals;
      use=obj.escandata{1,5};
      for idat=1:length(evals)
        use=use & obj.escandata{idat,5};
        xvals(idat,obj.escandata{idat,5}) = obj.escandata{idat,1} ;
        dxvals(idat,obj.escandata{idat,5}) = obj.escandata{idat,3} ;
        yvals(idat,obj.escandata{idat,5}) = obj.escandata{idat,2} ;
        dyvals(idat,obj.escandata{idat,5}) = obj.escandata{idat,4} ;
      end
      bid=obj.bpmid(use);
      dispx=nan(1,length(obj.bpmid)); dispx_err=dispx; dispy=dispx; dispy_err=dispx;
      n=1;
      for ibpm=find(use(:))'
        sel = ~isnan(xvals(:,ibpm)) ;
        if sum(sel)>=3
          x = evals(sel) / (BEAMLINE{bid(n)}.P.*1000) ; y = xvals(sel,ibpm) ; dy = dxvals(sel,ibpm) ;
          dy(dy==0)=min(dy(dy>0));
          [q,dq] = noplot_polyfit(x,y,dy,double(obj.escanfitorder)) ;
          dispx(ibpm) = q(1+obj.escanplotorder); dispx_err(ibpm) = dq(1+obj.escanplotorder) ;
        end
        sel = ~isnan(yvals(:,ibpm)) ;
        if sum(sel)>=3
          x = evals(sel) / (BEAMLINE{bid(n)}.P.*1000) ; y = yvals(sel,ibpm) ; dy = dyvals(sel,ibpm) ;
          dy(dy==0)=min(dy(dy>0));
          [q,dq] = noplot_polyfit(x,y,dy,double(obj.escanfitorder)) ;
          dispy(ibpm) = q(1+obj.escanplotorder); dispy_err(ibpm) = dq(1+obj.escanplotorder) ;
        end
        n=n+1;
      end
      dispdat.ebpm=nan;
      dispdat.usebpm=use;
      dispdat.x=dispx;
      dispdat.xerr=dispx_err;
      dispdat.y=dispy;
      dispdat.yerr=dispy_err;
      obj.DispData = dispdat ;
    end
    function dispdat = ProcEscan1(obj)
      %PROCESCAN1 Process escan data to generate dispersion at BPMs
      % This function used for DispMeasMethod=1
      global BEAMLINE
      
      if isempty(obj.escandata)
        error('No energy scan performed');
      end
      
      evals = [obj.escandata{:,7}] ; % Delta-E (MeV) - commanded energy changes
      [~,np] = size(obj.escandata{1,8}) ;
      xvals=nan(sum(obj.useregbpm),length(evals)*np); yvals=xvals;
      use=obj.escandata{1,5};
      for idat=1:length(evals)
        use=use & obj.escandata{idat,5};
        pid = 1 + (idat-1)*np : idat*np ; 
        xvals(:,pid) = obj.escandata{idat,8}(use,:) ;
        yvals(:,pid) = obj.escandata{idat,9}(use,:) ;
      end
      bid=obj.bpmid(use);
      
      % - use upstream most energy BPM for energy reference
      for ibpm=1:length(obj.ebpms)
        ind = findcells(BEAMLINE,'Name',char(obj.ebpms(ibpm))) ;
        ebpm=find(double(bid)==ind,1);
        if any(~isnan(xvals(ebpm,:)))
          break;
        end
      end
      evals = BEAMLINE{ind}.P .* ( xvals(ebpm,:) ./ obj.ebpms_disp(ibpm) ) ;
      obj.escandata{1,10} = evals.*1000 ;
      
      dispx=nan(1,length(obj.bpmid)); dispx_err=dispx; dispy=dispx; dispy_err=dispx;
      n=1;
      for ibpm=find(use(:))'
        sel = ~isnan(xvals(n,:)) ;
        if sum(sel)>=3
          x = evals(sel) / BEAMLINE{bid(n)}.P ; y = xvals(n,sel) ;
          [q,dq] = noplot_polyfit(x,y,0,double(obj.escanfitorder)) ;
          dispx(ibpm) = q(1+obj.escanplotorder); dispx_err(ibpm) = dq(1+obj.escanplotorder) ;
        end
        sel = ~isnan(yvals(n,:)) ;
        if sum(sel)>=3
          x = evals(sel) / BEAMLINE{bid(n)}.P ; y = yvals(n,sel) ;
          [q,dq] = noplot_polyfit(x,y,0,double(obj.escanfitorder)) ;
          dispy(ibpm) = q(1+obj.escanplotorder); dispy_err(ibpm) = dq(1+obj.escanplotorder) ;
        end
        n=n+1;
      end
      dispdat.ebpm=nan;
      dispdat.usebpm=use;
      dispdat.x=dispx;
      dispdat.xerr=dispx_err;
      dispdat.y=dispy;
      dispdat.yerr=dispy_err;
      obj.DispData = dispdat ;
    end
    function cobj = copyobj(obj)
      cobj=copy(obj);
      cobj.BPMS=copy(obj.BPMS);
    end
    function [xm,ym,xstd,ystd,use,id] = GetOrbit(obj,varargin)
      %GETORBIT Return mean and rms orbit from raw data
      %[xm,ym,xstd,ystd,use,id] = GetOrbit()
      %[xm,ym,xstd,ystd,use,id] = GetOrbit("all") % Include locally un-selected BPMs
      % use and id reference obj.bpmid
      
      if nargin>1 && varargin{1}=="all"
        id=obj.bpmid(obj.useregbpm) ;
      else
        id=obj.bpmid(obj.usebpm);
      end
      id=double(id(ismember(id,obj.BPMS.modelID)));
      use=ismember(obj.bpmid,id);
      use_local=ismember(obj.BPMS.modelID,id);
      if ~any(use)
        error('No BPM Data to use');
      end
      xm = mean(obj.BPMS.xdat,2,'omitnan') ; xm=xm(use_local);
      ym = mean(obj.BPMS.ydat,2,'omitnan') ; ym=ym(use_local);
      xstd = std(obj.BPMS.xdat,[],2,'omitnan') ; xstd=xstd(use_local);
      ystd = std(obj.BPMS.ydat,[],2,'omitnan') ; ystd=ystd(use_local);
      if ~isempty(obj.RefOrbit)
        [rid,idd] = ismember(id,obj.RefOrbit(:,1)) ;
        xm = xm(rid) ; xstd=xstd(rid); ym = ym(rid); ystd=ystd(rid);
        xm = xm - obj.RefOrbit(idd,2) ; ym = ym - obj.RefOrbit(idd,3) ;
        id=id(rid);
        use=ismember(obj.bpmid,id);
      end
    end
    function WriteGuiListBox(obj)
      %WRITEGUILISTBOX Update BPM and Corrector list boxes on gui
      % List all BPMs / correctors in region and show selected ones
      obj.LM.ModelClasses="MONI";
      usereg=false(size(obj.usebpm));
      usereg(~obj.badbpms & ismember(obj.bpmid,obj.LM.ModelID)) = true ;
      obj.aobj.ListBox.Items = obj.bpmnames(usereg) ;
      obj.aobj.ListBox.ItemsData = obj.bpmid(usereg) ;
      obj.aobj.ListBox.Value = obj.bpmid(obj.usebpm) ;
      obj.LM.ModelClasses="XCOR";
      usereg=false(size(obj.usexcor));
      usereg(~obj.badxcors & ismember(obj.xcorid,obj.LM.ModelID)) = true ;
      obj.aobj.ListBox_2.Items = obj.xcornames(usereg) ;
      obj.aobj.ListBox_2.ItemsData = obj.xcorid(usereg) ;
      obj.aobj.ListBox_2.Value = obj.xcorid(obj.usexcor) ;
      obj.LM.ModelClasses="YCOR";
      usereg=false(size(obj.useycor));
      usereg(~obj.badycors & ismember(obj.ycorid,obj.LM.ModelID)) = true ;
      obj.aobj.ListBox_3.Items = obj.ycornames(usereg) ;
      obj.aobj.ListBox_3.ItemsData = obj.ycorid(usereg) ;
      obj.aobj.ListBox_3.Value = obj.ycorid(obj.useycor) ;
    end
    % Plotting functions
    function plottol(obj)
      %PLOTTOL Show factorization data for response matrix to estimate tolerance to use in correction
      
      switch obj.corsolv
        case "lsqminnorm"
          obj.getr;
          A = obj.RM;
          [~,R] = qr(A,0);
          figure
          semilogy(abs(diag(R)),'o')
        otherwise
          id = ismember(obj.BPMS.modelID,obj.bpmid(obj.usebpm)) ;
          xm = mean(obj.BPMS.xdat(id,:),2,'omitnan') ;
          ym = mean(obj.BPMS.ydat(id,:),2,'omitnan') ;
          obj.getr;
          A = obj.RM ;
          B = -[xm(:); ym(:)] ;
          [U,S,Vt]=svd(A);
          sz=size(S); xc=zeros(1,sz(1)); yc=xc;
          for nm=1:sz(1)
            if nm<sz(1)
              Sn=S; Sn(nm+1:end,nm+1:end)=0;
            else
              Sn=S;
            end
            dcor = pinv(U*Sn*Vt') * B ;
            bpm_cor = [xm(:); ym(:)] + A*dcor ;
            xc(nm) = std(bpm_cor(1:length(xm)));
            yc(nm) = std(bpm_cor(1+length(xm):end));
          end
          figure
          subplot(2,1,1), plot(1:nm,xc.*1e3), xlabel('N Modes'); ylabel('RMS X Orbit (<x^2>^{1/2}) [mm]'); grid on;
          subplot(2,1,2), plot(1:nm,yc.*1e3), xlabel('N Mode'); ylabel('RMS Y Orbit (<y^2>^{1/2}) [mm]'); grid on;
      end
    end
    function plotdisp(obj,ahan,showmodel,showcors,plotall)
      global BEAMLINE
      if isempty(obj.DispData)
        return
      end
      
      % Make new axes if generating plot for logbook
      if ~exist('ahan','var') || isempty(ahan) || obj.aobj.logplot
        fhan=figure;
        sp1=subplot(2,1,1,'Parent',fhan);
        sp2=subplot(2,1,2,'Parent',fhan);
        ahan=[sp1 sp2];
      else
        ahan(1).reset; ahan(2).reset; cla(ahan(1)); cla(ahan(2)); drawnow;
      end
      
      if ~exist('plotall','var')
        plotall=false;
      end
      
      if ~exist('showmodel','var')
        showmodel=false;
      end
      ahan(1).reset; ahan(2).reset;
      dd=obj.DispData;
      use = dd.usebpm&obj.usebpm ;
      id=obj.bpmid(use) ;
      z = arrayfun(@(x) BEAMLINE{x}.Coordi(3),id) ;
      ddispx = obj.LiveModel.DesignTwiss.etax(id) ;
      ddispy = obj.LiveModel.DesignTwiss.etay(id) ;
      names = obj.bpmnames(dd.usebpm&obj.usebpm);
      dispx = dd.x(use) - ddispx.*1000 ; dispy = dd.y(use) - ddispy.*1000 ; % subtract design dispersion to show dispersion error
%       dispx = dd.x(use) ; dispy = dd.y(use) ; % subtract design dispersion to show dispersion error
      dispx_err = dd.xerr(use); dispy_err = dd.yerr(use) ;
      if plotall
        id_all=obj.bpmid(dd.usebpm&~obj.usebpm) ;
        z_all = arrayfun(@(x) BEAMLINE{x}.Coordi(3),id_all) ;
        use_all=dd.usebpm&~obj.usebpm;
        ddispx_all = obj.LiveModel.DesignTwiss.etax(id_all) ;
        ddispy_all = obj.LiveModel.DesignTwiss.etay(id_all) ;
        names_all = obj.bpmnames(dd.usebpm&~obj.usebpm);
        dispx_all = dd.x(use_all) - ddispx_all.*1000 ; dispy_all = dd.y(use_all) - ddispy_all.*1000 ; % subtract design dispersion to show dispersion error
        dispx_err_all = dd.xerr(use_all); dispy_err_all = dd.yerr(use_all) ;
      end
      
      % Check dispersion fit to bpms has happened
      if isempty(obj.DispFit)
        DX=obj.dispfit();
      else
        DX=obj.DispFitEle;
      end
      
      % Do plots
      if plotall
        pl_all=errorbar(ahan(1),z_all,dispx_all,dispx_err_all,'k.');
        hold(ahan(1),'on');
      end
      pl=errorbar(ahan(1),z,dispx,dispx_err,'.','Color',F2_common.ColorOrder(2,:));
      grid(ahan(1),'on');
      ylabel(ahan(1),'\Delta\eta_x [mm]');
      pl.DataTipTemplate.DataTipRows(1).Label = 'Linac Z (m)' ;
      pl.DataTipTemplate.DataTipRows(2).Label = '\Delta\eta_x (mm)' ;
      pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',cellstr(names));
      if plotall
        pl_all.DataTipTemplate.DataTipRows(1).Label = 'Linac Z (m)' ;
        pl_all.DataTipTemplate.DataTipRows(2).Label = '\Delta\eta_x (mm)' ;
        pl_all.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',cellstr(names_all));
      end
      if showmodel
        hold(ahan(1),'on');
        if plotall
          i1=min([id(1) id_all(1)])+1;
          i2=max([id(end) id_all(end)]);
        else
          i1=id(1)+1;
          i2=id(end);
        end
        n=0;
        dfit_x=zeros(1,i2-i1+1); dfit_y=dfit_x; dfit_z=dfit_x;
        for ind=i1:i2
          n=n+1;
          if ind>i1
            [~,R] = RmatAtoB(double(obj.regid(1)),double(ind));
          else
            R=eye(6);
          end
          D = R([1:4 6],[1:4 6]) * obj.disp0(:) ;
          dfit_x(n) = D(1) - obj.LiveModel.DesignTwiss.etax(ind+1)*1000 ; 
          dfit_y(n) = D(3) - obj.LiveModel.DesignTwiss.etay(ind+1)*1000 ; 
          dfit_z(n) = BEAMLINE{ind}.Coordf(3) ;
        end
        ylim_x=ahan(1).YLim; 
        plot(ahan(1),dfit_z,dfit_x,'Color',F2_common.ColorOrder(2,:));
        hold(ahan(1),'off');
        ahan(1).YLim=ylim_x;
      end
      if plotall
        pl_all=errorbar(ahan(2),z_all,dispy_all,dispy_err_all,'k.');
        hold(ahan(2),'on');
      end
      pl=errorbar(ahan(2),z,dispy,dispy_err,'.','Color',F2_common.ColorOrder(2,:));
      grid(ahan(2),'on'); xlabel(ahan(2),'Z [m]'); ylabel(ahan(2),'\Delta\eta_y [mm]');
      pl.DataTipTemplate.DataTipRows(1).Label = 'Linac Z (m)' ;
      pl.DataTipTemplate.DataTipRows(2).Label = '\Delta\eta_y (mm)' ;
      pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',cellstr(names));
      if plotall
        pl_all.DataTipTemplate.DataTipRows(1).Label = 'Linac Z (m)' ;
        pl_all.DataTipTemplate.DataTipRows(2).Label = '\Delta\eta_y (mm)' ;
        pl_all.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',cellstr(names_all));
      end
      if showmodel
        ylim_y=ahan(2).YLim;
        hold(ahan(2),'on');
        plot(ahan(2),dfit_z,dfit_y,'Color',F2_common.ColorOrder(2,:));
        hold(ahan(2),'off');
        ahan(2).YLim=ylim_y;
      end
      if plotall
        ahan(1).XLim=[min([z(:); z_all(:)]) max([z(:); z_all(:)])];
        ahan(2).XLim=[min([z(:); z_all(:)]) max([z(:); z_all(:)])];
      else
        ahan(1).XLim=[min(z) max(z)];
        ahan(2).XLim=[min(z) max(z)];
      end
      % Show corrector device locations?
      if showcors
        % Get correction devices in range
        obj.LM.ModelClasses=["QUAD" "SEXT"];
        corsel = find(ismember(obj.DispDevices,obj.LM.ModelNames)) ;
        if ~isempty(corsel)
          corele = find(ismember(obj.LM.ModelNames,obj.DispDevices)) ;
          hold(ahan(1),'on');
          hold(ahan(2),'on');
          for ic=1:length(corsel)
            if obj.DispDeviceType(corsel(ic))==1 || obj.DispDeviceType(corsel(ic))>2
              line(ahan(1),ones(1,2).*obj.LM.ModelZ(corele(ic)),ahan(1).YLim,'LineStyle','-','Color','black','LineWidth',2);
            end
            if obj.DispDeviceType(corsel(ic))==2 || obj.DispDeviceType(corsel(ic))>2
              line(ahan(2),ones(1,2).*obj.LM.ModelZ(corele(ic)),ahan(2).YLim,'LineStyle','-','Color','black','LineWidth',2);
            end
          end
          hold(ahan(1),'off');
          hold(ahan(2),'off');
        end
      end
      % Plot magnet bar
      F2_common.AddMagnetPlotZ(obj.LM.istart,obj.LM.iend,ahan(1)) ;
      F2_common.AddMagnetPlotZ(obj.LM.istart,obj.LM.iend,ahan(2)) ;
      
      % Logbook plot
      if ~isempty(obj.aobj) && obj.aobj.logplot
        obj.aobj.logplot=false;
        rnames = ["INJ";"L0";"DL1";"L1";"BC11";"L2";"BC14";"L3";"BC20";"FFS";"SPECTDUMP"] ;
        rnames=rnames(obj.UseRegion);
        txt = "Dispersion measurement for region(s): " + sprintf("%s ",rnames) + "\n" + "----\n" ;
        txt = txt + "Dispersion fit @ " + string(BEAMLINE{obj.fitele}.Name) + " :\n" ;
        txt = txt + "DX = " + DX(1) + " (mm)\n" ;
        txt = txt + "DPX = " + DX(2) + " (mrad)\n" ;
        txt = txt + "DY = " + DX(3) + " (mm)\n" ;
        txt = txt + "DPY = " + DX(4) + " (mrad)" ;
        util_printLog2020(fhan, 'title',sprintf('Dispersion Plot (config=%s)',obj.ConfigName),'author','F2_Orbit.m','text',char(sprintf(txt)));
        delete(fhan);
      end
      
    end
    function plotmia(obj,nmode,cmd,ahan)
      global BEAMLINE
      if ~exist('ahan','var') || isempty(ahan)
        figure;
        ahan(1)=subplot(2,1,1);
        ahan(2)=subplot(2,1,2);
      else
        ahan(1).reset; ahan(2).reset;
      end
      dat = obj.svdanal(nmode) ;
      nmode=min([nmode length(dat.svals)]);
      switch string(cmd)
        case "SingularValues"
          semilogy(ahan(1),1:nmode,dat.svals(1:nmode,1)); xlabel(ahan(1),'H Mode #'); ylabel(ahan(1),'X Mode Amplitude'); grid(ahan(1),'on');
          semilogy(ahan(2),1:nmode,dat.svals(1:nmode,2)); xlabel(ahan(2),'V Mode #'); ylabel(ahan(2),'Y Mode Amplitude'); grid(ahan(2),'on');
        case "EigenValue"
          t = double(1:obj.BPMS.nread)./ double(obj.BPMS.beamrate) ;
          val = dat.xd*dat.Vtx(nmode,:)' ;
          pl=plot(ahan(1),t,val); xlabel(ahan(1),'t [sec]'); ylabel(ahan(1),'X Mode Amplitude'); grid(ahan(1),'on');
          pl.DataTipTemplate.DataTipRows(1).Label = 'time (s)' ;
          pl.DataTipTemplate.DataTipRows(2).Label = 'X Mode Amp' ;
          val=dat.yd*dat.Vty(nmode,:)';
          pl=plot(ahan(2),t,val); xlabel(ahan(2),'t [sec]'); ylabel(ahan(2),'X Mode Amplitude'); grid(ahan(2),'on');
          pl.DataTipTemplate.DataTipRows(1).Label = 'time (s)' ;
          pl.DataTipTemplate.DataTipRows(2).Label = 'Y Mode Amp' ;
        case "EigenVector"
          id=ismember(obj.BPMS.modelID,obj.bpmid(obj.usebpm));
          z=arrayfun(@(x) BEAMLINE{x}.Coordi(x),obj.BPMS.modelID(id));
          pl=plot(ahan(1),z,dat.Vtx(nmode,id)); xlabel(ahan(1),'Z [m]'); ylabel(ahan(1),'X Eigenvector Amplitude');
          pl.DataTipTemplate.DataTipRows(1).Label = 'Linac Z (m)' ;
          pl.DataTipTemplate.DataTipRows(2).Label = 'X Mode Amp' ;
          pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',obj.BPMS.modelnames(id));
          pl=plot(ahan(2),z,dat.Vty(nmode,id)); xlabel(ahan(2),'Z [m]'); ylabel(ahan(2),'Y Eigenvector Amplitude');
          pl.DataTipTemplate.DataTipRows(1).Label = 'Linac Z (m)' ;
          pl.DataTipTemplate.DataTipRows(2).Label = 'Y Mode Amp' ;
          pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',obj.BPMS.modelnames(id));
        case "FFT"
          [freq_x,fft_x,freq_y,fft_y]=obj.svdfft(nmode);
          plot(ahan(1),freq_x,fft_x); xlabel(ahan(1),'f [Hz]'); ylabel(ahan(1),'|P1(f)| (X Mode)'); grid(ahan(1),'on');
          plot(ahan(2),freq_y,fft_y); xlabel(ahan(2),'f [Hz]'); ylabel(ahan(2),'|P1(f)| (Y Mode)'); grid(ahan(2),'on');
        case "DoF"
          id=ismember(obj.BPMS.modelID,obj.bpmid(obj.usebpm));
          z=obj.BPMS.modelZ;
          pl=plot(ahan(1),z,dat.dof{1}(id,1:nmode)); xlabel(ahan(1),'Z [m]'); grid(ahan(1),'on'); ylabel(ahan(1),'');
          pl.DataTipTemplate.DataTipRows(1).Label = 'Linac Z (m)' ;
          pl.DataTipTemplate.DataTipRows(2).Label = 'X Mode Amp' ;
          pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',obj.BPMS.modelnames(id));
          pl=plot(ahan(2),z,dat.dof{2}(id,1:nmode)); xlabel(ahan(2),'Z [m]'); grid(ahan(2),'on'); ylabel(ahan(2),'');
          pl.DataTipTemplate.DataTipRows(1).Label = 'Linac Z (m)' ;
          pl.DataTipTemplate.DataTipRows(2).Label = 'Y Mode Amp' ;
          pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',obj.BPMS.modelnames(id));
        case "KickAnalysis"
          id=ismember(obj.BPMS.modelID,obj.bpmid(obj.usebpm));
          z=obj.BPMS.modelZ;
          if length(id)<3
            return
          end
          gx = dat.xd*dat.Vtx(nmode,id)' ;
          gy = dat.yd*dat.Vty(nmode,id)' ;
          kickx = zeros(1,length(id)); kicky=kickx;
          for ibpm=3:length(id)
            a = gx(ibpm-2); b = gx(ibpm-1); c=gx(ibpm);
            [~,R]=RmatAtoB(id(ibpm-2),id(ibpm-1)); r11_12=R(1,1); r12_12=R(1,2); r33_12=R(3,3); r34_12=R(3,4);
            alpha = (b-a*r11_12)/r12_12 ;
            [~,R]=RmatAtoB(id(ibpm-2),id(ibpm)); r11_13=R(1,1); r12_13=R(1,2); r33_13=R(3,3); r34_13=R(3,4);
            c_pred = a*r11_13+alpha*r12_13;
            kickx(ibpm) = (c-c_pred)/c_pred;
            a = gy(ibpm-2); b = gy(ibpm-1); c=gy(ibpm);
            alpha = (b-a*r33_12)/r34_12 ;
            c_pred = a*r33_13+alpha*r34_13;
            kicky(ibpm) = (c-c_pred)/c_pred;
          end
          pl=plot(ahan(1),z,kickx); xlabel(ahan(1),'Z [m]'); ylabel(ahan(1),''); grid(ahan(1),'on');
          pl.DataTipTemplate.DataTipRows(1).Label = 'Linac Z (m)' ;
          pl.DataTipTemplate.DataTipRows(2).Label = 'X Kick' ;
          pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',obj.BPMS.modelnames(id));
          pl=plot(ahan(2),z,kicky); xlabel(ahan(2),'Z [m]'); ylabel(ahan(2),''); grid(ahan(2),'on');
          pl.DataTipTemplate.DataTipRows(1).Label = 'Linac Z (m)' ;
          pl.DataTipTemplate.DataTipRows(2).Label = 'Y Kick' ;
          pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',obj.BPMS.modelnames(id));
      end
    end
    function plotcor(obj,ahan,showmax,unitsBDES)
      %PLOTCOR Plot corrector values and propose new corrector values
      %plotcor([axisHandle_x axisHandle_y],showmax,unitsBDES)
      global BEAMLINE
      
      if isempty(obj.cordat_x)
        return
      end
      
      % Get scale factor for units (mrad or BDES)
      id = obj.xcorid(obj.usexcor) ;
      P = arrayfun(@(x) BEAMLINE{x}.P,id) ;
      if unitsBDES
        xsca = obj.LM.GEV2KGM.*P(:) ;
        xuni='kGm';
      else
        xsca = ones(size(P)).*1e3;
        xuni='mrad';
      end
      id = obj.ycorid(obj.useycor) ;
      P = arrayfun(@(x) BEAMLINE{x}.P,id) ;
      if unitsBDES
        ysca = obj.LM.GEV2KGM.*P(:) ;
        yuni='kGm';
      else
        ysca = ones(size(P)).*1e3;
        yuni='mrad';
      end
      
      % Make new axes if generating plot for logbook
      if ~exist('ahan','var') || isempty(ahan) || obj.aobj.logplot
        fhan=figure;
        sp1=subplot(2,1,1,'Parent',fhan);
        sp2=subplot(2,1,2,'Parent',fhan);
        ahan=[sp1 sp2];
      else
        ahan(1).reset; ahan(2).reset; cla(ahan(1)); cla(ahan(2)); drawnow;
      end
      
      % Plot extant corrector kick values
      pl=plot(ahan(1),obj.cordat_x.z(obj.usexcor),obj.cordat_x.theta(obj.usexcor).*xsca,'.','Color',F2_common.ColorOrder(1,:),'MarkerSize',10);
      pl.DataTipTemplate.DataTipRows(1).Label = 'Linac Z' ;
      pl.DataTipTemplate.DataTipRows(2).Label = sprintf('X Kick (%s)',xuni) ;
      pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',obj.xcornames(obj.usexcor));
      pl=plot(ahan(2),obj.cordat_y.z(obj.useycor),obj.cordat_y.theta(obj.useycor).*ysca,'.','Color',F2_common.ColorOrder(1,:),'MarkerSize',10);
      pl.DataTipTemplate.DataTipRows(1).Label = 'Linac Z' ;
      pl.DataTipTemplate.DataTipRows(2).Label = sprintf('Y Kick (%s)',yuni) ;
      pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',obj.ycornames(obj.useycor));
      grid(ahan(1),'on');
      grid(ahan(2),'on');
      ylabel(ahan(1),sprintf('XCOR \\theta_x [%s]',xuni));
      xlabel(ahan(2),'Z [m]'); ylabel(ahan(2),sprintf('YCOR \\theta_y [%s]',yuni));
      ahan(1).XLim=[min(obj.cordat_x.z(obj.usexcor)) max(obj.cordat_x.z(obj.usexcor))];
      ahan(2).XLim=[min(obj.cordat_y.z(obj.useycor)) max(obj.cordat_y.z(obj.useycor))];
      
      % If calculated, superimpose new kick values proposed
      if obj.calcperformed
        newtheta_x = obj.cordat_x.theta(obj.usexcor)+obj.dtheta_x(obj.usexcor) ;
        newtheta_y = obj.cordat_y.theta(obj.useycor)+obj.dtheta_y(obj.useycor) ;
        zv_x = obj.cordat_x.z(obj.usexcor); zv_y = obj.cordat_y.z(obj.useycor) ;
        hold(ahan(1),'on');
        i_p = obj.dtheta_x(obj.usexcor)>=0 ;
        i_m = obj.dtheta_x(obj.usexcor)<0 ;
        if any(i_p)
          pl_p=plot(ahan(1),zv_x(i_p),newtheta_x(i_p).*xsca(i_p),'^','Color',F2_common.ColorOrder(1,:),'MarkerSize',4);
        end
        if any(i_m)
          pl_m=plot(ahan(1),zv_x(i_m),newtheta_x(i_m).*xsca(i_m),'v','Color',F2_common.ColorOrder(1,:),'MarkerSize',4);
        end
        n=0;
        for icor=find(obj.usexcor)'
          n=n+1;
          y1 = obj.cordat_x.theta(icor).*xsca(n) ; y2 = newtheta_x(n).*xsca(n) ;
          line(ahan(1),ones(1,2).*obj.cordat_x.z(icor),[y1 y2],'Color',F2_common.ColorOrder(1,:));
        end
        if any(i_p)
          pl_p.DataTipTemplate.DataTipRows(1).Label = 'Linac Z' ;
          pl_p.DataTipTemplate.DataTipRows(2).Label = sprintf('X Kick (%s)',xuni) ;
          pl_p.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',cellstr(obj.xcornames(i_p)));
        end
        if any(i_m)
          pl_m.DataTipTemplate.DataTipRows(1).Label = 'Linac Z' ;
          pl_m.DataTipTemplate.DataTipRows(2).Label = sprintf('X Kick (%s)',yuni) ;
          pl_m.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',cellstr(obj.xcornames(i_m)));
        end
        hold(ahan(1),'off');
        hold(ahan(2),'on');
        i_p = obj.dtheta_y(obj.useycor)'>=0 ;
        i_m = obj.dtheta_y(obj.useycor)'<0 ;
        if any(i_p)
          pl_p=plot(ahan(2),zv_y(i_p),newtheta_y(i_p).*ysca(i_p),'^','Color',F2_common.ColorOrder(1,:),'MarkerSize',4);
        end
        if any(i_m)
          pl_m=plot(ahan(2),zv_y(i_m),newtheta_y(i_m).*ysca(i_m),'v','Color',F2_common.ColorOrder(1,:),'MarkerSize',4);
        end
        n=0;
        for icor=find(obj.useycor)'
          n=n+1;
          y1 = obj.cordat_y.theta(icor).*ysca(n) ; y2 = newtheta_y(n).*ysca(n) ;
          line(ahan(2),ones(1,2).*obj.cordat_y.z(icor),[y1 y2],'Color',F2_common.ColorOrder(1,:));
        end
        if any(i_p)
          pl_p.DataTipTemplate.DataTipRows(1).Label = 'Linac Z' ;
          pl_p.DataTipTemplate.DataTipRows(2).Label = sprintf('Y Kick (%s)',xuni) ;
          pl_p.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',cellstr(obj.ycornames(i_p)));
        end
        if any(i_m)
          pl_m.DataTipTemplate.DataTipRows(1).Label = 'Linac Z' ;
          pl_m.DataTipTemplate.DataTipRows(2).Label = sprintf('Y Kick (%s)',yuni) ;
          pl_m.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',cellstr(obj.ycornames(i_m)));
        end
        hold(ahan(2),'off');
        % Make it so data points are on top layer and data tips show
        ahan(1).Children=flip(ahan(1).Children);
        ahan(2).Children=flip(ahan(2).Children);
      end
      
      % Plot min/max values
      if showmax
        hold(ahan(1),'on');
        plot(ahan(1),obj.cordat_x.z(obj.usexcor),obj.cordat_x.thetamax(obj.usexcor).*xsca,'k--');
        plot(ahan(1),obj.cordat_x.z(obj.usexcor),-obj.cordat_x.thetamax(obj.usexcor).*xsca,'k--');
        hold(ahan(1),'off');
        hold(ahan(2),'on');
        plot(ahan(2),obj.cordat_y.z(obj.useycor),obj.cordat_y.thetamax(obj.useycor).*ysca,'k--');
        plot(ahan(2),obj.cordat_y.z(obj.useycor),-obj.cordat_y.thetamax(obj.useycor).*ysca,'k--');
        hold(ahan(2),'off');
      end
      
      % Magnet bar
      F2_common.AddMagnetPlotZ(obj.LM.istart,obj.LM.iend,ahan(1)) ;
      F2_common.AddMagnetPlotZ(obj.LM.istart,obj.LM.iend,ahan(2)) ;
      
      % Logbook plot
      if ~isempty(obj.aobj) && obj.aobj.logplot
        obj.aobj.logplot=false;
        rnames = ["INJ";"L0";"DL1";"L1";"BC11";"L2";"BC14";"L3";"BC20";"FFS";"SPECTDUMP"] ;
        rnames=rnames(obj.UseRegion);
        txt = "Corrector values for region(s): " + sprintf("%s ",rnames) + "\n" + "----\n" ;
        util_printLog2020(fhan, 'title',sprintf('Corrector Plot (config=%s)',obj.ConfigName),'author','F2_Orbit.m','text',char(sprintf(txt)));
        delete(fhan);
      end
      
    end
    function plotbpm(obj,ahan,showmodel,showcors,plotall)
      %PLOTBPM Plot BPM averaged orbit
      %plotbpm()
      %  Plot on new figure window
      %plotbpm([axisHandle1 , axisHandle2])
      %  Plot on provided axis handles (for [x y])
      %   -- set x or y = 0 to ignore plotting in that plane
      global BEAMLINE
      if isempty(obj.BPMS.xdat)
        error('No data to plot')
      end
      if ~exist('showmodel','var')
        showmodel=false;
      end
      if ~exist('showcors','var')
        showcors=false;
      end
      if ~exist('plotall','var')
        plotall=false;
      end
      
      % Get orbit data
      [xm,ym,xstd,ystd,use,id] = obj.GetOrbit ;
      betades_x = obj.LM.DesignTwiss.betax(id); betades_y = obj.LM.DesignTwiss.betay(id);
      P = obj.LM.DesignTwiss.P(id); gamma = P./0.511e-3; emit = 5e-6 ./ gamma ;
      if plotall
        [xm_all,ym_all,xstd_all,ystd_all,use_all,id_all] = obj.GetOrbit("all") ;
        P = obj.LM.DesignTwiss.P(id_all); gamma = P./0.511e-3; emit_all = 5e-6 ./ gamma ;
        z_all = arrayfun(@(x) BEAMLINE{x}.Coordi(3),id_all) ;
        betades_xall = obj.LM.DesignTwiss.betax(id_all); betades_yall = obj.LM.DesignTwiss.betay(id_all);
      end
      
      if ~any(use)
        error('No Data to plot');
      end
      if ~exist('ahan','var') || isempty(ahan) || (~isempty(obj.aobj) && obj.aobj.logplot)
        fhan=figure;
        sp1=subplot(2,1,1,'Parent',fhan);
        sp2=subplot(2,1,2,'Parent',fhan);
        ahan=[sp1 sp2];
      else
        if isa(ahan(1),'matlab.ui.control.UIAxes') || isa(ahan(1),'matlab.graphics.axis.Axes')
          ahan(1).reset;
        end
        if isa(ahan(2),'matlab.ui.control.UIAxes') || isa(ahan(2),'matlab.graphics.axis.Axes')
          ahan(2).reset;
        end
      end
      if isa(ahan(1),'matlab.ui.control.UIAxes') || isa(ahan(1),'matlab.graphics.axis.Axes')
        xax=ahan(1);
      else
        xax=[];
      end
      if isa(ahan(2),'matlab.ui.control.UIAxes') || isa(ahan(2),'matlab.graphics.axis.Axes')
        yax=ahan(2);
      else
        yax=[];
      end
      
      obj.LM.ModelClasses="MONI";
      
      z = arrayfun(@(x) BEAMLINE{x}.Coordi(3),id) ;
      
      if ~isempty(xax)
        if obj.dormsplot
          if plotall
            pl_all=plot(xax,z_all,(xstd_all(:).*1e-3)./sqrt(emit_all(:).*betades_xall(:)),'k.');
            hold(xax,'on');
          end
          pl=plot(xax,z,(xstd(:).*1e-3)./sqrt(emit(:).*betades_x(:)),'*','Color',F2_common.ColorOrder(2,:));
          ylabel(xax,'<X^2>^{1/2}/\sigma_x');
        else
          if plotall
            pl_all=errorbar(xax,z_all,xm_all,xstd_all,'k.');
            hold(xax,'on');
          end
          pl=errorbar(xax,z,xm,xstd,'.','MarkerFaceColor',F2_common.ColorOrder(2,:));
          ylabel(xax,'X [mm]');
        end
        if plotall
          zmin=z_all(1); zmax=z_all(end);
        else
          zmin=z(1); zmax=z(end);
        end

        pl.DataTipTemplate.DataTipRows(1).Label = 'Linac Z' ;
        pl.DataTipTemplate.DataTipRows(2).Label = '<X>' ;
        pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('RMS-X',xstd);
        pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',obj.bpmnames(use));
        if plotall
          pl_all.DataTipTemplate.DataTipRows(1).Label = 'Linac Z' ;
          pl_all.DataTipTemplate.DataTipRows(2).Label = '<X>' ;
          pl_all.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('RMS-X',xstd_all);
          pl_all.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',obj.bpmnames(use_all));
        end
        grid(xax,'on');
        if obj.BPMS.plotscale>0
          xax.YLim=[-double(obj.BPMS.plotscale) double(obj.BPMS.plotscale)];
        else
          xax.YLimMode="auto";
        end
      end
      if ~isempty(yax)
        if obj.dormsplot
          if plotall
            pl_all=plot(yax,z_all,(ystd_all(:).*1e-3)./sqrt(emit_all(:).*betades_yall(:)),'k*');
            hold(yax,'on');
          end
          pl=plot(yax,z,(ystd(:).*1e-3)./sqrt(emit(:).*betades_y(:)),'*','Color',F2_common.ColorOrder(2,:));
          ylabel(yax,'<Y^2>^{1/2}/\sigma_y');
        else
          if plotall
            pl_all=errorbar(yax,z_all,ym_all,ystd_all,'k.');
            hold(yax,'on');
          end
          pl=errorbar(yax,z,ym,ystd,'.','MarkerFaceColor',F2_common.ColorOrder(2,:));
          xlabel(yax,'Z [m]'); ylabel(yax,'Y [mm]');
          ylabel(yax,'Y [mm]');
        end
        if plotall
          zmin=min([zmin z_all(1)]); zmax=max([zmax z_all(end)]);
        else
          zmin=min([zmin z(1)]); zmax=max([zmax z(end)]);
        end
        pl.DataTipTemplate.DataTipRows(1).Label = 'Linac Z' ;
        pl.DataTipTemplate.DataTipRows(2).Label = '<Y>' ;
        pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('RMS-Y',ystd);
        pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',obj.bpmnames(use));
        if plotall
          pl_all.DataTipTemplate.DataTipRows(1).Label = 'Linac Z' ;
          pl_all.DataTipTemplate.DataTipRows(2).Label = '<Y>' ;
          pl_all.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('RMS-Y',ystd_all);
          pl_all.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',obj.bpmnames(use_all));
        end
        grid(yax,'on');
        if obj.BPMS.plotscale>0
          yax.YLim=[-double(obj.BPMS.plotscale) double(obj.BPMS.plotscale)];
        else
          yax.YLimMode="auto";
        end
      end
      % Show corrector locations?
      if showcors
        if ~isempty(xax)
          hold(xax,'on');
          for icor=find(obj.usexcor(:)')
            line(xax,[obj.cordat_x.z(icor) obj.cordat_x.z(icor)],xax.YLim,'LineStyle','-','Color','black','LineWidth',2);
          end
          zmin=min([zmin min(obj.cordat_x.z(icor))]); zmax=max([zmax max(obj.cordat_x.z(icor))]);
          hold(xax,'off');
        end
        if ~isempty(yax)
          hold(yax,'on');
          for icor=find(obj.useycor(:)')
            line(yax,[obj.cordat_y.z(icor) obj.cordat_y.z(icor)],yax.YLim,'LineStyle','-','Color','black','LineWidth',2);
          end
          zmin=min([zmin min(obj.cordat_y.z(icor))]); zmax=max([zmax max(obj.cordat_y.z(icor))]);
          hold(yax,'off');
        end
      end
      % If orbit correction calcs performed, superimpose solution
      if obj.calcperformed
        if ~isempty(xax)
          hold(xax,'on');
          xc=obj.xbpm_cor(obj.usebpm);
          if plotall
            plot(xax,z_all,obj.xbpm_cor(use_all),'Color','k');
          end
          plot(xax,z,xc,'Color',F2_common.ColorOrder(2,:));
          hold(xax,'off');
        end
        if ~isempty(yax)
          hold(yax,'on');
          yc=obj.ybpm_cor(obj.usebpm);
          plot(yax,z,yc,'Color',F2_common.ColorOrder(2,:));
          if plotall
            plot(yax,z_all,obj.ybpm_cor(use_all),'Color','k');
          end
          hold(yax,'off');
        end
      end
      % Superimpose model fit if requested
      X0 = obj.orbitfit(); % X0 is orbit at region start
      X0(1:4)=X0(1:4).*1e-3;
      if showmodel
        if plotall
          idf=obj.regid(1):obj.regid(2);
          i0m=obj.regid(1);
          nele = length(idf) ;
          x_fit=zeros(1,nele); y_fit=zeros(1,nele);
          x_fit(1)=X0(1); y_fit(1)=X0(3);
          for n=1:nele
            if i0m==idf(n)
              [~,R] = RmatAtoB(i0m,idf(n)) ;
            else
              [~,R] = RmatAtoB(i0m,idf(n)-1) ;
            end
            Xf = R([1:4 6],[1:4 6]) * X0 ;
            x_fit(n) = Xf(1); y_fit(n) = Xf(3) ;
          end
          zi=arrayfun(@(x) BEAMLINE{x}.Coordi(3),idf);
          if ~isempty(xax)
            ylim_x=xax.YLim;
            hold(xax,'on');
            plot(xax,zi,x_fit.*1e3,'Color','k');
            hold(xax,'off');
            xax.YLim=ylim_x;
          end
          if ~isempty(yax)
            ylim_y=yax.YLim;
            hold(yax,'on');
            plot(yax,zi,y_fit.*1e3,'Color','k');
            hold(yax,'off');
            yax.YLim=ylim_y;
          end
        end
        idf=id(1):id(end);
        i0m=obj.regid(1);
        nele = length(idf) ;
        x_fit=zeros(1,nele); y_fit=zeros(1,nele);
        x_fit(1)=X0(1); y_fit(1)=X0(3);
        for n=1:nele
          if i0m==idf(n)
            [~,R] = RmatAtoB(i0m,idf(n)) ;
          else
            [~,R] = RmatAtoB(i0m,idf(n)-1) ;
          end
          Xf = R([1:4 6],[1:4 6]) * X0 ;
          x_fit(n) = Xf(1); y_fit(n) = Xf(3) ;
        end
        zi=arrayfun(@(x) BEAMLINE{x}.Coordi(3),idf);
        if ~isempty(xax)
          hold(xax,'on');
          plot(xax,zi,x_fit.*1e3,'Color',F2_common.ColorOrder(2,:));
          hold(xax,'off');
        end
        if ~isempty(yax)
          hold(yax,'on');
          plot(yax,zi,y_fit.*1e3,'Color',F2_common.ColorOrder(2,:));
          hold(yax,'off');
        end
      end
      % Plot magnet bar
      if ~isempty(xax)
        F2_common.AddMagnetPlotZ(obj.LM.istart,obj.LM.iend,xax) ;
        xax.XLim=[zmin zmax];
      end
      if ~isempty(yax)
        F2_common.AddMagnetPlotZ(obj.LM.istart,obj.LM.iend,yax) ;
        yax.XLim=[zmin zmax];
      end
      
      % Logbook plot
      if ~isempty(obj.aobj) && obj.aobj.logplot
        obj.aobj.logplot=false;
        rnames = ["INJ";"L0";"DL1";"L1";"BC11";"L2";"BC14";"L3";"BC20";"FFS";"SPECTDUMP"] ;
        rnames=rnames(obj.UseRegion);
        txt = "Orbit for region(s): " + sprintf("%s ",rnames) + "\n" + "----\n" ;
        txt = txt + "Orbit fit @ " + string(BEAMLINE{obj.fitele}.Name) + " :\n" ;
        txt = txt + "X = " + obj.OrbitFit(1) + " (mm)\n" ;
        txt = txt + "XANG = " + obj.OrbitFit(2) + " (mrad)\n" ;
        txt = txt + "Y = " + obj.OrbitFit(3) + " (mm)\n" ;
        txt = txt + "YANG = " + obj.OrbitFit(4) + " (mrad)\n" ;
        txt = txt + "dE = " + (obj.OrbitFit(5)*BEAMLINE{obj.fitele}.P*1000) + " (MeV)" ;
        util_printLog2020(fhan, 'title',sprintf('Orbit Plot (config=%s)',obj.ConfigName),'author','F2_Orbit.m','text',char(sprintf(txt)));
        delete(fhan);
      end
    end
    % --- 
  end
  %set/get
  methods
    function set.UseRegion(obj,val)
      obj.UseRegion=val;
      obj.LM.UseRegion=val;
      obj.usebpm = false(size(obj.bpmid)) ;
      obj.usexcor = false(size(obj.xcorid)) ;
      obj.useycor = false(size(obj.ycorid)) ;
      obj.LM.ModelClasses="MONI";
      obj.usebpm=false(size(obj.usebpm));
      obj.usebpm(~obj.badbpms & ismember(obj.bpmid,obj.LM.ModelID)) = true ;
      obj.usebpm(~ismember(obj.bpmid,obj.BPMS.modelID))=false;
      obj.useregbpm = obj.usebpm ;
      obj.LM.ModelClasses="XCOR";
      obj.usexcor(~obj.badxcors & ismember(obj.xcorid,obj.LM.ModelID)) = true ;
      obj.LM.ModelClasses="YCOR";
      obj.useycor(~obj.badycors & ismember(obj.ycorid,obj.LM.ModelID)) = true ;
      obj.calcperformed=false;
      obj.fitele=obj.LM.iend;
      obj.regid=[double(obj.LM.istart) double(obj.LM.iend)];
    end
    function set.calcperformed(obj,val)
      if ~isempty(obj.aobj)
        if val
          obj.aobj.DoCorrectionButton.Enable=true;
        else
          obj.aobj.DoCorrectionButton.Enable=false;
        end
      end
      obj.calcperformed=val;
    end
    function orb = get.RefOrbit(obj)
      %orb = [ID,X,Y]
      switch obj.UseRefOrbit
        case "none"
          orb=[];
        case "local"
          orb = [obj.RefOrbitLocal{2} obj.RefOrbitLocal{3} obj.RefOrbitLocal{4}];
        case "config"
          orb = [obj.RefOrbitConfig{2} obj.RefOrbitConfig{3} obj.RefOrbitConfig{4}];
      end
    end
    function dt = get.RefOrbitDate(obj)
      switch obj.UseRefOrbit
        case "none"
          dt=[];
        case "local"
          dt = obj.RefOrbitLocal{1} ;
        case "config"
          dt = obj.RefOrbitConfig{1} ;
      end
    end
    function names = get.Configs(obj)
      d = dir(obj.OrbitConfigDir+"/conf_*") ;
      names = regexprep(string({d.name}),["conf_" "\.mat"],"") ;
    end
    function dates = get.ConfigsDate(obj)
      d = dir(obj.OrbitConfigDir+"/conf_*") ;
      dates = datenum({d.date}) ;
    end
  end
  methods(Hidden)
    function ProcModelUpdate(obj)
      if ~isempty(obj.aobj)
        obj.aobj.updateplots;
      end
    end
  end
  methods(Static,Hidden)
    function EscanStatPlot(axtop,axbot,evals_s,cmd,cmd2,txt)
      %ESCANSTATPLOT Status display for energy scan
      if ~exist('cmd','var')
        cmd=[0 0];
        cmd2={0 0};
      end
      axtop.reset; cla(axtop);
      axbot.reset; cla(axbot);
      ntop = floor(length(evals_s)/2) ;
      nbot = length(evals_s)-ntop ;
      axis(axtop,'off'); axis(axbot,'off');
      xtop=linspace(0,1,ntop+1); xbot=linspace(0,1,nbot+1);
      for ipl=1:ntop
        if cmd(1)==ipl
          rectangle(axtop,'Position',[xtop(ipl) 0 1/ntop 1],'FaceColor', [0.4660 0.6740 0.1880],'EdgeColor','r','LineWidth',2);
          text(axtop,(ipl-1)*1/ntop+(1/ntop)*0.3,0.5,sprintf('\\DeltaE = %.1f MeV',evals_s(ipl)));
          text(axtop,(ipl-1)*1/ntop+(1/ntop)*0.3,0.4,txt);
        else
          if ismember(ipl,cmd2{1})
            rectangle(axtop,'Position',[xtop(ipl) 0 1/ntop 1],'FaceColor', [0.4660 0.6740 0.1880]);
          else
            rectangle(axtop,'Position',[xtop(ipl) 0 1/ntop 1]);
          end
          text(axtop,(ipl-1)*1/ntop+(1/ntop)*0.3,0.5,sprintf('\\DeltaE = %.1f MeV',evals_s(ipl)));
        end
      end
      for ipl=1:nbot
        if cmd(2)==ipl
          rectangle(axbot,'Position',[xbot(ipl) 0 1/nbot 1],'FaceColor', [0.4660 0.6740 0.1880],'EdgeColor','r','LineWidth',2);
          text(axbot,(ipl-1)*1/nbot+(1/nbot)*0.3,0.5,sprintf('\\DeltaE = %.1f MeV',evals_s(ntop+ipl)));
          text(axbot,(ipl-1)*1/nbot+(1/nbot)*0.3,0.4,txt);
        else
          if ismember(ipl,cmd2{2})
            rectangle(axbot,'Position',[xbot(ipl) 0 1/nbot 1],'FaceColor', [0.4660 0.6740 0.1880]);
          else
            rectangle(axbot,'Position',[xbot(ipl) 0 1/nbot 1]);
          end
          text(axbot,(ipl-1)*1/nbot+(1/nbot)*0.3,0.5,sprintf('\\DeltaE = %.1f MeV',evals_s(ntop+ipl)));
        end
      end
      drawnow;
    end
  end
end
