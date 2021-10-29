classdef F2_CathodeServicesApp < handle & F2_common
  %F2_CATHODESERVICES Support functions for F2_CathodeServices.mlapp
  
  events
    PVUpdated % PV object list notifies this event after each set of monitored PVs have finished updating
  end
  properties(Dependent)
    CleaningNumLines % Number of lines to clean in defined cleaning region (vector of length CleaningNumCols if moving in x direction)
    CleaningNumCols % Number of columns per line to clean (vector of length CleaningNumLines if moving in y direction)
    CleaningTimeRemaining % Remaining cleaning time [min]
    MapNumLines % Number of lines to map in defined mapping region (vector of length MapNumCols if moving in x direction)
    MapNumCols % Number of columns per line to map (vector of length MapNumLines if moving in y direction)
    MapTimeRemaining % Remaining QE mapping time [min]
    MotorVelo % Required motor velocity based on current rep rate, CleaningStepSize and CleaningNumPulsesPerStep [mm/s]
    AcclDist % Distance required to move before full velocity achieved
    bonustime % Extra time to allow for edge-effects during cleaning (moving to correct location to start next line move)
  end
  properties(SetObservable)
    State CathodeServicesState = CathodeServicesState.Unknown
    buflen uint16 {mustBeGreaterThan(buflen,9)} = 500 % Data buffer length
    adistadd double {mustBeNonnegative} = 0.5 % Extra distance to add to allow motor to achieve full velocity (mm)
    imagemap string = "jet" % colormap to use for image
  end
  properties
    ctime = 30 % motor cooldown time [min]
    cmode logical = false % continuous mode for cleaning
    showimgstats logical = false % display Gaussian fit and stats on image
    takebkg logical = false % set true to take new backround image
    usebkg logical = false % Use stored image background and subtract from live stream
    nbkg uint8 {mustBePositive} = 10 % Number of consecutive image shots to use to average for background
    imgnormalize string = "LaserEnergy" % Use "CCD" or "LaserEnergy" to normalize image plot during cleaning
    orthcorrect logical = false % attempt to correct orthogobal backlash motion of mirrors
    RepRate uint8 = 30 % Firing rate of source laser [Hz]
    UseMirrPos logical = false % Use mirror position to determine where laser spot is, else use CCD image centroid
    MapCenter(1,2) single = [0,0] % center of QE mapping region (also motor "home" position when QE Map tab selected) [mm]
    MapRadius {mustBeLessThan(MapRadius,5e-3),mustBePositive} = 1.5e-3 % Radius on cathode to map [m]
    MapNumPulsesPerStep uint8 {mustBeLessThan(MapNumPulsesPerStep,100),mustBePositive}= 3 % Number of pulses between mapping step positions
    MapStepSize {mustBeLessThan(MapStepSize,300e-6),mustBePositive}= 80e-6 % Step size to use during QE mapping [m]
    MapStartPosition uint8 {mustBeMember(MapStartPosition,[1,2,3,4])} = 1 % Start position (1=bottom, 2=left, 3=top, 4=right)
    MapLineNum uint16 = 1 % Current line number for mapping process
    MapColNum uint16 = 1 % Current column number for mapping process
    CleaningCenter(1,2) single = [0,0] % center of cleaning area (also motor "home" position) [mm]
    CleaningRadius {mustBeLessThan(CleaningRadius,5e-3),mustBePositive} = 1.5e-3 % Radius on cathode to clean [m]
    CleaningNumPulsesPerStep uint8 {mustBeLessThan(CleaningNumPulsesPerStep,100),mustBePositive}= 3 % Number of pulses between cleaning step positions
    CleaningStepSize {mustBeLessThan(CleaningStepSize,300e-6),mustBePositive}= 40e-6 % Step size to use during laser cleaning [m]
    CheckRepVals logical = false % Perform check for past 10 PV values being the same in the watchdog timer?
    debug uint8 {mustBeMember(debug,[0,1,2])} = 2 % 0=live, 1=read only, 2=no connection
    gui; % ID for GUI (GUI launched by constructor)
    imudrate single {mustBePositive} = 30 % max image update rate [Hz]
    bufacq logical = false % Enable buffering of data 
    MotorVeloHome single = 2 % Home motor velocity [mm/s]
    CleaningStartPosition uint8 {mustBeMember(CleaningStartPosition,[1,2,3,4])} = 1 % Start position (1=bottom, 2=left, 3=top, 4=right)
    CleaningLineNum uint16 = 1 % Current line number for cleaning process
    CleaningColNum uint16 = 1 % Current column number for cleaning process
    imrot uint8 {mustBeMember(imrot,[0,1,2,3])} = 0 % Apply image rotation (in multiples of 90 degrees)
    imflipX logical = false % flip X axis after rotation ?
    imflipY logical = false % flip Y axis after rotation ?
    ImageCIntMax single {mustBePositive} = 50 % Abort if any pixel integrates to this times ImageIntensityRange(2)
    dnCMD logical = false % force drawnow command in main watchdog loop
    lmovadd = 1 % Add this move to line move commands [mm]
  end
  properties(SetAccess=private)
    VCC_mirrcal(1,4) single = [0,0,1,1] % Calibration mirror position to image position on VCC image [xpos,ypos,xscale,yscale] [mm]
    pvlist PV % Array of PV objects associated with this app
    pvs % Structure of PV arrays with PV names as structure field names
    CCD_rate uint8 = 30 % CCD acquire rate [Hz]
    STDOUT=1; % standard output destination
    STDERR=2; % standard error output destination
    ImageSource string = "VCC" % Source for displaying to axis ("VCC" or "REF")
    CCD_stream logical % streaming of CCD images?
    CCD_scale single {mustBePositive} = 9.9e-6 % m / pixel
    ImageIntensityRange(1,2) single {mustBeNonnegative} = [10 15000] % Allowable range for image intensity measurements, set using SetLimits method
    LaserSpotSizeRange(1,2) single {mustBeNonnegative} = [100 2000] % Allowable range for calculated laser spot size on CCD [um FWHM], set using SetLimits method
    LaserFluenceRange(1,2) single {mustBeNonnegative} = [0 20] % Allowable range for caculated laser fluence uJ/cm^2 [FWHM], set using SetLimits method
    GunVacuumRange(1,2) single {mustBeNonnegative} = [0.0001 10] % Allowable range for gun vacuum level [nTorr], set using SetLimits method
    LaserEnergyRange(1,2) single {mustBeNonnegative} = [0 150] % Allowable range for laser energy readbacks [uJ], set using SetLimits method
    GunVacuum single % Last read back gun vacuum level [Torr]
    ImageIntensity single % Last calculated image intensity from selected screen
    LaserEnergy single % Last read back laser energy from Joulemeter [uJ]
    LaserSpotSize(1,2) single % Last calculated laser spot size on CCD [um FWHM]
    LaserPosition_img(1,2) single % Last recorded laser position on screen [mm]
    LaserPosition_mot(1,2) single % Last indicted laser position based on mirror motors [mm]
    LaserPosition_tol single = 0.05 % Tolerance for laser being where it is supposed to be (distance from motor determined position) [mm], set using SetLimits method
    LaserFluence double = 0 % Laser fluence [uJ/mm^2] (FWHM)
    ScreenPosition(1,2) single % Indicated screen position [mm]
    LaserMotorStopped logical = true % Is motor in stopped state?
    wtimerKA % Watchdog keepalive timer
    poshistory single = nan(4,500,'single') % Buffered data for image position on camera
    ShutterCloseOveride logical = false % Force shutter to stay closed even when moving in auto pattern
    bkg uint16 % store background image used for subtraction
    validbkg logical = false % Is the background stored in memory compatible with current image?
  end
  properties(SetAccess=private,Hidden)
    stopping logical = false % flags when automatic pattern in process of stopping
    listeners
    stateListener
    moverListener
    buflenListener
    bufpos uint16 = 1
    pimg % integrated image filled during cleaning cycle
    pimg_ref
    qint_f % integrated faraday cup charge data
    qint_t % integrated torroid data
    lint % integrated laser energy data
    initvelo(1,2) = [4,4] % initial motor velocities in PVs at application startup (restored on shutdown) [mm/s]
    wd_running logical = false % true when watchdog method running
    wd_time(1,50) = nan(1,50)
    wd_time_noncleaning(1,50) = nan(1,50) ;
    wd_time_ind uint8 = 1
    wd_time_ind_noncleaning uint8 = 1
    CleaningSummaryData double
    cooldown ;
  end
  properties(Dependent,Hidden)
    wd_freq
    wd_freqerr
  end
  properties(Hidden)
    imupdate logical = false % force image update if true (set ==2 after loading an image into pimg property to display)
    CalibHan matlab.graphics.axis.Axes % handle to diagnostics window
  end
  properties(Constant,Hidden)
    std2fwhm=2*sqrt(2*log(2)) ; % conversion of gaussian width to FWHM
    motrbktol=0.04; % motor readback tolerance [mm] : regard readings within this tolerance band as equivalent
    motorsettings=[0.4,0.5,0.001,0.1,0.0124 ; 0.4, 0.5,0.001,0.1,0.01 ] ; % (all in local motor units) max speed, acceleration [for both backlash and normal] , base speed, backlash speed, backlash distance [X;Y]
    logfile='logs/F2_CathodeServicesApp'; % root filename to use for log
    camNames=["CAMR:LT10:900" "CTHD:IN10:111"]; % VCC,REF camera names
    version=1.0; % software version
    configprops=["CleaningCenter" "CleaningRadius" "CleaningNumPulsesPerStep" "CleaningStepSize" "CleaningStartPosition" "VCC_mirrcal" "ImageIntensityRange" "LaserSpotSizeRange" ...
      "LaserFluenceRange" "GunVacuumRange" "LaserEnergyRange" "version" "LaserPosition_tol" "MotorVeloHome" "buflen" "imrot" "imflipX" "imflipY"...
      "MapCenter" "MapRadius" "MapNumPulsesPerStep" "MapStepSize" "MapStartPosition" "RepRate" "orthcorrect" "adistadd" "imgnormalize" "bkg" ...
      "nbkg" "imagemap"]; % Properties to save/restore to/from configuration files
  end
  
  methods
    function obj=F2_CathodeServicesApp(debuglevel,guihan)
%       warning('off','MATLAB:nearlySingularMatrix');
      warning off
      
      % CS = F2_CathodeServices(debuglevel)
      if ~exist('debuglevel','var')
        error('Must provide debug level');
      end
      context = PV.Initialize(PVtype.EPICS) ;
%       context = PV.Initialize(PVtype.EPICS_labca) ;
%       cname = "PROF:IN10:241:" ;
      cname = "CAMR:LT10:900:" ;
      mname = ["MIRR:LT10:750:M3_MOTR_H" "MIRR:LT10:750:M3_MOTR_V"];
%       mname = ["MIRR:LT10:770:M2_MOTR_H" "MIRR:LT10:770:M2_MOTR_V"];
      obj.pvlist=[PV(context,'name',"gun_rfstate",'pvname',"KLYS:LI10:21:MOD:HVON_STATE",'monitor',true,'pvlogic','~'); % Gun rf on/off (10-2 modulator state)
        PV(context,'name',"CCD_img",'pvname',cname+"Image:ArrayData"); % CCD camera image
        PV(context,'name',"CCD_counter",'pvname',cname+"ArrayCounter_RBV",'monitor',true); % Image acquisition counter
%         PV(context,'name',"CCD_gain",'pvname',cname+"Gain",'monitor',true); % CCD camera image gain factor
%         PV(context,'name',"CCD_datatype",'pvname',cname+"DataType"); % CCD camera data type
        PV(context,'name',"CCD_nx",'pvname',cname+"ArraySizeX_RBV",'monitor',true); % # x-axis data points in CCD image
        PV(context,'name',"CCD_ny",'pvname',cname+"ArraySizeY_RBV",'monitor',true); % # y-axis data points in CCD image
        PV(context,'name',"CCD_xpos",'pvname',cname+"Stats:Xpos_RBV",'monitor',true,'conv',0.001); % xpos on CCD [mm]
        PV(context,'name',"CCD_ypos",'pvname',cname+"Stats:Ypos_RBV",'monitor',true,'conv',0.001); % ypos on CCD [mm]
        PV(context,'name',"CCD_xpos_out",'pvname',"SIOC:SYS1:ML00:AO358",'mode',"rw"); % Output of locally calculated X laser spot position [mm]
        PV(context,'name',"CCD_ypos_out",'pvname',"SIOC:SYS1:ML00:AO359",'mode',"rw"); % Output of locally calculated Y laser spot position [mm]
        PV(context,'name',"CCD_acq",'pvname',cname+"Acquire.RVAL",'monitor',true); % acquiring or not (readback)
        PV(context,'name',"CCD_acqset",'pvname',cname+"Acquire",'pvdatatype',java.lang.Integer(0).getClass); % acquiring or not (set)
        PV(context,'name',"CCD_acqmode",'pvname',cname+"ImageMode_RBV.RVAL",'monitor',true); % image mode (0=single, 2=continuous)
        PV(context,'name',"CCD_acqsetmode",'pvname',cname+"ImageMode",'pvdatatype',java.lang.Integer(0).getClass); % PV to use to set acquisition mode
        PV(context,'name','CCD_x1','pvname',cname+"ROI:MinX_mm_RBV",'monitor',true); % x1 [mm]
        PV(context,'name','CCD_y1','pvname',cname+"ROI:MinY_mm_RBV",'monitor',true); % y1 [mm]
        PV(context,'name','CCD_x2','pvname',cname+"ROI:MaxX_mm_RBV",'monitor',true); % x(end) [mm]
        PV(context,'name','CCD_y2','pvname',cname+"ROI:MaxY_mm_RBV",'monitor',true); % y(end) [mm]
        PV(context,'name',"CCD_spotsize",'pvname',cname+["Stats:SigmaX_mm_RBV" "Stats:SigmaY_mm_RBV"],'monitor',true,'conv',2*sqrt(2*log(2))); % Laser spot size (um FWHM)
        PV(context,'name',"CCD_xspotsize_out",'pvname',"SIOC:SYS1:ML00:AO348",'mode',"rw"); % Output of locally calculated X laser spot size (um FWHM)
        PV(context,'name',"CCD_yspotsize_out",'pvname',"SIOC:SYS1:ML00:AO349",'mode',"rw"); % Output of locally calculated Y laser spot size (um FWHM)
        PV(context,'name',"CCD_intensity",'pvname',cname+"Stats:MaxValue_RBV"); % intensity of laser spot on CCD - DON'T monitor this, use own calculation
        PV(context,'name',"CCD_intensity_out",'pvname',"SIOC:SYS1:ML00:AO360",'mode',"rw");
        PV(context,'name',"laser_shutterCtrl",'pvname',"IOC:SYS1:MP01:MSHUTCTL",'monitor',true,'pvlogic',"~"); % Laser MPS shutter control
        PV(context,'name',"laser_shutterStatIn",'pvname',"SHUT:LT10:950:IN_MPS.RVAL",'monitor',true); % Laser MPS shutter IN status
        PV(context,'name',"laser_shutterStatOut",'pvname',"SHUT:LT10:950:OUT_MPS.RVAL",'monitor',true); % Laser MPS shutter OUT status
        PV(context,'name',"watchdog_keepalive",'pvname',"IN10_CATHODESUPPORT:laserShutterOp",'pvdatatype',java.lang.Integer(0).getClass); % EPICS CathodeServices watchdog keepalive PV
        PV(context,'name',"watchdog_keepaliveval",'pvname',"IN10_CATHODESUPPORT:laserShutterOp.RVAL"); % EPICS CathodeServices watchdog keepalive PV value, should be 0 on application start otherwise another app running
        PV(context,'name',"watchdog_isalive",'pvname',"IN10_CATHODESUPPORT:HEARTBEAT",'monitor',true); % Counter which increments on each dbget
        PV(context,'name',"VV155_position",'pvname',"VVPG:IN10:155:POSITION",'monitor',true);
        PV(context,'name',"fcup_stat",'pvname',"FARC:IN10:241:PNEUMATIC",'monitor',true); % Faraday cup in/out status
        PV(context,'name',"fcup_val",'pvname',"SIOC:SYS1:ML00:AO850",'monitor',true); % Faraday cup reading
        PV(context,'name',"torr_val",'pvname',"TORR:IN10:1:VAL",'monitor',true); % Torroid charge reading
        PV(context,'name',"lsr_posx",'pvname',mname(1)+".RBV",'monitor',true,'conv',obj.VCC_mirrcal([3 1])); % X Position readback for laser based on motors [mm]
        PV(context,'name',"lsr_posy",'pvname',mname(2)+".RBV",'monitor',true,'conv',obj.VCC_mirrcal([4 2])); % Y Position readback for laser based on motors [mm]
        PV(context,'name',"lsr_xmov",'pvname',mname(1),'monitor',true,'mode','rw','conv',obj.VCC_mirrcal(3)); % X position move command for laser mirror [mm]
        PV(context,'name',"lsr_ymov",'pvname',mname(2),'monitor',true,'mode','rw','conv',obj.VCC_mirrcal(4)); % Y position move command for laser mirror [mm]
        PV(context,'name',"lsr_stopx",'pvname',mname(1)+".STOP",'mode','rw'); % stop X motion immediately
        PV(context,'name',"lsr_stopy",'pvname',mname(2)+".STOP",'mode','rw'); % stop y motion immediately
        PV(context,'name',"lsr_xvel",'pvname',mname(1)+".VELO",'mode',"rw",'putwait',true,'monitor',true,'conv',abs(obj.VCC_mirrcal(3))); % X mirror move velocity [mm/s]
        PV(context,'name',"lsr_yvel",'pvname',mname(2)+".VELO",'mode',"rw",'putwait',true,'monitor',true,'conv',abs(obj.VCC_mirrcal(4))); % X mirror move velocity [mm/s]
        PV(context,'name',"lsr_xaccl",'pvname',mname(1)+".ACCL",'monitor',true); % X mirror move acceleration [mm/s/s]
        PV(context,'name',"lsr_yaccl",'pvname',mname(2)+".ACCL",'monitor',true); % Y mirror move acceleration [mm/s/s]
        PV(context,'name',"lsr_xdir",'pvname',mname(1)+".CDIR"); % X mirror last move direction (1= +ve, 0=-ve)
        PV(context,'name',"lsr_ydir",'pvname',mname(2)+".CDIR"); % Y mirror last move direction (1= +ve, 0=-ve)
        PV(context,'name',"motx_maxvel",'pvname',mname(1)+".VMAX"); % max mirror motor velocity (Horizontal) (mm/s) - local motor units
        PV(context,'name',"moty_maxvel",'pvname',mname(2)+".VMAX"); % max mirror motor velocity (Vertical) - local motor units
        PV(context,'name',"motx_minvel",'pvname',mname(1)+".VBAS"); % base mirror motor velocity (Horizontal) (mm/s) - local motor units
        PV(context,'name',"moty_minvel",'pvname',mname(2)+".VBAS"); % base mirror motor velocity (Vertical) - local motor units
        PV(context,'name',"motx_accl",'pvname',mname(1)+".ACCL"); % horizontal mirror motor acceleration (s) - local motor units
        PV(context,'name',"moty_accl",'pvname',mname(2)+".ACCL"); % vertical mirror motor acceleration (s) - local motor units
        PV(context,'name',"motx_baccl",'pvname',mname(1)+".BACC"); % horizontal mirror motor backlash acceleration (s) - local motor units
        PV(context,'name',"moty_baccl",'pvname',mname(2)+".BACC"); % vertical mirror motor backlash acceleration (s) - local motor units
        PV(context,'name',"motx_bvelo",'pvname',mname(1)+".BVEL"); % horizontal mirror motor backlash velocity (mm/s) - local motor units
        PV(context,'name',"moty_bvelo",'pvname',mname(2)+".BVEL"); % vertical mirror motor backlash velocity (mm/s) - local motor units
        PV(context,'name',"motx_bdist",'pvname',mname(1)+".BDST"); % horizontal mirror motor backlash distance (mm) - local motor units
        PV(context,'name',"moty_bdist",'pvname',mname(2)+".BDST"); % vertical mirror motor backlash distance (mm) - local motor units
        PV(context,'name',"lsr_motion",'pvname',mname+".DMOV",'monitor',true,'pvlogic',"~&"); % Motion status for laser based on motors, true if in motion
        PV(context,'name',"laser_energy",'pvname',"IN10_CATHODESUPPORT:LaserPwrFiltered",'monitor',true); % Laser energy readout (uJ)
%         PV(context,'name',"laser_energy",'pvname',"LASR:LT10:930:PWR",'monitor',true); % Laser energy readout (uJ)
%         PV(context,'name',"laser_energy",'pvname',"PMTR:LT10:930:QUERYDATA",'monitor',true,'conv',25e6); % Laser energy readout (uJ) reads out 4% split of laser energy
        PV(context,'name',"gun_vacuum",'pvname',"VGCC:IN10:113:P",'monitor',true,'conv',1e9); % Vacuum pressire for gun [nTorr]
        PV(context,'name',"laser_telescope",'pvname',"SIOC:SYS1:ML00:CALC009",'monitor',true);
        PV(context,'name',"laser_shutter1",'pvname',"SHTR:LT10:250:PARM_SHUTTER_ENBL",'mode',"rw"); % Upstream laser shutter (blocks laser beam for background taking)
        PV(context,'name',"takebkg",'pvname',cname+"Proc:SaveBackground ",'mode',"rw"); % EPICS take CCD background command
        PV(context,'name',"ArrayRate",'pvname',cname+"ArrayRate_RBV",'monitor',true);
        PV(context,'name',"watchdog_gunvaclimitHI",'pvname',"IN10_CATHODESUPPORT:gunVacHi"); % PV used by EPICS watchdog for high gun vacuum limit
        PV(context,'name',"watchdog_laserlimitHI",'pvname',"IN10_CATHODESUPPORT:laserHi");
        PV(context,'name',"watchdog_gunvaclimitLO",'pvname',"IN10_CATHODESUPPORT:gunVacLo"); % PV used by EPICS watchdog for high gun vacuum limit
        PV(context,'name',"laser_flipper",'pvname',"MOTR:LT10:840:FLIPPER",'monitor',true); % State of attenuation flipper
        PV(context,'name',"watchdog_laserlimitLO",'pvname',"IN10_CATHODESUPPORT:laserLo")]; % PV used by EPICS watchdog for high laser energy limit
      pset(obj.pvlist,'debug',debuglevel) ;
      obj.pvs = struct(obj.pvlist) ;
      
      % if this isn't the main GUI linked object, done at this stage
      if ~exist('guihan','var')
        return
      end
      
      % Setup GUI field links to PVs
      obj.pvs.gun_rfstate.guihan = guihan.ModOFFLamp ;
