classdef orbit
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        X
        Y
        TMIT
        Z
        time_stamps
        pulses
        pulsenum = 1
    end
    
    methods
        function obj = orbit(data, names, pulses, time_stamps, z_pos)
            % Organize data into X, Y, and TMIT information
            
            % row indices of selected bpms
            X.bpm_idx = find(startsWith(names,'BPMS') & endsWith(names,'X'));
            Y.bpm_idx = find(startsWith(names,'BPMS') & endsWith(names,'Y'));
            TMIT.bpm_idx = find(startsWith(names,'BPMS') & endsWith(names,'TMIT'));
            
            % names of selected bpms
            X.bpm_names = names(X.bpm_idx);
            Y.bpm_names = names(Y.bpm_idx);
            TMIT.bpm_names = names(TMIT.bpm_idx);
            
            % data for selected bpms
            X.bpm_data = full(data(X.bpm_idx, pulses));
            Y.bpm_data = full(data(Y.bpm_idx, pulses));
            TMIT.bpm_data = full(data(TMIT.bpm_idx, pulses));
            
            % rms of orbit data
            X.mean = util_meanNan(X.bpm_data, 2);
            Y.mean = util_meanNan(Y.bpm_data, 2);
            TMIT.mean= util_meanNan(TMIT.bpm_data, 2);
            
            % rms error of orbit data
            X.rms_error = util_stdNan(X.bpm_data, 1, 2);
            Y.rms_error = util_stdNan(Y.bpm_data, 1, 2);
            TMIT.rms_error = util_stdNan(TMIT.bpm_data, 1, 2);
            
            % y-axis label
            X.label = 'X Position (mm)';
            Y.label = 'Y Position (mm)';
            TMIT.label = 'TMIT';
            obj.X = X;
            obj.Y = Y;
            obj.TMIT = TMIT;
            obj.Z = z_pos(X.bpm_idx);
            obj.pulses = pulses;
            obj.time_stamps = time_stamps;
        end

        function obj = updatePulse(obj, pulsenum)
            obj.pulsenum = pulsenum; 
        end
        
    end
end

