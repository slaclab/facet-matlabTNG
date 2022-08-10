function applauncher()
%APPLAUNCHER Matlab GUI application launcher server

% List of apps which need Live Model
LLM_apps = ["F2_LEM" "F2_LiveModel" "F2_Matching" "F2_MultiWire" "F2_Orbit" "F2_Wirescan"] ;

% Form user to use for client-server comms
username = string(getenv('USER'))+"_"+string(getenv('PHYSICS_USER')) ;

% Shutdown any open server on this host started by this user, all future client requests come to this new one
system(sprintf('./applauncher_client %s SHUTDOWN',username));

% generate instance of LiveModel
disp('Generating instance of LiveModel...');
% LLM = F2_LiveModelApp ; %#ok<NASGU>

% Open UDP port server and wait for client connection
fprintf('Matlab Application Launcher Listening on Port 49151...');

% Wait for valid app launch command and launch
addpath common
addpath web
while 1
  app=string(applauncher_server);
  server_user = regexprep(app,'\$\$\S+$','') ;
  if server_user ~= username
    fprintf(2,'Request comes from another user (%s), skipping...\n',server_user);
    continue
  end
  app = regexprep(app,'^\w+\$\$','') ;
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
    [~,splashid]=system(sprintf('./LaunchSplash.sh %s',app)); splashid=strip(splashid);
    cd(app);
    if ismember(string(app),LLM_apps) % supply LiveModel object to app if supported
      appobj=eval(app+"_exported(LLM)");
    else
      appobj=eval(app+"_exported");
    end
    % Kill splash screen loader message if still there
    if exist('splashid','var') && ~isempty(splashid)
      [stat,~]=system(sprintf('ps %s',splashid));
      if stat==0
        system(sprintf('kill %s',splashid));
      end
    end
    waitfor(appobj) % Wait for app to be closed by user
    exit
  end
end