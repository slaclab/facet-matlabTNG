classdef F2_runDAQ < handle
    events
        PVUpdated % PV object list notifies this event after each set of monitored PVs have finished updating
    end
    properties
        pvlist PV
        pvs
        params
        data_struct
        objhan
        freerun = true
        daq_pvs
        Instance
    end
    properties(Hidden)
        listeners
    end
    properties(Constant)
        maxbeat=1e7 % max heartbeat count, wrap to zero
    end
    
    methods
        
        function obj = F2_runDAQ(DAQ_params,apph)
            
            obj.params = DAQ_params;
            
            % Check if DAQ called by GUI
            if exist('apph','var')
                obj.objhan=apph;
                obj.freerun = false;
            end
            
            % initialize object and add PVs to be monitored
            context = PV.Initialize(PVtype.EPICS_labca) ;
            obj.pvlist=[...
                PV(context,'name',"DAQ_Running",'pvname',"SIOC:SYS1:ML02:AO352",'mode',"rw",'monitor',true); % Is DAQ running?
                PV(context,'name',"DAQ_Abort",'pvname',"SIOC:SYS1:ML02:AO353",'mode',"rw",'monitor',true); % Abort request
                PV(context,'name',"DAQ_Instance",'pvname',"SIOC:SYS1:ML02:AO400",'mode',"rw",'monitor',true); % Number of times DAQ is run
                ] ;
            pset(obj.pvlist,'debug',0);
            obj.pvs = struct(obj.pvlist);
            
            % Check if DAQ is running
            running = caget(obj.pvs.DAQ_Running);
            if running
                obj.dispMessage('Cannot start new DAQ. DAQ already running.');
                return
            end
            caput(obj.pvs.DAQ_Running,1);
            
            % Clear old aborts
            abort = caget(obj.pvs.DAQ_Abort);
            if abort
                caput(obj.pvs.DAQ_Abort,0);
                obj.dispMessage('Clearing abort status.');
            end
            
            % Update DAQ instance
            obj.Instance = caget(obj.pvs.DAQ_Instance)+1;
            caput(obj.pvs.DAQ_Instance,obj.Instance);
            obj.dispMessage(sprintf('Started DAQ instance %d.',obj.Instance));
            
            % =========================================
            % Create Data Path on NAS drive 
            % =========================================
            obj.data_struct.save_info = set_DAQ_filepath(obj);
            
            
            % Create data object, fill in metadata
            obj.data_struct.params = obj.params;
            obj.data_struct.metadata = struct();
            for i = 1:obj.params.num_CAM
                obj.data_struct.metadata.(obj.params.camNames{i}) = get_cam_info(obj.params.camPVs{i});
                obj.data_struct.metadata.(obj.params.camNames{i}).server = obj.params.camServers{i};
                obj.data_struct.metadata.(obj.params.camNames{i}).trigger = obj.params.camTrigs{i};
            end
            
            % Fill in BSA data
            for i = 1:numel(obj.params.BSA_list)
                pvList = feval(obj.params.BSA_list{i});
                pvDesc = lcaGetSmart(strcat(pvList,'.DESC'));
                
                obj.data_struct.metadata.(obj.params.BSA_list{i}).PVs = pvList;
                obj.data_struct.metadata.(obj.params.BSA_list{i}).Desc = pvDesc;
            end
            
            % Fill in non-BSA data
            for i = 1:numel(obj.params.nonBSA_list)
                pvList = feval(obj.params.nonBSA_list{i});
                pvDesc = lcaGetSmart(strcat(pvList,'.DESC'));
                
                obj.data_struct.metadata.(obj.params.nonBSA_list{i}).PVs = pvList;
                obj.data_struct.metadata.(obj.params.nonBSA_list{i}).Desc = pvDesc;
            end
            
            % Get PVs for cam control
            obj.daq_pvs = camera_DAQ_PVs(obj.params.camPVs);
            
            
            
            if obj.params.saveBG
                obj.grab_BG();
            end
            
            
            
        end
        
        function grab_BG(obj)
            
            nBG = obj.params.nBG;
            
        end
        
        function dispMessage(obj,message)
            
            if obj.freerun
                disp(message)
            else
                obj.objhan.addMessage(message);
            end
        end
            
           
        
        
        
    end
end
