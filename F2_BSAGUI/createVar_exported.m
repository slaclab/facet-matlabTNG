classdef createVar_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        GridLayout                  matlab.ui.container.GridLayout
        AddPVEditField              matlab.ui.control.EditField
        AddButton                   matlab.ui.control.Button
        CalculateNewVariableButton  matlab.ui.control.Button
        PVsListBoxLabel             matlab.ui.control.Label
        PVList                      matlab.ui.control.ListBox
        FormulaTextAreaLabel        matlab.ui.control.Label
        FormulaTextArea             matlab.ui.control.TextArea
        PVsAddedListBoxLabel        matlab.ui.control.Label
        AddedPVs                    matlab.ui.control.ListBox
        ClearButton                 matlab.ui.control.Button
    end

    
    properties (Access = public)
        next_letter % holder for iterating variable letters
        mdl % BSA GUI model object holding data and state of app
        formula % entered formula
        PVC % output of formula
        formula_pvs % name of pvs used in the formula
        fields2save % struct of fields to save for next instance of the gui
        STDERR = 2
    end
    
    methods (Access = private)
        
        function activate(app)
            %Correct bug with edit fields on window open
            app.UIFigure.WindowState='minimized';
            drawnow();
            app.UIFigure.WindowState='normal';
            drawnow();
        end
        
        function errorMessage(app, ex, callbackMessage)
            err = ex.stack(1);
            file = err.file; funcname = err.name; linenum = num2str(err.line);
            file = strsplit(file, '/'); file = file{end};
            loc = sprintf('File: %s   Function: %s   Line: %s', file, funcname, linenum);
            uiwait(errordlg(...
                    lprintf(app.STDERR, '%s%c%s%c%s', callbackMessage, newline, ex.message, newline, loc)));
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mdl)
            app.mdl = mdl;
            app.PVList.Items = app.mdl.ROOT_NAME;
            app.next_letter = 'a'; % start letter for PV labeling
            
            saved_fields = app.mdl.createVar_fields;
            if ~isempty(saved_fields)
                % reload saved fields (pvs and formula)
                pvs2check = saved_fields.pvs;
                for p = 1:length(pvs2check)
                    pv = pvs2check{p};
                    pvs2check{p} = pv(3:length(pv));
                end
                % double check those pvs are still in the PV list
                if sum(contains(app.PVList.Items, pvs2check)) == length(saved_fields.pvs)
                    param_idx = strfind(saved_fields.formula{1}, ')');
                    param_idx = param_idx(1);
                    formulaStr = extractAfter(saved_fields.formula{1}, param_idx);
                    app.FormulaTextArea.Value = formulaStr;
                    app.AddedPVs.Items = saved_fields.pvs;
                end
            end
            
            % Time activate function to handle edit field glitch
            t = timer('TimerFcn',@(~,~)activate(app),'StartDelay',0.02,'Name','activator');
            start(t)
        end

        % Value changed function: PVList
        function PVListValueChanged(app, event)
            try
                app.AddPVEditField.Value = app.PVList.Value;
            catch ex
               errorMessage(app, ex, 'Error selecting PV.'); 
            end
        end

        % Value changing function: AddPVEditField
        function AddPVEditFieldValueChanging(app, event)
            try
                searchString = upper(event.Value);
                strs = split(searchString, '*');
                if length(strs) > 1
                    str1 = strs(1); str2 = strs(2);
                else
                    str1 = strs(1); str2 = str1;
                end
                searchIdx = contains(app.mdl.ROOT_NAME, str1) & contains(app.mdl.ROOT_NAME, str2);
                app.PVList.Items = app.mdl.ROOT_NAME(searchIdx);
            catch ex
                errorMessage(app, ex, 'Error searching PV list.');
            end
        end

        % Button pushed function: AddButton
        function AddButtonPushed(app, event)
            % when the add button is hit, add the variable AddedPVs field
            % with the incremented letter label
            try
                current_vars = app.AddedPVs.Items;
                new_var = app.AddPVEditField.Value;
                new_var_str = strcat(app.next_letter,'. ',new_var);
                app.next_letter = char(app.next_letter+1);
                if isempty(current_vars)
                    current_vars = {new_var_str};
                else
                    current_vars{length(current_vars)+1} = new_var_str;
                end
                app.AddedPVs.Items = current_vars;
                app.AddPVEditField.Value = '';
            catch ex
                errorMessage(app, ex, 'Error adding PV.'); 
            end
        end

        % Button pushed function: CalculateNewVariableButton
        function CalculateNewVariableButtonPushed(app, event)
            try
                formula_str_raw = app.FormulaTextArea.Value;
                pvs = app.AddedPVs.Items;
                calcVariable(app.mdl, formula_str_raw, pvs);
                delete(app);
            catch ex
                errorMessage(app, ex, 'Error calculating new variable.');
            end
        end

        % Button pushed function: ClearButton
        function ClearButtonPushed(app, event)
            app.FormulaTextArea.Value = '';
            app.AddedPVs.Items = {};
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 792 636];
            app.UIFigure.Name = 'MATLAB App';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'0.5x', '1.5x', '1.5x', '1x', '1x', '3x'};
            app.GridLayout.RowHeight = {'1x', '1.1x', '1.1x', '4x', '1.1x', '1.1x', '15.53x'};

            % Create AddPVEditField
            app.AddPVEditField = uieditfield(app.GridLayout, 'text');
            app.AddPVEditField.ValueChangingFcn = createCallbackFcn(app, @AddPVEditFieldValueChanging, true);
            app.AddPVEditField.FontSize = 16;
            app.AddPVEditField.Layout.Row = 2;
            app.AddPVEditField.Layout.Column = [2 3];

            % Create AddButton
            app.AddButton = uibutton(app.GridLayout, 'push');
            app.AddButton.ButtonPushedFcn = createCallbackFcn(app, @AddButtonPushed, true);
            app.AddButton.VerticalAlignment = 'top';
            app.AddButton.FontSize = 16;
            app.AddButton.Layout.Row = 2;
            app.AddButton.Layout.Column = 4;
            app.AddButton.Text = 'Add';

            % Create CalculateNewVariableButton
            app.CalculateNewVariableButton = uibutton(app.GridLayout, 'push');
            app.CalculateNewVariableButton.ButtonPushedFcn = createCallbackFcn(app, @CalculateNewVariableButtonPushed, true);
            app.CalculateNewVariableButton.FontSize = 16;
            app.CalculateNewVariableButton.Layout.Row = 5;
            app.CalculateNewVariableButton.Layout.Column = [2 3];
            app.CalculateNewVariableButton.Text = 'Calculate New Variable';

            % Create PVsListBoxLabel
            app.PVsListBoxLabel = uilabel(app.GridLayout);
            app.PVsListBoxLabel.HorizontalAlignment = 'center';
            app.PVsListBoxLabel.FontSize = 16;
            app.PVsListBoxLabel.Layout.Row = 2;
            app.PVsListBoxLabel.Layout.Column = 5;
            app.PVsListBoxLabel.Text = 'PVs';

            % Create PVList
            app.PVList = uilistbox(app.GridLayout);
            app.PVList.Items = {};
            app.PVList.ValueChangedFcn = createCallbackFcn(app, @PVListValueChanged, true);
            app.PVList.FontSize = 16;
            app.PVList.Layout.Row = [3 7];
            app.PVList.Layout.Column = [5 6];
            app.PVList.Value = {};

            % Create FormulaTextAreaLabel
            app.FormulaTextAreaLabel = uilabel(app.GridLayout);
            app.FormulaTextAreaLabel.FontSize = 16;
            app.FormulaTextAreaLabel.Layout.Row = 3;
            app.FormulaTextAreaLabel.Layout.Column = 2;
            app.FormulaTextAreaLabel.Text = 'Formula';

            % Create FormulaTextArea
            app.FormulaTextArea = uitextarea(app.GridLayout);
            app.FormulaTextArea.FontSize = 16;
            app.FormulaTextArea.Layout.Row = 4;
            app.FormulaTextArea.Layout.Column = [2 3];

            % Create PVsAddedListBoxLabel
            app.PVsAddedListBoxLabel = uilabel(app.GridLayout);
            app.PVsAddedListBoxLabel.FontSize = 16;
            app.PVsAddedListBoxLabel.Layout.Row = 6;
            app.PVsAddedListBoxLabel.Layout.Column = 2;
            app.PVsAddedListBoxLabel.Text = 'PVs Added';

            % Create AddedPVs
            app.AddedPVs = uilistbox(app.GridLayout);
            app.AddedPVs.Items = {};
            app.AddedPVs.FontSize = 16;
            app.AddedPVs.Layout.Row = 7;
            app.AddedPVs.Layout.Column = [2 3];
            app.AddedPVs.Value = {};

            % Create ClearButton
            app.ClearButton = uibutton(app.GridLayout, 'push');
            app.ClearButton.ButtonPushedFcn = createCallbackFcn(app, @ClearButtonPushed, true);
            app.ClearButton.VerticalAlignment = 'top';
            app.ClearButton.FontSize = 16;
            app.ClearButton.Layout.Row = 6;
            app.ClearButton.Layout.Column = 3;
            app.ClearButton.Text = 'Clear';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = createVar_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

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