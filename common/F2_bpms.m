classdef F2_bpms < handle
  properties
  end
  properties(SetAccess=private)
    xdat
    ydat
    pulseid
    nread uint16
    names string
    LM
    beamrate uint8 = 30 % Active beam rate [Hz} Updates on readbpms
  end
  properties(SetObservable)
    UseRegion(1,11) logical = true(1,11) % See LucretiaModel for region definitions
  end
  properties(Constant)
    edef=3 % epics event definition for buffered acq
  end
  methods
    function obj = F2_bpms()
      
      % Generate model object
      obj.LM = LucretiaModel(F2_common.LucretiaLattice); 
      
      % Register EPICS monitors
      lcaSetMonitor(sprintf('EDEF:SYS0:%d:CTRL',obj.edef));
      
    end
    function set.UseRegion(obj,reg)
      obj.LM.UseRegion=reg;
    end
    function readbpms(obj,npulse)
      %READBPMS get buffered BPM data
      %readbpms(npulse)
      import edu.stanford.slac.aida.lib.da.DaObject;
      obj.beamrate = double(regexp(string(lcaGet('IOC:SYS1:MP01:MS_RATE',1)),'(\d+)','match')) ;
      obj.LM.ModelClasses("MONI");
      bpmnames=obj.LM.ControlNames;
      aidanames=find(startsWith(bpmnames,"LI"));
      epicsnames=find(startsWith(bpmnames,"BPMS:"));
      edefpv=sprintf('EDEF:SYS1:%d:CTRL',obj.edef);
      % Command EPICS channels to gather buffered data
      if ~isempty(epicsnames)
        lcaPutNoWait(edefpv,1) ;
      end
      % Get SCP buffered data through AIDA
      if ~isempty(aidanames)
        aidainit;
        da = DaObject();
        da.reset;
        da.setParam('BPMD', '57');
        da.setParam('NRPOS', num2str(npulse));
        nbpm=0;
        for ibpm=aidanames
          nbpm=nbpm+1;
          name = regexp(bpmnames(ibpm),"(\S+):(\S+):(\d+)",'tokens','once') ;
          da.setParam(sprintf('BPM%d',nbpm), char(name(2)+":"+name(1)+":"+name(3)));
        end
        buffdata = da.getDaValue(strcat('FACET-II', '//BUFFACQ'));
        aida_pid = buffdata.get(1).getAsDoubles() ; % Vector of pulse IDs
        aida_x = buffdata.get(2).getAsDoubles() ; aida_x=reshape(aida_x,length(aidanames),npulse) ;
        aida_y = buffdata.get(3).getAsDoubles() ; aida_y=reshape(aida_y,length(aidanames),npulse) ;
      end
      % Wait for EPICS data to finish, then grab it
      if ~isempty(epicsnames)
        cv=lcaGet(edefpv);
        if string(cv{1})~="OFF"
          lcaNewMonitorWait(edefpv);
        end
        epics_x = lcaGet(cellstr(bpmnames(epicsnames)+"XHST"+obj.edef),npulse) ;
        epics_y = lcaGet(cellstr(bpmnames(epicsnames)+"YHST"+obj.edef),npulse) ;
        epics_pid = lcaGet(sprintf('PATT:SYS1:1:PULSEID%d',obj.edef)) ; % Pulse ID of last data
      end
      % If both SCP and EPICS BPM data, then align using pulse ID
      if ~isempty(epicsnames) && ~isempty(aidanames)
        lastid = find(aida_pid==epics_pid,1) ;
        if isempty(lastid)
          error('No overlapping SCP+EPICS BPMs found in buffer');
        end
        obj.nread = lastid ;
        obj.xdat = zeros(length(aidanames)+length(epicsnames),obj.nread); obj.ydat=obj.xdat ;
        obj.xdat(aidanames,:) = aida_x(:,1:lastid) ; obj.ydat(aidanames,:) = aida_y(:,1:lastid) ;
        obj.xdat(epicsnames,:) = epics_x(:,1+(npulse-lastid):end) ; obj.ydat(epicsnames,:) = epics_y(:,1+(npulse-lastid):end) ;
        obj.pulseid = aida_pid(1:lastid) ;
        sid = sort([aidanames epicsnames]) ;
        obj.names = bpmnames(sid) ;
      elseif ~isempty(aidanames)
        obj.xdat = aida_x ;
        obj.ydat = aida_y ;
        obj.pulseid = aida_pid ;
        obj.names = bpmnames(aidanames) ;
      elseif ~isempty(epicsnames)
        obj.xdat = epics_x ;
        obj.ydat = epics_y ;
        obj.pulseid = epics_pid ;
        obj.names = bpmnames(epicsnames) ;
      end
    end
  end
end
