function data = read_chairs_img(imgDir, imageDim, toGray, labelLevel, verbose)
% read furniture images

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
	
	fnames = dirRecursive(imgDir);
	m = numel(fnames);
	
	data = struct;
	data.fns = {};
	data.bad = {};
	data.img_resized = {};
	data.images = {};

	if labelLevel ~= 0
		data.labels = zeros(1, m);
	else
		data.labels = [];
	end
	
	if toGray
		data.x = zeros(imageDim*imageDim, m);
	else
		data.x = zeros(imageDim*imageDim*3, m);
	end
	
	idx = 0;
	fprintf('reading images from %s\n', imgDir);
	for fnc = fnames
        fn = fnc{1};
		if ~ismember(lower(getExt(fn)), acceptExts)
			continue;
		end
		
		if labelLevel ~= 0
			simpleFn = removePath(fn);
			labelCode = simpleFn(1:4);
			theLabel = code2label(labelLevel, labelCode);
			if ~(numel(theLabel) == 1 && theLabel > 0)
				sprintf('\nbad label: %s for %s\n', labelCode, fn);
                errinfo = [fn '--bad label'];
				data.bad = [data.bad errinfo];
				continue;
			end
		end

		if verbose
			fprintf('reading image %s\n', fn);
		else
			fprintf('.');
            if mod(idx+1, 100) == 0, fprintf('\n'), end
		end
		
		try
			im = imread(fn);
		catch err
            errinfo = [fn '--' err.identifier];
            fprintf('\n');
			disp(errinfo);
			data.bad = [data.bad errinfo];
			continue;
		end
				
		dim = numel(size(im));
		
		a = im;
		
		if dim ~= 3 & dim ~= 2
            fprintf('\n');
            errinfo = ['bad image size dim ' fn];
			disp(errinfo);
			disp(size(im));
			data.bad = [data.bad errinfo];
			continue;
		elseif toGray & dim == 3
			a = rgb2gray(im);
		elseif ~toGray & dim == 2
			a = gray2rgb(im);
		end
		
		idx = idx + 1;
		data.images{idx} = im;
		
		b = imresize(a, [imageDim, imageDim]);
		data.img_resized{idx} = b;
		
		data.x(:, idx) = b(:);
		data.fns{idx} = fn;
		
		if labelLevel ~= 0
			data.labels(idx) = theLabel;
		end
	end
	
	toDel = idx+1:m;
	data.x(:, toDel) = [];
	
	if labelLevel ~= 0
		data.labels(toDel) = [];
	end
	
	data.goodCnt = numel(data.fns);
	data.badCnt = numel(data.bad);
	
	fprintf('read...%d\n', data.goodCnt);
	fprintf('bad...%d\n', data.badCnt);
	disp(data.bad);
end
