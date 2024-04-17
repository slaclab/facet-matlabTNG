classdef F2_S20ConfigApp < handle & F2_common
  %F2_S20CONFIGAPP Applicaton class for FACET-II Sector 20 IP Configurator
  %
  % * For use with F2_S20Config App Designer object when GUI object passed to constructor
  % * Used by online watcher when constructed without GUI object
  events
    PVUpdated % PV object list notifies this event after each set of monitored PVs have finished updating
  end
  properties
    E_override logical = false % Overrides the Energy PV and allows user setting of Sector 20 energy assumption
    isSFQED logical = false % If true, use special matching conditions for SFQED configuration
    isKracken logical = false % If true, use special matching conditions for Kracken configuration
    WaistDesNameDS string = "PDUMP" % Model name of (intended) downstream waist location
    showlegend logical = true % Display legend on Twiss plots or not
    OptimConstraints logical = true ;
  end
  properties(SetObservable, AbortSet)
    WaistDesName string = "PENT" % Model name of (intended) IP waist location
    E0 = 10 % Beam energy [GeV]
    dE = 1.2 % Energy spread [% RMS]
    WaistResolution {mustBePositive} = 0.5e-2 % Resolution for finding z location of waist [m]
    InitialOption string {mustBeMember(InitialOption,["Design","L3","IP","User"])} = "Design" % Source of initial parameters
    InitialIPOption string {mustBeMember(InitialIPOption,["USTHz","USOTR","IPOTR1","IPOTR1P","IPOTR2","DSOTR","WDSOTR","PRDMP"])} = "IPOTR1" % Source of IP initial parameters
    UserParams(1,10) = [5 5 1 1 0 0 0 0 0 0] % emit_x, emit_y, beta_x, beta_y, alpha_x, alpha_y, Dx, D'x, Dy, D'y [um-rad, m & mm/mrad] - Changes trigger waist calculation & Twiss propogation calculations If User initial source selected
    WaistShiftDES(1,2) = [0 0] % Desired Z-shift in waist from desired location (x,y) [m]
    BetaDES(1,2) {mustBePositive} = [0.5,0.5] % Desired IP beta functions [m]
    MatchOK logical = false % true = Matching performed and no errors
  end
  properties(SetObservable,SetAccess=private, AbortSet)
    Q_BDES(1,9) = zeros(1,9) % Current FFS Quadrupole BDES values [kG] - Changes trigger waist calculation & Twiss propogation calculations
    Q_Match(1,9) = zeros(1,9) % Matched FFS Quadrupole BDES values [kG)] (0= no matching performed)
  end
  properties(Dependent)
    Initial % In-use Lucretia Initial structure @ BEGFF20
    WaistStr % List output for GUI IP waist location List Box
    WaistDesZ % Z location of desired waist location
    WaistDesEle % Element # of desired waist
    WaistDesEleDS % Element # of desired downstream waist
  end
  properties(SetAccess=private)
    WaistID(1,2) uint16 = [0,0] % Calculated waist location (EleNames ID) [x,y]
    WaistZ(1,2) % Linac Z location of IP waist
    WaistShift(1,2) % Z-shift in waist from desired location (x,y) [m]
    BetaMatch(1,2) = [0,0] % Matched beta functions [m] (0= matching not performed or matching error)
    BetaCurrent(1,2) = [0,0] % Current IP beta functions based on Initial parameters and live Quad BDES
    guihan % App Designer object
    InitialDesign % Lucretia Initial structure @ BEGFF20 (Design)
    InitialUser % Lucretia Initial structure @ BEGFF20 (User defined)
    InitialL3 % Lucretia Initial structure @ BEGFF20 (L3 - S18/S19 wires)
    InitialIP % Lucretia Initial structure @ BEGFF20 (IP - InitialIPOption states source)
    Q_Design(1,9) % Design quadrupole values [kG]
    E_Design % Design S20 energy [GeV]
    LM % LucretiaModel
    DataTable
    pvlist
    pvs
  end
  properties(Access=private)
    B5_Design % (half) design element of B5 magnet
    EleB5
    EleNames
    EleID
    EleZ
    EleRange(1,2) % start/end BEAMLINE elements  BEGFF20 : Dump
    tabhan % Table handle
    startup logical = true % Avoid calculating Twiss etc until first pass at gathering data
    magplotdone logical = false
    mags % F2_mags object
    TwissMATCH
    TwissACT
    CounterTimer
  end
  properties(Constant)
