if ~isdeployed 
  addpath ../epics/extensions/labca_3_7_2/bin/linux-x86_64/labca/
  addpath common
  addpath web
  ldir="/usr/local/facet/tools/Lucretia/src/" ;
  addpath(ldir+"BeamGeneration");
  addpath(ldir+"LatticeGeneration");
  addpath(ldir+"LatticeVerification");
  addpath(ldir+"MomentumProfile");
  addpath(ldir+"OffsetsAndErrors");
  addpath(ldir+"RMatrix");
  addpath(ldir+"StatusAndMessages");
  addpath(ldir+"Tracking");
  addpath(ldir+"TuningAndAnalysis");
  addpath(ldir+"Twiss");
  addpath(ldir+"gui");
  addpath(ldir+"utils");
  %addpath ~/whitegr/cvs/matlab/toolbox
end
