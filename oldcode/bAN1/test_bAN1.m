% test boosted-TAN 直接用naive bayes，不考虑TAN
% iris 数据


% 加载数据，预处理
clc; clear; close all;
%cd D:\mine\xx\code\bAN1
load fisheriris
uspecies = unique(species);
y = zeros(size(species));
y(strcmp(species, uspecies(1))) = 1;
y(strcmp(species, uspecies(2))) = 2;
y(strcmp(species, uspecies(3))) = 3;

data = [meas, y];
nfeat = size(data, 2)-1;
n = nfeat+1;
m = size(data, 1);
X = data;
X(:, end) = [];
y = data(:, end);
levels = unique(y);

% 对半分训练-测试样本
part = cvpartition(y,'holdout',0.5);

istrain = training(part); % data for fitting
istest = test(part); % data for quality assessment

% 训练
[bAN, cls1, prob1, err1] = bAN_train(X(istrain,:), y(istrain), 1);

% 分类
[cls2, prob2, err2] = bAN_predict(bAN, X(istest, :), levels, y(istest));
err1
err2

% 交叉验证
%cp = cvpartition(Y, 'k', 5);
% 训练
%f = @(xtrain,ytrain,xtest) (bAN_predict(bAN_train(xtrain, ytrain), xtest));
%err3 = crossval(X, y, 'predfun', f, 'partition', cp)
