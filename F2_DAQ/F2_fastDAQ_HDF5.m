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
        nonbsa_list
        nonbsa_array_list
        scanFunctions
        %eDefNum
        daq_status
        camCheck
        BG_obj
        doStream = false
        blockBeam = false
        shotsArray
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
            obj.event = F2_EventClass();
            obj.event.select_rate_HDF5(obj.params.rate);
            obj.event_info = obj.event.evt_struct();
            obj.data_struct.metadata.Event = obj.event_info;
            
            % Set beam blocking if requested
            obj.blockBeam = obj.params.blockBeam;
            
            % Generate metadata for cameras and PVs
            obj.createMetadata();
                        
            % Fill in the rest of the data struct to prepare for data
            obj.setupDataStruct();
            
            % Fill in scan functions
            obj.scanFunctions = struct();
            for i = 1:numel(obj.params.scanFuncs)
                if strcmp(obj.params.scanFuncs{i},"Use_PV")
                    obj.scanFunctions.Use_PV = scanFunc_Use_PV(obj,...
                        obj.params.scanPVs{i},obj.params.RBV_PVs{i},obj.params.Waits{i},obj.params.Tolerance{i});
                else
                    obj.scanFunctions.(obj.params.scanFuncs{i}) = feval(['scanFunc_' obj.params.scanFuncs{i}],obj);
                end
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Camera prep and check %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Get PVs for cam control
            obj.daq_pvs = camera_DAQ_PVs(obj.params.camPVs);
            
            % Set DAQ_InUse PV for cameras
            lcaPutSmart(obj.daq_pvs.DAQ_InUse,1);
            
            % Test cameras before starting
            obj.checkCams();
            status = obj.check_abort();
            if status; obj.end_scan(status); return; end
            
            
            % Prep cams -> make sure they are in good state
            obj.prepCams();
            
            % Get backgrounds
            obj.BG_obj = F2_getBG(obj);
            obj.data_struct.backgrounds = struct;
            obj.data_struct.backgrounds.getBG = obj.params.saveBG;
            obj.data_struct.backgrounds.laserBG = obj.params.laserBG;
            if obj.params.saveBG || obj.params.laserBG
               obj.data_struct.backgrounds = obj.BG_obj.getBackground();
            end
            
            % Stop trigger
            % This sets EC214 and BUFFACQ rate to zero
            obj.event.stop_event_HDF5();
            pause(2);
            
            %%%%%%%%%%%%%%%%%%%%
            %   Run the DAQ!  %%
            %%%%%%%%%%%%%%%%%%%%
            status = obj.daq_loop();
            obj.end_scan(status);
            
        end
        
        function status = daq_loop(obj)
            % The meat of the matter
            
            % This sets EC214 and BUFFACQ rate to zero
            % obj.event.stop_event_HDF5();
            
            % Set Event PV number of shots
            lcaPut(obj.event.DAQ_EVNT_NUM,obj.params.n_shot);
            
            % This is a "simple" DAQ
            if obj.params.scanDim == 0
                lcaPut(obj.daq_pvs.HDF5_NumExtraDims,0);
                lcaPut(obj.daq_pvs.HDF5_FileNumber,0);
                
                obj.step = 1;
                try
                    % Capture here
                    % setup camera saving
                    lcaPut(obj.daq_pvs.HDF5_FileNumber,0); % this is redundant
                    set_CAM_filepath_HDF5(obj);
                    lcaPutNoWait(obj.daq_pvs.HDF5_Capture,1);
                    
                    status = obj.daq_step();
                    
                    % we are done BUFFACQ eDef
                    obj.event.release_eDef();
                    return;
                catch
                    obj.dispMessage(sprintf('DAQ failed on step %d',obj.step));
                    status = 1;
                    
                    % we are done BUFFACQ eDef
                    obj.event.release_eDef();
                    return;
                end 
            end
            
            % This is a scan
            old_steps = nan(1,obj.params.scanDim);
            lcaPut(obj.daq_pvs.HDF5_NumExtraDims,obj.params.scanDim);
            
            % Set ExtraDimSizeN to be number of shots per step
            lcaPut(obj.daq_pvs.HDF5_ExtraDimSizeN,obj.params.n_shot);
            
            % Set ExtraDimSizeX and Y to be num Steps
            lcaPut(obj.daq_pvs.HDF5_ExtraDimSizeX,obj.params.nSteps(1));
            
            if obj.params.scanDim > 1
                lcaPut(obj.daq_pvs.HDF5_ExtraDimSizeY,obj.params.nSteps(2));
            end
            
            % Capture here
            % setup camera saving
            lcaPut(obj.daq_pvs.HDF5_FileNumber,0);
            set_CAM_filepath_HDF5(obj);
            lcaPutNoWait(obj.daq_pvs.HDF5_Capture,1);
            
            for i = 1:obj.params.totalSteps
                obj.step = i;
                
                new_steps = obj.params.stepsAll(i,:);
                
                for j = 1:obj.params.scanDim
                    
                    if new_steps(j) == old_steps(j); continue; end
                    
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
                    
                    % we are done BUFFACQ eDef
                    obj.event.release_eDef();
                    status = 1;
                end
                
                if status; return; end
                
                old_steps = new_steps;
            end
            
            % Set back EVNT PV
            lcaPut(obj.event.DAQ_EVNT_NUM,0);
            
            % we are done BUFFACQ eDef
            obj.event.release_eDef();
            
        end
        
        % status = 0 -> ok. status = 1 -> DAQ failed or aborted
        function status = daq_step(obj)
            
            waitTime = obj.params.n_shot/obj.event_info.liveRate;
            
            obj.dispMessage(sprintf('Starting DAQ Step %d. Time estimate %0.1f seconds.',obj.step, waitTime));

