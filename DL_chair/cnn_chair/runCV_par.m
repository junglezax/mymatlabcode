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
	
	leaveOne = false;
	if k == 0
		leaveOne = true;
	end
	  
	if ~exist('data', 'var')
		runOptions = cnnOptions();
		data = load_it(runOptions.imgDir, runOptions, true);
	end	
	
	accTests = zeros(1, k);
    data_small = rmfield(data, {'images', 'x'});
	
    m = numel(data_small.labels);
    
    if k > m
        k = m;
    end
    
	if ~leaveOne
		indices = crossvalind('Kfold', data_small.labels, k);
	end
	
	cp = classperf(data_small.labels);
    
    if leaveOne
        loopMax = m;
    else
        loopMax = k;
    end
    
	for i = 1:loopMax
		if leaveOne
			[trainSet, testSet] = crossvalind('LeaveMOut', data_small.labels, 1);
		else
			testSet = find(indices == i);
			trainSet = setdiff(1:m, testSet); %~testSet;
		end

		sampleOut = sampleData4d(data_small.img_resized, data_small.labels, trainSet);
		
		fprintf('---------------------cycle %d------------------------\n', i);
        [~, predTest] = runIt_par('none', data_small, sampleOut)

		classperf(cp, predTest, testSet);
		accTests(i) = 1 - cp.ErrorRate;
		fprintf('cp.ErrorRate=%.2f\n', cp.ErrorRate);
	end
	
		fprintf('cross validation finished. cp.ErrorRate=%.2f\n', cp.ErrorRate);
		if leaveOne
			fprintf('LeaveOneOut cross validation, average accTest=%%%.2f-std=%%%.2f\n', 100*mean(accTests), std(accTests));
		else
			fprintf('%d-fold cross validation, average accTest=%%%.2f-std=%%%.2f\n', k, 100*mean(accTests), std(accTests));
		end
end

