function [data,ts,ispv,remoffs,shift] = lcaGetSyncHST(pv, varargin)
% function [VAL,TS,ISPV,REMAININGOFFS,SHIFTAPPLD] = lcaGetSyncHST(PVNAME, [NMAX], [CODE])
%
%  Only works for PVs recorded in the history buffers. 
%
%  Wrapper for lcaGetSmart and internal function fixBufferOffsets.
%  Appends ['HST' CODE] to all PVs in the cell string array PVNAME, calls
%  lcaGetSmart(PVNAME, NMAX), then lines up data using function 
%  fixBufferOffsets.
%
%  Reminder: The most recent data is at the end of the buffer (point 2800).
%
%  Inputs:
%       PVNAME = String or cell array of strings with PV names to retrieve.
%       NMAX = (Default 2800) Maximum number of points to retrieve. Value
%              must be in the range [10 2800].  Actual number returned will
%              be reduced in the event data shifts are applied.
%       CODE = Optional string defining beam code:
%              'BR' = Beam rate (Default), '1H' = 1 Hz, 'TH' = 10 Hz
%              'CUHBR' = Cu to HXR beam rate, 'CUSTH' = Cu to SXR 10 Hz,
%              etc
%  Outputs:
%       VAL =  NPVS x NPTS array of synchronized data, NaN for failed
%              devices
%       TS  =  1 x NPTS array of synchronous (I think) complex timestamps
%              corresponding to events in DATA
%       REMAININGOFFS = Number of pulseIDs the code thinks a point is still
%                       off by. Either because it was off by a fraction of
%                       an event size or too large to shift.
%       SHIFTAPPLD = How many slots (not pulseIDs) the device's data was
%                    circshifted
%
%  There's still a finite (< 0.1%) chance a set of data will be messed up
%  due to a passing fiducial wrap or other random nonsense.

%  T. Maxwell, initial release 13 Jan 2016

% IMPORTANT NOTE: When using in a 32-bit environment, the environment
% variable EPICS_CA_MAX_ARRAY_BYTES (default 80M) needs to reduced to
% prevent memory errors during channel access. This must be done prior to
% launching the Matlab enviorment calling this function. From linux, use
% the command: export EPICS_CA_MAX_ARRAY_BYTES=80000

if isa(pv,'char');pv = {pv};end;
if size(pv,1) == 1;pv = pv.';end
% Include the time stamp IDs
[sys, ~] = getSystem();
pv = vertcat(pv,...
    {sprintf('PATT:%s:1:SEC', sys);...
    sprintf('PATT:%s:1:NSEC', sys)});
if nargin < 2;N = 2800;else N = min([max([10,varargin{1}]),2800]);end
if nargin < 3;code = 'BR';else code = varargin{2};end
% add suffix to retrieve last N points - JR 11/15/22
pv = strcat(pv,['HST' code], sprintf('.[-%d:]', N));
% Start by getting one point for each to test ISPV. Trying to get the
% buffer for non-existent PVs bogs things down.
[~,~,ispv] = lcaGetSmart(pv,1);
% Certain PVs don't play nice...
ign = explicitIgnore(pv);
ispv = logical(ispv.*~ign);
data = nan(length(pv),N);
ts = nan(1,length(ispv));
remoffs = ts;shift = ts;
% Deal out results.
[data(ispv,:),ts(ispv)] = lcaGetSmart(pv(ispv),N);
% Fix the offsets.
[data(ispv,:),~,remoffs(ispv),shift(ispv)] = fixBufferOffsets(data(ispv,:),ts(ispv),code);
% Make TS complex format
ts = data(end-1,:) + 1i*data(end,:) + 631152000;
% Clip extra points
N = find(isnan(ts),1,'first');
if isempty(N);N = size(data,2);end
ts(N:end) = [];
data(:,N:end) = [];
data((end-1):end,:) = []; % remove what we added
ispv((end-1):end) = [];
remoffs((end-1):end) = [];
shift((end-1):end) = [];

function [data,ts,remoffs,shifts] = fixBufferOffsets(data,ts,code)
% function [data,ts,remoffs,shifts] = fixBufferOffsets(data,ts,code)
%
%  For BSA history buffered retrievals of scalars using command format
%  [data,ts] = lcaGet({'[PVs]HST[BeamCode]',...},N)
%  the ts is the timestamp of the retrieval time, and indicates a pulseId
%  offset for each row in data. This command computes the necessary
%  offsets, then, if needed
%   1) Shifts each row of data the necessary amount, if the pulseId
%   difference is a multiple of three
%   2) Clips off data that does not overlap (length of returned data will
%   be changed)
%   3) Data that would require shifts larger than the data length are NOT
%   shifted and will have a large remoffs (see below)
%
%  REMOFFS is the REMaining pulseid OFFSet of the data from the median
%  value, after performing the above shifts, if any.
%
%  If any PV is shifted *not* by a multiple of three (example, free-running
%  device), it will be shifted to the nearest multiple of three BSA event and
%  flagged in the array 'remoffs' by the difference between the pulseID shift
%  applied and the actual pulseID offset.
%
%  If any PV would need to be shifted by more than the amount of data in
%  the data set, they are not moved, so remoffs will also be non-zero.
%
%   Example: A pulseID is +2 larger than the median pulseID. The data is
%   shifted by +3 pulseIDs (one event) and remoffs for this PV = +2 - +3 = -1.
%
%  SHIFTS is an array of the actuall event shifts applied to the data
%
%  T. Maxwell, 27 Feb 2015
if size(data,1) ~= length(ts)
    error('Number of columns in data not same as length of timestamp vector')
