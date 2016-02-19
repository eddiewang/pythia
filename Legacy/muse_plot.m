function varargout = muse_plot(varargin)
% MUSE_PLOT MATLAB code for muse_plot.fig
%       Thrasyvoulos Karydis
%       04/15/2015
%       (c) Massachusetts Institute of Technology 2015
%       Permission granted for experimental and personal use;
%       license for commercial sale available from MIT
%
%       Plotting streaming data from muse and classifying on the fly

% Begin initialization code - DO NOT EDIT
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
% Choose default command line output for muse_plot
handles.output = hObject;

% Plotting background
% create an axes that spans the whole GUI
axes_cover = axes('unit', 'normalized', 'position', [0 0 1 1]);
% import the background image and show it on the axes
imraw = imread('bluehead.jpg'); 
set(hObject,'unit','pixel');
pos=get(hObject,'position');
imfit=imresize(imraw,[pos(end) pos(end-1)]);
imagesc(imfit);
% prevent plotting over the background and turn the axis off
set(axes_cover,'handlevisibility','off','visible','off')
% set axes_cover behind all the other uicontrols
uistack(axes_cover, 'bottom');


% Parameters
handles.server_buff = 'muse_values.mat';
handles.muse_port = 8000;
handles.client_port = 8001;
handles.nsec = 10;
handles.readprd = 0.3;         % update frequency from the file
handles.plotprd = 0.3;         %update the tech chart and update the data
handles.plotrefresh_rate=0.2;  %update balls drawings

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

%Storage Parameters
handles.max_EEG_len  = handles.EEG_sample_freq * 20;
handles.max_freq_len = handles.bndpwr_freq * 20;


handles.classind = 1;

% Plotting
%EEG
handles.EEGbuffer   = zeros(4,handles.nsec*handles.EEG_sample_freq);
handles.EEGPlot     = plot(handles.EEGAxes  ,handles.EEGbuffer(1,:));
set(handles.EEGAxes    ,'Xtick',[],'Ytick',[]);
set(handles.EEGAxes    ,'XLim',[0 handles.nsec*handles.EEG_sample_freq]);
%alpha
handles.alphabuffer = zeros(4,handles.nsec*handles.bndpwr_freq);
handles.alphaPlot   = plot(handles.alphaAxes,handles.alphabuffer(1,:),'r');
set(handles.alphaAxes  ,'Xtick',[],'Ytick',[]);
set(handles.alphaAxes  ,'XLim',[0 handles.nsec*handles.bndpwr_freq]);
set(handles.alphaAxes  ,'YLim',[-0.5 1.5]);
%beta
handles.betabuffer  = zeros(4,handles.nsec*handles.bndpwr_freq);
handles.betaPlot    = plot(handles.betaAxes ,handles.betabuffer(1,:),'g');
set(handles.betaAxes   ,'Xtick',[],'Ytick',[]);
set(handles.betaAxes   ,'XLim',[0 handles.nsec*handles.bndpwr_freq]);
set(handles.betaAxes   ,'YLim',[-0.5 1.5]);
%gamma
handles.gammabuffer = zeros(4,handles.nsec*handles.bndpwr_freq);
handles.gammaPlot   = plot(handles.gammaAxes ,handles.gammabuffer(1,:),'b');
set(handles.gammaAxes    ,'Xtick',[],'Ytick',[]);
set(handles.gammaAxes   ,'XLim',[0 handles.nsec*handles.bndpwr_freq]);
set(handles.gammaAxes  ,'YLim',[-0.5 1.5]);
%delta
handles.deltabuffer = zeros(4,handles.nsec*handles.bndpwr_freq);
handles.deltaPlot    = plot(handles.deltaAxes ,handles.deltabuffer(1,:),'m');
set(handles.deltaAxes    ,'Xtick',[],'Ytick',[]);
set(handles.deltaAxes   ,'XLim',[0 handles.nsec*handles.bndpwr_freq]);
set(handles.deltaAxes  ,'YLim',[-0.5 1.5]);
%theta
handles.thetabuffer = zeros(4,handles.nsec*handles.bndpwr_freq);
handles.thetaPlot    = plot(handles.thetaAxes ,handles.thetabuffer(1,:),'Color',[1 .5 0]);
set(handles.thetaAxes    ,'Xtick',[],'Ytick',[]);
set(handles.thetaAxes   ,'XLim',[0 handles.nsec*handles.bndpwr_freq]);
set(handles.thetaAxes  ,'YLim',[-0.5 1.5]);

