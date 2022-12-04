classdef F2_WirescanApp < handle
  %F2_WIRESCANAPP FACET-II wirescanner control and data processing
  properties(Transient)
    AbortScan logical = false % Set true to trigger abort of in-progress scan
    UpdateObj % Object to notify of updated data
    UpdateMethod(1,2) string % Method to call when data is updated [first is called with ProcData method, second with wiresel or plane property changes]
    UpdatePar(1,2) cell % Parameter to pass to method being called [first is called with ProcData method, second with wiresel or plane property changes]
  end
  properties(SetObservable=true,AbortSet)
    plane string {mustBeMember(plane,["x","y","u"])} = "x" % Selected measurement plane
    motor_range(1,2) = [-inf,inf] % Range over which to scan wires in motor reference frame [m]
    wiresel uint8 = 1
    pmtsel uint8 = 1
    torsel uint8 = 1
    blmsel uint8 = 1
    bpmsel(1,2) uint8 = [1 2]
    npulses uint16 = 100
    jittercor logical = false % Do jitter correction using BPMs?
    fitmethod string {mustBeMember(fitmethod,["gauss","agauss","agauss2"])} = "agauss"
    blenvals(1,2) = [-inf,inf] % Window values for bunch length measurements
    blenwin logical = false % Window cut on blen measurements?
    chargenorm logical = false % Do charge normalization using PMT?
    WireDiam = 60 % um
  end
  properties(SetAccess=private)
    data
    fitdata
    scansuccess logical = false
    scanstatus string
    initstate logical = true
  end
  properties(SetAccess=private,Transient,Hidden)
    LLM % Lucretia Live model storage
    guihan
    edef % Reserved BSA event code
  end
  properties(Dependent)
    npulselim(1,2) uint16 % Min/Max # pulses
    bpms % Available BPMs for jitter correction (depends on wire selection)
    modelbpms % Model names for BPMs
    wirename % Controls name for selected wire
    toroname % Controls name for selected Toroid
    motor_speed % m/s
    motlims(1,2) % Lower and upper motor positions for wires
    poslims(1,2) % Lower and upper motor positions for wires in accelertor frame
    curpos % Current wire position
    scan_angle % physics scan angle of wire card / deg
    npulserange(1,2) uint16 % range of possible npulse settings
    pos_range(1,2) % motor_range in accelerator x/y/u reference frame
    pmtname % Control name of selected PMT
    blmname % Control name of slected bunch length monitor
  end
  properties(Constant)
    usejit logical = [1 0 0 0 0 0 0 0 0 1 1] % Can use jitter correction for wires?
    aidabpms logical = [0          1         1           1          1          1         1          1            1          0           0     ]
    wires string = ["IN10:561" "LI11:444" "LI11:614" "LI11:744" "LI12:214" "LI18:944" "LI19:144" "LI19:244" "LI19:344" "LI20:3179" "LI20:3206"]
    wiremodel string = ["WS10561" "WS11444" "WS11614" "WS11744" "WS12214" "WS18944" "WS19144" "WS19244" "WS19344" "IPWS1" "IPWS3"]
    pmts string = ["IN10:561" "LI11:444" "LI11:614" "LI11:744" "LI12:214" "LI18:944" "LI19:144" "LI19:244" "LI19:344" "LI20:3060" "LI20:3070" "LI20:3179" "LI20:3350" "LI20:3360"]
%     pmts string = ["IN10:561" "LI11:444" "LI11:614" "LI11:744" "LI12:214" "LI18:944" "LI19:144" "LI19:244" "LI19:344"]
    tors string = ["IN10:591" "LI11:360" "LI14:890" "LI20:1988" "LI20:2040" "LI20:2452" "LI20:3163" "LI20:3255"]
