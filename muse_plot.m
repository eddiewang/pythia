function varargout = muse_plot(varargin)
% MUSE_PLOT MATLAB code for muse_plot.fig
%       Thrasyvoulos Karydis
%       02/19/2016
%       (c) Massachusetts Institute of Technology 2015
%       Permission granted for experimental and personal use;
%       license for commercial sale available from MIT
%
%       Plotting streaming data from muse and classifying on the fly

% Begin initialization code
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @muse_plot_OpeningFcn, ...
                   'gui_OutputFcn',  @muse_plot_OutputFcn, ...
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

% --- Executes just before muse_plot is made visible.
function muse_plot_OpeningFcn(hObject, ~, handles, ~)
tic ;
try
    parpool('local',2);
catch
    delete(gcp('nocreate'));
    parpool('local',2);
end
p = gcp();
parfeval(p, @ServerParser, 0)

% Choose default command line output for muse_plot
handles.output = hObject;

% Plotting background image
% create an axes that spans the whole GUI
handles.axes_cover = axes('unit', 'normalized', 'position', [0 0 1 1]);
% import the background image and show it on the axes
imraw = imread('brain.jpg'); 
set(hObject,'unit','pixel');
pos=get(hObject,'position');
imfit=imresize(imraw,[pos(end) pos(end-1)]);
imagesc(imfit);
% prevent plotting over the background and turn the axis off
set(handles.axes_cover,'handlevisibility','off','visible','off')
% set axes_cover behind all the other uicontrols
uistack(handles.axes_cover, 'bottom');

handles.title = text(500,550,'MIT CBA EEG Demo v0.1','backgroundcolor','none', ...
                    'Units','pixels', ...
                    'parent',handles.axes_cover, ...
                    'FontSize',60, ...
                    'FontAngle', 'normal', ...
                    'FontWeight', 'bold', ...
                    'FontName','Chalkduster', ...
                    'color','White',...
                    'HorizontalAlignment','center');
                
% Parameters
handles.server_buff = 'muse_values.mat';
handles.muse_port = 8000;
handles.nsec = 10;
handles.readprd = 0.3;         % update frequency from the file
handles.plotprd = 0.3;         %update the tech chart and update the data

%Muse configuration
handles.EEG_sample_freq = 220;
handles.bndpwr_freq = 10;

% Storage Variables
handles.EEG   = zeros(4,1);
handles.alpha = zeros(4,1);
handles.beta  = zeros(4,1);
handles.gamma = zeros(4,1);
handles.delta = zeros(4,1);
handles.theta = zeros(4,1);
handles.horseshoe = zeros(4,1);
handles.labels = 0;
handles.classind = 0;

%Storage Parameters
handles.max_EEG_len  = handles.EEG_sample_freq * 100;
handles.max_freq_len = handles.bndpwr_freq * 100;


handles.trained = 0;

% Plotting
%EEG
% handles.EEGbuffer   = zeros(4,handles.nsec*handles.EEG_sample_freq);
% handles.EEGPlot     = plot(handles.EEGAxes  ,mean(handles.EEGbuffer,1));
% set(handles.EEGAxes    ,'Xtick',[],'Ytick',[]);
% set(handles.EEGAxes    ,'XLim',[0 handles.nsec*handles.EEG_sample_freq]);

handles.labelbuffer = zeros(1,10);

%--------------------%
%- Training Timings -%
%--------------------%

% kNN Classifier
% GUI :    Start   |   Relax    | Put your hand in ice | train
% Time:     ------><------------><--------------------->
% Vars:    UNKOWNN   relax_time        ice_time
% Stat:   
handles.relax_time = 20 ; % set to 20

%----------%
%- Timers -%
%----------%
handles.timers_activated = 0;

% Create a timer object to read data from the muse
handles.read_timer = timer(...
    'ExecutionMode', 'fixedRate'    , ...
    'BusyMode'     , 'queue'        , ...
    'Period'       , handles.readprd, ...                     
    'TimerFcn', {@read_data,hObject});  %Passing hObject as data 

