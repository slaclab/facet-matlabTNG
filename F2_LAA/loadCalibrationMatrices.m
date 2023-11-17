function config = loadCalibrationMatrices(config)
%LOADCALIBRATIONMATRICES Load the calibration matrices for each section.

sections = fieldnames(config);
for i=1:numel(sections)
    section = config.(sections{i});
    section.gain = lcaGetSmart(section.gainPV);
    disp(section.calibrationMatrixPath)
    section.calibrationMatrix = importdata(section.calibrationMatrixPath);
    config.(sections{i}) = section;
end
end