%     tors string = ["IN10:591" "LI11:360" "LI14:890"]
    blms string = ["LI11:359" "LI14:888" "LI20:3014"]
    BeamRatePV string = "EVNT:SYS1:1:INJECTRATE"
  end
  methods
    function obj = F2_WirescanApp(LLM,iwire,dim)
      %F2_WIRESCANAPP
      %F2_WirescanApp([LucretiaLiveModel,WireSel,plane])
      
      warning('off','MATLAB:rankDeficientMatrix');
      
      % Use provided Lucretia Live Model, or generate new one
      if exist('LLM','var') && ~isempty(LLM)
        obj.LLM = LLM ;
      else
        obj.LLM = F2_LiveModelApp ;
      end
      if exist('dim','var') && ~isempty(dim)
        obj.plane=dim;
      end
      if exist('iwire','var') && ~isempty(iwire)
        obj.wiresel=iwire;
      end
      obj.initstate = false ;
      obj.confload;
    end
    function LoadData(obj,data,fitdata)
      obj.data=data; obj.fitdata=fitdata;
    end
    function AttachGUI(obj,ghan)
      obj.guihan=ghan;
      obj.guihan.WIREDropDown.Items = obj.wires ;
      obj.guihan.WIREDropDown.Value = obj.wires(obj.wiresel) ;
      obj.guihan.(upper(obj.plane)+"Button").Value = 1 ;
      obj.guihan.plane = obj.plane ;
      obj.guihan.PMTDropDown.Items = obj.pmts ;
      obj.guihan.TORODropDown.Items = obj.tors ;
      obj.guihan.BLENDropDown.Items = obj.blms ;
      obj.guiupdate ;
    end
    function ResetData(obj)
      obj.data=[];
      obj.scansuccess=false;
      if ~isempty(obj.guihan)
        obj.guihan.ScanWidth.Value=0;
        obj.guihan.ScanCenter.Value=0;
        obj.guihan.ScanWidthError.Value=0;
        obj.guihan.ScanCenterError.Value=0;
      end
    end
    function StartScan(obj,ahan)
      %STARTSCAN Start wire scan process
      global BEAMLINE
      obj.AbortScan = false ;
      obj.scansuccess = false ;
      
      if ~exist('ahan','var')
        ahan = obj.guihan.UIAxes ;
      end
      
      % Reserve Edef
      obj.edef = eDefReserve('F2_Wirescan') ;
      if ~obj.edef
        error('No EDEF slot available');
      end
      
      % Write scan data to PVs
      lcaPut(char(obj.wirename+":"+upper(obj.plane)+"WIREINNER"),obj.motor_range(1)*1e6);
      lcaPut(char(obj.wirename+":"+upper(obj.plane)+"WIREOUTER"),obj.motor_range(2)*1e6);
      lcaPut(char(obj.wirename+":SCANPULSES"),double(obj.npulses));
      planes=["x" "y" "u"];
      for iplane=1:3
        if obj.plane==planes(iplane)
          lcaPut(char(obj.wirename+":USE"+upper(planes(iplane))+"WIRE"),1);
        else
          lcaPut(char(obj.wirename+":USE"+upper(planes(iplane))+"WIRE"),0);
        end
      end
      
      % Setup for shared ADC PLIC signals
      switch obj.wirename
        % For shared ADC 11:100
        case 'WIRE:IN10:561'
        	gatewidth = lcaGet('SIOC:SYS1:ML01:AO801');
            lcaPutSmart('QADC:LI11:100:TDES',3620);
            lcaPutSmart('QADC:LI11:100:TWID',gatewidth);
        case 'WIRE:LI11:444'
        	gatewidth = lcaGet('SIOC:SYS1:ML01:AO802');
            lcaPutSmart('QADC:LI11:100:TDES',3620);
            lcaPutSmart('QADC:LI11:100:TWID',gatewidth);
        case 'WIRE:LI11:614'
        	gatewidth = lcaGet('SIOC:SYS1:ML01:AO803');
            lcaPutSmart('QADC:LI11:100:TDES',3750);
            lcaPutSmart('QADC:LI11:100:TWID',gatewidth);
        case 'WIRE:LI11:744'
        	gatewidth = lcaGet('SIOC:SYS1:ML01:AO804');
            lcaPutSmart('QADC:LI11:100:TDES',3700); %for PMT614
            %lcaPutSmart('QADC:LI11:100:TDES',4320); %for PMT444
            lcaPutSmart('QADC:LI11:100:TWID',gatewidth);
        case 'WIRE:LI12:214'
        	gatewidth = lcaGet('SIOC:SYS1:ML01:AO805');
            lcaPutSmart('QADC:LI11:100:TDES',4230);
            lcaPutSmart('QADC:LI11:100:TWID',gatewidth);
        % For shared ADC 19:100
        case 'WIRE:LI18:944'
        	gatewidth = lcaGet('SIOC:SYS1:ML01:AO806');
            lcaPutSmart('QADC:LI19:100:TDES',2070);
            lcaPutSmart('QADC:LI19:100:TWID',gatewidth);
        case 'WIRE:LI19:144'
        	gatewidth = lcaGet('SIOC:SYS1:ML01:AO807');
            lcaPutSmart('QADC:LI19:100:TDES',1900);
            lcaPutSmart('QADC:LI19:100:TWID',gatewidth);
        case 'WIRE:LI19:244'
        	gatewidth = lcaGet('SIOC:SYS1:ML01:AO808');
            lcaPutSmart('QADC:LI19:100:TDES',2050);
            lcaPutSmart('QADC:LI19:100:TWID',gatewidth);
        case 'WIRE:LI19:344'
        	gatewidth = lcaGet('SIOC:SYS1:ML01:AO809');
            lcaPutSmart('QADC:LI19:100:TDES',2250);
            lcaPutSmart('QADC:LI19:100:TWID',gatewidth);
      end
      
      beamrate = lcaGet(char(obj.BeamRatePV)) ;
      scanWireBufferNum=double(floor(min(obj.npulses*1.5+beamrate*6,2800)));
      wirecmd=char(obj.wirename+":STARTSCAN");
      progress=char(obj.wirename+":SCANPROGRESS");
      success=char(obj.wirename+":HADSUCCESS");
      
      % Start BSA data taking
      % - sync lvdt
      lcaPut(char(obj.wirename+":MOTR.STOP"),1);
      pause(2);
      lvdt=lcaGet(char(obj.wirename+":LVPOS"));
      if lvdt < lcaGet(char(obj.wirename+":MOTR.HLM"))
        lcaPut(char(obj.wirename+":MOTR.SET"),1);
        lcaPut(char(obj.wirename+":MOTR"),lvdt);
        lcaPut(char(obj.wirename+":MOTR.SET"),0);pause(.5);
      end
      eDefParams(obj.edef,1,scanWireBufferNum);
      eDefOn(obj.edef);
      
      % Start wire scan
      lcaPutNoWait(wirecmd,1);
      
      % If there AIDA BPMs, get buffered data whilst scan is happening
      mstruct=[];
      if obj.aidabpms(obj.wiresel)
        aidapva;
        builder = pvaRequest('FACET-II:BUFFACQ');
        builder.with('BPMD', 57);
        builder.with('NRPOS', double(scanWireBufferNum));
        builder.timeout(180);
        builder.with('BPMS', cellstr(obj.bpms(obj.bpmsel))) ;
        try 
          abuilder = builder.asyncGet() ;
        catch
          fprintf(2,'Failed to get AIDA BPMs, probably asking for too many pulses, try reducing pulses or increasing beam rate\n');
          mstruct = [];
        end
      end
      
      % Monitor scan progress
      obj.data=[];
      while string(cell2mat(lcaGet(wirecmd)))=="Scanning"
        % Process Abort Scan request
        if obj.AbortScan
          lcaPutNoWait(wirecmd,0);
          obj.AbortScan=false;
          obj.scansuccess=false;
          eDefRelease(obj.edef);
          obj.ProcData;
          obj.guiupdate;
        end
        pause(0.1);
        if ~isempty(ahan) % Display progress on axes
          prog=lcaGet(progress);
          cla(ahan); reset(ahan); axis(ahan,'off');
          rectangle(ahan,'Position',[0,0.4,prog/100,0.2],'facecolor','g');axis(ahan,[0 1 0 1]);
          title(ahan,sprintf('%s: Scan Progress...',obj.wirename));
          text(ahan,max([0 prog/100-0.1]),0.5,sprintf('%.1f %%',prog));
          drawnow
        end
      end
      cla(ahan); reset(ahan);
      eDefOff(obj.edef);
      
      % Flag success of scan
      obj.scanstatus=string(lcaGet(success));
      if obj.scanstatus == "Scan Successful"
        obj.scansuccess=true;
      else
        obj.scansuccess=false;
      end
      
      % Move wire to closest limit to leave out of beam