%---------------%
%- Ball Figure -%
%---------------%
handles.fig_ball.fig = figure;
handles.ball.axs = axes('Parent',handles.fig_ball.fig);
handles.ball.forceup=0;
%Declaring ball's initial condition
handles.ball.initpos=50;     %Ball's initial vertical position
handles.ball.initvel=0;      %Ball's initial vertical velocity
%Declaring environmental variable
handles.ball.r_ball=5;       %Ball's radius
handles.ball.gravity=10;     %Gravity's acceleration
handles.ball.c_bounce=1;     %Bouncing's coefficient of elasticity
%Declaring animation timestep
handles.ball.dt=handles.plotrefresh_rate; %0.125;      %Animation timestep
%Initiating figure, axes, and objects for animation

handles.ball.ball=rectangle('Position',[-handles.ball.r_ball,handles.ball.initpos,handles.ball.r_ball,handles.ball.r_ball],...
               'Curvature',[1,1],...
               'FaceColor','b',...
               'Parent',handles.ball.axs);
handles.ball.ball2=rectangle('Position',[-handles.ball.r_ball,handles.ball.initpos,handles.ball.r_ball,handles.ball.r_ball],...
               'Curvature',[1,1],...
               'FaceColor','b',...
               'Parent',handles.ball.axs);

handles.ball.annotation=annotation('textbox',...
        [0.3,0.9,0.4,0.1],...
       'String', 'THINK UP!!!',...
       'Horizontalalignment', 'center',...
       'Visible', 'off');

line([-5*handles.ball.r_ball,5*handles.ball.r_ball],...
     [0,0],...
     'Parent',handles.ball.axs);
%Executing animation
handles.ball.pos=handles.ball.initpos-handles.ball.r_ball;             %Ball's current vertical position
handles.ball.vel=handles.ball.initvel;                    %Ball's current vertical velocity
handles.ball.play=true;                      %Current animation status
handles.ball.pos2=0;     
%initial nice look
axis(handles.ball.axs,[-5*handles.ball.r_ball,5*handles.ball.r_ball,0,handles.ball.initpos+2*handles.ball.r_ball]);
axis(handles.ball.axs,'equal');
axis(handles.ball.axs,'off');

%---------------------%
%- Live Scatter Plot -%
%---------------------%
%set(handles.axes9,'XLim',[-0.5 1.5],'YLim',[-0.5 1.5]);
set(handles.axes9   ,'Xtick',[],'Ytick',[]);


% Classifiers Initializations
handles.classifier_tag='mean';

handles.meanC.center = zeros(5,1);  %20/
handles.meanC.radius = zeros(5,1);  %20/

handles.labelbuffer = zeros(1,handles.nsec*handles.bndpwr_freq);

%--------------------%
%- Training Timings -%
%--------------------%

% UP-Mean Classifier
% GUI :            |Set Rfst  | THINK UP
% Time:     ------><---------><---------------->
% Vars:    UNKOWNN  delayprd     up_duration
handles.max_rnd_delay = 5;
handles.delayprd = randi(handles.max_rnd_delay,1);
handles.up_duration = 3;     %Up state data collection (& THINK up display)
handles.nUp_data = handles.bndpwr_freq * handles.up_duration;

% kNN Classifier
% GUI :            |Set Rfst  | THINK UP
% Time:     ------><---------><---------------->
% Vars:    UNKOWNN  delayprd     up_duration
% Stat:     

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

