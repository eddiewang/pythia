%% Muse CSV format file data parser from OLD FIRMWARE (< Dec 2014)

clear all;
clc;
filename = 'black_sensor_test';

% open file
fid = fopen(sprintf('MuseRec/csv/old_firm/%s.csv',filename), 'r');

csv = fread(fid,[1 inf],'*char');

fclose(fid);
% All my data are now in a huge string called "csv"
% Split string into lines
line = strsplit(csv,'\n');

EEG = [0 0 0 0];
EEG_t = [];
ACC=[0 0 0];
ACC_t = [];
alpha = [0 0 0 0];
alpha_t = [];
beta = [0 0 0 0];
beta_t = [];
delta = [0 0 0 0];
delta_t = [];
gamma = [0 0 0 0];
gamma_t = [];
theta = [0 0 0 0];
theta_t = [];
low_freqs = [0 0 0 0];
low_freqs_t = [];
is_good = [0 0 0 0];
is_good_t = [];
blink = [0];
blink_t = [];
markers_t = [];


% Monitor progress
h = waitbar(0,'Mining...');
% For every line
for i=1:size(line,2)-1
   %split line in commas
   
   waitbar(i/(size(line,2)-1))
  
   data = strsplit(line{i},',');
   
   switch data{2}
       case ' /muse/eeg'
           t1 = str2double(data{3});
           t2 = str2double(data{4});
           t3 = str2double(data{5});
           t4 = str2double(data{6});
           EEG = [EEG ; [t1 t2 t3 t4]]; 
           EEG_t = [EEG_t; str2double(data{1})];
       case ' /muse/acc'
           t1 = str2double(data{3});
           t2 = str2double(data{4});
           t3 = str2double(data{5});
           ACC = [ACC ; [t1 t2 t3]]; 
           ACC_t = [ACC_t; str2double(data{1})];  
       case ' /muse/dsp/elements/low_freqs'
           t1 = str2double(data{3});
           t2 = str2double(data{4});
           t3 = str2double(data{5});
           t4 = str2double(data{6});
           low_freqs = [low_freqs ; [t1 t2 t3 t4]]; 
           low_freqs_t = [low_freqs_t; str2double(data{1})];
       case ' /muse/dsp/elements/alpha'
           t1 = str2double(data{3});
           t2 = str2double(data{4});
           t3 = str2double(data{5});
           t4 = str2double(data{6});
           alpha = [alpha ; [t1 t2 t3 t4]]; 
           alpha_t = [alpha_t; str2double(data{1})];
       case ' /muse/dsp/elements/beta'
           t1 = str2double(data{3});
           t2 = str2double(data{4});
           t3 = str2double(data{5});
           t4 = str2double(data{6});
           beta = [beta ; [t1 t2 t3 t4]]; 
           beta_t = [beta_t; str2double(data{1})];
       case ' /muse/dsp/elements/gamma'
           t1 = str2double(data{3});
           t2 = str2double(data{4});
           t3 = str2double(data{5});
           t4 = str2double(data{6});
           gamma = [gamma ; [t1 t2 t3 t4]]; 
           gamma_t = [gamma_t; str2double(data{1})];
       case ' /muse/dsp/elements/delta'
           t1 = str2double(data{3});
           t2 = str2double(data{4});
           t3 = str2double(data{5});
           t4 = str2double(data{6});
           delta = [delta ; [t1 t2 t3 t4]]; 
           delta_t = [delta_t; str2double(data{1})];
       case ' /muse/dsp/elements/theta'
           t1 = str2double(data{3});
           t2 = str2double(data{4});
           t3 = str2double(data{5});
           t4 = str2double(data{6});
           theta = [theta ; [t1 t2 t3 t4]]; 
           theta_t = [theta_t; str2double(data{1})];
       case ' /muse/dsp/elements/is_good'
           t1 = str2double(data{3});
           t2 = str2double(data{4});
           t3 = str2double(data{5});
           t4 = str2double(data{6});
           is_good = [is_good ; [t1 t2 t3 t4]]; 
           is_good_t = [is_good_t; str2double(data{1})];
       case ' /muse/dsp/elements/blink'
           blink = [blink ; data{3}];
           blink_t = [blink_t; str2double(data{1})];         
       case ' /muse/config'
           config = line{i};
       case ' /muse/annotation'
           markers_t = [markers_t; str2double(data{1})];
   end
        
end

close(h)

%clean up the 0's

EEG = EEG(2:size(EEG,1),:);
ACC = ACC(2:size(ACC,1),:);
alpha = alpha(2:size(alpha,1),:);
beta = beta(2:size(beta,1),:);
gamma = gamma(2:size(gamma,1),:);
delta = delta(2:size(delta,1),:);
theta = theta(2:size(theta,1),:);
low_freqs = low_freqs(2:size(low_freqs,1),:);
is_good = is_good(2:size(is_good,1),:);
blink = blink(2:size(blink,1),:);

% Preprocessing some data
   %Start of EEG
       start_t = EEG_t(1);

save(sprintf('MuseRec/mat/%s',filename));