%       obj.pvs.CCD_xpos.guihan = guihan.EditField_11 ;
%       obj.pvs.CCD_ypos.guihan = guihan.EditField_12 ;
      obj.pvs.CCD_intensity.guihan = [guihan.EditField_4,guihan.ImageIntensityGauge] ;
      obj.pvs.laser_shutterCtrl.guihan = guihan.CLOSESwitch ; SetMode(obj.pvs.laser_shutterCtrl,"rw"); obj.pvs.laser_shutterCtrl.putwait=true;
      obj.pvs.laser_shutterStatIn.guihan = guihan.STATUSLamp ;
      obj.pvs.laser_shutterStatOut.guihan = guihan.STATUSLampOPEN ;
      obj.pvs.fcup_stat.guihan = guihan.Lamp ;
      obj.pvs.fcup_val.guihan = guihan.EditField_5 ;
      obj.pvs.torr_val.guihan = guihan.EditField_6 ;
      obj.pvs.lsr_posx.guihan = guihan.EditField_7 ;
      obj.pvs.lsr_posy.guihan = guihan.EditField_8 ;
      obj.pvs.lsr_motion.guihan = guihan.InmotionLamp ;
      obj.pvs.laser_energy.guihan = [guihan.EditField_3,guihan.LaserEnergyGauge] ;
      obj.pvs.gun_vacuum.guihan = [guihan.EditField_2,guihan.GunVacuumGauge] ;
      obj.pvs.laser_telescope.guihan = guihan.SmallSpotEnabledLamp ;
      obj.pvs.ArrayRate.guihan = guihan.EditField_13 ;
      obj.pvs.torr_val.guihan = [guihan.EditField_6,guihan.Gauge] ;
      obj.pvs.fcup_val.guihan = [guihan.Gauge_2,guihan.EditField_5] ;
      obj.pvs.laser_flipper.guihan = guihan.LaserAttFlipperINLamp ; 
      obj.gui = guihan ;
      obj.debug = debuglevel ;
      
      % Enable alarm checking for critical PVs (alarm on MAJOR alarms)
      obj.pvs.laser_energy.alarm=1;
      obj.pvs.gun_vacuum.alarm=1;
      
      % There can only be a singleton instance of this running on the control system at one time
      % - use watchdog PV to detect running of another instance
      if caget(obj.pvs.watchdog_keepaliveval)==1
        fprintf(obj.STDERR,'ANOTHER INSTANCE OF F2_CATHODESERVICES  ALREADY RUNNING, ABORTING STARTUP!');
        waitfor(errordlg('ANOTHER INSTANCE OF F2_CATHODESERVICES  ALREADY RUNNING, ABORTING STARTUP!','Existing App Detected'));
        exit
      end
      
      % Set default limits in PV objects, and GUI objects
      obj.SetLimits("GunVacuumRange",obj.GunVacuumRange);
      obj.SetLimits("ImageIntensityRange",obj.ImageIntensityRange);
      obj.SetLimits("LaserEnergyRange",obj.LaserEnergyRange);
      obj.SetLimits("LaserSpotSizeRange",obj.LaserSpotSizeRange);
      obj.SetLimits("LaserPosition_tol",obj.LaserPosition_tol);
      obj.SetLimits("LaserFluenceRange",obj.LaserFluenceRange);
      obj.gui.StepSizeEditField.Value = double(obj.CleaningStepSize*1e6) ;
      obj.gui.PulsesateachpositionSpinner.Value = double(obj.CleaningNumPulsesPerStep) ;
      obj.gui.CleaningRadiusmmEditField.Value = double(obj.CleaningRadius*1e3) ;
      obj.gui.ccentEdit_x.Value = double(obj.CleaningCenter(1)) ;
      obj.gui.ccentEdit_y.Value = double(obj.CleaningCenter(2)) ;
      obj.gui.StartPositionKnob.Value = num2str(obj.CleaningStartPosition) ;
      obj.initvelo(1) = caget(obj.pvs.lsr_xvel) ;
      obj.initvelo(2) = caget(obj.pvs.lsr_yvel) ;
      obj.gui.HomeVELOmmsEditField.Value = double(obj.MotorVeloHome) ;
      
      % Set initial state
      % - write mirror motor settings
      caput(obj.pvs.motx_maxvel,obj.motorsettings(1,1)); caput(obj.pvs.moty_maxvel,obj.motorsettings(2,1));
      caput(obj.pvs.motx_accl,obj.motorsettings(1,2)); caput(obj.pvs.moty_accl,obj.motorsettings(2,2));
      caput(obj.pvs.motx_baccl,obj.motorsettings(1,2)); caput(obj.pvs.moty_baccl,obj.motorsettings(2,2));
      caput(obj.pvs.motx_minvel,obj.motorsettings(1,3)); caput(obj.pvs.moty_minvel,obj.motorsettings(2,3));
      caput(obj.pvs.motx_bvelo,obj.motorsettings(1,4)); caput(obj.pvs.moty_bvelo,obj.motorsettings(2,4));
      caput(obj.pvs.motx_bdist,obj.motorsettings(1,5)); caput(obj.pvs.moty_bdist,obj.motorsettings(2,5));
      caget(obj.pvlist);% fetch all values once
      if obj.pvs.laser_telescope.val{1}~=0
        obj.State=CathodeServicesState.Standby_cleaninglasermode;
      else
        obj.State=CathodeServicesState.Standby_opslasermode;
      end
      if obj.pvs.CCD_acqmode.val{1}==2 && obj.pvs.CCD_acq.val{1}>0
        guihan.StreamImageButton.Value=1;
      end
      obj.CCD_rate = caget(obj.pvs.ArrayRate) ;
      if obj.CCD_rate<1
        obj.CCD_rate = 1;
      end
      obj.pvlist.pset('timeout',0.01 + double(1/obj.CCD_rate));
      fprintf('Launch PV updater...\n');
      run(obj.pvlist,false,0.02,obj,'PVUpdated'); % polling time for PVs (set to faster than any expected laser firing rate)
      
      % Set initial motor settings to make sure they are good
      caput(obj.pvs.lsr_xaccl,1);
      caput(obj.pvs.lsr_yaccl,1);
      
      % Set PVs to autoupdate, PVUpdated event gets notified whenever one
      % of monitored PVs gets updated with a new value, which triggers
      % watchdog method
      obj.listeners = addlistener(obj,'PVUpdated',@(~,~) obj.watchdogUD) ; % causes watchdog method to be called when any PVs updated
      obj.stateListener = listener(obj,'State','PostSet',@(~,~) obj.ProcStateChange);
      obj.moverListener = addlistener(obj.pvs.lsr_motion,'PVStateChange',@(~,~) obj.ProcMirrorStateChange) ;
      obj.ProcMirrorStateChange(); % Initialize motion state readback
      obj.SetMirrCal(obj.VCC_mirrcal) ;
      obj.gui.BufferSizeMenu.Text = sprintf('Buffer Length = %d',obj.buflen) ;
      
      % Start logging
%       diary(sprintf('%s_%s.log',obj.logfile,datestr(now,30)));
      
      % Restore previous configuration settings
      fprintf('Restoring configuration settings...\n');
      try
        obj.LoadConfig;
      catch ME
        warning('No saved configuration file found, using program defaults');
        fprintf(obj.STDERR,'%s\n',ME.message);
      end
      disp('Returning from F2_CathodeServicesApp...');
      
      % Set background subtract option
      obj.gui.SubtractCheckBox.Value = obj.usebkg ;
      obj.gui.N_aveEditField.Value = double(obj.nbkg) ;
      
    end
    function ClearBuffer(obj)
      obj.poshistory = nan(4,obj.buflen,'single') ;
    end
    function ProcStateChange(obj)
      fprintf('%s: %s\n',datetime,obj.State);
    end
    function ProcMirrorStateChange(obj)
      val=caget(obj.pvs.lsr_motion);
      if val{1}==1 && val{2}==1
        obj.LaserMotorStopped=true;
      else
        obj.LaserMotorStopped=false;
      end
      if isautopattern(obj.State) && ~obj.LaserMotorStopped && ~obj.ShutterCloseOveride
        % DON'T DO THIS AS FINE-SCALE SEEKING BEHAVOR NEAR END MOVE POINT CAUSES FREQUENT SHUTTER COMMANDS
%         OpenShutterAndVerify(obj);
%         fprintf(obj.STDOUT,'%s: Mirror in motion: Opening Laser Shutter\n',datetime);
      elseif isautopattern(obj.State) && obj.LaserMotorStopped
        CloseShutterAndVerify(obj);
