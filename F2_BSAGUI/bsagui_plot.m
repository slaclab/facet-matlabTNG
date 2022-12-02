function bsagui_plot(mdl, yvar, xvar)
% Prepare data for plotting, and select which plot/tool function to use

mdl.status = '';
notify(mdl, 'StatusChanged');

if isempty(mdl.the_matrix)
    mdl.status = 'Take data before plotting!!';
    notify(mdl, 'StatusChanged')
    disp('No data');
    return
end

y_PV = yvar;

xisPV = any(contains(mdl.ROOT_NAME, xvar));
if xisPV, x_PV = xvar; end
    
try YinA = contains(mdl.PVA, yvar); catch, YinA = []; end
try YinB = contains(mdl.PVB, yvar); catch, YinB = []; end
if any(YinA), yvar = 'PVA';
elseif any(YinB), yvar = 'PVB';
elseif strcmp(yvar,mdl.formula_string), yvar = 'PVC';
end

try XinA = contains(mdl.PVA, xvar); catch, XinA = []; end
try XinB = contains(mdl.PVB, xvar); catch, XinB = []; end
if any(XinA),xvar='PVA';
elseif any(XinB),xvar='PVB';
elseif strcmp(xvar,mdl.formula_string),xvar='PVC';
end



% find relevant variable indices in mdl.ROOT_NAME
if mdl.facet
    PIDPV = 'PATT:SYS1:1:PULSEID';
else
    PIDPV = 'PATT:SYS0:1:PULSEID';
end
PIDidx = startsWith(mdl.ROOT_NAME, PIDPV);
try PVAidx = endsWith(mdl.ROOT_NAME,mdl.PVA); catch, end
try PVBidx = endsWith(mdl.ROOT_NAME,mdl.PVB); catch, end

% identify time data in seconds and pulse num
if strcmp(mdl.linac, 'CU') || mdl.facet
    PID = full(mdl.the_matrix(PIDidx,:));
    [~, ~, PID] = unrollpid(PID);
    t = PID / 360;
    plotdata.Time = t;
    plotdata.Index = PID/3;
else
    plotdata.Time = mdl.time_stamps - mdl.time_stamps(1);
    plotdata.Index = 1:length(mdl.time_stamps);
end


try plotdata.PVA = full(mdl.the_matrix(PVAidx,:)); catch, end
try plotdata.PVB = full(mdl.the_matrix(PVBidx,:)); catch, end
try plotdata.PVC = full(mdl.PVC); catch, end

plottext.Time = 'TIME [s]';
plottext.Index = 'Pulse #';
try plottext.PVA = mdl.ROOT_NAME(PVAidx,:); catch, end
try plottext.PVB = mdl.ROOT_NAME(PVBidx,:); catch, end
try plottext.PVC = mdl.formula_string; catch, end

% selected plot function might not need ydata
if strcmp(xvar,'Z PSD')
    ZPSD(mdl);
elseif strcmp(xvar, 'Z RMS')
    ZRMS(mdl);
elseif strcmp(xvar, 'Jitter Pie')
    jitter_pie(mdl);
else
    % if it does need ydata, verify selected variable
    try
        ytext = plottext.(yvar);
        idx = contains(ytext, y_PV);
        ydata = plotdata.(yvar);
        ydata = ydata(idx,:);
        ytext = ytext(idx);
    catch
        mdl.status = 'No variable selected';
        notify(mdl, 'StatusChanged')
        disp('No variable selected');
        return
    end
    mdl.status = '';
    notify(mdl, 'StatusChanged')

    % nan handling
    nans = isnan(ydata);
    if sum(nans, 'all') == numel(ydata)
        mdl.status = [ytext{:} ' data all NaNs'];
        notify(mdl, 'StatusChanged')
        disp([ytext{:} ' data all NaNs']);
        return
    end
    mdl.status = '';
    notify(mdl, 'StatusChanged')

    % identify and call user selected plot function
    if strcmp(xvar,'PSD')
        ydata(nans) = 0;
        PSD(mdl,ydata,ytext);
    elseif strcmp(xvar,'Histogram')
        ydata(nans) = [];
        Hist(mdl,ydata,ytext);
    elseif strcmp(xvar,'All Z')
        AllZ(mdl,ydata,ytext);
    else
        xtext = plottext.(xvar);
        try
            idx = contains(xtext, x_PV); % this should break if x_PV not defined in xisPV above
            xdata = plotdata.(xvar);
            xdata = xdata(idx,:);
            xtext = xtext(idx);
        catch
            xdata = plotdata.(xvar);
        end
        
        allnanrow = sum(nans, 2) == size(ydata, 2);
        ydata(allnanrow, :) = [];
        ytext(allnanrow) = [];
        
        % if it's a time or correlation plot, set relevant
        % variables and call
        
        if mdl.multiplot && mdl.multiplot_same
            [row, col] = size(ydata);
            for ii = 1:row
                for jj = 1:col
                    if isnan(ydata(ii, jj))
                        try
                            ydata(ii, jj) = ydata(ii, jj-1);
                        catch
                            ydata(ii, jj) = 0;
                        end
                    end
                end
            end
            multiTrace(mdl, xdata, ydata, xtext, ytext);
            return
        end
        nancols = sum(nans, 1) ~= 0;
        ydata(:, nancols) = [];
        xdata(nancols) = []; 
        if contains(xvar,'Time') || contains(xvar,'Index')
            time_plot(mdl,xdata,ydata,xtext,ytext);
        else
            nans = isnan(xdata);
            if sum(nans) == length(xdata)
                mdl.status = [xtext{:} ' data all NaNs'];
                notify(mdl, 'StatusChanged')
                disp([xtext{:} ' data all NaNs']);
                return
            end
            mdl.status = '';
            notify(mdl, 'StatusChanged')

            ydata(:, nans) = [];
            xdata(nans) = [];

            corr_plot(mdl,xdata,ydata,xtext,ytext);
        end
    end
end
end

function time_plot(mdl,xdata,ydata,xtext,ytext)
%Generate a time-like plot

% Offset data if requested by user
if mdl.offset > 0
    xdata = xdata(1 + mdl.offset:length(xdata));
    ydata = ydata(1:length(ydata) - mdl.offset);
elseif mdl.offset < 0
    xdata = xdata(1:length(xdata) + mdl.offset);
    ydata = ydata(1 + abs(mdl.offset):length(ydata));
end

figure;
plot_menus_BSA(mdl.app)
plot(xdata, ydata, '-', xdata, ydata, '*');
plotInit(xtext, ytext);

std_y=util_stdNan(ydata);

std_mean_y = sprintf('%5.3g',std_y/util_meanNan(ydata));

% If user created variable, display pvs used
if strcmp(ytext,mdl.formula_string) || strcmp(xtext,mdl.formula_string)
    pos = [1, 1.07]; horz = 'right'; str = mdl.formula_pvs; fontSize = 0.03;
    addText(pos, horz, str, fontSize);
end

pos = [-0.1, -0.07]; horz = 'left'; str = ['std = ' sprintf('%5.3g',std_y )]; 
addText(pos, horz, str);
pos = [-0.1, -0.11]; horz = 'left'; str = ['std/mean = ' std_mean_y]; 
addText(pos, horz, str);
pos = [0.1, 1.02]; horz = 'left'; str = ytext;
addText(pos, horz, str);
pos = [1.0, -0.07]; horz = 'right'; str = mdl.t_stamp;
addText(pos, horz, str);

end

function multiTrace(mdl, xdata, ydata, xtext, ytext)
% Offset data if requested by user
if mdl.offset > 0
    xdata = xdata(1 + mdl.offset:length(xdata));
    ydata = ydata(:,1:length(ydata) - mdl.offset);
elseif mdl.offset < 0
    xdata = xdata(1:length(xdata) + mdl.offset);
    ydata = ydata(:,1 + abs(mdl.offset):length(ydata));
end

figure;
hold on
plot_menus_BSA(mdl.app);
for i = 1:size(ydata, 1)
    plot(xdata, ydata(i,:));
end
legend(ytext, 'Location', 'eastoutside');
plotInit(xtext, '');
pos = [1.0, -0.07]; horz = 'right'; str = mdl.t_stamp;
addText(pos, horz, str);


end

function corr_plot(mdl,xdata,ydata,xtext,ytext)
%Generate a plot between 2 beam line variables

% Offset data if requested by user
if mdl.offset > 0
    xdata = xdata(1+mdl.offset:length(xdata));
    ydata = ydata(1:length(ydata)-mdl.offset);
elseif mdl.offset < 0
    xdata = xdata(1:length(xdata)+mdl.offset);
    ydata = ydata(1+abs(mdl.offset):length(ydata));
end

figure;
plot_menus_BSA(mdl.app);
[p,Y,~] = util_polyFit(xdata, ydata, 1 );
%Y = p(1)*xdata + p(2);
plot(xdata, ydata, '*', xdata, Y, '-');
plotInit(xtext, ytext);

if strcmp(ytext,mdl.formula_string) || strcmp(xtext,mdl.formula_string)
    pos = [1, 1.07]; horz = 'right'; str = mdl.formula_pvs; fontSize = 0.03;
    addText(pos, horz, str, fontSize);
end

corf = corcoef(xdata, ydata);
cf=sprintf('%4.2f',corf);

pos = [0.9, 1.02]; horz = 'right'; str = ['corr coef = ' cf];
addText(pos, horz, str);

pos = [0.02, 0.95]; horz = 'left'; str = sprintf('Y = MX + B');
addText(pos, horz, str);

pos = [0.02, 0.91]; horz = 'left'; str = sprintf('M = %7.3g ', p(1));
addText(pos, horz, str);

pos = [0.1, 1.02]; horz = 'left'; str = ytext;
addText(pos, horz, str);

pos = [1.0, -0.07]; horz = 'right'; str = mdl.t_stamp;
addText(pos, horz, str);

end

function PSD(mdl,ydata,ytext)
% Generate Power Spectrum Density plots

disp('A PSD button pressed...');
if mdl.facet
    indx2 = startsWith(mdl.ROOT_NAME,sprintf('PATT:SYS1:1:PULSEID'));
    xdata = mdl.the_matrix(indx2,:);
    
    %Unroll PULSEID
    [~, ~, xdata] = unrollpid(xdata, xdata);
    
    seconds = xdata / 360;
    
else
    switch mdl.linac
        case 'CU'
            indx2 = startsWith(mdl.ROOT_NAME,sprintf('PATT:SYS0:1:PULSEID'));
            xdata = mdl.the_matrix(indx2,:);

            %Unroll PULSEID
            [~, ~, xdata] = unrollpid(xdata);

            seconds = xdata / 360;
        case 'SC'
            idx_lower = startsWith(mdl.ROOT_NAME, 'TPG:SYS0:1:PIDL');
            idx_upper = startsWith(mdl.ROOT_NAME, 'TPG:SYS0:1:PIDU');
            lwr = mdl.the_matrix(idx_lower,:);
            upr = mdl.the_matrix(idx_upper,:);
            xdata = bitshift(upr, 32) + lwr;

            xdata = xdata - xdata(1);
            seconds = xdata / 910000;
    end
end
% test for rate change
dt = diff(seconds);
[beamrate_vector] = 1./dt;
beamrate_vector(isinf(beamrate_vector))=NaN;

secs = seconds(1:length(seconds)-1);

% plot beamrate
figure
plot_menus_BSA(mdl.app)
plot(secs,beamrate_vector,'.-')
ylabel('Beamrate',...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize', 0.040);

% Look for beamrate discontinuities
max_rate = max(beamrate_vector);
diff_xdata = (diff(xdata));
diff_xdata = diff_xdata - diff_xdata(1);
diff_xdata_sum = sum(abs(diff_xdata));

if diff_xdata_sum~=0
    disp('rate varied during data!   Taking largest block of highest rate')
    disp(' this is still... under construction!')
    
    dx = diff(xdata);
    ddx = (diff(dx));
    id_pblm = find(ddx~=0);
    
    % Plot discontinuities
    figure
    plot_menus_BSA(mdl.app)
    datalen = (1:length(ddx));
    plot(datalen,ddx,'.-',datalen(id_pblm),ddx(id_pblm),'s')
    ylabel('Beamrate Derivative Discontinuities',...
        'Units','normalized',...
        'FontUnits','normalized',...
        'FontSize', 0.040);
    
    % Find largest block with continuous beamrate
    [block_boundaries] = [1 id_pblm length(xdata)];
    blocks = diff(block_boundaries);
    [~, iblock] = sort(blocks,'descend');
    select = 0;
    for jj = 1:length(blocks)
        if ((round(beamrate_vector(block_boundaries(iblock(jj))+1)) >= round(max_rate)) && select==0)
            select = 1;
            block_index = [block_boundaries(iblock(jj)) block_boundaries(iblock(jj)+1)];
            disp('getting indices of highest beamrate data block to be used')
            [ydata] = ydata(block_index(1)+2:block_index(2)-2);
            % Plot ydata in largest block
            figure
            plot_menus_BSA(mdl.app)
            plot(seconds(block_index(1)+2:block_index(2)-2),ydata,'.-')
            yStr = 'data selected for use'; xStr = 'TIME [s]';
            plotInit(xStr, yStr);
            
            if strcmp(ytext,mdl.formula_string)
                pos = [1, 1.07]; horz = 'right'; str = mdl.formula_pvs; fontSize = 0.03;
                addText(pos, horz, str, fontSize);
            end
            
            pos = [0.1, 1.02]; horz = 'left'; str = ytext;
            addText(pos, horz, str);
            
            pos = [1.0, -0.07]; horz = 'right'; str = mdl.t_stamp;
            addText(pos, horz, str);
        end
    end
    
end

figure;
plot_menus_BSA(mdl.app)
beamrate = max_rate;

% Calculate PSD
[ p ] = psdint(ydata',beamrate, length(ydata'),'s',0,0);
freq   = p(2:length(p),1);
psd_mm = p(2:length(p),2);

%Raw PSD vs Freq
plot(freq,psd_mm);
xStr = 'Frequency [Hz]'; yStr = 'Power Spectral Density';
plotInit(xStr, yStr);

if strcmp(ytext,mdl.formula_string)
    pos = [1, 1.07]; horz = 'right'; str = mdl.formula_pvs; fontSize = 0.03;
    addText(pos, horz, str, fontSize);
end



