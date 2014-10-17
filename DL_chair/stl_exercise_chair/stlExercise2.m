%% ======================================================================
%  relevant parameters values

patchSize = 64;
inputSize  = patchSize * patchSize;
numLabels  = 12;
hiddenSize = 100;
sparsityParam = 0.1; % desired average activation of the hidden units.
                     % (This was denoted by the Greek alphabet rho, which looks like a lower-case "p",
		             %  in the lecture notes). 
lambda = 3e-3;       % weight decay parameter       
beta = 3;            % weight of sparsity penalty term   
maxIter = 400;

%% ======================================================================
% Load chair database files
read_chairs2;

%% ======================================================================
%  Train the sparse autoencoder
%  This trains the sparse autoencoder on the unlabeled training
%  images. 

useAE = false;

if useAE

%  Randomly initialize the parameters
theta = initializeParameters(hiddenSize, inputSize);

opttheta = theta; 

%addpath ../minFunc/
options.Method = 'lbfgs';
options.maxIter = maxIter;
options.display = 'on';

tic
[opttheta, cost] = minFunc( @(p) sparseAutoencoderCost(p, ...
                                   inputSize, hiddenSize, ...
                                   lambda, sparsityParam, ...
                                   beta, unlabeledData), ...
                              theta, options);

toc

%% -----------------------------------------------------
% Visualize weights

%W1 = reshape(opttheta(1:hiddenSize * inputSize), hiddenSize, inputSize);
%display_network(W1');

%%======================================================================
%% Extract Features from the Supervised Dataset
trainFeatures = feedForwardAutoencoder(opttheta, hiddenSize, inputSize, ...
                                       trainData);

testFeatures = feedForwardAutoencoder(opttheta, hiddenSize, inputSize, ...
                                       testData);

allFeatures = feedForwardAutoencoder(opttheta, hiddenSize, inputSize, ...
                                       chairData);

featureSize = hiddenSize;

else % not use AE

trainFeatures = trainData;

testFeatures = testData;

allFeatures = chairData;

featureSize = inputSize;
end

%%======================================================================
%% Train the softmax classifier

lambda = 1e-4;
options.maxIter = 100;
softmaxModel = softmaxTrain(featureSize, numLabels, 1e-4, ...
                            trainFeatures, trainLabels, options);

%%======================================================================
%% Testing 
% Compute Predictions on the test set (testFeatures) using softmaxPredict
% and softmaxModel

[pred] = softmaxPredict(softmaxModel, testFeatures);

%% -----------------------------------------------------
% Classification Score
fprintf('Test Accuracy: %f%%\n', 100*mean(pred(:) == testLabels(:)));

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
