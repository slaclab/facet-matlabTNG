classdef F2_MatchingApp < handle & F2_common
  properties
    guihan
    QuadScanData
    ProfFitMethod string {mustBeMember(ProfFitMethod,["Gaussian","Asymmetric"])} = "Asymmetric"
    LiveModel
    Optimizer string {mustBeMember(Optimizer,["fminsearch","lsqnonlin"])} = "lsqnonlin"
    DimSelect string {mustBeMember(DimSelect,["X" "Y" "XY"])} = "XY"
    LM
  end
  properties(SetAccess=private)
    MatchQuadNames string = ["QUAD:IN10:425" "QUAD:IN10:441" "QUAD:IN10:511" "QUAD:IN10:525"]
  end
  properties(SetAccess=private,SetObservable)
    goodmatch logical = false
  end
  properties(SetAccess=private,Hidden)
    InitMatch
    TwissMatch
    TwissPreMatch
    MatchQuadInitVals
    MatchQuadID
    InitRestore
    ProfModelInd
    MatchQuadModelInd
  end
  properties(SetObservable,AbortSet)
    ModelSource string {mustBeMember(ModelSource,["Live" "Archive" "Design"])} = "Live"
  end
  properties(SetObservable)
    ProfName string = "PROF:IN10:571"
    NumMatchQuads uint8 {mustBeGreaterThan(NumMatchQuads,3)} = 4 % Number of quadrupoles upstream of profile monitor to use in match
    UndoAvailable logical = false
  end
  properties(Dependent)
    quadscan_k
    fitdata
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
      obj.LiveModel = F2_LiveModelApp ;
      obj.LM=copy(obj.LiveModel.LM);
      obj.LM.UseModelClasses="PROF";
      obj.ProfModelInd = obj.LM.ModelUniqueID(obj.LM.ControlNames==obj.ProfName) ;
      obj.ProfModelInd = obj.ProfModelInd(1) ;
    end
    function DoMatch(obj)
      %DOMATCH Perform matching to profile monitor device based on fitted Twiss parameters and live model
      global BEAMLINE PS
      obj.goodmatch = false ;
      obj.MatchQuadInitVals = []; obj.TwissPreMatch=[]; obj.TwissMatch=[];
      if ~isefield(obj.QuadScanData,'fit')
        fprintf(2,'No data to fit');
        return
      end
      LM_mags=copy(obj.LiveModel.LEM.Mags.LM);
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
      LM_mags.ModelClasses = "QUAD" ;
      iquads = LM_mags.ModelUniqueID < pele ;
      if sum(iquads)<double(obj.NumMatchQuads)
        error('Insufficient matching quads available');
      end
      id1=find(iquads,double(obj.NumMatchQuads),'last') ;
      quadps = arrayfun(@(x) BEAMLINE{x}.PS,LM_mags.ModelUniqueID(id1)) ;
      idm=ismember(obj.LiveModel.LEM.Mags.LM.ModelUniqueID,LM_mags.ModelUniqueID(id1)) ;
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
      if any(abs(M.matchVals-[betax_fit betay_fit alphax_fit alphay_fit])>[betax_fit/100 betay_fit/100 0.01 0.01])
        error('Match failed');
      end
      obj.InitMatch=M.initStruc;
      [~,T]=GetTwiss(i1,i2,obj.InitMatch.x.Twiss,obj.InitMatch.y.Twiss);
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
      M.addMatch(pele,'alpha_x',alphax_design,1e-3);
      M.addMatch(pele,'alpha_y',alphay_design,1e-3);
      M.addMatch(pele,'beta_x',betax_design,betax_design/1e3);
      M.addMatch(pele,'beta_y',betay_design,betay_design/1e3);
      M.doMatch;
      display(M);
      [~,T]=GetTwiss(i1,i2,obj.InitMatch.x.Twiss,obj.InitMatch.y.Twiss);
      obj.TwissMatch=T;
      
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
      obj.QuadScanData.twissmatch = M.matchVals ;
      obj.QuadScanData.quadmatch = M.varVals ;
      
      obj.goodmatch = true ;
      obj.UndoAvailable = false ;
      
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
      obj.UndoAvailable = false ;
    end
    function msg = WriteMatchQuads(obj)
      %WRITEMATCHQUADS Write matched quadrupole fields to control system and update any Twiss PVs
      
      % Require DoMatch to have successfully run
      if ~obj.goodmatch
        error('No good match solution found, aborting quad writing');
      end
      
      % Write matched values to control system
      msg = obj.LiveModel.LEM.Mags.WriteBDES ;
      
      obj.UndoAvailable = true ;
      
    end
    function LoadQuadScanData(obj)
      %LOADSCANDATA Load corr plot data for quad scan
      
      obj.goodmatch = false ;
      obj.QuadScanData = [] ;
      LM_mags=obj.LiveModel.LEM.Mags.LM;
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
      obj.QuadScanData.QuadInd = find(LM_mags.ControlNames==obj.QuadScanData.QuadName,1) ;
      if isempty(obj.QuadScanData.QuadInd)
        errordlg(sprintf('Scan Quad (%s) Not found in model',obj.QuadScanData.QuadName),'QUAD not found');
        obj.QuadScanData=[];
        return
      end
    end
    function WriteEmitData(obj)
      %WRITEENMITDATA Write twiss and emittance data to PVs
      if ~isempty(obj.QuadScanData) && isfield(obj.QuadScanData,'fit') && ismember(obj.ProfName,obj.EmitDataProfs)
        if contains(obj.DimSelect,"X")
          lcaPutNoWait(spritnf('%s:BETA_X',obj.QuadScanData.ProfName),obj.QuadScanData.fit.betax);
          lcaPutNoWait(spritnf('%s:ALPHA_X',obj.QuadScanData.ProfName),obj.QuadScanData.fit.alphax);
          lcaPutNoWait(spritnf('%s:BMAG_X',obj.QuadScanData.ProfName),obj.QuadScanData.fit.bmagx);
          lcaPutNoWait(spritnf('%s:EMITN_X',obj.QuadScanData.ProfName),obj.QuadScanData.fit.emitnx*1e6);
        end
        if contains(obj.DimSelect,"Y")
          lcaPutNoWait(spritnf('%s:BETA_Y',obj.QuadScanData.ProfName),obj.QuadScanData.fit.betay);
          lcaPutNoWait(spritnf('%s:ALPHA_Y',obj.QuadScanData.ProfName),obj.QuadScanData.fit.alphay);
          lcaPutNoWait(spritnf('%s:BMAG_Y',obj.QuadScanData.ProfName),obj.QuadScanData.fit.bmagy);
          lcaPutNoWait(spritnf('%s:EMITN_Y',obj.QuadScanData.ProfName),obj.QuadScanData.fit.emitny*1e6);
        end
        % Write initial match conditions to PVs
        if ismember(obj.QuadScanData.ProfName,obj.InitMatchProf)
          if contains(obj.DimSelect,"X")
            lcaPutNowWait(char(obj.LiveModel.Initial_betaxPV),obj.InitMatch.x.Twiss.beta) ;
            lcaPutNowWait(char(obj.LiveModel.Initial_betaxPV),obj.InitMatch.y.Twiss.beta) ;
          end
          if contains(obj.DimSelect,"Y")
            lcaPutNowWait(char(obj.LiveModel.Initial_betaxPV),obj.InitMatch.x.Twiss.alpha) ;
            lcaPutNowWait(char(obj.LiveModel.Initial_betaxPV),obj.InitMatch.y.Twiss.alpha) ;
          end
        end
        obj.InitRestore = obj.LiveModel.Initial ;
        obj.LiveModel.Initial=obj.InitMatch ;
      end
    end
    function ReadEmitData(obj)
      if ismember(obj.ProfName,obj.EmitDataProfs)
        obj.QuadScanData.fit.betax = lcaGet(spritnf('%s:BETA_X',obj.QuadScanData.ProfName));
        obj.QuadScanData.fit.betay = lcaGet(spritnf('%s:BETA_Y',obj.QuadScanData.ProfName));
        obj.QuadScanData.fit.alphax = lcaGet(spritnf('%s:ALPHA_X',obj.QuadScanData.ProfName));
        obj.QuadScanData.fit.alphay = lcaGet(spritnf('%s:ALPHA_Y',obj.QuadScanData.ProfName));
        obj.QuadScanData.fit.bmagx = lcaGet(spritnf('%s:BMAG_X',obj.QuadScanData.ProfName));
        obj.QuadScanData.fit.bmagy = lcaGet(spritnf('%s:BMAG_Y',obj.QuadScanData.ProfName));
        obj.QuadScanData.fit.emitnx = lcaGet(spritnf('%s:EMITN_X',obj.QuadScanData.ProfName))*1e-6;
        obj.QuadScanData.fit.emitny = lcaGet(spritnf('%s:EMITN_Y',obj.QuadScanData.ProfName))*1e-6;
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
      LM_mags=obj.LiveModel.LEM.Mags.LM;
      LM_all=obj.LiveModel.LM;
      pele=LM_all.ModelUniqueID(id_prof);
      ele = LM_mags.ModelUniqueID(id);
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
      rgamma = LM_mags.ModelP(id)/0.511e-3;
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
      if contains(obj.DimSelect,"X")
        obj.QuadScanData.fit.betax = T(1,1) ;
        obj.QuadScanData.fit.alphax = -T(1,2) ;
        obj.QuadScanData.fit.bmagx = bmag(DesignTwiss.betax(pele),DesignTwiss.alphax(pele),...
          obj.QuadScanData.fit.betax,obj.QuadScanData.fit.alphax);
      end
      % -- y
      d=R(3,4);
      A=qy(3); B=qy(2); C=qy(1);
      sig11 = A / (d^2*Lq^2) ;
      sig12 = (B-2*d*Lq*sig11)/(2*d^2*Lq) ;
      sig22 = (C-sig11-2*d*sig12) / d^2 ;
      rgamma = LM_mags.ModelP(id)/0.511e-3;
      emit = sqrt(sig11*sig22 - sig12^2) ;
      obj.QuadScanData.fit.emitny = rgamma * emit ;
      alpha = - sig12/emit ;
      beta = sig11/emit ;
      % Propogate Twiss back to start of Model quadrupole and then forward to profile monitor location
      S = emit .* [beta -alpha;-alpha (1+alpha^2)/beta] ;
      S0 = Rd*S*Rd';
      S_prof = R2(3:4)*S0*R2(3:4)';
      T=S_prof./emit ;
      if contains(obj.DimSelect,"Y")
        obj.QuadScanData.fit.betay = T(1,1) ;
        obj.QuadScanData.fit.alphay = -T(1,2) ;
        obj.QuadScanData.fit.bmagy = bmag(obj.LiveModel.DesignTwiss.betay(pele),obj.LiveModel.DesignTwiss.alphay(pele),...
          obj.QuadScanData.fit.betay,obj.QuadScanData.fit.alphay);
      end
    end
    function PlotQuadScanData(obj)
      if ~isefield(obj.QuadScanData,'x')
        return
      end
      k = obj.quadscan_k ;
      x = obj.QuadScanData.x.(obj.ProfFitMethod) ;
      xerr = obj.QuadScanData.xerr(obj.ProfFitMethod) ;
      y = obj.QuadScanData.y.(obj.ProfFitMethod) ;
      yerr = obj.QuadScanData.yerr.(obj.ProfFitMethod) ;
      if isempty(obj.guihan)
        figure;
        fh=subplot(2,1,1);
        plot_polyfit(fh);
        plot_polyfit(k,x.^2,2.*x.*xerr,2,sprintf('K (%s)',obj.QuadScanData.QuadName),'\sigma_x^2','','\mum^2');
        fh=subplot(2,1,2);
        plot_polyfit(fh);
        plot_polyfit(k,y.^2,2.*y.*yerr,2,sprintf('K (%s)',obj.QuadScanData.QuadName),'\sigma_y^2','','\mum^2');
      else
        plot_polyfit(obj.guihan.UIAxes);
        plot_polyfit(k,x.^2,2.*x.*xerr,2,sprintf('K (%s)',obj.QuadScanData.QuadName),'\sigma_x^2','','\mum^2');
        plot_polyfit(obj.guihan.UIAxes_2);
        plot_polyfit(k,y.^2,2.*y.*yerr,2,sprintf('K (%s)',obj.QuadScanData.QuadName),'\sigma_y^2','','\mum^2');
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
      yyaxis(ah,'left');
      i1=obj.MatchQuadModelInd(1); i2=obj.ProfModelInd;
      z=arrayfun(@(x) BEAMLINE{x}.Coordi(3),i1:i2);
      txt=string.empty;
      if ~isempty(obj.TwissPreMatch)
        plot(ah,z,obj.TwissPreMatch.betax); hold(ah,'on');
        txt(end+1)="\beta_x (current)";
      end
      if ~isempty(obj.TwissMatch)
        plot(ah,z,obj.TwissMatch.betax); hold(ah,'on');
        txt(end+1)="\beta_x (matched)";
      end
      plot(ah,z,obj.LiveModel.DesignTwiss.betax); hold(ah,'off');
      txt(end+1)="\beta_x (design)";
      xlabel(ah,'Z [m]'); ylabel(ah,'\beta_x [m]');
      yyaxis(ah,'right');
      if ~isempty(obj.TwissPreMatch)
        plot(ah,z,obj.TwissPreMatch.betay); hold(ah,'on');
        txt(end+1)="\beta_y (current)";
      end
      if ~isempty(obj.TwissMatch)
        plot(ah,z,obj.TwissMatch.betay); hold(ah,'on');
        txt(end+1)="\beta_y (matched)";
      end
      plot(ah,z,obj.LiveModel.DesignTwiss.betay); hold(ah,'off');
      txt(end+1)="\beta_y (design)";
      ylabel(ah,'\beta_y [m]');
      yyaxis(ah,'left');
      legend(ah,txt) ;
      AddMagnetPlotZ(i1,i2,ah);
    end
    function tab = TwissTable(obj)
      param = ["beta_x";"beta_y";"alpha_x"; "alpha_y";"bmag_x";"bmag_y";"nemit_x";"nemit_y"] ;
      meas = struct2array(obj.QuadScanData.fit) ;
      if isfield(obj.QuadScanData,'twissmatch')
        match = [obj.QuadScanData.twissmatch nan nan nan nan];
      else
        match = nan(1,6) ;
      end
      dt=obj.LiveModel.DesignTwiss;
      pi=obj.ProfModelInd;
      I=obj.LiveModel.Initial ;
      design = [dt.betax(pi) dt.betay(pi) dt.alphax(pi) dt.alphay(pi) 1 1 I.x.NEmit I.y.NEmit] ;
      tab=table(param(:),meas(:),match(:),design(:));
      tab.Properties.VariableNames=["beta_x";"beta_y";"alpha_x"; "alpha_y";"bmag_x";"bmag_y";"nemit_x";"nemit_y"];
    end
    function tab = MagnetTable(obj)
      global BEAMLINE
      Z = arrayfun(@(x) BEAMLINE{x}.Coordi(3),obj.MatchQuadModelInd) ;
      E = arrayfun(@(x) BEAMLINE{x}.P,obj.MatchQuadModelInd) ;
      obj.LM.ModelClasses="QUAD";
      bdes = obj.LM.BDES_cntrl(obj.MatchQuadID) ;
      bact = obj.LM.BDES_cntrl(obj.MatchQuadID) ;
      if isfield(obj.QuadScanData,'quadmatch')
        bmatch = obj.QuadScanData.quadmatch ;
      else
        bmatch = nan(size(bdes)) ;
      end
      b_design = arrayfun(@(x) obj.LiveModel.DesignBEAMLINE(x).B*20,obj.MatchQuadModelInd) ;
      tab=table(obj.MatchQuadNames(:),Z(:),E(:),bdes(:),bact(:),bmatch(:),b_design(:));
      tab.Properties.VariableNames=["Name";"Z";"E (GeV)";"BDES";"BACT";"BMATCH";"B_DESIGN"];
    end
    % Get/Set
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
    function fdata = get.fitdata(obj)
      if isfield(obj.QuadScanData,'fit') && ~isempty(obj.QuadScanData.fit)
        fdata=obj.QuadScanData.fit;
      else
        fdata=[];
      end
    end
    function set.ModelSource(obj,src)
      switch string(src)
        case "Live"
          obj.UseArchive=false;
        case "Archive"
          obj.UseArchive=true;
        case "Design"
          obj.UseArchive=false;
      end
      obj.LiveModel.ModelSource=src;
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
      kdes = obj.QuadScanData.QuadVal./LM_mags.ModelL(id)./obj.LM.ModelP(id)./PhysConstants.GEV2TM ;
    end
    function set.ProfName(obj,name)
      pind = obj.LM.ModelUniqueID(obj.LM.ControlNames==string(name)) ;
      if isempty(pind)
        error('Profile monitor not found in model')
      else
        obj.ProfModelInd=pind(1);
        obj.ProfName=string(name);
      end
      obj.QuadScanData=[];
      obj.ReadEmitData; % Reads emittance data from PVs if there are any
      obj.NumMatchQuads=obj.NumMatchQuads; % triggers filling matching quad data
    end
    function set.NumMatchQuads(obj,num)
      obj.NumMatchQuads=num;
      obj.LM.ModelClasses="QUAD";
      iquads = obj.LM.ModelUniqueID < obj.ProfModelInd ;
      idq=find(iquads,double(obj.NumMatchQuads),'last') ;
      obj.MatchQuadNames = obj.LM.ControlNames(idq) ;
      obj.MatchQuadModelInd = obj.LM.ModelUniqueID(idq) ;
      obj.MatchQuadID = idq ;
    end
  end
end