% Create a timer object to refresh the ball figure
handles.plot_timer_refresh_rate = timer(...
    'ExecutionMode', 'fixedRate'    , ...
    'BusyMode'     , 'queue'        , ...      
    'Period'       , handles.plotrefresh_rate, ...                       
    'TimerFcn', {@update_ball_figure,hObject}); %Passing hObject as data

% Delay between pressing "Set Ref State" and display of "Think UP"
handles.delay_train = timer(...
    'ExecutionMode' , 'singleShot'    , ...
    'BusyMode'      , 'queue'         , ...      
    'StartDelay'    , handles.delayprd, ...                       
    'TimerFcn', {@rnd_delay_t_callback,hObject}); %Passing hObject as data

% Delay for data gatherin for classification
handles.delay_train2 = timer(...
    'ExecutionMode', 'singleShot'    , ...
    'BusyMode'     , 'queue'        , ...      
    'StartDelay'   , handles.up_duration, ...                       
    'TimerFcn', {@gather_t_callback,hObject}); %Passing hObject as data

disp 'Initialized';
toc
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
    
new_entries=0;
            
for j=1:size(data,2)  %#ok<USENS>
    switch data{j}.path 
        case '/EEG'
            values = [data{j}.data{1}; ...
                   data{j}.data{2}; ...
                   data{j}.data{3}; ...
                   data{j}.data{4}]; 
            handles.EEG = [handles.EEG values];   
            handles.EEGbuffer = [handles.EEGbuffer(:,2:end) values];
        case '/DELTA_ABSOLUTE'
            values = [data{j}.data{1}; ...
                   data{j}.data{2}; ...
                   data{j}.data{3}; ...
                   data{j}.data{4}];
            handles.delta = [handles.delta values];
            handles.deltabuffer = [handles.deltabuffer(:,2:end) values];
        case '/ALPHA_ABSOLUTE'
            values = [data{j}.data{1}; ...
                   data{j}.data{2}; ...
                   data{j}.data{3}; ...
                   data{j}.data{4}]; 
            handles.alpha = [handles.alpha values];
            handles.alphabuffer = [handles.alphabuffer(:,2:end) values];
            new_entries=new_entries+1;
        case '/BETA_ABSOLUTE'
            values = [data{j}.data{1}; ...
                   data{j}.data{2}; ...
                   data{j}.data{3}; ...
                   data{j}.data{4}]; 
            handles.beta = [handles.beta values];
            handles.betabuffer = [handles.betabuffer(:,2:end) values];
        case '/GAMMA_ABSOLUTE'
            values = [data{j}.data{1}; ...
                   data{j}.data{2}; ...
                   data{j}.data{3}; ...
                   data{j}.data{4}];
            handles.gamma = [handles.gamma values];
            handles.gammabuffer = [handles.gammabuffer(:,2:end) values];
        case '/THETA_ABSOLUTE'    
            values = [data{j}.data{1}; ...
                   data{j}.data{2}; ...
                   data{j}.data{3}; ...
                   data{j}.data{4}]; 
            handles.theta = [handles.theta values];
            handles.thetabuffer = [handles.thetabuffer(:,2:end) values];
        case '/HORSESHOE'    
            values = [data{j}.data{1}; ...
                   data{j}.data{2}; ...
                   data{j}.data{3}; ...
                   data{j}.data{4}]; 
            handles.horseshoe = values;
            handles.thetabuffer = [handles.thetabuffer(:,2:end) values];
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
    handles.labels = [handles.labels label];
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
    handles.labels= handles.labels (:,end-handles.max_freq_len:end);
end

if length(handles.EEG)>handles.max_EEG_len
    handles.EEG=handles.EEG(:,end-handles.max_EEG_len:end);
end

guidata(hfigure,handles)

%shows the inducation signal and exit
function rnd_delay_t_callback(~,~,hfigure)
handles = guidata(hfigure);

disp 'Calibration Listening'

