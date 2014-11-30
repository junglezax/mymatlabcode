% 集成学习算法
% from matlab2012b examples

% 分类例子
load fisheriris
ens = fitensemble(meas,species,'AdaBoostM2',100,'Tree')
flower = predict(ens,mean(meas))
bad = ~strcmp(flower,species);
err = mean(bad)

% 回归例子
load carsmall
X = [Horsepower Weight];
ens = fitensemble(X,MPG,'LSBoost',100,'Tree')
mileage = ens.predict(X);
idx = ~isnan(MPG);
% 偏差率
mean(abs(mileage(idx) - MPG(idx)))/mean(abs(MPG(idx)))

% Test Ensemble Quality
rng(1,'twister') % for reproducibility
X = rand(2000,20);
Y = sum(X(:,1:5),2) > 2.5;

cvpart = cvpartition(Y,'holdout',0.3);
Xtrain = X(training(cvpart),:);
Ytrain = Y(training(cvpart),:);
Xtest = X(test(cvpart),:);
Ytest = Y(test(cvpart),:);

figure;
plot(loss(bag,Xtest,Ytest,'mode','cumulative'));
xlabel('Number of trees');
ylabel('Test classification error');

% Generate a five-fold cross-validated bagged ensemble:
cv = fitensemble(X,Y,'Bag',200,'Tree',...
    'type','classification','kfold',5)

figure;
plot(loss(bag,Xtest,Ytest,'mode','cumulative'));
hold
plot(kfoldLoss(cv,'mode','cumulative'),'r.');
hold off;
xlabel('Number of trees');
ylabel('Classification error');
legend('Test','Cross-validation','Location','NE');

figure;
plot(loss(bag,Xtest,Ytest,'mode','cumulative'));
hold
plot(kfoldLoss(cv,'mode','cumulative'),'r.');
plot(oobLoss(bag,'mode','cumulative'),'k--');
hold off;
xlabel('Number of trees');
ylabel('Classification error');
legend('Test','Cross-validation','Out of bag','Location','NE');

% Classification with Imbalanced Data
urlwrite('http://archive.ics.uci.edu/ml/machine-learning-databases/covtype/covtype.data.gz','forestcover.gz');

load covtype.data
Y = covtype(:,end);
covtype(:,end) = [];

tabulate(Y)

part = cvpartition(Y,'holdout',0.5);
istrain = training(part); % data for fitting
istest = test(part); % data for quality assessment
tabulate(Y(istrain))

