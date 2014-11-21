function fs = dirRecursive(path, depth)
    if ~exist('depth', 'var')
        depth = 0;
        usedepth = false;
    else
        usedepth = true;
    end

    if usedepth && depth == 0
        fs = [];
        return
    end
    
    disp(depth)
    disp(usedepth)

    fst = dir(path);
	fs = [];
	for i = 3:numel(fst)
        f = fst(i);
		fn = [path '/' f.name];
		%f.isdir
		if f.isdir
            if usedepth
                nextfs = dirRecursive(fn, depth-1);
            else
                nextfs = dirRecursive(fn);
            end
            
			fs = [fs nextfs];
		else
			fs = [fs f];
		end
    end
end

% disp all names:
% arrayfun(@(x) disp(x.name), fs);
% or get all names:
% fnames = arrayfun(@(x) {x.name}, fs);
% and then display them:
% dispCells(fnames)

