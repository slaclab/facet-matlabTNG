classdef F2_mags < handle & matlab.mixin.Copyable & F2_common
  %F2_MAGS FACET-II magnet data
  %
  % BDES in kG units (Lucretia is T for B fields)
  events
    PVUpdated
  end
  properties
    WriteEnable logical = false % Set true to enable writing to control system BDES
    WriteAction string {mustBeMember(WriteAction,["TRIM","PERTURB"])} = "TRIM"
    WriteDest string {mustBeMember(WriteDest,["BDES","BCON","BDESCON"])} = "BDES" % Write to BDES, BCON or both
    RelTolBDES double = 0.001 % Relative Tolerance for BDES errors
    RelTolBACT double = 0.1 % Relative Tolerance for BDES vs BACT errors
    AbsTolBDES double = 0.001 % Absolute Tolerance for BDES errors
    AbsTolBACT double = 0.1 % Absolute Tolerance for BDES vs BACT errors
    UseFudge logical = false % Use available fudge factors?
    UpdateRate {mustBeNonnegative(UpdateRate)} = 1 % Update rate when autoupdate>0 (s)
  end
  properties(SetObservable)
    BDES double % Store location for BDES values to write
    autoupdate uint8 = 0 % 0=no auto update; 1=auto update B; 2= auto update B and Model (updates notify PVUpdated event)
  end
  properties(SetObservable,AbortSet)
    UseSector(1,5) logical = true(1,5) % L0, L1, L2, L3, S20
    MagClasses string {mustBeMember(MagClasses,["QUAD" "SEXT" "SBEN" "XCOR" "YCOR" "SOLENOID"])} = ["QUAD" "SEXT" "SBEN" "XCOR" "YCOR" "SOLENOID"]
  end
  properties(SetAccess=private)
    Initial
    LM LucretiaModel
  end
  properties(SetAccess=private)
    BDES_err % logical vector of BDES values away from desired
    BACT_err % logical vector of BACT values away from desired
    BDES_cntrl % BDES values read from control system
    BACT_cntrl % BACT values read from control system
    BMIN % BMAX from control system
    BMAX % BMIN from control system where available (else set based on BMAX)
    BfudName string % ModelNames corresponding to Bfud (fudge factor scalars)
    Bfud % Fudge factor scalars
  end
  properties(Access=private)
    MonitorList string
    UpdateTimer
  end
  properties(Dependent)
    KDES_cntrl
    KACT_cntrl
    KLDES_cntrl
    KLACT_cntrl
  end
  properties(Constant)
    version single = 1.1
  end
  methods
    function obj = F2_mags(LM)
      %F2_MAGS FACET-II magnet data
      %F2_mags(LM)
      % LM : LucretiaModel object (local copy made)
      obj.LM=copy(LM);
      obj.LM.ModelClasses = obj.MagClasses ;
    end
    function [bdes,bact] = ReadB(obj,SetModel)
      %READB Get magnet strengths from control system or achiver if UseArchive property = true
      %ReadB([SetModel])
      % SetModel (Optional) : also set read B fields into Lucretia model
      [bact,bdes] = obj.MagnetGet(cellstr(obj.LM.ControlNames)) ; 
      bdes=bdes(:)'; bact=bact(:)';
      obj.BDES_err = false(size(bdes)) ;
      obj.BACT_err = obj.BDES_err ;
      if length(obj.BDES) == length(bdes)
        obj.BDES_err(abs(obj.BDES-bdes)./abs(bdes) > obj.RelTolBDES) = true ;
        obj.BDES_err(abs(obj.BDES-bdes) < obj.AbsTolBDES) = false ;
        obj.BACT_err(abs(obj.BDES-bact)./abs(bdes) > obj.RelTolBACT) = true ;
        obj.BACT_err(abs(obj.BDES-bact) < obj.AbsTolBACT) = false ;
      end
      obj.BDES_cntrl = bdes ;
      obj.BACT_cntrl = bact ;
      if exist('SetModel','var') && SetModel
        obj.LM.ModelBDES = bdes ;
      end
      % Write BMIN/BMAX values
      maxpv = obj.LM.ControlNames+":BMAX" ;
      lgps = find(startsWith(maxpv,"LGPS")) ;
      for ipv=lgps(:)'
        t=regexp(maxpv(ipv),"LGPS:(\w+):(\d+)",'tokens','once');
        maxpv(ipv) = t(1) + ":LGPS:" + t(2) + ":BMAX" ;
      end
      minpv = regexprep(maxpv,"(BMAX)$","BMIN") ;
      dominpv = true(size(minpv)); dominpv(contains(minpv,["QUAS","LGPS","SXTS"])) = false ;
      dominpv(~startsWith(minpv,"QUAD") & ~startsWith(minpv,"XCOR") & ~startsWith(minpv,"YCOR")) = false ;
      obj.BMAX = lcaGet(cellstr(maxpv(:))) ;
      obj.BMIN = zeros(size(obj.BMAX)) ;
      if any(dominpv)
        obj.BMIN(dominpv) = lcaGet(cellstr(minpv(dominpv))) ;
      end
      isinv = obj.BMAX<obj.BMIN ;
      tempmax = obj.BMAX(isinv) ;
      obj.BMAX(isinv) = obj.BMIN(isinv) ;
      obj.BMIN(isinv) = tempmax ;
      obj.BMAX=obj.BMAX(:); obj.BMIN=obj.BMIN(:);
      % Apply any fudge factors
      if obj.UseFudge && ~isempty(obj.Bfud)
        [ifud,wfud] = ismember(obj.LM.ModelNames,obj.BfudName) ;
        if any(ifud)
          fud=obj.Bfud(wfud(ifud)); fud=fud(:)';
          obj.BDES_cntrl(ifud) = obj.BDES_cntrl(ifud) .* fud ;
          obj.BACT_cntrl(ifud) = obj.BACT_cntrl(ifud) .* fud ;
          if exist('SetModel','var') && SetModel
            obj.LM.ModelBDES = obj.BDES_cntrl ;
          end
          if ~isempty(obj.BMAX)
            obj.BMIN(ifud) = obj.BMIN(ifud) .* fud(:) ;
            obj.BMAX(ifud) = obj.BMAX(ifud) .* fud(:) ;
            dorev=find(obj.BMIN>obj.BMAX);
            if ~isempty(dorev)
              for irev=dorev
                btmp = obj.BMIN(irev) ;
                obj.BMIN(irev) = obj.BMAX(irev) ;
                obj.BMAX(irev) = btmp ;
              end
            end
          end
        end
      end
    end
    function msg=WriteBDES(obj)
      %SETBDES Write BDES property values to control system
      if ~obj.WriteEnable
        msg="Write functionality disabled, echoing write commands...";
        disp(msg)
      else
        msg=[];
      end
      mnames = obj.LM.ControlNames ;
      bdes_err = obj.BDES_err ;
      if isempty(obj.BDES) || ~any(bdes_err) % all magnets within tolerance, nothing to do
        msg="All magnets within tolerance, nothing to do.";
        return
      end
      % Reverse any fudge factors applied
      bdes = obj.BDES ;
      if obj.UseFudge && ~isempty(obj.Bfud)
        [ifud,wfud] = ismember(obj.LM.ModelNames,obj.BfudName) ;
        if any(ifud)
          bdes(ifud) = bdes(ifud) ./ obj.Bfud(wfud(ifud)) ;
        end
      end
      bulk=struct; control_mags={}; control_vals=[];
      for imag=1:length(mnames)
        if ~bdes_err(imag)
          continue
        end
        % is this a bulk+boost deal?
        [~, par] = control_magnetLGPSMap(char(mnames(imag)));
        if isfield(par,'idC') && length(par.idC{1})==2
          bn = regexprep(par.nameL{1},':','') ;
          if isfield(bulk,bn)
            minB = abs(bdes(imag))-abs(par.bM(2)) ;
            maxB = abs(bdes(imag)) ;
            if minB<bulk.(bn).minB
              bulk.(bn).minB = minB ;
            end
            if maxB>bulk.(bn).maxB
              bulk.(bn).maxB = maxB ;
            end
            bulk.(bn).boostname{end+1} = par.nameL{2} ;
            bulk.(bn).boostsign(end+1) = sign(bdes(imag)) ;
            bulk.(bn).boostval(end+1) = bdes(imag) ;
            bulk.(bn).magname{end+1} = char(mnames(imag)) ;
          else
            bulk.(bn).bulkmax = abs(par.bM(1)) ;
            bulk.(bn).bulksign = sign(par.bM(1)) ;
            bulk.(bn).bulkname = par.nameL{1} ;
            bulk.(bn).minB = abs(bdes(imag))-abs(par.bM(2)) ;
            bulk.(bn).maxB = abs(bdes(imag)) ;
            bulk.(bn).boostname{1} = par.nameL{2} ;
            bulk.(bn).boostsign(1) = sign(bdes(imag)) ;
            bulk.(bn).boostval(1) = bdes(imag) ;
            bulk.(bn).magname{1} = char(mnames(imag)) ;
          end
        elseif isfield(par,'idC') && length(par.idC{1})>2
          error('Dont know what to do with this: %s',mnames(imag));
        else % lucky day, it is a simple 1 PS, 1 magnet deal (or handled by SCP)
          control_mags{end+1}=char(mnames(imag)); %#ok<*AGROW>
          control_vals(end+1)=bdes(imag);
        end
      end
      % Set any bulks such that there is max average movement on each boost
      % supply
      if ~isempty(fieldnames(bulk))
        fn=fieldnames(bulk);
        control_mags_bb={}; control_vals_bb=[];
        for ifn=1:length(fn)
          breq = mean([bulk.(fn{ifn}).minB bulk.(fn{ifn}).maxB]) ;
          if breq>bulk.(fn{ifn}).bulkmax
            breq = bulk.(fn{ifn}).bulkmax ;
            if breq<bulk.(fn{ifn}).minB
              msg=sprintf("!!!!! Out of range on bulk PS: %s",fn{ifn});
              fprintf(2,msg);
              return
            end
          end
          control_vals_bb(end+1) = breq*bulk.(fn{ifn}).bulksign ;
          control_mags_bb{end+1} = bulk.(fn{ifn}).bulkname ;
          [~,bid]=unique(bulk.(fn{ifn}).magname);
          for ibst = bid(:)'
            control_mags_bb{end+1} = bulk.(fn{ifn}).magname{ibst} ;
            breq_bst = bulk.(fn{ifn}).boostval(ibst) - breq ;
            control_vals_bb(end+1) = breq_bst * bulk.(fn{ifn}).boostsign(ibst) ;
          end
        end
        if obj.WriteEnable
          try
            switch obj.WriteDest
              case "BDES"
                control_magnetSet(control_mags_bb',control_vals_bb','action',char(obj.WriteAction));
              case "BCON"
                control_magnetSetC(control_mags_bb',control_vals_bb','action',char(obj.WriteAction));
              case "BDESCON"
                control_magnetSetBC(control_mags_bb',control_vals_bb','action',char(obj.WriteAction));
            end
          catch
            msg=[msg; "!!!!! Error reported setting magnets, check values"];
          end
        else
          msg=[msg; "control_magnetSet: " + string(control_mags_bb(:)) + " = " + string(control_vals_bb(:)) ] ;
        end
        % This doesn't quite get there according to the QUAS values, do
        % fine-trim of boosts to get QUAS values to agree with required
        control_mags_bb={}; control_vals_bb=[];
        for ifn=1:length(fn)
          [~,bid]=unique(bulk.(fn{ifn}).magname);
          for ibst = bid(:)'
            [~,bdesm] = control_magnetGet(bulk.(fn{ifn}).magname{ibst}) ;
            [~,bdes] = control_magnetGet(bulk.(fn{ifn}).boostname{ibst}) ;
            bdes_new = bdes + (bulk.(fn{ifn}).boostval(ibst)-bdesm) ;
            control_mags_bb{end+1} = bulk.(fn{ifn}).magname{ibst} ;
            control_vals_bb(end+1) = bdes_new ;
          end
        end
        if obj.WriteEnable
          try
            switch obj.WriteDest
              case "BDES"
                control_magnetSet(control_mags_bb',control_vals_bb','action',char(obj.WriteAction));
              case "BCON"
                control_magnetSetC(control_mags_bb',control_vals_bb','action',char(obj.WriteAction));
              case "BDESCON"
                control_magnetSetBC(control_mags_bb',control_vals_bb','action',char(obj.WriteAction));
            end
          catch
            msg=[msg; "!!!!! Error reported setting magnets, check values"];
          end
        end
      end
      % Set the single PS magnets if any
      if ~isempty(control_mags)
        if obj.WriteEnable
          switch obj.WriteDest
            case "BDES"
              control_magnetSet(control_mags',control_vals','action',char(obj.WriteAction));
            case "BCON"
              control_magnetSetC(control_mags',control_vals','action',char(obj.WriteAction));
            case "BDESCON"
              control_magnetSetBC(control_mags',control_vals','action',char(obj.WriteAction));
          end
        else
          msg = [msg; "control_magnetSet: " + string(control_mags(:)) + " = " + string(control_vals(:)) ] ;
        end
      end
      
      % Check BDES and BACT within tolerances
      [bdes_new,bact_new]=obj.ReadB;
      for imag = find(obj.BDES_err(:)')
        if bdes_err(imag)
          try
          msg(end+1) = sprintf("!!!!!! %s: BDES out of Tol: Req= %g Act= %g",mnames(imag),obj.BDES(imag),bdes_new(imag));
          catch ME
            throw(ME)
          end
        end
      end
      for imag = find(obj.BACT_err(:)')
        if bdes_err(imag)
          msg(end+1) = sprintf("!!!!!! %s: BACT out of Tol: BDES= %g Act= %g",mnames(imag),obj.BDES(imag),bact_new(imag));
        end
      end
      if ~obj.WriteEnable
        disp(msg);
      end
    end
    function SetBDES_err(obj,val,id)
      if ~exist('id','var') || isempty(id)
        id=true(size(obj.BDES_err));
      end
      if ~islogical(id)
        if any(id<1) || any(id>length(obj.BDES_err))
          error('ID error');
        end
      elseif length(id)~=length(obj.BDES_err)
        error('If supply logical vector, must be same length as BDES_err');
      end
      obj.BDES_err(id)=logical(val);
    end
  end
  methods(Access=private)
    function UpdateProc(obj)
      %UPDATEPROC Process updated PVs
      
      % Check for updated PVs and process as requeted
      ud = lcaNewMonitorValue(cellstr(obj.MonitorList)) ;
      if any(ud)
        lcaGet(cellstr(obj.MonitorList(logical(ud))));
        notify(obj,"PVUpdated");
        switch obj.autoupdate
          case 1
            obj.ReadB();
          case 2
            obj.ReadB(true);
        end
        fprintf('%s Magnets changed, updating model...\n',datestr(now));
      end
    end
    function StopProc(obj)
      if obj.autoupdate
        fprintf(2,'Update timer stopped.\n');
        obj.autoupdate=0;
%         start(obj.UpdateTimer);
      end
    end
  end
  % set/get methods
  methods
    function set.autoupdate(obj,val)
      obj.autoupdate=val;
      if val==0 % stop Update Timer
        stop(obj.UpdateTimer);
        return
      end
      % Add any new PVs to monitor list
      cn = obj.LM.ControlNames ;
      map= obj.LM.LGPSMap ;
      monipv=string([]);
      for iname=1:length(cn)
        if ~isempty(map{iname})
          for ilp=1:length(map{iname})
            monipv(end+1) = map{iname}(ilp) + ":BDES" ;
          end
        else
          monipv(end+1) = cn{iname} + ":BDES" ;
        end
      end
      monipv=monipv(:);
      newmoni=monipv(~ismember(monipv,obj.MonitorList));
      if ~isempty(newmoni)
        obj.MonitorList = [obj.MonitorList; newmoni] ;
        lcaSetMonitor(cellstr(newmoni));
      end
      % (Re)Launch update timer
      if ~isempty(obj.UpdateTimer)
        stop(obj.UpdateTimer);
      end
      obj.UpdateTimer=timer('Period',obj.UpdateRate,'ExecutionMode','fixedRate','TimerFcn',@(~,~) obj.UpdateProc, 'StopFcn', @(~,~) obj.StopProc );
      start(obj.UpdateTimer);
    end
    function set.UseSector(obj,dosec)
      obj.BDES=[];
      obj.BDES_err=[];
      obj.BACT_err=[];
      obj.BMAX=[];
      obj.BMIN=[];
      obj.BDES_cntrl=[];
      obj.BACT_cntrl=[];
      doreg=false(11,1);
      if dosec(1) % L0
        doreg(1:3)=true;
      end
      if dosec(2) % L1
        doreg(4:5)=true;
      end
      if dosec(3) % L2
        doreg(6:7)=true;
      end
      if dosec(4) % L3
        doreg(8)=true;
      end
      if dosec(5) % S20
        doreg(9:11)=true;
      end
      obj.LM.UseRegion=doreg;
      obj.UseSector=dosec;
    end
    function set.MagClasses(obj,cstr)
      obj.BDES=[];
      obj.BDES_err=[];
      obj.BACT_err=[];
      obj.BMAX=[];
      obj.BMIN=[];
      obj.BDES_cntrl=[];
      obj.BACT_cntrl=[];
      obj.LM.ModelClasses = cstr ;
      obj.MagClasses=cstr;
    end
    function set.BDES(obj,bdes)
      if ~isempty(bdes) && length(bdes)~=length(obj.LM.ControlNames)
        error('BDES vector must be length %d',length(obj.LM.ControlNames))
      end
      obj.BDES=bdes(:)';
      obj.BDES_err = false(size(obj.BDES)) ;
      obj.BACT_err = false(size(obj.BDES)) ;
      if length(obj.BDES) == length(obj.BDES_cntrl)
        obj.BDES_err(abs(obj.BDES(:)'-obj.BDES_cntrl(:)')./abs(obj.BDES(:)') > obj.RelTolBDES(:)') = true ;
        obj.BDES_err(abs(obj.BDES(:)'-obj.BDES_cntrl(:)') < obj.AbsTolBDES(:)') = false ;
        obj.BACT_err(abs(obj.BDES(:)'-obj.BACT_cntrl(:)')./abs(obj.BDES(:)') > obj.RelTolBACT(:)') = true ;
        obj.BACT_err(abs(obj.BDES(:)'-obj.BACT_cntrl(:)') < obj.AbsTolBACT(:)') = false ;
      end
    end
    function kdes = get.KDES_cntrl(obj)
      kdes = obj.BDES_cntrl./obj.LM.ModelBDES_L./obj.LM.ModelP./LucretiaModel.GEV2KGM ;
    end
    function kdes = get.KACT_cntrl(obj)
      kdes = obj.BACT_cntrl./obj.LM.ModelBDES_L./obj.LM.ModelP./LucretiaModel.GEV2KGM ;
    end
    function kdes = get.KLDES_cntrl(obj)
      kdes = obj.BDES_cntrl./obj.LM.ModelP./LucretiaModel.GEV2KGM ;
    end
    function kdes = get.KLACT_cntrl(obj)
      kdes = obj.BACT_cntrl./obj.LM.ModelP./LucretiaModel.GEV2KGM ;
    end
  end
end