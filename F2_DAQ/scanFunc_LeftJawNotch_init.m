classdef scanFunc_LeftJawNotch_init
    properties
        pvlist PV
        pvs
        initial_control
        initial_readback
        initial_control_notch
        initial_readback_notch
        daqhandle
        freerun = true
        slope
        intercept
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
        
        function obj = scanFunc_LeftJawNotch_init(daqhandle)
            
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
            % Get the initial values of the collimators position set by the
            % user. Calculate the intercept based on the width you set in the SYAG.
            obj.slope = lcaGet('SIOC:SYS1:ML00:AO798');
            set_notch_pos = lcaGet('COLL:LI20:2069:MOTR.RBV');
            set_leftjaw_pos = lcaGet('COLL:LI20:2085:MOTR.RBV');
            obj.intercept = set_notch_pos - obj.slope*set_leftjaw_pos;
            % Set the intercept value at a PV to be used in susequent scans
            % (THE scanFunc_Left_Jaw_Notch FUCNTION!! NOT this one).
            lcaPut('SIOC:SYS1:ML00:AO799', obj.intercept);
        end
        
        function delta = set_value(obj,value)
            % Set the value of the jaw by the scan (mm).
            caput(obj.pvs.control,value);
            
            % Get the notch value corresponding to the width you set
            % previously.
            value_1 = value*obj.slope + obj.intercept;
            
            % Set the notch value (mu m)
            caput(obj.pvs.control_notch,value_1);
            
            % Dispaly the values
            obj.daqhandle.dispMessage(sprintf('test'));
            obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.control.name, value));
            obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.control_notch.name, value_1));
            obj.daqhandle.dispMessage(sprintf('test'));
            
            % Get the current values right after starting to move them
            current_value = caget(obj.pvs.readback);
            current_value_notch = caget(obj.pvs.readback_notch); 
            
            % Wait while the motor sets the position to within the
            % tolerance given in properties(constant)
            while max(abs([current_value current_value_notch] - [value value_1]) > [obj.tolerance obj.tolerance_notch])
                disp(max(abs([current_value current_value_notch] - [value value_1])))
                disp([obj.tolerance obj.tolerance_notch])
                current_value = caget(obj.pvs.readback);
                current_value_notch = caget(obj.pvs.readback_notch);
                pause(0.1);
            end
            
            % Return the value that is the difference between the initial
            % position and the new position.
            delta = current_value - value;
            obj.daqhandle.dispMessage(sprintf('%s readback is %0.2f', obj.pvs.readback.name, current_value));
            obj.daqhandle.dispMessage(sprintf('%s readback is %0.2f', obj.pvs.readback_notch.name, current_value_notch));
            
        end
        
        % Reset the values of the collimators
        function restoreInitValue(obj)
            obj.daqhandle.dispMessage('Restoring initial values - Confirm they are retracted fully!');
            
            %Park the collimators
            caput(obj.pvs.control, -12);
            caput(obj.pvs.control_notch, 2000);
            
        end
        
    end
    
end