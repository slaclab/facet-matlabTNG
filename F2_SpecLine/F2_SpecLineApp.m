classdef F2_SpecLineApp < handle
    events
        PVUpdated % PV object list notifies this event after each set of monitored PVs have finished updating
    end
    properties
        pvlist PV
        pvs
        guihan
    end
    properties(Hidden)
        listeners
    end
    properties(Constant)
        maxbeat=1e7 % max heartbeat count, wrap to zero
        defaultEnergy=10
        magnets={'LI20:LGPS:3141';'LI20:LGPS:3261';'LI20:LGPS:3091'; 'LGPS:LI20:3330'}
    end
    
    methods
        
        function obj = F2_SpecLineApp(apph)
            
            addpath('../F2_DAQ/');
            
            % initialize object and add PVs to be monitored
            context = PV.Initialize(PVtype.EPICS) ;
            obj.pvlist=[...
                PV(context,'name',"Energy",'pvname',"SIOC:SYS1:ML00:CALCOUT051",'monitor',true,'mode',"rw"); % Spec energy setting
                PV(context,'name',"Z_Object",'pvname',"SIOC:SYS1:ML00:CALCOUT052",'monitor',true,'mode',"rw"); % Object plane
                PV(context,'name',"Z_Image",'pvname',"SIOC:SYS1:ML00:CALCOUT053",'monitor',true,'mode',"rw"); % Image Plane
                PV(context,'name',"M12",'pvname',"SIOC:SYS1:ML00:CALCOUT054",'monitor',true,'mode',"rw"); % M12
                PV(context,'name',"M34",'pvname',"SIOC:SYS1:ML00:CALCOUT055",'monitor',true,'mode',"rw"); % M34
                %PV(context,'name',"incl_dipole",'pvname',"SIOC:SYS1:ML00:CALCOUT056",'monitor',true,'mode',"rw"); % Include dipole
                PV(context,'name',"Q0D_BDES",'pvname',"LI20:LGPS:3141:BDES",'monitor',true,'mode',"rw"); % Q0D BDES
                PV(context,'name',"Q0D_BACT",'pvname',"LI20:LGPS:3141:BACT",'monitor',true,'mode',"r"); % Q0D BACT
                PV(context,'name',"Q1D_BDES",'pvname',"LI20:LGPS:3261:BDES",'monitor',true,'mode',"rw"); % Q1D BDES
                PV(context,'name',"Q1D_BACT",'pvname',"LI20:LGPS:3261:BACT",'monitor',true,'mode',"r"); % Q1D BACT
                PV(context,'name',"Q2D_BDES",'pvname',"LI20:LGPS:3091:BDES",'monitor',true,'mode',"rw"); % Q2D BDES
                PV(context,'name',"Q2D_BACT",'pvname',"LI20:LGPS:3091:BACT",'monitor',true,'mode',"r"); % Q2D BACT
                PV(context,'name',"Q5D_BDES",'pvname',"LI20:LGPS:3330:BDES",'monitor',true,'mode',"rw"); % Q5D BDES
                PV(context,'name',"Q5D_BACT",'pvname',"LI20:LGPS:3330:BACT",'monitor',true,'mode',"r"); % Q5D BACT
                ] ;
            pset(obj.pvlist,'debug',0) ;
            obj.pvs = struct(obj.pvlist);
            
            % Associate class with GUI
            obj.guihan=apph;
            
            % Set GUI callbacks for PVs
            obj.pvs.Energy.guihan = apph.EnergyEditField;
            obj.pvs.Z_Object.guihan = apph.ZObjectEditField;
            obj.pvs.Z_Image.guihan = apph.ZImageEditField;
            obj.pvs.M12.guihan = apph.M12EditField;
            obj.pvs.M34.guihan = apph.M34EditField;
            %obj.pvs.incl_dipole.guihan = apph.DipoleSwitch;

            
            obj.pvs.Q0D_BDES.guihan = apph.Q0DBDESEditField;
            obj.pvs.Q0D_BACT.guihan = apph.Q0DBACTField;
            obj.pvs.Q1D_BDES.guihan = apph.Q1DBDESEditField;
            obj.pvs.Q1D_BACT.guihan = apph.Q1DBACTField;
            obj.pvs.Q2D_BDES.guihan = apph.Q2DBDESEditField;
            obj.pvs.Q2D_BACT.guihan = apph.Q2DBACTField;
            obj.pvs.Q5D_BDES.guihan = apph.B5DBDESEditField;
            obj.pvs.Q5D_BACT.guihan = apph.B5DBACTField;
            
            % Start listening for PV updates
            obj.listeners = addlistener(obj,'PVUpdated',@(~,~) obj.loop) ;
            run(obj.pvlist,true,0.1,obj,'PVUpdated');
            
            disp('hello from Doug s folder');
            
            
            
        end
        
        function loop(obj)
            
            caget(obj.pvs.Energy);
            
            return
            
        end
        
        function CalcAndTrim(obj)
            
            E = caget(obj.pvs.Energy);
            Z_Obj = caget(obj.pvs.Z_Object);
            Z_Img = caget(obj.pvs.Z_Image);
            M12 = caget(obj.pvs.M12);
            M34 = caget(obj.pvs.M34);
            %incl_dipole = caget(obj.pvs.incl_dipole);
            incl_dipole = lcaGetSmart('SIOC:SYS1:ML00:CALCOUT056');
            
            DeltaE = E - obj.defaultEnergy;
            
            disp('Got Values!');
            disp(['Energy = ' num2str(E)]);
            disp(['Z_Obj = ' num2str(Z_Obj)]);
            disp(['Z_Img = ' num2str(Z_Img)]);
            disp(['M12 = ' num2str(M12)]);
            disp(['M34 = ' num2str(M34)]);
            disp(['Include dipole = ' num2str(incl_dipole)]);
            
            [isok, BDES0, BDES1, BDES2] = E300_calc_QS_3(Z_Obj, Z_Img, DeltaE, M12, M34);
            
            if ~isok
                error('Not OK!');
            end
            
            disp('Setting magnets!');
            disp(['QD0 = ' num2str(BDES0)]);
            disp(['QD1 = ' num2str(BDES1)]);
            disp(['QD2 = ' num2str(BDES2)]);
            
            if incl_dipole == 1
               control_magnetSet(obj.magnets,[BDES0; BDES1; BDES2; E],'action','TRIM');
            else
               control_magnetSet(obj.magnets(1:3),[BDES0; BDES1; BDES2],'action','TRIM');
            end
            disp('Magnets set!');
                        
            
        end
        
        
    end
    
end