function [dirFileCnt, fnames] = cntByDir(fnames, acceptExts)
	%cellfun(@(x) ismember(getExt(x), acceptExts), fnames, 'UniformOutput', false);
	
	if exist('acceptExts', 'var')
		extvec = ismember(cellfun(@(x) lower(getExt(x)), fnames, 'UniformOutput', false), acceptExts);
		fnames(extvec == 0) = [];
	end

	dirvec = cellfun(@(x) getPath(x), fnames, 'UniformOutput', false);
size(dirvec)
class(dirvec)

	%dispCells(dirvec);
	dirFileCnt = sortcell(tabulate(dirvec), 1);
	fprintf('total files: %d\n', numel(dirvec));
	disp(dirFileCnt);
end

% setdiff(fnamesNew, data.fns)
