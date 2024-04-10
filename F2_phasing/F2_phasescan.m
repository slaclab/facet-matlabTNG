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
        
        % hardcoded dispersion at each BPM
        % TO DO: grab this from the model server, once such a thing exists
        etas = 1000 * [-0.2628 -0.2511 -0.4374 0.1207];

        EPICS_t0 = datenum('Jan 1 1990 00:00:00');

        DEFAULT_DPHI = [20 20 60 60];
        DEFAULT_STEPS = [15 15 9 9];
        DEFAULT_SAMPLES = 20;
        
    end
    
    properties

        linac_map = NaN(20,8);
        sector_map = NaN(5);
        klys_map = NaN(8);

        linac = 0;         % linac number (1,2,3)
        sector = 10;       % sector number (10-19)
        klys = 3;          % klystron number (1-8)
        klys_str = 'ss-k'; % klystron ID string

        % klystron trigger status 1: on-beam, 2: standby, 3: offline
        klys_stat = 3;

        start_time         % scan start time
        end_time           % scan completion time

        abort_requested = false;
        scan_aborted = false;
        success = false;
        
        i_scan = 0;        % phase scan step index, used to populate msmt arrays

        BPM = ''           % spectrometer BPM device name
        eta = 0.0          % dispersion at BPM (mm)
        klys_offset = 0;
        sbst_offset = 0;
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

        % handles for frontend objects to be manipulated during the scan
        GUI_attached logical
        GUI_ax matlab.ui.control.UIAxes 
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

            % get linac operating point & BPM info
            % self.update_op_point();
            self.beam.f = lcaGetSmart('EVNT:SYS1:1:BEAMRATE');
            self.beam.N_elec = lcaGetSmart('BPMS:IN10:221:TMIT1H');
            self.beam.Q = 1.6e-19 * self.beam.N_elec / 1e-12;
            self.beam.E_design = lcaGetSmart(self.bend_BACT_PVs(self.linac+1));
            self.BPM = self.bpms(self.linac+1);
            self.eta = self.etas(self.linac+1);
            self.PVs.X = sprintf('%s:%s', self.BPM, 'X');
            self.PVs.TMIT = sprintf('%s:%s', self.BPM, 'TMIT');
            self.msmt.TMIT_thr_lo = 0.8 * self.beam.N_elec;
            self.msmt.TMIT_thr_hi = 1.1 * self.beam.N_elec;
            
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

            if self.linac >= 2
                self.PVs.SBST_PDES = sprintf('LI%d:SBST:1:PDES', self.sector);
                p_sbst = lcaGetSmart(self.PVs.SBST_PDES);
                if abs(p_sbst) > 0, self.sbst_offset = -1 * p_sbst; end
            end

            [all_s,all_k] = find(self.linac_map == self.linac);
            self.klys_map = all_k(find(all_s == s));
            self.klys = self.klys_map(1);
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
                self.PVs.refpoc = sprintf('%s:REFPOC', klys_rec);
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
            switch self.linac
                case 0,     p_klys = lcaGetSmart(self.PVs.sfbPDES);
                case 1,     p_klys = lcaGetSmart(self.PVs.SSSB_PDES);
                case {2,3}, p_klys = lcaGetSmart(self.PVs.klys_PDES);
            end
            if abs(p_klys) > 0, self.klys_offset = -1 * p_klys; end
            self.in.phi_set = p_klys;

            self.save_target_initial_setting();

            % roll a fake error in degS for simulated scans to "measure"
            self.sim_err = 80.0*randn();
        end

        function set.dPhi(self, val)
            self.dPhi = val;
            self.compute_scan_range();
        end

        function set.N_steps(self, val)
            self.N_steps = val;
            self.compute_scan_range();
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
            self.dPhi = self.DEFAULT_DPHI(linac+1);
            self.in.p0 = 0;
            self.N_steps = self.DEFAULT_STEPS(linac+1);
            self.N_samples = self.DEFAULT_SAMPLES;
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
            % dp = self.dPhi;
                        
            % for L1 phase scans we manipulate the KPHR directly
            self.in.p0 = 0;
            if self.linac == 0
                % to do: autodetect L0-A/B phases?
                self.in.p0 = 0;
            elseif self.linac == 1
                % self.in.p0 = self.in.KPHR;
                self.in.p0 = lcaGetSmart(self.PVs.klys_KPHR);
            end

            uncorrected_range = linspace(self.in.p0-self.dPhi, self.in.p0+self.dPhi, N);
            self.in.range = self.sbst_offset + self.klys_offset + uncorrected_range;
            
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
            FB_state_PV = "SIOC:SYS1:ML00:AO856";
            FB_state = lcaGetSmart(FB_state_PV);
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

        % set the target station (in L1) PDES to 0
        % should be called before 
        function set_L1_chirp(self, cdes)
            if self.simulation, return; end
            lcaPutSmart(self.PVs.SSSB_PDES, cdes);
            % necessary? should have no effect since SLC PDES isn't used
            [L1_pact, L1_pok] = control_phaseSet(handles.data.name, cdes, 1, 1);
        end
        
        % subroutine to correct energy in L1 after cresting the target station before phase scans
        function L1_energy_correction(self)
            if self.simulation, return; end
            
            % fix energy with 11-2 for 11-1 scans and vice versa
            corrector_klys = 2; if self.klys == 2, corrector_klys = 1; end
            
            fprintf('Correcting L1 energy with 11-%d...', corrector_klys);
            
            PV_ADES = sprintf('KLYS:LI11:%d1:SSSB_ADES', corrector_klys);
            ADES_init = lcaGetSmart(PV_ADES);
            ADES_current = ADES_init;
            
            bpm_data = self.get_bpm_data();
            x = nanmean(bpm_data(:,1));
            
            i = 0;
            while (i < 1000) && (abs(x) >= pos_tolerance)
                i = i + 1;
                
                % default step of 0.1MeV, 0.5MeV when further off-energy
                % dispersion is negative at BC11, so sign(x) <-> sign(dE)
                amp_step = 0.1;
                if abs(x) > 1.0, amp_step = 0.5; end
                lcaPutSmart(PV_ADES, ADES_current + sign(x)*amp_step);
 
                ADES_current = lcaGetSmart(PV_ADES);
                bpm_data = self.get_bpm_data();
                x = nanmean(bpm_data(:,1));
            end
        end
        
        % set the scan target klystron's phase to 'p'
        % in L1 adjust KPHR directly, otherwise use PDES
        % TO DO: update for L0?
        function [PACT, phase_ok] = set_phase(self, p)
            
            % for simulated scans just pause and return PACT = PDES
            if self.simulation, pause(0.5); PACT = p; phase_ok = true; return; end

            % L0: set KLYS PDES, report ACCL WVG phase
            if self.linac == 0
                lcaPutSmart(self.PVs.klys_PDES, p)
                phase_ok = 1
                PACT = lcaGetSmart(self.PVs.wvgPACT)
            
            % L1: set klystron KPHR, report KPHR
            elseif self.linac == 1
                [~, phase_ok] = control_phaseSet(self.klys_str, p, 0,0, 'KPHR');
                PACT = lcaGetSmart(self.PVs.KPHR);
            
            % L2, L3: set klystron PDES, report PACT <--- slow!!!
            else
                [PACT, phase_ok] = control_phaseSet(self.klys_str, p, 1, 1);
            end
        end
        
        % sets the target klystron phase to self.in.range(i_scan)
        function step_phase(self)
            [PACT, phase_ok] = self.set_phase(self.in.range(self.i_scan));
            % subtracts off the initial KPHR value for sensible plot axes
            self.msmt.PHI(self.i_scan) = PACT - self.in.p0;
        end

        % reset the klystron phase to the first scan step
        function reset_phase(self)
            [PACT, phase_ok] = self.set_phase(self.in.range(1));
        end
        
        % correct target klystron phase based on the measured error
        function apply_phase_correction(self)
            if self.simulation, return; end

            % apply phase correction
            % L0: REFPOC is subtracted in the feedback -> ADD measured error
            % L1: subtract measured error from KPHR
            % L2-L3: reGOLD using the SCP, need to PDES=0 & trim as well
            switch self.linac
                case 0
                    poc_zero = wrapTo180(self.in.POC + self.fit.phi_meas);
                    lcaPutSmart(self.PVs.refpoc, poc_zero);
                
                case 1
                    poc_zero = self.in.POC - self.fit.phi_meas;
                    [~, OK] = control_phaseSet(self.klys_str, poc_zero, 0,0, 'KPHR');
                
                case {2,3}
                    [PACT, PDES, GOLD] = control_phaseGold(self.klys_str, self.in.phi_set)
                    poc_zero = GOLD;
                    [PACT, OK] = control_phaseSet(self.klys_str, 0.0, 1, 1);
            end

            % write out resultant phase settings
            [PDES, PACT, POC] = get_phase_settings(self)
            self.out.PDES = PDES;
            self.out.PACT = PACT;
            self.out.POC = POC;

            % write history PVs
            lcaPutSmart(self.PVs.phase0, self.fit.phi_meas)
            lcaPutSmart(self.PVs.goldchg, poc_zero);
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
                    lcaPutSmart(self.PVs.KPHR, self.undo.POC);
                case {2,3}
                    [~, ~] = control_phaseSet(self.klys_str, self.undo.PDES, 1, 1);
                    lcaPutSmart(self.PVs.klys_GOLD, self.undo.POC)
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
            bpm_data(:, 1) = A0*(sim_pos + jitter);
            bpm_data(:, 2) = 2e10;
        end
        
        % get position/energy & std dev of both
        function position_energy_msmt(self)
            bpm_data = self.get_bpm_data();
            
            self.msmt.X(self.i_scan)     = nanmean(bpm_data(:,1));
            self.msmt.X_err(self.i_scan) = nanstd(bpm_data(:,1));
            self.msmt.TMIT(self.i_scan)  = nanmean(bpm_data(:,2));
            
            dE_dx = self.beam.E_design / self.eta;
            self.msmt.dE(self.i_scan)     = dE_dx * self.msmt.X(self.i_scan);
            self.msmt.dE_err(self.i_scan) = dE_dx * self.msmt.X_err(self.i_scan);
        end

        % wrapper to update the GUI status message text box if it exists
        % and prints to stdout if not
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
            errorbar(ax, self.msmt.PHI(1:i), self.msmt.X(1:i), self.msmt.X_err(1:i), ...
                '.k', 'MarkerSize', 10);

            yyaxis(ax,'right');
            errorbar(ax, self.msmt.PHI(1:i), self.msmt.dE(1:i), self.msmt.dE_err(1:i),...
                '.', 'Color',"#7e2f8e", 'MarkerSize',10);
            hold(ax,"on");

            if show_fit
                yyaxis(ax,'right');
                plot(ax, self.fit.range, self.fit.dE, ...
                    '-', 'Color',"#d95319", 'LineWidth',2);

                yyaxis(ax,'left');
                plot(ax, self.fit.range, self.fit.X, ...
                    '-', 'Color',"#0072bd", 'LineWidth',2);
                xline(ax, self.in.phi_set, ...
                    '--', 'Color',"#666666", 'LineWidth',2)
                xline(ax, -1*self.fit.phi_meas, ...
                    '--g', 'LineWidth',2);
            end

            self.label_plot(ax);
        
        end

        function label_plot(self, ax)
            title(ax, sprintf('Phase scan: K%s  %s', self.klys_str, self.start_time));
            xlabel(ax, ['\phi ' self.klys_str], 'Interpreter','tex')
            yyaxis(ax, 'left');
            ylabel(ax, sprintf('%s [mm]', self.BPM), 'Interpreter','tex');
            yyaxis(ax, 'right');
            ylabel(ax, sprintf('\\Delta E [MeV]'), 'Interpreter', 'tex');
        end

        % calculate beam phase error
        % fits BPM data to Acos(phi+psi) + B using linear least-squares
        function beam_phase_fit(self)

            PHI = self.msmt.PHI;
            
            M_t = [cosd(PHI); sind(PHI); ones(size(PHI))];
            M = M_t';
            c = (M_t * M) \ M_t * self.msmt.X';
            
            self.fit.A = sign(c(1)) * sqrt(c(1)^2 + c(2)^2);
            self.fit.B = c(3);
            
            phi_meas = -1 * asind(c(2) / self.fit.A);
            
            % LLS fit always finds the nearest zero crossing, so we need to
            % flip the sign of A, shift by pi, then wrap to +/-180
            if sign(self.fit.A) ~= sign(self.eta)
                phi_meas = phi_meas + (abs(phi_meas) < 180.0)*180.0;
            end
            self.fit.phi_meas = wrapTo180(phi_meas);
            
            self.fit.range = linspace(PHI(1), PHI(end), 200);
            self.fit.X = self.fit.A * cosd(self.fit.range + self.fit.phi_meas) + self.fit.B;
            
            dE_dx = self.beam.E_design / self.eta;
            self.fit.dE = dE_dx * self.fit.X;
            self.fit.E0 = dE_dx * self.fit.A;
            self.fit.C = dE_dx * self.fit.B;
        end

        function phase_scan(self)

            assert(self.klys_stat == 1, 'Cannot phase scan, RFS is not on-beam')

            % check if GUI handles are attached, if so use them
            if self.GUI_attached
                ax = self.GUI_ax
            else
                ax = axis;
            end

            % verify that TD11 is in if scanning upstream of L2
            if self.linac < 2
                if ~strcmp(lcaGetSmart('DUMP:LI11:390:TGT_STS'), 'IN')
                    % self.GUI_message.Text = 'TD-11 is not inserted. Scan aborted.';
                    self.write_status('TD-11 is not inserted. Scan aborted.');
                    return
                end
            end
            
            % disable relevant longitudinal feedbacks before scanning
            % for L0, also turn off LLRF slow feedbacks
            self.disable_feedbacks()
            if self.linac == 0, selfset_L0_LLRF_phase_feedback(0); end
            
            % for L1, manually set SSSB on crest & fix energy
            if self.linac == 1
                self.set_L1_chirp(0.0);
                pause(1);
                self.L1_energy_correction();
            end
            
            hold(self.GUI_ax,"off");
            self.label_plot(self.GUI_ax);

            % main scan loop: set phase, take BPM data & plot
            for i = 1:self.in.N_steps
                self.i_scan = i;
                
                i_str = sprintf('[%d/%d]', i, self.in.N_steps);

                self.scan_abort_check();
                if self.abort_requested, self.scan_aborted = true; break; end

                self.write_status( ...
                    sprintf('%s Setting %s phase = %.1f deg ...', ...
                    i_str, self.klys_str, self.in.range(i) ...
                    ));
                % self.step_phase()
                [PACT, phase_ok] = self.set_phase(self.in.range(self.i_scan));

                % offset the plot axes for KPHR deltas
                self.msmt.PHI(self.i_scan) = PACT - self.in.p0;
                
                self.scan_abort_check();
                if self.abort_requested, self.scan_aborted = true; break; end
                
                self.write_status(sprintf('%s Collecting BPM data ...', i_str));
                bpm_data = self.get_bpm_data();
                
                self.msmt.X(self.i_scan)     = nanmean(bpm_data(:,1));
                self.msmt.X_err(self.i_scan) = nanstd(bpm_data(:,1));
                self.msmt.TMIT(self.i_scan)  = nanmean(bpm_data(:,2));
                
                dE_dx = self.beam.E_design / self.eta;
                self.msmt.dE(self.i_scan)     = dE_dx * self.msmt.X(self.i_scan);
                self.msmt.dE_err(self.i_scan) = dE_dx * self.msmt.X_err(self.i_scan);

                self.scan_abort_check();
                if self.abort_requested, self.scan_aborted = true; break; end
                
                self.plot_phase_scan(self.GUI_ax, false);
                
            end
            
            % quit here if the scan was aborted
            if app.scan_aborted, return; end
            
            % re-enable L0 LLRF phase FB
            if self.linac == 0, self.set_L0_LLRF_phase_feedback(1); end
            
            % (3) fit BPM data and calculate beam phase error and energy
            self.beam_phase_fit();
            
            self.success = true;
            self.end_time = datetime('now');
            self.end_time.Format = 'dd-MMM-uuuu HH:mm:ss';
            %fprintf('phi set  = %.1f deg\n', self.in.phi_set);
            %fprintf('phi act  = %.2f deg\n', err);
            %fprintf('phi meas = %.2f deg\n', self.fit.phi_meas);
            %fprintf('est. dE  = %.2f MeV\n', self.fit.E0);
            %fprintf('\n');
            %disp(self.fit);
            
            % (4) plot fit and scan result
            self.plot_phase_scan(self.GUI_ax, true);
            
            % self.GUI_message.Text = 'Scan completed. Press "Apply" to correct phase error.';

            % (5) restore initial phase setting
            if ~self.simulation, self.reset_phase(); end
        end

    end
end
