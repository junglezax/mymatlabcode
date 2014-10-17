%% ======================================================================
%  relevant parameters values

patchSize = 64;
inputSize  = patchSize * patchSize;
numLabels  = 2;
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

%---------------------------
% PCA
x = train_x';
avg = mean(x);
x1 = x - repmat(avg, size(x, 1), 1);

sigma = x1 * x1' / size(x1, 2);

[u, s, v] = svd(sigma);

dg = diag(s);
sdg = sum(dg);
for k=1:length(dg)
	if sum(dg(1:k))/sdg >= 0.99
		break
	end
end
k
sum(dg(1:k))/sdg

k=81; % 81 for visualization
sum(dg(1:k))/sdg

xTilde = u(:, 1:k)' * x1;

inputSize = k;
%---------------------------
chairData   = xTilde;
chairLabels = ischair + 1;

% Set Unlabeled Set (All Images)

% Simulate a Labeled and Unlabeled set
m = size(chairData, 2);
labeledSet   = 1:m;
unlabeledSet = 1:m;

[trainSet, testSet] = mysample(chairLabels);

unlabeledData = chairData(:, unlabeledSet);

trainData   = chairData(:, trainSet);
trainLabels = chairLabels(trainSet)';

testData   = chairData(:, testSet);
testLabels = chairLabels(testSet)';

% Output Some Statistics
fprintf('# examples in unlabeled set: %d\n', size(unlabeledData, 2));
fprintf('# examples in supervised training set: %d\n\n', size(trainData, 2));
fprintf('# examples in supervised testing set: %d\n\n', size(testData, 2));

%% ======================================================================
%  Train the sparse autoencoder
%  This trains the sparse autoencoder on the unlabeled training
%  images. 

useAE = true;

if useAE

%  Randomly initialize the parameters
theta = initializeParameters(hiddenSize, inputSize);

opttheta = theta; 

addpath ../minFunc/
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

% test all examples
[pred1] = softmaxPredict(softmaxModel, allFeatures);
fprintf('Test Accuracy on all examples: %f%%\n', 100*mean(pred1(:) == chairLabels(:)));

pr1 = pred1(:);
lb1 = chairLabels(:);

negp = sum(pr1 == lb1 & lb1 == 1);
negt = sum(lb1 == 1);
fprintf('Test Accuracy Neg: %d/%d = %f%%\n', negp, negt, 100 * negp./ negt);

posp = sum(pr1 == lb1 & lb1 == 2);
post = sum(lb1 == 2);
fprintf('Test Accuracy Pos: %d/%d = %f%%\n', posp, post, 100 * posp./ post);

[F1, prec, rec] = f1_score(lb1, pr1);
fprintf('F1 score: %f%%\n', 100 * F1);
