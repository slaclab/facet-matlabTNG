classdef DataSetDAN < handle
    %DATASETDAN Summary of this class goes here
    %   Detailed explanation goes here
    %
    %   Puclic properties:
    %       dataSet
    %       dataSetID
    %       hdr
    %
    %   Private properties:
    %   
    %       visImageIncrement
    %
    %   Public methods:
    %       waterfallPlot
    %       correlationPlot
    %       histogramPlot
    %       visImage
    %       visImages
    %       visAvImage
    %
    %
    %   Private methods:
    %
    %
    %   Wishlist:
    %       1. IMPLEMENTED subtracts background
    %       2. average over given number of images
    %       3. IMPLEMENTED colorbar adjuster
    %       4. IMPLEMENTED scalar histogram plot
    %       5. rotate and axis orientation
    %       6. select data points
    %       7. waterfall plot sort overlay sorting variable
    %       8. select set of data points to use
    %       9. Make DAN log work
    %       10. Print relevant dataSet metadata somewhere
    %       11. Fitting functions
    %       12. IMPLEMENTED Save plot data function
    %       13. Draw on top of current image function
    %
    %   Author: Henrik Ekerfelt
    
    properties (Access = public)
        dataSet;
        dataSetID;
        hdr;
        imgType
        
        % Ugly GUI settings
        showOnlyMatchedData = 1;
        
        hasBG = 0;
        subtractBackground = 0;
        
        visImageIncrement = 1;
        keepPlotting = 1;
        loopWaitTime = 0.5;
        
        
        % tempScalars
        tempScalars = struct();
        
    end
    
    properties (Access = private)
        
        include_data;
        inclSCP;
        
        % DAQ-file specific properties 
        maxShotNbr;
        scalarGroups;
        listOfCameras;
        visImageDiag;
        
        % GUI specific properties
        plotToGUI = 0;
        GUIHandle;
        
        % exportPlotData
        lastPlotData; %Struct for storing lastPlotData
        HDF5_imData = double.empty;
    end
    
    % Constructor
    methods 
        function s = DataSetDAN(dSID,exp,apph)
            %DATASETDAN Construct an instance of this class
            %   Detailed explanation goes here

            s.dataSetID = dSID;
            s.hlpDispMsg('Looking for directory...\n')
            if nargin >= 2
                %tic
                [s.dataSet,s.hdr] = getDataSet(dSID,exp);
                %toc
            else 
                %tic
                [s.dataSet,s.hdr] = getDataSet(dSID);
                %toc
            end
            s.hlpDispMsg('Done looking for directory\n')
            
            if nargin > 2
                s.GUIHandle = apph;
                s.plotToGUI = 1;
            end
            
            % Check if user wants to include SCP data in matches/analysis
            s.inclSCP = s.GUIHandle.InclSCPCheckBox.Value;
            if s.inclSCP == 1
                s.maxShotNbr = length(s.dataSet.pulseID.common_scalar_index_inclSCP);
            else
                s.maxShotNbr = length(s.dataSet.pulseID.common_scalar_index);
            end
            
            s.getImgType();
            
            s.hlpFindScalarGroups();
            s.hlpGetListOfCameras();
            
            s.hlpDispMsg('dataSet succefully loaded\n');
            
        end
    end
    
    %% Plotter 
    methods (Access = public) 
        
        
        function selectImages(s, FSArray, boolFcn)
        %% selectImages(s, FSArray, validFcn)
        % Of the already selected images, excludes the shots not fulfilling
        % the boolFcn.
        %
        % Example use:
        %
        % selectImages({'AX_IMG1', @(x) sum(sum(x)) }, @(x) x > 3e6)
        % selects the images from AX_IMG1 with a total pixel count sum 
        % greater than 3e6.
        % 
        % selectImages()
        % resets (removes) all previous selections.
        %
        
            if nargin == 3
                type = s.hlpIsFSArray(FSArray);
                [FSArray,FSLabel] = s.hlpGetScalarArray(FSArray, type);
                
                s.cam_select = s.cam_idx( boolFcn(FSArray) );
                s.epics_select = s.epics_idx( boolFcn(FSArray) );
                
                [~,idx] = intersect(s.cam_sort, s.cam_select);
                s.cam_idx = s.cam_sort(sort(idx));
                
                [~,idx2] = intersect(s.epics_sort, s.epics_select);
                s.epics_idx = s.epics_sort(sort(idx2));
                
            elseif nargin == 1
                s.cam_select = s.CAM_INDEX;
                s.epics_select = s.EPICS_INDEX;
                
                [~,idx] = intersect(s.cam_sort, s.cam_select);
                s.cam_idx = s.cam_sort(sort(idx));
                
                [~,idx2] = intersect(s.epics_select, s.epics_sort);
                s.epics_idx = s.epics_sort(sort(idx2));
            end
            
        end
        
        function visImage(s, diag, shotNbr, fcn)
            % Plots a single image from dataset diag 
            if nargin < 4
                fcn =@(x)x;
            end
            
            if s.validShotNbr(shotNbr)                
                % Get image data
                disp(['visImage: ', diag]) %BDO
                [data,~] = s.hlpCheckImage(diag);
                
                if strcmp(s.imgType,'HDF5')
                    if (isempty(s.HDF5_imData) || ~strcmp(s.visImageDiag, diag))
                        % If there is no HDF5 data, or the requested
                        % diagnostic changes, load the HDF5 data.
                        s.HDF5_imData = s.hlpGetImageHDF5(diag);
                        diagData = s.HDF5_imData(:,:,data.common_index(shotNbr));
                    else
                        diagData = s.HDF5_imData(:,:,data.common_index(shotNbr));
                    end
                else
                    diagData = s.hlpGetImage(diag,data.common_index(shotNbr));
                end

                % Get plot info
                curHandle = s.hlpGetFigAxis();
                
                type = 'Single image';
                xlabS = 'Pixels';
                ylabS = 'Pixels';
                titleS = sprintf('Image of %s shot number %d', ...
                    diag, shotNbr);
                
                s.hlpPlotImage(curHandle, fcn(diagData), type, ...
                    titleS, xlabS, ylabS);
                
                % Save the diagnostic that was plotted so you can tell when
                % the requested diagnostic has changed
                s.visImageDiag = diag;
                
            end
            
        end
        
        function visImages(s, diag, startNbr, fcn)
            
            if nargin < 4
                fcn = @(x)x;
            end
            
            [data,~] = s.hlpCheckImage(diag);
            
            for k = startNbr:s.visImageIncrement:length(data.common_index)
                s.visImage(diag, k, fcn);
                pause(s.loopWaitTime);
                s.GUIHandle.ImagenumberEditField.Value = k;
                
                if ~s.keepPlotting 
                    s.keepPlotting = 1;
                    return;
                end
            end
            
        end
        
