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
                PV(context,'name',"SIOC_Alarm",'pvname',SIOC_PV+":HEARTBEATSUM.SEVR",'mode',"r",'monitor',true,'pvdatatype',"int");
                ];
            
            pset(siocInstance.pvlist,'debug',0);
            siocInstance.pvs = struct(siocInstance.pvlist);
                        
            diary('/u1/facet/physics/log/matlab/CameraLog.log');
            fprintf('%s Starting SIOC instance for %s.\n',datetime('now'),siocInstance.PV);
            
            siocInstance.listeners = addlistener(siocInstance,'PVUpdated',@(~,~) siocInstance.loop);
            run(siocInstance.pvlist,false,3,siocInstance,'PVUpdated');
        end
        
        function loop(siocInstance)
            if caget(siocInstance.pvs.SIOC_Alarm) ~= 0
                siocInstance.Alarm = true;
                fprintf('%s SIOC %s is down.\n',datetime('now'),siocInstance.PV);
            else
                siocInstance.Alarm = false;
            end
        end
        
        function stop_PV(siocInstance)            
            fprintf('%s Stopping SIOC instance for %s.\n',datetime('now'),siocInstance.PV);
            
            Cleanup(siocInstance.pvlist);
            stop(siocInstance.pvlist);
        end
    end
end