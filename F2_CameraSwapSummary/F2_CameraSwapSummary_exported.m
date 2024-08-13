classdef F2_CameraSwapSummary_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        UITable                 matlab.ui.control.Table
        UIAxes                  matlab.ui.control.UIAxes
        CameraSwaps202324Label  matlab.ui.control.Label
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            data1 = load('Camera_Swap.mat','Camera_Swap');
            Camera_Swap = data1.Camera_Swap;
            app.UITable.Data = Camera_Swap;
            data2 = load('replacement_summary.mat','replacement_summary');
            replacement_summary = data2.replacement_summary;
            bar(app.UIAxes, replacement_summary.ReplacementCount);
            app.UIAxes.XTickLabel = replacement_summary.Name;
            title(app.UIAxes, 'Replacement Summary')
            xlabel(app.UIAxes,'Camera Name');
            ylabel(app.UIAxes,'Replacement Counts');
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.451 0 0.1333];
            app.UIFigure.Position = [100 100 1163 770];
            app.UIFigure.Name = 'MATLAB App';

            % Create UITable
            app.UITable = uitable(app.UIFigure);
            app.UITable.ColumnName = {'Camera Name'; 'Old SN'; 'New SN'; 'Old Reboot Count'};
            app.UITable.RowName = {};
            app.UITable.Position = [589 298 548 449];

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Title')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            app.UIAxes.FontSize = 10;
            app.UIAxes.Position = [12 19 1141 248];

            % Create CameraSwaps202324Label
            app.CameraSwaps202324Label = uilabel(app.UIFigure);
            app.CameraSwaps202324Label.FontSize = 50;
            app.CameraSwaps202324Label.FontWeight = 'bold';
            app.CameraSwaps202324Label.FontColor = [1 1 1];
            app.CameraSwaps202324Label.Position = [68 578 381 116];
            app.CameraSwaps202324Label.Text = {'Camera Swaps '; '2023-24'};

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_CameraSwapSummaey_exported

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