%         function visAvImage(s, diag, nbrsToAv)
%             
%         end
        
        function plotCorrMatrix(s)
            % Create array of all scalar data
            if s.inclSCP
                numDataPts = numel(s.dataSet.pulseID.common_scalar_index_inclSCP);
            else
                numDataPts = numel(s.dataSet.pulseID.common_scalar_index);
            end
            
            scalars = s.GUIHandle.IncludeListBox_CorrM.Items; % cell array
            numScalars = numel(scalars);
            scalarArrayData = zeros(numDataPts,numScalars);
            
            for i = 1:numScalars
                facetScalar = s.GUIHandle.IncludeListBox_CorrM.Items{i};
                [x, ~] = s.hlpGetScalarArray(facetScalar,1);
                scalarArrayData(:,i) = x;
            end
            
            if any(any(isnan(scalarArrayData)))
                s.GUIHandle.addMsg('Warning: Scalar data contains NaNs!')
            end
            
            panelHan = s.GUIHandle.PlotsPanel;
            set(panelHan,'AutoResizeChildren','off');
            delete(panelHan.Children); % clear plots
                
            if numScalars < 5
                % Make corrplot and copy to GUI panel
                fig = figure('Visible','off');
                ax = axes(fig);
                try
                    [R,~,h] = corrplot(ax,scalarArrayData);
                catch ME
                    s.GUIHandle.addMsg('Failed to make correlation plot');
                    if strcmp(ME.identifier,'MATLAB:hg:shaped_arrays:LimitsWithInfsPredicate')
                        s.GUIHandle.addMsg('Make sure correlations can be calculated for the selected variables');
                    end
                    return
                end

                % Copy all histogram/scatter plot handles
                axesHans = {};
                t = tiledlayout(panelHan,numScalars,numScalars,'Padding',...
                    'compact','TileSpacing','normal');
                
                XscalarVec = repmat(1:numScalars,numScalars,1);
                YscalarVec = repelem(1:numScalars,numScalars);
                for i = 1:numel(h)
                    axesHans{i} = nexttile(t);
                    copyobj(h(i),axesHans{i});
                    
                    scalars = replace(scalars,"_"," ");
                    xlabel(axesHans{i},scalars(XscalarVec(i)))
                    ylabel(axesHans{i},scalars(YscalarVec(i)),'FontSize',7)
                end

                delete(fig); % delete corrplot figure
            else
                [R,~] = corrcoef(scalarArrayData);
                
                t = tiledlayout(panelHan,1,1,'Padding',...
                    'compact','TileSpacing','none');
                axHan = nexttile(t);
                imagesc(axHan,R);
                colorbar(axHan);
                
                scalars = replace(scalars,"_"," ");
                xticks(axHan,1:numScalars);
                xticklabels(axHan,scalars);
                xtickangle(axHan,45);
                
                yticks(axHan,1:numScalars);
                yticklabels(axHan,scalars);
            end

            title(t,"Correlation Matrix",'FontWeight','bold');
                        
            % Show R values in DAN log
            s.hlpDispMsg('R =');
            R_str = num2str(R);
            for i = 1:size(R_str,1)
                s.hlpDispMsg(R_str(i,:));
            end
        end
        
        function [gof, ci] = fitData(s,fitMethod)
            % There is another "fit" function so we have to add the path
            % for the one we want to use (the matlab function)
            addpath('/usr/local/lcls/package/matlab/2020a/toolbox/curvefit/curvefit');
            
            % Get data
            scalars = s.GUIHandle.IncludeListBox_CorrM.Items; % cell array
            
            facetScalar1 = scalars{1};
            [x, ~] = s.hlpGetScalarArray(facetScalar1,1);
            facetScalar2 = scalars{2};
            [y, ~] = s.hlpGetScalarArray(facetScalar2,1);
            
            panelHan = s.GUIHandle.PlotsPanel;
            set(panelHan,'AutoResizeChildren','off');
            delete(panelHan.Children); % clear plots
            
            % Create UI Axes in panel and set size
            axesHan = uiaxes(panelHan);
            panelSize = get(panelHan,'Position');
            set(axesHan,'Position',[10 10 panelSize(3)-20 panelSize(4)-30]);
            
            % Filter out NaN values for fit
            y = y(~isnan(x));
            x = x(~isnan(x));
            x = x(~isnan(y));
            y = y(~isnan(y));
            
            % Get only unique X values
            % I think the "right" thing to do in this case would be to find
            % repeated values and average them, but for now just using
            % "unique" to retain only the first repeated data point
            [x_unique,idx] = unique(x);
            y_unique = y(idx);

            [f,gof] = fit(x_unique,y_unique,fitMethod);
            % Get confidence intervals
            ci = confint(f);
            
            fig = figure('Visible','off');
            ax = axes(fig);
            h = plot(f,x_unique,y_unique,'x');
            
            hApp = copyobj(h,axesHan);
