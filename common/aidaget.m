function value = aidaget(aidaname, aidaType, aidaParams)
aidapva
%   aidaget gets control system data, such as EPICS PV values, model, SLC db, etc.
%
%   AIDAGET(aidaname, aidaType, aidaParams) gets scalar or array (1-dimensional)
%   data from the control system through the AIDA [1] system,
%   subject to the specified list of AIDA parameters AIDAPARAMS. The AIDA
%   type (default: double) and the list of AIDA parameters (default: [])
%   are optional.
%
%   AIDA (Accelerator Independent Data Access) [1] is a software
%   system that can get (or put) the values of control system
%   quantities from a number of sources, such as EPICS PVs, XAL
%   model, Archiver and SLC History, and various specialist SLC
%   control system items such as Klystron phase/amp, Magnets,
%   triggers etc.
%
%   INPUTS:
%     AIDANAME is a char string that contains the name of a control system
%     quanitity, whose value you want; such as an EPICS PV record name. It
%     follows the pattern '<instance>:<attribute>'. See examples of such
%     names below. NB: the pattern '<instance>//<attribute>' is allowed for
%     reasons of backward compatibility with previous AIDA versions.
%
%     AIDATYPE is a string that contains the name of an AIDA type.
%     Allowed AIDA types for scalar values are:
%     boolean, byte, char, double (default), float, long, longdouble,
%     longlong, short, string, ulong, ulonglong, ushort,  wchar, wstring.
%     Allowed AIDA types for arrays are:
%     booleana, bytea, chara, doublea, floata, longa, longdoublea, longlonga,
%     shorta, stringa, ulonga, ulonglonga, ushorta,  wchara, wstringa.
%     The default is double, which is to say, if you don't specify it,
%     AIDA will attempt to get the data as a double; so be careful, not all data
%     can be acquired as a single double value. Check the individual data
%     provider help page for the dataum you're trying to get, to see what
%     data types are supported for that datum.
%     NB: these data types are maintained for backwards-compatibility but
%     locally map onto AIDA-PVA data types:
%     AIDA_BOOLEAN,AIDA_BYTE,AIDA_CHAR,AIDA_SHORT,AIDA_INTEGER,AIDA_LONG
%     AIDA_FLOAT,AIDA_DOUBLE,AIDA_STRING,AIDA_BOOLEAN_ARRAY,AIDA_BYTE_ARRAY
%     AIDA_CHAR_ARRAY,AIDA_SHORT_ARRAY,AIDA_INTEGER_ARRAY,AIDA_LONG_ARRAY
%     AIDA_FLOAT_ARRAY,AIDA_DOUBLE_ARRAY,AIDA_STRING_ARRAY,AIDA_TABLE
%
%     AIDAPARAMS is a (row or column) cell array of char strings, each element
%     of which contains an
%     AIDA parameter assignment. Each follows the pattern 'name=value'. The
%     valid parameters vary depending on the kind of data being acquired.
%     See the individual data provider help pages of the data providers
%     themselves, off the AIDA home page [1]
%
%   OUTPUTS:
%     VALUE will be the data returned by AIDA for the AIDANAME subject to
%     the AIDAPARAMS given. VALUE will be either a scalar value, or, 1D
%     array, as specified by the AIDATYPE. The default is to attempt to
%
%   Example names:  instance            attribute
%                   ------------------  ----------------
%   EPICS CA:       BPMS:IN20:425:X1    VAL
%   Archiver        QUAD:LI21:271:TEMP  HIST.lcls (*)
%   Model           XCOR:IN20:425       twiss
%   Oracle data     LCLS                BSA.elements.byZ (*)
%
%   Limitations of aidaget:
%     aidaget can't presently handle structured return types like those
%     provided by the AIDA archiver, history or Oracle data providers. So
%     the examples marked (*) above can't be acquired by aidaget. To get
%     those in matlab, you must use aida matlab code directly, see
%     examples linked to from the individual data provider help pages
%     of the data providers themselves, off the AIDA home page [1]
%
%   Examples of Usage:
%
%     1) Get an EPICS PV:
%     >> aidaget('BPMS:IN20:221:ATTC:VAL')
%
%     ans =
%
%          0
%
%     2) Get an SLC value, known to return a (2 value) vector:
%
%     >> aidaget('LGPS:LI23:1:IMMO','doublea')
%
%     ans =
%
%         [  0]
%         [200]
%
%     3) Get the DESIGN twiss of a QUAD.
%
%     >> aidaget(quad,'doublea',{'TYPE=DESIGN','POS=MID'})
%
%     ans =
%
%         [  0.1352]
%         [ 12.5824]
%         [ 10.1247]
%         [-14.8779]
%         [       0]
%         [       0]
%         [ 10.1643]
%         [  1.2552]
%         [  1.3065]
%         [       0]
%         [       0]
%
%   References:
%   [1] The AIDA web page: https://www.slac.stanford.edu/grp/cd/soft/aida/aida-pva/index.html
%
%   Mod:
%      06-Jan-2022, Glen White. Updated AIDA calls to use AIDA-PVA, made
%      associated changes to handling of data structures and types, updated help
%      06-Jun-2011, Henrik Loos. Changed num params calc from max(size()) to
%      numel() to avoid crash for [0xn] parameter arrays.
%      02-Feb-2009, Greg White. Removed latent addition of MODE=5 arg
%      where //twiss or //R is asked for, since now not giving MODE
%      argument is interpretted by DpModel server as a request to find
%      the model data in MODE 5 if it exsits there, and in
%      the latest model run (max RunID) that contains the data otherwise.
%      17-Sep-2008, Greg White. Added help, and actually released it!
%      Modified allowed form of input aidaParams, to permit char arrays.
%      25-Feb-2008, Sergei Chevtsov. Changed help.
%      15-Dec-2007, Greg White, Sergei Chevtsov. Append MODE=5 only if model
%      data is being acquired.
%      19-May-2007. Greg White. Added da.reset() following Mike's
%      (yesterday) making da static.
%
%   Auth: Sergei Chevtsov, 2005?
%   Copyright 2008 SLAC.

