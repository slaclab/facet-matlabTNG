classdef F2_LEMApp < handle & matlab.mixin.Copyable & F2_common
  %F2_LEMAPP FACET-II Linac Energy Management application
  events
    PVUpdated
  end
  properties
    uidetachplot logical = false % Generate detached plot
    uishowlegend logical = true % Show legend on plots
  end
  properties(SetObservable)
    UseBendEDEF logical = true % Use DL1, BC11, BC14, BC20 bends to set Edef
    blen(1,4) = [735 735 438 90] % rms Bunch length in L0, L1, L2 & L3 (um)
    bq(1,4) = [2 2 2 2] % Bunch charge in L0, L1, L2 & L3 (nC)
    linacsel(1,5) logical = [true true true true true] % use: L0, L1, L2, L3, S20
    RescaleWithModel logical = false % Set true to rescale based on model rather than extant magnet settings
    KlysZeroPhases logical = false % Force all read phases to zero
    errorstate logical = false
  end
  properties(SetAccess=private)
    Eref(1,5) = [0.005 0.135 0.335 4.5 10] % reference energies at entrance to regionNames (GeV)
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
      obj.LM = LucretiaModel("/usr/local/facet/tools/facet2-lattice/Lucretia/models/FACET2e/FACET2e.mat") ;
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
        PV(context,'name',"Q_inj",'pvname',"SIOC:SYS1:ML00:AO850") ;
        PV(context,'name',"EGUN",'pvname',"SIOC:SYS1:ML00:AO896",'mode',"rw") ;
        PV(context,'name',"EDL1",'pvname',"SIOC:SYS1:ML00:AO892",'mode',"rw") ;
        PV(context,'name',"EBC11",'pvname',"SIOC:SYS1:ML00:AO893",'mode',"rw") ;
        PV(context,'name',"EBC14",'pvname',"SIOC:SYS1:ML00:AO894",'mode',"rw") ;
        PV(context,'name',"EBC20",'pvname',"SIOC:SYS1:ML00:AO895",'mode',"rw") ;
        ] ;
      pset(obj.pvlist,'debug',0) ;
      obj.pvs = struct(obj.pvlist) ;
      
      % Initialize extant property values
      obj.fact = obj.fref ;
      
      % set reference momentum based on EPICS archive or original model
      obj.GetPref() ;
      
      obj.message("Updating with live data...");
      % Load wakefield Eloss data
      ld = load("common/swakelossfit.mat");
      obj.wakedat.sz = ld.sz ; % rms bunch length (um)
      obj.wakedat.Eloss = ld.Eloss ; % energy loss / m / nC (GeV)
      
      % Instantiate klystron & magnet objects
      if exist('KlysZeroPhase','var') && ~isempty(KlysZeroPhase)
        obj.Klys = F2_klys(obj.LM,context,KlysZeroPhase) ;
      else
        obj.Klys = F2_klys(obj.LM,context) ; % Constructs with update of live klystron data
      end
      obj.LM.SetKlystronData(obj.Klys,obj.fact) ; % Update model with Klystron values
      obj.Mags = F2_mags(obj.LM) ;
      obj.Mags.MagClasses = ["QUAD" "SEXT"] ;
      obj.Mags.WriteEnable = true ;
      
      % Fetch all magnet data once and load into model
      obj.Mags.ReadB(true);
      
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
      end
      
      obj.message("Initialization complete.");
    end
    function ReadWakeMeasData(obj)
      %READWAKEMEASDATA get bunch charge & bunch length data from EPICS
      obj.bq=ones(size(obj.bq)).*caget(obj.pvs.Q_inj);
    end
    function LaunchMultiknob(obj,cmd)
      rid=find(obj.GetRegionID);
      id=obj.Mags.LM.ModelUniqueID;
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
      id=obj.Mags.LM.ModelUniqueID;
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
      % Get pref from EPICS
      dat = caget(obj.pvs.Data) ; % Reference momenta of last LEM application and reference fudge factors
      datvalid = caget(obj.pvs.DataValid) ;
      zmod = arrayfun(@(x) BEAMLINE{x}.Coordi(3),1:length(BEAMLINE)) ;
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
        obj.Pref = interp1(obj.Pref_mdlz,obj.Pref_mdl,zmod) ;
        obj.RescaleWithModel = true ;
        obj.refdataValid = false ;
      end
    end
    function UpdateModel(obj)
      %UPDATEMODEL Get control system values and put in model
      obj.message("Getting new data from controls and updating model...");
      obj.errorstate = false ;
      if ~isempty(obj.aobj)
        obj.aobj.DataValidLamp.Color='black';
      end
      try
        obj.Mags.ReadB(true);
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
        obj.LM.SetKlystronData(obj.Klys,obj.fact) ; % Update model with Klystron values
        obj.SetLinacEref();
      catch ME
        obj.message("!!!!!! Error Updating Model:");
        obj.message(ME.message);
        return
      end
      if ~isempty(obj.aobj)
        obj.aobj.DataValidLamp.Color='green';
      end
      obj.GetPref() ;
      if ~obj.RescaleWithModel
        obj.SetExtantModel;
      end
      obj.message("Done.");
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
        if obj.linacsel(isec)
          if isec<5
            stat = UpdateMomentumProfile(double(secid(isec)),double(secid(isec+1)),obj.bq(isec).*1e-9,eref(isec),1) ;
          else
            stat = UpdateMomentumProfile(double(secid(isec)),double(secid(isec+1)),obj.bq(end).*1e-9,eref(end),1) ;
          end
          if stat{1}~=1
            error('Error updating momentum profile: %s',stat{2});
          end
          if isec<5
            eref(isec+1) = BEAMLINE{secid(isec+1)}.P ;
          end
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
          obj.klyswakeloss(ikly,isec) = sum(arrayfun(@(x) BEAMLINE{x}.Kloss,KLYSTRON(klyno).Element)).*obj.bq(secid)*1e-15 ; % MeV
        end
      end
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
      if ~isprop(obj.aobj,'TabGroup') % do nothing if no valid GUI present
        return
      end
      app=obj.aobj;
      
      switch app.TabGroup.SelectedTab % left side Tab group
        case app.EREFSTab
          app.GunEref.Value = obj.Eref(1) ;
          app.DL1Eref.Value = obj.Eref(2) ;
          app.BC11Eref.Value = obj.Eref(3) ;
          app.BC14Eref.Value = obj.Eref(4) ;
          app.BC20Eref.Value = obj.Eref(5) ;
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
          app.L0EditField.Value = obj.bq(1) ;
          app.L1EditField.Value = obj.bq(2) ;
          app.L2EditField.Value = obj.bq(3) ;
          app.L3EditField.Value = obj.bq(4) ;
          app.EditField_175.Value = obj.blen(1) ;
          app.EditField_176.Value = obj.blen(2) ;
          app.EditField_177.Value = obj.blen(3) ;
          app.EditField_178.Value = obj.blen(4) ;
          app.EditField_179.Value = obj.regionwakeloss(1) ;
          app.EditField_180.Value = obj.regionwakeloss(2) ;
          app.EditField_181.Value = obj.regionwakeloss(3) ;
          app.EditField_182.Value = obj.regionwakeloss(4) ;
        case app.RFTab
          app.EditField_169.Value = num2str(obj.Klys.SectorPhase(2),4) ;
          app.EditField_170.Value = num2str(obj.Klys.SectorPhase(3),4) ;
          app.EditField_171.Value = num2str(obj.Klys.SectorPhase(4),4) ;
          app.EditField_172.Value = num2str(obj.Eref(3)-obj.Eref(2),4) ;
          app.EditField_173.Value = num2str(obj.Eref(4)-obj.Eref(3),4) ;
          app.EditField_174.Value = num2str(obj.Eref(5)-obj.Eref(4),4) ;
          app.EditField_183.Value = num2str( obj.Echirp(2) , 4 ) ;
          app.EditField_184.Value = num2str( obj.Echirp(3) , 4 ) ;
          app.EditField_185.Value = num2str( obj.Echirp(4) , 4 ) ;
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
          end
        case app.KlysEgainTab
          for ikly=1:8
            for isec=1:10
              if obj.Klys.KlysInUse(ikly,isec) && obj.Klys.KlysStat(ikly,isec)==0
                egain = num2str(obj.Klys.KlysAmpl(ikly,isec)*cosd(obj.Klys.KlysPhase(ikly,isec)) - obj.klyswakeloss(ikly,isec),4) ;
              else
                egain="---";
              end
              app.(sprintf('EditField_%d',(ikly-1)*10+isec+8)).Value=egain;
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
              app.(sprintf('EditField_%d',(ikly-1)*10+isec+88)).Value=pha;
            end
          end
        case app.MagnetsTab
          if obj.uidetachplot
            figure;
            h=axes;
          else
            h=app.UIAxes2;
          end
          id=find(obj.GetRegionID);
          z_mags=arrayfun(@(x) BEAMLINE{x}.Coordi(3),id);
          Z=obj.Mags.LM.ModelBDES_Z;
          gid=Z>z_mags(1) & Z<z_mags(end);
          if ~any(gid)
            return
          end
          if obj.RescaleWithModel
            bmag=obj.Mags.LM.GetBMAG("Design") ;
          else
            bmag=obj.Mags.LM.GetBMAG("Ref") ;
          end
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
          area(h,Z(gid),bmagmax(gid),'FaceColor',co(2,:),'FaceAlpha',0.1,'EdgeColor',co(2,:));
          axis(h,[min(Z(gid)) max(Z(gid)) 1 max(bmagmax(:))]);
          xlabel(h,'Z [m]'); ylabel(h,'BMAG');
          if obj.uidetachplot
            obj.uidetachplot=false;
            AddMagnetPlotZ(id(1),id(end),h);
            obj.UpdateGUI;
          end
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
      if ~exist('eref','var') || isempty(eref) % Use bends to set Eref
        eref = [caget(obj.pvs.BendDL1) caget(obj.pvs.BendBC11) caget(obj.pvs.BendBC14) caget(obj.pvs.BendBC20)];
      elseif length(eref)~=4
        error('4 element vector of energies (GeV) required');
      end
      caput(obj.pvs.EDL1,eref(1)) ;
      caput(obj.pvs.EBC11,eref(2)) ;
      caput(obj.pvs.EBC14,eref(3)) ;
      caput(obj.pvs.EBC20,eref(4)) ;
      itry=0;
