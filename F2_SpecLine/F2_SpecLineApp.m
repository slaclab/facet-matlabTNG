classdef F2_SpecLineApp < handle
    events
        PVUpdated % PV object list notifies this event after each set of monitored PVs have finished updating
    end
    properties
        pvlist PV
        pvs
        guihan
        elogtext = 'Custom Values';
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
        
        function Calc(obj,app)
            
            E = caget(obj.pvs.Energy);
            Z_Obj = caget(obj.pvs.Z_Object);
            Z_Img = caget(obj.pvs.Z_Image);
            M12 = caget(obj.pvs.M12);
            M34 = caget(obj.pvs.M34);
            incl_dipole = lcaGetSmart('SIOC:SYS1:ML00:CALCOUT056');

            
            % Load the beamline map to check zob and zim positions
            % Set dropdown to custom if it is different from the table
            BL = IPmap(obj, app);
            indeleZob = find(BL.z==Z_Obj,1)
            if indeleZob~=0
                app.ZobDropDown.Value = BL.name{indeleZob};
            else
                app.ZobDropDown.Value = 'Custom';
            end
            indeleZim = find(BL.z==Z_Img,1);
            if indeleZim~=0
                app.ZimDropDown.Value = BL.name{indeleZim};
            else
                app.ZimDropDown.Value = 'Custom';
            end                
            
            
            
            DeltaE = E - obj.defaultEnergy;
            
            disp('Got Values!');
            disp(['Energy = ' num2str(E)]);
            disp(['Z_Obj = ' num2str(Z_Obj)]);
            disp(['Z_Img = ' num2str(Z_Img)]);
            disp(['M12 = ' num2str(M12)]);
            disp(['M34 = ' num2str(M34)]);
            disp(['Include dipole = ' num2str(incl_dipole)]);
            
            [isok, BCALC0, BCALC1, BCALC2] = E300_calc_QS_3(Z_Obj, Z_Img, DeltaE, M12, M34);
            
            if ~isok
                error('Not OK!');
            end
            
            disp('Calculated magnet settings!');
            disp(['QD0 = ' num2str(BCALC0)]);
            disp(['QD1 = ' num2str(BCALC1)]);
            disp(['QD2 = ' num2str(BCALC2)]);
            
            app.Q0DBCALCEditField.Value = BCALC0;
            app.Q1DBCALCEditField.Value = BCALC1;
            app.Q2DBCALCEditField.Value = BCALC2;
            updateLog(obj, app, {' Calculated magnet settings:', ['   Q0D = ' num2str(BCALC0)], ['   Q1D = ' num2str(BCALC1)], ['   Q2D = ' num2str(BCALC2)]});
            
            if incl_dipole == 1
                disp(['Dipole = ' num2str(E)]);
                app.B5DBCALCEditField.Value = E;
                updateLog(obj, app, {[' Dipole will be changed to ' num2str(E)]});
            else
                app.B5DBCALCEditField.Value = app.B5DBDESEditField.Value;
            end
            
            obj.elogtext = sprintf('\n\nE = %0.2f, Zob = %s (%0.2fm), Zim = %s (%0.2fm), M12 = %0.2f, M34 = %0.2f',...
                                   app.EnergyEditField.Value, app.ZobDropDown.Value, app.ZObjectEditField.Value, app.ZimDropDown.Value, app.ZImageEditField.Value, app.M12EditField.Value, app.M34EditField.Value);
            
            
        end
        
        function Trim(obj,app)
            
            % Read the values in BCALC and trim the magnets.
            % This allows you to enter values manually
            
