function driftWarnings = checkForLaserDrift(UserData)
handles.cameraPVs = UserData.camerapvs;
% Centroid setpoints on each camera x1,y1,x2,y2,...
centroidSetpoints = [477,531,525,250,453,457,952,476,503,138,308,235];
% Energy setpoints on each camera
energySetpoints = [330,5.3,14,6.7,0.218,0.078,0.05];
% Centroid Tolerance [pix], Energy Tol [rel], Temp Tol [deg F]
centroidTol = 10; energyTol = 0.25; tempTol = 0.25;
% Catastrophic Energy Tolerance (threshold for email warning)
catastrophicETol = 0.8;
driftWarnings = '';emailWarningStr = '';
    % Check for centroid or energy drifts (Ignoring VCC for now)
    try
        for jj = 1:length(UserData.camerapvs)-1 % Ignore VCC for now        
            cameraName = lcaGetSmart([UserData.camerapvs{jj},':NAME']);
            beamProperties=GrabLaserBeamPropertiesV2(UserData,jj);
            img = profmon_grab(UserData.camerapvs{jj});
            laserEnergy = energyCalibration(handles,jj,sum(sum(img.img))*1e-6);       
            centroidPositions = beamProperties(1:2)./UserData.umPerPixel(jj);

            if abs(centroidPositions(1)-centroidSetpoints(2*jj-1)) > centroidTol ||...
                    abs(centroidPositions(2)-centroidSetpoints(2*jj)) > centroidTol
                str = strcat('Centroid Drifted from Setpoint on ',cameraName,'. \n');
                driftWarnings = strcat(driftWarnings,str);    
            end

            if abs(laserEnergy./energySetpoints(jj)-1) > energyTol           
               str =  strcat('Energy Drifted from Setpoint on ',cameraName,'. \n');
               driftWarnings = strcat(driftWarnings,str);
            end
        % Check for 'catastrophic events' i.e. the energy going to zero on IR cams
        if jj<4; % IR cams only for now
            if abs(laserEnergy./energySetpoints(jj)-1) > catastrophicETol
            strc = strcat('Beam off on ',cameraName,'.');
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
            str =  ['Temp Fluctuations larger than 0.25 deg F RMS in last hour. \n'];
            driftWarnings = [driftWarnings,str];
        end
     % Send warning email for catastrophic events
     if ~isempty(emailWarningStr)
         logName = strcat('S10LaserWarning_',datestr(now,'DD_MM_YYYY'),'.txt');
         dos(['echo ' emailWarningStr{:} ' | mail -s S10LaserWarningEmail cemma@slac.stanford.edu boshea@slac.stanford.edu'])
     end
     
    catch
        disp('Error evaluating laser drift')
        driftWarnings = '';
    end
end
