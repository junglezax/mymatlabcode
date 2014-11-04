%scaledSize = 128;
imgBaseDir = '../../images/';
imgDirs = {'chair_labeled_97_png', 'yes', 'msmp2', 'msmp3', 'msmp4', 'msmp5'};
images = {};
img_resized = {};
x = [];
labels = [];
fns = {};
bad = {};

for i = 1:numel(imgDirs)
	[images1, img_resized1, x1, labels1, fns1, bad1] = read_labeled_chairs([imgBaseDir imgDirs{i} '/'], scaledSize, false, 2, false);
	[images, img_resized, x, labels, fns, bad] = merge_chairs_data(images, img_resized, x, labels, fns, bad, images1, img_resized1, x1, labels1, fns1, bad1);
end

%whos('images')
%whos('x')
fprintf('read: %d\n', numel(fns));
fprintf('bad : %d\n', numel(bad));

disp('saving...')
save -v7.3 ../../data/chairs_data_5sets.mat images img_resized x labels fns
disp('done')

% load('../../data/chairs_data_5sets.mat')