%         fprintf(obj.STDOUT,'%s: Mirror stopped moving: Closing Laser Shutter\n',datetime);
      end
    end
    function Proc_QEMap(obj,varargin)
      persistent mstate boundary whan xm ym shutoutpos
      %PROC_QEMAP Process next logical QE Mapping step
      %Proc_QEMap() 
      %Proc_QEMap("SetBoundary",[x0 y0 w h]) Set mapping boundary (Matlab rectangle function pos format with curvature=1)
      %Proc_QEMap("Stop")
      
      % Initialize state
      if isempty(mstate)
        mstate=0;
      end
      
      % Process boundary set command
      if nargin>1
        if varargin{1}=="SetBoundary"
          boundary=varargin{2};
          return
        elseif varargin{1}=="Stop"
          mstate=4;
          return
        end
      end
      
      % If laser motion currently in progress, update line/column number depending on movement direction, no further action required after this
      % Also, open shutter when in mapping zone defined by shutoutpos variable set in mstate 2
      if ~obj.LaserMotorStopped && mstate~=4
        if obj.State == CathodeServicesState.QEMap_linescan
          switch obj.MapStartPosition
            case {1,3} % horizontal moves
              xm_new = obj.LaserPosition_img(1) ; % current mirror command position
              if xm_new >= shutoutpos(1) && xm_new <= shutoutpos(2)
                OpenShutterAndVerify(obj);
              else
                CloseShutterAndVerify(obj);
              end
              nstep = ceil( abs(xm_new-xm) / (obj.MapStepSize*1e3) ) ;
              if nstep>obj.MapNumCols(obj.MapLineNum)
                obj.MapColNum = obj.MapNumCols(obj.MapLineNum) ;
              else
                obj.MapColNum = nstep ;
              end
            case {2,4} % vertical moves
              ym_new = obj.LaserPosition_img(2) ; % current mirror command position
              if ym_new >= shutoutpos(1) && ym_new <= shutoutpos(2)
                OpenShutterAndVerify(obj);
              else
                CloseShutterAndVerify(obj);
              end
              nstep = ceil( abs(ym_new-ym) / (obj.MapStepSize*1e3) ) ;
              if nstep>obj.MapNumLines(obj.MapColNum)
                obj.MapLineNum = obj.MapNumLines(obj.MapColNum) ;
              else
                obj.MapLineNum = nstep ;
              end
          end
        end
        return
      elseif ~obj.LaserMotorStopped
        return
      end
      
      switch mstate % take action based on current state
        case 0 % Start process actions
          % Telescope should be inserted (small spot size on cathode)
          if obj.pvs.laser_telescope.val{1}==0
            if isempty(whan) || ~ishandle(whan)
              whan=warndlg('Laser Telescope Optics not inserted, cannot start Mapping Sequence','Telescope not inserted');
            end
            return
          end

          % Need to have previously defined map program area
          if obj.State ~= CathodeServicesState.QEMap_definearea
            if isempty(whan) || ~ishandle(whan)
              whan=warndlg('Mapping area not yet defined, or different program in progress, stop any in-use program or use "Define Map Area" button first','Map Area Undefined');
            end
            return
          end
          
          % Boundary vector should be filled
          if isempty(boundary)
            if isempty(whan) || ~ishandle(whan)
              whan=warndlg('No area boundary defined, push "Define Map Area" button first','No map area boundary');
            end
            return
          end
          
          % If previous mapping attempt aborted, offer choice to re-start or start fresh
          if obj.MapColNum>1 || obj.MapLineNum>1
            resp = questdlg('Previous mapping program incomplete, continue previous or start new?','Restart Previous Program?','Continue Previous','Start New','Continue Previous');
            if strcmp(resp,'Start New')
              obj.MapColNum=1; obj.MapLineNum=1;
            end
          end

          % Make sure image streaming enabled and laser shutter initially closed
          obj.gui.StreamImageButton.Value = 1 ;
          obj.gui.StreamImageButton.ValueChangedFcn(obj.gui,obj.gui.StreamImageButton) ;
          if ~obj.CloseShutterAndVerify()
            return
          end
          if obj.MapColNum>1 || obj.MapLineNum>1
            mstate = 3 ;
          else
            mstate = 1 ;
          end
          obj.State = CathodeServicesState.QEMap_movingtonewline ; % watchdog method will repeatedly call this function until aborted
          fprintf(obj.STDOUT,'%s: QE Mapping: start\n',datetime);
        case 1 % move to start position
          obj.ShutterCloseOveride = true ; % don't open shutter until on auto pattern path
          obj.State = CathodeServicesState.QEMap_movingtonewline ;
          adist = obj.AcclDist ; % distance to accelerate to full velocity [mm]
          switch obj.MapStartPosition
            case 1 % bottom
              crdlen=double(obj.MapNumCols(obj.MapLineNum))*obj.MapStepSize*1e3; % length of circle cord at this vertical position
              dest = [boundary(1)+boundary(3)/2-crdlen/2-adist(1) boundary(2)] ;
            case 2 % left
              crdlen=double(obj.MapNumLines(obj.MapColNum))*obj.MapStepSize*1e3; % length of circle cord at this horizontal position
              dest = [boundary(1) boundary(2)+boundary(4)/2-crdlen/2-adist(2)] ;
            case 3 % top
              crdlen=double(obj.MapNumCols(obj.MapLineNum))*obj.MapStepSize*1e3; % length of circle cord at this vertical position
              dest = [boundary(1)+boundary(3)/2-crdlen/2-adist(1) boundary(2)+boundary(4)] ;
            case 4 % right
              crdlen=double(obj.MapNumLines(obj.MapColNum))*obj.MapStepSize*1e3; % length of circle cord at this horizontal position
              dest = [boundary(1)+boundary(3) boundary(2)+boundary(4)/2-crdlen/2-adist(2)] ;
          end
          xlim=[obj.pvs.CCD_x1.val{1} obj.pvs.CCD_x2.val{1}].*1e-3; ylim=[obj.pvs.CCD_y1.val{1} obj.pvs.CCD_y2.val{1}].*1e-3;
          if dest(1)<xlim(1)
            dest(1)=xlim(1);
          elseif dest(1)>xlim(2)
            dest(1)=xlim(2);
          end
          if dest(2)<ylim(1)
            dest(2)=ylim(1);
          elseif dest(2)>ylim(2)
            dest(2)=ylim(2);
          end
          reqmove = dest - obj.LaserPosition_img ;
          if any(abs(reqmove)>obj.motrbktol)
            obj.movemirror(reqmove,"fast");
          else % done with this move
            mstate = 2 ;
          end
          obj.ClearPIMG; % clear integrated image
          fprintf(obj.STDOUT,'%s: QE Map: move to start position\n',datetime);
        case 2 % Move along next line or column
          obj.ShutterCloseOveride = true ; % Automatically opens shutter when over map area (starts just outside)
          obj.State = CathodeServicesState.QEMap_linescan ;
          xm = obj.LaserPosition_img(1) ;
          ym = obj.LaserPosition_img(2) ; % current mirror command position
          adist = obj.AcclDist ; % distance to accelerate to full velocity [mm]
          switch obj.MapStartPosition
            case {1,3} % horizontal moves
              crdlen=double(obj.MapNumCols(obj.MapLineNum))*obj.MapStepSize*1e3; % length of circle cord at this vertical position
              if xm<(boundary(1)+boundary(3)/2) % move in +ve x direction
                reqmove = [crdlen+2*adist(1) 0] ;
                shutoutpos = [xm+adist(1) xm+crdlen+adist(1)] ; % x coordinates to open laser shutter
              else % move in -ve x direction
                reqmove = [-crdlen-2*adist(1) 0] ;
                shutoutpos = [xm-crdlen-adist(1) xm-adist(1)] ; % x coordinates to open laser shutter
              end
              fprintf(obj.STDOUT,'%s: QE Map: line # %d (of %d)\n',datetime,obj.MapLineNum,obj.MapNumLines);
              if obj.MapLineNum == obj.MapNumLines
                mstate = 4 ; % done
                obj.MapColNum = 1 ; obj.MapLineNum = 1 ;
              else
                obj.MapLineNum = obj.MapLineNum + 1 ;
                mstate = 3 ; % move to next line when move finished
              end
            case {2,4} % vertical moves
              crdlen=double(obj.MapNumLines(obj.MapColNum))*obj.MapStepSize*1e3; % length of circle cord at this horizontal position
              if ym<(boundary(2)+boundary(4)/2) % move in +ve y direction
                reqmove = [0 crdlen+2*adist(2)] ;
                shutoutpos = [ym+adist(2) ym+crdlen+adist(2)] ; % x coordinates to open laser shutter
              else % move in -ve y direction
                reqmove = [0 -crdlen-2*adist(2)] ;
                shutoutpos = [ym-crdlen-adist(2) ym-adist(2)] ; % x coordinates to open laser shutter
              end
              fprintf(obj.STDOUT,'%s: QE Map: column # %d (of %d)\n',datetime,obj.MapColNum,obj.MapNumCols);
              if obj.MapColNum == obj.MapNumCols
                mstate = 4 ; % done
                obj.MapColNum = 1 ; obj.MapLineNum = 1 ;
              else
                obj.MapColNum = obj.MapColNum + 1 ;
                mstate = 3 ; % move to next line when move finished
              end
          end
          obj.movemirror(reqmove);
        case 3 % Move to beginning of next line or column
          obj.State = CathodeServicesState.QEMap_movingtonewline ;
          obj.ShutterCloseOveride = true ;
          xm = obj.LaserPosition_img(1) ;
          ym = obj.LaserPosition_img(2) ; % current mirror command position
          adist = obj.AcclDist ; % distance to accelerate to full velocity [mm]
          switch obj.MapStartPosition
            case 1 % horizontal moves, starting from bottom
              crdlen=double(obj.MapNumCols(obj.MapLineNum))*obj.MapStepSize*1e3; % length of circle cord at this vertical position
              if xm<(boundary(1)+boundary(3)/2) % next move in +ve x direction
                dest = [boundary(1)+boundary(3)/2-crdlen/2-adist(1) boundary(2)+obj.MapStepSize*1e3*double(obj.MapLineNum-1)+(obj.MapStepSize/2)*1e3] ;
              else % next move in -ve x direction
                dest = [boundary(1)+boundary(3)/2+crdlen/2+adist(1) boundary(2)+obj.MapStepSize*1e3*double(obj.MapLineNum-1)+(obj.MapStepSize/2)*1e3] ;
              end
              fprintf(obj.STDOUT,'%s: QE Map: move to line # %d (of %d)\n',datetime,obj.MapLineNum,obj.MapNumLines);
            case 3
              % horizontal moves, starting from top
              crdlen=double(obj.MapNumCols(obj.MapLineNum))*obj.MapStepSize*1e3; % length of circle cord at this vertical position
              if xm<(boundary(1)+boundary(3)/2) % next move in +ve x direction
                dest = [boundary(1)+boundary(3)/2-crdlen/2-adist(1) boundary(2)+boundary(4)-obj.MapStepSize*1e3*double(obj.MapLineNum-1)-(obj.MapStepSize/2)*1e3] ;
              else % next move in -ve x direction
                dest = [boundary(1)+boundary(3)/2+crdlen/2+adist(1) boundary(2)+boundary(4)-obj.MapStepSize*1e3*double(obj.MapLineNum-1)-(obj.MapStepSize/2)*1e3] ;
              end
              fprintf(obj.STDOUT,'%s: QE Map: move to line # %d (of %d)\n',datetime,obj.MapLineNum,obj.MapNumLines);
            case 2 % vertical moves, starting on left
              crdlen=double(obj.MapNumLines(obj.MapColNum))*obj.MapStepSize*1e3; % length of circle cord at this horizontal position
              if ym<(boundary(2)+boundary(4)/2) % next move in +ve y direction
                dest = [boundary(1)+obj.MapStepSize*1e3*double(obj.MapColNum-1)+(obj.MapStepSize/2)*1e3 boundary(2)+boundary(4)/2-crdlen/2-adist(2)] ;
              else % next move in -ve y direction
                dest = [boundary(1)+obj.MapStepSize*1e3*double(obj.MapColNum-1)+(obj.MapStepSize/2)*1e3 boundary(2)+boundary(4)/2+crdlen/2+adist(2)] ;
              end
              fprintf(obj.STDOUT,'%s: QE Map: move to column # %d (of %d)\n',datetime,obj.MapColNum,obj.MapNumCols);
            case 4 % vertical moves, starting on right
              crdlen=double(obj.MapNumLines(obj.MapColNum))*obj.MapStepSize*1e3; % length of circle cord at this horizontal position
              if ym<(boundary(2)+boundary(4)/2) % next move in +ve y direction
                dest = [boundary(1)+boundary(3)-obj.MapStepSize*1e3*double(obj.MapColNum-1)-(obj.MapStepSize/2)*1e3 boundary(2)+boundary(4)/2-crdlen/2-adist(2)] ;
              else % next move in -ve y direction
                dest = [boundary(1)+boundary(3)-obj.MapStepSize*1e3*double(obj.MapColNum-1)-(obj.MapStepSize/2)*1e3 boundary(2)+boundary(4)/2+crdlen/2+adist(2)] ;
              end
              fprintf(obj.STDOUT,'%s: QE Map: move to column # %d (of %d)\n',datetime,obj.MapColNum,obj.MapNumCols);
          end
          xlim=[obj.pvs.CCD_x1.val{1} obj.pvs.CCD_x2.val{1}].*1e-3; ylim=[obj.pvs.CCD_y1.val{1} obj.pvs.CCD_y2.val{1}].*1e-3;
          if dest(1)<xlim(1)
            dest(1)=xlim(1);
          elseif dest(1)>xlim(2)
            dest(1)=xlim(2);
          end
          if dest(2)<ylim(1)
            dest(2)=ylim(1);
          elseif dest(2)>ylim(2)
            dest(2)=ylim(2);
          end
          reqmove = dest - obj.LaserPosition_img ;
          if any(abs(reqmove)>obj.motrbktol)
            obj.movemirror(reqmove);
          else % done with this move
            mstate = 2 ;
          end
        case 4 % QE Map complete, move back to center
          obj.stopping=true;
          obj.ShutterCloseOveride = true ;
          CloseShutterAndVerify(obj) ;
          if any( abs( obj.CleaningCenter - obj.LaserPosition_img ) > obj.motrbktol )
            obj.movemirror("home");
          else % done with this move
            mstate = 0 ;
            obj.State = CathodeServicesState.QEMap_definearea ;
            obj.ShutterCloseOveride = false ;
            obj.stopping=false;
          end
          fprintf(obj.STDOUT,'%s: QE Map: finishing\n',datetime);
      end
    end
    function Proc_Cleaning(obj,varargin)
      persistent cstate boundary whan xm ym href vref movecount engage
      %PROC_CLEANING Process next logical cleaning step
      %Proc_Cleaning() 
      %Proc_Cleaning("SetBoundary",[x0 y0 w h]) Set cleaning pattern boundaries (Matlab rectangle function pos format with curvature=1)
      
      % Initialize state
      if isempty(cstate)
        cstate=0;
        engage=false;
      end
      movecount=0;
      
      % Process boundary set command
      if nargin>1
        if varargin{1}=="SetBoundary"
          boundary=varargin{2};
          return
        elseif varargin{1}=="Stop"
          cstate=4;
        end
      end
      
      % If laser motion currently in progress, update line/column number depending on movement direction, no further action required after this
      % Also, open shutter when in cleaning zone
      % Also, force trajectory to be on straight line during move
      shopen=false;
      if ~obj.LaserMotorStopped && cstate~=4
        if obj.State == CathodeServicesState.Cleaning_linescan
          r_new = sqrt(sum(abs(obj.LaserPosition_img - obj.CleaningCenter).^2)) ;
%           if r_new < obj.CleaningRadius*1e3
%             obj.CleaningSummaryData.counter = obj.CleaningSummaryData.counter+1;
%             obj.CleaningSummaryData.LaserEnergy(obj.CleaningSummaryData.counter) = obj.LaserEnergy ;
%             obj.CleaningSummaryData.LaserFluence(obj.CleaningSummaryData.counter) = obj.LaserFluence ;
%           end
          switch obj.CleaningStartPosition
            case {1,3} % horizontal moves
              xm_new = obj.LaserPosition_img(1) ; % current position
              if r_new < obj.CleaningRadius*1e3
                OpenShutterAndVerify(obj);
                shopen=true;
                engage=true;
              else
                CloseShutterAndVerify(obj);
                if engage
                  caput(obj.pvs.lsr_stopx,1); caput(obj.pvs.lsr_stopy,1);
                  engage=false;
                end
              end
              nstep = ceil( abs(xm_new-xm) / (obj.CleaningStepSize*1e3) ) ;
              if nstep>obj.CleaningNumCols(obj.CleaningLineNum)
                obj.CleaningColNum = obj.CleaningNumCols(obj.CleaningLineNum) ;
              else
                obj.CleaningColNum = nstep ;
              end
              % Force trajectory on vertical axis
              if ~isempty(vref) && obj.orthcorrect && ~shopen
                dy = vref - obj.LaserPosition_img(2) ;
%                 fprintf('dy= %g movecount= %d\n',dy,movecount);
                if abs(dy)>obj.motrbktol
                  mstopped=caget(obj.pvs.lsr_motion);
                  if mstopped{2}==1
                    caput(obj.pvs.lsr_yvel,obj.MotorVeloHome);
                    caput(obj.pvs.moty_bvelo,obj.MotorVeloHome/abs(obj.VCC_mirrcal(4)));
                    ymr = caget(obj.pvs.lsr_ymov) ;
                    caput(obj.pvs.lsr_ymov,ymr+dy/2);
                  end
                end
              end
            case {2,4} % vertical moves
              ym_new = obj.LaserPosition_img(2) ; % current position
              if r_new < obj.CleaningRadius*1e3
                OpenShutterAndVerify(obj);
                shopen=true;
                engage=true;
              else
                CloseShutterAndVerify(obj);
                if engage
                  caput(obj.pvs.lsr_stopx,1); caput(obj.pvs.lsr_stopy,1);
                  engage=false;
                end
              end
              nstep = ceil( abs(ym_new-ym) / (obj.CleaningStepSize*1e3) ) ;
              if nstep>obj.CleaningNumLines(obj.CleaningColNum)
                obj.CleaningLineNum = obj.CleaningNumLines(obj.CleaningColNum) ;
              else
                obj.CleaningLineNum = nstep ;
              end
              % Force trajectory on horizontal axis
              if ~isempty(href) && obj.orthcorrect && ~shopen
                dx = href - obj.LaserPosition_img(1) ;
                if abs(dx)>obj.motrbktol
                  mstopped=caget(obj.pvs.lsr_motion);
                  if mstopped{1}==1
                    caput(obj.pvs.lsr_xvel,obj.MotorVeloHome);
                    caput(obj.pvs.motx_bvelo,obj.MotorVeloHome/abs(obj.VCC_mirrcal(3)));
                    xmr = caget(obj.pvs.lsr_xmov) ;
                    caput(obj.pvs.lsr_xmov,xmr+dx/2);
                  end
                end
              end
          end
        end
        return
      elseif ~obj.LaserMotorStopped
        return
      end
      
      switch cstate % take action based on current state
        case 0 % Start process actions
          vref=[]; href=[]; movecount=0;
          obj.SaveConfig; % Save config settings in case of improper app shutdown during cleaning
          
          fprintf('Laser Cleaning Start: %s\n',datestr(now));
          
%           ndata = (obj.CleaningTimeRemaining-obj.bonustime) * 60 * obj.pvs.ArrayRate.val{1} ;
          % Initialize summary data
