function [root_name, z] = bsagui_getRootNames(mdl)
% returns PV names and z locations for current operational mode.
%
% Author: Jake Rudolph

root_name_empty = false;

if mdl.dev
    root_name = devNames(mdl);
    beamPath = [mdl.destination 'I'];
    if isempty(root_name)
        root_name_empty = true;
        root_name = cellstr(readlines('bsagui_rootnames_saved_dev.txt'));
    end
elseif mdl.facet
    [root_name, z, root_name_empty] = facetNames(mdl);
    beamPath = 'F2_ELEC';
else  % prod, on an lcls server
    root_name = lclsNames(mdl);
    if strcmp(mdl.destination, 'SC_LINAC') % SC_LINAC beampath not in the model, but devices are identical to SC_BSYD
        beamPath = 'SC_BSYDI';
    else
        beamPath = [mdl.destination 'I'];
    end
    if isempty(root_name)
        root_name_empty = true;
        root_name = cellstr(readlines('bsagui_rootnames_saved_lcls.txt'));
    end
    
end

% Get z positions,
[prim,micro,unit] = model_nameSplit(root_name);
n = strcat(prim,':', micro, ':', unit);

if mdl.lcls && ~mdl.isSxr && ~mdl.isHxr && ~strcmp(mdl.linac, 'SC')% if dual energy, need to cross reference HXR and SXR models
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
if mdl.facet && mdl.acqSCP
    mdl.isSCP = mdl.isSCP(I);
end
root_name = root_name(I);

if root_name_empty
    warningTxt = "PV names loaded from file. There may be an issue with the directory service.";
    warndlg(warningTxt);
end

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

% Look for the most recent BSA file
tRef = datetime('now','TimeZone','Z');
found = 0;
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

% Bring returned names into correct format
for i = 1:length(root_name)
    name = root_name{i};
    rep = strfind(name,'_');
    try name(rep(1:3)) = ':'; catch end
    root_name{i} = name;
end

end

function root_name = lclsNames(mdl)
if isempty(mdl.destination)
    tag = 'LCLS.BSA.rootnames';
elseif strcmp(mdl.destination, 'SC_LINAC') % SC_LINAC does not have its own tag, but devices are equivalent to SC_BSYD
    tag = 'LCLS.SC_BSYD.BSA.rootnames';
else
    tag = ['LCLS.' mdl.destination '.BSA.rootnames'];
end
root_name = meme_names('tag', tag, 'sort','z');
end

function [root_name, z, root_name_empty] = facetNames(mdl)
% get directory service names, and format correctly
[~, root_name] = system('eget -ts ds -a tag=FACET.BSA.rootnames -w 20');
root_name = splitlines(root_name);
root_name = root_name(~cellfun(@isempty, root_name));
root_name(contains(root_name, 'BPMS')) = [];
root_name_empty = false;
if isempty(root_name)
    root_name_empty = true;
    fileID = fopen('bsagui_rootnames_saved_facet.txt','r');
    names_cell = textscan(fileID,'%s');
    root_name = cellstr(string(names_cell{:}));
    %root_name = cellstr(readlines('bsagui_rootnames_saved_facet.txt'));
end

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

end


function initSCPNames(mdl)
% read in SCP names from the Lucretia model

mdl.LM = LucretiaModel(F2_common.LucretiaLattice);
names = mdl.LM.ControlNames;
z = mdl.LM.ModelZ;
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