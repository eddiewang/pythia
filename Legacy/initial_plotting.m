% Thrasyvoulos Karydis
% 13/02/2015
% (c) Massachusetts Institute of Technology 2015
% Permission granted for experimental and personal use;
% license for commercial sale available from MIT

% This file plots random data from the file in different figures. It might
% help on choosing the correct features. Run it in sections!
% Use it only with new files.

%% Data Input
   clear all;
   clc;  
   
  % Choose filename from MuseRec/mat
   filename = 'andreas_pain_2501';
   f  = load(sprintf('MuseRec/mat/%s',filename));
   maxi = 0.2;
   mini = -0.2;
 
%% Alpha frequencies 
   figure  
   hold on
   subplot(6,1,1)
   
   plot(f.EEG_t,f.EEG(:,2))
   line([f.markers_t(1) f.markers_t(1)],[0 1682],'color','k');
   line([f.markers_t(2) f.markers_t(2)],[0 1682],'color','k');
   line([f.markers_t(3) f.markers_t(3)],[0 1682],'color','k');
   line([f.markers_t(4) f.markers_t(4)],[0 1682],'color','k');

  
   subplot(6,1,2)
   
   plot(f.alpha_t,mag2db(f.alpha(:,2)))
   subplot(6,1,3)
   plot(f.alpha_t,mag2db(f.beta(:,2)))
   subplot(6,1,4)
   plot(f.alpha_t,mag2db(f.gamma(:,2)))
   subplot(6,1,5)
   plot(f.alpha_t,mag2db(f.delta(:,2)))
   subplot(6,1,6)
   plot(f.alpha_t,mag2db(f.theta(:,2)))
  
   line([f.markers_t(1) f.markers_t(1)],[mini maxi],'color','k');
   line([f.markers_t(2) f.markers_t(2)],[mini maxi],'color','k');
   line([f.markers_t(3) f.markers_t(3)],[mini maxi],'color','k');
   line([f.markers_t(4) f.markers_t(4)],[mini maxi],'color','k');

 

%% Plot raw data and power from sensor 
fig=figure();
s=subplot (2,1,1)
timeraw=(1:size(f.EEG,1))/220;
plot (timeraw,f.EEG(:,1))
hold on
xlabel('time [s]') % x-axis label
ylabel('Voltage [mV]') % y-axis label
title('EEG')

%is good
f.is_good(f.is_good(:,1) == 0) = NaN
timeraw2=(1:size(f.is_good,1))/10;
plot(timeraw2,f.is_good(:,1)*100+400,'LineWidth',4,'color','r')
text(0,550,' IS GOOD','color','r')

%legend
ylocation=s.YLim(2)-100;
line([f.markers_t(1) f.markers_t(1)], [s.YLim(1) ylocation],'LineWidth',2,'color','k','LineStyle','--');
str1 = '\leftarrow Start Inducing pain';
text(f.markers_t(1),ylocation,str1)
line([f.markers_t(2) f.markers_t(2)], [s.YLim(1) ylocation],'LineWidth',2,'color','k','LineStyle','--');
str1 = '\leftarrow Start High pain';
text(f.markers_t(2),ylocation,str1)
line([f.markers_t(3) f.markers_t(3)], [s.YLim(1) ylocation],'LineWidth',2,'color','k','LineStyle','--');
str1 = '\leftarrow Remove Hand';
text(f.markers_t(3),ylocation,str1)
line([f.markers_t(4) f.markers_t(4)], [s.YLim(1) ylocation],'LineWidth',2,'color','k','LineStyle','--');
str1 = '\leftarrow End pain';
text(f.markers_t(4),ylocation,str1)

s=subplot (2,1,2)
hold on

timefreq=(1:size(f.alpha,1))/10;
plot (timefreq,mag2db(f.theta(:,1)),'r','LineWidth',2,'LineStyle','-.');
plot (timefreq,mag2db(f.delta(:,1)),'Color',[192/255 192/255 192/255],'LineWidth',1,'LineStyle','-.','Marker','+','MarkerFaceColor','red','MarkerSize',5);
plot (timefreq,mag2db(f.alpha(:,1)),'Color',[1 0 1],'LineWidth',2,'LineStyle','-');
plot (timefreq,mag2db(f.beta(:,1)),'k','LineWidth',2,'LineStyle',':');
plot (timefreq,mag2db(f.gamma(:,1)),'b','LineWidth',2,'LineStyle','--');



legend('theta','delta','alpha','beta','gamma','Location','best','orientation','horizontal')
title('EEG FFT')
xlabel('time [s]') % x-axis label
ylabel('Power [dB]') % y-axis label


ylocation=s.YLim(2);
line([f.markers_t(1) f.markers_t(1)], [s.YLim(1) ylocation],'LineWidth',2,'color','k','LineStyle','--');
str1 = '\leftarrow Start Inducing pain';
text(f.markers_t(1),ylocation,str1)
line([f.markers_t(2) f.markers_t(2)], [s.YLim(1) ylocation],'LineWidth',2,'color','k','LineStyle','--');
str1 = '\leftarrow Start High pain';
text(f.markers_t(2),ylocation,str1)
line([f.markers_t(3) f.markers_t(3)], [s.YLim(1) ylocation],'LineWidth',2,'color','k','LineStyle','--');
str1 = '\leftarrow Remove Hand';
text(f.markers_t(3),ylocation,str1)
line([f.markers_t(4) f.markers_t(4)], [s.YLim(1) ylocation],'LineWidth',2,'color','k','LineStyle','--');
str1 = '\leftarrow End pain';
text(f.markers_t(4),ylocation,str1)

%Absolute band powers are based on the logarithm ...
%of the Power Spectral Density of the EEG data for ...
%each channel. Since it is a logarithm, some of the values will ...
%be negative (i.e. when the absolute power is less than 1) They are ...
%given on a log scale, units are Bels. These values are emitted at 10Hz.
%Position 1: Left Ear(TP9), Range: 0.0 - 1682.0 in microvolts 
%theta (1-4Hz), delta (5-8Hz), alpha (9-13Hz), beta (13-30Hz), gamma (30-50Hz) a
