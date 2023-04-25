classdef F2_TFeedbackApp < handle
  properties
    pospv % Position readback PVs
    aobj % link to GUI
    cc_kick = 1e-4 % Kick range when experimentally calculating response matices [rad]
    cc_ndat = [10,5] % N data per corrector (bpm readings & kicks) to take when experimentally calculating response matices [nbpm per kick,n kicks]
    LLM
    verbose uint8 = 1
    datato = 30 % data timeout [s]
    stoptmr logical = false % Set true to stop data processing loop
  end
  properties(SetObservable=true)
    usemodel(1,4) logical = [false,false,false,false]
    gain(1,4)
    offs(1,16)
    fbon(1,4) logical = [true,true,true,true] % FB running?
  end
  properties(SetAccess=private)
    lastTS % Last data time stamps
    data % [m/rad]
    modeldat
    exptdat
    fbloc_ind
    pldata % data for gui plotting
    ltr % loop processing timer
  end
  properties(Constant)
    fbonpv = "SIOC:SYS1:ML00:FWF24" % PVs for FB on status
    gainoffpv = "SIOC:SYS1:ML00:FWF20" % Feedback gain values
    datapv = "SIOC:SYS1:ML01:AO601" % link to first of data PVs
    usemodelpv = "SIOC:SYS1:ML00:FWF19"
    fbcoefpv = "SIOC:SYS1:ML00:FWF23"
    maxage = 5 % Max FB data age [s]
    fbname = ["DL10" "BC11" "BC14" "BC20"]
    qpv = ["BPMS:IN10:731:TMIT" "BPMS:LI11:333:TMIT" "BPMS:LI14:801:TMIT" "BPMS:LI20:2445:TMIT1H"]
    fbloc = ["BPM10731" "BPM11333" "BPM14801" "M1E"]
    fbcors = ["XC10641" "XC10721" "XC11272" "XC11304" "XC14602" "XC14702" "XC19900" "XC1996"; "YC10722" "YC10642" "YC11305" "YC11321" "YC14703" "YC14780" "YC19803" "YC19900"]
    posmax = 10e-3 % [m]
    angmax = 10e-3 % [rad]
    demax = 5e-2;
    qmin = 1e9
  end
  methods
    function obj = F2_TFeedbackApp(aobj,LLM)
      global BEAMLINE
      % Initialize live model
      if exist('LLM','var') && ~isempty(LLM)
        obj.LLM=LLM;
      else
        obj.LLM=F2_LiveModelApp;
      end
      obj.LLM.autoupdate=true;
      % Attached GUI?
      if exist('aobj','var') && ~isempty(aobj)
        obj.aobj=aobj;
      end
      % Flag FBs to run
      obj.fbon=logical(lcaGet(obj.fbonpv,length(obj.fbname)));
      % Form PV names of reconstructed orbit entries
      id1=str2double(regexp(obj.datapv,"AO(\d+)$",'tokens','once'));
      pv1 = regexprep(obj.datapv,"(\d+)$","");
      for ifb=1:length(obj.fbname)
        obj.pospv.(obj.fbname(ifb)).x     = pv1 + (id1 + (ifb-1)*6 + 1) ;
        obj.pospv.(obj.fbname(ifb)).xp    = pv1 + (id1 + (ifb-1)*6 + 2) ;
        obj.pospv.(obj.fbname(ifb)).y     = pv1 + (id1 + (ifb-1)*6 + 3) ;
        obj.pospv.(obj.fbname(ifb)).yp    = pv1 + (id1 + (ifb-1)*6 + 4) ;
        obj.pospv.(obj.fbname(ifb)).de    = pv1 + (id1 + (ifb-1)*6 + 5) ;
        obj.pospv.(obj.fbname(ifb)).valid = pv1 + (id1 + (ifb-1)*6 + 6) ;
      end
      % Store BEAMLINE indices
      for ifb=1:length(obj.fbname)
        obj.fbloc_ind(ifb)=findcells(BEAMLINE,'Name',obj.fbloc(ifb));
      end
      % Get stored options
      obj.usemodel = logical(lcaGet(char(obj.usemodelpv),length(obj.usemodel))) ;
      % Get experimental fb coef data
      pvdat=lcaGet(obj.fbcoefpv,length(obj.fbname)*16);
      for ifb=find(obj.fbon)
        kpv(1,1) = obj.fbcors(1,(ifb-1)*2+1); kpv(1,2) = obj.fbcors(1,(ifb-1)*2+2);
        kpv(2,1) = obj.fbcors(2,(ifb-1)*2+1); kpv(2,2) = obj.fbcors(2,(ifb-1)*2+2);
        slopes(obj.fbname(ifb)).(kpv(1,1)).x  = pvdat((ifb-1)*16+1)  ;
        slopes(obj.fbname(ifb)).(kpv(1,2)).x  = pvdat((ifb-1)*16+2)  ;
        slopes(obj.fbname(ifb)).(kpv(2,1)).x  = pvdat((ifb-1)*16+3)  ;
        slopes(obj.fbname(ifb)).(kpv(2,2)).x  = pvdat((ifb-1)*16+4)  ;
        slopes(obj.fbname(ifb)).(kpv(1,1)).xp = pvdat((ifb-1)*16+5)  ;
        slopes(obj.fbname(ifb)).(kpv(1,2)).xp = pvdat((ifb-1)*16+6)  ;
        slopes(obj.fbname(ifb)).(kpv(2,1)).xp = pvdat((ifb-1)*16+7)  ;
        slopes(obj.fbname(ifb)).(kpv(2,2)).xp = pvdat((ifb-1)*16+8)  ;
        slopes(obj.fbname(ifb)).(kpv(1,1)).y  = pvdat((ifb-1)*16+9)  ;
        slopes(obj.fbname(ifb)).(kpv(1,2)).y  = pvdat((ifb-1)*16+10) ;
        slopes(obj.fbname(ifb)).(kpv(2,1)).y  = pvdat((ifb-1)*16+11) ;
        slopes(obj.fbname(ifb)).(kpv(2,2)).y  = pvdat((ifb-1)*16+12) ;
        slopes(obj.fbname(ifb)).(kpv(1,1)).yp = pvdat((ifb-1)*16+13) ;
        slopes(obj.fbname(ifb)).(kpv(1,2)).yp = pvdat((ifb-1)*16+14) ;
        slopes(obj.fbname(ifb)).(kpv(2,1)).yp = pvdat((ifb-1)*16+15) ;
        slopes(obj.fbname(ifb)).(kpv(2,2)).yp = pvdat((ifb-1)*16+16) ;
      end
      obj.exptdat = slopes ;
      % Get gain & offset data
      nfb=length(obj.fbname);
      d = lcaGet(char(obj.gainoffpv),nfb*5) ;
      obj.gain = d(1:nfb) ;
      obj.offs = d(nfb+1:end) ;
      % Start data processing timer
      if ~isempty(obj.aobj)
        obj.ltr=timer('TimerFcn',@obj.apploop,'StopFcn',@obj.loopstop,'ExecutionMode','fixedDelay','StartDelay',1);
      else
        obj.ltr=timer('TimerFcn',@obj.fbloop,'StopFcn',@obj.loopstop,'ExecutionMode','fixedDelay','StartDelay',1);
      end
      start(obj.ltr);
    end
    function loopstop(obj)
      if ~obj.stoptmr
        fprintf(2,'Processing loop erroneously stopped... restarting...\n');
        start(obj.ltr);
      else
        disp('User commanded processing loop stop.\n');
      end
    end
    function apploop(obj)
      %APPLOOP main processing loop to keep GUI fields updated
      
      % - stop timer?
      if obj.stoptmr
        stop(obj.ltr);
        return
      end
      
      ifb = obj.fbname==obj.aobj.FeedbackDropDown.Value ;
      nm = obj.fbname(ifb) ;
      % - Feedback data
      t0=tic;
      while ~obj.GetData()
        if toc(t0)>obj.datato
          fprintf(2,'Timeout waiting for good new orbit fit data\n');
          obj.aobj.DataValidLamp.Color = 'red' ; drawnow;
          return
        end
      end
      [fbvalid,agevalid,numvalid,qvalid] = CheckData(obj) ;
      t0=tic;
      while ~fbvalid(ifb)
        if toc(t0)>obj.datato
          fprintf(2,'Timeout waiting for good new orbit fit data:\n');
          obj.aobj.DataValidLamp.Color = 'red' ; drawnow;
          if ~agevalid(ifb)
            fprintf(2,'Data age to old\n');
          end
          if ~numvalid(ifb)
            fprintf(2,'Invalid numbers from PVs\n');
          end
          if ~qvalid(ifb)
            fprintf(2,'BPM reported bunch charge too low\n');
          end
          return
        end
        [fbvalid,agevalid,numvalid,qvalid] = CheckData(obj) ;
      end
      obj.aobj.DataValidLamp.Color = 'green' ;
      obj.aobj.PosX.Value = obj.data.(nm).x * 1e3 ;
      obj.aobj.PosXP.Value = obj.data.(nm).xp * 1e3 ;
      obj.aobj.PosY.Value = obj.data.(nm).y * 1e3 ;
      obj.aobj.PosYP.Value = obj.data.(nm).yp * 1e3 ;
      % Enabled?
      obj.aobj.EnableCheckBox.Value = obj.fbon(ifb) ;
      % Gain
      obj.aobj.gainEditField.Value = obj.gain(ifb) ;
      % Model response info
      if obj.usemodel(ifb)
        obj.aobj.UseModel.Value = 1 ;
        obj.aobj.UseMeas.Value = 0 ;
      else
        obj.aobj.UseModel.Value = 0 ;
        obj.aobj.UseMeas.Value = 1 ;
      end
      obj.aobj.EditField_5.Value = datestr(datetime(real(ts),'ConvertFrom','posixtime')) ;
      % Data plots
      pltime = obj.aobj.PlotTime.Value ;
      kpv(1,1) = obj.fbcors(1,(ifb-1)*length(obj.fbname)*2+1); kpv(1,2) = obj.fbcors(1,(ifb-1)*length(obj.fbname)*2+2);
      kpv(2,1) = obj.fbcors(2,(ifb-1)*length(obj.fbname)*2+1); kpv(2,2) = obj.fbcors(2,(ifb-1)*length(obj.fbname)*2+2);
      x1 = obj.LLM.MagnetGet(kpv(1,1)); x2 = obj.LLM.MagnetGet(kpv(1,2));
      y1 = obj.LLM.MagnetGet(kpv(2,1)); y2 = obj.LLM.MagnetGet(kpv(2,2));
      vals = [obj.data.(nm).x*1e3 obj.data.(nm).xp*1e3 obj.data.(nm).y*1e3 obj.data.(nm).yp*1e3 x1 x2 y1 y2];
      if isempty(obj.pldata)
        obj.pldata.time = clock ;
        obj.pldata.data = vals ;
        return
      else
        obj.pldata.time(end+1,:) = clock ;
        obj.pldata.data(end+1,:) = vals ;
      end
      dt=etime(obj.pldata.time,obj.pldata.time(end,:));
      irm = dt<-pltime;
      if any(irm)
        obj.pldata.time(irm,:)=[];
        obj.pldata.data(irm,:)=[];
        dt(irm)=[];
      end
      plot(obj.aobj.xpl,dt,obj.pldata(:,1)) ;
      plot(obj.aobj.xppl,dt,obj.pldata(:,2)) ;
      plot(obj.aobj.ypl,dt,obj.pldata(:,3)) ;
      plot(obj.aobj.yppl,dt,obj.pldata(:,4)) ;
      plot(obj.aobj.x1pl,dt,obj.pldata(:,5)) ;
      plot(obj.aobj.x2pl,dt,obj.pldata(:,6)) ;
      plot(obj.aobj.y1pl,dt,obj.pldata(:,7)) ;
      plot(obj.aobj.y2pl,dt,obj.pldata(:,8)) ;
      drawnow;
    end
    function fbloop(obj)
      %FBLOOP main processing loop for feedback to operate
      global BEAMLINE
      
      % - stop timer?
      if obj.stoptmr
        stop(obj.ltr);
        return
      end
      
      t0=tic;
      while ~obj.GetData() || sum(obj.CheckData())==sum(obj.fbon)
        if toc(t0)>obj.datato
          error('Timeout waiting for good new orbit fit data');
        end
      end
      nfb=length(obj.fbname);
      for ifb=1:length(obj.fbname)
        if obj.fbon(ifb) && gd(ifb)
          kpv(1,1) = obj.fbcors(1,(ifb-1)*length(obj.fbname)*2+1); kpv(1,2) = obj.fbcors(1,(ifb-1)*length(obj.fbname)*2+2);
          kpv(2,1) = obj.fbcors(2,(ifb-1)*length(obj.fbname)*2+1); kpv(2,2) = obj.fbcors(2,(ifb-1)*length(obj.fbname)*2+2);
          if obj.usemodel(ifb)
            Ax = [ obj.modeldat.(obj.fbname(ifb)).R1x(1) obj.modeldat.(obj.fbname(ifb)).R2x(1) ;
                   obj.modeldat.(obj.fbname(ifb)).R1x(2) obj.modeldat.(obj.fbname(ifb)).R2x(2) ] ;
            Ay = [ obj.modeldat.(obj.fbname(ifb)).R1y(1) obj.modeldat.(obj.fbname(ifb)).R2y(1) ;
                   obj.modeldat.(obj.fbname(ifb)).R1y(2) obj.modeldat.(obj.fbname(ifb)).R2y(2) ] ;
          else
            Ax = [ obj.exptdat.(obj.fbname(ifb)).kpv(1,1).x  obj.exptdat.(obj.fbname(ifb)).kpv(1,2).x  ;
                   obj.exptdat.(obj.fbname(ifb)).kpv(1,1).xp obj.exptdat.(obj.fbname(ifb)).kpv(1,2).xp ] ;
            Ay = [ obj.exptdat.(obj.fbname(ifb)).kpv(2,1).y  obj.exptdat.(obj.fbname(ifb)).kpv(2,2).y  ;
                   obj.exptdat.(obj.fbname(ifb)).kpv(2,1).yp obj.exptdat.(obj.fbname(ifb)).kpv(2,2).yp ] ;
          end
          d=obj.data.(obj.fbname(ifb));
          Cx = Ax \ -([d.x;d.xp]-[obj.offs((ifb-1)*nfb+1); obj.offs(ifb-1)*nfb+2] ) ;
          Cy = Ay \ -([d.y;d.yp]-[obj.offs((ifb-1)*nfb+3); obj.offs(ifb-1)*nfb+4] ) ;
          cop=physConsts.clight/(BEAMLINE{obj.fbloc_ind(ifb)}.P*1e9);
          bdes_x = obj.gain(ifb).*Cx./cop ; bdes_y = obj.gain(ifb).*Cy./cop ;
          if any(abs(bdes_x)>obj.cc_kick)
            warning('F2_TFeedbackApp:largeKick','(%s,%s) X kick exceeds recommended step size, skipping',kpv(1,1),kpv(1,2));
            continue
          end
          if any(abs(bdes_y)>obj.cc_kick)
            warning('F2_TFeedbackApp:largeKick','(%s,%s) Y kick exceeds recommended step size, skipping',kpv(2,1),kpv(2,2));
            continue
          end
          x1 = obj.LLM.MagnetGet(kpv(1,1)); x2 = obj.LLM.MagnetGet(kpv(1,2));
          y1 = obj.LLM.MagnetGet(kpv(2,1)); y2 = obj.LLM.MagnetGet(kpv(2,2));
