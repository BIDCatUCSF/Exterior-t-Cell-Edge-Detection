function varargout = image_segment(varargin)
% IMAGE_SEGMENT MATLAB code for image_segment.fig
%      IMAGE_SEGMENT, by itself, creates a new IMAGE_SEGMENT or raises the existing
%      singleton*.
%
%      H = IMAGE_SEGMENT returns the handle to a new IMAGE_SEGMENT or the handle to
%      the existing singleton*.
%
%      IMAGE_SEGMENT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGE_SEGMENT.M with the given input arguments.
%
%      IMAGE_SEGMENT('Property','Value',...) creates a new IMAGE_SEGMENT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before image_segment_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to image_segment_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help image_segment

% Last Modified by GUIDE v2.5 01-Nov-2018 09:49:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @image_segment_OpeningFcn, ...
                   'gui_OutputFcn',  @image_segment_OutputFcn, ...
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


% --- Executes just before image_segment is made visible.
function image_segment_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to image_segment (see VARARGIN)

% Choose default command line output for image_segment
handles.output = hObject;

% Update handles structure

% UIWAIT makes image_segment wait for user response (see UIRESUME)
guidata(hObject, handles);
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = image_segment_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%This is the select file for segmentation of boundary step

[file_1a,path,success]=uigetfile;
handles.filename_now=file_1a;
handles.pathname_now=path;

guidata(hObject, handles);






% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Go Button
file_1=handles.filename_now;
path_1=handles.pathname_now;

%number of files in directory
a=dir([path_1,'*.tif']);
num_ims=numel(a);

analyze_ims(file_1,path_1,num_ims);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%This is the file selection for max intensity projection

[file_2a,path_2a,success]=uigetfile;
handles.filename_now2=file_2a;
handles.pathname_now2=path_2a;

guidata(hObject, handles);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Go Button
file_2=handles.filename_now2;
path_2=handles.pathname_now2;

green_button=handles.button488

%number of files in directory
a2=dir([path_2,'*.tif']);
num_ims2=numel(a2);

stack_ims(file_2,path_2,num_ims2,green_button)


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

button_488=get(hObject,'Value');
handles.button488=button_488;

guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2

button_642=get(hObject,'Value')
handles.button642=button_642;

guidata(hObject, handles);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close all;
