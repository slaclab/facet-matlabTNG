% Script to take data whilst laser cleaning process is taking place

context = PV.Initialize(PVtype.EPICS) ;
%       context = PV.Initialize(PVtype.EPICS_labca) ;
%       cname = "PROF:IN10:241:" ;
cname = "CAMR:LT10:900:" ;
pvlist=[PV(context,'name',"CCD_img",'pvname',cname+"Image:ArrayData"); % CCD camera image
  PV(context,'name',"CCD_spotsize_x",'pvname',"SIOC:SYS1:ML00:AO348",'monitor',true); % x Laser spot size (um FWHM)
  PV(context,'name',"CCD_spotsize_y",'pvname',"SIOC:SYS1:ML00:AO349",'monitor',true); % y Laser spot size (um FWHM)
  PV(context,'name',"CCD_xpos",'pvname',"SIOC:SYS1:ML00:AO358",'monitor',true); % Output of locally calculated X laser spot position [mm]
  PV(context,'name',"CCD_ypos",'pvname',"SIOC:SYS1:ML00:AO359",'monitor',true); % Output of locally calculated Y laser spot position [mm]
  PV(context,'name',"laser_shutterStatIn",'pvname',"SHUT:LT10:950:IN_MPS.RVAL",'monitor',true); % Laser MPS shutter IN status
  PV(context,'name',"laser_energy",'pvname',"LASR:LT10:930:PWR",'monitor',true); % Laser energy readout (uJ)
  PV(context,'name',"laser_energy_filtered",'pvname',"IN10_CATHODESUPPORT:LaserPwrFiltered",'monitor',true); % Laser energy readout (uJ)
  PV(context,'name',"gun_vacuum",'pvname',"VGCC:IN10:113:P",'monitor',true,'conv',1e9); % Vacuum pressire for gun [nTorr]
  PV(context,'name',"CCD_intensity",'pvname',"SIOC:SYS1:ML00:AO360",'monitor',true); % intensity of laser spot on CCD
  PV(context,'name',"epicsintensity",'pvname',cname+"Stats:MaxValue_RBV",'monitor',true)]; % intensity of laser spot on CCD
pset(pvlist,'debug',0) ;

pvs = struct(pvlist) ;

rate=5; % approx data taking rate [Hz]
dtime=250; % max time in mins to be taking data
ndat=dtime*rate*60;
xv=nan(1,ndat); yv=xv; ss_x=xv; ss_y=xv; int=xv; shut=xv; lener=xv; vac=xv; int_epics=xv; lenerf=xv;
ind=1;
caget(pvlist);
run(pvlist,true,1/(3*rate));
while ind<=ndat
  t0=tic;
  xv(ind)=pvs.CCD_xpos.val{1};
  yv(ind)=pvs.CCD_ypos.val{1};
  ss_x(ind)=pvs.CCD_spotsize_x.val{1};
  ss_y(ind)=pvs.CCD_spotsize_y.val{1};
  int(ind)=pvs.CCD_intensity.val{1};
  shut(ind)=pvs.laser_shutterStatIn.val{1};
  lener(ind)=pvs.laser_energy.val{1};
  lenerf(ind)=pvs.laser_energy_filtered.val{1};
  vac(ind)=pvs.gun_vacuum.val{1};
  int_epics(ind)=pvs.epicsintensity.val{1};
  ind=ind+1;
  t1=toc(t0);
  if t1<(1/rate)
    pause((1/rate)-t1);
  end
end
