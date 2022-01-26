function [pAct, iok] = control_phaseSet(name, pDes, trim, nTry, type, ds)
%PHASESET
%  [PACT, IOK] = PHASESET(NAME, PDES, TRIM, NTRY, TYPE, DS) sets the phase
%  of rf devices in string or cellarray NAME to PDES.

% Input arguments:
%    NAME: Name of klystron (MAD, Epics, or SLC), string or cell string
%          array
%    PDES: Desired phase
%    TRIM: Optional flag to disable trim (TRIM=0), default is trim enabled
%    NTRY: Optional number of checks for phase to settle, default 20 (SLC)
%          & 60(EPICS)
%    TYPE: Secondary to set (PDES, GOLD, KPHR), string or cell string array
%    DS:   Data Slot for PAU, default empty, i.e. set global parameters

% Output arguments:
%    PACT: Actual phase after setting
%    IOK : Flag for success, =0 if aida failed

% Compatibility: Version 2007b, 2012a
% Called functions: model_nameConvert, DaObject, aidaget, lcaPut,
%                   phaseNames

% Author: Henrik Loos, SLAC
% JAN, 2022 (Glen White): Updated to use AIDA-PVA for SCP channels

% --------------------------------------------------------------------
% Check input arguments

% Defaults
if nargin < 6, ds=[];end
if nargin < 5, type=[];end
if nargin < 4, nTry=[];end
if nargin < 3, trim=1;end
if isempty(type), type='PDES';end
if isempty(nTry), nTry=40;end

% Get EPICS name.
name=cellstr(name);name=name(:);
type=cellstr(type);type=type(:);
pDes=pDes(:);pAct=zeros(size(name));
iok=1;
if isempty(name), return, end

n=max(numel(name),numel(type));
name(end+1:n,1)=name(end);
type(end+1:n,1)=type(end);

noPDES=isempty(pDes);
if noPDES
  [pAct,pDes]=control_phaseGet(name);
  %else
  %    pDes=mod(pDes+180,360)-180; % Limit pDes between [-180, 180]
end
pDes(end+1:n,1)=pDes(end);pDes(n+1:end)=[];
pAct(end+1:n,1)=pAct(end);

if epicsSimul_status, ds=[];end
[name,is,namePACT,namePDES,nameGOLD,nameKPHR,d,d,d,d,namePOFF]=control_phaseNames(name,ds);

% Find GOLD devices.
isGold=strcmp(type,'GOLD');
namePDES(isGold)=nameGOLD(isGold);
type(strcmp(type,'PDES') & is.FPS)={'VDES'};
namePDES(is.SLC)=strcat(name(is.SLC),':',type(is.SLC));
namePDES(is.KLY)=strcat(name(is.KLY),':',type(is.KLY));

% Set PACT if simulation.
if epicsSimul_status
  if ~noPDES
    disp(char(strcat({'Set '},namePDES,{' to '},cellstr(num2str(pDes)))));
    lcaPut(namePDES,pDes);
    lcaPut(namePACT(~is.L23 & ~isGold),pDes(~is.L23 & ~isGold));
  end
  [pAct,d,d,d,kPhr]=control_phaseGet(name);
  if trim
    isTrim=is.SLC & strcmp(type,'PDES');
    lcaPut(nameKPHR(isTrim),kPhr(isTrim)-pAct(isTrim)+pDes(isTrim));
    pAct(isTrim)=pDes(isTrim);
  end
  dispPact(name,pAct);
  if trim || nTry
    %        dispPact(name,pAct);
  end
  return
end

% Use AIDA for SLC RF devices.
pTol=2; % Phase tolerance
if any(is.SLC)
  aidapva;
  
  pAct(is.SLC)=Inf;
  isBad=abs(pAct-pDes) > pTol & is.SLC;
  jTry=5;
  while any(isBad) && jTry
    disp_log(char(strcat({'Set '},name(isBad),':',type(isBad),{' to '},cellstr(num2str(pDes(isBad))))));
    if jTry < 5, pause(5.);end
    for j=find(isBad)'
      try
        builder = pvaRequest([model_nameConvert(name{j},'SLC') ':' type{j}]);
        if trim; builder.with('TRIM', 'YES'); end
        builder.set(pDes(j));
      catch e
        handleExceptions(e);
        disp_log(['Error in setting phase for ' name{j}]);
        iok=0;
      end
    end
    pAct(isBad)=phaseSettle(name(isBad),pDes(isBad),pTol,max(1,nTry*trim),pAct(isBad));
    isBad=abs(pAct-pDes) > pTol & is.SLC;
    jTry=jTry-1;
    if ~trim || ~nTry, isBad=isBad & 0;break, end
  end
  if any(isBad)
    disp_log(char(strcat({'Not tracking '},name(isBad),{' at '},cellstr(num2str(pAct(isBad))),{' waiting...'})));
    pause(10.);
    pAct(isBad)=control_phaseGet(name(isBad));
    disp_log(char(strcat({'Now '},name(isBad),{' at '},cellstr(num2str(pAct(isBad))))));
  end
  if trim && nTry || 1
    dispPact(name(is.SLC),pAct(is.SLC));
  end
