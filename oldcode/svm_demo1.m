clc
clear
close all

% svm demo
% 想学习的时候没时间，有时间的时候不想学，时不我待，廉颇老矣

x1 = [0.0231926 0.2964719 0.4838635 0.2470214
0.4148389 0.1754181 0.3451341 0.6027388];

x2 = [0.3823597 0.7050896 0.8091961 0.5671486
0.7542710 0.3996857 0.7633629 0.8421596];

x1 = [x1; ones(1, size(x1, 2))];
x2 = [x2; 2 * ones(1, size(x2, 2))];
data = [x1 x2]';
tgt = data(:,3);

data = data(:, 1:2);

%[train, test] = crossvalind('holdOut', tgt);
%cp = classperf(tgt);

train = 1:size(data, 1);
test = train;
%length(find(train==1))
%length(find(tgt(train)==1))
%length(find(test==1))
%length(find(tgt(test)==1))

svmStru = svmtrain(data(train,:), tgt(train), 'Kernel_Function', 'rbf', 'autoscale', 'false', 'showplot', 'true', 'method', 'SMO');

% 对所有数据分类
classes1 = svmclassify(svmStru, data);

% 识别率（对正样本的分类正确率）
%length(find(tgt == 1 & classes1 == 1)) / length(find(tgt == 1))

% 正确率
%length(find(classes1 == tgt)) / length(classes1)

% 画分类面
% w x + b = 0
% w1 x1 + w2 x2 + b = 0
% x2 = -(w1 x1 + b)/w2
%lbl = tgt(svmStru.SupportVectorIndices) * 2 - 3
%w = (lbl .* svmStru.Alpha)' * svmStru.SupportVectors
w = svmStru.Alpha' * svmStru.SupportVectors;
w * svmStru.SupportVectors' + svmStru.Bias
maxx = max(data(:,1));
minx = min(data(:,1));

xdraw = [minx maxx];
ydraw = -(w(1) * xdraw + svmStru.Bias) / w(2);

%plot(data(:,1), data(:,2), '.')
figure;
hold on;
plot(x1(1,:), x1(2,:), 'or')
plot(x2(1,:), x2(2,:), 'xb')
plot(xdraw, ydraw)
hold off;

svmStru

% 总结：
% 仅在 quadratic/linear, autoscale 的情况下得到 4 个支持向量
% 仅在 linear, false 的情况下我画出的分类线才大致正确，但算出的 W^T * x + b 并不为 1
