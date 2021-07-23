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
            obj.getLiveNames();
            
        end
        
        function remove_transport(obj)
        % Remove laser transport cameras because they dont have triggers
            trnspt_cams = strcmp(obj.camera_info(:,4),'S20 Transprt');
            obj.camera_info(trnspt_cams,:) = [];
            
        end
        
        function add_SIOCs(obj)
            
            obj.sioc_list = {'cpu-lr10-ls01',       'SIOC:LR10:LS01';
                             'cpu-in10-pm01',       'SIOC:IN10:PM01';
                             'cpu-in10-ls01',       'SIOC:IN10:LS01';
                             'cpu-li10-pm01',       'SIOC:LI10:PM01';
                             'cpu-li14-pm01',       'SIOC:LI14:PM01';
                             'cpu-li15-pm01',       'SIOC:LI15:PM01';
                             'cpu-li20-pm01',       'SIOC:LI20:PM01';
                             'cpu-li20-pm02',       'SIOC:LI20:PM02';
                             'cpu-li20-pm03',       'SIOC:LI20:PM03';
                             'cpu-li20-pm04',       'SIOC:LI20:PM04';
                             'facet-li20-pm02',     'SIOC:LI20:PM21';
                             'facet-li20-pm03',     'SIOC:LI20:PM22';
                             'facet-li20-pm04',     'SIOC:LI20:PM23';
                             'facet-b244-cs01',     'SIOC:LI20:CS01';
                             'facet-b244-cs02',     'SIOC:LI20:CS02';
                             'facet-b244-cs03',     'SIOC:LI20:CS03';
                             };
            
            obj.siocs = cell(size(obj.camera_info(:,5)));
            for i = 1:numel(obj.camera_info(:,5))
                ind = strcmp(obj.sioc_list(:,1),obj.camera_info{i,5});
                obj.siocs{i} = obj.sioc_list{ind,2};                
            end
                         
        end
        
        function checkIOCs(obj)
            
            for i = 1:numel(obj.siocs)
                status = lcaGet([obj.siocs{i} ':HEARTBEATSUM'],0,'DBF_ENUM');
                if status ~= 0
                    obj.dispMessage(['Warning: IOC ' obj.siocs{i} ' serving camera ' obj.camNames{i} ' is down.']);
                    if obj.DAQ_bool
                        obj.dispMessage(['Removing camera ' obj.camNames{i} ' from DAQ.']);
                        obj.camera_info(i,:) = [];
                        obj.camNames(i) = [];
                        obj.camPVs(i) = [];
                        obj.regions(i) = [];
                        obj.camTrigs(i) = [];
                        obj.camPower(i) = [];
                        obj.siocs(i) = [];
                    end
                end
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
                        
        
        function dispMessage(obj,message)
            if obj.freerun
                disp(message);
            else
                obj.objhan.addMessage(message);
            end
        end
        
    end
    
end