%           obj.CleaningSummaryData.counter=0;
%           obj.CleaningSummaryData.start = now;
%           obj.CleaningSummaryData.LaserEnergy = zeros(1,ndata,'like',obj.LaserEnergy);
%           obj.CleaningSummaryData.LaserFluence = zeros(1,ndata,'like',obj.LaserFluence);
          
          % Telescope should be inserted (small spot size on cathode)
          if obj.pvs.laser_telescope.val{1}==0
            if isempty(whan) || ~ishandle(whan)
              whan=warndlg('Laser Telescope Optics not inserted, cannot start Cleaning Sequence','Telescope not inserted');
            end
            return
          end

          % Need to have previously defined cleaning program area
          if obj.State ~= CathodeServicesState.Cleaning_definearea
            if isempty(whan) || ~ishandle(whan)
              whan=warndlg('Cleaning area not yet defined, or different program in progress, stop any in-use program or use "Define Cleaning Program Areas" button first','Cleaning Area Undefined');
            end
            return
          end
          
          % Boundary vector should be filled
          if isempty(boundary)
            if isempty(whan) || ~ishandle(whan)
              whan=warndlg('No area boundary defined, push "Define cleaning program areas" button first','No cleaning area boundary');
            end
            return
          end
          
          % If previous cleaning attempt aborted, offer choice to re-start or start fresh
          if obj.CleaningColNum>1 || obj.CleaningLineNum>1
            resp = questdlg('Previous Cleaning Program incomplete, continue previous or start new?','Restart Previous Program?','Continue Previous','Start New','Continue Previous');
            if strcmp(resp,'Start New')
              obj.CleaningColNum=1; obj.CleaningLineNum=1;
            end
          end

          % Make sure image streaming enabled and laser shutter initially closed
          obj.gui.StreamImageButton.Value = 1 ;
          obj.gui.StreamImageButton.ValueChangedFcn(obj.gui,obj.gui.StreamImageButton) ;
          if ~obj.CloseShutterAndVerify()
            return
          end
          if obj.CleaningColNum>1 || obj.CleaningLineNum>1
            cstate = 3 ;
          else
            cstate = 1 ;
          end
          obj.State = CathodeServicesState.Cleaning_movingtonewline ; % watchdog method will repeatedly call this function until aborted
          fprintf(obj.STDOUT,'%s: Cleaning: start\n',datetime);
        case 1 % move to start position
          vref=[]; href=[]; movecount=0;
          obj.ShutterCloseOveride = true ; % don't open shutter until on auto pattern path
          obj.State = CathodeServicesState.Cleaning_movingtonewline ;
          adist = obj.AcclDist ; % distance to accelerate to full velocity [mm]
          switch obj.CleaningStartPosition
            case 1 % bottom
              crdlen=double(obj.CleaningNumCols(obj.CleaningLineNum))*obj.CleaningStepSize*1e3; % length of circle cord at this vertical position
              dest = [boundary(1)+boundary(3)/2-crdlen/2-adist(1) boundary(2)] ;
            case 2 % left
              crdlen=double(obj.CleaningNumLines(obj.CleaningColNum))*obj.CleaningStepSize*1e3; % length of circle cord at this horizontal position
              dest = [boundary(1) boundary(2)+boundary(4)/2-crdlen/2-adist(2)] ;
            case 3 % top
              crdlen=double(obj.CleaningNumCols(obj.CleaningLineNum))*obj.CleaningStepSize*1e3; % length of circle cord at this vertical position
              dest = [boundary(1)+boundary(3)/2-crdlen/2-adist(1) boundary(2)+boundary(4)] ;
            case 4 % right
              crdlen=double(obj.CleaningNumLines(obj.CleaningColNum))*obj.CleaningStepSize*1e3; % length of circle cord at this horizontal position
              dest = [boundary(1)+boundary(3) boundary(2)+boundary(4)/2-crdlen/2-adist(2)] ;
          end
          xlim=[obj.pvs.CCD_x1.val{1} obj.pvs.CCD_x2.val{1}].*1e-3; ylim=[obj.pvs.CCD_y1.val{1} obj.pvs.CCD_y2.val{1}].*1e-3;
          if dest(1)<xlim(1)
            dest(1)=xlim(1);
          elseif dest(1)>xlim(2)
            dest(1)=xlim(2);
          end
          if dest(2)<ylim(1)
            dest(2)=ylim(1);
          elseif dest(2)>ylim(2)
            dest(2)=ylim(2);
          end
          posnow = obj.LaserPosition_img;
          reqmove = dest - posnow ;
          if obj.CleaningStartPosition==1 || obj.CleaningStartPosition==3 % loose start tol in scan direction
            pres=[obj.motrbktol*3 obj.motrbktol];
          else
            pres=[obj.motrbktol obj.motrbktol*3];
          end
          if any(abs(reqmove)>pres)
            obj.movemirror(reqmove,"fast");
          else % done with this move
            cstate = 2 ;
          end
          obj.ClearPIMG; % clear integrated image
          fprintf(obj.STDOUT,'%s: Cleaning: move to start position\n',datetime);
        case 2 % Move along next line or column
          obj.ShutterCloseOveride = true ; % Automatically opens shutter when over cleaning area (starts just outside)
          obj.State = CathodeServicesState.Cleaning_linescan ;
          xm = obj.LaserPosition_img(1) ;
          ym = obj.LaserPosition_img(2) ; % current position
          adist = obj.AcclDist ; % distance to accelerate to full velocity [mm]
          switch obj.CleaningStartPosition
            case {1,3} % horizontal moves
              href=[];
              vref=ym;
              crdlen=double(obj.CleaningNumCols(obj.CleaningLineNum))*obj.CleaningStepSize*1e3; % length of circle cord at this vertical position
              if xm<(boundary(1)+boundary(3)/2) % move in +ve x direction
                reqmove = [crdlen+2*adist(1)+obj.lmovadd 0] ;
              else % move in -ve x direction
                reqmove = [-crdlen-2*adist(1)-obj.lmovadd 0] ;
              end
              fprintf(obj.STDOUT,'%s: Cleaning: line # %d (of %d)\n',datetime,obj.CleaningLineNum,obj.CleaningNumLines);
              if obj.CleaningLineNum == obj.CleaningNumLines
                cstate = 4 ; % done
                obj.CleaningColNum = 1 ; obj.CleaningLineNum = 1 ;
                if obj.CleaningStartPosition ==4 
                  obj.CleaningStartPosition = 1 ;
                else
                  obj.CleaningStartPosition = obj.CleaningStartPosition + 1 ;
                end
                obj.gui.StartPositionKnob.Value = num2str(obj.CleaningStartPosition) ;
                % If in continuous mode, then reset to state 3 and clear integrated image
                if obj.cmode
                  obj.ClearPIMG;
                  obj.imupdate=true;
                  cstate = 3 ;
                  obj.cooldown=clock;
                end
              else
                obj.CleaningLineNum = obj.CleaningLineNum + 1 ;
                cstate = 3 ; % move to next line when move finished
              end
            case {2,4} % vertical moves
              href=xm;
              vref=[];
              crdlen=double(obj.CleaningNumLines(obj.CleaningColNum))*obj.CleaningStepSize*1e3; % length of circle cord at this horizontal position
              if ym<(boundary(2)+boundary(4)/2) % move in +ve y direction
                reqmove = [0 crdlen+2*adist(2)+obj.lmovadd] ;
              else % move in -ve y direction
                reqmove = [0 -crdlen-2*adist(2)-obj.lmovadd] ;
              end
              fprintf(obj.STDOUT,'%s: Cleaning: column # %d (of %d)\n',datetime,obj.CleaningColNum,obj.CleaningNumCols);
              if obj.CleaningColNum == obj.CleaningNumCols
                cstate = 4 ; % done
                obj.CleaningColNum = 1 ; obj.CleaningLineNum = 1 ;
                if obj.CleaningStartPosition ==4 
                  obj.CleaningStartPosition = 1 ;
                else
                  obj.CleaningStartPosition = obj.CleaningStartPosition + 1 ;
                end
                obj.gui.StartPositionKnob.Value = num2str(obj.CleaningStartPosition) ;
                % If in continuous mode, then reset to state 3 and clear integrated image
                if obj.cmode
                  obj.ClearPIMG;
                  obj.imupdate=true;
                  cstate = 3 ;
                  obj.cooldown=clock;
                end
              else
                obj.CleaningColNum = obj.CleaningColNum + 1 ;
                cstate = 3 ; % move to next line when move finished
              end
          end
          obj.movemirror(reqmove);
          movecount = movecount+1;
        case 3 % Move to beginning of next line or column
          vref=[]; href=[]; movecount=0;
          obj.State = CathodeServicesState.Cleaning_movingtonewline ;
          obj.ShutterCloseOveride = true ;
          xm = obj.LaserPosition_img(1) ;
          ym = obj.LaserPosition_img(2) ; % current position
          adist = obj.AcclDist ; % distance to accelerate to full velocity [mm]
          switch obj.CleaningStartPosition
            case 1 % horizontal moves, starting from bottom
              crdlen=double(obj.CleaningNumCols(obj.CleaningLineNum))*obj.CleaningStepSize*1e3; % length of circle cord at this vertical position
              if xm<(boundary(1)+boundary(3)/2) % next move in +ve x direction
                dest = [boundary(1)+boundary(3)/2-crdlen/2-adist(1) boundary(2)+obj.CleaningStepSize*1e3*double(obj.CleaningLineNum-1)+(obj.CleaningStepSize/2)*1e3] ;
              else % next move in -ve x direction
                dest = [boundary(1)+boundary(3)/2+crdlen/2+adist(1) boundary(2)+obj.CleaningStepSize*1e3*double(obj.CleaningLineNum-1)+(obj.CleaningStepSize/2)*1e3] ;
              end
              fprintf(obj.STDOUT,'%s: Cleaning: move to line # %d (of %d)\n',datetime,obj.CleaningLineNum,obj.CleaningNumLines);
            case 3
              % horizontal moves, starting from top
              crdlen=double(obj.CleaningNumCols(obj.CleaningLineNum))*obj.CleaningStepSize*1e3; % length of circle cord at this vertical position
              if xm<(boundary(1)+boundary(3)/2) % next move in +ve x direction
                dest = [boundary(1)+boundary(3)/2-crdlen/2-adist(1) boundary(2)+boundary(4)-obj.CleaningStepSize*1e3*double(obj.CleaningLineNum-1)-(obj.CleaningStepSize/2)*1e3] ;
              else % next move in -ve x direction
                dest = [boundary(1)+boundary(3)/2+crdlen/2+adist(1) boundary(2)+boundary(4)-obj.CleaningStepSize*1e3*double(obj.CleaningLineNum-1)-(obj.CleaningStepSize/2)*1e3] ;
              end
              fprintf(obj.STDOUT,'%s: Cleaning: move to line # %d (of %d)\n',datetime,obj.CleaningLineNum,obj.CleaningNumLines);
            case 2 % vertical moves, starting on left
              crdlen=double(obj.CleaningNumLines(obj.CleaningColNum))*obj.CleaningStepSize*1e3; % length of circle cord at this horizontal position
              if ym<(boundary(2)+boundary(4)/2) % next move in +ve y direction
                dest = [boundary(1)+obj.CleaningStepSize*1e3*double(obj.CleaningColNum-1)+(obj.CleaningStepSize/2)*1e3 boundary(2)+boundary(4)/2-crdlen/2-adist(2)] ;
              else % next move in -ve y direction
                dest = [boundary(1)+obj.CleaningStepSize*1e3*double(obj.CleaningColNum-1)+(obj.CleaningStepSize/2)*1e3 boundary(2)+boundary(4)/2+crdlen/2+adist(2)] ;
              end
              fprintf(obj.STDOUT,'%s: Cleaning: move to column # %d (of %d)\n',datetime,obj.CleaningColNum,obj.CleaningNumCols);
            case 4 % vertical moves, starting on right
              crdlen=double(obj.CleaningNumLines(obj.CleaningColNum))*obj.CleaningStepSize*1e3; % length of circle cord at this horizontal position
              if ym<(boundary(2)+boundary(4)/2) % next move in +ve y direction
                dest = [boundary(1)+boundary(3)-obj.CleaningStepSize*1e3*double(obj.CleaningColNum-1)-(obj.CleaningStepSize/2)*1e3 boundary(2)+boundary(4)/2-crdlen/2-adist(2)] ;
              else % next move in -ve y direction
                dest = [boundary(1)+boundary(3)-obj.CleaningStepSize*1e3*double(obj.CleaningColNum-1)-(obj.CleaningStepSize/2)*1e3 boundary(2)+boundary(4)/2+crdlen/2+adist(2)] ;
              end
              fprintf(obj.STDOUT,'%s: Cleaning: move to column # %d (of %d)\n',datetime,obj.CleaningColNum,obj.CleaningNumCols);
          end
          xlim=[obj.pvs.CCD_x1.val{1} obj.pvs.CCD_x2.val{1}].*1e-3; ylim=[obj.pvs.CCD_y1.val{1} obj.pvs.CCD_y2.val{1}].*1e-3;
          if dest(1)<xlim(1)
            dest(1)=xlim(1);
          elseif dest(1)>xlim(2)
            dest(1)=xlim(2);
          end
          if dest(2)<ylim(1)
            dest(2)=ylim(1);
          elseif dest(2)>ylim(2)
            dest(2)=ylim(2);
          end
          posnow = obj.LaserPosition_img;
          reqmove = dest - posnow ;
          if obj.CleaningStartPosition==1 || obj.CleaningStartPosition==3 % loose start tol in scan direction
            pres=[obj.motrbktol*3 obj.motrbktol];
          else
            pres=[obj.motrbktol obj.motrbktol*3];
          end
          if any(abs(reqmove)>pres)
            disp(reqmove)
            obj.movemirror(reqmove,"fast");
          else % done with this move
            obj.pimg_ref = obj.pimg ; % reset reference integrated image
            cstate = 2 ;
          end
        case 4 % Cleaning complete, move back to center
          fprintf('Laser Cleaning Finish: %s\n',datestr(now))
          obj.stopping=true;
          href=[]; vref=[]; movecount=0;
          obj.ShutterCloseOveride = true ;
          CloseShutterAndVerify(obj) ;
          if any( abs( obj.CleaningCenter - obj.LaserPosition_img ) > obj.motrbktol )
            obj.movemirror("home");
          else % done with this move
            cstate = 0 ;
            obj.State = CathodeServicesState.Cleaning_definearea ;
            obj.ShutterCloseOveride = false ;
            obj.stopping=false;
          end
          fprintf(obj.STDOUT,'%s: Cleaning: finishing\n',datetime);