% THINK UP annotation
set(handles.ball.annotation,'visible','on');

% Uknown state indicator
set(handles.statetxt  ,'String','X');

%guidata(hfigure,handles) %save the reset features
start(handles.delay_train2);


%disables the induction signal, calculates the mean values exits
function gather_t_callback(~,~,hfigure)
handles = guidata(hfigure);
disp 'Calibration data collected, training ...'

% Remove THINK UP sign
set(handles.ball.annotation,'visible','off');

% Force the ball to go up
handles.ball.forceup=20;

switch handles.classifier_tag
    case 'mean'
        handles = train_mean_classifier(handles);
    case 'knn'
        handles = train_knn_classifier(handles);
    otherwise
        disp('Classifier not specified');       
end

set(handles.pbCalibration,'String','Start Calibration','Enable','on');
guidata(hfigure,handles);


function new_handles = train_mean_classifier(handles)
disp 'UP-Mean NonZero-Power Training'

% all
% handles.meanC.train_set =[handles.alpha(:,end-handles.nUp_data:end); ...
%                           handles.beta(:,end-handles.nUp_data:end);  ...
%                           handles.delta(:,end-handles.nUp_data:end); ...
%                           handles.gamma(:,end-handles.nUp_data:end); ...
%                           handles.theta(:,end-handles.nUp_data:end)];

% mean per band
nzmean_alpha = sum(handles.alpha(:,end-handles.nUp_data:end))./ ...
               sum(handles.alpha(:,end-handles.nUp_data:end)~=0);
nzmean_beta = sum(handles.beta(:,end-handles.nUp_data:end))./ ...
               sum(handles.beta(:,end-handles.nUp_data:end)~=0);
nzmean_gamma = sum(handles.gamma(:,end-handles.nUp_data:end))./ ...
               sum(handles.gamma(:,end-handles.nUp_data:end)~=0);
nzmean_delta = sum(handles.delta(:,end-handles.nUp_data:end))./ ...
               sum(handles.delta(:,end-handles.nUp_data:end)~=0);
nzmean_theta = sum(handles.theta(:,end-handles.nUp_data:end))./ ...
               sum(handles.theta(:,end-handles.nUp_data:end)~=0);
           
handles.meanC.train_set =  [nzmean_alpha    ; ...
                            nzmean_beta     ; ...
                            nzmean_gamma    ; ...
                            nzmean_delta    ; ...
                            nzmean_theta ];
                        
handles.meanC.center   = mean(handles.meanC.train_set,2); %nonzero
handles.meanC.radius   = std(handles.meanC.train_set,[],2); 

new_handles=handles;


function new_handles=train_knn_classifier(handles,~)
disp 'Training the knn model';

f = struct('alpha', handles.alpha, ...
            'beta', handles.beta, ...
           'delta', handles.delta, ...
           'theta', handles.theta, ...
           'gamma', handles.gamma, ...
       'horseshoe', handles.horseshoe, ...
       'markers_t',handles.up_duration,...
        'alpha_t',(1:length(handles.alpha))/handles.bndpwr_freq);
    
handles.kNNClassifier = train_kNNClassifier2(f,'verbose'); 

%handles.kNNClassifier = load('andreas_pain_class','kNNClassifier');
 
new_handles=handles;
return 


function label=label_state(handles,index)
switch handles.classifier_tag
    case 'mean'
        label = label_state_Mean_Classifier(handles,index);
    case 'knn'
        label = label_state_knn(handles,index);
    otherwise
        disp('Unknown classifier');       
end


function label_state=label_state_knn(handles,index)

