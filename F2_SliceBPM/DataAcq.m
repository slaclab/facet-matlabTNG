%% Constents
z = 1993.91;   % Position to calculate values at
%eventaully want to chage this with some value that can be changed in the
%gui
nshots = 5;
acq_time = 10; %secounds
% When beam is running acq_time should be replaced with: 
%rate = lcaGet('EVNT:SYS1:1:BEAMRATE'); % Hz
%acq_time = nshots/rate;

% Locations (z positions) of BPMs
z_3156 = 1991.31;
z_3218 = 1997.77;

% sets switch variable
switch_acq = 'beam_off';



%% PVs
%pvs for Beam Position Monitors
pv_BPM_3156_x = 'BPMS:LI20:3156:X';
pv_BPM_3156_y = 'BPMS:LI20:3156:Y';
pv_BPM_3156_TMIT = 'BPMS:LI20:3156:TMIT';

pv_BPM_3218_x = 'BPMS:LI20:3218:X';
pv_BPM_3218_y = 'BPMS:LI20:3218:Y';
pv_BPM_3218_TMIT = 'BPMS:LI20:3218:TMIT';

pv_BPM_2445_x = 'BPMS:LI20:2445:X';
pv_BPM_2445_y = 'BPMS:LI20:2445:Y';
pv_BPM_2445_TMIT = 'BPMS:LI20:2445:TMIT';

%% Initialize
% Calculate transport Matrix b/w BPMs
switch switch_acq
    case 'beam_on'
        PS_Q0D = control_magnetGet("LI20:LGPS:3141"); % Don't change this during the scan
        M = calcIPTransport(PS_Q0D);
        M11 = M(1,1);
        M12 = M(1,2);
        M33 = M(3,3);
        M34 = M(3,4); 
    case 'beam_off'
        rows = 4;
        cols = 4;
        M = rand(rows,cols);
        M11 = M(1,1);
        M12 = M(1,2);
        M33 = M(3,3);
        M34 = M(3,4);
end

% Initilize empty arrays
xmean = []; xpmean = []; ymean = []; 
ypmean = []; TMITmean = []; E0_BPM_plot = [];
y_std = []; xp_std = []; 
yp_std = []; TMIT_std = []; 
x_std = [];
%% Acquisition
masks = {{'TS5'} {} {} {}};

edef = eDefReserve('BPMdisperson');
eDefParams(edef, 1, nshots, masks{:});  % third argument = -1 makes it acquire forever
lcaPut(['EDEF:SYS1:' num2str(edef) ':EXCM64'], 0); % allows edef to run with no beam

