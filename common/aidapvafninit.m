% There are two types of Globals in matlab.  Global-globals only work when not inside a function
% so we need to do the same thing inside a function to create function-globals.
% These globals are for use in any function.  After this you simply need to use `global <symbolName>` to
% import the symbol into your scope
% e.g. `global pvaSet AIDA_STRING AIDA_DOUBLE` to allow use of pvaSet and the two enums.
% Note that here we need to define ALL API artifacts because functions won't benefit from the imports at the
% global-global level, for example, we define `AidaPvaStruct` in this function so it can be accessed from within
% functions, whereas it can otherwise be accessed directly in the global-global context.
function aidapvafninit()
    aidapva;

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
    AidaPvaStruct = @() edu.stanford.slac.aida.client.AidaPvaClientUtils.AidaPvaStruct();
end