%     Q_BMAX = [256 446 457 440 440 440 239 386 240] ; % absolute max field of quads
    Q_BMAX = [256.29 446.44 457.02 167.5 275 167.5 239.7 386.8 233.2] ; % absolute max field of quads
    QuadNames string = ["Q5FF" "Q4FF" "Q3FF" "Q2FF" "Q1FF" "Q0FF" "Q0D" "Q1D" "Q2D"]
    QuadUnitNo uint16 = [3011 3311 3151 1910 3204 3031 3142 3261 3091]
    IPClassList string = ["MARK" "PROF" "WIRE" "INST"] % Lucretia Classes to include in IP waist location selection
  end
  methods
    function obj = F2_S20ConfigApp(guihan)
      %F2_S20CONFIGAPP F2_S20Config application support or S20 Config Watcher
      %
      %C=F2_S20ConfigApp(guihan)
      % Construct with F2_S20Config application object
      %C=F2_S20ConfigApp()
      % No associated GUI- e.g. for use with watcher
      global BEAMLINE
      
      % Parse input variables
      if exist('guihan','var')
        obj.guihan=guihan;
      end
      
      % Form list of EPICS PVs
      context = PV.Initialize(PVtype.EPICS) ;
      obj.pvlist = [PV(context,'name',"UserBetax",'pvname',"SIOC:SYS1:ML01:AO117",'monitor',true);
        PV(context,'name',"UserBetay",'pvname',"SIOC:SYS1:ML01:AO118",'monitor',true);
        PV(context,'name',"UserAlphax",'pvname',"SIOC:SYS1:ML01:AO119",'monitor',true);
        PV(context,'name',"UserAlphay",'pvname',"SIOC:SYS1:ML01:AO120",'monitor',true);
        PV(context,'name',"UserNEmitx",'pvname',"SIOC:SYS1:ML01:AO121",'monitor',true);
        PV(context,'name',"UserNEmity",'pvname',"SIOC:SYS1:ML01:AO122",'monitor',true);
        PV(context,'name',"UserDispx",'pvname',"SIOC:SYS1:ML01:AO123",'monitor',true);
        PV(context,'name',"UserDispxp",'pvname',"SIOC:SYS1:ML01:AO124",'monitor',true);
        PV(context,'name',"UserDispy",'pvname',"SIOC:SYS1:ML01:AO125",'monitor',true);
        PV(context,'name',"UserDispyp",'pvname',"SIOC:SYS1:ML01:AO126",'monitor',true);
        PV(context,'name',"EBC20",'pvname',"SIOC:SYS1:ML00:AO895",'monitor',true) ;
        PV(context,'name',"dE",'pvname',"SIOC:SYS1:ML01:AO127",'monitor',true,'mode',"rw") ;
        PV(context,'name',"WaistZ",'pvname',"SIOC:SYS1:ML01:AO128",'mode',"rw") ;
        PV(context,'name',"WaistLocation",'pvname',"SIOC:SYS1:ML01:CA001",'mode',"rw") ;
        PV(context,'name',"BDES_Q5FF",'pvname',"LI20:LGPS:3011:BDES",'monitor',true);
        PV(context,'name',"BDES_Q4FF",'pvname',"LI20:LGPS:3311:BDES",'monitor',true);
        PV(context,'name',"BDES_Q3FF",'pvname',"LI20:LGPS:3151:BDES",'monitor',true);
        PV(context,'name',"BDES_Q2FF",'pvname',"LI20:LGPS:1910:BDES",'monitor',true); %% PV Wrong for this quad!!!!
        PV(context,'name',"BDES_Q1FF",'pvname',"LI20:LGPS:3204:BDES",'monitor',true);
        PV(context,'name',"BDES_Q0FF",'pvname',"LI20:LGPS:3031:BDES",'monitor',true);
        PV(context,'name',"BDES_Q0D",'pvname',"LI20:LGPS:3141:BDES",'monitor',true);
        PV(context,'name',"BDES_Q1D",'pvname',"LI20:LGPS:3261:BDES",'monitor',true);
        PV(context,'name',"BDES_Q2D",'pvname',"LI20:LGPS:3091:BDES",'monitor',true);
        PV(context,'name',"BDES_B5",'pvname',"LI20:LGPS:3330:BDES",'monitor',true);
        PV(context,'name',"IP_BETAX",'pvname',"SIOC:SYS1:ML01:AO129",'monitor',false,'mode',"rw");
        PV(context,'name',"IP_BETAY",'pvname',"SIOC:SYS1:ML01:AO130",'monitor',false,'mode',"rw");
%         PV(context,'name',"BETAX_DES",'pvname',"SIOC:SYS1:ML00:AO352",'monitor',true,'mode',"rw"); % Desire BETA_X
%         PV(context,'name',"BETAY_DES",'pvname',"SIOC:SYS1:ML00:AO354",'monitor',true,'mode',"rw"); % Desire BETA_X
        PV(context,'name',"WaistX_DES_Name",'pvname',"SIOC:SYS1:ML00:SO0351",'monitor',true,'mode',"rw");
        PV(context,'name',"WaistY_DES_Name",'pvname',"SIOC:SYS1:ML00:SO0353",'monitor',true,'mode',"rw");
        PV(context,'name',"WaistX_DES_Z",'pvname',"SIOC:SYS1:ML00:AO351");
        PV(context,'name',"WaistY_DES_Z",'pvname',"SIOC:SYS1:ML00:AO353");

        PV(context,'name',"WaistName_ACT",'pvname',"SIOC:SYS1:ML00:CA902");
        PV(context,'name',"WaistX_ACT",'pvname',"SIOC:SYS1:ML00:AO395");
        PV(context,'name',"WaistY_ACT",'pvname',"SIOC:SYS1:ML00:AO396");

        ] ;
      pset(obj.pvlist,'debug',0) ;
      obj.pvs = struct(obj.pvlist) ;
      
      % Load FACET-II model
      obj.LM = LucretiaModel ;
      reg=false(1,11); reg(10:11)=true; obj.LM.UseRegion=reg; % Enable FFS & Spectrometer regions
      
      % Form waist location list data
      obj.LM.ModelClasses=obj.IPClassList ;
      obj.EleID = obj.LM.ModelID ;
      obj.EleZ = obj.LM.ModelZ ;
      obj.EleNames = obj.LM.ModelNames ;
      obj.EleRange = [obj.LM.istart obj.LM.iend];
      
      % Assign model to include just quads for rest of this class applications
      obj.LM.ModelClasses = "QUAD" ;
      obj.E_Design = obj.E0 ; % Store design energy
      obj.Q_Design = obj.LM.ModelBDES ; % Store design magnet strengths at design energy
      
      % Generate F2_mags object
      obj.mags=F2_mags(obj.LM); obj.mags.MagClasses="QUAD"; obj.mags.RelTolBDES=1e-4;
      obj.mags.WriteEnable = true ;
      
      % B5 bend data
      obj.EleB5 = findcells(BEAMLINE,'Name','B5D*') ;
      obj.B5_Design = BEAMLINE{obj.EleB5(1)} ;      
      
      % Store Design Twiss Parameters @ BEGFF20
      obj.InitialDesign = obj.LM.Initial1 ;
      obj.guisetInitial();
      
      % Signify end of startup and first call of Waist location routines
      if ~isempty(obj.guihan)
        obj.guihan.ListBox.Items = obj.WaistStr ;
        obj.guihan.ListBox.Value = obj.WaistDesName ;
      end
      
      % Get PVs once and propogate state changes
      caget(obj.pvlist); obj.PVwatchdog() ; 
      
      obj.startup=false;
      obj.LM.ModelBDES = obj.Q_BDES ;
      obj.TwissACT=obj.TwissCalc(obj.WaistResolution);
      obj.WaistCalc; % Also calls Plot()
      
      % Start PV updater and attach listener
      addlistener(obj,'PVUpdated',@(~,~) obj.PVwatchdog) ;
      obj.PVwatchdog() ; 
      run(obj.pvlist,true,1,obj,'PVUpdated');
      
      % Start counter updater if not running in GUI mode
      if isempty(obj.guihan)
        t=timer('TimerFcn',@obj.CounterTimerFun,'Period',1, 'ExecutionMode', 'fixedRate');
        start(t);
        diary('/u1/facet/physics/log/matlab/F2_S20Config.log');
      end
      
    end
    function CounterTimerFun(~,~,~)
      lcaPutNoWait('F2:WATCHER:WAISTLOCATOR_STAT',1);
    end
    function oval = MatchFun(obj,x,I,objdes,qno,ele,mode)
      
      % Set desired quad values
      B = obj.LM.ModelBDES ; B(qno)=x;
      if any(qno==4); B(6)=B(4); end
      if any(qno==7); B(9)=B(7); end
      obj.LM.ModelBDES = B ;
      
      ele=double(ele);
      
      % Get Twiss parameters at desired location
      if mode==5 || mode==6
        [stat,R] = RmatAtoB(ele(1),ele(2)) ; % response matrix IP -> meas screen
        if mode==5
          [stat,T] = GetTwiss(double(obj.EleRange(1)),ele(2),I.x.Twiss,I.y.Twiss) ;
        end
      else
        [stat,T] = GetTwiss(double(obj.EleRange(1)),ele,I.x.Twiss,I.y.Twiss) ;
      end
      
      % form output based on mode
      switch mode
        case 1 % fminsearch for FFS
          if stat{1}~=1
            oval=1e4;
          else
            oval = sum(abs(objdes-[T.betax(end) T.betay(end)]))*100 + sum(abs(([T.alphax(end) T.alphay(end)])).*100) ;
          end
        case 2 % lsqnonlin for FFS
          if stat{1}~=1
            oval=ones(1,5).*1e4;
          else
            oval = [abs(objdes-[T.betax(end) T.betay(end)])*300 abs(T.alphax(end))*100 abs(T.alphay(end))*100 sum(abs(x))./10000] ;
          end
        case 3 % return results of FFS match
          oval = [T.betax(end) T.betay(end) T.alphax(end) T.alphay(end)] ;
        case 4 % re-match KRK waist to dump
          oval = T.betax(end) + T.betay(end) ;
        case 5 % R11 = 0, min beta_y
          oval = abs(R(1,1)) + T.betay(end) ;
        case 6 % R12/34 = 0
          oval = abs(R(1,2)) + abs(R(3,4)) ;
        case 7 % just match waist at desired z position offset from ip location
          if any(abs(objdes)>0)
            R=[1 objdes(1); 0 1];
            Tx=[T.betax(end) -T.alphax(end); -T.alphax(end) (1+T.alphax(end)^2)/T.betax(end)];
            T2x=R*Tx*R'; alpx=-T2x(1,1);
            R=[1 objdes(2); 0 1];
            Ty=[T.betay(end) -T.alphay(end); -T.alphay(end) (1+T.alphay(end)^2)/T.betay(end)];
            T2y=R*Ty*R'; alpy=-T2y(1,1);
          else
            alpx=T.alphax(end); alpy=T.alphay(end);
          end
          oval = [abs(alpx) abs(alpy)].*1000 ;
      end
      
    end
    function MatchFFS(obj)
      %DOMATCH Match incoming Twiss parameters to requested IP & d/s IP waist conditions
      
      % Disable Quad Trim button until match successful
      obj.MatchOK=false;
      
      % Set design quad values as initial conditions
      obj.LM.ModelBDES = obj.Q_Design * obj.E0/obj.E_Design;
      
      % qno: 1=QF5FF 2=QF4FF 3=QF3FF 4=QF2FF/QF0FF 5=Q1FF 7=Q0D/Q2D 8=Q1D
      qsign=sign(obj.Q_BDES); % quad polarities
      % Match IP
      qno=1:5;
      B0=obj.LM.ModelBDES ;
      lval=obj.Q_BMAX.*qsign; lval(lval>0)=2.7;
      uval=obj.Q_BMAX.*qsign; uval(uval<0)=2.7;
      % - If SFQED, then only use central quad of triplet
      if obj.isSFQED
        B0=obj.Q_BDES; B0(4:6)=0; obj.LM.ModelBDES=B0;
        qno=[1:4 5];
        obj.WaistDesName="PENT";
