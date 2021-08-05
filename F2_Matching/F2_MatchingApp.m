classdef F2_MatchingApp < handle & F2_common
  properties
    guihan
    QuadScanData
    ProfFitMethod string {mustBeMember(ProfFitMethod,["Gaussian","Asymmetric"])} = "Asymmetric"
    LiveModel
    NumMatchQuads uint8 = 4 % Number of quadrupoles upstream of profile monitor to use in match
    Optimizer string {mustBeMember(Optimizer,["fminsearch","lsqnonlin"])} = "lsqnonlin"
  end
  properties(SetAccess=private)
    goodmatch logical = false
  end
  properties(SetAccess=private,Hidden)
    InitMatch
    MatchQuadInitVals
    MatchQuadID
    InitRestore
  end
  properties(Dependent)
    quadscan_k
    ProfName string
    MatchQuadNames string
  end
  properties(Constant)
    InitMatchProf = ["WIRE:IN10:561","PROF:IN10:571"] % Profile devices to associate with initial match conditions
  end
 
  methods
    function obj = F2_MatchingApp(ghan)
      if exist('ghan','var') && ~isempty(ghan)
        obj.guihan=ghan;
      end
      obj.LiveModel = F2_LiveModelApp ;
      obj.LiveModel.UseArchive = true ;
      obj.UseArchive = true ;
    end
    function DoMatch(obj)
      %DOMATCH Perform matching to profile monitor device based on fitted Twiss parameters and live model
      global BEAMLINE PS
      obj.goodmatch = false ;
      obj.MatchQuadInitVals = []; obj.MatchQuadID=[];
      if ~isefield(obj.QuadScanData,'fit')
        fprintf(2,'No data to fit');
        return
      end
      LM=copy(obj.LiveModel.LEM.Mags.LM);
      id_prof = obj.QuadScanData.ProfInd ;
      LM_all=obj.LiveModel.LM;
      pele=LM_all.ModelUniqueID(id_prof);
      betax_design = obj.LiveModel.DesignTwiss.betax(pele) ;
      betay_design = obj.LiveModel.DesignTwiss.betay(pele) ;
      alphax_design = obj.LiveModel.DesignTwiss.alphax(pele) ;
      alphay_design = obj.LiveModel.DesignTwiss.alphay(pele) ;
      betax_fit = obj.QuadScanData.fit.betax ;
      betay_fit = obj.QuadScanData.fit.betay ;
      alphax_fit = obj.QuadScanData.fit.alphax ;
      alphay_fit = obj.QuadScanData.fit.alphay ;
      
      % Form list of matching quads
      LM.ModelClasses = "QUAD" ;
      iquads = LM.ModelUniqueID < pele ;
      if sum(iquads)<double(obj.NumMatchQuads)
        error('Insufficient matching quads available');
      end
      id1=find(iquads,double(obj.NumMatchQuads),'last') ;
      quadps = arrayfun(@(x) BEAMLINE{x}.PS,LM.ModelUniqueID(id1)) ;
      idm=ismember(obj.LiveModel.LEM.Mags.LM.ModelUniqueID,LM.ModelUniqueID(id1)) ;
      bmin = obj.LiveModel.LEM.Mags.BMIN(idm)./10;
      bmax = obj.LiveModel.LEM.Mags.BMAX(idm)./10;
      
      % Get initial PS settings
      ps_init = arrayfun(@(x) PS(x).Ampl,quadps) ;
      obj.MatchQuadInitVals = ps_init.*10 ;
      
      % If matching on PR10571 or WS10561 then get initial Twiss parameters and record them in PVs
      if ismember(obj.QuadScanData.ProfName,obj.InitMatchProf)
        i1=1;
      else % match from entrance of first matching quad
        i1=PS(quadps(1)).Element(1);
      end
      
      % Get Twiss parameters at initial match point
      I = TwissToInitial(obj.LiveModel.DesignTwiss,i1,obj.LiveModel.Initial);
      M=Match;
      M.beam=MakeBeam6DGauss(I,1e3,3,1);
      M.iInitial=i1;
      M.initStruc=I;
      M.verbose=false; % see optimizer output or not
      M.optim=char(obj.Optimizer);
      M.optimDisplay='iter';
      M.useParallel=false;
      M.addVariable('INITIAL',1,'betax',0.1,1000);
      M.addVariable('INITIAL',1,'betay',0.1,1000);
      M.addVariable('INITIAL',1,'alphax',-100,100);
      M.addVariable('INITIAL',1,'alphay',-100,100);
      M.addMatch(pele,'alpha_x',alphax_fit,1e-3);
      M.addMatch(pele,'alpha_y',alphay_fit,1e-3);
      M.addMatch(pele,'beta_x',betax_fit,betax_fit/1000);
      M.addMatch(pele,'beta_y',betay_fit,betay_fit/1000);
      M.doMatch;
      display(M);
      if any(abs(M.matchVals-[alphax_fit alphay_fit betax_fit betay_fit])>[0.01 0.01 betax_fit/100 betay_fit/100])
        error('Match failed');
      end
      obj.InitMatch=M.initStruc;
      
      % Calculate re-match to fitted Twiss parameters at profile monitor device
      M=Match;
      M.beam=MakeBeam6DGauss(obj.InitMatch,1e3,3,1);
      M.iInitial=i1;
      M.initStruc=obj.InitMatch;
      M.verbose=false; % see optimizer output or not
      M.optim=char(obj.Optimizer);
      M.optimDisplay='iter';
      M.useParallel=false;
      for ips=1:length(quadps)
        M.addVariable('PS', quadps(ips),'Ampl',bmin(ips),bmax(ips));
      end
      M.addMatch(pele,'alpha_x',alphax_design,1e-3);
      M.addMatch(pele,'alpha_y',alphay_design,1e-3);
      M.addMatch(pele,'beta_x',betax_design,betax_design/1e3);
      M.addMatch(pele,'beta_y',betay_design,betay_design/1e3);
      M.doMatch;
      display(M);
      
      % Restore pre-matched magnet strengths in model
      for ips=1:length(quadps)
        PS(ips).Ampl = ps_init(ips) ;
      end
      
      % Check match in range and store in Mags BDES field
      if any(M.varVals>bmax | M.varVals<bmin)
        error('Required quad match values outside limits');
      end
      if any(abs(M.matchVals-[alphax_design alphay_design betax_design betay_design])>[0.01 0.01 betax_design/100 betay_design/100])
        error('Match failed');
      end
      obj.MatchQuadID = idm ;
      obj.LiveModel.LEM.Mags.BDES(idm) = M.varVals ;
      obj.LiveModel.LEM.Mags.BDES_err(~idm) = false ; % set just matching quads to be written
      
      obj.goodmatch = true ;
      
    end
    function msg = RestoreMatchingQuads(obj)
      %RESTOREMATCHINGQUADS Undo last operation of WriteMatchQuads
      
      if isempty(obj.MatchQuadInitVals) || isempty(obj.MatchQuadID)
        error('No stored match quad settings to restore');
      end
      obj.LiveModel.LEM.Mags.BDES(obj.MatchQuadID) = obj.MatchQuadInitVals ;
      obj.LiveModel.LEM.Mags.BDES_err(~obj.MatchQuadID) = false ;
      obj.LiveModel.LEM.Mags.BDES_err(obj.MatchQuadID) = true ;
      msg = obj.LiveModel.LEM.Mags.WriteBDES ;
      obj.LiveModel.Initial = obj.InitRestore;
      obj.InitMatch = obj.InitRestore ;
      obj.goodmatch = false ;
      % Restore initial match conditions to PVs
      if ismember(obj.QuadScanData.ProfName,obj.InitMatchProf)
        lcaPutNowWait(char(obj.LiveModel.Initial_betaxPV),obj.InitMatch.x.Twiss.beta) ;
        lcaPutNowWait(char(obj.LiveModel.Initial_betaxPV),obj.InitMatch.y.Twiss.beta) ;
        lcaPutNowWait(char(obj.LiveModel.Initial_betaxPV),obj.InitMatch.x.Twiss.alpha) ;
        lcaPutNowWait(char(obj.LiveModel.Initial_betaxPV),obj.InitMatch.y.Twiss.alpha) ;
      end
    end
    function msg = WriteMatchQuads(obj)
      %WRITEMATCHQUADS Write matched quadrupole fields to control system and update any Twiss PVs
      
      % Require DoMatch to have successfully run
      if ~obj.goodmatch
        error('No good match solution found, aborting quad writing');
      end
      
      % Write matched values to control system
      msg = obj.LiveModel.LEM.Mags.WriteBDES ;
      
      % Write initial match conditions to PVs
      if ismember(obj.QuadScanData.ProfName,obj.InitMatchProf)
        lcaPutNowWait(char(obj.LiveModel.Initial_betaxPV),obj.InitMatch.x.Twiss.beta) ;
        lcaPutNowWait(char(obj.LiveModel.Initial_betaxPV),obj.InitMatch.y.Twiss.beta) ;
        lcaPutNowWait(char(obj.LiveModel.Initial_betaxPV),obj.InitMatch.x.Twiss.alpha) ;
        lcaPutNowWait(char(obj.LiveModel.Initial_betaxPV),obj.InitMatch.y.Twiss.alpha) ;
      end
      obj.InitRestore = obj.LiveModel.Initial ;
      obj.LiveModel.Initial=obj.InitMatch ;
    end
    function LoadQuadScanData(obj)
      %LOADSCANDATA Load corr plot data for quad scan
      
      obj.goodmatch = false ;
      obj.QuadScanData = [] ;
      LM=obj.LiveModel.LEM.Mags.LM;
      LM_all=obj.LiveModel.LM;
      
      % If there is a QUAD scan file in the current day's directory, default to loading that
      files = dir(obj.datadir);
      qscanfiles = startsWith(string(arrayfun(@(x) x.name,files,'UniformOutput',false)),"CorrelationPlot-QUAD") ;
      if any(qscanfiles)
        [~,latestfile]=max(datenum({files(qscanfiles).date}));
        ifile=find(qscanfiles); ifile=ifile(latestfile);
        [fn,pn]=uigetfile('CorrelationPlot-QUAD*','Select Cor Plot File',fullfile(obj.datadir,files(ifile).name));
      else % just offer up current data dir
        [fn,pn]=uigetfile('CorrelationPlot-QUAD*','Select Cor Plot File',obj.datadir);
      end
      if ~ischar(fn)
        return
      end
      % Update live model to match data file date
      if obj.UseArchive
        dd = dir(fullfile(pn,fn));
        obj.ArchiveDate = datevec(dd.datenum) ;
        obj.LiveModel.UseArchive = true ;
        obj.LiveModel.ArchiveDate = obj.ArchiveDate ;
      else
        obj.ArchiveDate = datevec(now) ;
        obj.LiveModel.UseArchive = false;
      end
      obj.LiveModel.UpdateModel ;
      dat = load(fullfile(pn,fn));
      obj.QuadScanData.QuadName = string(regexprep(dat.data.ctrlPV(1).name,'(:BCTRL)|(:BDES)$','')) ;
      stat = logical([dat.data.status]) ;
      obj.QuadScanData.QuadVal = [dat.data.ctrlPV(stat).val] ;
      obj.QuadScanData.nscan = sum(stat) ;
      if isfield(dat.data,'profPV')
        xpv = find(endsWith(string(arrayfun(@(x) x.name,dat.data.profPV(:,1),'UniformOutput',false)),"XRMS"),1) ;
        obj.QuadScanData.ProfName = string(regexprep(dat.data.profPV(xpv).name,':XRMS$','')) ;
        obj.QuadScanData.ProfInd = find(LM_all.ControlNames==obj.QuadScanData.ProfName,1) ;
      else
        obj.QuadScanData.ProfName = [] ;
      end
      fitm=["Gaussian" "Asymmetric"];
      for ii=1:2
        xdat=reshape([dat.data.beam(:,1,ii).xStat],5,length(stat)); xdat=xdat(3,stat);
        xdat_err=reshape([dat.data.beam(:,1,ii).xStatStd],5,length(stat)); xdat_err=xdat_err(3,stat);
        ydat=reshape([dat.data.beam(:,1,ii).yStat],5,length(stat)); ydat=ydat(3,stat);
        ydat_err=reshape([dat.data.beam(:,1,ii).yStatStd],5,length(stat)); ydat_err=ydat_err(3,stat);
        obj.QuadScanData.x.(fitm(ii)) = xdat ;
        obj.QuadScanData.xerr.(fitm(ii)) = xdat_err ;
        obj.QuadScanData.y.(fitm(ii)) = ydat ;
        obj.QuadScanData.yerr.(fitm(ii)) = ydat_err ;
      end
      obj.QuadScanData.QuadInd = find(LM.ControlNames==obj.QuadScanData.QuadName,1) ;
      if isempty(obj.QuadScanData.QuadInd)
        errordlg(sprintf('Scan Quad (%s) Not found in model',obj.QuadScanData.QuadName),'QUAD not found');
        obj.QuadScanData=[];
        return
      end
    end
    function WriteEmitData(obj)
      %WRITEENMITDATA Write twiss and emittance data to PVs
      if ~isempty(obj.QuadScanData) && isfield(obj.QuadScanData,'fit')
        lcaPutNoWait(spritnf('%s:BETA_X',obj.QuadScanData.ProfName),obj.QuadScanData.fit.betax);
        lcaPutNoWait(spritnf('%s:BETA_Y',obj.QuadScanData.ProfName),obj.QuadScanData.fit.betay);
        lcaPutNoWait(spritnf('%s:ALPHA_X',obj.QuadScanData.ProfName),obj.QuadScanData.fit.alphax);
        lcaPutNoWait(spritnf('%s:ALPHA_Y',obj.QuadScanData.ProfName),obj.QuadScanData.fit.alphay);
        lcaPutNoWait(spritnf('%s:BMAG_X',obj.QuadScanData.ProfName),obj.QuadScanData.fit.bmagx);
        lcaPutNoWait(spritnf('%s:BMAG_Y',obj.QuadScanData.ProfName),obj.QuadScanData.fit.bmagy);
        lcaPutNoWait(spritnf('%s:EMITN_X',obj.QuadScanData.ProfName),obj.QuadScanData.fit.emitnx*1e6);
        lcaPutNoWait(spritnf('%s:EMITN_Y',obj.QuadScanData.ProfName),obj.QuadScanData.fit.emitny*1e6);
      end
    end
    function FitQuadScanData(obj)
      %FITQUADSCANDATA Fit twiss parameter to live model using quad scan data
      % Taken from:
      %https://indico.cern.ch/event/703517/contributions/2886144/attachments/1602810/2541739/2018-02-19_Emittance_measurement_with_quadrupole_scan.pdf
      global BEAMLINE PS
      % Find scan quad ID, record PS setting and set to zero for initial calculations
      DesignTwiss = obj.LiveModel.DesignTwiss;
      id = obj.QuadScanData.QuadInd ;
      id_prof = obj.QuadScanData.ProfInd ;
      LM=obj.LiveModel.LEM.Mags.LM;
      LM_all=obj.LiveModel.LM;
      pele=LM_all.ModelUniqueID(id_prof);
      ele = LM.ModelUniqueID(id);
      ips = BEAMLINE{ele}.PS;
      ps0 = PS(ips).Ampl;
      PS(ips).Ampl=0;
      % Twiss parameters at quad entrance from quad scan data
      k = obj.quadscan_k ;
      x = obj.QuadScanData.x(obj.ProfFitMethod).*1e-6 ;
      xerr = obj.QuadScanData.xerr(obj.ProfFitMethod).*1e-6 ;
      y = obj.QuadScanData.y(obj.ProfFitMethod).*1e-6 ;
      yerr = obj.QuadScanData.yerr(obj.ProfFitMethod).*1e-6 ;
      qx=noplot_polyfit(k,x.^2,2.*x.*xerr,2);
      qy=noplot_polyfit(k,y.^2,2.*y.*yerr,2);
      % sigma matrix at (thin) quad entrance
      [~,R]=RmatAtoB(ele+1,pele); % from center of quad to profile monitor
      % -- x
      d=R(1,2);
      Lq=sum(arrayfun(@(x) BEAMLINE{x}.L,PS(ips).Element));
      A=qx(3); B=qx(2); C=qx(1);
      sig11 = A / (d^2*Lq^2) ;
      sig12 = (B-2*d*Lq*sig11)/(2*d^2*Lq) ;
      sig22 = (C-sig11-2*d*sig12) / d^2 ;
      rgamma = LM.ModelP(id)/0.511e-3;
      emit = sqrt(sig11*sig22 - sig12^2) ;
      obj.QuadScanData.fit.emitnx = rgamma * emit ;
      alpha = - sig12/emit ;
      beta = sig11/emit ;
      % Propogate Twiss back to start of Model quadrupole and then forward to profile monitor location
      S = emit .* [beta -alpha;-alpha (1+alpha^2)/beta] ;
      Rd = [1 -Lq/2;0 1] ;
      S0 = Rd*S*Rd';
      PS(ips).Ampl=ps0;
      [~,R2]=RmatAtoB(ele,pele);
      S_prof = R2(1:2,1:2)*S0*R2(1:2,1:2)';
      T=S_prof./emit ;
      obj.QuadScanData.fit.betax = T(1,1) ;
      obj.QuadScanData.fit.alphax = -T(1,2) ;
      obj.QuadScanData.fit.bmagx = bmag(DesignTwiss.betax(pele),DesignTwiss.alphax(pele),...
        obj.QuadScanData.fit.betax,obj.QuadScanData.fit.alphax);
      % -- y
      d=R(3,4);
      A=qy(3); B=qy(2); C=qy(1);
      sig11 = A / (d^2*Lq^2) ;
      sig12 = (B-2*d*Lq*sig11)/(2*d^2*Lq) ;
      sig22 = (C-sig11-2*d*sig12) / d^2 ;
      rgamma = LM.ModelP(id)/0.511e-3;
      emit = sqrt(sig11*sig22 - sig12^2) ;
      obj.QuadScanData.fit.emitny = rgamma * emit ;
      alpha = - sig12/emit ;
      beta = sig11/emit ;
      % Propogate Twiss back to start of Model quadrupole and then forward to profile monitor location
      S = emit .* [beta -alpha;-alpha (1+alpha^2)/beta] ;
      S0 = Rd*S*Rd';
      S_prof = R2(3:4)*S0*R2(3:4)';
      T=S_prof./emit ;
      obj.QuadScanData.fit.betay = T(1,1) ;
      obj.QuadScanData.fit.alphay = -T(1,2) ;
      obj.QuadScanData.fit.bmagy = bmag(obj.LiveModel.DesignTwiss.betay(pele),obj.LiveModel.DesignTwiss.alphay(pele),...
        obj.QuadScanData.fit.betay,obj.QuadScanData.fit.alphay);
    end
    function PlotQuadScanData(obj)
      k = obj.quadscan_k ;
      x = obj.QuadScanData.x(obj.ProfFitMethod) ;
      xerr = obj.QuadScanData.xerr(obj.ProfFitMethod) ;
      y = obj.QuadScanData.y(obj.ProfFitMethod) ;
      yerr = obj.QuadScanData.yerr(obj.ProfFitMethod) ;
      figure;
      fh=subplot(2,1,1);
      plot_polyfit(fh);
      plot_polyfit(k,x.^2,2.*x.*xerr,2,sprintf('K (%s)',obj.QuadScanData.QuadName),'\sigma_x^2','','\mum^2');
      fh=subplot(2,1,2);
      plot_polyfit(fh);
      plot_polyfit(k,y.^2,2.*y.*yerr,2,sprintf('K (%s)',obj.QuadScanData.QuadName),'\sigma_y^2','','\mum^2');
    end
    % Get/Set
    function kdes = get.quadscan_k(obj)
      if isempty(obj.QuadScanData)
        kdes=[];
        return
      end
      id = obj.QuadScanData.QuadInd ;
      LM=obj.LiveModel.LEM.Mags.LM;
      kdes = obj.QuadScanData.QuadVal./LM.ModelL(id)./obj.LM.ModelP(id)./PhysConstants.GEV2TM ;
    end
    function name = get.ProfName(obj)
      if isempty(obj.QuadScanData)
        name="";
      else
        name = obj.QuadScanData.ProfName;
      end
    end
    function names = get.MatchQuadNames(obj)
      if isempty(obj.QuadScanData)
        names="";
      else
        id_prof = obj.QuadScanData.ProfInd ;
        LM_all=obj.LiveModel.LM;
        pele=LM_all.ModelUniqueID(id_prof);
        LM=copy(obj.LiveModel.LEM.Mags.LM);
        LM.ModelClasses="QUAD";
        iquads = LM.ModelUniqueID < pele ;
        id1=find(iquads,double(obj.NumMatchQuads),'last') ;
        names = LM.ControlNames(id1) ;
      end
    end
  end
end