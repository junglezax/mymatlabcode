function ext = getExt(fn)
	ext = '';
	idx = find(fn == '.');
	if numel(idx) > 0
		idx = idx(end);
		ext = fn(idx+1:end);
	end
end
