classdef F2_klys < handle
  %KLYSDATA Facet-II LCAV Klystron data
  events
    PVUpdated
  end
  properties
    UseDesignPhases logical = true % Use design L1,L2,L3 phases to override sub-booster live values, else use sub-booster live vals
    KlysPhaseOverride(8,10) single = nan(8,10) % override live values for ~nan values
    KlysAmplOverride(8,10) single = nan(8,10) % override live values for ~nan values
    AutoUpdate string {mustBeMember(AutoUpdate,["All","Compliment"])} = "Compliment" % "All"=phases,ampls,design phases, stats; "Compliment"=stats, design phases only
  end
  properties(SetObservable,AbortSet)
    DesignPhases(1,3) = [-16.5 -31.7 0] % L1,L2,L3
    KlysForceZeroPhase logical = false
    KlysUseSector(1,4) logical = true(1,4) % L0, L1, L2, L3 (local setting to this object)
    KlysInUse(8,10) logical % Klystron in use? (flags which klystrons are physically present)
    UseArchive logical = false % Extract data from archive if true, else get live data
    UpdateRate {mustBeNonnegative} = 0 ;
    ArchiveDate(1,6) = [2021,7,1,12,1,1] % [yr,mnth,day,hr,min,sec]
  end
  properties(SetAccess=protected)
    KlysStat(8,10) uint8 = ones(8,10).*2 % Klystron status 0=ACTIVE 1=DEACT 2=OFF/MNT/IGNORE 3=???
    KlysSectorMap(8,10) uint8 % Map of each klystron to a sector 0,1,2,3 [id 1:4]
    KlysPhase(8,10) single % klystron phase [degrees]
    KlysAmpl(8,10) single % klystron E_noload [MeV]
    LM LucretiaModel
    KlysControl(8,10) uint8 % 0=EPICS, 1=SLC
  end
  properties(SetAccess=protected,Hidden)
    pvlist PV
    pvs
    pvlist_ud
    context
  end
  properties(Access=private)
    listeners
  end
  properties(Constant)
    DesignPhasesPV string = ["SIOC:SYS1:ML00:AO907" "SIOC:SYS1:ML00:AO908" "SIOC:SYS1:ML00:AO909"] % L1/L2/L3 design phases
    KlysBeamcode uint8 = 10
    version single = 1.0
  end
  properties(Dependent)
    KlysStatName(8,10) string
    SectorPhase(1,4) % mean klystron phase in L0,L1,L2,L3
  end
  methods
    function obj = F2_klys(LM,context,AmplOverride,PhaseOverride,klyszerophase,UpdateRate)
      %F2_KLYS Mapping between model and control system klystron data
      %F2_klys(LM [,context,UpdateRate])
      %  LM : LucretiaModel object (local copy made)
      % context : provide if already instantiated PV object elsewhere
      %  UpdateRate(Optional) : auto update data at this rate (s) default=0 (no auto update)
      obj.LM=copy(LM);
      obj.LM.ModelClasses = "LCAV" ;
      if exist('klyszerophase','var') && ~isempty(klyszerophase)
        obj.KlysForceZeroPhase=klyszerophase;
      end
      if exist('context','var') && ~isempty(context)
        obj.context=context;
      end
      if exist('PhaseOverride','var') && ~isempty(PhaseOverride)
        obj.KlysPhaseOverride = PhaseOverride ;
      end
      if exist('AmplOverride','var') && ~isempty(AmplOverride)
        obj.KlysAmplOverride = AmplOverride ;
      end
      % Klystron ID 1:10 = LI10:LI19
      obj.KlysInUse=true(8,10);
      obj.KlysInUse([1:2 5:8],1)=false;
      obj.KlysInUse(3,2)=false;
      obj.KlysInUse(7:8,5)=false;
      obj.KlysInUse(7:8,10)=false;
      obj.KlysSectorMap = ones(8,10).*4 ;
      obj.KlysSectorMap(:,1) = 1 ;
      obj.KlysSectorMap(1:3,2) = 2 ;
      obj.KlysSectorMap(4:8,2) = 3 ;
      obj.KlysSectorMap(:,3:5) = 3 ;
      obj.KlysControl=ones(8,10);
      obj.KlysControl(3:4,1)=0;
      obj.UpdatePVs();
      if exist('UpdateRate','var') && ~isempty(UpdateRate)
        obj.UpdateRate=UpdateRate;
      end
      if obj.UpdateRate == 0
        obj.UpdateData();
      end
    end
    function set.UseArchive(obj,val)
      if val && obj.UpdateRate>0
        obj.UpdateRate=0;
      end
      if ~isempty(obj.pvlist)
        obj.pvlist.pset('UseArchive',val);
      end
      obj.UseArchive=val;
    end
    function set.ArchiveDate(obj,val)
      if ~isempty(obj.pvlist)
        obj.pvlist.pset('ArchiveDate',[val;val]);
      end
      obj.ArchiveDate=val;
    end
    function set.UpdateRate(obj,val)
      if val>0
        if isempty(obj.listeners)
          obj.listeners = addlistener(obj,'PVUpdated',@(~,~) obj.UpdateData) ;
        end
        if obj.AutoUpdate=="All"
          run(obj.pvlist,true,val,obj,'PVUpdated');
        elseif obj.AutoUpdate=="Compliment"
          obj.pvlist_ud = obj.pvlist(startsWith([obj.pvlist.name],["cudstat" "L1DesignPhase" "L2DesignPhase" "L3DesignPhase"])) ;
          run(obj.pvlist_ud,true,val,obj,'PVUpdated');
        end
      else
        if obj.AutoUpdate=="All"
          stop(obj.pvlist);
        elseif obj.AutoUpdate=="Compliment"
          stop(obj.pvlist_ud);
        end
      end
      obj.UpdateRate=val;
    end
    function tab = table(obj)
      names=string([]); phase=[]; ampl=[]; stat=string([]);
      for isec=1:10
        for ikly=1:8
          linacsector = obj.KlysSectorMap(ikly,isec) ;
          if obj.KlysInUse(ikly,isec) && obj.KlysUseSector(linacsector)
            names(end+1)=sprintf("KLYS:LI1%d_%d",isec-1,ikly);
            phase(end+1)=obj.KlysPhase(ikly,isec);
            ampl(end+1)=obj.KlysAmpl(ikly,isec);
            stat(end+1)=obj.KlysStatName(ikly,isec);
          end
        end
      end
      tab=table(phase(:),ampl(:),stat(:),'RowNames',names(:));
      tab.Properties.VariableNames={'Phase [deg]' 'ENLD [MeV]' 'STAT'};
    end
    function set.DesignPhases(obj,pha)
      obj.DesignPhases=pha;
      caput(obj.pvs.L1DesignPhase,pha(1));
      caput(obj.pvs.L2DesignPhase,pha(2));
      caput(obj.pvs.L3DesignPhase,pha(3));
    end
    function set.KlysForceZeroPhase(obj,val)
      obj.KlysForceZeroPhase=logical(val);
      if ~isempty(obj.pvs)
        obj.UpdateData ;
      end
    end
    function sname = get.KlysStatName(obj)
      for isec=1:10
        for ikly=1:8
          linacsector = obj.KlysSectorMap(ikly,isec) ;
          if obj.KlysInUse(ikly,isec) && obj.KlysUseSector(linacsector)
            switch obj.KlysStat(ikly,isec)
              case 0
                sname = "ACTIVE" ;
              case 1
                sname = "DEACT" ;
              case 2
                sname = "OFF/MNT" ;
              case 3
                sname = "UNKNOWN" ;
            end
          else
            sname = "IGNORE" ;
          end
        end
      end
    end
    function pha = get.SectorPhase(obj)
      pha=zeros(1,length(obj.KlysUseSector));
      for isec=1:length(obj.KlysUseSector)
        pha(isec) = mean(obj.KlysPhase(obj.KlysSectorMap==isec & obj.KlysInUse & obj.KlysStat==0)) ;
      end
    end
    function set.KlysUseSector(obj,val)
      obj.KlysUseSector=logical(val);
      if ~isempty(obj.pvlist)
        obj.UpdatePVs;
      end
    end
    function set.KlysInUse(obj,val)
      obj.KlysInUse=logical(val);
      if ~isempty(obj.pvlist)
        obj.UpdatePVs;
      end
    end
    function UpdatePVs(obj)
      if isempty(obj.pvlist)
        if isempty(obj.context)
          context = PV.Initialize(PVtype.EPICS) ; %#ok<*PROP>
        else
          context = obj.context ;
        end
        for isec=1:10
          for ikly=1:8
            obj.pvlist(end+1) = PV(context,'name',"cudstat_"+ikly+"_1"+(isec-1),'pvname',"FCUDKLYS:LI1"+(isec-1)+":"+ikly+":ONBEAM10",'monitor',true, 'pvdatatype',"float" ) ;
            if obj.KlysControl(ikly,isec)==1 % SLC
              obj.pvlist(end+1) = PV(context,'name',sprintf("phase_%d_1%d",ikly,isec-1),'pvname',sprintf("LI1%d:KLYS:%d1:PDES",isec-1,ikly),'monitor',true);
              obj.pvlist(end+1) = PV(context,'name',sprintf("ampl_%d_1%d",ikly,isec-1),'pvname',sprintf("LI1%d:KLYS:%d1:ENLD",isec-1,ikly),'monitor',true);
