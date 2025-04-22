function [notch_pos, notch_angle, left_jaw_pos, right_jaw_pos] = calc_Collimators(drive_center, drive_width, witness_center, witness_width, compression)
    calibration_notch_angle_intercept_PV = 'SIOC:SYS1:ML00:AO991'; % a
    calibration_notch_angle_slope_PV = 'SIOC:SYS1:ML00:AO992'; % b 
    calibration_notch_position_intercept_PV = 'SIOC:SYS1:ML00:AO993'; % a'
    calibration_notch_position_slope_PV = 'SIOC:SYS1:ML00:AO994'; % b'
    calibration_left_jaw_intercept_PV = 'SIOC:SYS1:ML00:AO958'; % simple linear fit for these 4
    calibration_left_jaw_slope_PV = 'SIOC:SYS1:ML00:AO964';
    calibration_right_jaw_intercept_PV = 'SIOC:SYS1:ML00:AO965';
    calibration_right_jaw_slope_PV = 'SIOC:SYS1:ML00:AO967';
    
    calibration_notch_angle_offset_PV = 'SIOC:SYS1:ML00:AO997'; % theta_0
    calibration_notch_position_angle_slope_PV = 'SIOC:SYS1:ML00:AO538'; % c'


    calibration_notch_angle =  [lcaGet(calibration_notch_angle_intercept_PV), lcaGet(calibration_notch_angle_slope_PV) lcaGet(calibration_notch_angle_offset_PV)];
    calibration_notch_position = [lcaGet(calibration_notch_position_intercept_PV), lcaGet(calibration_notch_position_slope_PV)];
    calibration_notch_position_angle_contribution = lcaGet(calibration_notch_position_angle_slope_PV);
    calibration_left_jaw = [lcaGet(calibration_left_jaw_intercept_PV), lcaGet(calibration_left_jaw_slope_PV)];
    calibration_right_jaw = [lcaGet(calibration_right_jaw_intercept_PV), lcaGet(calibration_right_jaw_slope_PV)];
    
    width = abs(drive_center - witness_center) - drive_width/2 - witness_width/2;
    
    %notch_width_in_px = sqrt(a^2 + b^2 * (theta-theta_0)^2);
    %notch_center_in_px = a' + b' * motor_pos + c'(theta-theta_0);
    
    notch_angle = -sqrt(width^2/calibration_notch_angle(2)^2 - calibration_notch_angle(1)^2/calibration_notch_angle(2)^2)+calibration_notch_angle(3);
    
    if compression == 1 % overcompressed
        % drive_end = notch_mid - notch_width/2
        notch_pos = calibration_notch_position(1) + calibration_notch_position(2)*(drive_center + drive_width/2 + width/2) + calibration_notch_position_angle_contribution * (notch_angle - calibration_notch_angle(3));
        left_jaw_pos = calibration_left_jaw(1) + calibration_left_jaw(2)*(drive_center - drive_width/2);
        right_jaw_pos = calibration_right_jaw(1) + calibration_right_jaw(2)*(witness_center + witness_width/2);
    elseif compression == -1 % overcompressed
        notch_pos = calibration_notch_position(1) + calibration_notch_position(2)*(drive_center - drive_width/2 - width/2) + calibration_notch_position_angle_contribution * (notch_angle - calibration_notch_angle(3));
        left_jaw_pos = calibration_left_jaw(1) + calibration_left_jaw(2)*(witness_center - witness_width/2);
        right_jaw_pos = calibration_right_jaw(1) + calibration_right_jaw(2)*(drive_center + drive_width/2);
    end
end