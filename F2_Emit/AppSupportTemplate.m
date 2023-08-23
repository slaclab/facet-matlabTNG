classdef AppSupportTemplate < handle

    
    properties
        guihan
        plotOptionState
        %a property that stores application data here
        data
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
           
                
 
            
            % Associate class with GUI
            obj.guihan = apphandle;
            obj.data.dataSetID = nan;
            obj.data.exp = nan;
        end
        

%         
%         function setPlotOptTo1(obj)
%             % Define a function that updates the Plot Option State to "Plot
%             % PV1"
%             cla(obj.guihan.UIAxes);
%             % Add your code here:
%             obj.plotOptionState = "Plot PV1";
%         end
        
        %Aquire Data: 
        function [data_struct, header] = dataYum(obj, dataSetID,exp)
                [data_struct, header] = getDataSet(dataSetID, exp);
        end
        
        %Read image data:
        function [img, x, y, res, xmm, ymm] = dataYummy(obj, GUI, data_struct, header, cam, n, isrot)
            [img, x, y, res, xmm, ymm] = read_img(data_struct, GUI, header, cam, n, isrot);
         
        end 
        
        %Plot image:
        function plotty(obj, xmm, ymm, img, GUI)
            plot_img(xmm, ymm,img, GUI);
            
        end 

        
    end
    
    
    
end