% Create a timer object to update the plot
handles.plot_timer = timer(...
    'ExecutionMode', 'fixedRate'    , ...
    'BusyMode'     , 'drop'        , ...      
    'Period'       , handles.plotprd, ...                       
    'TimerFcn', {@update_plot,hObject}); %Passing hObject as data

% Relaxation state, collect negative values
handles.relax_timer = timer(...
    'ExecutionMode' , 'singleShot'    , ...
    'BusyMode'      , 'queue'         , ...      
    'StartDelay'    , handles.relax_time, ...                       
    'TimerFcn', {@relax_callback,hObject}); %Passing hObject as data

% Hand in ice state, wait until button pressed
handles.ice_timer = timer(...
    'ExecutionMode', 'singleShot'    , ...
    'BusyMode'     , 'queue'        , ...  
    'StartDelay'    , 8, ...    
    'TimerFcn', {@ice_callback,hObject}); %Passing hObject as data

disp 'Initialized';
toc
guidata(hObject,handles);
start_timers(hObject);

function start_timers(hObject)

handles = guidata(hObject);

while (strcmp(get(handles.read_timer, 'Running'), 'off')|| ...
       strcmp(get(handles.plot_timer, 'Running'), 'off'))
    try        
        if strcmp(get(handles.read_timer, 'Running'), 'off')
            start(handles.read_timer);       
        end
    catch
         warning('Could not start timer read timer')
    end
    try
        if strcmp(get(handles.plot_timer, 'Running'), 'off')
            start(handles.plot_timer);
        end
    catch
        warning('Could not start plot timer')
    end 
end
handles.timers_activated = 1;
% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = muse_plot_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;   

function read_data(~,~,hfigure)
% Callback function for read_timer
handles = guidata(hfigure);
try
    if (exist(handles.server_buff,'file'))
        while (movefile(handles.server_buff,'destination_delete.mat')==0)
            %disp('File in use!');
        end
        %disp('OK to proceed!');
        load ('destination_delete.mat','data');
    else
        %disp 'nothing to read'
        return
    end
catch 
    disp 'Error trying to read from file'
    return
end
                
for j=1:size(data,2)  %#ok<USENS>
    switch data{j}.path 
        case '/EEG'
            values = [data{j}.data{1}; ...
                   data{j}.data{2}; ...
                   data{j}.data{3}; ...
                   data{j}.data{4}]; 
            handles.EEG = [handles.EEG values];   
%             handles.EEGbuffer = [handles.EEGbuffer(:,2:end) values];
        case '/DELTA_ABSOLUTE'
            values = [data{j}.data{1}; ...
                   data{j}.data{2}; ...
                   data{j}.data{3}; ...
                   data{j}.data{4}];
            handles.delta = [handles.delta values];
        case '/ALPHA_ABSOLUTE'
            values = [data{j}.data{1}; ...
                   data{j}.data{2}; ...
                   data{j}.data{3}; ...
                   data{j}.data{4}]; 
            handles.alpha = [handles.alpha values];
        case '/BETA_ABSOLUTE'
            values = [data{j}.data{1}; ...
                   data{j}.data{2}; ...
                   data{j}.data{3}; ...
                   data{j}.data{4}]; 
            handles.beta = [handles.beta values];
        case '/GAMMA_ABSOLUTE'
            values = [data{j}.data{1}; ...
                   data{j}.data{2}; ...
                   data{j}.data{3}; ...
                   data{j}.data{4}];
            handles.gamma = [handles.gamma values];
        case '/THETA_ABSOLUTE'    
            values = [data{j}.data{1}; ...
                   data{j}.data{2}; ...
                   data{j}.data{3}; ...
                   data{j}.data{4}]; 
            handles.theta = [handles.theta values];
        case '/HORSESHOE'    
            values = [data{j}.data{1}; ...
                   data{j}.data{2}; ...
                   data{j}.data{3}; ...
                   data{j}.data{4}]; 
            handles.horseshoe = values;
        otherwise
    end    
