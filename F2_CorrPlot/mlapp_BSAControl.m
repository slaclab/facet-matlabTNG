function [acqStatus, status] = mlapp_BSAControl(mdl, bsaState, nPoints, beampath)
%GUI_BSACONTROL
%  GUI_BSACONTROL(HOBJECT, HANDLES, VAL, NUM) manages event definition for
%  GUI or other script.  

% Input arguments:
%    APP:       Matlab app object, holding data from the parent gui
%    NAME:      eDefName if desired CAN BE ADDED BUT IS NOT CURRENTLY IN
%    bsaState:  1 to reserve an eDef, 0 to remove
%    nPoints:   Buffer length for event definition
%    beampath:  CU or SC

% Compatibility: Matlab 2020a or higher
% Called functions: epicsSimul_status, eDefReserve, eDefParams,
%                   mlapp_statusDisp, eDefRelease

% Author: Henrik Loos, SLAC 
% Refurnished for Matlab 2020 by Jake Rudolph

% --------------------------------------------------------------------

% Quiet the eDef logging.
global eDefQuiet %#ok<NUSED>

if nargin < 4, beampath = 'CU'; end

% Check input arguments.
if nargin < 3 || isempty(nPoints)
    switch beampath
        case 'CU'
            nPoints = 2800; 
        case 'SC'
            nPoints = 20000;
    end
end

% This can be added if name is to be included
% % If handles isn't a struct, then what was passed at handles is an eDefName
% % string. Make handles a struct with field eDefName pointing to that string.
% returnapp = 0;
% if isempty(app)
%     returnapp = 1;
%     app=struct('eDefName',name);
% end

% If handles does not yet have an eDefName, make one from the name of the
% GUI
if isempty(mdl.eDefName)
    mdl.eDefName = [strrep(upper(mdl.appName),'_GUI','') '_' datestr(now,'HHMMSS_FFF')];
end

% If handles does not yet have a field eDefNumber, init the field to 0
if isempty(mdl.eDefNumber)
    mdl.eDefNumber = 0;
end

% If no bsaState sent, set bsaState to the acquireBSA flag
if isempty(bsaState)
    bsaState = mdl.acqOpt.BSA;
end
% If bsaState is sent, set the acquireBSA flag to bsaState
mdl.acqOpt.BSA = bsaState;

if ~epicsSimul_status
    % bsaState should either trigger an eDefReserve OR an eDefRelease
    if bsaState
        % Test if eDef name still valid.
        sys = getSystem;
        if strcmp(beampath(1:2), 'SC')
            lcaGetName = sprintf('BSA:%s:1:%d:NAME',sys,mdl.eDefNumber);
        else
            lcaGetName = sprintf('EDEF:%s:%d:NAME',sys,mdl.eDefNumber);
        end
        if mdl.eDefNumber && ~strcmp(mdl.eDefName,lcaGet(lcaGetName)) 
            mdl.eDefNumber = 0;
        end
        % Reserve eDef number if none assigned yet.
        if ~mdl.eDefNumber
            mdl.eDefNumber = eDefReserve(mdl.eDefName, beampath);
            eDefParams(mdl.eDefNumber, 1, nPoints, beampath);
        end
        % Disable BSA if no eDef number available.
        if ~mdl.eDefNumber
            mdl.status = 'No eDef available';
            notify(mdl, 'statusChanged');
            mlapp_BSAControl(mdl, 0);
            return
        end
    else
        % Release eDef.
        if mdl.eDefNumber
            eDefRelease(mdl.eDefNumber);
        end
        mdl.eDefNumber=0;
    end
end


% add in for case of taking in a name instead of an app
% if returnapp
%     varargout = app;
% end
end
