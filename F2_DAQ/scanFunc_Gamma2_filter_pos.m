classdef scanFunc_Gamma2_filter_pos
    properties
        pvlist PV
        pvs
        
        initial_control
        initial_readback
        
        initial_control_y
        initial_readback_y
        
        daqhandle
        freerun = true
    end
    properties(Constant)
        %control: ("XPS:LI20:MC02:M3","XPS:LI20:MC02:M6") (x,y) 
        %readback: ("XPS:LI20:MC02:M3.RBV","XPS:LI20:MC02:M6.RBV") (x,y)
        control_PV = "SIOC:SYS1:ML00:CALCOUT075"
        readback_PV = "SIOC:SYS1:ML00:CALCOUT075" 
        tolerance = 0.01;

        control_y_PV = "SIOC:SYS1:ML00:CALCOUT076"
        readback_y_PV = "SIOC:SYS1:ML00:CALCOUT076"
        tolerance_y = 0.01;
        
        readback_center_x_PV = "SIOC:SYS1:ML00:CALCOUT070" % assign an unused PV
        readback_center_y_PV = "SIOC:SYS1:ML00:CALCOUT071"
        
        radius = "12" % mm
    end
    
    methods 
        
        function obj = scanFunc_Gamma2_filter_pos(daqhandle)
            
            % Check if scanfunc called by DAQ
            if exist('daqhandle','var')
                obj.daqhandle=daqhandle;
                obj.freerun = false;
            end
                    
            context = PV.Initialize(PVtype.EPICS_labca);
            obj.pvlist=[...
                PV(context,'name',"control",'pvname',obj.control_PV,'mode',"rw",'monitor',true); % Control PV x motor
                PV(context,'name',"readback",'pvname',obj.readback_PV,'mode',"r",'monitor',true); % Readback PV x motor
                PV(context,'name',"control_y",'pvname',obj.control_y_PV,'mode',"rw",'monitor',true); % Control PV y motor
                PV(context,'name',"readback_y",'pvname',obj.readback_y_PV,'mode',"r",'monitor',true); % Readback PV y motor
                PV(context,'name',"readback_center_x",'pvname',obj.readback_center_x_PV,'mode',"r",'monitor',true); % Read center x pos of filter wheel
                PV(context,'name',"readback_center_y",'pvname',obj.readback_center_y_PV,'mode',"r",'monitor',true); % Read center y pos of filter wheel
                ];
            pset(obj.pvlist,'debug',0);
            obj.pvs = struct(obj.pvlist);
            
            obj.initial_control = caget(obj.pvs.control);
            obj.initial_readback = caget(obj.pvs.readback);
            obj.initial_control_y = caget(obj.pvs.control_y);
            obj.initial_readback_y = caget(obj.pvs.readback_y);
            
        end
        
        function delta = set_value(obj,value,restore_initial)
            arguments
                obj scanFunc_Gamma2_filter_pos
                value int16 {mustBeInteger, mustBeGreaterThanOrEqual(value, 1), mustBeLessThanOrEqual(value, 12)}
                restore_initial = false
            end
            % counter intuitively, the variable "value" is used to select
            % the filter number (integer from 1 to 12), NOT the PV of
            % Gamma2_X. The filter number is then converted to the Gamma2_X
            % and Gamma2_Y values. 
            
            if ~restore_initial
                angle = pi/12 + pi/6 * (value - 1);
                x_circ = obj.pvs.readback_center_x + obj.radius * cos(angle);
                y_circ = obj.pvs.readback_center_y + obj.radius * sin(angle);
            else
                x_circ = obj.initial_control;
                y_circ = obj.initial_control_y;
            end
            
            
            caput(obj.pvs.control, x_circ);
            caput(obj.pvs.control_y, y_circ);
            
            obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.control.name, x_circ));
            obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.control_y.name, y_circ));
            
            current_value = caget(obj.pvs.readback);
            current_value_y = caget(obj.pvs.readback_y);
            
            while max(abs([current_value current_value_y] - [x_circ y_circ]) > [obj.tolerance obj.tolerance_y])
                current_value = caget(obj.pvs.readback);
                current_value_y = caget(obj.pvs.readback_y);
                pause(0.1);
            end
            
            delta = current_value - x_circ;
            obj.daqhandle.dispMessage(sprintf('%s readback is %0.2f', obj.pvs.readback.name, current_value));
            obj.daqhandle.dispMessage(sprintf('%s readback is %0.2f', obj.pvs.readback_y.name, current_value_y));
        end
        
        function restoreInitValue(obj)
            obj.daqhandle.dispMessage('Restoring initial value');
            obj.set_value(1, true);
        end
        
    end
    
end