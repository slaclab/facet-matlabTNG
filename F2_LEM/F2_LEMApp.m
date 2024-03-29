classdef F2_LEMApp < handle & matlab.mixin.Copyable & F2_common
  %F2_LEMAPP FACET-II Linac Energy Management application
  % Klystron setup assumptions:
  %  * Sub-booster phases are DesignPhases, with individual Klystrons addative to that
  events
    ModelUpdated
  end
  properties
    uidetachplot logical = false % Generate detached plot
    uishowlegend logical = true % Show legend on plots
  end
  properties(Dependent)
    DesignPhases % Link to Klys.DesignPhases
    UseDesignPhases
  end
  properties(SetObservable,AbortSet)
    UseBendEDEF logical = true % Use DL1, BC11, BC14, BC20 bends to set Edef
    blen(1,4) = [638 638 480 80] % rms Bunch length in L0, L1, L2 & L3 (um)
    bq(1,4) = [2 2 2 2] % Bunch charge in L0, L1, L2 & L3 (nC)
    linacsel(1,5) logical = [true true true true true] % use: L0, L1, L2, L3, S20
    RescaleWithModel logical = false % Set true to rescale based on model rather than extant magnet settings
    KlysZeroPhases logical = false % Force all read phases to zero
    errorstate logical = false
    WriteDest string {mustBeMember(WriteDest,["BDES","BCON","BDESCON"])} = "BDESCON" % Write to BDES, BCON or both
    autoupdate logical = false
  end
  properties(SetAccess=private)
    Eref(1,5) = [0.006 0.125 0.335 4.5 9.3] % reference energies at entrance to regionNames (GeV)
    Echirp(1,4) = [0 0 0 0] % chirp energy [L0,L1,L2,L3]
    fref(1,4) = [1 1 1 1] % Reference fudge factors
    fact(1,4) % extant fudge factors
    regionwakeloss(1,4) = [0 0 0 0] % Total wakefield energy loss per region (MeV)
    klyswakeloss(8,10) = zeros(8,10) % Wakeloss for each station (MeV)
    klysPhaseRef(8,10) = zeros(8,10) % Reference phases for klystron rf stations
    pvlist
    pvs
    aobj
    Klys F2_klys
    Mags F2_mags
    LM LucretiaModel
    wakedat
    RefTwiss % Twiss parameters with scaled magnets
    Pref double
    Pref_mdl double
    Pref_mdlz double
    refdataValid logical = true
    tableinds % selected table coordinates from app GUI
    listeners cell
  end
  properties(Access=private)
    UndoSettings
  end
  properties(Constant)
    version single = 1
    regionNames = ["L0" "L1" "L2" "L3" "S20"]
  end
  methods
    function obj = F2_LEMApp(appobj,KlysZeroPhase)
      %F2_LEMAPP FACET-II Linac Energy Management application
      global BEAMLINE
      
      % Store app object if given
      if exist('appobj','var') && ~isempty(appobj)
        obj.aobj = appobj ;
      end
      
      % Initialize in mode where klystron phases are forced to be zero?
      if exist('KlysZeroPhase','var') && ~isempty(KlysZeroPhase)
        obj.KlysZeroPhases=KlysZeroPhase;
      end
      
      obj.message("Starting LEM Application...");
      
      % Load model
      obj.message("Loading Lucretia Model...");
      obj.LM = LucretiaModel() ;
      obj.Pref_mdl = arrayfun(@(x) BEAMLINE{x}.P,1:length(BEAMLINE));
      obj.Pref_mdlz = arrayfun(@(x) BEAMLINE{x}.Coordi(3),1:length(BEAMLINE));
      [obj.Pref_mdlz,iz]=unique(obj.Pref_mdlz) ; obj.Pref_mdl = obj.Pref_mdl(iz) ;
      
      % Generate PV links
      obj.message("Linking to EPICS PVs...");
      context = PV.Initialize(PVtype.EPICS) ;
      obj.pvlist = [ PV(context,'name',"Data",'pvname',"SIOC:SYS1:ML00:FWF21",'nmax',length(BEAMLINE)*2+5) ;
        PV(context,'name',"DataValid",'pvname',"SIOC:SYS1:ML00:AO957") ;
        PV(context,'name',"BendDL1",'pvname',"BEND:IN10:661:BDES") ;
        PV(context,'name',"BendBC11",'pvname',"BEND:LI11:314:BDES") ;
        PV(context,'name',"BendBC14",'pvname',"BEND:LI14:720:BDES") ;
        PV(context,'name',"BendBC20",'pvname',"LI20:LGPS:1990:BDES") ;
        PV(context,'name',"Q_inj",'pvname',"TORO:IN10:431:TMIT_PC 0:AO850",'conv',0.001) ;
        PV(context,'name',"EGUN",'pvname',"SIOC:SYS1:ML00:AO896",'mode',"rw") ;
        PV(context,'name',"EDL1",'pvname',"SIOC:SYS1:ML00:AO892",'mode',"rw") ;
        PV(context,'name',"EBC11",'pvname',"SIOC:SYS1:ML00:AO893",'mode',"rw") ;
        PV(context,'name',"EBC14",'pvname',"SIOC:SYS1:ML00:AO894",'mode',"rw") ;
        PV(context,'name',"EBC20",'pvname',"SIOC:SYS1:ML00:AO895",'mode',"rw") ;
        PV(context,'name',"BendEdef",'pvname',"SIOC:SYS1:ML00:AO899",'mode',"rw") ;
        PV(context,'name',"L1PHA",'pvname',F2_klys.DesignPhasesPV(1),'mode',"rw") ;
        PV(context,'name',"L2PHA",'pvname',F2_klys.DesignPhasesPV(2),'mode',"rw") ;
        PV(context,'name',"L3PHA",'pvname',F2_klys.DesignPhasesPV(3),'mode',"rw") ;
        ] ;
      pset(obj.pvlist,'debug',0) ;
      obj.pvs = struct(obj.pvlist) ;
      
      % Initialize Eref with last LEM'd values
      obj.Eref = [caget(obj.pvs.EGUN) caget(obj.pvs.EDL1) caget(obj.pvs.EBC11) caget(obj.pvs.EBC14) caget(obj.pvs.EBC20)];
      disp('Initial Eref:');
      disp(obj.Eref);
      
      % Initialize extant property values
      obj.fact = obj.fref ;
      
      % Are we using Bends fro Edef?
      
      % Check bend energies offer a valid solution
      eref = [caget(obj.pvs.EGUN) caget(obj.pvs.BendDL1) caget(obj.pvs.BendBC11) caget(obj.pvs.BendBC14) caget(obj.pvs.BendBC20)];
      for iref=2:length(eref)
        if eref(iref)<=eref(iref-1)
          obj.UseBendEDEF=false;
          if ~isempty(obj.aobj)
            obj.aobj.UseBendEDEFButton.Value=false;
          end
          break
        end
      end
      
      obj.message("Updating with live data...");
      % Load wakefield Eloss data
      ld = load("common/swakelossfit.mat");
      obj.wakedat.sz = ld.sz ; % rms bunch length (um)
      obj.wakedat.Eloss = ld.Eloss ; % energy loss / m / nC (GeV)
      
      % Instantiate klystron & magnet objects
      fname = obj.confdir+"/F2_LEM/overrides.mat" ; % Load previously set Override values
      if exist(fname,'file')
        load(fname,'PhaseOverride','AmplOverride');
      else
        PhaseOverride=[]; AmplOverride=[];
      end
      if exist('KlysZeroPhase','var') && ~isempty(KlysZeroPhase)
        obj.Klys = F2_klys(obj.LM,context,AmplOverride,PhaseOverride,KlysZeroPhase) ;
      else
        obj.Klys = F2_klys(obj.LM,context,AmplOverride,PhaseOverride) ; % Constructs with update of live klystron data
      end
      obj.Klys.UpdateRate = 1 ;
      obj.LM.SetKlystronData(obj.Klys,obj.fact) ; % Update model with Klystron values
      obj.Mags = F2_mags(obj.LM) ;
      obj.Mags.MagClasses = ["QUAD" "SEXT" "SOLENOID"] ;
      
      % Enable magnet setting
      obj.Mags.WriteEnable = true ;
      
      % set reference momentum based on EPICS archive or original model
      obj.GetPref() ;
      
      % Fetch all magnet data once and load into model
      obj.Mags.ReadB(true);
      obj.SetMagsOnEnergy;
      
      % Read measured bunch charge & length data
      obj.ReadWakeMeasData;
      
      % Load last reference energies and run LEM calculations
      for iele=1:length(BEAMLINE)
        BEAMLINE{iele}.P=double(obj.Pref(iele));
      end
      try
        obj.UpdateEREF;
        obj.SetLinacEref(); % Initialize with EREFs given by bend magnets (updates GUI afterwards)
      catch ME
        obj.message("!!!!!!!!! Error processing energy reference:");
        obj.message(ME.message);
        obj.UpdateGUI;
      end
      
      % Enable region select buttons
      if ~isempty(obj.aobj)
        obj.aobj.L0CheckBox.Enable=true;
        obj.aobj.L1CheckBox.Enable=true;
        obj.aobj.L2CheckBox.Enable=true;
        obj.aobj.L3CheckBox.Enable=true;
        obj.aobj.S20CheckBox.Enable=true;
        obj.aobj.SetRegion([0 0 1 1 0]);
        obj.linacsel=[0 0 1 1 0];
      end
      
      obj.message("Initialization complete.");
    end
    function ReadWakeMeasData(obj)
      %READWAKEMEASDATA get bunch charge & bunch length data from EPICS
      obj.bq=ones(size(obj.bq)).*caget(obj.pvs.Q_inj);
    end
    function LaunchMultiknob(obj,cmd)
      rid=find(obj.GetRegionID);
      id=obj.Mags.LM.ModelID;
      magid=ismember(id,rid);
      iserr = obj.Mags.BDES_err ; iserr(~magid) = false ;
      MagNames=obj.Mags.LM.ControlNames;
      switch cmd
        case "Berr"
          sca = obj.Mags.BDES(iserr)-obj.Mags.BDES_cntrl(iserr) ;
          Multiknob(MagNames(iserr),sca(:)) ;
        case "TableSelect"
          if isempty(obj.tableinds)
            error('No table selection data');
          end
          allid = find(magid) ;
          iserr=false(size(iserr)) ;
          iserr(allid(unique(obj.tableinds(:,1)))) = true ;
          sca = obj.Mags.BDES(iserr)-obj.Mags.BDES_cntrl(iserr) ;
          Multiknob(MagNames(iserr),sca(:)) ;
      end
    end
    function DoMagnetScale(obj,cmd)
      %DOMAGNETSCALE Write new scaled magnet strengths to control system
      app=obj.aobj;
      if ~isempty(app)
        obj.aobj.TabGroup2.SelectedTab=obj.aobj.MessagesTab ;
      end
      if obj.errorstate
        obj.message("!!!!!!! ABORTING: LEM is in an error state- see previous messages (press ReadData to try and clear)");
        return
      end
      if isempty(obj.Mags.BDES_cntrl) || isempty(obj.Mags.BDES)
        obj.message("!!!!!!! No magnet strengths read, push 'Read Data' button");
        return
      end
      if obj.RescaleWithModel
        obj.message("Scaling magnets from Design values to match current energy profile...");
      else
        obj.message("Scaling magnets from current values to match energy profile...");
      end
      obj.SaveModel(obj.confdir+"/F2_LEM/lastpref",true);
      obj.UndoSettings.BDES = obj.Mags.BDES ;
      obj.UndoSettings.BDES_cntrl = obj.Mags.BDES_cntrl ; 
      obj.UndoSettings.Pref = obj.Pref ;
      obj.UndoSettings.fref = obj.fref ;
      rid=find(obj.GetRegionID);
      id=obj.Mags.LM.ModelID;
      magid=ismember(id,rid);
      iserr = obj.Mags.BDES_err ; iserr(~magid)=false ;
      obj.Mags.SetBDES_err(iserr) ;
      if exist('cmd','var') && ~isempty(cmd)
        if string(cmd)=="tablesel" % User request to select magnets to trim based on uitable
          if isempty(obj.tableinds)
            error('No table selection data');
          end
          obj.Mags.SetBDES_err(false) ;
          allid = find(magid) ;
          obj.Mags.SetBDES_err(true,allid(unique(obj.tableinds(:,1)))) ;
        end
      end
      obj.UndoSettings.BDES_err = obj.Mags.BDES_err ;
      try
        msg=[]; %#ok<NASGU>
        msg = obj.Mags.WriteBDES ;
      catch ME
        obj.message(sprintf('!!!! Error writing new BDES values: %s',ME.message));
        return
      end
      if ~isempty(msg)
        obj.message(msg(:));
      end
      obj.SetPref;
      if ~isempty(msg)
        obj.message(msg(:));
      end
      obj.UpdateModel;
      if ~isempty(app)
        app.UndoButton.Enable = true ;
        obj.message("Done with magnet scaling. Push 'Undo' to backout changes");
      else
        obj.message("Done with magnet scaling.");
      end
      caput(obj.pvs.EGUN,obj.Eref(1)) ;
      caput(obj.pvs.EDL1,obj.Eref(2)) ;
      caput(obj.pvs.EBC11,obj.Eref(3)) ;
      caput(obj.pvs.EBC14,obj.Eref(4)) ;
      caput(obj.pvs.EBC20,obj.Eref(5)) ;
    end
    function attachGUI(obj,appobj)
      obj.aobj = appobj ;
      % Check bend energies offer a valid solution
      eref = [caget(obj.pvs.EGUN) caget(obj.pvs.BendDL1) caget(obj.pvs.BendBC11) caget(obj.pvs.BendBC14) caget(obj.pvs.BendBC20)];
      for iref=2:length(eref)
        if eref(iref)<=eref(iref-1)
          obj.UseBendEDEF=false;
          if ~isempty(obj.aobj)
            obj.aobj.UseBendEDEFButton.Value=false;
          end
          break
        end
      end
      % Enable region select buttons
      if ~isempty(obj.aobj)
        obj.aobj.L0CheckBox.Enable=true;
        obj.aobj.L1CheckBox.Enable=true;
        obj.aobj.L2CheckBox.Enable=true;
        obj.aobj.L3CheckBox.Enable=true;
        obj.aobj.S20CheckBox.Enable=true;
        obj.aobj.SetRegion([0 0 1 1 0]);
        obj.linacsel=[0 0 1 1 0];
      end
    end
    function UndoMagnetScale(obj)
      app=obj.aobj;
      if ~isempty(app)
        app.TabGroup2.SelectedTab=obj.aobj.MessagesTab ;
      end
      obj.message("Undoing last LEM operation, restoring Magnets...");
      if isempty(obj.UndoSettings)
        obj.message("No previous magnet setting data to undo, aborting.");
      else
        obj.Mags.ReadB(true);
        obj.SetMagsOnEnergy;
        obj.Mags.BDES = obj.UndoSettings.BDES_cntrl ;
        obj.Mags.SetBDES_err(obj.UndoSettings.BDES_err) ;
        try
          msg=[]; %#ok<NASGU>
          msg = obj.Mags.WriteBDES ;
        catch ME
          obj.message(sprintf('!!!! Error writing new BDES values: %s',ME.message));
          return
        end
        if ~isempty(msg)
          obj.message(msg(:));
        end
        obj.Mags.BDES = obj.UndoSettings.BDES ;
        obj.Pref = obj.UndoSettings.Pref ;
        obj.fref = obj.UndoSettings.fref ;
        obj.SetPref;
        obj.UndoSettings = [] ;
        obj.UpdateModel ;
      end
      obj.message("Done.");
      if ~isempty(app)
        app.UndoButton.Enable = false ;
      end
    end
    function message(obj,txt)
      fprintf('%s:\n',datestr(now));
      fprintf('%s\n',txt(:));
      if startsWith(string(txt),"!")
        obj.errorstate=true;
      end
      if ~isempty(obj.aobj)
        if strncmp(txt,"!!",2)
          obj.aobj.TextArea.Value = ["!!!!!!! " + string(datestr(now)) + " : " + regexprep(string(txt),"!+\s*","") ; string(obj.aobj.TextArea.Value) ]  ;
        else
          obj.aobj.TextArea.Value = [string(datestr(now)) + " : " + string(txt) ; string(obj.aobj.TextArea.Value) ]  ;
        end
