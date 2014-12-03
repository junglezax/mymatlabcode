function dirFileCnt = cntByDir(fnames, acceptExts)
	%cellfun(@(x) ismember(getExt(x), acceptExts), fnames, 'UniformOutput', false);
	
	dirvec = cellfun(@(x) getPath(x), fnames, 'UniformOutput', false);

	if exist('acceptExts', 'var')
		extvec = ismember(cellfun(@(x) getExt(x), fnames, 'UniformOutput', false), acceptExts);
		dirvec(extvec == 0) = [];
	end

	%dispCells(dirvec);
	dirFileCnt = sortcell(tabulate(dirvec), 1);
	fprintf('total files: %d\n', numel(dirvec));
	disp(dirFileCnt);
end
