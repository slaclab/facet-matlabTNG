function [newData]=getLaserStatusTableDataLive(camerasSelected,hObject,handles)
UserData.cameraPVs = {'CAMR:LT10:500','CAMR:LT10:600','CAMR:LT10:800',...
            'CAMR:LT10:700','CAMR:LT10:200','CAMR:LT10:380','CAMR:LT10:900'};% Note - CAMR:LT10:450 is fake VCC
UserData.magnification = [0.0475,0.425,0.27,0.11,1.0712,0.209,1];
UserData.pv_lroom_temp = 'LASR:LR10:1:TABLETEMP1';
UserData.pv_humidity = 'DAQ:LR10:TM01:AF01Humidity';
UserData.fitMethod = 2;             % See beamAnalysis_beamParams
UserData.umPerPixel = [3.75,4.08,3.75,4.08,9.9,9.9,6.8];         % From Manta G-125, G-095 and G-033b spec sheets
UserData.bufferSize = 3000;         % About 1.25 hrs of time @ 1.5 s/shot
nCams = length(UserData.cameraPVs);
%beamProperties = zeros(nCams,10,UserData.bufferSize);
%%%%%%%%%%%%%%%%%% USER INPUT ABOVE THIS LINE %%%%%%%%%%%%%%%%%%%%%%%
%tableData=get(hObject,'Data');
tableData = get(handles.uitable1,'Data');
newData = tableData;
m=1;
while(handles.LiveTableBool)    
    for n=1:nCams        
        clearvars t data
        if m<UserData.bufferSize
            [beamProperties(n,:,m),~]=GrabLaserBeamPropertiesV4(UserData,n);
            tStamp(m) = now;
        else
            beamProperties = circshift(beamProperties,-1,3);
            tStamp = circshift(tStamp,-1);
            [beamProperties(n,:,end),~]=GrabLaserBeamPropertiesV4(UserData,n); 
            tStamp(end) = now;          m=UserData.bufferSize;
        end

            idx1hr = tStamp<now & tStamp>datenum(now-1/24);
            idx15min = tStamp<now & tStamp>datenum(now-1/24/4);
        
        tempData(m) = lcaGetSmart(UserData.pv_lroom_temp);
        humidity(m) = lcaGetSmart(UserData.pv_humidity);    
        if m==1;continue;end
        data = squeeze(beamProperties(n,:,:))';
        
        sigFigs = 2;% Significant figures for displaying stuff        
        %data = 100*rand(13,271);% This works
        nSkip = 5;% number of lines to skip

        % Centroids 
        newData(2+(n-1)*nSkip,2) = {strcat(num2str(round(1e-3*data(end,1),sigFigs,'significant')),',',num2str(round(1e-3*data(end,2),sigFigs,'significant')))}    ;
            % Centroids 15 min average
            Xctr = (data(idx15min,1)-mean(data(idx15min,1)))./mean(data(idx15min,3));
            Yctr = (data(idx15min,2)-mean(data(idx15min,2)))./mean(data(idx15min,4));                      
        newData(2+(n-1)*nSkip,3) = {strcat(num2str(100*round(std(Xctr),sigFigs,'significant')),',',num2str(100*round(std(Yctr),sigFigs,'significant')))}    ;
            % Centroids 1 hr average
            Xctr = (data(idx1hr,1)-mean(data(idx1hr,1)))./mean(data(idx1hr,3));                
            Yctr = (data(idx1hr,2)-mean(data(idx1hr,2)))./mean(data(idx1hr,4));        
        newData(2+(n-1)*nSkip,4) = {strcat(num2str(100*round(std(Xctr),sigFigs,'significant')),',',num2str(100*round(std(Yctr),sigFigs,'significant')))}    ;

        % Spot Size 
        newData(3+(n-1)*nSkip,2) = {strcat(num2str(round(1e-3*data(end,3)/UserData.magnification(n),sigFigs,'significant')),...
            ',',num2str(round(1e-3*data(end,4)/UserData.magnification(n),sigFigs,'significant')))}    ;
            % SpotSize 15 min average
            Xctr = (data(idx15min,3)-mean(data(idx15min,3)))./mean(data(idx15min,3));          
            Yctr = (data(idx15min,4)-mean(data(idx15min,4)))./mean(data(idx15min,4));                        
        newData(3+(n-1)*nSkip,3) = {strcat(num2str(100*round(std(Xctr),sigFigs,'significant')),',',num2str(100*round(std(Yctr),sigFigs,'significant')))}    ;
            % SpotSize 1 hr average
            Xctr = (data(idx1hr,3)-mean(data(idx1hr,3)))./mean(data(idx1hr,3));
            Yctr = (data(idx1hr,4)-mean(data(idx1hr,4)))./mean(data(idx1hr,4));        
        newData(3+(n-1)*nSkip,4) = {strcat(num2str(100*round(std(Xctr),sigFigs,'significant')),',',num2str(100*round(std(Yctr),sigFigs,'significant')))}    ;

        % Uniformity
        newData(4+(n-1)*nSkip,2) = {strcat(num2str(round(data(end,10),sigFigs,'significant')))}    ;
            % Uniformity 15 min average
            Uctr = (data(idx15min,10)-mean(data(idx15min,10)))./mean(data(idx15min,10));        
        newData(4+(n-1)*nSkip,3) = {strcat(num2str(100*round(std(Uctr),sigFigs,'significant')))};
            % Uniformity 1 hr average
            Uctr = (data(idx1hr,10)-mean(data(idx1hr,10)))./mean(data(idx1hr,10));                
        newData(4+(n-1)*nSkip,4) = {strcat(num2str(100*round(std(Uctr),sigFigs,'significant')))};

        % Energy
        newData(5+(n-1)*nSkip,2) = {strcat(num2str(round(energyCalibration(UserData,n,data(end,5)),sigFigs,'significant')))}    ;
            % Energy 15 min average
            Ectr = (data(idx15min,5)-mean(data(idx15min,5)))./mean(data(idx15min,5));        
            EctrRange = (max(data(idx15min,5))-min(data(idx15min,5)))./mean(data(idx15min,5)); 

        newData(5+(n-1)*nSkip,3) = {strcat(num2str(100*round(std(Ectr),sigFigs,'significant')),',',num2str(100*round(EctrRange,sigFigs,'significant')))}    ;
        % SpotSize 1 hr average
            Ectr = (data(idx1hr,5)-mean(data(idx1hr,5)))./mean(data(idx1hr,5));        
            EctrRange = (max(data(idx1hr,5))-min(data(idx1hr,5)))./mean(data(idx1hr,5));               
        newData(5+(n-1)*nSkip,4) = {strcat(num2str(100*round(std(Ectr),sigFigs,'significant')),',',num2str(100*round(EctrRange,sigFigs,'significant')))}    ;        

        % Check if any values fall outside tolerance, if so color the row red        
        newData(1:5:21,2:end) = {''};% These rows have the camera names on them
         
          % Add temperature data   
        newData(5*nCams+1,2) = {num2str(round(tempData(end),sigFigs,'significant'))};
        newData(5*nCams+1,3) = {num2str(round(std(tempData(idx15min)),sigFigs,'significant'))};
        newData(5*nCams+1,4) = {num2str(round(std(tempData(idx1hr)),sigFigs,'significant'))};
        % Add Humidity data        
        newData(5*nCams+2,2) = {num2str(round(humidity(end),sigFigs,'significant'))};
        newData(5*nCams+2,3) = {num2str(round(std(humidity(idx15min)),sigFigs,'significant'))};
        newData(5*nCams+2,4) = {num2str(round(std(humidity(idx1hr)),sigFigs,'significant'))};
      
        % Set the table data to newData
        %hObject.Data = newData;
        set(handles.uitable1,'Data',newData);
        laserTableToleranceWarnings(data,tempData,humidity,tStamp,hObject,handles,n);
        drawnow
        set(handles.edit1,'String', ['Current data taken at ',datestr(now,'mm-dd-yyyy HH:MM')],'FontSize',10);

    end
m=m+1; 
handles = guidata(hObject);
end

end
