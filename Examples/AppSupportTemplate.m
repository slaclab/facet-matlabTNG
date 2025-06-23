classdef AppSupportTemplate < handle
    % This file is a template for the MATLAB GUI tutorial.
    % Fill in the script to create an App that plots Process Variables
    % from EPICS.
    
    properties
        PVtimer
        guihan
        PVtoPlot
        % Add a property that stores application data here
        plottingOn logical = false
    end
    
    properties (Constant)
        % This section contains properties that remain constant
        numPlotPts = 50
    end
    
    methods
        % This section contains functions that are needed to run the app
        
        function obj = AppSupportTemplate(apphandle)
            % This is the constructor method. This function is run when
            % an instance of the class is created. Property values are
            % initialized here.
            
            % Associate class with GUI
            obj.guihan = apphandle;
            
            % Create empty arrays to store the PV values to be plotted at 
            % each time stamp. Use the property numPlotPts, and store both
            % arrays in the data property you defined above.
            % Add your code here:
            
            
            % Set the initial state of the app to plot PV 1
            obj.PVtoPlot = "PV 1";
            
            % Create timer object
            % The timer executes a callback function every 1 s
            obj.PVtimer = timer("ExecutionMode","fixedRate","Period",1, ...
                "BusyMode","queue","TimerFcn",@obj.PVtimerFcn);
            
            % Start timer
            if strcmp(obj.PVtimer.Running,"off")
                start(obj.PVtimer);
            end
        end
        
        function PVtimerFcn(obj,~,event)
            % Use "circshift" to shift the values in the arrays to the
            % left:
            
            % Get the current PV values and assign them to a variable:
            PV1_val = ;
            PV2_val = ;
            
            % Store PV value in the last spot in its PV array:
            
            
            % Add a switch that plots a different PV depending on
            % PVtoPlot (ignore until Step 4)
            switch % Switch variable here
                case % Case where PV 1 is chosen
                    % Tell GUI to plot PV1 values here:
                    
                case % Case where PV 2 is chosen
                    % Tell GUI to plot PV2 values here:
                    
                otherwise
                    % Do nothing
            end
        end
        
        function imageData = loadFacetImage(obj)
            try
                fileData = load('/u1/facet/matlab/data/2025/2025-06/2025-06-02/ProfMon-CAMR_LI20_107-2025-06-02-235512.mat');
                imageData = fileData.data.img;
            catch
                imageData = 0;
            end
        end
        
        function closeApp(obj)
            stop(obj.PVtimer);
        end
    end
end