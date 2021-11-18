DAQ_params = struct();

DAQ_params.experiment = 'E327';

% Event Code/Data rate
DAQ_params.EC = 223;

% General Params
DAQ_params.comment = {'Test adaptive scan from script'};
DAQ_params.n_shot = 10;
DAQ_params.print2elog = true;
DAQ_params.saveBG = true;
DAQ_params.nBG = 1;

% Camera Parameters
DAQ_params.camNames = {'PR10571';};
DAQ_params.camPVs   = {'PROF:IN10:571';};
DAQ_params.camSIOCs = {'SIOC:LI10:PM01';};
DAQ_params.camTrigs = {'TRIG:LI10:PM02:0:TCTL';};
DAQ_params.num_CAM  = 1;

% Scalar data
DAQ_params.BSA_list = {'BSA_List_S10';'BSA_List_S10RF'};
DAQ_params.nonBSA_list = {'nonBSA_List_S10';'nonBSA_List_LaserS10'};
DAQ_params.include_nonBSA_arrays = false;

% Scan params
DAQ_params.scanDim = 1;

%DAQ_params.scanFuncs = {'QUAD_IN10_525'};
%DAQ_params.scanPVs = {'QUAD:IN10:525:BCTRL'};

DAQ_params.scanFuncs = {'ADAPT_QUAD_IN10_525'};
DAQ_params.scanPVs = {'QUAD:IN10:525:BCTRL'};


%DAQ_params.scanFuncs = {'Dummy_Scan'};
%DAQ_params.scanPVs = {'SIOC:SYS1:ML02:AO399'};

DAQ_params.startVals = -7;
DAQ_params.stopVals = -5;
DAQ_params.nSteps = 10;
DAQ_params.totalSteps = 10;
DAQ_params.scanVals = {linspace(DAQ_params.startVals,DAQ_params.stopVals,DAQ_params.nSteps)};
DAQ_params.stepsAll = (1:DAQ_params.nSteps)';

% Run DAQ
DAQ_obj = F2_runDAQ(DAQ_params);