%             tic % comment this
            
            % Start BUFFACQ buffer and camera triggers
            obj.event.start_event_HDF5();
%             disp(toc) % and this
            
            timer = tic;
            
            % if blockBeam
            if obj.blockBeam
            	obj.BG_obj.enable_Pockels_cell()
            end
            
            % Get data and count shots
            while toc(timer) < waitTime
                
                pause(1/obj.event_info.liveRate); % derive this from beam rate
                obj.async_data.addDataFR();
                
                % Add a "check failure" --> already checks shots below ..?

                % Add a "check abort" here
                status = obj.check_abort;
                if status; return; end
            end

            % Buffers should be full

            % Stop triggers
            obj.event.stop_event_HDF5();
            
            obj.dispMessage('Acquisition complete. Cameras saving data.');
            
            obj.dispMessage('Data saving complete. Starting quality control.');
            
            % Check number of shots per step and add to shotsArray
            status = obj.checkShots();
            if status; return; end
            
            % Get the data
            status = obj.collectData();
            
        end
        
        function end_scan(obj,status)
            
            if status
                obj.dispMessage('Ending failed/aborted scan.');
                obj.event.stop_eDef();
                obj.event.release_eDef();
                % this indicates data taking has ended
                caput(obj.pvs.DAQ_DataOn,0);
            end
            
            obj.camCheck.restore_trig_event(obj.params.EC);
            
            % Re-enable triggers
            lcaPut(obj.event.DAQ_EVNT_NUM,0);
            lcaPutSmart(obj.event.DAQ_EVNT_ON,1);

                        
            if obj.params.scanDim > 0
                
                obj.dispMessage('Restoring scan functions to initial value.');
                for j = 1:obj.params.scanDim
                    obj.scanFunctions.(obj.params.scanFuncs{j}).restoreInitValue();
                end
                
            end
            
            obj.dispMessage('Collecting camera data.');
            status = obj.getCamData();
            
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
        
        function status = checkShots(obj)
            % Checks that num of shots captured is going up at around the same
            % rate for all cameras
            status = 0;
            
            shots = lcaGet(obj.daq_pvs.HDF5_NumCaptured_RBV);  % returns a vector
            
            if shots == 0 % ?
                status = 1;
                return
            end
            
            % Vector of expected shots each camera should have captured at each step
            % e.g. for 3 cameras, 20 shots per step, and after the first step:
            % check_vec = [20      -> shots corresponding to camera 1
            %              20      -> shots corresponding to camera 2
            %              20]     -> shots corresponding to camera 3

            check_vec = obj.step*obj.params.n_shot*ones(obj.params.num_CAM,1);
            
            good = (check_vec == shots); % logical vector
            final_shots = zeros(size(shots));
            final_shots(good) = shots(good);
            
            any_bad = sum(~good);
            
            % the problem seems to be that after collecting all N shots,
            % some cameras immediately drop back down to zero. so maybe
            % have to deal with this on a camera by camera basis
            
            tic;
            
            while any_bad
                new_shots = lcaGet(obj.daq_pvs.HDF5_NumCaptured_RBV);
                new_good = (check_vec == new_shots);
                final_shots(new_good) = new_shots(new_good);
                
                % add new good shots to list
                good = good | new_good;
                any_bad = sum(~good);
                
