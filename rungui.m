function rungui(appname,splashid)
%RUNAPP Run FACET-II application from Matlab environment

if ~nargin || ~exist(appname,'dir')
  error('No provided app name or app doesn''t exist');
end

addpath common
addpath web
cd(appname);
appobj=eval([appname '_exported']);
% appobj=eval(appname);
% Kill splash screen loader message if still there
if exist('splashid','var') && ~isempty(splashid)
  [stat,~]=system(sprintf('ps %s',splashid));
  if stat==0
    system(sprintf('kill %s',splashid));
  end
end
waitfor(appobj)
exit
