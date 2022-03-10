function [newData]=getLaserStatusTableDatav4(camerasSelected,hObject,handles)
% This version is for the 1hr data
camerapvs = {'CAMR:LT10:500','CAMR:LT10:600','CAMR:LT10:800','CAMR:LT10:700',...
    'CAMR:LT10:200','CAMR:LT10:380','CAMR:LT10:900'};
UserData.magnification = [0.0475,0.425,0.27,0.11,1.0712,0.25,1];
handles.cameraPVs = camerapvs;
nCams = length(camerasSelected);
%%%%%%%%%%%%%%%%%% USER INPUT ABOVE THIS LINE %%%%%%%%%%%%%%%%%%%%%%%
tableData=get(hObject,'Data');
%tableData = get(handles.uitable1,'data');
newData = tableData;
% Make plots or not
disp(handles.filename)
onehrdata = importdata(handles.filename);
makeOnehrDataPlots(onehrdata,nCams);

    t = onehrdata.tStamp; idx = t~=0;    t = t(idx);
    alldata = onehrdata.beamImageData; alldata = alldata(idx,:,:);
    tempData = onehrdata.lRoomTemp;     tempData = tempData(idx);
    timeTicks = linspace(t(1),t(end),4);
    secondsPerShot = str2num(datestr(t(2)-t(1),'SS.FFF'));
    n15 = 1+round(15*60/secondsPerShot);
    n1hr = 1+round(60*60/secondsPerShot);
    if n1hr>length(t);n1hr = length(t)-1;end
    if n15>length(t);n15 = length(t)-1;end
    
    limits = [10,10,10,10,10,10,10]*1e-2;
    % Set the time
%    set(handles.edit1,'String', ['Current data taken at ',datestr(t(end),'mm-dd-yyyy HH:MM')],'FontSize',10);
     