%         scroll(obj.aobj.TextArea,'bottom'); 2020b
        drawnow;
      end
    end
    function GetPref(obj)
      %GETPREF Set reference momentum from archived values or design model
      global BEAMLINE
      zmod = arrayfun(@(x) BEAMLINE{x}.Coordi(3),1:length(BEAMLINE)) ;
      if obj.RescaleWithModel % Use Model to scale energy
        [zdat,izd]=unique(obj.Pref_mdlz);
        obj.Pref = interp1(zdat,obj.Pref_mdl(izd),zmod) ;
        obj.fref=[1 1 1 1];
        return
      end
      % Get pref from EPICS
      dat = caget(obj.pvs.Data) ; % Reference momenta of last LEM application and reference fudge factors
      datvalid = caget(obj.pvs.DataValid) ;
      try
        datlen = dat(1) ;
        zdat = dat(2:datlen+1) ;
        pdat = dat(2+datlen:1+datlen*2) ;
        if obj.RescaleWithModel
          [zdat,izd]=unique(obj.Pref_mdlz);
          obj.Pref = interp1(zdat,obj.Pref_mdl(izd),zmod) ;
        else
          [zdat,izd]=unique(zdat);
          obj.Pref = interp1(zdat,pdat(izd),zmod) ;
        end
        obj.fref = dat(2+datlen*2:5+datlen*2) ; 
        obj.refdataValid = true ;
      catch
        datvalid=0;
      end
      if datvalid==0
        obj.message(">>>>>>> Stored momentum ref values not valid, using Model momentum ref and unity fudge factors...");
        obj.RescaleWithModel = true ;
        obj.refdataValid = false ;
      end
    end
    function UpdateModel(obj)
      obj.message("Getting new data from controls and updating model...");
      obj.Update();
      if ~obj.RescaleWithModel
        obj.RescaleWithModel=true;
        obj.Update();
        obj.RescaleWithModel=false;
        obj.Update();
      else
        obj.RescaleWithModel=false;
        obj.Update();
        obj.RescaleWithModel=true;
        obj.Update();
      end
      notify(obj,"ModelUpdated");
      obj.message("Done.");
    end
    function Update(obj)
      global BEAMLINE PS
      
      % Check Edef numbers make sense
      if any(diff(obj.Eref)<0)
        iele=findcells(BEAMLINE,'Name','BX10661A'); obj.Eref(2)= PS(BEAMLINE{iele}.PS).Ampl/(3.335640952*BEAMLINE{iele}.Angle*2);  % DL10
        iele=findcells(BEAMLINE,'Name','BCX11314A'); obj.Eref(3)= PS(BEAMLINE{iele}.PS).Ampl/(3.335640952*BEAMLINE{iele}.Angle*2);  % BC11
        iele=findcells(BEAMLINE,'Name','BCX14720A'); obj.Eref(4)= PS(BEAMLINE{iele}.PS).Ampl/(3.335640952*BEAMLINE{iele}.Angle*2);  % BC14
        iele=findcells(BEAMLINE,'Name','B1LE1'); obj.Eref(5)= PS(BEAMLINE{iele}.PS).Ampl/(3.335640952*BEAMLINE{iele}.Angle*2);  % BC20
      end
      
      %UPDATEMODEL Get control system values and put in model
      obj.errorstate = false ;
      % Sync archiver settings
      obj.Mags.UseArchive = obj.UseArchive ;
      obj.Mags.ArchiveDate = obj.ArchiveDate ;
      obj.Klys.UseArchive = obj.UseArchive ;
      obj.Klys.ArchiveDate = obj.ArchiveDate ;
      if ~isempty(obj.aobj)
        obj.aobj.DataValidLamp.Color='black';
      end
      try
        obj.Mags.ReadB(true);
        obj.SetMagsOnEnergy;
      catch ME
        obj.message("!!!!!! Error Getting magnet data:");
        obj.message(ME.message);
        return
      end
      try
        obj.Klys.UpdateData;
      catch ME
        obj.message("!!!!!! Error Getting klystron data:");
        obj.message(ME.message);
        return
      end
      try
        if obj.UseArchive
          obj.LM.SetKlystronData(obj.Klys,ones(size(obj.fact))) ; % Update model with Klystron values
        else
          obj.LM.SetKlystronData(obj.Klys,obj.fact) ; % Update model with Klystron values
          obj.SetLinacEref();
        end
      catch ME
        obj.message("!!!!!! Error Updating Model:");
        obj.message(ME.message);
        return
      end
      if ~isempty(obj.aobj)
        obj.aobj.DataValidLamp.Color='green';
      end
      if ~obj.UseArchive
        obj.GetPref() ;
      else % Make energy profile based on bend strengths and Klystron compliment
        secid = [ obj.LM.ModelRegionID([1 4 6 8 9],1); length(BEAMLINE) ] ; %  L0, L1, L2, L3, S20
        iele=findcells(BEAMLINE,'Name','BX10661A'); obj.Eref(2)= PS(BEAMLINE{iele}.PS).Ampl/(3.335640952*BEAMLINE{iele}.Angle*2);  % DL10
        iele=findcells(BEAMLINE,'Name','BCX11314A'); obj.Eref(3)= PS(BEAMLINE{iele}.PS).Ampl/(3.335640952*BEAMLINE{iele}.Angle*2);  % BC11
        iele=findcells(BEAMLINE,'Name','BCX14720A'); obj.Eref(4)= PS(BEAMLINE{iele}.PS).Ampl/(3.335640952*BEAMLINE{iele}.Angle*2);  % BC14
        iele=findcells(BEAMLINE,'Name','B1LE1'); obj.Eref(5)= PS(BEAMLINE{iele}.PS).Ampl/(3.335640952*BEAMLINE{iele}.Angle*2);  % BC20
        UpdateMomentumProfile(secid(1),secid(2),2e-9,BEAMLINE{secid(1)}.P,0,obj.Eref(2));
        UpdateMomentumProfile(secid(2),secid(3),2e-9,BEAMLINE{secid(2)}.P,0,obj.Eref(3));
        UpdateMomentumProfile(secid(3),secid(4),2e-9,BEAMLINE{secid(3)}.P,0,obj.Eref(4));
        UpdateMomentumProfile(secid(4),length(BEAMLINE),2e-9,BEAMLINE{secid(4)}.P,0,obj.Eref(5));
      end
      if ~obj.RescaleWithModel
        obj.SetExtantModel;
      end
    end
    function UpdateEREF(obj)
      for itry=1:5
        obj.UpdateEREFmdl;
      end
    end
    function UpdateEREFmdl(obj)
      global BEAMLINE KLYSTRON
      %UPDATEEREF Update Eref property based on live Klystron values, update model and scale model magnets
      
      secid = [ obj.LM.ModelRegionID([1 4 6 8 9],1); length(BEAMLINE) ] ;
      eref=obj.Eref;
      wakeloss=zeros(1,4);
      if obj.RescaleWithModel % Load design model instead of live model if request to scale wrt Design
        obj.SetDesignModel;
      else % Scale with respect to momentum reference (last LEM action)
        if length(obj.Pref) ~= length(BEAMLINE)
          obj.message("!!!!!!!! Length mismatch between reference momentum profile and model, aborting update.");
          return
        end
        obj.SetExtantModel;
        for iele=1:length(BEAMLINE)
          BEAMLINE{iele}.P=double(obj.Pref(iele));
        end
      end
      obj.LM.SetKlystronData(obj.Klys,obj.fact) ;
      for isec=1:5 % L0, L1, L2, L3&S20
        % Set Kloss data in LCAV's using lookup table in wakedat property
        % - Eloss is GeV / m / nC -> convert to V/C/m for Lucretia Kloss property
        if isec<5
          kl = interp1(obj.wakedat.sz,obj.wakedat.Eloss,obj.blen(isec))*1e18 ;
          for ikly=findcells(BEAMLINE,'Class','LCAV',double(secid(isec)),double(secid(isec+1)))
            if BEAMLINE{ikly}.Freq==2856
              BEAMLINE{ikly}.Kloss = kl ;
              wakeloss(isec)=wakeloss(isec)+kl*BEAMLINE{ikly}.L*obj.bq(isec)*1e-15 ; % MeV
            end
          end
        end
        % Set energy profile and scale Model magnets
        if isec<5
          stat = UpdateMomentumProfile(double(secid(isec)),double(secid(isec+1)),abs(obj.bq(isec)).*1e-9,eref(isec),1) ;
        else
          stat = UpdateMomentumProfile(double(secid(isec)),double(secid(isec+1)),abs(obj.bq(end)).*1e-9,eref(end),1) ;
        end
        if stat{1}~=1
          error('Error updating momentum profile: %s',stat{2});
        end
        if isec<5
          eref(isec+1) = BEAMLINE{secid(isec+1)}.P ;
        end
      end
      for isec=1:4
        klyid = obj.LM.ModelKlysID(obj.Klys.KlysInUse & obj.Klys.KlysSectorMap==isec) ;
        obj.Echirp(isec) = sum(arrayfun(@(x) KLYSTRON(x).Ampl*sind(KLYSTRON(x).Phase),klyid)) ;
      end
      obj.klyswakeloss=zeros(8,10);
      for isec=1:10
        for ikly=1:8
          if ~obj.Klys.KlysInUse(ikly,isec)
            continue
          end
          klyno = obj.LM.ModelKlysID(ikly,isec) ;
          secid = obj.Klys.KlysSectorMap(ikly,isec) ;
          obj.klyswakeloss(ikly,isec) = sum(arrayfun(@(x) BEAMLINE{x}.Kloss,KLYSTRON(klyno).Element)).*abs(obj.bq(secid))*1e-15 ; % MeV
        end
      end
      obj.SetMagsOnEnergy;
      obj.Eref=eref;
      obj.regionwakeloss=wakeloss;
      % Store required BDES values in controls object and get reference Twiss values for scaled lattice
      obj.Mags.BDES = obj.Mags.LM.ModelBDES ;
      obj.Mags.LM.StoreRefTwiss;
      % Put design or current control BDES values back into model for comparisons
      if obj.RescaleWithModel
        obj.Mags.LM.SetDesignModel("PS");
      else
        obj.Mags.LM.ModelBDES = obj.Mags.BDES_cntrl ;
      end
    end
    function UpdateGUI(obj)
      %UPDATEGUI Update visible GUI tab info
      global BEAMLINE
      if isempty(obj.aobj) || ~isprop(obj.aobj,'TabGroup') % do nothing if no valid GUI present
        return
      end
      app=obj.aobj;
      
      switch app.TabGroup.SelectedTab % left side Tab group
        case app.EREFSTab
          app.GunEref.Value = round(obj.Eref(1).*1e3)./1e3 ;
          app.DL1Eref.Value = round(obj.Eref(2)*1e3)/1e3 ;
          app.BC11Eref.Value = round(obj.Eref(3)*1e3)/1e3 ;
          app.BC14Eref.Value = round(obj.Eref(4)*1e3)/1e3 ;
          app.BC20Eref.Value = round(obj.Eref(5)*1e3)/1e3 ;
          app.EditField.Value = obj.fact(1) ;
          if abs(obj.fref(1)-obj.fact(1))>0.0001; app.EditField.FontColor='red'; else; app.EditField.FontColor='black'; end
          app.EditField_2.Value = double(obj.fref(1)) ;
          app.EditField_3.Value = double(obj.fact(2)) ;
          if abs(obj.fref(2)-obj.fact(2))>0.0001; app.EditField_3.FontColor='red'; else; app.EditField_3.FontColor='black'; end
          app.EditField_4.Value = double(obj.fref(2)) ;
          app.EditField_5.Value = double(obj.fact(3)) ;
          if abs(obj.fref(3)-obj.fact(3))>0.0001; app.EditField_5.FontColor='red'; else; app.EditField_5.FontColor='black'; end
          app.EditField_6.Value = double(obj.fref(3)) ;
          app.EditField_7.Value = double(obj.fact(4)) ;
          if abs(obj.fref(4)-obj.fact(4))>0.0001; app.EditField_7.FontColor='red'; else; app.EditField_7.FontColor='black'; end
          app.EditField_8.Value = double(obj.fref(4)) ;
        case app.WakesTab
          app.L0EditField.Value = abs(obj.bq(1)) ;
          app.L1EditField.Value = abs(obj.bq(2)) ;
          app.L2EditField.Value = abs(obj.bq(3)) ;
          app.L3EditField.Value = abs(obj.bq(4)) ;
          app.EditField_175.Value = obj.blen(1) ;
          app.EditField_176.Value = obj.blen(2) ;
          app.EditField_177.Value = obj.blen(3) ;
          app.EditField_178.Value = obj.blen(4) ;
          app.EditField_179.Value = obj.regionwakeloss(1) ;
          app.EditField_180.Value = obj.regionwakeloss(2) ;
          app.EditField_181.Value = obj.regionwakeloss(3) ;
          app.EditField_182.Value = obj.regionwakeloss(4) ;
        case app.RFTab
          if obj.UseDesignPhases
            app.EditField_169.Editable = true ;
            app.EditField_170.Editable = true ;
            app.EditField_171.Editable = true ;
            app.EditField_169.Value = num2str(obj.Klys.DesignPhases(1)) ;
            app.EditField_170.Value = num2str(obj.Klys.DesignPhases(2)) ;
            app.EditField_171.Value = num2str(obj.Klys.DesignPhases(3)) ;
          else
            app.EditField_169.Editable = false ;
            app.EditField_170.Editable = false ;
            app.EditField_171.Editable = false ;
            app.EditField_169.Value = num2str(obj.Klys.SectorPhase(2)) ;
            app.EditField_170.Value = num2str(obj.Klys.SectorPhase(3)) ;
            app.EditField_171.Value = num2str(obj.Klys.SectorPhase(4)) ;
          end
          app.EditField_172.Value = num2str(round(1000*(obj.Eref(3)-obj.Eref(2)))) ;
          app.EditField_173.Value = num2str(round(1000*(obj.Eref(4)-obj.Eref(3)))) ;
          app.EditField_174.Value = num2str(round(1000*(obj.Eref(5)-obj.Eref(4)))) ;
          app.EditField_183.Value = num2str(round(obj.Echirp(2))) ;
          app.EditField_184.Value = num2str(round(obj.Echirp(3))) ;
          app.EditField_185.Value = num2str(round(obj.Echirp(4))) ;
        case app.MagnetsTab_2
          app.UseExtantStrengthsButton.Value = ~obj.RescaleWithModel ;
          app.UseModelStrengthsButton.Value = obj.RescaleWithModel ;
      end
      switch app.TabGroup2.SelectedTab % right side Tab group
        case app.EProfileTab
          if obj.uidetachplot
            figure;
            h=axes;
          else
            h=app.UIAxes;
          end
          id=find(obj.GetRegionID);
          z_mags=arrayfun(@(x) BEAMLINE{x}.Coordi(3),id);
          p=arrayfun(@(x) BEAMLINE{x}.P,id);
          p_ref=obj.Pref(id);
          dE = obj.Klys.KlysAmpl(obj.Klys.KlysInUse).*cosd(obj.Klys.KlysPhase(obj.Klys.KlysInUse)) - ...
            obj.klyswakeloss(obj.Klys.KlysInUse) ;
          dE_z = obj.LM.ModelKlysZ(obj.Klys.KlysInUse) ;
          dE(dE_z<z_mags(1))=[]; dE_z(dE_z<z_mags(1))=[];
          dE(dE_z>z_mags(end))=[]; dE_z(dE_z>z_mags(end))=[];
          if isempty(dE)
            return
          end
          yyaxis(h,'left');
          stem(h,dE_z,dE); grid(h,'on');
          xlabel(h,'Z [m]'); ylabel(h,'Egain [MeV]');
          yyaxis(h,'right');
          plot(h,z_mags,p,z_mags,p_ref);
          ylabel(h,'E [GeV] | EDIFF [%]');
          yyaxis(h,'left');
          axis(h,[min(z_mags) max(z_mags) 0 max(dE)-mod(max(dE),50)+50]);
          yyaxis(h,'right');
          pmax=max([p(:); p_ref(:)]); pmax=ceil(pmax);
          axis(h,[min(z_mags) max(z_mags) 0 pmax]);
          hold(h,'on');
          co=colororder;
          pdiff=100*abs((p-p_ref)./p_ref); pdiff(pdiff>pmax)=pmax;
          area(h,z_mags,pdiff,'FaceColor',co(2,:),'FaceAlpha',0.3,'EdgeColor',co(2,:),'linestyle','none');
