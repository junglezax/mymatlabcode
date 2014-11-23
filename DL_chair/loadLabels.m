function [labels badlabel] = loadLabels(fns, labelLevel)
% fns, cell array of file fullnames
	
	% labelLevel==0 for unlabeled
	if ~exist('labelLevel', 'var')
		labelLevel = 2;
	end
	
	% init labels
	m = numel(fns);
	labels = zeros(1, m);
	
	badlabel = {};

	idx = 0;
	for idx = 1:m
		fn = fns{idx};
		
		simpleFn = removePath(fn);
		labelCode = simpleFn(1:4);
		theLabel = code2label(labelLevel, labelCode);
		if ~(numel(theLabel) == 1 && theLabel > 0)
			sprintf('\nbad label: %s for %s\n', labelCode, fn);
            errinfo = [fn '--bad label'];
			badlabel = [badlabel errinfo];
			continue; % label remains 0
		end
		
		labels(idx) = theLabel;
	end
end
