function util_printLog2020(fig, varargin)
%PRINTLOG
%  PRINTLOG(FIG, OPTS) prints figure FIG to facility's logbook.

% Features:

% Input arguments:
%    FIG:  Handle of figure to print
%    OPTS: Options
%          TITLE:  Log entry title, default "Matlab"
%          TEXT:   Log entry text, default none
%          AUTHOR: Log entry author, default "Matlab"

% Output arguments:

% Compatibility: Version 7 and higher
% Called functions: util_parseOptions, getSystem, util_printLog_wComments

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Set default options.
optsdef=struct( ...
    'title','Matlab', ...
    'text','', ...
    'logType','physics', ...
    'author','Matlab' ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Check print queue syntax.
[sys,accel]=getSystem;
isQueue=isempty(varargin) || ~all(ismember(accel,{'LCLS' 'FACET' 'ASTA'}));
isQueue=isQueue || numel(varargin) == 2 && strcmp(varargin{1},'logType');
isQueue=isQueue || numel(varargin) == 1 && all(strcmp(fieldnames(varargin{1}),'logType'));

% Check if FIG is handle.
fig(~ishandle(fig))=[];

queue=['physics-' lower(accel) 'log'];
equeue=['elog_' lower(accel)];
elog=lower(accel);
if strcmp(accel,'NLCTA'), queue='physics-e163log';end
if strcmp(accel,'ASTA'), queue='physics-cathodelog';equeue='elog_asta_ent';end
if ismember(accel,{'ASTA' 'XTA'}), opts.logType='elog';isQueue=0;end % ASTA & XTA default to ELOG
if ismember(accel,{'LCLS' 'FACET'})
    opts.segment=accel;elog='mcc';equeue='elog_mcc';
end

if strcmp(opts.logType,'elog')
    queue=equeue;
    if ~isQueue
        util_eLogEntry(fig,[],elog,opts);
        return
    end
end

if ~isQueue && ~all(ismember(accel,'ASTA'));
    util_printLog_wComments(fig,opts.author,opts.title,opts.text,[500 375],0);
    return
end

for f=fig(:)'
    % Check if options used.
    %opts.fontName='Times';opts.fontSize=12;opts.lineWidth=1.5;
    %util_appFonts(f,opts);
    print(f,'-dpsc2',['-P' queue],'-bestfit');
    %hAxes=findobj(f,'type','axes');
    %opts.title=get(get(hAxes(1),'Title'),'String');
    %opts.title='Matlab Figure';
    %util_eLogEntry(f,now,'lcls',opts);
end
