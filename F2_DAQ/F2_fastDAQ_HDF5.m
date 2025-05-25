classdef F2_fastDAQ_HDF5 < handle
    events
        PVUpdated % PV object list notifies this event after each set of monitored PVs have finished updating
    end
    properties
        pvlist PV
        pvs
        params
        data_struct
        objhan
        freerun = true
        daq_pvs
        Instance
        event
        event_info
        scan_info
        save_info
        step
        async_data
        bsa_list
        scp_list
        nonbsa_list
        nonbsa_array_list
        scp_manager
        scanFunctions
        %eDefNum
        daq_status
        camCheck
        BG_obj
        doStream = false
        blockBeam = false
        shotsArray
        BPMS_cmd
    end
    properties(Hidden)
        listeners
    end
    properties(Constant)
        maxbeat=1e7 % max heartbeat count, wrap to zero
        %maxImSize = 1440744
        maxImSize = 4177920
        pulseIDPV = 'PATT:SYS1:1:PULSEID'
        secPV = 'PATT:SYS1:1:SEC'
        nSecPV = 'PATT:SYS1:1:NSEC'
        offset = 198; % this for extracting pulse ID from file
        
        ecs = [201,203,213,214,222,223,224,225,226,131,53,54,55,56]
        n_ecs = 14
        
        version = 2.0 % this is the datastruct version, update on change
    end
    
    methods
        
        function obj = F2_fastDAQ_HDF5(DAQ_params,apph)
            
            obj.params = DAQ_params;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% This block is Glen's boiler plate.                    %%%
            %%% 'apph' determines if DAQ was called by GUI or script. %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Check if DAQ called by GUI
            if exist('apph','var')
                obj.objhan=apph;
                obj.freerun = false;
                obj.camCheck = apph.camCheck;
            else
                obj.camCheck = F2_CamCheck(true);
                
                [~,ia,~] = intersect(obj.camCheck.camNames,obj.params.camNames);
                list_bool = false(size(obj.camCheck.camNames));
                list_bool(ia) = true;
                obj.camCheck.downSelect(list_bool);
                obj.camCheck.checkTrigStat();
            end
                        
            % initialize object and add PVs to be monitored
            context = PV.Initialize(PVtype.EPICS) ;
            obj.pvlist=[...
                PV(context,'name',"DAQ_Running",'pvname',"SIOC:SYS1:ML02:AO352",'mode',"rw",'monitor',true); % Is DAQ running?
                PV(context,'name',"DAQ_Abort",'pvname',"SIOC:SYS1:ML02:AO353",'mode',"rw",'monitor',true); % Abort request
                PV(context,'name',"DAQ_Instance",'pvname',"SIOC:SYS1:ML02:AO400",'mode',"rw",'monitor',true); % Number of times DAQ is run
                PV(context,'name',"DAQ_Exp",'pvname',"SIOC:SYS1:ML02:AO398",'mode',"rw",'monitor',true); % Exp number
                PV(context,'name',"MPS_Shutter",'pvname',"IOC:SYS1:MP01:MSHUTCTL",'mode',"rw",'monitor',true); % MPS Shutter
                PV(context,'name',"MPS_Shutter_RBV",'pvname',"SHUT:LT10:950:IN_MPS",'mode',"rw",'monitor',true); % MPS Shutter
                PV(context,'name',"Pockels_Cell",'pvname',"TRIG:LT10:LS04:TCTL",'mode',"rw",'monitor',true); % S10 Pockels Call
                PV(context,'name',"BSA_nRuns",'pvname',"SIOC:SYS1:ML02:AO500",'mode',"rw",'monitor',true); % BSA thing
                PV(context,'name',"DAQ_DataOn",'pvname',"SIOC:SYS1:ML02:AO354",'mode',"rw",'monitor',true); % DAQ Data On
                ] ;
            pset(obj.pvlist,'debug',0);
            obj.pvs = struct(obj.pvlist);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Final checks and setup before running the DAQ %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Check if DAQ is running
            running = caget(obj.pvs.DAQ_Running);
            if running
               obj.dispMessage('Cannot start new DAQ. DAQ already running.');
               return
            end
            caput(obj.pvs.DAQ_Running,1);
            
            % Clear old aborts
            abort = caget(obj.pvs.DAQ_Abort);
            if abort
               caput(obj.pvs.DAQ_Abort,0);
               obj.dispMessage('Clearing abort status.');
            end
            
            % Update DAQ instance
            obj.Instance = caget(obj.pvs.DAQ_Instance)+1;
            caput(obj.pvs.DAQ_Instance,obj.Instance);
            obj.dispMessage(sprintf('Started DAQ instance %d.',obj.Instance));
            
            % Update DAQ experiment
            if strcmp(obj.params.experiment,'TEST')
                expNum = 0;
            else
                expNum = str2num(obj.params.experiment(2:end));
            end
            caput(obj.pvs.DAQ_Exp,expNum);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Add DAQ params, save params,  %%%
            %%% event params, and PV metadata %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Save DAQ params to data_struct
            obj.data_struct.params = obj.params;
            obj.data_struct.metadata = struct();
            
            % Choose streaming or not
            obj.doStream = obj.params.doStream;
            
            % Create Data Path on NAS drive and save info to data_struct
            obj.save_info = set_DAQ_filepath(obj);
            obj.data_struct.save_info = obj.save_info;
            
            % Create EventClass for controlling global event triggers
            obj.event = F2_EventClass(); % edef reserved here
            obj.event.select_rate_HDF5(obj.params.rate);
            obj.event_info = obj.event.evt_struct();
            obj.data_struct.metadata.Event = obj.event_info;
            
            % Let SCPManager class manage SCP stuff
            obj.scp_manager = F2_SCPManager(obj.params.SCP_list,obj.params.n_shot,obj);

            % Set beam blocking if requested
            obj.blockBeam = obj.params.blockBeam;
            
            % Generate metadata for cameras and PVs
            obj.createMetadata();
                        
            % Fill in the rest of the data struct to prepare for data
            obj.setupDataStruct();
            
            % Fill in scan functions
            obj.scanFunctions = struct();