try
    if exist('handles.kNNClassifier','var')
        f = zscore([handles.alpha(3,index) ; ...
                    handles.beta(1:2,index)  ; ...
                    handles.gamma(1:3,index) ; ...
                    handles.theta(1,index)]);
        [label_state,~] = predict(handles.kNNClassifier,f');
    else
        label_state = 'unknown';
    end
catch exception
    getReport(exception)
    disp([size(handles.alpha);size(handles.beta);size(handles.gamma);size(handles.delta);size(handles.theta)]');
    fprintf('Value handles.classind %i\n',handles.index);
end


function label_state=label_state_Mean_Classifier(handles,index)  
multiplier = get(handles.slider3,'Value');

% all
% state = [handles.alpha(:,index);...
%         handles.beta(:,index);...
%         handles.delta(:,index);...
%         handles.gamma(:,index);...
%         handles.theta(:,index)];      

% mean per band
state = [mean(nonzeros(handles.alpha(:,index)));...
         mean(nonzeros(handles.beta(:,index)));...
         mean(nonzeros(handles.delta(:,index)));...
         mean(nonzeros(handles.gamma(:,index)));...
         mean(nonzeros(handles.theta(:,index)))]; 

if norm(state-handles.meanC.center) < multiplier*norm(handles.meanC.radius)
   label_state = 'pain';
else
   label_state = 'no pain';
end
% norm(handles.meanC.center)
% norm(handles.meanC.radius)
% label_state


%average time to plot 0.07s
function update_ball_figure(~,~,hfigure)
handles = guidata(hfigure);
%figure (handles.fig_ball.fig);
%Declaring time counter        
%Updating ball's condition  
in_state=handles.labelbuffer(end);
if (handles.ball.forceup)
    in_state=1;
    handles.ball.forceup=handles.ball.forceup-1;
end
%in_state=1;
if (in_state)
   color='r';
else
   color='b';
end

handles.ball.pos2=handles.ball.pos2+(in_state*2-1)*2;
if handles.ball.pos2>50
    handles.ball.pos2=50;      %Ball's current vertical velocity
end
if handles.ball.pos2<0
    handles.ball.pos2=0;      %Ball's current vertical velocity
end
%handles.ball.pos2=0;

%Updating ball
%add noise to the ball position
 set(handles.ball.ball2,'Position',[...
    -handles.ball.r_ball+rand*1 ...
    ,handles.ball.pos2+rand*1.5 ...
    ,handles.ball.r_ball ...
    ,handles.ball.r_ball]...
    ,'FaceColor',color ...
);

%to remove together with ball1    
set(handles.ball.ball,'Position',[...
    -handles.ball.r_ball ...
    ,100 ...
    ,handles.ball.r_ball ...
    ,handles.ball.r_ball]...
    ,'FaceColor',color ...
);

axis(handles.ball.axs,[-5*handles.ball.r_ball,5*handles.ball.r_ball,0,handles.ball.initpos+2*handles.ball.r_ball]);
axis(handles.ball.axs,'equal');
axis(handles.ball.axs,'off');
drawnow
guidata(hfigure,handles);
                     

function update_plot(~,~,hfigure) 
% Callback function for plot_timer
handles = guidata(hfigure);
 
try
    set(handles.EEGPlot   ,'YData',handles.EEGbuffer(1,:));
    set(handles.alphaPlot ,'YData',handles.alphabuffer(1,:));
    set(handles.betaPlot  ,'YData',handles.betabuffer(1,:));
    set(handles.gammaPlot ,'YData',handles.gammabuffer(1,:));
    set(handles.deltaPlot ,'YData',handles.deltabuffer(1,:));
    set(handles.thetaPlot ,'YData',handles.thetabuffer(1,:));
    
    if strcmp(get(handles.delay_train, 'Running'), 'off')
        if strcmp(get(handles.delay_train2, 'Running'), 'off')
            set(handles.statetxt  ,'String',handles.labelbuffer(end));
        end
    end
    
    
    set(handles.text26,'String', sprintf('Sensors: %i %i %i %i',handles.horseshoe(1,1),handles.horseshoe(2,1),handles.horseshoe(3,1),handles.horseshoe(4,1)));
     
    set(handles.text27,'String',datestr(now, 'HH:MM:SS'));  
    
    %updating circular plot
    if strcmp(handles.classifier_tag,'mean')&&strcmp(get(handles.axes9,'Visible'),'on')                
         
         mean_alpha_scatter = sum(handles.alphabuffer,1)./sum(handles.alphabuffer~=0,1);
         mean_beta_scatter  = sum(handles.betabuffer,1)./sum(handles.betabuffer~=0,1);
         multiplier = get(handles.slider3,'Value');
         
         hold(handles.axes9,'on') ;
         cla(handles.axes9);
         %plot(handles.axes9,mean_alpha_scatter(end-20:end),mean_beta_scatter(end-20:end),'b.');  
         plot(handles.axes9,handles.alphabuffer(1,end-20:end),handles.betabuffer(1,end-20:end),'bx');
         r = multiplier*sqrt(handles.meanC.radius(1)^2 + handles.meanC.radius(5)^2);
         x = handles.meanC.center(1);
         y = handles.meanC.center(5);
         viscircles(handles.axes9,[x y],r,'EdgeColor','r');
         drawnow
         hold(handles.axes9,'off')  ;        
    end

catch exception
    disp('Error in updating the plot')
    getReport(exception)
end


% --- Executes on button press in Start Streaming.
function pushStartButton_Callback(hObject , ~, handles)   %#ok<DEFNU>

if (handles.timers_activated == 0) 
    while (strcmp(get(handles.read_timer, 'Running'), 'off')|| ...
           strcmp(get(handles.plot_timer, 'Running'), 'off')|| ...
           strcmp(get(handles.plot_timer_refresh_rate, 'Running'), 'off'))
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
        try        
            if strcmp(get(handles.plot_timer_refresh_rate, 'Running'), 'off')
                start(handles.plot_timer_refresh_rate);

            end
        catch
             warning('Could not start timer read timer')
        end
    end
    handles.timers_activated = 1;
    set(hObject,'String','Stop');
    set(handles.pbCalibration,'Enable','on');
    disp 'Started timers'
else
    try    
        while strcmp(get(handles.read_timer, 'Running'), 'on')
            stop(handles.read_timer);
        end
    catch
         warning('Could not stop read timer')
    end
    
    try        
        while strcmp(get(handles.plot_timer_refresh_rate, 'Running'), 'on')
            stop(handles.plot_timer_refresh_rate);            
        end
    catch
         warning('Could not start timer read timer')
    end
    
    try
        while strcmp(get(handles.plot_timer, 'Running'), 'on')
            stop(handles.plot_timer);
        end
    catch
        warning('Could not stop timer plot timer')    
    end
    handles.timers_activated = 0;
    set(hObject,'String','Restart');
    set(handles.pbCalibration,'Enable','off');
    disp 'Stoped Timers'
end
guidata(hObject,handles);
    

% --- Executes on button press in pbCalibration.
function pbCalibration_Callback(~, ~, handles) %#ok<DEFNU>

set(handles.pbCalibration, 'String', 'Calibrating', 'Enable','off');

set(handles.statetxt  ,'String', 'X');

try
    if strcmp(get(handles.delay_train, 'Running'), 'off')
        start(handles.delay_train);
    end
catch
    warning('Could not start timer read timer')
end
   

% --- RESETS data
function pushbutton2_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.EEG     = zeros(4,1);
handles.alpha   = zeros(4,1);
handles.beta    = zeros(4,1);
handles.gamma   = zeros(4,1);
handles.delta   = zeros(4,1);
handles.theta   = zeros(4,1);
handles.horseshoe = zeros(4,1);
handles.labels = 0;
handles.classind = 1;

handles.EEGbuffer   = zeros(4,handles.nsec*handles.EEG_sample_freq);
handles.alphabuffer = zeros(4,handles.nsec*handles.bndpwr_freq);
handles.betabuffer  = zeros(4,handles.nsec*handles.bndpwr_freq);
handles.gammabuffer = zeros(4,handles.nsec*handles.bndpwr_freq);
handles.deltabuffer = zeros(4,handles.nsec*handles.bndpwr_freq);
handles.thetabuffer = zeros(4,handles.nsec*handles.bndpwr_freq);

guidata(hObject,handles) 


% --- SAVES DATA to DISK
function pushbutton6_Callback(~, ~, handles) %#ok<INUSD,DEFNU>
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
warning('off','all');
file_name_store_data=strcat('BioFeedbackExperiment',datestr(now,'yyyymmdd-HHMMSS'));
save(file_name_store_data,'handles'); 
movefile(strcat(file_name_store_data,'.mat'),'saved_experiments')
warning('on','all');


% --- Executes on slider movement.
function slider1_Callback(hObject, ~, handles) %#ok<DEFNU>
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.text30  ,'String',sprintf('%.1f ',get(hObject,'Value')));
handles.max_rnd_delay=get(hObject,'Value'); %maximum of random delay
handles.delayprd = round(handles.max_rnd_delay*rand,3);
set(handles.delay_train,'StartDelay',handles.delayprd);

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, ~, handles) %#ok<DEFNU>

