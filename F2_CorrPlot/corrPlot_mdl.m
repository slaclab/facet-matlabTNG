classdef corrPlot_mdl < handle
    %CORRPLOT_MODEL 
    % Model class for corrPlot_gui. This class holds the corrPlot data and
    % configuration, and performs all back end operations. There are: 
    %   Init Methods:       called once on application opening
    %   Control Methods:    intermediary between "controller" and "view"
    %   Save/Load Methods:  Save or load app data or configuration
    %   Acquire Methods:    Control acquisition of data
    %   Plot Methods:       Perform computations for plotting of data
    %   Set Methods:        API for changing model properties
    %   Get Methods:        API for returning model data to the mlapp
    %   Misc Methods:       Assorted
    %   Static Methods:     Not dependent on model
    
    properties
         
        appName = 'Correlation Plot' % name of the app
        accelerator % accelerator active in current facility
        system % sys code for current facility
        constants
        sector % struct containing device lists for each index
        beampath % Injector/destination code
        index % Same as beampath, used to refer to indexList
        indexList = ... % list of all possible "indices", i.e., facilities and destinations
            {... % no switches by sector ({''}) only beampath (3rd column)
            'LCLS' {''} 'CU_HXR'; ...
            'LCLS' {''} 'CU_SXR'; ...
            'LCLS' {''} 'SC_DIAG0'; ...
            'LCLS' {''} 'SC_BSYD'; ...
            'FACET' {''} 'F2_ELEC'; ...
            'NLCTA' {''} 'NLCTA'; ...
            'XTA'   {''} 'XTA'; ...
            'ASTA'  {''} 'ASTA'; ...
            'PAL'   {''} 'PAL';
            }
        
        
        profmonId = 0 % idx in list of possible profile monitors
        profmonName = '' % name of currently selected profile monitor
        profmonList % list of usable profile monitors for current index
        profmonMap % index map that sorts master set of profile monitors by Z
        
        emitId = 0 % idx in list of possible emittance devices
        emitName = '' % name of currently selected emittance device
        emitList % list of usable emittance devices for current index
        emitMap % index map that sorts master set of emmitance devices by Z
        emitType % 'multi' or 'quad' for type of emittance measurement
        
        blenId = 0 % idx in list of possible bunch length monitors
        blenName = '' % name of currently selected bunch length monitor
        blenList % list of usable bunch length monitors for current index
        blenMap % index map that sorts master set of bunch length monitors by Z
        
        wireId = 0 % idx of possible wire scanners
        wireName = '' % name of currently selected wire scanner
        wireList % list of possible wire scanners for current idnex
        wireMap % index map that sorts master set of wire scanners by Z
        wirePlane % X or Y
                
        ctrlPV % control PV object
        ctrlPVFast % control PV object referencing the "fast", or 2nd control PV
        numCtrlPV = 0 % number of control PVs in use (0, 1, or 2)
        
        whichSample = 1 % index of which sample is indicated by the slider (between 1 and numSamples)
        ctrlMKBName = '' % name of multiknob file/PV indicator
        
        % struct containing PVs to read during data acquisition
        nameList = struct('readPV', [],... % PVs specifically indicated by user
                          'profPV', [],... % PVs made from profile monitor
                          'wirePV', [],... % PVs made from wire scanner
                          'emitPV', [],... % PVs made from emittance device
                          'blenPV', [],... % PVs made from bunch lenght monitor
                          'calcPV', [],... % Formula 
                          'metaDataPV', []) % PVs to be read once at the start of a scan
         
        % struct containing options for data acquisition
        acqOpt = struct('BSA', 0,... % 0 for non BSA, 1 if a BSA mode is selected
                        'numSamples', 1,... % number of samples to acquire per step
                        'sampleDelay', 0.1,... % delay between acquiring each sample
                        'randomOrder', 0,... % flag for a random acquisition (in regards to the ctrl PV vals)
                        'spiralOrder', 0,... % flag for a spiral acquisition
                        'zigzagOrder', 0,... % flag for a zig zag acquisition
                        'relative', [0, 0],... % flag for doing a relative scan
                        'sampleForce', 0,... % flag to force wire/emit/blen acqusition for each sample
                        'useLEM', 0,... % flag for whether or not to LEM each step
                        'waitInit', 1.,... % amount of time to wait between initial setting of ctrlPV and beginning acquisition
                        'pausePV', '',... % PV on that indicates when to pause/continue acquisition
                        'settlePV', '',...  % PV that indicates when to move on to next acquisition step
                        'acquireStatus', 0,... % indicator for whether acquisition is in progress
                        'abortStatus', 0) % indicator for whether acquisition was aborted
        
        % struct containing options for plotting
        plotOpt = struct('XAxisId', 0,... % idx of selected X axis variable
                         'YAxisId', 1,... % idx of selected Y axis variable
                         'UAxisId', 0,... % idx of selected U axis variable
                         'XAxisNameList', [],... % list of names for possible X axis variables
                         'YAxisNameList', [],... % list of names for possible Y axis variables
                         'UAxisNameList', [],... % list of names for possible U axis variables
                         'header', 'Correlation Plot',... % Title for the plot
                         'showFitOrder', 1,... % order to which to fit the data
                         'showFit', 'No Fit',... % type of fit
                         'show3D', 'No 3D',... % type of 3D plot
                         'showAverage', 0,... % flag for plotting the average of a set of samples
                         'showSmoothing', 0,... % flag for creating a convolution of the data
                         'defWindowSize', 5,... % size of window for smoothing convolution
                         'showLines', 0,... % flag to show lines between points on plot
                         'showLogX', 0,... % flag to plot the X variable on a log scale
                         'showLogY',0,... % flag to plot the Y variable on a log scale
                         'grid', 1,... % flag for a grid background on the plot
                         'XLabel', struct('name', 1, 'desc', 1, 'egu', 1),... % display settings for the X label of the plot
                         'YLabel', struct('name', 1, 'desc', 1, 'egu', 1),... % display settings for the Y label of the plot
                         'ULabel', struct('name', 1, 'desc', 1, 'egu', 1)) % display settings for the U label of the plot
             
        % struct containing options for image processing
        imgOpt = struct('axes', [],... % axes to which to plot the image
                        'useStaticBG', 0,... % flag for whether or not to use a background image
                        'numBG', 1,... % number of images to average for background
                        'numAve', 1,... % number of images to average
                        'useImgCrop', 1,... % flag for whether or not to crop the image
                        'useCal', 1,... % if 1, use calibration to convert pixels to mm
                        'XSig', 4.6,... % X field of view for profmon display
                        'YSig', 4.6,... % Y field of view for profmon display
                        'BSA', 0,... % flag for whether or not to acquire beam synchronous images, (i.e., read the image buffer)
                        'staticBG', 0,... % number of images to average for background
                        'saveImg', 0,... % flag for whether or not to save images
                        'showImg', 0,... % flag for whether or not to display profmon image in GUI
                        'holdImg', 1,... % flag for whether to retain image data
                        'procImg', 1,... % flag for whether or not to process images
                        'showAutoscale', 0,... % flag top autoscale the profmon bit depth
                        'grid', 1,... % flag for a grid background on the plot
                        'selectedMethod', 1,... % idx in methodList as indicated by user
                        'methodList', [],... % list of available image fit methods
                        'methodMap', []) % mapping of listed methods to available methods (see image analysis code)
                     
