function FacetSetMags(dowrite)
%FACETSETMAGS Print and optionally set model quad values for L1-BC20
%facetSetMags() Print model magnet values
%facetSetMags(true) Write model values to control system
global BEAMLINE

if ~exist('dowrite','var'); dowrite=false; end

% Load and prepare Lucretia FACET2e model, get Beamline indices
load /usr/local/facet/tools/facet2-lattice/Lucretia/models/FACET2e/FACET2e.mat BEAMLINE
SetElementSlices(1,length(BEAMLINE));
i1=findcells(BEAMLINE,'Name','L0BFEND'); i2=findcells(BEAMLINE,'Name','MAINDUMP');

% Model and actual energy profile to use
emod0=arrayfun(@(x) BEAMLINE{x}.P,1:length(BEAMLINE));
EMOD=[0.135 0.335 4.5 9.3];
EACT=[0.1014 0.260 4.5 6]; % @ L1BEG, BC11, BC14, BC20 [0.106 0.28 0.28 10]
doreg=[false false false true]; % flag to set magnet strengths in region L0, L1, L2, L3
E_ind=[findcells(BEAMLINE,'Name','BEGL1F') findcells(BEAMLINE,'Name','BEGL2F') findcells(BEAMLINE,'Name','BEGL3F_1')];
SetDesignMomentumProfile( 1, E_ind(1), 2e-9, BEAMLINE{1}.P, EACT(1) ) ;
SetDesignMomentumProfile( E_ind(1), E_ind(2), 2e-9, EACT(1), EACT(2) ) ;
SetDesignMomentumProfile( E_ind(2), E_ind(3), 2e-9, EACT(2), EACT(3) ) ;
SetDesignMomentumProfile( E_ind(3), length(BEAMLINE), 2e-9, EACT(3), EACT(4) ) ;

% Print quad info and fields, and set to control system if requested
quads=findcells(BEAMLINE,'Class','QUAD',i1,i2);
names=arrayfun(@(x) BEAMLINE{x}.Name,quads,'UniformOutput',false);
[names,iq]=unique(names); quads=quads(iq); [quads,sI]=sort(quads); names=names(sI);
bulk=struct;
control_mags={}; control_vals=[];
bdes_model = zeros(1,length(names)) ;
for iquad=1:length(names)
  if ~doreg(1) && quads(iquad)<E_ind(1)
    continue
  end
  if ~doreg(2) && (quads(iquad)<E_ind(2) && quads(iquad)>E_ind(1))
    continue
  end
  if ~doreg(3) && (quads(iquad)<E_ind(3) && quads(iquad)>E_ind(2))
    continue
  end
  if ~doreg(4) && quads(iquad)>E_ind(3)
    continue
  end
  bdes_model(iquad) = 10*GetTrueStrength(quads(iquad),1) ;
  mname = model_nameConvert(names{iquad}) ;
  
  [~,bdes] = control_magnetGet(mname) ;
  if isnan(bdes)
      fprintf('!!!!!!!!!! No controls for %s !!!!!!!!!\n',mname);
      continue
  end
  
  edes = BEAMLINE{quads(iquad)}.P ;
  emod=emod0(quads(iquad));
  pscale=edes/emod;
  bdes_model1 = bdes_model(iquad) ;
  bdes_model(iquad) = bdes_model(iquad) * pscale ; 
  fprintf('%s(%s): BDES= %g BMOD= %g (kG) EDES= %g EMOD= %g (GeV)\n',names{iquad},mname,bdes_model(iquad),bdes_model1,edes,emod);
