classdef F2_klys < handle
  %KLYSDATA Facet-II LCAV Klystron data
  events
    PVUpdated
  end
  properties(SetObservable)
    KlysUseSector(1,4) logical = true(1,4) % L0, L1, L2, L3 (local setting to this object)
    KlysInUse(8,10) logical % Klystron in use? (flags which klystrons are physically present)
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
    UpdateRate = 0 ;
    context
  end
  properties(Access=private)
    listeners
  end
  properties(Constant)
    KlysBeamcode uint8 = 10
    version single = 1.0
  end
  properties(Dependent)
    KlysStatName(8,10) string
    SectorPhase(1,4) % mean klystron phase in L0,L1,L2,L3
  end
  methods
    function obj = F2_klys(LM,context,UpdateRate)
      %F2_KLYS Mapping between model and control system klystron data
      %F2_klys(LM [,context,UpdateRate])
      %  LM : LucretiaModel object (local copy made)
      % context : provide if already instantiated PV object elsewhere
      %  UpdateRate(Optional) : auto update data at this rate (s) default=0 (no auto update)
      obj.LM=copy(LM);
      obj.LM.ModelClasses = "LCAV" ;
      if exist('context','var') && ~isempty(context)
        obj.context=context;
      end
      if exist('UpdateRate','var') && ~isempty(UpdateRate)
        obj.UpdateRate=UpdateRate;
      end
      aidainit;
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
      if obj.UpdateRate>0
        obj.listeners = addlistener(obj,'PVUpdated',@(~,~) obj.UpdateData) ;
        run(obj.pvlist,true,UpdateRate,obj,'PVUpdated');
      else
        obj.UpdateData();
      end
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
            if obj.KlysControl(ikly,isec)==1 % SLC
              obj.pvlist(end+1) = PV(context,'name',sprintf("phase_%d_1%d",ikly,isec-1),'pvname',sprintf("LI1%d:KLYS:%d1:PDES",isec-1,ikly));
            else
              obj.pvlist(end+1) = PV(context,'name',sprintf("phase_%d_1%d",ikly,isec-1),'pvname',sprintf("KLYS:LI1%d:%d1:PDES",isec-1,ikly));
            end
            obj.pvlist(end+1) = PV(context,'name',sprintf("ampl_%d_1%d",ikly,isec-1),'pvname',sprintf("LI1%d:KLYS:%d1:ENLD",isec-1,ikly));
            obj.pvlist(end+1) = PV(context,'name',sprintf("stat_%d_1%d",ikly,isec-1),'pvname',sprintf("LI1%d:KLYS:%d1:STAT",isec-1,ikly));
            obj.pvlist(end+1) = PV(context,'name',sprintf("swrd_%d_1%d",ikly,isec-1),'pvname',sprintf("LI1%d:KLYS:%d1:SWRD",isec-1,ikly));
          end
        end
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
          obj.pvs.(sprintf("stat_%d_1%d",ikly,isec-1)).monitor=domoni;
          obj.pvs.(sprintf("swrd_%d_1%d",ikly,isec-1)).monitor=domoni;
        end
      end
    end
    function UpdateData(obj)
      % First update local klystron data from controls
      if obj.UpdateRate==0
        caget(obj.pvlist([obj.pvlist.monitor]));
      end
      obj.GetAmpl;
      obj.GetPhase;
      obj.GetStat;
    end
    function GetAmpl(obj)
      obj.KlysAmpl=nan(8,10);
      for isec=1:10
        for ikly=1:8
          linacsector = obj.KlysSectorMap(ikly,isec) ;
          if ~obj.KlysUseSector(linacsector) || ~obj.KlysInUse(ikly,isec)
            continue
          end
          obj.KlysAmpl(ikly,isec) = obj.pvs.(sprintf("ampl_%d_1%d",ikly,isec-1)).val{1} ;
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
          obj.KlysPhase(ikly,isec) = obj.pvs.(sprintf("phase_%d_1%d",ikly,isec-1)).val{1} * 0 ;
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
          stat = aidaget(sprintf('KLYS:LI1%d:%d1//TACT',isec-1,ikly),'short',{'BEAM=10' 'DGRP=LIN_KLYS'}) ;
          if isnan(stat) || isnan(obj.pvs.(sprintf("stat_%d_1%d",ikly,isec-1)).val{1}) || isnan(obj.pvs.(sprintf("swrd_%d_1%d",ikly,isec-1)).val{1})
            obj.KlysStat(ikly,isec) = 3 ;
          elseif bitget(stat, 1)
            obj.KlysStat(ikly,isec) = 0 ;
          elseif bitget(stat, 2)
            obj.KlysStat(ikly,isec) = 1 ;
          elseif bitget(stat, 3)
            obj.KlysStat(ikly,isec) = 2 ;
          end
        end
      end
    end
  end
end