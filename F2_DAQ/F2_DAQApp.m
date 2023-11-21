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
            obj.initCameras();
            
            % Load BSA Lists
            obj.loadBSALists();
            
            % Load non-BSA Lists
            obj.loadnonBSALists();
            
            % Load scan functions
            obj.loadScans();
            
        end
        
        function resetDAQ(obj)
            
            % this indicates daq not in use
            caput(obj.pvs.Reset,0);
            
            % this indicates data taking has ended
            caput(obj.pvs.DAQ_DataOn,0);
            obj.addMessage('DAQ reset.');
            
        end
        
        function abort(obj)
            
            caput(obj.pvs.Abort,1);
            obj.addMessage('Abort command sent.');
            
        end
        
        function runDAQ(obj)
        % This function pulls the configuration out of the GUI and formats
        % it into a DAQ parameter structure
        
            if isempty(obj.guihan.ListBox.Items)
                obj.addMessage('Cannot run DAQ with zero cameras selected.');
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
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% BSA and non-BSA PV lists %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Scalar data lists
            obj.DAQ_params.BSA_list = obj.guihan.ListBoxBSA.Items;
            obj.DAQ_params.nonBSA_list = obj.guihan.ListBoxNonBSA.Items;
            
            % Array lists
            if obj.guihan.nonBSAArraysCheckBox.Value
                obj.loadnonBSA_ArrayLists();
            else
                obj.DAQ_params.include_nonBSA_arrays = false;
            end     
            
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
                obj.DAQ_params.scanPVs{1} = obj.guihan.PVEditField.Value;
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
            obj.DAQ_obj = F2_fastDAQ(obj.DAQ_params,obj);
            
%             if obj.guihan.FastDAQCheckBox.Value
%                 obj.DAQ_obj = F2_fastDAQ(obj.DAQ_params,obj);
%             else
%                 obj.DAQ_obj = F2_runDAQ(obj.DAQ_params,obj);
%             end
            
            
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
            obj.guihan.BSADataListBox.Items = name_lists;
            
            obj.addMessage(sprintf('Loaded %d BSA Lists.',numel(name_lists)));
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
            obj.DAQ_params.nonBSA_Array_list = name_lists;
            obj.DAQ_params.include_nonBSA_arrays = true;
            
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
            %name_lists = ['Use PV'; name_lists];
            
            obj.guihan.ScanfunctionDropDown.Items = name_lists;
            obj.guihan.ScanfunctionDropDown_2.Items = name_lists;
            
            obj.addMessage(sprintf('Loaded %d Scan functions.',numel(name_lists)));
        end
        
        function scanFuncSelected(obj,value)

            if ~strcmp(value,'Use_PV')
                scanFunc = feval(['scanFunc_' value],obj);
                obj.guihan.PVEditField.Value = scanFunc.control_PV;
                obj.guihan.RBVEditField.Value = scanFunc.readback_PV;
                obj.guihan.ToleranceEditField.Value = scanFunc.tolerance;
            end
        end
        
        function scanFuncSelected_2(obj,value)
            
            if ~strcmp(value,'Use_PV')
                scanFunc = feval(['scanFunc_' value],obj);
                obj.guihan.PVEditField_2.Value = scanFunc.control_PV;
                obj.guihan.RBVEditField_2.Value = scanFunc.readback_PV;
                obj.guihan.ToleranceEditField_2.Value = scanFunc.tolerance;
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