%   printf('%s: Current BACT = %g (kG) (BDES=%g)\n',mname,bact,bdes) ;
  % is this a bulk+boost deal?
  [~, par] = control_magnetLGPSMap(mname);
  if isfield(par,'idC') && length(par.idC{1})==2
      bn = regexprep(par.nameL{1},':','') ;
      if isfield(bulk,bn)
          minB = abs(bdes_model(iquad))-abs(par.bM(2)) ;
          maxB = abs(bdes_model(iquad)) ;
          if minB<bulk.(bn).minB
              bulk.(bn).minB = minB ;
          end
          if maxB>bulk.(bn).maxB
              bulk.(bn).maxB = maxB ;
          end
          bulk.(bn).boostname{end+1} = par.nameL{2} ;
          bulk.(bn).boostsign(end+1) = sign(bdes_model(iquad)) ;
          bulk.(bn).boostval(end+1) = bdes_model(iquad) ;
          bulk.(bn).magname{end+1} = mname ;
      else
          bulk.(bn).bulkmax = abs(par.bM(1)) ;
          bulk.(bn).bulksign = sign(par.bM(1)) ;
          bulk.(bn).bulkname = par.nameL{1} ;
          bulk.(bn).minB = abs(bdes_model(iquad))-abs(par.bM(2)) ;
          bulk.(bn).maxB = abs(bdes_model(iquad)) ;
          bulk.(bn).boostname{1} = par.nameL{2} ;
          bulk.(bn).boostsign(1) = sign(bdes_model(iquad)) ;
          bulk.(bn).boostval(1) = bdes_model(iquad) ;
          bulk.(bn).magname{1} = mname ;
      end
  elseif isfield(par,'idC') && length(par.idC{1})>2
      error('Dont know what to do with this: %s',mname);
  else % lucky day, it is a simple 1 PS, 1 magnet deal
      control_mags{end+1}=mname; %#ok<*AGROW>
      control_vals(end+1)=bdes_model(iquad);
  end
  
end
% Set any bulks such that there is max average movement on each boost
% supply
if dowrite && ~isempty(fieldnames(bulk))
    fn=fieldnames(bulk);
    control_mags_bb={}; control_vals_bb=[];
    for ifn=1:length(fn)
        breq = mean([bulk.(fn{ifn}).minB bulk.(fn{ifn}).maxB]) ;
        if breq>bulk.(fn{ifn}).bulkmax
            breq = bulk.(fn{ifn}).bulkmax ;
            if breq<bulk.(fn{ifn}).minB
                error('Out of range on bulk PS: %s',fn{ifn});
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
    control_magnetSet(control_mags_bb',control_vals_bb','action','TRIM');
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
    control_magnetSet(control_mags_bb',control_vals_bb','action','TRIM');
end
% Set the single PS magnets if any
if dowrite && ~isempty(control_mags)
    control_magnetSet(control_mags',control_vals','action','TRIM');
end

% Check BDES correct and BACT somewhere close
for iquad=1:length(names)
  if ~doreg(1) && quads(iquad)<E_ind(1)
    continue
  end
  if ~doreg(2) && (quads(iquad)<E_ind(2) && quads(iquad)>E_ind(1))
    continue
  end
  if ~doreg(3) && (quads(iquad)<E_ind(3) && quads(iquad)>E_ind(2))
    continue
  end
  if ~doreg(4) && quads(iquad)>E_ind(3)
    continue
  end
  mname = model_nameConvert(names{iquad}) ;
  [~,bdes] = control_magnetGet(mname) ;
  if abs(bdes-bdes_model(iquad))/bdes_model(iquad) > 0.01
    fprintf('!!!!! %s: BDES=%g BDES_MODEL=%g\n',mname,bdes,bdes_model(iquad));
  end
end
for iquad=1:length(names)
  if ~doreg(1) && quads(iquad)<E_ind(1)
    continue
  end
  if ~doreg(2) && (quads(iquad)<E_ind(2) && quads(iquad)>E_ind(1))
    continue
  end
  if ~doreg(3) && (quads(iquad)<E_ind(3) && quads(iquad)>E_ind(2))
    continue
  end
  if ~doreg(4) && quads(iquad)>E_ind(3)
    continue
  end
  mname = model_nameConvert(names{iquad}) ;
  [bact,bdes] = control_magnetGet(mname) ;
  if abs(bact-bdes)/bdes > 0.1
    fprintf('!!!!! %s: BACT=%g BDES=%g\n',mname,bact,bdes);
  end
end
