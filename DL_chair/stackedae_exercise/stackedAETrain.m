
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
%display_network(W1(1:81, :)');

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

[sae1Features_all] = feedForwardAutoencoder(sae1OptTheta, hiddenSizeL1, inputSize, labeledData);										
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

%% ------------------------------------------------------
% train svm
if strcmp(classMethod, 'svm')
	[sae2Features_train_tuned] = stackedAEEncoder(stackedAEOptTheta, hiddenSizeL2, numClasses, netconfig, trainData);
	[multiSVMmodels, usedLabels]= multisvm_train(sae2Features_train_tuned', trainLabels);
else
	multiSVMmodels = [];
	usedLabels = [];
end

