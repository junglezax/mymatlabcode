% simple gradient descent algorithm
% by X.H. Jiang (jxhchina at gmail.com)
% 17:17 2013/12/11
function [theta, J_history] = gradientDescent(f, X, y, initial_theta, alpha, num_iters)
J_history = zeros(num_iters, 1);

eps = 0.0001;
theta = initial_theta;

[J, grad] = f(theta, X, y);
lastJ = J;
J_history(1) = J;

for iter = 2:num_iters
	theta = theta - alpha * grad;
	[J, grad] = f(theta, X, y);
	%theta
	fprintf('iter %d, J = %f lastJ = %f\n', iter, J, lastJ);

	J_history(iter) = J;

	if J - lastJ > eps
		fprintf('ft! J=%f, lastJ=%f, cost function increasing, use a smaller alpha\n', J, lastJ);
		%theta = initial_theta;
		%break;
	end
	if abs(lastJ - J) < eps
		disp('convergence')
		break
	end
	lastJ = J;
end

J_history = J_history(1:iter);

end
