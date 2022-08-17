classdef BSA_GUI_model < handle
    %BSA_GUI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        app % instance of the GUI object
        acqSCP = 0 % flag indicating whether or not to acquire data from SCP for FACET data acq
        beamCode % beam code for eDef setup
        bpms % data struct on beam position monitors
        BSD_inputs % previous field values for BSD_window
        BSD_ROOT_NAME % root names returned from BSA datastore
        bufferRatesText % string to display buffer rates of current machine
        currentVar % variable currently selected in drop down menu
        createVarApp % create variable mlapp object
        createVar_fields % saved fields for restoring last entered createVarApp settings
        current_plot_vars = {} % plot variables added by user (PVA, PVB, etc.)
        dataAcqStatus % status specifically as it relates to data acquisition
        default_plot_vars  = {'Time', 'Index', 'PSD', 'Histogram'}%, 'All Z', 'Z PSD'}%, 'Jitter Pie'} % default list for plot variable drop down
        destination % used to infer beampath
        dev = 0% 1 if on development network, 0 if on production
        eDef % eDef selected in eDef menu
        eDefStr % unchanged eDef value, used to restore private eDef names after use
        eDefs = {'Private', 'CUS1H','CUSTH','CUSBR','CUH1H','1H','TH','BR','CUHTH','CUHBR'} % list of available eDefs
        eDefNumber % eDef number for private eDef
        facet = 1% 1 if running on FACET, 0 otherwise
        facetBPMS % struct containing information about BPMS when in FACET mode (names, z pos, scp_idx)
        facetBR % current beamrate for FACET
        fileName % name of file to save to
        formula % formula used to create new variable
        formula_string % string of formula for new variable
        formula_pvs % pvs used to create new variable
        hasSCP % logical array indicating which pulses have data from SCP
        have_eDef = 0 % default 0, 1 if private eDef setup has been executed
        host % server hostname
        HXR % struct on HXR bpms for dual energy calculations
        HXRBR % HXR beam rate
        idxA % indices of ROOT_NAME  subsetted by search A
        idxB % indices of ROOT_NAME  subsetted by search B
        isBR % 1 if eDef is BR
        isHxr % 1 if eDef is for HXR
        isPV % logical array whether requested PVs are valid or not
        isSCP % logical array representing which PVs in ROOT_NAME are from SCP
        isSxr % 1 if eDef is for SXR
        lcls = 0% 1 if on lcls machine, 0 otherwise
        linac = 'CU' % CU or SC
        multiplot = 0 % reflects multiplot check box
        multiplot_same = 0 % change to 1 to plot traces on the same figure
        new_model = 1 % pushbutton value for initiating a new accelerator model
        numPoints_user = 2800
        numPoints_acq % number of points actually acquired
        offset % user entered offset value
        optx % options for X drop down menu
        opty % options for Y drop down menu
        other_fields % catch field if uploaded data is
        process % holder for whether data saved properly
        PSDstart = 58 % low end of PSD range for Z PSD analysis
        PSDend = 60 % high end of PSD range for Z PSD analysis
        PVA % PV selected in list A
        PVB % PV selected in list B
        PVC % value of created variable
        PVListA % list of PVs subset by search string A
        PVListB % list of PVs subset by search string A
        reserving = 0 % flag for eDef actually reserved
        ROOT_NAME % list of PV names
        searchStringB % hold this for ALL Z plot label
        status % generally informing of an error, communicate to view
        SXR % struct on HXR bpms for dual energy calculations
        SXRBR % SXR beam rate
        sys % SYS0 (lcls) or SYS1 (facet)
        t_stamp % time of last point in data
        the_matrix % number of PVs x numPoints_acq matrix containing data returned by lcaGet
        time_stamps % for private eDefs, time matrix for all points
        timeout % time willing to wait to acquire data
        waitenoload = 0 % 0 or 1 for enoload checkbox status
        z_options = struct('AllBSA', 1, 'HorzNoDispersion', 1, 'ModelBeamEnergy', 1, 'ModelBeamSigma', 1,...
            'Dispersion', 1, 'XYFactor', 1, 'VertRMS', 1, 'HorzRMS', 1, 'YBPMCorr', 1, 'XBPMCorr', 1,...
            'VertNormRMS', 1, 'HorzNormRMS', 1, 'NewModel', 0) % return value of z_options
        z_positions % Z location of selected devices
        zLCLS = 2014.7019 % z offset of LCLS injector
        zOptApp % z options mlapp object
    end
    
    events(NotifyAccess = private)
        AcqSCPChanged % change in acquire SCP flag
        AcqStatusChanged % change the data acquisition status message
        BufferRatesChanged % update the BSA buffer rate text
        DataAcquired % update the actual number of points label
        eDefOptionsChanged % update the eDef menu
        NumPointsChanged % update the num points edit field
        PlotOptionsChanged % update plot variable menus
        PVChanged % update selected PVs
        PVListChanged % update PV lists
    end
    
    events(NotifyAccess = public)
        StatusChanged  % update status message box
    end
    
    
    methods
        
        function mdl = BSA_GUI_model(app)
            % Construct a BSA_GUI_model instance for holding data and state
            % of BSA GUI. 
            
            mdl.app = app; 
        end
        
        function mdlInit(mdl)
            % Populate model with initial server and accelerator conditions
            mdl.host = strsplit(getenv('HOSTNAME'), '-');
            mdl.sys = getSystem();
            mdl.dev = startsWith(getenv('MATLABDATAFILES'),'/nfs');
            mdl.facet = strcmp(mdl.sys, 'SYS1');
            mdl.lcls = strcmp(mdl.sys, 'SYS0');
            
            
            if mdl.facet
                mdl.facetBR = lcaGetSmart('EVNT:SYS1:1:BEAMRATE', 1);
                mdl.bufferRatesText = sprintf('FACET Buffer Rate: %d HZ', mdl.facetBR);
                facetInit(mdl.app);
                mdl.eDefs = geteDefMenu(mdl);
                mdl.eDef = 'BR';
                mdl.eDefStr = mdl.eDef;
                updateRootNames(mdl);
            else
                % Default to CU if run on lcls server, dev or prod
                [mdl.HXRBR, mdl.SXRBR] = getCURates;
                mdl.bufferRatesText = sprintf('HXR Buffer Rate: %d HZ      SXR Buffer Rate: %d HZ', mdl.HXRBR, mdl.SXRBR);
                
                if mdl.dev
                    mdl.eDefs = [{'CUH'}, {'CUS'}, {'SCH'}, {'SCS'}];
                    mdl.eDef = 'CUH';
                    devInit(mdl.app);
                else
                    % Default to CUXBR for X beamline with higher beamrate
                    beamLines = {'CUH','CUS'};
                    currentLine = beamLines{(mdl.SXRBR > mdl.HXRBR) + 1};
                    mdl.eDef = [currentLine 'BR'];
                end
                mdl.eDefStr = mdl.eDef;
                updateRootNames(mdl);
                mdl.bpms = setupBPMS(mdl);
            end
            notify(mdl, 'eDefOptionsChanged');
            
        end
        
        function updateRootNames(mdl, varargin)
            %Called on initialization and change in eDef. Changes the list
            %of PVs, calls BPMS setup function, and sets device z_positions
            checkeDef = strsplit(mdl.eDefStr); checkeDef = checkeDef{1};   
            if length(checkeDef) < 3
                mdl.isBR = true;
                mdl.isSxr = false;
                mdl.isHxr = false;
            else
                mdl.isSxr = strcmp(checkeDef(3),'S');
                mdl.isHxr = strcmp(checkeDef(3),'H');
                mdl.isBR = false;
            end
            
            if mdl.isSxr
                HS = [mdl.linac 'S.'];
            elseif mdl.isHxr
                HS = [mdl.linac 'H.'];
            elseif strcmp(mdl.linac, 'SC')
                HS = 'SC.';
            else
                HS = [];
            end
            
            [mdl.ROOT_NAME, mdl.z_positions] = getRootNames(mdl, HS);
            
            mdl.idxA = 1:1:length(mdl.ROOT_NAME);
            mdl.idxB = 1:1:length(mdl.ROOT_NAME);
            
            mdl.PVListA = mdl.ROOT_NAME;
            mdl.PVListB = mdl.ROOT_NAME;
            
            notify(mdl, 'PVListChanged');
            
        end
        
        function [root_name, z] = getRootNames(mdl, HS)
            % returns PV names and z locations for current operational mode.
            
            if mdl.dev
                root_name = devNames(mdl);
                % Bring returned names into correct format
                for i = 1:length(root_name)
                    name = root_name{i};
                    rep = strfind(name,'_');
                    try name(rep(1:3)) = ':'; catch end
                    root_name{i} = name;
                end
                beamPath = ['CU_' HS(3) 'XRI'];
            elseif mdl.facet
                % get directory service names, and format correctly
                [~, root_name] = system('eget -ts ds -a tag=FACET.BSA.rootnames -w 20');
                root_name = splitlines(root_name);
                root_name = root_name(~cellfun(@isempty, root_name));
                root_name(contains(root_name, 'BPMS')) = [];
                if isempty(mdl.facetBPMS)
                    % get SCP BPM names, if not already done
                    initSCPNames(mdl);
                end
                if mdl.acqSCP
                    % interleave EPICS names and SCP names by Z
                    numEPICS = length(root_name);
                    z = zeros(numEPICS, 1);
                    mdl.isSCP = false(numEPICS, 1);
                    root_name = [root_name; mdl.facetBPMS.names];
                    z(numEPICS + 1 : length(root_name)) = mdl.facetBPMS.z;
                    mdl.isSCP(numEPICS + 1 : length(root_name)) = mdl.facetBPMS.scp_idx;
                else
                    numEPICS = length(root_name);
                    z = zeros(numEPICS, 1);
                    root_name = [root_name; mdl.facetBPMS.names(~mdl.facetBPMS.scp_idx)];
                    z(numEPICS+1:length(root_name)) = mdl.facetBPMS.z(~mdl.facetBPMS.scp_idx);
                    mdl.isSCP = false(length(root_name), 1);
                end
                beamPath = 'F2_ELEC';
            else  % prod, on an lcls server
                root_name = meme_names('tag',['LCLS.' HS 'BSA.rootnames'], 'sort','z');
                if strcmp(mdl.linac, 'SC')
                    beamPath = ['SC_' HS(3) 'XRI'];
                else
                    try
                        beamPath = ['CU_' HS(3) 'XRI'];
                    catch
                    end
                end
                if ~ismember('GDET:FEE1:241:ENRC',root_name)
                    root_name = [root_name ;{'GDET:FEE1:241:ENRC'; 'GDET:FEE1:242:ENRC'; 'GDET:FEE1:361:ENRC'; 'GDET:FEE1:362:ENRC'}];
                end
            end
            
            % Get z positions,
            [prim,micro,unit] = model_nameSplit(root_name);
            n = strcat(prim,':', micro, ':', unit);
            if strcmp(mdl.sys, 'SYS0') && ~mdl.isSxr && ~mdl.isHxr % if dual energy, need to cross reference HXR and SXR models
                zh = model_rMatGet(n,[],{'TYPE=DESIGN','BEAMPATH=CU_HXRI'},'Z');
                zs = model_rMatGet(n,[],{'TYPE=DESIGN','BEAMPATH=CU_SXRI'},'Z');
                z=zeros(length(n),1);
                % combine zh and zs without adding together
                z(find(zh)) = zh(find(zh));
                z(~zh) = zs(~zh);
            elseif mdl.facet
                nonBPMS = ~contains(root_name, 'BPMS');
                z(nonBPMS) = model_rMatGet(n(nonBPMS),[],{'TYPE=DESIGN',['BEAMPATH=' beamPath]},'Z');
            else
                z = model_rMatGet(n,[],{'TYPE=DESIGN',['BEAMPATH=' beamPath]},'Z');
            end
            [z, I] = sort(z);
            if mdl.acqSCP, mdl.isSCP = mdl.isSCP(I); end
            root_name = root_name(I);
            
        end
        
        function initSCPNames(mdl)
            % read in SCP names from the Lucretia model
            
            LM = LucretiaModel(F2_common.LucretiaLattice);
            names = LM.ControlNames;
            z = LM.ModelZ;
            bpm_loc = contains(names, 'BPMS');
            bpmnames = names(bpm_loc); z_bpms = z(bpm_loc);
            scp_loc = startsWith(bpmnames, 'LI');
            scpNames = bpmnames(scp_loc); z_scp = z_bpms(scp_loc);
            epicsNames = bpmnames(~scp_loc); z_epics = z_bpms(~scp_loc);
            [sec, prim, unit] = model_nameSplit(scpNames);
            scpNames = strcat(prim, ':', sec, ':', unit);
           
            % append attributes
            X_scp = strcat(scpNames, ':X'); 
            Y_scp = strcat(scpNames, ':Y');
            TMIT_scp = strcat(scpNames, ':TMIT');
            scpNames = [X_scp; Y_scp; TMIT_scp]; z_scp = [z_scp; z_scp; z_scp];
            X_epics = strcat(epicsNames, ':X'); 
            Y_epics = strcat(epicsNames, ':Y');
            TMIT_epics = strcat(epicsNames, ':TMIT');
            epicsNames = [X_epics; Y_epics; TMIT_epics]; z_epics = [z_epics; z_epics; z_epics];
            % interleave EPICS and SCP BPMS
            names = [scpNames; epicsNames];
            scp_idx = contains(names, scpNames);
            facet_offset = 1002.1;
            z = [z_scp; z_epics]; z = z - facet_offset;
            [z, I] = sort(z);
            names = names(I);
            scp_idx = scp_idx(I);
            mdl.facetBPMS.names = names;
            mdl.facetBPMS.z = z;
            mdl.facetBPMS.scp_idx = scp_idx;
        end
        
        function root_name = devNames(mdl)
            % Generate list of root_names on dev server by looking at most recent BSA
            % datastore file
            
            mdl.linac = mdl.eDef(1:2);
            if mdl.isSxr
                bl = [mdl.linac '_SXR'];
            elseif mdl.isHxr
                bl=[mdl.linac '_HXR'];
            else
                mdl.status = 'Error getting names';
                notify(mdl, 'StatusChanged');
                return
            end
            tRef = datetime('now','TimeZone','Z');
            found = 0;
            % Look for the most recent BSA file
            while ~found
                y = year(tRef); m = month(tRef); d = day(tRef);
                last_dir = sprintf('/nfs/slac/g/bsd/BSAService/data/%d/%02d/%02d/',y,m,d);
                files = extractfield(dir(last_dir),'name');
                files = files(contains(files,bl));
                if isempty(files)
                    tRef = tRef - 1;
                else
                    ref_file = files{length(files)};
                    found = 1;
                end
            end
            % Set root_names to the list of names in this file
            ref_file = fullfile(last_dir,ref_file);
            info = h5info(ref_file);
            root_name = {info.Datasets.Name}';
            suffix = strcat(mdl.eDef(1:3), root_name{1}(end-1:end));
            time_pvs = contains(root_name, {'nanoseconds', 'secondsPastEpoch'});
            root_name(~time_pvs) = strrep(root_name(~time_pvs), suffix, '');
            
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
       
        
        function setupeDef(mdl, HS)
            % Make sure eDef names reset correctly. This is probably not
            % the cleanest way to do this but it works...
            if mdl.facet
                mdl.eDefStr = sprintf('Private %d', mdl.eDefNumber);
            else
                mdl.eDefStr = sprintf('%s%s Private %d', mdl.linac, HS, mdl.eDefNumber);
            end
            mdl.have_eDef = 1;
            updateRootNames(mdl);
            
            % mdl.bpms = []
            % mdl.bpms = setupBPMS(mdl);
            
            notify(mdl, 'eDefOptionsChanged');
        end
        
        function reserveeDef(mdl, destination, numPoints, num2avg, timeout)
            % reserve a private eDef through the correct timing system
            if mdl.have_eDef
                releaseeDef(mdl);
            end
            uniqueNumberPV = 'SIOC:SYS0:ML00:AO900';
            lcaPutSmart(uniqueNumberPV, 1+lcaGetSmart(uniqueNumberPV));
            uniqueNumber = lcaGetSmart(uniqueNumberPV);
            mdl.timeout = timeout;
            mdl.numPoints_user = numPoints;
            notify(mdl, 'NumPointsChanged');
            switch mdl.sys
                case 'SYS1'
                    mdl.beamCode = 10;
                    mdl.eDefNumber = eDefReserve(sprintf('BSA_GUI %d', uniqueNumber));
                    eDefParams(mdl.eDefNumber, num2avg, numPoints,[],[],[],[], mdl.beamCode);
                    HS = [];
                case 'SYS0'
                    switch mdl.linac
                        case 'CU'
                            if startsWith(destination, 'H')
                                HS = 'H';
                                mdl.beamCode = 1;
                            elseif startsWith(destination, 'S')
                                HS = 'S';
                                mdl.beamCode = 2;
                            else
                                HS = [];
                                mdl.beamCode = 0;
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
                            mdl.destination = destination;
                    end
            end
            mdl.reserving = 1;
            setupeDef(mdl, HS);
        end
        
        function connecteDef(mdl, eDefNumber)
            switch mdl.linac
                case 'CU'
                    valid_eDefs = 1:11;
                    if ~any(valid_eDefs == eDefNumber)
                        warndlg('Invalid eDef for CU event system');
                        return
                    end
                case 'SC'
                    valid_eDefs = 21:64;
                    if ~any(valid_eDefs == eDefNumber)
                        warndlg('Invalid eDef for SC event system');
                        return
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
        
        function numPointsUserChanged(mdl, numPoints)
            % Update model with user entered number of points to collect
            mdl.numPoints_user = numPoints;
            if mdl.have_eDef
                if mdl.facet
                    edefPV = 'EDEF:SYS1';
                else
                    if strcmp(mdl.linac, 'CU')
                        edefPV = 'EDEF:SYS0'; 
                    else
                        edefPV = 'BSA:SYS0:1'; 
                    end
                end
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
                updateRootNames(mdl);
            end
            
            if mdl.facet
                mdl.facetBR = lcaGetSmart('EVNT:SYS1:1:BEAMRATE', 1);
                mdl.bufferRatesText = sprintf('FACET Buffer Rate: %d HZ', mdl.facetBR);
            else
                mdl.bpms = [];
                mdl.bpms = setupBPMS(mdl);

                switch mdl.linac
                    case 'CU'
                        [mdl.HXRBR, mdl.SXRBR] = getCURates;
                        mdl.bufferRatesText = sprintf('HXR Buffer Rate: %d HZ      SXR Buffer Rate: %d HZ', mdl.HXRBR, mdl.SXRBR);
                    case 'SC'
                        mdl.bufferRatesText = getSCRates;
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
                    mdl.numPoints_user = 20000;
                    mdl.bufferRatesText = getSCRates;
                    mdl.default_plot_vars = {'Time', 'Index', 'PSD', 'Histogram'};
                    mdl.eDef = 'Private';
                    updateRootNames(mdl);
                case 'CU'
                    [mdl.HXRBR, mdl.SXRBR] = getCURates;
                    mdl.bufferRatesText = sprintf('HXR Buffer Rate: %d HZ      SXR Buffer Rate: %d HZ', mdl.HXRBR, mdl.SXRBR);
                    
                    beamLines = {'CUH','CUS'};
                    currentLine = beamLines{(mdl.SXRBR > mdl.HXRBR) + 1};
                    mdl.eDef = [currentLine 'BR'];
                    mdl.numPoints_user = min(mdl.numPoints_user, 2800);
                    mdl.default_plot_vars = {'Time', 'Index', 'PSD', 'Histogram', 'All Z', 'Z PSD'}%, 'Jitter Pie'};
                    updateRootNames(mdl);
            end
            
            mdl.bpms = [];
            mdl.bpms = setupBPMS(mdl);
            generatePlotVars(mdl);
                        
            mdl.eDefStr = mdl.eDef;
            mdl.status = '';
            
            notify(mdl, 'StatusChanged');
            notify(mdl, 'BufferRatesChanged');
            notify(mdl, 'eDefOptionsChanged');
        end
        
        function menuitems = geteDefMenu(mdl)
            % Hardcoded default eDefs for CU, SC, and FACET
            if mdl.dev
                menuitems = {'CUH', 'CUS', 'SCH', 'SCS'};
                return
            end
            switch mdl.sys
                case 'SYS0'
                    switch mdl.linac
                        case 'CU'
                            menuitems = {'Private', 'CUS1H', 'CUSTH', 'CUSBR', 'CUH1H',...
                                '1H', 'TH', 'BR', 'CUHTH', 'CUHBR'};
                        case 'SC'
                            menuitems = {'Private', 'SCH1H', 'SCHTH', 'SCHHH',...
                                'SCS1H', 'SCSTH', 'SCSHH'};
                    end
                case 'SYS1'
                    menuitems = {'Private', '1H', 'TH', 'BR'};
            end
        end
        
        function resetFields(mdl)
            % Designate which properties are important to keep when loading
            % a new file, clear out the properties that will be changed
            fields = fieldnames(mdl);
            protected_fields = {'app', 'BSD_inputs', 'BSD_ROOT_NAME', 'BSD_window', 'bufferRatesText',...
                'createVarApp', 'createVar_fields', 'default_plot_vars', 'dev', 'eDefs', 'env', 'facet'...
                'have_eDef', 'host', 'linac', 'multiplot', 'multiplot_same', 'new_model', 'offset',...
                'sys', 'waitenoload', 'z_options', 'zLCLS', 'zOptApp'};
            for f = 1:length(fields)
                field = fields{f};
                
                if ~contains(protected_fields, field)
                    mdl.(field) = [];
                end
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
            protectedFields = {'app', 'bufferRatesText', 'default_plot_vars', 'env', 'host'};
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
            
            if ~mdl.facet
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
            
            if ~mdl.facet
                % Initialize BPMs if needed
                if isempty(mdl.bpms)
                    mdl.bpms = setupBPMS(mdl);
                end
            end
            
            mdl.PVListA = mdl.ROOT_NAME;
            mdl.PVListB = mdl.ROOT_NAME;
            
            if ~mdl.facet
                switch mdl.linac
                    case 'CU'
                        [HXRnow, SXRnow] = getCURates;
                        mdl.bufferRatesText = sprintf('HXR Buffer Rate: %d HZ      SXR Buffer Rate: %d HZ', HXRnow, SXRnow);
                        mdl.default_plot_vars = {'Time', 'Index', 'PSD', 'Histogram', 'All Z', 'Z PSD'};%, 'Jitter Pie'};
                    case 'SC'
                        mdl.bufferRatesText = getSCRates;
                        mdl.default_plot_vars = {'Time', 'Index', 'PSD', 'Histogram'};
                end
            else
                currentBR = lcaGetSmart('EVNT:SYS1:1:BEAMRATE', 1);
                mdl.bufferRatesText = sprintf('FACET Buffer Rate: %d HZ', currentBR);
                mdl.default_plot_vars = {'Time', 'Index', 'PSD', 'Histogram'};
            end
            notify(mdl, 'eDefOptionsChanged');
            generatePlotVars(mdl);
            
        end
        
        function exportToWorkspace(mdl)
            % Export public model properties to workspace in the struct
            % 'mdl'
            assignin('base','mdl', mdl);
        end
        
        function enoload(mdl, waitenoload)
            % Update model with user change to enoload check box
            mdl.waitenoload = waitenoload;
        end
        
        function acquireSCP(mdl, acqSCP)
            % update model with user change to acquire SCP check box
            mdl.acqSCP = acqSCP;
            updateRootNames(mdl);
        end
        
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
                lcaPutSmart('SIOC:SYS0:ML00:CA700', double(uint8(fullFileName)));
            end
            
        end
        

