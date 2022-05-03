classdef F2_OrbitApp < handle & F2_common & matlab.mixin.Copyable
  properties
    bpmid uint16 % Master list of BPM IDs
    xcorid uint16 % Master list of x corrector IDs
    ycorid uint16 % Master list of y corrector IDs
    usebpm logical % Selection (from master list) of BPMs to use
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
    CorrectionOffset(4,1) = [0; 0; 0; 0;] % Desired correction offset when using domodelfit
    npulse {mustBePositive} = 50 % default/GUI value for number of pulses of BPM data to take
    orbitfitmethod string {mustBeMember(orbitfitmethod,["lscov","backslash"])} = "lscov"
    escandev string {mustBeMember(escandev,["S20_ENERGY_3AND4","S20_ENERGY_4AND5","S20_ENERGY_4AND6","BC14_ENERGY_4AND5","BC14_ENERGY_5AND6","BC14_ENERGY_4AND6","BC11_ENERGY","DL10_ENERGY"])} = "DL10_ENERGY"
    escanrange(2,8) = [-50 -50 -50 -30 -30 -30 -30 -30; 50 50 50 30 30 30 30 30] % MeV
    nescan(1,8) = ones(1,8).*10 % Number of energy scan steps to use
  end
  properties(Transient)
    BPMS % Storage for F2_bpms object
    aobj % Storage for GUI application object
    LM % LucretiaModel object
    LiveModel % LiveModel object
  end
  properties(SetAccess=private)
    cordat_x % XCOR data
    cordat_y % YCOR data
    dtheta_x % calculated x corrector kicks (rad)
    dtheta_y % calculated y corrector kicks (rad)
    xbpm_cor % calculated corrected x bpm vals (mm)
    ybpm_cor % calculated corrected y bpm vals (mm)
    ebpms_disp(1,5) % dispersion at energy BPMS in mm
    DispData % Dispersion data calculated with svddisp method (mm)
    DispFit % Fitted [dispersion_x; dispersion_y] at each BPM in selected region calculated with plotdisp method
    DispCorData % fitted dispersion correction device settings
    DispCorVals
    ConfigName string = "none"
    ConfigDate
    escandata cell % Storage for energy scan data
  end
  properties(SetAccess=private,Hidden)
    bdesx_restore % bdes values store when written for undo function
    bdesy_restore % bdes values store when written for undo function
    RefOrbitConfig % {date,id,xref,yref}
    RefOrbitLocal % {date,id,xref,yref}
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
    DispDevices string = ["QB10731" "CQ11317" "CQ11352" "CQ14738" "CQ14866" "SQ1" "S1EL" "S2EL" "S2ER" "S1ER" "S1EL" "S2EL" "S2ER" "S1ER"]
    DispDeviceType uint8 = [1         1         1         1         1        2      3       3     3     3       4       4     4     4    ] % 1=quad 2=skew quad 3=sext(x) 4=sext(y)
    DispDeviceReadPV = ["QUAD:IN10:731:BDES" "QUAD:LI11:317:BDES" "QUAD:LI11:352:BDES" "QUAD:LI14:738:BDES" "QUAD:LI14:866:BDES" "LI20:QUAD:2086:BDES" ...
      "SIOC:ML00:AO551" "SIOC:ML01:AO501" "SIOC:ML01:AO516" "SIOC:ML01:AO566" "SIOC:ML01:AO556" "SIOC:ML01:AO506" "SIOC:ML01:AO521" "SIOC:ML01:AO571"]
    DispDeviceWritePV = ["QUAD:IN10:731:BCTRL" "QUAD:LI11:317:BCTRL" "QUAD:LI11:352:BCTRL" "QUAD:LI14:738:BCTRL" "QUAD:LI14:866:BCTRL" "QUAD:LI20:2086:BDES" ...
      "SIOC:ML00:AO551" "SIOC:ML01:AO501" "SIOC:ML01:AO516" "SIOC:ML01:AO566" "SIOC:ML01:AO556" "SIOC:ML01:AO506" "SIOC:ML01:AO521" "SIOC:ML01:AO571"]
    DispDeviceWriteProto = ["EPICS" "EPICS" "EPICS" "EPICS" "EPICS" "AIDA" "EPICS" "EPICS" "EPICS" "EPICS" "EPICS" "EPICS" "EPICS" "EPICS"]
    EnergyKnobNames = ["S20_ENERGY_3AND4","S20_ENERGY_4AND5","S20_ENERGY_4AND6","BC14_ENERGY_4AND5","BC14_ENERGY_5AND6","BC14_ENERGY_4AND6","BC11_ENERGY","DL10_ENERGY"]
    EnergyKnobs = {"MKB:S20_ENERGY_3AND4" "MKB:S20_ENERGY_4AND5" "MKB:S20_ENERGY_4AND6" "MKB:BC14_ENERGY_4AND5" "MKB:BC14_ENERGY_5AND6" "MKB:BC14_ENERGY_4AND6" ["KLYS:LI11:11:SSSB_ADES" "KLYS:LI11:21:SSSB_ADES"] "KLYS:LI10:41:SFB_ADES"}
    EnergyKnobsKlys = {["19_3","19_4"] ["19_4","19_5"] ["19_4","19_6"] ["14_4","14_5"] ["14_5","14_6"] ["14_4","14_6"] ["11_1","11_2"] "10_4"} % Klystron stations for each knob
    EnergyKnobsKlys11 = ["KLYS:LI11:11:SSSB_ADES" "KLYS:LI11:21:SSSB_ADES"; "KLYS:LI11:11:SSSB_PDES" "KLYS:LI11:21:SSSB_PDES"] % PVs for stations in 11 [Ampl;Phase]
  end
  methods
    function obj = F2_OrbitApp(appobj)
      global BEAMLINE
      obj.LiveModel = F2_LiveModelApp ;
      obj.BPMS = F2_bpms(obj.LiveModel.LM) ;
      if exist('appobj','var')
        obj.aobj = appobj ;
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
    end
    function acquire(obj,npulse)
      %ACQUIRE Get bpm and corrector data
      %acquire(npulse)
      global BEAMLINE
      % BPM data:
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
        [~,X1] = obj.orbitfit ; X=X1(1:4); X=obj.CorrectionOffset-X(:);
        ixc = double(obj.xcorid(obj.usexcor)) ; nxc=length(ixc);
        iyc = double(obj.ycorid(obj.useycor)) ;
        icor=[ixc(:); iyc(:)];
        R = zeros(4,length(icor));
        for ncor=1:length(icor)
          [~,Rm]=RmatAtoB(icor(ncor),double(obj.fitele-1));
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
    function dispdat = svddisp(obj)
      global BEAMLINE
      % Get energy
      id = find(ismember(obj.BPMS.modelnames,obj.ebpms)&ismember(obj.BPMS.modelnames,obj.bpmnames(obj.usebpm))) ;
      if isempty(id)
        error('BPM selection doesn''t include an energy BPM');
      end
      ide = id(end) ;
      dispx=nan(1,sum(obj.usebpm)); dispy=dispx; dispx_err=dispx; dispy_err=dispx;
      dat = obj.svdresponse(1,ide,10) ; % reconstituted BPM readings using mode most responsive to energy BPM
      xe = dat.xdat(ide,:) ;
      disp = obj.ebpms_disp(ismember(obj.ebpms,obj.BPMS.modelnames(ide)))' ;
      dp =  xe./disp  ; % dP/P @ energy BPMS
      nbpm=find(ismember(obj.BPMS.modelnames,obj.bpmnames(obj.usebpm)));
      for ibpm=1:length(nbpm)
        dp0=dp .* BEAMLINE{obj.BPMS.modelID(ide)}.P / BEAMLINE{obj.BPMS.modelID(nbpm(ibpm))}.P; % assumed dP/P @ BPM location
        gid = ~isnan(obj.BPMS.xdat(nbpm(ibpm),:)) ;
        [q,dq] = noplot_polyfit(dp0(gid),dat.xdat(nbpm(ibpm),gid),1,1) ;
        dispx(ibpm) = q(2) ;
        dispx_err(ibpm) = dq(2) ;
        gid = ~isnan(obj.BPMS.ydat(nbpm(ibpm),:)) ;
        [q,dq] = noplot_polyfit(dp0(gid),dat.ydat(nbpm(ibpm),gid),1,1) ;
        dispy(ibpm) = q(2) ;
        dispy_err(ibpm) = dq(2) ;
      end
      dispdat.ebpm=ide;
      dispdat.usebpm=obj.usebpm;
      dispdat.x=dispx;
      dispdat.xerr=dispx_err;
      dispdat.y=dispy;
      dispdat.yerr=dispy_err;
      obj.DispData = dispdat ;
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
      id=obj.bpmid(dd.usebpm) ;
      ddispx = obj.LiveModel.DesignTwiss.etax(id) ;
      ddispy = obj.LiveModel.DesignTwiss.etay(id) ;
      dispx_err = dd.xerr; dispy_err = dd.yerr ;
      
      % Fit model dispersion response from first BPM in the selection
      A = zeros(length(dd.x)+length(dd.y),4) ; A(1,:) = [1 0 0 0] ; A(length(dd.x)+1,:) = [0 0 1 0] ;
      for ibpm=2:length(id)
        [~,R]=RmatAtoB(double(id(1)),double(id(ibpm)));
        A(ibpm,:) = [R(1,1) R(1,2) R(1,3) R(1,4)];
        A(ibpm+length(dd.x),:) = [R(3,1) R(3,2) R(3,3) R(3,4)];
      end
      % - get scale factor that best fits all dispersion values
      dispsca = fminsearch(@(x) dispscafit(obj,x,A,dd.x,dd.y,dispx_err,dispy_err,ddispx,ddispy),1,optimset('Display','iter')) ;
      dd.x=dd.x.*dispsca; dd.y=dd.y.*dispsca; dispx_err=dispx_err.*dispsca; dispy_err=dispy_err.*dispsca;
      dispx = dd.x - ddispx.*1000 ; dispy = dd.y - ddispy.*1000 ; % subtract design dispersion to show dispersion error
      obj.DispData=obj.DispData.*dispsca;
      if string(obj.orbitfitmethod)=="lscov"
        disp0 = lscov(A,[dispx(:);dispy(:)],1./[dispx_err(:);dispy_err(:)].^2) ;
      else
        disp0 = A \ [dispx(:);dispy(:)] ;
      end
      
      % Store fitted dispersion at each BPM location
      obj.DispFit = A * disp0(:) ;
      
      % Return dispersion fit at fitele location
      if nargout>0
        if ~exist('dfitele','var')
          dfitele=double(obj.fitele);
        else
          dfitele=double(dfitele);
        end
        if dfitele>id(1)
          [~,R] = RmatAtoB(double(id(1)),dfitele);
          DX_f = R(1:4,1:4) * disp0(:) ;
        else
          [~,R] = RmatAtoB(dfitele+1,double(id(1)));
          DX_f = R(1:4,1:4) \ disp0(:) ;
        end
      end
      
    end
    function fiterr = dispscafit(obj,dispsca,A,dispx,dispy,dispx_err,dispy_err,ddispx,ddispy)
      %DISPSCAFIT Fitting function to scale dispersion measurements
      
      % Scale measured dispersion
      dispx=dispx.*dispsca; dispy=dispy.*dispsca; dispx_err=dispx_err.*dispsca; dispy_err=dispy_err.*dispsca;
      dispx = dispx - ddispx.*1000 ; dispy = dispy - ddispy.*1000 ; % subtract design dispersion to show dispersion error
      
      % Fit model dispersion response from first BPM in the selection
      if string(obj.orbitfitmethod)=="lscov"
        disp0 = lscov(A,[dispx(:);dispy(:)],1./[dispx_err(:);dispy_err(:)].^2) ;
      else
        disp0 = A \ [dispx(:);dispy(:)] ;
      end
      % fitted dispersion at each BPM location 
      dfit = A * disp0(:) ;
      % fit error
      fiterr = sum(abs(dfit-[dispx(:);dispy(:)])) ;
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
          xf = A \ [xstd(:);ystd(:)] ;
        end
      end
      i0=obj.LM.istart; 
      [~,R] = RmatAtoB(double(i0),double(id(1))); R=R([1:4 6],[1:4 6]);
      X0 = R \ xf ;
      if nargout>1
        i1=obj.fitele;
        if id(1)>=i1
          error('First available BPM after desired fit location!');
        end
        [~,R]=RmatAtoB(double(id(1)),double(i1)); R=R([1:4 6],[1:4 6]);
        X1 = R * xf ;
        X1(1:4)=X1(1:4).*1e3; 
      end
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
      reforbit = obj.RefOrbit ;
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
        % For some bizzarre reason, usebpm, usexcor & useycor all load with false values regardless of their saved state, so use separate variables for these
        ld = load(obj.OrbitConfigDir+"/conf_" + name + ".mat",'OrbitApp','usebpm','usexcor','useycor') ;
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
      % Load everything else...
      restorelist=["corsolv" "solvtol" "usex" "usey" "nmode" "domodelfit" "usebpmbuff" "dormsplot"  "fitele" "CorrectionOffset" "UseRefOrbit" "npulse" "orbitfitmethod"] ;
      for ilist=1:length(restorelist)
        obj.(restorelist(ilist)) = ld.OrbitApp.(restorelist(ilist)) ;
      end
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
      drawnow
    end
    function DoEscan(obj,nbpm)
      %DOESCAN Perform energy scan and extract dispersion function at BPMs
      %DoEscan(Nbpm)
      % Nbpm: number BPM readings to take per energy scan setting
      
      % Get energy knob to scan and desired range
      id = find(ismember(obj.EnergyKnobNames,obj.escandev)) ;
      evals = linspace(obj.escanrange(1,id),obj.escanrange(2,id),obj.nescan) ; % Delta-E (MeV)
      knob = obj.EnergyKnobs{id} ;
      
      % Get starting knob value
      % - MKB's adjust phase, EPICS adjusts amplitude
      if startsWith(knob(1),"MKB:")
        ismk=true;
        MK = SCP_MKB(lower(regexprep(knob,"^MKB:",""))) ;
        k0=0;
      else
        ismk=false;
        k0=lcaGet(cellstr(knob(:)));
      end
      
      % Get ENLD & phases
      pha=zeros(1,length(obj.EnergyKnobsKlys{id})); enld=pha; e0=pha;
      for iknob=1:length(obj.EnergyKnobsKlys{id})
        t=regexp(obj.EnergyKnobsKlys{id}(iknob),"(\d+)_(\d)","tokens","once");
        isec=double(t(1)); ikly=double(t(2));
        if isec==11
          pha(iknob)=lcaGet(char(obj.EnergyKnobsKlys11(2,iknob)));
          enld(iknob)=lcaGet(char(obj.EnergyKnobsKlys11(1,iknob)));
        elseif isec==10
          pha(iknob)=0;
          enld(iknob)=60;
        else
          pha(iknob)=lcaGet(char("LI"+isec+":KLYS:"+ikly+"1:PDES"));
          enld(iknob)=lcaGet(char("LI"+isec+":KLYS:"+ikly+"1:ENLD"));
        end
        e0(iknob)=enld(iknob)*cosd(pha(iknob));
      end
      
      % Scan the energy knob
      obj.escandata=cell(length(evals),6);
      disp("Starting energy scan...");
      for ival=1:length(evals)
        
        % Set the knob
        if ismk
          % Get required phase change to adjust the energy as required
          e_new = sum(e0) + evals(ival) ;
          dth = acosd(e_new/sum(enld)) -mean(abs(pha)) ;
          disp("Setting MKB:"+MK.Name+" dpha= "+ dth + " ...");
          MK.set(dth);
        else
          esca = 1 + evals(ival) / sum(e0) ; % Scale energy knob by required amount
          disp("Scaling " + knob(:) + " by " + esca + " ...");
          lcaPut(cellstr(knob(:)),k0(:).*esca);
        end
        pause(1);
        disp("Geting BPM data...");
        % Get BPM data:
        if obj.usebpmbuff
          obj.BPMS.readbuffer(nbpm);
        else
          obj.BPMS.readnp(nbpm);
        end
        % Process and store data
        [xm,ym,xstd,ystd,use,id] = obj.GetOrbit;
        obj.escandata{ival,1}=xm;
        obj.escandata{ival,2}=ym;
        obj.escandata{ival,3}=xstd;
        obj.escandata{ival,4}=ystd;
        obj.escandata{ival,5}=use;
        obj.escandata{ival,6}=id;
      end
      disp("Finished energy scan.");
    end
    function dispdat = ProcEscan(obj)
      %PROCESCAN Process escan data to generate dispersion at BPMs
      if isempty(obj.escandata)
        error('No energy scan performed');
      end
      id = find(ismember(obj.EnergyKnobNames,obj.escandev)) ;
      evals = linspace(obj.escanrange(1,id),obj.escanrange(2,id),obj.nescan) ; % Delta-E (MeV)
      xvals=nan(length(evals),length(obj.BPMS.modelID)); yvals=xvals; dxvals=xvals; dyvals=xvals;
      for idat=1:length(evals)
        xvals(idat,obj.escandata{idat,5}) = obj.escandata{idat,1} ;
        dxvals(idat,obj.escandata{idat,5}) = obj.escandata{idat,3} ;
        yvals(idat,obj.escandata{idat,5}) = obj.escandata{idat,2} ;
        dyvals(idat,obj.escandata{idat,5}) = obj.escandata{idat,4} ;
      end
      dispx=nan(1,length(obj.BPMS.modelID)); dispx_err=dispx; dispy=dispx; dispy_err=dispx;
      for ibpm=1:length(obj.BPMS.modelID)
        sel = ~isnan(xvals(:,ibpm)) ;
        if sum(sel)>=3
          x = evals(sel) ; y = xvals(sel) ; dy = dxvals(sel) ;
          [q,dq] = noplot_polyfit(x,y,dy,2) ;
          dispx(ibpm) = q(2); dispx_err = dq(2) ;
        end
        sel = ~isnan(yvals(:,ibpm)) ;
        if sum(sel)>=3
          x = evals(sel) ; y = yvals(sel) ; dy = dyvals(sel) ;
          [q,dq] = noplot_polyfit(x,y,dy,2) ;
          dispy(ibpm) = q(2); dispy_err = dq(2) ;
        end
      end
      sel=~isnan(dispx) & ~isnan(dispy) ;
      dispx=dispx(sel); dispx_err=dispx_err(sel);
      dispy=dispy(sel); dispy_err=dispy_err(sel);
      dispdat.ebpm=nan;
      dispdat.usebpm=sel;
      dispdat.x=dispx;
      dispdat.xerr=dispx_err;
      dispdat.y=dispy;
      dispdat.yerr=dispy_err;
      obj.DispData = dispdat ;
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
    function plotdisp(obj,ahan,showmodel,showcors)
      global BEAMLINE
      if isempty(obj.DispData)
        return
      end
      if ~exist('ahan','var') || isempty(ahan)
        figure
        ahan(1)=subplot(2,1,1);
        ahan(2)=subplot(2,1,2);
      end
      if ~exist('showmodel','var')
        showmodel=false;
      end
      ahan(1).reset; ahan(2).reset;
      dd=obj.DispData;
      id=obj.bpmid(dd.usebpm) ;
      z = arrayfun(@(x) BEAMLINE{x}.Coordi(3),id) ;
      ddispx = obj.LiveModel.DesignTwiss.etax(id) ;
      ddispy = obj.LiveModel.DesignTwiss.etay(id) ;
      names = obj.bpmnames(dd.usebpm);
      dispx = dd.x - ddispx.*1000 ; dispy = dd.y - ddispy.*1000 ; % subtract design dispersion to show dispersion error
      dispx_err = dd.xerr; dispy_err = dd.yerr ;
      
      % Fit model dispersion response from first BPM in the selection
      A = zeros(length(dispx)+length(dispy),4) ; A(1,:) = [1 0 0 0] ; A(length(dispx)+1,:) = [0 0 1 0] ;
      for ibpm=2:length(id)
        [~,R]=RmatAtoB(double(id(1)),double(id(ibpm)));
        A(ibpm,:) = [R(1,1) R(1,2) R(1,3) R(1,4)];
        A(ibpm+length(dispx),:) = [R(3,1) R(3,2) R(3,3) R(3,4)];
      end
      if string(obj.orbitfitmethod)=="lscov"
        disp0 = lscov(A,[dispx(:);dispy(:)],1./[dispx_err(:);dispy_err(:)].^2) ;
      else
        disp0 = A \ [dispx(:);dispy(:)] ;
      end
      obj.DispFit = A * disp0(:) ;
      
      % Do plots
      pl=errorbar(ahan(1),z,dispx,dispx_err,'.'); grid(ahan(1),'on'); ylabel(ahan(1),'\eta_x [mm]');
      pl.DataTipTemplate.DataTipRows(1).Label = 'Linac Z (m)' ;
      pl.DataTipTemplate.DataTipRows(2).Label = '\eta_x (mm)' ;
      pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',names);
      if showmodel
        hold(ahan(1),'on');
        plot(ahan(1),z,obj.DispFit(1:length(dispx)));
        hold(ahan(1),'off');
      end
      pl=errorbar(ahan(2),z,dispy,dispy_err,'.'); grid(ahan(2),'on'); xlabel(ahan(2),'Z [m]'); ylabel(ahan(2),'\eta_y [mm]');
      pl.DataTipTemplate.DataTipRows(1).Label = 'Linac Z (m)' ;
      pl.DataTipTemplate.DataTipRows(2).Label = '\eta_y (mm)' ;
      pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',names);
      if showmodel
        hold(ahan(2),'on');
        plot(ahan(2),z,obj.DispFit(length(dispx)+1:end));
        hold(ahan(2),'off');
      end
      ahan(1).XLim=[min(z) max(z)];
      ahan(2).XLim=[min(z) max(z)];
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
          for icor=find(obj.useycor(:)')
            line(yax,[obj.cordat_y.z(icor) obj.cordat_y.z(icor)],yax.YLim,'LineStyle','-','Color','black','LineWidth',2);
          end
          hold(xax,'off');
          hold(yax,'off');
        end
      end
      % Plot magnet bar
      F2_common.AddMagnetPlotZ(obj.LM.istart,obj.LM.iend,ahan(1)) ;
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
    function plotcor(obj,ahan,showmax)
      %PLOTCOR Plot corrector values and propose new corrector values
      %plotcor([axisHandle_x axisHandle_y],showmax)
      
      if isempty(obj.cordat_x)
        return
      end
      
      % Make new axes if not supplied
      if ~exist('ahan','var') || isempty(ahan)
        figure
        ahan(1)=subplot(2,1,1);
        ahan(2)=subplot(2,1,2);
      end
      ahan(1).reset; ahan(2).reset; cla(ahan(1)); cla(ahan(2)); drawnow;
      
      % Plot extant corrector kick values
      pl=plot(ahan(1),obj.cordat_x.z(obj.usexcor),obj.cordat_x.theta(obj.usexcor).*1e3,'.','Color',F2_common.ColorOrder(1,:),'MarkerSize',10);
      pl.DataTipTemplate.DataTipRows(1).Label = 'Linac Z' ;
      pl.DataTipTemplate.DataTipRows(2).Label = 'X Kick (rad)' ;
      pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',obj.xcornames(obj.usexcor));
      pl=plot(ahan(2),obj.cordat_y.z(obj.useycor),obj.cordat_y.theta(obj.useycor).*1e3,'.','Color',F2_common.ColorOrder(1,:),'MarkerSize',10);
      pl.DataTipTemplate.DataTipRows(1).Label = 'Linac Z' ;
      pl.DataTipTemplate.DataTipRows(2).Label = 'Y Kick (rad)' ;
      pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',obj.ycornames(obj.useycor));
      grid(ahan(1),'on');
      grid(ahan(2),'on');
      ylabel(ahan(1),'XCOR \theta_x [mrad]');
      xlabel(ahan(2),'Z [m]'); ylabel(ahan(2),'YCOR \theta_y [mrad]');
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
        pl_p=plot(ahan(1),zv_x(i_p),newtheta_x(i_p).*1e3,'^','Color',F2_common.ColorOrder(1,:),'MarkerSize',4);
        pl_m=plot(ahan(1),zv_x(i_m),newtheta_x(i_m).*1e3,'v','Color',F2_common.ColorOrder(1,:),'MarkerSize',4);
        for icor=find(obj.usexcor)'
          y1 = obj.cordat_x.theta(icor) ; y2 = obj.cordat_x.theta(icor)+obj.dtheta_x(icor) ;
          line(ahan(1),ones(1,2).*obj.cordat_x.z(icor),[y1 y2].*1e3,'Color',F2_common.ColorOrder(1,:));
        end
        pl_p.DataTipTemplate.DataTipRows(1).Label = 'Linac Z' ;
        pl_p.DataTipTemplate.DataTipRows(2).Label = 'X Kick (rad)' ;
        pl_p.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',obj.xcornames(i_p));
        pl_m.DataTipTemplate.DataTipRows(1).Label = 'Linac Z' ;
        pl_m.DataTipTemplate.DataTipRows(2).Label = 'X Kick (rad)' ;
        pl_m.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',obj.xcornames(i_m));
        hold(ahan(1),'off');
        hold(ahan(2),'on');
        i_p = obj.dtheta_y(obj.useycor)'>=0 ;
        i_m = obj.dtheta_y(obj.useycor)'<0 ;
        pl_p=plot(ahan(2),zv_y(i_p),newtheta_y(i_p).*1e3,'^','Color',F2_common.ColorOrder(1,:),'MarkerSize',4);
        pl_m=plot(ahan(2),zv_y(i_m),newtheta_y(i_m).*1e3,'v','Color',F2_common.ColorOrder(1,:),'MarkerSize',4);
        for icor=find(obj.useycor)'
          y1 = obj.cordat_y.theta(icor) ; y2 = obj.cordat_y.theta(icor)+obj.dtheta_y(icor) ;
          line(ahan(2),ones(1,2).*obj.cordat_y.z(icor),[y1 y2].*1e3,'Color',F2_common.ColorOrder(1,:));
        end
        pl_p.DataTipTemplate.DataTipRows(1).Label = 'Linac Z' ;
        pl_p.DataTipTemplate.DataTipRows(2).Label = 'Y Kick (rad)' ;
        pl_p.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',obj.ycornames(i_p));
        pl_m.DataTipTemplate.DataTipRows(1).Label = 'Linac Z' ;
        pl_m.DataTipTemplate.DataTipRows(2).Label = 'Y Kick (rad)' ;
        pl_m.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',obj.ycornames(i_m));
        hold(ahan(2),'off');
      end
      
      % Plot min/max values
      if showmax
        hold(ahan(1),'on');
        plot(ahan(1),obj.cordat_x.z(obj.usexcor),obj.cordat_x.thetamax(obj.usexcor).*1e3,'k--');
        plot(ahan(1),obj.cordat_x.z(obj.usexcor),-obj.cordat_x.thetamax(obj.usexcor).*1e3,'k--');
        hold(ahan(1),'off');
        hold(ahan(2),'on');
        plot(ahan(2),obj.cordat_y.z(obj.useycor),obj.cordat_y.thetamax(obj.useycor).*1e3,'k--');
        plot(ahan(2),obj.cordat_y.z(obj.useycor),-obj.cordat_y.thetamax(obj.useycor).*1e3,'k--');
        hold(ahan(2),'off');
      end
      
      % Magnet bar
      F2_common.AddMagnetPlotZ(obj.LM.istart,obj.LM.iend,ahan(1)) ;
      
    end
    function plotbpm(obj,ahan,showmodel,showcors)
      %PLOTBPM Plot BPM averaged orbit
      %plotbpm()
      %  Plot on new figure window
      %plotbpm([axisHandle1 , axisHandle2])
      %  Plot on provided axis handles (for [x y])
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
      [xm,ym,xstd,ystd,use,id] = obj.GetOrbit ;
      
      if ~any(use)
        error('No Data to plot');
      end
      if ~exist('ahan','var') || isempty(ahan)
        figure
        ahan(1)=subplot(2,1,1);
        ahan(2)=subplot(2,1,2);
      end
      ahan(1).reset; ahan(2).reset;
      
      obj.LM.ModelClasses="MONI";
      
      z = arrayfun(@(x) BEAMLINE{x}.Coordi(3),id) ;
      xax=ahan(1);
      yax=ahan(2);
      if obj.dormsplot
        pl=stem(xax,z,xstd,'filled');
      else
        pl=errorbar(xax,z,xm,xstd,'.');
      end
      zmin=z(1); zmax=z(end);
      ylabel(xax,'X [mm]');
      pl.DataTipTemplate.DataTipRows(1).Label = 'Linac Z' ;
      pl.DataTipTemplate.DataTipRows(2).Label = '<X>' ;
      pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('RMS_X',xstd);
      pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',obj.BPMS.modelnames(use));
      grid(xax,'on');
      if obj.BPMS.plotscale>0
        xax.YLim=[-double(obj.BPMS.plotscale) double(obj.BPMS.plotscale)];
      else
        xax.YLimMode="auto";
      end
      if obj.dormsplot
        pl=stem(yax,z,ystd,'filled');
      else
        pl=errorbar(yax,z,ym,ystd,'.'); xlabel(yax,'Z [m]'); ylabel(yax,'Y [mm]');
      end
      zmin=min([zmin z(1)]); zmax=max([zmax z(end)]);
      pl.DataTipTemplate.DataTipRows(1).Label = 'Linac Z' ;
      pl.DataTipTemplate.DataTipRows(2).Label = '<Y>' ;
      pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('RMS_Y',ystd);
      pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',obj.BPMS.modelnames(use));
      grid(yax,'on');
      if obj.BPMS.plotscale>0
        yax.YLim=[-double(obj.BPMS.plotscale) double(obj.BPMS.plotscale)];
      else
        yax.YLimMode="auto";
      end
      % Show corrector locations?
      if showcors
        hold(xax,'on');
        hold(yax,'on');
        for icor=find(obj.usexcor(:)')
          line(xax,[obj.cordat_x.z(icor) obj.cordat_x.z(icor)],xax.YLim,'LineStyle','-','Color','black','LineWidth',2);
        end
        zmin=min([zmin min(obj.cordat_x.z(icor))]); zmax=max([zmax max(obj.cordat_x.z(icor))]);
        for icor=find(obj.useycor(:)')
          line(yax,[obj.cordat_y.z(icor) obj.cordat_y.z(icor)],yax.YLim,'LineStyle','-','Color','black','LineWidth',2);
        end
        zmin=min([zmin min(obj.cordat_y.z(icor))]); zmax=max([zmax max(obj.cordat_y.z(icor))]);
        hold(xax,'off');
        hold(yax,'off');
      end
      % If orbit correction calcs performed, superimpose solution
      if obj.calcperformed
        hold(xax,'on');
        xc=obj.xbpm_cor(obj.usebpm);
        plot(xax,z,xc);
        hold(xax,'off');
        hold(yax,'on');
        yc=obj.ybpm_cor(obj.usebpm);
        plot(yax,z,yc);
        hold(yax,'off');
      end
      % Superimpose model fit if requested
      if showmodel
        idf=id(1):id(end);
        X0 = obj.orbitfit(); % X0 is orbit at region start
        i0m=double(obj.LM.istart); 
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
        hold(xax,'on');
        plot(xax,zi,x_fit);
        hold(xax,'off');
        hold(yax,'on');
        plot(yax,zi,y_fit);
        hold(yax,'off');
      end
      % Plot magnet bar
      if ~isempty(obj.aobj)
        F2_common.AddMagnetPlotZ(obj.LM.istart,obj.LM.iend,ahan(1)) ;
      end
      ahan(1).XLim=[zmin zmax];
      ahan(2).XLim=[zmin zmax];
      
    end
    function [xm,ym,xstd,ystd,use,id] = GetOrbit(obj)
      %GETORBIT Return mean and rms orbit from raw data
      use=ismember(obj.BPMS.modelID,obj.bpmid(obj.usebpm));
      if ~any(use)
        error('No BPM Data to use');
      end
      id = double(obj.BPMS.modelID(use)) ;
      xm = mean(obj.BPMS.xdat,2,'omitnan') ; xm=xm(use);
      ym = mean(obj.BPMS.ydat,2,'omitnan') ; ym=ym(use);
      xstd = std(obj.BPMS.xdat,[],2,'omitnan') ; xstd=xstd(use);
      ystd = std(obj.BPMS.ydat,[],2,'omitnan') ; ystd=ystd(use);
      if ~isempty(obj.RefOrbit)
        rid = ismember(id,obj.RefOrbit(:,1)) ;
        xm = xm(rid) ; xstd=xstd(rid); ym = ym(rid); ystd=ystd(rid);
        xm = xm - obj.RefOrbit(:,2) ; ym = ym - obj.RefOrbit(:,3) ;
        id=id(rid);
        use = use & ismember(obj.BPMS.modelID,id);
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
      obj.LM.ModelClasses="XCOR";
      obj.usexcor(~obj.badxcors & ismember(obj.xcorid,obj.LM.ModelID)) = true ;
      obj.LM.ModelClasses="YCOR";
      obj.useycor(~obj.badycors & ismember(obj.ycorid,obj.LM.ModelID)) = true ;
      obj.calcperformed=false;
      obj.fitele=obj.LM.iend;
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
end
