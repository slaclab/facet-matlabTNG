% This script tracks the drift of the laser in S10 or  S20 by recording 
% multiple figures of merit that determine beam quality over time
% C Emma - Jan 2021
pvSect = 'CAMR:LT10:'; arrayPV = 'SIOC:SYS1:ML00:FWF';
UserData.camerapvs = {[pvSect,'500'],[pvSect,'600'],[pvSect,'800'],...
    [pvSect,'700'],[pvSect,'200'],[pvSect,'380'],[pvSect,'450'],[pvSect,'900']};
UserData.matlabPvs ={[arrayPV,'05'],[arrayPV,'06'],[arrayPV,'03'],...
		     [arrayPV,'07'],[arrayPV,'04'],[arrayPV,'08'],[arrayPV,'01'],[arrayPV,'02']};
UserData.pv_lroom_temp = 'LASR:LR10:1:TABLETEMP1';
UserData.nshotsForAverage = 3;      % Find the average beam properties over nshots
UserData.nDataPointsPerShot = 13;   % How many data points u save each shot
UserData.nLaserParamsPerShot = 10;  % How laser parameters u save each shot
UserData.pauseTime = 120;           % Pause time between taking data [s]
UserData.fitMethod = 2;             % See beamAnalysis_beamParams.m
UserData.smoothingSigma = 5;        % In units of pixels on camera
%UserData.umPerPixel = [3.75,4.08,3.75,4.08,9.9,9.9,9.9,4.65];     % From Manta g-125,G-095,G-125,g-095,g-033b,g-033b spec sheets
UserData.umPerPixel = ones(1,length(UserData.camerapvs));% All vals in units of pixels
%%%%%%%%%%%%%%%%%%% NO USER INPUT BELOW THIS LINE %%%%%%%%%%%%%%%%%%%%%%%%%
%% Start the laser Watchdog
 laserTimerObj = timer;
 set(laserTimerObj,'UserData',UserData,'StartFcn',@laserTimerStart,...
     'Period',UserData.pauseTime,'TimerFcn',@takeLaserTimerData,...
     'StopFcn',@laserTimerCleanup,'ExecutionMode','fixedSpacing');
 start(laserTimerObj);
