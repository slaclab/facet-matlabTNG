classdef BufferData < handle
  %BUFFERDATA Generic class for aquiring buffered data with optional EPICS/AIDA aquisition
  
  events
    PVUpdated
  end
  properties
    Name string = "BufferedData"
    StripPlot logical = false % set true to continuously update plot
    MaxDataRate {mustBeGreaterThan(MaxDataRate,0.001)} = 100 % Max expected data rate [Hz]
    DoFilter logical = false
    FilterType string {mustBeMember(FilterType,["notch" "pass"])} = "pass" % filter can be pass or notch type
  end
  properties(SetObservable)
    DataPV PV % Connect to data PV ti acquire data
    Qual
    FilterInterval(1,2) = [0.001 0.1] % [LOW,HIGH] frequency filter settings [Hz]
    BufferTime uint16 {mustBePositive} = 2 % Storage length for feedback variables [minutes]
    Enable logical = false
  end
  properties(SetAccess=private)
    DataRaw timeseries
  end
  properties(Access=private)
    listener
  end
  properties(Dependent)
    DataFiltered timeseries
    Value % current data value (filtered if DoFilter=true)
  end
  
  methods
    function obj = BufferData(varargin)
      if nargin>0
        for iarg=1:2:nargin
          try
            obj.(varargin{iarg}) = varargin{iarg+1} ;
          catch
            error('Error passing parameter %s',varargin{iarg})
          end
        end
      end
      obj.DataRaw=timeseries;
      obj.listener = addlistener(obj,'PVUpdated',@(~,~) obj.DataUpdate) ;
    end
    function DataUpdate(obj)
      if ~isempty(obj.DataPV.val{1}) && ~obj.DataPV.isalarm
        obj.AddData(obj.DataPV.val{1},obj.DataPV.time{1});
      end
      if obj.StripPlot
        obj.plot;
      end
    end
    function AddData(obj,data,time)
      obj.DataRaw = addsample(obj.DataRaw,'Data',data,'Time',time) ;
      obj.TrimData();
    end
    function delete(obj)
      stop(obj.DataPV);
    end
    function plot(obj)
      persistent fh ah
      ts=obj.DataRaw;
      ts.Name=obj.Name;
      ts.Time=ts.Time-ts.Time(1);
      if isempty(fh)
        fh=figure;
        ah=axes;
      end
      if ~ishandle(fh) && obj.StripPlot % disable strip chart plotting if window deleted
        fh=[]; ah=[];
        obj.StripPlot=false;
        return;
      end
      plot(ts,'Parent',ah);
      if obj.DoFilter
        tsf=obj.DataFiltered;
        tsf.Time=tsf.Time-tsf.Time(1);
        hold(ah,'on');
        plot(tsf,'Parent',ah);
        hold(ah,'off');
        grid(ah,'on');
      end
      drawnow
    end
  end
  % Get/Set & private methods
  methods
    function set.Enable(obj,val)
      if logical(val) == obj.Enable
        return
      end
      obj.Enable = logical(val) ;
      if obj.Enable
        run(obj.DataPV,false,1/obj.MaxDataRate,obj,'PVUpdated');
      else
        stop(obj.DataPV);
      end
    end
    function val = get.Value(obj)
      if isempty(obj.DataRaw) || isempty(obj.DataRaw.Data)
        val = [] ;
        return
      end
      % Current value must be valid, else provide nan as output
      if isnan(obj.DataPV.val{1}) || isinf(obj.DataPV.val{1})
        val = nan;
        return
      end
      if obj.DoFilter
        val = obj.DataFiltered.Data(end) ;
      else
        val = obj.DataRaw.Data(end) ;
      end
    end
    function set.DataPV(obj,pv)
      pv.gettime=true;
      obj.DataPV = pv ;
      obj.Enable = true ;
    end
    function tf = get.DataFiltered(obj)
      %FILTER Apply filter to timeseries data (write to filtered field)
      if obj.DataRaw.Length<2 % if no data, just return empty timeseries object
        tf=timeseries;
        return
      end
      tf = idealfilter(obj.DataRaw,obj.FilterInterval,char(obj.FilterType)) + mean(obj.DataRaw) ;
    end
    function set.BufferTime(obj,val)
      %BUFFERTIME Set buffer length in minutes (if lower than Filter frequency requires, automatically sets longer)
      obj.BufferTime = val ;
      obj.TrimData;
    end
    function set.FilterInterval(obj,val)
      %FILTERINTERVAL Set low/high frequency interval for filter
      if val(1) >= val(2)
        error('Incorrect filter interval setting');
      end
      % Check filter settings
      if obj.BufferTime*60 < ceil(1/val(2))*2
        error('Buffer length insufficient for filter rate, set to %d mins',ceil(1/obj.FilterInterval(2)/30)) ;
      end
      obj.FilterInterval = val ;
    end
  end
  methods(Access=private)
    function TrimData(obj)
      %TRIMDATA Trims timeseries data lengths according to BufferTime property
      if obj.DataRaw.Length > 1
        dt = range(obj.DataRaw.Time) ;
        if dt/60 > obj.BufferTime
          t = abs(obj.DataRaw.Time - obj.DataRaw.Time(end)) ;
          obj.DataRaw = getsamples(obj.DataRaw,find(t<obj.BufferTime*60)) ;
        end
      end
    end
  end
end

