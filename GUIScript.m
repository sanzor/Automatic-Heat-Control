
function varargout = gui_3(varargin)
% GUI_3 MATLAB code for gui_3.fig
%      GUI_3, by itself, creates a new GUI_3 or raises the existing
%      singleton*.
%
%      H = GUI_3 returns the handle to a new GUI_3 or the handle to
%      the existing singleton*.
%
%      GUI_3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_3.M with the given input arguments.
%
%      GUI_3('Property','Value',...) creates a new GUI_3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_3

% Last Modified by GUIDE v2.5 26-Oct-2016 16:00:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_3_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_3_OutputFcn, ...
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


% --- Executes just before gui_3 is made visible.
function gui_3_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
handles.samples=100;
handles.FAN_1_PWM=0;
handles.BULB_1_PWM=0;
handles.FAN_2_PWM=0;
handles.BULB_2_PWM=0;
handles.FAN_3_PWM=0;
handles.BULB_3_PWM=0;
%handles.MODE=0;  %incepem din manual%
handles.DATA='------------------------Date RAW preluate de la ARDUINO----------------------';
handles.port_stt='closed';
handles.mode=0;
handles.ref1=0;
handles.ref2=0;
handles.ref3=0;
 grid(handles.axes1, 'on')
 ylim(handles.axes1,[0 100]);
 xlim(handles.axes1,[0 100]);
 grid(handles.axes2, 'on')
 ylim(handles.axes2,[0 100]);
 xlim(handles.axes2,[0 100]);
 grid(handles.axes3, 'on')
 ylim(handles.axes3,[0 100]);
 xlim(handles.axes3,[0 100]);


% Update handles structure
guidata(hObject, handles);
delete(instrfind({'Port'},{'COM9'}));
global myport;
myport=serial('COM9','BaudRate',9600,'Timeout',2);

% --- Outputs from this function are returned to the command line.
function varargout = gui_3_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes on button press in quit_btn.
function quit_btn_Callback(hObject, eventdata, handles)
close all;

function set_sample_btn_Callback(hObject, eventdata, handles)
global myport;
handles=guidata(hObject); 
if(strcmp(handles.port_stt,'closed'));
handles.samples=str2double(get(handles.sample_Set_TB,'String'));
guidata(hObject,handles);
end

function sample_Set_TB_Callback(hObject, eventdata, handles)
%functie care seteaza numarul de sample-uri
handles.samples=str2double(get(handles.sample_Set_TB,'String'));
guidata(hObject,handles);


%----------------------Port opening-----------------------%
function open_port_btn_Callback(hObject, eventdata, handles)
global myport;
handles=guidata(hObject);
if(~strcmp(handles.port_stt,'opened'))
fopen(myport);
handles.port_stt='opened';
guidata(hObject,handles);
end

%----------------------Port closing-----------------------%

%Atentie da TIMEOUT Daca dau fprintf-uri repetate consecutive !
function close_port_btn_Callback(hObject, eventdata, handles)
global myport;
handles=guidata(hObject);
if(~strcmp(handles.port_stt,'closed'))
fprintf(myport,'0,0');
fclose(myport);
handles.port_stt='closed';
guidata(hObject,handles);
end

%---de facut buton de STOP READ-----------------%
function read_btn_Callback(hObject, eventdata, handles)
global myport;
handles=guidata(hObject);
handles.y0=zeros(handles.samples,1);
handles.y1=zeros(handles.samples,1);
handles.y2=zeros(handles.samples,1);
guidata(hObject,handles);
i=0;
a=fopen('Data.txt','wt');

    while(strcmp(handles.port_stt,'opened'))
        handles=guidata(hObject);
        drawnow
           handles.y0(1:end-1)=handles.y0(2:end,1);
             handles.y1(1:end-1)=handles.y1(2:end,1);
            handles.y2(1:end-1)=handles.y2(2:end,1);
     if(strcmp(handles.port_stt,'opened'));
         data_row=fscanf(myport);
         string=strsplit(data_row,',')
        s1=str2double(string(1));
        s2=str2double(string(4));
        s3=str2double(string(7));
        handles.y0(end)=s1/100;
        handles.y1(end)=s2/100;
        handles.y2(end)=s3/100;
        guidata(hObject,handles);
        b=strcat(data_row,'\n');
       fprintf(a,b);
       set(handles.temp_1_instant,'String',handles.y0(end));
       set(handles.temp_2_instant,'String',handles.y1(end));
       set(handles.temp_3_instant,'String',handles.y2(end));
     end
        plot(handles.axes1,0:handles.samples-1,handles.y0,'--','LineWidth',2,'Color','g');
        grid(handles.axes1, 'on')
        ylim(handles.axes1,[0 100]);
        plot(handles.axes2,0:handles.samples-1,handles.y1,'--','LineWidth',2,'Color','r');
        grid(handles.axes2, 'on')
        ylim(handles.axes2,[0 100]);
        plot(handles.axes3,0:handles.samples-1,handles.y2,'--','LineWidth',2,'Color','b');
        grid(handles.axes3, 'on')
        ylim(handles.axes3,[0 100]);
        guidata(hObject,handles);
        pause(0.0001);   
    end
 
   fclose(a);
    
