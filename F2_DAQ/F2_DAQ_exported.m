classdef F2_DAQ_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        FACETIIDAQUIFigure             matlab.ui.Figure
        DAQSettingsPanel               matlab.ui.container.Panel
        ExperimentDropDownLabel        matlab.ui.control.Label
        ExperimentDropDown             matlab.ui.control.DropDown
        CommentTextArea                matlab.ui.control.TextArea
        ShotsperstepEditFieldLabel     matlab.ui.control.Label
        ShotsperstepEditField          matlab.ui.control.NumericEditField
        SavebackgroundCheckBox         matlab.ui.control.CheckBox
        BackgroundshotsEditFieldLabel  matlab.ui.control.Label
        BackgroundshotsEditField       matlab.ui.control.NumericEditField
        PrinttoeLogCheckBox            matlab.ui.control.CheckBox
        LoadConfigButton               matlab.ui.control.Button
        ClearConfigButton              matlab.ui.control.Button
        SaveConfigButton               matlab.ui.control.Button
        StreamDataCheckBox             matlab.ui.control.CheckBox
        RateDropDownLabel              matlab.ui.control.Label
        RateDropDown                   matlab.ui.control.DropDown
        SaveLaserBGCheckBox            matlab.ui.control.CheckBox
        Switch                         matlab.ui.control.Switch
        CameraConfigPanel              matlab.ui.container.Panel
        Tree                           matlab.ui.container.Tree
        AddButton                      matlab.ui.control.Button
        RemoveButton                   matlab.ui.control.Button
        ListBox                        matlab.ui.control.ListBox
        PVListsPanel                   matlab.ui.container.Panel
        BSAandSCPDataListBoxLabel      matlab.ui.control.Label
        BSADataListBox                 matlab.ui.control.ListBox
        nonBSADataListBoxLabel         matlab.ui.control.Label
        nonBSADataListBox              matlab.ui.control.ListBox
        AddBSA                         matlab.ui.control.Button
        RemoveBSA                      matlab.ui.control.Button
        AddNonBSA                      matlab.ui.control.Button
        RemoveNonBSA                   matlab.ui.control.Button
        ListBoxBSA                     matlab.ui.control.ListBox
        ListBoxNonBSA                  matlab.ui.control.ListBox
        DisplayBSA                     matlab.ui.control.Button
        DisplayNonBSA                  matlab.ui.control.Button
        IncludeSCPCheckBox             matlab.ui.control.CheckBox
        DisplaySCP                     matlab.ui.control.Button
        nonBSAArraysCheckBox           matlab.ui.control.CheckBox
        ScanPanel                      matlab.ui.container.Panel
        ScanTypeDropDownLabel          matlab.ui.control.Label
        ScanTypeDropDown               matlab.ui.control.DropDown
        FirstDimensionPanel            matlab.ui.container.Panel
        ScanfunctionDropDownLabel      matlab.ui.control.Label
        ScanfunctionDropDown           matlab.ui.control.DropDown
        PVEditFieldLabel               matlab.ui.control.Label
        PVEditField                    matlab.ui.control.EditField
        StartEditFieldLabel            matlab.ui.control.Label
        StartEditField                 matlab.ui.control.NumericEditField
        StopEditFieldLabel             matlab.ui.control.Label
        StopEditField                  matlab.ui.control.NumericEditField
        StepsEditFieldLabel            matlab.ui.control.Label
        StepsEditField                 matlab.ui.control.NumericEditField
        ScanValuesTextAreaLabel        matlab.ui.control.Label
        ScanValuesTextArea             matlab.ui.control.TextArea
        ToleranceEditFieldLabel        matlab.ui.control.Label
        ToleranceEditField             matlab.ui.control.NumericEditField
        RBVEditFieldLabel              matlab.ui.control.Label
        RBVEditField                   matlab.ui.control.EditField
        WaitsEditFieldLabel            matlab.ui.control.Label
        WaitsEditField                 matlab.ui.control.NumericEditField
        SecondDimensionPanel           matlab.ui.container.Panel
        ScanfunctionDropDown_2Label    matlab.ui.control.Label
        ScanfunctionDropDown_2         matlab.ui.control.DropDown
        PVEditField_2Label             matlab.ui.control.Label
        PVEditField_2                  matlab.ui.control.EditField
        StartEditField_2Label          matlab.ui.control.Label
        StartEditField_2               matlab.ui.control.NumericEditField
        StopEditField_2Label           matlab.ui.control.Label
        StopEditField_2                matlab.ui.control.NumericEditField
        StepsEditField_2Label          matlab.ui.control.Label
        StepsEditField_2               matlab.ui.control.NumericEditField
        ScanValuesTextArea_2Label      matlab.ui.control.Label
        ScanValuesTextArea_2           matlab.ui.control.TextArea
        ToleranceEditField_2Label      matlab.ui.control.Label
        ToleranceEditField_2           matlab.ui.control.NumericEditField
        RBVEditField_2Label            matlab.ui.control.Label
        RBVEditField_2                 matlab.ui.control.EditField
        WaitsEditField_2Label          matlab.ui.control.Label
        WaitsEditField_2               matlab.ui.control.NumericEditField
        Blockbeam                      matlab.ui.control.CheckBox
        RunPanel                       matlab.ui.container.Panel
        RunButton                      matlab.ui.control.StateButton
        AbortButton                    matlab.ui.control.StateButton
        MessagesTextArea               matlab.ui.control.TextArea
        ResetDAQButton                 matlab.ui.control.StateButton
        FixCamerasButton               matlab.ui.control.Button
    end

    
    properties (Access = private)
        aobj % Application helper object
        config_dir = '/u1/facet/matlab/config/F2_DAQ/'
    end
    
    properties (Access = public)
        scan_vals
        scan_vals2
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, blah)
            app.aobj=F2_DAQApp(app);
            app.FixCamerasButton.Enable = 'off';
        end

        % Selection changed function: Tree
        function TreeSelectionChanged(app, event)
            selectedNodes = app.Tree.SelectedNodes;
        end

        % Button pushed function: AddButton
        function AddButtonPushed(app, event)
            selectedNodes = app.Tree.SelectedNodes;
            items = app.ListBox.Items;
            data = app.ListBox.ItemsData;
            if ~isempty(selectedNodes.NodeData)
                if ~any(strcmp(items,selectedNodes.Text))
                    items{end+1} = selectedNodes.Text;
                    data{end+1} = selectedNodes.NodeData;
                    app.ListBox.Items = items;
                    app.ListBox.ItemsData = data;
                end
            end
        end

        % Button pushed function: RemoveButton
        function RemoveButtonPushed(app, event)
            value = app.ListBox.Value;
            items = app.ListBox.Items;
            data = app.ListBox.ItemsData;
            ind = strcmp(data,value);
            
            if ~isempty(ind)
                items(ind) = [];
                data(ind) = [];
                app.ListBox.Items = items;
                app.ListBox.ItemsData = data;
            end

        end

        % Button pushed function: AddBSA
        function AddBSAButtonPushed(app, event)
            
            values = app.BSADataListBox.Value;
            for ind = 1:length(values)
                value = values{ind};
                items = app.ListBoxBSA.Items;
                ind = strcmp(items,value);
                
                if isempty(ind) || sum(ind) == 0
                    items{end+1} = value;
                    app.ListBoxBSA.Items = items;
                end
            end
        end

        % Button pushed function: AddNonBSA
        function AddNonBSAButtonPushed(app, event)
            
            values = app.nonBSADataListBox.Value;
            for ind = 1:length(values)
                value = values{ind};
                items = app.ListBoxNonBSA.Items;
                ind = strcmp(items,value);
                
                if isempty(ind) || sum(ind) == 0
                    items{end+1} = value;
                    app.ListBoxNonBSA.Items = items;
                end
            end
        end

        % Button pushed function: RemoveBSA
        function RemoveBSAButtonPushed(app, event)
            value = app.ListBoxBSA.Value;
            items = app.ListBoxBSA.Items;
            ind = strcmp(items,value);
            
            if ~isempty(ind)
                items(ind) = [];
                app.ListBoxBSA.Items = items;
            end
        end

        % Button pushed function: RemoveNonBSA
        function RemoveNonBSAButtonPushed(app, event)
            value = app.ListBoxNonBSA.Value;
            items = app.ListBoxNonBSA.Items;
            ind = strcmp(items,value);
            
            if ~isempty(ind)
                items(ind) = [];
                app.ListBoxNonBSA.Items = items;
            end
        end

        % Value changed function: RunButton
        function RunButtonValueChanged(app, event)
            app.aobj.runDAQ();
            
        end

        % Value changed function: ScanTypeDropDown
        function ScanTypeDropDownValueChanged(app, event)
            value = app.ScanTypeDropDown.Value;
            switch value
                case 'Single Step'
                    set(app.FirstDimensionPanel.Children,'Enable','Off');
                    set(app.SecondDimensionPanel.Children,'Enable','Off');
                case '1D Scan'
                    set(app.FirstDimensionPanel.Children,'Enable','On');
                    set(app.SecondDimensionPanel.Children,'Enable','Off');
                    scanVal = app.ScanfunctionDropDown.Value;
                    app.aobj.scanFuncSelected(scanVal);
                case '2D Scan'
                    set(app.FirstDimensionPanel.Children,'Enable','On');
                    set(app.SecondDimensionPanel.Children,'Enable','On');
                    scanVal = app.ScanfunctionDropDown.Value;
                    app.aobj.scanFuncSelected(scanVal);
                    scanVal_2 = app.ScanfunctionDropDown_2.Value;
                    app.aobj.scanFuncSelected_2(scanVal_2);
            end
            
        end

        % Value changed function: ScanfunctionDropDown
        function ScanfunctionDropDownValueChanged(app, event)
            value = app.ScanfunctionDropDown.Value;
            app.aobj.scanFuncSelected(value);
        end

        % Value changed function: ScanfunctionDropDown_2
        function ScanfunctionDropDown_2ValueChanged(app, event)
            value = app.ScanfunctionDropDown_2.Value;
            app.aobj.scanFuncSelected_2(value);
        end

        % Value changed function: StartEditField, StepsEditField, 
        % StopEditField
        function StartEditFieldValueChanged(app, event)
            start_value = app.StartEditField.Value;
            end_value = app.StopEditField.Value;
            steps_val = app.StepsEditField.Value;
            
            if steps_val == 0
                return
            end
            
