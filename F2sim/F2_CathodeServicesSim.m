classdef F2_CathodeServicesSim < handle
  %F2_CATHODESERVICESSIM Simulation layer for Cathode Services software
  %  Designed to interface with FACET-II injector region simulated EPICS
  %  PVs and generate cathode VCC images which change with PV values
  
  properties
    SimVCC_mirrcal(1,4) single = [0,0,1,1] % Calibration mirror position to image position on VCC image [xpos,ypos,xscale,yscale] [mm]
    SimVCC_R(1,2) single {mustBePositive} = [10e-3,1.5e-3] % Radius of uv laser iris cut [m] in dimensions of VCC image plane (telescope [in,out])
    SimVCC_Rstd(1,2) single {mustBePositive} = [85e-6,2.7e-3] % RMS of gaussian distribution [m] in dimensions of VCC image plane (telescope [in,out])
    SimVCC_pixsize(1,1) single {mustBePositive} = 9.9e-6 % VCC pixel size [m]
    SimVCC_pixnoise uint16 = 2 % # rms [camera counts] noise floor to add
    SimVCC_laser2ccd single = 1 % conversion factor laser energy to peak CCD count (laser energy read in uJ)
    SimGunVacuum_pres(1,2) single = [0.01,0.1] % vacuum level [nTorr] = (1) + (2)*laser_energy_set
    SimGunVacuum_noise single = 0.05 % rms npose on pressure reading [nTorr]
    SimLaserEnergy_noise single = 1 % rms readback noise on laser energy [uJ]
    SimLaserPos_noise single = 10e-6 % rms position jitter on cathode from laser pointing [m]
    CCD_name string = "CAMR:LT10:900:" % Prefix of CCD PVs
    STDOUT = 1 % Standard echo output destination
    STDERR = 2 % Standard error output destination
    QEff=1e-4 % Quantum efficiency for cathode
  end
  properties(SetAccess=private)
    pvs % structure of PV objects
    SimRepRate single {mustBePositive} = 5 % simulated laser rep rate [Hz]
    pv_context
  end
  properties(SetAccess=private,Hidden)
    wtimer % Timer object attaches here
  end
  properties(Constant)
    SimVCC_nbin(1,2) uint16 {mustBePositive} = [656,492] % num x,y bins in image array
    version="1.0"
    laser_lam = 253e-9 % source laser wavelength [m]
    clight = 2.99792458e8
    h = 6.62607004e-34 % plank's constant
    qe=1.60217662e-19; % electron charge
  end
  
  methods
    function obj = F2_CathodeServicesSim()
      
      % labca setup and formation of PV list
