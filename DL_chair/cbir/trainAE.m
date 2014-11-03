%% ======================================================================
%  Train the sparse autoencoder
%  This trains the sparse autoencoder on the unlabeled training
%  images. 

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