for shots = 1:nshots
    fprintf('Acquiring shots %d of %d...\n', shots, nshots);

    eDefOn(edef);    % This starts the buffer
    pause(acq_time); % This waits for some amount of time
    eDefOff(edef);   % Stop the buffer

    switch switch_acq
        case 'beam_on'
            % Read the PVS from the buffer
            BPM_3156_x = lcaGetSmart(strcat(pv_BPM_3156_x, 'HST', num2str(edef)));
            BPM_3156_y = lcaGetSmart(strcat(pv_BPM_3156_y, 'HST', num2str(edef)));
            BPM_3156_TMIT = lcaGetSmart(strcat(pv_BPM_3156_TMIT, 'HST', num2str(edef)));
        
            BPM_3218_x = lcaGetSmart(strcat(pv_BPM_3218_x, 'HST', num2str(edef)));
            BPM_3218_y = lcaGetSmart(strcat(pv_BPM_3218_y, 'HST', num2str(edef)));
            BPM_3218_TMIT = lcaGetSmart(strcat(pv_BPM_3218_TMIT, 'HST', num2str(edef)));

            BPM_2445_x = lcaGetSmart(strcat(pv_BPM_2445_x, 'HST', num2str(edef)));
            BPM_2445_y = lcaGetSmart(strcat(pv_BPM_2445_y, 'HST', num2str(edef)));
            BPM_2445_TMIT = lcaGetSmart(strcat(pv_BPM_2445_TMIT, 'HST', num2str(edef)));
        
            EPICSpid = lcaGetSmart(strcat('PATT:SYS1:1:PULSEIDHST', num2str(edef)));

            %masks for BPM non zero and not an outlier
            ix = find(BPM_3156_x~=0);
            indE = ~isoutlier(BPM_2445_x(ix));
            ind_analyse = ix(indE);

            % Energy of each pulse
            E0_BPM = 10 + 0.0834*(BPM_2445_x);
        case 'beam_off'
            % Read the PVS from the buffer
            BPM_3156_x = randn(100,1);
            BPM_3156_y = randn(100,1);
            BPM_3156_TMIT = randn(100,1);
        
            BPM_3218_x = randn(100,1);
            BPM_3218_y = randn(100,1);
            BPM_3218_TMIT = randn(100,1);

            BPM_2445_x = randn(100,1); % Random 
            %BPM_2445_x = linspace(1, 2, nshots); %increases sequentially so plot is mor realistic looking
            BPM_2445_y = randn(100,1);
            BPM_2445_TMIT = randn(100,1);
        
            EPICSpid = randn(100,1);

            %sets x axis
            E0_BPM_plot_i = shots;
    end

    %% Analysis
    ix = find(BPM_3156_x~=0);
    indE = ~isoutlier(BPM_2445_x(ix));
    ind_analyse = ix(indE);

    %Calculates Vectors
    x1 = BPM_3156_x;
    x2 = BPM_3218_x;
    xp = (x2-M11.*x1)./M12;
       
    y1 = BPM_3156_y;
    y2 = BPM_3218_y;
    yp = (y2-M33.*y1)./M34;
        
    %BPM positions array for z and x (and y) positions
    z_BPM = [z_3156, z_3218];
    x_BPM = [x1, x1 + xp * diff(z_BPM)];
    y_BPM = [y1, y1 + yp * diff(z_BPM)];
    %NOTE: did not transpose matrix (like in origional) because wrong
    %shape for interpolation
        
    % Interpolate x and y positions over the specific z range
    x = interp1(z_BPM, x_BPM(ind_analyse, :)', z);
    y = interp1(z_BPM, y_BPM(ind_analyse, :)', z);
    xp = xp(ind_analyse);
    yp = yp(ind_analyse);
        
    % Calculate mean values
    xmean_i = mean(x,"omitnan")*1000;    % um
    ymean_i = mean(y,"omitnan")*1000;   % um
    xpmean_i = mean(xp,"omitnan")*1000;  % urad
    ypmean_i = mean(yp,"omitnan")*1000;  % urad
    TMITmean_i = mean(BPM_2445_TMIT);

    % Save the scaled values for plotting
    xmean(end+1) = xmean_i;
    ymean(end+1) = ymean_i;
    xpmean(end+1) = xpmean_i;
    ypmean(end+1) = ypmean_i;
    TMITmean(end+1) = TMITmean_i;
    E0_BPM_plot(end+1) = E0_BPM_plot_i;

    %calculate std values
    x_std_i = std(x, "omitnan")*1000;
    y_std_i = std(y,"omitnan")*1000;
    xp_std_i = std(xp,"omitnan")*1000;
    yp_std_i = std(yp,"omitnan")*1000;
    TMIT_std_i = std(BPM_2445_TMIT,"omitnan")*1000;

    %Save std values in an array
    x_std(end+1) = x_std_i;
    y_std(end+1) = y_std_i;
    xp_std(end+1) = xp_std_i;
    yp_std(end+1) = yp_std_i;
    TMIT_std(end+1) = TMIT_std_i;

    %mean of all shots
    xmean_allshots = mean(xmean);
    ymean_allshots = mean(ymean);
    xpmean_allshots = mean(xpmean);
    ypmean_allshots = mean(ypmean);
    TMITmean_allshots = mean(TMITmean);

    %deviation from mean (ie, x-x0 ir y-y0)
    x_deviation = xmean - xmean_allshots;
    y_deviation = ymean - ymean_allshots;
    xp_deviation = xpmean - xpmean_allshots;
    yp_deviation = ypmean - ypmean_allshots;
    TMIT_deviation = TMITmean - TMITmean_allshots;
     
    %force matrices to have the same diemstions) 
    x_deviation = x_deviation(:);
    y_deviation = y_deviation(:);
    xp_deviation = xp_deviation(:);
    yp_deviation = yp_deviation(:);
    BPM_2445_TMIT = BPM_2445_TMIT(ind_analyse);

    %figures
    figure(1)

    %x-x0 plot
    subplot(3,2,1)
    errorbar(E0_BPM_plot, x_deviation, x_std, 'o', 'MarkerFaceColor', 'b')
    xlabel('Slice Energy [GeV]')
    ylabel('x-x_0 \mu m')
    xlim([0,(shots + 1)]) %REMOVE WITH BEAM
    
    %xp-xp0 plot
    subplot(3,2,2)
    errorbar(E0_BPM_plot, xp_deviation, xp_std, 'o', 'MarkerFaceColor', 'b')
    xlabel('Slice Energy [GeV]')
    ylabel('x'' - x_0'' \mu m')  
    xlim([0,(shots + 1)]) %REMOVE WITH BEAM

    %y-y0 plot
    subplot(3,2,3)
    errorbar(E0_BPM_plot, y_deviation, y_std, 'o', 'MarkerFaceColor', 'b')
    xlabel('Slice Energy [GeV]')
    ylabel('y-y_0 [\mu m]')
    xlim([0,(shots + 1)]) %REMOVE WITH BEAM

    %yp-yp0 plot
    subplot(3,2,4)
    errorbar(E0_BPM_plot, yp_deviation, yp_std, 'o', 'MarkerFaceColor', 'b')
    xlabel('Slice Energy [GeV]')
    ylabel('y'' - y_0'' \mu m')
    xlim([0,(shots + 1)]) %REMOVE WITH BEAM

    %BPM 2445 TMIT plot
    subplot(3,2,5)
    errorbar(E0_BPM_plot, TMIT_deviation, TMIT_std, 'o', 'MarkerFaceColor', 'b')
    xlabel('Slice Energy [GeV]')
    ylabel('Transmitted')
    xlim([0,(shots + 1)]) %REMOVE WITH BEAM


end
    
% free up edef
eDefRelease(edef);

fprintf('Done!');
%% Support functions
function M = calcIPTransport(B)

zUSBPM = 1991.31;
zDSBPM = 1997.77;
zQ0D   = 1996.98244;
L_eff = 1; % Effective quad length

d1 = zQ0D - zUSBPM - L_eff/2;
d2 = zDSBPM - zQ0D - L_eff/2;

M = M_drift(d2)*M_quad(B)*M_drift(d1);

end

function M = M_drift(d)
OO = zeros(2,2);
m = [1 d; 0 1];
M = [m OO; OO m];
end

function M = M_quad(B)
OO = zeros(2,2);
E = 10;
L_eff = 1;


if B==0
    M = M_drift(L_eff);
else
    k = 0.299792458*abs(B*0.1)/E;
    
    phi = L_eff*sqrt(k);
    m_F = [ cos(phi)           (1/sqrt(k))*sin(phi)
        -sqrt(k)*sin(phi)   cos(phi)];
    m_D = [ cosh(phi)          (1/sqrt(k))*sinh(phi)
        sqrt(k)*sinh(phi)  cosh(phi)];
    if B>0
        M = [m_F OO; OO m_D];
    else
        M = [m_D OO; OO m_F];
    end
end
end