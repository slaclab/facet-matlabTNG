classdef PBDefender < handle
    
    % Plan for PB Defender
    % 1. Use a "config" parameter to do determine valid range for stages
    % 2. Set soft limits based on configuration?
    % 3. Detect invalid requests and stop motor
    % 4. Add an "administrative" wrapper over XPS PVs (new panel)
    % 5. Recovery from unknown state
    % 6. Does Defender set position of stages when config is set
    
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
        target_pos
        current_pos
    end
    properties(Constant)
        enable_PV  = "SIOC:SYS1:ML01:AO910"
        config_PV  = "SIOC:SYS1:ML01:AO911"
        error_PV  = "SIOC:SYS1:ML01:AO912"
        abort_PV  = "SIOC:SYS1:ML01:AO913"
        
        % Target stage horizontal
        target_stage_H_PV = "XPS:LI20:MC05:M2"
        target_stage_H_RBV_PV = "XPS:LI20:MC05:M2.RBV"
        target_stage_H_LLM_PV = "XPS:LI20:MC05:M2.LLM"
        target_stage_H_HLM_PV = "XPS:LI20:MC05:M2.HLM"
        target_stage_H_STAT_PV = "XPS:LI20:MC05:M2.DMOV"
        target_stage_H_STOP_PV = "XPS:LI20:MC05:M2.STOP"
        
        % Target stage vertical
        target_stage_V_PV = "XPS:LI20:MC05:M1"
        target_stage_V_RBV_PV = "XPS:LI20:MC05:M1.RBV"
        target_stage_V_LLM_PV = "XPS:LI20:MC05:M1.LLM"
        target_stage_V_HLM_PV = "XPS:LI20:MC05:M1.HLM"
        target_stage_V_STAT_PV = "XPS:LI20:MC05:M1.DMOV"
        target_stage_V_STOP_PV = "XPS:LI20:MC05:M1.STOP"
        
        tolerance = 0.01
    end
    properties(Hidden)
        listeners
    end
    
    methods
        
        function obj = PBDefender(defender_handle)
            
            obj.defender_handle = defender_handle;
            
            context = PV.Initialize(PVtype.EPICS);
            obj.pvlist=[...
                PV(context,'name',"enable",'pvname',obj.enable_PV,'mode',"rw",'monitor',true); % PB Defender enable/disable
                PV(context,'name',"config",'pvname',obj.config_PV,'mode',"rw",'monitor',true); % Congifuration
                PV(context,'name',"error",'pvname',obj.error_PV,'mode',"rw",'monitor',true); % If error detected
                PV(context,'name',"abort",'pvname',obj.abort_PV,'mode',"rw",'monitor',true); % If abort requested
                
                PV(context,'name',"targetStageH",'pvname',obj.target_stage_H_PV,'mode',"rw",'monitor',true); % Target stage H
                PV(context,'name',"targetStageH_RBV",'pvname',obj.target_stage_H_RBV_PV,'mode',"rw",'monitor',true); % Target stage H
                PV(context,'name',"targetStageH_LLM",'pvname',obj.target_stage_H_LLM_PV,'mode',"rw",'monitor',true); % Target stage H
                PV(context,'name',"targetStageH_HLM",'pvname',obj.target_stage_H_HLM_PV,'mode',"rw",'monitor',true); % Target stage H
                PV(context,'name',"targetStageH_STAT",'pvname',obj.target_stage_H_STAT_PV,'mode',"rw",'monitor',true); % Target stage H
                PV(context,'name',"targetStageH_STOP",'pvname',obj.target_stage_H_STAT_PV,'mode',"rw",'monitor',true); % Target stage H
                
                PV(context,'name',"targetStageV",'pvname',obj.target_stage_V_PV,'mode',"rw",'monitor',true); % Target stage V
                PV(context,'name',"targetStageV_RBV",'pvname',obj.target_stage_V_RBV_PV,'mode',"rw",'monitor',true); % Target stage V
                PV(context,'name',"targetStageV_LLM",'pvname',obj.target_stage_V_LLM_PV,'mode',"rw",'monitor',true); % Target stage V
                PV(context,'name',"targetStageV_HLM",'pvname',obj.target_stage_V_HLM_PV,'mode',"rw",'monitor',true); % Target stage V
                PV(context,'name',"targetStageV_STAT",'pvname',obj.target_stage_V_STAT_PV,'mode',"rw",'monitor',true); % Target stage V
                PV(context,'name',"targetStageV_STOP",'pvname',obj.target_stage_V_STAT_PV,'mode',"rw",'monitor',true); % Target stage V
                ];
            
            pset(obj.pvlist,'debug',0);
            obj.pvs = struct(obj.pvlist);
            
            obj.enable = caget(obj.pvs.enable);
            obj.config = caget(obj.pvs.config);
            
            obj.config_status = 'IDLE';
            obj.motion_status = 'IDLE';
            
            obj.config_queue = {};
            obj.motion_queue = {};
                                    
        end
        
        function set_config(obj)
            
            switch obj.config
                case 0 % Remove
                    obj.config_status = 'CONFIG_CHANGE';
                    obj.config_queue = [obj.config_queue; 'obj.remove()';];
                    
                case 1 % Solid Target
                    obj.config_status = 'CONFIG_CHANGE';
                    obj.config_queue = [obj.config_queue; 'obj.solidTarget()';];
                    
                case 2 % Target corner
                    disp("Target corner")
                    %caput(obj.pvlist(5),0); % Limits horizontal range to 0 (left edge of 92/122 targets) and 150 (right edge of target mount)
                    %caput(obj.pvlist(6),75); % Limits horizontal range to 75 (left edge of 92/122 targets) and 150 (right edge of target mount)
                    %caput(obj.pvlist(9),50); % Limits vertical range to 0 (left edge of 92/122 targets) and 150 (right edge of target mount)
                    %caput(obj.pvlist(10),100); % Limits verical range to 75 (left edge of 92/122 targets) and 150 (right edge of target mount)
                case 3 % Target gas jet
                    disp("Target gas jet")
                    %caput(obj.pvlist(5),0); % Limits horizontal range to 0 (left edge of 92/122 targets) and 150 (right edge of target mount)
                    %caput(obj.pvlist(6),75); % Limits horizontal range to 75 (left edge of 92/122 targets) and 150 (right edge of target mount)
                    %caput(obj.pvlist(9),50); % Limits vertical range to 0 (left edge of 92/122 targets) and 150 (right edge of target mount)
                    %caput(obj.pvlist(10),65); % Limits verical range to 75 (left edge of 92/122 targets) and 150 (right edge of target mount)
            end
        end
        
        function remove(obj)
            disp("Removing target stages to out position: H=0, V=80.");
            
            new_queue = {% Allow stage to move in vertical direction
                         'obj.setSoftLimits([obj.pvs.targetStageV_LLM,obj.pvs.targetStageV_HLM],[0,100])';
                         % Set stage vertical to out=80
                         'obj.move(obj.pvs.targetStageV,obj.pvs.targetStageV_RBV,80)';
                         % Allow stage to move in horizontal direction
                         'obj.setSoftLimits([obj.pvs.targetStageH_LLM,obj.pvs.targetStageH_HLM],[0,150])';
                         % Set stage horizontal to out=0
                         'obj.move(obj.pvs.targetStageH,targetStageH_RBV,0)';
                         % Restrict stage motion
                         'obj.setSoftLimits([obj.pvs.targetStageV_LLM,obj.pvs.targetStageV_HLM,obj.pvs.targetStageH_LLM,obj.pvs.targetStageH_HLM],[0,1,79,81])';
                         };
            %obj.motion_queue = [obj.motion_queue; new_queue];
            obj.motion_queue = new_queue;
        end
        
        function solidTarget(obj)
            disp("Setting stages to solid target position: H=150, V=75.");
            
            new_queue = {% Allow stage to move in vertical direction
                         'obj.setSoftLimits([obj.pvs.targetStageV_LLM,obj.pvs.targetStageV_HLM],[0,100])';
                         % Set stage vertical to in=75
                         'obj.move(obj.pvs.targetStageV,obj.pvs.targetStageV_RBV,75)';
                         % Allow stage to move in horizontal direction
                         'obj.setSoftLimits([obj.pvs.targetStageH_LLM,obj.pvs.targetStageH_HLM],[0,150])';
                         % Set stage horizontal to in=150
                         'obj.move(obj.pvs.targetStageH,obj.pvs.targetStageH_RBV,150)';
                         % Restrict stage motion
                         'obj.setSoftLimits([obj.pvs.targetStageV_LLM,obj.pvs.targetStageV_HLM,obj.pvs.targetStageH_LLM,obj.pvs.targetStageH_HLM],[75,150,0,100])';
                         };
            %obj.motion_queue = [obj.motion_queue; new_queue];
            obj.motion_queue = new_queue;
        end
            
        
        function setSoftLimits(pvs_lims,values)
            for i = 1:numel(pvs_lims)
                caput(pv_lim(i),values(i));
            end
        end
        
        function move(obj,pv_set,pv_rbv,target_pos)
            obj.motion_status = "MOVING";
            obj.pv_set = pv_set;
            obj.pv_rbv = pv_rbv;
            obj.target_pos = target_pos;
            obj.current_pos = caget(obj.pv_rbv);
            caput(obj.pv_set,target_pos);
        end
        
        function check_status(obj)
            
            % Status ERROR must be cleared by hand 
            if strcmp(obj.motion_status,"ERROR")
                if obj.pvs.error.val{1} == 0
                    disp("Error status cleared");
                    obj.motion_status = "IDLE";
                else
                    return;
                end
            end
            
            % Check if there is a request to change config
            if obj.pvs.config.val{1} ~= obj.config
                obj.config = obj.pvs.config;
                obj.set_config();
            end
            
            % Check if config change currently underway
            if strcmp(obj.config_status,"IDLE")
                if ~isempty(obj.config_queue)
                    feval(obj.config_queue{1});
                    obj.config_queue{1} = []; % remove request from queue
                end
            end
            
            % If no motors moving, Defender can work through motion queue
            if strcmp(obj.motion_status,"IDLE")
                if ~isempty(obj.motion_queue)
                    feval(obj.motion_queue{1});
                    obj.motion_queue{1} = []; % remove request from queue
                    if isempty(obj.motion_queue)
                        obj.config_status = "IDLE";
                    end
                end
            end
            
            % Check if motion complete
            if strcmp(obj.motion_status,"MOVING")
                obj.current_pos = caget(obj.pv_rbv);
                if abs(obj.current_pos - obj.target_pos) < obj.tolerance
                    obj.motion_status = "IDLE";
                end
            end
            
            % Check if anything is moving that shouldn't be
            if obj.pvs.targetStageH_STAT == 0 && obj.pv_set ~= obj.pvs.targetStageH
                caput(obj.pvs.targetStageH_STOP,1);
                caput(obj.pvs.error,1);
                obj.motion_status = "ERROR";
            end
            if obj.pvs.targetStageV_STAT == 0 && obj.pv_set ~= obj.pvs.targetStageV
                caput(obj.pvs.targetStageV_STOP,1);
                caput(obj.pvs.error,1);
                obj.motion_status = "ERROR";
            end
        end
        
    end
    
end
            
            
            
        