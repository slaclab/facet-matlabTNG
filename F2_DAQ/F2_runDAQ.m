classdef F2_runDAQ < handle
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
        event_info
        scan_info
        save_info
        step
        async_data
        bsa_list
        nonbsa_list
        scanFunctions
        eDefNum
        daq_status
    end
    properties(Hidden)
        listeners
    end
    properties(Constant)
        maxbeat=1e7 % max heartbeat count, wrap to zero
        maxImSize = 1440744
        pulseIDPV = 'PATT:SYS1:1:PULSEID'
    end
    
    methods
        
        function obj = F2_runDAQ(DAQ_params,apph)
            
            obj.params = DAQ_params;
            
            % Check if DAQ called by GUI
            if exist('apph','var')
                obj.objhan=apph;
                obj.freerun = false;
            end
                        
            % initialize object and add PVs to be monitored
            context = PV.Initialize(PVtype.EPICS_labca) ;
            obj.pvlist=[...
                PV(context,'name',"DAQ_Running",'pvname',"SIOC:SYS1:ML02:AO352",'mode',"rw",'monitor',true); % Is DAQ running?
                PV(context,'name',"DAQ_Abort",'pvname',"SIOC:SYS1:ML02:AO353",'mode',"rw",'monitor',true); % Abort request
                PV(context,'name',"DAQ_Instance",'pvname',"SIOC:SYS1:ML02:AO400",'mode',"rw",'monitor',true); % Number of times DAQ is run
                PV(context,'name',"MPS_Shutter",'pvname',"IOC:SYS1:MP01:MSHUTCTL",'mode',"rw",'monitor',true); % MPS Shutter
                PV(context,'name',"BSA_nRuns",'pvname',"SIOC:SYS1:ML02:AO500",'mode',"rw",'monitor',true); % BSA thing
                ] ;
            pset(obj.pvlist,'debug',0);
            obj.pvs = struct(obj.pvlist);
            
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
            
            % =========================================
            % Create Data Path on NAS drive 
            % =========================================
            obj.save_info = set_DAQ_filepath(obj);
            obj.data_struct.save_info = obj.save_info;
            
            
            % Create data object, fill in metadata
            obj.data_struct.params = obj.params;
            obj.data_struct.metadata = struct();
            for i = 1:obj.params.num_CAM
                obj.data_struct.metadata.(obj.params.camNames{i}) = get_cam_info(obj.params.camPVs{i});
                obj.data_struct.metadata.(obj.params.camNames{i}).sioc = obj.params.camSIOCs{i};
                obj.data_struct.metadata.(obj.params.camNames{i}).trigger = obj.params.camTrigs{i};
            end
            obj.event_info = getEventInfo(obj.params.EC);
            obj.data_struct.metadata.Event = obj.event_info;
            
            % Fill in BSA data
            obj.bsa_list = {obj.pulseIDPV};
            for i = 1:numel(obj.params.BSA_list)
                pvList = feval(obj.params.BSA_list{i});
                pvDesc = lcaGetSmart(strcat(pvList,'.DESC'));
                
                obj.data_struct.metadata.(obj.params.BSA_list{i}).PVs = pvList;
                obj.data_struct.metadata.(obj.params.BSA_list{i}).Desc = pvDesc;
                
                obj.bsa_list = [obj.bsa_list; pvList];
            end
            
            % Fill in non-BSA data
            obj.nonbsa_list = {obj.pulseIDPV};
            for i = 1:numel(obj.params.nonBSA_list)
                pvList = feval(obj.params.nonBSA_list{i});
                pvDesc = lcaGetSmart(strcat(pvList,'.DESC'));
                
                obj.data_struct.metadata.(obj.params.nonBSA_list{i}).PVs = pvList;
                obj.data_struct.metadata.(obj.params.nonBSA_list{i}).Desc = pvDesc;
                
                obj.nonbsa_list = [obj.nonbsa_list; pvList];
            end
            %obj.async_data = async_data(obj.nonbsa_list);
            
            % Fill in the rest of the data struct
            obj.setupDataStruct();
            
            
            % Fill in scan functions
            obj.scanFunctions = struct();
            for i = 1:numel(obj.params.scanFuncs)
                obj.scanFunctions.(obj.params.scanFuncs{i}) = feval(obj.params.scanFuncs{i});
            end
            
            
            % Get PVs for cam control
            obj.daq_pvs = camera_DAQ_PVs(obj.params.camPVs);
            
            % Test cameras before starting
            obj.checkCams();
            
            % Prep cams -> make sure they are in good state
            obj.prepCams();
            
            % Get backgrounds
            obj.data_struct.backgrounds = struct;
            obj.data_struct.backgrounds.getBG = obj.params.saveBG;
            if obj.params.saveBG
                obj.grab_BG();
            end
            
            %%%%%%%%%%%%%%%%%%%%
            %   Run the DAQ!  %%
            %%%%%%%%%%%%%%%%%%%%
            obj.daq_loop();
            
        end
        
        function daq_loop(obj)
            
            if obj.params.scanDim == 0
                obj.step = 1;
                obj.daq_step();
                
                obj.end_scan();
                
                return
            end
            
            old_steps = nan(1,obj.params.scanDim);
            for i = 1:obj.params.totalSteps
                obj.step = i;
                
                new_steps = obj.params.stepsAll(i,:);
                
                for j = 1:obj.params.scanDim
                    
                    if new_steps(j) == old_steps(j); continue; end
                    
                    obj.dispMessage(sprintf('Setting %s to %0.2f',obj.params.scanFuncs{j},obj.params.scanVals{j}(new_steps(j))));
                    obj.scanFunctions.(obj.params.scanFuncs{j}).set_value(obj.params.scanVals{j}(new_steps(j)));
                end
                obj.daq_step();
                old_steps = new_steps;
            end
            
            obj.end_scan();
        end
        
        function daq_step(obj)
            
            waitTime = obj.params.n_shot/obj.event_info.liveRate;
            
            obj.dispMessage(sprintf('Starting DAQ Step %d. Time estimate %0.1f seconds.',obj.step, waitTime));
            
            % reset nonBSA data
            %obj.async_data.flush();
            
            % disable camera triggers
            lcaPut(obj.params.camTrigs,0);
            
            % setup camera saving
            lcaPut(obj.daq_pvs.TIFF_FileNumber,0);
            lcaPut(obj.daq_pvs.TIFF_NumCapture,obj.params.n_shot);
            set_CAM_filepath(obj);
            
            % setup BSA data
            obj.reserve_eDef();
            
            % Turn on BSA
            eDefOn(obj.eDefNum);
            
            % Turn on cameras
            lcaPutNoWait(obj.daq_pvs.TIFF_Capture,1);
            lcaPutNoWait(obj.params.camTrigs,1);
            
            %obj.async_data.enable();
            
            tic;
            while toc < waitTime
                pause(0.1);
            end
            
            eDefOff(obj.eDefNum);
            %obj.async_data.disable();
            obj.dispMessage('Acquisition complete. Cameras saving data.');
            
            fnum_rbv = lcaGet(obj.daq_pvs.TIFF_FileNumber_RBV);
            save_not_done = fnum_rbv < obj.params.n_shot;
            tic;
            while any(save_not_done)
                fnum_rbv = lcaGet(obj.daq_pvs.TIFF_FileNumber_RBV);
                save_not_done = fnum_rbv < obj.params.n_shot;
                pause(0.1);
                if toc > 10 && any(fnum_rbv == 0)
                    obj.dispMessage('Camera did not save');
                    break;
                end
            end  
            obj.dispMessage('Data saving complete. Starting quality control.');
            
            obj.collectData();
            
        end
        
        function end_scan(obj)
            
            obj.dispMessage('Comparing pulse IDs.');
            obj.compareUIDs();
            
            obj.dispMessage('Saving data.');
            obj.save_data();
            
            obj.dispMessage('Writing to eLog.');
            obj.write2eLog();
            
            obj.dispMessage('Done!');
            caput(obj.pvs.DAQ_Running,0);
        end
        
        function collectData(obj)
            
            n_use = lcaGet(sprintf('PATT:SYS1:1:PULSEIDHST%d.NUSE',obj.eDefNum));
            pulse_IDs = lcaGet(sprintf('PATT:SYS1:1:PULSEIDHST%d',obj.eDefNum),n_use)';
            UIDs = obj.generateUIDs(pulse_IDs);
            steps = obj.step*ones(size(pulse_IDs));
            
            %obj.addData(obj.data_struct.pulseID.scalar_PID,pulse_IDs);
            %obj.addData(obj.data_struct.pulseID.scalar_UID,UIDs);
            %obj.addData(obj.data_struct.pulseID.steps,steps);
            
            obj.data_struct.pulseID.scalar_PID = [obj.data_struct.pulseID.scalar_PID; pulse_IDs];
            obj.data_struct.pulseID.scalar_UID = [obj.data_struct.pulseID.scalar_UID; UIDs];
            obj.data_struct.pulseID.scalar_steps = [obj.data_struct.pulseID.steps; steps];
            
            for i = 1:numel(obj.params.BSA_list)
                
                for j = 1:numel(obj.data_struct.metadata.(obj.params.BSA_list{i}).PVs)
                    pv = obj.data_struct.metadata.(obj.params.BSA_list{i}).PVs{j};
                    new_vals = lcaGet([pv 'HST' num2str(obj.eDefNum)],n_use);
                    %obj.addData(obj.data_struct.scalars.(obj.params.BSA_list{i}).(strrep(PV,':','_')),new_vals);
                    obj.data_struct.scalars.(obj.params.BSA_list{i}).(strrep(pv,':','_')) = ...
                        [obj.data_struct.scalars.(obj.params.BSA_list{i}).(strrep(pv,':','_')); new_vals'];
                end
            end
            obj.data_struct.scalars.steps = [obj.data_struct.scalars.steps; steps];
            
            eDefRelease(obj.eDefNum);
            
            obj.getCamData();
            
            %obj.checkCameraPID();
            
            obj.dispMessage('Quality control complete.');
        end
        
        function getCamData(obj)
            for i = 1:obj.params.num_CAM
                imgs = dir([obj.save_info.cam_paths{i} '/*.tif']);
                n_imgs = numel(imgs);
                obj.daq_status(i,1) = n_imgs;
                obj.daq_status(i,2) = obj.params.n_shot;
                if n_imgs < obj.params.n_shot
                    obj.dispMessage([obj.params.camNames{i} ' didn"t save all the shots']);
                end
                
                locs = strcat([obj.save_info.cam_paths{i} '/'],{imgs.name}');
                obj.data_struct.images.(obj.params.camNames{i}).loc = ...
                    [obj.data_struct.images.(obj.params.camNames{i}).loc; locs];
                
                pid_list = zeros(n_imgs,1);
                for j = 1:n_imgs
                    tiff_header = tiff_read_header(locs{j});
                    %pid_list(j) = bitand(tiff_header.private_65003, hex2dec('0001FFFF'));
                    pid_list(j) = tiff_header.private_65001;
                end
                UIDs = obj.generateUIDs(pid_list);
                steps = obj.step*ones(size(pid_list));
                obj.data_struct.images.(obj.params.camNames{i}).pid = ...
                    [obj.data_struct.images.(obj.params.camNames{i}).pid; pid_list];
                obj.data_struct.images.(obj.params.camNames{i}).uid = ...
                    [obj.data_struct.images.(obj.params.camNames{i}).uid; UIDs];
                obj.data_struct.images.(obj.params.camNames{i}).step = ...
                    [obj.data_struct.images.(obj.params.camNames{i}).step; steps];
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
                
            
            
                
        
%         function checkCameraPID(obj)
%             
%             COMMON_PID = obj.data_struct.pulseID.scalar_PID;
%             
%             obj.data_struct.images = struct();
%             
%             for i = 1:obj.params.num_CAM
%                 
%                 imgs = dir([obj.save_info.cam_paths{i} '/*.tif']);
%                 n_imgs = numel(imgs);
%                 obj.daq_status(i,1) = n_imgs;
%                 obj.daq_status(i,2) = obj.params.n_shot;
%                 if n_imgs < obj.params.n_shot
%                     obj.dispMessage([obj.params.camNames{i} ' didn"t save all the shots']);
%                 end
%                 
%                 obj.data_struct.images.(obj.params.camNames{i}).loc = strcat([obj.save_info.cam_paths{i} '/'],{imgs.name}');
%                 
%                 pid_list = zeros(n_imgs,1);
%                 for j = 1:n_imgs
%                     tiff_header = tiff_read_header(obj.data_struct.images.(obj.params.camNames{i}).loc{j});
%                     pid_list(j) = bitand(tiff_header.private_65003, hex2dec('0001FFFF'));
%                 end
%                 obj.data_struct.images.(obj.params.camNames{i}).pid = pid_list;
%                 
%                 [~,~,camera_index] = intersect(obj.data_struct.pulseID.scalar_PID,pid_list);
%                 obj.data_struct.images.(obj.params.camNames{i}).scalar_PID_index = camera_index;
%     
%                 COMMON_PID = intersect(COMMON_PID,pid_list);
% 
%                 
%             end
%             
%             [~,~,scalar_index] = intersect(COMMON_PID,obj.data_struct.pulseID.scalar_PID);
%             
%             obj.data_struct.pulseID.common_scalar_index = scalar_index;
%             
%             % second loop for common index
%             for i = 1:obj.params.num_CAM
%                 
%                 [~,~,camera_index] = intersect(COMMON_PID,obj.data_struct.images.(obj.params.camNames{i}).pid);
%                 
%                 obj.data_struct.images.(obj.params.camNames{i}).common_pid_index = camera_index;
%                 obj.data_struct.pulseID.([obj.params.camNames{i} '_index']) = camera_index;
%                 
%                 obj.daq_status(i,3) = numel(camera_index);
%                 
%             end
%             
%             obj.data_struct.pulseID.common_pulseIDs = COMMON_PID;
%             
%             
%         end
        
        function UIDs = generateUIDs(obj,pulseIDs)
            UIDs = 1e9*obj.Instance + 1e6*obj.step + pulseIDs;
        end
        
        function save_data(obj)
            data_struct = obj.data_struct;
            
            save_str = [obj.save_info.save_path '/' obj.params.experiment '_' num2str(obj.save_info.instance,'%05d')];

            save(save_str,'data_struct');
            
        end
        
        function write2eLog(obj)
            
            comment_str =sprintf([obj.params.comment{1} '\n']);
            camera_str = '';
            for i = 1:obj.params.num_CAM
                camera_str = [camera_str obj.params.camNames{i} ', '];
            end
            
            camera_str = sprintf([camera_str '\n']);
            
            DAQ_str  = sprintf(['FACET DAQ ' num2str(obj.Instance,'%05d') ' for ' obj.params.experiment '.\n']);
            
            Data_str = sprintf([num2str(obj.params.n_shot) ' shots per step and %d steps.\n'],obj.params.totalSteps);
            
            if obj.params.scanDim == 0
                Scan_str = sprintf(['Simple DAQ ' '\n']);
            else
                Scan_str = '';
                for i=1:obj.params.scanDim
                    scan_line = sprintf('Scan of %s from %0.2f to %0.2f in %d steps.\n',...
                        obj.params.scanFuncs{i},obj.params.startVals(i),obj.params.stopVals(i),obj.params.nSteps(i));
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
                info_str = [info_str mat_line];
            end
            info_str = sprintf([info_str '\n' '\n']);
            
            Comment  = [comment_str camera_str DAQ_str Data_str Scan_str Path_str info_str];
            
            FACET_DAQ2LOG(Comment,obj);
        end

            
                    
        
        function reserve_eDef(obj)
            
            nRuns = caget(obj.pvs.BSA_nRuns)+1;
            caput(obj.pvs.BSA_nRuns,nRuns);
            eDefString = sprintf('BUFFACQ %d',nRuns);
            obj.eDefNum = eDefReserve(eDefString);
            
            while obj.eDefNum > 11
                eDefRelease(obj.eDefNum);
                obj.eDefNum = eDefReserve(eDefString);
            end
            
            eDefParams (obj.eDefNum, 1, 2800, obj.event_info.incmSet, obj.event_info.incmReset, obj.event_info.excmSet, obj.event_info.excmReset, obj.event_info.beamcode);
            
        end
            
        
        function checkCams(obj)
            bad_cam = obj.objhan.camCheck.checkConnect();
            
            for i = 1:obj.params.num_CAM
                if bad_cam(i)
                    message = ['Camera ' obj.params.camNames{i} ' is disconnected.'];
                    reply = qstdlg(message,'Camera Down','Wait and retry','Abort DAQ');
                    switch reply
                        case 'Wait and retry'
                            obj.checkCams();
                        case 'Abort DAQ'
                            obj.abort()
                    end
                end
            end
        end
        
        function prepCams(obj)
            
            lcaPut(obj.daq_pvs.DataType,1);
            lcaPut(obj.daq_pvs.ROI_EnableCallbacks,1);
            lcaPut(obj.daq_pvs.TSS_SETEC,obj.params.EC);
            
            lcaPut(obj.daq_pvs.TIFF_EnableCallbacks,1);
            lcaPut(obj.daq_pvs.TIFF_FileWriteMode,1);
            lcaPut(obj.daq_pvs.TIFF_AutoIncrement,1);
            lcaPut(obj.daq_pvs.TIFF_AutoSave,1);
            lcaPut(obj.daq_pvs.TIFF_SetPort,2);
            
        end
        
        
        function grab_BG(obj)
            
            nBG = obj.params.nBG;
            obj.data_struct.backgrounds.nBG = nBG;
            BGs = zeros(obj.params.num_CAM,obj.maxImSize,nBG);
            
            shutter_state = caget(obj.pvs.MPS_Shutter);
            caput(obj.pvs.MPS_Shutter,0);
            pause(1);
            obj.dispMessage('Inserting shutter for backgrounds.');
            
            for i = 1:nBG
                BGs(:,:,i) = lcaGet(obj.daq_pvs.Image_ArrayData);
                pause(0.1);
            end
            
            if strcmp(shutter_state,'Yes')
                caput(obj.pvs.MPS_Shutter,1);
                obj.dispMessage('Extracting shutter.');
                pause(1);
            end
            
            
            for j = 1:obj.params.num_CAM
                %bgs = squeeze(BGs(j,:,:));
                size_x = obj.data_struct.metadata.(obj.params.camNames{j}).SizeX_RBV;
                size_y = obj.data_struct.metadata.(obj.params.camNames{j}).SizeY_RBV;
                bgs = squeeze(BGs(j,1:(size_x*size_y),:));
                if nBG == 1
                    bg_array = uint16(reshape(bgs,[size_x,size_y]));
                else
                    bg_array = uint16(reshape(bgs,[size_x,size_y,nBG]));
                end
                obj.data_struct.backgrounds.(obj.params.camNames{j}) = bg_array;
            end
            
        end
        
%         function addData(obj,field,new_data)
%             
%             if isempty(field)
%                 if iscell(new_data)
%                     field = 
        
        function setupDataStruct(obj)
            obj.data_struct.pulseID = struct();
            obj.data_struct.pulseID.scalar_PID = [];
            obj.data_struct.pulseID.scalar_UID = [];
            obj.data_struct.pulseID.steps = [];
            
            obj.data_struct.scalars = struct();
            obj.data_struct.scalars.steps = [];
            for i = 1:numel(obj.params.BSA_list)
                obj.data_struct.scalars.(obj.params.BSA_list{i}) = struct();
                for j=1:numel(obj.data_struct.metadata.(obj.params.BSA_list{i}).PVs)
                    pv = obj.data_struct.metadata.(obj.params.BSA_list{i}).PVs{j};
                    obj.data_struct.scalars.(obj.params.BSA_list{i}).(strrep(pv,':','_')) = [];
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
        
        function abort(obj)
            
            obj.dispMessage('Abork!');
            
        end
           
        
        
        
    end
end
