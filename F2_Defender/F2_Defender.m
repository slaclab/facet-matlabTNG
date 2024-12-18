classdef F2_Defender < handle
    events
        PVUpdated
    end
    properties
        pvlist PV
        pvs
        Instance
        Heartbeat
        Disable
        
        PBDefender
        LaserDefender
        PicoDefender
        CameraDefender
	DumpDefender
    end
    properties(Hidden)
        listeners
    end
    properties(Constant)
        maxbeat=1e7 % max heartbeat count, wrap to zero
    end
    
    methods
        function obj = F2_Defender()
            
            context = PV.Initialize(PVtype.EPICS);
            obj.pvlist=[...
                PV(context,'name',"Heartbeat",'pvname',"SIOC:SYS1:ML01:AO901",'mode',"rw",'monitor',true); % Defender heartbeat
                PV(context,'name',"Instance",'pvname',"SIOC:SYS1:ML01:AO902",'mode',"rw",'monitor',true); % Defender instance
                PV(context,'name',"Disable",'pvname',"SIOC:SYS1:ML01:AO903",'mode',"rw",'monitor',true); % Defender disable
                ];
            
            pset(obj.pvlist,'debug',0);
            obj.pvs = struct(obj.pvlist);
            
            inst = caget(obj.pvs.Instance);
            obj.Instance = inst+1;
            caput(obj.pvs.Instance,obj.Instance);
            
            obj.Heartbeat = caget(obj.pvs.Heartbeat);
            obj.Disable = caget(obj.pvs.Disable);
            
            obj.PBDefender = PBDefender(obj);
            %obj.LaserDefender = LaserDefender(obj);
            %obj.PicoDefender = PicoDefender(obj);
            %obj.CameraDefender = CameraDefender(obj);
            obj.DumpDefender = DumpDender(obj); 
            obj.listeners = addlistener(obj,'PVUpdated',@(~,~) obj.defender_loop);
            run(obj.pvlist,false,1,obj,'PVUpdated');
            
            diary('/u1/facet/physics/log/matlab/F2_Defender.log');
            
            fprintf('%s (F2_Defender) Started FACET Defender instance %d.\n',datestr(now),obj.Instance);
            
        end
        
        function defender_loop(obj)
            
            % Update heartbeat whether or not Defender Enabled/Disabled
            obj.Heartbeat = obj.pvs.Heartbeat + 1;
            caput(obj.pvs.Heartbeat,obj.Heartbeat);
            
            if obj.pvs.Disable
                obj.Disable = 1;
                fprintf('%s (F2_Defender) Defender disabled.\n',datestr(now),obj.Instance);
                return
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            %     Main Loop Body      %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            obj.PBDefender.check_status();
            %obj.LaserDefender.check_status();
            %obj.PicoDefender.check_status();
            %obj.CameraDefender.check_status();
            obj.DumpDefender.check_status(); 
        end
        
    end
    
end
