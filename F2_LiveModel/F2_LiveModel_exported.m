classdef F2_LiveModel_exported < matlab.apps.AppBase

  % Properties that correspond to app components
  properties (Access = public)
    F2_LiveModelUIFigure     matlab.ui.Figure
    RegionSelectPanel        matlab.ui.container.Panel
    GridLayout               matlab.ui.container.GridLayout
    INJButton                matlab.ui.control.StateButton
    L0Button                 matlab.ui.control.StateButton
    DL1Button                matlab.ui.control.StateButton
    L1Button                 matlab.ui.control.StateButton
    BC11Button               matlab.ui.control.StateButton
    L2Button                 matlab.ui.control.StateButton
    BC14Button               matlab.ui.control.StateButton
    L3Button                 matlab.ui.control.StateButton
    BC20Button               matlab.ui.control.StateButton
    FFSButton                matlab.ui.control.StateButton
    SPECTButton              matlab.ui.control.StateButton
    ArchiveDateTimePanel     matlab.ui.container.Panel
    DatePicker               matlab.ui.control.DatePicker
    EditField                matlab.ui.control.EditField
    DataSourcePanel          matlab.ui.container.Panel
    DataSourceDropDown       matlab.ui.control.DropDown
    SaveModeltoFileButton    matlab.ui.control.Button
    LoadModelFromFileButton  matlab.ui.control.Button
    UITable                  matlab.ui.control.Table
    TwissParametersPanel     matlab.ui.container.Panel
    BETACheckBox             matlab.ui.control.CheckBox
    ETAXCheckBox             matlab.ui.control.CheckBox
    ETAYCheckBox             matlab.ui.control.CheckBox
    PLOTButton               matlab.ui.control.Button
  end

  
  properties (Access = public)
    aobj % Description
  end
  

  % Callbacks that handle component events
  methods (Access = private)

    % Code that executes after component creation
    function startupFcn(app)
      app.aobj = F2_LiveModelApp ;
      dt = datetime ; % Set current archive date as now
      app.DatePicker.Value = dt ; 
      app.aobj.ArchiveDate = [year(dt),month(dt),day(dt),hour(dt),minute(dt),second(dt)];
      app.EditField.Value = sprintf('%02d:%02d:%02d',app.aobj.ArchiveDate(4:6)) ;
      app.DataSourceDropDownValueChanged ; % load model from default source
    end

    % Value changed function: DatePicker
    function DatePickerValueChanged(app, event)
      dt1 = app.DatePicker.Value ;
      dt2 = datetime(app.EditField.Value) ;
      app.aobj.ArchiveDate = [dt1.Year dt1.Month dt1.Day dt2.Hour dt2.Minute dt2.Second] ;
      app.DataSourceDropDownValueChanged ;
    end

    % Value changed function: EditField
    function EditFieldValueChanged(app, event)
      dt1 = app.DatePicker.Value ;
      dt2 = datetime(app.EditField.Value) ;
      app.aobj.ArchiveDate = [dt1.Year dt1.Month dt1.Day dt2.Hour dt2.Minute dt2.Second] ;
      app.DataSourceDropDownValueChanged ;
    end

    % Value changed function: BC11Button, BC14Button, 
    % BC20Button, DL1Button, DataSourceDropDown, FFSButton, 
    % INJButton, L0Button, L1Button, L2Button, L3Button, 
    % SPECTButton
    function DataSourceDropDownValueChanged(app, event)
      global BEAMLINE
      app.DataSourceDropDown.Enable = false ; app.DatePicker.Enable=false; app.EditField.Enable=false;  app.SaveModeltoFileButton.Enable=false; app.LoadModelFromFileButton.Enable=false; app.PLOTButton.Enable=false;
      app.UITable.Data={};
      drawnow
      try
        app.aobj.ModelSource = app.DataSourceDropDown.Value ;
        regid = [app.INJButton.Value app.L0Button.Value app.DL1Button.Value app.L1Button.Value app.BC11Button.Value app.L2Button.Value app.BC14Button.Value app.L3Button.Value app.BC20Button.Value app.FFSButton.Value app.SPECTButton.Value];
        reg1 = find(regid,1); reg2=find(regid,1,'last');
        i1 = app.aobj.LM.ModelRegionID(reg1,1); i2 = app.LM.ModelRegionID(reg2,2);
        [~,T]=GetTwiss(1,i2,app.aobj.Initial.x.Twiss,app.aobj.Initial.y.Twiss);
        tdata=cell(i2-i1+1,6);
        tind=1;
        for iele=i1:i2
          tdata{tind,1} = BEAMLINE{iele}.Name ;
          tdata{tind,2} = num2str(BEAMLINE{iele}.Coordi(3)) ;
          tdata{tind,3} = num2str([T.betax(iele) T.betay(iele)]) ;
          tdata{tind,4} = num2str([T.alphax(iele) T.alphay(iele)]) ;
          tdata{tind,5} = num2str([T.etax(iele) T.etay(iele)]) ;
          if isfield(BEAMLINE{iele},'B')
            tdata{tind,6} = num2str(BEAMLINE{iele}.B(1)*10) ;
          else
            tdata{tind,6} = '---' ;
          end
        end
        app.UITable.Data = tdata ;
      catch
        app.DataSourceDropDown.Enable = true ; app.DatePicker.Enable=true; app.EditField.Enable=true;  app.SaveModeltoFileButton.Enable=true; app.LoadModelFromFileButton.Enable=true; app.PLOTButton.Enable=true;
      end
      app.DataSourceDropDown.Enable = true ; app.DatePicker.Enable=true; app.EditField.Enable=true;  app.SaveModeltoFileButton.Enable=true; app.LoadModelFromFileButton.Enable=true; app.PLOTButton.Enable=true;
    end

    % Button pushed function: SaveModeltoFileButton
    function SaveModeltoFileButtonPushed(app, event)
      [fn,pn]=uiputfile('*.mat','Save Model');
      if fn
        obj.aobj.WriteModel(fullfile(pn,fn));
      end
    end

    % Button pushed function: LoadModelFromFileButton
    function LoadModelFromFileButtonPushed(app, event)
      [fn,pn]=uigetfile('*.mat','Save Model');
      if fn
        obj.aobj.LoadModel(fullfile(pn,fn));
        d=dir(fullfile(pn,fn));
        dt=datetime(d.datenum,'ConvertFrom','datenum');
        app.DatePicker.Value=dt;
        app.EditField.Value = sprintf('%02d:%02d:%02d',dt.Hour,dt.Minute,dt.Second) ;
        app.DataSourceDropDown.Value='Archive';
      end
    end

    % Button pushed function: PLOTButton
    function PLOTButtonPushed(app, event)
      regid = [app.INJButton.Value app.L0Button.Value app.DL1Button.Value app.L1Button.Value app.BC11Button.Value app.L2Button.Value app.BC14Button.Value app.L3Button.Value app.BC20Button.Value app.FFSButton.Value app.SPECTButton.Value];
      reg1 = find(regid,1); reg2=find(regid,1,'last');
      i1 = app.aobj.LM.ModelRegionID(reg1,1); i2 = app.LM.ModelRegionID(reg2,2);
      TwissPlot(i1,i2,obj.aobj.Initial,[app.BETACheckBox.Value app.ETAXCheckBox.Value app.ETAYCheckBox.Value],0.01) ;
    end
  end

  % Component initialization
  methods (Access = private)

    % Create UIFigure and components
    function createComponents(app)

      % Create F2_LiveModelUIFigure and hide until all components are created
      app.F2_LiveModelUIFigure = uifigure('Visible', 'off');
      app.F2_LiveModelUIFigure.Position = [100 100 865 614];
      app.F2_LiveModelUIFigure.Name = 'F2_LiveModel';

      % Create RegionSelectPanel
      app.RegionSelectPanel = uipanel(app.F2_LiveModelUIFigure);
      app.RegionSelectPanel.Title = 'Region Select';
      app.RegionSelectPanel.Position = [18 539 835 66];

      % Create GridLayout
      app.GridLayout = uigridlayout(app.RegionSelectPanel);
      app.GridLayout.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
      app.GridLayout.RowHeight = {'2x'};

      % Create INJButton
      app.INJButton = uibutton(app.GridLayout, 'state');
      app.INJButton.ValueChangedFcn = createCallbackFcn(app, @DataSourceDropDownValueChanged, true);
      app.INJButton.Interruptible = 'off';
      app.INJButton.Text = 'INJ';
      app.INJButton.Layout.Row = 1;
      app.INJButton.Layout.Column = 1;
      app.INJButton.Value = true;

      % Create L0Button
      app.L0Button = uibutton(app.GridLayout, 'state');
      app.L0Button.ValueChangedFcn = createCallbackFcn(app, @DataSourceDropDownValueChanged, true);
      app.L0Button.Interruptible = 'off';
      app.L0Button.Text = 'L0';
      app.L0Button.Layout.Row = 1;
      app.L0Button.Layout.Column = 2;
      app.L0Button.Value = true;

      % Create DL1Button
      app.DL1Button = uibutton(app.GridLayout, 'state');
      app.DL1Button.ValueChangedFcn = createCallbackFcn(app, @DataSourceDropDownValueChanged, true);
      app.DL1Button.Interruptible = 'off';
      app.DL1Button.Text = 'DL1';
      app.DL1Button.Layout.Row = 1;
      app.DL1Button.Layout.Column = 3;
      app.DL1Button.Value = true;

      % Create L1Button
      app.L1Button = uibutton(app.GridLayout, 'state');
      app.L1Button.ValueChangedFcn = createCallbackFcn(app, @DataSourceDropDownValueChanged, true);
      app.L1Button.Interruptible = 'off';
      app.L1Button.Text = 'L1';
      app.L1Button.Layout.Row = 1;
      app.L1Button.Layout.Column = 4;
      app.L1Button.Value = true;

      % Create BC11Button
      app.BC11Button = uibutton(app.GridLayout, 'state');
      app.BC11Button.ValueChangedFcn = createCallbackFcn(app, @DataSourceDropDownValueChanged, true);
      app.BC11Button.Interruptible = 'off';
      app.BC11Button.Text = 'BC11';
      app.BC11Button.Layout.Row = 1;
      app.BC11Button.Layout.Column = 5;
      app.BC11Button.Value = true;

      % Create L2Button
      app.L2Button = uibutton(app.GridLayout, 'state');
      app.L2Button.ValueChangedFcn = createCallbackFcn(app, @DataSourceDropDownValueChanged, true);
      app.L2Button.Interruptible = 'off';
      app.L2Button.Text = 'L2';
      app.L2Button.Layout.Row = 1;
      app.L2Button.Layout.Column = 6;
      app.L2Button.Value = true;

      % Create BC14Button
      app.BC14Button = uibutton(app.GridLayout, 'state');
      app.BC14Button.ValueChangedFcn = createCallbackFcn(app, @DataSourceDropDownValueChanged, true);
      app.BC14Button.Interruptible = 'off';
      app.BC14Button.Text = 'BC14';
      app.BC14Button.Layout.Row = 1;
      app.BC14Button.Layout.Column = 7;
      app.BC14Button.Value = true;

      % Create L3Button
      app.L3Button = uibutton(app.GridLayout, 'state');
      app.L3Button.ValueChangedFcn = createCallbackFcn(app, @DataSourceDropDownValueChanged, true);
      app.L3Button.Interruptible = 'off';
      app.L3Button.Text = 'L3';
      app.L3Button.Layout.Row = 1;
      app.L3Button.Layout.Column = 8;
      app.L3Button.Value = true;

      % Create BC20Button
      app.BC20Button = uibutton(app.GridLayout, 'state');
      app.BC20Button.ValueChangedFcn = createCallbackFcn(app, @DataSourceDropDownValueChanged, true);
      app.BC20Button.Interruptible = 'off';
      app.BC20Button.Text = 'BC20';
      app.BC20Button.Layout.Row = 1;
      app.BC20Button.Layout.Column = 9;
      app.BC20Button.Value = true;

      % Create FFSButton
      app.FFSButton = uibutton(app.GridLayout, 'state');
      app.FFSButton.ValueChangedFcn = createCallbackFcn(app, @DataSourceDropDownValueChanged, true);
      app.FFSButton.Interruptible = 'off';
      app.FFSButton.Text = 'FFS';
      app.FFSButton.Layout.Row = 1;
      app.FFSButton.Layout.Column = 10;
      app.FFSButton.Value = true;

      % Create SPECTButton
      app.SPECTButton = uibutton(app.GridLayout, 'state');
      app.SPECTButton.ValueChangedFcn = createCallbackFcn(app, @DataSourceDropDownValueChanged, true);
      app.SPECTButton.Interruptible = 'off';
      app.SPECTButton.Text = 'SPECT';
      app.SPECTButton.Layout.Row = 1;
      app.SPECTButton.Layout.Column = 11;
      app.SPECTButton.Value = true;

      % Create ArchiveDateTimePanel
      app.ArchiveDateTimePanel = uipanel(app.F2_LiveModelUIFigure);
      app.ArchiveDateTimePanel.Title = 'Archive Date/Time';
      app.ArchiveDateTimePanel.Position = [169 17 299 60];

      % Create DatePicker
      app.DatePicker = uidatepicker(app.ArchiveDateTimePanel);
      app.DatePicker.ValueChangedFcn = createCallbackFcn(app, @DatePickerValueChanged, true);
      app.DatePicker.Position = [14 10 150 22];

      % Create EditField
      app.EditField = uieditfield(app.ArchiveDateTimePanel, 'text');
      app.EditField.ValueChangedFcn = createCallbackFcn(app, @EditFieldValueChanged, true);
      app.EditField.HorizontalAlignment = 'center';
      app.EditField.Position = [179 10 100 22];
      app.EditField.Value = '12:00';

      % Create DataSourcePanel
      app.DataSourcePanel = uipanel(app.F2_LiveModelUIFigure);
      app.DataSourcePanel.Title = 'Data Source';
      app.DataSourcePanel.Position = [18 17 130 60];

      % Create DataSourceDropDown
      app.DataSourceDropDown = uidropdown(app.DataSourcePanel);
      app.DataSourceDropDown.Items = {'Design', 'Live', 'Archive'};
      app.DataSourceDropDown.ValueChangedFcn = createCallbackFcn(app, @DataSourceDropDownValueChanged, true);
      app.DataSourceDropDown.Position = [8 6 112 22];
      app.DataSourceDropDown.Value = 'Design';

      % Create SaveModeltoFileButton
      app.SaveModeltoFileButton = uibutton(app.F2_LiveModelUIFigure, 'push');
      app.SaveModeltoFileButton.ButtonPushedFcn = createCallbackFcn(app, @SaveModeltoFileButtonPushed, true);
      app.SaveModeltoFileButton.Position = [476 50 134 32];
      app.SaveModeltoFileButton.Text = 'Save Model to File';

      % Create LoadModelFromFileButton
      app.LoadModelFromFileButton = uibutton(app.F2_LiveModelUIFigure, 'push');
      app.LoadModelFromFileButton.ButtonPushedFcn = createCallbackFcn(app, @LoadModelFromFileButtonPushed, true);
      app.LoadModelFromFileButton.Position = [476 15 134 32];
      app.LoadModelFromFileButton.Text = 'Load Model From File';

      % Create UITable
      app.UITable = uitable(app.F2_LiveModelUIFigure);
      app.UITable.ColumnName = {'Name'; 'Linac Z [m]'; 'BETA_X,Y [m]'; 'ALPHA_X,Y'; 'ETA_X,Y'; 'BDES [kG]'};
      app.UITable.RowName = {};
      app.UITable.Position = [18 94 834 438];

      % Create TwissParametersPanel
      app.TwissParametersPanel = uipanel(app.F2_LiveModelUIFigure);
      app.TwissParametersPanel.Title = 'Twiss Parameters';
      app.TwissParametersPanel.Position = [617 14 236 68];

      % Create BETACheckBox
      app.BETACheckBox = uicheckbox(app.TwissParametersPanel);
      app.BETACheckBox.Text = 'BETA';
      app.BETACheckBox.Position = [5 13 52 22];
      app.BETACheckBox.Value = true;

      % Create ETAXCheckBox
      app.ETAXCheckBox = uicheckbox(app.TwissParametersPanel);
      app.ETAXCheckBox.Text = 'ETAX';
      app.ETAXCheckBox.Position = [60 13 52 22];
      app.ETAXCheckBox.Value = true;

      % Create ETAYCheckBox
      app.ETAYCheckBox = uicheckbox(app.TwissParametersPanel);
      app.ETAYCheckBox.Text = 'ETAY';
      app.ETAYCheckBox.Position = [116 13 51 22];
      app.ETAYCheckBox.Value = true;

      % Create PLOTButton
      app.PLOTButton = uibutton(app.TwissParametersPanel, 'push');
      app.PLOTButton.ButtonPushedFcn = createCallbackFcn(app, @PLOTButtonPushed, true);
      app.PLOTButton.Position = [170 9 62 30];
      app.PLOTButton.Text = 'PLOT';

      % Show the figure after all components are created
      app.F2_LiveModelUIFigure.Visible = 'on';
    end
  end

  % App creation and deletion
  methods (Access = public)

    % Construct app
    function app = F2_LiveModel_exported

      % Create UIFigure and components
      createComponents(app)

      % Register the app with App Designer
      registerApp(app, app.F2_LiveModelUIFigure)

      % Execute the startup function
      runStartupFcn(app, @startupFcn)

      if nargout == 0
        clear app
      end
    end

    % Code that executes before app deletion
    function delete(app)

      % Delete UIFigure when app is deleted
      delete(app.F2_LiveModelUIFigure)
    end
  end
end