%                 disp(final_shots);
%                 disp(good);
                pause(1);
                
                if toc > 3
                    obj.dispMessage('Cameras have not saved all shots after waiting 3 seconds.');
                    %status = 1;
                    break;
                    
                    % Alternatively, try to fix it?
                    % not 100% sure how to do this yet
                end
            end
            if any_bad
                final_shots(~good) = new_shots(~good);
            end
            
            % Create shotsArray here
            obj.shotsArray = [obj.shotsArray,final_shots];
        end
        
        function status = collectData(obj)
            
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
            
            disp('beep');
            
            obj.getBSAdata(n_use);
            
            disp('bop');
                        
            try 
                obj.getNonBSAdata(slac_time);
                status = 0;
            catch
                obj.dispMessage('Non-BSA data failed.');
                status = 1;
            end
            
            disp('borp');
                        
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
            status = 0;
            if obj.params.totalSteps == 0
                nSteps = 1;
            else
                nSteps =  obj.params.totalSteps;
            end
            
            % Check for no shots saved
            if isempty(obj.shotsArray)
                return
            end
            
            camShotsArray = [obj.shotsArray(:,1),diff(obj.shotsArray,1,2)];
            % Loop over steps and cameras to collect list of images in save
            % directory.
            for i = 1:obj.params.num_CAM
                
                % Try to read HDF5 file
                tryCount = 0;
                success = false; % success means HDF5 file was created and is readable
                
                while ~success && tryCount < 120
                    try
                        dirInfo = dir([obj.save_info.cam_paths{i} '/*.h5']);
%                         disp(dirInfo.name)
                        h5fn = [obj.save_info.cam_paths{i} '/' dirInfo.name];
                        info = h5info(h5fn,'/entry/data/data');
                        n_imgs = prod(info.Dataspace.Size(3:end));
                        obj.daq_status(i,1) = n_imgs;
                        
                        success = true;
                    catch
                        if tryCount == 0
                            obj.dispMessage('Could not read HDF5 file. Trying again.');
                        end
                        success = false;
                    end
                    tryCount = tryCount + 1;
                    pause(1);
                end
                
                if tryCount == 120
                    obj.dispMessage(['Could not read HDF5 file: ' h5fn '. Skipping camera.']);
                    status = 1;
                    continue;
                end
                
                obj.daq_status(i,2) = obj.params.n_shot;
                
                % Need to rewrite the code below:
                % 1. "k" doesn't exist anymore
                % 2. "n_imgs" is now the TOTAL number of images saved
                % 3. Can we check if all the shots weren't saved on a
                % certain step?
%                 if n_imgs < obj.params.n_shot
%                     obj.dispMessage([obj.params.camNames{i} ' didn"t save all the shots on step ' num2str(k) '.']);
%                 end
%                 if n_imgs == 0
%                     obj.dispMessage([obj.params.camNames{i} ' saved zero shots. Skipping step ' num2str(k) '.']);
%                     status = 1;
%                     continue;
%                 end
                
                disp('bleep');
                
                % Add the paths of images found to 'loc'
                obj.data_struct.images.(obj.params.camNames{i}).loc = {h5fn};
                
                disp('blop');
                
                status = obj.check_abort();
                if status; return; end
                PIDs = h5read(h5fn,'/entry/instrument/NDAttributes/NDArrayUniqueId');
                PIDs = double(PIDs);
                
                disp('blorp');
                
                % Add UIDs and PIDs
                obj.data_struct.images.(obj.params.camNames{i}).pid = PIDs;