pos = [1.0, -0.07]; horz = 'right'; str = mdl.t_stamp;
addText(pos, horz, str);

mm_sq = freq(1)*(cumsum(psd_mm(length(psd_mm):-1:1)));
mm_squared = flipud(mm_sq);
%mm = sqrt(mm_squared);

%PSD/Integrated PSD vs. freq
figure;
plot_menus_BSA(mdl.app)
plot(freq, mm_squared, '-', freq, mm_squared, '*');
xStr = 'Frequency [Hz]'; 
yStr = 'Integrated PSD * df';
plotInit(xStr, yStr);

if strcmp(ytext,mdl.formula_string)
    pos = [1, 1.07]; horz = 'right'; str = mdl.formula_pvs; fontSize = 0.03;
    addText(pos, horz, str, fontSize);
end

pos = [0.9, 1.02]; horz = 'right'; str = ['std of raw data = ' sprintf('%6.4g',std(ydata))];
addText(pos, horz, str);

pos = [0.1, 1.02]; horz = 'left'; str = ytext;
addText(pos, horz, str);

pos = [1.0, -0.07]; horz = 'right'; str = mdl.t_stamp;
addText(pos, horz, str);

end

function Hist(mdl,ydata,ytext)
% Plot histogram of ydata

std_y=sprintf('%5.3g',std(ydata));
std_mean_y = sprintf('%5.3g',std(ydata)/mean(ydata));

figure
plot_menus_BSA(mdl.app)

N = floor((length(ydata))/10);
if N < 10, N = 10; end
if N > 100, N = 100; end
h = histogram(ydata, N);
counts = h.Values;
barnum = h.BinEdges(2:end) + diff(h.BinEdges)/2;
[yfit,p,dp,chisq] = gauss_fit(barnum, counts);
%yyf = p(1)*ones(size(barnum)) + p(2)*sqrt(2*pi)*p(4)*gauss(barnum,p(3),p(4));
histogram(ydata, N);
set(gca,'FontUnits','normalized',...
    'FontSize', 0.035);
hold on;
axis;
plot(barnum,yfit,'b');
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r','EdgeColor','w')
set(gca,'FontUnits','normalized',...
    'FontSize', 0.035);

if strcmp(ytext,mdl.formula_string)
    pos = [1.0, 1.07]; horz = 'right'; str = mdl.formula_pvs; fontSize = 0.03;
    addText(pos, horz, str, fontSize);
end

pos = [0.6, 1.03]; horz = 'center'; str = 'A + B*exp( -(X-C)^2/2*D^2 )';
addText(pos, horz, str);

pos = [0.1, 1.02]; horz = 'left'; str = ytext;
addText(pos, horz, str);

pos = [1.0, -0.07]; horz = 'right'; str = mdl.t_stamp;
addText(pos, horz, str);

pos = [-0.1, -0.07]; horz = 'left'; str = ['std = ' std_y];
addText(pos, horz, str);

pos = [-0.1, -0.11]; horz = 'left'; str = ['std/mean = ' std_mean_y];
addText(pos, horz, str);

pos = [0.02, 0.95]; horz = 'left'; str = sprintf('A = %7.3g +- %7.3g',p(1),dp(1));
addText(pos, horz, str);

pos = [0.02, 0.91]; horz = 'left'; str = sprintf('B = %7.3g +- %7.3g',p(2),dp(2));
addText(pos, horz, str);

pos = [0.02, 0.87]; horz = 'left'; str = sprintf('C = %7.3g +- %7.3g',p(3),dp(3));
addText(pos, horz, str);

pos = [0.02, 0.83]; horz = 'left'; str = sprintf('D = %7.3g +- %7.3g',p(4),dp(4));
addText(pos, horz, str);

pos = [0.02, 0.79]; horz = 'left'; str = sprintf('CHISQ/NDF = %8.3g',chisq);
addText(pos, horz, str);

end




function AllZ(mdl,ydata,ytext)
% Calculate correlations between PVA and selected BSA devices,
% calculate model data, create plots representing both

disp('All Z vs A button pressed...');

% If BR eDef, check if dual energy mode. If so, send to
% dual_energy_AllZ, otherwise, collect device indices for only
% the active beamline
if mdl.isBR
    sxr_br = mdl.SXRBR;
    hxr_br = mdl.HXRBR;
    [hxr_idx, sxr_idx, ~] = splitNames(mdl);
    idxB = false(length(mdl.ROOT_NAME),1);
    idxB(mdl.idxB) = true;
    if sxr_br == 0
        idxB = idxB & hxr_idx;
        xdata = mdl.the_matrix(idxB,:);
        %use_idx = hxr_idx;
        %xtext = mdl.ROOT_NAME(idxB);
        %other_idx = idxB & neither_idx;
        %other_data = mdl.the_matrix(other_idx,:);
        %other_text = mdl.ROOT_NAME(other_idx);
    elseif hxr_br == 0
        idxB = idxB & sxr_idx;
        %use_idx = sxr_idx;
        xdata = mdl.the_matrix(idxB,:);
        %xtext = mdl.ROOT_NAME(idxB);
        %other_idx = idxB & neither_idx;
        %other_data = mdl.the_matrix(other_idx,:);
        %other_text = mdl.ROOT_NAME(other_idx);
    else
        dual_energy_AllZvsA(mdl, ydata, ytext)
        return
    end
else
    idxB = mdl.idxB;
    xdata = mdl.the_matrix(idxB,:);
    %use_idx = 1:size(mdl.the_matrix,1);
    %xtext = mdl.ROOT_NAME(mdl.idxB);
end

% Find Z positions
[N,~] = size(xdata);
myStr = mdl.searchStringB;
z_found = mdl.z_positions(mdl.idxB);
if length(z_found) ~= N
    z_found = 1:N;
end

% Calculate correlation coefficients
corf=zeros(1,N);
for j=1:N
    [corf(j)] = corcoef(ydata,xdata(j,:));
end

if isempty(myStr)
    xStr = sprintf('All BSA units');
    tStr = sprintf('correlation with all BSA units');
else
    xStr = sprintf('Z position of all units containing "%s"',myStr);
    tStr = sprintf('correlation with all units containing "%s"',myStr);
end

if isempty(mdl.z_options) || mdl.z_options.AllBSA
    figure; %Figure 1, plot correlation between selected PV and all or selected BSA units
    plot_menus_BSA(mdl.app)
    plot(z_found,corf,'-')
    hold on
    p=plot(z_found, corf, '*');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=mdl.ROOT_NAME(mdl.idxB);
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='Corr: ';
    A = axis;
    axis([0 A(2) A(3) A(4)]);
    yStr = ['correlation with ', ytext];
    plotInit(xStr, yStr);
    
    if strcmp(ytext,mdl.formula_string)
        pos = [1, 1.07]; horz = 'right'; str = mdl.formula_pvs; fontSize = 0.03;
        addText(pos, horz, str, fontSize);
    end
    
    pos = [0.1, 1.02]; horz = 'left'; str = ytext;
    addText(pos, horz, str);
    
    pos = [1.0, -0.07]; horz = 'right'; str = mdl.t_stamp;
    addText(pos, horz, str);

    pos = [0.4, 1.02]; horz = 'left'; str = tStr;
    addText(pos, horz, str);
end


% Correlation for dispersive bpms
etax_corf = zeros(1, length(mdl.bpms.etax_id));
for j=1:length(mdl.bpms.etax_id)
    [etax_corf(j)] = corcoef(ydata,mdl.the_matrix(mdl.bpms.etax_id(j),:));
end

etay_corf = zeros(1, length(mdl.bpms.etay_id));
for j=1:length(mdl.bpms.etay_id)
    [etay_corf(j)] = corcoef(ydata,mdl.the_matrix(mdl.bpms.etay_id(j),:));
end

% Calculate model data for each line
if (~isfield(mdl.bpms,'betax'))||(mdl.z_options.NewModel==1)
    
    mdl.bpms.name = strrep(mdl.bpms.x, ':X', '');
    if mdl.isSxr, beamPath = [mdl.linac '_SXRI']; else, beamPath = [mdl.linac '_HXRI']; end
    bpms_names = [{beamPath}; mdl.bpms.name];
    %bpms_names = [{strcat(beamPath,'I')}; app.bpms.name];
    model_init('source','MATLAB'); % yeah I did. --TJM
    [~, zPos, ~, twiss, energy] = model_rMatGet(bpms_names,[],{['BEAMPATH=' beamPath]});
    %rMat = rMat(:,:,2:size(rMat,3));
    zPos = zPos(2:length(zPos));
    %lEff = lEff(2:length(lEff));
    twiss = twiss(:,2:size(twiss,2));
    energy = energy(2:length(energy));
    betax_bpm = twiss(3,:);
    betay_bpm = twiss(8,:);
    etax_bpm  = twiss(5,:);
    etay_bpm  = twiss(10,:);
    
    mdl.bpms.betax = betax_bpm;
    mdl.bpms.betay = betay_bpm;
    mdl.bpms.etax = etax_bpm;
    mdl.bpms.etay = etay_bpm;
    mdl.bpms.energy = energy;
    mdl.bpms.z = zPos;
end

% Identify data from LTU dispersive BPMS, 250/450 for HXR,
% 235/370 for SXR

numetax = length(mdl.bpms.etax_id); % location of correct bpms different for SXR/HXR


if mdl.isHxr
    bpmLTU1_name = 'BPMS:LTUH:250:X';
    bpmLTU2_name = 'BPMS:LTUH:450:X';
else
    bpmLTU1_name = 'BPMS:LTUS:235:X';
    bpmLTU2_name = 'BPMS:LTUS:370:X';
end

bpmLTU1x = mdl.the_matrix(mdl.bpms.etax_id(strcmp(mdl.bpms.etax_names, bpmLTU1_name)),:);
bpmLTU2x = mdl.the_matrix(mdl.bpms.etax_id(strcmp(mdl.bpms.etax_names, bpmLTU2_name)),:);

useX = ~isnan(bpmLTU1x) & ~isnan(bpmLTU2x);


% For each BPM, calculate the correlation with the given PV,
% the rms motion, the correlation with the first LTU dispersive
% bpm, and the linear fit with the each LTU dispersive BPM
lx = length(mdl.bpms.x_id);
[x_bpm_corf, x_bpm_rms, etaxcorf, parxLTU1, parxLTU2] = deal(zeros(1,lx));
for j=1:lx
    useY = ~isnan(mdl.the_matrix(mdl.bpms.x_id(j),:));
    use = useX & useY;
    try
        [x_bpm_corf(j)] = corcoef(ydata,mdl.the_matrix(mdl.bpms.x_id(j),:));
        [x_bpm_rms(j)] = util_stdNan(mdl.the_matrix(mdl.bpms.x_id(j),:));
        [etaxcorf(j)] = corcoef(bpmLTU1x,mdl.the_matrix(mdl.bpms.x_id(j),:));
        a = util_polyFit(bpmLTU1x(use),mdl.the_matrix(mdl.bpms.x_id(j),use),1);
        [a]=a(1,:);
        if a > 2, a = 2; end
        if a < -2, a = -2; end
        b = util_polyFit(bpmLTU2x(use),mdl.the_matrix(mdl.bpms.x_id(j),use),1);
        [b]=b(1,:);
        if b > 2, b = 2; end
        if b < -2, b = -2; end
        [parxLTU1(j)] = a;
        [parxLTU2(j)] = b;
    catch
        x_bpm_corf(j) = NaN;
        x_bpm_rms(j) = NaN;
        etaxcorf(j) = NaN;
        parxLTU1(j) = NaN;
        parxLTU2(j) = NaN;
    end
end

ly = length(mdl.bpms.y_id);
[y_bpm_corf, y_bpm_rms, etaycorf, paryLTU1, paryLTU2] = deal(zeros(1,ly));
for j=1:ly
    useY = ~isnan(mdl.the_matrix(mdl.bpms.y_id(j),:));
    use = useX & useY;
    try
        [y_bpm_corf(j)] = corcoef(ydata,mdl.the_matrix(mdl.bpms.y_id(j),:));
        [y_bpm_rms(j)] = util_stdNan(mdl.the_matrix(mdl.bpms.y_id(j),:));
        [etaycorf(j)] = corcoef(bpmLTU1x,mdl.the_matrix(mdl.bpms.y_id(j),:));
        a = util_polyFit(bpmLTU1x(use),mdl.the_matrix(mdl.bpms.y_id(j),use),1);
        [a]=a(1,:);
        if a > 2, a = 2; end
        if a < -2, a = -2; end
        b = util_polyFit(bpmLTU2x(use),mdl.the_matrix(mdl.bpms.y_id(j),use),1);
        [b]=b(1,:);
        if b > 2, b = 2; end
        if b < -2, b = -2; end
        [paryLTU1(j)] = a;
        [paryLTU2(j)] = b;
    catch
        y_bpm_corf(j) = NaN;
        y_bpm_rms(j) = NaN;
        etaycorf(j) = NaN;
        paryLTU1(j) = NaN;
        paryLTU2(j) = NaN;
    end
end

% Get all z positions, then specifically for dispersive bpms
% and all bpms

% z = mdl.z_positions;
% z_etay_bpm = mdl.z_positions(mdl.bpms.etay_id) - mdl.zLCLS;
% z_etax_bpm = mdl.z_positions(mdl.bpms.etax_id) - mdl.zLCLS;
% z_y_bpm = mdl.z_positions(mdl.bpms.y_id) - mdl.zLCLS;
% z_x_bpm = mdl.z_positions(mdl.bpms.x_id) - mdl.zLCLS;



% dispersion in mm as determined by the average of (the model
% dispersion * the linear fit * 1000) at the 2 LTU dispersive
% bpms

etaxIndx1 = strcmp(mdl.bpms.x, bpmLTU1_name);
etaxIndx2 = strcmp(mdl.bpms.x, bpmLTU2_name);

mdl.bpms.x_dispersion = (1e3 * parxLTU1 * mdl.bpms.etax(etaxIndx1) + 1e3 * parxLTU2 * mdl.bpms.etax(etaxIndx2))/2 ;
mdl.bpms.y_dispersion = (1e3 * paryLTU1 * mdl.bpms.etax(etaxIndx1) + 1e3 * paryLTU2 * mdl.bpms.etax(etaxIndx2))/2 ;

% Motion with dispersion taken out

