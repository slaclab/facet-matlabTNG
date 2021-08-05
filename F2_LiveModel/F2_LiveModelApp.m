classdef F2_LiveModelApp < handle & F2_common
  properties
    LEM % LEM App object
    LM % Lucretia Model object
  end
  properties(SetAccess=private)
    DesignTwiss
  end
  properties(SetObservable)
    Initial % Lucretia initial structure for start of lattice
  end
  properties(Constant)
    Initial_betaxPV = "SIOC:ML01:AO401"
    Initial_betayPV = "SIOC:ML01:AO402"
    Initial_alphaxPV = "SIOC:ML01:AO403"
    Initial_alphayPV = "SIOC:ML01:AO404"
    Initial_emitxPV = "PROF:IN10:571:EMITN_X"
    Initial_emityPV = "PROF:IN10:571:EMITN_Y"
  end
  methods
    function obj = F2_LiveModelApp
      global BEAMLINE
      % Get data from design model
      LM0=LucretiaModel;
      [~,obj.DesignTwiss] = GetTwiss(1,length(BEAMLINE),LM0.Initial.x.Twiss,LM0.Initial.y.Twiss) ;
      obj.Initial = LM0.Initial;
      obj.Initial.x.NEmit = lcaGet(char(obj.Initial_emitxPV)).*1e-6 ;
      obj.Initial.y.NEmit = lcaGet(char(obj.Initial_emityPV)).*1e-6 ;
      obj.Initial.x.beta = lcaGet(char(obj.Initial_betaxPV)) ;
      obj.Initial.y.beta = lcaGet(char(obj.Initial_betayPV)) ;
      obj.Initial.x.alpha = lcaGet(char(obj.Initial_alphaxPV)) ;
      obj.Initial.y.alpha = lcaGet(char(obj.Initial_alphayPV)) ;
      % Make live model
      addpath('../F2_LEM');
      obj.LEM=F2_LEMApp; % Makes LEM object and reads in live model
      obj.LEM.Mags.ReadB(true); % sets extant magnet strengths into model
      obj.LM=copy(obj.LEM.LM);
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
      obj.LEM.UseArchive = obj.UseArchive ;
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
      save(fname,'LEM','BEAMLINE','PS','GIRDER','WF','KLYSTRON');
    end
  end
end
