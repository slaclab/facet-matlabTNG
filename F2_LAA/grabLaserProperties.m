function [beamImageData,img,data] = grabLaserProperties(UserData,nCamera)
methods = {'Gaussian','Asym Gauss', 'Super Gauss','Raw RMS','RMS with peak cut',...
    'RMS area cut','RMS noise cut','4th ord. Gauss','Double Gauss','Double Asym Gauss'};
if isfield(UserData,'umPerPixel');else;UserData.umPerPixel(nCamera) = 1;end
if isfield(UserData,'fitMethod');opts=struct('usemethod',UserData.fitMethod);
else opts = struct('usemethod',2);end % Set Asym Gaussian as default fit method
%disp(strcat('Fit Method: ',methods{UserData.fitMethod}));
camerapv = UserData.camerapvs{nCamera};
% Check that the camera is acquiring data (i.e. image array size > 0)
if verLessThan('matlab','9.6')
try lcaGetStatus(strcat(UserData.camerapvs{nCamera},':Image:ArraySize0_RBV'))
catch
    warning(['Camera status warning - no data acquired for ',UserData.camerapvs{nCamera}])
    beamImageData = eps*ones(10,1);
    img = [];
    return
end
end
% Add background
%data.back = backGrounds.img;
% Grab image
data = profmon_grab(UserData.camerapvs{nCamera},0);    
img = data.img;% If u want to use unprocessed image for centroid finding
[img,~,~,~,~]=beamAnalysis_imgProc(data,opts);% If you want to use the processed Image
% Calculate beam statistics
 beamParams = beamAnalysis_beamParams(img, 1:size(img,2), 1:size(img,1),0,opts);
 
 if isfield(opts,'usemethod');stats = beamParams.stats; stats = [stats beamParams.xStat];
 else stats = beamParams(UserData.fitMethod).stats; stats = [stats beamParams(UserData.fitMethod).xStat]; end   

beamImageData = [stats(1:4),sum(sum(img))*1e-6];
