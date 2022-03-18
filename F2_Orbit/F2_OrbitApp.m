classdef F2_OrbitApp < handle & F2_common
  properties
    BPMS % Storage for F2_bpms object
    aobj % Storage for GUI application object
    LM % LucretiaModel object
    LiveModel % LiveModel object
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
    corsolv string {mustBeMember(corsolv,["lscov","pinv","lsqminnorm","svd","lsqlin"])} = "lscov" % solver to use for orbit correction
    solvtol % tolerance for orbit solution QR factorization tolerance (only use if set)
    usex logical = true % apply x corrections when asked?
    usey logical = true % apply y corrections when asked?
    nmode uint8 = inf % # of svd modes to include in correction (for corsolv="svd")
  end
  properties(SetAccess=private)
    cordat_x % XCOR data
    cordat_y % YCOR data
    dtheta_x % calculated x corrector kicks (rad)
    dtheta_y % calculated y corrector kicks (rad)
    xbpm_cor % calculated corrected x bpm vals (mm)
    ybpm_cor % calculated corrected y bpm vals (mm)
    ebpms_disp(1,4) % dispersion at energy BPMS in mm
    DispData % Dispersion data calculated with svddisp method (mm)
    DispFit % Fitted [dispersion_x; dispersion_y] at each BPM in selected regopm calculated with plotdisp method
    XFit % Fitted orbit [x;y] at each BPM in selected regopm calculated with plotbpm method
  end
  properties(SetAccess=private,Hidden)
    bdesx_restore % bdes values store when written for undo function
    bdesy_restore % bdes values store when written for undo function
  end
  properties(SetObservable)
    UseRegion(1,11) logical = true(1,11) % ["INJ";"L0";"DL1";"L1";"BC11";"L2";"BC14";"L3";"BC20";"FFS";"SPECTDUMP"]
    calcperformed logical =false
  end
  properties(Constant)
    ebpms string = ["BPM10731" "BPM11333" "BPM14801" "M3E"] % energy BPMs for DL1, BC11, BC14 & BC20
    epicsxcor = ["XC10121" "XC10221" "XC10311" "XC10381" "XC10411" "XC10491" "XC10521" "XC10641" "XC10721" "XC10761" ...
      "XC11104" "XC11140" "XC11202" "XC11272" "XC11304" "XC11398"]
    epicsycor = ["YC10122" "YC10222" "YC10312" "YC10382" "YC10412" "YC10492" "YC10522" "YC10642" "YC10722" "YC10762" ...
      "YC11105" "YC11141" "YC11203" "YC11273" "YC11305" "YC11321" "YC11365" "YC11399" ]
    klys_bsa = "KLYS:LI10:41:FB:FAST_AACT3" % L0B
    klys_cntrl = "KLYS:LI10:41:ADES" % L0B
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
      obj.dtheta_x=zeros(size(obj.xcornames));
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
      obj.dtheta_y=zeros(size(obj.ycornames));
      % Load model, get dispersions at ebpms
      load(F2_common.LucretiaLattice,'BEAMLINE','Initial');
      [~,T]=GetTwiss(1,length(BEAMLINE),Initial.x.Twiss,Initial.y.Twiss);
      for ibpm=1:length(obj.ebpms)
        bpmind = findcells(BEAMLINE,'Name',char(obj.ebpms(ibpm))) ;
        obj.ebpms_disp(ibpm) = T.etax(bpmind)*1e3 ;
      end
    end
    function acquire(obj,npulse)
      %ACQUIRE Get bpm and corrector data
      %acquire(npulse)
      global BEAMLINE
      % BPM data:
      obj.BPMS.readbuffer(npulse);
      obj.usebpm=false(size(obj.usebpm));
      obj.LM.ModelClasses="MONI";
      obj.usebpm(~obj.badbpms & ismember(obj.bpmid,obj.LM.ModelID)) = true ;
      obj.usebpm(~ismember(obj.bpmid,obj.BPMS.modelID))=false;
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
      % Get orbit to correct
      id = ismember(obj.BPMS.modelID,obj.bpmid(obj.usebpm)) ;
      xm = mean(obj.BPMS.xdat(id,:),2,'omitnan').*1e-3 ;
      ym = mean(obj.BPMS.ydat(id,:),2,'omitnan').*1e-3 ;
      xstd = std(obj.BPMS.xdat(id,:),[],2,'omitnan').*1e-3 ;
      ystd = std(obj.BPMS.ydat(id,:),[],2,'omitnan').*1e-3 ;
      % Form response matrix and correction vectors
      obj.getr;
      A = obj.RM ;
      B = -[xm(:); ym(:)] ;
      W = 1./[xstd(:); ystd(:)].^2 ;
      % Generate solution for required corrector kicks (in radians) with requested solver
      switch obj.corsolv
        case "lscov"
          dcor = lscov(A,B,W) ;
        case "pinv"
          dcor = pinv(A)*B ;
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
      % Store correction kicks and expected BPM response
      obj.dtheta_x(obj.usexcor) = dcor(1:sum(obj.usexcor)) ;
      obj.dtheta_y(obj.useycor) = dcor(1+sum(obj.usexcor):end) ;
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
      icor=[ixc iyc];
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
        error('BPM selection doesn''t include and energy BPM');
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
    function plotdisp(obj,ahan,domodelfit)
      global BEAMLINE
      if isempty(obj.DispData)
        return
      end
      if ~exist('ahan','var') || isempty(ahan)
        figure
        ahan(1)=subplot(2,1,1);
        ahan(2)=subplot(2,1,2);
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
      if exist('domodelfit','var') && domodelfit
        A = zeros(length(dispx)+length(dispy),4) ; A(1,:) = [1 0 0 0] ; A(length(dispx)+1,:) = [0 0 1 0] ;
        for ibpm=2:length(id)
          [~,R]=RmatAtoB(double(id(1)),double(id(ibpm)));
          A(ibpm,:) = [R(1,1) R(1,2) R(1,3) R(1,4)];
          A(ibpm+length(dispx),:) = [R(3,1) R(3,2) R(3,3) R(3,4)];
        end
        disp0 = lscov(A,[dispx(:);dispy(:)],1./[dispx_err(:);dispy_err(:)].^2) ;
        obj.DispFit = A * disp0(:) ;
      else
        domodelfit=false;
      end
      
      % Do plots
      pl=errorbar(ahan(1),z,dispx,dispx_err,'.'); grid(ahan(1),'on'); xlabel(ahan(1),'Z [m]'); ylabel(ahan(1),'\eta_x [mm]');
      pl.DataTipTemplate.DataTipRows(1).Label = 'Linac Z (m)' ;
      pl.DataTipTemplate.DataTipRows(2).Label = '\eta_x (mm)' ;
      pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',names);
      if domodelfit
        hold(ahan(1),'on');
        plot(ahan(1),z,obj.DispFit(1:length(dispx)));
        hold(ahan(1),'off');
      end
      pl=errorbar(ahan(2),z,dispy,dispy_err,'.'); grid(ahan(2),'on'); xlabel(ahan(2),'Z [m]'); ylabel(ahan(2),'\eta_y [mm]');
      pl.DataTipTemplate.DataTipRows(1).Label = 'Linac Z (m)' ;
      pl.DataTipTemplate.DataTipRows(2).Label = '\eta_y (mm)' ;
      pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',names);
      if domodelfit
        hold(ahan(2),'on');
        plot(ahan(2),z,obj.DispFit(length(dispx)+1:end));
        hold(ahan(2),'off');
      end
      ahan(1).XLim=[min(z) max(z)];
      ahan(2).XLim=[min(z) max(z)];
      % Plot magnet bar
      if ~isempty(obj.aobj)
        obj.aobj.UIAxes5_3.reset;
        obj.aobj.UIAxes5_3.XLim=[min(z) max(z)];
        ylabel(obj.aobj.UIAxes5_3,'\eta_x [mm]');
        AddMagnetPlotZ(id(1),id(end),obj.aobj.UIAxes5_3,'replace');
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
    function plotcor(obj,ahan)
      %PLOTCOR Plot corrector values and propose new corrector values
      %plotcor([axisHandle_x axisHandle_y])
      
      if isempty(obj.cordat_x)
        return
      end
      
      % Make new axes if not supplied
      if ~exist('ahan','var') || isempty(ahan)
        figure
        ahan(1)=subplot(2,1,1);
        ahan(2)=subplot(2,1,2);
      end
      ahan(1).reset; ahan(2).reset;
      
      % Plot extant corrector kick values
      pl=stem(ahan(1),obj.cordat_x.z(obj.usexcor),obj.cordat_x.theta(obj.usexcor));
      pl.DataTipTemplate.DataTipRows(1).Label = 'Linac Z' ;
      pl.DataTipTemplate.DataTipRows(2).Label = 'X Kick (rad)' ;
      pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',obj.xcornames(obj.usexcor));
      xlabel(ahan(1),'Z [m]'); ylabel(ahan(1),'XCOR \theta_x [rad]');
      grid(ahan(1),'on');
      ahan(1).XLim=[min(obj.cordat_x.z(obj.usexcor)) max(obj.cordat_x.z(obj.usexcor))];
      pl=stem(ahan(2),obj.cordat_y.z(obj.useycor),obj.cordat_y.theta(obj.useycor));
      pl.DataTipTemplate.DataTipRows(1).Label = 'Linac Z' ;
      pl.DataTipTemplate.DataTipRows(2).Label = 'Y Kick (rad)' ;
      pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',obj.ycornames(obj.useycor));
      xlabel(ahan(2),'Z [m]'); ylabel(ahan(2),'YCOR \theta_y [rad]');
      grid(ahan(2),'on');
      ahan(2).XLim=[min(obj.cordat_y.z(obj.useycor)) max(obj.cordat_y.z(obj.useycor))];
      
      % If calculated, superimpose new kick values proposed
      if obj.calcperformed
        newtheta_x = obj.cordat_x.theta(obj.usexcor)+obj.dtheta_x(obj.usexcor) ;
        newtheta_y = obj.cordat_y.theta(obj.useycor)+obj.dtheta_y(obj.useycor) ;
        hold(ahan(1),'on');
        stem(ahan(1),obj.cordat_x.z(obj.usexcor),newtheta_x);
        hold(ahan(1),'off');
        hold(ahan(2),'on');
        stem(ahan(2),obj.cordat_y.z(obj.useycor),newtheta_y);
        hold(ahan(2),'off');
      end
      
      % Plot min/max values if any of the correctors are close