set(handles.text31  ,'String',sprintf('%.1f ',get(hObject,'Value')));
handles.up_duration=get(hObject,'Value'); %ShowMessage and mark
set(handles.delay_train2,'StartDelay',handles.up_duration);
handles.nUp_data = handles.bndpwr_freq * handles.up_duration;
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, ~,~) %#ok<DEFNU>
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, ~, handles) %#ok<DEFNU>

if get(hObject,'Value')
    value = 'on';
else
    value = 'off';
end

set(handles.uipanel5,'Visible',value);
set(handles.text28, 'Visible', value)
set(handles.text29, 'Visible', value)
set(handles.text30, 'Visible', value)
set(handles.text31, 'Visible', value)
set(handles.text33, 'Visible', value)

set(handles.slider1, 'Visible', value);
set(handles.slider1, 'Min',1,'Max',10);
set(handles.slider1, 'SliderStep', [1/(10-1) , 1/(10-1)]);
set(handles.slider1, 'Value', handles.max_rnd_delay);

set(handles.slider2,'Visible', value);
set(handles.slider2, 'Min',1,'Max',10);
set(handles.slider2, 'Value', handles.up_duration);
set(handles.slider2, 'SliderStep', [1/(10-1) , 1/(10-1) ]);

set(handles.slider3,'Visible', value)
set(handles.slider3, 'Min', 0);
set(handles.slider3, 'Max', 5);
set(handles.slider3, 'SliderStep', [1/100 , 1/100 ]);

