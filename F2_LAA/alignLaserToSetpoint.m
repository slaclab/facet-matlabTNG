function [newlaserCentroids,mirrorMovements,laserOffset] = alignLaserToSetpoint(dataStruct,requestedSetpoint,calibrationMatrix,k_p,k_i,app)
% Note - This does not include the integral term for the feedback
nshots = 3;% set number of shots for averaging 

    for jj=1:length(dataStruct.camerapvs)% Find beam centroid
        for n=1:nshots
        [bp(n,:),img]=grabLaserProperties(dataStruct,jj);
        end
        laserCentroids(1+2*(jj-1)) = mean(bp(:,1));%x setpoint
        laserCentroids(2*jj) = mean(bp(:,2));%y setpoint
    end

    for jj=1:length(laserCentroids) % Calculate beam offset from setpoint
        if mod(jj,2);axisfactor=1.0;else;axisfactor = 1.0;end % Axis factor makes +ve x and y correspond to right/left and up/down
        laserOffset(jj) = axisfactor*(requestedSetpoint(jj)-laserCentroids(jj));
 %       err_new(jj) = laserOffset(jj)./(requestedSetpoint(jj)-initialCentroid(jj));% Normalized error for integral term in PID
    end    
 %   err = [err;err_new];
    str = ['Beam Offset from requested setpoint = ',num2str(laserOffset)];
    app.LogTextArea.Value =  [str,app.LogTextArea.Value(:)'];drawnow()
    % Check that the requested move is not 'too large'
    % I.e. when the centroid offset is > half the camera ROI size 
    for jj=1:length(dataStruct.camerapvs)
        m=regexp(dataStruct.camerapvs{jj},app.camerapvs,'match');
        idx = find(~cellfun(@isempty,m));
        tols(1+2*(jj-1))=app.refCamSettings.ROIsizeX(idx)<0.5*abs(laserOffset(1+2*(jj-1))); 
        tols(2*jj)=app.refCamSettings.ROIsizeY(idx)<0.5*abs(laserOffset(2*jj));
    end
    if any(tols)% If requested move is too large exit
    str = ['Warning - Measured laser offset is larger than half the ROI size.',...
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
    
    for n=1:length(channel_index) % This goes to 4 when u include the second mirror
        channel = channel_index(n);        
        str =['Mirror motion = ',num2str(mirrorMovements(n))];
        app.LogTextArea.Value =  [str,app.LogTextArea.Value(:)'];drawnow()
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
%         lcaPutSmart([dataStruct.motorpvs,':CH',num2str(channel),':MOTOR.TWV'], mirrorMovements(n));% Set tweak
%         lcaPutSmart([dataStruct.motorpvs,':CH',num2str(channel),':MOTOR.TWF'],1.0);% Move mot
%         motor_status= lcaGetSmart([dataStruct.motorpvs,':CH',num2str(channel),':MOTOR.MSTA']);
%         while motor_status ~=2
%         motor_status= lcaGetSmart([dataStruct.motorpvs,':CH',num2str(channel),':MOTOR.MSTA']);
%         end
%         motorPositions(n) = lcaGetSmart([dataStruct.motorpvs,':CH',num2str(channel),':MOTOR']);
        pause(.5)

    end
    % Calculate the new beam position
        for jj=1:length(dataStruct.camerapvs)
            [bp(jj,:),img]=grabLaserProperties(dataStruct,jj);
            newlaserCentroids(1+2*(jj-1)) = bp(jj,1);%x setpoint
            newlaserCentroids(2*jj) = bp(jj,2);%y setpoint
        end
end
