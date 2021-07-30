classdef F2_LiveModelApp < handle & F2_common
  properties
    LEM % LEM App object
    LM % Lucretia Model object
  end
  methods
    function obj = F2_LiveModelApp
      addpath('../F2_LEM');
      obj.LEM=F2_LEMApp; % Makes LEM object and reads in live model
      obj.LEM.Mags.ReadB(true); % sets extant magnet strengths into model
      obj.LM=copy(obj.LEM.LM);
    end
    function UpdateModel(obj)
      fprintf('Updating live model...');
      obj.LEM.UpdateModel;
      obj.LEM.Mags.ReadB(true); % sets extant magnet strengths into model
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
