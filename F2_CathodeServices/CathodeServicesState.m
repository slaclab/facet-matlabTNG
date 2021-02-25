classdef CathodeServicesState < uint8
  %State options for cathode services operations
  
  enumeration
    Standby_opslasermode (0)
    Standby_cleaninglasermode (1)
    Cleaning_linescan (2)
    Cleaning_movingtonewline (3)
    QEMap_linescan (4)
    Abort_user (5)
    Abort_watchdog (6)
    Abort_epicswatchdog (7)
    Unknown (8)
    Cleaning_testpattern (9)
    Cleaning_setenergypattern (10)
    Cleaning_definearea (11)
    QEMap_definearea (12)
    QEMap_movingtonewline (13)
  end
  
  methods
    function err = iserror(obj) % Software is in error state for these
      if ismember(uint8(obj),5:8)
        err=true;
      else
        err=false;
      end
    end
    function ismap = isqemapstate(obj)
      ismap = ismember(uint8(obj),[4 12 13]) ;
    end
    function iserrck = iserrckpattern(obj) % These states indicate an autostop error should happen
      if ismember(uint8(obj),[2 3 4 10 13])
        iserrck = true;
      else
        iserrck = false;
      end
    end
    function isauto = isautopattern(obj) % These states indicate an automatic program is running
      if ismember(uint8(obj),[2 3 4 9 10 13])
        isauto = true;
      else
        isauto = false;
      end
    end
    function gunoffstate = isgunoffstate(obj) % Gun RF should be OFF for these
      if ismember(uint8(obj),[1 2 3 9 10 11])
        gunoffstate=true;
      else
        gunoffstate=false;
      end
    end
    function txt = text(obj) % 1 line text explanations of states for GUI display purposes
      switch uint8(obj)
        case 0
          txt = "Standby, laser in operations mode (large spot)" ;
        case 1
          txt = "Standby, laser in cleaning mode (small spot)" ;
        case 2
          txt = "Cleaning: scanning line" ;
        case 3
          txt = "Cleaning: moving to new line" ;
        case 4
          txt = "Running QE Map program, scanning line" ;
        case 5
          txt = "Stopped: user abort requested" ;
        case 6
          txt = "Error: auto abort triggered" ;
        case 7
          txt = "Error: EPICS watchdog abort triggered" ;
        case 8
          txt = "Error: unknown mode" ;
        case 9
          txt = "Cleaning: moving in test pattern" ;
        case 10
          txt = "Cleaning: laser energy setting pattern" ;
        case 11
          txt = "Cleaning: define area to clean" ;
        case 12
          txt = "QE Map: define mapping area" ;
        case 13
          txt = "QE Map: moving to start of new line to scan" ;
      end
    end
  end
  
end

