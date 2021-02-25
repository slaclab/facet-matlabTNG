function [tt,K,N,L,P,A,T,E,FDN,twss,orbt,S]=xtfft2mat(fname)
%
% [tt,K,N,L,P,A,T,E,FDN,twss,orbt,S]=xtfft2mat(fname);
%
% Outputs:
%
%   tt   = run title
%   K    = element keyword
%   N    = element name
%   L    = element length
%   P    = element parameter
%   A    = aperture
%   T    = engineering type
%   E    = energy
%   FDN  = NLC Formal Device Name
%   twss = twiss (mux,betx,alfx,dx,dpx,muy,bety,alfy,dy,dpy)
%   orbt = orbit (x,px,y,py,t,pt)
%   S    = suml

% check the input/output arguments
if (nargin~=1)
  error('File name input argument required')
end
if (nargout~=12)
  error('12 output arguments required')
end
if (~ischar(fname))
  error('File name must be a string')
end
[nrow,ncol]=size(fname);
if (nrow~=1)
  error('File name must be a single row')
end

if (exist('xtfft2mat_mex')==3)
  try
    % use the mex-file to download the data
    [tt,K,N,L,P,A,T,E,FDN,twss,orbt,S]=xtfft2mat_mex(fname);
  catch
    % use the (much slower) script to download the data
    [tt,K,N,L,P,A,T,E,FDN,twss,orbt,S]=xtfft2mat_nomex(fname);
  end
else
  % use the (much slower) script to download the data
  [tt,K,N,L,P,A,T,E,FDN,twss,orbt,S]=xtfft2mat_nomex(fname);
end

end