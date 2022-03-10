function varargout = laserStatusTableGUI(varargin)
% LASERSTATUSTABLEGUI MATLAB code for laserStatusTableGUI.fig
%      LASERSTATUSTABLEGUI, by itself, creates a new LASERSTATUSTABLEGUI or raises the existing
%      singleton*.
%
%      H = LASERSTATUSTABLEGUI returns the handle to a new LASERSTATUSTABLEGUI or the handle to
%      the existing singleton*.
%
%      LASERSTATUSTABLEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LASERSTATUSTABLEGUI.M with the given input arguments.
%
%      LASERSTATUSTABLEGUI('Property','Value',...) creates a new LASERSTATUSTABLEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before laserStatusTableGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to laserStatusTableGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help laserStatusTableGUI

% Last Modified by GUIDE v2.5 11-Nov-2020 09:11:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @laserStatusTableGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @laserStatusTableGUI_OutputFcn, ...
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


% --- Executes just before laserStatusTableGUI is made visible.
function laserStatusTableGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to laserStatusTableGUI (see VARARGIN)

% Choose default command line output for laserStatusTableGUI
handles.output = hObject;
assignin('base','myVar',hObject)
% No pushbutton in the new version - don't display reference vals button
set(handles.pushbutton1,'visible','on')
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes laserStatusTableGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = laserStatusTableGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function uitable1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
rowNames = {'Oscillator Output';'Centroid Offset [mm] (x,y)';'Spot Size [mm] (x,y)';...
    'Nonuniformity ';'Energy (mW, RMS [%],Range/RMS)';
    'Regen Output';'Centroid Position [pix] (x,y)';'Spot Size [mm] (x,y)';...
    'Nonuniformity ';'Energy (mJ, RMS [%],Range/RMS)';...
    'MPA Output';'Centroid Position [pix] (x,y)';'Spot Size [mm] (x,y)';...
    'Nonuniformity ';'Energy (mJ, RMS [%],Range/RMS)';...
    'Compressor Output';'Centroid Position [pix] (x,y)';'Spot Size [mm] (x,y)';...
    'Nonuniformity ';'Energy (mJ, RMS [%],Range/RMS)';...
    'UV Conv. Output';'Centroid Position [pix] (x,y)';'Spot Size [mm] (x,y)';...
    'Nonuniformity ';'Energy (mJ, RMS [%],Range/RMS)';...
    'UV Iris Output';'Centroid Position [pix] (x,y)';'Spot Size [mm] (x,y)';...
    'Nonuniformity ';'Energy (mJ, RMS [%],Range/RMS)';...
    'VCC';'Centroid Position [pix] (x,y)';'Spot Size [mm] (x,y)';...
    'Nonuniformity ';'Energy (mJ, RMS [%],Range/RMS)';'Temperature [deg F]';'Humidity [%]'};
hObject.ColumnEditable = [false true true true];
hObject.BackgroundColor = repmat([.85 .9 .95; 1 1 1;1 1 1;1 1 1;1 1 1],7,1);
bkgrnds = get(hObject,'BackgroundColor');
bkgrnds(36,:) = [.75 .9 .9];% Do this manually for now but you wanna do this programatically
bkgrnds(37,:) = [.75 .9 .9];
hObject.BackgroundColor = bkgrnds;
hObject.ColumnWidth = {180,100,100,100};
% Fill the table with zeros
emptyData=cell(length(rowNames),1); emptyData(:) = {0};
emptyData(1:5:31) = {''};
set(hObject,'ColumnFormat', {'char','numeric','numeric','numeric'});
hObject.Data =[rowNames emptyData emptyData emptyData];
guidata(hObject,handles)
% Add new data to the table
uitable1_CellEditCallback(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% Set the date to whaever you want
handles.filename = evalin('base','filename');
set(hObject,'String',['Current data taken at ',handles.filename(28:end-4)],'FontSize',10);

%set(hObject,'String','','FontSize',10);


% --- Executes when entered data in editable cell(s) in uitable1.
function uitable1_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
handles.filename = evalin('base','filename');
%set(hObject,'String',['Current data taken at ',datestr(t(end),'mm-dd-yyyy HH:MM')],'FontSize',10);
camerasSelected = 1:7;
%%%%%%%%%%%% THESE 3 ARE TO FILL THE TABLE AND THEY WORK %%%%%%%%%%%%%%%%%%
[newData]=getLaserStatusTableDatav4(camerasSelected,hObject,handles);% This will work using the 1hr data as input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%displayReferenceValues()

camerasSelected = 1:7;
handles.LiveTableBool = 1;
guidata(hObject,handles);
[newData]=getLaserStatusTableDataLive(camerasSelected,hObject,handles);% This will work using the archiver data as input


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.LiveTableBool = 0;
bkgrnds = repmat([.85 .9 .95; 1 1 1;1 1 1;1 1 1;1 1 1],7,1);
bkgrnds(36,:) = [.75 .9 .9];% Do this manually for now but you wanna do this programatically
bkgrnds(37,:) = bkgrnds(36,:);
% Set the new background colors
set(handles.uitable1,'BackgroundColor',bkgrnds);

guidata(hObject,handles);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path]=uigetfile('*.mat','Select a dataset');
handles.filename = fullfile(path,file);
camerasSelected = 1:7;
%%%%%%%%%%%% THESE 3 ARE TO FILL THE TABLE AND THEY WORK %%%%%%%%%%%%%%%%%%
[newData]=getLaserStatusTableDatav4(camerasSelected,hObject,handles);% This will work using the 1hr data as input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
