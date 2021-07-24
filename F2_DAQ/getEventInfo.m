function event_info = getEventInfo(EC)

event_info = struct();
event_info.EC = EC;

switch EC
    case 223
        event_info.DGRP = 'LASER10HZ';
        [incmSet,incmReset,excmSet,excmReset,beamcode] = getINCMEXCM(event_info.DGRP);
        event_info.incmSet = incmSet;
        event_info.incmReset = incmReset;
        event_info.excmSet = excmSet;
        event_info.excmReset = excmReset;
        event_info.beamcode = beamcode;
        event_info.ratePV = 'EVNT:SYS1:1:TS5_TE_RATE';
        event_info.liveRate = lcaGet(event_info.ratePV);
    case 201
        event_info.DGRP = 'FACET-II';
        [incmSet,incmReset,excmSet,excmReset,beamcode] = getINCMEXCM(event_info.DGRP);
        event_info.incmSet = incmSet;
        event_info.incmReset = incmReset;
        event_info.excmSet = excmSet;
        event_info.excmReset = excmReset;
        event_info.beamcode = beamcode;
        event_info.ratePV = 'EVNT:SYS1:1:INJECTRATE';
        event_info.liveRate = lcaGet(event_info.ratePV);
    otherwise
        error(['Event code ' num2str(EC) ' not supported.']);
end
        

