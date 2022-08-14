function S20_nonBSA_List = nonBSA_List_S20()

S20_nonBSA_List = {...
'XPS:LI20:MC01:M1'; % E12 Afterglow Injector
'XPS:LI20:MC01:M2'; % E11 Attenuator Rotation 1
'XPS:LI20:MC01:M3'; % IPOTR2P
'XPS:LI20:MC01:M4'; % E-Lanex
'XPS:LI20:MC01:M5'; % E8 E324 Delay
'XPS:LI20:MC01:M6'; % LFOV
'XPS:LI20:MC01:M7'; % DTOTR_X
'XPS:LI20:MC01:M8'; % DTOTR_Y

'XPS:LI20:MC02:M1'; % E14 Shadowgraphy Imaging
'XPS:LI20:MC02:M2'; % E10 Shadowgraphy Delay
'XPS:LI20:MC02:M3'; % E4 EOS Rotation 2
'XPS:LI20:MC02:M4'; % E2 EOS Translation 2
'XPS:LI20:MC02:M5'; % E7 EOS Delay
'XPS:LI20:MC02:M6'; % E16 PB NFF
'XPS:LI20:MC02:M7'; % SFQED EDC Horizontal
'XPS:LI20:MC02:M8'; % E5 EOS Rotation 3

'XPS:LI20:MC03:M1'; % PB10 USHM M2 Removal Stage
'XPS:LI20:MC03:M2'; % PB11 SFQED Target Vertical
'XPS:LI20:MC03:M3'; % PB12 SFQED Tower Mover
'XPS:LI20:MC03:M4'; % C1 E300/E301 Optic One Mover
'XPS:LI20:MC03:M5'; % SFQED EDC Vertical
'XPS:LI20:MC03:M6'; % C2 Grating Translation
'XPS:LI20:MC03:M7'; % E15 SFQED Focus Imaging 1
'XPS:LI20:MC03:M8'; % 

'XPS:LI20:MC04:M1'; % PB1 Lens Z Position Stage
'XPS:LI20:MC04:M2'; % PB2 Lens Vertical Stage
'XPS:LI20:MC04:M3'; % PB3 Lens Horizontal
'XPS:LI20:MC04:M4'; % PB4 EOS Assembly Removal
'XPS:LI20:MC04:M5'; % PB5 EOS Crystal Spacing
'XPS:LI20:MC04:M6'; % E1 EOS Translation 1
'XPS:LI20:MC04:M7'; % E6 EOS Rotation 4
'XPS:LI20:MC04:M8'; % E3 EOS Rotation 1

'XPS:LI20:MC05:M1'; % PB7 Target Mount Vertical
'XPS:LI20:MC05:M2'; % PB8 Target Mount Horizontal
'XPS:LI20:MC05:M3'; % PB9 Gas Jet Longitudinal
'XPS:LI20:MC05:M4'; % PB16 SFQED Assembly Removal
'XPS:LI20:MC05:M5'; % PB17 M3 Mover
'XPS:LI20:MC05:M6'; % PB18 Focus Imaging Vertical
'XPS:LI20:MC05:M7'; % E13 Ionizer Imaging
'XPS:LI20:MC05:M8'; % E9 Ionizer Delay

% E-320 motors start
'XPS:LI20:MC10:M1'; % E-320 alignment target (AT) up/down (vertical)
'XPS:LI20:MC10:M2'; % E-320 MO tower in/out
'XPS:LI20:MC10:M3'; % E-320 OAP assembly in/out
'XPS:LI20:MC10:M4'; % E-320 elliptical mirror in/out
'XPS:LI20:MC10:M5'; % E-320 MO tower up/down (vertical)

'MOTR:LI20:MC08:S6:CH1:MOTOR'; % AT focal
'MOTR:LI20:MC08:S6:CH2:MOTOR'; % AT horizontal
'MOTR:LI20:MC08:S6:CH3:MOTOR'; % MO focal
'MOTR:LI20:MC08:S6:CH4:MOTOR'; % MO horizontal

'MOTR:LI20:MC08:S7:CH1:MOTOR'; % OAP1 vertical rid
'MOTR:LI20:MC08:S7:CH2:MOTOR'; % OAP1 horizontal ril
'MOTR:LI20:MC08:S7:CH3:MOTOR'; % OAP1 vertical tilt riu (rid?)
'MOTR:LI20:MC08:S7:CH4:MOTOR'; % OAP1 horizontal tilt ril

'MOTR:LI20:MC08:S8:CH1:MOTOR'; % OAP1 focal
'MOTR:LI20:MC08:S8:CH2:MOTOR'; % OAP2 focal
'MOTR:LI20:MC08:S8:CH3:MOTOR'; % OAP2 horizontal
'MOTR:LI20:MC08:S8:CH4:MOTOR'; % OAP2 vertical
% E-320 motors end


'RADM:LI20:1:CH01:MEAS'; % Rad monitor IP
'RADM:LI20:2:CH01:MEAS'; % Rad monitor Dump table
'LION:LI20:3120:VACT'; % LI19-LION-3N
'LION:LI20:3121:VACT'; % LI19-LION-3S
'PICS:LI20:3485:VACT'; % LI19-FDMP-IC1
'PICS:LI20:3486:VACT'; % LI19-FDMP-IC2

'SIOC:SYS1:ML00:CALCOUT051'; % Spec Quad energy
'SIOC:SYS1:ML00:CALCOUT052'; % Spec Quad z obj
'SIOC:SYS1:ML00:CALCOUT053'; % Spec Quad z img
'SIOC:SYS1:ML00:CALCOUT054'; % Spec Quad M12
'SIOC:SYS1:ML00:CALCOUT055'; % Spec Quad M34
'SIOC:SYS1:ML00:CALCOUT056'; % Dipole Switch

'VGCM:LI20:M3201:P';%CM Gauge 1000 Torr
'VGCM:LI20:M3202:P';%CM Gauge 0.1 Torr
'VGCM:LI20:M3203:P';%CM Gauge 10 Torr
'VPTM:LI20:M3202:P';%fourth gauge

};
