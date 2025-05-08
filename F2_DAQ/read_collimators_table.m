function [BDES_list] = read_collimators_table()
%Read BDES values from table for waist scan 

fileID = fopen('/usr/local/facet/tools/matlabTNG/F2_gitIgnore/collimators_text_scan.txt','r');
formatSpec = '%f %f %f';
sizeA = [3 Inf];
BDES_list = fscanf(fileID,formatSpec,sizeA)';
end
