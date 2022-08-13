classdef F2_DAN_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
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
        PlotcorrelationButton           matlab.ui.control.Button
        ImageAxes                       matlab.ui.control.UIAxes
        WaterfallplotPanel              matlab.ui.container.Panel
        CameraDropDown_3Label           matlab.ui.control.Label
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
        MotivationIndicatorAirspeedIndicatorLabel  matlab.ui.control.Label
        MotivationIndicatorAirspeedIndicator  Aero.ui.control.AirspeedIndicator
        PrinttologbookButton            matlab.ui.control.Button
        BoostmotivationButton           matlab.ui.control.Button
        CLimPanel                       matlab.ui.container.Panel
        ColorbarMinEditFieldLabel       matlab.ui.control.Label
        ColorbarMinEditField            matlab.ui.control.NumericEditField
        ColorbarMaxEditFieldLabel       matlab.ui.control.Label
        ColorbarMaxEditField            matlab.ui.control.NumericEditField
        ColormapDropDownLabel           matlab.ui.control.Label
        ColormapDropDown                matlab.ui.control.DropDown
        LockCLimCheckBox                matlab.ui.control.CheckBox
        SaveplotdataButton              matlab.ui.control.Button
        SavedfilenameLabel              matlab.ui.control.Label
        SavedfilenameEditField          matlab.ui.control.EditField
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
            firstScalars = app.DANobject.getScalarsInGroup(scalarGroups{1});
            
            app.ScalargroupDropDown_Corr1.Items = scalarGroups;
            app.ScalarDropDown_Corr1.Items = firstScalars;
            
            app.ScalargroupDropDown_Corr2.Items = scalarGroups;
            app.ScalarDropDown_Corr2.Items =firstScalars;
            
            app.ScalargroupDropDown_WFS.Items = scalarGroups;
            app.ScalarDropDown_WFS.Items = firstScalars;
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
        
        function FS = getFacetScalar(app, sw, scalarDD, cameraDD, funcEF )
            if strcmp(sw.Value, 'Scalar')
                FS = {scalarDD.Value};
            elseif strcmp(sw.Value, 'Image')
                camera1 =  cameraDD.Value;
                funkh1 = str2func(funcEF.Value);
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
            app.ColorbarMaxEditField.Value = app.ImageAxes.CLim(2);
        end
        
        function plotImage(app, imageNumber)
            cameraName = app.CameraDropDown_DI.Value;
            applyfcn = app.ApplyImageanalysis2Dto2DCheckBox.Value;
            if ~applyfcn
                app.DANobject.visImage(cameraName, imageNumber);
            else 
                funk = app.ImageAnalysisFunctionEditField.Value;
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
            
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
%             set(app.dispImage.Children,'Enable','Off')
%             set(app.correlationPlot.Children,'Enable','Off')
            addpath('DANfunction')
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
            funk = app.D21DFunctionEditField_WF.Value;
            funkh = str2func(funk);
            
            if ~app.SortonscalarCheckBox.Value
                app.DANobject.waterfallPlot(camera,funkh)
            else
                FS = getFacetScalar(app, app.Switch_WFSFS, ...
                    app.ScalarDropDown_WFS, app.CameraDropDown_WFS, ...
                    app.D2SFunctionEditField_WFS );
                
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
                app.D21DFunctionEditField_Corr1 );
            
            if ~app.CorrelationCheckBox.Value
                if app.HistogramCheckBox.Value
                    app.DANobject.histogramPlot(FS1)
                else
                    app.DANobject.correlationPlot(FS1)
                end
                return
            end
            
            FS2 = getFacetScalar(app, app.Switch_Corr2FS, ...
                app.ScalarDropDown_Corr2, app.CameraDropDown_Corr2, ...
                app.D21DFunctionEditField_Corr2 );
            
            app.DANobject.correlationPlot(FS1,FS2)
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
            
            yyaxis(app.ImageAxes,'right');
            ylabel(newAx, '', 'Interpreter', 'none');
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
            listOfProps = fieldnames(uiAxGoodParams);
