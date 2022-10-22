function humidity = GetSlacMapData(datatime,pvupload,doplot)
% humidity = GetSlacMapData()
%  returns relative humidity (%) for SLAC main campus location
%  data is 2 hours old and updated every 40 mins
% GetSlacMapData(datatime)
%  datatime is anything that datevec command will pass (must be < 9 days ago)
% GetSlacMapData(datatime,PV)
%  writes humidity to PV
%  put datatime=[] for latest data
% GetSlacMapData(PV,datatime,true)
%  Plot map of SLAC location humidity data captured for
%  Put [] for PV and/or datatime if not wanted

% Can ask for any date-time up to 9 days previously
if etime(datevec(now),datevec(datenum(datetime)))/(3600*24) > 9
  error('Requested date must be newer than 9 days ago')
end

ran=0.01;
slaclat = 37.41657 ; % SLAC S30 lat/long
slaclon = -122.204912 ;
latlim = slaclat + [-ran ran] ;
lonlim = slaclon + [-ran ran] ;
numberOfAttempts = 5;
attempt = 0;
info = [];
% Map data server
serverURL = 'http://basemap.nationalmap.gov/ArcGIS/services/USGSImageryOnly/MapServer/WMSServer?';
% Humidity data server
server_humid = 'https://disc1.gsfc.nasa.gov/daac-bin/wms_airsnrt?';
while(isempty(info))
    try
        info = wmsinfo(serverURL);
        info_humid = wmsinfo(server_humid);
        orthoLayer = info.Layer(1);
        humidLayer = info_humid.Layer(12);
    catch e 
        
        attempt = attempt + 1;
        if attempt > numberOfAttempts
            throw(e);
        else
            fprintf('Attempting to connect to server:\n"%s"\n', serverURL)
        end        
    end
end
imageLength = 1024;
[A,R] = wmsread(orthoLayer,'Latlim',latlim, ...
                           'Lonlim',lonlim, ...
                           'ImageHeight',imageLength, ...
                           'ImageWidth',imageLength);
if exist('datatime','var')
%   time = '2010-04-16T00:00:00Z';
  Ah = wmsread(humidLayer,'Latlim',latlim, 'Lonlim',lonlim,'Time',datenum(datatime));
else
  Ah = wmsread(humidLayer,'Latlim',latlim, 'Lonlim',lonlim);
end
if exist('doplot','var') && doplot
  figure
  geoshow(A,R);
end
humidity=mean(Ah(:));
fprintf('Relative Humidity= %g\n',humidity);
if exist('pvupload','var')
  lcaPut(pvupload,humidity);
end