%             title(axesHan,"")
            
            % Fix underscores in scalar names and set x and y labels
            facetScalar1 = replace(facetScalar1,"_"," ");
            facetScalar2 = replace(facetScalar2,"_"," ");
            xlabel(axesHan,facetScalar1)
            ylabel(axesHan,facetScalar2)
            drawnow;

            delete(fig);
        end

        function waterfallPlot(s, diag, fcn, sortFSArray, plotBool)

            if nargin < 3
                s.hlpDispMsg('Need at least 3 inputs')
                return
            end
            
            curHandle = s.hlpGetFigAxis();

            [data,diagData] = s.hlpCheckImage(diag); % returns image data for first shot
            
            %Check that the provided function maps 2D -> 1D array
            wFData = fcn(diagData);

            [r,c] = size(wFData);
            if ~xor(r == 1, c == 1)
                error('The provided function does not map the data correctly. Mapped data has %d rows and %d columns.',r,c)
            end

            %Pre-allocate
            if strcmp(s.imgType,'TIFF')
                len = length(data.loc(data.common_index));
            elseif strcmp(s.imgType,'HDF5')
                len = length(data.common_index);
            end
            waterfall = zeros(r*c,len);
            waterfall(:,1) = wFData;
            
            sortedIdx = 1:len;
            sortLab = 'idx';
            
            if nargin >= 4
                type = s.hlpIsFSArray(sortFSArray);
                s.hlpDispMsg('Starting to sort vector')
                [sortFSArray,sortLab] = s.hlpGetScalarArray(sortFSArray, type);
                sortLab = ['Sorted on ', sortLab];
                [~, sortedIdx] = sort(sortFSArray);
                s.hlpDispMsg('Done with sorting vector')
            end
            
            if nargin < 5
                plotBool = 0;
            end
            
            %Label for applied function
            fcnS = func2str(fcn);

            % Create an allowed field name for the struct that is kind of unique 
            fcnSN = s.fcn2fieldName(fcnS);
            
            %Check if this has been calculated before to speed up the
            %plotting
            if isfield(s.tempScalars, diag) && ...
               isfield(s.tempScalars.(diag),'waterfall') && ...
               isfield(s.tempScalars.(diag).waterfall,fcnSN)       
               waterfall = s.tempScalars.(diag).waterfall.(fcnSN);
            else
                s.hlpDispMsg('Starting to make waterfall plot...\n')
                if strcmp(s.imgType,'TIFF')
                    for k = 1:len
                        diagData = s.hlpGetImage(diag, data.common_index(k));
                        wFData = fcn(diagData);
                        waterfall(:,k) = wFData;
                    end
                elseif strcmp(s.imgType,'HDF5')
                    % Load all the HDF5 Images
                    imData = s.hlpGetImageHDF5(diag);
                    % Grab only the shots that are in the common index
                    imData = imData(:,:,data.common_index);
                    % Loop through the images, apply the the function and
                    % add it to the waterfall plot.
                    for k = 1:len
                        waterfall(:, k) = fcn(imData(:, :, k));
                    end
