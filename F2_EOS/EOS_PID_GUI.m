classdef EOS_PID_GUI < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        EOSPlot                      matlab.ui.control.UIAxes
        TimingPlot                   matlab.ui.control.UIAxes
        StartButton                  matlab.ui.control.Button
        StopButton                   matlab.ui.control.Button
        KpEditFieldLabel             matlab.ui.control.Label
        KpEditField                  matlab.ui.control.NumericEditField
        kdEditFieldLabel             matlab.ui.control.Label
        kdEditField                  matlab.ui.control.NumericEditField
        ShotsaveragedEditFieldLabel  matlab.ui.control.Label
        ShotsaveragedEditField       matlab.ui.control.NumericEditField
        SetpointpxEditFieldLabel     matlab.ui.control.Label
        SetpointpxEditField          matlab.ui.control.NumericEditField
        MinTargetTimeEditFieldLabel  matlab.ui.control.Label
        MinTargetTimeEditField       matlab.ui.control.NumericEditField
        MaxTargetTimeEditFieldLabel  matlab.ui.control.Label
        MaxTargetTimeEditField       matlab.ui.control.NumericEditField
        KiEditFieldLabel             matlab.ui.control.Label
        KiEditField                  matlab.ui.control.NumericEditField
        LogTextAreaLabel             matlab.ui.control.Label
        LogEditField                 matlab.ui.control.TextArea
        CorrectTick                  matlab.ui.control.CheckBox
    end

    
    properties (Access = private)
        RunFeedbackBool % Description
        Timing_EOS_Vector % Description
        Error_Vector % Description
        SetPoint_px
        k_i
        k_p
        k_d
        TargetTime_UpperBound % Description
        TargetTime_LowerBound
        TargetTime_Vector % Description
        EOS_Pixelcount_threshold % Description
        ErrorOutput % Description
        NumberOfShotsPerDatapoint % Description
    end
    
    methods (Access = private)
        
        function results = RunPID(app)
            
              while app.RunFeedbackBool
              %    tic
                 app.ReadDataPoint();
                 app.PlotData();
               
                 app.Evaluate_error();
                 if app.CorrectTick.Value==1
                 app.SetCorrection();
                 end
                 
                 
              %   toc
                pause(0.001)
            
              end
            
            
        end
        
        function TimingPosition_px = ReadDataPoint(app)
             EOS_Camera_PV='CAMR:LI20:205';
             
             for n=1:app.NumberOfShotsPerDatapoint % first evaluate NumberOfShotsPerDatapoint shots then take average as datapoints 
                                                   % for loop
                 CameraData = profmon_grabSeries(EOS_Camera_PV,1);          
                 PxCountEOS=sum(sum(CameraData.img));
                 TargetTime_(n)=lcaGet('OSC:LA20:10:FS_TGT_TIME');
                 Projection_X=sum(CameraData.img);
                 [maxval,maxIndex]=max(Projection_X);
                  TimingPosition_px_(n)=maxIndex+CameraData.roiX;
                  %pause(0.01);
              end
              
              
              
            if PxCountEOS>app.EOS_Pixelcount_threshold
                 TargetTime=mean(TargetTime_);
                
                 
                
                 TimingPosition_px=mean(TimingPosition_px_);
                 
                 if length(app.Timing_EOS_Vector)<300
                     
                     app.Timing_EOS_Vector(length(app.Timing_EOS_Vector)+1)=TimingPosition_px;
                     app.TargetTime_Vector(length(app.TargetTime_Vector)+1)=TargetTime;
                     
                       
                 
                 
                 end
                 
                 if length(app.Timing_EOS_Vector)==300
                     app.Timing_EOS_Vector(1:299)=app.Timing_EOS_Vector(2:300);
                     app.Timing_EOS_Vector(300)=TimingPosition_px;
                     
                     app.TargetTime_Vector(1:299)=app.TargetTime_Vector(2:300);
                     app.TargetTime_Vector(300)=TargetTime;
                     
                     
                 end
                 
            end
             
             
             
        end
        
        function results = PlotData(app)
            
          % app.LogEditField.Value=[app.LogEditField.Value,'plotting...',num2str(app.TargetTime_Vector)]
            plot(app.EOSPlot,[1:length(app.Timing_EOS_Vector)],app.Timing_EOS_Vector)
            
            
            plot(app.TimingPlot,[1:length(app.Timing_EOS_Vector)],app.TargetTime_Vector)
            hold(app.TimingPlot,'on')
            plot(app.TimingPlot,[1,length(app.Timing_EOS_Vector)],[app.TargetTime_LowerBound,app.TargetTime_LowerBound],'--r')
            plot(app.TimingPlot,[1,length(app.Timing_EOS_Vector)],[app.TargetTime_UpperBound,app.TargetTime_UpperBound],'--r')
            axis(app.TimingPlot,[0,length(app.Timing_EOS_Vector),app.TargetTime_LowerBound-0.001,app.TargetTime_UpperBound+0.001])
            hold(app.TimingPlot,'off')
      %  app.TargetTime_UpperBound+0.01,app.TargetTime_LowerBound-0.001
        end
        
        function results = Evaluate_error(app)
            I_N=20; % number of datapoints  integrated for I
            app.Error_Vector=app.SetPoint_px-app.Timing_EOS_Vector;
            i_max=length(app.Error_Vector);
            Error_P=app.Error_Vector(i_max);
            if length(app.Error_Vector)>I_N
                Error_I=sum(app.Error_Vector([i_max-I_N:i_max]))/I_N;
            else
                Error_I=0;
            end
            if length(app.Error_Vector)>3
                Error_D=app.Error_Vector(i_max)-app.Error_Vector(i_max-1);
            else
                Error_D=0;
            end
                
               
               app.ErrorOutput=(Error_P)*(app.k_p)+(Error_I)*(app.k_i)+(Error_D)*(app.k_d);
 
        end
        
        function results = SetCorrection(app)
            
            EOS_Calibration=20*10^-6; % ns/px or 20 fs/px
            
            % Calculate changes that need to be made to target time
            Current_Target_Time=app.TargetTime_Vector(end);
        
   
            Correction=app.ErrorOutput*EOS_Calibration;
            
            % Calculate desired new target time
             
            TargetTime_Des=Current_Target_Time+Correction;
            
            if TargetTime_Des<app.TargetTime_UpperBound
                  
                  
               if TargetTime_Des>app.TargetTime_LowerBound
                   
                   lcaPut('OSC:LA20:10:FS_TGT_TIME',TargetTime_Des)
                  
                   [app.LogEditField.Value,'  Change tgt time by',num2str(round(Correction*10^6)),' fs. From',num2str(app.TargetTime_Vector(end)),' to ',num2str(TargetTime_Des),' ns.']
                   
                    
               end
                 
                
    end 
            
            if TargetTime_Des>app.TargetTime_UpperBound
                [app.LogEditField.Value,' >upper B  Want to target time by',num2str(round(Correction*10^6)),' fs. ',' to ',num2str(TargetTime_Des),' ns.']
                 
            end
            
            if TargetTime_Des<app.TargetTime_LowerBound
               [app.LogEditField.Value,' <lower B  Want to target time by',num2str(round(Correction*10^6)),' fs. ',' to ',num2str(TargetTime_Des),' ns.']
                 
            end
                
                
            
            
            
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.Error_Vector=[];
            app.RunFeedbackBool=false;
            app.Timing_EOS_Vector=[];
            app.TargetTime_Vector=[];
            app.EOS_Pixelcount_threshold=0;  % TODO: implement EOS threshold for goose-shot identification.
       
            TargetTime=lcaGet('OSC:LA20:10:FS_TGT_TIME');
            app.TargetTime_LowerBound=TargetTime-0.0025;
            app.TargetTime_UpperBound=TargetTime+0.0025;
            
            app.MinTargetTimeEditField.Value=app.TargetTime_LowerBound;
            app.MaxTargetTimeEditField.Value=app.TargetTime_UpperBound;
            
            app.SetPoint_px=800;
            app.SetpointpxEditField.Value=app.SetPoint_px;
            
            app.ErrorOutput=0;
            
            app.k_p=0.2;
            app.KpEditField.Value=app.k_p;
            app.k_i=0.1;
            app.KiEditField.Value=app.k_i;
            app.k_d=0.1;
            app.kdEditField.Value=app.k_d;
            
            app.NumberOfShotsPerDatapoint=1;
            app.ShotsaveragedEditField.Value=app.NumberOfShotsPerDatapoint;
        end

        % Value changed function: KpEditField
        function KpEditFieldValueChanged(app, event)
            value = app.KpEditField.Value;
            app.k_p=value;
        end

        % Value changed function: kdEditField
        function kdEditFieldValueChanged(app, event)
            value = app.kdEditField.Value;
            app.k_d=value;
        end

        % Value changed function: KiEditField
        function KiEditFieldValueChanged(app, event)
            value = app.KiEditField.Value;
            app.k_i=value;
        end

        % Value changed function: SetpointpxEditField
        function SetpointpxEditFieldValueChanged(app, event)
            value = app.SetpointpxEditField.Value;
            app.RunFeedbackBool=false;
            app.SetPoint_px=value;
        end

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
            app.RunFeedbackBool=true;
            app.RunPID();
        end

        % Value changed function: MaxTargetTimeEditField
        function MaxTargetTimeEditFieldValueChanged(app, event)
            value = app.MaxTargetTimeEditField.Value;
            app.TargetTime_UpperBound=value;
        end

        % Value changed function: MinTargetTimeEditField
        function MinTargetTimeEditFieldValueChanged(app, event)
            value = app.MinTargetTimeEditField.Value;
            app.TargetTime_LowerBound=value;
        end

        % Button pushed function: StopButton
        function StopButtonPushed(app, event)
            app.RunFeedbackBool=false;
        end

        % Value changed function: ShotsaveragedEditField
        function ShotsaveragedEditFieldValueChanged(app, event)
            value = app.ShotsaveragedEditField.Value;
            app.NumberOfShotsPerDatapoint=value;  
            app.LogEditField.Value=['N avg changed to ',num2str(value),'.'];
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 757 581];
            app.UIFigure.Name = 'MATLAB App';

            % Create EOSPlot
            app.EOSPlot = uiaxes(app.UIFigure);
            title(app.EOSPlot, 'rel. TOA as measured on EOS')
            xlabel(app.EOSPlot, 'moving shot no.')
            ylabel(app.EOSPlot, 'EOS signal (px)')
            app.EOSPlot.Position = [29 370 468 185];

            % Create TimingPlot
            app.TimingPlot = uiaxes(app.UIFigure);
            title(app.TimingPlot, 'Target time set point')
            xlabel(app.TimingPlot, 'moving shot no.')
            ylabel(app.TimingPlot, 'Target time (ns)')
            app.TimingPlot.Position = [29 167 473 185];

            % Create StartButton
            app.StartButton = uibutton(app.UIFigure, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.Position = [172 46 100 22];
            app.StartButton.Text = 'Start';

            % Create StopButton
            app.StopButton = uibutton(app.UIFigure, 'push');
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);
            app.StopButton.Position = [283 46 100 22];
            app.StopButton.Text = 'Stop';

            % Create KpEditFieldLabel
            app.KpEditFieldLabel = uilabel(app.UIFigure);
            app.KpEditFieldLabel.HorizontalAlignment = 'right';
            app.KpEditFieldLabel.Position = [577 483 25 22];
            app.KpEditFieldLabel.Text = 'Kp';

            % Create KpEditField
            app.KpEditField = uieditfield(app.UIFigure, 'numeric');
            app.KpEditField.ValueChangedFcn = createCallbackFcn(app, @KpEditFieldValueChanged, true);
            app.KpEditField.Position = [617 483 100 22];

            % Create kdEditFieldLabel
            app.kdEditFieldLabel = uilabel(app.UIFigure);
            app.kdEditFieldLabel.HorizontalAlignment = 'right';
            app.kdEditFieldLabel.Position = [577 385 25 22];
            app.kdEditFieldLabel.Text = 'kd';

            % Create kdEditField
            app.kdEditField = uieditfield(app.UIFigure, 'numeric');
            app.kdEditField.ValueChangedFcn = createCallbackFcn(app, @kdEditFieldValueChanged, true);
            app.kdEditField.Position = [617 385 100 22];

            % Create ShotsaveragedEditFieldLabel
            app.ShotsaveragedEditFieldLabel = uilabel(app.UIFigure);
            app.ShotsaveragedEditFieldLabel.HorizontalAlignment = 'right';
            app.ShotsaveragedEditFieldLabel.Position = [512 334 90 22];
            app.ShotsaveragedEditFieldLabel.Text = 'Shots averaged';

            % Create ShotsaveragedEditField
            app.ShotsaveragedEditField = uieditfield(app.UIFigure, 'numeric');
            app.ShotsaveragedEditField.ValueChangedFcn = createCallbackFcn(app, @ShotsaveragedEditFieldValueChanged, true);
            app.ShotsaveragedEditField.Position = [617 334 100 22];

            % Create SetpointpxEditFieldLabel
            app.SetpointpxEditFieldLabel = uilabel(app.UIFigure);
            app.SetpointpxEditFieldLabel.HorizontalAlignment = 'right';
            app.SetpointpxEditFieldLabel.Position = [151 106 77 22];
            app.SetpointpxEditFieldLabel.Text = 'Set point (px)';

            % Create SetpointpxEditField
            app.SetpointpxEditField = uieditfield(app.UIFigure, 'numeric');
            app.SetpointpxEditField.ValueChangedFcn = createCallbackFcn(app, @SetpointpxEditFieldValueChanged, true);
            app.SetpointpxEditField.Position = [243 106 100 22];

            % Create MinTargetTimeEditFieldLabel
            app.MinTargetTimeEditFieldLabel = uilabel(app.UIFigure);
            app.MinTargetTimeEditFieldLabel.HorizontalAlignment = 'right';
            app.MinTargetTimeEditFieldLabel.Position = [508 231 94 22];
            app.MinTargetTimeEditFieldLabel.Text = 'Min. Target Time';

            % Create MinTargetTimeEditField
            app.MinTargetTimeEditField = uieditfield(app.UIFigure, 'numeric');
            app.MinTargetTimeEditField.ValueChangedFcn = createCallbackFcn(app, @MinTargetTimeEditFieldValueChanged, true);
            app.MinTargetTimeEditField.Position = [617 231 100 22];

            % Create MaxTargetTimeEditFieldLabel
            app.MaxTargetTimeEditFieldLabel = uilabel(app.UIFigure);
            app.MaxTargetTimeEditFieldLabel.HorizontalAlignment = 'right';
            app.MaxTargetTimeEditFieldLabel.Position = [504 280 98 22];
            app.MaxTargetTimeEditFieldLabel.Text = 'Max. Target Time';

            % Create MaxTargetTimeEditField
            app.MaxTargetTimeEditField = uieditfield(app.UIFigure, 'numeric');
            app.MaxTargetTimeEditField.ValueChangedFcn = createCallbackFcn(app, @MaxTargetTimeEditFieldValueChanged, true);
            app.MaxTargetTimeEditField.Position = [617 280 100 22];

            % Create KiEditFieldLabel
            app.KiEditFieldLabel = uilabel(app.UIFigure);
            app.KiEditFieldLabel.HorizontalAlignment = 'right';
            app.KiEditFieldLabel.Position = [578 436 25 22];
            app.KiEditFieldLabel.Text = 'Ki';

            % Create KiEditField
            app.KiEditField = uieditfield(app.UIFigure, 'numeric');
            app.KiEditField.ValueChangedFcn = createCallbackFcn(app, @KiEditFieldValueChanged, true);
            app.KiEditField.Position = [618 436 100 22];

            % Create LogTextAreaLabel
            app.LogTextAreaLabel = uilabel(app.UIFigure);
            app.LogTextAreaLabel.HorizontalAlignment = 'right';
            app.LogTextAreaLabel.Position = [511 104 26 22];
            app.LogTextAreaLabel.Text = 'Log';

            % Create LogEditField
            app.LogEditField = uitextarea(app.UIFigure);
            app.LogEditField.Position = [552 68 150 60];

            % Create CorrectTick
            app.CorrectTick = uicheckbox(app.UIFigure);
            app.CorrectTick.Text = 'Correcting timing (instead of only reading)';
            app.CorrectTick.Position = [455 25 247 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = EOS_PID_GUI

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