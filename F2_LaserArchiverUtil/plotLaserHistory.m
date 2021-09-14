function varargout = plotLaserHistory(varargin)
% PLOTLASERHISTORY MATLAB code for plotLaserHistory.fig
%      PLOTLASERHISTORY, by itself, creates a new PLOTLASERHISTORY or raises the existing
%      singleton*.
%
%      H = PLOTLASERHISTORY returns the handle to a new PLOTLASERHISTORY or the handle to
%      the existing singleton*.
%
%      PLOTLASERHISTORY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTLASERHISTORY.M with the given input arguments.
%
%      PLOTLASERHISTORY('Property','Value',...) creates a new PLOTLASERHISTORY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plotLaserHistory_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plotLaserHistory_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plotLaserHistory

% Last Modified by GUIDE v2.5 26-Mar-2021 12:05:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plotLaserHistory_OpeningFcn, ...
                   'gui_OutputFcn',  @plotLaserHistory_OutputFcn, ...
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


% --- Executes just before plotLaserHistory is made visible.
function plotLaserHistory_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plotLaserHistory (see VARARGIN)
addpath(genpath('/home/fphysics/cemma/plotLaserHistoryGUI082020'))
% Choose default command line output for plotLaserHistory
handles.output = hObject;
set(handles.pushbutton2,'Enable','off')
% Add handles to camera PVs
handles.cameraPVs = {'CAMR:LT10:500','CAMR:LT10:600','CAMR:LT10:800','CAMR:LT10:700',...
    'CAMR:LT10:200','CAMR:LT10:380','CAMR:LT10:450','CAMR:LT10:900','CAMR:LT20:0001','CAMR:LT20:0002',...
    'CAMR:LT20:0003','CAMR:LT20:0004','CAMR:LT20:0005','CAMR:LT20:0006','CAMR:LT20:0007','CAMR:LT20:0007',...
    'CAMR:LT20:0009','CAMR:LT20:0010','CAMR:LT20:0101','CAMR:LT20:0102','CAMR:LT20:0103','CAMR:LT20:0104',...
    'CAMR:LT20:0105','CAMR:LT20:0106','CAMR:LT20:0107'};
handles.matlabArrayPVs ={'SIOC:SYS1:ML00:FWF05','SIOC:SYS1:ML00:FWF06',...
    'SIOC:SYS1:ML00:FWF03','SIOC:SYS1:ML00:FWF07','SIOC:SYS1:ML00:FWF04',...
    'SIOC:SYS1:ML00:FWF08','SIOC:SYS1:ML00:FWF01','SIOC:SYS1:ML00:FWF02','SIOC:SYS1:ML00:FWF09',...
    'SIOC:SYS1:ML00:FWF10','SIOC:SYS1:ML00:FWF11','SIOC:SYS1:ML00:FWF12',...
    'SIOC:SYS1:ML00:FWF13','SIOC:SYS1:ML00:FWF14','SIOC:SYS1:ML00:FWF15',...
    'SIOC:SYS1:ML00:FWF16','SIOC:SYS1:ML00:FWF57','SIOC:SYS1:ML00:FWF58','SIOC:SYS1:ML00:FWF59',...
    'SIOC:SYS1:ML00:FWF60','SIOC:SYS1:ML00:FWF61','SIOC:SYS1:ML00:FWF62',...
    'SIOC:SYS1:ML00:FWF63','SIOC:SYS1:ML00:FWF64','SIOC:SYS1:ML00:FWF65',...
    'SIOC:SYS1:ML00:FWF66'};% These are asssociated with the above cameraPVs
handles.magnification = [0.0475,0.425,0.25,0.11,1.0712,0.209,0.62,...
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
handles.umPerPixel = [3.75,4.08,3.75,4.08,9.9,9.9,9.9,4.65,...
    3.75,3.75,4.08,4.08,9.9,4.08,4.08,4.08,3.75,3.75,3.75,3.75,3.75,3.75,4.08,3.75,3.75];
%handles.magnification = ones(1,length(handles.cameraPVs));% Set all dimensions to pixels
%handles.umPerPixel = ones(1,length(handles.cameraPVs));% Set all dimensions to pixels
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes plotLaserHistory wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = plotLaserHistory_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function uitable1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
s10CameraNames = {'S10OscillatorOutput';'S10RegenOutput';'S10MPAOutput';'S10CompressorOutput';...
    'S10UVConversionOutput';'S10UVIrisOutput';'S10C2F';'S10VCC'};
handles.s10CameraNames = s10CameraNames;
checkbox1={false;false;false;false;false;false;false;false};
hObject.Data =[s10CameraNames checkbox1];
hObject.ColumnEditable = [false true];
hObject.ColumnWidth = {250,50};


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String',datestr(now-1,'mm/dd/yyyy HH:MM'));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String',datestr(now,'mm/dd/yyyy HH:MM'));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Determine which cameras to get data from and plot
s10cameraHandles = get(handles.uitable1, 'Data');
s10camerasSelected = find(cell2mat(s10cameraHandles(:,2)));
s20cameraHandles = get(handles.uitable2,'Data');
s20camerasSelected = find(cell2mat(s20cameraHandles(:,2)))+numel(s10cameraHandles(:,2));
allcamerasSelected = [s10camerasSelected;s20camerasSelected];
set(handles.text5,'String',' ');%Clear warnings
set(handles.text8,'String',' ');%Clear warnings
if isempty(allcamerasSelected) 
    set(handles.text5,'String','No cameras selected');return;end
% Determine which time interval to plot 
try
 startTimeStamp = datenum(handles.edit1.String); endTimeStamp = datenum(handles.edit2.String);
  if startTimeStamp > endTimeStamp 
     set(handles.text5,'String','End date must be after Start date');return;end
catch
    set(handles.text5,'String','Invalid Date Format');return;   
end 
  makeLaserHistoryPlots(hObject,startTimeStamp,endTimeStamp,handles);
    
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
laserHistoryData = handles.UserData;
uisave({'laserHistoryData'},'LaserHistoryData');

% --- Executes during object creation, after setting all properties.
function pushbutton2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function uitable2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uitable2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
s20CameraNames = {'S20RegenOutput';'S20PulsePicker';'S20PreampNear';'S20PreampFar';...
    'S20PreampOut';'S20MPANear';'S20MPAFar';'S20Launch';'S20HeNeNear';'S20HeNeFar';...
    'B0';'B1';'B2';'B3';'B4';'B5';'B6'};
handles.s20CameraNames = s20CameraNames;
checkbox1={false;false;false;false;false;false;false;false;...
    false;false;false;false;false;false;false;false;false};
hObject.Data =[s20CameraNames checkbox1];
hObject.ColumnEditable = [false true];
hObject.ColumnWidth = {250,50};

function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String',datestr(now-1,'mm/dd/yyyy HH:MM'));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Determine which time interval to plot 
set(handles.text5,'String',' ');%Clear warnings
set(handles.text8,'String',' ');%Clear warnings
try
 imageTimeStamp = datenum(handles.edit4.String); 
if imageTimeStamp > datenum(now-1/24) 
     set(handles.text8,'String','Image date must be at least 1hr ago');return;end
catch
    set(handles.text8,'String','Invalid Date Format');return;   
end 
plotS10andS20LaserImagesAtSomeTime(handles,imageTimeStamp)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
exit
