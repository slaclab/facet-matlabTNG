function [ell, cross] = beamAnalysis_getEllipse(stats, scale, varargin)
%GETELLIPSE
%  GETELLIPSE(STATS, SCALE, OPTS) calculates and optionally plots beam
%  ellipse based on STATS.

% Features:

% Input arguments:
%    STATS: Stats as returned from beamParams
%    SCALE: Scale factor, default 1
%    OPTS: Options stucture with fields (optional):
%        FIGURE: Figure handle
%        AXES:   Axes handle
%        DOPLOT: Generate plot
%        TS:     Time stamp to plot (default now, preliminary feature)

% Output arguments:
%    ELL:   [x;y] coordinates of ellipse
%    CROSS: [x;y] coordinates of helf-axis cross

% Compatibility: Version 2007b, 2012a
% Called functions: parseOptions, util_plotInit

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Set default options.
optsdef=struct( ...
    'figure',2, ...
    'axes',[], ...
    'ts',now, ...
    'doPlot',0);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Get points to draw beam ellipse.
if nargin < 2, scale=[];end
if isempty(scale), scale=1;end

if size(stats,1) == 3
    if size(stats,2) == 1
        stats=[0 0 sqrt(stats([1 3])') stats(2) 0];
    else
        for j=1:size(stats,2)
            [ell(:,:,j),cross(:,:,j)]=beamAnalysis_getEllipse(stats(:,j),scale);
        end
        return
    end
end

% Calculate eigenvectors and ~values of transverse matrix.
stats(isnan(stats))=0;
xmean=stats(1);ymean=stats(2);xrms=stats(3);yrms=stats(4);xy=stats(5);
[v,lam]=eig(4*[xrms^2 xy;xy yrms^2]);ei=real(v*sqrt(lam));
phi=linspace(0,2*pi,1000);ell=ei*[cos(phi);sin(phi)];
ei2=reshape([1;-1;NaN]*ei([1 3 2 4]),[],2);

% Draw target cross and beam ellipse.
ell=[xmean+scale*ell(1,:);ymean+scale*ell(2,:)];
cross=[xmean+ei2(:,1) ymean+ei2(:,2)]';

% Setup figure and axes.
if ~opts.doPlot, return, end
hAxes=util_plotInit(opts);

plot(real(ell(1,:)),real(ell(2,:)),'b',real(cross(1,:)),real(cross(2,:)),'k','Parent',hAxes);
xlabel(hAxes,'x  (\mum)');
ylabel(hAxes,'y  (\mum)');
axis(hAxes,'equal');
lim0=cell2mat(get(hAxes,{'XLim' 'YLim'})');
lim=lim0*[1.05 -.05;-.05 1.05];
xlim(hAxes,lim(1,:));
ylim(hAxes,lim(2,:));

opts.units='\\mum';
stats(5)=stats(5)/prod(stats(3:4));
str=[strcat('x',{'mean' 'rms'},[' = %5.2f ' opts.units '\n']);
     strcat('y',{'mean' 'rms'},[' = %5.2f ' opts.units '\n'])];
%text(lim0(1,1),0.9*lim0(2,2),sprintf([str{:} 'corr = %5.2f ' '\nsum = %6.3f Mcts' '\n\n%s'], ...
%    stats.*[1 1 1 1 1 1e-6],datestr(opts.ts)),'Parent',hAxes,'VerticalAlignment','top');
drawnow;
