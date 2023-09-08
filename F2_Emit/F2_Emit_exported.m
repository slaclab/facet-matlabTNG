classdef F2_Emit_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        UIAxes                          matlab.ui.control.UIAxes
        UIAxes2                         matlab.ui.control.UIAxes
        UIAxes3                         matlab.ui.control.UIAxes
        SpectrometerSettingsPanel       matlab.ui.container.Panel
        DipoleGeVEditFieldLabel         matlab.ui.control.Label
        DipoleGeVEditField              matlab.ui.control.NumericEditField
        AutoPopulateButton              matlab.ui.control.Button
        Q0DkGEditFieldLabel             matlab.ui.control.Label
        Q0DkGEditField                  matlab.ui.control.NumericEditField
        Q1DkGEditFieldLabel             matlab.ui.control.Label
        Q1DkGEditField                  matlab.ui.control.NumericEditField
        Q2DkGEditFieldLabel             matlab.ui.control.Label
        Q2DkGEditField                  matlab.ui.control.NumericEditField
        ObjectPlaneDropDownLabel        matlab.ui.control.Label
        ObjectPlaneDropDown             matlab.ui.control.DropDown
        zobEditField                    matlab.ui.control.NumericEditField
        ImagePlaneDropDownLabel         matlab.ui.control.Label
        ImagePlaneDropDown              matlab.ui.control.DropDown
        zimEditField                    matlab.ui.control.NumericEditField
        EnergyCalibrationPanel          matlab.ui.container.Panel
        NominalDispersionmmEditFieldLabel  matlab.ui.control.Label
        NominalDispersionmmEditField    matlab.ui.control.NumericEditField
        GeVBeamPositionmmEditFieldLabel  matlab.ui.control.Label
        GeVBeamPositionmmEditField      matlab.ui.control.NumericEditField
        CentroidButton                  matlab.ui.control.Button
        ToggleECalButton                matlab.ui.control.StateButton
        ChargePlotButton                matlab.ui.control.Button
        PlotTransportMatrixButton       matlab.ui.control.Button
        BeamWidthPlotSettingsPanel      matlab.ui.container.Panel
        PlotBeamWidthsButton            matlab.ui.control.Button
        PlotfitCheckBox                 matlab.ui.control.CheckBox
        FittypeButtonGroup              matlab.ui.container.ButtonGroup
        Method1Button                   matlab.ui.control.RadioButton
        Method2Button                   matlab.ui.control.RadioButton
        EmittancePanel                  matlab.ui.container.Panel
        DesiredEmittanceEditFieldLabel  matlab.ui.control.Label
        DesiredEmittanceEditField       matlab.ui.control.NumericEditField
        mLabel                          matlab.ui.control.Label
        DesiredBetaEditFieldLabel       matlab.ui.control.Label
        DesiredBetaEditField            matlab.ui.control.NumericEditField
        cmLabel                         matlab.ui.control.Label
        DesiredWaistOffsetEditFieldLabel  matlab.ui.control.Label
        DesiredWaistOffsetEditField     matlab.ui.control.NumericEditField
        mLabel_4                        matlab.ui.control.Label
        PlotDesiredButton               matlab.ui.control.StateButton
        DoFitButton                     matlab.ui.control.Button
        FitEmittanceEditFieldLabel      matlab.ui.control.Label
        FitEmittanceEditField           matlab.ui.control.NumericEditField
        mLabel_2                        matlab.ui.control.Label
        EmitCIEditField                 matlab.ui.control.EditField
        FitWaistBetaEditField_3Label    matlab.ui.control.Label
        FitWaistBetaEditField           matlab.ui.control.NumericEditField
        cmLabel_2                       matlab.ui.control.Label
        BetaCIEditField                 matlab.ui.control.EditField
        FitWaistOffsetEditFieldLabel    matlab.ui.control.Label
        FitWaistOffsetEditField         matlab.ui.control.NumericEditField
        mLabel_3                        matlab.ui.control.Label
        OffsetCIEditField               matlab.ui.control.EditField
        RsquaredEditFieldLabel          matlab.ui.control.Label
        RsquaredEditField               matlab.ui.control.NumericEditField
        TabGroup                        matlab.ui.container.TabGroup
        DAQDataTab                      matlab.ui.container.Tab
        SelectDataSetLabel              matlab.ui.control.Label
        ExperimentLabel                 matlab.ui.control.Label
        expDropDown                     matlab.ui.control.DropDown
        dataSetVal                      matlab.ui.control.NumericEditField
        LoadDataSetButton               matlab.ui.control.Button
        SelectCameraDropDownLabel       matlab.ui.control.Label
        SelectCameraDropDown            matlab.ui.control.DropDown
        RotatedCheckBox                 matlab.ui.control.CheckBox
        SubtractBGCheckBox              matlab.ui.control.CheckBox
        SelectImageEditFieldLabel       matlab.ui.control.Label
        SelectImageEditField            matlab.ui.control.NumericEditField
        NextButton                      matlab.ui.control.Button
        PlotButton                      matlab.ui.control.Button
        PlotandAnalyzeButton            matlab.ui.control.Button
        LiveDataTab                     matlab.ui.container.Tab
        CameraDropDown_2Label           matlab.ui.control.Label
        CameraDropDown_2                matlab.ui.control.DropDown
        AcquireButton                   matlab.ui.control.Button
        AcquireandAnalyzeButton         matlab.ui.control.Button
        PVEditFieldLabel                matlab.ui.control.Label
        PVEditField                     matlab.ui.control.EditField
        LogTextAreaLabel                matlab.ui.control.Label
        LogTextArea                     matlab.ui.control.TextArea
        ResetButton                     matlab.ui.control.Button
        PrinttologbookButton            matlab.ui.control.Button
        LockROICheckBox                 matlab.ui.control.CheckBox
        DataSetInfoTextAreaLabel        matlab.ui.control.Label
        DataSetInfoTextArea             matlab.ui.control.TextArea
        ManualClimLabel                 matlab.ui.control.Label
        ClimCheckBox                    matlab.ui.control.CheckBox
        ClimLoEditField                 matlab.ui.control.NumericEditField
        ClimHiEditField                 matlab.ui.control.NumericEditField
    end

    
    properties (Access = private)
        aobj % Description
        yOut % Description
        plots
    end
    
    methods (Access = private)

     

    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.aobj = EmitSupport(app);
            zoom(app.UIAxes,'on');
            addpath('../');
            LucretiaInit('/usr/local/facet/tools/Lucretia');
            
        end

        % Value changed function: expDropDown
        function expDropDownValueChanged(app, event)
            value = app.expDropDown.Value;
            app.aobj.data.exp = value;
        end

        % Value changed function: dataSetVal
        function dataSetValValueChanged(app, event)
            value = app.dataSetVal.Value;
            app.aobj.data.dataSetID = value;
        end

        % Button pushed function: LoadDataSetButton
        function LoadDataSetButtonPushed(app, event)
            exp = app.expDropDown.Value;
            dataSetID = app.dataSetVal.Value;
            try
                updateLog(app.aobj, app, sprintf('Looking for data set %s_%05d...', exp, dataSetID));
             
                [data_struct, header] = find_DAQ(app.aobj, dataSetID, exp);
                updateLog(app.aobj, app, 'Data set successfully loaded.');
                                
                %Load Cameras:
                Cams = fieldnames(data_struct.images);

                iStr = sprintf('Experiment %s, DataSetID = %d \n', ...
                    data_struct.save_info.experiment, data_struct.save_info.instance);
                tStr = sprintf('Obtained %s \n', ...
                    datestr(data_struct.save_info.local_time));
                cStr = sprintf('Comment: %s \n', ...
                    (data_struct.params.comment{1}));
                dStr = sprintf('Nbr of Cams: %d \n', ...
                    (data_struct.params.num_CAM));
                nStr = sprintf('Nbr of shots: %d steps x %d shots \n', ...
                    data_struct.params.totalSteps, data_struct.params.n_shot);
                info = sprintf('%s %s %s %s %s', iStr, tStr, cStr, dStr, nStr);

                app.DataSetInfoTextArea.Value = info;
                app.SelectCameraDropDown.Items = Cams;

                % Set the camera to a default spectrometer camera is available
                defCams = {'DTOTR2', 'LFOV', 'CHER','DTOTR1'};
                idefCams = find(contains(Cams, defCams));
                if ~isempty(idefCams)
                    app.SelectCameraDropDown.Value = Cams(idefCams(1));
                    SelectCameraDropDownValueChanged(app);
                end

                app.aobj.data.exp = exp;
                app.aobj.data.dataSetID = dataSetID;
                app.aobj.data.data_struct = data_struct;
                app.aobj.data.header = header;

                if data_struct.backgrounds.getBG==1
                    app.SubtractBGCheckBox.Value=1;
                else
                    app.SubtractBGCheckBox.Value=0;
                end
                
                app.AutoPopulateButton.Visible = 'on';

            catch 
                updateLog(app.aobj, app, 'Data set not found.');
                app.DataSetInfoTextArea.Value = '';
            end
             
              
            
        end

        % Value changed function: SelectCameraDropDown
        function SelectCameraDropDownValueChanged(app, event)
            value = app.SelectCameraDropDown.Value;
            
            switch value
                case 'LFOV'
                    app.NominalDispersionmmEditField.Value = -58.1;
                    app.GeVBeamPositionmmEditField.Value = 80;
                    app.RotatedCheckBox.Value = 0;
                    msg = sprintf('For selected camera; dnom = %.1fmm, 10 GeV Beam Position = %.2f mm',...
                        app.NominalDispersionmmEditField.Value, app.GeVBeamPositionmmEditField.Value);
                  
                case 'DTOTR1'
                    app.NominalDispersionmmEditField.Value = -55.9;
                    app.GeVBeamPositionmmEditField.Value = 3;
                    app.RotatedCheckBox.Value = 0;
                    msg = sprintf('For selected camera; dnom = %.1fmm, 10 GeV Beam Position = %.2f mm',...
                        app.NominalDispersionmmEditField.Value, app.GeVBeamPositionmmEditField.Value);
                    
                case 'DTOTR2' 
                    app.NominalDispersionmmEditField.Value = -55.9;
                    app.GeVBeamPositionmmEditField.Value = 16.5;
                    app.RotatedCheckBox.Value = 0;
                    msg = sprintf('For selected camera; dnom = %.1fmm, 10 GeV Beam Position = %.2f mm',...
                        app.NominalDispersionmmEditField.Value, app.GeVBeamPositionmmEditField.Value);
                    
                case 'CHER'
                    app.NominalDispersionmmEditField.Value = -61.7;
                    app.GeVBeamPositionmmEditField.Value = 50;
                    app.RotatedCheckBox.Value = 0;
                    msg = sprintf('For selected camera; dnom = %.1fmm, 10 GeV Beam Position = %.2f mm',...
                        app.NominalDispersionmmEditField.Value, app.GeVBeamPositionmmEditField.Value);
                    
                case 'PRDMP'
                    app.NominalDispersionmmEditField.Value = -69.5;
                    app.GeVBeamPositionmmEditField.Value = 60;
                    app.RotatedCheckBox.Value = 0;
                    msg = sprintf('For selected camera; dnom = %.1fmm, 10 GeV Beam Position = %.2f mm',...
                        app.NominalDispersionmmEditField.Value, app.GeVBeamPositionmmEditField.Value);
                   
                otherwise
                    msg = 'For selected camera; Unknown calibration';
            end
            updateLog(app.aobj, app, msg);
            
        end

        % Button pushed function: PlotButton
        function PlotButtonPushed(app, event)

            exp = app.aobj.data.data_struct.save_info.experiment;
            dataSetID = app.aobj.data.data_struct.save_info.instance;
            cam = app.SelectCameraDropDown.Value;
            ind = app.SelectImageEditField.Value;

            app.aobj.data.cam = cam;
            app.aobj.data.ind = ind;

            if app.RotatedCheckBox.Value == 1
                isrot = 1;
            elseif app.RotatedCheckBox.Value == 0 
                isrot = 0;
            end

            try
                % Read the file
                read_img(app.aobj, app, app.aobj.data.data_struct, app.aobj.data.header, cam, ind, isrot);

                app.aobj.data.titletext = sprintf('DAQ %s\\_%05d, cam: %s, Index: %d', exp, dataSetID, cam, ind);
                app.UIAxes.Title.String = app.aobj.data.titletext; 
                
                %Plot it
                plot_img(app.aobj, app);
                
                if app.ClimCheckBox.Value
                    caxis(app.UIAxes, [app.ClimLoEditField.Value app.ClimHiEditField.Value])
                else
                    app.UIAxes.CLimMode = 'auto';
                    cl = caxis(app.UIAxes);
                    app.ClimLoEditField.Value = cl(1);
                    app.ClimHiEditField.Value = cl(2);
                end

                app.ToggleECalButton.Value = 0;
                remove_EnergyAxis(app.aobj, app, 'UIAxes', 'YAxis', 2);
               
            catch
                msg = 'Error plotting image';
                updateLog(app.aobj, app, msg);
            end
            
        end

        % Button pushed function: AcquireButton
        function AcquireButtonPushed(app, event)
            
            exp = [];
            dataSetID = 'Live';
            cam = app.CameraDropDown_2.Value;
            ind = [];

            app.aobj.data.dataSetID = dataSetID;
            app.aobj.data.cam = cam;
            app.aobj.data.ind = ind;

            campv = app.PVEditField.Value;
            
            
            quadpvs.dipole = 'LI20:LGPS:3330:BACT';
            quadpvs.Q0D    = 'LI20:LGPS:3141:BACT';
            quadpvs.Q1D    = 'LI20:LGPS:3261:BACT';
            quadpvs.Q2D    = 'LI20:LGPS:3091:BACT';

            try
                % acquire a shot
                profmondata = profmon_grab(campv);
            catch
                updateLog(app.aobj, app, 'Error acquiring image');
            end

            try
                pvdata = lcaGetStruct(quadpvs, 0, 'double');
            catch
                updateLog(app.aobj, app, 'Error acquiring magnet values');
            end

            try
                % parse the profmon data
                read_profmon(app.aobj, app, profmondata);
              
                
                %Plot it
                plot_img(app.aobj, app);                
                
                app.aobj.data.titletext = sprintf('ProfMon %s %s %s', campv, cam, app.aobj.data.ts)
                app.UIAxes.Title.String = app.aobj.data.titletext;
                
                dataInfo = {sprintf('ProfMon %s %s\nAcquired: %s', campv, cam, app.aobj.data.ts)}
                
                if app.ClimCheckBox.Value
                    caxis(app.UIAxes, [app.ClimLoEditField.Value app.ClimHiEditField.Value])
                else
                    app.UIAxes.CLimMode = 'auto';
                    cl = caxis(app.UIAxes);
                    app.ClimLoEditField.Value = cl(1);
                    app.ClimHiEditField.Value = cl(2);
                end

                app.ToggleECalButton.Value = 0;
                remove_EnergyAxis(app.aobj, app, 'UIAxes', 'YAxis', 2);
               
            catch
                updateLog(app.aobj, app, 'Error plotting image');
            end

            try
                app.DipoleGeVEditField.Value = pvdata.dipole
                app.Q0DkGEditField.Value = pvdata.Q0D
                app.Q1DkGEditField.Value = pvdata.Q1D
                app.Q2DkGEditField.Value = pvdata.Q2D
            catch
                updateLog(app.aobj, app, 'Error setting magnet values in app');
            end

            % Set the planes
            try
                app.ImagePlaneDropDown.Value = cam;
                ImagePlaneDropDownValueChanged(app);
            catch
                app.ImagePlaneDropDown.Value = 'Select';
            end

            app.ObjectPlaneDropDown.Value = 'IPWS1';
            ObjectPlaneDropDownValueChanged(app);
            
            app.AutoPopulateButton.Visible = 'off';  
            
            app.DataSetInfoTextArea.Value = dataInfo;

        end

        % Value changed function: CameraDropDown_2
        function CameraDropDown_2ValueChanged(app, event)
            value = app.CameraDropDown_2.Value;
            
            switch value
                case 'DTOTR2'; app.PVEditField.Value = 'CAMR:LI20:107';
                case 'DTOTR1'; app.PVEditField.Value = 'CMOS:LI20:3505';
                case 'LFOV';   app.PVEditField.Value = 'CAMR:LI20:301';
                case 'CHER';   app.PVEditField.Value = 'CAMR:LI20:308';
                case 'PRDMP';  app.PVEditField.Value = 'CAMR:LI20:108';
                case 'EDC_SCREEN'; app.PVEditField.Value = 'CAMR:LI20:309';
                case 'Other';  app.PVEditField.Value = '';                
            end

            % Use the old function to update things
            app.SelectCameraDropDown.Items = {value};
            app.SelectCameraDropDown.Value = value;
            SelectCameraDropDownValueChanged(app);
        end

        % Button pushed function: PlotandAnalyzeButton
        function PlotandAnalyzeButtonPushed(app, event)
            
            updateLog(app.aobj, app, 'Doing analysis with default settings');

            % Press the plot button
            PlotButtonPushed(app);
            % Check if ROI button is pressed

            % Autopopulate magnet values
            AutoPopulateButtonPushed(app);
            % Toggle Ecal and press energy cal button
            app.ToggleECalButton.Value = 1;
            ToggleECalButtonValueChanged(app);
            ChargePlotButtonPushed(app);
            % Plot beam widths
            PlotBeamWidthsButtonPushed(app);
            % Do fit
            DoFitButtonPushed(app);

        end

        % Button pushed function: NextButton
        function NextButtonPushed(app, event)
            app.SelectImageEditField.Value = app.SelectImageEditField.Value +1;
            
            % Plot the next image
            app.PlotButtonPushed(app);

        end

        % Button pushed function: AutoPopulateButton
        function AutoPopulateButtonPushed(app, event)
            
            % Get proper index
            comIndScal = app.aobj.data.data_struct.scalars.common_index;
            n          = app.SelectImageEditField.Value;
            indScal    = comIndScal(n);
           
            try
                app.DipoleGeVEditField.Value = app.aobj.data.data_struct.scalars.nonBSA_List_S20Magnets.LI20_LGPS_3330_BACT(indScal);
                app.Q0DkGEditField.Value = app.aobj.data.data_struct.scalars.nonBSA_List_S20Magnets.LI20_LGPS_3141_BACT(indScal);
                app.Q1DkGEditField.Value = app.aobj.data.data_struct.scalars.nonBSA_List_S20Magnets.LI20_LGPS_3261_BACT(indScal);
                app.Q2DkGEditField.Value = app.aobj.data.data_struct.scalars.nonBSA_List_S20Magnets.LI20_LGPS_3091_BACT(indScal);

                msg = 'Magnet strengths successfully loaded.';                
            catch
                app.DipoleGeVEditField.Value = 10;
                app.Q0DkGEditField.Value = 0;
                app.Q1DkGEditField.Value = 0;
                app.Q2DkGEditField.Value = 0;

                msg = 'Some magnet strengths not found - Dipole strength set to 10 GeV';
            end
            updateLog(app.aobj, app, msg);

            % Set object and image plane locations
            try 
                app.ImagePlaneDropDown.Value  = app.SelectCameraDropDown.Value; % The camera location
            catch
                updateLog(obj, app, 'Camera not on list - select image plane manually');
                app.ImagePlaneDropDown.Value  = 'Custom';
            end
            app.zimEditField.Value = set_Z(app.aobj, app, 'ImagePlaneDropDown');


            try
               app.zobEditField.Value = data_struct.scalars.nonBSA_List_S20.SIOC_SYS1_ML00_CALCOUT052(indScal);
               app.ObjectPlaneDropDown.Value = 'Custom';
            catch
               updateLog(app.aobj, app, 'No object plane found - setting to IPWS1');
               app.ObjectPlaneDropDown.Value = 'IPWS1';
            end
            app.zobEditField.Value = set_Z(app.aobj, app, 'ObjectPlaneDropDown');


        end

        % Button pushed function: PlotTransportMatrixButton
        function PlotTransportMatrixButtonPushed(app, event)
            
            if length(app.aobj.ROI.E)>2
                E = app.aobj.ROI.E;
            elseif length(app.aobj.cal.E)>2
                E = app.aobj.cal.E;
            else
                E = 2:0.1:20;
            end

            try
                [M11 M12] = calc_TransportMatrix(app.aobj, app, E);

                figure
                plot(E, M11, '.-', E, M12, '.-');
                xlabel 'Energy [GeV]'
                ylabel 'Transport Elements'
                legend({'M11', 'M12'}, 'Location', 'NorthWest')
                grid on; grid minor

                
                exp = app.aobj.data.data_struct.save_info.experiment;
                dataSetID = app.aobj.data.data_struct.save_info.instance;
                ind = app.SelectImageEditField.Value;
                titletext1 = {sprintf('DAQ %s\\_%05d, Index: %d', exp, dataSetID, ind)};
                titletext2 = {sprintf('Object plane: %s (%.2fm), Image plane: %s (%.2fm)', app.ObjectPlaneDropDown.Value, app.zobEditField.Value, app.ImagePlaneDropDown.Value, app.zimEditField.Value), ...
                             sprintf('Magnets: Q0D = %.2f, Q1D = %.2f, Q2D = %.2f', app.Q0DkGEditField.Value, app.Q1DkGEditField.Value, app.Q2DkGEditField.Value)};
                title(titletext1, titletext2);


            catch
                updateLog(app.aobj, app, 'Error in plot transport');
            end


        end

        % Button pushed function: CentroidButton
        function CentroidButtonPushed(app, event)

            get_ROI(app.aobj, app);
            
            try
                if ~isempty(app.aobj.ROI.img)
                    Cy = sum(app.aobj.ROI.ymm.*sum(app.aobj.ROI.img, 1))/sum(sum(app.aobj.ROI.img, 1));
                    Ctext = 'ROI';
                else
                    Cy = sum(app.aobj.data.ymm.*sum(app.aobj.data.img, 1))/sum(sum(app.aobj.data.img, 1));
                    Ctext = 'full image';
                end
                app.GeVBeamPositionmmEditField.Value = Cy;
                updateLog(app.aobj, app, ['10 GeV beam position updated to ' Ctext ' centroid position']);
            catch
                updateLog(app.aobj, app, ['Error getting centroid from ' Ctext]);
            end

        end

        % Value changed function: ToggleECalButton
        function ToggleECalButtonValueChanged(app, event)
            
            if app.ToggleECalButton.Value
                
                % Do the energy calibration
                cal_Energy(app.aobj, app);

                % Add the axis to the side
                app.UIAxes.YAxis(2).Limits = app.UIAxes.YAxis(1).Limits;
                add_EnergyAxis(app.aobj, app, 'UIAxes', 'YAxis', 2);

                updateLog(app.aobj, app, 'Energy axis added');

            else
                remove_EnergyAxis(app.aobj, app, 'UIAxes', 'YAxis', 2);
                updateLog(app.aobj, app, 'Energy axis removed');
            end
        end

        % Button pushed function: ChargePlotButton
        function ChargePlotButtonPushed(app, event)


            get_ROI(app.aobj, app);
           
            if ~app.ToggleECalButton.Value
                % Plot stuff
                plot(app.UIAxes2, app.aobj.ROI.ymm, sum(app.aobj.ROI.img, 1));
                xlabel(app.UIAxes2, 'y position [mm]')
            else
                % Calculate E values
                app.aobj.ROI.E = cal_Energy(app.aobj, app, app.aobj.ROI.ymm);

                % Plot stuff
                plot(app.UIAxes2, app.aobj.ROI.E, sum(app.aobj.ROI.img, 1));
                xlabel(app.UIAxes2, 'Energy [GeV]')
            end

            


        end

        % Button pushed function: PlotBeamWidthsButton
        function PlotBeamWidthsButtonPushed(app, event)

            if isempty(app.aobj.ROI.E)
                msg = 'Calibrated data not available. Click charge plot first';
                updateLog(app.aobj, app, msg);
                return
            end

            % Put the data into more usable variables
            E   = app.aobj.ROI.E;
            xmm = app.aobj.ROI.xmm;
            img = app.aobj.ROI.img;

            app.plots = [];
            cla(app.UIAxes3);
            app.UIAxes3.YLimMode = 'auto';
            app.UIAxes3.XLimMode = 'auto';

            indy = 1:1:length(E);

            % Loop through all possible y-values and create line profiles
            prog = 0;
