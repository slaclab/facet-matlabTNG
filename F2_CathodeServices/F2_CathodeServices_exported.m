classdef F2_CathodeServices_exported < matlab.apps.AppBase

  % Properties that correspond to app components
  properties (Access = public)
    FACETIICathodeServicesUIFigure  matlab.ui.Figure
    FileMenu                        matlab.ui.container.Menu
    PropertiesMenu                  matlab.ui.container.Menu
    SaveConfigasMenu                matlab.ui.container.Menu
    LoadConfigMenu                  matlab.ui.container.Menu
    SaveBufferedDataMenu            matlab.ui.container.Menu
    SaveCleaningDataMenu            matlab.ui.container.Menu
    SettingsMenu                    matlab.ui.container.Menu
    EditLimitsMenu                  matlab.ui.container.Menu
    LaserPosTolMenu                 matlab.ui.container.Menu
    MotorCALMenu                    matlab.ui.container.Menu
    BufferSizeMenu                  matlab.ui.container.Menu
    ClearBufferMenu                 matlab.ui.container.Menu
    ImageRotation0Menu              matlab.ui.container.Menu
    ImageFlipX0Menu                 matlab.ui.container.Menu
    ImageFlipY0Menu                 matlab.ui.container.Menu
    StartDistance                   matlab.ui.container.Menu
    OrthBacklash                    matlab.ui.container.Menu
    ImageMenu                       matlab.ui.container.Menu
    LoadImageMenu                   matlab.ui.container.Menu
    SaveImageMenu                   matlab.ui.container.Menu
    NormalizationMenu               matlab.ui.container.Menu
    SelectColorMapMenu              matlab.ui.container.Menu
    ShowFitMenu                     matlab.ui.container.Menu
    ToolsMenu                       matlab.ui.container.Menu
    PositionCalibrationMenu         matlab.ui.container.Menu
    StripToolMenu                   matlab.ui.container.Menu
    HelpMenu                        matlab.ui.container.Menu
    AboutMenu                       matlab.ui.container.Menu
    DocumentationMenu               matlab.ui.container.Menu
    ProceduresMenu                  matlab.ui.container.Menu
    SwitchOPStoLaserCleaningmodeMenu  matlab.ui.container.Menu
    SwitchLaserCleaningtoOPSmodeMenu  matlab.ui.container.Menu
    TabGroup                        matlab.ui.container.TabGroup
    LaserCleaningTab                matlab.ui.container.Tab
    DefineCleaningAreaButton        matlab.ui.control.Button
    PulsesateachpositionSpinnerLabel  matlab.ui.control.Label
    PulsesateachpositionSpinner     matlab.ui.control.Spinner
    StepSizeumEditFieldLabel        matlab.ui.control.Label
    StepSizeEditField               matlab.ui.control.NumericEditField
    ExecuteAutomaticCleaningProcedureButton  matlab.ui.control.Button
    STOPButton                      matlab.ui.control.StateButton
    CleaningStatusEditFieldLabel    matlab.ui.control.Label
    CleaningStatusEditField         matlab.ui.control.EditField
    min00secGaugeLabel              matlab.ui.control.Label
    min00secGauge                   matlab.ui.control.NinetyDegreeGauge
    ApproxTimeRemainingminLabel     matlab.ui.control.Label
    CleaningRadiusmmEditFieldLabel  matlab.ui.control.Label
    CleaningRadiusmmEditField       matlab.ui.control.NumericEditField
    TestCleaningSequenceButton      matlab.ui.control.Button
    DetermineCleaningEnergyButton   matlab.ui.control.Button
    ccentEdit_x                     matlab.ui.control.NumericEditField
    CleaningCentermmLabel           matlab.ui.control.Label
    ccentEdit_y                     matlab.ui.control.NumericEditField
    getButton                       matlab.ui.control.Button
    XLabel                          matlab.ui.control.Label
    YLabel                          matlab.ui.control.Label
    ResetButton                     matlab.ui.control.Button
    StartPositionKnob               matlab.ui.control.DiscreteKnob
    CleaningStartPositionLabel      matlab.ui.control.Label
    QEMapTab                        matlab.ui.container.Tab
    DefineMapAreaButton             matlab.ui.control.Button
    ExecuteQEMapProgramButton       matlab.ui.control.Button
    STOPButton_2                    matlab.ui.control.StateButton
    ApproxTimeRemainingminLabel_2   matlab.ui.control.Label
    ccentEdit_x_2                   matlab.ui.control.NumericEditField
    MapCentermmLabel                matlab.ui.control.Label
    ccentEdit_y_2                   matlab.ui.control.NumericEditField
    getButton_2                     matlab.ui.control.Button
    XLabel_2                        matlab.ui.control.Label
    YLabel_2                        matlab.ui.control.Label
    PulsesateachpositionSpinner_2Label  matlab.ui.control.Label
    PulsesateachpositionSpinner_2   matlab.ui.control.Spinner
    StepSizeumEditFieldLabel_2      matlab.ui.control.Label
    StepSizeEditField_2             matlab.ui.control.NumericEditField
    MappingStatusEditFieldLabel     matlab.ui.control.Label
    MappingStatusEditField          matlab.ui.control.EditField
    min00secGauge_2Label            matlab.ui.control.Label
    min00secGauge_2                 matlab.ui.control.NinetyDegreeGauge
    MapRadiusmmEditFieldLabel       matlab.ui.control.Label
    MapRadiusmmEditField            matlab.ui.control.NumericEditField
    UseTorroidDataSwitch            matlab.ui.control.RockerSwitch
    UseLaserDataSwitch              matlab.ui.control.RockerSwitch
    ResettoStandbyButton_2          matlab.ui.control.Button
    VCCImagePanel                   matlab.ui.container.Panel
    UIAxes                          matlab.ui.control.UIAxes
    GrabFrameButton                 matlab.ui.control.Button
    ControlsButton_5                matlab.ui.control.Button
    StreamImageButton               matlab.ui.control.StateButton
    BufferedDataAcquisitionButton   matlab.ui.control.StateButton
    DetachButton                    matlab.ui.control.StateButton
    BackgroundPanel                 matlab.ui.container.Panel
    SubtractCheckBox                matlab.ui.control.CheckBox
    ValidLabel                      matlab.ui.control.Label
    ValidLamp                       matlab.ui.control.Lamp
    TakeNewButton                   matlab.ui.control.Button
    N_aveEditFieldLabel             matlab.ui.control.Label
    N_aveEditField                  matlab.ui.control.NumericEditField
    GunVacuumPanel                  matlab.ui.container.Panel
    GunVacuumGauge                  matlab.ui.control.LinearGauge
    EditField_2                     matlab.ui.control.NumericEditField
    nTorrLabel                      matlab.ui.control.Label
    LaserEnergyPanel                matlab.ui.container.Panel
    LaserEnergyGauge                matlab.ui.control.LinearGauge
    EditField_3                     matlab.ui.control.NumericEditField
    ControlsButton_3                matlab.ui.control.Button
    uJLabel                         matlab.ui.control.Label
    ShutterPanel                    matlab.ui.container.Panel
    STATUSLamp                      matlab.ui.control.Lamp
    CLOSESwitch                     matlab.ui.control.ToggleSwitch
    STATUSLampOPEN                  matlab.ui.control.Lamp
    EPICSWatchdogPanel              matlab.ui.container.Panel
    RunningLampLabel                matlab.ui.control.Label
    RunningLamp                     matlab.ui.control.Lamp
    ToroidpCPanel                   matlab.ui.container.Panel
    Gauge                           matlab.ui.control.LinearGauge
    EditField_6                     matlab.ui.control.NumericEditField
    FaradayCuppCPanel               matlab.ui.container.Panel
    Gauge_2                         matlab.ui.control.LinearGauge
    ControlsButton                  matlab.ui.control.Button
    Lamp                            matlab.ui.control.Lamp
    EditField_5                     matlab.ui.control.NumericEditField
    LaserPositionmmPanel            matlab.ui.container.Panel
    OpenMotionControlButton         matlab.ui.control.Button
    InrangeLampLabel                matlab.ui.control.Label
    InrangeLamp                     matlab.ui.control.Lamp
    XmotLabel                       matlab.ui.control.Label
    YmotLabel                       matlab.ui.control.Label
    EditField_7                     matlab.ui.control.NumericEditField
    EditField_8                     matlab.ui.control.NumericEditField
    XimgLabel                       matlab.ui.control.Label
    YimgLabel                       matlab.ui.control.Label
    EditField_11                    matlab.ui.control.NumericEditField
    EditField_12                    matlab.ui.control.NumericEditField
    InmotionLampLabel               matlab.ui.control.Label
    InmotionLamp                    matlab.ui.control.Lamp
    HomeVELOmmsEditFieldLabel       matlab.ui.control.Label
    HomeVELOmmsEditField            matlab.ui.control.NumericEditField
    MoveHome                        matlab.ui.control.Button
    MoveStop                        matlab.ui.control.Button
    CalMotor                        matlab.ui.control.Button
    ImageIntensityPanel             matlab.ui.container.Panel
    ImageIntensityGauge             matlab.ui.control.LinearGauge
    EditField_4                     matlab.ui.control.NumericEditField
    GunRFPanel                      matlab.ui.container.Panel
    ModOFFLampLabel                 matlab.ui.control.Label
    ModOFFLamp                      matlab.ui.control.Lamp
    ControlsButton_2                matlab.ui.control.Button
    CCDAcquireRateHzPanel           matlab.ui.container.Panel
    EditField_13                    matlab.ui.control.NumericEditField
    LaserSpotSizePanel              matlab.ui.container.Panel
    LaserSpotSizeGaugeX             matlab.ui.control.LinearGauge
    LaserSpotSizeX                  matlab.ui.control.NumericEditField
    XumFWHMYLabel                   matlab.ui.control.Label
    LaserSpotSizeGaugeY             matlab.ui.control.LinearGauge
    LaserSpotSizeY                  matlab.ui.control.NumericEditField
    LaserTelescopeInsertedPanel     matlab.ui.container.Panel
    SmallSpotEnabledLampLabel       matlab.ui.control.Label
    SmallSpotEnabledLamp            matlab.ui.control.Lamp
    LaserFluenceuJmm2Panel          matlab.ui.container.Panel
    Gauge_3                         matlab.ui.control.LinearGauge
    EditField_17                    matlab.ui.control.NumericEditField
    SoftwareRateHzPanel             matlab.ui.container.Panel
    EditField_15                    matlab.ui.control.NumericEditField
    LaserRepRateHzPanel_2           matlab.ui.container.Panel
    EditField_16                    matlab.ui.control.NumericEditField
    ValveVV155Panel                 matlab.ui.container.Panel
    OUTLampLabel                    matlab.ui.control.Label
    VV155Lamp                       matlab.ui.control.Lamp
    ControlButton                   matlab.ui.control.Button
    LaserAttFlipperINLampLabel      matlab.ui.control.Label
    LaserAttFlipperINLamp           matlab.ui.control.Lamp
  end

  
  properties (Access = public)
    aobj % F2_CathodeServicesApp object that called gui
  end
  
  

  % Callbacks that handle component events
  methods (Access = private)

    % Code that executes after component creation
    function startupFcn(app, appobj)
      fprintf('Launching F2_CathodeServicesApp...\n');
      if ~exist('appobj','var')
        appobj=F2_CathodeServicesApp(0,app);
      end
      disp('Attaching app object...')
      app.aobj=appobj;
      disp('Return')
    end

    % Value changed function: EditField_2
    function EditField_2ValueChanged(app, event)
      
      % User picks cleaning center coordinates
      waitfor(app.UIAxes,'CurrentPoint');
      chosenpoint=app.UIAxes.CurrentPoint;
      app.ccentEdit_x.Value=chosenpoint(1,1);
      app.ccentEdit_y.Value=chosenpoint(1,2);
    end

    % Button pushed function: getButton
    function getButtonPushed(app, event)
      app.ccentEdit_x.Value=round(double(app.aobj.LaserPosition_img(1)),3);
      app.ccentEdit_xValueChanged(event);
      app.ccentEdit_y.Value=round(double(app.aobj.LaserPosition_img(2)),3);
      app.ccentEdit_yValueChanged(event);
    end

    % Value changed function: StreamImageButton
    function StreamImageButtonValueChanged(app, event)
      value = app.StreamImageButton.Value;
      if value
        app.aobj.guicmd("acq-cont");
      else
        app.aobj.guicmd("acq-stop");
      end
    end

    % Button pushed function: GrabFrameButton
    function GrabFrameButtonPushed(app, event)
      if ~app.StreamImageButton.Value
        app.aobj.guicmd("acq-single");
      end
    end

    % Value changed function: STOPButton
    function STOPButtonValueChanged(app, event)
      app.aobj.dnCMD=true;
      app.aobj.StopResetGUI('STOP');
      app.aobj.dnCMD=false;
    end

    % Button pushed function: DefineCleaningAreaButton
    function DefineCleaningAreaButtonPushed(app, event)
      app.aobj.State = CathodeServicesState.Cleaning_definearea ;
    end

    % Value changed function: ccentEdit_x
    function ccentEdit_xValueChanged(app, event)
      app.aobj.CleaningCenter(1)=app.ccentEdit_x.Value;
    end

    % Value changed function: ccentEdit_y
    function ccentEdit_yValueChanged(app, event)
      app.aobj.CleaningCenter(2)=app.ccentEdit_y.Value;
    end

    % Value changed function: CleaningRadiusmmEditField
    function CleaningRadiusmmEditFieldValueChanged(app, event)
      value = app.CleaningRadiusmmEditField.Value;
      app.aobj.CleaningRadius = value*1e-3 ;
    end

    % Value changed function: StepSizeEditField
    function StepSizeEditFieldValueChanged(app, event)
      value = app.StepSizeEditField.Value;
      app.aobj.CleaningStepSize=value*1e-6;
    end

    % Value changed function: PulsesateachpositionSpinner
    function PulsesateachpositionSpinnerValueChanged(app, event)
      value = app.PulsesateachpositionSpinner.Value;
      app.aobj.CleaningNumPulsesPerStep=value;
    end

    % Button pushed function: ResetButton
    function ResetButtonPushed(app, event)
      app.aobj.dnCMD=true;
      app.aobj.StopResetGUI('RESET');
      app.aobj.dnCMD=false;
    end

    % Menu selected function: EditLimitsMenu
    function EditLimitsMenuSelected(app, event)
      app.aobj.dnCMD=true;
      CathodeServices_limits(app.aobj);
      app.aobj.dnCMD=false;
    end

    % Menu selected function: LaserPosTolMenu
    function LaserPosTolMenuSelected(app, event)
      app.aobj.dnCMD=true;
      newtol=inputdlg('Position Tolerance [um]:','Laser Position Tolerance',1,{num2str(app.aobj.LaserPosition_tol*1000)});
      if ~isempty(newtol) && str2double(newtol{1})>0
        app.aobj.SetLimits('LaserPosition_tol',str2double(newtol{1})/1000) ;
      end
      app.aobj.dnCMD=false;
    end

    % Callback function
    function ChangeLimitsMenuSelected(app, event)
      CathodeServices_limits(app.aobj);
    end

    % Menu selected function: MotorCALMenu
    function MotorCALMenuSelected(app, event)
      app.aobj.dnCMD=true;
      newcal=inputdlg({'X Offset [mm]:','Y Offset [mm]:','X Scale [Motor mm : Sceen mm]:','Y Scale [Motor mm : Sceen mm]:'},...
        'Motor Position Calibration',1,cellstr(string(app.aobj.VCC_mirrcal))) ;
      if ~isempty(newcal)
        app.aobj.SetMirrCal(str2double(newcal));
      end
      app.aobj.dnCMD=false;
    end

    % Menu selected function: PositionCalibrationMenu
    function PositionCalibrationMenuSelected(app, event)
      if isempty(app.aobj.CalibHan) || ~ishandle(app.aobj.CalibHan(1))
        app.aobj.CalibHan(1) = subplot(2,1,1) ;
        grid(app.aobj.CalibHan(1),'on');
        xlabel(app.aobj.CalibHan(1),'Mirror Motor Reported H Position [mm]');
        ylabel(app.aobj.CalibHan(1),'Image Reported H Position [mm]');
        app.aobj.CalibHan(2) = subplot(2,1,2) ;
        grid(app.aobj.CalibHan(2),'on');
        xlabel(app.aobj.CalibHan(2),'Mirror Motor Reported V Position [mm]');
        ylabel(app.aobj.CalibHan(2),'Image Reported V Position [mm]');
      else
        axes(app.aobj.CalibHan(1));
      end
    end

    % Button pushed function: TestCleaningSequenceButton
    function TestCleaningSequenceButtonPushed(app, event)
      app.aobj.Proc_Cleaning_testpattern(CathodeServicesState.Cleaning_testpattern);
    end

    % Menu selected function: ClearBufferMenu
    function ClearBufferMenuSelected(app, event)
      app.aobj.ClearBuffer;
    end

    % Menu selected function: BufferSizeMenu
    function BufferSizeMenuSelected(app, event)
      app.aobj.dnCMD=true;
      bufsize=inputdlg('Enter new data buffer length:','Change Data Buffer Length',1,{num2str(app.aobj.buflen)});
      if ~isempty(bufsize) && str2double(bufsize{1})>0
        app.aobj.buflen=str2double(bufsize(1));
        app.BufferSizeMenu.Text = sprintf('Buffer Length = %d',app.aobj.buflen) ;
      end
      app.aobj.dnCMD=false;
    end

    % Button pushed function: DetermineCleaningEnergyButton
    function DetermineCleaningEnergyButtonPushed(app, event)
      app.aobj.Proc_Cleaning_testpattern(CathodeServicesState.Cleaning_setenergypattern);
    end

    % Menu selected function: SaveBufferedDataMenu
    function SaveBufferedDataMenuSelected(app, event)
      app.aobj.dnCMD=true;
      [fn,pn]=uiputfile('*.mat');
      if ~isequal(fn,0)
        PositionData = app.aobj.poshistory ;
        timestamp=now;
        save(fullfile(pn,fn),'PositionData','timestamp');
      end
      app.aobj.dnCMD=false;
    end

    % Menu selected function: AboutMenu
    function AboutMenuSelected(app, event)
      helpdlg({sprintf('FACET-II Cathode Services App Version %.3f',app.aobj.version),'Author: G. White (whitegr@slac.stanford.edu)'},'About App')
    end

    % Button pushed function: MoveHome
    function MoveHomeButtonPushed(app, event)
      app.aobj.movemirror("home") ;
    end

    % Button pushed function: MoveStop
    function MoveStopButtonPushed(app, event)
      caput(app.aobj.pvs.lsr_stopx,1); caput(app.aobj.pvs.lsr_stopy,1);
    end

    % Close request function: FACETIICathodeServicesUIFigure
    function FACETIICathodeServicesUIFigureCloseRequest(app, event)
      app.aobj.dnCMD=true;
      try
        app.aobj.shutdown;
      catch ME
        fprintf(2,'Shutdown actions failed:\n');
        fprintf(2,'%s\n',ME.message);
        delete(app);
      end
      delete(app);
    end

    % Value changed function: StartPositionKnob
    function StartPositionKnobValueChanged(app, event)
      value = str2double(app.StartPositionKnob.Value);
      app.aobj.CleaningStartPosition = value ;
    end

    % Button pushed function: 
    % ExecuteAutomaticCleaningProcedureButton
    function ExecuteAutomaticCleaningProcedureButtonPushed(app, event)
      app.aobj.Proc_Cleaning();
    end

    % Menu selected function: PropertiesMenu
    function PropertiesMenuSelected(app, event)
      msgbox(sprintf('App Ave. Update Rate = %.1f +/- %.1f Hz',app.aobj.wd_freq,app.aobj.wd_freqerr),'Application Properties');
    end

    % Value changed function: BufferedDataAcquisitionButton
    function BufferedDataAcquisitionButtonValueChanged(app, event)
      value = app.BufferedDataAcquisitionButton.Value;
      app.aobj.bufacq = value ;
    end

    % Menu selected function: SaveConfigasMenu
    function SaveConfigasMenuSelected(app, event)
      app.aobj.dnCMD=true;
      [fn,pn]=uiputfile('*.mat');
      if ~isequal(fn,0)
        app.aobj.SaveConfig(fullfile(pn,fn));
      end
      app.aobj.dnCMD=false;
    end

    % Menu selected function: LoadConfigMenu
    function LoadConfigMenuSelected(app, event)
      app.aobj.dnCMD=true;
      [fn,pn]=uigetfile('*.mat');
      if ~isequal(fn,0)
        app.aobj.LoadConfig(fullfile(pn,fn));
      end
      app.aobj.dnCMD=false;
    end

    % Value changed function: HomeVELOmmsEditField
    function HomeVELOmmsEditFieldValueChanged(app, event)
      value = app.HomeVELOmmsEditField.Value;
      app.aobj.MotorVeloHome = value ;
    end

    % Menu selected function: LoadImageMenu
    function LoadImageMenuSelected(app, event)
      app.aobj.dnCMD=true;
      [fn,pn]=uigetfile('*.mat');
      if ~isequal(fn,0)
        app.aobj.LoadImage(fullfile(pn,fn));
      end
      app.aobj.dnCMD=false;
    end

    % Menu selected function: SaveImageMenu
    function SaveImageMenuSelected(app, event)
      app.aobj.dnCMD=true;
      [fn,pn]=uiputfile('*.mat');
      if ~isequal(fn,0)
        app.aobj.SaveImage(fullfile(pn,fn));
      end
      app.aobj.dnCMD=false;
    end

    % Menu selected function: DocumentationMenu
    function DocumentationMenuSelected(app, event)
      web('F2_CathodeServices.html');
    end

    % Button pushed function: CalMotor
    function CalMotorButtonPushed(app, event)
      mhan=msgbox('Getting Calibration data...','Getting Data','help','replace');
      try
        xave=caget(app.aobj.pvs.lsr_posx);
        yave=caget(app.aobj.pvs.lsr_posy);
        xave_CCD=caget(app.aobj.pvs.CCD_xpos_out);
        yave_CCD=caget(app.aobj.pvs.CCD_ypos_out);
      catch
        delete(mhan);
        errordlg("Timeout getting new motor positions","Motor Pos Timeout");
        return
      end
      if ishandle(mhan)
        delete(mhan);
      end
      oldcal = app.aobj.VCC_mirrcal;
      dx = xave_CCD - xave ;
      dy = yave_CCD - yave ;
      newcaloff = oldcal(1:2) + [dx dy] ;
      app.aobj.dnCMD=true;
      resp = questdlg(sprintf('Old calibration offset = %g , %g\nNew Calibration Offset = %g , %g\nOK?',oldcal(1:2),newcaloff),'Confirm Cal','Yes','No','No');
      if strcmp(resp,'Yes')
        oldcal(1:2) = newcaloff ;
        app.aobj.SetMirrCal(oldcal) ;
      end
      app.aobj.dnCMD=false;
    end

    % Menu selected function: ImageRotation0Menu
    function ImageRotation0MenuSelected(app, event)
      app.aobj.dnCMD=true;
      rot=inputdlg('Enter image rotation multiple of 90 degrees (enter 0,1,2 or 3)','Image Rotation');
      rot=str2double(rot);
      if ismember(rot,[0 1 2 3])
        app.aobj.imrot = uint8(rot) ;
        app.ImageRotation0Menu.Text = sprintf('Image Rotation = %d',rot);
      end
      app.aobj.dnCMD=false;
    end

    % Button pushed function: DefineMapAreaButton
    function DefineMapAreaButtonPushed(app, event)
      app.aobj.State = CathodeServicesState.QEMap_definearea ;
    end

    % Button pushed function: getButton_2
    function getButton_2Pushed(app, event)
      app.ccentEdit_x_2.Value=round(double(app.aobj.LaserPosition_img(1)),3);
      app.ccentEdit_x_2ValueChanged(event);
      app.ccentEdit_y_2.Value=round(double(app.aobj.LaserPosition_img(2)),3);
      app.ccentEdit_y_2ValueChanged(event);
    end

    % Value changed function: ccentEdit_x_2
    function ccentEdit_x_2ValueChanged(app, event)
      value = app.ccentEdit_x_2.Value;
      app.aobj.MapCenter(1)=value;
    end

    % Value changed function: ccentEdit_y_2
    function ccentEdit_y_2ValueChanged(app, event)
      value = app.ccentEdit_y_2.Value;
      app.aobj.MapCenter(2)=value;
    end

    % Value changed function: MapRadiusmmEditField
    function MapRadiusmmEditFieldValueChanged(app, event)
      value = app.MapRadiusmmEditField.Value;
      app.aobj.MapRadius = value*1e-3 ;
    end

    % Value changed function: PulsesateachpositionSpinner_2
    function PulsesateachpositionSpinner_2ValueChanged(app, event)
      value = app.PulsesateachpositionSpinner_2.Value;
      app.aobj.MapNumPulsesPerStep=value;
    end

    % Value changed function: StepSizeEditField_2
    function StepSizeEditField_2ValueChanged(app, event)
      value = app.StepSizeEditField_2.Value;
      app.aobj.MapStepSize=value*1e-6;
    end

    % Button pushed function: ExecuteQEMapProgramButton
    function ExecuteQEMapProgramButtonPushed(app, event)
      app.aobj.Proc_QEMap();
    end

    % Value changed function: STOPButton_2
    function STOPButton_2ValueChanged(app, event)
      app.aobj.guicmd("stop-reset");
    end

    % Value changed function: UseLaserDataSwitch
    function UseLaserDataSwitchValueChanged(app, event)
      app.aobj.imupdate = true ; % force image to update
    end

    % Value changed function: UseTorroidDataSwitch
    function UseTorroidDataSwitchValueChanged(app, event)
      app.aobj.imupdate = true ; % force image to update
    end

    % Button pushed function: ResettoStandbyButton_2
    function ResettoStandbyButton_2Pushed(app, event)
      app.aobj.dnCMD=true;
      resp=questdlg('Stop all operations and reset to standby mode (memory of any progress will be lost)?','Reset to Stanby Mode',...
        'Yes','No','No');
      if strcmp(resp,'Yes')
        app.aobj.MapLineNum=1;
        app.aobj.MapColNum=1;
        app.aobj.StopResetGUI('RESET');
        app.aobj.ClearPIMG;
        if strcmp(app.aobj.pvs.laser_telescope.val{1},'IN')
          app.aobj.State=CathodeServicesState.Standby_cleaninglasermode;
        else
          app.aobj.State=CathodeServicesState.Standby_opslasermode;
        end
        app.aobj.imupdate=true;
        if ~app.StreamImageButton.Value
          app.GrabFrameButtonPushed(app.GrabFrameButton);
        end
      end
      app.aobj.dnCMD=false;
    end

    % Callback function
    function ContextMenuOpening(app, event)
      get(event.Source)
    end

    % Menu selected function: ImageFlipX0Menu
    function ImageFlipX0MenuSelected(app, event)
      app.aobj.dnCMD=true;
      resp=questdlg('Flip image X-Axis (after rotation if set)?','Flip Image X Axis?','Yes','No','Cancel','Cancel');
      if strcmp(resp,'Yes')
        app.aobj.imflipX = true ;
      elseif strcmp(resp,'No')
        app.aobj.imflipX = false ;
      end
      app.ImageFlipX0Menu.Text = sprintf('Image Flip X = %d',app.aobj.imflipX);
      app.aobj.dnCMD=false;
    end

    % Menu selected function: ImageFlipY0Menu
    function ImageFlipY0MenuSelected(app, event)
      app.aobj.dnCMD=true;
      resp=questdlg('Flip image Y-Axis (after rotation if set)?','Flip Image X Axis?','Yes','No','Cancel','Cancel');
      if strcmp(resp,'Yes')
        app.aobj.imflipY = true ;
      elseif strcmp(resp,'No')
        app.aobj.imflipY = false ;
      end
      app.ImageFlipY0Menu.Text = sprintf('Image Flip Y = %d',app.aobj.imflipX);
      app.aobj.dnCMD=false;
    end

    % Value changed function: EditField_16
    function EditField_16ValueChanged(app, event)
      value = app.EditField_16.Value;
      app.aobj.RepRate = round(value) ;
    end

    % Button pushed function: ControlsButton_5
    function ControlsButton_5Pushed(app, event)
      system('edm -eolc -x -m "SYS=SYS1,EVGLOCA=SYS1,area=in10,x=2,subsys=lasr,y=7,ID=900,P=CAMR:,CAM=LT10:,LABEL=VCCF" /usr/local/facet/tools/edm/display/laser/lr10_cameras.edl &');
    end

    % Menu selected function: StartDistance
    function StartDistanceMenuSelected(app, event)
      app.aobj.dnCMD=true;
      adist=inputdlg('Start distance from cleaning edge [mm]:','Start Distance',1,{num2str(app.aobj.adistadd)});
      val=str2double(adist{1});
      if ~isempty(adist) && val>=0
        app.aobj.adistadd = val ;
      end
      app.StartDistance.Text=sprintf('Start Distance = %g',val);
      app.aobj.dnCMD=false;
    end

    % Menu selected function: OrthBacklash
    function OrthBacklashMenuSelected(app, event)
      if app.OrthBacklash.Checked
        app.OrthBacklash.Checked=false;
        app.aobj.orthcorrect=false;
      else
        app.OrthBacklash.Checked=true;
        app.aobj.orthcorrect=true;
      end
      
    end

    % Menu selected function: NormalizationMenu
    function NormalizationMenuSelected(app, event)
      app.aobj.dnCMD=true;
      opts={'LaserEnergy' 'CCD'};
      [sel,ok]=listdlg('PromptString','Select Normalization Method for image:','SelectionMode','single','ListString',opts);
      if ok
        app.NormalizationMenu.Text=sprintf('Normalization = %s',opts{sel});
        app.aobj.imgnormalize=string(opts{sel});
      end
      app.aobj.dnCMD=false;
    end

    % Menu selected function: SaveCleaningDataMenu
    function SaveCleaningDataMenuSelected(app, event)
      app.aobj.dnCMD=true;
      [fn,pn]=uiputfile('*.mat');
      if ~isequal(fn,0)
        CleaningData = app.aobj.CleaningSummaryData ;
        save(fullfile(pn,fn),'CleaningData');
      end
      app.aobj.dnCMD=false;
    end

    % Button pushed function: ControlsButton_3
    function ControlsButton_3Pushed(app, event)
      system('edm -eolc -x -m "SYS=SYS1,EVGLOCA=SYS1,area=in10,x=2,subsys=lasr,y=7,P=WPLT:LT10:150:,M=WP_ANGLE,A=WP_ANG_MAX" /usr/local/facet/tools/edm/display/laser/waveplatePS.edl &');
    end

    % Value changed function: SubtractCheckBox
    function SubtractCheckBoxValueChanged(app, event)
      app.aobj.usebkg = app.SubtractCheckBox.Value;
    end

    % Button pushed function: TakeNewButton
    function TakeNewButtonPushed(app, event)
      app.aobj.nbkg = app.N_aveEditField.Value;
      app.aobj.takebkg = true ;
    end

    % Menu selected function: SelectColorMapMenu
    function SelectColorMapMenuSelected(app, event)
      app.aobj.dnCMD=true;
      colormapselect(app.aobj,"imagemap");
      app.aobj.dnCMD=false;
    end

    % Button pushed function: OpenMotionControlButton
    function OpenMotionControlButtonPushed(app, event)
       system('edm -eolc -x -m "SYS=SYS1,EVGLOCA=SYS1,area=in10,x=2,subsys=lasr,y=7,P=MIRR:LT10:750:,M1=M3_MOTR_H,M2=M3_MOTR_V" /usr/local/facet/tools/edm/display/laser/motor2x.edl &');
    end

    % Button pushed function: ControlsButton_2
    function ControlsButton_2Pushed(app, event)
      system('edm -eolc -x -m "LOCA=LI10,SEC=10,STN_EW=$(STN_EW),LOCA_EW=0,DISP=klys_mr_modulator_faults,SYS=SYS1" /usr/local/facet/tools/edm/display/klys/klys_modulator_sec10.edl &');
    end

    % Button pushed function: ControlsButton
    function ControlsButtonPushed(app, event)
       system('edm -eolc -x -m "SYS=SYS1,EVGLOCA=SYS1,area=in10,x=2,subsys=prof" /usr/local/facet/tools/edm/display/facet/prof_in10_main.edl &');
    end

    % Button pushed function: ControlButton
    function ControlButtonPushed(app, event)
      system('edm -eolc -x -m "SYS=SYS1,EVGLOCA=SYS1,area=in10,x=2,subsys=vac,y=12,device=VVPG:IN10:155" /usr/local/facet/tools/edm/display/vac/vac_valve_pneumatic_in10.edl &');
    end

    % Menu selected function: ShowFitMenu
    function ShowFitMenuSelected(app, event)
      if app.ShowFitMenu.Checked
        app.ShowFitMenu.Checked=false;
        app.aobj.showimgstats=false;
      else
        app.ShowFitMenu.Checked=true;
        app.aobj.showimgstats=true;
      end
    end

    % Menu selected function: SwitchOPStoLaserCleaningmodeMenu
    function SwitchOPStoLaserCleaningmodeMenuSelected(app, event)
      msg=["Operational setpoints: LF lens at 1mm, L6 lens at 49 mm";
       "Laser cleaning setpoints: LF lens at 49mm, L6 at 1mm";
       "(1) Close laser room P-ARM shutter (set it to LOW)";
       "    SHTR:LT10:250:PARM_SHUTTER_ENBL";
       "(2) Set wave plate to minimum transmission (angle = 54 deg)";
       "(3) Set attenuation flipper to IN (MOTR:LT10:840:FLIPPER)";
       "(4) Move LF and L6 lenses from operational set points to laser cleaning setpoints";
       "(5) Open laser room P-ARM shutter (set to HIGH)";
       "(6) Change wave plate angle to get desired energy on Joule Meter";
       "    (LASR:LT10:930:PWR)";] ;
      app.aobj.ShowMessage(msg,"OPS to Laser Cleaning Procedure");
    end

    % Menu selected function: SwitchLaserCleaningtoOPSmodeMenu
    function SwitchLaserCleaningtoOPSmodeMenuSelected(app, event)
      msg=["Operational setpoints: LF lens at 1mm, L6 lens at 49 mm";
       "Laser cleaning setpoints: LF lens at 49mm, L6 at 1mm";
       "(1) Close laser room P-ARM shutter (set it to LOW)";
       "    SHTR:LT10:250:PARM_SHUTTER_ENBL";
       "(2) Set wave plate to minimum transmission (angle = 54 deg)";
       "(3) Set attenuation flipper to OUT (MOTR:LT10:840:FLIPPER)";
       "(4) Move LF and L6 lenses from laser cleaning setpoints to operational set points";
       "(5) Open laser room P-ARM shutter (set to HIGH)";
       "(6) Change wave plate angle to get desired energy on Joule Meter";
       "    (LASR:LT10:930:PWR)";
       "(7) Center OPS mode laser image on VCC to center of cleaned area using M3 motor"] ;
      app.aobj.ShowMessage(msg,"Laser Cleaning to OPS Procedure");
    end

    % Menu selected function: StripToolMenu
    function StripToolMenuSelected(app, event)
      !StripTool /u1/facet/tools/StripTool/config/jsy_laser_clean_monitor.stp &
    end
  end

  % Component initialization
  methods (Access = private)

    % Create UIFigure and components
    function createComponents(app)

      % Create FACETIICathodeServicesUIFigure and hide until all components are created
      app.FACETIICathodeServicesUIFigure = uifigure('Visible', 'off');
      app.FACETIICathodeServicesUIFigure.Position = [100 100 1574 711];
      app.FACETIICathodeServicesUIFigure.Name = 'FACET-II Cathode Services';
      app.FACETIICathodeServicesUIFigure.Resize = 'off';
      app.FACETIICathodeServicesUIFigure.CloseRequestFcn = createCallbackFcn(app, @FACETIICathodeServicesUIFigureCloseRequest, true);

      % Create FileMenu
      app.FileMenu = uimenu(app.FACETIICathodeServicesUIFigure);
      app.FileMenu.Text = 'File';

      % Create PropertiesMenu
      app.PropertiesMenu = uimenu(app.FileMenu);
      app.PropertiesMenu.MenuSelectedFcn = createCallbackFcn(app, @PropertiesMenuSelected, true);
      app.PropertiesMenu.Text = 'Properties';

      % Create SaveConfigasMenu
      app.SaveConfigasMenu = uimenu(app.FileMenu);
      app.SaveConfigasMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveConfigasMenuSelected, true);
      app.SaveConfigasMenu.Text = 'Save Config as...';

      % Create LoadConfigMenu
      app.LoadConfigMenu = uimenu(app.FileMenu);
      app.LoadConfigMenu.MenuSelectedFcn = createCallbackFcn(app, @LoadConfigMenuSelected, true);
      app.LoadConfigMenu.Text = 'Load Config';

      % Create SaveBufferedDataMenu
      app.SaveBufferedDataMenu = uimenu(app.FileMenu);
      app.SaveBufferedDataMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveBufferedDataMenuSelected, true);
      app.SaveBufferedDataMenu.Text = 'Save Buffered Data';

      % Create SaveCleaningDataMenu
      app.SaveCleaningDataMenu = uimenu(app.FileMenu);
      app.SaveCleaningDataMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveCleaningDataMenuSelected, true);
      app.SaveCleaningDataMenu.Text = 'Save Cleaning Data';

      % Create SettingsMenu
      app.SettingsMenu = uimenu(app.FACETIICathodeServicesUIFigure);
      app.SettingsMenu.Text = 'Settings';

      % Create EditLimitsMenu
      app.EditLimitsMenu = uimenu(app.SettingsMenu);
      app.EditLimitsMenu.MenuSelectedFcn = createCallbackFcn(app, @EditLimitsMenuSelected, true);
      app.EditLimitsMenu.Text = 'Edit Limits';

      % Create LaserPosTolMenu
      app.LaserPosTolMenu = uimenu(app.SettingsMenu);
      app.LaserPosTolMenu.MenuSelectedFcn = createCallbackFcn(app, @LaserPosTolMenuSelected, true);
      app.LaserPosTolMenu.Text = 'Laser Pos Tol = 30 um';

      % Create MotorCALMenu
      app.MotorCALMenu = uimenu(app.SettingsMenu);
      app.MotorCALMenu.MenuSelectedFcn = createCallbackFcn(app, @MotorCALMenuSelected, true);
      app.MotorCALMenu.Text = 'Motor CAL = [0 0 1 1]';

      % Create BufferSizeMenu
      app.BufferSizeMenu = uimenu(app.SettingsMenu);
      app.BufferSizeMenu.MenuSelectedFcn = createCallbackFcn(app, @BufferSizeMenuSelected, true);
      app.BufferSizeMenu.Text = 'Buffer Length = 1000';

      % Create ClearBufferMenu
      app.ClearBufferMenu = uimenu(app.SettingsMenu);
      app.ClearBufferMenu.MenuSelectedFcn = createCallbackFcn(app, @ClearBufferMenuSelected, true);
      app.ClearBufferMenu.Text = 'Clear Buffer';

      % Create ImageRotation0Menu
      app.ImageRotation0Menu = uimenu(app.SettingsMenu);
      app.ImageRotation0Menu.MenuSelectedFcn = createCallbackFcn(app, @ImageRotation0MenuSelected, true);
      app.ImageRotation0Menu.Visible = 'off';
      app.ImageRotation0Menu.Enable = 'off';
      app.ImageRotation0Menu.Text = 'Image Rotation = 0';

      % Create ImageFlipX0Menu
      app.ImageFlipX0Menu = uimenu(app.SettingsMenu);
      app.ImageFlipX0Menu.MenuSelectedFcn = createCallbackFcn(app, @ImageFlipX0MenuSelected, true);
      app.ImageFlipX0Menu.Text = 'Image Flip X = 0';

      % Create ImageFlipY0Menu
      app.ImageFlipY0Menu = uimenu(app.SettingsMenu);
      app.ImageFlipY0Menu.MenuSelectedFcn = createCallbackFcn(app, @ImageFlipY0MenuSelected, true);
      app.ImageFlipY0Menu.Text = 'Image Flip Y = 0';

      % Create StartDistance
      app.StartDistance = uimenu(app.SettingsMenu);
      app.StartDistance.MenuSelectedFcn = createCallbackFcn(app, @StartDistanceMenuSelected, true);
      app.StartDistance.Text = 'Start Distance = 0';

      % Create OrthBacklash
      app.OrthBacklash = uimenu(app.SettingsMenu);
      app.OrthBacklash.MenuSelectedFcn = createCallbackFcn(app, @OrthBacklashMenuSelected, true);
      app.OrthBacklash.Text = 'Orthogonal Backlash Correction';

      % Create ImageMenu
      app.ImageMenu = uimenu(app.FACETIICathodeServicesUIFigure);
      app.ImageMenu.Text = 'Image';

      % Create LoadImageMenu
      app.LoadImageMenu = uimenu(app.ImageMenu);
      app.LoadImageMenu.MenuSelectedFcn = createCallbackFcn(app, @LoadImageMenuSelected, true);
      app.LoadImageMenu.Text = 'Load Image';

      % Create SaveImageMenu
      app.SaveImageMenu = uimenu(app.ImageMenu);
      app.SaveImageMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveImageMenuSelected, true);
      app.SaveImageMenu.Text = 'Save Image';

      % Create NormalizationMenu
      app.NormalizationMenu = uimenu(app.ImageMenu);
      app.NormalizationMenu.MenuSelectedFcn = createCallbackFcn(app, @NormalizationMenuSelected, true);
      app.NormalizationMenu.Text = 'Nomalization = LaserEnergy';

      % Create SelectColorMapMenu
      app.SelectColorMapMenu = uimenu(app.ImageMenu);
      app.SelectColorMapMenu.MenuSelectedFcn = createCallbackFcn(app, @SelectColorMapMenuSelected, true);
      app.SelectColorMapMenu.Text = 'Select Color Map';

      % Create ShowFitMenu
      app.ShowFitMenu = uimenu(app.ImageMenu);
      app.ShowFitMenu.MenuSelectedFcn = createCallbackFcn(app, @ShowFitMenuSelected, true);
      app.ShowFitMenu.Text = 'Show Fit';

      % Create ToolsMenu
      app.ToolsMenu = uimenu(app.FACETIICathodeServicesUIFigure);
      app.ToolsMenu.Text = 'Tools';

      % Create PositionCalibrationMenu
      app.PositionCalibrationMenu = uimenu(app.ToolsMenu);
      app.PositionCalibrationMenu.MenuSelectedFcn = createCallbackFcn(app, @PositionCalibrationMenuSelected, true);
      app.PositionCalibrationMenu.Text = 'Position Calibration';

      % Create StripToolMenu
      app.StripToolMenu = uimenu(app.ToolsMenu);
      app.StripToolMenu.MenuSelectedFcn = createCallbackFcn(app, @StripToolMenuSelected, true);
      app.StripToolMenu.Text = 'Strip Tool';

      % Create HelpMenu
      app.HelpMenu = uimenu(app.FACETIICathodeServicesUIFigure);
      app.HelpMenu.Text = 'Help';

      % Create AboutMenu
      app.AboutMenu = uimenu(app.HelpMenu);
      app.AboutMenu.MenuSelectedFcn = createCallbackFcn(app, @AboutMenuSelected, true);
      app.AboutMenu.Text = 'About';

      % Create DocumentationMenu
      app.DocumentationMenu = uimenu(app.HelpMenu);
      app.DocumentationMenu.MenuSelectedFcn = createCallbackFcn(app, @DocumentationMenuSelected, true);
      app.DocumentationMenu.Text = 'Documentation';

      % Create ProceduresMenu
      app.ProceduresMenu = uimenu(app.HelpMenu);
      app.ProceduresMenu.Text = 'Procedures';

      % Create SwitchOPStoLaserCleaningmodeMenu
      app.SwitchOPStoLaserCleaningmodeMenu = uimenu(app.ProceduresMenu);
      app.SwitchOPStoLaserCleaningmodeMenu.MenuSelectedFcn = createCallbackFcn(app, @SwitchOPStoLaserCleaningmodeMenuSelected, true);
      app.SwitchOPStoLaserCleaningmodeMenu.Text = 'Switch OPS to Laser Cleaning mode';

      % Create SwitchLaserCleaningtoOPSmodeMenu
      app.SwitchLaserCleaningtoOPSmodeMenu = uimenu(app.ProceduresMenu);
      app.SwitchLaserCleaningtoOPSmodeMenu.MenuSelectedFcn = createCallbackFcn(app, @SwitchLaserCleaningtoOPSmodeMenuSelected, true);
      app.SwitchLaserCleaningtoOPSmodeMenu.Text = 'Switch Laser Cleaning to OPS mode';

      % Create TabGroup
      app.TabGroup = uitabgroup(app.FACETIICathodeServicesUIFigure);
      app.TabGroup.Position = [6 278 510 413];

      % Create LaserCleaningTab
      app.LaserCleaningTab = uitab(app.TabGroup);
      app.LaserCleaningTab.Title = 'Laser Cleaning';

      % Create DefineCleaningAreaButton
      app.DefineCleaningAreaButton = uibutton(app.LaserCleaningTab, 'push');
      app.DefineCleaningAreaButton.ButtonPushedFcn = createCallbackFcn(app, @DefineCleaningAreaButtonPushed, true);
      app.DefineCleaningAreaButton.Position = [16 337 197 35];
      app.DefineCleaningAreaButton.Text = 'Define Cleaning Area';

      % Create PulsesateachpositionSpinnerLabel
      app.PulsesateachpositionSpinnerLabel = uilabel(app.LaserCleaningTab);
      app.PulsesateachpositionSpinnerLabel.HorizontalAlignment = 'right';
      app.PulsesateachpositionSpinnerLabel.Position = [17 150 139 22];
      app.PulsesateachpositionSpinnerLabel.Text = '# Pulses at each position';

      % Create PulsesateachpositionSpinner
      app.PulsesateachpositionSpinner = uispinner(app.LaserCleaningTab);
      app.PulsesateachpositionSpinner.Limits = [1 100];
      app.PulsesateachpositionSpinner.ValueChangedFcn = createCallbackFcn(app, @PulsesateachpositionSpinnerValueChanged, true);
      app.PulsesateachpositionSpinner.Position = [167 147 74 22];
      app.PulsesateachpositionSpinner.Value = 3;

      % Create StepSizeumEditFieldLabel
      app.StepSizeumEditFieldLabel = uilabel(app.LaserCleaningTab);
      app.StepSizeumEditFieldLabel.HorizontalAlignment = 'right';
      app.StepSizeumEditFieldLabel.Position = [19 114 85 22];
      app.StepSizeumEditFieldLabel.Text = 'Step Size (um)';

      % Create StepSizeEditField
      app.StepSizeEditField = uieditfield(app.LaserCleaningTab, 'numeric');
      app.StepSizeEditField.ValueChangedFcn = createCallbackFcn(app, @StepSizeEditFieldValueChanged, true);
      app.StepSizeEditField.Position = [119 114 57 22];
      app.StepSizeEditField.Value = 80;

      % Create ExecuteAutomaticCleaningProcedureButton
      app.ExecuteAutomaticCleaningProcedureButton = uibutton(app.LaserCleaningTab, 'push');
      app.ExecuteAutomaticCleaningProcedureButton.ButtonPushedFcn = createCallbackFcn(app, @ExecuteAutomaticCleaningProcedureButtonPushed, true);
      app.ExecuteAutomaticCleaningProcedureButton.Position = [15 53 247 45];
      app.ExecuteAutomaticCleaningProcedureButton.Text = 'Execute Automatic Cleaning Procedure';

      % Create STOPButton
      app.STOPButton = uibutton(app.LaserCleaningTab, 'state');
      app.STOPButton.ValueChangedFcn = createCallbackFcn(app, @STOPButtonValueChanged, true);
      app.STOPButton.Text = 'STOP';
      app.STOPButton.BackgroundColor = [0.851 0.3294 0.102];
      app.STOPButton.FontWeight = 'bold';
      app.STOPButton.Position = [270 54 100 44];

      % Create CleaningStatusEditFieldLabel
      app.CleaningStatusEditFieldLabel = uilabel(app.LaserCleaningTab);
      app.CleaningStatusEditFieldLabel.HorizontalAlignment = 'right';
      app.CleaningStatusEditFieldLabel.Position = [12 16 94 22];
      app.CleaningStatusEditFieldLabel.Text = 'Cleaning Status:';

      % Create CleaningStatusEditField
      app.CleaningStatusEditField = uieditfield(app.LaserCleaningTab, 'text');
      app.CleaningStatusEditField.Editable = 'off';
      app.CleaningStatusEditField.Position = [121 16 381 22];
      app.CleaningStatusEditField.Value = 'Not started.';

      % Create min00secGaugeLabel
      app.min00secGaugeLabel = uilabel(app.LaserCleaningTab);
      app.min00secGaugeLabel.HorizontalAlignment = 'center';
      app.min00secGaugeLabel.Position = [395 223 90 22];
      app.min00secGaugeLabel.Text = '15 min 00 sec';

      % Create min00secGauge
      app.min00secGauge = uigauge(app.LaserCleaningTab, 'ninetydegree');
      app.min00secGauge.Limits = [0 15];
      app.min00secGauge.Orientation = 'southeast';
      app.min00secGauge.ScaleDirection = 'counterclockwise';
      app.min00secGauge.Position = [395 260 90 90];
      app.min00secGauge.Value = 15;

      % Create ApproxTimeRemainingminLabel
      app.ApproxTimeRemainingminLabel = uilabel(app.LaserCleaningTab);
      app.ApproxTimeRemainingminLabel.Position = [326 353 168 22];
      app.ApproxTimeRemainingminLabel.Text = 'Approx. Time Remaining (min)';

      % Create CleaningRadiusmmEditFieldLabel
      app.CleaningRadiusmmEditFieldLabel = uilabel(app.LaserCleaningTab);
      app.CleaningRadiusmmEditFieldLabel.HorizontalAlignment = 'right';
      app.CleaningRadiusmmEditFieldLabel.Position = [14 184 123 22];
      app.CleaningRadiusmmEditFieldLabel.Text = 'Cleaning Radius (mm)';

      % Create CleaningRadiusmmEditField
      app.CleaningRadiusmmEditField = uieditfield(app.LaserCleaningTab, 'numeric');
      app.CleaningRadiusmmEditField.Limits = [0 10];
      app.CleaningRadiusmmEditField.ValueChangedFcn = createCallbackFcn(app, @CleaningRadiusmmEditFieldValueChanged, true);
      app.CleaningRadiusmmEditField.Position = [149 184 59 22];
      app.CleaningRadiusmmEditField.Value = 1.5;

      % Create TestCleaningSequenceButton
      app.TestCleaningSequenceButton = uibutton(app.LaserCleaningTab, 'push');
      app.TestCleaningSequenceButton.ButtonPushedFcn = createCallbackFcn(app, @TestCleaningSequenceButtonPushed, true);
      app.TestCleaningSequenceButton.Position = [16 298 197 35];
      app.TestCleaningSequenceButton.Text = 'Test Cleaning Sequence';

      % Create DetermineCleaningEnergyButton
      app.DetermineCleaningEnergyButton = uibutton(app.LaserCleaningTab, 'push');
      app.DetermineCleaningEnergyButton.ButtonPushedFcn = createCallbackFcn(app, @DetermineCleaningEnergyButtonPushed, true);
      app.DetermineCleaningEnergyButton.Position = [16 260 197 35];
      app.DetermineCleaningEnergyButton.Text = 'Determine Cleaning Energy';

      % Create ccentEdit_x
      app.ccentEdit_x = uieditfield(app.LaserCleaningTab, 'numeric');
      app.ccentEdit_x.ValueChangedFcn = createCallbackFcn(app, @ccentEdit_xValueChanged, true);
      app.ccentEdit_x.HorizontalAlignment = 'center';
      app.ccentEdit_x.Position = [204 223 70 22];

      % Create CleaningCentermmLabel
      app.CleaningCentermmLabel = uilabel(app.LaserCleaningTab);
      app.CleaningCentermmLabel.Position = [19 223 125 22];
      app.CleaningCentermmLabel.Text = 'Cleaning Center (mm):';

      % Create ccentEdit_y
      app.ccentEdit_y = uieditfield(app.LaserCleaningTab, 'numeric');
      app.ccentEdit_y.ValueChangedFcn = createCallbackFcn(app, @ccentEdit_yValueChanged, true);
      app.ccentEdit_y.HorizontalAlignment = 'center';
      app.ccentEdit_y.Position = [281 223 71 22];

      % Create getButton
      app.getButton = uibutton(app.LaserCleaningTab, 'push');
      app.getButton.ButtonPushedFcn = createCallbackFcn(app, @getButtonPushed, true);
      app.getButton.Position = [144 223 53 22];
      app.getButton.Text = 'get';

      % Create XLabel
      app.XLabel = uilabel(app.LaserCleaningTab);
      app.XLabel.Position = [235 241 24 23];
      app.XLabel.Text = 'X';

      % Create YLabel
      app.YLabel = uilabel(app.LaserCleaningTab);
      app.YLabel.Position = [309 241 25 23];
      app.YLabel.Text = 'Y';

      % Create ResetButton
      app.ResetButton = uibutton(app.LaserCleaningTab, 'push');
      app.ResetButton.ButtonPushedFcn = createCallbackFcn(app, @ResetButtonPushed, true);
      app.ResetButton.BackgroundColor = [0.9294 0.6941 0.1255];
      app.ResetButton.FontWeight = 'bold';
      app.ResetButton.Position = [378 54 114 44];
      app.ResetButton.Text = 'Reset';

      % Create StartPositionKnob
      app.StartPositionKnob = uiknob(app.LaserCleaningTab, 'discrete');
      app.StartPositionKnob.Items = {'bottom', 'left', 'top', 'right'};
      app.StartPositionKnob.ItemsData = {'1', '2', '3', '4'};
      app.StartPositionKnob.ValueChangedFcn = createCallbackFcn(app, @StartPositionKnobValueChanged, true);
      app.StartPositionKnob.Position = [407 127 54 54];
      app.StartPositionKnob.Value = '1';

      % Create CleaningStartPositionLabel
      app.CleaningStartPositionLabel = uilabel(app.LaserCleaningTab);
      app.CleaningStartPositionLabel.Position = [371 107 128 22];
      app.CleaningStartPositionLabel.Text = 'Cleaning Start Position';

      % Create QEMapTab
      app.QEMapTab = uitab(app.TabGroup);
      app.QEMapTab.Title = 'QE Map';

      % Create DefineMapAreaButton
      app.DefineMapAreaButton = uibutton(app.QEMapTab, 'push');
      app.DefineMapAreaButton.ButtonPushedFcn = createCallbackFcn(app, @DefineMapAreaButtonPushed, true);
      app.DefineMapAreaButton.Position = [15 125 197 44];
      app.DefineMapAreaButton.Text = 'Define Map Area';

      % Create ExecuteQEMapProgramButton
      app.ExecuteQEMapProgramButton = uibutton(app.QEMapTab, 'push');
      app.ExecuteQEMapProgramButton.ButtonPushedFcn = createCallbackFcn(app, @ExecuteQEMapProgramButtonPushed, true);
      app.ExecuteQEMapProgramButton.Position = [15 53 247 45];
      app.ExecuteQEMapProgramButton.Text = 'Execute QE Map Program';

      % Create STOPButton_2
      app.STOPButton_2 = uibutton(app.QEMapTab, 'state');
      app.STOPButton_2.ValueChangedFcn = createCallbackFcn(app, @STOPButton_2ValueChanged, true);
      app.STOPButton_2.Text = 'STOP';
      app.STOPButton_2.BackgroundColor = [0.851 0.3255 0.098];
      app.STOPButton_2.FontWeight = 'bold';
      app.STOPButton_2.Position = [270 54 100 44];

      % Create ApproxTimeRemainingminLabel_2
      app.ApproxTimeRemainingminLabel_2 = uilabel(app.QEMapTab);
      app.ApproxTimeRemainingminLabel_2.Position = [326 353 168 22];
      app.ApproxTimeRemainingminLabel_2.Text = 'Approx. Time Remaining (min)';

      % Create ccentEdit_x_2
      app.ccentEdit_x_2 = uieditfield(app.QEMapTab, 'numeric');
      app.ccentEdit_x_2.ValueChangedFcn = createCallbackFcn(app, @ccentEdit_x_2ValueChanged, true);
      app.ccentEdit_x_2.HorizontalAlignment = 'center';
      app.ccentEdit_x_2.Position = [196 306 70 22];

      % Create MapCentermmLabel
      app.MapCentermmLabel = uilabel(app.QEMapTab);
      app.MapCentermmLabel.Position = [20 306 102 22];
      app.MapCentermmLabel.Text = 'Map Center (mm):';

      % Create ccentEdit_y_2
      app.ccentEdit_y_2 = uieditfield(app.QEMapTab, 'numeric');
      app.ccentEdit_y_2.ValueChangedFcn = createCallbackFcn(app, @ccentEdit_y_2ValueChanged, true);
      app.ccentEdit_y_2.HorizontalAlignment = 'center';
      app.ccentEdit_y_2.Position = [273 306 71 22];

      % Create getButton_2
      app.getButton_2 = uibutton(app.QEMapTab, 'push');
      app.getButton_2.ButtonPushedFcn = createCallbackFcn(app, @getButton_2Pushed, true);
      app.getButton_2.Position = [131 306 53 22];
      app.getButton_2.Text = 'get';

      % Create XLabel_2
      app.XLabel_2 = uilabel(app.QEMapTab);
      app.XLabel_2.Position = [227 325 24 23];
      app.XLabel_2.Text = 'X';

      % Create YLabel_2
      app.YLabel_2 = uilabel(app.QEMapTab);
      app.YLabel_2.Position = [305 325 25 23];
      app.YLabel_2.Text = 'Y';

      % Create PulsesateachpositionSpinner_2Label
      app.PulsesateachpositionSpinner_2Label = uilabel(app.QEMapTab);
      app.PulsesateachpositionSpinner_2Label.HorizontalAlignment = 'right';
      app.PulsesateachpositionSpinner_2Label.Position = [15 233 139 22];
      app.PulsesateachpositionSpinner_2Label.Text = '# Pulses at each position';

      % Create PulsesateachpositionSpinner_2
      app.PulsesateachpositionSpinner_2 = uispinner(app.QEMapTab);
      app.PulsesateachpositionSpinner_2.Limits = [1 100];
      app.PulsesateachpositionSpinner_2.ValueChangedFcn = createCallbackFcn(app, @PulsesateachpositionSpinner_2ValueChanged, true);
      app.PulsesateachpositionSpinner_2.Position = [165 230 74 22];
      app.PulsesateachpositionSpinner_2.Value = 3;

      % Create StepSizeumEditFieldLabel_2
      app.StepSizeumEditFieldLabel_2 = uilabel(app.QEMapTab);
      app.StepSizeumEditFieldLabel_2.HorizontalAlignment = 'right';
      app.StepSizeumEditFieldLabel_2.Position = [14 197 85 22];
      app.StepSizeumEditFieldLabel_2.Text = 'Step Size (um)';

      % Create StepSizeEditField_2
      app.StepSizeEditField_2 = uieditfield(app.QEMapTab, 'numeric');
      app.StepSizeEditField_2.ValueChangedFcn = createCallbackFcn(app, @StepSizeEditField_2ValueChanged, true);
      app.StepSizeEditField_2.Position = [114 197 57 22];
      app.StepSizeEditField_2.Value = 80;

      % Create MappingStatusEditFieldLabel
      app.MappingStatusEditFieldLabel = uilabel(app.QEMapTab);
      app.MappingStatusEditFieldLabel.HorizontalAlignment = 'right';
      app.MappingStatusEditFieldLabel.Position = [12 16 94 22];
      app.MappingStatusEditFieldLabel.Text = 'Mapping Status:';

      % Create MappingStatusEditField
      app.MappingStatusEditField = uieditfield(app.QEMapTab, 'text');
      app.MappingStatusEditField.Editable = 'off';
      app.MappingStatusEditField.Position = [121 16 381 22];
      app.MappingStatusEditField.Value = 'Not started.';

      % Create min00secGauge_2Label
      app.min00secGauge_2Label = uilabel(app.QEMapTab);
      app.min00secGauge_2Label.HorizontalAlignment = 'center';
      app.min00secGauge_2Label.Position = [395 223 90 22];
      app.min00secGauge_2Label.Text = '15 min 00 sec';

      % Create min00secGauge_2
      app.min00secGauge_2 = uigauge(app.QEMapTab, 'ninetydegree');
      app.min00secGauge_2.Limits = [0 15];
      app.min00secGauge_2.Orientation = 'southeast';
      app.min00secGauge_2.ScaleDirection = 'counterclockwise';
      app.min00secGauge_2.Position = [395 260 90 90];
      app.min00secGauge_2.Value = 15;

      % Create MapRadiusmmEditFieldLabel
      app.MapRadiusmmEditFieldLabel = uilabel(app.QEMapTab);
      app.MapRadiusmmEditFieldLabel.HorizontalAlignment = 'right';
      app.MapRadiusmmEditFieldLabel.Position = [15 268 100 22];
      app.MapRadiusmmEditFieldLabel.Text = 'Map Radius (mm)';

      % Create MapRadiusmmEditField
      app.MapRadiusmmEditField = uieditfield(app.QEMapTab, 'numeric');
      app.MapRadiusmmEditField.Limits = [0 10];
      app.MapRadiusmmEditField.ValueChangedFcn = createCallbackFcn(app, @MapRadiusmmEditFieldValueChanged, true);
      app.MapRadiusmmEditField.Position = [127 268 59 22];
      app.MapRadiusmmEditField.Value = 1.5;

      % Create UseTorroidDataSwitch
      app.UseTorroidDataSwitch = uiswitch(app.QEMapTab, 'rocker');
      app.UseTorroidDataSwitch.Items = {'Use Torroid Data', 'Use Faraday Cup Data'};
      app.UseTorroidDataSwitch.ItemsData = {'T', 'F'};
      app.UseTorroidDataSwitch.ValueChangedFcn = createCallbackFcn(app, @UseTorroidDataSwitchValueChanged, true);
      app.UseTorroidDataSwitch.Position = [432 127 20 45];
      app.UseTorroidDataSwitch.Value = 'F';

      % Create UseLaserDataSwitch
      app.UseLaserDataSwitch = uiswitch(app.QEMapTab, 'rocker');
      app.UseLaserDataSwitch.Items = {'Use Img Intensity Data', 'User Laser Energy Data'};
      app.UseLaserDataSwitch.ItemsData = {'I', 'L'};
      app.UseLaserDataSwitch.ValueChangedFcn = createCallbackFcn(app, @UseLaserDataSwitchValueChanged, true);
      app.UseLaserDataSwitch.Position = [285 128 20 45];
      app.UseLaserDataSwitch.Value = 'L';

      % Create ResettoStandbyButton_2
      app.ResettoStandbyButton_2 = uibutton(app.QEMapTab, 'push');
      app.ResettoStandbyButton_2.ButtonPushedFcn = createCallbackFcn(app, @ResettoStandbyButton_2Pushed, true);
      app.ResettoStandbyButton_2.BackgroundColor = [0.9294 0.6941 0.1255];
      app.ResettoStandbyButton_2.FontWeight = 'bold';
      app.ResettoStandbyButton_2.Position = [377.5 54 114 44];
      app.ResettoStandbyButton_2.Text = 'Reset to Standby';

      % Create VCCImagePanel
      app.VCCImagePanel = uipanel(app.FACETIICathodeServicesUIFigure);
      app.VCCImagePanel.Title = 'VCC Image';
      app.VCCImagePanel.Position = [524 15 712 676];

      % Create UIAxes
      app.UIAxes = uiaxes(app.VCCImagePanel);
      title(app.UIAxes, '')
      xlabel(app.UIAxes, 'X')
      ylabel(app.UIAxes, 'Y')
      app.UIAxes.PlotBoxAspectRatio = [1.37445887445887 1 1];
      app.UIAxes.Position = [12 91 684 560];

      % Create GrabFrameButton
      app.GrabFrameButton = uibutton(app.VCCImagePanel, 'push');
      app.GrabFrameButton.ButtonPushedFcn = createCallbackFcn(app, @GrabFrameButtonPushed, true);
      app.GrabFrameButton.Position = [12 10 81 49];
      app.GrabFrameButton.Text = 'Grab Frame';

      % Create ControlsButton_5
      app.ControlsButton_5 = uibutton(app.VCCImagePanel, 'push');
      app.ControlsButton_5.ButtonPushedFcn = createCallbackFcn(app, @ControlsButton_5Pushed, true);
      app.ControlsButton_5.Position = [273 10 70 49];
      app.ControlsButton_5.Text = 'Controls';

      % Create StreamImageButton
      app.StreamImageButton = uibutton(app.VCCImagePanel, 'state');
      app.StreamImageButton.ValueChangedFcn = createCallbackFcn(app, @StreamImageButtonValueChanged, true);
      app.StreamImageButton.Text = 'Stream Image';
      app.StreamImageButton.Position = [97 10 97 49];

      % Create BufferedDataAcquisitionButton
      app.BufferedDataAcquisitionButton = uibutton(app.VCCImagePanel, 'state');
      app.BufferedDataAcquisitionButton.ValueChangedFcn = createCallbackFcn(app, @BufferedDataAcquisitionButtonValueChanged, true);
      app.BufferedDataAcquisitionButton.Text = 'Buffered Data Acquisition';
      app.BufferedDataAcquisitionButton.Position = [346 10 152 49];

      % Create DetachButton
      app.DetachButton = uibutton(app.VCCImagePanel, 'state');
      app.DetachButton.Icon = 'detachicon.jpg';
      app.DetachButton.Text = '';
      app.DetachButton.Position = [198 10 71 49];

      % Create BackgroundPanel
      app.BackgroundPanel = uipanel(app.VCCImagePanel);
      app.BackgroundPanel.TitlePosition = 'centertop';
      app.BackgroundPanel.Title = 'Background';
      app.BackgroundPanel.Position = [501 10 199 70];

      % Create SubtractCheckBox
      app.SubtractCheckBox = uicheckbox(app.BackgroundPanel);
      app.SubtractCheckBox.ValueChangedFcn = createCallbackFcn(app, @SubtractCheckBoxValueChanged, true);
      app.SubtractCheckBox.Text = 'Subtract';
      app.SubtractCheckBox.Position = [6 26 67 22];

      % Create ValidLabel
      app.ValidLabel = uilabel(app.BackgroundPanel);
      app.ValidLabel.HorizontalAlignment = 'right';
      app.ValidLabel.Position = [3 4 35 22];
      app.ValidLabel.Text = 'Valid ';

      % Create ValidLamp
      app.ValidLamp = uilamp(app.BackgroundPanel);
      app.ValidLamp.Position = [42 4 20 20];

      % Create TakeNewButton
      app.TakeNewButton = uibutton(app.BackgroundPanel, 'push');
      app.TakeNewButton.ButtonPushedFcn = createCallbackFcn(app, @TakeNewButtonPushed, true);
      app.TakeNewButton.Position = [82 27 111 22];
      app.TakeNewButton.Text = 'Take New';

      % Create N_aveEditFieldLabel
      app.N_aveEditFieldLabel = uilabel(app.BackgroundPanel);
      app.N_aveEditFieldLabel.HorizontalAlignment = 'right';
      app.N_aveEditFieldLabel.Position = [106 3 44 22];
      app.N_aveEditFieldLabel.Text = 'N_ave:';

      % Create N_aveEditField
      app.N_aveEditField = uieditfield(app.BackgroundPanel, 'numeric');
      app.N_aveEditField.Limits = [1 999];
      app.N_aveEditField.RoundFractionalValues = 'on';
      app.N_aveEditField.ValueDisplayFormat = '%d';
      app.N_aveEditField.Position = [157 3 36 22];
      app.N_aveEditField.Value = 10;

      % Create GunVacuumPanel
      app.GunVacuumPanel = uipanel(app.FACETIICathodeServicesUIFigure);
      app.GunVacuumPanel.TitlePosition = 'centertop';
      app.GunVacuumPanel.Title = 'Gun Vacuum';
      app.GunVacuumPanel.Position = [6 16 100 252];

      % Create GunVacuumGauge
      app.GunVacuumGauge = uigauge(app.GunVacuumPanel, 'linear');
      app.GunVacuumGauge.Limits = [0 10];
      app.GunVacuumGauge.Orientation = 'vertical';
      app.GunVacuumGauge.ScaleColors = [1 0 0;0 1 0;1 0 0];
      app.GunVacuumGauge.ScaleColorLimits = [0 2;2 8;8 10];
      app.GunVacuumGauge.Position = [21 48 59 155];

      % Create EditField_2
      app.EditField_2 = uieditfield(app.GunVacuumPanel, 'numeric');
      app.EditField_2.ValueChangedFcn = createCallbackFcn(app, @EditField_2ValueChanged, true);
      app.EditField_2.Editable = 'off';
      app.EditField_2.FontColor = [1 1 1];
      app.EditField_2.BackgroundColor = [0 0 0];
      app.EditField_2.Position = [16 15 67 22];

      % Create nTorrLabel
      app.nTorrLabel = uilabel(app.GunVacuumPanel);
      app.nTorrLabel.Position = [34 205 33 22];
      app.nTorrLabel.Text = 'nTorr';

      % Create LaserEnergyPanel
      app.LaserEnergyPanel = uipanel(app.FACETIICathodeServicesUIFigure);
      app.LaserEnergyPanel.TitlePosition = 'centertop';
      app.LaserEnergyPanel.Title = 'Laser Energy';
      app.LaserEnergyPanel.Position = [210 16 100 252];

      % Create LaserEnergyGauge
      app.LaserEnergyGauge = uigauge(app.LaserEnergyPanel, 'linear');
      app.LaserEnergyGauge.Limits = [0 30];
      app.LaserEnergyGauge.Orientation = 'vertical';
      app.LaserEnergyGauge.Position = [25 64 53 134];

      % Create EditField_3
      app.EditField_3 = uieditfield(app.LaserEnergyPanel, 'numeric');
      app.EditField_3.Editable = 'off';
      app.EditField_3.FontColor = [1 1 1];
      app.EditField_3.BackgroundColor = [0 0 0];
      app.EditField_3.Position = [12 36 79 22];

      % Create ControlsButton_3
      app.ControlsButton_3 = uibutton(app.LaserEnergyPanel, 'push');
      app.ControlsButton_3.ButtonPushedFcn = createCallbackFcn(app, @ControlsButton_3Pushed, true);
      app.ControlsButton_3.Position = [11 9 81 21];
      app.ControlsButton_3.Text = 'Controls';

      % Create uJLabel
      app.uJLabel = uilabel(app.LaserEnergyPanel);
      app.uJLabel.Position = [43 203 25 22];
      app.uJLabel.Text = 'uJ';

      % Create ShutterPanel
      app.ShutterPanel = uipanel(app.FACETIICathodeServicesUIFigure);
      app.ShutterPanel.TitlePosition = 'centertop';
      app.ShutterPanel.Title = ' Shutter';
      app.ShutterPanel.Position = [457 16 60 252];

      % Create STATUSLamp
      app.STATUSLamp = uilamp(app.ShutterPanel);
      app.STATUSLamp.Position = [20 201 20 20];

      % Create CLOSESwitch
      app.CLOSESwitch = uiswitch(app.ShutterPanel, 'toggle');
      app.CLOSESwitch.Items = {'Open', 'Close'};
      app.CLOSESwitch.ItemsData = {'Yes', 'No'};
      app.CLOSESwitch.Position = [10 78 41 92];
      app.CLOSESwitch.Value = 'No';

      % Create STATUSLampOPEN
      app.STATUSLampOPEN = uilamp(app.ShutterPanel);
      app.STATUSLampOPEN.Position = [21 23 20 20];
      app.STATUSLampOPEN.Color = [1 0 0];

      % Create EPICSWatchdogPanel
      app.EPICSWatchdogPanel = uipanel(app.FACETIICathodeServicesUIFigure);
      app.EPICSWatchdogPanel.Title = 'EPICS Watchdog';
      app.EPICSWatchdogPanel.Position = [1240 454 149 57];

      % Create RunningLampLabel
      app.RunningLampLabel = uilabel(app.EPICSWatchdogPanel);
      app.RunningLampLabel.HorizontalAlignment = 'right';
      app.RunningLampLabel.Position = [14 10 57 22];
      app.RunningLampLabel.Text = 'Running?';

      % Create RunningLamp
      app.RunningLamp = uilamp(app.EPICSWatchdogPanel);
      app.RunningLamp.Position = [86 10 20 20];

      % Create ToroidpCPanel
      app.ToroidpCPanel = uipanel(app.FACETIICathodeServicesUIFigure);
      app.ToroidpCPanel.Title = 'Toroid (pC)';
      app.ToroidpCPanel.Position = [1394 396 169 115];

      % Create Gauge
      app.Gauge = uigauge(app.ToroidpCPanel, 'linear');
      app.Gauge.Position = [17 40 119 40];

      % Create EditField_6
      app.EditField_6 = uieditfield(app.ToroidpCPanel, 'numeric');
      app.EditField_6.Editable = 'off';
      app.EditField_6.FontColor = [1 1 1];
      app.EditField_6.BackgroundColor = [0 0 0];
      app.EditField_6.Position = [22 11 109 22];

      % Create FaradayCuppCPanel
      app.FaradayCuppCPanel = uipanel(app.FACETIICathodeServicesUIFigure);
      app.FaradayCuppCPanel.Title = 'Faraday Cup (pC)';
      app.FaradayCuppCPanel.Position = [1394 267 169 126];

      % Create Gauge_2
      app.Gauge_2 = uigauge(app.FaradayCuppCPanel, 'linear');
      app.Gauge_2.Position = [6 34 153 37];

      % Create ControlsButton
      app.ControlsButton = uibutton(app.FaradayCuppCPanel, 'push');
      app.ControlsButton.ButtonPushedFcn = createCallbackFcn(app, @ControlsButtonPushed, true);
      app.ControlsButton.Position = [12 78 110 21];
      app.ControlsButton.Text = 'Controls';

      % Create Lamp
      app.Lamp = uilamp(app.FaradayCuppCPanel);
      app.Lamp.Position = [133 79 20 20];

      % Create EditField_5
      app.EditField_5 = uieditfield(app.FaradayCuppCPanel, 'numeric');
      app.EditField_5.Editable = 'off';
      app.EditField_5.FontColor = [1 1 1];
      app.EditField_5.BackgroundColor = [0 0 0];
      app.EditField_5.Position = [25 6 109 22];

      % Create LaserPositionmmPanel
      app.LaserPositionmmPanel = uipanel(app.FACETIICathodeServicesUIFigure);
      app.LaserPositionmmPanel.Title = 'Laser Position [mm]';
      app.LaserPositionmmPanel.Position = [1240 517 323 174];

      % Create OpenMotionControlButton
      app.OpenMotionControlButton = uibutton(app.LaserPositionmmPanel, 'push');
      app.OpenMotionControlButton.ButtonPushedFcn = createCallbackFcn(app, @OpenMotionControlButtonPushed, true);
      app.OpenMotionControlButton.Position = [18 7 173 21];
      app.OpenMotionControlButton.Text = 'Open Motion Control';

      % Create InrangeLampLabel
      app.InrangeLampLabel = uilabel(app.LaserPositionmmPanel);
      app.InrangeLampLabel.HorizontalAlignment = 'right';
      app.InrangeLampLabel.Position = [7 127 50 22];
      app.InrangeLampLabel.Text = 'In range';

      % Create InrangeLamp
      app.InrangeLamp = uilamp(app.LaserPositionmmPanel);
      app.InrangeLamp.Position = [72 127 20 20];

      % Create XmotLabel
      app.XmotLabel = uilabel(app.LaserPositionmmPanel);
      app.XmotLabel.Position = [22 67 52 22];
      app.XmotLabel.Text = 'X (mot):';

      % Create YmotLabel
      app.YmotLabel = uilabel(app.LaserPositionmmPanel);
      app.YmotLabel.Position = [168 67 52 22];
      app.YmotLabel.Text = 'Y (mot):';

      % Create EditField_7
      app.EditField_7 = uieditfield(app.LaserPositionmmPanel, 'numeric');
      app.EditField_7.Editable = 'off';
      app.EditField_7.HorizontalAlignment = 'center';
      app.EditField_7.FontColor = [1 1 1];
      app.EditField_7.BackgroundColor = [0 0 0];
      app.EditField_7.Position = [73 67 80 22];

      % Create EditField_8
      app.EditField_8 = uieditfield(app.LaserPositionmmPanel, 'numeric');
      app.EditField_8.Editable = 'off';
      app.EditField_8.HorizontalAlignment = 'center';
      app.EditField_8.FontColor = [1 1 1];
      app.EditField_8.BackgroundColor = [0 0 0];
      app.EditField_8.Position = [219 67 80 22];

      % Create XimgLabel
      app.XimgLabel = uilabel(app.LaserPositionmmPanel);
      app.XimgLabel.Position = [22 99 47 22];
      app.XimgLabel.Text = 'X (img):';

      % Create YimgLabel
      app.YimgLabel = uilabel(app.LaserPositionmmPanel);
      app.YimgLabel.Position = [168 99 47 22];
      app.YimgLabel.Text = 'Y (img):';

      % Create EditField_11
      app.EditField_11 = uieditfield(app.LaserPositionmmPanel, 'numeric');
      app.EditField_11.Editable = 'off';
      app.EditField_11.HorizontalAlignment = 'center';
      app.EditField_11.FontColor = [1 1 1];
      app.EditField_11.BackgroundColor = [0 0 0];
      app.EditField_11.Position = [73 99 80 22];

      % Create EditField_12
      app.EditField_12 = uieditfield(app.LaserPositionmmPanel, 'numeric');
      app.EditField_12.Editable = 'off';
      app.EditField_12.HorizontalAlignment = 'center';
      app.EditField_12.FontColor = [1 1 1];
      app.EditField_12.BackgroundColor = [0 0 0];
      app.EditField_12.Position = [219 99 80 22];

      % Create InmotionLampLabel
      app.InmotionLampLabel = uilabel(app.LaserPositionmmPanel);
      app.InmotionLampLabel.HorizontalAlignment = 'right';
      app.InmotionLampLabel.Position = [214 127 55 22];
      app.InmotionLampLabel.Text = 'In motion';

      % Create InmotionLamp
      app.InmotionLamp = uilamp(app.LaserPositionmmPanel);
      app.InmotionLamp.Position = [284 127 20 20];
      app.InmotionLamp.Color = [1 0 0];

      % Create HomeVELOmmsEditFieldLabel
      app.HomeVELOmmsEditFieldLabel = uilabel(app.LaserPositionmmPanel);
      app.HomeVELOmmsEditFieldLabel.HorizontalAlignment = 'right';
      app.HomeVELOmmsEditFieldLabel.Position = [18 35 112 22];
      app.HomeVELOmmsEditFieldLabel.Text = 'Home VELO [mm/s]';

      % Create HomeVELOmmsEditField
      app.HomeVELOmmsEditField = uieditfield(app.LaserPositionmmPanel, 'numeric');
      app.HomeVELOmmsEditField.ValueChangedFcn = createCallbackFcn(app, @HomeVELOmmsEditFieldValueChanged, true);
      app.HomeVELOmmsEditField.Position = [137 35 53 22];
      app.HomeVELOmmsEditField.Value = 2;

      % Create MoveHome
      app.MoveHome = uibutton(app.LaserPositionmmPanel, 'push');
      app.MoveHome.ButtonPushedFcn = createCallbackFcn(app, @MoveHomeButtonPushed, true);
      app.MoveHome.Icon = 'home.svg';
      app.MoveHome.Tooltip = {'laser spot to cleaning cente'};
      app.MoveHome.Position = [242 22 30 28];
      app.MoveHome.Text = '';

      % Create MoveStop
      app.MoveStop = uibutton(app.LaserPositionmmPanel, 'push');
      app.MoveStop.ButtonPushedFcn = createCallbackFcn(app, @MoveStopButtonPushed, true);
      app.MoveStop.Icon = 'stop.svg';
      app.MoveStop.Tooltip = {'Stop all motors'};
      app.MoveStop.Position = [279 22 32 28];
      app.MoveStop.Text = '';

      % Create CalMotor
      app.CalMotor = uibutton(app.LaserPositionmmPanel, 'push');
      app.CalMotor.ButtonPushedFcn = createCallbackFcn(app, @CalMotorButtonPushed, true);
      app.CalMotor.Icon = 'calibration-mark.svg';
      app.CalMotor.Tooltip = {'Center readback on laser spot image'};
      app.CalMotor.Position = [205 22 30 28];
      app.CalMotor.Text = '';

      % Create ImageIntensityPanel
      app.ImageIntensityPanel = uipanel(app.FACETIICathodeServicesUIFigure);
      app.ImageIntensityPanel.TitlePosition = 'centertop';
      app.ImageIntensityPanel.Title = 'Image Intensity';
      app.ImageIntensityPanel.Position = [108 16 100 252];

      % Create ImageIntensityGauge
      app.ImageIntensityGauge = uigauge(app.ImageIntensityPanel, 'linear');
      app.ImageIntensityGauge.Limits = [0 30];
      app.ImageIntensityGauge.Orientation = 'vertical';
      app.ImageIntensityGauge.Position = [17 44 66 177];

      % Create EditField_4
      app.EditField_4 = uieditfield(app.ImageIntensityPanel, 'numeric');
      app.EditField_4.Editable = 'off';
      app.EditField_4.FontColor = [1 1 1];
      app.EditField_4.BackgroundColor = [0 0 0];
      app.EditField_4.Position = [9 11 82 22];

      % Create GunRFPanel
      app.GunRFPanel = uipanel(app.FACETIICathodeServicesUIFigure);
      app.GunRFPanel.Title = 'Gun RF';
      app.GunRFPanel.Position = [1240 168 149 81];

      % Create ModOFFLampLabel
      app.ModOFFLampLabel = uilabel(app.GunRFPanel);
      app.ModOFFLampLabel.HorizontalAlignment = 'right';
      app.ModOFFLampLabel.Position = [9 34 94 22];
      app.ModOFFLampLabel.Text = '10-2 Mod. OFF?';

      % Create ModOFFLamp
      app.ModOFFLamp = uilamp(app.GunRFPanel);
      app.ModOFFLamp.Position = [118 34 20 20];

      % Create ControlsButton_2
      app.ControlsButton_2 = uibutton(app.GunRFPanel, 'push');
      app.ControlsButton_2.ButtonPushedFcn = createCallbackFcn(app, @ControlsButton_2Pushed, true);
      app.ControlsButton_2.Position = [16 9 110 21];
      app.ControlsButton_2.Text = 'Controls';

      % Create CCDAcquireRateHzPanel
      app.CCDAcquireRateHzPanel = uipanel(app.FACETIICathodeServicesUIFigure);
      app.CCDAcquireRateHzPanel.Title = 'CCD Acquire Rate [Hz]';
      app.CCDAcquireRateHzPanel.Position = [1240 388 149 61];

      % Create EditField_13
      app.EditField_13 = uieditfield(app.CCDAcquireRateHzPanel, 'numeric');
      app.EditField_13.Editable = 'off';
      app.EditField_13.HorizontalAlignment = 'center';
      app.EditField_13.FontColor = [1 1 1];
      app.EditField_13.BackgroundColor = [0 0 0];
      app.EditField_13.Position = [20 11 106 22];

      % Create LaserSpotSizePanel
      app.LaserSpotSizePanel = uipanel(app.FACETIICathodeServicesUIFigure);
      app.LaserSpotSizePanel.TitlePosition = 'centertop';
      app.LaserSpotSizePanel.Title = 'Laser Spot Size';
      app.LaserSpotSizePanel.Position = [312 16 143 252];

      % Create LaserSpotSizeGaugeX
      app.LaserSpotSizeGaugeX = uigauge(app.LaserSpotSizePanel, 'linear');
      app.LaserSpotSizeGaugeX.Limits = [150 250];
      app.LaserSpotSizeGaugeX.Orientation = 'vertical';
      app.LaserSpotSizeGaugeX.Position = [9 44 53 153];
      app.LaserSpotSizeGaugeX.Value = 200;

      % Create LaserSpotSizeX
      app.LaserSpotSizeX = uieditfield(app.LaserSpotSizePanel, 'numeric');
      app.LaserSpotSizeX.Editable = 'off';
      app.LaserSpotSizeX.FontColor = [1 1 1];
      app.LaserSpotSizeX.BackgroundColor = [0 0 0];
      app.LaserSpotSizeX.Position = [9 11 55 22];

      % Create XumFWHMYLabel
      app.XumFWHMYLabel = uilabel(app.LaserSpotSizePanel);
      app.XumFWHMYLabel.Position = [24 203 91 22];
      app.XumFWHMYLabel.Text = 'X [um FWHM] Y';

      % Create LaserSpotSizeGaugeY
      app.LaserSpotSizeGaugeY = uigauge(app.LaserSpotSizePanel, 'linear');
      app.LaserSpotSizeGaugeY.Limits = [150 250];
      app.LaserSpotSizeGaugeY.Orientation = 'vertical';
      app.LaserSpotSizeGaugeY.Position = [77 44 53 153];
      app.LaserSpotSizeGaugeY.Value = 200;

      % Create LaserSpotSizeY
      app.LaserSpotSizeY = uieditfield(app.LaserSpotSizePanel, 'numeric');
      app.LaserSpotSizeY.Editable = 'off';
      app.LaserSpotSizeY.FontColor = [1 1 1];
      app.LaserSpotSizeY.BackgroundColor = [0 0 0];
      app.LaserSpotSizeY.Position = [76 11 55 22];

      % Create LaserTelescopeInsertedPanel
      app.LaserTelescopeInsertedPanel = uipanel(app.FACETIICathodeServicesUIFigure);
      app.LaserTelescopeInsertedPanel.Title = 'Laser Telescope Inserted?';
      app.LaserTelescopeInsertedPanel.Position = [1394 200 170 61];

      % Create SmallSpotEnabledLampLabel
      app.SmallSpotEnabledLampLabel = uilabel(app.LaserTelescopeInsertedPanel);
      app.SmallSpotEnabledLampLabel.HorizontalAlignment = 'right';
      app.SmallSpotEnabledLampLabel.Position = [11 11 111 22];
      app.SmallSpotEnabledLampLabel.Text = 'Small Spot Enabled';

      % Create SmallSpotEnabledLamp
      app.SmallSpotEnabledLamp = uilamp(app.LaserTelescopeInsertedPanel);
      app.SmallSpotEnabledLamp.Position = [137 11 20 20];

      % Create LaserFluenceuJmm2Panel
      app.LaserFluenceuJmm2Panel = uipanel(app.FACETIICathodeServicesUIFigure);
      app.LaserFluenceuJmm2Panel.Title = 'Laser Fluence [ uJ/mm^2 ]';
      app.LaserFluenceuJmm2Panel.Position = [1240 16 323 108];

      % Create Gauge_3
      app.Gauge_3 = uigauge(app.LaserFluenceuJmm2Panel, 'linear');
      app.Gauge_3.Position = [15 9 294 42];

      % Create EditField_17
      app.EditField_17 = uieditfield(app.LaserFluenceuJmm2Panel, 'numeric');
      app.EditField_17.ValueDisplayFormat = '%.1f';
      app.EditField_17.Editable = 'off';
      app.EditField_17.HorizontalAlignment = 'center';
      app.EditField_17.FontColor = [1 1 1];
      app.EditField_17.BackgroundColor = [0 0 0];
      app.EditField_17.Position = [105 57 106 22];

      % Create SoftwareRateHzPanel
      app.SoftwareRateHzPanel = uipanel(app.FACETIICathodeServicesUIFigure);
      app.SoftwareRateHzPanel.Title = 'Software Rate [Hz]';
      app.SoftwareRateHzPanel.Position = [1240 253 149 61];

      % Create EditField_15
      app.EditField_15 = uieditfield(app.SoftwareRateHzPanel, 'numeric');
      app.EditField_15.Editable = 'off';
      app.EditField_15.HorizontalAlignment = 'center';
      app.EditField_15.FontColor = [1 1 1];
      app.EditField_15.BackgroundColor = [0 0 0];
      app.EditField_15.Position = [20 11 106 22];

      % Create LaserRepRateHzPanel_2
      app.LaserRepRateHzPanel_2 = uipanel(app.FACETIICathodeServicesUIFigure);
      app.LaserRepRateHzPanel_2.Title = 'Laser Rep. Rate [Hz]';
      app.LaserRepRateHzPanel_2.Position = [1240 320 149 61];

      % Create EditField_16
      app.EditField_16 = uieditfield(app.LaserRepRateHzPanel_2, 'numeric');
      app.EditField_16.Limits = [0 120];
      app.EditField_16.ValueChangedFcn = createCallbackFcn(app, @EditField_16ValueChanged, true);
      app.EditField_16.HorizontalAlignment = 'center';
      app.EditField_16.Position = [18 10 108 22];
      app.EditField_16.Value = 30;

      % Create ValveVV155Panel
      app.ValveVV155Panel = uipanel(app.FACETIICathodeServicesUIFigure);
      app.ValveVV155Panel.Title = 'Valve VV155';
      app.ValveVV155Panel.Position = [1394 131 170 61];

      % Create OUTLampLabel
      app.OUTLampLabel = uilabel(app.ValveVV155Panel);
      app.OUTLampLabel.HorizontalAlignment = 'right';
      app.OUTLampLabel.Position = [5 11 38 22];
      app.OUTLampLabel.Text = 'OUT?';

      % Create VV155Lamp
      app.VV155Lamp = uilamp(app.ValveVV155Panel);
      app.VV155Lamp.Position = [58 11 20 20];

      % Create ControlButton
      app.ControlButton = uibutton(app.ValveVV155Panel, 'push');
      app.ControlButton.ButtonPushedFcn = createCallbackFcn(app, @ControlButtonPushed, true);
      app.ControlButton.Position = [89 9 70 22];
      app.ControlButton.Text = 'Control';

      % Create LaserAttFlipperINLampLabel
      app.LaserAttFlipperINLampLabel = uilabel(app.FACETIICathodeServicesUIFigure);
      app.LaserAttFlipperINLampLabel.HorizontalAlignment = 'right';
      app.LaserAttFlipperINLampLabel.Position = [1241 136 119 22];
      app.LaserAttFlipperINLampLabel.Text = 'Laser Att. Flipper IN?';

      % Create LaserAttFlipperINLamp
      app.LaserAttFlipperINLamp = uilamp(app.FACETIICathodeServicesUIFigure);
      app.LaserAttFlipperINLamp.Position = [1367 136 20 20];

      % Show the figure after all components are created
      app.FACETIICathodeServicesUIFigure.Visible = 'on';
    end
  end

  % App creation and deletion
  methods (Access = public)

    % Construct app
    function app = F2_CathodeServices_exported(varargin)

      % Create UIFigure and components
      createComponents(app)

      % Register the app with App Designer
      registerApp(app, app.FACETIICathodeServicesUIFigure)

      % Execute the startup function
      runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

      if nargout == 0
        clear app
      end
    end

    % Code that executes before app deletion
    function delete(app)

      % Delete UIFigure when app is deleted
      delete(app.FACETIICathodeServicesUIFigure)
    end
  end
end