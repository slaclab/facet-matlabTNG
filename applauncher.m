function applauncher(portno)
%APPLAUNCHER Matlab GUI application launcher server
%applauncher(portno)
% portno (char) = UDP port number to use with server (passed by applauncher.sh)

addpath comms

% List of status PVs to keep up-to-date
host=upper(string(getenv('HOSTNAME')));
context = PV.Initialize(PVtype.EPICS) ;
pvlist = [PV(context,'name',"Stat1",'pvname',"F2:MATLABSERVER:STAT1:"+host);
  PV(context,'name',"Stat2",'pvname',"F2:MATLABSERVER:STAT2:"+host);
  PV(context,'name',"Stat3",'pvname',"F2:MATLABSERVER:STAT3:"+host) ] ;
pset(pvlist,'debug',0) ;
pvs = struct(pvlist) ;

% Retrieve port number to communicate on
portno=str2double(portno);

% Get window ID
[~,wIDtxt] = system(sprintf('wmctrl -lG | grep "(%s)"',portno)) ;
wID=regexp(wIDtxt,'^\S+','match','once');

% List of apps which need Live Model
LLM_apps = ["F2_LEM" "F2_LiveModel" "F2_Matching" "F2_MultiWire" "F2_Orbit" "F2_Wirescan" "F2_OrbitBump" "F2_IPJitter"] ;

% generate instance of LiveModel
disp('Generating instance of LiveModel...');
try
  LLM = F2_LiveModelApp ; %#ok<NASGU>
catch
  fprintf(2,'Failed to launch live model, retrying...\n');
  try
    LLM = F2_LiveModelApp ; %#ok<NASGU>
  catch
    fprintf(2,'Failed to launch live model again, exiting...\n');
    exit;
  end
end

% Open UDP port server and wait for client connection
fprintf('Matlab Application Launcher Listening on Port %d...',portno);

% Wait for valid app launch command and launch
addpath common
addpath web
while 1
  try
    caput(pvs.Stat1,'RUNNING'); caput(pvs.Stat2,'RUNNING'); caput(pvs.Stat3,'RUNNING');
    app=string(applauncher_server(portno));
    wID_des=regexp(app,"^\S+\s+(\d+)",'tokens','once');
    app = regexprep(app,'^(\S+).*','$1');
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
      system(sprintf('./applauncher.sh %d',portno)); % Launch new applauncher to replace this one
      % Changle to calling workspace
      system(sprintf('wmctrl -i -r %s -t %s',wID,wID_des));
      % Change to required location + geometry
%       system(sprintf('wmctrl -r %s -e "1,%s,%s,%s,%s"',wID,xpos,ypos,wid,ht));
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
  catch ME
    fprintf(2,'applaunchner server error: %s',ME.message);
  end
end