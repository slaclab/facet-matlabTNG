function makeLaserHistoryPlots(hObject,startTimeStamp,endTimeStamp,handles)
set(handles.text5,'String',' ');
s10cameraHandles = get(handles.uitable1, 'Data');    s20cameraHandles = get(handles.uitable2,'Data');
s10camerasSelected = find(cell2mat(s10cameraHandles(:,2)));   
s20camerasSelected = find(cell2mat(s20cameraHandles(:,2)))+numel(s10cameraHandles(:,2));
camerasSelected = [s10camerasSelected;s20camerasSelected];
allcameraHandles = [s10cameraHandles;s20cameraHandles];
%uvcampvs = {'CAMR:LT10:200','CAMR:LT10:380','CAMR:LT10:450','CAMR:LT10:900'};% This is if u wanna plot the waveplate angle
%camerasSelected = find(cell2mat(s10cameraHandles(:,2)));% This was for just S10 cameras
nDataPointsPerShot = 13;% This should come straight from the dataset - fix in future releases
t1 = startTimeStamp;    t2 = endTimeStamp;
handles.UserData = struct();% For storing and saving data
%%%%%%%%%%%%%%%%%% USER INPUT ABOVE THIS LINE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for n=1:length(camerasSelected)
    clearvars t data        
    [t,data]=fetchLaserArchiverData(t1,t2,camerasSelected,n);
    %if isempty(t);set(handles.text5,'String','No data found for that time interval');continue;end    
    if isempty(t);continue;end
    timeTicks = linspace(t(1),t(end),4);
    %data(1:4,:) = data(1:4,:)/handles.magnification(camerasSelected(n));
    % Calculate energy jitter and moving average
    energyJitter = 100*(data(5,:)-mean(data(5,:)))./mean(data(5,:));    
    movingAverageEnergy=movMeanCemma(energyJitter, 59);
    % Calculate centroid jitter
    xcentroidJitter = 100*(data(1,:)-mean(data(1,:)))./data(3,:);
    ycentroidJitter = 100*(data(2,:)-mean(data(2,:)))./data(4,:);
    % Calculate moving average for p2p variation
    movingAveragep2p= movMeanCemma(data(10,:),59);
    % Grab waveplate history - this doesn't work yet
    %[wpDataInterp,makeWaveplatePlot] = interpolateHistoryData('WPLT:LT10:150:WP_ANGLE',t);

    % Make the plots
    figure(n);set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.5, 0.7, 0.7]);
    hAx(1) = subplot(2,3,1);
        plot(t,data(3,:)*1e-3);      hold on;     plot(t,data(4,:)*1e-3,'r'); grid on
        ylabel(['Rms Spotsize [pix]' char(10),'Lens Magnfication = ',num2str(1/handles.magnification(camerasSelected(n)),'%.2f'),...
            char(10),'Pixel Size [um] = ',num2str(handles.umPerPixel(camerasSelected(n)),'%.2f')],'interpreter','tex')        

    hAx(2) = subplot(2,3,2);
    yyaxis left
        %plot(t,data(1,:)*handles.magnification(camerasSelected(n))/handles.umPerPixel(camerasSelected(n)));
        plot(t,data(1,:))
        ylabel('X Centr. position [pix]','interpreter','tex')
    yyaxis right
        %plot(t,data(2,:)*handles.magnification(camerasSelected(n))/handles.umPerPixel(camerasSelected(n)));
        plot(t,data(2,:))
        ylabel('Y Centr. position [pix]','interpreter','tex');         
        title(allcameraHandles(camerasSelected(n),1),'FontSize',20)

    hAx(3) =subplot(2,3,3);
       p1 = plot(t,energyJitter);  ylabel('Energy Jitter [%]','interpreter','tex'); grid on    
        % If this is a UV camera plot waveplate angle
       %if  contains(handles.cameraPVs{camerasSelected(n)},uvcampvs) && makeWaveplatePlot
       %    yyaxis right;plot(t,wpDataInterp);ylabel('Waveplate Angle [deg]');end
       % Make the energy plot legend
       if regexp(handles.cameraPVs{camerasSelected(n)},'EXPT:LI20');str1 = 'Mean E [MCts] = ';
       elseif regexp(handles.cameraPVs{camerasSelected(n)},'CAMR:LT10:500');str1 = 'Mean E [mW] = ';
       else;str1 = 'Mean E [mJ] = ';end   
    %   legend([p1,p2],{[str1,num2str(mean(energyCalibration(handles,camerasSelected(n),data(5,:))),'%.3f')],'Avg 1 hr'},'FontSize',6);
       legend([str1,num2str(mean(energyCalibration(handles,camerasSelected(n),data(5,:))),'%.3f')],'FontSize',6);
       legend boxoff
            
    hAx(4) =subplot(2,3,4);
    yyaxis left
        plot(t,data(6,:));    ylabel('Humidity [%]','interpreter','tex')    ; 
    yyaxis right
        plot(t,data(11,:));    ylabel('Temperature [deg F]','interpreter','tex')    ; 

    hAx(5) =subplot(2,3,5);
        plot(t,data(7,:),'k'); hold on ;plot(t,data(8,:),'m')  ; grid on      
        ylabel('Eccentricity, R^2','interpreter','tex')
        legend('\epsilon','R^2','FontSize',8)                

    hAx(6) = subplot(2,3,6);
       p1 = plot(t,data(10,:),'g'); ylabel('Nonuniformity [%]','interpreter','tex')   ;grid on
    % Set common plot properties    
        set(hAx,'XTick',timeTicks,'FontName','Times','FontSize',14)
        set(hAx,'XTickLabel',cellstr(datestr(timeTicks,'mm/dd HH:MM')),'FontSize',14)
        set(hAx,'xlim',[t(1),t(end)]);set(hAx,'FontSize',10)
        XLabelHC = get(hAx, 'XLabel');
        XLabelH  = [XLabelHC{:}];
        set(XLabelH, 'String', 'Time');xtickangle(hAx,45)    

    % Make the histogram of energy jitter
    %    [a,bins]=histcounts(energyJitter,50);
    %    figure(111);plot(bins(1:end-1),a/length(t),'LineWidth',2);hold on;grid on;
    %     set(gca,'FontSize',18,'FontName','Times');
    %     xlabel('Relative Energy Jitter [%]','interpreter','tex');ylabel('Fraction of shots');
    %     titlestr = ['From ',datestr(t(1)),' to ',datestr(t(end))];
    %     title(titlestr)
    %     if n==length(camerasSelected);legend(s10cameraHandles(camerasSelected));end

     % Save data to workspace if you want
     assignin('base',char(allcameraHandles(camerasSelected(n),1)),data)
     if n==length(camerasSelected);assignin('base','timeStamps',t);end
     handles.UserData(n).timeStamps = t; handles.UserData(n).cameraData = data;
     handles.UserData(n).cameraName = allcameraHandles(camerasSelected(n),1);
     handles.UserData(n).dataColumnNames = {'Xctr','Yctr','Xrms','Yrms','Sum Counts',...
        'Humidity','Eccentricity','R^2','SumInROI','Nonuniformity'};
