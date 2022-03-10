function saveLaserHealthReport(UserData,nCamera)
%Camera Name
CameraName = UserData.camerapvs{nCamera};
% Find out the date of the last datapoint
dataforMatlab = lcaGetSmart(UserData.matlabPvs{nCamera}); 
idx = dataforMatlab~=0;
dataR = reshape(dataforMatlab(idx),UserData.nDataPointsPerShot,length(dataforMatlab(idx))/UserData.nDataPointsPerShot);
t = dataR(end-1,:)+dataR(end,:); 
% Health Report name
filename = strcat('HealthReport_',CameraName,'_',...
		  datestr(t(end-1),'yyyy_mm_dd'));

% Get the data from laser monitoring PV
dataStruct.pvData = lcaGetSmart(UserData.matlabPvs{nCamera});
% Add info about which camera was saved and some acquisition options
dataStruct.Info = UserData;
dataStruct.Info.camerapvs = dataStruct.Info.camerapvs{nCamera};
dataStruct.Info.matlabPvs = dataStruct.Info.matlabPvs{nCamera};
dataStruct.Info.umPerPixel = dataStruct.Info.umPerPixel(nCamera);

disp(strcat('Saving Health Report for ',CameraName));
save(char(filename),'dataStruct');   
pth = ['/u1/facet/matlab/data/',datestr(t(end-1),'yyyy'),'/',datestr(t(end-1),'yyyy-mm'),'/'];
  if ~exist(pth);dos(['mkdir ',pth]);end 
  pth = ['/u1/facet/matlab/data/',datestr(t(end-1),'yyyy'),'/',datestr(t(end-1),'yyyy-mm'),'/',datestr(t(end-1),'yyyy-mm-dd'),'/'];
  if ~exist(pth);dos(['mkdir ',pth]);end
dos(['mv ',filename,'.mat ',pth]);
%dos(['mv ',filename,'.mat S10LaserHealthReports'])
