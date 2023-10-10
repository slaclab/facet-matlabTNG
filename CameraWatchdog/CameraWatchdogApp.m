classdef CameraWatchdogApp < handle
    events
        PVUpdated
    end
    
    properties
        pvlist PV
        pvs
        CameraObjs Camera
        POEHubs POE_Hub
        SIOCs SIOC
        NameList
        SIOCList
    end
    properties(Hidden)
        listeners
    end
    properties(Constant)
        maxbeat = 1e7 % max heartbeat count, wrap to zero
    end
  
    methods
        function watchdogInstance = CameraWatchdogApp()
            
            context = PV.Initialize(PVtype.EPICS);
            watchdogInstance.pvlist = [...
                PV(context,'name',"Heartbeat",'pvname',"PHYS:SYS1:1:CAMERA",'mode',"rw",'monitor',true,'pvdatatype',"int"); % Watcher heartbeat
                PV(context,'name',"Watchdog",'pvname',"F2:WATCHER:CAMERA_STAT",'mode',"rw",'pvdatatype',"int")]; % Update watcher alive status
                        
            pset(watchdogInstance.pvlist,'debug',0);
            watchdogInstance.pvs = struct(watchdogInstance.pvlist);
            
            % Get NameList from F2_CamCheck, including bad cams
            camCheck = F2_CamCheck();
            watchdogInstance.NameList = camCheck.camera_info;
            watchdogInstance.SIOCList = camCheck.sioc_list;
            
            diaryLogFn = "/u1/facet/physics/log/matlab/CameraLog" + string(datetime('today','Format',"uuuu-MM-dd")) + ".log";
            diary(diaryLogFn);
            
            % Create Camera objects: camObj = Camera(cameraPV,SIOC_Status)
            for i = 1:size(watchdogInstance.NameList,1)
                if ~isempty(watchdogInstance.NameList{i,7}) % skip cameras without POE (should be none)
                    % Sort cameras with bad SIOCs : false = bad SIOC, true
                    % = good SIOC
                    if ismember(watchdogInstance.NameList{i,2},camCheck.badCams)
                        watchdogInstance.CameraObjs = [watchdogInstance.CameraObjs Camera(watchdogInstance.NameList{i,2},false)];
                    else
                        watchdogInstance.CameraObjs = [watchdogInstance.CameraObjs Camera(watchdogInstance.NameList{i,2},true)];
                    end
                    camObj = watchdogInstance.CameraObjs(end);
                    camObj.CamLocation = string(watchdogInstance.NameList{i,4});
                else
                    disp(['Could not create Camera object for ' watchdogInstance.NameList{i,2} '. Missing POE.'])
                end
            end
            
            % Unflag cameras that don't have alarm status for Acquisition PV
            for i = 1:numel(watchdogInstance.CameraObjs)
                if watchdogInstance.CameraObjs(i).IsSIOCgood &&...
                        iscell(lcaGetSmart(watchdogInstance.CameraObjs(i).CameraPV+":NAME"))
                    if strcmp(watchdogInstance.CameraObjs(i).pvs.Acquisition.SEVR{1},"NO_ALARM")
                        watchdogInstance.CameraObjs(i).Alarm = false;
                    end
                end
            end
                        
            % Get SIOCs from F2_CamCheck and create SIOC objects
            for i = 1:size(watchdogInstance.SIOCList,1)
                watchdogInstance.SIOCs = [watchdogInstance.SIOCs SIOC(watchdogInstance.SIOCList{i,2})];
            end
            
            % Create POE Hub objects
            watchdogInstance.POEHubs = [watchdogInstance.POEHubs POE_Hub("POE:LI20:1")];
            watchdogInstance.POEHubs = [watchdogInstance.POEHubs POE_Hub("POE:LI20:2")];
            watchdogInstance.POEHubs = [watchdogInstance.POEHubs POE_Hub("POE:LI20:3")];
            watchdogInstance.POEHubs = [watchdogInstance.POEHubs POE_Hub("POE:LA10:1")];
            watchdogInstance.POEHubs = [watchdogInstance.POEHubs POE_Hub("POE:LI10:1")];

            [watchdogInstance.CameraObjs.Watching] = deal(true);
            
            % Get Heartbeat PV to initialize it
            first_hb = caget(watchdogInstance.pvs.Heartbeat);
            
            watchdogInstance.listeners.Watchdog = addlistener(watchdogInstance,'PVUpdated',@(~,~) watchdogInstance.wdfun);
            watchdogInstance.listeners.Cameras = addlistener([watchdogInstance.CameraObjs],'PVUpdated',@(~,~) watchdogInstance.wdfun);
            watchdogInstance.listeners.SIOC = addlistener([watchdogInstance.SIOCs],'PVUpdated',@(~,~) watchdogInstance.wdfun);
            watchdogInstance.listeners.POEHubs = addlistener([watchdogInstance.POEHubs],'PVUpdated',@(~,~) watchdogInstance.wdfun);
            run(watchdogInstance.pvlist,false,3,watchdogInstance,'PVUpdated');
        end
        
        function wdfun(watchdogInstance)
            persistent lasthb lastReportTime
            
            % Update heartbeat
            caput(watchdogInstance.pvs.Watchdog,0);
            if isempty(lasthb)
                caput(watchdogInstance.pvs.Heartbeat,1);
                lasthb = clock;
            elseif watchdogInstance.pvs.Heartbeat.val{1} >= watchdogInstance.maxbeat
                caput(watchdogInstance.pvs.Heartbeat,1);
            elseif etime(clock,lasthb) > 1
                caput(watchdogInstance.pvs.Heartbeat,watchdogInstance.pvs.Heartbeat.val{1}+1);
                lasthb = clock;
            end
            
            % Once a day, create a camera report
            if isempty(lastReportTime)
                lastReportTime = datetime('today','Format',"dd-MMM-uuuu HH:mm:ss");
            elseif (datetime('now') - lastReportTime) > hours(24)
                watchdogInstance.saveData();
                lastReportTime = datetime('today','Format',"dd-MMM-uuuu HH:mm:ss");
                
                diary off
                diaryLogFn = "/u1/facet/physics/log/matlab/CameraLog" + string(datetime('today','Format',"uuuu-MM-dd")) + ".log";
                diary(diaryLogFn);
            end
      
            % Loop through SIOCs and POE hubs. If alarm is on, turn off
            % its respective camera(s) (stop looping/setting status)
            
            for i = 1:numel(watchdogInstance.SIOCs)
                if watchdogInstance.SIOCs(i).Alarm
                    server = string(watchdogInstance.SIOCList{i,1});
                    for j = 1:size(watchdogInstance.NameList,1)
                        if strcmp(watchdogInstance.NameList{j,5},server)
                            updateSIOCstatus(watchdogInstance.CameraObjs(j),false);
                        end
                    end
                else
                    server = string(watchdogInstance.SIOCList{i,1});
                    for j = 1:size(watchdogInstance.NameList,1)
                        if strcmp(watchdogInstance.NameList{j,5},server)
                            updateSIOCstatus(watchdogInstance.CameraObjs(j),true);
                        end
                    end
                end
            end
            
            for i = 1:numel(watchdogInstance.POEHubs)
                if watchdogInstance.POEHubs(i).Alarm
                    for j = 1:numel(watchdogInstance.CameraObjs)
                        if ~isempty(watchdogInstance.CameraObjs(j).POE_PV) &&...
                                contains(watchdogInstance.CameraObjs(j).POE_PV,watchdogInstance.POEHubs(i).PV)
                            updatePOEHUBstatus(watchdogInstance.CameraObjs(j),false);
                        end
                    end
                else
                    for j = 1:numel(watchdogInstance.CameraObjs)
                        if ~isempty(watchdogInstance.CameraObjs(j).POE_PV) &&...
                                contains(watchdogInstance.CameraObjs(j).POE_PV,watchdogInstance.POEHubs(i).PV)
                            updatePOEHUBstatus(watchdogInstance.CameraObjs(j),true);
                        end
                    end
                end
            end
        end
        
        function saveData(watchdogInstance)
            % Create empty arrays for table
            n = size(watchdogInstance.NameList,1);
            Name = strings(n,1);
            Model = strings(n,1);
            X_Orient = strings(n,1);
            Y_Orient = strings(n,1);
            Res = zeros(n,1);
            Exposure = zeros(n,1);
            Connection = strings(n,1);
            SerialNumber = strings(n,1);
            RebootCount = zeros(n,1);
            
            % For cameras that are not "bad," add data to arrays
            idx = [watchdogInstance.CameraObjs.IsSIOCgood];
            
            Name(idx) = [watchdogInstance.CameraObjs(idx).Name];
            PV = transpose([watchdogInstance.CameraObjs.CameraPV]);
            
            Model(idx) = string(lcaGetSmart([watchdogInstance.CameraObjs(idx).CameraPV]+":Model_RBV"));
            X_Orient(idx) = string(lcaGetSmart([watchdogInstance.CameraObjs(idx).CameraPV]+":X_ORIENT"));
            Y_Orient(idx) = string(lcaGetSmart([watchdogInstance.CameraObjs(idx).CameraPV]+":Y_ORIENT"));
            Res(idx) = lcaGetSmart([watchdogInstance.CameraObjs(idx).CameraPV]+":RESOLUTION");
            Exposure(idx) = lcaGetSmart([watchdogInstance.CameraObjs(idx).CameraPV]+":AcquireTime_RBV");
            Connection(idx) = lcaGetSmart([watchdogInstance.CameraObjs(idx).CameraPV]+":AsynIO.CNCT");
            SerialNumber(idx) = string(lcaGetSmart([watchdogInstance.CameraObjs(idx).CameraPV]+":SerialNumber_RBV"));
            RebootCount(idx) = lcaGetSmart([watchdogInstance.CameraObjs(idx).CameraPV]+":REBOOTCOUNT");
            
            % For bad cams, label them as "SIOC down"
            Connection(~idx) = "SIOC down";
            
            % Make table of camera data
            CameraData = table(Name,PV,Model,X_Orient,Y_Orient,Res,...
                Exposure,Connection,SerialNumber,RebootCount);
            
            % Save data as a table in a MAT file
            filename = "/u1/facet/physics/log/matlab/" + "CameraReport"...
                + string(datetime('now','Format',"uuuu-MM-dd-HH-mm"));
            save(filename,"CameraData");
        end

        function stopWatching(watchdogInstance)
            [watchdogInstance.CameraObjs.Watching] = deal(false);
            
            for i = 1:numel(watchdogInstance.CameraObjs)
                stop_PV(watchdogInstance.CameraObjs(i));
            end
            
            for i = 1:numel(watchdogInstance.POEHubs)
                stop_PV(watchdogInstance.POEHubs(i));
            end
            
            for i = 1:numel(watchdogInstance.SIOCs)
                stop_PV(watchdogInstance.SIOCs(i));
            end
            
            watchdogInstance.saveData();
            
            Cleanup(watchdogInstance.pvlist);
            stop(watchdogInstance.pvlist);
                        
            diary off
        end
    end
end