%                     waterfall = squeeze(fcn(imData));
                end
                s.hlpDispMsg('Finished making waterfall plot\n')
                s.tempScalars.(diag).waterfall.(fcnSN) = waterfall;
            end

            type = 'Waterfall plot';
            xlabS = sortLab;
            ylabS = fcnS;
            titleS = sprintf('Waterfall plot of %s', diag);

            s.hlpPlotImage(curHandle, waterfall(:,sortedIdx), type, ...
            titleS, xlabS, ylabS);
            s.hlpSetPlotLabels(curHandle, titleS, xlabS, ylabS);
            if plotBool
                s.hlpPlotOverlay(sortFSArray,sortedIdx,sortLab);
                drawnow;
            end
            
            % Add (approximate) step ticks
            x_shots_ticks = curHandle.XTick;
            steps = data.step(data.common_index)';
            steps_ticks = [0 steps(x_shots_ticks(2:end))];
            labelArray = [compose('%3g',x_shots_ticks); compose('%3g',steps_ticks)];
            tickLabels = strtrim(sprintf('%s\\newline%s\n', labelArray{:}));
            
            curHandle.XTickLabel = tickLabels;
            xlabel(curHandle,'First row: Shot number / Second row: Step number',...
                'FontSize',7);
        end
        
        function correlationPlot(s, inputArg1, SG1, inputArg2, SG2)
        %CORRELATIONPLOT plots 1 FACET-vector as a function another
        %  A FACET-vector can be defined by:
        %   - experimental scalar value captured for each shot in a dataset
        %   - a combination of an image diagnostic and a function that maps images
        %   to scalar values      
        % 
        %  Example use:
        %  
        %
        %  A scalar can be either a cell array containing a string with the a
        %  string with the name of a scalar diagnostic, or a cell containing the
        %  name of an image diagnostic and a function that maps the image to a
        %  scalar value.
        %  
        %  Single scalar case:
        %
        %  correlationPlot({'BPMS_LI20_2445_X'})
        %
        %    plots the scalar diagnostic value BPMS_LI20_2445_X as a 
        %  function of shot number
        %
        %  correlationPlot({'EOS_LO',@(x) sum(sum(x)) })
        %    plots the scalar diagnostic value from the image diagnostic 'EOS_LO' 
        %  mapped to a scalar by the lambda function @(x) sum(sum(x)) as a function 
        %  of shot number
        %  
        %  Double scalar case:
        %    correlationPlot({'BPMS_LI20_2445_X'}, {'EOS_LO',@(x) sum(sum(x))}) 
        %  plots the scalar diagnostic value BPMS_LI20_2445_X as a
        %  function of the scalar diagnostic value from the image diagnostic
        %  'EOS_LO' mapped to a scalar by the lambda function @(x) sum(sum(x))
        %
        %  Author: Henrik Ekerfelt

        %% Input parsing
        
            curHandle = s.hlpGetFigAxis();
            titleS = sprintf('Correlation plot');
            
            errm = 'input argument #1 not a FACET Scalar Array';
            type = s.hlpIsFSArray(inputArg1,errm);
            
            [x, xlabS] = s.hlpGetScalarArray(inputArg1,type,SG1);

            
            if nargin == 5
                errm = 'input argument #2 not a FACET Scalar Array';
                type = s.hlpIsFSArray(inputArg2, errm);
                [y, ylabS] = s.hlpGetScalarArray(inputArg2,type,SG2);
                
                s.hlpPlotTwoScalarArray(curHandle, x, y, ...
                    titleS, xlabS, ylabS)
                return
            end
            
            ylabS = xlabS;
            xlabS = 'idx';
                
            s.hlpPlotScalarArray(curHandle, x, ...
            titleS, xlabS, ylabS);
            
        end
        
        function histogramPlot(s,FS)
            % Plots a histogram of given scalar values
            curHandle = s.hlpGetFigAxis();
            
            errm = 'input argument not a FACET Scalar Array';
            type = s.hlpIsFSArray(FS, errm);
            [x, xlabS] = s.hlpGetScalarArray(FS,type);
            
            
            ylabS = '#';
            titleS = 'Histogram';
            type = titleS;
            
            histogram(curHandle,x)
            
            s.lastPlotData = struct(); % Make sure struct is fresh
            s.lastPlotData.type = type;
            s.lastPlotData.data = x;
            s.hlpSetPlotLabels(curHandle, titleS, xlabS, ylabS);
            
        end
        
        function exportPlotData(s, fileName)
            % Saves plot data
            computer = char(java.net.InetAddress.getLocalHost.getHostName);
            
            if strcmp(computer,'facet-srv20-2')
                %Current time
                [~,tsi]=lcaGet('PATT:SYS1:1:PULSEID');
                ts = lca2matlabTime(tsi);
                
                [fileName, pathName] = util_dataSave(... 
                    s.lastPlotData, 'DANplot', fileName, ts);
                fprintf('Plot data saved at: %s/%s.\n', pathName, fileName);
            else
                plotData = s.lastPlotData;
                save(fileName, 'plotData');
                fprintf('Plot data saved at: %s.mat.\n', fileName);
            end
        end
        
        
        
    end
    
    %% Getters and checks
    methods (Access = public)
        function listOfCameras = getListOfCameras(s)
            % Returns a cell listOfCameras with all available camera names
            
            listOfCameras = s.listOfCameras;
        end
        
        function scalarGroups = getScalarGroups(s)
            % Return list of scalar groups
            scalarGroups = s.scalarGroups;
        end
        
        function scalarList = getScalarsInGroup(s,group)
            % Return list of scalars in group
            scalarList = fieldnames(s.dataSet.scalars.(group));
        end
        
        function bool = validShotNbr(s, shotNbr)
            % Checks if shot number exist
            if shotNbr > 0 && shotNbr <= s.maxShotNbr
                bool = 1;
            else
                s.hlpDispMsg('shotNbr not within valid range')
                bool = 0;
            end
        end
        
        function img = getImage(s, diag, sNbr)
            img = imread( sprintf('%s%s',s.hdr,s.dataSet.images.(diag).loc{sNbr}) );
            if s.subtractBackground
                img = img - s.dataSet.backgrounds.(diag)';
            end
        end
        
        function [scalarArray, scalarLabel] = getFacetScalar(s, ...
            FACETscalar)
        %% hlpGetScalarArray extracts a 1D array of values from FACET data
        %  currently supports scalar diagnostics (type 1) and image
        %  diagnostics combined with a function that maps 2D - > scalar
        %  (type 2).
        
            if ischar(FACETscalar)
                FACETscalar = {FACETscalar};
            end
            
            type = s.hlpIsFSArray( FACETscalar, 'Input is not an FACET Scalar Array');

            if type == 1
                if isfield(s.dataSet.scalars,(FACETscalar{1}))
                    if s.inclSCP
                        scalarArray = s.dataSet.scalars.(FACETscalar{1})(s.dataSet.pulseID.common_scalar_index_inclSCP);
                    else
                        scalarArray = s.dataSet.scalars.(FACETscalar{1})(s.dataSet.pulseID.common_scalar_index);
                    end
                    scalarLabel = FACETscalar{1};
                    return
                else
                    for k = 1:numel(s.scalarGroups)
                        if isfield(s.dataSet.scalars.(s.scalarGroups{k}),(FACETscalar{1}))
                            if s.inclSCP
                                scalarArray = s.dataSet.scalars.(s.scalarGroups{k}).(FACETscalar{1})(s.dataSet.pulseID.common_scalar_index_inclSCP);
                            else
                                scalarArray = s.dataSet.scalars.(s.scalarGroups{k}).(FACETscalar{1})(s.dataSet.pulseID.common_scalar_index);
                            end
                            scalarLabel = FACETscalar{1};
                            return
                        end
                    end
                end
            elseif type == 2
                % Check if already calculated
                fcn = FACETscalar{2};
                fcnS = func2str(fcn);
                
                %Create an allowed field name for the struct that is kind of unique 
                fcnSN = s.fcn2fieldName(fcnS);
                
                %Check if this has been calculated before to speed up the
                %plotting
                if isfield(s.tempScalars, FACETscalar{1}) && ...
                        isfield(s.tempScalars.(FACETscalar{1}),fcnSN)
                    scalarArray = s.tempScalars.(FACETscalar{1}).(fcnSN);
                else
                    dS = getfield(s.dataSet.images,FACETscalar{1});
                    nbrOfShots = length(dS.common_index);
                    scalarArray = zeros(1,nbrOfShots);
                    
                    if strcmp(s.imgType,'TIFF')
                        for k = 1:nbrOfShots
                            diagData = s.hlpGetImage(FACETscalar{1},dS.common_index(k));
                            scalarData = fcn(diagData);
                            scalarArray(:,k) = scalarData;
                        end
                    elseif strcmp(s.imgType,'HDF5')
                        diagData = s.hlpGetImageHDF5(FACETscalar{1}); % returns all image data
                        diagData = diagData(:,:,dS.common_index);
                        scalarData = fcn(diagData);
                        scalarArray = scalarData;
                    end
                end
                
                %Save if used request to plot this again
                s.tempScalars.(FACETscalar{1}).(fcnSN) = scalarArray;
                
                scalarLabel = sprintf('%s|%s',FACETscalar{1},fcnS);
            end

        end
        
        function N = nbrOfSyncedDataPoints(s)
            N = length(s.dataSet.scalars.common_index);
        end
            
        function RVstruct = processImgsRV(s, diag, fcn)
            % Returns a struct with a matrix RV defined by fcn and the 
            % number of datapoints n in the diagnsotic diag and the length
            % N of the 1D vector  
            
            [data,diagData] = s.currAxes(diag);
            l = length(fcn(diagData));
            RVstruct.RV = zeros(l,length(data.common_index));
            
            
            for k = 1:length(data.common_index)
                img = s.hlpGetImage(diag, k);
                RVstruct.RV(:,k) = fcn(img);
            end
            
            %fill meta data
            RVstruct.diag = diag;
            RVstruct.fcn = fcn;
            RVstruct.fcnS = func2str(fcn);
            RVstruct.idx = data.common_index;
            
        end
        
        function getImgType(s)
            try
                s.imgType = s.dataSet.params.saveMethod;
            catch
                camPath = s.dataSet.save_info.cam_paths{1};
                listing = dir([camPath '/*data*']);
                fn = listing.name;
                expr = '\.[0-9a-z]+$';
                idx = regexp(fn,expr) + 1;
                
                %Check and select method to load from file format
                if strcmp(fn(idx:end),'tif') || strcmp(fn(idx:end),'tiff')
                    s.imgType = 'TIFF';
                elseif strcmp(fn(idx:end),'h5') || strcmp(fn(idx:end),'hdf5')
                    s.imgType = 'HDF5';
                else
                    error('File format not recognized for data.')
                end
            end
        end
        
    end
    
    
    %% private help functions
    methods (Access = private)
        
        function select_cams(s)
        %% Checks the UID of the images and the scalar data
        % DEPRECATED
        % selects and stores the matching indices in s.CAM_INDEX and
        % s.EPICS_INDEX. This is performeds once per initialization.
            
            CAMS = fields(s.dataSet.images);
            nCAMS = numel(CAMS);

            EPICS_UID  = s.dataSet.scalars.PATT_SYS1_1_PULSEID.UID;
            COMMON_UID = EPICS_UID;

            for i = 1:nCAMS
                cam_struct = s.dataSet.images.(CAMS{i});
                COMMON_UID = intersect(COMMON_UID,cam_struct.UID);
            end

            [~,~,EPICS_INDEX] = intersect(COMMON_UID,EPICS_UID);

            MATCHED     = numel(EPICS_INDEX);
            CAM_INDEX   = zeros(MATCHED,nCAMS);

            for i = 1:nCAMS
                cam_struct = s.dataSet.images.(CAMS{i});
                [~,~,CAM_INDEX(:,i)] = intersect(COMMON_UID,cam_struct.UID);
            end

            n_req   = s.dataSet.metadata.param.n_step*s.dataSet.metadata.param.n_shot;
            n_UID   = MATCHED;
            percent = 100*n_UID/n_req;
            per_str = num2str(percent,'%2.1f');
            
            s.EPICS_INDEX = EPICS_INDEX;
            if isequal(CAM_INDEX(:,1), unique(CAM_INDEX))
                s.CAM_INDEX = unique(CAM_INDEX);
            else
                warning('not all image diagnostics at all shots were saved, not handled well')
            end
            
            s.cam_idx = s.CAM_INDEX;
            s.epics_idx = s.EPICS_INDEX;
            s.cam_select = s.CAM_INDEX;
            s.epics_select = s.EPICS_INDEX;
            s.cam_sort = s.CAM_INDEX;
            s.epics_sort = s.EPICS_INDEX;
            s.include_data = 1:length(s.epics_idx)

            display([per_str '% of shots remain after UID matching']);
            
        end
        
        function type = hlpIsFVector(s, inputArg)
        %% Determines if inputArg is a FACET Scalar Array and if so, what 
        % type.
        %
        % 0 - > not a FACET Vector
        % 1 - > name of image diagnostic and a 2D - > vector function
        %
            type = 0;
            % Type 1 check image diagnostic and function
            if length(inputArg) == 2 && ischar(inputArg{1}) && ...
                    isfield(s.dataSet.images, inputArg{1}) && ...
                    isa(inputArg{2},'function_handle') && ...
                    isvector(inputArg{2}([1,2;3,4]))
                
                type = 1;
                return
            end
        
        
        end
        
        function type = hlpIsFSArray(s, inputArg, errm)
        %% Determines if inputArg is a FACET Scalar Array and if so, what 
        % type.
        %
        % 0 - > not a FACET Scalar Array
        % 1 - > name of scalar diagnostic
        % 2 - > name of image diagnostic and a 2D - > scalar function
        %

            if ischar(inputArg)
                inputArg = {inputArg};
            end
            
            if iscell(inputArg)
                % Type 1 check
                if length(inputArg) == 1 && ischar(inputArg{1}) && ...
                        isfield(s.dataSet.scalars, inputArg{1})
                    type = 1;
                    return
                elseif length(inputArg) == 1 && ischar(inputArg{1}) 
                    for k = 1:numel(s.scalarGroups)
                        if isfield(s.dataSet.scalars.(s.scalarGroups{k}), inputArg{1})
                            type = 1;
                            return
                        end
                    end
                end

                img = s.hlpGetImage(inputArg{1},1);
                % Type 2 check
                if length(inputArg) == 2 && ischar(inputArg{1}) && ...
                        isfield(s.dataSet.images, inputArg{1}) && ...
                        isa(inputArg{2},'function_handle') && ...
                        isscalar(inputArg{2}(img))

                    type = 2;
                    return
                end
                
            else
            
                type = 0;

                if exist(errm, 'var')
                    %Throw error if requested
                    error(errm)
                end
                
            end
            
            type = 0;
            
        end
        
        function [scalarArray, scalarLabel] = hlpGetScalarArray(s, ...
            FACETscalar, type, scalarGroup)
        %% hlpGetScalarArray extracts a 1D array of values from FACET data
        %  currently supports scalar diagnostics (type 1) and image
        %  diagnostics combined with a function that maps 2D - > scalar
        %  (type 2).
        
            if ischar(FACETscalar)
                FACETscalar = {FACETscalar};
            end

            if type == 1
                isSCPscalar = contains(scalarGroup,'SCP');
                if isfield(s.dataSet.scalars,(FACETscalar{1}))
                    if s.inclSCP
                        if isSCPscalar
                            scalarArray = s.dataSet.scalars.(FACETscalar{1})(s.dataSet.pulseID.common_scalar_index_SCP);
                        else
                            scalarArray = s.dataSet.scalars.(FACETscalar{1})(s.dataSet.pulseID.common_scalar_index_inclSCP);
                        end
                    else
                        scalarArray = s.dataSet.scalars.(FACETscalar{1})(s.dataSet.pulseID.common_scalar_index);
                    end
                    scalarLabel = FACETscalar{1};
                    return
                else
                    if s.inclSCP
                        if isSCPscalar
                            scalarArray = s.dataSet.scalars.(scalarGroup).(FACETscalar{1})(s.dataSet.pulseID.common_scalar_index_SCP);
                        else
                            scalarArray = s.dataSet.scalars.(scalarGroup).(FACETscalar{1})(s.dataSet.pulseID.common_scalar_index_inclSCP);
                        end
                    else
                        scalarArray = s.dataSet.scalars.(scalarGroup).(FACETscalar{1})(s.dataSet.pulseID.common_scalar_index);
                    end
                    scalarLabel = FACETscalar{1};
                    return
