function stop = TuneBC20_OutputFun(varargin)

stop = evalin('base','dostop') ; % Process stop request

if stop
  disp('Optimizer Stop Command Sent...');
end


