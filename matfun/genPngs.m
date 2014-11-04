function genPngs(fn)
% 由源图像生成多种尺寸的pngs，用于android app
% for example: genPngs('liblogo.png')

im = imread(fn);
sizes1 = [
	48 72 96 144
];

dirs = {'drawable-mdpi', 'drawable-hdpi', 'drawable-xhdpi', 'drawable-xxhdpi'};

sizes2 = [
	16 90 100 136 168 192 256 512
];

for i = 1:numel(sizes1)
	sz = sizes1(i);
	im1 = imresize(im, [sz sz]);
	%fnout = [dirs{i} '/ic_launcher.png'];
    
    d = ['../' dirs{i}];
    mkdir(d);
    
	fnout = strcat(d, '/ic_launcher.png');
	imwrite(im1, fnout, 'PNG');
end

newfn = removeExt(fn);
for i = 1:numel(sizes2)
	sz = sizes2(i);
	im1 = imresize(im, [sz sz]);
	
	fnout = strcat(newfn, '_', num2str(sz), '.png');
	imwrite(im1, fnout, 'PNG');
end
	
end
