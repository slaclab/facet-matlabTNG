classdef F2_DAN_HDF5_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        TabGroup                        matlab.ui.container.TabGroup
        MainDANTab                      matlab.ui.container.Tab
        dataSet                         matlab.ui.container.Panel
        ExperimentLabel                 matlab.ui.control.Label
        expDropDown                     matlab.ui.control.DropDown
        dataSetIDLabel                  matlab.ui.control.Label
        dataSetID                       matlab.ui.control.NumericEditField
        LoadDataSetButton               matlab.ui.control.Button
        DANlogTextAreaLabel             matlab.ui.control.Label
        DANlogTextArea                  matlab.ui.control.TextArea
        SubtractImageBackgroundCheckBox  matlab.ui.control.CheckBox
        DataSetInfoTextAreaLabel        matlab.ui.control.Label
        DataSetInfoTextArea             matlab.ui.control.TextArea
        LastDAQButton                   matlab.ui.control.Button
        correlationPlot                 matlab.ui.container.Panel
        FACETScalarArray1Panel          matlab.ui.container.Panel
        ScalarDropDown_Corr1            matlab.ui.control.DropDown
        ScalargroupLabel_Corr1          matlab.ui.control.Label
        ScalarLabel_Corr1               matlab.ui.control.Label
        ScalargroupDropDown_Corr1       matlab.ui.control.DropDown
        CameraDropDown_Corr1            matlab.ui.control.DropDown
        CameraLabel_Corr1               matlab.ui.control.Label
        DtoscalarfunctionLabel_Corr1    matlab.ui.control.Label
        D21DFunctionEditField_Corr1     matlab.ui.control.EditField
        Switch_Corr1FS                  matlab.ui.control.Switch
        HistogramCheckBox               matlab.ui.control.CheckBox
        D21DFcnDropDown_Corr1           matlab.ui.control.DropDown
        UseanotherfunctionLabel         matlab.ui.control.Label
        FACETScalarArray2Panel          matlab.ui.container.Panel
        ScalarDropDown_Corr2            matlab.ui.control.DropDown
        ScalargroupLabel_Corr2          matlab.ui.control.Label
        ScalarLabel_Corr2               matlab.ui.control.Label
        ScalargroupDropDown_Corr2       matlab.ui.control.DropDown
        CameraDropDown_Corr2            matlab.ui.control.DropDown
        CameraLabel_Corr2               matlab.ui.control.Label
        DtoscalarfunctionLabel_Corr2    matlab.ui.control.Label
        D21DFunctionEditField_Corr2     matlab.ui.control.EditField
        Switch_Corr2FS                  matlab.ui.control.Switch
        CorrelationCheckBox             matlab.ui.control.CheckBox
        D21DFcnDropDown_Corr2           matlab.ui.control.DropDown
        UseanotherfunctionLabel_2       matlab.ui.control.Label
        PlotcorrelationButton           matlab.ui.control.Button
        ImageAxes                       matlab.ui.control.UIAxes
        CLimPanel                       matlab.ui.container.Panel
        ColorbarMinEditFieldLabel       matlab.ui.control.Label
        ColorbarMinEditField            matlab.ui.control.NumericEditField
        MaxEditFieldLabel               matlab.ui.control.Label
        MaxEditField                    matlab.ui.control.NumericEditField
        ColormapDropDownLabel           matlab.ui.control.Label
        ColormapDropDown                matlab.ui.control.DropDown
        LockCLimCheckBox                matlab.ui.control.CheckBox
        SavedfilenameLabel              matlab.ui.control.Label
        SavedfilenameEditField          matlab.ui.control.EditField
        SaveplotdataButton              matlab.ui.control.Button
        PrinttologbookButton            matlab.ui.control.Button
        MotivationIndicatorAirspeedIndicatorLabel  matlab.ui.control.Label
        MotivationIndicatorAirspeedIndicator  Aero.ui.control.AirspeedIndicator
        BoostmotivationButton           matlab.ui.control.Button
        WaterfallplotPanel              matlab.ui.container.Panel
        CameraLabel                     matlab.ui.control.Label
        CameraDropDown_WF               matlab.ui.control.DropDown
        D21DFunctionEditField_WF        matlab.ui.control.EditField
        PlotwaterfallButton             matlab.ui.control.Button
        Dto1DFunctionLabel_WF           matlab.ui.control.Label
        SortwaterfallplotPanel          matlab.ui.container.Panel
        ScalarDropDown_WFS              matlab.ui.control.DropDown
        ScalargroupLabel_WFS            matlab.ui.control.Label
        ScalargroupDropDown_WFS         matlab.ui.control.DropDown
        ScalarLabel_WFS                 matlab.ui.control.Label
        CameraLabel_WFS                 matlab.ui.control.Label
        CameraDropDown_WFS              matlab.ui.control.DropDown
        D2SFunctionLabel_WFS            matlab.ui.control.Label
        D2SFunctionEditField_WFS        matlab.ui.control.EditField
        Switch_WFSFS                    matlab.ui.control.Switch
        SortonscalarCheckBox            matlab.ui.control.CheckBox
        PlotsortvaluesCheckBox          matlab.ui.control.CheckBox
        D2SFunctionDropDown_WFS         matlab.ui.control.DropDown
        UseanotherfunctionLabel_3       matlab.ui.control.Label
        Dto1DFunctionLabel              matlab.ui.control.Label
        Dto1DFunctionDropDown_WF        matlab.ui.control.DropDown
        dispImage                       matlab.ui.container.Panel
        ImageincrementEditFieldLabel    matlab.ui.control.Label
        ImageincrementEditField         matlab.ui.control.NumericEditField
        PlotImageButton                 matlab.ui.control.Button
        CameraDropDownLabel             matlab.ui.control.Label
        CameraDropDown_DI               matlab.ui.control.DropDown
        NextImageButton                 matlab.ui.control.Button
        ImagenumberEditFieldLabel       matlab.ui.control.Label
        ImagenumberEditField            matlab.ui.control.NumericEditField
        PreviousImageButton             matlab.ui.control.Button
        LoopThroughallButton            matlab.ui.control.Button
        WaittimesEditFieldLabel         matlab.ui.control.Label
        WaittimesEditField              matlab.ui.control.NumericEditField
        StopButton                      matlab.ui.control.Button
        ImageAnalysisFunctionEditField  matlab.ui.control.EditField
        ApplyImageanalysis2Dto2DCheckBox  matlab.ui.control.CheckBox
        FunctionLabel                   matlab.ui.control.Label
        ImageAnalysisFunctionDD         matlab.ui.control.DropDown
        UseanotherfunctionLabel_4       matlab.ui.control.Label
        MoreFeaturesTab                 matlab.ui.container.Tab
        DANInfoPanel                    matlab.ui.container.Panel
        DataSetInfoTextArea_2Label      matlab.ui.control.Label
        DataSetInfoTextArea_2           matlab.ui.control.TextArea
        DANlogTextArea_2Label           matlab.ui.control.Label
        DANlogTextArea_2                matlab.ui.control.TextArea
        CorrelationMatrixPanel          matlab.ui.container.Panel
        ScalarsLabel                    matlab.ui.control.Label
        ScalarsListBox_CorrM            matlab.ui.control.ListBox
        ShowCorrelationMatrixButton     matlab.ui.control.Button
        ScalargroupDropDownLabel        matlab.ui.control.Label
        ScalargroupDD_CorrM             matlab.ui.control.DropDown
        IncludeincorrmatrixListBoxLabel  matlab.ui.control.Label
        IncludeListBox_CorrM            matlab.ui.control.ListBox
        AddButton                       matlab.ui.control.Button
        RemoveButton                    matlab.ui.control.Button
        PlotsPanel                      matlab.ui.container.Panel
    end

    
    properties (Access = private)
        DANobject % Description
        commonPIDmax = 1;
        commonPIDmin = 1;
        messageLog;
    end
    
    methods (Access = private)
        function getLatestExp(app)
            % Loads the latest DAQ run to the input
            
            % Get latest DAQ number
            app.dataSetID.Value = lcaGetSmart('SIOC:SYS1:ML02:AO400');
            
            %Get latest DAQ experiment
            exp = lcaGetSmart('SIOC:SYS1:ML02:AO398');
            if exp == 0
                exp = 'TEST'
            else
                exp = sprintf('E%d',exp)
            end
            
            app.expDropDown.Value = exp;
        end
        
        function updateDataSetInfo(app)
            %
            %
            iStr = sprintf('Experiment %s, DataSetID = %d \n', ...
                app.DANobject.dataSet.save_info.experiment,app.DANobject.dataSetID);
            tStr = sprintf('Obtained %s \n', ...
                datestr(app.DANobject.dataSet.save_info.local_time));
            cStr = sprintf('Comment: %s \n', ...
                (app.DANobject.dataSet.params.comment{1}));
            dStr = sprintf('Nbr of Cams: %d \n', ...
                (app.DANobject.dataSet.params.num_CAM));
            
            info = sprintf('%s %s %s %s', iStr, tStr, cStr, dStr);
            app.DataSetInfoTextArea.Value = info;
            app.DataSetInfoTextArea_2.Value = info;
        end
        
        function changeSGroupDD(app, sDD, sGDDv)
            % sDD = scalar Drop Down object
            % sGDDv = scalar Group Drop Down value
            
            newScalarList = app.DANobject.getScalarsInGroup(sGDDv);
            sDD.Items = newScalarList; 
        end
        
        function setDropDowns(app)
            listOfCameras = app.DANobject.getListOfCameras();
            app.CameraDropDown_DI.Items = listOfCameras;
            app.CameraDropDown_Corr1.Items = listOfCameras;
            app.CameraDropDown_WF.Items = listOfCameras;
            app.CameraDropDown_Corr2.Items = listOfCameras;
            app.CameraDropDown_WFS.Items = listOfCameras;
            
            scalarGroups = app.DANobject.getScalarGroups();
            
            if ~isempty(scalarGroups)
                app.ScalargroupDropDown_Corr1.Items = scalarGroups;
                app.ScalargroupDropDown_Corr1ValueChanged();
                
                app.ScalargroupDropDown_Corr2.Items = scalarGroups;
                app.ScalargroupDropDown_Corr2ValueChanged();
                
                app.ScalargroupDropDown_WFS.Items = scalarGroups;
                app.ScalargroupDropDown_WFSValueChanged();
                
                app.ScalargroupDD_CorrM.Items = scalarGroups;
                app.ScalargroupDD_CorrMValueChanged();
            else
                app.ScalargroupDropDown_Corr1.Items = {''};
                app.ScalarDropDown_Corr1.Items = {''};
                
                app.ScalargroupDropDown_Corr2.Items = {''};
                app.ScalarDropDown_Corr2.Items = {''};
                
                app.ScalargroupDropDown_WFS.Items = {''};
                app.ScalarDropDown_WFS.Items = {''};
            end
        end
        
        function clearAxis(app)
            cla(app.ImageAxes);
            xlabel(app.ImageAxes,'', 'Interpreter', 'none');
            ylabel(app.ImageAxes,'', 'Interpreter', 'none');
            title(app.ImageAxes,'', 'Interpreter', 'none');
            yyaxis(app.ImageAxes,'right')
            cla(app.ImageAxes);
            yticks(app.ImageAxes,[]);
            ylabel(app.ImageAxes,'', 'Interpreter', 'none');
            yyaxis(app.ImageAxes,'left')
        end
        
        function FS = getFacetScalar(app, sw, scalarDD, cameraDD, funcEF, funcDD)
            if strcmp(sw.Value, 'Scalar')
                FS = {scalarDD.Value};
            elseif strcmp(sw.Value, 'Image')
                camera1 =  cameraDD.Value;
                if strcmp(funcDD.Value,"Other")
                    funkh1 = str2func(funcEF.Value);
                else
                    funkh1 = str2func(funcDD.Value);
                end
                FS = {camera1, funkh1};
            else
                error('Probably sent wrong switch to getFacetScalar')
            end
        end
        
        function UpdateCLim(app)
            if ~app.LockCLimCheckBox.Value
                app.ImageAxes.CLimMode = 'auto';
            end
            app.ColorbarMinEditField.Value = app.ImageAxes.CLim(1);
            app.MaxEditField.Value = app.ImageAxes.CLim(2);
        end
        
        function plotImage(app, imageNumber)
            cameraName = app.CameraDropDown_DI.Value;
            disp(['plotImage: ', cameraName]) %BDO
            applyfcn = app.ApplyImageanalysis2Dto2DCheckBox.Value;
            if ~applyfcn
                app.DANobject.visImage(cameraName, imageNumber);
            else 
                if strcmp(app.ImageAnalysisFunctionDD.Value,'Other')
                    funk = app.ImageAnalysisFunctionEditField.Value;
                else
                    funk = app.ImageAnalysisFunctionDD.Value;
                end
                funkh = str2func(funk);
                app.DANobject.visImage(cameraName, imageNumber, funkh);
            end
            app.UpdateCLim();
        end
    end
    
    methods (Access = public)
        
        function addMsg(app, msg)
            if length(app.messageLog) > 0
                app.messageLog = [app.messageLog, '\n', msg];
            else 
                app.messageLog = msg;
            end
            app.DANlogTextArea.Value = sprintf(app.messageLog);
            app.DANlogTextArea_2.Value = sprintf(app.messageLog);
            
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
%             set(app.dispImage.Children,'Enable','Off')
%             set(app.correlationPlot.Children,'Enable','Off')
            p = genpath('/home/fphysics/shperez/git_work/matlabTNG/F2_DAN/');
            addpath(p);
            app.getLatestExp();
            
        end

        % Button pushed function: LoadDataSetButton
        function LoadDataSetButtonPushed(app, event)
            % Clear old dataset settings
            app.clearAxis();
            app.DataSetInfoTextArea.Value = '';
            
            % Get input
            exp = app.expDropDown.Value;
            dataSetID = app.dataSetID.Value;
            
            try  
                app.DANobject = DataSetDAN(dataSetID,exp,app);
            catch errm
                app.addMsg('Could not find data set')
                return
            end
            
            app.updateDataSetInfo();

            app.setDropDowns;
            
            if ~app.DANobject.dataSet.backgrounds.getBG
                set(app.SubtractImageBackgroundCheckBox,'Enable','Off')
            end  
