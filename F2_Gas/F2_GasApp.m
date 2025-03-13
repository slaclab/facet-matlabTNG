classdef F2_GasApp < handle
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

    end
    
    methods
        
        function obj = F2_GasApp(apph)
            
      
         % initialize object and add PVs to be monitored
            context = PV.Initialize(PVtype.EPICS) ;
            obj.pvlist=[...
                PV(context,'name',"Pressure",'pvname',"VGCM:LI20:M3203:PMONRAW",'monitor',true,'mode',"r"); % Spec energy setting
                PV(context,'name',"MFC_SetPoint",'pvname',"VMFC:LI20:3205:FLOW_SP",'monitor',true,'mode',"rw"); % Spec energy setting
                PV(context,'name',"MFC_RBV",'pvname',"VMFC:LI20:3205:FLOW_SP_RBCK",'monitor',true,'mode',"r"); % Spec energy setting
                PV(context,'name',"EPS",'pvname',"VVFL:LI20:M3201:STATUS",'monitor',true,'mode',"r"); % Spec energy setting
                ] ;
            pset(obj.pvlist,'debug',0) ;
            obj.pvs = struct(obj.pvlist);
            
            % Associate class with GUI
            obj.guihan=apph;
            
            % Set GUI callbacks for PVs
    %        obj.pvs.Energy.guihan = apph.EnergyEditField;
     
            
            obj.pvs.Pressure.guihan = apph.IPpressureRBVEditField;
            obj.pvs.MFC_SetPoint.guihan = apph.MFCSetPointEditField;
            obj.pvs.MFC_RBV.guihan = apph.FlowRateRBVEditField;
            obj.pvs.EPS.guihan = apph.EPSStatusLamp;
            
            
            % Start listening for PV updates
            obj.listeners = addlistener(obj,'PVUpdated',@(~,~) obj.loop) ;
            run(obj.pvlist,true,0.1,obj,'PVUpdated');  
            
            
        end
        
        function loop(obj)
           
                    
                    
            
            return
          
            
        end
        
        function PIDloop(obj,app)
           
            
            
            
        end
        
    end
    
end