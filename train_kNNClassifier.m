

function train_kNNClassifier(inputFile,verbose)
% TRAIN_KNNCLASSIFIER is code ported from PETRAE paper classification
%    Thrasyvoulos Karydis
%    04/15/2015
%    (c) Massachusetts Institute of Technology 2015
%    Permission granted for experimental and personal use;
%    license for commercial sale available from MIT
%       
%    This function trains a kNN Classifier to classify between pain/no pain
%    by labeling data from a cold water experiment with four markers.
%
%
%    inputFile  - A .mat file created from a muse_read function with parsed
%                 data from a Muse session.
%                 Make sure that './mat' is added to the path
%    verbose    - 0/1 generate debug outputs or not

% Load file
tic
try
    f = load(inputFile);
    if verbose
        et = toc ;
        fprintf('Loaded file %s in %f sec.\n',inputFile,et)
    end
    
catch ME
    fprintf('Exception: %s \t Aborting ... \n',ME.identifier)
    rethrow(ME);
end

% Label data
tic;
f.label = cell(size(f.alpha,1),1);
%figure
%%%                                    | <- MARK
%%                  ------><------><--> <--><------>
%%                 UNKOWNN  NoPain  UNKOWNN   Pain
%# vertical line
%                          t1       t2  t3      t4  

for t=1:size(f.alpha,1)
    if (f.alpha_t(t)<f.markers_t(1))
        f.label{t} = 'unknown';
    end
    if (f.alpha_t(t)>=f.markers_t(1))        
        f.label{t} = 'no pain';
    end
    if (f.alpha_t(t)>=f.markers_t(2))
        f.label{t} = 'unknown';
    end    
    if (f.alpha_t(t)>=f.markers_t(4))
        f.label{t} = 'pain';
    end
end


fig=figure;
hax=axes;

%time is the    
alpha_t_plot=f.alpha_t(f.alpha_t>f.markers_t(1)-1);
if alpha_t_plot<0
   alpha_t_plot=0;
end


%plot (alpha_t_plot,f.alpha(:,end-f.alpha:end));
hold on;


% %Area with A marker
% for i=f.markers_t(1):0.3:f.markers_t(2)  
%      %your point goes here
%     line([i i],get(hax,'YLim'),'Color',[0 0 0.8]);
% end

ha = area([f.markers_t(1) f.markers_t(2)], [max(get(hax,'YLim')) max(get(hax,'YLim'))],'FaceColor','y');
ha2 = area([f.markers_t(1) f.markers_t(2)], [min(get(hax,'YLim')) min(get(hax,'YLim'))],'FaceColor','y');


% %area with B marker
% for i=f.markers_t(4):0.3:f.alpha_t(end)    
%      %your point goes here
%     line([i i],get(hax,'YLim'),'Color',[0.8 0 0]);
% end

ha3 = area([f.markers_t(4) f.alpha_t(end)], [max(get(hax,'YLim')) max(get(hax,'YLim'))],'FaceColor','r');
ha4 = area([f.markers_t(4) f.alpha_t(end)], [min(get(hax,'YLim')) min(get(hax,'YLim'))],'FaceColor','r');

%Vertical limits
%for i=1:4
%    SP=f.markers_t(i);
%     %your point goes here
%    line([SP SP],get(hax,'YLim'));
%end

%Buton Pressed Line
line([f.markers_t(3) f.markers_t(3)],get(hax,'YLim'));

%alpha
plot (alpha_t_plot,f.alpha(:,end-f.alpha:end),'color','k');


% for t=1:size(f.alpha,1)
%     % no pain: 1 second before inserting hand and 1 sec after end of pain
%     if (f.alpha_t(t)<floor(f.markers_t(1)-1)||f.alpha_t(t)>ceil(f.markers_t(4)+1))
%         f.label{t} = 'no pain';
%         % pain: 1 second after pain marker started until removal of hand
%     elseif (f.alpha_t(t)>floor(f.markers_t(2)+1)&&f.alpha_t(t)<ceil(f.markers_t(3)))
%         f.label{t} = 'pain';
%     else
%         f.label{t} = 'unknown';
%     end
% end

if verbose
    et = toc;    
    fprintf('Input Data labeled in %f sec.\n',et)
end

% Feature Extraction
tic;
[features,~] = feature_extraction(f) ;
if verbose
    et = toc;
    fprintf('Feature extraction completed in %f sec. \n',et)
end

% Train kNN Classifier
tic;
predictorNames = features.Properties.VariableNames(2:end);
predictors = features{:,predictorNames};
response = features.label;

kNNClassifier = fitcknn(predictors, response, ... 
                        'NumNeighbors',5, ...
                        'NSMethod','exhaustive', ...
                        'Distance','minkowski', ...
                        'PredictorNames', predictorNames, ...
                        'ResponseName', 'label', ...
                        'ClassNames', {'no pain' 'pain'});
                    
        kNNcrossed = crossval(kNNClassifier,'Kfold',5);
        cvalAccu = 1 - kfoldLoss(kNNcrossed, 'LossFun', 'ClassifError');
if verbose
    et = toc;
    fprintf('Classifier trained in %f sec. -- Cval = %f\n',et,cvalAccu)
end

save('kNNClassifier','kNNClassifier');

end % Function


