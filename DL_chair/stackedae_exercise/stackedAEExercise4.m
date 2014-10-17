%% CS294A/CS294W Stacked Autoencoder Exercise
%%======================================================================
%% STEP 0: relevant parameters

patchSize = 64;
inputSize  = patchSize * patchSize;
numClasses  = 12;
hiddenSizeL1 = 100;   % Layer 1 Hidden Size
hiddenSizeL2 = 100;   % Layer 2 Hidden Size
sparsityParam = 0.1;   % desired average activation of the hidden units.
lambda = 3e-3;         % weight decay parameter       
beta = 3;              % weight of sparsity penalty term       
maxIter = 400;

%% ======================================================================
% Load chair database files

%[x, fns, bad] = read_chairs4(patchSize);

load('../../../data/chairs_10000_64x64.mat');

%---------------------------
% PCA
[x1, xTilde, u, k, dg] = doPCA(x);

k=500;
fprintf('k=%d ratio=%f\n', k, sum(dg(1:k))/sum(dg));
xTilde = u(:, 1:k)' * x1;
%---------------------------
%disp('saving..');
%save('../../../data/chairs_10000_64x64.mat', 'x', 'fns', 'bad', 'x1', 'xTilde', 'u', 'k', 'dg');

% PCA faces
%display_network(u(:, 1:100));
%display_network(u(1:100, :)'); % meaningless

inputSize  = k;
unlabeledData = xTilde;

%%-----------------------------------------------
% load labeled dataset
%[images_labeled, x_labeled, allLabels] = read_chairs2(patchSize);
%disp('saving..');
%save('../../../data/chair_labeled_97_png_64x64.mat', 'images_labeled', 'x_labeled', 'allLabels');

load('../../../data/chair_labeled_97_png_64x64.mat');

x_labeled1 = bsxfun(@minus, x_labeled, mean(x_labeled));
xTilde_labeled = u(:, 1:k)' * x_labeled1;

%--------------------------------
% sampling
trainSet = [8, 6, 3, 2, 5, 64, 10, 16, 15, 12, 11, 18, 19, 25, 28, 22, 23, 33, 29, 31, 24, 43, 35, 38, 36, 48, 46, 34, 45, 39, 49, 50, 53, 52, 56, 70, 68, 61, 57, 67, 62, 63, 59, 73, 75, 71, 72, 78, 81, 79, 77, 90, 83, 95, 88, 91, 92, 85, 89];
testSet = [1, 4, 7, 9, 13, 14, 17, 20, 21, 26, 27, 30, 32, 37, 40, 41, 42, 44, 47, 51, 54, 55, 58, 60, 65, 66, 69, 74, 76, 80, 82, 84, 86, 87, 93, 94];

[trainData, trainLabels, testData, testLabels] = read_chairs2_sample(xTilde_labeled, allLabels, trainSet, testSet);

%%======================================================================
%% STEP 2: Train the first sparse autoencoder
tic

sae1Theta = initializeParameters(hiddenSizeL1, inputSize);

options.Method = 'lbfgs';
options.maxIter = 400;
options.display = 'on';

[sae1OptTheta, cost] = minFunc( @(p) sparseAutoencoderCost(p, ...
                                   inputSize, hiddenSizeL1, ...
                                   lambda, sparsityParam, ...
                                   beta, unlabeledData), ...
                              sae1Theta, options);
							  
%W1 = reshape(sae1OptTheta(1:hiddenSizeL1 * inputSize), hiddenSizeL1, inputSize);
%display_network(W1(1:9, :)');

%%======================================================================
%% STEP 3: Train the second sparse autoencoder
[sae1Features] = feedForwardAutoencoder(sae1OptTheta, hiddenSizeL1, ...
                                        inputSize, unlabeledData);

sae2Theta = initializeParameters(hiddenSizeL2, hiddenSizeL1);

[sae2OptTheta, cost] = minFunc( @(p) sparseAutoencoderCost(p, ...
                                   hiddenSizeL1, hiddenSizeL2, ...
                                   lambda, sparsityParam, ...
                                   beta, sae1Features), ...
                              sae2Theta, options);

toc

%W1 = reshape(sae2OptTheta(1:hiddenSizeL2 * hiddenSizeL1), hiddenSizeL2, hiddenSizeL1);
%display_network(W1');

[sae2Features] = feedForwardAutoencoder(sae2OptTheta, hiddenSizeL2, ...
                                        hiddenSizeL1, sae1Features);

%disp('saving..');
%save('../../../data/chair_10000_64x64_sae_100_100.mat', 'sae1OptTheta', 'sae2OptTheta', 'sae1Features', 'sae2Features');

% load('../../../data/chair_10000_64x64_sae_100_100.mat')
%%======================================================================
%% STEP 4: Train the softmax classifier

% get features
[sae1Features_train] = feedForwardAutoencoder(sae1OptTheta, hiddenSizeL1, inputSize, trainData);
[sae2Features_train] = feedForwardAutoencoder(sae2OptTheta, hiddenSizeL2, hiddenSizeL1, sae1Features_train);
										
[sae1Features_test] = feedForwardAutoencoder(sae1OptTheta, hiddenSizeL1, inputSize, testData);
[sae2Features_test] = feedForwardAutoencoder(sae2OptTheta, hiddenSizeL2, hiddenSizeL1, sae1Features_test);

[sae1Features_all] = feedForwardAutoencoder(sae1OptTheta, hiddenSizeL1, inputSize, xTilde_labeled);										
[sae2Features_all] = feedForwardAutoencoder(sae2OptTheta, hiddenSizeL2, hiddenSizeL1, sae1Features_all);

%-------------------------
% softmax
saeSoftmaxTheta = 0.005 * randn(hiddenSizeL2 * numClasses, 1);

options.maxIter = 100;
lambda = 1e-4;
softmaxModel = softmaxTrain(hiddenSizeL2, numClasses, lambda, ...
                            sae2Features_train, trainLabels, options);

saeSoftmaxOptTheta = softmaxModel.optTheta(:);

%%======================================================================
%% STEP 5: Finetune softmax model
stack = cell(2,1);
stack{1}.w = reshape(sae1OptTheta(1:hiddenSizeL1*inputSize), ...
                     hiddenSizeL1, inputSize);
stack{1}.b = sae1OptTheta(2*hiddenSizeL1*inputSize+1:2*hiddenSizeL1*inputSize+hiddenSizeL1);
stack{2}.w = reshape(sae2OptTheta(1:hiddenSizeL2*hiddenSizeL1), ...
                     hiddenSizeL2, hiddenSizeL1);
stack{2}.b = sae2OptTheta(2*hiddenSizeL2*hiddenSizeL1+1:2*hiddenSizeL2*hiddenSizeL1+hiddenSizeL2);

% Initialize the parameters for the deep model
[stackparams, netconfig] = stack2params(stack);
stackedAETheta = [ saeSoftmaxOptTheta ; stackparams ];

%% ------------------------------------------------------
% finetuning
options.maxIter = 400;
tic
[stackedAEOptTheta, cost] = minFunc( @(p) stackedAECost(p, inputSize, hiddenSizeL2, ...
                                              numClasses, netconfig, ...
                                              lambda, trainData, trainLabels), ...
                              stackedAETheta, options);
toc

%%======================================================================
%% STEP 6: Test 

[pred] = stackedAEPredict(stackedAETheta, inputSize, hiddenSizeL2, ...
                          numClasses, netconfig, testData);

acc = mean(testLabels(:) == pred(:));
fprintf('Before Finetuning Test Accuracy: %0.3f%%\n', acc * 100);

[pred] = stackedAEPredict(stackedAEOptTheta, inputSize, hiddenSizeL2, ...
                          numClasses, netconfig, testData);

acc = mean(testLabels(:) == pred(:));
fprintf('After Finetuning Test Accuracy: %0.3f%%\n', acc * 100);

%% -----------------------------------------------------
% test all examples
[pred1] = stackedAEPredict(stackedAEOptTheta, inputSize, hiddenSizeL2, ...
                          numClasses, netconfig, xTilde_labeled);
						  
pp = sum(pred1(:) == allLabels(:));
tt = numel(allLabels);
fprintf('Test Accuracy on all examples: %d/%d = %f%%\n', pp, tt, 100*pp/tt);

pr1 = pred1(:);
lb1 = allLabels(:);

levels = unique(lb1);
for i = 1:numel(levels)
	pp = sum(pr1 == lb1 & lb1 == levels(i));
	tt = sum(lb1 == levels(i));
	fprintf('Test Accuracy of class #%d: %d/%d = %f%%\n', levels(i), pp, tt, 100 * pp./ tt);
end

[F1, prec, rec] = f1_score(lb1, pr1);
fprintf('F1 score: %f%%\n', 100 * F1);
