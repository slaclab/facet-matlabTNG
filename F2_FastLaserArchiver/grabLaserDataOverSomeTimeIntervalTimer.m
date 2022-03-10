function oneHourData = grabLaserDataOverSomeTimeIntervalTimer(mTimer,~)
UserData = mTimer.UserData;

tCurrent = now;
tFinish = addtodate(tCurrent, UserData.TimeInterval,'second');
osctiming1 = 'OSC:LT10:20:FREQ_CUR';
osctiming2 = 'OSC:LT10:20:FREQ_MOTOR_POS';
n=1;
nShots = 5e3;
% Initialize arrays
beamImageData = zeros(nShots,length(UserData.camerapvs),10);
lRoomTemp = zeros(nShots,length(UserData.camerapvs));
tStamp = zeros(nShots,1);
%img1 = zeros(nShots,960,1280);
%img2 = zeros(nShots,734,1280);
%img3 = zeros(nShots,960,1280);
%img4 = zeros(nShots,734,1280);
disp(['Taking Laser Data for ',num2str(UserData.TimeInterval/60^2,'%.2f'),' hrs'])
normalCounts = [167.5,69.5,47.41,57.3,6.93,8.1,0.2674];
while tCurrent < tFinish

    for jj=1:length(UserData.camerapvs)% Only the IR cams for now
         [beamImageData(n,jj,:),img]=GrabLaserBeamPropertiesV4(UserData,jj);
         lRoomTemp(n,jj) = grabLaserRoomTemp(UserData,jj);
%          if n>1 && beamImageData(n,jj,5)>normalCounts(jj)*1.04;
%          save(strcat(UserData.camerapvs{jj},'_',datestr(now,'HH:MM:SS')),'img');
%          return
%          end
         
%{         
         switch jj
	 
	 case 1
	 img1(n,:,:) = img;
	 case 2
	 img2(n,:,:) = img;
	 case 3
	 img3(n,:,:) = img;
	 case 4
	 img4(n,:,:) = img;
	 end
         % disp(['Getting data for',UserData.camerapvs{jj}])
%}
    end

%lRoomTemp(n) = lcaGetSmart(UserData.pv_lroom_temp);
tStamp(n) = now;
tCurrent = now;
n=n+1;
end

disp('Finished taking data')
oneHourData.beamImageData = beamImageData;
oneHourData.lRoomTemp = lRoomTemp;
oneHourData.tStamp = tStamp;
%oneHourData.img1 = img1;
%oneHourData.img2 = img2;
%oneHourData.img3 = img3;
%oneHourData.img4 = img4;

filename = strcat('oneHourData',datestr(now,'mm-dd_HH_MM'));
save(filename,'oneHourData');
dos('mv oneHourData*.mat oneHourDatasets');
assignin('base','filename',['oneHourDatasets/',filename,'.mat']);
% Run the gui and print to logbook
run('laserStatusTableGUI.m');
figs = findall(0,'type','figure');
print(figs(1),'-dpsc2',['-P' 'physics-facetlog']);%No table print
print(figs(2),'-dpsc2',['-P' 'physics-facetlog'],'-bestfit');
close all force
clearvars figs 