%       lcaSetSeverityWarnLevel(14) ;
%       lcaSetSeverityWarnLevel(4) ;
      context = PV.Initialize(PVtype.EPICS) ;
      obj.pvs.CCD_stats = PV(context,'pvname',obj.CCD_name+"Stats:"+["EnableCallbacks" "ArrayCallbacks" "ComputeStatistics" "ComputeCentroid"]) ; % PVs to enable stats plugins
      obj.pvs.CCD_img = PV(context,'pvname',obj.CCD_name+"Image:ArrayData"); % CCD camera image
      obj.pvs.CCD_counter = PV(context,'pvname',obj.CCD_name+"ArrayCounter_RBV",'monitor',true) ; % Array counter- change triggers CCD image calc
      obj.pvs.CCD_acqperiod = PV(context,'pvname',obj.CCD_name+"AcquirePeriod") ;
      obj.pvs.CCD_intensity = PV(context,'pvname',"CAMR:LT10:900:Stats:MaxValue"); % intensity of laser spot on CCD
      obj.pvs.CCD_spotsize_x = PV(context,'pvname',"CAMR:LT10:900:Stats:SigmaX_mm_RBV"); % Laser spot size (stored in um rms)
      obj.pvs.CCD_spotsize_y = PV(context,'pvname',"CAMR:LT10:900:Stats:SigmaY_mm_RBV"); % Laser spot size (stored in um rms)
      obj.pvs.laser_shutterCtrl = PV(context,'pvname',"IOC:SYS1:MP01:MSHUTCTL.RVAL",'monitor',true) ;
      obj.pvs.laser_shutterStatIn = PV(context,'pvname',"SHUT:LT10:950:IN_MPS") ; % Laser MPS shutter IN status
      obj.pvs.laser_shutterStatOut = PV(context,'pvname',"SHUT:LT10:950:OUT_MPS") ; % Laser MPS shutter OUT status
      obj.pvs.laser_telescope = PV(context,'pvname',"LASR:LT10:100:TELE",'monitor',true) ;
      obj.pvs.laser_reprate = PV(context,'pvname',"LASR:LT10:REPRATE",'monitor',true) ;
      obj.pvs.CCD_nx = PV(context,'pvname',obj.CCD_name+"ArraySizeX_RBV",'monitor',true); % # x-axis data points in CCD image
      obj.pvs.CCD_ny = PV(context,'pvname',obj.CCD_name+"ArraySizeY_RBV",'monitor',true); % # y-axis data points in CCD image
      obj.pvs.CCD_x1 = PV(context,'pvname',obj.CCD_name+"ROI:MinX_mm_RBV"); % ROI limits [um]
      obj.pvs.CCD_y1 = PV(context,'pvname',obj.CCD_name+"ROI:MinY_mm_RBV"); % ROI limits [um]
      obj.pvs.CCD_x2 = PV(context,'pvname',obj.CCD_name+"ROI:MaxX_mm_RBV"); % ROI limits [um]
      obj.pvs.CCD_y2 = PV(context,'pvname',obj.CCD_name+"ROI:MaxY_mm_RBV"); % ROI limits [um]
      obj.pvs.CCD_res = PV(context,'pvname',obj.CCD_name+"RESOLUTION"); % ROI limits [um]
      obj.pvs.CCD_xpos = PV(context,'pvname',obj.CCD_name+"Stats:Xpos_RBV",'monitor',true); % xpos on CCD
      obj.pvs.CCD_ypos = PV(context,'pvname',obj.CCD_name+"Stats:Ypos_RBV",'monitor',true); % ypos on CCD
      obj.pvs.laser_energy_set = PV(context,'pvname',"LASR:LT10:930:PWR_SET",'monitor',true); % Laser energy setting (uJ)
      obj.pvs.gun_vacuum = PV(context,'pvname',"VGCC:IN10:113:P",'monitor',true,'conv',1e9);  % Vacuum pressire for gun [nTorr]
      obj.pvs.laser_energy = PV(context,'pvname',"LASR:LT10:930:PWR"); % Laser energy readout (uJ)
      obj.pvs.CCD_datatype = PV(context,'pvname',obj.CCD_name+"DataType",'monitor',true); % CCD camera data type
      obj.pvs.CCD_gain = PV(context,'pvname',obj.CCD_name+"Gain",'monitor',true); % CCD camera image gain factor
      obj.pvs.lsr_posx = PV(context,'pvname',"MIRR:LT10:770:M2_MOTR_H.RBV",'monitor',true); % X Position readback for laser based on motors
      obj.pvs.lsr_posy = PV(context,'pvname',"MIRR:LT10:770:M2_MOTR_V.RBV",'monitor',true); % Y Position readback for laser based on motors
      obj.pvs.lsr_setposx = PV(context,'pvname',"MIRR:LT10:770:M2_MOTR_H",'monitor',true); % X Position set for M2 mirror
      obj.pvs.lsr_setposy = PV(context,'pvname',"MIRR:LT10:770:M2_MOTR_V",'monitor',true); % Y Position set for M2 mirror
      obj.pvs.lsr_xaccl = PV(context,'pvname',"MIRR:LT10:770:M2_MOTR_H.ACCL"); % X mirror move acceleration [mm/s/s]
      obj.pvs.lsr_yaccl = PV(context,'pvname',"MIRR:LT10:770:M2_MOTR_V.ACCL"); % Y mirror move acceleration [mm/s/s]
      obj.pvs.fcup_val = PV(context,'pvname',"FARC:IN10:241:VAL"); % Faraday cup reading
      obj.pvs.torr_val = PV(context,'pvname',"TORR:IN10:1:VAL"); % Torroid charge reading
      obj.pvs.fcup_stat = PV(context,'pvname',"FARC:IN10:241:PNEUMATIC",'monitor',true); % Faraday cup in/out status
      obj.pv_context = context ;
      fn=fieldnames(obj.pvs);
      for ifn=1:length(fn)
        obj.pvs.(fn{ifn}).debug = 0 ;
        caget(obj.pvs.(fn{ifn}));
      end
      
      % Initialize PVs and start internal timer
      caput(obj.pvs.lsr_setposx,3.5);
      caput(obj.pvs.lsr_setposy,2.5);
      caput(obj.pvs.CCD_res,double(obj.SimVCC_pixsize));
