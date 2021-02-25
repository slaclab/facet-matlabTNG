
solcur=linspace(140,160,50);
SE=SolenoidEnergyCalibration; SE.tracker='GPT';  SE.verbose=0;
FD=F2GunDiagnostics('apps/solcaldata'); FD.verbose=0;
table_solI = FD.GunEnergyLookupData.SolI;
de1=zeros(1,length(solcur)); de2=de1; de3=de1;
for isol=1:length(solcur)
  isol_lookup=table_solI(interp1(table_solI,1:length(table_solI),solcur(isol),'nearest'));
  cd GPT;
  SE.SolCur=solcur(isol);
  [dx,dy,E]=SE.test(120,[0 3]);
  [E1,E2,E3]=FD.Ecalc(dx*1e3,dy*1e3,3,solcur(isol),'y',E-2,E+2);
  de1(isol)=abs(E-E1)/E; de2(isol)=abs(E-E2)/E; de3(isol)=abs(E-E3);
  fprintf('isol %d/%d SOLI= %g de1= %g de2= %g de3= %g dsolI= %g (%%)\n',...
    isol,length(solcur),solcur(isol),100*de1(isol),100*de2(isol),100*de3(isol),...
    abs(100*(solcur(isol)-isol_lookup)/solcur(isol)))
  cd ..
end