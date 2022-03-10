rootPath = pwd;
cameraNames = {'CAMR:LT10:500','CAMR:LT10:600','CAMR:LT10:700','CAMR:LT10:200','CAMR:LT10:380'}
tic
for jj = 1:numel(cameraNames)
    filelist = dir(pwd);mfile = find(~cellfun(@isempty,regexp({filelist.name},cameraNames{jj})));
    files = {filelist(mfile).name};
    for ifile = 1:numel(files)-1;laserImages(ifile).img = importdata(files{ifile});laserImages(ifile).imgName = files{ifile};end
    
    dataStruct = importdata(files{end});% Load the health report
    dataStruct.laserImages = laserImages;% Add the laser images
    save(files{end},'dataStruct')
    dos(['rm CAMR:LT10:*.mat']);% Remove the old images
end
toc