tic
            for iy = indy;
                prog = prog+1;
                dy = 20*ones(size(xmm));
                y_off = 1;
                gaussianWithOffset = @(params, x) params(1) + params(2) * exp(-(x - params(3)).^2 / (2 * params(4)^2));

                try
                    
                    if app.Method1Button.Value
                        [params_fit, params_MOE, yfit, y_lower, y_upper] = fit_guass(app.aobj, app, xmm, double(img(:,iy)'));
                        sigma_x(iy)  = params_fit(3)*1000;
                        dsigma_x(iy) = params_MOE(3)*1000;
                    elseif app.Method2Button.Value
                        [yfit,q,dq,chisq_ndf] = gauss_fit(xmm,double(img(:,iy)'),dy,y_off);
                        y_lower = gaussianWithOffset(q-dq, xmm);
                        y_upper = gaussianWithOffset(q+dq, xmm);
                        sigma_x(iy)  = q(4)*1000;
                        dsigma_x(iy) = dq(4)*1000;
                    end

                    
                    if app.PlotfitCheckBox.Value
                        plot(app.UIAxes3, xmm,img(:,iy), xmm, yfit)
                        hold(app.UIAxes3,'on')
                        fill(app.UIAxes3, [xmm fliplr(xmm)], [y_lower fliplr(y_upper)], ...
                                       'r', 'EdgeColor','none', 'FaceAlpha', 0.2);
                        title(app.UIAxes3, sprintf('E = %0.1f GeV - %3.0f%% complete', E(iy), prog/length(indy)*100))
                        legend(app.UIAxes3, 'Data','Fit', 'Bounds');
                        hold(app.UIAxes3,'off')
                        drawnow
                    end

                catch
                    sigma_x(iy)  = NaN;
                    dsigma_x(iy) = NaN;
                    if app.PlotfitCheckBox.Value
                        plot(app.UIAxes3, xmm,img(:,iy));
                        legend(app.UIAxes3, 'Data');
                        title(app.UIAxes3, sprintf('Fit failed: E = %0.1f GeV - %.0f%% complete', E(iy), prog/length(indy)*100))
                        drawnow
                    end
                end
                if app.PlotfitCheckBox.Value
                    xlabel(app.UIAxes3, 'x position [mm]');
                    ylabel(app.UIAxes3, 'Counts');
                end
                
            end

         toc
     
            % Do some conditioning
            indbad = dsigma_x>sigma_x; % Huge error
            indy = indy&~indbad;
            indbad = sigma_x>20*1000;  % huge beam width (20mm)
            indy = indy&~indbad;
            indbad = isnan(dsigma_x); % Check for NaNs
            indy = indy&~indbad;

            app.plots.DataPlot = errorbar(app.UIAxes3, E(indy), sigma_x(indy), dsigma_x(indy), '.');
            yl = ylim(app.UIAxes3);
            ymax = min(yl(2), 5000); % set 5mm as the max
            ylim(app.UIAxes3, [yl(1) ymax]);

            xlabel(app.UIAxes3, 'Energy [GeV]');
            ylabel(app.UIAxes3, 'Beam width, [µm]');            
            title(app.UIAxes3, '');

            % Save the data
            app.aobj.data.Efit     = E(indy);
            app.aobj.data.sigma_x  = sigma_x(indy);
            app.aobj.data.dsigma_x = dsigma_x(indy);

            add_legendEmit(app.aobj, app, app.UIAxes3, app.plots)

        end

        % Value changed function: PlotDesiredButton
        function PlotDesiredButtonValueChanged(app, event)
            value = app.PlotDesiredButton.Value;

            % 1) get image data 
            % 2) Calculate transport matrix
            % 3) calculate sigmax
            % 4) plot and add legend

            if value
                Desired_emitn = app.DesiredEmittanceEditField.Value*1e-6;
                DesiredBeta_w = app.DesiredBetaEditField.Value*1e-2;
                DesiredWaistOffset = app.DesiredWaistOffsetEditField.Value;
    
                % Calculate Transport matrrix
                E = app.aobj.ROI.E;
                [M11 M12] = calc_TransportMatrix(app.aobj, app, E);
    
                % Calculate beam width
                sigma_x = calc_BeamWidth(app.aobj, app, [Desired_emitn, DesiredBeta_w,  DesiredWaistOffset], E, M11, M12);
    
                hold(app.UIAxes3, 'on');
                app.plots.DesiredPlot = plot(app.UIAxes3, E, sigma_x, 'g-.');
     
                app.UIAxes3.YLimMode = 'auto';
                
                hold(app.UIAxes3, 'off');
                updateLog(app.aobj, app, 'Desired emittance plot data added to plot');



            else
                try
                    delete(app.plots.DesiredPlot);
                    app.plots = rmfield(app.plots, 'DesiredPlot');
                    updateLog(app.aobj, app, 'Removed desired emittance plot data');
                catch
                    updateLog(app.aobj, app, 'No desired emittance plot data to remove');
                end
            end
            

            add_legendEmit(app.aobj, app, app.UIAxes3, app.plots)

            
        end

        % Button pushed function: DoFitButton
        function DoFitButtonPushed(app, event)
            
            % Get the starting parameters
            Desired_emitn = app.DesiredEmittanceEditField.Value*1e-6;
            DesiredBeta_0 = app.DesiredBetaEditField.Value*1e-2;
            DesiredAlpha_0 = 0;
            startingPts = [Desired_emitn DesiredBeta_0 DesiredAlpha_0 ];

            % Calculate Transport matrrix
            E = app.aobj.data.Efit;
            sigma_x = app.aobj.data.sigma_x;
            dsigma_x = app.aobj.data.dsigma_x;
            [M11 M12] = calc_TransportMatrix(app.aobj, app, E);
    

            % Do the fit
            [params_fit, params_std_error, sigma_x_fit, sigma_x_lower_bound, sigma_x_upper_bound]  = fit_emittance(app.aobj, app, E, sigma_x, dsigma_x, M11, M12, startingPts);

            % Update the plot
            hold(app.UIAxes3, 'on');
            app.plots.FitPlot = plot(app.UIAxes3, E, sigma_x_fit, 'r-')
            app.UIAxes3.YLimMode = 'auto';
            yl = app.UIAxes3.YLim;
            
            app.plots.BoundPlot = fill(app.UIAxes3, [E fliplr(E)], [sigma_x_lower_bound fliplr(sigma_x_upper_bound)], ...
                                       'r', 'EdgeColor','none', 'FaceAlpha', 0.2);
            hold(app.UIAxes3, 'off');
            app.UIAxes3.YLim = yl;

            titletext = sprintf('Fit: ÿ_n = %.0f µm, ÿ_w = %.1f cm, Waist offset = %.1f cm', app.FitEmittanceEditField.Value, app.FitWaistBetaEditField.Value, app.FitWaistOffsetEditField.Value*100);
            title(app.UIAxes3, titletext)

            add_legendEmit(app.aobj, app, app.UIAxes3, app.plots)

            updateLog(app.aobj, app, 'Fit data added to plot'); 

            


        end

        % Button pushed function: PrinttologbookButton
        function PrinttologbookButtonPushed(app, event)


            fh = figure(199);
            clf(fh)
            set(fh,'Position', [480   340   1200   650]);
            set(fh,'color','w');

            t = tiledlayout(3,2,'TileSpacing','Compact','Padding','Compact');
            
            %Copy the emittance plot
            ax3 = nexttile([2 1]);
            copy_plot(app.aobj,app, ax3, app.UIAxes3);
            add_legendEmit(app.aobj, app, ax3, app.plots);
            lh = legend;
            lh.FontSize = 10;
            lh.Box = 'off';
            box on;
            
            % Copy the image
            ax1 = nexttile([2 1]);
            copy_plot(app.aobj,app, ax1, app.UIAxes);
            if strcmp(app.aobj.data.dataSetID,'Live')
                titletext = sprintf('Camera %s, %s', app.aobj.data.cam, app.aobj.data.ts);
            else
                titletext = sprintf('Camera %s, index %d', app.aobj.data.cam, app.aobj.data.ind);
            end
            title(ax1, titletext);
            
            % Copy the charge plot
            ax2 = nexttile(5);
            copy_plot(app.aobj,app, ax2, app.UIAxes2);
            box on;

            % Add some text
            ax4 = nexttile(6);
            axis off;

            if strcmp(app.aobj.data.dataSetID,'Live')
                src      = string(sprintf('Data source: Live - %s', app.aobj.data.ts));
                caminfo  = string(sprintf('Camera: %s', app.aobj.data.cam));
            else
                src      = string(sprintf('Data source: DAQ %s\\_%05d  ', app.aobj.data.exp, app.aobj.data.dataSetID));
                caminfo  = string(sprintf('Camera: %s, index: %d', app.aobj.data.cam, app.aobj.data.ind));  
            end
            emitinfo = string(sprintf('  Emittance,    \x03b5_n  = %.4g µm (%.4g, %.4g)', ...
                                         app.aobj.emit.emitn_fit*1e6, app.aobj.emit.emitn_CI(1)*1e6, app.aobj.emit.emitn_CI(2)*1e6));
            betainfo = string(sprintf('  Waist beta,    \x03b2_0 = %.3g cm   (%.3g, %.3g)', ...
                                         app.aobj.emit.beta_0_fit*1e2, app.aobj.emit.beta_0_CI(1)*1e2, app.aobj.emit.beta_0_CI(2)*1e2));
            dzinfo   = string(sprintf('  Waist offset,  \x0394z = %.3g cm    (%.3g, %.3g)', ...
                                         app.aobj.emit.deltaz_w_fit*1e2, app.aobj.emit.deltaz_w_CI(1)*1e2, app.aobj.emit.deltaz_w_CI(2)*1e2));
            locinfo  = string(sprintf('       from location %s (z = %gm)', app.ObjectPlaneDropDown.Value, app.zobEditField.Value));

            analysisinfo = [src;
                            caminfo;
                            " ";
                            "Fit results";
                            emitinfo;
                            betainfo;
                            dzinfo;
                            locinfo];

            tt= text(ax4, 0, 1,analysisinfo, 'VerticalAlignment', 'top', 'FontSize', 11);

            
            % save app object
            F2_Emit_data = [];
            F2_Emit_data.data = app.aobj.data;
            F2_Emit_data.ROI = app.aobj.ROI;
            F2_Emit_data.cal = app.aobj.cal;
            F2_Emit_data.emit = app.aobj.emit;
            F2_Emit_data.emit.text = analysisinfo;
            F2_Emit_data.log = app.aobj.log;
            F2_Emit_data.figure = fh;
            
            
            if strcmp(app.aobj.data.dataSetID,'Live')
                fileName = sprintf('Live_%s', app.aobj.data.cam)
            else
                fileName = sprintf('%s_%s_%s_ind%s', app.aobj.data.exp, app.aobj.data.dataSetID,app.aobj.data.cam, app.aobj.data.ind)
            end
            [fileName pathName] = util_dataSave(F2_Emit_data, 'F2_Emit', fileName, app.aobj.data.ts);
            pathfile = strcat(pathName, '/', fileName);
            

            
           % prepare to log
            opts.text = strcat(src, caminfo, ...
                               sprintf('\nnemit_x: %.4g (%.4g, %.4g) [mm-mrad], beta_0: %.3g (%.3g, %.3g) [cm]', ...
                                   app.aobj.emit.emitn_fit*1e6, app.aobj.emit.emitn_CI(1)*1e6, app.aobj.emit.emitn_CI(2)*1e6,  ...  
                                   app.aobj.emit.beta_0_fit*1e2, app.aobj.emit.beta_0_CI(1)*1e2, app.aobj.emit.beta_0_CI(2)*1e2), ...
                               sprintf('\n\nFile: %s', pathfile));
            opts.title= 'F2_Emit: Emittance Analysis';
    
            try
                util_printLog(fh,opts);
                updateLog(app.aobj, app, 'Printed to FACET elog'); 
            catch
                updateLog(app.aobj, app, 'Printing failed'); 
            end