%       [~,ii]=min(abs(obj.curpos-obj.motlims));
%       obj.curpos = obj.motlims(ii) ;
      
      % Get BSA data
      if obj.scansuccess
        % - Wait for AIDA BPM buffered data if needed 
        if obj.aidabpms(obj.wiresel)
          while ~abuilder.isReady()
            pause(0.2);
          end
          mstruct =  ML(abuilder.getResponse()) ;
        end
        pidpv=sprintf('PATT:SYS1:1:PULSEIDHST%d',obj.edef);
        obj.data.pid=lcaGet(pidpv,scanWireBufferNum);
        obj.data.pos=lcaGet(char(obj.wirename+":POSNHST"+obj.edef),scanWireBufferNum).*1e-6;
        obj.data.pmt=lcaGet(cellstr("PMT:"+obj.pmts(:)+":QDCRAWHST"+obj.edef),scanWireBufferNum) ;
        obj.data.toro = lcaGet(cellstr("TORO:"+obj.tors(:)+":TMITHST"+obj.edef),scanWireBufferNum) ;
        if ~isempty(obj.bpms)
          if obj.aidabpms(obj.wiresel) && ~isempty(mstruct) % align bpm data with pulse IDs
            nameid1 = ismember( string(mstruct.values.name) , obj.bpms(obj.bpmsel(1)) ) ;
            nameid2 = ismember( string(mstruct.values.name) , obj.bpms(obj.bpmsel(2)) ) ;
            id1 = mstruct.values.pulseId(nameid1) ; id2 = mstruct.values.pulseId(nameid2) ;
            x1 = mstruct.values.x(nameid1)*1e-3 ; x2 = mstruct.values.x(nameid2)*1e-3 ;
            y1 = mstruct.values.y(nameid1)*1e-3 ; y2 = mstruct.values.y(nameid2)*1e-3 ;
            [pidmatch1,pid1] = ismember(id1,obj.data.pid) ;
            [pidmatch2,pid2] = ismember(id2,obj.data.pid) ;
            obj.data.xbpm1 = zeros(1,scanWireBufferNum) ;
            obj.data.xbpm2 = obj.data.xbpm1;
            obj.data.ybpm1 = obj.data.xbpm1 ;
            obj.data.ybpm2 = obj.data.xbpm2 ;
            if sum(pidmatch1) < obj.npulses || sum(pidmatch2) < obj.npulses
              fprintf(2,'No overlap found between AIDA BPMs and wirescanner data\n');
            else
              obj.data.xbpm1(pid1(pid1>0)) = x1(pidmatch1) ;
              obj.data.xbpm2(pid2(pid2>0)) = x2(pidmatch2) ;
              obj.data.ybpm1(pid1(pid1>0)) = y1(pidmatch1) ;
              obj.data.ybpm2(pid2(pid2>0)) = y2(pidmatch2) ;
            end
          elseif obj.aidabpms(obj.wiresel) % failed to get AIDA BPMs
            obj.data.xbpm1 = zeros(size(obj.data.toro)) ;
            obj.data.xbpm2 = obj.data.xbpm1;
            obj.data.ybpm1 = obj.data.xbpm1 ;
            obj.data.ybpm2 = obj.data.xbpm2 ;
          else % EPICS buffered BPM data
            obj.data.xbpm1 = lcaGet(char(obj.bpms(obj.bpmsel(1))+":XHST"+obj.edef),scanWireBufferNum).*1e-3 ;
            obj.data.xbpm2 = lcaGet(char(obj.bpms(obj.bpmsel(2))+":XHST"+obj.edef),scanWireBufferNum).*1e-3 ;
            obj.data.ybpm1 = lcaGet(char(obj.bpms(obj.bpmsel(1))+":YHST"+obj.edef),scanWireBufferNum).*1e-3 ;
            obj.data.ybpm2 = lcaGet(char(obj.bpms(obj.bpmsel(2))+":YHST"+obj.edef),scanWireBufferNum).*1e-3 ;
          end
          % Convert to position at wire
          obj.LLM.UpdateModel ;
          mname=obj.modelbpms;
          i1=findcells(BEAMLINE,'Name',char(mname(obj.bpmsel(1))));
          i2=findcells(BEAMLINE,'Name',char(mname(obj.bpmsel(2))));
          iwire=findcells(BEAMLINE,'Name',char(obj.wiremodel(obj.wiresel)));
          if isempty(i1) || isempty(i2) || isempty(iwire)
            error('Elements not found in model')
          end
          [~,R]=RmatAtoB(i1,i2); [~,Rw]=RmatAtoB(i1,iwire);
          switch obj.plane
            case "x"
              x0 = obj.data.xbpm1 ;
              xp0 = ( obj.data.xbpm2 - R(1,1)*x0 ) ./ R(1,2) ;
              if iwire>i1
                xw = Rw(1:2,1:2) * [x0(:)';xp0(:)'] ;
              else
                xw = Rw(1:2,1:2) \ [x0(:)';xp0(:)'] ;
              end
              xw=xw(1,:);
            case "y"
              x0 = obj.data.ybpm1 ;
              xp0 = ( obj.data.ybpm2 - R(3,3)*x0 ) ./ R(3,4) ;
              if iwire>i1
                xw = Rw(3:4,3:4) * [x0(:)';xp0(:)'] ;
              else
                xw = Rw(3:4,3:4) \ [x0(:)';xp0(:)'] ;
              end
              xw=xw(1,:);
            case "u"
              x0 = obj.data.xbpm1 ;
              xp0 = ( obj.data.xbpm2 - R(1,1)*x0 ) ./ R(1,2) ;
              if iwire>i1
                xw = Rw(1:2,1:2) * [x0(:)';xp0(:)'] ;
              else
                xw = Rw(1:2,1:2) \ [x0(:)';xp0(:)'] ;
              end
              xw=xw(1,:);
              y0 = obj.data.ybpm1 ;
              yp0 = ( obj.data.ybpm2 - R(3,3)*y0 ) ./ R(3,4) ;
              if iwire>i1
                yw = Rw(3:4,3:4) * [y0(:)';yp0(:)'] ;
              else
                yw = Rw(3:4,3:4) \ [y0(:)';yp0(:)'] ;
              end
              yw=yw(1,:);
              xw = sqrt(2)/2 .* (xw -yw) ;
          end
          obj.data.bpmpos = xw ;
        end
      end
      
      % Release Edef
      eDefRelease(obj.edef);
      
      % Process and save data
      obj.ProcData(ahan);
      obj.guiupdate;
      obj.confsave;
      F2C=F2_common;
      obj.confsave(fullfile(F2C.datadir,"F2_Wirescan_"+datestr(now,30)+".mat"));
      
    end
    function ProcData(obj,ahan,NoUpdateCall)
      %PROCDATA
      %ProcData([AxesHandle])
      
      if ~obj.scansuccess
        return
      end
      if ~exist('ahan','var') || isempty(ahan)
        if ~isempty(obj.guihan)
          ahan=obj.guihan.UIAxes;
          cla(ahan); reset(ahan);
        else
          ahan=[];
        end
      end
      if ~exist('NoUpdateCall','var')
        NoUpdateCall=[];
      end
      
      switch obj.plane
        case "x"
          pos = obj.data.pos .* sind(obj.scan_angle) ;
        case "y"
          pos = obj.data.pos .* cosd(obj.scan_angle) ;
        case "u"
          pos = obj.data.pos ;
      end
      
      try
        ydat = obj.data.pmt(obj.pmtsel,:) ;
        qdat = obj.data.toro(obj.torsel,:) ;
      catch
        ydat = obj.data.pmt ;
        qdat = obj.data.toro ;
      end
      bad = isnan(ydat) | isinf(ydat) | ydat==0 | pos==0 | pos<(obj.pos_range(1)+5e-6) | pos>(obj.pos_range(2)-5e-6) | isnan(pos) ;
      
      % Apply BPM measured position correction?
      if obj.jittercor
        bad = bad | isnan(obj.data.bpmpos) | obj.data.bpmpos==0 | isinf(obj.data.bpmpos) ;
        pos = pos(~bad) + (obj.data.bpmpos(~bad)-mean(obj.data.bpmpos(~bad))) ;
      else
        pos = pos(~bad) ;
      end
      if all(bad)
        error('No good data');
      end
      ydat=ydat(~bad); qdat=qdat(~bad);
      
      Q=mean(qdat)*physConsts.eQ;
      if obj.chargenorm
        ydat=ydat.*qdat ;
      end
      ydat=ydat./sum(ydat).*Q.*1e9;
      dy=ones(size(ydat)).*max(ydat)./100;
      
      xx = linspace(min(pos),max(pos),1000);
