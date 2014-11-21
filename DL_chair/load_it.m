function data = load_it(options)
if ~exist('options', 'var')
	options = struct;
end

if ~isfield(options, 'imageDim')
	options.imageDim = 128;
end

if ~isfield(options, 'dataFrom')
	options.dataFrom = 'read';
end

if ~isfield(options, 'save')
	options.save = false;
end

if ~isfield(options, 'labelLevel')
	options.labelLevel = 2;
end

if ~isfield(options, 'dataDir')
	options.dataDir = '../../data';
end

if ~isfield(options, 'imgDir')
	options.imgDir = '../../images/chairs';
end

saveName = sprintf('%s/chairs_labeled_%dx%d.mat', options.dataDir, options.imageDim, options.imageDim);

if strcmp(options.dataFrom, 'read')
	data = read_chairs_img(options.imgDir, options.imageDim, false, options.labelLevel, false);

	if options.save
		disp('saving...')
		save(saveName, 'dataStru', '-v7.3');
		disp('done')
	end
elseif strcmp(options.dataFrom, 'load')
	disp('loading...')
	load(saveName);
	disp('done');

%else none donothing

end

%whos('images')
%whos('x')

end
