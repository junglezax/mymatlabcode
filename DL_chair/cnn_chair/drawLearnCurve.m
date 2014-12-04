function [error_train, error_val, data, out, model, options] = drawLearnCurve()
	%matlab -nosplash
	
	coreNum = 12;
	if matlabpool('size') <= 0
		disp('opening matlabpool....');
		matlabpool('open', 'local', coreNum);
	else
		% matlabpool close
		% matlabpool('open', 'local', coreNum);
		disp('Already initialized');
	end
	
	options = cnnOptions();
	
	if ~exist('data', 'var')
		data = load_it(options.imgDir, options, true);
	end	
	
	% step1: compute feature filters, use unlabeled images
	model = trainLAE(data.img_resized, options);
	
	% step2: compute featureSet on labeled images
	labeledImages = cell2mat4d(data.img_resized);
	out = struct;
	
	disp('computing features...');
	out.features = cnnComputeFeature_par(model, labeledImages, options);
	disp('finish computing features...');
	
	% step3: split featureSet to trainSet and testSet(validation set)
	m = numel(data.labels);
	trainSet = randsample(m, m * 0.6);
	testSet = setdiff(1:m, trainSet);
	trainFeatures = out.features(:, trainSet);
	testFeatures = out.features(:, testSet);
	trainLabels = data.labels(trainSet);
	testLabels = data.labels(testSet);
	
	% step4: loop on trainSet
	mTrain = numel(trainSet);
	error_train = zeros(mTrain, 1);
	error_val = zeros(mTrain, 1);
	
	for i = 1:mTrain
		fprintf('number of examples: %d\n', i);
	
		% use i examples of trainSet, i.e ith-trainSet, to train classifier
		iThTrainSet = 1:i;
		iThTrainData = trainFeatures(:, iThTrainSet);
		iThTrainLabels = trainLabels(iThTrainSet);
		
		disp('training softmax...');
		model.softmaxModel = trainSoftmax(iThTrainData, iThTrainLabels, options);
		disp('finish training softmax...');
		
		% predict on ith-train set with this classifier, got err_tr(i)
		disp('predicting for train data')
		accTrain = testSoftmax(model.softmaxModel, iThTrainData, iThTrainLabels);
		error_train(i) = 1 - accTrain;
		disp('finish for train data')
		
		% predict on testSet with this classifier, got err_te(i)
		accTest = testSoftmax(model.softmaxModel, testFeatures, testLabels);
		error_val(i) = 1 - accTest;
	end
	
	% step5: draw curves using err_tr and err_te
	plot(1:mTrain, error_train, 1:mTrain, error_val);
	title('Learning curve')
	legend('Train', 'Cross Validation')
	xlabel('Number of training examples')
	ylabel('Error')
	axis([0 13 0 150])

	fprintf('# Training Examples\tTrain Error\tCross Validation Error\n');
	for i = 1:mTrain
		fprintf('  \t%d\t\t%f\t%f\n', i, error_train(i), error_val(i));
	end
		
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%[error_tr, error_te] = learningCurve3(ftr, fte, sampleOut.trainData, sampleOut.trainLabels, sampleOut.testData, sampleOut.testLabels, options);

end

