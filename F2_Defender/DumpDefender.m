classdef DumpDefender < handle
    
    events 
        PVUpdated
    end
    properties
        pvlist PV
        pvs
        defender_handle
        
        enable
        config
        
        config_status
        motion_status
        
        config_queue
        motion_queue
        
        pv_set
        pv_rbv
        pvs_lims
        old_target_pos
        target_pos
        current_pos
        defender_llm = 0
        defender_hlm = 150
    end
    properties(Constant)
        enable_PV  = "SIOC:SYS1:ML01:AO910"
        config_PV  = "SIOC:SYS1:ML01:AO911"
        error_PV  = "SIOC:SYS1:ML01:AO912"
        abort_PV  = "SIOC:SYS1:ML01:AO913"
        
        % LFOV vertical
        defender_stage_V_PV = "SIOC:SYS1:ML01:AO919"
        target_stage_V_PV = "XPS:LI20:MC01:M6"
        target_stage_V_RBV_PV = "XPS:LI20:MC01:M6.RBV"
        target_stage_V_LLM_PV = "XPS:LI20:MC01:M6.LLM"
        target_stage_V_HLM_PV = "XPS:LI20:MC01:M6.HLM"
        target_stage_V_STAT_PV = "XPS:LI20:MC01:M6.DMOV"
        target_stage_V_STOP_PV = "XPS:LI20:MC01:M6.STOP"
        
        % DTOTR_X
        defender_stage_V_PV = "SIOC:SYS1:ML01:AO920"
        target_stage_V_PV = "XPS:LI20:MC01:M6"
        target_stage_V_RBV_PV = "XPS:LI20:MC01:M6.RBV"
        target_stage_V_LLM_PV = "XPS:LI20:MC01:M6.LLM"
        target_stage_V_HLM_PV = "XPS:LI20:MC01:M6.HLM"
        target_stage_V_STAT_PV = "XPS:LI20:MC01:M6.DMOV"
        target_stage_V_STOP_PV = "XPS:LI20:MC01:M6.STOP"
        
        tolerance = 0.01
    end
    properties(Hidden)
        listeners
    end
    
    methods
        
        function obj = DumpDefender(defender_handle)
            
            obj.defender_handle = defender_handle;
            
            context = PV.Initialize(PVtype.EPICS);
            obj.pvlist=[...
                PV(context,'name',"enable",'pvname',obj.enable_PV,'mode',"rw",'monitor',true); % PB Defender enable/disable
                PV(context,'name',"config",'pvname',obj.config_PV,'mode',"rw",'monitor',true); % Congifuration
                PV(context,'name',"error",'pvname',obj.error_PV,'mode',"rw",'monitor',true); % If error detected
                PV(context,'name',"abort",'pvname',obj.abort_PV,'mode',"rw",'monitor',true); % If abort requested
                
                PV(context,'name',"defenderStageV",'pvname',obj.defender_stage_V_PV,'mode',"rw",'monitor',true); % Defender stage V
                PV(context,'name',"targetStageV",'pvname',obj.target_stage_V_PV,'mode',"rw",'monitor',true); % Target stage V
                PV(context,'name',"targetStageV_RBV",'pvname',obj.target_stage_V_RBV_PV,'mode',"r",'monitor',true); % Target stage V
                PV(context,'name',"targetStageV_LLM",'pvname',obj.target_stage_V_LLM_PV,'mode',"rw",'monitor',true); % Target stage V
                PV(context,'name',"targetStageV_HLM",'pvname',obj.target_stage_V_HLM_PV,'mode',"rw",'monitor',true); % Target stage V
                PV(context,'name',"targetStageV_STAT",'pvname',obj.target_stage_V_STAT_PV,'mode',"r",'monitor',true); % Target stage V
                PV(context,'name',"targetStageV_STOP",'pvname',obj.target_stage_V_STOP_PV,'mode',"rw",'monitor',true); % Target stage V
                ];
            
            pset(obj.pvlist,'debug',0);
            obj.pvs = struct(obj.pvlist);
            
            obj.enable = caget(obj.pvs.enable);
            obj.config = caget(obj.pvs.config);
            
            current_stage_val = caget(obj.pvs.targetStageV);
            caput(obj.pvs.defenderStageV,current_stage_val);
            obj.old_target_pos = current_stage_val;
            caget(obj.pvs.targetStageV_STAT);
            
            obj.config_status = 'IDLE';
            obj.motion_status = 'IDLE';
            
            obj.config_queue = {};
            obj.motion_queue = {};
            
            %addlistener(obj,'PVUpdated',@(~,~) obj.check_status) ;
            %run(obj.pvlist,false,1,obj,'PVUpdated');
                                    
        end

        
        function move(obj,pv_set,pv_rbv,target_pos)
            obj.motion_status = "MOVING";
            obj.pv_set = pv_set;
            obj.pv_rbv = pv_rbv;
            obj.target_pos = target_pos;
            obj.current_pos = caget(obj.pv_rbv);
            caput(obj.pv_set,target_pos);
        end
        
        function setSoftLimits(obj,pvs_lims,values)
            obj.pvs_lims = pvs_lims;
            for i = 1:numel(pvs_lims)
                caput(pvs_lims(i),values(i));
            end
        end
        
        function setMotorPos(obj)
            disp("defender pv changed");
            if obj.target_pos < obj.defender_hlm && obj.target_pos > obj.defender_llm
                disp("valid range for pv");
                if obj.target_pos < obj.old_target_pos
                    new_queue = {% Change Low Limit
                        'obj.setSoftLimits(obj.pvs.targetStageV_LLM,obj.pvs.defenderStageV.val{1}-obj.tolerance)';
                        % Move stage
                        'obj.move(obj.pvs.targetStageV,obj.pvs.targetStageV_RBV,obj.pvs.defenderStageV.val{1})';
                        % Change High Limit
                        'obj.setSoftLimits(obj.pvs.targetStageV_HLM,obj.pvs.defenderStageV.val{1}+obj.tolerance)';
                        };
                end
                if obj.target_pos > obj.old_target_pos
                    new_queue = {% Change High Limit
                        'obj.setSoftLimits(obj.pvs.targetStageV_HLM,obj.pvs.defenderStageV.val{1}+obj.tolerance)';
                        % Move stage
                        'obj.move(obj.pvs.targetStageV,obj.pvs.targetStageV_RBV,obj.pvs.defenderStageV.val{1})';
                        % Change Low Limit
                        'obj.setSoftLimits(obj.pvs.targetStageV_LLM,obj.pvs.defenderStageV.val{1}-obj.tolerance)';
                        };
                end
                obj.motion_queue = [obj.motion_queue; new_queue];
            else
                disp("invalid range for pv");
                caput(obj.pvs.defenderStageV,obj.old_target_pos);
            end
        end
        
        function check_status(obj)
            
            obj.old_target_pos = obj.pvs.defenderStageV.val{1};
            obj.target_pos = caget(obj.pvs.defenderStageV);
            
