classdef PVtype
  %PVTYPE List of supported PV access protocols
  
  enumeration
    EPICS % java CA epics client
    EPICS_labca % labCA epics client
    AIDA % EPICS7 RPC calls to AIDA server using pvAccess and RPC
  end
  
end

