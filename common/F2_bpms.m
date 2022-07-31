classdef F2_bpms < handle & matlab.mixin.Copyable
  %F2_BPMS Read BPM orbit data from EPICS or use buffered BPM acquisition from EPICS+SCP
  events
    PVUpdated
  end
  properties
    plotscale uint8 = 0 % 0 = auto, else +/- mm scale
    dim string {mustBeMember(dim,["x","y","xy"])} = "xy" % Get new data for x, y or x & y (for read method only, readbuffer always gets x & y)
    tmitcut % If set, require tmit>tmitcut else position fields set to nan for that pulse (and omitted from ave and rms stats)
  end
  properties(SetAccess=private)
    xdat % [nbpm x nread] mm
    ydat % [nbpm x nread] mm
    tmit % [nbpm x nread] 1E9
    pulseid = 1 % vector of pulse ID's, length = nread (for readbuffer) or buffer location id (for read)
    nread uint16
    LM
    nepicsbuffer = 1.5 % get N times more EPICS data than AIDA to account for delay in getting AIDA data (for buffered acq)
    bpmnames string % control names of BPMs read
    modelnames string % corresponding model names
    modelZ % corresponding Z locations
    modelID % corresponding BEAMLINE indices
    epicsnames string % corresponding epics names
    stuckbpms logical % non-updating bpms list
    UpdateTimer
  end
  properties(Dependent)
    beamrate uint8 % Active beam rate [Hz]
    xave
    yave
    xrms
    yrms
    tmitave
    tmitrms
  end
  properties(SetObservable,AbortSet)
    UseRegion(1,11) logical = true(1,11) % ["INJ";"L0";"DL1";"L1";"BC11";"L2";"BC14";"L3";"BC20";"FFS";"SPECTDUMP"]
    BufferLen uint16 = 10 % Length of xdat/ydat buffer to use with read method (ignored for readbuffer)
  end
  properties(SetObservable)
    autoupdate logical = false % (updates notify PVUpdated event) : works for read method only (not readbuffer)
  end
  properties(Constant)
    badbpms string = ["BPM10781" "BPM19851"] % model names of BPMS with missing controls or known bad (excludes from master lists)
    edef=3 % epics event definition for buffered acq
  end
  properties(SetAccess=private)
    f2c F2_common
    epicsonly % list of BPMs which can only be got through source epics PVs (not *:X57 etc)
  end
  properties(Access=private)
    monidef logical = false
    moniedef logical =false
    moninames_x string
    moninames_y string
    moninames_tmit string
    usebacq logical = false
    MonitorList string
  end
  methods
    function obj = F2_bpms(LM)
      
      obj.f2c = F2_common;
      
      % Generate model object
      if ~exist('LM','var') || isempty(LM) % generate new model object
        obj.LM = LucretiaModel(F2_common.LucretiaLattice);
      else % use provided live model object
        obj.LM = copy(LM) ;
      end
      
      % Local lists
      obj.MakeList();
      
      % Initialize data buffers for use with read method
      obj.xdat=nan(length(obj.bpmnames),obj.BufferLen);
      obj.ydat=nan(length(obj.bpmnames),obj.BufferLen);
      obj.tmit=nan(length(obj.bpmnames),obj.BufferLen);
      obj.pulseid=1;
      
      % LabCA warnings level
      lcaSetSeverityWarnLevel(14) ;
      lcaSetSeverityWarnLevel(4) ;
      
    end
    function plot(obj,ahan,ahan2)
      if isempty(obj.xdat)
        error('No data to plot')
      end
      if ~exist('ahan','var') || isempty(ahan)
        ahan=figure;
      end
      xm = obj.xave ;
      ym = obj.yave ;
      xerr = obj.xrms ;
      yerr = obj.yrms ;
      z = obj.modelZ ;
      ele =obj.modelID ;
      xax=subplot(2,1,1,'Parent',ahan);
      yax=subplot(2,1,2,'Parent',ahan);
      errorbar(xax,z,xm,xerr,'.'), xlabel(xax,'Z [m]'); ylabel(xax,'X [mm]');
      grid(xax,'on');
      if exist('ahan2','var')
        errorbar(ahan2,z,xm,xerr,'.');
        try
          AddMagnetPlotZ(ele(1),ele(end),ahan2,'replace');
        catch
        end
      else
        try
          AddMagnetPlotZ(ele(1),ele(end),xax);
        catch
        end
      end
      if obj.plotscale>0
        ax=axis(xax); ax(3)=double(-obj.plotscale); ax(4)=double(obj.plotscale); axis(xax,ax);
      end
      errorbar(yax,z,ym,yerr,'.'), xlabel(yax,'Z [m]'); ylabel(yax,'Y [mm]');
      grid(yax,'on');
      if ~exist('ahan2','var')
        try
          AddMagnetPlotZ(ele(1),ele(end),yax);
        catch
        end
      end
    end
    function set.UseRegion(obj,reg)
      obj.LM.UseRegion=reg;
      obj.UseRegion=reg;
      obj.MakeList(); % Update local lists
    end
    function readnp(obj,npulse,archivedate)
      %READNP Read N pulses from EPICS BPM repeater
      %readnp(npulse)
      % Get N pulses (pausing 1 pulse duration between each get operation)
      %readnp(npulse,ArchiveDate)
      % Read npulses from archiver starting at archivedate=[yr mnth day hr min sec]
      obj.pulseid=1;
      obj.BufferLen=npulse;
      if ~exist('archivedate','var') || isempty(archivedate)
        for ipulse=1:npulse
          obj.read();
        end
      else
        obj.read(archivedate,npulse);
      end
      obj.nread=npulse;
    end
    function read(obj,archivedate,npulse)
      %READ Acquire a single orbit from EPICS
      %read() Read a single pulse from live EPICS database
      %read(startTime,npulse) Read npulses from archiver starting at startTime=[yr mnth day hr min sec]
      persistent lastpvs
      
      % Reset data buffers if previously used buffered data aquisition method
      if obj.usebacq
        obj.MakeList(); % Update master local lists
        obj.xdat=nan(length(obj.bpmnames),obj.BufferLen);
        obj.ydat=nan(length(obj.bpmnames),obj.BufferLen);
        obj.tmit=nan(length(obj.bpmnames),obj.BufferLen);
        obj.pulseid=1;
      end
      obj.usebacq=false;
      
      % Form PV list
      xnames = obj.epicsnames + ":X57" ;
      ynames = obj.epicsnames + ":Y57" ;
      tmitnames = obj.epicsnames + ":TMIT57" ;
      xnames(obj.epicsonly) = obj.epicsnames(obj.epicsonly) + ":X" ;
      ynames(obj.epicsonly) = obj.epicsnames(obj.epicsonly) + ":Y" ;
      tmitnames(obj.epicsonly) = obj.epicsnames(obj.epicsonly) + ":TMIT" ;
      switch obj.dim
        case "x"
          pvs = cellstr([xnames(:);tmitnames(:)]);
        case "y"
          pvs = cellstr([ynames(:);tmitnames(:)]);
        case "xy"
          pvs = cellstr([xnames(:);ynames(:);tmitnames(:)]);
      end
      
      % Acquire new bpm data live or from archiver
      if exist('archivedate','var')
        
        dat = archive_dataGet(pvs,datenum(archivedate),datenum(datetime(archivedate)+npulse*seconds(10))) ;
        for ipv=1:length(obj.epicsnames)
          for ipulse=1:npulse
            try
              switch obj.dim
                case "x"
                  obj.xdat(ipv,ipulse) = dat{ipv}(ipulse) ;
                  obj.tmit(ipv,ipulse) = dat{ipv+length(obj.epicsnames)}(ipulse) ;
                case "y"
                  obj.ydat(ipv,ipulse) = dat{ipv}(ipulse) ;
                  obj.tmit(ipv,ipulse) = dat{ipv+length(obj.epicsnames)}(ipulse) ;
                case "xy"
                  obj.xdat(ipv,ipulse) = dat{ipv}(ipulse) ;
                  obj.ydat(ipv,ipulse) = dat{ipv+length(obj.epicsnames)}(ipulse) ;
                  obj.tmit(ipv,ipulse) = dat{ipv+2*length(obj.epicsnames)}(ipulse) ;
              end
            catch
              continue
            end
          end
        end
        % Increment pulseid pointer
          obj.pulseid = obj.pulseid + npulse ;
          if obj.pulseid > obj.BufferLen
            obj.pulseid = 1 ;
          end
      else
        
        % Wait for any new BPM to post data, then pause 1/2 rep rate and grab all
        if isempty(lastpvs) || ~isequal(lastpvs,pvs)
          lcaSetMonitor(pvs);
          lastpvs=pvs;
        end
        t0=tic;
        while ~any(lcaNewMonitorValue(pvs)) || toc(t0)>1.5
          pause(1/double(obj.beamrate)/10);
        end
        pause(1/double(obj.beamrate)/2);
        dat = lcaGet(pvs) ;
        
        % Sort new data
        switch obj.dim
          case "x"
            obj.xdat(:,obj.pulseid) = dat(1:length(obj.epicsnames)) ;
            obj.tmit(:,obj.pulseid) = dat(length(obj.epicsnames)+1:end) ;
          case "y"
            obj.ydat(:,obj.pulseid) = dat(1:length(obj.epicsnames)) ;
            obj.tmit(:,obj.pulseid) = dat(length(obj.epicsnames)+1:end) ;
          case "xy"
            obj.xdat(:,obj.pulseid) = dat(1:length(obj.epicsnames)) ;
            obj.ydat(:,obj.pulseid) = dat(length(obj.epicsnames)+1:2*length(obj.epicsnames)) ;
            obj.tmit(:,obj.pulseid) = dat(2*length(obj.epicsnames)+1:end) ;
        end
        
        % Increment pulseid pointer
        obj.pulseid = obj.pulseid + 1 ;
        if obj.pulseid > obj.BufferLen
          obj.pulseid = 1 ;
        end
        
      end
      % Apply tmitcut if set
      if ~isempty(obj.tmitcut)
        cut = obj.tmit(:,obj.pulseid) < obj.tmitcut ;
        obj.xdat(cut,obj.pulseid) = nan ;
        obj.ydat(cut,obj.pulseid) = nan ;
      end
        
    end
    function readbuffer(obj,npulse)
      %READBUFFER get buffered BPM data
      %readbpms(npulse)
      
      % Reset any stored data
      obj.usebacq=true;
      obj.xdat=[];
      obj.ydat=[];
      obj.tmit=[];
      obj.MakeList(); % Update master local lists
      
      % Breakdown of BPM lists into those that need epics or aida and make edef pv name
      selaida=startsWith(obj.bpmnames,"LI") ;
      selepics=startsWith(obj.bpmnames,"BPMS:") ;
      edefpv=sprintf('EDEF:SYS1:%d:CTRL',obj.edef);
      
      % Command EPICS channels to gather buffered data
      if any(selepics) && any(selaida) % get more EPICS data if need to overlap AIDA and EPICS
        npe=floor(obj.nepicsbuffer*npulse);
      else
        npe=npulse;
      end
      if any(selepics)
        lcaPutNoWait(sprintf('EDEF:SYS1:%d:MEASCNT ',obj.edef),npe);
        if ~obj.moniedef
          lcaSetMonitor(edefpv);
          obj.moniedef=true;
        end
        lcaPutNoWait(edefpv,1) ;
      end
      % Get SCP buffered data through AIDA
      if any(selaida)
        aidapva;
        builder = pvaRequest('FACET-II:BUFFACQ');
        builder.with('BPMD', 57);
        builder.with('NRPOS', npulse);
        builder.timeout(180);
        abpmnames={};
        for ibpm=find(selaida)'
          name = regexp(obj.bpmnames(ibpm),"(\S+):(\S+):(\d+)",'tokens','once') ;
          abpmnames{end+1} = char(name(2)+":"+name(1)+":"+name(3)) ;
        end
        builder.with('BPMS', abpmnames) ;
        mstruct = ML(builder.get()) ;
        aida_pid = mstruct.values.id ; aida_pid=reshape(aida_pid,npulse,sum(selaida))'; aida_pid=aida_pid(1,:);
        aida_x = mstruct.values.x ; aida_x=reshape(aida_x,npulse,sum(selaida))' ;
        aida_y = mstruct.values.y ; aida_y=reshape(aida_y,npulse,sum(selaida))' ;
        aida_tmit = mstruct.values.tmits ; aida_tmit=reshape(aida_tmit,npulse,sum(selaida))' ;
      end
      % Wait for EPICS data to finish, then grab it
      if any(selepics)
        cv=lcaGet(edefpv);
        if string(cv{1})~="OFF"
          lcaNewMonitorWait(edefpv);
        end
        epics_x = lcaGet(cellstr(obj.bpmnames(selepics)+":XHST"+obj.edef),npe) ;
        epics_y = lcaGet(cellstr(obj.bpmnames(selepics)+":YHST"+obj.edef),npe) ;
        epics_tmit = lcaGet(cellstr(obj.bpmnames(selepics)+":TMITHST"+obj.edef),npe) ;
        epics_pid = lcaGet(sprintf('PATT:SYS1:1:PULSEID%d',obj.edef)) ; % Pulse ID of last data
      end
      % If both SCP and EPICS BPM data, then align using pulse ID
      if any(selepics) && any(selaida)
        aidaid = aida_pid<=epics_pid ; % overlap of AIDA data with EPICS data
        if ~any(aidaid)
          error('No overlapping SCP+EPICS BPMs found in buffer');
        end
        obj.nread = sum(aidaid) ;
        obj.xdat = zeros(length(obj.bpmnames),obj.nread); obj.ydat=obj.xdat ; obj.tmit=obj.xdat;
        obj.xdat(selaida,:) = aida_x(:,aidaid) ; obj.ydat(selaida,:) = aida_y(:,aidaid) ; obj.tmit(selaida,:) = aida_tmit(:,aidaid) ;
        obj.pulseid = aida_pid(aidaid) ;
        dpid=diff(obj.pulseid(1:2));
        nepicsextd = (epics_pid - obj.pulseid(end))/dpid ;
        sz=size(epics_x);
        if nepicsextd > 0 % epics buffer extends past aida buffer
          i2 = sz(2) - nepicsextd ;
        elseif nepicsextd <= 0 % aida buffer extends past epics buffer or end points match
          i2 = sz(2) ;
        end
        i1 = 1+(i2-obj.nread) ;
        if i1<1
          error('No overlap between EPICS and AIDA data');
        end
        obj.xdat(selepics,:) = epics_x(:,i1:i2) ;
        obj.ydat(selepics,:) = epics_y(:,i1:i2) ;
        obj.tmit(selepics,:) = epics_tmit(:,i1:i2) ;
      elseif any(selaida)
        obj.xdat = aida_x ;
        obj.ydat = aida_y ;
        obj.tmit = aida_tmit ;
        obj.pulseid = aida_pid ;
      elseif any(selepics)
        obj.xdat = epics_x ;
        obj.ydat = epics_y ;
        obj.tmit = epics_tmit ;
        obj.pulseid = epics_pid ;
      end
      % Assume exactly 0 vals are errors
      obj.xdat(obj.xdat==0)=nan;
      obj.ydat(obj.ydat==0)=nan;
      obj.tmit(obj.tmit==0)=nan;
      % If all entries for given BPM are nan, then deselct BPM and adjust name lists etc.
      for ibpm=1:length(obj.bpmnames)
        if all(isnan(obj.xdat(ibpm,:))) || all(isnan(obj.ydat(ibpm,:)))
          selepics(ibpm)=false;
          selaida(ibpm)=false;
        end
      end
      obj.xdat=obj.xdat(selepics|selaida,:);
      obj.ydat=obj.ydat(selepics|selaida,:);
      obj.tmit=obj.tmit(selepics|selaida,:);
      nsel = ~(selaida|selepics) ;
      obj.bpmnames(nsel)=[];
      obj.modelnames(nsel)=[];
      obj.modelZ(nsel)=[];
      obj.modelID(nsel)=[];
      obj.epicsnames(nsel)=[];
      % Apply tmit cuts
      if ~isempty(obj.tmitcut)
        cut = obj.tmit < obj.tmitcut ;
        obj.xdat(cut) = nan ;
        obj.ydat(cut) = nan ;
      end
    end
    function LoadData(obj,xdat_new,ydat_new,tmit_new)
      if exist('xdat_new','var') && ~isempty(xdat_new)
        sz_n=size(xdat_new);
        sz=size(obj.xdat);
        if ~isequal(sz,sz_n)
          error('Dimension mismatch between new and existing data, aborting laod');
        end
        obj.xdat=xdat_new;
      end
      if exist('ydat_new','var') && ~isempty(ydat_new)
        sz_n=size(ydat_new);
        sz=size(obj.ydat);
        if ~isequal(sz,sz_n)
          error('Dimension mismatch between new and existing data, aborting laod');
        end
        obj.ydat=ydat_new;
      end
      if exist('tmit_new','var') && ~isempty(tmit_new)
        sz_n=size(tmit_new);
        sz=size(obj.tmit);
        if ~isequal(sz,sz_n)
          error('Dimension mismatch between new and existing data, aborting laod');
        end
        obj.tmit=tmit_new;
      end
    end
  end
  methods(Access=private)
    function UpdateProc(obj) %#ok<MANU>
      % Wait for monitors to post and acquire new BPM data
      %       if ~obj.monidef
      %         lcaSetMonitor(cellstr(xnames(:)));
      %         obj.monidef=true;
      %       end
      %       timeout=2;
      %       if ~doasyn || obj.t_reset
      %         obj.t0=tic;
      %         obj.t_reset = false ;
      %       end
      %       while 1
      %         nv = logical(lcaNewMonitorValue(cellstr(xnames))) ;
      %       end
    end
    function StopProc(obj) %#ok<MANU>
    end
    function MakeList(obj)
      %MAKELIST Make local lists from master model info
      obj.LM.ModelClasses="MONI";
      obj.bpmnames=obj.LM.ControlNames;
      obj.modelnames=obj.LM.ModelNames;
      obj.modelZ = obj.LM.ModelZ ;
      obj.modelID = obj.LM.ModelID ;
      nsel = ismember(obj.modelnames,obj.badbpms) | (~startsWith(obj.bpmnames,"LI") & ~startsWith(obj.bpmnames,"BPMS")) ;
      obj.bpmnames(nsel)=[];
      obj.modelnames(nsel)=[];
      obj.modelZ(nsel)=[];
      obj.modelID(nsel)=[];
      obj.epicsnames=regexprep(obj.bpmnames,"(LI\d+:)BPMS:(.+)","BPMS:$1$2"); obj.epicsnames=obj.epicsnames(:);
      obj.epicsonly =  startsWith(obj.bpmnames,"BPMS:") ;
      obj.monidef=false; % Update monitors on next read command call
    end
  end
  % Get/set methods
  methods
    function set.autoupdate(obj,val)
      obj.autoupdate=val;
      if ~val % stop Update Timer
        stop(obj.UpdateTimer);
        return
      end
      % Add any new PVs to monitor list
      monipv = [obj.LM.ControlNames+":BDES"; obj.LM.ControlNames+":BACT"];
      newmoni=monipv(~ismember(monipv,obj.MonitorList));
      obj.MonitorList = [obj.MonitorList; newmoni] ;
      lcaSetMonitor(cellstr(newmoni));
      % (Re)Launch update timer
      if ~isempty(obj.UpdateTimer)
        stop(obj.UpdateTimer);
      end
      obj.UpdateTimer=timer('Period',0.1,'ExecutionMode','fixedRate','TimerFcn',@(~,~) obj.UpdateProc, 'StopFcn', @(~,~) obj.StopProc );
      start(obj.UpdateTimer);
    end
    function set.BufferLen(obj,blen)
      if blen>obj.BufferLen
        obj.xdat(:,obj.BufferLen+1:blen) = nan ;
        obj.ydat(:,obj.BufferLen+1:blen) = nan ;
        obj.tmit(:,obj.BufferLen+1:blen) = nan ;
      elseif blen<obj.BufferLen
        obj.xdat(:,blen+1:end) = [] ;
        obj.ydat(:,blen+1:end) = [] ;
        obj.tmit(:,blen+1:end) = [] ;
      end
      obj.BufferLen=blen;
    end
    function xm = get.xave(obj)
      xm = mean(obj.xdat,2,'omitnan') ;
    end
    function ym = get.yave(obj)
      ym = mean(obj.ydat,2,'omitnan') ;
    end
    function tm = get.tmitave(obj)
      tm = mean(obj.tmit,2,'omitnan') ;
    end
    function val = get.xrms(obj)
      val = std(obj.xdat,[],2,'omitnan') ;
    end
    function val = get.yrms(obj)
      val = std(obj.ydat,[],2,'omitnan') ;
    end
    function val = get.tmitrms(obj)
      val = std(obj.tmit,[],2,'omitnan') ;
    end
    function beamrate = get.beamrate(obj)
      beamrate = obj.f2c.beamrate ;
    end
  end
end
