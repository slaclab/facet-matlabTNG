function peakIdx = getPeakHDF5(x,sumDir)
% peakIdx = GETPEAK(x,sumDir)
% x is the 2D matrix to get projected peak from, sumDir is the dimension to
% sum over (1 (columns) or 2 (rows))
    
    if nargin == 1
        sumDir = 1;
    end
    
    for i = 1:size(x,3)
        
        vec = sum(x(:,:,i),sumDir);
        
        %find last peak
        peakIdx(i) = find(max(vec)==vec,1,'last');
    end
end