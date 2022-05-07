function [isok, BDES0, BDES1, BDES2] = calc_Spec_Quad_M12(M12_req)


% Just use a look up table of values for now. Will modify to calculating
% function later

    maxPS0 = 239;
    maxPS1 = 386;
    maxPS2 = 240;

    M12 = [   -1.5000   -1.1250   -0.7500   -0.3750    0.0000    0.3750    0.7500    1.1250    1.5000];
    PS0 = [  121.1340  120.8290  120.5224  120.2141  119.9042  119.5926  119.2793  118.9643  118.6474];
    PS1 = [  184.4664  183.6576  182.8467  182.0337  181.2185  180.4012  179.5818  178.7601  177.9361];
    PS2 = [  121.1340  120.8290  120.5224  120.2141  119.9042  119.5926  119.2793  118.9643  118.6474];
    
    BDES0 = interp1(M12,PS0,M12_req,'pchip');
    BDES1 = interp1(M12,PS1,M12_req,'pchip');
    BDES2 = interp1(M12,PS2,M12_req,'pchip');
   
    if (BDES0<=maxPS0) && (BDES1<=maxPS1) && (BDES2<=maxPS2)
        isok = 1;
    else
        isok = 0;
    end
    
end