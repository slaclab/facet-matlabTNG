classdef F2_OrbitApp < handle & F2_common
  properties
    BPMS % Storage for F2_bpms object
    aobj % Storage for GUI application object
    LM % LucretiaModel object
    LiveModel % LiveModel object
    bpmid uint16 % Master list of BPM IDs
    xcorid uint16 % Master list of x corrector IDs
    ycorid uint16 % Master list of y corrector IDs
    usebpm logical % Selection (from master list) of BPMs to use
    usexcor logical % Selection (from master list) of XCORs to use
    useycor logical % Selection (from master list) of YCORs to use
    bpmnames string % master list of names
    xcornames string % master list of names
    ycornames string % master list of names
    bpmcnames string % master list of control names
    xcorcnames string % master list of control names
    ycorcnames string % master list of control names
    xcorpv % x corrector EPICS BDES PV
    ycorpv % y corrector EPICS BDES PV
    xcormaxpv % x corrector EPICS BDES PV (BMAX)
    ycormaxpv % y corrector EPICS BDES PV (BMAX)
    badbpms logical % flag 'bad' BPMS (no controls or known bad)
    badxcors logical
    badycors logical
    RM % Response matrices X/YCOR -> BPMS [2*nbpm,ncor]
    corsolv string {mustBeMember(corsolv,["lscov","pinv","lsqminnorm"])} = "lscov" % solver to use for orbit correction
    solvtol % tolerance for orbit solution QR factorization tolerance (only use if set)
    usex logical = true % apply x corrections when asked?
    usey logical = true % apply y corrections when asked?
  end
  properties(SetAccess=private)
    cordat_x % XCOR data
    cordat_y % YCOR data
    dtheta_x % calculated x corrector kicks (rad)
    dtheta_y % calculated y corrector kicks (rad)
    xbpm_cor % calculated corrected x bpm vals (mm)
    ybpm_cor % calculated corrected y bpm vals (mm)
  end
  properties(SetObservable)
    UseRegion(1,11) logical = true(1,11) % ["INJ";"L0";"DL1";"L1";"BC11";"L2";"BC14";"L3";"BC20";"FFS";"SPECTDUMP"]
    calcperformed logical =false
  end
  methods
    function obj = F2_OrbitApp(appobj)
      addpath('F2_LiveModel');
      obj.LiveModel = F2_LiveModelApp ;
      obj.BPMS = F2_bpms(copy(obj.LiveModel.LM)) ;
      if exist('appobj','var')
        obj.aobj = appobj ;
      end
      obj.LM=copy(obj.BPMS.LM); % local copy of LucretiaModel
      obj.LM.UseMissingEle = true ; % don't return info about missing correctors
      obj.LM.ModelClasses="MONI";
      obj.bpmid = obj.LM.ModelID ;
      obj.LM.ModelClasses="XCOR";
      obj.xcorid = obj.LM.ModelID ;
      obj.LM.ModelClasses="YCOR";
      obj.ycorid = obj.LM.ModelID ;
      obj.usebpm = true(size(obj.bpmid)) ;
      obj.usexcor = true(size(obj.xcorid)) ;
      obj.useycor = true(size(obj.ycorid)) ;
      % Flag elements without control names as not in use
      obj.LM.ModelClasses="MONI";
      obj.bpmnames = obj.LM.ModelNames ;
      obj.bpmcnames = obj.LM.ControlNames ;
      obj.badbpms = false(size(obj.bpmid)) ;
      obj.badbpms(obj.LM.ModelNames==obj.LM.ControlNames)=true;
      obj.badbpms(ismember(obj.bpmnames,obj.BPMS.badbpms))=true;
      obj.usebpm(obj.badbpms) = false ;
      obj.xbpm_cor=zeros(size(obj.bpmnames));
      obj.ybpm_cor=zeros(size(obj.bpmnames));
      obj.LM.ModelClasses="XCOR";
      obj.xcornames = obj.LM.ModelNames ;
      obj.xcorcnames = obj.LM.ControlNames ;
      obj.badxcors = false(size(obj.xcorid)) ;
      obj.badxcors(obj.LM.ModelNames==obj.LM.ControlNames)=true;
      obj.usexcor(obj.badxcors) = false ;
      for icor=1:length(obj.xcorcnames)
        obj.xcorpv{icor,1} = char(obj.xcorcnames(icor)+":BDES");
        obj.xcormaxpv{icor,1} = char(obj.xcorcnames(icor)+":BMAX");
      end
      obj.dtheta_x=zeros(size(obj.xcornames));
      obj.LM.ModelClasses="YCOR";
      obj.ycornames = obj.LM.ModelNames ;
      obj.ycorcnames = obj.LM.ControlNames ;
      obj.badycors = false(size(obj.ycorid)) ;
      obj.badycors(obj.LM.ModelNames==obj.LM.ControlNames)=true;
      obj.useycor(obj.badycors) = false ;
      for icor=1:length(obj.ycorcnames)
        obj.ycorpv{icor,1} = char(obj.ycorcnames(icor)+":BDES");
        obj.ycormaxpv{icor,1} = char(obj.ycorcnames(icor)+":BMAX");
      end
      obj.dtheta_y=zeros(size(obj.ycornames));
    end
    function acquire(obj,npulse)
      %ACQUIRE Get bpm and corrector data
      %acquire(npulse)
      global BEAMLINE
      % BPM data:
      obj.BPMS.readbuffer(npulse);
      obj.usebpm=false(size(obj.usebpm));
      obj.LM.ModelClasses="MONI";
      obj.usebpm(~obj.badbpms & ismember(obj.bpmid,obj.LM.ModelID)) = true ;
      if ~isempty(obj.BPMS.readid)
        obj.usebpm(~ismember(obj.bpmid,obj.BPMS.readid))=false;
      end
      % Corrector data:
      obj.LM.ModelClasses="XCOR";
      id = obj.xcorid ; 
      obj.cordat_x.z = arrayfun(@(x) BEAMLINE{x}.Coordi(3),id) ;
      xv = lcaGet(obj.xcorpv) ; % BDES / kGm
      xvmax = lcaGet(obj.xcormaxpv) ; % BDES / kGm
      P = arrayfun(@(x) BEAMLINE{x}.P,id) ;
      xv = xv ./ obj.LM.GEV2KGM ./ P(:) ; % kick angle
      xvmax = xvmax ./ obj.LM.GEV2KGM ./ P(:) ; % kick angle
      obj.cordat_x.theta = xv ;
      obj.cordat_x.thetamax = xvmax ;
      obj.LM.ModelClasses="YCOR";
      id = obj.ycorid ; 
      obj.cordat_y.z = arrayfun(@(x) BEAMLINE{x}.Coordi(3),id) ;
      yv = lcaGet(obj.ycorpv) ; % BDES / kGm
      yvmax = lcaGet(obj.ycormaxpv) ; % BDES / kGm
      P = arrayfun(@(x) BEAMLINE{x}.P,id) ;
      yv = yv ./ obj.LM.GEV2KGM ./ P(:); % kick angle
      yvmax = yvmax ./ obj.LM.GEV2KGM ./ P(:); % kick angle
      obj.cordat_y.theta=yv;
      obj.cordat_y.thetamax=yvmax;
      obj.calcperformed=false;
    end
    function plotqrtol(obj)
      %PLOTQRTOL Show factorization data for response matrix to estimate tolerance to use in correction

      obj.getr;
      A = obj.RM;
      [~,R] = qr(A,0);
      figure
      semilogy(abs(diag(R)),'o')
    end
    function corcalc(obj)
      %CORCALC Calculate orbit correction and store calculation values
      if isempty(obj.BPMS.xdat)
        error('No BPM data taken');
      end
      % Get orbit to correct
      id = ismember(obj.BPMS.readid,obj.bpmid(obj.usebpm)) ;
      xm = mean(obj.BPMS.xdat(id,:),2,'omitnan').*1e-3 ;
      ym = mean(obj.BPMS.ydat(id,:),2,'omitnan').*1e-3 ;
      xstd = std(obj.BPMS.xdat(id,:),[],2,'omitnan').*1e-3 ;
      ystd = std(obj.BPMS.ydat(id,:),[],2,'omitnan').*1e-3 ;
      % Form response matrix and correction vectors
      obj.getr;
      A = obj.RM ;
      B = -[xm(:); ym(:)] ;
      W = [xstd(:); ystd(:)] ;
      % Generate solution for required corrector kicks (in radians) with requested solver
      switch obj.corsolv
        case "lscov"
          dcor = lscov(A,B,W) ;
        case "pinv"
          dcor = pinv(A)*B ;
        case "lsqminnorm"
          if ~isempty(obj.solvtol)
            dcor = lsqminnorm(A,B,obj.solvtol) ;
          else
            dcor = lsqminnorm(A,B) ;
          end
      end
      % Store correction kicks and expected BPM response
      obj.dtheta_x(obj.usexcor) = dcor(1:sum(obj.usexcor)) ;
      obj.dtheta_y(obj.useycor) = dcor(1+sum(obj.usexcor):end) ;
      bpm_cor = [xm(:); ym(:)] + A*dcor ;
      obj.xbpm_cor(obj.usebpm) = 1e3.*bpm_cor(1:sum(obj.usebpm)) ;
      obj.ybpm_cor(obj.usebpm) = 1e3.*bpm_cor(1+sum(obj.usebpm):end) ;
      obj.calcperformed=true;
      if ~isempty(obj.aobj)
        obj.aobj.updateplots; % update plots
      end
    end
    function applycalc(obj)
      %APPLYCALC Set corrector magnets using calculated orbit steering data
      global BEAMLINE
      if ~obj.calcperformed
        error('Calculation not performed');
      end
      if obj.usex
        obj.LM.ModelClasses="XCOR";
        id = obj.xcorid(obj.usexcor) ;
        bdes1 = lcaGet(obj.xcorpv(obj.usexcor)) ; % BDES / kGm
        bmax = lcaGet(obj.xcormaxpv(obj.usexcor)) ; % BDES / kGm
        P = arrayfun(@(x) BEAMLINE{x}.P,id) ;
        bdes = bdes1 + obj.dtheta_x(obj.usexcor).*obj.LM.GEV2KGM.*P(:) ;
        xcpv = obj.xcorcnames(obj.usexcor) + "//BDES" ;
        for icor=1:length(xcpv)
          fprintf('AIDAPUT: %s = %g -> %g',xcpv(icor),bdes1(icor),bdes(icor));
          if abs(bdes(icor))>bmax(icor)
            fprintf(' !!!!!! exceeds BMAX=%g\n',bmax(icor));
          else
            fprintf('\n');
          end
  %         obj.aidaput(char(xcpv(icor)),bdes(icor));
        end
      end
      if obj.usey
        obj.LM.ModelClasses="YCOR";
        id = obj.ycorid(obj.useycor) ;
        bdes1 = lcaGet(obj.ycorpv(obj.useycor)) ; % BDES / kGm
        bmax = lcaGet(obj.ycormaxpv(obj.useycor)) ; % BDES / kGm
        P = arrayfun(@(x) BEAMLINE{x}.P,id) ;
        bdes = bdes1 + obj.dtheta_y(obj.useycor).*obj.LM.GEV2KGM.* P(:) ;
        ycpv = obj.ycorcnames(obj.useycor) + "//BDES" ;
        for icor=1:length(ycpv)
          fprintf('AIDAPUT: %s = %g -> %g',ycpv(icor),bdes1(icor),bdes(icor));
          if abs(bdes(icor))>bmax(icor)
            fprintf(' !!!!!! exceeds BMAX=%g\n',bmax(icor));
          else
            fprintf('\n');
          end
  %         obj.aidaput(char(ycpv(icor)),bdes(icor));
        end
      end
      obj.calcperformed=false;
    end
    function getr(obj)
      %GETR Get model response matrices between correctors and BPMs
      ixc = double(obj.xcorid(obj.usexcor)) ;
      iyc = double(obj.ycorid(obj.useycor)) ;
      ibpm = double(obj.bpmid(obj.usebpm)) ;
      icor=[ixc iyc];
      obj.RM = zeros(2*length(ibpm),length(icor));
      for ncor=1:length(icor)
        for nbpm=1:length(ibpm)
          if ibpm(nbpm)>icor(ncor)
            [~,R]=RmatAtoB(icor(ncor),ibpm(nbpm));
            if ismember(icor(ncor),ixc) % XCOR
              obj.RM(nbpm,ncor) = R(1,2) ;
              obj.RM(nbpm+length(ibpm),ncor) = R(3,2) ;
            else % YCOR
              obj.RM(nbpm,ncor) = R(1,4) ;
              obj.RM(nbpm+length(ibpm),ncor) = R(3,4) ;
            end
          end
        end
      end
    end
    function set.UseRegion(obj,val)
      obj.UseRegion=val;
      obj.LM.UseRegion=val;
      obj.usebpm = false(size(obj.bpmid)) ;
      obj.usexcor = false(size(obj.xcorid)) ;
      obj.useycor = false(size(obj.ycorid)) ;
      obj.LM.ModelClasses="MONI";
      obj.usebpm=false(size(obj.usebpm));
      obj.usebpm(~obj.badbpms & ismember(obj.bpmid,obj.LM.ModelID)) = true ;
      if ~isempty(obj.BPMS.readid)
        obj.usebpm(~ismember(obj.bpmid,obj.BPMS.readid))=false;
      end
      obj.LM.ModelClasses="XCOR";
      obj.usexcor(~obj.badxcors & ismember(obj.xcorid,obj.LM.ModelID)) = true ;
      obj.LM.ModelClasses="YCOR";
      obj.useycor(~obj.badycors & ismember(obj.ycorid,obj.LM.ModelID)) = true ;
      obj.calcperformed=false;
    end
    function set.calcperformed(obj,val)
      if ~isempty(obj.aobj)
        if val
          obj.aobj.DoCorrectionButton.Enable=true;
        else
          obj.aobj.DoCorrectionButton.Enable=false;
        end
      end
      obj.calcperformed=val;
    end
    function plotcor(obj,ahan)
      %PLOTCOR Plot corrector values and propose new corrector values
      %plotcor([axisHandle_x axisHandle_y])
      
      if isempty(obj.cordat_x)
        return
      end
      
      % Make new axes if not supplied
      if ~exist('ahan','var') || isempty(ahan)
        figure
        ahan(1)=subplot(2,1,1);
        ahan(2)=subplot(2,1,2);
      end
      
      % Plot extant corrector kick values
      stem(ahan(1),obj.cordat_x.z(obj.usexcor),obj.cordat_x.theta(obj.usexcor));
      xlabel(ahan(1),'Z [m]'); ylabel(ahan(1),'XCOR \theta_x [rad]');
      grid(ahan(1),'on');
      ahan(1).XLim(2)=max(obj.cordat_x.z(obj.usexcor));
      stem(ahan(2),obj.cordat_y.z(obj.useycor),obj.cordat_y.theta(obj.useycor));
      xlabel(ahan(2),'Z [m]'); ylabel(ahan(2),'YCOR \theta_y [rad]');
      grid(ahan(2),'on');
      ahan(2).XLim(2)=max(obj.cordat_y.z(obj.useycor));
      
      % If calculated, superimpose new kick values proposed
      if obj.calcperformed
        newtheta_x = obj.cordat_x.theta(obj.usexcor)+obj.dtheta_x(obj.usexcor) ;
        newtheta_y = obj.cordat_y.theta(obj.useycor)+obj.dtheta_y(obj.useycor) ;
        hold(ahan(1),'on');
        stem(ahan(1),obj.cordat_x.z(obj.usexcor),newtheta_x);
        hold(ahan(1),'off');
        hold(ahan(2),'on');
        stem(ahan(2),obj.cordat_y.z(obj.useycor),newtheta_y);
        hold(ahan(2),'off');
      end
      
      % Plot min/max values if any of the correctors are close
      if any(obj.cordat_x.theta(obj.usexcor)./obj.cordat_x.thetamax(obj.usexcor) > 0.9) || ...
          obj.calcperformed && any(newtheta_x./obj.cordat_x.thetamax(obj.usexcor) > 0.9)
        hold(ahan(1),'on');
        plot(ahan(1),obj.cordat_x.z(obj.usexcor),obj.cordat_x.thetamax(obj.usexcor),'k--');
        hold(ahan(1),'off');
      end
      if any(obj.cordat_x.theta(obj.usexcor)./obj.cordat_x.thetamax(obj.usexcor) < -0.9) || ...
          obj.calcperformed && any(newtheta_x./obj.cordat_x.thetamax(obj.usexcor) < -0.9)
        hold(ahan(1),'on');
        plot(ahan(1),obj.cordat_x.z(obj.usexcor),-obj.cordat_x.thetamax(obj.usexcor),'k--');
        hold(ahan(1),'off');
      end
      if any(obj.cordat_y.theta(obj.useycor)./obj.cordat_y.thetamax(obj.useycor) > 0.9) || ...
          obj.calcperformed && any(newtheta_y./obj.cordat_y.thetamax(obj.useycor) > 0.9)
        hold(ahan(2),'on');
        plot(ahan(2),obj.cordat_y.z(obj.useycor),obj.cordat_y.thetamax(obj.useycor),'k--');
        hold(ahan(2),'off');
      end
      if any(obj.cordat_y.theta(obj.useycor)./obj.cordat_y.thetamax(obj.useycor) < -0.9) || ...
          obj.calcperformed && any(newtheta_y./obj.cordat_y.thetamax(obj.useycor) < -0.9)
        hold(ahan(2),'on');
        plot(ahan(2),obj.cordat_y.z(obj.useycor),-obj.cordat_y.thetamax(obj.useycor),'k--');
        hold(ahan(2),'off');
      end
      
    end
    function plotbpm(obj,ahan)
      %PLOTBPM Plot BPM averaged orbit
      %plotbpm()
      %  Plot on new figure window
      %plotbpm([axisHandle1 , axisHandle2])
      %  Plot on provided axis handles (for [x y])
      global BEAMLINE
      if isempty(obj.BPMS.xdat)
        error('No data to plot')
      end
      use=ismember(obj.BPMS.readid,obj.bpmid(obj.usebpm));
      if ~any(use)
        error('No Data to plot');
      end
      if ~exist('ahan','var') || isempty(ahan)
        figure
        ahan(1)=subplot(2,1,1);
        ahan(2)=subplot(2,1,2);
      end
      xm = mean(obj.BPMS.xdat,2,'omitnan') ;
      ym = mean(obj.BPMS.ydat,2,'omitnan') ;
      xstd = std(obj.BPMS.xdat,[],2,'omitnan') ;
      ystd = std(obj.BPMS.ydat,[],2,'omitnan') ;
      obj.LM.ModelClasses="MONI";
      z = arrayfun(@(x) BEAMLINE{x}.Coordi(3),obj.BPMS.readid) ;
      xax=ahan(1);
      yax=ahan(2);
      errorbar(xax,z(use),xm(use),xstd(use),'.'), xlabel(xax,'Z [m]'); ylabel(xax,'X [mm]');
      xax.XLim(2)=max(z(use));
      grid(xax,'on');
      if obj.BPMS.plotscale>0
        xax.YLim=[-double(obj.BPMS.plotscale) double(obj.BPMS.plotscale)];
      else
        xax.YLimMode="auto";
      end
      errorbar(yax,z(use),ym(use),ystd(use),'.'), xlabel(yax,'Z [m]'); ylabel(yax,'Y [mm]');
      yax.XLim(2)=max(z(use));
      grid(yax,'on');
      if obj.BPMS.plotscale>0
        yax.YLim=[-double(obj.BPMS.plotscale) double(obj.BPMS.plotscale)];
      else
        yax.YLimMode="auto";
      end
      % If orbit correction calcs performed, superimpose solution
      if obj.calcperformed
        hold(xax,'on');
        xc=obj.xbpm_cor(obj.usebpm);
        plot(xax,z(use),xc);
        hold(xax,'off');
        hold(yax,'on');
        yc=obj.ybpm_cor(obj.usebpm);
        plot(yax,z(use),yc);
        hold(yax,'off');
      end
    end
  end
end