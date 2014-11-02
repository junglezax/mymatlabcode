function [images, img_resized, x, labels, fns] = read_labeled_chairs(imgDir, scaledSize, toGray, labelLevel)
% read labeled furniture images
% example: 
%  [images, img_resized, x, labels, fns] = read_labeled_chairs('../../images/chair_labeled_97_png/', 64, true, 2);

	if ~exist('scaledSize', 'var')
		scaledSize = 64;
	end
	
	if ~exist('toGray', 'var')
		toGray = false;
	end

	if ~exist('scaledSize', 'var')
		scaledSize = 64;
	end
	
	if ~exist('labelLevel', 'var')
		labelLevel = 2;
	end

	fns = {};
	bad = {};

	dirs = dir(imgDir);
	dirs = dirs(3:end);
	m = numel(dirs);
	
	labels = zeros(1, m);
	
	idx = 0;
	
	images = {};
	if toGray
		img_resized = zeros(scaledSize, scaledSize, m);
		x = zeros(scaledSize*scaledSize, m);
	else
		img_resized = zeros(scaledSize, scaledSize, 3, m);
		x = zeros(scaledSize*scaledSize*3, m);
	end
	
	for i = 1:m
		fn = [imgDir dirs(i).name];
		
		fprintf('reading image %s\n', fn);
		
		try
			im = imread(fn);
		catch err
			disp(err.identifier);
			bad = [bad fn];
			continue;
		end
				
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
		
		idx = idx + 1;

		images{idx} = im;
		
		if toGray
			b = imresize(a, [scaledSize, scaledSize]);
			img_resized(:, :, idx) = b;
		else
			b = imresize(a, [scaledSize, scaledSize, 3]);
			img_resized(:, :, :, idx) = b;
		end
		
		labelCode = dirs(i).name(1:4);
		labels(idx) = code2label(labelCode, labelLevel);

		x(:, idx) = b(:);
		fns{idx} = fn;
	end
	
	toDel = m-numel(bad)+1:m;
	labels(toDel) = [];
	x(:, toDel) = [];
	%img_resized(toDel) = [];
	
	fprintf('bad...%d\n', numel(bad));
	disp(bad);
end
