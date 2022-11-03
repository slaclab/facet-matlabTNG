function bpms = bsagui_setupBPMS(mdl)
%Define dispersive BPMS and identify indices of all BPMS in
%ROOT_NAMES/the_matrix

% Identify indices in ROOT_NAME for SXR/HXR, set flags to setup
% SXR/HXR , or both


[prim,micro,unit,secn] = model_nameSplit(mdl.ROOT_NAME);
names = strcat(prim,':', micro, ':', unit);
isBpm = strcmp(prim,'BPMS');
isX = strcmp(secn,'X');
isY = strcmp(secn,'Y');
isTMIT = strcmp(secn, 'TMIT');
bpms.x = mdl.ROOT_NAME(isBpm & isX);% & use_idx);
bpms.y = mdl.ROOT_NAME(isBpm & isY);% & use_idx);
bpms.tmit = mdl.ROOT_NAME(isBpm & isTMIT);
bpms.x_id = find(isBpm & isX);% & use_idx);
bpms.y_id = find(isBpm & isY);% & use_idx);
bpms.tmit_id = find(isBpm & isTMIT);


if strcmp(mdl.linac, 'CU')
    beampath = mdl.destination;
    bpmNames = unique(names(isBpm), 'stable');
    [bpms.etax, bpms.etay] = lclsBPMS(bpmNames, beampath);
elseif strcmp(mdl.linac, 'SC')
    if isempty(mdl.destination)
        bpms = [];
        return
    end
    bpmNames = unique(names(isBpm), 'stable');
    [bpms.etax, bpms.etay] = lclsBPMS(bpmNames, mdl.destination);
elseif mdl.facet
    [bpms.etax, bpms.etay] = facetBPMS(names(isBpm));
else
    return
end
for j = 1:length(bpms.etax)
    try
        [bpms.etax_id(j)] = find(startsWith(mdl.ROOT_NAME,bpms.etax(j,:)));
    catch
    end
end
for j = 1:length(bpms.etay)
    try
        [bpms.etay_id(j)] = find(startsWith(mdl.ROOT_NAME,bpms.etay(j,:)));
    catch
    end
end

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

function [xbpms, ybpms] = lclsBPMS(bpms, beampath)
if isempty(beampath)
    [z_hxr, twiss_hxr] = model_rMatGet(bpms, [], {'TYPE=DESIGN', 'BEAMPATH=CU_HXR'}, {'Z', 'twiss'});
    [z_sxr, twiss_sxr] = model_rMatGet(bpms, [], {'TYPE=DESIGN', 'BEAMPATH=CU_SXR'}, {'Z', 'twiss'});
    etax_hxr = twiss_hxr(5,:);
    etay_hxr = twiss_hxr(10,:);
    etax_sxr = twiss_sxr(5,:);
    etay_sxr = twiss_sxr(10,:);
    xIdx_hxr = abs(etax_hxr) > 0.01;
    yIdx_hxr = abs(etay_hxr) > 0.01;
    xIdx_sxr = abs(etax_sxr) > 0.01;
    yIdx_sxr = abs(etay_sxr) > 0.01;
    xbpms_hxr = strcat(bpms(xIdx_hxr), ':X');
    ybpms_hxr = strcat(bpms(yIdx_hxr), ':Y');
    xbpms_sxr = strcat(bpms(xIdx_sxr), ':X');
    ybpms_sxr = strcat(bpms(yIdx_sxr), ':Y');
    z_x_hxr = z_hxr(xIdx_hxr)';
    z_y_hxr = z_hxr(yIdx_hxr)';
    z_x_sxr = z_sxr(xIdx_sxr)';
    z_y_sxr = z_sxr(yIdx_sxr)';
    xbpms = unique([xbpms_hxr; xbpms_sxr], 'stable');
    ybpms = unique([ybpms_hxr; ybpms_sxr], 'stable');
    z_x = unique([z_x_hxr; z_x_sxr], 'stable');
    z_y = unique([z_y_hxr; z_y_sxr], 'stable');
    
else
    [z, twiss] = model_rMatGet(bpms, [], {'TYPE=DESIGN', ['BEAMPATH=' beampath]}, {'Z', 'twiss'});
    etax = twiss(5,:);
    etay = twiss(10,:);
    xIdx = abs(etax) > 0.01;
    yIdx = abs(etay) > 0.01;
    xbpms = strcat(bpms(xIdx), ':X');
    ybpms = strcat(bpms(yIdx), ':Y');
    z_x = z(xIdx);
    z_y = z(yIdx);
end
[~, ix] = sort(z_x);
[~, iy] = sort(z_y);
xbpms = unique(xbpms(ix), 'stable');
ybpms = unique(ybpms(iy), 'stable');
end

function [xbpms, ybpms] = facetBPMS(mdl)
bpmIdx = contains(mdl.LM.ControlNames, 'BPMS');
modelIdx = mdl.LM.ModelID(bpmIdx);
etax = mdl.LM.DesignTwiss.etax(modelIdx);
etay = mdl.LM.DesignTwiss.etay(modelIdx);
xIdx = abs(etax) > 0.01;
yIdx = abs(etay) > 0.01;
namelist = mdl.facetBPMS.names;
xnames = namelist(endsWith(namelist, ':X'));
ynames = namelist(endsWith(namelist, ':Y'));
xbpms = xnames(xIdx);
ybpms = ynames(yIdx);
disp(xbpms) ; disp(ybpms);

end