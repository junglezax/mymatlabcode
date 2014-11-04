function coef = cubicBezierCoef(points)
% points given as a 4-by-2 array
    p1 = points(1,:);
    c1 = points(2,:);
    c2 = points(3,:);
    p2 = points(4,:);

% compute coefficients of Bezier Polynomial, using polyval ordering
coef(4, 1) = p1(1);
coef(4, 2) = p1(2);
coef(3, 1) = 3 * c1(1) - 3 * p1(1);
coef(3, 2) = 3 * c1(2) - 3 * p1(2);
coef(2, 1) = 3 * p1(1) - 6 * c1(1) + 3 * c2(1);
coef(2, 2) = 3 * p1(2) - 6 * c1(2) + 3 * c2(2);
coef(1, 1) = p2(1) - 3 * c2(1) + 3 * c1(1) - p1(1);
coef(1, 2) = p2(2) - 3 * c2(2) + 3 * c1(2) - p1(2); 