%         B0(qno)=[-20.7 -151.7 176.7 -28.2];
      elseif obj.isKracken
        qno=1:3;
        obj.WaistDesName="KRK";
        obj.BetaDES=[0.29 0.29];
        if ~isempty(obj.guihan)
          obj.guihan.BetaX_DES.Value=0.29;
          obj.guihan.BetaY_DES.Value=0.29;
        end
      end

      ipele=double(obj.WaistDesEle);
      disp('Run matching algorithm...')
      if ~obj.isSFQED && ( any(obj.BetaDES>0.5) || obj.isKracken ) % use fminsearch
        xmin=fminsearch(@(x) obj.MatchFun(x,obj.Initial,obj.BetaDES,qno,ipele,1),B0(qno),optimset('Display','iter','MaxFunEval',2000));
      else % use lsqnonlin
        if obj.OptimConstraints
          xmin=lsqnonlin(@(x) obj.MatchFun(x,obj.Initial,obj.BetaDES,qno,ipele,2),B0(qno),lval(qno),uval(qno),optimset('Display','iter','MaxFunEval',2000,'Algorithm','trust-region-reflective'));
        else
          xmin=lsqnonlin(@(x) obj.MatchFun(x,obj.Initial,obj.BetaDES,qno,ipele,2),B0(qno),[],[],optimset('Display','iter','MaxFunEval',2000,'Algorithm','levenberg-marquardt'));
        end
      end
      matchvals = obj.MatchFun(xmin,obj.Initial,obj.BetaDES,qno,ipele,3) ;
      fprintf('Matching complete: Matched beta_x= %g beta_y= %g alpha_x= %g alpha_y= %g\n',matchvals);
      obj.BetaMatch = matchvals(1:2) ;
      if ~isempty(obj.guihan)
        obj.guihan.BetaX_MATCH.Value = obj.BetaMatch(1)*100 ;
        obj.guihan.BetaY_MATCH.Value = obj.BetaMatch(2)*100 ;
        if abs(obj.BetaMatch(1)-obj.BetaDES(1))>0.01
          obj.guihan.BetaX_MATCH.FontColor='red';
        else
          obj.guihan.BetaX_MATCH.FontColor='black';
        end
        if abs(obj.BetaMatch(2)-obj.BetaDES(2))>0.01
          obj.guihan.BetaY_MATCH.FontColor='red';
        else
          obj.guihan.BetaY_MATCH.FontColor='black';
        end
        drawnow
      end
      
      iscr=obj.WaistDesEleDS;
      % If Kraken, then re-match waist at dump
      if obj.isKracken
        % Switch off spectrometer quads
        bdes=obj.LM.ModelBDES;
        bdes(7:9)=0;
        obj.LM.ModelBDES=bdes;
        fminsearch(@(x) obj.MatchFun(x,obj.Initial,[0 0],[4 5],iscr,4),[0 0],optimset('Display','iter','MaxFunEval',2000));
      else % Match dump optics from IP
        if obj.isSFQED
          bdes=obj.LM.ModelBDES;
          bdes(7:9)=0;
          obj.LM.ModelBDES=bdes;
          fminsearch(@(x) obj.MatchFun(x,obj.Initial,[0 0],[8 9],[ipele iscr],5),[200 -150],optimset('Display','iter','MaxFunEval',2000)); % R11 = 0, min beta_y(dump) with Q1D & Q2D
        else
          fminsearch(@(x) obj.MatchFun(x,obj.Initial,[0 0],[7 8],[ipele iscr],6),[0 0],optimset('Display','iter','MaxFunEval',2000)); % R12/34 = 0 with final triplet
        end
      end
      
      % Store matched quad BDES values &
      % Enable quad trim function if successful match
      obj.Q_Match = obj.LM.ModelBDES ; % Sets GUI edit boxes
      Bgood = obj.Q_Match==0 | ( obj.Q_Match>=lval & obj.Q_Match<=uval & sign(obj.Q_Match)==sign(obj.Q_BDES) ) ;
      obj.MatchOK=all(Bgood); % Sets Trim Quads button on GUI to enabled/disabled as required
      % Flag BDES values outside allowable range by changing font color to red
      if ~isempty(obj.guihan)
        for iquad=1:9
          if Bgood(iquad)
            obj.guihan.("BMATCH_"+obj.QuadNames(iquad)).FontColor='black';
          else
            obj.guihan.("BMATCH_"+obj.QuadNames(iquad)).FontColor='red';
          end
        end
        obj.Plot();
      end
      
      % Warn if magnets need to be DAC zero'd
      if any(obj.Q_Match==0)
        warndlg('One or more quadrupoles need to be set to zero: please set DAC ZERO in SCP for corresponding magnets after pushing "TRIM QUADS" button','DAC Zero Quads');
      end
      
    end
    function MatchWaist(obj)
      %WAISTMATCH Move IP waist to desired z location using final triplet
      
      % PS: 1=QF5FF 2=QF4FF 3=QF3FF 4=QF2FF/QF0FF 5=Q1FF 6=Q0D/Q2D 7=Q1D
      obj.MatchOK=false;
      qno=4:5;
      ipele=double(obj.WaistDesEle);
      B0=obj.LM.ModelBDES ;
      qsign=sign(obj.Q_BDES); % quad polarities
      lval=10*obj.Q_BMAX.*qsign; lval(lval>0)=0;
      uval=10*obj.Q_BMAX.*qsign; uval(uval<0)=0;
      lsqnonlin(@(x) obj.MatchFun(x,obj.Initial,obj.WaistShiftDES,qno,ipele,7),B0(qno),[],[],optimset('Display','iter','MaxFunEval',2000,'Algorithm','levenberg-marquardt'));
      
      % Store matched quad BDES values &
      % Enable quad trim function if successful match
      obj.Q_Match = obj.LM.ModelBDES ; % Sets GUI edit boxes
      Bgood = obj.Q_Match>=lval.*10 & obj.Q_Match<=uval.*10 & sign(obj.Q_Match)==sign(obj.Q_BDES) ;
      obj.MatchOK=all(Bgood); % Sets Trim Quads button on GUI to enabled/disabled as required
      % Flag BDES values outside allowable range by changing font color to red
      if ~isempty(obj.guihan)
        for iquad=1:9
          if Bgood(iquad)
            obj.guihan.("BMATCH_"+obj.QuadNames(iquad)).FontColor='black';
          else
            obj.guihan.("BMATCH_"+obj.QuadNames(iquad)).FontColor='red';
          end
        end
        obj.Plot();
      end
      
    end
    function Plot(obj,fhan)
      %PLOT Plotting function for Twiss parameters
      %Plot() Plot Twiss parameters in new figure window or Plot window if operating with GUI
      %Plot(fhan) Plot Twiss parameters into existing figure window
      global BEAMLINE
      
      if obj.startup; return; end
      
      % Live Twiss values
      obj.LM.ModelBDES = obj.Q_BDES ;
      Tl=obj.TwissACT;
      
      % Matched Twiss values
      if obj.MatchOK
        obj.LM.ModelBDES = obj.Q_Match ;
        Tm=obj.TwissMATCH;
      end
      
      % Draw plots
      if ~exist('fhan','var')
        if ~isempty(obj.guihan)
          axhan=obj.guihan.UIAxes2;
          cla(axhan);
        else
          fhan=figure;
          axhan=axes(fhan);
        end
      else
        clf(fhan);
        axhan=axes(fhan);
      end
      
      if obj.MatchOK
        plot(axhan,Tl.z,Tl.betax,'b',Tm.z,Tm.betax,'b--',Tl.z,Tl.betay,'r',Tm.z,Tm.betay,'r--',Tl.z,Tl.etay.*1e3,'g');
      else
        plot(axhan,Tl.z,Tl.betax,'b',Tl.z,Tl.betay,'r',Tl.z,Tl.etay.*1e3,'g');
      end
      axis(axhan,'tight');
      hold(axhan,'on');
      ax=axis(axhan);
      line(axhan,ones(1,2).*obj.WaistZ(1),ax(3:4),'LineStyle','-','Color','k');
      line(axhan,ones(1,2).*obj.WaistDesZ(1),ax(3:4),'LineStyle','--','Color','k');
      hold(axhan,'off');
      axis(axhan,ax);
      if obj.showlegend
        if obj.MatchOK
          legend(axhan,{'\beta_x (extant) [m]' '\beta_x (match) [m]' '\beta_y (extant) [m]' '\beta_y (match) [m]' '\eta_y [mm]' 'Waist Location' 'Design Waist Location'});
        else
          legend(axhan,{'\beta_x (extant) [m]' '\beta_y (extant) [m]' '\eta_y [mm]' 'Waist Location' 'Design Waist Location'});
        end
      end
      xlabel(axhan,'Z [m]'); ylabel(axhan,'\beta_{x,y} [m], \eta_y [mm]');
      if ~obj.magplotdone
        obj.LM.ModelBDES = obj.Q_BDES ; % Use extant quad strengths for magnet plot
        if ~isempty(obj.guihan)
          plot(obj.guihan.UIAxes,Tl.z,Tl.betax);
          axis(obj.guihan.UIAxes,'tight');
          AddMagnetPlotZ(double(obj.EleRange(1)),length(BEAMLINE),obj.guihan.UIAxes,'replace');
          obj.magplotdone = true ;
        else
          AddMagnetPlotZ(double(obj.EleRange(1)),length(BEAMLINE),axhan);
        end
      end
      drawnow
    end
    function PlotToLog(obj)
      %PLOTTOLOG Make a summary plot an post to facetelog
      global BEAMLINE
      
      % Matched Twiss values
      if ~obj.MatchOK
        error('No good Twiss match');
      end
      Tm=obj.TwissMATCH;
      
      % Draw plots
      fhan=figure;
      axhan=axes(fhan);
      plot(axhan,Tm.z,Tm.betax,'b',Tm.z,Tm.betay,'r',Tm.z,Tm.etay.*1e3,'g');
      grid(axhan,'on');
      axis(axhan,'tight');
      hold(axhan,'on');
      ax=axis(axhan);
      line(axhan,ones(1,2).*obj.WaistDesZ(1),ax(3:4),'LineStyle','--','Color','k');
      hold(axhan,'off');
      axis(axhan,ax);
      xlabel(axhan,'Z [m]'); ylabel(axhan,'\beta_x (blue) \beta_y (red) [m], \eta_y [mm]');
      AddMagnetPlotZ(double(obj.EleRange(1)),length(BEAMLINE));
      txt=[sprintf('BETA_X = %.3f\n',obj.BetaMatch(1)) ...
        sprintf('BETA_Y = %.3f\n',obj.BetaMatch(2)) ...
        sprintf('WAIST Location: %s (Z=%.3f)\n',obj.WaistDesName,obj.WaistDesZ) ...
        sprintf('Image location: %s\n',obj.WaistDesNameDS) ...
        sprintf('Q5FF=%.2f Q4FF=%.2f Q3FF=%.2f Q2FF=%.2f\nQ1FF=%.2f Q0FF= %.2f QD0= %.2f QD1=%.2f QD2= %.2f',obj.Q_Match)];
      if any(abs(obj.WaistShiftDES)>0)
        txt=[txt sprintf('\nDesired Waist Z shift: %g / %g cm\n',obj.WaistShiftDES.*100)];
      end
      drawnow
      util_printLog2020(fhan, 'title','Sector 20 Config Change','author','F2_S20Config.m','text',txt);
      close(fhan);
    end
    function PVwatchdog(obj,~,~)
      %PVWATCHDOG Triggers on update of vals in pvlist
      global BEAMLINE
