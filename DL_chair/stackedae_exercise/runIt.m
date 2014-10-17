%% ======================================================================
% Load chair database files

%%-----------------------------------------------
% load labeled dataset
load('../../../data/chair_labeled_97_png_64x64.mat');

[xTilde_labeled, u, inputSize] = doPCA(x_labeled);

unlabeledData = xTilde_labeled; % use same dataset

%---------------------------
% sampling

trainSet = [8, 6, 3, 2, 5, 64, 10, 16, 15, 12, 11, 18, 19, 25, 28, 22, 23, 33, 29, 31, 24, 43, 35, 38, 36, 48, 46, 34, 45, 39, 49, 50, 53, 52, 56, 70, 68, 61, 57, 67, 62, 63, 59, 73, 75, 71, 72, 78, 81, 79, 77, 90, 83, 95, 88, 91, 92, 85, 89];

testSet = [1, 4, 7, 9, 13, 14, 17, 20, 21, 26, 27, 30, 32, 37, 40, 41, 42, 44, 47, 51, 54, 55, 58, 60, 65, 66, 69, 74, 76, 80, 82, 84, 86, 87, 93, 94];

%[trainData, trainLabels, testData, testLabels, trainSet, testSet] = read_chairs2_sample(xTilde_labeled, allLabels);
[trainData, trainLabels, testData, testLabels] = read_chairs2_sample(xTilde_labeled, allLabels, trainSet, testSet);

%----------------------------
% run stackedAE*2+softmax classification
stackedAEExercise5;

