classdef scanFunc_zob_Spect_Quad_Scan_FILS
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
        
        function obj = scanFunc_zob_Spect_Quad_Scan_FILS(daqhandle)
            
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
            
            m12_req=0;
            m34_req=0;
            z_ob=1993.2737+value; % object plane position w.r.t. FILS
            z_im=2015.2599; % DTOTR1 position
            QS=lcaGet('SIOC:SYS1:ML00:CALCOUT051'); % read imaged energy written by scanFunc_E_Spect_Quad_Scan_FILS
            [isok, BDES0, BDES1, BDES2] = E300_calc_QS_3(z_ob, z_im, QS-10, m12_req, m34_req) % Note that the 3rd parameter (energy) is entered with repect to 10 GeV.
            
            caput(obj.pvs.control,value);
            obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.control.name, value));
            
        quadPV.control_PV0  = "LGPS:LI20:3141";
        quadPV.control_PV1  = "LGPS:LI20:3261";
        quadPV.control_PV2  = "LGPS:LI20:3091";
        quadPV.readback_PV0 = "LGPS:LI20:3141";
        quadPV.readback_PV1 = "LGPS:LI20:3261";
        quadPV.readback_PV2 = "LGPS:LI20:3091";
            
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