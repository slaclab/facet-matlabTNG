function laserTimerStart(mTimer,~)
UserData = mTimer.UserData;
% Check that the number of cameras is the same as the num of Matlab PVs 
if length(UserData.camerapvs) ~= length(UserData.matlabPvs)
    error(['The number of cameras is not equal to the number of Matlab',...
        'pvs - assign one PV to each camera to save laser data']);
elseif length(UserData.camerapvs) ~= length(UserData.umPerPixel)
    error('The number of cameras is not equal to the number of um/pixel',...
        'calibration values - assign one value to each camera ');
end

% If all that checks out start taking data
str1 = 'Starting Laser Watchdog';disp(str1)
str2 = strcat('You will be monitoring the S10 laser health status every ',{' '},...
    num2str(round(UserData.pauseTime/60)),' ',' minutes'); disp(str2)

% Now check that the Matlab array PVs aren't full - if so zero them
%{
    for n=1:length(UserData.camerapvs)
    % Find the first MatlabArray with zero element
        matlabPvData = lcaGetSmart(UserData.matlabPvs{n});
        zeroVals = find(matlabPvData==0);
    % Check that the array is not full - if so save data to file and refill
        if (length(matlabPvData)-zeroVals(1))<UserData.nDataPointsPerShot
            saveLaserHealthReport(UserData,n);
            lcaPutSmart(UserData.matlabPvs{n},zeros(length(matlabPvData,1)));
        end
    end
  %}   
end