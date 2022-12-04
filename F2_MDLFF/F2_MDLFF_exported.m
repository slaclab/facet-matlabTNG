classdef F2_MDLFF_exported < matlab.apps.AppBase

  % Properties that correspond to app components
  properties (Access = public)
    F2_MDLFFUIFigure              matlab.ui.Figure
    Panel                         matlab.ui.container.Panel
    GridLayout                    matlab.ui.container.GridLayout
    S11mdl                        matlab.ui.control.NumericEditField
    S12mdl                        matlab.ui.control.NumericEditField
    S13mdl                        matlab.ui.control.NumericEditField
    S14mdl                        matlab.ui.control.NumericEditField
    S15mdl                        matlab.ui.control.NumericEditField
    S16mdl                        matlab.ui.control.NumericEditField
    S17mdl                        matlab.ui.control.NumericEditField
    S18mdl                        matlab.ui.control.NumericEditField
    S19mdl                        matlab.ui.control.NumericEditField
    EditField_10                  matlab.ui.control.EditField
    EditField_11                  matlab.ui.control.EditField
    EditField_12                  matlab.ui.control.EditField
    EditField_13                  matlab.ui.control.EditField
    EditField_14                  matlab.ui.control.EditField
    EditField_15                  matlab.ui.control.EditField
    EditField_16                  matlab.ui.control.EditField
    EditField_17                  matlab.ui.control.EditField
    EditField_18                  matlab.ui.control.EditField
    FeedforwardstatusLampLabel    matlab.ui.control.Label
    Lamp                          matlab.ui.control.Lamp
    STOPButton                    matlab.ui.control.Button
    STARTButton                   matlab.ui.control.Button
    ModelResponseUsedatafromt0t1dataformatyrmnthdayhrminsecPanel  matlab.ui.container.Panel
    GridLayout2                   matlab.ui.container.GridLayout
    t0Button                      matlab.ui.control.Button
    t0_yr                         matlab.ui.control.NumericEditField
    t0_mnth                       matlab.ui.control.NumericEditField
    t0_day                        matlab.ui.control.NumericEditField
    t0_hr                         matlab.ui.control.NumericEditField
    t0_min                        matlab.ui.control.NumericEditField
    t0_sec                        matlab.ui.control.NumericEditField
    t1_yr                         matlab.ui.control.NumericEditField
    t1_mnth                       matlab.ui.control.NumericEditField
    t1_day                        matlab.ui.control.NumericEditField
    t1_hr                         matlab.ui.control.NumericEditField
    t1_min                        matlab.ui.control.NumericEditField
    t1_sec                        matlab.ui.control.NumericEditField
    t1Button                      matlab.ui.control.Button
    CopyToTrainingButton          matlab.ui.control.Button
    ShowData                      matlab.ui.control.Button
    ModelSelectionTrainingParametersPanel  matlab.ui.container.Panel
    DropDown                      matlab.ui.control.DropDown
    Train                         matlab.ui.control.Button
    SETDEFAULTButton              matlab.ui.control.Button
    NewButton                     matlab.ui.control.Button
    PasswordHTML                  matlab.ui.control.HTML
    Image                         matlab.ui.control.Image
    ModelTypeButtonGroup          matlab.ui.container.ButtonGroup
    LinearButton                  matlab.ui.control.RadioButton
    NNButton                      matlab.ui.control.RadioButton
    ShowModelTrainingDataButton   matlab.ui.control.Button
    Spinner                       matlab.ui.control.Spinner
    ModelDataInputSelectionPanel  matlab.ui.container.Panel
    GridLayout3                   matlab.ui.container.GridLayout
    PressureCheckBox              matlab.ui.control.CheckBox
    MCCTempCheckBox               matlab.ui.control.CheckBox
    S20TempCheckBox               matlab.ui.control.CheckBox
    MDL_temp_11CheckBox           matlab.ui.control.CheckBox
    MDL_temp_12CheckBox           matlab.ui.control.CheckBox
    MDL_temp_13CheckBox           matlab.ui.control.CheckBox
    MDL_temp_14CheckBox           matlab.ui.control.CheckBox
    MDL_temp_15CheckBox           matlab.ui.control.CheckBox
    MDL_temp_16CheckBox           matlab.ui.control.CheckBox
    MDL_temp_17CheckBox           matlab.ui.control.CheckBox
    MDL_temp_18CheckBox           matlab.ui.control.CheckBox
    MDL_temp_19CheckBox           matlab.ui.control.CheckBox
    TempLimitsdegFEditFieldLabel  matlab.ui.control.Label
    tlim1                         matlab.ui.control.NumericEditField
    tlim2                         matlab.ui.control.NumericEditField
    plim2                         matlab.ui.control.NumericEditField
    PressureLimitsmbarEditFieldLabel  matlab.ui.control.Label
    plim1                         matlab.ui.control.NumericEditField
    TrainingDataUsedatafromt0t1dataformatyrmnthdayhrminsecPanel  matlab.ui.container.Panel
    GridLayout2_2                 matlab.ui.container.GridLayout
    t0Button_2                    matlab.ui.control.Button
    t0_yr_2                       matlab.ui.control.NumericEditField
    t0_mnth_2                     matlab.ui.control.NumericEditField
    t0_day_2                      matlab.ui.control.NumericEditField
    t0_hr_2                       matlab.ui.control.NumericEditField
    t0_min_2                      matlab.ui.control.NumericEditField
    t0_sec_2                      matlab.ui.control.NumericEditField
    t1_yr_2                       matlab.ui.control.NumericEditField
    t1_mnth_2                     matlab.ui.control.NumericEditField
    t1_day_2                      matlab.ui.control.NumericEditField
    t1_hr_2                       matlab.ui.control.NumericEditField
    t1_min_2                      matlab.ui.control.NumericEditField
    t1_sec_2                      matlab.ui.control.NumericEditField
    t1Button_2                    matlab.ui.control.Button
    CopyToModelRespButton         matlab.ui.control.Button
    SaveButton                    matlab.ui.control.Button
    EditField_mdlname             matlab.ui.control.EditField
  end

  
  properties (Access = private)
    islocked logical = true % Locked for storing new model data
    mdlname string % default model name
    mdldate(2,6)
    mdldate_train(2,6)
    fhan
  end
  
  properties (Access = public)
    pvlist % EPICS PVs
    MDL % MDLFFApp object
  end
  

  % Callbacks that handle component events
  methods (Access = private)

    % Code that executes after component creation
    function startupFcn(app)
      app.mdlname = string(lcaGet('SIOC:SYS1:ML01:AO488.DESC')) ;
      app.EditField_mdlname.Value = app.mdlname ;
      context = PV.Initialize(PVtype.EPICS) ;
      app.pvlist = PV(context,'name',"MDL_stat",'pvname',"F2:WATCHER:MDLFF_STAT",'monitor',true,'guihan',app.Lamp);
      run(app.pvlist,true,0.1);
      mdls = split(string([dir(F2_common.confdir + "/F2_MDLFF/*.mat").name]),".mat") ;
      app.DropDown.Items = mdls(1:end-1) ;
      app.DropDown.Value = app.mdlname ;
      app.DropDownValueChanged;
      date = app.MDL.ModelDate ;
      app.t0_yr.Value = date(1,1) ; app.t0_mnth.Value = date(1,2) ; app.t0_day.Value = date(1,3) ; app.t0_hr.Value = date(1,4) ; app.t0_min.Value = date(1,5); app.t0_sec.Value = date(1,6) ;
      app.t1_yr.Value = date(2,1) ; app.t1_mnth.Value = date(2,2) ; app.t1_day.Value = date(2,3) ; app.t1_hr.Value = date(2,4) ; app.t1_min.Value = date(2,5); app.t1_sec.Value = date(2,6) ;
      app.mdldate_train = app.MDL.ModelDate ;
    end

    % Data changed function: PasswordHTML
    function PasswordHTMLDataChanged(app, event)
      % Generate password with : echo "fixedforever" | openssl aes-256-cbc -a -salt -pass pass:somepassword
      password = app.PasswordHTML.Data;
      [~,spass]=system(sprintf('echo "U2FsdGVkX19s9rbZLfNp+wN+RwfUtyMC1WzwCaNnPNc=" | openssl aes-256-cbc -d -a -pass pass:%s',password));
      if string(strip(spass)) == "fixedforever"
        app.Image.ImageSource = 'unlock-icon.svg' ;
        app.islocked=false;
        app.SETDEFAULTButton.Enable = true ;
        drawnow;
      else
        app.Image.ImageSource = 'lock-icon.svg' ;
        app.islocked=true;
        app.SETDEFAULTButton.Enable = false ;
        drawnow
      end
    end

    % Value changed function: DropDown
    function DropDownValueChanged(app, event)
      value = string(app.DropDown.Value) ;
      app.MDL = MDLFFApp(value);
      for isec=11:19
        app.("S"+isec+"mdl").Value = app.MDL.mode(isec-10) ;
      end
      date = app.MDL.ModelDate ;
      app.t0_yr_2.Value = date(1,1) ; app.t0_mnth_2.Value = date(1,2) ; app.t0_day_2.Value = date(1,3) ; app.t0_hr_2.Value = date(1,4) ; app.t0_min_2.Value = date(1,5); app.t0_sec_2.Value = date(1,6) ;
      app.t1_yr_2.Value = date(2,1) ; app.t1_mnth_2.Value = date(2,2) ; app.t1_day_2.Value = date(2,3) ; app.t1_hr_2.Value = date(2,4) ; app.t1_min_2.Value = date(2,5); app.t1_sec_2.Value = date(2,6) ;
      parstr = ["Pressure" "MCCTemp" "S20Temp" "MDL_temp_11" "MDL_temp_12" "MDL_temp_13" "MDL_temp_14" "MDL_temp_15" "MDL_temp_16" "MDL_temp_17" "MDL_temp_18" "MDL_temp_19"] ;
      for istr=1:length(parstr)
        if ismember(parstr(istr),app.MDL.EnvOmit)
          app.(parstr(istr)+"CheckBox").Value = false ;
        else
          app.(parstr(istr)+"CheckBox").Value = true ;
        end
      end
      if app.MDL.RegressionModel == "Linear"
        app.LinearButton.Value = true ;
      else
        app.NNButton.Value = true ;
      end
      app.tlim1.Value = app.MDL.TempLimits(1); app.tlim2.Value = app.MDL.TempLimits(2) ;
      app.plim1.Value = app.MDL.PresLimits(1); app.plim2.Value = app.MDL.PresLimits(2) ;
    end

    % Button pushed function: NewButton
    function NewButtonPushed(app, event)
      mdls = string(app.DropDown.Items) ;
      fn = uiputfile(F2_common.confdir+"/F2_MDLFF"+"/*.mat", 'New Model File');
      if fn
        mdls(end+1) = regexprep(fn,".mat$","") ;
        app.DropDown.Items = mdls ;
        app.DropDown.Value = mdls(end) ;
      end
    end

    % Selection changed function: ModelTypeButtonGroup
    function ModelTypeButtonGroupSelectionChanged(app, event)
      selectedButton = app.ModelTypeButtonGroup.SelectedObject;
      switch selectedButton
        case app.LinearButton
          app.MDL.RegressionModel = "Linear" ;
        otherwise
          app.MDL.RegressionModel = "NN" ;
      end
    end

    % Button pushed function: Train
    function TrainPushed(app, event)
      app.Train.Enable = false ;drawnow;
      try
        if ~isequal(app.MDL.ModelDate,app.mdldate_train)
          app.Train.Text = 'Get Archive Data' ;drawnow;
          app.MDL.GetArchiveData(app.MDL.ModelDate); app.MDL.ProcArchiveData;
        end
        app.Train.Text = 'Training Model' ;drawnow;
        app.MDL.Train ;
      catch ME
        errordlg('Training Failed','Training Failed');
        app.Train.Enable = true ;drawnow;
        app.Train.Text = 'Train - Push to Start' ;drawnow;
        throw(ME);
      end
      app.Train.Enable = true ;drawnow;
      app.Train.Text = 'Train - Push to Start' ;drawnow;
      app.mdldate_train = app.MDL.ModelDate ;
    end

    % Button pushed function: SETDEFAULTButton
    function SETDEFAULTButtonPushed(app, event)
      fn = fullfile(F2_common.confdir,"F2_MDLFF",string(app.DropDown.Value)+".mat") ;
      if exist(fn,'file')
        a=questdlg('Model file already exists, overwrite?','Overwrite Model?','Yes','No','Cancel','Cancel');
        if ~strcmp(a,'Yes')
          return
        end
      end
      MDL = app.MDL ; %#ok<ADPROPLC>
      save(fn,'MDL');
      app.EditField_mdlname.Value = app.DropDown.Value ;
      app.mdlname = app.DropDown.Value ;
      lcaPut('SIOC:SYS1:ML01:AO488.DESC',char(app.mdlname)) ;
      msgbox('MDLFF Service must be restarted for new model to be implemented');
    end

    % Button pushed function: t0Button
    function t0ButtonPushed(app, event)
      date = uigetdate ;
      if isempty(date); return; end
      date = datevec(date) ;
      app.t0_yr.Value = date(1,1) ; app.t0_mnth.Value = date(1,2) ; app.t0_day.Value = date(1,3) ; app.t0_hr.Value = date(1,4) ; app.t0_min.Value = date(1,5); app.t0_sec.Value = date(1,6) ;
      app.mdldate(1,:) = date ;
    end

    % Button pushed function: t1Button
    function t1ButtonPushed(app, event)
      date = uigetdate ;
      if isempty(date); return; end
      date = datevec(date) ;
      app.t1_yr.Value = date(1,1) ; app.t1_mnth.Value = date(1,2) ; app.t1_day.Value = date(1,3) ; app.t1_hr.Value = date(1,4) ; app.t1_min.Value = date(1,5); app.t1_sec.Value = date(1,6) ;
      app.mdldate(2,:) = date ;
    end

    % Value changed function: S11mdl, S12mdl, S13mdl, S14mdl, 
    % S15mdl, S16mdl, S17mdl, S18mdl, S19mdl
    function S11mdlValueChanged(app, event)
      app.MDL.mode = [app.S11mdl.Value app.S12mdl.Value app.S13mdl.Value app.S14mdl.Value app.S15mdl.Value app.S16mdl.Value app.S17mdl.Value app.S18mdl.Value app.S19mdl.Value] ;
    end

    % Value changed function: t0_day, t0_hr, t0_min, t0_mnth, 
    % t0_sec, t0_yr, t1_day, t1_hr, t1_min, t1_mnth, t1_sec, t1_yr
    function t0_yrValueChanged(app, event)
      date = [app.t0_yr.Value app.t0_mnth.Value app.t0_day.Value app.t0_hr.Value app.t0_min.Value app.t0_sec.Value;
        app.t1_yr.Value app.t1_mnth.Value app.t1_day.Value app.t1_hr.Value app.t1_min.Value app.t1_sec.Value ] ;
      app.mdldate = date ;
    end

    % Value changed function: PressureCheckBox
    function PressureCheckBoxValueChanged(app, event)
      value = app.PressureCheckBox.Value;
      if ~value && ~ismember("Pressure",app.MDL.EnvOmit)
        app.MDL.EnvOmit(end+1) = "Pressure" ;
      end
    end

    % Value changed function: MCCTempCheckBox
    function MCCTempCheckBoxValueChanged(app, event)
      value = app.MCCTempCheckBox.Value;
      if ~value && ~ismember("MCCTemp",app.MDL.EnvOmit)
        app.MDL.EnvOmit(end+1) = "MCCTemp" ;
      end
    end

    % Value changed function: S20TempCheckBox
    function S20TempCheckBoxValueChanged(app, event)
      value = app.S20TempCheckBox.Value;
      if ~value && ~ismember("S20Temp",app.MDL.EnvOmit)
        app.MDL.EnvOmit(end+1) = "S20Temp" ;
      end
    end

    % Value changed function: MDL_temp_11CheckBox
    function MDL_temp_11CheckBoxValueChanged(app, event)
      value = app.MDL_temp_11CheckBox.Value;
      if ~value && ~ismember("MDL_temp_11",app.MDL.EnvOmit)
        app.MDL.EnvOmit(end+1) = "MDL_temp_11" ;
      end
    end

    % Value changed function: MDL_temp_12CheckBox
    function MDL_temp_12CheckBoxValueChanged(app, event)
      value = app.MDL_temp_12CheckBox.Value;
      if ~value && ~ismember("MDL_temp_12",app.MDL.EnvOmit)
        app.MDL.EnvOmit(end+1) = "MDL_temp_12" ;
      end
    end

    % Value changed function: MDL_temp_13CheckBox
    function MDL_temp_13CheckBoxValueChanged(app, event)
      value = app.MDL_temp_13CheckBox.Value;
      if ~value && ~ismember("MDL_temp_13",app.MDL.EnvOmit)
        app.MDL.EnvOmit(end+1) = "MDL_temp_13" ;
      end
    end

    % Value changed function: MDL_temp_14CheckBox
    function MDL_temp_14CheckBoxValueChanged(app, event)
      value = app.MDL_temp_14CheckBox.Value;
      if ~value && ~ismember("MDL_temp_14",app.MDL.EnvOmit)
        app.MDL.EnvOmit(end+1) = "MDL_temp_14" ;
      end
    end

    % Value changed function: MDL_temp_15CheckBox
    function MDL_temp_15CheckBoxValueChanged(app, event)
      value = app.MDL_temp_15CheckBox.Value;
      if ~value && ~ismember("MDL_temp_15",app.MDL.EnvOmit)
        app.MDL.EnvOmit(end+1) = "MDL_temp_15" ;
      end
    end

    % Value changed function: MDL_temp_16CheckBox
    function MDL_temp_16CheckBoxValueChanged(app, event)
      value = app.MDL_temp_16CheckBox.Value;
      if ~value && ~ismember("MDL_temp_16",app.MDL.EnvOmit)
        app.MDL.EnvOmit(end+1) = "MDL_temp_16" ;
      end
    end

    % Value changed function: MDL_temp_17CheckBox
    function MDL_temp_17CheckBoxValueChanged(app, event)
      value = app.MDL_temp_17CheckBox.Value;
      if ~value && ~ismember("MDL_temp_17",app.MDL.EnvOmit)
        app.MDL.EnvOmit(end+1) = "MDL_temp_17" ;
      end
    end

    % Value changed function: MDL_temp_18CheckBox
    function MDL_temp_18CheckBoxValueChanged(app, event)
      value = app.MDL_temp_18CheckBox.Value;
      if ~value && ~ismember("MDL_temp_18",app.MDL.EnvOmit)
        app.MDL.EnvOmit(end+1) = "MDL_temp_18" ;
      end
    end

    % Value changed function: MDL_temp_19CheckBox
    function MDL_temp_19CheckBoxValueChanged(app, event)
      value = app.MDL_temp_19CheckBox.Value;
      if ~value && ~ismember("MDL_temp_19",app.MDL.EnvOmit)
        app.MDL.EnvOmit(end+1) = "MDL_temp_19" ;
      end
    end

    % Button pushed function: t0Button_2
    function t0Button_2Pushed(app, event)
      date = uigetdate ;
      if isempty(date); return; end
      date = datevec(date) ;
      app.t0_yr_2.Value = date(1,1) ; app.t0_mnth_2.Value = date(1,2) ; app.t0_day_2.Value = date(1,3) ; app.t0_hr_2.Value = date(1,4) ; app.t0_min_2.Value = date(1,5); app.t0_sec_2.Value = date(1,6) ;
      app.MDL.ModelDate(1,:) = date ;
    end

    % Button pushed function: t1Button_2
    function t1Button_2Pushed(app, event)
      date = uigetdate ;
      if isempty(date); return; end
      date = datevec(date) ;
      app.t1_yr_2.Value = date(1,1) ; app.t1_mnth_2.Value = date(1,2) ; app.t1_day_2.Value = date(1,3) ; app.t1_hr_2.Value = date(1,4) ; app.t1_min_2.Value = date(1,5); app.t1_sec_2.Value = date(1,6) ;
      app.MDL.ModelDate(2,:) = date ;
    end

    % Button pushed function: CopyToModelRespButton
    function CopyToModelRespButtonPushed(app, event)
      app.t0_yr.Value = app.t0_yr_2.Value; app.t0_mnth.Value = app.t0_mnth_2.Value ; app.t0_day.Value = app.t0_day_2.Value ; app.t0_hr.Value=app.t0_hr_2.Value; app.t0_min.Value = app.t0_min_2.Value;app.t0_sec.Value=app.t0_sec_2.Value;
      app.t1_yr.Value = app.t1_yr_2.Value; app.t1_mnth.Value = app.t1_mnth_2.Value ; app.t1_day.Value = app.t1_day_2.Value ; app.t1_hr.Value=app.t1_hr_2.Value; app.t1_min.Value = app.t1_min_2.Value;app.t1_sec.Value=app.t1_sec_2.Value;
      app.t0_yrValueChanged();
    end

    % Button pushed function: CopyToTrainingButton
    function CopyToTrainingButtonPushed(app, event)
      app.t0_yr_2.Value = app.t0_yr.Value; app.t0_mnth_2.Value = app.t0_mnth.Value ; app.t0_day_2.Value = app.t0_day.Value ; app.t0_hr_2.Value=app.t0_hr.Value; app.t0_min_2.Value = app.t0_min.Value;app.t0_sec_2.Value=app.t0_sec.Value;
      app.t1_yr_2.Value = app.t1_yr.Value; app.t1_mnth_2.Value = app.t1_mnth.Value ; app.t1_day_2.Value = app.t1_day.Value ; app.t1_hr_2.Value=app.t1_hr.Value; app.t1_min_2.Value = app.t1_min.Value;app.t1_sec_2.Value=app.t1_sec.Value;
      app.t0_yr_2ValueChanged();
    end

    % Value changed function: tlim1
    function tlim1ValueChanged(app, event)
      value = app.tlim1.Value;
      app.MDL.TempLimits(1) = value ;
    end

    % Value changed function: tlim2
    function tlim2ValueChanged(app, event)
      value = app.tlim2.Value;
      app.MDL.TempLimits(2) = value ;
    end

    % Value changed function: plim1
    function plim1ValueChanged(app, event)
      value = app.plim1.Value;
      app.MDL.PresLimits(1) = value ;
    end

    % Value changed function: plim2
    function plim2ValueChanged(app, event)
      value = app.plim2.Value;
      app.MDL.PresLimits(2) = value ;
    end

    % Value changed function: t0_day_2, t0_hr_2, t0_min_2, 
    % t0_mnth_2, t0_sec_2, t0_yr_2, t1_day_2, t1_hr_2, t1_min_2, 
    % t1_mnth_2, t1_sec_2, t1_yr_2
    function t0_yr_2ValueChanged(app, event)
      date = [app.t0_yr_2.Value app.t0_mnth_2.Value app.t0_day_2.Value app.t0_hr_2.Value app.t0_min_2.Value app.t0_sec_2.Value;
        app.t1_yr_2.Value app.t1_mnth_2.Value app.t1_day_2.Value app.t1_hr_2.Value app.t1_min_2.Value app.t1_sec_2.Value ] ;
      app.MDL.ModelDate = date ;
    end

    % Button pushed function: ShowData
    function ShowDataPushed(app, event)
      app.ShowData.Enable = false; drawnow;
      try
        app.ShowData.Text = 'Get Data\nFrom Archiver' ; drawnow;
        app.MDL.PredictEval(app.mdldate);
      catch ME
        app.ShowData.Enable = true ;
        app.ShowData.Text = '' ;
        drawnow
        throw(ME);
      end
      app.ShowData.Enable = true ;
      app.ShowData.Text = '' ;
      drawnow
    end

    % Button pushed function: ShowModelTrainingDataButton
    function ShowModelTrainingDataButtonPushed(app, event)
      switch app.MDL.RegressionModel
        case "Linear"
          disp(app.MDL.regmodel{app.Spinner.Value}) ;
        otherwise
          view(app.MDL.regmodel{app.Spinner.Value});
      end
      app.fhan=app.MDL.plot("ArchiveData_"+app.Spinner.Value);
    end

    % Value changed function: Spinner
    function SpinnerValueChanged(app, event)
      app.fhan=app.MDL.plot("ArchiveData_"+app.Spinner.Value,app.fhan);
    end

    % Button pushed function: STOPButton
    function STOPButtonPushed(app, event)
      d1=pwd;
      system('cd /usr/local/facet/tools/matlabTNG/; ./killappw.sh F2_MDLFF');
      cd(d1);
    end

    % Button pushed function: STARTButton
    function STARTButtonPushed(app, event)
      d1=pwd;
      system('cd /usr/local/facet/tools/matlabTNG; ./runappw.sh F2_MDLFF');
      cd(d1);
    end

    % Button pushed function: SaveButton
    function SaveButtonPushed(app, event)
      if app.DropDown.Value == app.mdlname && app.islocked
        warndlg('Password required to overwrite default model','Password Required');
        return
      end
      fn = fullfile(F2_common.confdir,"F2_MDLFF",string(app.DropDown.Value)+".mat") ;
      if exist(fn,'file')
        a=questdlg('Model file already exists, overwrite?','Overwrite Model?','Yes','No','Cancel','Cancel');
        if ~strcmp(a,'Yes')
          return
        end
      end
      MDL = app.MDL ; %#ok<ADPROPLC>
      save(fn,'MDL');
    end
  end

  % Component initialization
  methods (Access = private)

    % Create UIFigure and components
    function createComponents(app)

      % Create F2_MDLFFUIFigure and hide until all components are created
      app.F2_MDLFFUIFigure = uifigure('Visible', 'off');
      app.F2_MDLFFUIFigure.Position = [100 100 860 571];
      app.F2_MDLFFUIFigure.Name = 'F2_MDLFF';

      % Create Panel
      app.Panel = uipanel(app.F2_MDLFFUIFigure);
      app.Panel.Title = 'Feed-forward Sector Action [-1 : compute 0 : use own sector model >=11 : use that sector''s model]';
      app.Panel.Position = [16 433 826 89];

      % Create GridLayout
      app.GridLayout = uigridlayout(app.Panel);
      app.GridLayout.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
      app.GridLayout.RowHeight = {'0.8x', '1x'};

      % Create S11mdl
      app.S11mdl = uieditfield(app.GridLayout, 'numeric');
      app.S11mdl.Limits = [-1 19];
      app.S11mdl.ValueDisplayFormat = '%d';
      app.S11mdl.ValueChangedFcn = createCallbackFcn(app, @S11mdlValueChanged, true);
      app.S11mdl.HorizontalAlignment = 'center';
      app.S11mdl.Layout.Row = 2;
      app.S11mdl.Layout.Column = 1;

      % Create S12mdl
      app.S12mdl = uieditfield(app.GridLayout, 'numeric');
      app.S12mdl.Limits = [-1 19];
      app.S12mdl.ValueDisplayFormat = '%d';
      app.S12mdl.ValueChangedFcn = createCallbackFcn(app, @S11mdlValueChanged, true);
      app.S12mdl.HorizontalAlignment = 'center';
      app.S12mdl.Layout.Row = 2;
      app.S12mdl.Layout.Column = 2;

      % Create S13mdl
      app.S13mdl = uieditfield(app.GridLayout, 'numeric');
      app.S13mdl.Limits = [-1 19];
      app.S13mdl.ValueDisplayFormat = '%d';
      app.S13mdl.ValueChangedFcn = createCallbackFcn(app, @S11mdlValueChanged, true);
      app.S13mdl.HorizontalAlignment = 'center';
      app.S13mdl.Layout.Row = 2;
      app.S13mdl.Layout.Column = 3;

      % Create S14mdl
      app.S14mdl = uieditfield(app.GridLayout, 'numeric');
      app.S14mdl.Limits = [-1 19];
      app.S14mdl.ValueDisplayFormat = '%d';
      app.S14mdl.ValueChangedFcn = createCallbackFcn(app, @S11mdlValueChanged, true);
      app.S14mdl.HorizontalAlignment = 'center';
      app.S14mdl.Layout.Row = 2;
      app.S14mdl.Layout.Column = 4;

      % Create S15mdl
      app.S15mdl = uieditfield(app.GridLayout, 'numeric');
      app.S15mdl.Limits = [-1 19];
      app.S15mdl.ValueDisplayFormat = '%d';
      app.S15mdl.ValueChangedFcn = createCallbackFcn(app, @S11mdlValueChanged, true);
      app.S15mdl.HorizontalAlignment = 'center';
      app.S15mdl.Layout.Row = 2;
      app.S15mdl.Layout.Column = 5;

      % Create S16mdl
      app.S16mdl = uieditfield(app.GridLayout, 'numeric');
      app.S16mdl.Limits = [-1 19];
      app.S16mdl.ValueDisplayFormat = '%d';
      app.S16mdl.ValueChangedFcn = createCallbackFcn(app, @S11mdlValueChanged, true);
      app.S16mdl.HorizontalAlignment = 'center';
      app.S16mdl.Layout.Row = 2;
      app.S16mdl.Layout.Column = 6;

      % Create S17mdl
      app.S17mdl = uieditfield(app.GridLayout, 'numeric');
      app.S17mdl.Limits = [-1 19];
      app.S17mdl.ValueDisplayFormat = '%d';
      app.S17mdl.ValueChangedFcn = createCallbackFcn(app, @S11mdlValueChanged, true);
      app.S17mdl.HorizontalAlignment = 'center';
      app.S17mdl.Layout.Row = 2;
      app.S17mdl.Layout.Column = 7;

      % Create S18mdl
      app.S18mdl = uieditfield(app.GridLayout, 'numeric');
      app.S18mdl.Limits = [-1 19];
      app.S18mdl.ValueDisplayFormat = '%d';
      app.S18mdl.ValueChangedFcn = createCallbackFcn(app, @S11mdlValueChanged, true);
      app.S18mdl.HorizontalAlignment = 'center';
      app.S18mdl.Layout.Row = 2;
      app.S18mdl.Layout.Column = 8;

      % Create S19mdl
      app.S19mdl = uieditfield(app.GridLayout, 'numeric');
      app.S19mdl.Limits = [-1 19];
      app.S19mdl.ValueDisplayFormat = '%d';
      app.S19mdl.ValueChangedFcn = createCallbackFcn(app, @S11mdlValueChanged, true);
      app.S19mdl.HorizontalAlignment = 'center';
      app.S19mdl.Layout.Row = 2;
      app.S19mdl.Layout.Column = 9;

      % Create EditField_10
      app.EditField_10 = uieditfield(app.GridLayout, 'text');
      app.EditField_10.Editable = 'off';
      app.EditField_10.HorizontalAlignment = 'center';
      app.EditField_10.FontWeight = 'bold';
      app.EditField_10.BackgroundColor = [1 1 0.0667];
      app.EditField_10.Layout.Row = 1;
      app.EditField_10.Layout.Column = 1;
      app.EditField_10.Value = 'S 11';

      % Create EditField_11
      app.EditField_11 = uieditfield(app.GridLayout, 'text');
      app.EditField_11.Editable = 'off';
      app.EditField_11.HorizontalAlignment = 'center';
      app.EditField_11.FontWeight = 'bold';
      app.EditField_11.BackgroundColor = [1 1 0.0667];
      app.EditField_11.Layout.Row = 1;
      app.EditField_11.Layout.Column = 2;
      app.EditField_11.Value = 'S 12';

      % Create EditField_12
      app.EditField_12 = uieditfield(app.GridLayout, 'text');
      app.EditField_12.Editable = 'off';
      app.EditField_12.HorizontalAlignment = 'center';
      app.EditField_12.FontWeight = 'bold';
      app.EditField_12.BackgroundColor = [1 1 0.0667];
      app.EditField_12.Layout.Row = 1;
      app.EditField_12.Layout.Column = 3;
      app.EditField_12.Value = 'S 13';

      % Create EditField_13
      app.EditField_13 = uieditfield(app.GridLayout, 'text');
      app.EditField_13.Editable = 'off';
      app.EditField_13.HorizontalAlignment = 'center';
      app.EditField_13.FontWeight = 'bold';
      app.EditField_13.BackgroundColor = [1 1 0.0667];
      app.EditField_13.Layout.Row = 1;
      app.EditField_13.Layout.Column = 4;
      app.EditField_13.Value = 'S 14';

      % Create EditField_14
      app.EditField_14 = uieditfield(app.GridLayout, 'text');
      app.EditField_14.Editable = 'off';
      app.EditField_14.HorizontalAlignment = 'center';
      app.EditField_14.FontWeight = 'bold';
      app.EditField_14.BackgroundColor = [1 1 0.0667];
      app.EditField_14.Layout.Row = 1;
      app.EditField_14.Layout.Column = 5;
      app.EditField_14.Value = 'S 15';

      % Create EditField_15
      app.EditField_15 = uieditfield(app.GridLayout, 'text');
      app.EditField_15.Editable = 'off';
      app.EditField_15.HorizontalAlignment = 'center';
      app.EditField_15.FontWeight = 'bold';
      app.EditField_15.BackgroundColor = [1 1 0.0667];
      app.EditField_15.Layout.Row = 1;
      app.EditField_15.Layout.Column = 6;
      app.EditField_15.Value = 'S 16';

      % Create EditField_16
      app.EditField_16 = uieditfield(app.GridLayout, 'text');
      app.EditField_16.Editable = 'off';
      app.EditField_16.HorizontalAlignment = 'center';
      app.EditField_16.FontWeight = 'bold';
      app.EditField_16.BackgroundColor = [1 1 0.0667];
      app.EditField_16.Layout.Row = 1;
      app.EditField_16.Layout.Column = 7;
      app.EditField_16.Value = 'S 17';

      % Create EditField_17
      app.EditField_17 = uieditfield(app.GridLayout, 'text');
      app.EditField_17.Editable = 'off';
      app.EditField_17.HorizontalAlignment = 'center';
      app.EditField_17.FontWeight = 'bold';
      app.EditField_17.BackgroundColor = [1 1 0.0667];
      app.EditField_17.Layout.Row = 1;
      app.EditField_17.Layout.Column = 8;
      app.EditField_17.Value = 'S 18';

      % Create EditField_18
      app.EditField_18 = uieditfield(app.GridLayout, 'text');
      app.EditField_18.Editable = 'off';
      app.EditField_18.HorizontalAlignment = 'center';
      app.EditField_18.FontWeight = 'bold';
      app.EditField_18.BackgroundColor = [1 1 0.0667];
      app.EditField_18.Layout.Row = 1;
      app.EditField_18.Layout.Column = 9;
      app.EditField_18.Value = 'S 19';

      % Create FeedforwardstatusLampLabel
      app.FeedforwardstatusLampLabel = uilabel(app.F2_MDLFFUIFigure);
      app.FeedforwardstatusLampLabel.HorizontalAlignment = 'right';
      app.FeedforwardstatusLampLabel.Position = [16 535 113 22];
      app.FeedforwardstatusLampLabel.Text = 'Feed-forward status';

      % Create Lamp
      app.Lamp = uilamp(app.F2_MDLFFUIFigure);
      app.Lamp.Position = [144 535 20 20];

      % Create STOPButton
      app.STOPButton = uibutton(app.F2_MDLFFUIFigure, 'push');
      app.STOPButton.ButtonPushedFcn = createCallbackFcn(app, @STOPButtonPushed, true);
      app.STOPButton.Icon = 'stop.svg';
      app.STOPButton.Position = [176 534 100 23];
      app.STOPButton.Text = 'STOP';

      % Create STARTButton
      app.STARTButton = uibutton(app.F2_MDLFFUIFigure, 'push');
      app.STARTButton.ButtonPushedFcn = createCallbackFcn(app, @STARTButtonPushed, true);
      app.STARTButton.Icon = 'start.svg';
      app.STARTButton.Position = [286 534 100 23];
      app.STARTButton.Text = 'START';

      % Create ModelResponseUsedatafromt0t1dataformatyrmnthdayhrminsecPanel
      app.ModelResponseUsedatafromt0t1dataformatyrmnthdayhrminsecPanel = uipanel(app.F2_MDLFFUIFigure);
      app.ModelResponseUsedatafromt0t1dataformatyrmnthdayhrminsecPanel.Title = 'Model Response : Use data from t0 -> t1 : data format =  [yr mnth day hr min sec]';
      app.ModelResponseUsedatafromt0t1dataformatyrmnthdayhrminsecPanel.Position = [18 335 826 85];

      % Create GridLayout2
      app.GridLayout2 = uigridlayout(app.ModelResponseUsedatafromt0t1dataformatyrmnthdayhrminsecPanel);
      app.GridLayout2.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};

      % Create t0Button
      app.t0Button = uibutton(app.GridLayout2, 'push');
      app.t0Button.ButtonPushedFcn = createCallbackFcn(app, @t0ButtonPushed, true);
      app.t0Button.Icon = 'cal.svg';
      app.t0Button.Layout.Row = [1 2];
      app.t0Button.Layout.Column = 7;
      app.t0Button.Text = 't0';

      % Create t0_yr
      app.t0_yr = uieditfield(app.GridLayout2, 'numeric');
      app.t0_yr.Limits = [2000 2100];
      app.t0_yr.ValueDisplayFormat = '%d';
      app.t0_yr.ValueChangedFcn = createCallbackFcn(app, @t0_yrValueChanged, true);
      app.t0_yr.HorizontalAlignment = 'center';
      app.t0_yr.Layout.Row = 1;
      app.t0_yr.Layout.Column = 1;
      app.t0_yr.Value = 2000;

      % Create t0_mnth
      app.t0_mnth = uieditfield(app.GridLayout2, 'numeric');
      app.t0_mnth.Limits = [1 12];
      app.t0_mnth.ValueDisplayFormat = '%d';
      app.t0_mnth.ValueChangedFcn = createCallbackFcn(app, @t0_yrValueChanged, true);
      app.t0_mnth.HorizontalAlignment = 'center';
      app.t0_mnth.Layout.Row = 1;
      app.t0_mnth.Layout.Column = 2;
      app.t0_mnth.Value = 1;

      % Create t0_day
      app.t0_day = uieditfield(app.GridLayout2, 'numeric');
      app.t0_day.Limits = [1 31];
      app.t0_day.ValueDisplayFormat = '%d';
      app.t0_day.ValueChangedFcn = createCallbackFcn(app, @t0_yrValueChanged, true);
      app.t0_day.HorizontalAlignment = 'center';
      app.t0_day.Layout.Row = 1;
      app.t0_day.Layout.Column = 3;
      app.t0_day.Value = 1;

      % Create t0_hr
      app.t0_hr = uieditfield(app.GridLayout2, 'numeric');
      app.t0_hr.Limits = [0 23];
      app.t0_hr.ValueDisplayFormat = '%d';
      app.t0_hr.ValueChangedFcn = createCallbackFcn(app, @t0_yrValueChanged, true);
      app.t0_hr.HorizontalAlignment = 'center';
      app.t0_hr.Layout.Row = 1;
      app.t0_hr.Layout.Column = 4;

      % Create t0_min
      app.t0_min = uieditfield(app.GridLayout2, 'numeric');
      app.t0_min.Limits = [0 59];
      app.t0_min.ValueDisplayFormat = '%d';
      app.t0_min.ValueChangedFcn = createCallbackFcn(app, @t0_yrValueChanged, true);
      app.t0_min.HorizontalAlignment = 'center';
      app.t0_min.Layout.Row = 1;
      app.t0_min.Layout.Column = 5;

      % Create t0_sec
      app.t0_sec = uieditfield(app.GridLayout2, 'numeric');
      app.t0_sec.Limits = [0 59];
      app.t0_sec.ValueDisplayFormat = '%d';
      app.t0_sec.ValueChangedFcn = createCallbackFcn(app, @t0_yrValueChanged, true);
      app.t0_sec.HorizontalAlignment = 'center';
      app.t0_sec.Layout.Row = 1;
      app.t0_sec.Layout.Column = 6;

      % Create t1_yr
      app.t1_yr = uieditfield(app.GridLayout2, 'numeric');
      app.t1_yr.Limits = [2000 2100];
      app.t1_yr.ValueDisplayFormat = '%d';
      app.t1_yr.ValueChangedFcn = createCallbackFcn(app, @t0_yrValueChanged, true);
      app.t1_yr.HorizontalAlignment = 'center';
      app.t1_yr.Layout.Row = 2;
      app.t1_yr.Layout.Column = 1;
      app.t1_yr.Value = 2000;

      % Create t1_mnth
      app.t1_mnth = uieditfield(app.GridLayout2, 'numeric');
      app.t1_mnth.Limits = [1 12];
      app.t1_mnth.ValueDisplayFormat = '%d';
      app.t1_mnth.ValueChangedFcn = createCallbackFcn(app, @t0_yrValueChanged, true);
      app.t1_mnth.HorizontalAlignment = 'center';
      app.t1_mnth.Layout.Row = 2;
      app.t1_mnth.Layout.Column = 2;
      app.t1_mnth.Value = 1;

      % Create t1_day
      app.t1_day = uieditfield(app.GridLayout2, 'numeric');
      app.t1_day.Limits = [1 31];
      app.t1_day.ValueDisplayFormat = '%d';
      app.t1_day.ValueChangedFcn = createCallbackFcn(app, @t0_yrValueChanged, true);
      app.t1_day.HorizontalAlignment = 'center';
      app.t1_day.Layout.Row = 2;
      app.t1_day.Layout.Column = 3;
      app.t1_day.Value = 1;

      % Create t1_hr
      app.t1_hr = uieditfield(app.GridLayout2, 'numeric');
      app.t1_hr.Limits = [0 23];
      app.t1_hr.ValueDisplayFormat = '%d';
      app.t1_hr.ValueChangedFcn = createCallbackFcn(app, @t0_yrValueChanged, true);
      app.t1_hr.HorizontalAlignment = 'center';
      app.t1_hr.Layout.Row = 2;
      app.t1_hr.Layout.Column = 4;

      % Create t1_min
      app.t1_min = uieditfield(app.GridLayout2, 'numeric');
      app.t1_min.Limits = [0 59];
      app.t1_min.ValueDisplayFormat = '%d';
      app.t1_min.ValueChangedFcn = createCallbackFcn(app, @t0_yrValueChanged, true);
      app.t1_min.HorizontalAlignment = 'center';
      app.t1_min.Layout.Row = 2;
      app.t1_min.Layout.Column = 5;

      % Create t1_sec
      app.t1_sec = uieditfield(app.GridLayout2, 'numeric');
      app.t1_sec.Limits = [0 59];
      app.t1_sec.ValueDisplayFormat = '%d';
      app.t1_sec.ValueChangedFcn = createCallbackFcn(app, @t0_yrValueChanged, true);
      app.t1_sec.HorizontalAlignment = 'center';
      app.t1_sec.Layout.Row = 2;
      app.t1_sec.Layout.Column = 6;

      % Create t1Button
      app.t1Button = uibutton(app.GridLayout2, 'push');
      app.t1Button.Icon = 'cal.svg';
      app.t1Button.Layout.Row = [1 2];
      app.t1Button.Layout.Column = 8;
      app.t1Button.Text = 't1';

      % Create CopyToTrainingButton
      app.CopyToTrainingButton = uibutton(app.GridLayout2, 'push');
      app.CopyToTrainingButton.ButtonPushedFcn = createCallbackFcn(app, @CopyToTrainingButtonPushed, true);
      app.CopyToTrainingButton.Layout.Row = [1 2];
      app.CopyToTrainingButton.Layout.Column = 9;
      app.CopyToTrainingButton.Text = {'Copy'; 'To Training'};

      % Create ShowData
      app.ShowData = uibutton(app.GridLayout2, 'push');
      app.ShowData.ButtonPushedFcn = createCallbackFcn(app, @ShowDataPushed, true);
      app.ShowData.Icon = 'detachicon.jpg';
      app.ShowData.Layout.Row = [1 2];
      app.ShowData.Layout.Column = 10;
      app.ShowData.Text = '';

      % Create ModelSelectionTrainingParametersPanel
      app.ModelSelectionTrainingParametersPanel = uipanel(app.F2_MDLFFUIFigure);
      app.ModelSelectionTrainingParametersPanel.Title = 'Model Selection / Training / Parameters';
      app.ModelSelectionTrainingParametersPanel.Position = [17 9 827 313];

      % Create DropDown
      app.DropDown = uidropdown(app.ModelSelectionTrainingParametersPanel);
      app.DropDown.Items = {'MDLFF_lm_Nov22', 'Option 2', 'Option 3', 'Option 4'};
      app.DropDown.ValueChangedFcn = createCallbackFcn(app, @DropDownValueChanged, true);
      app.DropDown.Position = [10 263 367 22];
      app.DropDown.Value = 'MDLFF_lm_Nov22';

      % Create Train
      app.Train = uibutton(app.ModelSelectionTrainingParametersPanel, 'push');
      app.Train.ButtonPushedFcn = createCallbackFcn(app, @TrainPushed, true);
      app.Train.Icon = 'ML.svg';
      app.Train.HorizontalAlignment = 'left';
      app.Train.Position = [596 242 221 43];
      app.Train.Text = 'TRAIN - Push to Start';

      % Create SETDEFAULTButton
      app.SETDEFAULTButton = uibutton(app.ModelSelectionTrainingParametersPanel, 'push');
      app.SETDEFAULTButton.ButtonPushedFcn = createCallbackFcn(app, @SETDEFAULTButtonPushed, true);
      app.SETDEFAULTButton.Icon = 'save.svg';
      app.SETDEFAULTButton.Enable = 'off';
      app.SETDEFAULTButton.Position = [233 221 141 33];
      app.SETDEFAULTButton.Text = 'SET DEFAULT';

      % Create NewButton
      app.NewButton = uibutton(app.ModelSelectionTrainingParametersPanel, 'push');
      app.NewButton.ButtonPushedFcn = createCallbackFcn(app, @NewButtonPushed, true);
      app.NewButton.Icon = 'save.svg';
      app.NewButton.Position = [389 263 82 23];
      app.NewButton.Text = 'New...';

      % Create PasswordHTML
      app.PasswordHTML = uihtml(app.ModelSelectionTrainingParametersPanel);
      app.PasswordHTML.HTMLSource = 'passwordEdit.html';
      app.PasswordHTML.DataChangedFcn = createCallbackFcn(app, @PasswordHTMLDataChanged, true);
      app.PasswordHTML.Position = [10 228 165 24];

      % Create Image
      app.Image = uiimage(app.ModelSelectionTrainingParametersPanel);
      app.Image.Position = [190 226 32 28];
      app.Image.ImageSource = 'lock-icon.svg';

      % Create ModelTypeButtonGroup
      app.ModelTypeButtonGroup = uibuttongroup(app.ModelSelectionTrainingParametersPanel);
      app.ModelTypeButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ModelTypeButtonGroupSelectionChanged, true);
      app.ModelTypeButtonGroup.Title = 'Model Type';
      app.ModelTypeButtonGroup.Position = [483 192 100 93];

      % Create LinearButton
      app.LinearButton = uiradiobutton(app.ModelTypeButtonGroup);
      app.LinearButton.Text = 'Linear';
      app.LinearButton.Position = [11 40 58 22];
      app.LinearButton.Value = true;

      % Create NNButton
      app.NNButton = uiradiobutton(app.ModelTypeButtonGroup);
      app.NNButton.Text = 'NN';
      app.NNButton.Position = [11 11 65 22];

      % Create ShowModelTrainingDataButton
      app.ShowModelTrainingDataButton = uibutton(app.ModelSelectionTrainingParametersPanel, 'push');
      app.ShowModelTrainingDataButton.ButtonPushedFcn = createCallbackFcn(app, @ShowModelTrainingDataButtonPushed, true);
      app.ShowModelTrainingDataButton.Icon = 'detachicon.jpg';
      app.ShowModelTrainingDataButton.Position = [596 194 138 45];
      app.ShowModelTrainingDataButton.Text = {'Show Model'; '+ Training Data'};

      % Create Spinner
      app.Spinner = uispinner(app.ModelSelectionTrainingParametersPanel);
      app.Spinner.Limits = [11 19];
      app.Spinner.ValueChangedFcn = createCallbackFcn(app, @SpinnerValueChanged, true);
      app.Spinner.Position = [743 200 65 32];
      app.Spinner.Value = 11;

      % Create ModelDataInputSelectionPanel
      app.ModelDataInputSelectionPanel = uipanel(app.ModelSelectionTrainingParametersPanel);
      app.ModelDataInputSelectionPanel.Title = 'Model Data Input Selection';
      app.ModelDataInputSelectionPanel.Position = [6 104 812 81];

      % Create GridLayout3
      app.GridLayout3 = uigridlayout(app.ModelDataInputSelectionPanel);
      app.GridLayout3.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x'};

      % Create PressureCheckBox
      app.PressureCheckBox = uicheckbox(app.GridLayout3);
      app.PressureCheckBox.ValueChangedFcn = createCallbackFcn(app, @PressureCheckBoxValueChanged, true);
      app.PressureCheckBox.Text = 'Pressure';
      app.PressureCheckBox.Layout.Row = 1;
      app.PressureCheckBox.Layout.Column = 1;

      % Create MCCTempCheckBox
      app.MCCTempCheckBox = uicheckbox(app.GridLayout3);
      app.MCCTempCheckBox.ValueChangedFcn = createCallbackFcn(app, @MCCTempCheckBoxValueChanged, true);
      app.MCCTempCheckBox.Text = 'MCCTemp';
      app.MCCTempCheckBox.Layout.Row = 1;
      app.MCCTempCheckBox.Layout.Column = 2;

      % Create S20TempCheckBox
      app.S20TempCheckBox = uicheckbox(app.GridLayout3);
      app.S20TempCheckBox.ValueChangedFcn = createCallbackFcn(app, @S20TempCheckBoxValueChanged, true);
      app.S20TempCheckBox.Text = 'S20Temp';
      app.S20TempCheckBox.Layout.Row = 1;
      app.S20TempCheckBox.Layout.Column = 3;

      % Create MDL_temp_11CheckBox
      app.MDL_temp_11CheckBox = uicheckbox(app.GridLayout3);
      app.MDL_temp_11CheckBox.ValueChangedFcn = createCallbackFcn(app, @MDL_temp_11CheckBoxValueChanged, true);
      app.MDL_temp_11CheckBox.Text = 'MDL_temp_11';
      app.MDL_temp_11CheckBox.Layout.Row = 1;
      app.MDL_temp_11CheckBox.Layout.Column = 4;

      % Create MDL_temp_12CheckBox
      app.MDL_temp_12CheckBox = uicheckbox(app.GridLayout3);
      app.MDL_temp_12CheckBox.ValueChangedFcn = createCallbackFcn(app, @MDL_temp_12CheckBoxValueChanged, true);
      app.MDL_temp_12CheckBox.Text = 'MDL_temp_12';
      app.MDL_temp_12CheckBox.Layout.Row = 1;
      app.MDL_temp_12CheckBox.Layout.Column = 5;

      % Create MDL_temp_13CheckBox
      app.MDL_temp_13CheckBox = uicheckbox(app.GridLayout3);
      app.MDL_temp_13CheckBox.ValueChangedFcn = createCallbackFcn(app, @MDL_temp_13CheckBoxValueChanged, true);
      app.MDL_temp_13CheckBox.Text = 'MDL_temp_13';
      app.MDL_temp_13CheckBox.Layout.Row = 1;
      app.MDL_temp_13CheckBox.Layout.Column = 6;

      % Create MDL_temp_14CheckBox
      app.MDL_temp_14CheckBox = uicheckbox(app.GridLayout3);
      app.MDL_temp_14CheckBox.ValueChangedFcn = createCallbackFcn(app, @MDL_temp_14CheckBoxValueChanged, true);
      app.MDL_temp_14CheckBox.Text = 'MDL_temp_14';
      app.MDL_temp_14CheckBox.Layout.Row = 2;
      app.MDL_temp_14CheckBox.Layout.Column = 1;

      % Create MDL_temp_15CheckBox
      app.MDL_temp_15CheckBox = uicheckbox(app.GridLayout3);
      app.MDL_temp_15CheckBox.ValueChangedFcn = createCallbackFcn(app, @MDL_temp_15CheckBoxValueChanged, true);
      app.MDL_temp_15CheckBox.Text = 'MDL_temp_15';
      app.MDL_temp_15CheckBox.Layout.Row = 2;
      app.MDL_temp_15CheckBox.Layout.Column = 2;

      % Create MDL_temp_16CheckBox
      app.MDL_temp_16CheckBox = uicheckbox(app.GridLayout3);
      app.MDL_temp_16CheckBox.ValueChangedFcn = createCallbackFcn(app, @MDL_temp_16CheckBoxValueChanged, true);
      app.MDL_temp_16CheckBox.Text = 'MDL_temp_16';
      app.MDL_temp_16CheckBox.Layout.Row = 2;
      app.MDL_temp_16CheckBox.Layout.Column = 3;

      % Create MDL_temp_17CheckBox
      app.MDL_temp_17CheckBox = uicheckbox(app.GridLayout3);
      app.MDL_temp_17CheckBox.ValueChangedFcn = createCallbackFcn(app, @MDL_temp_17CheckBoxValueChanged, true);
      app.MDL_temp_17CheckBox.Text = 'MDL_temp_17';
      app.MDL_temp_17CheckBox.Layout.Row = 2;
      app.MDL_temp_17CheckBox.Layout.Column = 4;

      % Create MDL_temp_18CheckBox
      app.MDL_temp_18CheckBox = uicheckbox(app.GridLayout3);
      app.MDL_temp_18CheckBox.ValueChangedFcn = createCallbackFcn(app, @MDL_temp_18CheckBoxValueChanged, true);
      app.MDL_temp_18CheckBox.Text = 'MDL_temp_18';
      app.MDL_temp_18CheckBox.Layout.Row = 2;
      app.MDL_temp_18CheckBox.Layout.Column = 5;

      % Create MDL_temp_19CheckBox
      app.MDL_temp_19CheckBox = uicheckbox(app.GridLayout3);
      app.MDL_temp_19CheckBox.ValueChangedFcn = createCallbackFcn(app, @MDL_temp_19CheckBoxValueChanged, true);
      app.MDL_temp_19CheckBox.Text = 'MDL_temp_19';
      app.MDL_temp_19CheckBox.Layout.Row = 2;
      app.MDL_temp_19CheckBox.Layout.Column = 6;

      % Create TempLimitsdegFEditFieldLabel
      app.TempLimitsdegFEditFieldLabel = uilabel(app.ModelSelectionTrainingParametersPanel);
      app.TempLimitsdegFEditFieldLabel.HorizontalAlignment = 'right';
      app.TempLimitsdegFEditFieldLabel.Position = [6 191 112 22];
      app.TempLimitsdegFEditFieldLabel.Text = 'Temp Limits (degF):';

      % Create tlim1
      app.tlim1 = uieditfield(app.ModelSelectionTrainingParametersPanel, 'numeric');
      app.tlim1.Limits = [0 144];
      app.tlim1.ValueChangedFcn = createCallbackFcn(app, @tlim1ValueChanged, true);
      app.tlim1.Position = [129 191 44 22];

      % Create tlim2
      app.tlim2 = uieditfield(app.ModelSelectionTrainingParametersPanel, 'numeric');
      app.tlim2.Limits = [0 144];
      app.tlim2.ValueChangedFcn = createCallbackFcn(app, @tlim2ValueChanged, true);
      app.tlim2.Position = [181 191 44 22];
      app.tlim2.Value = 144;

      % Create plim2
      app.plim2 = uieditfield(app.ModelSelectionTrainingParametersPanel, 'numeric');
      app.plim2.Limits = [950 1050];
      app.plim2.ValueChangedFcn = createCallbackFcn(app, @plim2ValueChanged, true);
      app.plim2.Position = [427 191 44 22];
      app.plim2.Value = 1050;

      % Create PressureLimitsmbarEditFieldLabel
      app.PressureLimitsmbarEditFieldLabel = uilabel(app.ModelSelectionTrainingParametersPanel);
      app.PressureLimitsmbarEditFieldLabel.HorizontalAlignment = 'right';
      app.PressureLimitsmbarEditFieldLabel.Position = [233 191 131 22];
      app.PressureLimitsmbarEditFieldLabel.Text = 'Pressure Limits (mbar):';

      % Create plim1
      app.plim1 = uieditfield(app.ModelSelectionTrainingParametersPanel, 'numeric');
      app.plim1.Limits = [950 1050];
      app.plim1.ValueChangedFcn = createCallbackFcn(app, @plim1ValueChanged, true);
      app.plim1.Position = [375 191 45 22];
      app.plim1.Value = 950;

      % Create TrainingDataUsedatafromt0t1dataformatyrmnthdayhrminsecPanel
      app.TrainingDataUsedatafromt0t1dataformatyrmnthdayhrminsecPanel = uipanel(app.ModelSelectionTrainingParametersPanel);
      app.TrainingDataUsedatafromt0t1dataformatyrmnthdayhrminsecPanel.Title = 'Training Data : Use data from t0 -> t1 : data format =  [yr mnth day hr min sec]';
      app.TrainingDataUsedatafromt0t1dataformatyrmnthdayhrminsecPanel.Position = [6 10 812 85];

      % Create GridLayout2_2
      app.GridLayout2_2 = uigridlayout(app.TrainingDataUsedatafromt0t1dataformatyrmnthdayhrminsecPanel);
      app.GridLayout2_2.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};

      % Create t0Button_2
      app.t0Button_2 = uibutton(app.GridLayout2_2, 'push');
      app.t0Button_2.ButtonPushedFcn = createCallbackFcn(app, @t0Button_2Pushed, true);
      app.t0Button_2.Icon = 'cal.svg';
      app.t0Button_2.Layout.Row = [1 2];
      app.t0Button_2.Layout.Column = 7;
      app.t0Button_2.Text = 't0';

      % Create t0_yr_2
      app.t0_yr_2 = uieditfield(app.GridLayout2_2, 'numeric');
      app.t0_yr_2.Limits = [2000 2100];
      app.t0_yr_2.ValueDisplayFormat = '%d';
      app.t0_yr_2.ValueChangedFcn = createCallbackFcn(app, @t0_yr_2ValueChanged, true);
      app.t0_yr_2.HorizontalAlignment = 'center';
      app.t0_yr_2.Layout.Row = 1;
      app.t0_yr_2.Layout.Column = 1;
      app.t0_yr_2.Value = 2000;

      % Create t0_mnth_2
      app.t0_mnth_2 = uieditfield(app.GridLayout2_2, 'numeric');
      app.t0_mnth_2.Limits = [1 12];
      app.t0_mnth_2.ValueDisplayFormat = '%d';
      app.t0_mnth_2.ValueChangedFcn = createCallbackFcn(app, @t0_yr_2ValueChanged, true);
      app.t0_mnth_2.HorizontalAlignment = 'center';
      app.t0_mnth_2.Layout.Row = 1;
      app.t0_mnth_2.Layout.Column = 2;
      app.t0_mnth_2.Value = 1;

      % Create t0_day_2
      app.t0_day_2 = uieditfield(app.GridLayout2_2, 'numeric');
      app.t0_day_2.Limits = [1 31];
      app.t0_day_2.ValueDisplayFormat = '%d';
      app.t0_day_2.ValueChangedFcn = createCallbackFcn(app, @t0_yr_2ValueChanged, true);
      app.t0_day_2.HorizontalAlignment = 'center';
      app.t0_day_2.Layout.Row = 1;
      app.t0_day_2.Layout.Column = 3;
      app.t0_day_2.Value = 1;

      % Create t0_hr_2
      app.t0_hr_2 = uieditfield(app.GridLayout2_2, 'numeric');
      app.t0_hr_2.Limits = [0 23];
      app.t0_hr_2.ValueDisplayFormat = '%d';
      app.t0_hr_2.ValueChangedFcn = createCallbackFcn(app, @t0_yr_2ValueChanged, true);
      app.t0_hr_2.HorizontalAlignment = 'center';
      app.t0_hr_2.Layout.Row = 1;
      app.t0_hr_2.Layout.Column = 4;

      % Create t0_min_2
      app.t0_min_2 = uieditfield(app.GridLayout2_2, 'numeric');
      app.t0_min_2.Limits = [0 59];
      app.t0_min_2.ValueDisplayFormat = '%d';
      app.t0_min_2.ValueChangedFcn = createCallbackFcn(app, @t0_yr_2ValueChanged, true);
      app.t0_min_2.HorizontalAlignment = 'center';
      app.t0_min_2.Layout.Row = 1;
      app.t0_min_2.Layout.Column = 5;

      % Create t0_sec_2
      app.t0_sec_2 = uieditfield(app.GridLayout2_2, 'numeric');
      app.t0_sec_2.Limits = [0 59];
      app.t0_sec_2.ValueDisplayFormat = '%d';
      app.t0_sec_2.ValueChangedFcn = createCallbackFcn(app, @t0_yr_2ValueChanged, true);
      app.t0_sec_2.HorizontalAlignment = 'center';
      app.t0_sec_2.Layout.Row = 1;
      app.t0_sec_2.Layout.Column = 6;

      % Create t1_yr_2
      app.t1_yr_2 = uieditfield(app.GridLayout2_2, 'numeric');
      app.t1_yr_2.Limits = [2000 2100];
      app.t1_yr_2.ValueDisplayFormat = '%d';
      app.t1_yr_2.ValueChangedFcn = createCallbackFcn(app, @t0_yr_2ValueChanged, true);
      app.t1_yr_2.HorizontalAlignment = 'center';
      app.t1_yr_2.Layout.Row = 2;
      app.t1_yr_2.Layout.Column = 1;
      app.t1_yr_2.Value = 2000;

      % Create t1_mnth_2
      app.t1_mnth_2 = uieditfield(app.GridLayout2_2, 'numeric');
      app.t1_mnth_2.Limits = [1 12];
      app.t1_mnth_2.ValueDisplayFormat = '%d';
      app.t1_mnth_2.ValueChangedFcn = createCallbackFcn(app, @t0_yr_2ValueChanged, true);
      app.t1_mnth_2.HorizontalAlignment = 'center';
      app.t1_mnth_2.Layout.Row = 2;
      app.t1_mnth_2.Layout.Column = 2;
      app.t1_mnth_2.Value = 1;

      % Create t1_day_2
      app.t1_day_2 = uieditfield(app.GridLayout2_2, 'numeric');
      app.t1_day_2.Limits = [1 31];
      app.t1_day_2.ValueDisplayFormat = '%d';
      app.t1_day_2.ValueChangedFcn = createCallbackFcn(app, @t0_yr_2ValueChanged, true);
      app.t1_day_2.HorizontalAlignment = 'center';
      app.t1_day_2.Layout.Row = 2;
      app.t1_day_2.Layout.Column = 3;
      app.t1_day_2.Value = 1;

      % Create t1_hr_2
      app.t1_hr_2 = uieditfield(app.GridLayout2_2, 'numeric');
      app.t1_hr_2.Limits = [0 23];
      app.t1_hr_2.ValueDisplayFormat = '%d';
      app.t1_hr_2.ValueChangedFcn = createCallbackFcn(app, @t0_yr_2ValueChanged, true);
      app.t1_hr_2.HorizontalAlignment = 'center';
      app.t1_hr_2.Layout.Row = 2;
      app.t1_hr_2.Layout.Column = 4;

      % Create t1_min_2
      app.t1_min_2 = uieditfield(app.GridLayout2_2, 'numeric');
      app.t1_min_2.Limits = [0 59];
      app.t1_min_2.ValueDisplayFormat = '%d';
      app.t1_min_2.ValueChangedFcn = createCallbackFcn(app, @t0_yr_2ValueChanged, true);
      app.t1_min_2.HorizontalAlignment = 'center';
      app.t1_min_2.Layout.Row = 2;
      app.t1_min_2.Layout.Column = 5;

      % Create t1_sec_2
      app.t1_sec_2 = uieditfield(app.GridLayout2_2, 'numeric');
      app.t1_sec_2.Limits = [0 59];
      app.t1_sec_2.ValueDisplayFormat = '%d';
      app.t1_sec_2.ValueChangedFcn = createCallbackFcn(app, @t0_yr_2ValueChanged, true);
      app.t1_sec_2.HorizontalAlignment = 'center';
      app.t1_sec_2.Layout.Row = 2;
      app.t1_sec_2.Layout.Column = 6;

      % Create t1Button_2
      app.t1Button_2 = uibutton(app.GridLayout2_2, 'push');
      app.t1Button_2.ButtonPushedFcn = createCallbackFcn(app, @t1Button_2Pushed, true);
      app.t1Button_2.Icon = 'cal.svg';
      app.t1Button_2.Layout.Row = [1 2];
      app.t1Button_2.Layout.Column = 8;
      app.t1Button_2.Text = 't1';

      % Create CopyToModelRespButton
      app.CopyToModelRespButton = uibutton(app.GridLayout2_2, 'push');
      app.CopyToModelRespButton.ButtonPushedFcn = createCallbackFcn(app, @CopyToModelRespButtonPushed, true);
      app.CopyToModelRespButton.Layout.Row = [1 2];
      app.CopyToModelRespButton.Layout.Column = 9;
      app.CopyToModelRespButton.Text = {'Copy To'; 'Model Resp.'};

      % Create SaveButton
      app.SaveButton = uibutton(app.ModelSelectionTrainingParametersPanel, 'push');
      app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
      app.SaveButton.Icon = 'save.svg';
      app.SaveButton.Position = [388 221 83 33];
      app.SaveButton.Text = 'Save';

      % Create EditField_mdlname
      app.EditField_mdlname = uieditfield(app.F2_MDLFFUIFigure, 'text');
      app.EditField_mdlname.Editable = 'off';
      app.EditField_mdlname.HorizontalAlignment = 'center';
      app.EditField_mdlname.Position = [415 535 425 22];

      % Show the figure after all components are created
      app.F2_MDLFFUIFigure.Visible = 'on';
    end
  end

  % App creation and deletion
  methods (Access = public)

    % Construct app
    function app = F2_MDLFF_exported

      % Create UIFigure and components
      createComponents(app)

      % Register the app with App Designer
      registerApp(app, app.F2_MDLFFUIFigure)

      % Execute the startup function
      runStartupFcn(app, @startupFcn)

      if nargout == 0
        clear app
      end
    end

    % Code that executes before app deletion
    function delete(app)

      % Delete UIFigure when app is deleted
      delete(app.F2_MDLFFUIFigure)
    end
  end
end