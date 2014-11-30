function [error_train, error_val] = ...
    learningCurve1(X, y, Xval, yval, lambda, repeat)
	
if nargin < 6
	repeat = 50;
end

m = size(X, 1);

error_train = zeros(m, 1);
error_val   = zeros(m, 1);

for i = 1:m
	err_tr = 0;
	err_val = 0;
	for j = 1:repeat
		sub = randsample(m, i);
		Xtrain = X(sub, :);
		ytrain = y(sub);
		
		sub = randsample(length(yval), i);
		Xval1 = Xval(sub, :);
		yval1 = yval(sub);
		
		[theta] = trainLinearReg(Xtrain, ytrain, lambda);
		err_tr = err_tr + linearRegCostFunction(Xtrain, ytrain, theta, 0); 
		err_val = err_val + linearRegCostFunction(Xval, yval, theta, 0);
	end
	error_train(i) = err_tr ./ repeat;
	error_val(i) = err_val ./ repeat;
end

end
