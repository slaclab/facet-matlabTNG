function laserTimerCleanup(mTimer,~)
disp('Stopping Laser Watchdog.')
delete(mTimer);
end
