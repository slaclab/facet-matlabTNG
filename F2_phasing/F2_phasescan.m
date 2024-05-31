% object to handle coire actions and input/output/config parameters of a phase scan
% author: Zack Buschmann <zack@slac.stanford.edu>

classdef F2_phasescan < handle
    
    properties (Constant, Hidden)
        
        % EPICS record names for each spectrometer BPM
        bpms = [ ...
            "BPMS:IN10:731" "BPMS:LI11:333" "BPMS:LI14:801" "BPMS:LI20:2445" ...
            ]
        
        % bend magnet BACT values for design energy milestones
        bend_BACT_PVs = [ ...
            "BEND:IN10:751:BACT" "BEND:LI11:331:BACT" "BEND:LI14:720:BACT" "LI20:LGPS:1990:BACT" ...
            ];

        FB_state_PV = "SIOC:SYS1:ML00:AO856";
        
        % hardcoded dispersion at each BPM
        % TO DO: grab this from the model server, once such a thing exists
        etas = 1000 * [-0.2628 -0.2511 -0.4374 0.1207];

        EPICS_t0 = datenum('Jan 1 1990 00:00:00');

        DEFAULT_DPHI = [15 20 60 60];
        DEFAULT_STEPS = [15 15 9 9];
        DEFAULT_SAMPLES = 20;

        TMIT_THRESHOLD_LO = 0.8;
        TMIT_THRESHOLD_HI = 1.1;
        
    end
    
    properties

        linac_map = NaN(20,8);
        sector_map = NaN(5);
        klys_map = NaN(8);

        linac = -1;         % linac number (1,2,3)
        sector = -1;       % sector number (10-19)
        klys = -1;          % klystron number (1-8)
        klys_str = 'ss-k'; % klystron ID string

        % klystron trigger status 1: on-beam, 2: standby, 3: offline
        klys_stat = 3;

        start_time         % scan start time
        end_time           % scan completion time
        scan_name = ''     % klystron+ymdhms scan ID
        scan_summary = ''  % text summary for logbook/stdout
        data_file = ''     % full path to output .mat file

        init_feedback_state = 0; % initial longitudinal feedback state, for restore point

        abort_requested = false;
        scan_aborted = false;
        success = false;
        
        i_scan = 0;        % phase scan step index, used to populate msmt arrays

        BPM = ''           % spectrometer BPM device name
        eta = 0.0          % dispersion at BPM (mm)
        klys_offset = 0;   % offset for klystron PDES
        sbst_offset = 0;   % offset for subbooster PDES

        dPhi = 0;
        N_steps = 0;
        N_samples = 0;
        zigzag = false;
        simulation = false;

        PVs = struct;
        beam = struct;
        in = struct;
        msmt = struct;
        out = struct;
        fit = struct;
        undo = struct;

        sim_err = 0.0;

        % flag + handles for frontend objects to be manipulated during the scan
        GUI_attached logical
        GUI_ax matlab.ui.control.UIAxes 
        GUI_axTMIT matlab.ui.control.UIAxes 
        GUI_message matlab.ui.control.Label
        GUI_abortButton matlab.ui.control.StateButton

    end

    % set methods for scan inputs
    % automatically configures some downstream parameters
    % changes to linac -> sector -> klystron will cascade
    methods

        function self = set.linac(self, l)
            assert((0 <= l) && (l <= 3), 'Invalid linac number');
            self.linac = l;

            self.BPM = self.bpms(self.linac+1);
            self.eta = self.etas(self.linac+1);

            % get linac operating point info
            % rep rate, charge in pC, milestone energy in MeV
            self.beam.f = lcaGetSmart('EVNT:SYS1:1:BEAMRATE');
            self.beam.N_elec = lcaGetSmart(sprintf('%s:TMIT1H', self.BPM));
            self.beam.Q = 1.6e-19 * self.beam.N_elec / 1e-12;
            self.beam.E_design = 1000*lcaGetSmart(self.bend_BACT_PVs(self.linac+1));
            
            self.PVs.X = sprintf('%s:%s', self.BPM, 'X');
            self.PVs.TMIT = sprintf('%s:%s', self.BPM, 'TMIT');
            self.msmt.TMIT_thr_lo = self.TMIT_THRESHOLD_LO * self.beam.N_elec;
            self.msmt.TMIT_thr_hi = self.TMIT_THRESHOLD_HI * self.beam.N_elec;

            self.dPhi = self.DEFAULT_DPHI(self.linac+1);
            self.N_steps = self.DEFAULT_STEPS(self.linac+1);
            self.N_samples = self.DEFAULT_SAMPLES;
            
            [all_s,~] = find(self.linac_map == self.linac);
            self.sector_map = [unique(all_s)];
            self.sector = self.sector_map(1);
        end

        function self = set.sector(self, s)
            errmsg = 'Invalid sector number';
            switch self.linac
                case 0,     assert(s == 10, errmsg);
                case 1,     assert(s == 11, errmsg);
                case {2,3}, assert(ismember(s, self.sector_map), errmsg);
            end
            self.sector = s;

            self.sbst_offset = 0;
            if self.linac >= 2
                self.PVs.SBST_PDES = sprintf('LI%d:SBST:1:PDES', self.sector);
                p_sbst = lcaGetSmart(self.PVs.SBST_PDES);
                if abs(p_sbst) > 0, self.sbst_offset = -1 * p_sbst; end
            end

            [all_s,all_k] = find(self.linac_map == self.linac);
            self.klys_map = all_k(find(all_s == s));
            self.klys = self.klys_map(1);
            
            % special case dPhi for LI11 since beam gamma is so small here
            self.dPhi = self.DEFAULT_DPHI(self.linac+1);
            % if (self.linac == 2) && (self.sector == 11), self.dPhi = 40; end
            self.N_steps = self.DEFAULT_STEPS(self.linac+1);
            % self.N_samples = self.DEFAULT_SAMPLES;
        end

        function self = set.klys(self, k)
            assert(ismember(k, self.klys_map), 'Invalid klystron number');
            self.klys = k;

            self.klys_str = sprintf('%d-%d', self.sector, self.klys);

            % populate phase control/readback PVs
            % varies between L0, L1 and L2-3 due to rf control variation
            recbase = 'LI%d:KLYS:%d1';
            if self.linac == 0, recbase = 'KLYS:LI%d:%d1'; end;
            klys_rec = sprintf(recbase, self.sector, self.klys);
            self.PVs.klys_PDES = sprintf('%s:PDES', klys_rec);
            self.PVs.klys_PHAS = sprintf('%s:PHAS', klys_rec);
            self.PVs.klys_GOLD = sprintf('%s:GOLD', klys_rec);
            self.PVs.klys_KPHR = sprintf('%s:KPHR', klys_rec);
            self.PVs.goldchg = sprintf('%s:GOLDCHG', klys_rec);
            self.PVs.goldts = sprintf('%s:GOLDCHGTS', klys_rec);
            self.PVs.phase0 = sprintf('%s:PHASSCANERR', klys_rec);
            self.PVs.phasets = sprintf('%s:PHASSCANTS', klys_rec);
            if self.linac == 0
                self.PVs.sfbPDES = sprintf('%s:SFB_PDES', klys_rec);
                self.PVs.refpoc = sprintf('ACCL:LI10:%d1:REFPOC', self.klys);
                self.PVs.wvgPACT = sprintf('ACCL:LI10:%d1:PHASE_W0CH0', self.klys);
            elseif self.linac == 1
                stmp = sprintf('KLYS:LI11:%d1:SSSB', self.klys);
                self.PVs.SSSB_PDES = sprintf('%s_PDES', stmp);
                self.PVs.SSSB_ADES = sprintf('%s_ADES', stmp);
            end

            % check if this RFS is on-beam
            [act, ~,~,~,~,~] = control_klysStatGet(self.klys_str, 10);
            if bitget(act, 1)
                self.klys_stat = 1;
            elseif bitget(act, 2)
                self.klys_stat = 2;
            elseif bitget(act, 3)
                self.klys_stat = 3;
            end

            [PDES, PACT, POC] = self.get_phase_settings();
            self.in.PDES = PDES;
            self.in.PACT = PACT;
            self.in.POC = POC;

            % scan offset is determined by the relevant PDES
            p_klys = 0.0;
            self.klys_offset = 0.0;
            switch self.linac
                case 0,     p_klys = lcaGetSmart(self.PVs.sfbPDES);
                case 1,     p_klys = lcaGetSmart(self.PVs.SSSB_PDES);
                case {2,3}, p_klys = lcaGetSmart(self.PVs.klys_PDES);
            end
            if abs(p_klys) > 0.0, self.klys_offset = -1 * p_klys; end
            self.in.phi_set = p_klys - self.sbst_offset;

            self.save_target_initial_setting();
        end

        function set.N_steps(self, val)
            self.N_steps = val;
            % reinit measurement arrays when Nsteps changes
            self.msmt.PHI     = zeros(1, self.N_steps);
            self.msmt.X       = zeros(1, self.N_steps);
            self.msmt.X_err   = zeros(1, self.N_steps);
            self.msmt.dE      = zeros(1, self.N_steps);
            self.msmt.dE_err  = zeros(1, self.N_steps);
        end
    end

    methods
        
        function self = F2_phasescan(linac, sector, klys)

            self.construct_linac_map();
            self.linac = linac;
            self.sector = sector;
            self.klys = klys;

            self.in.range = [];
            self.zigzag = false;
            self.simulation = false;

            self.start_time = datetime('now');
            self.start_time.Format = 'dd-MMM-uuuu HH:mm:ss';

            self.GUI_attached = false;
        end

        % associate each linac with an int labelling its linac region
        % L0: 10-3, 10-4
        % L1: 11-1, 11-2
        % L2: 11-4 - 14-8
        % L3: 15-1 - 19-6
        function construct_linac_map(self)
            % literal indexing wastes ~11*8 elements, but who cares lol
            self.linac_map = NaN(20,8);
            self.linac_map(10,3:4) = 0;
            self.linac_map(11,1:2) = 1;
            self.linac_map(11,4:8) = 2;
            self.linac_map(12:14,:) = 2;
            self.linac_map(15:19,:) = 3;
            % 14-7, 15-2, and 19-7,8 do not exist, set back to NaN
            self.linac_map(14,7) = NaN;
            self.linac_map(15,2) = NaN;
            self.linac_map(19,7:8) = NaN;
        end
        
        function [PDES, PACT, POC] = get_phase_settings(self)
            switch self.linac
                case 0
                    PDES = lcaGetSmart(self.PVs.klys_PDES);
                    PACT = lcaGetSmart(self.PVs.wvgPACT);
                    POC = lcaGetSmart(self.PVs.refpoc);
                case 1
                    [PACT, ~, ~, ~, KPHR, GOLD] = control_phaseGet(self.klys_str);
                    PDES = lcaGetSmart(self.PVs.SSSB_PDES);
                    POC = KPHR;
                case {2,3}
                    [PACT, PDES, ~, ~, KPHR, GOLD] = control_phaseGet(self.klys_str);
                    POC = GOLD;
            end
        end

        function [ctl, rbv, poc] = get_phase_setting_desc(self)
            switch self.linac
                case 0
                    ctl = self.PVs.klys_PDES;
                    rbv = self.PVs.wvgPACT;
                    poc = self.PVs.refpoc;
                case 1
                    ctl = self.PVs.SSSB_PDES;
                    rbv = sprintf('%s (delta)', self.PVs.klys_KPHR);
                    poc = self.PVs.klys_GOLD;
                case {2,3}
                    ctl = self.PVs.klys_PDES;
                    rbv = self.PVs.klys_PHAS;
                    poc = self.PVs.klys_GOLD;
            end
        end
        
        % compute the range of phase settings given range + N steps
        function compute_scan_range(self)
            N = self.N_steps;
            if all(isnan(self.klys_map)), return; end
                        
            self.in.p0 = 0;
            switch self.linac
                case {0,2,3}
                    self.in.p0 = lcaGetSmart(self.PVs.klys_PDES);
                case 1
                    self.in.p0 = lcaGetSmart(self.PVs.klys_KPHR);
            end

            uncorrected_range = linspace(self.in.p0-self.dPhi, self.in.p0+self.dPhi, N);
            self.in.range = self.sbst_offset + self.klys_offset + uncorrected_range;
            fprintf(' calculated scan range is [%.2f, %.2f]\n', self.in.range(1), self.in.range(N))
            if self.zigzag
                odd_steps = find(bitget(1:N, 1));
                even_steps = find(~bitget(1:N, 1));
                midpt = round(numel(odd_steps)/2);
                mask = [odd_steps(midpt+1:end) flip(even_steps,2) odd_steps(1:midpt)];
                self.in.range = self.in.range(mask');
            end
        end

        % save all needed phase settings used to restore the target RFS
        function save_target_initial_setting(self)
            if self.linac == 1
                self.undo = struct;
                self.undo.SSSB.ADES1 = lcaGetSmart('KLYS:LI11:11:SSSB_ADES');
                self.undo.SSSB.ADES2 = lcaGetSmart('KLYS:LI11:21:SSSB_ADES');
                self.undo.SSSB.PDES1 = lcaGetSmart('KLYS:LI11:11:SSSB_PDES');
                self.undo.SSSB.PDES2 = lcaGetSmart('KLYS:LI11:21:SSSB_PDES');
            end
            self.undo.PDES = self.in.PDES;
            self.undo.POC = self.in.POC;
        end

        % disable relevant downstream longitudinal feedbacks for the scan
        function disable_feedbacks(self)
            if self.simulation, return; end

            need_disable = false;
            
            % FB on/off statuses are individual bits of overall status word
            FB_state = lcaGetSmart(self.FB_state_PV);
            self.init_feedback_state = FB_state;
            DL10E_on  = bitget(FB_state, 1);
            BC11E_on  = bitget(FB_state, 3);
            BC11BL_on = bitget(FB_state, 4);
            BC14E_on  = bitget(FB_state, 2);
            BC14BL_on = bitget(FB_state, 6);  
            BC20E_on  = bitget(FB_state, 5);
            
            % L0 scan: disable DL10E, BC11E, BC11BL
            % L1 scan: disable BC11E, BC11BL
            % L2 scan: disable BC14E, BC14BL
            % L3 scan: disable BC20E
            switch self.linac
                case 0
                    if DL10E_on,  FB_state = bitset(FB_state, 1, 0); end
                    if BC11E_on,  FB_state = bitset(FB_state, 3, 0); end
                    if BC11BL_on, FB_state = bitset(FB_state, 4, 0); end
                    if DL10E_on || BC11E_on || BC11BL_on, need_disable = true; end
 
                case 1
                    if BC11E_on,  FB_state = bitset(FB_state, 3, 0); end
                    if BC11BL_on, FB_state = bitset(FB_state, 4, 0); end
                    if BC11E_on || BC11BL_on, need_disable = true; end
  
                case 2
                    if BC14E_on,  FB_state = bitset(FB_state, 2, 0); end
                    if BC14BL_on, FB_state = bitset(FB_state, 6, 0); end
                    if BC14E_on || BC14BL_on, need_disable = true; end
                    
                case 3
                    if BC20E_on
                        FB_state = bitset(FB_state, 5, 0);
                        need_disable = true;
                    end
            end
            
            if need_disable, lcaPutSmart(FB_state_PV, FB_state); end
        end

        function set_L0_LLRF_phase_feedback(self, state)
            if self.simulation, return; end
            lcaPutSmart(sprintf('KLYS:LI10:%d1:SFB_PDIS', self.klys), state);
        end

        % set the scan target klystron's control phase to 'p'
        % in L1 adjust KPHR directly, otherwise use PDES
        % TO DO: update for L0?
        function PACT = set_phase(self, p)
            
            % for simulated scans just pause and return PACT = PDES
            if self.simulation, pause(0.5); PACT = p; return; end

            % L0: set KLYS PDES, report ACCL WVG phase
            if self.linac == 0
                lcaPutSmart(self.PVs.klys_PDES, p);
                pause(1.0);
                % L0 PADs occasionally read ~120deg for no apparent reason
                % try getting phase twice in hopes of avoiding bad luck
                PACT = lcaGetSmart(self.PVs.wvgPACT);
                if abs(PACT - p) > 1.5
                    pause(0.1)
                    PACT = lcaGetSmart(self.PVs.wvgPACT)
                end
            
            % L1: set klystron KPHR, report KPHR
            elseif self.linac == 1
                [~, ~] = control_phaseSet(self.klys_str, p, 0,0, 'KPHR');
                pause(0.2);
                PACT = lcaGetSmart(self.PVs.klys_KPHR);
            
            % L2, L3: set klystron PDES, report PACT <--- slow!!!
            else
                [PACT, ~] = control_phaseSet(self.klys_str, p, 1, 1);
                % invalid SLC phase readbacks use -10000degS as a fill value, try again if so
                if PACT == -10000.0, [PACT, ~] = control_phaseSet(self.klys_str, p, 1, 1); end
            end
        end

        % correct target klystron phase based on the measured error
        function apply_phase_correction(self)
            if self.simulation, return; end

            % apply phase correction
            % L0: update LLRF REFPOC
            % L1: subtract measured error from KPHR
            % L2-L3: reGOLD using the SCP, need to PDES=0 & trim as well
            switch self.linac
                case 0
                    lcaPutSmart(self.PVs.refpoc, self.out.POC);
                
                case 1
                    [~, ~] = control_phaseSet(self.klys_str, self.out.POC, 0,0, 'KPHR');
                
                case {2,3}
                    [PACT, ~] = control_phaseSet(self.klys_str, self.fit.phi_act, 1, 1);
                    [PACT, PDES, GOLD] = control_phaseGold(self.klys_str, self.in.phi_set);
                    % poc_zero = GOLD;
                    [PACT, ~] = control_phaseSet(self.klys_str, self.in.PDES, 1, 1);
            end

            % write out resultant phase settings
            [PDES, PACT, POC] = get_phase_settings(self);
            self.out.PDES = PDES;
            self.out.PACT = PACT;
            self.out.POC = POC;

            % write history PVs
            %lcaPutSmart(self.PVs.phase0, self.fit.phi_meas);
            %lcaPutSmart(self.PVs.goldchg, poc_zero);
            scan_ts = (now - self.EPICS_t0) * 24*60*60
            lcaPutSmart(self.PVs.goldts, scan_ts);
            lcaPutSmart(self.PVs.phasets, scan_ts);
        end
        
        % apply self.undo settings to revert the phase scan
        function revert_phase_settings(self)
            if self.simulation, return; end

            switch self.linac
                case 0
                    lcaPutSmart(self.PVs.klys_PDES, self.undo.PDES);
                    lcaPutSmart(self.PVs.refpoc, self.undo.POC);
                case 1
                    lcaPutSmart('KLYS:LI11:11:SSSB_ADES', self.undo.SSSB.ADES1);
                    lcaPutSmart('KLYS:LI11:21:SSSB_ADES', self.undo.SSSB.ADES2);
                    lcaPutSmart('KLYS:LI11:11:SSSB_PDES', self.undo.SSSB.PDES1);
                    lcaPutSmart('KLYS:LI11:21:SSSB_PDES', self.undo.SSSB.PDES2);
                    [~, ~] = control_phaseSet(self.klys_str, self.undo.POC, 0,0, 'KPHR');
                case {2,3}
                    [~, ~] = control_phaseSet(self.klys_str, self.undo.PDES, 1, 1);
                    lcaPutSmart(self.PVs.klys_GOLD, self.undo.POC);
            end
        end
        
        % collect & average self.N_samples of BPM data from the appropriate BPM
        function bpm_data = get_bpm_data(self)
            bpm_data = zeros(self.N_samples, 2);
            if self.simulation, bpm_data = self.mock_bpm_data(); return; end

            % lcaMonitor demands cell arrays for some reason(?)
            Xcell = {sprintf('%s', self.PVs.X)};
            lcaSetMonitor(Xcell);
            for i = 1:self.N_samples
                
                lcaNewMonitorWait(Xcell);
                %pause(0.1); % maybe needed?, not clear how monitorWait plays w/ AIDA
                xpos = lcaGetSmart(self.PVs.X);
                tmit = lcaGetSmart(self.PVs.TMIT);
                bpm_data(i,1) = xpos;
                bpm_data(i,2) = tmit;
                
                % discard BPM data when TMIT is too low, unphysically high or NaN
                if isnan(tmit) || tmit < self.msmt.TMIT_thr_lo || tmit > self.msmt.TMIT_thr_hi
                    disp('bad BPM data acq.');
                    disp(xpos); disp(tmit);
                    bpm_data(i,1) = NaN;
                end
            end
        end
        
        % fake bpm data for simulated scans
        function bpm_data = mock_bpm_data(self)
            A0 = sign(self.eta) * 5.0;
            phi_i = self.in.range(self.i_scan);
            sim_pos = cosd(phi_i - self.in.p0 + self.sim_err);
            jitter = 0.02*randn();
            jitter2 = 3e8*randn();
            bpm_data(:,1) = A0*(sim_pos + jitter);
            bpm_data(:,2) = self.beam.N_elec + jitter2;
            % small chance for bad data
            if rand < 0.1, bpm_data(:,1) = NaN; end
        end

        % sorts BPM/energy data by measured phase, filters NaNs
        function sanitize_scan_data(self)
            PHI = self.msmt.PHI;
            X = self.msmt.X; X_err = self.msmt.X_err;
            dE = self.msmt.dE; dE_err = self.msmt.dE_err;
            TMIT = self.msmt.TMIT;

            mask = ~isnan(X);
            PHI = PHI(mask);
            X = X(mask); X_err = X_err(mask);
            dE = dE(mask); dE_err = dE_err(mask);
            TMIT = TMIT(mask);

            [PHI, isort] = sort(PHI);
            X = X(isort); X_err = X_err(isort);
            dE = dE(isort); dE_err = dE_err(isort);
            TMIT = TMIT(isort);

            self.msmt.PHI = PHI;
            self.msmt.X = X; self.msmt.X_err = X_err;
            self.msmt.dE = dE; self.msmt.dE_err = dE_err;
            self.msmt.TMIT = TMIT;
        end

        % wrapper to update the GUI status message text box if it exists
        % prints to stdout if not
        function write_status(self, message)
            if self.GUI_attached
                self.GUI_message.Text = message;
            else
                disp(message);
            end
        end

        % wrapper to check if the 'Abort' button on the GUI was pressed
        function scan_abort_check(self)
            if ~self.GUI_attached, return; end
            if self.GUI_abortButton.Value
                self.abort_requested = true;
            end
        end

        function plot_phase_scan(self, ax, show_fit)
            hold(ax,"off");
            yyaxis(ax,'left');

            errorbar(ax, ...
                self.msmt.PHI, self.msmt.X, self.msmt.X_err, ...
                '.', 'Color','#0072bd', 'MarkerSize',10);

            yyaxis(ax,'right');
            errorbar(ax, ...
                self.msmt.PHI, self.msmt.dE, self.msmt.dE_err, ...
                '.', 'Color',"#d95319", 'MarkerSize',10);
            hold(ax,"on");

            if show_fit
                yyaxis(ax,'right');
                plot(ax, self.fit.range, self.fit.dE, ...
                    '-', 'Color',"#d95319", 'LineWidth',2);

                yyaxis(ax,'left');
                plot(ax, self.fit.range, self.fit.X, ...
                    '-', 'Color',"#0072bd", 'LineWidth',2);
                % p0 = 0;
                % if self.linac == 1, p0 = -1*self.in.phi_set; end
                p0 = -1*self.in.phi_set;
                xline(ax, p0, ...
                    '--', 'Color',"#666666", 'LineWidth',2)
                xline(ax, self.fit.phi_meas, ...
                    '--g', 'LineWidth',2);
            end

            self.label_plot(ax);
        
        end

        function plot_TMIT(self, ax)
            cla(ax);
            hold(ax, "on");
            tmit_ratio = self.msmt.TMIT ./ self.beam.N_elec;
            for i = 1:length(self.msmt.TMIT)
                ratio = tmit_ratio(i);
                bad_data = (ratio < 0.8 || ratio > 1.3 || isnan(self.msmt.X(i)));
                col = 'k'; if bad_data, col = 'r'; end
                plot(ax, self.msmt.PHI(i), ratio, '*', 'Color',col);
            end
        end

        function label_plot(self, ax)
            title(ax, sprintf('Phase scan: K%s  %s', self.klys_str, self.start_time));
            % if self.success
            %     sbs = ['\phi_{DES} = ' self.in.phi_set ' \phi_{ACT} = ' self.fit.phi_meas ' \phi_{err} = ' self.fit.phi_err];
            %     subtitle(ax, sbs , 'Interpreter','tex');
            % end
            xlabel(ax, ['\phi ' self.klys_str], 'Interpreter','tex')
            yyaxis(ax, 'left');
            ylabel(ax, sprintf('%s [mm]', self.BPM), 'Interpreter','tex');
            yyaxis(ax, 'right');
            ylabel(ax, sprintf('\\Delta E [MeV]'), 'Interpreter', 'tex');
        end

        % calculate beam phase error
        % fits BPM data to Acos(phi+psi) + B using linear least-squares
        function beam_phase_fit(self)

            % filter out bad BPM data & sort by phi
            self.sanitize_scan_data();

            PHI = self.msmt.PHI; X = self.msmt.X;
            
            M_t = [cosd(PHI); sind(PHI); ones(size(PHI))];
            M = M_t';
            c = (M_t * M) \ M_t * X';
            
            self.fit.A = sign(c(1)) * sqrt(c(1)^2 + c(2)^2);
            self.fit.B = c(3);
            
            % phi_meas = -1 * asind(c(2) / self.fit.A);
            phi_meas = asind(c(2) / self.fit.A);
            
            % LLS fit always finds the nearest zero crossing, so we need to
            % flip the sign of A, shift by pi, then wrap to +/-180
            %  phi_meas -> actual measured beam phase
            %  phi_err  -> difference of actual/expected beam phase
            %  phi_act  -> actual zero-crossing (i.e. peak Egain) phase
            if sign(self.fit.A) ~= sign(self.eta)
                phi_meas = phi_meas + (abs(phi_meas) < 180.0)*180.0;
            end
            self.fit.phi_meas = wrapTo180(phi_meas);
            self.fit.phi_err = self.fit.phi_meas + self.in.phi_set;
            self.fit.phi_act = self.in.phi_set + self.fit.phi_meas;
            if self.linac == 0,
                self.fit.phi_err = self.fit.phi_meas;
                self.fit.phi_act = self.fit.phi_meas + self.in.phi_set;
            elseif self.linac == 1,
                self.fit.phi_err = self.fit.phi_meas + self.in.phi_set;
                self.fit.phi_act = self.fit.phi_act + self.klys_offset;
            end

            self.fit.range = linspace(PHI(1), PHI(end), 200);
            % disp(self.fit.range);
            self.fit.X = self.fit.A * cosd(self.fit.range - self.fit.phi_meas) + self.fit.B;
            
            dE_dx = self.beam.E_design / self.eta;
            self.fit.dE = dE_dx * self.fit.X;
            self.fit.E0 = dE_dx * self.fit.A;
            self.fit.C = dE_dx * self.fit.B;
        end

        function phase_scan(self)

            assert(self.klys_stat == 1, 'Cannot phase scan, RFS is not on-beam')

            self.success = false;
            self.scan_aborted = false;

            % check if GUI handles are attached, if so use them
            if self.GUI_attached
                ax = self.GUI_ax;
            else
                ax = axis;
            end

            % verify that TD11 is in if scanning upstream of L2
            if self.linac < 2
                if ~strcmp(lcaGetSmart('DUMP:LI11:390:TGT_STS'), 'IN')
                    self.write_status('TD-11 is not inserted. Scan aborted.');
                    return
                end
            end

            self.start_time = datetime('now');
            self.start_time.Format = 'dd-MMM-uuuu HH:mm:ss';

            self.compute_scan_range();
            
            % disable relevant longitudinal feedbacks before scanning
            % for L0, also turn off LLRF slow feedbacks
            self.disable_feedbacks()
            if self.linac == 0, self.set_L0_LLRF_phase_feedback(0); end
            
            % roll a fake error in degS for simulated scans to "measure"
            % self.sim_err = 15.0;
            if self.simulation, self.sim_err = 45.0*randn(); end
            
            hold(ax,"off");
            self.label_plot(ax);

            % main scan loop: set phase, take BPM data & plot
            for i = 1:self.N_steps
                self.i_scan = i;
                
                i_str = sprintf('[%d/%d]', i, self.N_steps);

                self.scan_abort_check();
                if self.abort_requested, self.scan_aborted = true; break; end

                self.write_status( ...
                    sprintf('%s Setting %s phase = %.1f deg ...', ...
                    i_str, self.klys_str, self.in.range(i) ...
                    ));
                pdes = self.in.range(self.i_scan);
                PACT = self.set_phase(self.in.range(self.i_scan));

                prbv = PACT;
                if self.linac == 1, prbv = PACT - self.in.p0 - self.klys_offset; end
                self.msmt.PHI(self.i_scan) = prbv;
                fprintf('%s pDes/pAct : %.1f / %.1f\n', i_str, pdes, prbv);

                self.scan_abort_check();
                if self.abort_requested, self.scan_aborted = true; break; end
                
                self.write_status(sprintf('%s Collecting BPM data ...', i_str));
                try
                    bpm_data = self.get_bpm_data();
                catch
                    self.write_status(sprintf('%s BPM data acquisition failed. Aborting scan ...', i_str));
                    self.scan_aborted = true;
                    break;
                end
                
                self.msmt.X(self.i_scan)     = nanmean(bpm_data(:,1));
                self.msmt.X_err(self.i_scan) = nanstd(bpm_data(:,1));
                self.msmt.TMIT(self.i_scan)  = nanmean(bpm_data(:,2));
                
                dE_dx = self.beam.E_design / self.eta;
                self.msmt.dE(self.i_scan)     = dE_dx * self.msmt.X(self.i_scan);
                self.msmt.dE_err(self.i_scan) = dE_dx * self.msmt.X_err(self.i_scan);

                self.scan_abort_check();
                if self.abort_requested, self.scan_aborted = true; break; end
                
                self.plot_phase_scan(ax, false);
                if self.GUI_attached, self.plot_TMIT(self.GUI_axTMIT); end
                drawnow nocallbacks;
                
            end
            
            % quit here if the scan was aborted
            if self.scan_aborted, return; end
            
            % re-enable L0 LLRF phase FB & longitudinal feedback initial states
            if self.linac == 0, self.set_L0_LLRF_phase_feedback(1); end
            lcaPutSmart(self.FB_state_PB, self.init_feedback_state);
            
            % (3) fit BPM data and calculate beam phase error and energy
            self.beam_phase_fit();

            % (4) calculate correction to phase offset PV
            poc_zero = wrapTo180(self.in.POC + self.fit.phi_err);
            if (self.linac == 1) && (abs(self.in.POC) > 180.0)
                poc_zero = wrapTo360(self.in.POC + self.fit.phi_err);
            end
            self.out.POC = poc_zero;
            
            % (5) if we've gotten this far, scan succeeded, time to summarize & save results
            self.success = true;
            dt = datetime('now');
            self.end_time = dt;
            self.end_time.Format = 'dd-MMM-uuuu HH:mm:ss';
            yyyy = sprintf('%d', year(dt));
            yyyymm = sprintf('%s-%02d', yyyy, month(dt));
            yyyymmdd = sprintf('%s-%02d', yyyymm, day(dt));
            hhmmss = sprintf('%02d%02d%02d', hour(dt), minute(dt), uint8(second(dt)));
            datadir = sprintf('/u1/facet/matlab/data/%s/%s/%s', yyyy, yyyymm, yyyymmdd);
            self.scan_name = sprintf('PhaseScan_K%s_%s-%s', self.klys_str, yyyymmdd, hhmmss);
            self.data_file = sprintf('%s/%s.mat', datadir, self.scan_name);

            txt = { ...
                sprintf('phase scan K%s completed at %s\n', self.klys_str, self.end_time), ...
                sprintf('scan data saved to: %s\n', self.data_file), ...
                sprintf('scan success: %s\n', string(self.success)), ...
                sprintf('  desired beam phase = %.1f degS\n', self.in.phi_set), ...
                sprintf('  meas. beam phase   = %.1f degS\n', -1*self.fit.phi_meas), ...
                sprintf('  actual zero phase  = %.1f degS\n', self.fit.phi_act), ...
                sprintf('  phase error        = %.1f degS\n', self.fit.phi_err), ...
                sprintf('  POC init           = %.1f degS\n', self.in.POC), ...
                sprintf('  POC new            = %.1f degS\n', self.out.POC), ...
                sprintf('  est. klys Egain    = %.1f MeV', self.fit.E0), ...
            };
            self.scan_summary = strjoin(txt, '');
            disp(self.scan_summary);
            if self.simulation, fprintf('  simulated phase error = %.2fdeg\n', self.sim_err); end

            if ~self.simulation, save(self.data_file); end
            
            % (6) plot fit and scan result
            self.plot_phase_scan(ax, true);
            if self.GUI_attached, self.plot_TMIT(self.GUI_axTMIT); end
            
            self.GUI_message.Text = 'Scan completed. Press "Apply" to correct phase error.';

            % (7) restore initial phase setting
            if ~self.simulation, self.revert_phase_settings(); end
        end

    end
end