%                     for k = 1:numel(s.scalarGroups)
%                         if isfield(s.dataSet.scalars.(s.scalarGroups{k}),(FACETscalar{1}) )
%                             scalarArray = s.dataSet.scalars.(s.scalarGroups{k}).(FACETscalar{1})(s.dataSet.pulseID.common_scalar_index);
%                             scalarLabel = FACETscalar{1};
%                             return
%                         end
%                     end
                end
            elseif type == 2
                % Check if already calculated
                fcn = FACETscalar{2};
                fcnS = func2str(fcn);
                
                %Create an allowed field name for the struct that is kind of unique 
                fcnSN = s.fcn2fieldName(fcnS);
                
                %Check if this has been calculated before to speed up the
                %plotting
                if isfield(s.tempScalars, FACETscalar{1}) && ...
                        isfield(s.tempScalars.(FACETscalar{1}),fcnSN)
                    scalarArray = s.tempScalars.(FACETscalar{1}).(fcnSN);
                else
                    dS = getfield(s.dataSet.images,FACETscalar{1});
                    nbrOfShots = length(dS.common_index);
                    scalarArray = zeros(1,nbrOfShots);
                    if strcmp(s.imgType,'TIFF')
                        for k = 1:nbrOfShots
                            diagData = s.hlpGetImage(FACETscalar{1},dS.common_index(k));
                            scalarData = fcn(diagData);
                            scalarArray(:,k) = scalarData;
                        end
                    elseif strcmp(s.imgType,'HDF5')
                        diagData = s.hlpGetImageHDF5(FACETscalar{1});
                        diagData = diagData(:,:,dS.common_index);
                        scalarData = fcn(diagData);
                        scalarArray = squeeze(scalarData);
                    end
                end
                
                %Save if used request to plot this again
                s.tempScalars.(FACETscalar{1}).(fcnSN) = scalarArray;
                
                scalarLabel = sprintf('%s|%s',FACETscalar{1},fcnS);
            end

        end
        
        function img = hlpGetImage(s, diag, sNbr)
            if strcmp(s.imgType,'TIFF')
                img = imread(sprintf('%s%s',s.hdr,s.dataSet.images.(diag).loc{sNbr}));
            elseif strcmp(s.imgType,'HDF5')
                h5fn = sprintf('%s%s',s.hdr,s.dataSet.images.(diag).loc{1});
                imData = h5read(h5fn,'/entry/data/data');
                img = imData(:,:,sNbr);
            end
            
            if s.subtractBackground
                img = img - s.dataSet.backgrounds.(diag)';
            end
        end
        
        function img = hlpGetImageHDF5(s, diag)
            % Does the same thing as "hlpGetImage" but it returns the image
            % data for all the shots
            % This makes correlation and waterfall plots a lot faster

            img = double.empty;
            if numel(s.dataSet.images.(diag).loc) == 1
                h5fn = sprintf('%s%s',s.hdr,s.dataSet.images.(diag).loc{1});
                img = h5read(h5fn,'/entry/data/data');
            else
                for i = 1:numel(s.dataSet.images.(diag).loc)
                    h5fn = sprintf('%s%s',s.hdr,s.dataSet.images.(diag).loc{i});
                    imgData = h5read(h5fn,'/entry/data/data');
                    img = cat(3,img,imgData);
                end
            end
            s.HDF5_imData = img;
        end
        
        function [data, diagData] = hlpCheckImage(s,diag)
            
            
            % Check that diagnostic exists
            if ~isfield(s.dataSet.images,diag)
                error(sprintf('Could not find %s as an image diagnostic.',diag))
            end
            
            
            % Check that image links exist
            data = getfield(s.dataSet.images,diag);
            if isempty(data.loc)
                error(sprintf('In %s, images.%s.dat is empty',diag,diag))
            end
            
            %Find file format
