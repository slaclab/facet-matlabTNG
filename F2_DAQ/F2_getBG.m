classdef F2_getBG < handle
    % This dumbass class does all of the BG handling
    events
        PVUpdated
    end
    properties
        pvlist PV
        pvs
        objhan
        params
        daq_pvs
        MPS_Shutter_Status
        Laser_Shutter_Status
        init_MPS_Shutter_Status
        init_Laser_Shutter_Status
    end
    properties(Hidden)
        listeners
    end
    properties(Constant)
        laserShutterVoltage = 4
        laserShutterIn = 1
        laserShutterOut = 0
        MPS_ShutterIn = 0
        MPS_ShutterOut = 1
        pockelsBlock = 'Disabled'
        pockelsEnable = 'Enabled'
        maxImSize = 4177920
    end
    
    methods 
        
        function obj = F2_getBG(apph)
        
            obj.objhan = apph;
            obj.params = apph.params;
            obj.daq_pvs = apph.daq_pvs;

            % initialize object and add PVs to be monitored
            context = PV.Initialize(PVtype.EPICS) ;
            obj.pvlist=[...
                PV(context,'name',"MPS_Shutter",'pvname',"IOC:SYS1:MP01:MSHUTCTL",'mode',"rw",'monitor',true,'pvdatatype',"int"); % MPS Shutter
                PV(context,'name',"MPS_Shutter_RBV",'pvname',"SHUT:LT10:950:IN_MPS",'mode',"r",'monitor',true); % MPS Shutter
                PV(context,'name',"Laser_Shutter",'pvname',"DO:LA20:10:Bo1",'mode',"rw",'monitor',true,'pvdatatype',"int"); % Laser Shutter
                PV(context,'name',"Laser_Shutter_RBV",'pvname',"ADC:LA20:10:CH11",'mode',"r",'monitor',true); % Laser Shutter
                PV(context,'name',"Pockels_Cell",'pvname',"TRIG:LT10:LS04:TCTL",'mode',"rw",'monitor',true); % S10 Pockels Call
                ] ;
            pset(obj.pvlist,'debug',0);
            obj.pvs = struct(obj.pvlist);
            
            obj.get_MPS_Shutter_Status();
            obj.get_Laser_Shutter_Status();
            
            obj.init_MPS_Shutter_Status = obj.MPS_Shutter_Status;
            obj.init_Laser_Shutter_Status = obj.Laser_Shutter_Status;
            
        end
        
        function bg_struct = getBackground(obj)
            
            nBG = obj.params.nBG;
            BGs = zeros(obj.params.num_CAM,obj.maxImSize,nBG);
            
            % Insert MPS shutter
            if obj.params.saveBG
                obj.insert_MPS_shutter();
            end
            
            % Insert Laser shutter
            if obj.params.laserBG
                obj.insert_Laser_shutter();
            end
            
            % Get nBGs
            for i = 1:nBG
                
                % Loop over cameras (this way you don't wait between shots)
                for j = 1:obj.params.num_CAM
                    im = lcaGetSmart(obj.daq_pvs.Image_ArrayData{j});
                    if isnan(sum(im(:)))
                        pause(0.1);
                        im = lcaGetSmart(obj.daq_pvs.Image_ArrayData{j});
                        if isnan(sum(im(:)))
                            obj.objhan.dispMessage(['Warning: could not get background image for camera ' obj.params.camNames{j}]);
                            continue;
                        end
                    end
                    
                    BGs(j,1:numel(im),i) = im;
                    
                end
                pause(0.1);
            end
            
            % Reshape BGs
            bg_struct = struct;
            bg_struct.getBG = obj.params.saveBG;
            bg_struct.laserBG = obj.params.laserBG;
            bg_struct.nBG = nBG;
            for j = 1:obj.params.num_CAM
                size_x = obj.objhan.data_struct.metadata.(obj.params.camNames{j}).SizeX_RBV;
                size_y = obj.objhan.data_struct.metadata.(obj.params.camNames{j}).SizeY_RBV;
                bgs = squeeze(BGs(j,1:(size_x*size_y),:));
                if nBG == 1
                    bg_array = uint16(reshape(bgs,[size_x,size_y]));
                else
                    bg_array = uint16(reshape(bgs,[size_x,size_y,nBG]));
                end
                bg_struct.(obj.params.camNames{j}) = bg_array;
            end
            
            % Re-open shutters
            obj.restoreShutters();
            
        end
        
        function restoreShutters(obj)
            
            % Re-open shutters
            if ~obj.init_MPS_Shutter_Status
                obj.extract_MPS_shutter();
            end
            
            if ~obj.init_Laser_Shutter_Status
                obj.extract_Laser_shutter();
            end
            
        end
            
        
        function get_MPS_Shutter_Status(obj)
            % In = True, Out = False
            val = caget(obj.pvs.MPS_Shutter_RBV);
            if strcmp(val,'IS_IN')
                obj.MPS_Shutter_Status = true;
                
            elseif strcmp(val,'IS_NOT_IN')
                obj.MPS_Shutter_Status = false;
                
            else
                obj.objhan.dispMessage('Warning: cannot determine MPS shutter status.');
                obj.MPS_Shutter_Status = false;
                
            end
        end
        
        
        function get_Laser_Shutter_Status(obj)
            % In = True, Out = False
            val = caget(obj.pvs.Laser_Shutter_RBV);
            if val < obj.laserShutterVoltage
                obj.Laser_Shutter_Status = true;
                
            elseif val > obj.laserShutterVoltage
                obj.Laser_Shutter_Status = false;
                
            else
                obj.objhan.dispMessage('Warning: cannot determine Laser shutter status.');
                obj.Laser_Shutter_Status = false;
                
            end
        end
            
        
        function insert_MPS_shutter(obj)
            obj.objhan.dispMessage('Inserting MPS shutter');
            caput(obj.pvs.MPS_Shutter,obj.MPS_ShutterIn);
            
            obj.get_MPS_Shutter_Status();
            count = 0;
            while ~obj.MPS_Shutter_Status
                pause(0.1);
                obj.get_MPS_Shutter_Status();
                count = count+1;
                if count > 20
                    obj.objhan.dispMessage('Warning: cannot insert MPS shutter.');
                    return;
                end
            end
            obj.objhan.dispMessage('MPS shutter inserted');
        end
        
        
        function insert_Laser_shutter(obj)
            obj.objhan.dispMessage('Inserting Laser shutter');
            caput(obj.pvs.Laser_Shutter,obj.laserShutterIn);
            
            obj.get_Laser_Shutter_Status();
            count = 0;
            while ~obj.Laser_Shutter_Status
                pause(0.1);
                obj.get_Laser_Shutter_Status();
                count = count+1;
                if count > 100
                    obj.objhan.dispMessage('Warning: cannot insert Laser shutter');
                    return;
                end
            end
            obj.objhan.dispMessage('Laser shutter inserted');
        end
        
        function block_Pockels_cell(obj)
            obj.objhan.dispMessage('Blocking S10 laser with Pockels cell');
            caput(obj.pvs.Pockels_Cell,obj.pockelsBlock);
            obj.objhan.dispMessage('S10 laser blocked');
        end
        
        
        function extract_MPS_shutter(obj)
            obj.objhan.dispMessage('Extracting MPS shutter');
            caput(obj.pvs.MPS_Shutter,obj.MPS_ShutterOut);
            
            obj.get_MPS_Shutter_Status();
            count = 0;
            while obj.MPS_Shutter_Status
                pause(0.1);
                obj.get_MPS_Shutter_Status();
                count = count+1;
                if count > 20
                    obj.objhan.dispMessage('Warning: cannot extract MPS shutter.');
                    return;
                end
            end
            obj.objhan.dispMessage('MPS shutter extracted');
        end
        
        
        function extract_Laser_shutter(obj)
            obj.objhan.dispMessage('Extracting Laser shutter');
            caput(obj.pvs.Laser_Shutter,obj.laserShutterOut);
            
            obj.get_Laser_Shutter_Status();
            count = 0;
            while obj.Laser_Shutter_Status
                pause(0.1);
                obj.get_Laser_Shutter_Status();
                count = count+1;
                if count > 100
                    obj.objhan.dispMessage('Warning: cannot extract Laser shutter');
                    return;
                end
            end
            obj.objhan.dispMessage('Laser shutter extracted');
        end
        
        function enable_Pockels_cell(obj)
            obj.objhan.dispMessage('Enabling S10 laser with Pockels cell');
            caput(obj.pvs.Pockels_Cell,obj.pockelsEnable);
            obj.objhan.dispMessage('S10 laser enabled');
        end
    end
    
end