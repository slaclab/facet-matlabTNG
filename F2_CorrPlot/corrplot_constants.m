classdef corrplot_constants < handle
    %CORRPLOT_CONSTANTS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        mdl
        BSAOptions
        defaultReadPVs
        methodList = {'Gaussian','Asymetric Gaussian','RMS',...
                      'RMS Cut Peak','RMS Cut Area', 'RMS Cut Floor'}
        methodMap = [1, 2, 4, 5, 6, 7]
    end
    
    methods
        function obj = corrplot_constants()
            %CORRPLOT_CONSTANTS Construct an instance of this class
            %   Detailed explanation goes here
            setBSAOptions(obj);
            setDefaultReadPVs(obj);
        end
        
        function setBSAOptions(obj)
            %METHOD Summary of this method goes here
            %   Detailed explanation goes here
            obj.BSAOptions.SC = {'None', '1Hz', '10Hz', '100Hz', '1kHz', '10kHz', '71.5 kHz', '1MHz'};
            obj.BSAOptions.CU = {'None', 'ONE_HERTZ', 'TEN_HERTZ', 'THIRTY_HERTZ', 'TS4', '120_HERTZ', 'EVG_BURST'};
        end
        
        function setDefaultReadPVs(obj)
            obj.defaultReadPVs.CU =  {'BPMS:IN20:221:TMIT';'GDET:FEE1:241:ENRC';'EM1K0:GMD:HPS:milliJoulesPerPulse'};
        end
    end
end

