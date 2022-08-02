classdef cEpicsCamera < handle
    %CEPICSCAMERA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        PV
        lastData
        lastImg
        
        ROIminX
        ROIminY
        ROIsizeX
        ROIsizeY
        
    end
    
    methods
        function s = cEpicsCamera(PV)
            %CEPICSCAMERA Construct an instance of this class
            %   Detailed explanation goes here
            s.PV = PV;
            s.getImgData();
        end
        
        function updateData(s)
            data = s.getImgData();
            s.lastImg = data.img;
            
            s.ROIminX = data.roiX;
            s.ROIminY = data.roiY;
            s.ROIsizeX = data.roiXN;
            s.ROIsizeY = data.roiYN;
            
            
        end
        
        function data = getImgData(s)
            data = profmon_grab(s.PV,0);
            s.lastData = data;
        end
        
        function img = getFastImg(s)
            % Returns only the image, does not update data struct
            % Supposed to be faster than profmon_grab
            % fliplr and tranpose is to get the same image orientation as
            % profmon_grab
            im_vec = lcaGetSmart([s.PV,':Image:ArrayData']);
            im_vec = im_vec(1:(s.lastData.roiXN*s.lastData.roiYN));
            im_vec = fliplr(im_vec);
            img = reshape(im_vec,[s.lastData.roiXN,s.lastData.roiYN]);
            img = img.';
            s.lastImg = img;
        end
        
    end
    
    %% Getters
    methods
        function expT = getExposure(s)
            expT = lcaGetSmart([s.PV,':AcquireTime_RBV']);
        end
        
        function img = getImage(s)
            img = s.lastImg;
        end
    end
    
    %% Setters
    methods
        function setExposure(s, expT)
            lcaPutSmart([s.cameraPV,':AcquireTime'], expT)
        end
    end
    
end

