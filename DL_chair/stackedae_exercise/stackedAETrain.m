function [model, out] = stackedAETrain(data, out, model, options)

%%======================================================================
%% Train the first sparse autoencoder

sae1Theta = initializeParameters(options.hiddenSizeL1, options.inputSize);

aeOptions.Method = 'lbfgs';
aeOptions.maxIter = options.maxIter;
aeOptions.display = options.display;

[model.sae1OptTheta, model.costAE1] = minFunc( @(p) sparseAutoencoderCost(p, ...
                                   options.inputSize, options.hiddenSizeL1, ...
                                   options.lambda, options.sparsityParam, ...
                                   options.beta, data.unlabeledData), ...
                              sae1Theta, aeOptions);
							  
%W1 = reshape(sae1OptTheta(1:hiddenSizeL1 * inputSize), hiddenSizeL1, inputSize);
%display_network(W1(1:81, :)');

%%======================================================================
%% STEP 3: Train the second sparse autoencoder
[sae1Features] = feedForwardAutoencoder(model.sae1OptTheta, options.hiddenSizeL1, ...
                                        options.inputSize, data.unlabeledData);

sae2Theta = initializeParameters(options.hiddenSizeL2, options.hiddenSizeL1);

[model.sae2OptTheta, model.costAE2] = minFunc( @(p) sparseAutoencoderCost(p, ...
                                   options.hiddenSizeL1, options.hiddenSizeL2, ...
                                   options.lambda, options.sparsityParam, ...
                                   options.beta, sae1Features), ...
                              sae2Theta, aeOptions);

%W1 = reshape(sae2OptTheta(1:hiddenSizeL2 * hiddenSizeL1), hiddenSizeL2, hiddenSizeL1);
%display_network(W1');

[sae2Features] = feedForwardAutoencoder(model.sae2OptTheta, options.hiddenSizeL2, ...
                                        options.hiddenSizeL1, sae1Features);

%disp('saving..');
%save('../../../data/chair_10000_64x64_sae_100_100.mat', 'sae1OptTheta', 'sae2OptTheta', 'sae1Features', 'sae2Features');

% load('../../../data/chair_10000_64x64_sae_100_100.mat')
%%======================================================================
%% STEP 4: Train the softmax classifier

% get features
[sae1Features_train] = feedForwardAutoencoder(model.sae1OptTheta, options.hiddenSizeL1, options.inputSize, out.trainData);
[sae2Features_train] = feedForwardAutoencoder(model.sae2OptTheta, options.hiddenSizeL2, options.hiddenSizeL1, sae1Features_train);
										
[sae1Features_test] = feedForwardAutoencoder(model.sae1OptTheta, options.hiddenSizeL1, options.inputSize, out.testData);
[sae2Features_test] = feedForwardAutoencoder(model.sae2OptTheta, options.hiddenSizeL2, options.hiddenSizeL1, sae1Features_test);

[sae1Features_all] = feedForwardAutoencoder(model.sae1OptTheta, options.hiddenSizeL1, options.inputSize, data.labeledData);										
[sae2Features_all] = feedForwardAutoencoder(model.sae2OptTheta, options.hiddenSizeL2, options.hiddenSizeL1, sae1Features_all);

%-------------------------
% softmax
%saeSoftmaxTheta = 0.005 * randn(options.hiddenSizeL2 * options.numClasses, 1);

softmaxOptions.maxIter = options.softmaxIter;
softmaxOptions.lambda = 1e-4;
model.softmaxModel = softmaxTrain(options.hiddenSizeL2, options.numClasses, softmaxOptions.lambda, ...
                            sae2Features_train, out.trainLabels, softmaxOptions);

saeSoftmaxOptTheta = model.softmaxModel.optTheta(:);

%%======================================================================
%% STEP 5: Finetune softmax model
stack = cell(2,1);
stack{1}.w = reshape(model.sae1OptTheta(1:options.hiddenSizeL1*options.inputSize), ...
                     options.hiddenSizeL1, options.inputSize);
stack{1}.b = model.sae1OptTheta(2*options.hiddenSizeL1*options.inputSize+1:2*options.hiddenSizeL1*options.inputSize+options.hiddenSizeL1);
stack{2}.w = reshape(model.sae2OptTheta(1:options.hiddenSizeL2*options.hiddenSizeL1), ...
                     options.hiddenSizeL2, options.hiddenSizeL1);
stack{2}.b = model.sae2OptTheta(2*options.hiddenSizeL2*options.hiddenSizeL1+1:2*options.hiddenSizeL2*options.hiddenSizeL1+options.hiddenSizeL2);

% Initialize the parameters for the deep model
[stackparams, model.netconfig] = stack2params(stack);
model.stackedAETheta = [ saeSoftmaxOptTheta ; stackparams ];

%% ------------------------------------------------------
% finetuning
[model.stackedAEOptTheta, model.costFine] = minFunc( @(p) stackedAECost(p, options.inputSize, options.hiddenSizeL2, ...
                                              options.numClasses, model.netconfig, ...
                                              options.lambda, out.trainData, out.trainLabels), ...
                              model.stackedAETheta, options);

%% ------------------------------------------------------
% train svm
if strcmp(options.classMethod, 'svm')
	[sae2Features_train_tuned] = stackedAEEncoder(model.stackedAEOptTheta, options.hiddenSizeL2, options.numClasses, netconfig, out.trainData);
	[model.multiSVMmodels, model.usedLabels]= multisvm_train(sae2Features_train_tuned', out.trainLabels);
else
	model.multiSVMmodels = [];
	model.usedLabels = [];
end

end