%             for k = 1:numel(listOfProps)
% %                 disp(listOfProps{k})
%                 newAx.(listOfProps{k}) = uiAxGoodParams.(listOfProps{k});
%             end
            
            titleS = app.ImageAxes.Title.String;
            xlabS = app.ImageAxes.XLabel.String;
            ylabS = app.ImageAxes.YLabel.String;
            yyaxis(app.ImageAxes,'right');
            ylab2S = app.ImageAxes.YLabel.String;
            yyaxis(app.ImageAxes,'left');

            set(newAx, uiAxGoodParams);
            %coptiyobj(uiAxGoodParams,newAx);

            
            print(fh, '-dpsc2', ['-P','physics-facetlog']);
%             opts.title = 'DAN picture';
%             opts.author = 'Matlab';
%             opts.text = '';
%             util_printLog(fh,opts);
            close(fh)
            title(app.ImageAxes, titleS, 'Interpreter', 'none');
            xlabel(app.ImageAxes, xlabS, 'Interpreter', 'none');
            ylabel(app.ImageAxes, ylabS, 'Interpreter', 'none');
            yyaxis(app.ImageAxes,'right');
            ylabel(app.ImageAxes, ylab2S, 'Interpreter', 'none');
            yyaxis(app.ImageAxes,'left');
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            info_str = sprintf('%s %s', xlabS, ylabS);
            
            set(gcf,'Position',[10 10 10 10]);
            util_printLog2020(fh,'title',titleS,...
            'author','DAN','text',info_str);
            clf(99), close(99);
            
        end

        % Button pushed function: BoostmotivationButton
        function BoostmotivationButtonPushed(app, event)
            disp("I'm sorry Dave, I'm afraid I can't do that.");
            val = lcaGet('SIOC:SYS1:ML03:AO551');
            val = val - 3;
            lcaPut('SIOC:SYS1:ML03:AO551',val);
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
            end
        end

        % Value changed function: SubtractImageBackgroundCheckBox
        function SubtractImageBackgroundCheckBoxValueChanged(app, event)
            value = app.SubtractImageBackgroundCheckBox.Value;
            
            app.DANobject.subtractBackground = value;
        end

        % Value changed function: ColorbarMaxEditField
        function ColorbarMaxEditFieldValueChanged(app, event)
            value = app.ColorbarMaxEditField.Value;
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
            exit;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1197 937];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create dataSet
            app.dataSet = uipanel(app.UIFigure);
            app.dataSet.Title = 'Panel';
            app.dataSet.Position = [24 532 317 386];

            % Create ExperimentLabel
            app.ExperimentLabel = uilabel(app.dataSet);
            app.ExperimentLabel.HorizontalAlignment = 'right';
            app.ExperimentLabel.Position = [17 335 67 22];
            app.ExperimentLabel.Text = 'Experiment';

            % Create expDropDown
            app.expDropDown = uidropdown(app.dataSet);
            app.expDropDown.Items = {'TEST', 'E300', 'E305', 'E308', 'E320', 'E325', 'E326', 'E327', 'E332'};
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

            % Create dispImage
            app.dispImage = uipanel(app.UIFigure);
            app.dispImage.Title = 'Image view';
            app.dispImage.Position = [659 13 249 374];

            % Create ImageincrementEditFieldLabel
            app.ImageincrementEditFieldLabel = uilabel(app.dispImage);
            app.ImageincrementEditFieldLabel.HorizontalAlignment = 'right';
            app.ImageincrementEditFieldLabel.Position = [28 159 96 22];
            app.ImageincrementEditFieldLabel.Text = 'Image increment';

            % Create ImageincrementEditField
            app.ImageincrementEditField = uieditfield(app.dispImage, 'numeric');
            app.ImageincrementEditField.Limits = [1 Inf];
            app.ImageincrementEditField.ValueChangedFcn = createCallbackFcn(app, @ImageincrementEditFieldValueChanged, true);
            app.ImageincrementEditField.Position = [139 159 100 22];
            app.ImageincrementEditField.Value = 1;

            % Create PlotImageButton
            app.PlotImageButton = uibutton(app.dispImage, 'push');
            app.PlotImageButton.ButtonPushedFcn = createCallbackFcn(app, @PlotImageButtonPushed, true);
            app.PlotImageButton.Position = [45 263 168 30];
            app.PlotImageButton.Text = 'Plot Image';

            % Create CameraDropDownLabel
            app.CameraDropDownLabel = uilabel(app.dispImage);
            app.CameraDropDownLabel.HorizontalAlignment = 'right';
            app.CameraDropDownLabel.Position = [45 322 49 22];
            app.CameraDropDownLabel.Text = 'Camera';

            % Create CameraDropDown_DI
            app.CameraDropDown_DI = uidropdown(app.dispImage);
            app.CameraDropDown_DI.Items = {};
            app.CameraDropDown_DI.Position = [109 322 100 22];
            app.CameraDropDown_DI.Value = {};

            % Create NextImageButton
            app.NextImageButton = uibutton(app.dispImage, 'push');
            app.NextImageButton.ButtonPushedFcn = createCallbackFcn(app, @NextImageButtonPushed, true);
            app.NextImageButton.Position = [147 127 76 23];
            app.NextImageButton.Text = 'Next Image';

            % Create ImagenumberEditFieldLabel
            app.ImagenumberEditFieldLabel = uilabel(app.dispImage);
            app.ImagenumberEditFieldLabel.HorizontalAlignment = 'right';
            app.ImagenumberEditFieldLabel.Position = [29 296 84 22];
            app.ImagenumberEditFieldLabel.Text = 'Image number';

            % Create ImagenumberEditField
            app.ImagenumberEditField = uieditfield(app.dispImage, 'numeric');
            app.ImagenumberEditField.Position = [128 296 100 22];
            app.ImagenumberEditField.Value = 1;

            % Create PreviousImageButton
            app.PreviousImageButton = uibutton(app.dispImage, 'push');
            app.PreviousImageButton.ButtonPushedFcn = createCallbackFcn(app, @PreviousImageButtonPushed, true);
            app.PreviousImageButton.Position = [33 127 100 23];
            app.PreviousImageButton.Text = 'Previous Image';

            % Create LoopThroughallButton
            app.LoopThroughallButton = uibutton(app.dispImage, 'push');
            app.LoopThroughallButton.ButtonPushedFcn = createCallbackFcn(app, @LoopThroughallButtonPushed, true);
            app.LoopThroughallButton.Position = [50 52 168 30];
            app.LoopThroughallButton.Text = 'Loop Through all';

            % Create WaittimesEditFieldLabel
            app.WaittimesEditFieldLabel = uilabel(app.dispImage);
            app.WaittimesEditFieldLabel.HorizontalAlignment = 'right';
            app.WaittimesEditFieldLabel.Position = [25 90 70 22];
            app.WaittimesEditFieldLabel.Text = 'Wait time [s]';

            % Create WaittimesEditField
            app.WaittimesEditField = uieditfield(app.dispImage, 'numeric');
            app.WaittimesEditField.Limits = [0.1 Inf];
            app.WaittimesEditField.ValueChangedFcn = createCallbackFcn(app, @WaittimesEditFieldValueChanged, true);
            app.WaittimesEditField.Position = [110 90 118 22];
            app.WaittimesEditField.Value = 0.5;

            % Create StopButton
            app.StopButton = uibutton(app.dispImage, 'push');
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);
            app.StopButton.Position = [85 9 100 23];
            app.StopButton.Text = 'Stop';

            % Create ImageAnalysisFunctionEditField
            app.ImageAnalysisFunctionEditField = uieditfield(app.dispImage, 'text');
            app.ImageAnalysisFunctionEditField.Position = [7 202 236 24];
            app.ImageAnalysisFunctionEditField.Value = '@(x)abs(fftshift(fft2(x)))';

            % Create ApplyImageanalysis2Dto2DCheckBox
            app.ApplyImageanalysis2Dto2DCheckBox = uicheckbox(app.dispImage);
            app.ApplyImageanalysis2Dto2DCheckBox.Text = 'Apply Image analysis (2D to 2D)';
            app.ApplyImageanalysis2Dto2DCheckBox.Position = [11 232 198 22];

            % Create correlationPlot
            app.correlationPlot = uipanel(app.UIFigure);
            app.correlationPlot.Title = 'Scalar plots';
            app.correlationPlot.Position = [22 18 311 499];

            % Create FACETScalarArray1Panel
            app.FACETScalarArray1Panel = uipanel(app.correlationPlot);
            app.FACETScalarArray1Panel.Title = 'FACET Scalar Array 1';
            app.FACETScalarArray1Panel.Position = [9 296 295 174];

            % Create ScalarDropDown_Corr1
            app.ScalarDropDown_Corr1 = uidropdown(app.FACETScalarArray1Panel);
            app.ScalarDropDown_Corr1.Items = {};
            app.ScalarDropDown_Corr1.Position = [7 20 117 22];
            app.ScalarDropDown_Corr1.Value = {};

            % Create ScalargroupLabel_Corr1
            app.ScalargroupLabel_Corr1 = uilabel(app.FACETScalarArray1Panel);
            app.ScalargroupLabel_Corr1.Position = [7 100 78 22];
            app.ScalargroupLabel_Corr1.Text = 'Scalar group:';

            % Create ScalarLabel_Corr1
            app.ScalarLabel_Corr1 = uilabel(app.FACETScalarArray1Panel);
            app.ScalarLabel_Corr1.Position = [7 47 43 22];
            app.ScalarLabel_Corr1.Text = 'Scalar:';

            % Create ScalargroupDropDown_Corr1
            app.ScalargroupDropDown_Corr1 = uidropdown(app.FACETScalarArray1Panel);
            app.ScalargroupDropDown_Corr1.Items = {};
            app.ScalargroupDropDown_Corr1.ValueChangedFcn = createCallbackFcn(app, @ScalargroupDropDown_Corr1ValueChanged, true);
            app.ScalargroupDropDown_Corr1.Position = [7 73 117 22];
            app.ScalargroupDropDown_Corr1.Value = {};

            % Create CameraDropDown_Corr1
            app.CameraDropDown_Corr1 = uidropdown(app.FACETScalarArray1Panel);
            app.CameraDropDown_Corr1.Items = {};
            app.CameraDropDown_Corr1.Position = [140 73 100 22];
            app.CameraDropDown_Corr1.Value = {};

            % Create CameraLabel_Corr1
            app.CameraLabel_Corr1 = uilabel(app.FACETScalarArray1Panel);
            app.CameraLabel_Corr1.Position = [140 100 52 22];
            app.CameraLabel_Corr1.Text = 'Camera:';

            % Create DtoscalarfunctionLabel_Corr1
            app.DtoscalarfunctionLabel_Corr1 = uilabel(app.FACETScalarArray1Panel);
            app.DtoscalarfunctionLabel_Corr1.Position = [140 47 119 22];
            app.DtoscalarfunctionLabel_Corr1.Text = '2D to scalar function:';

            % Create D21DFunctionEditField_Corr1
            app.D21DFunctionEditField_Corr1 = uieditfield(app.FACETScalarArray1Panel, 'text');
            app.D21DFunctionEditField_Corr1.Position = [140 19 137 24];
            app.D21DFunctionEditField_Corr1.Value = '@(x)sum(sum(x))';

            % Create Switch_Corr1FS
            app.Switch_Corr1FS = uiswitch(app.FACETScalarArray1Panel, 'slider');
            app.Switch_Corr1FS.Items = {'Scalar', 'Image'};
            app.Switch_Corr1FS.Position = [192 127 45 20];
            app.Switch_Corr1FS.Value = 'Scalar';

            % Create HistogramCheckBox
            app.HistogramCheckBox = uicheckbox(app.FACETScalarArray1Panel);
            app.HistogramCheckBox.ValueChangedFcn = createCallbackFcn(app, @HistogramCheckBoxValueChanged, true);
            app.HistogramCheckBox.Text = 'Histogram';
            app.HistogramCheckBox.Position = [12 126 78 22];

            % Create FACETScalarArray2Panel
            app.FACETScalarArray2Panel = uipanel(app.correlationPlot);
            app.FACETScalarArray2Panel.Title = 'FACET Scalar Array 2';
            app.FACETScalarArray2Panel.Position = [9 99 295 188];

            % Create ScalarDropDown_Corr2
            app.ScalarDropDown_Corr2 = uidropdown(app.FACETScalarArray2Panel);
            app.ScalarDropDown_Corr2.Items = {};
            app.ScalarDropDown_Corr2.Position = [10 9 115 22];
            app.ScalarDropDown_Corr2.Value = {};

            % Create ScalargroupLabel_Corr2
            app.ScalargroupLabel_Corr2 = uilabel(app.FACETScalarArray2Panel);
            app.ScalargroupLabel_Corr2.Position = [10 89 78 22];
            app.ScalargroupLabel_Corr2.Text = 'Scalar group:';

            % Create ScalarLabel_Corr2
            app.ScalarLabel_Corr2 = uilabel(app.FACETScalarArray2Panel);
            app.ScalarLabel_Corr2.Position = [10 35 43 22];
            app.ScalarLabel_Corr2.Text = 'Scalar:';

            % Create ScalargroupDropDown_Corr2
            app.ScalargroupDropDown_Corr2 = uidropdown(app.FACETScalarArray2Panel);
            app.ScalargroupDropDown_Corr2.Items = {};
            app.ScalargroupDropDown_Corr2.ValueChangedFcn = createCallbackFcn(app, @ScalargroupDropDown_Corr2ValueChanged, true);
            app.ScalargroupDropDown_Corr2.Position = [10 62 115 22];
            app.ScalargroupDropDown_Corr2.Value = {};

            % Create CameraDropDown_Corr2
            app.CameraDropDown_Corr2 = uidropdown(app.FACETScalarArray2Panel);
            app.CameraDropDown_Corr2.Items = {};
            app.CameraDropDown_Corr2.Position = [145 62 115 22];
            app.CameraDropDown_Corr2.Value = {};

            % Create CameraLabel_Corr2
            app.CameraLabel_Corr2 = uilabel(app.FACETScalarArray2Panel);
            app.CameraLabel_Corr2.Position = [145 89 52 22];
            app.CameraLabel_Corr2.Text = 'Camera:';

            % Create DtoscalarfunctionLabel_Corr2
            app.DtoscalarfunctionLabel_Corr2 = uilabel(app.FACETScalarArray2Panel);
            app.DtoscalarfunctionLabel_Corr2.Position = [145 35 119 22];
            app.DtoscalarfunctionLabel_Corr2.Text = '2D to scalar function:';

            % Create D21DFunctionEditField_Corr2
            app.D21DFunctionEditField_Corr2 = uieditfield(app.FACETScalarArray2Panel, 'text');
            app.D21DFunctionEditField_Corr2.Position = [145 8 137 24];
            app.D21DFunctionEditField_Corr2.Value = '@(x)sum(sum(x))';

            % Create Switch_Corr2FS
            app.Switch_Corr2FS = uiswitch(app.FACETScalarArray2Panel, 'slider');
            app.Switch_Corr2FS.Items = {'Scalar', 'Image'};
            app.Switch_Corr2FS.Position = [199 129 45 20];
            app.Switch_Corr2FS.Value = 'Scalar';

            % Create CorrelationCheckBox
            app.CorrelationCheckBox = uicheckbox(app.FACETScalarArray2Panel);
            app.CorrelationCheckBox.ValueChangedFcn = createCallbackFcn(app, @CorrelationCheckBoxValueChanged, true);
            app.CorrelationCheckBox.Text = 'Correlation';
            app.CorrelationCheckBox.Position = [13 139 83 22];

            % Create PlotcorrelationButton
            app.PlotcorrelationButton = uibutton(app.correlationPlot, 'push');
            app.PlotcorrelationButton.ButtonPushedFcn = createCallbackFcn(app, @PlotcorrelationButtonPushed, true);
            app.PlotcorrelationButton.Position = [85 26 123 59];
            app.PlotcorrelationButton.Text = 'Plot correlation';

            % Create ImageAxes
            app.ImageAxes = uiaxes(app.UIFigure);
            title(app.ImageAxes, 'Title')
            xlabel(app.ImageAxes, 'X')
            ylabel(app.ImageAxes, 'Y')
            app.ImageAxes.Position = [363 409 803 509];

            % Create WaterfallplotPanel
            app.WaterfallplotPanel = uipanel(app.UIFigure);
            app.WaterfallplotPanel.Title = 'Waterfall plot';
            app.WaterfallplotPanel.Position = [363 15 281 372];

            % Create CameraDropDown_3Label
            app.CameraDropDown_3Label = uilabel(app.WaterfallplotPanel);
            app.CameraDropDown_3Label.HorizontalAlignment = 'right';
            app.CameraDropDown_3Label.Position = [11 314 49 22];
            app.CameraDropDown_3Label.Text = 'Camera';

            % Create CameraDropDown_WF
            app.CameraDropDown_WF = uidropdown(app.WaterfallplotPanel);
            app.CameraDropDown_WF.Items = {};
            app.CameraDropDown_WF.Position = [75 314 100 22];
            app.CameraDropDown_WF.Value = {};

            % Create D21DFunctionEditField_WF
            app.D21DFunctionEditField_WF = uieditfield(app.WaterfallplotPanel, 'text');
            app.D21DFunctionEditField_WF.Position = [11 264 255 24];
            app.D21DFunctionEditField_WF.Value = '@(x)(sum(x)/max(sum(x)))';

            % Create PlotwaterfallButton
            app.PlotwaterfallButton = uibutton(app.WaterfallplotPanel, 'push');
            app.PlotwaterfallButton.ButtonPushedFcn = createCallbackFcn(app, @PlotwaterfallButtonPushed, true);
            app.PlotwaterfallButton.Position = [70 212 143 42];
            app.PlotwaterfallButton.Text = 'Plot waterfall';

            % Create Dto1DFunctionLabel_WF
            app.Dto1DFunctionLabel_WF = uilabel(app.WaterfallplotPanel);
            app.Dto1DFunctionLabel_WF.Position = [11 289 106 22];
            app.Dto1DFunctionLabel_WF.Text = '2D to 1D Function:';

            % Create SortwaterfallplotPanel
            app.SortwaterfallplotPanel = uipanel(app.WaterfallplotPanel);
            app.SortwaterfallplotPanel.Title = 'Sort waterfall plot';
            app.SortwaterfallplotPanel.Position = [12 15 260 186];

            % Create ScalarDropDown_WFS
            app.ScalarDropDown_WFS = uidropdown(app.SortwaterfallplotPanel);
            app.ScalarDropDown_WFS.Items = {};
            app.ScalarDropDown_WFS.Position = [8 12 82 22];
            app.ScalarDropDown_WFS.Value = {};

            % Create ScalargroupLabel_WFS
            app.ScalargroupLabel_WFS = uilabel(app.SortwaterfallplotPanel);
            app.ScalargroupLabel_WFS.Position = [7 92 78 22];
            app.ScalargroupLabel_WFS.Text = 'Scalar group:';

            % Create ScalargroupDropDown_WFS
            app.ScalargroupDropDown_WFS = uidropdown(app.SortwaterfallplotPanel);
            app.ScalargroupDropDown_WFS.Items = {};
            app.ScalargroupDropDown_WFS.ValueChangedFcn = createCallbackFcn(app, @ScalargroupDropDown_WFSValueChanged, true);
            app.ScalargroupDropDown_WFS.Position = [7 65 117 22];
            app.ScalargroupDropDown_WFS.Value = {};

            % Create ScalarLabel_WFS
            app.ScalarLabel_WFS = uilabel(app.SortwaterfallplotPanel);
            app.ScalarLabel_WFS.Position = [10 38 43 22];
            app.ScalarLabel_WFS.Text = 'Scalar:';

            % Create CameraLabel_WFS
            app.CameraLabel_WFS = uilabel(app.SortwaterfallplotPanel);
            app.CameraLabel_WFS.Position = [132 92 49 22];
            app.CameraLabel_WFS.Text = 'Camera';

            % Create CameraDropDown_WFS
            app.CameraDropDown_WFS = uidropdown(app.SortwaterfallplotPanel);
            app.CameraDropDown_WFS.Items = {};
            app.CameraDropDown_WFS.Position = [133 65 100 22];
            app.CameraDropDown_WFS.Value = {};

            % Create D2SFunctionLabel_WFS
            app.D2SFunctionLabel_WFS = uilabel(app.SortwaterfallplotPanel);
            app.D2SFunctionLabel_WFS.Position = [123 38 116 22];
            app.D2SFunctionLabel_WFS.Text = '2D to scalar function';

            % Create D2SFunctionEditField_WFS
            app.D2SFunctionEditField_WFS = uieditfield(app.SortwaterfallplotPanel, 'text');
            app.D2SFunctionEditField_WFS.Position = [113 11 137 24];
            app.D2SFunctionEditField_WFS.Value = '@(x)sum(sum(x))';

            % Create Switch_WFSFS
            app.Switch_WFSFS = uiswitch(app.SortwaterfallplotPanel, 'slider');
            app.Switch_WFSFS.Items = {'Scalar', 'Image'};
            app.Switch_WFSFS.Position = [159 127 45 20];
            app.Switch_WFSFS.Value = 'Scalar';

            % Create SortonscalarCheckBox
            app.SortonscalarCheckBox = uicheckbox(app.SortwaterfallplotPanel);
            app.SortonscalarCheckBox.Text = 'Sort on scalar';
            app.SortonscalarCheckBox.Position = [5 142 97 22];

            % Create PlotsortvaluesCheckBox
            app.PlotsortvaluesCheckBox = uicheckbox(app.SortwaterfallplotPanel);
            app.PlotsortvaluesCheckBox.Text = 'Plot sort values';
            app.PlotsortvaluesCheckBox.Position = [5 117 105 22];

            % Create MotivationIndicatorAirspeedIndicatorLabel
            app.MotivationIndicatorAirspeedIndicatorLabel = uilabel(app.UIFigure);
            app.MotivationIndicatorAirspeedIndicatorLabel.HorizontalAlignment = 'center';
            app.MotivationIndicatorAirspeedIndicatorLabel.Position = [921 9 111 22];
            app.MotivationIndicatorAirspeedIndicatorLabel.Text = 'Motivation Indicator';

            % Create MotivationIndicatorAirspeedIndicator
            app.MotivationIndicatorAirspeedIndicator = uiaeroairspeed(app.UIFigure);
            app.MotivationIndicatorAirspeedIndicator.Position = [937 28 81 81];
            app.MotivationIndicatorAirspeedIndicator.Airspeed = 50;

            % Create PrinttologbookButton
            app.PrinttologbookButton = uibutton(app.UIFigure, 'push');
            app.PrinttologbookButton.ButtonPushedFcn = createCallbackFcn(app, @PrinttologbookButtonPushed, true);
            app.PrinttologbookButton.BackgroundColor = [0 1 0];
            app.PrinttologbookButton.Position = [1052 16 129 128];
            app.PrinttologbookButton.Text = {'Print to '; 'logbook'};

            % Create BoostmotivationButton
            app.BoostmotivationButton = uibutton(app.UIFigure, 'push');
            app.BoostmotivationButton.ButtonPushedFcn = createCallbackFcn(app, @BoostmotivationButtonPushed, true);
            app.BoostmotivationButton.Position = [925 117 105 23];
            app.BoostmotivationButton.Text = 'Boost motivation';

            % Create CLimPanel
            app.CLimPanel = uipanel(app.UIFigure);
            app.CLimPanel.Title = 'CLim';
            app.CLimPanel.Position = [921 231 260 156];

            % Create ColorbarMinEditFieldLabel
            app.ColorbarMinEditFieldLabel = uilabel(app.CLimPanel);
            app.ColorbarMinEditFieldLabel.HorizontalAlignment = 'right';
            app.ColorbarMinEditFieldLabel.Position = [26 37 76 22];
            app.ColorbarMinEditFieldLabel.Text = 'Colorbar Min';

            % Create ColorbarMinEditField
            app.ColorbarMinEditField = uieditfield(app.CLimPanel, 'numeric');
            app.ColorbarMinEditField.ValueChangedFcn = createCallbackFcn(app, @ColorbarMinEditFieldValueChanged, true);
            app.ColorbarMinEditField.Position = [27 11 100 22];

            % Create ColorbarMaxEditFieldLabel
            app.ColorbarMaxEditFieldLabel = uilabel(app.CLimPanel);
            app.ColorbarMaxEditFieldLabel.HorizontalAlignment = 'right';
            app.ColorbarMaxEditFieldLabel.Position = [136 37 79 22];
            app.ColorbarMaxEditFieldLabel.Text = 'Colorbar Max';

            % Create ColorbarMaxEditField
            app.ColorbarMaxEditField = uieditfield(app.CLimPanel, 'numeric');
            app.ColorbarMaxEditField.ValueChangedFcn = createCallbackFcn(app, @ColorbarMaxEditFieldValueChanged, true);
            app.ColorbarMaxEditField.Position = [137 11 100 22];

            % Create ColormapDropDownLabel
            app.ColormapDropDownLabel = uilabel(app.CLimPanel);
            app.ColormapDropDownLabel.HorizontalAlignment = 'right';
            app.ColormapDropDownLabel.Position = [136 104 59 22];
            app.ColormapDropDownLabel.Text = 'Colormap';

            % Create ColormapDropDown
            app.ColormapDropDown = uidropdown(app.CLimPanel);
            app.ColormapDropDown.Items = {'Bengt', 'parula', 'jet', 'gray'};
            app.ColormapDropDown.ValueChangedFcn = createCallbackFcn(app, @ColormapDropDownValueChanged, true);
            app.ColormapDropDown.Position = [137 78 100 22];
            app.ColormapDropDown.Value = 'parula';

            % Create LockCLimCheckBox
            app.LockCLimCheckBox = uicheckbox(app.CLimPanel);
            app.LockCLimCheckBox.Text = 'Lock CLim';
            app.LockCLimCheckBox.Position = [20 91 80 22];

            % Create SaveplotdataButton
            app.SaveplotdataButton = uibutton(app.UIFigure, 'push');
            app.SaveplotdataButton.ButtonPushedFcn = createCallbackFcn(app, @SaveplotdataButtonPushed, true);
            app.SaveplotdataButton.Position = [1066 188 100 23];
            app.SaveplotdataButton.Text = 'Save plot data';

            % Create SavedfilenameLabel
            app.SavedfilenameLabel = uilabel(app.UIFigure);
            app.SavedfilenameLabel.HorizontalAlignment = 'right';
            app.SavedfilenameLabel.Position = [934 200 96 22];
            app.SavedfilenameLabel.Text = 'Saved file name:';

            % Create SavedfilenameEditField
            app.SavedfilenameEditField = uieditfield(app.UIFigure, 'text');
            app.SavedfilenameEditField.Position = [941 177 100 22];
            app.SavedfilenameEditField.Value = 'myPlotName';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_DAN_exported

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