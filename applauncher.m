function applauncher()
%APPLAUNCHER Matlab GUI application launcher server

% List of apps which need Live Model
LLM_apps = ["F2_LEM" "F2_LiveModel" "F2_Matching" "F2_MultiWire" "F2_Orbit" "F2_Wirescan"] ;

% Shutdown any open server on this host, all future client requests come to this new one
!./applauncher_client SHUTDOWN

% generate instance of LiveModel
disp('Generating instance of LiveModel...');
LLM = F2_LiveModelApp ; %#ok<NASGU>

% Open UDP port server and wait for client connection
fprintf('Matlab Application Launcher Listening on Port 49151...');

% Wait for valid app launch command and launch
addpath common
addpath web
while 1
  app=string(applauncher_server);
  if string(app)=="SHUTDOWN"
    fprintf(2,'Shutdown requested, exiting...\n');
    exit
  end
  if ~exist(app,'dir')
    fprintf(2,'Unknown app: %s\n',app);
  else
    % Launch new app launcher instance and then launch requested GUI app
    fprintf('Launching app %s...\n',app);
    system(sprintf('echo -ne "\033]0;"%s"\007"',app)) ; % change xterm title
    system('./applauncher.sh');
    cd(app);
    if ismember(string(app),LLM_apps) % supply LiveModel object to app if supported
      appobj=eval(app+"_exported(LLM)");
    else
      appobj=eval(app+"_exported");
    end
    waitfor(appobj)
    exit
  end
end