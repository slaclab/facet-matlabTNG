classdef F2_OrbitBumpApp < handle
  properties(SetObservable,AbortSet)
    BumpVal = 0 % Corrector bump amplitude (m) at targetID
    UseRegion(1,11) logical = true(1,11) % ["INJ";"L0";"DL1";"L1";"BC11";"L2";"BC14";"L3";"BC20";"FFS";"SPECTDUMP"]
    usecor(1,3) = [1,2,3] % Corrector ID's to use in bump (indexed to obj.CORS)
    targetID % BEAMLINE index of desired bump location 
    dim string {mustBeMember(dim,["x","y"])} = "x" % Bumps considered in horizontal (x) or vertical (y) dimension
    FO % F2_Orbit object
  end
  properties(SetAccess=private)
    XCORS % LucretiaModel object for XCORS
    YCORS % LucretiaModel object for YCORS
    LiveModel % F2_LiveModel object
    LM % LucretiaModel object
    CorResp
    CorCoef(1,3) = [1 1 1] % Corrector bump coefficients
    guihan
    CorKickRef(1,3) = [0 0 0] % Reference corrector kick vals
    CorBDESRef(1,3) = [0 0 0] % Reference corrector BDES vals
    OrbitFit % 5D orbit fit at targetID location
    tobj % Timer object
  end
  properties(Dependent)
    CORS
    targetZ
    CorBDES(1,3)
    CorBACT(1,3)
    CorKick(1,3)
    BumpRange(1,2)
    BumpVal_rdb
    CorMax(1,3)
    CorMaxKick(1,3)
    CorModelNames(1,3) string
    CorControlNames(1,3) string
    targetName
  end
  methods
    function obj = F2_OrbitBumpApp(guihan,LLM)
      if exist('guihan','var') && ~isempty(guihan)
        obj.guihan=guihan;
      end
      
      % Initialize model and other internal lists
      if exist('LLM','var')
        obj.LiveModel = LLM ;
      else
        obj.LiveModel = F2_LiveModelApp ;
      end
      obj.LiveModel.autoupdate = true ;
      obj.LM=copy(obj.LiveModel.LM);
      addpath ../F2_Orbit
      obj.FO = F2_OrbitApp(true,obj.LiveModel) ;
      obj.FO.npulse=20;
      obj.FO.usebpmbuff=false;
      obj.XCORS = F2_mags(obj.LM) ; obj.XCORS.MagClasses="XCOR" ; obj.XCORS.autoupdate=true; 
      obj.YCORS = F2_mags(obj.LM) ; obj.YCORS.MagClasses="YCOR" ; obj.YCORS.autoupdate=true;
      obj.targetID = obj.LM.ModelID(floor(length(obj.LM.ModelID)/2)) ; % dummy initial target ID
      obj.ChooseCor;
      obj.GetCorResp();
      obj.ProcCors();
      %
      addlistener(obj.XCORS,'PVUpdated',@(~,~) obj.ProcCors) ;
      addlistener(obj.YCORS,'PVUpdated',@(~,~) obj.ProcCors) ;
      addlistener(obj.LiveModel,'ModelUpdated',@(~,~) obj.ModelUpdate) ;
      obj.StartTimer;
    end
    function StartTimer(obj)
      obj.tobj=timer('ExecutionMode','fixedRate','Period',1,'TimerFcn',@ProcLoop) ;
      start(obj.tobj);
    end
    function StopTimer(obj)
      if ~isempty(obj.tobj)
        stop(obj.tobj);
      end
    end
    function SetBump(obj)
