clear all;
clc;

filename = 'andreas_pain_2501';

load(filename);

markers_t = markers_t - EEG_t(1);

EEG_t = 0:1/220:size(EEG,1)/220;
EEG_t = EEG_t(1:end-1);

ACC_t = 0:1/50:size(ACC,1)/50;
ACC_t = ACC_t(1:end-1);

FREQ_t = 0:1/10:size(alpha,1)/10;
FREQ_t = FREQ_t(1:end-1);

alpha_t = FREQ_t;
beta_t = FREQ_t;
gamma_t = FREQ_t;
delta_t = FREQ_t;
theta_t = FREQ_t;
low_freqs_t = FREQ_t;
is_good_t = FREQ_t;
start_t = 0;

if exist('conc_t','var')
    conc_t = FREQ_t;
end



save(filename)