%           set(app.dispImage.Children,'Enable','On')
%           set(app.correlationPlot.Children,'Enable','On')
        end

        % Button pushed function: PlotImageButton
        function PlotImageButtonPushed(app, event)
            app.clearAxis();
            imageNumber = app.ImagenumberEditField.Value;
            app.plotImage(imageNumber);
        end

        % Value changed function: ImageincrementEditField
        function ImageincrementEditFieldValueChanged(app, event)
            value = app.ImageincrementEditField.Value;
            app.DANobject.visImageIncrement = value;
        end

        % Button pushed function: NextImageButton
        function NextImageButtonPushed(app, event)
            
            imageInc = app.ImageincrementEditField.Value;
            imageNumber = app.ImagenumberEditField.Value + imageInc;
            
            if app.DANobject.validShotNbr(imageNumber)
                app.ImagenumberEditField.Value = imageNumber;
                app.plotImage(imageNumber);
            else
                disp('Next number out of range');
            end
        end

        % Button pushed function: PreviousImageButton
        function PreviousImageButtonPushed(app, event)
            imageInc = app.ImageincrementEditField.Value;
            imageNumber = app.ImagenumberEditField.Value - imageInc;
            
            if app.DANobject.validShotNbr(imageNumber)
                app.ImagenumberEditField.Value = imageNumber;
                app.plotImage(imageNumber);
            else
                disp('Previous number out of range');
            end
        end

        % Button pushed function: LoopThroughallButton
        function LoopThroughallButtonPushed(app, event)
            cameraName = app.CameraDropDown_DI.Value;
            imageNumber = app.ImagenumberEditField.Value;
            
            applyfcnBool = app.ApplyImageanalysis2Dto2DCheckBox.Value;
            if ~applyfcnBool
                app.DANobject.visImages(cameraName, imageNumber);
            else 
                funk = app.ImageAnalysisFunctionEditField.Value;
                funkh = str2func(funk);
                app.DANobject.visImages(cameraName, imageNumber, funkh);
            end
            %app.UpdateCLim();
            %app.DANobject.visImages(cameraName,imageNumber);
        end

        % Button pushed function: StopButton
        function StopButtonPushed(app, event)
            app.DANobject.keepPlotting = 0;
        end

        % Value changed function: WaittimesEditField
        function WaittimesEditFieldValueChanged(app, event)
            value = app.WaittimesEditField.Value;
            
            app.DANobject.loopWaitTime = value;
            
        end

        % Button pushed function: PlotwaterfallButton
        function PlotwaterfallButtonPushed(app, event)
            app.clearAxis();
            camera = app.CameraDropDown_WF.Value;
            if strcmp(app.Dto1DFunctionDropDown_WF.Value,"Other")
                funk = app.D21DFunctionEditField_WF.Value;
            else
                funk = app.Dto1DFunctionDropDown_WF.Value;
            end
            funkh = str2func(funk);
            
            if ~app.SortonscalarCheckBox.Value
                app.DANobject.waterfallPlot(camera,funkh)
            else
                FS = getFacetScalar(app, app.Switch_WFSFS, ...
                    app.ScalarDropDown_WFS, app.CameraDropDown_WFS, ...
                    app.D2SFunctionEditField_WFS, app.D2SFunctionDropDown_WFS);
                
                plotSort = app.PlotsortvaluesCheckBox.Value;
                app.DANobject.waterfallPlot(camera,funkh, FS, plotSort)
            end
        end

        % Button pushed function: PlotcorrelationButton
        function PlotcorrelationButtonPushed(app, event)
            app.clearAxis();
            % Reset Axes after explicitly setting xlim and ylim
            app.ImageAxes.XLimMode = "auto";
            app.ImageAxes.YLimMode = "auto";
            
            
            FS1 = getFacetScalar(app, app.Switch_Corr1FS, ...
                app.ScalarDropDown_Corr1, app.CameraDropDown_Corr1, ...
                app.D21DFunctionEditField_Corr1, app.D21DFcnDropDown_Corr1);
            
            if ~app.CorrelationCheckBox.Value
                if app.HistogramCheckBox.Value
                    app.DANobject.histogramPlot(FS1);
                else
                    try
                        app.DANobject.correlationPlot(FS1);
                    catch
                        % Display error message
                        app.addMsg('Unable to make plot\nCheck that the data set has scalar data');
                    end
                end
                return
            end
            
            FS2 = getFacetScalar(app, app.Switch_Corr2FS, ...
                app.ScalarDropDown_Corr2, app.CameraDropDown_Corr2, ...
                app.D21DFunctionEditField_Corr2, app.D21DFcnDropDown_Corr2);
            
            try
                app.DANobject.correlationPlot(FS1,FS2);
            catch
                % Display error message
                app.addMsg('Unable to make plot. Check that the data set has scalar data.');
            end
        end

        % Value changed function: ScalargroupDropDown_Corr1
        function ScalargroupDropDown_Corr1ValueChanged(app, event)
            value = app.ScalargroupDropDown_Corr1.Value;
            app.changeSGroupDD(app.ScalarDropDown_Corr1, value);
        end

        % Value changed function: ScalargroupDropDown_Corr2
        function ScalargroupDropDown_Corr2ValueChanged(app, event)
            value = app.ScalargroupDropDown_Corr2.Value;
            app.changeSGroupDD(app.ScalarDropDown_Corr2, value);
        end

        % Value changed function: ScalargroupDropDown_WFS
        function ScalargroupDropDown_WFSValueChanged(app, event)
            value = app.ScalargroupDropDown_WFS.Value;
            app.changeSGroupDD(app.ScalarDropDown_WFS, value);
        end

        % Button pushed function: PrinttologbookButton
        function PrinttologbookButtonPushed(app, event)
            fh = figure(101);
            newAx = axes;
            
            % Dunno what this does.
            yyaxis(app.ImageAxes,'right');
            ylabel(newAx, '', 'Interpreter', 'none');

            % Save these 4 parameters because copying to the new axes
            % deletes them from the current axes. For some reason.
            yyaxis(app.ImageAxes,'left');
            titleS = app.ImageAxes.Title.String;
            xlabS = app.ImageAxes.XLabel.String;
            ylabS = app.ImageAxes.YLabel.String;
            yyaxis(app.ImageAxes,'right');
            ylab2S = app.ImageAxes.YLabel.String;
            yyaxis(app.ImageAxes,'left');

            % Copy the properties of the left y-axis and x-axis
            yyaxis(app.ImageAxes,'left');
            
            copyobj(app.ImageAxes.Children, newAx);
            uiAxParams = get(app.ImageAxes);
            uiAxParamsNames = fieldnames(uiAxParams);
            editableParams = fieldnames(set(newAx));
            
            badFields = uiAxParamsNames(~ismember(uiAxParamsNames, editableParams));
            badFields = [badFields; 'Parent'; 'Children'; 'XAxis'; ...
                'YAxis'; 'ZAxis'; 'Position'; 'OuterPosition'; ...
                'InnerPosition'];
            
            uiAxGoodParams = rmfield(uiAxParams, badFields);
            set(newAx, uiAxGoodParams);

 
            % Copy the properties of the right y-axis and x-axis
            yyaxis(app.ImageAxes, 'right');
            yyaxis(newAx, 'right')

            copyobj(app.ImageAxes.Children, newAx);
            uiAxParams = get(app.ImageAxes);
            uiAxParamsNames = fieldnames(uiAxParams);
            editableParams = fieldnames(set(newAx));

            badFields = uiAxParamsNames(~ismember(uiAxParamsNames, editableParams));
            badFields = [badFields; 'Parent'; 'Children'; 'XAxis'; ...
                'YAxis'; 'ZAxis'; 'Position'; 'OuterPosition'; ...
                'InnerPosition'; 'YAxisLocation'; 'Title'; 'XLabel'; 'ZLabel'];

            uiAxGoodParams = rmfield(uiAxParams, badFields);
            set(newAx, uiAxGoodParams);
            
