% Analyze image with figures of merit for Vitaly
images = {'SampleRegenInput','SampleRegenOut','SamplePreampNear','SamplePreampFar',...
    'SamplePreampOut'};

methods = {'Gaussian','Asym Gauss', 'Super Gauss','Raw RMS','RMS with peak cut',...
    'RMS area cut','RMS noise cut','4th ord. Gauss','Double Gauss','Double Asym Gauss'};
camerapvs = {'CAMR:LT10:500','CAMR:LT10:600','CAMR:LT10:700'}
close all
cal = [3.75 3.75 3.75 3.75 3.75];% um/pix 
method = 2;% Fit method - for choices see beamAnalysis_beamParams.m
disp(strcat('Fit Method: ',methods{method}))
opts=struct('floor',0.1,'usemethod',method,'doPlot',0,'method',method);
smoothingSigma = 3;
for n=1
%img = importdata([images{n},'Img.mat']);

% This code is adapted from profmon_process - should be incorporated into
% my image analysis, still need to figure out the Gaussian situation
data = profmon_grab(camerapvs{n});
img = data.img;% Raw image
%[img,xsub,ysub,flag,bgs]=beamAnalysis_imgProc(data,opts);% Processed Image
% ------------------ Henrik's code ------------------------------------ 
% bin=[data.roiYN data.roiXN]./size(data.img);
% xsub=xsub*bin(2);ysub=ysub*bin(1);
% pos.x=data.roiX+xsub;
% pos.y=data.roiY+ysub;
% 
% beamParams=beamAnalysis_beamParams(img,pos.x,pos.y,bgs,opts);
% beamAnalysis_imgPlot(beamParams,img,data);
% ---------------------------------------------------------------------
% %Calculate beam statistics
 beamParams = beamAnalysis_beamParams(img, 1:size(img,2), 1:size(img,1),0,opts);


 if isfield(opts,'usemethod');stats = beamParams.stats; stats = [stats beamParams.xStat];
 else stats = beamParams(method).stats; stats = [stats beamParams(method).xStat]; end
% Fit Ellipse to beam
%opts=struct( 'figure',1,'axes',[],'ts',now,'doPlot',0);
    [ell, cross] = beamAnalysis_getEllipse(stats, 1,opts);
    
% Calculate eccentricity
    a = [cross(1,end-1)-cross(1,end-2) cross(2,end-1)-cross(2,end-2)];
    b = [cross(1,2)-cross(1,1) cross(2,2)-cross(2,1)];    

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
 
% Plot the above but in the ROI and calculate the p2p homogeneity
% Find the points within the elliptical ROI
 x_ell = real(ell(1,:));
 y_ell = real(ell(2,:));
 [X,Y] = meshgrid(1:size(img,2),1:size(img,1)) ;
idx = inpolygon(X(:),Y(:),x_ell,y_ell) ;
%A = reshape(idx,[length(yvals),length(xvals)]);% This is the 2d array which defines your ROI

% Make the 2d Gaussian
gaussDist2 = gaussDist .* double(max(max(img(idx))));

% Calculate 2d correlation coefficient between image and 2d Gaussian
 corrCoeff = corr2(img,gaussDist2);
 r_squared = corrCoeff^2;

I = double(img)-double(gaussDist2);
%I = img;
I(~idx) = NaN ;
%p2p_homogeneity = 100*(double((max(I(idx))-min(I(idx))))/mean(I(idx)));% This is for variations inside a flattop
p2p_homogeneity = 100*(mean(abs(I(idx))./double(gaussDist2(idx))));% This is for variations relative to a Gaussian
%beamImageData(n,:) = [stats(1:4)*cal(n),stats(6)*1e-6,tilt,eccentricity,r_squared,p2p_homogeneity];
% Apply 2D Gaussian smoothing to the image
%Ismooth = imgaussfilt(img,smoothingSigma);% THis works with matlab 2017
    H = fspecial('disk',smoothingSigma);
%     Ismooth = imfilter(img,H);
Ismooth = imfilter(double(img)-double(gaussDist2),H);
Ismooth(~idx) = NaN ;
%p2p_homogeneity_smooth = 100*(double((max(Ismooth(idx))-min(Ismooth(idx))))/mean(Ismooth(idx)));
p2p_homogeneity_smooth = 100*(mean(abs(double(Ismooth(idx)))./double(gaussDist2(idx))));% This is for variations relative to a Gaussian
beamImageData(n,:) = [stats(1:4)*cal(n),stats(6)*1e-6,tilt,eccentricity,r_squared,p2p_homogeneity,p2p_homogeneity_smooth];
%% Plot image with fit
figure(100+n)
 subplot(3,1,1);imagesc([1:size(img,2)]*cal(n),[1:size(img,1)]*cal(n),img);colorbar;colormap jetvar;xlabel('x [um]');ylabel('y [um]');
 hold on
 plot(x_ell*cal(n),y_ell*cal(n),'b',real(cross(1,:))*cal(n),real(cross(2,:))*cal(n),'k','Parent',gca);
 title('Raw Image on Camera')
 subplot(3,1,2);imagesc([1:size(img,2)]*cal(n),[1:size(img,1)]*cal(n),gaussDist2);colorbar;colormap jetvar;xlabel('x [um]');ylabel('y [um]');
 hold on
 plot(x_ell*cal(n),y_ell*cal(n),'b',real(cross(1,:))*cal(n),real(cross(2,:))*cal(n),'k','Parent',gca);
 title('Ideal Gaussian with RMS parameters from image')
 subplot(3,1,3);imagesc([1:size(img,2)]*cal(n),[1:size(img,1)]*cal(n),abs(I)./double(img));colorbar;colormap jetvar;xlabel('x [um]');ylabel('y [um]')
 hold on
 plot(x_ell*cal(n),y_ell*cal(n),'b',real(cross(1,:))*cal(n),real(cross(2,:))*cal(n),'k','Parent',gca);
 legend('(Real(x,y)-Ideal(x,y))/Ideal(x,y)')
 title('Difference between Real and Ideal within +/- sqrt(2)*sigma ROI')
