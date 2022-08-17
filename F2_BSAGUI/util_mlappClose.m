function util_mlappClose(app)
%  Rewrite of util_appClose function, used for closing apps in App Designer
%  instead of Guide

%  util_mlappClose(app) is called from an App Designer GUI close request function to delete
%  the figure object and to exit matlab if the GUI is run in the production
%  environment and no other GUIs are running in the same matlab process.

% Features: 

% Input arguments:
%    App: Handle of the figure

% Output arguments: none

% Compatibility: Version 7 and higher

% Author: Henrik Loos, SLAC refurnished for App Designer by Jake Rudolph

% --------------------------------------------------------------------
% Get file name of GUI program instance.
if ishandle(app.UIFigure)
    file=mfilename('fullpath');
    [~,file]=fileparts(file);
    % Delete GUI.
    delete(app);
else
    file=dbstack; % Find caller
    file=file(end).name;
end

if length(findall(groot))==1
[~,filePath] = system(['readlink -fn ' fileparts(which(file))]); % Remove symlinks
filePath = strrep(filePath,'beta','toolbox');
[~,startupPath] = system(['readlink -fn ' fileparts(which('startup'))]); % Remove symlinks
startupPath = strrep(startupPath,'beta','toolbox');
if ~isempty(strfind(filePath,startupPath)) && ~epicsSimul_status
    lcaClear; % Disconnect from Channel Access
    exit
else
    % don't exit from matlab
end

end
