function [x,y] = noplot_ellipse(X,p,q)

%  function plot_ellipse(X,p,q,style)
%
%    x/y data points for ellipse described by the 2X2 symmetric matrix "X", centered
%    at the point (p,q), using the specified line (or point) style
%
%  INPUTS:
%
%    X:     a 2x2 symmetric matrix which describes the ellipse as follows:
%
%            [x y]*X*[x y]' = 1,
%
%           or, with X = [a b 
%                         b c],
%
%	           ax^2 + 2bxy + cy^2  = 1;
%
%           for a beam ellipse, X=inv(sigma)=(1/emit)*[gamma alpha
%                                                      alpha  beta]
%
%    p:     ordinate of ellipse center
%    q:     abscissa of ellipse center

%===============================================================================

[r,c]=size(X);
if ((r~=2)||(c~=2))
  error('X must be a 2x2 matrix')
end
if (abs(X(1,2)-X(2,1))>(abs(0.001*X(1,2))+eps))
  error('X must be a symmetric matrix')
end

a=X(1,1);
b=X(1,2);
c=X(2,2);

delta=0.001;
theta=[0:delta:pi]';
C=cos(theta);
S=sin(theta);

r=sqrt((a*(C.^2)+2*b*(C.*S)+c*(S.^2)).^(-1));
r=[r,r];
C=[C,-C];
S=[S,-S];

x=r.*C;         
y=r.*S;         

x=x+p;
y=y+q;