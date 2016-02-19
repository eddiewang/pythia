% Thrasyvoulos Karydis
% 13/02/2015
% (c) Massachusetts Institute of Technology 2015
% Permission granted for experimental and personal use;
% license for commercial sale available from MIT

function [cvalAccu, tvalAccu, ROC_class] = run_classifiers(trainset,testset,T_test,predictorNames)
    % This function trains a variety of classifiers and reports back
    % cross-validation and test results.
        predictors = trainset{:,predictorNames};
        response = trainset.label;
        
       
        % Train classifiers
        % Perform cross-validation (10-folds by default)
        % Compute cross-validation accuracy
        % Compute accuracy on test file
        
        TREEClassifier   = fitctree(predictors, response, ...
                        'AlgorithmForCategorical', 'PCA', ...                 
                        'PredictorNames', predictorNames, ...
                        'ResponseName', 'label', ...
                        'ClassNames', {'no pain' 'pain'}); 
                    
        TREEcrossed   = crossval(TREEClassifier,'Kfold',5);
        cvalAccu(1) = 1 - kfoldLoss(TREEcrossed, 'LossFun', 'ClassifError');
        [~,scores] = predict(TREEClassifier,testset{:,predictorNames});
        tvalAccu(1) = 100*(1-confusion(T_test,scores')); 
        [X_roc1, Y_roc1] = perfcurve(testset.label,scores(:,2)','pain');
        
        clear TREEClassifier;
        clear TREECrossed;
        
        SVMRBFClassifier = fitcsvm(predictors, response, ... 
                        'KernelFunction','rbf', ...
                        'PolynomialOrder', [], ...
                        'KernelScale', 'auto', ...
                        'BoxConstraint', 1,  ...
                        'PredictorNames', predictorNames, ...
                        'ResponseName', 'label', ...
                        'ClassNames', {'no pain' 'pain'});
                    
        SVMRBFcrossed = crossval(SVMRBFClassifier,'Kfold',5);
        cvalAccu(2) = 1 - kfoldLoss(SVMRBFcrossed, 'LossFun', 'ClassifError');
        [~,scores] = predict(SVMRBFClassifier,testset{:,predictorNames});
        tvalAccu(2) = 100*(1-confusion(T_test,scores')); 
        [X_roc2, Y_roc2] = perfcurve(testset.label,scores(:,2)','pain');
        
        clear SVMRBFClassifier;
        clear SVMRBFCrossed;
        
        SVMLINClassifier = fitcsvm(predictors, response, ... 
                        'KernelFunction','linear', ...
                        'PolynomialOrder', [], ...
                        'KernelScale', 'auto', ...
                        'BoxConstraint', 1, ...
                        'PredictorNames', predictorNames, ...
                        'ResponseName', 'label', ...
                        'ClassNames', {'no pain' 'pain'});
                    
        SVMLINcrossed = crossval(SVMLINClassifier,'Kfold',5);
        cvalAccu(3) = 1 - kfoldLoss(SVMLINcrossed, 'LossFun', 'ClassifError');
        [~,scores] = predict(SVMLINClassifier,testset{:,predictorNames});
        tvalAccu(3) = 100*(1-confusion(T_test,scores')); 
        [X_roc3, Y_roc3] = perfcurve(testset.label,scores(:,2)','pain');   
        
        clear SVMLINClassifier;
        clear SVMLINCrossed;
        
        kNNClassifier = fitcknn(predictors, response, ... 
                        'NumNeighbors',5, ...
                        'NSMethod','exhaustive', ...
                        'Distance','minkowski', ...
                        'PredictorNames', predictorNames, ...
                        'ResponseName', 'label', ...
                        'ClassNames', {'no pain' 'pain'});
                    
        kNNcrossed = crossval(kNNClassifier,'Kfold',5);
        cvalAccu(4) = 1 - kfoldLoss(kNNcrossed, 'LossFun', 'ClassifError');
        [~,scores] = predict(kNNClassifier,testset{:,predictorNames});
        tvalAccu(4) = 100*(1-confusion(T_test,scores')); 
        [X_roc4, Y_roc4] = perfcurve(testset.label,scores(:,2)','pain');    
        
        clear kNNClassifier;
        clear kNNCrossed;
        
        ROC_class = {[X_roc1 Y_roc1],[X_roc2 Y_roc2],[X_roc3 Y_roc3],[X_roc4 Y_roc4]};
%         RBOClassifier = fitensemble(predictors, response, ...
%                         'RobustBoost',300,...
%                         'Tree','RobustErrorGoal',0.01, ...
%                         'PredictorNames', predictorNames, ...
%                         'ResponseName', 'label', ...
%                         'ClassNames', {'no pain' 'pain'});
%                     
%         RBOcrossed = crossval(RBOClassifier);
%         cvalAccu(5) = 1 - kfoldLoss(RBOcrossed, 'LossFun', 'ClassifError');
%         tvalAccu(5) = sum(strcmp(test.label,predict(RBOClassifier,test{:,predictorNames})))/size(test,1);
%         
%         clear RBOClassifier;
%         clear RBOCrossed;
        
end
