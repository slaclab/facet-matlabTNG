function config = defineFeedbackSetpoint(config, fitMethod)
% DEFINEFEEDBACKSETPOINT Grabs reference camera settings and centroid.
%   Loops through all the cameras in the config struct and calls
%   grabLaserProperties for each camera. The results are inserted into each
%   individual camera struct.
%
%   Args:
%       config: Config struct with sections and cameras.
%       fitMethod: Integer describing the fit method to use, see
%           beamAnalysis_beamParams for a list of options.
%
%   Returns:
%       config: Config struct after adding refSumCts, refRMSSize,
%       refROIminX, refROIminY, refROIsizeX, and refROIsizeY to each
%       camera.


% Grab camera settings
sections = fieldnames(config);
for i=1:numel(sections)
    section = config.(sections{i});
    section.gain = lcaGetSmart(section.gainPV);
    cameras = fieldnames(section.cameras);
    for j=1:numel(cameras)
        camera = section.cameras.(cameras{j});
        camera = getParamsAndStats(camera, fitMethod);
        config.(sections{i}).cameras.(cameras{j}) = camera;
    end
end
end