%DE SCOS STRCAT DIN FPRINTF !!!!!! DE AIA DA TIMEOUT !!!
function Apply_btn_Callback(hObject, eventdata, handles)
global myport;
handles=guidata(hObject);
if(strcmp(handles.port_stt,'opened'));
%     if(handles.mode==1)
%     sendmode=strcat('1','1');
%     fprintf(myport,sendmode);
%     guidata(hObject,handles);
%     end
    if(handles.mode==0)
            handles.FAN_1_PWM=sprintf('%d',str2double(get(handles.SET_Fan1_TB,'String')));
            handles.BULB_1_PWM=sprintf('%d',str2double(get(handles.SET_Bulb1_TB,'String')));
            handles.FAN_2_PWM=sprintf('%d',str2double(get(handles.SET_Fan2_TB,'String')));
            handles.BULB_2_PWM=sprintf('%d',str2double(get(handles.SET_Bulb2_TB,'String')));
            handles.FAN_3_PWM=sprintf('%d',str2double(get(handles.SET_Fan3_TB,'String')));
            handles.BULB_3_PWM=sprintf('%d',str2double(get(handles.SET_Bulb3_TB,'String')));
            handles.ref=sprintf('%d',str2double(get(handles.ref1_TB,'String')));
            
            send1=strcat('2,',handles.FAN_1_PWM);
            send2=strcat('3,',handles.BULB_1_PWM);
            send3=strcat('4,',handles.FAN_2_PWM);
            send4=strcat('5,',handles.BULB_2_PWM);
            send5=strcat('6,',handles.FAN_3_PWM);
            send6=strcat('7,',handles.BULB_3_PWM);
            fprintf(myport,send1);
            fprintf(myport,send2);
            fprintf(myport,send3);
            fprintf(myport,send4);
            fprintf(myport,send5);
            fprintf(myport,send6);
            guidata(hObject,handles);
    end
end

function auto_zone_1_btn_Callback(hObject, eventdata, handles)
global myport;
handles=guidata(hObject);
if(strcmp(handles.port_stt,'opened') && handles.mode==1)
 handles.ref1=sprintf('%d',str2double(get(handles.ref1_TB,'String')));      
 send=strcat('8,',handles.ref1);
 fprintf(myport,send);
 guidata(hObject,handles);
end

function auto_zone_2_btn_Callback(hObject, eventdata, handles)
global myport;
handles=guidata(hObject);
if(strcmp(handles.port_stt,'opened') && handles.mode==1)
 handles.ref2=sprintf('%d',str2double(get(handles.ref2_TB,'String')));      
 send=strcat('9,',handles.ref2);
 fprintf(myport,send);
 guidata(hObject,handles);
end


% --- Executes on button press in auto_zone_3_btn.
function auto_zone_3_btn_Callback(hObject, eventdata, handles)
global myport;
handles=guidata(hObject);
if(strcmp(handles.port_stt,'opened') && handles.mode==1)
 handles.ref2=sprintf('%d',str2double(get(handles.ref3_TB,'String')));      
 send=strcat('10,',handles.ref2);
 fprintf(myport,send);
 guidata(hObject,handles);
end


% --- Executes on button press in manual_btn.
function auto_btn_Callback(hObject, eventdata, handles)
% handles=guidata(hObject);
handles=guidata(hObject);
global myport;
if(strcmp(handles.port_stt,'opened'))
handles.mode=1;
fprintf(myport,'1,1');
set(handles.mode_TB,'String','AUTO ON');
guidata(hObject,handles);
end

function manual_btn_Callback(hObject, eventdata, handles)
global myport;
handles=guidata(hObject);
if(strcmp(handles.port_stt,'opened'))
handles.mode=0;
fprintf(myport,'1,0');
set(handles.mode_TB,'String','MANUAL ON');
guidata(hObject,handles);
end

% --- Executes when user attempts to close main_fig.
function main_fig_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to main_fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global myport;
handles=guidata(hObject);
if(~strcmp(handles.port_stt,'closed'))
fprintf(myport,'0,0');
fclose(myport);
handles.port_stt='closed';
guidata(hObject,handles);
end
% Hint: delete(hObject) closes the figure
delete(hObject);



















function sample_Set_TB_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function kp1_TB_Callback(hObject, eventdata, handles)
% hObject    handle to kp1_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of kp1_TB as text
%        str2double(get(hObject,'String')) returns contents of kp1_TB as a double


% --- Executes during object creation, after setting all properties.
function kp1_TB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to kp1_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ki1_TB_Callback(hObject, eventdata, handles)
% hObject    handle to ki1_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ki1_TB as text
%        str2double(get(hObject,'String')) returns contents of ki1_TB as a double


