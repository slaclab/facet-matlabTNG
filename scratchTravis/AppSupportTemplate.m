classdef AppSupportTemplate < handle
    % This file is a template for the MATLAB GUI tutorial.
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
        data
    end
    
    properties (Hidden)
        listeners
    end
    
    properties (Constant)
        numPlotPts = 50
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
                PV(context,'name',"GaugePV1",'pvname',"SIOC:SYS1:ML00:AO952",'mode',"rw",'monitor',true,'guihan',apphandle.PV1Gauge);
                PV(context,'name',"GaugePV2",'pvname',"SIOC:SYS1:ML00:AO953",'mode',"rw",'monitor',true,'guihan',apphandle.PV2Gauge);
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
            obj.data.PV1Vals = zeros(1,obj.numPlotPts);
            obj.data.PV2Vals = zeros(1,obj.numPlotPts);

            % Set the initial state of the app to "Waiting for Input"
            obj.plotOptionState = "Waiting for Input";
            
            % Start listening for PV updates
            obj.listeners = addlistener(obj,'PVUpdated',@(~,~)obj.loop);
            run(obj.pvlist,false,0.1,obj,'PVUpdated');
        end
        
        function loop(obj)
            % The app will loop through this function every 0.1 s.
            
            % Get the current PV values and assign them to a variable
            PV1_val = obj.pvs.GaugePV1.val{1};
            PV2_val = obj.pvs.GaugePV2.val{1};
            
            % Assign each variable to the last value in its respective
            % PV array:
            obj.data.PV1Vals(end) = PV1_val;
            obj.data.PV2Vals(end) = PV2_val;
            
            % Add a switch that plots a different PV depending on the
            % Plot Option State (ignore until Step 4)
            switch obj.plotOptionState % Switch variable here
                case "Plot PV1"
                    plot(obj.guihan.UIAxes,obj.data.PV1Vals,'b')
                    drawnow
                case "Plot PV2"
                    plot(obj.guihan.UIAxes,obj.data.PV2Vals,'b')
                    drawnow  
                   
                otherwise
                    % Do nothing. This case is only true when the app is
                    % first launched, and the state is "Waiting for Input"
            end
            
            % Use "circshift" to shift the values in the arrays to the
            % left:
            obj.data.PV1Vals = circshift(obj.data.PV1Vals,-1);
            obj.data.PV2Vals = circshift(obj.data.PV2Vals,-1);
        end
        
        function setPlotOptTo1(obj)
            % Define a function that updates the Plot Option State to "Plot
            % PV1"
            cla(obj.guihan.UIAxes);
            % Add your code here:
            obj.plotOptionState = "Plot PV1"
            
        end
        
        function setPlotOptTo2(obj)
            % Define a function that updates the Plot Option State to "Plot
            % PV2"
            cla(obj.guihan.UIAxes);
            % Add your code here:
            obj.plotOptionState = "Plot PV2"
            
        end
        
        function clearPV(obj)
            % This function stops pvlist.
            Cleanup(obj.pvlist);
            stop(obj.pvlist);
        end
    end
end