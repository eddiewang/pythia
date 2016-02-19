% Thrasyvoulos Karydis
% 13/02/2015
% (c) Massachusetts Institute of Technology 2015
% Permission granted for experimental and personal use;
% license for commercial sale available from MIT
%% Import feature data for train and test set
 clear ; clc;
% % % load train and test data
% load('andreas_pain_2501_feat','featuresold','featuresnew');
% 
% trainset = featuresold;
% andreas = featuresnew;
% clear featuresold; clear featuresnew;
% load('thras_pain_2501_feat','featuresold','featuresnew');
% testset = featuresold;
% thras = featuresnew;
% clear featuresold; clear featuresnew;
% X_train = trainset{:,2:end}'; 
% X_test = testset{:,2:end}'; 
% 
% T_train = zeros(2,size(X_train,2));
% for t = 1:size(X_train,2)
%     if (strcmp(trainset.label{t},'pain'))
%         T_train(1,t) = 0;
%         T_train(2,t) = 1;
%     else
%         T_train(1,t) = 1;
%         T_train(2,t) = 0;
%     end      
% end
% T_test = zeros(2,size(X_test,2));
% 
% for t = 1:size(X_test,2)
%     if (strcmp(testset.label{t},'pain'))
%         T_test(1,t) = 0;
%         T_test(2,t) = 1;
%     else
%         T_test(1,t) = 1;
%         T_test(2,t) = 0;
%     end      
% end
% 
% clear t;

%save('feature_evaluation_data_20');

load('feature_evaluation_data');
%load('feature_evaluation_data_20');

%% Visualize data to see features that have the best separation
    
    % Fixed standardization
%      [G,~] = grp2idx(andreas.label);
%      mean_alpha_pain = andreas.meanalpha(find(G==3));
%      mean_beta_pain  = andreas.meanbeta(find(G==3)); 
%      mean_alpha_nopain = andreas.meanalpha(find(G==1));
%      mean_beta_nopain  = andreas.meanbeta(find(G==1));
%      mean_alpha_unknown = andreas.meanalpha(find(G==2));
%      mean_beta_unknown  = andreas.meanbeta(find(G==2));
%      
%      figure 
%         hold on
%         scatter(mean_alpha_pain,mean_beta_pain,'r');
%         scatter(mean_alpha_nopain,mean_beta_nopain,'b');
%         scatter(mean_alpha_unknown,mean_beta_unknown,'g');
    
        
%         [G,~] = grp2idx(andreas.label);
%      mean_alpha_pain = andreas.alpha_LE(find(G==3));
%      mean_beta_pain  = andreas.beta_RE(find(G==3)); 
%      mean_alpha_nopain = andreas.alpha_LE(find(G==1));
%      mean_beta_nopain  = andreas.beta_RE(find(G==1));
%      mean_alpha_unknown = andreas.alpha_LE(find(G==2));
%      mean_beta_unknown  = andreas.beta_RE(find(G==2));
%      figure 
%         hold on
%         scatter(mean_alpha_pain,mean_beta_pain,'r');
%         scatter(mean_alpha_nopain,mean_beta_nopain,'b');
%         scatter(mean_alpha_unknown,mean_beta_unknown,'g');
    
  %   figure
     %        gscatter(trainset.meanalpha,trainset.meanbeta,trainset.label,'rb');
   
%             figure
%             hold on
%             gscatter(testset.meanalpha,testset.meanbeta,testset.label,'gyoo')
%             gscatter(trainset.meangamma,trainset.meandelta,trainset.label,'rboo')
%             
%             % have time here
%     
%     figure
%     gplotmatrix(train{:,[2 7 12]},[],train.label, ...
%                 'br', ... %colormap
%                 '..', ... %style
%                 []  , ... %size of marker
%                 'on', ... %legend 
%                 '', ...
%                 train.Properties.VariableNames([2 7 12]), ...
%                 train.Properties.VariableNames([2 7 12]));
%     figure
%     gplotmatrix(test{:,[2 7 12 17 22]},[],test.label, ...
%                 'br', ... %colormap
%                 '..', ... %style
%                 []  , ... %size of marker
%                 'on', ... %legend 
%                 'hist', ...
%                 test.Properties.VariableNames([2 7 12 17 22]), ...
%                 test.Properties.VariableNames([2 7 12 17 22]));

%% Evaluate classifiers for stationary EEG classification

