classdef F2_MatchingApp < handle & F2_common
  properties
    guihan
    QuadScanData
    TwissFitSource string {mustBeMember(TwissFitSource,["Model","Analytic"])} = "Model"
    ProfFitMethod string {mustBeMember(ProfFitMethod,["Gaussian","Asymmetric"])} = "Asymmetric"
    LiveModel
    Optimizer string {mustBeMember(Optimizer,["fminsearch","lsqnonlin"])} = "lsqnonlin"
    DimSelect string {mustBeMember(DimSelect,["X" "Y" "XY"])} = "XY"
    LM
    ShowPlotLegend logical = true
    UseMatchQuad logical % Which matching quads to use
  end
  properties(SetAccess=private)
    MatchQuadNames string = ["QUAD:IN10:425" "QUAD:IN10:441" "QUAD:IN10:511" "QUAD:IN10:525"] 
    TwissFitModel(1,8) = [1 1 0 0 1 1 5 5] % beta_x,beta_y,alpha_x,alpha_y,bmag_x,bmag_y,nemit_x,nemit_y fitted twiss parameters at profile device (nemit in um-rad)
    TwissFitAnalytic(1,8) = [1 1 0 0 1 1 5 5] % beta_x,beta_y,alpha_x,alpha_y,bmag_x,bmag_y,nemit_x,nemit_y fitted twiss parameters at profile device (nemit in um-rad)
  end
  properties(SetAccess=private,SetObservable)
    goodmatch logical = false
  end
  properties(SetAccess=private,Hidden)
    InitMatch
    TwissMatch
    TwissPreMatch
    MatchQuadInitVals
    MatchQuadID % ID into LiveModel.Mags
    ModelQuadScan % [2 x Nscan]
    InitRestore
    ProfModelInd
    MatchQuadModelInd
    LEMQuadID
    ScanDataSelect
  end
  properties(SetObservable,AbortSet)
    ModelSource string {mustBeMember(ModelSource,["Live" "Archive" "Design"])} = "Live"
    ModelDate(1,6) = [2021,7,1,12,1,1] % [yr,mnth,day,hr,min,sec]
  end
  properties(SetObservable)
    ProfName string = "PROF:IN10:571"
    NumMatchQuads uint8 {mustBeGreaterThan(NumMatchQuads,3)} = 4 % Number of quadrupoles upstream of profile monitor to use in match
    UndoAvailable logical = false
  end
  properties(Dependent)
    quadscan_k
    TwissFit(1,8)
  end
  properties(Constant)
    EmitDataProfs = "PROF:IN10:571" % profile devices for which there are emittance PVs
    InitMatchProf = ["WIRE:IN10:561","PROF:IN10:571"] % Profile devices to associate with initial match conditions
  end
 
  methods
    function obj = F2_MatchingApp(ghan)
      if exist('ghan','var') && ~isempty(ghan)
        obj.guihan=ghan;
      end
      obj.LiveModel = F2_LiveModelApp ; % Initially update live model (default)
      obj.LM=copy(obj.LiveModel.LM);
      obj.LM.ModelClasses="PROF";
      obj.ProfModelInd = obj.LM.ModelUniqueID(obj.LM.ControlNames==obj.ProfName) ;
      obj.ProfModelInd = obj.ProfModelInd(1) ;
      obj.UseArchive = true ; % default to getting data from archive from now on
      obj.LiveModel.ModelSource = "Live" ;
      obj.LEMQuadID = obj.LiveModel.LEM.Mags.LM.ModelClassList == "QUAD" ; % Tag quadrupoles in LEM magnet list