%         
%         function getData(mdl)
%             % BSAGUI utility function for retrieving BSA data. Identifies which 'get'
%             % mode the GUI is in, and utilizes the appropriate function
%             %
%             % INPUTS
%             %   app: BSA GUI app object
%             %
%             % OUTPUTS
%             %   the_matrix: num_devices X num_points matrix containing retrieved data
%             %   t_stamp: time label for each pulse in posixtime
%             %   isPV: num_devices X 1 logical array expressing which PVs did not return
%             %         valid data
%             
%             % Author: Jake Rudolph, SLAC 5/2/22
%             % Largely based on code written by Jim Turner and others for the original
%             % BSA_GUI
%             
%             isDatastore = mdl.dev;
%             % If on dev, call datastore function
%             if ~isDatastore
%                 get_data(mdl);
%             else
%                 get_from_datastore(mdl);
%             end
%             
%        end
        
        function data = aidaGet(mdl, aidanames, nPoints)
            mdl.dataAcqStatus = 'AIDA buffered acquisition in progress';
            notify(mdl, 'AcqStatusChanged');
            try
                dgrp = 'FACET-II';
                bpmd = 57;
                aidapva;
                builder = pvaRequest([dgrp ':BUFFACQ']);
                builder.with('BPMD', bpmd);
                builder.with('NRPOS', nPoints);
                builder.with('BPMS', aidanames);
                builder.timeout(20)
                data = ML(builder.get());
                mdl.dataAcqStatus = 'Finished AIDA buffered acquisition';
                notify(mdl, 'AcqStatusChanged');
            catch
                data = [];
                mdl.status = 'FAILED: AIDA buffered acquisition';
                notify(mdl, 'StatusChanged');
            end
        end
        
        function getDataFacet(mdl)
            mdl.dataAcqStatus = '';
            notify(mdl, 'AcqStatusChanged');
            isPrivate = mdl.have_eDef;
            if isPrivate
                new_name = strcat(mdl.ROOT_NAME(~mdl.isSCP), {'HST'}, {num2str(mdl.eDefNumber)});
                mdl.eDef = ['HST' num2str(mdl.eDefNumber)];
            end
            
            if mdl.acqSCP
                % number of points receivable from SCP less than EPICS
                switch mdl.facetBR
                    case 1
                        nPoints = 10;
                    case 10
                        nPoints = 40;
                    case 30
                        nPoints = 80;
                    otherwise
                        nPoints = mdl.facetBR * 5; % A rough guesstimate of appropriate amounts. 5 seconds of data
                end
                % Double check with user before acquiring SCP data, as it
                % will steal rate
                answer = questdlg(sprintf('Acquiring SCP data will steal rate from other applications. %c%c Acquire %d points from SCP?',...
                    newline, newline, nPoints), 'Acquire SCP', 'Yes', 'No', 'Change Points', 'No');
                switch answer
                    case 'Yes'
                        % continue as normal
                    case 'Change Points'
                        nPoints = inputdlg('Number of points', 'SCP Points');
                    case 'No'
                        mdl.acqSCP = false;
                        notify(mdl, 'AcqSCPChanged');
                end
            end
            if mdl.acqSCP
                
                aidanames = mdl.ROOT_NAME(mdl.isSCP);
                [prim, sec, loc] = model_nameSplit(aidanames);
                aidanames = unique(strcat(prim, ':', sec, ':', loc), 'stable');
                
                if isPrivate
                     % Acquire BSA data
                    mdl.dataAcqStatus = sprintf('Acquiring EPICS data in buffer %d', mdl.eDefNumber);
                    notify(mdl, 'AcqStatusChanged');
                    eDefAcq(mdl.eDefNumber, mdl.timeout);
                    mdl.dataAcqStatus = ['New Data: HST' num2str(mdl.eDefNumber)];
                    notify(mdl, 'AcqStatusChanged');
                    % Acquire SCP data while EPICS eDef is buffering
                    bpm_struct = aidaGet(mdl, aidanames, nPoints);
                    done = false;
                    while ~done
                        done = eDefDone(mdl.eDefNumber);
                        pause(0.1)
                    end
                    [epics_matrix, mdl.t_stamp, epics_isPV] = lcaGetSmart(new_name, mdl.numPoints_user);
                    time = epics_matrix(contains(new_name, {'PATT:SYS1:1:NSEC', 'PATT:SYS1:1:SEC'}),:);
                    nsecs = time(1,:); secs = time(2,:);
                    mdl.time_stamps = secs + nsecs*1e-9 + 631152000;
                else
                    new_name = mdl.ROOT_NAME(~mdl.isSCP);                    
                    bpm_struct = aidaGet(mdl, aidanames, nPoints);
                    mdl.dataAcqStatus = sprintf('Retrieving %s data', mdl.eDef);
                    notify(mdl, 'AcqStatusChanged');
                    % This acquisition should cover the time of the SCP
                    % acquisition
                    [epics_matrix, mdl.t_stamp, epics_isPV] = lcaGetSyncHST(new_name, mdl.numPoints_user, char(mdl.eDef));
                    n = numel(mdl.t_stamp);
                    if mod(n,4) && n > 3 % for Decker and other timeslot analyzers...
                        mdl.t_stamp = mdl.t_stamp(3:end);
                        epics_matrix = epics_matrix(:,3:end);
                    end
                    mdl.time_stamps = mdl.t_stamp;
                end
                mdl.dataAcqStatus = 'Aligning EPICS and AIDA data';
                notify(mdl, 'AcqStatusChanged');
                
                epics_pid = epics_matrix(contains(new_name, 'PATT:SYS1:1:PULSEID'),:);
                mdl.the_matrix = nan(length(mdl.ROOT_NAME), size(epics_matrix, 2));
                mdl.the_matrix(~mdl.isSCP, :) = epics_matrix;
                aidaAcquired = ~isempty(bpm_struct);
                aidaFailed = 'failed';
                
                if aidaAcquired
                    % pull out X, Y, and TMIT data from SCP buffered acq
                    numBPM = numel(aidanames);
                    aida_pid = bpm_struct.values.id ; aida_pid = reshape(aida_pid, nPoints, numBPM)'; aida_pid = aida_pid(1,:);
                    aida_x = bpm_struct.values.x ; aida_x = reshape(aida_x, nPoints, numBPM)' ;
                    aida_y = bpm_struct.values.y ; aida_y = reshape(aida_y, nPoints, numBPM)' ;
                    aida_tmit = bpm_struct.values.tmits ; aida_tmit = reshape(aida_tmit, nPoints, numBPM)' ;

                    % interleave SCP data with EPICS data
                   
                    X_idx = contains(mdl.ROOT_NAME, aidanames) & endsWith(mdl.ROOT_NAME, ':X');
                    Y_idx = contains(mdl.ROOT_NAME, aidanames) & endsWith(mdl.ROOT_NAME, ':Y');
                    TMIT_idx = contains(mdl.ROOT_NAME, aidanames) & endsWith(mdl.ROOT_NAME, ':TMIT');
                    [pid, ~, mdl.hasSCP] = intersect(aida_pid, epics_pid);
                    if ~isempty(mdl.hasSCP)
                        mdl.the_matrix(X_idx, mdl.hasSCP) = aida_x;
                        mdl.the_matrix(Y_idx, mdl.hasSCP) = aida_y;
                        mdl.the_matrix(TMIT_idx, mdl.hasSCP) = aida_tmit;
                        aidaFailed = 'successful';
                        disp('great success')
                    else
                        mdl.status = 'AIDA and EPICS data do not overlap';
                        notify(mdl, 'StatusChanged');
                        disp('shame')
                    end
                end
                mdl.isPV = false(length(mdl.ROOT_NAME), 1);
                mdl.isPV(~mdl.isSCP) = epics_isPV;
                mdl.numPoints_acq = length(mdl.time_stamps);
                matlabTS = lca2matlabTime(mdl.time_stamps(end));
                
                mdl.dataAcqStatus = 'Data retrieved';
                notify(mdl, 'AcqStatusChanged');
                fprintf('Buffer %d data retrieved: %d points\n', mdl.eDefNumber, mdl.numPoints_acq);
                fprintf('AIDA buffered acquisition %s.\n', aidaFailed);
            else
                if isPrivate
                    % Acquire BSA data
                    mdl.dataAcqStatus = sprintf('Acquiring data in buffer %d', mdl.eDefNumber);
                    notify(mdl, 'AcqStatusChanged');
                    eDefAcq(mdl.eDefNumber, mdl.timeout);
                    mdl.dataAcqStatus = ['New Data: HST' num2str(mdl.eDefNumber)];
                    notify(mdl, 'AcqStatusChanged');
                    done = false;
                    while ~done
                        done = eDefDone(mdl.eDefNumber);
                        pause(0.1)
                    end
                    mdl.dataAcqStatus = sprintf('Retrieving data from buffer %d', mdl.eDefNumber);
                    notify(mdl, 'AcqStatusChanged');
                    [mdl.the_matrix, mdl.t_stamp, mdl.isPV] = lcaGetSmart(new_name, mdl.numPoints_user);
                    time = mdl.the_matrix(contains(new_name, {'PATT:SYS1:1:NSEC', 'PATT:SYS1:1:SEC'}),:);
                    nsecs = time(1,:); secs = time(2,:);
                    mdl.time_stamps = secs + nsecs*1e-9 + 631152000;
                    mdl.numPoints_acq = length(mdl.time_stamps);
                    matlabTS = lca2matlabTime(mdl.time_stamps(end));
                
                    mdl.dataAcqStatus = sprintf('Buffer %d data retrieved', mdl.eDefNumber);
                    notify(mdl, 'AcqStatusChanged');
                    disp([sprintf('Buffer %d data retrieved', mdl.eDefNumber) sprintf(': %d points', mdl.numPoints_acq)]);
                else
                    mdl.dataAcqStatus = sprintf('Retrieving %s data', mdl.eDef);
                    notify(mdl, 'AcqStatusChanged');

                    [mdl.the_matrix, mdl.t_stamp, mdl.isPV] = lcaGetSyncHST(mdl.ROOT_NAME, mdl.numPoints_user, char(mdl.eDef));

                    mdl.numPoints_acq = length(mdl.t_stamp);
                    matlabTS = lca2matlabTime(mdl.t_stamp(end));
                    n = numel(mdl.t_stamp);
                    if mod(n,4) && n > 3 % for Decker and other timeslot analyzers...
                        mdl.t_stamp = mdl.t_stamp(3:end);
                        mdl.the_matrix = mdl.the_matrix(:,3:end);
                    end
                    mdl.time_stamps = mdl.t_stamp;
                    mdl.dataAcqStatus = sprintf('%s data retrieved', mdl.eDef);
                    notify(mdl, 'AcqStatusChanged');
                    fprintf('%d points retrieved from %s\n', mdl.numPoints_acq, mdl.eDef);
                end
            end
            
            mdl.t_stamp = datestr(matlabTS);
            mdl.status = '';
            
            notify(mdl, 'StatusChanged');
            notify(mdl, 'DataAcquired');
            
        end
        
        function getData(mdl)
            % Funnel to correct acquisition method for current operational mode
            
            if mdl.facet
                getDataFacet(mdl);
                return
            end
            
            isPrivate = mdl.have_eDef;
            CU = strcmp(mdl.linac, 'CU');
            
            if CU && ~isPrivate % for calling a canned CU eDef
                
                mdl.dataAcqStatus = sprintf('Retrieving %s data', mdl.eDef);
                notify(mdl, 'AcqStatusChanged');
                
                [mdl.the_matrix, mdl.t_stamp, mdl.isPV] = lcaGetSyncHST(mdl.ROOT_NAME, mdl.numPoints_user, char(mdl.eDef));
                
                n = numel(mdl.t_stamp);
                if mod(n,4) && n > 3 % for Decker and other timeslot analyzers...
                    mdl.t_stamp = mdl.t_stamp(3:end);
                    mdl.the_matrix = mdl.the_matrix(:,3:end);
                end
                mdl.numPoints_acq = length(mdl.t_stamp);
                matlabTS = lca2matlabTime(mdl.t_stamp(end));
                mdl.time_stamps = mdl.t_stamp;
                mdl.dataAcqStatus = sprintf('%s data retrieved', mdl.eDef); 
                notify(mdl, 'AcqStatusChanged');
                fprintf('%d points retrieved from %s\n', mdl.numPoints_acq, mdl.eDef);
                
            else
                
                if isPrivate
                    
                    if CU
                        %Wait for enoloadcheck to finish loop to pause invasive
                        %measurement
                        if mdl.waitenoload && mdl.reserving
                            enoloadready = lcaGetSmart('SIOC:SYS0:ML01:AO636');
                            if ~enoloadready
                                mdl.dataAcqStatus ='Waiting for enoload';
                                notify(mdl, 'AcqStatusChanged');
                                drawnow();
                                while ~enoloadready
                                    enoloadready = lcaGetSmart('SIOC:SYS0:ML01:AO636');
                                end
                            end
                        end
                        timing_names = {'PATT:SYS0:1:NSEC'; 'PATT:SYS0:1:SEC'};
                        names = vertcat(mdl.ROOT_NAME, timing_names);
                        numacqPV = sprintf('EDEF:SYS0:%d:CNT', mdl.eDefNumber);
                    else
                        timing_names = {'TPG:SYS0:1:TSL'; 'TPG:SYS0:1:TSU'}; % these should already be in names
                        names = mdl.ROOT_NAME;
                        numacqPV = sprintf('BSA:SYS0:1:%d:CNT', mdl.eDefNumber);
                    end

                    new_name = strcat(names, {'HST'}, {num2str(mdl.eDefNumber)});
                    mdl.eDef = ['HST' num2str(mdl.eDefNumber)];
                    if mdl.reserving
                        %Tell enoloadcheck to that BSA is acquiring data
                        if CU, lcaPutSmart('SIOC:SYS0:ML01:AO637',1); end

                        % Acquire BSA data
                        mdl.dataAcqStatus = sprintf('Acquiring data in buffer %d', mdl.eDefNumber); 
                        notify(mdl, 'AcqStatusChanged');
                        eDefAcq(mdl.eDefNumber, mdl.timeout);
                        mdl.dataAcqStatus = ['New Data: HST' num2str(mdl.eDefNumber)];
                        notify(mdl, 'AcqStatusChanged');
                        done = false;
                        while ~done
                            done = eDefDone(mdl.eDefNumber);
                            pause(0.1)
                        end
                    end
                    
                    numacq = lcaGetSmart(numacqPV);
                    
                    if CU, lcaPutSmart('SIOC:SYS0:ML01:AO637',0); end %unpause enoloadcheck
                    
                    premessage = sprintf('Retrieving data from buffer %d', mdl.eDefNumber);
                    postmessage = sprintf('Buffer %d data retrieved', mdl.eDefNumber);
                    
                else
                    timing_names = {'TPG:SYS0:1:TSL';... % nanoseconds
                        'TPG:SYS0:1:TSU'}; % seconds
                    new_name = strcat(mdl.ROOT_NAME, 'HST', char(mdl.eDef));
                    premessage = sprintf('Retrieving %s data', mdl.eDef);
                    postmessage = sprintf('%s data retrieved', mdl.eDef);
                    numacq = mdl.numPoints_user;
                end
                
                mdl.dataAcqStatus = premessage;
                notify(mdl, 'AcqStatusChanged');
                
                % Retrieve data from the buffer
                
                [mdl.the_matrix, mdl.t_stamp, mdl.isPV] = lcaGetSmart(new_name, numacq);
                time = mdl.the_matrix(contains(new_name, timing_names),:);
                nsecs = time(1,:); secs = time(2,:);
                mdl.time_stamps = secs + nsecs*1e-9 + 631152000;
                mdl.numPoints_acq = length(mdl.time_stamps);
                matlabTS = lca2matlabTime(mdl.time_stamps(end));
                
                mdl.dataAcqStatus = postmessage; 
                notify(mdl, 'AcqStatusChanged');
                disp([postmessage sprintf(': %d points', mdl.numPoints_acq)]);
                
            end
            
            mdl.t_stamp = datestr(matlabTS);
            mdl.status = '';
            
            notify(mdl, 'StatusChanged');
            notify(mdl, 'DataAcquired');
            
        end
        
        
        function getFromDatastore(mdl, timeRange, pvs, BSD_inputs)
            % Launch BSA datastore options window
            mdl.BSD_inputs = BSD_inputs;
            
            runbatch = BSD_inputs.batch;
            sparseFactor = BSD_inputs.sparse;
            if mdl.isBR
                beamLine = [];
            else
                if endsWith(mdl.eDef, 'H')
                    beamLine = 'HXR';
                elseif endsWith(mdl.eDef, 'S')
                    beamLine = 'SXR';
                else
                    beamLine = [];
                end
            end
            mdl.dataAcqStatus = 'Getting Data...' ;
            notify(mdl, 'AcqStatusChanged');
            %pvs = strrep(pvs,'-','_');
            suffix = strcat(mdl.eDef, 'BR');
            time_pvs = contains(pvs, {'nanoseconds', 'secondsPastEpoch'});
            pvs(~time_pvs) = strcat(pvs(~time_pvs), suffix);
            data=fetch_bsa_slice(timeRange, pvs, mdl.linac, 'batch', runbatch, 'sparseFactor', sparseFactor, 'beamline', beamLine);
            
            if isempty(data)
                mdl.dataAcqStatus = 'No files found';
                notify(mdl, 'AcqStatusChanged');
                return
            end
            
            %             dual energy alignment from BSD under construction
            %
            %             if app.isBR
            %                 ltuh_idx = find(startsWith(data.ROOT_NAME,'BPMS:LTUH:250:X'));
            %                 ltus_idx = find(startsWith(data.ROOT_NAME,'BPMS:LTUS:235:X'));
            %                 ltuh = data.the_matrix(ltuh_idx,:);
            %                 ltus = data.the_matrix(ltus_idx,:);
            %                 cuh_data = ~isnan(ltuh);
            %                 cus_data = ~isnan(ltus);
            %                 if sum(cuh_data) == 0
            %                     data.the_matrix = data.the_matrix(:,cus_data);
            %                 elseif sum(cus_data) == 0
            %                     data.the_matrix = data.the_matrix(:,cuh_data);
            %                 else
            %                     t = data.the_matrix(1,:);
            %                     [~,ii,~] = unique(t);
            %                     idx1 = false(1,length(t));
            %                     idx1(ii) = true;
            %                     idx2 = ~idx1;
            %                     data1 = data.the_matrix(:,idx1);
            %                     data2 = data.the_matrix(:,idx2);
            %                     fillin = isnan(data1(:,1));
            %                     data1(fillin,:) = data2(fillin,:);
            %                     data.the_matrix = data1;
            %                 end
            %             end
            
            data.ROOT_NAME = strrep(data.ROOT_NAME, suffix, '');
            mdl.the_matrix = data.the_matrix(2:size(data.the_matrix,1),:);
            mdl.isPV = data.isPV(2:size(data.isPV,1),:);
            mdl.time_stamps = data.the_matrix(1,:);
            idx_in_mdl = find(contains(mdl.ROOT_NAME, data.ROOT_NAME)); 
            root_name = mdl.ROOT_NAME(idx_in_mdl);
            N = size(data.the_matrix, 2);
            num_names = length(root_name);
            data_for_sparse = zeros(N, num_names);
            rows = zeros(N, num_names);
            cols = zeros(N, num_names);
            
            % Convert data to sparse array
            for pvnum = 1:length(root_name)
                root_name_idx = find(contains(data.ROOT_NAME,root_name(pvnum)));
                data_for_sparse(:, pvnum) = mdl.the_matrix(root_name_idx(1) - 1,:);
                
                rows(:, pvnum) = ones(1,N) * idx_in_mdl(pvnum);
                cols(:, pvnum) = 1:N;
            end
            
            mdl.the_matrix = sparse(rows, cols, data_for_sparse, length(mdl.ROOT_NAME), N);
            mdl.BSD_ROOT_NAME = root_name;
                        
            mdl.PVListA = mdl.BSD_ROOT_NAME;
            mdl.PVListB = mdl.BSD_ROOT_NAME;
            notify(mdl, 'PVListChanged');
            
            mdl.idxA = 1:length(mdl.BSD_ROOT_NAME);
            mdl.idxB = 1:length(mdl.BSD_ROOT_NAME);
            
            mdl.numPoints_acq = N;
            
            mdl.t_stamp = datestr(datetime(mdl.time_stamps(1),'ConvertFrom','posixtime','TimeZone','America/Los_Angeles'));
            
            if isempty(mdl.bpms)
                mdl.bpms = setupBPMS(mdl);
            end
            
            notify(mdl, 'DataAcquired')
            
            mdl.dataAcqStatus = [mdl.eDef ' BSD data retrieved'] ;
            notify(mdl, 'AcqStatusChanged');
            
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
        
        function bpms = setupBPMS(mdl)
            %Define dispersive BPMS and identify indices of all BPMS in
            %ROOT_NAMES/the_matrix
            
            % Identify indices in ROOT_NAME for SXR/HXR, set flags to setup
            % SXR/HXR , or both
            
            if mdl.isBR
                [hxr_idx, sxr_idx, ~] = splitNames(mdl);
                if mdl.SXRBR == 0
                    use_idx = hxr_idx;
                    setup_SXR = 0;
                    setup_HXR = 1;
                elseif mdl.HXRBR == 0
                    use_idx = sxr_idx;
                    setup_SXR = 1;
                    setup_HXR = 0;
                else
                    use_idx = true(length(mdl.ROOT_NAME),1);
                    setup_SXR = 1;
                    setup_HXR = 1;
                end
            else
                use_idx = true(length(mdl.ROOT_NAME),1);
                setup_SXR = mdl.isSxr;
                setup_HXR = mdl.isHxr;
            end
            
            [prim,micro,unit,secn] = model_nameSplit(mdl.ROOT_NAME);
            n = strcat(prim,':', micro, ':', unit);
            isBpm = strcmp(prim,'BPMS');
            isX = strcmp(secn,'X');
            isY = strcmp(secn,'Y');
            bpms.x = mdl.ROOT_NAME(isBpm & isX & use_idx);
            bpms.y = mdl.ROOT_NAME(isBpm & isY & use_idx);
            bpms.x_id = find(isBpm & isX & use_idx);
            bpms.y_id = find(isBpm & isY & use_idx);
            