%       isel=find(obj.linacsel(2:5));
      isel=1:4;
      while any(abs(obj.Eref(1+isel)-eref(isel))>0.0001) && itry<15
        for iref=isel
          obj.fact(iref) = obj.fact(iref) * (eref(iref)-obj.Eref(iref)) / (obj.Eref(1+iref)-obj.Eref(iref)) ;
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
      id=obj.Mags.LM.ModelUniqueID;
      Z=obj.Mags.LM.ModelBDES_Z;
      NAME=obj.Mags.LM.ControlNames;
      EREF=obj.Pref(id);
      EACT=arrayfun(@(x) double(BEAMLINE{x}.P),id);
      BDES=obj.Mags.BDES;
      BACT=obj.Mags.BDES_cntrl;
      if obj.RescaleWithModel
        bmag=obj.Mags.LM.GetBMAG("Design") ;
      else
        bmag=obj.Mags.LM.GetBMAG("Ref") ;
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
      id=obj.Mags.LM.ModelUniqueID;
      lid=find(ismember(id,rid));
      lid=lid(indices(1));
      if exist('newData','var')
        if indices(2)==9
          obj.Mags.SetBDES_err(lid,newData);
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
      obj.bq = Q ;
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
      if val
        obj.SetLinacEref();
      end
      obj.UseBendEDEF=val;
    end
  end
end