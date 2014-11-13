function dataStru = load_it(dataFrom, scaledSize)

if ~exist('scaledSize', 'var')
	scaledSize = 128;
end

if ~exist('dataFrom', 'var')
	dataFrom = 'read';
end

saveName = sprintf('../../data/chairs_labeled_%dx%d.mat', scaledSize, scaledSize);

if strcmp(dataFrom, 'read')
	imgBaseDir = '../../images/';
	imgDirs = {'png97', 'yes', 'msmp1', 'msmp2', 'msmp3', 'msmp4', 'msmp5', 'msmp6', 'msmp7', 'msmp8'};
	disp(imgDirs);

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
		[images1, img_resized1, x1, labels1, fns1, bad1] = read_labeled_chairs([imgBaseDir imgDirs{i} '/'], scaledSize, false, 2, false);
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

	disp('saving...')
	save(saveName, 'dataStru', '-v7.3');
	disp('done')

elseif strcmp(dataFrom, 'load')

	disp('loading...')
	load(saveName);
	disp('done');

%else none donothing

end

%whos('images')
%whos('x')

end
