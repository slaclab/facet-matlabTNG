function [h] = util_errorBand(x, y, ystd, varargin)
%ERRORBAND
%  [H] = ERRORBAND(X, Y, YSTD, ...) plots lines and an errorband behind.

% Features: 

% Input arguments:
%    X: x-values
%    Y: y-values
%    YSTD: Width of error band to plot
%    VARARGIN: Optional arguments passed on to plot()

% Output arguments:
%    H: Handles to line objects created by plot

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Parse input parameters.

if size(y,1) ~= length(x), y=y';ystd=ystd';end
if size(x,1) ~= length(x), x=x';end
if size(x,2) ~= size(y,2), x=repmat(x,1,size(y,2));end

h1=plot(x,real(y),varargin{:});
col=get(h1,'Color');if iscell(col), col=vertcat(col{:});end
isblack=all(col == 0,2);col(isblack,:)=repmat([.5 .5 .5],sum(isblack),1);
hx=get(h1(1),'Parent');

use=~isnan(x) & ~isnan(y);
for j=1:size(y,2)
    us=use(:,j);
    patch([x(us,j);flipud(x(us,j))],real([y(us,j)+ystd(us,j);flipud(y(us,j)-ystd(us,j))]),...
        1-.25+.25*col(mod(j-1,size(col,1))+1,:),'EdgeColor','none','Parent',hx);
end

if ~isa(hx, 'matlab.ui.control.UIAxes')
    uistack(h1,'top');
end

if nargout, h=h1;end