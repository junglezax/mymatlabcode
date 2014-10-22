%% CS294A/CS294W Programming Assignment Starter Code
% user 1 AE to extract features from patches of furniture images
% use 97 image set

%%======================================================================
%% parameters

scaledSize = 512;
patchsize = 8;  % we'll use 8x8 patches 
visibleSize = patchsize*patchsize;   % number of input units 
hiddenSize = 25;     % number of hidden units 
sparsityParam = 0.01;   % desired average activation of the hidden units.
lambda = 0.0001;     % weight decay parameter       
beta = 3;            % weight of sparsity penalty term       
useLinear = true; % whether use linear autoencoder

%%======================================================================
% load image data
[images, img_gray, x, allLabels] = read_chairs2(scaledSize);

%%======================================================================
%% sampleIMAGES
patches = sampleIMAGES_chair(img_gray, patchsize);

%display_network(x(:, 1:36));
%display_network(patches(:,randi(size(patches,2),100,1)),8);
%display_network(patches(:, 1:36));

%%======================================================================
%% training your sparse autoencoder with minFunc (L-BFGS).

%  Randomly initialize the parameters
theta = initializeParameters(hiddenSize, visibleSize);

%  Use minFunc to minimize the function
options.Method = 'lbfgs';
options.maxIter = 400;	  % Maximum number of iterations of L-BFGS to run 
options.display = 'on';

tic

if useLinear
	[opttheta, cost] = minFunc( @(p) sparseAutoencoderLinearCost(p, ...
                                   visibleSize, hiddenSize, ...
                                   lambda, sparsityParam, ...
                                   beta, patches), ...
                              theta, options);
else
	[opttheta, cost] = minFunc( @(p) sparseAutoencoderCost(p, ...
                                   visibleSize, hiddenSize, ...
                                   lambda, sparsityParam, ...
                                   beta, patches), ...
                              theta, options);
end

toc
%%======================================================================
%% Visualization 

W1 = reshape(opttheta(1:hiddenSize*visibleSize), hiddenSize, visibleSize);
display_network(W1', 12);