%   All  methods in appropriate order, kept for posterity
%{'gauss','asym','super','rms_raw','rms_cut_peak','rms_cut_area','rms_floor','gauss4th','doublegauss','superasym')
      
        % struct of status flags indicating a process is running or has
        % been completed
        process = struct('displayExport', 0,... % flag indicating whether to plot on external figure
                         'saved', 0,... % flag indicating whether data has been saved
                         'loading', 0,... % flag indicating whether loading is in process
                         'dataDisp', 0,... % flag indicating whether to display data in the workspace
                         'settingCtrlPV', 0,... % flag indicating if currently setting control pv
                         'settingCtrlPVFast', 0,... % flag indicating if currently setting fast control pv
                         'resettingCtrlPV', 0,... % flag indicating if currently resetting control pv
                         'resettingCtrlPVFast', 0) % flag indicating if currently resetting fast control pv
                     
                
        data = struct() % struct for holding scan data
        
        eDefName % name assigned to event definiton
        eDefNumber % event definition number
        
        beamRatePV % PV giving the beam rate
        beamOffPV %
        
        fileName % file to which data is saved
        
        readPVValid % bit array indicating whether read PVs are valid PV names (i.e. are able to be read)
        BSAPVValid % bit array indicating whether read PVs are BSA enabled
        readPVValidId % idx in data.readPV marking valid PVs
        
        fitPar % parameters from data fit
        plotDataParam = struct() % struct holding the plot data, for communication to the plot function in the view
        BSAOptions % options for BSA eDef
        exportFig % figure to be exported to logbook
        wikiURL = 'https://aosd.slac.stanford.edu/wiki/index.php/Correlation_Plots_GUI'
        status = ''% text indicating status of the GUI
    end
    
    
    
    properties (Access = private)
        % list of properties of model representing current
        % configuration, used for saving configuration
        configList = {'numCtrlPV', 'ctrlPV', 'ctrlPVFast', 'ctrlMKBName',...
            'nameList', 'plotOpt', 'acqOpt', 'profmonId', 'wireId', 'emitId', 'blenId', ...
            'profmonName', 'wireName', 'emitName', 'blenName', 'index', 'beampath'}
        
        % config list of old corrPlot_gui, used to read in older
        % configuration files
        configList_old = {'ctrlPVNum' 'ctrlPVName' 'ctrlMKBName' 'ctrlPVValNum' 'ctrlPVRange' 'ctrlPVWait' ...
            'waitInit' 'settlePVName' 'readPVNameList' 'plotHeader' 'acqOpt.numSamples' ...
            'showFit' 'showFitOrder' 'showAverage' 'showSmoothing' 'showWindowSize' ...
            'profmonId' 'wireId' 'plotXAxisId' 'plotYAxisId' 'plotUAxisId' ...
            'acquireBSA' 'profmonNumBG' 'profmonNumAve' 'emitId' 'show2D' 'acquireSampleDelay' ...
            'acquireRandomOrder' 'acquireSpiralOrder' 'acquireZigzagOrder' 'calcPVNameList' 'blenId' ...
            'profmonName' 'wireName' 'emitName' 'blenName' 'index' 'beampath'};
    end
    

    % events are used to communicate to the View that an action is ready to
    % be performed
    events( NotifyAccess = private )
         
        ctrlPVChanged 
        ctrlPVFastChanged
        ctrlPVSliderChanged
        ctrlPVFastSliderChanged
        plotDataReady
        plotProfileReady
        clearPlotAxes
        clearProfileAxes
        readPVListChanged
        BSAChanged
        indexControlChanged        
        profmonChanged
        emitChanged
        wireChanged
        blenChanged
        emitTypeChanged
        acqStatusChanged
        statusChanged
        samplesChanged
        ctrlPVSetStatusChanged
        useChanged
        plotOptChanged
        updateAxisDropDown
        configLoaded
        imgOptChanged
        dataMethodChanged
        staticBGChanged
        
    end
    
    methods % INIT METHODS
        
        function mdl = corrPlot_mdl(opts)
            %CORRPLOT_MODEL Construct an instance of this class
            mdlInit(mdl);
            if nargin > 0
                if isfield(opts, 'prof_ax')
                    mdl.imgOpt.axes = opts.prof_ax;
                end
                if isfield(opts, 'config')
                    configLoad(mdl, opts.config);
                end
            end
        end
        
        function mdlInit(mdl)
            % initialize model properties based on current conditions
            cancd = mdlDataRemove(mdl);
            if cancd, return; end
            [mdl.system, mdl.accelerator] = getSystem;
            mdl.constants = corrplot_constants();
            acquireInit(mdl);
            acquireReset(mdl);
            
            % import sector device information, set current sector
            mdl.sector = corrplot_initSectors();
            indexInit(mdl);
            indexControl(mdl);
            sectorControl(mdl);
            
            % set property defaults that cannot be set in the properties
            % section
            if strcmp(mdl.accelerator, 'LCLS')
                mdl.nameList.readPV = mdl.constants.defaultReadPVs.CU;
            else
                mdl.nameList.readPV = {};
            end
            mdl.imgOpt.methodList = mdl.constants.methodList;
            mdl.imgOpt.methodMap = mdl.constants.methodMap;
            readPVNameListControl(mdl, mdl.nameList.readPV);
        end
        
        function indexInit(mdl)
            % Initialize the index based on current environment
            
            % Get facility from host.
            [mdl.system, mdl.accelerator] = getSystem; % Save present state
            [~, accel] = getSystem(''); % Check for test env
            getSystem(mdl.accelerator); % Restore present state
            
            % Column 1 was originally both the facility and the label. Now want the
            % label to correspond to beampath where applicable.
            
            % Check if beampath column (3) specified, blank if not:
            if size(mdl.indexList, 2) < 3
                sysTest = cell(size(mdl.indexList, 1), 1);
                sysTest(:) = {''};
                mdl.indexList = [mdl.indexList, sysTest];
            end
            
            % Check for index label column (4) specified, create if not:
            if size(mdl.indexList,2) < 4
                % if beampath, use that
                mdl.indexList = [mdl.indexList, mdl.indexList(:,3)];
                % where empty, use facility
                ind = cellfun(@isempty, mdl.indexList(:,4));
                mdl.indexList(ind,4) = mdl.indexList(ind,1);
            end
            
            % Reduce index list to available facility.
            indexList2 = mdl.indexList;
            indexId2 = ismember(mdl.indexList(:,1), accel); % List of available facilities
            indexId = ismember(mdl.indexList(:,1), mdl.accelerator); % List of displayed facilities
            if ~any(indexId)
                indexId(:) = true;
                indexId2(:) = true;
            end
            if ~any(indexId & indexId2), indexId2 = indexId; end
            if ~isempty(accel)
                mdl.indexList(~indexId,:) = [];
                indexId(~indexId) = [];
                indexList2(~indexId2,:) = [];
            end
            
            % Select present facility or first in list.
            mdl.index = mdl.indexList{find(indexId,1),4};
            
            % Collect list of all sector names.
            mdl.sector.nameList = [indexList2{:,2}];
            
        end
        
    end
    
    methods % CONTROL METHODS
        
        function indexControl(mdl, index)
            % Set the index and beampath based on change in GUI settings
            
            cancd = mdlDataRemove(mdl);
            if ~cancd
                if nargin == 2, mdl.index = index; end
                % Set system & acscelerator for simul case.
                if size(mdl.indexList,1) > 1 && size(mdl.indexList,2) < 4
                    [mdl.system, mdl.accelerator] = getSystem(mdl.index);
                else
                    ind = find(strcmp(mdl.indexList(:,4), mdl.index), 1, 'first');
                    if isempty(ind), ind = 1; end
                    [mdl.system, mdl.accelerator] = getSystem(mdl.indexList(ind,1));
                end
                
                % Generate global PV names.
                accel = mdl.accelerator;
                if strcmp(accel,'FACET'), accel = ''; end
                mdl.beamRatePV = ['EVNT:' mdl.system ':1:' accel 'BEAMRATE'];
                mdl.beamOffPV = 'IOC:BSY0:MP01:PCELLCTL';
                % nate 6/25/14 hack to adapt to FACET e+ or e-
                if strcmp(mdl.accelerator, 'FACET')
                    mdl.beamRatePV = 'EVNT:SYS1:1:INJECTRATE'; % New PV for beam rate
                    %rate = lcaGetSmart({mdl.beamRatePV; 'EVNT:SYS1:1:POSITRONRATE'});
                    % Old nate code to compare to positron rate
                    %if rate(2)>rate(1)
                    %    mdl.beamRatePV = 'EVNT:SYS1:1:POSITRONRATE';
                    %end
                end
                
                % find and set the current beampath
                if size(mdl.indexList,2) == 4
                    ind = find(strcmp(mdl.indexList(:,4), mdl.index), 1, 'first');
                    if ~isempty(ind)
                        mdl.beampath = mdl.indexList{ind,3};
                    else
                        mdl.beampath = '';
                    end
                else
                    mdl.beampath = '';
                end
                
                % this is terrible, but will be hard to come up with
                % something better until we test the beam at higher rates
                if startsWith(mdl.index, 'SC')
                    mdl.BSAOptions = mdl.constants.BSAOptions.SC;
                    rate = getSCTimingActualRate(mdl.index);
                    if isnan(rate)
                        mdl.BSAOptions = mdl.BSAOptions(1); % 'None'
                    else
                        if rate < 1000
                            rateStr = sprintf('%dHz', rate);
                        elseif rate < 70000
                            rateStr = sprintf('%dkHz', rate/1000);
                        elseif rate < 100000
                            rateStr = '71.5kHz';
                        else
                            rateStr = '1MHz';
                        end
                        idx = find(contains(mdl.BSAOptions, rateStr));
                        mdl.BSAOptions = mdl.BSAOptions(1:idx);
                    end
                else
                    mdl.BSAOptions = mdl.constants.BSAOptions.CU;
                end
                
                if mdl.acqOpt.BSA
                    acquireBSAControl(mdl, 0);
                end
                
                % set appropriate devices for this index
                sectorControl(mdl);
            end
            notify(mdl, 'indexControlChanged');
        end
        
        function ctrlPVControl(mdl, fast, name, low, high, numvals, settletime)
            % respond to intialization or change of control PV
            if nargin < 7, settletime = 1; end
            if nargin < 6, numvals = 1; end
            if nargin < 5, high = 1; end
            if nargin < 4, low = 0; end
            
            % changing this setting will remove the data field, unless this
            % action is cancelled
            cancd = mdlDataRemove(mdl);
            if ~cancd
                valid = mdl.pvValidate(name);
                if ~valid
                    warndlg('Not a valid control PV');
                    return
                else
                    % create a ctrlPV object
                    if fast
                        if isempty(name)
                            mdl.ctrlPVFast = [];
                        else
                            mdl.ctrlPVFast = corrplot_ctrlPV(name, low, high, numvals, settletime, mdl.acqOpt.relative(2));
                        end
                    else
                        if isempty(name)
                            mdl.ctrlPV = [];
                        else
                            mdl.ctrlPV = corrplot_ctrlPV(name, low, high, numvals, settletime, mdl.acqOpt.relative(1));
                        end
                    end
                    mdl.numCtrlPV = ~isempty(mdl.ctrlPV) + ~isempty(mdl.ctrlPVFast);
                end
            end
            plotXAxisControl(mdl, {});
            notify(mdl, 'ctrlPVChanged');
            notify(mdl, 'ctrlPVFastChanged');
        end
        
        function rangeControl(mdl, low, high, fast)
            % respond to change in one of the control PV range properties
            
            % optional argument indicating which PV
            if nargin < 4, fast = 0; end
            
            % changing this setting will remove the data field, unless this
            % action is cancelled
            cancd = mdlDataRemove(mdl);
            if ~cancd
                
                % set the range of the ctrlPV object
                if fast && ~isempty(mdl.ctrlPVFast)
                    setRange(mdl.ctrlPVFast, low, high);
                elseif ~fast && ~isempty(mdl.ctrlPV)
                    setRange(mdl.ctrlPV, low, high);
                end
            end
            notify(mdl, 'ctrlPVChanged');
            notify(mdl, 'ctrlPVFastChanged');
        end
        
        function numvalsControl(mdl, numvals, fast)
            % respond to change in the control PV num vals property
            
            % optional argument indicating which PV
            if nargin < 3, fast = 0; end
            
            % changing this setting will remove the data field, unless this
            % action is cancelled
            cancd = mdlDataRemove(mdl);
            if ~cancd
                % set the numvals property of the ctrlPV
                if fast && ~isempty(mdl.ctrlPVFast)
                    setNumvals(mdl.ctrlPVFast, numvals);
                elseif ~fast && ~isempty(mdl.ctrlPV)
                    setNumvals(mdl.ctrlPV, numvals);
                end
            end
            notify(mdl, 'ctrlPVChanged');
            notify(mdl, 'ctrlPVFastChanged');
        end
        
        function settletimeControl(mdl, settletime, fast)
            % respond to change of control PV settle time property
            
            % optional argument indicating which PV
            if nargin < 3, fast = 0; end
            
            % set the settletime property of the ctrlPV
            if fast && ~isempty(mdl.ctrlPVFast)
                mdl.ctrlPVFast.settletime = settletime;
            elseif ~fast && ~isempty(mdl.ctrlPV)
                mdl.ctrlPV.settletime = settletime;
            end
            notify(mdl, 'ctrlPVChanged');
            notify(mdl, 'ctrlPVFastChanged');
        end
        
        function ctrlPVIdxControl(mdl, newidx, fast)
            % respond to change in the index of the control PV. The index
            % is used to point to which value in the vallist is currently
            % set
            
            % optional argument indicating which PV
            if nargin < 3, fast = 0; end
            
            if fast
                setIdx(mdl.ctrlPVFast, newidx);
                notify(mdl, 'ctrlPVFastSliderChanged');
            else
                setIdx(mdl.ctrlPV, newidx);
                notify(mdl, 'ctrlPVSliderChanged');
            end
            acquirePlot(mdl);
        end
        
        function ctrlMKBControl(mdl, mkb, low, high, numvals, settletime)
            % create a multiknob control PV
            
            % changing this setting will remove the data field, unless this
            % action is cancelled
            cancd = mdlDataRemove(mdl);
            if cancd, return; end
            
            mdl.ctrlMKBName = mkb;
            if strncmpi(mkb, 'MKB:', 4)
                ctrlPVControl(mdl, 0, 'MKB:VAL', low, high, numvals, settletime);
            else
                ctrlPVControl(mdl, 0, 'MKB', low, high, numvals, settletime);
            end
        end
        
        function sampleControl(mdl, numSamples, newidx)
            % respond to change in the number of samples to acquire
            
            % either change which sample is being pointed to
            if nargin == 3
                newSample = newidx;
                if newSample > 0 && newSample <= mdl.acqOpt.numSamples
                    mdl.whichSample = newSample;
                end
            % or change the num samples property
            else
                % changing this setting will remove the data field, unless this
                % action is cancelled
                cancd = mdlDataRemove(mdl);
                if ~cancd
                    mdl.acqOpt.numSamples = numSamples;
                end
            end
            notify(mdl, 'samplesChanged');
        end
        
        function readPVNameListControl(mdl, pvs)
            % respond to change in the read PV list
            
            % changing this setting will remove the data field, unless this
            % action is cancelled
            cancd = mdlDataRemove(mdl);
            if ~cancd
                pvs = pvs(~cellfun(@isempty, pvs));
                mdl.nameList.readPV = pvs;
                mdl.readPVValid = [];
                mdl.BSAPVValid = [];
                acquireReset(mdl);
                plotAxisControl(mdl, []);
            end
            notify(mdl, 'readPVListChanged');
        end
        
        function deviceListControl(mdl, deviceType, idx)
            % generalized function for identifying the selected device from
            % it's index in the list
            
            devList = [deviceType, 'List'];
            if ~isempty(idx)
                mdl.([deviceType, 'Id']) = idx - 1;
                if idx == 1
                    mdl.([deviceType 'Name']) = '';
                else
                    mdl.([deviceType 'Name']) = mdl.(devList)(idx - 1);
                end
            else
                mdl.([deviceType 'Name']) = ''; 
                mdl.([deviceType, 'Id']) = 0;
            end
        end
        
        function profmonControl(mdl, idx)
            % respond to change in the selected profile monitor
            
            % changing this setting will remove the data field, unless this
            % action is cancelled
            cancd = mdlDataRemove(mdl);
            if cancd
                notify(mdl, 'profmonChanged');
                return;
            end
            deviceListControl(mdl, 'profmon', idx);
            mdl.nameList.profPV = {};
            % add relevant PVs to the namelist
            if any(mdl.profmonId)
                props = {'X' 'Y' 'XRMS' 'YRMS' 'XY' 'SUM'}';
                name = cellstr(mdl.profmonName);
                names = cell(numel(props), numel(name));
                for j = 1:numel(name)
                    names(:,j) = strcat(name(j), ':', props);
                end
                mdl.nameList.profPV = names(:);
            end
            notify(mdl, 'profmonChanged')
            acquireReset(mdl);
            plotAxisControl(mdl, []);
            wirePlaneControl(mdl, []);
            dataMethodControl(mdl, []);
        end
        
        function emitControl(mdl, idx)
            % respond to change in the selected emittance device
            
            % changing this setting will remove the data field, unless this
            % action is cancelled
            cancd = mdlDataRemove(mdl);
            if cancd
                notify(mdl, 'emitChanged');
                return;
            end
            deviceListControl(mdl, 'emit', idx);
            mdl.nameList.emitPV = {};
            % add relevant PVs to the namelist
            if mdl.emitId
                tags = {'EMIT' 'BETA' 'ALPHA' 'BMAG'}';
                mdl.nameList.emitPV = strcat(mdl.emitName,':', ...
                    [strcat(tags,'X');strcat(tags,'Y')]);
            end
            typ = 'Quad';
            if mdl.emitId && ismember(mdl.emitName, {'WIRE:LI28:144', 'WIRE:LTUH:735'})
                typ = 'Multi';
            end
            notify(mdl, 'emitChanged');
            emitTypeControl(mdl, typ);
            plotAxisControl(mdl, []);
            wirePlaneControl(mdl, []);
            dataMethodControl(mdl, []);
        end
        
        function wireControl(mdl, idx)
            % respond to change in the selected wire scanner
            
            % changing this setting will remove the data field, unless this
            % action is cancelled
            cancd = mdlDataRemove(mdl);
            if cancd
                notify(mdl, 'wireChanged');
                return;
            end
            deviceListControl(mdl, 'wire', idx);
            acquireReset(mdl);
            wirePlaneControl(mdl, []);
            dataMethodControl(mdl, []);
        end
        
        function blenControl(mdl, idx)
            % respond to change in the selected bunch length monitor
            
            % changing this setting will remove the data field, unless this
            % action is cancelled
            cancd = mdlDataRemove(mdl);
            if cancd
                notify(mdl, 'blenChanged');
                return;
            end
            deviceListControl(mdl, 'blen', idx);
            mdl.nameList.blenPV = {};
            % add relevant PVs to the namelist
            if mdl.blenId
                tags = {'BLEN'};
                mdl.nameList.blenPV = strcat(mdl.blenName, ':', tags);
            end
            notify(mdl, 'blenChanged');
            acquireReset(mdl);
            plotAxisControl(mdl, []);
            dataMethodControl(mdl, []);
        end
        
        function emitTypeControl(mdl, typ)
            % respond to change in the type of emittance measurement
            
            % changing this setting will remove the data field, unless this
            % action is cancelled
            cancd = mdlDataRemove(mdl);
            if cancd
                notify(mdl, 'emitTypeChanged');
                return;
            end
            mdl.emitType = typ;
            notify(mdl, 'emitTypeChanged');
            acquireReset(mdl);
        end
        
        function wirePlaneControl(mdl, xy)
            % respond to change in which plane to do the wire scan
            
            if isempty(xy), xy = 'x'; end
            mdl.wirePlane = xy;
            mdl.nameList.wirePV = {};
            % add relevant PVs to the namelist
            if mdl.wireId
                mdl.nameList.wirePV = strcat(mdl.wireName, ':', ...
                    [strcat(upper(mdl.wirePlane),{'' 'RMS'}');{'SUM'}]);
            end
            plotAxisControl(mdl, []);
            notify(mdl, 'wireChanged');
        end
        
        function dataMethodControl(mdl, methodIdx)
            % respond to change in profile monitor fit method
            if isempty(methodIdx), methodIdx = mdl.imgOpt.selectedMethod; end
            if methodIdx < 1 || methodIdx > length(mdl.imgOpt.methodMap), return; end
            mdl.imgOpt.selectedMethod = mdl.imgOpt.methodMap(methodIdx);
            notify(mdl, 'dataMethodChanged');
            acquireUpdate(mdl);
        end
        
        function sectorControl(mdl)
            % respond to change in sector (beampath). The correct device
            % lists must be plugged into the appropriate properties
            tag = fieldnames(mdl.sector.(mdl.index));
            for k = 1:length(tag)
                mdl.(tag{k}) = mdl.sector.(mdl.index).(tag{k});
            end
            % Let other apps take care of this still, I guess:
            %gui_modelSourceControl(hObject,handles,[],handles.beampath);
            if ismember(mdl.accelerator,{'LCLS','FACET'})
                mdl.beampath = mdl.index;
            else
                mdl.beampath = '';
            end
            % reinitialize device settings
            %setBSAOptions(mdl);
            profmonControl(mdl,[]);
            wireControl(mdl,[]);
            emitControl(mdl,[]);
            blenControl(mdl,[]);
            
        end
        
        function useControl(mdl, opt, val)
            % respond to change in the 'use' setting, indicating which
            % points to plot (or not plot)
            
            % switch on which property is being changed, then set the use
            % matrix so that it corresponds accurately to the data matrix
            switch opt
                case 'ctrlPV'
                    if ~isempty(mdl.ctrlPVFast)
                        numvals_fast = mdl.ctrlPVFast.numvals;
                    else
                        numvals_fast = 1;
                    end
                    use = reshape(mdl.data.use, [numvals_fast, mdl.ctrlPV.numvals, mdl.acqOpt.numSamples]);
                    use(:, mdl.ctrlPV.idx, :) = val;
                    mdl.data.use = reshape(use, [], mdl.acqOpt.numSamples);
                case 'ctrlPVFast'
                    mdl.data.use(getLinearIdx(mdl), :) = val;
                case 'sample'
                    mdl.data.use(getLinearIdx(mdl), mdl.whichSample) = val;
            end
            notify(mdl, 'useChanged');
            acquirePlot(mdl);
        end
        
        function imgProcControl(mdl)
            % initiate image processing
            acquireImgProc(mdl);
            acquirePlot(mdl);
        end
        
        function staticBGControl(mdl)
            if mdl.imgOpt.useStaticBG && ~isempty(mdl.profmonName)
                if mdl.imgOpt.numBG
                    opts.nBG = 0;
                    opts.bufd = 1;
                    opts.doPlot = 1;
                    opts.doProcess = 0;
                    opts.axes = mdl.imgOpt.axes;
                    opts.nAvg = mdl.imgOpt.numBG;
                    dataList = profmon_measure(mdl.profmonName, 1, opts);
                    mdl.imgOpt.staticBG = {dataList.img};
                else
                    mdl.imgOpt.staticBG = 0;
                end
            end
            notify(mdl, 'staticBGChanged')
        end
                
        function calcPVControl(mdl, calcPVs)
            % respond to change in formula
            mdl.nameList.calcPV = calcPVs;
            plotAxisControl(mdl, []);
        end
                
        function relativeControl(mdl, relative, fast)
            % set acquisition list relative to the current value (or unset)
            if fast
                mdl.acqOpt.relative(2) = relative;
                if ~isempty(mdl.ctrlPVFast)
                    setRelative(mdl.ctrlPVFast, relative);
                end
            else
                mdl.acqOpt.relative(1) = relative;
                if ~isempty(mdl.ctrlPV)
                    setRelative(mdl.ctrlPV, relative);
                end
            end
            notify(mdl, 'ctrlPVChanged');
            notify(mdl, 'ctrlPVFastChanged');
        end
        
        function helpControl(mdl)
            web(mdl.wikiURL, '-browser');
        end
        
    end
    
    methods % SAVE/LOAD METHODS
        
        function dataDisp(mdl)
            % initiate plotting with data written to workspace
            mdl.process.dataDisp = 1;
            plotData(mdl)
            mdl.process.dataDisp = 0;
        end
        
        function dataExport(mdl, val)
            % export plot to external figure, send to logbook/save data if desired
            mdl.process.displayExport = 1;
            acquireUpdate(mdl);
            mdl.process.displayExport = 0;
            util_appFonts(mdl.exportFig, 'fontName', 'Times', 'lineWidth', 1, 'fontSize', 14);
            if val
                % print to logbook
                devname = mdl.ctrlPV.name;
                if isfield(mdl, 'beampath') && ~isempty(mdl.beampath) && strcmp(mdl.accelerator, 'LCLS')
                    devname = [devname '(' mdl.beampath ')'];
                end
                if ~(strcmp(mdl.accelerator, 'LCLS') && strcmp(mdl.index(1:2), 'SC'))
                    disp_log('printing to elog')
                    util_appPrintLog(mdl.exportFig, mdl.plotOpt.header, devname, mdl.data.ts);
                else
                    util_appPrintLog(mdl.exportFig, mdl.plotOpt.header, devname, mdl.data.ts, 1, 'LCLS2');
                end
                dataSave(mdl, 0)
            end
        end
        
        function dataSave(mdl, saveAs)
            % save data and configuration
            
            data_temp = mdl.data;
            if ~any(data_temp.status), return; end
            if isfield(data_temp, 'dataList')
                % if not selected, no need to save all the image data
                if mdl.imgOpt.saveImg
                    butList = {'Proceed' 'Discard Images'};
                    button = questdlg('Save data with images?','Save Images',butList{:},butList{2});
                    if strcmp(button,butList{2}), data_temp = rmfield(data_temp,'dataList');end
                else
                    data_temp = rmfield(data_temp,'dataList');
                end
            end
            if isfield(data_temp, 'use'), data_temp = rmfield(data_temp, 'use'); end
            
            % set up the config for saving
            for tag = mdl.configList
                data_temp.config.(tag{:}) = mdl.(tag{:});
            end
            pvname = mdl.ctrlPV.name(mdl.ctrlPV.name ~= '/');
            % save to file
            fileName_saved = util_dataSave(data_temp, strrep(mdl.plotOpt.header, ' ', ''), pvname, data_temp.ts, saveAs);
            if ~ischar(fileName_saved), return; end
            mdl.fileName = fileName_saved;
            mdl.process.saved = 1;
            mdl.status = sprintf('Data saved to: %s', mdl.fileName);
            notify(mdl, 'statusChanged');
        end
        
        function dataLoad(mdl, fName)
            % load data and config into model
            prescan = 0;
            cancd = mdlDataRemove(mdl);
            if cancd, return; end
            if nargin == 2
                mdl.fileName = fName;
                data_temp = load(fName, 'data');
            else
                [data_temp, mdl.fileName] = util_dataLoad('Open Correlation Plot');
            end
            if ~ischar(mdl.fileName), return; end
            acquireReset(mdl);
            mdl.process.loading = 1;
            mdl.process.saved = 1;
            
            %load config
            configLoad(mdl, data_temp.config);
            data_temp = rmfield(data_temp, 'config');
            
            mdl.data = data_temp;
            notify(mdl, 'useChanged');
            mdl.process.loading = 0;
            
            if isfield(mdl.data, 'prescan')
                prescan = 1;
            end
            acquireUpdate(mdl, prescan);
        end
        
        function configLoad(mdl, config)
            % load configuration
            
            if nargin < 2, config = 1; end
            if isnumeric(config)
                config = util_configLoad('corrPlot_gui', config);
            elseif ~isstruct(config)
                config = load(config);
                config = config.config;
            end
            if isempty(config), return; end
            
            % not all configs will have an index option
            if ~isfield(config, 'index')
                config.index = mdl.indexList{1, 4};
            end
            if ~isfield(config, 'beampath')
                if ismember(mdl.accelerator, {'LCLS', 'FACET'})
                    config.beampath = mdl.indexList{1, 4};
                else
                    config.beampath = '';
                end
            end
            
            mdl.index = config.index;
            sectorControl(mdl)
            
            % the presence of 'ctrlPVName' is an indicator of new vs old
            % config
            if isfield(config, 'ctrlPVName')
                configLoadLegacy(mdl, config)
            else
                %oldIndex = mdl.index;
                for tag = mdl.configList
                    if isfield(config, tag{:})
                        mdl.(tag{:}) = config.(tag{:});
                    end
                end
            end
            
            % either set the control PVs to the values at which they were
            % saved, or to the current value
            if ~isempty(mdl.ctrlPV)
                pvName = mdl.ctrlPV.name;
                pvVal = mdl.ctrlPV.pv.val;
                str = sprintf('Reset %s to saved value of %d?', pvName, pvVal);
                if ~isempty(mdl.ctrlPVFast)
                    fastpvName = mdl.ctrlPVFast.name;
                    fastpvVal = mdl.ctrlPVFast.pv.val;
                    str = sprintf('Reset %s to saved value of %d, and %s to saved value of %d?', pvName, pvVal, fastpvName, fastpvVal);
                end
                
                btn = questdlg(str,'Reset Control PVs', ...
                    'Yes','No','No');
                
                switch btn
                    case 'Yes'
                        ctrlPVReset(mdl);
                    case 'No'
                        % the pv object inside the ctrlPVs is stuck at the
                        % saved value, change to the current value
                        setNewVal(mdl.ctrlPV);
                        if ~isempty(mdl.ctrlPVFast)
                            setNewVal(mdl.ctrlPVFast);
                        end
                end
                
            end
            
            plotAxisControl(mdl, []);
            notify(mdl, 'indexControlChanged');
            
            mdl.acqOpt.acquireStatus = 0; % this needs to be forced
            
            notify(mdl, 'configLoaded');
        end
        
        function configLoadLegacy(mdl, config)
            % load configuration from before App Designer upgrade
            
            % initialize control PVs
            if ~isempty(config.ctrlPVName{1})
                mdl.ctrlPV = corrplot_ctrlPV(config.ctrlPVName{1}, config.ctrlPVRange{1,1 }, config.ctrlPVRange{1, 2}, config.ctrlPVValNum(1), config.ctrlPVWait(1));
            end
            if ~isempty(config.ctrlPVName{2})
                mdl.ctrlPVFast = corrplot_ctrlPV(config.ctrlPVName{2}, config.ctrlPVRange{2, 1}, config.ctrlPVRange{2, 2}, config.ctrlPVValNum(2), config.ctrlPVWait(2));
            end
            
            % load properties that are same between old and new config
%             configSameName = {'ctrlMKBName','profmonId', 'wireId', 'profmonNumBG',...
%                 'profmonNumAve', 'emitId', 'blenId', 'profmonName',...
%                 'wireName', 'emitName', 'blenName', 'index', 'beampath'};
            configSameName = {'ctrlMKBName','profmonName',...
                'wireName', 'emitName', 'blenName', 'index', 'beampath'};
            
            for tag = configSameName
                if isfield(config, tag{:})
                    mdl.(tag{:}) = config.(tag{:});
                end
            end
            
            % the order of these matters for downstream view updates
            setDevice(mdl, 'wire', config.wireName);
            setDevice(mdl, 'emit', config.emitName);
            setDevice(mdl, 'profmon', config.profmonName);            
            setDevice(mdl, 'blen', config.blenName);
            
            % load properties that are formatted differently
            if isfield(config, 'ctrlPVNum'), mdl.numCtrlPV = config.ctrlPVNum; end
            if isfield(config, 'readPVNameList'), mdl.nameList.readPV = config.readPVNameList; end
            if isfield(config, 'calcPVNameList'), mdl.nameList.calcPV = config.calcPVNameList; end
            if isfield(config, 'waitInit'), mdl.acqOpt.waitInit = config.waitInit; end
            if isfield(config, 'settlePVName'), mdl.acqOpt.settlePV = config.settlePVName; end
            if isfield(config, 'acquireSampleNum'), mdl.acqOpt.numSamples = config.acquireSampleNum; end
            if isfield(config, 'acquireBSA'), mdl.acqOpt.BSA = config.acquireBSA; end
            if isfield(config, 'acquireRandomOrder'), mdl.acqOpt.randomOrder = config.acquireRandomOrder; end
            if isfield(config, 'acquireSpiralOrder'), mdl.acqOpt.spiralOrder = config.acquireSpiralOrder; end
            if isfield(config, 'acquireZigzagOrder'), mdl.acqOpt.zigzagOrder = config.acquireZigzagOrder; end
            if isfield(config, 'acquireSampleDelay'), mdl.acqOpt.sampleDelay = config.acquireSampleDelay; end
            if isfield(config, 'profmonNumBG'), mdl.imgOpt.numBG = config.profmonNumBG; end
            if isfield(config, 'profmonNumAve'), mdl.imgOpt.numAve = config.profmonNumAve; end
            if isfield(config, 'plotHeader'), mdl.plotOpt.header = config.plotHeader; end
            if isfield(config, 'showFit')
                fitOptions = {'No Fit', 'Polynomial', 'Gaussian', 'Sine', 'Parabola', 'Erf'};
                mdl.plotOpt.showFit = fitOptions{config.showFit + 1};
            end
            if isfield(config, 'showFitOrder'), mdl.plotOpt.showFitOrder = config.showFitOrder; end
            if isfield(config, 'showAverage'), mdl.plotOpt.showAverage = config.showAverage; end
            if isfield(config, 'showSmoothing'), mdl.plotOpt.showSmoothing = config.showSmoothing; end
            if isfield(config, 'defWindowSize'), mdl.plotOpt.showWindowSize = config.defWindowSize; end
            if isfield(config, 'show2D')
                show3DOptions = {'No 3D', 'Surface Plot', 'Scatter Plot', '3D Plot'};
                mdl.plotOpt.show3D = show3DOptions{config.show2D + 1}; 
            end
            if isfield(config, 'plotXAxisId'), mdl.plotOpt.XAxisId = config.plotXAxisId; end
            if isfield(config, 'plotYAxisId'), mdl.plotOpt.YAxisId = config.plotYAxisId; end
            if isfield(config, 'plotUAxisId'), mdl.plotOpt.UAxisId = config.plotUAxisId; end
            
        end
        
        function configSave(mdl)
            % save necessary model properties to encapsulate configuration
            for tag = mdl.configList
                config.(tag{:}) = mdl.(tag{:});
            end
            util_configSave('corrPlot_gui', config, 1);
        end
        
        function data = appQuery(mdl)
            % allow other applications to pull out the data struct
            data = mdl.data;
        end
        
    end
    
    methods % MISC

        function cancd = mdlDataRemove(mdl)
            % some actions require the data struct to be reset. Double
            % check with the user if they want this
            cancd = 0;
            if isempty(mdl.data), return; end
            if ~isfield(mdl.data, 'status'), return; end
            fig = mdl.locateApp();
            if any(mdl.data.status) && ~mdl.process.saved && ~isempty(fig)
                title = 'Unsaved Data';
                quest = 'Measured data not saved!';
                pbtns = {'Discard', 'Save', 'Cancel'};
                btn = uiconfirm(fig, quest, title, 'Options', pbtns, ...
                                'DefaultOption', 2, 'CancelOption', 3);
                switch btn
                  case 'Save'
                    dataSave(mdl, 0);
                  case 'Discard'
                    % move on with life
                  otherwise
                    cancd = 1;
                    return
                end
            end
            % this is a redundancy to avoid clearing data while data is
            % loading
            if ~mdl.process.loading
                mdl.data = struct();
            end
        end
        
        function doLEMTrim(mdl)
            % execute LEMing
            if ~mdl.acqOpt.useLEM, return, end
            mdl.status = 'LEM Trim starting ...';
            notify(mdl, 'statusChanged')
            model_energyBLEMTrim('action','PERTURB','quiet',1);
            mdl.status = 'LEM Trim completed.';
            notify(mdl, 'statusChanged');
        end
        
        function idx = getLinearIdx(mdl)
            % the linear index is refers to the flattened 
            % ctrlPVFast.numvals x ctrlPV.numvals matrix, used to navigate
            % when different indices are selected for each ctrl PV
            
            if isempty(mdl.ctrlPV)
                idx = 1;
            elseif isempty(mdl.ctrlPVFast)
                idx = mdl.ctrlPV.idx;
            else
                idx = sub2ind([fliplr(getNumVals(mdl)), 1], mdl.ctrlPVFast.idx, mdl.ctrlPV.idx);
            end
        end
        
        function numVals = getNumVals(mdl)
            % return the 2 numvals values for the ctrlPV and fast ctrlPV
            numVals = [1, 1];
            if ~isempty(mdl.ctrlPV)
                numVals(1) = mdl.ctrlPV.numvals;
            end
            if ~isempty(mdl.ctrlPVFast)
                numVals(2) = mdl.ctrlPVFast.numvals;
            end
        end
        
        function ts = getTitle(mdl)
            % return the timestamp for the plot title
            ts = now;
            if isfield(mdl.data,'readPV'), ts = [mdl.data.readPV(1).ts ts];end
            if isfield(mdl.data,'profPV'), ts = [mdl.data.profPV(1).ts ts];end
            if isfield(mdl.data,'wirePV'), ts = [mdl.data.wirePV(1).ts ts];end
            if isfield(mdl.data,'twissPV'), ts = [mdl.data.twissPV(1).ts ts];end
            if isfield(mdl.data,'blenPV'), ts = [mdl.data.blenPV(1).ts ts];end
            if ts(1) < 733000 || ts(1) > now, ts = now;end
            ts=ts(1);
        end
        
        function dataMerge(mdl)
            % used in prescan mode, concatenates data from successive scans
            fields = fieldnames(mdl.data)';
            for tag = fields
                nvals = prod(getNumVals(mdl));
                if isfield(mdl.data,tag)
                    str = cell2struct(tag,'tag',1);
                    switch str.tag
                        case 'status'
                            temp.data.status=repmat(mdl.data_old.status(1),nvals,1);
                            mdl.data.status=[temp.data.status;mdl.data_old.status];
                        case 'use'
                            %                 if handles.dataSample.nVal > 1
                            temp.data.use=repmat(mdl.data_old.use(1,:),nvals,1);
                            mdl.data.use=[temp.data.use;mdl.data_old.use];
                            %                 else
                            %                     temp.data.use=repmat(handles.data_old.use(1),nvals,1);
                            %                     handles.data.use=[temp.data.use;handles.data_old.use];
                            %                 end
                        case 'ctrlPV'
                            temp.data.ctrlPV=repmat(mdl.data_old.ctrlPV(:,1),1,nvals);
                            mdl.data.ctrlPV=[temp.data.ctrlPV mdl.data_old.ctrlPV];
                        case 'readPV'
                            %                 if handles.dataSample.nVal > 1
                            temp.data.readPV=repmat(mdl.data_old.readPV(:,1,:),1,nvals);
                            mdl.data.readPV=[temp.data.readPV mdl.data_old.readPV];
                            %                 else
                            %                     temp.data.readPV=repmat(handles.data_old.readPV(:,1),1,nvals);
                            %                     handles.data.readPV=[temp.data.readPV handles.data_old.readPV];
                            %                 end
                        case 'twissStd'
                            temp.data.twissStd=repmat(mdl.data_old.twissStd(1,:,:),nvals,1);
                            mdl.data.twissStd=[temp.data.twissStd; mdl.data_old.twissStd];
                        case 'twissPV'
                            %                 if handles.dataSample.nVal > 1
                            temp.data.twissPV=repmat(mdl.data_old.twissPV(:,1,:),1,nvals);
                            mdl.data.twissPV=[temp.data.twissPV mdl.data_old.twissPV];
                            %                 else
                            %                     temp.data.twissPV=repmat(handles.data_old.twissPV(:,1),1,nvals);
                            %                     handles.data.twissPV=[temp.data.twissPV handles.data_old.twissPV];
                            %                 end
                        case 'beam'
                            temp.data.beam=repmat(mdl.data_old.beam(1,:,:),nvals,1);
                            mdl.data.beam=[temp.data.beam; mdl.data_old.beam];
                        case 'profPV'
                            %                 if handles.dataSample.nVal > 1
                            temp.data.profPV=repmat(mdl.data_old.profPV(:,1,:),1,nvals);
                            mdl.data.profPV=[temp.data.profPV mdl.data_old.profPV];
                            %                 else
                            %                     temp.data.profPV=repmat(handles.data_old.profPV(:,1),1,nvals);
                            %                     handles.data.profPV=[temp.data.profPV handles.data_old.profPV];
                            %                 end
                        case 'wirePV'
                            temp.data.wirePV=repmat(mdl.data_old.wirePV(:,1,:),1,nvals);
                            mdl.data.wirePV=[temp.data.wirePV mdl.data_old.wirePV];
                        case 'wireBeam'
                            temp.data.wireBeam=repmat(mdl.data_old.wireBeam(1,1,:),nvals,1);
                            mdl.data.wireBeam=[temp.data.wireBeam; mdl.data_old.wireBeam];
                            %             case 'blenBeam'
                            %                 temp.data.blenBeam=repmat(handles.data_old.blenBeam(1),nvals,1);
                            %                 handles.data.blenBeam=[temp.data.blenBeam;handles.data_old.blenBeam];
                        case 'blenStd'
                            temp.data.blenStd=repmat(mdl.data_old.blenStd(1,1,:),nvals,1);
                            mdl.data.blenStd=[temp.data.blenStd; mdl.data_old.blenStd];
                        case 'blenPV'
                            %                 if handles.dataSample.nVal > 1
                            temp.data.blenPV=repmat(mdl.data_old.blenPV(:,1,:),1,nvals);
                            mdl.data.blenPV=[temp.data.blenPV mdl.data_old.blenPV];
                            %                 else
                            %                     temp.data.readPV=repmat(handles.data_old.readPV(:,1),1,nvals);
                            %                     handles.data.readPV=[temp.data.readPV handles.data_old.readPV];
                            %                 end
                        case 'dataList'
                            temp.data.dataList=repmat(mdl.data_old.dataList(1,:),nvals,1);
                            mdl.data.dataList=[temp.data.dataList; mdl.data_old.dataList];
                    end
                end
            end
        end
        
        function sortData(mdl)
            % sort data along the ctrl PV axis
            for idx=1:length(mdl.data.ctrlPV)
                ctrlPV_val(idx)=mdl.data.ctrlPV(1,idx).val;
            end
            [~, sort_idx]=sort(ctrlPV_val);
            fields=fieldnames(mdl.data)';
            for tag=fields
                if isfield (mdl.data,tag)
                    str=cell2struct(tag,'tag',1);
                    switch str.tag
                        case 'ctrlPV'
                            mdl.data.ctrlPV=mdl.data.ctrlPV(:,sort_idx);
                        case 'readPV'
                            %                     if handles.dataSample.nVal > 1
                            mdl.data.readPV=mdl.data.readPV(:,sort_idx,:);
                            %                     else
                            %                         handles.data.readPV=handles.data.readPV(:,sort_idx);
                            %                     end
                        case 'twissStd'
                            mdl.data.twissStd=mdl.data.twissStd(sort_idx,:,:);
                        case 'twissPV'
                            %                     if handles.dataSample.nVal > 1
                            mdl.data.twissPV=mdl.data.twissPV(:,sort_idx,:);
                            %                     else
                            %                     handles.data.twissPV=handles.data.twissPV(:,sort_idx);
                            %                     end
                        case 'beam'
                            mdl.data.beam=mdl.data.beam(sort_idx,:,:);
                        case 'profPV'
                            %                     if handles.profmonId
                            mdl.data.profPV=mdl.data.profPV(:,sort_idx,:);
                            %                     else
                            %                         handles.data.profPV=handles.data.profPV(:,sort_idx);
                            %                     end
                        case 'wireBeam'
                            mdl.data.wireBeam=mdl.data.wireBeam(sort_idx,:,:);
                        case 'wirePV'
                            mdl.data.wirePV=mdl.data.wirePV(:,sort_idx,:);
                        case 'dataList'
                            mdl.data.dataList=mdl.data.dataList(sort_idx,:);
                    end
                end
            end
        end
        
        function ctrlPVValidate(mdl)
            
        end
        
    end
        
    methods % ACQUIRE METHODS
         
        
        function acquireStart(mdl, prescan)
            % the primary acquisition loop
            if nargin < 2, prescan = 0; end
            
            % catch error trying to acquire without a control PV
            if isempty(mdl.ctrlPV)
                errTxt = "No Control PV entered. Use TIME for basic scan.";
                error("CP:ACQFAILED", errTxt);
            end
            
            % return if acquisition in progress
            if mdl.acqOpt.acquireStatus, return; end
            if mdl.process.loading
                fig = mdl.locateApp();
                if ~isempty(fig)
                    title = 'Loading Data';
                    quest = 'Cannot start acquisition. Data is loading!';
                    pbtns = {'Cancel'};
                    btn = uiconfirm(fig, quest, title, 'Options', pbtns);
                end
                return;
            end
            cancd = mdlDataRemove(mdl);
            if cancd, setAcquireStatus(mdl, 0); return; end
            acquireReset(mdl);
            setAcquireStatus(mdl, 1);
            relative = 0;
            
            % set up multiknob if necessary
            if ~isempty(mdl.ctrlMKBName)
                if ~contains(lower(mdl.ctrlMKBName), '.mkb')
                    mdl.ctrlMKBName = [mdl.ctrlMKBName, '.mkb'];
                end
                if ispc
                    mkbPV = AssignMultiknob(mdl.ctrlMKBName, 'C:');
                else
                    mkbPV = AssignMultiknob(mdl.ctrlMKBName);
                end
                if ~isempty(mkbPV)
                    if strcmpi(mkbPV, 'MKB:VAL')
                        relative = 1;
                    else
                        low = mdl.ctrlPV.range(1);
                        high = mdl.ctrlPV.range(2);
                        numvals = mdl.ctrlPV.numvals;
                        settletime = mdl.ctrlPV.settletime;
                        ctrlPVControl(mdl, 0, [mkbPV, ':VAL'], low, high, numvals, settletime);
                    end
                end
            end
            
            
            % acquire meta data before the scan
            if ~isempty(mdl.nameList.metaDataPV)
                cancd = acquireMetaData(mdl);
                if cancd
                    return
                end
            end
            
            % the loop
            dataAcquire = 1;
            while dataAcquire
                % set ctrl PV to initial value
                if ~isempty(mdl.ctrlPV) && ~mdl.acqOpt.randomOrder && ~mdl.acqOpt.zigzagOrder
                    setIdx(mdl.ctrlPV, 1);
                    ctrlPVSet(mdl, 0, 1);
                end
                
                % get the appropriate ctrl PV and fast ctrl PV lists
                [slowList, fastList] = acquireGetList(mdl);
                for jj = slowList
                    j = jj(1);
                    if mdl.numCtrlPV ~= 0
                        % increment the ctrl PV index
                        setIdx(mdl.ctrlPV, j);
                        val = mdl.ctrlPV.getVal();
                        notify(mdl, 'ctrlPVSliderChanged');
                        % notify change in value to view
                        str = sprintf('Data point #%d setting %s to %6.3f', j, mdl.ctrlPV.name, val);
                        disp_log(str);
                        mdl.status = str;
                        notify(mdl, 'statusChanged');
                        % set the ctrl PV to it's new value
                        ctrlPVSet(mdl, 0, 0, relative, slowList, j);
                    end
                    for k = fastList(min(end, jj(end)), :)
                        if ~isempty(mdl.ctrlPVFast)
                            % increment the fast ctrl PV index
                            setIdx(mdl.ctrlPVFast, k);
                            val = getVal(mdl.ctrlPVFast);
                            notify(mdl, 'ctrlPVFastSliderChanged');
                            % notify change in value to view
                            str = sprintf('Data point #%d setting %s to %6.3f', k, mdl.ctrlPVFast.name, val);
                            disp_log(str);
                            mdl.status = str;
                            notify(mdl, 'statusChanged');
                            % set the fast ctrl PV to its new value
                            ctrlPVSet(mdl, 1);
                        end
                        % acquire response data
                        acquireCurrentGet(mdl, 'remote', prescan);
                        if ~mdl.acqOpt.acquireStatus, break; end
                    end
                    if ~mdl.acqOpt.acquireStatus, break; end
                end
                dataAcquire = 0;
                % prescan modes allows user to do a successive scans with
                % different ctrl PV ranges
                if prescan
                    mdl.data.prescan = 1;
                    prompt = {'Enter Control PV Low Value:','Enter Control PV High Value:', ...
                        'Enter # of Control PV Values'};
                    dlg_title = 'More Data?';
                    num_lines = 1;
                    nvals = mdl.ctrlPV.numvals;
                    def = {'', '', nvals};
                    options.Resize = 'on';
                    answer = inputdlg(prompt, dlg_title, num_lines, def, options);
                    if ~isempty(answer)
                        dataAcquire = 1;
                        lo_val = str2double(answer{1});
                        hi_val = str2double(answer{2});
                        n_vals = str2double(answer{3});
                        % set some view stuff
                        mdl.data_old = mdl.data;
                        numvalsControl(mdl, n_vals, 0)
                        ctrlPVRangeControl(mdl, lo_val, hi_val, 0);
                        dataMerge(mdl)
                    end
                end
            end
            if prescan
                sortData(mdl)
            end
            % return everything to pre scan status
            ctrlPVReset(mdl, relative, slowList);
            setAcquireStatus(mdl, 0);
            if ~isempty(mdl.ctrlMKBName)
                DeassignMultiknob(mkbPV);
            end
            mdl.status = sprintf('Data acquisition complete');
            notify(mdl, 'statusChanged');
            disp(mdl.status);
        end
        
        function acquireCurrentGet(mdl, state, prescan)
            % acquire data for current sample index
            
            if nargin < 3, prescan = 0; end
            if mdl.acqOpt.BSA
                acquireBSAControl(mdl, []);
                lcaPut('SIOC:SYS0:ML00:AO526',mdl.eDefNumber);
            end
            
            mdl.process.saved = 0;
            readPVIdx = getLinearIdx(mdl); % identify which column of the data matrix needs to be filled in
            isQuasiBSA = strncmp(mdl.nameList.readPV,'SIOC:SYS0:ML00:FWF',18);
            isFELeLoss = strncmp(mdl.nameList.readPV,'PHYS:SYS0:1:ELOSSENERGY',20);
            
            if strcmp(mdl.ctrlPV.pv.name, 'MKB:VAL')
                mdl.data.ctrlPV(:, readPVIdx) = util_readPV('');
                mdl.data.ctrlPV(:, readPVIdx).name = 'MKB:VAL';
                mdl.data.ctrlPV(:, readPVIdx).desc = mdl.ctrlMKBName;
                % in other version, the vallist taken is handles.ctrlPVNum,
                % meaning if fast control PV is filled out, it will take
                % that vallist
                mdl.data.ctrlPV(:, readPVIdx).val = mdl.ctrlPV.vallist(readPVIdx);
            else
                % read in the values of the ctrl PVs
                if ~isempty(mdl.ctrlPVFast)
                    pvs = {mdl.ctrlPV.name, mdl.ctrlPVFast.name};
                else
                    pvs = mdl.ctrlPV.name;
                end
                mdl.data.ctrlPV(:, readPVIdx) = util_readPV(pvs, 1);
            end
            
            % create the readPV field of the data struct if necessary
            if ~isempty(mdl.nameList.readPV) && (isempty(mdl.readPVValid) || ~isfield(mdl.data, 'readPV'))
                timeout = lcaGetTimeout;
                lcaSetTimeout(0.5);
                % identify which PVs are reading valid
                [mdl.data.readPV(:, readPVIdx, 1), mdl.readPVValid] = util_readPV(mdl.nameList.readPV, 1);
                lcaSetTimeout(timeout);
                mdl.readPVValidId = readPVIdx;
                mdl.BSAPVValid = mdl.readPVValid & 0;
                if mdl.acqOpt.BSA
                    % identify which PVs read valid with their BSA suffix
                    [readPV, mdl.BSAPVValid] = util_readPV(strcat(mdl.nameList.readPV, 'BR'), 1);
                    mdl.BSAPVValid = mdl.BSAPVValid | isQuasiBSA;
                    mdl.readPVValid = mdl.readPVValid | mdl.BSAPVValid;
                    % warn user of invalid PVs
                    if ~all(mdl.BSAPVValid)
                        str = [{'Invalid BSA PVs:'}; mdl.nameList.readPV(~mdl.BSAPVValid)];
                        btn = questdlg(str,'Invalid BSA PV Names','Cancel','OK','Cancel');
                        if strcmp(btn,'Cancel')
                            setAcquireStatus(mdl, 0);
                            return
                        end
                    end
                end
                if ~all(mdl.readPVValid)
                    str = [{'Invalid PVs:'}; mdl.nameList.readPV(~mdl.readPVValid)];
                    btn = questdlg(str,'Invalid PV Names','Cancel','OK','Cancel');
                    if strcmp(btn,'Cancel')
                        setAcquireStatus(mdl, 0);
                        return
                    end
                end
            end
            
            % Do FEL energy loss.
            if any(isFELeLoss)
                E_loss_scan('appRemote',0);
            end
            
            % Do wire scan, only nonsynchronous.
            if mdl.wireId
                mdl.status = sprintf('Acquiring wire data');
                notify(mdl, 'statusChanged');
                if strcmp(state, 'query')
                    % just grab the data from an existing wire scan
                    dataList = wirescan_gui('appQuery', 0, mdl.wireName, mdl.wirePlane);
                else
                    % do a wire scan for each sample
                    for j = 1:(1 + (mdl.acqOpt.numSamples - 1) * mdl.acqOpt.sampleForce)
                        dataList(j) = wirescan_gui('appRemote', 0, mdl.wireName, mdl.wirePlane, 0, mdl.index);
                        pause(mdl.acqOpt.sampleDelay);
                    end
                end
                mdl.data.status(readPVIdx) = all([dataList.status]);
                if ~all([dataList.status])
                    setAcquireStatus(mdl, 0);
                end
                beamList = vertcat(dataList.beam);
                mdl.data.wireBeam(readPVIdx, 1:numel(dataList), :) = beamList;
                dataList(end+1:mdl.acqOpt.numSamples) = dataList(1);
                mdl.data.wirePV(:, readPVIdx, :) = [dataList.beamPV];
            end
            
            % Do emittance scan, only nonsynchronous.
            if mdl.emitId
                mdl.status = sprintf('Acquiring emittance data');
                notify(mdl, 'statusChanged');
                clear dataList
                if strcmp(mdl.emitType, 'multi') && strcmp(state, 'query')
                    % grab emittance data
                    dataList = emittance_gui('appQuery', 0);
                else
                    % ensure correct keyword for the emittance type for the
                    % emittance gui
                    if strcmp(mdl.emitType, 'Quad')
                        useType = 'scan';
                    else
                        useType = 'multi';
                    end
                    % do emittance scan
                    for j = 1:(1 + (mdl.acqOpt.numSamples - 1) * mdl.acqOpt.sampleForce)
                        % facet emittance gui does not take in facility
                        % index
                        dataList(j) = emittance_gui('appRemote', 0, mdl.emitName, useType, mdl.wirePlane);
                        pause(mdl.acqOpt.sampleDelay);
                    end
                end
                mdl.data.status(readPVIdx) = all([dataList.status]);
                if ~mdl.data.status(readPVIdx)
                    setAcquireStatus(mdl, 0);
                end
                dataList(end+1:mdl.acqOpt.sampleDelay) = dataList(1);
                twissStd = reshape(dataList(1).twissstd(:,:,:,1), [], size(dataList(1).twissstd, 3));
                twissStd([1, 5], :) = twissStd([1, 5], :) * 1e6; % Scale emittance into um
                mdl.data.twissStd(readPVIdx, :, :) = twissStd;
                mdl.data.twissPV(:, readPVIdx, :) = [dataList.twissPV];
            end
            
            % Do bunch length scan, only nonsynchronous.
            if mdl.blenId
                mdl.status = sprintf('Acquiring bunch length data');
                notify(mdl, 'statusChanged');
                clear dataList
                if strcmp(state,'query')
                    % grab bunch length data
                    dataList = tcav_gui('appQuery',0);
                else
                    % do bunch length scan
                    for j = 1:(1+(mdl.acqOpt.sampleDelay - 1) * mdl.acqOpt.sampleForce)
                        dataList(j) = tcav_gui('appRemote', 0, mdl.blenName, 'blen');
                        pause(mdl.acqOpt.sampleDelay);
                    end
                end
                mdl.data.status(readPVIdx) = all(all([dataList.status]));
                if ~all([dataList.status])
                    setAcquireStatus(mdl, 0);
                    return
                end
                beamList = permute(cat(3, dataList.beam), [3, 2, 1]);
                mdl.data.blenBeam(readPVIdx, 1:numel(dataList),:,:) = beamList;
                dataList(end+1:mdl.acqOpt.numSamples) = dataList(1);
                blenStd = dataList(1).blenStd(:,:);
                mdl.data.blenStd(readPVIdx,:,:) = blenStd;
                mdl.data.blenPV(:,readPVIdx,:) = [dataList.blenPV];
            end
            
            % Start beam synchronous acquisition.
            if ~ispc && (any(mdl.BSAPVValid) || mdl.imgOpt.BSA)
                if any(mdl.profmonId) && ~mdl.profmonBSA
                    eDefParams(mdl.eDefNumber, 1, 2800);
                    eDefOn(mdl.eDefNumber);
                else
                    eDefParams(mdl.eDefNumber, 1, mdl.acqOpt.numSamples);
                    eDefOn(mdl.eDefNumber);
                    mdl.status = sprintf('Waiting for eDef completion');
                    notify(mdl, 'statusChanged');
                end
            end
            
            % Get profile monitor data, non buffered acquisition, i.e., if
            % the profmon BSA option is not set, just go get the number of
            % images necessary
            if any(mdl.profmonId) && ~mdl.imgOpt.BSA
                mdl.status = sprintf('Getting Image Data');
                notify(mdl, 'statusChanged');
                opts.nBG = mdl.imgOpt.numBG;
                opts.bufd = 1;
                opts.nAvg = mdl.imgOpt.numAve;
                opts.axes = mdl.imgOpt.axes;
                opts.doPlot=1;
                opts.doProcess = 0;
                if mdl.imgOpt.useStaticBG, opts.nBG = mdl.imgOpt.staticBG; end
                dataList = profmon_measure(mdl.profmonName, mdl.acqOpt.numSamples, opts);
                mdl.status = sprintf('Done Image Acquisition');
                notify(mdl, 'statusChanged');
                acquireImgProc(mdl, readPVIdx, dataList);
                dataList = mdl.data.dataList(readPVIdx,:,:);
            end
            
            % Do beam synchronous acquisition
            if ~ispc && (any(mdl.BSAPVValid) || mdl.imgOpt.BSA)
                if any(mdl.profmonId) && ~mdl.imgOpt.BSA
                    eDefOff(mdl.eDefNumber);
                else
                    while ~eDefDone(mdl.eDefNumber), end
                    mdl.status = sprintf('eDef completed');
                    notify(mdl, 'statusChanged');
                end
            end
            
            % Get buffered profile monitor data.
            if any(mdl.profmonId) && mdl.imgOpt.BSA
                mdl.status = sprintf('Getting Image Data');
                notify(mdl, 'statusChanged');
                opts.nBG = mdl.imgOpt.numBG;
                opts.bufd = 1;
                opts.buffer = 1;
                opts.axes = mdl.imgOpt.axes;
                opts.doPlot = 1;
                opts.doProcess = 0;
                if mdl.imgOpt.useStaticBG, opts.nBG = mdl.imgOpt.staticBG; end
                dataList = profmon_measure(mdl.profmonName, mdl.acqOpt.numSamples, opts);
                mdl.status = sprintf('Done Image Acquisition');
                notify(mdl, 'statusChanged');
                acquireImgProc(mdl, readPVIdx, dataList);
                dataList = mdl.data.dataList(readPVIdx,:,:);
            end
            
            % acquire BSA data
            if any(mdl.BSAPVValid)
                mdl.status = sprintf('Getting Synchronous Data');
                notify(mdl, 'statusChanged');
                use = find(mdl.BSAPVValid);
                use2 = strncmp(mdl.nameList.readPV(use),'SIOC:SYS0:ML00:FWF',18);
                [readPV, pulseId] = util_readPVHst(mdl.nameList.readPV(use), mdl.eDefNumber, 1, mdl.acqOpt.numSamples);
                if any(isQuasiBSA)
                    util_quasiBSA;
                    val = num2cell(lcaGetSmart(mdl.nameList.readPV(isQuasiBSA), numel(pulseId)), 2);
                    [readPV(use2).val] = deal(val{:});
                end
                rate = mode(diff(pulseId,1,2),2);
                if isnan(rate), rate = 1; end
                mdl.status = sprintf('Done Data Acquisition');
                notify(mdl, 'statusChanged');
                useSample = 1:mdl.acqOpt.numSamples;
                if any(mdl.profmonId)
                    % identify profmon data with pulseId in the same time
                    % range as the BSA data
                    useSample = zeros(mdl.acqOpt.numSamples, 1);
                    for j=1:numel(dataList)
                        if (strncmp(dataList(j).name, 'CAMR', 4) && ~ strncmp(dataList(j).name, 'CAMR:FEE1', 9))
                            dataList(j).pulseId = round((dataList(j).ts - readPV(use(1)).ts)*24*60*60*360+pulseId(end));
                        end
                        if strncmp(dataList(j).name, 'DIAG:FEE1', 9)
                            dataList(j).pulseId=dataList(j).pulseId-3;
                        end
                    end
                    for j=1:mdl.acqOpt.numSamples
                        useIdx = find(dataList(j).pulseId >= pulseId); % indices where the profmon pulseId is greater than or equal the BSA pulseId
                        [d,id] = min(double(dataList(j).pulseId) - pulseId(useIdx)); % indices of profmon pulseId closest to BSA pulseId
                        if isempty(useIdx)
                            useIdx=1;
                            id=1;
                        end
                        useSample(j) = useIdx(id); % which profmon samples are the closest to BSA in time
                    end
                end
            end
            
            if any(mdl.BSAPVValid) || mdl.imgOpt.BSA
                % 10/17/22 JR - I am skeptical this will work with SC
                % BSA...needs to test
                if any(mdl.profmonId)
                    % Find common set of pulse IDs.
                    pID = [dataList(1,:,1).pulseId];
                    for j=2:size(dataList, 3)
                        pID = intersect(pID, [dataList(1,:,j).pulseId]);
                    end
                    % Find IDs in first profmon.
                    useID = ismember([dataList(1,:,1).pulseId], pID);
                    pID = [dataList(1,useID,1).pulseId];
                    % Match other screen pulse IDs.
                    for j=2:size(dataList, 3)
                        [~, useID2] = ismember(pID, [dataList(1,:,j).pulseId]);
                        dataList(1,useID,j) = dataList(1,useID2,j);
                    end
                    % Make beamPV NaN for bad pIDs.
                    if isfield(mdl.data,'profPV')
                        [mdl.data.profPV(:,readPVIdx,~useID,:).val] = deal(NaN(1,7));
                    end
                    for j=find(~useID)
                        for k=1:size(dataList,3)
                            dataList(1,j,k).img=dataList(1,j,k).img*NaN;
                        end
                    end
                    mdl.data.dataList(readPVIdx,:,:) = dataList;
                end
            end
            
            if any(mdl.BSAPVValid)
                isBLD = strcmp({readPV.name}, 'BLD:SYS0:500:PCAV_FITTIME1');
                if any(isBLD)
                    readPV(find(isBLD,1)).val = circshift(readPV(find(isBLD,1)).val,[0 -1]);
                end
                isBLD = strcmp({readPV.name}, 'BLD:SYS0:500:PCAV_FITTIME2');
                if any(isBLD)
                    readPV(find(isBLD,1)).val = circshift(readPV(find(isBLD,1)).val,[0 -1]);
                end
                mdl.data.readPV(use, readPVIdx, 1:mdl.acqOpt.numSamples) = repmat(readPV, 1, mdl.acqOpt.numSamples);
                for j = 1:mdl.acqOpt.numSamples
                    for k = 1:length(use)
                        tsList = (1-length(readPV(k).val):0)/24/60/60/360*rate+readPV(k).ts;
                        try
                            mdl.data.readPV(use(k),readPVIdx,j).val = readPV(k).val(useSample(j)); % useSample(j) is an array
                        catch
                            
                        end
                        mdl.data.readPV(use(k),readPVIdx,j).ts = tsList(useSample(j));
                    end
                end
            end
            
            % get data for valid PVs that are not BSA
            if ~all(mdl.BSAPVValid)
                use = mdl.readPVValid & ~mdl.BSAPVValid;
                bad = ~mdl.readPVValid;
                id = mdl.readPVValidId;
                mdl.status = sprintf('Getting Samples #1-%d', mdl.acqOpt.numSamples);
                notify(mdl, 'statusChanged');
                for l = 1:mdl.acqOpt.numSamples
                    if any(use)
                        mdl.data.readPV(use,readPVIdx,l) = mdl.data.readPV(use,id,1);
                        readPV = util_readPV(mdl.nameList.readPV(use),0,1);
                        [mdl.data.readPV(use, readPVIdx, l).val] = deal(readPV.val);
                        [mdl.data.readPV(use, readPVIdx, l).ts] = deal(readPV.ts);
                    end
                    mdl.data.readPV(bad, readPVIdx, l) = mdl.data.readPV(bad,id,1);
                    pause(mdl.acqOpt.sampleDelay);
                end
            end
            
            mdl.status = sprintf('Done Data Acquisition');
            notify(mdl, 'statusChanged');
            
            
            if ~isempty(mdl.acqOpt.pausePV)
                pauseDataAcq(mdl);
            end
            
            % initialize the use field for this sample
            mdl.data.status(readPVIdx) = 1;
            mdl.data.ts = getTitle(mdl);
            if ~isfield(mdl.data,'use')
                numvals = [1, 1];
                if ~isempty(mdl.ctrlPV)
                    numvals(1) = mdl.ctrlPV.numvals;
                end
                if ~isempty(mdl.ctrlPVFast)
                    numvals(2) = mdl.ctrlPVFast.numvals;
                end
                mdl.data.use = ones(prod(numvals), mdl.acqOpt.numSamples);
            end
            mdl.data.use(readPVIdx, 1:mdl.acqOpt.numSamples) = 1;
            acquireUpdate(mdl, prescan);            
        end
        
        function acquirePlot(mdl, prescan)
            % wrap plotting functions
            if ~isfield(mdl.data, 'status'), return; end
            if nargin < 2, prescan = 0; end
            plotProfile(mdl);
            try
                plotData(mdl);
            catch ex
                warning('Unhandled corrPlot_GUI.m exception, acquirePlot() trying to call plotData().')
                disp_log(ex.message)
            end

        end
        
        function acquireUpdate(mdl, prescan)
            % respond to newly acquired data
            if nargin < 2, prescan = 0; end
            if ~isfield(mdl.data, 'status') || ~any(mdl.data.status)
                acquirePlot(mdl)
                return
            end
            if prescan
                nval = numel(mdl.data.status);
            else
                nval = prod(getNumVals(mdl));
            end
            if ~isfield(mdl.data, 'use')
                mdl.data.use = ones(nval, mdl.acqOpt.numSamples);
            end
            if mdl.process.displayExport
                mdl.exportFig = figure;
            end
            acquirePlot(mdl, prescan);
        end
        
        function cancd = acquireMetaData(mdl)
            mdl.status = 'Acquiring pre scan meta data';
            notify(mdl, 'statusChanged');
            [mdl.data.metaDataPV(:, 1), metaDataValid] = util_readPV(mdl.nameList.metaDataPV, 1);
            cancd = 0;
            if ~all(metaDataValid)
                str = [{'Invalid PVs:'}; mdl.nameList.metaDataPV(~metaDataValid)];
                btn = questdlg(str,'Invalid PV Names','Cancel','OK','Cancel');
                if strcmp(btn,'Cancel')
                    setAcquireStatus(mdl, 0);
                    cancd = 1;
                    return
                end
            end
            
            use = metaDataValid;
            for l = 1:mdl.acqOpt.numSamples
                if any(use)
                    mdl.data.metaDataPV(use,l) = mdl.data.metaDataPV(use,1);
                    metaData = util_readPV(mdl.nameList.metaDataPV(use), 0, 1);
                    [mdl.data.metaDataPV(use, l).val] = deal(metaData.val);
                    [mdl.data.metaDataPV(use, l).ts] = deal(metaData.ts);
                end
                pause(mdl.acqOpt.sampleDelay);
            end
            mdl.status = 'Meta data acquisition complete';
            notify(mdl, 'statusChanged');
        end
        
        function acquireReset(mdl, prescan)
            % reset fields in data struct that record acquisition progress,
            % thus initiating data reset downstream
            if nargin < 2, prescan = 0; end
            mdl.fileName = '';
            mdl.data.accelerator = mdl.accelerator;
            mdl.data.status = zeros(prod(getNumVals(mdl)), 1);
            acquireUpdate(mdl);
        end
        
        function acquireBSAControl(mdl, bsaState)
            % acquire or release a BSA eDef
            if mdl.process.loading, return; end
            update = 1;
            if isempty(bsaState), update = 0; end
            eDef = 0;
            if ~isempty(mdl.eDefNumber), eDef = mdl.eDefNumber; end
            isSC = startsWith(mdl.beampath, 'SC');
            if isSC
                sampleMax = 20000;
            else
                sampleMax = 2800;
            end
            
            % ensure number to acquire is less than max in bugger
            if (any(bsaState) || (isempty(bsaState) && mdl.acqOpt.BSA)) && mdl.acqOpt.numSamples > sampleMax
                bsaState = 0;
                uiwait(warndlg(sprintf('Sample number exceeds BSA limit of %d.  Choose smaller number.', sampleMax), ...
                    'BSA Disabled'));
            end
            % do the eDef acquisition
            mlapp_BSAControl(mdl, bsaState, sampleMax, mdl.beampath);
            notify(mdl, 'BSAChanged');
            if ~ispc
                % logic for updating the event definition with parameters
                if mdl.acqOpt.BSA && (update || eDef ~= mdl.eDefNumber)
                    mask = mdl.BSAOptions;
                    if isSC
                        % 10/17/22 this works to set the BSA fixed rate
                        % right now when we are only sending beam to one
                        % destination. This will cause issues with timing
                        % markers once beam is sent to multiple
                        % destinations
                        lcaPutSmart(sprintf('BSA:SYS0:1:%d:FIXEDRATE', mdl.eDefNumber), mdl.BSAOptions{mdl.acqOpt.BSA + 1}); % clarify what needs to be added here
                    else
                        if ~strcmp(mask{mdl.acqOpt.BSA + 1}, '120_HERTZ')
                            lcaPut(sprintf('EDEF:SYS0:%d:BEAMCODE', mdl.eDefNumber), 1);
                            eDefParams(mdl.eDefNumber,1,2800,[mask{mdl.acqOpt.BSA+1};{'pockcel_perm'}],mask(setdiff(2:end-1,mdl.acqOpt.BSA+1)),{},{'TS2';'TS3';'TS5';'TS6'});
                        else
                            lcaPut(sprintf('EDEF:SYS0:%d:BEAMCODE', mdl.eDefNumber), 0);
                            eDefParams(mdl.eDefNumber,1,2800,{},[mask{2:end-1};{'TS4';'pockcel_perm'}],{'TS2';'TS3';'TS5';'TS6'});
                        end
                    end
                end
            end
            if update, mdl.readPVValid = []; end
            
        end
        
        function acquireImgProc(mdl, idx, dataList)
            % do image processing
            if nargin < 3 && ~isfield(mdl.data,'dataList'), return, end
            if nargin < 2, idx = find(mdl.data.status)';end
            if nargin == 3, mdl.data.dataList(idx,:,:) = shiftdim(dataList,1);end
            if ~mdl.imgOpt.procImg, return, end
            
            mdl.status = 'Processing images...';
            notify(mdl, 'statusChanged');
            % options for profmon_process
            opts.doPlot = 1;
            opts.useCal = mdl.imgOpt.useCal;
            opts.crop = mdl.imgOpt.useImgCrop;
            opts.xsig = mdl.imgOpt.XSig;
            opts.ysig = mdl.imgOpt.YSig;
            camName = mdl.data.dataList(idx,1,1).name;   % with live data, this may not have the second data
            doPut = ~ismember(camName(6:min(9,end)),{'M6:C' 'XS:C' 'PAL1' 'G2:C'});
            for j = idx
                for k = 1:size(mdl.data.dataList(j,:,:), 2)
                    for l = 1:size(mdl.data.dataList(j,:,:), 3)
                        data_temp = mdl.data.dataList(j,k,l); % raw profmon data
                        data_temp.beam = profmon_process(data_temp, opts); % process that data
                        mdl.data.beam(j, k, :, l) = data_temp.beam;
                        if doPut
                            try
                                control_profDataSet(camName, data_temp.beam);
                            catch ex
                                disp_log('Error trying to post processed camera stats!')
                                disp_log(ex.message)
                            end
                        end
                        mdl.data.profPV(:, j, k, l) = beamAnalysis_convert2PV(data_temp);
                    end
                end
            end
            if ~mdl.imgOpt.holdImg, mdl.data = rmfield(mdl.data, 'dataList'); end
            mdl.status = 'Processing images complete.';
            notify(mdl, 'statusChanged');
                        
        end
        
        function [slowList, fastList] = acquireGetList(mdl)
            % get the acquisition list based on the user requested ordering
            % method
            slowList = 1:mdl.ctrlPV.numvals;
            if ~isempty(mdl.ctrlPVFast)
                fastList = 1:mdl.ctrlPVFast.numvals;
            else
                fastList = [1];
            end
            
            if mdl.acqOpt.randomOrder
                slowList = randperm(slowList(end));
                fastList = randperm(fastList(end));
            end
            if mdl.acqOpt.zigzagOrder
                valLists = {slowList, fastList};
                currentVals = [1, 1];
                if ~isempty(mdl.ctrlPV)
                    currentVals(1) = mdl.ctrlPV.pv.val; 
                    valLists{1} = mdl.ctrlPV.vallist;
                end
                if ~isempty(mdl.ctrlPVFast)
                    currentVals(2) = mdl.ctrlPVFast.pv.val; 
                    valLists{2} = mdl.ctrlPVFast.vallist;
                end
                nmax = [length(slowList), length(fastList)];
                for num = 1:2
                    if mod(nmax(num), 2)
                        scan_array = [nmax(num):-2:1, 2:2:nmax(num)-1];
                    else
                        scan_array = [nmax(num):-2:2, 1:2:nmax(num)-1];
                    end
                    valList = valLists{num};
                    currentVal = currentVals(num);
                    [~, idxmin] = min(abs(valList - currentVal));
                    [~, idxmin] = min(abs(scan_array(:) - idxmin));
                    scan_array = circshift(scan_array, [0, -idxmin+1]);
                    if num == 1
                        slowList = scan_array;
                    else
                        fastList = scan_array;
                    end
                end
            end
            if mdl.acqOpt.spiralOrder
                [x, y] = meshgrid(slowList, fastList);
                x = x(:); y = y(:);
                r = max(abs(x - mean(x)), abs(y - mean(y)));
                p = mod(atan2(y - mean(y), x - mean(x)) + pi/4-1e-10, 2*pi);
                [~, ix] = sortrows([r, p]);
                slowList = [x(ix)'; 1:length(x)];
                fastList = y(ix);
            end
        end
        
        function pauseDataAcq(mdl)
            % manage acquisition pausing based on pause PV
            pauseValue = lcaGetSmart(mdl.acqOpt.pausePV);
            if pauseValue == 1
                warndlg('Data acqusition paused');
                beep;
                while pauseValue == 1
                    pause(1)
                    pauseValue = lcaGetSmart(mdl.acqOpt.pausePV);
                end
                warndlg('Data acqusition restarted');
                beep;
            end
        end
        
        function acquireInit(mdl)
            % initialize process and imgOpt properties
            mdl.process.displayExport=0;
            mdl.process.saved=0;
            mdl.process.loading=0;
            mdl.process.dataDisp=0;
            mdl.imgOpt.saveImg=0;
            mdl.imgOpt.showImg=0;
            mdl.imgOpt.holdImg=1;
            mdl.imgOpt.procImg=1;
        end
            
        
    end
    
    methods %PLOT METHODS
         
        function plotData(mdl) %, prescan)
%             if nargin < 2
%                 if isfield(mdl.data, 'prescan')
%                     prescan = mdl.data.prescan;
%                 else
%                     prescan = 0;
%                 end
%             end
%            THIS NEEDS LOGIC FOR UPDATING THE USE CHECKBOXES
%             if prescan
%                 nval = size(mdl.data.status);
%             else
%                 nval = getNumVals(mdl);
%             end            
            
            if ~any(mdl.data.status)
                notify(mdl, 'clearPlotAxes');
                return
            end
                       
            % create an array of all PVs with data to display
            use = mdl.data.status == 1;
            dispPV = struct('name',{},'val',{},'ts',{},'desc',{},'egu',{});
            if ~isempty(mdl.data.ctrlPV)
                dispPV = repmat(mdl.data.ctrlPV(1:mdl.numCtrlPV, use), [1, 1, mdl.acqOpt.numSamples]);
            end
            if isfield(mdl.data, 'readPV')
                dispPV = [dispPV; mdl.data.readPV(:, use, :)];
            end
            nPV = size(dispPV, 1);
            
            iPlane = 1;
            if strcmpi(mdl.wirePlane, 'y'), iPlane = 2; end
            beamStd = zeros(sum(use), 0);
            
            % Add PVs values if profmons used.
            if any(mdl.profmonId) && isfield(mdl.data,'profPV')
                dispPV = [dispPV; reshape(permute(mdl.data.profPV(:, use, :, :), [1 4 2 3]), [], sum(use), size(mdl.data.profPV, 3))];
            end
            
            % Add y values if wire scanner used.
            if mdl.wireId
                dispPV = [dispPV; mdl.data.wirePV([[0, 2] + iPlane, 6], use, :)];
            end
            
            % Add y values if emittance scan used.
            if mdl.emitId
                dispPV = [dispPV; mdl.data.twissPV(:, use, :)];
                beamStd = [beamStd, mdl.data.twissStd(use, :, mdl.imgOpt.selectedMethod)];
            end
            
            % Add y values if bunch length used.
            if mdl.blenId
                dispPV = [dispPV; mdl.data.blenPV(:, use, :)];
                beamStd = [beamStd, mdl.data.blenStd(use, :, mdl.imgOpt.selectedMethod)];
            end
            if nPV < size(dispPV, 1)
                val = num2cell(vertcat(dispPV(nPV+1:end, :).val));
                [dispPV(nPV+1:end,:).val] = deal(val{:, mdl.imgOpt.selectedMethod});
            end
            
            dispSize = cellfun('size',{dispPV.val},2);
            if ~all(dispSize == max(dispSize))
                for j = 1:numel(dispPV)
                    dispPV(j).val(1, end+1:max(dispSize)) = 0;
                end
            end
            
            % calculate some statistics for the disp PVs
            dispPVVal = reshape([dispPV.val], size(dispPV, 1), size(dispPV,2), []);
            idBeam = size(dispPVVal, 1) + (-(size(beamStd, 2)-1):0);
            [dispPV, dispPVVal] = calcPVs(mdl, dispPV, dispPVVal);
            dispPVVal(:, ~mdl.data.use(use, :)) = NaN;
            dispPVValMean = util_meanNan(dispPVVal, 3);
            dispPVValStd = util_stdNan(dispPVVal, 1, 3) ./ sqrt(sum(~isnan(dispPVVal), 3)); % !!! Error on mean value now
            dispPVValStd(idBeam, :) = permute(beamStd, [2, 1]);
            
            % put into workspace if requested
            if mdl.process.dataDisp
                assignin('base', 'dispPVVal', dispPVVal);
                assignin('base', 'dispPVValStd', dispPVValStd);
                assignin('base', 'dispPVValMean', dispPVValMean);
                evalin('base', 'openvar(''dispPVValStd'')');
                evalin('base', 'openvar(''dispPVValMean'')');
            end
                        
            % extract selected y PV
            id = mdl.plotOpt.YAxisId + mdl.numCtrlPV;
            yPV = dispPV(id,:,:);
            yPVVal = dispPVVal(id,:,:);
            yPVValMean = dispPVValMean(id,:);
            yPVValStd = dispPVValStd(id,:);
            
            % Generate x PV.
            id = mdl.plotOpt.XAxisId;
            if id == 0
                xPV.name = 'TIME'; xPV.desc='Elapsed Time'; xPV.egu='s';
                xPV = repmat(xPV, [1, size(yPV,2), mdl.acqOpt.numSamples]);
                xPVVal = reshape([yPV.ts], size(yPV,1), size(yPV,2), []) - yPV(1).ts;
                xPVValStd = std(xPVVal, 1, 3);
                xPVValMean = mean(xPVVal, 3);
            else
                xPV = dispPV(id,:,:);
                xPVVal = dispPVVal(id,:,:);
                xPVValStd = dispPVValStd(id,:);
                xPVValMean = dispPVValMean(id,:);
            end
            
            if ~isempty(mdl.ctrlPV)
                mdl.plotDataParam.ctrlPVLabel = mdl.ctrlPV.name;
                mdl.plotDataParam.ctrlPV = reshape(permute(dispPVVal(1,:,:), [1, 3, 2]), size(dispPVVal(1,:,:), 1), []);
                mdl.plotDataParam.ctrlPVAvg = reshape(permute(dispPVVal(1,:,1), [1, 3, 2]), size(dispPVVal(1,:,1), 1), []);
            end
            
            if ~isempty(mdl.ctrlPVFast)
                mdl.plotDataParam.ctrlPVFastLabel = mdl.ctrlPVFast.name;
                mdl.plotDataParam.ctrlPVFast = reshape(permute(dispPVVal(2,:,:), [1, 3, 2]), size(dispPVVal(2,:,:), 1), []);
                mdl.plotDataParam.ctrlPVFastAvg = reshape(permute(dispPVVal(2,:,1), [1, 3, 2]), size(dispPVVal(2,:,1), 1), []);
            end
            
            if mdl.acqOpt.numSamples > 1
                mdl.plotDataParam.SampleArray = repmat(1:mdl.acqOpt.numSamples, [1, numel(xPVVal)/mdl.acqOpt.numSamples]);
            end
            
            % Generate u PV.
            id = mdl.plotOpt.UAxisId; uPVVal = []; uPVValMean = [];
            uLabelStr = '';
            if id > 0
                uPV = dispPV(id,:,:);
                uPVVal = dispPVVal(id,:,:);
                %    uPVValStd=dispPVValStd(id,:);
                uPVValMean = dispPVValMean(id,:);
                if mdl.plotOpt.ULabel.name, uLabelStr = [uLabelStr, ' ', uPV(1).name]; end
                if mdl.plotOpt.ULabel.desc, uLabelStr = [uLabelStr, ' ', uPV(1).desc]; end 
                if mdl.plotOpt.ULabel.egu, uLabelStr = [uLabelStr, '(', uPV(1).egu, ')']; end 
                uLabelStr = strrep(uLabelStr, '_', '\_');
            
            end
            
            % if data needs to be averaged
            if mdl.plotOpt.showAverage
                xValList = xPVValMean;
                uValList = uPVValMean;
                yValList = yPVValMean;
                yStdList = yPVValStd;
                xStdList = xPVValStd;
                if ~all(xStdList), xStdList = xStdList*NaN; end
            else
                xValList = reshape(permute(xPVVal,[1, 3, 2]), size(xPVVal,1), []);
                uValList = reshape(permute(uPVVal,[1, 3, 2]), size(uPVVal,1), []);
                yValList = reshape(permute(yPVVal,[1, 3, 2]), size(yPVVal,1), []);
                yStdList = repmat(yValList,1,0);
            end
            
            % if data needs to be smoothed (convolved)
            if mdl.plotOpt.showSmoothing
                [xValList, yValList] = util_scanSmooth(xValList, yValList, mdl.plotOpt.defWindowSize);
            end
            
            % Fit functions.
            xFit = linspace(min(xValList(:)), max(xValList(:)), 100);
            par = [];
            for j = 1:size(yPVVal,1)
                xVal = xValList(min(j,end),:);
                yVal = yValList(j,:);
                yStd = yStdList(j,:);
                
                switch mdl.plotOpt.showFit
                    case 'No Fit'
                        yFit(j,:) = NaN * xFit;
                        yFitStd(j,:) = NaN * xFit;
                        strFitList{j} = '';
                    case 'Polynomial'
                        pOrd = min(mdl.plotOpt.showFitOrder, length(xVal)-1);
                        [par, yFit(j,:), parstd, yFitStd(j,:), chisq, d, rfe] = util_polyFit(xVal, yVal, pOrd, yStd, xFit);
                        ex = length(par)-1:-1:0;
                        lab = cellstr(char(64+(1:length(par)))')';
                        ch = [lab; num2cell(ex)];
                        strFit = sprintf('+ %s x^%d ', ch{:});
                    case 'Gaussian'
                        strFit = 'A exp((x - B)^2/C^2/2) + D';
                        [par, yFit(j,:), parstd, yFitStd(j,:), chisq, d, rfe] = util_gaussFit(xVal, yVal, 1, 0, yStd, xFit);
                    case 'Sine'
                        strFit = 'A sin((x - B)C) + D';
                        [par, yFit(j,:), parstd, yFitStd(j,:), chisq, d, rfe] = util_sineFit(xVal, yVal, 1, yStd, xFit);
                    case 'Parabola'
                        strFit = 'A (x - B)^2 + C';
                        [par, yFit(j,:), parstd, yFitStd(j,:), chisq, d, rfe] = util_parabFit(xVal, yVal, yStd, xFit);
                    case 'Erf'
                        strFit = 'A erfc(-(x - B)/C) + D';
                        [par, yFit(j,:), parstd, yFitStd(j,:), chisq, d, rfe] = util_erfFit(xVal, yVal, 1, yStd, xFit);
                end
                
                if ~strcmp(mdl.plotOpt.showFit, 'No Fit')
                    lab = cellstr(char(64+(1:length(par)))')';
                    str = [lab; num2cell([par, parstd]')];
                    strFitList{j} = [sprintf('y = %s\n',strFit) ...
                        sprintf('%s = %7.5g+-%7.5g\n',str{:}) ...
                        sprintf('\\chi^2/NDF = %5.3g\n',chisq) ...
                        sprintf('rms fit error = %5.3g %s',rfe,yPV(j).egu)];
                end
            end
            
            xLabelStr = '';
            if mdl.plotOpt.XLabel.name, xLabelStr = [xLabelStr, ' ', xPV(1).name]; end
            if mdl.plotOpt.XLabel.desc, xLabelStr = [xLabelStr, ' ', xPV(1).desc]; end 
            if mdl.plotOpt.XLabel.egu, xLabelStr = [xLabelStr, '(', xPV(1).egu, ')']; end
            xLabelStr = strrep(xLabelStr, '_', '\_');
            yLabelStr = '';
            if mdl.plotOpt.YLabel.name, yLabelStr = [yLabelStr, ' ', yPV(1).name]; end
            if mdl.plotOpt.YLabel.desc, yLabelStr = [yLabelStr, ' ', yPV(1).desc]; end 
            if mdl.plotOpt.YLabel.egu, yLabelStr = [yLabelStr, '(', yPV(1).egu, ')']; end 
            yLabelStr = strrep(yLabelStr, '_', '\_');
            
            mdl.fitPar = par;
            
            % store the plot data somewhere it can be found
            mdl.plotDataParam.xPV = xPV;
            mdl.plotDataParam.yPV = yPV;
            if mdl.plotOpt.UAxisId, mdl.plotDataParam.uPV = uPV; end
            mdl.plotDataParam.xValList = xValList;
            mdl.plotDataParam.yValList = yValList;
            mdl.plotDataParam.uValList = uValList;
            mdl.plotDataParam.yPVVal = yPVVal;
            if mdl.plotOpt.showAverage    
                mdl.plotDataParam.xStdList = xStdList;
                mdl.plotDataParam.yStdList = yStdList;
            end
            mdl.plotDataParam.xPVValMean = xPVValMean;
            mdl.plotDataParam.yPVValMean = yPVValMean;
            mdl.plotDataParam.uPVValMean = uPVValMean;
            mdl.plotDataParam.xFit = xFit;
            mdl.plotDataParam.yFit = yFit;
            mdl.plotDataParam.yFitStd = yFitStd;
            mdl.plotDataParam.strFitList = strFitList;
            mdl.plotDataParam.xLabelStr = xLabelStr;
            mdl.plotDataParam.yLabelStr = yLabelStr;
            mdl.plotDataParam.uLabelStr = uLabelStr;
            
            
            notify(mdl, 'plotDataReady');
        end
        
        function plotProfile(mdl)
            % no data analysis need be done before the image data is
            % plotted
            notify(mdl, 'plotProfileReady')
        end
        
        function plotAxisControl(mdl, val, ax)
            % wrapper for setting plot axis drop down options
            if nargin < 3
                plotYAxisControl(mdl, val);
                plotXAxisControl(mdl, val);
                plotUAxisControl(mdl, val);
            else
                switch ax
                    case 'X'
                        plotXAxisControl(mdl, val);
                    case 'Y'
                        plotYAxisControl(mdl, val);
                    case 'U'
                        plotUAxisControl(mdl, val);
                end
            end
            
        end
        
        function plotXAxisControl(mdl, val, prescan)
            % generate namelist for X axis drop down
            if nargin < 3, prescan = 0; end
            if isfield(mdl.data, 'prescan'), prescan = 1; end
            if isempty(val)
                val = mdl.plotOpt.XAxisId; 
            else
                val = find(contains(mdl.plotOpt.XAxisNameList, val), 1, 'first') - 1;
            end
            
            ctrlPVNames = {};
            if ~isempty(mdl.ctrlPV)
                ctrlPVNames{end + 1} = mdl.ctrlPV.name;
            end
            if ~isempty(mdl.ctrlPVFast)
                ctrlPVNames{end + 1} = mdl.ctrlPVFast.name;
            end
            if ~mdl.numCtrlPV
                lettList = {}; 
            else
                lettList = strcat(mdl.getLetters(mdl.numCtrlPV), {': '}, ctrlPVNames');
            end
            names = [{'TIME'}; lettList; getPlotList(mdl)];
            
            mdl.plotOpt.XAxisId = min(val, length(names) - 1);
            mdl.plotOpt.XAxisNameList = names;
            notify(mdl, 'updateAxisDropDown');
            
            acquireUpdate(mdl, prescan);
        end
        
        function plotYAxisControl(mdl, val, prescan)
            % generate namelist for Y axis list box. This excludes the ctrl
            % PVs
            
            if nargin < 3, prescan = 0; end
            if isfield(mdl.data, 'prescan'), prescan = 1; end
            if isempty(val)
                val = mdl.plotOpt.YAxisId; 
            else
                val = find(contains(mdl.plotOpt.YAxisNameList, val));
            end
            names = getPlotList(mdl);
            val = val(val <= length(names));
            if isempty(val), val = 1; end
            mdl.plotOpt.YAxisId = val;
            mdl.plotOpt.YAxisNameList = names;
            notify(mdl, 'updateAxisDropDown');
            
            acquireUpdate(mdl, prescan);
            
        end
        
        function plotUAxisControl(mdl, val, prescan)
            % generate namelist for U axis drop down
            
            if nargin < 3, prescan = 0; end
            if isfield(mdl.data, 'prescan'), prescan = 1; end
            if isempty(val)
                val = mdl.plotOpt.UAxisId; 
            else
                val = find(contains(mdl.plotOpt.UAxisNameList, val)) - 1;
            end
            
            ctrlPVNames = {};
            if ~isempty(mdl.ctrlPV)
                ctrlPVNames{end + 1} = mdl.ctrlPV.name;
            end
            if ~isempty(mdl.ctrlPVFast)
                ctrlPVNames{end + 1} = mdl.ctrlPVFast.name;
            end
            names = [{'none'}; ctrlPVNames'; getPlotList(mdl)];
            mdl.plotOpt.UAxisId = min(val, length(names) - 1);
            mdl.plotOpt.UAxisNameList = names;
            notify(mdl, 'updateAxisDropDown');
            
            acquireUpdate(mdl, prescan);
            
        end
        
        function list = getPlotList(mdl)
            % generate the lettered list of names
            list = [mdl.nameList.readPV; mdl.nameList.profPV; mdl.nameList.wirePV;...
                mdl.nameList.emitPV; mdl.nameList.blenPV; mdl.nameList.calcPV];
            nCalc = length(mdl.nameList.calcPV);
            nCtrl = mdl.numCtrlPV;
            lettList = strcat(mdl.getLetters(nCtrl + length(list)), {': '});
            lettList(nCtrl + length(list) - nCalc + 1:end) = {'*: '};
            if ~isempty(list)
                list = strcat(lettList(nCtrl+1:end), reshape(list, [], 1));
            end
        end
        
        function [dispPV, dispPVVal] = calcPVs(mdl, dispPV, dispPVVal)
            % evaluate user entered formula
            nPV = size(dispPV, 1);
            lett = mdl.getLetters(nPV);
            str = sprintf(',%s', lett{:});
            fDecl = ['f=@(' str(2:end) ') '];
            valList = num2cell(dispPVVal, [2, 3]);
            for j = 1:length(mdl.nameList.calcPV)
                name = lower(mdl.nameList.calcPV{j});
                x = NaN;
                try
                    evalc([fDecl, name]);
                    x = f(valList{:});
                catch
                end
                dispPVVal(nPV+j,:) = x(:);
                [dispPV(nPV+j,:,:).name] = deal(name);
                [dispPV(nPV+j,:,:).val] = deal(0);
                [dispPV(nPV+j,:,:).ts] = deal(dispPV(1,:,:).ts);
                [dispPV(nPV+j,:,:).desc] = deal('');
                [dispPV(nPV+j,:,:).egu] = deal('');
            end
        end
    end
    
    methods % SETTER METHODS
        
        function setAcquireStatus(mdl, status, abort)
            % set flag for whether acquisition is in progress, and whether
            % the acquisition was aborted
            if nargin < 3, abort = 0; end
            mdl.acqOpt.abortStatus = abort;
            mdl.acqOpt.acquireStatus = status;
            notify(mdl, 'acqStatusChanged');
        end
        
        function setAcqOpt(mdl, prop, val)
            % general setter for setting a property of the acqOpt struct
            if strcmp(prop, 'numSamples')
                sampleControl(mdl, val);
                return
            end
            mdl.acqOpt.(prop) = val;
        end
        
        function setImgOpt(mdl, prop, val)
            % general setter for setting a property of the imgOpt struct
            mdl.imgOpt.(prop) = val;
            notify(mdl, 'imgOptChanged');
            acquirePlot(mdl);
        end
        
        function setPlotOpt(mdl, prop, val)
            % general setter for setting a property of the plotOpt struct
            mdl.plotOpt.(prop) = val;
            notify(mdl, 'plotOptChanged');
            prescan = 0;
            if isfield(mdl.data, 'prescan'), prescan = 1; end
            acquirePlot(mdl, prescan);
        end
        
        function setPlotLabels(mdl, opts)
            % set the plot label options
            mdl.plotOpt.XLabel.name = opts.XLabelname;
            mdl.plotOpt.XLabel.desc = opts.XLabeldesc;
            mdl.plotOpt.XLabel.egu = opts.XLabelegu;
            mdl.plotOpt.YLabel.name = opts.YLabelname;
            mdl.plotOpt.YLabel.desc = opts.YLabeldesc;
            mdl.plotOpt.YLabel.egu = opts.YLabelegu;
            mdl.plotOpt.ULabel.name = opts.ULabelname;
            mdl.plotOpt.ULabel.desc = opts.ULabeldesc;
            mdl.plotOpt.ULabel.egu = opts.ULabelegu;
            acquirePlot(mdl);
        end
        
        function ctrlPVReset(mdl, relative, valList)
            % reset the ctrl PVs to their initial values
            if nargin < 3, valList = []; end
            if nargin < 2, relative = 0; end
            
            for fast = [0, 1]
                if fast
                    pv = mdl.ctrlPVFast;
                    evnt = 'resettingCtrlPVFast';
                else
                    pv = mdl.ctrlPV;
                    evnt = 'resettingCtrlPV';
                end
                   
                
                if isempty(pv), continue; end
                if relative % reset to negative of last set value
                    PVvalList = pv.vallist;
                    val = -PVvalList(valList(end));
                else
                    val = pv.pv.val;
                end
                fprintf('Resetting val: %g \n', val);
                mdl.process.(evnt) = 1;
                notify(mdl, 'ctrlPVSetStatusChanged');
                pvReset(pv, relative, valList);
                mdl.process.(evnt) = 0;
                pause(pv.settletime)
                notify(mdl, 'ctrlPVSetStatusChanged');
            end
            doLEMTrim(mdl);
        end
        
        function ctrlPVSet(mdl, fast, init, relative, refList, element)
            % set ctrl PV to the value pointed to by the current index
            if nargin < 6, element=[]; end
            if nargin < 5, refList=[]; end
            if nargin < 4, relative=0; end
            if nargin < 3, init=0;end
            
            if fast
                try
                    pv = mdl.ctrlPVFast;
                catch % if there is no ctrlPVFast
                    return
                end
                evnt = 'settingCtrlPVFast';
            else
                try
                    pv = mdl.ctrlPV;
                catch % if there is no ctrlPV
                    return
                end
                evnt = 'settingCtrlPV';
            end
            
            mdl.process.(evnt) = 1;
            notify(mdl, 'ctrlPVSetStatusChanged');
            pvSet(pv, relative, refList, element);
            mdl.process.(evnt) = 0;
            if ~isempty(mdl.acqOpt.settlePV)
                % logic for reacting to a settle pv
                fprintf('Waiting for %s',char(mdl.acqOpt.settlePV));
                pause(.5); 
                timeOut=now;
                while lcaGetSmart(mdl.acqOpt.settlePV, 0,'double') ~= mdl.acqOpt.waitInit
                    pause(.5);
                    if now > timeOut+1/24/60*5
                        disp_log('Timeout occured');
                        break
                    end
                    % 5 min timeout
                end
            else
                % if init, include waitInit
                pause(pv.settletime * (1-2*init) + mdl.acqOpt.waitInit*init);
            end
            notify(mdl, 'ctrlPVSetStatusChanged');
            doLEMTrim(mdl);
        end
        
        function setBest(mdl)
            % set the optimal value according to the fit parameters
            if mdl.numCtrlPV < 1 || isempty(mdl.fitPar) || numel(mdl.fitPar) < 2
                return
            end
            
            str = questdlg(['Do you want to set ' mdl.ctrlPV.name ' to best value at ' num2str(mdl.fitPar(2)) '?'],'Set Best Value','Yes','No','No');
            if ~strcmp(str,'Yes'), return, end
            setNewVal(mdl.ctrlPV, mdl.fitPar(2));
            ctrlPVReset(mdl);
            
        end
        
        function setCtrlPV(mdl, prop, val, fast)
            % wrapper to change the properties of the control PV without
            % the GUI
            
            if nargin < 4, fast = 0; end
            switch prop
                case 'name'
                    if fast
                        % if it doesn't exist yet, create a default ctrlPV,
                        % otherwise create a new ctrlPV with the same other
                        % attributes as the current one, wait for the user
                        % to reset those separately.
                        if isempty(mdl.ctrlPVFast)
                            ctrlPVControl(mdl, fast, val);
                        else
                            low = mdl.ctrlPVFast.range(1);
                            high = mdl.ctrlPVFast.range(2);
                            numvals = mdl.ctrlPVFast.numvals;
                            settletime = mdl.ctrlPVFast.settletime;
                            ctrlPVControl(mdl, fast, val, low, high, numvals, settletime)
                        end
                    else
                        if isempty(mdl.ctrlPV)
                            ctrlPVControl(mdl, fast, val);
                        else
                            low = mdl.ctrlPV.range(1);
                            high = mdl.ctrlPV.range(2);
                            numvals = mdl.ctrlPV.numvals;
                            settletime = mdl.ctrlPV.settletime;
                            ctrlPVControl(mdl, fast, val, low, high, numvals, settletime)
                        end
                    end
                case 'range'
                    rangeControl(mdl, val(1), val(2), fast);
                case 'numvals'
                    numvalsControl(mdl, val, fast);
                case 'settletime'
                    settletimeControl(mdl, val, fast)
                case 'idx'
                    ctrlPVIdxControl(mdl, val, fast);
                case 'relative'
                    relativeControl(mdl, val, fast);
                otherwise
                    mdl.status = 'Property not recognized';
                    notify(mdl, 'statusChanged');
            end
            notify(mdl, 'ctrlPVChanged');
            notify(mdl, 'ctrlPVFastChanged');
        end
        
        function setDevice(mdl, type, deviceName)
            % wrapper to set up an external device, including profile
            % monitors, emittanc  measurement, wire scanner, and bunch
            % lenght monitor
            
            % force the device to an epics name
            deviceName = model_nameConvert(deviceName, 'EPICS');
            if isempty(deviceName), deviceName = 'none'; end
            
            % direct to the correct control funciton for the device
            % comments in the first case apply to the rest
            switch type
                case 'profmon'
                    % force the list to a name type compatible with the
                    % device name
                    profListEPICS = model_nameConvert(mdl.profmonList, 'EPICS');
                    idx = find(contains(profListEPICS, deviceName));
                    % the control function wants 0 for none
                    if isempty(idx)
                        idx = 0;
                    end
                    profmonControl(mdl, idx + 1);
                case 'wire'
                    wireListEPICS = model_nameConvert(mdl.wireList, 'EPICS');
                    idx = find(contains(wireListEPICS, deviceName));
                    if isempty(idx)
                        idx = 0;
                    end
                    wireControl(mdl, idx + 1);
                case 'emit'
                    emitListEPICS = model_nameConvert(mdl.emitList, 'EPICS');
                    idx = find(contains(emitListEPICS, deviceName));
                    if isempty(idx)
                        idx = 0;
                    end
                    emitControl(mdl, idx + 1);
                case 'blen'
                    blenListEPICS = model_nameConvert(mdl.blenList, 'EPICS');
                    idx = find(contains(blenListEPICS, deviceName));
                    if isempty(idx)
                        idx = 0;
                    end
                    blenControl(mdl, idx + 1);
                otherwise
                    mdl.status = 'device type not recognized';
                    notify(mdl, 'statusChanged');
            end
        end
        
        function setReadPVs(mdl, pvs)
            % wrapper to set the read PV namelist
            readPVNameListControl(mdl, pvs);
        end
        
        function setIndex(mdl, index)
            % wrapper to set the beampath
            indexControl(mdl, index);
        end
        
        function setMKB(mdl, mkb, low, high, numvals, settletime)
            % wrapper for setting up a multiknob
            if nargin < 6, settletime = 1; end
            if nargin < 5, numvals = 1; end
            if nargin < 4, high = 1; end
            if nargin < 3, low = 0; end
            ctrlMKBControl(mdl, mkb, low, high, numvals, settletime);
        end
        
        function seteDef(mdl, eDefNumber)
            % connect to an existing eDef
            if eDefNumber == 0
                mdl.acqOpt.BSA = 0;
            else
                mdl.acqOpt.BSA = 1;
                mdl.eDefNumber = eDefNumber;
            end
        end
            
        function setBSA(mdl, rate)
            % set up or turn off BSA acquisition
            idx = find(contains(mdl.BSAOptions, rate));
            acquireBSAControl(mdl, idx - 1);
        end
        
        function setFormula(mdl, formula)
            % set the formula
            calcPVControl(mdl, formula); 
        end
        
        function setMetaData(mdl, metaDataPVs)
            % set meta data PVs
            cancd = mdlDataRemove(mdl);
            if ~cancd
                if isempty(strtrim(metaDataPVs))
                    metaDataPVs = [];
                end
                mdl.nameList.metaDataPV = metaDataPVs; 
            end
        end
        
        function setEmitType(mdl, type)
            % wrapper for emit type
            emitTypeControl(mdl, type);
        end
        
        function setWirePlane(mdl, xy)
            % wrapper for wire plane
            wirePlaneControl(mdl, xy);
        end
        
    end
    
    methods % GETTERS
         
        function ctrlPV = getCtrlPV(mdl, fast)
            % return ctrl PV properties for use by the view
            ctrlPV = struct();
            if fast
                if isempty(mdl.ctrlPVFast)
                    ctrlPV = [];
                    return
                end
                ctrlPV.name = mdl.ctrlPVFast.name;
                ctrlPV.low = num2str(mdl.ctrlPVFast.range(1));
                ctrlPV.high = num2str(mdl.ctrlPVFast.range(2));
                ctrlPV.val = mdl.ctrlPVFast.pv.val;
                ctrlPV.units = mdl.ctrlPVFast.pv.egu;
                ctrlPV.vallist = mdl.ctrlPVFast.vallist;
                ctrlPV.numvals = mdl.ctrlPVFast.numvals;
                ctrlPV.idx = mdl.ctrlPVFast.idx;
                ctrlPV.settletime = mdl.ctrlPVFast.settletime;
                ctrlPV.currentVal = mdl.ctrlPVFast.currentVal;
                ctrlPV.relative = mdl.ctrlPVFast.relative;
            else
                if isempty(mdl.ctrlPV)
                    ctrlPV = [];
                    return
                end
                ctrlPV.name = mdl.ctrlPV.name;
                ctrlPV.low = num2str(mdl.ctrlPV.range(1));
                ctrlPV.high = num2str(mdl.ctrlPV.range(2));
                ctrlPV.val = mdl.ctrlPV.pv.val;
                ctrlPV.units = mdl.ctrlPV.pv.egu;
                ctrlPV.vallist = mdl.ctrlPV.vallist;
                ctrlPV.numvals = mdl.ctrlPV.numvals;
                ctrlPV.idx = mdl.ctrlPV.idx;
                ctrlPV.settletime = mdl.ctrlPV.settletime;
                ctrlPV.currentVal = mdl.ctrlPV.currentVal;
                ctrlPV.relative = mdl.ctrlPV.relative;
            end
        end
        
        function plotOpt = getPlotOpt(mdl)
            % return plot options
            plotOpt = mdl.plotOpt;
        end
        
        function data = getData(mdl)
            % return data struct
            data = mdl.data;
        end
        
        function plotData = getPlotData(mdl)
            % return data for plotting
            plotData = mdl.plotDataParam;
        end
        
        function acqOpt = getAcqOpt(mdl)
            % return acquisition options
            acqOpt = mdl.acqOpt;
        end
        
        function imgOpt = getImgOpt(mdl)
            % return image options
            imgOpt = mdl.imgOpt;
        end
        
        function imgData = getImgData(mdl, idx, sample)
            % return image data
            imgData = mdl.data.dataList(idx, sample, :);
        end
        
        function process = getProcessStatus(mdl)
            % return process struct
            process = mdl.process;
        end
        
        function [use, useFast, useSample] = getUse(mdl)
            % indicate whether the current ctrlPV/ctrlPVFast/sample has
            % been set to use
            use = []; useFast = []; useSample = [];
            if ~isfield(mdl.data, 'use'), return; end
            
            if isempty(mdl.ctrlPVFast)
                use = all(mdl.data.use(mdl.ctrlPV.idx, :));
                useSample = mdl.data.use(mdl.ctrlPV.idx, mdl.whichSample);
            else
                use = reshape(mdl.data.use, [mdl.ctrlPVFast.numvals, mdl.ctrlPV.numvals, mdl.acqOpt.numSamples]);
                use = use(:, mdl.ctrlPV.idx, :);
                use = all(use(:));
                idx = getLinearIdx(mdl);
                useFast = all(mdl.data.use(idx, :));
                useSample = mdl.data.use(idx, mdl.whichSample);
            end
        end
        
        function letterList = getLetterList(mdl)
            % return the lettered PV list, useful for knowing what letters
            % to use in a formula
            letterList = mdl.plotOpt.XAxisNameList(2:end); 
        end

    end
    
    methods(Static) %STATIC METHODS

        function lettList = getLetters(nPV)
            % get a list of letters for indexing the variables in the plot
            % axis drop down lists
            lett = 'a':'z';
            [lett1, lett2] = meshgrid(lett);
            lett = [cellstr(lett'); cellstr([lett1(:) lett2(:)])];
            lett(ismember(lett, iskeyword)) = [];
            lettList = cell(nPV, 1);
            lettList(1:min(length(lett), end)) = lett(1:min(nPV, end));
            
        end
        
        function par = decker_corr(a, b)
            nd=size(a,2);
            ns=size(a,3);
            par=repmat(kron(eye(nd),[1 0])* ...
                lscov(kron(eye(nd),ones(ns,2)).* ...
                repmat([reshape(squeeze(a)',[],1) ones(nd*ns,1)],1,nd), ...
                reshape(squeeze(b)',[],1)),1,ns);
        end
        
        function valid = pvValidate(pv)
            valid = strcmpi(pv, 'TIME');
            valid = valid || startsWith(upper(pv), 'MKB');
            if ~valid
                timeout = lcaGetTimeout;
                lcaSetTimeout(0.1);
                [~, valid] = util_readPV(pv);
                lcaSetTimeout(timeout);
            end
            valid = valid || isempty(pv);
        end

        function fig = locateApp()
            name = 'corrPlot_guiDEV';
            fig = findall(0, 'Tag', name);
            if isempty(fig)
                fig = findall(0, 'Name', name);
            end
        end
        
    end
    
end
