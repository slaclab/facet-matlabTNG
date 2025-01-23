classdef F2_fastDAQ < handle
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
        
        function obj = F2_fastDAQ(DAQ_params,apph)
            
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
            obj.event.select_rate(obj.params.rate);
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
            
            %%%%%%%%%%%%%%%%%%%%
            %   Run the DAQ!  %%
            %%%%%%%%%%%%%%%%%%%%
            status = obj.daq_loop();
            obj.end_scan(status);
            
        end
        
        function status = daq_loop(obj)
            % The meat of the matter
            
            % This sets EC214 and BUFFACQ rate to zero
            obj.event.stop_event();
            
            % This is a "simple" DAQ
            if obj.params.scanDim == 0
                obj.step = 1;
                try
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
            for i = 1:obj.params.totalSteps
                obj.step = i;
                
                new_steps = obj.params.stepsAll(i,:);
                
                for j = 1:obj.params.scanDim
                    
                    %if new_steps(j) == old_steps(j); continue; end
                    
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
            
            % we are done BUFFACQ eDef
            obj.event.release_eDef();
            
        end
        
        % status = 0 -> ok. status = 1 -> DAQ failed or aborted
        function status = daq_step(obj)
            
            % waitTime isnt used but it is nice to see in display
            waitTime = obj.params.n_shot/obj.event_info.liveRate;
            pauseTime = 0.099;
            if strcmp(obj.event.RATE,'ONE_HERTZ')
                pauseTime = 0.999;
            elseif strcmp(obj.event.RATE,'FIVE_HERTZ')
                pauseTime = 0.199;
            elseif strcmp(obj.event.RATE,'TEN_HERTZ')
                pauseTime = 0.099;
            elseif strcmp(obj.event.RATE,'HALF_HERTZ')
                pauseTime = 1.999;
            else
                pauseTime = 0.099;
            end
            
            obj.dispMessage(sprintf('Starting DAQ Step %d. Time estimate %0.1f seconds.',obj.step, waitTime));
            
            % setup camera saving
            lcaPut(obj.daq_pvs.TIFF_FileNumber,0);
            set_CAM_filepath(obj);

            % Sometimes you can't set the TIFF_Capute PV so you try twice
            lcaPutNoWait(obj.daq_pvs.TIFF_Capture,1);
            stat = lcaGet(obj.daq_pvs.TIFF_Capture,0,'DBF_ENUM');
            if sum(stat) ~= obj.params.num_CAM
                obj.dispMessage('Attempt to set cameras to capture failed. Trying again.');
                lcaPutNoWait(obj.daq_pvs.TIFF_Capture,1);
                stat = lcaGet(obj.daq_pvs.TIFF_Capture,0,'DBF_ENUM');
                if sum(stat) ~= obj.params.num_CAM
                    obj.dispMessage('Attempt to set cameras to capture failed again. Aborting.');
                    status = 1;
                    return;
                end
            end
            
            % For counting shots while we wait for data
            count = 0;
            %old_pid = lcaGet(obj.data_struct.metadata.Event.PID_PV);
            old_pid = lcaGet('PATT:SYS1:1:PULSEID');
            
            % Start BUFFACQ buffer
            obj.event.start_eDef();
            
            % Start EC214 for cameras
            obj.event.start_event();
            
            % if blockBeam
            if obj.blockBeam
            	obj.BG_obj.enable_Pockels_cell()
            end
            
            % Get data and count shots
            while count < (obj.params.n_shot+1)
                %pause(0.01);
                %pause(0.099);
                pause(pauseTime);
                
                % Update beamrate PID
                try
                    %new_pid = lcaGet(obj.data_struct.metadata.Event.PID_PV);
                    new_pid = lcaGet('PATT:SYS1:1:PULSEID');
                catch
                    continue;
                end
                
                % if new_pid ~= old_pid, we have a new shot. Add non BSA
                % frame.
                if new_pid ~= old_pid
                    old_pid = new_pid;
                    count = count + 1;
                    
                    obj.async_data.addDataFR();
                    obj.async_data.addArrayData();
                end  
            end
            % Buffers should be full

            % Stop buffer data
            obj.event.stop_eDef();
            
