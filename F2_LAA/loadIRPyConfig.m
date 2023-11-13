function config = loadIRPyConfig()
%LOADIRPYCONFIG Summary of this function goes here
%   Detailed explanation goes here
loadConfigForMatlab = py.importlib.import_module('loadConfigForMatlab');
config = py2mat(loadConfigForMatlab.loadIRConfig());
end

