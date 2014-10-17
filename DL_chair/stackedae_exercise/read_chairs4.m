function [x, fns, bad] = read_chairs4(patchSize)
% read unlabeled images of 10,000 chairs 
%   and do PCA to them.

	if ~exist('patchSize', 'var')
		patchSize = 64;
	end

	imgDir = '../../../images/chair_10000/';

	dirs = dir(imgDir);
	m = numel(dirs) - 2;

	%images = {};
	fns = {};
	bad = {};
	x = zeros(patchSize*patchSize, m);
	idx = 0;
	for i = 1:m
		fn = [imgDir dirs(i+2).name];

		fprintf('reading image #%d %s\n', i, fn);
		
		try
			im = imread(fn);
		catch err
			disp(err.identifier);
			bad = [bad fn];
			continue;
		end
		
		%images{i} = im;
		
		%if i == 345
		%	figure; imshow(im);
		%	size(im)
		%end
		
		dim = numel(size(im));
		if dim == 3
			a = rgb2gray(im);
        elseif dim == 2
			a = im;
		else
			disp(['bad image ' fn]);
			bad = [bad fn];
			continue;
		end;
		
		b = imresize(a, [patchSize, patchSize]);
		
		idx = idx + 1;
		x(:, idx) = b(:);
		fns{idx} = fn;
	end
	
	badCnt = numel(bad);
	assert(all(all(x(:, end-badCnt+1:end) == 0)));
	x(:, end-badCnt+1:end) = [];
end
