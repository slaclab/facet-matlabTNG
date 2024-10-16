classdef F2_MDLFFApp < handle
  %F2_MDLFF FACET Main Drive line feed-forward
  properties(Transient)
    pvenv PV % Temp/pressure PVs
    pvgld PV % GOLD PVs
    pvpmdl PV % PMDL PVs
    pvpmdl_alt PV % PMDL PVs
    pvpred PV % Prediction PV list
    pvlist PV % List of all PVs
    pvs % Structure of all PVs
    pv11 PV % LI11_1 LI11_2 phase adjust PVs
  end
  properties(Transient,Hidden)
    cntx
  end
  properties
    Gain = 1 % Feed-forward Gain
    Period = 300 % Feed-forward action period (s)
    mode(1,9) = [0 0 0 0 0 15 0 0 0].*0+15 % 0= use own station model, >0= use different sector model as delta, <0 compute only
    use(1,9) logical = true(1,9) % Feed-forward active for these sectors
    data % archive data : raw = timetable of all PVs, proc = processed data cell array of timetables for each sector
    RegressionModel string {mustBeMember(RegressionModel,["Linear","NN","TS"])} = "Linear"
    ModelDate(2,6) % Timestamps for trained model
    SmoothSpan {mustBePositive} = 60 % Smoothing span in minutes used when processing archive data
    DataSpan {mustBePositive} = 12 % Data span in hours when getting data, prior to smoothing, to calculate feedforward phases
    TempLimits(1,2) = [35,105] % Temperture limits (degF) - force saturation at limits
    PresLimits(1,2) = [980 1035] % Pressure limits (mbar) - force saturation at limits
    EnvOmit string = ["MCCTemp" "S20Temp" "MDL_temp_11" "MDL_temp_12" "MDL_temp_13" "MDL_temp_14" "MDL_temp_16" "MDL_temp_17" "MDL_temp_18" "MDL_temp_19"] % sensor data to omit
    Live logical = false % Object is "Live" : writing to control PVs enabled
  end
  properties(SetObservable,AbortSet)
    usealt logical = false % Use alternate configuration
  end
  properties(SetAccess=private,Hidden)
    regmodel
    MDL_temps
    Pressure
    MCCTemp
    S20Temp
    state string = "Stopped"
    pmdl0 % starting pmdl values
    pp0 % predicted gold phase start values
  end
  properties(Access=private)
    to % timer object
    clock0
  end
  properties(Constant)
    secs=11:19 % Sectors to consider
    UseDummyPMDL logical = false
    StatePV = 'SIOC:SYS1:ML01:AO489' ; % running/stopped state
    WatcherPV = 'F2:WATCHER:MDLFF_STAT' ;
    params = ["Pressure" "MCCTemp" "S20Temp" "MDL_temp_11" "MDL_temp_12" "MDL_temp_13" "MDL_temp_14" "MDL_temp_15" "MDL_temp_16" "MDL_temp_17" "MDL_temp_18" "MDL_temp_19"]
  end
  methods
    function obj = F2_MDLFFApp(cmd)
      %F2_MDLFF FACET Main Drive line feed-forward
      
      % Load existing data
      if exist('cmd','var')
        switch lower(cmd)
          case "init"
            % Don't load a pre-defined model
          otherwise % Argument passed to constructor should be a valid model name
            ld = load(F2_common.confdir + "/F2_MDLFF/" + cmd) ;
            obj = ld.MDL;
        end
      else % Load model from config directory according to name in PV
        mdlname = string(lcaGet('SIOC:SYS1:ML01:AO488.DESC')) ;
        ld = load(F2_common.confdir + "/F2_MDLFF/" + mdlname) ;
        obj = ld.MDL;
      end
      
      % Re-assign mode and EnvOmit
      obj.mode = [15 15 15 15 15 15 15 15 15];
      
      % - EPICS PVs
      obj.cntx=PV.Initialize(PVtype.EPICS);
      % Environmental PVs (pressure and temperatures).
      obj.pvenv(1) = PV(obj.cntx,'Name',"Pressure",'pvname',"ROOM:BSY0:1:OUTSIDEPRES",'units',"mbar") ;
      obj.pvenv(2) = PV(obj.cntx,'Name',"MCCTemp",'pvname',"ROOM:BSY0:1:OUTSIDETEMP",'units',"deg") ;
      obj.pvenv(3) = PV(obj.cntx,'Name',"S20Temp",'pvname',"ROOM:LI20:1:OUTSIDE_TEMP ",'monitor',true) ;
      for n=1:length(obj.secs)
        obj.pvenv(3+n) = PV(obj.cntx,'Name',"MDL_temp_"+obj.secs(n),'pvname',"LI"+obj.secs(n)+":ASTS:M_D_LINE",'units',"deg") ; 
      end
      % PVs with GOLD phases for each sub-booster:
      for n=1:length(obj.secs)
        obj.pvgld(n) = PV(obj.cntx,'Name',"GOLD_"+obj.secs(n),'pvname',"LI"+obj.secs(n)+":SBST:1:GOLD",'units',"deg") ;
      end
      % PVs with SCP PMDL secondary:
      for n=1:length(obj.secs)
        if obj.UseDummyPMDL
          obj.pvpmdl(n) = PV(obj.cntx,'Name',"PMDL_"+obj.secs(n),'pvname',"SIOC:SYS1:ML01:AO"+(468+n),'monitor',true) ;
          obj.pvpmdl_alt(n) = PV(obj.cntx,'Name',"PMDL_"+obj.secs(n),'pvname',"SIOC:SYS1:ML01:AO"+(477+n),'monitor',true) ;
        else
          obj.pvpmdl(n) = PV(obj.cntx,'Name',"PMDL_"+obj.secs(n),'pvname',"LI"+obj.secs(n)+":SBST:1:PMDL",'units',"deg") ;
        end
      end
      % Grouped PV lists
      obj.pvlist = [obj.pvenv obj.pvgld obj.pvpmdl] ;
      obj.pvs = struct(obj.pvlist) ;
      % 11-1 / 11-2 phase PVs
      obj.pv11(1) = PV(obj.cntx,'Name',"K11_1",'pvname',"LI11:KLYS:11:PHAS") ;
      obj.pv11(2) = PV(obj.cntx,'Name',"K11_2",'pvname',"LI11:KLYS:21:PHAS") ;
      
      if ~exist('cmd','var') % If not instantiating with a command, assume this is being run as watcher app and start feedback, else require manual start
        obj.run();
      end
    end
    function run(obj)
      obj.pmdl0=[]; % Reset initial PMDL state
      obj.pp0=[]; % Reset initial predicted phase state
      obj.state = "Running" ;
      obj.to=timer('Period',1,'ExecutionMode','fixedRate','TimerFcn',@(~,~) obj.RunFunc,'StopFcn',@(~,~) obj.StopFunc);
      obj.Live=true;
      start(obj.to);
      lcaPutNoWait(obj.StatePV,1);
    end
    function reset(obj)
      %RESET Reset all PMDL PVs to zero
      aidapva;
      for n=1:length(obj.secs)
        if obj.UseDummyPMDL
          if obj.usealt
            caput(obj.pvpmdl_alt(n),0);
          else
            caput(obj.pvs.(sprintf("PMDL_%d",obj.secs(n))),0);
          end
        else
          pvaRequest(sprintf('SBST:LI%d:1:PMDL',obj.secs(n))).set(0);
        end
      end
    end
    function stop(obj)
      stop(obj.to);
      obj.Live=false;
      lcaPutNoWait(obj.StatePV,0);
    end
    function GenMoniPV(obj)
      obj.pvpred=[];
      if ~obj.usealt
        pv0=450;
      else
        pv0=459;
      end
      n=0;
      for isec=obj.secs
        n=n+1;
        obj.pvpred(n) = PV(obj.cntx,'Name',"GoldPred_"+isec,'pvname',"SIOC:SYS1:ML01:AO"+(pv0+n),'mode',"rw") ;
      end
    end
    function GetArchiveData(obj,dateinfo)
      %GETARCHIVEDATA Fetch all data from archiver
      %GetArchiveData(ndays)
      % Fetch data going back ndays from now
      %
      %GetArchiveData([date1;date2])
      % Fetch data from date1 to date2 (in datevec format- i.e. provide [2x6] array)
      if length(dateinfo)==1
        ad = [datevec(datetime(clock)-days(dateinfo));datevec(now)];
      else
        ad = dateinfo ;
      end
      obj.pvlist.pset('ArchiveDate',ad);
      obj.pvlist.pset('UseArchive',2);
      caget(obj.pvlist);
      ttA=obj.pvlist.ArchiveSync('minutely');
      obj.data.raw=ttA;
      obj.ModelDate=ad;
    end
    function ProcArchiveData(obj)
      %PROCARCHIVEDATA Process archive data
      
      if isempty(obj.data) || ~isfield(obj.data,'raw')
        error('No archive data fetched- use GetArchiveData method');
      end
      ttA=obj.data.raw;
      iptemps=startsWith(ttA.Properties.VariableNames,"MDL_temp"); iptemps(1:3)=true;
      tt=cell(1,length(obj.secs));
      n=0;
      for isec=obj.secs
        n=n+1;
        [~,ii]=unique(ttA.("GOLD_"+isec),'stable');
        ttS=smoothdata(ttA,'sgolay',duration(minutes(obj.SmoothSpan))); % Apply smoothing
        tt{n}=[ttS(ii,iptemps) timetable(ttA.Time(ii),ttA.("GOLD_"+isec)(ii)-ttA.("PMDL_"+isec)(ii))];
        tt{n}.Properties.VariableNames(end) = "GOLDPHA_"+isec ;
        tt{n}.("GOLDPHA_"+isec)=rad2deg(unwrap(deg2rad(tt{n}.("GOLDPHA_"+isec))));
        ttA.("GOLD_"+isec)=rad2deg(unwrap(deg2rad(ttA.("GOLD_"+isec))));
        obj.data.proc=tt;
      end
    end
    function fhan=plot(obj,cmd,fhan)
      %PLOT Various plot functions
      if ~exist('fhan','var') && ~isempty(fhan)
        fhan=figure;
      end
      if startsWith(cmd,"ArchiveData")
        ttA=obj.data.raw;
        isec=double(regexp(cmd,"ArchiveData_(\d+)",'once','tokens'));
        irw=startsWith(ttA.Properties.VariableNames,"MDL_temp"); irw(1:3)=true;
        tt=timetable(ttA.Time,ttA.("GOLD_"+isec)-ttA.("PMDL_"+isec));
        tt.Properties.VariableNames(end) = "GOLDPHA_"+isec ;
        s=stackedplot(fhan,[ttA(:,irw) tt]);
        ax = findobj(s.NodeChildren, 'Type','Axes');
        n=0;
        if obj.SmoothSpan>0
          ttS=smoothdata(ttA,'sgolay',duration(minutes(obj.SmoothSpan)));
        elseif obj.SmoothSpan==0
          ttS=smoothdata(ttA,'sgolay');
        else
          ttS=ttA;
        end
        for iax=length(ax):-1:2
          n=n+1;
          hold(ax(iax),'on');
          plot(ax(iax),ttS.Time,ttS{:,n},'r');
          hold(ax(iax),'off');
        end
        ttgld=obj.data.proc{isec-10}(:,end);
        hold(ax(1),'on');
        plot(ax(1),ttgld.Time,ttgld{:,end},'r*');
        hold(ax(1),'off');
      elseif cmd=="TrainData"
        for n=1:length(obj.secs)
          subplot(length(obj.secs),1,n,'Parent',fhan);
          plot(obj.data.Train.t{n},obj.data.Train.Phi{n},'*',obj.data.Train.t{n},obj.data.Train.pred{n},'-'), title("LI "+obj.secs(n)+" SBST GOLD");
        end
      elseif cmd=="PredData"
        tt=obj.data.pred.ttA;
        s=stackedplot(fhan,tt);
        ax = findobj(s.NodeChildren, 'Type','Axes');
        n=0;
        for iax=length(ax):-1:1
          n=n+1;
          hold(ax(iax),'on');
          plot(ax(iax),obj.data.pred.ttS.Time,obj.data.pred.ttS{:,n},'r');
          hold(ax(iax),'off');
        end
      elseif cmd=="PredPha"
        for n=1:length(obj.secs)
          subplot(length(obj.secs),1,n,'Parent',fhan);
          plot(obj.data.pred.ttA.Time,obj.data.pred.pha_pred(:,n)), title("LI "+obj.secs(n)+" SBST GOLD");
        end
      end
    end
    function Train(obj)
      %TRAIN Train regression model based on Archive Data taken with GetArchiveData method
      
      obj.regmodel={};
      obj.data.Train=[];
      n=0;
      for isec=obj.secs
        n=n+1;
        % Merge different data sets
        dt=obj.data.proc{n};
        sz=size(dt);
        for icol=1:sz(2)
          dt{:,icol}=dt{:,icol}-median(dt{:,icol});
        end
        if isfield(obj.data,'inc')
          for i_inc=1:length(obj.data.inc)
            try
              dtn = obj.data.inc{i_inc}{n} ;
              sz=size(dtn);
              for icol=1:sz(2)
                dtn{:,end}=dtn{:,icol}-dtn{1,icol} ;
              end
              dt=vertcat(dt,dtn);
            catch
              error('Incompatible data sets in data.inc');
            end
          end
        end
        dt=sortrows(dt);
        % Data columns to use
        Duse = find(~ismember(dt.Properties.VariableNames,obj.EnvOmit)) ;
        % - Unpack data
        [D,mi] = rmmissing( dt{:,Duse(1:end-1)} ) ;
        Phi = rmmissing( dt{:,end} ) ;
        t = dt.Time; t(mi)=[];
        % train regression model
        obj.data.Train.t{n}=t;
        obj.data.Train.Phi{n}=Phi;
        switch obj.RegressionModel
          case "Linear"
            obj.regmodel{n} = fitlm(D,Phi,'RobustOpts', 'on') ;
            obj.data.Train.pred{n}=obj.regmodel{n}.predict;
            cn=obj.regmodel{n}.CoefficientNames ;
            cnames=obj.params(~ismember(obj.params,obj.EnvOmit)) ;
            for ipar=2:length(cnames)
              cn{ipar}=cnames(ipar-1);
            end
            obj.regmodel{n}.CoefficientNames = cn ;
          case "NN"
            trainFcn = 'trainbr';  % Bayesian Regularization backpropagation.
            hiddenLayerSize = 15;
            net = fitnet(hiddenLayerSize,trainFcn);
            net.divideParam.trainRatio = 70/100;
            net.divideParam.valRatio = 20/100;
            net.divideParam.testRatio = 10/100;
            net = train(net,D',Phi');
            obj.regmodel{n}=net;
            obj.data.Train.pred{n}=obj.regmodel{n}(D');
          case "TS"
            X = tonndata(D,false,false);
            T = tonndata(Phi,false,false);
            trainFcn = 'trainbr';
            inputDelays = 1:2;
            hiddenLayerSize = 20;
            net = timedelaynet(inputDelays,hiddenLayerSize,trainFcn);
            [x,xi,ai,t] = preparets(net,X,T);
            net.divideParam.trainRatio = 70/100;
            net.divideParam.valRatio = 15/100;
            net.divideParam.testRatio = 15/100;
            net = train(net,x,t,xi,ai);
            obj.regmodel{n}=net;
            obj.data.Train.pred{n}=net(x,xi,ai);
        end
      end
      
    end
    function pha = Predict(obj,returnvec,when)
      %PREDICT Predict sector GOLD phases using trained model
      %Predict([returnvec,when])
      % returnvec=true : return array of predictions [nsectors,ndata] (default=false)
      % when=datevec : prediction time (get data obj.DataSpan hours back from when) (default=now)
      if isempty(obj.pvpred)
        obj.GenMoniPV();
      end
      if ~exist('returnvec','var') || isempty(returnvec)
        returnvec=false;
      end
      if ~exist('when','var')
        when=datevec(now);
      end
      % Get data and process (smooth)
      ad = [datevec(datetime(when)-hours(obj.DataSpan));when];
      obj.pvenv.pset('ArchiveDate',ad);
      obj.pvenv.pset('UseArchive',2);
      caget(obj.pvenv);
      tt=obj.pvenv.ArchiveSync('minutely');
      ttS=smoothdata(tt,'sgolay',duration(minutes(obj.SmoothSpan))); % Apply smoothing
      % Apply limits
      ttS.Pressure(ttS{:,1}<obj.PresLimits(1))=obj.PresLimits(1);
      ttS.Pressure(ttS{:,1}>obj.PresLimits(2))=obj.PresLimits(2);
      for ii=2:width(ttS)
        ttS{ttS{:,ii}<obj.TempLimits(1),ii}=obj.TempLimits(1);
        ttS{ttS{:,ii}>obj.TempLimits(2),ii}=obj.TempLimits(2);
      end
      if returnvec
        pha=zeros(height(ttS),length(obj.secs));
      else
        pha=zeros(1,length(obj.secs));
      end
      if obj.Live
        lcaPutNoWait(obj.WatcherPV,1) ; % Keep watcher happy
      end
      % Data columns to use
      Duse = ~ismember(ttS.Properties.VariableNames,obj.EnvOmit) ;
      % - Unpack data
      D = rmmissing( ttS{:,Duse} ) ;
      D = D - median(D) ;
      if ~returnvec
        D=D(end,:);
      end
      for n=1:length(obj.secs)
        if obj.mode(n)==0
          nm=n;
        else
          nm=obj.mode(n)-10;
        end
        if obj.RegressionModel=="NN"
          pha(:,n) = obj.regmodel{nm}(D');
        else
          pha(:,n) = obj.regmodel{nm}.predict(D) ;
        end
        if obj.Live
          caput(obj.pvpred(n),pha(end,n));
        end
      end
      obj.data.pred.ttA = tt ;
      obj.data.pred.ttS = ttS ;
      obj.data.pred.pha_pred = pha ;
    end
    function WritePMDL(obj)
      %WRITEPMDL Write PMDL to controls based on current predictions
      aidapva;
      obj.pvlist.pset('UseArchive',0);
      firstcall=false;
      if isempty(obj.pmdl0)
        firstcall=true;
        obj.pmdl0=zeros(1,length(obj.secs));
        obj.pp0=zeros(1,length(obj.secs));
      end
      pp=obj.Predict;
      fprintf('%s New PMDL settings:\n',datestr(now));
      pmdl_new=zeros(1,length(obj.secs));
      for n=1:length(obj.secs)
        if ~obj.use(n)
          continue
        end
        pmdl_current = caget(obj.pvs.(sprintf("PMDL_%d",obj.secs(n)))) ;
        if obj.mode(n)==0
          if firstcall
            obj.pmdl0(n) = pmdl_current ;
            obj.pp0(n) = pp(n) ;
          end
          pmdl = obj.pmdl0(n) - (pp(n)-obj.pp0(n)) ;
        elseif obj.mode(n)>0
          if firstcall
            obj.pmdl0(n) = pmdl_current ;
            obj.pp0(n) = pp(obj.mode(n)-10) ;
          end
          pmdl = obj.pmdl0(n) - ((pp(obj.mode(n)-10) - obj.pp0(n)) *n*0.2);
        end
        pmdl_new(n) = pmdl_current ;
        if obj.use(n)
          dpmdl = pmdl - pmdl_current ;
          if abs(dpmdl)>1 % Limit max change per write cycle
            errmess="PMDL change exceeds limit for SBST "+obj.secs(n)+" ("+dpmdl+")"+" , limiting to 1 deg";
            F2_common.LogMessage("F2_MDLFF",errmess);
            fprintf(2,errmess);
            dpmdl=double(sign(dpmdl))/obj.Gain;
          end
          pmdl_new(n) = pmdl_current + (dpmdl*obj.Gain) ;
          fprintf('LI%d: %g\n',obj.secs(n),pmdl_new(n));
          if obj.Live
            if obj.UseDummyPMDL
              if obj.usealt
                caput(obj.pvpmdl_alt(n),pmdl_new);
              else
                caput(obj.pvs.(sprintf("PMDL_%d",obj.secs(n))),pmdl_new(n));
              end
            else
%               lcaPutNoWait(obj.WatcherPV,1) ; % Keep watcher happy
%               pvaRequest(sprintf('SBST:LI%d:1:PMDL',obj.secs(n))).set(pmdl_new);
            end
          end
          % If setting LI11 sub-booster PMDL, then fix 11-1 & 11-2 so they don't trim
%           if n==length(obj.secs) && any(obj.secs(n)==11)
%             p11_1 = caget(obj.pv11(1)); p11_2 = caget(obj.pv11(2)) ;
%             pvaRequest('KLYS:LI11:11:PDES').set(p11_1) ;
%             pvaRequest('KLYS:LI11:21:PDES').set(p11_2) ;
%           end
        end
      end
      if obj.Live && ~obj.UseDummyPMDL
        lcaPutNoWait(obj.WatcherPV,1) ; % Keep watcher happy
        % Write new PMDL values
        builder = pvaRequest('KLYSTRONSET:PMDL');
        jstruct = AidaPvaStruct();
        jstruct.put('names', { 'SBST:LI11:1', 'SBST:LI12:1' 'SBST:LI13:1' 'SBST:LI14:1' 'SBST:LI15:1' 'SBST:LI16:1' 'SBST:LI17:1' 'SBST:LI18:1' 'SBST:LI19:1'});
        jstruct.put('values', num2cell(pmdl_new) );
        builder.set(jstruct);
      end
    end
    function [gold,gold_err]=PerfEval(obj,ArchiveDates)
      if isempty(obj.pvpred)
        obj.GenMoniPV();
      end
      obj.pvlist.pset('ArchiveDate',ArchiveDates);
      obj.pvlist.pset('UseArchive',2);
      caget(obj.pvlist);
      tt=obj.pvlist.ArchiveSync('minutely') ;
      figure
      n=0;
      gold_err=zeros(1,length(obj.secs));
      gold=cell(1,length(obj.secs));
      for isec=obj.secs
        [act,mi] = rmmissing(rad2deg(unwrap(deg2rad(tt.("GOLD_"+isec))))) ;
        t = tt.Time; t(mi)=[];
        [~,ii]=unique(act,'stable');
        act=act-act(1);
        act=act(ii); t=t(ii);
        subplot(length(obj.secs),4,[n*4+1,n*4+3]);
        plot(t,act); title(sprintf('SBST %d GOLD Phase Error [deg]',isec));
%         ax=gca;
%         ylim=ax.YLim;
        hold on
        [pmdl,mi] = rmmissing( tt.("PMDL_"+isec) ) ;
        t = tt.Time; t(mi)=[];
        plot(t,pmdl-pmdl(1),'k--');
        hold off
%         ax.YLim=ylim;
        subplot(length(obj.secs),4,n*4+4);
        [~,ii]=unique(act,'stable');
        err=act;
        histogram(err); title(sprintf('N = %d RMS Error = %.1f deg',length(ii),std(err)));
        gold_err(n+1)=std(err);
        gold{n+1}=act;
        n=n+1;
      end
    end
    function [dpha_pred,pha_err] = PredictEval(obj,dates,fhan)
      %PREDICTEVAL Test prediction using model over given datevecs
      % dates = [2x6] array of 2 datevecs [from;to]
      
      if ~exist('fhan','var')
        fhan=figure;
      end
      
      % Get data and process (smooth)
      obj.pvlist.pset('ArchiveDate',dates);
      obj.pvlist.pset('UseArchive',2);
      caget(obj.pvlist);
      tt=obj.pvlist.ArchiveSync('minutely');
      ttD=smoothdata(tt(:,1:12),'sgolay',duration(minutes(obj.SmoothSpan))); % Apply smoothing to env data
      
      % Apply limits
      ttD.Pressure(ttD{:,1}<obj.PresLimits(1))=obj.PresLimits(1);
      ttD.Pressure(ttD{:,1}>obj.PresLimits(2))=obj.PresLimits(2);
      for ii=2:width(ttD)
        ttD{ttD{:,ii}<obj.TempLimits(1),ii}=obj.TempLimits(1);
        ttD{ttD{:,ii}>obj.TempLimits(2),ii}=obj.TempLimits(2);
      end
      % Data columns to use
      Duse = ~ismember(ttD.Properties.VariableNames,obj.EnvOmit) ;
      % - Unpack data
      D = rmmissing( ttD{:,Duse} ) ;
      D = D - median(D) ;
      pha_pred=zeros(height(tt),length(obj.secs));
      pha_act=pha_pred;
      pha_err=zeros(1,length(obj.secs));
      dpha_pred=cell(1,length(obj.secs));
      % Generate predictions and extract measured GOLD phases
      for n=1:length(obj.secs)
        if obj.mode(n)==0
          nm=n;
        else
          nm=obj.mode(n)-10;
        end
        if obj.RegressionModel=="NN"
          pha_pred(:,n) = obj.regmodel{nm}(D');
        else
          pha_pred(:,n) = obj.regmodel{nm}.predict(D) ;
        end
        pha_act(:,n) = rad2deg( unwrap( deg2rad( tt.("GOLD_"+obj.secs(n)) - tt.("PMDL_"+obj.secs(n)) ) ) ) ;
        pha_act(:,n) = pha_act(:,n) - pha_act(1,n) ;
%         subplot(length(obj.secs),1,n,'Parent',fhan);
        subplot(length(obj.secs),4,[(n-1)*4+1,(n-1)*4+3],'Parent',fhan);
        [~,ii]=unique(tt.("GOLD_"+obj.secs(n)),'stable');
        act = pha_act(ii,n)-median(pha_act(ii,n)) ; 
        pred = pha_pred(:,n)-median(pha_pred(:,n)) ;
        plot(tt.Time(ii),act,'*',ttD.Time,pred); ylabel(sprintf('\\Delta\\phi (%d) [deg]',obj.secs(n)));
        title(sprintf('SBST %d GOLD Phase Error [deg]',obj.secs(n)));
        if obj.mode(n)>0
          if obj.RegressionModel=="NN"
            pp = obj.regmodel{n}(D');
          else
            pp = obj.regmodel{n}.predict(D) ;
          end
          ax=gca;
          ylim=ax.YLim;
          hold on
          plot(ttD.Time,pp-median(pp),'r--');
          hold off
          ax.YLim=ylim;
        end
        subplot(length(obj.secs),4,(n-1)*4+4);
        pred = pha_pred(ii,n)-median(pha_pred(ii,n)) ;
        pha_err(n)=std(act-pred);
        dpha_pred{n}=act-pred;
        histogram(act-pred); title(sprintf('N = %d RMS Error = %.1f deg',length(ii),pha_err(n)));
%         ax=gca;
%         ylim=ax.YLim;
%         hold on
%         plot(tt.Time,tt.("PMDL_"+obj.secs(n)) - tt.("PMDL_"+obj.secs(n))(1),'k--');
%         hold off
%         ax.YLim=ylim;
      end
      
    end
    function plotsummary(obj,g_ref,g_act,gerr_lm,gerr_nn)
      %PLOTSUMMARY Statistics summary plots of FF performance
      grp=string(obj.secs);
      x=[];
      gid=[];
      col=[];
      cols='kbrm';
      x_ref=[]; x_act=[]; x_lm=[]; x_nn=[];
      for ig=1:length(obj.secs)
        gid=[gid;repmat(grp(ig)+"_FFOFF",length(g_ref{ig}),1)];
        x=[x;g_ref{ig}-median(g_ref{ig})]; x_ref=[x_ref; g_ref{ig}-median(g_ref{ig})];
        gid=[gid;repmat(grp(ig)+"_FFON",length(g_act{ig}),1)];
        x=[x;g_act{ig}-median(g_act{ig})]; x_act=[x_act; g_act{ig}-median(g_act{ig})];
        gid=[gid;repmat(grp(ig)+"_lm",length(gerr_lm{ig}),1)];
        x=[x;gerr_lm{ig}-median(gerr_lm{ig})]; x_lm=[x_lm;gerr_lm{ig}-median(gerr_lm{ig})];
        gid=[gid;repmat(grp(ig)+"_nn",length(gerr_nn{ig}),1)];
        x=[x;gerr_nn{ig}-median(gerr_nn{ig})]; x_nn=[x_nn;gerr_nn{ig}-median(gerr_nn{ig})];
        col=[col; cols(1); cols(2); cols(3); cols(4)];
      end
      subplot(2,1,1);
      boxplot(x,gid,'PlotStyle','compact','Whisker',1000,'Colors',col)
%       boxplot(x,gid,'Whisker',1000,'Colors',col)
      ylabel('GOLD Phase Error [deg]');
      subplot(2,1,2);
      histogram(x_ref,'Normalization','probability');
      hold on;
      histogram(x_act+50,'Normalization','probability');
      histogram(x_lm+100,'Normalization','probability');
      histogram(x_nn+150,'Normalization','probability');
      hold off;
      fprintf('RMS Err: Ref = %g Act= %g lm= %g nn= %g\n',std(x_ref),std(x_act),std(x_lm),std(x_nn));
      fprintf('Range Err: Ref = %g Act= %g lm= %g nn= %g\n',range(x_ref),range(x_act),range(x_lm),range(x_nn));
    end
    function AddData(obj,mdlname)
      %ADDDATA Add data from a saved MDLFF object
      %AddData(MDLFFApp_Name)
      % Adds data into data.inc field (from data.proc field of MDLFFApp_name file in F2_common.confdir)
      mdlname=string(mdlname);
      mdlname=regexprep(mdlname,'.mat$','')+".mat";
      ld=load(fullfile(F2_common.confdir,'F2_MDLFF',mdlname));
      if ~isfield(ld,'MDL') || ~isfield(ld.MDL.data,'proc')
        error('MDLFF model or processed data not found');
      end
      if ~isfield(obj.data,'inc')
        obj.data.inc{1} = ld.MDL.data.proc ;
      else
        obj.data.inc{end+1} = ld.MDL.data.proc ;
      end
    end
  end
  % get/set methods
  methods
    function set.usealt(obj,usealt)
      wasrunning=false;
      if obj.state=="Running"
        obj.stop(obj.to);
        wasrunning=true;
      end
      obj.usealt=usealt;
      obj.GenMoniPV;
      if wasrunning
        obj.run(obj.to)
      end
    end
  end
  methods(Access=private)
    function RunFunc(obj)
      if isempty(obj.clock0) || etime(clock,obj.clock0)>obj.Period
        if logical(lcaGet(obj.StatePV))
          obj.WritePMDL();
          obj.state = "Running" ;
        else
          obj.state = "Feedforward OFF" ;
        end
        obj.clock0=clock;
      end
      lcaPutNoWait(obj.WatcherPV,1) ; % Keep watcher happy
    end
    function StopFunc(obj)
      obj.state = "Stopped" ;
      lcaPutNoWait(obj.StatePV,0);
    end
  end
  methods(Hidden,Static)
    function [InitialObservation,LoggedSignal] = myResetFunction(obs0)
      LoggedSignal.State = obs0 ;
      InitialObservation = LoggedSignal.State;
    end
  end
end