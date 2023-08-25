classdef POE_Hub < handle
    events
        PVUpdated % PV object list notifies this event after each set of monitored PVs have finished updating
    end
    
    properties
        pvlist PV
        pvs
        PV
        PowerSwitchPV
        Alarm logical = false
    end
    properties(Hidden)
        listeners
    end
    
    methods
        function poeHubInstance = POE_Hub(POE_PV)
            poeHubInstance.PV = POE_PV;
            
            switch POE_PV
                case "POE:LI20:1"
                    poeHubInstance.PowerSwitchPV = "ACSW:LI20:NW13:24HARDRESET";
                case "POE:LI20:2"
                    poeHubInstance.PowerSwitchPV = "ACSW:LI20:NW13:23HARDRESET";
                case "POE:LI20:3"
                    poeHubInstance.PowerSwitchPV = "ACSW:LI20:NW19:1HARDRESET";
                case "POE:LI10:1"
                    poeHubInstance.PowerSwitchPV = "ACSW:LI10:NW02:1HARDRESET";
                case "POE:LA10:1"
                    poeHubInstance.PowerSwitchPV = "ACSW:LR10:LS03:8HARDRESET";
                otherwise
                    % nothing
            end
            
            context = PV.Initialize(PVtype.EPICS);
            
            poeHubInstance.pvlist = [...
                PV(context,'name',"POE_Identity",'pvname',POE_PV+":Identity",'mode',"r",'monitor',true,'pvdatatype',"int",'alarm',1);
                PV(context,'name',"Reboot",'pvname',poeHubInstance.PowerSwitchPV,'mode',"r",'monitor',true,'pvdatatype',"int");
                ];
            
            pset(poeHubInstance.pvlist,'debug',0);
            poeHubInstance.pvs = struct(poeHubInstance.pvlist);
            
            % Call Identity PV once to make sure alarm field is not empty
            getAlarm = caget(poeHubInstance.pvs.POE_Identity);
                        
%             diaryLogFn = "/u1/facet/physics/log/matlab/CameraLog" + string(datetime('now','Format',"uuuu-MM-dd")) + ".log";
%             diary(diaryLogFn);
            fprintf('%s Starting POE Hub instance for %s.\n',datetime('now'),poeHubInstance.PV);
            
            poeHubInstance.listeners = addlistener(poeHubInstance,'PVUpdated',@(~,~) poeHubInstance.loop);
            run(poeHubInstance.pvlist,false,3,poeHubInstance,'PVUpdated');
        end
        
        function loop(poeHubInstance)
            if strcmp(poeHubInstance.pvs.POE_Identity.SEVR{1},"NO_ALARM")
                poeHubInstance.Alarm = false;
            else
                poeHubInstance.Alarm = true;
%                 poeHubInstance.rebootPOEHub();
                fprintf('%s POE Hub %s is down.\n',datetime('now'),poeHubInstance.PV);
            end
        end
        
        function rebootPOEHub(poeHubInstance)
            caput(poeHubInstance.pvs.Reboot,1)
        end
        
        function stop_PV(poeHubInstance)            
            fprintf('%s Stopping POE Hub instance for %s.\n',datetime('now'),poeHubInstance.PV);
            
            Cleanup(poeHubInstance.pvlist);
            stop(poeHubInstance.pvlist);
        end
    end
end