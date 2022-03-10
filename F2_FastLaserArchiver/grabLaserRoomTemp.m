function temperature = grabLaserRoomTemp(UserData,camNum)

camName = UserData.camerapvs{camNum};

if regexp(camName,'CAMR:LT10:500') % S10 Oscillator camera
     tempsensor{1} = 'LASR:LR10:1:OSCILATOR';
     tempsensor{2} = 'LASR:LR10:1:OSC_BASEPLATE1';
     tempsensor{3} = 'LASR:LR10:1:OSC_BASEPLATE2';
end

if regexp(camName,'CAMR:LT10:600') % S10 Regen camera
     tempsensor{1} = 'LASR:LR10:1:REGEN';
     tempsensor{2} = 'LASR:LR10:1:REGENVO';
     tempsensor{3} = 'LASR:LR10:1:REGEN_MOUNT1';
     tempsensor{4} = 'LASR:LR10:1:REGEN_MOUNT2';
end

if regexp(camName,'CAMR:LT10:800') % S10 MPA output camera
tempsensor{1} = 'LASR:LR10:1:MPA';
tempsensor{2} = 'LASR:LR10:1:MPA1EVO';
tempsensor{3} = 'LASR:LR10:1:MPA2EVO';
tempsensor{4} = 'LASR:LR10:1:MPA_MOUNT1';
tempsensor{5} = 'LASR:LR10:1:MPA_MOUNT2';
end

if regexp(camName,'CAMR:LT10:700') % S10 Compressor Output camera
tempsensor{1} = 'LASR:LR10:1:TRIPLER';
end

if regexp(camName,'CAMR:LT10:200') % S10 UV output camera
tempsensor{1} = 'LASR:LR10:1:UVTELESCOPE_LENS';
tempsensor{2} = 'ROOM:LR10:1:AIRTEMP2';
tempsensor{3} = 'LASR:LR10:1:TABLETEMP4';
tempsensor{4} = 'LASR:LR10:1:TABLETEMP5';
end

if regexp(camName,'CAMR:LT10:380') % S10 UV iris camera
tempsensor{1} = 'LASR:LR10:1:TABLETEMP1';
tempsensor{2} = 'LASR:LR10:1:TABLETEMP2';
tempsensor{3} = 'LASR:LR10:1:TABLETEMP3';
tempsensor{4} = 'ROOM:LR10:1:AIRTEMP1';
end

if regexp(camName,'CAMR:LT10:450')
tempsensor{1} = 'LASR:LR10:1:TABLETEMP1';% C2F camera
end

if regexp(camName,'CAMR:LT10:900')
    tempsensor{1} = 'GUN:IN10:111:BDYTEMP3';%Gun temp
end

temperature = mean(lcaGetSmart(tempsensor));

