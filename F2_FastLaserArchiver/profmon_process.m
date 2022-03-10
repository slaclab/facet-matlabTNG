function beam = profmon_process(data, varargin)
%PROFMON_PROCESS
%  PROFMON_PROCESS() processes image data and slices.

% Features:

% Input arguments:
%    DATA: Image data struct array returned from profmon_grab or
%          profmon_series
%    OPTS: Options struct
%          NSLICE: Number of slices, default is 10
%          SLICEDIR: Slicing direction, default is 'x'
%          SLICEWIN: Half width of slicing area in units of projected beam
%                    size, default is 5
%          DOPLOT: Show processing results, default 1

% Output arguments:
%    BEAM: results from image processing and profile analysis
%          (see beamAnalysis_beamParams)

% Compatibility: Version 2007b, 2012a
% Called functions: beamAnalysis_imgProc,beamAnalysis_beamParams,
%                   beamAnalysis_imgPlot

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Set default options.
optsdef=struct( ...
    'nSlice',0, ...
    'sliceDir','x', ...
    'sliceWin',3, ...
    'doPlot',1, ...
    'method',1, ...
    'usemethod',[], ...
    'useCal',1, ...
    'useTime',0, ...
    'useEner',0, ...
    'crop',1, ...
    'median',0, ...
    'hsig',1.5, ...
    'xsig',4.6, ...
    'ysig',4.6, ...
    'cut',.05, ...
    'saves', 0, ...
    'back',1,...
    'iSlice',[]);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);
if ~isempty(opts.usemethod), opts.method=1;end

popts=struct( ...
    'figure',1, ...
    'full',0, ...
    'units','Pixel', ...
    'xlim',[], ...
    'ylim',[], ...
    'title',data.name);

[img,xsub,ysub,flag,bgs]=beamAnalysis_imgProc(data,opts);
bin=[data.roiYN data.roiXN]./size(data.img);
xsub=xsub*bin(2);ysub=ysub*bin(1);
pos.x=data.roiX+xsub;
pos.y=data.roiY+ysub;
if opts.useCal
    popts.units='um';
    pos=profmon_coordTrans(pos,data);
    if opts.useTime && isfield(data,'tcavCal')
        pos.y=pos.y/data.tcavCal;
        popts.unitsY='Degree';
    end
    if opts.useEner && isfield(data,'enerCal')
        pos.x=pos.x*data.enerCal(1)/data.res(1);
        popts.unitsY=popts.units;
        popts.units='eV';
    end
end
beam=beamAnalysis_beamParams(img,pos.x,pos.y,bgs,opts);

if opts.doPlot 
    if isempty(opts.iSlice) || (opts.iSlice == 0)
        if opts.saves ==1
        else
            beamAnalysis_imgPlot(beam(opts.method),img,data,popts);
        end
    end
end


if ~opts.nSlice, return, end

lim=beam(1).stats([1 3;2 4]);

for j=1:opts.nSlice
    if ~isempty(opts.iSlice) && (opts.iSlice ~= 0)
        j = opts.iSlice;
    elseif (opts.iSlice == 0)
        return
    end
    xsub=1:length(pos.x);
    ysub=1:length(pos.y);
    range=lim(:,[1 1])+lim(:,2)*opts.sliceWin*(2*[j-1 j]-opts.nSlice)/opts.nSlice;
    switch opts.sliceDir
        case 'x'
            xsub=pos.x < range(1,2) & pos.x >= range(1,1);
        case 'y'
            ysub=pos.y < range(2,2) & pos.y >= range(2,1);
    end
    if numel(find(xsub)) > 1 && numel(find(ysub)) > 1
        beam(j+1,:)=beamAnalysis_beamParams(img(ysub,xsub),pos.x(xsub),pos.y(ysub),bgs,opts);
    else
        beam(j+1,:)=beam(1,:);
    end
    if opts.doPlot
        beamAnalysis_imgPlot(beam(j+1,opts.method),img(ysub,xsub),data,popts);
    end
    if ~isempty(opts.iSlice) && (opts.iSlice ~= 0)
        return
    end
end
