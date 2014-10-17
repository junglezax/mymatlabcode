%%======================================================================
%% STEP 0: relevant parameters

patchSize = 128;
inputSize  = patchSize * patchSize;
numClasses  = 12;
hiddenSizeL1 = 100;   % Layer 1 Hidden Size
hiddenSizeL2 = 100;   % Layer 2 Hidden Size
sparsityParam = 0.1;   % desired average activation of the hidden units.
lambda = 3e-3;         % weight decay parameter       
beta = 3;              % weight of sparsity penalty term       
maxIter = 400;
classMethod = 'svm'; % softmax/svm

%% ======================================================================
% Load unlabeled data

[x, fns, bad] = read_chairs4(patchSize);
%load('../../../data/chairs_10000_64x64.mat');

%---------------------------
% PCA
[x1, xTilde, u, k, dg] = doPCA(x);

%k=700;
%fprintf('k=%d ratio=%f\n', k, sum(dg(1:k))/sum(dg));
%xTilde = u(:, 1:k)' * x1;
%---------------------------
disp('saving..');
%save('../../../data/chairs_10000_64x64.mat', 'x', 'fns', 'bad', 'x1', 'xTilde', 'u', 'k', 'dg');
save('../../../data/chairs_10000_128x128.mat', 'x', 'fns', 'bad', 'x1', 'xTilde', 'u', 'k', 'dg');

% PCA faces
%display_network(u(:, 1:100));
%display_network(u(1:100, :)'); % meaningless

inputSize  = k;
unlabeledData = xTilde;

%% ======================================================================
% load labeled dataset
[images_labeled, x_labeled, allLabels] = read_chairs2(patchSize);
disp('saving..');
save('../../../data/chair_labeled_97_png_128x128.mat', 'images_labeled', 'x_labeled', 'allLabels');

%load('../../../data/chair_labeled_97_png_64x64.mat');

x_labeled1 = bsxfun(@minus, x_labeled , mean(x_labeled));
xTilde_labeled = u(:, 1:k)' * x_labeled1;

labeledData = xTilde_labeled;

%--------------------------------
% sampling
trainSet = [8, 6, 3, 2, 5, 64, 10, 16, 15, 12, 11, 18, 19, 25, 28, 22, 23, 33, 29, 31, 24, 43, 35, 38, 36, 48, 46, 34, 45, 39, 49, 50, 53, 52, 56, 70, 68, 61, 57, 67, 62, 63, 59, 73, 75, 71, 72, 78, 81, 79, 77, 90, 83, 95, 88, 91, 92, 85, 89];
testSet = [1, 4, 7, 9, 13, 14, 17, 20, 21, 26, 27, 30, 32, 37, 40, 41, 42, 44, 47, 51, 54, 55, 58, 60, 65, 66, 69, 74, 76, 80, 82, 84, 86, 87, 93, 94];

[trainData, trainLabels, testData, testLabels] = read_chairs2_sample(labeledData, allLabels, trainSet, testSet);

%----------------------------
% run stackedAE*2+softmax classification
stackedAETrain;
stackedAETest;
