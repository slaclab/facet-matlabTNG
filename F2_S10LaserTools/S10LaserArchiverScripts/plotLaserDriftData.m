camerapvs = {'CAMR:LT10:500','CAMR:LT10:600','CAMR:LT10:700','CAMR:LT10:200','CAMR:LT10:380'};
matlabPvs ={'SIOC:SYS1:ML00:FWF05','SIOC:SYS1:ML00:FWF06','SIOC:SYS1:ML00:FWF07','SIOC:SYS1:ML00:FWF08','SIOC:SYS1:ML00:FWF04'};
triggerPvs = {'EVNT:SYS1:1:FIDUCIALRATE'}; 
nDataPointsPerShot = 13;
StartDate = '03/13/2020 15:00:00';    EndDate = '03/14/2020 00:01:00';
t1 = datenum(StartDate);    t2 = datenum(EndDate);
plotGivenTimeInterval = 0;
camerasSelected = [1 2 3 4 5]
close all
%%%%%%%%%%%%%%%%%% USER INPUT ABOVE THIS LINE %%%%%%%%%%%%%%%%%%%%%%%
for n=1:length(camerasSelected)
makeLaserHistoryPlots(camerasSelected,t1,t2)

end

%% Plot some histograms
% idx = data(5,:) >100;
% figure;
% subplot(2,1,2)
% hist(data(5,idx)*mJperCounts(3))
% xlabel('Laser Energy [mJ]');ylabel('N');
% title('From 02/19 17:58 to 02/21/09:51')
% legend(strcat('Std [mJ]= ',' ',num2str(std(data(5,idx)*mJperCounts(3)),'%.2f')))
% subplot(2,1,1)
% plot(t(idx),data(5,idx)*mJperCounts(3))
% ylabel('Laser Energy [mJ]');
%     enhance_plot
%     set(gca,'XTick',timeTicks)
%     set(gca,'XTickLabel',cellstr(datestr(timeTicks,'mm/dd HH:MM')),'FontSize',12)
% 
% title('From 02/19 17:58 to 02/21/09:51')
% xlim([t(1),t(end)])


%% Find the std of each quantity
% for n=1:5
%     meanVals(n) = mean(data(n,:))
%     stdev(n) = std(data(n,:))
% end
