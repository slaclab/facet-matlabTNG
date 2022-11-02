classdef F2_CorrPlot_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        HelpMenu                        matlab.ui.container.Menu
        Wiki                            matlab.ui.container.Menu
        GridLayout                      matlab.ui.container.GridLayout
        GridLayout4                     matlab.ui.container.GridLayout
        GridLayout19                    matlab.ui.container.GridLayout
        FastControlPVNameEditFieldLabel  matlab.ui.control.Label
        ControlPVFastNameEditField      matlab.ui.control.EditField
        FastCurrentLabel                matlab.ui.control.Label
        FastInitialLabel                matlab.ui.control.Label
        GridLayout49                    matlab.ui.container.GridLayout
        ControlPVFastCurrentVal         matlab.ui.control.Label
        ControlPVFastCurrentUnits       matlab.ui.control.Label
        GridLayout49_2                  matlab.ui.container.GridLayout
        ControlPVFastInitialUnits       matlab.ui.control.Label
        ControlPVFastInitialVal         matlab.ui.control.Label
        StaticBGButton                  matlab.ui.control.Button
        ControlPVFastRangeUnits         matlab.ui.control.Label
        NumValsLabel_2                  matlab.ui.control.Label
        ControlPVFastNumValsEditField   matlab.ui.control.NumericEditField
        SampleDelaysEditFieldLabel      matlab.ui.control.Label
        SampleDelayEditField            matlab.ui.control.NumericEditField
        ControlPVFastSetButton          matlab.ui.control.Button
        profmonDropDownLabel            matlab.ui.control.Label
        ProfmonDropDown                 matlab.ui.control.DropDown
        UseCalCheckBox                  matlab.ui.control.CheckBox
        SettleTimeLabel_2               matlab.ui.control.Label
        ControlPVFastSettleTimeEditField  matlab.ui.control.NumericEditField
        SamplesLabel                    matlab.ui.control.Label
        NumSampleEditField              matlab.ui.control.NumericEditField
        profmonNumAveEditFieldLabel     matlab.ui.control.Label
        ProfmonNumAveEditField          matlab.ui.control.NumericEditField
        UseStaticBGCheckBox             matlab.ui.control.CheckBox
        CtrlPVLowEditFieldLabel_5       matlab.ui.control.Label
        ControlPVFastLowEditField       matlab.ui.control.EditField
        CtrlPVHighLabel_2               matlab.ui.control.Label
        ControlPVFastHighEditField      matlab.ui.control.EditField
        profmonNumBGEditFieldLabel      matlab.ui.control.Label
        ProfmonNumBGEditField           matlab.ui.control.NumericEditField
        BSACheckBox                     matlab.ui.control.CheckBox
        ProfmonMultiCheckBox            matlab.ui.control.CheckBox
        SetBestButton                   matlab.ui.control.Button
        SampleForceCheckBox             matlab.ui.control.CheckBox
        ControlPVFastRelativeCheckBox   matlab.ui.control.CheckBox
        GridLayout27                    matlab.ui.container.GridLayout
        ControlPVNameEditFieldLabel     matlab.ui.control.Label
        ControlPVNameEditField          matlab.ui.control.EditField
        CurrentLabel                    matlab.ui.control.Label
        InitialLabel                    matlab.ui.control.Label
        GridLayout48                    matlab.ui.container.GridLayout
        ControlPVCurrentUnits           matlab.ui.control.Label
        ControlPVCurrentVal             matlab.ui.control.Label
        GridLayout48_2                  matlab.ui.container.GridLayout
        ControlPVInitialVal             matlab.ui.control.Label
        ControlPVInitialUnits           matlab.ui.control.Label
        ControlPVRangeUnits             matlab.ui.control.Label
        NumValsLabel                    matlab.ui.control.Label
        ControlPVNumValsEditField       matlab.ui.control.NumericEditField
        ControlPVSetButton              matlab.ui.control.Button
        InitialSettleLabel              matlab.ui.control.Label
        InitialSettleEditField          matlab.ui.control.NumericEditField
        SettleTimeLabel                 matlab.ui.control.Label
        ControlPVSettleTimeEditField    matlab.ui.control.NumericEditField
        SettlePVEditFieldLabel          matlab.ui.control.Label
        SettlePVEditField               matlab.ui.control.EditField
        RandomOrderCheckBox             matlab.ui.control.CheckBox
        SpiralOrderCheckBox             matlab.ui.control.CheckBox
        ZigZagCheckBox                  matlab.ui.control.CheckBox
        BSAModeDropDownLabel            matlab.ui.control.Label
        BSADropDown                     matlab.ui.control.DropDown
        CtrlPVLowEditFieldLabel_4       matlab.ui.control.Label
        ControlPVLowEditField           matlab.ui.control.EditField
        CtrlPVHighLabel                 matlab.ui.control.Label
        ControlPVHighEditField          matlab.ui.control.EditField
        ResetCtrlPVsButton              matlab.ui.control.Button
        ControlPVRelativeCheckBox       matlab.ui.control.CheckBox
        MetadataButton                  matlab.ui.control.Button
        GridLayout37                    matlab.ui.container.GridLayout
        ControlPVFastCheckBox           matlab.ui.control.CheckBox
        GridLayout50                    matlab.ui.container.GridLayout
        ControlPVSliderVal              matlab.ui.control.Label
        ControlPVSliderUnits            matlab.ui.control.Label
        ControlPVSliderLabel            matlab.ui.control.Label
        GridLayout50_2                  matlab.ui.container.GridLayout
        ControlPVFastSliderVal          matlab.ui.control.Label
        ControlPVFastSliderUnits        matlab.ui.control.Label
        ControlPVFastSliderLabel        matlab.ui.control.Label
        GridLayout51                    matlab.ui.container.GridLayout
        FitOrderEditFieldLabel          matlab.ui.control.Label
        FitOrderEditField               matlab.ui.control.NumericEditField
        WindowSmoothingSizeSliderLabel  matlab.ui.control.Label
        WindowSmoothingSizeSlider       matlab.ui.control.Slider
        GridLayout52                    matlab.ui.container.GridLayout
        WindowSizeEditField             matlab.ui.control.NumericEditField
        GridLayout53                    matlab.ui.container.GridLayout
        ShowLinesCheckBox               matlab.ui.control.CheckBox
        ShowAverageCheckBox             matlab.ui.control.CheckBox
        SmoothingCheckBox               matlab.ui.control.CheckBox
        Show3DDropDown                  matlab.ui.control.DropDown
        ShowFitDropDown                 matlab.ui.control.DropDown
        GridLayout54                    matlab.ui.container.GridLayout
        dataMethodSliderLabel           matlab.ui.control.Label
        DataMethodSlider                matlab.ui.control.Slider
        DataMethodLabel                 matlab.ui.control.Label
        DataMethodSliderLeft            matlab.ui.control.Button
        DataMethodSliderRight           matlab.ui.control.Button
        GridLayout55                    matlab.ui.container.GridLayout
        ControlPVSliderLeft             matlab.ui.control.Button
        ControlPVSliderRight            matlab.ui.control.Button
        ControlPVSlider                 matlab.ui.control.Slider
        GridLayout56                    matlab.ui.container.GridLayout
        ControlPVFastSlider             matlab.ui.control.Slider
        ControlPVFastSliderLeft         matlab.ui.control.Button
        ControlPVFastSliderRight        matlab.ui.control.Button
        GridLayout57                    matlab.ui.container.GridLayout
        SampleSliderLabel               matlab.ui.control.Label
        SampleSlider                    matlab.ui.control.Slider
        SampleSliderLeft                matlab.ui.control.Button
        SampleSliderRight               matlab.ui.control.Button
        SampleLabel                     matlab.ui.control.Label
        GridLayout58                    matlab.ui.container.GridLayout
        DataSampleUseCheckBox           matlab.ui.control.CheckBox
        ReadPVListTextAreaLabel         matlab.ui.control.Label
        ReadPVListTextArea              matlab.ui.control.TextArea
        ControlPVCheckBox               matlab.ui.control.CheckBox
        GridLayout41                    matlab.ui.container.GridLayout
        UAxisDropDownLabel              matlab.ui.control.Label
        UAxisDropDown                   matlab.ui.control.DropDown
        XAxisDropDownLabel              matlab.ui.control.Label
        XAxisDropDown                   matlab.ui.control.DropDown
        showLogXCheckBox                matlab.ui.control.CheckBox
        YAxisListBoxLabel               matlab.ui.control.Label
        YAxisListBox                    matlab.ui.control.ListBox
        showLogYCheckBox                matlab.ui.control.CheckBox
        PlotHeaderEditFieldLabel        matlab.ui.control.Label
        PlotHeaderEditField             matlab.ui.control.EditField
        FormulaTextAreaLabel            matlab.ui.control.Label
        FormulaTextArea                 matlab.ui.control.TextArea
        wireDropDownLabel               matlab.ui.control.Label
        wireDropDown                    matlab.ui.control.DropDown
        blenDropDownLabel               matlab.ui.control.Label
        blenDropDown                    matlab.ui.control.DropDown
        emitDropDownLabel               matlab.ui.control.Label
        emitDropDown                    matlab.ui.control.DropDown
        wirePlaneButtons                matlab.ui.container.ButtonGroup
        x                               matlab.ui.control.RadioButton
        y                               matlab.ui.control.RadioButton
        emitTypeButtons                 matlab.ui.container.ButtonGroup
        Multi                           matlab.ui.control.RadioButton
        Quad                            matlab.ui.control.RadioButton
        Status                          matlab.ui.control.Label
        GridLayout5                     matlab.ui.container.GridLayout
        StartButton                     matlab.ui.control.Button
        AbortButton                     matlab.ui.control.Button
        GetDataButton                   matlab.ui.control.Button
        LogbookButton                   matlab.ui.control.Button
        ExportButton                    matlab.ui.control.Button
        DispDataButton                  matlab.ui.control.Button
        SaveButton                      matlab.ui.control.Button
        SaveAsButton                    matlab.ui.control.Button
        LoadButton                      matlab.ui.control.Button
        LoadConfigButton                matlab.ui.control.Button
        ImgProcessButton                matlab.ui.control.Button
        SaveConfigButton                matlab.ui.control.Button
        PlotData_ax                     matlab.ui.control.UIAxes
        PlotProf_ax                     matlab.ui.control.UIAxes
        GridLayout9                     matlab.ui.container.GridLayout
        YSigEditFieldLabel              matlab.ui.control.Label
        YSigEditField                   matlab.ui.control.NumericEditField
        GridLayout10                    matlab.ui.container.GridLayout
        XSigEditFieldLabel              matlab.ui.control.Label
        XSigEditField                   matlab.ui.control.NumericEditField
        SaveImagesCheckBox              matlab.ui.control.CheckBox
        HoldImagesCheckBox              matlab.ui.control.CheckBox
        ImgautoscaleCheckBox            matlab.ui.control.CheckBox
        ShowImagesCheckBox              matlab.ui.control.CheckBox
        ProcCheckBox                    matlab.ui.control.CheckBox
        CropCheckBox                    matlab.ui.control.CheckBox
        GridLayout63                    matlab.ui.container.GridLayout
        PlotGridCheckBox                matlab.ui.control.CheckBox
        ProfGridCheckBox                matlab.ui.control.CheckBox
        GridLayout17                    matlab.ui.container.GridLayout
        ProfileMonitorListBoxLabel      matlab.ui.control.Label
        ProfmonListBox                  matlab.ui.control.ListBox
        GridLayout59                    matlab.ui.container.GridLayout
        MultiknobFileEditFieldLabel     matlab.ui.control.Label
        MultiknobFileEditField          matlab.ui.control.EditField
        GridLayout60                    matlab.ui.container.GridLayout
        UseLEMCheckBox                  matlab.ui.control.CheckBox
        GridLayout62                    matlab.ui.container.GridLayout
        PrescanButton                   matlab.ui.control.Button
        PausePVEditFieldLabel           matlab.ui.control.Label
        PausePVEditField                matlab.ui.control.EditField
        BeamPath                        matlab.ui.container.ButtonGroup
        BeamPathButton1                 matlab.ui.control.ToggleButton
        BeamPathButton2                 matlab.ui.control.ToggleButton
        BeamPathButton3                 matlab.ui.control.ToggleButton
        BeamPathButton4                 matlab.ui.control.ToggleButton
        GridLayout61                    matlab.ui.container.GridLayout
        XLABELLabel                     matlab.ui.control.Label
        YLABELLabel                     matlab.ui.control.Label
        XNAMECheckBox                   matlab.ui.control.CheckBox
        YNAMECheckBox                   matlab.ui.control.CheckBox
        XDESCCheckBox                   matlab.ui.control.CheckBox
        YDESCCheckBox                   matlab.ui.control.CheckBox
        XEGUCheckBox                    matlab.ui.control.CheckBox
        YEGUCheckBox                    matlab.ui.control.CheckBox
        ULABELLabel                     matlab.ui.control.Label
        UNAMECheckBox                   matlab.ui.control.CheckBox
        UDESCCheckBox                   matlab.ui.control.CheckBox
        UEGUCheckBox                    matlab.ui.control.CheckBox
        CorrelationPlotLabel            matlab.ui.control.Label
    end

    
    properties (Access = public)
        mdl % model object containing app data and configuration
        figSize % height and width of the UIFigure
        minSize = [1254, 1375]
        gridParams
        isFixed
        init = 1
        STDERR = 2 % for writing error messages
        
        
        % listeners for receiving updates from the model
        ctrlPVListener
        ctrlPVFastListener
        ctrlPVSliderListener
        ctrlPVFastSliderListener
        plotDataListener
        plotProfileListener
        updatePlotAxisListener
        readPVListListener
        clearPlotAxesListener
        clearProfileAxesListener
        BSAChangedListener
        indexControlListener
        profmonListener
        emitListener
        wireListener
        blenListener
        emitTypeListener
        ctrlPVSetStatusListener
        acqStatusListener
        statusListener
        numSamplesListener
        useChangedListener
        plotOptListener
        configLoadedListener
        imgOptListener
        dataMethodListener
        staticBGListener
    end
    
    methods (Access = public)
        
        function appInit(app)
            % Update interface with latest values from the model
            try
                onctrlPVChanged(app);
                onctrlPVFastChanged(app);
                onnumSamplesChanged(app);
                onplotOptChanged(app);
                onctrlPVSliderChanged(app);
                onctrlPVFastSliderChanged(app);
                onBSAChanged(app);
                onreadPVListChanged(app);
                onemitChanged(app);
                onprofmonChanged(app);
                onwireChanged(app);
                onblenChanged(app);
                onimgOptChanged(app);
                onacqOptChanged(app);
                onplotOptChanged(app);
                onupdateAxisDropDown(app);
                ondataMethodChanged(app);
                onstatusChanged(app);
                app.StaticBGButton.Visible = 0;
            catch ME
                errorMessage(app, ME, 'Error initializing app interface');
            end

        end
        
        function onindexControl(app)
            % Set title text.
            try
                str = app.UIFigure.Name;
                d = unique(app.mdl.indexList(:,1));
                if ischar(d),d={d};end
                patt=sprintf('\\<%s\\>|',d{:});
                str = regexprep(str, patt, app.mdl.accelerator);
                if isempty(regexp(str,patt,'once')), str = [app.mdl.accelerator ' ' str];end
                app.UIFigure.Name = str;
                app.CorrelationPlotLabel.Text = str;
                
                % Set figure background and button colors to index specific color.
                indexId = find(strcmp(app.mdl.indexList(:,4), app.mdl.index));
                col = gui_indexColor(app.mdl.index);
                h = findobj(app.UIFigure,'-property','BackgroundColor');
                cal0 = round(app.UIFigure.Color, 2);
                hc = get(h,'BackgroundColor');
                h(cellfun(@ischar,hc)) = [];  
                hc(cellfun(@ischar,hc)) = []; % Remove color 'none' objects
                app.UIFigure.Color = col;
                hcr = round(cell2mat(hc), 2);
                set(h(all(hcr == repmat(cal0,numel(hc),1),2)),'BackgroundColor',col);
                
                % set beampath buttons based on index list
                if size(app.mdl.indexList, 1) > 1
                    for b = 1:size(app.mdl.indexList, 1)
                        buttonName = strcat('BeamPathButton', num2str(b));
                        app.(buttonName).BackgroundColor = col;
                        app.(buttonName).Visible = 'on';
                        app.(buttonName).Enable = 'on';
                        app.(buttonName).Text = app.mdl.indexList(b, 4);
                    end
                end
                app.(strcat('BeamPathButton', num2str(indexId))).BackgroundColor ='y';
                app.(strcat('BeamPathButton', num2str(indexId))).Value = 1;
                app.BSADropDown.Items = app.mdl.BSAOptions;
            catch ME
                errorMessage(app, ME, 'Error changing interface for updated index');
            end
        end
        
        function onctrlPVChanged(app)
            % respond to change in one of the ctrlPV properties
            try
                ctrlPV = getCtrlPV(app.mdl, 0);
                if ~isempty(ctrlPV)
                    val = ctrlPV.val;
                    units = ctrlPV.units;
                    name = ctrlPV.name;
                    sliderState = 'on';                
                    
                    % update the properties
                    app.ControlPVLowEditField.Value = ctrlPV.low;
                    app.ControlPVHighEditField.Value = ctrlPV.high;
                    app.ControlPVNumValsEditField.Value = ctrlPV.numvals;
                    app.ControlPVSettleTimeEditField.Value = ctrlPV.settletime;
                    app.ControlPVRelativeCheckBox.Value = ctrlPV.relative;
                    
                    % update the slider accordingly
                    lim = length(ctrlPV.vallist);
                    if lim == 1, lim = lim + 1; end
                    app.ControlPVSlider.Limits = [1, lim];
                    onctrlPVSliderChanged(app, ctrlPV);
                    
                else
                    val = [];
                    units = '';
                    name = '';
                    sliderState = 'off';
                end
                
                % update labels
                app.ControlPVNameEditField.Value = name;
                app.ControlPVSliderLabel.Text = name;
                app.ControlPVSliderUnits.Text = units;
                app.ControlPVCurrentVal.Text = num2str(val);
                app.ControlPVCurrentUnits.Text = units;
                app.ControlPVInitialVal.Text = num2str(val);
                app.ControlPVInitialUnits.Text = units;
                app.ControlPVRangeUnits.Text = units;
                
                % handle slider visibility
                app.ControlPVSlider.Visible = sliderState;
                app.ControlPVSliderVal.Visible = sliderState;
                app.ControlPVSliderUnits.Visible = sliderState;
                app.ControlPVSliderLabel.Visible = sliderState;
                app.ControlPVSliderRight.Visible = sliderState;
                app.ControlPVSliderLeft.Visible = sliderState;
                app.ControlPVCheckBox.Visible = sliderState;
                                
            catch ME
                errorMessage(app, ME, 'Error changing interface for updated control PV');
            end
            
        end
        
        function onctrlPVFastChanged(app)
            % respond to change in one of the fast ctrlPV properties
            try
                ctrlPVFast = getCtrlPV(app.mdl, 1);
                if ~isempty(ctrlPVFast)
                    val = ctrlPVFast.val;
                    units = ctrlPVFast.units;
                    name = ctrlPVFast.name;
                    sliderState = 'on';                
                    
                    % update properties
                    app.ControlPVFastLowEditField.Value = ctrlPVFast.low;
                    app.ControlPVFastHighEditField.Value = ctrlPVFast.high;
                    app.ControlPVFastNumValsEditField.Value = ctrlPVFast.numvals;
                    app.ControlPVFastSettleTimeEditField.Value = ctrlPVFast.settletime;
                    app.ControlPVFastRelativeCheckBox.Value = ctrlPVFast.relative;
                    
                    lim = length(ctrlPVFast.vallist);
                    if lim == 1, lim = lim + 1; end
                    app.ControlPVFastSlider.Limits = [1, lim];
                    onctrlPVFastSliderChanged(app, ctrlPVFast);
                    
                else
                    val = [];
                    units = '';
                    name = '';
                    sliderState = 'off';
                end
                
                % update labels
                app.ControlPVFastNameEditField.Value = name;
                app.ControlPVFastSliderLabel.Text = name;
                app.ControlPVFastSliderUnits.Text = units;
                app.ControlPVFastCurrentVal.Text = num2str(val);
                app.ControlPVFastCurrentUnits.Text = units;
                app.ControlPVFastInitialVal.Text = num2str(val);
                app.ControlPVFastInitialUnits.Text = units;
                app.ControlPVFastRangeUnits.Text = units;
                
                % handle slider visibility
                app.ControlPVFastSlider.Visible = sliderState;
                app.ControlPVFastSliderVal.Visible = sliderState;
                app.ControlPVFastSliderUnits.Visible = sliderState;
                app.ControlPVFastSliderLabel.Visible = sliderState;
                app.ControlPVFastSliderRight.Visible = sliderState;
                app.ControlPVFastSliderLeft.Visible = sliderState;
                app.ControlPVFastCheckBox.Visible = sliderState;
                
                
            catch ME
                errorMessage(app, ME, 'Error changing interface for updated fast control PV');
            end
        end
        
        function onctrlPVSliderChanged(app, ctrlPV)
            % respond to an action that changes the ctrl pv slider value
            try
                if nargin < 2, ctrlPV = getCtrlPV(app.mdl, 0); end
                if isempty(ctrlPV), return; end
                app.ControlPVSlider.Value = ctrlPV.idx;
                app.ControlPVSliderVal.Text = num2str(ctrlPV.vallist(ctrlPV.idx));
                useCheckBoxControl(app);
            catch ME
                errorMessage(app, ME, 'Error updating control PV slider');
            end
        end
        
        function onctrlPVFastSliderChanged(app, ctrlPVFast)
            % respond to an action that changes the fast ctrl pv slider
            try
                if nargin < 2, ctrlPVFast = getCtrlPV(app.mdl, 1); end
                if isempty(ctrlPVFast), return; end
                app.ControlPVFastSlider.Value = ctrlPVFast.idx;
                app.ControlPVFastSliderVal.Text = num2str(ctrlPVFast.vallist(ctrlPVFast.idx));
                useCheckBoxControl(app);
            catch ME
                errorMessage(app, ME, 'Error updating fast control PV slider');
            end
        end
        
        function useCheckBoxControl(app)
            % update the use check boxes 
            try
                acqOpt = getAcqOpt(app.mdl);
                
                [useCtrlPV, useCtrlPVFast, useSample] = getUse(app.mdl);
    
                if ~isempty(useCtrlPV)
                    app.ControlPVCheckBox.Value = useCtrlPV;
                end
                if ~isempty(useCtrlPVFast)
                    app.ControlPVFastCheckBox.Value = useCtrlPVFast;
                end
                if acqOpt.numSamples > 1 && ~isempty(useSample)
                    app.DataSampleUseCheckBox.Value = useSample;
                end
            catch ME
                errorMessage(app, ME, 'Error updating use check boxes');
            end
        end
        
        function setDataTip(app, plts, plotData, avg)
            % format data tips
            for i = 1:length(plts)
                plt = plts(i);
            
                dt = plt.DataTipTemplate;
                dt.DataTipRows(1).Label = plotData.xPV.name;
                dt.DataTipRows(2).Label = plotData.yPV(i).name;
                idx = 3;
                if ~isempty(app.mdl.ctrlPV) && ~(any(contains({plotData.xLabelStr, plotData.yLabelStr}, plotData.ctrlPVLabel)))
                    dt.DataTipRows(idx).Label = plotData.ctrlPVLabel;
                    if avg
                        dt.DataTipRows(idx).Value = [plotData.ctrlPVAvg, nan];
                    else
                        dt.DataTipRows(idx).Value = plotData.ctrlPV;
                    end
                    idx = idx + 1;
                end
                if ~isempty(app.mdl.ctrlPVFast) && ~(any(contains({plotData.xLabelStr, plotData.yLabelStr}, plotData.ctrlPVFastLabel)))
                    dt.DataTipRows(idx).Label = plotData.ctrlPVFastLabel;
                    if avg
                        dt.DataTipRows(idx).Value = [plotData.ctrlPVFastAvg, nan];
                    else
                        dt.DataTipRows(idx).Value = plotData.ctrlPVFast;
                    end
                    idx = idx + 1;
                end
                if app.mdl.acqOpt.numSamples > 1 && ~avg
                    dt.DataTipRows(idx).Label = 'Sample Num';
                    dt.DataTipRows(idx).Value = plotData.SampleArray;
                end
            end
        end
                
        function onplotData(app)
            % Plot data calculated by the model
            try
                ax = app.PlotData_ax;
                if app.mdl.process.displayExport, ax = gca; end
                
                plotData = getPlotData(app.mdl);
                opt = getPlotOpt(app.mdl);
                data = getData(app.mdl);
                imgOpt = getImgOpt(app.mdl);
                
                % start with an error band plot
                util_errorBand(plotData.xFit, plotData.yFit, plotData.yFitStd, 'Parent', ax);
                
                hold(ax,'on');
    
                % plot the fit
                plot(ax, plotData.xFit, plotData.yFit);
                pSym='*';
                % option to show lines between points
                if opt.showLines
                    if opt.showSmoothing
                        pSym='-';
                    else
                        pSym=['--' pSym];
                    end
                end
                
                % this gets reset to 4 somewhere...bring back to 1 for blue
                app.PlotData_ax.ColorOrderIndex = 1;
                
                % option to compress a group of samples to its average
                if opt.showAverage
                    if size(plotData.xValList,1) == 1
                        plotData.xValList = repmat(plotData.xValList, size(plotData.yValList,1), 1);
                        plotData.xStdList = repmat(plotData.xStdList, size(plotData.yValList,1), 1);
                        plotData.uValList = repmat(plotData.uValList, size(plotData.yValList,1), 1);
                    end
                    xtr = plotData.xValList(:,1)*NaN;
                    %h = errorbarh([plotData.xValList xtr]',[plotData.yValList xtr]',[plotData.xStdList xtr]',[plotData.yStdList xtr]', pSym, 'Parent',ax);
                    h = errorbar(ax, [plotData.xValList xtr]',[plotData.yValList xtr]',[plotData.yStdList xtr]', pSym);
                    setDataTip(app, h, plotData, 1);
                else
                    h = plot(plotData.xValList',plotData.yValList',pSym, 'Parent',ax);
                    setDataTip(app, h, plotData, 0);
                end
                % reset the frame to cover the plot area
                zoom(ax, 'reset')
                if ~imgOpt.showImg, zoom(app.UIFigure, 'out'); end
                hold(ax,'off');
                xLim = ax.XLim; yLim = ax.YLim;
                % add fit strings to the plot
                for j=1:size(plotData.yPVVal,1)
                    xTxtLoc = [1-(.1+j/2-.5), (.1+j/2-.5)] * xLim(:);
                    yTxtLoc = [1-.90, .90] * yLim(:);
                    col='k';
                    if size(plotData.yPVVal,1) > 1
                        col = get(h(min(j,length(h))),'Color');
                    end
                    text(xTxtLoc, yTxtLoc, plotData.strFitList{j},'VerticalAlignment','top','Parent',ax, ...
                        'Color',col);
                end
                % set limits to ensure plot in the right view
                xLim2 = [min(plotData.xValList(:)), max(plotData.xValList(:))]; 
                if diff(xLim2), xLim = xLim2; end
                ax.XLim = mean(xLim) + diff(xLim) / 2 * [-1, 1] * 1.1;
                ax.YLim = mean(yLim) + diff(yLim) / 2 * [-1, 1] * 1.1;
                
                if opt.XAxisId == 0
                    datetick(ax,'x','keeplimits');
                else
                    ax.XTickMode = 'auto';
                    ax.XTickLabelMode = 'auto';
                end
                
                ax.XLabel.String = plotData.xLabelStr;
                ax.YLabel.String = plotData.yLabelStr;
                ax.Title.String = strrep([opt.header ' ' datestr(data.ts)], '_', '\_');
                legend(ax, h, strrep({plotData.yPV(:,1).name}, '_', '\_'), 'Location', 'NorthWest');
                legend(ax, 'boxoff');
                
                str = {'linear' 'log'};
                ax.XScale = str{opt.showLogX + 1};
                ax.YScale = str{opt.showLogY + 1};
                
                % 3D options, plots to external figure
                if strcmp(opt.show3D, 'No 3D') || ~opt.UAxisId, return, end
                figure(3);
                switch opt.show3D
                    case 'No 3D'
                        if ~id, return; end
                    case 'Surface Plot'
                        siz = fliplr(getNumVals(app.mdl));
                        if ~all(siz > 1), return, end
                        use = logical(data.status);
                        [xData, uData, yData] = deal(nan(siz));
                        xData(use) = plotData.xPVValMean;
                        uData(use) = plotData.uPVValMean;
                        yData(use) = plotData.yPVValMean;
                        surf(xData, uData, yData);
                        shading interp
                    case 'Scatter Plot'
                        cols=get(gca,'ColorOrder');
                        for j = 1:size(plotData.yPVVal,1)
                            yData = plotData.yPVValMean(j,:);
                            scatter(plotData.xPVValMean(min(j,size(plotData.xPVValMean, 1)),:), plotData.uPVValMean(:), 100*(.05+(yData-min(yData))/(max(yData)-min(yData))),cols(1+mod(j-1,7),:));
                            hold on
                        end
                        hold off
                    case '3D Plot'
                        plot3(plotData.xValList', plotData.uValList', plotData.yValList', pSym);
                end
                ax=gca; set(ax,'Box','on');
                ax.XLabel.String = plotData.xLabelStr;
                ax.YLabel.String = plotData.uLabelStr;
                ax.ZLabel.String = plotData.yLabelStr;
                ax.Title.String = strrep([opt.header ' ' datestr(data.ts)], '_', '\_');
            catch ME
                errorMessage(app, ME, 'Error updating plot');
            end
        end
        
        function onplotProfile(app)
            % plot image data
            try
                data = getData(app.mdl);
                imgOpt = getImgOpt(app.mdl);
                
                if ~data.status(app.mdl.whichSample)
                    cla(app.PlotProf_ax);
                    return
                end
                
                % identify which point is being plotted
                idx = getLinearIdx(app.mdl);
                if imgOpt.showImg && isfield(data,'dataList')
                    % if user wants to plot image and there is data to plot
                    imgData = getImgData(app.mdl, idx, app.mdl.whichSample);
                    bits=8;
                    if imgOpt.showAutoscale, bits=0; end
                    if numel(imgData) > 1
                        figure(2);
                        for j = 1:numel(imgData)
                            profmon_imgPlot(imgData(j), 'axes', subplot(2,2,j,'Parent',2), 'bits', bits);
                        end
                    else
                        profmon_imgPlot(imgData, 'axes', app.PlotProf_ax, 'bits', bits);
                    end
                    return
                end
                
                % method for plotting image
                iMethod = imgOpt.selectedMethod;
                opts.axes = app.PlotProf_ax;
                plane = app.mdl.wirePlane;
                beam={};
                
                for tag = {'beam' 'wireBeam' 'blenBeam'}
                    if ~isfield(data, tag), continue, end
                    if isempty(data.(tag{:})(1).stats), continue, end
                    datatemp = data.(tag{:});
                    app.PlotProf_ax.YDir = 'normal';
                    beam = [beam; num2cell(squeeze(datatemp(getLinearIdx(app.mdl), min(app.mdl.whichSample, length(datatemp)),iMethod,:)))];
                end
                
                if app.mdl.blenId && isfield(data, 'blenBeam')
                    plane = 'y';
                    if isfield(data, 'blenPV') && strcmp(data.blenPV(1).name(1:13), 'OTRS:DMP1:695')
                        plane = 'x';
                    end
                end
                
                for j = 1:numel(beam)
                    opts.num = j;
                    % extract image data and plot it
                    beamAnalysis_profilePlot(beam{j}, plane, opts);
                end
                hold(opts.axes,'off');
                if ~isempty(beam), app.DataMethodLabel.Text = beam{1}.method; end
            catch ME
                errorMessage(app, ME, 'Error updating profile');
            end
        end
        
        function clearPlot(app)
            % clear plot
            try
                cla(app.PlotData_ax);
            catch ME
                errorMessage(app, ME, 'Error clearing plot');
            end
        end
        
        function clearProfile(app)
            % clear image plot
            try
                cla(app.plotProfile_ax);
            catch ME
                errorMessage(app, ME, 'Error clearing profile');
            end
        end
        
        function onupdateAxisDropDown(app)
            % update axis variable options
            try
                var = '';
                plotOpt = getPlotOpt(app.mdl);
                if ~isempty(plotOpt.XAxisNameList)
                    var = 'X';
                    app.XAxisDropDown.Items = plotOpt.XAxisNameList;
                    Xidx = min(plotOpt.XAxisId + 1, length(app.XAxisDropDown.Items));
                    app.XAxisDropDown.Value = app.XAxisDropDown.Items{Xidx};
                end
                if ~isempty(plotOpt.YAxisNameList)
                    var = 'Y';
                    app.YAxisListBox.Items = plotOpt.YAxisNameList;
                    app.YAxisListBox.ItemsData = 1:length(plotOpt.YAxisNameList);
                    Yidx = min(plotOpt.YAxisId, length(app.YAxisListBox.ItemsData));
                    app.YAxisListBox.Value = Yidx;
                end
                if ~isempty(plotOpt.UAxisNameList)
                    var = 'U';
                    app.UAxisDropDown.Items = plotOpt.UAxisNameList;
                    Uidx = min(plotOpt.UAxisId + 1, length(app.UAxisDropDown.Items));
                    app.UAxisDropDown.Value = app.UAxisDropDown.Items{Uidx};
                end
            catch ME
                errorMessage(app, ME, sprintf('Error updating %s variable', var));
            end
        end
        
        function onreadPVListChanged(app)
            % update read pv list
            try
                if isempty(app.mdl.nameList.readPV)
                    app.ReadPVListTextArea.Value = '';
                else 
                    app.ReadPVListTextArea.Value = app.mdl.nameList.readPV;
                end
            catch ME
                errorMessage(app, ME, 'Error updating read PV list');
            end
        end
        
        function onprofmonChanged(app)
            % update menu andvisibilities for selected profmon
            try
                madList = model_nameConvert(app.mdl.profmonList, 'MAD');
                app.ProfmonDropDown.Items = [{'none'} madList];
                app.ProfmonDropDown.Value = app.ProfmonDropDown.Items(app.mdl.profmonId + 1);
                isNone = strcmp(app.ProfmonDropDown.Value, 'none');
                app.ProfmonNumBGEditField.Visible = ~isNone;
                app.profmonNumBGEditFieldLabel.Visible = ~isNone;
                app.ProfmonNumAveEditField.Visible = ~isNone;
                app.profmonNumAveEditFieldLabel.Visible = ~isNone;
                app.UseStaticBGCheckBox.Visible = ~isNone;  
                app.DataMethodSlider.Visible = ~isNone;
                app.DataMethodLabel.Visible = ~isNone;
                app.DataMethodSliderLeft.Visible = ~isNone;
                app.DataMethodSliderRight.Visible = ~isNone;
                app.dataMethodSliderLabel.Visible = ~isNone;
            catch ME
                errorMessage(app, ME, 'Error updating profmon device selection');
            end
        end
        
        function onemitChanged(app)
            % update menu and visibilities for selected emittance device
            try
                madList = model_nameConvert(app.mdl.emitList, 'MAD');
                app.emitDropDown.Items = [{'none'} madList];
                app.emitDropDown.Value = app.emitDropDown.Items(app.mdl.emitId + 1);
                isNone = strcmp(app.emitDropDown.Value, 'none');
                app.emitTypeButtons.Visible = ~isNone;
            catch ME
                errorMessage(app, ME, 'Error updating emittance device selection');
            end
        end
        
        function onwireChanged(app)
            % update menu for selected wire scanner
            try
                madList = model_nameConvert(app.mdl.wireList, 'MAD');
                app.wireDropDown.Items = [{'none'} madList];
                app.wireDropDown.Value = app.wireDropDown.Items(app.mdl.wireId + 1);
                onWirePlaneButtonChanged(app);
            catch ME
                errorMessage(app, ME, 'Error updating wire selection');
            end
         end
        
        function onblenChanged(app)
            % update menu for selected blen monitor
            try
                madList = model_nameConvert(app.mdl.blenList, 'MAD');
                app.blenDropDown.Items = [{'none'} madList];
                app.blenDropDown.Value = app.blenDropDown.Items(app.mdl.blenId + 1);
            catch ME
                errorMessage(app, ME, 'Error updating bunch length device selection');
            end  
        end
        
        function onemitTypeChanged(app)
            % update emittance type radio buttons
            try
                app.(app.mdl.emitType).Value = 1;
            catch ME
                errorMessage(app, ME, 'Error updating emittance type selection');
            end
        end
        
        function onWirePlaneButtonChanged(app)
            % update wire plan buttons
            try
                showWirePlane = app.mdl.wireId || app.mdl.emitId || app.mdl.profmonId;
                app.wirePlaneButtons.Visible = showWirePlane;
                app.(app.mdl.wirePlane).Value = 1;
            catch ME
                errorMessage(app, ME, 'Error updating wire plane');
            end
        end
        
        function ondataMethodChanged(app)
            % update image data method slider and visibilities
            try
                vis = app.mdl.wireId || app.mdl.emitId || app.mdl.profmonId;
                app.DataMethodSlider.Visible = vis;
                app.DataMethodLabel.Visible = vis;
                app.DataMethodSliderRight.Visible = vis;
                app.DataMethodSliderLeft.Visible = vis;
                imgOpt = getImgOpt(app.mdl);
                app.DataMethodSlider.Limits = [1, length(imgOpt.methodMap)];
                app.DataMethodSlider.Value = find(imgOpt.methodMap == imgOpt.selectedMethod);
                app.DataMethodLabel.Text = imgOpt.methodList{app.DataMethodSlider.Value};    
            catch ME
                errorMessage(app, ME, 'Error updating date method slider');
            end
        end        
        
        function onnumSamplesChanged(app)
            % respond to change in number of samples, set visibilities as
            % necessary
            try
                acqOpt = getAcqOpt(app.mdl);
                app.NumSampleEditField.Value = acqOpt.numSamples;
                if acqOpt.numSamples > 1
                    vis = true;
                    app.SampleSlider.Limits = [1, acqOpt.numSamples];
                    app.SampleSlider.Value = app.mdl.whichSample;
                    app.SampleLabel.Text = num2str(app.mdl.whichSample);
                    useCheckBoxControl(app);
                else
                    vis = false;
                end
                app.SampleSlider.Visible = vis;
                app.SampleSliderLabel.Visible = vis;
                app.SampleSliderLeft.Visible = vis;
                app.SampleSliderRight.Visible = vis;
                app.SampleLabel.Visible = vis;
                app.DataSampleUseCheckBox.Visible = vis;
            catch ME
                errorMessage(app, ME, 'Error updating num samples');
            end
            
        end
        
        function onplotOptChanged(app)
            % respond to a change in one of the options for plotting
            try
                plotOpt = getPlotOpt(app.mdl);
                if strcmp(plotOpt.showFit, 'No Fit')
                    app.FitOrderEditField.Visible = false;
                    app.FitOrderEditFieldLabel.Visible = false;
                else
                    app.FitOrderEditField.Visible = true;
                    app.FitOrderEditFieldLabel.Visible = true;
                    app.FitOrderEditField.Value = plotOpt.showFitOrder;
                end
                if plotOpt.showSmoothing
                    app.WindowSmoothingSizeSlider.Visible = true;
                    app.WindowSizeEditField.Visible = true;
                    app.WindowSmoothingSizeSliderLabel.Visible = true;
                else
                    app.WindowSmoothingSizeSlider.Visible = false;
                    app.WindowSizeEditField.Visible = false;
                    app.WindowSmoothingSizeSliderLabel.Visible = false;
                end
                app.WindowSmoothingSizeSlider.Value = plotOpt.defWindowSize;
                app.WindowSizeEditField.Value = plotOpt.defWindowSize;
                app.ShowFitDropDown.Value = plotOpt.showFit;
                app.Show3DDropDown.Value = plotOpt.show3D;
                app.SmoothingCheckBox.Value = plotOpt.showSmoothing;
                app.ShowAverageCheckBox.Value = plotOpt.showAverage;
                app.PlotHeaderEditField.Value = plotOpt.header;
                app.ShowLinesCheckBox.Value = plotOpt.showLines;
                app.showLogXCheckBox.Value = plotOpt.showLogX;
                app.showLogYCheckBox.Value = plotOpt.showLogY;
                app.PlotGridCheckBox.Value = plotOpt.grid;
                app.PlotData_ax.XGrid = plotOpt.grid;
                app.PlotData_ax.YGrid = plotOpt.grid;
                onlabelOptChanged(app);
            catch ME
                errorMessage(app, ME, 'Error updating plot options');
            end
        end
        
        function onlabelOptChanged(app)
            % update plot label options
            try
                plotOpt = getPlotOpt(app.mdl);
                xLabel = plotOpt.XLabel;
                yLabel = plotOpt.YLabel;
                uLabel = plotOpt.ULabel;
                app.XNAMECheckBox.Value = xLabel.name;
                app.XEGUCheckBox.Value = xLabel.egu;
                app.XDESCCheckBox.Value = xLabel.desc;
                app.YNAMECheckBox.Value = yLabel.name;
                app.YEGUCheckBox.Value = yLabel.egu;
                app.YDESCCheckBox.Value = yLabel.desc;
                app.UNAMECheckBox.Value = uLabel.name;
                app.UEGUCheckBox.Value = uLabel.egu;
                app.UDESCCheckBox.Value = uLabel.desc;
            catch ME
                errorMessage(app, ME, 'Error updating plot label options');
            end
        end
        
        
        function onimgOptChanged(app)
            % respond to a change in one of the image options
            try
                imgOpt = getImgOpt(app.mdl);
                app.HoldImagesCheckBox.Value = imgOpt.holdImg;
                app.SaveImagesCheckBox.Value = imgOpt.saveImg;
                app.ShowImagesCheckBox.Value = imgOpt.showImg;
                app.ImgautoscaleCheckBox.Value = imgOpt.showAutoscale;
                app.CropCheckBox.Value = imgOpt.useImgCrop;
                app.ProcCheckBox.Value = imgOpt.procImg;
                app.ImgProcessButton.Visible = imgOpt.procImg;
                app.CropCheckBox.Visible = imgOpt.procImg;
                app.XSigEditField.Visible = imgOpt.procImg;
                app.XSigEditFieldLabel.Visible = imgOpt.procImg;
                app.YSigEditField.Visible = imgOpt.procImg;
                app.YSigEditFieldLabel.Visible = imgOpt.procImg;     
                app.ProfGridCheckBox.Value = imgOpt.grid;
                app.PlotProf_ax.XGrid = imgOpt.grid;
                app.PlotProf_ax.YGrid = imgOpt.grid;
                onstaticBGChanged(app)
            catch ME
                errorMessage(app, ME, 'Error updating image options');
            end
        end
        
        function onacqOptChanged(app)
            % update acquisition option elements with values from model
            try
                acqOpt = getAcqOpt(app.mdl);
                app.SampleDelayEditField.Value = acqOpt.sampleDelay;
                app.RandomOrderCheckBox.Value = acqOpt.randomOrder;
                app.SpiralOrderCheckBox.Value = acqOpt.spiralOrder;
                app.ZigZagCheckBox.Value = acqOpt.zigzagOrder;
                app.SampleForceCheckBox.Value = acqOpt.sampleForce;
                app.UseLEMCheckBox.Value = acqOpt.useLEM;
                app.InitialSettleEditField.Value = acqOpt.waitInit;
                app.PausePVEditField.Value = acqOpt.pausePV;
                app.SettlePVEditField.Value = acqOpt.settlePV;
            catch ME
                errorMessage(app, ME, 'Error updating acquisition options');
            end
        end
                        
        function onBSAChanged(app)
            % respond to change in BSA menu
            try
                acqOpt = getAcqOpt(app.mdl);
                app.BSADropDown.Value = app.BSADropDown.Items(acqOpt.BSA + 1);
            catch ME
                errorMessage(app, ME, 'Error updating BSA selection');
            end
        end
        
        function onstaticBGChanged(app)
            try
                imgOpt = getImgOpt(app.mdl);
                try
                    if imgOpt.staticBG == 0
                        app.StaticBGButton.BackgroundColor = 'red';
                    else
                        app.StaticBGButton.BackgroundColor = 'green';
                    end
                catch
                    app.StaticBGButton.BackgroundColor = 'green';
                end
            catch ME
                errorMessage(app, ME, 'Error updating static BG button color');
            end
        end
      
        function onctrlPVSetStatusChanged(app)
            % update the color of the ctrl PV set buttons, and current
            % value labels
            try
                process = getProcessStatus(app.mdl);
                ctrlPV = getCtrlPV(app.mdl, 0);
                ctrlPVFast = getCtrlPV(app.mdl, 1);
                if ~isempty(ctrlPV)
                    if process.settingCtrlPV
                        app.ControlPVSetButton.BackgroundColor = [0, 1, 0];
                        pause(0.1);
                    else
                        app.ControlPVSetButton.BackgroundColor = [0.96,0.96,0.96];
                        app.ControlPVCurrentVal.Text = num2str(ctrlPV.currentVal);
                        pause(0.1);
                    end
                    if process.resettingCtrlPV
                        app.ResetCtrlPVsButton.BackgroundColor = [0, 1, 0];
                        pause(0.1);
                    else
                        app.ResetCtrlPVsButton.BackgroundColor = [0.96,0.96,0.96];
                        app.ControlPVCurrentVal.Text = num2str(ctrlPV.currentVal);
                        pause(0.1);
                    end
                end
                if ~isempty(ctrlPVFast)
                    if process.settingCtrlPVFast
                        app.ControlPVFastSetButton.BackgroundColor = [0, 1, 0];
                        pause(0.1);
                    else
                        app.ControlPVFastSetButton.BackgroundColor = [0.96,0.96,0.96];
                        app.ControlPVFastCurrentVal.Text = num2str(ctrlPVFast.currentVal);
                        pause(0.1);
                    end
                    if process.resettingCtrlPVFast
                        app.ResetCtrlPVsButton.BackgroundColor = [0, 1, 0];
                        pause(0.1);
                    else
                        app.ResetCtrlPVsButton.BackgroundColor = [0.96,0.96,0.96];
                        app.ControlPVFastCurrentVal.Text = num2str(ctrlPVFast.currentVal);
                        pause(0.1);
                    end
                end
            catch ME
                errorMessage(app, ME, 'Error updating PV set button color');
            end
        end
        
        function onacqStatusChanged(app)
            % update Start button text and status text based on status of
            % the acquisition
            try
                STDOUT = 1;
                acqOpt = getAcqOpt(app.mdl);
                isOn = strcmp(app.StartButton.Text, 'Scanning...'); % state before this function was called
                
                % options for which strings to use
                str1 = {'Start Scan' 'Scanning ...'};
                str2 = {'stopped' 'aborted'};
                str3 = {[' acquisition ' str2{acqOpt.abortStatus + 1} ' after '] ' aquisition started '};
                file = app.UIFigure.Tag; % this is the name of the GUI
                
                app.StartButton.Text = str1{acqOpt.acquireStatus + 1};
                t = datestr(now);
                if ~isOn % duration since the button was hit
                    t = datestr(now - app.StartButton.UserData,'HH:MM:SS');
                end
                if acqOpt.acquireStatus ~= isOn % acq ended, tell the user how
                    app.Status.Text = [file str3{isOn + 1} t];
                    lprintf(STDOUT, [file str3{isOn + 1} t]);
                end
                app.StartButton.UserData = now;
            catch ME
                errorMessage(app, ME, 'Error updating acquisition status');
            end
        end
        
        function onstatusChanged(app)
            % update the status text box
            try
                app.Status.Text = app.mdl.status;
            catch ME
                errorMessage(app, ME, 'Error updating status');
            end
        end
        
        function initGridParams(app)
            % convert the row and column weighted parameters, in the string format
            % NUMx, into numeric ratios
            try
                row = app.GridLayout.RowHeight;
                rowRatio = zeros(1, length(row));
                for i = 1:length(row)
                    str = row{i};
                    if isnumeric(str)
                        rowRatio(i) = 0;
                    else
                        rowRatio(i) = str2double(str(1:length(str)-1));
                    end
                end
                col = app.GridLayout.ColumnWidth;
                colRatio = zeros(1, length(col));
                for i = 1:length(col)
                    str = col{i};
                    if isnumeric(str)
                        colRatio(i) = 0;
                    else
                        colRatio(i) = str2double(str(1:length(str)-1));
                    end
                end
                app.gridParams.rowWeight = row;
                app.gridParams.colWeight = col;
                app.gridParams.rowRatio = rowRatio;
                app.gridParams.colRatio = colRatio;
                app.isFixed.row = 0;
                app.isFixed.col = 0;
            catch ME
                errorMessage(app, ME, 'Error initializing layout');
            end
            
        end
        
        function errorMessage(app, ex, callbackMessage)
            % create a warning dialogue box with the location of the
            % exception
            err = ex.stack(1);
            file = err.file; funcname = err.name; linenum = num2str(err.line);
            file = strsplit(file, '/'); file = file{length(file)};
            loc = sprintf('File: %s   Function: %s   Line: %s', file, funcname, linenum);
            uiwait(errordlg(...
                    lprintf(app.STDERR, '%s%c%s%c%s', callbackMessage, newline, ex.message, newline, loc)));
        end
        
        function activate(app)
            %Correct bug with edit fields on window open
            app.UIFigure.WindowState='minimized';
            drawnow();
            app.UIFigure.WindowState='normal';
            drawnow();
        end
        
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.figSize = app.UIFigure.Position(3:4); % save the initial GUI size
            initGridParams(app);
            opts.prof_ax = app.PlotProf_ax;
            app.mdl = corrPlot_mdl(opts); % instantiate the model
            
            % set up the listeners
            app.ctrlPVListener = addlistener(app.mdl, 'ctrlPVChanged', @(~,~)app.onctrlPVChanged);
            app.ctrlPVFastListener = addlistener(app.mdl, 'ctrlPVFastChanged', @(~,~)app.onctrlPVFastChanged);
            app.ctrlPVSliderListener = addlistener(app.mdl, 'ctrlPVSliderChanged', @(~,~)app.onctrlPVSliderChanged);
            app.ctrlPVFastSliderListener = addlistener(app.mdl, 'ctrlPVFastSliderChanged', @(~,~)app.onctrlPVFastSliderChanged);
            app.plotDataListener = addlistener(app.mdl, 'plotDataReady', @(~,~)app.onplotData);
            app.plotProfileListener = addlistener(app.mdl, 'plotProfileReady', @(~,~)app.onplotProfile);
            app.updatePlotAxisListener = addlistener(app.mdl, 'updateAxisDropDown', @(~,~)app.onupdateAxisDropDown);
            app.readPVListListener = addlistener(app.mdl, 'readPVListChanged', @(~,~)app.onreadPVListChanged);
            app.clearPlotAxesListener = addlistener(app.mdl, 'clearPlotAxes', @(~,~)app.clearPlot);
            app.clearProfileAxesListener = addlistener(app.mdl, 'clearProfileAxes', @(~,~)app.clearProfile);
            app.BSAChangedListener = addlistener(app.mdl, 'BSAChanged', @(~,~)app.onBSAChanged);
            app.indexControlListener = addlistener(app.mdl, 'indexControlChanged', @(~,~)app.onindexControl);
            app.profmonListener = addlistener(app.mdl, 'profmonChanged', @(~,~)app.onprofmonChanged);
            app.emitListener = addlistener(app.mdl, 'emitChanged', @(~,~)app.onemitChanged);
            app.wireListener = addlistener(app.mdl, 'wireChanged', @(~,~)app.onwireChanged);
            app.blenListener = addlistener(app.mdl, 'blenChanged', @(~,~)app.onblenChanged);
            app.emitTypeListener = addlistener(app.mdl, 'emitTypeChanged', @(~,~)app.onemitTypeChanged);
            app.acqStatusListener = addlistener(app.mdl, 'acqStatusChanged', @(~,~)app.onacqStatusChanged);
            app.statusListener = addlistener(app.mdl, 'statusChanged', @(~,~)app.onstatusChanged);
            app.numSamplesListener = addlistener(app.mdl, 'samplesChanged', @(~,~)app.onnumSamplesChanged);
            app.ctrlPVSetStatusListener = addlistener(app.mdl, 'ctrlPVSetStatusChanged', @(~,~)app.onctrlPVSetStatusChanged);
            app.useChangedListener = addlistener(app.mdl, 'useChanged', @(~,~)app.useCheckBoxControl);
            app.plotOptListener = addlistener(app.mdl, 'plotOptChanged', @(~,~)app.onplotOptChanged);
            app.configLoadedListener = addlistener(app.mdl, 'configLoaded', @(~,~)app.appInit);
            app.imgOptListener = addlistener(app.mdl, 'imgOptChanged', @(~,~)app.onimgOptChanged);
            app.dataMethodListener = addlistener(app.mdl, 'dataMethodChanged', @(~,~)app.ondataMethodChanged);
            app.staticBGListener = addlistener(app.mdl, 'staticBGChanged', @(~,~)app.onstaticBGChanged);
            
            mdlInit(app.mdl); % initialize the model
            appInit(app); % initialize the GUI
            app.init = 0;
                        
            % Time activate function to handle edit field glitch
             t = timer('TimerFcn',@(~,~)activate(app),'StartDelay',1,'Name','activator');
             start(t);
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            mlapp_BSAControl(app.mdl, 0); % close eDef
            
            % clean up the activate timer
            t = timerfind('Name','activator');
            if ~isempty(t)
                delete(t);
            end
            
            % close the GUI
            util_mlappClose(app);
        end

        % Size changed function: UIFigure
        function UIFigureSizeChanged(app, event)
            % change the font size to fit the scaled GUI
            try 
                if app.init, return; end
                fixFont =  app.isFixed.col || app.isFixed.row;
                newPos = app.UIFigure.Position(3:4);
%                 if newPos(1) < app.minSize(1) && app.isFixed.col == 0
%                     % changing cols
%                     pxlParam = app.minSize(1) * (1/sum(app.gridParams.colRatio));
%                     idx0 = find(app.gridParams.colRatio == 0);
%                     app.GridLayout.ColumnWidth = pxlParam * app.gridParams.colRatio;
%                     if ~isempty(idx0)
%                         app.GridLayout.ColumnWidth{idx0} = app.gridParams.colWeight{idx0};
%                     end
%                     fixFont = 1;
%                     app.isFixed.col = 1;
%                 else
%                     % resetting cols
%                     app.GridLayout.ColumnWidth = app.gridParams.colWeight;
%                     app.isFixed.col = 0;
%                 end
%                 if newPos(2) < app.minSize(2) && app.isFixed.row == 0
%                     % changing rows
%                     fixFont = 1;
%                     pxlParam = app.minSize(2) * (1/sum(app.gridParams.rowRatio));
%                     idx0 = find(app.gridParams.rowRatio == 0);
%                     app.GridLayout.RowHeight = pxlParam * app.gridParams.rowRatio;
%                     if ~isempty(idx0)
%                         app.GridLayout.RowHeight{idx0} = app.gridParams.rowWeight{idx0};
%                     end
%                     app.isFixed.row = 1;
%                 else
%                     % resetting rows
%                     app.GridLayout.RowHeight = app.gridParams.rowWeight;
%                     app.isFixed.row = 0;
%                 end
%                 
%                 %app.UIFigure.Position(3:4) = max(app.UIFigure.Position(3:4), app.minSize);
%                 movegui(app.UIFigure)
                if ~fixFont
                    hasFont = findobj(app.UIFigure, '-property', 'FontSize');
                    sizeFactor = (prod(newPos)/prod(app.figSize)) ^ 0.5;
                    fontSizes = get(hasFont, 'FontSize');
                    for obj = 1:length(hasFont)
                        set(hasFont(obj), 'FontSize', fontSizes{obj} * sizeFactor);
                    end
                end
                app.figSize = newPos;
            catch ME
                errorMessage(app, ME, 'Error changing figure size');
            end
        end

        % Value changed function: ControlPVNameEditField
        function ControlPVNameEditFieldValueChanged(app, event)
            try
                % send all PV properties to the model 
                name = app.ControlPVNameEditField.Value;
                low = str2double(app.ControlPVLowEditField.Value);
                high = str2double(app.ControlPVHighEditField.Value);
                numvals = app.ControlPVNumValsEditField.Value;
                settletime = app.ControlPVSettleTimeEditField.Value;
                ctrlPVControl(app.mdl, 0, name, low, high, numvals, settletime);
            catch ME
                errorMessage(app, ME, 'Error changing control PV.')
            end
            
        end

        % Value changed function: ControlPVFastNameEditField
        function ControlPVFastNameEditFieldValueChanged(app, event)
            try
                % send all PV properties to the model 
                name = app.ControlPVFastNameEditField.Value;
                low = str2double(app.ControlPVFastLowEditField.Value);
                high = str2double(app.ControlPVFastHighEditField.Value);
                numvals = app.ControlPVFastNumValsEditField.Value;
                settletime = app.ControlPVFastSettleTimeEditField.Value;
                ctrlPVControl(app.mdl, 1, name, low, high, numvals, settletime);
            catch ME
                errorMessage(app, ME, 'Error changing fast control PV.')
            end
        end

        % Value changed function: ControlPVHighEditField, 
        % ControlPVLowEditField
        function ControlPVRangeFieldValueChanged(app, event)
            try
                lowstr = app.ControlPVLowEditField.Value;
                if isempty(lowstr)
                    low = 0;
                else
                    low = str2double(lowstr);
                    if isnan(low)
                        % allow user to enter range as some constant times the
                        % initial PV value
                        parts = strsplit(lowstr, '*');
                        disp(parts)
                        if strcmp(parts{2}, 'init')
                            low = str2double(parts{1}) * app.mdl.ctrlPV.pv.val;
                        end
                    end
                end
                highstr = app.ControlPVHighEditField.Value;
                if isempty(highstr)
                    high = 0;
                else
                    high = str2double(highstr);
                    if isnan(high)
                        % allow user to enter range as some constant times the
                        % initial PV value
                        parts = strsplit(highstr, '*');
                        if strcmp(parts{2}, 'init')
                            high = str2double(parts{1}) * app.mdl.ctrlPV.pv.val;
                        end
                    end
                end
                % send both high and low values to the model at once
                rangeControl(app.mdl, low, high, 0);
            catch ME
                errorMessage(app, ME, 'Error changing control PV range.')
            end
            
        end

        % Value changed function: ControlPVFastHighEditField, 
        % ControlPVFastLowEditField
        function ControlPVFastRangeEditFieldValueChanged(app, event)
            try
                lowstr = app.ControlPVFastLowEditField.Value;
                if isempty(lowstr)
                    low = 0;
                else
                    low = str2double(lowstr);
                    if isnan(low)
                        % allow user to enter range as some constant times the
                        % initial PV value
                        parts = strsplit(lowstr, '*');
                        disp(parts)
                        if strcmp(parts{2}, 'init')
                            low = str2double(parts{1}) * app.mdl.ctrlPVFast.pv.val;
                        end
                    end
                end
                highstr = app.ControlPVFastHighEditField.Value;
                if isempty(highstr)
                    high = 0;
                else
                    high = str2double(highstr);
                    if isnan(high)
                        % allow user to enter range as some constant times the
                        % initial PV value
                        parts = strsplit(highstr, '*');
                        if strcmp(parts{2}, 'init')
                            high = str2double(parts{1}) * app.mdl.ctrlPVFast.pv.val;
                        end
                    end
                end
                % send both high and low values to the model at once
                rangeControl(app.mdl, low, high, 1);
            catch ME
                errorMessage(app, ME, 'Error changing fast control PV range.')
            end
        end

        % Value changed function: ControlPVNumValsEditField
        function ControlPVNumValsEditFieldValueChanged(app, event)
            try
                numvals = app.ControlPVNumValsEditField.Value;
                numvalsControl(app.mdl, numvals, 0);
            catch ME
                errorMessage(app, ME, 'Error changing control PV num vals.');
            end
        end

        % Value changed function: ControlPVFastNumValsEditField
        function ControlPVFastNumValsEditFieldValueChanged(app, event)
            try
                numvals = app.ControlPVFastNumValsEditField.Value;
                numvalsControl(app.mdl, numvals, 1);
            catch ME
                errorMessage(app, ME, 'Error changing fast control PV num vals.');
            end
        end

        % Value changed function: ControlPVSettleTimeEditField
        function ControlPVSettleTimeEditFieldValueChanged(app, event)
            try
                settletime = app.ControlPVSettleTimeEditField.Value;
                settletimeControl(app.mdl, settletime, 0);
            catch ME
                errorMessage(app, ME, 'Error changing control PV settle time.');
            end
        end

        % Value changed function: ControlPVFastSettleTimeEditField
        function ControlPVFastSettleTimeEditFieldValueChanged(app, event)
            try
                settletime = app.ControlPVFastSettleTimeEditField.Value;
                settletimeControl(app.mdl, settletime, 1);
            catch ME
                errorMessage(app, ME, 'Error changing fast control PV settle time.');
            end
        end

        % Button pushed function: ControlPVSliderRight
        function ControlPVSliderRightButtonPushed(app, event)
            try
                % this action changes the underlying index of the ctrl PV
                ctrlPVIdxControl(app.mdl, app.ControlPVSlider.Value + 1);
            catch ME
                errorMessage(app, ME, 'Error toggling control PV values.');
            end
        end

        % Button pushed function: ControlPVSliderLeft
        function ControlPVSliderLeftButtonPushed(app, event)
            try
                % this action changes the underlying index of the ctrl PV
                ctrlPVIdxControl(app.mdl, app.ControlPVSlider.Value - 1);
            catch ME
                errorMessage(app, ME, 'Error toggling control PV values.');
            end
        end

        % Button pushed function: ControlPVFastSliderRight
        function ControlPVFastSliderRightButtonPushed(app, event)
            try
                % this action changes the underlying index of the fast ctrl PV
                ctrlPVIdxControl(app.mdl, app.ControlPVFastSlider.Value + 1, 1);
            catch ME
                errorMessage(app, ME, 'Error toggling fast control PV values.');
            end
        end

        % Button pushed function: ControlPVFastSliderLeft
        function ControlPVFastSliderLeftButtonPushed(app, event)
            try
                % this action changes the underlying index of the fast ctrl PV
                ctrlPVIdxControl(app.mdl, app.ControlPVFastSlider.Value - 1, 1);
            catch ME
                errorMessage(app, ME, 'Error toggling fast control PV values.');
            end
        end

        % Button pushed function: ControlPVSetButton
        function ControlPVSetButtonPushed(app, event)
            try
                ctrlPVSet(app.mdl, 0);
            catch ME
                errorMessage(app, ME, 'Error setting control PV');
            end
        end

        % Button pushed function: ControlPVFastSetButton
        function ControlPVFastSetButtonPushed(app, event)
            try
                ctrlPVSet(app.mdl, 1);
            catch ME
                errorMessage(app, ME, 'Error setting fast control PV');
            end
        end

        % Button pushed function: ResetCtrlPVsButton
        function ResetCtrlPVsButtonPushed(app, event)
            try
                ctrlPVReset(app.mdl);
            catch ME
                errorMessage(app, ME, 'Error setting fast control PV');
            end
        end

        % Button pushed function: SetBestButton
        function SetBestButtonPushed(app, event)
            try
                setBest(app.mdl);
            catch ME
                errorMessage(app, ME, 'Error setting best values');
            end
        end

        % Value changed function: InitialSettleEditField
        function InitialSettleEditFieldValueChanged(app, event)
            try
                settletimeInit = app.InitialSettleEditField.Value;
                setAcqOpt(app.mdl, 'waitInit', settletimeInit);
            catch ME
                errorMessage(app, ME, 'Error setting initial settle time.');
            end
        end

        % Value changed function: SettlePVEditField
        function SettlePVEditFieldValueChanged(app, event)
            try
                settlePV = app.SettlePVEditField.Value;
                setAcqOpt(app.mdl, 'settlePV', settlePV);
                % label is different depending on conditions
                if isempty(settlePV)
                    app.InitialSettleLabel.Text = 'Initial Settle';
                else
                    app.InitialSettleLabel.Text = 'Settle Condition';
                end
            catch ME
                errorMessage(app, ME, 'Error setting settle PV.');
            end
        end

        % Value changed function: RandomOrderCheckBox
        function RandomOrderCheckBoxValueChanged(app, event)
            try
                isRand = app.RandomOrderCheckBox.Value;
                % only one acq order checkbox at a time
                if isRand
                    app.SpiralOrderCheckBox.Value = 0;
                    app.ZigZagCheckBox.Value = 0;
                end
                setAcqOpt(app.mdl, 'randomOrder', isRand);
                setAcqOpt(app.mdl, 'spiralOrder', 0);
                setAcqOpt(app.mdl, 'zigzagOrder', 0);
            catch ME
                errorMessage(app, ME, 'Error setting acquisition order.');
            end
        end

        % Value changed function: SpiralOrderCheckBox
        function SpiralOrderCheckBoxValueChanged(app, event)
            try
                isSpiral = app.SpiralOrderCheckBox.Value;
                % only one acq order checkbox at a time
                if isSpiral
                    app.RandomOrderCheckBox.Value = 0;
                    app.ZigZagCheckBox.Value = 0;
                end
                setAcqOpt(app.mdl, 'randomOrder', 0);
                setAcqOpt(app.mdl, 'spiralOrder', isSpiral);
                setAcqOpt(app.mdl, 'zigzagOrder', 0);
            catch ME
                errorMessage(app, ME, 'Error setting acquisition order.');
            end
        end

        % Value changed function: ZigZagCheckBox
        function ZigZagCheckBoxValueChanged(app, event)
            try
                isZigzag = app.ZigZagCheckBox.Value;
                % only one acq order checkbox at a time
                if isZigzag
                    app.RandomOrderCheckBox.Value = 0;
                    app.SpiralOrderCheckBox.Value = 0;
                end
                setAcqOpt(app.mdl, 'randomOrder', 0);
                setAcqOpt(app.mdl, 'spiralOrder', 0);
                setAcqOpt(app.mdl, 'zigzagOrder', isZigzag);
            catch ME
                errorMessage(app, ME, 'Error setting acquisition order.');
            end
        end

        % Value changed function: MultiknobFileEditField
        function MultiknobFileEditFieldValueChanged(app, event)
            try    
                % send all ctrl PV properties to the model
                mkb = app.MultiknobFileEditField.Value;
                low = str2double(app.ControlPVLowEditField.Value);
                high = str2double(app.ControlPVHighEditField.Value);
                numvals = app.ControlPVNumValsEditField.Value;
                settletime = app.ControlPVSettleTimeEditField.Value;
                ctrlMKBControl(app.mdl, mkb, low, high, numvals, settletime);
            catch ME
                errorMessage(app, ME, 'Error setting multiknob acquisition.');
            end
        end

        % Value changed function: UseLEMCheckBox
        function UseLEMCheckBoxValueChanged(app, event)
            val = app.UseLEMCheckBox.Value;
            try    
                % double check with the user as this is "noisy"
                if ~isempty(val) && val
                    val=strcmp(questdlg('Do you really want to LEM at each data point?','LEM Selected'),'Yes');
                end
                app.UseLEMCheckBox.Value = val;
                setAcqOpt(app.mdl, 'useLEM', val);
            catch ME
                app.UseLEMCheckBox.Value = ~val;
                errorMessage(app, ME, 'Error changing LEM setting.');
            end
        end

        % Value changed function: PausePVEditField
        function PausePVEditFieldValueChanged(app, event)
            try
                pausePV = app.PausePVEditField.Value;
                setAcqOpt(app.mdl, 'pausePV', pausePV);
            catch ME
                 errorMessage(app, ME, 'Error setting pause PV.');
            end
        end

        % Value changed function: SampleDelayEditField
        function SampleDelayEditFieldValueChanged(app, event)
            try
                sampleDelay = app.SampleDelayEditField.Value;
                setAcqOpt(app.mdl, 'sampleDelay', sampleDelay);
            catch ME
                 errorMessage(app, ME, 'Error setting sample delay.');
            end
        end

        % Value changed function: NumSampleEditField
        function NumSampleEditFieldValueChanged(app, event)
            try
                sampleNum = app.NumSampleEditField.Value;
                sampleControl(app.mdl, sampleNum);
            catch ME
                 errorMessage(app, ME, 'Error setting number of samples.');
            end
        end

        % Value changed function: SampleForceCheckBox
        function SampleForceCheckBoxValueChanged(app, event)
            try
                sampleForce = app.SampleForceCheckBox.Value;
                setAcqOpt(app.mdl, 'sampleForce', sampleForce);
            catch ME
                 errorMessage(app, ME, 'Error setting sample force option.');
            end
        end

        % Value changed function: ReadPVListTextArea
        function ReadPVListTextAreaValueChanged(app, event)
            try
                pvs = app.ReadPVListTextArea.Value;
                readPVNameListControl(app.mdl, pvs)
            catch ME
                errorMessage(app, ME, 'Error changing read pv name list.');
            end
        end

        % Value changed function: BSADropDown
        function BSADropDownValueChanged(app, event)
            try
                % offset idx by 1 so this can be used as a boolean
                BSAidx = find(contains(app.BSADropDown.Items, app.BSADropDown.Value)) - 1;
                acquireBSAControl(app.mdl, BSAidx);
            catch ME
                errorMessage(app, ME, 'Error acquiring BSA eDef.');
            end
            
        end

        % Value changed function: ProfmonDropDown
        function ProfmonDropDownValueChanged(app, event)
            try
                profmon = app.ProfmonDropDown.Value;
                menuIdx = find(contains(app.ProfmonDropDown.Items, profmon));
                profmonControl(app.mdl, menuIdx);
            catch ME
                errorMessage(app, ME, 'Error changing profile monitor.');
            end
        end

        % Value changed function: wireDropDown
        function wireDropDownValueChanged(app, event)
            try
                wire = app.wireDropDown.Value;
                menuIdx = find(contains(app.wireDropDown.Items, wire));
                wireControl(app.mdl, menuIdx);
            catch ME
                errorMessage(app, ME, 'Error changing wire.');
            end
        end

        % Value changed function: blenDropDown
        function blenDropDownValueChanged(app, event)
            try
                blen = app.blenDropDown.Value;
                menuIdx = find(contains(app.blenDropDown.Items, blen));
                blenControl(app.mdl, menuIdx);
            catch ME
                errorMessage(app, ME, 'Error changing bunch length device.');
            end
        end

        % Value changed function: emitDropDown
        function emitDropDownValueChanged(app, event)
            try
                emitDevice = app.emitDropDown.Value;
                menuIdx = find(contains(app.emitDropDown.Items, emitDevice));
                emitControl(app.mdl, menuIdx);
            catch ME
                errorMessage(app, ME, 'Error changing emmittance device.');
            end
        end

        % Value changed function: ProfmonNumBGEditField
        function ProfmonNumBGEditFieldValueChanged(app, event)
            try
                numBG = app.ProfmonNumBGEditField.Value;
                setImgOpt(app.mdl, 'numBG', numBG);
            catch ME
                errorMessage(app, ME, 'Error changing num background.');
            end
        end

        % Value changed function: ProfmonNumAveEditField
        function ProfmonNumAveEditFieldValueChanged(app, event)
            try
                numAve = app.ProfmonNumAveEditField.Value;
                setImgOpt(app.mdl, 'numeAve', numAve);
            catch ME
                errorMessage(app, ME, 'Error changing num average.');
            end
        end

        % Value changed function: UseStaticBGCheckBox
        function UseStaticBGCheckBoxValueChanged(app, event)
            useStaticBG = app.UseStaticBGCheckBox.Value;
            try
                setImgOpt(app.mdl, 'useStaticBG', useStaticBG)
                if ~useStaticBG
                    setImgOpt(app.mdl, 'staticBG', 0);
                end
                app.StaticBGButton.Visible = useStaticBG;
            catch ME
                app.StaticBGButton.Visible = useStaticBG;
                app.UseStaticBGCheckBox.Value = ~useStaticBG;
                errorMessage(app, ME, 'Error changing static background option')
            end
            
        end

        % Value changed function: UseCalCheckBox
        function UseCalCheckBoxValueChanged(app, event)
            useCal = app.UseCalCheckBox.Value;
            try
                setImgOpt(app.mdl, 'useCal', useCal);
            catch ME
                app.UseCalCheckBox.Value = ~useCal;
                errorMessage(app, ME, 'Error changing use cal option')
            end
        end

        % Value changed function: BSACheckBox
        function BSACheckBoxValueChanged(app, event)
            try
                profmonBSA = app.BSACheckBox.Value;
                setImgOpt(app.mdl, 'BSA', profmonBSA);
            catch ME
                app.BSACheckBox.Value = ~profmonBSA;
                errorMessage(app, ME, 'Error changing prof mon BSA option')
            end  
        end

        % Value changed function: ProfmonMultiCheckBox
        function ProfmonMultiCheckBoxValueChanged(app, event)
            try
                multi = app.ProfmonMultiCheckBox.Value;
                if multi
                    % open up a listbox on the right hand side of the GUI
                    app.GridLayout.ColumnWidth{3} = 100;
                    app.ProfmonListBox.Visible = 'on';
                    madList = model_nameConvert(app.mdl.profmonList, 'MAD');
                    app.ProfmonListBox.Items = [{'none'} madList];
                else
                    app.GridLayout.ColumnWidth{3} = 1;
                    app.ProfmonListBox.Visible = 'off';
                end
            catch ME
                errorMessage(app, ME, 'Error changing multi profmon option');
            end
        end

        % Selection changed function: emitTypeButtons
        function emitTypeButtonsSelectionChanged(app, event)
            selectedButton = app.emitTypeButtons.SelectedObject;
            emitType = selectedButton.Text;
            try
                emitTypeControl(app.mdl, emitType);
            catch ME
                selectedButton.Value = 0;
                errorMessage(app, ME, 'Error changing emmittance type')
            end
        end

        % Selection changed function: wirePlaneButtons
        function wirePlaneButtonsSelectionChanged(app, event)
            selectedButton = app.wirePlaneButtons.SelectedObject;
            plane = selectedButton.Text;
            try
                wirePlaneControl(app.mdl, plane)
            catch ME
                selectedButton.Value = 0;
                errorMessage(app, ME, 'Error changing wire plane')
            end
        end

        % Selection changed function: BeamPath
        function BeamPathSelectionChanged(app, event)
            selectedButton = app.BeamPath.SelectedObject;
            try
                index = selectedButton.Text{1};
                indexControl(app.mdl, index);
            catch ME
                errorMessage(app, ME, 'Error changing beam path')
                selectedButton.Value = 0;
            end
        end

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
            try
                acquireStart(app.mdl);
            catch ME
                setAcquireStatus(app.mdl, 0, 1);
                errorMessage(app, ME, "Error with data acquisition.");
            end
        end

        % Button pushed function: AbortButton
        function AbortButtonPushed(app, event)
            try
                setAcquireStatus(app.mdl, 0, 1);
            catch ME
                errorMessage(app, ME, 'Error aborting acquisition');
            end
        end

        % Value changed function: XAxisDropDown
        function XAxisDropDownValueChanged(app, event)
            try
                xVar = app.XAxisDropDown.Value;
                plotXAxisControl(app.mdl, xVar);
            catch ME
                errorMessage(app, ME, 'Error changing X variable'); 
            end
        end

        % Value changed function: YAxisListBox
        function YAxisListBoxValueChanged(app, event)
            try
                yVar = app.YAxisListBox.Items(app.YAxisListBox.Value);
                plotYAxisControl(app.mdl, yVar);
            catch ME
                errorMessage(app, ME, 'Error changing Y variable'); 
            end
        end

        % Value changed function: UAxisDropDown
        function UAxisDropDownValueChanged(app, event)
            try
                uVar = app.UAxisDropDown.Value;
                plotUAxisControl(app.mdl, uVar);
            catch ME
                errorMessage(app, ME, 'Error changing U variable'); 
            end
        end

        % Value changed function: showLogXCheckBox
        function showLogXCheckBoxValueChanged(app, event)
            try
                xLog = app.showLogXCheckBox.Value;
                setPlotOpt(app.mdl, 'showLogX', xLog);
            catch ME
                errorMessage(app, ME, 'Error changing X log scale.');
            end
        end

        % Value changed function: showLogYCheckBox
        function showLogYCheckBoxValueChanged(app, event)
            try
                yLog = app.showLogYCheckBox.Value;
                setPlotOpt(app.mdl, 'showLogY', yLog);
            catch ME
                errorMessage(app, ME, 'Error changing Y log scale.');
            end
            
        end

        % Value changed function: PlotHeaderEditField
        function PlotHeaderEditFieldValueChanged(app, event)
            try
                plotHeader = app.PlotHeaderEditField.Value;
                setPlotOpt(app.mdl, 'header', plotHeader);
            catch ME
                errorMessage(app, ME, 'Error setting plot header.');
            end
        end

        % Value changed function: ControlPVCheckBox
        function ControlPVCheckBoxValueChanged(app, event)
            try
                use = app.ControlPVCheckBox.Value;
                useControl(app.mdl, 'ctrlPV', use);
            catch ME
                errorMessage(app, ME, 'Error setting use buttons.');
            end
        end

        % Value changed function: ControlPVFastCheckBox
        function ControlPVFastCheckBoxValueChanged(app, event)
            try
                use = app.ControlPVFastCheckBox.Value;
                useControl(app.mdl, 'ctrlPVFast', use);
            catch ME
                errorMessage(app, ME, 'Error setting use buttons.');
            end
        end

        % Value changed function: DataSampleUseCheckBox
        function DataSampleUseCheckBoxValueChanged(app, event)
            try
                use = app.DataSampleUseCheckBox.Value;
                useControl(app.mdl, 'sample', use);
            catch ME
                errorMessage(app, ME, 'Error setting use buttons.');
            end
        end

        % Button pushed function: SampleSliderRight
        function SampleSliderRightButtonPushed(app, event)
            try
                sampleControl(app.mdl, [], app.SampleSlider.Value + 1);
            catch ME
                errorMessage(app, ME, 'Error increasing sample index');
            end
                
        end

        % Button pushed function: SampleSliderLeft
        function SampleSliderLeftButtonPushed(app, event)
            try
                sampleControl(app.mdl, [], app.SampleSlider.Value - 1);
            catch ME
                errorMessage(app, ME, 'Error decreasing sample index');
            end
        end

        % Button pushed function: DataMethodSliderLeft
        function DataMethodSliderLeftButtonPushed(app, event)
            try
                method = round(app.DataMethodSlider.Value);
                dataMethodControl(app.mdl, method-1);
            catch ME
                errorMessage(app, ME, 'Error changing data method');
            end
        end

        % Button pushed function: DataMethodSliderRight
        function DataMethodSliderRightButtonPushed(app, event)
            try
                method = round(app.DataMethodSlider.Value);
                dataMethodControl(app.mdl, method+1);
            catch ME
                errorMessage(app, ME, 'Error changing data method');
            end
        end

        % Value changed function: ControlPVSlider
        function ControlPVSliderValueChanged(app, event)
            try
                idx = round(app.ControlPVSlider.Value);
                ctrlPVIdxControl(app.mdl, idx);
            catch ME
                errorMessage(app, ME, 'Error changing control PV index');
            end    
        end

        % Value changed function: ControlPVFastSlider
        function ControlPVFastSliderValueChanged(app, event)
            try
                idx = round(app.ControlPVFastSlider.Value);
                ctrlPVIdxControl(app.mdl, idx, 1);
            catch ME
                errorMessage(app, ME, 'Error changing fast control PV index');
            end
        end

        % Value changed function: SampleSlider
        function SampleSliderValueChanged(app, event)
            try
                idx = round(app.SampleSlider.Value);
                sampleControl(app.mdl, [], idx);
            catch ME
                errorMessage(app, ME, 'Error changing sample index');
            end
        end

        % Value changed function: DataMethodSlider
        function DataMethodSliderValueChanged(app, event)
            try
                method = round(app.DataMethodSlider.Value);
                dataMethodControl(app.mdl, method);
            catch ME
                errorMessage(app, ME, 'Error changing data method');
            end
        end

        % Value changed function: Show3DDropDown
        function Show3DDropDownValueChanged(app, event)
            try
                show3D = app.Show3DDropDown.Value;
                setPlotOpt(app.mdl, 'show3D', show3D);
            catch ME
                errorMessage(app, ME, 'Error changing show 3D option');
            end
        end

        % Value changed function: ShowFitDropDown
        function ShowFitDropDownValueChanged(app, event)
            try
                fit = app.ShowFitDropDown.Value;
                setPlotOpt(app.mdl, 'showFit', fit);
            catch ME
                errorMessage(app, ME, 'Error changing fit option');
            end
        end

        % Value changed function: ShowLinesCheckBox
        function ShowLinesCheckBoxValueChanged(app, event)
            try
                showLines = app.ShowLinesCheckBox.Value;
                setPlotOpt(app.mdl, 'showLines', showLines);
            catch ME
                errorMessage(app, ME, 'Error changing show lines option');
            end
        end

        % Value changed function: ShowAverageCheckBox
        function ShowAverageCheckBoxValueChanged(app, event)
            try
                showAverage = app.ShowAverageCheckBox.Value;
                % either smooth or average
                if showAverage
                    app.SmoothingCheckBox.Value = 0;
                    SmoothingCheckBoxValueChanged(app, event);
                end
                setPlotOpt(app.mdl, 'showAverage', showAverage);
            catch ME
                errorMessage(app, ME, 'Error changing show average option');
            end
        end

        % Value changed function: SmoothingCheckBox
        function SmoothingCheckBoxValueChanged(app, event)
            try
                showSmooth = app.SmoothingCheckBox.Value;
                % either smooth or average
                if showSmooth
                    app.ShowAverageCheckBox.Value = 0;
                    ShowAverageCheckBoxValueChanged(app, event);
                end
                setPlotOpt(app.mdl, 'showSmoothing', showSmooth);
            catch ME
                errorMessage(app, ME, 'Error changing show smoothing option');
            end
        end

        % Value changed function: FitOrderEditField
        function FitOrderEditFieldValueChanged(app, event)
            try
                order = app.FitOrderEditField.Value;
                setPlotOpt(app.mdl, 'showFitOrder', order);
            catch ME
                errorMessage(app, ME, 'Error changing fit order');
            end
        end

        % Value changed function: WindowSmoothingSizeSlider
        function WindowSmoothingSizeSliderValueChanged(app, event)
            try
                window = round(app.WindowSmoothingSizeSlider.Value);
                setPlotOpt(app.mdl, 'defWindowSize', window);
            catch ME
                errorMessage(app, ME, 'Error changing window size');
            end
        end

        % Value changed function: WindowSizeEditField
        function WindowSizeEditFieldValueChanged(app, event)
            try
                window = app.WindowSizeEditField.Value;
                if window <= 50 % max allowed
                    setPlotOpt(app.mdl, 'defWindowSize', window);
                else
                    onplotOptChanged(app);
                end
            catch ME
                errorMessage(app, ME, 'Error changing window size');
            end
        end

        % Button pushed function: GetDataButton
        function GetDataButtonPushed(app, event)
            try
                acquireCurrentGet(app.mdl, 'query')
            catch ME
                errorMessage(app, ME, 'Error acquiring current value');
            end
        end

        % Value changed function: FormulaTextArea
        function FormulaTextAreaValueChanged(app, event)
            try
                formula = app.FormulaTextArea.Value;
                calcPVControl(app.mdl, formula);
            catch ME
                errorMessage(app, ME, 'Error setting forumla');
            end

        end

        % Button pushed function: LogbookButton
        function LogbookButtonPushed(app, event)
            try
                dataExport(app.mdl, 1);
            catch ME
                errorMessage(app, ME, 'Error exporting to logbook');
            end
        end

        % Button pushed function: ExportButton
        function ExportButtonPushed(app, event)
            try
                dataExport(app.mdl, 0);
            catch ME
                errorMessage(app, ME, 'Error exporting data');
            end
        end

        % Button pushed function: DispDataButton
        function DispDataButtonPushed(app, event)
            try
                dataDisp(app.mdl);
            catch ME
                errorMessage(app, ME, 'Error displaying data');
            end
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
            try
                dataSave(app.mdl, 0);
            catch ME
                errorMessage(app, ME, 'Error saving data');
            end
        end

        % Button pushed function: SaveAsButton
        function SaveAsButtonPushed(app, event)
            try
                dataSave(app.mdl, 1);
                
            catch ME
                errorMessage(app, ME, 'Error saving data');
            end
        end

        % Button pushed function: LoadButton
        function LoadButtonPushed(app, event)
            try
                dataLoad(app.mdl);
            catch ME
                errorMessage(app, ME, 'Error loading data');
            end
        end

        % Button pushed function: LoadConfigButton
        function LoadConfigButtonPushed(app, event)
            try
                configLoad(app.mdl);
            catch ME
                errorMessage(app, ME, 'Error loading config');
            end
        end

        % Button pushed function: SaveConfigButton
        function SaveConfigButtonPushed(app, event)
            try
                configSave(app.mdl);
            catch ME
                errorMessage(app, ME, 'Error saving config');
            end
        end

        % Button pushed function: ImgProcessButton
        function ImgProcessButtonPushed(app, event)
            try
                imgProcControl(app.mdl);
            catch ME
                errorMessage(app, ME, 'Error processing image');
            end
        end

        % Value changed function: UDESCCheckBox, UEGUCheckBox, 
        % UNAMECheckBox, XDESCCheckBox, XEGUCheckBox, 
        % XNAMECheckBox, YDESCCheckBox, YEGUCheckBox, YNAMECheckBox
        function PlotLabelCheckBoxValueChanged(app, event)
            opts.XLabelname = app.XNAMECheckBox.Value;
            opts.XLabeldesc = app.XDESCCheckBox.Value;
            opts.XLabelegu = app.XEGUCheckBox.Value;
            opts.YLabelname = app.YNAMECheckBox.Value;
            opts.YLabeldesc = app.YDESCCheckBox.Value;
            opts.YLabelegu = app.YEGUCheckBox.Value;
            opts.ULabelname = app.UNAMECheckBox.Value;
            opts.ULabeldesc = app.UDESCCheckBox.Value;
            opts.ULabelegu = app.UEGUCheckBox.Value;
            setPlotLabels(app.mdl, opts);
        end

        % Value changed function: ShowImagesCheckBox
        function ShowImagesCheckBoxValueChanged(app, event)
            try
                show = app.ShowImagesCheckBox.Value;
                setImgOpt(app.mdl, 'showImg', show);
            catch ME
                app.ShowImagesCheckBox.Value = ~show;
                errorMessage(app, ME, 'Error changing show images option');
            end
        end

        % Value changed function: HoldImagesCheckBox
        function HoldImagesCheckBoxValueChanged(app, event)
            try
                % value determines other visibilities
                holdImg = app.HoldImagesCheckBox.Value;
                setImgOpt(app.mdl, 'holdImg', holdImg);
                app.SaveImagesCheckBox.Visible = holdImg;
                app.ShowImagesCheckBox.Visible = holdImg;
                app.ImgautoscaleCheckBox.Visible = holdImg;
            catch ME
                app.HoldImagesCheckBox.Value = ~holdImg;
                app.SaveImagesCheckBox.Visible = ~holdImg;
                app.ShowImagesCheckBox.Visible = ~holdImg;
                app.ImgautoscaleCheckBox.Visible = ~holdImg;
                errorMessage(app, ME, 'Error changing hold images option')
            end
        end

        % Value changed function: SaveImagesCheckBox
        function SaveImagesCheckBoxValueChanged(app, event)
            try
                saveImg = app.SaveImagesCheckBox.Value;
                setImgOpt(app.mdl, 'saveImg', saveImg);
            catch ME
                app.SaveImagesCheckBox.Value = ~saveImg;
                errorMessage(app, ME, 'Error changing save images option');
            end
        end

        % Value changed function: CropCheckBox
        function CropCheckBoxValueChanged(app, event)
            try
                crop = app.CropCheckBox.Value;
                setImgOpt(app.mdl, 'useImgCrop', crop);
            catch ME
                app.CropCheckBox.Value = ~crop;
                errorMessage(app, ME, 'Error changing crop images option');
            end
        end

        % Value changed function: ProcCheckBox
        function ProcCheckBoxValueChanged(app, event)
            try
                proc = app.ProcCheckBox.Value;
                setImgOpt(app.mdl, 'procImg', proc);
            catch ME
                app.ProcCheckBox.Value = ~proc;
                errorMessage(app, ME, 'Error changing process images option');
            end
        end

        % Value changed function: ImgautoscaleCheckBox
        function ImgautoscaleCheckBoxValueChanged(app, event)
            try
                imgAuto = app.ImgautoscaleCheckBox.Value;
                setImgOpt(app.mdl,'showAutoscale', imgAuto);
            catch ME
                app.ImgautoscaleCheckBox.Value = ~imgAuto;
                errorMessage(app, ME, 'Error changing image autoscale option');
            end
        end

        % Value changed function: XSigEditField
        function XSigEditFieldValueChanged(app, event)
            try
                xSig = app.XSigEditField.Value;
                setImgOpt(app.mdl,'XSig', xSig);
            catch ME
                errorMessage(app, ME, 'Error changing sigma X value');
            end            
        end

        % Value changed function: YSigEditField
        function YSigEditFieldValueChanged(app, event)
            try
                ySig = app.YSigEditField.Value;
                setImgOpt(app.mdl,'YSig', ySig);
            catch ME
                errorMessage(app, ME, 'Error changing sigma Y value');
            end    
        end

        % Value changed function: PlotGridCheckBox
        function PlotGridCheckBoxValueChanged(app, event)
            try
                val = app.PlotGridCheckBox.Value;
                setPlotOpt(app.mdl, 'grid', val);
            catch ME
                errorMessage(app, ME, 'Error changing grid option');
            end
        end

        % Value changed function: ProfGridCheckBox
        function ProfGridCheckBoxValueChanged(app, event)
            try
                val = app.ProfGridCheckBox.Value;
                setImgOpt(app.mdl, 'grid', val);
            catch ME
                errorMessage(app, ME, 'Error changing grid option');
            end
        end

        % Button pushed function: StaticBGButton
        function StaticBGButtonPushed(app, event)
            try
                staticBGControl(app.mdl);
            catch ME
                errorMessage(app, ME, 'Error getting static background');
            end
        end

        % Value changed function: ControlPVRelativeCheckBox
        function ControlPVRelativeCheckBoxValueChanged(app, event)
            relative = app.ControlPVRelativeCheckBox.Value;
            try
                relativeControl(app.mdl, relative, 0);
                % other view stuff to make more clear the options
            catch ME
                errorMessage(app, ME, 'Error setting relative scan option.');
                app.ControlPVRelativeCheckBox.Value = ~relative;
            end
        end

        % Value changed function: ControlPVFastRelativeCheckBox
        function ControlPVFastRelativeCheckBoxValueChanged(app, event)
            relative = app.ControlPVFastRelativeCheckBox.Value;
            try
                relativeControl(app.mdl, relative, 1);
                % other view stuff to make more clear the options
            catch ME
                errorMessage(app, ME, 'Error setting relative scan option.');
                app.ControlPVFastRelativeCheckBox.Value = ~relative;
            end
        end

        % Button pushed function: MetadataButton
        function MetadataButtonPushed(app, event)
            try
                corrplot_metaData(app.mdl);
            catch ME
                errorMessage(app, ME, 'Error loading metadata window');
            end
        end

        % Menu selected function: Wiki
        function WikiMenuSelected(app, event)
            try
                helpControl(app.mdl);
            catch ME
                errorMessage(app, ME, 'Error accessing documentation');
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Color = [0.9412 0.9412 0.9412];
            app.UIFigure.Position = [100 100 1254 1375];
            app.UIFigure.Name = 'Correlation Plot';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);
            app.UIFigure.Scrollable = 'on';
            app.UIFigure.Tag = 'corrPlot_guiDEV';

            % Create HelpMenu
            app.HelpMenu = uimenu(app.UIFigure);
            app.HelpMenu.Text = 'Help';

            % Create Wiki
            app.Wiki = uimenu(app.HelpMenu);
            app.Wiki.MenuSelectedFcn = createCallbackFcn(app, @WikiMenuSelected, true);
            app.Wiki.Text = 'Wiki';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '1.3x', 1};
            app.GridLayout.RowHeight = {'0.1x', '0.18x', '1x', '1x', '1x', '0.3x'};
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Scrollable = 'on';

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.RowHeight = {'0.95x', '1x', '0.05x'};
            app.GridLayout4.RowSpacing = 1;
            app.GridLayout4.Layout.Row = [3 6];
            app.GridLayout4.Layout.Column = 1;

            % Create GridLayout19
            app.GridLayout19 = uigridlayout(app.GridLayout4);
            app.GridLayout19.ColumnWidth = {'1x', '0.5x', '1x', '0.5x'};
            app.GridLayout19.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout19.ColumnSpacing = 5;
            app.GridLayout19.RowSpacing = 5;
            app.GridLayout19.Padding = [5 0 0 0];
            app.GridLayout19.Layout.Row = 1;
            app.GridLayout19.Layout.Column = 2;

            % Create FastControlPVNameEditFieldLabel
            app.FastControlPVNameEditFieldLabel = uilabel(app.GridLayout19);
            app.FastControlPVNameEditFieldLabel.VerticalAlignment = 'bottom';
            app.FastControlPVNameEditFieldLabel.Layout.Row = 1;
            app.FastControlPVNameEditFieldLabel.Layout.Column = [1 3];
            app.FastControlPVNameEditFieldLabel.Text = 'Fast Control PV Name';

            % Create ControlPVFastNameEditField
            app.ControlPVFastNameEditField = uieditfield(app.GridLayout19, 'text');
            app.ControlPVFastNameEditField.ValueChangedFcn = createCallbackFcn(app, @ControlPVFastNameEditFieldValueChanged, true);
            app.ControlPVFastNameEditField.Tag = 'PV2';
            app.ControlPVFastNameEditField.Layout.Row = 2;
            app.ControlPVFastNameEditField.Layout.Column = [1 3];

            % Create FastCurrentLabel
            app.FastCurrentLabel = uilabel(app.GridLayout19);
            app.FastCurrentLabel.Layout.Row = 3;
            app.FastCurrentLabel.Layout.Column = 1;
            app.FastCurrentLabel.Text = 'Current:';

            % Create FastInitialLabel
            app.FastInitialLabel = uilabel(app.GridLayout19);
            app.FastInitialLabel.Layout.Row = 4;
            app.FastInitialLabel.Layout.Column = 1;
            app.FastInitialLabel.Text = 'Initial';

            % Create GridLayout49
            app.GridLayout49 = uigridlayout(app.GridLayout19);
            app.GridLayout49.ColumnWidth = {'1x', '0.5x'};
            app.GridLayout49.RowHeight = {'1x'};
            app.GridLayout49.ColumnSpacing = 0;
            app.GridLayout49.RowSpacing = 0;
            app.GridLayout49.Padding = [0 0 0 0];
            app.GridLayout49.Layout.Row = 3;
            app.GridLayout49.Layout.Column = [2 3];

            % Create ControlPVFastCurrentVal
            app.ControlPVFastCurrentVal = uilabel(app.GridLayout49);
            app.ControlPVFastCurrentVal.HorizontalAlignment = 'right';
            app.ControlPVFastCurrentVal.Layout.Row = 1;
            app.ControlPVFastCurrentVal.Layout.Column = 1;
            app.ControlPVFastCurrentVal.Text = '';

            % Create ControlPVFastCurrentUnits
            app.ControlPVFastCurrentUnits = uilabel(app.GridLayout49);
            app.ControlPVFastCurrentUnits.Layout.Row = 1;
            app.ControlPVFastCurrentUnits.Layout.Column = 2;
            app.ControlPVFastCurrentUnits.Text = '';

            % Create GridLayout49_2
            app.GridLayout49_2 = uigridlayout(app.GridLayout19);
            app.GridLayout49_2.ColumnWidth = {'1x', '0.5x'};
            app.GridLayout49_2.RowHeight = {'1x'};
            app.GridLayout49_2.ColumnSpacing = 0;
            app.GridLayout49_2.RowSpacing = 0;
            app.GridLayout49_2.Padding = [0 0 0 0];
            app.GridLayout49_2.Layout.Row = 4;
            app.GridLayout49_2.Layout.Column = [2 3];

            % Create ControlPVFastInitialUnits
            app.ControlPVFastInitialUnits = uilabel(app.GridLayout49_2);
            app.ControlPVFastInitialUnits.Layout.Row = 1;
            app.ControlPVFastInitialUnits.Layout.Column = 2;
            app.ControlPVFastInitialUnits.Text = '';

            % Create ControlPVFastInitialVal
            app.ControlPVFastInitialVal = uilabel(app.GridLayout49_2);
            app.ControlPVFastInitialVal.HorizontalAlignment = 'right';
            app.ControlPVFastInitialVal.Layout.Row = 1;
            app.ControlPVFastInitialVal.Layout.Column = 1;
            app.ControlPVFastInitialVal.Text = '';

            % Create StaticBGButton
            app.StaticBGButton = uibutton(app.GridLayout19, 'push');
            app.StaticBGButton.ButtonPushedFcn = createCallbackFcn(app, @StaticBGButtonPushed, true);
            app.StaticBGButton.BackgroundColor = [1 0 0];
            app.StaticBGButton.Layout.Row = 15;
            app.StaticBGButton.Layout.Column = 3;
            app.StaticBGButton.Text = 'Get';

            % Create ControlPVFastRangeUnits
            app.ControlPVFastRangeUnits = uilabel(app.GridLayout19);
            app.ControlPVFastRangeUnits.Layout.Row = 6;
            app.ControlPVFastRangeUnits.Layout.Column = 4;
            app.ControlPVFastRangeUnits.Text = '';

            % Create NumValsLabel_2
            app.NumValsLabel_2 = uilabel(app.GridLayout19);
            app.NumValsLabel_2.VerticalAlignment = 'bottom';
            app.NumValsLabel_2.Layout.Row = 8;
            app.NumValsLabel_2.Layout.Column = 3;
            app.NumValsLabel_2.Text = 'Num Vals';

            % Create ControlPVFastNumValsEditField
            app.ControlPVFastNumValsEditField = uieditfield(app.GridLayout19, 'numeric');
            app.ControlPVFastNumValsEditField.ValueChangedFcn = createCallbackFcn(app, @ControlPVFastNumValsEditFieldValueChanged, true);
            app.ControlPVFastNumValsEditField.Tag = '2';
            app.ControlPVFastNumValsEditField.HorizontalAlignment = 'left';
            app.ControlPVFastNumValsEditField.Layout.Row = 9;
            app.ControlPVFastNumValsEditField.Layout.Column = 3;
            app.ControlPVFastNumValsEditField.Value = 1;

            % Create SampleDelaysEditFieldLabel
            app.SampleDelaysEditFieldLabel = uilabel(app.GridLayout19);
            app.SampleDelaysEditFieldLabel.VerticalAlignment = 'bottom';
            app.SampleDelaysEditFieldLabel.Layout.Row = 11;
            app.SampleDelaysEditFieldLabel.Layout.Column = [3 4];
            app.SampleDelaysEditFieldLabel.Text = 'Sample Delay (s)';

            % Create SampleDelayEditField
            app.SampleDelayEditField = uieditfield(app.GridLayout19, 'numeric');
            app.SampleDelayEditField.ValueChangedFcn = createCallbackFcn(app, @SampleDelayEditFieldValueChanged, true);
            app.SampleDelayEditField.HorizontalAlignment = 'left';
            app.SampleDelayEditField.Layout.Row = 12;
            app.SampleDelayEditField.Layout.Column = 3;
            app.SampleDelayEditField.Value = 0.1;

            % Create ControlPVFastSetButton
            app.ControlPVFastSetButton = uibutton(app.GridLayout19, 'push');
            app.ControlPVFastSetButton.ButtonPushedFcn = createCallbackFcn(app, @ControlPVFastSetButtonPushed, true);
            app.ControlPVFastSetButton.Layout.Row = 10;
            app.ControlPVFastSetButton.Layout.Column = [1 2];
            app.ControlPVFastSetButton.Text = 'Set Fast Ctrl PV';

            % Create profmonDropDownLabel
            app.profmonDropDownLabel = uilabel(app.GridLayout19);
            app.profmonDropDownLabel.VerticalAlignment = 'bottom';
            app.profmonDropDownLabel.Layout.Row = 14;
            app.profmonDropDownLabel.Layout.Column = [1 2];
            app.profmonDropDownLabel.Text = 'Profile Monitor';

            % Create ProfmonDropDown
            app.ProfmonDropDown = uidropdown(app.GridLayout19);
            app.ProfmonDropDown.Items = {};
            app.ProfmonDropDown.ValueChangedFcn = createCallbackFcn(app, @ProfmonDropDownValueChanged, true);
            app.ProfmonDropDown.Layout.Row = 15;
            app.ProfmonDropDown.Layout.Column = [1 2];
            app.ProfmonDropDown.Value = {};

            % Create UseCalCheckBox
            app.UseCalCheckBox = uicheckbox(app.GridLayout19);
            app.UseCalCheckBox.ValueChangedFcn = createCallbackFcn(app, @UseCalCheckBoxValueChanged, true);
            app.UseCalCheckBox.Text = 'Use Cal';
            app.UseCalCheckBox.Layout.Row = 16;
            app.UseCalCheckBox.Layout.Column = 1;
            app.UseCalCheckBox.Value = true;

            % Create SettleTimeLabel_2
            app.SettleTimeLabel_2 = uilabel(app.GridLayout19);
            app.SettleTimeLabel_2.VerticalAlignment = 'bottom';
            app.SettleTimeLabel_2.Layout.Row = 8;
            app.SettleTimeLabel_2.Layout.Column = 1;
            app.SettleTimeLabel_2.Text = 'Settle Time';

            % Create ControlPVFastSettleTimeEditField
            app.ControlPVFastSettleTimeEditField = uieditfield(app.GridLayout19, 'numeric');
            app.ControlPVFastSettleTimeEditField.ValueChangedFcn = createCallbackFcn(app, @ControlPVFastSettleTimeEditFieldValueChanged, true);
            app.ControlPVFastSettleTimeEditField.HorizontalAlignment = 'left';
            app.ControlPVFastSettleTimeEditField.Layout.Row = 9;
            app.ControlPVFastSettleTimeEditField.Layout.Column = 1;
            app.ControlPVFastSettleTimeEditField.Value = 1;

            % Create SamplesLabel
            app.SamplesLabel = uilabel(app.GridLayout19);
            app.SamplesLabel.VerticalAlignment = 'bottom';
            app.SamplesLabel.Layout.Row = 11;
            app.SamplesLabel.Layout.Column = 1;
            app.SamplesLabel.Text = '# Samples';

            % Create NumSampleEditField
            app.NumSampleEditField = uieditfield(app.GridLayout19, 'numeric');
            app.NumSampleEditField.Limits = [0 Inf];
            app.NumSampleEditField.ValueChangedFcn = createCallbackFcn(app, @NumSampleEditFieldValueChanged, true);
            app.NumSampleEditField.HorizontalAlignment = 'left';
            app.NumSampleEditField.Layout.Row = 12;
            app.NumSampleEditField.Layout.Column = 1;
            app.NumSampleEditField.Value = 1;

            % Create profmonNumAveEditFieldLabel
            app.profmonNumAveEditFieldLabel = uilabel(app.GridLayout19);
            app.profmonNumAveEditFieldLabel.HorizontalAlignment = 'right';
            app.profmonNumAveEditFieldLabel.Layout.Row = 18;
            app.profmonNumAveEditFieldLabel.Layout.Column = 2;
            app.profmonNumAveEditFieldLabel.Text = '# Ave';

            % Create ProfmonNumAveEditField
            app.ProfmonNumAveEditField = uieditfield(app.GridLayout19, 'numeric');
            app.ProfmonNumAveEditField.ValueChangedFcn = createCallbackFcn(app, @ProfmonNumAveEditFieldValueChanged, true);
            app.ProfmonNumAveEditField.Layout.Row = 18;
            app.ProfmonNumAveEditField.Layout.Column = 3;
            app.ProfmonNumAveEditField.Value = 1;

            % Create UseStaticBGCheckBox
            app.UseStaticBGCheckBox = uicheckbox(app.GridLayout19);
            app.UseStaticBGCheckBox.ValueChangedFcn = createCallbackFcn(app, @UseStaticBGCheckBoxValueChanged, true);
            app.UseStaticBGCheckBox.Text = 'Use Static BG';
            app.UseStaticBGCheckBox.Layout.Row = 16;
            app.UseStaticBGCheckBox.Layout.Column = [2 3];

            % Create CtrlPVLowEditFieldLabel_5
            app.CtrlPVLowEditFieldLabel_5 = uilabel(app.GridLayout19);
            app.CtrlPVLowEditFieldLabel_5.VerticalAlignment = 'bottom';
            app.CtrlPVLowEditFieldLabel_5.Layout.Row = 5;
            app.CtrlPVLowEditFieldLabel_5.Layout.Column = 1;
            app.CtrlPVLowEditFieldLabel_5.Text = 'Ctrl PV Low';

            % Create ControlPVFastLowEditField
            app.ControlPVFastLowEditField = uieditfield(app.GridLayout19, 'text');
            app.ControlPVFastLowEditField.ValueChangedFcn = createCallbackFcn(app, @ControlPVFastRangeEditFieldValueChanged, true);
            app.ControlPVFastLowEditField.Layout.Row = 6;
            app.ControlPVFastLowEditField.Layout.Column = 1;
            app.ControlPVFastLowEditField.Value = '0';

            % Create CtrlPVHighLabel_2
            app.CtrlPVHighLabel_2 = uilabel(app.GridLayout19);
            app.CtrlPVHighLabel_2.VerticalAlignment = 'bottom';
            app.CtrlPVHighLabel_2.Layout.Row = 5;
            app.CtrlPVHighLabel_2.Layout.Column = 3;
            app.CtrlPVHighLabel_2.Text = 'Ctrl PV High';

            % Create ControlPVFastHighEditField
            app.ControlPVFastHighEditField = uieditfield(app.GridLayout19, 'text');
            app.ControlPVFastHighEditField.ValueChangedFcn = createCallbackFcn(app, @ControlPVFastRangeEditFieldValueChanged, true);
            app.ControlPVFastHighEditField.Layout.Row = 6;
            app.ControlPVFastHighEditField.Layout.Column = 3;
            app.ControlPVFastHighEditField.Value = '0';

            % Create profmonNumBGEditFieldLabel
            app.profmonNumBGEditFieldLabel = uilabel(app.GridLayout19);
            app.profmonNumBGEditFieldLabel.HorizontalAlignment = 'right';
            app.profmonNumBGEditFieldLabel.Layout.Row = 17;
            app.profmonNumBGEditFieldLabel.Layout.Column = 2;
            app.profmonNumBGEditFieldLabel.Text = '# BG';

            % Create ProfmonNumBGEditField
            app.ProfmonNumBGEditField = uieditfield(app.GridLayout19, 'numeric');
            app.ProfmonNumBGEditField.ValueChangedFcn = createCallbackFcn(app, @ProfmonNumBGEditFieldValueChanged, true);
            app.ProfmonNumBGEditField.Layout.Row = 17;
            app.ProfmonNumBGEditField.Layout.Column = 3;
            app.ProfmonNumBGEditField.Value = 1;

            % Create BSACheckBox
            app.BSACheckBox = uicheckbox(app.GridLayout19);
            app.BSACheckBox.ValueChangedFcn = createCallbackFcn(app, @BSACheckBoxValueChanged, true);
            app.BSACheckBox.Text = 'BSA';
            app.BSACheckBox.Layout.Row = 17;
            app.BSACheckBox.Layout.Column = 1;

            % Create ProfmonMultiCheckBox
            app.ProfmonMultiCheckBox = uicheckbox(app.GridLayout19);
            app.ProfmonMultiCheckBox.ValueChangedFcn = createCallbackFcn(app, @ProfmonMultiCheckBoxValueChanged, true);
            app.ProfmonMultiCheckBox.Enable = 'off';
            app.ProfmonMultiCheckBox.Text = 'Multi';
            app.ProfmonMultiCheckBox.Layout.Row = 18;
            app.ProfmonMultiCheckBox.Layout.Column = 1;

            % Create SetBestButton
            app.SetBestButton = uibutton(app.GridLayout19, 'push');
            app.SetBestButton.ButtonPushedFcn = createCallbackFcn(app, @SetBestButtonPushed, true);
            app.SetBestButton.BackgroundColor = [0 1 1];
            app.SetBestButton.Layout.Row = 10;
            app.SetBestButton.Layout.Column = [3 4];
            app.SetBestButton.Text = 'Set Best';

            % Create SampleForceCheckBox
            app.SampleForceCheckBox = uicheckbox(app.GridLayout19);
            app.SampleForceCheckBox.ValueChangedFcn = createCallbackFcn(app, @SampleForceCheckBoxValueChanged, true);
            app.SampleForceCheckBox.Text = 'Force';
            app.SampleForceCheckBox.Layout.Row = 13;
            app.SampleForceCheckBox.Layout.Column = 3;

            % Create ControlPVFastRelativeCheckBox
            app.ControlPVFastRelativeCheckBox = uicheckbox(app.GridLayout19);
            app.ControlPVFastRelativeCheckBox.ValueChangedFcn = createCallbackFcn(app, @ControlPVFastRelativeCheckBoxValueChanged, true);
            app.ControlPVFastRelativeCheckBox.Text = 'Relative';
            app.ControlPVFastRelativeCheckBox.Layout.Row = 7;
            app.ControlPVFastRelativeCheckBox.Layout.Column = [1 2];

            % Create GridLayout27
            app.GridLayout27 = uigridlayout(app.GridLayout4);
            app.GridLayout27.ColumnWidth = {'1x', '0.25x', '1x', '0.25x'};
            app.GridLayout27.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout27.ColumnSpacing = 5;
            app.GridLayout27.RowSpacing = 5;
            app.GridLayout27.Padding = [0 0 5 0];
            app.GridLayout27.Layout.Row = 1;
            app.GridLayout27.Layout.Column = 1;

            % Create ControlPVNameEditFieldLabel
            app.ControlPVNameEditFieldLabel = uilabel(app.GridLayout27);
            app.ControlPVNameEditFieldLabel.VerticalAlignment = 'bottom';
            app.ControlPVNameEditFieldLabel.Layout.Row = 1;
            app.ControlPVNameEditFieldLabel.Layout.Column = [1 2];
            app.ControlPVNameEditFieldLabel.Text = 'Control PV Name';

            % Create ControlPVNameEditField
            app.ControlPVNameEditField = uieditfield(app.GridLayout27, 'text');
            app.ControlPVNameEditField.ValueChangedFcn = createCallbackFcn(app, @ControlPVNameEditFieldValueChanged, true);
            app.ControlPVNameEditField.Tag = 'PV1';
            app.ControlPVNameEditField.Layout.Row = 2;
            app.ControlPVNameEditField.Layout.Column = [1 3];

            % Create CurrentLabel
            app.CurrentLabel = uilabel(app.GridLayout27);
            app.CurrentLabel.Layout.Row = 3;
            app.CurrentLabel.Layout.Column = 1;
            app.CurrentLabel.Text = 'Current:';

            % Create InitialLabel
            app.InitialLabel = uilabel(app.GridLayout27);
            app.InitialLabel.Layout.Row = 4;
            app.InitialLabel.Layout.Column = 1;
            app.InitialLabel.Text = 'Initial';

            % Create GridLayout48
            app.GridLayout48 = uigridlayout(app.GridLayout27);
            app.GridLayout48.ColumnWidth = {'1x', '0.5x'};
            app.GridLayout48.RowHeight = {'1x'};
            app.GridLayout48.ColumnSpacing = 0;
            app.GridLayout48.RowSpacing = 0;
            app.GridLayout48.Padding = [0 0 0 0];
            app.GridLayout48.Layout.Row = 3;
            app.GridLayout48.Layout.Column = [2 3];

            % Create ControlPVCurrentUnits
            app.ControlPVCurrentUnits = uilabel(app.GridLayout48);
            app.ControlPVCurrentUnits.Layout.Row = 1;
            app.ControlPVCurrentUnits.Layout.Column = 2;
            app.ControlPVCurrentUnits.Text = '';

            % Create ControlPVCurrentVal
            app.ControlPVCurrentVal = uilabel(app.GridLayout48);
            app.ControlPVCurrentVal.HorizontalAlignment = 'right';
            app.ControlPVCurrentVal.Layout.Row = 1;
            app.ControlPVCurrentVal.Layout.Column = 1;
            app.ControlPVCurrentVal.Text = '';

            % Create GridLayout48_2
            app.GridLayout48_2 = uigridlayout(app.GridLayout27);
            app.GridLayout48_2.ColumnWidth = {'1x', '0.5x'};
            app.GridLayout48_2.RowHeight = {'1x'};
            app.GridLayout48_2.ColumnSpacing = 0;
            app.GridLayout48_2.RowSpacing = 0;
            app.GridLayout48_2.Padding = [0 0 0 0];
            app.GridLayout48_2.Layout.Row = 4;
            app.GridLayout48_2.Layout.Column = [2 3];

            % Create ControlPVInitialVal
            app.ControlPVInitialVal = uilabel(app.GridLayout48_2);
            app.ControlPVInitialVal.HorizontalAlignment = 'right';
            app.ControlPVInitialVal.Layout.Row = 1;
            app.ControlPVInitialVal.Layout.Column = 1;
            app.ControlPVInitialVal.Text = '';

            % Create ControlPVInitialUnits
            app.ControlPVInitialUnits = uilabel(app.GridLayout48_2);
            app.ControlPVInitialUnits.Layout.Row = 1;
            app.ControlPVInitialUnits.Layout.Column = 2;
            app.ControlPVInitialUnits.Text = '';

            % Create ControlPVRangeUnits
            app.ControlPVRangeUnits = uilabel(app.GridLayout27);
            app.ControlPVRangeUnits.Layout.Row = 6;
            app.ControlPVRangeUnits.Layout.Column = 4;
            app.ControlPVRangeUnits.Text = '';

            % Create NumValsLabel
            app.NumValsLabel = uilabel(app.GridLayout27);
            app.NumValsLabel.VerticalAlignment = 'bottom';
            app.NumValsLabel.Layout.Row = 8;
            app.NumValsLabel.Layout.Column = 3;
            app.NumValsLabel.Text = 'Num Vals';

            % Create ControlPVNumValsEditField
            app.ControlPVNumValsEditField = uieditfield(app.GridLayout27, 'numeric');
            app.ControlPVNumValsEditField.ValueChangedFcn = createCallbackFcn(app, @ControlPVNumValsEditFieldValueChanged, true);
            app.ControlPVNumValsEditField.Tag = '1';
            app.ControlPVNumValsEditField.HorizontalAlignment = 'left';
            app.ControlPVNumValsEditField.Layout.Row = 9;
            app.ControlPVNumValsEditField.Layout.Column = 3;
            app.ControlPVNumValsEditField.Value = 7;

            % Create ControlPVSetButton
            app.ControlPVSetButton = uibutton(app.GridLayout27, 'push');
            app.ControlPVSetButton.ButtonPushedFcn = createCallbackFcn(app, @ControlPVSetButtonPushed, true);
            app.ControlPVSetButton.Layout.Row = 10;
            app.ControlPVSetButton.Layout.Column = [1 2];
            app.ControlPVSetButton.Text = 'Set Ctrl PV';

            % Create InitialSettleLabel
            app.InitialSettleLabel = uilabel(app.GridLayout27);
            app.InitialSettleLabel.VerticalAlignment = 'bottom';
            app.InitialSettleLabel.Layout.Row = 11;
            app.InitialSettleLabel.Layout.Column = 1;
            app.InitialSettleLabel.Text = 'Initial Settle';

            % Create InitialSettleEditField
            app.InitialSettleEditField = uieditfield(app.GridLayout27, 'numeric');
            app.InitialSettleEditField.ValueChangedFcn = createCallbackFcn(app, @InitialSettleEditFieldValueChanged, true);
            app.InitialSettleEditField.HorizontalAlignment = 'left';
            app.InitialSettleEditField.Layout.Row = 12;
            app.InitialSettleEditField.Layout.Column = 1;
            app.InitialSettleEditField.Value = 1;

            % Create SettleTimeLabel
            app.SettleTimeLabel = uilabel(app.GridLayout27);
            app.SettleTimeLabel.VerticalAlignment = 'bottom';
            app.SettleTimeLabel.Layout.Row = 8;
            app.SettleTimeLabel.Layout.Column = 1;
            app.SettleTimeLabel.Text = 'Settle Time';

            % Create ControlPVSettleTimeEditField
            app.ControlPVSettleTimeEditField = uieditfield(app.GridLayout27, 'numeric');
            app.ControlPVSettleTimeEditField.ValueChangedFcn = createCallbackFcn(app, @ControlPVSettleTimeEditFieldValueChanged, true);
            app.ControlPVSettleTimeEditField.HorizontalAlignment = 'left';
            app.ControlPVSettleTimeEditField.Layout.Row = 9;
            app.ControlPVSettleTimeEditField.Layout.Column = 1;
            app.ControlPVSettleTimeEditField.Value = 1;

            % Create SettlePVEditFieldLabel
            app.SettlePVEditFieldLabel = uilabel(app.GridLayout27);
            app.SettlePVEditFieldLabel.VerticalAlignment = 'bottom';
            app.SettlePVEditFieldLabel.Layout.Row = 13;
            app.SettlePVEditFieldLabel.Layout.Column = 1;
            app.SettlePVEditFieldLabel.Text = 'Settle PV';

            % Create SettlePVEditField
            app.SettlePVEditField = uieditfield(app.GridLayout27, 'text');
            app.SettlePVEditField.ValueChangedFcn = createCallbackFcn(app, @SettlePVEditFieldValueChanged, true);
            app.SettlePVEditField.Layout.Row = 14;
            app.SettlePVEditField.Layout.Column = [1 3];

            % Create RandomOrderCheckBox
            app.RandomOrderCheckBox = uicheckbox(app.GridLayout27);
            app.RandomOrderCheckBox.ValueChangedFcn = createCallbackFcn(app, @RandomOrderCheckBoxValueChanged, true);
            app.RandomOrderCheckBox.Text = 'Random Order';
            app.RandomOrderCheckBox.Layout.Row = 15;
            app.RandomOrderCheckBox.Layout.Column = [1 2];

            % Create SpiralOrderCheckBox
            app.SpiralOrderCheckBox = uicheckbox(app.GridLayout27);
            app.SpiralOrderCheckBox.ValueChangedFcn = createCallbackFcn(app, @SpiralOrderCheckBoxValueChanged, true);
            app.SpiralOrderCheckBox.Text = 'Spiral Order';
            app.SpiralOrderCheckBox.Layout.Row = 16;
            app.SpiralOrderCheckBox.Layout.Column = [1 2];

            % Create ZigZagCheckBox
            app.ZigZagCheckBox = uicheckbox(app.GridLayout27);
            app.ZigZagCheckBox.ValueChangedFcn = createCallbackFcn(app, @ZigZagCheckBoxValueChanged, true);
            app.ZigZagCheckBox.Text = 'Zig Zag';
            app.ZigZagCheckBox.Layout.Row = 17;
            app.ZigZagCheckBox.Layout.Column = [1 2];

            % Create BSAModeDropDownLabel
            app.BSAModeDropDownLabel = uilabel(app.GridLayout27);
            app.BSAModeDropDownLabel.VerticalAlignment = 'bottom';
            app.BSAModeDropDownLabel.Layout.Row = 17;
            app.BSAModeDropDownLabel.Layout.Column = 3;
            app.BSAModeDropDownLabel.Text = 'BSA Mode';

            % Create BSADropDown
            app.BSADropDown = uidropdown(app.GridLayout27);
            app.BSADropDown.Items = {'None', 'ONE_HERTZ', 'TEN_HERTZ', 'THIRTY_HERTZ', 'TS4', '120_HERTZ', 'EVG_BURST'};
            app.BSADropDown.ValueChangedFcn = createCallbackFcn(app, @BSADropDownValueChanged, true);
            app.BSADropDown.Layout.Row = 18;
            app.BSADropDown.Layout.Column = 3;
            app.BSADropDown.Value = 'None';

            % Create CtrlPVLowEditFieldLabel_4
            app.CtrlPVLowEditFieldLabel_4 = uilabel(app.GridLayout27);
            app.CtrlPVLowEditFieldLabel_4.VerticalAlignment = 'bottom';
            app.CtrlPVLowEditFieldLabel_4.Layout.Row = 5;
            app.CtrlPVLowEditFieldLabel_4.Layout.Column = 1;
            app.CtrlPVLowEditFieldLabel_4.Text = 'Ctrl PV Low';

            % Create ControlPVLowEditField
            app.ControlPVLowEditField = uieditfield(app.GridLayout27, 'text');
            app.ControlPVLowEditField.ValueChangedFcn = createCallbackFcn(app, @ControlPVRangeFieldValueChanged, true);
            app.ControlPVLowEditField.Layout.Row = 6;
            app.ControlPVLowEditField.Layout.Column = 1;
            app.ControlPVLowEditField.Value = '0';

            % Create CtrlPVHighLabel
            app.CtrlPVHighLabel = uilabel(app.GridLayout27);
            app.CtrlPVHighLabel.VerticalAlignment = 'bottom';
            app.CtrlPVHighLabel.Layout.Row = 5;
            app.CtrlPVHighLabel.Layout.Column = 3;
            app.CtrlPVHighLabel.Text = 'Ctrl PV High';

            % Create ControlPVHighEditField
            app.ControlPVHighEditField = uieditfield(app.GridLayout27, 'text');
            app.ControlPVHighEditField.ValueChangedFcn = createCallbackFcn(app, @ControlPVRangeFieldValueChanged, true);
            app.ControlPVHighEditField.Layout.Row = 6;
            app.ControlPVHighEditField.Layout.Column = 3;
            app.ControlPVHighEditField.Value = '0';

            % Create ResetCtrlPVsButton
            app.ResetCtrlPVsButton = uibutton(app.GridLayout27, 'push');
            app.ResetCtrlPVsButton.ButtonPushedFcn = createCallbackFcn(app, @ResetCtrlPVsButtonPushed, true);
            app.ResetCtrlPVsButton.Layout.Row = 10;
            app.ResetCtrlPVsButton.Layout.Column = [3 4];
            app.ResetCtrlPVsButton.Text = 'Reset Ctrl PVs';

            % Create ControlPVRelativeCheckBox
            app.ControlPVRelativeCheckBox = uicheckbox(app.GridLayout27);
            app.ControlPVRelativeCheckBox.ValueChangedFcn = createCallbackFcn(app, @ControlPVRelativeCheckBoxValueChanged, true);
            app.ControlPVRelativeCheckBox.Text = 'Relative';
            app.ControlPVRelativeCheckBox.Layout.Row = 7;
            app.ControlPVRelativeCheckBox.Layout.Column = [1 2];

            % Create MetadataButton
            app.MetadataButton = uibutton(app.GridLayout27, 'push');
            app.MetadataButton.ButtonPushedFcn = createCallbackFcn(app, @MetadataButtonPushed, true);
            app.MetadataButton.Layout.Row = 18;
            app.MetadataButton.Layout.Column = 1;
            app.MetadataButton.Text = 'Metadata';

            % Create GridLayout37
            app.GridLayout37 = uigridlayout(app.GridLayout4);
            app.GridLayout37.ColumnWidth = {'1x', '0.1x'};
            app.GridLayout37.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '2x', '2x', '1x', '3x', '2x'};
            app.GridLayout37.ColumnSpacing = 5;
            app.GridLayout37.RowSpacing = 5;
            app.GridLayout37.Padding = [0 0 0 0];
            app.GridLayout37.Layout.Row = 2;
            app.GridLayout37.Layout.Column = 1;

            % Create ControlPVFastCheckBox
            app.ControlPVFastCheckBox = uicheckbox(app.GridLayout37);
            app.ControlPVFastCheckBox.ValueChangedFcn = createCallbackFcn(app, @ControlPVFastCheckBoxValueChanged, true);
            app.ControlPVFastCheckBox.Text = '';
            app.ControlPVFastCheckBox.Layout.Row = 9;
            app.ControlPVFastCheckBox.Layout.Column = 2;

            % Create GridLayout50
            app.GridLayout50 = uigridlayout(app.GridLayout37);
            app.GridLayout50.ColumnWidth = {'1.5x', '0.5x', '0.5x'};
            app.GridLayout50.RowHeight = {'1x'};
            app.GridLayout50.ColumnSpacing = 0;
            app.GridLayout50.RowSpacing = 0;
            app.GridLayout50.Padding = [0 0 0 0];
            app.GridLayout50.Layout.Row = 6;
            app.GridLayout50.Layout.Column = 1;

            % Create ControlPVSliderVal
            app.ControlPVSliderVal = uilabel(app.GridLayout50);
            app.ControlPVSliderVal.HorizontalAlignment = 'right';
            app.ControlPVSliderVal.Layout.Row = 1;
            app.ControlPVSliderVal.Layout.Column = 2;
            app.ControlPVSliderVal.Text = '';

            % Create ControlPVSliderUnits
            app.ControlPVSliderUnits = uilabel(app.GridLayout50);
            app.ControlPVSliderUnits.Layout.Row = 1;
            app.ControlPVSliderUnits.Layout.Column = 3;
            app.ControlPVSliderUnits.Text = '';

            % Create ControlPVSliderLabel
            app.ControlPVSliderLabel = uilabel(app.GridLayout50);
            app.ControlPVSliderLabel.Layout.Row = 1;
            app.ControlPVSliderLabel.Layout.Column = 1;
            app.ControlPVSliderLabel.Text = '';

            % Create GridLayout50_2
            app.GridLayout50_2 = uigridlayout(app.GridLayout37);
            app.GridLayout50_2.ColumnWidth = {'1.5x', '0.5x', '0.5x'};
            app.GridLayout50_2.RowHeight = {'0.5x'};
            app.GridLayout50_2.ColumnSpacing = 0;
            app.GridLayout50_2.RowSpacing = 0;
            app.GridLayout50_2.Padding = [0 0 0 0];
            app.GridLayout50_2.Layout.Row = 8;
            app.GridLayout50_2.Layout.Column = 1;

            % Create ControlPVFastSliderVal
            app.ControlPVFastSliderVal = uilabel(app.GridLayout50_2);
            app.ControlPVFastSliderVal.HorizontalAlignment = 'right';
            app.ControlPVFastSliderVal.Layout.Row = 1;
            app.ControlPVFastSliderVal.Layout.Column = 2;
            app.ControlPVFastSliderVal.Text = '';

            % Create ControlPVFastSliderUnits
            app.ControlPVFastSliderUnits = uilabel(app.GridLayout50_2);
            app.ControlPVFastSliderUnits.Layout.Row = 1;
            app.ControlPVFastSliderUnits.Layout.Column = 3;
            app.ControlPVFastSliderUnits.Text = '';

            % Create ControlPVFastSliderLabel
            app.ControlPVFastSliderLabel = uilabel(app.GridLayout50_2);
            app.ControlPVFastSliderLabel.Layout.Row = 1;
            app.ControlPVFastSliderLabel.Layout.Column = 1;
            app.ControlPVFastSliderLabel.Text = '';

            % Create GridLayout51
            app.GridLayout51 = uigridlayout(app.GridLayout37);
            app.GridLayout51.ColumnWidth = {'0.5x', '0.5x', '1x'};
            app.GridLayout51.ColumnSpacing = 0;
            app.GridLayout51.RowSpacing = 0;
            app.GridLayout51.Padding = [0 0 0 0];
            app.GridLayout51.Layout.Row = 14;
            app.GridLayout51.Layout.Column = 1;

            % Create FitOrderEditFieldLabel
            app.FitOrderEditFieldLabel = uilabel(app.GridLayout51);
            app.FitOrderEditFieldLabel.VerticalAlignment = 'bottom';
            app.FitOrderEditFieldLabel.Layout.Row = 1;
            app.FitOrderEditFieldLabel.Layout.Column = 1;
            app.FitOrderEditFieldLabel.Text = 'Order';

            % Create FitOrderEditField
            app.FitOrderEditField = uieditfield(app.GridLayout51, 'numeric');
            app.FitOrderEditField.ValueChangedFcn = createCallbackFcn(app, @FitOrderEditFieldValueChanged, true);
            app.FitOrderEditField.HorizontalAlignment = 'left';
            app.FitOrderEditField.Layout.Row = 2;
            app.FitOrderEditField.Layout.Column = 1;

            % Create WindowSmoothingSizeSliderLabel
            app.WindowSmoothingSizeSliderLabel = uilabel(app.GridLayout51);
            app.WindowSmoothingSizeSliderLabel.HorizontalAlignment = 'right';
            app.WindowSmoothingSizeSliderLabel.Layout.Row = 1;
            app.WindowSmoothingSizeSliderLabel.Layout.Column = [2 3];
            app.WindowSmoothingSizeSliderLabel.Text = 'Window Smoothing Size';

            % Create WindowSmoothingSizeSlider
            app.WindowSmoothingSizeSlider = uislider(app.GridLayout51);
            app.WindowSmoothingSizeSlider.Limits = [1 50];
            app.WindowSmoothingSizeSlider.MajorTicks = [];
            app.WindowSmoothingSizeSlider.MajorTickLabels = {''};
            app.WindowSmoothingSizeSlider.ValueChangedFcn = createCallbackFcn(app, @WindowSmoothingSizeSliderValueChanged, true);
            app.WindowSmoothingSizeSlider.MinorTicks = [];
            app.WindowSmoothingSizeSlider.Layout.Row = 2;
            app.WindowSmoothingSizeSlider.Layout.Column = 3;
            app.WindowSmoothingSizeSlider.Value = 1;

            % Create GridLayout52
            app.GridLayout52 = uigridlayout(app.GridLayout37);
            app.GridLayout52.ColumnWidth = {'1x'};
            app.GridLayout52.ColumnSpacing = 0;
            app.GridLayout52.RowSpacing = 0;
            app.GridLayout52.Padding = [0 0 0 0];
            app.GridLayout52.Layout.Row = 14;
            app.GridLayout52.Layout.Column = 2;

            % Create WindowSizeEditField
            app.WindowSizeEditField = uieditfield(app.GridLayout52, 'numeric');
            app.WindowSizeEditField.Limits = [1 50];
            app.WindowSizeEditField.ValueChangedFcn = createCallbackFcn(app, @WindowSizeEditFieldValueChanged, true);
            app.WindowSizeEditField.Layout.Row = 2;
            app.WindowSizeEditField.Layout.Column = 1;
            app.WindowSizeEditField.Value = 1;

            % Create GridLayout53
            app.GridLayout53 = uigridlayout(app.GridLayout37);
            app.GridLayout53.ColumnWidth = {'0.5x', '0.5x', '1x'};
            app.GridLayout53.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout53.ColumnSpacing = 5;
            app.GridLayout53.RowSpacing = 0;
            app.GridLayout53.Padding = [0 0 0 0];
            app.GridLayout53.Layout.Row = 13;
            app.GridLayout53.Layout.Column = 1;

            % Create ShowLinesCheckBox
            app.ShowLinesCheckBox = uicheckbox(app.GridLayout53);
            app.ShowLinesCheckBox.ValueChangedFcn = createCallbackFcn(app, @ShowLinesCheckBoxValueChanged, true);
            app.ShowLinesCheckBox.Text = 'Show Lines';
            app.ShowLinesCheckBox.Layout.Row = 1;
            app.ShowLinesCheckBox.Layout.Column = 3;

            % Create ShowAverageCheckBox
            app.ShowAverageCheckBox = uicheckbox(app.GridLayout53);
            app.ShowAverageCheckBox.ValueChangedFcn = createCallbackFcn(app, @ShowAverageCheckBoxValueChanged, true);
            app.ShowAverageCheckBox.Text = 'Show Average';
            app.ShowAverageCheckBox.Layout.Row = 2;
            app.ShowAverageCheckBox.Layout.Column = 3;

            % Create SmoothingCheckBox
            app.SmoothingCheckBox = uicheckbox(app.GridLayout53);
            app.SmoothingCheckBox.ValueChangedFcn = createCallbackFcn(app, @SmoothingCheckBoxValueChanged, true);
            app.SmoothingCheckBox.Text = 'Smoothing';
            app.SmoothingCheckBox.Layout.Row = 3;
            app.SmoothingCheckBox.Layout.Column = 3;

            % Create Show3DDropDown
            app.Show3DDropDown = uidropdown(app.GridLayout53);
            app.Show3DDropDown.Items = {'No 3D', 'Surface Plot', 'Scatter Plot', '3D Plot'};
            app.Show3DDropDown.ValueChangedFcn = createCallbackFcn(app, @Show3DDropDownValueChanged, true);
            app.Show3DDropDown.Layout.Row = 1;
            app.Show3DDropDown.Layout.Column = [1 2];
            app.Show3DDropDown.Value = 'No 3D';

            % Create ShowFitDropDown
            app.ShowFitDropDown = uidropdown(app.GridLayout53);
            app.ShowFitDropDown.Items = {'No Fit', 'Polynomial', 'Gaussian', 'Sine', 'Parabola', 'Erf'};
            app.ShowFitDropDown.ValueChangedFcn = createCallbackFcn(app, @ShowFitDropDownValueChanged, true);
            app.ShowFitDropDown.Layout.Row = 2;
            app.ShowFitDropDown.Layout.Column = [1 2];
            app.ShowFitDropDown.Value = 'No Fit';

            % Create GridLayout54
            app.GridLayout54 = uigridlayout(app.GridLayout37);
            app.GridLayout54.ColumnWidth = {'0.3x', '1x', '1x', '1x', '0.3x'};
            app.GridLayout54.ColumnSpacing = 3;
            app.GridLayout54.RowSpacing = 0;
            app.GridLayout54.Padding = [0 0 0 0];
            app.GridLayout54.Layout.Row = 11;
            app.GridLayout54.Layout.Column = 1;

            % Create dataMethodSliderLabel
            app.dataMethodSliderLabel = uilabel(app.GridLayout54);
            app.dataMethodSliderLabel.Layout.Row = 1;
            app.dataMethodSliderLabel.Layout.Column = [1 2];
            app.dataMethodSliderLabel.Text = 'Method Select';

            % Create DataMethodSlider
            app.DataMethodSlider = uislider(app.GridLayout54);
            app.DataMethodSlider.Limits = [1 10];
            app.DataMethodSlider.MajorTicks = [1 2 3 4 5 6 7 8 9 10];
            app.DataMethodSlider.MajorTickLabels = {'', ''};
            app.DataMethodSlider.ValueChangedFcn = createCallbackFcn(app, @DataMethodSliderValueChanged, true);
            app.DataMethodSlider.MinorTicks = [];
            app.DataMethodSlider.Layout.Row = 2;
            app.DataMethodSlider.Layout.Column = [2 4];
            app.DataMethodSlider.Value = 1;

            % Create DataMethodLabel
            app.DataMethodLabel = uilabel(app.GridLayout54);
            app.DataMethodLabel.HorizontalAlignment = 'right';
            app.DataMethodLabel.Layout.Row = 1;
            app.DataMethodLabel.Layout.Column = [4 5];
            app.DataMethodLabel.Text = '';

            % Create DataMethodSliderLeft
            app.DataMethodSliderLeft = uibutton(app.GridLayout54, 'push');
            app.DataMethodSliderLeft.ButtonPushedFcn = createCallbackFcn(app, @DataMethodSliderLeftButtonPushed, true);
            app.DataMethodSliderLeft.Layout.Row = 2;
            app.DataMethodSliderLeft.Layout.Column = 1;
            app.DataMethodSliderLeft.Text = '<';

            % Create DataMethodSliderRight
            app.DataMethodSliderRight = uibutton(app.GridLayout54, 'push');
            app.DataMethodSliderRight.ButtonPushedFcn = createCallbackFcn(app, @DataMethodSliderRightButtonPushed, true);
            app.DataMethodSliderRight.Layout.Row = 2;
            app.DataMethodSliderRight.Layout.Column = 5;
            app.DataMethodSliderRight.Text = '>';

            % Create GridLayout55
            app.GridLayout55 = uigridlayout(app.GridLayout37);
            app.GridLayout55.ColumnWidth = {'0.1x', '1x', '0.1x'};
            app.GridLayout55.RowHeight = {'1x'};
            app.GridLayout55.ColumnSpacing = 3;
            app.GridLayout55.RowSpacing = 0;
            app.GridLayout55.Padding = [0 0 0 0];
            app.GridLayout55.Layout.Row = 7;
            app.GridLayout55.Layout.Column = 1;

            % Create ControlPVSliderLeft
            app.ControlPVSliderLeft = uibutton(app.GridLayout55, 'push');
            app.ControlPVSliderLeft.ButtonPushedFcn = createCallbackFcn(app, @ControlPVSliderLeftButtonPushed, true);
            app.ControlPVSliderLeft.Layout.Row = 1;
            app.ControlPVSliderLeft.Layout.Column = 1;
            app.ControlPVSliderLeft.Text = '<';

            % Create ControlPVSliderRight
            app.ControlPVSliderRight = uibutton(app.GridLayout55, 'push');
            app.ControlPVSliderRight.ButtonPushedFcn = createCallbackFcn(app, @ControlPVSliderRightButtonPushed, true);
            app.ControlPVSliderRight.Layout.Row = 1;
            app.ControlPVSliderRight.Layout.Column = 3;
            app.ControlPVSliderRight.Text = '>';

            % Create ControlPVSlider
            app.ControlPVSlider = uislider(app.GridLayout55);
            app.ControlPVSlider.Limits = [0 0.4];
            app.ControlPVSlider.MajorTicks = [];
            app.ControlPVSlider.ValueChangedFcn = createCallbackFcn(app, @ControlPVSliderValueChanged, true);
            app.ControlPVSlider.MinorTicks = [];
            app.ControlPVSlider.Layout.Row = 1;
            app.ControlPVSlider.Layout.Column = 2;

            % Create GridLayout56
            app.GridLayout56 = uigridlayout(app.GridLayout37);
            app.GridLayout56.ColumnWidth = {'0.1x', '1x', '0.1x'};
            app.GridLayout56.RowHeight = {'1x'};
            app.GridLayout56.ColumnSpacing = 3;
            app.GridLayout56.RowSpacing = 0;
            app.GridLayout56.Padding = [0 0 0 0];
            app.GridLayout56.Layout.Row = 9;
            app.GridLayout56.Layout.Column = 1;

            % Create ControlPVFastSlider
            app.ControlPVFastSlider = uislider(app.GridLayout56);
            app.ControlPVFastSlider.Limits = [0 0.4];
            app.ControlPVFastSlider.MajorTicks = [];
            app.ControlPVFastSlider.ValueChangedFcn = createCallbackFcn(app, @ControlPVFastSliderValueChanged, true);
            app.ControlPVFastSlider.MinorTicks = [];
            app.ControlPVFastSlider.Layout.Row = 1;
            app.ControlPVFastSlider.Layout.Column = 2;

            % Create ControlPVFastSliderLeft
            app.ControlPVFastSliderLeft = uibutton(app.GridLayout56, 'push');
            app.ControlPVFastSliderLeft.ButtonPushedFcn = createCallbackFcn(app, @ControlPVFastSliderLeftButtonPushed, true);
            app.ControlPVFastSliderLeft.Layout.Row = 1;
            app.ControlPVFastSliderLeft.Layout.Column = 1;
            app.ControlPVFastSliderLeft.Text = '<';

            % Create ControlPVFastSliderRight
            app.ControlPVFastSliderRight = uibutton(app.GridLayout56, 'push');
            app.ControlPVFastSliderRight.ButtonPushedFcn = createCallbackFcn(app, @ControlPVFastSliderRightButtonPushed, true);
            app.ControlPVFastSliderRight.Layout.Row = 1;
            app.ControlPVFastSliderRight.Layout.Column = 3;
            app.ControlPVFastSliderRight.Text = '>';

            % Create GridLayout57
            app.GridLayout57 = uigridlayout(app.GridLayout37);
            app.GridLayout57.ColumnWidth = {'0.1x', '1x', '0.1x'};
            app.GridLayout57.ColumnSpacing = 3;
            app.GridLayout57.RowSpacing = 0;
            app.GridLayout57.Padding = [0 0 0 0];
            app.GridLayout57.Layout.Row = 10;
            app.GridLayout57.Layout.Column = 1;

            % Create SampleSliderLabel
            app.SampleSliderLabel = uilabel(app.GridLayout57);
            app.SampleSliderLabel.Layout.Row = 1;
            app.SampleSliderLabel.Layout.Column = [1 2];
            app.SampleSliderLabel.Text = 'Sample #';

            % Create SampleSlider
            app.SampleSlider = uislider(app.GridLayout57);
            app.SampleSlider.MajorTicks = [];
            app.SampleSlider.ValueChangedFcn = createCallbackFcn(app, @SampleSliderValueChanged, true);
            app.SampleSlider.MinorTicks = [];
            app.SampleSlider.Layout.Row = 2;
            app.SampleSlider.Layout.Column = 2;
            app.SampleSlider.Value = 73.1495880531358;

            % Create SampleSliderLeft
            app.SampleSliderLeft = uibutton(app.GridLayout57, 'push');
            app.SampleSliderLeft.ButtonPushedFcn = createCallbackFcn(app, @SampleSliderLeftButtonPushed, true);
            app.SampleSliderLeft.Layout.Row = 2;
            app.SampleSliderLeft.Layout.Column = 1;
            app.SampleSliderLeft.Text = '<';

            % Create SampleSliderRight
            app.SampleSliderRight = uibutton(app.GridLayout57, 'push');
            app.SampleSliderRight.ButtonPushedFcn = createCallbackFcn(app, @SampleSliderRightButtonPushed, true);
            app.SampleSliderRight.Layout.Row = 2;
            app.SampleSliderRight.Layout.Column = 3;
            app.SampleSliderRight.Text = '>';

            % Create SampleLabel
            app.SampleLabel = uilabel(app.GridLayout57);
            app.SampleLabel.Layout.Row = 1;
            app.SampleLabel.Layout.Column = 3;
            app.SampleLabel.Text = '';

            % Create GridLayout58
            app.GridLayout58 = uigridlayout(app.GridLayout37);
            app.GridLayout58.ColumnWidth = {'1x'};
            app.GridLayout58.ColumnSpacing = 0;
            app.GridLayout58.RowSpacing = 0;
            app.GridLayout58.Padding = [0 0 0 0];
            app.GridLayout58.Layout.Row = 10;
            app.GridLayout58.Layout.Column = 2;

            % Create DataSampleUseCheckBox
            app.DataSampleUseCheckBox = uicheckbox(app.GridLayout58);
            app.DataSampleUseCheckBox.ValueChangedFcn = createCallbackFcn(app, @DataSampleUseCheckBoxValueChanged, true);
            app.DataSampleUseCheckBox.Text = '';
            app.DataSampleUseCheckBox.Layout.Row = 2;
            app.DataSampleUseCheckBox.Layout.Column = 1;

            % Create ReadPVListTextAreaLabel
            app.ReadPVListTextAreaLabel = uilabel(app.GridLayout37);
            app.ReadPVListTextAreaLabel.Layout.Row = 1;
            app.ReadPVListTextAreaLabel.Layout.Column = 1;
            app.ReadPVListTextAreaLabel.Text = 'Read PV List';

            % Create ReadPVListTextArea
            app.ReadPVListTextArea = uitextarea(app.GridLayout37);
            app.ReadPVListTextArea.ValueChangedFcn = createCallbackFcn(app, @ReadPVListTextAreaValueChanged, true);
            app.ReadPVListTextArea.Layout.Row = [2 5];
            app.ReadPVListTextArea.Layout.Column = 1;

            % Create ControlPVCheckBox
            app.ControlPVCheckBox = uicheckbox(app.GridLayout37);
            app.ControlPVCheckBox.ValueChangedFcn = createCallbackFcn(app, @ControlPVCheckBoxValueChanged, true);
            app.ControlPVCheckBox.Text = '';
            app.ControlPVCheckBox.Layout.Row = 7;
            app.ControlPVCheckBox.Layout.Column = 2;

            % Create GridLayout41
            app.GridLayout41 = uigridlayout(app.GridLayout4);
            app.GridLayout41.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.GridLayout41.RowHeight = {'1x', '1x', '1x', '1x', '0.5x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout41.ColumnSpacing = 5;
            app.GridLayout41.RowSpacing = 5;
            app.GridLayout41.Padding = [0 0 0 0];
            app.GridLayout41.Layout.Row = 2;
            app.GridLayout41.Layout.Column = 2;

            % Create UAxisDropDownLabel
            app.UAxisDropDownLabel = uilabel(app.GridLayout41);
            app.UAxisDropDownLabel.Layout.Row = 17;
            app.UAxisDropDownLabel.Layout.Column = 1;
            app.UAxisDropDownLabel.Text = 'U Axis';

            % Create UAxisDropDown
            app.UAxisDropDown = uidropdown(app.GridLayout41);
            app.UAxisDropDown.Items = {};
            app.UAxisDropDown.ValueChangedFcn = createCallbackFcn(app, @UAxisDropDownValueChanged, true);
            app.UAxisDropDown.Layout.Row = 18;
            app.UAxisDropDown.Layout.Column = [1 4];
            app.UAxisDropDown.Value = {};

            % Create XAxisDropDownLabel
            app.XAxisDropDownLabel = uilabel(app.GridLayout41);
            app.XAxisDropDownLabel.Layout.Row = 15;
            app.XAxisDropDownLabel.Layout.Column = 1;
            app.XAxisDropDownLabel.Text = 'X Axis';

            % Create XAxisDropDown
            app.XAxisDropDown = uidropdown(app.GridLayout41);
            app.XAxisDropDown.Items = {};
            app.XAxisDropDown.ValueChangedFcn = createCallbackFcn(app, @XAxisDropDownValueChanged, true);
            app.XAxisDropDown.Layout.Row = 16;
            app.XAxisDropDown.Layout.Column = [1 4];
            app.XAxisDropDown.Value = {};

            % Create showLogXCheckBox
            app.showLogXCheckBox = uicheckbox(app.GridLayout41);
            app.showLogXCheckBox.ValueChangedFcn = createCallbackFcn(app, @showLogXCheckBoxValueChanged, true);
            app.showLogXCheckBox.Text = 'Log Scale';
            app.showLogXCheckBox.Layout.Row = 15;
            app.showLogXCheckBox.Layout.Column = [3 4];

            % Create YAxisListBoxLabel
            app.YAxisListBoxLabel = uilabel(app.GridLayout41);
            app.YAxisListBoxLabel.Layout.Row = 10;
            app.YAxisListBoxLabel.Layout.Column = 1;
            app.YAxisListBoxLabel.Text = 'Y Axis';

            % Create YAxisListBox
            app.YAxisListBox = uilistbox(app.GridLayout41);
            app.YAxisListBox.Items = {};
            app.YAxisListBox.Multiselect = 'on';
            app.YAxisListBox.ValueChangedFcn = createCallbackFcn(app, @YAxisListBoxValueChanged, true);
            app.YAxisListBox.Layout.Row = [11 14];
            app.YAxisListBox.Layout.Column = [1 4];
            app.YAxisListBox.Value = {};

            % Create showLogYCheckBox
            app.showLogYCheckBox = uicheckbox(app.GridLayout41);
            app.showLogYCheckBox.ValueChangedFcn = createCallbackFcn(app, @showLogYCheckBoxValueChanged, true);
            app.showLogYCheckBox.Text = 'Log Scale';
            app.showLogYCheckBox.Layout.Row = 10;
            app.showLogYCheckBox.Layout.Column = [3 4];

            % Create PlotHeaderEditFieldLabel
            app.PlotHeaderEditFieldLabel = uilabel(app.GridLayout41);
            app.PlotHeaderEditFieldLabel.HorizontalAlignment = 'right';
            app.PlotHeaderEditFieldLabel.Layout.Row = 6;
            app.PlotHeaderEditFieldLabel.Layout.Column = [1 2];
            app.PlotHeaderEditFieldLabel.Text = 'Plot Header';

            % Create PlotHeaderEditField
            app.PlotHeaderEditField = uieditfield(app.GridLayout41, 'text');
            app.PlotHeaderEditField.ValueChangedFcn = createCallbackFcn(app, @PlotHeaderEditFieldValueChanged, true);
            app.PlotHeaderEditField.HorizontalAlignment = 'right';
            app.PlotHeaderEditField.Layout.Row = 6;
            app.PlotHeaderEditField.Layout.Column = [3 4];
            app.PlotHeaderEditField.Value = 'Correlation Plot';

            % Create FormulaTextAreaLabel
            app.FormulaTextAreaLabel = uilabel(app.GridLayout41);
            app.FormulaTextAreaLabel.VerticalAlignment = 'bottom';
            app.FormulaTextAreaLabel.Layout.Row = 7;
            app.FormulaTextAreaLabel.Layout.Column = 1;
            app.FormulaTextAreaLabel.Text = 'Formula';

            % Create FormulaTextArea
            app.FormulaTextArea = uitextarea(app.GridLayout41);
            app.FormulaTextArea.ValueChangedFcn = createCallbackFcn(app, @FormulaTextAreaValueChanged, true);
            app.FormulaTextArea.Layout.Row = [8 9];
            app.FormulaTextArea.Layout.Column = [1 4];

            % Create wireDropDownLabel
            app.wireDropDownLabel = uilabel(app.GridLayout41);
            app.wireDropDownLabel.VerticalAlignment = 'bottom';
            app.wireDropDownLabel.Layout.Row = 1;
            app.wireDropDownLabel.Layout.Column = [1 2];
            app.wireDropDownLabel.Text = 'Wire Scanner';

            % Create wireDropDown
            app.wireDropDown = uidropdown(app.GridLayout41);
            app.wireDropDown.Items = {};
            app.wireDropDown.ValueChangedFcn = createCallbackFcn(app, @wireDropDownValueChanged, true);
            app.wireDropDown.Layout.Row = 2;
            app.wireDropDown.Layout.Column = [1 2];
            app.wireDropDown.Value = {};

            % Create blenDropDownLabel
            app.blenDropDownLabel = uilabel(app.GridLayout41);
            app.blenDropDownLabel.HorizontalAlignment = 'right';
            app.blenDropDownLabel.VerticalAlignment = 'bottom';
            app.blenDropDownLabel.Layout.Row = 1;
            app.blenDropDownLabel.Layout.Column = [3 4];
            app.blenDropDownLabel.Text = 'Bunch Length';

            % Create blenDropDown
            app.blenDropDown = uidropdown(app.GridLayout41);
            app.blenDropDown.Items = {};
            app.blenDropDown.ValueChangedFcn = createCallbackFcn(app, @blenDropDownValueChanged, true);
            app.blenDropDown.Layout.Row = 2;
            app.blenDropDown.Layout.Column = [3 4];
            app.blenDropDown.Value = {};

            % Create emitDropDownLabel
            app.emitDropDownLabel = uilabel(app.GridLayout41);
            app.emitDropDownLabel.VerticalAlignment = 'bottom';
            app.emitDropDownLabel.Layout.Row = 3;
            app.emitDropDownLabel.Layout.Column = [1 2];
            app.emitDropDownLabel.Text = 'Emittance Scan';

            % Create emitDropDown
            app.emitDropDown = uidropdown(app.GridLayout41);
            app.emitDropDown.Items = {};
            app.emitDropDown.ValueChangedFcn = createCallbackFcn(app, @emitDropDownValueChanged, true);
            app.emitDropDown.Layout.Row = 4;
            app.emitDropDown.Layout.Column = [1 2];
            app.emitDropDown.Value = {};

            % Create wirePlaneButtons
            app.wirePlaneButtons = uibuttongroup(app.GridLayout41);
            app.wirePlaneButtons.AutoResizeChildren = 'off';
            app.wirePlaneButtons.SelectionChangedFcn = createCallbackFcn(app, @wirePlaneButtonsSelectionChanged, true);
            app.wirePlaneButtons.BorderType = 'none';
            app.wirePlaneButtons.Layout.Row = [3 4];
            app.wirePlaneButtons.Layout.Column = 4;

            % Create x
            app.x = uiradiobutton(app.wirePlaneButtons);
            app.x.Text = 'x';
            app.x.Position = [4 17 65 22];
            app.x.Value = true;

            % Create y
            app.y = uiradiobutton(app.wirePlaneButtons);
            app.y.Text = 'y';
            app.y.Position = [3 -4 65 22];

            % Create emitTypeButtons
            app.emitTypeButtons = uibuttongroup(app.GridLayout41);
            app.emitTypeButtons.AutoResizeChildren = 'off';
            app.emitTypeButtons.SelectionChangedFcn = createCallbackFcn(app, @emitTypeButtonsSelectionChanged, true);
            app.emitTypeButtons.BorderType = 'none';
            app.emitTypeButtons.Layout.Row = [3 4];
            app.emitTypeButtons.Layout.Column = 3;

            % Create Multi
            app.Multi = uiradiobutton(app.emitTypeButtons);
            app.Multi.Text = 'Multi';
            app.Multi.Position = [4 17 65 22];

            % Create Quad
            app.Quad = uiradiobutton(app.emitTypeButtons);
            app.Quad.Text = 'Quad';
            app.Quad.Position = [3 -4 65 22];
            app.Quad.Value = true;

            % Create Status
            app.Status = uilabel(app.GridLayout4);
            app.Status.VerticalAlignment = 'top';
            app.Status.Layout.Row = 3;
            app.Status.Layout.Column = [1 2];
            app.Status.Text = '';

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.GridLayout);
            app.GridLayout5.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '0.8x'};
            app.GridLayout5.RowHeight = {'0.25x', '0.25x', '0.25x', '0.25x', '0.25x', '0.25x', '0.5x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout5.RowSpacing = 5;
            app.GridLayout5.Layout.Row = [3 5];
            app.GridLayout5.Layout.Column = 2;

            % Create StartButton
            app.StartButton = uibutton(app.GridLayout5, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.BackgroundColor = [0 1 0];
            app.StartButton.FontWeight = 'bold';
            app.StartButton.Layout.Row = [1 2];
            app.StartButton.Layout.Column = 1;
            app.StartButton.Text = 'Start Scan';

            % Create AbortButton
            app.AbortButton = uibutton(app.GridLayout5, 'push');
            app.AbortButton.ButtonPushedFcn = createCallbackFcn(app, @AbortButtonPushed, true);
            app.AbortButton.BackgroundColor = [1 0.2 0];
            app.AbortButton.FontWeight = 'bold';
            app.AbortButton.Layout.Row = [3 4];
            app.AbortButton.Layout.Column = 1;
            app.AbortButton.Text = 'Abort Scan';

            % Create GetDataButton
            app.GetDataButton = uibutton(app.GridLayout5, 'push');
            app.GetDataButton.ButtonPushedFcn = createCallbackFcn(app, @GetDataButtonPushed, true);
            app.GetDataButton.Layout.Row = [5 6];
            app.GetDataButton.Layout.Column = 1;
            app.GetDataButton.Text = 'Get Data';

            % Create LogbookButton
            app.LogbookButton = uibutton(app.GridLayout5, 'push');
            app.LogbookButton.ButtonPushedFcn = createCallbackFcn(app, @LogbookButtonPushed, true);
            app.LogbookButton.BackgroundColor = [0 1 1];
            app.LogbookButton.Layout.Row = [1 2];
            app.LogbookButton.Layout.Column = 2;
            app.LogbookButton.Text = 'Logbook';

            % Create ExportButton
            app.ExportButton = uibutton(app.GridLayout5, 'push');
            app.ExportButton.ButtonPushedFcn = createCallbackFcn(app, @ExportButtonPushed, true);
            app.ExportButton.Layout.Row = [3 4];
            app.ExportButton.Layout.Column = 2;
            app.ExportButton.Text = 'Export';

            % Create DispDataButton
            app.DispDataButton = uibutton(app.GridLayout5, 'push');
            app.DispDataButton.ButtonPushedFcn = createCallbackFcn(app, @DispDataButtonPushed, true);
            app.DispDataButton.Layout.Row = [5 6];
            app.DispDataButton.Layout.Column = 2;
            app.DispDataButton.Text = 'Disp Data';

            % Create SaveButton
            app.SaveButton = uibutton(app.GridLayout5, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.Layout.Row = [1 2];
            app.SaveButton.Layout.Column = 3;
            app.SaveButton.Text = 'Save';

            % Create SaveAsButton
            app.SaveAsButton = uibutton(app.GridLayout5, 'push');
            app.SaveAsButton.ButtonPushedFcn = createCallbackFcn(app, @SaveAsButtonPushed, true);
            app.SaveAsButton.Layout.Row = [3 4];
            app.SaveAsButton.Layout.Column = 3;
            app.SaveAsButton.Text = 'Save As...';

            % Create LoadButton
            app.LoadButton = uibutton(app.GridLayout5, 'push');
            app.LoadButton.ButtonPushedFcn = createCallbackFcn(app, @LoadButtonPushed, true);
            app.LoadButton.Layout.Row = [5 6];
            app.LoadButton.Layout.Column = 3;
            app.LoadButton.Text = 'Load...';

            % Create LoadConfigButton
            app.LoadConfigButton = uibutton(app.GridLayout5, 'push');
            app.LoadConfigButton.ButtonPushedFcn = createCallbackFcn(app, @LoadConfigButtonPushed, true);
            app.LoadConfigButton.Layout.Row = [1 2];
            app.LoadConfigButton.Layout.Column = 4;
            app.LoadConfigButton.Text = 'Load Config...';

            % Create ImgProcessButton
            app.ImgProcessButton = uibutton(app.GridLayout5, 'push');
            app.ImgProcessButton.ButtonPushedFcn = createCallbackFcn(app, @ImgProcessButtonPushed, true);
            app.ImgProcessButton.Layout.Row = [1 2];
            app.ImgProcessButton.Layout.Column = 5;
            app.ImgProcessButton.Text = 'Img Process';

            % Create SaveConfigButton
            app.SaveConfigButton = uibutton(app.GridLayout5, 'push');
            app.SaveConfigButton.ButtonPushedFcn = createCallbackFcn(app, @SaveConfigButtonPushed, true);
            app.SaveConfigButton.Layout.Row = [3 4];
            app.SaveConfigButton.Layout.Column = 4;
            app.SaveConfigButton.Text = 'Save Config...';

            % Create PlotData_ax
            app.PlotData_ax = uiaxes(app.GridLayout5);
            title(app.PlotData_ax, '')
            xlabel(app.PlotData_ax, '')
            ylabel(app.PlotData_ax, '')
            app.PlotData_ax.FontSize = 14;
            app.PlotData_ax.XGrid = 'on';
            app.PlotData_ax.YGrid = 'on';
            app.PlotData_ax.Layout.Row = [16 22];
            app.PlotData_ax.Layout.Column = [1 6];

            % Create PlotProf_ax
            app.PlotProf_ax = uiaxes(app.GridLayout5);
            title(app.PlotProf_ax, '')
            xlabel(app.PlotProf_ax, '')
            ylabel(app.PlotProf_ax, '')
            app.PlotProf_ax.FontSize = 14;
            app.PlotProf_ax.XGrid = 'on';
            app.PlotProf_ax.YGrid = 'on';
            app.PlotProf_ax.Layout.Row = [8 14];
            app.PlotProf_ax.Layout.Column = [1 6];

            % Create GridLayout9
            app.GridLayout9 = uigridlayout(app.GridLayout5);
            app.GridLayout9.RowHeight = {'1x'};
            app.GridLayout9.ColumnSpacing = 1;
            app.GridLayout9.RowSpacing = 1;
            app.GridLayout9.Padding = [0 0 0 0];
            app.GridLayout9.Layout.Row = [3 4];
            app.GridLayout9.Layout.Column = 6;

            % Create YSigEditFieldLabel
            app.YSigEditFieldLabel = uilabel(app.GridLayout9);
            app.YSigEditFieldLabel.HorizontalAlignment = 'center';
            app.YSigEditFieldLabel.Layout.Row = 1;
            app.YSigEditFieldLabel.Layout.Column = 1;
            app.YSigEditFieldLabel.Text = 'Y Sig';

            % Create YSigEditField
            app.YSigEditField = uieditfield(app.GridLayout9, 'numeric');
            app.YSigEditField.ValueChangedFcn = createCallbackFcn(app, @YSigEditFieldValueChanged, true);
            app.YSigEditField.Layout.Row = 1;
            app.YSigEditField.Layout.Column = 2;
            app.YSigEditField.Value = 4.6;

            % Create GridLayout10
            app.GridLayout10 = uigridlayout(app.GridLayout5);
            app.GridLayout10.RowHeight = {'1x'};
            app.GridLayout10.ColumnSpacing = 1;
            app.GridLayout10.RowSpacing = 1;
            app.GridLayout10.Padding = [0 0 0 0];
            app.GridLayout10.Layout.Row = [1 2];
            app.GridLayout10.Layout.Column = 6;

            % Create XSigEditFieldLabel
            app.XSigEditFieldLabel = uilabel(app.GridLayout10);
            app.XSigEditFieldLabel.HorizontalAlignment = 'center';
            app.XSigEditFieldLabel.Layout.Row = 1;
            app.XSigEditFieldLabel.Layout.Column = 1;
            app.XSigEditFieldLabel.Text = 'X Sig';

            % Create XSigEditField
            app.XSigEditField = uieditfield(app.GridLayout10, 'numeric');
            app.XSigEditField.ValueChangedFcn = createCallbackFcn(app, @XSigEditFieldValueChanged, true);
            app.XSigEditField.Layout.Row = 1;
            app.XSigEditField.Layout.Column = 2;
            app.XSigEditField.Value = 4.6;

            % Create SaveImagesCheckBox
            app.SaveImagesCheckBox = uicheckbox(app.GridLayout5);
            app.SaveImagesCheckBox.ValueChangedFcn = createCallbackFcn(app, @SaveImagesCheckBoxValueChanged, true);
            app.SaveImagesCheckBox.Text = 'Save Images';
            app.SaveImagesCheckBox.Layout.Row = 6;
            app.SaveImagesCheckBox.Layout.Column = 4;

            % Create HoldImagesCheckBox
            app.HoldImagesCheckBox = uicheckbox(app.GridLayout5);
            app.HoldImagesCheckBox.ValueChangedFcn = createCallbackFcn(app, @HoldImagesCheckBoxValueChanged, true);
            app.HoldImagesCheckBox.Text = 'Hold Images';
            app.HoldImagesCheckBox.Layout.Row = 5;
            app.HoldImagesCheckBox.Layout.Column = 4;
            app.HoldImagesCheckBox.Value = true;

            % Create ImgautoscaleCheckBox
            app.ImgautoscaleCheckBox = uicheckbox(app.GridLayout5);
            app.ImgautoscaleCheckBox.ValueChangedFcn = createCallbackFcn(app, @ImgautoscaleCheckBoxValueChanged, true);
            app.ImgautoscaleCheckBox.Text = 'Img autoscale';
            app.ImgautoscaleCheckBox.Layout.Row = 6;
            app.ImgautoscaleCheckBox.Layout.Column = [5 6];

            % Create ShowImagesCheckBox
            app.ShowImagesCheckBox = uicheckbox(app.GridLayout5);
            app.ShowImagesCheckBox.ValueChangedFcn = createCallbackFcn(app, @ShowImagesCheckBoxValueChanged, true);
            app.ShowImagesCheckBox.Text = 'Show Images';
            app.ShowImagesCheckBox.Layout.Row = 5;
            app.ShowImagesCheckBox.Layout.Column = [5 6];

            % Create ProcCheckBox
            app.ProcCheckBox = uicheckbox(app.GridLayout5);
            app.ProcCheckBox.ValueChangedFcn = createCallbackFcn(app, @ProcCheckBoxValueChanged, true);
            app.ProcCheckBox.Text = 'Proc';
            app.ProcCheckBox.Layout.Row = 4;
            app.ProcCheckBox.Layout.Column = 5;
            app.ProcCheckBox.Value = true;

            % Create CropCheckBox
            app.CropCheckBox = uicheckbox(app.GridLayout5);
            app.CropCheckBox.ValueChangedFcn = createCallbackFcn(app, @CropCheckBoxValueChanged, true);
            app.CropCheckBox.Text = 'Crop';
            app.CropCheckBox.Layout.Row = 3;
            app.CropCheckBox.Layout.Column = 5;
            app.CropCheckBox.Value = true;

            % Create GridLayout63
            app.GridLayout63 = uigridlayout(app.GridLayout5);
            app.GridLayout63.ColumnWidth = {'1x'};
            app.GridLayout63.ColumnSpacing = 0;
            app.GridLayout63.RowSpacing = 0;
            app.GridLayout63.Padding = [0 0 0 0];
            app.GridLayout63.Layout.Row = 15;
            app.GridLayout63.Layout.Column = 6;

            % Create PlotGridCheckBox
            app.PlotGridCheckBox = uicheckbox(app.GridLayout63);
            app.PlotGridCheckBox.ValueChangedFcn = createCallbackFcn(app, @PlotGridCheckBoxValueChanged, true);
            app.PlotGridCheckBox.Text = 'Grid';
            app.PlotGridCheckBox.Layout.Row = 2;
            app.PlotGridCheckBox.Layout.Column = 1;
            app.PlotGridCheckBox.Value = true;

            % Create ProfGridCheckBox
            app.ProfGridCheckBox = uicheckbox(app.GridLayout5);
            app.ProfGridCheckBox.ValueChangedFcn = createCallbackFcn(app, @ProfGridCheckBoxValueChanged, true);
            app.ProfGridCheckBox.Text = 'Grid';
            app.ProfGridCheckBox.Layout.Row = 7;
            app.ProfGridCheckBox.Layout.Column = 6;
            app.ProfGridCheckBox.Value = true;

            % Create GridLayout17
            app.GridLayout17 = uigridlayout(app.GridLayout);
            app.GridLayout17.ColumnWidth = {'1x'};
            app.GridLayout17.RowHeight = {'0.05x', '1x'};
            app.GridLayout17.ColumnSpacing = 0;
            app.GridLayout17.RowSpacing = 0;
            app.GridLayout17.Padding = [0 0 0 0];
            app.GridLayout17.Layout.Row = 3;
            app.GridLayout17.Layout.Column = 3;

            % Create ProfileMonitorListBoxLabel
            app.ProfileMonitorListBoxLabel = uilabel(app.GridLayout17);
            app.ProfileMonitorListBoxLabel.HorizontalAlignment = 'center';
            app.ProfileMonitorListBoxLabel.VerticalAlignment = 'bottom';
            app.ProfileMonitorListBoxLabel.Visible = 'off';
            app.ProfileMonitorListBoxLabel.Layout.Row = 1;
            app.ProfileMonitorListBoxLabel.Layout.Column = 1;
            app.ProfileMonitorListBoxLabel.Text = {'Profile Monitor'; ''};

            % Create ProfmonListBox
            app.ProfmonListBox = uilistbox(app.GridLayout17);
            app.ProfmonListBox.Items = {'', ''};
            app.ProfmonListBox.Multiselect = 'on';
            app.ProfmonListBox.Visible = 'off';
            app.ProfmonListBox.Layout.Row = 2;
            app.ProfmonListBox.Layout.Column = 1;
            app.ProfmonListBox.Value = {''};

            % Create GridLayout59
            app.GridLayout59 = uigridlayout(app.GridLayout);
            app.GridLayout59.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout59.ColumnSpacing = 15;
            app.GridLayout59.RowSpacing = 5;
            app.GridLayout59.Padding = [0 0 0 0];
            app.GridLayout59.Layout.Row = 2;
            app.GridLayout59.Layout.Column = 1;

            % Create MultiknobFileEditFieldLabel
            app.MultiknobFileEditFieldLabel = uilabel(app.GridLayout59);
            app.MultiknobFileEditFieldLabel.VerticalAlignment = 'bottom';
            app.MultiknobFileEditFieldLabel.Layout.Row = 1;
            app.MultiknobFileEditFieldLabel.Layout.Column = [2 3];
            app.MultiknobFileEditFieldLabel.Text = 'Multiknob File';

            % Create MultiknobFileEditField
            app.MultiknobFileEditField = uieditfield(app.GridLayout59, 'text');
            app.MultiknobFileEditField.ValueChangedFcn = createCallbackFcn(app, @MultiknobFileEditFieldValueChanged, true);
            app.MultiknobFileEditField.Layout.Row = 2;
            app.MultiknobFileEditField.Layout.Column = [2 3];

            % Create GridLayout60
            app.GridLayout60 = uigridlayout(app.GridLayout59);
            app.GridLayout60.ColumnWidth = {'1x'};
            app.GridLayout60.RowHeight = {'1x'};
            app.GridLayout60.ColumnSpacing = 0;
            app.GridLayout60.RowSpacing = 0;
            app.GridLayout60.Padding = [0 0 0 0];
            app.GridLayout60.Layout.Row = 2;
            app.GridLayout60.Layout.Column = 1;

            % Create UseLEMCheckBox
            app.UseLEMCheckBox = uicheckbox(app.GridLayout60);
            app.UseLEMCheckBox.ValueChangedFcn = createCallbackFcn(app, @UseLEMCheckBoxValueChanged, true);
            app.UseLEMCheckBox.Text = 'Use LEM';
            app.UseLEMCheckBox.Layout.Row = 1;
            app.UseLEMCheckBox.Layout.Column = 1;

            % Create GridLayout62
            app.GridLayout62 = uigridlayout(app.GridLayout59);
            app.GridLayout62.ColumnWidth = {'1x'};
            app.GridLayout62.RowHeight = {'1x'};
            app.GridLayout62.ColumnSpacing = 0;
            app.GridLayout62.RowSpacing = 0;
            app.GridLayout62.Padding = [0 0 0 0];
            app.GridLayout62.Layout.Row = 1;
            app.GridLayout62.Layout.Column = 1;

            % Create PrescanButton
            app.PrescanButton = uibutton(app.GridLayout62, 'push');
            app.PrescanButton.Visible = 'off';
            app.PrescanButton.Layout.Row = 1;
            app.PrescanButton.Layout.Column = 1;
            app.PrescanButton.Text = 'Prescan';

            % Create PausePVEditFieldLabel
            app.PausePVEditFieldLabel = uilabel(app.GridLayout59);
            app.PausePVEditFieldLabel.VerticalAlignment = 'bottom';
            app.PausePVEditFieldLabel.Layout.Row = 1;
            app.PausePVEditFieldLabel.Layout.Column = [4 5];
            app.PausePVEditFieldLabel.Text = 'Pause PV';

            % Create PausePVEditField
            app.PausePVEditField = uieditfield(app.GridLayout59, 'text');
            app.PausePVEditField.ValueChangedFcn = createCallbackFcn(app, @PausePVEditFieldValueChanged, true);
            app.PausePVEditField.Layout.Row = 2;
            app.PausePVEditField.Layout.Column = [4 5];

            % Create BeamPath
            app.BeamPath = uibuttongroup(app.GridLayout);
            app.BeamPath.AutoResizeChildren = 'off';
            app.BeamPath.SelectionChangedFcn = createCallbackFcn(app, @BeamPathSelectionChanged, true);
            app.BeamPath.BorderType = 'none';
            app.BeamPath.Layout.Row = 2;
            app.BeamPath.Layout.Column = 2;

            % Create BeamPathButton1
            app.BeamPathButton1 = uitogglebutton(app.BeamPath);
            app.BeamPathButton1.Enable = 'off';
            app.BeamPathButton1.Visible = 'off';
            app.BeamPathButton1.Text = {''; ''};
            app.BeamPathButton1.Position = [16 15 100 22];
            app.BeamPathButton1.Value = true;

            % Create BeamPathButton2
            app.BeamPathButton2 = uitogglebutton(app.BeamPath);
            app.BeamPathButton2.Enable = 'off';
            app.BeamPathButton2.Visible = 'off';
            app.BeamPathButton2.Text = '';
            app.BeamPathButton2.Position = [115 15 100 22];

            % Create BeamPathButton3
            app.BeamPathButton3 = uitogglebutton(app.BeamPath);
            app.BeamPathButton3.Enable = 'off';
            app.BeamPathButton3.Visible = 'off';
            app.BeamPathButton3.Text = '';
            app.BeamPathButton3.Position = [214 15 100 22];

            % Create BeamPathButton4
            app.BeamPathButton4 = uitogglebutton(app.BeamPath);
            app.BeamPathButton4.Enable = 'off';
            app.BeamPathButton4.Visible = 'off';
            app.BeamPathButton4.Text = '';
            app.BeamPathButton4.Position = [313 15 100 22];

            % Create GridLayout61
            app.GridLayout61 = uigridlayout(app.GridLayout);
            app.GridLayout61.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout61.RowHeight = {'0.5x', '1x', '1x', '1x', '0.5x'};
            app.GridLayout61.ColumnSpacing = 1;
            app.GridLayout61.RowSpacing = 1;
            app.GridLayout61.Layout.Row = 6;
            app.GridLayout61.Layout.Column = 2;

            % Create XLABELLabel
            app.XLABELLabel = uilabel(app.GridLayout61);
            app.XLABELLabel.HorizontalAlignment = 'center';
            app.XLABELLabel.Layout.Row = 2;
            app.XLABELLabel.Layout.Column = 2;
            app.XLABELLabel.Text = 'X LABEL';

            % Create YLABELLabel
            app.YLABELLabel = uilabel(app.GridLayout61);
            app.YLABELLabel.HorizontalAlignment = 'center';
            app.YLABELLabel.Layout.Row = 3;
            app.YLABELLabel.Layout.Column = 2;
            app.YLABELLabel.Text = 'Y LABEL';

            % Create XNAMECheckBox
            app.XNAMECheckBox = uicheckbox(app.GridLayout61);
            app.XNAMECheckBox.ValueChangedFcn = createCallbackFcn(app, @PlotLabelCheckBoxValueChanged, true);
            app.XNAMECheckBox.Text = 'NAME';
            app.XNAMECheckBox.Layout.Row = 2;
            app.XNAMECheckBox.Layout.Column = 3;
            app.XNAMECheckBox.Value = true;

            % Create YNAMECheckBox
            app.YNAMECheckBox = uicheckbox(app.GridLayout61);
            app.YNAMECheckBox.ValueChangedFcn = createCallbackFcn(app, @PlotLabelCheckBoxValueChanged, true);
            app.YNAMECheckBox.Text = 'NAME';
            app.YNAMECheckBox.Layout.Row = 3;
            app.YNAMECheckBox.Layout.Column = 3;
            app.YNAMECheckBox.Value = true;

            % Create XDESCCheckBox
            app.XDESCCheckBox = uicheckbox(app.GridLayout61);
            app.XDESCCheckBox.ValueChangedFcn = createCallbackFcn(app, @PlotLabelCheckBoxValueChanged, true);
            app.XDESCCheckBox.Text = 'DESC';
            app.XDESCCheckBox.Layout.Row = 2;
            app.XDESCCheckBox.Layout.Column = 4;
            app.XDESCCheckBox.Value = true;

            % Create YDESCCheckBox
            app.YDESCCheckBox = uicheckbox(app.GridLayout61);
            app.YDESCCheckBox.ValueChangedFcn = createCallbackFcn(app, @PlotLabelCheckBoxValueChanged, true);
            app.YDESCCheckBox.Text = 'DESC';
            app.YDESCCheckBox.Layout.Row = 3;
            app.YDESCCheckBox.Layout.Column = 4;
            app.YDESCCheckBox.Value = true;

            % Create XEGUCheckBox
            app.XEGUCheckBox = uicheckbox(app.GridLayout61);
            app.XEGUCheckBox.ValueChangedFcn = createCallbackFcn(app, @PlotLabelCheckBoxValueChanged, true);
            app.XEGUCheckBox.Text = 'EGU';
            app.XEGUCheckBox.Layout.Row = 2;
            app.XEGUCheckBox.Layout.Column = 5;
            app.XEGUCheckBox.Value = true;

            % Create YEGUCheckBox
            app.YEGUCheckBox = uicheckbox(app.GridLayout61);
            app.YEGUCheckBox.ValueChangedFcn = createCallbackFcn(app, @PlotLabelCheckBoxValueChanged, true);
            app.YEGUCheckBox.Text = 'EGU';
            app.YEGUCheckBox.Layout.Row = 3;
            app.YEGUCheckBox.Layout.Column = 5;
            app.YEGUCheckBox.Value = true;

            % Create ULABELLabel
            app.ULABELLabel = uilabel(app.GridLayout61);
            app.ULABELLabel.HorizontalAlignment = 'center';
            app.ULABELLabel.Layout.Row = 4;
            app.ULABELLabel.Layout.Column = 2;
            app.ULABELLabel.Text = 'U LABEL';

            % Create UNAMECheckBox
            app.UNAMECheckBox = uicheckbox(app.GridLayout61);
            app.UNAMECheckBox.ValueChangedFcn = createCallbackFcn(app, @PlotLabelCheckBoxValueChanged, true);
            app.UNAMECheckBox.Text = 'NAME';
            app.UNAMECheckBox.Layout.Row = 4;
            app.UNAMECheckBox.Layout.Column = 3;
            app.UNAMECheckBox.Value = true;

            % Create UDESCCheckBox
            app.UDESCCheckBox = uicheckbox(app.GridLayout61);
            app.UDESCCheckBox.ValueChangedFcn = createCallbackFcn(app, @PlotLabelCheckBoxValueChanged, true);
            app.UDESCCheckBox.Text = 'DESC';
            app.UDESCCheckBox.Layout.Row = 4;
            app.UDESCCheckBox.Layout.Column = 4;
            app.UDESCCheckBox.Value = true;

            % Create UEGUCheckBox
            app.UEGUCheckBox = uicheckbox(app.GridLayout61);
            app.UEGUCheckBox.ValueChangedFcn = createCallbackFcn(app, @PlotLabelCheckBoxValueChanged, true);
            app.UEGUCheckBox.Text = 'EGU';
            app.UEGUCheckBox.Layout.Row = 4;
            app.UEGUCheckBox.Layout.Column = 5;
            app.UEGUCheckBox.Value = true;

            % Create CorrelationPlotLabel
            app.CorrelationPlotLabel = uilabel(app.GridLayout);
            app.CorrelationPlotLabel.HorizontalAlignment = 'center';
            app.CorrelationPlotLabel.VerticalAlignment = 'top';
            app.CorrelationPlotLabel.FontSize = 24;
            app.CorrelationPlotLabel.FontWeight = 'bold';
            app.CorrelationPlotLabel.FontColor = [0 0.4471 0.7412];
            app.CorrelationPlotLabel.Layout.Row = 1;
            app.CorrelationPlotLabel.Layout.Column = [1 2];
            app.CorrelationPlotLabel.Text = 'Correlation Plot';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_CorrPlot_exported

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