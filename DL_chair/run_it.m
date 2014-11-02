scaledSize = 64;
imgBaseDir = '../../images/';
imgDirs = {'chair_labeled_97_png', 'yes', 'msmp2', 'msmp3', 'msmp4'};
images = {};
img_resized = {};
x = [];
labels = [];
fns = {};

for i = 1:numel(imgDirs)
	[images1, img_resized1, x1, labels1, fns1] = read_labeled_chairs([imgBaseDir imgDirs{i} '/'], scaledSize, true, 2);
	[images, img_resized, x, labels, fns] = merge_chairs_data(images, img_resized, x, labels, fns, images1, img_resized1, x1, labels1, fns1);
end

whos('images')
whos('x')