%       obj.LiveModel.LEM.Mags.WriteEnable=false; % disable writing to magnets to test
    end
    function DoMatch(obj)
      %DOMATCH Perform matching to profile monitor device based on fitted Twiss parameters and live model
      global BEAMLINE PS
      obj.goodmatch = false ;
      obj.MatchQuadInitVals = []; obj.TwissPreMatch=[]; obj.TwissMatch=[];
      LM_mags=obj.LiveModel.LEM.Mags.LM;
      pele=obj.ProfModelInd;
      betax_design = obj.LiveModel.DesignTwiss.betax(pele) ;
      betay_design = obj.LiveModel.DesignTwiss.betay(pele) ;
      alphax_design = obj.LiveModel.DesignTwiss.alphax(pele) ;
      alphay_design = obj.LiveModel.DesignTwiss.alphay(pele) ;
      betax_fit = obj.TwissFit(1) ;
      betay_fit = obj.TwissFit(2) ;
      alphax_fit = obj.TwissFit(3) ;
      alphay_fit = obj.TwissFit(4) ;
      
      % Form list of matching quads
      iquads = LM_mags.ModelUniqueID(:) < pele & obj.LEMQuadID(:) ;
      if sum(iquads)<double(obj.NumMatchQuads)
        error('Insufficient matching quads available');
      end
      id1=find(iquads,double(obj.NumMatchQuads),'last') ; id1=id1(obj.UseMatchQuad);
      quadps = arrayfun(@(x) BEAMLINE{x}.PS,LM_mags.ModelUniqueID(id1)) ;
      idm=ismember(obj.LiveModel.LEM.Mags.LM.ModelUniqueID,LM_mags.ModelUniqueID(id1)) ;
      bmin = obj.LiveModel.LEM.Mags.BMIN(idm)./10;
      bmax = obj.LiveModel.LEM.Mags.BMAX(idm)./10;
      
      % Get initial PS settings
      ps_init = arrayfun(@(x) PS(x).Ampl,quadps) ;
      obj.MatchQuadInitVals = ps_init.*10 ;
      
      % If matching on PR10571 or WS10561 then get initial Twiss parameters and record them in PVs
      if ismember(obj.ProfName,obj.InitMatchProf)
        i1=1;
      else % match from entrance of first matching quad
        i1=PS(quadps(1)).Element(1);
      end
      
      % Get Twiss parameters at initial match point
      I = TwissToInitial(obj.LiveModel.DesignTwiss,i1,obj.LiveModel.Initial);
      I.Momentum = BEAMLINE{i1}.P ;
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
      M.addMatch(pele,'beta_x',betax_fit,betax_fit/1000);
      M.addMatch(pele,'beta_y',betay_fit,betay_fit/1000);
      M.addMatch(pele,'alpha_x',alphax_fit,1e-3);
      M.addMatch(pele,'alpha_y',alphay_fit,1e-3);
      M.doMatch;
      display(M);
      if any(abs(M.optimVals-[betax_fit betay_fit alphax_fit alphay_fit])>[betax_fit/100 betay_fit/100 0.01 0.01])
        error('Match failed');
      end
      obj.InitMatch=M.initStruc;
      obj.InitMatch.x.NEmit = obj.TwissFit(7)*1e-6 ;
      obj.InitMatch.y.NEmit = obj.TwissFit(8)*1e-6 ;
      [~,T]=GetTwiss(i1,pele,obj.InitMatch.x.Twiss,obj.InitMatch.y.Twiss);
      obj.TwissPreMatch=T;
      
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
      M.addMatch(pele,'beta_x',betax_design,betax_design/1e3);
      M.addMatch(pele,'beta_y',betay_design,betay_design/1e3);
      M.addMatch(pele,'alpha_x',alphax_design,1e-3);
      M.addMatch(pele,'alpha_y',alphay_design,1e-3);
      M.doMatch;
      display(M);
      [~,T]=GetTwiss(i1,pele,obj.InitMatch.x.Twiss,obj.InitMatch.y.Twiss);
      obj.TwissMatch=T;
      
      % Check match in range and store in Mags BDES field
      if any(M.varVals>bmax | M.varVals<bmin)
        for ips=1:length(quadps)
          PS(quadps(ips)).Ampl = ps_init(ips) ;
        end
        error('Required quad match values outside limits');
      end
      if any(abs(M.optimVals-[betax_design betay_design alphax_design alphay_design])>[betax_design/100 betay_design/100 0.01 0.01])
        for ips=1:length(quadps)
          PS(quadps(ips)).Ampl = ps_init(ips) ;
        end
        error('Match failed to converge to required accuracy');
      end
      
      obj.MatchQuadID = idm ;
      obj.LiveModel.LEM.Mags.BDES(idm) = M.varVals * 10 ;
      obj.LiveModel.LEM.Mags.SetBDES_err(false,~idm) ; % set just matching quads to be written
      obj.QuadScanData.twissmatch = M.matchVals ;
      obj.QuadScanData.quadmatch = M.varVals * 10 ;
      
      % Restore pre-matched magnet strengths in model
      for ips=1:length(quadps)
        PS(quadps(ips)).Ampl = ps_init(ips) ;
      end
      
      obj.goodmatch = true ;
      obj.UndoAvailable = false ;
      
    end
    function msg = RestoreMatchingQuads(obj)
      %RESTOREMATCHINGQUADS Undo last operation of WriteMatchQuads
      
      if isempty(obj.MatchQuadInitVals) || isempty(obj.MatchQuadID)
        error('No stored match quad settings to restore');
      end
      obj.LiveModel.LEM.Mags.BDES(obj.MatchQuadID) = obj.MatchQuadInitVals ;
      obj.LiveModel.LEM.Mags.SetBDES_err(false,~obj.MatchQuadID) ;
      obj.LiveModel.LEM.Mags.SetBDES_err(true,obj.MatchQuadID) ;
      msg = obj.LiveModel.LEM.Mags.WriteBDES ;
      obj.LiveModel.Initial = obj.InitRestore;
      obj.goodmatch = false ;
      obj.UndoAvailable = false ;
      
      if obj.ModelSource ~= "Design"
        obj.LiveModel.UpdateModel ;
      end
      
    end
    function msg = WriteMatchingQuads(obj)
      %WRITEMATCHQUADS Write matched quadrupole fields to control system and update any Twiss PVs
      
      % Require DoMatch to have successfully run
      if ~obj.goodmatch
        error('No good match solution found, aborting quad writing');
      end
      
      % Write matched values to control system
      msg = obj.LiveModel.LEM.Mags.WriteBDES ;
      
      obj.UndoAvailable = true ;
      
      if obj.ModelSource ~= "Design"
        obj.LiveModel.UpdateModel ;
      end
      
    end
    function didload=LoadQuadScanData(obj)
      %LOADSCANDATA Load corr plot data for quad scan
      
      didload=false;
      
      obj.TwissMatch=[];
      obj.TwissPreMatch=[];
      obj.InitMatch=[];
      obj.goodmatch = false ;
      obj.QuadScanData = [] ;
      LM_mags=obj.LiveModel.LEM.Mags.LM;
      LM_all=obj.LiveModel.LM;
      
      % If there is a QUAD scan file in the current day's directory, default to loading that
      files = dir(obj.datadir);
      qscanfiles = startsWith(string(arrayfun(@(x) x.name,files,'UniformOutput',false)),"CorrelationPlot-QUAD") | ...
       ~isempty(regexp(string(arrayfun(@(x) x.name,files,'UniformOutput',false)),"CorrelationPlot-LI%d%d:QUAD", 'once')) | ...
       startsWith(string(arrayfun(@(x) x.name,files,'UniformOutput',false)),"Emittance-scan") ;
      if any(qscanfiles)
        [~,latestfile]=max(datenum({files(qscanfiles).date}));
        ifile=find(qscanfiles); ifile=ifile(latestfile);
        [fn,pn]=uigetfile('*.mat','Select Cor Plot File',fullfile(obj.datadir,files(ifile).name));
      else % just offer up current data dir
        [fn,pn]=uigetfile('*.mat','Select Cor Plot File',obj.datadir);
      end
      if ~ischar(fn)
        return
      end
      % Update live model to match data file date
      dd = dir(fullfile(pn,fn));
      obj.ModelDate = datevec(dd.datenum) ;
      dat = load(fullfile(pn,fn));
      if startsWith(string(fn),'Emittance') % data from emittance_gui?
        iscorplot=false;
      else % data from corr plot
        iscorplot=true;
      end
      if iscorplot
        xpv = find(endsWith(string(arrayfun(@(x) x.name,dat.data.profPV(:,1),'UniformOutput',false)),"XRMS"),1) ;
        obj.ProfName = string(regexprep(dat.data.profPV(xpv).name,':XRMS$','')) ; % also updates model
        obj.QuadScanData.QuadName = string(regexprep(dat.data.ctrlPV(1).name,'(:BCTRL)|(:BDES)$','')) ;
      else
        obj.ProfName = string(dat.data.name{1}) ;
        obj.QuadScanData.QuadName = string(dat.data.quadName) ;
      end
      obj.QuadScanData.ProfInd = find(LM_all.ControlNames==obj.ProfName,1) ;
      if iscorplot
        stat = logical([dat.data.status]) ;
      else
        stat = logical([dat.data.use]) ;
      end
      if iscorplot
        obj.QuadScanData.QuadVal = [dat.data.ctrlPV(stat).val] ;
      else
        obj.QuadScanData.QuadVal = dat.data.quadVal(stat) ;
      end
      obj.QuadScanData.nscan = sum(stat) ;
      fitm=["Gaussian" "Asymmetric"];
      if iscorplot
        sz=size(dat.data.beam);
      else
        sz=size(dat.data.beamList) ;
      end
      for ii=1:2
        if iscorplot
          xdat = reshape([dat.data.beam(stat,:,ii).xStat],5,sum(stat),sz(2)) ;
          ydat = reshape([dat.data.beam(stat,:,ii).yStat],5,sum(stat),sz(2)) ;
          xerr = reshape([dat.data.beam(stat,:,ii).xStatStd],5,sum(stat),sz(2)) ;
          yerr = reshape([dat.data.beam(stat,:,ii).yStatStd],5,sum(stat),sz(2)) ;
        else
          xdat = reshape([dat.data.beamList(stat,:,ii).xStat],5,sum(stat),sz(2)) ;
          ydat = reshape([dat.data.beamList(stat,:,ii).yStat],5,sum(stat),sz(2)) ;
          xerr = reshape([dat.data.beamList(stat,:,ii).xStatStd],5,sum(stat),sz(2)) ;
          yerr = reshape([dat.data.beamList(stat,:,ii).yStatStd],5,sum(stat),sz(2)) ;
        end
        if sz(2)>1
          xdat_err=std(squeeze(xdat(3,:,:)),[],2);
          xdat=mean(squeeze(xdat(3,:,:)),2);
          ydat_err=std(squeeze(ydat(3,:,:)),[],2);
          ydat=mean(squeeze(ydat(3,:,:)),2);
        else
          xdat=squeeze(xdat(3,:,:));
          xdat_err=squeeze(xerr(3,:,:));
          ydat=squeeze(ydat(3,:,:));
          ydat_err=squeeze(yerr(3,:,:));
        end
        obj.QuadScanData.x.(fitm(ii)) = xdat ;
        obj.QuadScanData.xerr.(fitm(ii)) = xdat_err ;
        obj.QuadScanData.y.(fitm(ii)) = ydat ;
        obj.QuadScanData.yerr.(fitm(ii)) = ydat_err ;
      end
      obj.QuadScanData.QuadInd = find(LM_mags.ControlNames==obj.QuadScanData.QuadName,1) ;
      if isempty(obj.QuadScanData.QuadInd)
        errordlg(sprintf('Scan Quad (%s) Not found in model',obj.QuadScanData.QuadName),'QUAD not found');
        obj.QuadScanData=[];
        return
      end
      didload=true;
    end
    function WriteEmitData(obj)
      %WRITEENMITDATA Write twiss and emittance data to PVs
      if ~isempty(obj.QuadScanData) && ismember(obj.ProfName,obj.EmitDataProfs)
        lcaPutNoWait(sprintf('%s:BETA_X',obj.ProfName),obj.TwissFit(1));
        lcaPutNoWait(sprintf('%s:ALPHA_X',obj.ProfName),obj.TwissFit(3));
        lcaPutNoWait(sprintf('%s:BMAG_X',obj.ProfName),obj.TwissFit(5));
        lcaPutNoWait(sprintf('%s:EMITN_X',obj.ProfName),obj.TwissFit(7));
        lcaPutNoWait(sprintf('%s:BETA_Y',obj.ProfName),obj.TwissFit(2));
        lcaPutNoWait(sprintf('%s:ALPHA_Y',obj.ProfName),obj.TwissFit(4));
        lcaPutNoWait(sprintf('%s:BMAG_Y',obj.ProfName),obj.TwissFit(6));
        lcaPutNoWait(sprintf('%s:EMITN_Y',obj.ProfName),obj.TwissFit(8));
        % Write initial match conditions to PVs
        if ~isempty(obj.InitMatch) && ismember(obj.ProfName,obj.InitMatchProf) && obj.goodmatch
          lcaPutNoWait(char(obj.LiveModel.Initial_betaxPV),obj.InitMatch.x.Twiss.beta) ;
          lcaPutNoWait(char(obj.LiveModel.Initial_betaxPV),obj.InitMatch.y.Twiss.beta) ;
          lcaPutNoWait(char(obj.LiveModel.Initial_betaxPV),obj.InitMatch.x.Twiss.alpha) ;
          lcaPutNoWait(char(obj.LiveModel.Initial_betaxPV),obj.InitMatch.y.Twiss.alpha) ;
          lcaPutNoWait(char(obj.LiveModel.Initial_emitxPV),obj.InitMatch.x.NEmit*1e6) ;
          lcaPutNoWait(char(obj.LiveModel.Initial_emityPV),obj.InitMatch.y.NEmit*1e6) ;
        end
        obj.InitRestore = obj.LiveModel.Initial ;
        if ~isempty(obj.InitMatch)
          obj.LiveModel.Initial=obj.InitMatch ;
        end
      end
    end
    function ReadEmitData(obj)
      if ismember(obj.ProfName,obj.EmitDataProfs)
        [betax,pvtime] = lcaGet(sprintf('%s:BETA_X',obj.ProfName));
        betay = lcaGet(sprintf('%s:BETA_Y',obj.ProfName));
        alphax = lcaGet(sprintf('%s:ALPHA_X',obj.ProfName));
        alphay = lcaGet(sprintf('%s:ALPHA_Y',obj.ProfName));
        bmagx = lcaGet(sprintf('%s:BMAG_X',obj.ProfName));
        bmagy = lcaGet(sprintf('%s:BMAG_Y',obj.ProfName));
        emitnx = lcaGet(sprintf('%s:EMITN_X',obj.ProfName));
        emitny = lcaGet(sprintf('%s:EMITN_Y',obj.ProfName));
        obj.TwissFitModel=[betax betay alphax alphay bmagx bmagy emitnx emitny];
        obj.TwissFitAnalytic=[betax betay alphax alphay bmagx bmagy emitnx emitny];
        % Set achive date to match PV write date if not already set by reading quad values
        if ~isfield(obj.QuadScanData,'QuadName')
          obj.ModelDate = datevec(F2_common.epics2mltime(pvtime)) ;
          obj.LiveModel.ArchiveDate = obj.ModelDate ;
        end
      end
    end
    function FitQuadScanData(obj)
      %FITQUADSCANDATA Fit twiss parameter to live model using quad scan data
      
      global BEAMLINE PS
      % Find scan quad ID, record PS setting and set to zero for initial calculations
      DesignTwiss = obj.LiveModel.DesignTwiss;
      qid = obj.QuadScanData.QuadInd ;
      LM_mags=obj.LiveModel.LEM.Mags.LM;
      pele=obj.ProfModelInd;
      qele = LM_mags.ModelUniqueID(qid);
      ips = BEAMLINE{qele}.PS;
      ps0 = PS(ips).Ampl;
      k = obj.quadscan_k ;
      x = obj.QuadScanData.x.(obj.ProfFitMethod).*1e-6 ; 
      xerr = obj.QuadScanData.xerr.(obj.ProfFitMethod).*1e-6 ; 
      y = obj.QuadScanData.y.(obj.ProfFitMethod).*1e-6 ; 
      yerr = obj.QuadScanData.yerr.(obj.ProfFitMethod).*1e-6 ; 
      rgamma = LM_mags.ModelP(qid)/0.511e-3;
      
      % Get Twiss at profile device using Model (RmatAtoB)
      qscanvals=obj.QuadScanData.QuadVal./10; % Quad scan values / T
      Rscan=cell(1,length(qscanvals));
      for iscan=1:length(qscanvals)
        PS(ips).Ampl=qscanvals(iscan);
        [~,R]=RmatAtoB(qele,pele);
        Rscan{iscan}=R;
      end
      PS(ips).Ampl=ps0;
      [~,R]=RmatAtoB(qele,pele);
      obj.ModelQuadScan=zeros(2,length(qscanvals));
      if contains(obj.DimSelect,"X")
        xopt = lsqnonlin(@(xx) obj.ModelTwissFitFn(xx,1:2,Rscan,x,xerr),...
          [1 0 obj.LiveModel.Initial.x.NEmit/rgamma],[0.01 -100 0.1e-6/rgamma],...
          [1e4 100 1e-3/rgamma],optimset('Display','iter'));
        emitx = xopt(3) ;
        Sx = emitx .* [xopt(1) -xopt(2);-xopt(2) (1+xopt(2)^2)/xopt(1)] ;
        Sx_prof = R(1:2,1:2) * Sx * R(1:2,1:2)' ; Sx_prof=Sx_prof./emitx ;
        obj.TwissFitModel([1 3 7]) = [Sx_prof(1,1) -Sx_prof(1,2) emitx*rgamma*1e6] ;
        obj.TwissFitModel(5) = bmag(obj.LiveModel.DesignTwiss.betax(pele),obj.LiveModel.DesignTwiss.alphax(pele),...
          Sx_prof(1,1),-Sx_prof(1,2));
        for iscan=1:length(qscanvals)
          S_prof = Rscan{iscan}(1:2,1:2) * Sx * Rscan{iscan}(1:2,1:2)' ; % Sigma matrix at profile monitor location
          obj.ModelQuadScan(1,iscan) = sqrt(S_prof(1,1)).*1e6 ;
        end
      end
      if contains(obj.DimSelect,"Y")
        yopt = lsqnonlin(@(xx) obj.ModelTwissFitFn(xx,3:4,Rscan,y,yerr),...
          [1 0 obj.LiveModel.Initial.x.NEmit/rgamma],[0.01 -100 0.1e-6/rgamma],...
          [1e4 100 1e-3/rgamma],optimset('Display','iter'));
        emity = yopt(3) ;
        Sy = emity .* [yopt(1) -yopt(2);-yopt(2) (1+yopt(2)^2)/yopt(1)] ;
        Sy_prof = R(3:4,3:4) * Sy * R(3:4,3:4)' ; Sy_prof = Sy_prof ./ emity ;
        obj.TwissFitModel([2 4 8]) = [Sy_prof(1,1) -Sy_prof(1,2) emity*rgamma*1e6] ;
        obj.TwissFitModel(6) = bmag(obj.LiveModel.DesignTwiss.betay(pele),obj.LiveModel.DesignTwiss.alphay(pele),...
          Sy_prof(1,1),-Sy_prof(1,2));
        for iscan=1:length(qscanvals)
          S_prof = Rscan{iscan}(3:4,3:4) * Sy * Rscan{iscan}(3:4,3:4)' ; % Sigma matrix at profile monitor location
          obj.ModelQuadScan(2,iscan) = sqrt(S_prof(1,1)).*1e6 ;
        end
      end
      
      % Twiss parameters using analytic approach
      %https://indico.cern.ch/event/703517/contributions/2886144/attachments/1602810/2541739/2018-02-19_Emittance_measurement_with_quadrupole_scan.pdf
      PS(ips).Ampl=0;
      qx=noplot_polyfit(-k,x.^2,2.*x.*xerr,2);
      qy=noplot_polyfit(k,y.^2,2.*y.*yerr,2);
      % sigma matrix at (thin) quad entrance
      [~,R]=RmatAtoB(qele+1,pele); % from center of quad to profile monitor
      % -- x
      d=R(1,2);
      Lq=sum(arrayfun(@(x) BEAMLINE{x}.L,PS(ips).Element));
      A=qx(3); B=qx(2); C=qx(1);
      sig11 = A / (d^2*Lq^2) ;
      sig12 = (B-2*d*Lq*sig11)/(2*d^2*Lq) ;
      sig22 = (C-sig11-2*d*sig12) / d^2 ;
      emit = sqrt(sig11*sig22 - sig12^2) ;
      alpha = - sig12/emit ;
      beta = sig11/emit ;
      % Propogate Twiss back to start of Model quadrupole and then forward to profile monitor location
      S = emit .* [beta -alpha;-alpha (1+alpha^2)/beta] ;
      Rd = [1 Lq/2;0 1] ; S(1,2)=-S(1,2); S(2,1)=-S(2,1);
      S0 = Rd*S*Rd';
      PS(ips).Ampl=ps0;
      [~,R2]=RmatAtoB(qele,pele);
      S0(1,2)=-S0(1,2); S0(2,1)=-S0(2,1);
      S_prof = R2(1:2,1:2)*S0*R2(1:2,1:2)';
      T=S_prof./emit ;
      if contains(obj.DimSelect,"X")
        if ~isreal(T)
          obj.TwissFitAnalytic(2:2:end)=nan;
        else
          obj.TwissFitAnalytic(7) = rgamma * emit * 1e6 ;
          obj.TwissFitAnalytic(1) = T(1,1) ;
          obj.TwissFitAnalytic(3) = -T(1,2) ;
          obj.TwissFitAnalytic(5) = bmag(DesignTwiss.betax(pele),DesignTwiss.alphax(pele),...
            obj.TwissFitAnalytic(1),obj.TwissFitAnalytic(3));
        end
      end
      % -- y
      d=R(3,4);
      A=qy(3); B=qy(2); C=qy(1);
      sig11 = A / (d^2*Lq^2) ;
      sig12 = (B-2*d*Lq*sig11)/(2*d^2*Lq) ;
      sig22 = (C-sig11-2*d*sig12) / d^2 ;
      emit = sqrt(sig11*sig22 - sig12^2) ;
      
      alpha = - sig12/emit ;
      beta = sig11/emit ;
      % Propogate Twiss back to start of Model quadrupole and then forward to profile monitor location
      S = emit .* [beta -alpha;-alpha (1+alpha^2)/beta] ; S(1,2)=-S(1,2); S(2,1)=-S(2,1);
      S0 = Rd*S*Rd'; S0(1,2)=-S0(1,2); S0(2,1)=-S0(2,1);
      S_prof = R2(3:4,3:4)*S0*R2(3:4,3:4)';
      T=S_prof./emit ;
      if contains(obj.DimSelect,"Y")
        if ~isreal(T)
          obj.TwissFitAnalytic(2:2:end)=nan;
        else
          obj.TwissFitAnalytic(8) = rgamma * emit * 1e6 ;
          obj.TwissFitAnalytic(2) = T(1,1) ;
          obj.TwissFitAnalytic(4) = -T(1,2) ;
          obj.TwissFitAnalytic(6) = bmag(obj.LiveModel.DesignTwiss.betay(pele),obj.LiveModel.DesignTwiss.alphay(pele),...
            obj.TwissFitAnalytic(2),obj.TwissFitAnalytic(4));
        end
      end
    end
    function PlotQuadScanData(obj)
      if ~isfield(obj.QuadScanData,'x')
        if ~isempty(obj.guihan)
          obj.guihan.UIAxes.reset;
          obj.guihan.UIAxes_2.reset;
        end
        return
      end
      k = obj.quadscan_k ;
      x = obj.QuadScanData.x.(obj.ProfFitMethod) ; 
      xerr = obj.QuadScanData.xerr.(obj.ProfFitMethod) ; 
      y = obj.QuadScanData.y.(obj.ProfFitMethod) ; 
      yerr = obj.QuadScanData.yerr.(obj.ProfFitMethod) ; 
      if isempty(obj.guihan)
        figure;
        ah1=subplot(2,1,1);
        ah2=subplot(2,1,2);
      else
        ah1=obj.guihan.UIAxes;
        ah2=obj.guihan.UIAxes_2;
      end
      ah1.reset; ah2.reset;
      [q,dq]=noplot_polyfit(k,x.^2,2.*x.*xerr,2);
      errorbar(ah1,abs(k),x.^2,2.*x.*xerr,'ko'); ax=axis(ah1);
      hold(ah1,'on');
      ypl1=(q(1)-dq(1))+(q(2)-dq(2)).*k+(q(3)-dq(3)).*k.^2; 
      ypl2=(q(1)+dq(1))+(q(2)+dq(2)).*k+(q(3)+dq(3)).*k.^2;
      ypl=[ypl1(:) ypl2(:)-ypl1(:)];
      apl=area(ah1,abs(k),ypl); apl(1).FaceColor='none'; apl(1).LineStyle='none'; apl(2).FaceColor=[0.3010 0.7450 0.9330]; apl(2).LineStyle='none'; apl(2).FaceAlpha=0.5;
      if length(obj.ModelQuadScan)==length(k)
        plot(ah1,abs(k),obj.ModelQuadScan(1,:).^2,'r','LineWidth',2);
        if obj.ShowPlotLegend; legend(ah1,["Data" "" "Polynomial Fit" "Model Fit"]); else; legend(ah1,'off'); end
      else
        if obj.ShowPlotLegend; legend(ah1,["Data" "" "Polynomial Fit"]); else; legend(ah1,'off'); end
      end
      xlabel(ah1,sprintf('|k| (%s)',obj.QuadScanData.QuadName)); ylabel(ah1,'\sigma_x^2 [\mum^2]');
      axis(ah1,ax);
      grid(ah1,'on');
      hold(ah1,'off');
      [q,dq]=noplot_polyfit(k,y.^2,2.*y.*yerr,2);
      errorbar(ah2,abs(k),y.^2,2.*y.*yerr,'ko'); ax=axis(ah2);
      hold(ah2,'on');
      ypl1=(q(1)-dq(1))+(q(2)-dq(2)).*k+(q(3)-dq(3)).*k.^2; 
      ypl2=(q(1)+dq(1))+(q(2)+dq(2)).*k+(q(3)+dq(3)).*k.^2;
      ypl=[ypl1(:) ypl2(:)-ypl1(:)];
      apl=area(ah2,abs(k),ypl); apl(1).FaceColor='none'; apl(1).LineStyle='none'; apl(2).FaceColor=[0.3010 0.7450 0.9330]; apl(2).LineStyle='none'; apl(2).FaceAlpha=0.5;
      if length(obj.ModelQuadScan)==length(k)
        plot(ah2,abs(k),obj.ModelQuadScan(2,:).^2,'r','LineWidth',2);
        if obj.ShowPlotLegend; legend(ah2,["Data" "" "Polynomial Fit" "Model Fit"]); else; legend(ah2,'off'); end
      else
        if obj.ShowPlotLegend; legend(ah2,["Data" "" "Polynomial Fit"]); else; legend(ah2,'off'); end
      end
      xlabel(ah2,sprintf('|k| (%s)',obj.QuadScanData.QuadName)); ylabel(ah2,'\sigma_y^2 [\mum^2]');
      axis(ah2,ax);
      grid(ah2,'on');
      hold(ah2,'off');
      if ~isempty(obj.guihan) % Fill emit / bmag values for Model and Analytic fit results
        TA=obj.TwissFitAnalytic; TA(isnan(TA))=0;
        obj.guihan.EditField_2.Value = TA(7) ;
        obj.guihan.EditField.Value = TA(5) ;
        obj.guihan.EditField_4.Value = obj.TwissFitModel(7) ;
        obj.guihan.EditField_3.Value = obj.TwissFitModel(5) ;
        obj.guihan.EditField_6.Value = TA(8) ;
        obj.guihan.EditField_5.Value = TA(6) ;
        obj.guihan.EditField_8.Value = obj.TwissFitModel(8) ;
        obj.guihan.EditField_7.Value = obj.TwissFitModel(6) ;
      end
    end
    function PlotTwiss(obj)
      global BEAMLINE
      if isempty(obj.guihan)
        figure;
        ah=axes;
      else
        ah=obj.guihan.UIAxes2;
      end
      ah.reset;
      if ismember(obj.ProfName,obj.InitMatchProf)
        i1=1;
      else
        i1=obj.MatchQuadModelInd(1);
      end
      i2=obj.ProfModelInd;
      z=arrayfun(@(x) BEAMLINE{x}.Coordi(3),i1:i2);
      txt=string.empty;
      if ~isempty(obj.TwissPreMatch) && contains(obj.DimSelect,"X")
        plot(ah,z,obj.TwissPreMatch.betax(1:end-1),'Color',[0 0.4470 0.7410],'LineStyle','-.'); hold(ah,'on');
        txt(end+1)="\beta_x (current)";
      end
      if ~isempty(obj.TwissMatch) && contains(obj.DimSelect,"X")
        plot(ah,z,obj.TwissMatch.betax(1:end-1),'Color',[0 0.4470 0.7410],'LineStyle','--'); hold(ah,'on');
        txt(end+1)="\beta_x (matched)";
      end
      plot(ah,z,obj.LiveModel.DesignTwiss.betax(i1:i2),'Color',[0 0.4470 0.7410]); hold(ah,'on');
      grid(ah,'on');
      txt(end+1)="\beta_x (design)";
      xlabel(ah,'Z [m]'); ylabel(ah,'\beta [m]');
      if ~isempty(obj.TwissPreMatch) && contains(obj.DimSelect,"Y")
        plot(ah,z,obj.TwissPreMatch.betay(1:end-1),'Color',[0.8500 0.3250 0.0980],'LineStyle','-.'); hold(ah,'on');
        txt(end+1)="\beta_y (current)";
      end
      if ~isempty(obj.TwissMatch) && contains(obj.DimSelect,"Y")
        plot(ah,z,obj.TwissMatch.betay(1:end-1),'Color',[0.8500 0.3250 0.0980],'LineStyle','--'); hold(ah,'on');
        txt(end+1)="\beta_y (matched)";
      end
      plot(ah,z,obj.LiveModel.DesignTwiss.betay(i1:i2),'Color',[0.8500 0.3250 0.0980]); hold(ah,'off');
      axis(ah,'tight'); 
      txt(end+1)="\beta_y (design)";
      if obj.ShowPlotLegend; legend(ah,txt) ; else; legend(ah,'off'); end
      if ~isempty(obj.guihan)
        ax=axis(ah);
        axis(obj.guihan.UIAxes2_2,ax);
        AddMagnetPlotZ(i1,i2,obj.guihan.UIAxes2_2,'replace');
      else
        AddMagnetPlotZ(i1,i2);
      end
    end
    function tab = TwissTable(obj)
      param = ["beta_x";"beta_y";"alpha_x"; "alpha_y";"bmag_x";"bmag_y";"nemit_x";"nemit_y"] ;
      meas = obj.TwissFit ;
      if isfield(obj.QuadScanData,'twissmatch')
        match = [obj.QuadScanData.twissmatch nan nan nan nan];
      else
        match = nan(1,8) ;
      end
      dt=obj.LiveModel.DesignTwiss;
      pi=obj.ProfModelInd;
      I=obj.LiveModel.DesignInitial ;
      design = [dt.betax(pi) dt.betay(pi) dt.alphax(pi) dt.alphay(pi) 1 1 I.x.NEmit*1e6 I.y.NEmit*1e6] ;
      tab=table(param(:),meas(:),match(:),design(:));
      tab.Properties.VariableNames=["Param";"Meas.";"Match";"Design"];
    end
    function tab = MagnetTable(obj)
      global BEAMLINE
      Z = arrayfun(@(x) BEAMLINE{x}.Coordi(3),obj.MatchQuadModelInd) ;
      E = arrayfun(@(x) BEAMLINE{x}.P,obj.MatchQuadModelInd) ;
      obj.LM.ModelClasses="QUAD";
      bdes = obj.LiveModel.LEM.Mags.LM.ModelBDES(ismember(obj.LiveModel.LEM.Mags.LM.ModelUniqueID,obj.MatchQuadModelInd)) ;
      if obj.ModelSource~="Design"
        bact = bdes ;
      else
        bact = obj.LiveModel.LEM.Mags.BDES_cntrl(ismember(obj.LiveModel.LEM.Mags.LM.ModelUniqueID,obj.MatchQuadModelInd)) ;
      end
      bmatch = nan(size(bdes)) ;
      if isfield(obj.QuadScanData,'quadmatch')
        bmatch(obj.UseMatchQuad) = obj.QuadScanData.quadmatch ;
      end
      b_design = arrayfun(@(x) obj.LiveModel.LM.DesignBeamline{x}.B*20,obj.MatchQuadModelInd) ;
      usequad = obj.UseMatchQuad ;
      tab=table(obj.MatchQuadNames(:),string(num2str(Z(:),6)),E(:),bdes(:),bact(:),bmatch(:),b_design(:),usequad(:));
      tab.Properties.VariableNames=["Name";"Z";"E (GeV)";"BDES";"BACT";"BMATCH";"B_DESIGN";"USE"];
    end
    % Get/Set
    function twiss=get.TwissFit(obj)
      switch obj.TwissFitSource
        case "Model"
          twiss=obj.TwissFitModel;
        case "Analytic"
          twiss=obj.TwissFitAnalytic;
      end
    end
    function set.ModelDate(obj,val)
      obj.ModelDate=val;
      obj.ArchiveDate=val;
      obj.LiveModel.ArchiveDate=val;
      if ~isempty(obj.guihan) && obj.ModelSource=="Archive"
        obj.guihan.ModelDateEditField.Value=datestr(val);
      end
    end
    function set.UndoAvailable(obj,val)
      obj.UndoAvailable=val;
      if ~isempty(obj.guihan)
        obj.guihan.UndoButton.Enable=val;
      end
    end
    function set.goodmatch(obj,val)
      obj.goodmatch=val;
      if ~isempty(obj.guihan)
        obj.guihan.SetMatchingQuadsButton.Enable=obj.goodmatch;
      end
    end
    function set.ModelSource(obj,src)
      switch string(src)
        case "Live"
          obj.UseArchive=false;
          if ~isempty(obj.guihan)
            obj.guihan.ModelDateEditField.Value="LIVE";
          end
        case "Archive"
          obj.UseArchive=true;
          if ~isempty(obj.guihan)
            obj.guihan.ModelDateEditField.Value=datestr(obj.ModelDate);
          end
        case "Design"
          if ~isempty(obj.guihan)
            obj.guihan.ModelDateEditField.Value="USE DESIGN";
          end
          obj.UseArchive=false;
      end
      obj.LiveModel.ModelSource=src; % causes Live and Design model updates, Archive waits until explicite UpdateModel call
      obj.ModelSource=src;
      obj.goodmatch=false;
      obj.UndoAvailable=false;
    end
    function kdes = get.quadscan_k(obj)
      if isempty(obj.QuadScanData)
        kdes=[];
        return
      end
      id = obj.QuadScanData.QuadInd ;
      LM_mags=obj.LiveModel.LEM.Mags.LM;
      kdes = obj.QuadScanData.QuadVal./LM_mags.ModelBDES_L(id)./LM_mags.ModelP(id)./LucretiaModel.GEV2KGM ;
    end
    function set.ProfName(obj,name)
      if string(name) == "<Select From Below>" % default startup condition for GUI
        return
      end
      obj.LM.ModelClasses="PROF";
      pind = obj.LM.ModelUniqueID(obj.LM.ControlNames==string(name)) ;
      if isempty(pind)
        error('Profile monitor not found in model')
      else
        obj.ProfModelInd=pind(1);
        obj.ProfName=string(name);
      end
      obj.QuadScanData=[];
      obj.ReadEmitData; % Reads emittance data from PVs if there are any and sets archive date
      if obj.ModelSource ~= "Design"
        obj.LiveModel.UpdateModel ;
      end
      obj.NumMatchQuads=obj.NumMatchQuads; % triggers filling matching quad data
    end
    function set.NumMatchQuads(obj,num)
      obj.NumMatchQuads=num;
      obj.QuadScanData=[];
      obj.LM.ModelClasses="QUAD";
      iquads = obj.LM.ModelUniqueID < obj.ProfModelInd ;
      idq=find(iquads,double(obj.NumMatchQuads),'last') ;
      obj.MatchQuadNames = obj.LM.ControlNames(idq) ;
      obj.MatchQuadModelInd = obj.LM.ModelUniqueID(idq) ;
      obj.MatchQuadID = idq ;
      obj.UseMatchQuad = true(1,length(obj.MatchQuadNames)) ;
    end
  end
  methods(Static,Hidden)
    function opt =  ModelTwissFitFn(x,dims,Rscan,sigma,sigma_err)
      
      S = x(3) .* [x(1) -x(2);-x(2) (1+x(2)^2)/x(1)] ; % Sigma matrix at entrance of scan quad
      sigma_scan = zeros(size(sigma)) ;
      for iscan=1:length(Rscan)
        S_prof = Rscan{iscan}(dims,dims) * S * Rscan{iscan}(dims,dims)' ; % Sigma matrix at profile monitor location
        sigma_scan(iscan) = sqrt(S_prof(1,1)) ;
      end
      opt = (sigma - sigma_scan) ./ sigma_err ;
      
    end
  end
end