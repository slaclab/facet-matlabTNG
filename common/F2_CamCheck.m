classdef F2_CamCheck < handle
    
    properties
        pvlist PV
        pvs
        camera_info
        camNames
        camPVs
        camTrigs
        camPower
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
            
            obj.sioc_list = {'cpu-lr10-pm01',       'SIOC:LR10:PM01';
                             'cpu-in10-pm01',       'SIOC:IN10:PM01';
                             'cpu-li10-pm01',       'SIOC:LI10:PM02';
                             'cpu-li14-pm01',       'SIOC:LI14:PM01';
                             'cpu-li15-pm01',       'SIOC:LI15:PM01';
                             'cpu-li20-pm01',       'SIOC:LI20:PM01';
                             'cpu-li20-pm02',       'SIOC:LI20:PM02';
                             'cpu-li20-pm03',       'SIOC:LI20:PM03';
                             'cpu-li20-pm04',       'SIOC:LI20:PM04';
                             'cpu-li20-pm05',       'SIOC:LI20:PM05';
                             'cpu-li20-pm06',       'SIOC:LI20:PM06';
                             'cpu-li20-pm07',       'SIOC:LI20:PM07';
                             'cpu-li20-pm08',       'SIOC:LI20:PM08';
                             };
            
            obj.siocs = cell(size(obj.camera_info(:,5)));
            for i = 1:numel(obj.camera_info(:,5))
                ind = strcmp(obj.sioc_list(:,1),obj.camera_info{i,5});
                obj.siocs{i} = obj.sioc_list{ind,2};                
            end
                         
        end
        
        function checkIOCs(obj)
            
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
                obj.dispMessage(['Removing camera ' obj.camNames{i} ' from DAQ.']);
                obj.camera_info(bad_inds,:) = [];
                obj.camNames(bad_inds) = [];
                obj.camPVs(bad_inds) = [];
                obj.regions(bad_inds) = [];
                obj.camTrigs(bad_inds) = [];
                obj.camPower(bad_inds) = [];
                obj.siocs(bad_inds) = [];
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
%             obj.camera_info(~ind,:) = [];
%             obj.camNames(~ind) = [];
%             obj.camPVs(~ind) = [];
%             obj.regions(~ind) = [];
%             obj.camTrigs(~ind) = [];
%             obj.camPower(~ind) = [];
%             obj.siocs(~ind) = [];

            obj.DAQ_Cams.camera_info = obj.camera_info(ind,:);
            obj.DAQ_Cams.camNames = obj.camNames(ind);
            obj.DAQ_Cams.camPVs = obj.camPVs(ind);
            obj.DAQ_Cams.regions = obj.regions(ind);
            obj.DAQ_Cams.camTrigs = obj.camTrigs(ind);
            obj.DAQ_Cams.camPower = obj.camPower(ind);
            obj.DAQ_Cams.siocs = obj.siocs(ind);


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