%               obj.pvlist(end+1) = PV(context,'name',sprintf("stat_%d_1%d",ikly,isec-1),'pvname',sprintf("LI1%d:KLYS:%d1:STAT",isec-1,ikly));
%               obj.pvlist(end+1) = PV(context,'name',sprintf("swrd_%d_1%d",ikly,isec-1),'pvname',sprintf("LI1%d:KLYS:%d1:SWRD",isec-1,ikly));
            else % EPICS
              obj.pvlist(end+1) = PV(context,'name',sprintf("phase_%d_1%d",ikly,isec-1),'pvname',sprintf("KLYS:LI1%d:%d1:PDES",isec-1,ikly),'monitor',true);
              obj.pvlist(end+1) = PV(context,'name',sprintf("ampl_%d_1%d",ikly,isec-1),'pvname',sprintf("KLYS:LI1%d:%d1:ADES",isec-1,ikly),'monitor',true);
%               obj.pvlist(end+1) = PV(context,'name',sprintf("stat_%d_1%d",ikly,isec-1),'pvname',sprintf("KLYS:LI1%d:%d1:FAULTSEQ_STATUS",isec-1,ikly));
%               obj.pvlist(end+1) = PV(context,'name',sprintf("swrd_%d_1%d",ikly,isec-1),'pvname',sprintf("KLYS:LI1%d:%d1:BEAMCODE10_TSTAT",isec-1,ikly));
            end
          end
          obj.pvlist(end+1) = PV(context,'name',sprintf("sbst_1%d_phase",isec-1),'pvname',sprintf("LI1%d:SBST:1:PDES",isec-1),'monitor',true) ;
        end
        obj.pvlist(end+1) = PV(context,'name',"L1DesignPhase",'pvname',obj.DesignPhasesPV(1),'monitor',true,'mode',"rw") ;
        obj.pvlist(end+1) = PV(context,'name',"L2DesignPhase",'pvname',obj.DesignPhasesPV(2),'monitor',true,'mode',"rw") ;
        obj.pvlist(end+1) = PV(context,'name',"L3DesignPhase",'pvname',obj.DesignPhasesPV(3),'monitor',true,'mode',"rw") ;
        pset(obj.pvlist,'debug',0) ;
        obj.pvs = struct(obj.pvlist) ;
      end
      for isec=1:10
        for ikly=1:8
          linacsector = obj.KlysSectorMap(ikly,isec) ;
          if obj.KlysInUse(ikly,isec) && obj.KlysUseSector(linacsector)
            domoni=true;
          else
            domoni=false;
          end
          obj.pvs.(sprintf("ampl_%d_1%d",ikly,isec-1)).monitor=domoni;
          obj.pvs.(sprintf("phase_%d_1%d",ikly,isec-1)).monitor=domoni;
          obj.pvs.(sprintf("cudstat_%d_1%d",ikly,isec-1)).monitor=domoni;
        end
      end
    end
    function UpdateData(obj)
      % First update local klystron data from controls
      if obj.UpdateRate==0
        caget(obj.pvlist([obj.pvlist.monitor]));
      end
      obj.DesignPhases=[obj.pvs.L1DesignPhase.val{1} obj.pvs.L2DesignPhase.val{1} obj.pvs.L3DesignPhase.val{1}];
      obj.GetAmpl;
      obj.GetPhase;
      obj.GetStat;
      fprintf('%s Klystron data and model updated\n',datestr(now));
    end
    function GetAmpl(obj)
      obj.KlysAmpl=nan(8,10);
      for isec=1:10
        for ikly=1:8
          linacsector = obj.KlysSectorMap(ikly,isec) ;
          if ~obj.KlysUseSector(linacsector) || ~obj.KlysInUse(ikly,isec)
            continue
          end
          if ~isnan(obj.KlysAmplOverride(ikly,isec))
            obj.KlysAmpl(ikly,isec) = obj.KlysAmplOverride(ikly,isec) ;
          else
            obj.KlysAmpl(ikly,isec) = obj.pvs.(sprintf("ampl_%d_1%d",ikly,isec-1)).val{1} ;
          end
        end
      end
    end
    function GetPhase(obj)
      obj.KlysPhase=nan(8,10);
      for isec=1:10
        for ikly=1:8
          linacsector = obj.KlysSectorMap(ikly,isec) ;
          if ~obj.KlysUseSector(linacsector) || ~obj.KlysInUse(ikly,isec)
            continue
          end
          if obj.KlysForceZeroPhase
            obj.KlysPhase(ikly,isec) = 0 ;
          elseif ~isnan(obj.KlysPhaseOverride(ikly,isec))
            obj.KlysPhase(ikly,isec) = obj.KlysPhaseOverride(ikly,isec) ;
          else
            obj.KlysPhase(ikly,isec) = obj.pvs.(sprintf("phase_%d_1%d",ikly,isec-1)).val{1} ;
            if isec>1
              if obj.UseDesignPhases && isec>1
                if isec==2 && ikly<3
                  obj.KlysPhase(ikly,isec) = obj.KlysPhase(ikly,isec) + obj.DesignPhases(1) ;
                elseif isec<6
                  obj.KlysPhase(ikly,isec) = obj.KlysPhase(ikly,isec) + obj.DesignPhases(2) ;
                else
                  obj.KlysPhase(ikly,isec) = obj.KlysPhase(ikly,isec) + obj.DesignPhases(3) ;
                end
              else
                obj.KlysPhase(ikly,isec) = obj.KlysPhase(ikly,isec) + obj.pvs.(sprintf("sbst_1%d_phase",isec-1)).val{1}  ;
              end
            end
          end
        end
      end
    end
    function GetStat(obj)
      obj.KlysStat=ones(8,10).*2;
      for isec=1:10
        for ikly=1:8
          linacsector = obj.KlysSectorMap(ikly,isec) ;
          if ~obj.KlysUseSector(linacsector) || ~obj.KlysInUse(ikly,isec)
            continue
          end
          stat = logical(obj.pvs.(sprintf("cudstat_%d_1%d",ikly,isec-1)).val{1}) ;
          if stat || ~isnan(obj.KlysAmplOverride(ikly,isec)) % force status to be OK if overriding ampl settings
            obj.KlysStat(ikly,isec) = 0 ;
          else
            obj.KlysStat(ikly,isec) = 2 ;
          end