%       if ~isempty(obj.guihan) && string(obj.guihan.UnitsDropDown.Value)=="Motor"
%         xx_pl=linspace(min(pos),max(pos),1000);
%       else
        xx_pl=xx;
%       end
      
      [pos,ii]=sort(pos); ydat=ydat(ii); dy=dy(ii);

      switch obj.fitmethod
        case "gauss"
          [~,q,dq,chi2]=gauss_fit(pos,ydat,dy); q(5)=0;
        case "agauss"
          [~,q,dq,chi2]=agauss_fit(pos,ydat,dy);
        case "agauss2"
          [par, yFit, parstd, ~, chi2] = util_gaussFit(pos, ydat, 1, '1', dy, xx_pl); % [AMP, XM, SIG, BG, BGS]
          q(1) = par(4); q(2) = par(1); q(3)=par(2); q(4)=par(3);
          dq(1) = parstd(4); dq(2) = parstd(1); dq(3)=parstd(2); dq(4)=parstd(3);
      end
      dy=dy.*sqrt(chi2);
      switch obj.fitmethod
        case "gauss"
          [~,q,dq]=gauss_fit(pos,ydat,dy); q(5)=0;
        case "agauss"
          [~,q,dq]=agauss_fit(pos,ydat,dy);
        case "agauss2"
          [par, yFit, parstd] = util_gaussFit(pos, ydat, 1, '1', dy, xx_pl); % [AMP, XM, SIG, BG, BGS]
          q(1) = par(4); q(2) = par(1); q(3)=par(2); q(4)=par(3);
          dq(1) = parstd(4); dq(2) = parstd(1); dq(3)=parstd(2); dq(4)=parstd(3);
      end
      sigma = abs(q(4))*1e6; sigmaErr = abs(dq(4))*1e6;
      if sigma<(obj.WireDiam/4)
        sigma=0;
      else
        sigma = sqrt(sigma.^2 - (obj.WireDiam/4).^2) ;
      end
      center = q(3)*1e6; centerErr = dq(3)*1e6 ;
      obj.fitdata.sigma=sigma; obj.fitdata.sigmaErr=sigmaErr;
      obj.fitdata.center=center; obj.fitdata.centerErr = centerErr ;
      lcaPut(char(obj.wirename+":"+upper(obj.plane)+"RMS"),sigma);
      lcaPut(char(obj.wirename+":"+upper(obj.plane)),center);
      if obj.wirename == "WIRE:LI20:3179"
        if obj.plane=="x"
          lcaPut('SIOC:SYS1:ML01:AO149',sigmaErr);
        elseif obj.plane=="y"
          lcaPut('SIOC:SYS1:ML01:AO150',sigmaErr);
        end
      end
      
      if ~isempty(ahan)