%             try
            for i = 1:numel(obj.params.scanFuncs)
                if strcmp(obj.params.scanFuncs{i},"Use_PV")
                    obj.scanFunctions.Use_PV = scanFunc_Use_PV(obj,...
                        obj.params.scanPVs{i},obj.params.RBV_PVs{i},obj.params.Waits{i},obj.params.Tolerance{i});
                else
                    obj.scanFunctions.(obj.params.scanFuncs{i}) = feval(['scanFunc_' obj.params.scanFuncs{i}],obj);
                end
            end
%             catch ME
%                 obj.dispMessage('Error getting scan function');
%                 disp(ME.message)
%                 obj.event.release_eDef();
%                 return
%             end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Camera prep and check %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Get PVs for cam control
            obj.daq_pvs = camera_DAQ_PVs(obj.params.camPVs);
            
            % Set DAQ_InUse PV for cameras
%             lcaPutSmart(obj.daq_pvs.DAQ_InUse,1);
            
            % Test cameras before starting
            obj.checkCams();
            status = obj.check_abort();
            if status; obj.end_scan(status); return; end
            
            % Prep cams -> make sure they are in good state
            obj.prepCams();
            
            % Get backgrounds
            try
                obj.BG_obj = F2_getBG(obj);
                obj.data_struct.backgrounds = struct;
                obj.data_struct.backgrounds.getBG = obj.params.saveBG;
                obj.data_struct.backgrounds.laserBG = obj.params.laserBG;
                if obj.params.saveBG || obj.params.laserBG
                   obj.data_struct.backgrounds = obj.BG_obj.getBackground();
                end
            catch ME
                obj.dispMessage('Error getting backgrounds');
                disp(ME.message)
                obj.event.release_eDef();
                return
            end
            
            % Stop buffer
            obj.event.stop_eDef();
            
            %%%%%%%%%%%%%%%%%%%%
            %   Run the DAQ!  %%
            %%%%%%%%%%%%%%%%%%%%
            status = obj.daq_loop();
            obj.end_scan(status);
            
        end
        
        function status = daq_loop(obj)
            % The meat of the matter
            
            % Make sure DAQ isn't saving images in extra dimensions
            lcaPut(obj.daq_pvs.HDF5_NumExtraDims,0);
            lcaPut(obj.daq_pvs.HDF5_ExtraDimSizeN,0);
            lcaPut(obj.daq_pvs.HDF5_ExtraDimSizeX,0);
            lcaPut(obj.daq_pvs.HDF5_ExtraDimSizeY,0);
            
            % This is a "simple" DAQ
            if obj.params.scanDim == 0
                
                obj.step = 1;
                try
                    status = obj.daq_step();
                    
                    % we are done BUFFACQ eDef
                    obj.event.release_eDef();
                    return
                catch ME
                    disp(ME.message)
                    obj.dispMessage(sprintf('DAQ failed on step %d',obj.step));
                    status = 1;
                    
                    % we are done BUFFACQ eDef
                    obj.event.release_eDef();
                    return
                end 
            end
            
            % This is a scan
            old_steps = nan(1,obj.params.scanDim);
            
            for i = 1:obj.params.totalSteps
                obj.step = i;
                
                new_steps = obj.params.stepsAll(i,:);
            
                for j = 1:obj.params.scanDim
                    
                    if ~obj.params.allowDuplicateSteps
                        if new_steps(j) == old_steps(j); continue; end
                    end
                    
                    obj.dispMessage(sprintf('Setting %s to %0.2f',obj.params.scanFuncs{j},obj.params.scanVals{j}(new_steps(j))));
                    if obj.blockBeam
                        obj.BG_obj.block_Pockels_cell()
                    end
                    obj.scanFunctions.(obj.params.scanFuncs{j}).set_value(obj.params.scanVals{j}(new_steps(j)));
                end
                
                try
                    status = obj.daq_step();
                catch ME
                    disp(ME.message);
                    obj.dispMessage(sprintf('DAQ failed on step %d',obj.step));
                    status = 1;
                end
                
                if status; return; end
                
                old_steps = new_steps;
                
            end
            
            % we are done BUFFACQ eDef
            obj.event.release_eDef();
        end
        
        % status = 0 -> ok. status = 1 -> DAQ failed or aborted
        function status = daq_step(obj)
            
            waitTime = obj.params.n_shot/obj.event_info.liveRate;
            
            obj.dispMessage(sprintf('Starting DAQ Step %d. Time estimate %0.1f seconds.',obj.step, waitTime));
            
            % Set up camera files
            lcaPut(obj.daq_pvs.HDF5_FileNumber,0);
            set_CAM_filepath_HDF5(obj);
            
            % If we are requesting SCP data
            if obj.params.saveSCP
                % Start SCP Buffered Acquisition
                scp_status = obj.scp_manager.startBuffAcq(obj.step);
                if scp_status == 0
                    % Pause for SCP data acquisiton setup
                    pause(0.5);
                    obj.dispMessage('SCP data acquisition started');
                else
                    obj.dispMessage('SCP acquisition failed to start');
                end
            end
            
            % Start image capture
            lcaPutNoWait(obj.daq_pvs.HDF5_Capture,1);
            obj.dispMessage('Image data acquisition started')
            
            % Start BSA acquisition
            obj.event.start_eDef();
            obj.dispMessage('BSA acquisition started')
            
            % Start timer
            timer = tic;
            
            % if blockBeam
            if obj.blockBeam
            	obj.BG_obj.enable_Pockels_cell()
            end
            
            % Get data and count shots
            while toc(timer) < waitTime
                
                pause(1/obj.event_info.liveRate); % derive this from beam rate
                obj.async_data.addDataFR();
                % Add array data? obj.async_data.addArrayData();
                
                % Add a "check abort" here
                status = obj.check_abort;
                if status; return; end
            end

            % Buffers should be full, stop buffer data
            obj.event.stop_eDef();
            obj.dispMessage('BSA acquisition complete')
            
            % Stop capture, regardless of how many shots were saved
            lcaPut(obj.daq_pvs.HDF5_Capture,0);

            obj.dispMessage('Acquisition complete. Starting quality control.');

            % Get BSA and non-BSA data
            status = obj.collectData();

            % Check FileNumber_RBV and WriteFile_RBV PVs
            % If FileNumber_RBV is stuck at 0, then that means writing
            % command never got sent. Send a command to write file if this
            % is the case
            fileNums = lcaGetSmart(obj.daq_pvs.HDF5_FileNumber_RBV); % should be 1
            if any(~fileNums)
                lcaPutSmart(obj.daq_pvs.HDF5_WriteFile(~fileNums),1);
            end

            obj.dispMessage('Checking if cameras are still writing data.');
            
            writingStatus = lcaGetSmart(obj.daq_pvs.HDF5_WriteFile_RBV);
            while any(~strcmp(writingStatus,'Done'))
                writingStatus = lcaGetSmart(obj.daq_pvs.HDF5_WriteFile_RBV);
                if any(~strcmp(writingStatus,'Done'))
                    for c=1:numel(writingStatus)
                        if ~strcmp(writingStatus(c),'Done')
                            obj.dispMessage([obj.params.camNames{c} ' still writing data']);
                        end
                    end
                end
                % Check and break if there is a writing error
                errorStatus = lcaGetSmart(obj.daq_pvs.HDF5_WriteStatus);
                if strcmp(errorStatus,'Write error')
                    break
                end
                pause(1);
            end
            
            obj.dispMessage('Camera data written.');
        end
        
        function end_scan(obj,status)
            
            if status
                obj.dispMessage('Ending failed/aborted scan.');
                obj.event.stop_eDef();
                obj.event.release_eDef();
                % This indicates data taking has ended
                caput(obj.pvs.DAQ_DataOn,0);
            end
            
            % Restore triggers
            obj.camCheck.restore_trig_event(obj.params.EC);
       
            if obj.params.scanDim > 0
                
                obj.dispMessage('Restoring scan functions to initial value.');
                for j = 1:obj.params.scanDim
                    obj.scanFunctions.(obj.params.scanFuncs{j}).restoreInitValue();
                end
                
            end
            
            obj.dispMessage('Collecting camera data.');
            status = obj.getCamData();
            
            if obj.params.saveSCP
                obj.dispMessage('Collecting SCP BPM data');
                obj.getSCPdata();
            end
            
            obj.dispMessage('Comparing pulse IDs.');
            obj.compareUIDs();
            
            obj.dispMessage('Saving data.');
            obj.save_data();
            
            if obj.params.print2elog
                obj.dispMessage('Writing to eLog.');
                obj.write2eLog(status);
            end
            
            obj.dispMessage('Done!');
            caput(obj.pvs.DAQ_Running,0);
            lcaPutSmart(obj.daq_pvs.DAQ_InUse,0);
        end
        
        function status = checkShots(obj) % this function isn't used anymore
            % Checks that num of shots captured is going up at around the same
            % rate for all cameras
            status = 0;
            
            shots = lcaGet(obj.daq_pvs.HDF5_NumCaptured_RBV);  % returns a vector

            check_vec = obj.step*obj.params.n_shot*ones(obj.params.num_CAM,1);
            
            good = (check_vec == shots); % logical vector
            final_shots = zeros(size(shots));
            final_shots(good) = shots(good);
            
            any_bad = sum(~good);
            
            % the problem seems to be that after collecting all N shots,
            % some cameras immediately drop back down to zero. so maybe
            % have to deal with this on a camera by camera basis
            
            shotsTimer = tic;
            
            while any_bad && toc(shotsTimer) < 3
                new_shots = lcaGet(obj.daq_pvs.HDF5_NumCaptured_RBV);
                new_good = (check_vec == new_shots);
                final_shots(new_good) = new_shots(new_good);
                
                % add new good shots to list
                good = good | new_good;
                any_bad = sum(~good);

                pause(1);
            end
                
            if toc(shotsTimer) > 3
                obj.dispMessage('Cameras have not saved all shots after waiting 3 seconds.');
                %status = 1;
