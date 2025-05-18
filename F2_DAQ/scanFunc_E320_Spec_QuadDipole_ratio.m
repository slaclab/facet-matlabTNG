classdef scanFunc_E320_Spec_QuadDipole_ratio
    properties
        pvlist PV
        pvs
        initial_control
        initial_readback
        initial_control_dipole
        initial_readback_dipole
        daqhandle
        freerun = true
    end
    properties(Constant)
        control_PV  = "SIOC:SYS1:ML00:CALCOUT051"
        readback_PV = "SIOC:SYS1:ML00:CALCOUT051"
        abort_PV    = "SIOC:SYS1:ML02:AO353"
        dipole_control_PV = "BNDS:LI20:3330"
        dipole_readback_PV = "BNDS:LI20:3330"
        
        ratio_PV = 'SIOC:SYS1:ML00:CALCOUT101'
        
        
        tolerance = 0.01;
        tolerance_dipole = 0.05;
    end
    
    methods 
        
        function obj = scanFunc_E320_Spec_QuadDipole_ratio(daqhandle)
            
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
            
            obj.initial_control_dipole = control_magnetGet(obj.dipole_control_PV);
            obj.initial_readback_dipole = control_magnetGet(obj.dipole_readback_PV);
            
        end
        
        function delta = set_value(obj,value)
            
            E=value;
            z_ob=lcaGet('SIOC:SYS1:ML00:CALCOUT052');
            z_im=lcaGet('SIOC:SYS1:ML00:CALCOUT053');
            m12_req=lcaGet('SIOC:SYS1:ML00:CALCOUT054');
            m34_req=lcaGet('SIOC:SYS1:ML00:CALCOUT055');
            [isok, BDES0, BDES1, BDES2] = E300_calc_QS_3(z_ob, z_im, E-10, m12_req, m34_req); % Note that the 3rd parameter (energy) is entered with repect to 10 GeV.
            
            caput(obj.pvs.control,value);
            obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', obj.pvs.control.name, value));
            
            quadPV.control_PV0  = "LGPS:LI20:3141";
            quadPV.control_PV1  = "LGPS:LI20:3261";
            quadPV.control_PV2  = "LGPS:LI20:3091";
            quadPV.control_PV3  = "LGPS:LI20:3330"; % Added dipole
            quadPV.readback_PV0 = "LGPS:LI20:3141";
            quadPV.readback_PV1 = "LGPS:LI20:3261";
            quadPV.readback_PV2 = "LGPS:LI20:3091";
            quadPV.readback_PV3 = "LGPS:LI20:3330"; % Added dipole
            
            
            dipole_value = lcaGet(obj.ratio_PV) * value;
            
            
            
            try
                control_magnetSet(obj.dipole_control_PV,dipole_value);
            catch
                % try again:
                obj.daqhandle.dispMessage(sprintf('First attempt setting %s failed, try once more', obj.dipole_control_PV));
                control_magnetSet(obj.dipole_control_PV,dipole_value); 
            end
            
            
            current_value_dipole = control_magnetGet(obj.dipole_readback_PV);
            
            while abs(current_value_dipole - dipole_value) > obj.tolerance_dipole
                current_value_dipole = control_magnetGet(obj.dipole_readback_PV);
                pause(0.4);
            end
            
            delta = current_value_dipole - dipole_value;
            obj.daqhandle.dispMessage(sprintf('%s readback is %0.2f', obj.dipole_readback_PV, current_value_dipole));
            
            
            
            if isok
                [delta] = set_Spec_QuadDipole(obj, quadPV, [BDES0, BDES1, BDES2, E]');
            else
                obj.daqhandle.dispMessage('BDES out of range: Q0D = %.2f, Q1D = %.2f, Q2D = %.2f', BDES0, BDES1, BDES2);
                % caput(obj.abort_PV,1);
                %delta = 100; % How do I stop a DAQ with an error?
            end
            
           
            
        end
        
        function restoreInitValue(obj)
            obj.daqhandle.dispMessage('NOT Restoring initial value. Sorry!');
            
        end
        
    end
    
end