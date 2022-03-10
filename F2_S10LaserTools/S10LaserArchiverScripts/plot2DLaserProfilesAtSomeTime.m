function plot2DLaserProfilesAtSomeTime(dateAndTime)
UserData.cameraPVs = {'CAMR:LT10:500','CAMR:LT10:600','CAMR:LT10:800','CAMR:LT10:700','CAMR:LT10:200','CAMR:LT10:380','CAMR:LT10:900'};
UserData.cameraNames = {'Oscillator Out', 'Regen Out','MPA Out','Compressor Out','UV Conv. Out', 'CIRIS','VCC'};
rootPath = '/u1/facet/matlab/data/';
UserData.umPerPixel = [3.75,4.08,3.75,4.08,9.9,9.9,4.65];         % From Manta G-125 and G-095 and G-033Bspec sheets respectively 
UserData.magnification = [0.0475,0.425,0.27,0.2,0.68,0.44,0.63];
%%%%% THE ABOVE NEEDS TO BE MEASURED / CALIBRATED AGAINST THE CAMERAS %%%%
t1 = datenum(dateAndTime);
requestedHour = str2num(datestr(t1,'HH'));
for jj=1:length(UserData.cameraPVs)    
    clearvars theHour
    pth = [rootPath,'/',datestr(t1,'yyyy'),'/',datestr(t1,'yyyy-mm'),'/',datestr(t1,'yyyy-mm-dd'),'/'];                                    
    filelist = dir(pth);                          
    mfile = find(~cellfun(@isempty,regexp({filelist.name},UserData.cameraPVs{jj})));  
    %if length(mfile)>1
    %if jj~=3;mfile = mfile(1:end-1);else;mfile = mfile(2:end);end% Remove the Health report file from the list
    %end
    files = {filelist(mfile).name};   if isempty(files);disp('No data found');continue;end
    for ij = 1:length(mfile)-1;theHour(ij) = str2num(files{ij}(15:16));end% Get the hour of the image  the -1 removes the Health report      
    [~,idx] = min(abs(requestedHour-theHour));

    img = importdata([pth,files{idx}]);
    sumCounts = sum(sum(img))*1e-6;
    % Crop image
    % Find the smallest dimension and set the x-y limits to that
    opts = struct('usemethod',2);% Asymmetric Gaussian
     beamParams = beamAnalysis_beamParams(img, 1:size(img,2), 1:size(img,1),0,opts);
    x_com = beamParams.stats(1);y_com = beamParams.stats(2);%figure(jj);imagesc(img);disp(y_com)
    sigmax = beamParams.stats(3);sigmay = beamParams.stats(4);
    [smalldim,~]= min(size(img));  [largedim,idxlargedim]= max(size(img));
    %[~,sigmax]=fit_gaussian(sum(img,1)./max(sum(img,1)));[~,sigmay]=fit_gaussian(sum(img,2)'./max(sum(img,2)));
    %[~,x_c]= max(sum(img,1)); [~,y_c]= max(sum(img,2)); % Centroid from peak of projection
    %x_com = round(sum(([1:length(sum(img,1))].*sum(img,1)))./sum(sum(img,1))); % Centroid from COM
    %y_com = round(sum(([1:length(sum(img,2))].*sum(img,2)'))./sum(sum(img,2))); 
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
    
    
    %{ 
    % Optional Annotations for Plot
    
%     workingPoint(jj,1:2) = datamean(3:4);% spotsize x,y
%     workingPoint(jj,3) = size(img,2)*UserData.umPerPixel(jj)/datamean(3);% Chip Size / spotsize x
%     workingPoint(jj,4) = size(img,1)*UserData.umPerPixel(jj)/datamean(4);% Chip Size / spotsize y
%     workingPoint(jj,5) = 100* UserData.umPerPixel(jj)/datamean(3);% Pixel Size / spotsize x in %
%     workingPoint(jj,6) = 100* UserData.umPerPixel(jj)/datamean(4);% Pixel Size / spotsize y in %
%     workingPoint(jj,7) = abs(datamean(1)-round(size(img,2))*UserData.umPerPixel(jj)/2)/datamean(3);% Centr. Offset / spotsize x
%     workingPoint(jj,8) = abs(datamean(2)-round(size(img,1))*UserData.umPerPixel(jj)/2)/datamean(4);% Centr. Offset / spotsize y
%     workingPoint(jj,9) = 100*(double(max(max(img)))/4096);% Max Counts / 4096
%     workingPoint(jj,10) = datamean(end);% p2p homogeneity
%     workingPoint(jj,11) = datamean(end-2);% R^2
%     workingPoint(jj,12) = datamean(end-3);% eccentricity
    
%     str=[strcat('x',{'mean' 'rms'},[' = %5.0f um \n']);
%      strcat('y',{'mean' 'rms'},[' = %5.0f um \n'])];
%     str2 = strcat(' Spot Size (x,y) = %2.0f %2.0f um','\n Chip Size / Spot Size = %2.0f %2.0f', '\n Pixel Size / spot Size = %2.1f %2.1f %%', ...
%     '\n Centr. Offset/ spot Size = %2.1f %2.1f','\n Max Cts/4096 = %.0f %%',...
%     '\n Nonuniformity = %.0f %%','\n R^2 = %2.2f ','\n Eccentr = %2.2f \n',datestr(now,'mm/dd/yyyy HH:MM'));
%     ht = text(2.2*lim0(1,1),0.05*lim0(2,2),sprintf([str2],workingPoint(jj,:)),'Parent',gca,'VerticalAlignment','top','FontSize',8);

    %}
end
