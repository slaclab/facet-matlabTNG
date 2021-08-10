function save_info = set_DAQ_filepath(obj)
% prepare save path

% Get info for creating save directory
n_saves = obj.Instance;
save_info.instance = n_saves;

experiment = obj.params.experiment;
save_info.experiment = experiment;

num_CAM = obj.params.num_CAM;
camNames = obj.params.camNames;

time = clock;
year = num2str(time(1));
month = num2str(time(2),'%02d');
day = num2str(time(3),'%02d');


% Add timestamp info to struct
save_info.local_time = time;
save_info.matlab_timestamp = now;
[~,unix_ts] = system('date +%s');
save_info.unix_timestamp = str2num(unix_ts);

% This will only work from facet-srv20
header = '/nas/nas-li20-pm00/';
save_info.header = header;

% Create top directory for DAQ instance
save_info.save_path = [header experiment '/' year '/' year month day '/' ...
    experiment '_' num2str(n_saves,'%05d')];
if(~exist(save_info.save_path, 'dir')); mkdir(save_info.save_path); end
system(['chmod a+w ' save_info.save_path]);

% Create sub directory for each camera
save_info.cam_paths = cell(size(camNames));
for i=1:num_CAM
    save_info.cam_paths{i} = [save_info.save_path '/images/' camNames{i}];
    if(~exist(save_info.cam_paths{i}, 'dir')); mkdir(save_info.cam_paths{i}); end
    system(['chmod a+w ' save_info.cam_paths{i}]);
end