%       if any(obj.cordat_x.theta(obj.usexcor)./obj.cordat_x.thetamax(obj.usexcor) > 0.9) || ...
%           obj.calcperformed && any(newtheta_x./obj.cordat_x.thetamax(obj.usexcor) > 0.9)
        hold(ahan(1),'on');
        plot(ahan(1),obj.cordat_x.z(obj.usexcor),obj.cordat_x.thetamax(obj.usexcor),'k--');
        hold(ahan(1),'off');
%       end
%       if any(obj.cordat_x.theta(obj.usexcor)./obj.cordat_x.thetamax(obj.usexcor) < -0.9) || ...
%           obj.calcperformed && any(newtheta_x./obj.cordat_x.thetamax(obj.usexcor) < -0.9)
        hold(ahan(1),'on');
        plot(ahan(1),obj.cordat_x.z(obj.usexcor),-obj.cordat_x.thetamax(obj.usexcor),'k--');
        hold(ahan(1),'off');
%       end
%       if any(obj.cordat_y.theta(obj.useycor)./obj.cordat_y.thetamax(obj.useycor) > 0.9) || ...
%           obj.calcperformed && any(newtheta_y./obj.cordat_y.thetamax(obj.useycor) > 0.9)
        hold(ahan(2),'on');
        plot(ahan(2),obj.cordat_y.z(obj.useycor),obj.cordat_y.thetamax(obj.useycor),'k--');
        hold(ahan(2),'off');