set(handles.text30  ,'String',sprintf('%.1f ',get(handles.slider1,'Value')));
set(handles.text31  ,'String',sprintf('%.1f ',get(handles.slider2,'Value')));
set(handles.text33  ,'String',sprintf('Radial Distance Classifier:    %.2f ',get(handles.slider3,'Value')));
set(handles.checkbox5,'Value',1)
guidata(hObject,handles)


% --- Executes on slider movement.
function slider3_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.text33  ,'String',sprintf('Radial Distance Classifier:  %.2f ',get(handles.slider3,'Value')));
handles.up_duration=get(hObject,'Value'); %ShowMessage and mark
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, ~, handles) %#ok<DEFNU>

set(handles.checkbox6,'Value',0);
handles.classifier_tag='mean';
guidata(hObject,handles);

% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox6
set(handles.checkbox5,'Value',0);
handles.classifier_tag='knn';
guidata(hObject,handles);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, ~, handles)  %#ok<DEFNU>

try
    while strcmp(get(handles.read_timer, 'Running'), 'on')
        stop(handles.read_timer);
    end
    while strcmp(get(handles.plot_timer, 'Running'), 'on')
        stop(handles.plot_timer);
    end
catch
    warning('Could not delete timers')
end
delete(handles.fig_ball.fig);
delete(hObject);


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(~, ~, ~) %#ok<DEFNU>
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