%       caget(obj.pvlist);
      % Set B5 bend angle and strength
      E_B5 = obj.pvs.BDES_B5.val{1} ;
      sca = E_B5 / obj.B5_Design.P ;
      for iele=obj.EleB5
        BEAMLINE{iele}.Angle = obj.B5_Design.Angle .* sca ;
        BEAMLINE{iele}.EdgeAngle = obj.B5_Design.EdgeAngle .* sca ;
        BEAMLINE{iele}.B = obj.B5_Design.B .* sca ;
      end
      % Read and set Quad vals
      obj.Q_BDES = [obj.pvs.BDES_Q5FF.val{1} obj.pvs.BDES_Q4FF.val{1} obj.pvs.BDES_Q3FF.val{1} obj.pvs.BDES_Q2FF.val{1} obj.pvs.BDES_Q1FF.val{1} ...
        obj.pvs.BDES_Q0FF.val{1} obj.pvs.BDES_Q0D.val{1} obj.pvs.BDES_Q1D.val{1} obj.pvs.BDES_Q2D.val{1}] ;
      % User Initial parameters
      obj.UserParams = [obj.pvs.UserBetax.val{1} obj.pvs.UserBetay.val{1} obj.pvs.UserAlphax.val{1} obj.pvs.UserAlphay.val{1} ...
        obj.pvs.UserNEmitx.val{1} obj.pvs.UserNEmity.val{1} obj.pvs.UserDispx.val{1} obj.pvs.UserDispxp.val{1} ...
        obj.pvs.UserDispy.val{1} obj.pvs.UserDispyp.val{1} ] ;
      % Set Lattice beam energy
      if ~obj.E_override
        obj.E0 = obj.pvs.EBC20.val{1} ;
      end
      obj.dE = obj.pvs.dE.val{1} ;
