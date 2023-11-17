classdef acq_nonBSA_data < handle
    
    properties
        
        base_list
        nonBSA_list
        data
        nPV
        nBase
        interpData
        daq_handle
        PID
        freerun = true
        
    end
    
    methods
        function obj = acq_nonBSA_data(base_list,daq_handle)
            
            if exist('daq_handle','var')
                obj.daq_handle = daq_handle;
                obj.freerun = false;
            end
            
            lcaSetTimeout(0.1);
            lcaSetRetryCount(3);
            
            % These are some basic PVs that get added every time
            base_list = obj.checkList(base_list);
            obj.base_list = base_list;
            obj.nBase = numel(base_list);
            
            % Copy base list into nonBSA_list
            % More PVs will be added using addList
            obj.nonBSA_list = obj.base_list;
            obj.nPV = obj.nBase;
            
            obj.initGet();
            obj.PID = 0;
            
        end
        
        function list = checkList(obj,list)
            % check if PVs exist/are working
            
            nList = numel(list);
            test_data = lcaGetSmart(list,0,'DBF_ENUM'); % lcaGetSmart will returns NaNs for bad PVs 
            rm_ind = [];
            for i = 1:nList
                if isempty(test_data(i)) || isnan(test_data(i))
                    if ~obj.freerun
                        obj.daq_handle.dispMessage(['Warning: Cannot get PV ' list{i} '. Removing from list.']);
                    else
                        warning(['Warning: Cannot get PV ' list{i} '. Removing from list.']);
                    end
                    rm_ind = [rm_ind; i];
                    continue;
                end 
            end
            list(rm_ind) = [];
        end
        
        function list = addList(obj,list)
            
            list = obj.checkList(list);
            obj.nonBSA_list = [obj.nonBSA_list; list];
            obj.nPV = numel(obj.nonBSA_list);
            
        end
        
        function descs = getDesc(obj,list)
            
            descs = lcaGetSmart(strcat(list,':DESC'));
            
        end
        
        function obj = initGet(obj)
            % Most of the functionality here moved to checkList()
            
%             init_data = lcaGetSmart(obj.nonBSA_list,0,'DBF_ENUM');
%             rm_ind = [];
%             for i = 1:obj.nPV
%                 if isempty(init_data(i)) || isnan(init_data(i))
%                     if ~obj.freerun
%                         obj.daq_handle.dispMessage(['Warning: Cannot get PV ' obj.nonBSA_list{i} '. Removing from list.']);
%                     else
%                         warning(['Warning: Cannot get PV ' obj.nonBSA_list{i} '. Removing from list.']);
%                     end
%                     rm_ind = [rm_ind; i];
%                     continue;
%                 end
%                 
%                 
%             end
%             obj.nonBSA_list(rm_ind) = [];
%             obj.nPV = numel(obj.nonBSA_list);
%             
%             init_data(rm_ind) = [];
            obj.data = lcaGetSmart(obj.nonBSA_list,0,'DBF_ENUM');
            
        end
        
        function obj = addData(obj)
            
            new_data = lcaGetSmart(obj.nonBSA_list,0,'DBF_ENUM');
            obj.data = [obj.data new_data];
            
        end
        
        function obj = addDataFR(obj)
            
            try
                new_data = lcaGet(obj.nonBSA_list,0,'DBF_ENUM');
            catch
                new_data = nan(size(obj.nonBSA_list));
            end
            obj.data = [obj.data new_data];
                
        end
        
        function interpolate(obj,time)
            
            if ~strcmp(obj.nonBSA_list{2},"PATT:SYS1:1:SEC") || ~strcmp(obj.nonBSA_list{3},"PATT:SYS1:1:NSEC")
                if ~obj.freerun
                    obj.daq_handle.dispMessage('Warning: Cannot get interpolate non-BSA data.');
                else
                    warning('Cannot get interpolate non-BSA data.');
                end
                return;
                
            end
            
            pv_names = remove_dots(obj.nonBSA_list);
            
            if size(obj.data,2) == 1
                for i = 1:obj.nPV
                    vals = obj.data(i)*ones(size(time));
                    obj.interpData.(pv_names{i}) = vals;
                end
            else
                non_BSA_times = obj.data(2,:) + obj.data(3,:)/1e9;
                for i = 1:obj.nPV
                    vals = interp1(non_BSA_times,obj.data(i,:),time,'nearest','extrap');
                    obj.interpData.(pv_names{i}) = vals;
                end
            end
        end
        
        function flush(obj)
            obj.data = [];
            obj.interpData = [];
            obj.initGet();
        end
    end
end