classdef BSA_GUI_orbitmodel < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        app % BPM_Orbit app object
        play_rate = 0.1 % rate at which new pulses are presented in continuous mode
        enabled = {} % list of bpms user wants to see
        disabled = {} % list of bpms user does not want to see
        all_names % list of all available bpms
        orbits = {} % list of orbit objects
        currentOrbit % pointer to the currently plotted orbit
        orbitIdx % index in orbits list of the current orbit
        orbitNameList = {} % name of orbits in orbit list
        fileName 
        BSAGUI % parent BSA GUI object
        showAve = 0 % flag to show the average and rms ov position vs z
        diffOrbitName = ''
    end
    
    events (NotifyAccess = public)
        plotOrbit 
        BPMSChanged
        newOrbit
        orbitLoaded
    end
    
    methods
        
        function orbit_mdl = BSA_GUI_orbitmodel(app, BG_mdl)
            % constructor for orbit model object
            
            % Point at originating app and BSA GUI model
            orbit_mdl.app = app;
            orbit_mdl.BSAGUI = BG_mdl;
            
        end
        
        function orbitInit(orbit_mdl)
            loadFromBSA(orbit_mdl, orbit_mdl.BSAGUI);
        end
        
        function loadFromBSA(orbit_mdl, BG_mdl)
            % time stamp gymnastics due to different BSA file formats over
            % time
            if isempty(BG_mdl.time_stamps)
                t = BG_mdl.t_stamp;
            else
                t = real(BG_mdl.time_stamps) + imag(BG_mdl.time_stamps)*10^-9;
            end
            if isempty(t)
                t = BG_mdl.fileName;
                t_stamp = BG_mdl.fileName;
            else
                t_stamp = datestr(lca2matlabTime(t(length(t))));
            end
            time_stamps = t;
            
            if isfield(BG_mdl, 'lcls')
                isLCLS = BG_mdl.isLCLS;
            else
                isLCLS = any(contains(BG_mdl.ROOT_NAME, 'PATT:SYS0:1:PULSEID'));
            end
            
            % if BR edef, must separate out HXR/SXR names and pulses
            if isLCLS && BG_mdl.isBR
                % split hxr and sxr names and pulses
                [hxr_idx, sxr_idx, ~] = splitNames(BG_mdl);
                [hxr_pulses, sxr_pulses] = splitPulses(BG_mdl);
                has_sxr = false;
                has_hxr = false;
                
                % create hxr and sxr orbits if there is data to do so
                if ~isempty(hxr_pulses)
                    hxr_names = BG_mdl.ROOT_NAME(hxr_idx);
                    hxr_data = BG_mdl.the_matrix(hxr_idx,:);
                    hxr_z = orbit_mdl.getZ(BG_mdl, hxr_names);
                    hxr_orbit = orbit(hxr_data, hxr_names, hxr_pulses, time_stamps(hxr_pulses), hxr_z);
                    orbit_mdl.orbits{end + 1} = hxr_orbit;
                    has_hxr = true;
                end
                if ~isempty(sxr_pulses)
                    sxr_names = BG_mdl.ROOT_NAME(sxr_idx);
                    sxr_data = BG_mdl.the_matrix(sxr_idx,:);
                    sxr_z = orbit_mdl.getZ(BG_mdl, sxr_names);
                    sxr_orbit = orbit(sxr_data, sxr_names, sxr_pulses, time_stamps(sxr_pulses), sxr_z);
                    orbit_mdl.orbits{end + 1} = sxr_orbit;
                    has_sxr = true;
                end
                %orbit_mdl.currentOrbit = orbit_mdl.orbits{1};
                
                % initialize name list
                has_both = has_hxr & has_sxr;
                if ~has_both
                    orbit_mdl.orbitNameList{end + 1} = sprintf('BSA-orbit-%s', t_stamp);
                else
                    orbit_mdl.orbitNameList{end + 1} = sprintf('HXR-BSA-orbit-%s', t_stamp);
                    orbit_mdl.orbitNameList{end + 1} = sprintf('SXR-BSA-orbit-%s', t_stamp);
                end
            else
                names = BG_mdl.ROOT_NAME;
                pulses = true(1, size(BG_mdl.the_matrix,2));
                z = orbit_mdl.getZ(BG_mdl, names);
                orbit_mdl.orbits{end + 1} = orbit(BG_mdl.the_matrix, names, pulses, time_stamps, z);
                orbit_mdl.orbitNameList{end + 1} = sprintf('BSA-orbit-%s', t_stamp);
            end
                        
            bpms = BG_mdl.ROOT_NAME(contains(BG_mdl.ROOT_NAME, 'BPMS'));
            [prim,micro,unit] = model_nameSplit(bpms);
            bpms = unique(strcat(prim,':', micro, ':', unit), 'stable');
            
            orbit_mdl.all_names = unique([orbit_mdl.all_names; bpms], 'stable');
            orbit_mdl.enabled = orbit_mdl.all_names(~contains(orbit_mdl.all_names, orbit_mdl.disabled));
            
            if isempty(orbit_mdl.currentOrbit)
                orbit_mdl.orbitIdx = 1;
                orbit_mdl.currentOrbit = orbit_mdl.orbits{orbit_mdl.orbitIdx};
                notify(orbit_mdl, 'newOrbit');
                notify(orbit_mdl, 'plotOrbit');
            end
            notify(orbit_mdl, 'orbitLoaded');
        end
        
        function loadFromOrbit(orbit_mdl, dataStruct)
            names = strrep(string(dataStruct.names), ' ', '');
            X_names = strcat(names, ':X');
            Y_names = strcat(names, ':Y');
            TMIT_names = strcat(names, ':TMIT');
            names = [X_names; Y_names; TMIT_names];
            
            data = [dataStruct.x'; dataStruct.y'; dataStruct.tmit'];

            refOrbit = orbit(data, names, 1, dataStruct.ts, dataStruct.z);
            orbit_mdl.orbits{end+1} = refOrbit;
            orbit_mdl.orbitNameList{end + 1} = sprintf('orbit-%s', dataStruct.ts);
            notify(orbit_mdl, 'orbitLoaded');
        end
        
        function updatePulseNum(orbit_mdl, pulsenum)
            orbit_mdl.currentOrbit = updatePulse(orbit_mdl.currentOrbit, pulsenum);
            notify(orbit_mdl, 'plotOrbit');
        end
        
        function changeOrbit(orbit_mdl, newOrbit)
            if orbit_mdl.orbitIdx ~= 0
                orbit_mdl.orbits{orbit_mdl.orbitIdx} = orbit_mdl.currentOrbit;
            else
                orbit_mdl.diffOrbitName = '';
            end
            orbit_mdl.orbitIdx = contains(orbit_mdl.orbitNameList, newOrbit);
            orbit_mdl.currentOrbit = orbit_mdl.orbits{orbit_mdl.orbitIdx};
            notify(orbit_mdl, 'newOrbit');
            notify(orbit_mdl, 'plotOrbit');
        end
        
        function differenceOrbit(orbit_mdl, orbitA_name, orbitB_name, diffPulse)
            if nargin < 4, diffPulse = 1; end
            
            orbitA = orbit_mdl.orbits{contains(orbit_mdl.orbitNameList, orbitA_name)};
            orbitB = orbit_mdl.orbits{contains(orbit_mdl.orbitNameList, orbitB_name)};
            
            % find common bpms between the 2 orbits
            % first, find where in this orbit are the orbitB bpms
            X_AinB = contains(orbitA.X.bpm_names, orbitB.X.bpm_names);
            Y_AinB = contains(orbitA.Y.bpm_names, orbitB.Y.bpm_names);
            TMIT_AinB = contains(orbitA.TMIT.bpm_names, orbitB.TMIT.bpm_names);
            
            % second, find where in orbitB are this orbit's bpms
            X_BinA = contains(orbitB.X.bpm_names, orbitA.X.bpm_names);
            Y_BinA = contains(orbitB.Y.bpm_names, orbitA.Y.bpm_names);
            TMIT_BinA = contains(orbitB.TMIT.bpm_names, orbitA.TMIT.bpm_names);
            
            % collect common names
            X_names = orbitA.X.bpm_names(X_AinB);
            Y_names = orbitA.Y.bpm_names(Y_AinB);
            TMIT_names = orbitA.TMIT.bpm_names(TMIT_AinB);
            names = [X_names; Y_names; TMIT_names];
            
            % take the difference between the 2 orbits from common bpms
            X_data = orbitA.X.bpm_data(X_AinB,:) - orbitB.X.bpm_data(X_BinA, diffPulse);
            Y_data = orbitA.Y.bpm_data(Y_AinB,:) - orbitB.Y.bpm_data(Y_BinA, diffPulse);
            TMIT_data = orbitA.TMIT.bpm_data(TMIT_AinB,:) - orbitB.TMIT.bpm_data(TMIT_BinA, diffPulse);
            data = [X_data; Y_data; TMIT_data];
            
            % create an orbit object with the difference
            orbit_mdl.currentOrbit = orbit(data, names, true(1, sum(orbitA.pulses)), orbitA.time_stamps, orbitA.Z);
            orbit_mdl.orbitIdx = 0;
            orbit_mdl.diffOrbitName = orbitB_name;
            notify(orbit_mdl, 'newOrbit');
            notify(orbit_mdl, 'plotOrbit');
        end
        
        function diffFromCurrent(orbit_mdl)
            refOrbit = orbit_mdl.currentOrbit;
            orbit_mdl.orbits{end+1} = refOrbit;
            currentName = orbit_mdl.orbitNameList{orbit_mdl.orbitIdx};
            newName = sprintf('%s Pulse %d', orbit_mdl.orbitNameList{orbit_mdl.orbitIdx}, refOrbit.pulsenum);
            orbit_mdl.orbitNameList{end+1} = newName;
            differenceOrbit(orbit_mdl, currentName, newName, refOrbit.pulsenum);
        end
        
        function enableBPMS(orbit_mdl, pvs)
            orbit_mdl.enabled = [orbit_mdl.enabled; pvs'];
            orbit_mdl.disabled(contains(orbit_mdl.disabled, pvs)) = [];
            orbit_mdl.enabled = orbit_mdl.all_names(contains(orbit_mdl.all_names, orbit_mdl.enabled));
            notify(orbit_mdl, 'BPMSChanged');
            notify(orbit_mdl, 'plotOrbit');
        end
        
        function disableBPMS(orbit_mdl, pvs)
            orbit_mdl.disabled = [orbit_mdl.disabled; pvs'];
            orbit_mdl.enabled(contains(orbit_mdl.enabled, pvs)) = [];
            orbit_mdl.disabled = orbit_mdl.all_names(contains(orbit_mdl.all_names, orbit_mdl.disabled));
            notify(orbit_mdl, 'BPMSChanged');
            notify(orbit_mdl, 'plotOrbit');
        end
        
        function saveOrbit(orbit_mdl, saveas)
            bpms = orbit_mdl.currentOrbit.X.bpm_names;
            [prim,micro,unit] = model_nameSplit(bpms);
            bpms = unique(strcat(prim,':', micro, ':', unit), 'stable');
            z = reshape(orbit_mdl.currentOrbit.Z, size(bpms));
            use = contains(bpms, orbit_mdl.enabled) .* z ~= 0;
            data.names = char(bpms(use));
            pulsenum = orbit_mdl.currentOrbit.pulsenum;
            data.x = reshape(orbit_mdl.currentOrbit.X.bpm_data(use, pulsenum), 1, []);
            data.y = reshape(orbit_mdl.currentOrbit.Y.bpm_data(use, pulsenum), 1, []);
            data.tmit = reshape(orbit_mdl.currentOrbit.TMIT.bpm_data(use, pulsenum), 1, []);
            data.z = z;
            data.x_rms = zeros(1, length(data.x));
            data.y_rms = zeros(1, length(data.y));
            data.tmit_rms = zeros(1, length(data.tmit));
            data.x_severity = zeros(1, length(data.x));
            data.y_severity = zeros(1, length(data.y));
            data.tmit_severity = zeros(1, length(data.tmit));
            
            
            data.ts = datestr(lca2matlabTime(orbit_mdl.currentOrbit.time_stamps(orbit_mdl.currentOrbit.pulsenum)));
            [fname, pathName]=util_dataSave(data, 'orbit', [] , data.ts, saveas);
            
            fprintf('file saved to %s %s', pathName, fname)
            
            orbit_mdl.fileName = fname;
        end
        
        
    end
    
    methods(Static)
        function z_pos = getZ(BG_mdl, names)
            z_pos = BG_mdl.z_positions(contains(BG_mdl.ROOT_NAME, names));
        end
    end
end

