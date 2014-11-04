function newfn = removeExt(fn)
	ext = '';
	idx = find(fn == '.');
	newfn = fn;
	if numel(idx) > 0
		idx = idx(end);
		newfn = fn(1:idx-1);
	end
end
