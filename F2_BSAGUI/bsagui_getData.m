function bsagui_getData(mdl)
% Funnel to correct acquisition method for current operational mode

if mdl.facet
    getDataFacet(mdl);
    return
elseif mdl.dev
    getFromDatastore(mdl);
    return
end


isPrivate = mdl.have_eDef;
CU = strcmp(mdl.linac, 'CU');

if CU && ~isPrivate % for calling a canned CU eDef
    
    mdl.dataAcqStatus = sprintf('Retrieving %s data', mdl.eDef);
    notify(mdl, 'AcqStatusChanged');
    
    [mdl.the_matrix, mdl.t_stamp, mdl.isPV] = lcaGetSyncHST(mdl.ROOT_NAME, mdl.numPoints_user, char(mdl.eDef));
   
    if isempty(mdl.t_stamp)
         errTxt = "No data acquired; call to lcaGetSyncHST returns empty.";
         error("BG:ACQEMPTY", errTxt);
    end
    
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
    
    if sum(mdl.isPV) == 0
         errTxt = "No data acquired; call to lcaGetSmart returns no valid PVs.";
         error("BG:ACQEMPTY", errTxt);
    end
    
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
    builder.timeout(300)
    data = ML(builder.get());
    mdl.dataAcqStatus = 'Finished AIDA buffered acquisition';
    notify(mdl, 'AcqStatusChanged');
catch ME
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
            nPoints = str2double(inputdlg('Number of points', 'SCP Points'));
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
    mdl.bpms = bsagui_setupBPMS(mdl);
end

notify(mdl, 'DataAcquired')

mdl.dataAcqStatus = [mdl.eDef ' BSD data retrieved'] ;
notify(mdl, 'AcqStatusChanged');

end