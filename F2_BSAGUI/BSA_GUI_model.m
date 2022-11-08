classdef BSA_GUI_model < handle
    % Model class for BSA_GUI
    %
    % This class holds the state of the BSA_GUI, the acquired data, and all
    % relevant properties related to those 2 categories. It contains
    % functions to respond to user interactions from the GUI, and to
    % manipulate the data.
    
    properties
        app % instance of the GUI object
       
        ROOT_NAME % list of PV names
        the_matrix % number of PVs x numPoints_acq matrix containing data returned by lcaGet
        isPV % logical array whether requested PVs are valid or not
        t_stamp % time of last point in data
        time_stamps % for private eDefs, time matrix for all points
        z_positions % Z location of selected devices
        constants
        LM
        
        bpms % data struct on beam position monitors
        facetBPMS
        HXR % struct on HXR bpms for dual energy calculations
        SXR % struct on HXR bpms for dual energy calculations
        
        BSD_inputs % previous field values for BSD_window
        BSD_ROOT_NAME % root names returned from BSA datastore
        
        eDef % eDef selected in eDef menu
        eDefStr % unchanged eDef value, used to restore private eDef names after use
        eDefs = {'Private', 'CUS1H','CUSTH','CUSBR','CUH1H','1H','TH','BR','CUHTH','CUHBR'} % list of available eDefs
        eDefNumber % eDef number for private eDef
        have_eDef = 0 % default 0, 1 if private eDef setup has been executed
        reserving = 0 % flag for eDef actually reserved
        
        formula % formula used to create new variable
        formula_string % string of formula for new variable
        formula_pvs % pvs used to create new variable
        
        host % server hostname
        facet
        lcls
        linac = 'CU' % CU or SC
        dev % 1 if on development network, 0 if on production
        destination = '' % used to infer beampath
        beamCode % beam code for eDef setup
        HXRBR % HXR beam rate
        SXRBR % SXR beam rate
        facetBR
        acqSCP = 0
        isSCP
        hasSCP
        bufferRatesText % string to display buffer rates of current machine
        
        idxA % indices of ROOT_NAME  subsetted by search A
        idxB % indices of ROOT_NAME  subsetted by search B
        PVA % PV selected in list A
        PVB % PV selected in list B
        PVC % value of created variable
        PVListA % list of PVs subset by search string A
        PVListB % list of PVs subset by search string A
        
        isBR % 1 if eDef is BR
        isHxr % 1 if eDef is for HXR
        isSxr % 1 if eDef is for SXR
        
        waitenoload = 0 % 0 or 1 for enoload checkbox status
        timeout % time willing to wait to acquire data
        numPoints_user = 2800
        numPoints_acq % number of points actually acquired
        
        multiplot = 0 % reflects multiplot check box
        multiplot_same = 0 % change to 1 to plot traces on the same figure
        new_model = 1 % pushbutton value for initiating a new accelerator model
        offset % user entered offset value
        PSDstart = 58 % low end of PSD range for Z PSD analysis
        PSDend = 60 % high end of PSD range for Z PSD analysis
        searchStringB % hold this for ALL Z plot label
        z_options = struct('AllBSA', 1, 'HorzNoDispersion', 1, 'ModelBeamEnergy', 1, 'ModelBeamSigma', 1,...
            'Dispersion', 1, 'XYFactor', 1, 'VertRMS', 1, 'HorzRMS', 1, 'YBPMCorr', 1, 'XBPMCorr', 1,...
            'VertNormRMS', 1, 'HorzNormRMS', 1, 'NewModel', 0) % return value of z_options
        
        other_fields % catch field if uploaded data is
        process % holder for whether data saved properly
        status % generally informing of an error, communicate to view
        dataAcqStatus % status specifically as it relates to data acquisition
        fileName % name of file to save to
        
        default_plot_vars % default list for plot variable drop down, loaded from constants
        current_plot_vars = {} % plot variables added by user (PVA, PVB, etc.)
        currentVar % variable currently selected in drop down menu
        optx % options for X drop down menu
        opty % options for Y drop down menu

        createVarApp % create variable mlapp object
        createVar_fields % saved fields for restoring last entered createVarApp settings
        zOptApp % z options mlapp object
    end
    
    events(NotifyAccess = public)
        AcqSCPChanged % change in acquire SCP flag
        AcqStatusChanged % change the data acquisition status message
        BufferRatesChanged % update the BSA buffer rate text
        DataAcquired % update the actual number of points label
        eDefOptionsChanged % update the eDef menu
        NumPointsChanged % update the num points edit field
        PlotOptionsChanged % update plot variable menus
        PVChanged % update selected PVs
        PVListChanged % update PV lists
        Init % tells GUI to initialize the interface for a particular setting (dev, facet, etc)
        StatusChanged  % update status message box
    end
    
    
    
    methods % MODEL 
        
        function mdl = BSA_GUI_model(app)
            % Construct a BSA_GUI_model instance for holding data and state
            % of BSA GUI. 
            
            mdl.app = app;
            mdl.constants = bsagui_constants();
        end
        
        function mdlInit(mdl)
            % Populate model with initial server and accelerator conditions
            sys = getSystem();
            if strcmp(sys, 'SYS1')
                mdl.facet = 1;
                mdl.lcls = 0;
            elseif strcmp(sys, 'SYS0')
                mdl.facet = 0;
                mdl.lcls = 1;
            else
                warndlg('BSA GUI not supported on this system')
                return
            end
            mdl.dev = startsWith(getenv('MATLABDATAFILES'),'/nfs');
            
          
            if mdl.facet
                mdl.facetBR = mdl.getFacetRate;
                mdl.bufferRatesText = sprintf('FACET Buffer Rate: %d HZ', mdl.facetBR);
                mdl.default_plot_vars = mdl.constants.defaultPlotVars.facet;
                notify(mdl, 'Init');
                mdl.eDefs = geteDefMenu(mdl);
                mdl.eDef = 'BR';
            else
                % Default to CU if run on lcls server, dev or prod
                [mdl.HXRBR, mdl.SXRBR] = mdl.getCURates;
                mdl.bufferRatesText = sprintf('HXR Buffer Rate: %d HZ      SXR Buffer Rate: %d HZ', mdl.HXRBR, mdl.SXRBR);
                if mdl.dev
                    mdl.default_plot_vars = mdl.constants.defaultPlotVars.dev;
                    mdl.eDefs = mdl.constants.menuitems.dev;
                    mdl.eDef = 'CUH';
                    notify(mdl, 'Init');
                else
                    % Default to CUXBR for X beamline with higher beamrate
                    % addpath('/home/physics/LEMSC/matlab/toolbox') I think
                    % this was added accidentally? Left it here in case it
                    % breaks something 10/12/22 JR
                    mdl.default_plot_vars = mdl.constants.defaultPlotVars.CU;
                    mdl.eDefs = mdl.constants.menuitems.CU;
                    beamLines = {'CUH','CUS'};
                    currentLine = beamLines{(mdl.SXRBR > mdl.HXRBR) + 1};
                    mdl.eDef = [currentLine 'BR'];
                    mdl.destination = ['CU_' currentLine(3) 'XR'];
                end
            end
            mdl.eDefStr = mdl.eDef;
            updateRootNames(mdl);
            mdl.bpms = bsagui_setupBPMS(mdl);
            notify(mdl, 'eDefOptionsChanged');
        end
        
        function mdlReset(mdl, whichPV)
            % reset selected PV and PV lists to default configuration
            PVList = mdl.ROOT_NAME;
            idxProp = strcat("idx", whichPV);
            mdl.(idxProp) = 1:length(mdl.ROOT_NAME);
            PVprop = strcat("PV", whichPV);
            mdl.(PVprop) = [];
            PVListProp = strcat('PVList', whichPV);
            mdl.(PVListProp) = PVList;
            generatePlotVars(mdl);
            notify(mdl, 'PVListChanged')
        end
        
        function mdlClose(mdl)
            if mdl.have_eDef
                releaseeDef(mdl);
            end
        end
        
    end
        
    methods
        
        function updateRootNames(mdl, varargin)
            %Called on initialization and change in eDef. Changes the list
            %of PVs, calls BPMS setup function, and sets device z_positions
            if length(mdl.eDef) < 3
                mdl.isBR = true;
                mdl.isSxr = false;
                mdl.isHxr = false;
            else
                mdl.isSxr = strcmp(mdl.eDef(3),'S');
                mdl.isHxr = strcmp(mdl.eDef(3),'H');
                mdl.isBR = false;
            end
            
            [mdl.ROOT_NAME, mdl.z_positions] = bsagui_getRootNames(mdl);
            
            mdl.idxA = 1:1:length(mdl.ROOT_NAME);
            mdl.idxB = 1:1:length(mdl.ROOT_NAME);
            
            mdl.PVListA = mdl.ROOT_NAME;
            mdl.PVListB = mdl.ROOT_NAME;
            
            mdl.bpms = bsagui_setupBPMS(mdl);
            
            notify(mdl, 'PVListChanged');
            
        end
                
        function [hxr_idx, sxr_idx, neither_idx] = splitNames(mdl)
            % Split the indices of ROOT_NAME into devices in the HXR list,
            % SXR list, and neither (as a safety net)
            
            hxr_names = meme_names('tag','LCLS.CUH.BSA.rootnames','sort','z');
            sxr_names = meme_names('tag','LCLS.CUS.BSA.rootnames','sort','z');
            hxr_idx = contains(mdl.ROOT_NAME,hxr_names);
            sxr_idx = contains(mdl.ROOT_NAME,sxr_names);
            neither_idx = ~contains(mdl.ROOT_NAME,hxr_names) & ~contains(mdl.ROOT_NAME,sxr_names);
            
        end
        
        function [hxr_pulses, sxr_pulses] = splitPulses(mdl)
            % Identify which pulses in a dataset went
            % through the HXR undulator, and which the SXR undulator
            
            % Extract the modifier bit identifying the pulse
            mod_bit = startsWith(mdl.ROOT_NAME, "PATT:SYS0:1:MODIFIER1");
            mod_bit_data = mdl.the_matrix(mod_bit, :);
            bc = bitand(bitshift(mod_bit_data, -8), hex2dec('0000001f'));
            sxr_pulses = bc == 2;
            hxr_pulses = bc == 1;
            
        end
                                
        function generatePlotVars(mdl, varargin)
            % Generate X and Y list of variables for the plot var drop down
            % menus

            mdl.optx = mdl.default_plot_vars;
            mdl.opty = mdl.current_plot_vars;
            opts = {};
            n = 0; % counter of how many variables there are for the YMenu
            
            %add PVC
            if ~isempty(mdl.PVC)
                formstring=func2str(mdl.formula);
                formstring=formstring(length(strtok(formstring,')'))+2:length(formstring));
                mdl.formula_string=formstring;
                opts = [{formstring}];
                n = n + 1;
            end
            
            %add PVB
            if ~isempty(mdl.PVB)
                opts=[mdl.PVB,opts];
                n = n + 1;
            end
            
            %add PVA
            if ~isempty(mdl.PVA)
                opts=[mdl.PVA,opts];
                n = n + 1;
            end
            
            % Either set opty as an empty list, or sort it with the newest
            % variable at the top
            if isempty(mdl.opty) || isempty(opts)
                mdl.opty = unique(opts, 'stable');
            else
                hasvar = contains(opts,mdl.opty);
                mdl.opty = unique([opts(~hasvar), opts(hasvar)], 'stable');
            end
            mdl.optx = [mdl.opty, mdl.optx];

            notify(mdl, 'PlotOptionsChanged');
            if ~isempty(varargin)
                mdl.currentVar = varargin{1};
                notify(mdl, 'PVChanged');
            end
        end
        
        function calcVariable(mdl, formula_str_raw, pvs)
            % Create a custom variable. This function is called from the 
            % createVar.mlapp, and takes the user inputs from that
            % interface to return a new variable to the BSA GUI itself
            
            
            s = ''; % this will be the string that holds the list of arguments
            l = 'a'; % start letter for identifying which PV is which
            % iterate over pvs to create list of letters for formula
            % argument string and single string of pvs
            varstring = [];
            for i = 1:length(pvs)
                pv = pvs{i};
                varstring = [varstring pv ' '];
                s = [s ',' l];
                l = char(l+1);
            end
            mdl.formula_pvs = varstring;
            s = ['@(',s(2:length(s)),')'];
            formula_str = strcat(s,formula_str_raw); %function needs to look something like @(args)function
            mdl.formula = str2func(formula_str{1}); % create formula from string
            args = {};
            % create array of arguments
            for argidx = 1:length(pvs)
                arg = pvs{argidx};
                arg = arg(3:length(arg));
                argdata = mdl.the_matrix(startsWith(mdl.ROOT_NAME,arg),:);
                args{length(args)+1} = argdata;
            end
            
            mdl.PVC = mdl.formula(args{:}); % calculate formula output
            
            mdl.createVar_fields.formula = formula_str;
            mdl.createVar_fields.pvs = pvs;
            
            generatePlotVars(mdl);
            
        end
                        
        function linacSwitched(mdl, linac)
            % Update model with appropriate property changes based on
            % switch of Linac selection
            mdl.linac = linac;
            if mdl.have_eDef, releaseeDef(mdl); end
            mdl.eDefs = geteDefMenu(mdl);
            
            mdl.PVA = [];
            mdl.PVB = [];
            mdl.PVC = [];
            mdl.bpms = [];
            mdl.createVar_fields = [];
            
            switch mdl.linac
                case 'SC'
                    mdl.numPoints_user = mdl.constants.bufferSize.SC;
                    mdl.bufferRatesText = mdl.getSCRates;
                    mdl.default_plot_vars = mdl.constants.defaultPlotVars.SC;
                    mdl.eDef = 'Private';
                    updateRootNames(mdl);
                case 'CU'
                    mdl.numPoints_user = min(mdl.numPoints_user, mdl.constants.bufferSize.CU);
                    [mdl.HXRBR, mdl.SXRBR] = mdl.getCURates;
                    mdl.bufferRatesText = sprintf('HXR Buffer Rate: %d HZ      SXR Buffer Rate: %d HZ', mdl.HXRBR, mdl.SXRBR);
                    mdl.default_plot_vars = mdl.constants.defaultPlotVars.CU;
                    beamLines = {'CUH','CUS'};
                    currentLine = beamLines{(mdl.SXRBR > mdl.HXRBR) + 1};
                    mdl.eDef = [currentLine 'BR'];
                    mdl.destination = ['CU_' currentLine(3) 'XR'];
                    updateRootNames(mdl);
            end
            
            mdl.bpms = [];
            mdl.bpms = bsagui_setupBPMS(mdl);
            generatePlotVars(mdl);
                        
            mdl.eDefStr = mdl.eDef;
            mdl.status = '';
            
            notify(mdl, 'StatusChanged');
            notify(mdl, 'BufferRatesChanged');
            notify(mdl, 'eDefOptionsChanged');
        end
                
        function exportToWorkspace(mdl)
            % Export public model properties to workspace in the struct
            % 'mdl'
            assignin('base','mdl', mdl);
        end
                                                
    end
    
    methods % EDEF
        
        function setupeDef(mdl, HS)
            % Set correct eDef name for a private eDef, update rootname
            % list
            mdl.eDefStr = sprintf('%s%s Private %d', mdl.linac, HS, mdl.eDefNumber);
            mdl.have_eDef = 1;
            updateRootNames(mdl);
            notify(mdl, 'eDefOptionsChanged');
        end
        
        function reserveeDef(mdl, destination, numPoints, num2avg, timeout)
            % reserve a private eDef through the correct timing system
            if mdl.have_eDef
                releaseeDef(mdl);
            end
            uniqueNumberPV = mdl.constants.uniqueNumberPV;
            lcaPutSmart(uniqueNumberPV, 1+lcaGetSmart(uniqueNumberPV));
            uniqueNumber = lcaGetSmart(uniqueNumberPV);
            mdl.timeout = timeout;
            mdl.numPoints_user = numPoints;
            notify(mdl, 'NumPointsChanged');
            
            % eDef reerve nuances for different conditions
            if mdl.facet
                    mdl.beamCode = 10;
                    mdl.eDefNumber = eDefReserve(springtf('BSA_GUI %d', uniqueNumber));
                    eDefParams(mdl.eDefNumber, num2avg, numPoints,[],[],[],[], mdl.beamCode);
                    HS = [];
            elseif mdl.lcls
                switch mdl.linac
                    case 'CU'
                        if startsWith(destination, 'H')
                            HS = 'H';
                            mdl.beamCode = 1;
                            destination = 'CU_HXR';
                        elseif startsWith(destination, 'S')
                            HS = 'S';
                            mdl.beamCode = 2;
                            destination = 'CU_SXR';
                        else
                            HS = [];
                            mdl.beamCode = 0;
                            destination = '';
                        end
                        mdl.eDefNumber = eDefReserve(sprintf('BSA_GUI %d',uniqueNumber));
                        eDefParams(mdl.eDefNumber, num2avg, numPoints,[],[],[],[],mdl.beamCode);
                    case 'SC'
                        mdl.eDefNumber = bsaReserve(sprintf('BSA_GUI %d',uniqueNumber));
                        bsaParams(mdl.eDefNumber, num2avg, numPoints, destination);
                        if strcmp(destination, 'SC_HXR')
                            HS = 'H';
                        elseif strcmp(destination, 'SC_SXR')
                            HS = 'S';
                        else
                            HS = [];
                        end
                        
                end
            end
            mdl.destination = destination;
            mdl.reserving = 1;
            setupeDef(mdl, HS);
        end
        
        function connecteDef(mdl, eDefNumber)
            % ensure that the eDefNumber sent is valid
            if mdl.facet
                if ~any(mdl.constants.valid_eDefs.facet == eDefNumber)
                    warndlg('Invalid eDef for FACET event system');
                    return
                end
            else
                switch mdl.linac
                    case 'CU'
                        if ~any(mdl.constants.valid_eDefs.CU == eDefNumber)
                            warndlg('Invalid eDef for CU event system');
                            return
                        end
                        gettingBeamcode = 1;
                        while gettingBeamcode
                            beamcode = lcaGetSmart(sprintf('EDEF:SYS0:%d:BEAMCODE', eDefNumber));
                            if ~isnan(beamcode)
                                gettingBeamcode = 0;
                            end
                        end
                        if beamcode == 0
                            mdl.destination = [];
                        elseif beamcode == 1
                            mdl.destination = 'CU_HXR';
                        elseif beamcode == 2
                            mdl.destination = 'CU_SXR';
                        end
                    case 'SC'
                        if ~any(mdl.constants.valid_eDefs.SC == eDefNumber)
                            warndlg('Invalid eDef for SC event system');
                            return
                        end
                        gettingDestination = 1;
                        while gettingDestination
                            destination = lcaGetSmart(sprintf('BSA:SYS0:1:%d:INCMS1', eDefNumber));
                            if ~isnan(destination)
                                gettingDestination = 0;
                            end
                        end
                        mdl.destination = destination;
                end
            end
            
            if mdl.have_eDef
                releaseeDef(mdl);
            end
            mdl.eDefNumber = eDefNumber;
            mdl.reserving = 0;
            
            setupeDef(mdl, '');
        end
        
        function releaseeDef(mdl)
            % Release private eDef and reset appropriate model properties
            if mdl.reserving
                eDefRelease(mdl.eDefNumber);
                mdl.reserving = 0;
            end
            mdl.eDefNumber=[];
            mdl.have_eDef=0;
        end
        
        function needseDef = needseDef(mdl)
            % Utility function for determining if an eDef needs to be set
            % up to proceed with another function
            needseDef = contains(mdl.eDef, 'Private') & ~mdl.have_eDef;
        end
        
        function menuitems = geteDefMenu(mdl)
            % Hardcoded default eDefs for CU, SC, and FACET
            if mdl.dev
                menuitems = mdl.constants.menuitems.dev;
                return
            elseif mdl.lcls
                switch mdl.linac
                    case 'CU'
                        menuitems = mdl.constants.menuitems.CU;
                    case 'SC'
                        menuitems = mdl.constants.menuitems.SC;
                end
            elseif mdl.facet
                menuitems = mdl.constants.menuitems.facet;
            end
        end
        
    end
    
    methods % SETTERS
        
        function numPointsUserChanged(mdl, numPoints)
            % Update model with user entered number of points to collect
            mdl.numPoints_user = numPoints;
            if mdl.have_eDef
                if strcmp(mdl.linac, 'CU'), edefPV = 'EDEF:SYS0'; else, edefPV = 'BSA:SYS0:1'; end
                try
                    lcaPutSmart(sprintf('%s:%d:MEASCNT', edefPV, mdl.eDefNumber), numPoints);
                catch ME
                    disp(ME)
                end
            end
        end
        
        function eDefChanged(mdl, eDef, isPrivate)
            % Update model with new eDef information and reset appropriate
            % properties
            if mdl.have_eDef
                releaseeDef(mdl);
            end
            
            mdl.eDef = eDef;
            mdl.eDefStr = eDef;
            mdl.PVA = [];
            mdl.PVB = [];
            mdl.PVC = [];
            mdl.formula = [];
            mdl.formula_string = [];
            mdl.formula_pvs = [];
            generatePlotVars(mdl);
                        
            if ~isPrivate
                try
                    mdl.destination = [mdl.linac '_' mdl.eDef(3), 'XR'];
                catch
                    mdl.destination = [];
                end
                updateRootNames(mdl);
            end
            
            if mdl.facet
                mdl.facetBR = lcaGetSmart('EVNT:SYS1:1:BEAMRATE', 1);
                mdl.bufferRatesText = sprintf('FACET Buffer Rate: %d HZ', mdl.facetBR);
            else
                mdl.bpms = [];
                mdl.bpms = bsagui_setupBPMS(mdl);

                switch mdl.linac
                    case 'CU'
                        [mdl.HXRBR, mdl.SXRBR] = mdl.getCURates;
                        mdl.bufferRatesText = sprintf('HXR Buffer Rate: %d HZ      SXR Buffer Rate: %d HZ', mdl.HXRBR, mdl.SXRBR);
                    case 'SC'
                        mdl.bufferRatesText = mdl.getSCRates;
                end
            end
            
            mdl.dataAcqStatus = '';
            mdl.status = '';
            
            notify(mdl, 'StatusChanged');
            notify(mdl, 'AcqStatusChanged');
            notify(mdl, 'eDefOptionsChanged');
            
        end
        
        function PSDRangeChanged(mdl, val, hilo)
            % Update model with user entered changes to PSD range
            if strcmp(hilo, 'high')
                mdl.PSDend = val;
                mdl.status;
            elseif strcmp(hilo, 'low')
                mdl.PSDstart = val;
                mdl.status;
            else
                mdl.status = 'Error setting PSD range';
            end
            notify(mdl, 'StatusChanged');
        end
        
        function offsetChanged(mdl, offset)
            % Update model with change in plot offset
            mdl.offset = offset;
        end
        
        function multiplotOptionChanged(mdl, button)
            mdl.multiplot_same = contains(button.Tag, 'same'); 
        end
        
        function multiplotChanged(mdl, doMulti)
            mdl.multiplot = doMulti; 
        end
        
        function updateZOptions(mdl, value, field)
            % Read in all z options from z_options app
            mdl.z_options.(field) = value;
            %mdl.new_model = new_model; % this refers to accelerator model calculations
        end
        
        function acquireSCP(mdl, acqSCP)
             % update model with user change to acquire SCP check box
             mdl.acqSCP = acqSCP;
             updateRootNames(mdl);
        end
        
        function setPV(mdl, PV, whichPV)
            % record user selected PV and add to plot variable drop down menus
            if needseDef(mdl)
                return
            else
                PVProp = strcat("PV", whichPV);
                mdl.(PVProp) = PV;
            end
            generatePlotVars(mdl, PV);
        end
        
        function searchPVSet(mdl, searchString, whichPV)
            % update PV list based on search string
            strs = split(searchString, '*');
            if length(strs) > 1
                str1 = strs(1); str2 = strs(2);
            else
                str1 = strs(1); str2 = str1;
            end
            searchIdx = find(contains(mdl.ROOT_NAME, str1) & contains(mdl.ROOT_NAME, str2));
            PVList = mdl.ROOT_NAME(searchIdx);
            mdl.(strcat('PVList', whichPV)) = PVList;
            idxProp = strcat("idx", whichPV);
            mdl.(idxProp) = searchIdx;
            if length(PVList) == 1 % if only 1 options, set that PV
                setPV(mdl, PVList(1), whichPV);
            end