%            incl_dipole = lcaGetSmart('SIOC:SYS1:ML00:CALCOUT056');
            
            E     = app.B5DBCALCEditField.Value;
            BDES0 = app.Q0DBCALCEditField.Value;
            BDES1 = app.Q1DBCALCEditField.Value;
            BDES2 = app.Q2DBCALCEditField.Value;
            
            
         
            disp('Setting magnets!');
            disp(['QD0 = ' num2str(BDES0)]);
            disp(['QD1 = ' num2str(BDES1)]);
            disp(['QD2 = ' num2str(BDES2)]);
            disp(['Dipole = ' num2str(E)]);
            
    %        if incl_dipole == 1
    %           disp(['Dipole = ' num2str(E)]);
               updateLog(obj, app, {' Setting magnets:', ['   Q0D = ' num2str(BDES0)], ['   Q1D = ' num2str(BDES1)], ['   Q2D = ' num2str(BDES2)], ['   Dipole = ' num2str(E)]});
               pause(0.1);
               updateLog(obj, app, {'  Waiting for SLC magnet trim...'}); pause(0.1);
               
               control_magnetSet(obj.magnets,[BDES0; BDES1; BDES2; E],'action','TRIM');
    %        else
    %            updateLog(obj, app, {' Setting magnets:', [' Q0D = ' num2str(BDES0)], [' Q1D = ' num2str(BDES1)], [' Q2D = ' num2str(BDES2)]});
    %            control_magnetSet(obj.magnets(1:3),[BDES0; BDES1; BDES2],'action','TRIM');
    %        end
            
            disp('Magnets set!');
            updateLog(obj, app, 'Magnets set!')
            
        end
        
        function updateLog(obj, app, msg)
           % add an entry to the end of the log
           t = char(datetime('now','TimeZone','local','Format','dd-MMM-yyyy HH:mm:ss'));
           
           if iscell(msg)
               app.LogTextArea.Value = {[t ': '], msg{:}, app.LogTextArea.Value{:}};
           else
            app.LogTextArea.Value = {[t ':  ' msg], app.LogTextArea.Value{:}};
           end
           
           % app.LogTextArea.scroll('bottom');
        end
        
            %% Calculate the transport matrices
        function M = calc_TransportMatrix(obj, app)

            zob = app.ZObjectEditField.Value;
            zim = app.ZImageEditField.Value;
            PS_Q0D = app.Q0DBACTField.Value;
            PS_Q1D = app.Q1DBACTField.Value;
            PS_Q2D = app.Q2DBACTField.Value;
            E = app.EnergyEditField.Value;    
            
            
            % Define magnet positions
            zQ0D = 1996.98244;
            zQ1D = 1999.20656;
            zQ2D = 2001.43099;
            
            addpath('../F2_Emit');
            load 'SpecBeamline.mat'
            

            % Find where everything is
            Q0D =findcells(BEAMLINE,'Name','Q0D');
            Q1D =findcells(BEAMLINE,'Name','Q1D');
            Q2D =findcells(BEAMLINE,'Name','Q2D');
            
            % Adjust the positions of things, and set magnet strengths
            BEAMLINE{1} = BEAMLINE{Q0D(1)-2}; BEAMLINE{1}.S = zob;
            
            BEAMLINE{2} = BEAMLINE{Q0D(1)-1};  BEAMLINE{2}.L = zQ0D-zob - 0.5;
            BEAMLINE{3} = BEAMLINE{Q0D(1)};    BEAMLINE{3}.B = PS_Q0D/10/2;
            BEAMLINE{4} = BEAMLINE{Q0D(2)};    BEAMLINE{4}.B = PS_Q0D/10/2;
            
            BEAMLINE{5} = BEAMLINE{Q1D(1)-1};  BEAMLINE{5}.L = zQ1D- zQ0D - 1;
            BEAMLINE{6} = BEAMLINE{Q1D(1)};    BEAMLINE{6}.B = PS_Q1D/10/2;
            BEAMLINE{7} = BEAMLINE{Q1D(2)};    BEAMLINE{7}.B = PS_Q1D/10/2;
            
            BEAMLINE{8} = BEAMLINE{Q2D(1)-1};  BEAMLINE{8}.L = zQ2D - zQ1D - 1;
            BEAMLINE{9} = BEAMLINE{Q2D(1)};    BEAMLINE{9}.B = PS_Q2D/10/2;
            BEAMLINE{10} = BEAMLINE{Q2D(2)};   BEAMLINE{10}.B = PS_Q2D/10/2;
            
            BEAMLINE{11} = BEAMLINE{Q2D(2)+1}; BEAMLINE{11}.L = zim - zQ2D - 0.5;
            BEAMLINE{12} = BEAMLINE{Q2D(2)+2}; 
            
            % Fix all S positions
            SetSPositions( 1, length(BEAMLINE),  BEAMLINE{1}.S);
            


            % Set the energy of each element
            for i =1:length(BEAMLINE)
                BEAMLINE{i}.P = E;
            end
          
            % Calculate the transport matrix
            [~,M]=RmatAtoB(1, length(BEAMLINE));
        
        end
        
        
        function z = set_Z(obj, app, dropdown)
            
            ele = app.(dropdown).Value;
            
            % Load the beamline set_Zmap
            beamline = IPmap(obj, app);
            indele = find(strcmp(beamline.name, ele),1);
            
            if indele>0
                z = beamline.z(indele);
            else
                z=0;
            end
            
        end
        
        function beamline = IPmap(obj, app)
            % Beamline map
            
            beamline.name = {};
            beamline.z = [];
            beamline.name{end+1}='DTOTR';    beamline.z(end+1) = 2.0152598e+03;
            beamline.name{end+1}='LFOV';     beamline.z(end+1) = 2.0156298e+03;
            beamline.name{end+1}='CHER';     beamline.z(end+1) = 2.0162200e+03;
            beamline.name{end+1}='PRDMP';    beamline.z(end+1) = 2.0175299e+03;
            beamline.name{end+1}='EDC_SCREEN';   beamline.z(end+1) = 2.0104999e+03;
            beamline.name{end+1}='PIC_CENT'; beamline.z(end+1) = 1.9928200e+03;
            beamline.name{end+1}='FILS';     beamline.z(end+1) = 1.9932737e+03;
            beamline.name{end+1}='FILG';     beamline.z(end+1) = 1.9932217e+03;
            beamline.name{end+1}='IPOTR1P';  beamline.z(end+1) = 1.9937400e+03;
            beamline.name{end+1}='IPOTR1';   beamline.z(end+1) = 1.9938300e+03;
            beamline.name{end+1}='IPWS1';    beamline.z(end+1) = 1.9939100e+03;
            beamline.name{end+1}='PENT';     beamline.z(end+1) = 1.9938700e+03;
            beamline.name{end+1}='PEXT';     beamline.z(end+1) = 1.9950400e+03;
            beamline.name{end+1}='IPOTR2';   beamline.z(end+1) = 1.9950900e+03;
            beamline.name{end+1}='BEWIN2';   beamline.z(end+1) = 1.9961000e+03;
        end
     
        
    end
    
end