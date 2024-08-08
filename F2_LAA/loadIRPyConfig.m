function config = loadIRPyConfig()
%LOADIRPYCONFIG Summary of this function goes here
%   Detailed explanation goes here
%loadConfigForMatlab = py.importlib.import_module('loadConfigForMatlab');
config = py.loadConfigForMatlab.loadIRConfig();
data = py.json.dumps(config);
data = char(data);
config = jsondecode(data);
%config = py2mat(loadConfigForMatlab.loadIRConfig());
end

