function [x, fns, bad] = read_chairs3(patchSize)
% read unlabeled images of 20,000 furnitures 
%   and do PCA to them.

	if ~exist('patchSize', 'var')
		patchSize = 64;
	end

	imgDir = '../../../images/furniture_20000/';

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

%{
bad...
reading image #1 1733029494.jpg
MATLAB:imagesci:jpg:cmykColorSpace
reading image #2 1819033120.jpg
bad image 1819033120.jpg dim=4
reading image #3 1975510348.jpg
bad image 1975510348.jpg dim=4
reading image #4 2040637304.jpg
bad image 2040637304.jpg dim=4
reading image #5 2222988503.jpg
bad image 2222988503.jpg dim=4
reading image #6 2230501854.jpg
bad image 2230501854.jpg dim=4
reading image #7 2911420870.jpg
MATLAB:imagesci:jpg:cmykColorSpace
reading image #8 2934597217.jpg
bad image 2934597217.jpg dim=4
reading image #9 2943249928.jpg
MATLAB:imagesci:jpg:cmykColorSpace
reading image #10 2943250144.jpg
MATLAB:imagesci:jpg:cmykColorSpace
reading image #11 2969176038.jpg
bad image 2969176038.jpg dim=4
%}
