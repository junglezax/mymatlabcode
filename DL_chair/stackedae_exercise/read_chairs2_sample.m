function [trainData, trainLabels, testData, testLabels, trainSet, testSet] = read_chairs2_sample(x, allLabels, trainSet, testSet)
	%---------------------------
	% sample
	m = size(x, 2);
	
	labeledSet   = 1:m;
	%unlabeledSet = 1:m;

	if ~exist('trainSet', 'var')
		[trainSet, testSet] = mysample(allLabels);
	elseif ~exist('testSet', 'var')
		testSet = setdiff(labeledSet, trainSet);
	end
	

	%unlabeledData = x(:, unlabeledSet);

	trainData   = x(:, trainSet);
	trainLabels = allLabels(trainSet)';

	testData   = x(:, testSet);
	testLabels = allLabels(testSet)';

	% Output Some Statistics
	%fprintf('# examples in unlabeled set: %d\n', size(unlabeledData, 2));
	fprintf('# examples in supervised training set: %d\n\n', size(trainData, 2));
	fprintf('# examples in supervised testing set: %d\n\n', size(testData, 2));
end