mdl.bpms.x_nodisp = mdl.bpms.x_dispersion + mdl.bpms.etax;

% Calculate sigma
% emittance at 0.5 um, then (in meters and GeV)
emit_n = 0.5e-6;
gamma = 1 + ( mdl.bpms.energy / 0.000511);
beta = ( sqrt ((gamma.*gamma) - 1))./gamma;
beta_gamma = gamma.*beta;
emit = emit_n ./ beta_gamma;
mdl.bpms.sigmax = 1e6 * sqrt(mdl.bpms.betax .* emit); % back to microns for the result
mdl.bpms.sigmay = 1e6 * sqrt(mdl.bpms.betay .* emit); % back to microns for the result

% Calculate rms_n
x_bpm_rms_n = x_bpm_rms ./ (mdl.bpms.sigmax/1e3); %adjust to mm for normalization
y_bpm_rms_n = y_bpm_rms ./ (mdl.bpms.sigmay/1e3); %adjust to mm for normalization

% For non-dispersive bpms:
x_noeta_bpm_rms = x_bpm_rms;
y_noeta_bpm_rms = y_bpm_rms;
x_noeta_bpm_rms(mdl.bpms.etax_sub_id) = [];
y_noeta_bpm_rms(mdl.bpms.etay_sub_id) = [];
%x_noeta_bpm = mdl.bpms.x;
%x_noeta_bpm(mdl.bpms.etax_sub_id) = [];
x_noeta_bpm_rms_n = x_bpm_rms_n;
x_noeta_bpm_rms_n(mdl.bpms.etax_sub_id) = [];
z_noeta_x_bpm = mdl.bpms.z;
z_noeta_x_bpm(mdl.bpms.etax_sub_id) = [];
y_noeta_bpm_rms_n = y_bpm_rms_n;
y_noeta_bpm_rms_n(mdl.bpms.etay_sub_id) = [];
z_noeta_y_bpm = mdl.bpms.z;
z_noeta_y_bpm(mdl.bpms.etay_sub_id) = [];


z_etay_bpm = mdl.bpms.z(mdl.bpms.etay_sub_id);
z_etax_bpm = mdl.bpms.z(mdl.bpms.etax_sub_id);
z_y_bpm = mdl.bpms.z;
z_x_bpm = mdl.bpms.z;



if isempty(mdl.z_options) || mdl.z_options.XBPMCorr
    %
    figure; %Figure 2, plot correlation between selected PV and X bpms
    plot_menus_BSA(mdl.app)
    plot(mdl.bpms.z, x_bpm_corf, 'b-');
    hold on
    plot(z_etax_bpm, etax_corf,'m*');
    p=plot(mdl.bpms.z, x_bpm_corf, 'b+');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=mdl.ROOT_NAME(mdl.bpms.x_id);
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='Corr: ';
    
    A = axis;
    axis([0 A(2) A(3) A(4)]);
    xStr = sprintf('X BPM Z positions');
    yStr = ['correlation with ', ytext];
    plotInit(xStr, yStr);
    
    if strcmp(ytext,mdl.formula_string)
        pos = [1, 1.07]; horz = 'right'; str = mdl.formula_pvs; fontSize = 0.03;
        addText(pos, horz, str, fontSize);
    end
    
    pos = [0.1, 1.02]; horz = 'left'; str = ytext;
    addText(pos, horz, str);
    
    pos = [1.0, -0.07]; horz = 'right'; str = mdl.t_stamp;
    addText(pos, horz, str);
    
    pos = [0.4, 1.02]; horz = 'left'; str = 'correlation with X BPM positions';
    addText(pos, horz, str);    
end

if isempty(mdl.z_options) || mdl.z_options.YBPMCorr
    figure; %Figure 3, correlation between selected PV and Y bpms
    plot_menus_BSA(mdl.app)
    plot(z_y_bpm, y_bpm_corf, 'b-');
    hold on
    plot(z_etay_bpm, etay_corf,'m*');
    p=plot(z_y_bpm, y_bpm_corf, 'b+');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=mdl.ROOT_NAME(mdl.bpms.y_id);
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='Corr: ';
    
    A = axis;
    axis([0 A(2) A(3) A(4)]);
    xStr = sprintf('Y BPM Z positions');
    yStr = ['correlation with ', ytext];
    plotInit(xStr, yStr);
    
    if strcmp(ytext,mdl.formula_string)
        pos = [1, 1.07]; horz = 'right'; str = mdl.formula_pvs; fontSize = 0.03;
        addText(pos, horz, str, fontSize);
    end
    
    pos = [0.1, 1.02]; horz = 'left'; str = ytext;
    addText(pos, horz, str);

    pos = [1.0, -0.07]; horz = 'right'; str = mdl.t_stamp;
    addText(pos, horz, str);
    
    pos = [0.4, 1.02]; horz = 'left'; str = 'correlation with Y BPM positions';
    addText(pos, horz, str);
end

% Calculate XY factor
l = length(mdl.bpms.x_id);
xy_bpm_corf = zeros(1, l);
for j=1:length(mdl.bpms.x_id)
    [xy_bpm_corf(j)] = corcoef(mdl.the_matrix(mdl.bpms.x_id(j),:),mdl.the_matrix(mdl.bpms.y_id(j),:));
end



if isempty(mdl.z_options) || mdl.z_options.XYFactor
    figure; %Figure 4, correlation between X and Y values for each BPM
    plot_menus_BSA(mdl.app)
    plot(mdl.bpms.z, xy_bpm_corf, 'b-');
    hold on
    p=plot(mdl.bpms.z, xy_bpm_corf, 'b+');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=mdl.bpms.name;
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='Corr: ';
    %    z_etax_bpm, etaxy_corf,'m*', z_etay_bpm, etayx_corf,'m*');
    A = axis;
    axis([0 A(2) A(3) A(4)]);
    xStr = sprintf('BPM Z positions');
    yStr = 'XY factor';
    plotInit(xStr, yStr);
    
    if strcmp(ytext,mdl.formula_string)
        pos = [1, 1.07]; horz = 'right'; str = mdl.formula_pvs; fontSize = 0.03;
        addText(pos, horz, str, fontSize);
    end
    
    pos = [0.1, 1.02]; horz = 'left'; str = ytext;
    addText(pos, horz, str);
    
    pos = [1.0, -0.07]; horz = 'right'; str = mdl.t_stamp;
    addText(pos, horz, str);
    
    pos = [0.4, 1.02]; horz = 'left'; str = 'XY coupling with BPM positions';
    addText(pos, horz, str);
end

if mdl.facet
    return;
end

if isempty(mdl.z_options) || mdl.z_options.Dispersion
    figure; %Figure 5, dispersion at each bpm
    plot_menus_BSA(mdl.app);
    font_size=0.08;
    subplot(2,1,1)
    %plot(app.bpms.z,app.bpms.x_dispersion,'b-',app.bpms.z,app.bpms.y_dispersion,'m-')
    p1=plot(mdl.bpms.z,mdl.bpms.x_dispersion,'b-');
    dt1=p1.DataTipTemplate;
    dt1.DataTipRows(1).Value=mdl.bpms.name;
    dt1.DataTipRows(1).Label='';
    dt1.DataTipRows(2).Label='Dispersion';
    set(gca,'FontUnits','normalized',...
        'FontSize',font_size);
    ylabel('horizontal dispersion (mm)',...
        'Units','normalized',...
        'FontUnits','normalized',...
        'FontSize',font_size);
    A = axis;
    axis([0 A(2) -50 50]);
    
    
    subplot(2,1,2)
    p2=plot(mdl.bpms.z,mdl.bpms.y_dispersion,'b-');
    dt2=p2.DataTipTemplate;
    dt2.DataTipRows(1).Value=mdl.bpms.name;
    dt2.DataTipRows(1).Label='';
    dt2.DataTipRows(2).Label='Dispersion';
    xStr = 'Z position (meters)';
    yStr = 'vertical dispersion (mm)';
    plotInit(xStr, yStr, font_size);  
    
end

if isempty(mdl.z_options) || mdl.z_options.HorzNoDispersion
    figure; %Figure 6, horizontal motion with dispersion taken out
    plot_menus_BSA(mdl.app);
    font_size=0.035;
    %subplot(2,1,1)
    p=plot(mdl.bpms.z,mdl.bpms.x_nodisp,'b-');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=mdl.bpms.name;
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='Dispersion';
    set(gca,'FontUnits','normalized',...
        'FontSize',font_size);
    ylabel('horizontal dispersion (mm)',...
        'Units','normalized',...
        'FontUnits','normalized',...
        'FontSize',font_size);
    axis;
    
end

bpm_noeta_name = mdl.bpms.name;
bpm_noetax_name = bpm_noeta_name;
bpm_noetay_name = bpm_noeta_name;
bpm_noetax_name(mdl.bpms.etax_sub_id)=[];
bpm_noetay_name(mdl.bpms.etay_sub_id)=[];

if isempty(mdl.z_options) || mdl.z_options.HorzNormRMS
    figure; %Figure 7, normalized horizontal rms motion
    plot_menus_BSA(mdl.app);
    plot(z_noeta_x_bpm,x_noeta_bpm_rms_n,'b-')
    hold on
    p=plot(z_noeta_x_bpm,x_noeta_bpm_rms_n,'b+');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=bpm_noetax_name;
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='RMS Motion';
    xStr = 'Z position (meters)';
    yStr = 'normalized horizontal rms motion (sigma) ';
    plotInit(xStr, yStr);
    
end

if isempty(mdl.z_options) || mdl.z_options.VertNormRMS
    figure; %Figure 8, normalized vertical rms motion
    plot_menus_BSA(mdl.app);
    plot(z_noeta_y_bpm,y_noeta_bpm_rms_n,'b-')
    hold on
    p=plot(z_noeta_y_bpm,y_noeta_bpm_rms_n,'b+');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=bpm_noetay_name;
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='RMS Motion';
    xStr = 'Z position (meters)';
    yStr = 'normalized vertical rms motion (sigma) ';
    plotInit(xStr, yStr);
    
    
end

if isempty(mdl.z_options) || mdl.z_options.HorzRMS
    figure; %Figure 9, horizontal rms motion
    plot_menus_BSA(mdl.app);
    plot(z_noeta_x_bpm,x_noeta_bpm_rms,'b-')
    hold on
    p = plot(z_noeta_x_bpm,x_noeta_bpm_rms,'b+');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=bpm_noetax_name;
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='RMS Motion';
    xStr = 'Z position (meters)';
    yStr = 'horizontal rms motion (mm) ';
    plotInit(xStr, yStr);

    
end

if isempty(mdl.z_options) || mdl.z_options.VertRMS
    figure; %Figure 10, vertical rms motion
    plot_menus_BSA(mdl.app);
    plot(z_noeta_y_bpm,y_noeta_bpm_rms,'b-')
    hold on
    p=plot(z_noeta_y_bpm,y_noeta_bpm_rms,'b+');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=bpm_noetay_name;
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='RMS Motion';
    xStr = 'Z position (meters)';
    yStr = 'vertical rms motion (mm) ';
    plotInit(xStr, yStr);    
end

if isempty(mdl.z_options) || mdl.z_options.ModelBeamSigma
    figure; %Figure 11, model beam sigma
    plot_menus_BSA(mdl.app);
    plot(z_x_bpm,mdl.bpms.sigmax,'g-')
    hold on
    plot(mdl.bpms.z,mdl.bpms.sigmay,'b-')
    p1=plot(z_x_bpm,mdl.bpms.sigmax,'g+');
    p2=plot(mdl.bpms.z,mdl.bpms.sigmay,'b+');
    dt1=p1.DataTipTemplate;
    dt1.DataTipRows(1).Value=mdl.ROOT_NAME(mdl.bpms.x_id);
    dt1.DataTipRows(1).Label='';
    dt1.DataTipRows(2).Label='Sigma';
    dt2=p2.DataTipTemplate;
    dt2.DataTipRows(1).Value=mdl.ROOT_NAME(mdl.bpms.y_id);
    dt2.DataTipRows(1).Label='';
    dt2.DataTipRows(2).Label='Sigma';
    xStr = 'Z position (meters)';
    yStr = 'model beam sigma (in microns)';
    plotInit(xStr, yStr);

    pos = [0.01, 1.02]; horz = 'left'; str = 'Model beam size at BSA BPMs from beta not dispersion, x=green y=blue';
    addText(pos, horz, str);
end

if isempty(mdl.z_options) || mdl.z_options.ModelBeamEnergy
    figure; %Figure 12, model beam energy
    plot_menus_BSA(mdl.app);
    plot(z_x_bpm,mdl.bpms.energy,'b-')
    p=plot(z_x_bpm,mdl.bpms.energy,'b+');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=mdl.ROOT_NAME(mdl.bpms.x_id);
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='Energy';
    xStr = 'Z position (meters)';
    yStr = 'model beam energy ';
    plotInit(xStr, yStr);
end

disp('All Z vs A button done...');
end

function dual_energy_AllZvsA(mdl, xdata, ytext)
% Same as ALLZ function, but evaluates information for HXR and
% SXR separately

% Find indices of SXR data and HXR data respectively
[hxr_pulse_idx, sxr_pulse_idx] = splitPulses(mdl);

%indx1 = find(startsWith(app.ROOT_NAME,app.PVA));
xdataHXR = xdata(hxr_pulse_idx);
xdataSXR = xdata(sxr_pulse_idx);
xdataALL = xdata;
myStr = mdl.searchStringB;

% Find row indices of HXR and SXR devices
[hxr_idx, sxr_idx, other_idx] = splitNames(mdl);

% Filter row indices by those subset by idxB
idxB = false(length(mdl.ROOT_NAME),1);
idxB(mdl.idxB) = true;
idxBH = idxB & hxr_idx;
idxBS = idxB & sxr_idx;
%idxBO = idxB & other_idx;


% find z positions for SXR and HXR devices
ydataHXR = mdl.the_matrix(idxBH,hxr_pulse_idx);
ytextHXR = mdl.ROOT_NAME(idxBH);
[N_h,~] = size(ydataHXR);
z_found_h = mdl.z_positions(idxBH);
if length(z_found_h) ~= N_h
    z_found_h = 1:N_h;
end

