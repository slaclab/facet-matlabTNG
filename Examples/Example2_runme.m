function Example2_runme(cmd)
%EXAMPLE2_RUNME Function to launch and delete Example2 App
%
%Example2_runme('start')
%  Launch Example2 App and connect to EPICS PVs
%
% Example2_runme('stop')
%  Shutdown EPICS connections and delet the running Example2 App
persistent app context pvlist

switch cmd
  case 'start'
    
    % Launch app and capture application object containing component fields
    app = Example2 ;
    
    % generate a (java) context object, required by the PV class to perform read/write operations to EPICS PV channels using a java CA client
    % (NB: this should be called only once per Matlab session)
    context = PV.Initialize(PVtype.EPICS) ;
    
    % Generate list of PV objects and associate with app components
    %  'name' field is user-supplied name to refer to this PV channel locally
    %  'pvname' field should be EPICS PV name
    %  'monitor' field should be set to true to automatically update the local PV values (starts when you call the run() method)
    %  'guihan' field is the App Designer component to associate with a given PV channel
    %  'mode' field should be set to "rw" if you want to be able to write to this PV
    pvlist = [ PV(context,'name',"LampPV",'pvname',"SIOC:SYS1:ML00:AO956",'monitor',true,'guihan',app.Lamp);
      PV(context,'name',"ToggleSwitchPV",'pvname',"SIOC:SYS1:ML00:AO956",'monitor',true,'guihan',app.ToggleSwitch);
      PV(context,'name',"SwitchPV",'pvname',"SIOC:SYS1:ML00:AO956",'monitor',true,'guihan',app.Switch);
      PV(context,'name',"RockerSwitchPV",'pvname',"SIOC:SYS1:ML00:AO956",'monitor',true,'guihan',app.RockerSwitch);
      PV(context,'name',"NumericEditFieldPV",'pvname',"SIOC:SYS1:ML00:AO956",'monitor',true,'guihan',app.NumericEditField);
      PV(context,'name',"WriteableNumericEditFieldPV",'pvname',"SIOC:SYS1:ML00:AO956",'monitor',true,'guihan',app.WritableNumericEditField,'mode',"rw");
      PV(context,'name',"LinearGaugePV",'pvname',"SIOC:SYS1:ML00:AO953",'monitor',true,'guihan',app.LinearGauge);
      PV(context,'name',"GaugePV",'pvname',"SIOC:SYS1:ML00:AO953",'monitor',true,'guihan',app.Gauge);
      PV(context,'name',"NinetyDegreeGaugePV",'pvname',"SIOC:SYS1:ML00:AO953",'monitor',true,'guihan',app.NinetyDegreegaugeGauge);
      PV(context,'name',"SemicircularGaugePV",'pvname',"SIOC:SYS1:ML00:AO953",'monitor',true,'guihan',app.SemiCircularGauge);
      PV(context,'name',"StateButtonPV",'pvname',"SIOC:SYS1:ML00:AO956",'monitor',true,'guihan',app.StateButton) ] ;
    pset(pvlist,'debug',0) ; % Set debug level to 0 to enable read/write operations (make PV objects live)
    % start timer which keeps local values of PV data updated and updates GUI field. async=true option uses asnchronous get methods (non blocking)
    run(pvlist,true,0.02); % (async, polltime) - set polling time to a value (s) less than the fastest rate at which you expect PV values to be changing
    
  case 'stop'
    
    % Perform 1-time java EPICS CA cleanup actions and delete app
    stop(pvlist); % Stop timers used to auto update PV fields
    Cleanup(pvlist); % Cleanup java objects used for PV access
    delete(app);
    
end