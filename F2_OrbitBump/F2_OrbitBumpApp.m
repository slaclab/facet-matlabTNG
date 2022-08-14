classdef F2_OrbitBumpApp < handle
  properties
    FO % F2_Orbit object
    corapp % link to corrector app
  end
  properties(SetObservable,AbortSet)
    BumpVal = 0 % Corrector bump amplitude (m) at targetID
    UseRegion(1,11) logical = true(1,11) % ["INJ";"L0";"DL1";"L1";"BC11";"L2";"BC14";"L3";"BC20";"FFS";"SPECTDUMP"]
    usecor(1,3) = [1,2,3] % Corrector ID's to use in bump (indexed to obj.CORS)
    targetID % BEAMLINE index of desired bump location 
    dim string {mustBeMember(dim,["x","y"])} = "x" % Bumps considered in horizontal (x) or vertical (y) dimension
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
      if ~isempty(obj.guihan)
        obj.FO.npulse=obj.guihan.NAveEditField.Value;
      else
        obj.FO.npulse=20;
      end
      obj.FO.usebpmbuff=false;
      obj.XCORS = F2_mags(obj.LM) ; obj.XCORS.MagClasses="XCOR" ; obj.XCORS.ReadB ; obj.XCORS.autoupdate=true; 
      obj.YCORS = F2_mags(obj.LM) ; obj.YCORS.MagClasses="YCOR" ; obj.YCORS.ReadB ; obj.YCORS.autoupdate=true;
      obj.targetID = obj.LM.ModelID(floor(length(obj.LM.ModelID)/2)) ; % dummy initial target ID
      %
      obj.FO.acquire();
      obj.FO.StoreRef();
      obj.FO.UseRefOrbit="local";
      if ~isempty(obj.guihan)
        obj.guihan.ReferenceEditField.Value=datestr(now);
      end
      addlistener(obj.XCORS,'PVUpdated',@(~,~) obj.ProcCors) ;
      addlistener(obj.YCORS,'PVUpdated',@(~,~) obj.ProcCors) ;
      addlistener(obj.LiveModel,'ModelUpdated',@(~,~) obj.ModelUpdate) ;
    end
    function StartTimer(obj)
      obj.tobj=timer('ExecutionMode','fixedRate','Period',1,'TimerFcn',@(~,~) obj.ProcLoop) ;
      start(obj.tobj);
    end
    function StopTimer(obj)
      if ~isempty(obj.tobj)
        stop(obj.tobj);
      end
    end
    function SetBump(obj)
      dkick = obj.CorCoef(:).*obj.BumpVal ;
      dbdes = dkick .* obj.CORS.LM.ModelP(obj.usecor).*LucretiaModel.GEV2KGM ;
      for icor=1:3; fprintf(2,'SET %s %g -> %g\n',obj.CorControlNames(icor),obj.CorBDESRef(icor),obj.CorBDESRef(icor)+dbdes(icor)); end
      control_magnetSet(cellstr(obj.CorControlNames),obj.CorBDESRef(:)+dbdes);
    end
  end
  methods(Hidden)
    function ModelUpdate(obj)
      obj.GetCorCoef;
      obj.GetCorResp;
      if ~isempty(obj.guihan)
        obj.guihan.ListBox_2.Items = obj.CORS.LM.ControlNames(:) + " / " + obj.CorResp(:) ;
        obj.guihan.ListBox_2.ItemsData = 1:length(obj.guihan.ListBox_2.Items) ;
        obj.guihan.ListBox_2.Value = obj.guihan.ListBox_2.ItemsData(obj.usecor) ;
        drawnow;
      end
      obj.ProcCors;
    end
    function ProcCors(obj)
      %PROCCORS Process changes to corrector magnet readbacks
      if ~isempty(obj.guihan)
        dkick = obj.CorCoef(:).*obj.BumpVal ;
        dbdes = dkick .* obj.CORS.LM.ModelP(obj.usecor).*LucretiaModel.GEV2KGM ;
        bdes=obj.CorBDESRef(:)+dbdes(:) ;
        bact = obj.CORS.BACT_cntrl(obj.usecor) ;
        if abs(bact(1)-bdes(1)) > 1e-4 && abs(bact(1)-bdes(1)) / abs(bdes(1)) > 0.02
          obj.guihan.EditField_16.FontColor = 'r';
        else
          obj.guihan.EditField_16.FontColor = 'k';
        end
        if abs(bact(2)-bdes(2)) > 1e-4 && abs(bact(2)-bdes(2)) / abs(bdes(2)) > 0.02
          obj.guihan.EditField_17.FontColor = 'r';
        else
          obj.guihan.EditField_17.FontColor = 'k';
        end
        if abs(bact(1)-bdes(3)) > 1e-4 && abs(bact(3)-bdes(3)) / abs(bdes(3)) > 0.02
          obj.guihan.EditField_18.FontColor = 'r';
        else
          obj.guihan.EditField_18.FontColor = 'k';
        end
        obj.guihan.EditField_4.Value = bdes(1) ;
        obj.guihan.EditField_16.Value = bact(1) ;
        obj.guihan.EditField_6.Value = dkick(1)*1e3 ;
        obj.guihan.EditField_8.Value = bdes(2) ;
        obj.guihan.EditField_17.Value = bact(2) ;
        obj.guihan.EditField_10.Value = dkick(2) * 1e3 ;
        obj.guihan.EditField_12.Value = bdes(3) ;
        obj.guihan.EditField_18.Value = bact(3) ;
        obj.guihan.EditField_14.Value = dkick(3) * 1e3 ;
        obj.guihan.BumpRange.Value = sprintf("[ %.1f : %.1f ]",obj.BumpRange.*1e3) ;
        obj.guihan.BumpRdb_cor.Value = obj.BumpVal_rdb * 1e3 ;
        obj.guihan.BumpVal.Limits = obj.BumpRange .* 1e3 ;
        drawnow;
      end
      % If corrector panel open, update numbers
      if ~isempty(obj.corapp) && isprop(obj.corapp,'Cor1')
        obj.corapp.Update();
      end
    end
    function ProcLoop(obj,~)
      %PROCLOOP Main processing loop (for BPM updates)
      global BEAMLINE
      try
        obj.FO.BPMS.read(); % Update BPM buffer
        [~,X1]=obj.FO.orbitfit; obj.OrbitFit=X1;
        if ~isempty(obj.guihan)
          cla(obj.guihan.PlotAxes); obj.guihan.PlotAxes.reset();
          [xm,ym,xstd,ystd,~,id] = obj.FO.GetOrbit ;
          z1 = arrayfun(@(x) BEAMLINE{x}.Coordi(3),id) ;
          if obj.dim=="x"
            obj.guihan.BumpRdb_bpm.Value = X1(1) ;
            errorbar(obj.guihan.PlotAxes,z1,xm,xstd,'.','MarkerFaceColor',F2_common.ColorOrder(2,:));
            ylabel(obj.guihan.PlotAxes,'X [mm]');
          else
            obj.guihan.BumpRdb_bpm.Value = X1(3) ;
            errorbar(obj.guihan.PlotAxes,z1,ym,ystd,'.','MarkerFaceColor',F2_common.ColorOrder(2,:));
            ylabel(obj.guihan.PlotAxes,'Y [mm]');
          end
          
          % Superimpose design kick
          dkick = obj.CorCoef(:).*obj.BumpVal ;
          icor = obj.CORS.LM.ModelID(obj.usecor) ;
          np=range(icor)+1;
          if obj.dim=="x"; inds=[1 2]; else; inds=[3 4]; end
          z=zeros(1,np); x=z;
          for iele=1:np
            blele = icor(1)-1+iele ;
            z(iele) = BEAMLINE{blele}.Coordi(3) ;
            x(iele) = 0 ;
            if blele>icor(1) && blele<=icor(2)
              [~,R]=RmatAtoB(icor(1),blele-1);
              x(iele) = R(inds(1),inds(2))*dkick(1) ;
            elseif blele>icor(2)
              [~,R1]=RmatAtoB(icor(1),blele-1);
              [~,R2]=RmatAtoB(icor(2),blele-1);
              x(iele) = R1(inds(1),inds(2))*dkick(1) + R2(inds(1),inds(2))*dkick(2);
            end
          end
          hold(obj.guihan.PlotAxes,'on');
          plot(obj.guihan.PlotAxes,z,x*1e3,'r--');
          zpl_z=linspace(z1(1),z(1),100); zpl_x=zeros(size(zpl_z)); 
          plot(obj.guihan.PlotAxes,zpl_z,zpl_x,'r--');
          zpl_z=linspace(z(end),z1(end),100);
          plot(obj.guihan.PlotAxes,zpl_z,zpl_x,'r--');
          % Plot magnet bar
          F2_common.AddMagnetPlotZ(obj.FO.LM.istart,obj.FO.LM.iend,obj.guihan.PlotAxes) ;
          obj.guihan.PlotAxes.XLim=[z1(1) z1(end)];
          ax=axis(obj.guihan.PlotAxes);
          line(obj.guihan.PlotAxes,ones(1,2).*obj.targetZ,ax(3:4),'Color','m');
          hold(obj.guihan.PlotAxes,'off');
          grid(obj.guihan.PlotAxes,'on');
          drawnow;
        end
      catch ME
        drawnow;
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
      obj.usecor = [id-1 id id+1] ; % Calls GetCorCoef etc
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
      obj.ProcCors();
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
    function maxvals = get.CorMaxKick(obj)
      maxvals=[obj.CORS.BMAX(obj.usecor(1)) obj.CORS.BMAX(obj.usecor(2)) obj.CORS.BMAX(obj.usecor(3))]./...
        [obj.CORS.LM.ModelP(obj.usecor(1)).*LucretiaModel.GEV2KGM obj.CORS.LM.ModelP(obj.usecor(2)).*LucretiaModel.GEV2KGM obj.CORS.LM.ModelP(obj.usecor(3)).*LucretiaModel.GEV2KGM] ;
    end
    function names = get.CorModelNames(obj)
      names = obj.CORS.LM.ModelNames(obj.usecor) ;
    end
    function names = get.CorControlNames(obj)
      names = obj.CORS.LM.ControlNames(obj.usecor) ;
    end
    function range = get.BumpRange(obj)
      maxkick = obj.CorMaxKick - obj.CorKickRef ;
      minkick = -obj.CorMaxKick - obj.CorKickRef ;
      maxbump = maxkick./obj.CorCoef ; maxbump=min(maxbump) ;
      minbump = minkick./obj.CorCoef ; minbump=max(minbump) ;
      range = sort([minbump,maxbump]) ;
    end
    function set.usecor(obj,icor)
      obj.usecor=icor;
      obj.GetCorCoef();
      obj.CorKickRef = obj.CorKick ;
      obj.CorBDESRef = obj.CorBDES ;
      obj.ProcCors();
      if ~isempty(obj.corapp) && isprop(obj.corapp,'Cor1')
        obj.corapp.init(char(obj.CorControlNames(1)),char(obj.CorControlNames(2)),char(obj.CorControlNames(3)));
      end
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
      obj.GetCorResp();
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
    function CORS = get.CORS(obj)
      if obj.dim=="x"
        CORS=obj.XCORS;
      else
        CORS=obj.YCORS;
      end
    end
    function set.UseRegion(obj,reg)
      obj.UseRegion=reg;
      obj.FO.UseRegion=reg;
      obj.XCORS.LM.UseRegion=reg; obj.XCORS.ReadB();
      obj.YCORS.LM.UseRegion=reg; obj.YCORS.ReadB();
      obj.LM.UseRegion=reg;
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
    function z = get.targetZ(obj)
      global BEAMLINE
      z=BEAMLINE{obj.targetID}.Coordi(3);
    end
  end
end