classdef F2_LAA_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        SelectLaserAlignmentTargetPositionsButtonGroup  matlab.ui.container.ButtonGroup
        OptionsDropDown                 matlab.ui.control.DropDown
        ShowTargetsButton               matlab.ui.control.Button
        FACETIILaserAutoAlignmentLabel  matlab.ui.control.Label
        LogTextAreaLabel                matlab.ui.control.Label
        LogTextArea                     matlab.ui.control.TextArea
        InitializeReferenceLaserParametersPanel  matlab.ui.container.Panel
        GrabReferencesButton            matlab.ui.control.Button
        ClearReferencesButton           matlab.ui.control.Button
        SelectCamerastoAlignPanel       matlab.ui.container.Panel
        UITable                         matlab.ui.control.Table
        InitiateAutoAlignmentPanel      matlab.ui.container.Panel
        StartAlignmentButton            matlab.ui.control.Button
        PauseAlignmentButton            matlab.ui.control.Button
        StopAlignmentButton             matlab.ui.control.Button
        StatusLampLabel                 matlab.ui.control.Label
        StatusLamp                      matlab.ui.control.Lamp
        IRmodeButton                    matlab.ui.control.Button
        ExpertButton                    matlab.ui.control.Button
        ClearLogButton                  matlab.ui.control.Button
        SetshutterstatusPanel           matlab.ui.container.Panel
        HeNestatusLampLabel             matlab.ui.control.Label
        HeNestatusLamp                  matlab.ui.control.Lamp
        EPSshutterLampLabel             matlab.ui.control.Label
        EPSshutterLamp                  matlab.ui.control.Lamp
        BlockUnblockButton              matlab.ui.control.Button
        BlockUnblockButton_2            matlab.ui.control.Button
        SetcameraexposuresPanel         matlab.ui.container.Panel
        HeNecamerasButton               matlab.ui.control.Button
        AmpcamerasButton                matlab.ui.control.Button
    end

    
    properties (Access = public)
        camerapvs =  {'CAMR:LT20:100', ... % old 'CAMR:LT20:0001' S20RegenOut
            'CAMR:LT20:101', ...           % old: 'CAMR:LT20:0002' S20PulsePicker
            'CAMR:LT20:102', ...           % old: 'CAMR:LT20:0003' S20PreampNear
            'CAMR:LT20:103', ...           % old: 'CAMR:LT20:0004' S20PreampFar
            'CAMR:LT20:105', ...           % old: 'CAMR:LT20:0006' S20MPANear
            'CAMR:LT20:106', ...           % old: 'CAMR:LT20:0007' S20MPAFar
            'CAMR:LT20:200', ...           % old: 'CAMR:LT20:0009' HeNeNear
            'CAMR:LT20:201', ...           % old: 'CAMR:LT20:0010' HeNeFar
            'CAMR:LT20:202', ...           % old: 'CAMR:LT20:0101' B0
            'CAMR:LT20:203', ...           % old: 'CAMR:LT20:0102' B1
            'CAMR:LT20:204', ...           % old: 'CAMR:LT20:0103' B2
            'CAMR:LT20:205', ...           % old: 'CAMR:LT20:0104' B3
            'CAMR:LT20:206', ...           % old: 'CAMR:LT20:0105' B4
            'CAMR:LT20:207', ...           % old: 'CAMR:LT20:0106' B5
            'CAMR:LT20:208', ...           % old: 'CAMR:LT20:0107' B6
            };% S20 Camera PVs
            
        motorpvs = {'MOTR:LI20:MC06:S3','MOTR:LI20:MC06:M0','MOTR:LI20:MC06:S6',...
        'MOTR:LI20:MC06:S4','MOTR:LI20:MC06:S5','MOTR:LI20:MC07:M0',...
        'MOTR:LI20:MC07:S1','MOTR:LI20:MC08:M0','MOTR:LI20:MC08:S2'};%S20 Motor PVs
        
        feedbackOnPVs = {'SIOC:SYS1:ML01:AO170','SIOC:SYS1:ML01:AO171','SIOC:SYS1:ML01:AO172',...
        'SIOC:SYS1:ML01:AO173','SIOC:SYS1:ML01:AO174','SIOC:SYS1:ML01:AO175',...
        'SIOC:SYS1:ML01:AO176','SIOC:SYS1:ML01:AO177','SIOC:SYS1:ML01:AO178'};%Matlab helper PVs for toggling alignment on/off
        
        feedbackExitPV = 'SIOC:SYS1:ML01:AO169';
        feedbackPausePV = 'SIOC:SYS1:ML01:AO179';
        
        sectionNames = {'Pulse Picker and Regen Out','Preamp Near and Far',...
            'MPA Near and Far','HeNe Near and Far','B0 and B1','B2 and B3','B4','B5','B6'}
        
        gainPVs = {'SIOC:SYS1:ML01:AO190','SIOC:SYS1:ML01:AO191','SIOC:SYS1:ML01:AO199',...
            'SIOC:SYS1:ML01:AO192','SIOC:SYS1:ML01:AO193',...
            'SIOC:SYS1:ML01:AO194','SIOC:SYS1:ML01:AO195',...
            'SIOC:SYS1:ML01:AO196','SIOC:SYS1:ML01:AO197'}
        
        maxMisalignmentTolerancePV = 'SIOC:SYS1:ML01:AO200';
        MPANearFarmaxMisalignmentTolerancePV = 'SIOC:SYS1:ML01:AO189';
        disableTimestampCheckForCamerasPV = 'SIOC:SYS1:ML01:AO187';
        fitMethod = 2;% Centroid fit method for profmon_process
        umPerPixel ;
        setPointOption = 1;% 2 = Set desired centroid setpoint from current position, 1 uses pre-defined target position
        feedbackOn = logical([0,0,0,0,0,0,0,0,0]);
        k_p = [0.1,0.1,0.01,0.2,0.05,0.2,0.2,0.2,0.2];% Default Proportional Gains
        k_i = 0.0;% Integral gain term is set to zero for now - can be included later
        maxMisalignmentTolerance;
        MPANearFarmaxMisalignmentTolerance;
        disableTimestampCheckForCameras;
        refCamSettings = [];
        refSumCts = []; 
        refRMSVals = [];
        requestedSetpoints = [];
        calibrationMatrices;
        initialMotorValues;
        
        HeNeBlockTRAPV = 'XPS:LA20:LS24:M3';
        HeNeBlockOut = 8;
        HeNeBlockIn = 10;
        
        EPSShutterPV = 'DO:LA20:10:Bo1';
        EPSShutterBlocked = 'High';
        EPSShutterOpen = 'Low';
        
    end
    % Helper functions
    methods (Access = private)
        
        function checkBool = performPreAlignmentChecks(app)
            checkBool = 1;
            data = app.UITable.Data;
            sectionBools = double(table2array(data(:,2)));
             if sum(sectionBools)==0
              app.LogTextArea.Value =['Error - No laser cameras selected for alignment ',...
                 app.LogTextArea.Value(:)']  ;
             checkBool = 0;  
            end
            if isempty(app.refCamSettings) || isempty(app.refSumCts)% Exit if no references grabbed
              app.LogTextArea.Value = ...
                  ['Error - no laser references grabbed.',...
                 ' Grab references before starting auto-alignment ',...
                 app.LogTextArea.Value(:)']  ;
             checkBool = 0;
            end
            if isempty(app.requestedSetpoints)% Exit if no setpoints selected
                   app.LogTextArea.Value = ...
                  ['Error - no laser target positions selected.',...
                 ' Select target centroid positions before starting auto-alignment ',...
                 app.LogTextArea.Value(:)']  ;
             checkBool = 0;
            end
        end
        
 
        
        function initiateShutterPanel(app)
            app.setHeNeStatus();
            app.setEPSShutterStatus();
        end
        
        function setHeNeStatus(app)
            HeNeVal = lcaGetSmart([app.HeNeBlockTRAPV,'.RBV']);
            
            if abs(HeNeVal - app.HeNeBlockOut) < 0.001
                app.HeNestatusLamp.Color = [0, 1, 0];
                app.HeNestatusLamp.Tooltip = 'HeNe block is out, HeNe is being sent';
                app.BlockUnblockButton.Text = 'Block';
            elseif  abs(HeNeVal - app.HeNeBlockIn) < 0.001
                app.HeNestatusLamp.Color = [1, 0, 0];
                app.HeNestatusLamp.Tooltip = 'HeNe block is in, HeNe is being blocked';
                app.BlockUnblockButton.Text = 'Unblock';
            else
                app.HeNestatusLamp.Color = [1, 1, 0];
                app.HeNestatusLamp.Tooltip = 'Status unknown';
                app.BlockUnblockButton.Text = 'Block';
            end
        end
        
        function setEPSShutterStatus(app)
            ShutterVal = lcaGetSmart(app.EPSShutterPV);
            
            
            if strcmp(ShutterVal,'High')
                app.EPSshutterLamp.Color = [1, 0, 0];
                app.EPSshutterLamp.Tooltip = 'EPS shutter is in';
                app.BlockUnblockButton_2.Text = 'Unblock';
            elseif strcmp(ShutterVal,'Low')
                app.EPSshutterLamp.Color = [0, 1, 0];
                app.EPSshutterLamp.Tooltip = 'EPS shutter is out';
                app.BlockUnblockButton_2.Text = 'Block';
            end

        end
        
%         function movePicoMotor(app, motorPV, target)
%             lcaPutSmart([motorPV,':MOTOR.TWV'], mirrorMovements(n));% Set tweak
%             lcaPutSmart([motorPV,':MOTOR.TWF'],1.0);% Move mot
%             motor_status = lcaGetSmart([motorPV,':MOTOR.MSTA']);
%             while motor_status ~=2
%                 motor_status = lcaGetSmart([motorPV, ':MOTOR.MSTA']);
%             end
%         end
        function flipEPSShutter(app)
            ShutterVal = lcaGetSmart(app.EPSShutterPV);
            
            if strcmp(ShutterVal, app.EPSShutterBlocked) 
                lcaPutSmart(app.EPSShutterPV, app.EPSShutterOpen);
            elseif strcmp(ShutterVal, app.EPSShutterOpen)
                lcaPutSmart(app.EPSShutterPV, app.EPSShutterBlocked);
            end
            
            app.setEPSShutterStatus();
        end
        
        function moveStepperMotor(app, motorPV, motorName, target)
            
            lcaPutSmart(motorPV, target);
            motorVal = lcaGetSmart([motorPV,'.RBV']);
            app.LogTextArea.Value = ...
                  [['Moving motor: ', motorName], ...
                 app.LogTextArea.Value(:)']  ;
            
            while ~(abs(motorVal - target) < 0.01)
                motorVal = lcaGetSmart([motorPV,'.RBV']);
                app.setHeNeStatus();
                drawnow;
            end
            
            app.LogTextArea.Value = ...
                  [['Finished moving motor: ', motorName], ...
                 app.LogTextArea.Value(:)'] ;
        end
        
        function appendMessage(app, msg)
            app.LogTextArea.Value = ...
                  [msg, ...
                 app.LogTextArea.Value(:)'] ;
            pause(1e-2);
        end
        
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            t = table(app.sectionNames',app.feedbackOn');
            app.UITable.Data = t; 
            app.umPerPixel = ones(length(app.camerapvs),1);
            app.calibrationMatrices = loadCalibrationMatrices();
            app.initialMotorValues = getMotorValues(app);
            app.k_p = lcaGetSmart(app.gainPVs);
            
            app.initiateShutterPanel();
                       
        end

        % Cell edit callback: UITable
        function UITableCellEdit(app, event)
            %indices = event.Indices;
            %newData = event.NewData;
        end

        % Button pushed function: GrabReferencesButton
        function GrabReferencesButtonPushed(app, event)
            app.LogTextArea.Value = ['Grabbing Reference Laser Parameters...',...
                app.LogTextArea.Value(:)'];
            drawnow()
            app.setPointOption = app.OptionsDropDown.Value;
            [app.refCamSettings,app.refSumCts,app.requestedSetpoints,app.refRMSVals] = ...
                defineFeedbackSetpoint(app);
            app.LogTextArea.Value = ...
                ['Grabbed Reference Laser Reference Parameters',...
                app.LogTextArea.Value(:)'];
            disp(app.requestedSetpoints)
        end

        % Button pushed function: ClearReferencesButton
        function ClearReferencesButtonPushed(app, event)
            app.refCamSettings = [];
            app.refSumCts = [];
            app.requestedSetpoints = [];
            app.LogTextArea.Value = ['Cleared Reference Laser Position and Sum Counts',app.LogTextArea.Value(:)'];
        end

        % Button pushed function: PauseAlignmentButton
        function PauseAlignmentButtonPushed(app, event)
            if lcaGetSmart(app.feedbackExitPV)==1
                app.LogTextArea.Value = [' Cannot pause Auto-Alignment because it is already stopped',app.LogTextArea.Value(:)'];
            elseif lcaGetSmart(app.feedbackPausePV)==0
                lcaPutSmart(app.feedbackPausePV,1);
                app.LogTextArea.Value = ['Auto-Alignment Paused',app.LogTextArea.Value(:)'];
                app.StatusLamp.Color = [1.0 0.41 0.16];
            else
                lcaPutSmart(app.feedbackPausePV,0);
                app.LogTextArea.Value = ['Auto-Alignment Un-Paused',app.LogTextArea.Value(:)'];
                app.StatusLamp.Color = 'Green';
            end
        end

        % Button pushed function: StartAlignmentButton
        function StartAlignmentButtonPushed(app, event)
            
            lcaPutSmart(app.feedbackExitPV,0);% Set exit PV to zero
            lcaPutSmart(app.feedbackPausePV,0);% Set pause PV to zero
            data = app.UITable.Data;
            sectionBools = double(table2array(data(:,2)));
            NLaserSections = length(app.feedbackOnPVs);
            for n=1:NLaserSections;lcaPut(app.feedbackOnPVs{n},sectionBools(n));end% Set which sections align or not 
            checkBool = performPreAlignmentChecks(app);
            if ~checkBool;return;end% Exit alignment if pre-checks are bad
            app.LogTextArea.Value = ['Starting Auto Alignment',app.LogTextArea.Value(:)'];
            app.StatusLamp.Color = 'Green';
            drawnow()
            
            while lcaGetSmart(app.feedbackExitPV) ==0% Start the feedback             
                    
                    app.k_p = lcaGetSmart(app.gainPVs);% Update gain vals
                    app.maxMisalignmentTolerance = lcaGetSmart(app.maxMisalignmentTolerancePV);% Update max misalignment tolerance
                    app.MPANearFarmaxMisalignmentTolerance = lcaGetSmart(app.MPANearFarmaxMisalignmentTolerancePV);% Update max misalignment tolerance
                    app.disableTimestampCheckForCameras = lcaGetSmart(app.disableTimestampCheckForCamerasPV);% Update timestamp check
                    
                    if any(isnan(app.k_p))                     
                         app.LogTextArea.Value =  ['One or more invalid Gain values. Skipping alignment',...
                         app.LogTextArea.Value(:)'];
                     continue
                    end
                    if any([isnan(app.maxMisalignmentTolerance),~isreal(app.maxMisalignmentTolerance),~isnumeric(app.maxMisalignmentTolerance)])
                         app.LogTextArea.Value =  ['Invalid value for max misalignment tolerance. Skipping alignment',...
                         app.LogTextArea.Value(:)'];
                     continue                                   
                    end             
                    
                for ij = 1:NLaserSections
                   if lcaGetSmart(app.feedbackPausePV)==0
                    % Get setpoint and motor pv for the relevant cameras      
                    inputDataStruct.motorpvs = app.motorpvs{ij};
                    
                    if ij<7% Deals with cameras up to and including B3
                        steeringSetpoint = app.requestedSetpoints(1+4*(ij-1):4*ij);
                        inputDataStruct.camerapvs = {app.camerapvs{2*ij-1},app.camerapvs{2*ij}};
                        inputDataStruct.channel_index = [1:4];
                    else% Deals with cameras B4 B5 and B6    
                        steeringSetpoint = [app.requestedSetpoints(25+2*(ij-7)) app.requestedSetpoints(24+2*(ij-6))];
                        inputDataStruct.camerapvs = {app.camerapvs{13+(ij-7)}};
                        if ij==8;inputDataStruct.channel_index = [3,4];% are B4 motors backwards with channels?
                        else
                            inputDataStruct.channel_index = [1,2];
                        end
                    end                       
                    % Evaluate the exit condition
                    if evaluateExitCondition(inputDataStruct,app.refSumCts,app.refCamSettings,app.feedbackOnPVs,ij,app)
                        continue;
                    else % Run the feedback
                     app.LogTextArea.Value =  [newline,'Aligning on ',lcaGetSmart([inputDataStruct.camerapvs{1},':NAME']),...
                         app.LogTextArea.Value(:)'];
                      [~,~,~] = ...
                            alignLaserToSetpoint(inputDataStruct,steeringSetpoint,...
                            app.calibrationMatrices{ij},app.k_p(ij),app.k_i,app);    
                            app.LogTextArea.Value = ['Last move made ',...
                                datestr(now), app.LogTextArea.Value(:)'];               
                    end
                    else
                    lcaGetSmart(app.feedbackPausePV);                  
                    if lcaGetSmart(app.feedbackExitPV);continue;end %Makes sure you don't get stuck on pause and exit PVs = 1
                   end 
                end

                drawnow()
            end            
        end

        % Button pushed function: StopAlignmentButton
        function StopAlignmentButtonPushed(app, event)
            lcaPutSmart(app.feedbackExitPV,1)
            app.LogTextArea.Value = ['Auto-Alignment Stopped',app.LogTextArea.Value(:)'];
            app.StatusLamp.Color = 'Red';
        end

        % Value changed function: OptionsDropDown
        function OptionsDropDownValueChanged(app, event)
            value = str2num(app.OptionsDropDown.Value);
            if value ==1
                set(app.ShowTargetsButton, 'Enable','on');          
            else
                set(app.ShowTargetsButton, 'Enable','off');
            end
            drawnow
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            delete(app)
            disp('Remember to uncomment the exit command')
            exit;
        end

        % Button pushed function: ClearLogButton
        function ClearLogButtonPushed(app, event)
             app.LogTextArea.Value =  ' ';
        end

        % Button pushed function: ShowTargetsButton
        function ShowTargetsButtonPushed(app, event)
            addpath('/usr/local/facet/tools/matlabTNG/F2_LaserMultiProfmon/')
            s20LaserTargetPositionsTable
        end

        % Button pushed function: ExpertButton
        function ExpertButtonPushed(app, event)
            expertSettings_F2_LAA
        end

        % Button pushed function: IRmodeButton
        function IRmodeButtonPushed(app, event)
            lcaPutSmart(app.feedbackExitPV,1)
            app.LogTextArea.Value = ['Auto-Alignment Stopped, Launching IR alignment app',app.LogTextArea.Value(:)'];
            app.StatusLamp.Color = 'Red';
            IRmode
        end

        % Button pushed function: BlockUnblockButton
        function BlockUnblockButtonPushed(app, event)
            % Blocks/unblocks the HeNe
            
            HeNeVal = lcaGetSmart(app.HeNeBlockTRAPV);
            
            app.HeNestatusLamp.Color = [1, 1, 0];
            app.HeNestatusLamp.Tooltip = 'Status unknown';
            app.BlockUnblockButton.Text = 'Block';
            drawnow();
            
            if abs(HeNeVal - app.HeNeBlockIn) < 0.001
                target = app.HeNeBlockOut;
            else
                target = app.HeNeBlockIn;
            end
            
            app.moveStepperMotor(app.HeNeBlockTRAPV, 'HeNe block', target);
            app.setHeNeStatus
            drawnow();
            
        end

        % Button pushed function: BlockUnblockButton_2
        function BlockUnblockButton_2Pushed(app, event)
            app.flipEPSShutter();
        end

        % Button pushed function: HeNecamerasButton
        function HeNecamerasButtonPushed(app, event)
            lcaPutSmart('CAMR:LT20:202:AcquireTime',5e-4); % B0 
            lcaPutSmart('CAMR:LT20:203:AcquireTime',5e-4); % B1
            lcaPutSmart('CAMR:LT20:204:AcquireTime',1e-3); % B2
            lcaPutSmart('CAMR:LT20:205:AcquireTime',0.3);  % B3
            lcaPutSmart('CAMR:LT20:206:AcquireTime',4);    % B4
            lcaPutSmart('CAMR:LT20:207:AcquireTime',1);    % B5
            lcaPutSmart('CAMR:LT20:208:AcquireTime',2);    % B6
            app.appendMessage('Transport cameras exposure time set');
        end

        % Button pushed function: AmpcamerasButton
        function AmpcamerasButtonPushed(app, event)
            lcaPutSmart('CAMR:LT20:100:AcquireTime',1e-4) % S20RegenOut
            lcaPutSmart('CAMR:LT20:101:AcquireTime',1e-4) % S20PulsePicker
            lcaPutSmart('CAMR:LT20:102:AcquireTime',1e-4)% S20PreampNear
            lcaPutSmart('CAMR:LT20:103:AcquireTime',1e-4)% S20PreampFar
            lcaPutSmart('CAMR:LT20:105:AcquireTime',1e-4)% S20MPANear
            lcaPutSmart('CAMR:LT20:106:AcquireTime',1e-4)% S20MPAFar
            lcaPutSmart('CAMR:LT20:200:AcquireTime',1e-4)% HeNe Near
            lcaPutSmart('CAMR:LT20:201:AcquireTime',1e-4)% HeNe Far
            app.appendMessage('Amp cameras exposure time set');
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 637 729];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create SelectLaserAlignmentTargetPositionsButtonGroup
            app.SelectLaserAlignmentTargetPositionsButtonGroup = uibuttongroup(app.UIFigure);
            app.SelectLaserAlignmentTargetPositionsButtonGroup.Title = '1. Select Laser Alignment Target Positions';
            app.SelectLaserAlignmentTargetPositionsButtonGroup.Position = [35 592 280 80];

            % Create OptionsDropDown
            app.OptionsDropDown = uidropdown(app.SelectLaserAlignmentTargetPositionsButtonGroup);
            app.OptionsDropDown.Items = {'Use Pre-Defined References as Target', 'Use Current Position as Target'};
            app.OptionsDropDown.ItemsData = {'1', '2'};
            app.OptionsDropDown.ValueChangedFcn = createCallbackFcn(app, @OptionsDropDownValueChanged, true);
            app.OptionsDropDown.Position = [8 35 250 22];
            app.OptionsDropDown.Value = '1';

            % Create ShowTargetsButton
            app.ShowTargetsButton = uibutton(app.SelectLaserAlignmentTargetPositionsButtonGroup, 'push');
            app.ShowTargetsButton.ButtonPushedFcn = createCallbackFcn(app, @ShowTargetsButtonPushed, true);
            app.ShowTargetsButton.Position = [83 5 100 23];
            app.ShowTargetsButton.Text = 'Show Targets';

            % Create FACETIILaserAutoAlignmentLabel
            app.FACETIILaserAutoAlignmentLabel = uilabel(app.UIFigure);
            app.FACETIILaserAutoAlignmentLabel.HorizontalAlignment = 'center';
            app.FACETIILaserAutoAlignmentLabel.FontSize = 14;
            app.FACETIILaserAutoAlignmentLabel.FontWeight = 'bold';
            app.FACETIILaserAutoAlignmentLabel.Position = [217 697 218 22];
            app.FACETIILaserAutoAlignmentLabel.Text = 'FACET-II Laser Auto Alignment';

            % Create LogTextAreaLabel
            app.LogTextAreaLabel = uilabel(app.UIFigure);
            app.LogTextAreaLabel.HorizontalAlignment = 'right';
            app.LogTextAreaLabel.Position = [345 437 29 22];
            app.LogTextAreaLabel.Text = 'Log:';

            % Create LogTextArea
            app.LogTextArea = uitextarea(app.UIFigure);
            app.LogTextArea.Position = [345 22 268 411];

            % Create InitializeReferenceLaserParametersPanel
            app.InitializeReferenceLaserParametersPanel = uipanel(app.UIFigure);
            app.InitializeReferenceLaserParametersPanel.Title = '4. Initialize Reference Laser Parameters';
            app.InitializeReferenceLaserParametersPanel.Position = [35 314 280 57];

            % Create GrabReferencesButton
            app.GrabReferencesButton = uibutton(app.InitializeReferenceLaserParametersPanel, 'push');
            app.GrabReferencesButton.ButtonPushedFcn = createCallbackFcn(app, @GrabReferencesButtonPushed, true);
            app.GrabReferencesButton.Position = [22 8 108 23];
            app.GrabReferencesButton.Text = 'Grab References';

            % Create ClearReferencesButton
            app.ClearReferencesButton = uibutton(app.InitializeReferenceLaserParametersPanel, 'push');
            app.ClearReferencesButton.ButtonPushedFcn = createCallbackFcn(app, @ClearReferencesButtonPushed, true);
            app.ClearReferencesButton.Position = [145 8 111 23];
            app.ClearReferencesButton.Text = 'Clear References';

            % Create SelectCamerastoAlignPanel
            app.SelectCamerastoAlignPanel = uipanel(app.UIFigure);
            app.SelectCamerastoAlignPanel.Title = '5. Select Cameras to Align';
            app.SelectCamerastoAlignPanel.Position = [35 18 280 277];

            % Create UITable
            app.UITable = uitable(app.SelectCamerastoAlignPanel);
            app.UITable.ColumnName = {'Laser Cameras'; 'Select'};
            app.UITable.RowName = {};
            app.UITable.ColumnEditable = [false true];
            app.UITable.CellEditCallback = createCallbackFcn(app, @UITableCellEdit, true);
            app.UITable.Position = [13 15 255 230];

            % Create InitiateAutoAlignmentPanel
            app.InitiateAutoAlignmentPanel = uipanel(app.UIFigure);
            app.InitiateAutoAlignmentPanel.Title = '6. Initiate Auto Alignment';
            app.InitiateAutoAlignmentPanel.Position = [345 520 271 151];

            % Create StartAlignmentButton
            app.StartAlignmentButton = uibutton(app.InitiateAutoAlignmentPanel, 'push');
            app.StartAlignmentButton.ButtonPushedFcn = createCallbackFcn(app, @StartAlignmentButtonPushed, true);
            app.StartAlignmentButton.BackgroundColor = [0.3922 0.8314 0.0745];
            app.StartAlignmentButton.FontSize = 14;
            app.StartAlignmentButton.Position = [15 94 121 24];
            app.StartAlignmentButton.Text = 'Start Alignment';

            % Create PauseAlignmentButton
            app.PauseAlignmentButton = uibutton(app.InitiateAutoAlignmentPanel, 'push');
            app.PauseAlignmentButton.ButtonPushedFcn = createCallbackFcn(app, @PauseAlignmentButtonPushed, true);
            app.PauseAlignmentButton.BackgroundColor = [1 0.4118 0.1608];
            app.PauseAlignmentButton.FontSize = 14;
            app.PauseAlignmentButton.Position = [15 57 122 24];
            app.PauseAlignmentButton.Text = 'Pause Alignment';

            % Create StopAlignmentButton
            app.StopAlignmentButton = uibutton(app.InitiateAutoAlignmentPanel, 'push');
            app.StopAlignmentButton.ButtonPushedFcn = createCallbackFcn(app, @StopAlignmentButtonPushed, true);
            app.StopAlignmentButton.BackgroundColor = [1 0 0];
            app.StopAlignmentButton.FontSize = 14;
            app.StopAlignmentButton.Position = [15 19 121 24];
            app.StopAlignmentButton.Text = 'Stop Alignment';

            % Create StatusLampLabel
            app.StatusLampLabel = uilabel(app.InitiateAutoAlignmentPanel);
            app.StatusLampLabel.HorizontalAlignment = 'right';
            app.StatusLampLabel.Position = [176 20 42 22];
            app.StatusLampLabel.Text = 'Status:';

            % Create StatusLamp
            app.StatusLamp = uilamp(app.InitiateAutoAlignmentPanel);
            app.StatusLamp.Position = [233 20 20 20];
            app.StatusLamp.Color = [0.902 0.902 0.902];

            % Create IRmodeButton
            app.IRmodeButton = uibutton(app.InitiateAutoAlignmentPanel, 'push');
            app.IRmodeButton.ButtonPushedFcn = createCallbackFcn(app, @IRmodeButtonPushed, true);
            app.IRmodeButton.BackgroundColor = [0.302 0.7451 0.9333];
            app.IRmodeButton.Position = [181 95 72 23];
            app.IRmodeButton.Text = 'IR mode';

            % Create ExpertButton
            app.ExpertButton = uibutton(app.InitiateAutoAlignmentPanel, 'push');
            app.ExpertButton.ButtonPushedFcn = createCallbackFcn(app, @ExpertButtonPushed, true);
            app.ExpertButton.Position = [183 57 70 23];
            app.ExpertButton.Text = 'Expert...';

            % Create ClearLogButton
            app.ClearLogButton = uibutton(app.UIFigure, 'push');
            app.ClearLogButton.ButtonPushedFcn = createCallbackFcn(app, @ClearLogButtonPushed, true);
            app.ClearLogButton.Position = [515 478 100 23];
            app.ClearLogButton.Text = 'Clear Log';

            % Create SetshutterstatusPanel
            app.SetshutterstatusPanel = uipanel(app.UIFigure);
            app.SetshutterstatusPanel.Title = '2. Set shutter status';
            app.SetshutterstatusPanel.Position = [35 475 280 97];

            % Create HeNestatusLampLabel
            app.HeNestatusLampLabel = uilabel(app.SetshutterstatusPanel);
            app.HeNestatusLampLabel.HorizontalAlignment = 'right';
            app.HeNestatusLampLabel.Position = [26 44 72 22];
            app.HeNestatusLampLabel.Text = 'HeNe status';

            % Create HeNestatusLamp
            app.HeNestatusLamp = uilamp(app.SetshutterstatusPanel);
            app.HeNestatusLamp.Position = [113 44 20 20];
            app.HeNestatusLamp.Color = [1 1 0];

            % Create EPSshutterLampLabel
            app.EPSshutterLampLabel = uilabel(app.SetshutterstatusPanel);
            app.EPSshutterLampLabel.HorizontalAlignment = 'right';
            app.EPSshutterLampLabel.Position = [151 44 69 22];
            app.EPSshutterLampLabel.Text = 'EPS shutter';

            % Create EPSshutterLamp
            app.EPSshutterLamp = uilamp(app.SetshutterstatusPanel);
            app.EPSshutterLamp.Position = [235 44 20 20];

            % Create BlockUnblockButton
            app.BlockUnblockButton = uibutton(app.SetshutterstatusPanel, 'push');
            app.BlockUnblockButton.ButtonPushedFcn = createCallbackFcn(app, @BlockUnblockButtonPushed, true);
            app.BlockUnblockButton.Position = [29 12 100 23];
            app.BlockUnblockButton.Text = 'Block/Unblock';

            % Create BlockUnblockButton_2
            app.BlockUnblockButton_2 = uibutton(app.SetshutterstatusPanel, 'push');
            app.BlockUnblockButton_2.ButtonPushedFcn = createCallbackFcn(app, @BlockUnblockButton_2Pushed, true);
            app.BlockUnblockButton_2.Position = [153 12 100 23];
            app.BlockUnblockButton_2.Text = 'Block/Unblock';

            % Create SetcameraexposuresPanel
            app.SetcameraexposuresPanel = uipanel(app.UIFigure);
            app.SetcameraexposuresPanel.Title = '3. Set camera exposures';
            app.SetcameraexposuresPanel.Position = [35 391 280 64];

            % Create HeNecamerasButton
            app.HeNecamerasButton = uibutton(app.SetcameraexposuresPanel, 'push');
            app.HeNecamerasButton.ButtonPushedFcn = createCallbackFcn(app, @HeNecamerasButtonPushed, true);
            app.HeNecamerasButton.Position = [28 11 100 23];
            app.HeNecamerasButton.Text = 'HeNe cameras';

            % Create AmpcamerasButton
            app.AmpcamerasButton = uibutton(app.SetcameraexposuresPanel, 'push');
            app.AmpcamerasButton.ButtonPushedFcn = createCallbackFcn(app, @AmpcamerasButtonPushed, true);
            app.AmpcamerasButton.Position = [149 11 100 23];
            app.AmpcamerasButton.Text = 'Amp cameras';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = F2_LAA_exported

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