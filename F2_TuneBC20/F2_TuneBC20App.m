classdef F2_TuneBC20App < handle
  %F2_TUNEBC20APP Application interface for BC20 tuning algorithms
  % Uses TuneBC20OptimFun as objective function for optimizer
  
  events
    PVUpdated % PV object list notifies this event after each set of monitored PVs have finished updating
  end
  properties
    Nbkg uint8 = 1
    PM % Profile measurement device object
    BkgDevice string {mustBeMember(BkgDevice,["PMT3060" "PMT3070" "PMT3179" "PMT3350" "PMT3360"])} = "PMT3179" % PV source for background measurement
    OptimAlg string {mustBeMember(OptimAlg,["fminsearch","fmincon","lsqnonlin","mobo","cnsga"])} = "fminsearch"
  end
  properties(SetObservable)
    ProfDevice string {mustBeMember(ProfDevice,["IPOTR1" "IPOTR1P" "IPOTR2" "PRDMP"])} = "PRDMP"
    S1Limit(1,2) = [0 1200]
    S2Limit(1,2) = [-3000 0]
    S3Limit(1,2) = [-1200 0]
  end
  properties(SetAccess=private,SetObservable)
    S_opt(1,3) = nan(1,3) % Optimized sextupole strengths
    S_reset(1,3) = nan(1,3) % Reset values for sextupole strengths
  end
  properties(SetAccess=private,Hidden)
    guihan
    pvlist
  end
  properties(SetAccess=private)
    pvs
  end
  properties(Constant)
    SextupolePV = ["LI20:LGPS:2145:BDES" "LI20:LGPS:2165:BDES" "LI20:LGPS:2195:BDES";
      "LI20:LGPS:2365:BDES" "LI20:LGPS:2335:BDES" "LI20:LGPS:2275:BDES" ]
  end
  
  methods
    function obj = F2_TuneBC20App(guihan)
      %F2_TUNEBC20APP
      %F2_TuneBC20App(guihan)
      
      if exist('guihan','var')
        obj.guihan=guihan;
      end
      
      obj.PM = F2_ProfMeas(obj.ProfDevice); % Profile measurement device object with default configuration
      
      context = PV.Initialize(PVtype.EPICS) ;
      obj.pvlist=[PV(context,'name',"S1_BDES",'pvname',obj.SextupolePV(:,1),'monitor',true,'pvlogic',"MAX",'mode',"rw");
                  PV(context,'name',"S2_BDES",'pvname',obj.SextupolePV(:,2),'monitor',true,'pvlogic',"MAX",'mode',"rw");
                  PV(context,'name',"S3_BDES",'pvname',obj.SextupolePV(:,3),'monitor',true,'pvlogic',"MAX",'mode',"rw")];
      pset(obj.pvlist,'debug',0) ;
      obj.pvs = struct(obj.pvlist) ;
      if ~isempty(obj.guihan)
        obj.pvs.S1_BDES.guihan = guihan.S1BDES ;
        obj.pvs.S2_BDES.guihan = guihan.S2BDES ;
        obj.pvs.S3_BDES.guihan = guihan.S3BDES ;
        obj.S1Limit = [guihan.S1BDES_LowerLimit.Value guihan.S1BDES_UpperLimit.Value] ;
        obj.S2Limit = [guihan.S2BDES_LowerLimit.Value guihan.S2BDES_UpperLimit.Value] ;
        obj.S3Limit = [guihan.S3BDES_LowerLimit.Value guihan.S3BDES_UpperLimit.Value] ;
      else
        obj.pvs.S1_BDES.limits=obj.S1Limit;
        obj.pvs.S2_BDES.limits=obj.S2Limit;
        obj.pvs.S3_BDES.limits=obj.S3Limit;
      end
      run(obj.pvlist,false,0.5);
    end
    function run(obj)
      %RUN Start optimizer
      
      % Pass required options to objective function
      bkgpv=regexprep(obj.BkgDevice,"PMT(\d+)","PMT:LI20:$1:QDCRAW");
      nbkg=double(obj.Nbkg);
      pname=obj.ProfDevice;
      oalg=obj.OptimAlg;
      gh=obj.guihan;
      assignin('base','ProfileDeviceName',pname);
      assignin('base','BkgDevice',bkgpv); %#ok<*SPEVB>
      assignin('base','nbkg',nbkg);
      assignin('base','dostop',false);
      assignin('base','optimtype',oalg);
      assignin('base','guihan',gh);
      % Run optimizer
      if ~isempty(obj.guihan)
        obj.guihan.StatusText.Value = "Running Optimizer..." ;
        drawnow
      end
      x0=[obj.pvs.S1_BDES.val{1} obj.pvs.S2_BDES.val{1} obj.pvs.S3_BDES.val{1}];
      xmin=[];
      lb=[obj.S1Limit(1) obj.S2Limit(1) obj.S3Limit(1)]; ub=[obj.S1Limit(2) obj.S2Limit(2) obj.S3Limit(2)];
      switch obj.OptimAlg
        case "fminsearch"
          xmin=fminsearch(@TuneBC20_OptimFun,x0,optimset('Display','iter','OutputFcn',@TuneBC20_OutputFun)) ;
        case "fmincon"
          xmin=fmincon(@TuneBC20_OptimFun,x0,[],[],[],[],lb,ub,[],optimset('Display','iter','OutputFcn',@TuneBC20_OutputFun)) ;
        case "lsqnonlin"
          xmin=lsqnonlin(@TuneBC20_OptimFun,x0,lb,ub,optimset('Display','iter','OutputFcn',@TuneBC20_OutputFun)) ;
        otherwise % Xopt based optimization
          spmd
            assignin('base','optimtype',"lsqnonlin");
          end
          X = Xopt("TuneBC20_OptimFun",3,2) ;
          X.Optimizer = obj.OptimAlg ;
          X.xrange = [lb;ub] ;
          X.yrange = [10000 10000; 1 0] ;
          X.runopt ;
      end
      obj.S_opt=nan(1,3);
      obj.S_reset=x0;
      if ~isempty(obj.guihan)
        if isempty(xmin) || any(isnan(xmin)) || length(xmin)~=length(x0)
          txt="Optimizer exited abnormally, no solution to set" ;
        else
          obj.S_opt=xmin;
          txt=sprintf("Set solution [%g %g %g] or reset initial values [%g %g %g].",xmin,x0);
        end
        obj.guihan.StatusText.Value = "Optimizer stopped. " + txt ; drawnow ;
      end
    end
    function ResetSextBDES(obj)
      %RESETSEXTBDES Reset sextupole BDES values to initial
      for isext=1:3
        if ~isnan(obj.S_reset(isext))
          caput(obj.pvs.S1_BDES,obj.S_reset(isext));
        end
      end
    end
    function SetOptSextBDES(obj)
      %SETOPTSEXTBDES Set optimized sextupole BDES values
      for isext=1:3
        if ~isnan(obj.S_opt(isext))
          caput(obj.pvs.S1_BDES,obj.S_opt(isext));
        end
      end
    end
  end
  methods % set/get methods
    function set.ProfDevice(obj,DeviceName)
      obj.ProfDevice=DeviceName;
      if ~isempty(obj.PM)
        obj.PM.Device=DeviceName;
      end
    end
    function set.S_opt(obj,val)
      obj.S_opt=val;
      if ~isempty(obj.guihan)
        if any(isnan(val))
          obj.guihan.SetOptimizedBDESButton.Enable=false;
        else
          obj.guihan.SetOptimizedBDESButton.Enable=true;
        end
        drawnow
      end
    end
    function set.S_reset(obj,val)
      obj.S_reset=val;
      if ~isempty(obj.guihan)
        if any(isnan(val))
          obj.guihan.ResetBDESButton.Enable=false;
        else
          obj.guihan.ResetBDESButton.Enable=true;
        end
        drawnow
      end
    end
    function set.S1Limit(obj,val)
      obj.S1Limit=val;
      obj.pvs.S1_BDES.limits=val;
    end
    function set.S2Limit(obj,val)
      obj.S2Limit=val;
      obj.pvs.S2_BDES.limits=val;
    end
    function set.S3Limit(obj,val)
      obj.S3Limit=val;
      obj.pvs.S3_BDES.limits=val;
    end
  end
end

