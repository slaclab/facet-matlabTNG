function bAct = control_magnetSetC(name, val, varargin)
%CONTROL_CMAGNETSET
%  CONTROL_CMAGNETSET(NAME, VAL, OPTS) set magnet NAME:BDES to VAL and
%  perturbes. Returns the new BACT as VAL. Depending on OPTS, the magnet
%  can also be trimmed.

% Writes to BCON after setting magnet - other functionality same as control_magnetSet

% Features:

% Input arguments:
%    NAME: Base name of magnet PV.
%    VAL: New BDES value, not set if VAL is empty
%    OPTS: Options struct
%          ACTION: Control action for magnet, PERTURB or TRIM with default
%                  perturb
%          WAIT:   Additional wait time after magnet function completed,
%                  default 3s

% Output arguments:
%    BACT: New magnet BACT

% Compatibility: Version 2007b, 2012a
% Called functions: util_parseOptions, model_nameConvert,
%                   control_magnetNameLGPS, epicsSimul_status, lcaGet,
%                   lcaPut, lcaPutSmart, control_magnetGet,
%                   control_magnetQuadTrimSet, model_nameSplit,
%                   lcaGetStatus, aidainit

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Set default options.
optsdef=struct( ...
    'action','PERTURB', ...
    'wait',3 ...
    );
% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);
opts.action=upper(opts.action);
[name,d,isSLC]=model_nameConvert(cellstr(name),'EPICS');
name=name(:);val=val(:);bAct=zeros(size(name));
if ~isempty(val), val(end+1:numel(name),1)=val(end);end

% Do BNDS/QUAS stuff.
[nameLGPS,is]=control_magnetNameLGPS(name,isSLC);

% XTA.
isMcor=strncmp(name,'MCOR',4);
if ~isempty(val), val(isMcor)=val(isMcor)*0.579;end

% Set BACT if simulation.
if epicsSimul_status
    if strcmp(opts.action,'BCON_TO_BDES')
        val=lcaGet(strcat(name,':BCON'));
    end
    if ~isempty(val)
        lcaPut(strcat(name,':BACT'),val);
        lcaPut(strcat(name,':BDES'),val);
        lcaPut(strcat(name,':BCTRL'),val);
        if any(isMcor)
            lcaPut(strcat(name(isMcor),':IACT'),val(isMcor));
            lcaPut(strcat(name(isMcor),':ISETPT'),val(isMcor));
        end
        if any(is.Str), lcaPut(strcat(nameLGPS,':BDES'),val(is.Str));end
    end
    if strcmp(opts.action,'SAVE_BDES')
        val=lcaGet(strcat(name,':BDES'));
        if any(isMcor), val(isMcor)=lcaGet(strcat(name(isMcor),':ISETPT'));end
        lcaPut(strcat(name,':BCON'),val);
    end
    bAct=lcaGet(strcat(name,':BACT'));
    if any(isMcor), bAct(isMcor)=lcaGet(strcat(name(isMcor),':IACT'))/0.579;end
    return
end

% Do MCORs.
if any(isMcor) && ~isempty(val)
    lcaPutSmart(strcat(name(isMcor),':ISETPT'),val(isMcor));
    pause(opts.wait);
    bAct(isMcor)=lcaGet(strcat(name(isMcor),':IACT'))/0.579;
    return
end

% Get started with EPICS magnets.
if any(~isSLC)
    % Perturb or trim magnet.
    %lcaSetMonitor([name ':RAMPSTATE'],0,'double');
    %while ~lcaNewMonitorValue([name ':RAMPSTATE'],'double');end
    %state=lcaGet([name ':RAMPSTATE'],0,'double');
    %disp(state);

    % Set BDES if VAL is not empty.
    if ~isempty(val)
        lcaPut(strcat(name(~isSLC),':BDES'),val(~isSLC));
        lcaPut(strcat(name(~isSLC),':BCON'),val(~isSLC));
    end
    % Trim or perturb magnets.
    nameCTRL=strcat(name(~isSLC),':CTRL');

    % Don't use magnets in No or Feedback Control.
    nameOnline=strcat(name(~isSLC),':STATMSG');
    use=~ismember(lcaGet(nameOnline,0,'double'),[15 7 2]);

    % Do BCON to BDES action.
    if ismember(opts.action,{'BCON_TO_BDES' 'LOAD_BDES'}) && any(use)
        lcaPut(nameCTRL(use),opts.action);
        pause(.5);
        opts.action='TRIM';
    end
 
    if ismember(opts.action,{'TRIM' 'PERTURB' 'SAVE_BDES' 'DAC_ZERO' 'STDZ' ...
            'TURN_ON' 'TURN_OFF' 'DEGAUSS'}) && any(use)
        good(use)=lcaPutSmart(nameCTRL(use),opts.action);good(~use)=1;
        if any(~good)
            disp(['Magnet ' opts.action ' action failed for:']);
            disp(strrep(nameCTRL(~good),':CTRL',''));
        end
    end
    disp(['Set EPICS magnet BDES and ' opts.action ' magnet']);
    pause(.1);
end

