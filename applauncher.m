function u=applauncher()
%APPLAUNCHER Matlab GUI application launcher for use with mfacethome

% Get port number to use from file directory and increment
portno=49151;
d=dir('.');
for ifile=1:length(d)
  t=regexp(d(ifile).name,'applauncherPort_(\d+)','tokens','once');
  if ~isempty(t)
    portno=str2double(t{1})+1;
  end
end
delete('applauncherPort_*');
portno=portno+1;
if portno>65535
  portno=49152;
end
fid=fopen(sprintf('applauncherPort_%d',portno),'w'); fclose(fid);

% Open UDP port
u=udpport('LocalPort',portno) ;

% Wait for valid app launch command and launch
addpath common
addpath web
while 1
  if u.NumBytesAvailable>0
    app = char(read(u,u.NumBytesAvailable));
    if string(app)=="exit"
      exit
    end
    if ~exist(app,'dir')
      fprintf(2,'Unknown app: %s\n',app);
    else
      % Launch new app launcher instance and then launch requested GUI app
      system('./applauncher.sh');
      cd(app);
      try
        appobj=eval([app '_exported']);
        waitfor(appobj)
      catch
        exit
      end
      exit
    end
  end
  pause(1)
end