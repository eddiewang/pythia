% Thrasyvoulos Karydis
% 13/02/2015
% (c) Massachusetts Institute of Technology 2015
% Permission granted for experimental and personal use;
% license for commercial sale available from MIT

% This script acts on the .mat files directory and updates the database
% of annotated (labeled) data for the pain experiment. The data are labeled
% using the markers as flagposts. Use seperately 3110 and 2501 files.

% List of files already included in the database:
    clear; clc;
    
    load('andreas_pain_2501');
    
    %reminder Fs is 10 Hz for freq data
    label = cell(size(alpha,1),1);
    for t=1:size(alpha,1)
        % no pain: 1 second before inserting hand and 1 sec after end of
        % pain
        if (alpha_t(t)<floor(markers_t(1)-1)||alpha_t(t)>ceil(markers_t(4)+1))
            label{t} = 'no pain';
            % pain: 1 second after pain marker started until removal of hand 
        elseif (alpha_t(t)>floor(markers_t(2)+20)&&alpha_t(t)<ceil(markers_t(3)))
            label{t} = 'pain';
        else
            label{t} = 'unknown';
        end
    end
    
    clear t;  
    clear filen;
  
    save(filename);
    
    
    
    