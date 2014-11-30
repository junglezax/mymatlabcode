Cs = [0.01; 0.03; 0.1; 0.3; 1; 3; 10; 30];
sigmas = [0.01; 0.03; 0.1; 0.3; 1; 3; 10; 30];

lenC = length(Cs);
lens = length(sigmas);
err_vals = zeros(lenC, lens);
err_trs = zeros(lenC, lens);

min_err_val = Inf;
min_C = 0; min_sigma = 0;
for i=1:lenC
	for j=1:lens
		C = Cs(i); sigma = sigmas(j);
		model= svmTrain(X, y, C, @(x1, x2) gaussianKernel(x1, x2, sigma));
		pred = svmPredict(model, X);
		err_trs(i, j) = mean(pred ~= y);
		pred = svmPredict(model, Xval);
		err = mean(pred ~= yval)
		if err < min_err_val
			min_err_val = err;
			min_C = C; min_sigma = sigma;
		end
		err_vals(i, j) = err;
	end
end

[e, I] = min(err_vals);
[e, J] = min(e);
err_vals(I(J), J)
Cs(I(J))
sigmas(J)
plot(sigmas, err_vals(1, :))
plot(err_vals(1, :))
for i=1:lenC
	plot(1:lens, err_vals(i, :), 1:lens, err_trs(i, :))
	title(sprintf('C=%f', Cs(i)))
	legend('validation', 'train')
	pause
end

for i=1:lens
	plot(1:lenC, err_vals(:, i), 1:lenC, err_trs(:, i))
	title(sprintf('sigma=%f', sigmas(i)))
	legend('validation', 'train')
	pause
end