ydataSXR = mdl.the_matrix(idxBS,sxr_pulse_idx);
ytextSXR = mdl.ROOT_NAME(idxBS);
[N_s,~] = size(ydataSXR);
z_found_s = mdl.z_positions(idxBS);
if length(z_found_s) ~= N_s
    z_found_s = 1:N_s;
end

 ydataOTHER = mdl.the_matrix(other_idx,:);
% ytextOTHER = mdl.ROOT_NAME(other_idx);
 [N_o,l_o] = size(ydataOTHER);
% z_found_o = mdl.z_positions(idxBO);
% if length(z_found_o) ~= N_o
%     z_found_o = 1:N_o;
% end


ydata = {ydataHXR,ydataSXR,ydataOTHER};
xdata = {xdataHXR,xdataSXR,xdataALL};
%pulse_idx = {hxr_pulse_idx,sxr_pulse_idx,1:l_o};
N = {N_h, N_s, N_o};

% Get correlation coefficient for each line
corf = cell(1, 3);
for i = 1:3
    y = ydata{i};
    x = xdata{i};
    n = N{i};
    corf_i = zeros(1, n);
    for j=1:n
        [corf_i(j)] = corcoef(x,y(j,:));
    end
    corf{i} = corf_i;
end

% Separate HXR and SXR dispersive bpms
etax_id_HXR = intersect(mdl.bpms.etax_id, find(hxr_idx));
etax_id_SXR = intersect(mdl.bpms.etax_id, find(sxr_idx));
etay_id_HXR = intersect(mdl.bpms.etay_id, find(hxr_idx));
etay_id_SXR = intersect(mdl.bpms.etay_id, find(sxr_idx));

% Correlation for dispersive bpms
l = length(etax_id_HXR);
etax_corf_HXR = zeros(1, l);
for j=1:l
    [etax_corf_HXR(j)] = corcoef(xdataHXR,mdl.the_matrix(etax_id_HXR(j),hxr_pulse_idx));
end
l = length(etay_id_HXR);
etay_corf_HXR = zeros(1, l);
for j=1:l
    [etay_corf_HXR(j)] = corcoef(xdataHXR,mdl.the_matrix(etay_id_HXR(j),hxr_pulse_idx));
end
l = length(etax_id_SXR);
etax_corf_SXR = zeros(1, l);
for j=1:l
    [etax_corf_SXR(j)] = corcoef(xdataSXR,mdl.the_matrix(etax_id_SXR(j),sxr_pulse_idx));
end
l = length(etay_id_SXR);
etay_corf_SXR = zeros(1, l);
for j=1:l
    [etay_corf_SXR(j)] = corcoef(xdataSXR,mdl.the_matrix(etay_id_SXR(j),sxr_pulse_idx));
end

% Identify data from LTU dispersive BPMS, 250/450 for HXR,
% 235/370 for SXR
bpm250x = mdl.the_matrix(mdl.bpms.etax_id(4),hxr_pulse_idx);
bpm450x = mdl.the_matrix(mdl.bpms.etax_id(5),hxr_pulse_idx);

bpm235x = mdl.the_matrix(mdl.bpms.etax_id(8),sxr_pulse_idx);
bpm370x = mdl.the_matrix(mdl.bpms.etax_id(9),sxr_pulse_idx);

useX_HXR = ~isnan(bpm250x) & ~isnan(bpm450x);
useX_SXR = ~isnan(bpm235x) & ~isnan(bpm370x);

HXR_x_id = intersect(mdl.bpms.x_id,find(hxr_idx));
SXR_x_id = intersect(mdl.bpms.x_id,find(sxr_idx));

HXR_y_id = intersect(mdl.bpms.y_id,find(hxr_idx));
SXR_y_id = intersect(mdl.bpms.y_id,find(sxr_idx));

% For each BPM, calculate the correlation with the given PV,
% the rms motion, the correlation with the first LTU dispersive
% bpm, and the linear fit with the each LTU dispersive BPM
l = length(HXR_x_id);
[x_bpm_corf_HXR, x_bpm_rms_HXR, etaxcorf_HXR, parx250, parx450] = deal(zeros(1, l));
for j=1:l
    useY = ~isnan(mdl.the_matrix(HXR_x_id(j),hxr_pulse_idx));
    use = useX_HXR & useY;
    try
        [x_bpm_corf_HXR(j)] = corcoef(xdataHXR,mdl.the_matrix(HXR_x_id(j),hxr_pulse_idx));
        [x_bpm_rms_HXR(j)] = util_stdNan(mdl.the_matrix(HXR_x_id(j),hxr_pulse_idx));
        [etaxcorf_HXR(j)] = corcoef(bpm250x,mdl.the_matrix(HXR_x_id(j),hxr_pulse_idx));
        a = util_polyFit(bpm250x(use),mdl.the_matrix(HXR_x_id(j),use),1);
        [a]=a(1,:);
        if a > 2, a = 2; end
        if a < -2, a = -2; end
        b = util_polyFit(bpm450x(use),mdl.the_matrix(HXR_x_id(j),use),1);
        [b]=b(1,:);
        if b > 2, b = 2; end
        if b < -2, b = -2; end
        [parx250(j)] = a;
        [parx450(j)] = b;
    catch
        x_bpm_corf_HXR(j) = NaN;
        x_bpm_rms_HXR(j) = NaN;
        etaxcorf_HXR(j) = NaN;
        parx250(j) = NaN;
        parx450(j) = NaN;
    end
end

l = length(HXR_y_id);
[y_bpm_corf_HXR, y_bpm_rms_HXR, etaycorf_HXR, pary250, pary450] = deal(zeros(1, l));
for j=1:l
    useY = ~isnan(mdl.the_matrix(HXR_y_id(j),hxr_pulse_idx));
    use = useX_HXR & useY;
    try
        [y_bpm_corf_HXR(j)] = corcoef(xdataHXR,mdl.the_matrix(HXR_y_id(j),hxr_pulse_idx));
        [y_bpm_rms_HXR(j)] = util_stdNan(mdl.the_matrix(HXR_y_id(j),hxr_pulse_idx));
        [etaycorf_HXR(j)] = corcoef(bpm250x,mdl.the_matrix(HXR_y_id(j),hxr_pulse_idx));
        a = util_polyFit(bpm250x(use),mdl.the_matrix(HXR_y_id(j),use),1);
        [a]=a(1,:);
        if a > 2, a = 2; end
        if a < -2, a = -2; end
        b = util_polyFit(bpm450x(use),mdl.the_matrix(HXR_y_id(j),use),1);
        [b]=b(1,:);
        if b > 2, b = 2; end
        if b < -2, b = -2; end
        [pary250(j)] = a;
        [pary450(j)] = b;
    catch
        y_bpm_corf_HXR(j) = NaN;
        y_bpm_rms_HXR(j) = NaN;
        etaycorf_HXR(j) = NaN;
        pary250(j) = NaN;
        pary450(j) = NaN;
    end
end

l = length(SXR_x_id);
[x_bpm_corf_SXR, x_bpm_rms_SXR, etaxcorf_SXR, parx235, parx370] = deal(zeros(1, l));
for j=1:l
    useY = ~isnan(mdl.the_matrix(SXR_x_id(j),sxr_pulse_idx));
    use = useX_SXR & useY;
    try
        [x_bpm_corf_SXR(j)] = corcoef(xdataSXR,mdl.the_matrix(SXR_x_id(j),sxr_pulse_idx));
        [x_bpm_rms_SXR(j)] = util_stdNan(mdl.the_matrix(SXR_x_id(j),sxr_pulse_idx));
        [etaxcorf_SXR(j)] = corcoef(bpm235x,mdl.the_matrix(SXR_x_id(j),sxr_pulse_idx));
        a = util_polyFit(bpm235x(use),mdl.the_matrix(SXR_x_id(j),use),1);
        [a]=a(1,:);
        if a > 2, a = 2; end
        if a < -2, a = -2; end
        b = util_polyFit(bpm370x(use),mdl.the_matrix(SXR_x_id(j),use),1);
        [b]=b(1,:);
        if b > 2, b = 2; end
        if b < -2, b = -2; end
        [parx235(j)] = a;
        [parx370(j)] = b;
    catch
        x_bpm_corf_SXR(j) = NaN;
        x_bpm_rms_SXR(j) = NaN;
        etaxcorf_SXR(j) = NaN;
        parx235(j) = NaN;
        parx370(j) = NaN;
    end
end

l = length(SXR_y_id);
[y_bpm_corf_SXR, y_bpm_rms_SXR, etaycorf_SXR, pary235, pary370] = deal(zeros(1, l));
for j=1:l
    useY = ~isnan(mdl.the_matrix(SXR_y_id(j),sxr_pulse_idx));
    use = useX_SXR & useY;
    try
        [y_bpm_corf_SXR(j)] = corcoef(xdataSXR,mdl.the_matrix(SXR_y_id(j),sxr_pulse_idx));
        [y_bpm_rms_SXR(j)] = util_stdNan(mdl.the_matrix(SXR_y_id(j),sxr_pulse_idx));
        [etaycorf_SXR(j)] = corcoef(bpm235x,mdl.the_matrix(SXR_y_id(j),sxr_pulse_idx));
        a = util_polyFit(bpm235x(use),mdl.the_matrix(SXR_y_id(j),use),1);
        [a]=a(1,:);
        if a > 2, a = 2; end
        if a < -2, a = -2; end
        b = util_polyFit(bpm370x(use),mdl.the_matrix(SXR_y_id(j),use),1);
        [b]=b(1,:);
        if b > 2, b = 2; end
        if b < -2, b = -2; end
        [pary235(j)] = a;
        [pary370(j)] = b;
    catch
        y_bpm_corf_SXR(j) = NaN;
        y_bpm_rms_SXR(j) = NaN;
        etaycorf_SXR(j) = NaN;
        pary235(j) = NaN;
        pary370(j) = NaN;
    end
end

% Get all z positions, then specifically for dispersive bpms
% and all bpms

% z = mdl.z_positions;
% 
% z_etay_bpm_HXR = mdl.z_positions(etay_id_HXR) - mdl.zLCLS;
% z_etax_bpm_HXR = mdl.z_positions(etax_id_HXR) - mdl.zLCLS;
% z_y_bpm_HXR = mdl.z_positions(HXR_y_id) - mdl.zLCLS;
% z_x_bpm_HXR = mdl.z_positions(HXR_x_id) - mdl.zLCLS;
% 
% z_etay_bpm_SXR = mdl.z_positions(etay_id_SXR) - mdl.zLCLS;
% z_etax_bpm_SXR = mdl.z_positions(etax_id_SXR) - mdl.zLCLS;
% z_y_bpm_SXR = mdl.z_positions(SXR_y_id) - mdl.zLCLS;
% z_x_bpm_SXR = mdl.z_positions(SXR_x_id) - mdl.zLCLS;


% Calculate model data for each line
if (~isfield(mdl.bpms,'betax'))||(mdl.z_options.NewModel==1)
    
    mdl.HXR.name = strrep(mdl.ROOT_NAME(HXR_x_id), ':X', '');
    mdl.SXR.name = strrep(mdl.ROOT_NAME(SXR_x_id), ':X', '');
    bpms_names_HXR = [{'CU_HXRI'}; mdl.HXR.name];
    bpms_names_SXR = [{'CU_SXRI'}; mdl.SXR.name];
    [~, zPos_HXR, ~, twiss_HXR, energy_HXR] = model_rMatGet(bpms_names_HXR,[],{'BEAMPATH=CU_HXRI'});
    [~, zPos_SXR, ~, twiss_SXR, energy_SXR] = model_rMatGet(bpms_names_SXR,[],{'BEAMPATH=CU_SXRI'});
    twiss_HXR = twiss_HXR(:,2:size(twiss_HXR,2));
    twiss_SXR = twiss_SXR(:,2:size(twiss_SXR,2));
    betax_bpm_HXR = twiss_HXR(3,:);
    betax_bpm_SXR = twiss_SXR(3,:);
    betay_bpm_HXR = twiss_HXR(8,:);
    betay_bpm_SXR = twiss_SXR(8,:);
    etax_bpm_HXR  = twiss_HXR(5,:);
    etax_bpm_SXR  = twiss_SXR(5,:);
    etay_bpm_HXR  = twiss_HXR(10,:);
    etay_bpm_SXR  = twiss_SXR(10,:);
    
    
    mdl.bpms.betax = 1;
    mdl.HXR.betax = betax_bpm_HXR;
    mdl.SXR.betax = betax_bpm_SXR;
    mdl.HXR.betay = betay_bpm_HXR;
    mdl.SXR.betay = betay_bpm_SXR;
    mdl.HXR.etax = etax_bpm_HXR;
    mdl.SXR.etax = etax_bpm_SXR;
    mdl.HXR.etay = etay_bpm_HXR;
    mdl.SXR.etay = etay_bpm_SXR;
    mdl.HXR.energy = energy_HXR(2:length(energy_HXR));
    mdl.SXR.energy = energy_SXR(2:length(energy_SXR));
    mdl.HXR.z = zPos_HXR(2:length(zPos_HXR));
    mdl.SXR.z = zPos_SXR(2:length(zPos_SXR));
end

% dispersion in mm as determined by the average of (the model
% dispersion * the linear fit * 1000) at the 2 LTU dispersive
% bpms
SXR_etaxIndx1 = strcmp(mdl.SXR.name,'BPMS:LTUS:235');
SXR_etaxIndx2 = strcmp(mdl.SXR.name,'BPMS:LTUS:370');
HXR_etaxIndx1 = strcmp(mdl.HXR.name,'BPMS:LTUH:250');
HXR_etaxIndx2 = strcmp(mdl.HXR.name,'BPMS:LTUH:450');
mdl.SXR.x_dispersion = (1e3 * parx235 * mdl.SXR.etax(SXR_etaxIndx1) + 1e3 * parx370 * mdl.SXR.etax(SXR_etaxIndx2))/2 ;
mdl.SXR.y_dispersion = (1e3 * pary235 * mdl.SXR.etax(SXR_etaxIndx1) + 1e3 * pary370 * mdl.SXR.etax(SXR_etaxIndx2))/2 ;
mdl.HXR.x_dispersion = (1e3 * parx250 * mdl.HXR.etax(HXR_etaxIndx1) + 1e3 * parx450 * mdl.HXR.etax(HXR_etaxIndx2))/2 ;
mdl.HXR.y_dispersion = (1e3 * pary250 * mdl.HXR.etax(HXR_etaxIndx1) + 1e3 * pary450 * mdl.HXR.etax(HXR_etaxIndx2))/2 ;

