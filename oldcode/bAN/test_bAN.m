% test boosted-TAN

% 加载数据，预处理
clc; clear; close all;
cd d:\mine\xx\code\BN_ALL
load ALLm7.mat
cd D:\mine\xx\code\bAN

nfeat = size(ALLm, 2)-1;
n = nfeat+1;
m = size(ALLm, 1);
X = ALLm;
X(:, end) = [];
y = ALLm(:, end);
levels = unique(y);

% 对半分训练-测试样本
part = cvpartition(y,'holdout',0.5);

istrain = training(part); % data for fitting
istest = test(part); % data for quality assessment

% 训练
[bAN, cls, prob1, err1] = bAN_train(X(istrain,:), y(istrain), 1);

% 分类
[cls, prob2, err2] = bAN_predict(bAN, X(istest,:), levels, y(istest));
err1
err2

% 交叉验证
%cp = cvpartition(Y, 'k', 5);
% 训练
%f = @(xtrain,ytrain,xtest) (bAN_predict(bAN_train(xtrain, ytrain), xtest));
%err3 = crossval(X, y, 'predfun', f, 'partition', cp)
