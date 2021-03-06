function [trainData, trainLabels, testData, testLabels, trainSet, testSet] = sampleData4d(x, allLabels, trainSet, testSet);
	% sample
	% x: 4-d matrix, for example a matrix of m images, r*c*3*m
	m = size(x, 4);
	
	labeledSet   = 1:m;

	if ~exist('trainSet', 'var')
		[trainSet, testSet] = mysample(allLabels);
	elseif ~exist('testSet', 'var')
		testSet = setdiff(labeledSet, trainSet);
	end

	trainData   = x(:, :, :, trainSet);
	trainLabels = allLabels(trainSet)';

	testData   = x(:, :, :, testSet);
	testLabels = allLabels(testSet)';

	% Output Some Statistics
	%fprintf('# examples in unlabeled set: %d\n', size(unlabeledData, 2));
	fprintf('# examples in supervised training set: %d\n\n', size(trainData, 2));
	fprintf('# examples in supervised testing set: %d\n\n', size(testData, 2));
end