%       end
%       if any(obj.cordat_y.theta(obj.useycor)./obj.cordat_y.thetamax(obj.useycor) < -0.9) || ...
%           obj.calcperformed && any(newtheta_y./obj.cordat_y.thetamax(obj.useycor) < -0.9)
        hold(ahan(2),'on');
        plot(ahan(2),obj.cordat_y.z(obj.useycor),-obj.cordat_y.thetamax(obj.useycor),'k--');
        hold(ahan(2),'off');
%       end
      
    end
    function plotbpm(obj,ahan,domodelfit)
      %PLOTBPM Plot BPM averaged orbit
      %plotbpm()
      %  Plot on new figure window
      %plotbpm([axisHandle1 , axisHandle2])
      %  Plot on provided axis handles (for [x y])
      global BEAMLINE
      if isempty(obj.BPMS.xdat)
        error('No data to plot')
      end
      use=ismember(obj.BPMS.modelID,obj.bpmid(obj.usebpm));
      id = double(obj.BPMS.modelID(use)) ;
      if ~any(use)
        error('No Data to plot');
      end
      if ~exist('ahan','var') || isempty(ahan)
        figure
        ahan(1)=subplot(2,1,1);
        ahan(2)=subplot(2,1,2);
      end
      ahan(1).reset; ahan(2).reset;
      xm = mean(obj.BPMS.xdat,2,'omitnan') ; xm=xm(use);
      ym = mean(obj.BPMS.ydat,2,'omitnan') ; ym=ym(use);
      xstd = std(obj.BPMS.xdat,[],2,'omitnan') ; xstd=xstd(use);
      ystd = std(obj.BPMS.ydat,[],2,'omitnan') ; ystd=ystd(use);
      obj.LM.ModelClasses="MONI";
      
      % Fit model dispersion response from first BPM in the selection
      if exist('domodelfit','var') && domodelfit
        A = zeros(length(xm)+length(ym),4) ; A(1,:) = [1 0 0 0] ; A(length(xm)+1,:) = [0 0 1 0] ;
        for ibpm=2:length(id)
          [~,R]=RmatAtoB(id(1),id(ibpm));
          A(ibpm,:) = [R(1,1) R(1,2) R(1,3) R(1,4)];
          A(ibpm+length(xm),:) = [R(3,1) R(3,2) R(3,3) R(3,4)];
        end
        x0 = lscov(A,[xm(:);ym(:)],1./[xstd(:);ystd(:)].^2) ;
        obj.XFit = A * x0(:) ;
      else
        domodelfit=false;
      end
      
      z = arrayfun(@(x) BEAMLINE{x}.Coordi(3),id) ;
      xax=ahan(1);
      yax=ahan(2);
      pl=errorbar(xax,z,xm,xstd,'.'); xlabel(xax,'Z [m]'); ylabel(xax,'X [mm]');
      pl.DataTipTemplate.DataTipRows(1).Label = 'Linac Z' ;
      pl.DataTipTemplate.DataTipRows(2).Label = '<X>' ;
      pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('RMS_X',xstd);
      pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',obj.BPMS.modelnames(use));
      xax.XLim(1)=min(z);
      xax.XLim(2)=max(z);
      grid(xax,'on');
      if obj.BPMS.plotscale>0
        xax.YLim=[-double(obj.BPMS.plotscale) double(obj.BPMS.plotscale)];
      else
        xax.YLimMode="auto";
      end
      pl=errorbar(yax,z,ym,ystd,'.'); xlabel(yax,'Z [m]'); ylabel(yax,'Y [mm]');
      pl.DataTipTemplate.DataTipRows(1).Label = 'Linac Z' ;
      pl.DataTipTemplate.DataTipRows(2).Label = '<Y>' ;
      pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('RMS_Y',ystd);
      pl.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Name',obj.BPMS.modelnames(use));
      yax.XLim(1)=min(z);
      yax.XLim(2)=max(z);
      grid(yax,'on');
      if obj.BPMS.plotscale>0
        yax.YLim=[-double(obj.BPMS.plotscale) double(obj.BPMS.plotscale)];
      else
        yax.YLimMode="auto";
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
      if domodelfit
        hold(xax,'on');
        plot(xax,z,obj.XFit(1:length(xm)));
        hold(xax,'off');
        hold(yax,'on');
        plot(yax,z,obj.XFit(1+length(xm):end));
        hold(yax,'off');
      end
      % Plot magnet bar
      if ~isempty(obj.aobj)
        obj.aobj.UIAxes_3.reset;
        obj.aobj.UIAxes_3.XLim=[min(z) max(z)];
        ylabel(obj.aobj.UIAxes_3,'X [mm]');
        AddMagnetPlotZ(id(1),id(end),obj.aobj.UIAxes_3,'replace');
      end
    end
  end
end
