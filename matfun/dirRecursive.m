function fsnames = dirRecursive(path, depth)
    if ~exist('depth', 'var')
        depth = 0;
        usedepth = false;
    else
        usedepth = true;
    end

    if usedepth && depth == 0
        fsnames = {};
        return
    end

    fst = dir(path);
	fsnames = {};
	for i = 3:numel(fst)
        f = fst(i);
		fn = [path '/' f.name];
		%f.isdir
		if f.isdir
            if usedepth
                nextfnames = dirRecursive(fn, depth-1);
            else
                nextfnames = dirRecursive(fn);
            end
            
			fsnames = [fsnames nextfnames];
		else
			fsnames = [fsnames fn];
		end
    end
end

% to display:
% dispCells(fnames)

