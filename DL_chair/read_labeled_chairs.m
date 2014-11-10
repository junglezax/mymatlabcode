function [images, img_resized, x, labels, fns, bad] = read_labeled_chairs(imgDir, imageDim, toGray, labelLevel, verbose)
% read labeled furniture images
% example: 
%  [images, img_resized, x, labels, fns] = read_labeled_chairs('../../images/chair_labeled_97_png/', 64, true, 2);

	if ~exist('imageDim', 'var')
		imageDim = 64;
	end
	
	if ~exist('toGray', 'var')
		toGray = false;
	end

	if ~exist('imageDim', 'var')
		imageDim = 64;
	end
	
	if ~exist('labelLevel', 'var')
		labelLevel = 2;
	end
	
	if ~exist('verbose', 'var')
		verbose = false;
	end

	fns = {};
	bad = {};

	dirs = dir(imgDir);
	dirs = dirs(3:end);
	m = numel(dirs);
	
	labels = zeros(1, m);
	
	idx = 0;
	
	img_resized = {};
	images = {};
	if toGray
		x = zeros(imageDim*imageDim, m);
	else
		x = zeros(imageDim*imageDim*3, m);
	end
	
	fprintf('reading images from %s\n', imgDir);
	for i = 1:m
		fn = [imgDir dirs(i).name];
		if strcmp(getExt(dirs(i).name), 'xls')
			continue;
		end
		
		if verbose
			fprintf('reading image %s\n', fn);
		else
			fprintf('.');
		end
		
		try
			im = imread(fn);
		catch err
			disp(err.identifier);
			bad = [bad fn];
			continue;
		end
				
		dim = numel(size(im));
		
		a = im;
		
		if dim ~= 3 & dim ~= 2
			disp(['bad image size ' fn]);
			disp(size(im));
			bad = [bad fn];
			continue;
		elseif toGray & dim == 3
			a = rgb2gray(im);
		elseif ~toGray & dim == 2
			a = gray2rgb(im);
		end
		
		idx = idx + 1;

		images{idx} = im;
		
		b = imresize(a, [imageDim, imageDim]);
		img_resized{idx} = b;
		
		labelCode = dirs(i).name(1:4);
		labels(idx) = code2label(labelCode, labelLevel);

		x(:, idx) = b(:);
		fns{idx} = fn;
	end
	
	toDel = idx+1:m;
	labels(toDel) = [];
	x(:, toDel) = [];
	
	fprintf('read...%d\n', numel(fns));
	fprintf('bad...%d\n', numel(bad));
	disp(bad);
end
