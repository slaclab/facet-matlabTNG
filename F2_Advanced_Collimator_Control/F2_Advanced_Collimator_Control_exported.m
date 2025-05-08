classdef F2_Advanced_Collimator_Control_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        LeftPanel                       matlab.ui.container.Panel
        TabGroup                        matlab.ui.container.TabGroup
        MaincontrolsTab                 matlab.ui.container.Tab
        DrivebunchcenterpxSpinnerLabel  matlab.ui.control.Label
        CurrentcompressionButtonGroup   matlab.ui.container.ButtonGroup
        OvercompressedButton            matlab.ui.control.ToggleButton
        UndercompressedButton           matlab.ui.control.ToggleButton
        DBC_UC                          matlab.ui.control.Spinner
        DBC_OC                          matlab.ui.control.Spinner
        DrivebunchwidthpxSpinnerLabel   matlab.ui.control.Label
        DBW_UC                          matlab.ui.control.Spinner
        DBW_OC                          matlab.ui.control.Spinner
        WBC_OC                          matlab.ui.control.Spinner
        WitnessbunchcenterpxSpinnerLabel  matlab.ui.control.Label
        WBC_UC                          matlab.ui.control.Spinner
        WBW_OC                          matlab.ui.control.Spinner
        WitnessbunchwidthpxSpinnerLabel  matlab.ui.control.Label
        WBW_UC                          matlab.ui.control.Spinner
        ApplyconfigurationButton        matlab.ui.control.Button
        BlockdriveCheckBox              matlab.ui.control.CheckBox
        BlockwitnessCheckBox            matlab.ui.control.CheckBox
        CalculateconfigurationButton    matlab.ui.control.Button
        SavecurrentstateButton          matlab.ui.control.Button
        LoadsavedstateButton            matlab.ui.control.Button
        NotchpositionmEditFieldLabel    matlab.ui.control.Label
        NotchpositionmEditField         matlab.ui.control.NumericEditField
        NotchangledegEditFieldLabel     matlab.ui.control.Label
        NotchangledegEditField          matlab.ui.control.NumericEditField
        LeftjawpositionmmEditFieldLabel  matlab.ui.control.Label
        LeftjawpositionmmEditField      matlab.ui.control.NumericEditField
        RightjawpositionmmLabel         matlab.ui.control.Label
        RightjawpositionmmEditField     matlab.ui.control.NumericEditField
        CalibrationtoolTab              matlab.ui.container.Tab
        CurrentcalibrationsettingsLabel  matlab.ui.control.Label
        CalibratemotorDropDownLabel     matlab.ui.control.Label
        CalibratemotorDropDown          matlab.ui.control.DropDown
        OngoingcalibrationTextArea      matlab.ui.control.TextArea
        Pixelposition1EditFieldLabel    matlab.ui.control.Label
        Pixelposition1EditField         matlab.ui.control.NumericEditField
        Pixelposition2EditFieldLabel    matlab.ui.control.Label
        Pixelposition2EditField         matlab.ui.control.NumericEditField
        SlopeEditFieldLabel             matlab.ui.control.Label
        SlopeEditField                  matlab.ui.control.NumericEditField
        InterceptEditFieldLabel         matlab.ui.control.Label
        InterceptEditField              matlab.ui.control.NumericEditField
        SemiautomaticCalibrationLabel   matlab.ui.control.Label
        RestoredefaultsettingsButton    matlab.ui.control.Button
        StartcalibrationButton          matlab.ui.control.Button
        ClearongoingcalibrationButton   matlab.ui.control.Button
        ApplycalibrationButton          matlab.ui.control.Button
        NextButton                      matlab.ui.control.Button
        SlopeLabel                      matlab.ui.control.Label
        InterceptLabel                  matlab.ui.control.Label
        EditField                       matlab.ui.control.NumericEditField
        EditField2                      matlab.ui.control.NumericEditField
        EditField3                      matlab.ui.control.NumericEditField
        EditField4                      matlab.ui.control.NumericEditField
        NotchpositionumEditFieldLabel   matlab.ui.control.Label
        NotchpositionumEditField        matlab.ui.control.NumericEditField
        NotchangledegEditField_2Label   matlab.ui.control.Label
        NotchangledegEditField_2        matlab.ui.control.NumericEditField
        LeftjawpositionmmEditField_2Label  matlab.ui.control.Label
        LeftjawpositionmmEditField_2    matlab.ui.control.NumericEditField
        RightjawpositionmmEditField_2Label  matlab.ui.control.Label
        RightjawpositionmmEditField_2   matlab.ui.control.NumericEditField
        EditField_2                     matlab.ui.control.NumericEditField
        SlopeLabel_2                    matlab.ui.control.Label
        InterceptLabel_2                matlab.ui.control.Label
        OffsetLabel                     matlab.ui.control.Label
        EditField_3                     matlab.ui.control.NumericEditField
        WarningwilloverwritecalibrationPVswithhardcodeddefaultsLabel  matlab.ui.control.Label
        ShowcalibrationdetailsButton    matlab.ui.control.Button
        bLabel                          matlab.ui.control.Label
        bLabel_2                        matlab.ui.control.Label
        aLabel                          matlab.ui.control.Label
        aLabel_2                        matlab.ui.control.Label
        t0Label                         matlab.ui.control.Label
        cLabel                          matlab.ui.control.Label
        b_lLabel                        matlab.ui.control.Label
        b_rLabel                        matlab.ui.control.Label
        a_lLabel                        matlab.ui.control.Label
        a_rLabel                        matlab.ui.control.Label
        CalibrationtoolbutmanualTab     matlab.ui.container.Tab
        SelectmotorDropDownLabel        matlab.ui.control.Label
        SelectmotorDropDown             matlab.ui.control.DropDown
        FancylinearequationsolverLabel  matlab.ui.control.Label
        Pixelposition1EditField_2Label  matlab.ui.control.Label
        Pixelposition1EditField_2       matlab.ui.control.NumericEditField
        Pixelposition2EditField_2Label  matlab.ui.control.Label
        Pixelposition2EditField_2       matlab.ui.control.NumericEditField
        Motorposition1EditFieldLabel    matlab.ui.control.Label
        Motorposition1EditField         matlab.ui.control.NumericEditField
        Motorposition2EditFieldLabel    matlab.ui.control.Label
        Motorposition2EditField         matlab.ui.control.NumericEditField
        SlopeEditField_2Label           matlab.ui.control.Label
        SlopeEditField_2                matlab.ui.control.NumericEditField
        InterceptEditField_2Label       matlab.ui.control.Label
        InterceptEditField_2            matlab.ui.control.NumericEditField
        CalculateButton                 matlab.ui.control.Button
        ClearButton                     matlab.ui.control.Button
        ApplycalibrationButton_2        matlab.ui.control.Button
        CurrentmotorpositionButton      matlab.ui.control.Button
        CurrentmotorpositionButton_2    matlab.ui.control.Button
        Label_3                         matlab.ui.control.Label
        onSYAGbeforecalibratingnotchpositionLabel  matlab.ui.control.Label
        NotchandjawcontrolsLabel        matlab.ui.control.Label
        RightPanel                      matlab.ui.container.Panel
        UIAxes                          matlab.ui.control.UIAxes
        StartacquiringButton            matlab.ui.control.Button
        StopacquiringButton             matlab.ui.control.Button
        DrivewitnesschargeratioEditFieldLabel  matlab.ui.control.Label
        DrivewitnesschargeratioEditField  matlab.ui.control.NumericEditField
        CurrentnotchpositionpxEditFieldLabel  matlab.ui.control.Label
        CurrentnotchpositionpxEditField  matlab.ui.control.NumericEditField
        SubtractbackgroundCheckBox      matlab.ui.control.CheckBox
        CalculatechargeratioCheckBox    matlab.ui.control.CheckBox
        TakebackgroundButton            matlab.ui.control.Button
        LowenergysideLabel              matlab.ui.control.Label
        HighenergysideLabel             matlab.ui.control.Label
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    
    properties (Access = private)
        SavedDriveCenter;
        SavedDriveWidth;
        SavedWitnessCenter;
        SavedWitnessWidth;
        SavedCompression;
        UpdateSYAG; % timer to run the axis update loop

        DefaultNotchAngleSlope = 67.9803;
        DefaultNotchAngleIntercept = 78.8235;
        DefaultNotchPositionSlope = -5.25;
        DefaultNotchPositionIntercept = 14798;
        DefaultRightJawSlope = -0.004; % 
        DefaultRightJawIntercept = 2.086;
        DefaultLeftJawSlope = -0.0054;
        DefaultLeftJawIntercept = 2.553;
        DefaultNotchAngleOffset = 5.2985;
        DefaultNotchPositionAngleSlope = 15.4007;

        SYAG_background;
        
        DBC_current;
        DBW_current;
        WBC_current;
        WBW_current;

        calibration_notch_angle_intercept_PV = 'SIOC:SYS1:ML00:AO991';
        calibration_notch_angle_slope_PV = 'SIOC:SYS1:ML00:AO992';
        calibration_notch_angle_offset_PV = 'SIOC:SYS1:ML00:AO997';
        calibration_notch_position_angle_slope_PV = 'SIOC:SYS1:ML00:AO538';
        
        calibration_notch_position_intercept_PV = 'SIOC:SYS1:ML00:AO993';
        calibration_notch_position_slope_PV = 'SIOC:SYS1:ML00:AO994';
        calibration_left_jaw_intercept_PV = 'SIOC:SYS1:ML00:AO958';
        calibration_left_jaw_slope_PV = 'SIOC:SYS1:ML00:AO964';
        calibration_right_jaw_intercept_PV = 'SIOC:SYS1:ML00:AO965';
        calibration_right_jaw_slope_PV = 'SIOC:SYS1:ML00:AO967';

        drive_center_OC_PV = 'SIOC:SYS1:ML00:CALCOUT671';
        drive_width_OC_PV = 'SIOC:SYS1:ML00:CALCOUT672';
        witness_center_OC_PV = 'SIOC:SYS1:ML00:CALCOUT673';
        witness_width_OC_PV = 'SIOC:SYS1:ML00:CALCOUT674';
        
        drive_center_UC_PV = 'SIOC:SYS1:ML00:CALCOUT675';
        drive_width_UC_PV = 'SIOC:SYS1:ML00:CALCOUT676';
        witness_center_UC_PV = 'SIOC:SYS1:ML00:CALCOUT677';
        witness_width_UC_PV = 'SIOC:SYS1:ML00:CALCOUT678';

        array_data_PV = 'CAMR:LI20:100:Image:ArrayData';
        size_0_PV = 'CAMR:LI20:100:Image:ArraySize0_RBV';
        size_1_PV = 'CAMR:LI20:100:Image:ArraySize1_RBV';

        ROI_x = 1:1192;
        ROI_y = 700:950;
        ROI_y_2 = 800:810;


        moving = 0;
        tolerance = 0.1;
        valid_config_available = 0;
        
        % calibration switches
        calibration_ongoing = 0;
        calibration_completed = 0;

        calibration_p1_ready = 0;
        calibration_p2_ready = 0;

        calibration_p1_done = 0;
        calibration_p2_done = 0;

        calibration_motorpos_1;
        calibration_motorpos_2;

        calibration_messagesent_1 = 0;
        calibration_messagesent_2 = 0;
        
        calibration_second = 0;
    end
    
    methods (Access = private)
        
        function updateImage(app, img2)
            
            if app.SubtractbackgroundCheckBox.Value
                img = flip(img2 - app.SYAG_background,1);
            else
                img = flip(img2,1);
            end

            %'prepare to update image'
            
            objs = app.UIAxes.Children;
            
            for i=1:length(objs)
                obj = objs(i);
                if ~isa(obj, 'matlab.graphics.primitive.Patch')
                    obj.CData = img(app.ROI_x, app.ROI_y)';
                else
                    switch obj.Tag
                        case 'Drive'
                            if app.DBW_current.Value > 0
                                obj.XData = [app.DBC_current.Value - app.DBW_current.Value/2 app.DBC_current.Value - app.DBW_current.Value/2 app.DBC_current.Value + app.DBW_current.Value/2 app.DBC_current.Value + app.DBW_current.Value/2];
                                obj.YData = [650 1000 1000 650];
                            end
                        case 'Witness'
                            if app.WBW_current.Value > 0
                                obj.XData = [app.WBC_current.Value - app.WBW_current.Value/2 app.WBC_current.Value - app.WBW_current.Value/2 app.WBC_current.Value + app.WBW_current.Value/2 app.WBC_current.Value + app.WBW_current.Value/2];
                                obj.YData = [650 1000 1000 650];
                            end
                    end
                end
            end
            
            
            %'updated image'
            
            %if app.DBW_current.Value > 0
            %    fill(app.UIAxes, [app.DBC_current.Value - app.DBW_current.Value/2 app.DBC_current.Value - app.DBW_current.Value/2 app.DBC_current.Value + app.DBW_current.Value/2 app.DBC_current.Value + app.DBW_current.Value/2], [650 1000 1000 650], 'r', 'FaceAlpha',0.1)
            %end
            
            %'updated drive boxes'
            
            %if app.WBW_current.Value > 0
            %    fill(app.UIAxes, [app.WBC_current.Value - app.WBW_current.Value/2 app.WBC_current.Value - app.WBW_current.Value/2 app.WBC_current.Value + app.WBW_current.Value/2 app.WBC_current.Value + app.WBW_current.Value/2], [650 1000 1000 650], 'g', 'FaceAlpha',0.1)
            %end
            
            %'updated witness box'

            

            if app.CalculatechargeratioCheckBox.Value
                notch_pos_current = lcaGet('COLL:LI20:2069:MOTR.RBV');
                notch_angle_current = lcaGet('COLL:LI20:2073:MOTR.RBV');
                notch_center_px = (notch_pos_current - lcaGet(app.calibration_notch_position_intercept_PV - lcaGet(app.calibration_notch_position_angle_slope_PV) * (notch_angle_current - lcaGet(app.calibration_notch_angle_offset_PV))))/lcaGet(app.calibration_notch_position_slope_PV);
                notch_center_px = int32(notch_center_px);
                app.CurrentnotchpositionpxEditField.Value = double(notch_center_px);

                if app.CurrentcompressionButtonGroup.SelectedObject == app.OvercompressedButton && notch_center_px<1292 && notch_center_px >0
                    drive_counts = sum(img(app.ROI_x(1):notch_center_px, app.ROI_y_2), "all");
                    witness_counts = sum(img(notch_center_px:app.ROI_x(end), app.ROI_y_2), "all");
                    app.DrivewitnesschargeratioEditField.Value = (drive_counts/witness_counts); 
                elseif app.CurrentcompressionButtonGroup.SelectedObject == app.UndercompressedButton && notch_center_px<1292 && notch_center_px >0
                    witness_counts = sum(img(app.ROI_x(1):notch_center_px, app.ROI_y_2), "all");
                    drive_counts = sum(img(notch_center_px:app.ROI_x(end), app.ROI_y_2), "all");
                    app.DrivewitnesschargeratioEditField.Value = (drive_counts/witness_counts); 
                end 
                
                
            end
            
        end



        function UpdateSYAGTimerFcn(app, src, event)
            % pull image array data and send the image to app.UpdateImage            
            cam_array = lcaGet(app.array_data_PV);
            size_0 = lcaGet(app.size_0_PV);
            size_1 = lcaGet(app.size_1_PV);
            
            cam_image = reshape(cam_array(1:size_0*size_1), size_0, []);
            
            app.updateImage(cam_image);

            app.DBC_OC.Value = lcaGet(app.drive_center_OC_PV);
            app.DBW_OC.Value = lcaGet(app.drive_width_OC_PV);
            app.WBC_OC.Value = lcaGet(app.witness_center_OC_PV);
            app.WBW_OC.Value = lcaGet(app.witness_width_OC_PV);

            app.DBC_UC.Value = lcaGet(app.drive_center_UC_PV);
            app.DBW_UC.Value = lcaGet(app.drive_width_UC_PV);
            app.WBC_UC.Value = lcaGet(app.witness_center_UC_PV);
            app.WBW_UC.Value = lcaGet(app.witness_width_UC_PV);
            
            selectedButton = app.CurrentcompressionButtonGroup.SelectedObject;
            if selectedButton == app.OvercompressedButton
                app.DBC_current = app.DBC_OC;
                app.DBW_current = app.DBW_OC;
                app.WBC_current = app.WBC_OC;
                app.WBW_current = app.WBW_OC;
            else
                app.DBC_current = app.DBC_UC;
                app.DBW_current = app.DBW_UC;
                app.WBC_current = app.WBC_UC;
                app.WBW_current = app.WBW_UC;                
            end

            calibration_notch_position_slope = lcaGet(app.calibration_notch_position_slope_PV);
            calibration_notch_position_intercept = lcaGet(app.calibration_notch_position_intercept_PV);
            calibration_notch_position_angle_slope = lcaGet(app.calibration_notch_position_angle_slope_PV);
            
            calibration_notch_angle_slope = lcaGet(app.calibration_notch_angle_slope_PV);
            calibration_notch_angle_intercept = lcaGet(app.calibration_notch_angle_intercept_PV);
            calibration_notch_angle_offset = lcaGet(app.calibration_notch_angle_offset_PV);
            
            calibration_left_jaw_slope = lcaGet(app.calibration_left_jaw_slope_PV);
            calibration_left_jaw_intercept = lcaGet(app.calibration_left_jaw_intercept_PV);
            calibration_right_jaw_slope = lcaGet(app.calibration_right_jaw_slope_PV);
            calibration_right_jaw_intercept = lcaGet(app.calibration_right_jaw_intercept_PV);
            
            app.NotchpositionumEditField.Value = calibration_notch_position_slope;
            app.EditField.Value = calibration_notch_position_intercept;
            app.NotchangledegEditField_2.Value = calibration_notch_angle_slope;
            app.EditField2.Value = calibration_notch_angle_intercept;
            app.LeftjawpositionmmEditField_2.Value = calibration_left_jaw_slope;
            app.EditField3.Value = calibration_left_jaw_intercept;
            app.RightjawpositionmmEditField_2.Value = calibration_right_jaw_slope;
            app.EditField4.Value = calibration_right_jaw_intercept;
            app.EditField_2.Value = calibration_notch_angle_offset;
            app.EditField_3.Value = calibration_notch_position_angle_slope; 


            if app.moving
                if abs(lcaGet('COLL:LI20:2069:MOTR')-app.NotchpositionmEditField.Value)>app.tolerance && abs(lcaGet('COLL:LI20:2086:MOTR')-left_jaw)>app.tolerance && abs(lcaGet('COLL:LI20:2085:MOTR')-right_jaw)>app.tolerance
                  app.ApplyconfigurationButton.BackgroundColor = 'r';
                else
                  app.ApplyconfigurationButton.BackgroundColor = 'g';
                  app.moving = 0;
                end
            end
            
            if app.calibration_ongoing
                if ~app.calibration_p1_done && ~app.calibration_p1_ready
                    if ~app.calibration_messagesent_1
                        app.update_calibration_textbox('Move motor to first viable position, then press "Next"')
                        app.NextButton.Enable = 'on';
                        app.calibration_messagesent_1 = 1;
                    end

                elseif ~app.calibration_p2_done && ~app.calibration_p2_ready && app.calibration_second
                    if ~app.calibration_messagesent_2
                        app.update_calibration_textbox('Move motor to second viable position, then press "Next"')
                        app.NextButton.Enable = 'on';
                        app.calibration_messagesent_2 = 1;
                    end

                elseif app.calibration_p1_done && app.calibration_p2_done
                    % (px1, m1), (px2, m2)
                    % m = a + b * px
                    % m - m1 = (m2-m1)/(px2-px1) * (px-px1)
                    % m = m1 - (m2-m1)/(px2-px1)*px1+(m2-m1)/(px2-px1)*px
                    
                    % a = m1 - (m2-m1)/(px2-px1)  *px1
                    % b = (m2-m1)/(px2-px1)

                    app.SlopeEditField.Value = (app.calibration_motorpos_2 - app.calibration_motorpos_1)/(app.Pixelposition2EditField.Value - app.Pixelposition1EditField.Value) ; %b
                    app.InterceptEditField.Value = app.calibration_motorpos_1 - (app.calibration_motorpos_2 - app.calibration_motorpos_1)/(app.Pixelposition2EditField.Value - app.Pixelposition1EditField.Value) * app.Pixelposition1EditField.Value; %a

                    app.update_calibration_textbox('Calculated calibration slope and intercept')
                    app.ApplycalibrationButton.Enable = 'on';

                    app.calibration_ongoing = 0;
                    app.calibration_completed = 1;

                    app.calibration_p1_ready = 0;
                    app.calibration_p2_ready = 0;

                    app.calibration_p1_done = 0;
                    app.calibration_p2_done = 0;

                    app.calibration_messagesent_1 = 0;
                    app.calibration_messagesent_2 = 0;

                    app.calibration_second = 0;
                end
            end
        end

        function update_calibration_textbox(app, new_text)
            current_text = app.OngoingcalibrationTextArea.Value;
            current_text{end+1} = new_text;

            app.OngoingcalibrationTextArea.Value = current_text; 
        end

    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.DBC_current = app.DBC_OC;
            app.DBW_current = app.DBW_OC;
            app.WBC_current = app.WBC_OC;
            app.WBW_current = app.WBW_OC;

            app.UpdateSYAG = timer("ExecutionMode","fixedRate","Period",0.15, ...
    "BusyMode","drop","TimerFcn",@app.UpdateSYAGTimerFcn) ;
        end

        % Button pushed function: StartacquiringButton
        function StartacquiringButtonPushed(app, event)
            cam_array = lcaGet(app.array_data_PV);
            size_0 = lcaGet(app.size_0_PV);
            size_1 = lcaGet(app.size_1_PV);
            
            img = reshape(cam_array(1:size_0*size_1), size_0, []);
            img = flip(img, 1);
            
            cla(app.UIAxes)
            hold(app.UIAxes, 'on')
            imagesc(app.UIAxes, app.ROI_x, app.ROI_y, img(app.ROI_x, app.ROI_y)');
            colorbar(app.UIAxes);
            f1 = fill(app.UIAxes, [app.DBC_current.Value - app.DBW_current.Value/2 app.DBC_current.Value - app.DBW_current.Value/2 app.DBC_current.Value + app.DBW_current.Value/2 app.DBC_current.Value + app.DBW_current.Value/2], [650 1000 1000 650], 'r', 'FaceAlpha',0.1);
            f1.Tag = 'Drive';
            
            f2 = fill(app.UIAxes, [app.WBC_current.Value - app.WBW_current.Value/2 app.WBC_current.Value - app.WBW_current.Value/2 app.WBC_current.Value + app.WBW_current.Value/2 app.WBC_current.Value + app.WBW_current.Value/2], [650 1000 1000 650], 'g', 'FaceAlpha',0.1);
            f2.Tag = 'Witness';
            
            app.UIAxes.XLim = [app.ROI_x(1) app.ROI_x(end)];
            app.UIAxes.YLim = [app.ROI_y(1) app.ROI_y(end)];
            app.UIAxes.CLim = [0 100];
            hold(app.UIAxes, 'off')
            
            
            if strcmp(app.UpdateSYAG.Running, 'off')
                start(app.UpdateSYAG);
            end
        end

        % Button pushed function: StopacquiringButton
        function StopacquiringButtonPushed(app, event)
            if strcmp(app.UpdateSYAG.Running, 'on')
                stop(app.UpdateSYAG);
            end
        end

        % Selection changed function: CurrentcompressionButtonGroup
        function CurrentcompressionButtonGroupSelectionChanged(app, event)
            selectedButton = app.CurrentcompressionButtonGroup.SelectedObject;
            if selectedButton == app.OvercompressedButton
                app.DBC_UC.Editable = "off";
                app.DBC_UC.Enable = "off";
                app.DBW_UC.Editable = "off";
                app.DBW_UC.Enable = "off";
                app.WBC_UC.Editable = "off";
                app.WBC_UC.Enable = "off";
                app.WBW_UC.Editable = "off";
                app.WBW_UC.Enable = "off";

                app.DBC_OC.Editable = "on";
                app.DBC_OC.Enable = "on";
                app.DBW_OC.Editable = "on";
                app.DBW_OC.Enable = "on";
                app.WBC_OC.Editable = "on";
                app.WBC_OC.Enable = "on";
                app.WBW_OC.Editable = "on";
                app.WBW_OC.Enable = "on";

                app.DBC_current = app.DBC_OC;
                app.DBW_current = app.DBW_OC;
                app.WBC_current = app.WBC_OC;
                app.WBW_current = app.WBW_OC;
            elseif selectedButton == app.UndercompressedButton
                app.DBC_OC.Editable = "off";
                app.DBC_OC.Enable = "off";
                app.DBW_OC.Editable = "off";
                app.DBW_OC.Enable = "off";
                app.WBC_OC.Editable = "off";
                app.WBC_OC.Enable = "off";
                app.WBW_OC.Editable = "off";
                app.WBW_OC.Enable = "off";

                app.DBC_UC.Editable = "on";
                app.DBC_UC.Enable = "on";
                app.DBW_UC.Editable = "on";
                app.DBW_UC.Enable = "on";
                app.WBC_UC.Editable = "on";
                app.WBC_UC.Enable = "on";
                app.WBW_UC.Editable = "on";
                app.WBW_UC.Enable = "on";

                app.DBC_current = app.DBC_UC;
                app.DBW_current = app.DBW_UC;
                app.WBC_current = app.WBC_UC;
                app.WBW_current = app.WBW_UC;
            end
        end

        % Value changed function: DBC_OC
        function DBC_OCValueChanged(app, event)
            value = app.DBC_OC.Value;
            lcaPut(app.drive_center_OC_PV, value);           
        end

        % Value changed function: DBW_OC
        function DBW_OCValueChanged(app, event)
            value = app.DBW_OC.Value;
            lcaPut(app.drive_width_OC_PV, value);
        end

        % Value changed function: WBC_OC
        function WBC_OCValueChanged(app, event)
            value = app.WBC_OC.Value;
            lcaPut(app.witness_center_OC_PV, value);
        end

        % Value changed function: WBW_OC
        function WBW_OCValueChanged(app, event)
            value = app.WBW_OC.Value;
            lcaPut(app.witness_width_OC_PV, value);
        end

        % Value changed function: DBC_UC
        function DBC_UCValueChanged(app, event)
            value = app.DBC_UC.Value;
            lcaPut(app.drive_center_UC_PV, value);
        end

        % Value changed function: DBW_UC
        function DBW_UCValueChanged(app, event)
            value = app.DBW_UC.Value;
            lcaPut(app.drive_width_UC_PV, value);
        end

        % Value changed function: WBC_UC
        function WBC_UCValueChanged(app, event)
            value = app.WBC_UC.Value;
            lcaPut(app.witness_center_UC_PV, value);
        end

        % Value changed function: WBW_UC
        function WBW_UCValueChanged(app, event)
            value = app.WBW_UC.Value;
            lcaPut(app.witness_width_UC_PV, value);
        end

        % Button pushed function: TakebackgroundButton
        function TakebackgroundButtonPushed(app, event)
            cam_array = lcaGet(app.array_data_PV);
            size_0 = lcaGet(app.size_0_PV);
            size_1 = lcaGet(app.size_1_PV);
            
            cam_image_bg = reshape(cam_array(1:size_0*size_1), size_0, []);
            
            app.SYAG_background = cam_image_bg;

            app.SubtractbackgroundCheckBox.Enable = 'on';
        end

        % Button pushed function: CalculateconfigurationButton
        function CalculateconfigurationButtonPushed(app, event)
% use XBX_current instead and calculate notch width before eife
            if app.CurrentcompressionButtonGroup.SelectedObject == app.OvercompressedButton
                compression = 1;
                
                drive_center = app.DBC_OC.Value;
                drive_width = app.DBW_OC.Value;
                witness_center = app.WBC_OC.Value;
                witness_width = app.WBW_OC.Value;
                
                notch_width = abs(drive_center - witness_center) - drive_width/2 - witness_width/2;
                notch_center = drive_center + drive_width/2 + notch_width/2;
            else
                compression = -1;

                drive_center = app.DBC_UC.Value;
                drive_width = app.DBW_UC.Value;
                witness_center = app.WBC_UC.Value;
                witness_width = app.WBW_UC.Value;              
                
                notch_width = abs(drive_center - witness_center) - drive_width/2 - witness_width/2;
                notch_center = drive_center - drive_width/2 - notch_width/2;
            end

            if notch_width < lcaGet(app.calibration_notch_angle_intercept_PV)
                fig = app.UIFigure;
                uialert(fig, {'Bunch separation too small for notch', 'Please increase distance between drive and witness'}, 'Warning: Invalid configuration')
            elseif (compression == 1 && (drive_center > witness_center)) || (compression == -1 && (drive_center < witness_center))
                fig = app.UIFigure;
                uialert(fig, {'Drive and witness on wrong sides for set compression', 'Please change drive and witness centers', 'or switch compression'}, 'Warning: Invalid configuration')
            else
                [notch_pos, notch_angle, left_jaw_pos, right_jaw_pos] = notch_motion_calculator(drive_center, drive_width, witness_center, witness_width, compression);

                if app.BlockdriveCheckBox.Value
                    if compression == 1
                        left_jaw_pos = lcaGet(app.calibration_left_jaw_intercept_PV) + lcaGet(app.calibration_left_jaw_slope_PV) * notch_center;
                    else
                        right_jaw_pos = lcaGet(app.calibration_right_jaw_intercept_PV) + lcaGet(app.calibration_right_jaw_slope_PV) * notch_center;
                    end
                end

                if app.BlockwitnessCheckBox.Value
                    if compression == -1
                        left_jaw_pos = lcaGet(app.calibration_left_jaw_intercept_PV) + lcaGet(app.calibration_left_jaw_slope_PV) * notch_center;
                    else
                        right_jaw_pos = lcaGet(app.calibration_right_jaw_intercept_PV) + lcaGet(app.calibration_right_jaw_slope_PV) * notch_center;
                    end
                end

                app.NotchpositionmEditField.Value = notch_pos;
                app.NotchangledegEditField.Value = notch_angle;
                app.LeftjawpositionmmEditField.Value = left_jaw_pos;
                app.RightjawpositionmmEditField.Value = right_jaw_pos;

                app.valid_config_available = 1;
            end
        end

        % Button pushed function: RestoredefaultsettingsButton
        function RestoredefaultsettingsButtonPushed(app, event)
            lcaPut(app.calibration_notch_position_slope_PV, app.DefaultNotchPositionSlope);
            lcaPut(app.calibration_notch_position_intercept_PV, app.DefaultNotchPositionIntercept);
            lcaPut(app.calibration_notch_angle_slope_PV, app.DefaultNotchAngleSlope);
            lcaPut(app.calibration_notch_angle_intercept_PV, app.DefaultNotchAngleIntercept);
            lcaPut(app.calibration_left_jaw_slope_PV, app.DefaultLeftJawSlope);
            lcaPut(app.calibration_left_jaw_intercept_PV, app.DefaultLeftJawIntercept);
            lcaPut(app.calibration_right_jaw_slope_PV, app.DefaultRightJawSlope);
            lcaPut(app.calibration_right_jaw_intercept_PV, app.DefaultRightJawIntercept);
            lcaPut(app.calibration_notch_angle_offset_PV, app.DefaultNotchAngleOffset);
            lcaPut(app.calibration_notch_position_angle_slope_PV, app.DefaultNotchPositionAngleSlope);
        end

        % Button pushed function: ApplyconfigurationButton
        function ApplyconfigurationButtonPushed(app, event)
            if app.valid_config_available == 1
                lcaPutSmart('COLL:LI20:2073:MOTR', app.NotchangledegEditField.Value);
                lcaPutSmart('COLL:LI20:2069:MOTR', app.NotchpositionmEditField.Value);
                lcaPutSmart('COLL:LI20:2086:MOTR', app.RightjawpositionmmEditField.Value);
                lcaPutSmart('COLL:LI20:2085:MOTR', app.LeftjawpositionmmEditField.Value);
                
                app.moving = 1;
                pause(0.05);
            else
                fig = app.UIFigure;
                uialert(fig, 'Invalid or missing configuration', 'Warning: Invalid configuration')
            end
        end

        % Button pushed function: SavecurrentstateButton
        function SavecurrentstateButtonPushed(app, event)
            if app.CurrentcompressionButtonGroup.SelectedObject == app.OvercompressedButton
                current_compression = 1;
            else
                current_compression = -1;
            end

            app.SavedCompression = current_compression;
            app.SavedDriveCenter = app.DBC_current.Value;
            app.SavedDriveWidth = app.DBW_current.Value;
            app.SavedWitnessCenter = app.WBC_current.Value;
            app.SavedWitnessWidth = app.WBW_current.Value;
        end

        % Button pushed function: LoadsavedstateButton
        function LoadsavedstateButtonPushed(app, event)
            if ~isempty(app.SavedCompression)
                if app.SavedCompression == 1
                    lcaPut(app.drive_center_OC_PV, app.SavedDriveCenter)
                    lcaPut(app.drive_width_OC_PV, app.SavedDriveWidth)
                    lcaPut(app.witness_center_OC_PV, app.SavedWitnessCenter)
                    lcaPut(app.witness_width_OC_PV, app.SavedWitnessWidth)
                elseif app.SavedCompression == -1
                    lcaPut(app.drive_center_UC_PV, app.SavedDriveCenter)
                    lcaPut(app.drive_width_UC_PV, app.SavedDriveWidth)
                    lcaPut(app.witness_center_UC_PV, app.SavedWitnessCenter)
                    lcaPut(app.witness_width_UC_PV, app.SavedWitnessWidth)
                end
            end


        end

        % Value changed function: CalibratemotorDropDown
        function CalibratemotorDropDownValueChanged(app, event)
            value = app.CalibratemotorDropDown.Value;
            app.ClearongoingcalibrationButtonPushed(event)
            app.update_calibration_textbox(sprintf('Ready to start calibration: %s', value))
        end

        % Button pushed function: StartcalibrationButton
        function StartcalibrationButtonPushed(app, event)
            value = app.CalibratemotorDropDown.Value;
            app.ClearongoingcalibrationButtonPushed(event)
            app.update_calibration_textbox(sprintf('Ready to start calibration: %s', value))
            
            h = findobj(app.UIAxes, 'Type', 'Image');  % Get the line object
            
            if ~isempty(h)
                set(h, 'ButtonDownFcn', @(evt)app.UIAxesButtonDown(app, evt));
            else
                disp("No plot object found in UIAxes to attach callback.");
            end

            app.update_calibration_textbox(sprintf('Starting calibration for: %s', app.CalibratemotorDropDown.Value))
            app.calibration_ongoing = 1;
        end

        % Callback function: UIAxes
        function UIAxesButtonDown(app, event)
            if app.calibration_ongoing
                if ~app.calibration_p1_done && app.calibration_p1_ready
                    current_calibration_selection = app.CalibratemotorDropDown.Value;
                    if strcmp(current_calibration_selection, 'Notch position')
                        current_motor_PV = 'COLL:LI20:2069:MOTR';
                    elseif strcmp(current_calibration_selection, 'Left jaw position')
                        current_motor_PV = 'COLL:LI20:2085:MOTR';
                    elseif strcmp(current_calibration_selection, 'Right jaw position')
                        current_motor_PV = 'COLL:LI20:2086:MOTR';
                    end

                    cp = get(app.UIAxes, 'CurrentPoint');
                    x1 = cp(1,1);
                
                    app.Pixelposition1EditField.Value = x1;
                    app.calibration_motorpos_1 = lcaGet(current_motor_PV);
                    app.calibration_p1_done = 1;

                elseif ~app.calibration_p2_done && app.calibration_p2_ready
                    current_calibration_selection = app.CalibratemotorDropDown.Value;
                    if strcmp(current_calibration_selection, 'Notch position')
                        current_motor_PV = 'COLL:LI20:2069:MOTR';
                    elseif strcmp(current_calibration_selection, 'Left jaw position')
                        current_motor_PV = 'COLL:LI20:2085:MOTR';
                    elseif strcmp(current_calibration_selection, 'Right jaw position')
                        current_motor_PV = 'COLL:LI20:2086:MOTR';
                    end

                    cp = get(app.UIAxes, CurrentPoint);
                    x2 = cp(1,1);

                    app.Pixelposition2EditField.Value = x2;
                    app.calibration_motorpos_2 = lcaGet(current_motor_PV);
                    app.calibration_p2_done = 1;
                end
            end
        end

        % Value changed function: Pixelposition1EditField
        function Pixelposition1EditFieldValueChanged(app, event)
            value = app.Pixelposition1EditField.Value;

            current_calibration_selection = app.CalibratemotorDropDown.Value;
            if strcmp(current_calibration_selection, 'Notch position')
                current_motor_PV = 'COLL:LI20:2069:MOTR.RBV';
            elseif strcmp(current_calibration_selection, 'Left jaw position')
                current_motor_PV = 'COLL:LI20:2085:MOTR.RBV';
            elseif strcmp(current_calibration_selection, 'Right jaw position')
                current_motor_PV = 'COLL:LI20:2086:MOTR.RBV';
            end
            app.calibration_motorpos_1 = lcaGet(current_motor_PV);
            additional_text = sprintf('Pixel position %d selected for %s / %s value of %.5f', value, current_calibration_selection, current_motor_PV, lcaGet(current_motor_PV));
            app.update_calibration_textbox(additional_text)

            additional_text_2 = 'Moving on to next point';
            app.update_calibration_textbox(additional_text_2)
            app.calibration_second = 1;
            
            app.calibration_p1_done = 1;

        end

        % Value changed function: Pixelposition2EditField
        function Pixelposition2EditFieldValueChanged(app, event)
            value = app.Pixelposition2EditField.Value;
            
            current_calibration_selection = app.CalibratemotorDropDown.Value;
            if strcmp(current_calibration_selection, 'Notch position')
                current_motor_PV = 'COLL:LI20:2069:MOTR.RBV';
            elseif strcmp(current_calibration_selection, 'Left jaw position')
                current_motor_PV = 'COLL:LI20:2085:MOTR.RBV';
            elseif strcmp(current_calibration_selection, 'Right jaw position')
                current_motor_PV = 'COLL:LI20:2086:MOTR.RBV';
            end
            app.calibration_motorpos_2 = lcaGet(current_motor_PV);
            additional_text = sprintf('Pixel position %d selected for %s / %s value of %.5f', value, current_calibration_selection, current_motor_PV, lcaGet(current_motor_PV));
            app.update_calibration_textbox(additional_text)
            
            additional_text_2 = 'Both points and motor positions saved!';
            app.update_calibration_textbox(additional_text_2)
            
            app.calibration_p2_done = 1;
        end

        % Button pushed function: NextButton
        function NextButtonPushed(app, event)
            if app.calibration_ongoing
                if ~app.calibration_p1_done && ~app.calibration_p1_ready
                    additional_text = 'Select the point on the figure corresponding to the relevant motor position';
                    app.update_calibration_textbox(additional_text);
                    app.calibration_p1_ready = 1;
                    app.NextButton.Enable = 'off';
                elseif ~app.calibration_p2_done && ~app.calibration_p2_ready && app.calibration_second
                    additional_text = 'Select the point on the figure corresponding to the relevant motor position';
                    app.update_calibration_textbox(additional_text);
                    app.calibration_p2_ready = 1;
                end
            end
        end

        % Button pushed function: ApplycalibrationButton
        function ApplycalibrationButtonPushed(app, event)
            if app.calibration_completed
                
                current_calibration_selection = app.CalibratemotorDropDown.Value;
                if strcmp(current_calibration_selection, 'Notch position')
                    lcaPut(app.calibration_notch_position_intercept_PV, app.InterceptEditField.Value);
                    lcaPut(app.calibration_notch_position_slope_PV, app.SlopeEditField.Value);
                elseif strcmp(current_calibration_selection, 'Left jaw position')
                    lcaPut(app.calibration_left_jaw_intercept_PV, app.InterceptEditField.Value);
                    lcaPut(app.calibration_left_jaw_slope_PV, app.SlopeEditField.Value);
                elseif strcmp(current_calibration_selection, 'Right jaw position')
                    lcaPut(app.calibration_right_jaw_intercept_PV, app.InterceptEditField.Value);
                    lcaPut(app.calibration_right_jaw_slope_PV, app.SlopeEditField.Value);
                end
    
                app.update_calibration_textbox('Updated calibration PVs');
                
                app.calibration_completed = 0;
                app.ApplycalibrationButton.Enable = 'off';
            end
        end

        % Button pushed function: ClearongoingcalibrationButton
        function ClearongoingcalibrationButtonPushed(app, event)
            app.update_calibration_textbox('Aborting/clearing ongoing calibration');
            app.calibration_ongoing = 0;
            app.calibration_completed = 0;

            app.calibration_p1_ready = 0;
            app.calibration_p2_ready = 0;

            app.calibration_p1_done = 0;
            app.calibration_p2_done = 0;

            app.calibration_messagesent_1 = 0;
            app.calibration_messagesent_2 = 0;

            app.calibration_second = 0;

            app.Pixelposition1EditField.Value = 0;
            app.Pixelposition2EditField.Value = 0;

            app.SlopeEditField.Value = 0;
            app.InterceptEditField.Value = 0;
        end

        % Selection change function: TabGroup
        function TabGroupSelectionChanged(app, event)
            selectedTab = app.TabGroup.SelectedTab;
            if selectedTab == app.MaincontrolsTab
                app.update_calibration_textbox('Aborting/clearing ongoing calibration');
                app.calibration_ongoing = 0;
                app.calibration_completed = 0;
                
                app.calibration_p1_ready = 0;
                app.calibration_p2_ready = 0;
                
                app.calibration_p1_done = 0;
                app.calibration_p2_done = 0;
                
                app.calibration_messagesent_1 = 0;
                app.calibration_messagesent_2 = 0;
                
                app.calibration_second = 0;
                
                app.Pixelposition1EditField.Value = 0;
                app.Pixelposition2EditField.Value = 0;
                
                app.SlopeEditField.Value = 0;
                app.InterceptEditField.Value = 0;
                current_selection = app.CalibratemotorDropDown.Value;
                app.OngoingcalibrationTextArea.Value = {sprintf('Ready to start calibration: %s', current_selection)};
            end
        end

        % Button pushed function: CurrentmotorpositionButton
        function CurrentmotorpositionButtonPushed(app, event)
            current_calibration_selection = app.SelectmotorDropDown.Value;
            if strcmp(current_calibration_selection, 'Notch position')
                current_motor_PV = 'COLL:LI20:2069:MOTR.RBV';
            elseif strcmp(current_calibration_selection, 'Left jaw position')
                current_motor_PV = 'COLL:LI20:2085:MOTR.RBV';
            elseif strcmp(current_calibration_selection, 'Right jaw position')
                current_motor_PV = 'COLL:LI20:2086:MOTR.RBV';
            end
            app.Motorposition1EditField.Value = lcaGet(current_motor_PV);
        end

        % Button pushed function: CurrentmotorpositionButton_2
        function CurrentmotorpositionButton_2Pushed(app, event)
            current_calibration_selection = app.SelectmotorDropDown.Value;
            if strcmp(current_calibration_selection, 'Notch position')
                current_motor_PV = 'COLL:LI20:2069:MOTR.RBV';
            elseif strcmp(current_calibration_selection, 'Left jaw position')
                current_motor_PV = 'COLL:LI20:2085:MOTR.RBV';
            elseif strcmp(current_calibration_selection, 'Right jaw position')
                current_motor_PV = 'COLL:LI20:2086:MOTR.RBV';
            end
            app.Motorposition2EditField.Value = lcaGet(current_motor_PV);
        end

        % Button pushed function: ClearButton
        function ClearButtonPushed(app, event)
            app.Pixelposition1EditField_2.Value = 0;
            app.Pixelposition2EditField_2.Value = 0;
            app.Motorposition1EditField.Value = 0;
            app.Motorposition2EditField.Value = 0;
        end

        % Button pushed function: CalculateButton
        function CalculateButtonPushed(app, event)
            app.SlopeEditField_2.Value = (app.Motorposition2EditField.Value - app.Motorposition1EditField.Value)/(app.Pixelposition2EditField_2.Value - app.Pixelposition1EditField_2.Value) ; %b
            app.InterceptEditField_2.Value = app.Motorposition1EditField.Value - (app.Motorposition2EditField.Value - app.Motorposition1EditField.Value)/(app.Pixelposition2EditField_2.Value - app.Pixelposition1EditField_2.Value) * app.Pixelposition1EditField_2.Value; %a
        end

        % Button pushed function: ApplycalibrationButton_2
        function ApplycalibrationButton_2Pushed(app, event)
            current_calibration_selection = app.SelectmotorDropDown.Value;
            if strcmp(current_calibration_selection, 'Notch position')
                lcaPut(app.calibration_notch_position_intercept_PV, app.InterceptEditField_2.Value);
                lcaPut(app.calibration_notch_position_slope_PV, app.SlopeEditField_2.Value);
            elseif strcmp(current_calibration_selection, 'Left jaw position')
                lcaPut(app.calibration_left_jaw_intercept_PV, app.InterceptEditField_2.Value);
                lcaPut(app.calibration_left_jaw_slope_PV, app.SlopeEditField_2.Value);
            elseif strcmp(current_calibration_selection, 'Right jaw position')
                lcaPut(app.calibration_right_jaw_intercept_PV, app.InterceptEditField_2.Value);
                lcaPut(app.calibration_right_jaw_slope_PV, app.SlopeEditField_2.Value);
            end
        end

        % Value changed function: NotchpositionumEditField
        function NotchpositionumEditFieldValueChanged(app, event)
            value = app.NotchpositionumEditField.Value;
            lcaPut(app.calibration_notch_position_slope_PV, value);
        end

        % Value changed function: EditField
        function EditFieldValueChanged(app, event)
            value = app.EditField.Value;
            lcaPut(app.calibration_notch_position_intercept_PV, value);
        end

        % Value changed function: LeftjawpositionmmEditField_2
        function LeftjawpositionmmEditField_2ValueChanged(app, event)
            value = app.LeftjawpositionmmEditField_2.Value;
            lcaPut(app.calibration_left_jaw_slope_PV, value);
        end

        % Value changed function: EditField3
        function EditField3ValueChanged(app, event)
            value = app.EditField3.Value;
            lcaPut(app.calibration_left_jaw_intercept_PV, value);
        end

        % Value changed function: RightjawpositionmmEditField_2
        function RightjawpositionmmEditField_2ValueChanged(app, event)
            value = app.RightjawpositionmmEditField_2.Value;
            lcaPut(app.calibration_right_jaw_slope_PV, value);
        end

        % Value changed function: EditField4
        function EditField4ValueChanged(app, event)
            value = app.EditField4.Value;
            lcaPut(app.calibration_right_jaw_intercept_PV, value);
        end

        % Value changed function: NotchangledegEditField_2
        function NotchangledegEditField_2ValueChanged(app, event)
            value = app.NotchangledegEditField_2.Value;
            lcaPut(app.calibration_notch_angle_slope_PV, value);
        end

        % Value changed function: EditField_2
        function EditField_2ValueChanged(app, event)
            value = app.EditField_2.Value;
            lcaPut(app.calibration_notch_angle_offset_PV, value);
        end

        % Value changed function: EditField2
        function EditField2ValueChanged(app, event)
            value = app.EditField2.Value;
            lcaPut(app.calibration_notch_angle_intercept_PV, value);
        end

        % Value changed function: SelectmotorDropDown
        function SelectmotorDropDownValueChanged(app, event)
            value = app.SelectmotorDropDown.Value;
            if strcmp(value, 'Notch position')
                app.Label_3.Visible = 'on';
                app.onSYAGbeforecalibratingnotchpositionLabel.Visible = 'on';
            else
                app.Label_3.Visible = 'off';
                app.onSYAGbeforecalibratingnotchpositionLabel.Visible = 'off';
            end
        end

        % Button pushed function: ShowcalibrationdetailsButton
        function ShowcalibrationdetailsButtonPushed(app, event)
            msgbox(["left jaw motor = a_l + b_l * (left jaw px)", ...
                    "right jaw motor = a_r + b_r * (right jaw px)", ...
                    "notch angle motor = -sqrt((notch width px)^2-a^2)/b + t0",...
                    "notch position motor = a' + b' * (notch position px) + c'((notch angle)-t0)"],"Calibration details");
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {575, 575};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {422, '1x'};
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
            app.UIFigure.Position = [100 100 949 575];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {422, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create TabGroup
            app.TabGroup = uitabgroup(app.LeftPanel);
            app.TabGroup.SelectionChangedFcn = createCallbackFcn(app, @TabGroupSelectionChanged, true);
            app.TabGroup.Position = [8 7 409 513];

            % Create MaincontrolsTab
            app.MaincontrolsTab = uitab(app.TabGroup);
            app.MaincontrolsTab.Title = 'Main controls';

            % Create DrivebunchcenterpxSpinnerLabel
            app.DrivebunchcenterpxSpinnerLabel = uilabel(app.MaincontrolsTab);
            app.DrivebunchcenterpxSpinnerLabel.HorizontalAlignment = 'right';
            app.DrivebunchcenterpxSpinnerLabel.Position = [18 386 128 22];
            app.DrivebunchcenterpxSpinnerLabel.Text = 'Drive bunch center [px]';

            % Create CurrentcompressionButtonGroup
            app.CurrentcompressionButtonGroup = uibuttongroup(app.MaincontrolsTab);
            app.CurrentcompressionButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @CurrentcompressionButtonGroupSelectionChanged, true);
            app.CurrentcompressionButtonGroup.TitlePosition = 'centertop';
            app.CurrentcompressionButtonGroup.Title = 'Current compression';
            app.CurrentcompressionButtonGroup.Position = [145 417 262 61];

            % Create OvercompressedButton
            app.OvercompressedButton = uitogglebutton(app.CurrentcompressionButtonGroup);
            app.OvercompressedButton.Text = 'Over compressed';
            app.OvercompressedButton.Position = [144 9 109 22];
            app.OvercompressedButton.Value = true;

            % Create UndercompressedButton
            app.UndercompressedButton = uitogglebutton(app.CurrentcompressionButtonGroup);
            app.UndercompressedButton.Text = 'Under compressed';
            app.UndercompressedButton.Position = [8 9 116 22];

            % Create DBC_UC
            app.DBC_UC = uispinner(app.MaincontrolsTab);
            app.DBC_UC.Limits = [0 Inf];
            app.DBC_UC.ValueChangedFcn = createCallbackFcn(app, @DBC_UCValueChanged, true);
            app.DBC_UC.Editable = 'off';
            app.DBC_UC.Enable = 'off';
            app.DBC_UC.Position = [161 386 100 22];

            % Create DBC_OC
            app.DBC_OC = uispinner(app.MaincontrolsTab);
            app.DBC_OC.Limits = [0 Inf];
            app.DBC_OC.ValueChangedFcn = createCallbackFcn(app, @DBC_OCValueChanged, true);
            app.DBC_OC.Position = [294 386 100 22];

            % Create DrivebunchwidthpxSpinnerLabel
            app.DrivebunchwidthpxSpinnerLabel = uilabel(app.MaincontrolsTab);
            app.DrivebunchwidthpxSpinnerLabel.HorizontalAlignment = 'right';
            app.DrivebunchwidthpxSpinnerLabel.Position = [23 352 123 22];
            app.DrivebunchwidthpxSpinnerLabel.Text = 'Drive bunch width [px]';

            % Create DBW_UC
            app.DBW_UC = uispinner(app.MaincontrolsTab);
            app.DBW_UC.Limits = [0 Inf];
            app.DBW_UC.ValueChangedFcn = createCallbackFcn(app, @DBW_UCValueChanged, true);
            app.DBW_UC.Editable = 'off';
            app.DBW_UC.Enable = 'off';
            app.DBW_UC.Position = [161 352 100 22];

            % Create DBW_OC
            app.DBW_OC = uispinner(app.MaincontrolsTab);
            app.DBW_OC.Limits = [0 Inf];
            app.DBW_OC.ValueChangedFcn = createCallbackFcn(app, @DBW_OCValueChanged, true);
            app.DBW_OC.Position = [294 352 100 22];

            % Create WBC_OC
            app.WBC_OC = uispinner(app.MaincontrolsTab);
            app.WBC_OC.Limits = [0 Inf];
            app.WBC_OC.ValueChangedFcn = createCallbackFcn(app, @WBC_OCValueChanged, true);
            app.WBC_OC.Position = [294 317 100 22];

            % Create WitnessbunchcenterpxSpinnerLabel
            app.WitnessbunchcenterpxSpinnerLabel = uilabel(app.MaincontrolsTab);
            app.WitnessbunchcenterpxSpinnerLabel.HorizontalAlignment = 'right';
            app.WitnessbunchcenterpxSpinnerLabel.Position = [3 317 143 22];
            app.WitnessbunchcenterpxSpinnerLabel.Text = 'Witness bunch center [px]';

            % Create WBC_UC
            app.WBC_UC = uispinner(app.MaincontrolsTab);
            app.WBC_UC.Limits = [0 Inf];
            app.WBC_UC.ValueChangedFcn = createCallbackFcn(app, @WBC_UCValueChanged, true);
            app.WBC_UC.Editable = 'off';
            app.WBC_UC.Enable = 'off';
            app.WBC_UC.Position = [161 317 100 22];

            % Create WBW_OC
            app.WBW_OC = uispinner(app.MaincontrolsTab);
            app.WBW_OC.Limits = [0 Inf];
            app.WBW_OC.ValueChangedFcn = createCallbackFcn(app, @WBW_OCValueChanged, true);
            app.WBW_OC.Position = [294 281 100 22];

            % Create WitnessbunchwidthpxSpinnerLabel
            app.WitnessbunchwidthpxSpinnerLabel = uilabel(app.MaincontrolsTab);
            app.WitnessbunchwidthpxSpinnerLabel.HorizontalAlignment = 'right';
            app.WitnessbunchwidthpxSpinnerLabel.Position = [8 281 138 22];
            app.WitnessbunchwidthpxSpinnerLabel.Text = 'Witness bunch width [px]';

            % Create WBW_UC
            app.WBW_UC = uispinner(app.MaincontrolsTab);
            app.WBW_UC.Limits = [0 Inf];
            app.WBW_UC.ValueChangedFcn = createCallbackFcn(app, @WBW_UCValueChanged, true);
            app.WBW_UC.Editable = 'off';
            app.WBW_UC.Enable = 'off';
            app.WBW_UC.Position = [161 281 100 22];

            % Create ApplyconfigurationButton
            app.ApplyconfigurationButton = uibutton(app.MaincontrolsTab, 'push');
            app.ApplyconfigurationButton.ButtonPushedFcn = createCallbackFcn(app, @ApplyconfigurationButtonPushed, true);
            app.ApplyconfigurationButton.BackgroundColor = [0 1 0];
            app.ApplyconfigurationButton.Position = [166 12 232 53];
            app.ApplyconfigurationButton.Text = 'Apply configuration';

            % Create BlockdriveCheckBox
            app.BlockdriveCheckBox = uicheckbox(app.MaincontrolsTab);
            app.BlockdriveCheckBox.Text = 'Block drive';
            app.BlockdriveCheckBox.Position = [45 242 80 22];

            % Create BlockwitnessCheckBox
            app.BlockwitnessCheckBox = uicheckbox(app.MaincontrolsTab);
            app.BlockwitnessCheckBox.Text = 'Block witness';
            app.BlockwitnessCheckBox.Position = [45 221 94 22];

            % Create CalculateconfigurationButton
            app.CalculateconfigurationButton = uibutton(app.MaincontrolsTab, 'push');
            app.CalculateconfigurationButton.ButtonPushedFcn = createCallbackFcn(app, @CalculateconfigurationButtonPushed, true);
            app.CalculateconfigurationButton.Position = [161 221 233 43];
            app.CalculateconfigurationButton.Text = 'Calculate configuration';

            % Create SavecurrentstateButton
            app.SavecurrentstateButton = uibutton(app.MaincontrolsTab, 'push');
            app.SavecurrentstateButton.ButtonPushedFcn = createCallbackFcn(app, @SavecurrentstateButtonPushed, true);
            app.SavecurrentstateButton.Position = [27 43 112 22];
            app.SavecurrentstateButton.Text = 'Save current state';

            % Create LoadsavedstateButton
            app.LoadsavedstateButton = uibutton(app.MaincontrolsTab, 'push');
            app.LoadsavedstateButton.ButtonPushedFcn = createCallbackFcn(app, @LoadsavedstateButtonPushed, true);
            app.LoadsavedstateButton.Position = [31 12 106 22];
            app.LoadsavedstateButton.Text = 'Load saved state';

            % Create NotchpositionmEditFieldLabel
            app.NotchpositionmEditFieldLabel = uilabel(app.MaincontrolsTab);
            app.NotchpositionmEditFieldLabel.HorizontalAlignment = 'right';
            app.NotchpositionmEditFieldLabel.Position = [171 185 108 22];
            app.NotchpositionmEditFieldLabel.Text = 'Notch position [µm]';

            % Create NotchpositionmEditField
            app.NotchpositionmEditField = uieditfield(app.MaincontrolsTab, 'numeric');
            app.NotchpositionmEditField.ValueDisplayFormat = '%.3f';
            app.NotchpositionmEditField.Position = [294 185 100 22];

            % Create NotchangledegEditFieldLabel
            app.NotchangledegEditFieldLabel = uilabel(app.MaincontrolsTab);
            app.NotchangledegEditFieldLabel.HorizontalAlignment = 'right';
            app.NotchangledegEditFieldLabel.Position = [180 150 99 22];
            app.NotchangledegEditFieldLabel.Text = 'Notch angle [deg]';

            % Create NotchangledegEditField
            app.NotchangledegEditField = uieditfield(app.MaincontrolsTab, 'numeric');
            app.NotchangledegEditField.Position = [294 150 100 22];

            % Create LeftjawpositionmmEditFieldLabel
            app.LeftjawpositionmmEditFieldLabel = uilabel(app.MaincontrolsTab);
            app.LeftjawpositionmmEditFieldLabel.HorizontalAlignment = 'right';
            app.LeftjawpositionmmEditFieldLabel.Position = [158 115 121 22];
            app.LeftjawpositionmmEditFieldLabel.Text = 'Left jaw position [mm]';

            % Create LeftjawpositionmmEditField
            app.LeftjawpositionmmEditField = uieditfield(app.MaincontrolsTab, 'numeric');
            app.LeftjawpositionmmEditField.Position = [294 115 100 22];

            % Create RightjawpositionmmLabel
            app.RightjawpositionmmLabel = uilabel(app.MaincontrolsTab);
            app.RightjawpositionmmLabel.HorizontalAlignment = 'right';
            app.RightjawpositionmmLabel.Position = [150 83 129 22];
            app.RightjawpositionmmLabel.Text = 'Right jaw position [mm]';

            % Create RightjawpositionmmEditField
            app.RightjawpositionmmEditField = uieditfield(app.MaincontrolsTab, 'numeric');
            app.RightjawpositionmmEditField.Position = [294 83 100 22];

            % Create CalibrationtoolTab
            app.CalibrationtoolTab = uitab(app.TabGroup);
            app.CalibrationtoolTab.Title = 'Calibration tool';

            % Create CurrentcalibrationsettingsLabel
            app.CurrentcalibrationsettingsLabel = uilabel(app.CalibrationtoolTab);
            app.CurrentcalibrationsettingsLabel.FontSize = 18;
            app.CurrentcalibrationsettingsLabel.FontWeight = 'bold';
            app.CurrentcalibrationsettingsLabel.Position = [94 455 242 23];
            app.CurrentcalibrationsettingsLabel.Text = 'Current calibration settings';

            % Create CalibratemotorDropDownLabel
            app.CalibratemotorDropDownLabel = uilabel(app.CalibrationtoolTab);
            app.CalibratemotorDropDownLabel.HorizontalAlignment = 'right';
            app.CalibratemotorDropDownLabel.Position = [6 221 129 22];
            app.CalibratemotorDropDownLabel.Text = 'Calibrate motor';

            % Create CalibratemotorDropDown
            app.CalibratemotorDropDown = uidropdown(app.CalibrationtoolTab);
            app.CalibratemotorDropDown.Items = {'Notch position', 'Left jaw position', 'Right jaw position'};
            app.CalibratemotorDropDown.ValueChangedFcn = createCallbackFcn(app, @CalibratemotorDropDownValueChanged, true);
            app.CalibratemotorDropDown.Position = [150 221 249 22];
            app.CalibratemotorDropDown.Value = 'Notch position';

            % Create OngoingcalibrationTextArea
            app.OngoingcalibrationTextArea = uitextarea(app.CalibrationtoolTab);
            app.OngoingcalibrationTextArea.Editable = 'off';
            app.OngoingcalibrationTextArea.Position = [8 12 397 103];
            app.OngoingcalibrationTextArea.Value = {'Ready to start calibration: Notch position'};

            % Create Pixelposition1EditFieldLabel
            app.Pixelposition1EditFieldLabel = uilabel(app.CalibrationtoolTab);
            app.Pixelposition1EditFieldLabel.HorizontalAlignment = 'right';
            app.Pixelposition1EditFieldLabel.Position = [2 138 86 22];
            app.Pixelposition1EditFieldLabel.Text = 'Pixel position 1';

            % Create Pixelposition1EditField
            app.Pixelposition1EditField = uieditfield(app.CalibrationtoolTab, 'numeric');
            app.Pixelposition1EditField.ValueChangedFcn = createCallbackFcn(app, @Pixelposition1EditFieldValueChanged, true);
            app.Pixelposition1EditField.Position = [103 138 100 22];

            % Create Pixelposition2EditFieldLabel
            app.Pixelposition2EditFieldLabel = uilabel(app.CalibrationtoolTab);
            app.Pixelposition2EditFieldLabel.HorizontalAlignment = 'right';
            app.Pixelposition2EditFieldLabel.Position = [2 117 86 22];
            app.Pixelposition2EditFieldLabel.Text = 'Pixel position 2';

            % Create Pixelposition2EditField
            app.Pixelposition2EditField = uieditfield(app.CalibrationtoolTab, 'numeric');
            app.Pixelposition2EditField.ValueChangedFcn = createCallbackFcn(app, @Pixelposition2EditFieldValueChanged, true);
            app.Pixelposition2EditField.Position = [103 117 100 22];

            % Create SlopeEditFieldLabel
            app.SlopeEditFieldLabel = uilabel(app.CalibrationtoolTab);
            app.SlopeEditFieldLabel.HorizontalAlignment = 'right';
            app.SlopeEditFieldLabel.Position = [250 138 36 22];
            app.SlopeEditFieldLabel.Text = 'Slope';

            % Create SlopeEditField
            app.SlopeEditField = uieditfield(app.CalibrationtoolTab, 'numeric');
            app.SlopeEditField.Editable = 'off';
            app.SlopeEditField.Position = [301 138 100 22];

            % Create InterceptEditFieldLabel
            app.InterceptEditFieldLabel = uilabel(app.CalibrationtoolTab);
            app.InterceptEditFieldLabel.HorizontalAlignment = 'right';
            app.InterceptEditFieldLabel.Position = [234 117 52 22];
            app.InterceptEditFieldLabel.Text = 'Intercept';

            % Create InterceptEditField
            app.InterceptEditField = uieditfield(app.CalibrationtoolTab, 'numeric');
            app.InterceptEditField.Editable = 'off';
            app.InterceptEditField.Position = [301 117 100 22];

            % Create SemiautomaticCalibrationLabel
            app.SemiautomaticCalibrationLabel = uilabel(app.CalibrationtoolTab);
            app.SemiautomaticCalibrationLabel.HorizontalAlignment = 'center';
            app.SemiautomaticCalibrationLabel.FontSize = 18;
            app.SemiautomaticCalibrationLabel.FontWeight = 'bold';
            app.SemiautomaticCalibrationLabel.Position = [91 245 241 23];
            app.SemiautomaticCalibrationLabel.Text = 'Semi-automatic Calibration';

            % Create RestoredefaultsettingsButton
            app.RestoredefaultsettingsButton = uibutton(app.CalibrationtoolTab, 'push');
            app.RestoredefaultsettingsButton.ButtonPushedFcn = createCallbackFcn(app, @RestoredefaultsettingsButtonPushed, true);
            app.RestoredefaultsettingsButton.Position = [243 269 148 22];
            app.RestoredefaultsettingsButton.Text = 'Restore default settings';

            % Create StartcalibrationButton
            app.StartcalibrationButton = uibutton(app.CalibrationtoolTab, 'push');
            app.StartcalibrationButton.ButtonPushedFcn = createCallbackFcn(app, @StartcalibrationButtonPushed, true);
            app.StartcalibrationButton.Position = [6 193 100 22];
            app.StartcalibrationButton.Text = 'Start calibration';

            % Create ClearongoingcalibrationButton
            app.ClearongoingcalibrationButton = uibutton(app.CalibrationtoolTab, 'push');
            app.ClearongoingcalibrationButton.ButtonPushedFcn = createCallbackFcn(app, @ClearongoingcalibrationButtonPushed, true);
            app.ClearongoingcalibrationButton.Position = [38 167 147 22];
            app.ClearongoingcalibrationButton.Text = 'Clear ongoing calibration';

            % Create ApplycalibrationButton
            app.ApplycalibrationButton = uibutton(app.CalibrationtoolTab, 'push');
            app.ApplycalibrationButton.ButtonPushedFcn = createCallbackFcn(app, @ApplycalibrationButtonPushed, true);
            app.ApplycalibrationButton.Enable = 'off';
            app.ApplycalibrationButton.Position = [264 167 134 48];
            app.ApplycalibrationButton.Text = 'Apply calibration';

            % Create NextButton
            app.NextButton = uibutton(app.CalibrationtoolTab, 'push');
            app.NextButton.ButtonPushedFcn = createCallbackFcn(app, @NextButtonPushed, true);
            app.NextButton.Enable = 'off';
            app.NextButton.Position = [124 193 100 22];
            app.NextButton.Text = 'Next';

            % Create SlopeLabel
            app.SlopeLabel = uilabel(app.CalibrationtoolTab);
            app.SlopeLabel.Position = [197 437 36 22];
            app.SlopeLabel.Text = 'Slope';

            % Create InterceptLabel
            app.InterceptLabel = uilabel(app.CalibrationtoolTab);
            app.InterceptLabel.Position = [320 437 52 22];
            app.InterceptLabel.Text = 'Intercept';

            % Create EditField
            app.EditField = uieditfield(app.CalibrationtoolTab, 'numeric');
            app.EditField.ValueDisplayFormat = '%.2f';
            app.EditField.ValueChangedFcn = createCallbackFcn(app, @EditFieldValueChanged, true);
            app.EditField.Position = [266 330 44 22];

            % Create EditField2
            app.EditField2 = uieditfield(app.CalibrationtoolTab, 'numeric');
            app.EditField2.ValueDisplayFormat = '%.2f';
            app.EditField2.ValueChangedFcn = createCallbackFcn(app, @EditField2ValueChanged, true);
            app.EditField2.Position = [266 352 44 22];

            % Create EditField3
            app.EditField3 = uieditfield(app.CalibrationtoolTab, 'numeric');
            app.EditField3.ValueDisplayFormat = '%.2f';
            app.EditField3.ValueChangedFcn = createCallbackFcn(app, @EditField3ValueChanged, true);
            app.EditField3.Position = [323 416 68 22];

            % Create EditField4
            app.EditField4 = uieditfield(app.CalibrationtoolTab, 'numeric');
            app.EditField4.ValueDisplayFormat = '%.2f';
            app.EditField4.ValueChangedFcn = createCallbackFcn(app, @EditField4ValueChanged, true);
            app.EditField4.Position = [323 395 68 22];

            % Create NotchpositionumEditFieldLabel
            app.NotchpositionumEditFieldLabel = uilabel(app.CalibrationtoolTab);
            app.NotchpositionumEditFieldLabel.HorizontalAlignment = 'right';
            app.NotchpositionumEditFieldLabel.Position = [43 330 108 22];
            app.NotchpositionumEditFieldLabel.Text = 'Notch position [um]';

            % Create NotchpositionumEditField
            app.NotchpositionumEditField = uieditfield(app.CalibrationtoolTab, 'numeric');
            app.NotchpositionumEditField.ValueDisplayFormat = '%.2f';
            app.NotchpositionumEditField.ValueChangedFcn = createCallbackFcn(app, @NotchpositionumEditFieldValueChanged, true);
            app.NotchpositionumEditField.Position = [188 330 45 22];

            % Create NotchangledegEditField_2Label
            app.NotchangledegEditField_2Label = uilabel(app.CalibrationtoolTab);
            app.NotchangledegEditField_2Label.HorizontalAlignment = 'right';
            app.NotchangledegEditField_2Label.Position = [51 352 100 22];
            app.NotchangledegEditField_2Label.Text = 'Notch angle [deg]';

            % Create NotchangledegEditField_2
            app.NotchangledegEditField_2 = uieditfield(app.CalibrationtoolTab, 'numeric');
            app.NotchangledegEditField_2.ValueDisplayFormat = '%.2f';
            app.NotchangledegEditField_2.ValueChangedFcn = createCallbackFcn(app, @NotchangledegEditField_2ValueChanged, true);
            app.NotchangledegEditField_2.Position = [188 352 45 22];

            % Create LeftjawpositionmmEditField_2Label
            app.LeftjawpositionmmEditField_2Label = uilabel(app.CalibrationtoolTab);
            app.LeftjawpositionmmEditField_2Label.HorizontalAlignment = 'right';
            app.LeftjawpositionmmEditField_2Label.Position = [28 416 122 22];
            app.LeftjawpositionmmEditField_2Label.Text = 'Left jaw position [mm]';

            % Create LeftjawpositionmmEditField_2
            app.LeftjawpositionmmEditField_2 = uieditfield(app.CalibrationtoolTab, 'numeric');
            app.LeftjawpositionmmEditField_2.ValueDisplayFormat = '%.2f';
            app.LeftjawpositionmmEditField_2.ValueChangedFcn = createCallbackFcn(app, @LeftjawpositionmmEditField_2ValueChanged, true);
            app.LeftjawpositionmmEditField_2.Position = [194 416 71 22];

            % Create RightjawpositionmmEditField_2Label
            app.RightjawpositionmmEditField_2Label = uilabel(app.CalibrationtoolTab);
            app.RightjawpositionmmEditField_2Label.HorizontalAlignment = 'right';
            app.RightjawpositionmmEditField_2Label.Position = [20 397 130 22];
            app.RightjawpositionmmEditField_2Label.Text = 'Right jaw position [mm]';

            % Create RightjawpositionmmEditField_2
            app.RightjawpositionmmEditField_2 = uieditfield(app.CalibrationtoolTab, 'numeric');
            app.RightjawpositionmmEditField_2.ValueDisplayFormat = '%.2f';
            app.RightjawpositionmmEditField_2.ValueChangedFcn = createCallbackFcn(app, @RightjawpositionmmEditField_2ValueChanged, true);
            app.RightjawpositionmmEditField_2.Position = [194 397 71 22];

            % Create EditField_2
            app.EditField_2 = uieditfield(app.CalibrationtoolTab, 'numeric');
            app.EditField_2.ValueDisplayFormat = '%.2f';
            app.EditField_2.ValueChangedFcn = createCallbackFcn(app, @EditField_2ValueChanged, true);
            app.EditField_2.Position = [346 352 45 22];

            % Create SlopeLabel_2
            app.SlopeLabel_2 = uilabel(app.CalibrationtoolTab);
            app.SlopeLabel_2.Position = [185 370 36 22];
            app.SlopeLabel_2.Text = 'Slope';

            % Create InterceptLabel_2
            app.InterceptLabel_2 = uilabel(app.CalibrationtoolTab);
            app.InterceptLabel_2.Position = [253 370 52 22];
            app.InterceptLabel_2.Text = 'Intercept';

            % Create OffsetLabel
            app.OffsetLabel = uilabel(app.CalibrationtoolTab);
            app.OffsetLabel.Position = [338 370 37 22];
            app.OffsetLabel.Text = 'Offset';

            % Create EditField_3
            app.EditField_3 = uieditfield(app.CalibrationtoolTab, 'numeric');
            app.EditField_3.ValueDisplayFormat = '%.2f';
            app.EditField_3.Position = [346 330 45 23];

            % Create WarningwilloverwritecalibrationPVswithhardcodeddefaultsLabel
            app.WarningwilloverwritecalibrationPVswithhardcodeddefaultsLabel = uilabel(app.CalibrationtoolTab);
            app.WarningwilloverwritecalibrationPVswithhardcodeddefaultsLabel.Position = [52 269 183 28];
            app.WarningwilloverwritecalibrationPVswithhardcodeddefaultsLabel.Text = {'Warning: will overwrite calibration'; 'PVs with hard coded defaults [!]'};

            % Create ShowcalibrationdetailsButton
            app.ShowcalibrationdetailsButton = uibutton(app.CalibrationtoolTab, 'push');
            app.ShowcalibrationdetailsButton.ButtonPushedFcn = createCallbackFcn(app, @ShowcalibrationdetailsButtonPushed, true);
            app.ShowcalibrationdetailsButton.Position = [246 296 142 22];
            app.ShowcalibrationdetailsButton.Text = 'Show calibration details';

            % Create bLabel
            app.bLabel = uilabel(app.CalibrationtoolTab);
            app.bLabel.Position = [166 351 25 22];
            app.bLabel.Text = 'b =';

            % Create bLabel_2
            app.bLabel_2 = uilabel(app.CalibrationtoolTab);
            app.bLabel_2.Position = [165 331 25 22];
            app.bLabel_2.Text = 'b'' =';

            % Create aLabel
            app.aLabel = uilabel(app.CalibrationtoolTab);
            app.aLabel.Position = [246 351 25 22];
            app.aLabel.Text = 'a =';

            % Create aLabel_2
            app.aLabel_2 = uilabel(app.CalibrationtoolTab);
            app.aLabel_2.Position = [243 330 25 22];
            app.aLabel_2.Text = 'a'' =';

            % Create t0Label
            app.t0Label = uilabel(app.CalibrationtoolTab);
            app.t0Label.Position = [323 351 26 22];
            app.t0Label.Text = 't0 =';

            % Create cLabel
            app.cLabel = uilabel(app.CalibrationtoolTab);
            app.cLabel.Position = [323 331 25 22];
            app.cLabel.Text = 'c'' =';

            % Create b_lLabel
            app.b_lLabel = uilabel(app.CalibrationtoolTab);
            app.b_lLabel.Position = [166 416 32 22];
            app.b_lLabel.Text = 'b_l =';

            % Create b_rLabel
            app.b_rLabel = uilabel(app.CalibrationtoolTab);
            app.b_rLabel.Position = [165 397 33 22];
            app.b_rLabel.Text = 'b_r =';

            % Create a_lLabel
            app.a_lLabel = uilabel(app.CalibrationtoolTab);
            app.a_lLabel.Position = [294 416 32 22];
            app.a_lLabel.Text = 'a_l =';

            % Create a_rLabel
            app.a_rLabel = uilabel(app.CalibrationtoolTab);
            app.a_rLabel.Position = [293 395 33 22];
            app.a_rLabel.Text = 'a_r =';

            % Create CalibrationtoolbutmanualTab
            app.CalibrationtoolbutmanualTab = uitab(app.TabGroup);
            app.CalibrationtoolbutmanualTab.Title = 'Calibration tool but manual';

            % Create SelectmotorDropDownLabel
            app.SelectmotorDropDownLabel = uilabel(app.CalibrationtoolbutmanualTab);
            app.SelectmotorDropDownLabel.HorizontalAlignment = 'right';
            app.SelectmotorDropDownLabel.Position = [24 425 73 22];
            app.SelectmotorDropDownLabel.Text = 'Select motor';

            % Create SelectmotorDropDown
            app.SelectmotorDropDown = uidropdown(app.CalibrationtoolbutmanualTab);
            app.SelectmotorDropDown.Items = {'Notch position', 'Left jaw position', 'Right jaw position'};
            app.SelectmotorDropDown.ValueChangedFcn = createCallbackFcn(app, @SelectmotorDropDownValueChanged, true);
            app.SelectmotorDropDown.Position = [112 425 286 22];
            app.SelectmotorDropDown.Value = 'Notch position';

            % Create FancylinearequationsolverLabel
            app.FancylinearequationsolverLabel = uilabel(app.CalibrationtoolbutmanualTab);
            app.FancylinearequationsolverLabel.HorizontalAlignment = 'center';
            app.FancylinearequationsolverLabel.FontSize = 20;
            app.FancylinearequationsolverLabel.Position = [67 453 258 25];
            app.FancylinearequationsolverLabel.Text = 'Fancy linear equation solver';

            % Create Pixelposition1EditField_2Label
            app.Pixelposition1EditField_2Label = uilabel(app.CalibrationtoolbutmanualTab);
            app.Pixelposition1EditField_2Label.HorizontalAlignment = 'right';
            app.Pixelposition1EditField_2Label.Position = [27 317 86 22];
            app.Pixelposition1EditField_2Label.Text = 'Pixel position 1';

            % Create Pixelposition1EditField_2
            app.Pixelposition1EditField_2 = uieditfield(app.CalibrationtoolbutmanualTab, 'numeric');
            app.Pixelposition1EditField_2.Position = [128 317 49 22];

            % Create Pixelposition2EditField_2Label
            app.Pixelposition2EditField_2Label = uilabel(app.CalibrationtoolbutmanualTab);
            app.Pixelposition2EditField_2Label.HorizontalAlignment = 'right';
            app.Pixelposition2EditField_2Label.Position = [227 317 86 22];
            app.Pixelposition2EditField_2Label.Text = 'Pixel position 2';

            % Create Pixelposition2EditField_2
            app.Pixelposition2EditField_2 = uieditfield(app.CalibrationtoolbutmanualTab, 'numeric');
            app.Pixelposition2EditField_2.Position = [328 317 51 22];

            % Create Motorposition1EditFieldLabel
            app.Motorposition1EditFieldLabel = uilabel(app.CalibrationtoolbutmanualTab);
            app.Motorposition1EditFieldLabel.HorizontalAlignment = 'right';
            app.Motorposition1EditFieldLabel.Position = [22 289 91 22];
            app.Motorposition1EditFieldLabel.Text = 'Motor position 1';

            % Create Motorposition1EditField
            app.Motorposition1EditField = uieditfield(app.CalibrationtoolbutmanualTab, 'numeric');
            app.Motorposition1EditField.Position = [128 289 49 22];

            % Create Motorposition2EditFieldLabel
            app.Motorposition2EditFieldLabel = uilabel(app.CalibrationtoolbutmanualTab);
            app.Motorposition2EditFieldLabel.HorizontalAlignment = 'right';
            app.Motorposition2EditFieldLabel.Position = [222 289 91 22];
            app.Motorposition2EditFieldLabel.Text = 'Motor position 2';

            % Create Motorposition2EditField
            app.Motorposition2EditField = uieditfield(app.CalibrationtoolbutmanualTab, 'numeric');
            app.Motorposition2EditField.Position = [328 289 50 22];

            % Create SlopeEditField_2Label
            app.SlopeEditField_2Label = uilabel(app.CalibrationtoolbutmanualTab);
            app.SlopeEditField_2Label.HorizontalAlignment = 'right';
            app.SlopeEditField_2Label.Position = [128 150 36 22];
            app.SlopeEditField_2Label.Text = 'Slope';

            % Create SlopeEditField_2
            app.SlopeEditField_2 = uieditfield(app.CalibrationtoolbutmanualTab, 'numeric');
            app.SlopeEditField_2.Position = [179 150 100 22];

            % Create InterceptEditField_2Label
            app.InterceptEditField_2Label = uilabel(app.CalibrationtoolbutmanualTab);
            app.InterceptEditField_2Label.HorizontalAlignment = 'right';
            app.InterceptEditField_2Label.Position = [112 114 52 22];
            app.InterceptEditField_2Label.Text = 'Intercept';

            % Create InterceptEditField_2
            app.InterceptEditField_2 = uieditfield(app.CalibrationtoolbutmanualTab, 'numeric');
            app.InterceptEditField_2.Position = [179 114 100 22];

            % Create CalculateButton
            app.CalculateButton = uibutton(app.CalibrationtoolbutmanualTab, 'push');
            app.CalculateButton.ButtonPushedFcn = createCallbackFcn(app, @CalculateButtonPushed, true);
            app.CalculateButton.Position = [264 200 100 22];
            app.CalculateButton.Text = 'Calculate';

            % Create ClearButton
            app.ClearButton = uibutton(app.CalibrationtoolbutmanualTab, 'push');
            app.ClearButton.ButtonPushedFcn = createCallbackFcn(app, @ClearButtonPushed, true);
            app.ClearButton.Position = [61 204 100 22];
            app.ClearButton.Text = 'Clear';

            % Create ApplycalibrationButton_2
            app.ApplycalibrationButton_2 = uibutton(app.CalibrationtoolbutmanualTab, 'push');
            app.ApplycalibrationButton_2.ButtonPushedFcn = createCallbackFcn(app, @ApplycalibrationButton_2Pushed, true);
            app.ApplycalibrationButton_2.Position = [61 29 304 56];
            app.ApplycalibrationButton_2.Text = 'Apply calibration';

            % Create CurrentmotorpositionButton
            app.CurrentmotorpositionButton = uibutton(app.CalibrationtoolbutmanualTab, 'push');
            app.CurrentmotorpositionButton.ButtonPushedFcn = createCallbackFcn(app, @CurrentmotorpositionButtonPushed, true);
            app.CurrentmotorpositionButton.Position = [45 260 134 22];
            app.CurrentmotorpositionButton.Text = 'Current motor position';

            % Create CurrentmotorpositionButton_2
            app.CurrentmotorpositionButton_2 = uibutton(app.CalibrationtoolbutmanualTab, 'push');
            app.CurrentmotorpositionButton_2.ButtonPushedFcn = createCallbackFcn(app, @CurrentmotorpositionButton_2Pushed, true);
            app.CurrentmotorpositionButton_2.Position = [243 260 134 22];
            app.CurrentmotorpositionButton_2.Text = 'Current motor position';

            % Create Label_3
            app.Label_3 = uilabel(app.CalibrationtoolbutmanualTab);
            app.Label_3.Position = [107 386 237 22];
            app.Label_3.Text = 'WARNING: Ensure notch width is minimum';

            % Create onSYAGbeforecalibratingnotchpositionLabel
            app.onSYAGbeforecalibratingnotchpositionLabel = uilabel(app.CalibrationtoolbutmanualTab);
            app.onSYAGbeforecalibratingnotchpositionLabel.Position = [108 365 233 22];
            app.onSYAGbeforecalibratingnotchpositionLabel.Text = 'on SYAG before calibrating notch position.';

            % Create NotchandjawcontrolsLabel
            app.NotchandjawcontrolsLabel = uilabel(app.LeftPanel);
            app.NotchandjawcontrolsLabel.HorizontalAlignment = 'center';
            app.NotchandjawcontrolsLabel.FontSize = 24;
            app.NotchandjawcontrolsLabel.FontWeight = 'bold';
            app.NotchandjawcontrolsLabel.Position = [46 533 370 31];
            app.NotchandjawcontrolsLabel.Text = 'Notch and jaw controls';

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.RightPanel);
            title(app.UIAxes, 'SYAG view')
            xlabel(app.UIAxes, 'x [px]')
            ylabel(app.UIAxes, 'y [px]')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [14 158 512 390];

            % Create StartacquiringButton
            app.StartacquiringButton = uibutton(app.RightPanel, 'push');
            app.StartacquiringButton.ButtonPushedFcn = createCallbackFcn(app, @StartacquiringButtonPushed, true);
            app.StartacquiringButton.Position = [72 101 100 22];
            app.StartacquiringButton.Text = 'Start acquiring';

            % Create StopacquiringButton
            app.StopacquiringButton = uibutton(app.RightPanel, 'push');
            app.StopacquiringButton.ButtonPushedFcn = createCallbackFcn(app, @StopacquiringButtonPushed, true);
            app.StopacquiringButton.Position = [362 101 100 22];
            app.StopacquiringButton.Text = 'Stop acquiring';

            % Create DrivewitnesschargeratioEditFieldLabel
            app.DrivewitnesschargeratioEditFieldLabel = uilabel(app.RightPanel);
            app.DrivewitnesschargeratioEditFieldLabel.HorizontalAlignment = 'right';
            app.DrivewitnesschargeratioEditFieldLabel.Position = [255 20 150 22];
            app.DrivewitnesschargeratioEditFieldLabel.Text = 'Drive : witness charge ratio';

            % Create DrivewitnesschargeratioEditField
            app.DrivewitnesschargeratioEditField = uieditfield(app.RightPanel, 'numeric');
            app.DrivewitnesschargeratioEditField.Editable = 'off';
            app.DrivewitnesschargeratioEditField.Position = [420 20 100 22];

            % Create CurrentnotchpositionpxEditFieldLabel
            app.CurrentnotchpositionpxEditFieldLabel = uilabel(app.RightPanel);
            app.CurrentnotchpositionpxEditFieldLabel.HorizontalAlignment = 'right';
            app.CurrentnotchpositionpxEditFieldLabel.Position = [260 51 145 22];
            app.CurrentnotchpositionpxEditFieldLabel.Text = 'Current notch position [px]';

            % Create CurrentnotchpositionpxEditField
            app.CurrentnotchpositionpxEditField = uieditfield(app.RightPanel, 'numeric');
            app.CurrentnotchpositionpxEditField.Editable = 'off';
            app.CurrentnotchpositionpxEditField.Position = [420 51 100 22];

            % Create SubtractbackgroundCheckBox
            app.SubtractbackgroundCheckBox = uicheckbox(app.RightPanel);
            app.SubtractbackgroundCheckBox.Enable = 'off';
            app.SubtractbackgroundCheckBox.Text = 'Subtract background';
            app.SubtractbackgroundCheckBox.Position = [28 51 132 22];

            % Create CalculatechargeratioCheckBox
            app.CalculatechargeratioCheckBox = uicheckbox(app.RightPanel);
            app.CalculatechargeratioCheckBox.Text = 'Calculate charge ratio';
            app.CalculatechargeratioCheckBox.Position = [28 20 138 22];

            % Create TakebackgroundButton
            app.TakebackgroundButton = uibutton(app.RightPanel, 'push');
            app.TakebackgroundButton.ButtonPushedFcn = createCallbackFcn(app, @TakebackgroundButtonPushed, true);
            app.TakebackgroundButton.Position = [217 101 106 22];
            app.TakebackgroundButton.Text = 'Take background';

            % Create LowenergysideLabel
            app.LowenergysideLabel = uilabel(app.RightPanel);
            app.LowenergysideLabel.Position = [14 547 92 22];
            app.LowenergysideLabel.Text = 'Low energy side';

            % Create HighenergysideLabel
            app.HighenergysideLabel = uilabel(app.RightPanel);
            app.HighenergysideLabel.Position = [395 552 95 22];
            app.HighenergysideLabel.Text = 'High energy side';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_Advanced_Collimator_Control_exported

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