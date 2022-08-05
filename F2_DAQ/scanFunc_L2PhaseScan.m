classdef scanFunc_L2PhaseScan
    properties
        pvlist PV
        pvs
        initial_control
        initial_readback
        daqhandle
        freerun = true
        Control
    end
    properties(Constant)
        control_PV = "L2_PHASE.MKB"
        readback_PV = "L2_PHASE.MKB"
        tolerance = 0.01;
    end
    
    methods 
        
        function obj = scanFunc_L2PhaseScan(daqhandle)
            
            % Check if scanfunc called by DAQ
            if exist('daqhandle','var')
                obj.daqhandle=daqhandle;
                obj.freerun = false;
            end
            
            obj.Control = SCP_MKB("l2_phase");
        

            
            obj.initial_control = obj.Control.get();
            obj.initial_readback = obj.initial_control;
            
        end
        
        function delta = set_value(obj,value)
            
            obj.Control.set(value);
            obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.control_PV, value));
            
            pause(3);
            
            current_value = obj.Control.get();
            
%             while abs(current_value - value) > obj.tolerance
%                 current_value = caget(obj.pvs.readback);
%                 pause(0.1);
%             end
            
%             delta = current_value - value;
            delta = 0;
            obj.daqhandle.dispMessage(sprintf('%s readback is %0.2f', obj.readback_PV, current_value));
            
        end
        
        function restoreInitValue(obj)
            obj.daqhandle.dispMessage('Restoring initial value');
            obj.set_value(obj.initial_control);
        end
        
    end
    
end