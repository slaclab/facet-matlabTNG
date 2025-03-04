function LaserS20_nonBSA_List = nonBSA_List_LaserS20()

LaserS20_nonBSA_List = {...
'DO:LA20:10:Bo1'; % laser shutter
'PMTR:LA20:10:PWR'; % power meter
'XPS:LA20:LS24:M1'; % waveplate
'XPS:LA20:LS24:M2'; % waveplate too
'XPS:LA20:LS24:M8'; % oscillator motor
'OSC:LA20:10:FS_TGT_TIME'; % vitara target time
'OSC:LA20:10:FS_CTR_TIME'; % counter target time
'TRIG:LA20:LS25:TCTL'; % sdg gate enable (pulse
'TRIG:LA20:LS28:TDES'; % saga timing
'SIOC:SYS1:ML02:AO502'; % long delay laser target time
'ADC:LA20:10:CALC:CH03'; % Laser energy in S20 laser room
'TRIG:LT20:PM07:2:TDES'; % Regen camera timing

'MOTR:LI20:MC06:M0:CH1:MOTOR'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:M0:CH2:MOTOR'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:M0:CH3:MOTOR'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:M0:CH4:MOTOR'; % S20 LASER ROOM pico

'MOTR:LI20:MC06:S1:CH1:MOTOR'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S1:CH2:MOTOR'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S1:CH3:MOTOR'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S1:CH4:MOTOR'; % S20 LASER ROOM pico

'MOTR:LI20:MC06:S2:CH1:MOTOR'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S2:CH2:MOTOR'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S2:CH3:MOTOR'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S2:CH4:MOTOR'; % S20 LASER ROOM pico

'MOTR:LI20:MC06:S3:CH1:MOTOR'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S3:CH2:MOTOR'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S3:CH3:MOTOR'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S3:CH4:MOTOR'; % S20 LASER ROOM pico

'MOTR:LI20:MC06:S4:CH1:MOTOR'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S4:CH2:MOTOR'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S4:CH3:MOTOR'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S4:CH4:MOTOR'; % S20 LASER ROOM pico

'MOTR:LI20:MC06:S5:CH1:MOTOR'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S5:CH2:MOTOR'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S5:CH3:MOTOR'; % S20 LASER TRANSPORT pico
'MOTR:LI20:MC06:S5:CH4:MOTOR'; % S20 LASER TRANSPORT pico

'MOTR:LI20:MC07:M0:CH1:MOTOR'; % S20 LASER TRANSPORT pico
'MOTR:LI20:MC07:M0:CH2:MOTOR'; % S20 LASER TRANSPORT pico
'MOTR:LI20:MC07:M0:CH3:MOTOR'; % S20 LASER TRANSPORT pico
'MOTR:LI20:MC07:M0:CH4:MOTOR'; % S20 LASER TRANSPORT pico

'MOTR:LI20:MC07:S1:CH1:MOTOR'; % S20 LASER TRANSPORT pico
'MOTR:LI20:MC07:S1:CH2:MOTOR'; % S20 LASER TRANSPORT pico



'MOTR:LI20:MC06:M0:CH1:MOTOR.RBV'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:M0:CH2:MOTOR.RBV'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:M0:CH3:MOTOR.RBV'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:M0:CH4:MOTOR.RBV'; % S20 LASER ROOM pico

'MOTR:LI20:MC06:S1:CH1:MOTOR.RBV'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S1:CH2:MOTOR.RBV'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S1:CH3:MOTOR.RBV'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S1:CH4:MOTOR'; % S20 LASER ROOM pico

'MOTR:LI20:MC06:S2:CH1:MOTOR.RBV'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S2:CH2:MOTOR.RBV'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S2:CH3:MOTOR.RBV'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S2:CH4:MOTOR.RBV'; % S20 LASER ROOM pico

'MOTR:LI20:MC06:S3:CH1:MOTOR.RBV'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S3:CH2:MOTOR.RBV'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S3:CH3:MOTOR.RBV'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S3:CH4:MOTOR.RBV'; % S20 LASER ROOM pico

'MOTR:LI20:MC06:S4:CH1:MOTOR.RBV'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S4:CH2:MOTOR.RBV'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S4:CH3:MOTOR.RBV'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S4:CH4:MOTOR.RBV'; % S20 LASER ROOM pico

'MOTR:LI20:MC06:S5:CH1:MOTOR.RBV'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S5:CH2:MOTOR.RBV'; % S20 LASER ROOM pico
'MOTR:LI20:MC06:S5:CH3:MOTOR.RBV'; % S20 LASER TRANSPORT pico
'MOTR:LI20:MC06:S5:CH4:MOTOR.RBV'; % S20 LASER TRANSPORT pico

'MOTR:LI20:MC07:M0:CH1:MOTOR.RBV'; % S20 LASER TRANSPORT pico
'MOTR:LI20:MC07:M0:CH2:MOTOR.RBV'; % S20 LASER TRANSPORT pico
'MOTR:LI20:MC07:M0:CH3:MOTOR.RBV'; % S20 LASER TRANSPORT pico
'MOTR:LI20:MC07:M0:CH4:MOTOR.RBV'; % S20 LASER TRANSPORT pico

'MOTR:LI20:MC07:S1:CH1:MOTOR.RBV'; % S20 LASER TRANSPORT pico
'MOTR:LI20:MC07:S1:CH2:MOTOR.RBV'; % S20 LASER TRANSPORT pico
};
