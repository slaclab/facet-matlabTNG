classdef async_data < handle
  events
    PVUpdated 
  end
  properties
      DataRate = 1 % 1 Hz
  end
  
  properties(SetAccess=private,Transient)
    
    pvlist
    pvs
    bufflist
    nPV
    interpData
    
  end
  properties(Access=private)
    is_shutdown logical = false
    to % Running timer object
  end
  
  methods
    function obj = async_data(nonBSA_list)
      
      % Generate app pv links
      cntx=PV.Initialize(PVtype.EPICS);
      obj.pvlist = PV.empty;
      obj.bufflist = BufferData.empty;
      obj.nPV = numel(nonBSA_list);
      for i = 1:obj.nPV
          obj.pvlist(end+1) = PV(cntx,'Name',strrep(nonBSA_list{i},':','_'),'pvname',nonBSA_list{i},'monitor',true);
          obj.bufflist(end+1) = BufferData('Name',strrep(nonBSA_list{i},':','_'),'DataPV',obj.pvlist(end),'MaxDataRate',obj.DataRate,'Enable',0);
      end
      obj.pvs=struct(obj.pvlist);
      
    end
    
    function interpolate(obj,time)
        
        if ~strcmp(obj.bufflist(2).Name,"PATT_SYS1_1_SEC") || ~strcmp(obj.bufflist(3).Name,"PATT_SYS1_1_NSEC")
            error('Cannot interpolate without SLAC timing data');
        elseif numel(obj.bufflist(2).DataRaw.Data) > 0 && numel(obj.bufflist(3).DataRaw.Data) > 0
            buff_zero = obj.bufflist(2).DataRaw.Data(1) + obj.bufflist(3).DataRaw.Data(1)/1e9;
            ts_zero = obj.bufflist(2).DataRaw.Time(1);
            delta = ts_zero(1) - buff_zero(1);
            bsa_time = time + delta;
        else
            for i = 1:obj.nPV
                caget(obj.bufflist(i).DataPV);
                obj.bufflist(i).DataUpdate();
            end
        end
        
        obj.interpData = struct();
        
        for i = 1:obj.nPV
            
            if numel(obj.bufflist(i).DataRaw.Data) == 0
                caget(obj.bufflist(i).DataPV);
                obj.bufflist(i).DataUpdate();
                vals = obj.bufflist(i).DataRaw.Data(1)*ones(size(time));
                obj.interpData.(obj.bufflist(i).Name) = vals;
            elseif numel(obj.bufflist(i).DataRaw.Data) == 1
                vals = obj.bufflist(i).DataRaw.Data(1)*ones(size(time));
                obj.interpData.(obj.bufflist(i).Name) = vals;
            else
                vals = interp1(obj.bufflist(i).DataRaw.Time,obj.bufflist(i).DataRaw.Data,bsa_time,'nearest','extrap');
                obj.interpData.(obj.bufflist(i).Name) = vals;
            end
            
        end
        
    end
        
    
    function enable(obj)
        
        for i = 1:numel(obj.bufflist)
            obj.bufflist(i).Enable = 1;
        end
    end
    
    function disable(obj)
        
        for i = 1:numel(obj.bufflist)
            obj.bufflist(i).Enable = 0;
        end
    end
    
    function flush(obj)
        
        for i = 1:numel(obj.bufflist)
            obj.bufflist(i).Enable = 0;
            obj.bufflist(i).flush();
        end
        
    end
    
    function shutdown(obj)
        
        for i = 1:numel(obj.bufflist)
            obj.bufflist(i).shutdown();
        end
        
    end
    
  end
  
end
          
          
          
          
        