%  Average performance of nSamples sets for each different classifier

    % Go from labels to T_train and then 
   
    nSamples = 5;  
    nClassifiers = 5; 
    class_names = {'Decision Trees','SVM Linear','SVM RBF','kNN','Neural Network'};
    
    crossAccu_class = zeros(nClassifiers,nSamples);
    testAccu_class = zeros(nClassifiers,nSamples); 
    ROC_class = cell(nSamples,1);
    
    h = waitbar(0,'Training models and validating');
    
    for i=1:nSamples   % for different number of features 
        rng('shuffle');
        ind = randperm(20)+1;
        rng('shuffle');
        predictorNames = trainset.Properties.VariableNames(ind(1:randi([5 20])));
        % Run classifiers
        [crossAccu_class(1:nClassifiers-1,i), ...
         testAccu_class(1:nClassifiers-1,i), ... 
         R1] = run_classifiers(trainset,testset,T_test,predictorNames); 
                                              
        [crossAccu_class(nClassifiers,i), ...
         testAccu_class(nClassifiers,i), ... 
         R2] = run_neural_classifier(trainset{:,predictorNames}',T_train,testset{:,predictorNames}',T_test);  
         
        ROC_class{i}{1} = R1;
        ROC_class{i}{2} = R2;
        waitbar(i/nSamples,h,sprintf('Currently at sample #%d',i))
    end
    
    close(h);
    testAccu_class(1:4,:) = testAccu_class(1:4,:)/100;
    [~,id] = max(testAccu_class,[],2);
    %s = sprintf('class_data_%s',datestr(datetime('now')));
    %save(s,'crossAccu_class','testAccu_class','id','nSamples','nClassifiers','ROC_class','class_names');
     %load('class_data_14-Feb-2015 03:32:13.mat');
    
    % Bar graph for performances
    figure
        hold on 
        plot([1;2;3;4;5],mean(crossAccu_class,2),'*');
        errorbar([1;2;3;4;5],mean(testAccu_class,2),(max(testAccu_class,[],2)-min(testAccu_class,[],2))/2,'o');
        
    % ROC plot
    figure
        hold on
        for i=1:nClassifiers-1
            plot(ROC_class{id(i)}{1}{i}(:,1),ROC_class{id(i)}{1}{i}(:,2))       
        end
        mal = ROC_class{id(end)}{2}{1};
        plot(mal(1,1:size(mal,2)/2),mal(1,size(mal,2)/2+1:end))
        h = ezplot('x',[0 1 0 1]);
        set(h,'color','k')
       
    % Optimal algorithm is kNN.
%% Evaluate number of train features by simulation
    
    % Average performance of nSamples sets for each different nFeat
   
