classdef scanFunc_L3Phase_Scan
    properties
        pvlist PV
        pvs
        initial_control
        initial_readback
        daqhandle
        freerun = true
        k4_initial
        k5_initial
    end
    properties(Constant)
        control_PV = "SIOC:SYS1:ML02:AO399"
        readback_PV = "SIOC:SYS1:ML02:AO399"
        tolerance = 0.01;
    end
    
    methods 
        
        function obj = scanFunc_L3Phase_Scan(daqhandle)
            
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

            obj.k4_initial = lcaGetSmart('LI19:KLYS:41:KPHR');
            obj.k5_initial = lcaGetSmart('LI19:KLYS:51:KPHR');
            
        end
        
        function delta = set_value(obj,value)
            
            k4 = lcaGetSmart('LI19:KLYS:41:KPHR');
            k5 = lcaGetSmart('LI19:KLYS:51:KPHR');

            disp(["Initial K4 Phase : ", k4])
            disp(["Initial K5 Phase : ", k5])

        	control_phaseSet('19-4',  obj.k4_initial - value, 0,0,'KPHR');
            control_phaseSet('19-5',  obj.k5_initial + value, 0,0,'KPHR');

%             caput(obj.pvs.control,value);

            obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.control.name, value));
            
            current_value = caget(obj.pvs.readback);
            
%             while abs(current_value - value) > obj.tolerance
%                 current_value = caget(obj.pvs.readback);
%                 pause(0.1);
%             end
            
            delta = current_value - value;
            obj.daqhandle.dispMessage(sprintf('%s readback is %0.2f', obj.pvs.readback.name, current_value));
            
        end
        
        function restoreInitValue(obj)
            obj.daqhandle.dispMessage('Restoring initial value');
%             obj.set_value(obj.initial_control);
        	control_phaseSet('19-4',  obj.k4_initial, 0,0,'KPHR');
            control_phaseSet('19-5',  obj.k5_initial, 0,0,'KPHR');
        end
        
    end
    
end