%             expr = '\.[0-9a-z]+$';
%             idx = regexp(data.loc{1},expr) + 1;
            
            %Check and select method to load from file format
%             if strcmp(data.loc{1}(idx:end),'tif') || strcmp(data.loc{1}(idx:end),'tiff')
            switch s.imgType
                case 'TIFF'
                    diagData = imread( sprintf('%s%s',s.hdr,data.loc{1}) );
                case 'HDF5'
                    imData = h5read(sprintf('%s%s',s.hdr,data.loc{1}),...
                        '/entry/data/data');
                    diagData = imData(:,:,1);
                otherwise
                    error('File format not recognized for data.')
            end
            
        end
        
        function hlpGetListOfCameras(s)
            s.listOfCameras = fieldnames(s.dataSet.images);
        end
        
        function hlpFindScalarGroups(s)
            % Identifies if there are different groups in
            % data_struct.scalars, adds them to the scalarGroups variable
            
            % Find all structs in dataSet.scalar
            fieldNames = fieldnames(s.dataSet.scalars);
            n = 1;
            for k = 1:numel(fieldNames)
                if isstruct(s.dataSet.scalars.(fieldNames{k}))
                    if s.inclSCP
                        s.scalarGroups{n} = fieldNames{k};
                        n = n + 1;
                    else
                        if ~contains(fieldNames{k},'SCP')
                            s.scalarGroups{n} = fieldNames{k};
                            n = n + 1;
                        end
                    end
                end
            end
            
        end
        
        function curHandle = hlpGetFigAxis(s)
            if ~s.plotToGUI
                figure;
                curHandle = gca;
            else
                curHandle = s.GUIHandle.ImageAxes;
                curHandle.YDir = 'normal';
            end
        end
        
        function hlpPlotImage(s, plotHandle, img, type, ...
                titleS, xlabS, ylabS)
            
            % save plotData so it can be saved
            s.lastPlotData = struct(); % Make sure struct is fresh
            s.lastPlotData.type = type;
            s.lastPlotData.img = img;
            
            imagesc(plotHandle, img);
            plotHandle.XLim = [0, size(img,2)];
            plotHandle.YLim = [0, size(img,1)];
            s.hlpSetPlotLabels(plotHandle, titleS, xlabS, ylabS);
        end
        
        function hlpPlotScalarArray(s, plotHandle, data, ...
                titleS, xlabS, ylabS)
            
            type = 'Scalar Array';
            
            % save plotData so it can be saved
            s.lastPlotData = struct(); % Make sure struct is fresh
            s.lastPlotData.type = type;
            s.lastPlotData.data = data;
            
            plot(plotHandle, data, 'x');
            s.hlpSetPlotLabels(plotHandle, titleS, xlabS, ylabS);
            s.hlpAddStepTicks(plotHandle);
        end
        
        function hlpPlotTwoScalarArray(s, plotHandle, xData, yData, ...
                titleS, xlabS, ylabS)
            
            type = 'Correlation plot';
            
            % save plotData so it can be saved
            s.lastPlotData = struct(); % Make sure struct is fresh
            s.lastPlotData.type = type;
            s.lastPlotData.xData = xData;
            s.lastPlotData.yData = yData;
            
            plot(plotHandle, xData, yData, 'x');
            s.hlpSetPlotLabels(plotHandle, titleS, xlabS, ylabS);
        end
        
        function hlpPlotOverlay(s, values, index, ylab)
            curHandle = s.hlpGetFigAxis();
            hold(curHandle)
            yyaxis(curHandle,'right')
            plot(curHandle,values(index),'ro')
            yticks(curHandle,'auto')
            ylabel(curHandle,ylab)
            yyaxis(curHandle,'left')
            hold(curHandle)
        end
        
        function hlpSetPlotLabels(s, plotHandle, titleS, xlabS, ylabS)
            % Set standardized plot labels, forces labels to be set
            % Saves labels to lastPlotData
            
            s.lastPlotData.xlab = xlabS;
            s.lastPlotData.ylab = ylabS;
            s.lastPlotData.title = titleS;
            
            titleS = sprintf('%s, Dataset ID %d, %s',s.dataSet.save_info.experiment, ...
                s.dataSetID ,titleS);
            
            set(plotHandle, 'fontsize', 18);
            title(plotHandle, titleS, 'Interpreter', 'none');
            xlabel(plotHandle, xlabS, 'Interpreter', 'none');
            ylabel(plotHandle, ylabS, 'Interpreter', 'none');
            
