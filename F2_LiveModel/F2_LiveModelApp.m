classdef F2_LiveModelApp < handle & F2_common
  properties
    LEM % LEM App object
    LM % Lucretia Model object
    Initial % Lucretia initial structure for start of lattice
  end
  properties(SetAccess=private)
    DesignTwiss
    DesignInitial
    pvs
    pvlist
  end
  properties(Access=private)
    InjSolInd
    InjSolBkInd
  end
  properties(SetObservable)
    ModelSource string {mustBeMember(ModelSource,["Live" "Archive" "Design"])} = "Live"
  end
  properties(Constant)
    Initial_betaxPV = "SIOC:SYS1:ML01:AO401"
    Initial_betayPV = "SIOC:SYS1:ML01:AO402"
    Initial_alphaxPV = "SIOC:SYS1:ML01:AO403"
    Initial_alphayPV = "SIOC:SYS1:ML01:AO404"
    Initial_emitxPV = "PROF:IN10:571:EMITN_X"
    Initial_emityPV = "PROF:IN10:571:EMITN_Y"
  end
  methods
    function obj = F2_LiveModelApp(KlysZero)
      global BEAMLINE
      
      % Get data from design model
      obj.LM=LucretiaModel;
      [~,obj.DesignTwiss] = GetTwiss(1,length(BEAMLINE),obj.LM.Initial.x.Twiss,obj.LM.Initial.y.Twiss) ;
      obj.DesignInitial = obj.LM.Initial ;
      
      % PV lists
      cntx=PV.Initialize(PVtype.EPICS);
      obj.pvlist=[PV(cntx,'name',"betax",'pvname',obj.Initial_betaxPV);
                  PV(cntx,'name',"betay",'pvname',obj.Initial_betayPV);
                  PV(cntx,'name',"alphax",'pvname',obj.Initial_alphaxPV);
                  PV(cntx,'name',"alphay",'pvname',obj.Initial_alphayPV)
                  PV(cntx,'name',"emitx",'pvname',obj.Initial_emitxPV)
                  PV(cntx,'name',"emity",'pvname',obj.Initial_emityPV)] ;
      pset(obj.pvlist,'debug',0) ;
      obj.pvs = struct(obj.pvlist) ;
      
      % Get Initial Twiss parameters from last injector emittance scan
      obj.Initial = obj.LM.Initial;
      obj.Initial.x.NEmit = caget(obj.pvs.emitx).*1e-6 ;
      obj.Initial.y.NEmit = caget(obj.pvs.emity).*1e-6 ;
      obj.Initial.x.beta = caget(obj.pvs.betax) ;
      obj.Initial.y.beta = caget(obj.pvs.betay) ;
      obj.Initial.x.alpha = caget(obj.pvs.alphax) ;
      obj.Initial.y.alpha = caget(obj.pvs.alphay) ;
      
      % Make live model
      addpath('../F2_LEM');
      if obj.ModelSource~="Design"
        if ~exist('KlysZero','var')
          obj.LEM=F2_LEMApp; % Makes LEM object and reads in live model
        else
          obj.LEM=F2_LEMApp([],KlysZero); % Makes LEM object and reads in live model
        end
        obj.LEM.Mags.ReadB(true); % sets extant magnet strengths into model
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
          % Load Initial structure from archived injector emittance scan data
          pset(obj.pvlist,'ArchiveDate',obj.ArchiveDate) ;
          obj.Initial.x.NEmit = caget(obj.pvs.emitx).*1e-6 ;
          obj.Initial.y.NEmit = caget(obj.pvs.emity).*1e-6 ;
          obj.Initial.x.beta = caget(obj.pvs.betax) ;
          obj.Initial.y.beta = caget(obj.pvs.betay) ;
          obj.Initial.x.alpha = caget(obj.pvs.alphax) ;
          obj.Initial.y.alpha = caget(obj.pvs.alphay) ;
        case "Design"
          obj.UseArchive=false;
          obj.LEM.UseArchive=false;
          obj.LEM.SetDesignModel;
      end
      obj.ModelSource=src;
    end
%     function set.Initial(obj,Inew)
%       global BEAMLINE
%       [stat,Twiss] = GetTwiss(1,length(BEAMLINE),Inew.x.Twiss,Inew.y.Twiss) ;
%       if stat{1}~=1
%         error('Invalid Initial structure')
%       else
%         obj.DesignTwiss = Twiss;
%         obj.Initial = Inew ;
%       end
%     end
    function UpdateModel(obj)
      fprintf('Updating live model...');
      % Sync archiver settings
      obj.LEM.ArchiveDate = obj.ArchiveDate ;
      obj.LEM.UpdateModel; % Updates Klystron and momentum profile data and scales magnets in model (with Arcived Klystron data if requested)
      obj.LEM.Mags.ReadB(true); % sets back extant or Archive magnet strengths into model
      fprintf('Done.');
    end
    function WriteModel(obj,fname)
      global BEAMLINE PS GIRDER WF KLYSTRON
      LEM=copy(obj.LEM); %#ok<PROPLC>
      if ~exist('fname','var') || isempty(fname)
        fname = obj.confdir+"/F2_LiveModel/LiveModel.mat" ;
      end
      Initial=obj.Initial; %#ok<PROPLC>
      save(fname,'LEM','BEAMLINE','PS','GIRDER','WF','KLYSTRON','Initial');
    end
    function LoadModel(obj,fname)
      global BEAMLINE PS GIRDER WF KLYSTRON
      if ~exist('fname','var') || isempty(fname)
        fname = obj.confdir+"/F2_LiveModel/LiveModel.mat" ;
      end
      load(fname,'LEM','BEAMLINE','PS','GIRDER','WF','KLYSTRON','Initial');
      obj.LEM=LEM; %#ok<PROPLC>
      obj.Initial=Initial; %#ok<PROPLC>
    end
  end
end
