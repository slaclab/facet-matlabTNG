classdef scanFunc_LeftJawNotch
    properties
        pvlist PV
        pvs
        initial_control
        initial_readback
        initial_control_notch
        initial_readback_notch
        daqhandle
        freerun = true
    end
    properties(Constant)
        control_PV = "COLL:LI20:2085:MOTR.VAL"
        readback_PV = "COLL:LI20:2085:MOTR.RBV"
        tolerance = 0.1;
        
        control_notch_PV = "COLL:LI20:2069:MOTR" %"SIOC:SYS1:ML00:CALCOUT076"
        readback_notch_PV = "COLL:LI20:2069:MOTR.RBV" %"SIOC:SYS1:ML00:CALCOUT076"
        tolerance_notch = 2;
        
        
    end
    
    methods 
        
        function obj = scanFunc_LeftJawNotch(daqhandle)
            
            % Check if scanfunc called by DAQ
            if exist('daqhandle','var')
                obj.daqhandle=daqhandle;
                obj.freerun = false;
            end
                    
            context = PV.Initialize(PVtype.EPICS_labca);
            obj.pvlist=[...
                PV(context,'name',"control",'pvname',obj.control_PV,'mode',"rw",'monitor',true); % Control PV
                PV(context,'name',"readback",'pvname',obj.readback_PV,'mode',"r",'monitor',true); % Readback PV
                PV(context,'name',"control_notch",'pvname',obj.control_notch_PV,'mode',"rw",'monitor',true); % Control PV y motor
                PV(context,'name',"readback_notch",'pvname',obj.readback_notch_PV,'mode',"r",'monitor',true); % Readback PV y motor
                ];
            pset(obj.pvlist,'debug',0);
            obj.pvs = struct(obj.pvlist);
            
            obj.initial_control = caget(obj.pvs.control);
            obj.initial_readback = caget(obj.pvs.readback);
            obj.initial_control_notch = caget(obj.pvs.control_notch);
            obj.initial_readback_notch = caget(obj.pvs.readback_notch);
            
        end
        
        function delta = set_value(obj,value)

            caput(obj.pvs.control,value);
            
            value_1 = (value*139.8718798 + 919.78)/0.07421884;

            caput(obj.pvs.control_notch,value_1);
            %caput("COLL:LI20:2069:MOTR",value_1);
            obj.daqhandle.dispMessage(sprintf('test'));
            disp('test')
            obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.control.name, value));
            obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.control_notch.name, value_1));
            obj.daqhandle.dispMessage(sprintf('test'));
            disp('test')
            current_value = caget(obj.pvs.readback);
            current_value_notch = caget(obj.pvs.readback_notch); %lcaGet('COLL:LI20:2069:MOTR.RBV');

            %delta_jaw = abs(current_value - value);
            %delta_notch = abs(current_value_notch - value_1);
 
            while max(abs([current_value current_value_notch] - [value value_1]) > [obj.tolerance obj.tolerance_notch])
                disp(max(abs([current_value current_value_notch] - [value value_1])))
                disp([obj.tolerance obj.tolerance_notch])
                current_value = caget(obj.pvs.readback);
                current_value_notch = caget(obj.pvs.readback_notch);
                pause(0.1);
            end
            
            %while (delta_jaw > 0.1) || (delta_notch > 5)
             %   disp(delta_jaw)
                %disp(obj.tolerance_jaw)
              %  disp(delta_notch)
                %disp(obj.tolerance_notch)
  
               % value_1 = (value*139.8718798 + 1230.78256)/0.07421884; %10114.05734 - 8883.27478
            
                %current_value = caget(obj.pvs.readback);
                %current_value_notch = lcaGet('COLL:LI20:2069:MOTR.RBV');
                %delta_jaw = abs(current_value - value);
                %delta_notch = abs(current_value_notch - value_1);
                %pause(1);
            %end
            delta = current_value - value;
            obj.daqhandle.dispMessage(sprintf('%s readback is %0.2f', obj.pvs.readback.name, current_value));
            obj.daqhandle.dispMessage(sprintf('%s readback is %0.2f', obj.pvs.readback_notch.name, current_value_notch));
            
        end
        
        function restoreInitValue(obj)
            obj.daqhandle.dispMessage('Restoring initial values - Confirm they are retracted fully!');
            
            caput(obj.pvs.control,obj.initial_control);
            caput(obj.pvs.control_notch,obj.initial_control_notch);
            
        end
        
    end
    
end