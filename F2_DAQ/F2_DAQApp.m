classdef F2_DAQApp < handle
    events
        PVUpdated % PV object list notifies this event after each set of monitored PVs have finished updating
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
    end
    
    methods
        
        function obj = F2_DAQApp(apph)
            
            % Associate class with GUI
            obj.guihan=apph;
            
            % Dear Diary, My name is FACET DAQ and I am 0x00 old today
            diary('/u1/facet/physics/log/matlab/F2_DAQ.log');
            
            % initialize object and add PVs to be monitored
            context = PV.Initialize(PVtype.EPICS_labca) ;
            obj.pvlist=[...
                PV(context,'name',"GUI_Instance",'pvname',"SIOC:SYS1:ML02:AO351",'mode',"rw",'monitor',true); % Number of times GUI is run
                PV(context,'name',"DAQ_Instance",'pvname',"SIOC:SYS1:ML02:AO400",'mode',"rw",'monitor',true); % Number of times DAQ is run
                ] ;
            pset(obj.pvlist,'debug',0) ;
            obj.pvs = struct(obj.pvlist);
            
            inst = caget(obj.pvs.GUI_Instance);
            caput(obj.pvs.GUI_Instance,inst+1);
            obj.nMsg = 0;
            obj.addMessage(sprintf('Started GUI instance %d.',inst+1));
            
            % Initialize camera list
            obj.camCheck = F2_CamCheck(true,obj);
            obj.initCameras();
            
            % Load BSA Lists
            obj.loadBSALists();
            
            % Load non-BSA Lists
            obj.loadnonBSALists();
            
        end
        
        function runDAQ(obj)
        % This function pulls the configuration out of the GUI and formats
        % it into a DAQ parameter structure
        
            if isempty(obj.guihan.ListBox.Items)
                obj.addMessage('Cannot run DAQ with zero cameras selected.');
                return
            end
            
            obj.DAQ_params.experiment = obj.guihan.ExperimentDropDown.Value;
            EC = split(obj.guihan.EventCodeButtonGroup.SelectedObject.Text);
            obj.DAQ_params.EC = str2num(EC{1});
            obj.DAQ_params.comment = obj.guihan.CommentTextArea.Value;
            obj.DAQ_params.n_shot = obj.guihan.ShotsperstepEditField.Value;
            obj.DAQ_params.print2elog = obj.guihan.PrinttoeLogCheckBox.Value;
            obj.DAQ_params.saveBG = obj.guihan.SavebackgroundCheckBox.Value;
            obj.DAQ_params.nBG = obj.guihan.BackgroundshotsEditField.Value;
            
            % Get camera info
            [~,ia,~] = intersect(obj.camera_info(:,1),obj.guihan.ListBox.Items);
            obj.DAQ_params.camNames = obj.camera_info(ia,1);
            obj.DAQ_params.camPVs = obj.camera_info(ia,2);
            obj.DAQ_params.camServers = obj.camera_info(ia,5);
            obj.DAQ_params.camTrigs = obj.camera_info(ia,6);
            obj.DAQ_params.num_CAM = numel(ia);
            
            % Scalar data lists
            obj.DAQ_params.BSA_list = obj.guihan.ListBoxBSA.Items;
            obj.DAQ_params.nonBSA_list = obj.guihan.ListBoxNonBSA.Items;
            
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
            obj.DAQ_params.stepVals = [];
            obj.DAQ_params.scanVals = {};
            
            % This array is used for flattening the scan
            obj.DAQ_params.stepsAll = [];
            obj.DAQ_params.totalSteps = 0;
            
            
            
            if obj.DAQ_params.scanDim > 0
                obj.DAQ_params.scanFuncs{1} = obj.guihan.ScanfunctionDropDown.Value;
                obj.DAQ_params.scanPvs{1} = obj.guihan.PVEditField.Value;
                obj.DAQ_params.startVals(1) = obj.guihan.StartEditField.Value;
                obj.DAQ_params.stopVals(1) = obj.guihan.StopEditField.Value;
                obj.DAQ_params.nSteps(1) = obj.guihan.StepsEditField.Value;
                obj.DAQ_params.scanVals{1} = obj.guihan.ScanValuesTextArea.Value;
                
                obj.DAQ_params.totalSteps = obj.DAQ_params.nSteps(1);
                obj.DAQ_params.stepsAll = (1:obj.DAQ_params.nSteps(1))';
            end
            
            if obj.DAQ_params.scanDim > 1
                obj.DAQ_params.scanFuncs{2} = obj.guihan.ScanfunctionDropDown_2.Value;
                obj.DAQ_params.scanPvs{2} = obj.guihan.PVEditField_2.Value;
                obj.DAQ_params.startVals(2) = obj.guihan.StartEditField_2.Value;
                obj.DAQ_params.stopVals(2) = obj.guihan.StopEditField_2.Value;
                obj.DAQ_params.nSteps(2) = obj.guihan.StepsEditField_2.Value;
                obj.DAQ_params.scanVals{2} = obj.guihan.ScanValuesTextArea_2.Value;
                
                obj.DAQ_params.totalSteps = obj.DAQ_params.nSteps(1)*obj.DAQ_params.nSteps(2);
                obj.DAQ_params.stepsAll = zeros(obj.DAQ_params.totalSteps,2);
                obj.DAQ_params.stepsAll(:,1) = repelem((1:obj.DAQ_params.nSteps(1))',obj.DAQ_params.nSteps(2));
                obj.DAQ_params.stepsAll(:,2) = repmat((1:obj.DAQ_params.nSteps(2))',obj.DAQ_params.nSteps(1));
                
            end
            
            obj.addMessage('DAQ parameters set.');
            obj.DAQ_obj = F2_runDAQ(obj.DAQ_params,obj);
            
        end
        
        function initCameras(obj)
        % Gets list of FACET cameras and adds it to DAQ GUI 
            
            obj.camera_info = model_nameListFACETProf(true); % Camera List
            
            % Remove laser transport cameras because they dont have triggers
            trnspt_cams = strcmp(obj.camera_info(:,4),'S20 Transprt');
            obj.camera_info(trnspt_cams,:) = [];
            
            camera_pvs = obj.camera_info(:,2); % Camera PVs
            camera_regions = obj.camera_info(:,4); % Camera regions
            
            % Get dynamic names
            camera_names = lcaGetSmart(strcat(camera_pvs,':NAME'));
            ind = find(cellfun(@(x) isempty(x),camera_names));
            if ind; camera_names(ind) = obj.camera_info(ind,1); end
            obj.camera_info(:,1) = camera_names;
            
            % Organize cameras in GUI by region and load into GUI
            region_list = unique(camera_regions);
            region_node_list = [];
            camera_node_list = [];
            
            for i = 1:numel(region_list)
                region_node_list = [region_node_list uitreenode(obj.guihan.Tree,'Text',region_list{i})];
            end
            
            for j = 1:numel(camera_names)
                r = find(strcmp(region_list,camera_regions{j}));
                camera_node_list = [camera_node_list uitreenode(region_node_list(r),'Text',camera_names{j},'NodeData',camera_pvs{j})];
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
