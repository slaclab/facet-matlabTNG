% object to handle coire actions and input/output/config parameters of a phase scan
% author: Zack Buschmann <zack@slac.stanford.edu>

classdef F2_phasescan < handle
    
    properties (Constant)
        
        % EPICS record names for each spectrometer BPM
        bpms = [ ...
            "BPMS:IN10:731", "BPMS:LI11:333" "BPMS:LI14:801" "BPMS:LI20:2445" ...
            ];
        
        % bend magnet BACT values for design energy milestones
        bend_BACT_PVs = [ ...
            "BEND:IN10:751:BACT", "BEND:LI11:331:BACT" "BEND:LI14:720:BACT" "LI20:LGPS:1990:BACT" ...
            ];
        
        % hardcoded dispersion at each BPM
        % TO DO: grab this from the model server, once such a thing exists
        etas = 1000 * [-0.2628 -0.2511 -0.4374 0.1207];

        EPICS_t0 = datenum('Jan 1 1990 00:00:00');
        
    end
    
    properties
        linac = 0;         % linac number (1,2,3)
        sector = 10;       % sector number (10-19)
        klys = 3;          % klystron number (1-8)
        klys_str = 'ss-k'; % klystron ID string

        PV_klys_PDES = '';
        PV_klys_PHAS = '';
        PV_klys_GOLD = '';
        PV_klys_KPHR = '';
        PV_goldchg = '';
        PV_goldts = '';
        PV_phase0 = '';
        PV_phasets = '';
        PV_refpoc = '';
        PV_wvgPACT = '';
        PV_sfbPDES = '';
        PV_SSSB_PDES = '';
        PV_SSSB_ADES = '';
        PV_SBST_PDES = '';
        
        BPM = ''           % spectrometer BPM
        eta = 0.0          % dispersion at BPM
        
        sim_err = 0.0;
        
        PV_X = ''
        PV_TMIT = ''
        
        start_time         % scan start time
        end_time           % scan completion time
        
        SUCCESS = false;
        ABORTED = false;
        
        I_STEP = 0;        % phase scan step index, used to populate msmt arrays
        
        beam = struct;
        in = struct;
        msmt = struct;
        out = struct;
        fit = struct;
        undo = struct;
    end

    methods
        
        function self = F2_phasescan(linac, sector, klys)

            % global scan setup
            self.linac = linac;
            self.sector = sector;
            self.klys = klys;
            self.klys_str = sprintf('%d-%d', self.sector, self.klys);

            % phase control/readback PVs
            % varies between L0, L1 and L2-3 due to rf control variation
            recbase = 'LI%d:KLYS:%d1';
            if self.linac == 0, recbase = 'KLYS:LI%d:%d1'; end;
            klys_rec = sprintf(recbase, self.sector, self.klys);
            self.PV_klys_PDES = sprintf('%s:PDES', klys_rec);
            self.PV_klys_PHAS = sprintf('%s:PHAS', klys_rec);
            self.PV_klys_GOLD = sprintf('%s:GOLD', klys_rec);
            self.PV_klys_KPHR = sprintf('%s:KPHR', klys_rec);
            self.PV_goldchg = sprintf('%s:GOLDCHG', klys_rec);
            self.PV_goldts = sprintf('%s:GOLDCHGTS', klys_rec);
            self.PV_phase0 = sprintf('%s:PHASSCANERR', klys_rec);
            self.PV_phasets = sprintf('%s:PHASSCANTS', klys_rec);

            if self.linac == 0
                self.PV_sfbPDES = sprintf('%s:SFB_PDES', klys_rec);
                self.PV_refpoc = sprintf('%s:REFPOC', klys_rec);
                self.PV_wvgPACT = sprintf('ACCL:LI10:%d1:PHASE_W0CH0', self.klys);
            elseif self.linac == 1
                stmp = sprintf('KLYS:LI11:%d1:SSSB', self.klys);
                self.PV_SSSB_PDES = sprintf('%s_PDES', stmp);
                self.PV_SSSB_ADES = sprintf('%s_ADES', stmp);
            else
                self.PV_SBST_PDES = sprintf('LI%d:SBST:1:PDES', self.sector);
            end

            self.BPM = '';
            self.PV_X = '';
            self.PV_TMIT = '';
            self.eta = 0.0;

            self.start_time = datetime('now');
            self.start_time.Format = 'dd-MMM-uuuu HH:mm:ss';
            
            % current beam parameters
            self.beam.N_elec = 0.0;
            self.beam.Q = 0.0;
            self.beam.f = 0.0;
            self.beam.E_design = 0.0;
            
            % input configuration
            self.in.range = [];
            self.in.dPhi = 0;
            self.in.p0 = 0;
            self.in.N_steps = 0;
            self.in.N_samples = 0;
            self.in.klys_offset = 0;
            self.in.sbst_offset = 0;
            self.in.zigzag = false;
            self.in.simulation = false;
            self.in.phi_set = 0.0;

            [PDES, PACT, POC] = self.get_phase_settings();
            self.in.PDES = PDES;
            self.in.PACT = PACT;
            self.in.POC = POC;

            % offset by SBST, klystron PDES in the main linac
            p_sbst = 0.0; p_klys = 0.0;
            switch self.linac
                case 0
                    p_klys = lcaGetSmart(self.PV_sfbPDES);
                case 1
                    p_klys = lcaGetSmart(self.PV_SSSB_PDES);
                case {2,3}
                    p_sbst = lcaGetSmart(self.PV_SBST_PDES);
                    p_klys = lcaGetSmart(self.PV_klys_PDES);
            end
            if abs(p_sbst) > 0, self.in.sbst_offset = -1 * p_sbst; end
            if abs(p_klys) > 0
                self.in.klys_offset = -1 * p_klys;
                self.in.phi_set = p_klys;
            end
            
            % undo settings
            self.undo.PDES = 0.0;
            self.undo.POC = 0.0;
            self.undo.SSSB = struct;
            self.undo.SSSB.ADES1 = 0.0;
            self.undo.SSSB.ADES2 = 0.0;
            self.undo.SSSB.PDES1 = 0.0;
            self.undo.SSSB.PDES2 = 0.0;

            % scan measurement data
            self.msmt.PHI = [];
            self.msmt.X = [];
            self.msmt.X_err = [];
            self.msmt.TMIT = [];
            self.msmt.dE = [];
            self.msmt.dE_err = [];
            self.msmt.TMIT_thr_lo = 0;
            self.msmt.TMIT_thr_hi = 1e11;
            
            % scan outputs
            %self.out.phi_meas = 0.0;
            self.out.PDES = 0.0;
            self.out.PACT = 0.0;
            self.out.POC = 0.0;
            
            % fit results
            self.fit.range = [];
            self.fit.X = [];
            self.fit.phi_meas = 0.0;
            self.fit.A = 0.0;
            self.fit.B = 0.0;
            self.fit.dE = [];
            self.fit.E0 = 0.0;
            self.fit.C = 0.0;

            self.update_op_point();
            
            % fake phase error if this is a simulated scan
            self.sim_err = 80.0*randn();
            
        end
        
        % initializes arrays for storing measurement data
        % should be called after self.in is fully configured
        function init_msmt(self)
            self.msmt.PHI     = zeros(1, self.in.N_steps);
            self.msmt.X       = zeros(1, self.in.N_steps);
            self.msmt.X_err   = zeros(1, self.in.N_steps);
            self.msmt.dE      = zeros(1, self.in.N_steps);
            self.msmt.dE_err  = zeros(1, self.in.N_steps);
        end
   
        function get_beam_rate(self)
            f = lcaGetSmart('EVNT:SYS1:1:BEAMRATE');
            if isnan(f), f = 0; end
            self.beam.f = f;
        end
        
        function get_bunch_charge(self)
            self.beam.N_elec = lcaGetSmart('BPMS:IN10:221:TMIT1H');
            Q = 1.6e-19 * self.beam.N_elec / 1e-12;
            if isnan(Q), Q = 0; end
            self.beam.Q = Q;
        end
        
        function get_beam_design_energy(self)
            E = lcaGetSmart(self.bend_BACT_PVs(self.linac+1));
            if isnan(E), E = 0; end
            self.beam.E_design = E;
        end

        function get_BPM(self)
            self.BPM = self.bpms(self.linac+1);
            self.eta = self.etas(self.linac+1);
        end

        function [PDES, PACT, POC] = get_phase_settings(self)
            switch self.linac
                case 0
                    PDES = lcaGetSmart(self.PV_klys_PDES);
                    PACT = lcaGetSmart(self.PV_wvgPACT);
                    POC = lcaGetSmart(self.PV_refpoc);
                case 1
                    [PACT, ~, ~, ~, KPHR, GOLD] = control_phaseGet(self.klys_str);
                    PDES = lcaGetSmart(self.PV_SSSB_PDES);
                    POC = KPHR;
                case {2,3}
                    [PACT, PDES, ~, ~, KPHR, GOLD] = control_phaseGet(self.klys_str);
                    POC = GOLD;
            end
        end

        function [ctl, rbv, poc] = get_phase_setting_desc(self)
            switch self.linac
                case 0
                    ctl = self.PV_klys_PDES;
                    rbv = self.PV_wvgPACT;
                    poc = self.PV_refpoc;
                case 1
                    ctl = self.PV_SSSB_PDES;
                    rbv = sprintf('%s (delta)', self.PV_klys_KPHR);
                    poc = self.PV_klys_GOLD;
                case {2,3}
                    ctl = self.PV_klys_PDES;
                    rbv = self.PV_klys_PHAS;
                    poc = self.PV_klys_GOLD;
            end
        end
        
        % wrapper that grabs BPM+dispersion, rep rate, bunch charge and energy
        function update_op_point(self)
            self.get_BPM();
            self.get_beam_rate();
            self.get_bunch_charge();
            self.get_beam_design_energy();
            
            self.PV_X = sprintf('%s:%s', self.BPM, 'X');
            self.PV_TMIT = sprintf('%s:%s', self.BPM, 'TMIT');
            
            % % need to add event code '57' for SLC BPMs coming through AIDA
            % if self.linac == 3, self.PV_X = sprintf('%s57', self.PV_X); end
            
            % also need to monkey these back into cell arrays for lcaMonitor
            self.PV_X = {sprintf('%s', self.PV_X)};
            self.PV_TMIT = {sprintf('%s', self.PV_TMIT)};
            
            self.msmt.TMIT_thr_lo = 0.8 * self.beam.N_elec;
            self.msmt.TMIT_thr_hi = 1.1 * self.beam.N_elec;
        end
        
        % disable relevant downstream longitudinal feedbacks for the scan
        function disable_feedbacks(self)
            if self.in.simulation, return; end

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
            lcaPutSmart(sprintf('KLYS:LI10:%d1:SFB_PDIS', self.klys), state);
        end
        
        % compute the range of phase settings given range + N steps
        function compute_scan_range(self)
            N = self.in.N_steps;
            dp = self.in.dPhi;
                        
            % for L1 phase scans we manipulate the KPHR directly
            self.in.p0 = 0;
            if self.linac == 0
                % to do: autodetect L0-A/B phases?
                self.in.p0 = 0;
            elseif self.linac == 1
                % self.in.p0 = self.in.KPHR;
                self.in.p0 = lcaGetSmart(self.PV_klys_KPHR);
            end

            uncorrected_range = linspace(self.in.p0-dp, self.in.p0+dp, N);
            self.in.range = self.in.sbst_offset + self.in.klys_offset + uncorrected_range;
            
            if self.in.zigzag
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
                self.undo.SSSB.ADES1 = lcaGetSmart('KLYS:LI11:11:SSSB_ADES');
                self.undo.SSSB.ADES2 = lcaGetSmart('KLYS:LI11:21:SSSB_ADES');
                self.undo.SSSB.PDES1 = lcaGetSmart('KLYS:LI11:11:SSSB_PDES');
                self.undo.SSSB.PDES2 = lcaGetSmart('KLYS:LI11:21:SSSB_PDES');
            end
            self.undo.PDES = self.in.PDES;
            self.undo.POC = self.in.POC;
        end

        % set the target station (in L1) PDES to 0
        % should be called before 
        function set_L1_chirp(self, cdes)
            if self.in.simulation, return; end
            lcaPutSmart(self.PV_SSSB_PDES, cdes);
            % necessary? should have no effect since SLC PDES isn't used
            [L1_pact, L1_pok] = control_phaseSet(handles.data.name, cdes, 1, 1);
        end
        
        % subroutine to correct energy in L1 after cresting the target station before phase scans
        function L1_energy_correction(self)
            if self.in.simulation, return; end
            
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
            if self.in.simulation, pause(0.5); PACT = p; phase_ok = true; return; end

            % L0: set KLYS PDES, report ACCL WVG phase
            if self.linac == 0
                lcaPutSmart(self.PV_klys_PDES, p)
                phase_ok = 1
                PACT = lcaGetSmart(self.PV_wvgPACT)
            
            % L1: set klystron KPHR, report KPHR
            elseif self.linac == 1
                [~, phase_ok] = control_phaseSet(self.klys_str, p, 0,0, 'KPHR');
                PACT = lcaGetSmart(self.PV_KPHR);
            
            % L2, L3: set klystron PDES, report PACT <--- slow!!!
            else
                [PACT, phase_ok] = control_phaseSet(self.klys_str, p, 1, 1);
            end
        end
        
        % sets the target klystron phase to self.in.range(I_STEP)
        function step_phase(self)
            [PACT, phase_ok] = self.set_phase(self.in.range(self.I_STEP));
            % subtracts off the initial KPHR value for sensible plot axes
            self.msmt.PHI(self.I_STEP) = PACT - self.in.p0;
        end

        % reset the klystron phase to the first scan step
        function reset_phase(self)
            [PACT, phase_ok] = self.set_phase(self.in.range(1));
        end
        
        % correct target klystron phase based on the measured error
        function apply_phase_correction(self)

            % apply phase correction
            % L0: REFPOC is subtracted in the feedback -> ADD measured error
            % L1: subtract measured error from KPHR
            % L2-L3: reGOLD using the SCP, need to PDES=0 & trim as well
            switch self.linac
                case 0
                    poc_zero = wrapTo180(self.in.POC + self.fit.phi_meas);
                    lcaPutSmart(self.PV_refpoc, poc_zero);
                
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
            lcaPutSmart(self.PV_phase0, self.fit.phi_meas)
            lcaPutSmart(self.PV_goldchg, poc_zero);
            scan_ts = (now - self.EPICS_t0) * 24*60*60
            lcaPutSmart(self.PV_goldts, scan_ts);
            lcaPutSmart(self.PV_phasets, scan_ts);
        end
        
        % apply self.undo settings to revert the phase scan
        function revert_phase_settings(self)
            switch self.linac
                case 0
                    lcaPutSmart(self.PV_klys_PDES, self.undo.PDES);
                    lcaPutSmart(self.PV_refpoc, self.undo.POC);
                case 1
                    lcaPutSmart('KLYS:LI11:11:SSSB_ADES', self.undo.SSSB.ADES1);
                    lcaPutSmart('KLYS:LI11:21:SSSB_ADES', self.undo.SSSB.ADES2);
                    lcaPutSmart('KLYS:LI11:11:SSSB_PDES', self.undo.SSSB.PDES1);
                    lcaPutSmart('KLYS:LI11:21:SSSB_PDES', self.undo.SSSB.PDES2);
                    lcaPutSmart(self.PV_KPHR, self.undo.POC);
                case {2,3}
                    [~, ~] = control_phaseSet(self.klys_str, self.undo.PDES, 1, 1);
                    lcaPutSmart(self.PV_klys_GOLD, self.undo.POC)
            end
        end
        
        % collect & average self.in.N_samples of BPM data from the appropriate BPM
        function bpm_data = get_bpm_data(self)
            bpm_data = zeros(self.in.N_samples, 2);
            
            if self.in.simulation, bpm_data = self.mock_bpm_data(); return; end

            lcaSetMonitor(self.PV_X);
            for i = 1:self.in.N_samples
                
                lcaNewMonitorWait(self.PV_X);
                %pause(0.1); % maybe needed?, not clear how monitorWait plays w/ AIDA
                xpos = lcaGetSmart(self.PV_X);
                tmit = lcaGetSmart(self.PV_TMIT);
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
            phi_i = self.in.range(self.I_STEP);
            sim_pos = cosd(phi_i - self.in.p0 + self.sim_err);
            jitter = 0.02*randn();
            bpm_data(:, 1) = A0*(sim_pos + jitter);
            bpm_data(:, 2) = 2e10;
        end
        
        % get position/energy & std dev of both
        function position_energy_msmt(self)
            bpm_data = self.get_bpm_data();
            
            self.msmt.X(self.I_STEP)     = nanmean(bpm_data(:,1));
            self.msmt.X_err(self.I_STEP) = nanstd(bpm_data(:,1));
            self.msmt.TMIT(self.I_STEP)  = nanmean(bpm_data(:,2));
            
            dE_dx = self.beam.E_design / self.eta;
            self.msmt.dE(self.I_STEP)     = dE_dx * self.msmt.X(self.I_STEP);
            self.msmt.dE_err(self.I_STEP) = dE_dx * self.msmt.X_err(self.I_STEP);
        end

        function plot_phase_scan(self, ax, show_fit)
            % generate final phase scan plot for logbook
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
        
    end
end