end
%try;plot2DLaserProfilesAtSomeTime(datestr(t2));catch;warning('2D profile plot didnt work');end% Plot 2D profiles
set(handles.pushbutton2,'Enable','on');% Un-grey the save data button
guidata(hObject,handles)% Update the handles structure
%% Functions
function [t,data]=fetchLaserArchiverData(t1,t2,camerasSelected,n)
        rootPath = '/u1/facet/matlab/data/';% For FACET implementation
        rawdata = [];
            
        if all(datestr(t1,'yyyy-mm')==datestr(t2,'yyyy-mm'))% Same year same month 
            ndays = 1+str2num(datestr(t2,'dd'))-str2num(datestr(t1,'dd'));            
            for jj=1:ndays
                dayNum = str2num(datestr(t1,'dd'))+jj-1;
                pth = [rootPath,datestr(t1,'yyyy'),'/',datestr(t1,'yyyy-mm'),'/',datestr(t1,'yyyy-mm'),'-',num2str(dayNum,'%02.0f')];                                
                filelist = dir(pth);                          
                mfile = find(~cellfun(@isempty,regexp({filelist.name},['HealthReport_',handles.cameraPVs{camerasSelected(n)}])));                                                               
                if ~isempty(mfile)
                healthReport = importdata(strcat(pth,'/',filelist(mfile).name));
                dayReport = healthReport.pvData;
                idx = dayReport~=0;                
                rawdata = [rawdata dayReport(idx)];
                end
            end
            
        elseif all(datestr(t1,'yyyy')==datestr(t2,'yyyy')) && any(datestr(t1,'mm')~=datestr(t2,'mm'))% Same year different month
            nmonths = 1+str2num(datestr(t2,'mm'))-str2num(datestr(t1,'mm')) ; 
            
            for ij = 1:nmonths
               monthNum = str2num(datestr(t1,'mm'))+ij-1;               
               if ij==1;ndays = 1+eomday(str2num(datestr(t1,'yyyy')),str2num(datestr(t1,'mm')))-str2num(datestr(t1,'dd')); % First month               
               elseif ij==nmonths;ndays = str2num(datestr(t2,'dd'));% Last month               
               else ndays = eomday(str2num(datestr(t1,'yyyy')),monthNum);% Other months                                      
               end                
                    for jj = 1:ndays 
                        if ij==1;dayNum = str2num(datestr(t1,'dd'))+jj-1;else;dayNum = jj;end;
                    pth = [rootPath,datestr(t1,'yyyy'),'/',datestr(t1,'yyyy'),'-',num2str(monthNum,'%02.0f'),'/',datestr(t1,'yyyy'),'-',num2str(monthNum,'%02.0f'),'-',num2str(dayNum,'%02.0f')];                                
                    filelist = dir(pth);                          
                    mfile = find(~cellfun(@isempty,regexp({filelist.name},['HealthReport_',handles.cameraPVs{camerasSelected(n)}])));                                                               
                    if ~isempty(mfile)
                    healthReport = importdata(strcat(pth,'/',filelist(mfile).name));
                    dayReport = healthReport.pvData;
                    idx = dayReport~=0;                
                    rawdata = [rawdata dayReport(idx)];
                    end                                        
                end                
            end
                        
        end                
        
       % If the user wants data from today            
        if datestr(t2,'yyyy-mm-dd')==datestr(now,'yyyy-mm-dd') 
             todaysdata = lcaGetSmart(handles.matlabArrayPVs{camerasSelected(n)});idx = todaysdata~=0;
             rawdata = cat(2,rawdata,todaysdata(idx));
        end
        
        % Make sure the data can be reshaped
        try
             dataR = reshape(rawdata,nDataPointsPerShot,length(rawdata)/nDataPointsPerShot);
             data = dataR;
        catch
            set(handles.text5,'String','Error Reshaping Data');
            t = []; data = [];
             warning(strcat('Data cannot be resized into integer number of shots on ',handles.cameraPVs{camerasSelected(n)}));
            return
            %{
           
        %Now cut out all shots with infinities before reshaping
        find(isinf(rawdata(idx)))% This tells you shots with any infinity
        idxx = rawdata(idx)>7e5;
        figure;
        plot(diff(find(idxx)));% If shots aren't separated by nDataPointsPerShot then something's wrong
        xlabel('Shot number');ylabel('Shot Data Size')
        title(camerapvs{n})
        shotDataSize = diff(find(idxx));
        goodShots = shotDataSize == nDataPointsPerShot;
        for i=1:length(goodShots)
            if goodShots(i)
                i0 = sum(shotDataSize(1:i-1));
            data(:,i) = rawdata(1+(i-1)*nDataPointsPerShot:i*nDataPointsPerShot);
            end
        end
            return
            %}
        end

        % Find the timestamp closest to your time interval
        tRaw = dataR(end-1,:)+dataR(end,:);
        idxt = tRaw > t1 & tRaw < t2;
        data = dataR(:,idxt);
        t = data(end-1,:)+data(end,:);
        if isempty(t);set(handles.text5,'String','No data found for that time interval');return;end
    end

