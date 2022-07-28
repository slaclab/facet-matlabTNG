classdef acq_nonBSA_data < handle
    
    properties
        
        nonBSA_list
        data
        nPV
        interpData
        daq_handle
        PID
        freerun = true
        
    end
    
    methods
        function obj = acq_nonBSA_data(nonBSA_list,daq_handle)
            
            if exist('daq_handle','var')
                obj.daq_handle = daq_handle;
                obj.freerun = false;
            end
            
            obj.nonBSA_list = nonBSA_list;
            obj.nPV = numel(nonBSA_list);
            
            
            lcaSetTimeout(0.1);
            lcaSetRetryCount(3);
            
            obj.initGet();
            obj.PID = 0;
            
        end
        
        function obj = initGet(obj)
            
            init_data = lcaGetSmart(obj.nonBSA_list,0,'DBF_ENUM');
            rm_ind = [];
            for i = 1:obj.nPV
                if isempty(init_data(i)) || isnan(init_data(i))
                    if ~obj.freerun
                        obj.daq_handle.dispMessage(['Warning: Cannot get PV ' obj.nonBSA_list{i} '. Removing from list.']);
                    else
                        warning(['Warning: Cannot get PV ' obj.nonBSA_list{i} '. Removing from list.']);
                    end
                    rm_ind = [rm_ind; i];
                    continue;
                end
                
                
            end
            obj.nonBSA_list(rm_ind) = [];
            
            obj.data = init_data;
            
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