%  subplot(4,1,4);imagesc([1:size(img,2)]*cal(n),[1:size(img,1)]*cal(n),abs(double(Ismooth))./double(img));colorbar;colormap jetvar;xlabel('x [um]');ylabel('y [um]')
%  hold on
%  plot(x_ell*cal(n),y_ell*cal(n),'b',real(cross(1,:))*cal(n),real(cross(2,:))*cal(n),'k','Parent',gca);

 figure(10)
%subplot(2,2,n)

 imagesc([1:size(img,2)]*cal(n),[1:size(img,1)]*cal(n),img)
 hold on
 plot(x_ell*cal(n),y_ell*cal(n),'b',real(cross(1,:))*cal(n),real(cross(2,:))*cal(n),'k','Parent',gca);

lim0=cell2mat(get(gca,{'XLim' 'YLim'})');
lim=lim0*[1.0 0.05;0.01 2.0];
stats(5)=stats(5)/prod(stats(3:4));
str=[strcat('x',{'mean' 'rms'},[' = %5.0f um \n']);
     strcat('y',{'mean' 'rms'},[' = %5.0f um \n'])];
str2 = strcat('sum = %6.3f Mcts', '\ntilt = %.0f deg', '\neccentr = %.2f',...
    '\nR^2 = %.3f','\np2p var = %.0f %%','\np2p var smooth = %.0f %%');
 
ht = text(2.2*lim0(1,1),0.6*lim0(2,2),sprintf([str{:} str2],beamImageData(n,:)),'Parent',gca,'VerticalAlignment','top');

set(ht,'Color',[0 0 0],'FontSize',10)
 xlabel('x  [mm]');
 ylabel('y  [mm]');
 title(images{n})
colormap jetvar
set(gca,'FontSize',16)
 colorbar
 h = colorbar;
title(h,'Counts')
drawnow;

figure(20)
%subplot(2,2,n)
imagesc([1:size(img,2)]*cal(n),[1:size(img,1)]*cal(n),I); shading interp
hold on
colormap jetvar
plot(x_ell*cal(n),y_ell*cal(n),'k','Parent',gca);
xlim([min(x_ell),max(x_ell)]*cal(n))
ylim([min(y_ell),max(y_ell)]*cal(n))
 xlabel('x  [mm]');
 ylabel('y  [mm]'); 
 set(gca,'FontSize',16)
 if isfield(opts,'cut')
 titlestr = strcat('ROI intensity , method:', methods{method},' cut = ',num2str(opts.cut,'%.2f'));
 elseif isfield(opts,'floor')
     titlestr = strcat('ROI intensity , method:', methods{method},' floor = ',num2str(opts.floor,'%.2f'));
 else
     titlestr = strcat('ROI intensity , method:', methods{method});
 end
 title(titlestr,'FontSize',14)
h = colorbar;
title(h,'Counts')

figure(30)
%subplot(2,2,n)
imagesc([1:size(img,2)]*cal(n),[1:size(img,1)]*cal(n),Ismooth); shading interp
hold on
colormap jetvar
plot(x_ell*cal(n),y_ell*cal(n),'k','Parent',gca);
xlim([min(x_ell),max(x_ell)]*cal(n))
ylim([min(y_ell),max(y_ell)]*cal(n))
colormap jetvar
 xlabel('x  [mm]');
 ylabel('y  [mm]'); 
 set(gca,'FontSize',16)
titlestr = strcat('Smoothed Img \sigma = ', num2str(smoothingSigma*cal(n)*1e3,'%.0f'),' um'); 
 title(titlestr,'FontSize',14)
end

return


%% Example of image blurring using filters (Gaussian or average)
sigmavals = [1,3,5];
for m =1:length(sigmavals)
    smoothingSigma = sigmavals(m);
%   Ismooth = imgaussfilt(img,smoothingSigma);
    H = fspecial('disk',smoothingSigma);
    Ismooth = imfilter(img,H);
Ismooth(~idx) = NaN ;
p2p_homogeneity_smooth = 100*(double((max(Ismooth(idx))-min(Ismooth(idx))))/mean(Ismooth(idx)));
figure(5)
subplot(1,3,m)
imagesc([1:size(img,2)]*cal(n),[1:size(img,1)]*cal(n),Ismooth); shading interp
hold on
colormap jetvar
plot(x_ell*cal(n),y_ell*cal(n),'k','Parent',gca);
xlim([min(x_ell),max(x_ell)]*cal(n))
ylim([min(y_ell),max(y_ell)]*cal(n))
colormap jetvar
 xlabel('x  [mm]');
 ylabel('y  [mm]'); 
 set(gca,'FontSize',16)
titlestr = strcat('Smooth Img \sigma = ', num2str(smoothingSigma*cal(n)*1e3,'%.0f'),' um, p2p = ',num2str(p2p_homogeneity_smooth,'%.0f'),'%'); 
 title(titlestr,'FontSize',14)
end