% Motion with dispersion taken out
mdl.HXR.x_nodisp = mdl.HXR.x_dispersion + mdl.HXR.etax;
mdl.SXR.x_nodisp = mdl.SXR.x_dispersion + mdl.SXR.etax;

% Calculate sigma
% emittance at 0.5 um, then (in meters and GeV)
emit_n = 0.5e-6;
gamma_HXR = 1 + ( mdl.HXR.energy / 0.000511);
gamma_SXR = 1 + ( mdl.SXR.energy / 0.000511);
beta_HXR = ( sqrt ((gamma_HXR.*gamma_HXR) - 1))./gamma_HXR;
beta_SXR = ( sqrt ((gamma_SXR.*gamma_SXR) - 1))./gamma_SXR;
beta_gamma_HXR = gamma_HXR.*beta_HXR;
beta_gamma_SXR = gamma_SXR.*beta_SXR;
emit_HXR = emit_n ./ beta_gamma_HXR;
emit_SXR = emit_n ./ beta_gamma_SXR;
mdl.HXR.sigmax = 1e6 * sqrt(mdl.HXR.betax .* emit_HXR); % back to microns for the result
mdl.HXR.sigmay = 1e6 * sqrt(mdl.HXR.betay .* emit_HXR); % back to microns for the result
mdl.SXR.sigmax = 1e6 * sqrt(mdl.SXR.betax .* emit_SXR); % back to microns for the result
mdl.SXR.sigmay = 1e6 * sqrt(mdl.SXR.betay .* emit_SXR); % back to microns for the result

% Calculate rms_n
x_bpm_rms_n_HXR = x_bpm_rms_HXR ./ (mdl.HXR.sigmax/1e3); %adjust to mm for normalization
y_bpm_rms_n_HXR = y_bpm_rms_HXR ./ (mdl.HXR.sigmay/1e3); %adjust to mm for normalization
x_bpm_rms_n_SXR = x_bpm_rms_SXR ./ (mdl.SXR.sigmax/1e3); %adjust to mm for normalization
y_bpm_rms_n_SXR = y_bpm_rms_SXR ./ (mdl.SXR.sigmay/1e3); %adjust to mm for normalization

% For non-dispersive bpms:
etax_names_HXR = strrep(mdl.ROOT_NAME(etax_id_HXR),':X','');
etay_names_HXR = strrep(mdl.ROOT_NAME(etay_id_HXR),':Y','');
etax_names_SXR = strrep(mdl.ROOT_NAME(etax_id_SXR),':X','');
etay_names_SXR = strrep(mdl.ROOT_NAME(etay_id_SXR),':Y','');

HXR_etax_sub_id = find(contains(mdl.HXR.name,etax_names_HXR));
HXR_etay_sub_id = find(contains(mdl.HXR.name,etay_names_HXR));
SXR_etax_sub_id = find(contains(mdl.SXR.name,etax_names_SXR));
SXR_etay_sub_id = find(contains(mdl.SXR.name,etay_names_SXR));

x_noeta_bpm_rms_HXR = x_bpm_rms_HXR;
y_noeta_bpm_rms_HXR = y_bpm_rms_HXR;
x_noeta_bpm_rms_SXR = x_bpm_rms_SXR;
y_noeta_bpm_rms_SXR = y_bpm_rms_SXR;
x_noeta_bpm_rms_HXR(HXR_etax_sub_id) = [];
y_noeta_bpm_rms_HXR(HXR_etay_sub_id) = [];
x_noeta_bpm_rms_SXR(SXR_etax_sub_id) = [];
y_noeta_bpm_rms_SXR(SXR_etay_sub_id) = [];

x_noeta_bpm_rms_n_HXR = x_bpm_rms_n_HXR;
x_noeta_bpm_rms_n_HXR(HXR_etax_sub_id) = [];
x_noeta_bpm_rms_n_SXR = x_bpm_rms_n_SXR;
x_noeta_bpm_rms_n_SXR(SXR_etax_sub_id) = [];
z_noeta_x_bpm_HXR = mdl.HXR.z;
z_noeta_x_bpm_HXR(HXR_etax_sub_id) = [];
z_noeta_x_bpm_SXR = mdl.SXR.z;
z_noeta_x_bpm_SXR(SXR_etax_sub_id) = [];
y_noeta_bpm_rms_n_HXR = y_bpm_rms_n_HXR;
y_noeta_bpm_rms_n_HXR(HXR_etay_sub_id) = [];
y_noeta_bpm_rms_n_SXR = y_bpm_rms_n_SXR;
y_noeta_bpm_rms_n_SXR(SXR_etay_sub_id) = [];
z_noeta_y_bpm_HXR = mdl.HXR.z;
z_noeta_y_bpm_HXR(HXR_etay_sub_id) = [];
z_noeta_y_bpm_SXR = mdl.SXR.z;
z_noeta_y_bpm_SXR(SXR_etay_sub_id) = [];


z_etay_bpm_HXR = mdl.HXR.z(HXR_etay_sub_id);
z_etay_bpm_SXR = mdl.SXR.z(SXR_etay_sub_id);
z_etax_bpm_HXR = mdl.HXR.z(HXR_etax_sub_id);
z_etax_bpm_SXR = mdl.SXR.z(SXR_etax_sub_id);
% z_y_bpm_HXR = mdl.HXR.z;
% z_y_bpm_SXR = mdl.SXR.z;
% z_x_bpm_HXR = mdl.HXR.z;
% z_x_bpm_SXR = mdl.SXR.z;



if isempty(myStr)
    xStr = sprintf('All BSA units');
    tStr = sprintf('correlation with all BSA units');
else
    xStr = sprintf('Z position of all units containing "%s"',myStr);
    tStr = sprintf('correlation with all units containing "%s"',myStr);
end

if isempty(mdl.z_options) || mdl.z_options.AllBSA
    f = figure; %Figure 1, plot correlation between selected PV and all or selected BSA units
    pos = f.Position;
    pos(3) = pos(3) * 2;
    f.Position = pos;
    plot_menus_BSA(mdl.app)
    subplot(1,2,1);
    plot(z_found_h,corf{1},'-')
    hold on
    p=plot(z_found_h, corf{1}, '*');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=ytextHXR;
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='Corr: ';
    A = axis;
    axis([0 A(2) A(3) A(4)]);
    %title('HXR')
    yStr = ['correlation with ', ytext];
    plotInit(xStr, yStr);
    
    pos = [0.1, 1.02]; horz = 'left'; str = mdl.PVA;
    addText(pos, horz, str);
   
    pos = [1.0, -0.07]; horz = 'right'; str = mdl.t_stamp;
    addText(pos, horz, str);
    
    pos = [0.4, 1.02]; horz = 'left'; str = tStr;
    addText(pos, horz, str);
    
    pos = [0.42, 1.065]; horz = 'left'; str = 'HXR'; fontSize = 0.05;
    addText(pos, horz, str, fontSize);
    
    subplot(1,2,2);
    plot(z_found_s,corf{2},'-')
    hold on
    p=plot(z_found_s, corf{2}, '*');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=ytextSXR;
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='Corr: ';
    A = axis;
    axis([0 A(2) A(3) A(4)]);
    yStr = ['correlation with ', ytext];
    plotInit(xStr, yStr);
    
    pos = [0.1, 1.02]; horz = 'left'; str = mdl.PVA;
    addText(pos, horz, str);
   
    pos = [1.0, -0.07]; horz = 'right'; str = mdl.t_stamp;
    addText(pos, horz, str);
    
    pos = [0.4, 1.02]; horz = 'left'; str = tStr;
    addText(pos, horz, str);
    
    pos = [0.42, 1.065]; horz = 'left'; str = 'SXR'; fontSize = 0.05;
    addText(pos, horz, str, fontSize);
end

if isempty(mdl.z_options) || mdl.z_options.XBPMCorr
    f = figure; %Figure 2, plot correlation between selected PV and X bpms
    pos = f.Position;
    pos(3) = pos(3) * 2;
    f.Position = pos;
    plot_menus_BSA(mdl.app)
    subplot(1,2,1);
    plot(mdl.HXR.z, x_bpm_corf_HXR, 'b-');
    hold on
    plot(z_etax_bpm_HXR, etax_corf_HXR,'m*');
    p=plot(mdl.HXR.z, x_bpm_corf_HXR, 'b+');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=mdl.HXR.name;
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='Corr: ';
    A = axis;
    axis([0 A(2) A(3) A(4)]);
    xStr = sprintf('X BPM Z positions');
    yStr = ['correlation with ', ytext];
    plotInit(xStr, yStr);
    
    pos = [0.1, 1.02]; horz = 'left'; str = mdl.PVA;
    addText(pos, horz, str);
   
    pos = [1.0, -0.07]; horz = 'right'; str = mdl.t_stamp;
    addText(pos, horz, str);
    
    pos = [0.4, 1.02]; horz = 'left'; str = 'correlation with X BPM positions';
    addText(pos, horz, str);
    
    pos = [0.42, 1.065]; horz = 'left'; str = 'HXR'; fontSize = 0.05;
    addText(pos, horz, str, fontSize);
    
    
    subplot(1,2,2);
    plot(mdl.SXR.z, x_bpm_corf_SXR, 'b-');
    hold on
    plot(z_etax_bpm_SXR, etax_corf_SXR,'m*');
    p=plot(mdl.SXR.z, x_bpm_corf_SXR, 'b+');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=mdl.SXR.name;
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='Corr: ';
    A = axis;
    axis([0 A(2) A(3) A(4)]);
    xStr = sprintf('X BPM Z positions');
    yStr = ['correlation with ', ytext];
    plotInit(xStr, yStr);
    
    pos = [0.1, 1.02]; horz = 'left'; str = mdl.PVA;
    addText(pos, horz, str);
   
    pos = [1.0, -0.07]; horz = 'right'; str = mdl.t_stamp;
    addText(pos, horz, str);
    
    pos = [0.4, 1.02]; horz = 'left'; str = 'correlation with X BPM positions';
    addText(pos, horz, str);
    
    pos = [0.42, 1.065]; horz = 'left'; str = 'SXR'; fontSize = 0.05;
    addText(pos, horz, str, fontSize);
end

if isempty(mdl.z_options) || mdl.z_options.YBPMCorr
    f = figure; %Figure 3, correlation between selected PV and Y bpms
    pos = f.Position;
    pos(3) = pos(3) * 2;
    f.Position = pos;
    plot_menus_BSA(mdl.app)
    subplot(1,2,1);
    plot(mdl.HXR.z, y_bpm_corf_HXR, 'b-');
    hold on
    plot(z_etay_bpm_HXR, etay_corf_HXR,'m*');
    p=plot(mdl.HXR.z, y_bpm_corf_HXR, 'b+');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=mdl.HXR.name;
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='Corr: ';
    A = axis;
    axis([0 A(2) A(3) A(4)]);
    xStr = sprintf('Y BPM Z positions');
    yStr = ['correlation with ', ytext];
    plotInit(xStr, yStr);
    
    pos = [0.1, 1.02]; horz = 'left'; str = mdl.PVA;
    addText(pos, horz, str);
   
    pos = [1.0, -0.07]; horz = 'right'; str = mdl.t_stamp;
    addText(pos, horz, str);
    
    pos = [0.4, 1.02]; horz = 'left'; str = 'correlation with Y BPM positions';
    addText(pos, horz, str);
    
    pos = [0.42, 1.065]; horz = 'left'; str = 'HXR'; fontSize = 0.05;
    addText(pos, horz, str, fontSize);
    
    subplot(1,2,2);
    plot(mdl.SXR.z, y_bpm_corf_SXR, 'b-');
    hold on
    plot(z_etay_bpm_SXR, etay_corf_SXR,'m*');
    p=plot(mdl.SXR.z, y_bpm_corf_SXR, 'b+');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=mdl.SXR.name;
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='Corr: ';
    A = axis;
    axis([0 A(2) A(3) A(4)]);
    xStr = sprintf('Y BPM Z positions');
    yStr = ['correlation with ', ytext];
    plotInit(xStr, yStr);
    
    pos = [0.1, 1.02]; horz = 'left'; str = mdl.PVA;
    addText(pos, horz, str);
   
    pos = [1.0, -0.07]; horz = 'right'; str = mdl.t_stamp;
    addText(pos, horz, str);
    
    pos = [0.4, 1.02]; horz = 'left'; str = 'correlation with Y BPM positions';
    addText(pos, horz, str);
    
    pos = [0.42, 1.065]; horz = 'left'; str = 'SXR'; fontSize = 0.05;
    addText(pos, horz, str, fontSize);
end

% Calculate XY factor
l = length(HXR_x_id);
xy_bpm_corf_HXR = zeros(1, l);
for j=1:l
    [xy_bpm_corf_HXR(j)] = corcoef(mdl.the_matrix(HXR_x_id(j),hxr_pulse_idx),mdl.the_matrix(HXR_y_id(j),hxr_pulse_idx));
end

l = length(SXR_x_id);
xy_bpm_corf_SXR = zeros(1, l);
for j=1:l
    [xy_bpm_corf_SXR(j)] = corcoef(mdl.the_matrix(SXR_x_id(j),sxr_pulse_idx),mdl.the_matrix(SXR_y_id(j),sxr_pulse_idx));
end