%             % Add (approximate) step ticks
%             x_shots_ticks = plotHandle.XTick;
%             steps = s.dataSet.pulseID.steps(s.dataSet.pulseID.common_scalar_index)';
%             
%             % Manual formatting of steps ticks
%             steps_ticks = [0 steps(x_shots_ticks(2:end-1)) steps(end)];
%             labelArray = [compose('%3g',x_shots_ticks); compose('%3g',steps_ticks)];
%             tickLabels = strtrim(sprintf('%s\\newline%s\n', labelArray{:}));
%             
%             plotHandle.XTickLabel = tickLabels;
%             xlabel(plotHandle,'First row: Shot number / Second row: Step number',...
%                 'FontSize',7);
        end
        
        function hlpAddStepTicks(s,plotHandle)
            % Add (approximate) step ticks
            x_shots_ticks = plotHandle.XTick;
            if s.inclSCP
                steps = s.dataSet.pulseID.steps(s.dataSet.pulseID.common_scalar_index_inclSCP)';
            else
                steps = s.dataSet.pulseID.steps(s.dataSet.pulseID.common_scalar_index)';
            end
            
            % Manual formatting of steps ticks
            steps_ticks = [0 steps(x_shots_ticks(2:end-1)) steps(end)];
            labelArray = [compose('%3g',x_shots_ticks); compose('%3g',steps_ticks)];
            tickLabels = strtrim(sprintf('%s\\newline%s\n', labelArray{:}));
            
            plotHandle.XTickLabel = tickLabels;
            plotHandle.XTickMode = 'manual';
            xlabel(plotHandle,'First row: Shot number / Second row: Step number',...
                'FontSize',7);
        end
        
        function hlpClearPlot(s, plotHandle)
            yyaxis(plotHandle,'right')
            cla(plotHandle);
            yticks(plotHandle,[])
            yyaxis(plotHandle,'left')
            cla(plotHandle);
            
        end
        
        function fcnSN = fcn2fieldName(s, fcnS)
            % Tries to make a unique filename from a function string
            % ()+-*/':~.=@
            % LRPMTKACTDES
            
            fcnSN = strrep(fcnS,'(','L');
            fcnSN = strrep(fcnSN,')','R');
            fcnSN = strrep(fcnSN,'+','P');
            fcnSN = strrep(fcnSN,'-','M');
            fcnSN = strrep(fcnSN,'*','T');
            fcnSN = strrep(fcnSN,'/','T');
            fcnSN = strrep(fcnSN,"'",'A');
            fcnSN = strrep(fcnSN,":",'C');
            fcnSN = strrep(fcnSN,"~",'T');
            fcnSN = strrep(fcnSN,".",'D');
            fcnSN = strrep(fcnSN,"=",'E');
            fcnSN = strrep(fcnSN,"@",'S');
            
            fcnSN = fcnSN{1};
            fcnSN = fcnSN(regexp(fcnSN,'[0-9a-zA-Z]'));
            if s.subtractBackground
                fcnSN = ['B',fcnSN];
            else
                fcnSN = ['F',fcnSN];
            end
            
        end
        
        function hlpDispMsg(s,str)
            if s.plotToGUI
                s.GUIHandle.addMsg(str)
            else
                fprintf(str);
            end
        end
        
    end
end

