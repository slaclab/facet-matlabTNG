classdef F2_Orbit_exported < matlab.apps.AppBase

  % Properties that correspond to app components
  properties (Access = public)
    FACETIIOrbitToolconfignoneUIFigure  matlab.ui.Figure
    ConfigMenu                     matlab.ui.container.Menu
    SelectMenu                     matlab.ui.container.Menu
    NoneMenu                       matlab.ui.container.Menu
    SaveAsMenu                     matlab.ui.container.Menu
    SaveMenu                       matlab.ui.container.Menu
    DeleteMenu                     matlab.ui.container.Menu
    BPMsPanel                      matlab.ui.container.Panel
    ListBox                        matlab.ui.control.ListBox
    PlotallCheckBox                matlab.ui.control.CheckBox
    CorrectorsPanel                matlab.ui.container.Panel
    ListBox_2                      matlab.ui.control.ListBox
    ListBox_3                      matlab.ui.control.ListBox
    TabGroup                       matlab.ui.container.TabGroup
    OrbitTab                       matlab.ui.container.Tab
    UIAxes                         matlab.ui.control.UIAxes
    CalcCorrectionButton           matlab.ui.control.Button
    DoCorrectionButton             matlab.ui.control.Button
    USEXButton                     matlab.ui.control.StateButton
    USEYButton                     matlab.ui.control.StateButton
    UIAxes_2                       matlab.ui.control.UIAxes
    CorrectionSolverButtonGroup    matlab.ui.container.ButtonGroup
    lscovButton                    matlab.ui.control.RadioButton
    pinvButton                     matlab.ui.control.RadioButton
    lsqminnormButton               matlab.ui.control.RadioButton
    TolEditFieldLabel              matlab.ui.control.Label
    TolEditField                   matlab.ui.control.NumericEditField
    TolPlotButton                  matlab.ui.control.Button
    svdButton                      matlab.ui.control.RadioButton
    lsqlinButton                   matlab.ui.control.RadioButton
    ShowModelFitButton             matlab.ui.control.StateButton
    UndoCorrectionButton           matlab.ui.control.Button
    ModelFitButton                 matlab.ui.control.StateButton
    rmsChoose                      matlab.ui.control.StateButton
    OrbitFitPanel                  matlab.ui.container.Panel
    EditField_3                    matlab.ui.control.NumericEditField
    EditField_4                    matlab.ui.control.NumericEditField
    EditField_5                    matlab.ui.control.NumericEditField
    EditField_6                    matlab.ui.control.NumericEditField
    EditField_7                    matlab.ui.control.NumericEditField
    EditField_8                    matlab.ui.control.NumericEditField
    EditField_9                    matlab.ui.control.NumericEditField
    EditField_10                   matlab.ui.control.NumericEditField
    XmmLabel                       matlab.ui.control.Label
    XANGmmLabel                    matlab.ui.control.Label
    YmmLabel                       matlab.ui.control.Label
    YANGmmLabel                    matlab.ui.control.Label
    ACTLabel                       matlab.ui.control.Label
    DESLabel                       matlab.ui.control.Label
    ACTLabel_2                     matlab.ui.control.Label
    DESLabel_2                     matlab.ui.control.Label
    ACTLabel_3                     matlab.ui.control.Label
    DESLabel_3                     matlab.ui.control.Label
    ACTLabel_4                     matlab.ui.control.Label
    DESLabel_4                     matlab.ui.control.Label
    EditField_11                   matlab.ui.control.NumericEditField
    dEMeVLabel                     matlab.ui.control.Label
    EditField_13                   matlab.ui.control.EditField
    SelectFitLocationButton        matlab.ui.control.Button
    DropDown_5                     matlab.ui.control.DropDown
    DropDown_4                     matlab.ui.control.DropDown
    TakeNewRefButton               matlab.ui.control.Button
    ShowCors                       matlab.ui.control.StateButton
    CorrectorsTab                  matlab.ui.container.Tab
    UIAxes2                        matlab.ui.control.UIAxes
    UIAxes3                        matlab.ui.control.UIAxes
    ShowMaxButton                  matlab.ui.control.StateButton
    CorUnitsButton                 matlab.ui.control.StateButton
    DispersionTab                  matlab.ui.container.Tab
    UIAxes5                        matlab.ui.control.UIAxes
    UIAxes5_2                      matlab.ui.control.UIAxes
    DispersionFitmmmradPanel       matlab.ui.container.Panel
    EditField_14                   matlab.ui.control.NumericEditField
    EditField_16                   matlab.ui.control.NumericEditField
    EditField_18                   matlab.ui.control.NumericEditField
    EditField_20                   matlab.ui.control.NumericEditField
    DXLabel                        matlab.ui.control.Label
    EditField_23                   matlab.ui.control.EditField
    SelectFitLocationButton_2      matlab.ui.control.Button
    DropDown_6                     matlab.ui.control.DropDown
    ShowFitButton                  matlab.ui.control.StateButton
    DPXLabel                       matlab.ui.control.Label
    DYLabel                        matlab.ui.control.Label
    DPYLabel                       matlab.ui.control.Label
    DispersionCorrectionPanel      matlab.ui.container.Panel
    DoCorrectionButton_2           matlab.ui.control.Button
    ShowDevicesButton              matlab.ui.control.StateButton
    DispersionfromEnergyScanPanel  matlab.ui.container.Panel
    DoScanButton                   matlab.ui.control.Button
    DropDown_7                     matlab.ui.control.DropDown
    MinEditFieldLabel              matlab.ui.control.Label
    MinEditField                   matlab.ui.control.NumericEditField
    MaxEditFieldLabel              matlab.ui.control.Label
    MaxEditField                   matlab.ui.control.NumericEditField
    NstepEditFieldLabel            matlab.ui.control.Label
    NstepEditField                 matlab.ui.control.NumericEditField
    DispScan_minunit               matlab.ui.control.Label
    DispScan_maxunit               matlab.ui.control.Label
    MIATab                         matlab.ui.container.Tab
    UIAxes6                        matlab.ui.control.UIAxes
    PlotOptionPanel                matlab.ui.container.Panel
    DropDown_2                     matlab.ui.control.DropDown
    NmodesLabel                    matlab.ui.control.Label
    NmodesEditField                matlab.ui.control.NumericEditField
    CorrelatePanel                 matlab.ui.container.Panel
    DropDown_3                     matlab.ui.control.DropDown
    rEditFieldLabel                matlab.ui.control.Label
    rEditField                     matlab.ui.control.EditField
    pEditFieldLabel                matlab.ui.control.Label
    pEditField                     matlab.ui.control.EditField
    PlotButton                     matlab.ui.control.Button
    modeEditFieldLabel             matlab.ui.control.Label
    modeEditField                  matlab.ui.control.EditField
    UIAxes6_2                      matlab.ui.control.UIAxes
    RegionSelectPanel              matlab.ui.container.Panel
    GridLayout                     matlab.ui.container.GridLayout
    INJButton                      matlab.ui.control.StateButton
    L0Button                       matlab.ui.control.StateButton
    DL1Button                      matlab.ui.control.StateButton
    L1Button                       matlab.ui.control.StateButton
    BC11Button                     matlab.ui.control.StateButton
    L2Button                       matlab.ui.control.StateButton
    BC14Button                     matlab.ui.control.StateButton
    L3Button                       matlab.ui.control.StateButton
    BC20Button                     matlab.ui.control.StateButton
    FFSButton                      matlab.ui.control.StateButton
    SPECTButton                    matlab.ui.control.StateButton
    AcquireButton                  matlab.ui.control.Button
    NPulseEditFieldLabel           matlab.ui.control.Label
    NPulseEditField                matlab.ui.control.NumericEditField
    PlotRangeDropDownLabel         matlab.ui.control.Label
    PlotRangeDropDown              matlab.ui.control.DropDown
    NReadEditFieldLabel            matlab.ui.control.Label
    NReadEditField                 matlab.ui.control.NumericEditField
    UpdateLiveModelButton          matlab.ui.control.Button
    UseBufferedDataCheckBox        matlab.ui.control.CheckBox
    LogbookButton                  matlab.ui.control.Button
  end

  
  properties (Access = public)
    aobj % F2_OrbitApp object
    logplot logical = false % Description
  end
  
  properties (Access = private)
    escandone logical = false % Description
  end
  
  methods (Access = public)
    
    function updateplots(app)
      app.TabGroupSelectionChanged;
    end
  end
  

  % Callbacks that handle component events
  methods (Access = private)

    % Code that executes after component creation
    function startupFcn(app)
      app.aobj = F2_OrbitApp(app) ;
      app.INJButtonValueChanged(); % Populates BPM and corrector list boxes
    end

    % Value changed function: BC11Button, BC14Button, 
    % BC20Button, DL1Button, FFSButton, INJButton, L0Button, 
    % L1Button, L2Button, L3Button, SPECTButton
    function INJButtonValueChanged(app, event)
      global BEAMLINE
      value = [app.INJButton.Value app.L0Button.Value app.DL1Button.Value app.L1Button.Value ...
        app.BC11Button.Value app.L2Button.Value app.BC14Button.Value app.L3Button.Value ...
        app.BC20Button.Value app.FFSButton.Value app.SPECTButton.Value] ;
