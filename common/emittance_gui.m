


function varargout = emittance_gui(varargin)
% EMITTANCE_GUI is an interactive matlab application that measures beam 
% emittance.
% 
%      The application can use either a number of wirescanners and profile
%      monitors, or use quadrupoles and a number of screens. Projected or 
%      slice emittance.
% 
%      M-file for emittance_gui.fig
%      EMITTANCE_GUI, by itself, creates a new EMITTANCE_GUI or raises the existing
%      singleton*.
%
%      H = EMITTANCE_GUI returns the handle to a new EMITTANCE_GUI or the handle to
%      the existing singleton*.
%
%      EMITTANCE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EMITTANCE_GUI.M with the given input arguments.
%
%      EMITTANCE_GUI('Property','Value',...) creates a new EMITTANCE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before emittance_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to emittance_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help emittance_gui

% Last Modified by GUIDE v2.5 01-Nov-2021 16:36:28
% Mod:  18-May-2016 T. Maxwell, add back QS on WSVM2 and create WS33 QS
%       16-Sep-2016 Greg White, revered addition of WSVM2 to multiwire scan.
%       03-Dec-2020 G. White, add IN10 devices
%       27-Feb-2020 S. Gessner, add S19/S20 devices

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @emittance_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @emittance_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before emittance_gui is made visible.
function emittance_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to emittance_gui (see VARARGIN)

emittance_const;
warning backtrace off;  % Don't give files and function names of warnings,
                        % all that is handled by logging.

% Choose default command line output for emittance_gui
handles.output = hObject;

try
    % Application constants initialization
    handles=appInit(hObject,handles);
        
    % Add Menu Bar
    %
    % The follow adds File and Controls menu bar operations to the GUI
    %
    set(gcf,'MenuBar','None');
    
    % Add "File" menubar item
    %
    handles.menuFile=uimenu('Label','File');
    
    % Add "File->View Log" 
    handles.menuFile_itemViewLog=...
        uimenu(handles.menuFile,'Label','Execution Log...');
    set(handles.menuFile_itemViewLog,'Callback',...
        {@viewLog_Callback,handles});

    % File->Screenshot
    handles.menuFile_itemScreenShot=...
        uimenu(handles.menuFile,'Label','Screen Shot to Physics Log');
    set(handles.menuFile_itemScreenShot,'Callback',...
        {@screenShot_Callback,handles});

    % File->Quit
    handles.menuFile_itemQuit=...
        uimenu(handles.menuFile,'Label','Quit Emittance');
    set(handles.menuFile_itemQuit,'Callback',...
        {@quit_Callback,handles});

    % Add Controls menubar menu
    %
    % Controls menubar menu
    handles.menuControls=uimenu('Label','Controls');
    
    % Controls->LCLS Home = display lcls_main.edl
    handles.menuControls_itemGlobal=...
        uimenu(handles.menuControls,'Label','LCLS Home');
    set(handles.menuControls_itemGlobal,'Callback',...
        {@controlsScreen_Callback,handles,'lcls_main.edl'});
    
    % Controls->Wire Scanners-> submenu
    %
    handles.menuControls_smenuWireScanners=uimenu(handles.menuControls);
    set(handles.menuControls_smenuWireScanners,'Label','Wire Scanners');
    
    % Controls->Wire Scanners->IN20 = display ws_in20_main.edl
    handles.menuControls_smenuWireScanners_itemIN20=...
        uimenu(handles.menuControls_smenuWireScanners,'Label','IN20');
    set(handles.menuControls_smenuWireScanners_itemIN20,'Callback',...
        {@controlsScreen_Callback,handles,'ws_in20_main.edl'});
    
    % Controls->Wire Scanners->LI21 = display ws_li21_main.edl
    handles.menuControls_smenuWireScanners_itemLI21=...
        uimenu(handles.menuControls_smenuWireScanners,'Label','LI21');
    set(handles.menuControls_smenuWireScanners_itemLI21,'Callback',...
        {@controlsScreen_Callback,handles,'ws_li21_main.edl'});
    
    % Controls->Wire Scanners->LI24 = display ws_li24_main.edl
    handles.menuControls_smenuWireScanners_itemLI24=...
        uimenu(handles.menuControls_smenuWireScanners,'Label','LI24');
    set(handles.menuControls_smenuWireScanners_itemLI24,'Callback',...
        {@controlsScreen_Callback,handles,'ws_li24_main.edl'});
    
    % Controls->Wire Scanners->LI28 = display ws_li28_main.edl
    handles.menuControls_smenuWireScanners_itemLI28=...
        uimenu(handles.menuControls_smenuWireScanners,'Label','LI28');
    set(handles.menuControls_smenuWireScanners_itemLI28,'Callback',...
        {@controlsScreen_Callback,handles,'ws_li28_main.edl'});
    
    % Controls->Wire Scanners->LTUH = display ws_ltu1_main.edl
    handles.menuControls_smenuWireScanners_itemLTU1=...
        uimenu(handles.menuControls_smenuWireScanners,'Label','LTUH');
    set(handles.menuControls_smenuWireScanners_itemLTU1,'Callback',...
        {@controlsScreen_Callback,handles,'ws_ltuh_main.edl'});
    
    % Controls->Wire Scanners->UND1 = display ws_und1_main.edl
    handles.menuControls_smenuWireScanners_itemUND1=...
        uimenu(handles.menuControls_smenuWireScanners,'Label','UNDH');
    set(handles.menuControls_smenuWireScanners_itemUND1,'Callback',...
        {@controlsScreen_Callback,handles,'ws_undh_main.edl'});
    
    
    % Controls->Profile Monitors submenu
    %
    handles.menuControls_smenuProfileMonitors=uimenu(handles.menuControls);
    set(handles.menuControls_smenuProfileMonitors,'Label','Profile Monitors');
    
    % Controls->Profile Monitors->IN20 = display prof_in20_main.edl
    handles.menuControls_smenuProfileMonitors_itemIN20=...
        uimenu(handles.menuControls_smenuProfileMonitors,'Label','IN20');
    set(handles.menuControls_smenuProfileMonitors_itemIN20,'Callback',...
        {@controlsScreen_Callback,handles,'prof_in20_main.edl'});
    
    % Controls->Profile Monitors->LI21 = display prof_li21_main.edl
    handles.menuControls_smenuProfileMonitors_itemLI21=...
        uimenu(handles.menuControls_smenuProfileMonitors,'Label','LI21');
    set(handles.menuControls_smenuProfileMonitors_itemLI21,'Callback',...
        {@controlsScreen_Callback,handles,'prof_li21_main.edl'});
    
    % Controls->Profile Monitors->LI24 = display prof_li24_main.edl
    handles.menuControls_smenuProfileMonitors_itemLI24=...
        uimenu(handles.menuControls_smenuProfileMonitors,'Label','LI24');
    set(handles.menuControls_smenuProfileMonitors_itemLI24,'Callback',...
        {@controlsScreen_Callback,handles,'prof_li24_main.edl'});
    
    % Controls->Profile Monitors->LI28 = display prof_li28_main.edl
    % (there are no profile mons in LI28)
    
    % Controls->Profile Monitors->LTU1 = display prof_ltu1_main.edl
    handles.menuControls_smenuProfileMonitors_itemLTU1=...
        uimenu(handles.menuControls_smenuProfileMonitors,'Label','LTUH');
    set(handles.menuControls_smenuProfileMonitors_itemLTU1,'Callback',...
        {@controlsScreen_Callback,handles,'prof_ltuh_main.edl'});
    
    % Controls->Profile Monitors->UND1 = display prof_und1_main.edl
    handles.menuControls_smenuProfileMonitors_itemUND1=...
        uimenu(handles.menuControls_smenuProfileMonitors,'Label','UND1');
    set(handles.menuControls_smenuProfileMonitors_itemUND1,'Callback',...
        {@controlsScreen_Callback,handles,'prof_und1_main.edl'});

    % Controls->Quadrupoles submenu
    %
    handles.menuControls_smenuQuadrupoles=uimenu(handles.menuControls);
    set(handles.menuControls_smenuQuadrupoles,'Label','Quadrupoles');
    
    % Controls->Quadrupoles->IN20 = display mgnt_in20_quad.edl
    handles.menuControls_smenuQuadrupoles_itemIN20=...
        uimenu(handles.menuControls_smenuQuadrupoles,'Label','IN20');
    set(handles.menuControls_smenuQuadrupoles_itemIN20,'Callback',...
        {@controlsScreen_Callback,handles,'mgnt_in20_quad.edl'});
    
    % Controls->Quadrupoles->LI21 = display mgnt_li21_quad.edl
    handles.menuControls_smenuQuadrupoles_itemLI21=...
        uimenu(handles.menuControls_smenuQuadrupoles,'Label','LI21');
    set(handles.menuControls_smenuQuadrupoles_itemLI21,'Callback',...
        {@controlsScreen_Callback,handles,'mgnt_li21_quad.edl'});
    
    % Controls->Quadrupoles->LI24 = display mgnt_li24_quad.edl
    handles.menuControls_smenuQuadrupoles_itemLI24=...
        uimenu(handles.menuControls_smenuQuadrupoles,'Label','LI24');
    set(handles.menuControls_smenuQuadrupoles_itemLI24,'Callback',...
        {@controlsScreen_Callback,handles,'mgnt_li24_quad.edl'});
    
    % Controls->Quadrupoles->LI28 = display mgnt_li28_quad.edl
    handles.menuControls_smenuQuadrupoles_itemLI28=...
        uimenu(handles.menuControls_smenuQuadrupoles,'Label','LI28');
    set(handles.menuControls_smenuQuadrupoles_itemLI28,'Callback',...
        {@controlsScreen_Callback,handles,'mgnt_li28_quad.edl'});
    
    % Controls->Quadrupoles->LTU1 = display mgnt_ltu1_quad.edl
    handles.menuControls_smenuQuadrupoles_itemLTU1=...
        uimenu(handles.menuControls_smenuQuadrupoles,'Label','LTUH');
    set(handles.menuControls_smenuQuadrupoles_itemLTU1,'Callback',...
        {@controlsScreen_Callback,handles,'mgnt_ltuh_quad.edl'});
    
    % Controls->Quadrupoles->UND1 = display mgnt_und1_quad.edl
    handles.menuControls_smenuQuadrupoles_itemUND1=...
        uimenu(handles.menuControls_smenuQuadrupoles,'Label','UND1');
    set(handles.menuControls_smenuQuadrupoles_itemUND1,'Callback',...
        {@controlsScreen_Callback,handles,'mgnt_und1_quad.edl'});
    
    % Add Help menubar item
    %
    handles.menuHelp=uimenu('Label','Help');
    
    % Help->Ad-ops Wiki entry [of Emittance]
    handles.menuHelp_itemWiki=...
        uimenu(handles.menuHelp,'Label','Ad-ops wiki entry...');
    set(handles.menuHelp_itemWiki,'Callback',...
        {@help_Callback,handles});

    
    % Log successful application launch. 
    lprintf(STDOUT,'Instance of Emittance GUI launched successfully');
    
catch ex
    if ~strncmp(ex.identifier,EM_EXID_PREFIX,3)  
       lprintf(STDERR, '%s', ex.getReport());
    end
    uiwait(errordlg(...
        lprintf(STDERR, 'Could not initialize GUI. %s', ex.message)));
end


% Update handles structure
guidata(hObject, handles);




% --- Outputs from this function are returned to the command line.
function varargout = emittance_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close emittance_gui.
function emittance_gui_CloseRequestFcn(hObject, eventdata, handles)

emittance_const;            % Application specific constants.
EXITMSG=...
   'Emittance GUI exits by user selection.';
lprintf(STDOUT, EXITMSG);

util_appClose(hObject);


% ------------------------------------------------------------------------
function data = appRemote(hObject, devName, measureType, plane)

[hObject,handles]=util_appFind('emittance_gui');
[sector,devId]=measureDevFind(hObject,handles,devName,measureType);
handles=sectorControl(hObject,handles,sector);
handles=measureTypeInit(hObject,handles,measureType);
handles=measureDevListControl(hObject,handles,devId);
if nargin > 3
    handles=processPlaneControl(hObject,handles,plane);
end

handles.process.saved=1;
handles=acquireStart(hObject,handles);
data=handles.data;
handles.process.saved=1;
guidata(hObject,handles);


% ------------------------------------------------------------------------
function data = appQuery(hObject)

[hObject,handles]=util_appFind('emittance_gui');
data=handles.data;


% ------------------------------------------------------------------------
function handles = appInit(hObject, handles)

% List of index names.
handles.indexList={'LCLS' {'IN20' 'LI21' 'LI24' 'LI28' 'LTUH' 'LTUS'}; ...
    'FACET' {'IN10' 'LI11' 'LI15' 'LI19' 'LI20'}; ...
    'NLCTA' {'NLCTA'}; ...
    'LCLS2' {'GUNB'}; ...
    'XTA'   {'XT01'}; ...
    'ASTA'  {'AS01'}; ...
    };

% Wire scanner MAD names by sector
handles.sector.IN20.wireMADList={ ...
    'WS01' 'WS02' 'WS03' 'WS04'};
handles.sector.LI21.wireMADList={ ...
    'WS11' 'WS12' 'WS13'};
handles.sector.LI24.wireMADList={ ...
    'WS24'};
handles.sector.LI28.wireMADList={ ...
%    'WS21' 'WS22' 'WS23' 'WS24' ...
    'WS27644' 'WS28144' 'WS28444' 'WS28744'};