if nargin < 1
  disp('You must specify an AIDA target at the very least.');
  return;
end

if nargin < 3
  aidaParams = [];
else
  aidaParams=cellstr(aidaParams);
end

if nargin < 2
  %default type
  aidaType = 'AIDA_DOUBLE';
else % convert to AIDA-PVA data type
  aidaType=char(aidaType);
  if aidaType(end)=='a'
    aidaType=aidaType(1:end-1);
    isarray=true;
  else
    isarray=false;
  end
  switch aidaType
    case 'boolean'
      aidaType = 'AIDA_BOOLEAN' ;
    case 'byte'
      aidaType = 'AIDA_BYTE' ;
    case 'char'
      aidaType = 'AIDA_CHAR' ;
    case 'double'
      aidaType = 'AIDA_DOUBLE';
    case 'float'
      aidaType = 'AIDA_FLOAT';
    case 'long'
      aidaType = 'AIDA_LONG';
    case 'short'
      aidaType = 'AIDA_SHORT';
    case 'string'
      aidaType = 'AIDA_STRING';
    otherwise % double
      fprintf('Type ''%s'' not known, using ''double''.', aidaType);
      aidaType = 'AIDA_DOUBLE' ;
  end
  if isarray
    aidaType = sprintf('%s_ARRAY',aidaType) ;
  end
end
eval(sprintf('aidaType=%s;',aidaType));

%we accept both, column and row cell arrays
nrParams = numel(aidaParams);

% Convert // into : for backwards compatibility
aidaname = regexprep(aidaname,'//',':');

% Use SLC:: prefix for klystrons
% aidaname = regexprep(aidaname,'^KLYS:(.+)','SLC::KLYS:$1') ;

% Form AIDA-PVA request and get value
builder = pvaRequest(aidaname);
if nrParams>0
  for ipar=1:nrParams
    pname=regexprep(aidaParams{ipar},'=.+','');
    pval=regexprep(aidaParams{ipar},'.+=','');
    builder.with(pname,pval);
  end
end
builder.returning(aidaType);
value = ML(builder.get());

