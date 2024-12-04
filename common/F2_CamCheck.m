classdef F2_CamCheck < handle
    
    properties
        pvlist PV
        pvs
        camera_info
        camNames
        camPVs
        camTrigs
        camPower
        camECs
        regions
        siocs
        sioc_list
        DAQ_bool
        objhan
        freerun
        DAQ_Cams
        camStructs
        badIOCs
        badCams
        badINDs
    end
    properties(Hidden)
        listeners
    end
    properties(Constant)
        maxbeat=1e7 % max heartbeat count, wrap to zero
        ecs = [201,203,213,214,222,223,224,225,226,131,53,54,55,56]
        n_ecs = 14
    end
    
    methods
        
         function obj = F2_CamCheck(DAQ_bool,apph)
            
            % Check if CamCheck called by DAQ
            if exist('DAQ_bool','var')
                obj.DAQ_bool = DAQ_bool;
            else
                obj.DAQ_bool = false;
            end
            
            % Check if CamCheck called by GUI
            if exist('apph','var')
                obj.objhan=apph;
                obj.freerun = false;
            else
                obj.freerun = true;
            end
            
            obj.camera_info = model_nameListFACETProf(true); % Camera List
            spctrmtrInfo = {'UVVisSpec','SPEC:LI20:101','','S20 Spectrometer','cpu-li20-pm01','TRIG:LI20:PM06:1:TCTL',''};
            obj.camera_info = [obj.camera_info;spctrmtrInfo];
            
            % Ignore transport cameras in DAQ
            if obj.DAQ_bool; obj.remove_transport(); end
            
            % Ignore transport cameras in DAQ
            if obj.DAQ_bool; obj.remove_monitor(); end
            
            % Ignore cmos cameras in DAQ
            %if obj.DAQ_bool; obj.remove_cmos(); end
            
            % Get camera IOC status, remove bad cameras if DAQ
            obj.add_SIOCs();
            
            % add info to CamCheck obj
            obj.camNames = obj.camera_info(:,1);
            obj.camPVs = obj.camera_info(:,2);
            obj.regions = obj.camera_info(:,4);
            obj.camTrigs = obj.camera_info(:,6);
            obj.camPower = obj.camera_info(:,7);
            
            % Check for IOCs that are down and remove bad cameras if DAQ
            obj.checkIOCs();
            
            % Get live camera names
            if obj.DAQ_bool; obj.getLiveNames(); end
            
        end
        
        function remove_transport(obj)
        % Remove laser transport cameras because they dont have triggers
            trnspt_cams = strcmp(obj.camera_info(:,4),'S20 Transprt');
            obj.camera_info(trnspt_cams,:) = [];
            
        end
        
        function remove_monitor(obj)
        % Remove laser transport cameras because they dont have triggers
            monitor_cams = strcmp(obj.camera_info(:,4),'S20 Monitor');
            obj.camera_info(monitor_cams,:) = [];
            
        end
        
        function remove_cmos(obj)
        % Remove laser transport cameras because they dont have triggers
            scmos_cams = strcmp(obj.camera_info(:,4),'S20 sCMOS');
            obj.camera_info(scmos_cams,:) = [];
            
        end
        
        function add_SIOCs(obj)
            
            % Mapping of CPUs, SIOCs, and ECs
            %                 CPU                    SIOC              EC
            obj.sioc_list = {'cpu-lr10-pm01',       'SIOC:LR10:PM01'   223;
                             'cpu-in10-pm01',       'SIOC:IN10:PM01'   223;
                             'cpu-li10-pm01',       'SIOC:LI10:PM02'   201;
                             'cpu-li14-pm01',       'SIOC:LI14:PM01'   201;
                             'cpu-li15-pm01',       'SIOC:LI15:PM01'   201;
                             'cpu-li20-pm01',       'SIOC:LI20:PM01'   222;
                             'cpu-li20-pm02',       'SIOC:LI20:PM02'   222;
                             'cpu-li20-pm03',       'SIOC:LI20:PM03'   223;
                             'cpu-li20-pm04',       'SIOC:LI20:PM04'   222;
                             'cpu-li20-pm05',       'SIOC:LI20:PM05'   222;
                             'cpu-li20-pm06',       'SIOC:LI20:PM06'   222;
                             'cpu-li20-pm07',       'SIOC:LI20:PM07'   223;
                             'cpu-li20-pm08',       'SIOC:LI20:PM08'   223;
                             'cpu-li20-pm09',       'SIOC:LI20:PM09'   222;
                             };
            
            % Fill in data for each camera and add exceptions
            obj.siocs = cell(size(obj.camera_info(:,5)));
            obj.camECs = zeros(size(obj.camera_info(:,5)));
            cam_names = obj.camera_info(:,1);
            for i = 1:numel(obj.camera_info(:,5))
                ind = strcmp(obj.sioc_list(:,1),obj.camera_info{i,5});
                obj.siocs{i} = obj.sioc_list{ind,2};
                obj.camECs(i) = obj.sioc_list{ind,3};
                
                % Exceptions
                if strcmp(cam_names{i},'PR10241') ||...
                   strcmp(cam_names{i},'LHUSOTR') ||...
                   strcmp(cam_names{i},'LHDSOTR')
                    obj.camECs(i) = 201;
                end
                if strcmp(cam_names{i},'UVVisSpec')
                    obj.camECs(i) = 223;
                end
            end
            
            
                         
        end
        
        function checkIOCs(obj)
            % Removes cameras from the list if the IOCs are bad
            
            bad_inds = false(numel(obj.siocs),1);
            for i = 1:numel(obj.siocs)
                status = lcaGetSmart([obj.siocs{i} ':HEARTBEATSUM'],0,'DBF_ENUM');
                if status ~= 0
                    obj.dispMessage(['Warning: IOC ' obj.siocs{i} ' serving camera ' obj.camNames{i} ' is down.']);
                    bad_inds(i) = true;
                end
            end
            
            obj.badIOCs = obj.siocs(bad_inds);
            obj.badCams = obj.camPVs(bad_inds);
            obj.badINDs = bad_inds;
            
            if obj.DAQ_bool
                badCamNames = join(obj.camNames(bad_inds),",");
                if ~isempty(obj.camNames(bad_inds))
                    obj.dispMessage(char(append('Removing camera(s) ',badCamNames,' from DAQ.')));
                end
                obj.camera_info(bad_inds,:) = [];
                obj.camNames(bad_inds) = [];
                obj.camPVs(bad_inds) = [];
                obj.regions(bad_inds) = [];
                obj.camTrigs(bad_inds) = [];
                obj.camPower(bad_inds) = [];
                obj.siocs(bad_inds) = [];
                obj.camECs(bad_inds) = [];
            end

            
        end
        
        function getLiveNames(obj)
            % This should work if IOC test went ok
            
            liveNames = lcaGetSmart(strcat(obj.camPVs,':NAME'));
            
            % This should be unnessary if IOCs are live
            ind = find(cellfun(@(x) isempty(x),liveNames));
            if ind; liveNames(ind) = obj.camNames(ind,1); end
            
            obj.camNames = liveNames;
            obj.camera_info(:,1) = liveNames;
            
        end
        
        function downSelect(obj,ind)
            % This function selects only the cams wanted by DAQ
            obj.DAQ_Cams.camera_info = obj.camera_info(ind,:);
            obj.DAQ_Cams.camNames = obj.camNames(ind);
            obj.DAQ_Cams.camPVs = obj.camPVs(ind);
            obj.DAQ_Cams.regions = obj.regions(ind);
            obj.DAQ_Cams.camTrigs = obj.camTrigs(ind);
            obj.DAQ_Cams.camPower = obj.camPower(ind);
            obj.DAQ_Cams.siocs = obj.siocs(ind);
            obj.DAQ_Cams.camECs = obj.camECs(ind);
            obj.DAQ_Cams.num_CAM = sum(ind);

        end
        
        % Functions for DAQ - Generate EVR PVs and check state
        function checkTrigStat(obj)
            % List of triggers associated with each camera
            cam_trigs = obj.DAQ_Cams.camTrigs;
            
            % Configuration of EVR before DAQ starts
            evrSettings = zeros(obj.DAQ_Cams.num_CAM,1);
            evrRoots  = cell(obj.DAQ_Cams.num_CAM,1);
            evrChans  = cell(obj.DAQ_Cams.num_CAM,1);
            
            % Loop over camera trigs
            for i = 1:numel(cam_trigs)
                % Create EVR PV from trigger PV
                comps = strsplit(cam_trigs{i},':');
                chan_str = comps{4};
                %chan_num = str2num(comps{4});
                
                evr_str = ['EVR:' comps{2} ':' comps{3}];
                evrRoots{i} = evr_str;
                evrChans{i} = chan_str;
                
                % We now implement a default EC to revert to
                evr_default = (obj.DAQ_Cams.camECs(i) == obj.ecs);
                
                % Loop over event codes and find which one is set to true
                evr_state = zeros(1,obj.n_ecs);
                for j = 1:obj.n_ecs
                    
                    evr_state(j) = lcaGet([evr_str ':EVENT' num2str(j) 'CTRL.OUT' chan_str],0,'float');
                    
                end
                
                % Process fails if none are set to true or if more than 1
                % are set to true
                if sum(evr_state) ~= 1
                    obj.dispMessage(sprintf('Cannot determine EVR/Trigger state of camera %s. Aborting',obj.DAQ_Cams.camNames{i}));
                    error('Cannot determine EVR/Trigger state of camera %s. Aborting',obj.DAQ_Cams.camNames{i});
                end
                
                % If EVR state is not he default state, issue a warning
                if ~isequal(evr_default,evr_state)
                    obj.dispMessage(sprintf('Warning: EVR state of camera %s does not match default state. Camera will revert to default after DAQ.',obj.DAQ_Cams.camNames{i}));
                end
                
                evrSettings(i) = obj.ecs(logical(evr_default));
                
            end
            
            obj.DAQ_Cams.evrSettings = evrSettings;
            obj.DAQ_Cams.evrRoots = evrRoots;
            obj.DAQ_Cams.evrChans = evrChans;
        end
                
        function set_trig_event(obj,EC)
            daq_ind = find(obj.ecs==EC);
           
            for i=1:obj.DAQ_Cams.num_CAM
                evr_setting = obj.DAQ_Cams.evrSettings(i);
                evr_ind = find(obj.ecs==evr_setting);
                lcaPut([obj.DAQ_Cams.evrRoots{i} ':EVENT' num2str(evr_ind) 'CTRL.OUT' obj.DAQ_Cams.evrChans{i}],0);
                lcaPut([obj.DAQ_Cams.evrRoots{i} ':EVENT' num2str(daq_ind) 'CTRL.OUT' obj.DAQ_Cams.evrChans{i}],1);
            end
        end
        
        function restore_trig_event(obj,EC)
            
            %daq_ind = find(obj.ecs==EC);
           
            for i=1:obj.DAQ_Cams.num_CAM
                
                % Reset all event codes to false
                for j = 1:obj.n_ecs
                    lcaPut([obj.DAQ_Cams.evrRoots{i} ':EVENT' num2str(j) 'CTRL.OUT' obj.DAQ_Cams.evrChans{i}],0,'float');
                end
