classdef Camera < handle
    
    events
        PVUpdated % PV object list notifies this event after each set of monitored PVs have finished updating
    end
    
    properties
        CameraPV
        POE_PV
        Name = ""
        pvlist PV
        pvs
        PreviousState = -1
        RebootAttempted logical = false
        RebootCount = 0
        Watching logical = false
        CamLocation
        IsSIOCgood logical % Set by CameraWatchdog if SIOC down
        IsPOEHUBgood logical = true % Called by CameraWatchdog if POE Hub down
        Alarm logical = true
        looptime = 3
    end
    properties(Hidden)
        listeners
    end
    
    methods
        function cameraInstance = Camera(camPV,SIOC_Status)
            if exist('SIOC_Status','var')
                cameraInstance.IsSIOCgood = SIOC_Status;
            else
                cameraInstance.IsSIOCgood = true;
            end
            
            cameraInstance.CameraPV = string(camPV);

            if cameraInstance.IsSIOCgood
                POE_PV = string(lcaGet([camPV ':POE']));
                cameraInstance.POE_PV = POE_PV;
                
                context = PV.Initialize(PVtype.EPICS);
                cameraInstance.pvlist=[...
                    PV(context,'name',"NAME",'pvname',camPV+":NAME",'mode',"r",'monitor',true);
                    PV(context,'name',"ArrayRate",'pvname',camPV+":ArrayRate_RBV",'mode',"r",'monitor',true);
                    PV(context,'name',"Acquisition",'pvname',camPV+":Acquisition",'mode',"rw",'monitor',true);
                    PV(context,'name',"Connection",'pvname',camPV+":AsynIO.CNCT",'mode',"r",'monitor',true);
                    PV(context,'name',"TriggerMode",'pvname',camPV+":TriggerMode",'mode',"rw",'monitor',true);
                    PV(context,'name',"TriggerModeRBV",'pvname',camPV+":TriggerMode_RBV",'mode',"rw",'monitor',true);
                    PV(context,'name',"AcquisitionRBV",'pvname',camPV+":Acquire",'mode',"rw",'monitor',true);
                    PV(context,'name',"Exposure",'pvname',camPV+":AcquireTime",'mode',"r",'monitor',true);
                    PV(context,'name',"State",'pvname',camPV+":STATUS",'mode',"rw",'monitor',true,'pvdatatype',"int");
                    PV(context,'name',"DataType",'pvname',camPV+":DataType",'mode',"rw",'monitor',true,'pvdatatype',"int");
                    PV(context,'name',"ROI_EnableCallbacks",'pvname',camPV+":ROI:EnableCallbacks",'mode',"rw",'monitor',true,'pvdatatype',"int");
                    ];

                if contains(cameraInstance.POE_PV,'POE')
                    cameraInstance.pvlist = [cameraInstance.pvlist;...
                        PV(context,'name',"PortName",'pvname',cameraInstance.POE_PV+":Name",'mode',"r",'monitor',true);
                        PV(context,'name',"POE_Off",'pvname',cameraInstance.POE_PV+":PowerOff",'mode',"rw",'monitor',true,'pvdatatype',"int");
                        PV(context,'name',"POE_On",'pvname',cameraInstance.POE_PV+":PowerOn",'mode',"rw",'monitor',true,'pvdatatype',"int");
                        PV(context,'name',"PowerCycle",'pvname',cameraInstance.POE_PV+":HardReset",'mode',"rw",'monitor',true,'pvdatatype',"int");
                        PV(context,'name',"POE_Status",'pvname',cameraInstance.POE_PV+":PowerStatus",'mode',"r",'monitor',true);
                        PV(context,'name',"PowerUse",'pvname',cameraInstance.POE_PV+":Pwr",'mode',"r",'monitor',true);
                        ];
                elseif contains(cameraInstance.POE_PV,'ACSW')
                    cameraInstance.pvlist=[cameraInstance.pvlist;...
                        PV(context,'name',"PortName",'pvname',POE_PV+"NAME",'mode',"r",'monitor',true);
                        PV(context,'name',"POE_Off",'pvname',POE_PV+"POWEROFF",'mode',"rw",'monitor',true,'pvdatatype',"int");
                        PV(context,'name',"POE_On",'pvname',POE_PV+"POWERON",'mode',"rw",'monitor',true,'pvdatatype',"int");
                        PV(context,'name',"PowerCycle",'pvname',POE_PV+"HARDRESET",'mode',"rw",'monitor',true,'pvdatatype',"int");
                        PV(context,'name',"POE_Status",'pvname',POE_PV+"POWERSTATE",'mode',"r",'monitor',true);
                        ];
                end

                pset(cameraInstance.pvlist,'debug',0);
                cameraInstance.pvs = struct(cameraInstance.pvlist);

                cameraInstance.Name = string(caget(cameraInstance.pvs.NAME));
                
                cameraInstance.listeners = addlistener(cameraInstance,'PVUpdated',@(~,~) cameraInstance.loop);
                run(cameraInstance.pvlist,false,cameraInstance.looptime,cameraInstance,'PVUpdated');
            end
                        
            diary('/u1/facet/physics/log/matlab/CameraLog.log');
            fprintf('%s Starting Camera instance for %s.\n',datetime('now'),cameraInstance.Name);
        end
        
        function loop(cameraInstance)
            if cameraInstance.Watching && cameraInstance.IsSIOCgood &&...
                    cameraInstance.IsPOEHUBgood && ~cameraInstance.Alarm
                cameraInstance.setStatus()
            elseif cameraInstance.Watching && cameraInstance.Alarm
                caput(cameraInstance.pvs.State,5);
            end
        end
        
        function setStatus(cameraInstance)
            switch cameraInstance.pvs.Connection.val{1}
                case 'Connect'
                    if cameraInstance.RebootAttempted
                        fprintf('%s Camera %s is recovered.\n',datetime('now'),cameraInstance.Name);
