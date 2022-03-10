% Calibrates S10 laser energy on cameras to sum counts
% C Emma 01/26/2021
function energyOut=energyCalibration(handles,cameraNumber,energyIn) 
    energyOut = energyIn;% In case you have no energy calibration
        switch handles.cameraPVs{cameraNumber}
            case 'CAMR:LT10:500';% Oscillator Out
                %energyOut = 324/156*energyIn;% New since 09/25/2020
                energyOut = lcaGetSmart('SIOC:SYS1:ML02:AO023')*energyIn;% Update 10/2021
            case 'CAMR:LT10:600';% Regen Out
                %energyOut = 6.58e-2*energyIn-6.79e-2;% mJ
                energyOut = lcaGetSmart('SIOC:SYS1:ML02:AO024')*energyIn;
            case 'CAMR:LT10:800';% MPA out
                %energyOut = 1.5*energyIn;%mJ Updated 04/16/21
                energyOut = lcaGetSmart('SIOC:SYS1:ML02:AO025')*energyIn;
            case 'CAMR:LT10:700';% Compressor Out
                %energyOut = 0.32*energyIn;% mJ Updated 04/16/21
                energyOut = lcaGetSmart('SIOC:SYS1:ML02:AO026')*energyIn;
            case 'CAMR:LT10:200';% UV Conv Out
                %energyOut = 0.167*energyIn;% mJ - New Since 03/22/2021 
                energyOut = lcaGetSmart('SIOC:SYS1:ML02:AO027')*energyIn;
            case 'CAMR:LT10:380';% UV Iris Out
                %energyOut = 0.125*energyIn;% mJ - New Since 03/22/2021
                energyOut = lcaGetSmart('SIOC:SYS1:ML02:AO028')*energyIn;
            case 'CAMR:LT10:900'% VCC
                 %energyOut = 5.04e-2*energyIn;% mJ calibrated against LASR:LT10:930:PWR 03/17/2021
                 energyOut = lcaGetSmart('SIOC:SYS1:ML02:AO029')*energyIn;
            case 'CAMR:LT10:450'% Fake VCC
                %energyOut = 0.3113*energyIn;%Updated 04/16/21
                %energyOut = lcaGetSmart('SIOC:SYS1:ML02:AO024')*energyIn;
                energyOut = lcaGetSmart('SIOC:SYS1:ML02:AO030')*energyIn;
                 
        end        
end
