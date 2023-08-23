function [img, x, y, res, xmm, ymm] = read_img(data_struct,GUI, header, cam, n, isrot)

% [img, x, y, res, xmm, ymm] = read_img(data_struct, header, cam, n, doplot, isrot)
% 
% data_struct and header come from findDAQ function
% cam is camera name, i.e. LFOV, DTOTR2, etc
% n is index from dataset
% doplot = 1 plots the image
% isrot = 1 rotates the image. Use trial and error. Could be written in as a if loop


%image data
comIndImg  = data_struct.images.(cam).common_index;
comIndScal = data_struct.scalars.common_index;
imgmeta = data_struct.metadata.(cam);
imgloc = data_struct.images.(cam).loc;

res = imgmeta.RESOLUTION;


indImg  = comIndImg(n);
indScal = comIndScal(n);

    % Load the image
    imgloc = data_struct.images.(cam).loc{indImg};
    startIdx = regexp(imgloc,'[a-zA-Z0-9]{4}_\d{5}');
    fileloc = [header imgloc(startIdx+10:end)];
    
    
    disp(fileloc);
    
    img = uint16(imread(fileloc));

    % Do the background subtraction, if background image exists
    if data_struct.backgrounds.getBG==1
        bkgd = uint16(data_struct.backgrounds.(cam));
        
        if size(bkgd,1)==size(img,1)
            img = img - bkgd;
        elseif size(bkgd,2)==size(img,1)
            img = img - bkgd';
        else
            warning('Bkgd image size not the same dimensions as image file');
        end
    end

    % Get ROI details
    minXROI = imgmeta.MinY_RBV;
    maxXROI = minXROI+imgmeta.ROI_SizeY_RBV-1;
    x = minXROI:maxXROI;
    minYROI = imgmeta.MinX_RBV;
    maxYROI = minYROI+imgmeta.ROI_SizeX_RBV-1;
    y = minYROI:maxYROI;
    
    % rotate image if required
    if isrot
        img = img';
        xold = x;
        x = y;
        y = xold;
    end
    xmm = x*res*1e-3;  ymm = y*res*1e-3;
    % the orientation should now be image(xpixel, ypixel), and use imagesc(x,y,img)

    %check orientations
    if strcmp(imgmeta.X_ORIENT, 'Negative')
        img = flipud(img);
    end
    if strcmp(imgmeta.Y_ORIENT, 'Negative')
        img = fliplr(img);
    end

        
    

end