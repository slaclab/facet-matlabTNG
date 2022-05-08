classdef scanFunc_Spect_Quad_Scan
    properties
        pvlist PV
        pvs
        initial_control
        initial_readback
        daqhandle
        freerun = true
    end
    properties(Constant)
        control_PV  = "SIOC:SYS1:ML00:AO959"
        readback_PV = "SIOC:SYS1:ML00:AO959"
        
%         control_PV0  = "LGPS:LI20:3141"
%         control_PV1  = "LGPS:LI20:3261"
%         control_PV2  = "LGPS:LI20:3091"
%         readback_PV0 = "LGPS:LI20:3141"
%         readback_PV1 = "LGPS:LI20:3261"
%         readback_PV2 = "LGPS:LI20:3091"
        tolerance = 0.01;
    end
    
    methods 
        
        function obj = scanFunc_Spect_Quad_Scan(daqhandle)
            
            % Check if scanfunc called by DAQ
            if exist('daqhandle','var')
                obj.daqhandle=daqhandle;
                obj.freerun = false;
            end
                    
            context = PV.Initialize(PVtype.EPICS_labca);
            obj.pvlist=[...
                PV(context,'name',"control",'pvname',obj.control_PV,'mode',"rw",'monitor',true); % Control PV
                PV(context,'name',"readback",'pvname',obj.readback_PV,'mode',"r",'monitor',true); % Readback PV
               
%                 PV(context,'name',"control0",'pvname',obj.control_PV0,'mode',"rw",'monitor',true); % Control PV
%                 PV(context,'name',"control1",'pvname',obj.control_PV1,'mode',"rw",'monitor',true); % Control PV
%                 PV(context,'name',"control2",'pvname',obj.control_PV2,'mode',"rw",'monitor',true); % Control PV
%                 PV(context,'name',"readback0",'pvname',obj.readback_PV0,'mode',"r",'monitor',true); % Readback PV
%                 PV(context,'name',"readback1",'pvname',obj.readback_PV1,'mode',"r",'monitor',true); % Readback PV
%                 PV(context,'name',"readback2",'pvname',obj.readback_PV2,'mode',"r",'monitor',true); % Readback PV
                ];
            pset(obj.pvlist,'debug',0);
            obj.pvs = struct(obj.pvlist);
            
            obj.initial_control = caget(obj.pvs.control);
            obj.initial_readback = caget(obj.pvs.readback);
            
%             obj.initial_control0 = control_magnetGet(obj.control_PV0);
%             obj.initial_readback0 = control_magnetGet(obj.readback_PV0);
%             obj.initial_control1 = control_magnetGet(obj.control_PV1);
%             obj.initial_readback1 = control_magnetGet(obj.readback_PV1);
%             obj.initial_control2 = control_magnetGet(obj.control_PV2);
%             obj.initial_readback2 = control_magnetGet(obj.readback_PV2);

            
        end
        
        function delta = set_value(obj,value)
            
            [isok, BDES0, BDES1, BDES2] = calc_Spec_Quad_M12(value);  %z_ob, z_im, QS, m12_req, m34_req)
            
            caput(obj.pvs.control,value);
            obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.control.name, value));
            
        quadPV.control_PV0  = "LGPS:LI20:3141"
        quadPV.control_PV1  = "LGPS:LI20:3261"
        quadPV.control_PV2  = "LGPS:LI20:3091"
        quadPV.readback_PV0 = "LGPS:LI20:3141"
        quadPV.readback_PV1 = "LGPS:LI20:3261"
        quadPV.readback_PV2 = "LGPS:LI20:3091"
            
            if isok
                [delta] = set_Spec_Quad(obj, quadPV, BDES0, BDES1, BDES2);
            else
                obj.daqhandle.dispMessage('BDES out of range: Q0D = %.2f, Q1D = %.2f, Q2D = %.2f', BDES0, BDES1, BDES2);
                delta = 100; % How do I stop a DAQ with an error?
            end
            
        end
        
        function restoreInitValue(obj)
            obj.daqhandle.dispMessage('NOT Restoring initial value. Sorry!');
            
         %           quadPV.control_PV0  = "LGPS:LI20:3141"
         %           quadPV.control_PV1  = "LGPS:LI20:3261"
         %           quadPV.control_PV2  = "LGPS:LI20:3091"
         %           quadPV.readback_PV0 = "LGPS:LI20:3141"
         %           quadPV.readback_PV1 = "LGPS:LI20:3261"
         %           quadPV.readback_PV2 = "LGPS:LI20:3091"
         %   [delta] = set_Spec_Quad(quadPV, obj.initial_control0, obj.initial_control1, obj.initial_control2);
        end
        
    end
    
end