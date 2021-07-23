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
      for i = 1:numel(nonBSA_list)
          obj.pvlist(end+1) = PV(cntx,'Name',strrep(nonBSA_list{i},':','_'),'pvname',nonBSA_list{i},'monitor',true);
          obj.bufflist(end+1) = BufferData('Name',strrep(nonBSA_list{i},':','_'),'DataPV',obj.pvlist(end),'MaxDataRate',obj.DataRate,'Enable',0);
      end
      obj.pvs=struct(obj.pvlist);
      
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
          
          
          
          
        