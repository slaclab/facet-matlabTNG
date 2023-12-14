% object to handle input/output/config parameters of a phase scan
% author: Zack Buschmann <zack@slac.stanford.edu>

classdef F2_phasescan < handle
    
    properties
        linac = 0;         % linac number (1,2,3)
        klys_str = 'ss-k'; % klystron ID string
        start_time         % scan start time
        E_design = 0.0;    % beam design energy
        eta = 0.0;         % dispersion at spectrometer BPM
        f = 0.0;           % beam repetition rate
        
        SUCCESS = false;
        ABORTED = false;

        in = struct;
        msmt = struct;
        out = struct;
        fit = struct;
        undo = struct;
        
    end
    
    methods
        
        % constructor
        function self = F2_phasescan(linac, klys_str)
            
            % global scan setup
            self.linac = linac;
            self.klys_str = klys_str;
            self.start_time = datetime('now');
            self.start_time.Format = 'dd-MMM-uuuu hh:mm:ss';
            
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









