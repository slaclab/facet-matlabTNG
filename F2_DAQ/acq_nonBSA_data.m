classdef acq_nonBSA_data < handle
    
    properties
        
        base_list
        nonBSA_list
        nonBSA_Array_list
        data
        arrayData
        nPV
        nArrayPV
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
            obj.nonBSA_Array_list = obj.base_list;
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
            obj.data = lcaGetSmart(obj.nonBSA_list,0,'DBF_ENUM');
            obj.nPV = numel(obj.nonBSA_list);
            
        end
        
        function list = addListArray(obj,list)
            
            list = obj.checkList(list);
            obj.nonBSA_Array_list = [obj.nonBSA_Array_list; list];
            obj.arrayData{end+1} = lcaGetSmart(list,0,'DBF_ENUM');
            obj.nArrayPV = numel(obj.nonBSA_Array_list);
            
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
            obj.arrayData = lcaGetSmart(obj.nonBSA_Array_list,0,'DBF_ENUM');
            obj.arrayData = num2cell(obj.arrayData);
            
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
        
        function obj = addArrayData(obj)
            
            try
                % lcaGet returns a matrix that expands to the size of the
                % largest array PV and fills in the scalar PV rows to be
                % Nan
                new_data = lcaGet(obj.nonBSA_Array_list,0,'DBF_ENUM');
            catch
                new_data = nan(size(obj.nonBSA_Array_list));
            end
            base_list_data = new_data(1:3,1);
            base_list_data = num2cell(base_list_data);
            array_pv_data = cell((size(new_data,1)-3),1);
            for i = 4:size(new_data,1)
                array_pv_data{i-3} = new_data(i,:);
            end
            obj.arrayData = [obj.arrayData [base_list_data;array_pv_data]];
                
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
                if any(isnan(non_BSA_times))
                    obj.daq_handle.dispMessage('Warning: Non-BSA time has NaNs.');
                    
                    non_BSA_times = fillmissing(non_BSA_times,'linear',2,'EndValues','nearest');
                    
                    % Special handling for if NaNs land at end of array
                    if any(diff(non_BSA_times)==0)
                        for z=1:(numel(non_BSA_times)-1)
                            if non_BSA_times(z+1) <= non_BSA_times(z)
                                non_BSA_times(z+1) = non_BSA_times(z) + 1e-3;
                            end
                        end
                    end
                end
                for i = 1:obj.nPV
                    %obj.daq_handle.dispMessage('blorf');
                    vals = interp1(non_BSA_times,obj.data(i,:),time,'nearest','extrap');
                    obj.interpData.(pv_names{i}) = vals;
                    %obj.daq_handle.dispMessage('phew');
                end
            end
        end
        
        function interpolateArrays(obj,time)
            
            if ~strcmp(obj.nonBSA_Array_list{2},"PATT:SYS1:1:SEC") || ~strcmp(obj.nonBSA_Array_list{3},"PATT:SYS1:1:NSEC")
                if ~obj.freerun
                    obj.daq_handle.dispMessage('Warning: Cannot get interpolate non-BSA Array data.');
                else
                    warning('Cannot get interpolate non-BSA Array data.');
                end
                return;
                
            end
            
            pv_names = remove_dots(obj.nonBSA_Array_list);
            
            if size(obj.arrayData,2) == 1
                for i = 1:obj.nArrayPV
                    vals = obj.arrayData{i}*ones(size(time));
                    obj.interpData.(pv_names{i}) = vals;
                end
            else
                non_BSA_times = [obj.arrayData{2,:}] + [obj.arrayData{3,:}]/1e9;
                for i = 4:obj.nArrayPV
                    PVdata = obj.arrayData(i,:)';
                    PVdata = cell2mat(PVdata);
                    vals = interp1(non_BSA_times,PVdata,time,'nearest','extrap');
                    vals = num2cell(vals,2);
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