function appobj = runapp(appname)
%RUNAPP Run FACET-II application from Matlab environment

if ~nargin || ~exist(appname,'dir')
  error('No provided app name or app doesn''t exist');
end

cd(appname);
appobj=eval([appname 'App']);

