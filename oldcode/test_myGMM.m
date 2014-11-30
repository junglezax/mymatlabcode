disp('testing my GMM...');
smallIdx = [1:10 2001:2010]; Xsmall = X(smallIdx, 1:3); ysmall = y(smallIdx);
tic; nb = myGMM(Xsmall, 1); toc
[prob, pred] = myGMMPredict(nb, Xsmall);
fprintf('GMM, accuracy: %f\n', max(mean(pred' == ysmall), mean(pred' ~= ysmall)) * 100);

ncls = 2;
[m n] = size(X);
nb = myGMMinit(ncls, n);

tic; nb = myGMM(X, 10, 0, nb); toc
tic; [prob, pred] = myGMMPredict(nb, X); toc
fprintf('GMM, accuracy: %f\n', max(mean(pred' == y), mean(pred' ~= y)) * 100);
