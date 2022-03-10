function laserTableToleranceWarnings(data,tempData,humidity,tStamp,hObject,handles,nCam)
    nSkip = 5;% number of lines to skip for each camera
    idx1hr = tStamp<now & tStamp>datenum(now-1/24);
    idx15min = tStamp<now & tStamp>datenum(now-1/24/4);
% Load the original backgrounds            
    bkgrnds = get(handles.uitable1,'BackgroundColor');
    bkgrnds(7*nSkip+1,:) = [.75 .9 .9];bkgrnds(7*nSkip+2,:) = bkgrnds(7*nSkip+1,:);% Green
    
% Set warnings for jitter of laser quantities 
% (spot size, energy, centroid ,nonuniformity,humidity,temperature)
% Temperature
    if any([std(tempData(idx15min))>0.05,std(tempData(idx1hr))>0.05])
        bkgrnds(7*nSkip+1,:) = [1 .3 .3];else;bkgrnds(7*nSkip+1,:) = [.75 .9 .9];
    end

% Humidity
    if any([std(humidity(idx15min))>0.02,std(humidity(idx1hr))>0.05])
        bkgrnds(7*nSkip+2,:) = [1 .3 .3];else;bkgrnds(7*nSkip+2,:) = [.75 .9 .9];
    end

% Energy
    Ectr = (data(idx15min,5)-mean(data(idx15min,5)))./mean(data(idx15min,5)); 
    if any([std(Ectr)>0.05,std(Ectr)>0.05])
        bkgrnds(nSkip*(nCam-1)+5,:) = [1 .3 .3];else;bkgrnds(nSkip*(nCam-1)+5,:) = [1 1 1];
    end

% Spot Size
    Xrms15min = (data(idx15min,3)-mean(data(idx15min,3)))./mean(data(idx15min,3)); 
    Yrms15min = (data(idx15min,4)-mean(data(idx15min,4)))./mean(data(idx15min,4));
    Xrms1hr = (data(idx1hr,3)-mean(data(idx1hr,3)))./mean(data(idx1hr,3)); 
    Yrms1hr = (data(idx1hr,4)-mean(data(idx1hr,4)))./mean(data(idx1hr,4));
    if any([std(Xrms15min)>0.02,std(Yrms15min)>0.02,std(Xrms1hr)>0.05,std(Yrms1hr)>0.05])
        bkgrnds(nSkip*(nCam-1)+3,:) = [1 .3 .3];else;bkgrnds(nSkip*(nCam-1)+3,:) = [1 1 1];
    end

% Centroid 
    Xctr15min = (data(idx15min,1)-mean(data(idx15min,1)))./mean(data(idx15min,3));
    Yctr15min = (data(idx15min,2)-mean(data(idx15min,2)))./mean(data(idx15min,4));   
    Xctr1hr = (data(idx1hr,1)-mean(data(idx1hr,1)))./mean(data(idx1hr,3));                
    Yctr1hr = (data(idx1hr,2)-mean(data(idx1hr,2)))./mean(data(idx1hr,4)); 
    if any([std(Xctr15min)>0.02,std(Yctr15min)>0.02,std(Xctr1hr)>0.05,std(Yctr1hr)>0.05])
        bkgrnds(nSkip*(nCam-1)+2,:) = [1 .3 .3];else;bkgrnds(nSkip*(nCam-1)+2,:) = [1 1 1];
    end
    
% Nonuniformity
 Uctr15 = (data(idx15min,10)-mean(data(idx15min,10)))./mean(data(idx15min,10));   
 Uctr1hr = (data(idx1hr,10)-mean(data(idx1hr,10)))./mean(data(idx1hr,10));  
    if any([std(Uctr15)>0.05,std(Uctr1hr)>0.05])
        bkgrnds(nSkip*(nCam-1)+4,:) = [1 .3 .3];else;bkgrnds(nSkip*(nCam-1)+4,:) = [1 1 1];
    end

% Set the new background colors
set(handles.uitable1,'BackgroundColor',bkgrnds)