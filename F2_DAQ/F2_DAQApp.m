classdef F2_DAQApp < handle
    % F2_DAQApp is responsible for taking the parameters from the GUI
    % interface and translating them into a structured input to the DAQ
    events
        PVUpdated 
    end
    properties
        pvlist PV
        pvs
        guihan
        message
        nMsg
        DAQ_params
        DAQ_obj
        camCheck
    end
    properties(Hidden)
        listeners
    end
    properties(Constant)
        maxbeat=1e7 % max heartbeat count, wrap to zero
        rates = {'BEAM','TEN_HERTZ','FIVE_HERTZ','ONE_HERTZ','HALF_HERTZ','ASSET'}
        rate_names = {'Beam','10 Hz','5 Hz','1 Hz','0.5 Hz','0.2 Hz'}
        ecs = [201,203,213,214,222,223,224,225,226,131,53,54,55,56]
        n_ecs = 14
        n_edefs = 11
        scp_max = 2000
    end
    
    methods
        
        function obj = F2_DAQApp(apph)
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% This block is Glen's boiler plate %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Associate class with GUI
            obj.guihan=apph;
            
            % Dear Diary, My name is FACET DAQ and I am 0x00 old today
            diary('/u1/facet/physics/log/matlab/F2_DAQ.log');
            
            % initialize object and add PVs to be monitored
            context = PV.Initialize(PVtype.EPICS) ;
            obj.pvlist=[...
                PV(context,'name',"GUI_Instance",'pvname',"SIOC:SYS1:ML02:AO351",'mode',"rw",'monitor',true); % Number of times GUI is run
                PV(context,'name',"DAQ_Instance",'pvname',"SIOC:SYS1:ML02:AO400",'mode',"rw",'monitor',true); % Number of times DAQ is run
                PV(context,'name',"Reset",'pvname',"SIOC:SYS1:ML02:AO352",'mode',"rw",'monitor',true); % DAQ Running
                PV(context,'name',"EDEFAVAIL",'pvname',"IOC:SYS1:EV01:EDEFAVAIL",'mode',"rw",'monitor',true); % DAQ Running
                PV(context,'name',"Abort",'pvname',"SIOC:SYS1:ML02:AO353",'mode',"rw",'monitor',true); % DAQ Abort
                PV(context,'name',"DAQ_DataOn",'pvname',"SIOC:SYS1:ML02:AO354",'mode',"rw",'monitor',true); % DAQ Data On
                ] ;
            pset(obj.pvlist,'debug',0) ;
            obj.pvs = struct(obj.pvlist);
            
            inst = caget(obj.pvs.GUI_Instance);
            caput(obj.pvs.GUI_Instance,inst+1);
            obj.nMsg = 0;
            obj.addMessage(sprintf('Started GUI instance %d.',inst+1));
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% This block is helper functions for finding %%%
            %%% cameras, PV lists, and scan functions      %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Initialize camera list, CamCheck has info on cameras and IOCs
            obj.camCheck = F2_CamCheck(true,obj);
