classdef cAligner < handle
    %% cAligner
    %  A class that combines an epicsCamera and two picomotors to create an
    %  alignment tool.
    %
    %  Public methods:
    %   
    %
    %  Public properties:
    %
    %
    
    %%
    properties (Access = public)
        cam
        xMotor
        xMf 
        yMotor
        yMf
        
        setPointX
        setPointY
    end
    
    properties (Access = private)
        curStackIdx = 1;
        imgStack;
        stackSize = 1;
        
    end
    
    methods (Access = public)    
        
        function s = cAligner(cPV, xPicoPV, yPicoPV, SPx, SPy,xMflipped,yMflipped)
            % cEpicsCamera creates an instant of this class
            %
            
            s.cam = cEpicsCamera(cPV);
            s.xMotor = cEpicsPicoMotor(xPicoPV);
            s.xMf = xMflipped;
            s.yMotor = cEpicsPicoMotor(yPicoPV);
            s.yMf = yMflipped;
            
            s.setPointX = SPx;
            s.setPointY = SPy;
            
            s.initData();
        end
        
        function initData(s)
            s.cam.updateData();
            
            s.curStackIdx = (s.curStackIdx+1) - ... 
            ((s.curStackIdx > s.stackSize)*s.stackSize);
            %s.curStackIdx = mod(s.curStackIdx, s.stackSize);
            [y,x] = size(s.cam.lastImg);
            s.imgStack = zeros(y,x,s.stackSize);
            s.imgStack(:,:,s.curStackIdx) = s.cam.lastImg;
        end
        
        function moveX(s,step)
            s.xMotor.move(s.xMf*step)
        end
        
        function moveY(s,step)
            s.yMotor.move(s.yMf*step)
        end
    end
    
    
    %% Getters
    methods (Access = public)
        
        function avImg = getAvImg(s)
            % Returns the stack averaged image
            avImg = mean(s.imgStack,3)/size(s.imgStack,3);
        end
            
        function [sPX, sPY] = getTarget(s)
            % [sPX, sPY] = getTarget()
            % Returns ROI adjusted set points
            
            sPX = s.setPointX - s.cam.ROIminX;
            sPY = s.setPointY - s.cam.ROIminY;
        end
    end
    
    %% Helpers
    methods (Access = private)
        
        function [beamImageData,FilteredImg] = grabLaserProperties(s)
            % [beamImageData,FilteredImg] = grabLaserProperties
            
            % beamAnalysis_beamParams
            % All available fitting methods
            % methods = {'Gaussian','Asym Gauss', 'Super Gauss','Raw RMS','RMS with peak cut',...
            %    'RMS area cut','RMS noise cut','4th ord. Gauss','Double Gauss','Double Asym Gauss'};
            %
            %        STATS:    [XMEAN YMEAN XRMS YRMS CORR SUM]
            %        XSTAT:    [SUM MEAN RMS SKEW KURTOSIS]
            
            % Set Asym Gaussian as default fit method
            opts = struct('usemethod',2);
            
            [FilteredImg,~,~,~,~] = beamAnalysis_imgProc(s.data,opts); % Processed Image
            % Calculate beam statistics
            beamParams = beamAnalysis_beamParams(FilteredImg, 1:size(FilteredImg,2), 1:size(FilteredImg,1),0,opts);
            
            stats = [beamParams.stats beamParams.xStat];
                    
            beamImageData = [stats(1:4),sum(sum(FilteredImg))*1e-6];
            
        end
        
    end
        
end