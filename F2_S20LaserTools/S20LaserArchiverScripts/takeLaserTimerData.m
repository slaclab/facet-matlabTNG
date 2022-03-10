function takeLaserTimerData(mTimer,~)
    UserData = mTimer.UserData;
    tStart = tic;      
    % Check that the array is not full - if full save data & start over
    for n=1:length(UserData.camerapvs)
        % Check that the camera array rate is not 0 Hz
        if lcaGetSmart([UserData.camerapvs{n},':Image:ArrayRate_RBV'])==0 || isnan(lcaGetSmart([UserData.camerapvs{n},':Image:ArrayRate_RBV']))
            warning(['Camera array rate is 0 Hz - no data acquired for ',UserData.camerapvs{n}])
            continue
        end
        % Load existing data from Matlab array PV
        dataforMatlab = lcaGetSmart(UserData.matlabPvs{n});     
        zeroVals = find(dataforMatlab ==0);
        % If buffer is full save data
        if (length(dataforMatlab)-zeroVals(1))<UserData.nDataPointsPerShot
            saveLaserHealthReport(UserData,n);
            lcaPutSmart(UserData.matlabPvs{n},zeros(length(dataforMatlab),1));
            i0(n) = 1;% start over   
            dataforMatlab = lcaGetSmart(UserData.matlabPvs{n});% read zeros
            disp('Saved Health Report because array was full')
        else
            i0(n) = zeroVals(1);
        end
        
        % If it's the end of the day save data
        if zeroVals(1)>2*UserData.nDataPointsPerShot
            idx = dataforMatlab~=0;
            dataR = reshape(dataforMatlab(idx),UserData.nDataPointsPerShot,length(dataforMatlab(idx))/UserData.nDataPointsPerShot);   
            t = dataR(end-1,:)+dataR(end,:);    
              if weekday(t(end))~=weekday(t(end-1))    
                    saveLaserHealthReport(UserData,n);
                    lcaPutSmart(UserData.matlabPvs{n},zeros(length(dataforMatlab),1));
                    i0(n) = 1;
                    dataforMatlab = lcaGetSmart(UserData.matlabPvs{n});%read zeros
              end
        end
        
        % Grab current laser beam properties
         for m=1:UserData.nshotsForAverage
            beamProperties(m,:)=GrabLaserBeamPropertiesV2(UserData,n);
         end  
         
         % Throw out shots with low counts (e.g. if laser is off screen)
         % sumcounts = beamProperties(m,5);
         % idx = sumcounts < mean(sumcounts) + 2*std(sumcounts);
        beamProperties = mean(beamProperties,1);        
        t1 = now;% Split the timestamp into two numbers so you can store it
        t2 = floor(t1);
        t3 = t1-t2;
        % Store laser data in an array to pass to Matlab Array PV
        data = cat(2,beamProperties,[grabLaserRoomTemp(UserData,n),t2,t3]);
        % Check that the num of datapoints is UserData.nDataPointsPerShot
        if length(data)~=UserData.nDataPointsPerShot
            warning(['Data collected is wrong size for ',UserData.camerapvs{n}])
            data = eps*ones(UserData.nDataPointsPerShot,1);
        end
        % Check that none of the data values are exactly zero
        idx = data ==0;
        if any(idx);data(idx) = eps;end
        
        % Write the laser health data to a Matlab array PV
        dataforMatlab(i0(n):i0(n)-1+length(data))=data;

        % Save one image every 1 hour if you want
       if zeroVals(1)>2*UserData.nDataPointsPerShot
         if str2num(datestr(t(end),'HH'))~=str2num(datestr(t(end-1),'HH'))
            img = profmon_grab(UserData.camerapvs{n},0); img = img.img;
            pth = ['/u1/facet/matlab/data/',datestr(now,'yyyy'),'/',datestr(now,'yyyy-mm'),'/']
            if ~exist(pth);dos(['mkdir ',pth]);end 
            pth = ['/u1/facet/matlab/data/',datestr(now,'yyyy'),'/',datestr(now,'yyyy-mm'),'/',datestr(now,'yyyy-mm-dd'),'/'];
            if ~exist(pth);dos(['mkdir ',pth]);end
            save(strcat(pth,UserData.camerapvs{n},'_',datestr(now,'HH:MM')),'img');
            disp('Saving one image')           
            % Print one image to logbook @ 8AM and 8PM - dont do it for S20
            if n==length(UserData.camerapvs) 
                if ~isempty(regexp(datestr(t(end),'HH'),'08')) || ~isempty(regexp(datestr(t(end),'HH'),'20'))
                    try
                    commentString = checkForLaserDrift(UserData);
                    plot2DLaserProfilesAtSomeTime(datestr(t(end)));                   
                    %util_printLog_wComments(55,'autoS20LaserImageDump','Matlab',sprintf(commentString{:}));close(55);
                    catch
                        disp('Could not auto dump images to logbook')
                    end
                end
             % Check for catastrophic laser event once/hour (laser down on IR cams)
            %  checkForLaserDrift(UserData);% Do this for S10 - Don't do this for S20
            end
         end
       end
        
        % Add new data from last shot to Matlab Array PVs    
        lcaPutSmart(UserData.matlabPvs{n},dataforMatlab,'double');

        % Double check that you'll be able to reshape the stored data on the next timestep
        % Note - at the moment I'm not storing these shots it might be good to store when it happens so you
        % Can see what that correlates with in time...
	 storedData = lcaGetSmart(UserData.matlabPvs{n});
	 ids = storedData~=0;
         try
         dataRs = reshape(storedData(ids),UserData.nDataPointsPerShot,length(storedData(ids))/UserData.nDataPointsPerShot);                                                                                 
         catch e
	 warning(['Stored data size incompatible with num of data points per shot. Data not stored on cam.',num2str(UserData.camerapvs{n})]);
         goodShots = floor(sum(ids)/UserData.nDataPointsPerShot);
         goodStoredData = storedData(1:goodShots*UserData.nDataPointsPerShot);
         lcaPutSmart(UserData.matlabPvs{n},goodStoredData,'double');   
	 end
      
    end    
    disp(['Last Data Taken at ',datestr(now)])
    tElapsed = toc(tStart);
end
