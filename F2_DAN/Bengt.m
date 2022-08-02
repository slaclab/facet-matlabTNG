function [ cmap] = Bengt( k )
    if (nargin < 1)
        k = linspace(0,3,256)';
    else
        k = linspace(0,3,k)';
    end
    l = linspace(1,3,256);
    
    cmap = interp1([0 l], [1 1 1; parula(256)], k);
end