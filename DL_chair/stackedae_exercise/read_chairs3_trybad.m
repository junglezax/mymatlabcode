function read_chairs3_trybad(bad)
	patchSize = 64;
	imgDir = '../../../images/furniture_20000/';

	for i = 1:numel(bad)
		fn = bad{i};
		fprintf('reading image %s\n', fn);
		
		try
			im = imread(fn);
		catch err
			disp(err.identifier);
			continue;
		end
		
		dim = numel(size(im));
		if dim ~= 3 & dim ~= 2
			%if dim == 4
			%	inprof = iccread('swopcmyk.icm');
			%	outprof = iccread('sRGB.icm');
			%	C = makecform('icc',inprof,outprof);
			%	im = applycform(im,C);
			%else
				fprintf('bad image dim=%d\n', dim);
			%	continue;
			%end
		end;
	end
end