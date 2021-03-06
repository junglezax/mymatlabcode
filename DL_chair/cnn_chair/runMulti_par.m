function [accTests, accAlls, data_small] = runMulti_par(cnt, data)
	%example [accTests, accAlls] = runMulti_par(2);
	%        tic; [accTests, accAlls] = runMulti_par(2, data); toc
	%        no-par version: tic; [accTests, ~, accAlls] = runMulti(2, 'none', data); toc
	
	options = cnnOptions();
	startpool(options.coreNum);

	accTests = zeros(1, cnt);
	accAlls = zeros(1, cnt);
	useTimes = zeros(1, cnt);
    
	if ~exist('data', 'var')
		data = load_it(options.imgDir, options, true);
	end	
	
    data_small = rmfield(data, {'images', 'x'});
    
	for i = 1:cnt
		datas(i) = data_small;
    end
    
	parfor j = 1:cnt
		fprintf('---------------------cycle %d------------------------\n', j);
        [accTest, ~, accAll] = runIt_par('none', datas(j));
		accTests(j) = accTest;
		accAlls(j) = accAll;
	end
	
	fprintf('run %d times, average accTest=%%%.2f-std=%%%.2f, accAll=%%%.2f-std=%%%.2f\n', cnt, 100*mean(accTests), std(accTests), 100*mean(accAlls), std(accAlls));
	%printf('useTime=%.0fs=%.2fm=%.2fh, std=%f\n',mean(useTimes), mean(useTimes)/60, mean(useTimes)/3600, std(useTimes));
end

