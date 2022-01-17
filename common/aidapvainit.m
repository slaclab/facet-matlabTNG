
% aidapvainit prepares a local session for accessing aida channels
if isempty(cell2mat(regexp(javaclasspath,'aida-pva-client.jar$','once')))
  
  % Dynamically add AIDA releated classes
  javaaddpath('/usr/local/facet/tools/matlabTNG/common/aida-pva-client.jar')
  disp 'Aida PVA client initialization completed';
end

% aida-pva-client imports
import('edu.stanford.slac.aida.client.AidaPvaClientUtils.*');
import('edu.stanford.slac.aida.client.AidaType.*');

% Epics request exceptions
import('org.epics.pvaccess.server.rpc.RPCRequestException');

% PVAClient imports
import('org.epics.pvaccess.*')
import('org.epics.pvaClient.*')
import('org.epics.pvdata.*')

AIDA_BOOLEAN = [edu.stanford.slac.aida.client.AidaType.AIDA_BOOLEAN];
AIDA_BYTE = [edu.stanford.slac.aida.client.AidaType.AIDA_BYTE];
AIDA_CHAR = [edu.stanford.slac.aida.client.AidaType.AIDA_CHAR];
AIDA_SHORT = [edu.stanford.slac.aida.client.AidaType.AIDA_SHORT];
AIDA_INTEGER = [edu.stanford.slac.aida.client.AidaType.AIDA_INTEGER];
AIDA_LONG = [edu.stanford.slac.aida.client.AidaType.AIDA_LONG];
AIDA_FLOAT = [edu.stanford.slac.aida.client.AidaType.AIDA_FLOAT];
AIDA_DOUBLE = [edu.stanford.slac.aida.client.AidaType.AIDA_DOUBLE];
AIDA_STRING = [edu.stanford.slac.aida.client.AidaType.AIDA_STRING];
AIDA_BOOLEAN_ARRAY = [edu.stanford.slac.aida.client.AidaType.AIDA_BOOLEAN_ARRAY];
AIDA_BYTE_ARRAY = [edu.stanford.slac.aida.client.AidaType.AIDA_BYTE_ARRAY];
AIDA_CHAR_ARRAY = [edu.stanford.slac.aida.client.AidaType.AIDA_CHAR_ARRAY];
AIDA_SHORT_ARRAY = [edu.stanford.slac.aida.client.AidaType.AIDA_SHORT_ARRAY];
AIDA_INTEGER_ARRAY = [edu.stanford.slac.aida.client.AidaType.AIDA_INTEGER_ARRAY];
AIDA_LONG_ARRAY = [edu.stanford.slac.aida.client.AidaType.AIDA_LONG_ARRAY];
AIDA_FLOAT_ARRAY = [edu.stanford.slac.aida.client.AidaType.AIDA_FLOAT_ARRAY];
AIDA_DOUBLE_ARRAY = [edu.stanford.slac.aida.client.AidaType.AIDA_DOUBLE_ARRAY];
AIDA_STRING_ARRAY = [edu.stanford.slac.aida.client.AidaType.AIDA_STRING_ARRAY];
AIDA_TABLE = [edu.stanford.slac.aida.client.AidaType.AIDA_TABLE];

pvaRequest = @(channel) edu.stanford.slac.aida.client.AidaPvaClientUtils.pvaRequest(channel);
pvaSet = @(channel, value) edu.stanford.slac.aida.client.AidaPvaClientUtils.pvaSet(channel, value);
pvaSetM = @(channel, value) ML(edu.stanford.slac.aida.client.AidaPvaClientUtils.pvaSet(channel, value));
AidaPvaStruct = @() edu.stanford.slac.aida.client.AidaPvaClientUtils.newStruct();
