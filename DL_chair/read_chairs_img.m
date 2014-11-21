function [images, img_resized, x, labels, fns, bad] = read_chairs_img(imgDir, imageDim, toGray, labelLevel, verbose)
% read labeled furniture images

	if ~exist('imageDim', 'var')
		imageDim = 64;
	end
	
	if ~exist('toGray', 'var')
		toGray = false;
	end

	if ~exist('imageDim', 'var')
		imageDim = 64;
	end
	
	% labelLevel==0 for unlabeled
	if ~exist('labelLevel', 'var')
		labelLevel = 2;
	end
	
	if ~exist('verbose', 'var')
		verbose = false;
	end

	acceptExts = {'png', 'jpg'};
	
	fns = {};
	bad = {};

	fnames = dirRecursive(imgDir);
	m = numel(fs);
	
	if labelLevel ~= 0
		labels = zeros(1, m);
	else
		labels = [];
	end
	
	idx = 0;
	
	img_resized = {};
	images = {};
	if toGray
		x = zeros(imageDim*imageDim, m);
	else
		x = zeros(imageDim*imageDim*3, m);
	end
	
	fprintf('reading images from %s\n', imgDir);
	for fn = fnames
		if ~ismember(lower(getExt(fn)), acceptExts)
			continue;
		end
		
		if labelLevel ~= 0
			simpleFn = removeExt(fn);
			labelCode = simpleFn(1:4);
			theLabel = code2label(labelLevel, labelCode);
			if ~(numel(theLabel) == 1 && theLabel > 0)
				sprintf('bad label: %s for %s', labelCode, fn);
				bad = [bad [fn '--bad label']];
				continue;
			end
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
			bad = [bad [fn '--' err.identifier]];
			continue;
		end
				
		dim = numel(size(im));
		
		a = im;
		
		if dim ~= 3 & dim ~= 2
			disp(['bad image size dim ' fn]);
			disp(size(im));
			bad = [bad [fn '--bad image size dim']];
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
		
		x(:, idx) = b(:);
		fns{idx} = fn;
		
		if labelLevel ~= 0
			labels(idx) = theLabel;
		end
	end
	
	toDel = idx+1:m;
	x(:, toDel) = [];
	
	if labelLevel ~= 0
		labels(toDel) = [];
	end
	
	fprintf('read...%d\n', numel(fns));
	fprintf('bad...%d\n', numel(bad));
	disp(bad);
end
