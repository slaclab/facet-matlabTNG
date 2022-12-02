function util_closeFigs()
% find all figures in this session and close those that are not running
% apps
openfigs = findall(groot, 'Type', 'figure');
isApp = isprop(openfigs, 'RunningAppInstance');
delete(openfigs(~isApp));
end