function m=movMeanCemma(A,n)
% n must be an odd number
m=ones(1,length(A));
    for i=1:length(A)
        if i < 1+(n-1)/2
            m(i) = mean(A(1:i));
        elseif i > length(A)-(n-1)/2-1
            m(i) = mean(A(i-(n-1)/2:end));
        else            
            m(i) = mean(A(i-(n-1)/2:i+(n-1)/2));                                
        end
    end
end
%{
function plot2DLaserProfiles(t1,camerasSelected,handles)
       
    UserData.cameraPVs = handles.cameraPVs;
    UserData.cameraNames =  s10cameraHandles(camerasSelected,1);
    UserData.umPerPixel = [3.75,4.08,3.75,4.08,9.9,9.9];         % From Manta G-125 and G-095 and G-033Bspec sheets respectively 
    UserData.magnification = [0.0475,0.425,0.27,0.1667,1.0712,0.209];
    
    requestedHour = str2num(datestr(t1,'HH'));
    rootPath = '/u1/facet/matlab/data';% Change this when deploying the script on the FACET server to /u1/matlab/facet/data/etc.

    for jj=1:length(camerasSelected)    
        camPV = UserData.cameraPVs{camerasSelected(jj)};
        pth = [rootPath,'/',datestr(t1,'yyyy'),'/',datestr(t1,'yyyy-mm'),'/',datestr(t1,'yyyy-mm-dd'),'/'];                                    
        filelist = dir(pth);                          
        mfile = find(~cellfun(@isempty,regexp({filelist.name},camPV)));                          
        if camPV=='PROF:IN10:471';mfile = mfile(2:end);else;mfile = mfile(1:end-1);end% Remove the Health report file from the list
        files = {filelist(mfile).name};        
        for ij = 1:length(mfile)             
            theHour(ij) = str2num(files{ij}(15:16));% Get the hour of the image
        end            
        [~,idx] = min(abs(requestedHour-theHour));
        img = importdata([pth,files{idx}]);
        if isempty(img);warning(['Empty image on camera ',camPV]);continue;end
        sumCounts = sum(sum(img))*1e-6;
        % Crop image
        % Find the smallest dimension and set the x-y limits to that
        [smalldim,~]= min(size(img));  [largedim,idxlargedim]= max(size(img));
        [~,sigmax]=fit_gaussian(sum(img,1)./max(sum(img,1)));[~,sigmay]=fit_gaussian(sum(img,2)'./max(sum(img,2)));
        [~,x_c]= max(sum(img,1)); [~,y_c]= max(sum(img,2)); 
        sigma = max(sigmax,sigmay);
        nSig = 4;

        cdims = [y_c-nSig*sigma<0,y_c+nSig*sigma>size(img,1),x_c-nSig*sigma<0,x_c+nSig*sigma>size(img,2)];
        Ddims = round([y_c-nSig*sigma,y_c+nSig*sigma,x_c-nSig*sigma,x_c+nSig*sigma]);

        if ~any(logical(cdims))
        imgcrop = img(round((y_c-nSig*sigma)):round((y_c+nSig*sigma)),round((x_c-nSig*sigma)):round((x_c+nSig*sigma)));    
            else
                 for jk = 1:4
                 if mod(jk,2);cropDim(jk) = max(1,Ddims(jk));else;cropDim(jk) = min(size(img,jk/2),Ddims(jk));end
                 end        
             imgcrop = img(cropDim(1):cropDim(2),cropDim(3):cropDim(4));
        end

        % Set the image equal to the cropped image before plotting
        img = imgcrop;

        X = ([1:size(img,2)]-round(size(img,2)/2))*UserData.umPerPixel(jj)*1e-3/UserData.magnification(jj);
        Y = ([1:size(img,1)]-round(size(img,1)/2))*UserData.umPerPixel(jj)*1e-3/UserData.magnification(jj);    

        % Draw stuff

        figure(55);      
        subplot(2,3,jj);
        lim0=cell2mat(get(gca,{'XLim' 'YLim'})');
        lim=lim0*[1.0 0.05;0.01 2.0];
        imagesc(X,Y,img);colormap jetvar;xlabel('x [mm]');ylabel('y [mm]');
       % axis(15*[-1 1 -1 1])
        title([s10cameraHandles(camerasSelected(jj),1)],'FontSize',16);
        %hg = text(lim0(1,1),0.8*lim0(2,2),['Max Counts/4096 = ',num2str(double(max(max(img)))/4096,'%.2f')],'Parent',gca,'FontSize',10,'FontName','Times');
        if regexp(camPV,'CAMR:LT10:500');str1 = ' [mW]';else;str1 = ' [mJ]';end
        hg = text(lim0(1,1),0.7*lim0(2,2),['Max Counts/4096 = ',...
            num2str(double(max(max(img)))/4096,'%.2f'),char(10),...
            'Energy',str1,' = ',num2str(energyCalibration(UserData,jj,sumCounts),'%.2f')],'Parent',gca,'FontSize',10,'FontName','Times');
        
        if jj ==1
        ht = text(1.85*lim0(1,1),-1.35*lim0(2,2),[datestr(t1,'mm-dd-yyyy') char(10) datestr(t1,'HH:MM')],'Parent',gca,'VerticalAlignment','top','FontSize',10,'FontName','Times');
        end    

        set(gca,'FontSize',12,'FontName','Times','LineWidth',2)

    end

        
end
%}
end
