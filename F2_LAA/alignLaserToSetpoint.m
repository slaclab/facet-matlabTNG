function [newlaserCentroids,mirrorMovements,laserOffset] = alignLaserToSetpoint(dataStruct,requestedSetpoint,calibrationMatrix,k_p,k_i,app)
% Note - This does not include the integral term for the feedback
if regexp(dataStruct.camerapvs{1},'CAMR:LT20:105')% Special case for MPA near and far
    nshots = 20;% Average over many shots for MPA near and far
else
    nshots = 3;% set number of shots for averaging 
end

    for jj=1:length(dataStruct.camerapvs)% Find beam centroid
        for n=1:nshots
        [bp(n,:),img,data]=grabLaserProperties(dataStruct,jj);
        end
        laserCentroids(1+2*(jj-1)) = mean(bp(:,1));%x setpoint
        laserCentroids(2*jj) = mean(bp(:,2));%y setpoint
        
        % Check that the camera image is not more than 10 seconds old (in case the camera has frozen)
        tenSec = 1/360/24;
        if abs(now-data.ts)>tenSec% 
            str = ['Image timestamp more than 10 s old. Alignment skipped for '...
                ,lcaGetSmart([dataStruct.camerapvs{1},':NAME'])];
            app.LogTextArea.Value =  [str,app.LogTextArea.Value(:)'];drawnow()   
                newlaserCentroids = laserCentroids;
                laserOffset = 0;
                mirrorMovements = 0;
            return
       end
    end

    for jj=1:length(laserCentroids) % Calculate beam offset from setpoint
        if mod(jj,2);axisfactor=1.0;else;axisfactor = 1.0;end % Axis factor makes +ve x and y correspond to right/left and up/down
        laserOffset(jj) = axisfactor*(requestedSetpoint(jj)-laserCentroids(jj));
 %       err_new(jj) = laserOffset(jj)./(requestedSetpoint(jj)-initialCentroid(jj));% Normalized error for integral term in PID
       laserOffset(jj) = 1.0*round(laserOffset(jj)*100)/100; % Round to nearest hundredth of a pixel 
        % Set the offset to zero if it's smaller than 0.5 pixels
        if abs(laserOffset(jj))<0.5%set less than 0.5 pix offset to zero
            laserOffset(jj) = 0.0;
        end 
    end    
 %   err = [err;err_new];
    str = ['Beam Offset from requested setpoint = ',newline,num2str(laserOffset)];
    app.LogTextArea.Value =  [str,app.LogTextArea.Value(:)'];drawnow()

%     % Check that the requested move is not 'too large'
%     % I.e. when the centroid offset is > 0.5*ROI size - not using this
%     % anymore not we set the max misalignment tolerance in pixels manually
%     for jj=1:length(dataStruct.camerapvs)
%         m=regexp(dataStruct.camerapvs{jj},app.camerapvs,'match');
%         idx = find(~cellfun(@isempty,m));
%         tols(1+2*(jj-1))=app.refCamSettings.ROIsizeX(idx)<0.5*abs(laserOffset(1+2*(jj-1))); 
%         tols(2*jj)=app.refCamSettings.ROIsizeY(idx)<0.5*abs(laserOffset(2*jj));
%     end
    if regexp(dataStruct.camerapvs{1},'CAMR:LT20:105')% Special case for MPA near and far
        tols = any(abs(laserOffset)>app.MPANearFarmaxMisalignmentTolerance); % Average over many shots for MPA near and far
    else
        tols = any(abs(laserOffset)>app.maxMisalignmentTolerance); 
    end
    %tols = any(abs(laserOffset)>app.maxMisalignmentTolerance);
    if any(tols)% If requested move is too large exit
    str = ['Warning - Laser offset is larger than the max tolerance of ', strcat(num2str(app.maxMisalignmentTolerance),' pix'),...
        'Alignment skipped for ',lcaGetSmart([dataStruct.camerapvs{1},':NAME'])];
    app.LogTextArea.Value =  [str,app.LogTextArea.Value(:)'];drawnow()  
    newlaserCentroids = laserCentroids;
    mirrorMovements = 0;
    return
    end
    
    % Calculate the mirror correction movements
    %mirrorMovements = calibrationMatrix\laserOffset';% Solve linear system - the correction is proportional to the offset
    mirrorMovements = lscov(calibrationMatrix,laserOffset');% Solve linear system
    % If you want you can add the integral term to improve convergence speed of PID               
    %mirrorMovements = k_p*mirrorMovements+k_i*sign(mirrorMovements).*abs(trapz(err))';
    mirrorMovements = k_p*mirrorMovements;
    
    if any(isnan(mirrorMovements))
    str = ['Warning - NaN mirror movements requested, setting to zero. Moves Requested =  '];
    app.LogTextArea.Value =  [str,app.LogTextArea.Value(:)'];drawnow()
    mirrorMovements(isnan(mirrorMovements)) = 0;
    end
    mirrorMovements = 1.0*round(mirrorMovements*1000)/1000; % Round to nearest thousandth revolution    
   
    % Step 4: Move the beam with mirrors using calculated correction
    if isfield(dataStruct,'channel_index')
    channel_index = dataStruct.channel_index;
    else
        channel_index = [1:4];
    end
    % Print the mirror motion to the log
    str =['Mirror motion = ',newline,num2str([mirrorMovements'])];
    app.LogTextArea.Value =  [str,app.LogTextArea.Value(:)'];drawnow()
        
    for n=1:length(channel_index) % This goes to 4 when u include the second mirror
        channel = channel_index(n);        
        % Check that the motor is reading back if not don't align
        motorStatus = lcaGetSmart([dataStruct.motorpvs,':CH',num2str(channel),':MOTOR_TYPE']);
         if regexp('No motor',motorStatus{1},'once')==1
               str = ['Warning - ',[dataStruct.motorpvs,':CH',num2str(channel)],...
                   ' not responding . Skipping alignment' ];
               app.LogTextArea.Value =  [str,app.LogTextArea.Value(:)'];drawnow()
                   newlaserCentroids(n) = laserCentroids(n);
                    mirrorMovements(n) = 0;
         continue
         end
         
        % Check that the motor value is equal to the readback value
        motor_rbv = lcaGetSmart([dataStruct.motorpvs,':CH',num2str(channel),':MOTOR.RBV']);
        motor_val = lcaGetSmart([dataStruct.motorpvs,':CH',num2str(channel),':MOTOR']);
        
        if abs(motor_rbv-motor_val)>1e-3
            str = 'Warning - Motor value not equal to readback value. Setting motor value to readback value.';
            app.LogTextArea.Value =  [str,app.LogTextArea.Value(:)'];drawnow()
            lcaPutSmart([dataStruct.motorpvs,':CH',num2str(channel),':MOTOR'],motor_rbv);
        end
        
        % Move the motor by setting the tweak value - this is off during GUI testing
         lcaPutSmart([dataStruct.motorpvs,':CH',num2str(channel),':MOTOR.TWV'], mirrorMovements(n));% Set tweak
         
         lcaPutSmart([dataStruct.motorpvs,':CH',num2str(channel),':MOTOR.TWF'],1.0);% Move motor
         
         motor_status= lcaGetSmart([dataStruct.motorpvs,':CH',num2str(channel),':MOTOR.MSTA']);
         while motor_status ~=2 % motor_status = 2 means it's done moving
         motor_status= lcaGetSmart([dataStruct.motorpvs,':CH',num2str(channel),':MOTOR.MSTA']);
         drawnow()
         % Check that someone didn't stop the auto-alignment mid
         % motor move - if so stop moving and exit - this doesnt work right now
%          if lcaGetSmart(app.feedbackExitPV)
%             app.LogTextArea.Value = ['Auto-Alignment Stopped',app.LogTextArea.Value(:)'];
%             app.StatusLamp.Color = 'Red';drawnow()
%             %lcaPutSmart(motor_status, 2);% Stop motor
%             lcaPutSmart([dataStruct.motorpvs,':CH',num2str(channel),':MOTOR.TWV'], 0);% Set tweak to zero
%             newLaserCentroids = laserCentroids;
%             mirrorMovements = 0;
%             return
%          end

         end
         motorPositions(n) = lcaGetSmart([dataStruct.motorpvs,':CH',num2str(channel),':MOTOR']);
        pause(0.1)

    end
    % Calculate the new beam position
        for jj=1:length(dataStruct.camerapvs)
            [bp(jj,:),img]=grabLaserProperties(dataStruct,jj);
            newlaserCentroids(1+2*(jj-1)) = bp(jj,1);%x setpoint
            newlaserCentroids(2*jj) = bp(jj,2);%y setpoint
        end
end
