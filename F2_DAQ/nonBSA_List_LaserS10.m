function LaserS10_nonBSA_List = nonBSA_List_LaserS10()

LaserS10_nonBSA_List = {...
%'IOC:SYS1:MP01:MSHUTCTL';
'LASR:LT10:930:PWR';
%'WPLT:LT10:150:WP_ANGLE.RBV';
'WPLT:LT10:150:WP_ANGLE';% UV waveplate
'IRIS:LT10:330:MOTR_ANGLE';
% Laser heater stuff
'PMTR:HT10:950:PWR';%Power meter
'WPLT:HT10:150:WPA_ANGLE';% LH energy waveplate 
'WPLT:HT10:100:WPB_ANGLE'; % IR splitter before UV compressor
'WPLT:HT10:950:VHC_ANGLE';% LH polarization waveplate 
'LHDL:HT10:310:LHDL_MOTR ';% Laser heater delay stage
};