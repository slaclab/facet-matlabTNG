function [imgcrop,roiAxesVals] = setImgROI(img,nSig)
    opts = struct('usemethod',2);% Asymmetric Gaussian
    beamParams = beamAnalysis_beamParams(img, 1:size(img,2), 1:size(img,1),0,opts);
    x_com = beamParams.stats(1);y_com = beamParams.stats(2);
    xrms = beamParams.stats(3);yrms = beamParams.stats(4);
    sigma = max(xrms,yrms);  
    cdims = [y_com-nSig*sigma<0,y_com+nSig*sigma>size(img,1),x_com-nSig*sigma<0,x_com+nSig*sigma>size(img,2)];
    Ddims = round([y_com-nSig*sigma,y_com+nSig*sigma,x_com-nSig*sigma,x_com+nSig*sigma]);
    % This makes sure your indices are not outside image range   
    try
    if ~any(logical(cdims))
    imgcrop = img(Ddims(1):Ddims(2),Ddims(3):Ddims(4));    
        else
             for jk = 1:4
             if mod(jk,2);cropDim(jk) = max(1,Ddims(jk));else;cropDim(jk) = min(size(img,jk/2),Ddims(jk));end
             end        
         imgcrop = img(cropDim(1):cropDim(2),cropDim(3):cropDim(4));
    end
    catch
        warning(['Could not crop image on',UserData.cameraNames{jj}]);
        imgcrop = img;
    end
    % roiAxesVals gives a square ROI of +/- 4* largest sigma
    roiAxesVals = [min(x_com-nSig*xrms,y_com-nSig*yrms)-round(size(img,2)/2),...
        max(x_com+nSig*xrms,y_com+nSig*yrms)-round(size(img,2)/2),...
        min(x_com-nSig*xrms,y_com-nSig*yrms)-round(size(img,1)/2),...
        max(x_com+nSig*xrms,y_com+nSig*yrms)];%xmin,xmax,ymin,ymax
end