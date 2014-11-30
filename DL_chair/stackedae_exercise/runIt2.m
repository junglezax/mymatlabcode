function [acc, accFine, accAll, F1, pred, predFine, predAll, out, model, data] = runIt2()

%%======================================================================
%% STEP 0: relevant parameters
options = cnnOptions(true);

%options.inputSize  = options.imageDim * options.imageDim;
%% ======================================================================
% Load unlabeled data
data = load_it(options.imgDir, options, true);

%---------------------------
model = struct;

% PCA
[x1, xTilde, model.u, model.k, dg] = doPCA(data.x);

%model.k=700;
%fprintf('k=%d ratio=%f\n', k, sum(dg(1:k))/sum(dg));
%xTilde = u(:, 1:model.k)' * x1;

%---------------------------
if options.save
disp('saving..');
	%save('../../../data/chairs_10000_64x64.mat', 'data.x', 'fns', 'bad', 'x1', 'xTilde', 'u', 'k', 'dg');
	save('../../../data/chairs_10000_128x128.mat', 'data.x', 'fns', 'bad', 'x1', 'xTilde', 'u', 'k', 'dg');
end

% PCA faces
%display_network(u(:, 1:100));
%display_network(u(1:100, :)'); % meaningless

options.inputSize  = model.k;
data.unlabeledData = xTilde;

%% ======================================================================
% load labeled dataset
%labeled_data = load_it(labeledDir, runOptions, true);
data.labeledData = xTilde;
%--------------------------------
% sampling
%trainSet = [8, 6, 3, 2, 5, 64, 10, 16, 15, 12, 11, 18, 19, 25, 28, 22, 23, 33, 29, 31, 24, 43, 35, 38, 36, 48, 46, 34, 45, 39, 49, 50, 53, 52, 56, 70, 68, 61, 57, 67, 62, 63, 59, 73, 75, 71, 72, 78, 81, 79, 77, 90, 83, 95, 88, 91, 92, 85, 89];
%testSet = [1, 4, 7, 9, 13, 14, 17, 20, 21, 26, 27, 30, 32, 37, 40, 41, 42, 44, 47, 51, 54, 55, 58, 60, 65, 66, 69, 74, 76, 80, 82, 84, 86, 87, 93, 94];
%[trainData, trainLabels, testData, testLabels] = sampleData(data.labeledData, data.labels, trainSet, testSet);

out = struct;

[out.trainData, out.trainLabels, out.testData, out.testLabels, out.trainSet, out.testSet] = sampleData(data.labeledData, data.labels);

%----------------------------
% run stackedAE*2+softmax classification
[model, out] = stackedAETrain(data, out, model, options);
[acc, accFine, accAll, F1, pred, predFine, predAll] = stackedAETest(data, out, model, options);

end
