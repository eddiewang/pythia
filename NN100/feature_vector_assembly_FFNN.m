%this file has outputs the features in a new file called 'filename_feat'

clear all;
clc;
 
f = load('thras_pain_2501');
%reminder Fs is 10 Hz for freq data
filename = strcat(f.filename,'_feat');
k = 1;
varNames = {'label', ...
            'meanalpha','alphaback','alphafront','alphaleft','alpharight', ...
            'meanbeta' ,'betaback' ,'betafront' ,'betaleft' ,'betaright', ...
            'meangamma','gammaback','gammafront','gammaleft','gammaright', ...
            'meandelta','deltaback','deltafront','deltaleft','deltaright', ...
            'meantheta','thetaback','thetafront','thetaleft','thetaright' };
        
observations = [];
    
for t=1:size(f.alpha,1)
    if (~isempty(f.label{t}))
        response{k} = f.label{t};
        
        row = [nanmean(f.alpha(t,:)) ...
        nanmean(f.alpha(t,[1 4])) ...
        nanmean(f.alpha(t,[2 3])) ...
        nanmean(f.alpha(t,[1 2])) ...
        nanmean(f.alpha(t,[3 4])) ...
        ...
        nanmean(f.beta(t,:)) ...
        nanmean(f.beta(t,[1 4])) ...
        nanmean(f.beta(t,[2 3])) ...
        nanmean(f.beta(t,[1 2])) ...
        nanmean(f.beta(t,[3 4])) ...
        ...
        nanmean(f.gamma(t,:)) ...
        nanmean(f.gamma(t,[1 4])) ...
        nanmean(f.gamma(t,[2 3])) ...
        nanmean(f.gamma(t,[1 2])) ...
        nanmean(f.gamma(t,[3 4])) ...
        ...
        nanmean(f.delta(t,:)) ...
        nanmean(f.delta(t,[1 4])) ...
        nanmean(f.delta(t,[2 3])) ...
        nanmean(f.delta(t,[1 2])) ...
        nanmean(f.delta(t,[3 4])) ...
        ...
        nanmean(f.theta(t,:)) ...
        nanmean(f.theta(t,[1 4])) ...
        nanmean(f.theta(t,[2 3])) ...
        nanmean(f.theta(t,[1 2])) ...
        nanmean(f.theta(t,[3 4])) ];
        
    observations = [observations ; row];
        k = k+1;
    end
end

observations = zscore(observations);
features = [cell2table(response') array2table(observations)];
features.Properties.VariableNames = varNames;
save(filename,'features');



%%%%%%%%%%%%%%%%%%%%%%%%%
Y2=features(:,1);
Y2=Y2.label;
Y3=1:size(Y2,1)
for i=1:size(Y2)
    if (strcmp(Y2(i),'no pain'))
        Y3(i)=0;
    else
        Y3(i)=1;
    end
end
Y2=Y3';

X2 = table2array(features(:,2:end));

%

f = load('andreas_pain_2501');
%reminder Fs is 10 Hz for freq data
filename = strcat(f.filename,'_feat');
k = 1;
varNames = {'label', ...
            'meanalpha','alphaback','alphafront','alphaleft','alpharight', ...
            'meanbeta' ,'betaback' ,'betafront' ,'betaleft' ,'betaright', ...
            'meangamma','gammaback','gammafront','gammaleft','gammaright', ...
            'meandelta','deltaback','deltafront','deltaleft','deltaright', ...
            'meantheta','thetaback','thetafront','thetaleft','thetaright' };
        
observations = [];
    
for t=1:size(f.alpha,1)
    if (~isempty(f.label{t}))
        response{k} = f.label{t};
        
        row = [nanmean(f.alpha(t,:)) ...
        nanmean(f.alpha(t,[1 4])) ...
        nanmean(f.alpha(t,[2 3])) ...
        nanmean(f.alpha(t,[1 2])) ...
        nanmean(f.alpha(t,[3 4])) ...
        ...
        nanmean(f.beta(t,:)) ...
        nanmean(f.beta(t,[1 4])) ...
        nanmean(f.beta(t,[2 3])) ...
        nanmean(f.beta(t,[1 2])) ...
        nanmean(f.beta(t,[3 4])) ...
        ...
        nanmean(f.gamma(t,:)) ...
        nanmean(f.gamma(t,[1 4])) ...
        nanmean(f.gamma(t,[2 3])) ...
        nanmean(f.gamma(t,[1 2])) ...
        nanmean(f.gamma(t,[3 4])) ...
        ...
        nanmean(f.delta(t,:)) ...
        nanmean(f.delta(t,[1 4])) ...
        nanmean(f.delta(t,[2 3])) ...
        nanmean(f.delta(t,[1 2])) ...
        nanmean(f.delta(t,[3 4])) ...
        ...
        nanmean(f.theta(t,:)) ...
        nanmean(f.theta(t,[1 4])) ...
        nanmean(f.theta(t,[2 3])) ...
        nanmean(f.theta(t,[1 2])) ...
        nanmean(f.theta(t,[3 4])) ];
        
    observations = [observations ; row];
        k = k+1;
    end
end

observations = zscore(observations);
features = [cell2table(response') array2table(observations)];
features.Properties.VariableNames = varNames;
save(filename,'features');



%%%%%%%%%%%%%%%%%%%%%%%%%
Y4=features(:,1);
Y4=Y4.label;
Y5=1:size(Y4,1)
for i=1:size(Y4)
    if (strcmp(Y4(i),'no pain'))
        Y5(i)=0;
    else
        Y5(i)=1;
    end
end
Y4=Y5';

X4 = table2array(features(:,2:end));



THRAS_ENTRY=X2;
THRAS_ENTRY_PAIN_MARKER=Y2;
ANDREAS_ENTRY=X2;
ANDREAS_ENTRY_PAIN_MARKER=Y2;








%
x = X2';
t = Y2';


% Create a Pattern Recognition Network
hiddenLayerSize = 1000;
net = patternnet(hiddenLayerSize);

% Setup Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 80/100;
net.divideParam.valRatio = 10/100;
net.divideParam.testRatio = 10/100;

% Train the Network
[net,tr] = train(net,x,t);

% Test the Network
y = net(ANDREAS_ENTRY');
t = ANDREAS_ENTRY_PAIN_MARKER';
e = gsubtract(t,y);
tind = vec2ind(t);
yind = vec2ind(y);
percentErrors = sum(tind ~= yind)/numel(tind);
performance = perform(net,t,y);

% View the Network
%view(net)

% Plots
% Uncomment these lines to enable various plots.
figure, plotperform(tr)
figure, plottrainstate(tr)
figure, plotconfusion(t,y)
figure, plotroc(t,y)
figure, ploterrhist(e)


break










%
%Cross test with 
testInput=table2array(features(:,2:end))';
test_expected=table2array(features(:,1))';
test_expected2=1:size(test_expected,1);
for i=1:size(test_expected,2)
    if (strcmp(test_expected(i),'no pain'))
        test_expected2(i)=0;
    else
        test_expected2(i)=1;
    end
end
output = net(testInput);
output(10)=0
plot(output',test_expected2,'x');