end
%all the data must have the same length
if (length(handles.alpha)~=length(handles.beta))||...
    (length(handles.alpha)~=length(handles.gamma))||...
    (length(handles.alpha)~=length(handles.delta))||...
    (length(handles.alpha)~=length(handles.theta))
   disp('Data Lengths are not the same')
end

for n = 1:size(handles.alpha,2)-size(handles.labels,2)
    strlabel = label_state(handles,n);

    if strcmp(strlabel,'pain')
        label = 1;
    else
        label=0;
    end
%     handles.labels = [handles.labels label];
    handles.labelbuffer = [handles.labelbuffer(:,2:end) label];
    
    handles.classind = handles.classind + 1;    
end

%discard unecessary data
if length(handles.alpha)>handles.max_freq_len
    handles.alpha=handles.alpha(:,end-handles.max_freq_len:end);
    handles.beta=handles.beta(:,end-handles.max_freq_len:end);
    handles.delta=handles.delta(:,end-handles.max_freq_len:end);
    handles.gamma=handles.gamma(:,end-handles.max_freq_len:end);
    handles.theta=handles.theta(:,end-handles.max_freq_len:end);
    
end

if length(handles.labels)>handles.max_freq_len
    handles.labels=handles.labels (:,end-handles.max_freq_len:end);
end

if length(handles.EEG)>handles.max_EEG_len
    handles.EEG=handles.EEG(:,end-handles.max_EEG_len:end);
end

guidata(hfigure,handles)

% Callback function for plot_timer
function update_plot(~,~,hfigure) 

handles = guidata(hfigure);
 
try
    % Update connection indicators
    set(handles.sensors,'String', sprintf('Sensors: %i %i %i %i',handles.horseshoe(1,1),handles.horseshoe(2,1),handles.horseshoe(3,1),handles.horseshoe(4,1)));
    
    % Update datestring
    set(handles.text27,'String',datestr(now, 'HH:MM:SS')); 
    
    % set(handles.EEGPlot,'YData',handles.EEGbuffer);
    if (histc(handles.labelbuffer,0) > histc(handles.labelbuffer,1))  
        set(handles.statetxt,'String','no pain');
    else
        set(handles.statetxt,'String','pain');
    end
%     display(handles.labelbuffer)

    
catch exception
    disp('Error in updating the plot')
    getReport(exception)
end

% --- Executes on button press in Start Streaming.
function pushStartButton_Callback(hObject , ~, handles)   %#ok<DEFNU>

set(hObject,'Units','Pixels');
disp 'Started Calibration'

handles = reset_data(handles);


handles.prompt = text(500,460,'Relax...','backgroundcolor','none', ...
            'Units','pixels', ...
            'parent', handles.axes_cover, ...
            'FontSize',60, ...
            'FontAngle', 'italic', ...
            'FontWeight', 'bold', ...
            'FontName','Monotype Corsiva', ...
            'color','white', ...
            'HorizontalAlignment','center');
handles.statetxt.Visible = 'off';
hObject.Visible = 'Off';
pos = get(hObject,'Position');
set(hObject, 'Position',[pos(1) 44 pos(3) pos(4)],'String','Repeat Calibration','HorizontalAlignment','center');
set(handles.sensors,'Position',[3.142 1.667 21.571 1.6]);

try
    if strcmp(get(handles.relax_timer, 'Running'), 'off')
        start(handles.relax_timer);
    end
catch
    warning('Could not start plot timer')
end 
guidata(hObject,handles);
 
% --- Relax time
function relax_callback(~,~,hfigure)
handles = guidata(hfigure);

disp 'Collecting no pain states ...'

set(handles.prompt,'Visible','off');
handles.prompt1 = text(500,460,'Put your hand in the cold water ...','backgroundcolor','none', ...
                    'Units','pixels', ...
                    'parent', handles.axes_cover, ...
                    'FontSize',60, ...
                    'FontAngle', 'italic', ...
                    'FontWeight', 'bold', ...
                    'FontName','Monotype Corsiva', ...
                    'color','white', ...
                    'HorizontalAlignment','center');
                
