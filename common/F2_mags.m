classdef F2_mags < handle
  %F2_MAGS FACET-II magnet data
  events
    PVUpdated
  end
  properties
    WriteEnable logical = false % Set true to enable writing to control system BDES
    RelTolBDES double = 0.001 % Relative Tolerance for BDES errors
    RelTolBACT double = 0.1 % Relative Tolerance for BDES vs BACT errors
    AbsTolBDES double = 0.001 % Absolute Tolerance for BDES errors
    AbsTolBACT double = 0.1 % Absolute Tolerance for BDES vs BACT errors
  end
  properties(SetObservable)
    BDES double
    UseSector(1,5) logical = true(1,5) % L0, L1, L2, L3, S20
    MagClasses string {mustBeMember(MagClasses,["QUAD" "SEXT" "SBEN" "XCOR" "YCOR"])} = ["QUAD" "SEXT" "SBEN" "XCOR" "YCOR"]
  end
  properties(SetAccess=private)
    Initial
    LM LucretiaModel
  end
  properties(SetAccess=private)
    BDES_err
    BACT_err
    BDES_cntrl
    BACT_cntrl
  end
  properties(Constant)
    version single = 1.0
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
      %READB Get magnet strengths from control system
      %ReadB([SetModel])
      % SetModel (Optional) : also set read B fields into Lucretia model
      [bact,bdes] = control_magnetGet(cellstr(obj.LM.ControlNames)) ; bdes=bdes(:)'; bact=bact(:)';
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
            minB = abs(obj.BDES(imag))-abs(par.bM(2)) ;
            maxB = abs(obj.BDES(imag)) ;
            if minB<bulk.(bn).minB
              bulk.(bn).minB = minB ;
            end
            if maxB>bulk.(bn).maxB
              bulk.(bn).maxB = maxB ;
            end
            bulk.(bn).boostname{end+1} = par.nameL{2} ;
            bulk.(bn).boostsign(end+1) = sign(obj.BDES(imag)) ;
            bulk.(bn).boostval(end+1) = obj.BDES(imag) ;
            bulk.(bn).magname{end+1} = char(mnames(imag)) ;
          else
            bulk.(bn).bulkmax = abs(par.bM(1)) ;
            bulk.(bn).bulksign = sign(par.bM(1)) ;
            bulk.(bn).bulkname = par.nameL{1} ;
            bulk.(bn).minB = abs(obj.BDES(imag))-abs(par.bM(2)) ;
            bulk.(bn).maxB = abs(obj.BDES(imag)) ;
            bulk.(bn).boostname{1} = par.nameL{2} ;
            bulk.(bn).boostsign(1) = sign(obj.BDES(imag)) ;
            bulk.(bn).boostval(1) = obj.BDES(imag) ;
            bulk.(bn).magname{1} = char(mnames(imag)) ;
          end
        elseif isfield(par,'idC') && length(par.idC{1})>2
          error('Dont know what to do with this: %s',mnames(imag));
        else % lucky day, it is a simple 1 PS, 1 magnet deal (or handled by SCP)
          control_mags{end+1}=char(mnames(imag)); %#ok<*AGROW>
          control_vals(end+1)=obj.BDES(imag);
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
          control_magnetSet(control_mags_bb',control_vals_bb','action','TRIM');
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
          control_magnetSet(control_mags_bb',control_vals_bb','action','TRIM');
        end
      end
      % Set the single PS magnets if any
      if ~isempty(control_mags)
        if obj.WriteEnable
          control_magnetSet(control_mags',control_vals','action','TRIM');
        else
          msg = [msg; "control_magnetSet: " + string(control_mags(:)) + " = " + string(control_vals(:)) ] ;
        end
      end
      
      % Check BDES and BACT within tolerances
      [bdes,bact]=obj.ReadB;
      for imag = find(obj.BDES_err)
        if bdes_err(imag)
          msg(end+1) = sprintf("!!!!!! %s: BDES out of Tol: Req= %g Act= %g",mnames(imag),obj.BDES(imag),bdes(imag));
        end
      end
      for imag = find(obj.BACT_err)
        if bdes_err(imag)
          msg(end+1) = sprintf("!!!!!! %s: BACT out of Tol: BDES= %g Act= %g",mnames(imag),obj.BDES(imag),bact(imag));
        end
      end
    end
    function set.UseSector(obj,dosec)
      if ~isequal(dosec,obj.UseSector)
        obj.BDES=[];
        obj.BDES_err=[];
        obj.BACT_err=[];
      end
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
      if ~isequal(cstr,obj.MagClasses)
        obj.BDES=[];
        obj.BDES_err=[];
        obj.BACT_err=[];
      end
      obj.LM.ModelClasses = cstr ;
      obj.MagClasses=cstr;
    end
    function set.BDES(obj,bdes)
      if ~isempty(bdes) && length(bdes)~=length(obj.LM.ControlNames)
        error('BDES vector must be length %d',length(obj.LM.ControlNames))
      end
      obj.BDES=bdes;
      obj.BDES_err = false(size(obj.BDES)) ;
      obj.BACT_err = false(size(obj.BDES)) ;
      if length(obj.BDES) == length(obj.BDES_cntrl)
        obj.BDES_err(abs(obj.BDES-obj.BDES_cntrl)./abs(obj.BDES) > obj.RelTolBDES) = true ;
        obj.BDES_err(abs(obj.BDES-obj.BDES_cntrl) < obj.AbsTolBDES) = false ;
        obj.BACT_err(abs(obj.BDES-obj.BACT_cntrl)./abs(obj.BDES) > obj.RelTolBACT) = true ;
        obj.BACT_err(abs(obj.BDES-obj.BACT_cntrl) < obj.AbsTolBACT) = false ;
      end
    end
    function SetBDES_err(obj,val,id)
      if ~exist('id','var') || isempty(id)
        id=1:length(obj.BDES_err);
      end
      if any(id<1) || any(id>length(obj.BDES_err))
        error('ID error');
      end
      obj.BDES_err(id)=logical(val);
    end
  end
end