%       obj.BetaDES = [obj.pvs.BETAX_DES.val{1} obj.pvs.BETAY_DES.val{1}] ;
      if ~isempty(obj.guihan)
        obj.guihan.BetaX_DES.Value = obj.BetaDES(1)*100 ;
        obj.guihan.BetaY_DES.Value = obj.BetaDES(2)*100 ;
      end
      if obj.WaistDesName ~= string(obj.pvs.WaistX_DES_Name.val{1})
        obj.WaistDesName = string(obj.pvs.WaistX_DES_Name.val{1}) ;
      end
      if ~isempty(obj.guihan)
%         obj.guihan.ListBox.Value = obj.WaistDesName ; % need to deal with waist pointer text
      end
      drawnow;
    end
    function Table(obj)
      %TABLE Show table of twiss parameters and other Beamline data
      global BEAMLINE
      
      % Live Twiss values
      obj.LM.ModelBDES = obj.Q_BDES ;
      [~,Tl]=GetTwiss(double(obj.EleRange(1)),length(BEAMLINE),obj.Initial.x.Twiss,obj.Initial.y.Twiss);
      
      % Matched Twiss values
      if obj.MatchOK
        obj.LM.ModelBDES = obj.Q_Match ;
        [~,Tm]=GetTwiss(double(obj.EleRange(1)),length(BEAMLINE),obj.Initial.x.Twiss,obj.Initial.y.Twiss);
      end
      
      ModelName=arrayfun(@(x) BEAMLINE{x}.Name,double(obj.EleRange(1)):length(BEAMLINE),'UniformOutput',false);
      LinacZ=arrayfun(@(x) BEAMLINE{x}.Coordi(3),double(obj.EleRange(1)):length(BEAMLINE));
      BetaX=Tl.betax(1:end-1);
      BetaY=Tl.betay(1:end-1);
      DispY=Tl.etay(1:end-1);
      NuX=Tl.nux(1:end-1);
      NuY=Tl.nuy(1:end-1);
      gamma=obj.E0/0.511e-3;
      emit=[obj.Initial.x.NEmit/gamma obj.Initial.y.NEmit/gamma];
      SigmaX=sqrt(BetaX.*emit(1)); SigmaY=sqrt(BetaY.*emit(2)+DispY.^2*(obj.dE./100).^2);
      if obj.MatchOK && length(Tm.betax)==length(Tl.betax)
        BetaX_match=Tm.betax(1:end-1);
        BetaY_match=Tm.betay(1:end-1);
        NuX_match=Tm.nux(1:end-1);
        NuY_match=Tm.nuy(1:end-1);
        SigmaX_match=sqrt(BetaX_match.*emit(1)); SigmaY_match=sqrt(BetaY_match.*emit(2)+DispY.^2*(obj.dE./100).^2);
      else
        BetaX_match=nan(size(BetaX));
        BetaY_match=BetaX_match;
        SigmaX_match=BetaX_match;
        SigmaY_match=BetaX_match;
        NuX_match=BetaX_match;
        NuY_match=BetaX_match;
      end
      ModelName=ModelName(:); LinacZ=string(LinacZ(:)); BetaX=BetaX(:);BetaY=BetaY(:); BetaX_match=BetaX_match(:); BetaY_match=BetaY_match(:);
      NuX=NuX(:)-NuX(1); NuX_match=NuX_match(:)-NuX_match(1); NuY=NuY(:)-NuY(1); NuY_match=NuY_match(:)-NuY_match(1);
      SigmaX=SigmaX(:); SigmaY=SigmaY(:); SigmaX_match=SigmaX_match(:); SigmaY_match=SigmaY_match(:); DispY=DispY(:);
      tab=table(ModelName,LinacZ,BetaX,BetaY,NuX,NuY,BetaX_match,BetaY_match,SigmaX,SigmaY,SigmaX_match,SigmaY_match,NuX_match,NuY_match,DispY);
      if ~ishandle(obj.tabhan)
        fig = uifigure;
        obj.tabhan=uitable(fig,'Data',tab);
        obj.tabhan.Position=[1 1 fig.Position(3:4)];
      else
        obj.tabhan.Data=tab;
      end
    end
    function TrimQuads(obj)
      %TRIMQUADS Trim SLC quadrupoles to Match values
      if ~obj.MatchOK
        error('No successful match performed');
      end
      % Store initial MPS sutter state
      shut = lcaGet('IOC:SYS1:MP01:MSHUTCTL') ;
      % Put Injector MPS shutter in before trimming quads
      lcaPut('IOC:SYS1:MP01:MSHUTCTL','No');
      try
        try
          obj.mags.ReadB;
          obj.mags.BDES=obj.Q_Match;
          obj.mags.WriteBDES;
        catch
          obj.mags.WriteBDES;
        end
      catch ME
        lcaPut('IOC:SYS1:MP01:MSHUTCTL',shut); % Restore original shutter state
        fprintf(2,'Error reported from AIDA whilst trimming quads:\n');
        throw(ME);
      end
      % write actual waist parameters after a successful trim
      waist_str = lcaGet('SIOC:SYS1:ML00:SO0351');
      caput(obj.pvs.WaistName_ACT, char(waist_str));
      caput(obj.pvs.WaistX_ACT, obj.BetaMatch(1));
      caput(obj.pvs.WaistY_ACT, obj.BetaMatch(2));
      
      lcaPut('IOC:SYS1:MP01:MSHUTCTL',shut); % Restore original shutter state
    end
    function Twiss=TwissCalc(obj,dL)
      %TWISSCALC segment BEAMLINE according to dL spacing and propogate Twiss parameters
      global BEAMLINE PS
      
      istart=double(obj.EleRange(1)); iend=double(obj.EleRange(2));
      I=obj.Initial;
      
      % Split up BEAMLINE as required
      if ~exist('dL','var')
        dL=[];
      end
      if ~isempty(dL)
        BL1=BEAMLINE; % Store Original BEAMLINE to restore later
        PS1=PS;
        for ips=1:length(PS)
          if PS(ips).Element(1)<iend
            RenormalizePS(ips);
            for iele=PS(ips).Element
              if PS(ips).Ampl==0
                BEAMLINE{iele}.B=BEAMLINE{iele}.B.*0;
              end
              BEAMLINE{iele}.PS=zeros(size(BEAMLINE{iele}.PS));
            end
          end
        end
        BEAMLINE=BEAMLINE(istart:iend);
        BL_new={};
        for iele=1:length(BEAMLINE)
          if isfield(BEAMLINE{iele},'Girder')
            BEAMLINE{iele}.Girder=0;
          end
          if isfield(BEAMLINE{iele},'Block')
            BEAMLINE{iele}=rmfield(BEAMLINE{iele},'Block');
          end
          if isfield(BEAMLINE{iele},'Slices')
            BEAMLINE{iele}=rmfield(BEAMLINE{iele},'Slices');
          end
          if isfield(BEAMLINE{iele},'L') && BEAMLINE{iele}.L>dL && ~strcmp(BEAMLINE{iele}.Class,'TMAP')
            nsplit=ceil(BEAMLINE{iele}.L/dL);
            BL=BEAMLINE{iele};
            BL.L=BL.L/nsplit;
            if isfield(BL,'B')
              BL.B=BL.B./nsplit;
            end
            if isfield(BL,'Volt')
              BL.Volt=BL.Volt./nsplit;
              BL.Egain=BL.Egain./nsplit;
            end
            if strcmp(BL.Class,'SBEN')
              BL.Angle=BL.Angle./nsplit;
              if length(BL.EdgeAngle)==1
                BL.EdgeAngle=ones(1,2).*BL.EdgeAngle;
              end
              if length(BL.HGAP)==1
                BL.HGAP=ones(1,2).*BL.HGAP;
              end
              if length(BL.FINT)==1
                BL.FINT=ones(1,2).*BL.FINT;
              end
              if length(BL.EdgeCurvature)==1
                BL.EdgeCurvature=ones(1,2).*BL.EdgeCurvature;
              end
            end
            for isplit=1:nsplit
              if isfield(BL,'EdgeAngle') && isplit==1
                BL.EdgeAngle=[BEAMLINE{iele}.EdgeAngle(1) 0];
                BL.HGAP=[BEAMLINE{iele}.HGAP(1) 0];
                BL.FINT=[BEAMLINE{iele}.FINT(1) 0];
                BL.EdgeCurvature=[BEAMLINE{iele}.EdgeCurvature(1) 0];
              elseif isfield(BL,'EdgeAngle') && isplit==nsplit
                BL.EdgeAngle=[0 BEAMLINE{iele}.EdgeAngle(2)];
                BL.HGAP=[0 BEAMLINE{iele}.HGAP(2)];
                BL.FINT=[0 BEAMLINE{iele}.FINT(2)];
                BL.EdgeCurvature=[0 BEAMLINE{iele}.EdgeCurvature(2)];
              elseif isfield(BL,'EdgeAngle')
                BL.EdgeAngle=[0 0];
                BL.HGAP=[0 0];
                BL.FINT=[0 0];
                BL.EdgeCurvature=[0 0];
              elseif isfield(BL,'Volt') && isplit>1
                BL.P=BL.P+BL.Egain*1e-3;
              end
              BL_new{end+1}=BL; %#ok<AGROW>
            end
          else
            BL_new{end+1}=BEAMLINE{iele}; %#ok<AGROW>
          end
        end
        BEAMLINE=BL_new(:);
        SetSPositions(1,length(BEAMLINE),BL1{istart}.S);
        SetFloorCoordinates(1,length(BEAMLINE),[BEAMLINE{1}.Coordi BEAMLINE{1}.Anglei]);
        istart=1; iend=length(BEAMLINE);
      end
      % Calc Twiss parameters
      [stat,Twiss]=GetTwiss(istart,iend,I.x.Twiss,I.y.Twiss);
      Twiss.z = arrayfun(@(x) BEAMLINE{x}.Coordi(3),1:length(BEAMLINE)) ;
      [~,ia]=unique(Twiss.z);
      fn=fieldnames(Twiss);
      for ifn=1:length(fn)
        Twiss.(fn{ifn})=Twiss.(fn{ifn})(ia);
      end
      if stat{1}~=1
        error(stat{2});
      end
      % Put original beamline back
      if ~isempty(dL)
        BEAMLINE=BL1;
        PS=PS1;
      end
    end
    function WaistCalc(obj)
      %WAISTCALC Propogate Twiss parameters through Model and calculate waist data
      global BEAMLINE
      if obj.startup; return; end % Don't calculate stuff until bootstrapped startup complete
      obj.LM.ModelBDES = obj.Q_BDES ; % Make sure extant Quad values loaded into model
      try
        T=obj.TwissACT;
      catch
        error('Error propogating Twiss parameters through model');
      end
      % Find waist location as local minimum in alpha functions starting at desired waist location
      % - define 3 regions (between triplets and between last triplet and dump)
      zreg = [BEAMLINE{obj.LM.ModelID(3)}.Coordf(3)  BEAMLINE{obj.LM.ModelID(4)}.Coordi(3) ...
              BEAMLINE{obj.LM.ModelID(6)}.Coordf(3) BEAMLINE{obj.LM.ModelID(7)}.Coordi(3) ...
              BEAMLINE{obj.LM.ModelID(9)}.Coordf(3) T.z(end) ];
      % First look in the zone where the design IP is
      if obj.WaistDesZ>=zreg(1) && obj.WaistDesZ<=zreg(2)
        ind=find(T.z>zreg(1) & T.z<=zreg(2)) ;
      elseif obj.WaistDesZ>=zreg(3) && obj.WaistDesZ<=zreg(4)
        ind=find(T.z>=zreg(3) & T.z<=zreg(4)) ;
      else
        ind=find(T.z>=zreg(5) & T.z<=zreg(6)) ;
      end
      ix = find(sign(T.alphax(ind(1)).*T.alphax(ind))<0,1) ;
      iy = find(sign(T.alphay(ind(1)).*T.alphay(ind))<0,1) ;
      % If not found there then look everywhere (finds most upstream waist)
      if isempty(ix) || isempty(iy)
        ind=find(T.z>zreg(1) & T.z<=zreg(6)) ;
      end
      if isempty(ix)
        ix = find(sign(T.alphax(ind(1)).*T.alphax(ind))<0,1) ;
        if isempty(ix); ix=1; end
      end
      z_x = T.z(ind(ix)) ;
      if isempty(iy)
        iy = find(sign(T.alphay(ind(1)).*T.alphay(ind))<0,1) ;
        if isempty(iy); iy=1; end
      end
      z_y = T.z(ind(iy)) ;
      obj.WaistZ = [z_x z_y] ;
      [~,id_x] = min(abs(obj.EleZ-z_x)) ;
      [~,id_y] = min(abs(obj.EleZ-z_y)) ;
      obj.WaistID = [id_x id_y] ;
      obj.WaistShift = obj.WaistZ - obj.WaistDesZ ;
      caput(obj.pvs.WaistLocation,char(obj.EleNames(id_x)));
      caput(obj.pvs.WaistZ,z_x);
      fprintf('Waist Location = %s (Z=%f m)\n',obj.EleNames(id_x),z_x);
      bx = spline(T.z,T.betax,z_x); % beta_x @ waist
      by = spline(T.z,T.betay,z_y); % beta_y @ waist
      caput(obj.pvs.IP_BETAX,bx);
      caput(obj.pvs.IP_BETAY,by);
      fprintf('Waist Beta functions: %g / %g (m)\n',bx,by);
      obj.BetaCurrent =[bx by];
      if ~isempty(obj.guihan)
        ival = find(string(obj.guihan.ListBox.Items)==string(obj.guihan.ListBox.Value));
        obj.guihan.ListBox.Items = obj.WaistStr ;
        newstr=string(obj.guihan.ListBox.Items);
        obj.guihan.ListBox.Value = newstr(ival) ; %#ok<FNDSB>
        obj.guihan.BetaX_CUR.Value = bx*100 ; % cm
        obj.guihan.BetaY_CUR.Value = by*100 ; % cm
        if abs(bx-obj.BetaDES(1))>0.01
          obj.guihan.BetaX_CUR.FontColor='red';
        else
          obj.guihan.BetaX_CUR.FontColor='black';
        end
        if abs(by-obj.BetaDES(2))>0.01
          obj.guihan.BetaY_CUR.FontColor='red';
        else
          obj.guihan.BetaY_CUR.FontColor='black';
        end
        obj.guihan.WaistX_dzACT.Value = obj.WaistShift(1).*100 ; % cm
        obj.guihan.WaistY_dzACT.Value = obj.WaistShift(2).*100 ; % cm
        if abs(obj.WaistShift(1)-obj.WaistShiftDES(1))>obj.WaistResolution
          obj.guihan.WaistX_dzACT.FontColor = 'red' ;
        else
          obj.guihan.WaistX_dzACT.FontColor = 'black' ;
        end
        if abs(obj.WaistShift(2)-obj.WaistShiftDES(2))>obj.WaistResolution
          obj.guihan.WaistY_dzACT.FontColor = 'red' ;
        else
          obj.guihan.WaistY_dzACT.FontColor = 'black' ;
        end
        obj.Plot() ;
        drawnow
      end
    end
  end
  methods % Get/Set methods
    function guiset(obj,str,val)
      if ~isempty(obj.guihan)
        obj.guihan.(str).Value = val ;
      end
    end
    function guisetInitial(obj)
      if ~isempty(obj.guihan)
        I = obj.Initial ;
        obj.guihan.emitx.Value = I.x.NEmit.*1e6 ;
        obj.guihan.emity.Value = I.y.NEmit.*1e6 ;
        obj.guihan.betax.Value = I.x.Twiss.beta ;
        obj.guihan.betay.Value = I.y.Twiss.beta ;
        obj.guihan.alphax.Value = I.x.Twiss.alpha ;
        obj.guihan.alphay.Value = I.y.Twiss.alpha ;
        obj.guihan.Dx.Value = I.x.Twiss.eta ;
        obj.guihan.Dxp.Value = I.x.Twiss.etap ;
        obj.guihan.Dy.Value = I.y.Twiss.eta ;
        obj.guihan.Dyp.Value = I.y.Twiss.etap ;
      end
    end
    function I = get.Initial(obj)
      switch obj.InitialOption
        case "Design"
          I = obj.InitialDesign ;
        case "L3"
          I = obj.InitialL3 ;
        case "IP"
          I = obj.InitialIP ;
        case "User"
          I = obj.InitialUser ;
      end
    end
    function ele = get.WaistDesEle(obj)
      ele = obj.EleID(obj.EleNames==obj.WaistDesName) ;
    end
    function ele = get.WaistDesEleDS(obj)
      ele = obj.EleID(obj.EleNames==obj.WaistDesNameDS) ;
    end
    function z = get.WaistDesZ(obj)
      z = obj.EleZ(obj.EleNames==obj.WaistDesName) ;
    end
    function str = get.WaistStr(obj)
      str = obj.EleNames ;
      id_x = obj.WaistID(1); id_y = obj.WaistID(2);
      if id_x==0 || id_y==0
        return
      end
      if id_x==id_y
        str(id_x) = str(id_x) + " <-- W_x&y" ;
      else
        str(id_x) = str(id_x) + " <-- W_x" ;
        str(id_y) = str(id_y) + " <-- W_y" ;
      end
    end
    function set.BetaDES(obj,beta)
      obj.BetaDES=beta;
      if ~isempty(obj.guihan)
        if abs(beta(1)-obj.BetaCurrent(1))>0.01
          obj.guihan.BetaX_CUR.FontColor='red';
        else
          obj.guihan.BetaX_CUR.FontColor='black';
        end
        if abs(beta(2)-obj.BetaCurrent(2))>0.01
          obj.guihan.BetaY_CUR.FontColor='red';
        else
          obj.guihan.BetaY_CUR.FontColor='black';
        end
        if abs(beta(1)-obj.BetaMatch(1))>0.01
          obj.guihan.BetaX_MATCH.FontColor='red';
        else
          obj.guihan.BetaX_MATCH.FontColor='black';
        end
        if abs(beta(2)-obj.BetaMatch(2))>0.01
          obj.guihan.BetaY_MATCH.FontColor='red';
        else
          obj.guihan.BetaY_MATCH.FontColor='black';
        end
      end
      obj.MatchOK=false;
      % Write BETA DES PVs
