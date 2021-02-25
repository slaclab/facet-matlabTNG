function CS=F2sim()
%Run FACET-II controls system simulation tools
CS = F2_CathodeServicesSim() ;
fprintf('Running F2_CathodeServicesSim, version %s\n',CS.version);
end