handles.sector.LTUH.wireMADList={ ...
    'WS31' 'WS32' 'WS33' 'WS34' 'WS35' 'WSVM2'};
handles.sector.LTUS.wireMADList={ ...
    'WS31B' 'WS32B' 'WS33B' 'WS34B'};
handles.sector.NLCTA.wireMADList={ ...
    ''};
handles.sector.XT01.wireMADList={ ...
    ''};
handles.sector.AS01.wireMADList={ ...
    ''};
handles.sector.LI20.wireMADList={ ...
    'WSIP1' 'WSIP2' 'WSIP3' 'WSIP4'};
handles.sector.IN10.wireMADList={ ...
    'WS10561'};
handles.sector.LI11.wireMADList={ ...
    'WS11444'    'WS11614'    'WS11744'    'WS12214'};
handles.sector.LI15.wireMADList={ ...
    ''};
handles.sector.LI19.wireMADList={ ...
     'WS18944'    'WS19144'    'WS19244'    'WS19344'};
handles.sector.GUNB.wireMADList={ ...
    ''};


% Profile monitor MAD names by sector
handles.sector.IN20.profMADList={ ...
    'YAG01' 'YAG02' 'YAG03' 'YAG04' ...
    'YAGG1' 'YAGS1' 'YAGS2' ...
    'OTR1' 'OTR2' 'OTR3' 'OTR4' ...
    'OTRS1'};
handles.sector.LI21.profMADList={ ...
    'OTR11' 'OTR12'};
handles.sector.LI24.profMADList={ ...
    ''};
handles.sector.LI28.profMADList={ ...
    'OTR21' 'OTR22'};
handles.sector.LTUH.profMADList={ ...
    'OTR30' 'OTR33' 'YAGPSI'};
handles.sector.LTUS.profMADList={ ...
    ''};
handles.sector.NLCTA.profMADList={ ...
    'P810595T' 'P811550T' 'P812290T' 'P812250T' 'P812190T'};
handles.sector.XT01.profMADList={ ...
    'YAG150X' 'OTR250X' 'OTR350X' 'YAG550X'};
handles.sector.AS01.profMADList={ ...
    'YAG3S'};
handles.sector.LI20.profMADList={ ...
    'PMON' 'USOTR' 'IPOTR1' 'DSOTR'};
handles.sector.IN10.profMADList={ ...
    'PR10571' 'PR10711'};
handles.sector.LI11.profMADList={ ...
    'PR11375'};
handles.sector.LI15.profMADList={ ...
    'PR15944'};
handles.sector.LI19.profMADList={ ...
    ''};
handles.sector.GUNB.profMADList={ ...
    'YAG01B'};


% Quad MAD names by sector
handles.sector.IN20.quadMADList={ ...
    'SOL1' 'SOL2' 'QA01' 'QA02' ...
    'QE01' 'QE02' 'QE03' 'QE04' ...
    'QM01' 'QM02' 'QM03' 'QM04'};
handles.sector.LI21.quadMADList={ ...
    'QA11' 'QA12' 'Q21201' ...
    'QM11' 'QM12' 'QM13'};
handles.sector.LI24.quadMADList={ ...
    'Q24201'};
handles.sector.LI28.quadMADList={ ...
    'QM21' 'Q28201'};
handles.sector.LTUH.quadMADList={ ...
    'QA0' 'QEM3V' 'QEM1' 'QEM2' 'QEM3' 'QEM4'};
handles.sector.LTUS.quadMADList={ ...
    'QEM3VB' 'QEM1B' 'QEM2B' 'QEM3B' 'QEM4B'};
handles.sector.NLCTA.quadMADList={ ...
    'Q810530T' 'Q810560T' 'Q810575T' 'Q810590T' 'Q811510T' 'Q811530T'};
handles.sector.XT01.quadMADList={ ...
    'SOL1X' 'QE01X' 'QE02X' 'QE03X' 'QE04X'};
handles.sector.AS01.quadMADList={ ...
    'SOL1S'};
handles.sector.LI20.quadMADList={ ...
    'Q5FF' 'Q4FF' 'Q2FF' 'Q1FF' 'Q0FF'};

handles.sector.IN10.quadMADList={ ...
    'QE10511' 'QE10525'};
handles.sector.LI11.quadMADList={ ...
    'QM11362' 'QM11358'};
handles.sector.LI15.quadMADList={ ...
    'Q15701' 'Q15801' 'Q15901'};
handles.sector.LI19.quadMADList={ ...
    ''};
handles.sector.GUNB.quadMADList={ ...
    'SOL1B' 'SOL2B'};

% 3 screen devices by sector
handles.sector.IN20.multiDevList={ ...
    'wire' [1 2 3]; ...
    'prof' [8 9 10]};
handles.sector.LI21.multiDevList={ ...
    'wire' [1 2 3]};
handles.sector.LI24.multiDevList={ ...
    };
handles.sector.LI28.multiDevList={ ...
    'wire' [1 2 3 4]; ...
    'wire' [2 3 4]};
handles.sector.LTUH.multiDevList={ ...
    'wire' [1 2 3 4]}; 
handles.sector.LTUS.multiDevList={ ...
    'wire' [1 2 3 4]}; 
handles.sector.NLCTA.multiDevList={ ...
    };
handles.sector.XT01.multiDevList={ ...
    };
handles.sector.AS01.multiDevList={ ...
    };
handles.sector.IN10.multiDevList={ ...
    };
handles.sector.LI11.multiDevList={ ...
    'wire' [1 2 3 4];...
    };
handles.sector.LI15.multiDevList={ ...
    };
handles.sector.LI19.multiDevList={ ...
    'wire' [1 2 3 4];...
    };
handles.sector.LI20.multiDevList={ ...
    'wire' [1 2 3]; ...
    'prof' [1 2 3 4]; ...
    };
handles.sector.GUNB.multiDevList={ ...
    };

% Quad scan devices by sector {strType numDev [numQuad ...]}
handles.sector.IN20.scanDevList={ ...
    'prof'  1 1; ...
    'prof'  2 1; ...
    'prof'  4 [5 6]; ...
    'wire'  2 [5 6 7 8]; ...
    'prof'  8 [5 6 7 8]; ...
    'prof'  9 [5 6 7 8]; ...
    'prof' 10 [5 6 7 8]; ...
    'prof' 11 [9 10]; ...
    'prof'  6 [9 10]};
handles.sector.LI21.scanDevList={ ...
    'wire' 2 [5 6]; ...
    'prof' 1 [2 3]; ...
    'prof' 2 [4 5 6]};
handles.sector.LI24.scanDevList={ ...
    'wire' 1 1};
handles.sector.LI28.scanDevList={ ...
    'prof' 1 1; ...
    'wire' 4 2};
handles.sector.LTUH.scanDevList={ ...
    'prof' 3 [2 3 4 5 6]; ...
    'wire' 2 [2 3 4 5 6]; ...
    'wire' 6 1; };
handles.sector.LTUS.scanDevList={ ...
    'wire' 2 [1 2 3 4 5]};
handles.sector.NLCTA.scanDevList={ ...
    'prof' 1 [1 2 3 4 5 6]; ...
    'prof' 2 [1 2 3 4 5 6];};
handles.sector.XT01.scanDevList={ ...
    'prof' 1 1; ...
    'prof' 2 [2 3 4 5]; ...
    'prof' 3 [2 3 4 5]; ...
    'prof' 4 [2 3 4 5]};
handles.sector.AS01.scanDevList={ ...
    'prof' 1 1};
handles.sector.LI20.scanDevList={ ...
    'prof' 1 [1 2]; ...
    'wire' 1 [3 4 5]; ...
    'wire' 2 [3 4 5]; ...
    'wire' 3 [3 4 5]; ...
    %'wire' 1 [1 2 3]; ...
    %'wire' 2 [1 2 3]; ...
    %'wire' 3 [1 2 3]; ...
    %'prof' 3 [1 2 3]; ...
    %'prof' 4 [1 2 3]; ...
    %'prof' 5 [1 2 3]; ...
    %'prof' 6 [1 2 3]; ...
    %'prof' 7 [1 2 3]; ...
    %'prof' 8 [1 2 3]; ...   
    };
handles.sector.IN10.scanDevList={ ...
    'prof' 1 [1 2]; ...   
    'prof' 2 [1 2]; ... 
};
handles.sector.LI15.scanDevList={ ...
    'prof' 1 [1 2 3];
};
handles.sector.LI11.scanDevList={ ...
    'prof' 1 [1 2]; ...
    'wire' 1 [1 2]; ...    
};
handles.sector.LI19.scanDevList={ ...
    'prof' 1 1};
handles.sector.GUNB.scanDevList={ ...
    'prof' 1 [1 2]; ...
    };

% PAL additions.
handles.indexList(end+1,:)={'PAL'   {'PL01' 'PL02'}};
handles.sector.PL01.wireMADList={ ...
    'WS01P' 'WS02P' 'WS03P'};
handles.sector.PL01.profMADList={ ...
    'OTR01P' 'OTR02P' 'OTR03P' 'OTR04P'};
handles.sector.PL01.quadMADList={ ...
    'QE01P' 'QE02P'};
handles.sector.PL01.multiDevList={ ...
    'wire' [1 2 3]; ...
    'prof' [2 3 4]};
handles.sector.PL01.scanDevList={ ...
    'prof' 3 [1 2]; ...
    'prof' 4 [1 2]; ...
    'wire' 2 [1 2]};
handles.sector.PL02.wireMADList={ ...
    ''};
handles.sector.PL02.profMADList={ ...
    };
handles.sector.PL02.quadMADList={ ...
    ''};
handles.sector.PL02.multiDevList={ ...
    };
handles.sector.PL02.scanDevList={ ...
    'wire' [] []};


% Devices to use and data initialization for each wire/prof by sector
for tag=fieldnames(handles.sector)'
    sector=handles.sector.(tag{:});
    if ~isstruct(sector), continue, end
    sector.wireDevList=model_nameConvert(sector.wireMADList,'EPICS');
    sector.profDevList=model_nameConvert(sector.profMADList,'EPICS');
    sector.quadDevList=model_nameConvert(sector.quadMADList,'EPICS');
    devList=sector.scanDevList;
    num=size(devList,1);
    sector.measureQuadUsed=ones(num,1);
    range=cellfun(@(x) x*0,devList(:,[3 3]),'UniformOutput',false);
    sector.measureQuadRange=range;
    sector.measureType='scan';
    sector.measureDevListId=struct('scan',1,'multi',1);
    sector.measureQuadAutoVal=0;
    handles.sector.(tag{:})=sector;
end

% Initialize GUI control values.
handles.measureQuadHandles=[handles.measureQuad_pan; ...
    get(handles.measureQuad_pan,'Children')];
handles.measureQuadRange={0 0};
handles.measureQuadValNum=7;
handles.measureQuadAutoVal=0;
handles.measureQuadAutoValXY=0;
handles.measureQuadAutoValSource=0;
handles.processNumBG=1;
handles.processAverage=0;
handles.processSampleNum=1;
handles.processSelectMethod=1;
handles.processSlicesNum=0;
handles.processSliceWin=3;
handles.processDisplayNormalize=1;
handles.processDisplayPhaseSpace=0;
handles.processResolution=0;
handles.measureType='multi';
handles.noHeater=1;
handles.profmonCut=0.05;
handles.profmonMedian=0;

% Select fields to be saved in config file.
handles.configList={'measureQuadValNum' 'processNumBG' 'processAverage' ...
    'processSampleNum' 'processSelectMethod' 'processSliceWin' 'measureType' ...
    'measureQuadAutoVal' 'measureQuadAutoValXY' 'measureQuadAutoValSource' ...
    'processDisplayNormalize' 'processDisplayPhaseSpace'};
handles.sector.configList={'measureQuadUsed' 'measureQuadRange' ...
    'measureType' 'measureDevListId' 'measureQuadAutoVal'};

set(handles.sectorSel_btn,'Position',get(handles.sectorSel_btn,'Position')-[0 0 2 0]);

% Initialize sector buttons (done in indexControl)
%handles.sectorSel=handles.sector.nameList{1};
%handles=gui_radioBtnInit(hObject,handles,'sectorSel',handles.sector.nameList,'_btn');

% Initialize indices (a.k.a. facilities).
handles=gui_indexInit(hObject,handles,'Emittance Measurement');

% Finish initialization.
guidata(hObject,handles);
util_appFonts(hObject,'fontName','Helvetica','lineWidth',1,'fontSize',10);
handles=appSetup(hObject,handles);
handles=processInit(hObject,handles);
handles=gui_appLoad(hObject,handles);


% ------------------------------------------------------------------------
function handles = appSetup(hObject, handles)

handles=gui_indexControl(hObject,handles,[]);
%handles=sectorControl(hObject,handles,[]);
handles=processSlicesNumControl(hObject,handles,[],[]);
handles=processDisplayNormalizeControl(hObject,handles,[]);
handles=processDisplayPhaseSpaceControl(hObject,handles,[]);
handles=dataMethodControl(hObject,handles,[],6);
handles=processAverageControl(hObject,handles,[]);
handles=processResolutionControl(hObject,handles,[]);
handles=profmonCutControl(hObject,handles,[]);
handles=profmonMedianControl(hObject,handles,[]);


% ------------------------------------------------------------------------
function handles = sectorControl(hObject, handles, name)

[handles,cancd,name]=gui_dataRemove(hObject,handles,name);
handles=gui_radioBtnControl(hObject,handles,'sectorSel',name, ...
    numel(handles.sector.nameList) > 0,'_btn');
if cancd, return, end
if ~isempty(name) && ismember(name,{'LTUS'})
    beamPath = 'CU_SXR';