%                         cameraInstance.jiggle();
                    end
                    cameraInstance.RebootAttempted = false;
                    switch cameraInstance.pvs.Acquisition.val{1}
                        case 'Acquire'
                            if cameraInstance.pvs.ArrayRate.val{1} == 0
                                caput(cameraInstance.pvs.State,2);
                            else
                                switch cameraInstance.pvs.TriggerMode.val{1}
                                    case 'Free Run'
                                        caput(cameraInstance.pvs.State,4);
                                    case 'Sync In 1'
                                        caput(cameraInstance.pvs.State,0);
                                end
                            end
                        case 'Idle'
                            caput(cameraInstance.pvs.State,3);
                    end
                case 'Disconnect'
                    caput(cameraInstance.pvs.State,1);
            end
            
            if cameraInstance.PreviousState ~= cameraInstance.pvs.State.val{1}
                cameraInstance.performAction()
            end
        end
        
        function performAction(cameraInstance)
            if cameraInstance.pvs.State.val{1} == 0
                fprintf('%s Camera %s is Connected, Acquiring, Array Rate is nonzero, and Trigger Mode is Sync in 1.\n',datetime('now'),cameraInstance.Name);
            end
            
            if cameraInstance.pvs.State.val{1} == 1
                if cameraInstance.RebootAttempted
                    fprintf('%s Camera %s already tried to reboot.\n',datetime('now'),cameraInstance.Name);
                else
                    fprintf('%s Camera %s is Disconnected. Attempting Reboot.\n',datetime('now'),cameraInstance.Name);
%                     caput(cameraInstance.pvs.PowerCycle,1);
%                     cameraInstance.RebootCount = cameraInstance.RebootCount + 1;
                    cameraInstance.RebootAttempted = true;
                end
            end
            
            if cameraInstance.pvs.State.val{1} == 2
                fprintf('%s Camera %s is Connected and Acquiring but Array Rate is 0.\n',datetime('now'),cameraInstance.Name);
            end
            
            if cameraInstance.pvs.State.val{1} == 3
                fprintf('%s Camera %s is Connected but Idle.\n',datetime('now'),cameraInstance.Name);
%                 caput(cameraInstance.pvs.Acquisition,'Acquire');
            end
            
            if cameraInstance.pvs.State.val{1} == 4
                fprintf('%s Camera %s is Connected, Acquiring, Array Rate is nonzero, but Trigger Mode is Free Run.\n',datetime('now'),cameraInstance.Name);
%                 caput(cameraInstance.pvs.TriggerMode,'Sync In 1');
            end
            
            cameraInstance.PreviousState = cameraInstance.pvs.State.val{1};
        end
        
        function jiggle(cameraInstance)
            caput(cameraInstance.pvs.Acquisition,'Idle');
            pause(0.1);
            caput(cameraInstance.pvs.TriggerMode,'Sync In 1');
            caput(cameraInstance.pvs.DataType,1);
            caput(cameraInstance.pvs.Acquisition,'Acquire');
            exposure = caget(cameraInstance.pvs.Exposure);
            caput(cameraInstance.pvs.Exposure,exposure);
            caput(cameraInstance.pvs.ROI_EnableCallbacks,1);
        end
        
        function updateSIOCstatus(cameraInstance)
            cameraInstance.IsSIOCgood = false;
            cameraInstance.Watching = false;
        end
        
        function updatePOEHUBstatus(cameraInstance)
            cameraInstance.IsPOEHUBgood = false;
            cameraInstance.Watching = false;
            caput(cameraInstance.pvs.State,5);
        end
        
        function stop_PV(cameraInstance)
            cameraInstance.Watching = false;
            
            fprintf('%s Stopping Camera instance for %s.\n',datetime('now'),cameraInstance.Name);
            
            if ~isempty(cameraInstance.pvlist)
                Cleanup(cameraInstance.pvlist);
                stop(cameraInstance.pvlist);
            end
        end

    end
end