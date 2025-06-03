classdef F2_OvenWatcherApp < handle
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
        
        function obj = F2_OvenWatcherApp(apph)
            
      
         % initialize object and add PVs to be monitored
            context = PV.Initialize(PVtype.EPICS) ;
            obj.pvlist=[...
                PV(context,'name',"IPPressure",'pvname',"VGCM:LI20:M3203:PMONRAW",'monitor',true,'mode',"r");
                PV(context,'name',"TC4",'pvname',"OVEN:LI20:3185:TEMP4",'monitor',true,'mode',"r");
                PV(context,'name',"TC3",'pvname',"OVEN:LI20:3185:TEMP3",'monitor',true,'mode',"r");
                PV(context,'name',"TC2",'pvname',"OVEN:LI20:3185:TEMP2",'monitor',true,'mode',"r");
                PV(context,'name',"TC1",'pvname',"OVEN:LI20:3185:TEMP1",'monitor',true,'mode',"r");
                PV(context,'name',"TC5",'pvname',"OVEN:LI20:3185:TEMP5",'monitor',true,'mode',"r");
                PV(context,'name',"TC6",'pvname',"OVEN:LI20:3185:TEMP6",'monitor',true,'mode',"r");
                PV(context,'name',"TC7",'pvname',"BMLN:LI20:3184:TEMP",'monitor',true,'mode',"r");
                PV(context,'name',"TC8",'pvname',"BMLN:LI20:3186:TEMP",'monitor',true,'mode',"r");
                
                PV(context,'name',"TC1highLimit",'pvname',"SIOC:SYS1:ML02:AO551",'monitor',true,'mode',"rw");
                PV(context,'name',"TC2highLimit",'pvname',"SIOC:SYS1:ML02:AO552",'monitor',true,'mode',"rw");
                PV(context,'name',"TC3highLimit",'pvname',"SIOC:SYS1:ML02:AO553",'monitor',true,'mode',"rw");
                PV(context,'name',"TC4highLimit",'pvname',"SIOC:SYS1:ML02:AO554",'monitor',true,'mode',"rw");
                PV(context,'name',"TC5highLimit",'pvname',"SIOC:SYS1:ML02:AO555",'monitor',true,'mode',"rw");
                PV(context,'name',"TC6highLimit",'pvname',"SIOC:SYS1:ML02:AO556",'monitor',true,'mode',"rw");
                PV(context,'name',"TC7highLimit",'pvname',"SIOC:SYS1:ML02:AO557",'monitor',true,'mode',"rw");
                PV(context,'name',"TC8highLimit",'pvname',"SIOC:SYS1:ML02:AO558",'monitor',true,'mode',"rw");
                
                ] ;
            pset(obj.pvlist,'debug',0) ;
            obj.pvs = struct(obj.pvlist);
            
            % Associate class with GUI
            obj.guihan=apph;
            
            % Set GUI callbacks for PVs
    %        obj.pvs.Energy.guihan = apph.EnergyEditField;
     
            
            obj.pvs.IPPressure.guihan = apph.IPPressure;
            obj.pvs.TC4.guihan = apph.TC4;
            obj.pvs.TC3.guihan = apph.TC3;
            obj.pvs.TC2.guihan = apph.TC2;
            obj.pvs.TC1.guihan = apph.TC1;
            obj.pvs.TC5.guihan = apph.TC5;
            obj.pvs.TC6.guihan = apph.TC6;
            obj.pvs.TC7.guihan = apph.TC7;
            obj.pvs.TC8.guihan = apph.TC8;
            
            obj.pvs.TC4highLimit.guihan = apph.TC4highLimit;
            obj.pvs.TC3highLimit.guihan = apph.TC3highLimit;
            obj.pvs.TC2highLimit.guihan = apph.TC2highLimit;
            obj.pvs.TC1highLimit.guihan = apph.TC1highLimit;
            obj.pvs.TC5highLimit.guihan = apph.TC5highLimit;
            obj.pvs.TC6highLimit.guihan = apph.TC6highLimit;
            obj.pvs.TC7highLimit.guihan = apph.TC7highLimit;
            obj.pvs.TC8highLimit.guihan = apph.TC8highLimit;
            
            % Start listening for PV updates
            obj.listeners = addlistener(obj,'PVUpdated',@(~,~) obj.loop) ;
            run(obj.pvlist,true,0.1,obj,'PVUpdated');  
            
            
        end
        
        function loop(obj)
                   
            
            return
          
            
        end
        
  
        
    end
    
end