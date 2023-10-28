function cent = getGaussCtr(x,sumDir)
% gets the centroid position
    
    if nargin == 1
        sumDir = 1
    end
    
    vec = sum(x,sumDir);

    %find last peak
    [yfit,q,dq,chisq_ndf] = gauss_fit(1:length(vec),vec);
    cent = q(3);

end