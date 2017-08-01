function varargout = GUI_windowSelection(varargin)
% GUI_WINDOWSELECTION MATLAB code for GUI_windowSelection.fig
%      GUI_WINDOWSELECTION, by itself, creates a new GUI_WINDOWSELECTION or raises the existing
%      singleton*.
%
%      H = GUI_WINDOWSELECTION returns the handle to a new GUI_WINDOWSELECTION or the handle to
%      the existing singleton*.
%
%      GUI_WINDOWSELECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_WINDOWSELECTION.M with the given input arguments.
%
%      GUI_WINDOWSELECTION('Property','Value',...) creates a new GUI_WINDOWSELECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_windowSelection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_windowSelection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_windowSelection

% Last Modified by GUIDE v2.5 08-Aug-2016 08:39:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_windowSelection_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_windowSelection_OutputFcn, ...
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


% --- Executes just before GUI_windowSelection is made visible.
function GUI_windowSelection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_windowSelection (see VARARGIN)

% Choose default command line output for GUI_windowSelection
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(handles.axes1,'HitTest','off');
set(gcf, 'WindowButtonDownFcn', @getMousePositionOnImage);
cursorPoint = get(handles.axes1, 'CurrentPoint');
handles.cursorPoint=cursorPoint(1,1:2);
% UIWAIT makes GUI_windowSelection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_windowSelection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1. 
function pushbutton1_Callback(hObject, eventdata, handles) %for Next Window
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.i>1
    s=handles.s;
end
s(handles.i).name=handles.FolderContent(handles.Index ).name;
if (get(handles.radiobutton1,'Value')) %hematoma region
    disp('UnHealthy!!!!!!!!!!!!!!');
    s(handles.i).type='Hem';
    [handles.curX,handles.curY]
elseif (get(handles.radiobutton2,'Value')) %healthy region
    disp('Healthy!!!!!!!!!!!!!!');
    s(handles.i).type='NotHem';
end
s(handles.i).cX=handles.curY;
s(handles.i).cY=handles.curX;
set(handles.radiobutton1,'Value',0)
set(handles.radiobutton2,'Value',0)
handles.s=s;
handles.i=handles.i +1;
guidata(hObject,handles);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)%for Next Image
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%handles.i=1;
handles.Index = handles.Index + 1;
if  handles.Index <= handles.NoI
    I = uint16(dicomread([handles.dname '\' handles.FolderContent(handles.Index).name]));
    I = ContAdj(I,30,80); 
    axes(handles.axes1);
    hold off;
    handles.Img = imshow(I, []);
    hold on
    set(handles.radiobutton1,'Value',0)
    set(handles.radiobutton2,'Value',0)
    %set(handles.Img,'ButtonDownFcn',@ImageClickCallback);
end
guidata(hObject,handles);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles) %for Exit

% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=handles.s;
save(['W:\Massey2016\',handles.dname(end-2:end)],'s')

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)%for Open a folder
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.dname = uigetdir('W:\Massey2016\');
handles.FolderContent = dir(handles.dname);
handles.NoI = length(handles.FolderContent);
handles.Index = 3;
handles.i=1;
handle.s = struct('name',{},'type',{},'cX',{},'cY',{});
if handles.Index < handles.NoI
    I = uint16(dicomread([handles.dname '\' handles.FolderContent(handles.Index ).name]));
    I = ContAdj(I,30,80); 
    axes(handles.axes1);
    hold off
    handles.Img = imshow(I, []);
    hold on
    set(handles.radiobutton1,'Value',0)
    set(handles.radiobutton2,'Value',0)

%     coordinates = get(handles.axes1,'CurrentPoint'); 
%     coordinates = coordinates(1,1:2)
    %set(handles.Img,'ButtonDownFcn',@ImageClickCallback);
end
guidata(hObject,handles);

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2


% --- Executes on mouse press over axes background.


% --- Executes on mouse press over axes background.