% Do SLC magnets in the mean time.
if any(isSLC)
    nameSLC=model_nameConvert(name(isSLC),'SLC');
    isColl=strncmp(nameSLC,'STEP',4) | strncmp(nameSLC,'AMPL',4);
    if isempty(val)
        [d,bDes]=control_magnetGet(name(isSLC));
    else
        bDes=val(isSLC);
    end
    [bDes,nameSLCQ,isQTRM]=control_magnetQuadTrimSet(nameSLC,bDes);
    nameSLCQ=model_nameConvert(nameSLCQ,'SLC');
    if any(is.Str)
        [m,p,u]=model_nameSplit(nameLGPS);
        nameLGPS=strcat(p,':',m,':',u);
        nameSLCQ(is.Str(isSLC))=nameLGPS;
    end
    func='TRIM'; %do always trim, perturb sucks!
    if any(strncmp(nameSLC,'AMPL',4)), func='PTRB'; end; %perturb for NLCTA

    %if strcmp(opts.action,'PERTURB'), func='PTRB';end
    disp('Wait for SLC magnet trim ...');
    bActSLC(~isColl)=magnetSet(nameSLCQ(~isColl),bDes(~isColl),'BDES',func);
    bActSLC(~isColl)=magnetSet(nameSLCQ(~isColl),bDes(~isColl),'BCON',func);
    bActSLC(isColl)=magnetSet(nameSLCQ(isColl),bDes(isColl),'VDES',func);
    bActSLC(isQTRM)=control_magnetGet(nameSLC(isQTRM));
    if strcmp(func,'PTRB')
        pause(15.);bActSLC=NaN;
    end
    if any(isnan(bActSLC)), bActSLC=control_magnetGet(name(isSLC));end
    bAct(isSLC)=bActSLC;
end

% Return if all SLC magnets.
if all(isSLC), return, end

% Finish EPICS magnets.
disp([datestr(now) ' Wait for EPICS ' opts.action ' ...']);
switch opts.action
    case 'PERTURB'
        % Wait for RAMPSTATE to turn ON
%        while ~lcaNewMonitorValue([name ':RAMPSTATE'],'double');end
%        state=lcaGet([name ':RAMPSTATE'],0,'double');
%        disp(state);
    case 'TRIM'
        nTry=120;
        magnetWait(nameCTRL(use),nTry,.5);
%        while ~lcaNewMonitorValue([name ':RAMPSTATE'],'double');end
%        state=lcaGet([name ':RAMPSTATE'],0,'double');
%        disp(state);
    case 'STDZ'
        nTry=900;
        magnetWait(nameCTRL(use),nTry,1);
    case 'DEGAUSS'
        nTry=600;
        magnetWait(nameCTRL(use),nTry,1);
    case {'DAC_ZERO' 'TURN_ON' 'TURN_OFF'}
        pause(3.); % Needs extra wait
    case 'SAVE_BDES'
    otherwise
        disp([datestr(now) ' Unknown action for magnet']);
end

nTry=0;
while nTry
    state=lcaGetStatus(strcat(name(~isSLC),':BACT')) > 1;
    nTry=nTry-1;
    if ~any(state), break, end
    pause(.1);
end
if any(use), pause(opts.wait);end

% Wait for RAMPSTATE to turn OFF
%if state
%    while ~lcaNewMonitorValue([name ':RAMPSTATE'],'double');end
%    state=lcaGet([name ':RAMPSTATE'],0,'double');
%    disp(state);
%end
%lcaClear([name ':RAMPSTATE']);

% Return if no output argument.
disp([datestr(now) ' Magnet set done.']);
if ~nargout, return, end

% Read back BACT.
bAct(~isSLC)=lcaGet(strcat(name(~isSLC),':BACT'));


% --------------------------------------------------------------------
function val = magnetWait(nameCTRL, nTry, wait)

if isempty(nameCTRL), return, end
while nTry
    state=lcaGet(nameCTRL,0,'double') > 0;
    nTry=nTry-1;
    if ~any(state), break, end
    pause(wait);
end
val=nTry > 0;
if ~val
    str=sprintf('%s ',nameCTRL{state});
    disp([datestr(now) ' Magnet function timed out for ' str]);
end


% --------------------------------------------------------------------
function val = magnetSet(name, val, secn, func)

% Initialize aida
%global da in

aidainit;
   import edu.stanford.slac.aida.lib.da.DaObject;
   import edu.stanford.slac.err.*;
   import edu.stanford.slac.aida.lib.da.*;
   import edu.stanford.slac.aida.lib.util.common.*;
   da=DaObject;
   in=DaValue;

if isempty(name), val=[];return, end
in.type=0;
in.addElement(DaValue(name));
%in.addElement(DaValue(java.lang.Float(val))); % Kludge to make Aida format conversion work.
in.addElement(DaValue(single(val))); % Kludge to make Aida format conversion work.
da.reset;
da.setParam('MAGFUNC',func);
da.setParam('LIMITCHECK','SOME');
val=[];
try
    out=da.setDaValue(['MAGNETSET//' secn],in);
    val=getAsDoubles(out.get(1));
catch
    fprintf('Aida error trimming %s ... %s',name{unique([1 end])});
    pause(1);
    try
      out=da.setDaValue(['MAGNETSET//' secn],in);
      val=getAsDoubles(out.get(1));
    catch
      fprintf('Aida error trimming a second time, aborting %s ... %s',name{unique([1 end])});
    end
end
