Date = ["05/22/24";"05/22/24";"05/22/24";"05/07/24";"04/24/24";"04/24/24";"04/24/24";"04/24/24";"04/09/24";"03/26/24";"03/26/24";"02/05/24";"11/29/23";"11/15/23";"11/09/23";"11/09/23";"11/09/23";"11/09/23";"11/09/23"];
Name=["LFOV";"GAMMA2";"EDC_SCREEN";"IPOTR1P";"DTOTR2";"LFOV";"GAMMA1";"GAMMA2";"GAMMA2";"GAMMA1";"PRDMP";"GAMMA2";"IPOTR2";"LFOV";"IPOTR1";"IPOTR2";"DSOTR";"EDC_SRAD";"EPIX_TEST/CHER"];
Model = ["C13440-20CU";"Mako G-125B";"Manta G-895B";"Mako G-125B";"Mako G-125B";"C13440-20CU";"Mako G-125B";"Mako G-125B";"Mako G-125B";"Mako G-125B";"Mako G-125B";"Mako G-032B";"Manta_G-125B";"Mako G-125B";"Manta_G-125B";"Manta_G-125B";"Manta_G-125B";"Manta G-895B";"Manta G-895B"];
OldSN=["50-0537053256";"50-0537008522";"50-0503485903";"N/A";"503525583";"537054133";"537039407";"537039412";"537014396";"537008533";"537008522";"50-0536987606";"50-0503525586";"50-0536987942";"50-0503350448";"50-0503343953";"50-0503525598";"50-0503525599";"50-0537008532"];
NewSN=["50-0537039322";"50-0537039405";"50-0503485907";"50-0537054130";"537008384";"537053256";"50-0537039384";"537008522";"537039412";"537039407";"537039416";"50-0537014396";"50-0503525582";"50-0537054133";"50-0503525584";"50-0503525586";"50-0503525588";"50-0503525587";"50-0503485906"];
OldRebootCount=["295";"59";"269";"154";"1363";"694";"205";"106";"382";"640";"679";"280";"15";"328";"17";"14";"12";"76";"151"];
Camera_Swap= table(Date,Name,Model,OldSN,NewSN,OldRebootCount);
disp(Camera_Swap)
[Camera_Names, replacement_counts] = groupcounts(Camera_Swap.Name);
replacement_summary = table(replacement_counts, Camera_Names, 'VariableNames',{'Name','Replacements'});
disp(replacement_summary);
save('Camera_Swap.mat','Camera_Swap');
save('replacement_summary.mat','replacement_summary');
[model_names, model_counts] = groupcounts(Camera_Swap.Model);
model_summary = table(model_counts, model_names,'VariableNames',{'Model','Replacements'});
disp(model_summary);
save('model_summary.mat','model_summary');
