function [beamImageData,img] = GrabLaserBeamPropertiesV4(UserData,nCamera)
methods = {'Gaussian','Asym Gauss', 'Super Gauss','Raw RMS','RMS with peak cut',...
    'RMS area cut','RMS noise cut','4th ord. Gauss','Double Gauss','Double Asym Gauss'};
opts=struct('usemethod',UserData.fitMethod);
%disp(strcat('Fit Method: ',methods{UserData.fitMethod}));
camerapv = UserData.camerapvs{nCamera};
% Check that the camera is acquiring data (i.e. image array size > 0)
try lcaGetStatus(strcat(camerapv,':Image:ArraySize0_RBV'));
catch
    warning(['Camera status warning - no data acquired for ',camerapv])
    beamImageData = eps*ones(10,1);
    img = [];
    return
end
% Grab image
data = profmon_grab(camerapv,0);     img = data.img;
% Sum counts
sumCountsRaw = 1e-6*sum(sum(img));
[img,xsub,ysub,flag,bgs]=beamAnalysis_imgProc(data,opts);% Processed Image
% Calculate frame rate just to see if that's causing intensity spikes
frameRate = lcaGetSmart([camerapv,':ArrayRate_RBV']);
% Calculate beam statistics
 beamParams = beamAnalysis_beamParams(img, 1:size(img,2), 1:size(img,1),0,opts);
 
 if isfield(opts,'usemethod');stats = beamParams.stats; stats = [stats beamParams.xStat];
 else stats = beamParams(UserData.fitMethod).stats; stats = [stats beamParams(UserData.fitMethod).xStat]; end
% Fit rms Ellipse to beam
%opts=struct( 'figure',1,'axes',[],'ts',now,'doPlot',0);
    [ell, cross] = beamAnalysis_getEllipse(stats, 1,opts);
    
% Calculate eccentricity
    a = [cross(1,end-1)-cross(1,end-2) cross(2,end-1)-cross(2,end-2)];
    b = [cross(1,2)-cross(1,1) cross(2,2)-cross(2,1)];    
    
% Calculate tilt angle 
ax1 = sqrt((cross(1,end-1)-cross(1,end-2)).^2+(cross(2,end-1)-cross(2,end-2)).^2);
ax2 = sqrt((cross(1,2)-cross(1,1)).^2+(cross(2,2)-cross(2,1)).^2);
if ax1>ax2; eccentricity = ax1/ax2; else eccentricity = ax2/ax1;end
anglex1 = acosd(a(1,1)./ax1); anglex2 = acosd(b(1,1)./ax2);
tilt = min(anglex1,anglex2);

% Calculate the difference between the image and a 2d Gaussian
 xmean = stats(1);ymean = stats(2);xrms = stats(3);yrms = stats(4);
 [X,Y] = meshgrid( 1:size(img,2), 1:size(img,1));
 gaussDist = 1.0/sqrt(2*pi*xrms^2).*exp(-(X-xmean).^2/2/xrms^2)*1.0/sqrt(2*pi*yrms^2).*exp(-(Y-ymean).^2/2/yrms^2);
 gaussDist = gaussDist./max(max(gaussDist));% Normalize counts

% Don't do the ROI calculation with inpolygon (it's too slow) 
 % Make the ideal 2d Gaussian
 gaussDist = gaussDist .* double(max(max(img)));

% Calculate 2d correlation coefficient between image and 2d Gaussian
 corrCoeff = corr2(img,gaussDist);
 r_squared = corrCoeff^2; 
% Calculate the difference image
Diff = abs((double(img)-double(gaussDist)))./double(gaussDist);
Diff_noWeight = abs((double(img)-double(gaussDist)))./double(max(max(img)));

% Cut the diff image at +/- 2 sigma box (faster than inpolygon for live plotting)
xv = [1:size(img,2)]-xmean; yv = [1:size(img,1)]-ymean;
Diff = Diff(abs(yv)<2*yrms,:); % keep all the 
Diff = Diff(:, abs(xv)<2*xrms);
p2p_homogeneity = mean(mean(Diff));
% Calculate p2p uniformity without weighting
Diff_noWeight = Diff_noWeight(abs(yv)<2*yrms,:); % keep all the 
Diff_noWeight = Diff_noWeight(:, abs(xv)<2*xrms);
p2p_homogeneity_smooth = 100*mean(mean(Diff_noWeight));

% Ignore the tilt angle and calculate the humidity in the room instead
humidity = lcaGetSmart('DAQ:LR10:TM01:AF01Humidity');
% For Brendan - calculate the sum counts within a +/- 2 sigma ROI box to see influence of background
imgROI = img;
imgROI = imgROI(abs(yv)<2*yrms,:);
imgROI = imgROI(:,abs(xv)<2*xrms);
sumInROI = sum(sum(imgROI))*1e-6;

%Store image data in array
beamImageData = [stats(1:4)*UserData.umPerPixel(nCamera),sumCountsRaw,...
    humidity,eccentricity,r_squared,frameRate,p2p_homogeneity_smooth];