%             if setup_HXR && setup_SXR
%                 hxr_names = n(isBpm & hxr_idx);
%                 sxr_names = n(isBpm & sxr_idx);
%                 hxr_names = [{'CU_HXRI'}; hxr_names];
%                 sxr_names = [{'CU_SXR'}; sxr_names]; % change to CU_SXRI when that call is accepted by model
%                 hxr_names = unique(hxr_names, 'stable');
%                 sxr_names = unique(sxr_names, 'stable');
%                 
%                 twiss_h = model_rMatGet(hxr_names, [], {'TYPE=DESIGN', 'BEAMPATH=CU_HXRI'}, 'twiss');
%                 twiss_s = model_rMatGet(sxr_names, [], {'TYPE=DESIGN', 'BEAMPATH=CU_SXR'}, 'twiss');
%                 etax_h = twiss_h(5,:);
%                 etay_h = twiss_h(10,:);
%                 etax_s = twiss_s(5,:);
%                 etay_s = twiss_s(10,:);
%                 
%                 [dxh, ixh] = findpeaks(abs(etax_h));
%                 [dyh, iyh] = findpeaks(abs(etay_h));
%                 [dxs, ixs] = findpeaks(abs(etax_s));
%                 [dys, iys] = findpeaks(abs(etay_s));
%                 
%                 etax = [hxr_names(ixh(dxh > 0.01)); sxr_names(ixs(dxs > 0.01))];
%                 etay = [hxr_names(iyh(dyh > 0.01)); sxr_names(iys(dys > 0.01))];
%                 
%                 etax = unique(etax, 'stable');
%                 etay = unique(etay, 'stable');
%                 
%                 bpms.etax = strcat(etax, ':X');
%                 bpms.etay = strcat(etay, ':Y');
%             end
            
