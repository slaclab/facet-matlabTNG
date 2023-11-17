function [root_name, z] = bsagui_getRootNames(mdl)
% returns PV names and z locations for current operational mode.

if mdl.dev
    root_name = devNames(mdl);
    beamPath = [mdl.destination 'I'];
elseif mdl.facet
    [root_name, z] = facetNames(mdl);
    % JR 12/6/22 - Odd first 2 names coming up, seems to clear when
    % recalled, not sure what is causing the issue
    if startsWith(root_name(1), 'Gtk')
        [root_name, z] = facetNames(mdl);
    end
    beamPath = 'F2_ELEC';
else  % prod, on an lcls server
    root_name = lclsNames(mdl);
    beamPath = [mdl.destination 'I'];
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
%elseif mdl.facet
    %nonBPMS = ~contains(root_name, 'BPMS');
    %z(nonBPMS) = model_rMatGet(n(nonBPMS),[],{'TYPE=DESIGN',['BEAMPATH=' beamPath]},'Z');
else
    z = model_rMatGet(n,[],{'TYPE=DESIGN',['BEAMPATH=' beamPath]},'Z');
end

[z, I] = sort(z);
if mdl.facet && mdl.acqSCP
    mdl.isSCP = mdl.isSCP(I);
end
root_name = root_name(I);

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
else
    tag = ['LCLS.' mdl.destination '.BSA.rootnames'];
end
root_name = meme_names('tag', tag, 'sort','z');
end

function [root_name, z] = facetNames(mdl)
% get directory service names, and format correctly
[~, root_name] = system('eget -ts ds -a tag=FACET.BSA.rootnames -w 20');
root_name = splitlines(root_name);
root_name = root_name(~cellfun(@isempty, root_name));
%root_name = [];
if isempty(root_name)
    root_name = cellstr(readlines("rootnames_saved.txt"));
else
    writelines(root_name,"rootnames_saved.txt");
end
%root_name(contains(root_name, 'BPMS')) = [];

if isempty(mdl.scpNames)
    % get SCP names, if not already done
    initSCPNames(mdl);
end

if mdl.acqSCP
    % interleave EPICS names and SCP names by Z
    numEPICS = length(root_name);
    z = zeros(numEPICS, 1);
    mdl.isSCP = false(numEPICS, 1);
    useSCP = mdl.scpNames.use;
    root_name = [root_name; mdl.scpNames.names(useSCP)];
    z(numEPICS + 1 : length(root_name)) = mdl.scpNames.z(useSCP);
    mdl.isSCP(numEPICS + 1 : length(root_name)) = true;
else
    numEPICS = length(root_name);
    z = zeros(numEPICS, 1);
    %root_name = [root_name; mdl.scpNames.names(~mdl.scpNames.scp_idx)];
    %z(numEPICS+1:length(root_name)) = mdl.scpNames.z(~mdl.scpNames.scp_idx);
    mdl.isSCP = false(length(root_name), 1);
end

end


function initSCPNames(mdl)
% read in SCP names from the Lucretia model

mdl.LM = LucretiaModel(F2_common.LucretiaLattice);
names = mdl.LM.ControlNames;
z = mdl.LM.ModelZ;

% extract BPMS names
bpm_loc = contains(names, 'BPMS');
bpmnames = names(bpm_loc); z_bpms = z(bpm_loc);
scp_loc = startsWith(bpmnames, 'LI');
scpBPMS = bpmnames(scp_loc); z_scp = z_bpms(scp_loc);
epicsBPMS = bpmnames(~scp_loc); z_epics = z_bpms(~scp_loc);
[sec, prim, unit] = model_nameSplit(scpBPMS);
scpBPMS = strcat(prim, ':', sec, ':', unit);

% append attributes
X_scp = strcat(scpBPMS, ':X');
Y_scp = strcat(scpBPMS, ':Y');
TMIT_scp = strcat(scpBPMS, ':TMIT');
scpBPMS = [X_scp; Y_scp; TMIT_scp]; z_scp = [z_scp; z_scp; z_scp];
X_epics = strcat(epicsBPMS, ':X');
Y_epics = strcat(epicsBPMS, ':Y');
TMIT_epics = strcat(epicsBPMS, ':TMIT');
epicsBPMS = [X_epics; Y_epics; TMIT_epics]; z_epics = [z_epics; z_epics; z_epics];


% extract klystron names
kidx = startsWith(names, 'K');
knames = names(kidx);
z_klys = z(kidx);
scpKLYS = cell(length(knames),1);
for n = 1:length(knames)
    name = char(knames(n));
    if contains(name, '_')
        sec = name(2:3);
        unit = name(5);
        scpKLYS{n} = sprintf('KLYS:LI%s:%s1:PHAS', sec, unit);
    end
end
badname = cellfun(@isempty, scpKLYS);
scpKLYS(badname)=[];
z_klys(badname) = [];
[scpKLYS, uniqueIdx] = unique(scpKLYS, 'stable');
z_klys = z_klys(uniqueIdx);

% create subbooster names
scpSBST = cell(10, 1);
for sec = 11:20
    name = sprintf('SBST:LI%d:1:PHAS', sec);
    scpSBST{sec-10} = name;
end
z_sbst = zeros(10,1);

% struct of SCP names and relevant related data
mdl.scpNames.names = [scpBPMS; scpKLYS; scpSBST];
mdl.scpNames.z = [z_scp; z_klys; z_sbst];
mdl.scpNames.use = true(length(mdl.scpNames.names), 1);
mdl.scpNames.bpmsIdx = contains(mdl.scpNames.names, scpBPMS);
mdl.scpNames.rfIdx = contains(mdl.scpNames.names, [scpKLYS; scpSBST]);
mdl.scpNames.getBPMS = 1;
mdl.scpNames.getRF = 1;

% interleave EPICS and SCP BPMS
names = [scpBPMS; epicsBPMS];
scp_idx = contains(names, scpBPMS);
facet_offset = 1002.1;
z = [z_scp; z_epics]; z = z - facet_offset;
[z, I] = sort(z);
names = names(I);
scp_idx = scp_idx(I);
mdl.facetBPMS.names = names;
mdl.facetBPMS.z = z;
mdl.facetBPMS.scp_idx = scp_idx;



end
