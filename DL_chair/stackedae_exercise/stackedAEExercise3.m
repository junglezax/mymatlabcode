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

%[x, xTilde, u, k, fns, bad] = read_chairs3(patchSize);
load('../../../data/furniture_20000_64x64.mat');
inputSize  = k;
unlabeledData = xTilde;

%W1 = reshape(xTilde(:, 1), k, 1);
%display_network(W1);

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
%display_network(W1');
%t = W1(:, 1:81);
%display_network(t);


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
%save('../../../data/furniture_20000_64x64_sae_100_100.mat', 'sae1OptTheta', 'sae2OptTheta');

% load('../../../data/furniture_20000_64x64_sae_100_100.mat')
%%======================================================================
%% STEP 4: Train the softmax classifier

%%-----------------------------------------------
% load labeled dataset
[images_labeled, x_labeled, allLabels] = read_chairs2(patchSize);
x_labeled = bsxfun(@minus, x_labeled , mean(x_labeled));
xTilde_labeled = u(:, 1:k)' * x_labeled;

%---------------------------
disp('saving..');
save('../../../data/chair_labeled_97_png_64x64.mat', 'images_labeled', 'x_labeled');

%[xTilde_labeled, u_labeled, k_labeled] = doPCA(x_labeled);

%---------------------------
% sample
[trainData, trainLabels, testData, testLabels] = read_chairs2_sample(xTilde_labeled, allLabels);

%---------------------------
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
