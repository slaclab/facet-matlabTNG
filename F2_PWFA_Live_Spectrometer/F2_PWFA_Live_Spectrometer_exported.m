classdef F2_PWFA_Live_Spectrometer_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        LeftPanel                      matlab.ui.container.Panel
        PWFALiveSpectrometerLabel      matlab.ui.control.Label
        StartacquiringButton           matlab.ui.control.Button
        StopacquiringButton            matlab.ui.control.Button
        AcquisitionrateHzLabel         matlab.ui.control.Label
        AcquisitionrateHzEditField     matlab.ui.control.NumericEditField
        AcquisitionstatusLabel         matlab.ui.control.Label
        AcquisitionstatusLamp          matlab.ui.control.Lamp
        Spectrometerdisplay1DropDownLabel  matlab.ui.control.Label
        Spectrometerdisplay1DropDown   matlab.ui.control.DropDown
        AccelerationthresholdGeVEditFieldLabel  matlab.ui.control.Label
        AccelerationthresholdGeVEditField  matlab.ui.control.NumericEditField
        CurrentcompressionButtonGroup  matlab.ui.container.ButtonGroup
        OvercompressedButton           matlab.ui.control.ToggleButton
        UndercompressedButton          matlab.ui.control.ToggleButton
        TakebackgroundsButton          matlab.ui.control.Button
        S14BLENatpeakcompressionEditFieldLabel  matlab.ui.control.Label
        S14BLENatpeakcompressionEditField  matlab.ui.control.NumericEditField
        UsenormalizedBLENCheckBox      matlab.ui.control.CheckBox
        ClearwaterfallButton           matlab.ui.control.Button
        CHERchargecalibrationtypeDropDownLabel  matlab.ui.control.Label
        CHERchargecalibrationtypeDropDown  matlab.ui.control.DropDown
        AcceleratedchargepCEditFieldLabel  matlab.ui.control.Label
        AcceleratedchargepCEditField   matlab.ui.control.NumericEditField
        InitialtrailingchargepCEditFieldLabel  matlab.ui.control.Label
        InitialtrailingchargepCEditField  matlab.ui.control.NumericEditField
        ChargecaptureEditFieldLabel    matlab.ui.control.Label
        ChargecaptureEditField         matlab.ui.control.NumericEditField
        EnergygainJEditFieldLabel      matlab.ui.control.Label
        EnergygainJEditField           matlab.ui.control.NumericEditField
        EnergylossJEditFieldLabel      matlab.ui.control.Label
        EnergylossJEditField           matlab.ui.control.NumericEditField
        DrivechargepCEditFieldLabel    matlab.ui.control.Label
        DrivechargepCEditField         matlab.ui.control.NumericEditField
        TrailingbunchcutSYAGpxEditFieldLabel  matlab.ui.control.Label
        TrailingbunchcutSYAGpxEditField  matlab.ui.control.NumericEditField
        PrinttologButton               matlab.ui.control.Button
        NumberofcolumnsEditFieldLabel  matlab.ui.control.Label
        NumberofcolumnsEditField       matlab.ui.control.NumericEditField
        TwobunchmodeDropDownLabel      matlab.ui.control.Label
        TwobunchmodeDropDown           matlab.ui.control.DropDown
        S14BLENauEditFieldLabel        matlab.ui.control.Label
        S14BLENauEditField             matlab.ui.control.NumericEditField
        ApplybackgroundsButton         matlab.ui.control.StateButton
        nCcountEditFieldLabel          matlab.ui.control.Label
        nCcountEditField               matlab.ui.control.EditField
        BackgroundsubtractionLabel     matlab.ui.control.Label
        TotalenergytransferefficiencyEditFieldLabel  matlab.ui.control.Label
        TotalenergytransferefficiencyEditField  matlab.ui.control.NumericEditField
        InitialdrivechargepCEditFieldLabel  matlab.ui.control.Label
        InitialdrivechargepCEditField  matlab.ui.control.NumericEditField
        SYAGchargecalibrationtypeDropDownLabel  matlab.ui.control.Label
        SYAGchargecalibrationtypeDropDown  matlab.ui.control.DropDown
        BitdepthLabel                  matlab.ui.control.Label
        WaterfallSpinner               matlab.ui.control.Spinner
        WaterfallSpinnerLabel          matlab.ui.control.Label
        Spectrometer1SpinnerLabel      matlab.ui.control.Label
        Spectrometer1Spinner           matlab.ui.control.Spinner
        nCcountEditField_2Label        matlab.ui.control.Label
        nCcountEditField_2             matlab.ui.control.EditField
        Spectrometerdisplay2DropDownLabel  matlab.ui.control.Label
        Spectrometerdisplay2DropDown   matlab.ui.control.DropDown
        Spectrometer2SpinnerLabel      matlab.ui.control.Label
        Spectrometer2Spinner           matlab.ui.control.Spinner
        ResetButton                    matlab.ui.control.Button
        RightPanel                     matlab.ui.container.Panel
        UIAxes                         matlab.ui.control.UIAxes
        UIAxes2                        matlab.ui.control.UIAxes
        UIAxes3                        matlab.ui.control.UIAxes
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    
    properties (Access = private)
        % parameters for the main update loop
        
        main_loop; % self explanatory 
        is_timer_running = 0;
        

        % cameras and relevant PVs

        CHER_camera_PV = 'CMOS:LI20:3506';
        SYAG_camera_PV = 'CAMR:LI20:100';
        blen_PV = 'BLEN:LI14:888:BRAWBR';
        toro_PV = 'TORO:LI20:3255:TMIT';
        
        CHER_res;
        CHER_burn_spots = {[102 283 110 302], [111 309 116 320], [115 324 128 341], [115 364 121 370], [128 364 135 381]};
       
        % background subtraction

        bg_CHER;
        bg_SYAG;
        apply_backgrounds = 0;


        % energy calibration

        d_nom = 58.5;
        dy = 164.5;
        E_vals;

        % charge calibration

        charge_calibration_value = 7.5e-6 * ones([1 2040]); % pC / count
        %charge_calibration_value_SYAG = 5.2399e-3; % pC / count 
        charge_calibration_value_SYAG = 5.2399e-3 * ones([1 1192]); % pC / count 

        calibration_notch_position_intercept_PV = 'SIOC:SYS1:ML00:AO993';
        calibration_notch_position_slope_PV = 'SIOC:SYS1:ML00:AO994';
        calibration_notch_angle_offset_PV = 'SIOC:SYS1:ML00:AO997';
        calibration_notch_position_angle_slope_PV = 'SIOC:SYS1:ML00:AO538';

        ROI_SYAG_x = 1:1192;
        ROI_SYAG_y = 800:810;

        % waterfall arrays

        waterfall_array;
        cmap;
        cb;
        cb2;

        % spectrometer scalar arrays
        
        spec_blen_array
        spec_accelerated_charge_array
        spec_incoming_trailing_charge_array
        spec_charge_capture_array
        spec_energy_gain_array
        spec_energy_loss_array
        spec_efficiency_array

        trailing_charge_rolling;
        
        current_scalar_type_1 = 'line';
        current_scalar_type_2 = 'line';

        divide_blen_by = 1;

        loop_counter = 1;
        
        kill_switch_PV = 'SIOC:SYS1:ML00:AO910';
    end
    



    methods (Access = private)
        
        function update_acquisition_fcn(app, src, event)
            if lcaGet(app.kill_switch_PV)
                if app.is_timer_running
                app.is_timer_running = 0;
                app.AcquisitionstatusLamp.Color = 'r';
                pause(0.05)
                stop(app.main_loop)
                return
                end
            end
            
            
            % acquire CHER, SYAG and all relevant spectrometer scalars
            app.loop_counter = app.loop_counter + 1;
            
            if app.loop_counter == 10
                app.loop_counter = 1;
                java.lang.System.gc()
                app.reset_timer;
            end
            
            
            proj_CHER = app.get_camera_img(app.CHER_camera_PV);
            proj_SYAG = app.get_camera_img(app.SYAG_camera_PV);

            blen = lcaGet(app.blen_PV);
            
            % append to arrays

            [waterfall_column, accelerated_charge, incoming_trailing_charge, energy_gain, energy_loss, incoming_drive_charge, efficiency] = app.calculate_main(proj_CHER, proj_SYAG);
            [E_tick_list, E_tick_pos] = generate_E_ticks(app.E_vals, 10);
            
            
            if numel(app.trailing_charge_rolling) < 5
                app.trailing_charge_rolling = [app.trailing_charge_rolling incoming_trailing_charge];
            else
                app.trailing_charge_rolling = circshift(app.trailing_charge_rolling, 1);
                app.trailing_charge_rolling(1) = incoming_trailing_charge;
            end
            
            trailing_charge = mean(app.trailing_charge_rolling, "all");
            
            app.waterfall_array = circshift(app.waterfall_array, 1, 2);
            app.spec_blen_array = circshift(app.spec_blen_array, 1);
            app.spec_accelerated_charge_array = circshift(app.spec_accelerated_charge_array, 1);
            app.spec_incoming_trailing_charge_array = circshift(app.spec_incoming_trailing_charge_array, 1);
            app.spec_charge_capture_array = circshift(app.spec_charge_capture_array, 1);
            app.spec_energy_gain_array = circshift(app.spec_energy_gain_array, 1);
            app.spec_energy_loss_array = circshift(app.spec_energy_loss_array, 1);
            app.spec_efficiency_array = circshift(app.spec_efficiency_array, 1);
            
            app.waterfall_array(:,1) = waterfall_column;
            app.spec_blen_array(:,1) = blen;
            app.spec_accelerated_charge_array(1) = accelerated_charge;
            app.spec_incoming_trailing_charge_array(1) = trailing_charge;
            app.spec_charge_capture_array(1) = accelerated_charge/trailing_charge * 100;
            app.spec_energy_gain_array(1) = energy_gain;
            app.spec_energy_loss_array(1) = energy_loss;
            app.spec_efficiency_array(1) = efficiency;
            
            
            % display axes figures
            
            %cla(app.UIAxes, 'reset');
            app.UIAxes.Children.CData = flip(app.waterfall_array,2);
            %imagesc(app.UIAxes, app.waterfall_array);
            %xlabel(app.UIAxes, "Shots [live]")
            %ylabel(app.UIAxes, "Energy [GeV, LATEST]")
            %cb = colorbar(app.UIAxes);
            %cb.Label.String = 'Charge density [pC/GeV]';
            %colormap(app.UIAxes, app.cmap.wbgyr());
            app.UIAxes.CLim = [1 2^app.WaterfallSpinner.Value];
            %app.UIAxes.YLim = [1 2040];
            app.UIAxes.XLim = [1000-app.NumberofcolumnsEditField.Value 1000];
            set(app.UIAxes, 'YTick', E_tick_pos, 'YTickLabel', E_tick_list);
            pause(0.05)
            
            
            ylabel(app.UIAxes2, app.Spectrometerdisplay1DropDown.Value)
            %cla(app.UIAxes2, 'reset');
            
            %app.UIAxes3.Children.YData = flip(app.spec_blen_array/app.divide_blen_by);
            %app.UIAxes3.YLim = [0 100000/app.divide_blen_by];
            
            if strcmp(app.Spectrometerdisplay1DropDown.Value, 'S14 BLEN')
                app.UIAxes2.Children.YData = flip(app.spec_blen_array/app.divide_blen_by);
                app.UIAxes2.YLim = [0 100000/app.divide_blen_by];
            elseif strcmp(app.Spectrometerdisplay1DropDown.Value, 'Accelerated Charge [pC]')
                app.UIAxes2.Children.YData = flip(app.spec_accelerated_charge_array);
                %plot(app.UIAxes2, app.spec_accelerated_charge_array)
            elseif strcmp(app.Spectrometerdisplay1DropDown.Value, 'Initial Trailing Charge [pC]')
                app.UIAxes2.Children.YData = flip(app.spec_incoming_trailing_charge_array);
                %plot(app.UIAxes2, app.spec_incoming_trailing_charge_array)
            elseif strcmp(app.Spectrometerdisplay1DropDown.Value, 'Charge Capture [%]')
                app.UIAxes2.Children.YData = flip(app.spec_charge_capture_array);
                %plot(app.UIAxes2, app.spec_charge_capture_array)
            elseif strcmp(app.Spectrometerdisplay1DropDown.Value, 'Energy Gain [J]')
                app.UIAxes2.Children.YData = flip(app.spec_energy_gain_array);
                %plot(app.UIAxes2, app.spec_energy_gain_array)
            elseif strcmp(app.Spectrometerdisplay1DropDown.Value, 'Energy Loss [J]')
                app.UIAxes2.Children.YData = flip(app.spec_energy_loss_array);
                %plot(app.UIAxes2, app.spec_energy_loss_array)
            elseif strcmp(app.Spectrometerdisplay1DropDown.Value, 'Total transfer efficiency [%]')
                app.UIAxes2.Children.YData = flip(app.spec_efficiency_array);
            elseif strcmp(app.Spectrometerdisplay1DropDown.Value, 'Charge acceleration performance')
                app.UIAxes2.Children.YData = flip(app.spec_charge_capture_array);
                app.UIAxes2.Children.CData = flip(app.spec_accelerated_charge_array);
                ylabel(app.UIAxes2, 'Charge capture[%]')
                app.cb.Label.String = 'Accelerated charge [pC]';
            elseif strcmp(app.Spectrometerdisplay1DropDown.Value, 'Energy transfer performance')
                app.UIAxes2.Children.YData = flip(app.spec_efficiency_array);
                app.UIAxes2.Children.CData = flip(app.spec_energy_gain_array);
                ylabel(app.UIAxes2, 'Total transfer efficiency [%]')
                app.cb.Label.String = 'Energy gain [J]';
            end
            %xlabel(app.UIAxes2, "Shots [live]")
            
            
            if strcmp(app.Spectrometerdisplay2DropDown.Value, 'S14 BLEN')
                app.UIAxes3.Children.YData = flip(app.spec_blen_array/app.divide_blen_by);
                app.UIAxes3.YLim = [0 100000/app.divide_blen_by];
            elseif strcmp(app.Spectrometerdisplay2DropDown.Value, 'Accelerated Charge [pC]')
                app.UIAxes3.Children.YData = flip(app.spec_accelerated_charge_array);
                %plot(app.UIAxes2, app.spec_accelerated_charge_array)
            elseif strcmp(app.Spectrometerdisplay2DropDown.Value, 'Initial Trailing Charge [pC]')
                app.UIAxes3.Children.YData = flip(app.spec_incoming_trailing_charge_array);
                %plot(app.UIAxes2, app.spec_incoming_trailing_charge_array)
            elseif strcmp(app.Spectrometerdisplay2DropDown.Value, 'Charge Capture [%]')
                app.UIAxes3.Children.YData = flip(app.spec_charge_capture_array);
                %plot(app.UIAxes2, app.spec_charge_capture_array)
            elseif strcmp(app.Spectrometerdisplay2DropDown.Value, 'Energy Gain [J]')
                app.UIAxes3.Children.YData = flip(app.spec_energy_gain_array);
                %plot(app.UIAxes2, app.spec_energy_gain_array)
            elseif strcmp(app.Spectrometerdisplay2DropDown.Value, 'Energy Loss [J]')
                app.UIAxes3.Children.YData = flip(app.spec_energy_loss_array);
                %plot(app.UIAxes2, app.spec_energy_loss_array)
            elseif strcmp(app.Spectrometerdisplay2DropDown.Value, 'Total transfer efficiency [%]')
                app.UIAxes3.Children.YData = flip(app.spec_efficiency_array);
            elseif strcmp(app.Spectrometerdisplay2DropDown.Value, 'Charge acceleration performance')
                app.UIAxes3.Children.YData = flip(app.spec_charge_capture_array);
                app.UIAxes3.Children.CData = flip(app.spec_accelerated_charge_array);
                ylabel(app.UIAxes3, 'Charge capture[%]')
                app.cb2.Label.String = 'Accelerated charge [pC]';
            elseif strcmp(app.Spectrometerdisplay2DropDown.Value, 'Energy transfer performance')
                app.UIAxes3.Children.YData = flip(app.spec_efficiency_array);
                app.UIAxes3.Children.CData = flip(app.spec_energy_gain_array);
                ylabel(app.UIAxes3, 'Total transfer efficiency [%]')
                app.cb2.Label.String = 'Energy gain [J]';
            end
            
            app.UIAxes2.XLim = [1000-app.NumberofcolumnsEditField.Value 1000];
            app.UIAxes3.XLim = [1000-app.NumberofcolumnsEditField.Value 1000];
            
            if strcmp(app.current_scalar_type_1, 'scatter')
                if strcmp(app.Spectrometerdisplay1DropDown.Value, 'Charge acceleration performance')
                    app.UIAxes2.YLim = [0 100];
                else
                    app.UIAxes2.YLim = [0 8];
                end
                app.UIAxes2.CLim = [0 2^app.Spectrometer1Spinner.Value];
            else
                app.UIAxes2.YLim = [0 2^app.Spectrometer1Spinner.Value];
            end
            
            if strcmp(app.current_scalar_type_2, 'scatter')
                if strcmp(app.Spectrometerdisplay2DropDown.Value, 'Charge acceleration performance')
                    app.UIAxes3.YLim = [0 100];
                else
                    app.UIAxes3.YLim = [0 8];
                end
                app.UIAxes3.CLim = [0 2^app.Spectrometer2Spinner.Value];
            else
                app.UIAxes3.YLim = [0 2^app.Spectrometer2Spinner.Value];
            end

            %app.UIAxes2.XLim = [1 app.NumberofcolumnsEditField.Value];
            %grid(app.UIAxes2, 'on');
            pause(0.05)
            

            % calculate all spectrometer scalars

            app.S14BLENauEditField.Value = blen;
            app.AcceleratedchargepCEditField.Value = accelerated_charge;
            app.InitialtrailingchargepCEditField.Value = trailing_charge;
            app.ChargecaptureEditField.Value = accelerated_charge/trailing_charge * 100;
            app.EnergygainJEditField.Value = energy_gain;
            app.EnergylossJEditField.Value = energy_loss;
            app.DrivechargepCEditField.Value = incoming_drive_charge;
            app.TotalenergytransferefficiencyEditField.Value = efficiency;
            
        end

        function cam_proj = get_camera_img(app, camera_PV)
            array_data_PV = strcat(camera_PV, ':Image:ArrayData');
            size_0_PV = strcat(camera_PV, ':Image:ArraySize0_RBV');
            size_1_PV = strcat(camera_PV, ':Image:ArraySize1_RBV');

            cam_array = lcaGet(array_data_PV);
            size_0 = lcaGet(size_0_PV);
            size_1 = lcaGet(size_1_PV);
            
            cam_image = reshape(cam_array(1:size_0*size_1), size_0, []);
            
            if strcmp(camera_PV, app.CHER_camera_PV)
                if app.apply_backgrounds
                    cam_image = cam_image - app.bg_CHER;
                end
                cam_image = fix_burns(cam_image(1040:1800, :), app.CHER_burn_spots);
                cam_proj = sum(cam_image, 1);
            else
                if app.apply_backgrounds
                    cam_image = cam_image - app.bg_SYAG;
                end
                cam_image = flip(cam_image, 1);
                cam_proj = sum(cam_image(:,app.ROI_SYAG_y), 2);
            end
        end
        
        function cam_image = get_bg(app, camera_PV)
            array_data_PV = strcat(camera_PV, ':Image:ArrayData');
            size_0_PV = strcat(camera_PV, ':Image:ArraySize0_RBV');
            size_1_PV = strcat(camera_PV, ':Image:ArraySize1_RBV');

            cam_array = lcaGet(array_data_PV);
            size_0 = lcaGet(size_0_PV);
            size_1 = lcaGet(size_1_PV);
            
            cam_image = reshape(cam_array(1:size_0*size_1), size_0, []);
        end


        function [waterfall_column, accelerated_charge, incoming_trailing_charge, energy_gain, energy_loss, incoming_drive_charge, efficiency] = calculate_main(app, proj_CHER2, proj_SYAG)
            px_range = 1:2040;
            
            proj_CHER = proj_CHER2(px_range);

            y_vals = (1:2040) * app.CHER_res / 1000;
            y_vals = y_vals(end) - y_vals;
            E_bend = lcaGet('LI20:LGPS:3330:BACT');

            app.E_vals = app.d_nom * E_bend./(app.dy - y_vals);
            app.E_vals = app.E_vals(px_range);
            
            dEdy = app.d_nom * E_bend./(app.dy - y_vals).^2 * app.CHER_res / 1000; % GeV/mm * um/px * 1e-3
            dEdy = dEdy(px_range);
            %dEdy = app.E_vals * app.CHER_res / 1000; % GeV/mm * um/px * 1e-3
            waterfall_column = proj_CHER ./ dEdy .* app.charge_calibration_value;
            
            [~,threshold] = min(abs(app.E_vals - app.AccelerationthresholdGeVEditField.Value));
            if threshold > 1
                accelerated_charge = sum(proj_CHER(1:threshold) .* app.charge_calibration_value(1:threshold));
                energy_gain = sum(proj_CHER(1:threshold) .* (app.E_vals(1:threshold) - 10) .* app.charge_calibration_value(1:threshold)) * 1e-3;
            else
                accelerated_charge = 0;
                energy_gain = 0;
            end
            
            if strcmp(app.TwobunchmodeDropDown.Value, 'Notched [automatic]')
                notch_pos_current = lcaGet('COLL:LI20:2069:MOTR.RBV');
                notch_angle_current = lcaGet('COLL:LI20:2073:MOTR.RBV');
                
                notch_center_px = (notch_pos_current - lcaGet(app.calibration_notch_position_intercept_PV) - lcaGet(app.calibration_notch_position_angle_slope_PV) * (notch_angle_current - lcaGet(app.calibration_notch_angle_offset_PV)))/lcaGet(app.calibration_notch_position_slope_PV);
                app.TrailingbunchcutSYAGpxEditField.Value = notch_center_px;
                notch_center_px = int32(notch_center_px);
                
                if app.CurrentcompressionButtonGroup.SelectedObject == app.OvercompressedButton
                    witness_charge = sum(proj_SYAG(notch_center_px:app.ROI_SYAG_x(end)) .* app.charge_calibration_value_SYAG(notch_center_px:app.ROI_SYAG_x(end))');
                    drive_charge = sum(proj_SYAG(app.ROI_SYAG_x(1):notch_center_px) .* app.charge_calibration_value_SYAG(app.ROI_SYAG_x(1):notch_center_px)');
                else
                    witness_charge = sum(proj_SYAG(app.ROI_SYAG_x(1):notch_center_px) .* app.charge_calibration_value_SYAG(app.ROI_SYAG_x(1):notch_center_px)');
                    drive_charge = sum(proj_SYAG_2(notch_center_px:app.ROI_SYAG_x(end)) .* app.charge_calibration_value_SYAG(notch_center_px:app.ROI_SYAG_x(end))');
                end
            elseif strcmp(app.TwobunchmodeDropDown.Value, 'Photocathode [manual]')
                notch_center_px = int32(app.TrailingbunchcutSYAGpxEditField.Value);
                
                if app.CurrentcompressionButtonGroup.SelectedObject == app.OvercompressedButton
                    witness_charge = sum(proj_SYAG(notch_center_px:app.ROI_SYAG_x(end)) .* app.charge_calibration_value_SYAG(notch_center_px:app.ROI_SYAG_x(end))');
                    drive_charge = sum(proj_SYAG(app.ROI_SYAG_x(1):notch_center_px) .* app.charge_calibration_value_SYAG(app.ROI_SYAG_x(1):notch_center_px)');
                else
                    witness_charge = sum(proj_SYAG(app.ROI_SYAG_x(1):notch_center_px) .* app.charge_calibration_value_SYAG(app.ROI_SYAG_x(1):notch_center_px)');
                    drive_charge = sum(proj_SYAG(notch_center_px:app.ROI_SYAG_x(end)) .* app.charge_calibration_value_SYAG(notch_center_px:app.ROI_SYAG_x(end))');
                end
            elseif strcmp(app.TwobunchmodeDropDown.Value, 'Specify fixed bunch charges')
                witness_charge = app.TrailingbunchcutSYAGpxEditField.Value;
                drive_charge = app.DrivechargepCEditField.Value;
            end
            
            if strcmp(app.SYAGchargecalibrationtypeDropDown.Value, 'TORO 3255')
                toro_reading = lcaGet(app.toro_PV) * 1.6022e-7;
                incoming_trailing_charge = witness_charge/(witness_charge+drive_charge)*toro_reading;
                incoming_drive_charge = drive_charge/(witness_charge+drive_charge)*toro_reading;
            else
                incoming_trailing_charge = witness_charge;
                incoming_drive_charge = drive_charge; 
            end
            
            total_charge_initial = incoming_trailing_charge + incoming_drive_charge;
            
            energy_loss = 10 * total_charge_initial - sum(app.E_vals .* proj_CHER .* app.charge_calibration_value) - (total_charge_initial - sum(proj_CHER .* app.charge_calibration_value)) * 10;
            energy_loss = energy_loss * 1e-3;
            
            lcaPut('SIOC:SYS1:ML00:AO545', energy_loss);
            
            efficiency = energy_gain/(incoming_drive_charge * 10 * 1e-3) * 100;
            
        end
        
        function reset_timer(app)
            if app.is_timer_running
                app.is_timer_running = 0;
                app.AcquisitionstatusLamp.Color = 'r';
                pause(0.05)
                stop(app.main_loop)
            end            
            
            if ~app.is_timer_running
                app.is_timer_running = 1;
                app.AcquisitionstatusLamp.Color = 'g';
                pause(0.05)
                start(app.main_loop)
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % initialize waterfall and property arrays 
            app.waterfall_array = zeros([2040 app.NumberofcolumnsEditField.Value]);

            app.spec_blen_array = zeros([1 app.NumberofcolumnsEditField.Value]);
            app.spec_accelerated_charge_array = zeros([1 app.NumberofcolumnsEditField.Value]);
            app.spec_incoming_trailing_charge_array = zeros([1 app.NumberofcolumnsEditField.Value]);
            app.spec_charge_capture_array = zeros([1 app.NumberofcolumnsEditField.Value]);
            app.spec_energy_gain_array = zeros([1 app.NumberofcolumnsEditField.Value]);
            app.spec_energy_loss_array = zeros([1 app.NumberofcolumnsEditField.Value]);
            app.spec_efficiency_array = zeros([1 app.NumberofcolumnsEditField.Value]);
            
            app.CHER_res = lcaGet(strcat(app.CHER_camera_PV, ':RESOLUTION'));
            
            app.cmap = custom_cmap();

            %app.UIAxes.InnerPosition = [28 449 800 400];
            %app.UIAxes.PositionConstraint = 'innerposition';
            imagesc(app.UIAxes, app.waterfall_array);
            xlabel(app.UIAxes, "Shots [live]")
            ylabel(app.UIAxes, "Energy [GeV, LATEST]")
            app.UIAxes.CLim = [0 2^app.WaterfallSpinner.Value];
            app.UIAxes.YLim = [1 2040];
            app.UIAxes.XLim = [1 app.NumberofcolumnsEditField.Value];
            %app.UIAxes.XDir = 'reverse';
            cba = colorbar(app.UIAxes);
            cba.Label.String = 'Charge density [pC/GeV]';
            colormap(app.UIAxes, app.cmap.wbgyr());

            pause(0.05)
            
            %app.UIAxes3.InnerPosition = [28 15 400 150];
            %app.UIAxes3.PositionConstraint = 'innerposition';
            %plot(app.UIAxes3, app.spec_blen_array/app.S14BLENatpeakcompressionEditField.Value)
            plot(app.UIAxes3, app.spec_energy_loss_array)
            xlabel(app.UIAxes3, "Shots [live]")
            ylabel(app.UIAxes3, app.Spectrometerdisplay2DropDown.Value)
            app.UIAxes3.YLim = [0 2^app.Spectrometer2Spinner.Value];
            app.UIAxes3.XLim = [1 app.NumberofcolumnsEditField.Value];
            %app.UIAxes3.XDir = 'reverse';
            grid(app.UIAxes3, 'on');
            pause(0.05)
            
            %app.UIAxes2.InnerPosition = [25 220 400 150];
            %app.UIAxes2.PositionConstraint = 'innerposition';            
            plot(app.UIAxes2, app.spec_accelerated_charge_array)
            xlabel(app.UIAxes2, "Shots [live]")
            ylabel(app.UIAxes2, app.Spectrometerdisplay1DropDown.Value)
            app.UIAxes2.YLim = [0 2^app.Spectrometer1Spinner.Value];
            app.UIAxes2.XLim = [1 app.NumberofcolumnsEditField.Value];
            %app.UIAxes2.XDir = 'reverse';
            grid(app.UIAxes2, 'on');
            pause(0.05)
            
            app.main_loop = timer("ExecutionMode","fixedRate","Period",1/app.AcquisitionrateHzEditField.Value, ...
    "BusyMode","drop","TimerFcn",@app.update_acquisition_fcn) ;
        end

        % Button pushed function: StartacquiringButton
        function StartacquiringButtonPushed(app, event)
            if ~app.is_timer_running
                lcaPut(app.kill_switch_PV, 0);
                app.is_timer_running = 1;
                app.AcquisitionstatusLamp.Color = 'g';
                pause(0.05)
                start(app.main_loop)
            end
        end

        % Button pushed function: StopacquiringButton
        function StopacquiringButtonPushed(app, event)

            if app.is_timer_running
                app.is_timer_running = 0;
                app.AcquisitionstatusLamp.Color = 'r';
                pause(0.05)
                stop(app.main_loop)
            end
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            if app.is_timer_running
                app.AcquisitionstatusLamp.Color = 'r';
                pause(0.05)
                stop(app.main_loop)
            end
            delete(app.main_loop)
            delete(app)
        end

        % Value changed function: AcquisitionrateHzEditField
        function AcquisitionrateHzEditFieldValueChanged(app, event)
            period = 1/app.AcquisitionrateHzEditField.Value;
            if app.is_timer_running
                app.AcquisitionstatusLamp.Color = 'r';
                pause(0.05)
                stop(app.main_loop)
                app.is_timer_running = 0;

                app.main_loop = timer("ExecutionMode","fixedRate","Period",period, ...
    "BusyMode","drop","TimerFcn",@app.update_acquisition_fcn);
                app.is_timer_running = 1;
                app.AcquisitionstatusLamp.Color = 'g';
                start(app.main_loop)
            end
        end

        % Button pushed function: TakebackgroundsButton
        function TakebackgroundsButtonPushed(app, event)
            b_CHER = app.get_bg(app.CHER_camera_PV);
            b_SYAG = app.get_bg(app.SYAG_camera_PV);
            
            save("/home/fphysics/rego/waterfall_live_backgrounds.mat", "b_CHER", "b_SYAG")
            
            app.bg_CHER = b_CHER;
            app.bg_SYAG = b_SYAG;
            
            app.ApplybackgroundsButton.Enable = 'on';
        end

        % Value changed function: ApplybackgroundsButton
        function ApplybackgroundsButtonValueChanged(app, event)
            value = app.ApplybackgroundsButton.Value;
            if value
                try 
                    bg_mat = load("/home/fphysics/rego/waterfall_live_backgrounds.mat");
                    app.bg_CHER = bg_mat.b_CHER;
                    app.bg_SYAG = bg_mat.b_SYAG;
                    app.apply_backgrounds = 1;
                catch
                    app.apply_backgrounds = 0;
                end
            else
                app.apply_backgrounds = 0;
            end
        end

        % Button pushed function: ClearwaterfallButton
        function ClearwaterfallButtonPushed(app, event)
            app.waterfall_array = zeros([2040 app.NumberofcolumnsEditField.Value]);

            app.spec_blen_array = zeros([1 app.NumberofcolumnsEditField.Value]);
            app.spec_accelerated_charge_array = zeros([1 app.NumberofcolumnsEditField.Value]);
            app.spec_incoming_trailing_charge_array = zeros([1 app.NumberofcolumnsEditField.Value]);
            app.spec_charge_capture_array = zeros([1 app.NumberofcolumnsEditField.Value]);
            app.spec_energy_gain_array = zeros([1 app.NumberofcolumnsEditField.Value]);
            app.spec_energy_loss_array = zeros([1 app.NumberofcolumnsEditField.Value]);
        end

        % Button pushed function: PrinttologButton
        function PrinttologButtonPushed(app, event)
            %util_printLog_wComments(app.UIAxes,'Matlab app','E300: CHER waterfall live feed',string(datetime))
            %util_printLog_wComments(app.UIAxes2,'Matlab app',strcat('E300: CHER waterfall live feed', app.Spectrometerdisplay1DropDown.Value),string(datetime))
        end

        % Value changed function: CHERchargecalibrationtypeDropDown
        function CHERchargecalibrationtypeDropDownValueChanged(app, event)
            value = app.CHERchargecalibrationtypeDropDown.Value;
            if strcmp(value, 'Simple')
                app.nCcountEditFieldLabel.Text = 'nC / count';
                app.nCcountEditField.Value = '7.5e-9';
            else
                app.nCcountEditFieldLabel.Text = 'Path to calibration';
                app.nCcountEditField.Value = '/home/fphysics/rego/matlab_scripts/detailed charge calibration/charge_calibration.mat';
            end
        end

        % Value changed function: nCcountEditField
        function nCcountEditFieldValueChanged2(app, event)
            value = app.nCcountEditField.Value;
            selection = app.CHERchargecalibrationtypeDropDown.Value;
            if strcmp(selection, 'Simple')
                app.charge_calibration_value = str2double(value) * ones([1 2040]) * 1e3;
            else
                charge_cal_import = load(value);
                app.charge_calibration_value = charge_cal_import.charge_cal;
            end
        end

        % Value changed function: S14BLENatpeakcompressionEditField
        function S14BLENatpeakcompressionEditFieldValueChanged(app, event)
            value = app.S14BLENatpeakcompressionEditField.Value;
            if value < 100000 && value > 0
                app.UsenormalizedBLENCheckBox.Enable = 'on';
            end
        end

        % Value changed function: Spectrometer1Spinner
        function Spectrometer1SpinnerValueChanged(app, event)
            value = app.Spectrometer1Spinner.Value;
            if strcmp(app.current_scalar_type_1, 'line')
                app.UIAxes2.YLim = [0 2^value];
            elseif strcmp(app.current_scalar_type_1, 'scatter')
                app.UIAxes2.CLim = [0 2^value];
            end
        end

        % Value changed function: WaterfallSpinner
        function WaterfallSpinnerValueChanged(app, event)
            value = app.Spectrometer1Spinner.Value;
            app.UIAxes.CLim = [0 2^value];
        end

        % Value changed function: TwobunchmodeDropDown
        function TwobunchmodeDropDownValueChanged(app, event)
            value = app.TwobunchmodeDropDown.Value;
            if strcmp(value, 'Specify fixed bunch charges')
                app.TrailingbunchcutSYAGpxEditFieldLabel.Text = 'Trailing charge [pC]';
            else
                app.TrailingbunchcutSYAGpxEditFieldLabel.Text = 'Trailing bunch cut [SYAG px]';
            end
        end

        % Value changed function: Spectrometerdisplay1DropDown
        function Spectrometerdisplay1DropDownValueChanged(app, event)
            value = app.Spectrometerdisplay1DropDown.Value;
            if (strcmp(value, 'Charge acceleration performance') || strcmp(value, 'Energy transfer performance'))
                app.current_scalar_type_1 = 'scatter';
                cla(app.UIAxes2, 'reset')
                if strcmp(value, 'Charge acceleration performance')
                    scatter(app.UIAxes2, 1:app.NumberofcolumnsEditField.Value, app.spec_charge_capture_array, [], app.spec_accelerated_charge_array, 'filled')
                    ylabel(app.UIAxes2, 'Charge capture [%]')
                    app.cb = colorbar(app.UIAxes2);
                    app.cb.Label.String = 'Accelerated charge [pC]';
                    app.UIAxes2.YLim = [0 100];
                else
                    scatter(app.UIAxes2, 1:app.NumberofcolumnsEditField.Value, app.spec_efficiency_array, [], app.spec_energy_gain_array, 'filled')
                    ylabel(app.UIAxes2, 'Total transfer efficiency [%]')
                    app.cb = colorbar(app.UIAxes2);
                    app.cb.Label.String = 'Energy gain [J]';
                    app.UIAxes2.YLim = [0 8];
                end
                xlabel(app.UIAxes2, "Shots [live]")
                app.UIAxes2.CLim = [0 2^app.Spectrometer1Spinner.Value];
                app.UIAxes2.XLim = [1 app.NumberofcolumnsEditField.Value];
                grid(app.UIAxes2, 'on');
                pause(0.05);
            elseif ~(strcmp(value, 'Charge acceleration performance') || strcmp(value, 'Energy transfer performance')) && strcmp(app.current_scalar_type_1, 'scatter')
                app.current_scalar_type_1 = 'line';
                cla(app.UIAxes2, 'reset')
                if strcmp(app.Spectrometerdisplay1DropDown.Value, 'Accelerated Charge [pC]')
                    plot(app.UIAxes2, app.spec_accelerated_charge_array)
                elseif strcmp(app.Spectrometerdisplay1DropDown.Value, 'Initial Trailing Charge [pC]')
                    plot(app.UIAxes2, app.spec_incoming_trailing_charge_array)
                elseif strcmp(app.Spectrometerdisplay1DropDown.Value, 'Charge Capture [%]')
                    plot(app.UIAxes2, app.spec_charge_capture_array)
                elseif strcmp(app.Spectrometerdisplay1DropDown.Value, 'Energy Gain [J]')
                    plot(app.UIAxes2, app.spec_energy_gain_array)
                elseif strcmp(app.Spectrometerdisplay1DropDown.Value, 'Energy Loss [J]')
                    plot(app.UIAxes2, app.spec_energy_loss_array)
                elseif strcmp(app.Spectrometerdisplay1DropDown.Value, 'Total transfer efficiency [%]')
                    plot(app.UIAxes2, app.spec_efficiency_array)
                end
                xlabel(app.UIAxes2, "Shots [live]")
                ylabel(app.UIAxes2, app.Spectrometerdisplay1DropDown.Value)
                app.UIAxes2.YLim = [0 2^app.Spectrometer1Spinner.Value];
                app.UIAxes2.XLim = [1 app.NumberofcolumnsEditField.Value];
                grid(app.UIAxes2, 'on');
                pause(0.05);
            end
        end

        % Value changed function: SYAGchargecalibrationtypeDropDown
        function SYAGchargecalibrationtypeDropDownValueChanged(app, event)
            value = app.SYAGchargecalibrationtypeDropDown.Value;
            if strcmp(value, 'Simple')
                app.nCcountEditField_2Label.Text = 'nC / count';
                app.nCcountEditField_2.Value = '5.24e-6';
            elseif strcmp(value, 'Detailed')
                app.nCcountEditField_2Label.Text = 'Path to calibration';
                app.nCcountEditField_2.Value = '/home/fphysics/rego/matlab_scripts/detailed charge calibration/charge_calibration.mat';
            else
                app.nCcountEditField_2Label.Text = 'nC / count';
                app.nCcountEditField_2.Value = '5.24e-6';
            end
        end

        % Value changed function: nCcountEditField_2
        function nCcountEditField_2ValueChanged(app, event)
            value = app.nCcountEditField_2.Value;
            selection = app.SYAGchargecalibrationtypeDropDown.Value;
            if strcmp(selection, 'Simple')
                app.charge_calibration_value_SYAG = str2double(value) * ones([1 1192]) * 1e3;
            elseif strcmp(selection, 'Detailed')
                charge_cal_import = load(value);
                app.charge_calibration_value = charge_cal_import.charge_cal;
            end
        end

        % Value changed function: UsenormalizedBLENCheckBox
        function UsenormalizedBLENCheckBoxValueChanged(app, event)
            value = app.UsenormalizedBLENCheckBox.Value;
            if value
                app.divide_blen_by = app.S14BLENatpeakcompressionEditField.Value;
            else
                app.divide_blen_by = 1;
            end
        end

        % Value changed function: Spectrometerdisplay2DropDown
        function Spectrometerdisplay2DropDownValueChanged(app, event)
            value = app.Spectrometerdisplay2DropDown.Value;
            if (strcmp(value, 'Charge acceleration performance') || strcmp(value, 'Energy transfer performance'))
                app.current_scalar_type_2 = 'scatter';
                cla(app.UIAxes3, 'reset')
                if strcmp(value, 'Charge acceleration performance')
                    scatter(app.UIAxes3, 1:app.NumberofcolumnsEditField.Value, app.spec_charge_capture_array, [], app.spec_accelerated_charge_array, 'filled')
                    ylabel(app.UIAxes3, 'Charge capture [%]')
                    app.cb2 = colorbar(app.UIAxes3);
                    app.cb2.Label.String = 'Accelerated charge [pC]';
                    app.UIAxes3.YLim = [0 100];
                else
                    scatter(app.UIAxes3, 1:app.NumberofcolumnsEditField.Value, app.spec_efficiency_array, [], app.spec_energy_gain_array, 'filled')
                    ylabel(app.UIAxes3, 'Total transfer efficiency [%]')
                    app.cb2 = colorbar(app.UIAxes3);
                    app.cb2.Label.String = 'Energy gain [J]';
                    app.UIAxes3.YLim = [0 8];
                end
                xlabel(app.UIAxes3, "Shots [live]")
                app.UIAxes3.CLim = [0 2^app.Spectrometer2Spinner.Value];
                app.UIAxes3.XLim = [1 app.NumberofcolumnsEditField.Value];
                grid(app.UIAxes3, 'on');
                pause(0.05);
            elseif ~(strcmp(value, 'Charge acceleration performance') || strcmp(value, 'Energy transfer performance')) && strcmp(app.current_scalar_type_2, 'scatter')
                app.current_scalar_type_2 = 'line';
                cla(app.UIAxes3, 'reset')
                if strcmp(app.Spectrometerdisplay2DropDown.Value, 'Accelerated Charge [pC]')
                    plot(app.UIAxes3, app.spec_accelerated_charge_array)
                elseif strcmp(app.Spectrometerdisplay2DropDown.Value, 'Initial Trailing Charge [pC]')
                    plot(app.UIAxes3, app.spec_incoming_trailing_charge_array)
                elseif strcmp(app.Spectrometerdisplay2DropDown.Value, 'Charge Capture [%]')
                    plot(app.UIAxes3, app.spec_charge_capture_array)
                elseif strcmp(app.Spectrometerdisplay2DropDown.Value, 'Energy Gain [J]')
                    plot(app.UIAxes3, app.spec_energy_gain_array)
                elseif strcmp(app.Spectrometerdisplay2DropDown.Value, 'Energy Loss [J]')
                    plot(app.UIAxes3, app.spec_energy_loss_array)
                elseif strcmp(app.Spectrometerdisplay2DropDown.Value, 'Total transfer efficiency [%]')
                    plot(app.UIAxes3, app.spec_efficiency_array)
                end
                xlabel(app.UIAxes3, "Shots [live]")
                ylabel(app.UIAxes3, app.Spectrometerdisplay2DropDown.Value)
                app.UIAxes3.YLim = [0 2^app.Spectrometer2Spinner.Value];
                app.UIAxes3.XLim = [1 app.NumberofcolumnsEditField.Value];
                grid(app.UIAxes3, 'on');
                pause(0.05);
            end
        end

        % Button pushed function: ResetButton
        function ResetButtonPushed(app, event)
            if app.is_timer_running
                app.is_timer_running = 0;
                app.AcquisitionstatusLamp.Color = 'r';
                pause(0.05)
                stop(app.main_loop)
            end            
            
            if ~app.is_timer_running
                app.is_timer_running = 1;
                app.AcquisitionstatusLamp.Color = 'g';
                pause(0.05)
                start(app.main_loop)
            end
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {942, 942};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {342, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 1420 942];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {342, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create PWFALiveSpectrometerLabel
            app.PWFALiveSpectrometerLabel = uilabel(app.LeftPanel);
            app.PWFALiveSpectrometerLabel.HorizontalAlignment = 'center';
            app.PWFALiveSpectrometerLabel.FontSize = 24;
            app.PWFALiveSpectrometerLabel.FontWeight = 'bold';
            app.PWFALiveSpectrometerLabel.Position = [29 889 294 31];
            app.PWFALiveSpectrometerLabel.Text = 'PWFA Live Spectrometer';

            % Create StartacquiringButton
            app.StartacquiringButton = uibutton(app.LeftPanel, 'push');
            app.StartacquiringButton.ButtonPushedFcn = createCallbackFcn(app, @StartacquiringButtonPushed, true);
            app.StartacquiringButton.Position = [29 859 87 22];
            app.StartacquiringButton.Text = 'Start acquiring';

            % Create StopacquiringButton
            app.StopacquiringButton = uibutton(app.LeftPanel, 'push');
            app.StopacquiringButton.ButtonPushedFcn = createCallbackFcn(app, @StopacquiringButtonPushed, true);
            app.StopacquiringButton.Position = [140 859 87 22];
            app.StopacquiringButton.Text = 'Stop acquiring';

            % Create AcquisitionrateHzLabel
            app.AcquisitionrateHzLabel = uilabel(app.LeftPanel);
            app.AcquisitionrateHzLabel.HorizontalAlignment = 'right';
            app.AcquisitionrateHzLabel.Position = [155 786 112 22];
            app.AcquisitionrateHzLabel.Text = 'Acquisition rate [Hz]';

            % Create AcquisitionrateHzEditField
            app.AcquisitionrateHzEditField = uieditfield(app.LeftPanel, 'numeric');
            app.AcquisitionrateHzEditField.Limits = [0.1 5];
            app.AcquisitionrateHzEditField.ValueDisplayFormat = '%.2f';
            app.AcquisitionrateHzEditField.ValueChangedFcn = createCallbackFcn(app, @AcquisitionrateHzEditFieldValueChanged, true);
            app.AcquisitionrateHzEditField.Position = [277 785 43 22];
            app.AcquisitionrateHzEditField.Value = 2;

            % Create AcquisitionstatusLabel
            app.AcquisitionstatusLabel = uilabel(app.LeftPanel);
            app.AcquisitionstatusLabel.HorizontalAlignment = 'center';
            app.AcquisitionstatusLabel.Position = [37 816 104 30];
            app.AcquisitionstatusLabel.Text = 'Acquisition status';

            % Create AcquisitionstatusLamp
            app.AcquisitionstatusLamp = uilamp(app.LeftPanel);
            app.AcquisitionstatusLamp.Position = [75 788 27 27];
            app.AcquisitionstatusLamp.Color = [1 0 0];

            % Create Spectrometerdisplay1DropDownLabel
            app.Spectrometerdisplay1DropDownLabel = uilabel(app.LeftPanel);
            app.Spectrometerdisplay1DropDownLabel.HorizontalAlignment = 'right';
            app.Spectrometerdisplay1DropDownLabel.Position = [-1 319 128 22];
            app.Spectrometerdisplay1DropDownLabel.Text = 'Spectrometer display 1';

            % Create Spectrometerdisplay1DropDown
            app.Spectrometerdisplay1DropDown = uidropdown(app.LeftPanel);
            app.Spectrometerdisplay1DropDown.Items = {'Accelerated Charge [pC]', 'Initial Trailing Charge [pC]', 'Charge Capture [%]', 'Energy Gain [J]', 'Energy Loss [J]', 'Total transfer efficiency [%]', 'Charge acceleration performance', 'Energy transfer performance', 'S14 BLEN'};
            app.Spectrometerdisplay1DropDown.ValueChangedFcn = createCallbackFcn(app, @Spectrometerdisplay1DropDownValueChanged, true);
            app.Spectrometerdisplay1DropDown.Position = [133 319 203 22];
            app.Spectrometerdisplay1DropDown.Value = 'Accelerated Charge [pC]';

            % Create AccelerationthresholdGeVEditFieldLabel
            app.AccelerationthresholdGeVEditFieldLabel = uilabel(app.LeftPanel);
            app.AccelerationthresholdGeVEditFieldLabel.HorizontalAlignment = 'right';
            app.AccelerationthresholdGeVEditFieldLabel.Position = [45 574 158 22];
            app.AccelerationthresholdGeVEditFieldLabel.Text = 'Acceleration threshold [GeV]';

            % Create AccelerationthresholdGeVEditField
            app.AccelerationthresholdGeVEditField = uieditfield(app.LeftPanel, 'numeric');
            app.AccelerationthresholdGeVEditField.Position = [218 574 100 22];
            app.AccelerationthresholdGeVEditField.Value = 11;

            % Create CurrentcompressionButtonGroup
            app.CurrentcompressionButtonGroup = uibuttongroup(app.LeftPanel);
            app.CurrentcompressionButtonGroup.TitlePosition = 'centertop';
            app.CurrentcompressionButtonGroup.Title = 'Current compression';
            app.CurrentcompressionButtonGroup.Position = [29 696 123 77];

            % Create OvercompressedButton
            app.OvercompressedButton = uitogglebutton(app.CurrentcompressionButtonGroup);
            app.OvercompressedButton.Text = 'Overcompressed';
            app.OvercompressedButton.Position = [9 4 106 22];
            app.OvercompressedButton.Value = true;

            % Create UndercompressedButton
            app.UndercompressedButton = uitogglebutton(app.CurrentcompressionButtonGroup);
            app.UndercompressedButton.Text = 'Undercompressed';
            app.UndercompressedButton.Position = [6 31 113 22];

            % Create TakebackgroundsButton
            app.TakebackgroundsButton = uibutton(app.LeftPanel, 'push');
            app.TakebackgroundsButton.ButtonPushedFcn = createCallbackFcn(app, @TakebackgroundsButtonPushed, true);
            app.TakebackgroundsButton.Position = [197 723 112 22];
            app.TakebackgroundsButton.Text = 'Take backgrounds';

            % Create S14BLENatpeakcompressionEditFieldLabel
            app.S14BLENatpeakcompressionEditFieldLabel = uilabel(app.LeftPanel);
            app.S14BLENatpeakcompressionEditFieldLabel.HorizontalAlignment = 'right';
            app.S14BLENatpeakcompressionEditFieldLabel.Position = [29 625 175 22];
            app.S14BLENatpeakcompressionEditFieldLabel.Text = 'S14 BLEN at peak compression';

            % Create S14BLENatpeakcompressionEditField
            app.S14BLENatpeakcompressionEditField = uieditfield(app.LeftPanel, 'numeric');
            app.S14BLENatpeakcompressionEditField.Limits = [0 100000];
            app.S14BLENatpeakcompressionEditField.ValueChangedFcn = createCallbackFcn(app, @S14BLENatpeakcompressionEditFieldValueChanged, true);
            app.S14BLENatpeakcompressionEditField.Position = [219 625 100 22];

            % Create UsenormalizedBLENCheckBox
            app.UsenormalizedBLENCheckBox = uicheckbox(app.LeftPanel);
            app.UsenormalizedBLENCheckBox.ValueChangedFcn = createCallbackFcn(app, @UsenormalizedBLENCheckBoxValueChanged, true);
            app.UsenormalizedBLENCheckBox.Enable = 'off';
            app.UsenormalizedBLENCheckBox.Text = 'Use normalized BLEN';
            app.UsenormalizedBLENCheckBox.Position = [106 605 140 22];

            % Create ClearwaterfallButton
            app.ClearwaterfallButton = uibutton(app.LeftPanel, 'push');
            app.ClearwaterfallButton.ButtonPushedFcn = createCallbackFcn(app, @ClearwaterfallButtonPushed, true);
            app.ClearwaterfallButton.Position = [41 659 100 22];
            app.ClearwaterfallButton.Text = 'Clear waterfall';

            % Create CHERchargecalibrationtypeDropDownLabel
            app.CHERchargecalibrationtypeDropDownLabel = uilabel(app.LeftPanel);
            app.CHERchargecalibrationtypeDropDownLabel.HorizontalAlignment = 'right';
            app.CHERchargecalibrationtypeDropDownLabel.Position = [18 540 164 22];
            app.CHERchargecalibrationtypeDropDownLabel.Text = 'CHER charge calibration type';

            % Create CHERchargecalibrationtypeDropDown
            app.CHERchargecalibrationtypeDropDown = uidropdown(app.LeftPanel);
            app.CHERchargecalibrationtypeDropDown.Items = {'Simple', 'Detailed'};
            app.CHERchargecalibrationtypeDropDown.ValueChangedFcn = createCallbackFcn(app, @CHERchargecalibrationtypeDropDownValueChanged, true);
            app.CHERchargecalibrationtypeDropDown.Position = [197 540 117 22];
            app.CHERchargecalibrationtypeDropDown.Value = 'Simple';

            % Create AcceleratedchargepCEditFieldLabel
            app.AcceleratedchargepCEditFieldLabel = uilabel(app.LeftPanel);
            app.AcceleratedchargepCEditFieldLabel.HorizontalAlignment = 'right';
            app.AcceleratedchargepCEditFieldLabel.Position = [72 228 134 22];
            app.AcceleratedchargepCEditFieldLabel.Text = 'Accelerated charge [pC]';

            % Create AcceleratedchargepCEditField
            app.AcceleratedchargepCEditField = uieditfield(app.LeftPanel, 'numeric');
            app.AcceleratedchargepCEditField.ValueDisplayFormat = '%.f';
            app.AcceleratedchargepCEditField.Position = [221 228 100 22];

            % Create InitialtrailingchargepCEditFieldLabel
            app.InitialtrailingchargepCEditFieldLabel = uilabel(app.LeftPanel);
            app.InitialtrailingchargepCEditFieldLabel.HorizontalAlignment = 'right';
            app.InitialtrailingchargepCEditFieldLabel.Position = [69 203 137 22];
            app.InitialtrailingchargepCEditFieldLabel.Text = 'Initial trailing charge [pC]';

            % Create InitialtrailingchargepCEditField
            app.InitialtrailingchargepCEditField = uieditfield(app.LeftPanel, 'numeric');
            app.InitialtrailingchargepCEditField.ValueDisplayFormat = '%.2f';
            app.InitialtrailingchargepCEditField.Position = [221 203 100 22];

            % Create ChargecaptureEditFieldLabel
            app.ChargecaptureEditFieldLabel = uilabel(app.LeftPanel);
            app.ChargecaptureEditFieldLabel.HorizontalAlignment = 'right';
            app.ChargecaptureEditFieldLabel.Position = [98 143 108 22];
            app.ChargecaptureEditFieldLabel.Text = 'Charge capture [%]';

            % Create ChargecaptureEditField
            app.ChargecaptureEditField = uieditfield(app.LeftPanel, 'numeric');
            app.ChargecaptureEditField.ValueDisplayFormat = '%.2f';
            app.ChargecaptureEditField.Position = [221 143 100 22];

            % Create EnergygainJEditFieldLabel
            app.EnergygainJEditFieldLabel = uilabel(app.LeftPanel);
            app.EnergygainJEditFieldLabel.HorizontalAlignment = 'right';
            app.EnergygainJEditFieldLabel.Position = [120 116 86 22];
            app.EnergygainJEditFieldLabel.Text = 'Energy gain [J]';

            % Create EnergygainJEditField
            app.EnergygainJEditField = uieditfield(app.LeftPanel, 'numeric');
            app.EnergygainJEditField.ValueDisplayFormat = '%.4f';
            app.EnergygainJEditField.Position = [221 116 100 22];

            % Create EnergylossJEditFieldLabel
            app.EnergylossJEditFieldLabel = uilabel(app.LeftPanel);
            app.EnergylossJEditFieldLabel.HorizontalAlignment = 'right';
            app.EnergylossJEditFieldLabel.Position = [122 90 84 22];
            app.EnergylossJEditFieldLabel.Text = 'Energy loss [J]';

            % Create EnergylossJEditField
            app.EnergylossJEditField = uieditfield(app.LeftPanel, 'numeric');
            app.EnergylossJEditField.ValueDisplayFormat = '%.4f';
            app.EnergylossJEditField.Position = [221 90 100 22];

            % Create DrivechargepCEditFieldLabel
            app.DrivechargepCEditFieldLabel = uilabel(app.LeftPanel);
            app.DrivechargepCEditFieldLabel.HorizontalAlignment = 'right';
            app.DrivechargepCEditFieldLabel.Position = [106 353 99 22];
            app.DrivechargepCEditFieldLabel.Text = 'Drive charge [pC]';

            % Create DrivechargepCEditField
            app.DrivechargepCEditField = uieditfield(app.LeftPanel, 'numeric');
            app.DrivechargepCEditField.ValueDisplayFormat = '%.4f';
            app.DrivechargepCEditField.Position = [220 353 100 22];

            % Create TrailingbunchcutSYAGpxEditFieldLabel
            app.TrailingbunchcutSYAGpxEditFieldLabel = uilabel(app.LeftPanel);
            app.TrailingbunchcutSYAGpxEditFieldLabel.HorizontalAlignment = 'right';
            app.TrailingbunchcutSYAGpxEditFieldLabel.Position = [47 382 158 22];
            app.TrailingbunchcutSYAGpxEditFieldLabel.Text = 'Trailing bunch cut [SYAG px]';

            % Create TrailingbunchcutSYAGpxEditField
            app.TrailingbunchcutSYAGpxEditField = uieditfield(app.LeftPanel, 'numeric');
            app.TrailingbunchcutSYAGpxEditField.Position = [220 382 100 22];
            app.TrailingbunchcutSYAGpxEditField.Value = 400;

            % Create PrinttologButton
            app.PrinttologButton = uibutton(app.LeftPanel, 'push');
            app.PrinttologButton.ButtonPushedFcn = createCallbackFcn(app, @PrinttologButtonPushed, true);
            app.PrinttologButton.Position = [202 659 100 22];
            app.PrinttologButton.Text = 'Print to log';

            % Create NumberofcolumnsEditFieldLabel
            app.NumberofcolumnsEditFieldLabel = uilabel(app.LeftPanel);
            app.NumberofcolumnsEditFieldLabel.HorizontalAlignment = 'right';
            app.NumberofcolumnsEditFieldLabel.Position = [152 819 112 22];
            app.NumberofcolumnsEditFieldLabel.Text = 'Number of columns';

            % Create NumberofcolumnsEditField
            app.NumberofcolumnsEditField = uieditfield(app.LeftPanel, 'numeric');
            app.NumberofcolumnsEditField.Limits = [1 2000];
            app.NumberofcolumnsEditField.ValueDisplayFormat = '%d';
            app.NumberofcolumnsEditField.Position = [277 819 42 22];
            app.NumberofcolumnsEditField.Value = 1000;

            % Create TwobunchmodeDropDownLabel
            app.TwobunchmodeDropDownLabel = uilabel(app.LeftPanel);
            app.TwobunchmodeDropDownLabel.HorizontalAlignment = 'right';
            app.TwobunchmodeDropDownLabel.Position = [50 412 96 22];
            app.TwobunchmodeDropDownLabel.Text = 'Two bunch mode';

            % Create TwobunchmodeDropDown
            app.TwobunchmodeDropDown = uidropdown(app.LeftPanel);
            app.TwobunchmodeDropDown.Items = {'Photocathode [manual]', 'Notched [automatic]', 'Specify fixed bunch charges'};
            app.TwobunchmodeDropDown.ValueChangedFcn = createCallbackFcn(app, @TwobunchmodeDropDownValueChanged, true);
            app.TwobunchmodeDropDown.Position = [161 412 159 22];
            app.TwobunchmodeDropDown.Value = 'Photocathode [manual]';

            % Create S14BLENauEditFieldLabel
            app.S14BLENauEditFieldLabel = uilabel(app.LeftPanel);
            app.S14BLENauEditFieldLabel.HorizontalAlignment = 'right';
            app.S14BLENauEditFieldLabel.Position = [116 254 91 22];
            app.S14BLENauEditFieldLabel.Text = 'S14 BLEN [a.u.]';

            % Create S14BLENauEditField
            app.S14BLENauEditField = uieditfield(app.LeftPanel, 'numeric');
            app.S14BLENauEditField.ValueDisplayFormat = '%g';
            app.S14BLENauEditField.Position = [221 254 100 22];

            % Create ApplybackgroundsButton
            app.ApplybackgroundsButton = uibutton(app.LeftPanel, 'state');
            app.ApplybackgroundsButton.ValueChangedFcn = createCallbackFcn(app, @ApplybackgroundsButtonValueChanged, true);
            app.ApplybackgroundsButton.Text = 'Apply backgrounds';
            app.ApplybackgroundsButton.Position = [193 696 117 22];

            % Create nCcountEditFieldLabel
            app.nCcountEditFieldLabel = uilabel(app.LeftPanel);
            app.nCcountEditFieldLabel.HorizontalAlignment = 'right';
            app.nCcountEditFieldLabel.Position = [29 512 87 22];
            app.nCcountEditFieldLabel.Text = 'nC / count';

            % Create nCcountEditField
            app.nCcountEditField = uieditfield(app.LeftPanel, 'text');
            app.nCcountEditField.ValueChangedFcn = createCallbackFcn(app, @nCcountEditFieldValueChanged2, true);
            app.nCcountEditField.HorizontalAlignment = 'right';
            app.nCcountEditField.Position = [127 512 187 22];
            app.nCcountEditField.Value = '7.5e-9';

            % Create BackgroundsubtractionLabel
            app.BackgroundsubtractionLabel = uilabel(app.LeftPanel);
            app.BackgroundsubtractionLabel.HorizontalAlignment = 'center';
            app.BackgroundsubtractionLabel.FontSize = 14;
            app.BackgroundsubtractionLabel.FontWeight = 'bold';
            app.BackgroundsubtractionLabel.Position = [169 751 167 22];
            app.BackgroundsubtractionLabel.Text = 'Background subtraction';

            % Create TotalenergytransferefficiencyEditFieldLabel
            app.TotalenergytransferefficiencyEditFieldLabel = uilabel(app.LeftPanel);
            app.TotalenergytransferefficiencyEditFieldLabel.HorizontalAlignment = 'right';
            app.TotalenergytransferefficiencyEditFieldLabel.Position = [16 63 190 22];
            app.TotalenergytransferefficiencyEditFieldLabel.Text = 'Total energy transfer efficiency [%]';

            % Create TotalenergytransferefficiencyEditField
            app.TotalenergytransferefficiencyEditField = uieditfield(app.LeftPanel, 'numeric');
            app.TotalenergytransferefficiencyEditField.Position = [221 63 100 22];

            % Create InitialdrivechargepCEditFieldLabel
            app.InitialdrivechargepCEditFieldLabel = uilabel(app.LeftPanel);
            app.InitialdrivechargepCEditFieldLabel.HorizontalAlignment = 'right';
            app.InitialdrivechargepCEditFieldLabel.Position = [78 177 128 22];
            app.InitialdrivechargepCEditFieldLabel.Text = 'Initial drive charge [pC]';

            % Create InitialdrivechargepCEditField
            app.InitialdrivechargepCEditField = uieditfield(app.LeftPanel, 'numeric');
            app.InitialdrivechargepCEditField.Position = [221 177 100 22];

            % Create SYAGchargecalibrationtypeDropDownLabel
            app.SYAGchargecalibrationtypeDropDownLabel = uilabel(app.LeftPanel);
            app.SYAGchargecalibrationtypeDropDownLabel.HorizontalAlignment = 'right';
            app.SYAGchargecalibrationtypeDropDownLabel.Position = [22 482 162 22];
            app.SYAGchargecalibrationtypeDropDownLabel.Text = 'SYAG charge calibration type';

            % Create SYAGchargecalibrationtypeDropDown
            app.SYAGchargecalibrationtypeDropDown = uidropdown(app.LeftPanel);
            app.SYAGchargecalibrationtypeDropDown.Items = {'Simple', 'Detailed', 'TORO 3255'};
            app.SYAGchargecalibrationtypeDropDown.ValueChangedFcn = createCallbackFcn(app, @SYAGchargecalibrationtypeDropDownValueChanged, true);
            app.SYAGchargecalibrationtypeDropDown.Position = [199 482 116 22];
            app.SYAGchargecalibrationtypeDropDown.Value = 'Simple';

            % Create BitdepthLabel
            app.BitdepthLabel = uilabel(app.LeftPanel);
            app.BitdepthLabel.HorizontalAlignment = 'center';
            app.BitdepthLabel.FontSize = 14;
            app.BitdepthLabel.FontWeight = 'bold';
            app.BitdepthLabel.Position = [13 13 66 22];
            app.BitdepthLabel.Text = 'Bit depth';

            % Create WaterfallSpinner
            app.WaterfallSpinner = uispinner(app.LeftPanel);
            app.WaterfallSpinner.ValueChangedFcn = createCallbackFcn(app, @WaterfallSpinnerValueChanged, true);
            app.WaterfallSpinner.Position = [95 13 51 22];
            app.WaterfallSpinner.Value = 8;

            % Create WaterfallSpinnerLabel
            app.WaterfallSpinnerLabel = uilabel(app.LeftPanel);
            app.WaterfallSpinnerLabel.HorizontalAlignment = 'right';
            app.WaterfallSpinnerLabel.Position = [92 33 52 22];
            app.WaterfallSpinnerLabel.Text = 'Waterfall';

            % Create Spectrometer1SpinnerLabel
            app.Spectrometer1SpinnerLabel = uilabel(app.LeftPanel);
            app.Spectrometer1SpinnerLabel.HorizontalAlignment = 'center';
            app.Spectrometer1SpinnerLabel.Position = [158 33 88 22];
            app.Spectrometer1SpinnerLabel.Text = 'Spectrometer 1';

            % Create Spectrometer1Spinner
            app.Spectrometer1Spinner = uispinner(app.LeftPanel);
            app.Spectrometer1Spinner.ValueChangedFcn = createCallbackFcn(app, @Spectrometer1SpinnerValueChanged, true);
            app.Spectrometer1Spinner.Position = [179 12 51 22];
            app.Spectrometer1Spinner.Value = 8;

            % Create nCcountEditField_2Label
            app.nCcountEditField_2Label = uilabel(app.LeftPanel);
            app.nCcountEditField_2Label.HorizontalAlignment = 'right';
            app.nCcountEditField_2Label.Position = [50 449 60 22];
            app.nCcountEditField_2Label.Text = 'nC / count';

            % Create nCcountEditField_2
            app.nCcountEditField_2 = uieditfield(app.LeftPanel, 'text');
            app.nCcountEditField_2.ValueChangedFcn = createCallbackFcn(app, @nCcountEditField_2ValueChanged, true);
            app.nCcountEditField_2.HorizontalAlignment = 'right';
            app.nCcountEditField_2.Position = [125 449 188 22];
            app.nCcountEditField_2.Value = '5.24e-6';

            % Create Spectrometerdisplay2DropDownLabel
            app.Spectrometerdisplay2DropDownLabel = uilabel(app.LeftPanel);
            app.Spectrometerdisplay2DropDownLabel.HorizontalAlignment = 'right';
            app.Spectrometerdisplay2DropDownLabel.Position = [-9 285 133 22];
            app.Spectrometerdisplay2DropDownLabel.Text = 'Spectrometer display 2';

            % Create Spectrometerdisplay2DropDown
            app.Spectrometerdisplay2DropDown = uidropdown(app.LeftPanel);
            app.Spectrometerdisplay2DropDown.Items = {'Accelerated Charge [pC]', 'Initial Trailing Charge [pC]', 'Charge Capture [%]', 'Energy Gain [J]', 'Energy Loss [J]', 'Total transfer efficiency [%]', 'Charge acceleration performance', 'Energy transfer performance', 'S14 BLEN'};
            app.Spectrometerdisplay2DropDown.ValueChangedFcn = createCallbackFcn(app, @Spectrometerdisplay2DropDownValueChanged, true);
            app.Spectrometerdisplay2DropDown.Position = [134 285 202 22];
            app.Spectrometerdisplay2DropDown.Value = 'Energy Loss [J]';

            % Create Spectrometer2SpinnerLabel
            app.Spectrometer2SpinnerLabel = uilabel(app.LeftPanel);
            app.Spectrometer2SpinnerLabel.HorizontalAlignment = 'right';
            app.Spectrometer2SpinnerLabel.Position = [248 34 88 22];
            app.Spectrometer2SpinnerLabel.Text = 'Spectrometer 2';

            % Create Spectrometer2Spinner
            app.Spectrometer2Spinner = uispinner(app.LeftPanel);
            app.Spectrometer2Spinner.Position = [267 14 48 22];
            app.Spectrometer2Spinner.Value = 3;

            % Create ResetButton
            app.ResetButton = uibutton(app.LeftPanel, 'push');
            app.ResetButton.ButtonPushedFcn = createCallbackFcn(app, @ResetButtonPushed, true);
            app.ResetButton.Position = [253 859 68 22];
            app.ResetButton.Text = 'Reset';

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.RightPanel);
            title(app.UIAxes, 'CHER live view')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [28 449 1019 471];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.RightPanel);
            title(app.UIAxes2, 'Spectrometer display 1')
            xlabel(app.UIAxes2, 'X')
            ylabel(app.UIAxes2, 'Y')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.Position = [25 220 1021 214];

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.RightPanel);
            title(app.UIAxes3, 'Spectrometer display 2')
            xlabel(app.UIAxes3, 'X')
            ylabel(app.UIAxes3, 'Y')
            app.UIAxes3.Position = [28 15 1017 185];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_PWFA_Live_Spectrometer_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end