function [camera] = getParamsAndStats(camera, fitMethod)
%GETPARAMSANDSTATS Loads and image and gets reference stats from it.
%   Calls grabLaserProperties for the given camera. The results are
%   inserted into the camera structure struct.
%
%   Args:
%       camera: struct containing all the information for a camera.
%
%   Returns
%       camera: struct containing all the information for a camera.

[stats, ~, data] = grabLaserProperties(camera.cameraPV, fitMethod);
camera.refSumCts = stats(5);
camera.refRMSSize = [stats(3), stats(4)];
camera.refExposureTime = lcaGetSmart([camera.cameraPV,':AcquireTime']);
camera.refROIminX = data.roiX;
camera.refROIminY = data.roiY;
camera.refROIsizeX = data.roiXN;
camera.refROIsizeY = data.roiYN;
camera.TS = data.ts;
end

