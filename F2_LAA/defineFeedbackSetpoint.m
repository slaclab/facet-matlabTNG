function [refCamSettings,refSumCts,requestedSetpoint,refRMSVals] = defineFeedbackSetpoint(app)
%DEFINEREQUESTEDSETPOINT 
% Grabs reference camera settings and the centroid setpoint for the
% S20 laser orbit feedback

% app.setPointOption = 2; Use current position as setpoint
% app.setPointOption = 1; Use predefined target position as setpoint

% Grab camera settings
for jj=1:length(app.camerapvs)
    [bp(jj,:),img,data]=grabLaserProperties(app,jj);
    refSumCts(jj) = bp(jj,5);% reference Sum Cts
    refRMSVals(1+2*(jj-1)) = bp(jj,3);%xrms ref
    refRMSVals(2*jj) = bp(jj,4);%yrms ref
    refCamSettings.ExposureTime(jj) = lcaGetSmart([app.camerapvs{jj},':AcquireTime']); % reference Exposure Time
    refCamSettings.ROIminX(jj) = data.roiX; % ref ROI x min
    refCamSettings.ROIminY(jj) = data.roiY; % ref ROI y min
    refCamSettings.ROIsizeX(jj) = data.roiXN; % ref ROI x size
    refCamSettings.ROIsizeY(jj) = data.roiYN; % ref ROI y size
    requestedSetpoint(1+2*(jj-1)) = bp(jj,1)-refCamSettings.ROIminX(jj);%x setpoint
    requestedSetpoint(2*jj) = bp(jj,2)-refCamSettings.ROIminY(jj);%y setpoint
    
%         disp(lcaGetSmart([app.camerapvs{jj},':NAME']))
%         disp(refSumCts(jj))
end
          
    if app.setPointOption % Set reference centroid using pre-defined references
      %s20LaserTargetPositions = importdata('/home/fphysics/cemma/S20Laser/S20LaserAlignmentFeedback/s20LaserTargetPositionswMPA.mat');
      s20LaserTargetPositions = importdata('/usr/local/facet/tools/matlabTNG/F2_LAA/s20LaserTargetPositionswMPA.mat');
      strs = {s20LaserTargetPositions.cameraPV};
        for jj = 1:length(app.camerapvs)
            ind=find(ismember(strs,app.camerapvs{jj}));
            requestedSetpoint(1+2*(jj-1))=s20LaserTargetPositions(ind).XmeanTarget-refCamSettings.ROIminX(jj);
            requestedSetpoint(2*jj)=s20LaserTargetPositions(ind).YmeanTarget-refCamSettings.ROIminY(jj);
% Diagnostic comments
%         disp(lcaGetSmart([app.camerapvs{jj},':NAME']))
%         disp(requestedSetpoint(1+2*(jj-1))+refCamSettings.ROIminX(jj))
%         disp(requestedSetpoint(2*jj)+refCamSettings.ROIminY(jj))
%             rs(1+2*(jj-1))=s20LaserTargetPositions(ind).XmeanTarget;
%             rs(2*jj)=s20LaserTargetPositions(ind).YmeanTarget;
%             disp(refCamSettings.ROIminX(jj)) 
%             disp(refCamSettings.ROIminY(jj)) 
        end
    
    end
     
end