%         if ~isempty(obj.guihan) && string(obj.guihan.UnitsDropDown.Value)=="Motor"
%           pos=obj.data.pos(~bad);
%         end
        plot(ahan,pos.*1e6,ydat,'*');
        if obj.fitmethod == "agauss2"
          yy = yFit ;
        else
          yy = q(1)+q(2).*exp(-0.5.*((xx-q(3))./(q(4).*(1+sign(xx-q(3)).*q(5)))).^2) ;
        end
        
        hold(ahan,'on');
        plot(ahan,xx_pl.*1e6,yy,'r');
        hold(ahan,'off');
        grid(ahan,'on');
        ax=axis(ahan);ax(1:2)=[xx_pl(1) xx_pl(end)].*1e6;axis(ahan,ax);
        xlabel(ahan,upper(obj.plane)+" [\mum]"); ylabel(ahan,'Q [nC]');
        if ~isempty(obj.guihan)
          obj.guihan.ScanWidth.Value = sigma ; obj.guihan.ScanWidthError.Value = sigmaErr ;
          obj.guihan.ScanCenter.Value = center ; obj.guihan.ScanCenterError.Value = centerErr ;
        end
      end
      
      % Call upstream app to let it know data is updated
      if ~isempty(obj.UpdateObj) && isempty(NoUpdateCall)
        obj.UpdateObj.(obj.UpdateMethod(1))(obj.UpdatePar{1});
      end
      
    end
    function confload(obj,fname)
      %CONFLOAD
      %confload([file_name])
      if ~exist('fname','var')
        fname = F2_common.confdir + "/F2_Wirescan/" + obj.wirename + "_" + obj.plane + ".mat" ;
      end
      if ~exist(fname,'file')
        warning('No config file, using default settings...');
        obj.npulses = lcaGet(char(obj.wirename+":SCANPULSES")) ;
        obj.data=[];
        obj.confsave;
        return
      end
      try
        ld=load(fname);
      catch
        delete(fname);
        obj.confload;
        return
      end
      lpar = ["pmtsel" "jittercor" "chargenorm" "blenwin" "bpmsel" "torsel" "blmsel" "fitmethod" "data" "scansuccess" "blenvals" "WireDiam"] ;
      for ipar=1:length(lpar)
        if isfield(ld,lpar(ipar))
          try
            obj.(lpar(ipar)) = ld.(lpar(ipar)) ;
          catch
            fprintf(2,sprintf("No entry for parameter %s, using default value",lpar(ipar)));
          end
        end
      end
      if isempty(ld.data)
        obj.scansuccess=false;
      else
        obj.scansuccess=true;
      end
      try
        obj.ProcData;
      catch
        warning('Incompatible data');
      end
    end
    function confsave(obj,fname)
      %CONFSAVE
      %confsave([filename])
      % Only save if scan successful and data present
      if ~obj.scansuccess || isempty(obj.data)
        return
      end
      if ~exist('fname','file')
        fname = F2_common.confdir + "/F2_Wirescan/" + obj.wirename + "_" + obj.plane + ".mat" ;
      end
      lpar = ["pmtsel" "jittercor" "chargenorm" "blenwin" "bpmsel" "torsel" "blmsel" "fitmethod" "data" "motor_range" "npulses" "scansuccess" "blenvals" "fitdata" "WireDiam"] ;
      for ipar=1:length(lpar)
        ss.(lpar(ipar))=obj.(lpar(ipar));
      end
      save(fname,'-struct','ss');
    end
    function guiupdate(obj)
      if ~isempty(obj.guihan)
        obj.guihan.WIREDropDown.Value = obj.wires(obj.wiresel) ;
        obj.guihan.PMTDropDown.Value = obj.pmts(obj.pmtsel) ;
        obj.guihan.JitterCorrectionCheckBox.Value = obj.jittercor ;
        switch obj.plane
          case "x"
            obj.guihan.XButton.Value=1;
            obj.guihan.YButton.Value=0;
            obj.guihan.UButton.Value=0;
          case "y"
            obj.guihan.XButton.Value=0;
            obj.guihan.YButton.Value=1;
            obj.guihan.UButton.Value=0;
          case "u"
            obj.guihan.XButton.Value=0;
            obj.guihan.YButton.Value=0;
            obj.guihan.UButton.Value=1;
        end
        if isempty(obj.bpms)
          obj.guihan.BPM1DropDown.Items = "---" ;
          obj.guihan.BPM1DropDown.Value = "---" ;
          obj.guihan.BPM2DropDown.Items = "---" ;
          obj.guihan.BPM2DropDown.Value = "---" ;
        else
          obj.guihan.BPM1DropDown.Items = regexprep(obj.bpms,"^BPMS:","") ;
          obj.guihan.BPM2DropDown.Items = regexprep(obj.bpms,"^BPMS:","") ;
          obj.guihan.BPM1DropDown.Value = regexprep(obj.bpms(obj.bpmsel(1)),"^BPMS:","") ;
          obj.guihan.BPM2DropDown.Value = regexprep(obj.bpms(obj.bpmsel(2)),"^BPMS:","") ;
        end
        obj.guihan.ChargeNormalizationCheckBox.Value = obj.chargenorm ;
        obj.guihan.TORODropDown.Value = obj.tors(obj.torsel) ;
        obj.guihan.BunchLengthWindowingCheckBox.Value = obj.blenwin ;
        obj.guihan.EditField_3.Value = obj.blenvals(1) ;
        obj.guihan.EditField_4.Value = obj.blenvals(2) ;
        obj.guihan.BLENDropDown.Value = obj.blms(obj.blmsel) ;
        switch obj.fitmethod
          case "agauss"
            obj.guihan.FitMethodDropDown.Value = "Asymm Gaussian" ;
          case "agauss2"
            obj.guihan.FitMethodDropDown.Value = "Asymm Gaussian (2)" ;
          case "gauss"
            obj.guihan.FitMethodDropDown.Value = "Gaussian" ;
        end
        if string(obj.guihan.UnitsDropDown.Value) == "Position"
          l1=min([obj.poslims(1) obj.pos_range(1)])*1e6; l2=max([obj.poslims(2) obj.pos_range(2)])*1e6;
          obj.guihan.EditField.Limits =  [l1 l2] ;
          obj.guihan.EditField_2.Limits = [l1 l2] ;
          obj.guihan.EditField.Value = ceil(obj.pos_range(1)*1e6) ;
          obj.guihan.EditField_2.Value = floor(obj.pos_range(2)*1e6) ;
        else
          l1=min([obj.motlims(1) obj.motor_range(1)])*1e6; l2 = max([obj.motlims(2) obj.motor_range(2)])*1e6 ;
          obj.guihan.EditField.Limits = [l1 l2] ;
          obj.guihan.EditField_2.Limits = [l1 l2] ;
          obj.guihan.EditField.Value = ceil(obj.motor_range(1)*1e6) ;
          obj.guihan.EditField_2.Value = floor(obj.motor_range(2)*1e6) ;
        end
        obj.guihan.PulsesEditField.Value=double(obj.npulses);
        if obj.scansuccess
          obj.guihan.ScanSuccessLamp.Color = 'g' ;
        else
          obj.guihan.ScanSuccessLamp.Color = 'r' ;
        end
        obj.guihan.PulsesEditField.Limits = double(obj.npulselim) ;
        drawnow;
      end
    end
  end
  methods % get/set methods
    function set.blmname(obj,name)
      name=regexprep(name,"^BLEN:","");
      bsel = find(obj.blms,name);
      if isempty(bsel)
        error("BLEN name not found");
      end
      obj.blmsel = bsel ;
    end
    function name = get.blmname(obj)
      name = obj.blms(obj.blmsel) ;
    end
    function lims = get.npulselim(obj)
      beamrate = lcaGet(char(obj.BeamRatePV)) ; if beamrate<1; beamrate=1; end
      speedMax = lcaGet(char(obj.wirename+":MOTR.VMAX"))*1e-6 ;
      speedMin = lcaGet(char(obj.wirename+":MOTR.VBAS"))*1e-6 ;
      lims = [ceil(range(obj.motor_range) / speedMax * beamrate), floor(range(obj.motor_range) / speedMin * beamrate)];
    end
    function set.pmtname(obj,name)
      name=regexprep(name,"^PMT:","");
      psel = find(obj.pmts==name);
      if isempty(psel)
        error('PMT name not found');
      end
      obj.pmtsel = psel ;
    end
    function name = get.pmtname(obj)
      name = "PMT:"+obj.pmts(obj.pmtsel) ;
    end
    function set.plane(obj,pl)
      if obj.initstate
        obj.plane=pl;
        return
      end
      fprintf('Set plane %c -> %c...\n',obj.plane,pl);
      % Call upstream app to let it know data is updated
      if ~isempty(obj.UpdateObj)
        obj.UpdateObj.(obj.UpdateMethod(2))(obj.UpdatePar{2});
      end
      obj.plane=pl;
      obj.confload;
    end
    function pos = get.pos_range(obj)
      switch obj.plane
        case "x"
          pos = obj.motor_range .* sind(obj.scan_angle) ;
        case "y"
          pos = obj.motor_range .* cosd(obj.scan_angle) ;
        case "u"
          pos = obj.motor_range ;
      end
      pos=sort(pos);
    end
    function set.pos_range(obj,ran)
      switch obj.plane
        case "x"
          ran = ran ./ sind(obj.scan_angle) ;
        case "y"
          ran = ran ./ cosd(obj.scan_angle) ;
      end
      obj.motor_range=sort(ran);
    end
    function np = get.npulses(obj)
      np = lcaGet(char(obj.wirename+":SCANPULSES")) ;
    end
    function set.npulses(obj,np)
      beamrate = lcaGet(char(obj.BeamRatePV)) ;
      speed = range(obj.motor_range) / double(np) * beamrate ;
      speedMax = lcaGet(char(obj.wirename+":MOTR.VMAX"))*1e-6 ;
      speedMin = lcaGet(char(obj.wirename+":MOTR.VBAS"))*1e-6 ;
      if speed > speedMax
        warning('Request # pulses requires too great motor speed, setting to fastest possible');
        obj.npulses = ceil(range(obj.motor_range) / (speedMax * beamrate)) ;
        return
      end
      if speed < speedMin
         warning('Request # pulses requires too small motor speed, setting to slowest possible');
        obj.npulses = floor(range(obj.motor_range) / (speedMin * beamrate)) ;
        return
      end
      lcaPut(char(obj.wirename+":SCANPULSES"),double(np))
      obj.npulses=np;
      obj.confsave;
    end
    function npran = get.npulserange(obj)
      speedMax = lcaGet(char(obj.wirename+":MOTR.VMAX"))*1e-6 ;
      speedMin = lcaGet(char(obj.wirename+":MOTR.VBAS"))*1e-6 ;
      npran = uint16([ceil(range(obj.motor_range) / (speedMax * beamrate)) floor(range(obj.motor_range) / (speedMin * beamrate))]) ;
    end
    function set.motor_range(obj,ran)
      lims=obj.motlims;
      if length(ran)~=2 || ran(1)<lims(1) || ran(2)>lims(2)
        warning('Invalid range settings (outside limits), using existing range');
        switch obj.plane
          case "x"
            ran = [lcaGet(char(obj.wirename+":XWIREINNER"))  lcaGet(char(obj.wirename+":XWIREOUTER"))] ;
          case "y"
            ran = [lcaGet(char(obj.wirename+":YWIREINNER"))  lcaGet(char(obj.wirename+":YWIREOUTER"))] ;
          case "u"
            ran = [lcaGet(char(obj.wirename+":UWIREINNER"))  lcaGet(char(obj.wirename+":UWIREOUTER"))] ;
        end
        ran=ran.*1e-6;
      end
      obj.motor_range=ran;
      ran=ran*1e6;
      switch obj.plane
        case "x"
          lcaPut(char(obj.wirename+":XWIREINNER"),ran(1)); lcaPut(char(obj.wirename+":XWIREOUTER"),ran(2)) ;
        case "y"
          lcaPut(char(obj.wirename+":YWIREINNER"),ran(1)); lcaPut(char(obj.wirename+":YWIREOUTER"),ran(2)) ;
        case "u"
          lcaPut(char(obj.wirename+":UWIREINNER"),ran(1)); lcaPut(char(obj.wirename+":UWIREOUTER"),ran(2)) ;
      end
      obj.confsave;
    end
    function ran = get.motor_range(obj)
      switch obj.plane
        case "x"
          ran = [lcaGet(char(obj.wirename+":XWIREINNER"))  lcaGet(char(obj.wirename+":XWIREOUTER"))] ;
        case "y"
          ran = [lcaGet(char(obj.wirename+":YWIREINNER"))  lcaGet(char(obj.wirename+":YWIREOUTER"))] ;
        case "u"
          ran = [lcaGet(char(obj.wirename+":UWIREINNER"))  lcaGet(char(obj.wirename+":UWIREOUTER"))] ;
      end
      ran=ran.*1e-6;
    end
    function ang = get.scan_angle(obj)
      ang = lcaGet(char(obj.wirename+":INSTALLANGLE")) ;
    end
    function pos = get.curpos(obj)
      pos = lcaGet(char(obj.wirename+":MOTR"))*1e-6 ;
    end
    function set.curpos(obj,pos)
      lcaPut(char(obj.wirename+":MOTR"),pos) ;
    end
    function lims = get.motlims(obj)
      lims = [lcaGet(char(obj.wirename+":MOTR.LLM"))-10 lcaGet(char(obj.wirename+":MOTR.HLM"))+10].*1e-6 ;
    end
    function lims = get.poslims(obj)
      lims = [lcaGet(char(obj.wirename+":MOTR.LLM")) lcaGet(char(obj.wirename+":MOTR.HLM"))].*1e-6 ;
       switch obj.plane % case for "u" assumes in same plane as motor card movement
        case "x"
          lims = sort(lims .* sind(obj.scan_angle)) ;
        case "y"
          lims = sort(lims .* cosd(obj.scan_angle)) ;
      end
    end
    function bpms = get.bpms(obj)
      bpms=[];
      switch obj.wirename
        case "WIRE:LI20:3179"
          bpms = ["BPMS:LI20:3156" "BPMS:LI20:3218" "BPMS:LI20:3265" "BPMS:LI20:3315"] ;
        case "WIRE:LI20:3206"
          bpms = ["BPMS:LI20:3156" "BPMS:LI20:3218" "BPMS:LI20:3265" "BPMS:LI20:3315"] ;
        case "WIRE:IN10:561"
          bpms = ["BPMS:IN10:425" "BPMS:IN10:525" "BPMS:IN10:581" "BPMS:IN10:631"] ;
        case "WIRE:LI11:444"
          bpms = ["BPMS:LI11:401" "BPMS:LI11:501" "BPMS:LI11:601" "BPMS:LI11:701"] ;
        case "WIRE:LI11:614"
          bpms = ["BPMS:LI11:501" "BPMS:LI11:601" "BPMS:LI11:701" "BPMS:LI11:801"] ;
        case "WIRE:LI11:744"
          bpms = ["BPMS:LI11:601" "BPMS:LI11:701" "BPMS:LI11:801" "BPMS:LI11:901"] ;
        case "WIRE:LI12:214"
          bpms = ["BPMS:LI11:901" "BPMS:LI12:201" "BPMS:LI12:301" "BPMS:LI12:401"] ;
        case "WIRE:LI18:944"
          bpms = ["BPMS:LI18:801" "BPMS:LI18:901" "BPMS:LI19:201" "BPMS:LI19:301"] ;
        case "WIRE:LI19:144"
          bpms = ["BPMS:LI18:801" "BPMS:LI18:901" "BPMS:LI19:201" "BPMS:LI19:301"] ;
        case "WIRE:LI19:244"
          bpms = ["BPMS:LI18:901" "BPMS:LI19:201" "BPMS:LI19:301" "BPMS:LI19:401"] ;
        case "WIRE:LI19:344"
          bpms = ["BPMS:LI19:201" "BPMS:LI19:301" "BPMS:LI19:401" "BPMS:LI19:501"] ;
      end
    end
    function bpms = get.modelbpms(obj)
      bpms=[];
      switch obj.wirename
        case "WIRE:LI20:3179"
          bpms = ["M5FF" "M0EX" "M1EX" "M2EX"] ;
        case "WIRE:LI20:3206"
          bpms = ["M5FF" "M0EX" "M1EX" "M2EX"] ;
        case "WIRE:IN10:561"
          bpms = ["BPM10425" "BPM10525" "BPM10581" "BPM10631"] ;
        case "WIRE:LI11:444"
          bpms = ["BPM11401" "BPM11501" "BPM11601" "BPM11701"] ;
        case "WIRE:LI11:614"
          bpms = ["BPM11501" "BPM11601" "BPM11701" "BPM11801"] ;
        case "WIRE:LI11:744"
          bpms = ["BPM11601" "BPM11701" "BPM11801" "BPM11901"] ;
        case "WIRE:LI12:214"
          bpms = ["BPM11901" "BPM12201" "BPM12301" "BPM12401"] ;
        case "WIRE:LI18:944"
          bpms = ["BPM18801" "BPM18901" "BPM19201" "BPM19301"] ;
        case "WIRE:LI19:144"
          bpms = ["BPM18801" "BPM18901" "BPM19201" "BPM19301"] ;
        case "WIRE:LI19:244"
          bpms = ["BPM18901" "BPM19201" "BPM19301" "BPM19401"] ;
        case "WIRE:LI19:344"
          bpms = ["BPM19201" "BPM19301" "BPM19401" "BPM19501"] ;
      end
    end
    function speed = get.motor_speed(obj)
      beamrate = lcaGet(char(obj.BeamRatePV)) ;
      speed = range(obj.motor_range) / double(obj.npulses) * beamrate ;
    end
    function name = get.toroname(obj)
      name = "TORO:"+obj.tors(obj.torsel) ;
    end
    function set.toroname(obj,name)
      name=regexprep(name,"^TORO:","");
      tsel = find(obj.tors==name);
      if isempty(tsel)
        error('TORO name not found');
      end
      obj.torsel = tsel ;
    end
    function name = get.wirename(obj)
      name = "WIRE:" + obj.wires(obj.wiresel) ;
    end
    function set.wirename(obj,name)
      name=regexprep(name,"^WIRE:","");
      wsel=find(obj.wires==name);
      if isempty(wsel)
        error('Wire name not found');
      end
      obj.wiresel=wsel;
    end
    function set.jittercor(obj,sel)
