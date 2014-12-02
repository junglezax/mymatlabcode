function sampleOut = sampleData4d(x, allLabels, trainSet, testSet);
	% sample
	% x: cell matrix, for example a matrix of m images, each r*c*3
	m = numel(x);
	
	labeledSet   = 1:m;

	if ~exist('trainSet', 'var')
		[trainSet, testSet] = mysample(allLabels);
	elseif ~exist('testSet', 'var')
		testSet = setdiff(labeledSet, trainSet);
	end

	trainData   = cell2mat4d(x(trainSet));
	trainLabels = allLabels(trainSet)';

	testData   = cell2mat4d(x(testSet));
	testLabels = allLabels(testSet)';

	sampleOut = struct;
	sampleOut.trainSet = trainSet;
	sampleOut.testSet = testSet;
	sampleOut.trainLabels = trainLabels;
	sampleOut.testLabels = testLabels;
	sampleOut.trainData = trainData;
	sampleOut.testData = testData;
	
	% Output Some Statistics
	%fprintf('# examples in supervised training set: %d\n\n', numel(trainSet));
	%fprintf('# examples in supervised testing set: %d\n\n', numel(testSet));
end
