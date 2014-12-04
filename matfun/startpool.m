function startpool(coreNum)
	if matlabpool('size') <= 0
		disp('opening matlabpool....');
		matlabpool('open', 'local', coreNum);
	else
		% matlabpool close
		% matlabpool('open', 'local', coreNum);
		disp('Already initialized');
	end
end
