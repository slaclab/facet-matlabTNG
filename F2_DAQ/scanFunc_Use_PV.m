classdef scanFunc_Use_PV
    properties
        pvlist PV
        pvs
        control_PV
        readback_PV
        initial_control
        initial_readback
        daqhandle
        tolerance
        freerun = true
    end
    
    methods 
        
        function obj = scanFunc_Use_PV(daqhandle,PV_name)
            
            % Check if scanfunc called by DAQ
            if exist('daqhandle','var')
                obj.daqhandle=daqhandle;
                obj.freerun = false;
            end
                        
            obj.control_PV = PV_name;
            
            split_pv = strsplit(PV_name,':');
            field = split_pv{end};
            
            % Funky handling for XPS (there's gotta be a better way . . .)
            if numel(field) == 2 && strcmp(field(1),'M') && str2num(field(2)) < 9
                field = 'M';
            end
            
            % Currently supporting magnets and motors
            switch field
                case 'BDES'
                    obj.readback_PV = strrep(obj.control_PV,'BDES','BACT');
                case 'BCTRL'
                    obj.readback_PV = strrep(obj.control_PV,'BCTRL','BACT');
                case 'MOTR'
                    obj.readback_PV = [obj.control_PV '.RBV'];
                case 'MOTOR'
                    obj.readback_PV = [obj.control_PV '.RBV'];
                case 'M'
                    obj.readback_PV = [obj.control_PV '.RBV'];
                otherwise
                    obj.daqhandle.dispMessage('Cannot identify readback PV');
                    obj.get_readbackPV();
            end
                
        
            context = PV.Initialize(PVtype.EPICS_labca);
            obj.pvlist=[...
                PV(context,'name',"control",'pvname',obj.control_PV,'mode',"rw",'monitor',true); % Control PV
                PV(context,'name',"readback",'pvname',obj.readback_PV,'mode',"r",'monitor',true); % Readback PV
                ];
            pset(obj.pvlist,'debug',0);
            obj.pvs = struct(obj.pvlist);
            
            obj.initial_control = caget(obj.pvs.control);
            obj.initial_readback = caget(obj.pvs.readback);
            
        end
        
        function delta = set_value(obj,value)
            
            caput(obj.pvs.control,value);
            obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.control.name, value));
            
            current_value = caget(obj.pvs.readback);
            
            while abs(current_value - value) > obj.tolerance
                current_value = caget(obj.pvs.readback);
                pause(0.1);
            end
            
            delta = current_value - value;
            obj.daqhandle.dispMessage(sprintf('%s readback is %0.2f', obj.pvs.readback.name, current_value));
            
        end
        
        function obj = get_readbackPV(obj)
            prompt = 'Could not determine readback PV. Enter one below:';
            dlgtitle = 'Readback PV';
            answer = inputdlg(prompt,dlgtitle);
            if isempty(answer)
                obj.daqhandle.dispMessage('No readback PV. Aborting');
            else
                obj.readback_PV = answer;
            end
        end
        
    end
    
end