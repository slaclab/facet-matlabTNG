function config = loadPyConfig()
%LOADCONFIG Summary of this function goes here
%   Detailed explanation goes here
%loadConfigForMatlab = py.importlib.import_module('loadConfigForMatlab');
config = py.loadConfigForMatlab.loadConfig();
data = py.json.dumps(config);
data = char(data);
config = jsondecode(data);
%config = py2mat(py.loadConfigForMatlab.loadConfig());
end

