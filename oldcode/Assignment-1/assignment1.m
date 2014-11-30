% Machince Learning course by R. Xia, assignment-1
% Text Classification and Sentiment Analysis
% by X.H. Jiang (jxhchina at gmail.com)
% 14:51 2013/11/29

%======================================================
% flags
% 1=TF, 2=BOOL, 3=TFIDF
termWeight = 2;
computeIg = 0;
runcv = 0; %run k-fold cross validation or not
feanorm = 0; % featureNormalize or not
%======================================================
% 加载数据
%loadData
load hotel1
if termWeight == 1
	Xorigin = XoriginTF;
elseif termWeight == 2
	Xorigin = XoriginBOOL;
elseif termWeight == 3
	Xorigin = XoriginTFIDF;
	feanorm = 1;
end
%======================================================
% 高频词
%[cp, cpidx] = sort(sum(Xorigin));
%bag(cpidx(end-20:end))

% 计算信息增益率
if computeIg
	disp('computing information gain ratio...');
	tic;
	ig = infoGain(Xorigin, y);
	[ig1 idxf] = sort(ig, 'descend');
	toc;
	
%	disp('saving...');
	tic;
	save('hotel0.mat');
	save('hotel1.mat', 'XoriginTF', 'XoriginBOOL', 'XoriginTFIDF', 'bag', 'ig', 'ig1', 'idxf', 'm', 'y');
	toc;
end

%======================================================
% 特征选择
nSel = 130;
% for holdout validation
disp('holdout partitioning...');
part = cvpartition(y, 'holdout', 0.3);
istrain = training(part);
istest = test(part);

featureSel

lambda = 0.0; % for regularization
%======================================================
% logistic回归
% 训练
disp('Logistic regression...');
tic; [theta, cost] = logisticR(Xtr, ytr, lambda); toc

% 分类
p = logisticRpredict(theta, Xte);
fprintf('Logistic, nSel=%d, lambda=%f, test ccuracy: %f\n', nSel, lambda, mean(double(p == yte)) * 100);
%======================================================
% 主成分分析 PCA
disp('Logistic + PCA...');
[m, n] = size(X);
tic
covx = cov(X);
[COEFF, latent, explained] = pcacov(covx);
X1 = X * COEFF;
covX1 = cov(X1);
dg1 = diag(covX1);
kpca = 34;
fprintf('PCA, %d features, proportion %f\n', kpca, sum(dg1(1:kpca)) / sum(dg1));
X2 = X1(:, 1:kpca);
toc

tic; [theta, cost] = logisticR(X2(istrain), ytr, lambda); toc
p = logisticRpredict(theta, X2(istest));
fprintf('Logistic + PCA-%d, nSel=%d, lambda=%f, accuracy: %f\n', kpca, nSel, lambda, mean(double(p == yte)) * 100);
%======================================================
% Naive Bayes (Multi-variate Bernoulli event model)
disp('Naive Bayes...');
smooth = 1;
tic; nb = mynaivebayes(Xtr, ytr, smooth); toc
[p err] = mynaivebayesPredict(nb, Xte, yte);
fprintf('Naive Bayes, smooth = %d, accuracy: %f\n', smooth, (1-err) * 100);
%======================================================
% matlab svmtrain
disp('svmtrain/svmclassify...');
tic; svmStruct = svmtrain(double(Xtr), ytr, 'Kernel_Function', 'rbf', 'autoscale', 'false'); toc

p = svmclassify(svmStruct, double(Xte));
fprintf('svmtrain, accuracy: %f\n', mean(double(p == yte)) * 100);
%======================================================
% EMNB
disp('EMNB...');
tic; nb = myemnb(X, 30); toc
[prob, pred] = myemnbPredict(nb, X);
fprintf('EMNB, accuracy: %f\n', max(mean(pred' == y), mean(pred' ~= y)) * 100);
%======================================================
% boost+logistic
%smallIdx = [1:5 2001:2005]; Xsmall = X(smallIdx, 1:3); ysmall = y(smallIdx);
levels = unique(y);
logisticRlambda = @(X, y) logisticR(X, y, 0.01);
tic; boostModel = boostTrain(@logisticR, @logisticRpredict, Xtr, ytr, 10); toc
[p, prob, err] = boostPredict(boostModel, @logisticRpredict, levels, Xte, yte);
fprintf('boost logistic, holdout accuracy: %f\n', (1 - err) * 100);
%======================================================
% CV-5
if runcv
	k = 5;
	cp = cvpartition(y, 'k', k);

	% logistic
	f = @(xtrain, ytrain, xtest) (logisticRpredict(logisticR(xtrain, ytrain, 0), xtest));
	tic; [err, errs] = crossvalid(f, X, y, k, cp); toc
	fprintf('Logistic, accuracy in 5-fold cross validation: %f\n', (1-err) * 100);

	% logistic lambda=0.1
	f = @(xtrain, ytrain, xtest) (logisticRpredict(logisticR(xtrain, ytrain, 0.1), xtest));
	tic; [err, errs] = crossvalid(f, X, y, k, cp); toc
	fprintf('Logistic, lambda = 0.1, accuracy in 5-fold cross validation: %f\n', (1-err) * 100);

	% logistic + PCA
	f = @(xtrain, ytrain, xtest) (logisticRpredict(logisticR(xtrain, ytrain, 0), xtest));
	tic; [err, errs] = crossvalid(f, X2, y, k, cp); toc
	fprintf('Logistic + PCA-%d, accuracy in %d-fold cross validation: %f\n', kpca, k, (1-err) * 100);

	% naive bayes
	f = @(xtrain, ytrain, xtest) (mynaivebayesPredict(mynaivebayes(xtrain, ytrain, 0), xtest));
	tic; [err, errs] = crossvalid(f, X, y, k, cp); toc
	fprintf('Naive Bayes, smooth = 0, accuracy in 5-fold cross validation: %f\n', (1-err) * 100);

	% naive bayes + smooth
	f = @(xtrain, ytrain, xtest) (mynaivebayesPredict(mynaivebayes(xtrain, ytrain, 1), xtest));
	tic; [err, errs] = crossvalid(f, X, y, k, cp); toc
	fprintf('Naive Bayes, smooth = 1, accuracy in 5-fold cross validation: %f\n', (1-err) * 100);

	% svmtrain
	f = @(xtrain, ytrain, xtest) (svmclassify(svmtrain(double(xtrain), ytrain, 'Kernel_Function', 'rbf', 'autoscale', 'false'), double(xtest)));
	tic; [err, errs] = crossvalid(f, X, y, k, cp); toc
	fprintf('svmtrain, accuracy in 5-fold cross validation: %f\n', (1-err) * 100);
end
