function [accTests, data_small] = runCV_par(k, data)
% run with cross validation
	%example [accTests, data_small] = runCV_par()
	%        tic; [accTests, data_small] = runCV_par(data); toc
	%        tic; [accTests, data_small] = runCV_par(20, data); toc
	
	coreNum = 12;
	if matlabpool('size') <= 0
		disp('opening matlabpool....');
		matlabpool('open', 'local', coreNum);
	else
		disp('Already initialized');
	end

	if ~exist('k', 'var')
		k = 10;
	end	
	  
	if ~exist('data', 'var')
		runOptions = cnnOptions();
		data = load_it(runOptions.imgDir, runOptions, true);
	end	
	
	accTests = zeros(1, k);
    data_small = rmfield(data, {'images', 'x'});
	
	indices = crossvalind('Kfold', data_small.labels, k);
	cp = classperf(data_small.labels);
	for i = 1:k
		testSet = (indices == i);
        trainSet = ~testSet;
		
		sampleOut = sampleData4d(data.img_resized, data.labels, trainSet, testSet);
		
		fprintf('---------------------cycle %d------------------------\n', i);
        [~, predTest] = runIt_par('none', data, sampleOut);

		classperf(cp, predTest, testSet);
		accTests(i) = 1 - cp.ErrorRate;
		fprintf('cp.ErrorRate=%.2f\n', cp.ErrorRate);
	end
	fprintf('cross validation finished. cp.ErrorRate=%.2f\n', cp.ErrorRate);

	fprintf('%d-fold cross validation, average accTest=%%%.2f-std=%%%.2f\n', k, 100*mean(accTests), std(accTests));
end

