classdef F2_LiveModelApp < handle & F2_common
  properties
    LEM % LEM App object
    LM % Lucretia Model object
  end
  properties(SetAccess=private)
    DesignTwiss
    DesignInitial
  end
  properties(Access=private)
    InjSolInd
    InjSolBkInd
  end
  properties(SetObservable)
    Initial % Lucretia initial structure for start of lattice
    ModelSource string {mustBeMember(ModelSource,["Live" "Archive" "Design"])} = "Live"
  end
  properties(Constant)
    Initial_betaxPV = "SIOC:SYS1:ML01:AO401"
    Initial_betayPV = "SIOC:SYS1:ML01:AO402"
    Initial_alphaxPV = "SIOC:SYS1:ML01:AO403"
    Initial_alphayPV = "SIOC:SYS1:ML01:AO404"
    Initial_emitxPV = "PROF:IN10:571:EMITN_X"
    Initial_emityPV = "PROF:IN10:571:EMITN_Y"
    SolPV = 'SOLN:IN10:121:BDES'
    BkSolPV = 'SOLN:IN10:111:BDES'
  end
  methods
    function obj = F2_LiveModelApp
      global BEAMLINE
      % Get data from design model
      obj.LM=LucretiaModel;
      [~,obj.DesignTwiss] = GetTwiss(1,length(BEAMLINE),obj.LM.Initial.x.Twiss,obj.LM.Initial.y.Twiss) ;
      obj.DesignInitial = obj.LM.Initial ;
      obj.Initial = obj.LM.Initial;
      obj.Initial.x.NEmit = lcaGet(char(obj.Initial_emitxPV)).*1e-6 ;
      obj.Initial.y.NEmit = lcaGet(char(obj.Initial_emityPV)).*1e-6 ;
      obj.Initial.x.beta = lcaGet(char(obj.Initial_betaxPV)) ;
      obj.Initial.y.beta = lcaGet(char(obj.Initial_betayPV)) ;
      obj.Initial.x.alpha = lcaGet(char(obj.Initial_alphaxPV)) ;
      obj.Initial.y.alpha = lcaGet(char(obj.Initial_alphayPV)) ;
      % Make live model
      addpath('../F2_LEM');
      if obj.ModelSource~="Design"
        obj.LEM=F2_LEMApp; % Makes LEM object and reads in live model
        obj.LEM.Mags.ReadB(true); % sets extant magnet strengths into model
      end
      % Update source solenoid
      obj.InjSolInd = findcells(BEAMLINE,'Name','SOL10121');
      obj.InjSolBkInd = findcells(BEAMLINE,'Name','SOL10111');
      lcaSetMonitor(obj.SolPV) ;
      lcaSetMonitor(obj.BkSolPV) ;
      bdes = lcaGet(obj.SolPV) / 10 ;
      for iele=obj.InjSolInd
        BEAMLINE{iele}.B = bdes / length(obj.InjSolInd) ;
      end
      bdes = lcaGet(obj.BkSolPV) / 10 ;
      for iele=obj.InjSolBkInd
        BEAMLINE{iele}.B = bdes / length(obj.InjSolBkInd) ;
      end
    end
    function set.ModelSource(obj,src)
      switch string(src)
        case "Live"
          obj.UseArchive=false;
          obj.LEM.UseArchive=false;
          obj.UpdateModel;
        case "Archive"
          obj.UseArchive=true;
          obj.LEM.UseArchive=true;
        case "Design"
          obj.UseArchive=false;
          obj.LEM.UseArchive=false;
          obj.LEM.SetDesignModel;
      end
      obj.ModelSource=src;
    end
    function set.Initial(obj,Inew)
      global BEAMLINE
      [stat,Twiss] = GetTwiss(1,length(BEAMLINE),Inew.x.Twiss,Inew.y.Twiss) ;
      if stat{1}~=1
        error('Invalid Initial structure')
      else
        obj.DesignTwiss = Twiss;
        obj.Initial = Inew ;
      end
    end
    function UpdateModel(obj)
      fprintf('Updating live model...');
      % Sync archiver settings
      obj.LEM.ArchiveDate = obj.ArchiveDate ;
      obj.LEM.UpdateModel; % Updates Klystron and momentum profile data and scales magnets in model (with Arcived Klystron data if requested)
      obj.LEM.Mags.ReadB(true); % sets back extant or Archive magnet strengths into model
      % Update solenoid field if changed
      if lcaNewMonitorValue(obj.SolPV)
        bdes = lcaGet(obj.SolPV) / 10 ;
        for iele=obj.InjSolInd
          BEAMLINE{iele}.B = bdes / length(obj.InjSolInd) ;
        end
      end
      if lcaNewMonitorValue(obj.BkSolPV)
        bdes = lcaGet(obj.BkSolPV) / 10 ;
        for iele=obj.InjSolBkInd
          BEAMLINE{iele}.B = bdes / length(obj.InjSolBkInd) ;
        end
      end
      fprintf('Done.');
    end
    function WriteModel(obj,fname)
      global BEAMLINE PS GIRDER WF KLYSTRON
      LEM=copy(obj.LEM); %#ok<PROPLC>
      if ~exist('fname','var') || isempty(fname)
        fname = obj.confdir+"/F2_LiveModel/LiveModel.mat" ;
      end
      save(fname,'LEM','BEAMLINE','PS','GIRDER','WF','KLYSTRON');
    end
  end
end
