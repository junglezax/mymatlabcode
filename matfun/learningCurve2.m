function [error_train, error_val] = ...
    learningCurve2(ftr, fte, X, y, Xval, yval, lambda, repeat)
	
if nargin < 8
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
		
		model = ftr(Xtrain, ytrain, lambda);
		[p, err] = fte(model, Xtrain, ytrain);
		err_tr = err_tr + err;
		[p, err] = fte(model, Xval, yval);
		err_val = err_val + err;
	end
	error_train(i) = err_tr ./ repeat;
	error_val(i) = err_val ./ repeat;
end

end
