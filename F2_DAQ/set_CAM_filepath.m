function set_CAM_filepath(obj)

num_cam = obj.params.num_CAM;

filePrefix = obj.params.camNames;
file_format = '%s%s_%4.4d.tif';
data_string = ['_data_step' sprintf('%02d',obj.step)];

% Set filepath format
ff = zeros(1,256);
formatASCII = double(file_format);
n_el = length(formatASCII);
ff(1:n_el) = formatASCII;
lcaPut(obj.daq_pvs.TIFF_FileTemplate, ff);

% Set filepath for saved data (path must already exist)
for i=1:numel(filePrefix)
    
    fp = zeros(1,256);
    %path = obj.save_info.(filePrefix{i});
    path = obj.save_info.cam_paths{i};

    pathASCII = double(path);
    n_el = length(pathASCII);
    fp(1:n_el) = pathASCII;
    lcaPut(obj.daq_pvs.TIFF_FilePath{i}, fp);
end

% Check that all paths exists
for i=1:num_cam
    ext = lcaGet(obj.daq_pvs.TIFF_FilePathExists_RBV(i));
    if (~strcmp(ext,'Yes'))
        obj.dispMessage('IOC cannot access image save path. NAS might be unmounted on IOC server.');
        error(['File path: ' path ' does not exist.']);
    end
end

% Set name for data images
for i=1:num_cam
    fn = zeros(1,256);
    filename = [filePrefix{i}, data_string];
    fileASCII = double(filename);
    n_el = length(fileASCII);
    fn(1:n_el) = fileASCII;
    lcaPut(obj.daq_pvs.TIFF_FileName(i), fn);
    
end