function varargout = errorbarh(varargin)
%ERRORBARH
%  ERRORBARH(X,Y,EX,[EY]) plots horizontal and optional vertical errorbars.
%  It takes the same optional parameters as ERRORBAR.

% Input arguments:
%    X: image array NxM, M horizontal, N vertical pixels

% Output arguments:
%    H: handle(s) to errorbarseries objects

% Compatibility: Version 7 and higher
% Called functions: 

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Test for 1st argument is axes object.
isax=0;if numel(varargin{1}) == 1 && ishandle(varargin{1}), isax=1;end

% Determine other parameters.
x=varargin{isax+1};
y=varargin{isax+2};
ex=varargin{isax+3};
isey=0;if numel(varargin) >= isax+4 && ~ischar(varargin{isax+4}), ey=varargin{isax+4};isey=1;end
ls={};if numel(varargin) >= isax+isey+4, ls=varargin(isax+isey+4:end);end

% Plot errorbar with x and y switched.
h=errorbar(varargin{1:isax},y,x,ex,ls{:});

% Reverse XData and YData in line objects.
hLine=get(h,'Children');if numel(h) > 1, hLine=vertcat(hLine{:});end
data=get(hLine,{'XData' 'YData'});
set(hLine,{'YData' 'XData'},data);

% Plot vertical errorbars.
if isey
    ax=get(h(1),'Parent');
    ax.ColorOrderIndex = 1; % JR 10/21/22 - align color to color index at start
    np=get(ax,'NextPlot');
    set(ax,'NextPlot','add');
    h = errorbar(ax,x,y,ey,ls{:}); 
    set(ax,'NextPlot',np);
end

% return errorbar object.
if nargout == 1, varargout{1}=h;end