%       caput(obj.pvs.CCD_stats,1); % manually setting stats values in here, EPICS db not working now, clobbers CCD_intensity value
      caput(obj.pvs.CCD_nx,double(obj.SimVCC_nbin(1)));
      caput(obj.pvs.CCD_ny,double(obj.SimVCC_nbin(2)));
      caput(obj.pvs.CCD_x1,double(obj.SimVCC_pixsize*1e6));
      caput(obj.pvs.CCD_x2,obj.SimVCC_nbin(1)*double(obj.SimVCC_pixsize*1e6)); % PV in um units
      caput(obj.pvs.CCD_y1,double(obj.SimVCC_pixsize*1e6));
      caput(obj.pvs.CCD_y2,obj.SimVCC_nbin(2)*double(obj.SimVCC_pixsize*1e6)); % PV in um units
      caput(obj.pvs.laser_energy_set,30); % uJ
      caput(obj.pvs.lsr_xaccl,1); % 1 s acceleration time
      caput(obj.pvs.lsr_yaccl,1); % 1 s acceleration time
      obj.SetRepRate(obj.SimRepRate); % Starts internal timer function
      
    end
    function SetRepRate(obj,reprate)
      % SETREPRATE reprate / Hz
      if reprate<=0
        error('Set rep rate >0 Hz');
      end
      % Use ms precision for poll time
      reprate=single(round(reprate*1000)/1000);
      obj.SimRepRate=reprate;
      if ~isempty(obj.wtimer)
        obj.wtimer.stop;
        delete(obj.wtimer);
        obj.wtimer=[];
      end
      % Run timer at rep rate of laser
      obj.wtimer=timer('Period',double(round((1/reprate)*1000))/1000,'ExecutionMode','fixedRate','TimerFcn',@(~,~) obj.watchdog,'ErrorFcn',@(~,~) obj.watchdogStop);
      obj.wtimer.start;
      % Set areaDetector PVs
      caput(obj.pvs.laser_reprate,reprate);
      caput(obj.pvs.CCD_acqperiod,1/reprate);
    end
    function watchdog(obj,~,~)
      % Set MPS shutter in/out status
      shutin = caget(obj.pvs.laser_shutterCtrl) ;
      if shutin
        caput(obj.pvs.laser_shutterStatIn,'IS_IN');
        caput(obj.pvs.laser_shutterStatOut,'IS_NOT_OUT');
      else
        caput(obj.pvs.laser_shutterStatIn,'IS_NOT_IN');
        caput(obj.pvs.laser_shutterStatOut,'IS_OUT');
      end
      % Handle laser rep rate change
      reprate = caget(obj.pvs.laser_reprate) ;
      if reprate ~= obj.SimRepRate && reprate>0
        obj.SetRepRate(reprate);
        return
      end
      % Generate different data sets based on laser telescope being in/put
      teleIN = strcmp(caget(obj.pvs.laser_telescope),'IN') ;
      % Set laser energy readback value, including noise
      lasE = caget(obj.pvs.laser_energy_set) ;
      caput(obj.pvs.laser_energy,double(lasE+randn*obj.SimLaserEnergy_noise)) ;
       % Set Gun vacuum pressure, including noise
      vacpres=obj.SimGunVacuum_pres(1)+lasE*obj.SimGunVacuum_pres(2);
      vacpres=vacpres+randn*obj.SimGunVacuum_noise ;
      caput(obj.pvs.gun_vacuum,double(vacpres)./obj.pvs.gun_vacuum.conv);
      % only update CCD image if driver posts new image #
      imno_last=obj.pvs.CCD_counter.val;
      imno=caget(obj.pvs.CCD_counter);
      if isempty(imno_last) || imno~=imno_last{1}
        obj.SimGenVCC(teleIN); % Update VCC image
      end
    end
    function shutdown(obj)
      obj.wtimer.stop;
      delete(obj.wtimer);
      try
        waitfor(obj.wtimer);
      catch
      end
      obj.pv_context.close();
    end
    function watchdogStop(obj,~,~) % Actions to take if watchdog timer errors (which it should never do)
      fprintf(obj.STDERR,'%s: timer service crashed, restarting\n',datetime);
      obj.wtimer.start;
    end
    function SimGenVCC(obj,teleIN)
      %SIMGENVCC Generate VCC image based on EPICS PV settings
      
      % Generate image of cathode spot in camera pixel units, add noise to
      % read back laser positions
      nx = caget(obj.pvs.CCD_nx); ny = caget(obj.pvs.CCD_ny);
      x1 = caget(obj.pvs.CCD_x1)*1e-3; x2 = caget(obj.pvs.CCD_x2)*1e-3; % ->mm
      y1 = caget(obj.pvs.CCD_y1)*1e-3; y2 = caget(obj.pvs.CCD_y2)*1e-3; % ->mm
      if teleIN
        Rcut = obj.SimVCC_R(1)*1e3 ;
        Rstd = obj.SimVCC_Rstd(1)*1e3 ;
      else
        Rcut = obj.SimVCC_R(2)*1e3 ;
        Rstd = obj.SimVCC_Rstd(2)*1e3 ;
      end
      xran=linspace(x1,x2,nx);
      yran=linspace(y1,y2,ny);
      [X,Y] = meshgrid(xran, yran); XY = [X(:) Y(:)]; 
      
      % Generate truncated Gaussian image and add noise, write to array PV
      dtype = caget(obj.pvs.CCD_datatype) ;
      gain = caget(obj.pvs.CCD_gain) ;
      impk = caget(obj.pvs.laser_energy) * obj.SimVCC_laser2ccd * gain ;
      xpos = obj.SimVCC_mirrcal(1)+caget(obj.pvs.lsr_posx)*obj.SimVCC_mirrcal(3)+rand*obj.SimLaserPos_noise*1e3 ;
      ypos = obj.SimVCC_mirrcal(2)+caget(obj.pvs.lsr_posy)*obj.SimVCC_mirrcal(4)+rand*obj.SimLaserPos_noise*1e3 ;
      caput(obj.pvs.CCD_xpos,xpos*1e3); % um
      caput(obj.pvs.CCD_ypos,ypos*1e3); % um
      [~,Ri]=cart2pol(X-xpos,Y-ypos);
      img = mvnpdf(XY,[xpos,ypos],eye(2).*(Rstd.^2));
      img(Ri>Rcut) = 0;
      img=floor(impk.*(img./max(img(:))));
      img=img+randi(1+obj.SimVCC_pixnoise,size(img))-1;
      img = cast(img,lower(dtype)) ;
      caput(obj.pvs.CCD_intensity,max(img(:)));
      % Get rms quatities from FWHM cubic fit to radial distribution
      img(img<0.1*impk)=0;
      [sy,sx]=obj.ellipseFit(double(reshape(img,ny,nx)),ny,nx);
      dx=x2-x1; dy=y2-y1;
      caput(obj.pvs.CCD_spotsize_x,sx*dx*1e3);
      caput(obj.pvs.CCD_spotsize_y,sy*dy*1e3);
      caput(obj.pvs.CCD_img,double(img));
      % Write charge data to toroids/faraday cup
      Egam = (obj.h*obj.clight) / obj.laser_lam ; % energy of single laser photon
      lasE = caget(obj.pvs.laser_energy_set) * 1e-6 ;
      Nphot = lasE/Egam ;
      Qb = Nphot * obj.qe * obj.QEff *1e12 ; % Bunch charge / pC
      if strcmp(caget(obj.pvs.fcup_stat),'IN')
        caput(obj.pvs.fcup_val,Qb.*(1+randn*0.02)); % pC
      else
        caput(obj.pvs.fcup_val,rand.*2); % pC
      end
      caput(obj.pvs.torr_val,Qb.*(1+randn*0.02)); % pC
    end
  end
  methods(Hidden,Static)
    function [sigx,sigy]=ellipseFit(c,resx,resy,xbar,ybar)
      x=double(1:resx);
      y=double(1:resy)';
      c=double(c);
      norm=sum(c(:));
      if ~exist('xbar','var')
        ybar=sum(x*c)/norm;
        xbar=sum(c*y)/norm;
      end
      sigyy=sum(((x-ybar).*(x-ybar))*c)/norm;
      sigxx=sum(c*((y-xbar).*(y-xbar)))/norm;
