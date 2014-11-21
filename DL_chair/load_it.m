function dataStru = load_it(imgDir, options)
if ~exist('options', 'var')
	options = struct;
end

if ~isfield(options, 'imageDim')
	options.imageDim = 128;
end

if ~isfield(options, 'dataFrom')
	options.dataFrom = 'read';
end

if ~isfield(options, 'save')
	options.save = false;
end

if ~isfield(options, 'dataDir')
	options.dataDir = '../../data';
end


saveName = sprintf('%s/chairs_labeled_%dx%d.mat', options.dataDir, options.imageDim, options.imageDim);

if strcmp(options.dataFrom, 'read')
		[images, img_resized, x, labels, fns, bad] = read_chairs_img(d, options.imageDim, false, options.labelLevel, false);
		goodCnt = numel(fns);
		badCnt= numel(bad);
		
dataStru = struct;
dataStru.images = images;
dataStru.img_resized = img_resized;
dataStru.x = x;
dataStru.labels = labels;
dataStru.fns = fns;
dataStru.bad = bad;
dataStru.goodCnt = goodCnt;
dataStru.badCnt = badCnt;
dataStru.imgDirs = imgDirs;

	fprintf('read: %d\n', goodCnt);
	fprintf('bad : %d\n', badCnt);

	if options.save
		disp('saving...')
		save(saveName, 'dataStru', '-v7.3');
		disp('done')
	end

elseif strcmp(options.dataFrom, 'load')

	disp('loading...')
	load(saveName);
	disp('done');

%else none donothing

end

%whos('images')
%whos('x')

end
