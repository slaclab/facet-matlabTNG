if ~isdeployed 
  addpath ../epics/extensions/labca_3_7_2/bin/linux-x86_64/labca/
  addpath common
  addpath web
  addpath Lucretia/src/BeamGeneration
  addpath Lucretia/src/LatticeGeneration
  addpath Lucretia/src/LatticeVerification
  addpath Lucretia/src/MomentumProfile
  addpath Lucretia/src/OffsetsAndErrors
  addpath Lucretia/src/RMatrix
  addpath Lucretia/src/StatusAndMessages
  addpath Lucretia/src/Tracking
  addpath Lucretia/src/TuningAndAnalysis
  addpath Lucretia/src/Twiss
  addpath Lucretia/src/gui
  addpath Lucretia/src/utils
  %addpath ~/whitegr/cvs/matlab/toolbox
end
