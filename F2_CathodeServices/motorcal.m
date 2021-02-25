function motorcal(dx,dy,cal)
%motorcal(dx,dy,cal) routine for setting up calibration constants and backlash correction
% dx,dy : requested moves in CCD image readback units (mm)
% cal : (x,y) calibration slopes from motor readback to CCD image position in mm

persistent context pvs

if isempty(context)
  context = PV.Initialize(PVtype.EPICS) ;
  cname = "CAMR:LT10:900:" ;
  mname = ["MIRR:LT10:750:M3_MOTR_H" "MIRR:LT10:750:M3_MOTR_V"];
  pvlist=[PV(context,'name',"CCD_xpos",'pvname',cname+"Stats:Xpos_RBV",'conv',0.001); % xpos on CCD [mm]
    PV(context,'name',"CCD_ypos",'pvname',cname+"Stats:Ypos_RBV",'conv',0.001); % ypos on CCD [mm]
    PV(context,'name',"lsr_posx",'pvname',mname(1)+".RBV"); % X Position readback for laser based on motors [mm]
    PV(context,'name',"lsr_posy",'pvname',mname(2)+".RBV"); % Y Position readback for laser based on motors [mm]
    PV(context,'name',"lsr_xmov",'pvname',mname(1),'mode','rw'); % X position move command for laser mirror [mm]
    PV(context,'name',"lsr_ymov",'pvname',mname(2),'mode','rw'); % Y position move command for laser mirror [mm]
    PV(context,'name',"lsr_motion",'pvname',mname+".DMOV",'pvlogic',"~&") ]; % Motion status for laser based on motors, true if in motion
  pset(pvlist,'debug',0) ;
  pvs = struct(pvlist) ;
end

% Get current motor reported position in CCD units
xm = caget(pvs.lsr_xmov)*cal(1) ;
ym = caget(pvs.lsr_ymov)*cal(2) ;

% Determine new position and send move command
xdes = xm + dx ;
ydes = ym + dy ;
x0 = caget(pvs.CCD_xpos) ;
y0 = caget(pvs.CCD_ypos) ;
caput(pvs.lsr_xmov,xdes/cal(1));
caput(pvs.lsr_ymov,ydes/cal(2));
pause(0.1);

% wait for motor to finish and see how we did
sval=caget(pvs.lsr_motion);
while sval{1}~=1 || sval{2}~=1
  sval=caget(pvs.lsr_motion);
  pause(1)
end
x1 = caget(pvs.CCD_xpos) ;
y1 = caget(pvs.CCD_ypos) ;
xerr = (x1-x0) - dx ; newcal_x = cal(1) * (1+xerr/dx) ;
yerr = (y1-y0) - dy ; newcal_y = cal(2) * (1+yerr/dy) ;
fprintf('Xerr = %g Yerr = %g (mm)\n',xerr,yerr);
fprintf('Suggested new cal constants: [%g %g]\n',newcal_x,newcal_y);
fprintf('Or, backlash = [%g %g]\n',xerr/cal(1),yerr/cal(2));
