classdef LucretiaModel < handle & matlab.mixin.Copyable
  %LUCRETIAMODEL Interface to Lucretia model
  properties
    Initial % Lucretia Initial structure
  end
  properties(Dependent)
    ModelP double % GeV
    ModelBDES double % kG.m^(N-1)
    ModelBDES_Z double
    ModelRegionID(11,2) uint32 % Mapping from regions boundaries to BEAMLINE array
    ModelRegionE(11,2) single % Region boundary  energy (GeV)
    ControlNames string % Names used by control system
    ModelNames string % MAD (Lucretia) model names (unique magnets)
    ModelID uint16 % BEAMLINE indices of all elements wihin range of UseRegion selection
    ModelUniqueID uint16 % BEAMLINE indices of all elements wihin range of UseRegion selection, for only 1 of each split element
  end
  properties(Constant)
    LucretiaModelVersion single = 1.0 
    ModelRegionName(11,1) string = ["INJ";"L0";"DL1";"L1";"BC11";"L2";"BC14";"L3";"BC20";"FFS";"SPECTDUMP"]
  end
  properties(Access=private)
    ModelDat
    ModelDesign % Storage for original BEAMLINE,PS,KLYSTRON arrays
    ModelTempStore
  end
  properties(SetAccess=private)
    ModelKlysID(8,10) uint8 = zeros(8,10) % Linac KLYSTRON model ID's (Sector 10-19,stations 1-8)
    ModelKlysZ(8,10) = zeros(8,10) % Central z location of each structure
    ModelDesignFile string
    DesignTwiss % Twiss parameters for design model
    RefTwiss % Some other reference Twiss parameter set
  end
  properties(SetObservable)
    ModelClasses string  = "All"
    UseRegion(11,1) logical = true(11,1)
  end
  methods
    function obj = LucretiaModel(LucretiaFile)
      global BEAMLINE PS KLYSTRON
      if ~exist('LucretiaFile','var')
        error('Must provide Lucretia beamline file');
      end
      % Load Lucretia BEAMLINE database and configure
      ld = load(LucretiaFile,'BEAMLINE','Initial') ;
      if ~isfield(ld,'BEAMLINE') || ~isfield(ld,'Initial')
        error('Beamline and/or Initial structures not found in provided Lucretia file');
      end
      dd=dir(LucretiaFile);
      obj.ModelDesignFile = string(regexprep(dd.name,'\.mat$','')) ;
      BEAMLINE = ld.BEAMLINE ;
      KLYSTRON=[]; PS=[];
      obj.Initial = ld.Initial ;
      SetElementSlices(1,length(BEAMLINE));
      SetElementBlocks(1,length(BEAMLINE));
      SetIndependentPS(1,length(BEAMLINE));
      % S-band klystrons
      AssignToKlystron(findcells(BEAMLINE,'Name','L0AF_*'),1); obj.ModelKlysID(3,1) = 1 ;
      obj.ModelKlysZ(3,1) = mean([arrayfun(@(x) BEAMLINE{x}.Coordi(3),KLYSTRON(end).Element) BEAMLINE{KLYSTRON(end).Element(end)}.Coordf(3)]) ;
      AssignToKlystron(findcells(BEAMLINE,'Name','L0BF_*'),2); obj.ModelKlysID(4,1) = 2 ;
      obj.ModelKlysZ(4,1) = mean([arrayfun(@(x) BEAMLINE{x}.Coordi(3),KLYSTRON(end).Element) BEAMLINE{KLYSTRON(end).Element(end)}.Coordf(3)]) ;
      for sector=11:19
        for klyno=1:8
          id=findcells(BEAMLINE,'Name',sprintf('K%d_%d*',sector,klyno));
          if any(ismember(findcells(BEAMLINE,'Name','K1X*'),id)); continue; end
          if ~isempty(id) && (~isfield(BEAMLINE{id(1)},'Klystron') || ~BEAMLINE{id(1)}.Klystron)
            AssignToKlystron(id,length(KLYSTRON)+1);
            obj.ModelKlysID(klyno,sector-9) = length(KLYSTRON) ;
            obj.ModelKlysZ(klyno,sector-9) = mean([arrayfun(@(x) BEAMLINE{x}.Coordi(3),KLYSTRON(end).Element) BEAMLINE{KLYSTRON(end).Element(end)}.Coordf(3)]) ;
          end
        end
      end
      MovePhysicsVarsToKlystron( 1:length(KLYSTRON) ) ;
      MovePhysicsVarsToPS( 1:length(PS) ) ;
      obj.ModelDesign.BEAMLINE=BEAMLINE;
      obj.ModelDesign.PS=PS;
      obj.ModelDesign.KLYSTRON=KLYSTRON;
      [~,obj.DesignTwiss]=GetTwiss(1,length(BEAMLINE),obj.Initial.x.Twiss,obj.Initial.y.Twiss);
    end
    function set.UseRegion(obj,reg)
      obj.ModelDat=[]; % Clear indexing
      obj.UseRegion=reg;
      obj.ModelClasses=obj.ModelClasses;
    end
    function set.ModelClasses(obj,cstr)
      global BEAMLINE
      cstr=string(cstr);
      obj.ModelDat=[]; % Clear indexing
      obj.ModelDat.ClassID=[];
      if isempty(BEAMLINE) || ismember("All",cstr)
        return
      end
      if ~all(ismember(cstr,["QUAD","SBEN","SEXT","XCOR","YCOR","DRIF","MULT","LCAV","TCAV","MARK","PROF","INSTR","MONI"]))
        error('Bad BEAMLINE Class provided');
      end
      for iclass=1:length(cstr)
        obj.ModelDat.ClassID=[obj.ModelDat.ClassID findcells(BEAMLINE,'Class',char(cstr(iclass)))] ;
      end
      obj.ModelClasses=cstr;
    end
    function emod = get.ModelRegionE(obj)
      global BEAMLINE
      id = obj.ModelRegionID ;
      emod = zeros(length(id),2,'single') ;
      for ireg=1:length(id)
        emod(ireg,1) = BEAMLINE{id(ireg,1)}.P ;
        emod(ireg,2) = BEAMLINE{id(ireg,2)}.P ;
      end
      obj.ModelDat.RegionE = emod ;
    end
    function id = get.ModelUniqueID(obj)
      GetModelDat(obj,"UniqueModelID");
      id = obj.ModelID(ismember(obj.ModelID,obj.ModelDat.UniqueModelID)) ;
    end
    function names = get.ModelNames(obj)
      % MODELNAMES - model names for BEAMLINE indices for which UseRegion selected
      global BEAMLINE
      if isempty(BEAMLINE)
        names="";
        return
      end
      GetModelDat(obj,"ModelNames");
      names = obj.ModelDat.ModelNames(obj.ModelUniqueID) ;
    end
    function names = get.ControlNames(obj)
      % MODELNAMES - control system reference names for BEAMLINE indices for which UseRegion selected
      global BEAMLINE
      if isempty(BEAMLINE)
        names="";
        return
      end
      names = string(model_nameConvert(cellstr(obj.ModelNames))) ;
      names(obj.ModelNames=="QA10361") = "QUAD:IN10:361" ;
      names(obj.ModelNames=="QA10371") = "QUAD:IN10:371" ;
    end
    function id = get.ModelID(obj)
      global BEAMLINE
      if isempty(BEAMLINE)
        id = [];
        return
      end
      lid = false(1,length(BEAMLINE));
      rid=obj.ModelRegionID;
      for ireg=find(obj.UseRegion(:)')
        lid(rid(ireg,1):rid(ireg,2))=true;
      end
      id=find(lid);
      if isfield(obj.ModelDat,'ClassID') && ~isempty(obj.ModelDat.ClassID)
        id=id(ismember(id,obj.ModelDat.ClassID));
      end
    end
    function id = get.ModelRegionID(obj)
      GetModelDat(obj,"RegionID");
      id = obj.ModelDat.RegionID ;
    end
    function P = get.ModelP(obj)
      global BEAMLINE
      if isempty(BEAMLINE)
        P=[];
        return
      end
      P = arrayfun(@(x) BEAMLINE{x}.P,1:length(BEAMLINE)) ;
      P = P(obj.ModelUniqueID) ;
    end
    function bdes = get.ModelBDES(obj)
      global BEAMLINE
      if isempty(BEAMLINE)
        bdes=[];
        return
      end
      GetModelDat(obj,"ModelBDES_i");
      bdes = arrayfun(@(x) GetTrueStrength(x,1),obj.ModelDat.ModelBDES_i).*10 ;
      ind = ismember(obj.ModelDat.ModelBDES_i,obj.ModelUniqueID) ;
      bdes=bdes(ind) ;
    end
    function set.ModelBDES(obj,bdes)
      global BEAMLINE PS
      if isempty(BEAMLINE)
        error('No model in memory');
      end
      GetModelDat(obj,"ModelBDES_i");
      ind = obj.ModelDat.ModelBDES_i(ismember(obj.ModelDat.ModelBDES_i,obj.ModelUniqueID)) ;
      if length(bdes) ~= length(ind)
        error('Must provide BDES vector same length as model (%d)\n',length(ind));
      end
      for imag=1:length(ind)
        PS(BEAMLINE{ind(imag)}.PS).Ampl = bdes(imag)./10 ;
        PS(BEAMLINE{ind(imag)}.PS).SetPt = bdes(imag)./10 ;
      end
    end
    function bdes = get.ModelBDES_Z(obj)
      global BEAMLINE
      if isempty(BEAMLINE)
        bdes=[];
        return
      end
      GetModelDat(obj,["ModelBDES_Z" "ModelBDES_i"]);
      ind = ismember(obj.ModelDat.ModelBDES_i,obj.ModelUniqueID) ;
      bdes=obj.ModelDat.ModelBDES_Z(ind) ;
    end
    function StoreRefTwiss(obj)
      %STOREREFTWISS Get current Twiss function values and store in RefTwiss object parameter
      global BEAMLINE
      
      % get current Twiss parameters
      I=obj.Initial;
      reg1=find(obj.UseRegion,1);
      if reg1>1
        i1=obj.ModelRegionID(reg1,1);
        I = TwissToInitial(obj.DesignTwiss,i1,I);
      else
        i1=1;
      end
      [~,T]=GetTwiss(i1,length(BEAMLINE),I.x.Twiss,I.y.Twiss);
      if reg1>1
        fn=fieldnames(T);
        for ifn=1:length(fn)
          T.(fn{ifn}) = [obj.DesignTwiss.(fn{ifn})(1:i1-2) T.fn{ifn}] ;
        end
      end
      obj.RefTwiss = T ;
    end
    function bmag = GetBMAG(obj,refmodel)
      %GETBMAG Get BMAG optical mismatch parameter between current and design or reference model
      %bmag(x,y) = GetBMAG("Design" | "Ref")
      global BEAMLINE 
      % get current Twiss parameters
      I=obj.Initial;
      reg1=find(obj.UseRegion,1);
      if reg1>1
        i1=obj.ModelRegionID(reg1,1);
        I = TwissToInitial(obj.DesignTwiss,i1,I);
      else
        i1=1;
      end
      [~,T]=GetTwiss(i1,length(BEAMLINE),I.x.Twiss,I.y.Twiss);
      if reg1>1
        fn=fieldnames(T);
        for ifn=1:length(fn)
          T.(fn{ifn}) = [obj.DesignTwiss.(fn{ifn})(1:i1-2) T.fn{ifn}] ;
        end
      end
      idsel=1+find(ismember(i1:length(BEAMLINE),obj.ModelUniqueID));
      switch refmodel
        case "Design"
          bref_x=obj.DesignTwiss.betax(idsel);
          bref_y=obj.DesignTwiss.betay(idsel);
          aref_x=obj.DesignTwiss.alphax(idsel);
          aref_y=obj.DesignTwiss.alphay(idsel);
        case "Ref"
          bref_x=obj.RefTwiss.betax(idsel);
          bref_y=obj.RefTwiss.betay(idsel);
          aref_x=obj.RefTwiss.alphax(idsel);
          aref_y=obj.RefTwiss.alphay(idsel);
        otherwise
          error('Choose "Design" or "Ref" for comparison');
      end
      bx=obj.bmag(bref_x,aref_x,T.betax(idsel),T.alphax(idsel));
      by=obj.bmag(bref_y,aref_y,T.betay(idsel),T.alphay(idsel));
      bmag=[bx(:) by(:)];
    end
  end
  methods
    function GetModelDat(obj,dname)
      %GETMODELDAT Extract model data from Lucretia arrays
      global BEAMLINE
      dname=string(dname);
      for iname=1:length(dname)
        if ~isfield(obj.ModelDat,dname(iname))
          switch dname(iname)
            case "RegionID"
              %    1    2     3    4     5      6    7      8    9      10      11
              % ["INJ";"L0";"DL1";"L1";"BC11";"L2";"BC14";"L3";"BC20";"FFS";"SPECTDUMP"]
              id = zeros(11,2,'uint32') ;
              id(1,1)=1;
              id(1,2)=findcells(BEAMLINE,'Name','L0BFBEG')-1;
              id(2,1)=findcells(BEAMLINE,'Name','L0BFBEG');
              id(2,2)=findcells(BEAMLINE,'Name','L0BFEND');
              id(3,1)=findcells(BEAMLINE,'Name','L0BFEND')+1;
              id(3,2)=findcells(BEAMLINE,'Name','BEGL1F')-1;
              id(4,1)=findcells(BEAMLINE,'Name','BEGL1F');
              id(4,2)=findcells(BEAMLINE,'Name','ENDL1F');
              id(5,1)=findcells(BEAMLINE,'Name','ENDL1F')+1;
              id(5,2)=findcells(BEAMLINE,'Name','ENDBC11_2');
              id(6,1)=findcells(BEAMLINE,'Name','ENDBC11_2')+1;
              id(6,2)=findcells(BEAMLINE,'Name','ENDL2F');
              id(7,1)=findcells(BEAMLINE,'Name','ENDL2F')+1;
              id(7,2)=findcells(BEAMLINE,'Name','ENDBC14_2');
              id(8,1)=findcells(BEAMLINE,'Name','ENDBC14_2')+1;
              id(8,2)=findcells(BEAMLINE,'Name','ENDL3F_2');
              id(9,1)=findcells(BEAMLINE,'Name','ENDL3F_2')+1;
              id(9,2)=findcells(BEAMLINE,'Name','BEGFF20')-1;
              id(10,1)=findcells(BEAMLINE,'Name','BEGFF20');
              id(10,2)=findcells(BEAMLINE,'Name','MIP');
              id(11,1)=findcells(BEAMLINE,'Name','MIP')+1;
              id(11,2)=length(BEAMLINE);
              obj.ModelDat.RegionID = id ;
            case "ModelNames"
              obj.ModelDat.ModelNames = string(cellfun(@(x) x.Name,BEAMLINE,'UniformOutput',false)) ;
            case "UniqueModelID"
              slice_ele = findcells(BEAMLINE,'Slices') ;
              noslice_ele = 1:length(BEAMLINE) ; noslice_ele(slice_ele) = [] ;
              obj.ModelDat.UniqueModelID = sort([noslice_ele arrayfun(@(x) BEAMLINE{x}.Slices(1),slice_ele)]) ;
            case "ModelBDES_i"
              obj.ModelDat.ModelBDES_i = findcells(BEAMLINE,'B') ;
            case "ModelBDES_Z"
              GetModelDat(obj,"ModelBDES_i");
              obj.ModelDat.ModelBDES_Z = arrayfun(@(x) BEAMLINE{x}.Coordf(3),obj.ModelDat.ModelBDES_i) ;
            otherwise
              error('Invalid model data parameter: %s',dname);
          end
        end
      end
    end
    function SetKlystronData(obj,Klys,ffact)
      global KLYSTRON
      if ~exist('Klys','var') || ~isa(Klys,'F2_klys')
        error('Must pass a F2_klys object');
      end
      % Set Klystron values from control system readings
      for isec=1:10
        for ikly=1:8
          if isec==1
            fudge = ffact(1) ;
          elseif isec==2 && ikly<3
            fudge = ffact(2) ;
          elseif isec<6
            fudge = ffact(3) ;
          else
            fudge = ffact(4) ;
          end
          if obj.ModelKlysID(ikly,isec)>0
            if Klys.KlysInUse(ikly,isec) && Klys.KlysStat(ikly,isec)==0
              KLYSTRON(obj.ModelKlysID(ikly,isec)).Ampl = double( Klys.KlysAmpl(ikly,isec)*fudge ) ;
              KLYSTRON(obj.ModelKlysID(ikly,isec)).AmplSetPt = double( Klys.KlysAmpl(ikly,isec)*fudge ) ;
            else
              KLYSTRON(obj.ModelKlysID(ikly,isec)).Ampl = 0 ;
              KLYSTRON(obj.ModelKlysID(ikly,isec)).AmplSetPt = 0 ;
            end
            if Klys.KlysInUse(ikly,isec)
              KLYSTRON(obj.ModelKlysID(ikly,isec)).Phase = double( Klys.KlysPhase(ikly,isec) ) ;
              KLYSTRON(obj.ModelKlysID(ikly,isec)).PhaseSetPt = double( Klys.KlysPhase(ikly,isec) ) ;
            end
          end
        end
      end
    end
    function hasset=SetExtantModel(obj)
      global BEAMLINE PS KLYSTRON
      hasset=false;
      if isempty(obj.ModelTempStore)
        return % haven't updated model since loading design or extant model already loaded
      end
      BEAMLINE = obj.ModelTempStore.BEAMLINE ;
      PS = obj.ModelTempStore.PS ;
      KLYSTRON = obj.ModelTempStore.KLYSTRON ;
      hasset=true;
    end
    function SetDesignModel(obj,db)
      %SETDESIGNMODEL Restore design model database
      % SetDesignModel([db])
      %  db (optional): string array containing 1 or more of: "PS" "KLYSTRON" "BEAMLINE"
      global BEAMLINE PS KLYSTRON
      obj.ModelTempStore.BEAMLINE = BEAMLINE; obj.ModelTempStore.PS=PS; obj.ModelTempStore.KLYSTRON=KLYSTRON;
      if exist('db','var')
        db=string(db);
      else
        db=["BEAMLINE" "PS" "KLYSTRON"];
      end
      if ismember("BEAMLINE",db)
        BEAMLINE = obj.ModelDesign.BEAMLINE ;
      end
      if ismember("PS",db)
        PS = obj.ModelDesign.PS ;
      end
      if ismember("KLYSTRON",db)
        KLYSTRON = obj.ModelDesign.KLYSTRON ;
      end
    end
  end
  methods(Static,Hidden)
    function [B,Bpsi]=bmag(b0,a0,b,a)
      %
      % [B,Bpsi]=bmag(b0,a0,b,a);
      %
      % Compute BMAG and its phase from Twiss parameters
      %
      % INPUTs:
      %
      %   b0 = matched beta
      %   a0 = matched alpha
      %   b  = mismatched beta
      %   a  = mismatched alpha
      %
      % OUTPUTs:
      %
      %   B    = mismatch amplitude
      %   Bpsi = mismatch phase (deg)
      
      g0=(1+a0.^2)./b0;
      g=(1+a.^2)./b;
      B=(b0.*g-2..*a0.*a+g0.*b)/2;
      if nargout>1
        Bcos=((b./b0)-B)./sqrt(B.^2-1);
        Bsin=(a-(b./b0).*a0)./sqrt(B.^2-1);
        Bpsi=atan2d(Bsin,Bcos)./2;
      end
    end
  end
end