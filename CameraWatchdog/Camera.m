classdef Camera < handle
    
    events
        PVUpdated % PV object list notifies this event after each set of monitored PVs have finished updating
    end
    
    properties
        CameraPV
        POE_PV
        Name
        pvlist PV
        pvs
        PreviousState
        RebootAttempted logical = false
        stopFcnCalled logical = false
        CamLocation
    end
    properties(Hidden)
        listeners
    end
    
    methods
        function cameraInstance = Camera(camPV)    % Constructor fcn
            cameraInstance.CameraPV = camPV;
            POE_PV = lcaGet([camPV ':POE']);
            cameraInstance.POE_PV = POE_PV{1};
            
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
                ];
            
            
            if contains(cameraInstance.POE_PV,'POE')
                cameraInstance.pvlist = [cameraInstance.pvlist;...
                    PV(context,'name',"PortName",'pvname',POE_PV+":Name",'mode',"r",'monitor',true);
                    PV(context,'name',"POE_Off",'pvname',POE_PV+":PowerOff",'mode',"rw",'monitor',true,'pvdatatype',"int");
                    PV(context,'name',"POE_On",'pvname',POE_PV+":PowerOn",'mode',"rw",'monitor',true,'pvdatatype',"int");
                    PV(context,'name',"PowerCycle",'pvname',POE_PV+":HardReset",'mode',"rw",'monitor',true,'pvdatatype',"int");
                    PV(context,'name',"POE_Status",'pvname',POE_PV+":PowerStatus",'mode',"r",'monitor',true);
                    PV(context,'name',"PowerUse",'pvname',POE_PV+":Pwr",'mode',"r",'monitor',true);
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
            
            name = lcaGet([cameraInstance.CameraPV ':NAME']);
            cameraInstance.Name = name{1};
            
            cameraInstance.PreviousState = -1;
            
            cameraInstance.listeners = addlistener(cameraInstance,'PVUpdated',@(~,~) cameraInstance.loop);
            run(cameraInstance.pvlist,false,1,cameraInstance,'PVUpdated');             
        end
        
        function loop(cameraInstance)
            if ~cameraInstance.stopFcnCalled
                cameraInstance.setStatus()
            end
        end
        
        function setStatus(cameraInstance)
            switch cameraInstance.pvs.Connection.val{1}
                case 'Connect'
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
                disp(['Camera ' cameraInstance.Name ' is Connected, Acquiring, Array Rate is nonzero, and Trigger Mode is Sync In 1'])
            end
            
            if cameraInstance.pvs.State.val{1} == 1
                disp(['Camera ' cameraInstance.Name ' is Disconnected. Attempting Reboot.'])
                if cameraInstance.RebootAttempted
                    disp(['Camera ' cameraInstance.Name ' already tried to reboot.'])
                else
%                     caput(cameraInstance.pvs.PowerCycle,1);
                    cameraInstance.RebootAttempted = true;
                end

            end
            
            if cameraInstance.pvs.State.val{1} == 2
                disp(['Camera ' cameraInstance.Name ' is Connected and Acquiring but Array Rate is 0'])
            end
            
            if cameraInstance.pvs.State.val{1} == 3
                disp(['Camera ' cameraInstance.Name ' is Connected but Idle'])
%                 caput(cameraInstance.pvs.Acquisition,'Acquire');
            end
            
            if cameraInstance.pvs.State.val{1} == 4
                disp(['Camera ' cameraInstance.Name ' is Connected, Acquiring, Array Rate is nonzero, but Trigger Mode is Free Run'])
%                 caput(cameraInstance.pvs.TriggerMode,'Sync In 1');
            end
            
            cameraInstance.PreviousState = cameraInstance.pvs.State.val{1};
        end
        
        function stop_PV(cameraInstance)
            cameraInstance.stopFcnCalled = true;
            Cleanup(cameraInstance.pvlist)
            stop(cameraInstance.pvlist);
        end

    end
end