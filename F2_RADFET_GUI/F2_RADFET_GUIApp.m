classdef F2_RADFET_GUIApp < handle
    % This is the support class for the Camera Reboot and Radiation Plotter
    % GUI. Use the GUI to create plots of reboot counts and radiation for
    % cameras at the dump.
    
    properties
        guihan
        starttime
        endtime
        CamRebootPV
        RADFETPV
        reboot_t
        reboot_v
        rad_t
        rad_v
        figFn
    end
      
    methods
        function obj = F2_RADFET_GUIApp(apphandle)
            obj.guihan = apphandle;
        end
        
        % Support functions
        function populateRADFET(obj)
            camera = obj.guihan.CameraDropDown.Value;
            switch camera
                case "LBG LFOV"
                    obj.RADFETPV = 'RADF:LI20:1:C:1:DOSE';
                    obj.guihan.RADFETDropDown.Value = obj.RADFETPV;
                    obj.CamRebootPV = 'CAMR:LI20:308:REBOOTCOUNT';
                case "DTOTR2"
                    obj.RADFETPV = 'RADF:LI20:1:D:1:DOSE';
                    obj.guihan.RADFETDropDown.Value = obj.RADFETPV;
                    obj.CamRebootPV = 'CAMR:LI20:107:REBOOTCOUNT';
                case "PRDMP"
                    obj.RADFETPV = 'RADF:LI20:2:A:1:DOSE';
                    obj.guihan.RADFETDropDown.Value = obj.RADFETPV;
                    obj.CamRebootPV = 'CAMR:LI20:108:REBOOTCOUNT';
                case "GAMMA2"
                    obj.RADFETPV = 'RADF:LI20:2:B:1:DOSE';
                    obj.guihan.RADFETDropDown.Value = obj.RADFETPV;
                    obj.CamRebootPV = 'CAMR:LI20:303:REBOOTCOUNT';
                case "GAMMA1"
                    obj.RADFETPV = 'RADF:LI20:2:C:1:DOSE';
                    obj.guihan.RADFETDropDown.Value = obj.RADFETPV;
                    obj.CamRebootPV = 'CAMR:LI20:302:REBOOTCOUNT';
                case "LFOV"
                    obj.RADFETPV = 'RADF:LI20:2:D:1:DOSE';
                    obj.guihan.RADFETDropDown.Value = obj.RADFETPV;
                    obj.CamRebootPV = 'CAMR:LI20:301:REBOOTCOUNT';
            end
        end
        
        function getArchiveData(obj)
            timeRange = [obj.starttime obj.endtime];
            
            [obj.reboot_t,obj.reboot_v] = history(obj.CamRebootPV,timeRange);
            [obj.rad_t,obj.rad_v] = history(obj.RADFETPV,timeRange);
        end
        
        function plotData(obj)
            yyaxis(obj.guihan.UIAxes,'left')
            plot(obj.guihan.UIAxes,obj.rad_t,obj.rad_v)
            datetick(obj.guihan.UIAxes)
            ylabel(obj.guihan.UIAxes,"RADFET (Rad)")
            
            yyaxis(obj.guihan.UIAxes,'right')
            plot(obj.guihan.UIAxes,obj.reboot_t,obj.reboot_v)
            datetick(obj.guihan.UIAxes)
            ylabel(obj.guihan.UIAxes,"Reboot Counts")
            
            title(obj.guihan.UIAxes,obj.guihan.CameraDropDown.Value)
        end
        
        function exportLogbook(obj)
            obj.figFn = 'RADFET_plot.png';
            exportgraphics(obj.guihan.UIAxes,obj.figFn)

            imshow(obj.figFn,'Border','tight')
            fig = gcf;
            util_printLog2020(fig,'title',...
                "Radiation and Reboot Count for "+...
                obj.guihan.CameraDropDown.Value,'author',...
                'F2_CameraRebootPlotter.m')
            close(fig)
            delete(obj.figFn)
        end
    end
    
end