%     nSamples = 100;
%     
%     nFeat = 1:1:size(testset,2)-1;
%     
%     crossAccu_feat = zeros(size(nFeat,2),3);
%     testAccu_feat = zeros(size(nFeat,2),3); 
%     cval = zeros(nSamples,1);
%     tval = zeros(nSamples,1);
%     R = cell(nSamples,1);
%     ROC_feat = cell(size(nFeat,2),1);
%     
%     h = waitbar(0,'Training models and cross-validating');
%     
%     for i=1:size(nFeat,2)   % for each number of features
%         for j = 1:nSamples %run nSamples and avg
%             rng('shuffle');
%             tzoker  = randperm(25)+1;
%             predictorNames = testset.Properties.VariableNames(tzoker(1:nFeat(i)));
%             % Run optimal classifier
%             kNNClassifier = fitcknn(trainset{:,predictorNames}, trainset.label, ... 
%                         'NumNeighbors',5, ...
%                         'NSMethod','exhaustive', ...
%                         'Distance','minkowski', ...
%                         'PredictorNames', predictorNames, ...
%                         'ResponseName', 'label', ...
%                         'ClassNames', {'no pain' 'pain'});
%                     
%             kNNcrossed = crossval(kNNClassifier,'Kfold',5);
%             cval(j) = 1 - kfoldLoss(kNNcrossed, 'LossFun', 'ClassifError');
%             [~,scores] = predict(kNNClassifier,testset{:,predictorNames});
%             tval(j) = 1-confusion(T_test,scores'); 
%             [X_roc, Y_roc] = perfcurve(testset.label,scores(:,2)','pain');
%             R{j} = [X_roc Y_roc];
%             waitbar(i/size(nFeat,2),h,sprintf('Currently at nFeat: %d, nSample:%d',nFeat(i),j))
%         end
%         crossAccu_feat(i,1) = min(cval);
%         crossAccu_feat(i,2) = mean(cval);
%         crossAccu_feat(i,3) = max(cval);
%         testAccu_feat(i,1)  = min(tval);
%         testAccu_feat(i,2)  = mean(tval);
%         [testAccu_feat(i,3),id]  = max(tval);
%         ROC_feat{i} = R{id};
%     end
%     
%     close(h);
%    s = sprintf('feat_data_%s',datestr(datetime('now')));
%    save(s,'crossAccu_feat','testAccu_feat','nSamples','nFeat','ROC_feat');
   %load('feat_data_14-Feb-2015 04:29:51');  
    
    figure
        hold on 
        plot(nFeat,mean(crossAccu_feat,2),'*');
        errorbar(nFeat,mean(testAccu_feat,2),(max(testAccu_feat,[],2)-min(testAccu_feat,[],2))/2,'o');
   
    
%     Optimal number of features is 7
      optfeatNum = 7;
 
%% Evaluate features sets of size optFeat from the top 10 of the features
       
    % Average performance of nSamples sets for each different nFeat
   
    
    all_comb = VChooseK(2:26,7);
     sets = all_comb(1:2:10000,:);
    nSamples = size(sets,1);
%     
%     crossAccu_set = zeros(size(sets,2),1);
%     testAccu_set = zeros(size(sets,2),1); 
%     ROC_set = cell(size(sets,2),1);
%     
%     h = waitbar(0,'Training models and cross-validating');
%     
%     for i=1:nSamples   % for each number of features         
%             predictorNames = testset.Properties.VariableNames(sets(i,:));
%             % Run optimal classifier
%             kNNClassifier = fitcknn(trainset{:,predictorNames}, trainset.label, ... 
%                         'NumNeighbors',5, ...
%                         'NSMethod','exhaustive', ...
%                         'Distance','minkowski', ...
%                         'PredictorNames', predictorNames, ...
%                         'ResponseName', 'label', ...
%                         'ClassNames', {'no pain' 'pain'});
%                     
%             kNNcrossed = crossval(kNNClassifier,'Kfold',5);
%             crossAccu_set(i) = 1 - kfoldLoss(kNNcrossed, 'LossFun', 'ClassifError');
%             [~,scores] = predict(kNNClassifier,testset{:,predictorNames});
%             testAccu_set(i) = 1-confusion(T_test,scores'); 
%             [X_roc, Y_roc] = perfcurve(testset.label,scores(:,2)','pain');
%             ROC_set{i} = [X_roc Y_roc];        
%         waitbar(i/size(sets,1),h,sprintf('Currently at set: %d',i))
%     end
%     
%     close(h);
%     
%     [~,id] = max(testAccu_set);
     %s = sprintf('set_data_%s',datestr(datetime('now')));
     %save(s,'crossAccu_set','testAccu_set','nSamples','sets','ROC_set');
   %  load('feat_data_14-Feb-2015 04:29:51');  
    
   optimalFeat = testset.Properties.VariableNames(sets(965,:));
    figure
    hold on
        plot(testAccu_set)
        plot(testAccu_set)
        plot(testAccu_set)
%% Classification of New Data
            % Run optimal classifier
            kNNClassifier = fitcknn(trainset{:,optimalFeat}, trainset.label, ... 
                        'NumNeighbors',5, ...
                        'NSMethod','exhaustive', ...
                        'Distance','minkowski', ...
                        'PredictorNames', optimalFeat, ...
                        'ResponseName', 'label', ...
                        'ClassNames', {'no pain' 'pain'});
                    
            kNNcrossed = crossval(kNNClassifier,'Kfold',5);
            crossAccu_new = 1 - kfoldLoss(kNNcrossed, 'LossFun', 'ClassifError');
            [~,scores] = predict(kNNClassifier,andreas{:,optimalFeat});
            T_andreas = zeros(2,size(X_test,2));

            for t = 1:size(andreas,1)
                if (strcmp(andreas.label{t},'pain'))
                    T_andreas(1,t) = 0;
                    T_andreas(2,t) = 1;
                else
                    T_andreas(1,t) = 1;
                    T_andreas(2,t) = 0;
                end      
            end            

            testAccu_new = 1-confusion(T_andreas,scores'); 
            [X_roc_new, Y_roc_new] = perfcurve(andreas.label,scores(:,2)','pain');
            ROC_set{i} = [X_roc_new Y_roc_new];        

    
    