% object to handle input/output/config parameters of a phase scan
% author: Zack Buschmann <zack@slac.stanford.edu>

classdef F2_phasescan < handle
    
    properties (Constant)
        
        % EPICS record names for each spectrometer BPM
        bpms = [ ...
            "BPMS:IN10:731", "BPMS:LI11:333" "BPMS:LI14:801" "BPMS:LI20:2050" ...
            ];
        
        % bend magnet BACT values for design energy milestones
        bend_BACT_PVs = [ ...
            "BEND:IN10:751:BACT", "BEND:LI11:331:BACT" "BEND:LI14:720:BACT" "LI20:LGPS:1990:BACT" ...
            ];
        
        % hardcoded dispersion at each BPM
        % TO DO: grab this from the model server, once such a thing exists
        etas = 1000 * [-0.10 -0.2511 -0.4374 0.1207]
        
    end
    
    properties
        linac = 0;         % linac number (1,2,3)
        sector = 10;       % sector number (10-19)
        klys = 3;          % klystron number (1-8)
        klys_str = 'ss-k'; % klystron ID string
        start_time         % scan start time
        
        SUCCESS = false;
        ABORTED = false;
        
        beam = struct;
        in = struct;
        msmt = struct;
        out = struct;
        fit = struct;
        undo = struct;
    end

    methods
        
        % constructor
        function self = F2_phasescan(linac, sector, klys)
            
            % global scan setup
            self.linac = linac;
            self.sector = sector;
            self.klys = klys;
            self.klys_str = sprintf('%d-%d', self.sector, self.klys);
            self.start_time = datetime('now');
            self.start_time.Format = 'dd-MMM-uuuu hh:mm:ss';
            
            % current beam parameters
            self.beam.N_elec = 0.0;
            self.beam.Q = 0.0;
            self.beam.f = 0.0;
            self.beam.E_design = 0.0;
            self.beam.BPM = '';
            self.beam.eta = 0.0;
            self.update_beam_status();
            
            % input configuration
            self.in.range = [];
            self.in.dPhi = 0;
            self.in.N_steps = 0;
            self.in.N_samples = 0;
            self.in.klys_offset = 0;
            self.in.sbst_offset = 0;
            self.in.zigzag = false;
            self.in.simulation = false;
            self.in.phi_set = 0.0;
            self.in.PDES = 0.0;
            self.in.PHAS = 0.0;
            self.in.GOLD = 0.0;
            self.in.KPHR = 0.0;
            
            self.undo.PDES = 0.0;
            self.undo.PHAS = 0.0;
            self.undo.GOLD = 0.0;
            self.undo.KPHR = 0.0;
            self.undo.SSSB = struct;
            self.undo.SSSB.ADES1 = 0.0;
            self.undo.SSSB.ADES2 = 0.0;
            self.undo.SSSB.PDES1 = 0.0;
            self.undo.SSSB.PDES2 = 0.0;
            
            % scan measurement data
            self.msmt.PHI = [];
            self.msmt.X = [];
            self.msmt.X_err = [];
            self.msmt.dE = [];
            self.msmt.dE_err = [];
            
            % scan outputs
            self.out.phi_meas = 0.0;
            self.out.PDES = 0.0;
            self.out.PHAS = 0.0;
            self.out.GOLD = 0.0;
            self.out.KPHR = 0.0;
            
            % fit results
            self.fit.range = [];
            self.fit.X = [];
            self.fit.phi_meas = 0.0;
            self.fit.A = 0.0;
            self.fit.B = 0.0;
            self.fit.dE = [];
            self.fit.E0 = 0.0;
            self.fit.C = 0.0;
            
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
            self.beam.eta = self.etas(self.linac+1);
        end
        
        % wrapper that grabs rep rate, bunch charge and energy
        function update_beam_status(self)
            self.beam.BPM = self.bpms(self.linac+1);
            self.get_beam_rate();
            self.get_bunch_charge();
            self.get_beam_design_energy();
        end
        
        % disable relevant downstream longitudinal feedbacks
        % L0 scan: disable DL10E, BC11E, BC11BL
        % L1 scan: disable BC11E, BC11BL
        % L2 scan: disable BC14E, BC14BL
        % L3 scan: disable BC20E
        function disable_feedbacks(self)
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
        
        % compute the range of phase settings given range + N steps
        function compute_scan_range(self)
            N = self.in.N_steps;
            dp = self.in.dPhi;
                        
            % for L1 phase scans we manipulate the KPHR directly
            p0 = self.in.PDES;
            if self.linac == 1, p0 = self.in.KPHR; end

            self.in.range = ...
                self.in.sbst_offset + self.in.klys_offset + linspace(p0-dp, p0+dp, N);
            
            if self.in.zigzag
                odd_steps = find(bitget(1:N, 1));
                even_steps = find(~bitget(1:N, 1));
                midpt = round(numel(odd_steps)/2);
                mask = [odd_steps(midpt+1:end) flip(even_steps,2) odd_steps(1:midpt)];
                self.in.range = self.in.range(mask');
            end
        end
        
        % subroutine to correct energy in L1 before phase scans
        function SSSB_energy_correction(self)
            
            pos_tolerance = 0.1;   % BPM tolerance in mm
            max_iters     = 1000;  % iteration cap to prevent runaway
            
            if strcmp(self.klys_str, '11-1')
                klys = 21;
                klys_str = '11-2';
            else
                klys = 11;
                klys_str = '11-1';
            end
            
            fprintf('Correcting L1 energy with %s...', klys_str);
            
            PV_ADES = sprintf('KLYS:LI11:%d1:SSSB_ADES', klys);
            ADES_init = lcaGetSmart(PV_ADES);
            ADES_current = ADES_init;
            
            [xraw, ~] = self.get_BPM_data();
            x = nanmean(xraw);
            
            i = 0;
            while (i < max_iters) && (abs(x) >= pos_tolerance)
                i = i + 1;
                
                % default step of 0.1MeV, 0.5MeV when further off-energy
                % dispersion is negative at BC11, so sign(x) <-> sign(dE)
                amp_step = 0.1;
                if abs(x) > 1.0, amp_step = 0.5; end
                lcaPutSmart(PV_ADES, ADES_current + sign(x)*amp_step);
                
                ADES_current = lcaGetSmart(PV_ADES);
                [xraw, ~] = self.get_BPM_data();
                x = nanmean(xraw);
            end
            
        end
        
        % set the scan target klystron's phase to 'p'
        % in L1 adjust KPHR directly, otherwise use PDES
        % TO DO: update for L0?
        function [PACT, phase_ok] = set_phase(self, p)
            if self.linac == 1
                [~, phase_ok] = control_phaseSet(self.klys_str, p, 0,0, 'KPHR');
                PV_KPHR = sprintf('LI%d:KLYS:%d1:KPHR', self.sector, self.klys);
                PACT = lcaGetSmart(PV_KPHR);
            else
                [PACT, phase_ok] = control_phaseSet(app.target.klys_str, p, 1, 1);
            end
        end
        
        % collect & average self.in.N_samples of BPM data from the appropriate BPM
        function get_bpm_data(self)
        end 
        
        % calculate beam phase error
        % fits BPM data to Acos(phi+psi) + B using linear least-squares
        function self = beam_phase_fit(self)
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
            
            dE_dx = self.E_design / self.eta;
            self.fit.dE = dE_dx * self.fit.X;
            self.fit.E0 = dE_dx * self.fit.A;
            self.fit.C = dE_dx * self.fit.B;
        end
        
    end
end