%                 shotsArray = repelem((1:nSteps)',obj.params.n_shot);
                
%                 shotsArray = [obj.shotsArray(i,1),diff(obj.shotsArray,1,2)];
                stepsArray = repelem((1:nSteps),camShotsArray(i,:))';
                
                % if size(steps_array) < size(PIDs), this means shots were
                % added at the end of scan to make up for lost shots
                if size(stepsArray,1) < size(PIDs,1)
                    extra = size(PIDs,1) - size(stepsArray,1);
                    stepsArray = [stepsArray; -1*ones(extra,1)];
                end
                    
                
                disp(obj.params.camNames{i})
                %disp(size(PIDs))
                %disp(size(stepsArray))
                
                UIDs = obj.generateUIDs(PIDs,stepsArray);
                obj.data_struct.images.(obj.params.camNames{i}).uid = UIDs;
                obj.data_struct.images.(obj.params.camNames{i}).step = stepsArray;
            end
            
        end
        
        function compareUIDs(obj)
            COMMON_UID = obj.data_struct.pulseID.scalar_UID;
            
            for i = 1:obj.params.num_CAM
                
                [~,~,camera_index] = intersect(obj.data_struct.pulseID.scalar_UID,obj.data_struct.images.(obj.params.camNames{i}).uid);
                obj.data_struct.images.(obj.params.camNames{i}).scalar_index = camera_index;
    
                COMMON_UID = intersect(COMMON_UID,obj.data_struct.images.(obj.params.camNames{i}).uid);
                
            end
            
            [~,~,scalar_index] = intersect(COMMON_UID,obj.data_struct.pulseID.scalar_UID);
            obj.data_struct.pulseID.common_scalar_index = scalar_index;
            obj.data_struct.scalars.common_index = scalar_index;
            
            % second loop for common index
            for i = 1:obj.params.num_CAM
                [~,~,camera_index] = intersect(COMMON_UID,obj.data_struct.images.(obj.params.camNames{i}).uid);
                
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
            warning('off',wid);
            
            data_struct = obj.data_struct;
            
            save_str = [obj.save_info.save_path '/' obj.params.experiment '_' num2str(obj.save_info.instance,'%05d')];

            save(save_str,'data_struct');
            
%             obj.dispMessage('Converting data to HDF5');
%             try
%                 matlab2hdf5(data_struct,save_str);
%             catch
%                 obj.dispMessage('Failed to convert to HDF5');
%             end
            
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
            
            info_str = sprintf(['| NAME | SAVE | REQ | MATCH ' '\n']);
            for i = 1:obj.params.num_CAM
                if obj.params.totalSteps == 0
                    tot_req = obj.daq_status(i,2);
                else
                    tot_req = obj.params.totalSteps*obj.daq_status(i,2);
                end
                mat_line   = sprintf(['| ' obj.params.camNames{i} ' | ' num2str(obj.daq_status(i,1)) ' | '...
                    num2str(tot_req) ' | ' num2str(obj.daq_status(i,3)) ' ' '\n']);
                % add a disp message here?
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
            
            lcaPutSmart(obj.daq_pvs.DataType,1);
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
%             lcaPutSmart(obj.daq_pvs.HDF5_SetPort,2);
            
            lcaPutSmart(obj.daq_pvs.HDF5_NumCapture,obj.params.n_shot);
            
            obj.camCheck.set_trig_event(obj.params.EC);
            
        end
        
        function createMetadata(obj)
            
            % loop over cameras and add metadata
            for i = 1:obj.params.num_CAM
                obj.data_struct.metadata.(obj.params.camNames{i}) = get_cam_info(obj.params.camPVs{i});
                obj.data_struct.metadata.(obj.params.camNames{i}).sioc = obj.params.camSIOCs{i};
                obj.data_struct.metadata.(obj.params.camNames{i}).trigger = obj.params.camTrigs{i};
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
            
            % Fill in non-BSA arrays, not supported yet
            if obj.params.include_nonBSA_arrays
                for i = 1:numel(obj.params.nonBSA_Array_list)
                    pvList = feval(obj.params.nonBSA_Array_list{i});
                    pvList = obj.async_data.addListArray(pvList);
                    pvDesc = lcaGetSmart(strcat(pvList,'.DESC'));
                    
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
