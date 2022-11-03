classdef bsagui_constants < handle
    %BSAGUI_CONSTANTS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        menuitems
        defaultPlotVars
        valid_eDefs
        uniqueNumberPV = 'SIOC:SYS0:ML00:AO900'
        savePV = 'SIOC:SYS0:ML00:CA700'
        zLCLS = 2014.7019 % z offset of LCLS injector
        protected_fields = {'app', 'BSD_inputs', 'BSD_ROOT_NAME', 'BSD_window', 'bufferRatesText', 'constants',...
                'createVarApp', 'createVar_fields', 'default_plot_vars', 'dev', 'eDefs', 'env', 'facet',...
                'have_eDef', 'host', 'lcls', 'linac', 'multiplot', 'multiplot_same', 'new_model', 'offset',...
                'sys', 'waitenoload', 'z_options', 'zLCLS', 'zOptApp'};
        bufferSize = struct('facet', 2800,...
                            'CU', 2800,...
                            'SC', 20000)
    end
    
    methods
        function obj = bsagui_constants()
            %BSAGUI_CONSTANTS Construct an instance of this class
            %   Detailed explanation goes here
            setMenuItems(obj);
            setPlotVars(obj);
            setSIOCS(obj);
        end
        
        function setMenuItems(obj)
            % Hardcoded default eDefs for CU, SC, and FACET
            obj.menuitems.dev = {'CUH', 'CUS', 'SCH', 'SCS'};
            obj.menuitems.CU = {'Private', 'CUS1H', 'CUSTH', 'CUSBR', 'CUH1H',...
                            '1H', 'TH', 'BR', 'CUHTH', 'CUHBR'};
            obj.menuitems.SC = {'Private', 'SCH1H', 'SCHTH', 'SCHHH',...
                            'SCS1H', 'SCSTH', 'SCSHH'};
            obj.menuitems.facet = {'Private', '1H', 'TH', 'BR'};
        end
        
        function setPlotVars(obj)
             obj.defaultPlotVars.dev = {'Time', 'Index', 'PSD', 'Histogram', 'All Z', 'Z PSD', 'Jitter Pie'};
             obj.defaultPlotVars.CU = {'Time', 'Index', 'PSD', 'Histogram', 'All Z', 'Z PSD', 'Jitter Pie', 'Z RMS'};
             obj.defaultPlotVars.SC = {'Time', 'Index', 'PSD', 'Histogram', 'All Z', 'Z PSD'};
             obj.defaultPlotVars.facet = {'Time', 'Index', 'PSD', 'Histogram'};
        end
        
        function setValidEDefs(obj)
            obj.valid_eDefs.CU = 1:11;
            obj.valid_eDefs.SC = 21:64;
            obj.valid_eDefs.facet = [1:15, 19:20];
        end
        
        function setSIOCS(obj)
            sys = getSystem();
            if strcmp(sys, 'SYS1')
                obj.uniqueNumberPV = strrep(obj.uniqueNumberPV, 'SYS0', 'SYS1');
                obj.savePV = strrep(obj.savePV, 'SYS0', 'SYS1');
            end
        end
    end
end