%             if strcmp(whichPV, 'B')
%                 mdl.searchStringB = searchString;
%             end
            notify(mdl, 'PVListChanged');
        end
        
        function enoload(mdl, waitenoload)
            % Update model with user change to enoload check box
            mdl.waitenoload = waitenoload;
        end
        
        
    end
    
    methods % SAVE/LOAD
        
        function saveData(mdl, saveas)
            % Save data to either default or user selected location
            disp('Saving Data...');
            data = getAppData(mdl); % copy app data into data struct
            
            data.fileName = strrep(['BSA-' ['data-' char(strrep(mdl.eDefStr,' ','-'))] '-' datestr(mdl.t_stamp,'yyyy-mm-dd-HHMMSS') '.mat'],':','_');
            
            savetime = datestr(now);
            [fname, pathName]=util_dataSave(data, 'BSA', ['data-' char(strrep(mdl.eDefStr,' ','-'))] , savetime, saveas);
            
            if ~strcmp(fname, data.fileName)
                disp('predicted filename does not match')
            end
            if ~ischar(fname), return, end
            mdl.fileName=fname;
            mdl.process.saved=1;
            
            fprintf('Data saved to %s',fname);
            if saveas
                fullFileName = [ pathName '/' fname ];
                lcaPutSmart(mdl.constants.savePV, double(uint8(fullFileName)));
            end
            
        end
        
        function loaded = loadFields(mdl, data)
            % Used during loading of a file. It checks to see
            % if there are any necessary fields that were not in the file (usually
            % because of an older format for the app properties), and tries to create
            % them based on the data in the file.
            
            if mdl.have_eDef, releaseeDef(mdl); end
            
            loaded = 1; % notify whether load was successful
            
             if isempty(data.ROOT_NAME)
                disp('Error: loaded file must contain a ROOT_NAME field')
                mdl.status = 'Error: loaded file must contain a ROOT_NAME field';
                notify(mdl, 'StatusChanged');
                loaded = 0;
                return
            end
            mdl.status = '';
            notify(mdl, 'StatusChanged');
            
            dataFields = fieldnames(data);
            
            % create a clean slate to load in new data
            resetFields(mdl);
            % don't overwrite these fields
            protectedFields = {'app', 'bufferRatesText', 'default_plot_vars', 'env', 'host', 'multiplot'};
            for ii = 1:length(dataFields)
                field = dataFields{ii};
                if any(contains(protectedFields, field)), continue; end
                try
                        mdl.(field) = data.(field);
                catch
                    fprintf('Field %s not recognized. Adding to app.other_fields \n', dataFields{ii})
                    mdl.other_fields.(field) = data.(field);
                end
            end
            
            % Ensure constants are loaded
            if ~isfield(dataFields, 'constants')
                mdl.constants = bsagui_constants();
            end
            
            % Ensure an appropriate filename is saved
            if ~strcmp(mdl.fileName, mdl.app.fileName)
                mdl.fileName = mdl.app.fileName;
            end
            
            data = struct();
            if ~mdl.facet
                % identify if SXR or HXR or dual energy
                [hxr_id, sxr_id, ~] = splitNames(mdl);

                file_isSxr = contains(mdl.fileName, 'CUS');
                file_isHxr = contains(mdl.fileName, 'CUH');


                if file_isSxr
                    data.isSxr = 1;
                    data.isHxr = 0;
                    data.isBR = 0;
                elseif file_isHxr
                    data.isHxr = 1;
                    data.isSxr = 0;
                    data.isBR = 0;
                elseif isempty(hxr_id) && isempty(sxr_id)
                    disp('No valid root names'); 
                    mdl.status = 'Error: No valid ROOT NAMES';
                    notify(mdl, 'StatusChanged');
                    loaded = 0;
                    return;
                else
                    data.isBR= 1;
                    data.isSxr = 0;
                    data.isHxr = 0;
                end
            end
            mdl.status = '';
            notify(mdl, 'StatusChanged');
            
            if mdl.facet
                patt = contains(mdl.ROOT_NAME,'PATT:SYS1:1:PULSEID');
            else
                patt = contains(mdl.ROOT_NAME,'PATT:SYS0:1:PULSEID');
            end
            tpg = contains(mdl.ROOT_NAME,'TPG:SYS0:1');
            
            if isempty(mdl.the_matrix)
                mdl.status = 'Data matrix empty';
                notify(mdl, 'StatusChanged');
                
                beamrate = 0;
            else
                if any(patt)
                    pid_idx = patt;
                    % calculate approximate beamrate
                    pid = mdl.the_matrix(pid_idx,:);
                    [~, ~, pid] = unrollpid(pid);
                    seconds = pid / 360;
                    dt = diff(seconds);
                    [beamrate_vector] = 1./dt;
                    beamrate_vector(isinf(beamrate_vector))=NaN;
                    beamrate = max(beamrate_vector);
                    if mdl.lcls
                        mdl.linac = 'CU';
                        [hxr_idx, sxr_idx] = splitPulses(mdl);
                        % identify SXR/HXR beam rates
                        if ~isempty(hxr_idx)
                            data.HXRBR = round(120 * (sum(hxr_idx) / length(hxr_idx)));
                        else
                            data.HXRBR = 0;
                        end

                        if ~isempty(sxr_idx)
                            data.SXRBR = round(120 * (sum(sxr_idx) / length(sxr_idx)));
                        else
                            data.SXRBR = 0;
                        end
                    else
                        data.facetBR = beamrate;
                    end
                elseif any(tpg)
                    mdl.linac = 'SC';
                    upper_pididx = contains(mdl.ROOT_NAME, 'TPG:SYS0:1:PIDU');
                    lower_pididx = contains(mdl.ROOT_NAME, 'TPG:SYS0:1:PIDL');
                    if ~(any(upper_pididx) && any(lower_pididx))
                       mdl.status = 'Invalid pulse ID information in file';
                       notify(mdl, 'StatusChanged');
                    end
                    pid = bitshift(mdl.the_matrix(upper_pididx,:), 32) + mdl.the_matrix(lower_pididx,:);
                    seconds = pid / 910000;
                    dt = diff(seconds);
                    [beamrate_vector] = 1./dt;
                    beamrate_vector(isinf(beamrate_vector))=NaN;
                    beamrate = max(beamrate_vector);
                end
            end
            
            switch round(beamrate)
                case 1, suffix = '1H';
                case 10, suffix = 'TH';
                otherwise
                    if strcmp(mdl.linac, 'SC') && round(beamrate) == 100
                        suffix = 'HH';
                    else
                        suffix = 'BR';
                    end
            end
            
            % create eDef name
            if mdl.facet
                data.eDef = suffix;
            else
                if data.isBR
                    data.eDef = suffix;
                elseif data.isHxr
                    data.eDef = [mdl.linac 'H' suffix];
                elseif data.isSxr
                    data.eDef = [mdl.linac 'S' suffix];
                end
            end
            
            if mdl.lcls
                % get z positions
                [prim,micro,unit] = model_nameSplit(mdl.ROOT_NAME);
                n = strcat(prim,':', micro, ':', unit);
                zh = model_rMatGet(n,[],{'TYPE=DESIGN',['BEAMPATH=' mdl.linac '_HXRI']},'Z');
                zs = model_rMatGet(n,[],{'TYPE=DESIGN',['BEAMPATH=' mdl.linac '_SXRI']},'Z');
                z=zeros(length(n),1);
                % combine zh and zs without adding together
                z(find(zh)) = zh(find(zh));
                z(~zh) = zs(~zh);
                [z, I] = sort(z);
                mdl.ROOT_NAME = mdl.ROOT_NAME(I);
                if ~isempty(mdl.the_matrix)
                    mdl.the_matrix = mdl.the_matrix(I,:);
                end
                mdl.z_positions = z;
            end
            
            % if the loaded file did not load in the necessary data fields,
            % plug them in based on the above calculations
            dataFields = fieldnames(data);
            for f = 1:length(dataFields)
                field = dataFields{f};
                if isempty(mdl.(field))
                    mdl.(field) = data.(field);
                end
            end
            
            mdl.have_eDef = 0;
            mdl.reserving = 0; 
            mdl.eDefNumber = [];
            mdl.dev = startsWith(getenv('MATLABDATAFILES'),'/nfs');
            
            mdl.numPoints_acq = size(mdl.the_matrix,2);
            notify(mdl, 'DataAcquired');
            