%           if obj.KlysControl(ikly,isec)==0 % EPICS
%             if string(obj.pvs.(sprintf("stat_%d_1%d",ikly,isec-1)).val{1}) ~= "OK"
%               obj.KlysStat(ikly,isec) = 3 ;
%             elseif string(obj.pvs.(sprintf("swrd_%d_1%d",ikly,isec-1)).val{1}) ~= "Activated"
%               obj.KlysStat(ikly,isec) = 1 ;
%             else
%               obj.KlysStat(ikly,isec) = 0 ;
%             end
%           else % SCP
%             stat = aidaget(sprintf('KLYS:LI1%d:%d1//TACT',isec-1,ikly),'short',{'BEAM=10' 'DGRP=LIN_KLYS'}) ;
%             if isnan(stat) || isnan(obj.pvs.(sprintf("stat_%d_1%d",ikly,isec-1)).val{1}) || isnan(obj.pvs.(sprintf("swrd_%d_1%d",ikly,isec-1)).val{1})
%               obj.KlysStat(ikly,isec) = 3 ;
%             elseif bitget(stat, 1)
%               obj.KlysStat(ikly,isec) = 0 ;
%             elseif bitget(stat, 2)
%               obj.KlysStat(ikly,isec) = 1 ;
%             elseif bitget(stat, 3)
%               obj.KlysStat(ikly,isec) = 2 ;
%             end
%           end
        end
      end
    end
    function SetKlysPhase(obj,phase)
      obj.KlysPhase=phase;
    end
  end
end