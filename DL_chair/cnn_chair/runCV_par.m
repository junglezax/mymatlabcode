function [accTests, data_small] = runCV_par(k, data)
% run with K-fold cross validation
% k==0 for LeaveOneOut CV
	%example [accTests, data_small] = runCV_par()
	%        tic; [accTests, data_small] = runCV_par(data); toc
	%        tic; [accTests, data_small] = runCV_par(20, data); toc
	
	%matlab -nosplash (matlabpool need java)
	
	options = cnnOptions();
	
	startpool(options.coreNum);

	if ~exist('k', 'var')
		k = 10;
	end	
	  
	if ~exist('data', 'var')
		runOptions = cnnOptions();
		data = load_it(runOptions.imgDir, runOptions, true);
	end	

    data_small = rmfield(data, {'images', 'x'});
	
    m = numel(data_small.labels);
    
	if k == 0
		k = m;
	end

    if k > m
        k = m;
    end
    
	accTests = zeros(1, k);
	cp = cvpartition(data_small.labels, 'k', k);
	
	for i = 1:k
		trainSet = cp.training(i);

		sampleOut = sampleData4d(data_small.img_resized, data_small.labels, trainSet);
		
		fprintf('---------------------cycle %d------------------------\n', i);
        [~, predTest] = runIt_par('none', data_small, sampleOut);

		accTests(i) = mean(predTest(:) == sampleOut.testLabels(:));
	end

	fprintf('%d-fold cross validation, average accTest=%%%.2f-std=%%%.2f\n', k, 100*mean(accTests), std(accTests));
end