elseif strcmp(getSystem,'SYS0')
    beamPath = 'CU_HXR';
elseif strcmp(getSystem,'SYS1')
    beamPath = 'F2_ELEC';
else
    beamPath = '';
end
gui_modelSourceControl(hObject,handles,[],beamPath);
edsysControl(hObject,handles,[]);
noHeaterControl(hObject,handles,[]);
handles=measureTypeInit(hObject,handles,[]);


% ------------------------------------------------------------------------
function handles = measureTypeInit(hObject, handles, tag)

sector=handles.sector.(handles.sectorSel);
handles.measureType=sector.measureType;
[handles,cancd,tag]=gui_dataRemove(hObject,handles,tag);
handles=gui_popupMenuControl(hObject,handles,'measureType',tag,{'multi' 'scan'});
if cancd, return, end
tag=handles.measureType;
handles.sector.(handles.sectorSel).measureType=tag;
if isempty(sector.([tag 'DevList'])), return, end

devType=sector.([tag 'DevList'])(:,1);
devNum=sector.([tag 'DevList'])(:,2);
str=cell(size(devNum,1),1);
for j=1:size(devNum,1)
    str{j}=sprintf('%s ',sector.([devType{j} 'MADList']){devNum{j}});
end
set(handles.measureDevList_pmu,'String',str,'Value',1);

state={'off' 'on'};
set(handles.measureQuadHandles,'Visible', ...
    state{strcmp(tag,'scan')+1});
handles=measureDevListControl(hObject,handles,[]);
guidata(hObject,handles);


% ------------------------------------------------------------------------
function [sector, devId] = measureDevFind(hObject, handles, devName, measureType)

devName=model_nameConvert(devName,'EPICS');
sector='';devId=0;
for tag=handles.sector.nameList
    for devType={'prof' 'wire'}
        val=strcmpi(handles.sector.(tag{:}).([devType{:} 'DevList']),devName);
        if any(val)
            sector=tag{:};
            devList=handles.sector.(tag{:}).([measureType 'DevList']);
            devId=find(strcmp(devList(:,1),devType) & cellfun(@(x) ismember(find(val,1),x),devList(:,2)),1);
        end
    end
end


% ------------------------------------------------------------------------
function handles = measureDevListControl(hObject, handles, listId)

% Set devList control.
sector=handles.sector.(handles.sectorSel);
[handles,cancd,listId]=gui_dataRemove(hObject,handles,listId);
if isempty(listId)
    listId=sector.measureDevListId.(handles.measureType);
end
handles.measureDevListId=listId;
handles.sector.(handles.sectorSel).measureDevListId.(handles.measureType)=listId;
set(handles.measureDevList_pmu,'Value',listId);
if cancd, return, end
devList=sector.([handles.measureType 'DevList'])(listId,:);
devType=devList{1};
handles.measureDevType=devList{1};
measureDevId=devList{2};
if numel(measureDevId) == 0
    error('EM:NOMEASUREMENTDEVICES','No measurement devices in sector');
end
handles.measureDevName=sector.([devType 'DevList'])(measureDevId);
handles.devRef=handles.measureDevName{round(end/2)};
if numel(handles.measureDevName) == 5, handles.devRef=handles.measureDevName{2};end
set([handles.profIn_btn handles.profOut_btn handles.profInOutLabel_txt handles.wireStatus_txt],'Visible','off');
wireStatusControl(hObject,handles);
handles.twiss0=model_twissGet(handles.devRef,'TYPE=DESIGN');

if strcmp(handles.sectorSel, 'LI20') && ~epicsSimul_status
    % get FACET beta* and waist position set by IPCONFIG gui
    r = model_rMatGet(lcaGet('SIOC:SYS1:ML00:SO0351'), handles.devRef);
    twiss_ip = [5e-5, 5e-6; lcaGet('SIOC:SYS1:ML00:AO352'), lcaGet('SIOC:SYS1:ML00:AO354'); 0, 0;];
    handles.twiss0 = model_twissTrans(twiss_ip, r);
end
switch handles.measureType
    case 'multi'
         handles.dataDevice.nVal=length(handles.measureDevName);
         set(handles.dataDeviceLabel_txt,'String',handles.measureDevType);
    case 'scan'
         quadList=devList{3};
         set(handles.measureQuadDev_pmu,'String',sector.quadDevList(quadList));
         handles=measureQuadControl(hObject,handles,[]);
         set(handles.dataDeviceLabel_txt,'String',handles.measureQuadName);
         handles.measureProfOrig=0;
         if strcmp(handles.measureDevType,'prof') && ~strcmp(handles.measureDevName,'YAGS:LTUH:743')
             if strcmp(handles.accelerator,'NLCTA')
                 handles.measureProfOrig=lcaGetSmart(handles.measureDevName,0,'double');
             else
                 handles.measureProfOrig=lcaGetSmart(strcat(handles.measureDevName,':PNEUMATIC'),0,'double');
             end
             set([handles.profIn_btn handles.profOut_btn handles.profInOutLabel_txt],'Visible','on');
         end
end
handles=processSampleNumControl(hObject,handles,[]);
handles=processNumBGControl(hObject,handles,[]);
guidata(hObject,handles);
handles=acquireReset(hObject,handles);
if strcmp(handles.measureDevType,'prof'), iMethod=6;else iMethod=2;end
handles=dataMethodControl(hObject,handles,iMethod,6);


% ------------------------------------------------------------------------
function [handles, cancd] = acquireReset(hObject, handles)

[handles,cancd]=gui_dataRemove(hObject,handles);
if cancd, return, end
handles=dataCurrentDeviceControl(hObject,handles,1,[]);
handles.process.saved=0;
handles.process.done=0;
handles.fileName='';
handles.data.status=zeros(handles.dataDevice.nVal,1);
handles.data.type=handles.measureType;
handles.data.name=handles.measureDevName;
if strcmp(handles.measureType,'scan') && isfield(handles,'measureQuadName')
    handles.data.quadName=handles.measureQuadName;
    handles.data.quadVal=handles.measureQuadValList;
end
handles.data.use=ones(handles.dataDevice.nVal,1);
handles=processUpdate(hObject,handles);
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = measureQuadControl(hObject, handles, val)

listId=handles.measureDevListId;
sector=handles.sector.(handles.sectorSel);
[handles,cancd,val]=gui_dataRemove(hObject,handles,val);
if isempty(val)
    val=sector.measureQuadUsed(listId);
end
handles.sector.(handles.sectorSel).measureQuadUsed(listId)=val;
set(handles.measureQuadDev_pmu,'Value',val);
if cancd, return, end

id=sector.scanDevList{listId,3}(val);
handles.measureQuadName=sector.quadDevList{id};

handles.measureQuadOrigVal=control_magnetGet(handles.measureQuadName,'BDES');
set(handles.measureQuadResetVal_txt,'String',sprintf('%5.2f kG',handles.measureQuadOrigVal));
set(handles.measureQuadVal_txt,'String',sprintf('%5.2f kG',handles.measureQuadOrigVal));
set(handles.dataDeviceLabel_txt,'String',handles.measureQuadName);
[k1,bAct,handles.lEff,handles.en]=model_k1Get(handles.measureQuadName);
elemType='qu';if strncmp(handles.measureQuadName,'SOLN',4), elemType='dr';end
handles.measureQuadOrigRElem=model_rMatElement(elemType,handles.lEff,k1);
%[~,~,~,~,bp] = model_init;
if strcmp(model_init,'MATLAB')
    [~,~,~,~,bp] = model_init;
    handles.rQES0=model_rMatGet(handles.measureQuadName,handles.devRef,...
        {['BEAMPATH=',bp],'POS=END'});
else
    measureQuadRMat=model_rMatGet(handles.measureQuadName,[],'POS=END');
    handles.rQES0=model_rMatGet(handles.devRef)*inv(measureQuadRMat);
end
handles.rQBS0=handles.rQES0*handles.measureQuadOrigRElem;

handles=measureQuadRangeControl(hObject,handles,1:2,[]);
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = measureQuadValNumControl(hObject, handles, val)

[handles,cancd,val]=gui_dataRemove(hObject,handles,val);
handles=gui_editControl(hObject,handles,'measureQuadValNum',val);
if cancd, return, end

handles.measureQuadValList=linspace(handles.measureQuadRange{:}, ...
    handles.measureQuadValNum);
handles.dataDevice.nVal=handles.measureQuadValNum;
guidata(hObject,handles);
handles=measureQuadAutoValControl(hObject,handles,[],[],[]);
handles=acquireReset(hObject,handles);


% ------------------------------------------------------------------------
function handles = measureQuadRangeControl(hObject, handles, tag, val)

sector=handles.sector.(handles.sectorSel);
listId=handles.measureDevListId;
quadNum=sector.measureQuadUsed(listId);
for j=1:2
    handles.measureQuadRange{j}=sector.measureQuadRange{listId,j}(quadNum);
end
[handles,cancd,val]=gui_dataRemove(hObject,handles,val);
handles=gui_rangeControl(hObject,handles,'measureQuadRange',tag,val);
if cancd, return, end
for j=1:2
    handles.sector.(handles.sectorSel).measureQuadRange{listId,j}(quadNum)=handles.measureQuadRange{j};
end
handles=measureQuadValNumControl(hObject,handles,[]);
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = measureQuadAutoValCalc(hObject, handles)

if handles.measureQuadAutoVal && any(handles.rQES0(:))
    twiss=handles.twiss0;
    if handles.measureQuadAutoValSource
        twiss=control_emitGet(handles.devRef);twiss=twiss(2:3,:);
    end
    bLim=handles.measureQuadOrigVal+[-20 20];
    if strcmp(handles.accelerator,'LCLS')
        [bn,bx]=control_deviceGet(handles.measureQuadName,{'BMIN' 'BMAX'});
        bLim=[bn,bx];
    end
    bAct=linspace(bLim(1),bLim(2),100);
    k1=model_k1Get(bAct,handles.lEff,handles.en);

    psi=k1'*[0 0];
    for j=1:length(k1)
        rMat1=handles.rQES0*model_rMatElement('qu',handles.lEff,k1(j))*inv(handles.rQBS0);
        psi(j,:)=model_twissPhase(twiss,rMat1);
    end

    iPlane=1;if strcmpi(handles.processSelectPlane,'y'), iPlane=2;end
    if handles.measureQuadAutoValXY && strcmp(handles.measureDevType,'prof')
        iPlane=1:2;
    end
    phX=psi(:,1);phY=psi(:,2);
    num=handles.measureQuadValNum;
    psi0=mean(psi([1 end],:));
    range=(num-1)*7/8*pi/num;
    range=min([abs(diff(psi([1 end],iPlane))) range]);
    phXList=max(min(psi(:,1)),min(psi0(1)+linspace(-1,1,num)*range/2,max(psi(:,1))));
    phYList=max(min(psi(:,2)),min(psi0(2)+linspace(-1,1,num)*range/2,max(psi(:,2))));
    if any(isnan(psi(:))) || any(isnan(bAct(:)))
        bList=[phXList;phYList]*0;
    else
        bList(1,:)=sort(interp1(phX,bAct,phXList));
        bList(2,:)=sort(interp1(phY,bAct,phYList));
    end
    bList=mean(bList(iPlane,:),1);
    handles.measureQuadValList=bList;
else
    handles.measureQuadValList=linspace(handles.measureQuadRange{:}, ...
        handles.measureQuadValNum);
end
set(handles.(['measureQuadRange' 'Low' '_txt']),'String',num2str(min(handles.measureQuadValList)));
set(handles.(['measureQuadRange' 'High' '_txt']),'String',num2str(max(handles.measureQuadValList)));
%handles=acquireReset(hObject,handles);
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = measureQuadAutoValControl(hObject, handles, val, val2, val3)

if strcmp(handles.measureType,'multi'), return, end
handles.measureQuadAutoVal=handles.sector.(handles.sectorSel).measureQuadAutoVal;
handles=gui_checkBoxControl(hObject,handles,'measureQuadAutoVal',val);
handles.sector.(handles.sectorSel).measureQuadAutoVal=handles.measureQuadAutoVal;
vis=handles.measureQuadAutoVal;
handles=gui_checkBoxControl(hObject,handles,'measureQuadAutoValXY',val2,vis);
handles=gui_checkBoxControl(hObject,handles,'measureQuadAutoValSource',val3,vis);
handles=measureQuadAutoValCalc(hObject,handles);


% ------------------------------------------------------------------------
function edsysControl(hObject, handles, val)
        
bAct=0;
if strcmp('LTUH',handles.sectorSel)
    qEdmch={'QEM1' 'QEM2' 'QEM3' 'QEM4'};
    qEdsys={'QE31' 'QE32' 'QE33' 'QE34' 'QE35' 'QE36'};

    if ~isempty(val)
        if val
            clicked_button = questdlg(['This will set BCON to BDES and trim' ...
                ' for QEM1-4 and QE31-36. Are you sure you want to do this?'], ...
             'Change LTU quads?', ...
             'Cancel', 'Change LTU Quads', 'Cancel');

            if strcmp(clicked_button, 'Cancel')
                return;
            end
            control_magnetSet([qEdmch qEdsys],[],'action','BCON_TO_BDES');
        else
            clicked_button = questdlg(['This will reconfigure the LTU lattice to'...
             ' run quad emittance scans in the LTU.  Are you sure you want to' ...
             ' change LTU matching quads?'], 'Change LTU quads?', ...
             'Cancel', 'Change LTU Quads', 'Cancel');

            if strcmp(clicked_button, 'Cancel')
                return;
            end
            [len,en]=model_rMatGet(qEdmch,[],[],{'LEFF' 'EN'});
            bp=en/299.792458*1e4; % kG m
            k1=[0.52306699115 -0.353726691931 0.476261672082 -0.277924519959];
            %k1=[-80.633 88.380 -83.211 74.227]/(13.64/299.792458*1e4)./len;
            bDes=k1.*bp.*len;

            control_magnetSet(qEdsys,0);
            control_magnetSet(qEdmch,bDes);
        end
    end
    bAct=abs(control_magnetGet(qEdsys{1})) > 1;
