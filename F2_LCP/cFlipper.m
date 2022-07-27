classdef cFlipper < handle & acFlipper
    %cFlipper handles pneumatic flippers 
    %   
    %  CONSTRUCTOR: 
    %       cFlipper(PV, polarity):
    %       PV is the flipper PV string, e.g. 'APC:LI20:EX02:24VOUT_4'
    %       Polarity is 1 or -1: 1 => ON/IN = flipper in beam path 
    %        -1 => ON/IN = flipper out of beam path
    %
    %
    %  FUNCTIONS:
    %      flipIn():
    %           Flips the flipper into the beam path
    %
    %      flipOut():
    %           Flips the flipper out of the beam path
    %
    %      flip():
    %           Flips the flipper to the opposite state
    %
    
    properties
        PV
        polarity % 1 => on = in, -1 => on = out
        stateIn 
        stateOut
    end
    
    methods
        function s = cFlipper(PV,polarity)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            
            if ~ (polarity == 1 || polarity == -1)
                error('1. Something is rotten in the state of Denmark')
            end
            
            s.PV = PV;
            s.polarity = polarity;
            
            stateStr = lcaGetSmart(PV);
            
            if strcmp(stateStr, 'ON') || strcmp(stateStr, 'OFF')
               s.stateIn = 'ON';
               s.stateOut = 'OFF';
            elseif strcmp(stateStr, 'IN') || strcmp(stateStr, 'OUT')
               s.stateIn = 'IN';
               s.stateOut = 'OUT';
            elseif strcmp(stateStr, 'Low') || strcmp(stateStr, 'High')
               s.stateIn = 'Low';
               s.stateOut = 'High';
            else
                error('Flipper states not recognized')
            end
            
            if polarity == -1
                tmp = s.stateIn;
                s.stateIn = s.stateOut;
                s.stateOut = tmp;
            elseif polarity == 1
                a = 1;
            else
                error('Polarity has to be 1 or -1')
            end
            
            
        end
        
        function flipIn(s)
            %FLIPIN() Flips the flipper into the laser path
            lcaPutSmart(s.PV, s.stateIn);
        end
        
        function flipOut(s)
            %FLIPOUT() Flips the flipper out the laser path
            lcaPutSmart(s.PV, s.stateOut);
        end
        
        function flip(s)
            %FLIP() Flips the flipper to the opposite state
            stateStr = lcaGetSmart(s.PV);
            if strcmp(stateStr,s.stateIn)
                s.flipOut();
            elseif strcmp(stateStr,s.stateOut)
                s.flipIn();
            else
                error('3. Something is rotten in the state of Denmark')
            end
        end
        
        function sStr = getState(s)
            %GETSTATE() returns state of flipper as 'IN' beam path or 'OUT'
            % of beam path
            stateStr = lcaGetSmart(s.PV);
            if strcmp(stateStr,s.stateIn)
                sStr = 'In';
            elseif strcmp(stateStr,s.stateOut)
                sStr = 'Out';
            else
                error('4. Something is rotten in the state of Denmark')
            end
        end
        
        function desc = getDesc(s)
            desc = lcaGetSmart([s.PV,'.DESC']);
            desc = desc{1};
        end
        
        function pstr = print(s)
            status = s.getState();
            name = s.getDesc();
            PV = s.PV;
            pstr = sprintf('| %s | %s | %s ', name, PV, status);
        end
        
    end
end

