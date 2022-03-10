function createLaserTimer(UserData)
t = timer;
t.UserData = UserData;

t.StopFcn = @laserTimerCleanup;
t.Period = t.UserData.pausetime;% in s
t.TasksToExecute = t.UserData.nTimeIntervals;
t.ExecutionMode = 'fixedSpacing';
end



