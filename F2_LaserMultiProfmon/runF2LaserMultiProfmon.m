function appobj = runF2LaserMultiProfmon(whichLaser)
%RUNAPP Run FACET-II application from Matlab environment
appname = 'F2_LaserMultiProfmon';

if ~nargin || ~exist(appname,'dir')
  error('No provided app name or app doesn''t exist');
end
%addpath common
%addpath web
%cd(appname);

switch whichLaser
    
    case 'S10'
        cameraPVs={'CAMR:LT10:500','CAMR:LT10:600','CAMR:LT10:700',...
     'CAMR:LT10:800','CAMR:LT10:200','CAMR:LT10:380','CAMR:LT10:900',...
     'CTHD:IN10:111'};
 
    case 'S20LaserRoom'
        cameraPVs = {'CAMR:LT20:100','CAMR:LT20:101','CAMR:LT20:102',...
    'CAMR:LT20:103','CAMR:LT20:104','CAMR:LT20:105',...
    'CAMR:LT20:106','CAMR:LT20:107'};

    case 'S20LaserTransport'
        cameraPVs = {'CAMR:LT20:200','CAMR:LT20:201','CAMR:LT20:202',...
            'CAMR:LT20:203','CAMR:LT20:204','CAMR:LT20:205',...
    'CAMR:LT20:206','CAMR:LT20:207','CAMR:LT20:208'};

end

assignin('base','cameraPVs',cameraPVs);
    
appobj=eval([appname,'_exported']);
