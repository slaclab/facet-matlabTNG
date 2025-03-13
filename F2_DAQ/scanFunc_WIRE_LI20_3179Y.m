classdef scanFunc_WIRE_LI20_3179Y
    properties
        pvlist PV
        pvs
        initial_control
        initial_readback
        daqhandle
        freerun = true
        num_shots
    end
    properties(Constant)
        control_PV = "SIOC:SYS1:ML00:CALCOUT073" 
        readback_PV = "SIOC:SYS1:ML00:CALCOUT073" 
        tolerance = 0.01;
        WireDiam = 45
    end
    
    methods 
        function obj = scanFunc_WIRE_LI20_3179Y(daqhandle)
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
            
        end
    
        function delta = set_value(obj,value)
            disp(obj.daqhandle.params.n_shot);
            caput(obj.pvs.control,value);
            obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.control.name, value));
            
            current_value = caget(obj.pvs.readback);
            
            while abs(current_value - value) > obj.tolerance
                current_value = caget(obj.pvs.readback);
                pause(0.1);
            end
            
            delta = current_value - value;
            obj.daqhandle.dispMessage(sprintf('%s readback is %0.2f', obj.pvs.readback.name, current_value));
            wire_start = lcaGet(char("WIRE:LI20:3179:YWIREINNER"));
            lcaPut(char("WIRE:LI20:3179:USEYWIRE"),1)
            lcaPut(char("WIRE:LI20:3179:USEXWIRE"),0)
            lcaPut(char("WIRE:LI20:3179:STARTSCAN"),1)
            pos = lcaGet(char("WIRE:LI20:3179:POSN"));
            pos_tolerance = 1;

            %wait here for motor rbk to reach startpoint 
            while abs(pos - wire_start) >= pos_tolerance
                pos = lcaGet(char("WIRE:LI20:3179:POSN"));
                
            end
            
            % Motor has reached start point, store current position
            current_pos = pos;
            
            % Now wait until the motor starts moving again
            while abs(pos - current_pos) < pos_tolerance
                pos = lcaGet(char("WIRE:LI20:3179:POSN"));
            end
            
        end
        
        function restoreInitValue(obj)
            %obj.daqhandle.dispMessage('Restoring initial value');
            %obj.set_value(obj.initial_control);
            
            %lcaPut(char("WIRE:LI20:3179:STARTSCAN"),0)
            %lcaPut(obj.pvs.control,0);
        end
        
    end
    
end