%             if start_value == end_value
%                 return
%             end
            
            app.scan_vals = linspace(start_value,end_value,steps_val);
            scan_str = num2str(app.scan_vals,'%0.4f, ');
            app.ScanValuesTextArea.Value = scan_str;
            
        end

        % Value changed function: StartEditField_2, 
        % StepsEditField_2, StopEditField_2
        function StartEditField_2ValueChanged(app, event)
            start_value = app.StartEditField_2.Value;
            end_value = app.StopEditField_2.Value;
            steps_val = app.StepsEditField_2.Value;
            
            if steps_val == 0
                return
            end
            
%             if start_value == end_value
%                 return
%             end
            
            app.scan_vals2 = linspace(start_value,end_value,steps_val);
            scan_str = num2str(app.scan_vals2,'%0.4f, ');
            app.ScanValuesTextArea_2.Value = scan_str;
            
        end

        % Value changed function: ResetDAQButton
        function ResetDAQButtonValueChanged(app, event)
            app.aobj.resetDAQ();
            
        end

        % Value changed function: AbortButton
        function AbortButtonValueChanged(app, event)
            app.aobj.abort();
            
        end

        % Button pushed function: DisplayBSA
        function DisplayBSAButtonPushed(app, event)
            list = app.BSADataListBox.Value;
            list = string(list);
            app.aobj.display_list(list);
        end

        % Button pushed function: DisplayNonBSA
        function DisplayNonBSAButtonPushed(app, event)
            list = app.nonBSADataListBox.Value;
            list = string(list);
            app.aobj.display_list(list);
        end

        % Button pushed function: SaveConfigButton
        function SaveConfigButtonPushed(app, event)
            gui_state = struct();
            gui_state.Experiment = app.ExperimentDropDown.Value;
            gui_state.ShotsPerStep = app.ShotsperstepEditField.Value;
            gui_state.SaveBackground = app.SavebackgroundCheckBox.Value;
            gui_state.BackgroundShots = app.BackgroundshotsEditField.Value;
            gui_state.CameraList = {app.ListBox.Items app.ListBox.ItemsData};
            gui_state.BSAList = app.ListBoxBSA.Items;
            gui_state.nonBSAList = app.ListBoxNonBSA.Items;
            gui_state.IncludeSCP = app.IncludeSCPCheckBox.Value;
            gui_state.nonBSAArrays = app.nonBSAArraysCheckBox.Value;
            
            exp = gui_state.Experiment;
            
            uisave('gui_state',[app.config_dir exp '_config_' date '.mat']);
            
            % Save DAQ parameters struct
            daq_params = app.aobj.generateDAQParams();
            uisave('daq_params',['DAQ_params_' exp '_' date '.mat']);
        end

        % Button pushed function: ClearConfigButton
        function ClearConfigButtonPushed(app, event)
            app.ExperimentDropDown.Value = 'TEST';
            app.CommentTextArea.Value = 'Comment . . .';
