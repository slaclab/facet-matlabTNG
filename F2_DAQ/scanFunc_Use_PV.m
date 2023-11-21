classdef scanFunc_Use_PV
    properties
        pvlist PV
        pvs
        control_PV
        readback_PV
        initial_control
        initial_readback
        daqhandle
        tolerance = 0.01
        freerun = true
    end
    
    methods 
        
        function obj = scanFunc_Use_PV(daqhandle,PV_name,RBV_name,tolerance)
            
            % Check if scanfunc called by DAQ
            if exist('daqhandle','var')
                obj.daqhandle=daqhandle;
                obj.freerun = false;
            end
                        
            obj.control_PV = PV_name;
            obj.readback_PV = RBV_name;
            obj.tolerance = tolerance;

                
        
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
        
        function restoreInitValue(obj)
            obj.daqhandle.dispMessage('Restoring initial value');
            obj.set_value(obj.initial_control);
        end
        
    end
    
end