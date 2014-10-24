function [images, allLabels, x, img_resized] = read_97chairs(scaledSize, toGray)
% read labeled furniture 97(two unlabeled skipped) images
%   and resize, and to gray
%   and return their labels

	if ~exist('scaledSize', 'var')
		scaledSize = 64;
	end
	
	if ~exist('toGray', 'var')
		toGray = true;
	end

	fns = {'1112-a', '1111', '1112-b', '1113-a', '1113-b', '1121', '1122', '1123', '1124', '1154', '1214', '1224', '1251', '1252', '1253', '1254', '1111-c', '1332', '1333', '1334', '2111', '2112', '2113', '2114', '2154', '2171', '2172', '2173', '2184-b', '2181', '2182', '2183', '2184-a', '2211', '2212', '2213', '2214', '2221', '2222', '2223', '2224', '2233-a', '2232', '2233-b', '2234', '2241', '2252', '2253', '2311', '2313', '2324', '2411', '2412', '2424', '2431', '2433', '3111', '3122', '3123', '3124', '3141', '3132', '3133', '1128', '3141-a', '3141-b', '3151', '3152', '3153', '3154', '3211', '3212', '3213', '3214', '3231', '3241', '3311', '3313', '3351', '3352', '3353', '3354', '4011', '4012', '4013', '4021-a', '4021-b', '4022-a', '4022-b', '4023-a', '4023-b', '4023-c', '4041', '4061', '4071'};

	realLabels2 = [11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 12, 11, 13, 13, 13, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 23, 23, 23, 24, 24, 24, 24, 24, 31, 31, 31, 31, 31, 31, 31, 11, 31, 31, 31, 31, 31, 31, 32, 32, 32, 32, 32, 32, 33, 33, 33, 33, 33, 33, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40];

	realLabel2 = [11, 12, 13, 21, 22, 23, 24, 31, 32, 33, 34, 40];

	allLabels = zeros(size(realLabels2));
	for i = 1:numel(realLabel2)
		allLabels(realLabels2 == realLabel2(i)) = i;
	end

	m = length(fns);
	images = {}; %zeros(scaledSize, scaledSize, m);
	
	if toGray
		img_resized = zeros(scaledSize, scaledSize, m);
		x = zeros(scaledSize*scaledSize, m);
	else
		img_resized = zeros(scaledSize, scaledSize, 3, m);
		x = zeros(scaledSize*scaledSize*3, m);
	end
	
	for i = 1:m
		fn = sprintf('../../../images/chair_labeled_97_png/%s.png', fns{i});
		
		fprintf('reading image %s\n', fn);
		
		im = imread(fn);
		images{i} = im;
		
		if toGray
			a = rgb2gray(im);
			b = imresize(a, [scaledSize, scaledSize]);
		
			%figure; imshow(b);
			img_resized(:, :, i) = b;
			x(:, i) = b(:);
		else
			b = imresize(im, [scaledSize, scaledSize]);
			img_resized(:, :, :, i) = b;
			x(:, i) = b(:);
		end
	end
	%close all
end
