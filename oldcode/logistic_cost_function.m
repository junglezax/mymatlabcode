function [J, grad] = logistic_cost_function(theta, X, y, h)
	J = -(y' * log(h(theta, X)) + (1-y)' * log(1-h(theta, X)))./m;
	grad = X' * (h(theta, X) - y)/.m;
	