%% getDataSet(dataSetID)
function [data_struct, header] = getDataSet(dataSetID,exp)

    dataSetID = sprintf('%05d',dataSetID);
    
    
    %% Check if already looked up:
    storagePath = 'pathStorage.mat';
    fieldName = sprintf('%s%s','field',dataSetID);
    paths = struct;
    
    if exist(storagePath,'file')
        load(storagePath);
        
        if isfield(paths,fieldName)
            dataSetInfo = paths.(fieldName);
            if exist(dataSetInfo.path, 'file')
                load(dataSetInfo.path);
%                data = data.raw;
                header = dataSetInfo.header;
                return
            end
        end
    end

    
    %% Search for dataset
    % find ~ -name "*21190" 2>/dev/null
    
    if isunix 
        if ismac %% assumes running from Henrik's machine
            searchPath = '/Users/henrik01/FACETData';
        else %% assumes running from facet-srv20
            if nargin == 1
                searchPath = '/nas/nas-li20-pm00/';
            elseif nargin == 2
                searchPath = ['/nas/nas-li20-pm00/',exp,'/'];
            end
        end
%        [~, outp] = unix(sprintf( 'find %s -name "*%s" 2>/dev/null', searchPath, dataSetID ));
        [~, outp] = unix(sprintf( 'find %s -name "*%s" -maxdepth 3 2>/dev/null', searchPath, dataSetID ));

    else
        error('Currently not supported on your operating system')
    end

    if isempty(outp)
        error('In getDataSet.m: Could not find the dataSet');
        
    end
    lines = splitlines(outp);
    if length(lines) == 2
        path = lines{1};
    else 
        error('In getDataSet.m: Data set not unique');
    end
    
    %% Find .mat file
    %expr = 'E\d{3}_\d{5}$';
    expr = '[a-zA-Z0-9]{4}_\d{5}$';
    startIdx = regexp(path,expr);
    dsName = sprintf('%s%s',path(startIdx:end),'.mat');
    
    matfile = sprintf('%s/%s',path,dsName);
    if exist(matfile)
        load(matfile);
    else
        error('In getDataSet.m: Could not find the .mat file')
    end
    
    %% Find header (in case there is path previous to '/nas/nas-li20-pm00/')
    expr = '/nas/nas-li20-pm00/';
    idx = regexp(path,expr);
    if isempty(idx)
        error('In getDataSet.m: Something is wrong with the find header, idx is empty' )
    elseif length(idx) > 1
        error('In getDataSet.m: Something is wrong with the find header, idx gives multiple matches' )
    end
    if idx ~= 1 
        header = path(1:idx-1);
    else
        header = '';
    end
    
    %% Save to known data sets
    dataSetInfo.path = matfile;
    dataSetInfo.header = header;
    paths = setfield(paths,fieldName,dataSetInfo);
    
    save(storagePath, 'paths')
    
    %data = data.raw;

    
        
end