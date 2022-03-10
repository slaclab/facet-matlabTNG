camerapvs = {'CAMR:LT10:500','CAMR:LT10:600','CAMR:LT10:700','CAMR:LT10:200','CAMR:LT10:380'};
for n=2%1:length(camerapvs)
   dataim = profmon_grab(camerapvs{n})
    figure(n)
   imagesc(dataim.img)
   colormap jetvar
   
end