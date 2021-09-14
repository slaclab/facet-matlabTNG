classdef XPS_stage < handle
    
    events 
        PVUpdated
    end
    properties
        pvlist PV
        pvs
        
        target_pos
        old_target_pos
        current_pos
        motion_status
        tolerance
    end
   
    properties(Hidden)
        listeners
    end
    
    methods
        
        function obj = XPS_stage(defender_PV,xps_PV,tol)
            
            context = PV.Initialize(PVtype.EPICS);
            obj.pvlist=[                
                PV(context,'name',"defenderStage",'pvname',defender_PV,'mode',"rw",'monitor',true); % Defender stage V
                PV(context,'name',"xpsStage",'pvname',xps_PV,'mode',"rw",'monitor',true); % Target stage V
                PV(context,'name',"xpsStage_RBV",'pvname',[xps_PV '.RBV'],'mode',"r",'monitor',true); % Target stage V
                PV(context,'name',"xpsStage_LLM",'pvname',[xps_PV '.LLM'],'mode',"rw",'monitor',true); % Target stage V
                PV(context,'name',"xpsStage_HLM",'pvname',[xps_PV '.HLM'],'mode',"rw",'monitor',true); % Target stage V
                PV(context,'name',"xpsStage_STAT",'pvname',[xps_PV '.DMOV'],'mode',"r",'monitor',true); % Target stage V
                PV(context,'name',"xpsStage_STOP",'pvname',[xps_PV '.STOP'],'mode',"rw",'monitor',true); % Target stage V
                ];
            
            obj.tolerance = tol;
            pset(obj.pvlist,'debug',0);
            obj.pvs = struct(obj.pvlist);
            
            current_stage_val = caget(obj.pvs.xpsStage);
            caput(obj.pvs.defenderStage,current_stage_val);
            obj.old_target_pos = current_stage_val;
            
            caget(obj.pvs.xpsStage_RBV);
            caget(obj.pvs.xpsStage_LLM);
            caget(obj.pvs.xpsStage_HLM);
            caget(obj.pvs.xpsStage_STAT);
            caget(obj.pvs.xpsStage_STOP);
        end

        
        function move(obj,target_pos)
            obj.motion_status = "MOVING";
            obj.target_pos = target_pos;
            obj.current_pos = caget(obj.pvs.xpsStage_RBV);
            caput(obj.pvs.xpsStage,target_pos);
        end
        
        function setLowLimit(obj,value)
            caput(obj.pvs.xpsStage_LLM,value);
        end
        
        function setHighLimit(obj,value)
            caput(obj.pvs.xpsStage_HLM,value);
        end
       
        function stop(obj)
            caput(obj.pvs.xpsStage_STOP,1);
        end
        
        function current_pos = check_pos(obj)
            current_pos = caget(obj.pvs.xpsStage_RBV);
            obj.current_pos = current_pos;
        end
        
        function status = check_status(obj)
            status = caget(obj.pvs.xpsStage_STAT);
        end
    end
    
end

% In dump defender, put the different motors in properties, initialize each
% motor under DumpDefender function with something like:
% dtotrStage = XPS_stage('SIOC:SYS1:ML01:AO920','XPS:LI20:MC01:M7',0.01)
            
            
        