%           area(h,z_mags(pdiff>1),pdiff(pdiff>1),'FaceColor',co(2,:),'FaceAlpha',0.1,'EdgeColor',co(2,:));
          hold(h,'off');
          if obj.uishowlegend
            legend(h,{'EGAIN' 'EACT' 'EREF' 'EDIFF'},'Location','NorthEast');
          else
            legend(h,'off');
          end
          if obj.uidetachplot
            obj.uidetachplot=false;
            AddMagnetPlotZ(id(1),id(end),h);
            obj.UpdateGUI;
          else
            yyaxis(h,'left');
            F2_common.AddMagnetPlotZ(id(1),id(end),h) ;
          end
        case app.KlysEgainTab
          for ikly=1:8
            for isec=1:10
              if obj.Klys.KlysInUse(ikly,isec) && obj.Klys.KlysStat(ikly,isec)==0
                egain = num2str(obj.Klys.KlysAmpl(ikly,isec)*cosd(obj.Klys.KlysPhase(ikly,isec)) - obj.klyswakeloss(ikly,isec),4) ;
              else
                egain="---";
              end
              if isnan(obj.Klys.KlysAmplOverride(ikly,isec))
                col='black';
              else
                col='red';
              end
              app.(sprintf('EditField_%d',(ikly-1)*10+isec+8)).Value=egain;
              app.(sprintf('EditField_%d',(ikly-1)*10+isec+8)).FontColor=col;
            end
          end
        case app.KlysPhaseTab
          for ikly=1:8
            for isec=1:10
              if obj.Klys.KlysInUse(ikly,isec)
                pha = num2str(round(obj.Klys.KlysPhase(ikly,isec))) ;
              else
                pha="---";
              end
              if isnan(obj.Klys.KlysPhaseOverride(ikly,isec))
                col='black';
              else
                col='red';
              end
              app.(sprintf('EditField_%d',(ikly-1)*10+isec+88)).FontColor=col;
              app.(sprintf('EditField_%d',(ikly-1)*10+isec+88)).Value=pha;
            end
          end
        case app.MagnetsTab
          if obj.uidetachplot
            figure;
            h=axes;
          else
            h=app.UIAxes2;
            reset(h);
          end
          id=find(obj.GetRegionID);
          z_mags=arrayfun(@(x) BEAMLINE{x}.Coordi(3),id);
          Z=obj.Mags.LM.ModelBDES_Z;
          gid=Z>z_mags(1) & Z<z_mags(end);
          if ~any(gid)
            return
          end
          bmag=obj.Mags.LM.GetBMAG(obj.Mags,gid) ;
          BMAG_X=bmag(:,1);
          BMAG_Y=bmag(:,2);
          dbdes=100*((obj.Mags.BDES./obj.Mags.BDES_cntrl)-1); dbdes(abs(dbdes)>100)=100*sign(dbdes(abs(dbdes)>100));
          dbdes(obj.Mags.BDES_cntrl==0)=0;
          yyaxis(h,'left');
          stem(h,Z(gid),dbdes(gid));
          axis(h,[min(Z(gid)) max(Z(gid)) -100 100]);
          xlabel(h,'Z [m]'); ylabel(h,'\DeltaBDES [%]');
          yyaxis(h,'right');
          co=colororder;
          bmagmax=max([BMAG_X BMAG_Y],[],2); bmagmax(bmagmax>10)=10;
          bpl=100*(bmagmax(gid)-1);
          bad=bpl>=1; bad1=find(bad,1); if ~isempty(bad1) && bad1>1; bad(bad1:length(bad))=1; end
          good=bpl<1;
          if any(bad) && bad1>1
            good=1:bad1;
          end
          zpl=Z(gid);
          area(h,zpl(bad),bpl(bad),'FaceColor',co(2,:),'FaceAlpha',0.5,'LineStyle','none'); hold(h,'on');
          area(h,zpl(good),bpl(good),'FaceColor',co(5,:),'FaceAlpha',0.5,'LineStyle','none'); hold(h,'off');
