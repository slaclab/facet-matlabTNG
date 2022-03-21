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
        cameraPVs={'CAMR:LT10:500','CAMR:LT10:600','CAMR:LT10:800',...
     'CAMR:LT10:700','CAMR:LT10:200','CAMR:LT10:380','CAMR:LT10:900'};
 
    case 'S20LaserRoom'
        cameraPVs = {'CAMR:LT20:0001','CAMR:LT20:0002','CAMR:LT20:0003',...
    'CAMR:LT20:0004','CAMR:LT20:0005','CAMR:LT20:0006',...
    'CAMR:LT20:0007','CAMR:LT20:0008'};

    case 'S20LaserTransport'
        cameraPVs = {'CAMR:LT20:0009','CAMR:LT20:0010','CAMR:LT20:0101',...
            'CAMR:LT20:0102','CAMR:LT20:0103','CAMR:LT20:0104',...
    'CAMR:LT20:0105','CAMR:LT20:0106','CAMR:LT20:0107'};

end

assignin('base','cameraPVs',cameraPVs);
    
appobj=eval([appname,'_exported']);
