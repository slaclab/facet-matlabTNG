function im_out = fftRoi(x, roi)
% allows you to put an ROI on an fft of the image
    if nargin == 1
        [Ny, Nx] = size(x);
        roi = [1, Ny, 1, Nx];
    end
    
    temp = abs(fftshift(fft2(x)));
    im_out = temp(roi(1):roi(2), roi(3):roi(4));

end