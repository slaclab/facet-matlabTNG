function [BDES_list] = read_BDES_table()
%Read BDES values from table for waist scan 
cd '/home/fphysics/amth10/git_work/matlabTNG/F2_DAQ/'
fileID = fopen('waist_BDES_values.txt','r');
formatSpec = '%f %f %f %f %f %f %f %f %f';
sizeA = [9 Inf];
BDES_list = fscanf(fileID,formatSpec,sizeA)';
end