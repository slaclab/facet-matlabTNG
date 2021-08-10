function matlab2hdf5(data_structure,file_name)

file_name = [file_name '.h5'];

% First get structure of file to write
path_list = get_path(data_structure,{},'');

% Next, iterate through structure
for i = 1:numel(path_list)
    
    % Get data items
    fields = strsplit(path_list{i},'/');
    item = data_structure;
    for j = 2:numel(fields)
        item = item.(fields{j});
    end
    
    % check type and make adjustments
    [item, data_type, data_size] = type_check(item);
        
    % Create and write to file
    h5create(file_name,['/data' path_list{i}],data_size,'Datatype',data_type);
    h5write(file_name,['/data' path_list{i}],item);
    
    
end

% Check datatypes and make adjustments
function [item, data_type, data_size] = type_check(item)

if isempty(item)
    item = 0;
    data_size = size(item);
    data_type = class(item);
    return;
end
    
data_type = class(item);

switch data_type
    case 'double'
        data_size = size(item);
    case 'single'
        data_size = size(item);
    case 'uint16'
        data_size = size(item);
    case 'char'
        item = string(item);
        data_type = class(item);
        data_size = size(item);
    case 'logical'
        item = int16(item);
        data_type = class(item);
        data_size = size(item);
    case 'cell'
        if ischar(item{1})
            item = string(item);
            data_type = class(item);
            data_size = size(item);
        else
            error('Failed here');
        end
    otherwise
        error('Error: cannot interp type. Abort file write.');
end


% This is a recursive function that finds the shape of the matlab structure
function path_list = get_path(structure,path_list,path)

f = fieldnames(structure);

for i = 1:numel(f)
    
    current_path = [path '/' f{i}];
    
    if isstruct(structure.(f{i}))
        
        path_list = get_path(structure.(f{i}),path_list,current_path);
        
    else
        
        path_list = [path_list; current_path];
        
    end
end