%           obj.CleaningSummaryData.finish = now;
      end
    end
    function Proc_Cleaning_testpattern(obj,varargin)
      persistent tpstate boundary1 boundary2 whan shutcall vref href movecount
      %PROC_CLEANING_TESTPATTERN Process a test calibration autopattern
      %Proc_Cleaning_testpattern(newstate) Process current test pattern state with CathodeServicesState.Cleaning_testpattern or CathodeServicesState.Cleaning_setenergypattern
      %Proc_Cleaning_testpattern("SetTestBoundary",[x0 y0 w h]) Set cleaning pattern boundaries (Matlab rectangle function pos format)
      %Proc_Cleaning_testpattern("SetEnergyBoundary",[x0 y0 w h]) Set cleaning pattern boundaries (Matlab rectangle function pos format)
      
      % Initialize state
      if isempty(tpstate)
        tpstate=0;
        shutcall=true(1,8);
      end
      movecount=0;
      
      % Process boundary set command
      if nargin>1
        if varargin{1}=="SetTestBoundary"
          boundary1=varargin{2};
          return
        elseif varargin{1}=="SetEnergyBoundary"
          boundary2=varargin{2};
          return
        elseif varargin{1}=="Stop"
          tpstate=8;
        else
          newstate = varargin{1} ;
        end
      end
      
      switch obj.State
        case CathodeServicesState.Cleaning_testpattern
          boundary=boundary1;
        case CathodeServicesState.Cleaning_setenergypattern
          boundary=boundary2;
      end
      
      % If laser motion currently in progress, unless moving diagonally then force orthogonal axis to be fixed
      if ~obj.LaserMotorStopped
        switch tpstate
          case {2,4} % vertical moves along test pattern rectangle
            if ~isempty(href) && obj.orthcorrect && movecount==1
              dx = href - obj.LaserPosition_img(1) ;
              if abs(dx)>obj.motrbktol
                mstopped=caget(obj.pvs.lsr_motion);
                if mstopped{1}==1
                  caput(obj.pvs.lsr_xvel,obj.MotorVeloHome);
                  xm = caget(obj.pvs.lsr_xmov) ;
                  caput(obj.pvs.lsr_xmov,xm+dx/4);
                end
              end
            end
          case {3,5} % horizontal moves along test pattern rectangle
            if ~isempty(vref) && obj.orthcorrect && movecount==1
              dy = vref - obj.LaserPosition_img(2) ;
              if abs(dy)>obj.motrbktol
                mstopped=caget(obj.pvs.lsr_motion);
                if mstopped{2}==1
                  caput(obj.pvs.lsr_yvel,obj.MotorVeloHome);
                  ym = caget(obj.pvs.lsr_ymov) ;
                  caput(obj.pvs.lsr_ymov,ym+dy/4);
                end
              end
            end
        end
        return
      end
      
      switch tpstate % take action based on current state
        case 0 % Start process actions
          href=[]; vref=[]; movecount=0;
          shutcall=true(1,8);
          % Telescope should be inserted (small spot size on cathode)
          if obj.pvs.laser_telescope.val{1}==0
            if isempty(whan) || ~ishandle(whan)
              whan=warndlg('Laser Telescope Optics not inserted, cannot start Test Cleaning Sequence','Telescope not inserted');
            end
            return
          end

          % Need to have previously defined cleaning program area
          if obj.State ~= CathodeServicesState.Cleaning_definearea
            if isempty(whan) || ~ishandle(whan)
              whan=warndlg('Cleaning area not yet defined, or different program in progress, stop any in-use program or use "Define Cleaning Program Areas" button first','Cleaning Area Undefined');
            end
            return
          end
          
          % Boundary vector should be filled
          if isempty(boundary1)
            if isempty(whan) || ~ishandle(whan)
              whan=warndlg('No area boundary defined, push "Define cleaning program areas" button first','No Test area boundary');
            end
            return
          end

          % Make sure image streaming enabled and laser shutter initially closed
          obj.gui.StreamImageButton.Value = 1 ;
          obj.gui.StreamImageButton.ValueChangedFcn(obj.gui,obj.gui.StreamImageButton) ;
          if ~obj.CloseShutterAndVerify()
            return
          end
          tpstate = 1 ;
          obj.State = newstate ; % watchdog method will repeatedly call this function until aborted
          fprintf(obj.STDOUT,'%s: Cleaning_testpattern: start\n',datetime);
        case 1 % move to right edge of test pattern square from center
          vref=[]; href=[]; movecount=0;
          obj.ShutterCloseOveride = true ; % don't open shutter until on auto pattern path
          dest = [boundary(1)+boundary(3) boundary(2)+boundary(4)/2] ;
          reqmove = dest - obj.LaserPosition_img ;
          if any(abs(reqmove)>obj.motrbktol)
            obj.movemirror(reqmove,"fast");
          else % done with this move
            tpstate = 2 ;
          end
          obj.ClearPIMG();
          fprintf(obj.STDOUT,'%s: Cleaning_testpattern: step 1\n',datetime);
        case 2 % move to top-right of test pattern square
          if obj.State ~= CathodeServicesState.Cleaning_testpattern && shutcall(2) % open shutter for first move only
            OpenShutterAndVerify(obj);
            shutcall(2)=false;
          end
          obj.ShutterCloseOveride = false ; % ok to open shutter when moving now
          dest = [boundary(1)+boundary(3) boundary(2)+boundary(4)] ;
          reqmove = dest - obj.LaserPosition_img ;
          href = obj.LaserPosition_img(1) ;
          if any(abs(reqmove)>obj.motrbktol)
            obj.movemirror(reqmove);
            movecount=movecount+1;
          else % done with this move
            tpstate = 3 ;
            movecount=0;
          end
          obj.ClearPIMG();
          fprintf(obj.STDOUT,'%s: Cleaning_testpattern: step 2\n',datetime);
        case 3 % move to top-left of test pattern square
          if obj.State ~= CathodeServicesState.Cleaning_testpattern && shutcall(3) % open shutter for first move only
            OpenShutterAndVerify(obj);
            shutcall(3)=false;
          end
          obj.ShutterCloseOveride = false ; % ok to open shutter when moving now
          dest = [boundary(1) boundary(2)+boundary(4)] ;
          reqmove = dest - obj.LaserPosition_img ;
          vref=obj.LaserPosition_img(2);
          if any(abs(reqmove)>obj.motrbktol)
            obj.movemirror(reqmove);
            movecount=movecount+1;
          else % done with this move
            tpstate = 4 ;
            movecount=0;
          end
          obj.ClearPIMG();
          fprintf(obj.STDOUT,'%s: Cleaning_testpattern: step 3\n',datetime);
        case 4 % move to bottom-left of test pattern square
          if obj.State ~= CathodeServicesState.Cleaning_testpattern && shutcall(4) % open shutter for first move only
            OpenShutterAndVerify(obj);
            shutcall(4)=false;
          end
          obj.ShutterCloseOveride = false ; % ok to open shutter when moving now
          dest = [boundary(1) boundary(2)] ;
          reqmove = dest - obj.LaserPosition_img ;
          href=obj.LaserPosition_img(1);
          if any(abs(reqmove)>obj.motrbktol)
            obj.movemirror(reqmove);
            movecount=movecount+1;
          else % done with this move
            tpstate = 5 ;
            movecount=0;
          end
          obj.ClearPIMG();
          fprintf(obj.STDOUT,'%s: Cleaning_testpattern: step 4\n',datetime);
        case 5 % move to bottom-right of test pattern square
          if obj.State ~= CathodeServicesState.Cleaning_testpattern && shutcall(5) % open shutter for first move only
            OpenShutterAndVerify(obj);
            shutcall(5)=false;
          end
          obj.ShutterCloseOveride = false ; % ok to open shutter when moving now
          dest = [boundary(1)+boundary(3) boundary(2)] ;
          reqmove = dest - obj.LaserPosition_img ;
          vref=obj.LaserPosition_img(2);
          if any(abs(reqmove)>obj.motrbktol)
            obj.movemirror(reqmove);
            movecount=movecount+1;
          else % done with this move
            movecount=0;
            if obj.State == CathodeServicesState.Cleaning_testpattern % include diagonal moves for test pattern, not for energy set pattern
              tpstate = 6 ;
            else
              shutcall=true(1,8);
              tpstate = 2 ;
            end
          end
          obj.ClearPIMG();
          fprintf(obj.STDOUT,'%s: Cleaning_testpattern: step 5\n',datetime);
        case 6 % move diagonally to top-left
          obj.ShutterCloseOveride = false ; % ok to open shutter when moving now
          dest = [boundary(1) boundary(2)+boundary(4)] ;
          reqmove = dest - obj.LaserPosition_img ;
          if any(abs(reqmove)>obj.motrbktol)
            obj.movemirror(reqmove);
          else % done with this move
            tpstate = 7 ;
          end
          obj.ClearPIMG();
          fprintf(obj.STDOUT,'%s: Cleaning_testpattern: step 6\n',datetime);
        case 7 % move diagonally to bottom-right
          obj.ShutterCloseOveride = false ; % ok to open shutter when moving now
          dest = [boundary(1)+boundary(3) boundary(2)] ;
          reqmove = dest - obj.LaserPosition_img ;
          if any(abs(reqmove)>obj.motrbktol)
            obj.movemirror(reqmove);
          else % done with this move
            tpstate = 2 ;
          end
          obj.ClearPIMG();
          fprintf(obj.STDOUT,'%s: Cleaning_testpattern: step 7\n',datetime);
        case 8 % stop process and return to center of cleaning pattern area
          movecount=0;
          obj.stopping=true;
          obj.ShutterCloseOveride = true ; % don't open shutter until on auto pattern path
          CloseShutterAndVerify(obj) ;
          obj.ClearPIMG(); % Clear integrated image data
          dest = obj.CleaningCenter ;
          reqmove = dest - obj.LaserPosition_img ;
          if any(abs(reqmove)>obj.motrbktol)
            obj.movemirror("home");
          else % done with this move
            tpstate = 0 ;
            obj.State = CathodeServicesState.Cleaning_definearea ;
            obj.ShutterCloseOveride = false ; 
            obj.stopping=false;
          end
          fprintf(obj.STDOUT,'%s: Cleaning_testpattern: finishing\n',datetime);
      end
      
    end
    function movemirror(obj,dpos,cmd)
      %MOVEMIRROR Command laser mirror relative move or go home
      %movemirror(delta-pos) Sets velocity based on object properties
      %movemirror(delta-pos,"fast") Uses "home" motor velocity
      %movemirror("home") Go to home position defined by CleaningCenter or MapCenter property
      %opens laser shutter if in auto mode, then make relative move
      
      if ~exist('dpos','var') || ( ~isequal(dpos,"home") && ( ~isnumeric(dpos) || length(dpos)~=2) )
        error('Incorrect movemirror command structure')
      end
      xm = caget(obj.pvs.lsr_xmov) ;
      ym = caget(obj.pvs.lsr_ymov) ; % current mirror command position
      if isequal(dpos,"home")
        if obj.gui.TabGroup.SelectedTab ==  obj.gui.TabGroup.Children(1) % Laser Cleaning Tab
          dpos = obj.CleaningCenter - obj.LaserPosition_img ;
        elseif obj.gui.TabGroup.SelectedTab ==  obj.gui.TabGroup.Children(2) % QE Map Tab
          dpos = obj.MapCenter - obj.LaserPosition_img ;
        end
        vel = obj.MotorVeloHome ;
      elseif exist('cmd','var') && cmd=="fast"
        vel = obj.MotorVeloHome ;
      else
        vel = obj.MotorVelo ;
      end
      if ~any(abs(dpos))>obj.motrbktol
        return
      end
      if vel<obj.motorsettings(1,4) || vel<obj.motorsettings(2,4)
        fprintf(2,'Warning, mirror velocity set too low, min velocity used!');
      end
      caput(obj.pvs.lsr_xvel,vel); caput(obj.pvs.motx_bvelo,vel/abs(obj.VCC_mirrcal(3)));
      caput(obj.pvs.lsr_yvel,vel); caput(obj.pvs.moty_bvelo,vel/abs(obj.VCC_mirrcal(4)));
      xnew = xm+dpos(1);
      ynew = ym+dpos(2);
      caput(obj.pvs.lsr_xmov,xnew);
      caput(obj.pvs.lsr_ymov,ynew);
      obj.LaserMotorStopped=false;
    end
    function guicmd(obj,cmd,varargin)
      %GUICMD Pass commands from GUI
      switch string(cmd)
        case "acq-cont"
          caput(obj.pvs.CCD_acqsetmode,2);
          caput(obj.pvs.CCD_acqset,1);
        case "acq-single"
          obj.imupdate=true; % force refresh of all graphics
          caput(obj.pvs.CCD_acqsetmode,0);
          caput(obj.pvs.CCD_acqset,1);
        case "acq-stop"
          caput(obj.pvs.CCD_acqset,0);
        case "stop-reset"
          obj.StopResetGUI;
        otherwise
          error('Unknown command: %s',cmd)
      end
    end
    function StopResetGUI(obj,cmd)
      switch cmd
        case 'STOP'
          obj.ShutterCloseOveride = true ;
          obj.CloseShutterAndVerify ;
          obj.cooldown=false;
          caput(obj.pvs.lsr_stopx,1); caput(obj.pvs.lsr_stopy,1);
          if obj.State == CathodeServicesState(6)
            obj.StopResetGUI('RESET');
          end
          switch obj.State
            case {CathodeServicesState.Cleaning_testpattern,CathodeServicesState.Cleaning_setenergypattern}
              obj.Proc_Cleaning_testpattern("Stop");
            case {CathodeServicesState.Cleaning_movingtonewline,CathodeServicesState.Cleaning_linescan}
              obj.Proc_Cleaning("Stop");
            case {CathodeServicesState.QEMap_movingtonewline,CathodeServicesState.QEMap_linescan}
              obj.Proc_QEMap("Stop");
          end
        case 'RESET'
          if obj.State ~= CathodeServicesState(6) % if not reseting from auto stop then want to reset GUI
            resp=questdlg('Reset to standby mode (memory of any progress will be lost)?','Reset to Stanby Mode',...
              'Yes','No','No');
            if strcmp(resp,'Yes')
              obj.CleaningLineNum=1;
              obj.CleaningColNum=1;
              obj.AutoStop("reset");
              obj.ClearPIMG;
              if obj.pvs.laser_telescope.val{1}>0
                obj.State=CathodeServicesState.Standby_cleaninglasermode;
              else
                obj.State=CathodeServicesState.Standby_opslasermode;
              end
              obj.imupdate=true;
            end
          else % Reset from watchdog autostop
            obj.pimg_ref = obj.pimg ; % reset reference integrated image
            obj.gui.CLOSESwitch.Enable='on';
            obj.AutoStop("reset");
          end
      end
    end
    function isclosed = CloseShutterAndVerify(obj)
      persistent han
      if caget(obj.pvs.laser_shutterStatIn) && ~caget(obj.pvs.laser_shutterStatOut)
        isclosed=true;
        return
      end
      caput(obj.pvs.laser_shutterCtrl,'No');
      timeout=3;
      t0=tic;
      isclosed = false ;
      while ~caget(obj.pvs.laser_shutterStatIn) || caget(obj.pvs.laser_shutterStatOut)
        pause(0.1);
        if toc(t0)>timeout
          if isempty(han) || ~ishandle(han)
            han=errordlg('MPS Laser Shutter Not reported closed, check!','MPS Laser Shutter not closed');
          end
          return
        end
      end
      isclosed = true ;
    end
    function isopen = OpenShutterAndVerify(obj)
      persistent han
      if ~caget(obj.pvs.laser_shutterStatIn) && caget(obj.pvs.laser_shutterStatOut)
        isopen=true;
        return
      end
      caput(obj.pvs.laser_shutterCtrl,'Yes');
      timeout=3;
      t0=tic;
      isopen = false ;
      while caget(obj.pvs.laser_shutterStatIn) || ~caget(obj.pvs.laser_shutterStatOut)
        pause(0.1);
        if toc(t0)>timeout
          if isempty(han) || ~ishandle(han)
            han=errordlg('MPS Laser Shutter Not reported open, check!','MPS Laser Shutter not open');
          end
          return
        end
      end
      isopen = true ;
    end
    function AutoStop(obj,reasons,txt)
      persistent lastreasons prevstate
      if obj.stopping == true % if in the process of stopping, then let continue
          return;
      end
      if isequal(reasons,"reset")
        % If stopped due to integrated signal getting too high, renormalize the signal
        lastreasons="none";
        if ~isempty(prevstate) % put back into state when error issued
          obj.State=prevstate;
        end
        if exist('ABORTREQ','file') % Delete abort request file- generated by remote process
          delete('ABORTREQ');
        end
        return
      end
      isclosed = obj.CloseShutterAndVerify ;
      if isclosed; obj.gui.CLOSESwitch.Enable=false; end
      if isequal(reasons,lastreasons) % process warnings etc if new failure reasons
        return
      else
        lastreasons=reasons;
      end
      prevstate = obj.State ;
      obj.State = CathodeServicesState(6) ;
      set(obj.gui.CleaningStatusEditField,'Value',sprintf('%s <Reset to cont.>',text(obj.State)));
      set(obj.gui.CleaningStatusEditField,'BackgroundColor',[0.85,0.33,0.10]);
      fprintf(obj.STDERR,'%s: F2_CathodeServicesApp AutoStop:\n%s\n',datetime,reasons(:));
      if exist('txt','var') && ~isempty(txt)
        fprintf(obj.STDERR,'%s\n',split(txt,';'));
      end
      warndlg(sprintf('Auto shutdown Cathode Services Program:  \n%s\nCHECK LASER AND MPS SHUTTER STATUS  \nPush Reset Button to re-start',reasons(:)),'MPS Laser Shutter Inserted');
    end
    function shutdown(obj)
      %SHUTDOWN Actions to perform when closing GUI
      try
        % Restore velocity PVs (use Home velocity)
        vel = obj.MotorVeloHome ;
        caput(obj.pvs.lsr_xvel,vel); caput(obj.pvs.motx_bvelo,vel/abs(obj.VCC_mirrcal(3)));
        caput(obj.pvs.lsr_yvel,vel); caput(obj.pvs.moty_bvelo,vel/abs(obj.VCC_mirrcal(4)));
        % Store configuration state for re-load on next start
        obj.SaveConfig;
        % Stop timers and exit matlab session
        stop(obj.pvlist);
        fprintf('Cleanup PV processes...\n');
        obj.pvlist.Cleanup;
        fprintf('Done with cleanup.\n');
      catch ME
        fprintf(obj.STDERR,ME.message);
      end
    end
    function ClearPIMG(obj)
      %CLEARPIMG Clear persistent image and other integrated data
      obj.pimg=[]; obj.pimg_ref=[];
      obj.qint_f=[];
      obj.qint_t=[];
      obj.lint=[];
    end
    function SaveConfig(obj,fname)
      %SAVECONFIG Save key configuration data
      %SaveCongig() Saves "default" configuration data, loaded on next startup (this is done on app exit)
      %SaveConfig(fname) Save configuration data with user supplied file name
      configdata = struct;
      for iconf=1:length(obj.configprops)
        configdata.(obj.configprops(iconf)) = obj.(obj.configprops(iconf)) ;
      end
      if ~exist('fname','var')
        fname=sprintf('%s/F2_CathodeServices_configdata',obj.confdir);
      end
      save(fname,'configdata');
    end
    function LoadConfig(obj,fname)
      %LOADCONFIG Load saved configuration parameters
      %LoadConfig() Loads "default" configuration parameters (from last time app exited)
      %LoadConfig(fname) Loads configuration parameters from user supplied file name
      if ~exist('fname','var') || isempty(fname)
        fname=obj.confdir + "/F2_CathodeServices_configdata" ;
      end
      if ~exist(fname,'file') && ~exist(sprintf('%s.mat',fname),'file')
        error('Cannot find file: %s',fname)
      end
      ld=load(fname);
      if ~isfield(ld.configdata,'version') || ld.configdata.version~=obj.version
        error('Version mismatch between saved configuration file and running app')
      end
      fn=fieldnames(ld.configdata);
      for ifn=1:length(fn)
        if ~strcmp(fn{ifn},'version')
          obj.(fn{ifn})=ld.configdata.(fn{ifn});
        end
      end
      % If not the main GUI environment, bail here
      if isempty(obj.gui)
        return
      end
      % Write restored PV values and update GUIs
      obj.SetLimits("GunVacuumRange",obj.GunVacuumRange);
      obj.SetLimits("ImageIntensityRange",obj.ImageIntensityRange);
      obj.SetLimits("LaserEnergyRange",obj.LaserEnergyRange);
      obj.SetLimits("LaserSpotSizeRange",obj.LaserSpotSizeRange);
      obj.SetLimits("LaserPosition_tol",obj.LaserPosition_tol);
      obj.SetLimits("LaserFluenceRange",obj.LaserFluenceRange);
      obj.gui.HomeVELOmmsEditField.Value = double(obj.MotorVeloHome) ;
      obj.gui.StepSizeEditField.Value = double(obj.CleaningStepSize*1e6) ;
      obj.gui.PulsesateachpositionSpinner.Value = double(obj.CleaningNumPulsesPerStep) ;
      obj.gui.CleaningRadiusmmEditField.Value = double(obj.CleaningRadius*1e3) ;
      obj.gui.ccentEdit_x.Value = double(obj.CleaningCenter(1)) ;
      obj.gui.ccentEdit_y.Value = double(obj.CleaningCenter(2)) ;
      obj.gui.StartPositionKnob.Value = num2str(obj.CleaningStartPosition) ;
      obj.gui.ImageRotation0Menu.Text = sprintf('Image Rotation = %d',obj.imrot);
      obj.gui.ImageFlipX0Menu.Text = sprintf('Image Flip X = %d',obj.imflipX);
      obj.gui.ImageFlipY0Menu.Text = sprintf('Image Flip Y = %d',obj.imflipY);
      obj.SetMirrCal(obj.VCC_mirrcal);
      obj.gui.StartDistance.Text = sprintf('Start Distance = %g',obj.adistadd);
      obj.gui.OrthBacklash.Checked=obj.orthcorrect;
      obj.gui.NormalizationMenu.Text = sprintf('Normalization = %s',obj.imgnormalize);
    end
    function SaveImage(obj,fname)
      if ~exist('fname','var')
        error('No file name provided');
      end
      try
        img=get(obj.gui.UIAxes.Children(end),'CData');
        xdata=get(obj.gui.UIAxes.Children(end),'XData');
        ydata=get(obj.gui.UIAxes.Children(end),'YData');
        save(fname,'img','xdata','ydata');
      catch ME
        errordlg('Error saving image data: unexpected data format','Image Save Failed');
        throw(ME)
      end
    end
    function LoadImage(obj,fname)
      % Load image data
      if ~exist(fname,'file') && ~exist(sprintf('%s.mat',fname),'file')
        error('Cannot find file: %s',fname)
      end
      try
        ld=load(fname,'img','xdata','ydata');
      catch ME
        errorglg('Failed to load image data, incorrect save format?','Image Load Failed');
        throw(ME)
      end
      % Display image
      han=obj.gui.UIAxes;
      hold(han,'off');
      cla(han);
      axis(han,[ld.xdata(1) ld.xdata(end) ld.ydata(1) ld.ydata(end)]),hold(han,'on')
      imagesc(han,ld.img,'XData',ld.xdata,'YData',ld.ydata); xlabel(han,'X [mm]'); ylabel(han,'Y [mm]');
      axis(han,'image');
    end
    function CleaningDataSummary(obj) %#ok<MANU>
