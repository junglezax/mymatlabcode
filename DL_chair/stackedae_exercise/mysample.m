function [trainset, testset] = mysample(labels, train_scale)
	if ~exist('train_scale', 'var')
		train_scale = 0.6;
	end
	
	sz = size(labels);
	if sz(2) == 1
		labels = labels'; % to row vector
	end
	
	levels = unique(labels);
	nLevels = length(levels);
	
	trainset = [];
	%testset = [];
	for i = 1:nLevels
		idxs = find(labels == levels(i));
		n = numel(idxs);
		trsz = round(n * train_scale);
		trt = randsample(idxs, trsz);
		%tet = setdiff(idxs, trt);
		trainset = [trainset trt];
		%testset = [testset tet];
	end
	testset = setdiff(1:numel(labels), trainset);
end