%             opts.title = 'DAN picture';
%             opts.author = 'Matlab';
%             opts.text = '';
%             util_printLog(fh,opts);
%             close(fh)
%             
%             info_str = sprintf('%s %s', xlabS, ylabS);
%             
%             set(gcf,'Position',[10 10 10 10]);
%             util_printLog2020(fh,'title',titleS,...
%             'author','DAN','text',info_str);
%             clf(99), close(99);
        end

        % Button pushed function: ResetButton
        function ResetButtonPushed(app, event)

            % Reset the app object
            app.aobj = EmitSupport(app);

            % Reset the text areas
            app.LogTextArea.Value = '';
            app.DataSetInfoTextArea.Value = '';
            
            % Clear plots
            yyaxis(app.UIAxes, 'left');
            cla(app.UIAxes);
            yyaxis(app.UIAxes, 'right');
            cla(app.UIAxes);
            cla(app.UIAxes2);
            cla(app.UIAxes3);
            app.plots = [];
            title(app.UIAxes, '');
            title(app.UIAxes3, '');
            
            
            app.FitEmittanceEditField.Value=0;
            app.EmitCIEditField.Value='';
            app.FitWaistBetaEditField.Value=0;
            app.BetaCIEditField.Value='';
            app.FitWaistOffsetEditField.Value=0;
            app.OffsetCIEditField.Value='';
            app.RsquaredEditField.Value=0;
            
        end

        % Value changed function: zobEditField
        function zobEditFieldValueChanged(app, event)
            value = app.zobEditField.Value;
            app.ObjectPlaneDropDown.Value = 'Custom';
        end

        % Value changed function: zimEditField
        function zimEditFieldValueChanged(app, event)
            value = app.zimEditField.Value;
            app.ImagePlaneDropDown.Value = 'Custom';
        end

        % Value changed function: ObjectPlaneDropDown
        function ObjectPlaneDropDownValueChanged(app, event)
            value = app.ObjectPlaneDropDown.Value;
            app.zobEditField.Value = set_Z(app.aobj, app, 'ObjectPlaneDropDown');
        end

        % Value changed function: ImagePlaneDropDown
        function ImagePlaneDropDownValueChanged(app, event)
            value = app.ImagePlaneDropDown.Value;
            app.zimEditField.Value = set_Z(app.aobj, app, 'ImagePlaneDropDown');
        end

        % Callback function: LiveDataTab
        function LiveDataTabButtonDown(app, event)
            app.AutoPopulateButton.Visible = 'off';
        end

        % Callback function: DAQDataTab
        function DAQDataTabButtonDown(app, event)
            app.AutoPopulateButton.Visible = 'on';
        end

        % Button pushed function: AcquireandAnalyzeButton
        function AcquireandAnalyzeButtonPushed(app, event)
            
            % Toggle Ecal and press energy cal button
            app.ToggleECalButton.Value = 1;
            ToggleECalButtonValueChanged(app);
            ChargePlotButtonPushed(app);
            % Plot beam widths
            PlotBeamWidthsButtonPushed(app);
            % Do fit
            DoFitButtonPushed(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1199 887];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.Scrollable = 'on';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, '')
            xlabel(app.UIAxes, 'x position [mm]')
            ylabel(app.UIAxes, 'y position [mm]')
            app.UIAxes.Position = [643 558 533 304];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.UIFigure);
            title(app.UIAxes2, '')
            xlabel(app.UIAxes2, 'y position [mm]')
            ylabel(app.UIAxes2, 'Charge [a.u.]')
            app.UIAxes2.Position = [643 304 533 236];

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.UIFigure);
            title(app.UIAxes3, '')
            xlabel(app.UIAxes3, 'Beam Energy [Gev]')
            ylabel(app.UIAxes3, 'Beam Width')
            app.UIAxes3.Position = [643 27 533 268];

            % Create SpectrometerSettingsPanel
            app.SpectrometerSettingsPanel = uipanel(app.UIFigure);
            app.SpectrometerSettingsPanel.Title = 'Spectrometer Settings';
            app.SpectrometerSettingsPanel.Position = [26 412 277 215];

            % Create DipoleGeVEditFieldLabel
            app.DipoleGeVEditFieldLabel = uilabel(app.SpectrometerSettingsPanel);
            app.DipoleGeVEditFieldLabel.Position = [17 161 123 22];
            app.DipoleGeVEditFieldLabel.Text = 'Dipole [GeV]';

            % Create DipoleGeVEditField
            app.DipoleGeVEditField = uieditfield(app.SpectrometerSettingsPanel, 'numeric');
            app.DipoleGeVEditField.Limits = [0 Inf];
            app.DipoleGeVEditField.Position = [94 161 84 22];
            app.DipoleGeVEditField.Value = 10;

            % Create AutoPopulateButton
            app.AutoPopulateButton = uibutton(app.SpectrometerSettingsPanel, 'push');
            app.AutoPopulateButton.ButtonPushedFcn = createCallbackFcn(app, @AutoPopulateButtonPushed, true);
            app.AutoPopulateButton.BackgroundColor = [0 1 0];
            app.AutoPopulateButton.Position = [189 145 74 38];
            app.AutoPopulateButton.Text = {'Auto'; 'Populate'};

            % Create Q0DkGEditFieldLabel
            app.Q0DkGEditFieldLabel = uilabel(app.SpectrometerSettingsPanel);
            app.Q0DkGEditFieldLabel.Position = [17 133 55 22];
            app.Q0DkGEditFieldLabel.Text = 'Q0D [kG]';

            % Create Q0DkGEditField
            app.Q0DkGEditField = uieditfield(app.SpectrometerSettingsPanel, 'numeric');
            app.Q0DkGEditField.ValueDisplayFormat = '%11.5g';
            app.Q0DkGEditField.Position = [94 133 84 22];

            % Create Q1DkGEditFieldLabel
            app.Q1DkGEditFieldLabel = uilabel(app.SpectrometerSettingsPanel);
            app.Q1DkGEditFieldLabel.Position = [17 103 55 22];
            app.Q1DkGEditFieldLabel.Text = 'Q1D [kG]';

            % Create Q1DkGEditField
            app.Q1DkGEditField = uieditfield(app.SpectrometerSettingsPanel, 'numeric');
            app.Q1DkGEditField.ValueDisplayFormat = '%11.5g';
            app.Q1DkGEditField.Position = [94 103 84 22];

            % Create Q2DkGEditFieldLabel
            app.Q2DkGEditFieldLabel = uilabel(app.SpectrometerSettingsPanel);
            app.Q2DkGEditFieldLabel.Position = [17 71 55 22];
            app.Q2DkGEditFieldLabel.Text = 'Q2D [kG]';

            % Create Q2DkGEditField
            app.Q2DkGEditField = uieditfield(app.SpectrometerSettingsPanel, 'numeric');
            app.Q2DkGEditField.ValueDisplayFormat = '%11.5g';
            app.Q2DkGEditField.Position = [94 71 84 22];

            % Create ObjectPlaneDropDownLabel
            app.ObjectPlaneDropDownLabel = uilabel(app.SpectrometerSettingsPanel);
            app.ObjectPlaneDropDownLabel.Position = [17 38 74 22];
            app.ObjectPlaneDropDownLabel.Text = 'Object Plane';

            % Create ObjectPlaneDropDown
            app.ObjectPlaneDropDown = uidropdown(app.SpectrometerSettingsPanel);
            app.ObjectPlaneDropDown.Items = {'Select', 'SFQED', 'FILS', 'IPWS1', 'PENT', 'PEXT', 'DSBeWIN', 'Custom'};
            app.ObjectPlaneDropDown.ValueChangedFcn = createCallbackFcn(app, @ObjectPlaneDropDownValueChanged, true);
            app.ObjectPlaneDropDown.Position = [94 38 84 22];
            app.ObjectPlaneDropDown.Value = 'Select';

            % Create zobEditField
            app.zobEditField = uieditfield(app.SpectrometerSettingsPanel, 'numeric');
            app.zobEditField.ValueDisplayFormat = '%11.6g';
            app.zobEditField.ValueChangedFcn = createCallbackFcn(app, @zobEditFieldValueChanged, true);
            app.zobEditField.Position = [189 38 74 22];

            % Create ImagePlaneDropDownLabel
            app.ImagePlaneDropDownLabel = uilabel(app.SpectrometerSettingsPanel);
            app.ImagePlaneDropDownLabel.Position = [17 7 72 22];
            app.ImagePlaneDropDownLabel.Text = 'Image Plane';

            % Create ImagePlaneDropDown
            app.ImagePlaneDropDown = uidropdown(app.SpectrometerSettingsPanel);
            app.ImagePlaneDropDown.Items = {'Select', 'DTOTR1', 'DTOTR2', 'LFOV', 'CHER', 'PRDMP', 'EDC_SCREEN', 'Custom'};
            app.ImagePlaneDropDown.ValueChangedFcn = createCallbackFcn(app, @ImagePlaneDropDownValueChanged, true);
            app.ImagePlaneDropDown.Position = [95 7 84 22];
            app.ImagePlaneDropDown.Value = 'Select';

            % Create zimEditField
            app.zimEditField = uieditfield(app.SpectrometerSettingsPanel, 'numeric');
            app.zimEditField.ValueDisplayFormat = '%11.6g';
            app.zimEditField.ValueChangedFcn = createCallbackFcn(app, @zimEditFieldValueChanged, true);
            app.zimEditField.Position = [189 7 74 22];

            % Create EnergyCalibrationPanel
            app.EnergyCalibrationPanel = uipanel(app.UIFigure);
            app.EnergyCalibrationPanel.Title = 'Energy Calibration';
            app.EnergyCalibrationPanel.Position = [319 412 288 215];

            % Create NominalDispersionmmEditFieldLabel
            app.NominalDispersionmmEditFieldLabel = uilabel(app.EnergyCalibrationPanel);
            app.NominalDispersionmmEditFieldLabel.Position = [11 161 142 22];
            app.NominalDispersionmmEditFieldLabel.Text = 'Nominal Dispersion [mm]';

            % Create NominalDispersionmmEditField
            app.NominalDispersionmmEditField = uieditfield(app.EnergyCalibrationPanel, 'numeric');
            app.NominalDispersionmmEditField.Position = [169 161 41 22];
            app.NominalDispersionmmEditField.Value = -50;

            % Create GeVBeamPositionmmEditFieldLabel
            app.GeVBeamPositionmmEditFieldLabel = uilabel(app.EnergyCalibrationPanel);
            app.GeVBeamPositionmmEditFieldLabel.Position = [11 133 157 22];
            app.GeVBeamPositionmmEditFieldLabel.Text = '10 GeV Beam Position [mm]';

            % Create GeVBeamPositionmmEditField
            app.GeVBeamPositionmmEditField = uieditfield(app.EnergyCalibrationPanel, 'numeric');
            app.GeVBeamPositionmmEditField.Position = [169 133 41 22];
            app.GeVBeamPositionmmEditField.Value = 5;

            % Create CentroidButton
            app.CentroidButton = uibutton(app.EnergyCalibrationPanel, 'push');
            app.CentroidButton.ButtonPushedFcn = createCallbackFcn(app, @CentroidButtonPushed, true);
            app.CentroidButton.Position = [220 133 55 22];
            app.CentroidButton.Text = 'Centroid';

            % Create ToggleECalButton
            app.ToggleECalButton = uibutton(app.EnergyCalibrationPanel, 'state');
            app.ToggleECalButton.ValueChangedFcn = createCallbackFcn(app, @ToggleECalButtonValueChanged, true);
            app.ToggleECalButton.Text = {'Toggle ECal'; ''};
            app.ToggleECalButton.BackgroundColor = [0 1 0];
            app.ToggleECalButton.Position = [149 103 126 22];

            % Create ChargePlotButton
            app.ChargePlotButton = uibutton(app.EnergyCalibrationPanel, 'push');
            app.ChargePlotButton.ButtonPushedFcn = createCallbackFcn(app, @ChargePlotButtonPushed, true);
            app.ChargePlotButton.BackgroundColor = [0 1 0];
            app.ChargePlotButton.Position = [150 71 126 22];
            app.ChargePlotButton.Text = 'Charge Plot';

            % Create PlotTransportMatrixButton
            app.PlotTransportMatrixButton = uibutton(app.EnergyCalibrationPanel, 'push');
            app.PlotTransportMatrixButton.ButtonPushedFcn = createCallbackFcn(app, @PlotTransportMatrixButtonPushed, true);
            app.PlotTransportMatrixButton.Position = [149 39 126 22];
            app.PlotTransportMatrixButton.Text = 'Plot Transport Matrix';

            % Create BeamWidthPlotSettingsPanel
            app.BeamWidthPlotSettingsPanel = uipanel(app.UIFigure);
            app.BeamWidthPlotSettingsPanel.Title = 'Beam Width Plot Settings';
            app.BeamWidthPlotSettingsPanel.Position = [25 283 278 111];

            % Create PlotBeamWidthsButton
            app.PlotBeamWidthsButton = uibutton(app.BeamWidthPlotSettingsPanel, 'push');
            app.PlotBeamWidthsButton.ButtonPushedFcn = createCallbackFcn(app, @PlotBeamWidthsButtonPushed, true);
            app.PlotBeamWidthsButton.BackgroundColor = [0 1 0];
            app.PlotBeamWidthsButton.Position = [15 58 141 23];
            app.PlotBeamWidthsButton.Text = 'Plot Beam Widths';

            % Create PlotfitCheckBox
            app.PlotfitCheckBox = uicheckbox(app.BeamWidthPlotSettingsPanel);
            app.PlotfitCheckBox.Text = 'Plot fit';
            app.PlotfitCheckBox.Position = [19 29 55 22];

            % Create FittypeButtonGroup
            app.FittypeButtonGroup = uibuttongroup(app.BeamWidthPlotSettingsPanel);
            app.FittypeButtonGroup.Title = 'Fit type';
            app.FittypeButtonGroup.Position = [170 4 100 82];

            % Create Method1Button
            app.Method1Button = uiradiobutton(app.FittypeButtonGroup);
            app.Method1Button.Text = 'Method 1';
            app.Method1Button.Position = [9 35 72 22];
            app.Method1Button.Value = true;

            % Create Method2Button
            app.Method2Button = uiradiobutton(app.FittypeButtonGroup);
            app.Method2Button.Text = 'Method 2';
            app.Method2Button.Position = [9 7 72 22];

            % Create EmittancePanel
            app.EmittancePanel = uipanel(app.UIFigure);
            app.EmittancePanel.Title = 'Emittance';
            app.EmittancePanel.Position = [321 102 286 292];

            % Create DesiredEmittanceEditFieldLabel
            app.DesiredEmittanceEditFieldLabel = uilabel(app.EmittancePanel);
            app.DesiredEmittanceEditFieldLabel.Position = [15 238 103 22];
            app.DesiredEmittanceEditFieldLabel.Text = 'Desired Emittance';

            % Create DesiredEmittanceEditField
            app.DesiredEmittanceEditField = uieditfield(app.EmittancePanel, 'numeric');
            app.DesiredEmittanceEditField.Position = [133 238 58 22];
            app.DesiredEmittanceEditField.Value = 20;

            % Create mLabel
            app.mLabel = uilabel(app.EmittancePanel);
            app.mLabel.Position = [200 237 25 22];
            app.mLabel.Text = 'µm';

            % Create DesiredBetaEditFieldLabel
            app.DesiredBetaEditFieldLabel = uilabel(app.EmittancePanel);
            app.DesiredBetaEditFieldLabel.Position = [15 209 74 22];
            app.DesiredBetaEditFieldLabel.Text = 'Desired Beta';

            % Create DesiredBetaEditField
            app.DesiredBetaEditField = uieditfield(app.EmittancePanel, 'numeric');
            app.DesiredBetaEditField.Position = [133 209 58 22];
            app.DesiredBetaEditField.Value = 50;

            % Create cmLabel
            app.cmLabel = uilabel(app.EmittancePanel);
            app.cmLabel.Position = [201 209 25 22];
            app.cmLabel.Text = 'cm';

            % Create DesiredWaistOffsetEditFieldLabel
            app.DesiredWaistOffsetEditFieldLabel = uilabel(app.EmittancePanel);
            app.DesiredWaistOffsetEditFieldLabel.Position = [15 180 114 22];
            app.DesiredWaistOffsetEditFieldLabel.Text = 'Desired Waist Offset';

            % Create DesiredWaistOffsetEditField
            app.DesiredWaistOffsetEditField = uieditfield(app.EmittancePanel, 'numeric');
            app.DesiredWaistOffsetEditField.Position = [133 180 58 22];

            % Create mLabel_4
            app.mLabel_4 = uilabel(app.EmittancePanel);
            app.mLabel_4.Position = [200 180 25 22];
            app.mLabel_4.Text = 'm';

            % Create PlotDesiredButton
            app.PlotDesiredButton = uibutton(app.EmittancePanel, 'state');
            app.PlotDesiredButton.ValueChangedFcn = createCallbackFcn(app, @PlotDesiredButtonValueChanged, true);
            app.PlotDesiredButton.Text = 'Plot Desired';
            app.PlotDesiredButton.Position = [16 143 111 23];

            % Create DoFitButton
            app.DoFitButton = uibutton(app.EmittancePanel, 'push');
            app.DoFitButton.ButtonPushedFcn = createCallbackFcn(app, @DoFitButtonPushed, true);
            app.DoFitButton.BackgroundColor = [0 1 0];
            app.DoFitButton.Position = [158 143 111 23];
            app.DoFitButton.Text = 'Do Fit';

            % Create FitEmittanceEditFieldLabel
            app.FitEmittanceEditFieldLabel = uilabel(app.EmittancePanel);
            app.FitEmittanceEditFieldLabel.Position = [15 106 75 22];
            app.FitEmittanceEditFieldLabel.Text = 'Fit Emittance';

            % Create FitEmittanceEditField
            app.FitEmittanceEditField = uieditfield(app.EmittancePanel, 'numeric');
            app.FitEmittanceEditField.Position = [101 106 50 22];

            % Create mLabel_2
            app.mLabel_2 = uilabel(app.EmittancePanel);
            app.mLabel_2.Position = [159 106 25 22];
            app.mLabel_2.Text = 'µm ';

            % Create EmitCIEditField
            app.EmitCIEditField = uieditfield(app.EmittancePanel, 'text');
            app.EmitCIEditField.Position = [184 106 86 23];

            % Create FitWaistBetaEditField_3Label
            app.FitWaistBetaEditField_3Label = uilabel(app.EmittancePanel);
            app.FitWaistBetaEditField_3Label.Position = [15 75 79 22];
            app.FitWaistBetaEditField_3Label.Text = 'Fit Waist Beta';

            % Create FitWaistBetaEditField
            app.FitWaistBetaEditField = uieditfield(app.EmittancePanel, 'numeric');
            app.FitWaistBetaEditField.Position = [101 75 50 22];

            % Create cmLabel_2
            app.cmLabel_2 = uilabel(app.EmittancePanel);
            app.cmLabel_2.Position = [159 75 25 22];
            app.cmLabel_2.Text = 'cm';

            % Create BetaCIEditField
            app.BetaCIEditField = uieditfield(app.EmittancePanel, 'text');
            app.BetaCIEditField.Position = [184 75 86 23];

            % Create FitWaistOffsetEditFieldLabel
            app.FitWaistOffsetEditFieldLabel = uilabel(app.EmittancePanel);
            app.FitWaistOffsetEditFieldLabel.Position = [15 44 86 22];
            app.FitWaistOffsetEditFieldLabel.Text = 'Fit Waist Offset';

            % Create FitWaistOffsetEditField
            app.FitWaistOffsetEditField = uieditfield(app.EmittancePanel, 'numeric');
            app.FitWaistOffsetEditField.Position = [101 44 50 22];

            % Create mLabel_3
            app.mLabel_3 = uilabel(app.EmittancePanel);
            app.mLabel_3.Position = [159 45 31 22];
            app.mLabel_3.Text = 'm';

            % Create OffsetCIEditField
            app.OffsetCIEditField = uieditfield(app.EmittancePanel, 'text');
            app.OffsetCIEditField.Position = [184 44 86 23];

            % Create RsquaredEditFieldLabel
            app.RsquaredEditFieldLabel = uilabel(app.EmittancePanel);
            app.RsquaredEditFieldLabel.Position = [15 14 61 22];
            app.RsquaredEditFieldLabel.Text = 'R-squared';

            % Create RsquaredEditField
            app.RsquaredEditField = uieditfield(app.EmittancePanel, 'numeric');
            app.RsquaredEditField.Position = [101 14 50 22];

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [24 640 583 217];

            % Create DAQDataTab
            app.DAQDataTab = uitab(app.TabGroup);
            app.DAQDataTab.Title = 'DAQ Data';

            % Create SelectDataSetLabel
            app.SelectDataSetLabel = uilabel(app.DAQDataTab);
            app.SelectDataSetLabel.Position = [16 161 101 22];
            app.SelectDataSetLabel.Text = 'Select Data Set:';

            % Create ExperimentLabel
            app.ExperimentLabel = uilabel(app.DAQDataTab);
            app.ExperimentLabel.Position = [15 136 36 22];
            app.ExperimentLabel.Text = 'DAQ';

            % Create expDropDown
            app.expDropDown = uidropdown(app.DAQDataTab);
            app.expDropDown.Items = {'SELECT', 'E300', 'E301', 'E305', 'E308', 'E320', 'E325', 'E326', 'E327', 'E331', 'E332'};
            app.expDropDown.ValueChangedFcn = createCallbackFcn(app, @expDropDownValueChanged, true);
            app.expDropDown.Position = [49 136 75 22];
            app.expDropDown.Value = 'E332';

            % Create dataSetVal
            app.dataSetVal = uieditfield(app.DAQDataTab, 'numeric');
            app.dataSetVal.Limits = [0 Inf];
            app.dataSetVal.ValueDisplayFormat = '%d';
            app.dataSetVal.ValueChangedFcn = createCallbackFcn(app, @dataSetValValueChanged, true);
            app.dataSetVal.Position = [133 136 53 22];
            app.dataSetVal.Value = 1856;

            % Create LoadDataSetButton
            app.LoadDataSetButton = uibutton(app.DAQDataTab, 'push');
            app.LoadDataSetButton.ButtonPushedFcn = createCallbackFcn(app, @LoadDataSetButtonPushed, true);
            app.LoadDataSetButton.HorizontalAlignment = 'left';
            app.LoadDataSetButton.BackgroundColor = [0 1 0];
            app.LoadDataSetButton.Position = [200 136 87 22];
            app.LoadDataSetButton.Text = 'Load DataSet';

            % Create SelectCameraDropDownLabel
            app.SelectCameraDropDownLabel = uilabel(app.DAQDataTab);
            app.SelectCameraDropDownLabel.Position = [16 102 84 22];
            app.SelectCameraDropDownLabel.Text = {'Select Camera'; ''};

            % Create SelectCameraDropDown
            app.SelectCameraDropDown = uidropdown(app.DAQDataTab);
            app.SelectCameraDropDown.Items = {'Load Data', ''};
            app.SelectCameraDropDown.ValueChangedFcn = createCallbackFcn(app, @SelectCameraDropDownValueChanged, true);
            app.SelectCameraDropDown.Position = [105 102 100 22];
            app.SelectCameraDropDown.Value = 'Load Data';

            % Create RotatedCheckBox
            app.RotatedCheckBox = uicheckbox(app.DAQDataTab);
            app.RotatedCheckBox.Text = 'Rotated';
            app.RotatedCheckBox.Position = [214 102 65 22];

            % Create SubtractBGCheckBox
            app.SubtractBGCheckBox = uicheckbox(app.DAQDataTab);
            app.SubtractBGCheckBox.Text = 'Subtract BG';
            app.SubtractBGCheckBox.Position = [214 81 87 22];

            % Create SelectImageEditFieldLabel
            app.SelectImageEditFieldLabel = uilabel(app.DAQDataTab);
            app.SelectImageEditFieldLabel.Position = [16 38 75 30];
            app.SelectImageEditFieldLabel.Text = {'Select Image'; ''; ''};

            % Create SelectImageEditField
            app.SelectImageEditField = uieditfield(app.DAQDataTab, 'numeric');
            app.SelectImageEditField.Limits = [1 Inf];
            app.SelectImageEditField.Position = [110 50 42 22];
            app.SelectImageEditField.Value = 200;

            % Create NextButton
            app.NextButton = uibutton(app.DAQDataTab, 'push');
            app.NextButton.ButtonPushedFcn = createCallbackFcn(app, @NextButtonPushed, true);
            app.NextButton.Position = [164 50 47 23];
            app.NextButton.Text = 'Next';

            % Create PlotButton
            app.PlotButton = uibutton(app.DAQDataTab, 'push');
            app.PlotButton.ButtonPushedFcn = createCallbackFcn(app, @PlotButtonPushed, true);
            app.PlotButton.BackgroundColor = [0 1 0];
            app.PlotButton.Position = [19 16 100 23];
            app.PlotButton.Text = 'Plot';

            % Create PlotandAnalyzeButton
            app.PlotandAnalyzeButton = uibutton(app.DAQDataTab, 'push');
            app.PlotandAnalyzeButton.ButtonPushedFcn = createCallbackFcn(app, @PlotandAnalyzeButtonPushed, true);
            app.PlotandAnalyzeButton.BackgroundColor = [0 1 0];
            app.PlotandAnalyzeButton.Position = [137 16 104 23];
            app.PlotandAnalyzeButton.Text = 'Plot and Analyze';

            % Create LiveDataTab
            app.LiveDataTab = uitab(app.TabGroup);
            app.LiveDataTab.Title = 'Live Data';

            % Create CameraDropDown_2Label
            app.CameraDropDown_2Label = uilabel(app.LiveDataTab);
            app.CameraDropDown_2Label.HorizontalAlignment = 'right';
            app.CameraDropDown_2Label.Position = [11 150 48 22];
            app.CameraDropDown_2Label.Text = 'Camera';

            % Create CameraDropDown_2
            app.CameraDropDown_2 = uidropdown(app.LiveDataTab);
            app.CameraDropDown_2.Items = {'Select', 'DTOTR2', 'DTOTR1', 'LFOV', 'CHER', 'PRDMP', 'EDC_SCREEN', 'Other'};
            app.CameraDropDown_2.ValueChangedFcn = createCallbackFcn(app, @CameraDropDown_2ValueChanged, true);
            app.CameraDropDown_2.Position = [74 149 90 24];
            app.CameraDropDown_2.Value = 'Select';

            % Create AcquireButton
            app.AcquireButton = uibutton(app.LiveDataTab, 'push');
            app.AcquireButton.ButtonPushedFcn = createCallbackFcn(app, @AcquireButtonPushed, true);
            app.AcquireButton.BackgroundColor = [0 1 0];
            app.AcquireButton.Position = [17 114 146 23];
            app.AcquireButton.Text = 'Acquire';

            % Create AcquireandAnalyzeButton
            app.AcquireandAnalyzeButton = uibutton(app.LiveDataTab, 'push');
            app.AcquireandAnalyzeButton.ButtonPushedFcn = createCallbackFcn(app, @AcquireandAnalyzeButtonPushed, true);
            app.AcquireandAnalyzeButton.BackgroundColor = [0 1 0];
            app.AcquireandAnalyzeButton.Position = [17 81 146 23];
            app.AcquireandAnalyzeButton.Text = 'Acquire and Analyze';

            % Create PVEditFieldLabel
            app.PVEditFieldLabel = uilabel(app.LiveDataTab);
            app.PVEditFieldLabel.HorizontalAlignment = 'right';
            app.PVEditFieldLabel.Position = [171 150 25 22];
            app.PVEditFieldLabel.Text = 'PV';

            % Create PVEditField
            app.PVEditField = uieditfield(app.LiveDataTab, 'text');
            app.PVEditField.Position = [204 150 103 22];

            % Create LogTextAreaLabel
            app.LogTextAreaLabel = uilabel(app.UIFigure);
            app.LogTextAreaLabel.Position = [28 246 52 22];
            app.LogTextAreaLabel.Text = 'Log';

            % Create LogTextArea
            app.LogTextArea = uitextarea(app.UIFigure);
            app.LogTextArea.Position = [26 41 277 206];

            % Create ResetButton
            app.ResetButton = uibutton(app.UIFigure, 'push');
            app.ResetButton.ButtonPushedFcn = createCallbackFcn(app, @ResetButtonPushed, true);
            app.ResetButton.Position = [328 41 126 43];
            app.ResetButton.Text = {'Reset'; ''};

            % Create PrinttologbookButton
            app.PrinttologbookButton = uibutton(app.UIFigure, 'push');
            app.PrinttologbookButton.ButtonPushedFcn = createCallbackFcn(app, @PrinttologbookButtonPushed, true);
            app.PrinttologbookButton.BackgroundColor = [1 1 0];
            app.PrinttologbookButton.Position = [479 41 116 43];
            app.PrinttologbookButton.Text = {'Print to '; 'logbook'};

            % Create LockROICheckBox
            app.LockROICheckBox = uicheckbox(app.UIFigure);
            app.LockROICheckBox.Text = '    Lock ROI';
            app.LockROICheckBox.Position = [363 675 85 22];

            % Create DataSetInfoTextAreaLabel
            app.DataSetInfoTextAreaLabel = uilabel(app.UIFigure);
            app.DataSetInfoTextAreaLabel.HorizontalAlignment = 'right';
            app.DataSetInfoTextAreaLabel.Position = [348 801 72 22];
            app.DataSetInfoTextAreaLabel.Text = 'DataSet Info';

            % Create DataSetInfoTextArea
            app.DataSetInfoTextArea = uitextarea(app.UIFigure);
            app.DataSetInfoTextArea.Position = [344 707 247 93];

            % Create ManualClimLabel
            app.ManualClimLabel = uilabel(app.UIFigure);
            app.ManualClimLabel.HorizontalAlignment = 'right';
            app.ManualClimLabel.Position = [388 651 72 22];
            app.ManualClimLabel.Text = 'Manual Clim';

            % Create ClimCheckBox
            app.ClimCheckBox = uicheckbox(app.UIFigure);
            app.ClimCheckBox.Text = '';
            app.ClimCheckBox.Position = [363 651 25 22];

            % Create ClimLoEditField
            app.ClimLoEditField = uieditfield(app.UIFigure, 'numeric');
            app.ClimLoEditField.Position = [472 651 46 22];

            % Create ClimHiEditField
            app.ClimHiEditField = uieditfield(app.UIFigure, 'numeric');
            app.ClimHiEditField.Position = [524 651 46 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_Emit_exported

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