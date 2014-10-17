%function images = read_chairs()

fns = {'1112-a', '1111', '1112-b', '1113-a', '1113-b', '1121', '1122', '1123', '1124', '1154', '1214', '1224', '1251', '1252', '1253', '1254', '1111-c', '1332', '1333', '1334', '2111', '2112', '2113', '2114', '2154', '2171', '2172', '2173', '2184-b', '2181', '2182', '2183', '2184-a', '2211', '2212', '2213', '2214', '2221', '2222', '2223', '2224', '2233-a', '2232', '2233-b', '2234', '2241', '2252', '2253', '2311', '2313', '2324', '2411', '2412', '2424', '2431', '2433', '3111', '3122', '3123', '3124', '3141', '3132', '3133', '1128', '3141-a', '3141-b', '3151', '3152', '3153', '3154', '3211', '3212', '3213', '3214', '3231', '3241', '3311', '3313', '3351', '3352', '3353', '3354', '4011', '4012', '4013', '4021-a', '4021-b', '4022-a', '4022-b', '4023-a', '4023-b', '4023-c', '4041', '4061', '4071'}';

ischair = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]';

label12 = [9	34; 9	34; 9	34; 9	34; 9	34; 9	35; 9	35; 9	35; 9	35; 9	32; 1	2; 1	1; 9	33; 9	33; 9	33; 9	33; 9	34; 7	25; 7	25; 7	25; 8	26; 8	26; 8	26; 8	26; 2	4; 8	31; 8	31; 8	31; 8	31; 8	30; 8	30; 8	30; 8	30; 5	12; 5	12; 5	12; 5	12; 5	15; 5	15; 5	15; 5	15; 5	14; 5	14; 5	14; 5	14; 5	13; 8	28; 8	28; 8	27; 8	27; 8	29; 3	10; 3	10; 4	11; 3	9; 3	9; 6	22; 6	22; 6	22; 6	22; 6	16; 6	16; 6	16; 6	16; 6	21; 6	21; 6	17; 6	17; 6	17; 6	17; 6	23; 6	23; 6	23; 6	23; 6	18; 2	8; 6	19; 6	19; 6	20; 6	20; 6	20; 6	20; 2	3; 2	3; 2	3; 2	7; 2	7; 2	7; 2	7; 2	7; 2	7; 2	7; 2	6; 2	8; 2	5];

N = length(fns);
images = {}; %zeros(patchSize, patchSize, N);
train_x = zeros(N, patchSize*patchSize);
%train_y = zeros(N, 2);
for i = 1:N
	fn = sprintf('../chairs/%s.png', fns{i});
	im = imread(fn);
	images{i} = im;
	
	a = rgb2gray(im);
	b = imresize(a, [patchSize, patchSize]);
	
	%figure; imshow(b);
	%images(:, :, i) = b;
	train_x(i, :) = b(:);
	%if ischair(i)
	%	train_y(i, 1) = 1;
	%else
	%	train_y(i, 2) = 1;
	%end
end
%close all

%test_x = train_x;
%test_y = train_y;

%---------------------------
% PCA
x = train_x';
avg = mean(x);
x1 = x - repmat(avg, size(x, 1), 1);

sigma = x1 * x1' / size(x1, 2);

[u, s, v] = svd(sigma, 0);

dg = diag(s);
sdg = sum(dg);
for k=1:length(dg)
	if sum(dg(1:k))/sdg >= 0.99
		break
	end
end
k;
sum(dg(1:k))/sdg;

%k=81; % 81 for visualization
%sum(dg(1:k))/sdg;

xTilde = u(:, 1:k)' * x1;

inputSize = k;

%---------------------------
% sample

chairData   = xTilde;
%chairLabels = ischair + 1;
chairLabels2 = label12(:, 1);

% numLabels  = numel(unique(chairLabels2)); %不行，可能有的标签没有样本，比如24

% Set Unlabeled Set (All Images)

% Simulate a Labeled and Unlabeled set
m = size(chairData, 2);
labeledSet   = 1:m;
unlabeledSet = 1:m;

[trainSet, testSet] = mysample(chairLabels2);

unlabeledData = chairData(:, unlabeledSet);

trainData   = chairData(:, trainSet);
trainLabels = chairLabels2(trainSet)';

testData   = chairData(:, testSet);
testLabels = chairLabels2(testSet)';

% Output Some Statistics
fprintf('# examples in unlabeled set: %d\n', size(unlabeledData, 2));
fprintf('# examples in supervised training set: %d\n\n', size(trainData, 2));
fprintf('# examples in supervised testing set: %d\n\n', size(testData, 2));