end
r = code(end-1:end);
switch r %sets the scale of expected one-event shifts later.
    case 'BR'
        mult = 3;
    case 'TH'
        mult = 30;
    case '1H'
        mult = 360;
    otherwise
        error('What rate code you doin''?!')
end
% Convert to pulseIDs.
pids = lcaTs2PulseId(ts);

% Find the typical pulse ID
mpid = median(pids);
% If all pulseIDs same, don't need to do anything
if ~any(~(pids == mpid))
    remoffs = zeros(size(ts));
    shifts = remoffs;
    return
end
[~,ind] = min(abs(pids-mpid));
% Adjust for fiducial roll-over (big deal for 1H and TH, sometimes BR)
pidoffs = double(unwrapPulseID(ts,ts(ind)));
pidoffs = pidoffs - round(median(double(pidoffs)));
% Compute one-event shifts
shifts = round(pidoffs/mult);
% Some "bad PVs" may require a shift larger than the data
% buffer. Flag them and any PV that's off by finite seconds.
thelim = 0.5*size(data,2)-2;
toignore = (abs(shifts) >= thelim);% | (abs(real(ts) - median(real(ts))) > 1);
% Don't do anything to those data
shifts(toignore) = 0;
% Remaining pulseID offsets:
remoffs = pidoffs - mult*shifts;
% Apply row-dependent shifts
fixme = 1:length(ts);
fixme(shifts == 0) = []; % skip sets that don't need shifting
for k = fixme
    data(k,:) = circshift(data(k,:),[0,shifts(k)]);
end
% Cut off data that no longer overlaps. Whether any set is shifted left or
% right, the same amount of data no longer overlaps on either end.
N = size(data,2);
biggest = max(abs(shifts(fixme)));
if isempty(biggest);biggest = 0;end
data(:, [1:(biggest), (end-biggest+1):end]) = [];
if biggest ~= 0;data = horzcat(data,nan(size(data,1),N-size(data,2)));end;
% Fix timestamps accordingly. 
% We cut trimmed also the unshifted data, so need those tweaked too.
ts = real(ts) + 1i*(median(imag(ts)) + remoffs - biggest);


function pulseId = lcaTs2PulseId(lcaTS)
% Internal version. In case using offline. Also I like doubles.
tsNsecs = imag(lcaTS);
pulseId = double(bitand(uint32(tsNsecs), hex2dec('1FFFF')));


function pIDoffset = unwrapPulseID(ts,ts0)
% function pIDoffset = unwrapPulseID(ts,ts0)
%
%  Input an array of complex timestamps (ts). Output is an array of pulse ID
%  offsets (pIDoffset) with respect to an optional reference timestamp
%  ts0 [= ts(1) by default]. These offsets are unwrapped with respect to
%  the 17-bit fiducial limit as (signed) int64's.
%
%  Note: Results *should* be pulse IDs that are all unique and
%  monotonically increasing with respect to time. Depending on beam/data
%  rate, may not be of constant spacing on the unwrapping points (if any).

%  T. Maxwell, 03-Mar-2015

%{
A word on fiducial wrapping: In general the LCLS fiducial increments by 3
for every 120 Hz shot. (Some preliminary data that show the beam rate data
randomly incrememnting by 168 several thousands of shots apart. Unclear
what the source was.)

As the fiducial is 17-bit limited, approximately every
2^17 IDs / wrap * 1 Pulse / 3 ID  * 1 second / 120 pulses = 
16384/45 seconds / wrap, the fiducial resets to zero. So given a
reference timestamp, we can compute what time stamps should have the
(artificially higher bit-rate) fiducial incremented/decremented by
multiples of 2^17 sufficient to unwrap the pulseID offset beyond 2^17.

At 120 Hz, a 2800 point data set has a 6.4% chance of seeing a fiducial
wrap. At 10 Hz, this increases to 77%. < ~7 Hz data are guaranteed
to see at least one fiducial wrap in every 2800-point data set.
%}
if isempty(ts);pIDoffset = [];return;end
if nargin < 2;ts0 = ts(1);end
%offsincr = int32(2^17); % fiducials between wraps
offsincr = int32(131040);
%offsdist = 16384/45*1e9; % nanoseconds between wraps
%offsdist = 364e9;
offsdist = 131042/360*1e9;
pid0 = int32(lcaTs2PulseId(ts0)); % reference fiducial
pid = int32(lcaTs2PulseId(ts)); % data fiducials
t0 = 1e9*real(ts0) + imag(ts0) - double(offsincr) * double(pid0); % reference time (ns)
t0d = double(pid0)*offsdist/double(offsincr); % offset of the reference time
t = 1e9*real(ts) + imag(ts)- double(offsincr) * double(pid); % data times (ns)
%td = double(pid)*offsdist/double(offsincr); % offset of the data times
Nwrap = int32(floor((t-t0+t0d)/offsdist)); % N times they're wrapped
pIDoffset = pid - pid0 + offsincr*Nwrap;

function these = explicitIgnore(pvs)
these = zeros(numel(pvs),1);
incl = {'BLD:SYS0:500:PCAV254'};
for k = 1:length(incl)
    a = strfind(pvs, incl{k});
    these(~cellfun(@isempty,a)) = 1;
end