%                 lcaPut([obj.DAQ_Cams.evrRoots{i} ':EVENT' num2str(daq_ind) 'CTRL.OUT' obj.DAQ_Cams.evrChans{i}],0);
                
                % Set correct event code to true
                evr_setting = obj.DAQ_Cams.evrSettings(i);
                evr_ind = find(obj.ecs==evr_setting);
                lcaPut([obj.DAQ_Cams.evrRoots{i} ':EVENT' num2str(evr_ind) 'CTRL.OUT' obj.DAQ_Cams.evrChans{i}],1);
                
                lcaPut([obj.DAQ_Cams.camPVs{i} ':TSS_SETEC'],evr_setting);
            end
        end
        
           function bad_cam = checkConnect(obj,daq_bool)
            % Check if camera is running
            if daq_bool
                cmos_cams = strcmp(obj.DAQ_Cams.regions,'S20 sCMOS');
                connect_pvs = strcat(obj.DAQ_Cams.camPVs,':AsynIO.CNCT');
                connect_pvs(cmos_cams) = strcat(obj.DAQ_Cams.camPVs(cmos_cams),':DetectorState_RBV');
                cam_stat = lcaGet(connect_pvs,0,'DBF_ENUM');
                bad_cam = cam_stat ~= 1;
            else
                cmos_cams = strcmp(obj.regions,'S20 sCMOS');
                connect_pvs = strcat(obj.camPVs,':AsynIO.CNCT');
                connect_pvs(cmos_cams) = strcat(obj.camPVs(cmos_cams),':DetectorState_RBV');
                cam_stat = lcaGet(connect_pvs,0,'DBF_ENUM');
                bad_cam = cam_stat ~= 1;
            end
        end
        
        function getCamStructs(obj)
            obj.checkIOCs();
            obj.camStructs = {};
            
            for i = 1:numel(obj.camPVs)
    
                obj.camStructs{i} = get_cam_info(obj.camPVs{i});
    
            end
            
        end
                        
        
        function dispMessage(obj,message)
            if obj.freerun
                disp(message);
            else
                obj.objhan.addMessage(message);
            end
        end
        
    end
    
end