%             % if using capture, buffer should be full
%             if ~obj.doStream
%                 pause(0.1);
%                 obj.event.stop_event();
%             end
            
            obj.dispMessage('Acquisition complete. Cameras saving data.');
            
            % Allow 0.1 s (1 frame) for data saving to complete
            pause(0.1);
            fnum_rbv = lcaGet(obj.daq_pvs.TIFF_FileNumber_RBV);
            save_not_done = fnum_rbv < obj.params.n_shot;
            
            max_save_counts = 0.4*obj.params.n_shot; % 0.2 is an empiricle number
            max_save_time = max_save_counts;
            
            if any(save_not_done)
                obj.dispMessage(sprintf('Waiting for cameras to save. Max wait is %0.1f seconds.',max_save_time));
            end

            % If data saving is not complete, run a loop to check for
            % completion
            count = 0;
            while any(save_not_done)
                status = obj.check_abort();
                if status; return; end
                
                % Check if saves are inceasing with time
                pause(1);
                new_fnum_rbv = lcaGet(obj.daq_pvs.TIFF_FileNumber_RBV);
                save_not_done = new_fnum_rbv < obj.params.n_shot;
                change = any(fnum_rbv ~= new_fnum_rbv);
                
                % If we are streaming data and the saves do not increase,
                % we should abort
                if obj.doStream
                    if any(save_not_done)
                        if ~change
                            obj.dispMessage('Cameras did not save. Will abort.');
                            obj.event.stop_event();
                            status = 1;
                            return;
                        end
                    end
                    
                else
                    if any(save_not_done)
                        count = count+1;
                        

                        % if we have waited a very long time and no saves, we abort.
                        % 2 is an empiricle number
                        if count > max_save_counts
                            obj.dispMessage('Cameras did not save. Will abort.');
                                obj.event.stop_event();
                                status = 1;
                                return;
                        end
                    end
                end
                fnum_rbv = new_fnum_rbv;
            end
            
            % This means that data saving is complete
            obj.event.stop_event();
            obj.dispMessage('Data saving complete. Starting quality control.');
            
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
            
            obj.dispMessage(sprintf('Done with DAQ instance %d!!!!',obj.Instance));
            caput(obj.pvs.DAQ_Running,0);
            lcaPutSmart(obj.daq_pvs.DAQ_InUse,0);
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
                        
            obj.getNonBSAdata(slac_time);
            
            disp('borp');
            
            status = 0;
                        
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
            obj.async_data.interpolateArrays(slac_time);
            
            for i = 1:numel(obj.params.nonBSA_list)
                for j = 1:numel(obj.data_struct.metadata.(obj.params.nonBSA_list{i}).PVs)
                    pv = obj.data_struct.metadata.(obj.params.nonBSA_list{i}).PVs{j};
                    obj.data_struct.scalars.(obj.params.nonBSA_list{i}).(remove_dots(pv)) = ...
                        [obj.data_struct.scalars.(obj.params.nonBSA_list{i}).(remove_dots(pv)); obj.async_data.interpData.(remove_dots(pv))];
                end
            end
            
            for i = 1:numel(obj.params.nonBSA_Array_list)
                for j = 1:numel(obj.data_struct.metadata.(obj.params.nonBSA_Array_list{i}).PVs)
                    pv = obj.data_struct.metadata.(obj.params.nonBSA_Array_list{i}).PVs{j};
                    obj.data_struct.arrays.(obj.params.nonBSA_Array_list{i}).(remove_dots(pv)) = ...
                        [obj.data_struct.arrays.(obj.params.nonBSA_Array_list{i}).(remove_dots(pv)); obj.async_data.interpData.(remove_dots(pv))];
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
            
            % Loop over steps and cameras to collect list of images in save
            % directory.
            for k = 1:nSteps
                for i = 1:obj.params.num_CAM
                    imgs = dir([obj.save_info.cam_paths{i} '/*_data_step' num2str(k,'%02d') '*.tif']);
                    n_imgs = numel(imgs);
                    obj.daq_status(i,1) = n_imgs;
                    obj.daq_status(i,2) = obj.params.n_shot;
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
                    locs = strcat([obj.save_info.cam_paths{i} '/'],{imgs.name}');
                    obj.data_struct.images.(obj.params.camNames{i}).loc = ...
                        [obj.data_struct.images.(obj.params.camNames{i}).loc; locs];
                    
                    disp('blop');
                    
                    % Notes to my future self. . .
                    % In this step, we extract the PIDs from the TIFF file
                    % header by knowing exactly where to look in the file.
                    % This is a hack suggested by H. Ekerfelt and is a
                    % major speed improvement over the previous code called
                    % tiff_read_header(). The image saved to disk comes
                    % from the ROI plugin. We used to use ROI_SizeX/Y_RBV
                    % to get the image size, but this failed to account for
                    % binning. ROI_ArraySize0/1_RBV accounts for binning.
                    im_size = obj.data_struct.metadata.(obj.params.camNames{i}).ROI_ArraySize0_RBV*...
                        obj.data_struct.metadata.(obj.params.camNames{i}).ROI_ArraySize1_RBV;
                    file_pos = 2*im_size+obj.offset;
                    
                    pid_list = zeros(n_imgs,1);
                    for j = 1:n_imgs
                        status = obj.check_abort();
                        if status; return; end
                        pid_list(j) = tiff_get_PID(locs{j},file_pos);
                    end
                    
                    disp('blorp');
                    
                    % Add UIDs and PIds
                    UIDs = obj.generateUIDs(pid_list,k);
                    steps = k*ones(size(pid_list));
                    obj.data_struct.images.(obj.params.camNames{i}).pid = ...
                        [obj.data_struct.images.(obj.params.camNames{i}).pid; pid_list];
                    obj.data_struct.images.(obj.params.camNames{i}).uid = ...
                        [obj.data_struct.images.(obj.params.camNames{i}).uid; UIDs];
                    obj.data_struct.images.(obj.params.camNames{i}).step = ...
                        [obj.data_struct.images.(obj.params.camNames{i}).step; steps];
                end
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
            
            comment_str = sprintf([obj.params.comment{1} '\n']);
            camera_str = '';
            for i = 1:obj.params.num_CAM
                camera_str = [camera_str obj.params.camNames{i} ', '];
                obj.daq_status(i,1) = numel(dir([obj.save_info.cam_paths{i} '/*.tif']));
            end
            
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
            
            lcaPut(obj.daq_pvs.TIFF_EnableCallbacks,1);
            if obj.doStream
                lcaPut(obj.daq_pvs.TIFF_FileWriteMode,2); % 2 =streaming (fast)
            else
                lcaPut(obj.daq_pvs.TIFF_FileWriteMode,1); % 1=capture (slow)
            end
            lcaPutSmart(obj.daq_pvs.TIFF_AutoIncrement,1);
            lcaPutSmart(obj.daq_pvs.TIFF_AutoSave,1);
            lcaPutSmart(obj.daq_pvs.TIFF_SetPort,2);
            
            lcaPutSmart(obj.daq_pvs.TIFF_NumCapture,obj.params.n_shot);
            
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
            
%             obj.async_data.initGet();
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
                obj.data_struct.arrays.steps = [];
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