%       sigxy=(x-ybar)*c*(y-xbar)/norm;
%       sig=[sigxx,sigxy;sigxy,sigyy];
      sigx=sqrt(sigxx)/resx;
      sigy=sqrt(sigyy)/resy;
%       theta=atan(2*sigxy/(sigyy-sigxx))/2;
%       sigaa=(sigx*sigx*cos(theta)*cos(theta)-sigy*sigy*sin(theta)*sin(theta))/cos(2*theta);
%       sigbb=(sigy*sigy*cos(theta)*cos(theta)-sigx*sigx*sin(theta)*sin(theta))/cos(2*theta);
%       siga  = sqrt(sigaa);
%       sigb  = sqrt(sigbb);
%       phi = 0:pi/100:2*pi;
%       a1 = siga*cos(phi);
%       b1 = sigb*sin(phi);
%       x1 = [cos(theta) sin(theta); -sin(theta) cos(theta)]*[a1; b1];
%       gplot1(1,:)=(x1(1,:).*resx+xbar);
%       gplot1(2,:)=(x1(2,:).*resy+ybar);
%       x1 = [cos(theta) sin(theta); -sin(theta) cos(theta)]*[-siga siga; 0 0];
%       gplot2(1,:)=(x1(1,:).*resx+xbar);
%       gplot2(2,:)=(x1(2,:).*resy+ybar);
%       x1 = [cos(theta) sin(theta); -sin(theta) cos(theta)]*[0 0; -sigb sigb];
%       gplot3(1,:)=(x1(1,:).*resx+xbar);
%       gplot3(2,:)=(x1(2,:).*resy+ybar);
    end
  end
end

