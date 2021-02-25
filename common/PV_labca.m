classdef PV < handle
  % PV Control system process variable info, access methods and GUI links
 
  events
    PVStateChange % notifies upon successfull fetching of new PV value
  end
  properties
    name string = "none" % user supplied name for PV
    pvname string = "none" % Control system PV string (can be a vector associating this PV to multiple control PVs)
    monitor=false; % Flag this PV to be monitored
    type PVtype = PVtype.EPICS % Control system type (choose from listed Constant types)
    debug uint8 {mustBeMember(debug,[0,1,2])} = 2 % 0=live, 1=read only, 2=no connection
    units string = "none" % User specified units
    conv double % Scalar Conversion factor PV -> reported value or vector of polynomial coefficients (for use with polyval)
    guihan = 0 % gui handle to assoicate with this PV (e.g. to write out a variable or control a switch etc) (can be vector of handles)
    val cell % Last read value (can be any type and length depending on number and type of linked pvname PVs)
%     guiprec uint8 = 3 % Precision (significant figures) to use for GUI displays
    limits double {mustBeNumeric, mustBeGoodLimits(limits)} % Numerical upper/lower bounds for PV numeric values
    guiprefs GUI_PREFS % GUI preferences
    pvlogic char = '&' % logic used to combine multiple linked PVs for some GUI events, or negate, set to one of: '&','|','XOR','~','~&','~|','MAX','MIN','SUM'
    STDOUT = 1 % Standard echo output destination
    STDERR = 2 % Standard error output destination
    nmax uint32 % limit number of returned values (per control system PV) empty=default: get everything available
    putwait logical = false % wait for confirmation of pvput command
    timeout double {mustBePositive} = 3 % timout in s for waiting for a new monitor value
  end
  properties(SetAccess=protected)
    mode string = "r" % Access mode: "r", or "rw"
    polltime single = 1 % Rate at which to update monitored PVs
    utimer % Holder for update timer object
  end
  properties(Access=private)
    moniregistered=false; % have already registered monitor for this PV?
    cafirstcall=false; % has caget been called once?
    lastlims % last limits value
    lastnm % last nmax value
    lastconv % last conversion values
  end
  properties(Constant)
    errcol=[0.7 0 0];
  end
  methods
    function obj=PV(varargin)
      obj.guiprefs = GUI_PREFS ; % Use default preferences unless overriden by user
      for iarg=1:2:nargin
        obj.(lower(varargin{iarg}))=varargin{iarg+1};
      end
      % Loop through provided args again and take any action that requires
      % full set of parameters set first
      for iarg=1:2:nargin
        if strcmp(varargin{iarg},"mode")
          SetMode(obj,varargin{iarg+1});
        end
      end
    end
    function set(obj,par,val)
      for iobj=1:length(obj)
        obj(iobj).(par)=val;
      end
    end
    function SetMode(obj,mode)
      %MODE Read/write mode for interface with GUIs
      mode=string(mode);
      switch mode
        case "r"
        case "rw"
          % Set GUI callbacks on editable fields or toggle  or state
          % buttons
          for ihan=1:length(obj.guihan) % Loop over all linked handles
            h=obj.guihan(ihan);
            if h==0 || ~ishandle(h); continue; end
            if isprop(h,'ValueChangedFcn')
              set(h,'ValueChangedFcn',@obj.guiCallback);
            end
          end
        otherwise
          error('Unsupported mode: use "r" or "rw"');
      end
    end
    function SetPolltime(obj,polltime)
      %SETPOLLTIME Change update rate of timer polling monitored PVs
      
      % If in list context, then use first PV object to control timer
      if ~isempty(obj(1).utimer)
        obj(1).utimer.Period=double(round(polltime*1000))/1000;
      end
      obj(1).polltime = polltime ;
    end
    function run(obj,polltime,evobj,evname)
      %RUN Start update timer for monitored PVs
      % run(polltime) Starts timer to update monitored PVs at obj.polltime
      %   intervals, poll PVs at given period (polltime) [s]
      % run(polltime,evobj,evname) Notify provided event object (list) and event
      %   name if any of the monitored lists of PVs updates
      
      % If there is already a timer, stop it first
      if ~isempty(obj(1).utimer)
        obj(1).utimer.stop;
      end
      
      % If in list context, then use first PV object to control timer
      if exist('evobj','var') && exist('evname','var')
        obj(1).utimer=timer('Period',double(round(obj(1).polltime*1000))/1000,...
          'ExecutionMode','fixedRate','TimerFcn',{@obj.utimerRun,evobj,evname},'ErrorFcn',@obj.utimerErr);
      else
        obj(1).utimer=timer('Period',double(round(obj(1).polltime*1000))/1000,...
          'ExecutionMode','fixedRate','TimerFcn',@obj.utimerRun,'ErrorFcn',@obj.utimerErr);
      end
      obj(1).SetPolltime(polltime);
      obj(1).utimer.start;
    end
    function stop(obj)
      %STOP stop update timer running
      obj(1).utimer.stop;
    end
    function aveval = cagetave(obj,Ndat)
      %CAGETAVE Return the average of N new values
      % aveval=cagetave(N)
      %  aveval is average of N new values (monitor must be set)
      %  aveval is double array of length pvname
      %  numeric scalar output from PV assumed
      
      % If passing a vector of PV objects, loop through and get each
      if length(obj)>1
        aveval=cell(1,length(obj));
        for iobj=1:length(obj)
          aveval{iobj}=obj(iobj).cagetave(Ndat);
        end
        return
      end
      
      % If not set a monitor already, do that now
      if ~obj.moniregistered
        for ipv=1:length(obj.pvname)
          lcaSetMonitor(cellstr(obj.pvname(ipv)));
        end
        obj.moniregistered=true;
      end
      
      % Gather required data
      aveval=zeros(1,length(obj.pvname));
      for ival=1:Ndat
        for ipv=1:length(obj.pvname)
          newval=lcaGet(cellstr(obj.pvname(ipv)));
          aveval(ipv)=aveval(ipv)+newval(1);
          t0=tic;
          while ~lcaNewMonitorValue(cellstr(obj.pvname(ipv))) && toc(t0)<obj.timeout
            pause(0.01);
          end
        end
      end
      for ipv=1:length(obj.pvname)
        aveval(ipv)=aveval(ipv)/Ndat;
      end
    end
    function [newval,updt]=caget(obj,~,~)
      %CAGET Fetch control system values for this PV
      % [newval,updated] = caget(obj)
      %  new value inserted into val property and returned to newval. If
      %  no new value available (on monitored PVs), then last value is
      %  returned. update variable indicates if value has changed or not.
      
      % If passing a vector of PV objects, loop through and get each
      updt=false(1,length(obj));
      if length(obj)>1
        newval=cell(1,length(obj));
        for iobj=1:length(obj)
          [newval{iobj},updt(iobj)]=obj(iobj).caget;
        end
        return
      else
        newval=obj.val;
        if length(newval)==1
          newval=newval{1};
        end
      end
      
      % force update for the first call and link to previous values
      lastval=obj.val;
      
      % currently only supporting EPICS, also skip if debug flag set >1
      if obj.type~=PVtype.EPICS
        warning('Unsupported controls type, skipping caget %s',obj.name);
        return
      elseif obj.debug>1
        warning('Debug set>1, skipping caget %s',obj.name);
        return
      end
      
      % Register monitor if not already done so
      if obj.monitor && ~obj.moniregistered
        for ipv=1:length(obj.pvname)
          lcaSetMonitor(cellstr(obj.pvname(ipv)));
        end
        obj.moniregistered=true;
      end
      
      % check monitor value (if nmax changed then force update)
      if obj.monitor && ~isempty(obj.val)
        newmoni = lcaNewMonitorValue(cellstr(obj.pvname(:))) ;
      else
        newmoni = true(size(obj.pvname(:))) ;
      end
      if obj.nmax~=obj.lastnm; newmoni=true(size(newmoni)); end
      if ~obj.cafirstcall || ~isequal(obj.conv,obj.lastconv) % get all monitored values first time through, or if conversion factors have been changed
        newmoni=true(size(newmoni));
        obj.cafirstcall=true;
      else
        if ~any(newmoni) && isequal(obj.limits,obj.lastlims); return; end
      end
      
      % Now do the fetching, and perform any value conversions
      iserr=false(1,length(obj.pvname));
      cavals=obj.val;
      for ipv=1:length(obj.pvname)
        if ~newmoni(ipv); continue; end
        try
          if isempty(obj.nmax) % default to getting everything
            cavals=lcaGet(char(obj.pvname(ipv)));
          else
            cavals=lcaGet(char(obj.pvname(ipv)),double(obj.nmax)) ;
          end
        catch ME
          errcodes = lcaLastError();
          fprintf(obj.STDERR,'lcaGet ERROR, errorcodes ');
          fprintf(obj.STDERR,'%i\n',errcodes);
          fprintf(obj.STDERR,'%s\n',ME.message);
          iserr(ipv)=true;
          continue
        end
        if ~isempty(obj.conv) && length(obj.conv)==1 && isnumeric(cavals)
          cavals = cavals .* obj.conv ;
        elseif ~isempty(obj.conv) && length(obj.conv)>1 && isnumeric(cavals)
          cavals = polyval(obj.conv,cavals) ;
        elseif iscell(cavals) && length(cavals)==1
          cavals=cavals{1};
        end
        obj.val{ipv}=cavals;
      end
      if all(iserr); return;  end
      if length(obj.val)==1
        newval = cavals ;
      else
        newval = obj.val ;
      end
      
      % Notify listeners that PV value has changed and update get counter
      notify(obj,'PVStateChange');
      updt=true;
      
      % Update GUI links if live and values have changed
      nvals=length(obj.val);
      lims=obj.limits;
      pvl=obj.pvlogic;
      for ihan=1:length(obj.guihan) % Loop over all linked handles
        h=obj.guihan(ihan);
        if h==0 || ~ishandle(h); continue; end
        if isequal(lastval,obj.val) && isequal(lims,obj.lastlims); continue; end % loop if values haven't changed
        switch class(h)
          case 'matlab.ui.control.Lamp' % set lamp to green if all associated PVs evaluate to true ('ON', 'YES', or >0), else red
            negate=false;
            if pvl(1)=='~'
              negate=true;
              if length(pvl)>1; pvl=pvl(2:end); end
            end
            on=nan(1,nvals);
            for ival=1:nvals
              if strcmpi(obj.val{ival},'ON') || strcmpi(obj.val{ival},'YES') || strcmpi(obj.val{ival},'IN') || (isnumeric(obj.val{ival}) && obj.val{ival}>0)
                on(ival)=1;
              elseif strcmpi(obj.val{ival},'OFF') || strcmpi(obj.val{ival},'NO') || strcmpi(obj.val{ival},'OUT') || ~(isnumeric(obj.val{ival}) && obj.val{ival}>0)
                on(ival)=0;
              end
            end
            if any(isnan(on))
              h.Color=obj.guiprefs.guiLampCol{3};
            else
              if nvals>1
                for ival=2:nvals
                  if strcmp(pvl,'|')
                    on(1) = on(1) | on(ival) ;
                  elseif strcmp(pvl,'XOR')
                    on(1) = xor(on(1),on(ival)) ;
                  else
                    on(1) = on(1) & on(ival) ;
                  end
                end
              end
            end
            if negate; on=~on; end
            if on(1)
              h.Color=obj.guiprefs.guiLampCol{2};
            else
              h.Color=obj.guiprefs.guiLampCol{1};
            end
          case {'matlab.ui.control.ToggleSwitch','matlab.ui.control.Switch','matlab.ui.control.RockerSwitch'} % set lower toggle value if 'OFF' or 0 or 'NO'
            negate=false;
            if pvl(1)=='~'
              negate=true;
              if length(pvl)>1; pvl=pvl(2:end); end
            end
            on=false(1,nvals);
            for ival=1:nvals
              if strcmpi(obj.val{ival},'ON') || strcmpi(obj.val{ival},'YES') || strcmpi(obj.val{ival},'IN') || (isnumeric(obj.val{ival}) && obj.val{ival}>0)
                on(ival)=true;
              end
            end
            if negate; on=~on; end
            if nvals>1
              for ival=2:nvals
                if strcmp(pvl,'|')
                  on(1) = on(1) | on(ival) ;
                elseif strcmp(pvl,'XOR')
                  on(1) = xor(on(1),on(ival)) ;
                else
                  on(1) = on(1) & on(ival) ;
                end
              end
            end
            if isempty(h.ItemsData)
              if on(1)
                h.Value=h.Items{2};
              else
                h.Value=h.Items{1};
              end
            else
              if on(1)
                h.Value=h.ItemsData{2};
              else
                h.Value=h.ItemsData{1};
              end
            end
          case 'matlab.ui.control.NumericEditField' % Write PV value to edit field
            % If limits have been changed, update GUI field limits also
            % only apply limits to editable fields
            if strcmp(h.Editable,'on') && ~isempty(lims) && ~isequal(lims,obj.lastlims)
              h.Limits=double(lims);
            end
            % Deal with multiple PV channels linked to this object
            if length(obj.val)>1
              if strcmpi(obj.pvlogic,'MAX')
                hval=-inf;
              elseif strcmpi(obj.pvlogic,'MIN')
                hval=inf;
              else
                hval=0;
              end
              for ival=1:length(obj.val)
                if strcmpi(obj.pvlogic,'MAX') && obj.val{ival}>hval
                  hval=obj.val{ival};
                elseif strcmpi(obj.pvlogic,'MIN') && obj.val{ival}<hval
                  hval=obj.val{ival};
                elseif strcmpi(obj.pvlogic,'SUM')
                  hval=hval+obj.val{ival};
                else
                  hval=obj.val{1};
                end
              end
            else
              hval=obj.val{1};
            end
            h.Value=hval;
            if ~isempty(lims)
              if hval<lims(1) || hval>lims(2)
                h.BackgroundColor=obj.errcol;
              elseif h.Editable
                h.BackgroundColor=[1 1 1];
              else
                h.BackgroundColor=[0 0 0];
              end
            end
          case {'matlab.ui.control.LinearGauge','matlab.ui.control.Gauge','matlab.ui.control.NinetyDegreeGauge','matlab.ui.control.SemicircularGauge'}
            % If limits have been changed, update GUI field limits and coloring also
            if ~isempty(lims) && ~isequal(lims,obj.lastlims)
              ext=obj.guiprefs.gaugeLimitExtension;
              rng=range(lims);
              scalelims=[lims(1)-rng*ext(1),lims(1);lims(1),lims(2);lims(2),lims(2)+rng*ext(2)];
              h.Limits=double([min(scalelims(:)),max(scalelims(:))]);
              h.ScaleColors=obj.guiprefs.gaugeCol;
              h.ScaleColorLimits=double(scalelims);
            end
            h.Value=obj.val{1};
            if ~isempty(lims)
              if obj.val{1}<lims(1) || obj.val{1}>lims(2)
                h.BackgroundColor=obj.errcol;
              else
                h.BackgroundColor=[1 1 1];
              end
            end
          case 'matlab.ui.control.StateButton'
            on=false(1,nvals);
            negate=false;
            if pvl(1)=='~'
              negate=true;
              if length(pvl)>1; pvl=pvl(2:end); end
            end
            for ival=1:nvals
              if strcmpi(obj.val{ival},'ON') || strcmpi(obj.val{ival},'YES') || strcmpi(obj.val{ival},'IN') || (isnumeric(obj.val{ival}) && obj.val{ival}>0)
                on(ival)=true;
              end
            end
            if negate; on=~on; end
            if nvals>1
              for ival=2:nvals
                if strcmp(pvl,'|')
                  on(1) = on(1) | on(ival) ;
                elseif strcmp(pvl,'XOR')
                  on(1) = xor(on(1),on(ival)) ;
                else
                  on(1) = on(1) & on(ival) ;
                end
              end
            end
            if on(1)
              h.Value=true;
            else
              h.Value=false;
            end
        end
      end
      obj.lastlims=obj.limits;
      obj.lastnm=obj.nmax;
      obj.lastconv=obj.conv;
    end
    function stat=caput(obj,val)
      %CAPUT Set control system values for this PV
      % caput(PV,val)
      % PV is singleton object or vector of objects
      % val can be numeric or char vector or singleton or cell array
      %  if cell array, must match length of pvname vector for singleton PV
      %  or length of PV vector.
      % stat=0 on success
      
      % If passing a vector of PV objects, loop through and put each with
      % same val or pass each val to each PV if a cell array
      if length(obj)>1
        for iobj=1:length(obj)
          if iscell(val)
            obj(iobj).caput(val{iobj});
          else
            obj(iobj).caput(val);
          end
        end
        return
      end
      
      % Perform control system write operation or write operation to
      % command line if debug>0
      stat=0;
      if obj.debug==0
        for ipv=1:length(obj.pvname)
          pvstr=char(obj.pvname(ipv));
          if iscell(val)
            putval=val{ipv};
          else
            putval=val;
          end
          if isnumeric(putval)
            putval=double(putval);
          else
            putval=char(putval);
          end
          try
            if obj.type==PVtype.EPICS
              if obj.putwait
                lcaPut(pvstr,putval(:)');
              else
                lcaPutNoWait(pvstr,putval(:)');
              end
            end
          catch ME
            stat=1;
            errcodes = lcaLastError();
            fprintf(obj.STDERR,'lcaPut ERROR, errorcodes:\n');
            fprintf(obj.STDERR,'%i\n',errcodes);
            fprintf(obj.STDERR,'%s\n',ME.message);
          end
        end
      else
        fprintf(obj.STDOUT,'!DEBUG>0: caput %s %s\n',obj.pvname,num2str(val));
      end
      
    end
    function guiCallback(obj,src,~,~)
      
      switch src.Type
        case {'uitoggleswitch','uiswitch','uirockerswitch'}
          if (~isempty(src.ItemsData) && isequal(src.Value,src.ItemsData{1})) || ...
            isequal(src.Value,src.Items{1}) % OFF state
            caput(obj,0);
          else % ON state
            caput(obj,1);
          end
        case 'uinumericeditfield'
          val=double(src.Value);
          if ~isempty(obj.limits)
            if val<obj.limits(1) || val>obj.limits(2)
              fprintf(obj.STDERR,'Trying to write value outside of set limits, aborting...\n');
              return
            end
          end
          caput(obj,val);
        otherwise
          fprintf(obj.STDERR,'Unsupported PV write operations from this GUI object: %s\n',src.Type);
      end
    end
    function pvstruct = struct(obj)
      %STRUCT Generate a structure array from object list
      pvstruct = builtin('struct',[]);
      names=[obj.name];
      % Names must be unique, if not append incremental number
      uname=unique(names);
      if length(uname)~=length(names)
        for iname=1:length(names)
          nnam=find(ismember(names,names(iname)));
          if length(nnam)>1
            nc=1;
            for iname2=nnam(:)'
              names(iname2)=names(iname2)+"_"+nc;
            end
          end
        end
      end
      for iname=1:length(names)
        pvstruct(1).(names(iname)) = obj(iname) ;
      end
    end
    function disp(obj)
      if length(obj)>1
        pvt=table(obj);
        display(pvt(:,{'ID','VarNames','pvname','monitor','units','limits','val'}));
      else
        builtin('disp',obj);
      end
    end
    function pvtab = table(obj)
      %TABLE Generate a table object from object list
      pvname={obj.pvname}';
      monitor=[obj.monitor]';
      val={obj.val}';
      for ival=1:length(val) % try and convert everything to simple numeric array, the rest stay as cell vectors
        try
          val{ival}=cell2mat(val{ival});
        catch
        end
      end
      type=[obj.type]';
      debug=[obj.debug]';
      units=[obj.units]';
      conv={obj.conv}';
      guihan={obj.guihan}';
      limits=zeros(length(obj),2);
      for ilimit=1:length(obj)
        if isempty(obj(ilimit).limits)
          limits(ilimit,:)=[-inf inf];
        else
          limits(ilimit,:)=obj(ilimit).limits;
        end
      end
      pvlogic={obj.pvlogic}';
      nmax=inf(length(obj),1);
      nmax(cellfun(@(x) ~isempty(x),{obj.nmax}))=[obj.nmax];
      for imax=1:length(obj)
        if isempty(obj(imax).nmax)
          nmax(imax)=inf;
        end
      end
      ID=1:length(pvname); ID=ID(:);
      pvtab = table(pvname,monitor,val,type,debug,units,conv,guihan,limits,pvlogic,nmax,ID) ;
      names=[obj.name];
      % Names must be unique, if not append incremental number
      uname=unique(names);
      if length(uname)~=length(names)
        for iname=1:length(names)
          nnam=find(ismember(names,names(iname)));
          if length(nnam)>1
            nc=1;
            for iname2=nnam(:)'
              names(iname2)=names(iname2)+"_"+nc;
            end
          end
        end
      end
      pvtab.VarNames = cellstr(names)';
    end
    function pset(obj,propname,val)
      % If passing a vector of PV objects, loop through and set each
      if length(val)==1 && length(obj)>1
        for iobj=1:length(obj)
          obj(iobj).(propname)=val ;
        end
      elseif length(val)==length(obj)
        for iobj=1:length(obj)
          obj(iobj).(propname)=val(iobj) ;
        end
      end
    end
  end
  methods(Access=protected)
    function utimerErr(obj,~,~) % Actions to take if timer errors
      fprintf(obj(1).STDERR,'%s: timer service crashed, restarting\n',datetime);
      obj(1).utimer.start;
    end
    function utimerRun(obj,~,~,evobj,evname) % Update timer actions
      monipv=[obj.monitor];
      if ~any(monipv); return; end
      [~,ud]=caget(obj(monipv)); % get all changed values
      % notify event if requested and anything changed
      if any(ud) && exist('evobj','var') && exist('evname','var') && ~isempty(evobj)
        notify(evobj,evname);
      end
    end
  end
end

function mustBeGoodLimits(limits)
  if ~isempty(limits) && ( length(limits)~=2 || limits(1)>=limits(2) )
    error('Value assigned is not a good array for setting limts, must be [a,b], where b>a');
  end
end