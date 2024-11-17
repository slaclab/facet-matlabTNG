classdef scanFunc_Gamma2_Filter_InOut
    properties
        pvlist PV
        pvs
        initial_control
        initial_readback
        daqhandle
        freerun = true
    end
    properties(Constant)
        control_PV = "SIOC:SYS1:ML02:AO399"  % dummy PV
        readback_PV = "SIOC:SYS1:ML02:AO399"
        tolerance = 0.01;
    end
    
    methods 
        
        function obj = scanFunc_Gamma2_Filter_InOut(daqhandle)
            
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
            
            %Define PVs
            Gamma2_In_x = 'SIOC:SYS1:ML00:AO635';
            Gamma2_In_y = 'SIOC:SYS1:ML00:AO636';
            Gamma2_Out_x = 'SIOC:SYS1:ML00:AO637';
            Gamma2_Out_y = 'SIOC:SYS1:ML00:AO638';
            
            Gamma2_x_SP = 'XPS:LI20:MC02:M3';
            Gamma2_y_SP = 'XPS:LI20:MC02:M6';
            
            Gamma2_x_RBV = 'XPS:LI20:MC02:M3.RBV';
            Gamma2_y_RBV = 'XPS:LI20:MC02:M6.RBV';
            
            % Select if inserting or retracting
            if value==0
                Gamma2_x = lcaGet(Gamma2_Out_x);
                Gamma2_y = lcaGet(Gamma2_Out_y);
                obj.daqhandle.dispMessage(sprintf('Removing Gamma2 filters to x = %0.2f, y = %0.2f', Gamma2_x, Gamma2_y));
            elseif value==1
                Gamma2_x = lcaGet(Gamma2_In_x);
                Gamma2_y = lcaGet(Gamma2_In_y);
                obj.daqhandle.dispMessage(sprintf('Inserting Gamma2 filters to x = %0.2f, y = %0.2f', Gamma2_x, Gamma2_y));
            else
               obj.daqhandle.dispMessage(sprintf('Invalid Gamma2 position request - enter 0 or 1'));
               return;
            end
                           
              
            % Set the motor PVs
            lcaPut(Gamma2_x_SP,Gamma2_x);
            lcaPut(Gamma2_y_SP,Gamma2_y);
            
            obj.daqhandle.dispMessage(sprintf('Setting Gamma2 x to %0.2f, Gamma2 y to %0.2f', Gamma2_x, Gamma2_y));
            
            %Wait for motor to reach the setpoint
            current_value_x = lcaGet(Gamma2_x_RBV);
            current_value_y = lcaGet(Gamma2_y_RBV);
            delta_x = abs(current_value_x-Gamma2_x);
            delta_y = abs(current_value_y-Gamma2_y);
            
            while max([delta_x delta_y]) > obj.tolerance
                current_value_x = lcaGet(Gamma2_x_RBV);
                current_value_y = lcaGet(Gamma2_y_RBV);
                delta_x = abs(current_value_x-Gamma2_x);
                delta_y = abs(current_value_y-Gamma2_y);
                pause(0.1);
            end
            
            obj.daqhandle.dispMessage(sprintf('Gamma2 x set to %0.2f, Gamma2 y set to %0.2f', current_value_x, current_value_y));
            
        end
        
        function restoreInitValue(obj)
            obj.daqhandle.dispMessage('Not restoring initial Gamma2 position. Sorry.');
          
        end
        
    end
    
end