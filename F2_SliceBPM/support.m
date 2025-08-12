classdef support < handle
    events
        PVUpdated % PV object list notifies this event after each set of monitored PVs have finished updating
    end
    properties
        pvlist PV
        pvs
        guihan
        listeners
        %elogtext = 'Custom Values';
    end

    properties(Constant)
    end
    
    methods
        function obj = support(apph)

            %addpath('../F2_DAQ/');
            %addpath('../common/');
            
            % Check if scanfunc called by DAQ
         

            %pulls pvs and creates a structured list with them
            context = PV.Initialize(PVtype.EPICS_labca);
            obj.pvlist=[...
                PV(context,'name',"NotchCol_LLS",'pvname',"COLL:LI20:2069:MOTR.LLS",'monitor',true,'mode',"rw") %Jaw Collimator Left Readback
                          ];    
            pset(obj.pvlist,'debug',0);
            obj.pvs = struct(obj.pvlist);

            % Associate class with GUI 
            obj.guihan=apph;
            

            % Set GUI callbacks for PVs
            obj.pvs.NotchCol_LLS.guihan = apph.LLS;


         
            % Start listening for PV updates
            obj.listeners = addlistener(obj,'PVUpdated',@(~,~) obj.loop) ;
            run(obj.pvlist,true,0.1,obj,'PVUpdated');

          
        end

        function loop(obj)
            disp('loop() called');

            caget(obj.pvs.NotchCol_LLS);

             %Pulls currentl LLS value
            LLS_status = obj.pvs.NotchCol_LLS.val{1};
            

            %Live Panel Update
            if LLS_status == 1
                obj.guihan.LLS.Visible = 'on';
                obj.guihan.LLS.Color = [1 0 0];
            else
                obj.guihan.LLS.Visible = 'off';
            end
        end

       
    end
    
end