function exitcondition = evaluateExitCondition(inputData,refSumCts,refCamSettings,feedbackOnPVs,sectNum,app)

if lcaGetSmart(feedbackOnPVs{sectNum}) 
    % Get the reference settings for this section of the laser
    if sectNum<7%up to and including B3
    refSumCts = [refSumCts(2*sectNum-1) refSumCts(2*sectNum)];
    refCamSettings.ExposureTime = [refCamSettings.ExposureTime(2*sectNum-1) refCamSettings.ExposureTime(2*sectNum)];
    else
       refSumCts = refSumCts(13+(sectNum-7));%B4 thru  B6
       refCamSettings.ExposureTime = refCamSettings.ExposureTime(13+(sectNum-7));
    end
    
    %refCamSettings.ExposureTime = [refCamSettings.ExposureTime(2*sectNum-1) refCamSettings.ExposureTime(2*sectNum)];
    %refCamSettings.ROIminX = [refCamSettings.ROIminX(2*sectNum-1) refCamSettings.ROIminX(2*sectNum)];
    %refCamSettings.ROIminX = [refCamSettings.ROIminY(2*sectNum-1) refCamSettings.ROIminY(2*sectNum)];
    %refCamSettings.ROIsizeX = [refCamSettings.ROIsizeX(2*sectNum-1) refCamSettings.ROIsizeX(2*sectNum)];
    %refCamSettings.ROIsizeY = [refCamSettings.ROIsizeY(2*sectNum-1) refCamSettings.ROIsizeY(2*sectNum)];

    % Get the current laser and camera settings
    for jj=1:length(inputData.camerapvs)
        [bp(jj,:),~]=grabLaserProperties(inputData,jj);
        laserSumCts(jj) = bp(jj,5);% sum Cts
        newCamSettings.ExposureTime(jj) = lcaGetSmart([inputData.camerapvs{jj},':AcquireTime']); % reference Exposure Time
        newCamSettings.ROIminX(jj) = lcaGetSmart([inputData.camerapvs{jj},':MinX_RBV']); % ref ROI x
        newCamSettings.ROIminY(jj) = lcaGetSmart([inputData.camerapvs{jj},':MinY_RBV']); % ref ROI x
        newCamSettings.ROIsizeX(jj) = lcaGetSmart([inputData.camerapvs{jj},':SizeX_RBV']); % ref ROI x
        newCamSettings.ROIsizeY(jj) = lcaGetSmart([inputData.camerapvs{jj},':SizeY_RBV']); % ref ROI x
    end

    % Check that the exposure time has not changed
    exposureTimeTol = any(abs(newCamSettings.ExposureTime-refCamSettings.ExposureTime)>1e-10);
    if exposureTimeTol
     str = ['Warning - Camera exposure time changed.',...
        'Alignment skipped for ',lcaGetSmart([inputData.camerapvs{1},':NAME'])];
    app.LogTextArea.Value =  [str,app.LogTextArea.Value(:)'];drawnow()  
    
    end
    
    % Check that the beam RMS size has not changed 'too much' from its reference value
    for jj=1:length(inputData.camerapvs)
        m=regexp(inputData.camerapvs{jj},app.camerapvs,'match');
        idx = find(~cellfun(@isempty,m));
        rmstols(1+2*(jj-1))=abs(app.refRMSVals(1+2*(idx-1))./bp(jj,3)-1)>0.25;
        rmstols(2*jj)=abs(app.refRMSVals(2*idx)./bp(jj,4)-1)>0.25;
    end
    
    % Apply logic
    
    if any(rmstols)% If requested move is too large exit
    str = ['Warning - Measured laser RMS spotsize has changed by more than 25% of reference RMS.',...
        'Alignment skipped for ',lcaGetSmart([inputData.camerapvs{1},':NAME'])];
    app.LogTextArea.Value =  [str,app.LogTextArea.Value(:)'];drawnow()  
    
    end
    
    %cameraSettingsChanged = ~isequal(refCamSettings,newCamSettings);
    %if cameraSettingsChanged
    %    warning('Camera Settings changed on ',inputData.camerapvs{1})%,...
      %      ' or ',inputData.camerapvs{2},'.')
    %end

    laserOffScreen = abs((refSumCts-laserSumCts)./laserSumCts)>0.5;
    if any(laserOffScreen)
        str = ['Warning - Laser sum cts differs more than 50% from reference in section',...
            num2str(sectNum),'. Feedback will not align this section'];
        app.LogTextArea.Value =  [str,app.LogTextArea.Value(:)'];drawnow()
    end
    %laserOffScreen = 0;
    exitcondition = any([lcaGetSmart(app.feedbackExitPV) laserOffScreen ~lcaGetSmart(feedbackOnPVs{sectNum}) rmstols exposureTimeTol]);
    %if sectNum>5;exitcondition = 1;end
else
    exitcondition = 1;
end
end