function makeOnehrDataPlots(oneHourData,nCams)
camNames = {'S10OscillatorOutput','S10RegenOutput','S10MPAOutput',...
    'S10CompressorOutput','S10UVConvOutput','S10UVIrisOutput','S10VCC'};

    t = oneHourData.tStamp;    idx = t~=0;    t = t(idx);
    alldata = oneHourData.beamImageData; alldata = alldata(idx,:,:);
    tempData = oneHourData.lRoomTemp;     tempData = tempData(idx);
    timeTicks = linspace(t(1),t(end),4);
    
    secondsPerShot = str2num(datestr(t(2)-t(1),'SS.FFF'));
    nshots15 = round(15*60/secondsPerShot);    
    nshots1hr = round(60*60/secondsPerShot);
    if nshots1hr>length(t);nshots1hr = length(t)-1;end
    if nshots15>length(t);nshots15 = length(t)-1;end
    
    energyLimits = [3,3,3,3];% This is for energy filtering
for n=1:nCams    
    data = squeeze(alldata(:,n,:));    
    data = permute(data,[2 1]);
         
    % Calculate energy jitter and moving average
    energyJitter = 100*(data(5,:)-mean(data(5,:)))./mean(data(5,:));  
    % Filter out the spikes if you want    
    
    movingAverageEnergy=movMeanCemma(energyJitter, round(60/secondsPerShot));
    % Calculate centroid jitter
    xcentroidJitter = 100*(data(1,:)-mean(data(1,:)))./data(3,:);
    ycentroidJitter = 100*(data(2,:)-mean(data(2,:)))./data(4,:);
    % Calculate moving average for p2p variation
    movingAveragep2p= movMeanCemma(data(10,:),round(60/secondsPerShot));    
%{    
figure(n);set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.2, 0.1, 0.75, 0.8]);
hAx(1) = subplot(2,3,1);
    plot(t,data(3,:));      hold on;     plot(t,data(4,:),'r'); grid on
    ylabel('Rms Spotsize [um]')        
    
hAx(2) = subplot(2,3,2);
    plot(t,xcentroidJitter);  hold on; plot(t,ycentroidJitter,'r')
    ylabel('Centroid jitter / RMS Spotsize [%]')
    legend('x','y')    
    grid on    
    title(camNames{n},'FontSize',20)
    
hAx(3) =subplot(2,3,3);
   p1 = plot(t,energyJitter);  ylabel('Energy Jitter [%]'); grid on    
   hold on
   p2 = plot(t,movingAverageEnergy,'k','LineWidth',2);
   legend([p2],{strcat('Moving avg 1 min')})
   
hAx(4) =subplot(2,3,4);
yyaxis left
    plot(t,data(6,:));    ylabel('Humidity [%]')    ; 
yyaxis right
    plot(t,tempData);    ylabel('Temperature [deg F]')    ; 
    
hAx(5) =subplot(2,3,5);
    plot(t,data(7,:),'k'); hold on ;plot(t,data(8,:),'m')  ; grid on      
    ylabel('Eccentricity, R^2')
    legend('\epsilon','R^2')                

hAx(6) = subplot(2,3,6);
   p1 = plot(t,data(10,:),'g'); ylabel('Uniformity [%]')   ;grid on
   hold on
   p2 = plot(t,movingAveragep2p,'k','LineWidth',2);
   legend([p2],{strcat('Moving avg 1 m')})
% Set common plot properties    
    set(hAx,'XTick',timeTicks,'FontName','Times','FontSize',14)
    set(hAx,'XTickLabel',cellstr(datestr(timeTicks,'mm/dd HH:MM')),'FontSize',12,'XTickLabelRotation',45)
    set(hAx,'xlim',[t(1),t(end)])
    XLabelHC = get(hAx, 'XLabel');
    XLabelH  = [XLabelHC{:}];
    set(XLabelH, 'String', 'Time');
%}
% Plot Energy Jitter histograms
%idE = energyJitter-mean(energyJitter)<energyLimits(n);
   [a,bins]=histcounts(energyJitter-mean(energyJitter),50);      
   hg = figure(112);hhAx(n) = subplot(1,7,n);histogram(energyJitter-mean(energyJitter));
        set(hhAx(n),'FontSize',6);title(camNames{n},'FontSize',6);xlabel('dE/E [%]','FontSize',8);ylabel('N shots','FontSize',8);
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.1, 0.7, 0.9, 0.4]);

%{
   legend(['E mean [mJ] = ',num2str(energyCalibration(handles,n,mean(data(5,:))))])
    [maxi,ind]= max(a);   
    figure(111);                   
         plot(bins(1:end-1)-bins(ind),a/max(a),'LineWidth',2);hold on;grid on;
         set(gca,'FontSize',18,'FontName','Times');
         xlabel('Relative Energy Jitter [%]');%ylabel('Fraction of shots');
         ylabel('N counts/max counts');
         titlestr = ['From ',datestr(t(1)),' to ',datestr(t(end))];
         title(titlestr)
         if n==nCams;legend(camNames,'FontSize',10);end
  %}      
% Save data to workspace
% assignin('base',camNames{n},data) 
end

function m=movMeanCemma(A,n)    
   if ~mod(n,2);warning('Even number of points for moving avg. Rounded to nearest odd');n=n+1;end 
% n must be an odd number
m=ones(1,length(A));
    for i=1:length(A)
        if i < 1+(n-1)/2
            m(i) = mean(A(1:i));
        elseif i > length(A)-(n-1)/2-1
            m(i) = mean(A(i-(n-1)/2:end));
        else            
            m(i) = mean(A(i-(n-1)/2:i+(n-1)/2));                                
        end
    end
end

end