for n=1:nCams   
    clearvars t data      
    data = squeeze(alldata(:,n,:));    
    data = permute(data,[2 1]);
    
    sigFigs = 3;% Significant figures for displaying stuff
        
    nSkip = 5;% number of lines to skip
    indx = [1,2,3,4,10,10,5,5];% Centroid, spotsize, uniformity, energy
    magnification = UserData.magnification(n);
    % Centroids 
    newData(2+(n-1)*nSkip,2) = {strcat(num2str(round(data(1,end),sigFigs,'significant')),',',num2str(round(data(2,end),sigFigs,'significant')))}    ;
        % Centroids 15 min average
        Xctr = (data(1,end-n15:end)-mean(data(1,end-n15:end)))./mean(data(3,end-n15:end));
        Yctr = (data(2,end-n15:end)-mean(data(2,end-n15:end)))./mean(data(4,end-n15:end));                      
    newData(2+(n-1)*nSkip,3) = {strcat(num2str(100*round(std(Xctr),sigFigs,'significant')),',',num2str(100*round(std(Yctr),sigFigs,'significant')))}    ;
        % Centroids 1 hr average
        Xctr = (data(1,end-n1hr:end)-mean(data(1,end-n1hr:end)))./mean(data(3,end-n1hr:end));                
        Yctr = (data(2,end-n1hr:end)-mean(data(2,end-n1hr:end)))./mean(data(4,end-n1hr:end));        
    newData(2+(n-1)*nSkip,4) = {strcat(num2str(100*round(std(Xctr),sigFigs,'significant')),',',num2str(100*round(std(Yctr),sigFigs,'significant')))}    ;
        
    % Spot Size 
    newData(3+(n-1)*nSkip,2) = {strcat(num2str(1e-3*round(data(3,end)/magnification,sigFigs,'significant')),',',num2str(round(1e-3*data(4,end)/magnification,sigFigs,'significant')))}    ;
        % SpotSize 15 min average
        Xctr = (data(3,end-n15:end)-mean(data(3,end-n15:end)))./mean(data(3,end-n15:end));                 
        Yctr = (data(4,end-n15:end)-mean(data(4,end-n15:end)))./mean(data(4,end-n15:end));                        
    newData(3+(n-1)*nSkip,3) = {strcat(num2str(100*round(std(Xctr),sigFigs,'significant')),',',num2str(100*round(std(Yctr),sigFigs,'significant')))}    ;
        % SpotSize 1 hr average
        Xctr = (data(3,end-n1hr:end)-mean(data(3,end-n1hr:end)))./mean(data(3,end-n1hr:end));
        Yctr = (data(4,end-n1hr:end)-mean(data(4,end-n1hr:end)))./mean(data(4,end-n1hr:end));        
    newData(3+(n-1)*nSkip,4) = {strcat(num2str(100*round(std(Xctr),sigFigs,'significant')),',',num2str(100*round(std(Yctr),sigFigs,'significant')))}    ;
        
    % Uniformity
    newData(4+(n-1)*nSkip,2) = {strcat(num2str(round(data(10,end),sigFigs,'significant')))}    ;
        % Uniformity 15 min average
        Uctr = (data(10,end-n15:end)-mean(data(10,end-n15:end)))./mean(data(10,end-n15:end));        
    newData(4+(n-1)*nSkip,3) = {strcat(num2str(100*round(std(Uctr),sigFigs,'significant')))};
        % Uniformity 1 hr average
        Uctr = (data(10,end-n1hr:end)-mean(data(10,end-n1hr:end)))./mean(data(10,end-n1hr:end));                
    newData(4+(n-1)*nSkip,4) = {strcat(num2str(100*round(std(Uctr),sigFigs,'significant')))};
    
    % Energy
    %newData(5+(n-1)*nSkip,2) ={strcat(num2str(round(data(5,end),sigFigs,'significant')))};% in MCts 
    newData(5+(n-1)*nSkip,2) = {strcat(num2str(round(energyCalibration(handles,n,data(5,end)),sigFigs,'significant')))};% in mJ
    %assignin('base','Elaser',data(5,:));
        % Energy 15 min average
        Ectr = (data(5,end-n15:end)-mean(data(5,end-n15:end)))./mean(data(5,end-n15:end)); 
        %%%% FILTER ON ENERGY %%%%
        Ectr = Ectr - abs(mean(Ectr));
        %Ectr = Ectr(abs(Ectr)<limits(n));%figure;histogram(Ectr)% Uncomment for energy jitter histogram plot
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        EctrRange = (range(data(5,end-n15:end)))./mean(data(5,end-n15:end)); 
        RangeOverstd = EctrRange/(std(Ectr-mean(Ectr)));        

    newData(5+(n-1)*nSkip,3) = {strcat(num2str(100*round(std(Ectr-mean(Ectr)),sigFigs,'significant')),',',num2str(round(RangeOverstd,sigFigs,'significant')))}    ;
        % Energy 1 hr average
        Ectr = (data(5,end-n1hr:end)-mean(data(5,end-n1hr:end)))./mean(data(5,end-n1hr:end));        
        %%%% FILTER ON ENERGY %%%%
        Ectr = Ectr - abs(mean(Ectr));
        %Ectr = Ectr(abs(Ectr)<limits(n));% Uncomment for energy jitter filtering
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        EctrRange = (range(data(5,end-n1hr:end)))./mean(data(5,end-n1hr:end));  
        RangeOverstd = EctrRange/(std(Ectr-mean(Ectr)));

    newData(5+(n-1)*nSkip,4) = {strcat(num2str(100*round(std(Ectr-mean(Ectr)),sigFigs,'significant')),',',num2str(round(RangeOverstd,sigFigs,'significant')))}    ;
            
    % Add temperature data   
    numCameras = length(camerapvs);
    newData(5*numCameras+1,2) = {num2str(round(tempData(end),sigFigs,'significant'))};
    newData(5*numCameras+1,3) = {num2str(round(std(tempData(end-n15:end)),sigFigs,'significant'))};
    newData(5*numCameras+1,4) = {num2str(round(std(tempData(end-n1hr:end)),sigFigs,'significant'))};
    % Add Humidity data        
    newData(5*numCameras+2,2) = {num2str(round(data(6,end),sigFigs,'significant'))};
    newData(5*numCameras+2,3) = {num2str(round(std(data(6,end-n15:end)),sigFigs,'significant'))};
    newData(5*numCameras+2,4) = {num2str(round(std(data(6,end-n1hr:end)),sigFigs,'significant'))};
    
    newData(1:5:31,2:end) = {''};% These rows have the camera names on them
    % Set the table data to newData
    hObject.Data = newData;
    %set(handles.uitable1,'Data',newData);

end
  


end
