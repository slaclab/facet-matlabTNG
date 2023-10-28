function peakIdx = getGaussStd(x,sumDir)
% peakIdx = GETPEAK(x,sumDir)
% x is the 2D matrix to get projected peak from, sumDir is the dimension to
% sum over (1 (columns) or 2 (rows))
    
    if nargin == 1
        sumDir = 1
    end
    
    vec = sum(x,sumDir);

    %find last peak
    [yfit,q,dq,chisq_ndf] = gauss_fit(1:length(vec),vec);
    peakIdx = q(4);
%     peakIdx = find(max(vec)==vec,1,'last');
end