%       control_magnetSet(cellstr(obj.CorControlNames),obj.CorBDESRef(:)+obj.CorCoef(:).*obj.BumpVal);
    end
  end
  methods(Access=private)
    function ModelUpdate(obj)
      obj.GetCorCoef;
      obj.GetCorResp;
      if ~isempty(obj.guihan)
        obj.guihan.ListBox_2.Items = sprintf("%s / %.1f",obj.CorModelNames,obj.CorResp) ;
        obj.guihan.ListBox_2.ItemsData = 1:length(obj.guihan.ListBox_2.Items) ;
        obj.guihan.ListBox_2.Value = obj.guihan.ListBox_2.ItemsData(obj.usecor) ;
        drawnow;
      end
    end
    function ProcCors(obj)
      %PROCCORS Process changes to corrector magnet readbacks
      if ~isempty(obj.guihan)
        obj.guihan.EditField_4.Value = obj.CORS.BDES_cntrl(obj.usecor(1)) ;
        obj.guihan.EditField_16.Value = obj.CORS.BACT_cntrl(obj.usecor(1)) ;
        obj.guihan.EditField_6.Value = obj.CORS.KLDES_cntrl(obj.usecor(1)) * 1e3 ;
        obj.guihan.EditField_8.Value = obj.CORS.BDES_cntrl(obj.usecor(2)) ;
        obj.guihan.EditField_17.Value = obj.CORS.BACT_cntrl(obj.usecor(2)) ;
        obj.guihan.EditField_10.Value = obj.CORS.KLDES_cntrl(obj.usecor(2)) * 1e3 ;
        obj.guihan.EditField_12.Value = obj.CORS.BDES_cntrl(obj.usecor(3)) ;
        obj.guihan.EditField_18.Value = obj.CORS.BACT_cntrl(obj.usecor(3)) ;
        obj.guihan.EditField_14.Value = obj.CORS.KLDES_cntrl(obj.usecor(3)) * 1e3 ;
        obj.guihan.BumpRange.Value = sprintf("[ %.1f : %.1f ]",obj.BumpRange.*1e3) ;
        obj.guihan.BumpRdb_cor.Value = obj.BumpVal_rdb * 1e3 ;
        obj.guihan.BumpVal.Limits = obj.BumpRange .* 1e3 ;
        drawnow;
      end
    end
    function ProcLoop(obj,~)
      %PROCLOOP Main processing loop (for BPM updates)
      try
        obj.FO.BPMS.read(); % Update BPM buffer
        [~,X1]=obj.FO.orbitfit; obj.OrbitFit=X1;
        if ~isempty(obj.guihan)
          if obj.dim=="x"
            obj.guihan.BumpRdb_bpm.Value = X1(1).*1e3 ;
            obj.FO.plotbpm([obj.guihan.PlotAxes 0],1,0,0);
          else
            obj.guihan.BumpRdb_bpm.Value = X1(3).*1e3 ;
            obj.FO.plotbpm([0 obj.guihan.PlotAxes],1,0,0);
          end
          drawnow;
        end
      catch ME
        fprintf(2,'F2_OrbitBumpApp main loop error:\n');
        fprintf(2,sprintf('%s\n',ME.message));
      end
    end
    function ChooseCor(obj)
      %CHOOSECOR Default selection of correctors based on desired target
      
      % Choose corrector closest to targetID and the ones either side
      [~,id] = min(abs(obj.CORS.LM.ModelZ-obj.targetZ)) ;
      % If the closest corrector is the first or last corrector, choose one closer to middle
      if id==obj.CORS.LM.ModelID(end) 
        id=id-1;
      elseif id==obj.CORS.LM.ModelID(1)
        id=id+1;
      end
      obj.usecor = [id-1 id id+1] ;
      obj.GetCorCoef();
    end
    function GetCorResp(obj)
      %GETCORRESP Get response matrices from correctors to targetID
      uscor = obj.CORS.LM.ModelID < obj.targetID ;
      dscor = ~uscor ;
      obj.CorResp = zeros(1,length(obj.CORS.LM.ModelID)) ;
      if obj.dim=="x"
        i1=1; i2=2;
      else
        i1=3; i2=4;
      end
      for icor=find(uscor(:)')
        [~,R] = RmatAtoB(obj.CORS.LM.ModelID(icor),obj.targetID) ;
        obj.CorResp(icor) = R(i1,i2) ;
      end
      for icor=find(dscor(:)')
        [~,R] = RmatAtoB(obj.targetID,obj.CORS.LM.ModelID(icor)) ;
        obj.CorResp(icor) = R(i1,i2) ;
      end
    end
    function GetCorCoef(obj)
      %GETCORCOEF Get corrector bump coefficents
      if obj.dim=="x"
        i1=1; i2=2;
      else
        i1=3; i2=4;
      end
      A=zeros(3,3);
      [~,R] = RmatAtoB(obj.CORS.LM.ModelID(obj.usecor(1)),obj.targetID) ;
      A(1,1) = R(i1,i2) ;
      if obj.CORS.LM.ModelID(obj.usecor(2)) < obj.targetID
        [~,R] = RmatAtoB(obj.CORS.LM.ModelID(obj.usecor(2)),obj.targetID) ;
        A(1,2) = R(i1,i2) ;
      end
      [~,R] = RmatAtoB(obj.CORS.LM.ModelID(obj.usecor(1)),obj.CORS.LM.ModelID(obj.usecor(3))) ;
      A(2,1) = R(i1,i2) ; A(3,1) = R(i2,i2) ;
      [~,R] = RmatAtoB(obj.CORS.LM.ModelID(obj.usecor(2)),obj.CORS.LM.ModelID(obj.usecor(3))) ;
      A(2,2) = R(i1,i2) ; A(3,2) = R(i2,i2) ;
      A(3,3) = 1 ;
      obj.CorCoef = A\[1;0;0] ;
      if ~isempty(obj.guihan)
        obj.guihan.EditField_7.Value = obj.CorCoef(1);
        obj.guihan.EditField_11.Value = obj.CorCoef(2);
        obj.guihan.EditField_15.Value = obj.CorCoef(3);
        drawnow;
      end
      obj.BumpVal = 0 ;
    end
  end
  % set/get methods
  methods
    function set.BumpVal(obj,val)
      obj.BumpVal = val ;
    end
    function val = get.BumpVal_rdb(obj)
      val = mean((obj.CorKick-obj.CorKickRef) ./ obj.CorCoef) ;
    end
    function vals = get.CorBDES(obj)
      vals=[obj.CORS.BDES_cntrl(obj.usecor(1)) obj.CORS.BDES_cntrl(obj.usecor(2)) obj.CORS.BDES_cntrl(obj.usecor(3))];
    end
    function vals = get.CorBACT(obj)
      vals=[obj.CORS.BACT_cntrl(obj.usecor(1)) obj.CORS.BACT_cntrl(obj.usecor(2)) obj.CORS.BACT_cntrl(obj.usecor(3))];
    end
    function vals = get.CorKick(obj)
      vals=[obj.CORS.BDES_cntrl(obj.usecor(1)) obj.CORS.BDES_cntrl(obj.usecor(2)) obj.CORS.BDES_cntrl(obj.usecor(3))]./...
        [obj.CORS.LM.ModelP(obj.usecor(1)).*LucretiaModel.GEV2KGM obj.CORS.LM.ModelP(obj.usecor(2)).*LucretiaModel.GEV2KGM obj.CORS.LM.ModelP(obj.usecor(3)).*LucretiaModel.GEV2KGM] ;
    end
    function maxvals = get.CorMax(obj)
      maxvals=[obj.CORS.BMAX(obj.usecor(1)) obj.CORS.BMAX(obj.usecor(2)) obj.CORS.BMAX(obj.usecor(3))];
    end
    function minvals = get.CorMaxKick(obj)
      minvals=-[obj.CORS.BMAX(obj.usecor(1)) obj.CORS.BMAX(obj.usecor(2)) obj.CORS.BMAX(obj.usecor(3))]./...
        [obj.CORS.LM.ModelP(obj.usecor(1)).*LucretiaModel.GEV2KGM obj.CORS.LM.ModelP(obj.usecor(2)).*LucretiaModel.GEV2KGM obj.CORS.LM.ModelP(obj.usecor(3)).*LucretiaModel.GEV2KGM] ;
    end
    function names = get.CorModelNames(obj)
      names = obj.CORS.LM.ModelNames(obj.usecor) ;
    end
    function names = get.CorControlNames(obj)
      names = obj.CORS.LM.ControlNames(obj.usecor) ;
    end
    function range = get.BumpRange(obj)
      maxkick = obj.CorMaxKick - obj.CorKick ;
      minkick = -obj.CorMaxKick - obj.CorKick ;
      maxbump = maxkick./obj.CorCoef ; maxbump=min(maxbump) ;
      minbump = minkick./obj.CorCoef ; minbump=max(minbump) ;
      range = obj.BumpVal + [minbump,maxbump] ;
    end
    function set.usecor(obj,icor)
      obj.usecor=icor;
      obj.GetCorCoef();
      obj.CorKickRef = obj.CorKick ;
      obj.CorBDESRef = obj.CorBDES ;
      obj.ProcCors();
    end
    function set.targetID(obj,id)
      if id>obj.CORS.LM.ModelID(end)
        error('No downstream correctors from target');
      end
      if id<obj.CORS.LM.ModelID(1)
        error('No upstream correctors from target');
      end
      obj.targetID=id;
      obj.ChooseCor;
      obj.FO.fitele=id;
    end
    function set.targetName(obj,name)
      global BEAMLINE
      id=findcells(BEAMLINE,'Name',char(name));
      if isempty(id)
        error('Name not found');
      end
      obj.targetID=id;
    end
    function name = get.targetName(obj)
      global BEAMLINE
      name = BEAMLINE{obj.targetID}.Name ;
    end
    function z = get.targetZ(obj)
      z = obj.LM.ModelZ(ismember(obj.LM.ModelID,obj.targetID)) ;
    end
    function CORS = get.CORS(obj)
      if obj.dim=="x"
        CORS=obj.XCORS;
      else
        CORS=obj.YCORS;
      end
    end
    function set.UseRegion(obj,reg)
      obj.UseRegion=reg;
      obj.FO.UseRegion(reg);
      obj.XCORS.UseRegion(reg); obj.XCORS.ReadB();
      obj.YCORS.UseRegion(reg); obj.YCORS.ReadB();
      obj.LM.UseRegion(reg);
      if ~ismember(obj.targetName,obj.LM.ModelNames)
        obj.targetID = obj.LM.ModelID(floor(length(obj.LM.ModelID)/2)) ; % dummy initial target ID
      end
      obj.ChooseCor;
      obj.GetCorResp();
      obj.ProcCors();
    end
    function set.dim(obj,dim)
      obj.dim=dim;
      obj.ChooseCor;
      obj.GetCorResp();
      obj.ProcCors();
    end
  end
end