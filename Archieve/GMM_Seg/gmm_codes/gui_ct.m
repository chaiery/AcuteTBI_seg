function varargout = gui_ct(varargin)
% GUI_CT MATLAB code for gui_ct.fig
%      GUI_CT, by itself, creates a new GUI_CT or raises the existing
%      singleton*.
%
%      H = GUI_CT returns the handle to a new GUI_CT or the handle to
%      the existing singleton*.
%
%      GUI_CT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_CT.M with the given input arguments.
%
%      GUI_CT('Property','Value',...) creates a new GUI_CT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_ct_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_ct_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_ct

% Last Modified by GUIDE v2.5 04-Jul-2014 00:23:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_ct_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_ct_OutputFcn, ...
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


% --- Executes just before gui_ct is made visible.
function gui_ct_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_ct (see VARARGIN)

% Choose default command line output for gui_ct
handles.output = hObject;
handles.OutputDir = hObject;
handles.HemaDir = hObject;
handles.EdemaDir = hObject;
handles.RotatedDir = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_ct wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_ct_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in select.
function select_Callback(select, eventdata, handles)
% hObject    handle to select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% vars = evalin('base','who');
% inputDir = uigetdir('C:\Users\abafna\Google Drive\Winter14\Medical\longMarchShared\examples');
inputDir = uigetdir('C:\Users\abafna\Google Drive\Winter14\Medical\longMarchShared\examples');
outputDir = strcat(inputDir, '\Processed');
handles.inputDir = inputDir; 
handles.OutputDir = outputDir; 
handles.HemaDir = strcat(outputDir, '\hematoma\');
handles.EdemaDir = strcat(outputDir, '\edema\');
handles.RotatedDir = strcat(outputDir, '\dir_ideal\');
handles.MidlineDir = strcat(outputDir, '\actualMidline\');guidata(select,handles);
set(handles.inputdir,'String',inputDir);
    if exist(handles.RotatedDir,'dir')
        k = dir(strcat(handles.RotatedDir,'*.png'));
        curr_list = cell(numel(k),1);
        for i = 1:numel(k)
            curr_list{i} = k(i).name;
        end
        set(handles.imagelist,'String',curr_list);
    end




% --- Executes on button press in processm.
function processm_Callback(select, eventdata, handles)
% hObject    handle to processm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% inputDir = evalin('base',
p = path;
path(path, '../modules');
curr_list = testAll(get(handles.inputdir,'String'), handles.OutputDir, get(handles.isD,'Value'));
set(handles.imagelist,'String',curr_list);
path(p)
 


% --- Executes on selection change in imagelist.
function imagelist_Callback(imagelist, eventdata, handles)
% hObject    handle to imagelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(imagelist,'String')); %returns imagelist contents as cell array
filename = contents{get(imagelist,'Value')}; % returns selected item from imagelist
im0 = imread(strcat(handles.RotatedDir, filename));
ind = find(filename == '.');
filename2 = [filename(1:ind) 'jpg'];
im1 = imread([handles.inputDir '\' filename2]);
if get(handles.original,'Value')
    imshow(im0,'Parent',handles.graph1);
    imshow(im1,'Parent',handles.graph2);
elseif get(handles.midline,'Value') 
    im2 = imread(strcat(handles.MidlineDir, filename));
    imshow(im1,'Parent',handles.graph1);
    imshow(im2,'Parent',handles.graph2);
elseif get(handles.hema,'Value')
    im2 = imread(strcat(handles.HemaDir, filename));
    imshow(im1,'Parent',handles.graph1);
    imshow(im2,'Parent',handles.graph2);
elseif get(handles.edema,'Value')
    im2 = imread(strcat(handles.EdemaDir, filename));
    imshow(im1,'Parent',handles.graph1);
    imshow(im2,'Parent',handles.graph2);
end




% --- Executes during object creation, after setting all properties.
function imagelist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imagelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in original.
function original_Callback(hObject, eventdata, handles)
% hObject    handle to original (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% if get(hObject,'Value') 
% % midline = strcat(handles.OutputDir, '\dir_ideal\');
% set(hObject,'Value',0);
% filelist = get(handles.imagelist,'String');
% filename = filelist{get(handles.imagelist,'Value')};
% im1 = imread(strcat(handles.RotatedDir, filename));
% im2 = imread(strcat(handles.RotatedDir, filename));
% handles.graph1;
% subplot(121);imshow(im1);
% subplot(122);imshow(im2);
% end

% Hint: get(hObject,'Value') returns toggle state of original

% --- Executes on button press in midline.
function midline_Callback(hObject, eventdata, handles)
% hObject    handle to midline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% if get(hObject,'Value') 
% set(hObject,'Value',0);
% filelist = get(handles.imagelist,'String');
% filename = filelist{get(handles.imagelist,'Value')};
% im1 = imread(strcat(handles.RotatedDir, filename));
% im2 = imread(strcat(handles.MidlineDir, filename));
% handles.graph1;
% subplot(121);imshow(im1);
% subplot(122);imshow(im2);
% end
% Hint: get(hObject,'Value') returns toggle state of midline


% --- Executes on button press in hema.
function hema_Callback(hObject, eventdata, handles)
% hObject    handle to hema (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% if get(hObject,'Value') 
% % hema = strcat(handles.OutputDir, '\hematoma\');
% set(hObject,'Value',0);
% filelist = get(handles.imagelist,'String');
% filename = filelist{get(handles.imagelist,'Value')};
% im1 = imread(strcat(handles.RotatedDir, filename));
% im2 = imread(strcat(handles.HemaDir, filename));
% handles.graph1;
% subplot(121);imshow(im1);
% subplot(122);imshow(im2);
% end
% Hint: get(hObject,'Value') returns toggle state of hema


% --- Executes on button press in edema.
function edema_Callback(hObject, eventdata, handles)
% hObject    handle to edema (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% if get(hObject,'Value') 
% % edema = strcat(handles.OutputDir, '\edema\');
% set(hObject,'Value',0);
% filelist = get(handles.imagelist,'String');
% filename = filelist{get(handles.imagelist,'Value')};
% im1 = imread(strcat(handles.RotatedDir, filename));
% im2 = imread(strcat(handles.EdemaDir, filename));
% handles.graph1;
% subplot(121);imshow(im1);
% subplot(122);imshow(im2);
% end
% Hint: get(hObject,'Value') returns toggle state of edema


% --- Executes on button press in processh.
function processh_Callback(hObject, eventdata, handles)
% hObject    handle to processh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filelist = get(handles.imagelist,'String');
filename = filelist{get(handles.imagelist,'Value')};
rd = handles.RotatedDir;
he = handles.HemaDir;
filelist = filelist(~cellfun(@isempty,filelist));
if get(handles.batch,'Value')
    parfor i = 1:numel(filelist)
       detectHe(filelist{i},rd,he);
    end
    matlabpool close
    isdetected = 'Batch process complete!';
else
    isdetected = detectHe(filename,rd,he);
end
set(handles.display,'String',isdetected);


% --- Executes on button press in processe.
function processe_Callback(hObject, eventdata, handles)
% hObject    handle to processe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path(path, './nlmeans');
filelist = get(handles.imagelist,'String');
filename = filelist{get(handles.imagelist,'Value')};
rd = handles.RotatedDir;
ed = handles.EdemaDir;
filelist = filelist(~cellfun(@isempty,filelist));
if get(handles.batch,'Value')
    parfor i = 1:numel(filelist)
       detectEd(filelist{i},rd,ed);
    end
    matlabpool close
    isdetected = 'Batch process complete!';
else
    isdetected = detectEd(filename,rd,ed);
end
set(handles.display,'String',isdetected);


% --- Executes on button press in batch.
function batch_Callback(hObject, eventdata, handles)
% hObject    handle to batch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of batch


% --- Executes on button press in isD.
function isD_Callback(hObject, eventdata, handles)
% hObject    handle to isD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isD
