function plotS10andS20LaserImagesAtSomeTime(handles,dateAndTime)
set(handles.text8,'String',' ');
rootPath = '/u1/facet/matlab/data/';
%%%%% THE ABOVE NEEDS TO BE MEASURED / CALIBRATED AGAINST THE CAMERAS %%%%
t1 = datenum(dateAndTime);
requestedHour = str2num(datestr(t1,'HH'));
disp(handles.cameraPVs)
hh = figure;
for jj=1:8      % S10 Cameras
    pth = [rootPath,datestr(t1,'yyyy'),'/',datestr(t1,'yyyy-mm'),'/',datestr(t1,'yyyy-mm-dd'),'/LaserArchiverImages/'];                                    
    filelist = dir(pth);                          
    mfile = find(~cellfun(@isempty,regexp({filelist.name},handles.cameraPVs{jj})));
    files = {filelist(mfile).name};   if isempty(files);disp('No data found');continue;end
    for ij = 1:length(mfile)-1;theHour(ij) = str2num(files{ij}(15:16));end% Get the hour of the image        
    [~,idx] = min(abs(requestedHour-theHour));    
    img = importdata([pth,files{idx}]);
    sumCounts = sum(sum(img))*1e-6;
    % Draw stuff          
    % Enlarge figure to full screen.
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.5, 0.8, 0.8]);
    subplot(2,4,jj);    
    imagesc([1:size(img,1)],[1:size(img,2)],img);colormap jetvar;
    xlabel('x [pix]');ylabel('y [pix]');  
    title(lcaGetSmart([handles.cameraPVs{jj},':NAME']),'FontSize',14); 
    set(gca,'FontName','Times','LineWidth',2);
    dim = [0.01 0.85 0.1 0.1];
    annotation('textbox',dim,'String',datestr(t1,'mm/dd/yyyy HH:MM'));
end
clearvars theHour files
hg = figure;
for jj=9:length(handles.cameraPVs)      % S20 Cameras
    pth = [rootPath,datestr(t1,'yyyy'),'/',datestr(t1,'yyyy-mm'),'/',datestr(t1,'yyyy-mm-dd'),'/LaserArchiverImages/'];                                    
    filelist = dir(pth);                          
    mfile = find(~cellfun(@isempty,regexp({filelist.name},handles.cameraPVs{jj})));
    files = {filelist(mfile).name};
    if length(mfile)<2;disp('No data found');continue;end    
    for ij = 1:length(mfile)-1;theHour(ij) = str2num(files{ij}(16:17));end% Get the hour of the image        
    [~,idx] = min(abs(requestedHour-theHour));    
    img = importdata([pth,files{idx}]);
    % Draw stuff Enlarge figure to full screen.
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.5, 0.8, 0.8]);
    subplot(3,6,jj-8);    
    imagesc([1:size(img,1)],[1:size(img,2)],img);colormap jetvar;
    xlabel('x [pix]');ylabel('y [pix]');  
    title(lcaGetSmart([handles.cameraPVs{jj},':NAME']),'FontSize',14); 
    set(gca,'FontName','Times','LineWidth',2)  
    dim = [0.8 0.05 0.1 0.1];
    annotation('textbox',dim,'String',datestr(t1,'mm/dd/yyyy HH:MM'));
end