%       if sel && ~obj.usejit(obj.wiresel)
%         obj.jittercor=false;
%         warning('Unable to process orbit jitter for %s',obj.wirename);
%       else
        obj.jittercor=sel;
%       end
      obj.confsave;
    end
    function set.wiresel(obj,sel)
      if sel<1 || sel>length(obj.wires)
        error('No corresponding wire to selection')
      end
      if obj.initstate
        obj.wiresel = sel ;
        return
      end
      % Call upstream app to let it know data is updated
      if ~isempty(obj.UpdateObj)
        obj.UpdateObj.(obj.UpdateMethod(2))(obj.UpdatePar{2});
      end
      obj.wiresel = sel ;
      obj.confload;
    end
    function set.pmtsel(obj,sel)
      if sel<1 || sel>length(obj.pmts)
        error('No corresponding PMT to selection')
      end
      obj.pmtsel=sel;
      obj.confsave;
    end
    function set.torsel(obj,sel)
      if sel<1 || sel>length(obj.tors)
        error('No corresponding TORO to selection')
      end
      obj.torsel=sel;
      obj.confsave;
    end
    function set.blmsel(obj,sel)
      if sel<1 || sel>length(obj.blms)
        error('No corresponding BLM to selection')
      end
      obj.blmsel=sel;
      obj.confsave;
    end
    function set.fitmethod(obj,method)
      obj.fitmethod=method;
      obj.confsave;
      obj.ProcData;
    end
    function set.blenvals(obj,vals)
      obj.blenvals=vals;
      obj.confsave;
    end
    function set.blenwin(obj,win)
      obj.blenwin=win;
      obj.confsave;
    end
    function set.chargenorm(obj,docn)
      obj.chargenorm=docn;
      obj.confsave;
    end
    function set.WireDiam(obj,diam)
      obj.WireDiam=diam;
      obj.confsave;
      obj.ProcData;
    end
  end
end