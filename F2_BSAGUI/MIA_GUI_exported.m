classdef MIA_GUI_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        MIAGUIUIFigure               matlab.ui.Figure
        GridLayout                   matlab.ui.container.GridLayout
        UIAxes                       matlab.ui.control.UIAxes
        ButtonGroup                  matlab.ui.container.ButtonGroup
        XButton                      matlab.ui.control.ToggleButton
        YButton                      matlab.ui.control.ToggleButton
        SpatialEigenvectorButton     matlab.ui.control.Button
        Reconstruct                  matlab.ui.control.Button
        BetatronAnalysisButton       matlab.ui.control.Button
        TemporalEigenvectorButton    matlab.ui.control.Button
        DegreesofFreedomButton       matlab.ui.control.Button
        CloseButton                  matlab.ui.control.Button
        PlotOrbitButton              matlab.ui.control.Button
        DoFLabel                     matlab.ui.control.Label
        DoF                          matlab.ui.control.NumericEditField
        EigenvectorEditFieldLabel    matlab.ui.control.Label
        SpatialEV                    matlab.ui.control.EditField
        EigenvectorEditFieldLabel_2  matlab.ui.control.Label
        TemporalEV                   matlab.ui.control.EditField
        BPMEditFieldLabel            matlab.ui.control.Label
        BPMEditField                 matlab.ui.control.NumericEditField
        BPMLabel                     matlab.ui.control.Label
        EigenvectorsLabel            matlab.ui.control.Label
        ReconstructionEVs            matlab.ui.control.EditField
    end

    
    properties (Access = private)
        BG_mdl % BSA GUI model object holding data and state of app
        MIA_mdl % MIA GUI model object holding data and state of app
        STDERR = 2
    end
    
    methods
        
        function plotInit(app)
            % plot the singular values
            coors = ["Y","X"];
            coor = coors(app.XButton.Value + 1);
            plot(app.UIAxes, app.MIA_mdl.(coor).S,'*');
            yline(app.UIAxes,0);
            app.UIAxes.XLabel.String = 'Singular Value Sequence';
            app.UIAxes.YLabel.String = 'Singular Value';
            app.UIAxes.Title.String = 'Singular Value Decomposition';
        end

        function errorMessage(app, ex, callbackMessage)
            err = ex.stack(1);
            file = err.file; funcname = err.name; linenum = num2str(err.line);
            file = strsplit(file, '/'); file = file{end};
            loc = sprintf('File: %s   Function: %s   Line: %s', file, funcname, linenum);
            uiwait(errordlg(...
                    lprintf(app.STDERR, '%s%c%s%c%s', callbackMessage, newline, ex.message, newline, loc)));
        end
    
        function activate(app)
            %Correct bug with edit fields on window open
            app.MIAGUIUIFigure.WindowState='minimized';
            drawnow();
            app.MIAGUIUIFigure.WindowState='normal';
            drawnow();
        end
        
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, BG_mdl)
            app.BG_mdl = BG_mdl;
            app.MIA_mdl = MIA_GUI_model(app, app.BG_mdl);
            plotInit(app);
            
            setup_dispersion(app.MIA_mdl);
            
            % Time activate function to handle edit field glitch
            t = timer('TimerFcn',@(~,~)activate(app),'StartDelay',0.02,'Name','activator');
            start(t)
        end

        % Selection changed function: ButtonGroup
        function ButtonGroupSelectionChanged(app, event)
            try
                coors = ["Y","X"];
                coor = coors(app.XButton.Value + 1);
                plot(app.UIAxes, app.MIA_mdl.(coor).S,'*');
                yline(app.UIAxes,0);
            catch ex
                errorMessage(app, ex, 'Error changing coordinate.'); 
            end
        end

        % Button pushed function: SpatialEigenvectorButton
        function SpatialEigenvectorButtonPushed(app, event)
            % create a stacked plot for the user specified list of
            % spatial eigenvectors for the user specified coordinate
            try
                coors = ["Y","X"];
                coor_str = coors(app.XButton.Value + 1);
                coor = app.MIA_mdl.(coor_str);
                
                evs = str2num(app.SpatialEV.Value);
                
                disp_bpms = app.MIA_mdl.dispersion.(coor_str).(app.MIA_mdl.beamLine);
                eta_idx = contains(coor.bpm_names,disp_bpms);
                
                all_bpms = coor.V(:,evs);
                disp_bpms = coor.V(eta_idx,evs);
                
                
                f=figure();
                sp=stackedplot(f,all_bpms);
                sp.DisplayLabels = num2cell(evs,1);
                sp.Title = 'Selected Spatial Eigenvectors';
                sp.XLabel = 'BPM #';
                lim = max(abs(coor.V(:,evs)),[],'all') * 1.05;
                for p = 1:length(evs)
                    sp.AxesProperties(p).YLimits = [-lim,lim];
                end
            catch ex
                errorMessage(app, ex, 'Error plotting spatial eigenvectors.');
            end
        end

        % Button pushed function: TemporalEigenvectorButton
        function TemporalEigenvectorButtonPushed(app, event)
            % create a stacked plot for the user specified list of
            % temporal eigenvectors for the user specified coordinate
            try
                coors = ["Y","X"];
                coor = coors(app.XButton.Value +1);
                coor = app.MIA_mdl.(coor);
                
                evs = str2num(app.TemporalEV.Value);
               
                f = figure;
                sp = stackedplot(f,coor.U(:,evs),'DisplayLabels',num2cell(evs,1),'Title','Selected Temporal Eigenvectors','XLabel','Pulse #');
            catch ex
                errorMessage(app, ex, 'Error plotting temporal eigenvectors.');
            end
        end

        % Button pushed function: DegreesofFreedomButton
        function DegreesofFreedomButtonPushed(app, event)
            % Create degrees of freedom plot
            try
                app.DegreesofFreedomButton.Text='...calculating';
                drawnow();
                dof = app.DoF.Value; % add edit field for DoF total
                coors = ["Y","X"];
                coor = coors(app.XButton.Value +1);
                degreesOfFreedomPlot(app.MIA_mdl, coor, dof);
                app.DegreesofFreedomButton.Text='Degress of Freedom';
                drawnow();
            catch ex
                errorMessage(app, ex, 'Error plotting degrees of freedom.');
                app.DegreesofFreedomButton.Text='Degress of Freedom';
            end
        end

        % Button pushed function: Reconstruct
        function ReconstructPushed(app, event)
            % reconstruct the data with only the selected eigenvectors
            try
                app.Reconstruct.Text='Reconstructing...';
                
                coors = ["Y","X"];
                coor_str = coors(app.XButton.Value +1);
                evs = str2num(app.ReconstructionEVs.Value);
                
                reconstruct(app.MIA_mdl, coor_str, evs);
                
                app.Reconstruct.Text='Done';
                pause(1);
                app.Reconstruct.Text='Reconstruct';
            catch ex
                errorMessage(app, ex, 'Error reconstructing data matrix.');
                app.Reconstruct.Text='Reconstruct';
            end
        end

        % Button pushed function: PlotOrbitButton
        function PlotOrbitButtonPushed(app, event)
            % open the Plot Orbit GUI with the newly constructed data
            try
                coors = ["Y","X"];
                coor = coors(app.XButton.Value +1);
                coor = app.MIA_mdl.(coor);
                
                % requires a special instance of the BSA_GUI so it does not
                % change with the original data
                BSA_instance = struct();
                BSA_instance.isBR =  app.BG_mdl.isBR;
                BSA_instance.isSxr = app.BG_mdl.isSxr;
                BSA_instance.isHxr = app.BG_mdl.isHxr;
                BSA_instance.ROOT_NAME = app.BG_mdl.ROOT_NAME;
                BSA_instance.the_matrix = app.BG_mdl.the_matrix;
                BSA_instance.fileName = app.BG_mdl.fileName;
                BSA_instance.time_stamps = app.BG_mdl.time_stamps;
                BSA_instance.t_stamp = app.BG_mdl.t_stamp;
                bpm_idx = app.BG_mdl.bpms.x_id;
                BSA_instance.the_matrix(bpm_idx,:) = coor.reconstructed;
                
                BPM_Orbit(BSA_instance);
            catch ex
                errorMessage(app, ex, 'Error opening orbit plotter.');
            end
        end

        % Value changed function: BPMEditField
        function BPMEditFieldValueChanged(app, event)
            try
                coors = ["Y","X"];
                coor = coors(app.XButton.Value +1);
                coor = app.MIA_mdl.(coor);
                bpm_num = app.BPMEditField.Value;
                if bpm_num ~= 0
                    app.BPMLabel.Text =  coor.bpm_names(bpm_num);
                    drawnow();
                end
            catch ex
                errorMessage(app, ex, 'Error searching for BPM'); 
            end
        end

        % Button pushed function: CloseButton
        function CloseButtonPushed(app, event)
            delete(app)
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create MIAGUIUIFigure and hide until all components are created
            app.MIAGUIUIFigure = uifigure('Visible', 'off');
            app.MIAGUIUIFigure.Position = [100 100 905 609];
            app.MIAGUIUIFigure.Name = 'MIA GUI';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.MIAGUIUIFigure);
            app.GridLayout.ColumnWidth = {'1x', '1x', '1x', '0.5x', '0.5x', '1x', '1x', '0.5x', '0.25x'};
            app.GridLayout.RowHeight = {'1x', '1x', '0.75x', '1x', '0.75x', '1x', '0.75x', '1x', '0.75x', '1x', '1x', '1x', '1x', '1x'};

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout);
            title(app.UIAxes, 'Title')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            app.UIAxes.FontSize = 14;
            app.UIAxes.Layout.Row = [1 12];
            app.UIAxes.Layout.Column = [1 6];

            % Create ButtonGroup
            app.ButtonGroup = uibuttongroup(app.GridLayout);
            app.ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ButtonGroupSelectionChanged, true);
            app.ButtonGroup.BorderType = 'none';
            app.ButtonGroup.Layout.Row = 13;
            app.ButtonGroup.Layout.Column = 3;

            % Create XButton
            app.XButton = uitogglebutton(app.ButtonGroup);
            app.XButton.Text = 'X';
            app.XButton.FontSize = 16;
            app.XButton.Position = [5 0 40 27];
            app.XButton.Value = true;

            % Create YButton
            app.YButton = uitogglebutton(app.ButtonGroup);
            app.YButton.Text = 'Y';
            app.YButton.FontSize = 16;
            app.YButton.Position = [45 0 40 27];

            % Create SpatialEigenvectorButton
            app.SpatialEigenvectorButton = uibutton(app.GridLayout, 'push');
            app.SpatialEigenvectorButton.ButtonPushedFcn = createCallbackFcn(app, @SpatialEigenvectorButtonPushed, true);
            app.SpatialEigenvectorButton.FontSize = 16;
            app.SpatialEigenvectorButton.Layout.Row = 2;
            app.SpatialEigenvectorButton.Layout.Column = [7 8];
            app.SpatialEigenvectorButton.Text = 'Spatial Eigenvector';

            % Create Reconstruct
            app.Reconstruct = uibutton(app.GridLayout, 'push');
            app.Reconstruct.ButtonPushedFcn = createCallbackFcn(app, @ReconstructPushed, true);
            app.Reconstruct.FontSize = 16;
            app.Reconstruct.Layout.Row = 8;
            app.Reconstruct.Layout.Column = [7 8];
            app.Reconstruct.Text = 'Reconstruct';

            % Create BetatronAnalysisButton
            app.BetatronAnalysisButton = uibutton(app.GridLayout, 'push');
            app.BetatronAnalysisButton.FontSize = 16;
            app.BetatronAnalysisButton.Enable = 'off';
            app.BetatronAnalysisButton.Visible = 'off';
            app.BetatronAnalysisButton.Layout.Row = 10;
            app.BetatronAnalysisButton.Layout.Column = [7 8];
            app.BetatronAnalysisButton.Text = 'Betatron Analysis';

            % Create TemporalEigenvectorButton
            app.TemporalEigenvectorButton = uibutton(app.GridLayout, 'push');
            app.TemporalEigenvectorButton.ButtonPushedFcn = createCallbackFcn(app, @TemporalEigenvectorButtonPushed, true);
            app.TemporalEigenvectorButton.FontSize = 16;
            app.TemporalEigenvectorButton.Layout.Row = 4;
            app.TemporalEigenvectorButton.Layout.Column = [7 8];
            app.TemporalEigenvectorButton.Text = 'Temporal Eigenvector';

            % Create DegreesofFreedomButton
            app.DegreesofFreedomButton = uibutton(app.GridLayout, 'push');
            app.DegreesofFreedomButton.ButtonPushedFcn = createCallbackFcn(app, @DegreesofFreedomButtonPushed, true);
            app.DegreesofFreedomButton.FontSize = 16;
            app.DegreesofFreedomButton.Layout.Row = 6;
            app.DegreesofFreedomButton.Layout.Column = [7 8];
            app.DegreesofFreedomButton.Text = 'Degrees of Freedom ';

            % Create CloseButton
            app.CloseButton = uibutton(app.GridLayout, 'push');
            app.CloseButton.ButtonPushedFcn = createCallbackFcn(app, @CloseButtonPushed, true);
            app.CloseButton.Layout.Row = 14;
            app.CloseButton.Layout.Column = [8 9];
            app.CloseButton.Text = 'Close';

            % Create PlotOrbitButton
            app.PlotOrbitButton = uibutton(app.GridLayout, 'push');
            app.PlotOrbitButton.ButtonPushedFcn = createCallbackFcn(app, @PlotOrbitButtonPushed, true);
            app.PlotOrbitButton.FontSize = 16;
            app.PlotOrbitButton.Layout.Row = 12;
            app.PlotOrbitButton.Layout.Column = [7 8];
            app.PlotOrbitButton.Text = 'Plot Orbit';

            % Create DoFLabel
            app.DoFLabel = uilabel(app.GridLayout);
            app.DoFLabel.HorizontalAlignment = 'right';
            app.DoFLabel.Layout.Row = 7;
            app.DoFLabel.Layout.Column = 7;
            app.DoFLabel.Text = '# DoF';

            % Create DoF
            app.DoF = uieditfield(app.GridLayout, 'numeric');
            app.DoF.HorizontalAlignment = 'center';
            app.DoF.Layout.Row = 7;
            app.DoF.Layout.Column = 8;
            app.DoF.Value = 10;

            % Create EigenvectorEditFieldLabel
            app.EigenvectorEditFieldLabel = uilabel(app.GridLayout);
            app.EigenvectorEditFieldLabel.HorizontalAlignment = 'right';
            app.EigenvectorEditFieldLabel.Layout.Row = 3;
            app.EigenvectorEditFieldLabel.Layout.Column = 7;
            app.EigenvectorEditFieldLabel.Text = 'Eigenvector #';

            % Create SpatialEV
            app.SpatialEV = uieditfield(app.GridLayout, 'text');
            app.SpatialEV.Layout.Row = 3;
            app.SpatialEV.Layout.Column = 8;
            app.SpatialEV.Value = '1';

            % Create EigenvectorEditFieldLabel_2
            app.EigenvectorEditFieldLabel_2 = uilabel(app.GridLayout);
            app.EigenvectorEditFieldLabel_2.HorizontalAlignment = 'right';
            app.EigenvectorEditFieldLabel_2.Layout.Row = 5;
            app.EigenvectorEditFieldLabel_2.Layout.Column = 7;
            app.EigenvectorEditFieldLabel_2.Text = 'Eigenvector #';

            % Create TemporalEV
            app.TemporalEV = uieditfield(app.GridLayout, 'text');
            app.TemporalEV.Layout.Row = 5;
            app.TemporalEV.Layout.Column = 8;
            app.TemporalEV.Value = '1';

            % Create BPMEditFieldLabel
            app.BPMEditFieldLabel = uilabel(app.GridLayout);
            app.BPMEditFieldLabel.HorizontalAlignment = 'right';
            app.BPMEditFieldLabel.Layout.Row = 13;
            app.BPMEditFieldLabel.Layout.Column = 4;
            app.BPMEditFieldLabel.Text = 'BPM #';

            % Create BPMEditField
            app.BPMEditField = uieditfield(app.GridLayout, 'numeric');
            app.BPMEditField.ValueChangedFcn = createCallbackFcn(app, @BPMEditFieldValueChanged, true);
            app.BPMEditField.HorizontalAlignment = 'center';
            app.BPMEditField.Layout.Row = 13;
            app.BPMEditField.Layout.Column = 5;

            % Create BPMLabel
            app.BPMLabel = uilabel(app.GridLayout);
            app.BPMLabel.FontSize = 16;
            app.BPMLabel.Layout.Row = 13;
            app.BPMLabel.Layout.Column = [6 7];
            app.BPMLabel.Text = '';

            % Create EigenvectorsLabel
            app.EigenvectorsLabel = uilabel(app.GridLayout);
            app.EigenvectorsLabel.HorizontalAlignment = 'right';
            app.EigenvectorsLabel.Layout.Row = 9;
            app.EigenvectorsLabel.Layout.Column = 7;
            app.EigenvectorsLabel.Text = 'Eigenvectors';

            % Create ReconstructionEVs
            app.ReconstructionEVs = uieditfield(app.GridLayout, 'text');
            app.ReconstructionEVs.Layout.Row = 9;
            app.ReconstructionEVs.Layout.Column = 8;
            app.ReconstructionEVs.Value = '1';

            % Show the figure after all components are created
            app.MIAGUIUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = MIA_GUI_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.MIAGUIUIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.MIAGUIUIFigure)
        end
    end
end