%       caput(obj.pvs.BETAX_DES,beta(1));
%       caput(obj.pvs.BETAY_DES,beta(2));
    end
    function set.dE(obj,dE)
      caput(obj.pvs.dE,dE);
      obj.dE = dE ;
      obj.guiset('dE',dE);
      if ishandle(obj.tabhan) % Re-populate data table
        Table(obj);
      end
    end
    function set.E0(obj,E0)
      obj.LM.P0 = E0 ; % Scale lattice to required energy
      obj.E0 = E0 ;
      obj.InitialDesign.Momentum=E0;
      obj.InitialUser.Momentum=E0;
      obj.InitialIP.Momentum=E0;
      obj.InitialL3.Momentum=E0;
      obj.guiset('E0',E0);
      obj.WaistCalc;
    end
    function set.InitialOption(obj,opt)
      obj.InitialOption=opt;
      obj.WaistCalc;
      obj.guisetInitial();
    end
    function set.MatchOK(obj,ok)
      obj.MatchOK=ok;
      if ~isempty(obj.guihan)
        obj.guihan.TRIMQUADSButton.Enable=ok;
        drawnow
      end
    end
    function set.Q_BDES(obj,BDES)
      obj.Q_BDES = BDES ;% Set B5 bend angle and strength
      E_B5 = obj.pvs.BDES_B5.val{1} ;
      sca = E_B5 / obj.B5_Design.P ;
      for iele=obj.EleB5
        BEAMLINE{iele}.Angle = obj.B5_Design.Angle .* sca ;
        BEAMLINE{iele}.EdgeAngle = obj.B5_Design.EdgeAngle .* sca ;
        BEAMLINE{iele}.B = obj.B5_Design.B .* sca ;
      end
      if ~isempty(obj.guihan)
        obj.guihan.BDES_Q5FF.Value = BDES(1) ;
        obj.guihan.BDES_Q4FF.Value = BDES(2) ;
        obj.guihan.BDES_Q3FF.Value = BDES(3) ;
        obj.guihan.BDES_Q2FF.Value = BDES(4) ;
        obj.guihan.BDES_Q1FF.Value = BDES(5) ;
        obj.guihan.BDES_Q0FF.Value = BDES(6) ;
        obj.guihan.BDES_Q0D.Value = BDES(7) ;
        obj.guihan.BDES_Q1D.Value = BDES(8) ;
        obj.guihan.BDES_Q2D.Value = BDES(9) ;
        if ishandle(obj.tabhan) % Re-populate data table
          Table(obj);
        end
        drawnow
      end
      if ~obj.startup
        disp('Quad BDES values changed, re-calculating Twiss parameters and Waist data...')
        obj.LM.ModelBDES = obj.Q_BDES ;
        obj.TwissACT=obj.TwissCalc(obj.WaistResolution);
        obj.WaistCalc; % Also calls Plot()
      end
    end
    function set.Q_Match(obj,BDES)
      obj.Q_Match = BDES ;
      if ~isempty(obj.guihan)
        obj.guihan.BMATCH_Q5FF.Value = BDES(1) ;
        obj.guihan.BMATCH_Q4FF.Value = BDES(2) ;
        obj.guihan.BMATCH_Q3FF.Value = BDES(3) ;
        obj.guihan.BMATCH_Q2FF.Value = BDES(4) ;
        obj.guihan.BMATCH_Q1FF.Value = BDES(5) ;
        obj.guihan.BMATCH_Q0FF.Value = BDES(6) ;
        obj.guihan.BMATCH_Q0D.Value = BDES(7) ;
        obj.guihan.BMATCH_Q1D.Value = BDES(8) ;
        obj.guihan.BMATCH_Q2D.Value = BDES(9) ;
        if ishandle(obj.tabhan) % Re-populate data table
          Table(obj);
        end
        if ~obj.startup
          disp('Matched Quad values changed, re-calculating Matched Twiss parameters and updating plots...');
          obj.LM.ModelBDES = obj.Q_Match ;
          obj.TwissMATCH=obj.TwissCalc(obj.WaistResolution);
          obj.Plot() ;
        end
      end
    end
    function set.UserParams(obj,parvec)
      obj.InitialUser = obj.InitialDesign ;
      obj.InitialUser.x.Twiss.beta = parvec(1) ;
      obj.InitialUser.y.Twiss.beta = parvec(2) ;
      obj.InitialUser.x.Twiss.alpha = parvec(3) ;
      obj.InitialUser.y.Twiss.alpha = parvec(4) ;
      obj.InitialUser.x.NEmit = parvec(5).*1e-6 ;
      obj.InitialUser.y.NEmit = parvec(6).*1e-6 ;
      obj.InitialUser.x.Twiss.eta = parvec(7)*1e3 ;
      obj.InitialUser.x.Twiss.etap = parvec(8)*1e3 ;
      obj.InitialUser.y.Twiss.eta = parvec(9)*1e3 ;
      obj.InitialUser.y.Twiss.etap = parvec(10)*1e3 ;
      if obj.InitialOption == "User"
        obj.guisetInitial();
        if ishandle(obj.tabhan) % Re-populate data table
          Table(obj);
        end
        if ~obj.startup
          disp('Initial parameters changed, re-calculating Twiss parameters and Waist data...');
          obj.LM.ModelBDES = obj.Q_BDES(:) ;
          obj.TwissACT=obj.TwissCalc(obj.WaistResolution);
          if obj.MatchOK
            obj.LM.ModelBDES = obj.Q_Match(:) ;
            obj.TwissMATCH=obj.TwissCalc(obj.WaistResolution);
          end
          obj.WaistCalc;
        end
      end
    end
    function set.WaistDesName(obj,name)
      if ismember(string(name),obj.EleNames)
        obj.WaistDesName=string(name);
      else
        error('Unkown name: %s',name);
      end
      obj.WaistCalc;
      caput(obj.pvs.WaistX_DES_Name,char(name));
      caput(obj.pvs.WaistY_DES_Name,char(name));
      obj.WaistDesName=name;
      z=obj.WaistDesZ;
      caput(obj.pvs.WaistX_DES_Z,z);
      caput(obj.pvs.WaistY_DES_Z,z);
    end
    function set.WaistDesNameDS(obj,name)
      if ismember(string(name),obj.EleNames)
        obj.WaistDesNameDS=string(name);
      else
        error('Unkown name: %s',name);
      end
      obj.WaistCalc;
    end
    function set.WaistResolution(obj,res)
      obj.WaistResolution=res;
      obj.WaistCalc();
    end
    function set.WaistShiftDES(obj,dz)
      obj.WaistShiftDES=dz;
      if ~isempty(obj.guihan)
        if abs(obj.WaistShift(1)-obj.WaistShiftDES(1))>obj.WaistResolution
          obj.guihan.WaistX_dzACT.FontColor = 'red' ;
        else
          obj.guihan.WaistX_dzACT.FontColor = 'black' ;
        end
        if abs(obj.WaistShift(2)-obj.WaistShiftDES(2))>obj.WaistResolution
          obj.guihan.WaistY_dzACT.FontColor = 'red' ;
        else
          obj.guihan.WaistY_dzACT.FontColor = 'black' ;
        end
      end
    end
  end
end
