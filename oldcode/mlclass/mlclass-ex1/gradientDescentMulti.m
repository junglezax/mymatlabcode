function [theta, J_history, iter] = gradientDescentMulti(X, y, theta, alpha, num_iters)
%GRADIENTDESCENTMULTI Performs gradient descent to learn theta
%   theta = GRADIENTDESCENTMULTI(x, y, theta, alpha, num_iters) updates theta by
%   taking num_iters gradient steps with learning rate alpha

% Initialize some useful values
m = length(y); % number of training examples
maxiter = 10000000;
J_history = zeros(maxiter, 1);
theta0 = theta;

lastJ = Inf;
for iter = 1:maxiter

    % ====================== YOUR CODE HERE ======================
    % Instructions: Perform a single gradient step on the parameter vector
    %               theta. 
    %
    % Hint: While debugging, it can be useful to print out the values
    %       of the cost function (computeCostMulti) and gradient here.
    %

	grad = (X' * (X * theta - y)) / m;
	theta = theta - alpha * grad;

	J = computeCostMulti(X, y, theta);
	J_history(iter) = computeCostMulti(X, y, theta);
	
	%disp(J);
	%disp(lastJ);
	%disp(sprintf('%d - %d = %d', J, lastJ, J - lastJ));
	eps = 0.0000001;
	if J - lastJ > eps
		disp('cost function increasing, use a smaller alpha')
		theta = theta0;
		break;
	end
	if abs(lastJ - J) < eps
		disp('convergence')
		break
	end
	lastJ = J;
	%pause
    % ============================================================

    % Save the cost J in every iteration    
    %J_history(iter) = computeCostMulti(X, y, theta);

end

end