%             obj.DAQ_params.camCheck = obj.camCheck;
            obj.initCameras();
            
            % Load BSA Lists
            obj.loadBSALists();
            
            % Load non-BSA Lists
            obj.loadnonBSALists();
            
            % Load non-BSA Array Lists
            obj.loadnonBSA_ArrayLists();
            
            % Load scan functions
            obj.loadScans();
            
        end
        
        function resetDAQ(obj)
            
            % This indicates DAQ is not in use
            caput(obj.pvs.Reset,0);
            
            % Reset DAQ_InUse PVs for cameras
            if ~isempty(obj.DAQ_obj)
                if ~isempty(obj.DAQ_obj.daq_pvs)
                    daq_InUse_PV = obj.DAQ_obj.daq_pvs.DAQ_InUse;
                    lcaPutSmart(daq_InUse_PV,0);
                end
            end
            
            % This indicates data taking has ended
            caput(obj.pvs.DAQ_DataOn,0);
            obj.addMessage('DAQ reset.');
            
        end
        
        function clearEDEFs(obj)
                        
            % Check number of available EDEFs
            avail = caget(obj.pvs.EDEFAVAIL);
            obj.addMessage([num2str(avail) ' EDEFs available before clearing.']);
            
            % Loop over EDEFs and clear them if they are off
            for i = 1:obj.n_edefs
                stat = lcaGet(['EDEF:SYS1:' num2str(i) ':CTRL'],0,'DBF_ENUM');
                if stat
                    obj.addMessage(['EDEF ' num2str(i) ' is active. Skipping.']);
                    continue;
                end
                lcaPut(['EDEF:SYS1:' num2str(i) ':FREE.PROC'],1);
            end
            
            % Check number of available EDEFs
            avail = caget(obj.pvs.EDEFAVAIL);
            obj.addMessage([num2str(avail) ' EDEFs available after clearing.']);
            
        end
        
        function abort(obj)
            
            caput(obj.pvs.Abort,1);
            obj.addMessage('Abort command sent.');
            
        end
        
        function params = generateDAQParams(obj)            
            params.include_nonBSA_arrays = true;
            params.experiment = obj.guihan.ExperimentDropDown.Value;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Beam rate and associated event code %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            rv = obj.guihan.RateDropDown.Value;
            
            params.rate = obj.rates{strcmp(rv,obj.rate_names)};
            params.rate_name = rv;
            params.doStream = obj.guihan.StreamDataCheckBox.Value;
            %if obj.guihan.FastDAQCheckBox.Value
            %    params.EC = 214;
            %else
            %    params.EC = 222;
            %end
            params.EC = 214;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% parameters and flags %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            params.comment    = obj.guihan.CommentTextArea.Value;
            params.n_shot     = obj.guihan.ShotsperstepEditField.Value;
            params.print2elog = obj.guihan.PrinttoeLogCheckBox.Value;
            params.saveBG     = obj.guihan.SavebackgroundCheckBox.Value;
            params.laserBG    = obj.guihan.SaveLaserBGCheckBox.Value;
            params.nBG        = obj.guihan.BackgroundshotsEditField.Value;
            params.blockBeam  = obj.guihan.Blockbeam.Value;
            params.allowDuplicateSteps = obj.guihan.Allowduplicatesteps.Value;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Get the cameras, metadata, %%%
            %%% settings and triggers      %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            [~,ia,~] = intersect(obj.camCheck.camNames,obj.guihan.ListBox.Items);
            list_bool = false(size(obj.camCheck.camNames));
            list_bool(ia) = true;
            obj.camCheck.downSelect(list_bool);
            
            params.camNames = obj.camCheck.DAQ_Cams.camNames;
            params.camPVs   = obj.camCheck.DAQ_Cams.camPVs;
            params.camSIOCs = obj.camCheck.DAQ_Cams.siocs;
            params.camTrigs = obj.camCheck.DAQ_Cams.camTrigs;
            params.num_CAM  = numel(params.camNames);
            obj.camCheck.checkTrigStat();
            
            % Enable "Fix Cameras" button in GUI
            obj.guihan.FixCamerasButton.Enable = 'on';
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% BSA and non-BSA PV lists %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Scalar data lists
            isSCP = contains(obj.guihan.ListBoxBSA.Items,"SCP");
            params.SCP_list = obj.guihan.ListBoxBSA.Items(isSCP);
            params.BSA_list = obj.guihan.ListBoxBSA.Items(~isSCP);

            if ~isempty(params.SCP_list)
                params.saveSCP = true;
            else
                params.saveSCP = false;
            end
            
            isarray = contains(obj.guihan.ListBoxNonBSA.Items,"array");
            params.nonBSA_list = obj.guihan.ListBoxNonBSA.Items(~isarray);
            
            % Array lists
            params.nonBSA_Array_list = obj.guihan.ListBoxNonBSA.Items(isarray);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Setup the scan parameters %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            scan_type = obj.guihan.ScanTypeDropDown.Value;
            switch scan_type
                case 'Single Step'
                    params.scanDim = 0;
                case '1D Scan'
                    params.scanDim = 1;
                case '2D Scan'
                    params.scanDim = 2;
            end
            
            params.scanFuncs = {};
            params.scanPVs = {};
            params.startVals = [];
            params.stopVals = [];
            params.scanVals = {};
            
            % This array is used for flattening the scan
            params.stepsAll = [];
            params.totalSteps = 0;
            
            if params.scanDim > 0
                % Add handling for use PV
                % e.g: obj.checkUsePV()
                
                params.scanFuncs{1} = obj.guihan.ScanfunctionDropDown.Value;
                if ~isempty(obj.guihan.PVEditField) &&...
                        ~isempty(obj.guihan.RBVEditField) && ...
                        ~isempty(obj.guihan.WaitsEditField)  && ...
                        ~isempty(obj.guihan.ToleranceEditField)
                    params.scanPVs{1} = obj.guihan.PVEditField.Value;
                    params.RBV_PVs{1} = obj.guihan.RBVEditField.Value;
                    params.Waits{1} = obj.guihan.WaitsEditField.Value;
                    params.Tolerance{1} = obj.guihan.ToleranceEditField.Value;
                else
                    obj.addMessage('Cannot run scan without PV field specified.');
                    return
                end
                
                if params.Tolerance{1} == 0
                    obj.addMessage('Warning: attempting scan with tolerance = 0.');
                end
                
                params.startVals(1) = obj.guihan.StartEditField.Value;
                params.stopVals(1) = obj.guihan.StopEditField.Value;
                params.nSteps(1) = obj.guihan.StepsEditField.Value;
                params.scanVals{1} = obj.guihan.scan_vals;
                
                params.totalSteps = params.nSteps(1);
                params.stepsAll = (1:params.nSteps(1))';
                
                if params.totalSteps == 0
                    obj.addMessage('Cannot run scan with zero steps.');
                    return
                end
                
                if params.startVals(1) == params.stopVals(1)
                    answer = obj.CheckWithMax();
                    if ~answer
                        obj.addMessage('Try again.');
                        return
                    end
                end
                    
            end
            
            if params.scanDim > 1
                % Add handling for use PV
                % e.g: obj.checkUsePV()
                
                params.scanFuncs{2} = obj.guihan.ScanfunctionDropDown_2.Value;
                % Check that PV, RBV, and Tolerance fields are filled in
                if ~isempty(obj.guihan.PVEditField_2) &&...
                        ~isempty(obj.guihan.RBVEditField_2) && ...
                        ~isempty(obj.guihan.WaitsEditField_2) && ...
                        ~isempty(obj.guihan.ToleranceEditField_2)
                    params.scanPVs{2} = obj.guihan.PVEditField_2.Value;
                    params.RBV_PVs{2} = obj.guihan.RBVEditField_2.Value;
                    params.Waits{2} = obj.guihan.WaitsEditField_2.Value;
                    params.Tolerance{2} = obj.guihan.ToleranceEditField_2.Value;
                else
                    obj.addMessage('Cannot run scan without PV field specified.');
                    return
                end
                
                if params.Tolerance{2} == 0
                    obj.addMessage('Warning: attempting scan with tolerance = 0.');
                end
                
                params.scanPVs{2} = obj.guihan.PVEditField_2.Value;
                params.startVals(2) = obj.guihan.StartEditField_2.Value;
                params.stopVals(2) = obj.guihan.StopEditField_2.Value;
                params.nSteps(2) = obj.guihan.StepsEditField_2.Value;
                params.scanVals{2} = obj.guihan.scan_vals2;
                
                params.totalSteps = params.nSteps(1)*params.nSteps(2);
                params.stepsAll = zeros(params.totalSteps,2);
                params.stepsAll(:,1) = repelem((1:params.nSteps(1))',params.nSteps(2));
                params.stepsAll(:,2) = repmat((1:params.nSteps(2))',params.nSteps(1),1);
                if params.totalSteps == 0
                    obj.addMessage('Cannot run scan with zero steps.');
                    return
                end
                
                if params.startVals(2) == params.stopVals(2)
                    answer = obj.CheckWithMax();
                    if ~answer
                        obj.addMessage('Try again.');
                        return
                    end
                end
            end
        end
        
        function runDAQ(obj)
        % This function pulls the configuration out of the GUI and formats
        % it into a DAQ parameter structure
        
            if isempty(obj.guihan.ListBox.Items)
                obj.addMessage('Cannot run DAQ with zero cameras selected.');
                return
            end
            
            % Check if there are edefs available
            num_edefs = lcaGetSmart('IOC:SYS1:EV01:EDEFAVAIL');
            if num_edefs == 0
                obj.addMessage('Cannot run DAQ with no EDEFs available.');
                return
            end
            
            obj.DAQ_params.experiment = obj.guihan.ExperimentDropDown.Value;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Beam rate and associated event code %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            rv = obj.guihan.RateDropDown.Value;
            
            obj.DAQ_params.rate = obj.rates{strcmp(rv,obj.rate_names)};
            obj.DAQ_params.rate_name = rv;
            obj.DAQ_params.doStream = obj.guihan.StreamDataCheckBox.Value;
            %if obj.guihan.FastDAQCheckBox.Value
            %    obj.DAQ_params.EC = 214;
            %else
            %    obj.DAQ_params.EC = 222;
            %end
            obj.DAQ_params.EC = 214;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% parameters and flags %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            obj.DAQ_params.comment    = obj.guihan.CommentTextArea.Value;
            obj.DAQ_params.n_shot     = obj.guihan.ShotsperstepEditField.Value;
            obj.DAQ_params.print2elog = obj.guihan.PrinttoeLogCheckBox.Value;
            obj.DAQ_params.saveBG     = obj.guihan.SavebackgroundCheckBox.Value;
            obj.DAQ_params.laserBG    = obj.guihan.SaveLaserBGCheckBox.Value;
            obj.DAQ_params.nBG        = obj.guihan.BackgroundshotsEditField.Value;
            obj.DAQ_params.blockBeam  = obj.guihan.Blockbeam.Value;
            obj.DAQ_params.allowDuplicateSteps = obj.guihan.Allowduplicatesteps.Value;
            obj.DAQ_params.saveMethod = obj.guihan.Switch.Value;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Get the cameras, metadata, %%%
            %%% settings and triggers      %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            [~,ia,~] = intersect(obj.camCheck.camNames,obj.guihan.ListBox.Items);
            list_bool = false(size(obj.camCheck.camNames));
            list_bool(ia) = true;
            obj.camCheck.downSelect(list_bool);
            
            obj.DAQ_params.camNames = obj.camCheck.DAQ_Cams.camNames;
            obj.DAQ_params.camPVs   = obj.camCheck.DAQ_Cams.camPVs;
            obj.DAQ_params.camSIOCs = obj.camCheck.DAQ_Cams.siocs;
            obj.DAQ_params.camTrigs = obj.camCheck.DAQ_Cams.camTrigs;
            obj.DAQ_params.num_CAM  = numel(obj.DAQ_params.camNames);
            obj.camCheck.checkTrigStat();
            
            % Enable "Fix Cameras" button in GUI
            obj.guihan.FixCamerasButton.Enable = 'on';
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% BSA, SCP, and non-BSA PV lists %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Scalar data lists
            isBSA = contains(obj.guihan.ListBoxBSA.Items,"BSA");
            obj.DAQ_params.BSA_list = obj.guihan.ListBoxBSA.Items(isBSA);
                        
            isSCP = contains(obj.guihan.ListBoxBSA.Items,"SCP");
            obj.DAQ_params.SCP_list = obj.guihan.ListBoxBSA.Items(isSCP);
            if ~isempty(obj.DAQ_params.SCP_list)
                obj.DAQ_params.saveSCP = true;
            else
                obj.DAQ_params.saveSCP = false;
            end
            
            if obj.DAQ_params.saveSCP
                if obj.DAQ_params.n_shot >= obj.scp_max
                    selection = uiconfirm(obj.guihan.FACETIIDAQUIFigure,...
                        "Requesting too many shots. Aborting. Try again with less shots.",...
                        "Error requesting SCP data",'Options',{'OK'},'Icon','error');
                    if strcmp(selection,'OK');return;end
                else
                    % Try to estimate how long it will take to write SCP data
                    % assume approx 8 devices per SCP list
                    totalDataPts = obj.DAQ_params.n_shot*numel(obj.DAQ_params.SCP_list)*8;
                    
                    % Coefficients for linear fit were acquired empirically
                    c1 = 3.87E-03;
                    c2 = 0.25;
                    predWaitTime = c1*totalDataPts + c2;
                    predWaitTime = round(predWaitTime,-1);
                    
                    selection = uiconfirm(obj.guihan.FACETIIDAQUIFigure,...
                        ['Acquiring SCP data will steal rate from other applications. ',...
                        'Also, expect to wait approx ' num2str(predWaitTime) ' seconds ',...
                        'between steps while SCP data is being written.'],...
                        "Warning",'Options',{'Continue','Abort'},'Icon','warning');
                    if strcmp(selection,'Abort')
                        return
                    end
                end
            end
            
            isarray = contains(obj.guihan.ListBoxNonBSA.Items,"array");
            obj.DAQ_params.nonBSA_list = obj.guihan.ListBoxNonBSA.Items(~isarray);
            
            % Array lists
            obj.DAQ_params.nonBSA_Array_list = obj.guihan.ListBoxNonBSA.Items(isarray);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Setup the scan parameters %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            scan_type = obj.guihan.ScanTypeDropDown.Value;
            switch scan_type
                case 'Single Step'
                    obj.DAQ_params.scanDim = 0;
                case '1D Scan'
                    obj.DAQ_params.scanDim = 1;
                case '2D Scan'
                    obj.DAQ_params.scanDim = 2;
            end
            
            obj.DAQ_params.scanFuncs = {};
            obj.DAQ_params.scanPVs = {};
            obj.DAQ_params.startVals = [];
            obj.DAQ_params.stopVals = [];
            obj.DAQ_params.scanVals = {};
            
            % This array is used for flattening the scan
            obj.DAQ_params.stepsAll = [];
            obj.DAQ_params.totalSteps = 0;
            
            if obj.DAQ_params.scanDim > 0
                % Add handling for use PV
                % e.g: obj.checkUsePV()
                
                obj.DAQ_params.scanFuncs{1} = obj.guihan.ScanfunctionDropDown.Value;
                if ~isempty(obj.guihan.PVEditField) &&...
                        ~isempty(obj.guihan.RBVEditField) && ...
                        ~isempty(obj.guihan.WaitsEditField)  && ...
                        ~isempty(obj.guihan.ToleranceEditField)
                    obj.DAQ_params.scanPVs{1} = obj.guihan.PVEditField.Value;
                    obj.DAQ_params.RBV_PVs{1} = obj.guihan.RBVEditField.Value;
                    obj.DAQ_params.Waits{1} = obj.guihan.WaitsEditField.Value;
                    obj.DAQ_params.Tolerance{1} = obj.guihan.ToleranceEditField.Value;
                else
                    obj.addMessage('Cannot run scan without PV field specified.');
                    return
                end
                
                if obj.DAQ_params.Tolerance{1} == 0
                    obj.addMessage('Warning: attempting scan with tolerance = 0.');
                end
                
                obj.DAQ_params.startVals(1) = obj.guihan.StartEditField.Value;
                obj.DAQ_params.stopVals(1) = obj.guihan.StopEditField.Value;
                obj.DAQ_params.nSteps(1) = obj.guihan.StepsEditField.Value;
                obj.DAQ_params.scanVals{1} = obj.guihan.scan_vals;
                
                obj.DAQ_params.totalSteps = obj.DAQ_params.nSteps(1);
                obj.DAQ_params.stepsAll = (1:obj.DAQ_params.nSteps(1))';
                
                if obj.DAQ_params.totalSteps == 0
                    obj.addMessage('Cannot run scan with zero steps.');
                    return
                end
                
                if obj.DAQ_params.startVals(1) == obj.DAQ_params.stopVals(1)
                    answer = obj.CheckWithMax();
                    if ~answer
                        obj.addMessage('Try again.');
                        return
                    end
                end
                    
            end
            
            if obj.DAQ_params.scanDim > 1
                % Add handling for use PV
                % e.g: obj.checkUsePV()
                
                obj.DAQ_params.scanFuncs{2} = obj.guihan.ScanfunctionDropDown_2.Value;
                % Check that PV, RBV, and Tolerance fields are filled in
                if ~isempty(obj.guihan.PVEditField_2) &&...
                        ~isempty(obj.guihan.RBVEditField_2) && ...
                        ~isempty(obj.guihan.WaitsEditField_2) && ...
                        ~isempty(obj.guihan.ToleranceEditField_2)
                    obj.DAQ_params.scanPVs{2} = obj.guihan.PVEditField_2.Value;
                    obj.DAQ_params.RBV_PVs{2} = obj.guihan.RBVEditField_2.Value;
                    obj.DAQ_params.Waits{2} = obj.guihan.WaitsEditField_2.Value;
                    obj.DAQ_params.Tolerance{2} = obj.guihan.ToleranceEditField_2.Value;
                else
                    obj.addMessage('Cannot run scan without PV field specified.');
                    return
                end
                
                if obj.DAQ_params.Tolerance{2} == 0
                    obj.addMessage('Warning: attempting scan with tolerance = 0.');
                end
                
                obj.DAQ_params.scanPVs{2} = obj.guihan.PVEditField_2.Value;
                obj.DAQ_params.startVals(2) = obj.guihan.StartEditField_2.Value;
                obj.DAQ_params.stopVals(2) = obj.guihan.StopEditField_2.Value;
                obj.DAQ_params.nSteps(2) = obj.guihan.StepsEditField_2.Value;
                obj.DAQ_params.scanVals{2} = obj.guihan.scan_vals2;
                
                obj.DAQ_params.totalSteps = obj.DAQ_params.nSteps(1)*obj.DAQ_params.nSteps(2);
                obj.DAQ_params.stepsAll = zeros(obj.DAQ_params.totalSteps,2);
                obj.DAQ_params.stepsAll(:,1) = repelem((1:obj.DAQ_params.nSteps(1))',obj.DAQ_params.nSteps(2));
                obj.DAQ_params.stepsAll(:,2) = repmat((1:obj.DAQ_params.nSteps(2))',obj.DAQ_params.nSteps(1),1);
                if obj.DAQ_params.totalSteps == 0
                    obj.addMessage('Cannot run scan with zero steps.');
                    return
                end
                
                if obj.DAQ_params.startVals(2) == obj.DAQ_params.stopVals(2)
                    answer = obj.CheckWithMax();
                    if ~answer
                        obj.addMessage('Try again.');
                        return
                    end
                end
            end
            
            %%%%%%%%%%%%%%%%%%%%
            %%% Run the DAQ! %%%
            %%%%%%%%%%%%%%%%%%%%
            
            obj.addMessage('DAQ parameters set.');
            if strcmp(obj.DAQ_params.saveMethod,'TIFF')
                obj.DAQ_obj = F2_fastDAQ(obj.DAQ_params,obj);
            elseif strcmp(obj.DAQ_params.saveMethod,'HDF5')
                obj.DAQ_obj = F2_fastDAQ_HDF5(obj.DAQ_params,obj);
            end
            
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Everything below is a helper function %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        function initCameras(obj)
        % Gets list of FACET cameras and adds it to DAQ GUI 
            
            % Organize cameras in GUI by region and load into GUI
            region_list = unique(obj.camCheck.regions);
            region_node_list = [];
            camera_node_list = [];
            
            for i = 1:numel(region_list)
                region_node_list = [region_node_list uitreenode(obj.guihan.Tree,'Text',region_list{i})];
            end
            
            for j = 1:numel(obj.camCheck.camNames)
                r = find(strcmp(region_list,obj.camCheck.regions{j}));
                camera_node_list = [camera_node_list uitreenode(region_node_list(r),'Text',obj.camCheck.camNames{j},'NodeData',obj.camCheck.camPVs{j})];
            end
            
            obj.addMessage(sprintf('Loaded %d cameras.',numel(camera_node_list)));
            
        end
        
        function loadBSALists(obj)
            
            file_lists = dir('BSA_List*');
            name_lists = {};
            for i = 1:numel(file_lists)
                split = strsplit(file_lists(i).name,'.');
                name_lists{end+1} = split{1};
            end
            
            % Add SCP BPM lists
            scp_lists = dir('SCP_*');
            SCP_Lists = {};
            for i = 1:numel(scp_lists)
                split = strsplit(scp_lists(i).name,'.');
                SCP_Lists{end+1} = split{1};
            end

            name_lists = [name_lists, SCP_Lists];
            obj.guihan.BSADataListBox.Items = name_lists;
            obj.addMessage(sprintf('Loaded %d BSA and SCP Lists.',numel(name_lists)));
        end
        
        function loadnonBSALists(obj)
            
            file_lists = dir('nonBSA_List*');
            name_lists = {};
            for i = 1:numel(file_lists)
                split = strsplit(file_lists(i).name,'.');
                name_lists{end+1} = split{1};
            end
            obj.guihan.nonBSADataListBox.Items = name_lists;
            
            obj.addMessage(sprintf('Loaded %d non-BSA Lists.',numel(name_lists)));
        end
        
        function loadnonBSA_ArrayLists(obj)
            
            file_lists = dir('array_nonBSA_List*');
            name_lists = {};
            for i = 1:numel(file_lists)
                split = strsplit(file_lists(i).name,'.');
                name_lists{end+1} = split{1};
            end
            obj.DAQ_params.include_nonBSA_arrays = true;
            
            obj.guihan.nonBSADataListBox.Items = [obj.guihan.nonBSADataListBox.Items name_lists];
            
            obj.addMessage(sprintf('Loaded %d non-BSA Array Lists.',numel(name_lists)));
        end
        
        function loadScans(obj)
            file_lists = dir('scanFunc*');
            name_lists = {};
            for i = 1:numel(file_lists)
                split = strsplit(file_lists(i).name,'.');
                split = strsplit(split{1},'scanFunc_');
                name_lists{end+1} = split{2};
            end
            
            obj.guihan.ScanfunctionDropDown.Items = name_lists;
            obj.guihan.ScanfunctionDropDown.Value = 'Use_PV';
            obj.guihan.ScanfunctionDropDown_2.Items = name_lists;
            obj.guihan.ScanfunctionDropDown.Value = 'Use_PV';
            
            obj.addMessage(sprintf('Loaded %d Scan functions.',numel(name_lists)));
        end
        
        function scanFuncSelected(obj,value)
            
            obj.guihan.PVEditField.Value = '';
            obj.guihan.RBVEditField.Value = '';
            obj.guihan.WaitsEditField.Value = 0;
            obj.guihan.ToleranceEditField.Value = 0;
            
            obj.guihan.PVEditField.Enable = true;
            obj.guihan.RBVEditField.Enable = true;
            obj.guihan.WaitsEditField.Enable = true;
            obj.guihan.ToleranceEditField.Enable = true;

            if ~strcmp(value,'Use_PV')
                scanFunc = feval(['scanFunc_' value],obj);
                obj.guihan.PVEditField.Value = scanFunc.control_PV;
                obj.guihan.RBVEditField.Value = scanFunc.readback_PV;
                %obj.guihan.WaitsEditField.Value = scanFunc.waits;
                obj.guihan.ToleranceEditField.Value = scanFunc.tolerance;
                
                obj.guihan.PVEditField.Enable = false;
                obj.guihan.RBVEditField.Enable = false;
                obj.guihan.WaitsEditField.Enable = false;
                obj.guihan.ToleranceEditField.Enable = false;
                
            end
        end
        
        function scanFuncSelected_2(obj,value)
            
            obj.guihan.PVEditField_2.Value = '';
            obj.guihan.RBVEditField_2.Value = '';
            obj.guihan.WaitsEditField_2.Value = 0;
            obj.guihan.ToleranceEditField_2.Value = 0;
            
            obj.guihan.PVEditField_2.Enable = true;
            obj.guihan.RBVEditField_2.Enable = true;
            obj.guihan.WaitsEditField_2.Enable = true;
            obj.guihan.ToleranceEditField_2.Enable = true;
            
            if ~strcmp(value,'Use_PV')
                scanFunc = feval(['scanFunc_' value],obj);
                obj.guihan.PVEditField_2.Value = scanFunc.control_PV;
                obj.guihan.RBVEditField_2.Value = scanFunc.readback_PV;
                %obj.guihan.WaitsEditField_2.Value = scanFunc.waits;
                obj.guihan.ToleranceEditField_2.Value = scanFunc.tolerance;
                
                obj.guihan.PVEditField_2.Enable = false;
                obj.guihan.RBVEditField_2.Enable = false;
                obj.guihan.WaitsEditField_2.Enable = false;
                obj.guihan.ToleranceEditField_2.Enable = false;
            end
        end
            
        function display_list(obj,list)
            obj.addMessage(sprintf('Generating display table for %s',list));
            
            pv_list = feval(list);
            pv_check = pv_list;
            for i = 1:numel(pv_check)
                if contains(pv_check{i},'.')
                    spl = strsplit(pv_check{i},'.');
                    pv_check{i} = spl{1};
                end
            end
            descs = lcaGetSmart(strcat(pv_check,'.DESC'));
            t = table(pv_list,descs);
            fig = uifigure;
            uit = uitable(fig,'Data',t);
            uit.Position = [20 20 520 380];
        end
        
        function answer = CheckWithMax(obj)
            quest = 'You tried to a run scan with all the same values. Did you mean to?';
            dlgTitle = 'Are you Max Gilljohann?';
            btn1 = 'Yes I meant to do this.';
            btn2 = 'Whoops! My bad.';
            max = questdlg(quest,dlgTitle,btn1,btn2,btn2);
            
            answer = strcmp(max,btn1);
        end

        function addMessage(obj,message)
            
            obj.nMsg = obj.nMsg+1;
            obj.message{obj.nMsg} = message;
            fprintf(['%s (F2_DAQ) ' message '\n'],datestr(now));
            
            msgBoxStr = '';
            if obj.nMsg < 5
                
                for i = 1:obj.nMsg
                    msgBoxStr = sprintf([msgBoxStr obj.message{i} '\n']);
                end
                
            else
                
                for i = (obj.nMsg-3):obj.nMsg
                    msgBoxStr = sprintf([msgBoxStr obj.message{i} '\n']);
                end
            end
            obj.guihan.MessagesTextArea.Value = msgBoxStr;
            
            
        end
        
        function end_watch(obj)
            
            stop(obj.pvlist);
            
        end
        
        
        
    end
end
