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
        switch_acq = 'beam_off';
        %elogtext = 'Custom Values';

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

        end

    properties(Constant)
        tolerance_jaw = 0.1;
        tolerance_notch = 2;

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
           
            
        end

        function aquireAndPlotBPMData (obj, ~)
            obj.stopflag = false; 

            z_3156 = 1991.31;
            z_3218 = 1997.77;
            z = obj.guihan.ZLocation;

            acq_time = 10;
              % or get this from GUI or logic if you have that

            switch obj.switch_acq
                case 'beam on'
                    PS_Q0D = control_magnetGet("LI20:LGPS:3141"); % Don't change this during the scan
                    M = calcIPTransport(PS_Q0D);
                case 'beam_off'
                    M =  rand(4,4);
            end
            
            M11 = M(1,1);
            M12 = M(1,2);
            M33 = M(3,3);
            M34 = M(3,4);

            %reserve edef's
            masks = {{'TS5'} {} {} {}};
            edef = eDefReserve('BPMdisperson');
            eDefParams(edef, 1, obj.guihan.ShotsperBuffer.Value, masks{:});  % third argument = -1 makes it acquire forever
            lcaPut(['EDEF:SYS1:' num2str(edef) ':EXCM64'], 0); % allows edef to run with no beam

            %start aquisition
            eDefOn(edef);    % This starts the buffer
            pause(acq_time); % This waits for some amount of time
            eDefOff(edef);   % Stop the buffer

            if strcmp(obj.switch_acq, 'beam_on')
                BPM_3156_x = getHist(obj.pv_BPM_3156_x);
                BPM_3156_y = getHist(obj.pv_BPM_3156_y);
                %BPM_3156_TMIT = getHist(obj.pv_BPM_3156_TMIT);
        
                BPM_3218_x = getHist(obj.pv_BPM_3218_x);
                BPM_3218_y = getHist(obj.pv_BPM_3218_y);
                %BPM_3218_TMIT = getHist(obj.pv_BPM_3218_TMIT);
        
                %BPM_2445_x = getHist(obj.pv_BPM_2445_x);
                %BPM_2445_y = getHist(obj.pv_BPM_2445_y);
                BPM_2445_TMIT = getHist(obj.pv_BPM_2445_TMIT);

                % Energy for plotting
                E0_BPM = 10 + 0.0834 * (BPM_2445_TMIT);
            else
                BPM_3156_x = randn(100,1);
                BPM_3156_y = randn(100,1);
                %BPM_3156_TMIT = randn(100,1);
            
                BPM_3218_x = randn(100,1);
                BPM_3218_y = randn(100,1);
                %BPM_3218_TMIT = randn(100,1);
    
                BPM_2445_x = linspace(1, 2, 100);
                %BPM_2445_y = randn(100,1);
                BPM_2445_TMIT = randn(100,1);
            
                EPICSpid = randn(100,1);
    
                %sets x axis
                E0_BPM_plot_i = length(obj.E0_BPM_plot) + 1;
                
            end

            obj.stopflag = false; 
            
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
            x_BPM = [x1, x1+xp*diff(z_BPM)];
            y_BPM = [y1, y1+yp*diff(z_BPM)];

            % Interpolate x and y positions over the specific z range
            x = interp1(z_BPM, x_BPM(ind_analyse, :)', z.Value);
            y = interp1(z_BPM, y_BPM(ind_analyse, :)', z.Value);
            xp = xp(ind_analyse);
            yp = yp(ind_analyse);

            %calculate means
            xmean_i = mean(x, 'omitnan') * 1000;
            ymean_i = mean(y, 'omitnan') * 1000;
            xpmean_i = mean(xp, 'omitnan') * 1000;
            ypmean_i = mean(yp, 'omitnan') * 1000;
            TMITmean_i = mean(BPM_2445_TMIT, 'omitnan');

            % store means
            obj.xmean(end+1) = xmean_i;
            obj.ymean(end+1) = ymean_i;
            obj.xpmean(end+1) = xpmean_i;
            obj.ypmean(end+1) = ypmean_i;
            obj.TMITmean(end+1) = TMITmean_i;
            obj.E0_BPM_plot(end+1) = E0_BPM_plot_i;
        
            % calculate and stoe STD
            obj.x_std(end+1) = std(x, "omitnan") * 1000;
            obj.y_std(end+1) = std(y, "omitnan") * 1000;
            obj.xp_std(end+1) = std(xp, "omitnan") * 1000;
            obj.yp_std(end+1) = std(yp, "omitnan") * 1000;
            obj.TMIT_std(end+1) = std(BPM_2445_TMIT, "omitnan") * 1000;
        
            % dev from total mean
            x_deviation = obj.xmean - mean(obj.xmean);
            y_deviation = obj.ymean - mean(obj.ymean);
            xp_deviation = obj.xpmean - mean(obj.xpmean);
            yp_deviation = obj.ypmean - mean(obj.ypmean);
            TMIT_deviation = obj.TMITmean - mean(obj.TMITmean);
                       
            %plots
            errorbar(obj.guihan.xPlot, obj.E0_BPM_plot, x_deviation, obj.x_std, 'o', 'MarkerFaceColor','b');
            xlabel('Slice Energy [GeV]')
            ylabel('x-x_0 \mu m')
            drawnow;
            
            errorbar(obj.guihan.xpPlot, obj.E0_BPM_plot, xp_deviation, obj.xp_std, 'o','MarkerFaceColor','b');
            xlabel('Slice Energy [GeV]')
            ylabel('xp-xp_0 \mu m')
            drawnow;
            
            errorbar(obj.guihan.yPlot, obj.E0_BPM_plot, y_deviation, obj.y_std, 'o','MarkerFaceColor','b');
            xlabel('Slice Energy [GeV]')
            ylabel('y-y_0 \mu m')
            drawnow;
            
            errorbar(obj.guihan.ypPlot, obj.E0_BPM_plot, yp_deviation, obj.yp_std, 'o','MarkerFaceColor','b');
            xlabel('Slice Energy [GeV]')
            ylabel('yp-yp_0 \mu m')
            drawnow;
            
            errorbar(obj.guihan.tmitPlot, obj.E0_BPM_plot, TMIT_deviation, obj.TMIT_std, 'o','MarkerFaceColor','b');
            xlabel('Slice Energy [GeV]')
            ylabel('Slice Charge [nC]')
            drawnow;

            % Release edef
            eDefRelease(edef);
        end
        
        function scanCols(obj)

            obj.guihan.ScaninProgressLabel.Visible = 'on';

            %link start and stop positions to values imputted from .mlapp
            startPos = obj.guihan.StartPos.Value;
            endPos = obj.guihan.EndPos.Value;
            nSteps = obj.guihan.NumSteps.Value;

            notch_col_pos = 'COLL:LI20:2069:MOTR';
            jaw_col_pos = 'COLL:LI20:2085:MOTR.VAL';

            %sets up variables for nested while loop
            maxCount = 5;          % Max retry count
            maxWaitTime = 10;      % Max time in seconds

            obj.stopflag = false;  %resets stop flag at the biggining

            %generate list of position
            positions = linspace(startPos,endPos,nSteps);

            % for loop to move collimator through steps
            for i = 1:length(positions)

                if obj.stopflag
                    fprintf('Scan stopped at step %d\n', i);
                    break;
                end
                drawnow;

                pos = positions(i);

                %defines gab between collimators
                delta = pos * obj.slope + obj.intercept;

                lcaPut(jaw_col_pos,pos); %pushes new position to hardware
                lcaPut(notch_col_pos, pos + delta);   %amybe add a loop here that waits fot the motors to stop

                fprintf('Set jaw to %.2f, notch to %.2f\n', pos, pos + delta);

                %call data acq function          
                obj.aquireAndPlotBPMData(i);

                tStart = tic;
                while true

                    % checks to see if abort button has been hit
                    if obj.stopflag
                        disp('Scan Aborted Manually');
                        return;
                    end
                    drawnow;

                    %looks to see if collimators are moving
                    notch_status = caget(obj.pvs.NotchCol_Active);
                    jaw_status   = caget(obj.pvs.JawCol_Active);

                    if notch_status == 0 && jaw_status == 0
                    break;   
                    end
                    
                    if toc(tStart) > maxWaitTime
                        warning('Timeout: Collimators failed to reach position');
                        break;
                    end
                    
                    pause(0.1);
                end
                   
                count = 0;
                while count <=5
                    %checks stopflag
                    if obj.stopflag
                        disp('Scan Aborted Manually');
                        return;
                    end
                    drawnow;

                    %checks tolarances
                    readback_notch = caget(obj.pvs.NotchCol_Readback);
                    readback_jaw = caget(obj.pvs.JawLeftCol_Readback);

                    if abs(readback_jaw - pos) < obj.tolerance_jaw && ...
                        abs(readback_notch - (pos + delta)) < obj.tolerance_notch
                        break;
                    end
                    
                    tWait = tic;
                    while true
                        caget(obj.pvs.NotchCol_Active);
                        caget(obj.pvs.JawCol_Active);
                        if obj.pvs.NotchCol_Active.val{1} == 0 && obj.pvs.JawCol_Active.val{1} == 0
                            return;
                        end
                        if toc(tWait) > maxWaitTime
                            warning('Timeout: Collimators failed to reach position');
                            break;
                        end
                        pause(0.1);
                    end

                    count = count + 1;

                    obj.stopflag = false;

                    if count > maxCount
                        warning('Notch or Jaw failed to reach position %.3f after %d attemps (readback = %.3f)', pos, maxCount,readback_notch);
                        break;
                    end
                    
                    if toc(tStart) > maxWaitTime
                        warning('Timeout while waiting for collimators to reach %.3f',pos,readback_notch);
                        break;
                    end
                end 
            end

            %visual display
            obj.guihan.ScaninProgressLabel.Visible = 'off';
            obj.guihan.ScanFinishedLabel.Visible = 'on';
            pause(1);
            obj.guihan.ScanFinishedLabel.Visible = 'off';
            pause(0.2);
            obj.guihan.ScanFinishedLabel.Visible = 'on';
            pause(1);
            obj.guihan.ScanFinishedLabel.Visible = 'off';
            pause(0.2);
            obj.guihan.ScanFinishedLabel.Visible = 'on';
            pause(1);
            obj.guihan.ScanFinishedLabel.Visible = 'off';

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

            caput(obj.pvs.NotchCol_Set, 1000);
            caput(obj.pvs.JawLeftCol_Set, -12);

        end

        function abort(obj) %stop whatever is currently happening and move collimators out of beam
        obj.stopflag = true;

        safe_notch_pos = 1000;
        safe_jaw_pos = -12;

        caput(obj.pvs.NotchCol_Set, safe_notch_pos);
        caput(obj.pvs.JawLeftCol_Set, safe_jaw_pos);

        fprintf('Abort Triggered: Notch at %.2f & Jaw at %.2f/n', safe_notch_pos, safe_jaw_pos);
        end

        function loop(obj)
            caget(obj.pvs.NotchCol_Set);
            caget(obj.pvs.NotchCol_Readback);
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
    end
end