%       if ~isempty(obj.CleaningSummaryData) && obj.CleaningSummaryData.counter>0
%         c=false(1,length(obj.CleaningSummaryData.LaserEnergy)); c(1:obj.CleaningSummaryData.counter)=true;
%         txt{1}=sprintf('Cleaning start time: %s',datestr(obj.CleaningSummaryData.start));
%         if isfield(obj.CleaningSummaryData,'finish')
%           txt{2}=sprintf('Cleaning finish time: %s',datestr(obj.CleaningSummaryData.finish));
%         else
%           txt{2}='Cleaning finish time: <unfinished>';
%         end
%         txt{3}=sprintf('Laser energy (joulemeter): mean = %.3f STD = %.3f PK-PK = %.3f (uJ)',...
%           mean(obj.CleaningSummaryData.LaserEnergy(c)),std(obj.CleaningSummaryData.LaserEnergy(c)),range(mean(obj.CleaningSummaryData.LaserEnergy(c))));
%         txt{4}=sprintf('Laser fluence: mean = %.3f STD = %.3f PK-PK = %.3f (uJ/mm^2)',...
%           mean(obj.CleaningSummaryData.LaserFluence(c)),std(obj.CleaningSummaryData.LaserFluence(c)),range(mean(obj.CleaningSummaryData.LaserFluence(c))));
%         msgbox(txt);
%       end
    end
  end
  % get/set methods
  methods
    function time = get.bonustime(obj)
      time = 180 * ( 75 / (obj.CleaningRadius / obj.CleaningStepSize) ) ;
    end
    function [xpos,ypos] = GetLaserPos(obj)
      if obj.UseMirrPos
        xpos = caget(obj.pvs.lsr_posx) ;
        ypos = caget(obj.pvs.lsr_posy) ;
      else
        xpos = obj.LaserPosition_img(1) ;
        ypos = obj.LaserPosition_img(2) ;
      end
    end
    function SetMirrCal(obj,cal)
      %SETMIRRCAL Set calibration coefficients for mirror position readback
      %SetMirrCal([offX,offY,scalX,scalY]) 
      if ~exist('cal','var') || length(cal)~=4
        error('Must supply cal as 1x4 vector [offX,offY,scalX,scalY]');
      end
      obj.VCC_mirrcal=cal;
      obj.pvs.lsr_posx.conv = obj.VCC_mirrcal([3 1]) ;
      obj.pvs.lsr_posy.conv = obj.VCC_mirrcal([4 2]) ;
      obj.pvs.lsr_xvel.conv = abs(obj.VCC_mirrcal(3)) ;
      obj.pvs.lsr_yvel.conv = abs(obj.VCC_mirrcal(4)) ;
      obj.pvs.lsr_xmov.conv = obj.VCC_mirrcal(3) ;
      obj.pvs.lsr_ymov.conv = obj.VCC_mirrcal(4) ;
      obj.gui.MotorCALMenu.Text = sprintf('Motor CAL = [%g %g %g %g]',cal) ;
    end
    function SetLimits(obj,par,limits)
      %SETLIMITS Set lower,upper limits for PV and derived parameters
      %SetLimits("GunVacuumRange",[low,high])
      %SetLimits("ImageIntensityRange",[low,high])
      %SetLimits("LaserEnergyRange",[low,high])
      %SetLimits("LaserSpotSizeRange",[low,high])
      %SetLimits("LaserFluence",[low,high])
      %SetLimits("LaserPosition_tol",tol)
      
      % Changing PV object limits causes GUI objects to be updated
      limits=double(limits);
      try
        obj.(par)=limits;
        switch string(par)
          case "GunVacuumRange"
            obj.pvs.gun_vacuum.limits = limits ;
            caput(obj.pvs.watchdog_gunvaclimitHI,1e-9*double(limits(2)));
            caput(obj.pvs.watchdog_gunvaclimitLO,1e-9*double(limits(1)));
          case "ImageIntensityRange" % no associated PV, just change range on GUI gauge
            obj.pvs.CCD_intensity.limits = limits ;
            rng=range(limits); buf=0.1;
            obj.gui.ImageIntensityGauge.Limits = double([limits(1)-rng*buf,limits(2)+rng*buf]) ;
            obj.gui.ImageIntensityGauge.ScaleColors = [1,0,0;0,1,0;1,0,0] ;
            obj.gui.ImageIntensityGauge.ScaleColorLimits = ...
              double([limits(1)-rng*buf,limits(1);limits(1),limits(2);limits(2),limits(2)+rng*buf]) ;
          case "LaserEnergyRange"
            obj.pvs.laser_energy.limits = limits ;
            caput(obj.pvs.watchdog_laserlimitHI,double(limits(2)));
            caput(obj.pvs.watchdog_laserlimitLO,double(limits(1)));
          case "LaserSpotSizeRange"
            obj.pvs.CCD_spotsize.limits = limits ;
          case "LaserFluenceRange" % no associated PV, just change range on GUI gauge
            lims2=ceil((limits(2)+range(limits)*0.15)*10)/10;
            obj.gui.Gauge_3.Limits = [limits(1) lims2] ;
            obj.gui.Gauge_3.ScaleColorLimits = [limits(1) limits(2); limits(2) lims2 ];
            obj.gui.Gauge_3.ScaleColors = {'green','red'} ;
          case "LaserPosition_tol"
            obj.gui.LaserPosTolMenu.Text = sprintf('Laser Pos Tol = %g um',limits*1000) ;
          otherwise
            error('Unknown limit parameter');
        end
      catch ME
        error('Error setting limits for %s :\n %s\n',par,ME.message);
      end
    end
    function numlines=get.CleaningNumLines(obj)
      switch obj.CleaningStartPosition
        case {1,3} % horizontal moves
          numlines=ceil((obj.CleaningRadius*2)/(obj.CleaningStepSize));
        case {2,4} % vertical moves
          w=abs(linspace(0.00000001,obj.CleaningRadius*2-0.0000001,obj.CleaningNumCols)-obj.CleaningRadius);
          crdlen=2.*sqrt(obj.CleaningRadius^2-w.^2);
          numlines=ceil(crdlen./(obj.CleaningStepSize));
      end
    end
    function numcols=get.CleaningNumCols(obj)
      switch obj.CleaningStartPosition
        case {1,3} % horizontal moves
          h=abs(linspace(0.00000001,obj.CleaningRadius*2-0.0000001,obj.CleaningNumLines)-obj.CleaningRadius);
          crdlen=2.*sqrt(obj.CleaningRadius^2-h.^2);
          numcols=ceil(crdlen./(obj.CleaningStepSize));
        case {2,4} % vertical moves
          numcols=ceil((obj.CleaningRadius*2)/obj.CleaningStepSize);
      end
    end
    function time=get.CleaningTimeRemaining(obj) % minutes
      switch obj.CleaningStartPosition
        case {1,3} % horizontal moves
          numcols=obj.CleaningNumCols;
          numsteps=sum(numcols);
          if obj.CleaningLineNum>1
            stepsdone=sum(numcols(1:obj.CleaningLineNum-1))+obj.CleaningColNum-1;
          else
            stepsdone=obj.CleaningColNum-1;
          end
          time = (double(numsteps-stepsdone)*double(obj.CleaningNumPulsesPerStep)) / double(obj.RepRate) / 60 ;
        case {2,4} % vertical moves
          numlines=obj.CleaningNumLines;
          numsteps=sum(numlines);
          if obj.CleaningColNum>1
            stepsdone=sum(numlines(1:obj.CleaningColNum-1))+obj.CleaningLineNum-1;
          else
            stepsdone=obj.CleaningLineNum-1;
          end
          time = (double(numsteps-stepsdone)*double(obj.CleaningNumPulsesPerStep)) / double(obj.RepRate) / 60 ;
      end
      time = time + obj.bonustime*(double(numsteps-stepsdone)/double(numsteps)) ; % add end-effects estimate
    end
    function numlines=get.MapNumLines(obj)
      switch obj.MapStartPosition
        case {1,3} % horizontal moves
          numlines=ceil((obj.MapRadius*2)/(obj.MapStepSize));
        case {2,4} % vertical moves
          w=abs(linspace(0.00000001,obj.MapRadius*2-0.0000001,obj.MapNumCols)-obj.MapRadius);
          crdlen=2.*sqrt(obj.MapRadius^2-w.^2);
          numlines=ceil(crdlen./(obj.MapStepSize));
      end
    end
    function numcols=get.MapNumCols(obj)
      switch obj.MapStartPosition
        case {1,3} % horizontal moves
          h=abs(linspace(0.00000001,obj.MapRadius*2-0.0000001,obj.MapNumLines)-obj.MapRadius);
          crdlen=2.*sqrt(obj.MapRadius^2-h.^2);
          numcols=ceil(crdlen./(obj.MapStepSize));
        case {2,4} % vertical moves
          numcols=ceil((obj.MapRadius*2)/obj.MapStepSize);
      end
    end
    function time=get.MapTimeRemaining(obj) % minutes
      switch obj.MapStartPosition
        case {1,3} % horizontal moves
          numcols=obj.MapNumCols;
          numsteps=sum(numcols);
          if obj.MapLineNum>1
            stepsdone=sum(numcols(1:obj.MapLineNum-1))+obj.MapColNum-1;
          else
            stepsdone=obj.MapColNum-1;
          end
          time = (double(numsteps-stepsdone)*double(obj.MapNumPulsesPerStep)) / double(obj.RepRate) / 60 ;
        case {2,4} % vertical moves
          numlines=obj.MapNumLines;
          numsteps=sum(numlines);
          if obj.MapColNum>1
            stepsdone=sum(numlines(1:obj.MapColNum-1))+obj.MapLineNum-1;
          else
            stepsdone=obj.MapLineNum-1;
          end
          time = (double(numsteps-stepsdone)*double(obj.MapNumPulsesPerStep)) / double(obj.RepRate) / 60 ;
      end
    end
    function velo = get.MotorVelo(obj) % mm/s
      t = double(obj.CleaningNumPulsesPerStep) / double(obj.RepRate) ; % time to traverse 1 step size
      velo = (double(obj.CleaningStepSize)*1000) / t ; % velocity in mm / s
    end
    function adist = get.AcclDist(obj) % mm
      adist = obj.adistadd + abs(obj.MotorVelo .* [ obj.pvs.lsr_xaccl.val{1} obj.pvs.lsr_yaccl.val{1} ]) ;
    end
    function freq=get.wd_freq(obj)
      if obj.State == CathodeServicesState.Cleaning_linescan
        tave = mean(obj.wd_time_noncleaning,'omitnan');
      else
        tave = mean(obj.wd_time,'omitnan');
      end
      freq = 1/tave ;
      if isnan(freq)
        freq=0;
      end
    end
    function freqerr=get.wd_freqerr(obj)
      freqerr = std(1./obj.wd_time,'omitnan');
      if isnan(freqerr)
        freqerr=0;
      end
    end
    function set.adistadd(obj,val)
      % Set distance to add to starting position outside of cleaning circle
      %  (this is added to acceleration distance required)
      obj.adistadd=val;
      % Check added distance doesn't make us start outside CCD area and adjust if necessary
      xax=[obj.pvs.CCD_x1.val{1} obj.pvs.CCD_x2.val{1}].*1e-3;
      yax=[obj.pvs.CCD_y1.val{1} obj.pvs.CCD_y2.val{1}].*1e-3; % Axis ranges [mm]
      cent=obj.CleaningCenter;
      r=obj.CleaningRadius*1e3;
      adist=obj.AcclDist;
      safety=0.15;
      missval=[(cent(1)-r-adist(1)-safety)-xax(1) xax(2)-(cent(1)+r+adist(1)+safety) (cent(2)-r-adist(2)-safety)-yax(1) yax(2)-(cent(2)+r+adist(2)+safety)];
      if any(missval<0)
        newval = val - max(abs(missval(missval<0))) ;
        if newval<0; newval=0; end
        obj.adistadd = newval ;
      end
    end
    function set.buflen(obj,newlen)
      if newlen<10 || newlen>10000
        return
      end
      oldlen=obj.buflen;
      if newlen>oldlen
        oldvals=obj.poshistory;
        obj.poshistory = nan(4,newlen,'single') ;
        obj.poshistory(:,1:oldlen)=oldvals;
      elseif newlen<oldlen
        obj.poshistory=obj.poshistory(:,1:newlen); %#ok<*MCSUP>
      end
      obj.buflen=newlen;
    end
    function set.imagemap(obj,mapname)
      obj.imagemap=mapname;
      obj.imupdate=true; 
    end   
  end
  % watchdog / GUI updaters
  methods(Access=private)
    function watchdogUD(obj,~,~) % called whenever a monitored pv value changes
      persistent t0
      % If in an error state, don't do anything until error is cleared (with GUI reset button)
      if iserror(obj.State)
        return
      end
      % Drop update if last one still processing
      if obj.wd_running
        return
      end
      % Limit rate to twice reported CCD rate 
      if ~isempty(t0) && toc(t0)<(0.5/obj.CCD_rate)
        return
      end
      obj.wd_running=true;
      try
        obj.watchdog();
        if ~isempty(t0)
          if obj.State ~= CathodeServicesState.Cleaning_linescan
            obj.wd_time_noncleaning(obj.wd_time_ind_noncleaning) = toc(t0);
            if obj.wd_time_ind_noncleaning>=length(obj.wd_time_noncleaning)
              obj.wd_time_ind_noncleaning = 1 ;
            else
              obj.wd_time_ind_noncleaning = obj.wd_time_ind_noncleaning + 1 ;
            end
          end
          obj.wd_time(obj.wd_time_ind) = toc(t0);
          if obj.wd_time_ind>=length(obj.wd_time)
            obj.wd_time_ind = 1 ;
          else
            obj.wd_time_ind = obj.wd_time_ind + 1 ;
          end
        end
        t0=tic;
        obj.gui.EditField_15.Value=obj.wd_freq;