end

cols={'default' 'default';'default' 'g';'r' 'default'};
state={'off';'on'};
set([handles.edsysLabel_txt handles.edsysOn_btn handles.edsysOff_btn], ...
    {'Visible' 'BackgroundColor'}, ...
    [state(strcmp('LTUH',handles.sectorSel)+[1 1 1]) cols(:,bAct+1)]);


% ------------------------------------------------------------------------
function handles = noHeaterControl(hObject, handles, val)

handles=gui_checkBoxControl(hObject,handles,'noHeater',val,strcmp(handles.sectorSel,'IN20'));


% ------------------------------------------------------------------------
function handles = measureQuadSet(hObject, handles)

emittance_const;  % STDOUT

if ismember(handles.sectorSel,{'IN20' 'LI21' 'LI28'})
    lcaPut('IOC:BSY0:MP01:BYKIKCTL',0);
end
pv=handles.measureQuadName;
val=handles.measureQuadValList(handles.dataDevice.iVal);
set(handles.measureQuadSet_btn,'String','Perturb');
gui_statusDisp(handles,lprintf(STDOUT,['Setting quad ' pv ' ...']));
guidata(hObject,handles);
valAct=control_magnetSet(pv,val);
if abs(valAct-val) > .1, pause(1);end
gui_statusDisp(handles,['Setting quad ' pv ' done']);
handles=guidata(hObject);
set(handles.measureQuadSet_btn,'String','Set Quad');
handles=measureQuadGet(hObject,handles);


% ------------------------------------------------------------------------
function handles = measureQuadGet(hObject, handles)

val=control_magnetGet(handles.measureQuadName);
set(handles.measureQuadVal_txt,'String',sprintf('%5.2f kG',val));
k1=model_k1Get(val,handles.lEff,handles.en);
elemType='qu';if strncmp(handles.measureQuadName,'SOLN',4), elemType='so';end
measureQuadRElem=model_rMatElement(elemType,handles.lEff,k1);
if strcmp(model_init,'MATLAB')
    [~,~,~,~,bp]=model_init;
    rQES=model_rMatGet(handles.measureQuadName,handles.devRef,...
        {['BEAMPATH=',bp],'POS=END'});
else
    rQES=handles.rQES0;
end
handles.rQBS=rQES*measureQuadRElem;
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = measureQuadReset(hObject, handles)

pv=handles.measureQuadName;
val=handles.measureQuadOrigVal;
set(handles.measureQuadReset_btn,'String','Perturb');
gui_statusDisp(handles,['Setting quad ' pv ' ...']);
val=control_magnetSet(pv,val);
gui_statusDisp(handles,['Setting quad ' pv ' done']);
set(handles.measureQuadReset_btn,'String','Reset Quad');
set(handles.measureQuadVal_txt,'String',sprintf('%5.2f kG',val));
if ismember(handles.accelerator,'LCLS')
    lcaPut('IOC:BSY0:MP01:BYKIKCTL',handles.bykik);
end


% ------------------------------------------------------------------------
function handles = measureProfSet(hObject, handles, val)

if strcmp(handles.measureType,'multi') || strcmp(handles.measureDevType,'wire'), return, end
if strcmp(handles.measureDevName,'YAGS:LTUH:743'), return, end
gui_statusDisp(handles,['Moving screen ' handles.measureDevName{:} ' ...']);
try
	profmon_activate(handles.measureDevName,val,1);
	gui_statusDisp(handles,['Moving screen ' handles.measureDevName{:} ' done']);
catch
	gui_statusDisp(handles,['Cannot move screen ' handles.measureDevName{:} ' done']);
end


% ------------------------------------------------------------------------
function opts = profmonOpts(hObject, handles, opts)

opts.nSlice=handles.dataSlice.nVal-1;
opts.sliceDir=char(241-handles.processSelectPlane);
opts.sliceWin=handles.processSliceWin;
opts.cut=handles.profmonCut;
opts.median=handles.profmonMedian;


% ------------------------------------------------------------------------
function handles = wireStatusControl(hObject, handles)

