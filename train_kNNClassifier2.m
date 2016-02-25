function kNNClassifier = train_kNNClassifier2(inputData,verbose)
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
    f = inputData;   
catch ME
    fprintf('Exception: %s \t Aborting ... \n',ME.identifier)
    rethrow(ME);
end

% Label data
tic;
f.label = cell(size(f.alpha,2),1);
                    

for t=1:size(f.alpha,2)
    
    if f.alpha_t(t) <= f.markers_t - 12
        f.label{t} = 'unknown';
    elseif f.alpha_t(t) <= f.markers_t - 2
        f.label{t} = 'no pain';
    elseif f.alpha_t(t) <= f.alpha_t(end)-12
        f.label{t} = 'unknown';
    elseif f.alpha_t(t) <= f.alpha_t(end)-2
        f.label{t} = 'pain';
    else
        f.label{t} = 'unknown';
    end
end

save('ffff')

hold on;

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