%                     break;

                % Alternatively, try to fix it?
                % not 100% sure how to do this yet
            end
            
            if any_bad
                final_shots(~good) = new_shots(~good);
            end
            
            % Create shotsArray here
            obj.shotsArray = [obj.shotsArray,final_shots];
        end
        
        function status = collectData(obj)
            % Get pulse IDs, BSA and non BSA data
            n_use = lcaGet(sprintf('%sHST%d.NUSE',obj.pulseIDPV,obj.event.eDefNum));
            pulse_IDs = lcaGet(sprintf('%sHST%d',obj.pulseIDPV,obj.event.eDefNum),n_use)';
            seconds = lcaGet(sprintf('%sHST%d',obj.secPV,obj.event.eDefNum),n_use)';
            nSeconds = lcaGet(sprintf('%sHST%d',obj.nSecPV,obj.event.eDefNum),n_use)';
            slac_time = seconds + nSeconds/1e9;
            
            UIDs = obj.generateUIDs(pulse_IDs,obj.step);
            steps = obj.step*ones(size(pulse_IDs));
            
            obj.data_struct.pulseID.scalar_PID = [obj.data_struct.pulseID.scalar_PID; pulse_IDs];
            obj.data_struct.pulseID.scalar_UID = [obj.data_struct.pulseID.scalar_UID; UIDs];
            obj.data_struct.pulseID.steps      = [obj.data_struct.pulseID.steps; steps];
            obj.data_struct.pulseID.SLAC_time  = [obj.data_struct.pulseID.SLAC_time; slac_time];
            
            obj.data_struct.scalars.steps = [obj.data_struct.scalars.steps; steps];
            
            obj.dispMessage('beep');
            
            try
                obj.getBSAdata(n_use);
                status = 0;
            catch ME
                disp(ME.message)
                obj.dispMessage('BSA data failed.');
                status = 1;
            end
            
            obj.dispMessage('bop');
                        
            try 
                obj.getNonBSAdata(slac_time);
                status = 0;
            catch ME
                disp(ME.message)
                obj.dispMessage('Non-BSA data failed.');
                status = 1;
            end
            
            obj.dispMessage('borp');
                        
            obj.dispMessage('Quality control complete.');
        end
        
        function getBSAdata(obj,n_use)
            
            for i = 1:numel(obj.params.BSA_list)
                
                for j = 1:numel(obj.data_struct.metadata.(obj.params.BSA_list{i}).PVs)
                    pv = obj.data_struct.metadata.(obj.params.BSA_list{i}).PVs{j};
                    new_vals = lcaGet([pv 'HST' num2str(obj.event.eDefNum)],n_use);
                    obj.data_struct.scalars.(obj.params.BSA_list{i}).(strrep(pv,':','_')) = ...
                        [obj.data_struct.scalars.(obj.params.BSA_list{i}).(strrep(pv,':','_')); new_vals'];
                end
            end
            
        end
        
        function getNonBSAdata(obj,slac_time)
            
            obj.async_data.interpolate(slac_time);
            
            for i = 1:numel(obj.params.nonBSA_list)
                
                for j = 1:numel(obj.data_struct.metadata.(obj.params.nonBSA_list{i}).PVs)
                    pv = obj.data_struct.metadata.(obj.params.nonBSA_list{i}).PVs{j};
                    obj.data_struct.scalars.(obj.params.nonBSA_list{i}).(remove_dots(pv)) = ...
                        [obj.data_struct.scalars.(obj.params.nonBSA_list{i}).(remove_dots(pv)); obj.async_data.interpData.(remove_dots(pv))];
                end
            end
        end
        
        function status = getCamData(obj)
            % Read HDF5 image files, extract pulse IDs
            status = 0;
            if obj.params.totalSteps == 0
                nSteps = 1;
            else
                nSteps = obj.params.totalSteps;
            end
         
            obj.daq_status(:,1) = zeros(obj.params.num_CAM,1);
            for k = 1:nSteps
                % if the DAQ failed before completing all steps, don't try
                % to save data after step where it failed
%                 if k > obj.step
%                     obj.dispMessage('No camera data to save after this step!')
%                     break
%                 end
                for i = 1:obj.params.num_CAM
                    
                    % Try to read HDF5 file
                    tryCount = 0; % timeout is 60 s
                    success = false; % success means HDF5 file was created and is readable
                    
                    while ~success && tryCount < 60
                        try
                            dirInfo = dir([obj.save_info.cam_paths{i} '/*_data_step' num2str(k,'%02d') '.h5']);
                            h5fn = [obj.save_info.cam_paths{i} '/' dirInfo.name];
                            info = h5info(h5fn,'/entry/data/data');
                            
                            success = true;
                        catch
                            if tryCount == 0
                                obj.dispMessage('Could not read HDF5 file, trying again. Max wait is 60 s.');
                            end
                            success = false;
                        end
                        tryCount = tryCount + 1;
                        status = obj.check_abort();
                        if status; return; end
                        pause(1);
                    end
                    
                    if tryCount == 60
                        obj.dispMessage(['Could not read HDF5 file: ' h5fn '. Skipping step.']);
                        status = 1;
                        continue;
                    end
                    
                    n_imgs = prod(info.Dataspace.Size(3:end)); % number of images in this step
                    obj.daq_status(i,1) = obj.daq_status(i,1)+n_imgs; % number of images saved
                    obj.daq_status(i,2) = obj.params.n_shot; % number of images requested
                    
                    if n_imgs < obj.params.n_shot
                        obj.dispMessage([obj.params.camNames{i} ' didn"t save all the shots on step ' num2str(k) '.']);
                    end
                    if n_imgs == 0
                        obj.dispMessage([obj.params.camNames{i} ' saved zero shots. Skipping step ' num2str(k) '.']);
                        status = 1;
                        continue;
                    end
                    
                    disp('bleep');
                    
                    % Add the paths of images found to 'loc'
                    locs = strcat([obj.save_info.cam_paths{i} '/'],{dirInfo.name}');
                    obj.data_struct.images.(obj.params.camNames{i}).loc = ...
                        [obj.data_struct.images.(obj.params.camNames{i}).loc; locs];
                    
                    disp('blop');
                    
                    status = obj.check_abort();
                    if status; return; end
                    
                    % Get PIDs from location in HDF5 file and save in data_struct
                    PIDs = h5read(h5fn,'/entry/instrument/NDAttributes/NDArrayUniqueId');
                    PIDs = double(PIDs);
                    
                    disp('blorp');
                                        
                    UIDs = obj.generateUIDs(PIDs,k);
                    steps = k*ones(size(PIDs));
                    
                    obj.data_struct.images.(obj.params.camNames{i}).pid = ...
                        [obj.data_struct.images.(obj.params.camNames{i}).pid; PIDs];
                    obj.data_struct.images.(obj.params.camNames{i}).uid = ...
                        [obj.data_struct.images.(obj.params.camNames{i}).uid; UIDs];
                    obj.data_struct.images.(obj.params.camNames{i}).step = ...
                        [obj.data_struct.images.(obj.params.camNames{i}).step; steps];
                end
            end
            
        end
        
        function getSCPdata(obj)
            % Get SCP data from txt files and save to data_struct
            
            try
                obj.scp_manager.getSCPdata(obj.params.scanDim,obj.params.totalSteps);

                for i = 1:numel(obj.params.SCP_list)
                    obj.data_struct.scalars.(obj.params.SCP_list{i}) = ...
                        obj.scp_manager.data.(obj.params.SCP_list{i});
                end

                pid = obj.scp_manager.data.pids;
                steps = obj.scp_manager.data.steps;

                % Create UIDs
                uids = obj.generateUIDs(pid,steps);
                
                obj.data_struct.pulseID.scalar_PID_SCP = pid;
                obj.data_struct.pulseID.scalar_UID_SCP = uids;

                % Add to data_struct
                obj.data_struct.scalars.steps_SCP = steps;
                obj.data_struct.pulseID.steps_SCP = steps;
            catch ME
                disp(ME.message)
            end

        end
        
        function compareUIDs(obj)
            COMMON_UID = obj.data_struct.pulseID.scalar_UID;
            
            % Compare scalar (BSA) UIDs and camera UIDs
            for i = 1:obj.params.num_CAM
                % This finds matches between each camera and BSA data
                [~,~,camera_index] = intersect(obj.data_struct.pulseID.scalar_UID,obj.data_struct.images.(obj.params.camNames{i}).uid,'stable');
                obj.data_struct.images.(obj.params.camNames{i}).scalar_index = camera_index;
    
                COMMON_UID = intersect(COMMON_UID,obj.data_struct.images.(obj.params.camNames{i}).uid,'stable');
                
            end
            
            [~,~,scalar_index] = intersect(COMMON_UID,obj.data_struct.pulseID.scalar_UID,'stable');
            obj.data_struct.pulseID.common_scalar_index = scalar_index;
            obj.data_struct.scalars.common_index = scalar_index;
            % Up to here nothing should be different...
            
            % Find SCP matches
            if obj.params.saveSCP
                [COMMON_UID_inclSCP,~,scalar_index_SCP] = intersect(COMMON_UID,obj.data_struct.pulseID.scalar_UID_SCP,'stable');
                obj.data_struct.pulseID.common_scalar_index_SCP = scalar_index_SCP;
                obj.data_struct.scalars.common_index_SCP = scalar_index_SCP;
                
                obj.data_struct.pulseID.common_UIDs_inclSCP = COMMON_UID_inclSCP;
                obj.data_struct.pulseID.common_PIDs_inclSCP = ...
                    obj.data_struct.pulseID.scalar_PID_SCP(obj.data_struct.pulseID.common_scalar_index_SCP);
                                
                % Loop to get camera common idx including SCP
                for i = 1:obj.params.num_CAM
                    [~,~,camera_index_inclSCP] = intersect(COMMON_UID_inclSCP,obj.data_struct.images.(obj.params.camNames{i}).uid,'stable');

                    obj.data_struct.images.(obj.params.camNames{i}).common_index_inclSCP = camera_index_inclSCP;
                    obj.data_struct.pulseID.([obj.params.camNames{i} 'common_index_inclSCP']) = camera_index_inclSCP;
                    
                    obj.daq_status(i,4) = numel(camera_index_inclSCP);
                end
                
                % Get BSA common idx including SCP
                [~,~,scalar_index_inclSCP] = intersect(COMMON_UID_inclSCP,obj.data_struct.pulseID.scalar_UID,'stable');
                obj.data_struct.pulseID.common_scalar_index_inclSCP = scalar_index_inclSCP;
                obj.data_struct.scalars.common_index_inclSCP = scalar_index_inclSCP;
            end
            
            % Loop to find number of BSA/camera matches (not including SCP)
            for i = 1:obj.params.num_CAM
                [~,~,camera_index] = intersect(COMMON_UID,obj.data_struct.images.(obj.params.camNames{i}).uid,'stable');
                
                obj.data_struct.images.(obj.params.camNames{i}).common_index = camera_index;
                obj.data_struct.pulseID.([obj.params.camNames{i} 'common_index']) = camera_index;
                
                obj.daq_status(i,3) = numel(camera_index);
            end
                        
            obj.data_struct.pulseID.common_UIDs = COMMON_UID;
            obj.data_struct.pulseID.common_PIDs = obj.data_struct.pulseID.scalar_PID(obj.data_struct.pulseID.common_scalar_index);
        end                
        
        function UIDs = generateUIDs(obj,pulseIDs,step)
            UIDs = 1e9*obj.Instance + 1e6*step + pulseIDs;
        end
        
        function save_data(obj)
            % Suppress weird EPICS warning -- not the best workaround but
            % ok for now
            wid = 'MATLAB:Java:ConvertFromOpaque';
            wstate = warning('off',wid);
            
            data_struct = obj.data_struct;
            
            save_str = [obj.save_info.save_path '/' obj.params.experiment '_' num2str(obj.save_info.instance,'%05d')];

            save(save_str,'data_struct');
            
            warning(wstate); % restore warning after we are done saving
        end
        
        function write2eLog(obj,status)
            
            if status
                fail_str = sprintf(['DAQ FAILED/ABORTED' '\n']);
            end
            
            if obj.params.totalSteps == 0
                nSteps = 1;
            else
                nSteps =  obj.params.totalSteps;
            end
            
            comment_str = sprintf([obj.params.comment{1} '\n']);
            camera_str = '';
            
            camera_str = sprintf([camera_str '\n']);
            
            DAQ_str  = sprintf(['FACET DAQ ' num2str(obj.Instance,'%05d') ' for ' obj.params.experiment '.\n']);
            
            Data_str = sprintf([num2str(obj.params.n_shot) ' shots per step and %d steps.\n'],obj.params.totalSteps);
            
            if obj.params.scanDim == 0
                Scan_str = sprintf(['Simple DAQ ' '\n']);
            else
                Scan_str = '';
                for i=1:obj.params.scanDim
                    scan_line = sprintf('Scan of %s (PV %s) from %0.2f to %0.2f in %d steps.\n',...
                        obj.params.scanFuncs{i},obj.params.scanPVs{i},obj.params.startVals(i),obj.params.stopVals(i),obj.params.nSteps(i));
                    Scan_str = [Scan_str scan_line];
                end
                sprintf(Scan_str);
            end
            
            Path_str = sprintf(['Path: ' obj.save_info.save_path '\n' '\n']);
            
            if obj.params.saveSCP
                info_str = sprintf(['| NAME | SAVE | REQ | MATCH | SCP MATCH ' '\n']);
            else
                info_str = sprintf(['| NAME | SAVE | REQ | MATCH ' '\n']);
            end
            
            for i = 1:obj.params.num_CAM
                if obj.params.totalSteps == 0
                    tot_req = obj.daq_status(i,2);
                else
                    tot_req = obj.params.totalSteps*obj.daq_status(i,2);
                end
                
                if obj.params.saveSCP
                    mat_line   = sprintf(['| ' obj.params.camNames{i} ' | ' num2str(obj.daq_status(i,1)) ' | '...
                        num2str(tot_req) ' | ' num2str(obj.daq_status(i,3)) ' | ' num2str(obj.daq_status(i,4)) ' ' '\n']);
                % add a disp message here?
                else
                    mat_line   = sprintf(['| ' obj.params.camNames{i} ' | ' num2str(obj.daq_status(i,1)) ' | '...
                        num2str(tot_req) ' | ' num2str(obj.daq_status(i,3)) ' ' '\n']);
                % add a disp message here?
                end
                obj.dispMessage(mat_line);
                info_str = [info_str mat_line];
            end
            info_str = sprintf([info_str '\n' '\n']);
            
            if status
                Comment  = [fail_str comment_str camera_str DAQ_str Data_str Scan_str Path_str info_str];
            else
                Comment  = [comment_str camera_str DAQ_str Data_str Scan_str Path_str info_str];
            end
            
            FACET_DAQ2LOG(Comment,obj);
        end
            
        function checkCams(obj)
            bad_cam = obj.camCheck.checkConnect(true);
            
            for i = 1:obj.params.num_CAM
                if bad_cam(i)
                    message = ['Camera ' obj.params.camNames{i} ' is disconnected.'];
                    reply = questdlg(message,'Camera Down','Wait and retry','Abort DAQ');
                    switch reply
                        case 'Wait and retry'
                            obj.checkCams();
                        case 'Abort DAQ'
                            status = obj.check_abort();
                            if status; return; end
                            
                    end
                end
            end
        end
        
        function prepCams(obj)
            
            lcaPutSmart(obj.daq_pvs.Acquire,1);
            lcaPutSmart(obj.daq_pvs.DataType,'UInt16');
            lcaPutSmart(obj.daq_pvs.ROI_EnableCallbacks,1);
            lcaPutSmart(obj.daq_pvs.TSS_SETEC,obj.params.EC);
            
            lcaPut(obj.daq_pvs.HDF5_EnableCallbacks,1);
            if obj.doStream
                lcaPut(obj.daq_pvs.HDF5_FileWriteMode,2); % 2 =streaming (fast)
            else
                lcaPut(obj.daq_pvs.HDF5_FileWriteMode,1); % 1=capture (slow)
            end
            lcaPutSmart(obj.daq_pvs.HDF5_AutoIncrement,1);
            lcaPutSmart(obj.daq_pvs.HDF5_AutoSave,1);
            
            lcaPutSmart(obj.daq_pvs.HDF5_NumCapture,obj.params.n_shot);
            
            % Check if spectrometer is being used, if so set "Start" PV
            
            
            obj.camCheck.set_trig_event(obj.params.EC);
            
        end
        
        function createMetadata(obj)
            
            % loop over cameras and add metadata
            for i = 1:obj.params.num_CAM
                obj.data_struct.metadata.(obj.params.camNames{i}) = get_cam_info(obj.params.camPVs{i});
                obj.data_struct.metadata.(obj.params.camNames{i}).sioc = obj.params.camSIOCs{i};
                obj.data_struct.metadata.(obj.params.camNames{i}).trigger = obj.params.camTrigs{i};
                
                % Add spectrometer metadata here - min/max wavelength
                if contains(obj.params.camNames{i},'Spec','IgnoreCase',true)
                    wavelengths = lcaGetSmart('SPEC:LI20:PM02:Wavelengths');
                    obj.data_struct.metadata.(obj.params.camNames{i}).Min_Wavelength = min(wavelengths);
                    obj.data_struct.metadata.(obj.params.camNames{i}).Max_Wavelength = max(wavelengths);
                end
            end
            
            % Fill in BSA data
            obj.bsa_list = {obj.pulseIDPV; obj.secPV; obj.nSecPV;};
            for i = 1:numel(obj.params.BSA_list)
                pvList = feval(obj.params.BSA_list{i});
                %pvDesc = lcaGetSmart(strcat(pvList,'HSTBR.DESC'));
                pvDesc = pvList; % Temporary
                
                obj.data_struct.metadata.(obj.params.BSA_list{i}).PVs = pvList;
                obj.data_struct.metadata.(obj.params.BSA_list{i}).Desc = pvDesc;
                
                obj.bsa_list = [obj.bsa_list; pvList];
            end
            
            % Fill in SCP BPM data
            for i = 1:numel(obj.params.SCP_list)
                obj.data_struct.metadata.(obj.params.SCP_list{i}) =...
                    obj.scp_manager.metadata.(obj.params.SCP_list{i});
            end
            
            % Fill in non-BSA data
            obj.nonbsa_list = {obj.pulseIDPV; obj.secPV; obj.nSecPV;};
            obj.async_data = acq_nonBSA_data(obj.nonbsa_list,obj);
            for i = 1:numel(obj.params.nonBSA_list)
                list = feval(obj.params.nonBSA_list{i});
                list = obj.async_data.addList(list);
                desc = obj.async_data.getDesc(list);
                
                obj.data_struct.metadata.(obj.params.nonBSA_list{i}).PVs = list;
                obj.data_struct.metadata.(obj.params.nonBSA_list{i}).Desc = desc;
                
                %obj.nonbsa_list = [obj.nonbsa_list; list];
            end
            %obj.async_data = acq_nonBSA_data(obj.nonbsa_list,obj);
            
            % Fill in non-BSA arrays
            if obj.params.include_nonBSA_arrays
                for i = 1:numel(obj.params.nonBSA_Array_list)
                    pvList = feval(obj.params.nonBSA_Array_list{i});
                    pvList = obj.async_data.addListArray(pvList);
%                     pvDesc = lcaGetSmart(strcat(pvList,'.DESC'));
                    pvDesc = pvList; % Temporary
                    
                    obj.data_struct.metadata.(obj.params.nonBSA_Array_list{i}).PVs = pvList;
                    obj.data_struct.metadata.(obj.params.nonBSA_Array_list{i}).Desc = pvDesc;
                
%                     obj.nonbsa_array_list = [obj.nonbsa_array_list; pvList];
                    
                end

            end
            
            
        end
        
        function setupDataStruct(obj)
            obj.data_struct.version = obj.version;
            obj.data_struct.pulseID = struct();
            obj.data_struct.pulseID.scalar_PID = [];
            obj.data_struct.pulseID.scalar_UID = [];
            obj.data_struct.pulseID.steps = [];
            obj.data_struct.pulseID.SLAC_time = [];
            
            obj.data_struct.scalars = struct();
            obj.data_struct.scalars.steps = [];

            for i = 1:numel(obj.params.BSA_list)
                obj.data_struct.scalars.(obj.params.BSA_list{i}) = struct();
                for j=1:numel(obj.data_struct.metadata.(obj.params.BSA_list{i}).PVs)
                    pv = obj.data_struct.metadata.(obj.params.BSA_list{i}).PVs{j};
                    obj.data_struct.scalars.(obj.params.BSA_list{i}).(remove_dots(pv)) = [];
                end
            end
            
            if obj.params.saveSCP
                obj.data_struct.pulseID.scalar_PID_SCP = [];
                obj.data_struct.pulseID.scalar_UID_SCP = [];
                obj.data_struct.pulseID.steps_SCP = [];
                obj.data_struct.scalars.steps_SCP = [];
                
                for i = 1:numel(obj.params.SCP_list)
                    obj.data_struct.scalars.(obj.params.SCP_list{i}) = struct();
                    for j=1:numel(obj.data_struct.metadata.(obj.params.SCP_list{i}).PVs)
                        pv = obj.data_struct.metadata.(obj.params.SCP_list{i}).PVs{j};
                        obj.data_struct.scalars.(obj.params.SCP_list{i}).(remove_dots(pv)) = [];
                    end
                end
            end
            
            for i = 1:numel(obj.params.nonBSA_list)
                obj.data_struct.scalars.(obj.params.nonBSA_list{i}) = struct();
                for j=1:numel(obj.data_struct.metadata.(obj.params.nonBSA_list{i}).PVs)
                    pv = obj.data_struct.metadata.(obj.params.nonBSA_list{i}).PVs{j};
                    obj.data_struct.scalars.(obj.params.nonBSA_list{i}).(remove_dots(pv)) = [];
                end
            end
                        
            if obj.params.include_nonBSA_arrays
                obj.data_struct.arrays = struct();
                for i = 1:numel(obj.params.nonBSA_Array_list)
                    obj.data_struct.arrays.(obj.params.nonBSA_Array_list{i}) = struct();
                    for j=1:numel(obj.data_struct.metadata.(obj.params.nonBSA_Array_list{i}).PVs)
                        pv = obj.data_struct.metadata.(obj.params.nonBSA_Array_list{i}).PVs{j};
                        obj.data_struct.arrays.(obj.params.nonBSA_Array_list{i}).(remove_dots(pv)) = [];
                    end
                end
            end
            
            obj.data_struct.images = struct();
            for i = 1:obj.params.num_CAM
                obj.data_struct.images.(obj.params.camNames{i}) = struct();
                obj.data_struct.images.(obj.params.camNames{i}).loc = {};
                obj.data_struct.images.(obj.params.camNames{i}).pid = [];
                obj.data_struct.images.(obj.params.camNames{i}).uid = [];
                obj.data_struct.images.(obj.params.camNames{i}).step = [];
            end
        end
        
        function dispMessage(obj,message)
            
            if obj.freerun
                disp(message)
            else
                obj.objhan.addMessage(message);
            end
        end
        
        function status = check_abort(obj)
            
            status = caget(obj.pvs.DAQ_Abort);
            if status
                obj.dispMessage('Abork!');
            end
        end
        
    end
end