%         obj.gui.memuse.Value = java.lang.Runtime.getRuntime.freeMemory/1024/1024;
      catch ME
        obj.wd_running=false;
        rethrow(ME)
      end
      obj.wd_running=false;
    end
    function watchdog(obj,~,~) % called from watchdogUD timer when a PV value changes
      %WATCHDOG Process PV value chages, compute running state and take corresponding actions
      persistent prevVals repind lastepicswatchdog tic_epicswatchdog lastpos fhan lastStateConsidered sufficientRate t0wd inerr_tries inerr_pval

      
      % Force CA updates for 5s to make sure GUI values are correct
      tt=5;
      if isempty(t0wd)
        t0wd=tic;
      end
      if ~isnan(t0wd)
        if toc(t0wd)<tt
          caget(obj.pvlist,'force');
        else
          t0wd=nan;
        end
      end
      
      % Reasons to auto close laser shutter and put app in error state
      reasons = ["Automated laser pattern enabled without streaming CCD image",...  % 1
        "Repeated PV readings",...                                                  % 2
        "Gun RF not OFF",...                                                        % 3
        "EPICS watchdog isalive beacon stopped incrementing",...                    % 4
        "Laser not in motion with shutter OPEN whilst in cleaning mode",...         % 5
        "Laser position error, out of range",...                                    % 6
        "Gun Vacuum Out of range",...                                               % 7
        "Image Intensity Out of range",...                                          % 8
        "Laser energy Out of range",...                                             % 9
        "Laser spot size Out of range",...                                          % 10
        "Laser Position Out of Range",...                                           % 11
        "Laser telescope not inserted",...                                          % 12
        "Laser fluence out of range",...                                            % 13
        "Integrated image count too high (motors stuck?)",...                       % 14
        "VV155 not out", ...                                                        % 15
        "Laser attenuation flipper not IN" ] ;                                      % 16
      inerr = false(1,length(reasons)) ;
      etxt=""; % Additional error text to display goes here, split character is ";"
      if isempty(inerr_tries)
        inerr_tries=zeros(1,length(inerr),'uint8');
      end
      maxerrtries=[1 1 1 1 1 3 1 3 1 3 3 1 3 1 1 1]; % need this many consecutive errors to cause GUI to go into shutdown state
      
      % Actions to take based on telescope in/out state
      if obj.pvs.laser_telescope.val{1}>0 % telescope inserted (small laser spot)
        if ~isautopattern(obj.State) && obj.State~=CathodeServicesState.Cleaning_definearea && ...
            obj.State~=CathodeServicesState.Standby_cleaninglasermode && obj.State~=CathodeServicesState.QEMap_definearea
          obj.State = CathodeServicesState.Standby_cleaninglasermode ;
        end
      else
        if isautopattern(obj.State)
          [inerr,inerr_tries] = obj.procerr(12,maxerrtries,inerr,inerr_tries) ;
        elseif obj.State~=CathodeServicesState.Cleaning_definearea && obj.State~=CathodeServicesState.Standby_opslasermode && obj.State~=CathodeServicesState.QEMap_definearea
          obj.State = CathodeServicesState.Standby_opslasermode ;
          inerr_tries(12)=0;
        else
          inerr_tries(12)=0;
        end
      end
      obj.CCD_stream = obj.pvs.CCD_acq.val{1}==1 & obj.pvs.CCD_acqmode.val{1}==2 ; % is in continuous mode and acquiring?
      
      % Update time remaining
      if strcmp(obj.gui.TabGroup.SelectedTab.Title,'Laser Cleaning')
        timeremain=obj.CleaningTimeRemaining;
        if obj.CleaningLineNum==1 && obj.CleaningColNum==1
          obj.gui.min00secGauge.Limits=[0 ceil(timeremain)];
        end
        obj.gui.min00secGauge.Value=timeremain;
        obj.gui.min00secGaugeLabel.Text=sprintf('%d min %02d sec',floor(timeremain),round((timeremain-floor(timeremain))*60));
      else
        timeremain=obj.MapTimeRemaining;
        if obj.MapLineNum==1 && obj.MapColNum==1
          obj.gui.min00secGauge_2.Limits=[0 ceil(timeremain)];
        end
        obj.gui.min00secGauge_2.Value=timeremain;
        obj.gui.min00secGauge_2Label.Text=sprintf('%d min %02d sec',floor(timeremain),round((timeremain-floor(timeremain))*60));
      end
      
      % Get current PV & other derived values of interest and set corresponding properties
      epicswatchdog = obj.pvs.watchdog_isalive.val{1} ;
      obj.GunVacuum = obj.pvs.gun_vacuum.val{1} ;
      obj.LaserEnergy = obj.pvs.laser_energy.val{1} ;
      obj.LaserPosition_mot = [obj.pvs.lsr_posx.val{1} obj.pvs.lsr_posy.val{1}];
      gunrfon = ~strcmp(obj.pvs.gun_rfstate.val{1},'OFF') ;
      obj.LaserSpotSize = [obj.pvs.CCD_spotsize.val{1} obj.pvs.CCD_spotsize.val{2}] ;
      obj.ImageIntensity = obj.pvs.CCD_intensity.val{1} ;
      obj.LaserPosition_img = [obj.pvs.CCD_xpos.val{1} obj.pvs.CCD_ypos.val{1}] ;
      newreprate = obj.pvs.ArrayRate.val{1} ;
      if newreprate ~= obj.CCD_rate
        if newreprate<=0
          obj.CCD_rate = 30 ;
        else
          obj.CCD_rate = newreprate ;
        end
        obj.pvlist.pset('timeout',0.01 + 1/double(obj.CCD_rate));
      end
      
      % Store buffered data if requested
      if obj.bufacq && ( isempty(lastpos) || any(abs(obj.LaserPosition_img-lastpos)>0.01) ) % store positions in history buffer if substantially moved
        lastpos = obj.LaserPosition_img ;
        obj.poshistory(1,obj.bufpos) = obj.LaserPosition_img(1) ;
        obj.poshistory(2,obj.bufpos) = obj.LaserPosition_img(2) ;
        obj.poshistory(3,obj.bufpos) = obj.LaserPosition_mot(1) ;
        obj.poshistory(4,obj.bufpos) = obj.LaserPosition_mot(2) ;
        if obj.bufpos >= obj.buflen
          obj.bufpos=1;
        else
          obj.bufpos=obj.bufpos+1;
        end
        % Plot calibration data
        if ~isempty(obj.CalibHan) && all(ishandle(obj.CalibHan)) % plot mirror vs image position history in diagnostic window if requested
          plot(obj.CalibHan(1),obj.poshistory(3,:),obj.poshistory(1,:),'rx');
          grid(obj.CalibHan(1),'on');
          xlabel(obj.CalibHan(1),'Mirror Motor Reported H Position [mm]');
          ylabel(obj.CalibHan(1),'Image Reported H Position [mm]');
          plot(obj.CalibHan(2),obj.poshistory(4,:),obj.poshistory(2,:),'bo');
          grid(obj.CalibHan(2),'on');
          xlabel(obj.CalibHan(2),'Mirror Motor Reported V Position [mm]');
          ylabel(obj.CalibHan(2),'Image Reported V Position [mm]');
        end
      end
      
      % Write CCD image to axis if image changed - also get local versions of spot size, position and CCD intensity and overwrite EPICS
      % versions if good
      % - if on cleaning line scan, only draw image if update rate is fast enough
      if isempty(lastStateConsidered) || lastStateConsidered~=obj.State % keep same decision until State changes
        lastStateConsidered = obj.State ;
        sufficientRate = true ;
        if (obj.State == CathodeServicesState.Cleaning_linescan || obj.State == CathodeServicesState.QEMap_linescan) && (obj.wd_freq < obj.CCD_rate) 
          sufficientRate = false ;
        end
      end
      if ~sufficientRate % only get img in cleaning mode if the software update rate is high enough
        obj.getimg ;
      elseif obj.gui.DetachButton.Value % stream image to remote figure window
        if isempty(fhan) || ~ishandle(fhan)
          fhan=axes;
          obj.imdraw('reset');
        end
        obj.imdraw(fhan) ;
      else % stream image to GUI figure window
        obj.imdraw(obj.gui.UIAxes) ;
      end
      
      % Check VV155 Out
      if string(obj.pvs.VV155_position.val{1})~="OPEN"
        inerr(15) = true ;
        obj.gui.VV155Lamp.Color = 'red' ;
      else
        obj.gui.VV155Lamp.Color = 'green' ;
      end
      
      % Check EPICS watchdog running (check at <1Hz, and command autostop if in an automatic operating mode)
      if isempty(tic_epicswatchdog) || toc(tic_epicswatchdog)>1.5
        if ~isempty(lastepicswatchdog) && epicswatchdog==lastepicswatchdog
          if obj.State ~= CathodeServicesState.Standby_opslasermode
            [inerr,inerr_tries] = obj.procerr(4,maxerrtries,inerr,inerr_tries) ;
          end
          obj.gui.RunningLamp.Color='red';
          tic_epicswatchdog=tic;
        else
          inerr_tries(4)=0;
          obj.gui.RunningLamp.Color='green';
          tic_epicswatchdog=tic;
        end
        lastepicswatchdog=epicswatchdog;
      end
      
      % If in OPS mode (large spot size), then no further checks required
      if obj.State == CathodeServicesState.Standby_opslasermode
        if obj.dnCMD || ~obj.gui.DetachButton.Value
          drawnow;
        else
          drawnow limitrate
        end
        return;
      end
      
      % Poke EPICS watchdog keepalive PV
      caput(obj.pvs.watchdog_keepalive,1);
      caput(obj.pvs.watchdog_keepalive,1);
      
      % Throw error if the laser spot goes off the CCD area or estimate of centroid from image does
      xran=[obj.pvs.CCD_x1.val{1}+obj.LaserSpotSize(1)*1e-3 obj.pvs.CCD_x2.val{1}-obj.LaserSpotSize(1)*1e-3];
      yran=[obj.pvs.CCD_x1.val{1}+obj.LaserSpotSize(2)*1e-3 obj.pvs.CCD_x2.val{1}-obj.LaserSpotSize(2)*1e-3];
      test1 = obj.LaserPosition_mot(1)<xran(1) || obj.LaserPosition_mot(1)>xran(2) || obj.LaserPosition_mot(2)<yran(1) || obj.LaserPosition_mot(2)>yran(2) ;
      test2 = obj.LaserPosition_img(1)<xran(1) || obj.LaserPosition_img(1)>xran(2) || obj.LaserPosition_img(2)<yran(1) || obj.LaserPosition_img(2)>yran(2) ;
      if test1 || test2
        obj.LaserPosition_img = obj.LaserPosition_mot ; % use motor position readback when image not visible
%         [inerr,inerr_tries] = obj.procerr(6,maxerrtries,inerr,inerr_tries) ;
      else
        inerr_tries(6)=0;
      end
      
      % Use motor readback if image intensity or spot size out of bounds (the fit is suspect)
      if obj.ImageIntensity < obj.ImageIntensityRange(1) || obj.ImageIntensity > obj.ImageIntensityRange(2) || ...
          any(obj.LaserSpotSize < obj.LaserSpotSizeRange(1)) || any(obj.LaserSpotSize > obj.LaserSpotSizeRange(2))
        obj.LaserPosition_img = obj.LaserPosition_mot ;
      end
      
      % Check for integrated image pixels rising above threshold value- tests if motors got stuck in some way not detected by other means
      if ~isempty(obj.pimg_ref) && isequal(size(obj.pimg),size(obj.pimg_ref))
        pcomp = obj.pimg - obj.pimg_ref ;
      else
        pcomp = obj.pimg ;
      end
      if strcmp(obj.gui.TabGroup.SelectedTab.Title,'Laser Cleaning')
        if ~isempty(pcomp) && max(pcomp(:)) > ( double(obj.CleaningNumPulsesPerStep) * double(obj.ImageCIntMax) * double(obj.ImageIntensityRange(2)) )
          [inerr,inerr_tries] = obj.procerr(14,maxerrtries,inerr,inerr_tries) ;
          fprintf('Integrated image count = %g\n',max(obj.pimg(:)))
        else
          inerr_tries(14)=0;
        end
      else
        if ~isempty(pcomp) && max(pcomp(:)) > ( double(obj.MapNumPulsesPerStep) * double(obj.ImageCIntMax) * double(obj.ImageIntensityRange(2)) )
          [inerr,inerr_tries] = obj.procerr(14,maxerrtries,inerr,inerr_tries) ;
        else
          inerr_tries(14)=0;
        end
      end
      
      % CCD image should be streaming in auto pattern moving States, check that here
      if isautopattern(obj.State) && ~obj.CCD_stream
        [inerr,inerr_tries] = obj.procerr(1,maxerrtries,inerr,inerr_tries) ;
      else
        inerr_tries(1)=0;
      end
      
      % Check watched values are changing
      if obj.CheckRepVals
        nrepmax=10; % max number of repeated readings to allow
        watchpv=["gun_vacuum","laser_energy","lsr_posx","lsr_posy","CCD_xpos","CCD_ypos","CCD_intensity"];
        if ~obj.CCD_stream % only check vars related to CCD if in streaming mode
          iwatch=1:4;
        else
          iwatch=1:length(watchpv);
        end
        if isempty(repind)
          repind=zeros(1,length(watchpv));
          prevVals=nan(1,length(watchpv));
        end
        repval=false(1,length(watchpv));
        for ipv=iwatch
          if isequal(obj.pvs.(watchpv(ipv)).vals{1},prevVals{ipv})
            repval(ipv)=true;
          end
          prevVals{ipv} = obj.pvs.(watchpv(ipv)).vals{1} ;
        end
        repind(repval)=repind(repval)+1;
        repind(~repval)=0;
        if any(repind>=nrepmax)
          for irep=find(repind>=nrepmax)
            etxt=etxt+sprintf(">%d Repeated readings for %s;",nrepmax,watchpv(irep));
          end
          [inerr,inerr_tries] = obj.procerr(2,maxerrtries,inerr,inerr_tries) ;
        else
          inerr_tries(2)=0;
        end
      end
      
      % Check Gun RF is off if it is supposed to be
      if isgunoffstate(obj.State) && gunrfon
        inerr(3) = true ;
      end
      
      % shutter should only be open when laser in motion
      if obj.LaserMotorStopped==1 && isautopattern(obj.State) && ~obj.CloseShutterAndVerify
        [inerr,inerr_tries] = obj.procerr(5,maxerrtries,inerr,inerr_tries) ;
      else
        inerr_tries(5)=0;
      end
      
      % Check laser is where the mirror motors say it is (error if auto pattern and if not calibrating this)
      if any(abs(obj.LaserPosition_img-obj.LaserPosition_mot)>obj.LaserPosition_tol)
        if obj.State~=CathodeServicesState.Cleaning_testpattern && caget(obj.pvs.laser_shutterStatOut)
          [inerr,inerr_tries] = obj.procerr(11,maxerrtries,inerr,inerr_tries) ;
        else
          inerr_tries(11)=0;
        end
        obj.gui.InrangeLamp.Color='red';
      else
        inerr_tries(11)=0;
        obj.gui.InrangeLamp.Color='green';
      end
      
      % Check laser attenuation flipper state is in
      if ~strcmp(obj.pvs.laser_flipper.val{1},'IN')
        [inerr,inerr_tries] = obj.procerr(16,maxerrtries,inerr,inerr_tries) ;
      else
        inerr_tries(16)=0;
      end
      
      % Check values in range
      if obj.GunVacuum > obj.GunVacuumRange(2) || obj.GunVacuum < obj.GunVacuumRange(1)
        etxt=etxt+sprintf("Gun Vacuum Out of range: val= %g range= [%g %g];",obj.GunVacuum,obj.GunVacuumRange);
        if ~isfield(inerr_pval,'GunVacuum') || inerr_pval.GunVacuum~=obj.GunVacuum
          [inerr,inerr_tries] = obj.procerr(7,maxerrtries,inerr,inerr_tries) ;
        end
        inerr_pval.GunVacuum = obj.GunVacuum ;
      else
        inerr_tries(7)=0;
      end
      if obj.ImageIntensity < obj.ImageIntensityRange(1) || obj.ImageIntensity > obj.ImageIntensityRange(2)
        etxt=etxt+sprintf("Image Intensity Out of range: val= %g range= [%g %g];",obj.ImageIntensity,obj.ImageIntensityRange);
        if ~isfield(inerr_pval,'ImageIntensity') || inerr_pval.ImageIntensity~=obj.ImageIntensity
          [inerr,inerr_tries] = obj.procerr(8,maxerrtries,inerr,inerr_tries) ;
        end
        inerr_pval.ImageIntensity = obj.ImageIntensity ;
      else
        inerr_tries(8)=0;
      end
      if obj.LaserEnergy < obj.LaserEnergyRange(1) || obj.LaserEnergy > obj.LaserEnergyRange(2)
        etxt=etxt+sprintf("Laser energy Out of range: val= %g range= [%g %g];",obj.LaserEnergy,obj.LaserEnergyRange);
        if ~isfield(inerr_pval,'LaserEnergy') || inerr_pval.LaserEnergy~=obj.LaserEnergy
          [inerr,inerr_tries] = obj.procerr(9,maxerrtries,inerr,inerr_tries) ;
        end
        inerr_pval.LaserEnergy = obj.LaserEnergy ;
      else
        inerr_tries(9)=0;
      end
      if any(obj.LaserSpotSize < obj.LaserSpotSizeRange(1))
        etxt=etxt+sprintf("Laser spot size Out of range: val= %g range= [%g %g];",min(obj.LaserSpotSize),obj.LaserSpotSizeRange);
        if ~isfield(inerr_pval,'LaserSpotSize') || inerr_pval.LaserSpotSize~=obj.LaserSpotSize
          [inerr,inerr_tries] = obj.procerr(10,maxerrtries,inerr,inerr_tries) ;
        end
        inerr_pval.LaserSpotSize = obj.LaserSpotSize ;
      else
        inerr_tries(10)=0;
      end
      
      % Check alarms
      if obj.pvs.laser_energy.isalarm
        etxt=etxt+"Alarm on laser energy readback PV;";
        inerr(9)=true;
      end
      if obj.pvs.gun_vacuum.isalarm
        etxt=etxt+"Alarm on Gun Vacuum readback PV;";
        inerr(7)=true;
      end
      
      % Deal with laser fluence update and range checking
      fluence = obj.LaserFluence ;
      obj.gui.Gauge_3.Value = double(fluence) ;
      obj.gui.EditField_17.Value = double(fluence) ;
      if (fluence<obj.LaserFluenceRange(1) || fluence>obj.LaserFluenceRange(2)) && ...
          ( ~isfield(inerr_pval,'LaserFluence') || inerr_pval.LaserFluence~=obj.LaserFluence )
        obj.gui.Gauge_3.BackgroundColor=[0.7 0 0];
        [inerr,inerr_tries] = obj.procerr(13,maxerrtries,inerr,inerr_tries) ;
      else
        inerr_tries(13)=0;
        obj.gui.Gauge_3.BackgroundColor=[1 1 1];
      end
      inerr_pval.LaserFluence = obj.LaserFluence ;
      
      % If in error state, check shutter off and control disabled if in auto mode
      if any(inerr)
