classdef F2_RADFET_GUIApp < handle
    % This is the support class for the RADFET GUI
    % Use the GUI to create plots of reboot counts and radiation or charge
    % for cameras at the dump
    
    % Dump Cameras and their associated RADFETs:
    % The mapping may change in the future. Refer to facethome

%     Camera Name   PV               RADFET
%     --------------------------------------------------
%     LBG_LFOV      CMOS:LI20:3515   RADF:LI20:1:D:1:DOSE
%     DTOTR2        CAMR:LI20:107    RADF:LI20:1:C:1:DOSE
%     CHER          CMOS:LI20:3506   RADF:LI20:2:A:1:DOSE
%     GAMMA2        CAMR:LI20:303    RADF:LI20:2:B:1:DOSE
%     GAMMA1        CAMR:LI20:302    RADF:LI20:2:C:1:DOSE
%     LFOV          CAMR:LI20:301    RADF:LI20:2:D:1:DOSE

    
    properties
        guihan
        radfetPVs = {'RADF:LI20:1:D:1:DOSE';'RADF:LI20:1:C:1:DOSE';...
                'RADF:LI20:2:A:1:DOSE';'RADF:LI20:2:B:1:DOSE';...
                'RADF:LI20:2:C:1:DOSE';'RADF:LI20:2:D:1:DOSE'};
        camNames = {'LBG LFOV';'DTOTR2';'CHER';'GAMMA2';'GAMMA1';'LFOV'}
        camPVs = {'CMOS:LI20:3515';'CAMR:LI20:107';'CMOS:LI20:3506';...
            'CAMR:LI20:303';'CAMR:LI20:302';'CAMR:LI20:301'};
        starttime % Start time for data time range
        endtime % End time for data time range
        CamRebootPV % Reboot PV for selected camera
        RADFETPV % PV for selected RADFET
        toroidPV = 'TORO:LI20:3255:TMIT_PC'
        reboot_t % Time stamps for reboot count
        reboot_v % Values for reboot count
        rad_t % Time stamps for RADFET
        rad_v % Values for RADFET
        toro_t % Time stamps for toroid
        toro_v % Values for toroid
        totalCharge % Integrated charge values
        plotVar % Variable (Radiation or Charge) to plot on second axis
        figFn % Figure file name used for plotting to eLog
    end
      
    methods
        function obj = F2_RADFET_GUIApp(apphandle)
            obj.guihan = apphandle;
        end
        
        % Support functions
        function populate(obj)
            camera = obj.guihan.CameraDropDown.Value;
            
            % Based on camera chosen, auto populate the RADFET and toroid
            % drop down values
            i = strcmp(camera,obj.camNames);
            obj.RADFETPV = obj.radfetPVs(i);
            obj.toroidPV = 'TORO:LI20:3255:TMIT_PC';
            obj.CamRebootPV = [obj.camPVs{i} ':REBOOTCOUNT'];
            
            % Update RADFET drop down
            obj.guihan.RADFETDropDown.Value = obj.RADFETPV;
        end
        
        function getArchiveData(obj)
            % Get data from archiver within selected time range
            timeRange = [obj.starttime obj.endtime];
            [obj.reboot_t,obj.reboot_v] = history(obj.CamRebootPV,...
                        timeRange);
            switch obj.plotVar
                case "Radiation"
                    obj.RADFETPV = obj.guihan.RADFETDropDown.Value;
                    [obj.rad_t,obj.rad_v] = history(obj.RADFETPV,timeRange);
                case "Charge"
                    [obj.toro_t,obj.toro_v] = history(obj.toroidPV,timeRange);
                    toroid_data = obj.toro_v;
                    
                    % Filter noise and negative values
                    toroid_data(toroid_data<100) = 0;
                    
                    % Get time difference between sample points in seconds. For points where
                    % difference is 0 (ie. 2 data points taken in one second), set multiplier
                    % to 0.5
                    t_diffs = 24*60*60*diff(obj.toro_t);
                    t_diffs(t_diffs==0) = 0.5;
                    
                    % Get frequency multiplier and apply to data to get real total charge
                    freq_mult = 10*[1; t_diffs];
                    charge10Hz = freq_mult.*toroid_data;
                    obj.totalCharge = cumsum(charge10Hz);
                otherwise
                    % do nothing
            end
        end
        
        function plotData(obj)
            switch obj.plotVar
                case "Radiation"
                    % Plot RADFET values on left axis
                    yyaxis(obj.guihan.UIAxes,'left')
                    plot(obj.guihan.UIAxes,obj.rad_t,obj.rad_v)
                    datetick(obj.guihan.UIAxes)
                    ylabel(obj.guihan.UIAxes,"RADFET (Rad)")
                case "Charge"
                    % Plot toroid values on left axis
                    yyaxis(obj.guihan.UIAxes,'left')
                    plot(obj.guihan.UIAxes,obj.toro_t,obj.totalCharge/1000)
                    datetick(obj.guihan.UIAxes)
                    ylabel(obj.guihan.UIAxes,"Total cumulative charge (nC)")
                otherwise
                    % display error message
            end
            
            % Plot reboot count values on right axis
            yyaxis(obj.guihan.UIAxes,'right')
            plot(obj.guihan.UIAxes,obj.reboot_t,obj.reboot_v)
            datetick(obj.guihan.UIAxes)
            ylabel(obj.guihan.UIAxes,"Reboot Counts")
            
            title(obj.guihan.UIAxes,obj.guihan.CameraDropDown.Value)
        end
        
        function exportLogbook(obj)
            % Export UI Axis content to a PNG image
            obj.figFn = 'RADFET_plot.png';
            exportgraphics(obj.guihan.UIAxes,obj.figFn)

            % Open the PNG image, get figure handle, and print to eLog
            imshow(obj.figFn,'Border','tight')
            fig = gcf;
            util_printLog2020(fig,'title',...
                obj.plotVar+" and Reboot Count for "+...
                obj.guihan.CameraDropDown.Value,'author',...
                'F2_RADFET_GUI.m')
            
            % Close image and delete file
            close(fig)
            delete(obj.figFn)
        end
    end
    
end