if strcmp(handles.measureDevType,'prof'), return, end
if isempty(handles.measureDevName), return, end
pName={'X' 'Y' 'U'};
if ~strcmp(handles.sectorSel,'UND1')
    pv=strcat(handles.devRef,':USE',pName','WIRE');
    stat=lcaGetSmart(pv,0,'double');stat(isnan(stat))=0;
    use=logical(stat);
    set(handles.wireStatus_txt,'Visible','on','String',['Current Wire ' pName{use}]);
else
%    pv=[name ':BFW:actC'];
    set(handles.wireStatus_txt,'Visible','on','String',['Current Wire ' '?']);
end


% ------------------------------------------------------------------------
function handles = dataCurrentDeviceControl(hObject, handles, iVal, nVal)

switch handles.measureType
    case 'multi'
        str=handles.measureDevName;
    case 'scan'
        str=cellstr(num2str(handles.measureQuadValList(:),'%6.2f kG'));
end
handles=gui_sliderControl(hObject,handles,'dataDevice',iVal,nVal,1,1,str);


% ------------------------------------------------------------------------
function handles = measureCurrentGet(hObject, handles, state)

emittance_const; % Application specific include file.

% Specific message for issue doing Get Data from Fast Wire Scanners through
% wirescan app.
FWS_ALL3PLANESWARNING_MSG = ...   
    ['Note that for fast wire scanners, all planes must have ' ...
     'same selection acquired in the remote app in order ' ...
     'for Emittance to successfully Get Data.'];

iVal=handles.dataDevice.iVal;
devName=handles.measureDevName{min(iVal,end)};
if strcmp(handles.accelerator,'NLCTA')
    profName=model_nameConvert(devName,'MAD');
    camName=strrep(profName,'P81','CAM');
    camPV=model_nameConvert(camName(1:end-1),'EPICS');
end
if strcmp(handles.measureType,'scan')
    if strcmp(state,'remote')
        handles=measureQuadSet(hObject,handles);
        measureProfSet(hObject,handles,1);
    else
        handles=measureQuadGet(hObject,handles);
    end
end
guidata(hObject,handles);
switch handles.measureDevType
    case 'wire'
        plane=handles.processSelectPlane;
%        if strncmp(devName,'WIRE:LTU1:7',11) || ...
%           strncmp(devName,'WIRE:LTU0:122',13) % 23/8/16 Added WSVM2
        if isFWS(devName) && ~strcmp(handles.measureType,'scan')
            plane='xyu'; % Quad scan settings for different planes not typ. the same
        end
        try
            if strcmp(state,'remote')
                data=wirescan_gui('appRemote',0,devName,plane);
            else
                data=wirescan_gui('appQuery',0,devName,plane);
            end
        catch ex
            % App threw exception. 
            % If the app has a "acquireStart" button and it shows state as
            % START, then assume the app has recovered from last data 
            % acquisition error and returned to the event loop, so it's
            % safe to try acquisition again. Otherwise, give up.
            %
            if ~gui_acquireStatusGet(hObject,handles)
                msgtext=[ EM_SCANFAILED_MSG, ...
                    ' Caused by: ', ex.message, ...
                    ' And can not get status. Giving up. ' ];
                warning('EM:SCANFAILED', msgtext); %#ok<*SPWRN>
                data.status=0;
            else
                msgtext=[ EM_SCANFAILED_MSG, ...
                    ' Caused by: ', ex.message, ' Retrying...' ];
                warning('EM:SCANFAILED', msgtext); %#ok<*SPWRN>
                % Try acquisistion again.
                if strcmp(state,'remote')
                    data=wirescan_gui('appRemote',0,devName,plane);
                else
                    data=wirescan_gui('appQuery',0,devName,plane);
                end
            end
        end
        
        % Update GUI.
        handles=guidata(hObject);
        
        % Check data fields match. That is, check the fields of the data
        % structure returned by the app for this suppplementary 'Get Data'
        % operatin match the fields of the structure from the originally
        % acquired data. If they don't match we can't sensibly simply
        % update the data structure.
        %
        if isfield(handles.data,'beam') && isfield(data,'beam') && ...
                ~isequal(fieldnames(handles.data.beam),fieldnames(data.beam))
            data.status=0;
            errtxt = sprintf(EM_UNEXPECTEDDATASTRUCT_MSG, ...
                handles.measureDevType);
            % If the field mismatch error occurred in the context of a 
            % fast wire scan, append a possible explanation to the 
            % error message.
            if isFWS(devName)
                errtxt = [ errtxt '. ' FWS_ALL3PLANESWARNING_MSG ];
            end
            gui_statusDisp([],...
                lprintf(STDERR,'Dissimilar beam structure occured.'));
            disp(fieldnames(handles.data.beam));
            disp(fieldnames(data.beam));
            lprintf(STDERR, errtxt);
            error('EM:UNEXPECTEDDATASTRUCT_MSG', errtxt);
        end
        handles.data.status(iVal)=data.status;
        if data.status
            handles.data.ts=data.ts;
            handles.data.beam(iVal,:,handles.dataSlice.iVal)=data.beam;
            handles.data.beamList(iVal,:,:,handles.dataSlice.iVal)=data.beam;
            if isfield(data,'wireSize')
                handles.data.res(iVal)=data.wireSize.(handles.processSelectPlane)/4;
            end
            if isfield(data.beam,'statsStd')
                data.beamStd=data.beam;
                [data.beamStd.stats]=deal(data.beamStd.statsStd);
                handles.data.beamStd(iVal,:,handles.dataSlice.iVal)=data.beamStd;
            end
        end
    case 'prof'
        opts.insScreen=strcmp(handles.measureType,'multi');
        opts.nBG=handles.processNumBG;
        opts.bufd=1;opts.axes=handles.plotProf_ax;
        opts=profmonOpts(hObject,handles,opts);
%        opts.nSlice=handles.dataSlice.nVal-1;
%        opts.sliceDir=char(241-handles.processSelectPlane);
%        opts.sliceWin=handles.processSliceWin;
%        opts.cut=handles.profmonCut;opts.median=handles.profmonMedian;
        if strcmp(handles.accelerator,'NLCTA')
            dataList=profmon_measure(camPV,handles.processSampleNum,opts);
        else
            dataList=profmon_measure(devName,handles.processSampleNum,opts);
        end
        handles=guidata(hObject);
        data.beamList=permute(cat(3,dataList.beam),[3 2 1]);
        [data.beam,data.beamStd]=beamAnalysis_beamAverage(data.beamList);
        data.status=1;
        data.ts=dataList(1).ts;
        handles.data.status(iVal)=data.status;
        handles.data.ts=data.ts;
        handles.data.dataList(iVal,:)=dataList;
        if data.status
            handles.data.beam(iVal,:,:)=data.beam;
            handles.data.beamStd(iVal,:,:)=data.beamStd;
            handles.data.beamList(iVal,:,:,1:size(data.beamList,3))=data.beamList;
        end
end
guidata(hObject,handles);charge=zeros(1,5);
if ~ismember(handles.accelerator,{'NLCTA' 'XTA'})
    bpmPV='BPMS:IN20:221:TMIT';
    if strcmp(handles.accelerator,'FACET'), bpmPV='BPMS:IN10:221:TMIT';end
    if strcmp(handles.accelerator,'ASTA'), bpmPV='TORO:AS01:100:RAW:CHRG';end
    for j=1:5
        charge(j)=lcaGetSmart(bpmPV)*1.6021e-10; %nC
        pause(.1);
    end
end
handles=guidata(hObject);
handles.data.chargeList(iVal,:)=charge;
handles.data.charge=mean(handles.data.chargeList(:));
handles.data.chargeStd=std(handles.data.chargeList(:));
if strcmp(handles.measureType,'scan')
    rMat=handles.rQBS*inv(handles.rQBS0);
else
    [rMat,posRef]=model_rMatGet(handles.devRef,devName);
    pos=model_rMatGet(devName,[],[],'Z');
    handles.data.posVal(iVal)=pos-posRef;
end
handles.data.rMatrix{iVal}=rMat;
handles.data.twiss0=handles.twiss0;
handles.data.energy=model_rMatGet(handles.devRef,[],[],'EN');
handles.process.done=0;
wireStatusControl(hObject,handles);
handles=processUpdate(hObject,handles);

function [isfastwirescanner] = isFWS(devName)
% isFWS returns true if the given device name is of a fast wire scanner.
% TODO: Replace by call to names, to check via directory service.
%
isfastwirescanner = ismember(devName,...
        { ... % GUN-L3
          'WIRE:IN20:561' 'WIRE:IN20:611' ...
          'WIRE:LI21:285' 'WIRE:LI21:293' ...
          'WIRE:LI21:301' ... 
          'WIRE:LI27:644' 'WIRE:LI28:144' 'WIRE:LI28:444' ...
          'WIRE:LI28:744' ...
          ... % LTU
          'WIRE:LTUH:715' 'WIRE:LTUH:735' 'WIRE:LTUH:755' ...
          'WIRE:LTUH:775' 'WIRE:LTUH:777' 'WIRE:LTU0:122' ...
          'WIRE:LTUS:715' 'WIRE:LTUS:735' 'WIRE:LTUS:755' ...
          'WIRE:LTUS:785' ...
        });  
    
% ------------------------------------------------------------------------
function handles = acquireStart(hObject, handles)

% Set running or return if already running.
if gui_acquireStatusSet(hObject,handles,1);return, end
[handles,cancd]=acquireReset(hObject,handles);
if cancd, gui_acquireStatusSet(hObject,handles,0);return, end
handles=measureQuadAutoValControl(hObject,handles,[],[],[]);
handles=acquireReset(hObject,handles); % To update new quad vals.

% Do device specific machine setup.
pvList={};

% Insert TD11 if injector quad scan.
if strcmp(handles.sectorSel,'IN20') && strcmp(handles.measureType,'scan')
    pvList=[pvList;{'DUMP:LI21:305:TD11_PNEU'}];
end

% Block laser heater as necessary.
if handles.noHeater && strcmp(handles.sectorSel,'IN20') && strcmp(handles.measureDevType,'prof')
    pvList=[pvList;{'IOC:BSY0:MP01:LSHUTCTL'}];
    disp('Closing heater shutter for emittance scan, per user preference.');
end

% Disable selected devices.
if ~isempty(pvList)
    gui_statusDisp(handles,'Disable selected devices');
    pvState=lcaGetSmart(pvList,0,'double');
    lcaPutSmart(pvList,0);
end

iVal=handles.dataDevice.iVal;
devName=handles.measureDevName{min(iVal,end)};
measDev=model_nameConvert(devName,'MAD');

otr2_in=lcaGetSmart('OTRS:IN20:571:PNEUMATIC',0,'double'); %OTR2 inserted
if strcmp(measDev,'WS12') && strcmpi(otr2_in,'IN')
    btn=questdlg({'WS12 selected but OTR2 is IN' 'Remove OTR2?'},'Remove OTR2?','Yes','No','Yes');
    if strcmp(btn,'Yes')
        lcaPutSmart('OTRS:IN20:571:PNEUMATIC',0);
    end
end
    
if strcmp(handles.measureType,'scan')
    handles.bykik=0;
    if ismember(handles.accelerator,'LCLS')
        handles.bykik=lcaGet('IOC:BSY0:MP01:BYKIKCTL',0,'double');
    end
    val=control_magnetGet(handles.measureQuadName,'BDES');
    if val ~= handles.measureQuadOrigVal
        str=sprintf('Current quad val %5.2f differs from reset val %5.2f!\nKeep reset value or update with current val?',val,handles.measureQuadOrigVal);
        btn=questdlg(str,'Magnet Value Change','Keep','Update','Update');
        if strcmp(btn,'Update')
            handles=measureQuadControl(hObject,handles,[]);
        end
    end
end

if strcmp(handles.measureDevType,'wire')
    set(handles.processSelectPlaneX_rbn,'Enable','off');
    set(handles.processSelectPlaneY_rbn,'Enable','off');
    set(handles.processSelectPlaneU_rbn,'Enable','off');
end

for j=1:handles.dataDevice.nVal
    handles=dataCurrentDeviceControl(hObject,handles,j,[]);
    handles=measureCurrentGet(hObject,handles,'remote');
    if ~gui_acquireStatusGet(hObject,handles), break, end
end

if strcmp(handles.measureType,'scan')
    measureQuadReset(hObject,handles);
    measureProfSet(hObject,handles,handles.measureProfOrig);
end

if strcmp(handles.measureDevType,'wire')
    set(handles.processSelectPlaneX_rbn,'Enable','on');
    set(handles.processSelectPlaneY_rbn,'Enable','on');
    set(handles.processSelectPlaneU_rbn,'Enable','on');
end

% Restore selected devices.
if ~isempty(pvList)
    gui_statusDisp(handles,'Restoring devices to pre-scan status');
    lcaPutSmart(pvList,pvState);
end

uploadPVs(hObject,handles,1:2);
gui_acquireStatusSet(hObject,handles,0);
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = processSlice(hObject, handles)

if handles.dataSlice.nVal == 1 && all(gcbo ~= handles.dataImgProc_btn), return, end
data=handles.data;
if ~isfield(data,'dataList'), return, end
if isfield(data,'beam')
    data=rmfield(data,'beam');
    data=rmfield(data,'beamStd');
    data=rmfield(data,'beamList');
end
handles.data=data;
for iVal=1:handles.dataDevice.nVal
    if ~data.status(iVal), continue, end
    dataList=data.dataList(iVal,:);
    opts=profmonOpts(hObject,handles);
%    opts.nSlice=handles.dataSlice.nVal-1;
%    opts.sliceDir=char(241-handles.processSelectPlane);
%    opts.sliceWin=handles.processSliceWin;
%    opts.doPlot=1;
%    opts.cut=handles.profmonCut;
%    opts.median=handles.profmonMedian;
    for j=1:length(dataList)
        data.beamList(j,:,:)=profmon_process(dataList(j),opts)';
    end
    [data.beam,data.beamStd]=beamAnalysis_beamAverage(data.beamList);
    handles.data.beam(iVal,:,:)=data.beam;
    handles.data.beamStd(iVal,:,:)=data.beamStd;
    handles.data.beamList(iVal,:,:,1:size(data.beamList,3))=data.beamList;
end
handles=processUpdate(hObject,handles);


% ------------------------------------------------------------------------
function handles = processSlicesNumControl(hObject, handles, val, val2)

handles=gui_editControl(hObject,handles,'processSlicesNum',val);
handles=gui_editControl(hObject,handles,'processSliceWin',val2,1,handles.processSlicesNum);

handles=dataCurrentSliceControl(hObject,handles,1,handles.processSlicesNum+1);
guidata(hObject,handles);
handles.process.done=0;
handles=processSlice(hObject,handles);


% ------------------------------------------------------------------------
function handles = dataCurrentSliceControl(hObject, handles, iVal, nVal)

handles=gui_sliderControl(hObject,handles,'dataSlice',iVal,nVal);
iVal=handles.dataSlice.iVal;
str=num2str(iVal-1);if iVal == 1, str='Projected';end
set(handles.dataSlice_txt,'String',str);


% ------------------------------------------------------------------------
function handles = processSampleNumControl(hObject, handles, val)

vis=strcmp(handles.measureDevType,'prof');
handles=gui_editControl(hObject,handles,'processSampleNum',val,1,vis,[0 1]);
val=handles.processSampleNum;
if ~vis, val=1;end
handles=dataCurrentSampleControl(hObject,handles,1,val);
handles=acquireReset(hObject,handles);


% ------------------------------------------------------------------------
function handles = dataCurrentSampleControl(hObject, handles, iVal, nVal)

handles=gui_sliderControl(hObject,handles,'dataSample',iVal,nVal);


% ------------------------------------------------------------------------
function handles = processNumBGControl(hObject, handles, val)

handles=gui_editControl(hObject,handles,'processNumBG',val,1,strcmp(handles.measureDevType,'prof'),[0 0]);


% ------------------------------------------------------------------------
function handles = dataMethodControl(hObject, handles, iVal, nVal)

if isempty(iVal)
    iVal=handles.processSelectMethod;
end
handles.processSelectMethod=iVal;

handles=gui_sliderControl(hObject,handles,'dataMethod',iVal,nVal);
processUpdate(hObject,handles);


% ------------------------------------------------------------------------
function handles = processPlaneControl(hObject, handles, tag)

if isempty(tag), tag='x';end
handles=gui_radioBtnControl(hObject,handles,'processSelectPlane',tag);
%measureQuadAutoValControl(handles.measureQuadAutoVal_box,handles,...
%    get(handles.measureQuadAutoVal_box,'Value'),[],[]); %TEST
processUpdate(hObject,handles);


% ------------------------------------------------------------------------
function handles = processAverageControl(hObject, handles, val)

handles=gui_checkBoxControl(hObject,handles,'processAverage',val);
handles.process.done=0;
processUpdate(hObject,handles);


% ------------------------------------------------------------------------
function handles = processResolutionControl(hObject, handles, val)

handles=gui_checkBoxControl(hObject,handles,'processResolution',val);
handles.process.done=0;
processUpdate(hObject,handles);


% ------------------------------------------------------------------------
function handles = profmonCutControl(hObject, handles, val)

handles=gui_editControl(hObject,handles,'profmonCut',val,1,1,[2 0 1]);


% ------------------------------------------------------------------------
function handles = profmonMedianControl(hObject, handles, val)

handles=gui_checkBoxControl(hObject,handles,'profmonMedian',val);


% ------------------------------------------------------------------------
function plotProfile(hObject, handles, plane)

iVal=handles.dataDevice.iVal;
set(handles.dataDeviceUse_box,'Value',handles.data.use(iVal));

if get(handles.tomo_btn,'Value')
    plot_tomo(hObject, handles);
    return
end

data=handles.data;
if ~data.status(handles.dataDevice.iVal)
    cla(handles.plotProf_ax);
    return
end

iDev=handles.dataDevice.iVal;
if handles.process.showImg && isfield(data,'dataList')
    imgData=data.dataList(iDev,handles.dataSample.iVal);
    profmon_imgPlot(imgData,'axes',handles.plotProf_ax,'bits',8);
    return
end

iMethod=handles.dataMethod.iVal;iSlice=handles.dataSlice.iVal;
beam=data.beam(iDev,iMethod,iSlice);
%if ~handles.processAverage && isfield(data,'beamList')
if isfield(data,'beamList')
    beam=data.beamList(iDev,handles.dataSample.iVal,iMethod,iSlice);
end
set(handles.dataMethod_txt,'String',beam.method);
devName=handles.measureDevName{min(iDev,end)};
opts.axes=handles.plotProf_ax;opts.xlab=[devName ' Position  (\mum)'];
str='';if strcmp(data.type,'scan'), str=sprintf(' at %5.2f kG',data.quadVal(iDev));end
opts.title=['Profile ' datestr(data.ts) ' ' data.beam(1,iMethod).method str];
if nargin < 3, plane=handles.processSelectPlane;end
beamAnalysis_profilePlot(beam,plane,opts);


% ------------------------------------------------------------------------
function handles = processDisplayNormalizeControl(hObject, handles, val)

handles=gui_checkBoxControl(hObject,handles,'processDisplayNormalize',val);

if get(handles.tomo_btn,'Value')
    plot_tomo(hObject, handles);
    return
end
processUpdate(hObject,handles);


% ------------------------------------------------------------------------
function handles = processDisplayPhaseSpaceControl(hObject, handles, val)

handles=gui_checkBoxControl(hObject,handles,'processDisplayPhaseSpace',val);
state={'off' 'on'};val=handles.processDisplayPhaseSpace;
set(handles.plotEmit_pan,'Visible',state{2-val});
set(handles.plotPhaseSpace_pan,'Visible',state{1+val});


% ------------------------------------------------------------------------
function handles = processInit(hObject, handles)

handles.process.done=0;
handles.process.saved=0;
handles.process.saveImg=0;
handles.process.showImg=0;
handles.process.displaySliceEmit=0;
handles.process.displayExport=0;
handles=processPlaneControl(hObject,handles,[]);
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = processUpdate(hObject, handles)

guidata(hObject,handles);
set(handles.output,'Name',['Emittance Application - [' handles.fileName ']']);
processPlot(hObject,handles);
data=handles.data;
if any(~data.status & data.use), return, end
%if ~any(data.status), return, end
%if sum(data.status) < 3, return, end
use=data.status & data.use;

rMat=cat(3,data.rMatrix{use});
val=reshape(rMat(1,2,:),[],1);
if strcmp(data.type,'scan')
    val=data.quadVal(use);
    opts.xlab=[data.quadName ':BDES  (kG)'];
elseif isfield(data,'posVal')
    val=data.posVal(use);
end
if isfield(data,'res') && handles.processResolution, opts.res=data.res;end
if ~handles.processAverage && isfield(data,'beamList')
    val=reshape(repmat(val(:)',size(data.beamList,2),1),[],1);
    rMat=reshape(repmat(rMat,1,size(data.beamList,2)),6,6,[]);
end

opts.doPlot=0;
if ~handles.process.done
    if isfield(data,'twiss')
        data.twiss(:,:,2:end)=[];
        data.twissstd(:,:,2:end)=[];
    end
    if isfield(data,'orbit')
        data.orbit(:,:,2:end)=[];
        data.orbitstd(:,:,2:end)=[];
    end
    for iSlice=1:handles.dataSlice.nVal
        for iMethod=1:size(data.beam,2)
            for iPlane=1:2
                beam=data.beam(use,iMethod,iSlice);
                beamStd=[];
                if ~handles.processAverage && isfield(data,'beamList')
                    beam=data.beamList(use,:,iMethod,iSlice)';
                    beam=beam(:);
                end
                if handles.processAverage && isfield(data,'beamStd')
                    beamStd=data.beamStd(use,iMethod,iSlice);
                end
                [data.twiss(:,iPlane,iMethod,iSlice), ...
                 data.twissstd(:,iPlane,iMethod,iSlice), ...
                 data.orbit(:,iPlane,iMethod,iSlice), ...
                 data.orbitstd(:,iPlane,iMethod,iSlice)]=emittance_process( ...
                    val,rMat,beam,beamStd,iPlane,1e-6,data.energy,data.twiss0,{},opts);
            end
        end
    end
    data.twissPV=emittance_convert2PV(handles.devRef,data.twiss,data.ts);
    handles.process.done=1;
end
handles.data=data;
guidata(hObject,handles);

iPlane=1;if strcmpi(handles.processSelectPlane,'y'), iPlane=2;end
if strcmpi(handles.processSelectPlane,'u'), iPlane=3;end
iSlice=handles.dataSlice.iVal;
iMethod=handles.dataMethod.iVal;
opts.axes=[handles.plotEmit_ax handles.plotPhaseSpace_ax];
opts.title={['Emittance Scan on ' sprintf('%s ',data.name{ceil(end/2)})] datestr(data.ts)};
opts.title{2}=[opts.title{2} ' ' data.beam(1,iMethod).method];
opts.normPS=handles.processDisplayNormalize;
opts.doPlot=1;
if handles.process.displayExport
    handles.exportFig=figure;
    opts.figure=[];opts.axes={1 2};
    guidata(hObject,handles);
    if isfield(data.beam,'profx') && isfield(data.beam,'profy')
        opts.axes={2 2 1;2 2 2};
        if handles.dataSlice.nVal < 2
            iPlane=[1 2];
        end
    end
end
strTitle=opts.title;
if iSlice > 1
    opts.title{1}=[sprintf('Slice #%d ',iSlice-1) opts.title{1}];
end

beam=data.beam(use,iMethod,iSlice);
beamStd=[];
if ~handles.processAverage && isfield(data,'beamList')
    beam=data.beamList(use,:,iMethod,iSlice)';
    beam=beam(:);
end
if handles.processAverage && isfield(data,'beamStd')
    beamStd=data.beamStd(use,iMethod,iSlice);
end

%{
% first data
size062=[182.4 139.9 105.5 89.5 103.3 142.9 197];
size102 =[226.4 168.3 118.7 93.7 114.4 169.9 240.2];
size122=[255.8 186.8 126.1 93 118.4 185 266.7];

% second data
size06=[138.3 109 85.8 75.4 83.6 106.6 137.6]; % rms beam size at YAG02, units in um 
size10 =[199.5 145.7 99.5 78.6 101.9 151.1 209.2]; %rms size at YAG02, units in um
size12=[229.8 163.7 105.7 80.3 114.3 177.4 249.1]; % rms size at YAG02, units in um

size065=[149.9 116.8 90.1 78.7 87.5 115.4 152.8]; % rms beam size at YAG02, units in um 
size105 =[212.7 157.2 108.4 81.6 99.5 148.9 209.8]; %rms size at YAG02, units in um
size125=[245.2 177.8 117 82.6 107.7 170 243.8]; % rms size at YAG02, units in um

sizeList=size122;


stats=vertcat(beam.stats);
statsStd=vertcat(beamStd.stats);
stats(:,3:4)=repmat(sizeList',1,2);
statsC=num2cell(stats,2);
statsStd(:,3:4)=5;
statsStdC=num2cell(statsStd,2);
[beam.stats]=deal(statsC{:});
[beamStd.stats]=deal(statsStdC{:});
%}


for j=iPlane
    if numel(iPlane) == 2 && j == 2
        opts.axes={2 2 3;2 2 4};
        opts.title='';
    end
    tw=emittance_process(val,rMat,beam,beamStd,j,1e-6,data.energy,data.twiss0,{data.charge data.chargeStd},opts);
    if handles.process.displayExport && length(iPlane) == 1
        set(findobj(handles.exportFig,'Tag','','Type','axes'),'PlotBoxAspectRatio',[1 1 1]);
    end
end
%disp(tw(1)*1e6);

ax=handles.plotSliceEmit_ax;
if handles.dataSlice.nVal == 1, return, end
if handles.process.displayExport
    fig=figure;ax=subplot(1,1,1,'Box','on');
    handles.exportFig(2)=fig;
%    ax=subplot(2,2,3:4,'Box','on');
end

iPlane=1;if strcmpi(handles.processSelectPlane,'y'), iPlane=2;end
beam=data.beam(:,iMethod,:);
stats=reshape(vertcat(data.beam(:,6,:).stats),size(beam,1),[],6);
tmit=mean(stats(:,:,6));
tmitStd=std(stats(:,:,6),1);
stats=reshape(vertcat(beam.stats),size(beam,1),[],6);
tmitStd=tmitStd/max(tmit(2:end))*data.twiss(1,iPlane,iMethod,round(end/2))*1e6*3;
tmit=tmit/max(tmit(2:end))*data.twiss(1,iPlane,iMethod,round(end/2))*1e6*3;
pos=mean(stats(:,2:end,3-iPlane))*1e-3; % This is mean screen position (mm) for each slice. Might be non-linear at fringes.
%posStd=std(stats(:,:,3-iPlane),1);
x=1:size(data.twiss,4)-1;
%x=pos(2:end);
[a,sl_m,sl_s]=util_moments(x,tmit(2:end)); % Find center slice and bunch length rms in slice numbers
use=abs(x-sl_m) < sl_s;
par=polyfit(x(use),pos(use),1);
pos=polyval(par,x)-polyval(par,sl_m); % Linear position coordinate (mm)

% Pick x coordinate
if 1
    xLab='Slice Number';
else
    xLab='Time  (ps)';
    x=pos/.587/.3; % Time coordinate
end

errorbar(x,squeeze(data.twiss(1,iPlane,iMethod,2:end))*1e6,squeeze(data.twissstd(1,iPlane,iMethod,2:end))*1e6,'.-','Parent',ax);
hold(ax,'on');
errorbar(x,tmit(2:end),tmitStd(2:end),'r.-','Parent',ax);
errorbar(x,squeeze(data.twiss(4,iPlane,iMethod,2:end)),squeeze(data.twissstd(4,iPlane,iMethod,2:end)),'g.-','Parent',ax);
errorbar(x,(squeeze(data.orbit(1,iPlane,iMethod,2:end))-data.orbit(1,iPlane,iMethod,1))*1e3,squeeze(data.orbitstd(1,iPlane,iMethod,2:end)*1e3),'y.-','Parent',ax);
errorbar([0 1],[data.twiss(1,iPlane,iMethod,1)*1e6 NaN],[data.twissstd(1,iPlane,iMethod,1)*1e6 NaN],'kx','Parent',ax);
hold(ax,'off');
%set(ax,'YLim',[0 Inf]);
xlabel(ax,xLab);
ylabel(ax,'Norm. Emittance  ( \mum)');
opts.title={['Slice ' strTitle{1}] strTitle{2}};
title(ax,opts.title);
legend(ax,'Emittance','Current','BMAG','Position');legend(ax,'boxoff');
%legend(ax,{'Emittance' 'Current'},'Location','North');legend(ax,'boxoff');

if handles.process.displayExport
    util_appFonts(fig,'fontName','Times','lineWidth',2,'fontSize',14);
end


% ------------------------------------------------------------------------
function uploadPVs(hObject, handles, val)

emittance_const;

data=handles.data;
if ~all(data.status), return, end
if handles.dataSlice.nVal > 1, return, end

plane={'X' 'Y'};
iMethod=handles.dataMethod.iVal;

if strcmp(handles.accelerator,'NLCTA')
    profName=model_nameConvert(handles.devRef,'MAD');
    camName=strrep(profName,'PROF','CAM');
    handles.devRef=model_nameConvert(camName,'EPICS');
end

% Save fit method and twiss, if there is data. Warn if there was no data,
% judging by absence of fit method.
if ~isempty(data.beam(1,iMethod).method)
    lcaPut([handles.devRef,':FIT_METHOD'],data.beam(1,iMethod).method);
else
    lprintf(STDERR,'%s Suspect no measured data.',...
        EM_NOFITMETHODASSIGNED_MSG);
end
control_emitSet(handles.devRef,data.twiss(:,val,iMethod,1), ...
    data.twissstd(:,val,iMethod,1),plane(val));
lcaPut([handles.devRef,':EMIT_TIME'],datestr(data.ts));


% ------------------------------------------------------------------------
function processPlot(hObject, handles)

plotProfile(hObject,handles);
if ~all(handles.data.status)
    cla(handles.plotEmit_ax);
    cla(handles.plotPhaseSpace_ax);
    cla(handles.plotSliceEmit_ax);
end


% --- Executes on slider movement.
function dataDevice_sl_Callback(hObject, eventdata, handles)

handles=dataCurrentDeviceControl(hObject,handles,round(get(hObject,'Value')),[]);
plotProfile(hObject,handles);


% --- Executes on slider movement.
function dataSlice_sl_Callback(hObject, eventdata, handles)

handles=dataCurrentSliceControl(hObject,handles,round(get(hObject,'Value')),[]);
plotProfile(hObject,handles);
processUpdate(hObject,handles);


% --- Executes on button press in processDisplaySliceEmit_box.
function processDisplaySliceEmit_box_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
handles.process.displaySliceEmit=val;
guidata(hObject,handles);
state={'off' 'on'};
set(handles.plotProf_pan,'Visible',state{2-val});
set(handles.plotSliceEmit_pan,'Visible',state{1+val});
processUpdate(hObject,handles);


% --- Executes on slider movement.
function dataSample_sl_Callback(hObject, eventdata, handles)

handles=dataCurrentSampleControl(hObject,handles,round(get(hObject,'Value')),[]);
plotProfile(hObject,handles);


% -----------------------------------------------------------
function handles = dataExport(hObject, handles, val)

handles.process.displayExport=1;
handles=processUpdate(hObject,handles);
handles.process.displayExport=0;
guidata(hObject,handles);
util_appFonts(handles.exportFig,'fontName','Times','lineWidth',1,'fontSize',14);
if val
    data=handles.data;
    str='Emittance';if numel(handles.exportFig) == 2, str=['Slice ' str];end
    util_appPrintLog(handles.exportFig,str,data.name{ceil(end/2)},data.ts);
%    util_printLog(handles.exportFig);
    dataSave(hObject,handles,0);
end


% -----------------------------------------------------------
function handles = dataSave(hObject, handles, val)

data=handles.data;
if ~any(data.status), return, end
if isfield(data,'dataList')
    if handles.process.saveImg
        butList={'Proceed' 'Discard Images'};
        button=questdlg('Save data with images?','Save Images',butList{:},butList{2});
        if strcmp(button,butList{2}), data=rmfield(data,'dataList');end
    else
        data=rmfield(data,'dataList');
    end
end
if isfield(data,'res'), data=rmfield(data,'res');end
fileName=util_dataSave(data,['Emittance-' data.type],data.name{ceil(end/2)},data.ts,val);
if ~ischar(fileName), return, end
handles.fileName=fileName;
handles.process.saved=1;
set(handles.output,'Name',['Emittance Application - [' handles.fileName ']']);
guidata(hObject,handles);


% -----------------------------------------------------------
function handles = dataOpen(hObject, handles, val)

[data,fileName,pathName]=util_dataLoad('Open emittance measurement');
if ~ischar(fileName), return, end
handles.fileName=fileName;

% Check fields.
if ~isfield(data,'energy'), data.energy=.135;end
if ~isfield(data,'charge'), data.charge=NaN;data.chargeStd=NaN;end
if ~isfield(data,'use'), data.use=data.status*0+1;end

% Put data in storage.
handles.data=data;

% Initialize controls.
handles.measureType=data.type;
handles.measureDevName=data.name;
handles.devRef=handles.measureDevName{round(end/2)};
if numel(handles.measureDevName) == 5, handles.devRef=handles.measureDevName{2};end
if strcmp(handles.measureType,'scan')
    handles.measureQuadValList=data.quadVal;
    set(handles.dataDeviceLabel_txt,'String',handles.measureDevName);
else
    set(handles.dataDeviceLabel_txt,'String','multi');
end
handles=dataCurrentDeviceControl(hObject,handles,1,size(data.beam,1));
handles=processSlicesNumControl(hObject,handles,size(data.beam,3)-1,[]);
handles=dataCurrentSampleControl(hObject,handles,1,size(data.beamList,2));
handles.process.saved=1;

handles=processUpdate(hObject,handles);
guidata(hObject,handles);


% --- Executes on button press in dataSaveImg_box.
function dataSaveImg_box_Callback(hObject, eventdata, handles)

handles.process.saveImg=get(hObject,'Value');
guidata(hObject,handles);


% --- Executes on button press in uploadPVs_btn.
function uploadPVs_btn_Callback(hObject, eventdata, handles)

use=[0 0];tags='xy';
for j=1:2
    if isfield(handles.data.beam(1),['prof' tags(j)]), use(j)=1;end
end
%uploadPVs(hObject,handles,find(use));
uploadPVs(hObject,handles,1:2);


% --- Executes on button press in showImg_box.
function showImg_box_Callback(hObject, eventdata, handles)

handles.process.showImg=get(hObject,'Value');
guidata(hObject,handles);
plotProfile(hObject,handles);


% --- Executes on button press in dataDeviceUse_box.
function dataDeviceUse_box_Callback(hObject, eventdata, handles)

handles.data.use(handles.dataDevice.iVal)=get(hObject,'Value');
handles.process.done=0;
processUpdate(hObject,handles);


% --- Executes on button press in processDisplayPhaseSpace_box.
function processDisplayPhaseSpace_box_Callback(hObject, eventdata, handles)

processDisplayPhaseSpaceControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in processDisplayNormPS_box.
function processDisplayNormalize_box_Callback(hObject, eventdata, handles)

processDisplayNormalizeControl(hObject,handles,get(hObject,'Value'));


function processNumBG_txt_Callback(hObject, eventdata, handles)

processNumBGControl(hObject,handles,str2double(get(hObject,'String')));


% --- Executes on button press in dataSave_btn.
function dataSave_btn_Callback(hObject, eventdata, handles, val)

dataSave(hObject,handles,val);


% --- Executes on button press in dataOpen_btn.
function dataOpen_btn_Callback(hObject, eventdata, handles)

dataOpen(hObject,handles);


% --- Executes on button press in dataExport_btn.
function dataExport_btn_Callback(hObject, eventdata, handles, val)

dataExport(hObject,handles,val);


% --- Executes on button press in processSelectPlaneX_rbn.
function processSelectPlane_rbn_Callback(hObject, eventdata, handles, tag)

processPlaneControl(hObject,handles,tag);


function processSampleNum_txt_Callback(hObject, eventdata, handles)

processSampleNumControl(hObject,handles,str2double(get(hObject,'String')));


function processSlicesNum_txt_Callback(hObject, eventdata, handles)

processSlicesNumControl(hObject,handles,round(str2double(get(hObject,'String'))),[]);


function processSliceWin_txt_Callback(hObject, eventdata, handles)

processSlicesNumControl(hObject,handles,[],round(str2double(get(hObject,'String'))*10)/10);


% --- Executes on selection change in measureDevList.
function measureDevList_Callback(hObject, eventdata, handles)

measureDevListControl(hObject,handles,get(hObject,'Value'));


% --- Executes on selection change in measureQuad_btn.
function measureQuad_btn_Callback(hObject, eventdata, handles)

measureQuadControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in appSave_btn.
function appSave_btn_Callback(hObject, eventdata, handles)

gui_appSave(hObject,handles);


% --- Executes on button press in appLoad_btn.
function appLoad_btn_Callback(hObject, eventdata, handles)

gui_appLoad(hObject,handles);


function measureQuadValNum_txt_Callback(hObject, eventdata, handles)

measureQuadValNumControl(hObject,handles,round(str2double(get(hObject,'String'))));


function measureQuadRange_txt_Callback(hObject, eventdata, handles, tag)

measureQuadRangeControl(hObject,handles,tag,str2double(get(hObject,'String')));


% --- Executes on button press in measureQuadSet_btn.
function measureQuadSet_btn_Callback(hObject, eventdata, handles)

measureQuadSet(hObject,handles);


% --- Executes on button press in measureQuadReset_btn.
function measureQuadReset_btn_Callback(hObject, eventdata, handles)

measureQuadReset(hObject,handles);


% --- Executes on button press in measureCurrentGet_btn.
function measureCurrentGet_btn_Callback(hObject, eventdata, handles)

emittance_const;  % Emittance app specific constants.

try
    measureCurrentGet(hObject,handles,'query');
catch ex
    % If exception was not generated by EMittance app itself, then 
    % treat as internal error so print stacktrace to stderr for debugging.
    if ~strncmp(ex.identifier,EM_EXID_PREFIX,3)  
        lprintf(STDERR, '%s', ex.getReport());
    end
    % Log and dialog the error in context of what we were trying to do.
    txt=sprintf('%s %s',EM_GETDATAERR_MSG, ex.message);
    uiwait(errordlg(lprintf(STDERR,txt)));
end
    


% --- Executes on slider movement.
function dataMethod_sl_Callback(hObject, eventdata, handles)

dataMethodControl(hObject,handles,round(get(hObject,'Value')),[]);


% --- Executes on button press in sectorSel_btn.
function sectorSel_btn_Callback(hObject, eventdata, handles, tag)

sectorControl(hObject,handles,tag);


% --- Executes on selection change in measureType_pmu.
function measureType_pmu_Callback(hObject, eventdata, handles)

emittance_const;  % Emittance app specific constants.

try
    measureTypeInit(hObject,handles,get(hObject,'Value'));
catch ex
    % If exception was not generated by EMittance app itself, then 
    % treat as internal error so print stacktrace to stderr for debugging.
    if ~strncmp(ex.identifier,EM_EXID_PREFIX,3)  
        lprintf(STDERR, '%s', ex.getReport());
    end
    % Log and dialog the error in context of what we were trying to do.
    txt=sprintf('Error setting measurement type. %s', ex.message);
    uiwait(errordlg(lprintf(STDERR,txt)));
end

% --- Executes on button press in acquireStart_btn.
function acquireStart_btn_Callback(hObject, eventdata, handles)

emittance_const;  % Emittance app specific constants.

try
    set(hObject,'Value',~get(hObject,'Value'));
    acquireStart(hObject,handles);
catch ex
    % If exception was not generated by EMittance app itself, then 
    % treat as internal error so print stacktrace to stderr for debugging.
    if ~strncmp(ex.identifier,EM_EXID_PREFIX,3)  
        lprintf(STDERR, '%s', ex.getReport());
    end
    % Log and dialog the error in context of what we were trying to do.
    txt=sprintf('Issue making emittance data acquisition. %s', ex.message);
    set(handles.processSelectPlaneX_rbn,'Enable','on');
    set(handles.processSelectPlaneY_rbn,'Enable','on');
    set(handles.processSelectPlaneU_rbn,'Enable','on');
    uiwait(errordlg(lprintf(STDERR,txt)));
end
    

% --- Executes on button press in acquireAbort_btn.
function acquireAbort_btn_Callback(hObject, eventdata, handles)

gui_acquireAbortAll;


% --- Executes on button press in processAverage_box.
function processAverage_box_Callback(hObject, eventdata, handles)

processAverageControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in processResolution_box.
function processResolution_box_Callback(hObject, eventdata, handles)

processResolutionControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in measureQuadAutoVal_box.
function measureQuadAutoVal_box_Callback(hObject, eventdata, handles)

measureQuadAutoValControl(hObject,handles,get(hObject,'Value'),[],[]);


% --- Executes on button press in measureQuadAutoValXY_box.
function measureQuadAutoValXY_box_Callback(hObject, eventdata, handles)

measureQuadAutoValControl(hObject,handles,[],get(hObject,'Value'),[]);


% --- Executes on button press in measureQuadAutoValSource_box.
function measureQuadAutoValSource_box_Callback(hObject, eventdata, handles)

measureQuadAutoValControl(hObject,handles,[],[],get(hObject,'Value'));


% --- Executes on button press in profOut_btn.
function profInOut_btn_Callback(hObject, eventdata, handles, val)

measureProfSet(hObject,handles,val);


% --- Executes on button press in edsysOff_btn.
function edsysOnOff_btn_Callback(hObject, eventdata, handles, val)
edsysControl(hObject,handles,val);


% --- Executes on button press in prof2log_btn.
function prof2log_btn_Callback(hObject, eventdata, handles)

allProf=0;
handles.process.showImg=0;
n=handles.dataDevice.nVal;
m{2}=ceil(sqrt(n));m{1}=ceil(n/m{2});
if ~allProf, m={1 1};
else h=figure;end
for j=1:n
    handles.dataDevice.iVal=j;
    if ~allProf, h=figure;end
    handles.plotProf_ax=subplot(m{:},min(prod([m{:}]),j),'Parent',h);
    plotProfile(hObject,handles,'xy');drawnow;
    if ~allProf || j == n
        util_appFonts(h,'fontName','Times','lineWidth',1,'fontSize',14);
        util_appPrintLog(h,'Emittance Profile',handles.data.name{min(j,end)},handles.data.ts);
        pause(1);
    end
end


% --- Executes on button press in tomo_btn.
function tomo_btn_Callback(hObject, eventdata, handles)

stat=get(hObject,'Value');
vis={'off' 'on'};
set([handles.tomoRun_btn handles.tomoMethod_btn handles.tomoPosRange_txt ...
    handles.tomoAngleRange_txt handles.tomoPoints_txt],'Visible',vis{stat+1});
if ~isfield(handles,'tomoPosRange')
    handles.tomoPosRange=5;handles.tomoAngleRange=5;handles.tomoPoints=200;
    set(handles.tomoPosRange_txt,'String',num2str(handles.tomoPosRange));
    set(handles.tomoAngleRange_txt,'String',num2str(handles.tomoAngleRange));
    set(handles.tomoPoints_txt,'String',num2str(handles.tomoPoints));
    guidata(hObject,handles);
end


% --- Executes on button press in tomoRun_btn.
function tomoRun_btn_Callback(hObject, eventdata, handles, type)

if ~isfield(handles,'tomo'), handles.tomo.type='ment';end
t=handles.tomo;
data=handles.data;
use=data.status & data.use;
tag=handles.processSelectPlane;tagN=tag-119;
iSlice=handles.dataSlice.iVal;
twiss=data.twiss(1:3,tagN,handles.dataMethod.iVal,iSlice);
sigma=model_twiss2Sigma(twiss,data.energy);t.sigma=sigma;
n=200;
t.ex_time=handles.tomoPosRange*sqrt(sigma(1));
t.ex_delta=handles.tomoAngleRange*sqrt(sigma(3));
t.timevec=t.ex_time*linspace(-1,1,n);
t.deltavec=t.ex_delta*linspace(-1,1,n)';
beam=data.beamList(use,:,handles.dataMethod.iVal,iSlice);
stats=vertcat(beam.stats);
t.timevec0=5*max(stats(:,2+tagN))*linspace(-1,1,100)*1e-6;
%t.timevec0=600*linspace(-1,1,100)*1e-6;
profs=zeros(numel(beam),length(t.timevec0));
for j=1:numel(beam)
    prof=beam(j).(['prof' tag]);j
    profs(j,:)=interp1((prof(1,:)-beam(j).stats(tagN))*1e-6,prof(2,:)-prof(3,1),t.timevec0,'linear',0);
    profs(j,:)=profs(j,:)/sum(profs(j,:))/diff(t.timevec0(1:2));
end
profs=mean(reshape(profs,size(beam,1),size(beam,2),[]),2);
t.profs0=max(0,reshape(profs,size(beam,1),[])');
m=cat(3,data.rMatrix{use});
t.m=m((1:2)+tagN*2-2,(1:2)+tagN*2-2,:);
m=t.m([2 1],:,:);
ax=handles.plotEmit_ax;
[t.recon0,d,d,t.B,t.xn,t.yn]=tomo_init(t.timevec,t.deltavec,t.profs0,...
                   t.timevec0,{m []},[],[],t.type,ax);

for j=1:size(beam,1)
%    t.profs(:,j)=tomo_getProj(t.xn,t.yn,t.recon0,t.m(:,:,j)*t.B,t.timevec0,1,t.deltavec);
    m=t.m(:,:,j)*t.B;m(2,:)=[0 1];
    phi=atan2(m(1,2),m(1,1));
    m(2,:)=[-sin(phi) cos(phi)]; % Keep rotation in y coordinate from normalized phasespace
    t.profs(:,j)=tomo_getProj(t.xn,t.yn,t.recon0,m,t.timevec0,1,t.yn);
    t.profs(:,j)=t.profs(:,j)*sum(t.profs0(:,j))/sum(t.profs(:,j));
end
handles.tomo=t;
handles=recon_tomo(hObject,handles);


% ------------------------------------------------------------------------
function handles = recon_tomo(hObject, handles)

if ~isfield(handles,'tomo'), return, end

t=handles.tomo;
t.ex_time=handles.tomoPosRange*sqrt(t.sigma(1));
t.ex_delta=handles.tomoAngleRange*sqrt(t.sigma(3));
t.timevec=t.ex_time*linspace(-1,1,handles.tomoPoints);
t.deltavec=t.ex_delta*linspace(-1,1,handles.tomoPoints)';
t.recon=tomo_transPhaseSpace(t.xn,t.yn,t.recon0,t.B,t.deltavec,t.timevec);
handles.tomo=t;

plot_tomo(hObject,handles);
guidata(hObject,handles);

global t0
t0=handles.tomo;


% --- Executes on selection change in tomoMethod_btn.
function tomoMethod_btn_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
typeList={'sart' 'cbrt' 'sart_sp' 'sart_spnew' 'ment'};
handles.tomo.type=typeList{val};
guidata(hObject,handles);


function tomoPosRange_txt_Callback(hObject, eventdata, handles)

handles.tomoPosRange=str2double(get(hObject,'String'));
guidata(hObject,handles);
recon_tomo(hObject,handles);


function tomoAngleRange_txt_Callback(hObject, eventdata, handles)

handles.tomoAngleRange=str2double(get(hObject,'String'));
guidata(hObject,handles);
recon_tomo(hObject,handles);


function tomoPoints_txt_Callback(hObject, eventdata, handles)

handles.tomoPoints=str2double(get(hObject,'String'));
guidata(hObject,handles);
recon_tomo(hObject,handles);


% ------------------------------------------------------------------------
function plot_tomo(hObject, handles)

if ~isfield(handles,'tomo'), return, end

ax=handles.plotProf_ax;
j=handles.dataDevice.iVal;
use=handles.data.use & handles.data.status;
t=handles.tomo;
if use(j)
    j=sum(use(1:j));
    plot(t.timevec0*1e6,t.profs0(:,j),t.timevec0*1e6,t.profs(:,j),'r--','Parent',ax);
else
    plot(t.timevec0,NaN,'Parent',ax);
end

hAx=util_plotInit('figure',9,'axes',{2 2});set(hAx(3),'Visible','off');
imagesc(t.xn,t.yn,t.recon0,'Parent',hAx(1));
xlabel(hAx(1),'x_N  ()');ylabel(hAx(1),'x''_N  ()');
imagesc(t.timevec*1e6,t.deltavec*1e6,t.recon,'Parent',hAx(2));
xlabel(hAx(2),'x  (\mum)');ylabel(hAx(2),'x''  (\murad)');
set(hAx(1:2),'YDir','normal');set(9,'Colormap',jet(256));

r=t.recon0;x=t.xn;y=t.yn;
p=r*diff(x(1:2))*diff(y(1:2));
[x2,y2]=meshgrid(x,y);
%[d,id]=sort(p(:),'descend'); % Integrate over decreasing charge density
[d,id]=sort(abs(x2(:))); % Integrate over x slit width
p2=p(id);pp=cumsum(p2);
sig=[x2(id).*x2(id) y2(id).*y2(id) x2(id).*y2(id)].*repmat(p2,1,3);
sig2=cumsum(sig)./repmat(pp,1,3);xx=sig2(:,1);yy=sig2(:,2);xy=sig2(:,3);
emit=real(sqrt(xx.*yy-xy.^2))*det(t.B)*1e6*handles.data.energy/.511e-3;
beta=t.B(1)^2*xx./emit*1e6*handles.data.energy/.511e-3;
alpha=-(t.B(1)*t.B(4)*xy+t.B(1)*t.B(2)*xx)*1e6*handles.data.energy/.511e-3;
sig22=reshape(t.B*reshape(reshape(reshape(sig2(:,[1 3 3 2]),[],2)*t.B',[],4)',2,[]),4,[])';
emit22=real(sqrt(sig22(:,1).*sig22(:,4)-sig22(:,2).*sig22(:,3)));
beta22=sig22(:,1)./emit22;alpha22=-sig22(:,2)./emit22;
emit22=emit22*1e6*handles.data.energy/.511e-3;
%plot(hAx(3),pp(2:end)/pp(end),beta(2:end));
use=pp > .01*pp(end);
figure(2);subplot(3,1,1);plot(pp(use)/pp(end),beta22(use));%,pp(use)/pp(end),beta(use),':r');
set(gca,'XTickLabel','');
ylabel('\beta  (m)');
subplot(3,1,2);plot(pp(use)/pp(end),alpha22(use));%,pp(use)/pp(end),alpha(use),':r');
set(gca,'XTickLabel','');
ylabel('\alpha  ()');
subplot(3,1,3);plot(pp(use)/pp(end),emit22(use));%,pp(use)/pp(end),emit(use),':r');
ylabel('\gamma\epsilon  (\mum)');
xlabel('Normalized Charge');
util_marginSet(2,[.12 .04],[.12 .03 .03 .04]);
util_appFonts(2,'fontSize',14);

disp('Normalized Charge');
disp(pp(end));
disp('Normalized Emittance (um)');
disp(emit(end));
emitn=emit;ppn=pp;

%{
r=t.recon;x=t.timevec;y=t.deltavec;
p=r*diff(x(1:2))*diff(y(1:2));
[x2,y2]=meshgrid(x,y);
[p2,id]=sort(p(:),'descend');
sig=[x2(id).*x2(id) y2(id).*y2(id) x2(id).*y2(id)];
xx=cumsum(sig(:,1).*p2);
yy=cumsum(sig(:,2).*p2);
xy=cumsum(sig(:,3).*p2);
pp=cumsum(p2);
emit=real(sqrt(xx.*yy-xy.^2))./pp*1e6*handles.data.energy/.511e-3;
disp('Normalized Emittance (um)');
disp(emit(end));
plot(pp/pp(end),emit,'Parent',ax);
%}

q=linspace(0,1,1000);
ax=hAx(4);
emitn2=emit(find(pp > pp(end)/2,1));
plot(ax,ppn/ppn(end),emitn,q,emitn2/(1-log(2))*(1-(1-1./q).*log(1-q)),'r:');
xlabel(ax,'Normalized Charge');ylabel(ax,'Normalized Emittance  (\mum)');
legend(ax,{'Cumulative Emittance' 'Extrapolated Core'},'Location','NorthWest');legend(ax,'boxoff');
text(.1,.5*emitn(end),num2str(emit(find(pp > .95*pp(end),1)),'%5.2f \\mum @95%% full'),'Parent',ax,'Color','b');
text(.1,.35*emitn(end),num2str(emitn2/(1-log(2)),'%5.2f \\mum @100%% core'),'Parent',ax,'Color','r');
util_appFonts(9,'fontSize',10);

ax=handles.plotEmit_ax;
if handles.processDisplayNormalize
    imagesc(t.xn,t.yn,t.recon0,'Parent',ax);
    xlabel(ax,'Norm. Position');
    ylabel(ax,'Norm. Angle');
else
    imagesc(t.timevec*1e6,t.deltavec*1e6,t.recon,'Parent',ax);
    xlabel(ax,'Position  (\mum)');
    ylabel(ax,'Angle  (\murad)');
end
set(ax,'YDir','normal');


% --- Executes on button press in modelSource_btn.
function modelSource_btn_Callback(hObject, eventdata, handles)

val=gui_modelSourceControl(hObject,handles,[]);
gui_modelSourceControl(hObject,handles,mod(val,3)+1);
%gui_modelSourceControl(hObject,handles,get(hObject,'Value')+1);
%measureDevListControl(hObject,handles,[]); % Breaks when model source unavail


% --- Executes on button press in noHeater_box.
function noHeater_box_Callback(hObject, eventdata, handles)

noHeaterControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in dataImgProc_btn.
function dataImgProc_btn_Callback(hObject, eventdata, handles)

handles.process.done=0;
processSlice(hObject,handles);


function profmonCut_txt_Callback(hObject, eventdata, handles)

profmonCutControl(hObject,handles,str2double(get(hObject,'String')));


% --- Executes on button press in profmonMedian_box.
function profmonMedian_box_Callback(hObject, eventdata, handles)

profmonMedianControl(hObject,handles,get(hObject,'Value'));




% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function viewLog_Callback(hObject, eventdata, handles)
% ViewLog_Callback is called when View Log menu item is selected.
% A.t.t.o.w. Viewlog is under teh file menu.
% hObject    handle to ViewLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% vewLog_Callback finds and spawn a viewer of this application execution 
% instance specific log file.
% 
emittance_const;
UNDEFLOGENV=...
   'Environment variable MATLAB_LOG_FILE_NAME is undefined or empty.';

try
    logfile=getenv('MATLAB_LOG_FILE_NAME');
    if (~isempty(logfile))
         pid=feature('getpid');   % Pass pid to tail, to terminate tail 
                                 % when app process completes.
        [s,res]=system(sprintf(VIEWLOGCMD,logfile,logfile,pid));
        if s~=0
           uiwait(errordlg(sprintf('%s %s. Can not complete command %s',...
                EM_LOGFILEERR_MSG, res, VIEWLOGCMD)));
        end
    else
        uiwait(errordlg(sprintf('%s %s',EM_LOGFILEERR_MSG, UNDEFLOGENV)));
    end
catch ex
    if ~strncmp(ex.identifier,EM_EXID_PREFIX,3)  
        lprintf(STDERR, '%s\n', getReport(ex,'extended'));
    end
    uiwait(errordlg(....
        lprintf(STDERR,'Problem viewing log file. %s', ex.message)));
end

function screenShot_Callback(hObject, eventdata, handles)
% screenShot_Callback is called when File->Screen Shot to Log menubar 
% item is selected. This function prints a screen shot of the GUI 
% to the Physics Log.
%
% hObject    handle to ScreenShot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Find and spawn a viewer of the log file
emittance_const;

% This function just sets a timer to execute screenShot_toLog in 1 second,
% since if the screenshot is actually done synchronously then the image
% would include the pulldown in action.
try
    screenShotTimer=timer;
    screenShotTimer.Name='ScreenShotTimer';
    screenShotTimer.StartDelay=1.0;
    screenShotTimer.ExecutionMode='singleShot';
    screenShotTimer.BusyMode='drop';
    screenShotTimer.TimerFcn=@(~,thisEvent)screenShot_toLog(handles);
    start(screenShotTimer);
catch ex
    delete(screenShotTimer);
    if ~strncmp(ex.identifier,EM_EXID_PREFIX,3)  
        lprintf(STDERR, '%s\n', getReport(ex,'extended'));
    end
    uiwait(errordlg(...
        lprintf(STDERR,'Problem putting screen shot in physics log. %s', ...
        ex.message)));
end

% ----------------------------------------------------------------------
function screenShot_toLog(handles)
% screenShot_toLog takes a screenshot of the GUI window and puts a png
% of it in the Physics logbook.

wirescan_const;
windowTitlePattern='Emittance Application'; 
persistent SUCCESS;
SUCCESS=0;

% Find Application's GUI screen id. The GUI title must contain 
% windowTitlePattern.
getWindowIdCmd=...
    sprintf('wmctrl -l | awk ''/%s/ {print $1}''',windowTitlePattern);
[iss,winId_hextxt]=system(getWindowIdCmd);
if ~isequal(iss,SUCCESS) 
    error(lprintf(STDERR,...
        'Could not get application window id for window %s',...
        windowTitlePattern));
end;

% Make screen capture of GUI screen
pngfn=sprintf('%s.png',tempname);
screencapture_cmd=sprintf('import -window "%s" %s',winId_hextxt,pngfn);
[iss,msg]=system(screencapture_cmd);
if ~isequal(iss,SUCCESS) 
    error(lprintf(STDERR,...
        'Could not screen capture application window. %s',char(msg)));
end;

% Post screen capture to logbook
loggerCmd='physicselog'; % Must be in PYTHONPATH. Note named as if module.
logBookPostCmd=...
    sprintf('python -m %s lcls "Screenshot" %s "Emittance Screenshot"',...
    loggerCmd, pngfn);
[iss,msg]=system(logBookPostCmd);
if ~isequal(iss,SUCCESS) 
    error(lprintf(STDERR,...
        'Could not post screen capture png to log book. %s',char(msg))); 
end;


% ------------------------------------------------------------------
function controlsScreen_Callback(hObject, eventdata, handles, screenName)
% hObject    handle to Global (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% screenname The file name of the controls screen to launch. At the time
%            of writing this must be an EDM file *.edl which must be 
%            in the path given by EDMDATAFILES.
%
% controlsScreen_Callback launches a given control "panel", specified by
% argument screenName.

emittance_const;

try
    cmd=sprintf(SCREENCOMMAND,screenName);
    [iss,res]=system(cmd);
    if iss~=0
        uiwait(errordlg(EM_CANTOPENCONTROLSSCREEN_MSG,cmd,res));
    end
catch ex
    if ~strncmp(ex.identifier,EM_EXID_PREFIX,3)  
        lprintf(STDERR, '%s\n', getReport(ex,'extended'));
    end
    uiwait(errordlg(lprintf(STDERR,'Problem openning controls screen. %s', ...
        ex.message)));
end

function help_Callback(hObject, eventdata, handles)
% help_Callback is called when Help menubar item is selected. This
% function presents the online user guide documententation.
%
% hObject    handle to ViewLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Find and spawn a viewer of the log file
emittance_const;
try
    web(EMITTANCEGUIHELP_URL, '-browser');
catch ex
    if ~strncmp(ex.identifier,EM_EXID_PREFIX,3)  
        lprintf(STDERR, '%s\n', getReport(ex,'extended','hyperlinks','off'));
    end
    uiwait(errordlg(...
        lprintf(STDERR,'Problem viewing help. %s', ex.message)));
end

% --------------------------------------------------------------------
function quit_Callback(hObject, eventdata, handles)
% quit_Callback is called when Quit menu item is selected to exit the GUI.
%
% hObject    handle to quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(handles.emittance_gui);



% --- Server mode selection
function checkbox14_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject,'Value')
    handles.servertimer = timer('Period',0.5,'TimerFcn',{@serverRun_Callback,handles},'StopFcn',{@serverStop_Callback,handles},'ExecutionMode','fixedrate');   
    guidata(hObject,handles);
    start(handles.servertimer);
else
    stop(handles.servertimer);
end

% --- Function runs in timer when server mode option checked
function serverRun_Callback(~,~,handles)

% --- look for new command in PV and execute
if strcmp(handles.accelerator,'FACET')
   cmd = deblank(char(lcaGet('SIOC:SYS1:ML00:CA027')));
   try
       switch cmd
           case 'Start Scan'
               disp('Server Mode: Start Scan commanded...');
               set(handles.acquireStart_btn,'Value',1);
               acquireStart_btn_Callback(handles.acquireStart_btn, [], handles) ;
               lcaPutNoWait('SIOC:SYS1:ML00:CA027',double('Scanning'));
           case 'Scanning'
               if ~gui_acquireStatusGet(handles.acquireStart_btn,handles)
                   disp('Server Mode: Saving data after scan...');
                   dataSave(handles.dataSave_btn,handles,0);
                   lcaPutNoWait('SIOC:SYS1:ML00:CA027',0);
               end
           case 'Set Quad Limits'
               lim1=lcaGet('SIOC:SYS1:ML01:AO351'); lim2=lcaGet('SIOC:SYS1:ML01:AO352');
               fprintf('Server Mode: Set Quad Limits: %g %g\n',lim1,lim2);
               set(handles.measureQuadRangeLow_txt,'Value',lim1); set(handles.measureQuadRangeHigh_txt,'Value',lim2);
               measureQuadRange_txt_Callback(handles.measureQuadRangeLow_txt_Callback,[],handles,1);
               measureQuadRange_txt_Callback(handles.measureQuadRangeHigh_txt_Callback,[],handles,2);
               lcaPutNoWait('SIOC:SYS1:ML00:CA027',0);
       end
   catch ME
       lcaPutNoWait('SIOC:SYS1:ML00:CA027',0);
       stop(handles.servertimer);
       throw(ME);
   end
   
end

% --- Function runs when server mode timer stopped
function serverStop_Callback(~,~,handles)
set(handles.checkbox14,'Value',0);
drawnow

