function [stats, img, data] = grabLaserProperties(cameraPV, fitMethod)
% GRABLASERPROPERTIES Retrives an image, camera properties, and fit.
%   Retrieves an image and returns the camera parameters from profmon_grab
%   and the results of center finding from beamAnalysis_beamParams.
%
%   Args:
%       cameraPV: The PV of the camera.
%       fitMethod: Integer describing the fit method to use, see
%           beamAnalysis_beamParams for a list of options.
%
%   Returns:
%       stats: Results of beam analysis, sumCts is in Mcounts, format is:
%           [centerX, centerY, RMSX, RMSY, sumCts].
%       img: Camera image after processing by beamAnalysis_imgProc.
%       data: Output of profmon_grab, see profmon_grab for details.

opts = struct('usemethod', fitMethod);
% Grab image
data = profmon_grab(cameraPV, 0);    
[img,~,~,~,~] = beamAnalysis_imgProc(data, opts);% If you want to use the processed Image
% Calculate beam statistics
beamParams = beamAnalysis_beamParams(img, 1:size(img,2), 1:size(img,1), 0, opts);

stats = [beamParams.stats, beamParams.xStat]; 
stats = [stats(1:4), sum(sum(img))*1e-6];
end
