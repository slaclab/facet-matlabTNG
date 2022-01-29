if ~isdeployed 
  if getenv('IOCCONSOLE_ENV')~="Dev"
    addpath ../epics/extensions/labca_3_7_2/bin/linux-x86_64/labca/
  end
  addpath('/usr/local/facet/tools/AIDA-Matlab/src'); % AIDA-PVA Matlab support
  addpath common % overrides some AIDA-PVA stuff (aidapvainit)
  addpath web
  addpath python
  addpath F2_LiveModel
  if string(getenv('IOCCONSOLE_ENV'))=="Dev"
    ldir="/afs/slac/g/ilc/codes/Lucretia/src/";
  else
    ldir="/usr/local/facet/tools/Lucretia/src/" ;
  end
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
  aidapvainit;
end
