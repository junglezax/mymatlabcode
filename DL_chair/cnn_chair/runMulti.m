function [accTests, accAlls, useTimes, runOptions, model, out, data] = runMulti(cnt, dataFrom, data)
	%example [accTests, accAlls, useTimes, runOptions, model, out, data] = runMulti(3);
	%        tic; [accTests, accAlls, useTimes, runOptions, model, out, data] = runMulti(3, 'none', data); toc
	
	if ~exist('dataFrom', 'var')
		dataFrom = 'read';
	end
	
	if ~exist('data', 'var')
		data = struct;
	end

	accTests = zeros(1, cnt);
	accAlls = zeros(1, cnt);
	useTimes = zeros(1, cnt);

	fprintf('---------------------cycle %d------------------------\n', 1);
	tic();
	[accTest, predTest, accAll, predAll, runOptions, model, out, data] = runIt(dataFrom, data);
	accTests(1) = accTest;
	accAlls(1) = accAll;
	useTimes(1) = toc();
	
	for i = 2:cnt
		tic();
		fprintf('---------------------cycle %d------------------------\n', i);
		[accTest, predTest, accAll, predAll, runOptions, model, out, data] = runIt('none', data);
		accTests(i) = accTest;
		accAlls(i) = accAll;
		useTimes(i) = toc();
	end
	
	fprintf('run %d times, average accTest=%%%.2f-std=%%%.2f, accAll=%%%.2f-std=%%%.2f\n', cnt, 100*mean(accTests), std(accTests), 100*mean(accAlls), std(accAlls));
	fprintf('useTime=%.0fs=%.2fm=%.2fh, std=%f\n',mean(useTimes), mean(useTimes)/60, mean(useTimes)/3600, std(useTimes));
end