end

% Return if all SLC.
if all(is.SLC), return, end

% Get PACT if PDES is empty and return.
if noPDES, return, end

% Set PDES in SLC for LEM
%for j=find(strncmp(name,'ACCL:LI24',9))'
%    in=DaValue(java.lang.Float(pDes(j)));
%    da.reset;
%    try
%        da.setParam('TRIM','NO');
%        da.setDaValue([model_nameConvert(name{j},'SLC') '//PDES'],in);
%    catch
%        disp(['Error in setting phase for ' name{j}]);
%        iok=0;
%    end
%end

% Do PAU
pDesMaster=pDes*0;strPAU='';
if ~isempty(ds)
  [d,d,d,namePDESmaster]=control_phaseNames(name(is.PAU));
  pDesMaster(is.PAU)=lcaGetSmart(namePDESmaster);
  namePDES(is.PAU)=namePOFF(is.PAU);
  strPAU=strcat({' - ('},cellstr(num2str(pDesMaster,'%7.2f')),')');
  strPAU(~is.PAU)={''};
end
pDesSet=pDes-pDesMaster;

% Set feedback gain to 1.
if any(is.FBK) && ~any(is.TCV) && ~any(is.LSN)
  namePSMOOTH=strcat(strtok(name(is.FBK),'_'),'_PSMOOTH');
  namePSMOOTH(is.New(is.FBK))=strcat(strtok(name(is.New(is.FBK)),'_'),':PSMOOTH');
  pSmooth=lcaGet(namePSMOOTH);
  if any(pSmooth >= 1)
    warndlg(strcat({'Original smooth factor for '},name(is.FBK),{' of '},cellstr(num2str(pSmooth,'%7.2f')),{' >= 1'}),'LARGE SMOOTH FACTOR');
  end
  lcaPut(namePSMOOTH,1);
end
if any(is.L2 & ~isGold & isempty(ds))
  nameL2Ref='LLRF:IN20:RH:L2_PDES';
  pL2=lcaGetSmart([{nameL2Ref};namePDES(find(is.L2 & ~isGold,1))]);
end
disp_log(char(strcat({'Set '},namePDES(~is.SLC),{' to '},cellstr(num2str(pDes(~is.SLC))),strPAU)));
lcaPutSmart(namePDES(~is.SLC),pDesSet(~is.SLC));

% Wait for phase to settle and reset feedback gain.
pTol=0.5; % Phase tolerance

if any(is.FBK) && ~any(is.LSN)
  pAct(is.FBK)=phaseSettle(name(is.FBK),pDes(is.FBK),pTol,nTry,[],ds);
  if ~any(is.TCV)
    lcaPut(namePSMOOTH,pSmooth);
  end
end
if any(is.L2 & ~isGold & isempty(ds))
  pause(.1);
  iTry=nTry;
  while abs(lcaGetSmart(nameL2Ref)-pDes(find(is.L2 & ~isGold,1))+diff(pL2)) > pTol && iTry
    pause(.1);
    iTry=iTry-1;
  end
end
if any(is.L3 & ~isGold)
  pause(.1);
  while lcaGetSmart('LLRF:IN20:RH:REF_2_CONVERGE'), pause(.1);end
end
if any(is.KLY)
  pTol=1;
  isPDES=strcmp(type,'PDES');
  isTrim=is.KLY & isPDES & trim;
  if any(isTrim), lcaPut(strcat(name(isTrim),':TRIMPHAS'),1);
  elseif ~all(is.SBS), pause(1.);end
  pAct(is.KLY)=phaseSettle(name(is.KLY),pDes(is.KLY),pTol,max(1,nTry*trim));
end

% Deal with new laser crap.
if any(is.LSN)
  pause(1);
  pAct(is.LSN)=control_phaseGet(name(is.LSN));
end

% Set PACT for no PAD devices and global L2/3 and new Laser
pAct(is.PAC | is.L23)=pDes(is.PAC | is.L23);
if nTry
  dispPact(name(~is.SLC),pAct(~is.SLC));
end


% --------------------------------------------------------------------
function [pAct, isBad] = phaseSettle(name, pDes, pTol, nTry, pAct, ds)

if nargin < 6, ds=[];end
if nargin < 5, pAct=[];end
if isempty(pAct), pAct=inf(size(name));end
iTry=nTry;
isBad=abs(pAct-pDes) > pTol;
while any(isBad) && iTry
  if iTry < nTry, pause(.2);end
  [pAct,pDes]=control_phaseGet(name,[],ds);
  isBad=abs(pAct-pDes) > pTol;
  iTry=iTry-1;
end


% --------------------------------------------------------------------
function dispPact(name, pAct)

[d,id]=unique(name);isUn=false(size(name));isUn(id)=true;
str=char(strcat({'Phase readback '},name(isUn),{' is '},cellstr(num2str(pAct(isUn),'%7.2f'))));
if ~epicsSimul_status, disp_log(str);else disp(str);end
