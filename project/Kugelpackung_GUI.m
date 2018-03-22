function varargout = Kugelpackung_GUI(varargin)

gui_Singleton = 1;

gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Kugelpackung_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @Kugelpackung_GUI_OutputFcn, ...
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

function Kugelpackung_GUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

guidata(hObject, handles);

%% Variablendeklaration (globalLink)
global n;
global F;
global CR;
global my;
global max_Iter;

%% Variablendefinition
[n_init,F_init,CR_init,my_init,max_Iter_init,F_min,F_max,CR_min,CR_max,Ver] ...
                    = Initialisierung_Parameter; %initiale Parameter setzen
n = n_init;
F = F_init;
CR = CR_init;
my = my_init;
max_Iter = max_Iter_init;

%% Initialisierungsroutine GUI

% Initialisierung: Axes
Kugelplot_loeschen(handles.Axes_Darstellung);

% Initialisierung: TextBox
set(handles.TextBox_Kugelanzahl_n,'string',num2str(n_init));
set(handles.TextBox_my,'string',num2str(my_init));
set(handles.TextBox_max_Iterationen,'string',num2str(max_Iter_init));

% Initialisierung: Slider
set(handles.Slider_F,'min',F_min);
set(handles.Slider_F,'max',F_max);
set(handles.Slider_F,'Value',F_init);
set(handles.Slider_CR,'min',CR_min);
set(handles.Slider_CR,'max',CR_max);
set(handles.Slider_CR,'Value',CR_init);

% Initialisierung: Text
set(handles.Text_Wert_F,'String',num2str(get(handles.Slider_F,'Value')));
set(handles.Text_Wert_CR,'String',num2str(get(handles.Slider_CR,'Value')));
set(handles.Text_Wert_Packungsdichte,'String','n.v.');
set(handles.Text_Wert_Laufzeit,'String','n.v.');
set(handles.StaticText_Version,'String',Ver);

function varargout = Kugelpackung_GUI_OutputFcn(hObject, eventdata,...
                                                                   handles) 

varargout{1} = handles.output;

function Slider_F_Callback(hObject, eventdata, handles)

% Variablendeklaration (globalLink)
global F;

% (neuen) Wert übernehmen
F = double(get(hObject,'Value'));
set(handles.Text_Wert_F,'String',num2str(F));

function Slider_F_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), ... 
                                  get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function Button_Start_Callback(hObject, eventdata, handles)
%% Variablendeklaration (globalLink)
global n;
global F;
global CR;
global my;
global max_Iter;

t_lauf = 0;                                                                 %Laufzeit initialisieren
tic;                                                                        %Timer starten

%Optimierungsalgorithmus aufrufen
[x,x_best,d,dKP,t_arr,generationenSpeicher, ... 
    best_zwischen_d, best_zwischen_x, best_d_of_t] = ...
                                            Algorithm(n,F,CR,my,max_Iter);

t_lauf = t_lauf + toc;                                                      %Laufzeit aktualisieren und Timer stoppen

%"Text_Wert_Laufzeit" anhand von "t_lauf" aktualisieren
set(handles.Text_Wert_Laufzeit,'String',num2str(t_lauf));

%Ergebnis graphisch darstellen
Kugelplot(handles.Axes_Darstellung,d,x_best(:,:,1), ...
                         x_best(:,:,2),x_best(:,:,3),dKP,F,CR,my,max_Iter);

%"Text_Wert_Packungsdichte" anhand von "dKP" aktualisieren
set(handles.Text_Wert_Packungsdichte,'String',num2str(dKP));

%Verlauf des (Kugel-)Durchmessers "d" über die Generationen "t" darstellen
Kugeldurchmesserplot(best_d_of_t,t_arr,dKP,F,CR,my,max_Iter);

function Slider_CR_Callback(hObject, eventdata, handles)

% Variablendeklaration (globalLink)
global CR;

% (neuen) Wert übernehmen
CR = double(get(hObject,'Value'));
set(handles.Text_Wert_CR,'String',num2str(CR));

function Slider_CR_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), ... 
                                  get(0,'defaultUicontrolBackgroundColor'))
                              
    set(hObject,'BackgroundColor',[.9 .9 .9]);

end

function TextBox_my_Callback(hObject, eventdata, handles)

% Variablendeklaration (globalLink)
global my;

%  Kontrolle der Eingabe und Übergabe
if isnan(str2double(get(hObject,'string')))                                 %ist Eingabe in double-Format konvertierbar?
    
    set(handles.TextBox_my,'string',num2str(my));                           %Wert zurücksetzen
    mb = msgbox('Falsche oder ungültige Eingabe der Populationsgröße µ.');
    return;

else
    
    my = uint16(str2double(get(hObject,'string')));                         %in Integer (8 bit) umwandeln
    set(handles.TextBox_my,'string',num2str(my));                           %(umgewandelten) Wert einsetzen

end

function TextBox_my_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), ...
                                  get(0,'defaultUicontrolBackgroundColor'))
    
    set(hObject,'BackgroundColor','white');
    
end

function TextBox_max_Iterationen_Callback(hObject, eventdata, handles)

% Variablendeklaration (globalLink)
global max_Iter;

%  Kontrolle der Eingabe und Übergabe
if isnan(str2double(get(hObject,'string')))                                 %ist Eingabe in double-Format konvertierbar?
    
    set(handles.TextBox_max_Iterationen,'string',num2str(max_Iter));        %Wert zurücksetzen
    mb = msgbox('Falsche oder ungültige Eingabe der maximalen Anzahl an Iterationen.');
    return;

else
    
    max_Iter = uint16(str2double(get(hObject,'string')));                   %in Integer (16 bit) umwandeln
    set(handles.TextBox_max_Iterationen,'string',num2str(max_Iter));        %(umgewandelten) Wert einsetzen

end

function TextBox_max_Iterationen_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'),...
                                  get(0,'defaultUicontrolBackgroundColor'))
    
    set(hObject,'BackgroundColor','white');
    
end

function TextBox_Kugelanzahl_n_Callback(hObject, eventdata, handles)

% Variablendeklaration (globalLink)
global n;

%  Kontrolle der Eingabe und Übergabe
if isnan(str2double(get(hObject,'string')))                                 %ist Eingabe in double-Format konvertierbar?
 
    set(handles.TextBox_Kugelanzahl_n,'string',num2str(n));                 %Wert zurücksetzen
    mb = msgbox('Falsche oder ungültige Eingabe der Kugelanzahl n.');
    return;

else
    
    n = uint16(str2double(get(hObject,'string')));                          %in Integer (16 bit) umwandeln
    set(handles.TextBox_Kugelanzahl_n,'string',num2str(n));                 %(umgewandelten) Wert einsetzen

end

function TextBox_Kugelanzahl_n_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), ...
                                  get(0,'defaultUicontrolBackgroundColor'))
    
                              set(hObject,'BackgroundColor','white');

end
