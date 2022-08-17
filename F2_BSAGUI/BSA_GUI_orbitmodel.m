classdef BSA_GUI_orbitmodel < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        app % BPM_Orbit app object
        BG_mdl % BSA_GUI model object holding BSA GUI data and state
        X % Struct holding X bpm data
        Y % Struct holding Y bpm data
        TMIT % Struct holding TMIT data
        t_stamp % single time stamp label for data
        time_stamps % time array for each pulse
        hxr_pulses % indices for hxr pulses in dual energy mode
        sxr_pulses % indices for sxr pulses in dual energy mode
        hxr_pulsenum % most recently viewed hxr pulse
        sxr_pulsenum % most recently viewed sxr pulse
        selectedBeamLine % HXR or SXR as selected by user
        pulses 
        pulse_num % current pulse number
        play_rate % rate at which new pulses are presented in continuous mode
    end
    
    events (NotifyAccess = private)
        plotOrbit 
        processBPMS
    end
    
    methods
        function orbit_mdl = BSA_GUI_orbitmodel(app, BG_mdl)
            % constructor for orbit model object
            
            % Point at originating app and BSA GUI model
            orbit_mdl.app = app;
            orbit_mdl.BG_mdl = BG_mdl;
            
            % time stamp gymnastics due to different BSA file formats over
            % time
            if isempty(BG_mdl.time_stamps)
                t = BG_mdl.t_stamp;
            else
                t = real(BG_mdl.time_stamps) + imag(BG_mdl.time_stamps)*10^-9;
            end
            if isempty(t)
                orbit_mdl.t_stamp = BG_mdl.fileName;
            else
                orbit_mdl.t_stamp = t(length(t));
            end
            orbit_mdl.time_stamps = t;
            
            % initlialize app properties
            orbit_mdl.play_rate = 1/10;
            orbit_mdl.hxr_pulsenum = 1;
            orbit_mdl.sxr_pulsenum = 1;
            
            beamLineOpts = {'HXR', 'SXR'};
            orbit_mdl.selectedBeamLine = beamLineOpts{BG_mdl.isSxr + 1};
             
        end
        
        function orbitInit(orbit_mdl)
            % execute initial bpm data processing and plotting
            orbitBPMS(orbit_mdl, orbit_mdl.BG_mdl);
            notify(orbit_mdl, 'plotOrbit');
        end
        
        function beamLineChanged(orbit_mdl, beamLine, pulsenum)
            % Reset data for newly selected beamline
            switch beamLine
                case 'HXR'
                    orbit_mdl.hxr_pulsenum = pulsenum;
                case 'SXR'
                    orbit_mdl.sxr_pulsenum = pulsenum;
            end
            orbit_mdl.selectedBeamLine = beamLine;
            
            % bpm data must be reprocessed and replotted
            orbitBPMS(orbit_mdl, orbit_mdl.BG_mdl);
            notify(orbit_mdl, 'plotOrbit');
        end
        
        function orbitBPMS(orbit_mdl, BG_mdl)
            % Organize data into X, Y, and TMIT information


            
            % if BR edef, must separate out HXR/SXR names and pulses
            if BG_mdl.isBR && ~strcmp(BG_mdl.sys, 'SYS1')
                [hxr_idx, sxr_idx, ~] = splitNames(BG_mdl);
                %identify HXR pulse or SXR pulse
                [orbit_mdl.hxr_pulses, orbit_mdl.sxr_pulses] = splitPulses(BG_mdl);
                switch orbit_mdl.selectedBeamLine
                    case 'HXR'
                        names = BG_mdl.ROOT_NAME(hxr_idx);
                        orbit_mdl.pulses = orbit_mdl.hxr_pulses;
                        orbit_mdl.pulse_num = orbit_mdl.hxr_pulsenum; % keep track of user selected pulse num
                    case 'SXR'
                        names = BG_mdl.ROOT_NAME(sxr_idx);
                        orbit_mdl.pulses = orbit_mdl.sxr_pulses;
                        orbit_mdl.pulse_num = orbit_mdl.sxr_pulsenum; % keep track of user selected pulse num
                end
            else
                names = BG_mdl.ROOT_NAME;
                if ~BG_mdl.acqSCP
                    names = names(~BG_mdl.isSCP);
                    orbit_mdl.pulses = 1:size(BG_mdl.the_matrix,2);
                else
                    orbit_mdl.pulses = BG_mdl.hasSCP;
                end
                orbit_mdl.pulse_num = 1;
            end
            
            % row indices of selected bpms
            orbit_mdl.X.bpm_idx = find(contains(BG_mdl.ROOT_NAME,names) & contains(BG_mdl.ROOT_NAME,'BPMS') & endsWith(BG_mdl.ROOT_NAME,'X'));
            orbit_mdl.Y.bpm_idx = find(contains(BG_mdl.ROOT_NAME, names) & contains(BG_mdl.ROOT_NAME,'BPMS') & endsWith(BG_mdl.ROOT_NAME,'Y'));
            orbit_mdl.TMIT.bpm_idx = find(contains(BG_mdl.ROOT_NAME, names) & contains(BG_mdl.ROOT_NAME,'BPMS') & endsWith(BG_mdl.ROOT_NAME,'TMIT'));
            
            % names of selected bpms
            orbit_mdl.X.bpm_names = BG_mdl.ROOT_NAME(orbit_mdl.X.bpm_idx);
            orbit_mdl.Y.bpm_names = BG_mdl.ROOT_NAME(orbit_mdl.Y.bpm_idx);
            orbit_mdl.TMIT.bpm_names = BG_mdl.ROOT_NAME(orbit_mdl.TMIT.bpm_idx);
            
            % data for selected bpms
            orbit_mdl.X.bpm_data = full(BG_mdl.the_matrix(orbit_mdl.X.bpm_idx,orbit_mdl.pulses));
            orbit_mdl.Y.bpm_data = full(BG_mdl.the_matrix(orbit_mdl.Y.bpm_idx,orbit_mdl.pulses));
            orbit_mdl.TMIT.bpm_data = full(BG_mdl.the_matrix(orbit_mdl.TMIT.bpm_idx,orbit_mdl.pulses));
            
            % y-axis label
            orbit_mdl.X.label = 'X Position (mm)';
            orbit_mdl.Y.label = 'Y Position (mm)';
            orbit_mdl.TMIT.label = 'TMIT';
            
            notify(orbit_mdl, 'processBPMS');
        end
        
    end
end

