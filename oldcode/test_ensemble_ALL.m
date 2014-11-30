% ensemble on ALL data
cd d:\mine\xx\code\BN_ALL
load ALLm30.mat

n = size(ALLm, 2)-1;
m = size(ALLm, 1);
X = ALLm;
X(:, end) = [];
Y = ALLm(:, end);

tabulate(Y)

part = cvpartition(Y,'holdout',0.5);

istrain = training(part); % data for fitting
istest = test(part); % data for quality assessment
tabulate(Y(istrain))

t = ClassificationTree.template('minleaf',20);
tic
rusTree = fitensemble(X(istrain,:), Y(istrain), 'RUSBoost', 1000, t, 'LearnRate', 0.1, 'nprint', 100);
toc

figure;
tic
tloss = loss(rusTree, X(istest,:), Y(istest), 'mode', 'cumulative');
plot(tloss);
toc
grid on;
xlabel('Number of trees');
ylabel('Test classification error');
min(tloss)

% 用30个特征的数据，rusTree不管怎么算loss全是89.36

tic
Yfit = predict(rusTree, X(istest,:));
toc
tab = tabulate(Y(istest));
bsxfun(@rdivide, (Y(istest),Yfit), tab(:,2))*100
% 同样显示前两类识别率高，后两类识别率低，建议分别选择特征分别训练（训练得到两个模型，然后分别识别，哪个得到的概率高就算哪类）
mean(Yfit ~= Y(istest))

cmpctRus = compact(rusTree);

sz(1) = whos('rusTree');
sz(2) = whos('cmpctRus');
[sz(1).bytes sz(2).bytes]
% 没怎么压的动

cmpctRus = removeLearners(cmpctRus, [30:end]); % 没有这个方法

sz(3) = whos('cmpctRus');
sz(3).bytes

L = loss(cmpctRus, X(istest,:), Y(istest))

cv = fitensemble(X(istrain,:), Y(istrain), 'RUSBoost', 1000, t, 'LearnRate', 0.1, 'nprint', 100, 'kfold', 5);
cvloss = kfoldLoss(cv, 'mode', 'cumulative')

adam2 = fitensemble(X(istrain,:), Y(istrain), 'AdaBoostM2', 1000, 'Tree');
Yfit = predict(adam2, X(istest,:));
mean(Yfit ~= Y(istest))
