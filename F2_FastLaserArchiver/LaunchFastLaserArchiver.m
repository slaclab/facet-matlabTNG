% This script measures S10 laser data as fast as possible for arbitrary
% time intervals (will do 1hr every day at 8AM and 8PM)
% C Emma - Feb 2020
UserData.camerapvs = {'CAMR:LT10:500','CAMR:LT10:600','CAMR:LT10:800',...
    'CAMR:LT10:700','CAMR:LT10:200','CAMR:LT10:380','CAMR:LT10:900'};
UserData.pv_lroom_temp = 'LASR:LR10:1:TABLETEMP1';
UserData.pauseTime = 11*60^2;       % Pause time between taking data [s]
UserData.fitMethod = 2;             % See beamAnalysis_beamParams.m
%UserData.StartDelay = 9.25*60^2;    % Delay between running script and first time data is taken
UserData.umPerPixel = ones(1,length(UserData.camerapvs)); % Units of Pixels
UserData.TimeInterval = 1*60^2;     % How long to take data for between evaluations
% Delay between starting script and running loop for the first time
if hour(now)<19 && hour(now)>6
    UserData.StartDelay = (19-hour(now))*60^2-minute(now)*60;
elseif hour(now)>19 && hour(now)<24
    UserData.StartDelay = (24-hour(now)+7)*60^2-minute(now)*60;
else
    UserData.StartDelay = (7-hour(now))*60^2-minute(now)*60;
end
%%%%%%%%%%%%%%%%%%% NO USER INPUT BELOW THIS LINE %%%%%%%%%%%%%%%%%%%%%%%%%
%% Start the laser timer 
 oneHourlaserTimerObj = timer;
 set(oneHourlaserTimerObj,'UserData',UserData,'StartDelay',UserData.StartDelay);
 set(oneHourlaserTimerObj,'Period',UserData.pauseTime,'ExecutionMode','fixedSpacing');
 set(oneHourlaserTimerObj,'TimerFcn',@grabLaserDataOverSomeTimeIntervalTimer);
 start(oneHourlaserTimerObj);
