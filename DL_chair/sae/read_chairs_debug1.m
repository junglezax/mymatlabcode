%function images = read_chair()
%global imgsize

fns = {
'1214_20'
'1113-20'
};

ischair = [
0
1
];

N = length(fns);
images = zeros(imgsize, imgsize, N);
train_x = zeros(N, imgsize*imgsize);
train_y = zeros(N, 2);
for i = 1:N
	fn = sprintf('chairs/%s.png', fns{i});
	a = rgb2gray(imread(fn));
	b = imresize(a, [imgsize, imgsize]);
	%figure; imshow(b);
	images(:, :, i) = b;
	train_x(i, :) = b(:);
	if ischair(i)
		train_y(i, 1) = 1;
	else
		train_y(i, 2) = 1;
	end
end
%close all

test_x = train_x;
test_y = train_y;
