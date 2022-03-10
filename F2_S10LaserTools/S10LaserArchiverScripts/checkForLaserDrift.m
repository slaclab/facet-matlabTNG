function driftWarnings = checkForLaserDrift(UserData)
handles.cameraPVs = UserData.camerapvs;
% Centroid setpoints on each camera x1,y1,x2,y2,...
centroidSetpoints = [550,550,551,234,693,484,716,453,336,216,347,198,900,600];%Updated 11/3/21
% Energy setpoints on each camera
energySetpoints = [388,3.02,22.02,11.7,0.4,0.25,0.25,0.05];%mW (for Osc) and mJ for rest Updated 10/28/21
% Centroid Tolerance [pix], Energy Tol [rel], Temp Tol [deg F]
centroidTol = 20; energyTol = 0.25; tempTol = 0.25;
% Catastrophic Energy Tolerance (threshold for email warning)
catastrophicETol = 0.2;
driftWarnings = {''};emailWarningStr = '';
    % Check for centroid or energy drifts (Ignoring UV cams for now)
    try
        for jj = 1:4 % Check only IR cams for now  
            % Check that the camera array rate is not 0 Hz
                if lcaGetSmart([UserData.camerapvs{jj},':Image:ArrayRate_RBV'])==0 || isnan(lcaGetSmart([UserData.camerapvs{jj},':Image:ArrayRate_RBV']))
                warning(['Camera array rate is 0 Hz or NaN - no data acquired for ',UserData.camerapvs{jj}])
                continue
                end
            cameraName = lcaGetSmart([UserData.camerapvs{jj},':NAME']);
            beamProperties=GrabLaserBeamPropertiesV2(UserData,jj);
            img = profmon_grab(UserData.camerapvs{jj});
            laserEnergy = energyCalibration(handles,jj,sum(sum(img.img))*1e-6);       
            centroidPositions = beamProperties(1:2)./UserData.umPerPixel(jj);

            if abs(centroidPositions(1)-centroidSetpoints(2*jj-1)) > centroidTol ||...
                    abs(centroidPositions(2)-centroidSetpoints(2*jj)) > centroidTol
                str = strcat(' Centroid Drifted from Setpoint on ',cameraName,'. ');
                driftWarnings = strcat(driftWarnings,str);    
            end

            if abs(laserEnergy./energySetpoints(jj)-1) > energyTol           
               str =  strcat(' Energy Drifted from Setpoint on ',cameraName,'. ');
               driftWarnings = strcat(driftWarnings,str);
            end
        % Check for 'catastrophic events' i.e. the energy going to -80% on IR cams
        if jj<5 % IR cams only for now
            if laserEnergy./energySetpoints(jj) < catastrophicETol
            strc = strcat('Laser off on ',cameraName,'.');
            emailWarningStr = strcat(emailWarningStr,strc);
            end   
            end
        end
    % Check for temperature fluctuations (use temp at compressor location) 
    todaysdata = lcaGetSmart(UserData.matlabPvs{4});idx = todaysdata~=0;
    rawdata = todaysdata(idx);
    dataR = reshape(rawdata,UserData.nDataPointsPerShot,length(rawdata)/UserData.nDataPointsPerShot);
            % Select the last hour's worth of data
            tRaw = dataR(end-1,:)+dataR(end,:);
            idxt = tRaw > now-1/24 & tRaw < now;
            data = dataR(:,idxt);
            tempData = data(11,:); 

    if std(abs(tempData-mean(tempData))) > tempTol
        str =  ['S10 Laser Temp Fluctuations larger than 0.25 deg F RMS in last hour. \n'];
        driftWarnings = strcat(driftWarnings,str);
    end
     % Check for unstable timing fiducial rate
     fiducialRate = lcaGetSmart('IOC:LR10:LS01:FIDUCIALRATE');
     if fiducialRate ~=360
         str = ['IOC:LR10:LS01:FIDUCIALRATE moved from 360 Hz. \n'];
         driftWarnings = strcat(driftWarnings,str);
         warning(str);
     end
     % Send warning email if laser is down 
     if ~isempty(emailWarningStr)
         disp('Sending laser down warning email')
         logName = strcat('S10LaserWarning_',datestr(now,'DD_MM_YYYY'),'.txt');
         dos(['echo ' emailWarningStr{:} ' | mail -s S10LaserWarningEmail cemma@slac.stanford.edu boshea@slac.stanford.edu ']);%tallmike@slac.stanford.edu dskl@slac.stanford.edu scondam@slac.stanford.edu'])
     % Set the 'Injector Laser Shutdown' PV to 1 to warn ops
     lcaPutSmart('SIOC:SYS1:ML02:AO050',1);
     else
     lcaPutSmart('SIOC:SYS1:ML02:AO050',0);    
     end
             
    catch
        disp('Error evaluating laser drift')
        driftWarnings = {''};
    end
end
