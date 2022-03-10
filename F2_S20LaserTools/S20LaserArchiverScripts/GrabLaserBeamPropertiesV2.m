function beamImageData = GrabLaserBeamPropertiesV2(UserData,nCamera)
methods = {'Gaussian','Asym Gauss', 'Super Gauss','Raw RMS','RMS with peak cut',...
    'RMS area cut','RMS noise cut','4th ord. Gauss','Double Gauss','Double Asym Gauss'};
opts=struct('usemethod',UserData.fitMethod);
camerapv = UserData.camerapvs{nCamera};
disp(['Fit Method: ',methods{UserData.fitMethod},' on ',camerapv]);

try lcaGetStatus(strcat(camerapv,':Image:ArraySize0_RBV'));
catch 
    warning(['Camera status warning - no data acquired for ',camerapv]);
    beamImageData = eps*ones(UserData.nLaserParamsPerShot,1);
    return
end
% Grab image
img = profmon_grab(camerapv,0);     img = img.img;
% Sum Counts
sumCountsRaw = 1e-6*sum(sum(img));
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
% Ignore the tilt angle and calculate the humidity in the room instead
humidity = lcaGetSmart('DAQ:LA20:TM01:AF01Humidity');% S20 Humidity
% Calculate the difference between the image and a 2d Gaussian
 xmean = stats(1);ymean = stats(2);xrms = stats(3);yrms = stats(4);
 [X,Y] = meshgrid( 1:size(img,2), 1:size(img,1));
 gaussDist = 1.0/sqrt(2*pi*xrms^2).*exp(-(X-xmean).^2/2/xrms^2)*1.0/sqrt(2*pi*yrms^2).*exp(-(Y-ymean).^2/2/yrms^2);
 gaussDist = gaussDist./max(max(gaussDist));% Normalize counts

% Calculate the non-uniformity using a box ROI 
gaussDist2 = gaussDist .* double(max(max(img)));
     corrCoeff = corr2(img,gaussDist);                                                                              
     r_squared = corrCoeff^2;
% Calculate the difference image
Diff = abs((double(img)-double(gaussDist2)))./double(gaussDist2);
Diff_noWeight = abs((double(img)-double(gaussDist2)))./double(max(max(img)));

% Cut the diff image at +/- 2 sigma box (much faster than inpolygon for)
xv = [1:size(img,2)]-xmean; yv = [1:size(img,1)]-ymean;
Diff = Diff(abs(yv)<2*yrms,:); % keep all the 
Diff = Diff(:, abs(xv)<2*xrms);
p2p_homogeneity = 100*mean(mean(Diff));

Diff_noWeight = Diff_noWeight(abs(yv)<2*yrms,:); % keep all the 
Diff_noWeight = Diff_noWeight(:, abs(xv)<2*xrms);
p2p_homogeneity_smooth = 100*mean(mean(Diff_noWeight));

% For Brendan - calculate the sum counts within a +/- 2 sigma ROI box to see influence of background
imgROI = img;
imgROI = imgROI(abs(yv)<2*yrms,:);
imgROI = imgROI(:,abs(xv)<2*xrms);
sumInROI = sum(sum(imgROI))*1e-6;

% Store the outside temperature - to correlate with indoor humidity
outsideTemp = lcaGetSmart('DAQ:LA20:TM01:AF01Temp_F');

% Store beam properties in array
beamImageData = [stats(1:4)*UserData.umPerPixel(nCamera),sumCountsRaw,humidity,...
    eccentricity,r_squared,outsideTemp,p2p_homogeneity_smooth];
% Make sure none of the stored beam parameters are exactly zero - set to
% eps if they are
beamImageData(find(beamImageData==0))=eps;
% Make sure you're storing only nLaserParamsPerShot values per shot
if length(beamImageData)~=UserData.nLaserParamsPerShot
    warning(['Beam Image Data acquired on ',camerapv,...
        ' is wrong size - set to eps for this shot' ])
    beamImageData = eps*ones(UserData.nLaserParamsPerShot,1);
end

