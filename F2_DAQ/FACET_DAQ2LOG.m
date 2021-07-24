function FACET_DAQ2LOG(Comment,obj)

figure(99);
ax = axes();
set(ax, 'Visible', 'off');
set(gcf,'Position',[10 10 10 10]);


util_printLog2020(99,'title',[obj.params.experiment '_' num2str(obj.Instance,'%05d') ' DAQ'],...
   'author',obj.params.experiment,'text',Comment);
clf(99), close(99);