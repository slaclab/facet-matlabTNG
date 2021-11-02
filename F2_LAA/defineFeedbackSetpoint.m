function [refCamSettings,refSumCts,requestedSetpoint] = defineFeedbackSetpoint(app)
%DEFINEREQUESTEDSETPOINT 
% Grabs reference camera settings and the centroid setpoint for the
% S20 laser orbit feedback

% app.setPointOption = 2; Use current position as setpoint
% app.setPointOption = 1; Use predefined target position as setpoint

% Grab camera settings
for jj=1:length(app.camerapvs)
    [bp(jj,:),img,data]=grabLaserProperties(app,jj);
    refSumCts(jj) = bp(jj,5);% reference Sum Cts
    refCamSettings.ExposureTime(jj) = lcaGetSmart([app.camerapvs{jj},':AcquireTime']); % reference Exposure Time
    refCamSettings.ROIminX(jj) = data.roiX; % ref ROI x min
    refCamSettings.ROIminY(jj) = data.roiY; % ref ROI y min
    refCamSettings.ROIsizeX(jj) = data.roiXN; % ref ROI x size
    refCamSettings.ROIsizeY(jj) = data.roiYN; % ref ROI y size
    requestedSetpoint(1+2*(jj-1)) = bp(jj,1)-refCamSettings.ROIminX(jj);%x setpoint
    requestedSetpoint(2*jj) = bp(jj,2)-refCamSettings.ROIminY(jj);%y setpoint
end
% Grab B1 ROI manually for now
%refCamSettings.ROIminX(8)=290;refCamSettings.ROIminY(8) = 384;
            
    if app.setPointOption % Set reference centroid using pre-defined  references
%      str = 'Set point grabbed from pre-defined references';
%          app.LogTextArea.Value = [str,app.LogTextArea.Value(:)'];
%            drawnow()
      s20LaserTargetPositions = importdata('/home/fphysics/cemma/S20Laser/S20LaserAlignmentFeedback/s20LaserTargetPositions.mat');
      strs = {s20LaserTargetPositions.cameraPV};
        for jj = 1:length(app.camerapvs)
            ind=find(ismember(strs,app.camerapvs{jj}));
            requestedSetpoint(1+2*(jj-1))=s20LaserTargetPositions(ind).XmeanTarget-refCamSettings.ROIminX(jj);
            requestedSetpoint(2*jj)=s20LaserTargetPositions(ind).YmeanTarget-refCamSettings.ROIminY(jj);
        end

% Set B4 and B5 and B6 manually for now
 %   requestedSetpoint(21) = 747-refCamSettings.ROIminX(11);
 %   requestedSetpoint(22) = 289-refCamSettings.ROIminY(11);
    requestedSetpoint(23) = 673.4-refCamSettings.ROIminX(12);
    requestedSetpoint(24) = 365.08-refCamSettings.ROIminY(12);
    requestedSetpoint(25) = 587.6-refCamSettings.ROIminX(13);
    requestedSepoint(26) = 484.92-refCamSettings.ROIminY(13);
    end
end

