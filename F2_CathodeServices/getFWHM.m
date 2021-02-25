function [FWHM_x,FWHM_y] = getFWHM(img,xdata,ydata,xmid,ymid,xsize,ysize)
%FETFWHM Return full-width, half-max widths for x and y projections of img

xproj=sum(img,1);
xsel=xdata>xmid-xsize*6 & xdata<xmid+xsize*6;
yproj=sum(img,2);
ysel=ydata>ymid-ysize*6 & ydata<ymid+ysize*6;
FWHM_x = fwhm(xdata(xsel),xproj(xsel));
FWHM_y = fwhm(ydata(ysel),yproj(ysel));