%           axis(h,[min(Z(gid)) max(Z(gid)) 0 max(bpl(:))]);
          xlabel(h,'Z [m]'); ylabel(h,'Mismatch (%%)');
          if obj.uidetachplot
            obj.uidetachplot=false;
            AddMagnetPlotZ(id(1),id(end),h);
            obj.UpdateGUI;
          else
            yyaxis(h,'left');
            F2_common.AddMagnetPlotZ(id(1),id(end),h) ;
          end
          yyaxis(h,'left'); % Leave magnets axis as current axis
        case app.MessagesTab
        case app.Table
          tab = table(obj) ;
          if obj.uidetachplot
            uf=uifigure;
            h=uitable(uf,'Data',tab);
            h.Position=[1 1 uf.Position(3:4)];
          else
            app.UITable.Data = tab ;
            h=app.UITable;
          end
          h.ColumnName=tab.Properties.VariableNames;
          h.ColumnSortable = true ;
          h.ColumnEditable=[false false false false false false false false true];
          if obj.uidetachplot
            obj.uidetachplot=false;
            obj.UpdateGUI;
          end
      end
    end
    function inds = GetRegionID(obj)
      %GETREGIONID Return BEAMLINE indices for selected regions
      % Return logical vector of length BEAMLINE
      global BEAMLINE
      inds=true(1,length(BEAMLINE));
      if ~obj.linacsel(1)
        inds(obj.LM.ModelRegionID(1,1):obj.LM.ModelRegionID(3,2))=false;
      end
      if ~obj.linacsel(2)
        inds(obj.LM.ModelRegionID(4,1):obj.LM.ModelRegionID(5,2))=false;
      end
      if ~obj.linacsel(3)
        inds(obj.LM.ModelRegionID(6,1):obj.LM.ModelRegionID(7,2))=false;
      end
      if ~obj.linacsel(4)
        inds(obj.LM.ModelRegionID(8,1):obj.LM.ModelRegionID(8,2))=false;
      end
      if ~obj.linacsel(5)
        inds(obj.LM.ModelRegionID(9,1):obj.LM.ModelRegionID(end,2))=false;
      end
    end
    function SetGunEref(obj,eref)
      %SETGUNEREF Change the initial reference energy for the lattice (GeV)
      % Changes Linac reference energies
      obj.Eref(1) = eref ;
      caput(obj.pvs.EGUN,eref) ;
      if obj.UseBendEDEF
        obj.SetLinacEref();
      else
        obj.SetLinacEref(obj.Eref(2:end));
      end
    end
    function SetLinacEref(obj,eref)
      %SETLINACEREF Change the Linac reference energy (1x4) vector (GeV)
      % Changes extant fudge factors to match
      egun = caget(obj.pvs.EGUN) ;
      obj.Eref(1) = egun ;
      if obj.UseBendEDEF % Use bends to set Eref
        eref = [caget(obj.pvs.BendDL1) caget(obj.pvs.BendBC11) caget(obj.pvs.BendBC14) caget(obj.pvs.BendBC20)];
      elseif ~exist('eref','var')
        eref = obj.Eref(2:end) ;
      elseif length(eref)~=4
        if ~isempty(obj.aobj)
          obj.message('!!!! Error setting ref energy');
          return
        else
          error('Incorrect eref format');
        end
      end
      % Force reference energies to be non-decreasing and fudge factors to start non-zero
      for iref=2:length(obj.Eref)
        if obj.Eref(iref)<obj.Eref(iref-1)
          obj.Eref(iref)=obj.Eref(iref-1)+1e-3;
        end
      end
      for iref=2:length(eref)
        if eref(iref)<eref(iref-1)
          eref(iref)=eref(iref-1)+1e-3;
        end
      end
      obj.fact(obj.fact==0)=obj.fref(obj.fact==0);
      obj.fact(obj.fact<0)=1;
      itry=0;
      isel=1:4;
      while any(abs(obj.Eref(1+isel)-eref(isel))>0.0001) && itry<15
        for iref=isel
          obj.fact(iref) = obj.fact(iref) * (eref(iref)-obj.Eref(iref)) / (obj.Eref(1+iref)-obj.Eref(iref)) ;
          if obj.fact(iref)<0 && iref>1 % cannot have a deceleration case
            obj.fact(iref)=0;
            eref(iref)=obj.Eref(iref);
          end
        end
        obj.fact(isinf(obj.fact))=0; % cases with no energy gain in a sector
        obj.UpdateEREFmdl;
        disp(obj.Eref)
        itry=itry+1;
      end
      obj.UpdateGUI;
    end
    function SetPref(obj)
      % SetPREF Store current BEAMLINE momentum profile and fudge factors into EPICS and Pref property
      global BEAMLINE
      if isempty(BEAMLINE)
        error('No model loaded into memory');
      end
      pref = arrayfun(@(x) BEAMLINE{x}.P,1:length(BEAMLINE)) ;
      zdat = arrayfun(@(x) BEAMLINE{x}.Coordi(3),1:length(BEAMLINE)) ;
      caput(obj.pvs.Data,[length(zdat) zdat pref obj.fact]);
      obj.fref=obj.fact;
      obj.SaveModel(obj.datadir+"/F2_LEM"+datestr(now,30),true);
      obj.GetPref(); % load new reference values locally
      if ~isempty(obj.aobj)
        obj.UpdateGUI;
      end
    end
    function SaveOverrides(obj)
      fname = obj.confdir+"/F2_LEM/overrides.mat" ;
      PhaseOverride = obj.Klys.KlysPhaseOverride ;
      AmplOverride = obj.Klys.KlysAmplOverride ;
      save(fname,'PhaseOverride','AmplOverride');
    end
    function LoadOverrides(obj)
      fname = obj.confdir+"/F2_LEM/overrides.mat" ;
      load(fname,'PhaseOverride','AmplOverride');
      obj.Klys.KlysPhaseOverride = PhaseOverride ;
      obj.Klys.KlysAmplOverride = AmplOverride ;
    end
    function SaveModel(obj,fname,dataonly)
      global BEAMLINE PS KLYSTRON
      LEM = obj ;
      fref = obj.fact ; %#ok<PROPLC>
      pref = arrayfun(@(x) BEAMLINE{x}.P,1:length(BEAMLINE)) ;
      zdat = arrayfun(@(x) BEAMLINE{x}.Coordi(3),1:length(BEAMLINE)) ;
      if exist('dataonly','var') && dataonly
        save(fname,'fref','pref','zdat');
      else
        save(fname,'BEAMLINE','PS','KLYSTRON','LEM','pref','zdat','fref');
      end
    end
    function LoadModel(obj,fname,dataonly)
      global BEAMLINE PS KLYSTRON
      ld=load(fname);
      if ~exist('dataonly','var') || isempty(dataonly) || ~dataonly
        BEAMLINE=ld.BEAMLINE; PS=ld.PS; KLYSTRON=ld.KLYSTRON;
      end
      obj.fref=ld.fref;
      zmod = arrayfun(@(x) BEAMLINE{x}.Coordi(3),1:length(BEAMLINE)) ;
      [zd,izd]=unique(ld.zdat);
      obj.Pref = interp1(zd,ld.pref(izd),zmod) ;
      if any(isnan(obj.Pref))
        obj.message("!!!! Save data does not match current model z value range");
      end
      obj.SetExtantModel;
      obj.UpdateEREF;
      if ~isempty(obj.aobj)
        obj.UpdateGUI;
      end
    end
    function tab = table(obj)
      % TABLE Tabular data format for magnet strengths and reference
      % momenta etc
      % Name | Z | EREF | EACT | BDES | BACT | BMAG_X | BMAG_Y | BERR
      global BEAMLINE
      rid=find(obj.GetRegionID);
      id=obj.Mags.LM.ModelID;
      Z=obj.Mags.LM.ModelBDES_Z;
      NAME=obj.Mags.LM.ControlNames;
      EREF=obj.Pref(id);
      EACT=arrayfun(@(x) double(BEAMLINE{x}.P),id);
      BDES=obj.Mags.BDES;
      BACT=obj.Mags.BDES_cntrl;
      if obj.RescaleWithModel
        bmag=obj.Mags.LM.GetBMAG(obj.Mags) ;
      else
        bmag=obj.Mags.LM.GetBMAG(obj.Mags) ;
      end
      BMAG_X=bmag(:,1);
      BMAG_Y=bmag(:,2);
      Berr=obj.Mags.BDES_err;
      tab=table(NAME(:),string(Z(:)),EREF(:),EACT(:),BDES(:),BACT(:),BMAG_X(:),BMAG_Y(:),Berr(:));
      tab.Properties.VariableNames=["Name"; "Z"; "EREF"; "EACT"; "BDES"; "BACT"; "BMAG_X"; "BMAG_Y"; "BERR"];
      tab=tab(ismember(id,rid),:);
    end
    function tableCallback(obj,indices,newData)
      %TABLECALLBACK callback function for app table
      %tableCallback(inds [,NewData])
      rid=find(obj.GetRegionID);
      id=obj.Mags.LM.ModelID;
      lid=find(ismember(id,rid));
      lid=lid(indices(1));
      if exist('newData','var')
        if indices(2)==9
          obj.Mags.SetBDES_err(newData,lid);
        end
      else
        obj.tableinds=indices;
      end
    end
    function SetExtantModel(obj)
      obj.Mags.LM.SetExtantModel;
      obj.Mags.LM.ModelBDES = obj.Mags.BDES_cntrl;
      if ~isempty(obj.aobj)
        obj.aobj.MagnetReferenceSourceButtonGroup.SelectedObject = obj.aobj.UseExtantStrengthsButton ;
      end
    end
    function SetDesignModel(obj)
      obj.Mags.LM.SetDesignModel;
      if ~isempty(obj.aobj)
        obj.aobj.MagnetReferenceSourceButtonGroup.SelectedObject = obj.aobj.UseModelStrengthsButton ;
      end
    end
  end
  % Set/Get methods
  methods
    function set.DesignPhases(obj,pha)
      obj.Klys.DesignPhases=pha;
      obj.UpdateModel();
    end
    function pha=get.DesignPhases(obj)
      pha=obj.Klys.DesignPhases;
    end
    function set.UseDesignPhases(obj,use)
      obj.Klys.UseDesignPhases=use;
      obj.UpdateModel();
    end
    function use = get.UseDesignPhases(obj)
      use=obj.Klys.UseDesignPhases;
    end
    function set.WriteDest(obj,dest)
      obj.Mags.WriteDest=dest;
    end
    function set.errorstate(obj,val)
      obj.errorstate=logical(val);
      if ~isempty(obj.aobj)
        if obj.errorstate
          obj.aobj.DataValidLamp.Color='red';
        else
          obj.aobj.DataValidLamp.Color='green';
        end
      end
    end
    function set.RescaleWithModel(obj,val)
      if logical(val) ~= obj.RescaleWithModel
        obj.RescaleWithModel=logical(val);
        if ~obj.refdataValid
          obj.RescaleWithModel=true;
        end
        obj.GetPref() ; % set reference momentum based on EPICS archive or original model
        obj.UpdateEREFmdl;
        if ~isempty(obj.aobj)
          obj.UpdateGUI;
        end
      end
    end
    function set.bq(obj,Q)
      obj.bq = abs(Q) ;
      obj.LM.Initial.Q = Q(1)*1e-9 ;
      try
        obj.UpdateEREF; % need to update wakeloss entries
      catch ME
        obj.message("!!!!!!!!! Error processing energy reference:");
        obj.message(ME.message);
      end
    end
    function set.blen(obj,blen)
      obj.blen = blen ;
      obj.LM.Initial.sigz = blen*1e-6 ; 
      obj.UpdateEREF; % need to update wakeloss entries
    end
    function set.linacsel(obj,sel)
      obj.linacsel=sel;
