classdef scanFunc_ADAPT_QUAD_IN10_525
    properties
        pvlist PV
        pvs
        initial_control
        initial_readback
        daqhandle
        freerun = true
    end
    properties(Constant)
        control_PV = "QUAD:IN10:525:BCTRL"
        readback_PV = "QUAD:IN10:525:BACT"
        tolerance = 0.01;
    end
    
    methods 
        
        function obj = scanFunc_ADAPT_QUAD_IN10_525(daqhandle)
            
            % Check if scanfunc called by DAQ
            if exist('daqhandle','var')
                obj.daqhandle=daqhandle;
                obj.freerun = false;
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
            
            system('python /home/fphysics/cemma/git_work/lcls_emit/Emit_from_lcls/tofacet/adaptRangesFACET.py');
            
            min_x = lcaGet('SIOC:SYS1:ML01:AO651');
            max_x = lcaGet('SIOC:SYS1:ML01:AO652');
            
            min_y = lcaGet('SIOC:SYS1:ML01:AO653');
            max_y = lcaGet('SIOC:SYS1:ML01:AO654');
            
            steps = lcaGet('SIOC:SYS1:ML01:AO655');
            
            x_range = linspace(min_x,max_x,steps);
            y_range = linspace(min_y,max_y,steps);
            
            all_range = [x_range y_range];
            obj.daqhandle.params.scanVals = {all_range};
            
            
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
        
        function restoreInitValue(obj)
            obj.daqhandle.dispMessage('Restoring initial value');
            obj.set_value(obj.initial_control);
        end
        
    end
    
end