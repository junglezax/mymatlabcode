function mat = cell2mat4d(c)
% c: 1xm cell of r*c*d matrices
	sz = size(c{1});
	m = numel(c);
	mat = zeros(sz(1), sz(2), sz(3), m); 
	for i = 1:m
		mat(:, :, :, i) = c{i};
	end
end
