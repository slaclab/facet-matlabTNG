classdef CathodeServices_limits_exported < matlab.apps.AppBase

  % Properties that correspond to app components
  properties (Access = public)
    CathideServicesAPPLimitsUIFigure  matlab.ui.Figure
    UITable  matlab.ui.control.Table
  end

  
  properties (Access = public)
    aobj % calling application object
  end
  

  % Callbacks that handle component events
  methods (Access = private)

    % Code that executes after component creation
    function startupFcn(app, appobj)
      app.aobj = appobj ;
      tdat=zeros(2,5);
      tdat(:,1)=appobj.GunVacuumRange(:);
      tdat(:,2)=appobj.ImageIntensityRange(:);
      tdat(:,3)=appobj.LaserEnergyRange(:);
      tdat(:,4)=appobj.LaserSpotSizeRange(:);
      tdat(:,5)=appobj.LaserFluenceRange(:);
      app.UITable.Data=tdat;
    end

    % Cell selection callback: UITable
    function UITableCellSelection(app, event)
%       indices = event.Indices;
%       disp(indices)
    end

    % Cell edit callback: UITable
    function UITableCellEdit(app, event)
      indices = event.Indices;
      newData = event.NewData;
      switch indices(2)
        case 1
          rdat=app.aobj.GunVacuumRange;
          rdat(indices(1))=newData;
          SetLimits(app.aobj,"GunVacuumRange",rdat);
        case 2
          rdat=app.aobj.ImageIntensityRange;
          rdat(indices(1))=newData;
          SetLimits(app.aobj,"ImageIntensityRange",rdat);
        case 3
          rdat=app.aobj.LaserEnergyRange;
          rdat(indices(1))=newData;
          SetLimits(app.aobj,"LaserEnergyRange",rdat);
        case 4
          rdat=app.aobj.LaserSpotSizeRange;
          rdat(indices(1))=newData;
          SetLimits(app.aobj,"LaserSpotSizeRange",rdat);
        case 5
          rdat=app.aobj.LaserFluenceRange;
          rdat(indices(1))=newData;
          SetLimits(app.aobj,"LaserFluenceRange",rdat);
      end
    end
  end

  % Component initialization
  methods (Access = private)

    % Create UIFigure and components
    function createComponents(app)

      % Create CathideServicesAPPLimitsUIFigure and hide until all components are created
      app.CathideServicesAPPLimitsUIFigure = uifigure('Visible', 'off');
      app.CathideServicesAPPLimitsUIFigure.Position = [100 100 791 109];
      app.CathideServicesAPPLimitsUIFigure.Name = 'Cathide Services APP Limits';

      % Create UITable
      app.UITable = uitable(app.CathideServicesAPPLimitsUIFigure);
      app.UITable.ColumnName = {'Gun Vacuum (nTorr)'; 'Image Intensity'; 'Laser Energy (uJ)'; 'Laser Spot Size (um)'; 'Laser Fluence (uJ/mm^2)'};
      app.UITable.RowName = {'Min'; 'Max'};
      app.UITable.ColumnEditable = true;
      app.UITable.CellEditCallback = createCallbackFcn(app, @UITableCellEdit, true);
      app.UITable.CellSelectionCallback = createCallbackFcn(app, @UITableCellSelection, true);
      app.UITable.Position = [1 0 791 110];

      % Show the figure after all components are created
      app.CathideServicesAPPLimitsUIFigure.Visible = 'on';
    end
  end

  % App creation and deletion
  methods (Access = public)

    % Construct app
    function app = CathodeServices_limits_exported(varargin)

      % Create UIFigure and components
      createComponents(app)

      % Register the app with App Designer
      registerApp(app, app.CathideServicesAPPLimitsUIFigure)

      % Execute the startup function
      runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

      if nargout == 0
        clear app
      end
    end

    % Code that executes before app deletion
    function delete(app)

      % Delete UIFigure when app is deleted
      delete(app.CathideServicesAPPLimitsUIFigure)
    end
  end
end