%       obj.Mags.UseSector=sel;
      obj.UpdateEREF;
      obj.UpdateGUI;
    end
    function set.KlysZeroPhases(obj,val)
      obj.KlysZeroPhases=logical(val);
      if isempty(obj.Klys)
        return
      end
      obj.Klys.KlysForceZeroPhase=val;
      try
        obj.UpdateModel;
        obj.UpdateEREF;
        obj.UpdateGUI;
      catch ME
        obj.message("!!!!! Error setting energy profile:");
        obj.message(ME.message);
        if ~isempty(obj.aobj)
          obj.aobj.TabGroup2.SelectedTab=obj.aobj.MessagesTab ;
        end
      end
    end
    function set.UseBendEDEF(obj,val)
      
      val=logical(val);
      obj.UseBendEDEF=val;
      caput(obj.pvs.BendEdef,double(val));
      if val
        % Check bend energies offer a valid solution
        eref = [caget(obj.pvs.EGUN) caget(obj.pvs.BendDL1) caget(obj.pvs.BendBC11) caget(obj.pvs.BendBC14) caget(obj.pvs.BendBC20)];
        for iref=2:length(eref)
          if eref(iref)<=eref(iref-1)
            obj.UseBendEDEF=false;
            caput(obj.pvs.BendEdef,0);
            if ~isempty(obj.aobj)
              obj.aobj.UseBendEDEFButton.Value=false;
            end
            return
          end
        end
        obj.SetLinacEref();
      end
      
    end
    function set.autoupdate(obj,ud)
      
      % Enable auto-updating magnets and klystrons and
      % Register listeners on Mags/Klys updaters
      if ~isempty(obj.listeners)
        delete(obj.listeners{1});
        delete(obj.listeners{2});
        obj.listeners={};
      end
      if ud
        obj.Mags.autoupdate = 2 ;
        obj.Klys.UpdateRate = 1 ;
        obj.listeners{1} = addlistener(obj.Mags,'PVUpdated',@(~,~) obj.UpdateModel) ;
        obj.listeners{2} = addlistener(obj.Klys,'PVUpdated',@(~,~) obj.UpdateModel) ;
      else
        obj.Mags.autoupdate = 0 ;
        obj.Klys.UpdateRate = 0 ;
      end
      obj.autoupdate=ud;
    end
  end
  methods(Static)
    function SetMagsOnEnergy()
      %SETMAGSONENERGY Set B fields of bends according to design bend angles at energies real magnets set to
      global BEAMLINE PS
      psno=unique(arrayfun(@(x) BEAMLINE{x}.PS,findcells(BEAMLINE,'Class','SBEN'))); psno(psno==0)=[];
      for ips=psno
        nele=length(PS(ips).Element);
        for iele=PS(ips).Element
          BEAMLINE{iele}.B=1/nele;
        end
        ang=sum(arrayfun(@(x) BEAMLINE{x}.Angle,PS(ips).Element));
        PS(ips).Ampl=3.335640952*BEAMLINE{iele}.P*ang;
      end
    end
  end
end