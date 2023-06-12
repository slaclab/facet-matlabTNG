classdef AppSupportTemplate < handle
    % This file is a template for the Summer Example App tutorial.
    % Fill in the script to create an App that plots Process Variables
    % from EPICS.
    
    events
        PVUpdated
    end
    
    properties
        pvlist PV
        pvs
        guihan
        plotOptionState
        % Add a property that stores application data here
    end
    
    properties (Hidden)
        listeners
    end
    
    properties (Constant)
        numPlotPts = 50;
    end
    
    methods
        % This section contains functions that are needed to run the app
        
        function obj = AppSupportTemplate(apphandle)
            % This is the constructor method. This function is run when
            % an instance of the class is created. Property values are
            % initialized here.
            
            % Initialize the object and add PVs to be monitored
            context = PV.Initialize(PVtype.EPICS);
            obj.pvlist = [...
                PV(context,'name',"GaugePV1",'pvname',"SIOC:SYS1:ML00:AO951",'mode',"rw",'monitor',true,'guihan',apphandle.PV1Gauge);
                % Add another PV here:
                ];
            
            % Set debug level to 0 to enable read/write operations (make 
            % PV objects live)
            pset(obj.pvlist,'debug',0);
            
            % Place the PVs in a struct
            obj.pvs = struct(obj.pvlist);
            
            % Associate class with GUI
            obj.guihan = apphandle;
            
            % Create arrays to store the PV values to be plotted at each
            % time stamp. Use the property numPlotPts, and store both
            % arrays in the data property you defined above.
            % Add your code here:
            

            % Set the initial state of the app to "Waiting for Input"
            obj.plotOptionState = "Waiting for Input";
            
            % Start listening for PV updates
            obj.listeners = addlistener(obj,'PVUpdated',@(~,~)obj.loop);
            run(obj.pvlist,false,0.1,obj,'PVUpdated');
        end
        
        function loop(obj)
            % The app will loop through this function every 0.1 s.
            
            % Get the PV values and assign them to a variable
            PV1_val = obj.pvs.GaugePV1.val{1};
            PV2_val = obj.pvs.GaugePV2.val{1};
            
            % Assign each variable to the last value in its respective
            % PV array:
            
            
            % Add a switch that plots a different PV depending on what the
            % Plot Option State is
            switch % Switch variable here
                case % Case where PV1 is chosen
                    % Plot PV1 values:
                    
                    drawnow
                case % Case where PV2 is chosen
                    % Plot PV2 values:
                    
                    drawnow
                otherwise
                    % Do nothing. This case is only true when the app is
                    % first launched, and the state is "Waiting for Input"
            end
            
            % Use "circshift" to shift the values in the arrays to the
            % left:
            
        end
        
        function
            % Define a function that updates the Plot Option State to "Plot
            % PV1"
            cla(obj.guihan.UIAxes);
            % Add your code here:
            
        end
        
        function
            % Define a function that updates the Plot Option State to "Plot
            % PV2"
            cla(obj.guihan.UIAxes);
            % Add your code here:
            
        end
        
        function clearPV(obj)
            % This function stops pvlist.
            stop(obj.pvlist);
        end
    end
end