%             Print the figure to the logbook
            print(fh, '-dpsc2', ['-P','physics-facetlog']);
            close(fh)


            % Copy the labels back to the DAN figure in the GUI
            % I dunno why copying gets rid of them on the original figure.
            yyaxis(app.ImageAxes, 'left');
            title(app.ImageAxes, titleS, 'Interpreter', 'none');
            xlabel(app.ImageAxes, xlabS, 'Interpreter', 'none');
            ylabel(app.ImageAxes, ylabS, 'Interpreter', 'none');
            yyaxis(app.ImageAxes,'right');
            ylabel(app.ImageAxes, ylab2S, 'Interpreter', 'none');

            
        end

        % Button pushed function: BoostmotivationButton
        function BoostmotivationButtonPushed(app, event)
            disp("I'm sorry Dave, I'm afraid I can't do that.");
            val = lcaGetSmart('SIOC:SYS1:ML03:AO551');
            val = val - 3;
            lcaPutSmart('SIOC:SYS1:ML03:AO551',val);
            app.MotivationIndicatorAirspeedIndicator.Value = val;
            
        end

        % Value changed function: HistogramCheckBox
        function HistogramCheckBoxValueChanged(app, event)
            value = app.HistogramCheckBox.Value;
            if value
                app.CorrelationCheckBox.Value = 0;
            end
        end

        % Value changed function: CorrelationCheckBox
        function CorrelationCheckBoxValueChanged(app, event)
            value = app.CorrelationCheckBox.Value;
            if value
                app.HistogramCheckBox.Value = 0;
                app.ScalarDropDown_Corr2.Enable = 'on';
                app.ScalargroupDropDown_Corr2.Enable = 'on';
                app.CameraDropDown_Corr2.Enable = 'on';
                app.Switch_Corr2FS.Enable = 'on';
                app.D21DFcnDropDown_Corr2.Enable = 'on';
                app.D21DFcnDropDown_Corr2ValueChanged;
            else
                app.ScalarDropDown_Corr2.Enable = 'off';
                app.ScalargroupDropDown_Corr2.Enable = 'off';
                app.CameraDropDown_Corr2.Enable = 'off';
                app.D21DFunctionEditField_Corr2.Enable = 'off';
                app.Switch_Corr2FS.Enable = 'off';
                app.D21DFcnDropDown_Corr2.Enable = 'off';
            end
        end

        % Value changed function: SubtractImageBackgroundCheckBox
        function SubtractImageBackgroundCheckBoxValueChanged(app, event)
            value = app.SubtractImageBackgroundCheckBox.Value;
            
            app.DANobject.subtractBackground = value;
        end

        % Value changed function: MaxEditField
        function MaxEditFieldValueChanged(app, event)
            value = app.MaxEditField.Value;
            app.ImageAxes.CLim(2) = value;
        end

        % Value changed function: ColorbarMinEditField
        function ColorbarMinEditFieldValueChanged(app, event)
            value = app.ColorbarMinEditField.Value;
            app.ImageAxes.CLim(1) = value;
        end

        % Value changed function: ColormapDropDown
        function ColormapDropDownValueChanged(app, event)
            value = app.ColormapDropDown.Value;
            app.ImageAxes.Colormap = eval(value);
        end

        % Button pushed function: SaveplotdataButton
        function SaveplotdataButtonPushed(app, event)
            fileName = app.SavedfilenameEditField.Value;
            app.DANobject.exportPlotData(fileName);
        end

        % Button pushed function: LastDAQButton
        function LastDAQButtonPushed(app, event)
            app.getLatestExp();
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            delete(app)
            disp('Remember to uncomment the exit command')
