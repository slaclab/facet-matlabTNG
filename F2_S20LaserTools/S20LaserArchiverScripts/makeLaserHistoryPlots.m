    function makeLaserHistoryPlots(camerasSelected,startTimeStamp,endTimeStamp)
camerapvs = {'CAMR:LT10:500','CAMR:LT10:600','CAMR:LT10:700','CAMR:LT10:200','CAMR:LT10:380'};
matlabPvs ={'SIOC:SYS1:ML00:FWF05','SIOC:SYS1:ML00:FWF06','SIOC:SYS1:ML00:FWF07','SIOC:SYS1:ML00:FWF08','SIOC:SYS1:ML00:FWF04'};
triggerPvs = {'EVNT:SYS1:1:FIDUCIALRATE'}; 
nDataPointsPerShot = 13;
t1 = startTimeStamp;    t2 = datenum(endTimeStamp);
plotGivenTimeInterval = 0;
%%%%%%%%%%%%%%%%%% USER INPUT ABOVE THIS LINE %%%%%%%%%%%%%%%%%%%%%%%
for n=1:length(camerasSelected)
    clearvars t data
    rawdata = lcaGetSmart(matlabPvs{camerasSelected(n)});    
    save(camerapvs{camerasSelected(n)},'rawdata')
    idx = rawdata~=0;
    try
         dataR = reshape(rawdata(idx),nDataPointsPerShot,length(rawdata(idx))/nDataPointsPerShot);
         data = dataR;
    catch
        warning(strcat('Data cannot be resized into integer number of shots on ',camerapvs{camerasSelected(n)}))
    %Now cut out all shots with infinities before reshaping
    find(isinf(rawdata(idx)))% This tells you shots with any infinity
    idxx = rawdata(idx)>7e5;
    figure;
    plot(diff(find(idxx)));% If shots aren't separated by nDataPointsPerShot then something's wrong
    xlabel('Shot number');ylabel('Shot Data Size')
    title(camerapvs{n})
    shotDataSize = diff(find(idxx));
    goodShots = shotDataSize == nDataPointsPerShot;
    for i=1:length(goodShots)
        if goodShots(i)
            i0 = sum(shotDataSize(1:i-1));
        data(:,i) = rawdata(1+(i-1)*nDataPointsPerShot:i*nDataPointsPerShot);
        end
    end
    return
    end
    
    % Find the timestamp closest to your time interval
    tRaw = dataR(end-1,:)+dataR(end,:);
    idxt = tRaw > t1 & tRaw < t2;
    data = dataR(:,idxt);
    t = data(end-1,:)+data(end,:);
    timeTicks = linspace(t(1),t(end),4);

figure(n);set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.2, 0.1, 0.7, 0.8]);
hAx(1) = subplot(2,3,1);
    plot(t,data(1,:)-data(1,1));  hold on; plot(t,data(2,:)-data(2,1),'r')
    ylabel('Beam Centroid Motion [um]')
    legend('x','y')    
    grid on

hAx(2) = subplot(2,3,2);
    plot(t,data(3,:));      hold on;     plot(t,data(4,:),'r'); grid on
    ylabel('Rms spot size [um]')        
%    title(strcat(lcaGetSmart(strcat(matlabPvs{n},'.DESC'))),'FontSize',16)

hAx(3) =subplot(2,3,3);
    plot(t,data(5,:));  ylabel('Sum Counts [Mcts]'); grid on    
    
hAx(4) =subplot(2,3,4);
    plot(t,data(6,:));    ylabel('Tilt [deg]')    ; grid on
    
hAx(5) =subplot(2,3,5);
    plot(t,data(7,:),'k'); hold on ;plot(t,data(8,:),'m')  ; grid on      
    ylabel('Eccentricity, R^2')
    legend('\epsilon','R^2')                

hAx(6) = subplot(2,3,6);
    plot(t,data(10,:),'g'); ylabel('P2P Intensity  Var. [%]')   ;grid on
% Set common plot properties    
    set(hAx,'XTick',timeTicks,'FontName','Times')
    set(hAx,'XTickLabel',cellstr(datestr(timeTicks,'mm/dd HH:MM')),'FontSize',12)
    set(hAx,'xlim',[t(1),t(end)])
    XLabelHC = get(hAx, 'XLabel');
    XLabelH  = [XLabelHC{:}];
    set(XLabelH, 'String', 'Time')
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
