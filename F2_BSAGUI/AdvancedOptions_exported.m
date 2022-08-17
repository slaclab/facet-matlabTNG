classdef AdvancedOptions_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        BSAGUIOptionsUIFigure        matlab.ui.Figure
        GridLayout                   matlab.ui.container.GridLayout
        AllZOptionsPanel             matlab.ui.container.Panel
        GridLayout2                  matlab.ui.container.GridLayout
        AllBSACorrCheckBox           matlab.ui.control.CheckBox
        HorzNormRMSCheckBox          matlab.ui.control.CheckBox
        XBPMCorrCheckBox             matlab.ui.control.CheckBox
        VertNormRMSCheckBox          matlab.ui.control.CheckBox
        YBPMCorrCheckBox             matlab.ui.control.CheckBox
        XYFactorCheckBox             matlab.ui.control.CheckBox
        DispersionCheckBox           matlab.ui.control.CheckBox
        HorzRMSCheckBox              matlab.ui.control.CheckBox
        VertRMSCheckBox              matlab.ui.control.CheckBox
        ModelBeamSigmaCheckBox       matlab.ui.control.CheckBox
        HorzNoDispersionCheckBox     matlab.ui.control.CheckBox
        ModelBeamEnergyCheckBox      matlab.ui.control.CheckBox
        NewModelCheckBox             matlab.ui.control.CheckBox
        GridLayout3                  matlab.ui.container.GridLayout
        MultiplotOptionsButtonGroup  matlab.ui.container.ButtonGroup
        SeparateFigure               matlab.ui.control.RadioButton
        SameFigure                   matlab.ui.control.RadioButton
        GridLayout4                  matlab.ui.container.GridLayout
        ExportdatatoworkspaceButton  matlab.ui.control.Button
    end

    
    properties (Access = private)
        mdl % BSA_GUI app
        options % struct of selected options
        STDERR = 2
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mdl)
            app.mdl = mdl;
            
            if ~isempty(app.mdl.z_options)
                app.options = app.mdl.z_options;
                
                app.NewModelCheckBox.Value = app.options.NewModel;
            
                app.AllBSACorrCheckBox.Value = app.options.AllBSA;
                app.XBPMCorrCheckBox.Value = app.options.XBPMCorr;
                app.YBPMCorrCheckBox.Value = app.options.YBPMCorr;
                app.XYFactorCheckBox.Value = app.options.XYFactor;            
                app.DispersionCheckBox.Value = app.options.Dispersion;
                app.HorzNoDispersionCheckBox.Value = app.options.HorzNoDispersion;
                app.HorzNormRMSCheckBox.Value = app.options.HorzNormRMS;
                app.VertNormRMSCheckBox.Value = app.options.VertNormRMS;
                app.HorzRMSCheckBox.Value = app.options.HorzRMS;
                app.VertRMSCheckBox.Value = app.options.VertRMS;
                app.ModelBeamSigmaCheckBox.Value = app.options.ModelBeamSigma;
                app.ModelBeamEnergyCheckBox.Value = app.options.ModelBeamEnergy;
                
            end
            
            app.SameFigure.Value = app.mdl.multiplot_same;
        end

        % Selection changed function: MultiplotOptionsButtonGroup
        function MultiplotOptionsButtonGroupSelectionChanged(app, event)
            selectedButton = app.MultiplotOptionsButtonGroup.SelectedObject;
            multiplotOptionChanged(app.mdl, selectedButton);
        end

        % Button pushed function: ExportdatatoworkspaceButton
        function ExportdatatoworkspaceButtonPushed(app, event)
            exportToWorkspace(app.mdl);
        end

        % Value changed function: AllBSACorrCheckBox, 
        % DispersionCheckBox, HorzNoDispersionCheckBox, 
        % HorzNormRMSCheckBox, HorzRMSCheckBox, 
        % ModelBeamEnergyCheckBox, ModelBeamSigmaCheckBox, 
        % NewModelCheckBox, VertNormRMSCheckBox, VertRMSCheckBox, 
        % XBPMCorrCheckBox, XYFactorCheckBox, YBPMCorrCheckBox
        function ZOptValueChanged(app, event)
            value = event.Source.Value;
            field = event.Source.Tag;
            updateZOptions(app.mdl, value, field);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create BSAGUIOptionsUIFigure and hide until all components are created
            app.BSAGUIOptionsUIFigure = uifigure('Visible', 'off');
            app.BSAGUIOptionsUIFigure.Position = [100 100 899 428];
            app.BSAGUIOptionsUIFigure.Name = 'BSA GUI Options';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.BSAGUIOptionsUIFigure);
            app.GridLayout.ColumnWidth = {'1x', '1.5x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 20;

            % Create AllZOptionsPanel
            app.AllZOptionsPanel = uipanel(app.GridLayout);
            app.AllZOptionsPanel.BorderType = 'none';
            app.AllZOptionsPanel.Title = 'All Z Options';
            app.AllZOptionsPanel.Layout.Row = 1;
            app.AllZOptionsPanel.Layout.Column = 2;
            app.AllZOptionsPanel.FontSize = 16;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.AllZOptionsPanel);
            app.GridLayout2.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout2.ColumnSpacing = 0;
            app.GridLayout2.RowSpacing = 0;
            app.GridLayout2.Padding = [0 0 0 0];

            % Create AllBSACorrCheckBox
            app.AllBSACorrCheckBox = uicheckbox(app.GridLayout2);
            app.AllBSACorrCheckBox.ValueChangedFcn = createCallbackFcn(app, @ZOptValueChanged, true);
            app.AllBSACorrCheckBox.Tag = 'AllBSA';
            app.AllBSACorrCheckBox.Text = 'All BSA Corr';
            app.AllBSACorrCheckBox.FontSize = 16;
            app.AllBSACorrCheckBox.Layout.Row = 1;
            app.AllBSACorrCheckBox.Layout.Column = 1;
            app.AllBSACorrCheckBox.Value = true;

            % Create HorzNormRMSCheckBox
            app.HorzNormRMSCheckBox = uicheckbox(app.GridLayout2);
            app.HorzNormRMSCheckBox.ValueChangedFcn = createCallbackFcn(app, @ZOptValueChanged, true);
            app.HorzNormRMSCheckBox.Tag = 'HorzNormRMS';
            app.HorzNormRMSCheckBox.Text = 'Horz Norm RMS';
            app.HorzNormRMSCheckBox.FontSize = 16;
            app.HorzNormRMSCheckBox.Layout.Row = 1;
            app.HorzNormRMSCheckBox.Layout.Column = 2;
            app.HorzNormRMSCheckBox.Value = true;

            % Create XBPMCorrCheckBox
            app.XBPMCorrCheckBox = uicheckbox(app.GridLayout2);
            app.XBPMCorrCheckBox.ValueChangedFcn = createCallbackFcn(app, @ZOptValueChanged, true);
            app.XBPMCorrCheckBox.Tag = 'XPMBCorr';
            app.XBPMCorrCheckBox.Text = 'X BPM Corr';
            app.XBPMCorrCheckBox.FontSize = 16;
            app.XBPMCorrCheckBox.Layout.Row = 2;
            app.XBPMCorrCheckBox.Layout.Column = 1;
            app.XBPMCorrCheckBox.Value = true;

            % Create VertNormRMSCheckBox
            app.VertNormRMSCheckBox = uicheckbox(app.GridLayout2);
            app.VertNormRMSCheckBox.ValueChangedFcn = createCallbackFcn(app, @ZOptValueChanged, true);
            app.VertNormRMSCheckBox.Tag = 'VertNormRMS';
            app.VertNormRMSCheckBox.Text = 'Vert Norm RMS';
            app.VertNormRMSCheckBox.FontSize = 16;
            app.VertNormRMSCheckBox.Layout.Row = 2;
            app.VertNormRMSCheckBox.Layout.Column = 2;
            app.VertNormRMSCheckBox.Value = true;

            % Create YBPMCorrCheckBox
            app.YBPMCorrCheckBox = uicheckbox(app.GridLayout2);
            app.YBPMCorrCheckBox.ValueChangedFcn = createCallbackFcn(app, @ZOptValueChanged, true);
            app.YBPMCorrCheckBox.Tag = 'YBPMCorr';
            app.YBPMCorrCheckBox.Text = 'Y BPM Corr';
            app.YBPMCorrCheckBox.FontSize = 16;
            app.YBPMCorrCheckBox.Layout.Row = 3;
            app.YBPMCorrCheckBox.Layout.Column = 1;
            app.YBPMCorrCheckBox.Value = true;

            % Create XYFactorCheckBox
            app.XYFactorCheckBox = uicheckbox(app.GridLayout2);
            app.XYFactorCheckBox.ValueChangedFcn = createCallbackFcn(app, @ZOptValueChanged, true);
            app.XYFactorCheckBox.Tag = 'XYFactor';
            app.XYFactorCheckBox.Text = 'XY Factor';
            app.XYFactorCheckBox.FontSize = 16;
            app.XYFactorCheckBox.Layout.Row = 4;
            app.XYFactorCheckBox.Layout.Column = 1;
            app.XYFactorCheckBox.Value = true;

            % Create DispersionCheckBox
            app.DispersionCheckBox = uicheckbox(app.GridLayout2);
            app.DispersionCheckBox.ValueChangedFcn = createCallbackFcn(app, @ZOptValueChanged, true);
            app.DispersionCheckBox.Tag = 'Dispersion';
            app.DispersionCheckBox.Text = 'Dispersion';
            app.DispersionCheckBox.FontSize = 16;
            app.DispersionCheckBox.Layout.Row = 5;
            app.DispersionCheckBox.Layout.Column = 1;
            app.DispersionCheckBox.Value = true;

            % Create HorzRMSCheckBox
            app.HorzRMSCheckBox = uicheckbox(app.GridLayout2);
            app.HorzRMSCheckBox.ValueChangedFcn = createCallbackFcn(app, @ZOptValueChanged, true);
            app.HorzRMSCheckBox.Tag = 'HorzRMS';
            app.HorzRMSCheckBox.Text = 'Horz RMS';
            app.HorzRMSCheckBox.FontSize = 16;
            app.HorzRMSCheckBox.Layout.Row = 3;
            app.HorzRMSCheckBox.Layout.Column = 2;
            app.HorzRMSCheckBox.Value = true;

            % Create VertRMSCheckBox
            app.VertRMSCheckBox = uicheckbox(app.GridLayout2);
            app.VertRMSCheckBox.ValueChangedFcn = createCallbackFcn(app, @ZOptValueChanged, true);
            app.VertRMSCheckBox.Tag = 'VertRMS';
            app.VertRMSCheckBox.Text = 'Vert RMS';
            app.VertRMSCheckBox.FontSize = 16;
            app.VertRMSCheckBox.Layout.Row = 4;
            app.VertRMSCheckBox.Layout.Column = 2;
            app.VertRMSCheckBox.Value = true;

            % Create ModelBeamSigmaCheckBox
            app.ModelBeamSigmaCheckBox = uicheckbox(app.GridLayout2);
            app.ModelBeamSigmaCheckBox.ValueChangedFcn = createCallbackFcn(app, @ZOptValueChanged, true);
            app.ModelBeamSigmaCheckBox.Tag = 'ModelBeamSigma';
            app.ModelBeamSigmaCheckBox.Text = 'Model Beam Sigma';
            app.ModelBeamSigmaCheckBox.FontSize = 16;
            app.ModelBeamSigmaCheckBox.Layout.Row = 5;
            app.ModelBeamSigmaCheckBox.Layout.Column = 2;
            app.ModelBeamSigmaCheckBox.Value = true;

            % Create HorzNoDispersionCheckBox
            app.HorzNoDispersionCheckBox = uicheckbox(app.GridLayout2);
            app.HorzNoDispersionCheckBox.ValueChangedFcn = createCallbackFcn(app, @ZOptValueChanged, true);
            app.HorzNoDispersionCheckBox.Tag = 'HorzNoDispersion';
            app.HorzNoDispersionCheckBox.Text = 'Horz No Dispersion';
            app.HorzNoDispersionCheckBox.FontSize = 16;
            app.HorzNoDispersionCheckBox.Layout.Row = 6;
            app.HorzNoDispersionCheckBox.Layout.Column = 1;
            app.HorzNoDispersionCheckBox.Value = true;

            % Create ModelBeamEnergyCheckBox
            app.ModelBeamEnergyCheckBox = uicheckbox(app.GridLayout2);
            app.ModelBeamEnergyCheckBox.ValueChangedFcn = createCallbackFcn(app, @ZOptValueChanged, true);
            app.ModelBeamEnergyCheckBox.Tag = 'ModelBeamEnergy';
            app.ModelBeamEnergyCheckBox.Text = 'Model Beam Energy';
            app.ModelBeamEnergyCheckBox.FontSize = 16;
            app.ModelBeamEnergyCheckBox.Layout.Row = 6;
            app.ModelBeamEnergyCheckBox.Layout.Column = 2;
            app.ModelBeamEnergyCheckBox.Value = true;

            % Create NewModelCheckBox
            app.NewModelCheckBox = uicheckbox(app.GridLayout2);
            app.NewModelCheckBox.ValueChangedFcn = createCallbackFcn(app, @ZOptValueChanged, true);
            app.NewModelCheckBox.Tag = 'NewModel';
            app.NewModelCheckBox.Text = 'New Model';
            app.NewModelCheckBox.FontSize = 16;
            app.NewModelCheckBox.Layout.Row = 7;
            app.NewModelCheckBox.Layout.Column = 2;

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout);
            app.GridLayout3.ColumnWidth = {'1x'};
            app.GridLayout3.RowHeight = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout3.ColumnSpacing = 0;
            app.GridLayout3.RowSpacing = 0;
            app.GridLayout3.Padding = [0 0 0 0];
            app.GridLayout3.Layout.Row = 1;
            app.GridLayout3.Layout.Column = 1;

            % Create MultiplotOptionsButtonGroup
            app.MultiplotOptionsButtonGroup = uibuttongroup(app.GridLayout3);
            app.MultiplotOptionsButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @MultiplotOptionsButtonGroupSelectionChanged, true);
            app.MultiplotOptionsButtonGroup.BorderType = 'none';
            app.MultiplotOptionsButtonGroup.Title = 'Multiplot Options';
            app.MultiplotOptionsButtonGroup.Layout.Row = [1 2];
            app.MultiplotOptionsButtonGroup.Layout.Column = 1;
            app.MultiplotOptionsButtonGroup.FontSize = 16;

            % Create SeparateFigure
            app.SeparateFigure = uiradiobutton(app.MultiplotOptionsButtonGroup);
            app.SeparateFigure.Tag = 'separate';
            app.SeparateFigure.Text = 'Plot traces on separate figures';
            app.SeparateFigure.FontSize = 16;
            app.SeparateFigure.Position = [11 100 239 22];
            app.SeparateFigure.Value = true;

            % Create SameFigure
            app.SameFigure = uiradiobutton(app.MultiplotOptionsButtonGroup);
            app.SameFigure.Tag = 'same';
            app.SameFigure.Text = 'Plot traces on same figure';
            app.SameFigure.FontSize = 16;
            app.SameFigure.Position = [11 70 207 22];

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout3);
            app.GridLayout4.ColumnWidth = {'0.125x', '1x', '0.25x'};
            app.GridLayout4.RowHeight = {'1x'};
            app.GridLayout4.ColumnSpacing = 0;
            app.GridLayout4.RowSpacing = 0;
            app.GridLayout4.Padding = [0 0 0 0];
            app.GridLayout4.Layout.Row = 4;
            app.GridLayout4.Layout.Column = 1;

            % Create ExportdatatoworkspaceButton
            app.ExportdatatoworkspaceButton = uibutton(app.GridLayout4, 'push');
            app.ExportdatatoworkspaceButton.ButtonPushedFcn = createCallbackFcn(app, @ExportdatatoworkspaceButtonPushed, true);
            app.ExportdatatoworkspaceButton.FontSize = 16;
            app.ExportdatatoworkspaceButton.Layout.Row = 1;
            app.ExportdatatoworkspaceButton.Layout.Column = 2;
            app.ExportdatatoworkspaceButton.Text = 'Export data to workspace';

            % Show the figure after all components are created
            app.BSAGUIOptionsUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = AdvancedOptionsExported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.BSAGUIOptionsUIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.BSAGUIOptionsUIFigure)
        end
    end
end