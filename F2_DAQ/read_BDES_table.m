function [BDES_list] = read_BDES_table()
%Read BDES values from table for waist scan 

fileID = fopen('/usr/local/facet/tools/matlabTNG/F2_gitIgnore/waist_BDES_values.txt','r');
formatSpec = '%f %f %f %f %f %f %f %f %f';
sizeA = [9 Inf];
BDES_list = fscanf(fileID,formatSpec,sizeA)';
end
