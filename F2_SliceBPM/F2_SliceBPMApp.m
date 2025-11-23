classdef F2_SliceBPMApp < handle
    events
        PVUpdated % PV object list notifies this event after each set of monitored PVs have finished updating
    end
    properties
        pvlist PV
        pvs
        guihan
        listeners
        slope
        intercept
        stopflag
        switch_acq = 'beam_on';
        %elogtext = 'Custom Values';
        debug_mode = false;

        raw_data_storage
        scan_positions    % Collimator positions for each scan step
        scan_transport_matrices
        
        xmean
        ymean
        xpmean
        ypmean
        TMITmean
        E0_BPM_plot

        x_std
        y_std
        xp_std
        yp_std
        TMIT_std
        
        % PV Filtering
        filter_config  % Struct to store parsed filter configuration
        filter_stats   % Struct to store filtering statistics

        end

    properties(Constant)
        tolerance_jaw = 0.2;
        tolerance_notch = 10;% YY: Notch is not that precise

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
    end
    
    methods
        
        function obj = F2_SliceBPMApp(apph)
            
            %addpath('../common/');
            %javaaddpath('/home/fphysics/aphoebe/gitwork/matlabTNG/common');
            
            % initialize object and add PVs to be monitored
            context = PV.Initialize(PVtype.EPICS) ;
            obj.pvlist=[...
                PV(context,'name',"NotchCol_Set",'pvname',"COLL:LI20:2069:MOTR",'monitor',true,'mode',"rw"); %Notch Collimator Read/Write
                PV(context,'name',"NotchCol_Readback",'pvname',"COLL:LI20:2069:MOTR.RBV",'monitor',true,'mode',"r") %Notch Collimator Readback
                PV(context,'name',"NotchColY_Set",'pvname',"COLL:LI20:2072:MOTR",'monitor',true,'mode',"rw"); %Notch Collimator Read/Write for elevation YY
                PV(context,'name',"NotchColY_Readback",'pvname',"COLL:LI20:2072:MOTR.RBV",'monitor',true,'mode',"r") %Notch Collimator Readback for elevation YY
                PV(context,'name',"NotchColYaw_Set",'pvname',"COLL:LI20:2073:MOTR",'monitor',true,'mode',"rw") %Notch Collimator Yaw Set
                PV(context,'name',"NotchColYaw_Readback",'pvname',"COLL:LI20:2073:MOTR.RBV",'monitor',true,'mode',"r") %Notch Collimator Yaw Readback
                PV(context,'name',"NotchCol_LLS",'pvname',"COLL:LI20:2069:MOTR.LLS",'monitor',true,'mode',"rw") %Notch Collimator LLS
                PV(context,'name',"NotchCol_HLS",'pvname',"COLL:LI20:2069:MOTR.HLS",'monitor',true,'mode',"rw") %Notch Collimator HLS
                PV(context,'name',"NotchCol_LLM",'pvname',"COLL:LI20:2069:MOTR.LLM",'monitor',true,'mode',"rw") %Notch Collimator Lower Limit Moniter
                PV(context,'name',"NotchCol_VAL",'pvname',"COLL:LI20:2069:MOTR.VAL",'monitor',true,'mode',"rw") %Notch Collimator Absalute Value
                PV(context,'name',"NotchCol_Calibration",'pvname',"COLL:LI20:2069:MOTR.SET",'monitor',true,'mode',"rw") % Notch Col Clibration Function(options are 'set' and 'use')
                PV(context,'name',"NotchCol_Active",'pvname',"COLL:LI20:2069:MOTR.MOVN",'monitor',true,'mode',"r") % reads weather or not the Notch col in moving
                PV(context,'name',"JawLeftCol_Set",'pvname',"COLL:LI20:2085:MOTR",'monitor',true,'mode',"rw") %Jaw Collimator Left Set
                PV(context,'name',"JawLeftCol_Readback",'pvname',"COLL:LI20:2085:MOTR.RBV",'monitor',true,'mode',"r") %Jaw Collimator Left Readback
                PV(context,'name',"JawCol_LLS",'pvname',"COLL:LI20:2085:MOTR.LLS",'monitor',true,'mode',"rw") %Jaw Collimator LLS
                PV(context,'name',"JawCol_HLS",'pvname',"COLL:LI20:2085:MOTR.HLS",'monitor',true,'mode',"rw") %Jaw Collimator HLS
                PV(context,'name',"JawCol_Active",'pvname',"COLL:LI20:2085:MOTR.MOVN",'monitor',true,'mode',"r") %checks to see if jaw col is moving
                ] ;
            pset(obj.pvlist,'debug',0) ;
            obj.pvs = struct(obj.pvlist);

            % Associate class with GUI 
            obj.guihan=apph;
            
            % Set GUI callbacks for PVs
            obj.pvs.NotchCol_Set.guihan = apph.NotchSet;
            obj.pvs.NotchCol_Readback.guihan = apph.NotchRead;
            obj.pvs.NotchColY_Set.guihan = apph.NotchYSet;
            obj.pvs.NotchColY_Readback.guihan = apph.NotchYRead;
            obj.pvs.NotchColYaw_Set.guihan = apph.YawSet;
            obj.pvs.NotchColYaw_Readback.guihan = apph.YawRead;
            obj.pvs.NotchCol_LLS.guihan = apph.NotchLLSLamp;
            obj.pvs.JawLeftCol_Set.guihan = apph.JawLeftSet;
            obj.pvs.JawLeftCol_Readback.guihan = apph.JawLeftRead;
            obj.pvs.NotchCol_HLS.guihan = apph.NotchHLSLamp;
            obj.pvs.JawCol_LLS.guihan = apph.JawLLSLamp;
            obj.pvs.JawCol_HLS.guihan = apph.JawHLSLamp;
         
            % Start listening for PV updates
            obj.listeners = addlistener(obj,'PVUpdated',@(~,~) obj.loop) ;
            run(obj.pvlist,true,0.1,obj,'PVUpdated');

            %define slope and intercept values from init scan
            obj.slope = lcaGet('SIOC:SYS1:ML00:AO798');
            obj.intercept = lcaGet('SIOC:SYS1:ML00:AO799');
            
            % YY: PV filtering
            % Initialize filter configuration
            obj.filter_config = struct(...
                'filters', [], ...           % Array of structs
                'monitor_pvs', {{}}, ...     % Cell array of PVs without limits
                'raw_text', '' ...            % Store the raw text for reference
                );
            
            obj.filter_stats = struct(...
                'total_shots', 0, ...
                'kept_shots', 0, ...
                'survival_rate', 100 ...
                );
            
            obj.guihan.SystemLog.Value = {''};
            
            obj.updateFilterStatus();
            
            obj.logMessage('Application initialized successfully');
            %obj.logMessage('Slope: %.6f, Intercept: %.4f mm', obj.slope, obj.intercept);
           
            
        end

        function aquireAndPlotBPMData (obj, step_index)  % ← CHANGED: ~ to step_index
            obj.stopflag = false;
            
            z_3156 = 1991.31;
            z_3218 = 1997.77;
            z = obj.guihan.ZLocation;
            
            % acq_time will be calculated below based on shots needed
            
            switch obj.switch_acq
                case 'beam_on'
                    PS_Q0D = control_magnetGet("LI20:LGPS:3141");
                    M = calcIPTransport(obj, PS_Q0D);
                case 'beam_off'
                    M =  rand(4,4);
            end
            
            M11 = M(1,1);
            M12 = M(1,2);
            M33 = M(3,3);
            M34 = M(3,4);
            
            %reserve edef's
            masks = {{'TS5'} {} {'DUMP_2_9' 'NO_EXT_ELEC'} {}};
            edef = eDefReserve('BPMdisperson');
            eDefParams(edef, 1, obj.guihan.ShotsperBuffer.Value, masks{:});
            
            % ===== REPLACED SECTION - ACTIVE MONITORING =====
            shots_needed = obj.guihan.ShotsperBuffer.Value;
            
            % Get beam rate
            try
                beam_rate = lcaGet('EVNT:SYS1:1:BEAMRATE');
                if isempty(beam_rate) || beam_rate <= 0
                    beam_rate = 10;
                end
            catch
                beam_rate = 10;
            end
            
            % Calculate shot-dependent wait time
            min_acq_time = shots_needed / beam_rate;
            acq_time = min_acq_time * 1.2 + 0.5;
            
            fprintf('Acquiring %d shots at %.1f Hz (wait: %.2f s)...\n', ...
                shots_needed, beam_rate, acq_time);
            
            obj.logMessage('Acquiring %d shots at %.1f Hz (wait: %.2f s)', ...
                shots_needed, beam_rate, acq_time);
            
            eDefOn(edef);
            
            % Active monitoring loop
            timer = tic;
            last_update = 0;
            
            while toc(timer) < acq_time
                % Check abort
                if obj.stopflag
                    fprintf('*** DATA ACQUISITION ABORTED ***\n');
                    obj.logMessage('*** ACQUISITION ABORTED ***\n');
                    eDefOff(edef);
                    eDefRelease(edef);
                    return;
                end
                
                drawnow;
                pause(1/beam_rate);
                
                % Check buffer
                try
                    buffer_count = lcaGet(sprintf('EDEF:SYS1:%d:CNT', edef));
                    if buffer_count >= shots_needed
                        fprintf('Buffer full (%d shots)\n', buffer_count);
                        obj.logMessage('Buffer full (%d shots)\n', buffer_count);
                        break;
                    end
                catch
                    buffer_count = -1;
                end
                
                % Progress
                elapsed = toc(timer);
                if (elapsed - last_update) >= 1.0
                    progress = elapsed / acq_time;
                    if buffer_count >= 0
                        fprintf('  %.1f/%.1f s (%.0f%%) - %d/%d shots\n', ...
                            elapsed, acq_time, progress*100, buffer_count, shots_needed);
                        obj.logMessage('  %.1f/%.1f s (%.0f%%) - %d/%d shots\n', ...
                            elapsed, acq_time, progress*100, buffer_count, shots_needed);
                    else
                        fprintf('  %.1f/%.1f s (%.0f%%)\n', ...
                            elapsed, acq_time, progress*100);
                        obj.logMessage('  %.1f/%.1f s (%.0f%%)\n', ...
                            elapsed, acq_time, progress*100);
                    end
                    last_update = elapsed;
                end
            end
            
            eDefOff(edef);
            fprintf('Acquisition complete (%.2f s)\n', toc(timer));
            obj.logMessage('Acquisition complete (%.2f s)\n', toc(timer));
            % ===== END REPLACED SECTION =====
            
            if strcmp(obj.switch_acq, 'beam_on')
                % Read the PVS from the buffer
                BPM_3156_x = lcaGetSmart(strcat(obj.pv_BPM_3156_x, 'HST', num2str(edef)))';
                BPM_3156_y = lcaGetSmart(strcat(obj.pv_BPM_3156_y, 'HST', num2str(edef)))';
                
                BPM_3218_x = lcaGetSmart(strcat(obj.pv_BPM_3218_x, 'HST', num2str(edef)))';
                BPM_3218_y = lcaGetSmart(strcat(obj.pv_BPM_3218_y, 'HST', num2str(edef)))';
                
                BPM_2445_x = lcaGetSmart(strcat(obj.pv_BPM_2445_x, 'HST', num2str(edef)))';
                BPM_2445_y = lcaGetSmart(strcat(obj.pv_BPM_2445_y, 'HST', num2str(edef)))';
                BPM_2445_TMIT = lcaGetSmart(strcat(obj.pv_BPM_2445_TMIT, 'HST', num2str(edef)))';
                
                EPICSpid = lcaGetSmart(strcat('PATT:SYS1:1:PULSEIDHST', num2str(edef)));
                
                % PV filtering

                user_pvs = obj.parseFilterList();
                user_pv_data = struct();
                
                for i = 1:length(user_pvs)
                    pv = user_pvs(i).pvname;
                    safe_name = regexprep(pv, '[:.-]', '_');
                    try
                        % Get Synchronized History Buffer
                        val = lcaGetSmart([pv, 'HST', num2str(edef)])';
                        % Safety: Ensure length matches BPM data
                        if length(val) ~= length(BPM_3156_x), val = nan(length(BPM_3156_x),1); end
                        user_pv_data.(safe_name) = val;
                    catch
                        user_pv_data.(safe_name) = nan(length(BPM_3156_x), 1);
                    end
                end











                
                % Energy for plotting
                E0_BPM = 10 + 0.0834 * (BPM_2445_x);
            else
                BPM_3156_x = randn(100,1);
                BPM_3156_y = randn(100,1);
                
                BPM_3218_x = randn(100,1);
                BPM_3218_y = randn(100,1);
                
                BPM_2445_x = linspace(1, 2, 100);
                BPM_2445_TMIT = randn(100,1);
                
                EPICSpid = randn(100,1);
                
                E0_BPM_plot_i = length(obj.E0_BPM_plot) + 1;
            end
            
            % obj.stopflag = false;  % ← CAN DELETE THIS DUPLICATE LINE
            
            %analyse
            ix = find(BPM_3156_x~=0);
            indE = ~isoutlier(BPM_2445_x(ix));
            ind_analyse = ix(indE);
            
            %calculate vectors
            x1 = BPM_3156_x;
            x2 = BPM_3218_x;
            
            y1 = BPM_3156_y;
            y2 = BPM_3218_y;
            
            %calculate prime values
            xp = (x2-M11.*x1)./M12;
            yp = (y2-M33.*y1)./M34;
            
            %BPM positions array for z and x (and y) positions
            z_BPM = [z_3156, z_3218];
            
            % Store raw data for later recalculation at different z
            raw_data = struct();
            raw_data.x1 = x1;
            raw_data.x2 = x2;
            raw_data.y1 = y1;
            raw_data.y2 = y2;
            raw_data.xp = xp(ind_analyse);
            raw_data.yp = yp(ind_analyse);
            raw_data.BPM_2445_x = BPM_2445_x;
            raw_data.BPM_2445_TMIT = BPM_2445_TMIT;
            raw_data.ind_analyse = ind_analyse;
            raw_data.z_BPM = z_BPM;
            raw_data.M = M;
            raw_data.user_pv_data = user_pv_data;
            
            % Initialize or append to storage
            if step_index == 1
                obj.raw_data_storage = {raw_data};
                obj.scan_positions = [];
                obj.scan_transport_matrices = {};
            else
                obj.raw_data_storage{end+1} = raw_data;
            end
            
            % Store current collimator position
            try
                caget(obj.pvs.JawLeftCol_Readback);
                obj.scan_positions(end+1) = obj.pvs.JawLeftCol_Readback.val{1};
            catch
                obj.scan_positions(end+1) = nan;
            end
            obj.scan_transport_matrices{end+1} = M;
            
            x_BPM = [x1, x1+xp*diff(z_BPM)];
            y_BPM = [y1, y1+yp*diff(z_BPM)];
            
            % Interpolate x and y positions over the specific z range
            x = interp1(z_BPM, x_BPM(ind_analyse, :)', z.Value);
            y = interp1(z_BPM, y_BPM(ind_analyse, :)', z.Value);
            xp = xp(ind_analyse);
            yp = yp(ind_analyse);
            
            BPM_2445_TMIT = BPM_2445_TMIT(ind_analyse);
            
            num_par_to_nC = 1.602e-10;
            
            %calculate means
            xmean_i = mean(x, 'omitnan') * 1000;
            ymean_i = mean(y, 'omitnan') * 1000;
            xpmean_i = mean(xp, 'omitnan') * 1000;
            ypmean_i = mean(yp, 'omitnan') * 1000;
            TMITmean_i = mean(BPM_2445_TMIT, 'omitnan') * num_par_to_nC;
            E0_BPM_plot_i = mean(E0_BPM(ind_analyse), 'omitnan');
            
            % store means
            obj.xmean(end+1) = xmean_i;
            obj.ymean(end+1) = ymean_i;
            obj.xpmean(end+1) = xpmean_i;
            obj.ypmean(end+1) = ypmean_i;
            obj.TMITmean(end+1) = TMITmean_i;
            obj.E0_BPM_plot(end+1) = E0_BPM_plot_i;
            
            % calculate and store STD
            obj.x_std(end+1) = std(x, "omitnan") * 1000;
            obj.y_std(end+1) = std(y, "omitnan") * 1000;
            obj.xp_std(end+1) = std(xp, "omitnan") * 1000;
            obj.yp_std(end+1) = std(yp, "omitnan") * 1000;
            obj.TMIT_std(end+1) = std(BPM_2445_TMIT, "omitnan") * num_par_to_nC;
            
            % dev from total mean
            x_deviation = obj.xmean - mean(obj.xmean, "omitnan");
            y_deviation = obj.ymean - mean(obj.ymean, "omitnan");
            xp_deviation = obj.xpmean - mean(obj.xpmean, "omitnan");
            yp_deviation = obj.ypmean - mean(obj.ypmean, "omitnan");
            TMIT_plot = obj.TMITmean;
            
            %plots
            errorbar(obj.guihan.xPlot, obj.E0_BPM_plot, x_deviation, obj.x_std, 'o', 'MarkerFaceColor','b');
            xlabel(obj.guihan.xPlot,'Slice Energy [GeV]')
            ylabel(obj.guihan.xPlot,'x-x_0 \mu m')
            drawnow;
            
            errorbar(obj.guihan.xpPlot, obj.E0_BPM_plot, xp_deviation, obj.xp_std, 'o','MarkerFaceColor','b');
            xlabel(obj.guihan.xpPlot,'Slice Energy [GeV]')
            ylabel(obj.guihan.xpPlot,'xp-xp_0 \mu m')
            drawnow;
            
            errorbar(obj.guihan.yPlot, obj.E0_BPM_plot, y_deviation, obj.y_std, 'o','MarkerFaceColor','b');
            xlabel(obj.guihan.yPlot,'Slice Energy [GeV]')
            ylabel(obj.guihan.yPlot,'y-y_0 \mu m')
            drawnow;
            
            errorbar(obj.guihan.ypPlot, obj.E0_BPM_plot, yp_deviation, obj.yp_std, 'o','MarkerFaceColor','b');
            xlabel(obj.guihan.ypPlot,'Slice Energy [GeV]')
            ylabel(obj.guihan.ypPlot,'yp-yp_0 \mu m')
            drawnow;
            
            errorbar(obj.guihan.tmitPlot, obj.E0_BPM_plot, TMIT_plot, obj.TMIT_std, 'o','MarkerFaceColor','b');
            xlabel(obj.guihan.tmitPlot,'Slice Energy [GeV]')
            ylabel(obj.guihan.tmitPlot,'Slice Charge [nC]')
            drawnow;
            
            % Release edef
            eDefRelease(edef);
        end

        
        function scanCols(obj)
            
            obj.guihan.ScaninProgressLabel.Visible = 'on';
            obj.logMessage('=== SCAN STARTED ===');
            
            % Get the current slope/intercept
            obj.slope = lcaGet('SIOC:SYS1:ML00:AO798');
            obj.intercept = lcaGet('SIOC:SYS1:ML00:AO799');
            obj.logMessage('Using slope: %.6f, intercept: %.4f mm', obj.slope, obj.intercept);

            
            startPos = obj.guihan.StartPos.Value;
            endPos = obj.guihan.EndPos.Value;
            nSteps = obj.guihan.NumSteps.Value;
            
            obj.logMessage('Scan: %.3f to %.3f mm in %d steps', startPos, endPos, nSteps);

            
            notch_col_pos = 'COLL:LI20:2069:MOTR';
            jaw_col_pos = 'COLL:LI20:2085:MOTR.VAL';
            
            % ===== OPTIMIZED TIMEOUTS =====
            maxWaitTime = 10;
            lcaSetTimeout(5);
            required_settle = 3;
            % ===== END OPTIMIZATIONS =====
            
            obj.stopflag = false;
            positions = linspace(startPos, endPos, nSteps);
            
            % Time the entire scan
            scan_start = tic;
            
            for i = 1:length(positions)
                if obj.stopflag
                    fprintf('Scan stopped at step %d\n', i);
                    obj.logMessage('*** SCAN ABORTED at step %d ***', i);
                    break;
                end
                drawnow;
                
                pos = positions(i);
                delta = pos * obj.slope + obj.intercept;
                
                % ===== MOVE COLLIMATORS =====
                fprintf('\n=== Step %d/%d: Moving to jaw=%.3f mm', i, nSteps, pos);
                
                step_start = tic;
                
                % Always move jaw
                lcaPut(jaw_col_pos, pos);
                
                % Move notch only if NOT in debug mode
                if ~obj.debug_mode
                    lcaPut(notch_col_pos, pos + delta);
                    fprintf(', notch=%.3f mm ===\n', pos + delta);
                    obj.logMessage(', notch=%.3f mm ===\n', pos + delta);
                else
                    fprintf(', notch NOT moved (DEBUG MODE) ===\n');
                    obj.logMessage(', notch NOT moved (DEBUG MODE) ===\n');
                end
                % ===== END MOVE COLLIMATORS =====
                
                % ===== OPTIMIZED SINGLE WAIT LOOP =====
                tStart = tic;
                settle_count = 0;
                
                while settle_count < required_settle
                    if obj.stopflag
                        disp('Scan Aborted Manually');
                        obj.logMessage('Scan aborted during settling');
                        return;
                    end
                    drawnow;
                    
                    % Check motion status
                    caget(obj.pvs.NotchCol_Active);
                    caget(obj.pvs.JawCol_Active);
                    notch_moving = obj.pvs.NotchCol_Active.val{1};
                    jaw_moving = obj.pvs.JawCol_Active.val{1};
                    
                    % Check position
                    caget(obj.pvs.JawLeftCol_Readback);
                    readback_jaw = obj.pvs.JawLeftCol_Readback.val{1};
                    in_tolerance = abs(readback_jaw - pos) < obj.tolerance_jaw;
                    
                    % Count consecutive settled readings
                    if ~notch_moving && ~jaw_moving && in_tolerance
                        settle_count = settle_count + 1;
                    else
                        settle_count = 0;
                    end
                    
                    % Timeout check
                    if toc(tStart) > maxWaitTime
                        warning('Timeout at step %d: target=%.3f, readback=%.3f', i, pos, readback_jaw);
                        obj.logMessage('Timeout at step %d: target=%.3f, readback=%.3f', i, pos, readback_jaw)
                        break;
                    end
                    
                    pause(0.1);
                end
                
                fprintf('  Collimators settled in %.1f s\n', toc(tStart));
                obj.logMessage('  Collimators settled in %.1f s\n', toc(tStart));
                % ===== END OPTIMIZED LOOP =====
                
                % Acquire data
                fprintf('  Acquiring data...\n');
                obj.logMessage('  Acquiring data...\n');
                obj.aquireAndPlotBPMData(i);
                
                fprintf('  Step %d completed in %.1f s\n', i, toc(step_start));
                obj.logMessage('  Step %d completed in %.1f s\n', i, toc(step_start));
            end
            
            fprintf('\n=== Scan Complete: Total time = %.1f s ===\n', toc(scan_start));
            obj.logMessage('\n=== Scan Complete: Total time = %.1f s ===\n', toc(scan_start));
            
            % Visual display
            obj.guihan.ScaninProgressLabel.Visible = 'off';
            obj.guihan.ScanFinishedLabel.Visible = 'on';
            pause(1);
            obj.guihan.ScanFinishedLabel.Visible = 'off';
            pause(0.2);
            obj.guihan.ScanFinishedLabel.Visible = 'on';
            pause(1);
            obj.guihan.ScanFinishedLabel.Visible = 'off';
        end
        
        
        
        
        
        
        
        
        
        
        function recalculateAndPlot(obj)
            % RECALCULATEANDPLOT Recompute Twiss parameters at new z location
            %   This function reprocesses all stored raw BPM data and recalculates
            %   the interpolated beam parameters at the z location specified in
            %   obj.guihan.ZLocation
            %   Now includes PV filtering support
            
            % Check if we have stored data
            if isempty(obj.raw_data_storage)
                errordlg('No scan data available. Please run a scan first.', 'No Data');
                return;
            end
            
            % Parse current filter configuration
            obj.parseAndStoreFilters();
            
            % Get new z location from GUI
            z_new = obj.guihan.ZLocation.Value;
            
            fprintf('\n=== Recalculating at z = %.3f m ===\n', z_new);
            fprintf('Using %d stored scan steps\n', length(obj.raw_data_storage));
            
            if obj.guihan.EnableFilteringCheckBox.Value && ~isempty(obj.filter_config.filters)
                fprintf('PV Filtering: ENABLED (%d filters)\n', length(obj.filter_config.filters));
                obj.logMessage('PV Filtering: ENABLED (%d filters)\n', length(obj.filter_config.filters));
            else
                fprintf('PV Filtering: DISABLED\n');
                obj.logMessage('PV Filtering: DISABLED\n');
            end
            
            % Clear existing statistics arrays
            obj.xmean = [];
            obj.ymean = [];
            obj.xpmean = [];
            obj.ypmean = [];
            obj.TMITmean = [];
            obj.E0_BPM_plot = [];
            
            obj.x_std = [];
            obj.y_std = [];
            obj.xp_std = [];
            obj.yp_std = [];
            obj.TMIT_std = [];
            
            % Conversion factor
            num_par_to_nC = 1.602e-10;
            
            % Track cumulative statistics
            cumulative_total = 0;
            cumulative_kept = 0;
            
            % Loop through each stored scan step
            for i = 1:length(obj.raw_data_storage)
                
                % Get the stored raw data for this step
                raw = obj.raw_data_storage{i};
                
                % Apply PV filters if enabled
                if obj.guihan.EnableFilteringCheckBox.Value
                    [valid_mask, step_stats] = obj.applyPVFilters(raw);
                    
                    % Further filter the ind_analyse indices
                    % ind_analyse gives us shots that passed energy outlier detection
                    % valid_mask gives us shots that pass PV filters
                    % We need the intersection
                    ind_analyse_filtered = raw.ind_analyse(valid_mask);
                    
                    % Update cumulative stats
                    cumulative_total = cumulative_total + step_stats.total_shots;
                    cumulative_kept = cumulative_kept + step_stats.kept_shots;
                    
                else
                    % No filtering - use all shots that passed energy outlier detection
                    ind_analyse_filtered = raw.ind_analyse;
                    
                    cumulative_total = cumulative_total + length(raw.ind_analyse);
                    cumulative_kept = cumulative_kept + length(raw.ind_analyse);
                end
                
                % Check if we have any shots left after filtering
                if isempty(ind_analyse_filtered)
                    warning('Step %d: No shots remaining after filtering (skipped)', i);
                    continue;
                end
                
                % Reconstruct the filtered BPM positions
                x1_filtered = raw.x1(ind_analyse_filtered);
                y1_filtered = raw.y1(ind_analyse_filtered);
                
                % Get the stored angles (filter to matching indices)
                % raw.xp and raw.yp were calculated from raw.ind_analyse
                % So we need to map from ind_analyse_filtered back to the xp/yp arrays
                
                % Find which indices in raw.ind_analyse correspond to ind_analyse_filtered
                [~, ia, ~] = intersect(raw.ind_analyse, ind_analyse_filtered, 'stable');
                xp = raw.xp(ia);
                yp = raw.yp(ia);
                
                % Reconstruct the trajectory arrays
                x_BPM = [x1_filtered, x1_filtered + xp * diff(raw.z_BPM)];
                y_BPM = [y1_filtered, y1_filtered + yp * diff(raw.z_BPM)];
                
                % Interpolate to the NEW z location
                x = interp1(raw.z_BPM, x_BPM', z_new);
                y = interp1(raw.z_BPM, y_BPM', z_new);
                
                % Energy calculation
                E0_BPM = 10 + 0.0834 * raw.BPM_2445_x;
                E0_BPM_filtered = E0_BPM(ind_analyse_filtered);
                
                % Get filtered TMIT
                BPM_2445_TMIT_filtered = raw.BPM_2445_TMIT(ind_analyse_filtered);
                
                % Calculate means for this step
                xmean_i = mean(x, 'omitnan') * 1000;  % Convert to microns
                ymean_i = mean(y, 'omitnan') * 1000;
                xpmean_i = mean(xp, 'omitnan') * 1000;
                ypmean_i = mean(yp, 'omitnan') * 1000;
                TMITmean_i = mean(BPM_2445_TMIT_filtered, 'omitnan') * num_par_to_nC;
                E0_BPM_plot_i = mean(E0_BPM_filtered, 'omitnan');
                
                % Store means
                obj.xmean(end+1) = xmean_i;
                obj.ymean(end+1) = ymean_i;
                obj.xpmean(end+1) = xpmean_i;
                obj.ypmean(end+1) = ypmean_i;
                obj.TMITmean(end+1) = TMITmean_i;
                obj.E0_BPM_plot(end+1) = E0_BPM_plot_i;
                
                % Calculate and store standard deviations
                obj.x_std(end+1) = std(x, 'omitnan') * 1000;
                obj.y_std(end+1) = std(y, 'omitnan') * 1000;
                obj.xp_std(end+1) = std(xp, 'omitnan') * 1000;
                obj.yp_std(end+1) = std(yp, 'omitnan') * 1000;
                obj.TMIT_std(end+1) = std(BPM_2445_TMIT_filtered, 'omitnan') * num_par_to_nC;
            end
            
            % Store cumulative statistics
            obj.filter_stats.total_shots = cumulative_total;
            obj.filter_stats.kept_shots = cumulative_kept;
            if cumulative_total > 0
                obj.filter_stats.survival_rate = 100 * cumulative_kept / cumulative_total;
            else
                obj.filter_stats.survival_rate = 0;
            end
            
            % Update filter status label
            obj.updateFilterStatus();
            
            % Calculate deviations from mean
            x_deviation = obj.xmean - mean(obj.xmean, "omitnan");
            y_deviation = obj.ymean - mean(obj.ymean, "omitnan");
            xp_deviation = obj.xpmean - mean(obj.xpmean, "omitnan");
            yp_deviation = obj.ypmean - mean(obj.ypmean, "omitnan");
            TMIT_plot = obj.TMITmean;
            
            % Clear all plots
            cla(obj.guihan.xPlot);
            cla(obj.guihan.yPlot);
            cla(obj.guihan.xpPlot);
            cla(obj.guihan.ypPlot);
            cla(obj.guihan.tmitPlot);
            
            % Recreate all plots with new data
            errorbar(obj.guihan.xPlot, obj.E0_BPM_plot, x_deviation, obj.x_std, ...
                'o', 'MarkerFaceColor','b');
            xlabel(obj.guihan.xPlot, 'Slice Energy [GeV]');
            ylabel(obj.guihan.xPlot, 'x-x_0 [\mum]');
            title(obj.guihan.xPlot, sprintf('z = %.3f m', z_new));
            
            errorbar(obj.guihan.xpPlot, obj.E0_BPM_plot, xp_deviation, obj.xp_std, ...
                'o', 'MarkerFaceColor','b');
            xlabel(obj.guihan.xpPlot, 'Slice Energy [GeV]');
            ylabel(obj.guihan.xpPlot, 'x''-x''_0 [\murad]');
            title(obj.guihan.xpPlot, sprintf('z = %.3f m', z_new));
            
            errorbar(obj.guihan.yPlot, obj.E0_BPM_plot, y_deviation, obj.y_std, ...
                'o', 'MarkerFaceColor','b');
            xlabel(obj.guihan.yPlot, 'Slice Energy [GeV]');
            ylabel(obj.guihan.yPlot, 'y-y_0 [\mum]');
            title(obj.guihan.yPlot, sprintf('z = %.3f m', z_new));
            
            errorbar(obj.guihan.ypPlot, obj.E0_BPM_plot, yp_deviation, obj.yp_std, ...
                'o', 'MarkerFaceColor','b');
            xlabel(obj.guihan.ypPlot, 'Slice Energy [GeV]');
            ylabel(obj.guihan.ypPlot, 'y''-y''_0 [\murad]');
            title(obj.guihan.ypPlot, sprintf('z = %.3f m', z_new));
            
            errorbar(obj.guihan.tmitPlot, obj.E0_BPM_plot, TMIT_plot, obj.TMIT_std, ...
                'o', 'MarkerFaceColor','b');
            xlabel(obj.guihan.tmitPlot, 'Slice Energy [GeV]');
            ylabel(obj.guihan.tmitPlot, 'Slice Charge [nC]');
            title(obj.guihan.tmitPlot, sprintf('z = %.3f m', z_new));
            
            drawnow;
            
            fprintf('=== Recalculation complete at z = %.3f m ===\n\n', z_new);
            obj.logMessage('Recalculation complete: %d/%d shots kept (%.1f%%)', ...
                obj.filter_stats.kept_shots, obj.filter_stats.total_shots, ...
                obj.filter_stats.survival_rate);
        end
        
        
        
        
        

        function notchHome(obj)
            %initial constants
            step = 1000;
            maxTries = 5;
            maxWaitTime = 10;
            
            obj.stopflag = false;  %resets stop flag at the biggining
            
            %move the notch Collimator to zero
            caput(obj.pvs.NotchCol_Set, 0);
            
            %loop that allows the motor time to move
            tStart = tic;
            while true
                caget(obj.pvs.NotchCol_Active);
                if obj.pvs.NotchCol_Active.val{1} == 0
                    break;
                end
                if toc(tStart) > maxWaitTime
                    warning('Timeout: Notch failed to reach 0');
                    return;
                end
                pause(0.1);
            end
            
            %pull notch coll LLS value after bring moved to zero
            caget(obj.pvs.NotchCol_LLS);
            caget(obj.pvs.NotchCol_Readback);
            current_pos = obj.pvs.NotchCol_Readback.val{1};
            
            if obj.pvs.NotchCol_LLS.val{1} == 1 %checks to see if LLS it hit
                if abs(current_pos) < 0.1
                    fprintf('Notch is at home position')
                    return;
                else
                    caput(obj.pvs.NotchCol_Calibration, 'Set');%sets calibration value to 'Set'
                    pause(0.2);
                    caput(obj.pvs.NotchCol_VAL, 0); %Calibrates LL value to equal zero
                    pause(0.2);
                    caput(obj.pvs.NotchCol_Calibration, 'Use');%Puts calibration back to 'use'
                    pause(0.2);
                    caput(obj.pvs.NotchCol_LLM, 0); %Sets LLM to zero at that value
                    pause(0.2);
                    fprintf('Notch is at home position and LLS value has been recalibrated')
                    return;
                end
            else
                attempt = 0;
                
                while obj.pvs.NotchCol_LLS.val{1} == 0 && attempt < maxTries
                    attempt = attempt + 1; % counts amount of time LLM has been changed
                    
                    % if loop dosent hit limit incriment llm by 1000
                    current_pos = caget(obj.pvs.NotchCol_Set);
                    %changes LLM and moves notch col to new LLM value
                    new_position = current_pos - step;
                    
                    caput(obj.pvs.NotchCol_LLM, new_position);
                    caput(obj.pvs.NotchCol_Set, new_position);
                    
                    %loop that allows the motor time to move
                    tStart = tic;
                    while true
                        caget(obj.pvs.NotchCol_Active);
                        if obj.pvs.NotchCol_Active.val{1} == 0
                            break;
                        end
                        if toc(tStart) > maxWaitTime
                            warning('Timeout: Notch failed to reach 0');
                            return;
                        end
                        pause(0.1);
                    end
                    
                    caget(obj.pvs.NotchCol_LLS);
                    if obj.pvs.NotchCol_LLS.val{1} == 1
                        fprintf('Notch LLS Hit');
                        break;
                    end
                end
                
                caget(obj.pvs.NotchCol_LLS);
                if obj.pvs.NotchCol_LLS.val{1} == 1
                    %sets calibration value to 'Set'
                    caput(obj.pvs.NotchCol_Calibration, 'Set');
                    pause(0.2);
                    %Calibrates LL value to equal zero
                    caput(obj.pvs.NotchCol_VAL, 0);
                    pause(0.2);
                    %Puts calibration back to 'use'
                    caput(obj.pvs.NotchCol_Calibration, 'Use');
                    pause(0.2);
                    %Sets LLM to zero at that value
                    caput(obj.pvs.NotchCol_LLM, 0);
                    pause(0.2);
                    fprintf('Notch collimator at home position')
                end
            end
        end

        function retractCols(obj)
            obj.stopflag = false;
            obj.logMessage('Retracting collimators to safe positions');

            caput(obj.pvs.NotchCol_Set, 1000);% YY
            caput(obj.pvs.JawLeftCol_Set, -12);
            obj.logMessage('Collimators retracted: Notch=1000mm, Jaw=-12mm');

        end

        function abort(obj) %stop whatever is currently happening and move collimators out of beam
            obj.stopflag = true;
            obj.logMessage('*** EMERGENCY ABORT TRIGGERED ***');
            
            safe_notch_pos = 1000;
            safe_jaw_pos = -12;
            
            caput(obj.pvs.NotchCol_Set, safe_notch_pos);%YY
            caput(obj.pvs.JawLeftCol_Set, safe_jaw_pos);
            
            fprintf('Abort Triggered: Notch at %.2f & Jaw at %.2f/n', safe_notch_pos, safe_jaw_pos);
            obj.logMessage('Collimators moved to safe positions');
        end

        function loop(obj)
            caget(obj.pvs.NotchCol_Set);
            caget(obj.pvs.NotchCol_Readback);
            caget(obj.pvs.NotchColY_Set);
            caget(obj.pvs.NotchColY_Readback);
            caget(obj.pvs.JawLeftCol_Set);
            caget(obj.pvs.JawLeftCol_Readback);
            caget(obj.pvs.NotchColYaw_Set);
            caget(obj.pvs.NotchColYaw_Readback);
            caget(obj.pvs.NotchCol_LLS);
            caget(obj.pvs.NotchCol_HLS);
            caget(obj.pvs.JawCol_LLS);
            caget(obj.pvs.JawCol_HLS);


            %Notch LLS Lamp Default Settings
            NotchLLS_status = obj.pvs.NotchCol_LLS.val{1};
            if NotchLLS_status == 1
                obj.guihan.NotchLLSLamp.Visible = 'on';
                obj.guihan.NotchLLSLamp.Color = [1 0 0];
            else
                obj.guihan.NotchLLSLamp.Visible = 'off';
            end

            %Notch HLS Lamp default settings
            NotchHLS_status = obj.pvs.NotchCol_HLS.val{1};
            if NotchHLS_status == 1
                obj.guihan.NotchHLSLamp.Visible = 'on';
                obj.guihan.NotchHLSLamp.Color = [1 0 0];
            else
                obj.guihan.NotchHLSLamp.Visible = 'off';
            end
            
            %Jaw LLS default settings
            JawLLS_status = obj.pvs.JawCol_LLS.val{1};
            if JawLLS_status == 1
                obj.guihan.JawLLSLamp.Visible = 'on';
                obj.guihan.JawLLSLamp.Color = [1 0 0];
            else
                obj.guihan.JawLLSLamp.Visible = 'off';
            end
           
            %Jaw HLS default settings
            JawHLS_status = obj.pvs.JawCol_HLS.val{1};
            if JawHLS_status == 1
                obj.guihan.JawHLSLamp.Visible = 'on';
                obj.guihan.JawHLSLamp.Color = [1 0 0];
            else
                obj.guihan.JawHLSLamp.Visible = 'off';
            end

        end
        
        function clearPlotsAndData(obj)
            obj.xmean = [];
            obj.ymean = [];
            obj.xpmean = [];
            obj.ypmean = [];
            obj.TMITmean = [];
            obj.E0_BPM_plot = [];

            obj.x_std = [];
            obj.y_std = [];
            obj.xp_std = [];
            obj.yp_std = [];
            obj.TMIT_std = [];

            obj.raw_data_storage = {};
            obj.scan_positions = [];
            obj.scan_transport_matrices = {};

            cla(obj.guihan.xPlot, 'reset');
            cla(obj.guihan.yPlot, 'reset');
            cla(obj.guihan.xpPlot, 'reset');
            cla(obj.guihan.ypPlot, 'reset');
            cla(obj.guihan.tmitPlot, 'reset');

            xlabel(obj.guihan.xPlot, 'Slice Energy [GeV]');
            ylabel(obj.guihan.xPlot, 'x-x_0 \mu m');

            xlabel(obj.guihan.yPlot, 'Slice Energy [GeV]');
            ylabel(obj.guihan.yPlot, 'xp-xp_0 \mu m');

            xlabel(obj.guihan.xpPlot, 'Slice Energy [GeV]');
            ylabel(obj.guihan.xpPlot, 'y-y_0 \mu m');

            xlabel(obj.guihan.ypPlot, 'Slice Energy [GeV]');
            ylabel(obj.guihan.ypPlot, 'yp-yp_0 \mu m');

            xlabel(obj.guihan.tmitPlot, 'Slice Energy [GeV]');
            ylabel(obj.guihan.tmitPlot, 'Slice Charge [nC]');


            drawnow;

            fprintf('Data arrays and plots cleard.\n')
            obj.logMessage('All data and plots cleared.\n');
        end
        
        
        function calibrateNotch(obj)
            % CALIBRATENOTCH Calibrate the notch collimator intercept
            %   Reads current jaw and notch positions and computes the intercept
            %   based on: notch_pos = slope * jaw_pos + intercept
            %
            %   The slope is read from obj.slope (loaded at startup from PV)
            %   The new intercept is calculated and stored back to the PV
            
            fprintf('\n=== NOTCH COLLIMATOR CALIBRATION ===\n');
            obj.logMessage('=== NOTCH COLLIMATOR CALIBRATION ===');
            
            % PV name for intercept storage
            pv_intercept = 'SIOC:SYS1:ML00:AO799';
            pv_slope = 'SIOC:SYS1:ML00:AO798';
            
            try
                % Step 1: Get the current slope (could use obj.slope or read fresh from PV)
                % Let's read fresh to ensure we have the latest value
                fprintf('Reading slope from PV...\n');
                obj.logMessage('Reading slope from PV...\n');
                slope = lcaGet(pv_slope);
                
                if isempty(slope) || isnan(slope)
                    error('Failed to read slope value from PV: %s', pv_slope);
                end
                
                % Update object property with fresh value
                obj.slope = slope;
                fprintf('  Slope: %.6f\n', slope);
                obj.logMessage('Slope: %.6f\n', slope);
                
                % Step 2: Wait for collimators to be stationary
                fprintf('Checking collimator status...\n');
                obj.logMessage('Checking collimator status...\n');
                maxWait = 5;
                tStart = tic;
                while true
                    caget(obj.pvs.NotchCol_Active);
                    caget(obj.pvs.JawCol_Active);
                    
                    notch_moving = obj.pvs.NotchCol_Active.val{1};
                    jaw_moving = obj.pvs.JawCol_Active.val{1};
                    
                    if notch_moving == 0 && jaw_moving == 0
                        fprintf('  Collimators are stationary\n');
                        obj.logMessage('  Collimators are stationary\n');
                        break;
                    end
                    
                    if toc(tStart) > maxWait
                        warning('Timeout: Collimators may still be moving. Proceeding anyway...');
                        obj.logMessage('WARNING: Collimators may still be moving');
                        break;
                    end
                    pause(0.1);
                end
                
                % Step 3: Read current positions from READBACK PVs
                fprintf('Reading collimator positions...\n');
                obj.logMessage('Reading collimator positions...\n');
                
                caget(obj.pvs.JawLeftCol_Readback);
                jaw_pos = obj.pvs.JawLeftCol_Readback.val{1};
                
                caget(obj.pvs.NotchCol_Readback);
                notch_pos = obj.pvs.NotchCol_Readback.val{1};
                
                % Validate readings
                if isempty(jaw_pos) || isnan(jaw_pos)
                    error('Failed to read jaw collimator position');
                end
                if isempty(notch_pos) || isnan(notch_pos)
                    error('Failed to read notch collimator position');
                end
                
                fprintf('  Jaw position:   %.4f mm\n', jaw_pos);
                fprintf('  Notch position: %.4f mm\n', notch_pos);
                obj.logMessage('Jaw: %.4f mm, Notch: %.4f mm\n', jaw_pos, notch_pos);
                
                % Step 4: Compute new intercept using the object's slope
                % Formula: intercept = notch_pos - (slope * jaw_pos)
                intercept_new = notch_pos - (obj.slope * jaw_pos);
                
                fprintf('\n--- Calibration Results ---\n');
                fprintf('  Jaw position:    %.4f mm\n', jaw_pos);
                fprintf('  Notch position:  %.4f mm\n', notch_pos);
                fprintf('  Slope:           %.6f\n', obj.slope);
                fprintf('  NEW Intercept:   %.4f mm\n', intercept_new);
                obj.logMessage('NEW Intercept: %.4f mm\n', intercept_new);
                
                % Step 5: Compare with old intercept
                intercept_old = obj.intercept;  % Use the object property
                if ~isempty(intercept_old) && ~isnan(intercept_old)
                    delta = intercept_new - intercept_old;
                    fprintf('  Old Intercept:   %.4f mm\n', intercept_old);
                    fprintf('  Change:          %.4f mm\n', delta);
                    
                    % Warn if change is large
                    if abs(delta) > 10
                        warning('Large intercept change detected: %.2f mm', delta);
                        fprintf('  This may indicate the collimators have drifted significantly.\n');
                        obj.logMessage('WARNING: Large intercept change!\n');
                        
                        % Ask user to confirm
                        answer = questdlg(sprintf(['Large intercept change detected: %.2f mm\n\n' ...
                            'Old: %.4f mm\n' ...
                            'New: %.4f mm\n\n' ...
                            'Continue with calibration?'], ...
                            delta, intercept_old, intercept_new), ...
                            'Large Change Warning', ...
                            'Yes', 'No', 'No');
                        
                        if ~strcmp(answer, 'Yes')
                            fprintf('Calibration cancelled by user.\n');
                            obj.logMessage('Calibration cancelled by user.\n');
                            return;
                        end
                    end
                else
                    fprintf('  (No previous intercept found)\n');
                end
                
                % Step 6: Write new intercept to PV
                fprintf('\nWriting new intercept to PV: %s\n', pv_intercept);
                obj.logMessage('\nWriting new intercept to PV: %s\n', pv_intercept);
                lcaPut(pv_intercept, intercept_new);
                
                % Step 7: Verify the write was successful
                pause(0.2);  % Brief pause for PV to update
                intercept_verify = lcaGet(pv_intercept);
                
                if abs(intercept_verify - intercept_new) < 0.001
                    fprintf('\n*** SUCCESS ***\n');
                    fprintf('Intercept calibration complete!\n');
                    fprintf('Verified value: %.4f mm\n', intercept_verify);
                    
                    obj.logMessage('*** CALIBRATION SUCCESSFUL ***,');
                    obj.logMessage('Verified: %.4f mm,', intercept_verify);
                    
                    % Update the object's intercept property
                    obj.intercept = intercept_new;
                    
                    % Show success message to user
                    msgbox(sprintf(['Notch Calibration Complete!\n\n' ...
                        'Jaw Position:    %.3f mm\n' ...
                        'Notch Position:  %.3f mm\n' ...
                        'Slope:           %.6f\n' ...
                        'New Intercept:   %.4f mm\n\n' ...
                        'This intercept will be used for future scans.'], ...
                        jaw_pos, notch_pos, obj.slope, intercept_new), ...
                        'Calibration Success', 'help');
                else
                    error('Verification failed: PV reads %.4f but expected %.4f', ...
                        intercept_verify, intercept_new);
                end
                
            catch ME
                % Error handling
                fprintf('\n*** CALIBRATION FAILED ***\n');
                fprintf('Error: %s\n', ME.message);
                obj.logMessage('*** CALIBRATION FAILED ***');
                obj.logMessage('Error: %s', ME.message);
                
                errordlg(sprintf('Calibration failed:\n\n%s', ME.message), ...
                    'Calibration Error');
            end
            
            fprintf('\n=== END CALIBRATION ===\n\n');
            obj.logMessage('\n=== CALIBRATION END ===\n\n');
        end

        
        
        
        function cleanup(obj)
            % CLEANUP Properly close all PV connections and stop monitoring
            fprintf('Cleaning up EPICS connections...\n');
            
            % Stop the PV monitoring loop
            try
                stop(obj.pvlist);
                fprintf('  PV monitoring stopped\n');
            catch ME
                warning('Error stopping PV list: %s', ME.message);
            end
            
            % Cleanup PV connections
            try
                Cleanup(obj.pvlist);
                fprintf('  PV connections cleaned up\n');
            catch ME
                warning('Error cleaning up PV list: %s', ME.message);
            end
            
            % Remove listeners
            try
                if ~isempty(obj.listeners) && isvalid(obj.listeners)
                    delete(obj.listeners);
                    obj.listeners = [];
                    fprintf('  Event listeners removed\n');
                end
            catch ME
                warning('Error removing listeners: %s', ME.message);
            end
            
            fprintf('EPICS cleanup complete\n');
        end
        
        
        function plotToElog(obj)
            % PLOTTOELOG Create separate figure with all plots and send to elog
            %   Includes save path and user comment in elog entry
            
            obj.logMessage('Creating elog entry...');
            
            % Create a new figure for elog with wider aspect ratio
            fh = figure('Position', [100, 100, 700, 600], 'Color', 'white');
            
            % Check if we have data
            hasData = ~isempty(obj.E0_BPM_plot) && ~isempty(obj.xmean);
            
            if hasData
                % Calculate deviations
                x_deviation = obj.xmean - mean(obj.xmean, "omitnan");
                y_deviation = obj.ymean - mean(obj.ymean, "omitnan");
                xp_deviation = obj.xpmean - mean(obj.xpmean, "omitnan");
                yp_deviation = obj.ypmean - mean(obj.ypmean, "omitnan");
                TMIT_plot = obj.TMITmean;
            end
            
            % Create 5 subplots in 2 rows
            % Top row: x, x', y, y'
            % Bottom row: TMIT (centered)
            
            % Plot 1: x vs Energy
            subplot(3, 2, 1);
            if hasData
                errorbar(obj.E0_BPM_plot, x_deviation, obj.x_std, 'o', 'MarkerFaceColor', 'b');
            end
            xlabel('Slice Energy [GeV]');
            ylabel('x-x_0 [µm]');
            grid on;
            
            % Plot 2: x' vs Energy
            subplot(3, 2, 2);
            if hasData
                errorbar(obj.E0_BPM_plot, xp_deviation, obj.xp_std, 'o', 'MarkerFaceColor', 'b');
            end
            xlabel('Slice Energy [GeV]');
            ylabel('x''-x''_0 [µrad]');
            grid on;
            
            % Plot 3: y vs Energy
            subplot(3, 2, 3);
            if hasData
                errorbar(obj.E0_BPM_plot, y_deviation, obj.y_std, 'o', 'MarkerFaceColor', 'b');
            end
            xlabel('Slice Energy [GeV]');
            ylabel('y-y_0 [µm]');
            grid on;
            
            % Plot 4: y' vs Energy
            subplot(3, 2, 4);
            if hasData
                errorbar(obj.E0_BPM_plot, yp_deviation, obj.yp_std, 'o', 'MarkerFaceColor', 'b');
            end
            xlabel('Slice Energy [GeV]');
            ylabel('y''-y''_0 [µrad]');
            grid on;
            
            % Plot 5: TMIT vs Energy (centered in bottom row)
            subplot(3, 2, 5);
            if hasData
                errorbar(obj.E0_BPM_plot, TMIT_plot, obj.TMIT_std, 'o', 'MarkerFaceColor', 'b');
            end
            xlabel('Slice Energy [GeV]');
            ylabel('Slice Charge [nC]');
            grid on;
            
            % Ensure figure is fully rendered
            drawnow;
            
            % Build comment text with metadata
            comment_parts = {};
            
            % Add user comment if provided
            user_comment = obj.guihan.CommentTextArea.Value;
            if ~isempty(user_comment)
                % Combine cell array into single string if needed
                if iscell(user_comment)
                    user_comment_str = strjoin(user_comment, ' ');  % Join with space, not newline
                else
                    user_comment_str = user_comment;
                end
                
                user_comment_str = strtrim(user_comment_str);
                if ~isempty(user_comment_str)
                    comment_parts{end+1} = sprintf('Comment: %s', user_comment_str);
                end
            end
            
            % Add save path
            save_path = strtrim(obj.guihan.SavePathEditField.Value);
            if ~isempty(save_path)
                comment_parts{end+1} = sprintf('Data file: %s', save_path);
            else
                comment_parts{end+1} = 'Data file: Not yet saved';
            end
            
            % Add scan parameters
            comment_parts{end+1} = sprintf('Scan: %.3f to %.3f mm in %d steps', ...
                obj.guihan.StartPos.Value, obj.guihan.EndPos.Value, obj.guihan.NumSteps.Value);
            
            % Add calibration info
            comment_parts{end+1} = sprintf('Calibration: slope=%.6f, intercept=%.4f mm', ...
                obj.slope, obj.intercept);
            
            % Add z-location
            comment_parts{end+1} = sprintf('Z location: %.3f m', obj.guihan.ZLocation.Value);
            
            % Add filtering info
            if obj.guihan.EnableFilteringCheckBox.Value && ~isempty(obj.filter_config.filters)
                comment_parts{end+1} = sprintf('PV Filtering: %d filters applied, %d/%d shots kept (%.1f%%)', ...
                    length(obj.filter_config.filters), ...
                    obj.filter_stats.kept_shots, ...
                    obj.filter_stats.total_shots, ...
                    obj.filter_stats.survival_rate);
            else
                comment_parts{end+1} = 'PV Filtering: None';
            end
            
            % Add timestamp
            comment_parts{end+1} = sprintf('Timestamp: %s', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
            
            % Combine all parts - use a delimiter that will display well in elog
            % The function will handle XML escaping automatically
            full_comment = strjoin(comment_parts, ' \n ');
            
            % Send to elog with comment
            % util_printLog_wComments(fig, author, title, text, dim, invert, accel)
            try
                util_printLog_wComments(fh, 'F2_SliceBPM', 'BPM Slice Dispersion Measurement', full_comment);
                obj.logMessage('Posted to elog successfully');
            catch ME
                obj.logMessage('Failed to post to elog: %s', ME.message);
                errordlg(sprintf('Failed to post to elog:\n\n%s', ME.message), 'Elog Error');
            end
        end
        
        
        
        function parseAndStoreFilters(obj)
            % PARSEANDSTOREFILTERS Parse PV filter list from GUI text area
            %   Format: PV_NAME; MIN; MAX (one per line)
            %   Also supports: PV_NAME (monitor only, no filtering)
            %   Comment lines start with % or #
            
            % Get text from GUI
            filter_text = obj.guihan.PVFilterList.Value;
            
            % Handle empty or non-string input
            if isempty(filter_text)
                obj.filter_config.filters = [];
                obj.filter_config.monitor_pvs = {};
                obj.filter_config.raw_text = '';
                return;
            end
            
            % Convert cell array to string if needed
            if iscell(filter_text)
                filter_text = strjoin(filter_text, '\n');
            end
            
            % Ensure it's a string
            if ~ischar(filter_text) && ~isstring(filter_text)
                obj.filter_config.filters = [];
                obj.filter_config.monitor_pvs = {};
                obj.filter_config.raw_text = '';
                return;
            end
            
            % Check if it's only whitespace
            if isempty(strtrim(filter_text))
                obj.filter_config.filters = [];
                obj.filter_config.monitor_pvs = {};
                obj.filter_config.raw_text = '';
                return;
            end
            
            % Initialize storage
            filters = [];
            monitor_pvs = {};
            
            % Split into lines
            lines = strsplit(filter_text, '\n');
            
            for i = 1:length(lines)
                line = strtrim(lines{i});
                
                % Skip empty lines
                if isempty(line)
                    continue;
                end
                
                % Skip comment lines
                if startsWith(line, '%') || startsWith(line, '#')
                    continue;
                end
                
                % Split by semicolon
                parts = strsplit(line, ';');
                parts = strtrim(parts);
                
                if length(parts) == 1
                    % Monitor-only mode (no limits)
                    pvname = parts{1};
                    
                    % Skip if empty
                    if isempty(pvname)
                        continue;
                    end
                    
                    monitor_pvs{end+1} = pvname;
                    fprintf('  Monitor PV (no limits): %s\n', pvname);
                    
                elseif length(parts) == 3
                    % Full filter with limits
                    pvname = parts{1};
                    
                    % Skip if empty
                    if isempty(pvname)
                        continue;
                    end
                    
                    min_val = str2double(parts{2});
                    max_val = str2double(parts{3});
                    
                    % Validate numeric conversion
                    if isnan(min_val) || isnan(max_val)
                        warning('Invalid numeric values for PV %s: MIN=%s, MAX=%s (skipping)', ...
                            pvname, parts{2}, parts{3});
                        continue;
                    end
                    
                    % Validate min < max
                    if min_val >= max_val
                        warning('MIN >= MAX for PV %s: %.3f >= %.3f (skipping)', ...
                            pvname, min_val, max_val);
                        continue;
                    end
                    
                    % Create safe field name (replace : . - with _)
                    safe_name = regexprep(pvname, '[:.-]', '_');
                    
                    % Store filter
                    filter_struct = struct(...
                        'pvname', pvname, ...
                        'min', min_val, ...
                        'max', max_val, ...
                        'safe_name', safe_name ...
                        );
                    
                    if isempty(filters)
                        filters = filter_struct;
                    else
                        filters(end+1) = filter_struct;
                    end
                    
                    fprintf('  Filter: %s [%.3f, %.3f]\n', pvname, min_val, max_val);
                    
                else
                    warning('Invalid format on line %d: "%s" (expected: PV;MIN;MAX or PV)', i, line);
                end
            end
            
            % Store parsed configuration
            obj.filter_config.filters = filters;
            obj.filter_config.monitor_pvs = monitor_pvs;
            obj.filter_config.raw_text = filter_text;
            
            if length(filters) > 0 || length(monitor_pvs) > 0
                fprintf('Parsed %d filters and %d monitor PVs\n', ...
                    length(filters), length(monitor_pvs));
                obj.logMessage('Parsed %d filters and %d monitor PVs', ...
                    length(filters), length(monitor_pvs));
            end
        end
        
        
        function [valid_indices, stats] = applyPVFilters(obj, raw_data)
            % APPLYPVFILTERS Apply PV filters to raw data
            %   Returns logical array indicating which shots pass all filters
            %   stats contains filtering statistics
            
            % Start with all shots that passed energy outlier detection
            n_total = length(raw_data.ind_analyse);
            valid_mask = true(n_total, 1);
            
            % Initialize stats
            stats = struct();
            stats.total_shots = n_total;
            stats.per_filter_rejected = struct();
            
            % Check if filtering is enabled
            if ~obj.guihan.EnableFilteringCheckBox.Value || isempty(obj.filter_config.filters)
                stats.kept_shots = n_total;
                stats.survival_rate = 100;
                valid_indices = true(n_total, 1);
                return;
            end
            
            % Apply each filter
            for i = 1:length(obj.filter_config.filters)
                filt = obj.filter_config.filters(i);
                
                % Check if this PV exists in the raw data
                if ~isfield(raw_data.user_pv_data, filt.safe_name)
                    warning('PV %s not found in raw data (filter skipped)', filt.pvname);
                    continue;
                end
                
                % Get PV values for the analyzed shots
                pv_values = raw_data.user_pv_data.(filt.safe_name);
                pv_values = pv_values(raw_data.ind_analyse);
                
                % Apply filter: value must be in [min, max] AND not NaN
                filter_pass = (pv_values >= filt.min) & (pv_values <= filt.max) & ~isnan(pv_values);
                
                % Count rejections
                n_rejected = sum(~filter_pass);
                stats.per_filter_rejected.(filt.safe_name) = n_rejected;
                
                if obj.debug_mode && n_rejected > 0
                    fprintf('  Filter %s: rejected %d/%d shots (%.1f%%)\n', ...
                        filt.pvname, n_rejected, n_total, 100*n_rejected/n_total);
                end
                
                % Update valid mask (AND logic - must pass ALL filters)
                valid_mask = valid_mask & filter_pass;
            end
            
            % Final statistics
            stats.kept_shots = sum(valid_mask);
            stats.survival_rate = 100 * stats.kept_shots / n_total;
            
            fprintf('PV Filtering: %d/%d shots kept (%.1f%%)\n', ...
                stats.kept_shots, n_total, stats.survival_rate);
            
            valid_indices = valid_mask;
        end
        

        
        function updateFilterStatus(obj)
            % UPDATEFILTERSTATUS Update the filter status label in GUI
            %   Shows whether displayed plots are filtered and survival statistics
            
            % Check if we have any data at all
            if isempty(obj.raw_data_storage)
                obj.guihan.FilterStatusLabel.Text = 'No Data';
                obj.guihan.FilterStatusLabel.FontColor = [0.5 0.5 0.5];  % Gray
                return;
            end
            
            % Check if filtering checkbox is enabled
            checkbox_enabled = obj.guihan.EnableFilteringCheckBox.Value;
            
            % Check if we have any filter text in the text area
            filter_text = strtrim(obj.guihan.PVFilterList.Value);
            has_filter_text = ~isempty(filter_text);
            
            % Filtering is active if checkbox is ON AND we have filter text
            filtering_active = checkbox_enabled && has_filter_text;
            
            if ~filtering_active
                % No filtering - showing raw data
                total = obj.filter_stats.total_shots;
                if total > 0
                    if ~checkbox_enabled
                        obj.guihan.FilterStatusLabel.Text = sprintf('Raw Data: %d shots (100%%)', total);
                    elseif ~has_filter_text
                        obj.guihan.FilterStatusLabel.Text = 'No Filters Defined';
                    else
                        obj.guihan.FilterStatusLabel.Text = sprintf('Raw Data: %d shots (100%%)', total);
                    end
                else
                    if ~checkbox_enabled
                        obj.guihan.FilterStatusLabel.Text = 'Raw Data (No Scan Yet)';
                    elseif ~has_filter_text
                        obj.guihan.FilterStatusLabel.Text = 'No Filters Defined';
                    else
                        obj.guihan.FilterStatusLabel.Text = 'Raw Data (No Scan Yet)';
                    end
                end
                obj.guihan.FilterStatusLabel.FontColor = [0.5 0.5 0.5];  % Gray
                
            else
                % Filtering is active - show survival statistics
                total = obj.filter_stats.total_shots;
                kept = obj.filter_stats.kept_shots;
                rate = obj.filter_stats.survival_rate;
                
                if total > 0
                    status_text = sprintf('Filtered: %d/%d shots (%.1f%%)', kept, total, rate);
                    obj.guihan.FilterStatusLabel.Text = status_text;
                    
                    % Color code based on survival rate
                    if rate >= 80
                        obj.guihan.FilterStatusLabel.FontColor = [0 0.6 0];  % Green - good
                    elseif rate >= 50
                        obj.guihan.FilterStatusLabel.FontColor = [0.9 0.6 0];  % Orange - warning
                    else
                        obj.guihan.FilterStatusLabel.FontColor = [0.8 0 0];  % Red - poor survival
                    end
                else
                    obj.guihan.FilterStatusLabel.Text = 'Filtering Ready (No Scan Yet)';
                    obj.guihan.FilterStatusLabel.FontColor = [0 0.6 0];  % Green
                end
            end
        end
        
        
        function loadDefaultFilters(obj)
            % LOADDEFAULTFILTERS Load standard FACET-II quality cut PVs
            
            default_text = [...
                '% FACET-II Standard Quality Cuts\n', ...
                '% Format: PV_NAME; MIN; MAX\n', ...
                '% Lines starting with %% are comments\n', ...
                '\n', ...
                '% Charge stability (TMIT in particles)\n', ...
                'BPMS:LI20:2445:TMIT; 1e9; 5e9\n', ...
                '\n', ...
                '% Energy jitter (BPM X position in mm)\n', ...
                'BPMS:LI20:2445:X; -20; 20\n', ...
                '\n', ...
                '% Orbit stability at upstream BPM (mm)\n', ...
                'BPMS:LI20:3156:X; -5; 5\n', ...
                'BPMS:LI20:3156:Y; -5; 5\n', ...
                '\n', ...
                '% Orbit stability at downstream BPM (mm)\n', ...
                'BPMS:LI20:3218:X; -5; 5\n', ...
                'BPMS:LI20:3218:Y; -5; 5\n'
                ];
            
            obj.guihan.PVFilterList.Value = sprintf(default_text);
            fprintf('Default filters loaded\n');
            obj.logMessage('Default filters loaded\n');
        end
        
        
        
        function clearFilters(obj)
            % CLEARFILTERS Clear all filter configuration and recalculate with raw data
            
            % Clear GUI
            obj.guihan.PVFilterList.Value = '';
            obj.guihan.EnableFilteringCheckBox.Value = false;
            
            % Clear internal storage
            obj.filter_config = struct(...
                'filters', [], ...
                'monitor_pvs', {{}}, ...
                'raw_text', '' ...
                );
            
            obj.filter_stats = struct(...
                'total_shots', 0, ...
                'kept_shots', 0, ...
                'survival_rate', 100 ...
                );
            
            % Recalculate with raw data
            if ~isempty(obj.raw_data_storage)
                obj.recalculateAndPlot();
            end
            
            obj.updateFilterStatus();
            
            fprintf('All filters cleared - showing raw data\n');
            obj.logMessage('All filters cleared - showing raw data\n');
        end
        
        
        
        
        
        function user_pvs = parseFilterList(obj)
            % PARSEFILTERLIST Parse PV filter list and return array of PV names
            %   Used during data acquisition to determine which PVs to fetch from BSA
            
            % Get text from GUI
            filter_text = obj.guihan.PVFilterList.Value;
            
            % Handle empty or non-string input
            if isempty(filter_text)
                user_pvs = struct('pvname', {}, 'safe_name', {});
                return;
            end
            
            % Convert cell array to string if needed
            if iscell(filter_text)
                filter_text = strjoin(filter_text, '\n');
            end
            
            % Ensure it's a string
            if ~ischar(filter_text) && ~isstring(filter_text)
                user_pvs = struct('pvname', {}, 'safe_name', {});
                return;
            end
            
            % Initialize storage
            user_pvs = [];
            
            % Split into lines
            lines = strsplit(filter_text, '\n');
            
            for i = 1:length(lines)
                line = strtrim(lines{i});
                
                % Skip empty lines
                if isempty(line)
                    continue;
                end
                
                % Skip comment lines
                if startsWith(line, '%') || startsWith(line, '#')
                    continue;
                end
                
                % Split by semicolon
                parts = strsplit(line, ';');
                parts = strtrim(parts);
                
                if length(parts) >= 1
                    % Get PV name (first part)
                    pvname = parts{1};
                    
                    % Skip if empty
                    if isempty(pvname)
                        continue;
                    end
                    
                    % Create safe field name
                    safe_name = regexprep(pvname, '[:.-]', '_');
                    
                    % Store PV info
                    pv_struct = struct(...
                        'pvname', pvname, ...
                        'safe_name', safe_name ...
                        );
                    
                    if isempty(user_pvs)
                        user_pvs = pv_struct;
                    else
                        user_pvs(end+1) = pv_struct;
                    end
                end
            end
            
            if isempty(user_pvs)
                % Return empty struct array with correct fields
                user_pvs = struct('pvname', {}, 'safe_name', {});
            end
        end
      
        

        
        
        

        
        
        
        
        function logMessage(obj, message, varargin)
            % LOGMESSAGE Add timestamped message to GUI log
            %   New messages appear at the TOP
            
            % Format message if additional arguments provided
            if nargin > 2
                message = sprintf(message, varargin{:});
            end
            
            % Add timestamp
            timestamp = datestr(now, 'HH:MM:SS');
            log_entry = sprintf('[%s] %s', timestamp, message);
            
            % Get current log content
            current_log = obj.guihan.SystemLog.Value;
            
            % Handle different cases
            if isempty(current_log)
                new_log = {log_entry};
            elseif iscell(current_log) && length(current_log) == 1 && isempty(current_log{1})
                new_log = {log_entry};
            elseif ~iscell(current_log)
                new_log = {log_entry; current_log};  % ← NEW MESSAGE FIRST
            else
                new_log = [{log_entry}; current_log];  % ← NEW MESSAGE FIRST
            end
            
            % Update log (keep last 500 lines from top)
            max_lines = 50;
            if length(new_log) > max_lines
                new_log = new_log(1:max_lines);  % ← Keep first 500, not last 500
            end
            
            obj.guihan.SystemLog.Value = new_log;
            
            % Force update
            drawnow;
            
            % Also print to console if in debug mode
            if obj.debug_mode
                fprintf('%s\n', log_entry);
            end
        end
        

        
        
        
        function saveData(obj)
            % SAVEDATA Save all scan data and configuration to .mat file
            
            % Check if we have data to save
            if isempty(obj.raw_data_storage)
                errordlg('No scan data to save. Please run a scan first.', 'No Data');
                obj.logMessage('Save failed: No data available');
                return;
            end
            
            % Get save path from GUI
            user_path = strtrim(obj.guihan.SavePathEditField.Value);
            
            filename = '';
            
            if isempty(user_path)
                % Generate default path
                current_time = now;
                date_str = datestr(current_time, 'yyyy-mm-dd');
                year_str = datestr(current_time, 'yyyy');
                year_month_str = datestr(current_time, 'yyyy-mm');
                time_str = datestr(current_time, 'HHMMSS');
                
                % Create directory structure
                base_dir = '/u1/facet/matlab/data';
                save_dir = fullfile(base_dir, year_str, year_month_str, date_str);
                
                % Create directories if they don't exist
                if ~exist(save_dir, 'dir')
                    try
                        mkdir(save_dir);
                        obj.logMessage('Created directory: %s', save_dir);
                    catch ME
                        errordlg(sprintf('Failed to create directory:\n%s', ME.message), 'Save Error');
                        obj.logMessage('Save failed: Could not create directory');
                        return;
                    end
                end
                
                % Generate filename
                filename = sprintf('SliceBPMdispersion-scan-%s-%s.mat', date_str, time_str);
                filepath = fullfile(save_dir, filename);
                
                % Update GUI with the generated path
                obj.guihan.SavePathEditField.Value = filepath;
            else
                % Use user-specified path
                filepath = user_path;
                
                [save_dir, name, ext] = fileparts(filepath);
                filename = [name ext];
                
                % Check if directory exists
                [save_dir, ~, ~] = fileparts(filepath);
                if ~isempty(save_dir) && ~exist(save_dir, 'dir')
                    try
                        mkdir(save_dir);
                        obj.logMessage('Created directory: %s', save_dir);
                    catch ME
                        errordlg(sprintf('Failed to create directory:\n%s', ME.message), 'Save Error');
                        obj.logMessage('Save failed: Could not create directory');
                        return;
                    end
                end
            end
            
            obj.logMessage('Saving data to: %s', filepath);
            
            try
                % Gather all data to save
                data = struct();
                
                % Metadata
                data.timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
                data.app_version = 'F2_SliceBPMDispersion v1.0';
                
                % Scan parameters
                data.scan_params = struct();
                data.scan_params.start_pos = obj.guihan.StartPos.Value;
                data.scan_params.end_pos = obj.guihan.EndPos.Value;
                data.scan_params.num_steps = obj.guihan.NumSteps.Value;
                data.scan_params.shots_per_buffer = obj.guihan.ShotsperBuffer.Value;
                data.scan_params.z_location = obj.guihan.ZLocation.Value;
                
                % Collimator calibration
                data.calibration = struct();
                data.calibration.slope = obj.slope;
                data.calibration.intercept = obj.intercept;
                
                % Raw data storage (most important!)
                data.raw_data_storage = obj.raw_data_storage;
                data.scan_positions = obj.scan_positions;
                data.scan_transport_matrices = obj.scan_transport_matrices;
                
                % Processed statistics
                data.statistics = struct();
                data.statistics.xmean = obj.xmean;
                data.statistics.ymean = obj.ymean;
                data.statistics.xpmean = obj.xpmean;
                data.statistics.ypmean = obj.ypmean;
                data.statistics.TMITmean = obj.TMITmean;
                data.statistics.E0_BPM_plot = obj.E0_BPM_plot;
                data.statistics.x_std = obj.x_std;
                data.statistics.y_std = obj.y_std;
                data.statistics.xp_std = obj.xp_std;
                data.statistics.yp_std = obj.yp_std;
                data.statistics.TMIT_std = obj.TMIT_std;
                
                % Filter configuration
                data.filter_config = obj.filter_config;
                data.filter_stats = obj.filter_stats;
                data.filtering_enabled = obj.guihan.EnableFilteringCheckBox.Value;
                
                % Comment from GUI (for future use)
                data.comment = obj.guihan.CommentTextArea.Value;
                
                % Save to file
                save(filepath, '-struct', 'data', '-v7.3');
                
                obj.logMessage('Data saved successfully');
                obj.logMessage('File: %s', filename);
                
                % Show success message
                msgbox(sprintf('Data saved successfully!\n\n%s', filepath), ...
                    'Save Complete', 'help');
                
            catch ME
                errordlg(sprintf('Failed to save data:\n\n%s', ME.message), 'Save Error');
                obj.logMessage('Save failed: %s', ME.message);
            end
        end
        
        
        
        
        function loadData(obj)
            % LOADDATA Load scan data from .mat file and restore state
            
            % Get file path from GUI
            user_path = strtrim(obj.guihan.SavePathEditField.Value);
            
            if isempty(user_path)
                % Open file browser
                default_dir = '/u1/facet/matlab/data';
                if ~exist(default_dir, 'dir')
                    default_dir = pwd;
                end
                
                [filename, pathname] = uigetfile('*.mat', 'Select data file to load', default_dir);
                
                if isequal(filename, 0)
                    obj.logMessage('Load cancelled by user');
                    return;
                end
                
                filepath = fullfile(pathname, filename);
                obj.guihan.SavePathEditField.Value = filepath;
            else
                filepath = user_path;
            end
            
            % Check if file exists
            if ~exist(filepath, 'file')
                errordlg(sprintf('File not found:\n%s', filepath), 'Load Error');
                obj.logMessage('Load failed: File not found');
                return;
            end
            
            obj.logMessage('Loading data from: %s', filepath);
            
            try
                % Load data
                data = load(filepath);
                
                % Verify this is a valid SliceBPM data file
                if ~isfield(data, 'raw_data_storage')
                    error('Invalid data file: missing raw_data_storage');
                end
                
                obj.logMessage('Data file loaded: %s', data.timestamp);
                
                % Restore scan parameters
                if isfield(data, 'scan_params')
                    obj.guihan.StartPos.Value = data.scan_params.start_pos;
                    obj.guihan.EndPos.Value = data.scan_params.end_pos;
                    obj.guihan.NumSteps.Value = data.scan_params.num_steps;
                    obj.guihan.ShotsperBuffer.Value = data.scan_params.shots_per_buffer;
                    obj.guihan.ZLocation.Value = data.scan_params.z_location;
                    obj.logMessage('Scan parameters restored');
                end
                
                % Restore calibration
                if isfield(data, 'calibration')
                    obj.slope = data.calibration.slope;
                    obj.intercept = data.calibration.intercept;
                    obj.logMessage('Calibration restored: slope=%.6f, intercept=%.4f', ...
                        obj.slope, obj.intercept);
                end
                
                % Restore raw data (most important!)
                obj.raw_data_storage = data.raw_data_storage;
                obj.scan_positions = data.scan_positions;
                obj.scan_transport_matrices = data.scan_transport_matrices;
                obj.logMessage('Raw data restored: %d scan steps', length(obj.raw_data_storage));
                
                % Restore processed statistics
                if isfield(data, 'statistics')
                    obj.xmean = data.statistics.xmean;
                    obj.ymean = data.statistics.ymean;
                    obj.xpmean = data.statistics.xpmean;
                    obj.ypmean = data.statistics.ypmean;
                    obj.TMITmean = data.statistics.TMITmean;
                    obj.E0_BPM_plot = data.statistics.E0_BPM_plot;
                    obj.x_std = data.statistics.x_std;
                    obj.y_std = data.statistics.y_std;
                    obj.xp_std = data.statistics.xp_std;
                    obj.yp_std = data.statistics.yp_std;
                    obj.TMIT_std = data.statistics.TMIT_std;
                    obj.logMessage('Statistics restored');
                end
                
                % Restore filter configuration
                if isfield(data, 'filter_config')
                    obj.filter_config = data.filter_config;
                    
                    % Update GUI filter list
                    if ~isempty(data.filter_config.raw_text)
                        obj.guihan.PVFilterList.Value = data.filter_config.raw_text;
                    end
                    
                    if isfield(data, 'filtering_enabled')
                        obj.guihan.EnableFilteringCheckBox.Value = data.filtering_enabled;
                    end
                    
                    if isfield(data, 'filter_stats')
                        obj.filter_stats = data.filter_stats;
                    end
                    
                    obj.logMessage('Filter configuration restored');
                end
                
                % Restore comment
                if isfield(data, 'comment')
                    obj.guihan.CommentTextArea.Value = data.comment;
                end
                
                % Recalculate and replot with loaded data
                obj.logMessage('Recalculating plots...');
                obj.recalculateAndPlot();
                
                obj.logMessage('Data loaded successfully');
                
                % Show success message
                msgbox(sprintf('Data loaded successfully!\n\nTimestamp: %s\nSteps: %d', ...
                    data.timestamp, length(obj.raw_data_storage)), ...
                    'Load Complete', 'help');
                
            catch ME
                errordlg(sprintf('Failed to load data:\n\n%s', ME.message), 'Load Error');
                obj.logMessage('Load failed: %s', ME.message);
            end
        end
        
        
        
        
        %% Support functions
        function M = calcIPTransport(obj, B)
            
            zUSBPM = 1991.31;
            zDSBPM = 1997.77;
            zQ0D   = 1996.98244;
            L_eff = 1; % Effective quad length
            
            d1 = zQ0D - zUSBPM - L_eff/2;
            d2 = zDSBPM - zQ0D - L_eff/2;
            
            M = M_drift(obj, d2)*M_quad(obj, B)*M_drift(obj, d1);
            
        end
        
        function M = M_drift(obj, d)
            OO = zeros(2,2);
            m = [1 d; 0 1];
            M = [m OO; OO m];
        end
        
        function M = M_quad(obj, B)
            OO = zeros(2,2);
            E = 10;
            L_eff = 1;
            
            
            if B==0
                M = M_drift(obj, L_eff);
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
    end
end