if isempty(mdl.z_options) || mdl.z_options.XYFactor
    f = figure; %Figure 4, correlation between X and Y values for each BPM
    pos = f.Position;
    pos(3) = pos(3) * 2;
    f.Position = pos;
    plot_menus_BSA(mdl.app)
    subplot(1,2,1);
    plot_menus_BSA(mdl.app)
    plot(mdl.HXR.z, xy_bpm_corf_HXR, 'b-');
    hold on
    p=plot(mdl.HXR.z, xy_bpm_corf_HXR, 'b+');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=mdl.HXR.name;
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='Corr: ';
    %    z_etax_bpm, etaxy_corf,'m*', z_etay_bpm, etayx_corf,'m*');
    A = axis;
    axis([0 A(2) A(3) A(4)]);
    xStr = sprintf('BPM Z positions');
    yStr = 'XY factor';
    plotInit(xStr, yStr);
    
    pos = [0.1, 1.02]; horz = 'left'; str = mdl.PVA;
    addText(pos, horz, str);
    
    pos = [1.0, -0.07]; horz = 'right'; str = mdl.t_stamp;
    addText(pos, horz, str);
    
    pos = [0.4, 1.02]; horz = 'left'; str = 'XY coupling with BPM positions';
    addText(pos, horz, str);
    
    pos = [0.42, 1.065]; horz = 'left'; str = 'SXR'; fontSize = 0.05;
    addText(pos, horz, str, fontSize);
    
    subplot(1,2,2);
    plot_menus_BSA(mdl.app)
    plot(mdl.SXR.z, xy_bpm_corf_SXR, 'b-');
    hold on
    p=plot(mdl.SXR.z, xy_bpm_corf_SXR, 'b+');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=mdl.SXR.name;
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='Corr: ';
    %    z_etax_bpm, etaxy_corf,'m*', z_etay_bpm, etayx_corf,'m*');
    A = axis;
    axis([0 A(2) A(3) A(4)]);
    xStr = sprintf('BPM Z positions');
    yStr = 'XY factor';
    plotInit(xStr, yStr);
    
    pos = [0.1, 1.02]; horz = 'left'; str = mdl.PVA;
    addText(pos, horz, str);
    
    pos = [1.0, -0.07]; horz = 'right'; str = mdl.t_stamp;
    addText(pos, horz, str);
    
    pos = [0.4, 1.02]; horz = 'left'; str = 'XY coupling with BPM positions';
    addText(pos, horz, str);
    
    pos = [0.42, 1.065]; horz = 'left'; str = 'SXR'; fontSize = 0.05;
    addText(pos, horz, str, fontSize);
end




if isempty(mdl.z_options) || mdl.z_options.Dispersion
    f = figure; %Figure 5, dispersion at each bpm
    pos = f.Position;
    pos(3) = pos(3) * 2;
    f.Position = pos;
    plot_menus_BSA(mdl.app);
    font_size=0.08;
    subplot(2,2,1)
    %plot(app.bpms.z,app.bpms.x_dispersion,'b-',app.bpms.z,app.bpms.y_dispersion,'m-')
    p1=plot(mdl.HXR.z,mdl.HXR.x_dispersion,'b-');
    dt1=p1.DataTipTemplate;
    dt1.DataTipRows(1).Value=mdl.HXR.name;
    dt1.DataTipRows(1).Label='';
    dt1.DataTipRows(2).Label='Dispersion';
    set(gca,'FontUnits','normalized',...
        'FontSize',font_size);
    ylabel('horizontal dispersion (mm)',...
        'Units','normalized',...
        'FontUnits','normalized',...
        'FontSize',font_size);
    A = axis;
    axis([0 A(2) -50 50]);
    pos = [0.42, 1.065]; horz = 'left'; str = 'HXR'; fontSize = 0.05;
    addText(pos, horz, str, fontSize);
    
    subplot(2,2,3)
    p2=plot(mdl.HXR.z,mdl.HXR.y_dispersion,'b-');
    dt2=p2.DataTipTemplate;
    dt2.DataTipRows(1).Value=mdl.HXR.name;
    dt2.DataTipRows(1).Label='';
    dt2.DataTipRows(2).Label='Dispersion';
    xStr = 'Z position (meters)';
    yStr = 'vertical dispersion (mm)';
    plotInit(xStr, yStr, font_size);  
    
    axis([0 A(2) -50 50]);
    
    subplot(2,2,2)
    %plot(app.bpms.z,app.bpms.x_dispersion,'b-',app.bpms.z,app.bpms.y_dispersion,'m-')
    p1=plot(mdl.SXR.z,mdl.SXR.x_dispersion,'b-');
    dt1=p1.DataTipTemplate;
    dt1.DataTipRows(1).Value=mdl.SXR.name;
    dt1.DataTipRows(1).Label='';
    dt1.DataTipRows(2).Label='Dispersion';
    set(gca,'FontUnits','normalized',...
        'FontSize',font_size);
    ylabel('horizontal dispersion (mm)',...
        'Units','normalized',...
        'FontUnits','normalized',...
        'FontSize',font_size);
    A = axis;
    axis([0 A(2) -50 50]);
    
    pos = [0.42, 1.065]; horz = 'left'; str = 'SXR'; fontSize = 0.05;
    addText(pos, horz, str, fontSize);
    
    subplot(2,2,4)
    p2=plot(mdl.SXR.z,mdl.SXR.y_dispersion,'b-');
    dt2=p2.DataTipTemplate;
    dt2.DataTipRows(1).Value=mdl.SXR.name;
    dt2.DataTipRows(1).Label='';
    dt2.DataTipRows(2).Label='Dispersion';
    xStr = 'Z position (meters)';
    yStr = 'vertical dispersion (mm)';
    plotInit(xStr, yStr, font_size);  
    
    axis([0 A(2) -50 50]);
end

if isempty(mdl.z_options) || mdl.z_options.HorzNoDispersion
    f = figure; %Figure 6, horizontal motion with dispersion taken out
    pos = f.Position;
    pos(3) = pos(3) * 2;
    f.Position = pos;
    plot_menus_BSA(mdl.app);
    font_size=0.035;
    subplot(1,2,1)
    p=plot(mdl.HXR.z,mdl.HXR.x_nodisp,'b-');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=mdl.HXR.name;
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='Dispersion';
    set(gca,'FontUnits','normalized',...
        'FontSize',font_size);
    ylabel('horizontal dispersion (mm)',...
        'Units','normalized',...
        'FontUnits','normalized',...
        'FontSize',font_size);
    axis;
    
    pos = [0.42, 1.065]; horz = 'left'; str = 'HXR'; fontSize = 0.05;
    addText(pos, horz, str, fontSize);
    
    subplot(1,2,2)
    p=plot(mdl.SXR.z,mdl.SXR.x_nodisp,'b-');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=mdl.SXR.name;
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='Dispersion';
    set(gca,'FontUnits','normalized',...
        'FontSize',font_size);
    ylabel('horizontal dispersion (mm)',...
        'Units','normalized',...
        'FontUnits','normalized',...
        'FontSize',font_size);
    axis;
    pos = [0.42, 1.065]; horz = 'left'; str = 'SXR'; fontSize = 0.05;
    addText(pos, horz, str, fontSize);
end

bpm_noeta_name_HXR = mdl.HXR.name;
bpm_noetax_name_HXR = bpm_noeta_name_HXR;
bpm_noetay_name_HXR = bpm_noeta_name_HXR;
bpm_noetax_name_HXR(HXR_etax_sub_id)=[];
bpm_noetay_name_HXR(HXR_etay_sub_id)=[];

bpm_noeta_name_SXR = mdl.SXR.name;
bpm_noetax_name_SXR = bpm_noeta_name_SXR;
bpm_noetay_name_SXR = bpm_noeta_name_SXR;
bpm_noetax_name_SXR(SXR_etax_sub_id)=[];
bpm_noetay_name_SXR(SXR_etay_sub_id)=[];

if isempty(mdl.z_options) || mdl.z_options.HorzNormRMS
    f = figure; %Figure 7, normalized horizontal rms motion
    pos = f.Position;
    pos(3) = pos(3) * 2;
    f.Position = pos;
    plot_menus_BSA(mdl.app);
    subplot(1,2,1);
    plot(z_noeta_x_bpm_HXR,x_noeta_bpm_rms_n_HXR,'b-')
    hold on
    p=plot(z_noeta_x_bpm_HXR,x_noeta_bpm_rms_n_HXR,'b+');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=bpm_noetax_name_HXR;
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='RMS Motion';
    xStr = 'Z position (meters)';
    yStr = 'normalized horizontal rms motion (sigma) ';
    plotInit(xStr, yStr);
    
    pos = [0.42, 1.065]; horz = 'left'; str = 'HXR'; fontSize = 0.05;
    addText(pos, horz, str, fontSize);
    
    subplot(1,2,2);
    plot(z_noeta_x_bpm_SXR,x_noeta_bpm_rms_n_SXR,'b-')
    hold on
    p=plot(z_noeta_x_bpm_SXR,x_noeta_bpm_rms_n_SXR,'b+');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=bpm_noetax_name_SXR;
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='RMS Motion';
    xStr = 'Z position (meters)';
    yStr = 'normalized horizontal rms motion (sigma) ';
    plotInit(xStr, yStr);
    
    pos = [0.42, 1.065]; horz = 'left'; str = 'SXR'; fontSize = 0.05;
    addText(pos, horz, str, fontSize);
end

if isempty(mdl.z_options) || mdl.z_options.VertNormRMS
    f = figure; %Figure 8, normalized vertical rms motion
    pos = f.Position;
    pos(3) = pos(3) * 2;
    f.Position = pos;
    plot_menus_BSA(mdl.app);
    subplot(1,2,1);
    plot(z_noeta_y_bpm_HXR,y_noeta_bpm_rms_n_HXR,'b-')
    hold on
    p=plot(z_noeta_y_bpm_HXR,y_noeta_bpm_rms_n_HXR,'b+');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=bpm_noetay_name_HXR;
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='RMS Motion';
    xStr = 'Z position (meters)';
    yStr = 'normalized vertical rms motion (sigma) ';
    plotInit(xStr, yStr);
    
    pos = [0.42, 1.065]; horz = 'left'; str = 'HXR'; fontSize = 0.05;
    addText(pos, horz, str, fontSize);
    
    subplot(1,2,2);
    plot(z_noeta_y_bpm_SXR,y_noeta_bpm_rms_n_SXR,'b-')
    hold on
    p=plot(z_noeta_y_bpm_SXR,y_noeta_bpm_rms_n_SXR,'b+');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=bpm_noetay_name_SXR;
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='RMS Motion';
    xStr = 'Z position (meters)';
    yStr = 'normalized vertical rms motion (sigma) ';
    plotInit(xStr, yStr);
    
    pos = [0.42, 1.065]; horz = 'left'; str = 'SXR'; fontSize = 0.05;
    addText(pos, horz, str, fontSize);
end

if isempty(mdl.z_options) || mdl.z_options.HorzRMS
    f = figure; %Figure 9, horizontal rms motion
    pos = f.Position;
    pos(3) = pos(3) * 2;
    f.Position = pos;
    plot_menus_BSA(mdl.app);
    subplot(1,2,1);
    plot(z_noeta_x_bpm_HXR,x_noeta_bpm_rms_HXR,'b-')
    hold on
    p=plot(z_noeta_x_bpm_HXR,x_noeta_bpm_rms_HXR,'b+');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=bpm_noetax_name_HXR;
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='RMS Motion';
    xStr = 'Z position (meters)';
    yStr = 'horizontal rms motion (mm) ';
    plotInit(xStr, yStr);
    
    pos = [0.42, 1.065]; horz = 'left'; str = 'HXR'; fontSize = 0.05;
    addText(pos, horz, str, fontSize);
    
    subplot(1,2,2);
    plot(z_noeta_x_bpm_SXR,x_noeta_bpm_rms_SXR,'b-')
    hold on
    p=plot(z_noeta_x_bpm_SXR,x_noeta_bpm_rms_SXR,'b+');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=bpm_noetax_name_SXR;
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='RMS Motion';
    xStr = 'Z position (meters)';
    yStr = 'horizontal rms motion (mm) ';
    plotInit(xStr, yStr);
    
    pos = [0.42, 1.065]; horz = 'left'; str = 'SXR'; fontSize = 0.05;
    addText(pos, horz, str, fontSize);
end

if isempty(mdl.z_options) || mdl.z_options.VertRMS
    f = figure; %Figure 10, vertical rms motion
    pos = f.Position;
    pos(3) = pos(3) * 2;
    f.Position = pos;
    plot_menus_BSA(mdl.app);
    subplot(1,2,1);
    plot(z_noeta_y_bpm_HXR,y_noeta_bpm_rms_HXR,'b-')
    hold on
    p=plot(z_noeta_y_bpm_HXR,y_noeta_bpm_rms_HXR,'b+');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=bpm_noetay_name_HXR;
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='RMS Motion';
    xStr = 'Z position (meters)';
    yStr = 'vertical rms motion (mm) ';
    plotInit(xStr, yStr);
    
    pos = [0.42, 1.065]; horz = 'left'; str = 'HXR'; fontSize = 0.05;
    addText(pos, horz, str, fontSize);
    
    subplot(1,2,2);
    plot(z_noeta_y_bpm_SXR,y_noeta_bpm_rms_SXR,'b-')
    hold on
    p=plot(z_noeta_y_bpm_SXR,y_noeta_bpm_rms_SXR,'b+');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=bpm_noetay_name_SXR;
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='RMS Motion';
    xStr = 'Z position (meters)';
    yStr = 'vertical rms motion (mm) ';
    plotInit(xStr, yStr);
    
    pos = [0.42, 1.065]; horz = 'left'; str = 'XR'; fontSize = 0.05;
    addText(pos, horz, str, fontSize);
end

if isempty(mdl.z_options) || mdl.z_options.ModelBeamSigma
    f = figure; %Figure 11, model beam sigma
    pos = f.Position;
    pos(3) = pos(3) * 2;
    f.Position = pos;
    plot_menus_BSA(mdl.app);
    subplot(1,2,1);
    plot(mdl.HXR.z,mdl.HXR.sigmax,'g-')
    hold on
    plot(mdl.HXR.z,mdl.HXR.sigmay,'b-')
    p1=plot(mdl.HXR.z,mdl.HXR.sigmax,'g+');
    p2=plot(mdl.HXR.z,mdl.HXR.sigmay,'b+');
    dt1=p1.DataTipTemplate;
    dt1.DataTipRows(1).Value=mdl.HXR.name;
    dt1.DataTipRows(1).Label='';
    dt1.DataTipRows(2).Label='Sigma';
    dt2=p2.DataTipTemplate;
    dt2.DataTipRows(1).Value=mdl.HXR.name;
    dt2.DataTipRows(1).Label='';
    dt2.DataTipRows(2).Label='Sigma';
    xStr = 'Z position (meters)';
    yStr = 'model beam sigma (in microns)';
    plotInit(xStr, yStr);
    
    pos = [0.01, 1.02]; horz = 'left'; str = 'Model beam size at BSA BPMs from beta not dispersion, x=green y=blue';
    addText(pos, horz, str);

    pos = [0.42, 1.065]; horz = 'left'; str = 'HXR'; fontSize = 0.05;
    addText(pos, horz, str, fontSize);

    subplot(1,2,2);
    plot(mdl.SXR.z,mdl.SXR.sigmax,'g-')
    hold on
    plot(mdl.SXR.z,mdl.SXR.sigmay,'b-')
    p1=plot(mdl.SXR.z,mdl.SXR.sigmax,'g+');
    p2=plot(mdl.SXR.z,mdl.SXR.sigmay,'b+');
    dt1=p1.DataTipTemplate;
    dt1.DataTipRows(1).Value=mdl.SXR.name;
    dt1.DataTipRows(1).Label='';
    dt1.DataTipRows(2).Label='Sigma';
    dt2=p2.DataTipTemplate;
    dt2.DataTipRows(1).Value=mdl.SXR.name;
    dt2.DataTipRows(1).Label='';
    dt2.DataTipRows(2).Label='Sigma';
    xStr = 'Z position (meters)';
    yStr = 'model beam sigma (in microns)';
    plotInit(xStr, yStr);
    
    pos = [0.01, 1.02]; horz = 'left'; str = 'Model beam size at BSA BPMs from beta not dispersion, x=green y=blue';
    addText(pos, horz, str);

    pos = [0.42, 1.065]; horz = 'left'; str = 'SXR'; fontSize = 0.05;
    addText(pos, horz, str, fontSize);

