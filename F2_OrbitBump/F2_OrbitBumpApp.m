classdef F2_OrbitBumpApp < handle
  properties(SetObservable,AbortSet)
    BumpVal = 0 % Corrector bump amplitude (mm) at targetID
    UseRegion(1,11) logical = true(1,11) % ["INJ";"L0";"DL1";"L1";"BC11";"L2";"BC14";"L3";"BC20";"FFS";"SPECTDUMP"]
    usebpm logical % Which BPMs to use in app (indexed to obj.BPMS)
    usecor(1,3) = [1,2,3] % Corrector ID's to use in bump (indexed to obj.CORS)
    targetID % BEAMLINE index of desired bump location 
    dim string {mustBeMember(dim,["x","y"])} = "x" % Bumps considered in horizontal (x) or vertical (y) dimension
  end
  properties(SetAccess=private)
    BPMS % F2_bpms object
    XCORS % LucretiaModel object for XCORS
    YCORS % LucretiaModel object for YCORS
    LiveModel % F2_LiveModel object
    LM % LucretiaModel object
    CorResp
    CorCoef(1,3) = [1 1 1] % Corrector bump coefficients
    guihan
    CorKickRef(1,3) = [0 0 0] % Reference corrector kick vals when bump made (GetCOrCoef method called)
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
  end
  methods
    function obj = F2_OrbitBumpApp(guihan)
      if exist('guihan','var')
        obj.guihan=guihan;
      end
      
      % Initialize model and other internal lists
      obj.LiveModel = F2_LiveModelApp ;
      obj.BPMS = F2_bpms(obj.LiveModel.LM) ;
      obj.usebpm = true(size(obj.BPMS.modelnames)) ;
      obj.XCORS = copy(obj.LiveModel.LM) ; obj.XCORS.MagClasses="XCOR" ; obj.XCORS.ReadB();
      obj.YCORS = copy(obj.LiveModel.LM) ; obj.YCORS.MagClasses="YCOR" ; obj.YCORS.ReadB();
      obj.targetID = obj.LM.ModelID(floor(length(obj.LM.ModelID)/2)) ; % dummy initial target ID
      obj.ChooseCor;
      obj.GetCorResp();
      
      % 
      addlistener(obj.XCORS,'PVUpdated',@(~,~) obj.ProcCors) ;
      addlistener(obj.YCORS,'PVUpdated',@(~,~) obj.ProcCors) ;
    end
  end
  methods(Access=private)
    function ProcCors(obj)
      %PROCCORS Process changes to corrector magnet readbacks
      if ~isempty(obj.guihan)
        obj.guihan.EditField_4.Value = obj.CORS.BDES_cntrl(obj.usecor(1)) ;
        obj.guihan.EditField_16.Value = obj.CORS.BACT_cntrl(obj.usecor(1)) ;
        obj.guihan.EditField_6.Value = obj.CORS.KLDES_cntrl(obj.usecor(1)) ;
        obj.guihan.EditField_8.Value = obj.CORS.BDES_cntrl(obj.usecor(2)) ;
        obj.guihan.EditField_17.Value = obj.CORS.BACT_cntrl(obj.usecor(2)) ;
        obj.guihan.EditField_10.Value = obj.CORS.KLDES_cntrl(obj.usecor(2)) ;
        obj.guihan.EditField_12.Value = obj.CORS.BDES_cntrl(obj.usecor(3)) ;
        obj.guihan.EditField_18.Value = obj.CORS.BACT_cntrl(obj.usecor(3)) ;
        obj.guihan.EditField_14.Value = obj.CORS.KLDES_cntrl(obj.usecor(3)) ;
        obj.guihan.BumpRange.Value = sprintf("[ %.1f : %.1f ]",obj.BumpRange) ;
        obj.guihan.BumpReadback.Value = obj.BumpVal_rdb ;
      end
    end
    function ProcLoop(obj)
      %PROCLOOP Main processing loop
      
    end
    function ChooseCor(obj)
      %CHOOSECOR Default selection of correctors based on desired target
      
      % Choose corrector closest to targetID and the ones either side
      [~,id] = min(abs(obj.CORS.ModelZ-obj.targetZ)) ;
      % If the closest corrector is the first or last corrector, choose one closer to middle
      if id==obj.CORS.ModelID(end) 
        id=id-1;
      elseif id==obj.CORS.ModelID(1)
        id=id+1;
      end
      obj.usecor = [id-1 id id+1] ;
      
    end
    function GetCorResp(obj)
      %GETCORRESP Get response matrices and phases from correctors to targetID
      uscor = obj.CORS.ModelID < obj.targetID ;
      dscor = ~uscor ;
      obj.CorResp = zeros(1,length(obj.CORS.ModelID)) ;
      if obj.dim=="x"
        i1=1; i2=2;
      else
        i1=3; i2=4;
      end
      for icor=find(uscor)
        [~,R] = RmatAtoB(obj.CORS.ModeID(icor),obj.targetID) ;
        obj.CorResp(icor) = R(i1,i2) ;
      end
      for icor=find(dscor)
        [~,R] = RmatAtoB(obj.CORS.ModeID(icor),obj.targetID) ;
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
      [~,R] = RmatAtoB(obj.CORS.ModelID(obj.usecor(1)),obj.targetID) ;
      A(1,1) = R(i1,i2) ;
      if obj.CORS.ModelID(obj.usecor(2)) < obj.targetID
        [~,R] = RmatAtoB(obj.CORS.ModelID(obj.usecor(2)),obj.targetID) ;
        A(1,2) = R(i1,i2) ;
      end
      [~,R] = RmatAtoB(obj.CORS.ModelID(obj.usecor(1)),obj.CORS.ModelID(obj.usecor(3))) ;
      A(2,1) = R(i1,i2) ; A(3,1) = R(i2,i2) ;
      [~,R] = RmatAtoB(obj.CORS.ModelID(obj.usecor(2)),obj.CORS.ModelID(obj.usecor(3))) ;
      A(2,2) = R(i1,i2) ; A(3,2) = R(i2,i2) ;
      A(3,3) = 1 ;
      obj.CorCoef = A\[1;0;0] ;
      if ~isempty(obj.guihan)
        obj.guihan.EditField_7.Value = obj.CorCoef(1);
        obj.guihan.EditField_11.Value = obj.CorCoef(2);
        obj.guihan.EditField_15.Value = obj.CorCoef(3);
      end
      obj.CorKickRef = obj.CorKick ;
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
        [obj.CORS.LM.ModelP(obj.usecor(1))./LucretiaModel.GEV2KGM obj.CORS.LM.ModelP(obj.usecor(2))./LucretiaModel.GEV2KGM obj.CORS.LM.ModelP(obj.usecor(3))./LucretiaModel.GEV2KGM] ;
    end
    function maxvals = get.CorMax(obj)
      maxvals=[obj.CORS.BMAX(obj.usecor(1)) obj.CORS.BMAX(obj.usecor(2)) obj.CORS.BMAX(obj.usecor(3))];
    end
    function minvals = get.CorMaxKick(obj)
      minvals=-[obj.CORS.BMAX(obj.usecor(1)) obj.CORS.BMAX(obj.usecor(2)) obj.CORS.BMAX(obj.usecor(3))]./...
        [obj.CORS.LM.ModelP(obj.usecor(1))./LucretiaModel.GEV2KGM obj.CORS.LM.ModelP(obj.usecor(2))./LucretiaModel.GEV2KGM obj.CORS.LM.ModelP(obj.usecor(3))./LucretiaModel.GEV2KGM] ;
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
      % Apply setting limits for BDES/Kick edit fields
      if ~isempty(obj.guihan)
        obj.guihan.EditField_4.Limits=[-obj.CORS.BMAX(icor(1)),obj.CORS.BMAX(icor(1))];
        obj.guihan.EditField_6.Limits=[-obj.CORS.BMAX(icor(1)),obj.CORS.BMAX(icor(1))]./obj.CORS.LM.ModelP(icor(1))./LucretiaModel.GEV2KGM;
        obj.guihan.EditField_8.Limits=[-obj.CORS.BMAX(icor(2)),obj.CORS.BMAX(icor(2))];
        obj.guihan.EditField_10.Limits=[-obj.CORS.BMAX(icor(2)),obj.CORS.BMAX(icor(2))]./obj.CORS.LM.ModelP(icor(2))./LucretiaModel.GEV2KGM;
        obj.guihan.EditField_12.Limits=[-obj.CORS.BMAX(icor(3)),obj.CORS.BMAX(icor(3))];
        obj.guihan.EditField_14.Limits=[-obj.CORS.BMAX(icor(3)),obj.CORS.BMAX(icor(3))]./obj.CORS.LM.ModelP(icor(3))./LucretiaModel.GEV2KGM;
      end
    end
    function set.targetID(obj,id)
      if id>obj.CORS.ModelID(end)
        error('No downstream correctors from target');
      end
      if id<obj.CORS.ModelID(1)
        error('No upstream correctors from target');
      end
      obj.targetID=id;
      obj.ChooseCor;
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
      obj.BPMS.UseRegion(reg);
      obj.XCORS.UseRegion(reg); obj.XCORS.ReadB();
      obj.YCORS.UseRegion(reg); obj.YCORS.ReadB();
      obj.LM.UseRegion(reg);
      obj.usebpm = true(size(obj.BPMS.modelnames)) ;
      obj.targetID = obj.LM.ModelID(floor(length(obj.LM.ModelID)/2)) ; % dummy initial target ID
      obj.ChooseCor;
      obj.GetCorResp();
    end
    function set.dim(obj,dim)
      obj.dim=dim;
      obj.ChooseCor;
    end
  end
end