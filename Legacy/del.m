%--------------------------------------------------------------------------
%Script01a - Dancing Sinus
%Creating Simple Animation in MATLAB
%MATLAB undercover
%zerocrossraptor.wordpress.com
%--------------------------------------------------------------------------
%This script m-file creates an endless animation of sinusoidal wave whose
%amplitude keeps on changing between -1 and 1.
%--------------------------------------------------------------------------
 
%CodeStart-----------------------------------------------------------------
%Resetting MATLAB environment
    close all;
    clear all;
    clc;
%Creating base plot (sinusoidal plot)
    x=0:10:360;
    y=sind(x);
%Declaring variable as a scale factor (amplitude) for base plot
    theta=0;
%Executing infinite loop to animate base plot
    while 1
        %Scaling base plot
        theta=theta+1;
        y_plot=y*sind(theta);
        plot(x,y_plot);
        %Preserving axis configuration
        axis([0,360,-1.2,1.2]);
        %Delaying animation
        pause(0.001);
    end
%CodeEnd-----------------------