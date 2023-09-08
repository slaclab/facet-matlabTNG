classdef EmitSupport < handle

    
    properties
        guihan
        plotOptionState
        %a property that stores application data here
        data
        ROI
        cal
        emit
        log
    end
    

    
    properties (Constant)
        numPlotPts = 50
    end
    
    methods
        % This section contains functions that are needed to run the app
        
        function obj = EmitSupport(apphandle)
            % This is the constructor method. This function is run when
            % an instance of the class is created. Property values are
            % initialized here.
 
            
            % Associate class with GUI
            obj.guihan = apphandle;
            obj.data.dataSetID = [];
            obj.data.exp = [];
            obj.data.data_struct = [];
            obj.data.header = [];
            obj.data.cam = [];
            obj.data.ind = [];
            obj.data.ts = [];
            obj.data.title = [];
            
            % Image data
            obj.data.img = [];
            obj.data.x = [];
            obj.data.y = [];
            obj.data.xmm = [];
            obj.data.ymm = [];

            obj.ROI.img = [];
            obj.ROI.x = [];
            obj.ROI.y = [];
            obj.ROI.xmm = [];
            obj.ROI.ymm = [];
            obj.ROI.E = [];

            %Calibration data
            obj.cal.Edipole = [];
            obj.cal.dnom = [];
            obj.cal.ybeam = [];
            obj.cal.E = [];

            % Fit data
            obj.data.Efit = [];
            obj.data.sigma_x = [];
            obj.data.dsigma_x = [];
            
            % Emittance data
            obj.emit.emitn_fit = [];
            obj.emit.beta_0_fit = [];
            obj.emit.deltaz_w_fit = [];
            obj.emit.emitn_CI = [];
            obj.emit.beta_0_CI = [];
            obj.emit.deltaz_w_CI = [];
            obj.emit.text = [];

            % log data
            obj.log = [];
            

        end
        
        
        %% Update the log
        function app = updateLog(obj, app, msg)
            % add an entry to the end of the log
            t = char(datetime('now','TimeZone','local','Format','dd-MMM-yyyy HH:mm:ss'));
           % app.LogTextArea.Value = {app.LogTextArea.Value{:}, [t ': ']};
            app.LogTextArea.Value = {app.LogTextArea.Value{:}, [t ':  ' msg]};
           % app.LogTextArea.scroll('bottom');

            obj.log = app.LogTextArea.Value;
        end


        %% Aquire Data: 
        function [data_struct, header] = find_DAQ(obj, dataSetID,exp)
                [data_struct, header] = getDataSet(dataSetID, exp);
        end
        

        %% Read image data:
        function [img, x, y, res, xmm, ymm] = read_img(obj, app, data_struct, header, cam, n, isrot)

            %image data
            comIndImg  = data_struct.images.(cam).common_index;
            comIndScal = data_struct.scalars.common_index;
            imgmeta = data_struct.metadata.(cam);
            imgloc = data_struct.images.(cam).loc;
            
            res = imgmeta.RESOLUTION;
            if strcmp(cam,'DTOTR1')
                if res == 9.9
                    % Fix badly saved reolution value for DTOTR1
                    res = 3.12;
                end
            end
                        
            indImg  = comIndImg(n);  indScal = comIndScal(n);
            
                % Load the image
                imgloc = data_struct.images.(cam).loc{indImg};
                startIdx = regexp(imgloc,'[a-zA-Z0-9]{4}_\d{5}');
                fileloc = [header imgloc(startIdx+10:end)];
                
                disp(fileloc);
                
                img = uint16(imread(fileloc));
            
                % Do the background subtraction, if background image exists
                if app.SubtractBGCheckBox.Value
                    if data_struct.backgrounds.getBG==1
                        bkgd = uint16(data_struct.backgrounds.(cam));
                        
                        if size(bkgd,1)==size(img,1)
                            img = img - bkgd;
                        elseif size(bkgd,2)==size(img,1)
                            img = img - bkgd';
                        else
                            warning('Bkgd image size not the same dimensions as image file');
                        end
                    end
                end
            
                % Get ROI details
                minXROI = imgmeta.MinY_RBV;
                maxXROI = minXROI+imgmeta.ROI_SizeY_RBV-1;
                x = minXROI:maxXROI;
                minYROI = imgmeta.MinX_RBV;
                maxYROI = minYROI+imgmeta.ROI_SizeX_RBV-1;
                y = minYROI:maxYROI;
                
                % rotate image if required
                if isrot
                    img = img';
                    xold = x;
                    x = y;
                    y = xold;
                end
                xmm = x*res*1e-3;  ymm = y*res*1e-3;
                % the orientation should now be image(xpixel, ypixel), and use imagesc(x,y,img)
            
                %check orientations
                if strcmp(imgmeta.X_ORIENT, 'Negative')
                    img = flipud(img);
                end
                if strcmp(imgmeta.Y_ORIENT, 'Negative')
                    img = fliplr(img);
                end
         
            obj.data.img = img;
            obj.data.x = x;
            obj.data.y = y;
            obj.data.xmm = xmm;
            obj.data.ymm = ymm;

        end 

        %% Read image data from profmon:
        function [img, x, y, res, xmm, ymm] = read_profmon(obj, app, profmondata)

         
            img = uint16(profmondata.img);
            
            res = profmondata.res;
            if strcmp(obj.data.cam,'DTOTR1')
                if res == 9.9
                    % Fix badly saved reolution value for DTOTR1
                    res = 3.12;
                end
            end
            

                % Get ROI details
                minXROI = profmondata.roiX;
                maxXROI = minXROI+profmondata.roiXN-1;
                y = minXROI:maxXROI;
                minYROI = profmondata.roiY;
                maxYROI = minYROI+profmondata.roiYN-1;
                x = minYROI:maxYROI;
                
                % rotate image if required
                if profmondata.isRot
                    img = img';
                    xold = x;
                    x = y;
                    y = xold;
                end
                xmm = x*res*1e-3;  ymm = y*res*1e-3;
                % the orientation should now be image(xpixel, ypixel), and use imagesc(x,y,img)
            
                %check orientations
                if profmondata.orientX
                    img = flipud(img);
                end
                if profmondata.orientY
                    img = fliplr(img);
                end
         
            obj.data.img = img;
            obj.data.x = x;
            obj.data.y = y;
            obj.data.xmm = xmm;
            obj.data.ymm = ymm;
            obj.data.ts = datestr(profmondata.ts);
        end 
        
        
        %% Plot image:
        function plot_img(obj, app)

            yyaxis(app.UIAxes, 'left')
            imagesc(app.UIAxes, obj.data.xmm, obj.data.ymm, obj.data.img', 'HitTest', 'off');
            axis(app.UIAxes, 'tight')
            
            %Set the axis in the right direction
            set(app.UIAxes, 'YDir', 'normal');

            if app.LockROICheckBox.Value

                try
                    % set limits
                    xlim(app.UIAxes, [min(obj.ROI.xmm) max(obj.ROI.xmm)]); 
                    ylim(app.UIAxes, [min(obj.ROI.ymm) max(obj.ROI.ymm)]); 
                catch
                    % send a messsage
                    updateLog(obj, app, 'No ROI saved');
                end

            end
            
        end 

        %% Do energy calibration
        function E = cal_Energy(obj, app, ymm);
            
            % If ymm value is not supplied, then pull the whole y axis data
            if nargin==2
                ymm = obj.data.ymm;
            end

            Edipole = app.DipoleGeVEditField.Value;
            dnom    = app.NominalDispersionmmEditField.Value;
            ybeam   = app.GeVBeamPositionmmEditField.Value;

            dy_mm = dnom*Edipole/10-ybeam;  %distance (mm) from inf energy axis to the lowest pixel of camera
                        
            E = abs(dnom*Edipole./(ymm+dy_mm));
            
            % Save stuff
            obj.cal.Edipole = app.DipoleGeVEditField.Value;
            obj.cal.dnom    = app.NominalDispersionmmEditField.Value;
            obj.cal.ybeam   = app.GeVBeamPositionmmEditField.Value;

            % only update if calculating for the whole axis
            if nargin==2
                obj.cal.E = E;
            end
        end

        %% Add energy axis
        function app = add_EnergyAxis(obj, app, axes, axis, axisnum)

            if ~exist('axisnum')
                axisnum = 1;
            end
            
            ticks = app.(axes).(axis)(axisnum).TickValues;
            Emin = cal_Energy(obj, app, ticks(1));
            Emax = cal_Energy(obj, app, ticks(end));
            dE = Emax - Emin;

            nticks = length(ticks);% app.EnergyAxisTicksEditField.Value
            
            Eticks = linspace(Emin, Emax, nticks);
            if dE<0.1;   dec = 0.01;
            elseif dE<0.5;  dec = 0.025;    
            elseif dE<1;  dec = 0.1;
            elseif dE<5;  dec = 0.5;
            else;         dec = 1;
            end

            EticksPlot = unique(round(Eticks/dec)*dec);
            if length(EticksPlot)<3
                EticksPlot = Eticks;
            end

            ytiks = interp1(obj.cal.E, obj.data.ymm, EticksPlot);
%             if ytiks(1)>ytiks(end)
%                 ytiks = fliplr(ytiks)
%                 EticksPlot = fliplr(EticksPlot);
%             end

            app.(axes).(axis)(axisnum).TickValues = ytiks(~isnan(ytiks));
            app.(axes).(axis)(axisnum).TickLabels = EticksPlot(~isnan(ytiks));

            app.(axes).(axis)(axisnum).Label.String = 'Energy [GeV]';
            app.(axes).(axis)(axisnum).Visible = 'on';
            yyaxis(app.UIAxes, 'left');


        end

        %% Remove energy Axis
        function app = remove_EnergyAxis(obj, app, axes, axis, axisnum)

            app.(axes).(axis)(axisnum).Visible = 'off';
            app.(axes).(axis)(axisnum).TickLabelsMode = 'auto';
            app.(axes).(axis)(axisnum).TickValuesMode = 'auto';
            app.(axes).(axis)(axisnum).Label.String = 'y position [mm]';
        end

        %% Get smaller ROI

        function app = get_ROI(obj, app)
            
            % Get the limits of the the axis, and convert to indices
            xlmm = xlim(app.UIAxes(1));
            ylmm = ylim(app.UIAxes(1));
            xl = round(interp1(obj.data.xmm, obj.data.x, xlmm, 'linear', 'extrap'));
            yl = round(interp1(obj.data.ymm, obj.data.y, ylmm, 'linear', 'extrap'));
            xl(1) = max(xl(1), obj.data.x(1));   yl(1) = max(yl(1), obj.data.y(1));
            xl(2) = min(xl(2), obj.data.x(end)); yl(2) = min(yl(2), obj.data.y(end));
            
            % Convert to pixel values
            ix = find(obj.data.x==xl(1)) : find(obj.data.x==xl(2));
            iy = find(obj.data.y==yl(1)) : find(obj.data.y==yl(2));
            
            % Save new ROI data
            obj.ROI.x = obj.data.x(ix); obj.ROI.xmm = obj.data.xmm(ix);
            obj.ROI.y = obj.data.y(iy); obj.ROI.ymm = obj.data.ymm(iy);
            obj.ROI.img = obj.data.img(ix,iy);
            
        end

        %% Set z locations
        function z = set_Z(obj, app, dropdown)

            ele = app.(dropdown).Value;

            switch ele
                case 'DTOTR1'
                    z = 2.015259850655461e+03;
                case 'DTOTR2'
                    z = 2.015259850655461e+03;
                case 'LFOV'
                    z = 2.015629843995481e+03;
                case 'CHER'
                    z = 2.016220001372488e+03;
                case 'PRDMP'
                    z = 2.017529977792559e+03;
                case 'EDC_SCREEN'
                    z = 2.010499937335186e+03;
                case 'PIC_CENT'
                    z = 1.992820001379069e+03;
                case 'FILS'
                    z = 1.993273701379069e+03;
                case 'FILG'
                    z = 1.993221701379069e+03;
                case 'IPWS1'
                    z = 1.993910001379069e+03;
                case 'PENT'
                    z = 1.993870001379069e+03;
                case 'PEXT'
                    z = 1.995040001379069e+03;
                case 'DSBeWIN'
                    z = 1.996100001379069e+03;
                otherwise
                    z = 0;                
            end


                

        end

        %% Calculate the transport matrices
        function [M11 M12] = calc_TransportMatrix(obj, app, E)

            zob = app.zobEditField.Value;
            zim = app.zimEditField.Value;
            PS_Q0D = app.Q0DkGEditField.Value;
            PS_Q1D = app.Q1DkGEditField.Value;
            PS_Q2D = app.Q2DkGEditField.Value;


            % Define magnet positions
            zQ0D = 1996.98244;
            zQ1D = 1999.20656;
            zQ2D = 2001.43099;
            
            load 'SpecBeamline.mat'
            

            % Find where everything is
            Q0D =findcells(BEAMLINE,'Name','Q0D');
            Q1D =findcells(BEAMLINE,'Name','Q1D');
            Q2D =findcells(BEAMLINE,'Name','Q2D');
            
            % Adjust the positions of things, and set magnet strengths
            BEAMLINE{1} = BEAMLINE{Q0D(1)-2}; BEAMLINE{1}.S = zob;
            
            BEAMLINE{2} = BEAMLINE{Q0D(1)-1};  BEAMLINE{2}.L = zQ0D-zob - 0.5;
            BEAMLINE{3} = BEAMLINE{Q0D(1)};    BEAMLINE{3}.B = PS_Q0D/10/2;
            BEAMLINE{4} = BEAMLINE{Q0D(2)};    BEAMLINE{4}.B = PS_Q0D/10/2;
            
            BEAMLINE{5} = BEAMLINE{Q1D(1)-1};  BEAMLINE{5}.L = zQ1D- zQ0D - 1;
            BEAMLINE{6} = BEAMLINE{Q1D(1)};    BEAMLINE{6}.B = PS_Q1D/10/2;
            BEAMLINE{7} = BEAMLINE{Q1D(2)};    BEAMLINE{7}.B = PS_Q1D/10/2;
            
            BEAMLINE{8} = BEAMLINE{Q2D(1)-1};  BEAMLINE{8}.L = zQ2D - zQ1D - 1;
            BEAMLINE{9} = BEAMLINE{Q2D(1)};    BEAMLINE{9}.B = PS_Q2D/10/2;
            BEAMLINE{10} = BEAMLINE{Q2D(2)};   BEAMLINE{10}.B = PS_Q2D/10/2;
            
            BEAMLINE{11} = BEAMLINE{Q2D(2)+1}; BEAMLINE{11}.L = zim - zQ2D - 0.5;
            BEAMLINE{12} = BEAMLINE{Q2D(2)+2}; 
            
            % Fix all S positions
            SetSPositions( 1, length(BEAMLINE),  BEAMLINE{1}.S);
            

            for iE = 1:length(E)
                % Set the energy of each element
                for i =1:length(BEAMLINE)
                    BEAMLINE{i}.P = E(iE);
                end
            
                % Calculate the transport matrix
                [~,M]=RmatAtoB(1, length(BEAMLINE));

                M11(iE) = M(1,1);
                M12(iE) = M(1,2);
            end
        
        end

        %% Calculate beam widths for a set of inputs
        function sigma_x = calc_BeamWidth(obj, app, params, E, M11, M12)
            % E, M11, M12 can be a vectors
            % returns beam width in µm

            emitn    = params(1);
            beta_w   = params(2);
            deltaz_w = -params(3);  % positive z means further downstream

            alpha_w = 0;  % at the waist
            gammaT = (1+alpha_w^2)/beta_w; % constant

             % Translate this to the object plane
            beta_0  = beta_w -2*deltaz_w*alpha_w + deltaz_w^2*gammaT
            alpha_0 = alpha_w - deltaz_w*gammaT
            
            masse = 0.511/1000;
            gamma = sqrt(1 + (E/masse).^2);


            sigma_x = sqrt( emitn./gamma.*( M11.^2*beta_0 - 2*M11.*M12*alpha_0 + M12.^2*(1+alpha_0^2)/beta_0 ) )*1e6;
            

        end

        
        %% Do the emittance fit
        function [params_fit, params_CIs, sigma_x_fit, sigma_x_lower_bound, sigma_x_upper_bound] = fit_emittance(obj, app, E, sigma_x_data, dsigma_x, M11, M12, initial_guess)

            % Perform a linear regression fit

            % Define a weighting function
            %weights = 1./dsigma_x;

            % estimate errors
            perc = .01;
            uncertainty_E   = 0.1*perc;
            uncertainty_M11 = 5*perc;
            uncertainty_M12 = 5*perc;
            uncertainty_sigx = dsigma_x./sigma_x_data;
            weights = 1 ./ ( sqrt(uncertainty_E.^2 + uncertainty_M12.^2 + uncertainty_M12.^2 + uncertainty_sigx.^2) .* sigma_x_data);

            % Define the objective function for lsqnonlin
            objective_function = @(params) (sigma_x_data - calc_BeamWidth(obj, app, params, E, M11, M12)).* weights;
           

            % Set options for lsqnonlin
            options = optimoptions('lsqnonlin', 'Display', 'iter', 'MaxIterations', 500);

            % Perform the nonlinear regression
            [params_fit,~,R,~,~,~,J] = lsqnonlin(objective_function, initial_guess, [], [], options);

            % Compute the cinfidence intervals
            params_CIs = nlparci(params_fit,R,'jacobian',J);

            % Extract the fitted parameters
            emitn_fit = params_fit(1);
            beta_0_fit = params_fit(2);
            deltaz_w_fit = params_fit(3);
             
%             % Compute the covariance matrix
%             covariance_matrix = inv(J' * J);
%             
%             % Calculate standard errors (square root of diagonal elements)
%             standard_errors = sqrt(diag(covariance_matrix));
%             emitn_std_error = standard_errors(1)+0;
%             beta_0_std_error = standard_errors(2)+0;
%             deltaz_w_std_error = standard_errors(3)+0;
%             params_std_error = [emitn_std_error beta_0_std_error deltaz_w_std_error];
%             
%             
%             % Calculate upper and lower bounds for each parameter
%             emitn_upper_bound = emitn_fit + emitn_std_error;
%             emitn_lower_bound = emitn_fit - emitn_std_error;
%             beta_0_upper_bound = beta_0_fit + beta_0_std_error;
%             beta_0_lower_bound = beta_0_fit - beta_0_std_error;
%             deltaz_w_upper_bound = deltaz_w_fit + deltaz_w_std_error;
%             deltaz_w_lower_bound = deltaz_w_fit - deltaz_w_std_error;
            
            
            % Calculate the fit function and upper/lower bounds
            sigma_x_fit = calc_BeamWidth(obj, app, params_fit, E, M11, M12);
            
            % Calculate upper and lower bounds for sigma_x
%             sigma_x_upper_bound = calc_BeamWidth(obj, app, [emitn_upper_bound, beta_0_upper_bound, deltaz_w_upper_bound], E, M11, M12);
%             sigma_x_lower_bound = calc_BeamWidth(obj, app, [emitn_lower_bound, beta_0_lower_bound, deltaz_w_lower_bound], E, M11, M12);
            sigma_x_upper_bound = calc_BeamWidth(obj, app, params_CIs(:,2), E, M11, M12);
            sigma_x_lower_bound = calc_BeamWidth(obj, app, params_CIs(:,1), E, M11, M12);
            
            
            % Update values on app
            app.FitEmittanceEditField.Value = emitn_fit*1e6;  app.EmitCIEditField.Value = sprintf('(%.3g, %.3g)', params_CIs(1,1)*1e6, params_CIs(1,2)*1e6);
            app.FitWaistBetaEditField.Value = beta_0_fit*100; app.BetaCIEditField.Value = sprintf('(%.3g, %.3g)', params_CIs(2,1)*100, params_CIs(2,2)*100); 
            app.FitWaistOffsetEditField.Value = deltaz_w_fit; app.OffsetCIEditField.Value = sprintf('(%.3g, %.3g)', params_CIs(3,1), params_CIs(3,2));
            
            % Calculate R-squared
            residuals = sigma_x_data - sigma_x_fit;
            sigma_x_mean = mean(sigma_x_data);
            ss_total = sum((sigma_x_data - sigma_x_mean).^2); % Total sum of squares
            ss_residual = sum(residuals.^2); % Residual sum of squares
            r_squared = 1 - (ss_residual / ss_total); % R-squared value
            
            app.RsquaredEditField.Value = r_squared;

            obj.emit.emitn_fit = emitn_fit;
            obj.emit.beta_0_fit = beta_0_fit;
            obj.emit.deltaz_w_fit = deltaz_w_fit;

            obj.emit.emitn_CI = params_CIs(1,:);
            obj.emit.beta_0_CI = params_CIs(2,:);
            obj.emit.deltaz_w_CI = params_CIs(3,:);

        end

        %% fit the gaussian beam width
        function [params_fit, params_MOE, y_fit, y_lower, y_upper] = fit_guass(obj, app, x,y)

            % Define the Gaussian function with an offset
            gaussianWithOffset = @(params, x) params(1) * exp(-(x - params(2)).^2 / (2 * params(3)^2)) + params(4);
            
            % Define the objective function
            objective_function = @(params) (y - gaussianWithOffset(params,x));

            % Initial guess for the parameters:
            %            [amplitude, mean, standard deviation, offset]
            initialGuess = [max(y), mean(x), (max(x)-min(x))/5, min(y)];

            % Bounds
            lowerbounds = [0         -1000 0 -1e4];
            upperbounds = [10*max(y)  1000 1000 1e4];

            % Set options for lsqnonlin
            options = optimoptions('lsqnonlin', 'Display', 'iter', 'MaxIterations', 500);
            options.Display = 'off';

            % Perform the nonlinear regression
            [params_fit,~,R,~,~,~,J] = lsqnonlin(objective_function, initialGuess, lowerbounds, upperbounds, options);
            
            paramCIs = nlparci(params_fit,R,'jacobian',J);
            
            % Extract the fitted parameters and confidence intervals
            amplitude = params_fit(1);
            meanValue = params_fit(2);
            standardDeviation = params_fit(3);
            offset = params_fit(4);
            
            % Calculate upper and lower bounds for the parameters
            amplitudeCI = paramCIs(1,:);
            meanCI = paramCIs(2,:);
            stdDevCI = paramCIs(3,:);
            offsetCI = paramCIs(4,:);

            % Calculate the margin of error
            params_MOE = [diff(amplitudeCI) diff(meanCI) diff(stdDevCI) diff(offsetCI)];
            
            % Calculate the fitted y values
            y_fit = gaussianWithOffset(params_fit, x);                   

            % Calculate the upper and lower bounds for the fitted Gaussian curve
            y_upper = gaussianWithOffset(paramCIs(:, 2), x); % Upper bound
            y_lower = gaussianWithOffset(paramCIs(:, 1), x); % Lower bound

%    plot(x,y,x, y_fit, x, y_upper, x, y_lower)

        end

        %% Copy a figure axes to a new one
        function copy_plot(obj,app, axnew, axold)

            copyobj(axold.Children, axnew);


         %   axnewParams = get(axold);
            
         %   params = {'XLim', 'YLim', 'XLabel', 'YLabel'}

         %   for i = 1:length(params)
         %       set(axnew, params{i}, axnewParams.(params{i}))
         %   end

            axnew.XLim = axold.XLim;
            axnew.YLim = axold.YLim;
            axnew.XLabel.String = axold.XLabel.String;
            axnew.YLabel.String = axold.YLabel.String;
            
            if length(axold.YAxis) == 2
                yyaxis right
                axnew.YLim = axold.YAxis(2).Limits;
                axnew.YTick = axold.YAxis(2).TickValues;
                axnew.YTickLabel = axold.YAxis(2).TickLabels;
                axnew.YLabel.String = axold.YAxis(2).Label.String;
                yyaxis left
            end


        end

        %% add a legend to the emittance plot
        function add_legendEmit(obj, app, ax, plothandles)

            ph = []; legendtext = {};

            if isfield(plothandles, 'DataPlot')
                ph(end+1) = plothandles.DataPlot;
                legendtext{end+1} = 'Data';
            end

            if isfield(plothandles, 'FitPlot')
                ph(end+1) = plothandles.FitPlot;
                legendtext{end+1} = 'Emittance fit';
            end

            if isfield(plothandles, 'BoundPlot')
                ph(end+1) = plothandles.BoundPlot;
                legendtext{end+1} = 'Fit bounds';
            end

            if isfield(plothandles, 'DesiredPlot')
                ph(end+1) = plothandles.DesiredPlot;
                legendtext{end+1} = 'Desired emittance';
            end

            legend(ax, ph, legendtext);

        end


    end
    
    
end