%             exit;
        end

        % Value changed function: PlotsortvaluesCheckBox
        function PlotsortvaluesCheckBoxValueChanged(app, event)
            value = app.PlotsortvaluesCheckBox.Value;
            
        end

        % Callback function
        function GaussFitButtonPushed(app, event)
            app.DANobject.PlotGaussFits();
        end

        % Button pushed function: ShowCorrelationMatrixButton
        function CorrMatrixButtonPushed(app, event)
            app.clearAxis();
            app.DANobject.plotCorrMatrix();
        end

        % Value changed function: Dto1DFunctionDropDown_WF
        function Dto1DFunctionDropDown_WFValueChanged(app, event)
            value = app.Dto1DFunctionDropDown_WF.Value;
            if strcmp(value,"Other")
                app.D21DFunctionEditField_WF.Enable = 'on';
            else
                app.D21DFunctionEditField_WF.Enable = 'off';
            end
        end

        % Value changed function: D21DFcnDropDown_Corr1
        function D21DFcnDropDown_Corr1ValueChanged(app, event)
            value = app.D21DFcnDropDown_Corr1.Value;
            if strcmp(value,"Other")
                app.D21DFunctionEditField_Corr1.Enable = 'on';
            else
                app.D21DFunctionEditField_Corr1.Enable = 'off';
            end
        end

        % Value changed function: D21DFcnDropDown_Corr2
        function D21DFcnDropDown_Corr2ValueChanged(app, event)
            value = app.D21DFcnDropDown_Corr2.Value;
            if strcmp(value,"Other")
                app.D21DFunctionEditField_Corr2.Enable = 'on';
            else
                app.D21DFunctionEditField_Corr2.Enable = 'off';
            end
        end

        % Value changed function: D2SFunctionDropDown_WFS
        function D2SFunctionDropDown_WFSValueChanged(app, event)
            value = app.D2SFunctionDropDown_WFS.Value;
            if strcmp(value,"Other")
                app.D2SFunctionEditField_WFS.Enable = 'on';
            else
                app.D2SFunctionEditField_WFS.Enable = 'off';
            end
        end

        % Value changed function: ImageAnalysisFunctionDD
        function ImageAnalysisFunctionDDValueChanged(app, event)
            value = app.ImageAnalysisFunctionDD.Value;
            if strcmp(value,"Other")
                app.ImageAnalysisFunctionEditField.Enable = 'on';
            else
                app.ImageAnalysisFunctionEditField.Enable = 'off';
            end
        end

        % Value changed function: ScalargroupDD_CorrM
        function ScalargroupDD_CorrMValueChanged(app, event)
            value = app.ScalargroupDD_CorrM.Value;
            app.changeSGroupDD(app.ScalarsListBox_CorrM,value);
        end

        % Button pushed function: AddButton
        function AddButtonPushed(app, event)
            selectedScalars = app.ScalarsListBox_CorrM.Value;
            items = app.IncludeListBox_CorrM.Items;
            
            if isempty(items)
                app.IncludeListBox_CorrM.Items = selectedScalars;
            else
                ind = contains(selectedScalars,items);
                items = [items,selectedScalars(~ind)];
                app.IncludeListBox_CorrM.Items = items;
            end
        end

        % Button pushed function: RemoveButton
        function RemoveButtonPushed(app, event)
            value = app.IncludeListBox_CorrM.Value;
            items = app.IncludeListBox_CorrM.Items;
            ind = contains(items,value);
            
            if ~isempty(ind)
                items(ind) = [];
                app.IncludeListBox_CorrM.Items = items;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1247 947];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [1 1 1235 947];

            % Create MainDANTab
            app.MainDANTab = uitab(app.TabGroup);
            app.MainDANTab.Title = 'Main DAN';

            % Create dataSet
            app.dataSet = uipanel(app.MainDANTab);
            app.dataSet.Title = 'Load data';
            app.dataSet.Position = [30 524 326 386];

            % Create ExperimentLabel
            app.ExperimentLabel = uilabel(app.dataSet);
            app.ExperimentLabel.HorizontalAlignment = 'right';
            app.ExperimentLabel.Position = [17 335 67 22];
            app.ExperimentLabel.Text = 'Experiment';

            % Create expDropDown
            app.expDropDown = uidropdown(app.dataSet);
            app.expDropDown.Items = {'TEST', 'E300', 'E301', 'E304', 'E305', 'E308', 'E310', 'E320', 'E324', 'E325', 'E326', 'E327', 'E331', 'E332', 'E338'};
            app.expDropDown.Position = [98 335 124 22];
            app.expDropDown.Value = 'TEST';

            % Create dataSetIDLabel
            app.dataSetIDLabel = uilabel(app.dataSet);
            app.dataSetIDLabel.HorizontalAlignment = 'right';
            app.dataSetIDLabel.Position = [14 304 59 22];
            app.dataSetIDLabel.Text = 'dataSetID';

            % Create dataSetID
            app.dataSetID = uieditfield(app.dataSet, 'numeric');
            app.dataSetID.Limits = [0 Inf];
            app.dataSetID.ValueDisplayFormat = '%d';
            app.dataSetID.Position = [88 304 100 22];
            app.dataSetID.Value = 234;

            % Create LoadDataSetButton
            app.LoadDataSetButton = uibutton(app.dataSet, 'push');
            app.LoadDataSetButton.ButtonPushedFcn = createCallbackFcn(app, @LoadDataSetButtonPushed, true);
            app.LoadDataSetButton.Position = [18 269 100 23];
            app.LoadDataSetButton.Text = 'Load DataSet';

            % Create DANlogTextAreaLabel
            app.DANlogTextAreaLabel = uilabel(app.dataSet);
            app.DANlogTextAreaLabel.HorizontalAlignment = 'right';
            app.DANlogTextAreaLabel.Position = [13 91 52 22];
            app.DANlogTextAreaLabel.Text = 'DAN log';

            % Create DANlogTextArea
            app.DANlogTextArea = uitextarea(app.dataSet);
            app.DANlogTextArea.Position = [11 12 298 80];

            % Create SubtractImageBackgroundCheckBox
            app.SubtractImageBackgroundCheckBox = uicheckbox(app.dataSet);
            app.SubtractImageBackgroundCheckBox.ValueChangedFcn = createCallbackFcn(app, @SubtractImageBackgroundCheckBoxValueChanged, true);
            app.SubtractImageBackgroundCheckBox.Text = {'Subtract Image '; 'Background'};
            app.SubtractImageBackgroundCheckBox.Position = [195 262 107 30];

            % Create DataSetInfoTextAreaLabel
            app.DataSetInfoTextAreaLabel = uilabel(app.dataSet);
            app.DataSetInfoTextAreaLabel.HorizontalAlignment = 'right';
            app.DataSetInfoTextAreaLabel.Position = [17 230 72 22];
            app.DataSetInfoTextAreaLabel.Text = 'DataSet Info';

            % Create DataSetInfoTextArea
            app.DataSetInfoTextArea = uitextarea(app.dataSet);
            app.DataSetInfoTextArea.Position = [13 121 294 108];

            % Create LastDAQButton
            app.LastDAQButton = uibutton(app.dataSet, 'push');
            app.LastDAQButton.ButtonPushedFcn = createCallbackFcn(app, @LastDAQButtonPushed, true);
            app.LastDAQButton.Position = [233 313 69 25];
            app.LastDAQButton.Text = 'Last DAQ';

            % Create correlationPlot
            app.correlationPlot = uipanel(app.MainDANTab);
            app.correlationPlot.Title = 'Scalar plots';
            app.correlationPlot.Position = [30 7 326 511];

            % Create FACETScalarArray1Panel
            app.FACETScalarArray1Panel = uipanel(app.correlationPlot);
            app.FACETScalarArray1Panel.Title = 'FACET Scalar Array 1';
            app.FACETScalarArray1Panel.Position = [11 275 304 208];

            % Create ScalarDropDown_Corr1
            app.ScalarDropDown_Corr1 = uidropdown(app.FACETScalarArray1Panel);
            app.ScalarDropDown_Corr1.Items = {};
            app.ScalarDropDown_Corr1.Position = [8 60 117 22];
            app.ScalarDropDown_Corr1.Value = {};

            % Create ScalargroupLabel_Corr1
            app.ScalargroupLabel_Corr1 = uilabel(app.FACETScalarArray1Panel);
            app.ScalargroupLabel_Corr1.Position = [7 134 78 22];
            app.ScalargroupLabel_Corr1.Text = 'Scalar group:';

            % Create ScalarLabel_Corr1
            app.ScalarLabel_Corr1 = uilabel(app.FACETScalarArray1Panel);
            app.ScalarLabel_Corr1.Position = [9 81 43 22];
            app.ScalarLabel_Corr1.Text = 'Scalar:';

            % Create ScalargroupDropDown_Corr1
            app.ScalargroupDropDown_Corr1 = uidropdown(app.FACETScalarArray1Panel);
            app.ScalargroupDropDown_Corr1.Items = {};
            app.ScalargroupDropDown_Corr1.ValueChangedFcn = createCallbackFcn(app, @ScalargroupDropDown_Corr1ValueChanged, true);
            app.ScalargroupDropDown_Corr1.Position = [8 112 117 22];
            app.ScalargroupDropDown_Corr1.Value = {};

            % Create CameraDropDown_Corr1
            app.CameraDropDown_Corr1 = uidropdown(app.FACETScalarArray1Panel);
            app.CameraDropDown_Corr1.Items = {};
            app.CameraDropDown_Corr1.Position = [151 112 131 22];
            app.CameraDropDown_Corr1.Value = {};

            % Create CameraLabel_Corr1
            app.CameraLabel_Corr1 = uilabel(app.FACETScalarArray1Panel);
            app.CameraLabel_Corr1.Position = [151 134 52 22];
            app.CameraLabel_Corr1.Text = 'Camera:';

            % Create DtoscalarfunctionLabel_Corr1
            app.DtoscalarfunctionLabel_Corr1 = uilabel(app.FACETScalarArray1Panel);
            app.DtoscalarfunctionLabel_Corr1.Position = [151 81 119 22];
            app.DtoscalarfunctionLabel_Corr1.Text = '2D to scalar function:';

            % Create D21DFunctionEditField_Corr1
            app.D21DFunctionEditField_Corr1 = uieditfield(app.FACETScalarArray1Panel, 'text');
            app.D21DFunctionEditField_Corr1.Enable = 'off';
            app.D21DFunctionEditField_Corr1.Position = [15 7 276 24];
            app.D21DFunctionEditField_Corr1.Value = '@(x)sum(sum(x))';

            % Create Switch_Corr1FS
            app.Switch_Corr1FS = uiswitch(app.FACETScalarArray1Panel, 'slider');
            app.Switch_Corr1FS.Items = {'Scalar', 'Image'};
            app.Switch_Corr1FS.Position = [192 161 45 20];
            app.Switch_Corr1FS.Value = 'Scalar';

            % Create HistogramCheckBox
            app.HistogramCheckBox = uicheckbox(app.FACETScalarArray1Panel);
            app.HistogramCheckBox.ValueChangedFcn = createCallbackFcn(app, @HistogramCheckBoxValueChanged, true);
            app.HistogramCheckBox.Text = 'Histogram';
            app.HistogramCheckBox.Position = [12 160 78 22];

            % Create D21DFcnDropDown_Corr1
            app.D21DFcnDropDown_Corr1 = uidropdown(app.FACETScalarArray1Panel);
            app.D21DFcnDropDown_Corr1.Items = {'@(x)sum(sum(x))', 'Other'};
            app.D21DFcnDropDown_Corr1.ValueChangedFcn = createCallbackFcn(app, @D21DFcnDropDown_Corr1ValueChanged, true);
            app.D21DFcnDropDown_Corr1.Position = [151 60 131 22];
            app.D21DFcnDropDown_Corr1.Value = '@(x)sum(sum(x))';

            % Create UseanotherfunctionLabel
            app.UseanotherfunctionLabel = uilabel(app.FACETScalarArray1Panel);
            app.UseanotherfunctionLabel.Position = [14 29 120 22];
            app.UseanotherfunctionLabel.Text = 'Use another function:';

            % Create FACETScalarArray2Panel
            app.FACETScalarArray2Panel = uipanel(app.correlationPlot);
            app.FACETScalarArray2Panel.Title = 'FACET Scalar Array 2';
            app.FACETScalarArray2Panel.Position = [13 65 302 202];

            % Create ScalarDropDown_Corr2
            app.ScalarDropDown_Corr2 = uidropdown(app.FACETScalarArray2Panel);
            app.ScalarDropDown_Corr2.Items = {};
            app.ScalarDropDown_Corr2.Enable = 'off';
            app.ScalarDropDown_Corr2.Position = [6 61 115 22];
            app.ScalarDropDown_Corr2.Value = {};

            % Create ScalargroupLabel_Corr2
            app.ScalargroupLabel_Corr2 = uilabel(app.FACETScalarArray2Panel);
            app.ScalargroupLabel_Corr2.Position = [7 128 78 22];
            app.ScalargroupLabel_Corr2.Text = 'Scalar group:';

            % Create ScalarLabel_Corr2
            app.ScalarLabel_Corr2 = uilabel(app.FACETScalarArray2Panel);
            app.ScalarLabel_Corr2.Position = [7 81 43 22];
            app.ScalarLabel_Corr2.Text = 'Scalar:';

            % Create ScalargroupDropDown_Corr2
            app.ScalargroupDropDown_Corr2 = uidropdown(app.FACETScalarArray2Panel);
            app.ScalargroupDropDown_Corr2.Items = {};
            app.ScalargroupDropDown_Corr2.ValueChangedFcn = createCallbackFcn(app, @ScalargroupDropDown_Corr2ValueChanged, true);
            app.ScalargroupDropDown_Corr2.Enable = 'off';
            app.ScalargroupDropDown_Corr2.Position = [6 107 115 22];
            app.ScalargroupDropDown_Corr2.Value = {};

            % Create CameraDropDown_Corr2
            app.CameraDropDown_Corr2 = uidropdown(app.FACETScalarArray2Panel);
            app.CameraDropDown_Corr2.Items = {};
            app.CameraDropDown_Corr2.Enable = 'off';
            app.CameraDropDown_Corr2.Position = [149 107 131 22];
            app.CameraDropDown_Corr2.Value = {};

            % Create CameraLabel_Corr2
            app.CameraLabel_Corr2 = uilabel(app.FACETScalarArray2Panel);
            app.CameraLabel_Corr2.Position = [151 128 52 22];
            app.CameraLabel_Corr2.Text = 'Camera:';

            % Create DtoscalarfunctionLabel_Corr2
            app.DtoscalarfunctionLabel_Corr2 = uilabel(app.FACETScalarArray2Panel);
            app.DtoscalarfunctionLabel_Corr2.Position = [151 81 119 22];
            app.DtoscalarfunctionLabel_Corr2.Text = '2D to scalar function:';

            % Create D21DFunctionEditField_Corr2
            app.D21DFunctionEditField_Corr2 = uieditfield(app.FACETScalarArray2Panel, 'text');
            app.D21DFunctionEditField_Corr2.Enable = 'off';
            app.D21DFunctionEditField_Corr2.Position = [12 7 276 24];
            app.D21DFunctionEditField_Corr2.Value = '@(x)sum(sum(x))';

            % Create Switch_Corr2FS
            app.Switch_Corr2FS = uiswitch(app.FACETScalarArray2Panel, 'slider');
            app.Switch_Corr2FS.Items = {'Scalar', 'Image'};
            app.Switch_Corr2FS.Enable = 'off';
            app.Switch_Corr2FS.Position = [192 154 45 20];
            app.Switch_Corr2FS.Value = 'Scalar';

            % Create CorrelationCheckBox
            app.CorrelationCheckBox = uicheckbox(app.FACETScalarArray2Panel);
            app.CorrelationCheckBox.ValueChangedFcn = createCallbackFcn(app, @CorrelationCheckBoxValueChanged, true);
            app.CorrelationCheckBox.Text = 'Correlation';
            app.CorrelationCheckBox.Position = [13 153 83 22];

            % Create D21DFcnDropDown_Corr2
            app.D21DFcnDropDown_Corr2 = uidropdown(app.FACETScalarArray2Panel);
            app.D21DFcnDropDown_Corr2.Items = {'@(x)sum(sum(x))', 'Other'};
            app.D21DFcnDropDown_Corr2.ValueChangedFcn = createCallbackFcn(app, @D21DFcnDropDown_Corr2ValueChanged, true);
            app.D21DFcnDropDown_Corr2.Enable = 'off';
            app.D21DFcnDropDown_Corr2.Position = [149 61 132 22];
            app.D21DFcnDropDown_Corr2.Value = '@(x)sum(sum(x))';

            % Create UseanotherfunctionLabel_2
            app.UseanotherfunctionLabel_2 = uilabel(app.FACETScalarArray2Panel);
            app.UseanotherfunctionLabel_2.Position = [12 32 120 22];
            app.UseanotherfunctionLabel_2.Text = 'Use another function:';

            % Create PlotcorrelationButton
            app.PlotcorrelationButton = uibutton(app.correlationPlot, 'push');
            app.PlotcorrelationButton.ButtonPushedFcn = createCallbackFcn(app, @PlotcorrelationButtonPushed, true);
            app.PlotcorrelationButton.Position = [92 8 135 51];
            app.PlotcorrelationButton.Text = 'Plot correlation';

            % Create ImageAxes
            app.ImageAxes = uiaxes(app.MainDANTab);
            title(app.ImageAxes, 'Title')
            xlabel(app.ImageAxes, 'X')
            ylabel(app.ImageAxes, 'Y')
            app.ImageAxes.Position = [405 401 803 509];

            % Create CLimPanel
            app.CLimPanel = uipanel(app.MainDANTab);
            app.CLimPanel.Title = 'CLim';
            app.CLimPanel.Position = [964 261 260 122];

            % Create ColorbarMinEditFieldLabel
            app.ColorbarMinEditFieldLabel = uilabel(app.CLimPanel);
            app.ColorbarMinEditFieldLabel.Position = [13 12 76 22];
            app.ColorbarMinEditFieldLabel.Text = 'Colorbar Min';

            % Create ColorbarMinEditField
            app.ColorbarMinEditField = uieditfield(app.CLimPanel, 'numeric');
            app.ColorbarMinEditField.ValueChangedFcn = createCallbackFcn(app, @ColorbarMinEditFieldValueChanged, true);
            app.ColorbarMinEditField.HorizontalAlignment = 'left';
            app.ColorbarMinEditField.Position = [92 12 37 22];

            % Create MaxEditFieldLabel
            app.MaxEditFieldLabel = uilabel(app.CLimPanel);
            app.MaxEditFieldLabel.Position = [145 12 30 22];
            app.MaxEditFieldLabel.Text = 'Max';

            % Create MaxEditField
            app.MaxEditField = uieditfield(app.CLimPanel, 'numeric');
            app.MaxEditField.ValueChangedFcn = createCallbackFcn(app, @MaxEditFieldValueChanged, true);
            app.MaxEditField.Position = [174 12 39 22];

            % Create ColormapDropDownLabel
            app.ColormapDropDownLabel = uilabel(app.CLimPanel);
            app.ColormapDropDownLabel.Position = [13 48 59 22];
            app.ColormapDropDownLabel.Text = 'Colormap';

            % Create ColormapDropDown
            app.ColormapDropDown = uidropdown(app.CLimPanel);
            app.ColormapDropDown.Items = {'Bengt', 'parula', 'jet', 'gray'};
            app.ColormapDropDown.ValueChangedFcn = createCallbackFcn(app, @ColormapDropDownValueChanged, true);
            app.ColormapDropDown.Position = [78 47 164 22];
            app.ColormapDropDown.Value = 'parula';

            % Create LockCLimCheckBox
            app.LockCLimCheckBox = uicheckbox(app.CLimPanel);
            app.LockCLimCheckBox.Text = 'Lock CLim';
            app.LockCLimCheckBox.Position = [13 76 80 22];

            % Create SavedfilenameLabel
            app.SavedfilenameLabel = uilabel(app.MainDANTab);
            app.SavedfilenameLabel.Position = [964 224 96 22];
            app.SavedfilenameLabel.Text = 'Saved file name:';

            % Create SavedfilenameEditField
            app.SavedfilenameEditField = uieditfield(app.MainDANTab, 'text');
            app.SavedfilenameEditField.Position = [1068 224 152 22];
            app.SavedfilenameEditField.Value = 'myPlotName';

            % Create SaveplotdataButton
            app.SaveplotdataButton = uibutton(app.MainDANTab, 'push');
            app.SaveplotdataButton.ButtonPushedFcn = createCallbackFcn(app, @SaveplotdataButtonPushed, true);
            app.SaveplotdataButton.Position = [1000 191 184 23];
            app.SaveplotdataButton.Text = 'Save plot data';

            % Create PrinttologbookButton
            app.PrinttologbookButton = uibutton(app.MainDANTab, 'push');
            app.PrinttologbookButton.ButtonPushedFcn = createCallbackFcn(app, @PrinttologbookButtonPushed, true);
            app.PrinttologbookButton.BackgroundColor = [0 1 0];
            app.PrinttologbookButton.Position = [1092 27 129 128];
            app.PrinttologbookButton.Text = {'Print to '; 'logbook'};

            % Create MotivationIndicatorAirspeedIndicatorLabel
            app.MotivationIndicatorAirspeedIndicatorLabel = uilabel(app.MainDANTab);
            app.MotivationIndicatorAirspeedIndicatorLabel.HorizontalAlignment = 'center';
            app.MotivationIndicatorAirspeedIndicatorLabel.Position = [962 26 111 22];
            app.MotivationIndicatorAirspeedIndicatorLabel.Text = 'Motivation Indicator';

            % Create MotivationIndicatorAirspeedIndicator
            app.MotivationIndicatorAirspeedIndicator = uiaeroairspeed(app.MainDANTab);
            app.MotivationIndicatorAirspeedIndicator.Position = [978 45 81 81];
            app.MotivationIndicatorAirspeedIndicator.Airspeed = 50;

            % Create BoostmotivationButton
            app.BoostmotivationButton = uibutton(app.MainDANTab, 'push');
            app.BoostmotivationButton.ButtonPushedFcn = createCallbackFcn(app, @BoostmotivationButtonPushed, true);
            app.BoostmotivationButton.Position = [964 133 105 23];
            app.BoostmotivationButton.Text = 'Boost motivation';

            % Create WaterfallplotPanel
            app.WaterfallplotPanel = uipanel(app.MainDANTab);
            app.WaterfallplotPanel.Title = 'Waterfall plot';
            app.WaterfallplotPanel.Position = [374 7 299 392];

            % Create CameraLabel
            app.CameraLabel = uilabel(app.WaterfallplotPanel);
            app.CameraLabel.Position = [12 345 52 22];
            app.CameraLabel.Text = 'Camera:';

            % Create CameraDropDown_WF
            app.CameraDropDown_WF = uidropdown(app.WaterfallplotPanel);
            app.CameraDropDown_WF.Items = {};
            app.CameraDropDown_WF.Position = [12 324 107 22];
            app.CameraDropDown_WF.Value = {};

            % Create D21DFunctionEditField_WF
            app.D21DFunctionEditField_WF = uieditfield(app.WaterfallplotPanel, 'text');
            app.D21DFunctionEditField_WF.Enable = 'off';
            app.D21DFunctionEditField_WF.Position = [16 271 252 27];

            % Create PlotwaterfallButton
            app.PlotwaterfallButton = uibutton(app.WaterfallplotPanel, 'push');
            app.PlotwaterfallButton.ButtonPushedFcn = createCallbackFcn(app, @PlotwaterfallButtonPushed, true);
            app.PlotwaterfallButton.Position = [81 234 122 29];
            app.PlotwaterfallButton.Text = 'Plot waterfall';

            % Create Dto1DFunctionLabel_WF
            app.Dto1DFunctionLabel_WF = uilabel(app.WaterfallplotPanel);
            app.Dto1DFunctionLabel_WF.Position = [16 298 120 22];
            app.Dto1DFunctionLabel_WF.Text = 'Use another function:';

            % Create SortwaterfallplotPanel
            app.SortwaterfallplotPanel = uipanel(app.WaterfallplotPanel);
            app.SortwaterfallplotPanel.Title = 'Sort waterfall plot';
            app.SortwaterfallplotPanel.Position = [12 10 276 218];

            % Create ScalarDropDown_WFS
            app.ScalarDropDown_WFS = uidropdown(app.SortwaterfallplotPanel);
            app.ScalarDropDown_WFS.Items = {};
            app.ScalarDropDown_WFS.Position = [7 60 105 22];
            app.ScalarDropDown_WFS.Value = {};

            % Create ScalargroupLabel_WFS
            app.ScalargroupLabel_WFS = uilabel(app.SortwaterfallplotPanel);
            app.ScalargroupLabel_WFS.Position = [7 124 78 22];
            app.ScalargroupLabel_WFS.Text = 'Scalar group:';

            % Create ScalargroupDropDown_WFS
            app.ScalargroupDropDown_WFS = uidropdown(app.SortwaterfallplotPanel);
            app.ScalargroupDropDown_WFS.Items = {};
            app.ScalargroupDropDown_WFS.ValueChangedFcn = createCallbackFcn(app, @ScalargroupDropDown_WFSValueChanged, true);
            app.ScalargroupDropDown_WFS.Position = [7 103 105 22];
            app.ScalargroupDropDown_WFS.Value = {};

            % Create ScalarLabel_WFS
            app.ScalarLabel_WFS = uilabel(app.SortwaterfallplotPanel);
            app.ScalarLabel_WFS.Position = [7 78 43 22];
            app.ScalarLabel_WFS.Text = 'Scalar:';

            % Create CameraLabel_WFS
            app.CameraLabel_WFS = uilabel(app.SortwaterfallplotPanel);
            app.CameraLabel_WFS.Position = [138 124 52 22];
            app.CameraLabel_WFS.Text = 'Camera:';

            % Create CameraDropDown_WFS
            app.CameraDropDown_WFS = uidropdown(app.SortwaterfallplotPanel);
            app.CameraDropDown_WFS.Items = {};
            app.CameraDropDown_WFS.Position = [138 103 123 22];
            app.CameraDropDown_WFS.Value = {};

            % Create D2SFunctionLabel_WFS
            app.D2SFunctionLabel_WFS = uilabel(app.SortwaterfallplotPanel);
            app.D2SFunctionLabel_WFS.Position = [138 78 118 22];
            app.D2SFunctionLabel_WFS.Text = '2D to scalar function:';

            % Create D2SFunctionEditField_WFS
            app.D2SFunctionEditField_WFS = uieditfield(app.SortwaterfallplotPanel, 'text');
            app.D2SFunctionEditField_WFS.Enable = 'off';
            app.D2SFunctionEditField_WFS.Position = [19 8 214 24];
            app.D2SFunctionEditField_WFS.Value = '@(x)sum(sum(x))';

            % Create Switch_WFSFS
            app.Switch_WFSFS = uiswitch(app.SortwaterfallplotPanel, 'slider');
            app.Switch_WFSFS.Items = {'Scalar', 'Image'};
            app.Switch_WFSFS.Position = [177 163 45 20];
            app.Switch_WFSFS.Value = 'Scalar';

            % Create SortonscalarCheckBox
            app.SortonscalarCheckBox = uicheckbox(app.SortwaterfallplotPanel);
            app.SortonscalarCheckBox.Text = 'Sort on scalar';
            app.SortonscalarCheckBox.Position = [5 174 97 22];

            % Create PlotsortvaluesCheckBox
            app.PlotsortvaluesCheckBox = uicheckbox(app.SortwaterfallplotPanel);
            app.PlotsortvaluesCheckBox.ValueChangedFcn = createCallbackFcn(app, @PlotsortvaluesCheckBoxValueChanged, true);
            app.PlotsortvaluesCheckBox.Text = 'Plot sort values';
            app.PlotsortvaluesCheckBox.Position = [5 149 105 22];

            % Create D2SFunctionDropDown_WFS
            app.D2SFunctionDropDown_WFS = uidropdown(app.SortwaterfallplotPanel);
            app.D2SFunctionDropDown_WFS.Items = {'@(x)sum(sum(x))', 'Other'};
            app.D2SFunctionDropDown_WFS.ValueChangedFcn = createCallbackFcn(app, @D2SFunctionDropDown_WFSValueChanged, true);
            app.D2SFunctionDropDown_WFS.Position = [138 60 123 22];
            app.D2SFunctionDropDown_WFS.Value = '@(x)sum(sum(x))';

            % Create UseanotherfunctionLabel_3
            app.UseanotherfunctionLabel_3 = uilabel(app.SortwaterfallplotPanel);
            app.UseanotherfunctionLabel_3.Position = [19 30 120 22];
            app.UseanotherfunctionLabel_3.Text = 'Use another function:';

            % Create Dto1DFunctionLabel
            app.Dto1DFunctionLabel = uilabel(app.WaterfallplotPanel);
            app.Dto1DFunctionLabel.Position = [137 345 106 22];
            app.Dto1DFunctionLabel.Text = '2D to 1D Function:';

            % Create Dto1DFunctionDropDown_WF
            app.Dto1DFunctionDropDown_WF = uidropdown(app.WaterfallplotPanel);
            app.Dto1DFunctionDropDown_WF.Items = {'@(x)(sum(x)./max(sum(x)))', 'Other'};
            app.Dto1DFunctionDropDown_WF.ValueChangedFcn = createCallbackFcn(app, @Dto1DFunctionDropDown_WFValueChanged, true);
            app.Dto1DFunctionDropDown_WF.Position = [135 324 153 22];
            app.Dto1DFunctionDropDown_WF.Value = '@(x)(sum(x)./max(sum(x)))';

            % Create dispImage
            app.dispImage = uipanel(app.MainDANTab);
            app.dispImage.Title = 'Image view';
            app.dispImage.Position = [688 10 262 374];

            % Create ImageincrementEditFieldLabel
            app.ImageincrementEditFieldLabel = uilabel(app.dispImage);
            app.ImageincrementEditFieldLabel.HorizontalAlignment = 'right';
            app.ImageincrementEditFieldLabel.Position = [30 143 93 22];
            app.ImageincrementEditFieldLabel.Text = 'Image increment';

            % Create ImageincrementEditField
            app.ImageincrementEditField = uieditfield(app.dispImage, 'numeric');
            app.ImageincrementEditField.Limits = [1 Inf];
            app.ImageincrementEditField.ValueChangedFcn = createCallbackFcn(app, @ImageincrementEditFieldValueChanged, true);
            app.ImageincrementEditField.Position = [133 143 100 22];
            app.ImageincrementEditField.Value = 1;

            % Create PlotImageButton
            app.PlotImageButton = uibutton(app.dispImage, 'push');
            app.PlotImageButton.ButtonPushedFcn = createCallbackFcn(app, @PlotImageButtonPushed, true);
            app.PlotImageButton.Position = [152 288 90 30];
            app.PlotImageButton.Text = 'Plot Image';

            % Create CameraDropDownLabel
            app.CameraDropDownLabel = uilabel(app.dispImage);
            app.CameraDropDownLabel.HorizontalAlignment = 'right';
            app.CameraDropDownLabel.Position = [10 322 49 22];
            app.CameraDropDownLabel.Text = 'Camera';

            % Create CameraDropDown_DI
            app.CameraDropDown_DI = uidropdown(app.dispImage);
            app.CameraDropDown_DI.Items = {};
            app.CameraDropDown_DI.Position = [74 322 165 22];
            app.CameraDropDown_DI.Value = {};

            % Create NextImageButton
            app.NextImageButton = uibutton(app.dispImage, 'push');
            app.NextImageButton.ButtonPushedFcn = createCallbackFcn(app, @NextImageButtonPushed, true);
            app.NextImageButton.Position = [140 105 92 23];
            app.NextImageButton.Text = 'Next Image';

            % Create ImagenumberEditFieldLabel
            app.ImagenumberEditFieldLabel = uilabel(app.dispImage);
            app.ImagenumberEditFieldLabel.HorizontalAlignment = 'right';
            app.ImagenumberEditFieldLabel.Position = [11 291 84 22];
            app.ImagenumberEditFieldLabel.Text = 'Image number';

            % Create ImagenumberEditField
            app.ImagenumberEditField = uieditfield(app.dispImage, 'numeric');
            app.ImagenumberEditField.Position = [103 291 38 22];
            app.ImagenumberEditField.Value = 1;

            % Create PreviousImageButton
            app.PreviousImageButton = uibutton(app.dispImage, 'push');
            app.PreviousImageButton.ButtonPushedFcn = createCallbackFcn(app, @PreviousImageButtonPushed, true);
            app.PreviousImageButton.Position = [30 105 91 23];
            app.PreviousImageButton.Text = 'Previous Image';

            % Create LoopThroughallButton
            app.LoopThroughallButton = uibutton(app.dispImage, 'push');
            app.LoopThroughallButton.ButtonPushedFcn = createCallbackFcn(app, @LoopThroughallButtonPushed, true);
            app.LoopThroughallButton.Position = [66 37 129 26];
            app.LoopThroughallButton.Text = 'Loop Through all';

            % Create WaittimesEditFieldLabel
            app.WaittimesEditFieldLabel = uilabel(app.dispImage);
            app.WaittimesEditFieldLabel.HorizontalAlignment = 'right';
            app.WaittimesEditFieldLabel.Position = [67 73 70 22];
            app.WaittimesEditFieldLabel.Text = 'Wait time [s]';

            % Create WaittimesEditField
            app.WaittimesEditField = uieditfield(app.dispImage, 'numeric');
            app.WaittimesEditField.Limits = [0.1 Inf];
            app.WaittimesEditField.ValueChangedFcn = createCallbackFcn(app, @WaittimesEditFieldValueChanged, true);
            app.WaittimesEditField.Position = [164 73 31 22];
            app.WaittimesEditField.Value = 0.5;

            % Create StopButton
            app.StopButton = uibutton(app.dispImage, 'push');
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);
            app.StopButton.Position = [84 7 93 26];
            app.StopButton.Text = 'Stop';

            % Create ImageAnalysisFunctionEditField
            app.ImageAnalysisFunctionEditField = uieditfield(app.dispImage, 'text');
            app.ImageAnalysisFunctionEditField.Enable = 'off';
            app.ImageAnalysisFunctionEditField.Position = [13 175 236 24];
            app.ImageAnalysisFunctionEditField.Value = '@(x)abs(fftshift(fft2(x)))';

            % Create ApplyImageanalysis2Dto2DCheckBox
            app.ApplyImageanalysis2Dto2DCheckBox = uicheckbox(app.dispImage);
            app.ApplyImageanalysis2Dto2DCheckBox.Text = 'Apply Image analysis (2D to 2D)';
            app.ApplyImageanalysis2Dto2DCheckBox.Position = [23 263 198 22];

            % Create FunctionLabel
            app.FunctionLabel = uilabel(app.dispImage);
            app.FunctionLabel.Position = [14 234 61 22];
            app.FunctionLabel.Text = 'Function:';

            % Create ImageAnalysisFunctionDD
            app.ImageAnalysisFunctionDD = uidropdown(app.dispImage);
            app.ImageAnalysisFunctionDD.Items = {'@(x)abs(fftshift(fft2(x)))', 'Other'};
            app.ImageAnalysisFunctionDD.ValueChangedFcn = createCallbackFcn(app, @ImageAnalysisFunctionDDValueChanged, true);
            app.ImageAnalysisFunctionDD.Position = [70 234 179 22];
            app.ImageAnalysisFunctionDD.Value = '@(x)abs(fftshift(fft2(x)))';

            % Create UseanotherfunctionLabel_4
            app.UseanotherfunctionLabel_4 = uilabel(app.dispImage);
            app.UseanotherfunctionLabel_4.Position = [13 203 120 22];
            app.UseanotherfunctionLabel_4.Text = 'Use another function:';

            % Create MoreFeaturesTab
            app.MoreFeaturesTab = uitab(app.TabGroup);
            app.MoreFeaturesTab.Title = 'More Features';

            % Create DANInfoPanel
            app.DANInfoPanel = uipanel(app.MoreFeaturesTab);
            app.DANInfoPanel.Title = 'DAN Info';
            app.DANInfoPanel.Position = [30 590 334 320];

            % Create DataSetInfoTextArea_2Label
            app.DataSetInfoTextArea_2Label = uilabel(app.DANInfoPanel);
            app.DataSetInfoTextArea_2Label.Position = [17 255 72 22];
            app.DataSetInfoTextArea_2Label.Text = 'DataSet Info';

            % Create DataSetInfoTextArea_2
            app.DataSetInfoTextArea_2 = uitextarea(app.DANInfoPanel);
            app.DataSetInfoTextArea_2.Position = [15 146 304 109];

            % Create DANlogTextArea_2Label
            app.DANlogTextArea_2Label = uilabel(app.DANInfoPanel);
            app.DANlogTextArea_2Label.Position = [16 95 50 22];
            app.DANlogTextArea_2Label.Text = 'DAN log';

            % Create DANlogTextArea_2
            app.DANlogTextArea_2 = uitextarea(app.DANInfoPanel);
            app.DANlogTextArea_2.Position = [15 14 305 82];

            % Create CorrelationMatrixPanel
            app.CorrelationMatrixPanel = uipanel(app.MoreFeaturesTab);
            app.CorrelationMatrixPanel.Title = 'Correlation Matrix';
            app.CorrelationMatrixPanel.Position = [31 15 333 558];

            % Create ScalarsLabel
            app.ScalarsLabel = uilabel(app.CorrelationMatrixPanel);
            app.ScalarsLabel.Position = [15 470 49 22];
            app.ScalarsLabel.Text = 'Scalars:';

            % Create ScalarsListBox_CorrM
            app.ScalarsListBox_CorrM = uilistbox(app.CorrelationMatrixPanel);
            app.ScalarsListBox_CorrM.Items = {};
            app.ScalarsListBox_CorrM.Multiselect = 'on';
            app.ScalarsListBox_CorrM.Position = [14 326 300 145];
            app.ScalarsListBox_CorrM.Value = {};

            % Create ShowCorrelationMatrixButton
            app.ShowCorrelationMatrixButton = uibutton(app.CorrelationMatrixPanel, 'push');
            app.ShowCorrelationMatrixButton.ButtonPushedFcn = createCallbackFcn(app, @CorrMatrixButtonPushed, true);
            app.ShowCorrelationMatrixButton.Position = [86 16 146 42];
            app.ShowCorrelationMatrixButton.Text = 'Show Correlation Matrix';

            % Create ScalargroupDropDownLabel
            app.ScalargroupDropDownLabel = uilabel(app.CorrelationMatrixPanel);
            app.ScalargroupDropDownLabel.Position = [13 500 77 22];
            app.ScalargroupDropDownLabel.Text = 'Scalar group:';

            % Create ScalargroupDD_CorrM
            app.ScalargroupDD_CorrM = uidropdown(app.CorrelationMatrixPanel);
            app.ScalargroupDD_CorrM.Items = {};
            app.ScalargroupDD_CorrM.ValueChangedFcn = createCallbackFcn(app, @ScalargroupDD_CorrMValueChanged, true);
            app.ScalargroupDD_CorrM.Position = [105 500 211 22];
            app.ScalargroupDD_CorrM.Value = {};

            % Create IncludeincorrmatrixListBoxLabel
            app.IncludeincorrmatrixListBoxLabel = uilabel(app.CorrelationMatrixPanel);
            app.IncludeincorrmatrixListBoxLabel.Position = [19 262 120 22];
            app.IncludeincorrmatrixListBoxLabel.Text = 'Include in corr matrix:';

            % Create IncludeListBox_CorrM
            app.IncludeListBox_CorrM = uilistbox(app.CorrelationMatrixPanel);
            app.IncludeListBox_CorrM.Items = {};
            app.IncludeListBox_CorrM.Multiselect = 'on';
            app.IncludeListBox_CorrM.Position = [19 87 296 174];
            app.IncludeListBox_CorrM.Value = {};

            % Create AddButton
            app.AddButton = uibutton(app.CorrelationMatrixPanel, 'push');
            app.AddButton.ButtonPushedFcn = createCallbackFcn(app, @AddButtonPushed, true);
            app.AddButton.Position = [86 296 68 22];
            app.AddButton.Text = 'Add';

            % Create RemoveButton
            app.RemoveButton = uibutton(app.CorrelationMatrixPanel, 'push');
            app.RemoveButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveButtonPushed, true);
            app.RemoveButton.Position = [164 296 68 22];
            app.RemoveButton.Text = 'Remove';

            % Create PlotsPanel
            app.PlotsPanel = uipanel(app.MoreFeaturesTab);
            app.PlotsPanel.Title = 'Plots';
            app.PlotsPanel.Position = [386 328 827 582];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_DAN_HDF5_exported

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