%             n = unique(n(isBpm & use_idx),'stable');
%             n_s = [{'CU_SXR'};n];
%             n_h = [{'CU_HXR'};n];
%             twiss_s = model_rMatGet(n_s, [], {'TYPE=DESIGN', 'BEAMPATH=CU_SXR'}, 'twiss');
%             twiss_h = model_rMatGet(n_h, [], {'TYPE=DESIGN', 'BEAMPATH=CU_HXR'}, 'twiss');
%             etax_s = twiss_s(5,:);
%             etay_s = twiss_s(10,:);
%             etax_h = twiss_h(5,:);
%             etay_h = twiss_h(10,:);
%             
%             etax_s(isnan(etax_s)) = 0;
%             etay_s(isnan(etay_s)) = 0;
%             etax_h(isnan(etax_h)) = 0;
%             etay_h(isnan(etay_h)) = 0;
%             
%             eta_lim = 0.1;
%             [dxs, ixs] = findpeaks(abs(etax_s));
%             etaxs = n(ixs(dxs>eta_lim)-1);
%             [dys, iys] = findpeaks(abs(etay_s));
%             etays = n(iys(dys>0.35)-1);
%             [dxh, ixh] = findpeaks(abs(etax_h));
%             etaxh = n(ixh(dxh>eta_lim)-1);
%             [dyh, iyh] = findpeaks(abs(etay_h));
%             etayh = n(iyh(dyh>0.01)-1);
            
            % set-up ids for bpms with horizontal dispersion

            if strcmp(mdl.linac, 'CU')
                j = 1;
                bpms.etax{j,:} = sprintf('BPMS:IN20:731:X'); j = j + 1;
                bpms.etax{j,:} = sprintf('BPMS:LI21:233:X'); j = j + 1;
                bpms.etax{j,:} = sprintf('BPMS:LI24:801:X'); j = j + 1;

                if setup_HXR
                    bpms.etax{j,:} = sprintf('BPMS:LTUH:250:X'); j = j + 1;
                    bpms.etax{j,:} = sprintf('BPMS:LTUH:450:X'); j = j + 1;
                end
                if setup_SXR
                    bpms.etax{j,:} = sprintf('BPMS:CLTS:420:X'); j = j + 1;
                    bpms.etax{j,:} = sprintf('BPMS:CLTS:620:X'); j = j + 1;
                    bpms.etax{j,:} = sprintf('BPMS:LTUS:235:X'); j = j + 1;
                    bpms.etax{j,:} = sprintf('BPMS:LTUS:370:X'); j = j + 1;
                end

                for j = 1:length(bpms.etax)
                    try
                        [bpms.etax_id(j)] = find(startsWith(mdl.ROOT_NAME,bpms.etax(j,:)));
                    catch
                    end
                end

                % set-up ids for bpms with vertical dispersion
                j=1;

                if setup_HXR
                    bpms.etay{j,:} = sprintf('BPMS:LTUH:130:Y'); j = j + 1;
                    bpms.etay{j,:} = sprintf('BPMS:LTUH:150:Y'); j = j + 1;
                    bpms.etay{j,:} = sprintf('BPMS:LTUH:170:Y'); j = j + 1;
                    bpms.etay{j,:} = sprintf('BPMS:DMPH:502:Y'); j = j + 1;
                    bpms.etay{j,:} = sprintf('BPMS:DMPH:693:Y'); j = j + 1;
                end
                if setup_SXR
                    bpms.etay{j,:} = sprintf('BPMS:CLTS:450:Y'); j = j + 1;
                    bpms.etay{j,:} = sprintf('BPMS:CLTS:590:Y'); j = j + 1;
                    bpms.etay{j,:} = sprintf('BPMS:DMPS:502:Y'); j = j + 1;
                    bpms.etay{j,:} = sprintf('BPMS:DMPS:693:Y'); j = j + 1;
                end

                for j = 1:length(bpms.etay)
                    try
                        [bpms.etay_id(j)] = find(startsWith(mdl.ROOT_NAME,bpms.etay(j,:)));
                    catch
                    end
                end
            else
                % SC BPMS

                j = 1;
                % bpms.etax{j,:} = sprintf('BPMS:HTR:540:X'); j = j + 1;
                % bpms.etax{j,:} = sprintf('BPMS:HTR:760:X'); j = j + 1;
                bpms.etax{j,:} = sprintf('BPMS:BC1B:440:X'); j = j + 1;
                bpms.etax{j,:} = sprintf('BPMS:BC2B:530:X'); j = j + 1;
                bpms.etax{j,:} = sprintf('BPMS:DOG:150:X'); j = j + 1;
                bpms.etax{j,:} = sprintf('BPMS:DOG:215:X'); j = j + 1;

                if setup_HXR
