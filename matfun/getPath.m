function newfn = getPath(fn)
	idx = find(fn == '/' | fn == '\');
	newfn = fn;
	if numel(idx) > 0
		idx = idx(end);
		newfn = fn(1:idx);
	end
end
