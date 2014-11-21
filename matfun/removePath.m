function newfn = removePath(fn)
	idx = find(fn == '/' | fn == '\');
	newfn = fn;
	if numel(idx) > 0
		idx = idx(end);
		newfn = fn(idx+1:end);
	end
end