%                     bpms.etax{j,:} = sprintf('BPMS:SPH:322:X'); j = j + 1;
%                     bpms.etax{j,:} = sprintf('BPMS:SPH:420:X'); j = j + 1;
%                     bpms.etax{j,:} = sprintf('BPMS:SPH:450:X'); j = j + 1;
%                     bpms.etax{j,:} = sprintf('BPMS:SPH:520:X'); j = j + 1;
%                     bpms.etax{j,:} = sprintf('BPMS:SPH:840:X'); j = j + 1;
%                     bpms.etax{j,:} = sprintf('BPMS:SPH:915:X'); j = j + 1;
%                     bpms.etax{j,:} = sprintf('BPMS:SPH:940:X'); j = j + 1;
                    bpms.etax{j,:} = sprintf('BPMS:SLTH:220:X'); j = j + 1;
                    bpms.etax{j,:} = sprintf('BPMS:LTUH:450:X'); j = j + 1;
                end
                if setup_SXR
                    bpms.etax{j,:} = sprintf('BPMS:SPS:572:X'); j = j + 1;
                    bpms.etax{j,:} = sprintf('BPMS:SPS:710:X'); j = j + 1;
                    bpms.etax{j,:} = sprintf('BPMS:SPS:840:X'); j = j + 1;
                    %bpms.etax{j,:} = sprintf('BPMS:LTUS:300:X'); j = j + 1;
                    %bpms.etax{j,:} = sprintf('BPMS:LTUS:370:X'); j = j + 1;
                end

                for j = 1:length(bpms.etax)
                    try
                        [bpms.etax_id(j)] = find(startsWith(mdl.ROOT_NAME,bpms.etax(j,:)));
                    catch
                    end
                end

                % set-up ids for bpms with vertical dispersion
                j=1;
                bpms.etay{j,:} = sprintf('BPMS:DOG:135:Y'); j = j + 1;
                bpms.etay{j,:} = sprintf('BPMS:DOG:200:Y'); j = j + 1;
                if setup_HXR