%             if mdl.lcls
%             % Initialize BPMs if needed
%             %if isempty(mdl.bpms)
%                 
%             end

            mdl.bpms = bsagui_setupBPMS(mdl);
            mdl.PVListA = mdl.ROOT_NAME;
            mdl.PVListB = mdl.ROOT_NAME;
            if mdl.facet
                currentBR = mdl.getFacetRate;
                mdl.bufferRatesText = sprintf('FACET Buffer Rate: %d HZ', currentBR);
                mdl.default_plot_vars = mdl.constants.defaultPlotVars.facet;
            else
                switch mdl.linac
                    case 'CU'
                        [HXRnow, SXRnow] = mdl.getCURates;
                        mdl.bufferRatesText = sprintf('HXR Buffer Rate: %d HZ      SXR Buffer Rate: %d HZ', HXRnow, SXRnow);
                        switch mdl.dev
                            case 0
                                mdl.default_plot_vars = mdl.constants.defaultPlotVars.CU;
                            case 1
                                mdl.default_plot_vars = mdl.constants.defaultPlotVars.dev;
                        end
                    case 'SC'
                        mdl.bufferRatesText = mdl.getSCRates;
                        mdl.default_plot_vars = mdl.constants.defaultPlotVars.SC;
                end
            end
            notify(mdl, 'eDefOptionsChanged');
            generatePlotVars(mdl);
            
        end
        
        function resetFields(mdl)
            % Designate which properties are important to keep when loading
            % a new file, clear out the properties that will be changed
            fields = fieldnames(mdl);
            
            for f = 1:length(fields)
                field = fields{f};
                
                if ~contains(mdl.constants.protected_fields, field)
                    mdl.(field) = [];
                end
            end
        end
        
        function data = getAppData(mdl)
            %Assigns properties of 'app' to struct 'data' for save to
            %output file
            appfields = properties(mdl);
            for ii = 1:length(appfields)
                field = appfields{ii};
                if strcmp(field, 'app')
                    continue
                end
                data.(field) = mdl.(field);
            end
        end
    end
    
    methods(Static)
        
        function rates = getSCRates
            % Returns a formatted text box of the current beam rates for the 4
            % primary SC destinations: BSY, DIAG0, HXR, SXR
            
            destinations = {'SC_BSYD', 'SC_DIAG0', 'SC_HXR', 'SC_SXR'};
            rates = [];
            breakstr = {[], '    ', [newline newline], '    '}; % used for formatting
            for d = 1:4
                dest = destinations{d};
                rate = getSCTimingActualRate(dest);
                if isnan(rate), rate = 0; end
                ratestr = sprintf('%s Buffer Rate: %dHZ ', dest, rate);
                rates = [rates breakstr{d} ratestr];
            end
            
        end
        
        function [rateHXR, rateSXR] = getCURates
            % Utility function returning current CU_HXR and CU_SXR BSA buffer rates
            
            rateSXR = lcaGetSmart('PATT:SYS0:12:CUSXR:ACTRATE',1);
            rateHXR = lcaGetSmart('PATT:SYS0:11:CUHXR:ACTRATE',1);
            
        end
        
        function rate = getFacetRate
            rate = lcaGetSmart('EVNT:SYS1:1:BEAMRATE', 1);
        end
    end
    
end