%         if isautopattern(obj.State) % any auto running state
        if iserrckpattern(obj.State) % if laser cleaning or energy set test pattern or QE map
          inerr_tries=zeros(size(inerr_tries)); % reset error counter
          obj.AutoStop(reasons(inerr),etxt);
          return
        end
      else
        txt = text(obj.State) ;
        if strcmp(obj.gui.TabGroup.SelectedTab.Title,'Laser Cleaning')
          if obj.State == CathodeServicesState.Cleaning_linescan || obj.State == CathodeServicesState.Cleaning_movingtonewline
            switch obj.CleaningStartPosition
              case {1,3} % horizontal moves
                nline = obj.CleaningNumLines ;
                iline = obj.CleaningLineNum ;
              otherwise
                nline = obj.CleaningNumCols ;
                iline = obj.CleaningColNum ;
            end
            txt=sprintf("%s (Line %d/%d)",txt,iline,nline);
          end
          obj.gui.CleaningStatusEditField.Value=txt;
          obj.gui.CleaningStatusEditField.BackgroundColor='white';
        else
          if obj.State == CathodeServicesState.QEMap_linescan || obj.State == CathodeServicesState.QEMap_movingtonewline
            switch obj.MapStartPosition
              case {1,3} % horizontal moves
                nline = obj.MapNumLines ;
                iline = obj.MapLineNum ;
              otherwise
                nline = obj.MapNumCols ;
                iline = obj.MapColNum ;
            end
            txt=sprintf("%s (Line %d/%d)",txt,iline,nline);
          end
          obj.gui.MappingStatusEditField.Value=txt;
          obj.gui.MappingStatusEditField.BackgroundColor='white';
        end
      end
      
      % Process cooldown wait
      if ~isempty(obj.cooldown)
        if etime(clock,obj.cooldown) < obj.ctime*60
          obj.gui.CleaningStatusEditField.Value=sprintf('Motor cooldown: %.1f / %.1f min ...',etime(clock,obj.cooldown)/60, obj.ctime) ;
          obj.gui.CleaningStatusEditField.BackgroundColor='white';
          drawnow
          return
        else
          obj.cooldown=[];
        end
      end
      
      % Process automatic pattern steps
      switch obj.State
        case {CathodeServicesState.Cleaning_testpattern,CathodeServicesState.Cleaning_setenergypattern}
          obj.Proc_Cleaning_testpattern(obj.State);
        case {CathodeServicesState.Cleaning_movingtonewline,CathodeServicesState.Cleaning_linescan}
          obj.Proc_Cleaning();
        case {CathodeServicesState.QEMap_movingtonewline,CathodeServicesState.QEMap_linescan}
          obj.Proc_QEMap();
      end
      
      % force drawnow?
      if obj.dnCMD || ~obj.gui.DetachButton.Value
        drawnow;
      else
        drawnow limitrate
      end
      
    end
  end
  methods
    function [nx,ny,img,imgstats] = getimg(obj)
      persistent bkgcount initshutstate
      imgstats=[];
      nx=obj.pvs.CCD_nx.val{1}; ny=obj.pvs.CCD_ny.val{1};
      obj.pvs.CCD_img.nmax=round(nx*ny);
      img=reshape(caget(obj.pvs.CCD_img),nx,ny);
      if obj.imrot>0 % rotate image by multiples of 90 degrees
        img=rot90(img,obj.imrot);
      end
      if obj.imflipX
        img=fliplr(img);
      end
      if obj.imflipY
        img=flipud(img);
      end
      
      % Take new background? (insert upstream laser shutter to block beam during background taking)
      if isempty(bkgcount)
        bkgcount=1;
      end
      if obj.takebkg && string(caget(obj.pvs.laser_shutter1))=="LOW"
        obj.validbkg = true ;
        if bkgcount==obj.nbkg
          bkgcount=1;
          obj.takebkg = false ;
          obj.bkg = obj.bkg + uint16(img) ;
          obj.bkg = uint16(double(obj.bkg) / double(obj.nbkg)) ;
          if ~isempty(initshutstate)
            caput(obj.pvs.laser_shutter1,initshutstate);
          end
          initshutstate=[];
        elseif bkgcount==1
          obj.bkg = uint16(img) ;
          bkgcount=2;
          caput(obj.pvs.takebkg,'Yes'); % Tell EPICS to take background for PROC calcs
        elseif ~isequal(size(obj.bkg),size(img))
          obj.validbkg = false ;
          obj.takebkg = false ;
        else
          obj.bkg = obj.bkg + uint16(img) ;
          bkgcount=bkgcount+1 ;
        end
      elseif obj.takebkg && string(caget(obj.pvs.laser_shutter1))~="LOW"
        initshutstate="HIGH" ;
        caput(obj.pvs.laser_shutter1,'LOW');
      end
      
      % perform background subtraction
      if obj.usebkg && ~isempty(obj.bkg) && ~obj.takebkg
        if isequal(size(img),size(obj.bkg))
          img = cast(uint16(img) - obj.bkg,'like',img);
          img(img<0) = 0 ;
        else
          obj.validbkg = false ;
        end
      end
      
      % Set bakground valid status on GUI
      if obj.takebkg
        obj.gui.ValidLamp.Color='red';
      elseif isequal(size(img),size(obj.bkg))
        obj.validbkg = true ;
        obj.gui.ValidLamp.Color='green';
      else
        obj.validbkg = false ;
        obj.gui.ValidLamp.Color='red';
      end
      
      % Replace spot size and centroid with local calculation - EPICS value
      xax=[obj.pvs.CCD_x1.val{1} obj.pvs.CCD_x2.val{1}].*1e-3; yax=[obj.pvs.CCD_y1.val{1} obj.pvs.CCD_y2.val{1}].*1e-3;
      xvals = linspace(xax(1),xax(2),nx) ; yvals = linspace(yax(1),yax(2),ny) ;
      ran=0.2; xran=[obj.LaserPosition_img(1)-ran obj.LaserPosition_img(1)+ran]; yran=[obj.LaserPosition_img(2)-ran obj.LaserPosition_img(2)+ran];
      xran(1)=max([xran(1) xax(1)]); xran(2)=min([xran(2) xax(2)]); yran(1)=max([yran(1) yax(1)]); yran(2)=min([yran(2) yax(2)]);
      if obj.State ~= CathodeServicesState.Standby_opslasermode % only use local fitting for small spots
        xcut=xvals>xran(1) & xvals<xran(2); ycut=yvals>yran(1) & yvals<yran(2);
        xproj=sum(img,1); yproj=sum(img,2);
        try
          [~,q]=gauss_fit(xvals(xcut),xproj(xcut)); obj.LaserSpotSize(1)=obj.std2fwhm*abs(q(4))*1000; obj.LaserPosition_img(1)=q(3); imgstats.x=q;
          [~,q]=gauss_fit(yvals(ycut),yproj(ycut)); obj.LaserSpotSize(2)=obj.std2fwhm*abs(q(4))*1000; obj.LaserPosition_img(2)=q(3); imgstats.y=q;
          obj.ImageIntensity = q(2)/100 ;
        catch
          fprintf('Gauss fit fail, using EPICS spot size values\n');
        end
      end
      
      % Calculate Laser Fluence
      obj.LaserFluence = 1e6 * obj.LaserEnergy / prod(obj.LaserSpotSize) ;
      
      % Write to PVs
      caput(obj.pvs.CCD_xspotsize_out,double(obj.LaserSpotSize(1)));
      caput(obj.pvs.CCD_yspotsize_out,double(obj.LaserSpotSize(2)));
      caput(obj.pvs.CCD_xpos_out,double(obj.LaserPosition_img(1)));
      caput(obj.pvs.CCD_ypos_out,double(obj.LaserPosition_img(2)));
      caput(obj.pvs.CCD_intensity_out,double(obj.ImageIntensity));
      % Write to GUI
      obj.gui.EditField_11.Value=double(obj.LaserPosition_img(1));
      obj.gui.EditField_12.Value=double(obj.LaserPosition_img(2));
      obj.gui.EditField_4.Value=double(obj.ImageIntensity);
      obj.gui.ImageIntensityGauge.Value=double(obj.ImageIntensity);
      lims=obj.pvs.CCD_intensity.limits;
      if ~isempty(lims)
        if obj.ImageIntensity<lims(1) || obj.ImageIntensity>lims(2)
          obj.gui.EditField_4.BackgroundColor=[0.7 0 0];
          obj.gui.ImageIntensityGauge.BackgroundColor=[0.7 0 0];
        else
          obj.gui.EditField_4.BackgroundColor=[0 0 0];
          obj.gui.ImageIntensityGauge.BackgroundColor=[1 1 1];
        end
      end
      lims=obj.pvs.CCD_spotsize.limits;
      obj.gui.LaserSpotSizeX.Value = double(round(obj.LaserSpotSize(1))) ;
      obj.gui.LaserSpotSizeY.Value = double(round(obj.LaserSpotSize(2))) ;
      obj.gui.LaserSpotSizeGaugeX.Value = double(round(obj.LaserSpotSize(1))) ;
      obj.gui.LaserSpotSizeGaugeY.Value = double(round(obj.LaserSpotSize(2))) ;
      if ~isempty(lims)
        rng=range(lims);
        gp=GUI_PREFS;
        ext=gp.gaugeLimitExtension;
        scalelims=[lims(1)-rng*ext(1),lims(1);lims(1),lims(2);lims(2),lims(2)+rng*ext(2)];
        obj.gui.LaserSpotSizeGaugeX.Limits=double([min(scalelims(:)),max(scalelims(:))]);
        obj.gui.LaserSpotSizeGaugeY.Limits=double([min(scalelims(:)),max(scalelims(:))]);
        obj.gui.LaserSpotSizeGaugeX.ScaleColors=gp.gaugeCol;
        obj.gui.LaserSpotSizeGaugeX.ScaleColorLimits=double(scalelims);
        obj.gui.LaserSpotSizeGaugeY.ScaleColors=gp.gaugeCol;
        obj.gui.LaserSpotSizeGaugeY.ScaleColorLimits=double(scalelims);
        if obj.gui.LaserSpotSizeX.Value<lims(1) || obj.gui.LaserSpotSizeX.Value>lims(2)
          obj.gui.LaserSpotSizeX.BackgroundColor=[0.7 0 0];
          obj.gui.LaserSpotSizeGaugeX.BackgroundColor=[0.7 0 0];
        elseif obj.gui.LaserSpotSizeX.Editable
          obj.gui.LaserSpotSizeX.BackgroundColor=[1 1 1];
          obj.gui.LaserSpotSizeGaugeX.BackgroundColor=[1 1 1];
        else
          obj.gui.LaserSpotSizeX.BackgroundColor=[0 0 0];
          obj.gui.LaserSpotSizeGaugeX.BackgroundColor=[1 1 1];
        end
        if obj.gui.LaserSpotSizeY.Value<lims(1) || obj.gui.LaserSpotSizeY.Value>lims(2)
          obj.gui.LaserSpotSizeY.BackgroundColor=[0.7 0 0];
          obj.gui.LaserSpotSizeGaugeY.BackgroundColor=[0.7 0 0];
        elseif obj.gui.LaserSpotSizeY.Editable
          obj.gui.LaserSpotSizeY.BackgroundColor=[1 1 1];
          obj.gui.LaserSpotSizeGaugeY.BackgroundColor=[1 1 1];
        else
          obj.gui.LaserSpotSizeY.BackgroundColor=[0 0 0];
          obj.gui.LaserSpotSizeGaugeY.BackgroundColor=[1 1 1];
        end
      end
      
      % Normalize image intensity
      if obj.imgnormalize == "LaserEnergy"
        img=double(obj.LaserEnergy).*(double(img)./double(max(img(:))));
      else
        img=double(obj.ImageIntensity).*(double(img)./double(max(img(:))));
      end
      
      
      % If automated program running, integrate image -> abort if max integrated signal goes above ImageCIntMax threhold
      if isautopattern(obj.State) && obj.pvs.laser_shutterStatOut.val{1}
        if isempty(obj.pimg) || ~isequal(size(img),size(obj.pimg))
          obj.pimg=img;
        else
          % Integrate image over top 10% of intensity distribution (approx the area that is responsible for cleaning)
          img_clean = img ;
          cx = obj.LaserPosition_img(1) ; cy = obj.LaserPosition_img(2) ;
          zeroimg = {xvals <= cx-obj.CleaningStepSize*1e3 | xvals >= cx+obj.CleaningStepSize*1e3 ; yvals <= cy-obj.CleaningStepSize*1e3 | yvals >= cy+obj.CleaningStepSize*1e3} ;
          img_clean(:,zeroimg{1}) = 0 ;
          img_clean(zeroimg{2},:) = 0 ;
          try
            obj.pimg=obj.pimg+img_clean;
          catch ME
            throw(ME);
          end
        end
        % If QE Mapping, integrate charge and laser data here
        if obj.State == CathodeServicesState.QEMap_linescan
          imref = double(img)./max(double(img(:))) ;
          if isempty(obj.qint_f)
            obj.qint_f = imref.*double(obj.pvs.fcup_val.val{1}) ;
            obj.qint_t = imref.*double(obj.pvs.torr_val.val{1}) ;
            obj.lint = imref.*double(obj.pvs.laser_energy.val{1}) ;
          else
            obj.qint_f = obj.qint_f + imref.*double(obj.pvs.fcup_val.val{1}) ;
            obj.qint_t = obj.qint_t + imref.*double(obj.pvs.torr_val.val{1}) ;
            obj.lint = obj.lint + imref.*double(obj.pvs.laser_energy.val{1}) ;
          end
        end
      end
      % Present integrated image for display if appropriate
      if ~isempty(obj.pimg)
        if obj.State==CathodeServicesState.Cleaning_linescan || obj.State==CathodeServicesState.Cleaning_movingtonewline || obj.State==CathodeServicesState.Cleaning_definearea
          img=obj.pimg;
        elseif obj.State==CathodeServicesState.QEMap_linescan || obj.State==CathodeServicesState.QEMap_movingtonewline || obj.State==CathodeServicesState.QEMap_definearea
          if obj.gui.UseLaserDataSwitch.Value=='L'
            src = obj.lint ;
          else
            src = double(obj.pimg) ;
          end
          if obj.gui.UseTorroidDataSwitch.Value=='F'
            qdat = obj.qint_f ;
          else
            qdat = obj.qint_t ;
          end
          src(src==0)=1; % protect agains divide by 0 errors
          img = qdat ./ src ;
        end
      end
      
    end
    function imdraw(obj,axhan)
      %IMDRAW VCC image drawing routine
      persistent tic_img tic_cmp lastimcount lastax
      
      if isequal(axhan,'reset')
        lastax=[];
        return
      end
      
      imdrawn=false;
      xax=[obj.pvs.CCD_x1.val{1} obj.pvs.CCD_x2.val{1}].*1e-3; yax=[obj.pvs.CCD_y1.val{1} obj.pvs.CCD_y2.val{1}].*1e-3; % Axis ranges
      if obj.imupdate || isempty(lastimcount) || obj.pvs.CCD_counter.val{1}~=lastimcount
        
        % Update array size to get if required
        [nx,ny,img,imgstats] = obj.getimg ;
        
        % Update image in axes window at imupdate rate if intensity above threshold
        xdata = linspace(xax(1),xax(2),nx) ; ydata = linspace(yax(1),yax(2),ny) ;
        if obj.imupdate || isempty(tic_img) || ( ( obj.ImageIntensity > obj.ImageIntensityRange(1) ) && toc(tic_img)>1/obj.imudrate )
          tic_img = tic ;
          if isempty(lastax) || ~isequal(lastax,[nx ny xax yax]) || obj.imupdate
            hold(axhan,'off');
            cla(axhan);
            axis(axhan,[xax yax]),hold(axhan,'on')
            imagesc(axhan,img,'XData',xdata,'YData',ydata); xlabel(axhan,'X [mm]'); ylabel(axhan,'Y [mm]');
            axis(axhan,'image');
            try
              colormap(axhan,obj.imagemap);
            catch
              colormap(axhan,"jet");
            end
          else
            if length(axhan.Children)>1
              delete(axhan.Children(1:end-1));
            end
            axhan.Children(end).CData=img;
          end
          lastax=[nx ny xax yax];
          lastimcount=obj.pvs.CCD_counter.val{1};
          grid(axhan,'on'); axhan.Layer='top';
        end
        imdrawn=true;
      end

      % Draw on complications
      if imdrawn || isempty(tic_cmp) || toc(tic_cmp)>1/obj.imudrate
        tic_cmp = tic ;
        if length(axhan.Children)>1
          delete(axhan.Children(1:end-1));
        end
        hold(axhan,'on');
        % Draw on Gaussian fits if requested
        if obj.showimgstats && ~isempty(imgstats)
%           y = A + B*exp( -(x-C)^2/2*D^2 )
          q=imgstats.x; imx = range(ydata)*0.9; gval = abs( q(1) + q(2)*exp( -(xdata-q(3)).^2./(2.*q(4).^2)) ) ;
          plot(axhan,xdata,ydata(1) + imx.*gval./max(gval),'r') ;
          qx=q;
          q=imgstats.y; imx = range(xdata)*0.9; gval = abs( q(1) + q(2)*exp( -(ydata-q(3)).^2./(2.*q(4).^2)) ) ;
          qy=q;
          plot(axhan,xdata(1) + imx.*gval./max(gval),ydata,'r') ;
          text(axhan,xdata(1)+range(xdata)*0.05,ydata(1)+range(ydata)*0.95,sprintf('sigma_x = %g sigma_y = %g [um]',qx(4)*1e3,qy(4)*1e3),'Color','red','FontSize',16)
          text(axhan,xdata(1)+range(xdata)*0.05,ydata(1)+range(ydata)*0.85,sprintf('FWHM_x = %g FWHM_y = %g [um]',qx(4)*1e3*obj.std2fwhm,qy(4)*1e3*obj.std2fwhm),'Color','red','FontSize',16)
        end
        % Plot expected positions
        plot(axhan,obj.LaserPosition_mot(1),obj.LaserPosition_mot(2),'rx','MarkerSize',12,'LineWidth',1); % position from laser mirrors
        xp=obj.LaserPosition_img(1); yp=obj.LaserPosition_img(2);
        if xp<xax(1); xp=xax(1); end
        if xp>xax(2); xp=xax(2); end
        if yp<yax(1);yp=yax(1); end
        if yp>yax(2);yp=yax(2); end
        plot(axhan,xp,yp,'w.','MarkerSize',20); % centroid calculated by EPICS based on image
        if uint8(obj.State)>1 % for all states other than standby, draw cleaning areas
          % Draw circle showing cleaning area and rectangles showing test and energy set patterns
          if isqemapstate(obj.State)
            xc=obj.MapCenter(1); yc=obj.MapCenter(2);
            r=obj.MapRadius.*1e3;
            ssize=obj.MapStepSize.*1e3*5;
          else
            xc=obj.CleaningCenter(1); yc=obj.CleaningCenter(2);
            r=obj.CleaningRadius.*1e3;
            ssize=obj.CleaningStepSize.*1e3*5;
          end
          x0=xc-r; y0=yc-r;
          % Cleaning area
          rectangle(axhan,'Position',[x0,y0,2*r,2*r],'Curvature',1,'EdgeColor','w','LineWidth',3,'LineStyle','-');
          adist=obj.AcclDist;
          rectangle(axhan,'Position',[x0-adist(1),y0-adist(2),2*(r+adist(1)),2*(r+adist(2))],'Curvature',1,'EdgeColor','k','LineWidth',2,'LineStyle','-.');
          plot(axhan,xc,yc,'k+','MarkerSize',20,'LineWidth',3);
          if isqemapstate(obj.State)
            obj.Proc_QEMap("SetBoundary",[x0,y0,2*r,2*r]);
          else
            obj.Proc_Cleaning("SetBoundary",[x0,y0,2*r,2*r]);
          end
          % Energy determination square pattern outside cleaning area
          rectangle(axhan,'Position',[x0-ssize,y0-ssize,2*r+2*ssize,2*r+2*ssize],'EdgeColor','k','LineWidth',2,'LineStyle','--');
          % Test square pattern inside cleaning area
          xt=sqrt((2*r)^2/2)-ssize;
          rectangle(axhan,'Position',[xc-xt/2,yc-xt/2,xt,xt],'EdgeColor','k','LineWidth',2,'LineStyle','--');
          if ~isqemapstate(obj.State)
            obj.Proc_Cleaning_testpattern("SetTestBoundary",[xc-xt/2,yc-xt/2,xt,xt]);
            obj.Proc_Cleaning_testpattern("SetEnergyBoundary",[x0-ssize,y0-ssize,2*r+2*ssize,2*r+2*ssize]);
          end
        end
        if ~isempty(obj.gui) && imdrawn
%           drawnow limitrate
        end
      elseif imdrawn && ~isempty(obj.gui)
%         drawnow limitrate
      end
      obj.imupdate = false ;
    end
  end
  methods(Static,Hidden)
    function ShowMessage(msg,title)
      % SHOWMESSAGE Display a message in a popup text area
      % ShowMessage(message_text,title)
      border=20;
      uf=uifigure('Name',title);
      uitextarea(uf,'Position',[border border uf.Position(3:4)-border*2],'Value',msg);
    end
    function [inerr,inerr_tries] = procerr(ierr,maxerrtries,inerr,inerr_tries)
      if inerr_tries(ierr)>=maxerrtries(ierr)
        inerr(ierr) = true ;
        inerr_tries(ierr)=0; % reset try count on error
      else
        inerr_tries(ierr)=inerr_tries(ierr)+1;
      end
    end
  end
end

