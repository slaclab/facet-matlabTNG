DAQ_params = struct();

DAQ_params.experiment = 'TEST';

% Event Code/Data rate
DAQ_params.EC = 223;

% General Params
DAQ_params.comment = 'Test run from script';
DAQ_params.n_shot = 10;
DAQ_params.print2elog = true;
DAQ_params.saveBG = true;
DAQ_params.nBG = 1;

% Camera Parameters
DAQ_params.camNames = {'VCCF';'PR10571'};
DAQ_params.camPVs   = {'PROF:IN10:241';'PROF:IN10:571'};
DAQ_params.camSIOCs = {'SIOC:LR10:LS01';'SIOC:LI10:PM01'};
DAQ_params.camTrigs = {'CAMR:LT10:380:TCTL';'TRIG:LI10:PM02:0:TCTL'};
DAQ_params.num_CAM  = 2;

% Scalar data
DAQ_params.BSA_list = {'BSA_List_S10';'BSA_List_S10RF'};
DAQ_params.nonBSA_list = {'nonBSA_List_S10';'nonBSA_List_LaserS10'};
DAQ_params.include_nonBSA_arrays = false;

% Scan params
DAQ_params.scanDim = 1;
DAQ_params.scanFuncs = {'QUAD_IN10_525'};
DAQ_params.scanPVs = {'QUAD:IN10:525:BCTRL'};
DAQ_params.startVals = 1;
DAQ_params.stopVals = 5;
DAQ_params.nSteps = 5;
DAQ_params.totalSteps = 5;
DAQ_params.scanVals = {linspace(DAQ_params.startVals,DAQ_params.stopVals,DAQ_params.nSteps)};
DAQ_params.stepsAll = linspace(DAQ_params.startVals,DAQ_params.stopVals,DAQ_params.nSteps);

% Run DAQ
DAQ_obj = F2_runDAQ(obj.DAQ_params);