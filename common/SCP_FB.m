classdef SCP_FB < handle
  %SCP_FB Control of SCP Feedbacks
  %  Currently implemented: LI11, LI18 transverse feedback loops
  %
  % >> FB=SCP_FB
  % >> FB.name = "TRANS_LI11" | "TRANS_LI18"
  % >> FB.state = "OFF" | "Running" | "Compute"
  properties
    name string {mustBeMember(name,["TRANS_LI11","TRANS_LI18"])} = "TRANS_LI11"
  end
  properties(Dependent)
    state string
    hsta_name
  end
  methods
    function st = get.state(obj)
      aidapva;
      h=num2hex(pvaRequest(char(obj.hsta_name)).returning(AIDA_INTEGER).get());
      if ~str2double(h(7))
        st = "OFF" ;
      elseif str2double(h(8))>0
        st = "Running" ;
      else
        st = "Compute" ;
      end
    end
    function set.state(obj,st)
      aidapva;
      h=num2hex(pvaRequest(char(obj.hsta_name)).returning(AIDA_INTEGER).get());
      switch string(st)
        case "OFF"
          h(7)='0';
        case "Running"
          h(7:8)='88';
        case "Compute"
          h(7:8)='80';
        otherwise
          error("Unknown state option");
      end
      pvaRequest(obj.hsta_name).with('VALUE_TYPE','INTEGER_ARRAY').set(hex2num(h));
    end
    function hsta = get.hsta_name(obj)
      switch obj.name
        case "TRANS_LI11"
          hsta = "FBCK:LI11:26:HSTA" ;
        case "TRANS_LI18"
          hsta = "FBCK:LI18:28:HSTA" ;
      end
    end
  end
end