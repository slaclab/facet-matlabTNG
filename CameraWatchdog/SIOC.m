classdef SIOC < handle
    events
        PVUpdated % PV object list notifies this event after each set of monitored PVs have finished updating
    end
    
    properties
        pvlist PV
        pvs
        PV
        Alarm logical = false
    end
    properties(Hidden)
        listeners
    end
    
    methods
        function siocInstance = SIOC(SIOC_PV)
            siocInstance.PV = SIOC_PV;
            
            context = PV.Initialize(PVtype.EPICS);
            
            siocInstance.pvlist = [...
                PV(context,'name',"SIOC_Heartbeat",'pvname',SIOC_PV+":HEARTBEATSUM",'mode',"r",'monitor',true,'pvdatatype',"int",'alarm',1);
                ];
            
            pset(siocInstance.pvlist,'debug',0);
            siocInstance.pvs = struct(siocInstance.pvlist);
            
            % Call Heartbeat PV once to make sure alarm field is not empty
            getAlarm = caget(siocInstance.pvs.SIOC_Heartbeat);
                        
            diary('/u1/facet/physics/log/matlab/CameraLog.log');
            fprintf('%s Starting SIOC instance for %s.\n',datetime('now'),siocInstance.PV);
            
            siocInstance.listeners = addlistener(siocInstance,'PVUpdated',@(~,~) siocInstance.loop);
            run(siocInstance.pvlist,false,3,siocInstance,'PVUpdated');
        end
        
        function loop(siocInstance)
            if strcmp(siocInstance.pvs.SIOC_Heartbeat.SEVR{1},"NO_ALARM")
                siocInstance.Alarm = false;
            else
                siocInstance.Alarm = true;
                fprintf('%s SIOC %s is down.\n',datetime('now'),siocInstance.PV);
            end
        end
        
        function stop_PV(siocInstance)            
            fprintf('%s Stopping SIOC instance for %s.\n',datetime('now'),siocInstance.PV);
            
            Cleanup(siocInstance.pvlist);
            stop(siocInstance.pvlist);
        end
    end
end