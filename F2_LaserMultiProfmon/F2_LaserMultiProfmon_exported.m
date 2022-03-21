classdef F2_LaserMultiProfmon_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure               matlab.ui.Figure
        UIAxes                 matlab.ui.control.UIAxes
        UIAxes_2               matlab.ui.control.UIAxes
        UIAxes_3               matlab.ui.control.UIAxes
        UIAxes_4               matlab.ui.control.UIAxes
        UIAxes_5               matlab.ui.control.UIAxes
        UIAxes_6               matlab.ui.control.UIAxes
        UIAxes_7               matlab.ui.control.UIAxes
        UIAxes_8               matlab.ui.control.UIAxes
        StartDisplayingButton  matlab.ui.control.Button
        PauseDisplayingButton  matlab.ui.control.Button
        PrinttoeLogButton      matlab.ui.control.Button
        ShowstatsButton        matlab.ui.control.Button
        AutoROICheckBox        matlab.ui.control.CheckBox
        UIAxes_9               matlab.ui.control.UIAxes
        ShowStripChartButton   matlab.ui.control.Button
    end

    
    properties (Access = private)
        plotBool = 1 ;% Bool for starting or stopping the plotting
        autoROI = 0;
        cameraPVs ;
        opts;% Fitting options
        AxesStorage;% Store all axes  
   
    end
    methods (Access = private)
        
                function results = jetvar(m)
                    if nargin < 1
                        m = size(get(gcf, 'colormap'), 1);
                    end
                out = jet(m);
                % Modify the output starting at 1 before where Jet outputs pure blue.
                n = find(out(:, 3) == 1, 1) - 1;
                out(1:n, 1:2) = repmat((n:-1:1)'/n, [1 2]);
                out(1:n, 3) = 1;
                end
                
                
                function launchLaserStripChart(app)
                addpath('/home/fphysics/cemma/S10Laser/S10LaserWatchdog')
                UserData.camerapvs = app.cameraPVs;
                UserData.pauseTime = 1e-4;             % Pause time between taking data [s]
                UserData.bufferSize = 7200/8;         % About 1 hr of time 
                UserData.fitMethod = 2;             % See beamAnalysis_beamParams.m
                UserData.umPerPixel = ones(length(UserData.camerapvs),1);% This gives everything in pixels
                UserData.smoothingSigma = 5; % in pixel units
                nCams = length(UserData.camerapvs);
                %%%%% The User needs to input nothing below this line %%%%%%%%%%%%%%%%%
                % Initialize arrays and initialize plot options
                plot_titles = {'','Centroid','RMS Spot Size','Sum Counts'};
                ylabels = {'','Val [pix]','Val [pix]',' Cts [10^6]'};
                plts = cell(10,2);
                hh1 = cell(10,1);
                % Grab beam data for a single shot
                k=1;
                timestamp(k) = now;
                % Loop over subplots and initialise plot lines
                h1 = figure;
                for jj = 1:nCams
                      [beamProps(jj,k,:),img]=GrabLaserBeamPropertiesV3(UserData,jj);  
                    % Decide if you want x and y axes in pixels on mm
                    X = ([1:size(img,2)]); Y = ([1:size(img,1)]);     
                      hh1{jj}=subplot(4,nCams,jj);
                      plts{jj,1}=imagesc(X,Y,img);colormap jetvar;
                      xlabel('x [pix]');ylabel('y [pix]');set(gca,'FontSize',8);
                      title(lcaGetSmart([UserData.camerapvs{jj},':NAME']),'FontSize',8);
                      
                    for p = 2:4    % Set plot options                                    
                        pidx = jj+(p-1)*nCams;
                        hh1{pidx}=subplot(4,nCams,pidx); box on; grid on;set(gca,'FontSize',8)
                        if p==4; xlabel('Time');end        
                        if jj==1; ylabel(ylabels{p});end
                        if jj==1;title(sprintf(plot_titles{p}),'FontSize',8);end
                        % Hold on to make 3 plots. Create initial points and set line styles. 
                        hold on
                       plts{pidx,1} = plot(hh1{pidx},timestamp(1),beamProps(jj,k,1),'k','linewidth',1);
                       plts{pidx,2} = plot(hh1{pidx},timestamp(1),beamProps(jj,k,2),'r');
                       grid on
                       ticks = linspace(now-1/12/2, now, 4); % 60 ticks from the last hour
                       labels = datestr(ticks, 'HH:MM'); % get only hours and minutes
                       set(hh1{pidx}, 'xtick', ticks, 'xtickLabel', labels);                       
                    end
                    legend(hh1{nCams+1},'x','y','location','NorthWest','FontSize',8);
                end
                %% Fill buffer for first time
                for k = 2:UserData.bufferSize% Only stores bufferSize steps in variable
                   
                  for jj = 1:nCams                               
                [beamProps(jj,k,:),img]=GrabLaserBeamPropertiesV3(UserData,jj);     % Load array with new data              
                 timestamp(k) = now;                                  
                    if ishandle(h1) % Plot new Data
                    set(plts{jj,1}, 'CData', img );  
                    set(plts{jj+nCams,1}, 'XData', timestamp(1:k), 'YData', beamProps(jj,1:k,1) );% X centr  
                    set(plts{jj+nCams,2}, 'XData', timestamp(1:k), 'YData', beamProps(jj,1:k,2) );% Y centr
                    set(plts{jj+2*nCams,1}, 'XData', timestamp(1:k), 'YData', beamProps(jj,1:k,3) );% X rms  
                    set(plts{jj+2*nCams,2}, 'XData', timestamp(1:k), 'YData', beamProps(jj,1:k,4) );% Y rms          
                    set(plts{jj+3*nCams,1}, 'XData', timestamp(1:k), 'YData', beamProps(jj,1:k,5) );% Sum counts 
                 
                        for m = 2:4% Set the moving time window
                        pidx = jj+(m-1)*nCams;
                        ticks = linspace(timestamp(1), now, 4); % 4 ticks for buffer window
                        labels = datestr(ticks, 'HH:MM'); % get only hours and minutes            
                        set(hh1{pidx},'Xlim',[timestamp(1),now]);% This is where u set the xlim i.e the time window
                        set(hh1{pidx}, 'xtick', ticks, 'xtickLabel', labels); 
                        end                  
                        drawnow;                 
                    else
                     return
                    end
                    
                  end
             
                end
                %% March through time. No replotting required, just update XData and YData
        while(ishandle(h1))    
       
          for jj = 1:nCams
              tstart = tic;
              beamProps(jj,:,:) = circshift(beamProps(jj,:,:),[0 -1 0]);
         
            [beamProps(jj,size(beamProps,2),:),img]=GrabLaserBeamPropertiesV3(UserData,jj); % Load array with new data 
          
                timestamp = circshift(timestamp,[2 -1]); timestamp(length(timestamp)) = now;% Replace last value in buffer with new data
    
            if ishandle(h1)         % Plot new Data 
            set(plts{jj,1}, 'CData', img );  
            set(plts{jj+nCams,1}, 'XData', timestamp(1:k), 'YData', beamProps(jj,1:k,1) );% X centr  
            set(plts{jj+nCams,2}, 'XData', timestamp(1:k), 'YData', beamProps(jj,1:k,2) );% Y centr
            set(plts{jj+2*nCams,1}, 'XData', timestamp(1:k), 'YData', beamProps(jj,1:k,3) );% X rms  
            set(plts{jj+2*nCams,2}, 'XData', timestamp(1:k), 'YData', beamProps(jj,1:k,4) );% Y rms          
            set(plts{jj+3*nCams,1}, 'XData', timestamp(1:k), 'YData', beamProps(jj,1:k,5) );% Sum counts 
         % Set the moving time window
                for m = 2:4
                    pidx = jj+(m-1)*nCams;
                ticks = linspace(timestamp(1), now, 4); % 60 ticks from the last hour
                labels = datestr(ticks, 'HH:MM'); % get only hours and minutes            
                set(hh1{pidx},'Xlim',[timestamp(1),now]);% This is where u set the xlim i.e the time window
                set(hh1{pidx}, 'xtick', ticks, 'xtickLabel', labels); 
                end
            
                drawnow;
            else 
                return
            end
         end 
        end
       end
                
        
       function [imgcrop,roiAxesVals] = setImgROI(app,img,nSig)
                
                beamParams = beamAnalysis_beamParams(img, 1:size(img,2), 1:size(img,1),0,app.opts);
                x_com = beamParams.stats(1);y_com = beamParams.stats(2);
                xrms = beamParams.stats(3);yrms = beamParams.stats(4);
                sigma = max(xrms,yrms);  
                adims = [y_com-nSig*sigma<0,y_com+nSig*sigma>size(img,1),x_com-nSig*sigma<0,x_com+nSig*sigma>size(img,2)];
                bdims = round([y_com-nSig*sigma,y_com+nSig*sigma,x_com-nSig*sigma,x_com+nSig*sigma]);
                % This makes sure your indices are not outside image range   
                try
                if ~any(logical(adims))
                imgcrop = img(bdims(1):bdims(2),bdims(3):bdims(4));    
                roiAxesVals = [bdims(1),bdims(2),bdims(3),bdims(4)];
                    else
                         for jk = 1:4
                         if mod(jk,2);cropDim(jk) = max(1,bdims(jk));else;cropDim(jk) = min(size(img,jk/2),bdims(jk));end
                         end        
                     imgcrop = img(cropDim(1):cropDim(2),cropDim(3):cropDim(4));
                     roiAxesVals = [cropDim(1),cropDim(2),cropDim(3),cropDim(4)];
                end
                catch
                    warning(['Failed to auto set image ROI']);
                    imgcrop = img;
                    roiAxesVals = [1,size(imgcrop,2),1,size(imgcrop,1)];
                end
        end
    end
     
  

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            try
                app.cameraPVs = evalin('base','cameraPVs');
            catch 
                warning('No cameras specified defaulting to S20 Laser Room')
            app.cameraPVs = {'CAMR:LT20:0001','CAMR:LT20:0002','CAMR:LT20:0003','CAMR:LT20:0004',...
            'CAMR:LT20:0005','CAMR:LT20:0006','CAMR:LT20:0007','CAMR:LT20:0008'};       
            end
          app.AxesStorage={app.UIAxes, app.UIAxes_2, app.UIAxes_3, app.UIAxes_4...
                , app.UIAxes_5, app.UIAxes_6, app.UIAxes_7, app.UIAxes_8,app.UIAxes_9};
            for i=1:length(app.cameraPVs)
            title(app.AxesStorage{i},lcaGetSmart([app.cameraPVs{i},':NAME']));
            end
            if length(app.AxesStorage)>length(app.cameraPVs)
                for i=length(app.cameraPVs)+1:length(app.AxesStorage)
                    delete(app.AxesStorage{i});
                end
                
            end
            app.opts=struct('usemethod',2);% Fit Option If you wanna process the image
        end

        % Button pushed function: StartDisplayingButton
        function StartDisplayingButtonPushed(app, event)
 
            app.plotBool = 1;
            while app.plotBool
                
                for i =1:length(app.cameraPVs)
                    if lcaGetSmart([app.cameraPVs{i},':ArrayRate_RBV'])== 0 || isnan(lcaGetSmart([app.cameraPVs{i},':ArrayRate_RBV']))
                        continue
                    end
                    data = profmon_grab([app.cameraPVs{i}]);
                    img = data.img;
                    
                    [img,~,~,~,~]=beamAnalysis_imgProc(data,app.opts);% Processed Image
                    if app.autoROI
                       [imgcrop,roiAxesVals] = setImgROI(app,data.img,4);
                       X = [1:size(imgcrop,2)]+roiAxesVals(1);
                       Y = [1:size(imgcrop,2)]+roiAxesVals(3);
                       imagesc(app.AxesStorage{i},X,Y,imgcrop);                   
                    else
                        X = data.roiX+[1:data.roiXN];
                        Y = data.roiY+[1:data.roiYN];
                    imagesc(app.AxesStorage{i}, X,Y,img);
                    end
                    axis(app.AxesStorage{i},'tight');
                    app.AxesStorage{i}.Colormap = jetvar;
                end   
                drawnow
                pause(0.3)
            end
            
        end

        % Button pushed function: PauseDisplayingButton
        function PauseDisplayingButtonPushed(app, event)
            app.plotBool = 0;
        end

        % Value changed function: AutoROICheckBox
        function AutoROICheckBoxValueChanged(app, event)
            value = app.AutoROICheckBox.Value;
            app.autoROI = value;
        end

        % Button pushed function: PrinttoeLogButton
        function PrinttoeLogButtonPushed(app, event)
            fh = figure(101);
            for i =1:length(app.cameraPVs)
                    if lcaGetSmart([app.cameraPVs{i},':ArrayRate_RBV'])== 0 || isnan(lcaGetSmart([app.cameraPVs{i},':ArrayRate_RBV']))
                        continue
                    end
                    data = profmon_grab([app.cameraPVs{i}]);
                    subplot(2,5,i)
                    if app.autoROI                     
                       [imgcrop,roiAxesVals] = setImgROI(app,data.img,4);
                       X = [1:size(imgcrop,2)]+roiAxesVals(1);
                       Y = [1:size(imgcrop,2)]+roiAxesVals(3);
                       imagesc(X,Y,imgcrop)
                    else
                        X = data.roiX+[1:data.roiXN];
                        Y = data.roiY+[1:data.roiYN];
                    imagesc(X,Y,data.img);
                    end
                   % axis(fh,'tight');
                    colormap  jetvar;
                    axesnum = app.AxesStorage{i};                
                    xlabel(axesnum.XLabel.String)
                    ylabel(axesnum.YLabel.String)
                    set(gca,'FontSize',8)
                    title(axesnum.Title.String,'FontSize',10)
            end
                drawnow
                %print(fh, '-dpsc2', ['-P','physics-facetlog']);  
                util_printLog(fh,'title','Laser Multi Profmon GUI',...
            'author','F2_LaserMultiProfmon');
                close(fh)
                       
        end

        % Button pushed function: ShowstatsButton
        function ShowstatsButtonPushed(app, event)
            laserStatsTable
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            app.plotBool =0;
            delete(app)
            exit
        end

        % Button pushed function: ShowStripChartButton
        function ShowStripChartButtonPushed(app, event)
            launchLaserStripChart(app)
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1204 490];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, '')
            xlabel(app.UIAxes, 'X [pix]')
            ylabel(app.UIAxes, 'Y [pix]')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Box = 'on';
            app.UIAxes.Position = [12 286 230 185];

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.UIFigure);
            title(app.UIAxes_2, '')
            xlabel(app.UIAxes_2, 'X [pix]')
            ylabel(app.UIAxes_2, 'Y [pix]')
            zlabel(app.UIAxes_2, 'Z')
            app.UIAxes_2.Box = 'on';
            app.UIAxes_2.Position = [250 286 230 185];

            % Create UIAxes_3
            app.UIAxes_3 = uiaxes(app.UIFigure);
            title(app.UIAxes_3, '')
            xlabel(app.UIAxes_3, 'X [pix]')
            ylabel(app.UIAxes_3, 'Y [pix]')
            zlabel(app.UIAxes_3, 'Z')
            app.UIAxes_3.Box = 'on';
            app.UIAxes_3.Position = [495 286 230 185];

            % Create UIAxes_4
            app.UIAxes_4 = uiaxes(app.UIFigure);
            title(app.UIAxes_4, '')
            xlabel(app.UIAxes_4, 'X [pix]')
            ylabel(app.UIAxes_4, 'Y [pix]')
            zlabel(app.UIAxes_4, 'Z')
            app.UIAxes_4.Box = 'on';
            app.UIAxes_4.Position = [724 286 230 185];

            % Create UIAxes_5
            app.UIAxes_5 = uiaxes(app.UIFigure);
            title(app.UIAxes_5, '')
            xlabel(app.UIAxes_5, 'X [pix]')
            ylabel(app.UIAxes_5, 'Y [pix]')
            zlabel(app.UIAxes_5, 'Z')
            app.UIAxes_5.Box = 'on';
            app.UIAxes_5.Position = [953 286 230 185];

            % Create UIAxes_6
            app.UIAxes_6 = uiaxes(app.UIFigure);
            title(app.UIAxes_6, '')
            xlabel(app.UIAxes_6, 'X [pix]')
            ylabel(app.UIAxes_6, 'Y [pix]')
            zlabel(app.UIAxes_6, 'Z')
            app.UIAxes_6.Box = 'on';
            app.UIAxes_6.Position = [12 85 230 185];

            % Create UIAxes_7
            app.UIAxes_7 = uiaxes(app.UIFigure);
            title(app.UIAxes_7, '')
            xlabel(app.UIAxes_7, 'X [pix]')
            ylabel(app.UIAxes_7, 'Y [pix]')
            zlabel(app.UIAxes_7, 'Z')
            app.UIAxes_7.Box = 'on';
            app.UIAxes_7.Position = [250 85 230 185];

            % Create UIAxes_8
            app.UIAxes_8 = uiaxes(app.UIFigure);
            title(app.UIAxes_8, '')
            xlabel(app.UIAxes_8, 'X [pix]')
            ylabel(app.UIAxes_8, 'Y [pix]')
            zlabel(app.UIAxes_8, 'Z')
            app.UIAxes_8.Box = 'on';
            app.UIAxes_8.Position = [495 85 230 185];

            % Create StartDisplayingButton
            app.StartDisplayingButton = uibutton(app.UIFigure, 'push');
            app.StartDisplayingButton.ButtonPushedFcn = createCallbackFcn(app, @StartDisplayingButtonPushed, true);
            app.StartDisplayingButton.FontSize = 14;
            app.StartDisplayingButton.Position = [31 18 134 24];
            app.StartDisplayingButton.Text = 'Start Displaying';

            % Create PauseDisplayingButton
            app.PauseDisplayingButton = uibutton(app.UIFigure, 'push');
            app.PauseDisplayingButton.ButtonPushedFcn = createCallbackFcn(app, @PauseDisplayingButtonPushed, true);
            app.PauseDisplayingButton.FontSize = 14;
            app.PauseDisplayingButton.Position = [187 18 123 24];
            app.PauseDisplayingButton.Text = 'Pause Displaying';

            % Create PrinttoeLogButton
            app.PrinttoeLogButton = uibutton(app.UIFigure, 'push');
            app.PrinttoeLogButton.ButtonPushedFcn = createCallbackFcn(app, @PrinttoeLogButtonPushed, true);
            app.PrinttoeLogButton.BackgroundColor = [0.0745 0.6235 1];
            app.PrinttoeLogButton.FontSize = 14;
            app.PrinttoeLogButton.Position = [341 18 100 24];
            app.PrinttoeLogButton.Text = 'Print to eLog';

            % Create ShowstatsButton
            app.ShowstatsButton = uibutton(app.UIFigure, 'push');
            app.ShowstatsButton.ButtonPushedFcn = createCallbackFcn(app, @ShowstatsButtonPushed, true);
            app.ShowstatsButton.Position = [953 19 100 23];
            app.ShowstatsButton.Text = 'Show stats';

            % Create AutoROICheckBox
            app.AutoROICheckBox = uicheckbox(app.UIFigure);
            app.AutoROICheckBox.ValueChangedFcn = createCallbackFcn(app, @AutoROICheckBoxValueChanged, true);
            app.AutoROICheckBox.Text = 'Auto ROI';
            app.AutoROICheckBox.Position = [1085 20 71 22];

            % Create UIAxes_9
            app.UIAxes_9 = uiaxes(app.UIFigure);
            title(app.UIAxes_9, '')
            xlabel(app.UIAxes_9, 'X [pix]')
            ylabel(app.UIAxes_9, 'Y [pix]')
            app.UIAxes_9.Box = 'on';
            app.UIAxes_9.Position = [724 85 230 185];

            % Create ShowStripChartButton
            app.ShowStripChartButton = uibutton(app.UIFigure, 'push');
            app.ShowStripChartButton.ButtonPushedFcn = createCallbackFcn(app, @ShowStripChartButtonPushed, true);
            app.ShowStripChartButton.Position = [823.5 18 107 23];
            app.ShowStripChartButton.Text = 'Show Strip Chart';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_LaserMultiProfmon_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end