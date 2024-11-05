function cent = getGaussStdHDF5(x,sumDir)
% gets the centroid position
    
    if nargin == 1
        sumDir = 1;
    end
    
    cent = zeros(1,size(x,3));
    for i = 1:size(x,3)
        vec = sum(x(:,:,i),sumDir);

        %find last peak

        [yfit,q,dq,chisq_ndf] = gauss_fit(1:length(vec),vec);
        cent(i) = q(4);
    end
end