%             % STAT = 0 mean moving, if pv_set ~= currently_moving_pv,
%             % that's bad
%             if obj.pvs.targetStageV_STAT.val{1} == 0 && ~any(obj.pv_set ~= obj.pvs.targetStageV)
%                 disp('oh no!');
%                 caput(obj.pvs.targetStageV_STOP,1);
%                 caput(obj.pvs.error,1);
%                 obj.motion_status = "ERROR";
%             end
            
            % Status ERROR must be cleared by hand 
            if strcmp(obj.motion_status,"ERROR")
                if obj.pvs.error.val{1} == 0
                    disp("Error status cleared");
                    obj.motion_status = "IDLE";
                else
                    return;
                end
            end
            
            % Check if defenderStage has changed
            if obj.old_target_pos ~= obj.target_pos
                obj.setMotorPos;
            end
            
            % If no motors moving, Defender can work through motion queue
            if strcmp(obj.motion_status,"IDLE")
                if ~isempty(obj.motion_queue)      
                    eval(obj.motion_queue{1});
                    obj.motion_queue{1} = []; % remove request from queue
                    obj.motion_queue = obj.motion_queue(~cellfun('isempty',obj.motion_queue));
                    if isempty(obj.motion_queue)
                        obj.config_status = "IDLE";
                    end
                end
            end
            
            % Check if motion complete
            if strcmp(obj.motion_status,"MOVING")
                obj.current_pos = caget(obj.pv_rbv);
                disp(obj.current_pos);
                if abs(obj.current_pos - obj.target_pos) < obj.tolerance
                    obj.motion_status = "IDLE";
                    obj.pv_set = [];
                    obj.pv_rbv = [];
                end
            end
            
            
%             % Check if anything is moving that shouldn't be
%             if obj.pvs.targetStageH_STAT == 0 && obj.pv_set ~= obj.pvs.targetStageH
%                 caput(obj.pvs.targetStageH_STOP,1);
%                 caput(obj.pvs.error,1);
%                 obj.motion_status = "ERROR";
%             end

            
        end
        
    end
    
end
            
            
            
        