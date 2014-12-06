%function [error_train, error_val, data_small, out, model, options] = drawLearnCurve()
	%matlab -nosplash
	
	options = cnnOptions();
	startpool(options.coreNum);

	if 1
		data = load_it(options.imgDir, options, true);
		data_small = rmfield(data, {'images', 'x'});
		
		% step1: compute feature filters, use unlabeled images
		model = trainLAE(data_small.img_resized, options);
		
		% step2: compute featureSet on labeled images
		labeledImages = cell2mat4d(data_small.img_resized);
		out = struct;
		
		disp('computing features...');
		features = cnnComputeFeature(model, labeledImages, options);
		disp('finish computing features...');
        out.featuers = features;
	end
	
	% step3: split featureSet to trainSet and testSet(validation set)
	m = numel(data_small.labels);
	trainSet = randsample(m, int32(m * 0.6));
	testSet = setdiff(1:m, trainSet);
	trainFeatures = features(:, trainSet);
	testFeatures = features(:, testSet);
	trainLabels = data_small.labels(trainSet);
	testLabels = data_small.labels(testSet);
	
	% step4: loop on trainSet
	mTrain = numel(trainSet);
	error_train = zeros(mTrain, 1);
	error_val = zeros(mTrain, 1);
	
	for i = 1:mTrain
		%fprintf('number of examples: %d\n', i);
	
		% use i examples of trainSet, i.e ith-trainSet, to train classifier
		iThTrainSet = randsample(mTrain, i);
		iThTrainData = trainFeatures(:, iThTrainSet);
		iThTrainLabels = trainLabels(iThTrainSet);
		
		%disp('training softmax...');
		options.softmaxLambda = 0.005;
		model.softmaxModel = trainSoftmax(iThTrainData, iThTrainLabels, options);
		%disp('finish training softmax...');
		
		% predict on ith-train set with this classifier, got err_tr(i)
		accTrain = testSoftmax(model.softmaxModel, iThTrainData, iThTrainLabels);
		fprintf('i=#%d, Train Accuracy: %2.3f%%\n', i, accTrain * 100);
		error_train(i) = 1 - accTrain;
		
		% predict on testSet with this classifier, got err_te(i)
		accTest = testSoftmax(model.softmaxModel, testFeatures, testLabels);
		error_val(i) = 1 - accTest;
	end
	
	% step5: draw curves using err_tr and err_te
	mTrain = numel(error_train);
	plot(1:mTrain, error_train, 1:mTrain, error_val);
	%plot(1:mTrain, error_train);
	%plot(1:mTrain, error_val);
	title('Learning curve')
	legend('Train', 'Cross Validation')
	xlabel('Number of training examples')
	ylabel('Error')
	axis([0 mTrain 0 1])

	fprintf('min(error_val)=%f, max(error_train)=%f\n', min(error_val), max(error_train));
	%fprintf('# Training Examples\tTrain Error\tCross Validation Error\n');
	for i = 1:mTrain
		%fprintf('  \t%d\t\t%f\t%f\n', i, error_train(i), error_val(i));
	end
	
	%save([options.dataDir 'learnCurveData.mat'], 'error_train', 'error_val', 'options', 'model', 'data_small', '-v7.3');
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%[error_tr, error_te] = learningCurve3(ftr, fte, sampleOut.trainData, sampleOut.trainLabels, sampleOut.testData, sampleOut.testLabels, options);

%end

