function [Xcentroid,Ycentroid] = displayLaserCentroidForSingleCamera(cameraPV)
% Display laser centroid on camera. The user has to input the camera PV
% Example:  [Xcentroid,Ycentroid] = displayLaserCentroidForSingleCamera('CAMR:LT20:100');

% Get the laser centroid using the same method as the auto-aligner
opts = struct('usemethod',2);
data = profmon_grab(cameraPV,0);    
[img,~,~,~,~]=beamAnalysis_imgProc(data,opts);% The Auto-aligner uses the processed Image for fitting

% Calculate beam statistics
beamParams = beamAnalysis_beamParams(img, 1:size(img,2), 1:size(img,1),0,opts);
stats = beamParams.stats;

Xcentroid = stats(1);
Ycentroid = stats(2);

figure;imagesc(img);xlabel('X [pix]');ylabel('Y [pix]');
hold on;plot(Xcentroid,Ycentroid,'r*','MarkerSize',10);
str = sprintf(['Xctr = ',num2str(Xcentroid,'%.2f'), ' Yctr = ',num2str(Ycentroid,'%.2f')]);
title(str)
set(gca,'FontSize',20,'LineWidth',2)
end