end

if isempty(mdl.z_options) || mdl.z_options.ModelBeamEnergy
    figure; %Figure 12, model beam energy
    plot_menus_BSA(mdl.app);
    plot(mdl.HXR.z,mdl.HXR.energy,'b-')
    hold on
    p=plot(mdl.HXR.z,mdl.HXR.energy,'b+');
    dt=p.DataTipTemplate;
    dt.DataTipRows(1).Value=mdl.HXR.name;
    dt.DataTipRows(1).Label='';
    dt.DataTipRows(2).Label='Energy';
    plot(mdl.SXR.z,mdl.SXR.energy,'r-')
    p2=plot(mdl.SXR.z,mdl.SXR.energy,'r+');
    dt2=p2.DataTipTemplate;
    dt2.DataTipRows(1).Value=mdl.SXR.name;
    dt2.DataTipRows(1).Label='';
    dt2.DataTipRows(2).Label='Energy';
    xStr = 'Z position (meters)';
    yStr = 'model beam energy ';
    plotInit(xStr, yStr);
end

disp('All Z vs A button done...');
end

function ZPSD(mdl)
% Calculate PSD in user specified range for all available devices
disp('All Z PSD button pressed...');

if isempty(mdl.bpms)
    % This should probably never occur??
    mdl.bpms = setupBPMS(mdl);
end

psd_start = mdl.PSDstart;
psd_end = mdl.PSDend;

pid_idx = startsWith(mdl.ROOT_NAME,'PATT:SYS0:1:PULSEID');
xdata = mdl.the_matrix(pid_idx,:);

% If BR pull out only the devices corresponding to th active
% beamline. If dual_energy, only pull out devices shared by
% both beamlines (aka only linac devices)
if mdl.isBR
    sxr_br = mdl.SXRBR;
    hxr_br = mdl.HXRBR;
    [hxr_idx, sxr_idx, ~] = splitNames(mdl);
    idxB = false(length(mdl.ROOT_NAME),1);
    idxB(mdl.idxB) = true;
    if sxr_br == 0
        idxB = idxB & hxr_idx;
        ydata = mdl.the_matrix(idxB,:);
        %ytext = app.ROOT_NAME(idxB);
        bpms_x_id = mdl.bpms.x_id & hxr_idx;
        bpms_y_id = mdl.bpms.y_id & hxr_idx;
    elseif hxr_br == 0
        idxB = idxB & sxr_idx;
        ydata = mdl.the_matrix(idxB,:);
        %ytext = app.ROOT_NAME(idxB);
        bpms_x_id = mdl.bpms.x_id & sxr_idx;
        bpms_y_id = mdl.bpms.y_id & sxr_idx;
    else
        mdl.status = 'Calculating PSD only for LINAC';
        notify(mdl, 'StatusChanged');
        disp('Calculating PSD only for LINAC');
        idxB = idxB & sxr_idx & hxr_idx;
        ydata = mdl.the_matrix(idxB,:);
        %ytext = app.ROOT_NAME(idxB);
        bpms_x_id = false(length(mdl.ROOT_NAME),1);
        bpms_y_id = false(length(mdl.ROOT_NAME),1);
        bpms_x_id(mdl.bpms.x_id) = 1;
        bpms_y_id(mdl.bpms.y_id) = 1;
        bpms_x_id = find(bpms_x_id & hxr_idx & sxr_idx);
        bpms_y_id = find(bpms_y_id & hxr_idx & sxr_idx);
    end
else
    idxB = mdl.idxB;
    ydata = mdl.the_matrix(idxB,:);
    %ytext = app.ROOT_NAME(idxB);
    bpms_x_id = mdl.bpms.x_id;
    bpms_y_id = mdl.bpms.y_id;
end

%myStr = app.SearchPVB.Value;
[N,~] = size(ydata);

z_found = mdl.z_positions(idxB);
if length(z_found) ~= N
    z_found = 1:N;
end

switch mdl.linac
    case 'CU'
        indx2 = startsWith(mdl.ROOT_NAME,sprintf('PATT:SYS0:1:PULSEID'));
        xdata = mdl.the_matrix(indx2,:);
        
        %Unroll PULSEID
        [~, ~, xdata] = unrollpid(xdata);
        
        seconds = xdata / 360;
    case 'SC'
        idx_lower = startsWith(mdl.ROOT_NAME, 'TPG:SYS0:1:PIDL');
        idx_upper = startsWith(mdl.ROOT_NAME, 'TPG:SYS0:1:PIDU');
        lwr = mdl.the_matrix(idx_lower,:);
        upr = mdl.the_matrix(idx_upper,:);
        xdata = bitshift(upr, 32) + lwr;
        
        xdata = xdata - xdata(1);
        seconds = xdata / 910000;
end

% test for rate change
dt = diff(seconds);
[beamrate_vector] = 1./dt;
beamrate_vector(isinf(beamrate_vector))=NaN;

secs = seconds(1:length(seconds)-1);

% Plot beamrate
figure
plot_menus_BSA(mdl.app)
plot(secs,beamrate_vector,'.-')
ylabel('Beamrate',...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',0.040);

% Identify beamrate discontinuities
max_rate = max(beamrate_vector);
diff_xdata = (diff(xdata));
diff_xdata = diff_xdata - diff_xdata(1);
diff_xdata_sum = sum(abs(diff_xdata));

if diff_xdata_sum~=0
    %%RESOLVE THIS HOOPLAH
    disp('rate varied during data!   Taking largest block of highest rate')
    disp(' this is still... under construction!')
    
    dx = diff(xdata);
    ddx = (diff(dx));
    id_pblm = find(ddx~=0);
    
    % plot discontinuities
    figure
    plot_menus_BSA(mdl.app)
    datalen = (1:length(ddx));
    plot(datalen,ddx,'.-',datalen(id_pblm),ddx(id_pblm),'s')
    ylabel('Beamrate Derivative Discontinuities',...
        'Units','normalized',...
        'FontUnits','normalized',...
        'FontSize',0.040);
    
    % identify largest block with continuous beamrate
    [block_boundaries] = [1 id_pblm length(xdata)];
    blocks = diff(block_boundaries);
    [~,iblock] = sort(blocks,'descend');
    select = 0;
    for jj = 1:length(blocks)
        if ((round(beamrate_vector(block_boundaries(iblock(jj))+1)) >= round(max_rate)) && select==0)
            select = 1;
            block_index = [block_boundaries(iblock(jj)) block_boundaries(iblock(jj)+1)];
            disp('getting indices of highest beamrate data block to be used')
            [ydata] = ydata(:,block_index(1)+2:block_index(2)-2);
            % plot unrolled pulse id for largest continous
            % block
            figure
            plot_menus_BSA(mdl.app)
            plot(seconds(block_index(1)+2:block_index(2)-2),xdata(block_index(1)+2:block_index(2)-2),'.-')
            xStr = 'TIME [s]';
            yStr = 'data selected for use';
            plotInit(xStr, yStr);
            
            pos = [0.1, 1.02]; horz = 'left'; str = mdl.currentVar;
            addText(pos, horz, str);

            pos = [1.0, -0.07]; horz = 'right'; str = mdl.t_stamp;
            addText(pos, horz, str);
        end
    end
end

beamrate = max_rate;
% Calculate PSD for each selected device. Be cautious of NaNs
p_norm = zeros(1, N);
for jj=1:N
    y = full(ydata(jj,:));
    nans = isnan(y);
    if sum(nans) == length(y)
        p_norm(jj) = 0;
        m_psd(jj,:) = zeros(1,floor(length(y)/2));
        continue
    end
    y(nans) = 0;
    [ p ] = psdint(y',beamrate, length(y'),'s',0,0);
    p_norm(jj) = sum(p(2:length(p),2));
    m_psd(jj,:) = p(2:length(p),2);
end

freq   = p(2:length(p),1);

indx_z = find(z_found>0);
z_indxd = z_found(indx_z);

p_norm_factor = p_norm(indx_z);

% pull out the frequency range requested by user
indx_slice = find(freq >= psd_start & freq <= psd_end);
%freq_slice = freq(indx_slice);
psd_slice = m_psd(indx_z,indx_slice);

