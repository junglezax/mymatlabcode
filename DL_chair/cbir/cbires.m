function varargout = cbires(varargin)
	% CBIRES MATLAB code for cbires.fig
	%      CBIRES, by itself, creates a new CBIRES or raises the existing
	%      singleton*.
	%
	%      H = CBIRES returns the handle to a new CBIRES or the handle to
	%      the existing singleton*.
	%
	%      CBIRES('CALLBACK',hObject,eventData,handles,...) calls the local
	%      function named CALLBACK in CBIRES.M with the given input arguments.
	%
	%      CBIRES('Property','Value',...) creates a new CBIRES or raises the
	%      existing singleton*.  Starting from the left, property value pairs are
	%      applied to the GUI before cbires_OpeningFcn gets called.  An
	%      unrecognized property name or invalid value makes property application
	%      stop.  All inputs are passed to cbires_OpeningFcn via varargin.
	%
	%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
	%      instance to run (singleton)".
	%
	% See also: GUIDE, GUIDATA, GUIHANDLES

	% Edit the above text to modify the response to help cbires

	% Last Modified by GUIDE v2.5 09-Nov-2014 17:20:46

	% Begin initialization code - DO NOT EDIT
	gui_Singleton = 1;
	gui_State = struct('gui_Name',       mfilename, ...
		'gui_Singleton',  gui_Singleton, ...
		'gui_OpeningFcn', @cbires_OpeningFcn, ...
		'gui_OutputFcn',  @cbires_OutputFcn, ...
		'gui_LayoutFcn',  [] , ...
		'gui_Callback',   []);
	if nargin && ischar(varargin{1})
		gui_State.gui_Callback = str2func(varargin{1});
	end

	if nargout
		[varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
	else
		gui_mainfcn(gui_State, varargin{:});
	end
end
% End initialization code - DO NOT EDIT

function options = getParam()
	options = struct;
	options.imageDim = 67;
	options.patchDim = 8;
	options.poolDim = 10;          % dimension of pooling region % (imageDim - patchDim + 1)/poolDim = int
	options.imageChannels = 3;     % number of channels (rgb, so 3)
	options.numPatches = 100;   % number of patches
	options.maxIter = 40;
	options.softmaxIter = 20;
	options.hiddenSize  = 30;           % number of hidden units
	options.stepSize = 10;			% hiddenSize / stepSize = int
	options.sparsityParam = 0.035; % desired average activation of the hidden units.
	options.lambda = 3e-3;         % weight decay parameter       
	options.beta = 5;              % weight of sparsity penalty term       
	options.epsilon = 0.1;	       % epsilon for ZCA whitening
	options.numClasses = 12;
	options.softmaxLambda = 1e-4;
	options.imgBaseDir = '';
end

% --- Executes just before cbires is made visible.
function cbires_OpeningFcn(hObject, eventdata, handles, varargin)
	% This function has no output args, see OutputFcn.
	% hObject    handle to figure
	% eventdata  reserved - to be defined in a future version of MATLAB
	% handles    structure with handles and user data (see GUIDATA)
	% varargin   command line arguments to cbires (see VARARGIN)

	% Choose default command line output for cbires
	handles.modelput = hObject;

	handles.options = getParam();
	
	handles.unlabeledDir = '../../../images/chair_labeled_97_png';
	handles.retrievalDir = '../../../images/chair_labeled_97_png';
	
	% Update handles structure
	guidata(hObject, handles);

	% UIWAIT makes cbires wait for user response (see UIRESUME)
	% uiwait(handles.figure1);
	
end

% --- Outputs from this function are returned to the command line.
function varargout = cbires_OutputFcn(hObject, eventdata, handles)
	% varargout  cell array for returning output args (see VARARGOUT);
	% hObject    handle to figure
	% eventdata  reserved - to be defined in a future version of MATLAB
	% handles    structure with handles and user data (see GUIDATA)

	% Get default command line output from handles structure
	varargout{1} = handles.modelput;
end

%% ==========================================================================
% --- Executes on button press in btn_BrowseImage.
function btn_BrowseImage_Callback(hObject, eventdata, handles)
	[query_fname, query_pathname] = uigetfile('*.jpg; *.png; *.bmp', 'Select query image');

	if (query_fname ~= 0)
		query_fullpath = strcat(query_pathname, query_fname);
		[pathstr, name, ext] = fileparts(query_fullpath); % fiparts returns char type
		
		if ( strcmp(lower(ext), '.jpg') == 1 || strcmp(lower(ext), '.png') == 1 ...
				|| strcmp(lower(ext), '.bmp') == 1 )
			
			queryImage = imread( fullfile( pathstr, strcat(name, ext) ) );
			handles.queryImage = queryImage;
			guidata(hObject, handles);
			
			helpdlg('Proceed with the query by executing the green button!');
			
			% Clear workspace
			clear('query_fname', 'query_pathname', 'query_fullpath', 'pathstr', ...
				'name', 'ext', 'queryImage');
		else
			errordlg('You have not selected the correct file type');
		end
	else
		return;
	end
end

%% ==========================================================================
% --- Executes on selection change in popupmenu_DistanceFunctions.
function popupmenu_DistanceFunctions_Callback(hObject, eventdata, handles)
	% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_DistanceFunctions contents as cell array
	%        contents{get(hObject,'Value')} returns selected item from popupmenu_DistanceFunctions

	handles.DistanceFunctions = get(handles.popupmenu_DistanceFunctions, 'Value');
	guidata(hObject, handles);
end

%% ==========================================================================
% --- Executes during object creation, after setting all properties.
function popupmenu_DistanceFunctions_CreateFcn(hObject, eventdata, handles)
	% Hint: popupmenu controls usually have a white background on Windows.
	%       See ISPC and COMPUTER.
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
end

%% ==========================================================================
% --- Executes on selection change in popupmenu_NumOfReturnedImages.
function popupmenu_NumOfReturnedImages_Callback(hObject, eventdata, handles)
	% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_NumOfReturnedImages contents as cell array
	%        contents{get(hObject,'Value')} returns selected item from popupmenu_NumOfReturnedImages

	handles.numOfReturnedImages = get(handles.popupmenu_NumOfReturnedImages, 'Value');
	guidata(hObject, handles);
end

%% ==========================================================================
% --- Executes during object creation, after setting all properties.
function popupmenu_NumOfReturnedImages_CreateFcn(hObject, eventdata, handles)
	% hObject    handle to popupmenu_NumOfReturnedImages (see GCBO)
	% eventdata  reserved - to be defined in a future version of MATLAB
	% handles    empty - handles not created until after all CreateFcns called

	% Hint: popupmenu controls usually have a white background on Windows.
	%       See ISPC and COMPUTER.
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
end

%% ==========================================================================
% --- Executes on button press in btnExecuteQuery.
function btnExecuteQuery_Callback(hObject, eventdata, handles)
	% check for image query
	if (~isfield(handles, 'queryImage'))
		errordlg('Please select an image first, then choose your similarity metric and num of returned images!');
		return;
	end

	% check for dataset existence
	if (~isfield(handles, 'featureSet'))
		errordlg('Please load a dataset first. If you dont have one then you should consider creating one!');
		return;
	end

	% set variables
	if (~isfield(handles, 'DistanceFunctions') && ~isfield(handles, 'numOfReturnedImages'))
		metric = get(handles.popupmenu_DistanceFunctions, 'Value');
		numOfReturnedImgs = get(handles.popupmenu_NumOfReturnedImages, 'Value');
	elseif (~isfield(handles, 'DistanceFunctions') || ~isfield(handles, 'numOfReturnedImages'))
		if (~isfield(handles, 'DistanceFunctions'))
			metric = get(handles.popupmenu_DistanceFunctions, 'Value');
			numOfReturnedImgs = handles.numOfReturnedImages;
		else
			metric = handles.DistanceFunctions;
			numOfReturnedImgs = get(handles.popupmenu_NumOfReturnedImages, 'Value');
		end
	else
		metric = handles.DistanceFunctions;
		numOfReturnedImgs = handles.numOfReturnedImages;
	end

	queryImage = preprocessImage1(handles.queryImage, handles.options.imageDim);
	% extract query image features
	imgData = cell2mat4d({queryImage});
	queryImageFeature = cnnComputeFeature(handles.model, imgData, handles.options);

	useClassifier = false;
	if useClassifier
		% do classify
		% classification
		[pred] = softmaxPredict(handles.model.softmaxModel, queryImageFeature);
		
		cls_idxs = find(handles.labels == pred);
    else
        cls_idxs = 1:size(handles.featureSet, 2);
	end

	handles.queryImageFeature = queryImageFeature;
	guidata(hObject, handles);
	
	assignin('base', 'queryImageFeature', handles.queryImageFeature);

	if (metric == 1)
		idxs = L1(numOfReturnedImgs, handles.queryImageFeature, handles.featureSet(:, cls_idxs)); 
	elseif (metric == 2 || metric == 3 || metric == 4 || metric == 5 || metric == 6  || metric == 7 || metric == 8 || metric == 9 || metric == 10 || metric == 11)
		idxs = L2(numOfReturnedImgs, handles.queryImageFeature, handles.featureSet(:, cls_idxs), metric);
	else
		idxs = relativeDeviation(numOfReturnedImgs, handles.queryImageFeature, handles.featureSet(:, cls_idxs));
	end
	plotReturnedImages(handles.queryImage, handles.retrievalData.img_resized, idxs, cls_idxs);
end

%% ==========================================================================
% --- Executes on button press in btnExecuteSVM.
function btnExecuteSVM_Callback(hObject, eventdata, handles)
	% hObject    handle to btnExecuteSVM (see GCBO)
	% eventdata  reserved - to be defined in a future version of MATLAB
	% handles    structure with handles and user data (see GUIDATA)

	% check for image query
	if (~isfield(handles, 'queryImageFeature'))
		errordlg('Please select an image first!');
		return;
	end

	% check for dataset existence
	if (~isfield(handles, 'imageDataset'))
		errordlg('Please load a dataset first. If you dont have one then you should consider creating one!');
		return;
	end

	numOfReturnedImgs = get(handles.popupmenu_NumOfReturnedImages, 'Value');
	metric = get(handles.popupmenu_DistanceFunctions, 'Value');

	% call svm function passing as parameters the numOfReturnedImgs, queryImage and the dataset
	[~, ~, cmat] = svm(numOfReturnedImgs, handles.imageDataset.dataset, handles.queryImageFeature, metric);

	% plot confusion matrix
	opt = confMatPlot('defaultOpt');
	opt.className = {
		'Africa', 'Beach', 'Monuments', ...
		'Buses', 'Dinosaurs', 'Elephants', ...
		'Flowers', 'Horses', 'Mountains', ...
		'Food'
		};
	opt.mode = 'both';
	figure('Name', 'Confusion Matrix');
	confMatPlot(cmat, opt);
	xlabel('Confusion Matrix');
end

%% ==========================================================================
% --- Executes on button press in btnPlotPrecisionRecall.
function btnPlotPrecisionRecall_Callback(hObject, eventdata, handles)
	% hObject    handle to btnPlotPrecisionRecall (see GCBO)
	% eventdata  reserved - to be defined in a future version of MATLAB
	% handles    structure with handles and user data (see GUIDATA)

	if (~isfield(handles, 'imageDataset'))
		errordlg('Please select a dataset first!');
		return;
	end

	% set variables
	numOfReturnedImgs = 20;
	database = handles.imageDataset.dataset;
	metric =  get(handles.popupmenu_DistanceFunctions, 'Value');

	precAndRecall = zeros(2, 10);

	imgpath = '..\chairs\';

	for k = 1:15
		randImgName = randi([0 999], 1);
		randStrName = int2str(randImgName);
		randStrName = strcat(imgpath, randStrName, '.jpg');
		randQueryImg = imread(randStrName);
		
		% extract query image features
		queryImage = imresize(randQueryImg, [384 256]);
		hsvHist = hsvHistogram(queryImage);
		autoCorrelogram = colorAutoCorrelogram(queryImage);
		color_moments = colorMoments(queryImage);
		% for gabor filters we need gary scale image
		img = double(rgb2gray(queryImage))/255;
		[meanAmplitude, msEnergy] = gaborWavelet(img, 4, 6); % 4 = number of scales, 6 = number of orientations
		wavelet_moments = waveletTransform(queryImage);
		% construct the queryImage feature vector
		queryImageFeature = [hsvHist autoCorrelogram color_moments meanAmplitude msEnergy wavelet_moments randImgName];
		
		disp(['Random Image = ', num2str(randImgName), '.jpg']);
		[precision, recall] = svm(numOfReturnedImgs, database, queryImageFeature, metric);
		precAndRecall(1, k) = precision;
		precAndRecall(2, k) = recall;
	end

	figure;
	plot(precAndRecall(2, :), precAndRecall(1, :), '--mo');
	xlabel('Recall'), ylabel('Precision');
	title('Precision and Recall');
	legend('Recall & Precision', 'Location', 'NorthWest');
end

%% ==========================================================================
% --- Executes on button press in btnSelectImageDirectory.
function btnSelectImageDirectory_Callback(hObject, eventdata, handles)
	% select image directory
	unlabeledDir = uigetdir(pwd, 'Select the directory of unlabeled images');
	if ( unlabeledDir ~= 0 )
		handles.unlabeledDir = unlabeledDir;
		guidata(hObject, handles);
        
        set(handles.info, 'String', ['unlabeled dir: ', unlabeledDir]);
	else
		return;
	end
end

function btnSelLabeledDir_Callback(hObject, eventdata, handles)
	labeledDir = uigetdir(pwd, 'Select the directory of labeled images');
	if ( labeledDir ~= 0 )
		handles.labeledDir = labeledDir;
		guidata(hObject, handles);
		
		set(handles.info, 'String', ['labeled dir: ', labeledDir]);
	else
		return;
	end
end

% --- Executes on button press in btnSelRetrievalDir.
function btnSelRetrievalDir_Callback(hObject, eventdata, handles)
    retrievalDir = uigetdir(pwd, 'Select the directory of images to retrieve from');
	if ( retrievalDir ~= 0 )
		handles.retrievalDir = retrievalDir;
		guidata(hObject, handles);
		
		set(handles.info, 'String', ['retrieval dir: ', retrievalDir]);
	else
		return;
    end
end

%% ==========================================================================
% --- Executes on button press in btnCreateDB.
function btnCreateDB_Callback(hObject, eventdata, handles)
	if (~isfield(handles, 'retrievalDir'))
		errordlg('Please select an image directory for retrieving first!');
		return;
	end

	disp('creating db...');
	
	handles.retrievalData = load_it(handles.retrievalDir, handles.options, false);
	
	numImages = numel(handles.retrievalData.fns);

	if (numImages > 0)
		imgData = cell2mat4d(handles.retrievalData.img_resized);
		featureSet = cnnComputeFeature(handles.model, imgData, handles.options);
		
		useClassifier = false;
		if useClassifier
			% do classify
		end
		
		handles.featureSet = featureSet;
		guidata(hObject, handles);
		
		% prompt to save dataset
		uisave({'featureSet'}, 'features');
	end
	
	disp('creating db finished');
end

%% ==========================================================================
% --- Executes on button press in btn_LoadDataset.
function btn_LoadDataset_Callback(hObject, eventdata, handles)
	[fname, pthname] = uigetfile('*.mat', 'Select the Dataset');
	if (fname ~= 0)
		dataset_fullpath = strcat(pthname, fname);
		[pathstr, name, ext] = fileparts(dataset_fullpath);
		if ( strcmp(lower(ext), '.mat') == 1)
			filename = fullfile( pathstr, strcat(name, ext) );
			handles.featureSet = load(filename);
			guidata(hObject, handles);
			
			%make dataset visible from workspace
			assignin('base', 'featureSet', handles.featureSet);
			helpdlg('Dataset loaded successfuly!');
		else
			errordlg('You have not selected the correct file type');
		end
	else
		return;
	end
end

% --- Executes on button press in btnTrainClassifier.
function btnTrainClassifier_Callback(hObject, eventdata, handles)
	handles.labeledData = load_it(handles.labeledDir, handles.options, true);
	labeledImages = handles.labeledData.img_resized;
	[trainImages, trainLabels, testImages, testLabels, trainSet, testSet] = sampleData4d(labeledImages, handles.labeledData.labels);
	
	handles.model.trainSet = trainSet;
	handles.model.testSet = testSet;
	handles.model.trainLabels = trainLabels;
	handles.model.testLabels = testLabels;
	
	softmaxXTrain = cnnComputeFeature(handles.model, trainImages, handles.options);
	softmaxYTrain = trainLabels;

	options = struct;
	options.maxIter = handles.options.softmaxIter;

	disp('training softmax...');
	softmaxModel = softmaxTrain(numel(pooledFeaturesTrain) / numTrainImages,...
		handles.options.numClasses, handles.options.softmaxLambda, softmaxXtrain, softmaxYtrain, options);
	disp('training softmax finished');
	
	handles.model.softmaxModel = softmaxModel;
	guidata(hObject, handles);
end

% --- Executes on button press in btnTestClassifier.
function btnTestClassifier_Callback(hObject, eventdata, handles)
	% test classifier
	disp('predicting for test data')
	
	numTestImages = numel(handles.model.testSet);
	
	softmaxXtest = permute(handles.model.pooledFeaturesTest, [1 3 4 2]);
	softmaxXtest = reshape(softmaxXtest, numel(handles.model.pooledFeaturesTest) / numTestImages, numTestImages);
	softmaxYtest = handles.model.testLabels;
	
	handles.model.softmaxXtest = softmaxYtest;

	[predTest] = softmaxPredict(handles.model.softmaxModel, softmaxXtest);
	accTest = (predTest(:) == softmaxYtest(:));
	accTest = sum(accTest) / size(accTest, 1);
	fprintf('Accuracy: %2.3f%%\n', accTest * 100);

	% test on all examples
	disp('predicting for all data')
	softmaxXall = [handles.model.softmaxXtrain handles.model.softmaxXtest];
	softmaxYall = [handles.model.trainLabels; handles.model.testLabels];

	[predAll] = softmaxPredict(handles.model.softmaxModel, softmaxXall);
	accAll = (predAll(:) == softmaxYall(:));
	accAll = sum(accAll) / size(accAll, 1);
	fprintf('Accuracy on all: %2.3f%%\n', accAll * 100);
	
	handles.model.accTest = accTest;
	handles.model.accAll = accAll;
	handles.model.predTest = predTest;
	handles.model.predAll = predAll;
end

% --- Executes on selection change in selClassifyAlg.
function selClassifyAlg_Callback(hObject, eventdata, handles)
% hObject    handle to selClassifyAlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns selClassifyAlg contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selClassifyAlg
end

% --- Executes during object creation, after setting all properties.
function selClassifyAlg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selClassifyAlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in btnComputeFeatures.
function btnComputeFeatures_Callback(hObject, eventdata, handles)
	if (~isfield(handles, 'unlabeledDir'))
		errordlg('Please select dir of unlabeled images!');
		return;
	end
	
    handles.unlabeledData = load_it(handles.unlabeledDir, handles.options, false);
	
	%images = handles.unlabeledData.images;
	img_resized = handles.unlabeledData.img_resized;
	x = handles.unlabeledData.x;
	%labels = handles.unlabeledData.labels;
	%fns = handles.unlabeledData.fns;
	%bad = handles.unlabeledData.bad;
	%badCnt = handles.unlabeledData.goodCnt;
	%imgDirs = handles.unlabeledData.imgDirs;
	
	% sample train images to train patches for train AE
	disp('sampling patches from images...');
	patches = sampleIMAGES_color(img_resized, handles.options.patchDim, handles.options.numPatches);
	disp('sampling patches from images finished');
	
	% do ZCA
	meanPatch = mean(patches, 2);
	patches = bsxfun(@minus, patches, meanPatch);

	% Apply ZCA whitening
	sigma = patches * patches' / handles.options.numPatches;
	[u, s, v] = svd(sigma);
	ZCAWhite = u * diag(1 ./ sqrt(diag(s) + handles.options.epsilon)) * u';
	patches = ZCAWhite * patches;
	
	% train linear AE, got feature filter matrix
	visibleSize = handles.options.patchDim * handles.options.patchDim * handles.options.imageChannels;
	theta = initializeParameters(handles.options.hiddenSize, visibleSize);

	options = struct;
	options.Method = 'lbfgs'; 
	options.maxIter = handles.options.maxIter;
	options.display = 'on';

	disp('training linear encoder...');
	[optTheta, cost] = minFunc( @(p) sparseAutoencoderLinearCost(p, ...
									   visibleSize, handles.options.hiddenSize, ...
									   handles.options.lambda, handles.options.sparsityParam, ...
									   handles.options.beta, patches), ...
								  theta, options);
	disp('training linear encoder finished');

	handles.model = struct;
	handles.model.optTheta = optTheta;
	handles.model.ZCAWhite = ZCAWhite;
	handles.model.meanPatch = meanPatch;
	
	guidata(hObject, handles);

	fprintf('Saving\n');
	save('../../../data/chairLinearFeatures.mat', 'optTheta', 'ZCAWhite', 'meanPatch');
	fprintf('Saved\n');
end

% --- Executes on button press in btnSaveModel.
function btnSaveModel_Callback(hObject, eventdata, handles)
end

% --- Executes on button press in btnLoadModel.
function btnLoadModel_Callback(hObject, eventdata, handles)
end

function info_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of info as text
%        str2double(get(hObject,'String')) returns contents of info as a double
end

% --- Executes during object creation, after setting all properties.
function info_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
end