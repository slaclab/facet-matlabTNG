function plot2DLaserProfilesAtSomeTime(dateAndTime)
UserData.camerapvs = {'EXPT:LI20:3300','EXPT:LI20:3301','EXPT:LI20:3302','EXPT:LI20:3303',...
    'EXPT:LI20:3304','EXPT:LI20:3305','EXPT:LI20:3306','EXPT:LI20:3306'};
UserData.cameraNames = {'S20 Osc Out', 'S20 Regen Out','S20 Preamp Near','S20 Preamp Far',...
    'S20 Preamp Out', 'S20 MPA Near','S20 MPA Far','S20 Launch'};
rootPath = '/u1/facet/matlab/data/';
UserData.umPerPixel = [3.75,3.75,3.75,3.75,9.9,4.08,4.08,4.08];     %        % From Manta G-125 and G-095 and G-033Bspec sheets respectively 
UserData.magnification = [1,1,1,1,1,1,1,1];
%%%%% THE ABOVE NEEDS TO BE MEASURED / CALIBRATED AGAINST THE CAMERAS %%%%
t1 = datenum(dateAndTime);
requestedHour = str2num(datestr(t1,'HH'));
for jj=1:length(UserData.cameraPVs) 
    
    clearvars theHour
    pth = [rootPath,'/',datestr(t1,'yyyy'),'/',datestr(t1,'yyyy-mm'),'/',datestr(t1,'yyyy-mm-dd'),'/'];                                    
    filelist = dir(pth);                          
    mfile = find(~cellfun(@isempty,regexp({filelist.name},UserData.cameraPVs{jj})));  
    files = {filelist(mfile).name};   if isempty(files);disp('No data found');continue;end
    if all(datestr(t1,'yyyy-mm-dd')==datestr(now,'yyyy-mm-dd'))% today
        for ij = 1:length(mfile);theHour(ij) = str2num(files{ij}(15:16));end% Get the hour of the image   
        [~,idx] = min(abs(requestedHour-theHour));
        img = importdata([pth,files{idx}]);
    else% All other days except today
        hReport = importdata(strcat(pth,files{end}));
        img = hReport.laserImages(requestedHour).img;
    end

    sumCounts = sum(sum(img))*1e-6;
    % Crop image
    % Find the smallest dimension and set the x-y limits to that
    opts = struct('usemethod',2);% Asymmetric Gaussian
     beamParams = beamAnalysis_beamParams(img, 1:size(img,2), 1:size(img,1),0,opts);
    x_com = beamParams.stats(1);y_com = beamParams.stats(2);%figure(jj);imagesc(img);disp(y_com)
    sigmax = beamParams.stats(3);sigmay = beamParams.stats(4);
    sigma = max(sigmax,sigmay);
    nSig = 4;    
    %if jj==length(UserData.cameraPVs);x_com = x_c;end% Issue with x_com
    cdims = [y_com-nSig*sigma<0,y_com+nSig*sigma>size(img,1),x_com-nSig*sigma<0,x_com+nSig*sigma>size(img,2)];
    Ddims = round([y_com-nSig*sigma,y_com+nSig*sigma,x_com-nSig*sigma,x_com+nSig*sigma]);
         
    if ~any(logical(cdims))
    imgcrop = img(round((y_com-nSig*sigma)):round((y_com+nSig*sigma)),round((x_com-nSig*sigma)):round((x_com+nSig*sigma)));    
        else
             for jk = 1:4
             if mod(jk,2);cropDim(jk) = max(1,Ddims(jk));else;cropDim(jk) = min(size(img,jk/2),Ddims(jk));end %#ok<*AGROW,NOSEM>
             end        
         imgcrop = img(cropDim(1):cropDim(2),cropDim(3):cropDim(4));
    end
                               
    % Set the image equal to the cropped image before plotting
    if jj~=length(UserData.cameraPVs);img = imgcrop;end
        X = ([1:size(img,2)]-round(size(img,2)/2))*UserData.umPerPixel(jj)*1e-3/UserData.magnification(jj);
        Y = ([1:size(img,1)]-round(size(img,1)/2))*UserData.umPerPixel(jj)*1e-3/UserData.magnification(jj);                  
    % Draw stuff
    figure(55);      
    % Enlarge figure to full screen.
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.5, 0.8, 0.8]);
    subplot(2,4,jj);    
    imagesc(X,Y,img);colormap jetvar;xlabel('x [mm]');ylabel('y [mm]');
    %if jj ==length(UserData.cameraPVs);axis([x_com-2*sigma x_com+2*sigma y_com-2*sigma y_com+2*sigma]*1e-3/UserData.magnification(jj));end % Fix VCC axis manually   
    lim0=cell2mat(get(gca,{'XLim' 'YLim'})');
    lim=lim0*[1.0 0.05;0.01 2.0];
    
    title([UserData.cameraNames{jj}],'FontSize',14);
    if regexp(UserData.cameraNames{jj},'Oscillator Out');str1 = ' [mW]';else;str1 = ' [mJ]';end
        hg = text(lim0(1,1),0.8*lim0(2,2),['Max Counts/4096 = ',...
            num2str(double(max(max(img)))/4096,'%.2f'),char(10),...
            'Energy',str1,' = ',num2str(energyCalibration(UserData,jj,sumCounts),'%.3f')],'Parent',gca,'FontSize',10,'FontName','Times');
    if jj ==1
        ht = text(1.85*lim0(1,1),-1.35*lim0(2,2),[datestr(t1,'mm-dd-yyyy HH:MM') char(10) datestr(t1,'HH:MM')],'Parent',gca,'VerticalAlignment','top','FontSize',10,'FontName','Times');
    end  
    set(gca,'FontName','Times','LineWidth',2)
    
end