%           control_magnetSet(kpv(1,1),x1+bdes_x(1)); control_magnetSet(kpv(1,2),x2+bdes_x(2));
%           control_magnetSet(kpv(2,1),y1+bdes_y(1)); control_magnetSet(kpv(2,2),y2+bdes_y(2));
          fprintf('%s -> %g\n',kpv(1,1),x1+bdes_x(1));
          fprintf('%s -> %g\n',kpv(1,2),x2+bdes_x(2));
          fprintf('%s -> %g\n',kpv(2,1),y1+bdes_y(1));
          fprintf('%s -> %g\n',kpv(1,2),y2+bdes_y(2));
        end
      end
    end
    function [fbvalid,agevalid,numvalid,qvalid] = CheckData(obj)
      %CHECKDATA Check data quality from EPICS PVs
      persistent agepv
      
      % - Check input data age
      if isempty(agepv)
        a=structfun(@(x) x,obj.pospv);
        agepv=[a.x;a.xp;a.y;a.yp;a.de;a.valid]; agepv=cellstr(agepv(:)+"TS");
        lcaSetMonitor(agepv);
      end
      dn = now ;
      if any(lcaNewMonitorValue(agepv)) || isempty(obj.lastTS)
        obj.lastTS=datenum(lcaGet(agepv));
      end
      age = (dn-obj.lastTS).*86400 ;
      isvalid = age<obj.maxage ;
      fbvalid = false(1,length(obj.fbname)) ;
      for ifb=1:length(obj.fbname)
        fbvalid(ifb) = all(isvalid((ifb-1)*6 + 1:6)) ;
        agevalid.(obj.fbname(ifb)).x     = isvalid((ifb-1)*6 + 1) ;
        agevalid.(obj.fbname(ifb)).xp    = isvalid((ifb-1)*6 + 2) ;
        agevalid.(obj.fbname(ifb)).y     = isvalid((ifb-1)*6 + 3) ;
        agevalid.(obj.fbname(ifb)).yp    = isvalid((ifb-1)*6 + 4) ;
        agevalid.(obj.fbname(ifb)).de    = isvalid((ifb-1)*6 + 5) ;
        agevalid.(obj.fbname(ifb)).valid = isvalid((ifb-1)*6 + 6) ;
      end
      
      % Check number data validity (no infs, nans and within ranges)
      a=structfun(@(x) x,obj.data); d=[a.x;a.xp;a.y;a.yp];
      for ifb=1:length(obj.fbname)
        fbvalid(ifb) = fbvalid(ifb) & all([~isinf(d((ifb-1)*6 + 1:5)); ~isnan(d((ifb-1)*6 + 1:5)); abs(d((ifb-1)*6 + 1:5))<[obj.posmax;obj.angmax;obj.posmax;obj.angmax;obj.demax]]) ;
        numvalid.(obj.fbname(ifb)).x  = ~isinf(d((ifb-1)*6 + 1)) & ~isnan(d((ifb-1)*6 + 1)) & abs(d((ifb-1)*6 + 1))<obj.posmax ;
        numvalid.(obj.fbname(ifb)).xp = ~isinf(d((ifb-1)*6 + 2)) & ~isnan(d((ifb-1)*6 + 2)) & abs(d((ifb-1)*6 + 2))<obj.angmax ;
        numvalid.(obj.fbname(ifb)).y  = ~isinf(d((ifb-1)*6 + 3)) & ~isnan(d((ifb-1)*6 + 3)) & abs(d((ifb-1)*6 + 3))<obj.posmax ;
        numvalid.(obj.fbname(ifb)).yp = ~isinf(d((ifb-1)*6 + 4)) & ~isnan(d((ifb-1)*6 + 4)) & abs(d((ifb-1)*6 + 4))<obj.angmax ;
        numvalid.(obj.fbname(ifb)).de = ~isinf(d((ifb-1)*6 + 5)) & ~isnan(d((ifb-1)*6 + 5)) & abs(d((ifb-1)*6 + 5))<obj.demax ;
      end
      
      % Check bunch charge
      q = lcaGet(cellstr(obj.qpv(:))) ;
      qvalid = q>obj.qmin ;
      fbvalid=fbvalid & qvalid ;
      
    end
    function suc = GetData(obj)
      pvs=[];
      suc=false;
      for ifb=1:length(obj.fbname)
        if obj.fbon(ifb)
          pvs=[pvs;structfun(@(x) x,obj.pospv.(obj.fbname(ifb)))];
        end
      end
      if ~all(lcaNewMonitorValue(pvs))
        return
      end
      d=lcaGet(cellstr(pvs(:)));
      for ifb=1:length(obj.fbname)
        if obj.fbon(ifb)
          obj.data.(obj.fbname(ifb)).x     = d((ifb-1)*6 + 1) * 1e-3 ;
          obj.data.(obj.fbname(ifb)).xp    = d((ifb-1)*6 + 2) * 1e-3 ;
          obj.data.(obj.fbname(ifb)).y     = d((ifb-1)*6 + 3) * 1e-3 ;
          obj.data.(obj.fbname(ifb)).yp    = d((ifb-1)*6 + 4) * 1e-3 ;
          obj.data.(obj.fbname(ifb)).de    = d((ifb-1)*6 + 5) * 1e-3 ;
          obj.data.(obj.fbname(ifb)).valid = d((ifb-1)*6 + 6) * 1e-3 ;
        end
      end
    end
    function GetModelResp(obj,getall)
      %GETMODELRESP Get model-based linear responses kickers to FB location
      global BEAMLINE
      if ~exist('getall','var')
        getall=false;
      end
      um=obj.usemodel;
      if getall; um=true(size(um)); end
      for ifb=find(um(:)')
        if isempty(obj.modeldat) || ~isfield(obj.modeldat,obj.fbname(ifb))
          for icor=1:2
            i2=findcells(BEAMLINE,'Name',char(obj.fbloc(ifb)));
            i1=findcells(BEAMLINE,'Name',char(obj.fbcors(1,(ifb-1)*2+1))); obj.modeldat.(obj.fbname(ifb)).inds1x = [i1 i2] ;
            i1=findcells(BEAMLINE,'Name',char(obj.fbcors(1,(ifb-1)*2+2))); obj.modeldat.(obj.fbname(ifb)).inds2x = [i1 i2] ;
            i1=findcells(BEAMLINE,'Name',char(obj.fbcors(2,(ifb-1)*2+1))); obj.modeldat.(obj.fbname(ifb)).inds1y = [i1 i2] ;
            i1=findcells(BEAMLINE,'Name',char(obj.fbcors(2,(ifb-1)*2+2))); obj.modeldat.(obj.fbname(ifb)).inds2y = [i1 i2] ;
          end
        end
        [~,R]=RmatAtoB(obj.modeldat.(obj.fbname(ifb)).inds1x(1),obj.modeldat.(obj.fbname(ifb)).inds1x(2)); obj.modeldat.(obj.fbname(ifb)).R1x = [R(1,2), R(2,2)] ;
        [~,R]=RmatAtoB(obj.modeldat.(obj.fbname(ifb)).inds2x(1),obj.modeldat.(obj.fbname(ifb)).inds2x(2)); obj.modeldat.(obj.fbname(ifb)).R2x = [R(1,2), R(2,2)] ;
        [~,R]=RmatAtoB(obj.modeldat.(obj.fbname(ifb)).inds1y(1),obj.modeldat.(obj.fbname(ifb)).inds1y(2)); obj.modeldat.(obj.fbname(ifb)).R1y = [R(3,4), R(4,4)] ;
        [~,R]=RmatAtoB(obj.modeldat.(obj.fbname(ifb)).inds2y(1),obj.modeldat.(obj.fbname(ifb)).inds2y(2)); obj.modeldat.(obj.fbname(ifb)).R2y = [R(3,4), R(4,4)] ;
      end
    end
    function suc = GetExpResp(obj,fbsel,corsel,dimsel)
      %GETEXPRESP Get experimental response data from Live machine
      global BEAMLINE
      
      suc=false;
      
      if ~exist('fbsel','var')
        fbsel=find(obj.fbon);
      end
      if ~exist('corsel','var')
        corsel=1:2;
      end
      if ~exist('dimsel','var')
        dimsel=1:2;
      end
      if isempty(fbsel)
        return
      end
      
      % Get kick vs. reconstructed orbit data
      for ifb=fbsel
        if ~obj.fbon(ifb); continue; end
        kpv(1,1) = obj.fbcors(1,(ifb-1)*length(obj.fbname)*2+1); kpv(1,2) = obj.fbcors(1,(ifb-1)*length(obj.fbname)*2+2);
        kpv(2,1) = obj.fbcors(2,(ifb-1)*length(obj.fbname)*2+1); kpv(2,2) = obj.fbcors(2,(ifb-1)*length(obj.fbname)*2+2);
        cop=physConsts.clight/(BEAMLINE{obj.fbloc_ind(ifb)}.P*1e9);
        kick_dbdes = linspace(-obj.cc_kick/cop,obj.cc_kick/cop,obj.cc_ndat(2)) ;
        ic = randperm(obj.cc_ndat(2)) ; dims='xy';
        for idim=dimsel
          for kno=corsel
            k0 = obj.LLM.MagnetGet(kpv(idim,kno)) ;
            try
              xdat=zeros(obj.cc_ndat(2),obj.cc_ndat(1)); ydat=xdat; xpdat=xdat; ypdat=xdat;
              for ikick=1:obj.cc_ndat(2)
                if obj.verbose; fprintf('Calibrating %s: set %s (%c) -> %g and take data...\n',obj.fbname(ifb),kpv(idim,kno),dims(idim),k0+kick_dbdes(ic(ikick))); end
                control_magnetSet(kpv(idim,kno),k0+kick_dbdes(ic(ikick))) ;
                for idat=1:obj.cc_ndat(1)
                  t0=tic;
                  while ~obj.GetData() || sum(obj.CheckData())==sum(obj.fbon)
                    if toc(t0)>obj.datato
                      error('Timeout waiting for good new orbit fit data for FB: %s',obj.fbname(ifb));
                    end
                  end
                  odat.(obj.fbname(ifb)).x(idim,kno,idat)  = obj.data.(obj.fbname(ifb)).x ;
                  odat.(obj.fbname(ifb)).xp(idim,kno,idat) = obj.data.(obj.fbname(ifb)).xp ;
                  odat.(obj.fbname(ifb)).y(idim,kno,idat)  = obj.data.(obj.fbname(ifb)).y ;
                  odat.(obj.fbname(ifb)).yp(idim,kno,idat) = obj.data.(obj.fbname(ifb)).yp ;
                  xdat(ikick,idat) = obj.data.(obj.fbname(ifb)).x ;
                  xpdat(ikick,idat) = obj.data.(obj.fbname(ifb)).xp ;
                  ydat(ikick,idat) = obj.data.(obj.fbname(ifb)).y ;
                  ypdat(ikick,idat) = obj.data.(obj.fbname(ifb)).yp ;
                end
                % GUI plotting
                if ~isempty(obj.aobj) && ~isempty(app.aobj.calobj) && ishandle(app.aobj.calobj)
                  h=app.aobj.calobj;
                  if h.DisplayDropDown.Value==1
                    xv=kick_dbdes(ic(1:ikick))*cop;
                  else
                    xv=kick_dbdes(ic(1:ikick));
                  end
                  plot(h.xpl,xv,xdat(1:ikick,:),'*');
                  plot(h.xppl,xv,xpdat(1:ikick,:),'*');
                  plot(h.ypl,xv,ydat(1:ikick,:),'*');
                  plot(h.yppl,xv,ypdat(1:ikick,:),'*');
                  drawnow;
                end
              end
            catch ME
              fprintf(2,'Error during calibration (%s), restoring corrector to original setting\n%s',obj.fbname(ifb),ME.message);
              control_magnetSet(kpv(idim,kno),k0);
              return
            end
            control_magnetSet(kpv(idim,kno),k0);
            if ~isempty(obj.aobj) && ~isempty(app.aobj.calobj) && ishandle(app.aobj.calobj)
              plot_polyfit(h.xpl);
              [q,dq]=plot_polyfit(kick_dbdes(ic),mean(xdat,2),std(xdat,[],2),2); slopes.(obj.fbname(ifb)).(kpv(idim,kno)).x=q(end); slopes.(obj.fbname(ifb)).(kpv(idim,kno)).dx=dq(end);
              plot_polyfit(h.xppl);
              [q,dq]=plot_polyfit(kick_dbdes(ic),mean(xpdat,2),std(xpdat,[],2),2); slopes.(obj.fbname(ifb)).(kpv(idim,kno)).xp=q(end); slopes.(obj.fbname(ifb)).(kpv(idim,kno)).dxp=dq(end);
              plot_polyfit(h.ypl);
              [q,dq]=plot_polyfit(kick_dbdes(ic),mean(ydat,2),std(ydat,[],2),2); slopes.(obj.fbname(ifb)).(kpv(idim,kno)).y=q(end); slopes.(obj.fbname(ifb)).(kpv(idim,kno)).dy=dq(end);
              plot_polyfit(h.yppl);
              [q,dq]=plot_polyfit(kick_dbdes(ic),mean(ypdat,2),std(ypdat,[],2),2); slopes.(obj.fbname(ifb)).(kpv(idim,kno)).yp=q(end); slopes.(obj.fbname(ifb)).(kpv(idim,kno)).dyp=dq(end);
              drawnow;
            else
              [q,dq]=noplot_polyfit(kick_dbdes(ic),mean(xdat,2),std(xdat,[],2),2); slopes.(obj.fbname(ifb)).(kpv(idim,kno)).x=q(end); slopes.(obj.fbname(ifb)).(kpv(idim,kno)).dx=dq(end);
              [q,dq]=noplot_polyfit(kick_dbdes(ic),mean(xpdat,2),std(xpdat,[],2),2); slopes.(obj.fbname(ifb)).(kpv(idim,kno)).xp=q(end); slopes.(obj.fbname(ifb)).(kpv(idim,kno)).dxp=dq(end);
              [q,dq]=noplot_polyfit(kick_dbdes(ic),mean(ydat,2),std(ydat,[],2),2); slopes.(obj.fbname(ifb)).(kpv(idim,kno)).y=q(end); slopes.(obj.fbname(ifb)).(kpv(idim,kno)).dy=dq(end);
              [q,dq]=noplot_polyfit(kick_dbdes(ic),mean(ypdat,2),std(ypdat,[],2),2); slopes.(obj.fbname(ifb)).(kpv(idim,kno)).yp=q(end); slopes.(obj.fbname(ifb)).(kpv(idim,kno)).dyp=dq(end);
            end
          end
        end
      end
      if obj.verbose; fprintf('Calibration data taking complete, publishing results...\n'); end
      suc=true;
      pvdat=lcaGet(obj.fbcoefpv,length(obj.fbname)*16);
      slopes=obj.exptdat;
      for ifb=fbsel
        if ismember(1,dimsel)
          if ismember(1,corsel)
            pvdat((ifb-1)*16+1)  = slopes(obj.fbname(ifb)).(kpv(1,1)).x  ;
            pvdat((ifb-1)*16+5)  = slopes(obj.fbname(ifb)).(kpv(1,1)).xp ;
            pvdat((ifb-1)*16+9)  = slopes(obj.fbname(ifb)).(kpv(1,1)).y  ;
            pvdat((ifb-1)*16+13) = slopes(obj.fbname(ifb)).(kpv(1,1)).yp ;
          end
          if ismember(2,corsel)
            pvdat((ifb-1)*16+2)  = slopes(obj.fbname(ifb)).(kpv(1,2)).x  ;
            pvdat((ifb-1)*16+6)  = slopes(obj.fbname(ifb)).(kpv(1,2)).xp ;
            pvdat((ifb-1)*16+10) = slopes(obj.fbname(ifb)).(kpv(1,2)).y ;
            pvdat((ifb-1)*16+14) = slopes(obj.fbname(ifb)).(kpv(1,2)).yp ;
          end
        end
        if ismember(2,dimsel)
          if ismember(1,corsel)
            pvdat((ifb-1)*16+3)  = slopes(obj.fbname(ifb)).(kpv(2,1)).x  ;
            pvdat((ifb-1)*16+7)  = slopes(obj.fbname(ifb)).(kpv(2,1)).xp ;
            pvdat((ifb-1)*16+11) = slopes(obj.fbname(ifb)).(kpv(2,1)).y  ;
            pvdat((ifb-1)*16+15) = slopes(obj.fbname(ifb)).(kpv(2,1)).yp ;
          end
          if ismember(2,corsel)
            pvdat((ifb-1)*16+4)  = slopes(obj.fbname(ifb)).(kpv(2,2)).x  ;
            pvdat((ifb-1)*16+8)  = slopes(obj.fbname(ifb)).(kpv(2,2)).xp ;
            pvdat((ifb-1)*16+12) = slopes(obj.fbname(ifb)).(kpv(2,2)).y  ;
            pvdat((ifb-1)*16+16) = slopes(obj.fbname(ifb)).(kpv(2,2)).yp ;
          end
        end
      end
      lcaPut(obj.fbcoefpv,pvdat(:));
      obj.exptdat=slopes;
    end
    function delete(obj)
      if ~isempty(obj.ltr)
        obj.ltr.stop;
      end
    end
  end
  methods % get/set
    function set.gain(obj,vals)
      obj.gain=vals;
      lcaPut(char(obj.gainoffpv),[vals(:);obj.offs(:)]);
    end
    function set.offs(obj,vals)
      obj.offs=vals;
      lcaPut(char(obj.gainoffpv),[obj.gain(:);vals(:)]);
    end
    function set.fbon(obj,vals)
      obj.fbon=vals;
      lcaPut(char(obj.fbonpv),vals);
    end
    function set.usemodel(obj,vals)
      obj.usemodel=vals;
      lcaPut(char(obj.usemodelpv),double(vals));
      obj.GetModelResp();
    end
  end
end