% --- Executes during object creation, after setting all properties.
function ki1_TB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ki1_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function kd1_TB_Callback(hObject, eventdata, handles)
% hObject    handle to kd1_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of kd1_TB as text
%        str2double(get(hObject,'String')) returns contents of kd1_TB as a double


% --- Executes during object creation, after setting all properties.
function kd1_TB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to kd1_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function SET_Fan1_TB_Callback(hObject, eventdata, handles)
% hObject    handle to SET_Fan1_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SET_Fan1_TB as text
%        str2double(get(hObject,'String')) returns contents of SET_Fan1_TB as a double


% --- Executes during object creation, after setting all properties.
function SET_Fan1_TB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SET_Fan1_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.



% --- Executes during object creation, after setting all properties.


function SET_Bulb1_TB_Callback(hObject, eventdata, handles)
% hObject    handle to SET_Bulb1_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SET_Bulb1_TB as text
%        str2double(get(hObject,'String')) returns contents of SET_Bulb1_TB as a double


% --- Executes during object creation, after setting all properties.
function SET_Bulb1_TB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SET_Bulb1_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function SET_Fan2_TB_Callback(hObject, eventdata, handles)
% hObject    handle to SET_Fan2_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SET_Fan2_TB as text
%        str2double(get(hObject,'String')) returns contents of SET_Fan2_TB as a double


% --- Executes during object creation, after setting all properties.
function SET_Fan2_TB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SET_Fan2_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on slider movement.



% --- Executes during object creation, after setting all properties.



function SET_Bulb2_TB_Callback(hObject, eventdata, handles)
% hObject    handle to SET_Bulb2_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SET_Bulb2_TB as text
%        str2double(get(hObject,'String')) returns contents of SET_Bulb2_TB as a double


% --- Executes during object creation, after setting all properties.
function SET_Bulb2_TB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SET_Bulb2_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SET_Fan3_TB_Callback(hObject, eventdata, handles)
% hObject    handle to SET_Fan3_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SET_Fan3_TB as text
%        str2double(get(hObject,'String')) returns contents of SET_Fan3_TB as a double


% --- Executes during object creation, after setting all properties.
function SET_Fan3_TB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SET_Fan3_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SET_Bulb3_TB_Callback(hObject, eventdata, handles)
% hObject    handle to SET_Bulb3_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SET_Bulb3_TB as text
%        str2double(get(hObject,'String')) returns contents of SET_Bulb3_TB as a double


% --- Executes during object creation, after setting all properties.
function SET_Bulb3_TB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SET_Bulb3_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in stop_read_btn.
function stop_read_btn_Callback(hObject, eventdata, handles)
% hObject    handle to stop_read_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in modepanel.



function ref1_TB_Callback(hObject, eventdata, handles)
% hObject    handle to ref1_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ref1_TB as text
%        str2double(get(hObject,'String')) returns contents of ref1_TB as a double


% --- Executes during object creation, after setting all properties.
function ref1_TB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref1_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in auto_btn.



function mode_TB_Callback(hObject, eventdata, handles)
% hObject    handle to mode_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mode_TB as text
%        str2double(get(hObject,'String')) returns contents of mode_TB as a double


% --- Executes during object creation, after setting all properties.
function mode_TB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mode_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in auto_zone_1_btn.


% --- Executes on button press in auto_zone_2_btn.




function ref2_TB_Callback(hObject, eventdata, handles)
% hObject    handle to ref2_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ref2_TB as text
%        str2double(get(hObject,'String')) returns contents of ref2_TB as a double


% --- Executes during object creation, after setting all properties.
function ref2_TB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref2_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref3_TB_Callback(hObject, eventdata, handles)
% hObject    handle to ref3_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ref3_TB as text
%        str2double(get(hObject,'String')) returns contents of ref3_TB as a double


% --- Executes during object creation, after setting all properties.
function ref3_TB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref3_TB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function temp_1_instant_Callback(hObject, eventdata, handles)
% hObject    handle to temp_1_instant (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of temp_1_instant as text
%        str2double(get(hObject,'String')) returns contents of temp_1_instant as a double


% --- Executes during object creation, after setting all properties.
function temp_1_instant_CreateFcn(hObject, eventdata, handles)
% hObject    handle to temp_1_instant (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function temp_2_instant_Callback(hObject, eventdata, handles)
% hObject    handle to temp_2_instant (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of temp_2_instant as text
%        str2double(get(hObject,'String')) returns contents of temp_2_instant as a double


% --- Executes during object creation, after setting all properties.
function temp_2_instant_CreateFcn(hObject, eventdata, handles)
% hObject    handle to temp_2_instant (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function temp_3_instant_Callback(hObject, eventdata, handles)
% hObject    handle to temp_3_instant (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of temp_3_instant as text
%        str2double(get(hObject,'String')) returns contents of temp_3_instant as a double


% --- Executes during object creation, after setting all properties.
function temp_3_instant_CreateFcn(hObject, eventdata, handles)
% hObject    handle to temp_3_instant (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function main_fig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to main_fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