%                     bpms.etax{j,:} = sprintf('BPMS:SPH:450:Y'); j = j + 1;
%                     bpms.etax{j,:} = sprintf('BPMS:SPH:520:Y'); j = j + 1;
%                     bpms.etax{j,:} = sprintf('BPMS:SPH:600:Y'); j = j + 1;
%                     bpms.etax{j,:} = sprintf('BPMS:SPH:760:Y'); j = j + 1;
%                     bpms.etax{j,:} = sprintf('BPMS:SPH:840:Y'); j = j + 1;
%                     bpms.etax{j,:} = sprintf('BPMS:SPH:915:Y'); j = j + 1;
                end
                if setup_SXR
%                     bpms.etay{j,:} = sprintf('BPMS:LTUS:540:Y'); j = j + 1;
%                     bpms.etay{j,:} = sprintf('BPMS:LTUS:560:Y'); j = j + 1;
                end

                for j = 1:length(bpms.etay)
                    try
                        [bpms.etay_id(j)] = find(startsWith(mdl.ROOT_NAME,bpms.etay(j,:)));
                    catch
                    end
                end
            end
            
            [prim,micro,unit,secn] = model_nameSplit(mdl.ROOT_NAME);
            
            isBpm = strcmp(prim,'BPMS');
            isX = strcmp(secn,'X');
            isY = strcmp(secn,'Y');
            bpms.x = mdl.ROOT_NAME(isBpm & isX & use_idx);
            bpms.y = mdl.ROOT_NAME(isBpm & isY & use_idx);
            bpms.x_id = find(isBpm & isX & use_idx);
            bpms.y_id = find(isBpm & isY & use_idx);
            
            % identify dispersion BPMS within list of all BPMS in ROOT_NAME
            for j = 1:length(bpms.etay)
                [bpms.etay_id(j)] = find(startsWith(mdl.ROOT_NAME,bpms.etay(j,:)));
                [bpms.etay_sub_id(j)] = find(startsWith(bpms.y,bpms.etay(j,:)));
            end
            
            for j = 1:length(bpms.etax)
                [bpms.etax_id(j)] = find(startsWith(mdl.ROOT_NAME,bpms.etax(j,:)));
                [bpms.etax_sub_id(j)] = find(startsWith(bpms.x,bpms.etax(j,:)));
            end
            
        end
        
    end
end


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
