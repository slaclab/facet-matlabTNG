function varargout = TuneBC20_OptimFun(varargin)
%TUNEBC20OPTIMFUN Optimization function for tuning BC20 Sextoples for use with F2_TuneBC20App
%
%Format for use with Xopt:
%[sigx,bkg] = TuneBC20_OptimFun(S1,S2,S3)
%
%Format for use with Matlab based optimizer:
%y = TuneBC20_OptimFun(x)

% If using Matlab optimizer, variables passed as an array in first argument, Xopt passes separate arguments
optimtype = evalin('base','optimtype') ;
if ismember(optimtype,["fminsearch" "fmincon" "lsqnonlin"])
  S1=varargin{1}(1);
  S2=varargin{1}(2);
  S3=varargin{1}(3);
end

% Get Profile and background devices and app handle and stop request status
PDevice = evalin('base','ProfileDeviceName') ;
BkgPV = evalin('base','BkgDevice') ;
app = evalin('base','guihan') ;
stop = evalin('base','dostop') ;

% Set sextupoles unless stop requested
spv = ["LGPS:LI20:2145" "LGPS:LI20:2165" "LGPS:LI20:2195" ...
       "LGPS:LI20:2365" "LGPS:LI20:2335" "LGPS:LI20:2275" ] ;
if stop
  puterr=false;
else
  puterr = aidaset(cellstr(spv(:)),[S1,S2,S3,S1,S2,S3]) ;
end
% fprintf('lcaPut({%s;%s;%s;%s;%s;%s},[%g;%g;%g;%g;%g;%g])\n',spv(:),S1,S2,S3,S1,S2,S3);

% Grab profile image, generate stats and get rms x size
nbkg=evalin('base','nbkg');
PM = F2_ProfMeas(PDevice);
PM.MeasMethod="RMS";
if nbkg>0
  PM.AcquireBkg(nbkg);
end
img = PM.Acquire;
sigx = PM.Stats.rms_x.*1e6;
if nbkg>0
  val=zeros(1,nbkg);
  for ibkg=1:nbkg
    val(ibkg) = lcaGet(char(BkgPV)) ;
    pause(0.1);
  end
  bkg = mean(val) ;
else
  bkg = lcaGet(char(BkgPV)) ;
end

% Update GUI fields and plots
if ~isempty(app)
  app.SpotSizeEditField.Value = sigx ;
  app.BkgEditField.Value = bkg ;
  if ~isnan(sigx) || isempty(sigx)
    app.sxdata(end+1) = sigx ;
  end
  if ~isnan(bkg) || isempty(bkg)
    app.bkgdata(end+1) = bkg ;
  end
  if ~isempty(img)
    imagesc(app.UIAxes_3,img); app.UIAxes_3.YDir='normal'; axis(app.UIAxes_3,'tight'); % colormap(app.UIAxes_3,'turbo');
  end
  if length(app.bkgdata)>1
    plot(app.UIAxes,app.bkgdata); axis(app.UIAxes,'tight');
  end
  if length(app.sxdata)>1
    plot(app.UIAxes_2,app.sxdata); axis(app.UIAxes_2,'tight');
  end
  if puterr
    app.StatusText.Value = "AIDA Error putting new Sextupole values!" ; drawnow; pause(2);
  else
    app.StatusText.Value = sprintf("Optimizer running: x= [%g %g %g] y= [%g %g]",S1,S2,S3,sigx,bkg);
  end
  drawnow;
end

% if using Matlab optimizer, format output accordingly
if puterr; sigx=nan; bkg=nan; end
switch string(optimtype)
  case "lsqnonlin"
    varargout{1} = [sigx bkg]  ;
  case ["fminsearch" "fmincon"]
    varargout{1} = sigx + bkg ;
  otherwise % force stop for Xopt algorithm by constantly outputting invalid responses
    varargout{1} = sigx ; varargout{2} = bkg ;
    if stop
      varargout{1}=nan; varargout{2}=nan;
    end
end
drawnow % Update any GUI processing steps

function err = aidaset(name,val)
aidainit;
import edu.stanford.slac.aida.lib.da.DaObject;
import edu.stanford.slac.err.*;
import edu.stanford.slac.aida.lib.da.*;
import edu.stanford.slac.aida.lib.util.common.*;
da=DaObject;
in=DaValue;

in.type=0;
in.addElement(DaValue(name));
%in.addElement(DaValue(java.lang.Float(val))); % Kludge to make Aida format conversion work.
in.addElement(DaValue(single(val(:)))); % Kludge to make Aida format conversion work.
da.reset;
da.setParam('MAGFUNC','TRIM');
da.setParam('LIMITCHECK','SOME');
err=false;
try
  da.setDaValue('MAGNETSET//BDES',in);
catch
  err=true;
end