% Calculate integrated PSD
psd_slice_sum = ( sum( psd_slice,2 ) ) ./ ( p_norm_factor' );

% Plot integrated PSD for each device along Z
figure;
plot_menus_BSA(mdl.app)
p=plot(z_indxd, psd_slice_sum, '-');
dt=p.DataTipTemplate;
dt.DataTipRows(1).Value=mdl.ROOT_NAME(indx_z);
dt.DataTipRows(1).Label='';
dt.DataTipRows(2).Label='';
xStr = 'Z Position (m)';
yStr = 'Integrated Normalized PSD';
plotInit(xStr, yStr);

pos = [0.85, 1.02]; horz = 'right';
str = sprintf('Power from %5.1f Hz to %5.1f Hz   All Devices which have Z', mdl.PSDstart, mdl.PSDend);
addText(pos, horz, str);

pos = [1.0, -0.07]; horz = 'right'; str = mdl.t_stamp;
addText(pos, horz, str);

% Calculate PSD for bpms
l = length(bpms_x_id);
px_norm = zeros(1, l);
for j=1:l
    y = mdl.the_matrix(bpms_x_id(j),:);
    nans = isnan(y);
    y(nans) = 0;
    [ p ] = psdint(y',beamrate,length(y),'s',0,0);
    px_norm(j) = sum(p(2:length(p),2));
    mx_psd(j,:) = p(2:length(p),2);
end

l = length(bpms_y_id);
py_norm = zeros(1, l);
for j=1:l
    y = mdl.the_matrix(bpms_x_id(j),:);
    nans = isnan(y);
    y(nans) = 0;
    [ p ] = psdint(y',beamrate, length(y),'s',0,0);
    py_norm(j) = sum(p(2:length(p),2));
    my_psd(j,:) = p(2:length(p),2);
end

% Calculate integrated PSD in frequency range
psdx_slice = mx_psd(:,indx_slice);
psdx_slice_sum = ( sum( psdx_slice,2 ) ) ./ ( px_norm' );
psdy_slice = my_psd(:,indx_slice);
psdy_slice_sum = ( sum( psdy_slice,2 ) ) ./ ( py_norm' );

z_y_bpm = mdl.z_positions(bpms_y_id);
z_x_bpm = mdl.z_positions(bpms_x_id);
etay_sub_id = mdl.bpms.etay_sub_id(mdl.bpms.etay_sub_id < length(bpms_y_id));
etax_sub_id = mdl.bpms.etax_sub_id(mdl.bpms.etax_sub_id < length(bpms_x_id));

% plot integrated PSD of y bpms
figure;
plot_menus_BSA(mdl.app)
plot(z_y_bpm, psdy_slice_sum, 'b+-');
hold on
p1=plot(z_y_bpm,psdy_slice_sum, 'b+');
dt1=p1.DataTipTemplate;
dt1.DataTipRows(1).Value=mdl.ROOT_NAME(bpms_y_id);
dt1.DataTipRows(1).Label='';
dt1.DataTipRows(2).Label='';

% No etay in linac
if ~isempty(etay_sub_id)
    p2=plot(z_y_bpm(etay_sub_id), psdy_slice_sum(etay_sub_id),'m*');
    dt2=p2.DataTipTemplate;
    dt2.DataTipRows(1).Value=mdl.ROOT_NAME(bpms_y_id(etay_sub_id));
    dt2.DataTipRows(1).Label='';
    dt2.DataTipRows(2).Label='';
end
xStr = 'Z Position (m)';
yStr = 'Integrated Normalized PSD';
plotInit(xStr, yStr);

pos = [0.85, 1.02]; horz = 'right';
str = sprintf('Power from %5.1f Hz to %5.1f Hz  All Y BPMs', mdl.PSDstart, mdl.PSDend);
addText(pos, horz, str);

pos = [1.0, -0.07]; horz = 'right'; str = mdl.t_stamp;
addText(pos, horz, str);

% plot integrated PSD of x bpms
figure;
plot_menus_BSA(mdl.app)
plot(z_x_bpm, psdx_slice_sum, 'b+-');
hold on
p1=plot(z_x_bpm,psdx_slice_sum, 'b+');
p2=plot(z_x_bpm(etax_sub_id), psdx_slice_sum(etax_sub_id),'m*');
dt1=p1.DataTipTemplate;
dt1.DataTipRows(1).Value=mdl.ROOT_NAME(bpms_x_id);
dt1.DataTipRows(1).Label='';
dt1.DataTipRows(2).Label='';
dt2=p2.DataTipTemplate;
dt2.DataTipRows(1).Value=mdl.ROOT_NAME(bpms_x_id(etax_sub_id));
dt2.DataTipRows(1).Label='';
dt2.DataTipRows(2).Label='';
xStr = 'Z Position (m)';
yStr = 'Integrated Normalized PSD';
plotInit(xStr, yStr);

pos = [0.85, 1.02]; horz = 'right';
str = sprintf('Power from %5.1f Hz to %5.1f Hz  All X BPMs', mdl.PSDstart, mdl.PSDend);
addText(pos, horz, str);

pos = [1.0, -0.07]; horz = 'right'; str = mdl.t_stamp;
addText(pos, horz, str);

mdl.status = '';
notify(mdl, 'StatusChanged');
end

function longpsd(mdl)
% Plot integrated PSD of a certain timeslot over a long period
% of time

pid_idx = find(contains(mdl.ROOT_NAME,'PATT:SYS0:1:PULSEID'));
PVAidx = contains(mdl.ROOT_NAME,mdl.PVA);
psd_matrix = [mdl.time_stamps;mdl.the_matrix(PVAidx,:);mdl.the_matrix(pididx,:)];
timediff = diff(mdl.time_stamps);

% separate data into blocks of mostly continuous beamrate
highdiffidx = [find(timediff>2),mdl.nPoints];
start_idx = 1;
targetidx = [];
for idx = 1:length(highdiffidx)
    end_idx = highdiffidx(idx);
    sizesubmat = end_idx - start_idx;
    if sizesubmat > 12000000
        nsubs = floor(sizesubmat / 12000000);
        for sub = 1:nsubs
            targetidx = [targetidx,start_idx + sub * 12000000];
        end
        targetidx = [targetidx,end_idx];
    else
        targetidx = [targetidx,end_idx];
    end
    start_idx = end_idx + 1;
end

% Separate data to submatrices based on continuity of
% beamrate and maximum submatrix size (for improved parallel
% processing)
submats = cell(1,length(targetidx));
disp('Splitting to submatrices')
for i = 1:length(targetidx)
    fprintf('%d read, %d total \n',i,length(targetidx))
    if i == 1
        start_idx = 1;
    else
        start_idx = targetidx(i - 1) + 1;
    end
    end_idx = targetidx(i);
    submat = psd_matrix(:,start_idx:end_idx);
    submats{i} = submat;
end

% Find integrated PSD of selected timeslot in 20s bins
disp('Iterating over submatrices')
if isempty(submats)
    numsubs = 1;
    submats{1} = psd_matrix;
else
    numsubs = length(submats);
end
clear psd_matrix % for memory management
bintime = cell(1,numsubs);
relative_pwr = cell(1,numsubs);
raw_pwr = cell(1,numsubs);
PSDStart = mdl.PSDstart;
PSDEnd = mdl.PSDend;
parfor j = 1:numsubs
    try
        submat = submats{j};
        submats{j} = [];
        pulseid = submat(3,:);
        ydata = submat(2,:);
        t = submat(1,:);
        splitidx = zeros(1,floor((t(length(t)) - t(1)) / 20));
        if isempty(splitidx)
            fprintf('Submat %d too small \n',j)
            continue
        end
        
        % Split into 20s bins
        ctr = 1;
        ptr = 1;
        for idx = 1:length(t)
            if t(idx) - t(ptr) > 20
                splitidx(ctr) = idx;
                ctr = ctr + 1;
                ptr = idx;
            end
        end
        t = t(1:ptr);
        pulseid = pulseid(1:length(t));
        ydata = ydata(1:length(t));
        fprintf('Finding powers in submat %d \n',j)
        timemat = zeros(1,length(splitidx));
        rawpwr = cell(1,length(splitidx));
        relpwr = zeros(1,length(splitidx));
        for k = 1:length(splitidx)
            try
                runs = length(splitidx);
                if mod(k,250) == 0
                    fprintf('On run %d of %d at time %d \n',k,runs,t(1))
                end
                end_idx = splitidx(k);
                pidslice = pulseid(1:end_idx);
                ydataslice = ydata(1:end_idx);
                [ydataslice,beamrate,~] = unrollpid(pidslice,ydataslice);
                if isempty(ydataslice)
                    disp('empty slice')
                    continue
                end
                [p] = psdint(ydataslice',beamrate,length(ydataslice),'s',0,0);
                freq = round(p(2:length(p),1),2);
                psd_mm = p(2:length(p),2);
                %             if k==3
                %                 mm_sq=freq(1)*(cumsum(psd_mm(length(psd_mm):-1:1)));
                %                 mm_squared=flipud(mm_sq);
                %                 plot(freq,mm_squared)
                %             end
                tidx = ceil((end_idx - 1) / 2);
                %thistime=datetime(submat(1,tidx),'ConvertFrom','posixtime');
                splitidx = splitidx - end_idx;
                pulseid(1:end_idx) = [];
                ydata(1:end_idx) = [];
                thistime = t(tidx);
                t(1:end_idx) = [];
                target_freq = find((freq <= PSDEnd) & (freq >= PSDStart));
                thispow = psd_mm(target_freq);
                relpow = thispow / sum(psd_mm);
                if ~isempty(target_freq)
                    timemat(k) = thistime;
                    try
                        relpwr(k) = sum(relpow);
                        rawpwr{k} = [freq(target_freq);thispow];
                    catch
                        continue
                    end
                end
                
            catch ME
                disp(ME.identifier)
                disp(ME.message)
                disp(ME.cause)
                disp(ME.stack(1))
                disp(ME.stack(2))
                
                continue
            end
            
        end
        if isempty(timemat)
            bintime{j} = [0];
            relative_pwr{j} = [0];
            raw_pwr{j} = [0];
        else
            bintime{j} = timemat;
            relative_pwr{j} = relpwr;
            raw_pwr{j} = rawpwr;
        end
    catch ME
        disp('catch 2')
        disp(ME.identifier)
        disp(ME.message)
        disp(ME.cause)
        disp(ME.stack(1))
        disp(ME.stack(2))
        continue
    end
end

t = cell2mat(bintime);
p = cell2mat(relative_pwr);
zers = find(t == 0);
t(zers) = [];
p(zers) = [];

% plot integrated PSD over each bin over time
plot_menus_BSA(mdl.app)
plot(t, p, '-', t, p, '*');
xStr = 'Time (UTC)'; 
yStr = 'PSD/Integrated PSD';
plotInit(xStr, yStr);

pos = [0.9, 1.02]; horz = 'right'; str = sprintf('std of raw data = %6.4g',std(p));
addText(pos, horz, str);

pos = [0.1, 1.02]; horz = 'left'; str = mdl.PVA;
addText(pos, horz, str);

pos = [1.0, -0.07]; horz = 'right'; str = mdl.t_stamp;
addText(pos, horz, str);
end

function jitter_pie(mdl)
disp_bpms_idx = mdl.bpms.etax_id(1:3);

notnan1 = ~isnan(mdl.the_matrix(:,10));
notnan2 = ~isnan(mdl.the_matrix(:,20));
use = max(notnan1, notnan2);

if mdl.lcls
    secn = {'DL1', 'BC1', 'BC2', 'DL2'};
    disp_bpms_idx = [disp_bpms_idx, mdl.bpms.etax_id(end)];
    r16=[2.63 2.32 3.65 1.25];

    if mdl.isSxr
        secn{4} = 'CLTS';
        r16(4) = 2.895;
    end
    
    names1 = find(endsWith(mdl.ROOT_NAME, 'ST') & use);
    names2 = find(endsWith(mdl.ROOT_NAME, 'LT') & use);
    names3part1 = endsWith(mdl.ROOT_NAME, {'A','P'});
    names3part2 = ~contains(mdl.ROOT_NAME,{':PH', 'FASTP', 'FASTA'});
    names3 = find(names3part1 & names3part2 & use);
    
    jitter_idx = [names1; names3; names2];
    pulse_idx = 1:size(the_matrix,2);
    
elseif mdl.facet
    secn = {'LO', 'L1', 'L2', 'L3'};
    disp_bpms_idx = [disp_bpms_idx, find(contains(mdl.ROOT_NAME, 'BPMS:LI20:2050:X'))];
    r16 = [2.63 2.51 4.37 1.2];
    
    names1 = find(startsWith(mdl.ROOT_NAME, 'ACCL') & use);
    names2 = find(endsWith(mdl.ROOT_NAME, ':PHAS') & use);
    names3 = find(startsWith(mdl.ROOT_NAME, 'KLYS') & ~endsWith(mdl.ROOT_NAME, ':PHAS') & use);
    
    jitter_idx = [names1; names2; names3];
    pulse_idx = mdl.hasSCP;
    
else
    return 
end

use_matrix = mdl.the_matrix(:, pulse_idx);

short_mat = use_matrix(:, 1:2:(size(use_matrix,2)-1));
ts_idx = 1:size(short_mat, 2)-1; %get points from the same timeslot
for section = 1:4
    ref_bpm = disp_bpms_idx(section);
    if section == 4
        ts_idx = short_mat(ref_bpm, ts_idx) ~= 0; 
    end
    ref_bpm_data = short_mat(ref_bpm, ts_idx);
    for idx = 1:length(ref_bpm_data)
        if isnan(ref_bpm_data(idx))
            if idx == 1
                ref_bpm_data(idx) = 0;
            else
                ref_bpm_data(idx) = ref_bpm_data(idx-1);
            end
        end
    end
    ref_bpm_data_unchanged = ref_bpm_data;
    jitter_coef = zeros([length(jitter_idx),1]);
    name = cell(10,1);
    relative_jitt = zeros(10,1);
    for num = 1:10
        for device = 1:length(jitter_idx)
            data = short_mat(jitter_idx(device), ts_idx);
            for idx = 1:length(data)
                if isnan(data(idx))
                    if idx == 1
                        data(idx) = 0;
                    else
                        data(idx) = data(idx-1);
                    end
                end
            end
            coef = corrcoef(data, ref_bpm_data);
            coef = coef(1,2);
            if isfinite(coef)
                jitter_coef(device) = coef;
            end
        end
        
        [max_jitt, max_idx] = sort(jitter_coef.^2, 'descend');
        device_data = short_mat(jitter_idx(max_idx(1)),ts_idx);
        for idx = 1:length(device_data)
            if isnan(device_data(idx))
                if idx == 1
                    device_data(idx) = 0;
                else
                    device_data(idx) = device_data(idx-1);
                end
            end
        end
        [p1,~] = plot_polyfit(device_data, ref_bpm_data,1,1,[],[],'', ' mm',1);
        ref_bpm_data = ref_bpm_data - (p1(2) * device_data);
        
        name(num) = mdl.ROOT_NAME(jitter_idx(max_idx(1)));
        relative_jitt(num) = max_jitt(1);
        if num > 1
            sum_jitt = sum(relative_jitt(1:num-1));
            relative_jitt(num) = relative_jitt(num) * (1 - sum_jitt);
        end
        
    end
    %relative_jitt_rounded = round(relative_jitt * 1000) / 10;
    stdE=round(1000 * std(ref_bpm_data_unchanged) / r16(section)) / 1000;
    f=figure;
    f.Position = f.Position * 1.5;
    pie_chart = pie(relative_jitt);
    legend(name, 'Orientation', 'Vertical', 'FontSize', 11, 'Location', 'westoutside', 'Interpreter', 'none');
    title([strcat('Sources for'," ", secn(section), ' Energy Jitter'), strcat(num2str(abs(stdE)), '%')])
    for i=1:length(name)
        set(pie_chart(2*i),'FontSize',14,'Interpreter','none')
    end
    plot_menus_BSA(mdl.app);
    text('FontSize',12,'Position', [1.4 -1.25],'HorizontalAlignment','right', 'String', datestr(mdl.t_stamp));
end
end

function corf = corcoef(xdata, ydata)
% function that calculates correlation coefficient from xdata and ydata
% returns it in 'corf', as needed for calculations in the BSA GUI

N=length(xdata);
useX = ~isnan(xdata);
useY = ~isnan(ydata);
use = useX & useY;
xdata = xdata(use);
ydata = ydata(use);
sumX = sum(xdata);
sumY = sum(ydata);
sumX_sq = sum(xdata.*xdata);
sumY_sq = sum(ydata.*ydata);
sumXY = sum(xdata.*ydata);
corf=(N*sumXY-sumX*sumY)/...
    sqrt((N*sumX_sq-sumX^2)*(N*sumY_sq-sumY^2));

end

function addText(pos, horz, str, fontSize)
if nargin < 4, fontSize = 0.035; end
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize', fontSize,...
    'Position',pos,...
    'HorizontalAlignment',horz,...
    'String', str);
end

function plotInit(xStr, yStr, fontSize)
if nargin < 3, fontSize = 0.035; end

set(gca,'FontUnits','normalized',...
    'FontSize', fontSize);
xlabel(xStr,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize', fontSize);
ylabel(yStr,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize', fontSize);

end

function ZRMS(mdl)
x_bpm_rms = util_stdNan(mdl.the_matrix(mdl.bpms.x_id,:), 1, 2);
y_bpm_rms = util_stdNan(mdl.the_matrix(mdl.bpms.y_id,:), 1, 2);
tmit_bpm_rms = util_stdNan(mdl.the_matrix(mdl.bpms.tmit_id,:), 1, 2);

tiledlayout(3,1);
nexttile
plot_menus_BSA(mdl.app);
p1 = plot(mdl.z_positions(mdl.bpms.x_id), x_bpm_rms,'b-');
dt1 = p1.DataTipTemplate;
dt1.DataTipRows(1).Value = mdl.ROOT_NAME(mdl.bpms.x_id);
dt1.DataTipRows(1).Label='';
dt1.DataTipRows(2).Label='Absolute RMS';
xStr = '';
yStr = 'Horizontal RMS';
plotInit(xStr, yStr, 0.1);

nexttile
p2 = plot(mdl.z_positions(mdl.bpms.y_id), y_bpm_rms,'b-');
dt2 = p2.DataTipTemplate;
dt2.DataTipRows(1).Value = mdl.ROOT_NAME(mdl.bpms.y_id);
dt2.DataTipRows(1).Label='';
dt2.DataTipRows(2).Label='Absolute RMS';
xStr = '';
yStr = 'Vertical RMS';
plotInit(xStr, yStr, 0.1);

nexttile
p3 = plot(mdl.z_positions(mdl.bpms.tmit_id), tmit_bpm_rms,'b-');
dt3 = p3.DataTipTemplate;
dt3.DataTipRows(1).Value = mdl.ROOT_NAME(mdl.bpms.tmit_id);
dt3.DataTipRows(1).Label='';
dt3.DataTipRows(2).Label='Absolute RMS';
xStr = 'Z position (meters)';
yStr = 'TMIT RMS';
plotInit(xStr, yStr, 0.1);

end
