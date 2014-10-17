%% ======================================================================
%  relevant parameters values

patchSize = 64;
inputSize  = patchSize * patchSize;
numLabels  = 35;
hiddenSize = 50;
sparsityParam = 0.1; % desired average activation of the hidden units.
                     % (This was denoted by the Greek alphabet rho, which looks like a lower-case "p",
		             %  in the lecture notes). 
lambda = 3e-3;       % weight decay parameter       
beta = 3;            % weight of sparsity penalty term   
maxIter = 400;

%% ======================================================================
% Load chair database files
read_chairs;

%% ======================================================================
%  Train the sparse autoencoder
useAE = true;
trainAE;


%%======================================================================
%% extract features
	trainFeatures = extractFeatures(opttheta, hiddenSize, inputSize, trainData, useAE);
	testFeatures = extractFeatures(opttheta, hiddenSize, inputSize, testData, useAE);
	allFeatures = extractFeatures(opttheta, hiddenSize, inputSize, chairData, useAE);
		
%%======================================================================
%% Train the softmax classifier

lambda = 1e-4;
options.maxIter = 100;
featureSize = size(trainFeatures, 1);
softmaxModel = softmaxTrain(featureSize, numLabels, 1e-4, ...
                            trainFeatures, trainLabels, options);

%%======================================================================
%% Testing 
% Compute Predictions on the test set (testFeatures) using softmaxPredict
% and softmaxModel

[pred] = softmaxPredict(softmaxModel, testFeatures);

%% -----------------------------------------------------
% Classification Score
pp = sum(pred(:) == testLabels(:));
tt = numel(testLabels);
fprintf('Test Accuracy on test examples: %d/%d = %f%%\n', pp, tt, 100*pp/tt);

%% -----------------------------------------------------
% test all examples
[pred1] = softmaxPredict(softmaxModel, allFeatures);
pp = sum(pred1(:) == chairLabels2(:));
tt = numel(chairLabels2);
fprintf('Test Accuracy on all examples: %d/%d = %f%%\n', pp, tt, 100*pp/tt);

pr1 = pred1(:);
lb1 = chairLabels2(:);

levels = unique(lb1);
for i = 1:numel(levels)
	pp = sum(pr1 == lb1 & lb1 == levels(i));
	tt = sum(lb1 == levels(i));
	fprintf('Test Accuracy of class #%d: %d/%d = %f%%\n', levels(i), pp, tt, 100 * pp./ tt);
end

[F1, prec, rec] = f1_score(lb1, pr1);
fprintf('F1 score: %f%%\n', 100 * F1);
