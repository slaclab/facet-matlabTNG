classdef DAQMonitorScript < handle
    events
        PVUpdated
    end
    properties
        pvs = {'SIOC:SYS1:ML02:AO352','EVNT:SYS1:1:PMAQCTRL.E','EVNT:SYS1:1:PMAQCTRL.H','SIOC:SYS1:ML02:AO353'}
        guihan
        listener
    end
    methods
        function obj = DAQMonitorScript(apphandle) %Listens for updates to check pv status
            obj.guihan = apphandle;
            for i = 1:numel(obj.pvs)
                obj.listener{i} = addlistener(obj,'PVUpdated',@(~,~)obj.UpdateLamp);
            end
            obj.UpdateLamp()
        end
        function UpdateLamp(obj) %Updates lamp color based on current value
            DAQRunningStatusLampValue = lcaGet(obj.pvs{1});
            EnabledLampValue = lcaGet(obj.pvs{2});
            ResettoZeroLampValue = lcaGet(obj.pvs{3});
            
            if DAQRunningStatusLampValue == 0
                obj.guihan.DAQRunningStatusLamp.Color = [0.7,0.7,0.7];
            else
                obj.guihan.DAQRunningStatusLamp.Color = 'g';
            end
            if EnabledLampValue == 1
                obj.guihan.EnabledLamp.Color= 'g';
            else
                obj.guihan.EnabledLamp.Color = 'r';
            end
            if ResettoZeroLampValue == 0
                obj.guihan.ResettoZeroLamp.Color = 'g';
            else
                obj.guihan.ResettoZeroLamp.Color = 'r';
            end
            obj.UpdateTable();
        end
        function UpdateStatusButton(obj)
            obj.UpdateLamp();
            obj.guihan.UpdateLabel.Text = 'Status Updated'; %Text disappears after 15 seconds
            AbortLabeltimer = timer('ExecutionMode', 'singleShot', 'StartDelay', 15,'TimerFcn', @(~,~) obj.clearLabels({'UpdateLabel'}));
            start(AbortLabeltimer);
        end
        function UpdateTable(obj)
            data = load('camerapvs.mat');
            fieldNames = fields(data);
            if numel(fieldNames)== 1 %Checks which cameras are in use by DAQ
                AllCameras = data.(fieldNames{1});
                FilteredCameras = {};
                ShotsCaptured = {};
                DAQinuseFormat = '%s:DAQ_InUse';
                ShotsFormat = '%s:NumCaptured_RBV';
                for i = 1:numel(AllCameras)
                    CameraName = AllCameras{i};
                    DAQinusePV = sprintf(DAQinuseFormat, CameraName);
                    DAQinuseValue = lcaGet(DAQinusePV);
                    if DAQinuseValue == 1
                        FilteredCameras{end+1} = cameraname;
                        Captured = sprintf(ShotsFormat, CameraName);
                        NumCaptured = lcaget(Captured);
                        ShotsCaptured(end+1)= NumCaptured;
                    end
                end
                if ~isempty(FilteredCameras)
                    tableData = [FilteredCameras(:), num2cell(ShotsCaptured)];
                    obj.guihan.UITable.data = tableData;
                    obj.guihan.UITable.ColumnName = {'Camera Name','Shots Captured'};
                else
                    obj.guihan.UITable.ColumnName = {'No Cameras being Used'};
                end
            end
        end
        function ResetPVs(obj) %Resets pvs to ideal value
            lcaPut(obj.pvs{2},1);
            lcaPut(obj.pvs{3},0);
            obj.UpdateLamp();
        end
        function Enable(obj)
            lcaPut(obj.pvs{2},1);
            obj.UpdateLamp();
        end
        function ResetZero(obj)
            lcaPut(obj.pvs{3},0);
            obj.UpdateLamp();
        end
        function AbortDAQ(obj)
            lcaPut(obj.pvs{4},1);
            AbortValue = lcaGet(obj.pvs{4});
            if AbortValue == 1
                obj.guihan.AbortLabel.Text = 'DAQ Aborted';
            else
                obj.guihan.AbortLabel.Text = 'DAQ Unable to Abort';
            end
            obj.UpdateLamp();
            AbortButtonTimer = timer('ExecutionMode', 'singleShot', 'StartDelay', 15,'TimerFcn', @(~,~) obj.clearLabels({'AbortLabel'}));
            start(AbortButtonTimer);
        end
        function ResetDAQ(obj)
            lcaPut(obj.pvs{1},0);
            ResetValue = lcaGet(obj.pvs{1});
            if ResetValue == 0
                obj.guihan.ResetLabel.Text = 'DAQ Reset Successfully';
            else
                obj.guihan.ResetLabel.Text = 'DAQ Not Reset';
            end
            obj.UpdateLamp();
            ResetDAQTimer = timer('ExecutionMode', 'singleShot', 'StartDelay', 15,'TimerFcn', @(~,~) obj.clearLabels({'ResetLabel'}));
            start(ResetDAQTimer);
        end
        function RunDAQ(obj) 
            try
                params = load('TEST_config_GUI.mat'); %Test DAQ parameters
                daq_params_test_gui = params.daq_params;
                F2_fastDAQ_HDF5(daq_params_test_gui);
                obj.guihan.DAQlabel.Text = 'DAQ run successfully';
                obj.UpdateLamp();
            catch
                obj.guihan.DAQlabel.Text = 'DAQ failed to run';
                obj.UpdateLamp();
            end
        end
        function clearLabels(obj, labelNames)
            for i = 1:numel(labelNames)
                label = obj.guihan.(labelNames{i});
                if isprop(label, 'Text')
                    label.Text = ' ';
                end
            end
        end
    end
end

