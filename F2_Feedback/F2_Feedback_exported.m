classdef F2_Feedback_exported < matlab.apps.AppBase

  % Properties that correspond to app components
  properties (Access = public)
    FACETIIFeedbackUIFigure         matlab.ui.Figure
    StripchartsMenu                 matlab.ui.container.Menu
    DL1EnergyMenu                   matlab.ui.container.Menu
    BC11EnergyMenu                  matlab.ui.container.Menu
    BC11BLENMenu                    matlab.ui.container.Menu
    BC14EnergyMenu                  matlab.ui.container.Menu
    BC14BLENMenu                    matlab.ui.container.Menu
    BC20EnergyMenu                  matlab.ui.container.Menu
    SettingsMenu                    matlab.ui.container.Menu
    DL10EnergyFeedbackMenu          matlab.ui.container.Menu
    BC11EnergyFeedbackMenu          matlab.ui.container.Menu
    BC11BLENFeedbackMenu            matlab.ui.container.Menu
    BC14EnergyFeedbackMenu          matlab.ui.container.Menu
    BC14BLENFeedbackMenu            matlab.ui.container.Menu
    BC20EnergyFeedbackMenu          matlab.ui.container.Menu
    RestoreallactuatorsMenu         matlab.ui.container.Menu
    JitterTimeoutMenu               matlab.ui.container.Menu
    HelpMenu                        matlab.ui.container.Menu
    ActuatorReadbackPVsMenu         matlab.ui.container.Menu
    DL10SIOCSYS1ML01AO257Menu       matlab.ui.container.Menu
    BC14ESIOCSYS1ML01AO258Menu      matlab.ui.container.Menu
    BC11ESIOCSYS1ML01AO259Menu      matlab.ui.container.Menu
    BC11_BLENSIOCSYS1ML01AO260Menu  matlab.ui.container.Menu
    BC20ESIOCSYS1ML01AO261Menu      matlab.ui.container.Menu
    BC14_BLENSIOCSYS1ML01AO262Menu  matlab.ui.container.Menu
    DL10EnergyFeedbackPanel         matlab.ui.container.Panel
    SetpointEditField               matlab.ui.control.NumericEditField
    keVLabel                        matlab.ui.control.Label
    Gauge                           matlab.ui.control.LinearGauge
    StatusLamp                      matlab.ui.control.Lamp
    Switch                          matlab.ui.control.Switch
    Gauge_3                         matlab.ui.control.LinearGauge
    KLYSIN1041SFB_ADESLabel         matlab.ui.control.Label
    SIOCSYS1ML01AO606Label          matlab.ui.control.Label
    EditField                       matlab.ui.control.NumericEditField
    EditField_2                     matlab.ui.control.NumericEditField
    NotRunningButton                matlab.ui.control.Button
    FeedbackJitterButton            matlab.ui.control.StateButton
    ADESJitterAmplitudeEditFieldLabel  matlab.ui.control.Label
    JitAmpEdit                      matlab.ui.control.NumericEditField
    ActuatorRestoreToDate_DL10      matlab.ui.control.Button
    BC14EnergyFeedbackPanel         matlab.ui.container.Panel
    SetpointEditField_2             matlab.ui.control.NumericEditField
    mmLabel_4                       matlab.ui.control.Label
    Switch_2                        matlab.ui.control.Switch
    StatusLamp_2                    matlab.ui.control.Lamp
    BC14_C1Lab                      matlab.ui.control.Label
    BC14_C2Lab                      matlab.ui.control.Label
    BPMSLI14801X1HLabel             matlab.ui.control.Label
    EditField_5                     matlab.ui.control.NumericEditField
    EditField_6                     matlab.ui.control.NumericEditField
    NotRunningButton_5              matlab.ui.control.Button
    Gauge_16                        matlab.ui.control.NinetyDegreeGauge
    Gauge_17                        matlab.ui.control.NinetyDegreeGauge
    Gauge_6                         matlab.ui.control.LinearGauge
    MKBLabel_2                      matlab.ui.control.Label
    DropDown_2                      matlab.ui.control.DropDown
    ActuatorRestoreToDate_BC14E     matlab.ui.control.Button
    ActuatorReset_BC14E             matlab.ui.control.Button
    BC20EnergyFeedbackPanel         matlab.ui.container.Panel
    SetpointEditField_4             matlab.ui.control.NumericEditField
    MeVLabel                        matlab.ui.control.Label
    Switch_4                        matlab.ui.control.Switch
    StatusLamp_4                    matlab.ui.control.Lamp
    SIOCSYS1ML01AO624Label          matlab.ui.control.Label
    EditField_8                     matlab.ui.control.NumericEditField
    NotRunningButton_6              matlab.ui.control.Button
    MKBLabel                        matlab.ui.control.Label
    DropDown                        matlab.ui.control.DropDown
    BC20_C1Lab                      matlab.ui.control.Label
    BC20_C2Lab                      matlab.ui.control.Label
    Gauge_19                        matlab.ui.control.NinetyDegreeGauge
    Gauge_20                        matlab.ui.control.NinetyDegreeGauge
    EditField_17                    matlab.ui.control.NumericEditField
    Gauge_7                         matlab.ui.control.LinearGauge
    ActuatorRestoreToDate_BC20E     matlab.ui.control.Button
    ActuatorReset_BC20E             matlab.ui.control.Button
    BC11EnergyFeedbackPanel         matlab.ui.container.Panel
    SetpointEditField_5             matlab.ui.control.NumericEditField
    mmLabel_6                       matlab.ui.control.Label
    StatusLamp_5                    matlab.ui.control.Lamp
    Switch_5                        matlab.ui.control.Switch
    Gauge_9                         matlab.ui.control.LinearGauge
    KLYSLI111121SSSB_ADESLabel      matlab.ui.control.Label
    BPMSLI11333X1HLabel             matlab.ui.control.Label
    EditField_11                    matlab.ui.control.NumericEditField
    EditField_12                    matlab.ui.control.NumericEditField
    NotRunningButton_3              matlab.ui.control.Button
    Gauge_8                         matlab.ui.control.LinearGauge
    ActuatorRestoreToDate_BC11E     matlab.ui.control.Button
    BC11BunchLengthFeedbackPanel    matlab.ui.container.Panel
    SetpointEditField_6             matlab.ui.control.NumericEditField
    fsLabel_2                       matlab.ui.control.Label
    StatusLamp_6                    matlab.ui.control.Lamp
    Switch_6                        matlab.ui.control.Switch
    Gauge_11                        matlab.ui.control.LinearGauge
    KLYSLI111121SSSB_PDESLabel      matlab.ui.control.Label
    BLENLI11359Label                matlab.ui.control.Label
    EditField_13                    matlab.ui.control.NumericEditField
    EditField_14                    matlab.ui.control.NumericEditField
    NotRunningButton_4              matlab.ui.control.Button
    Gauge_10                        matlab.ui.control.LinearGauge
    ActuatorRestoreToDate_BC11_BLEN  matlab.ui.control.Button
    BC14BunchLengthFeedbackPanel    matlab.ui.container.Panel
    SetpointEditField_7             matlab.ui.control.NumericEditField
    fsLabel                         matlab.ui.control.Label
    Gauge_13                        matlab.ui.control.LinearGauge
    L2PHASELabel                    matlab.ui.control.Label
    BLENLI14888Label                matlab.ui.control.Label
    EditField_15                    matlab.ui.control.NumericEditField
    EditField_16                    matlab.ui.control.NumericEditField
    StatusLamp_7                    matlab.ui.control.Lamp
    NotRunningButton_7              matlab.ui.control.Button
    Switch_7                        matlab.ui.control.Switch
    Gauge_12                        matlab.ui.control.LinearGauge
    ActuatorRestoreToDate_BC14_BLEN  matlab.ui.control.Button
    FeedbackWatcherProcessStatusPanel  matlab.ui.container.Panel
    fbstat                          matlab.ui.control.Label
  end

  
  properties (Access = public)
    aobj % Helper App object
  end
  

  % Callbacks that handle component events
  methods (Access = private)

    % Code that executes after component creation
    function startupFcn(app, arg1)
      app.aobj = F2_FeedbackApp(app) ; % generate helper object
    end

    % Value changed function: Switch
    function SwitchValueChanged(app, event)
      disp('Setting DL FB Enable...');
      value = string(app.Switch.Value) == "On" ;
      caput(app.aobj.pvs.FeedbackEnable,double(bitset(app.aobj.Enabled,1,double(value))));
      disp('Done.');
    end

    % Menu selected function: DL1EnergyMenu
    function DL1EnergyMenuSelected(app, event)
      !StripTool /u1/facet/tools/StripTool/config/FB_DL1_E.stp &
    end

    % Menu selected function: DL10EnergyFeedbackMenu
    function DL10EnergyFeedbackMenuSelected(app, event)
      app.DL10EnergyFeedbackMenu.Enable = false ;
      DL1E_Settings(app.aobj);
      drawnow;
    end

    % Value changed function: SetpointEditField
    function SetpointEditFieldValueChanged(app, event)
      value = app.SetpointEditField.Value;
      caput(app.aobj.pvs.DL1E_Offset,value) ;
      app.aobj.SetpointOffsets(1) = value ;
    end

    % Close request function: FACETIIFeedbackUIFigure
    function FACETIIFeedbackUIFigureCloseRequest(app, event)
      app.aobj.shutdown;
      delete(app)
    end

    % Value changed function: SetpointEditField_2
    function SetpointEditField_2ValueChanged(app, event)
      value = app.SetpointEditField_2.Value;
      caput(app.aobj.pvs.BC14E_Offset,value) ;
      app.aobj.SetpointOffsets(2) = value ;
    end

    % Menu selected function: BC14EnergyMenu
    function BC14EnergyMenuSelected(app, event)
      !StripTool /u1/facet/tools/StripTool/config/FB_BC14_E.stp &
    end

    % Menu selected function: BC14EnergyFeedbackMenu
    function BC14EnergyFeedbackMenuSelected(app, event)
      app.BC14EnergyFeedbackMenu.Enable = false ;
      BC14E_Settings(app.aobj);
      drawnow
    end

    % Value changed function: Switch_2
    function Switch_2ValueChanged(app, event)
      value = string(app.Switch_2.Value) == "On" ;
      caput(app.aobj.pvs.FeedbackEnable,double(bitset(app.aobj.Enabled,2,value)));
    end

    % Menu selected function: BC11EnergyFeedbackMenu
    function BC11EnergyFeedbackMenuSelected(app, event)
      app.BC11EnergyFeedbackMenu.Enable = false ;
      BC11E_Settings(app.aobj);
      drawnow
    end

    % Value changed function: Switch_5
    function Switch_5ValueChanged(app, event)
      value = string(app.Switch_5.Value) == "On" ;
      caput(app.aobj.pvs.FeedbackEnable,double(bitset(app.aobj.Enabled,3,value)));
    end

    % Value changed function: SetpointEditField_5
    function SetpointEditField_5ValueChanged(app, event)
      value = app.SetpointEditField_5.Value;
      caput(app.aobj.pvs.BC11E_Offset,value) ;
      app.aobj.SetpointOffsets(3) = value ;
    end

    % Menu selected function: BC11EnergyMenu
    function BC11EnergyMenuSelected(app, event)
      !StripTool /u1/facet/tools/StripTool/config/FB_BC11_E.stp &
    end

    % Menu selected function: JitterTimeoutMenu
    function JitterTimeoutMenuSelected(app, event)
      resp=str2double(inputdlg('Enter Jitter Timeout (min)','Jitter Timeout',1,{'2'}));
      if ~isempty(resp)
        app.JitterTimeoutMenu.Text = sprintf('Jitter Timeout = %d min',round(resp)) ;
        caput(app.aobj.pvs.FB_JitterOnTime,resp);
      end
    end

    % Value changed function: FeedbackJitterButton
    function FeedbackJitterButtonValueChanged(app, event)
      value = app.FeedbackJitterButton.Value;
      caput(app.aobj.pvs.DL1E_JitterON,double(value));
    end

    % Value changed function: JitAmpEdit
    function JitAmpEditValueChanged(app, event)
      value = app.JitAmpEdit.Value;
      caput(app.aobj.pvs.DL1E_JitterAMP,double(value));
    end

    % Value changed function: Switch_6
    function Switch_6ValueChanged(app, event)
      value = string(app.Switch_6.Value) == "On" ;
      caput(app.aobj.pvs.FeedbackEnable,double(bitset(app.aobj.Enabled,4,value)));
    end

    % Menu selected function: BC11BLENFeedbackMenu
    function BC11BLENFeedbackMenuSelected(app, event)
      app.BC11BLENFeedbackMenu.Enable = false ;
      BC11BL_Settings(app.aobj);
      drawnow
    end

    % Value changed function: DropDown
    function DropDownValueChanged(app, event)
      value = app.DropDown.Value;
      app.aobj.BC20E_mkb = value ;
    end

    % Menu selected function: BC20EnergyFeedbackMenu
    function BC20EnergyFeedbackMenuSelected(app, event)
      app.BC20EnergyFeedbackMenu.Enable = false ;
      BC20E_Settings(app.aobj);
      drawnow
    end

    % Value changed function: DropDown_2
    function DropDown_2ValueChanged(app, event)
      value = app.DropDown_2.Value;
      app.aobj.BC14E_mkb = value ;
    end

    % Value changed function: Switch_4
    function Switch_4ValueChanged(app, event)
      value = string(app.Switch_4.Value) == "On" ;
      caput(app.aobj.pvs.FeedbackEnable,double(bitset(app.aobj.Enabled,5,value)));
    end

    % Value changed function: SetpointEditField_4
    function SetpointEditField_4ValueChanged(app, event)
      value = app.SetpointEditField_4.Value;
      caput(app.aobj.pvs.BC20E_Offset,value) ;
      app.aobj.SetpointOffsets(5) = value ;
    end

    % Value changed function: SetpointEditField_6
    function SetpointEditField_6ValueChanged(app, event)
      value = app.SetpointEditField_6.Value;
      caput(app.aobj.pvs.BC11BL_Offset,value) ;
      app.aobj.SetpointOffsets(4) = value ;
    end

    % Value changed function: SetpointEditField_7
    function SetpointEditField_7ValueChanged(app, event)
      value = app.SetpointEditField_7.Value;
      caput(app.aobj.pvs.BC14BL_Offset,value) ;
      app.aobj.SetpointOffsets(6) = value ;
      
    end

    % Menu selected function: BC20EnergyMenu
    function BC20EnergyMenuSelected(app, event)
      !StripTool /u1/facet/tools/StripTool/config/FB_BC20_E.stp &
    end

    % Menu selected function: BC14BLENFeedbackMenu
    function BC14BLENFeedbackMenuSelected(app, event)
      app.BC14BLENFeedbackMenu.Enable = false ;
      BC14BL_Settings(app.aobj);
      drawnow
    end

    % Menu selected function: BC11BLENMenu
    function BC11BLENMenuSelected(app, event)
      !StripTool /u1/facet/tools/StripTool/config/FB_BC11_BLEN.stp &
    end

    % Menu selected function: BC14BLENMenu
    function BC14BLENMenuSelected(app, event)
      !StripTool /u1/facet/tools/StripTool/config/FB_BC14_BLEN.stp &
    end

    % Value changed function: Switch_7
    function Switch_7ValueChanged(app, event)
      value = string(app.Switch_7.Value) == "On" ;
      caput(app.aobj.pvs.FeedbackEnable,double(bitset(app.aobj.Enabled,6,value)));
    end

    % Button pushed function: ActuatorRestoreToDate_DL10
    function ActuatorRestoreToDate_DL10Pushed(app, event)
      dval=uigetdate;
      if isempty(dval)
        return
      end
      % Switch off FB
      initstate = caget(app.aobj.pvs.FeedbackEnable) ;
      caput(app.aobj.pvs.FeedbackEnable,double(bitset(app.aobj.Enabled,1,0))); drawnow ;
      % Restore actuator to given date
      aval=archive_dataGet('SIOC:SYS1:ML01:AO257',datevec(dval),datevec(dval)) ;
      lcaPut('KLYS:LI10:41:SFB_ADES',aval{1}(1));
      % Re-enable FB (if previously enabled)
      caput(app.aobj.pvs.FeedbackEnable,initstate);
    end

    % Button pushed function: ActuatorRestoreToDate_BC14E
    function ActuatorRestoreToDate_BC14EButtonPushed(app, event)
      aidapva;
      dval=uigetdate;
      if isempty(dval)
        return
      end
      % Switch off FB
      initstate = caget(app.aobj.pvs.FeedbackEnable) ; 
      caput(app.aobj.pvs.FeedbackEnable,double(bitset(app.aobj.Enabled,2,0))); drawnow;
      % Restore actuator to given date
      pv1=char(app.BC14_C1Lab.Text); pv2=char(app.BC14_C2Lab.Text);
      aval1=archive_dataGet(pv1,datevec(dval),datevec(dval)) ;
      aval2=archive_dataGet(pv2,datevec(dval),datevec(dval)) ;
      try
        pvaRequest(regexprep(pv1,'LI14:KLYS','KLYS:LI14')).with('TRIM','YES').set(aval1{1}(1));
      catch ME
        fprintf(2,ME.message);
      end
      try
        pvaRequest(regexprep(pv2,'LI14:KLYS','KLYS:LI14')).with('TRIM','YES').set(aval2{1}(1));
      catch ME
        fprintf(2,ME.message);
      end
      % Re-enable FB (if previously enabled)
      caput(app.aobj.pvs.FeedbackEnable,initstate);
    end

    % Button pushed function: ActuatorReset_BC14E
    function ActuatorReset_BC14EButtonPushed(app, event)
      aidapva;
     % Switch off FB
      initstate = caget(app.aobj.pvs.FeedbackEnable) ;
      caput(app.aobj.pvs.FeedbackEnable,double(bitset(app.aobj.Enabled,2,0))); drawnow ;
      % Reset actuators
      pv1=char(app.BC14_C1Lab.Text); pv2=char(app.BC14_C2Lab.Text);
      try
        pvaRequest(regexprep(pv1,'LI14:KLYS','KLYS:LI14')).with('TRIM','YES').set(-60);
      catch ME
        fprintf(2,ME.message);
      end
      try
        pvaRequest(regexprep(pv2,'LI14:KLYS','KLYS:LI14')).with('TRIM','YES').set(60);
      catch ME
        fprintf(2,ME.message);
      end
      % Re-enable FB (if previously enabled)
      caput(app.aobj.pvs.FeedbackEnable,initstate);
    end

    % Button pushed function: ActuatorRestoreToDate_BC11E
    function ActuatorRestoreToDate_BC11EButtonPushed(app, event)
      dval=uigetdate;
      if isempty(dval)
        return
      end
      % Switch off FB
      initstate = caget(app.aobj.pvs.FeedbackEnable) ;
      caput(app.aobj.pvs.FeedbackEnable,double(bitset(app.aobj.Enabled,3,0))); drawnow ;
      % Restore actuator to given date
      aval=archive_dataGet('SIOC:SYS1:ML01:AO259',datevec(dval),datevec(dval)) ;
      lcaPut('KLYS:LI11:11:SSSB_ADES',aval{1}(1));
      lcaPut('KLYS:LI11:21:SSSB_ADES',aval{1}(1));
      % Re-enable FB (if previously enabled)
      caput(app.aobj.pvs.FeedbackEnable,initstate);
    end

    % Button pushed function: ActuatorRestoreToDate_BC11_BLEN
    function ActuatorRestoreToDate_BC11_BLENButtonPushed(app, event)
      dval=uigetdate;
      if isempty(dval)
        return
      end
      % Switch off FB
      initstate = caget(app.aobj.pvs.FeedbackEnable) ;
      caput(app.aobj.pvs.FeedbackEnable,double(bitset(app.aobj.Enabled,4,0))); drawnow ;
      % Restore actuator to given date
      aval=archive_dataGet('SIOC:SYS1:ML01:AO260',datevec(dval),datevec(dval)) ;
      lcaPut('KLYS:LI11:11:SSSB_PDES',aval{1}(1));
      lcaPut('KLYS:LI11:21:SSSB_PDES',aval{1}(1));
      % Re-enable FB (if previously enabled)
      caput(app.aobj.pvs.FeedbackEnable,initstate);
    end

    % Button pushed function: ActuatorRestoreToDate_BC20E
    function ActuatorRestoreToDate_BC20EButtonPushed(app, event)
      aidapva;
      dval=uigetdate;
      if isempty(dval)
        return
      end
      % Switch off FB
      initstate = caget(app.aobj.pvs.FeedbackEnable) ;
      caput(app.aobj.pvs.FeedbackEnable,double(bitset(app.aobj.Enabled,5,0))); drawnow ;
      % Reset actuators
      pv1=char(app.BC20_C1Lab.Text); pv2=char(app.BC20_C2Lab.Text);
      aval1=archive_dataGet(pv1,datevec(dval),datevec(dval)) ;
      aval2=archive_dataGet(pv2,datevec(dval),datevec(dval)) ;
      try
        pvaRequest(regexprep(pv1,'LI19:KLYS','KLYS:LI19')).with('TRIM','YES').set(aval1{1}(1));
      catch ME
        fprintf(2,ME.message);
      end
      try
        pvaRequest(regexprep(pv2,'LI19:KLYS','KLYS:LI19')).with('TRIM','YES').set(aval2{1}(1));
      catch ME
        fprintf(2,ME.message);
      end
      % Re-enable FB (if previously enabled)
      caput(app.aobj.pvs.FeedbackEnable,initstate);
    end

    % Button pushed function: ActuatorReset_BC20E
    function ActuatorReset_BC20EButtonPushed(app, event)
      aidapva;
       % Switch off FB
      initstate = caget(app.aobj.pvs.FeedbackEnable) ;
      caput(app.aobj.pvs.FeedbackEnable,double(bitset(app.aobj.Enabled,5,0))); drawnow ;
      % Reset actuators
      pv1=char(app.BC20_C1Lab.Text); pv2=char(app.BC20_C2Lab.Text);
      try
        pvaRequest(regexprep(pv1,'LI19:KLYS','KLYS:LI19')).with('TRIM','YES').set(-60);
      catch ME
        fprintf(2,ME.message);
      end
      try
        pvaRequest(regexprep(pv2,'LI19:KLYS','KLYS:LI19')).with('TRIM','YES').set(60);
      catch ME
        fprintf(2,ME.message);
      end
      % Re-enable FB (if previously enabled)
      caput(app.aobj.pvs.FeedbackEnable,initstate);
    end

    % Button pushed function: ActuatorRestoreToDate_BC14_BLEN
    function ActuatorRestoreToDate_BC14_BLENButtonPushed(app, event)
      dval=uigetdate;
      if isempty(dval)
        return
      end
      % Switch off FB
      initstate = caget(app.aobj.pvs.FeedbackEnable) ;
      caput(app.aobj.pvs.FeedbackEnable,double(bitset(app.aobj.Enabled,6,0))); drawnow ;
      % Restore actuator to given date
      aval11=archive_dataGet('LI11:SBST:1:PDES',datevec(dval),datevec(dval)) ;
      aval12=archive_dataGet('LI12:SBST:1:PDES',datevec(dval),datevec(dval)) ;
      aval13=archive_dataGet('LI13:SBST:1:PDES',datevec(dval),datevec(dval)) ;
      aval14=archive_dataGet('LI14:SBST:1:PDES',datevec(dval),datevec(dval)) ;
      MK=SCP_MKB('l2_phase');
      MK.set(mode([aval11{1}(1),aval12{1}(1),aval13{1}(1),aval14{1}(1)])-mode(MK.DeviceVals));
      % Re-enable FB (if previously enabled)
      caput(app.aobj.pvs.FeedbackEnable,initstate);
    end

    % Menu selected function: RestoreallactuatorsMenu
    function RestoreallactuatorsMenuSelected(app, event)
      aidapva;
      dval=uigetdate;
      if isempty(dval)
        return
      end
      % Switch off FBs
      initstate = caget(app.aobj.pvs.FeedbackEnable) ;
      caput(app.aobj.pvs.FeedbackEnable,0); drawnow;
      % Restore actuators to given date
      % DL10_E
      aval=archive_dataGet('SIOC:SYS1:ML01:AO257',datevec(dval),datevec(dval)) ;
      lcaPut('KLYS:LI10:41:SFB_ADES',aval{1}(1));
      % BC14_E
      pv1=char(app.BC14_C1Lab.Text); pv2=char(app.BC14_C2Lab.Text);
      aval1=archive_dataGet(pv1,datevec(dval),datevec(dval)) ;
      aval2=archive_dataGet(pv2,datevec(dval),datevec(dval)) ;
      try
        pvaRequest(ccregexprep(pv1,'LI14:KLYS','KLYS:LI14')).with('TRIM','YES').set(aval1{1}(1));
      catch ME
        fprintf(2,ME.message);
      end
      try
        pvaRequest(regexprep(pv2,'LI14:KLYS','KLYS:LI14')).with('TRIM','YES').set(aval2{1}(1));
      catch ME
        fprintf(2,ME.message);
      end
      % BC11_E
      aval=archive_dataGet('SIOC:SYS1:ML01:AO259',datevec(dval),datevec(dval)) ;
      lcaPut('KLYS:LI11:11:SSSB_ADES',aval{1}(1));
      lcaPut('KLYS:LI11:21:SSSB_ADES',aval{1}(1));
      % BC11_BLEN
      aval=archive_dataGet('SIOC:SYS1:ML01:AO260',datevec(dval),datevec(dval)) ;
      lcaPut('KLYS:LI11:11:SSSB_PDES',aval{1}(1));
      lcaPut('KLYS:LI11:21:SSSB_PDES',aval{1}(1));
      % BC20_E
      pv1=char(app.BC20_C1Lab.Text); pv2=char(app.BC20_C2Lab.Text);
      aval1=archive_dataGet(pv1,datevec(dval),datevec(dval)) ;
      aval2=archive_dataGet(pv2,datevec(dval),datevec(dval)) ;
      try
        pvaRequest(regexprep(pv1,'LI19:KLYS','KLYS:LI19')).with('TRIM','YES').set(aval1{1}(1));
      catch ME
        fprintf(2,ME.message);
      end
      try
        pvaRequest(regexprep(pv2,'LI19:KLYS','KLYS:LI19')).with('TRIM','YES').set(aval2{1}(1));
      catch ME
        fprintf(2,ME.message);
      end
      % BC14_BLEN
      aval11=archive_dataGet('LI11:SBST:1:PDES',datevec(dval),datevec(dval)) ;
      aval12=archive_dataGet('LI12:SBST:1:PDES',datevec(dval),datevec(dval)) ;
      aval13=archive_dataGet('LI13:SBST:1:PDES',datevec(dval),datevec(dval)) ;
      aval14=archive_dataGet('LI14:SBST:1:PDES',datevec(dval),datevec(dval)) ;
      MK=SCP_MKB('l2_phase');
      MK.set(mode([aval11{1}(1),aval12{1}(1),aval13{1}(1),aval14{1}(1)])-mode(MK.DeviceVals));
      % Restore FBs
      caput(app.aobj.pvs.FeedbackEnable,initstate);
    end
  end

  % Component initialization
  methods (Access = private)

    % Create UIFigure and components
    function createComponents(app)

      % Create FACETIIFeedbackUIFigure and hide until all components are created
      app.FACETIIFeedbackUIFigure = uifigure('Visible', 'off');
      app.FACETIIFeedbackUIFigure.Position = [100 100 994 765];
      app.FACETIIFeedbackUIFigure.Name = 'FACET-II Feedback';
      app.FACETIIFeedbackUIFigure.Resize = 'off';
      app.FACETIIFeedbackUIFigure.CloseRequestFcn = createCallbackFcn(app, @FACETIIFeedbackUIFigureCloseRequest, true);

      % Create StripchartsMenu
      app.StripchartsMenu = uimenu(app.FACETIIFeedbackUIFigure);
      app.StripchartsMenu.Text = 'Stripcharts';

      % Create DL1EnergyMenu
      app.DL1EnergyMenu = uimenu(app.StripchartsMenu);
      app.DL1EnergyMenu.MenuSelectedFcn = createCallbackFcn(app, @DL1EnergyMenuSelected, true);
      app.DL1EnergyMenu.Text = 'DL1 Energy';

      % Create BC11EnergyMenu
      app.BC11EnergyMenu = uimenu(app.StripchartsMenu);
      app.BC11EnergyMenu.MenuSelectedFcn = createCallbackFcn(app, @BC11EnergyMenuSelected, true);
      app.BC11EnergyMenu.Text = 'BC11 Energy';

      % Create BC11BLENMenu
      app.BC11BLENMenu = uimenu(app.StripchartsMenu);
      app.BC11BLENMenu.MenuSelectedFcn = createCallbackFcn(app, @BC11BLENMenuSelected, true);
      app.BC11BLENMenu.Text = 'BC11 BLEN';

      % Create BC14EnergyMenu
      app.BC14EnergyMenu = uimenu(app.StripchartsMenu);
      app.BC14EnergyMenu.MenuSelectedFcn = createCallbackFcn(app, @BC14EnergyMenuSelected, true);
      app.BC14EnergyMenu.Text = 'BC14 Energy';

      % Create BC14BLENMenu
      app.BC14BLENMenu = uimenu(app.StripchartsMenu);
      app.BC14BLENMenu.MenuSelectedFcn = createCallbackFcn(app, @BC14BLENMenuSelected, true);
      app.BC14BLENMenu.Text = 'BC14 BLEN';

      % Create BC20EnergyMenu
      app.BC20EnergyMenu = uimenu(app.StripchartsMenu);
      app.BC20EnergyMenu.MenuSelectedFcn = createCallbackFcn(app, @BC20EnergyMenuSelected, true);
      app.BC20EnergyMenu.Text = 'BC20 Energy';

      % Create SettingsMenu
      app.SettingsMenu = uimenu(app.FACETIIFeedbackUIFigure);
      app.SettingsMenu.Text = 'Settings';

      % Create DL10EnergyFeedbackMenu
      app.DL10EnergyFeedbackMenu = uimenu(app.SettingsMenu);
      app.DL10EnergyFeedbackMenu.MenuSelectedFcn = createCallbackFcn(app, @DL10EnergyFeedbackMenuSelected, true);
      app.DL10EnergyFeedbackMenu.Text = 'DL10 Energy Feedback ...';

      % Create BC11EnergyFeedbackMenu
      app.BC11EnergyFeedbackMenu = uimenu(app.SettingsMenu);
      app.BC11EnergyFeedbackMenu.MenuSelectedFcn = createCallbackFcn(app, @BC11EnergyFeedbackMenuSelected, true);
      app.BC11EnergyFeedbackMenu.Text = 'BC11 Energy Feedback...';

      % Create BC11BLENFeedbackMenu
      app.BC11BLENFeedbackMenu = uimenu(app.SettingsMenu);
      app.BC11BLENFeedbackMenu.MenuSelectedFcn = createCallbackFcn(app, @BC11BLENFeedbackMenuSelected, true);
      app.BC11BLENFeedbackMenu.Text = 'BC11 BLEN Feedback...';

      % Create BC14EnergyFeedbackMenu
      app.BC14EnergyFeedbackMenu = uimenu(app.SettingsMenu);
      app.BC14EnergyFeedbackMenu.MenuSelectedFcn = createCallbackFcn(app, @BC14EnergyFeedbackMenuSelected, true);
      app.BC14EnergyFeedbackMenu.Text = 'BC14 Energy Feedback ...';

      % Create BC14BLENFeedbackMenu
      app.BC14BLENFeedbackMenu = uimenu(app.SettingsMenu);
      app.BC14BLENFeedbackMenu.MenuSelectedFcn = createCallbackFcn(app, @BC14BLENFeedbackMenuSelected, true);
      app.BC14BLENFeedbackMenu.Text = 'BC14 BLEN Feedback...';

      % Create BC20EnergyFeedbackMenu
      app.BC20EnergyFeedbackMenu = uimenu(app.SettingsMenu);
      app.BC20EnergyFeedbackMenu.MenuSelectedFcn = createCallbackFcn(app, @BC20EnergyFeedbackMenuSelected, true);
      app.BC20EnergyFeedbackMenu.Text = 'BC20 Energy Feedback...';

      % Create RestoreallactuatorsMenu
      app.RestoreallactuatorsMenu = uimenu(app.SettingsMenu);
      app.RestoreallactuatorsMenu.MenuSelectedFcn = createCallbackFcn(app, @RestoreallactuatorsMenuSelected, true);
      app.RestoreallactuatorsMenu.Text = 'Restore all actuators...';

      % Create JitterTimeoutMenu
      app.JitterTimeoutMenu = uimenu(app.SettingsMenu);
      app.JitterTimeoutMenu.MenuSelectedFcn = createCallbackFcn(app, @JitterTimeoutMenuSelected, true);
      app.JitterTimeoutMenu.Text = 'Jitter Timeout = 2 min';

      % Create HelpMenu
      app.HelpMenu = uimenu(app.FACETIIFeedbackUIFigure);
      app.HelpMenu.Text = 'Help';

      % Create ActuatorReadbackPVsMenu
      app.ActuatorReadbackPVsMenu = uimenu(app.HelpMenu);
      app.ActuatorReadbackPVsMenu.Text = 'Actuator Readback PVs...';

      % Create DL10SIOCSYS1ML01AO257Menu
      app.DL10SIOCSYS1ML01AO257Menu = uimenu(app.ActuatorReadbackPVsMenu);
      app.DL10SIOCSYS1ML01AO257Menu.Text = 'DL10 = SIOC:SYS1:ML01:AO257';

      % Create BC14ESIOCSYS1ML01AO258Menu
      app.BC14ESIOCSYS1ML01AO258Menu = uimenu(app.ActuatorReadbackPVsMenu);
      app.BC14ESIOCSYS1ML01AO258Menu.Text = 'BC14E = SIOC:SYS1:ML01:AO258';

      % Create BC11ESIOCSYS1ML01AO259Menu
      app.BC11ESIOCSYS1ML01AO259Menu = uimenu(app.ActuatorReadbackPVsMenu);
      app.BC11ESIOCSYS1ML01AO259Menu.Text = 'BC11E = SIOC:SYS1:ML01:AO259';

      % Create BC11_BLENSIOCSYS1ML01AO260Menu
      app.BC11_BLENSIOCSYS1ML01AO260Menu = uimenu(app.ActuatorReadbackPVsMenu);
      app.BC11_BLENSIOCSYS1ML01AO260Menu.Text = 'BC11_BLEN = SIOC:SYS1:ML01:AO260';

      % Create BC20ESIOCSYS1ML01AO261Menu
      app.BC20ESIOCSYS1ML01AO261Menu = uimenu(app.ActuatorReadbackPVsMenu);
      app.BC20ESIOCSYS1ML01AO261Menu.Text = 'BC20E = SIOC:SYS1:ML01:AO261';

      % Create BC14_BLENSIOCSYS1ML01AO262Menu
      app.BC14_BLENSIOCSYS1ML01AO262Menu = uimenu(app.ActuatorReadbackPVsMenu);
      app.BC14_BLENSIOCSYS1ML01AO262Menu.Text = 'BC14_BLEN = SIOC:SYS1:ML01:AO262';

      % Create DL10EnergyFeedbackPanel
      app.DL10EnergyFeedbackPanel = uipanel(app.FACETIIFeedbackUIFigure);
      app.DL10EnergyFeedbackPanel.ForegroundColor = [0.9294 0.6941 0.1255];
      app.DL10EnergyFeedbackPanel.Title = 'DL10 Energy Feedback';
      app.DL10EnergyFeedbackPanel.FontWeight = 'bold';
      app.DL10EnergyFeedbackPanel.Position = [22 465 472 217];

      % Create SetpointEditField
      app.SetpointEditField = uieditfield(app.DL10EnergyFeedbackPanel, 'numeric');
      app.SetpointEditField.ValueChangedFcn = createCallbackFcn(app, @SetpointEditFieldValueChanged, true);
      app.SetpointEditField.HorizontalAlignment = 'center';
      app.SetpointEditField.Position = [17 128 100 29];

      % Create keVLabel
      app.keVLabel = uilabel(app.DL10EnergyFeedbackPanel);
      app.keVLabel.FontSize = 16;
      app.keVLabel.Position = [123 130 48 28];
      app.keVLabel.Text = 'keV';

      % Create Gauge
      app.Gauge = uigauge(app.DL10EnergyFeedbackPanel, 'linear');
      app.Gauge.Limits = [-100 100];
      app.Gauge.MajorTicks = [-100 -60 -20 20 60 100];
      app.Gauge.MajorTickLabels = {''};
      app.Gauge.MinorTicks = [-100 -92 -84 -76 -68 -60 -52 -44 -36 -28 -20 -12 -4 4 12 20 28 36 44 52 60 68 76 84 92 100];
      app.Gauge.ScaleColors = [1 0 0;1 0 0;0.3922 0.8314 0.0745];
      app.Gauge.ScaleColorLimits = [-100 -75;75 100;-25 25];
      app.Gauge.FontSize = 10;
      app.Gauge.Position = [185 113 125 29];

      % Create StatusLamp
      app.StatusLamp = uilamp(app.DL10EnergyFeedbackPanel);
      app.StatusLamp.Position = [8 164 29 29];
      app.StatusLamp.Color = [0 0 0];

      % Create Switch
      app.Switch = uiswitch(app.DL10EnergyFeedbackPanel, 'slider');
      app.Switch.ValueChangedFcn = createCallbackFcn(app, @SwitchValueChanged, true);
      app.Switch.Interruptible = 'off';
      app.Switch.Position = [51 70 86 38];

      % Create Gauge_3
      app.Gauge_3 = uigauge(app.DL10EnergyFeedbackPanel, 'linear');
      app.Gauge_3.FontSize = 10;
      app.Gauge_3.Position = [333 113 125 29];
      app.Gauge_3.Value = 40;

      % Create KLYSIN1041SFB_ADESLabel
      app.KLYSIN1041SFB_ADESLabel = uilabel(app.DL10EnergyFeedbackPanel);
      app.KLYSIN1041SFB_ADESLabel.Position = [323 141 148 22];
      app.KLYSIN1041SFB_ADESLabel.Text = 'KLYS:IN10:41:SFB_ADES';

      % Create SIOCSYS1ML01AO606Label
      app.SIOCSYS1ML01AO606Label = uilabel(app.DL10EnergyFeedbackPanel);
      app.SIOCSYS1ML01AO606Label.Position = [177 140 143 22];
      app.SIOCSYS1ML01AO606Label.Text = 'SIOC:SYS1:ML01:AO606';

      % Create EditField
      app.EditField = uieditfield(app.DL10EnergyFeedbackPanel, 'numeric');
      app.EditField.Editable = 'off';
      app.EditField.HorizontalAlignment = 'center';
      app.EditField.FontSize = 10;
      app.EditField.BackgroundColor = [0.4667 0.6745 0.1882];
      app.EditField.Position = [185 87 125 22];

      % Create EditField_2
      app.EditField_2 = uieditfield(app.DL10EnergyFeedbackPanel, 'numeric');
      app.EditField_2.ValueDisplayFormat = '%11.6g';
      app.EditField_2.Editable = 'off';
      app.EditField_2.HorizontalAlignment = 'center';
      app.EditField_2.FontSize = 10;
      app.EditField_2.Position = [334 87 125 22];

      % Create NotRunningButton
      app.NotRunningButton = uibutton(app.DL10EnergyFeedbackPanel, 'push');
      app.NotRunningButton.FontSize = 8;
      app.NotRunningButton.FontWeight = 'bold';
      app.NotRunningButton.Position = [44 165 418 23];
      app.NotRunningButton.Text = 'Not Running';

      % Create FeedbackJitterButton
      app.FeedbackJitterButton = uibutton(app.DL10EnergyFeedbackPanel, 'state');
      app.FeedbackJitterButton.ValueChangedFcn = createCallbackFcn(app, @FeedbackJitterButtonValueChanged, true);
      app.FeedbackJitterButton.Interruptible = 'off';
      app.FeedbackJitterButton.Text = 'Feedback Jitter OFF';
      app.FeedbackJitterButton.FontWeight = 'bold';
      app.FeedbackJitterButton.Position = [28 8 168 31];

      % Create ADESJitterAmplitudeEditFieldLabel
      app.ADESJitterAmplitudeEditFieldLabel = uilabel(app.DL10EnergyFeedbackPanel);
      app.ADESJitterAmplitudeEditFieldLabel.HorizontalAlignment = 'right';
      app.ADESJitterAmplitudeEditFieldLabel.Position = [224 13 128 22];
      app.ADESJitterAmplitudeEditFieldLabel.Text = 'ADES Jitter Amplitude:';

      % Create JitAmpEdit
      app.JitAmpEdit = uieditfield(app.DL10EnergyFeedbackPanel, 'numeric');
      app.JitAmpEdit.ValueChangedFcn = createCallbackFcn(app, @JitAmpEditValueChanged, true);
      app.JitAmpEdit.Position = [367 13 60 22];
      app.JitAmpEdit.Value = 0.1;

      % Create ActuatorRestoreToDate_DL10
      app.ActuatorRestoreToDate_DL10 = uibutton(app.DL10EnergyFeedbackPanel, 'push');
      app.ActuatorRestoreToDate_DL10.ButtonPushedFcn = createCallbackFcn(app, @ActuatorRestoreToDate_DL10Pushed, true);
      app.ActuatorRestoreToDate_DL10.Position = [212 50 225 26];
      app.ActuatorRestoreToDate_DL10.Text = 'Actuator Restore To Date-time';

      % Create BC14EnergyFeedbackPanel
      app.BC14EnergyFeedbackPanel = uipanel(app.FACETIIFeedbackUIFigure);
      app.BC14EnergyFeedbackPanel.ForegroundColor = [0 0 1];
      app.BC14EnergyFeedbackPanel.Title = 'BC14 Energy Feedback';
      app.BC14EnergyFeedbackPanel.FontWeight = 'bold';
      app.BC14EnergyFeedbackPanel.Position = [22 185 473 266];

      % Create SetpointEditField_2
      app.SetpointEditField_2 = uieditfield(app.BC14EnergyFeedbackPanel, 'numeric');
      app.SetpointEditField_2.ValueChangedFcn = createCallbackFcn(app, @SetpointEditField_2ValueChanged, true);
      app.SetpointEditField_2.HorizontalAlignment = 'center';
      app.SetpointEditField_2.Position = [52 177 100 29];

      % Create mmLabel_4
      app.mmLabel_4 = uilabel(app.BC14EnergyFeedbackPanel);
      app.mmLabel_4.FontSize = 16;
      app.mmLabel_4.Position = [159 177 47 29];
      app.mmLabel_4.Text = 'mm';

      % Create Switch_2
      app.Switch_2 = uiswitch(app.BC14EnergyFeedbackPanel, 'slider');
      app.Switch_2.Orientation = 'vertical';
      app.Switch_2.ValueChangedFcn = createCallbackFcn(app, @Switch_2ValueChanged, true);
      app.Switch_2.Position = [36 65 37 83];

      % Create StatusLamp_2
      app.StatusLamp_2 = uilamp(app.BC14EnergyFeedbackPanel);
      app.StatusLamp_2.Position = [8 210 29 29];
      app.StatusLamp_2.Color = [0 0 0];

      % Create BC14_C1Lab
      app.BC14_C1Lab = uilabel(app.BC14EnergyFeedbackPanel);
      app.BC14_C1Lab.Position = [233 158 116 22];
      app.BC14_C1Lab.Text = 'LI14:KLYS:41:PDES';

      % Create BC14_C2Lab
      app.BC14_C2Lab = uilabel(app.BC14EnergyFeedbackPanel);
      app.BC14_C2Lab.Position = [348 158 116 22];
      app.BC14_C2Lab.Text = 'LI14:KLYS:51:PDES';

      % Create BPMSLI14801X1HLabel
      app.BPMSLI14801X1HLabel = uilabel(app.BC14EnergyFeedbackPanel);
      app.BPMSLI14801X1HLabel.Position = [124 111 117 22];
      app.BPMSLI14801X1HLabel.Text = 'BPMS:LI14:801:X1H';

      % Create EditField_5
      app.EditField_5 = uieditfield(app.BC14EnergyFeedbackPanel, 'numeric');
      app.EditField_5.Editable = 'off';
      app.EditField_5.HorizontalAlignment = 'center';
      app.EditField_5.FontSize = 10;
      app.EditField_5.Position = [117 55 125 22];

      % Create EditField_6
      app.EditField_6 = uieditfield(app.BC14EnergyFeedbackPanel, 'numeric');
      app.EditField_6.Editable = 'off';
      app.EditField_6.HorizontalAlignment = 'center';
      app.EditField_6.FontSize = 10;
      app.EditField_6.Position = [284 44 125 22];

      % Create NotRunningButton_5
      app.NotRunningButton_5 = uibutton(app.BC14EnergyFeedbackPanel, 'push');
      app.NotRunningButton_5.FontSize = 8;
      app.NotRunningButton_5.FontWeight = 'bold';
      app.NotRunningButton_5.Position = [51 214 414 24];
      app.NotRunningButton_5.Text = 'Not Running';

      % Create Gauge_16
      app.Gauge_16 = uigauge(app.BC14EnergyFeedbackPanel, 'ninetydegree');
      app.Gauge_16.Limits = [-180 0];
      app.Gauge_16.Orientation = 'southwest';
      app.Gauge_16.ScaleDirection = 'counterclockwise';
      app.Gauge_16.Position = [257 70 90 90];
      app.Gauge_16.Value = -60;

      % Create Gauge_17
      app.Gauge_17 = uigauge(app.BC14EnergyFeedbackPanel, 'ninetydegree');
      app.Gauge_17.Limits = [0 180];
      app.Gauge_17.Orientation = 'southeast';
      app.Gauge_17.ScaleDirection = 'counterclockwise';
      app.Gauge_17.Position = [347 70 90 90];
      app.Gauge_17.Value = 60;

      % Create Gauge_6
      app.Gauge_6 = uigauge(app.BC14EnergyFeedbackPanel, 'linear');
      app.Gauge_6.Limits = [-100 100];
      app.Gauge_6.MajorTicks = [-100 -60 -20 20 60 100];
      app.Gauge_6.MajorTickLabels = {''};
      app.Gauge_6.MinorTicks = [-100 -92 -84 -76 -68 -60 -52 -44 -36 -28 -20 -12 -4 4 12 20 28 36 44 52 60 68 76 84 92 100];
      app.Gauge_6.ScaleColors = [1 0 0;1 0 0;0.3922 0.8314 0.0745];
      app.Gauge_6.ScaleColorLimits = [-100 -75;75 100;-25 25];
      app.Gauge_6.FontSize = 10;
      app.Gauge_6.Position = [116 81 125 29];

      % Create MKBLabel_2
      app.MKBLabel_2 = uilabel(app.BC14EnergyFeedbackPanel);
      app.MKBLabel_2.Position = [224 184 34 22];
      app.MKBLabel_2.Text = 'MKB:';

      % Create DropDown_2
      app.DropDown_2 = uidropdown(app.BC14EnergyFeedbackPanel);
      app.DropDown_2.Items = {'BC14_ENERGY_4AND5', 'BC14_ENERGY_5AND6', 'BC14_ENERGY_4AND6'};
      app.DropDown_2.ValueChangedFcn = createCallbackFcn(app, @DropDown_2ValueChanged, true);
      app.DropDown_2.Position = [269 184 189 22];
      app.DropDown_2.Value = 'BC14_ENERGY_4AND5';

      % Create ActuatorRestoreToDate_BC14E
      app.ActuatorRestoreToDate_BC14E = uibutton(app.BC14EnergyFeedbackPanel, 'push');
      app.ActuatorRestoreToDate_BC14E.ButtonPushedFcn = createCallbackFcn(app, @ActuatorRestoreToDate_BC14EButtonPushed, true);
      app.ActuatorRestoreToDate_BC14E.Position = [234 9 225 26];
      app.ActuatorRestoreToDate_BC14E.Text = 'Actuator Restore To Date-time';

      % Create ActuatorReset_BC14E
      app.ActuatorReset_BC14E = uibutton(app.BC14EnergyFeedbackPanel, 'push');
      app.ActuatorReset_BC14E.ButtonPushedFcn = createCallbackFcn(app, @ActuatorReset_BC14EButtonPushed, true);
      app.ActuatorReset_BC14E.Position = [17 9 207 26];
      app.ActuatorReset_BC14E.Text = 'Re-Center Actuator (+/- 60 deg)';

      % Create BC20EnergyFeedbackPanel
      app.BC20EnergyFeedbackPanel = uipanel(app.FACETIIFeedbackUIFigure);
      app.BC20EnergyFeedbackPanel.ForegroundColor = [0.7176 0.2745 1];
      app.BC20EnergyFeedbackPanel.Title = 'BC20 Energy Feedback';
      app.BC20EnergyFeedbackPanel.FontWeight = 'bold';
      app.BC20EnergyFeedbackPanel.Position = [503 13 472 307];

      % Create SetpointEditField_4
      app.SetpointEditField_4 = uieditfield(app.BC20EnergyFeedbackPanel, 'numeric');
      app.SetpointEditField_4.ValueChangedFcn = createCallbackFcn(app, @SetpointEditField_4ValueChanged, true);
      app.SetpointEditField_4.HorizontalAlignment = 'center';
      app.SetpointEditField_4.Position = [17 195 109 29];

      % Create MeVLabel
      app.MeVLabel = uilabel(app.BC20EnergyFeedbackPanel);
      app.MeVLabel.FontSize = 16;
      app.MeVLabel.Position = [130 199 41 22];
      app.MeVLabel.Text = 'MeV';

      % Create Switch_4
      app.Switch_4 = uiswitch(app.BC20EnergyFeedbackPanel, 'slider');
      app.Switch_4.Orientation = 'vertical';
      app.Switch_4.ValueChangedFcn = createCallbackFcn(app, @Switch_4ValueChanged, true);
      app.Switch_4.Position = [25 71 40 89];

      % Create StatusLamp_4
      app.StatusLamp_4 = uilamp(app.BC20EnergyFeedbackPanel);
      app.StatusLamp_4.Position = [8 240 31 31];
      app.StatusLamp_4.Color = [0 0 0];

      % Create SIOCSYS1ML01AO624Label
      app.SIOCSYS1ML01AO624Label = uilabel(app.BC20EnergyFeedbackPanel);
      app.SIOCSYS1ML01AO624Label.Position = [80 126 143 22];
      app.SIOCSYS1ML01AO624Label.Text = 'SIOC:SYS1:ML01:AO624';

      % Create EditField_8
      app.EditField_8 = uieditfield(app.BC20EnergyFeedbackPanel, 'numeric');
      app.EditField_8.Editable = 'off';
      app.EditField_8.HorizontalAlignment = 'center';
      app.EditField_8.FontSize = 10;
      app.EditField_8.Position = [88 72 128 22];

      % Create NotRunningButton_6
      app.NotRunningButton_6 = uibutton(app.BC20EnergyFeedbackPanel, 'push');
      app.NotRunningButton_6.FontSize = 8;
      app.NotRunningButton_6.FontWeight = 'bold';
      app.NotRunningButton_6.Position = [47 245 417 25];
      app.NotRunningButton_6.Text = 'Not Running';

      % Create MKBLabel
      app.MKBLabel = uilabel(app.BC20EnergyFeedbackPanel);
      app.MKBLabel.Position = [217 207 34 22];
      app.MKBLabel.Text = 'MKB:';

      % Create DropDown
      app.DropDown = uidropdown(app.BC20EnergyFeedbackPanel);
      app.DropDown.Items = {'S20_ENERGY_3AND4', 'S20_ENERGY_3AND5', 'S20_ENERGY_4AND5', 'S20_ENERGY_4AND6'};
      app.DropDown.ValueChangedFcn = createCallbackFcn(app, @DropDownValueChanged, true);
      app.DropDown.Position = [262 207 189 22];
      app.DropDown.Value = 'S20_ENERGY_3AND4';

      % Create BC20_C1Lab
      app.BC20_C1Lab = uilabel(app.BC20EnergyFeedbackPanel);
      app.BC20_C1Lab.HorizontalAlignment = 'right';
      app.BC20_C1Lab.Position = [204 173 127 22];
      app.BC20_C1Lab.Text = 'LI19:KLYS:31:PDES';

      % Create BC20_C2Lab
      app.BC20_C2Lab = uilabel(app.BC20EnergyFeedbackPanel);
      app.BC20_C2Lab.Position = [338 173 127 22];
      app.BC20_C2Lab.Text = 'LI19:KLYS:41:PDES';

      % Create Gauge_19
      app.Gauge_19 = uigauge(app.BC20EnergyFeedbackPanel, 'ninetydegree');
      app.Gauge_19.Limits = [-180 0];
      app.Gauge_19.Orientation = 'southwest';
      app.Gauge_19.ScaleDirection = 'counterclockwise';
      app.Gauge_19.Position = [245 85 90 90];
      app.Gauge_19.Value = -60;

      % Create Gauge_20
      app.Gauge_20 = uigauge(app.BC20EnergyFeedbackPanel, 'ninetydegree');
      app.Gauge_20.Limits = [0 180];
      app.Gauge_20.Orientation = 'southeast';
      app.Gauge_20.ScaleDirection = 'counterclockwise';
      app.Gauge_20.Position = [335 85 90 90];
      app.Gauge_20.Value = 60;

      % Create EditField_17
      app.EditField_17 = uieditfield(app.BC20EnergyFeedbackPanel, 'numeric');
      app.EditField_17.Editable = 'off';
      app.EditField_17.HorizontalAlignment = 'center';
      app.EditField_17.FontSize = 10;
      app.EditField_17.Position = [273 57 125 22];

      % Create Gauge_7
      app.Gauge_7 = uigauge(app.BC20EnergyFeedbackPanel, 'linear');
      app.Gauge_7.Limits = [-100 100];
      app.Gauge_7.MajorTicks = [-100 -60 -20 20 60 100];
      app.Gauge_7.MajorTickLabels = {''};
      app.Gauge_7.MinorTicks = [-100 -92 -84 -76 -68 -60 -52 -44 -36 -28 -20 -12 -4 4 12 20 28 36 44 52 60 68 76 84 92 100];
      app.Gauge_7.ScaleColors = [1 0 0;1 0 0;0.3922 0.8314 0.0745];
      app.Gauge_7.ScaleColorLimits = [-100 -75;75 100;-25 25];
      app.Gauge_7.FontSize = 10;
      app.Gauge_7.Position = [88 98 125 29];

      % Create ActuatorRestoreToDate_BC20E
      app.ActuatorRestoreToDate_BC20E = uibutton(app.BC20EnergyFeedbackPanel, 'push');
      app.ActuatorRestoreToDate_BC20E.ButtonPushedFcn = createCallbackFcn(app, @ActuatorRestoreToDate_BC20EButtonPushed, true);
      app.ActuatorRestoreToDate_BC20E.Position = [233 10 225 26];
      app.ActuatorRestoreToDate_BC20E.Text = 'Actuator Restore To Date-time';

      % Create ActuatorReset_BC20E
      app.ActuatorReset_BC20E = uibutton(app.BC20EnergyFeedbackPanel, 'push');
      app.ActuatorReset_BC20E.ButtonPushedFcn = createCallbackFcn(app, @ActuatorReset_BC20EButtonPushed, true);
      app.ActuatorReset_BC20E.Position = [16 10 207 26];
      app.ActuatorReset_BC20E.Text = 'Re-Center Actuator (+/- 60 deg)';

      % Create BC11EnergyFeedbackPanel
      app.BC11EnergyFeedbackPanel = uipanel(app.FACETIIFeedbackUIFigure);
      app.BC11EnergyFeedbackPanel.ForegroundColor = [0.851 0.3255 0.098];
      app.BC11EnergyFeedbackPanel.Title = 'BC11 Energy Feedback';
      app.BC11EnergyFeedbackPanel.FontWeight = 'bold';
      app.BC11EnergyFeedbackPanel.Position = [502 510 472 172];

      % Create SetpointEditField_5
      app.SetpointEditField_5 = uieditfield(app.BC11EnergyFeedbackPanel, 'numeric');
      app.SetpointEditField_5.ValueChangedFcn = createCallbackFcn(app, @SetpointEditField_5ValueChanged, true);
      app.SetpointEditField_5.HorizontalAlignment = 'center';
      app.SetpointEditField_5.Position = [17 83 100 29];

      % Create mmLabel_6
      app.mmLabel_6 = uilabel(app.BC11EnergyFeedbackPanel);
      app.mmLabel_6.FontSize = 16;
      app.mmLabel_6.Position = [123 84 58 29];
      app.mmLabel_6.Text = 'mm';

      % Create StatusLamp_5
      app.StatusLamp_5 = uilamp(app.BC11EnergyFeedbackPanel);
      app.StatusLamp_5.Position = [5 116 31 31];
      app.StatusLamp_5.Color = [0 0 0];

      % Create Switch_5
      app.Switch_5 = uiswitch(app.BC11EnergyFeedbackPanel, 'slider');
      app.Switch_5.ValueChangedFcn = createCallbackFcn(app, @Switch_5ValueChanged, true);
      app.Switch_5.Position = [47 25 88 39];

      % Create Gauge_9
      app.Gauge_9 = uigauge(app.BC11EnergyFeedbackPanel, 'linear');
      app.Gauge_9.FontSize = 10;
      app.Gauge_9.Position = [334 67 126 29];
      app.Gauge_9.Value = 40;

      % Create KLYSLI111121SSSB_ADESLabel
      app.KLYSLI111121SSSB_ADESLabel = uilabel(app.BC11EnergyFeedbackPanel);
      app.KLYSLI111121SSSB_ADESLabel.HorizontalAlignment = 'center';
      app.KLYSLI111121SSSB_ADESLabel.Position = [298 95 175 22];
      app.KLYSLI111121SSSB_ADESLabel.Text = 'KLYS:LI11:11&21:SSSB_ADES';

      % Create BPMSLI11333X1HLabel
      app.BPMSLI11333X1HLabel = uilabel(app.BC11EnergyFeedbackPanel);
      app.BPMSLI11333X1HLabel.Position = [178 95 117 22];
      app.BPMSLI11333X1HLabel.Text = 'BPMS:LI11:333:X1H';

      % Create EditField_11
      app.EditField_11 = uieditfield(app.BC11EnergyFeedbackPanel, 'numeric');
      app.EditField_11.Editable = 'off';
      app.EditField_11.HorizontalAlignment = 'center';
      app.EditField_11.FontSize = 10;
      app.EditField_11.Position = [185 42 125 22];

      % Create EditField_12
      app.EditField_12 = uieditfield(app.BC11EnergyFeedbackPanel, 'numeric');
      app.EditField_12.Editable = 'off';
      app.EditField_12.HorizontalAlignment = 'center';
      app.EditField_12.FontSize = 10;
      app.EditField_12.Position = [334 42 125 22];

      % Create NotRunningButton_3
      app.NotRunningButton_3 = uibutton(app.BC11EnergyFeedbackPanel, 'push');
      app.NotRunningButton_3.FontSize = 8;
      app.NotRunningButton_3.FontWeight = 'bold';
      app.NotRunningButton_3.Position = [48 121 417 22];
      app.NotRunningButton_3.Text = 'Not Running';

      % Create Gauge_8
      app.Gauge_8 = uigauge(app.BC11EnergyFeedbackPanel, 'linear');
      app.Gauge_8.Limits = [-100 100];
      app.Gauge_8.MajorTicks = [-100 -60 -20 20 60 100];
      app.Gauge_8.MajorTickLabels = {''};
      app.Gauge_8.MinorTicks = [-100 -92 -84 -76 -68 -60 -52 -44 -36 -28 -20 -12 -4 4 12 20 28 36 44 52 60 68 76 84 92 100];
      app.Gauge_8.ScaleColors = [1 0 0;1 0 0;0.3922 0.8314 0.0745];
      app.Gauge_8.ScaleColorLimits = [-100 -75;75 100;-25 25];
      app.Gauge_8.FontSize = 10;
      app.Gauge_8.Position = [185 67 125 29];

      % Create ActuatorRestoreToDate_BC11E
      app.ActuatorRestoreToDate_BC11E = uibutton(app.BC11EnergyFeedbackPanel, 'push');
      app.ActuatorRestoreToDate_BC11E.ButtonPushedFcn = createCallbackFcn(app, @ActuatorRestoreToDate_BC11EButtonPushed, true);
      app.ActuatorRestoreToDate_BC11E.Position = [217 7 225 26];
      app.ActuatorRestoreToDate_BC11E.Text = 'Actuator Restore To Date-time';

      % Create BC11BunchLengthFeedbackPanel
      app.BC11BunchLengthFeedbackPanel = uipanel(app.FACETIIFeedbackUIFigure);
      app.BC11BunchLengthFeedbackPanel.ForegroundColor = [0.851 0.3255 0.098];
      app.BC11BunchLengthFeedbackPanel.Title = 'BC11 Bunch Length Feedback';
      app.BC11BunchLengthFeedbackPanel.FontWeight = 'bold';
      app.BC11BunchLengthFeedbackPanel.Position = [502 326 472 174];

      % Create SetpointEditField_6
      app.SetpointEditField_6 = uieditfield(app.BC11BunchLengthFeedbackPanel, 'numeric');
      app.SetpointEditField_6.ValueChangedFcn = createCallbackFcn(app, @SetpointEditField_6ValueChanged, true);
      app.SetpointEditField_6.HorizontalAlignment = 'center';
      app.SetpointEditField_6.Position = [17 83 100 29];
      app.SetpointEditField_6.Value = 0.4;

      % Create fsLabel_2
      app.fsLabel_2 = uilabel(app.BC11BunchLengthFeedbackPanel);
      app.fsLabel_2.FontSize = 16;
      app.fsLabel_2.Position = [130 86 25 22];
      app.fsLabel_2.Text = 'fs';

      % Create StatusLamp_6
      app.StatusLamp_6 = uilamp(app.BC11BunchLengthFeedbackPanel);
      app.StatusLamp_6.Position = [7 118 32 32];
      app.StatusLamp_6.Color = [0 0 0];

      % Create Switch_6
      app.Switch_6 = uiswitch(app.BC11BunchLengthFeedbackPanel, 'slider');
      app.Switch_6.ValueChangedFcn = createCallbackFcn(app, @Switch_6ValueChanged, true);
      app.Switch_6.Position = [46 26 86 38];

      % Create Gauge_11
      app.Gauge_11 = uigauge(app.BC11BunchLengthFeedbackPanel, 'linear');
      app.Gauge_11.Limits = [0 10];
      app.Gauge_11.FontSize = 10;
      app.Gauge_11.Position = [334 65 126 33];

      % Create KLYSLI111121SSSB_PDESLabel
      app.KLYSLI111121SSSB_PDESLabel = uilabel(app.BC11BunchLengthFeedbackPanel);
      app.KLYSLI111121SSSB_PDESLabel.HorizontalAlignment = 'center';
      app.KLYSLI111121SSSB_PDESLabel.Position = [296 99 175 22];
      app.KLYSLI111121SSSB_PDESLabel.Text = 'KLYS:LI11:11&21:SSSB_PDES';

      % Create BLENLI11359Label
      app.BLENLI11359Label = uilabel(app.BC11BunchLengthFeedbackPanel);
      app.BLENLI11359Label.HorizontalAlignment = 'center';
      app.BLENLI11359Label.Position = [200 99 88 22];
      app.BLENLI11359Label.Text = 'BLEN:LI11:359';

      % Create EditField_13
      app.EditField_13 = uieditfield(app.BC11BunchLengthFeedbackPanel, 'numeric');
      app.EditField_13.Editable = 'off';
      app.EditField_13.HorizontalAlignment = 'center';
      app.EditField_13.FontSize = 10;
      app.EditField_13.Position = [184 42 126 22];

      % Create EditField_14
      app.EditField_14 = uieditfield(app.BC11BunchLengthFeedbackPanel, 'numeric');
      app.EditField_14.Editable = 'off';
      app.EditField_14.HorizontalAlignment = 'center';
      app.EditField_14.FontSize = 10;
      app.EditField_14.Position = [334 42 125 22];

      % Create NotRunningButton_4
      app.NotRunningButton_4 = uibutton(app.BC11BunchLengthFeedbackPanel, 'push');
      app.NotRunningButton_4.FontSize = 8;
      app.NotRunningButton_4.FontWeight = 'bold';
      app.NotRunningButton_4.Position = [44 124 419 22];
      app.NotRunningButton_4.Text = 'Not Running';

      % Create Gauge_10
      app.Gauge_10 = uigauge(app.BC11BunchLengthFeedbackPanel, 'linear');
      app.Gauge_10.Limits = [-100 100];
      app.Gauge_10.MajorTicks = [-100 -60 -20 20 60 100];
      app.Gauge_10.MajorTickLabels = {''};
      app.Gauge_10.MinorTicks = [-100 -92 -84 -76 -68 -60 -52 -44 -36 -28 -20 -12 -4 4 12 20 28 36 44 52 60 68 76 84 92 100];
      app.Gauge_10.ScaleColors = [1 0 0;1 0 0;0.3922 0.8314 0.0745];
      app.Gauge_10.ScaleColorLimits = [-100 -75;75 100;-25 25];
      app.Gauge_10.FontSize = 10;
      app.Gauge_10.Position = [185 66 125 32];

      % Create ActuatorRestoreToDate_BC11_BLEN
      app.ActuatorRestoreToDate_BC11_BLEN = uibutton(app.BC11BunchLengthFeedbackPanel, 'push');
      app.ActuatorRestoreToDate_BC11_BLEN.ButtonPushedFcn = createCallbackFcn(app, @ActuatorRestoreToDate_BC11_BLENButtonPushed, true);
      app.ActuatorRestoreToDate_BC11_BLEN.Position = [223 10 225 26];
      app.ActuatorRestoreToDate_BC11_BLEN.Text = 'Actuator Restore To Date-time';

      % Create BC14BunchLengthFeedbackPanel
      app.BC14BunchLengthFeedbackPanel = uipanel(app.FACETIIFeedbackUIFigure);
      app.BC14BunchLengthFeedbackPanel.ForegroundColor = [0 0 1];
      app.BC14BunchLengthFeedbackPanel.Title = 'BC14 Bunch Length Feedback';
      app.BC14BunchLengthFeedbackPanel.FontWeight = 'bold';
      app.BC14BunchLengthFeedbackPanel.Position = [22 14 473 162];

      % Create SetpointEditField_7
      app.SetpointEditField_7 = uieditfield(app.BC14BunchLengthFeedbackPanel, 'numeric');
      app.SetpointEditField_7.ValueChangedFcn = createCallbackFcn(app, @SetpointEditField_7ValueChanged, true);
      app.SetpointEditField_7.HorizontalAlignment = 'center';
      app.SetpointEditField_7.Position = [17 77 100 29];
      app.SetpointEditField_7.Value = 50;

      % Create fsLabel
      app.fsLabel = uilabel(app.BC14BunchLengthFeedbackPanel);
      app.fsLabel.FontSize = 16;
      app.fsLabel.Position = [128 82 25 22];
      app.fsLabel.Text = 'fs';

      % Create Gauge_13
      app.Gauge_13 = uigauge(app.BC14BunchLengthFeedbackPanel, 'linear');
      app.Gauge_13.Limits = [-180 180];
      app.Gauge_13.FontSize = 10;
      app.Gauge_13.Position = [334 59 126 35];

      % Create L2PHASELabel
      app.L2PHASELabel = uilabel(app.BC14BunchLengthFeedbackPanel);
      app.L2PHASELabel.HorizontalAlignment = 'center';
      app.L2PHASELabel.Position = [338 92 120 22];
      app.L2PHASELabel.Text = 'L2 PHASE';

      % Create BLENLI14888Label
      app.BLENLI14888Label = uilabel(app.BC14BunchLengthFeedbackPanel);
      app.BLENLI14888Label.HorizontalAlignment = 'center';
      app.BLENLI14888Label.Position = [192 93 113 22];
      app.BLENLI14888Label.Text = 'BLEN:LI14:888';

      % Create EditField_15
      app.EditField_15 = uieditfield(app.BC14BunchLengthFeedbackPanel, 'numeric');
      app.EditField_15.Editable = 'off';
      app.EditField_15.HorizontalAlignment = 'center';
      app.EditField_15.FontSize = 10;
      app.EditField_15.Position = [185 36 125 22];

      % Create EditField_16
      app.EditField_16 = uieditfield(app.BC14BunchLengthFeedbackPanel, 'numeric');
      app.EditField_16.Editable = 'off';
      app.EditField_16.HorizontalAlignment = 'center';
      app.EditField_16.FontSize = 10;
      app.EditField_16.Position = [334 36 125 22];

      % Create StatusLamp_7
      app.StatusLamp_7 = uilamp(app.BC14BunchLengthFeedbackPanel);
      app.StatusLamp_7.Position = [5 109 30 30];
      app.StatusLamp_7.Color = [0 0 0];

      % Create NotRunningButton_7
      app.NotRunningButton_7 = uibutton(app.BC14BunchLengthFeedbackPanel, 'push');
      app.NotRunningButton_7.FontSize = 8;
      app.NotRunningButton_7.FontWeight = 'bold';
      app.NotRunningButton_7.Position = [46 115 417 22];
      app.NotRunningButton_7.Text = 'Not Running';

      % Create Switch_7
      app.Switch_7 = uiswitch(app.BC14BunchLengthFeedbackPanel, 'slider');
      app.Switch_7.ValueChangedFcn = createCallbackFcn(app, @Switch_7ValueChanged, true);
      app.Switch_7.Position = [51 18 88 39];

      % Create Gauge_12
      app.Gauge_12 = uigauge(app.BC14BunchLengthFeedbackPanel, 'linear');
      app.Gauge_12.Limits = [-100 100];
      app.Gauge_12.MajorTicks = [-100 -60 -20 20 60 100];
      app.Gauge_12.MajorTickLabels = {''};
      app.Gauge_12.MinorTicks = [-100 -92 -84 -76 -68 -60 -52 -44 -36 -28 -20 -12 -4 4 12 20 28 36 44 52 60 68 76 84 92 100];
      app.Gauge_12.ScaleColors = [1 0 0;1 0 0;0.3922 0.8314 0.0745];
      app.Gauge_12.ScaleColorLimits = [-100 -75;75 100;-25 25];
      app.Gauge_12.FontSize = 10;
      app.Gauge_12.Position = [186 61 125 32];

      % Create ActuatorRestoreToDate_BC14_BLEN
      app.ActuatorRestoreToDate_BC14_BLEN = uibutton(app.BC14BunchLengthFeedbackPanel, 'push');
      app.ActuatorRestoreToDate_BC14_BLEN.ButtonPushedFcn = createCallbackFcn(app, @ActuatorRestoreToDate_BC14_BLENButtonPushed, true);
      app.ActuatorRestoreToDate_BC14_BLEN.Position = [205 5 225 26];
      app.ActuatorRestoreToDate_BC14_BLEN.Text = 'Actuator Restore To Date-time';

      % Create FeedbackWatcherProcessStatusPanel
      app.FeedbackWatcherProcessStatusPanel = uipanel(app.FACETIIFeedbackUIFigure);
      app.FeedbackWatcherProcessStatusPanel.Title = 'Feedback Watcher Process Status';
      app.FeedbackWatcherProcessStatusPanel.Position = [22 689 951 67];

      % Create fbstat
      app.fbstat = uilabel(app.FeedbackWatcherProcessStatusPanel);
      app.fbstat.HorizontalAlignment = 'center';
      app.fbstat.FontSize = 18;
      app.fbstat.FontWeight = 'bold';
      app.fbstat.FontColor = [0.851 0.3294 0.102];
      app.fbstat.Position = [231 12 509 23];
      app.fbstat.Text = 'MATLAB Watcher Process STOPPED - All Feedbacks OFF';

      % Show the figure after all components are created
      app.FACETIIFeedbackUIFigure.Visible = 'on';
    end
  end

  % App creation and deletion
  methods (Access = public)

    % Construct app
    function app = F2_Feedback_exported(varargin)

      % Create UIFigure and components
      createComponents(app)

      % Register the app with App Designer
      registerApp(app, app.FACETIIFeedbackUIFigure)

      % Execute the startup function
      runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

      if nargout == 0
        clear app
      end
    end

    % Code that executes before app deletion
    function delete(app)

      % Delete UIFigure when app is deleted
      delete(app.FACETIIFeedbackUIFigure)
    end
  end
end