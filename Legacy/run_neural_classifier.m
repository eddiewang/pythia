% Thrasyvoulos Karydis
% 13/02/2015
% (c) Massachusetts Institute of Technology 2015
% Permission granted for experimental and personal use;
% license for commercial sale available from MIT

function [cvalAccu, tvalAccu, ROC_class] = run_neural_classifier(X_train,T_train,X_test,T_test)
%This function trains a neural network classifier and reports back cross-validation and test results.


% Manipulate the data so that they are suitable for neural network toolbox
% We need now two matrices (arrays) input X and target T.
% Input should have rows for features and columns for observations 
%(Feat x Obs).
% Target should have 2 columns, one with 1's on pain and one with 1's to no
% pain.

% Choose a Training Function
% For a list of all training functions type: help nntrain
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations.
trainFcn = 'trainscg';  % Scaled conjugate gradient backpropagation.

% Create a Pattern Recognition Network
hiddenLayerSize = 10;
net = patternnet(hiddenLayerSize,trainFcn);

% Choose Input and Output Pre/Post-Processing Functions
% For a list of all processing functions type: help nnprocess
net.input.processFcns = {'removeconstantrows','mapminmax'};
net.output.processFcns = {'removeconstantrows','mapminmax'};

% Setup Division of Data for Training, Validation, Testing
% For a list of all data division functions type: help nndivide
net.divideFcn = 'dividerand';  % Divide data randomly
net.divideMode = 'sample';  % Divide up every sample
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

% Choose a Performance Function
% For a list of all performance functions type: help nnperformance
net.performFcn = 'crossentropy';  % Cross-Entropy

% Choose Plot Functions
% For a list of all plot functions type: help nnplot
net.plotFcns = {'plotperform','plottrainstate','ploterrhist', ...
    'plotconfusion', 'plotroc'};

% Train the Network
[net,~] = train(net,X_train,T_train);

% Test the Network
y = net(X_train);
tind = vec2ind(T_train);
yind = vec2ind(y);
percentErrors = sum(tind ~= yind)/numel(tind);

cvalAccu = (1-percentErrors);
% View the Network
%view(net)

% Plots
% Uncomment these lines to enable various plots.
%figure, plotperform(tr)
%figure, plottrainstate(tr)
%figure, ploterrhist(e)
%figure, plotconfusion(t,y)
%figure, plotroc(t,y)

   Y_test = net(X_test);
   [tpr, fpr] = roc(T_test(2,:),Y_test(2,:));
   ROC_class = {[fpr tpr]};
   % plotconfusion(T_test,Y_test);
   % plotroc(T_test,Y_test,'pain');
   [c,~] = confusion(T_test,Y_test);
   tvalAccu = (1-c);
    
end