%             app.BeamButton.Value = true;
            app.ShotsperstepEditField.Value = 20;
            app.SavebackgroundCheckBox.Value = true;
            app.BackgroundshotsEditField.Value = 1;
            app.ListBox.Items = {};
            app.ListBox.ItemsData = {};
            app.ListBoxBSA.Items = {};
            app.ListBoxNonBSA.Items = {};
            app.IncludeSCPCheckBox.Value = false;
            app.nonBSAArraysCheckBox.Value = false;
        end

        % Button pushed function: LoadConfigButton
        function LoadConfigButtonPushed(app, event)
            uiopen(app.config_dir);
            
            app.ExperimentDropDown.Value = gui_state.Experiment;
            
%             switch gui_state.EventCode
%                 case 223
% %                     app.BeamButton.Value = true;
%                 case 53
% %                     app.TS510HzButton.Value = true;
%                 otherwise
%                     app.aobj.addMessage('Warning: Could not load Event Code');
%             end
            
%             app.EventCodeButtonGroup.SelectedObject.Value = true;
            app.ShotsperstepEditField.Value = gui_state.ShotsPerStep;
            app.SavebackgroundCheckBox.Value = gui_state.SaveBackground;
            app.BackgroundshotsEditField.Value = gui_state.BackgroundShots;
            app.ListBox.Items = gui_state.CameraList{:,1};
            app.ListBox.ItemsData = gui_state.CameraList{:,2};
            app.ListBoxBSA.Items = gui_state.BSAList;
            app.ListBoxNonBSA.Items = gui_state.nonBSAList;
            app.IncludeSCPCheckBox.Value = gui_state.IncludeSCP;
            app.nonBSAArraysCheckBox.Value = gui_state.nonBSAArrays;

        end

        % Button pushed function: FixCamerasButton
        function FixCamerasButtonPushed(app, event)
            app.aobj.camCheck.restore_trig_event(214)
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create FACETIIDAQUIFigure and hide until all components are created
            app.FACETIIDAQUIFigure = uifigure('Visible', 'off');
            app.FACETIIDAQUIFigure.Position = [100 100 882 700];
            app.FACETIIDAQUIFigure.Name = 'FACET-II DAQ';

            % Create DAQSettingsPanel
            app.DAQSettingsPanel = uipanel(app.FACETIIDAQUIFigure);
            app.DAQSettingsPanel.Title = 'DAQ Settings';
            app.DAQSettingsPanel.Position = [16 441 407 240];

            % Create ExperimentDropDownLabel
            app.ExperimentDropDownLabel = uilabel(app.DAQSettingsPanel);
            app.ExperimentDropDownLabel.HorizontalAlignment = 'right';
            app.ExperimentDropDownLabel.Position = [9 187 67 22];
            app.ExperimentDropDownLabel.Text = 'Experiment';

            % Create ExperimentDropDown
            app.ExperimentDropDown = uidropdown(app.DAQSettingsPanel);
            app.ExperimentDropDown.Items = {'TEST', 'BEAMPHYS', 'E300', 'E301', 'E304', 'E305', 'E308', 'E310', 'E320', 'E324', 'E325', 'E326', 'E327', 'E331', 'E332', 'E338', 'E339'};
            app.ExperimentDropDown.Position = [88 187 71 22];
            app.ExperimentDropDown.Value = 'TEST';

            % Create CommentTextArea
            app.CommentTextArea = uitextarea(app.DAQSettingsPanel);
            app.CommentTextArea.Position = [175 109 218 97];
            app.CommentTextArea.Value = {'Comment . . .'};

            % Create ShotsperstepEditFieldLabel
            app.ShotsperstepEditFieldLabel = uilabel(app.DAQSettingsPanel);
            app.ShotsperstepEditFieldLabel.HorizontalAlignment = 'right';
            app.ShotsperstepEditFieldLabel.Position = [9 79 83 22];
            app.ShotsperstepEditFieldLabel.Text = 'Shots per step';

            % Create ShotsperstepEditField
            app.ShotsperstepEditField = uieditfield(app.DAQSettingsPanel, 'numeric');
            app.ShotsperstepEditField.Limits = [1 1000];
            app.ShotsperstepEditField.Position = [107 79 56 22];
            app.ShotsperstepEditField.Value = 20;

            % Create SavebackgroundCheckBox
            app.SavebackgroundCheckBox = uicheckbox(app.DAQSettingsPanel);
            app.SavebackgroundCheckBox.Text = 'Save background';
            app.SavebackgroundCheckBox.Position = [15 50 118 22];
            app.SavebackgroundCheckBox.Value = true;

            % Create BackgroundshotsEditFieldLabel
            app.BackgroundshotsEditFieldLabel = uilabel(app.DAQSettingsPanel);
            app.BackgroundshotsEditFieldLabel.HorizontalAlignment = 'right';
            app.BackgroundshotsEditFieldLabel.Position = [9 21 103 22];
            app.BackgroundshotsEditFieldLabel.Text = 'Background shots';

            % Create BackgroundshotsEditField
            app.BackgroundshotsEditField = uieditfield(app.DAQSettingsPanel, 'numeric');
            app.BackgroundshotsEditField.Limits = [1 10];
            app.BackgroundshotsEditField.Position = [127 21 37 22];
            app.BackgroundshotsEditField.Value = 1;

            % Create PrinttoeLogCheckBox
            app.PrinttoeLogCheckBox = uicheckbox(app.DAQSettingsPanel);
            app.PrinttoeLogCheckBox.Text = 'Print to eLog?';
            app.PrinttoeLogCheckBox.Position = [175 79 98 22];
            app.PrinttoeLogCheckBox.Value = true;

            % Create LoadConfigButton
            app.LoadConfigButton = uibutton(app.DAQSettingsPanel, 'push');
            app.LoadConfigButton.ButtonPushedFcn = createCallbackFcn(app, @LoadConfigButtonPushed, true);
            app.LoadConfigButton.Position = [293 79 100 23];
            app.LoadConfigButton.Text = 'Load Config';

            % Create ClearConfigButton
            app.ClearConfigButton = uibutton(app.DAQSettingsPanel, 'push');
            app.ClearConfigButton.ButtonPushedFcn = createCallbackFcn(app, @ClearConfigButtonPushed, true);
            app.ClearConfigButton.Position = [293 12 100 23];
            app.ClearConfigButton.Text = 'Clear Config';

            % Create SaveConfigButton
            app.SaveConfigButton = uibutton(app.DAQSettingsPanel, 'push');
            app.SaveConfigButton.ButtonPushedFcn = createCallbackFcn(app, @SaveConfigButtonPushed, true);
            app.SaveConfigButton.Position = [293 45 100 23];
            app.SaveConfigButton.Text = 'Save Config';

            % Create StreamDataCheckBox
            app.StreamDataCheckBox = uicheckbox(app.DAQSettingsPanel);
            app.StreamDataCheckBox.Tooltip = {'Stream data is much faster, but works best when cameras have reduced ROI.'};
            app.StreamDataCheckBox.Text = 'Stream Data';
            app.StreamDataCheckBox.Position = [176 21 89 22];

            % Create RateDropDownLabel
            app.RateDropDownLabel = uilabel(app.DAQSettingsPanel);
            app.RateDropDownLabel.HorizontalAlignment = 'right';
            app.RateDropDownLabel.Position = [42 157 31 22];
            app.RateDropDownLabel.Text = 'Rate';

            % Create RateDropDown
            app.RateDropDown = uidropdown(app.DAQSettingsPanel);
            app.RateDropDown.Items = {'Beam', '10 Hz', '5 Hz', '1 Hz', '0.5 Hz'};
            app.RateDropDown.Tooltip = {'Beam rate may be any value. Select a different rate to limit the rate of the DAQ.'};
            app.RateDropDown.Position = [88 157 71 22];
            app.RateDropDown.Value = 'Beam';

            % Create SaveLaserBGCheckBox
            app.SaveLaserBGCheckBox = uicheckbox(app.DAQSettingsPanel);
            app.SaveLaserBGCheckBox.Text = 'Save Laser BG';
            app.SaveLaserBGCheckBox.Position = [144 50 104 22];
            app.SaveLaserBGCheckBox.Value = true;

            % Create Switch
            app.Switch = uiswitch(app.DAQSettingsPanel, 'slider');
            app.Switch.Items = {'TIFF', 'HDF5'};
            app.Switch.Position = [60 120 45 20];
            app.Switch.Value = 'HDF5';

            % Create CameraConfigPanel
            app.CameraConfigPanel = uipanel(app.FACETIIDAQUIFigure);
            app.CameraConfigPanel.Title = 'Camera Config';
            app.CameraConfigPanel.Position = [445 442 419 239];

            % Create Tree
            app.Tree = uitree(app.CameraConfigPanel);
            app.Tree.SelectionChangedFcn = createCallbackFcn(app, @TreeSelectionChanged, true);
            app.Tree.Position = [12 11 150 197];

            % Create AddButton
            app.AddButton = uibutton(app.CameraConfigPanel, 'push');
            app.AddButton.ButtonPushedFcn = createCallbackFcn(app, @AddButtonPushed, true);
            app.AddButton.Position = [178 133 64 23];
            app.AddButton.Text = 'Add';

            % Create RemoveButton
            app.RemoveButton = uibutton(app.CameraConfigPanel, 'push');
            app.RemoveButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveButtonPushed, true);
            app.RemoveButton.Position = [178 86 64 23];
            app.RemoveButton.Text = 'Remove';

            % Create ListBox
            app.ListBox = uilistbox(app.CameraConfigPanel);
            app.ListBox.Items = {};
            app.ListBox.Position = [266 10 139 197];
            app.ListBox.Value = {};

            % Create PVListsPanel
            app.PVListsPanel = uipanel(app.FACETIIDAQUIFigure);
            app.PVListsPanel.Title = 'PV Lists';
            app.PVListsPanel.Position = [16 154 406 276];

            % Create BSAandSCPDataListBoxLabel
            app.BSAandSCPDataListBoxLabel = uilabel(app.PVListsPanel);
            app.BSAandSCPDataListBoxLabel.HorizontalAlignment = 'right';
            app.BSAandSCPDataListBoxLabel.Position = [12 223 110 22];
            app.BSAandSCPDataListBoxLabel.Text = 'BSA and SCP Data';

            % Create BSADataListBox
            app.BSADataListBox = uilistbox(app.PVListsPanel);
            app.BSADataListBox.Items = {};
            app.BSADataListBox.Multiselect = 'on';
            app.BSADataListBox.Position = [12 141 166 74];
            app.BSADataListBox.Value = {};

            % Create nonBSADataListBoxLabel
            app.nonBSADataListBoxLabel = uilabel(app.PVListsPanel);
            app.nonBSADataListBoxLabel.HorizontalAlignment = 'right';
            app.nonBSADataListBoxLabel.Position = [213 222 83 22];
            app.nonBSADataListBoxLabel.Text = 'non-BSA Data';

            % Create nonBSADataListBox
            app.nonBSADataListBox = uilistbox(app.PVListsPanel);
            app.nonBSADataListBox.Items = {};
            app.nonBSADataListBox.Multiselect = 'on';
            app.nonBSADataListBox.Position = [216 141 166 74];
            app.nonBSADataListBox.Value = {};

            % Create AddBSA
            app.AddBSA = uibutton(app.PVListsPanel, 'push');
            app.AddBSA.ButtonPushedFcn = createCallbackFcn(app, @AddBSAButtonPushed, true);
            app.AddBSA.Tag = 'AddBSA';
            app.AddBSA.Position = [12 115 34 23];
            app.AddBSA.Text = 'Add';

            % Create RemoveBSA
            app.RemoveBSA = uibutton(app.PVListsPanel, 'push');
            app.RemoveBSA.ButtonPushedFcn = createCallbackFcn(app, @RemoveBSAButtonPushed, true);
            app.RemoveBSA.Tag = 'RemoveBSA';
            app.RemoveBSA.Position = [51 115 61 23];
            app.RemoveBSA.Text = 'Remove';

            % Create AddNonBSA
            app.AddNonBSA = uibutton(app.PVListsPanel, 'push');
            app.AddNonBSA.ButtonPushedFcn = createCallbackFcn(app, @AddNonBSAButtonPushed, true);
            app.AddNonBSA.Tag = 'AddNonBSA';
            app.AddNonBSA.Position = [215 115 34 23];
            app.AddNonBSA.Text = 'Add';

            % Create RemoveNonBSA
            app.RemoveNonBSA = uibutton(app.PVListsPanel, 'push');
            app.RemoveNonBSA.ButtonPushedFcn = createCallbackFcn(app, @RemoveNonBSAButtonPushed, true);
            app.RemoveNonBSA.Tag = 'RemoveNonBSA';
            app.RemoveNonBSA.Position = [254 115 61 23];
            app.RemoveNonBSA.Text = 'Remove';

            % Create ListBoxBSA
            app.ListBoxBSA = uilistbox(app.PVListsPanel);
            app.ListBoxBSA.Items = {};
            app.ListBoxBSA.Position = [12 36 166 74];
            app.ListBoxBSA.Value = {};

            % Create ListBoxNonBSA
            app.ListBoxNonBSA = uilistbox(app.PVListsPanel);
            app.ListBoxNonBSA.Items = {};
            app.ListBoxNonBSA.Position = [216 36 166 74];
            app.ListBoxNonBSA.Value = {};

            % Create DisplayBSA
            app.DisplayBSA = uibutton(app.PVListsPanel, 'push');
            app.DisplayBSA.ButtonPushedFcn = createCallbackFcn(app, @DisplayBSAButtonPushed, true);
            app.DisplayBSA.Tag = 'RemoveBSA';
            app.DisplayBSA.Position = [117 115 61 23];
            app.DisplayBSA.Text = 'Display';

            % Create DisplayNonBSA
            app.DisplayNonBSA = uibutton(app.PVListsPanel, 'push');
            app.DisplayNonBSA.ButtonPushedFcn = createCallbackFcn(app, @DisplayNonBSAButtonPushed, true);
            app.DisplayNonBSA.Tag = 'RemoveBSA';
            app.DisplayNonBSA.Position = [321 115 61 23];
            app.DisplayNonBSA.Text = 'Display';

            % Create IncludeSCPCheckBox
            app.IncludeSCPCheckBox = uicheckbox(app.PVListsPanel);
            app.IncludeSCPCheckBox.Visible = 'off';
            app.IncludeSCPCheckBox.Tooltip = {'BPMS only'};
            app.IncludeSCPCheckBox.Text = 'Include SCP';
            app.IncludeSCPCheckBox.Position = [13 7 90 22];

            % Create DisplaySCP
            app.DisplaySCP = uibutton(app.PVListsPanel, 'push');
            app.DisplaySCP.Tag = 'RemoveBSA';
            app.DisplaySCP.Enable = 'off';
            app.DisplaySCP.Visible = 'off';
            app.DisplaySCP.Position = [111 7 61 23];
            app.DisplaySCP.Text = 'Display';

            % Create nonBSAArraysCheckBox
            app.nonBSAArraysCheckBox = uicheckbox(app.PVListsPanel);
            app.nonBSAArraysCheckBox.Enable = 'off';
            app.nonBSAArraysCheckBox.Visible = 'off';
            app.nonBSAArraysCheckBox.Text = 'Include non-BSA Arrays';
            app.nonBSAArraysCheckBox.Position = [222 7 152 22];

            % Create ScanPanel
            app.ScanPanel = uipanel(app.FACETIIDAQUIFigure);
            app.ScanPanel.Title = 'Scan';
            app.ScanPanel.Position = [445 12 419 418];

            % Create ScanTypeDropDownLabel
            app.ScanTypeDropDownLabel = uilabel(app.ScanPanel);
            app.ScanTypeDropDownLabel.HorizontalAlignment = 'right';
            app.ScanTypeDropDownLabel.Position = [8 372 63 22];
            app.ScanTypeDropDownLabel.Text = 'Scan Type';

            % Create ScanTypeDropDown
            app.ScanTypeDropDown = uidropdown(app.ScanPanel);
            app.ScanTypeDropDown.Items = {'Single Step', '1D Scan', '2D Scan'};
            app.ScanTypeDropDown.ValueChangedFcn = createCallbackFcn(app, @ScanTypeDropDownValueChanged, true);
            app.ScanTypeDropDown.Tooltip = {'It is possible to run N-dimensional scans but not from GUI.'};
            app.ScanTypeDropDown.Position = [79 372 100 22];
            app.ScanTypeDropDown.Value = 'Single Step';

            % Create FirstDimensionPanel
            app.FirstDimensionPanel = uipanel(app.ScanPanel);
            app.FirstDimensionPanel.Tooltip = {''};
            app.FirstDimensionPanel.Title = 'First Dimension';
            app.FirstDimensionPanel.Position = [12 7 190 359];

            % Create ScanfunctionDropDownLabel
            app.ScanfunctionDropDownLabel = uilabel(app.FirstDimensionPanel);
            app.ScanfunctionDropDownLabel.HorizontalAlignment = 'right';
            app.ScanfunctionDropDownLabel.Enable = 'off';
            app.ScanfunctionDropDownLabel.Position = [9 308 79 22];
            app.ScanfunctionDropDownLabel.Text = 'Scan function';

            % Create ScanfunctionDropDown
            app.ScanfunctionDropDown = uidropdown(app.FirstDimensionPanel);
            app.ScanfunctionDropDown.Items = {'Use PV', 'Function 1', 'Function 2', 'Function 3'};
            app.ScanfunctionDropDown.ValueChangedFcn = createCallbackFcn(app, @ScanfunctionDropDownValueChanged, true);
            app.ScanfunctionDropDown.Enable = 'off';
            app.ScanfunctionDropDown.Tooltip = {'Fast scan param'};
            app.ScanfunctionDropDown.Position = [9 282 169 22];
            app.ScanfunctionDropDown.Value = 'Use PV';

            % Create PVEditFieldLabel
            app.PVEditFieldLabel = uilabel(app.FirstDimensionPanel);
            app.PVEditFieldLabel.HorizontalAlignment = 'right';
            app.PVEditFieldLabel.Enable = 'off';
            app.PVEditFieldLabel.Position = [9 254 25 22];
            app.PVEditFieldLabel.Text = 'PV';

            % Create PVEditField
            app.PVEditField = uieditfield(app.FirstDimensionPanel, 'text');
            app.PVEditField.Enable = 'off';
            app.PVEditField.Position = [49 254 127 22];

            % Create StartEditFieldLabel
            app.StartEditFieldLabel = uilabel(app.FirstDimensionPanel);
            app.StartEditFieldLabel.HorizontalAlignment = 'right';
            app.StartEditFieldLabel.Enable = 'off';
            app.StartEditFieldLabel.Position = [56 144 30 22];
            app.StartEditFieldLabel.Text = 'Start';

            % Create StartEditField
            app.StartEditField = uieditfield(app.FirstDimensionPanel, 'numeric');
            app.StartEditField.ValueDisplayFormat = '%11.6g';
            app.StartEditField.ValueChangedFcn = createCallbackFcn(app, @StartEditFieldValueChanged, true);
            app.StartEditField.Enable = 'off';
            app.StartEditField.Position = [101 146 75 22];

            % Create StopEditFieldLabel
            app.StopEditFieldLabel = uilabel(app.FirstDimensionPanel);
            app.StopEditFieldLabel.HorizontalAlignment = 'right';
            app.StopEditFieldLabel.Enable = 'off';
            app.StopEditFieldLabel.Position = [57 114 30 22];
            app.StopEditFieldLabel.Text = 'Stop';

            % Create StopEditField
            app.StopEditField = uieditfield(app.FirstDimensionPanel, 'numeric');
            app.StopEditField.ValueDisplayFormat = '%11.6g';
            app.StopEditField.ValueChangedFcn = createCallbackFcn(app, @StartEditFieldValueChanged, true);
            app.StopEditField.Enable = 'off';
            app.StopEditField.Position = [102 116 74 22];

            % Create StepsEditFieldLabel
            app.StepsEditFieldLabel = uilabel(app.FirstDimensionPanel);
            app.StepsEditFieldLabel.HorizontalAlignment = 'right';
            app.StepsEditFieldLabel.Enable = 'off';
            app.StepsEditFieldLabel.Position = [58 85 36 22];
            app.StepsEditFieldLabel.Text = 'Steps';

            % Create StepsEditField
            app.StepsEditField = uieditfield(app.FirstDimensionPanel, 'numeric');
            app.StepsEditField.ValueChangedFcn = createCallbackFcn(app, @StartEditFieldValueChanged, true);
            app.StepsEditField.Enable = 'off';
            app.StepsEditField.Position = [134 87 42 22];

            % Create ScanValuesTextAreaLabel
            app.ScanValuesTextAreaLabel = uilabel(app.FirstDimensionPanel);
            app.ScanValuesTextAreaLabel.HorizontalAlignment = 'right';
            app.ScanValuesTextAreaLabel.Enable = 'off';
            app.ScanValuesTextAreaLabel.Position = [1 66 74 22];
            app.ScanValuesTextAreaLabel.Text = 'Scan Values';

            % Create ScanValuesTextArea
            app.ScanValuesTextArea = uitextarea(app.FirstDimensionPanel);
            app.ScanValuesTextArea.Enable = 'off';
            app.ScanValuesTextArea.Position = [10 9 166 53];

            % Create ToleranceEditFieldLabel
            app.ToleranceEditFieldLabel = uilabel(app.FirstDimensionPanel);
            app.ToleranceEditFieldLabel.HorizontalAlignment = 'right';
            app.ToleranceEditFieldLabel.Enable = 'off';
            app.ToleranceEditFieldLabel.Position = [9 174 59 22];
            app.ToleranceEditFieldLabel.Text = 'Tolerance';

            % Create ToleranceEditField
            app.ToleranceEditField = uieditfield(app.FirstDimensionPanel, 'numeric');
            app.ToleranceEditField.Limits = [0 Inf];
            app.ToleranceEditField.Enable = 'off';
            app.ToleranceEditField.Position = [115 174 61 22];

            % Create RBVEditFieldLabel
            app.RBVEditFieldLabel = uilabel(app.FirstDimensionPanel);
            app.RBVEditFieldLabel.HorizontalAlignment = 'right';
            app.RBVEditFieldLabel.Enable = 'off';
            app.RBVEditFieldLabel.Position = [4 228 30 22];
            app.RBVEditFieldLabel.Text = 'RBV';

            % Create RBVEditField
            app.RBVEditField = uieditfield(app.FirstDimensionPanel, 'text');
            app.RBVEditField.Enable = 'off';
            app.RBVEditField.Position = [49 228 127 22];

            % Create WaitsEditFieldLabel
            app.WaitsEditFieldLabel = uilabel(app.FirstDimensionPanel);
            app.WaitsEditFieldLabel.HorizontalAlignment = 'right';
            app.WaitsEditFieldLabel.Enable = 'off';
            app.WaitsEditFieldLabel.Position = [9 202 59 22];
            app.WaitsEditFieldLabel.Text = 'Wait (s)';

            % Create WaitsEditField
            app.WaitsEditField = uieditfield(app.FirstDimensionPanel, 'numeric');
            app.WaitsEditField.Limits = [0 Inf];
            app.WaitsEditField.Enable = 'off';
            app.WaitsEditField.Position = [115 202 61 22];

            % Create SecondDimensionPanel
            app.SecondDimensionPanel = uipanel(app.ScanPanel);
            app.SecondDimensionPanel.Title = 'Second Dimension';
            app.SecondDimensionPanel.Position = [214 7 190 359];

            % Create ScanfunctionDropDown_2Label
            app.ScanfunctionDropDown_2Label = uilabel(app.SecondDimensionPanel);
            app.ScanfunctionDropDown_2Label.HorizontalAlignment = 'right';
            app.ScanfunctionDropDown_2Label.Enable = 'off';
            app.ScanfunctionDropDown_2Label.Position = [9 308 79 22];
            app.ScanfunctionDropDown_2Label.Text = 'Scan function';

            % Create ScanfunctionDropDown_2
            app.ScanfunctionDropDown_2 = uidropdown(app.SecondDimensionPanel);
            app.ScanfunctionDropDown_2.Items = {'Use PV', 'Function 1', 'Function 2', 'Function 3'};
            app.ScanfunctionDropDown_2.ValueChangedFcn = createCallbackFcn(app, @ScanfunctionDropDown_2ValueChanged, true);
            app.ScanfunctionDropDown_2.Enable = 'off';
            app.ScanfunctionDropDown_2.Tooltip = {'Slow scan param'};
            app.ScanfunctionDropDown_2.Position = [9 282 169 22];
            app.ScanfunctionDropDown_2.Value = 'Use PV';

            % Create PVEditField_2Label
            app.PVEditField_2Label = uilabel(app.SecondDimensionPanel);
            app.PVEditField_2Label.HorizontalAlignment = 'right';
            app.PVEditField_2Label.Enable = 'off';
            app.PVEditField_2Label.Position = [9 253 25 22];
            app.PVEditField_2Label.Text = 'PV';

            % Create PVEditField_2
            app.PVEditField_2 = uieditfield(app.SecondDimensionPanel, 'text');
            app.PVEditField_2.Enable = 'off';
            app.PVEditField_2.Position = [49 253 127 22];

            % Create StartEditField_2Label
            app.StartEditField_2Label = uilabel(app.SecondDimensionPanel);
            app.StartEditField_2Label.HorizontalAlignment = 'right';
            app.StartEditField_2Label.Enable = 'off';
            app.StartEditField_2Label.Position = [61 142 30 22];
            app.StartEditField_2Label.Text = 'Start';

            % Create StartEditField_2
            app.StartEditField_2 = uieditfield(app.SecondDimensionPanel, 'numeric');
            app.StartEditField_2.ValueDisplayFormat = '%11.6g';
            app.StartEditField_2.ValueChangedFcn = createCallbackFcn(app, @StartEditField_2ValueChanged, true);
            app.StartEditField_2.Enable = 'off';
            app.StartEditField_2.Position = [106 142 71 22];

            % Create StopEditField_2Label
            app.StopEditField_2Label = uilabel(app.SecondDimensionPanel);
            app.StopEditField_2Label.HorizontalAlignment = 'right';
            app.StopEditField_2Label.Enable = 'off';
            app.StopEditField_2Label.Position = [61 114 30 22];
            app.StopEditField_2Label.Text = 'Stop';

            % Create StopEditField_2
            app.StopEditField_2 = uieditfield(app.SecondDimensionPanel, 'numeric');
            app.StopEditField_2.ValueDisplayFormat = '%11.6g';
            app.StopEditField_2.ValueChangedFcn = createCallbackFcn(app, @StartEditField_2ValueChanged, true);
            app.StopEditField_2.Enable = 'off';
            app.StopEditField_2.Position = [106 114 71 22];

            % Create StepsEditField_2Label
            app.StepsEditField_2Label = uilabel(app.SecondDimensionPanel);
            app.StepsEditField_2Label.HorizontalAlignment = 'right';
            app.StepsEditField_2Label.Enable = 'off';
            app.StepsEditField_2Label.Position = [62 84 36 22];
            app.StepsEditField_2Label.Text = 'Steps';

            % Create StepsEditField_2
            app.StepsEditField_2 = uieditfield(app.SecondDimensionPanel, 'numeric');
            app.StepsEditField_2.ValueChangedFcn = createCallbackFcn(app, @StartEditField_2ValueChanged, true);
            app.StepsEditField_2.Enable = 'off';
            app.StepsEditField_2.Position = [134 87 42 22];

            % Create ScanValuesTextArea_2Label
            app.ScanValuesTextArea_2Label = uilabel(app.SecondDimensionPanel);
            app.ScanValuesTextArea_2Label.HorizontalAlignment = 'right';
            app.ScanValuesTextArea_2Label.Enable = 'off';
            app.ScanValuesTextArea_2Label.Position = [1 65 74 22];
            app.ScanValuesTextArea_2Label.Text = 'Scan Values';

            % Create ScanValuesTextArea_2
            app.ScanValuesTextArea_2 = uitextarea(app.SecondDimensionPanel);
            app.ScanValuesTextArea_2.Enable = 'off';
            app.ScanValuesTextArea_2.Position = [10 9 166 53];

            % Create ToleranceEditField_2Label
            app.ToleranceEditField_2Label = uilabel(app.SecondDimensionPanel);
            app.ToleranceEditField_2Label.HorizontalAlignment = 'right';
            app.ToleranceEditField_2Label.Enable = 'off';
            app.ToleranceEditField_2Label.Position = [10 170 59 22];
            app.ToleranceEditField_2Label.Text = 'Tolerance';

            % Create ToleranceEditField_2
            app.ToleranceEditField_2 = uieditfield(app.SecondDimensionPanel, 'numeric');
            app.ToleranceEditField_2.Limits = [0 Inf];
            app.ToleranceEditField_2.Enable = 'off';
            app.ToleranceEditField_2.Position = [116 170 61 22];

            % Create RBVEditField_2Label
            app.RBVEditField_2Label = uilabel(app.SecondDimensionPanel);
            app.RBVEditField_2Label.HorizontalAlignment = 'right';
            app.RBVEditField_2Label.Enable = 'off';
            app.RBVEditField_2Label.Position = [4 226 30 22];
            app.RBVEditField_2Label.Text = 'RBV';

            % Create RBVEditField_2
            app.RBVEditField_2 = uieditfield(app.SecondDimensionPanel, 'text');
            app.RBVEditField_2.Enable = 'off';
            app.RBVEditField_2.Position = [49 226 127 22];

            % Create WaitsEditField_2Label
            app.WaitsEditField_2Label = uilabel(app.SecondDimensionPanel);
            app.WaitsEditField_2Label.HorizontalAlignment = 'right';
            app.WaitsEditField_2Label.Enable = 'off';
            app.WaitsEditField_2Label.Position = [10 197 59 22];
            app.WaitsEditField_2Label.Text = 'Wait (s)';

            % Create WaitsEditField_2
            app.WaitsEditField_2 = uieditfield(app.SecondDimensionPanel, 'numeric');
            app.WaitsEditField_2.Limits = [0 Inf];
            app.WaitsEditField_2.Enable = 'off';
            app.WaitsEditField_2.Position = [116 197 61 22];

            % Create Blockbeam
            app.Blockbeam = uicheckbox(app.ScanPanel);
            app.Blockbeam.Text = 'Block beam between steps';
            app.Blockbeam.Position = [215 372 168 22];

            % Create RunPanel
            app.RunPanel = uipanel(app.FACETIIDAQUIFigure);
            app.RunPanel.Title = 'Run';
            app.RunPanel.Position = [16 12 406 135];

            % Create RunButton
            app.RunButton = uibutton(app.RunPanel, 'state');
            app.RunButton.ValueChangedFcn = createCallbackFcn(app, @RunButtonValueChanged, true);
            app.RunButton.Text = 'Run';
            app.RunButton.BackgroundColor = [0.4588 0.9412 0.4588];
            app.RunButton.FontWeight = 'bold';
            app.RunButton.Position = [12 84 86 23];

            % Create AbortButton
            app.AbortButton = uibutton(app.RunPanel, 'state');
            app.AbortButton.ValueChangedFcn = createCallbackFcn(app, @AbortButtonValueChanged, true);
            app.AbortButton.Text = 'Abort';
            app.AbortButton.BackgroundColor = [0.949 0.0863 0.0863];
            app.AbortButton.FontWeight = 'bold';
            app.AbortButton.Position = [102 84 90 23];

            % Create MessagesTextArea
            app.MessagesTextArea = uitextarea(app.RunPanel);
            app.MessagesTextArea.Position = [13 8 382 69];

            % Create ResetDAQButton
            app.ResetDAQButton = uibutton(app.RunPanel, 'state');
            app.ResetDAQButton.ValueChangedFcn = createCallbackFcn(app, @ResetDAQButtonValueChanged, true);
            app.ResetDAQButton.Tooltip = {'Only do this if you know that someone else isn''t trying to run the DAQ. Ask your friends!'};
            app.ResetDAQButton.Text = 'Reset DAQ';
            app.ResetDAQButton.BackgroundColor = [0.8 0.8 0.8];
            app.ResetDAQButton.Position = [303 84 90 23];

            % Create FixCamerasButton
            app.FixCamerasButton = uibutton(app.RunPanel, 'push');
            app.FixCamerasButton.ButtonPushedFcn = createCallbackFcn(app, @FixCamerasButtonPushed, true);
            app.FixCamerasButton.BackgroundColor = [0.8 0.8 0.8];
            app.FixCamerasButton.Position = [211 84 90 23];
            app.FixCamerasButton.Text = 'Fix Cameras';

            % Show the figure after all components are created
            app.FACETIIDAQUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_DAQ_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.FACETIIDAQUIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.FACETIIDAQUIFigure)
        end
    end
end