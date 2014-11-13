function dataStru = load_it(imgDirs, options, labeled)
%imgDirs = {'chair_labeled_97_png', 'yes', 'msmp2', 'msmp3', 'msmp4', 'msmp5', 'msmp6'};
if ~exist('options', 'var')
	options = struct;
end

if ~isfield(options, 'imageDim')
	options.imageDim = 128;
end

if ~exist('labeled', 'var')
	labeled = false;
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

if ~isfield(options, 'imgBaseDir')
	options.imgBaseDir = '../../images/';
end

if strcmp(class(imgDirs), 'char')
	imgDirs = {imgDirs};
end

saveName = sprintf('%s/chairs_labeled_%dx%d.mat', options.dataDir, options.imageDim, options.imageDim);

if strcmp(options.dataFrom, 'read')
>>>>>>> 961e09cd191638039c7b99a86e91aa75bcd605b0
	dirCnt = numel(imgDirs);

	images = {};
	img_resized = {};
	x = [];
	labels = [];
	fns = {};
	bad = {};
	goodCnt = zeros(1, dirCnt);
	badCnt = zeros(1, dirCnt);

	for i = 1:dirCnt
		d = imgDirs{i};
		if ~(d(end) == '/' || d(end) == '\')
			d = [d '/'];
		end
		
		if ~isAbsPath(d)
			d = [options.imgBaseDir d];
		end
		
		[images1, img_resized1, x1, labels1, fns1, bad1] = read_labeled_chairs(d, options.imageDim, false, 2, false);
		goodCnt(i) = numel(fns1);
		badCnt(i) = numel(bad1);
		[images, img_resized, x, labels, fns, bad] = merge_chairs_data(images, img_resized, x, labels, fns, bad, images1, img_resized1, x1, labels1, fns1, bad1);
	end

dataStru = struct;
dataStru.images = images;
dataStru.img_resized = img_resized;
dataStru.x = x;
dataStru.labels = labels;
dataStru.fns = fns;
dataStru.bad = bad;
dataStru.goodCnt = badCnt;
dataStru.imgDirs = imgDirs;

	fprintf('read: %d\n', numel(fns));
	fprintf('bad : %d\n', numel(bad));

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