handles.prompt2 = text(500, 200,'and remove it when unbearable.','backgroundcolor','none', ...
                    'Units','pixels', ...
                    'parent', handles.axes_cover, ...
                    'FontSize',60, ...
                    'FontAngle', 'italic', ...
                    'FontWeight', 'bold', ...
                    'FontName','Monotype Corsiva', ...
                    'color','white', ...
                    'HorizontalAlignment','center');
                
                
guidata(hfigure,handles) %save the reset features
start(handles.ice_timer);

% --- Ice time
function ice_callback(~,~,hfigure)
handles = guidata(hfigure);

disp 'Calibration data collected, training ...'

handles.pushbutton8.Visible = 'On';
 
guidata(hfigure,handles);

% --- Executes on button press Hand removed
function pushbutton8_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hObject.Visible = 'Off';
handles.prompt1.Visible = 'Off';
handles.prompt2.Visible = 'Off';

handles.prompt = text(500, 300,'Calibrating ...','backgroundcolor','none', ...
                    'Units','pixels', ...
                    'parent', handles.axes_cover, ...
                    'FontSize',60, ...
                    'FontAngle', 'italic', ...
                    'FontWeight', 'bold', ...
                    'FontName','Monotype Corsiva', ...
                    'color','white', ...
                    'HorizontalAlignment','center');

handles = train_knn_classifier(handles);

handles.trained = 1;

handles.prompt.Visible = 'off';

handles.statetxt.Visible = 'on';

handles.pushbutton1.Visible = 'on';

guidata(hObject,handles);

function new_handles=train_knn_classifier(handles,~)
disp 'Training the knn model';

f = struct('alpha', handles.alpha, ...
            'beta', handles.beta, ...
           'delta', handles.delta, ...
           'theta', handles.theta, ...
           'gamma', handles.gamma, ...
       'horseshoe', handles.horseshoe, ...
       'markers_t', handles.relax_time,...
        'alpha_t',(1:length(handles.alpha))/handles.bndpwr_freq);
 display(f.alpha_t)
handles.kNNClassifier = train_kNNClassifier2(f,'verbose'); 

handles.trained = 1;
new_handles=handles;

function label=label_state(handles,index)
try
    if handles.trained == 1
        f = zscore([handles.alpha(3,index) ; ...
                    handles.beta(1:2,index)  ; ...
                    handles.gamma(1:3,index) ; ...
                    handles.theta(1,index)]);
        [label,~] = predict(handles.kNNClassifier,f');
    else
        label = 'unknown';
    end
catch exception
    getReport(exception)
    disp([size(handles.alpha);size(handles.beta);size(handles.gamma);size(handles.delta);size(handles.theta)]');
    fprintf('Value handles.classind %i\n',handles.index);
end
 
% --- RESETS data
function new_handles = reset_data(handles)

handles.EEG     = zeros(4,1);
handles.alpha   = zeros(4,1);
handles.beta    = zeros(4,1);
handles.gamma   = zeros(4,1);
handles.delta   = zeros(4,1);
handles.theta   = zeros(4,1);
handles.horseshoe = zeros(4,1);
% handles.labels = 0;
handles.trained = 0;
handles.classind = 0;

new_handles = handles;
% handles.EEGbuffer   = zeros(4,handles.nsec*handles.EEG_sample_freq);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, ~, handles)  %#ok<DEFNU>

try
    delete(gcp('nocreate'));
    while strcmp(get(handles.read_timer, 'Running'), 'on')
        stop(handles.read_timer);
    end
    while strcmp(get(handles.plot_timer, 'Running'), 'on')
        stop(handles.plot_timer);
    end
catch
    warning('Could not delete timers')
end
delete(hObject);


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(~, ~, ~) %#ok<DEFNU>
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