%       ele1=find(value,1);
%       if isempty(ele1)
%         value(1)=true;
%         app.INJButton.Value=true;
%       end
%       ele2=find(~value,1)-1;
%       if isempty(ele2)
%         ele2=length(value);
%       elseif ele2<ele1
%         ele2=length(value);
%       end
%       value=false(1,length(value)); value(ele1:ele2)=true;
      app.INJButton.Value=value(1);
      app.L0Button.Value=value(2);
      app.DL1Button.Value=value(3);
      app.L1Button.Value=value(4);
      app.BC11Button.Value=value(5);
      app.L2Button.Value=value(6);
      app.BC14Button.Value=value(7);
      app.L3Button.Value=value(8);
      app.BC20Button.Value=value(9);
      app.FFSButton.Value=value(10);
      app.SPECTButton.Value=value(11);
      drawnow
      app.aobj.UseRegion = value ;
      app.EditField_13.Value = BEAMLINE{app.aobj.fitele}.Name ;
      app.aobj.WriteGuiListBox(); % Update BPM/Corrector list boxes
      app.TabGroupSelectionChanged;
    end

    % Selection change function: TabGroup
    function TabGroupSelectionChanged(app, event)
      global BEAMLINE
      switch app.TabGroup.SelectedTab
        case app.OrbitTab
          app.ModelFitButton.Value=app.aobj.domodelfit;
          if ~isempty(app.aobj.BPMS.xdat) && any(~isnan(app.aobj.BPMS.xdat(:)))
            try
              [~,X1]=app.aobj.orbitfit;
            catch
              X1=nan(5,1);
              disp('Orbit fit failed');
            end
            if ~isnan(X1(1))
              app.EditField_3.Value = X1(1) ;
              app.EditField_5.Value = X1(2) ;
              app.EditField_7.Value = X1(3) ;
              app.EditField_9.Value = X1(4) ;
              app.EditField_11.Value = X1(5) * BEAMLINE{app.aobj.fitele}.P * 1000 ;
            end
            app.aobj.plotbpm([app.UIAxes app.UIAxes_2],app.ShowModelFitButton.Value,app.ShowCors.Value,app.PlotallCheckBox.Value);
          end
        case app.CorrectorsTab
          app.aobj.plotcor([app.UIAxes2 app.UIAxes3],app.ShowMaxButton.Value,app.CorUnitsButton.Value);
        case app.DispersionTab
          try
            if ~app.escandone
              if app.PlotallCheckBox.Value
                app.aobj.svddisp("all");
              end
              app.aobj.svddisp;
            else
              app.aobj.ProcEscan;
            end
            DX = app.aobj.dispfit ;
            app.EditField_14.Value = DX(1) ;
            app.EditField_16.Value = DX(2) ;
            app.EditField_18.Value = DX(3) ;
            app.EditField_20.Value = DX(4) ;
            app.aobj.plotdisp([app.UIAxes5 app.UIAxes5_2],app.ShowFitButton.Value,app.ShowDevicesButton.Value,app.PlotallCheckBox.Value) ;
          catch ME
            warning(ME.identifier,'Dispersion calc error:\n%s',ME.message);
            app.EditField_14.Value = inf ;
            app.EditField_16.Value = inf ;
            app.EditField_18.Value = inf ;
            app.EditField_20.Value = inf ;
          end
        case app.MIATab
          app.DropDown_2ValueChanged;
      end
      drawnow
    end

    % Button pushed function: AcquireButton
    function AcquireButtonPushed(app, event)
      cla(app.UIAxes); cla(app.UIAxes_2); cla(app.UIAxes2); cla(app.UIAxes3); cla(app.UIAxes5); cla(app.UIAxes5_2); cla(app.UIAxes6); cla(app.UIAxes6_2);
      app.escandone=false;
      app.AcquireButton.Enable=false;
      app.NReadEditField.Value=0;
      drawnow
      try
        app.aobj.acquire(app.NPulseEditField.Value);
        app.aobj.WriteGuiListBox();
        app.NReadEditField.Value = double(app.aobj.BPMS.nread) ;
        app.TabGroupSelectionChanged();
        app.AcquireButton.Enable=true; drawnow;
      catch ME
        errordlg(sprintf('Failed to acquire new BPM values: %s',ME.message));
        app.AcquireButton.Enable=true; drawnow;
        lcaPutNoWait('SIOC:SYS1:ML01:AO217',0);
      end
    end

    % Value changed function: PlotRangeDropDown
    function PlotRangeDropDownValueChanged(app, event)
      value = app.PlotRangeDropDown.Value;
      app.aobj.BPMS.plotscale=str2double(value);
      app.TabGroupSelectionChanged;
    end

    % Value changed function: ListBox
    function ListBoxValueChanged(app, event)
      value = app.ListBox.Value;
      app.aobj.usebpm=true(size(app.aobj.usebpm));
      app.aobj.usebpm(~ismember(app.aobj.bpmid,value)) = false ;
      if ~isempty(app.aobj.BPMS.modelID)
        app.aobj.usebpm(~ismember(app.aobj.bpmid,app.aobj.BPMS.modelID))=false;
      end
      app.TabGroupSelectionChanged;
    end

    % Value changed function: ListBox_2
    function ListBox_2ValueChanged(app, event)
      value = app.ListBox_2.Value;
      app.aobj.usexcor=true(size(app.aobj.usexcor));
      app.aobj.usexcor(~ismember(app.aobj.xcorid,value)) = false ;
      app.TabGroupSelectionChanged;
    end

    % Value changed function: ListBox_3
    function ListBox_3ValueChanged(app, event)
      value = app.ListBox_3.Value;
      app.aobj.useycor=true(size(app.aobj.useycor));
      app.aobj.useycor(~ismember(app.aobj.ycorid,value)) = false ;
      app.TabGroupSelectionChanged;
    end

    % Value changed function: TolEditField
    function TolEditFieldValueChanged(app, event)
      value = app.TolEditField.Value;
      if value>0
        app.aobj.solvtol=value;
      end
    end

    % Button pushed function: TolPlotButton
    function TolPlotButtonPushed(app, event)
      if app.lscovButton.Value
        app.aobj.corsolv="lscov";
      elseif app.pinvButton.Value
        app.aobj.corsolv="pinv";
      elseif app.lsqminnormButton.Value
        app.aobj.corsolv="lsqminnorm";
      elseif app.svdButton.Value
        app.aobj.corsolv="svd";
      elseif app.lsqlinButton.Value
        app.aobj.corsolv="lsqlin";
      end
      app.aobj.plottol;
    end

    % Button pushed function: CalcCorrectionButton
    function CalcCorrectionButtonPushed(app, event)
      if app.lscovButton.Value
        app.aobj.corsolv="lscov";
      elseif app.pinvButton.Value
        app.aobj.corsolv="pinv";
      elseif app.lsqminnormButton.Value
        app.aobj.corsolv="lsqminnorm";
        app.aobj.solvtol = app.TolEditField.Value;
      elseif app.svdButton.Value
        app.aobj.corsolv="svd";
        app.aobj.nmode = round(app.TolEditField.Value);
      elseif app.lsqlinButton.Value
        app.aobj.corsolv="lsqlin";
      end
      app.CalcCorrectionButton.Enable=false;
      drawnow;
      try
        app.aobj.corcalc;
      catch ME
        app.CalcCorrectionButton.Enable=true;
        errordlg(sprintf('Calc error:\n%s',ME.message),'Orbit Calc Error');
      end
      app.CalcCorrectionButton.Enable=true;
    end

    % Button pushed function: UpdateLiveModelButton
    function UpdateLiveModelButtonPushed(app, event)
      app.UpdateLiveModelButton.Enable=false;
      drawnow
      try
        app.aobj.LiveModel.UpdateModel;
      catch
        errordlg('Live Model update failed','Live Model Error');
        app.UpdateLiveModelButton.Enable=true;
        drawnow
      end
      app.UpdateLiveModelButton.Enable=true;
      drawnow
    end

    % Value changed function: USEXButton
    function USEXButtonValueChanged(app, event)
      value = app.USEXButton.Value;
      app.aobj.usex=value;
    end

    % Value changed function: USEYButton
    function USEYButtonValueChanged(app, event)
      value = app.USEYButton.Value;
      app.aobj.usey=value;
    end

    % Button pushed function: DoCorrectionButton
    function DoCorrectionButtonPushed(app, event)
      try
        app.aobj.applycalc;
      catch ME
        errordlg(sprintf('Failed to apply orbit correction:\n%s',ME.message),'Correction Error');
        return
      end
      app.UndoCorrectionButton.Enable=true;
      app.DoCorrectionButton.Enable=false;
    end

    % Callback function
    function DoDispCalcButtonPushed(app, event)
      app.DoDispCalcButton.Enable=false;
      drawnow
      try
        dd=app.aobj.svddisp;
        app.DoDispCalcButton.Enable=true;
      catch ME
        errordlg(sprintf('Dispersion calc error:\n%s',ME.message),'Disp Calc Error');
        app.DoDispCalcButton.Enable=true;
        drawnow
        return
      end
      drawnow
      app.TabGroupSelectionChanged;
      app.EditField.Value = sum(abs(dd.x),'omitnan') ;
      app.EditField_2.Value = sum(abs(dd.y),'omitnan') ;
    end

    % Value changed function: DropDown_2
    function DropDown_2ValueChanged(app, event)
      value = app.DropDown_2.Value;
      nmodes=app.NmodesEditField.Value;
      ah = [app.UIAxes6 app.UIAxes6_2] ;
      app.DropDown_2.Enable = false;
      drawnow
      try
        app.aobj.plotmia(nmodes,string(value),ah);
        app.DropDown_2.Enable = true;
      catch ME
        errordlg(sprintf('Plot error:\n%s',ME.message),'Plot Error');
        app.DropDown_2.Enable = true;
      end
      drawnow
    end

    % Button pushed function: PlotButton
    function PlotButtonPushed(app, event)
      nmodes=app.NmodesEditField.Value;
      switch string(app.CorrelatPanel.Value)
        case "E_DL1"
          id=find(ismember(app.aobj.BPMS.modelnames,app.aobj.ebpms(1)));
          if isempty(id)
            errordlg('DL1 Energy BPM not read out','SVD Corr Error');
            return
          end
          cvec = app.aobj.BPMS.xdat(id,:) ./ app.aobj.ebpms_disp(1) ; % dP/P @ energy BPM
        case "E_BC11"
        case "E_BC14"
        case "E_BC20"
      end
      dat = app.aobj.svdcorr(cvec,nmodes) ;
      app.modeEditField.Value=sprintf('%d, %d',dat.xmode,dat.ymode) ;
      app.rEditField.Value=sprintf('%.3f, %.3f',dat.rx,dat.ry) ;
      app.pEditField.Value=sprintf('%.3f, %.3f',dat.px,dat.py) ;
      subplot(app.UIAxes6); subplot(111);
      subplot(2,1,1); plot(cvec,dat.sdat_x,'.'); xlabel('Correlation Variable'); ylabel('X Mode Amplitude'); grid on
      subplot(2,1,2); plot(cvec,dat.sdat_y,'.'); xlabel('Correlation Variable'); ylabel('Y Mode Amplitude'); grid on
    end

    % Callback function
    function ShowModelFitButton_2ValueChanged(app, event)
      app.aobj.domodelfit=app.ShowModelFitButton_2.Value;
      app.TabGroupSelectionChanged;
    end

    % Value changed function: ShowModelFitButton
    function ShowModelFitButtonValueChanged(app, event)
      app.aobj.domodelfit = app.ShowModelFitButton.Value ;
      app.TabGroupSelectionChanged ;
    end

    % Value changed function: NmodesEditField
    function NmodesEditFieldValueChanged(app, event)
      app.DropDown_2ValueChanged;
    end

    % Button pushed function: UndoCorrectionButton
    function UndoCorrectionButtonPushed(app, event)
      try
        app.aobj.undocor;
      catch ME
        errordlg(sprintf('Failed to undo orbit correction:\n%s',ME.message),'Correction Error');
        return
      end
      app.UndoCorrectionButton.Enable=false;
      app.DoCorrectionButton.Enable=false;
    end

    % Callback function
    function stemMenuSelected(app, event)
      app.aobj.corplottype="stem";
      app.stemMenu.Checked=true;
      app.quiverMenu.Checked=false;
      if app.TabGroup.SelectedTab == app.CorrectorsTab
        app.TabGroupSelectionChanged;
      end
    end

    % Callback function
    function quiverMenuSelected(app, event)
      app.aobj.corplottype="quiver";
      app.stemMenu.Checked=false;
      app.quiverMenu.Checked=true;
      if app.TabGroup.SelectedTab == app.CorrectorsTab
        app.TabGroupSelectionChanged;
      end
    end

    % Value changed function: ModelFitButton
    function ModelFitButtonValueChanged(app, event)
      value = app.ModelFitButton.Value;
      app.aobj.domodelfit=value;
    end

    % Value changed function: UseBufferedDataCheckBox
    function UseBufferedDataCheckBoxValueChanged(app, event)
      value = app.UseBufferedDataCheckBox.Value;
      app.aobj.usebpmbuff = value ;
    end

    % Value changed function: rmsChoose
    function rmsChooseValueChanged(app, event)
      value = app.rmsChoose.Value;
      app.aobj.dormsplot=value;
      app.TabGroupSelectionChanged;
    end

    % Callback function
    function PlotTypeButtonGroupSelectionChanged(app, event)
      selectedButton = app.PlotTypeButtonGroup.SelectedObject;
      switch selectedButton
        case app.StemButton
          app.aobj.corplottype = "stem" ;
        case app.QuiverButton
          app.aobj.corplottype = "quiver" ;
      end
      app.TabGroupSelectionChanged;
    end

    % Value changed function: EditField_4
    function EditField_4ValueChanged(app, event)
      value = app.EditField_4.Value;
      app.aobj.CorrectionOffset(1) = value ;
    end

    % Value changed function: EditField_6
    function EditField_6ValueChanged(app, event)
      value = app.EditField_6.Value;
      app.aobj.CorrectionOffset(2) = value ;
    end

    % Value changed function: EditField_8
    function EditField_8ValueChanged(app, event)
      value = app.EditField_8.Value;
      app.aobj.CorrectionOffset(3) = value ;
    end

    % Value changed function: EditField_10
    function EditField_10ValueChanged(app, event)
      value = app.EditField_10.Value;
      app.aobj.CorrectionOffset(4) = value ;
    end

    % Callback function
    function EditField_12ValueChanged(app, event)
      value = app.EditField_12.Value;
      app.aobj.CorrectionOffset(5) = value ;
    end

    % Button pushed function: SelectFitLocationButton, 
    % SelectFitLocationButton_2
    function SelectFitLocationButtonPushed(app, event)
      LM=copy(app.aobj.LM);
      LM.ModelClasses="All";
      ele = ElementChooser(LM).GetChoice;
      if ~isnan(ele(1))
        if LM.ModelID(ele) < LM.istart || LM.ModelID(ele) > LM.iend
          errordlg('Chosen element outside of active region','Element Choice Error');
          return
        end
        app.aobj.fitele = LM.ModelID(ele(1)) ;
        app.EditField_13.Value = LM.ModelNames(ele(1)) ;
        app.EditField_23.Value = LM.ModelNames(ele(1)) ;
      end
      app.TabGroupSelectionChanged;
    end

    % Button pushed function: TakeNewRefButton
    function TakeNewRefButtonPushed(app, event)
      app.aobj.StoreRef();
    end

    % Value changed function: DropDown_4
    function DropDown_4ValueChanged(app, event)
      value = app.DropDown_4.Value;
      switch value
        case '1'
          app.aobj.UseRefOrbit="none";
        case '2'
          app.aobj.UseRefOrbit="local";
        case '3'
          app.aobj.UseRefOrbit="config";
        otherwise
          error('Ref orbit selection error');
      end
      app.TabGroupSelectionChanged;
    end

    % Menu selected function: NoneMenu
    function NoneMenuSelected(app, event)
      app.aobj.GuiConfigLoad(event);
    end

    % Menu selected function: SaveMenu
    function SaveMenuSelected(app, event)
      app.aobj.ConfigSave();
    end

    % Value changed function: NPulseEditField
    function NPulseEditFieldValueChanged(app, event)
      value = app.NPulseEditField.Value;
      app.aobj.npulse = value ;
      app.TabGroupSelectionChanged;
    end

    % Menu selected function: SaveAsMenu
    function SaveAsMenuSelected(app, event)
      cname=inputdlg('Provide new configuration name','Save New Config',1);
      if ~isempty(cname)
        name=string(cname{1});
        if ismember(name,app.aobj.Configs)
          if string(questdlg('Configuration file exists, overwrite?','Overwrite Config?','Yes','No','No'))=="Yes"
            app.aobj.ConfigSave(name);
          end
        else
          app.aobj.ConfigSave(name);
          uimenu(app.SelectMenu,'Text',name + "  (" + datestr(now) + ")",'Tag',name,'MenuSelectedFcn',@(source,event) app.aobj.GuiConfigLoad(event));
        end
        app.FACETIIOrbitToolconfignoneUIFigure.Name = sprintf("FACET-II Orbit Tool [config = %s]",name);
        for imenu=1:length(app.SelectMenu.Children)
          if string(app.SelectMenu.Children(imenu).Tag) == name
            app.SelectMenu.Children(imenu).Checked=1;
          else
            app.SelectMenu.Children(imenu).Checked=0;
          end
        end
      end
    end

    % Menu selected function: DeleteMenu
    function DeleteMenuSelected(app, event)
      resp=questdlg('Delete current configuration file?','Delete Config?','No');
      if string(resp)~="Yes"
        return
      end
      app.aobj.ConfigDelete();
      for imenu=1:length(app.SelectMenu.Children)
        app.SelectMenu.Children(imenu).Checked=0;
      end
      app.NoneMenu.Checked = 1 ;
      app.FACETIIOrbitToolconfignoneUIFigure.Name = sprintf("FACET-II Orbit Tool [config = %s]","none");
    end

    % Value changed function: DropDown_5
    function DropDown_5ValueChanged(app, event)
      value = app.DropDown_5.Value;
      app.DropDown_6.Value = value ;
      app.aobj.orbitfitmethod=value;
      app.TabGroupSelectionChanged;
    end

    % Value changed function: ShowCors
    function ShowCorsValueChanged(app, event)
      app.TabGroupSelectionChanged;
    end

    % Value changed function: ShowMaxButton
    function ShowMaxButtonValueChanged(app, event)
      drawnow;
      app.TabGroupSelectionChanged;
    end

    % Value changed function: DropDown_6
    function DropDown_6ValueChanged(app, event)
      value = app.DropDown_6.Value;
      app.DropDown_5.Value = value ;
      app.aobj.orbitfitmethod=value;
      app.TabGroupSelectionChanged;
    end

    % Button pushed function: DoScanButton
    function DoScanButtonPushed(app, event)
      app.escandone=false;
      app.DoScanButton.Enable=false; drawnow;
      try
        app.aobj.DoEscan(app.NPulseEditField.Value) ;
      catch ME
        errordlg('E Scan Error',ME.message);
        app.DoScanButton.Enabletrue; drawnow;
        return
      end
      app.escandone=true;
      app.DoScanButton.Enabletrue; drawnow;
    end

    % Value changed function: ShowFitButton
    function ShowFitButtonValueChanged(app, event)
      app.TabGroupSelectionChanged;
    end

    % Value changed function: ShowDevicesButton
    function ShowDevicesButtonValueChanged(app, event)
      app.TabGroupSelectionChanged;
    end

    % Button pushed function: DoCorrectionButton_2
    function DoCorrectionButton_2Pushed(app, event)
      D_init = [app.EditField_14.Value app.EditField_16.Value app.EditField_18.Value app.EditField_20.Value] ;
      try
        app.DoCorrectionButton_2.Enable=false; drawnow;
        DX_cor = app.aobj.dispcor() ;
      catch ME
        app.DoCorrectionButton_2.Enable=true; drawnow;
        errordlg(ME.message,'Disp Correct Error');
        return
      end
      app.DoCorrectionButton_2.Enable=true; drawnow;
      corvals = app.aobj.DispCorData ;
      app.aobj.LM.ModelClasses=["QUAD" "SEXT"];
      corsel = find(ismember(app.aobj.DispDevices,app.aobj.LM.ModelNames)) ;
      txt = sprintf("Dispersion correction:\nInitial = [%g , %g , %g , %g] mm/mrad\nCorrection = [%g , %g , %g , %g] mm/mrad",D_init,DX_cor);
      txt = txt + "\n --- \n" + "Correction Devices and calculated changes:" ;
      for icor=corsel(:)'
        txt = txt + "\n" ;
        curval = lcaGet(char(app.aobj.DispDeviceReadPV(icor))) ;
        switch double(app.aobj.DispDeviceType(icor))
          case {1,2}
            txt = txt + app.aobj.DispDevices(icor) + " " + curval + " -> " + (curval+corvals(icor)*10) ;
            txt = txt + " (BDES)" ;
          case 3
            txt = txt + app.aobj.DispDevices(icor) + " " + curval + " -> " + (curval+corvals(icor)*1000) ;
            txt = txt + " (X / mm)" ;
          case 4
            txt = txt + app.aobj.DispDevices(icor) + " " + curval + " -> " + (curval+corvals(icor)*1000) ;
            txt = txt + " (Y / mm)" ;
        end
      end
      resp = questdlg(sprintf(txt),"Accept Correction?","No") ;
      if string(resp) == "Yes"
        app.aobj.SetDispcor() ;
        UpdateLiveModelButtonPushed(app) ;
      end
    end

    % Value changed function: DropDown_7
    function DropDown_7ValueChanged(app, event)
      value = string(app.DropDown_7.Value);
      app.aobj.escandev = value ;
      iknob=ismember(EnergyKnobNames,value) ;
      range=app.aobj.escanrange;
      app.MinEditField.Value = range(1,iknob) ;
      app.MaxEditFIeld.Value = range(2,iknob) ;
      app.NstepEditField.Value = app.aobj.nescan(iknob) ;
    end

    % Value changed function: MinEditField
    function MinEditFieldValueChanged(app, event)
      value = app.MinEditField.Value;
      iknob=ismember(EnergyKnobNames,app.aobj.escandev) ;
      app.aobj.escanrange(1,iknob) = value ;
    end

    % Value changed function: MaxEditField
    function MaxEditFieldValueChanged(app, event)
      value = app.MaxEditField.Value;
      iknob=ismember(EnergyKnobNames,app.aobj.escandev) ;
      app.aobj.escanrange(2,iknob) = value ;
    end

    % Value changed function: NstepEditField
    function NstepEditFieldValueChanged(app, event)
      value = app.NstepEditField.Value;
      iknob=ismember(EnergyKnobNames,app.aobj.escandev) ;
      app.aobj.nescan(iknob) = value ;
    end

    % Value changed function: CorUnitsButton
    function CorUnitsButtonValueChanged(app, event)
      value = app.CorUnitsButton.Value;
      if value
        app.CorUnitsButton.Text = "Units = BDES" ;
      else
        app.CorUnitsButton.Text = "Units = mrad" ;
      end
      drawnow;
      app.TabGroupSelectionChanged;
    end

    % Button pushed function: LogbookButton
    function LogbookButtonPushed(app, event)
      app.logplot=true;
      try
        app.TabGroupSelectionChanged;      
      catch ME
        app.logplot=false;
        throw(ME);
      end
    end

    % Value changed function: PlotallCheckBox
    function PlotallCheckBoxValueChanged(app, event)
      app.TabGroupSelectionChanged;
    end
  end

  % Component initialization
  methods (Access = private)

    % Create UIFigure and components
    function createComponents(app)

      % Create FACETIIOrbitToolconfignoneUIFigure and hide until all components are created
      app.FACETIIOrbitToolconfignoneUIFigure = uifigure('Visible', 'off');
      app.FACETIIOrbitToolconfignoneUIFigure.Position = [100 100 1428 740];
      app.FACETIIOrbitToolconfignoneUIFigure.Name = 'FACET-II Orbit Tool [config = none]';
      app.FACETIIOrbitToolconfignoneUIFigure.Resize = 'off';

      % Create ConfigMenu
      app.ConfigMenu = uimenu(app.FACETIIOrbitToolconfignoneUIFigure);
      app.ConfigMenu.Text = 'Config';

      % Create SelectMenu
      app.SelectMenu = uimenu(app.ConfigMenu);
      app.SelectMenu.Text = 'Select';

      % Create NoneMenu
      app.NoneMenu = uimenu(app.SelectMenu);
      app.NoneMenu.MenuSelectedFcn = createCallbackFcn(app, @NoneMenuSelected, true);
      app.NoneMenu.Checked = 'on';
      app.NoneMenu.Text = 'None';
      app.NoneMenu.Tag = 'none';

      % Create SaveAsMenu
      app.SaveAsMenu = uimenu(app.ConfigMenu);
      app.SaveAsMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveAsMenuSelected, true);
      app.SaveAsMenu.Text = 'Save As...';

      % Create SaveMenu
      app.SaveMenu = uimenu(app.ConfigMenu);
      app.SaveMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveMenuSelected, true);
      app.SaveMenu.Text = 'Save';

      % Create DeleteMenu
      app.DeleteMenu = uimenu(app.ConfigMenu);
      app.DeleteMenu.MenuSelectedFcn = createCallbackFcn(app, @DeleteMenuSelected, true);
      app.DeleteMenu.Text = 'Delete';

      % Create BPMsPanel
      app.BPMsPanel = uipanel(app.FACETIIOrbitToolconfignoneUIFigure);
      app.BPMsPanel.Title = 'BPMs';
      app.BPMsPanel.Position = [8 10 163 719];

      % Create ListBox
      app.ListBox = uilistbox(app.BPMsPanel);
      app.ListBox.ItemsData = {'1', '2', '3', '4'};
      app.ListBox.Multiselect = 'on';
      app.ListBox.ValueChangedFcn = createCallbackFcn(app, @ListBoxValueChanged, true);
      app.ListBox.Position = [8 37 147 654];
      app.ListBox.Value = {'1', '2', '3', '4'};

      % Create PlotallCheckBox
      app.PlotallCheckBox = uicheckbox(app.BPMsPanel);
      app.PlotallCheckBox.ValueChangedFcn = createCallbackFcn(app, @PlotallCheckBoxValueChanged, true);
      app.PlotallCheckBox.Text = 'Plot all?';
      app.PlotallCheckBox.Position = [8 8 66 22];

      % Create CorrectorsPanel
      app.CorrectorsPanel = uipanel(app.FACETIIOrbitToolconfignoneUIFigure);
      app.CorrectorsPanel.Title = 'Correctors';
      app.CorrectorsPanel.Position = [1240 11 174 718];

      % Create ListBox_2
      app.ListBox_2 = uilistbox(app.CorrectorsPanel);
      app.ListBox_2.ItemsData = {'[1,2,3,4]'};
      app.ListBox_2.Multiselect = 'on';
      app.ListBox_2.ValueChangedFcn = createCallbackFcn(app, @ListBox_2ValueChanged, true);
      app.ListBox_2.Position = [11 366 155 324];
      app.ListBox_2.Value = {'[1,2,3,4]'};

      % Create ListBox_3
      app.ListBox_3 = uilistbox(app.CorrectorsPanel);
      app.ListBox_3.Multiselect = 'on';
      app.ListBox_3.ValueChangedFcn = createCallbackFcn(app, @ListBox_3ValueChanged, true);
      app.ListBox_3.Position = [11 7 155 355];
      app.ListBox_3.Value = {'Item 1'};

      % Create TabGroup
      app.TabGroup = uitabgroup(app.FACETIIOrbitToolconfignoneUIFigure);
      app.TabGroup.SelectionChangedFcn = createCallbackFcn(app, @TabGroupSelectionChanged, true);
      app.TabGroup.Position = [187 66 1045 586];

      % Create OrbitTab
      app.OrbitTab = uitab(app.TabGroup);
      app.OrbitTab.AutoResizeChildren = 'off';
      app.OrbitTab.Title = 'Orbit';

      % Create UIAxes
      app.UIAxes = uiaxes(app.OrbitTab);
      title(app.UIAxes, '')
      xlabel(app.UIAxes, '')
      ylabel(app.UIAxes, 'Y')
      app.UIAxes.FontSize = 14;
      app.UIAxes.Position = [134 264 712 290];

      % Create CalcCorrectionButton
      app.CalcCorrectionButton = uibutton(app.OrbitTab, 'push');
      app.CalcCorrectionButton.ButtonPushedFcn = createCallbackFcn(app, @CalcCorrectionButtonPushed, true);
      app.CalcCorrectionButton.Interruptible = 'off';
      app.CalcCorrectionButton.Position = [17 514 100 29];
      app.CalcCorrectionButton.Text = 'Calc Correction';

      % Create DoCorrectionButton
      app.DoCorrectionButton = uibutton(app.OrbitTab, 'push');
      app.DoCorrectionButton.ButtonPushedFcn = createCallbackFcn(app, @DoCorrectionButtonPushed, true);
      app.DoCorrectionButton.Interruptible = 'off';
      app.DoCorrectionButton.Enable = 'off';
      app.DoCorrectionButton.Position = [17 478 100 29];
      app.DoCorrectionButton.Text = 'Do Correction';

      % Create USEXButton
      app.USEXButton = uibutton(app.OrbitTab, 'state');
      app.USEXButton.ValueChangedFcn = createCallbackFcn(app, @USEXButtonValueChanged, true);
      app.USEXButton.Text = 'USE X';
      app.USEXButton.Position = [17 409 100 23];
      app.USEXButton.Value = true;

      % Create USEYButton
      app.USEYButton = uibutton(app.OrbitTab, 'state');
      app.USEYButton.ValueChangedFcn = createCallbackFcn(app, @USEYButtonValueChanged, true);
      app.USEYButton.Text = 'USE Y';
      app.USEYButton.Position = [17 378 100 23];
      app.USEYButton.Value = true;

      % Create UIAxes_2
      app.UIAxes_2 = uiaxes(app.OrbitTab);
      title(app.UIAxes_2, '')
      xlabel(app.UIAxes_2, 'X')
      ylabel(app.UIAxes_2, 'Y')
      app.UIAxes_2.FontSize = 14;
      app.UIAxes_2.Position = [134 4 712 254];

      % Create CorrectionSolverButtonGroup
      app.CorrectionSolverButtonGroup = uibuttongroup(app.OrbitTab);
      app.CorrectionSolverButtonGroup.AutoResizeChildren = 'off';
      app.CorrectionSolverButtonGroup.Title = 'Correction Solver';
      app.CorrectionSolverButtonGroup.Position = [5 14 123 187];

      % Create lscovButton
      app.lscovButton = uiradiobutton(app.CorrectionSolverButtonGroup);
      app.lscovButton.Text = 'lscov';
      app.lscovButton.Position = [11 144 58 22];

      % Create pinvButton
      app.pinvButton = uiradiobutton(app.CorrectionSolverButtonGroup);
      app.pinvButton.Text = 'pinv';
      app.pinvButton.Position = [11 123 65 22];

      % Create lsqminnormButton
      app.lsqminnormButton = uiradiobutton(app.CorrectionSolverButtonGroup);
      app.lsqminnormButton.Text = 'lsqminnorm';
      app.lsqminnormButton.Position = [11 102 86 22];

      % Create TolEditFieldLabel
      app.TolEditFieldLabel = uilabel(app.CorrectionSolverButtonGroup);
      app.TolEditFieldLabel.HorizontalAlignment = 'right';
      app.TolEditFieldLabel.Position = [9 34 25 22];
      app.TolEditFieldLabel.Text = 'Tol';

      % Create TolEditField
      app.TolEditField = uieditfield(app.CorrectionSolverButtonGroup, 'numeric');
      app.TolEditField.ValueChangedFcn = createCallbackFcn(app, @TolEditFieldValueChanged, true);
      app.TolEditField.Position = [48 34 62 22];

      % Create TolPlotButton
      app.TolPlotButton = uibutton(app.CorrectionSolverButtonGroup, 'push');
      app.TolPlotButton.ButtonPushedFcn = createCallbackFcn(app, @TolPlotButtonPushed, true);
      app.TolPlotButton.Position = [11 6 100 23];
      app.TolPlotButton.Text = 'Tol Plot';

      % Create svdButton
      app.svdButton = uiradiobutton(app.CorrectionSolverButtonGroup);
      app.svdButton.Text = 'svd';
      app.svdButton.Position = [11 81 41 22];

      % Create lsqlinButton
      app.lsqlinButton = uiradiobutton(app.CorrectionSolverButtonGroup);
      app.lsqlinButton.Text = 'lsqlin';
      app.lsqlinButton.Position = [11 59 51 22];
      app.lsqlinButton.Value = true;

      % Create ShowModelFitButton
      app.ShowModelFitButton = uibutton(app.OrbitTab, 'state');
      app.ShowModelFitButton.ValueChangedFcn = createCallbackFcn(app, @ShowModelFitButtonValueChanged, true);
      app.ShowModelFitButton.Text = 'Show Model Fit';
      app.ShowModelFitButton.Position = [9 213 115 27];

      % Create UndoCorrectionButton
      app.UndoCorrectionButton = uibutton(app.OrbitTab, 'push');
      app.UndoCorrectionButton.ButtonPushedFcn = createCallbackFcn(app, @UndoCorrectionButtonPushed, true);
      app.UndoCorrectionButton.Interruptible = 'off';
      app.UndoCorrectionButton.Enable = 'off';
      app.UndoCorrectionButton.Position = [14 441 105 29];
      app.UndoCorrectionButton.Text = 'Undo Correction';

      % Create ModelFitButton
      app.ModelFitButton = uibutton(app.OrbitTab, 'state');
      app.ModelFitButton.ValueChangedFcn = createCallbackFcn(app, @ModelFitButtonValueChanged, true);
      app.ModelFitButton.Text = 'Use Model Fit';
      app.ModelFitButton.Position = [17 346 100 23];

      % Create rmsChoose
      app.rmsChoose = uibutton(app.OrbitTab, 'state');
      app.rmsChoose.ValueChangedFcn = createCallbackFcn(app, @rmsChooseValueChanged, true);
      app.rmsChoose.Text = 'Show RMS';
      app.rmsChoose.Position = [9 247 115 27];

      % Create OrbitFitPanel
      app.OrbitFitPanel = uipanel(app.OrbitTab);
      app.OrbitFitPanel.AutoResizeChildren = 'off';
      app.OrbitFitPanel.Title = 'Orbit Fit';
      app.OrbitFitPanel.Position = [868 46 172 508];

      % Create EditField_3
      app.EditField_3 = uieditfield(app.OrbitFitPanel, 'numeric');
      app.EditField_3.Editable = 'off';
      app.EditField_3.Position = [26 352 90 22];

      % Create EditField_4
      app.EditField_4 = uieditfield(app.OrbitFitPanel, 'numeric');
      app.EditField_4.ValueChangedFcn = createCallbackFcn(app, @EditField_4ValueChanged, true);
      app.EditField_4.Position = [26 326 90 22];

      % Create EditField_5
      app.EditField_5 = uieditfield(app.OrbitFitPanel, 'numeric');
      app.EditField_5.Editable = 'off';
      app.EditField_5.Position = [26 270 90 22];

      % Create EditField_6
      app.EditField_6 = uieditfield(app.OrbitFitPanel, 'numeric');
      app.EditField_6.ValueChangedFcn = createCallbackFcn(app, @EditField_6ValueChanged, true);
      app.EditField_6.Position = [26 245 90 22];

      % Create EditField_7
      app.EditField_7 = uieditfield(app.OrbitFitPanel, 'numeric');
      app.EditField_7.Editable = 'off';
      app.EditField_7.Position = [24 187 90 22];

      % Create EditField_8
      app.EditField_8 = uieditfield(app.OrbitFitPanel, 'numeric');
      app.EditField_8.ValueChangedFcn = createCallbackFcn(app, @EditField_8ValueChanged, true);
      app.EditField_8.Position = [24 161 90 22];

      % Create EditField_9
      app.EditField_9 = uieditfield(app.OrbitFitPanel, 'numeric');
      app.EditField_9.Editable = 'off';
      app.EditField_9.Position = [24 99 90 22];

      % Create EditField_10
      app.EditField_10 = uieditfield(app.OrbitFitPanel, 'numeric');
      app.EditField_10.ValueChangedFcn = createCallbackFcn(app, @EditField_10ValueChanged, true);
      app.EditField_10.Position = [24 74 90 22];

      % Create XmmLabel
      app.XmmLabel = uilabel(app.OrbitFitPanel);
      app.XmmLabel.Position = [44 373 44 22];
      app.XmmLabel.Text = 'X (mm)';

      % Create XANGmmLabel
      app.XANGmmLabel = uilabel(app.OrbitFitPanel);
      app.XANGmmLabel.Position = [44 291 70 22];
      app.XANGmmLabel.Text = 'XANG (mm)';

      % Create YmmLabel
      app.YmmLabel = uilabel(app.OrbitFitPanel);
      app.YmmLabel.Position = [42 213 44 22];
      app.YmmLabel.Text = 'Y (mm)';

      % Create YANGmmLabel
      app.YANGmmLabel = uilabel(app.OrbitFitPanel);
      app.YANGmmLabel.Position = [42 122 70 22];
      app.YANGmmLabel.Text = 'YANG (mm)';

      % Create ACTLabel
      app.ACTLabel = uilabel(app.OrbitFitPanel);
      app.ACTLabel.Position = [126 352 29 22];
      app.ACTLabel.Text = 'ACT';

      % Create DESLabel
      app.DESLabel = uilabel(app.OrbitFitPanel);
      app.DESLabel.Position = [125 325 30 22];
      app.DESLabel.Text = 'DES';

      % Create ACTLabel_2
      app.ACTLabel_2 = uilabel(app.OrbitFitPanel);
      app.ACTLabel_2.Position = [126 272 29 22];
      app.ACTLabel_2.Text = 'ACT';

      % Create DESLabel_2
      app.DESLabel_2 = uilabel(app.OrbitFitPanel);
      app.DESLabel_2.Position = [125 245 30 22];
      app.DESLabel_2.Text = 'DES';

      % Create ACTLabel_3
      app.ACTLabel_3 = uilabel(app.OrbitFitPanel);
      app.ACTLabel_3.Position = [120 187 29 22];
      app.ACTLabel_3.Text = 'ACT';

      % Create DESLabel_3
      app.DESLabel_3 = uilabel(app.OrbitFitPanel);
      app.DESLabel_3.Position = [119 160 30 22];
      app.DESLabel_3.Text = 'DES';

      % Create ACTLabel_4
      app.ACTLabel_4 = uilabel(app.OrbitFitPanel);
      app.ACTLabel_4.Position = [122 100 29 22];
      app.ACTLabel_4.Text = 'ACT';

      % Create DESLabel_4
      app.DESLabel_4 = uilabel(app.OrbitFitPanel);
      app.DESLabel_4.Position = [121 73 30 22];
      app.DESLabel_4.Text = 'DES';

      % Create EditField_11
      app.EditField_11 = uieditfield(app.OrbitFitPanel, 'numeric');
      app.EditField_11.Editable = 'off';
      app.EditField_11.Position = [26 16 90 22];

      % Create dEMeVLabel
      app.dEMeVLabel = uilabel(app.OrbitFitPanel);
      app.dEMeVLabel.Position = [44 39 56 22];
      app.dEMeVLabel.Text = 'dE (MeV)';

      % Create EditField_13
      app.EditField_13 = uieditfield(app.OrbitFitPanel, 'text');
      app.EditField_13.Editable = 'off';
      app.EditField_13.HorizontalAlignment = 'center';
      app.EditField_13.Position = [11 433 142 22];
      app.EditField_13.Value = '<FitLocation>';

      % Create SelectFitLocationButton
      app.SelectFitLocationButton = uibutton(app.OrbitFitPanel, 'push');
      app.SelectFitLocationButton.ButtonPushedFcn = createCallbackFcn(app, @SelectFitLocationButtonPushed, true);
      app.SelectFitLocationButton.Position = [11 459 142 23];
      app.SelectFitLocationButton.Text = 'Select Fit Location';

      % Create DropDown_5
      app.DropDown_5 = uidropdown(app.OrbitFitPanel);
      app.DropDown_5.Items = {'lscov', 'backslash'};
      app.DropDown_5.ValueChangedFcn = createCallbackFcn(app, @DropDown_5ValueChanged, true);
      app.DropDown_5.Position = [13 402 139 22];
      app.DropDown_5.Value = 'lscov';

      % Create DropDown_4
      app.DropDown_4 = uidropdown(app.OrbitTab);
      app.DropDown_4.Items = {'No Ref. Orbit', 'New Ref. Orbit', 'Config Ref. Orbit'};
      app.DropDown_4.ItemsData = {'1', '2', '3'};
      app.DropDown_4.ValueChangedFcn = createCallbackFcn(app, @DropDown_4ValueChanged, true);
      app.DropDown_4.Position = [9 282 117 22];
      app.DropDown_4.Value = '1';

      % Create TakeNewRefButton
      app.TakeNewRefButton = uibutton(app.OrbitTab, 'push');
      app.TakeNewRefButton.ButtonPushedFcn = createCallbackFcn(app, @TakeNewRefButtonPushed, true);
      app.TakeNewRefButton.Position = [8 307 117 23];
      app.TakeNewRefButton.Text = 'Take New Ref.';

      % Create ShowCors
      app.ShowCors = uibutton(app.OrbitTab, 'state');
      app.ShowCors.ValueChangedFcn = createCallbackFcn(app, @ShowCorsValueChanged, true);
      app.ShowCors.Text = 'Show Corrector Locations';
      app.ShowCors.Position = [876 10 156 28];

      % Create CorrectorsTab
      app.CorrectorsTab = uitab(app.TabGroup);
      app.CorrectorsTab.Title = 'Correctors';

      % Create UIAxes2
      app.UIAxes2 = uiaxes(app.CorrectorsTab);
      title(app.UIAxes2, '')
      xlabel(app.UIAxes2, '')
      ylabel(app.UIAxes2, 'Y')
      app.UIAxes2.Position = [9 243 1025 290];

      % Create UIAxes3
      app.UIAxes3 = uiaxes(app.CorrectorsTab);
      title(app.UIAxes3, '')
      xlabel(app.UIAxes3, 'X')
      ylabel(app.UIAxes3, 'Y')
      app.UIAxes3.Position = [8 21 1024 217];

      % Create ShowMaxButton
      app.ShowMaxButton = uibutton(app.CorrectorsTab, 'state');
      app.ShowMaxButton.ValueChangedFcn = createCallbackFcn(app, @ShowMaxButtonValueChanged, true);
      app.ShowMaxButton.Text = 'Show Min/Max Envelope';
      app.ShowMaxButton.Position = [889 534 150 23];

      % Create CorUnitsButton
      app.CorUnitsButton = uibutton(app.CorrectorsTab, 'state');
      app.CorUnitsButton.ValueChangedFcn = createCallbackFcn(app, @CorUnitsButtonValueChanged, true);
      app.CorUnitsButton.Text = 'Units = mrad';
      app.CorUnitsButton.Position = [780 534 100 23];

      % Create DispersionTab
      app.DispersionTab = uitab(app.TabGroup);
      app.DispersionTab.Title = 'Dispersion';

      % Create UIAxes5
      app.UIAxes5 = uiaxes(app.DispersionTab);
      title(app.UIAxes5, '')
      xlabel(app.UIAxes5, '')
      ylabel(app.UIAxes5, 'Y')
      app.UIAxes5.FontSize = 14;
      app.UIAxes5.Position = [4 263 854 295];

      % Create UIAxes5_2
      app.UIAxes5_2 = uiaxes(app.DispersionTab);
      title(app.UIAxes5_2, '')
      xlabel(app.UIAxes5_2, 'X')
      ylabel(app.UIAxes5_2, 'Y')
      app.UIAxes5_2.FontSize = 14;
      app.UIAxes5_2.Position = [4 6 854 254];

      % Create DispersionFitmmmradPanel
      app.DispersionFitmmmradPanel = uipanel(app.DispersionTab);
      app.DispersionFitmmmradPanel.AutoResizeChildren = 'off';
      app.DispersionFitmmmradPanel.Title = 'Dispersion Fit [mm/mrad]';
      app.DispersionFitmmmradPanel.Position = [865 307 172 247];

      % Create EditField_14
      app.EditField_14 = uieditfield(app.DispersionFitmmmradPanel, 'numeric');
      app.EditField_14.Editable = 'off';
      app.EditField_14.Position = [25 112 90 22];
      app.EditField_14.Value = Inf;

      % Create EditField_16
      app.EditField_16 = uieditfield(app.DispersionFitmmmradPanel, 'numeric');
      app.EditField_16.Editable = 'off';
      app.EditField_16.Position = [25 87 90 22];
      app.EditField_16.Value = Inf;

      % Create EditField_18
      app.EditField_18 = uieditfield(app.DispersionFitmmmradPanel, 'numeric');
      app.EditField_18.Editable = 'off';
      app.EditField_18.Position = [25 63 90 22];
      app.EditField_18.Value = Inf;

      % Create EditField_20
      app.EditField_20 = uieditfield(app.DispersionFitmmmradPanel, 'numeric');
      app.EditField_20.Editable = 'off';
      app.EditField_20.Position = [25 39 90 22];
      app.EditField_20.Value = Inf;

      % Create DXLabel
      app.DXLabel = uilabel(app.DispersionFitmmmradPanel);
      app.DXLabel.Position = [122 112 25 22];
      app.DXLabel.Text = 'DX';

      % Create EditField_23
      app.EditField_23 = uieditfield(app.DispersionFitmmmradPanel, 'text');
      app.EditField_23.Editable = 'off';
      app.EditField_23.HorizontalAlignment = 'center';
      app.EditField_23.Position = [11 172 142 22];
      app.EditField_23.Value = '<FitLocation>';

      % Create SelectFitLocationButton_2
      app.SelectFitLocationButton_2 = uibutton(app.DispersionFitmmmradPanel, 'push');
      app.SelectFitLocationButton_2.ButtonPushedFcn = createCallbackFcn(app, @SelectFitLocationButtonPushed, true);
      app.SelectFitLocationButton_2.Position = [11 198 142 23];
      app.SelectFitLocationButton_2.Text = 'Select Fit Location';

      % Create DropDown_6
      app.DropDown_6 = uidropdown(app.DispersionFitmmmradPanel);
      app.DropDown_6.Items = {'lscov', 'backslash'};
      app.DropDown_6.ValueChangedFcn = createCallbackFcn(app, @DropDown_6ValueChanged, true);
      app.DropDown_6.Position = [15 141 134 22];
      app.DropDown_6.Value = 'lscov';

      % Create ShowFitButton
      app.ShowFitButton = uibutton(app.DispersionFitmmmradPanel, 'state');
      app.ShowFitButton.ValueChangedFcn = createCallbackFcn(app, @ShowFitButtonValueChanged, true);
      app.ShowFitButton.Text = 'Show Fit';
      app.ShowFitButton.Position = [12 8 150 23];
      app.ShowFitButton.Value = true;

      % Create DPXLabel
      app.DPXLabel = uilabel(app.DispersionFitmmmradPanel);
      app.DPXLabel.Position = [122 87 30 22];
      app.DPXLabel.Text = 'DPX';

      % Create DYLabel
      app.DYLabel = uilabel(app.DispersionFitmmmradPanel);
      app.DYLabel.Position = [122 63 25 22];
      app.DYLabel.Text = 'DY';

      % Create DPYLabel
      app.DPYLabel = uilabel(app.DispersionFitmmmradPanel);
      app.DPYLabel.Position = [122 39 30 22];
      app.DPYLabel.Text = 'DPY';

      % Create DispersionCorrectionPanel
      app.DispersionCorrectionPanel = uipanel(app.DispersionTab);
      app.DispersionCorrectionPanel.Title = 'Dispersion Correction';
      app.DispersionCorrectionPanel.Position = [865 200 172 104];

      % Create DoCorrectionButton_2
      app.DoCorrectionButton_2 = uibutton(app.DispersionCorrectionPanel, 'push');
      app.DoCorrectionButton_2.ButtonPushedFcn = createCallbackFcn(app, @DoCorrectionButton_2Pushed, true);
      app.DoCorrectionButton_2.Position = [14 39 144 34];
      app.DoCorrectionButton_2.Text = 'Do Correction';

      % Create ShowDevicesButton
      app.ShowDevicesButton = uibutton(app.DispersionCorrectionPanel, 'state');
      app.ShowDevicesButton.ValueChangedFcn = createCallbackFcn(app, @ShowDevicesButtonValueChanged, true);
      app.ShowDevicesButton.Text = 'Show Devices';
      app.ShowDevicesButton.Position = [14 7 144 23];

      % Create DispersionfromEnergyScanPanel
      app.DispersionfromEnergyScanPanel = uipanel(app.DispersionTab);
      app.DispersionfromEnergyScanPanel.Title = 'Dispersion from Energy Scan';
      app.DispersionfromEnergyScanPanel.Position = [865 6 172 189];

      % Create DoScanButton
      app.DoScanButton = uibutton(app.DispersionfromEnergyScanPanel, 'push');
      app.DoScanButton.ButtonPushedFcn = createCallbackFcn(app, @DoScanButtonPushed, true);
      app.DoScanButton.Position = [16 12 144 29];
      app.DoScanButton.Text = 'Do Scan';

      % Create DropDown_7
      app.DropDown_7 = uidropdown(app.DispersionfromEnergyScanPanel);
      app.DropDown_7.Items = {'S20_ENERGY_3AND4', 'S20_ENERGY_4AND5', 'S20_ENERGY_4AND6', 'BC14_ENERGY_4AND5', 'BC14_ENERGY_5AND6', 'BC14_ENERGY_4AND6', 'BC11_ENERGY', 'DL10_ENERGY'};
      app.DropDown_7.ValueChangedFcn = createCallbackFcn(app, @DropDown_7ValueChanged, true);
      app.DropDown_7.FontSize = 10;
      app.DropDown_7.Position = [5 139 162 22];
      app.DropDown_7.Value = 'S20_ENERGY_3AND4';

      % Create MinEditFieldLabel
      app.MinEditFieldLabel = uilabel(app.DispersionfromEnergyScanPanel);
      app.MinEditFieldLabel.HorizontalAlignment = 'right';
      app.MinEditFieldLabel.Position = [16 105 25 22];
      app.MinEditFieldLabel.Text = 'Min';

      % Create MinEditField
      app.MinEditField = uieditfield(app.DispersionfromEnergyScanPanel, 'numeric');
      app.MinEditField.Limits = [-500 500];
      app.MinEditField.ValueChangedFcn = createCallbackFcn(app, @MinEditFieldValueChanged, true);
      app.MinEditField.Position = [55 106 59 22];
      app.MinEditField.Value = -50;

      % Create MaxEditFieldLabel
      app.MaxEditFieldLabel = uilabel(app.DispersionfromEnergyScanPanel);
      app.MaxEditFieldLabel.HorizontalAlignment = 'right';
      app.MaxEditFieldLabel.Position = [14 77 28 22];
      app.MaxEditFieldLabel.Text = 'Max';

      % Create MaxEditField
      app.MaxEditField = uieditfield(app.DispersionfromEnergyScanPanel, 'numeric');
      app.MaxEditField.Limits = [-500 500];
      app.MaxEditField.ValueChangedFcn = createCallbackFcn(app, @MaxEditFieldValueChanged, true);
      app.MaxEditField.Position = [56 77 59 22];
      app.MaxEditField.Value = 50;

      % Create NstepEditFieldLabel
      app.NstepEditFieldLabel = uilabel(app.DispersionfromEnergyScanPanel);
      app.NstepEditFieldLabel.HorizontalAlignment = 'right';
      app.NstepEditFieldLabel.Position = [5 49 37 22];
      app.NstepEditFieldLabel.Text = 'Nstep';

      % Create NstepEditField
      app.NstepEditField = uieditfield(app.DispersionfromEnergyScanPanel, 'numeric');
      app.NstepEditField.ValueChangedFcn = createCallbackFcn(app, @NstepEditFieldValueChanged, true);
      app.NstepEditField.Position = [56 49 59 22];
      app.NstepEditField.Value = 10;

      % Create DispScan_minunit
      app.DispScan_minunit = uilabel(app.DispersionfromEnergyScanPanel);
      app.DispScan_minunit.Position = [123 105 37 22];
      app.DispScan_minunit.Text = 'MeV';

      % Create DispScan_maxunit
      app.DispScan_maxunit = uilabel(app.DispersionfromEnergyScanPanel);
      app.DispScan_maxunit.Position = [123 77 37 22];
      app.DispScan_maxunit.Text = 'MeV';

      % Create MIATab
      app.MIATab = uitab(app.TabGroup);
      app.MIATab.Title = 'MIA';

      % Create UIAxes6
      app.UIAxes6 = uiaxes(app.MIATab);
      title(app.UIAxes6, '')
      xlabel(app.UIAxes6, 'X')
      ylabel(app.UIAxes6, 'Y')
      app.UIAxes6.FontSize = 14;
      app.UIAxes6.Position = [13 277 864 266];

      % Create PlotOptionPanel
      app.PlotOptionPanel = uipanel(app.MIATab);
      app.PlotOptionPanel.Title = 'Plot Option';
      app.PlotOptionPanel.Position = [887 307 141 104];

      % Create DropDown_2
      app.DropDown_2 = uidropdown(app.PlotOptionPanel);
      app.DropDown_2.Items = {'SingularValues', 'EigenValue', 'EigenVector', 'FFT', 'DofF', 'KickAnalysis'};
      app.DropDown_2.ValueChangedFcn = createCallbackFcn(app, @DropDown_2ValueChanged, true);
      app.DropDown_2.Position = [9 46 124 22];
      app.DropDown_2.Value = 'SingularValues';

      % Create NmodesLabel
      app.NmodesLabel = uilabel(app.PlotOptionPanel);
      app.NmodesLabel.HorizontalAlignment = 'right';
      app.NmodesLabel.Position = [3 9 62 22];
      app.NmodesLabel.Text = 'N mode(s)';

      % Create NmodesEditField
      app.NmodesEditField = uieditfield(app.PlotOptionPanel, 'numeric');
      app.NmodesEditField.Limits = [1 100];
      app.NmodesEditField.ValueDisplayFormat = '%d';
      app.NmodesEditField.ValueChangedFcn = createCallbackFcn(app, @NmodesEditFieldValueChanged, true);
      app.NmodesEditField.Position = [74 9 54 22];
      app.NmodesEditField.Value = 10;

      % Create CorrelatePanel
      app.CorrelatePanel = uipanel(app.MIATab);
      app.CorrelatePanel.Title = 'Correlate';
      app.CorrelatePanel.Position = [889 103 141 190];

      % Create DropDown_3
      app.DropDown_3 = uidropdown(app.CorrelatePanel);
      app.DropDown_3.Items = {'E_DL1', 'E_BC11', 'E_BC14', 'E_BC20'};
      app.DropDown_3.Position = [14 136 113 22];
      app.DropDown_3.Value = 'E_DL1';

      % Create rEditFieldLabel
      app.rEditFieldLabel = uilabel(app.CorrelatePanel);
      app.rEditFieldLabel.HorizontalAlignment = 'right';
      app.rEditFieldLabel.Position = [18 70 25 22];
      app.rEditFieldLabel.Text = 'r ';

      % Create rEditField
      app.rEditField = uieditfield(app.CorrelatePanel, 'text');
      app.rEditField.Editable = 'off';
      app.rEditField.Position = [55 70 69 22];

      % Create pEditFieldLabel
      app.pEditFieldLabel = uilabel(app.CorrelatePanel);
      app.pEditFieldLabel.HorizontalAlignment = 'right';
      app.pEditFieldLabel.Position = [16 41 25 22];
      app.pEditFieldLabel.Text = 'p';

      % Create pEditField
      app.pEditField = uieditfield(app.CorrelatePanel, 'text');
      app.pEditField.Editable = 'off';
      app.pEditField.Position = [55 41 69 22];

      % Create PlotButton
      app.PlotButton = uibutton(app.CorrelatePanel, 'push');
      app.PlotButton.ButtonPushedFcn = createCallbackFcn(app, @PlotButtonPushed, true);
      app.PlotButton.Position = [26 10 100 23];
      app.PlotButton.Text = 'Plot';

      % Create modeEditFieldLabel
      app.modeEditFieldLabel = uilabel(app.CorrelatePanel);
      app.modeEditFieldLabel.HorizontalAlignment = 'right';
      app.modeEditFieldLabel.Position = [5 100 36 22];
      app.modeEditFieldLabel.Text = 'mode';

      % Create modeEditField
      app.modeEditField = uieditfield(app.CorrelatePanel, 'text');
      app.modeEditField.Editable = 'off';
      app.modeEditField.Position = [55 100 69 22];

      % Create UIAxes6_2
      app.UIAxes6_2 = uiaxes(app.MIATab);
      title(app.UIAxes6_2, '')
      xlabel(app.UIAxes6_2, 'X')
      ylabel(app.UIAxes6_2, 'Y')
      app.UIAxes6_2.FontSize = 14;
      app.UIAxes6_2.Position = [11 9 864 266];

      % Create RegionSelectPanel
      app.RegionSelectPanel = uipanel(app.FACETIIOrbitToolconfignoneUIFigure);
      app.RegionSelectPanel.Title = 'Region Select';
      app.RegionSelectPanel.Position = [187 663 1043 66];

      % Create GridLayout
      app.GridLayout = uigridlayout(app.RegionSelectPanel);
      app.GridLayout.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
      app.GridLayout.RowHeight = {'2x'};

      % Create INJButton
      app.INJButton = uibutton(app.GridLayout, 'state');
      app.INJButton.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.INJButton.Interruptible = 'off';
      app.INJButton.Text = 'INJ';
      app.INJButton.Layout.Row = 1;
      app.INJButton.Layout.Column = 1;
      app.INJButton.Value = true;

      % Create L0Button
      app.L0Button = uibutton(app.GridLayout, 'state');
      app.L0Button.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.L0Button.Interruptible = 'off';
      app.L0Button.Text = 'L0';
      app.L0Button.Layout.Row = 1;
      app.L0Button.Layout.Column = 2;
      app.L0Button.Value = true;

      % Create DL1Button
      app.DL1Button = uibutton(app.GridLayout, 'state');
      app.DL1Button.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.DL1Button.Interruptible = 'off';
      app.DL1Button.Text = 'DL1';
      app.DL1Button.Layout.Row = 1;
      app.DL1Button.Layout.Column = 3;
      app.DL1Button.Value = true;

      % Create L1Button
      app.L1Button = uibutton(app.GridLayout, 'state');
      app.L1Button.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.L1Button.Interruptible = 'off';
      app.L1Button.Text = 'L1';
      app.L1Button.Layout.Row = 1;
      app.L1Button.Layout.Column = 4;
      app.L1Button.Value = true;

      % Create BC11Button
      app.BC11Button = uibutton(app.GridLayout, 'state');
      app.BC11Button.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.BC11Button.Interruptible = 'off';
      app.BC11Button.Text = 'BC11';
      app.BC11Button.Layout.Row = 1;
      app.BC11Button.Layout.Column = 5;
      app.BC11Button.Value = true;

      % Create L2Button
      app.L2Button = uibutton(app.GridLayout, 'state');
      app.L2Button.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.L2Button.Interruptible = 'off';
      app.L2Button.Text = 'L2';
      app.L2Button.Layout.Row = 1;
      app.L2Button.Layout.Column = 6;
      app.L2Button.Value = true;

      % Create BC14Button
      app.BC14Button = uibutton(app.GridLayout, 'state');
      app.BC14Button.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.BC14Button.Interruptible = 'off';
      app.BC14Button.Text = 'BC14';
      app.BC14Button.Layout.Row = 1;
      app.BC14Button.Layout.Column = 7;
      app.BC14Button.Value = true;

      % Create L3Button
      app.L3Button = uibutton(app.GridLayout, 'state');
      app.L3Button.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.L3Button.Interruptible = 'off';
      app.L3Button.Text = 'L3';
      app.L3Button.Layout.Row = 1;
      app.L3Button.Layout.Column = 8;
      app.L3Button.Value = true;

      % Create BC20Button
      app.BC20Button = uibutton(app.GridLayout, 'state');
      app.BC20Button.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.BC20Button.Interruptible = 'off';
      app.BC20Button.Text = 'BC20';
      app.BC20Button.Layout.Row = 1;
      app.BC20Button.Layout.Column = 9;
      app.BC20Button.Value = true;

      % Create FFSButton
      app.FFSButton = uibutton(app.GridLayout, 'state');
      app.FFSButton.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.FFSButton.Interruptible = 'off';
      app.FFSButton.Text = 'FFS';
      app.FFSButton.Layout.Row = 1;
      app.FFSButton.Layout.Column = 10;
      app.FFSButton.Value = true;

      % Create SPECTButton
      app.SPECTButton = uibutton(app.GridLayout, 'state');
      app.SPECTButton.ValueChangedFcn = createCallbackFcn(app, @INJButtonValueChanged, true);
      app.SPECTButton.Interruptible = 'off';
      app.SPECTButton.Text = 'SPECT';
      app.SPECTButton.Layout.Row = 1;
      app.SPECTButton.Layout.Column = 11;
      app.SPECTButton.Value = true;

      % Create AcquireButton
      app.AcquireButton = uibutton(app.FACETIIOrbitToolconfignoneUIFigure, 'push');
      app.AcquireButton.ButtonPushedFcn = createCallbackFcn(app, @AcquireButtonPushed, true);
      app.AcquireButton.Interruptible = 'off';
      app.AcquireButton.Position = [187 17 109 37];
      app.AcquireButton.Text = 'Acquire';

      % Create NPulseEditFieldLabel
      app.NPulseEditFieldLabel = uilabel(app.FACETIIOrbitToolconfignoneUIFigure);
      app.NPulseEditFieldLabel.HorizontalAlignment = 'right';
      app.NPulseEditFieldLabel.Position = [308 24 51 22];
      app.NPulseEditFieldLabel.Text = 'N Pulse:';

      % Create NPulseEditField
      app.NPulseEditField = uieditfield(app.FACETIIOrbitToolconfignoneUIFigure, 'numeric');
      app.NPulseEditField.ValueDisplayFormat = '%d';
      app.NPulseEditField.ValueChangedFcn = createCallbackFcn(app, @NPulseEditFieldValueChanged, true);
      app.NPulseEditField.Position = [374 24 47 22];
      app.NPulseEditField.Value = 50;

      % Create PlotRangeDropDownLabel
      app.PlotRangeDropDownLabel = uilabel(app.FACETIIOrbitToolconfignoneUIFigure);
      app.PlotRangeDropDownLabel.HorizontalAlignment = 'right';
      app.PlotRangeDropDownLabel.Position = [703 23 66 22];
      app.PlotRangeDropDownLabel.Text = 'Plot Range';

      % Create PlotRangeDropDown
      app.PlotRangeDropDown = uidropdown(app.FACETIIOrbitToolconfignoneUIFigure);
      app.PlotRangeDropDown.Items = {'Auto', '5 mm', '4 mm', '3 mm', '2 mm', '1mm'};
      app.PlotRangeDropDown.ItemsData = {'0', '5', '4', '3', '2', '1'};
      app.PlotRangeDropDown.ValueChangedFcn = createCallbackFcn(app, @PlotRangeDropDownValueChanged, true);
      app.PlotRangeDropDown.Position = [784 23 100 22];
      app.PlotRangeDropDown.Value = '0';

      % Create NReadEditFieldLabel
      app.NReadEditFieldLabel = uilabel(app.FACETIIOrbitToolconfignoneUIFigure);
      app.NReadEditFieldLabel.HorizontalAlignment = 'right';
      app.NReadEditFieldLabel.Position = [436 24 47 22];
      app.NReadEditFieldLabel.Text = 'N Read';

      % Create NReadEditField
      app.NReadEditField = uieditfield(app.FACETIIOrbitToolconfignoneUIFigure, 'numeric');
      app.NReadEditField.ValueDisplayFormat = '%d';
      app.NReadEditField.Editable = 'off';
      app.NReadEditField.Position = [498 24 47 22];

      % Create UpdateLiveModelButton
      app.UpdateLiveModelButton = uibutton(app.FACETIIOrbitToolconfignoneUIFigure, 'push');
      app.UpdateLiveModelButton.ButtonPushedFcn = createCallbackFcn(app, @UpdateLiveModelButtonPushed, true);
      app.UpdateLiveModelButton.Interruptible = 'off';
      app.UpdateLiveModelButton.Position = [1032 16 118 34];
      app.UpdateLiveModelButton.Text = 'Update Live Model';

      % Create UseBufferedDataCheckBox
      app.UseBufferedDataCheckBox = uicheckbox(app.FACETIIOrbitToolconfignoneUIFigure);
      app.UseBufferedDataCheckBox.ValueChangedFcn = createCallbackFcn(app, @UseBufferedDataCheckBoxValueChanged, true);
      app.UseBufferedDataCheckBox.Text = 'Use Buffered Data?';
      app.UseBufferedDataCheckBox.Position = [565 23 129 22];
      app.UseBufferedDataCheckBox.Value = true;

      % Create LogbookButton
      app.LogbookButton = uibutton(app.FACETIIOrbitToolconfignoneUIFigure, 'push');
      app.LogbookButton.ButtonPushedFcn = createCallbackFcn(app, @LogbookButtonPushed, true);
      app.LogbookButton.Icon = 'logbook.gif';
      app.LogbookButton.Position = [1175 8 53 50];
      app.LogbookButton.Text = '';

      % Show the figure after all components are created
      app.FACETIIOrbitToolconfignoneUIFigure.Visible = 'on';
    end
  end

  % App creation and deletion
  methods (Access = public)

    % Construct app
    function app = F2_Orbit_exported

      % Create UIFigure and components
      createComponents(app)

      % Register the app with App Designer
      registerApp(app, app.FACETIIOrbitToolconfignoneUIFigure)

      % Execute the startup function
      runStartupFcn(app, @startupFcn)

      if nargout == 0
        clear app
      end
    end

    % Code that executes before app deletion
    function delete(app)

      % Delete UIFigure when app is deleted
      delete(app.FACETIIOrbitToolconfignoneUIFigure)
    end
  end
end