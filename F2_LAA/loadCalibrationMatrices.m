function calibrationMatrices = loadCalibrationMatrices()
%LOADCALIBRATIONMATRICES Summary of this function goes here
% Load the calibration matrices
    calibrationMatrices{1} = importdata('/home/fphysics/cemma/S20Laser/S20LaserAlignmentFeedback/PulsePickerFeedbackTest_082021/cal_matrix_S20PulsePicker08_10_2021_13_51.mat');
    calibrationMatrices{2} = importdata('/home/fphysics/cemma/S20Laser/S20LaserAlignmentFeedback/PreampFeedbackTest_062021/cal_matrix_S20Preamp08_02_2021_11_57.mat');
    calibrationMatrices{3} = importdata('/home/fphysics/cemma/S20Laser/S20LaserAlignmentFeedback/cal_matrix_S20TransportMPANearAndFar12_09_2021_15_01.mat');
    calibrationMatrices{4} = -1.0*importdata('/home/fphysics/cemma/S20Laser/S20LaserAlignmentFeedback/S20HeNeFeedbackTest_062021/cal_matrix_S20HeNe06_10_2021_13_10.mat');
    calibrationMatrices{5} = 1.0*importdata('/home/fphysics/cemma/S20Laser/S20LaserAlignmentFeedback/S20TransportFeedbackTest_082021/cal_matrix_S20TransportB0B109_22_2021_10_42.mat');
    calibrationMatrices{6} = importdata('/home/fphysics/cemma/S20Laser/S20LaserAlignmentFeedback/S20TransportFeedbackTest_082021/cal_matrix_S20TransportB2B309_17_2021_12_58.mat');
    calibrationMatrices{7} = importdata('/home/fphysics/cemma/S20Laser/S20LaserAlignmentFeedback/S20TransportFeedbackTest_082021/cal_matrix_S20TransportB409_24_2021_14_16.mat');
    calibrationMatrices{7}(2,1) = -1.0*calibrationMatrices{6}(2,1);% B4 vertical is the wrong sign

    calibrationMatrices{8} = importdata('/home/fphysics/cemma/S20Laser/S20LaserAlignmentFeedback/S20TransportFeedbackTest_082021/cal_matrix_S20TransportB509_24_2021_14_07.mat');
    %calibrationMatrices{8} =
    %importdata('/home/fphysics/cemma/S20Laser/S20LaserAlignmentFeedback/S20TransportFeedbackTest_082021/cal_matrix_S20TransportB609_24_2021_14_38.mat');%No
    %vertical calibration on this matrix
    
    calibrationMatrices{9} = importdata('/home/fphysics/cemma/S20Laser/S20LaserAlignmentFeedback/S20TransportFeedbackTest_082021/cal_matrix_S20TransportB611_02_2021_14_37.mat');
    calibrationMatricesIR = importdata('/home/fphysics/cemma/S20Laser/S20LaserAlignmentFeedback/cal_matrix_S20TransportB0B1IR11_30_2021_18_22.mat');%This is IR
end

