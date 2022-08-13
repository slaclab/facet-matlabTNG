classdef F2_aligner_control < handle
    %F2_aligner_control class for supporting the F2_aligner GUI 
    
    properties
        GUI;
        aList; % List of camera motor pair classes cAligner.m
        currentCamera;
        x0
        x1
        
        y0
        y1
        
    end
    
    methods
        function s = F2_aligner_control(GUI)
            %F2_aligner_control constructs an instance of this class
            s.GUI = GUI;
            
            s.aList.DMNear = cAligner('CAMR:LT20:0013', ... 
                'MOTR:LI20:MC06:S2:CH2', 'MOTR:LI20:MC06:S2:CH1', 540, 500,-1,-1);
            s.aList.DMFar = cAligner('CAMR:LT20:0014', ... 
                'MOTR:LI20:MC06:S2:CH3', 'MOTR:LI20:MC06:S2:CH4', 900, 300,-1,-1);
            s.aList.Probeline0 = cAligner('CAMR:LI20:200', ... 
                'MOTR:LI20:MC09:M0:CH1', 'MOTR:LI20:MC09:M0:CH2', 658, 422,1,1);
            s.aList.Probeline1 = cAligner('CAMR:LI20:203', ...
                'MOTR:LI20:MC09:M0:CH4', 'MOTR:LI20:MC09:M0:CH3', 357, 233,1,1);
            s.aList.Probeline2 = cAligner('CAMR:LI20:204', ...
                'MOTR:LI20:MC09:S1:CH1', 'MOTR:LI20:MC09:S1:CH2', 650, 450,-1,-1);
            s.aList.CompNear = cAligner('CAMR:LI20:201', ...
                'MOTR:LI20:MC08:S2:CH3', 'MOTR:LI20:MC08:S2:CH4', 740, 493,-1,1);
            s.aList.CompFar = cAligner('CAMR:LI20:202', ...
                'MOTR:LI20:MC08:M0:CH2', 'MOTR:LI20:MC08:M0:CH1', 409, 384,-1,-1);
            s.aList.PBNear = cAligner('CAMR:LI20:305', ...
                'MOTR:LI20:MC08:S1:CH4', 'MOTR:LI20:MC08:S1:CH3', 570, 477,1,-1);
            s.aList.PBFar = cAligner('CAMR:LI20:306', ...
                'MOTR:LI20:MC08:S3:CH2', 'MOTR:LI20:MC08:S3:CH1', 604, 530,-1,-1);
            s.aList.Probeline0HeNe = cAligner('CAMR:LI20:200', ... 
                'MOTR:LI20:MC07:S1:CH2', 'MOTR:LI20:MC07:S1:CH1', 658, 422, -1, -1);
            
%             s.aList.PL0B3 = cAligner('CAMR:LI20:200', ... 
%                 'MOTR:LI20:MC07:S1:CH2', 'MOTR:LI20:MC07:S1:CH1', 632, 391,-1,-1);
%             s.aList.B4 = cAligner('CAMR:LI20:105', ... 
%                 'MOTR:LI20:MC07:S1:CH2', 'MOTR:LI20:MC07:S1:CH1', 966, 374,1,1);
%             s.aList.B0 = cAligner('CAMR:LT20:0101', ... 
%                 'MOTR:LI20:MC06:S5:CH1', 'MOTR:LI20:MC06:S5:CH2', 632, 391,1,1);
            
            cameraList = s.getCameras();
            s.currentCamera = cameraList{1};
            s.updateGUI(s.currentCamera);
            
        end
        
        function listOfCameras = getCameras(s)
            %getCameras returns a list of camera names
            %   
            listOfCameras = fieldnames(s.aList);
            
        end
        
        function updateImage(s, alignerName)
            % Plots a single image from dataset diag 
            
            s.aList.(alignerName).cam.updateData();
            imageData = s.aList.(alignerName).cam.getImage();
            
            % Get plot info
            curHandle = s.GUI.ImageAxes;
            s.hlpPlotImage(curHandle, imageData);
            
            [xt yt] = s.aList.(alignerName).getTarget();
            r = s.GUI.RadiusEditField.Value;
            s.hlpPlotCircle(curHandle,xt,yt,r);

        end
        
        function updateGUI(s, alignerName)
            %updates fields in GUI
            s.currentCamera = alignerName;
            s.GUI.HorizontalEditField.Value = ...
                s.aList.(alignerName).setPointX;
            s.GUI.VerticalEditField.Value = ...
                s.aList.(alignerName).setPointY;
            s.GUI.ExposuretimeEditField.Value = ...
                s.aList.(alignerName).cam.getExposure();
            
            s.x0 = s.aList.(alignerName).cam.ROIminX;
            s.x1 = s.x0 + s.aList.(alignerName).cam.ROIsizeX;
            
            s.y0 = s.aList.(alignerName).cam.ROIminY;
            s.y1 = s.y0 + s.aList.(alignerName).cam.ROIsizeY;
            
            s.updateImage(alignerName)
        end
        
        function hlpPlotImage(s, plotHandle, img)
            % Helps to set the correct parameters when plotting in the app
            plotHandle.YDir = 'normal';
            imagesc(plotHandle, img);

            plotHandle.XLim = [s.x0, s.x1];
            plotHandle.YLim = [s.y0, s.y1];
            
            cmax = s.GUI.BitdepthSpinner.Value;
            caxis(plotHandle,[0,2^cmax]);
        end
        
        function h = hlpPlotCircle(s,axis,x,y,r)
            hold(axis, 'on');
            th = 0:pi/50:2*pi;
            xunit = r * cos(th) + x;
            yunit = r * sin(th) + y;
            h = plot(axis,xunit, yunit, 'r','linewidth',2);
            plot(axis,[0 x-r], [y y], 'r','linewidth',1);
            plot(axis,[x+r s.x1], [y y], 'r','linewidth',1);
            plot(axis,[x x], [0 y-r], 'r','linewidth',1);
            plot(axis,[x x], [y+r s.y1], 'r','linewidth',1);
            hold(axis, 'off');
        end
    end
    
    methods
        function moveVerN(s)
            step = s.GUI.StepsizerevsEditField.Value;
            s.aList.(s.currentCamera).moveY(-step);
        end
        
        function moveVerP(s)
            step = s.GUI.StepsizerevsEditField.Value;
            s.aList.(s.currentCamera).moveY(step);
        end
        
        function moveHorN(s)
            step = s.GUI.StepsizerevsEditField.Value;
            s.aList.(s.currentCamera).moveX(-step);
        end
        
        function moveHorP(s)
            step = s.GUI.StepsizerevsEditField.Value;
            s.aList.(s.currentCamera).moveX(step);
        end
        
        function setExposure(s,expT)
            s.aList.(s.currentCamera).cam.setExposure(expT);
        end
    end
end

