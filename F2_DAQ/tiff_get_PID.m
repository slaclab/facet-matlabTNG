function pulseID=tiff_get_PID(filename,offset)
% This function tiff_read_PID extracts pulse ID from image
%
% 	pulseID = tiff_get_PID( Filename,offset )
%
% inputs,
%   Filename : filename of a Tif/Tiff file
%   offset : position of PID tag in file
%
% ouputs,
%   pulseID : pulse ID

fid = fopen(filename,'r','l');
fseek(fid,offset,'bof');
pulseID = fread(fid,1,'uint32=>uint32');
fclose(fid);