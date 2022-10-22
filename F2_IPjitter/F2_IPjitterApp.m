classdef F2_IPjitterApp < handle
  %F2_IPJITTERAPP Get waist data in experimental region of S20
  % Companion app to F2_IPjitter GUI
  properties
    mintmit {mustBePositive} = 1 % min allowable TMIT on bpms (x 1E9)
    designsigma(1,2) = [11.3 11.3] % Design beam size [um]
    designdivergence(1,2) = [22.6 22.6] % Design divergence angle [urad]
  end
  properties(SetAccess=private)
    guihan
    LLM
    BPMS
    ipdat % processed data [mm,mrad for x/y; m for z]
  end
  properties(Access=private)
    adate
  end
  properties(SetObservable)
    npulses uint16 {mustPositive,mustBeLessThan(npulses,10000)} = 20
    bpmid(1,2) uint8
  end
  methods
    function obj = F2_IPjitterApp(apphan,LLM)
      %F2_IPJITTERAPP Get waist data in experimental region of S20
      %F2_IPjitterApp([guihandle,LucretiaLiveModelApp])
      if exist('apphan','var')
        obj.guihan=apphan;
      end
      if exist('LLM','var')
        obj.LLM=LLM;
      else
        obj.LLM=F2_LiveModelApp;
      end
      % Initialize model elements (use S20 FFS and Dump regions)
      obj.LLM.Mags.UseSector=[0 0 0 0 1];
      obj.LLM.Mags.autoupdate=true;
      obj.BPMS=F2_bpms(obj.LLM.LM);
      obj.BPMS.UseRegion=[0 0 0 0 0 0 0 0 0 1 1];
      obj.BPMS.BufferLen = obj.npulses;
      % Use M5FF/M0EX BPMs by defaults
      obj.bpmid = [find(obj.BPMS.modelnames=="M5FF") find(obj.BPMS.modelnames=="M0EX")] ;
      % Setup BPM lists in GUI
      if ~isempty(obj.guihan)
        obj.guihan.BPMS1.Items = obj.BPMS.modelnames + " / " + obj.BPMS.bpmnames ;
        obj.guihan.BPMS1.ItemsData = 1:length(obj.BPMS.modelnames) ;
        obj.guihan.BPMS1.Value = obj.bpmid(1) ;
        obj.guihan.BPMS2.Items = obj.BPMS.modelnames + " / " + obj.BPMS.bpmnames ;
        obj.guihan.BPMS2.ItemsData = 1:length(obj.BPMS.modelnames) ;
        obj.guihan.BPMS2.Value = obj.bpmid(2) ;
      end
    end
    function guiplot(obj)
      %GUIPLOT Plot data in GUI and update GUI data fields
      global BEAMLINE
      if isempty(obj.guihan)
        return
      end
      if isempty(obj.ipdat)
        error('No BPM data taken, or procdata not called');
      end
      g=obj.guihan;
      histogram(g.xax,obj.ipdat.xpos.*1e3);
      histogram(g.xpax,obj.ipdat.xang.*1e3);
      histogram(g.yax,obj.ipdat.ypos.*1e3);
      histogram(g.ypax,obj.ipdat.yang.*1e3);
      plot(g.xyax,obj.ipdat.xpos.*1e3,obj.ipdat.ypos.*1e3,'.');
      plot(g.xpypax,obj.ipdat.xang.*1e3,obj.ipdat.yang.*1e3,'.');
      plot(g.sxax.*1e3,obj.ipdat.zpos-1000,obj.ipdat.xstd); ax=axis(g.sxax);
      line(g.sxax,ones(1,2)*obj.ipdat.xstd(obj.ipdat.izwaist(1))*1e3,ax(3:4),'LineStyle','--','Color','r');
      plot(g.syax.*1e3,obj.ipdat,zpos-1000,obj.ipdat.ystd); ax=axis(g.syax);
      line(g.syax,ones(1,2)*obj.ipdat.ystd(obj.ipdat.izwaist(2))*1e3,ax(3:4),'LineStyle','--','Color','r');
      if ~isempty(obj.adate)
        txt="BPM data from archiver: " + datestr(obj.adate) ;
      else
        txt="Live BPM data (N pulses = " + length(obj.ipdat.xpos) + ")";
      end
      zall=arrayfun(@(x) BEAMLINE{x}.Coordi(3),1:length(BEAMLINE));
      dzx = zall-obj.ipdat.zpos(obj.ipdat.izwaist(1)) ;
      dzy = zall-obj.ipdat.zpos(obj.ipdat.izwaist(2)) ;
      [~,inearestx] = min(abs(dzx)) ; dzx = dzx(inearestx) ;
      [~,inearesty] = min(abs(dzy)) ; dzy = dzy(inearesty) ;
      txt=sprintf("%s\nIP X waist fit @ Z=%.3f (m), nearest model element = %s [dz=%.1f (mm)]",...
        txt,obj.ipdat.zpos(obj.ipdat.izwaist(1)),BEAMLINE{inearestx}.Name,dzx*1e3) ;
      txt=sprintf("%s\nIP Y waist fit @ Z=%.3f (m), nearest model element = %s [dz=%.1f (mm)]",...
        txt,obj.ipdat.zpos(obj.ipdat.izwaist(2)),BEAMLINE{inearesty}.Name,dzy*1e3) ;
      txt=sprintf("%s\nRMS X Position jitter @ IP Waist = %.2f (um) = %.2f (sigma)",...
        txt,obj.ipdat.xstd(obj.ipdat.izwaist(1))*1e3,obj.ipdat.xstd(obj.ipdat.izwaist(1))*1e3/obj.designsigma(1));
      txt=sprintf("%s\nRMS Y Position jitter @ IP Waist = %.2f (um) = %.2f (sigma)",...
        txt,obj.ipdat.ystd(obj.ipdat.izwaist(2))*1e3,obj.ipdat.ystd(obj.ipdat.izwaist(2))*1e3/obj.designsigma(2));
      txt=sprintf("%s\nRMS X Angle jitter @ IP Waist = %.2f (urad) = %.2f (sigma')",...
        txt,obj.ipdat.xpstd(obj.ipdat.izwaist(1))*1e3,obj.ipdat.xpstd(obj.ipdat.izwaist(1))*1e3/obj.designdivergence(1));
      txt=sprintf("%s\nRMS Y Angle jitter @ IP Waist = %.2f (urad) = %.2f (sigma')",...
        txt,obj.ipdat.ypstd(obj.ipdat.izwaist(2))*1e3,obj.ipdat.ypstd(obj.ipdat.izwaist(2))*1e3/obj.designdivergence(2));
      g.fitinfo.Value = txt ;
    end
    function procdata(obj)
      %PROCDATA process BPM data to get IP waist info
      global BEAMLINE
      % - Get raw BPM data in x and y for selected pair of BPMS
      tok= obj.BPMS.tmit(obj.bpmid(1),:)>=obj.mintmit & obj.BPMS.tmit(obj.bpmid(2),:)>=obj.mintmit ;
      xbpm=[obj.BPMS.xdat(obj.bpmid(1),tok); obj.BPMS.xdat(obj.bpmid(2),tok)] ;
      ybpm=[obj.BPMS.ydat(obj.bpmid(1),tok); obj.BPMS.ydat(obj.bpmid(2),tok)] ;
      if isempty(xbpm) || isempty(ybpm)
        error('No valid BPM data')
      end
      % - Get corresponding x and y positions at waist and waist location
      % - first get beam position at first bpm, then extrapolate at 1mm intervals between Q0FF and Q0F
      i1=obj.BPMS.modelID(obj.bpmid(1));
      i2=obj.BPMS.modelID(obj.bpmid(2));
      [~,R]=RmatAtoB(i1,i2);
      x0 = xbpm(1,:) ;
      xp0 = ( xbpm(2,:) - R(1,1)*x0 ) ./ R(1,2) ;
      y0 = ybpm(1,:) ;
      yp0 = ( ybpm(2,:) - R(3,3)*y0 ) ./ R(3,4) ;
      q1=findcells(BEAMLINE,'Name','Q0FF');
      q2=findcells(BEAMLINE,'Name','Q0D');
      dz=BEAMLINE{q2(1)}.Coordi(3)-BEAMLINE{q1(end)}.Coordf(3);
      zdat=linspace(BEAMLINE{q1(end)}.Coordf(3),BEAMLINE{q2(1)}.Coordi(3),ceil(dz/1e-3));
      if i1<q1(end)
        [~,Rq]=RmatAtoB(i1,q1(end));
        X0 = Rq(1:4,1:4) * [x0;xp0;y0;yp0] ;
      else
        [~,Rq]=RmatAtoB(q1(end),i1);
        X0 = Rq(1:4,1:4) \ [x0;xp0;y0;yp0] ;
      end
      obj.ipdat.xpos = X0(1,:) + X0(2,:).*(zdat(:)-zdat(1)) ;
      obj.ipdat.xang = X0(2,:) ;
      obj.ipdat.ypos = X0(3,:) + X0(4,:).*(zdat(:)-zdat(1)) ;
      obj.ipdat.yang = X0(4,:) ;
      obj.ipdat.zpos = zdat ;
      obj.ipdat.xstd = std(obj.ipdat.xpos) ;
      obj.ipdat.ystd = std(obj.ipdat.ypos) ;
      obj.ipdat.xpstd = std(obj.ipdat.xang) ;
      obj.ipdat.ypstd = std(obj.ipdat.yang) ;
      [~,iwx] = min(obj.ipdat.xstd) ;
      [~,iwy] = min(obj.ipdat.ystd) ;
      obj.ipdat.izwaist = [iwx iwy] ;
    end
    function GetBPMS(obj,archivedate)
      %GETBPMS Get new BPM data
      %GetBPMS([archivedate])
      % Default is to use live data unless archive data/time provided
      % archivedate = [yr mnth day hr min sec]
      obj.ipdat=[];
      if exist('archivedate','var')
        obj.adate=archivedate;
        obj.BPMS.readnp(obj.npulses,archivedate);
      else
        obj.adate=[];
        obj.BPMS.readbuffer(obj.npulses);
      end
    end
  end
  methods % get/set functions
    function set.npulses(obj,np)
      obj.npulses=np;
      obj.BPMS.BufferLen=np;
    end
  end
end