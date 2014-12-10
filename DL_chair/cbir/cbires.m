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

	% Last Modified by GUIDE v2.5 30-Nov-2014 14:34:07

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

% --- Executes just before cbires is made visible.
function cbires_OpeningFcn(hObject, eventdata, handles, varargin)
	% This function has no output args, see OutputFcn.
	% hObject    handle to figure
	% eventdata  reserved - to be defined in a future version of MATLAB
	% handles    structure with handles and user data (see GUIDATA)
	% varargin   command line arguments to cbires (see VARARGIN)

	% Choose default command line output for cbires
	handles.modelput = hObject;

	handles.options = cnnOptions();
	
	handles.options.dataDir = [handles.options.dataDir, 'cbir/'];
    handles.outFilename = [handles.options.dataDir, 'out.mat'];
    handles.modelFilename = [handles.options.dataDir, 'model.mat'];
    handles.retrievalDataFilename = [handles.options.dataDir, 'retrievalData.mat'];
	handles.optionsFilename = [handles.options.dataDir, 'options.mat'];
    
    handles.out = struct;
    handles.model = struct;
	
	handles.unlabeledDir = handles.options.imgDir; %'../../../images/chairs/png97';
	handles.retrievalDir = handles.unlabeledDir;
    handles.labeledDir = handles.unlabeledDir;
    handles.numOfReturnedImages = 10;
	
    set(handles.info, 'String', ['unlabeled dir: ', handles.unlabeledDir]);

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
    filterSpec = sprintf('%s/*.jpg; *.png', handles.options.imgDir);
    %filterSpec = sprintf('%s/*.jpg; %s/*.png; %s/*.bmp', handles.options.imgDir, handles.options.imgDir, handles.options.imgDir);
	[query_fname, query_pathname] = uigetfile(filterSpec, 'Select query image');

	if (query_fname ~= 0)
		query_fullpath = strcat(query_pathname, query_fname);
		[pathstr, name, ext] = fileparts(query_fullpath); % fiparts returns char type
		
		if ( strcmp(lower(ext), '.jpg') == 1 || strcmp(lower(ext), '.png') == 1 ...
				|| strcmp(lower(ext), '.bmp') == 1 )
			
			queryImage = imread( fullfile( pathstr, strcat(name, ext) ) );
			handles.queryImage = queryImage;
			guidata(hObject, handles);
			
            plotQueryImage(queryImage);
            
			%helpdlg('Proceed with the query by executing the green button!');
			
			% Clear workspace
			clear('query_fname', 'query_pathname', 'query_fullpath', 'pathstr', ...
				'name', 'ext', 'queryImage');
            
            executeQuery(hObject, eventdata, handles);
            
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
	handles.DistanceFunctions = get(handles.popupmenu_DistanceFunctions, 'Value');
	guidata(hObject, handles);
end

%% ==========================================================================
% --- Executes during object creation, after setting all properties.
function popupmenu_DistanceFunctions_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
end

%% ==========================================================================
function executeQuery(hObject, eventdata, handles)
	% check for image query
	if (~isfield(handles, 'queryImage'))
		errordlg('Please select an image first, then choose your similarity metric and num of returned images!');
		return;
	end

	% check for dataset existence
	if (~isfield(handles.out, 'featureSet'))
		errordlg('Please load a dataset first. If you dont have one then you should consider creating one!');
		return;
    end
    
    getNumOfReturnedImages(hObject, handles);
    metric = get(handles.popupmenu_DistanceFunctions, 'Value');
    handles.DistanceFunctions = metric;

	queryImage = preprocessImage1(handles.queryImage, handles.options.imageDim);
	% extract query image features
	imgData = cell2mat4d({queryImage});
	queryImageFeature = cnnComputeFeature(handles.model, imgData, handles.options);

    handles.classifyAlg = get(handles.selClassifyAlg, 'Value');
	if handles.classifyAlg ~= 1
        if (~isfield(handles.out, 'predSet'))
            errordlg('Please load a gen prediction set first!');
            return;
        end
    
		% do classify
		% classification
        disp('predicting for query iamge...');
        
        pred = 0;
        if handles.classifyAlg == 2
            pred = softmaxPredict(handles.model.softmaxModel, queryImageFeature);
        elseif handles.classifyAlg == 3
            error('predicting for retrieval features with svm not supported')
        end
        
        fprintf('predicting result %d\n', pred);

        newPred = confirmPred(queryImage, pred);
        newPred = str2double(newPred{1});
        
        fprintf('newPred %d\n', newPred);

        if handles.classifyAlg ~= 1
            set(handles.textClassifyResult, 'String', ['classify result£º', num2str(newPred)]);
        end
        
		cls_idxs = find(handles.out.predSet == newPred);
    else
        cls_idxs = 1:size(handles.out.featureSet, 2);
	end

	handles.queryImageFeature = queryImageFeature;
	guidata(hObject, handles);
	
	assignin('base', 'queryImageFeature', handles.queryImageFeature);

	if (metric == 1)
		idxs = L1(handles.numOfReturnedImages, handles.queryImageFeature, handles.out.featureSet(:, cls_idxs)); 
	elseif (metric == 2 || metric == 3 || metric == 4 || metric == 5 || metric == 6  || metric == 7 || metric == 8 || metric == 9 || metric == 10 || metric == 11)
		idxs = L2(handles.numOfReturnedImages, handles.queryImageFeature, handles.out.featureSet(:, cls_idxs), metric);
	else
		idxs = relativeDeviation(handles.numOfReturnedImages, handles.queryImageFeature, handles.out.featureSet(:, cls_idxs));
	end
	plotReturnedImages(handles.queryImage, handles.retrievalData.images, idxs, cls_idxs, handles.retrievalData.fns);
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
	unlabeledDir = uigetdir(handles.options.imgDir, 'Select the directory of unlabeled images');
	if ( unlabeledDir ~= 0 )
		handles.unlabeledDir = unlabeledDir;
		guidata(hObject, handles);
        
        set(handles.info, 'String', ['unlabeled dir: ', unlabeledDir]);
	else
		return;
	end
end

function btnSelLabeledDir_Callback(hObject, eventdata, handles)
	labeledDir = uigetdir(handles.options.imgDir, 'Select the directory of labeled images');
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
    retrievalDir = uigetdir(handles.options.imgDir, 'Select the directory of images to retrieve from');
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
    handles.classifyAlg = get(handles.selClassifyAlg, 'Value');
    if handles.classifyAlg == 3
        error('predicting for retrieval features with svm not supported')
    end
        
	if (~isfield(handles, 'retrievalDir'))
		errordlg('Please select an image directory for retrieving first!');
		return;
    end
    
    if (~isfield(handles, 'model'))
		errordlg('Please compute model first!');
		return;
    end
    
    handles.classifyAlg = get(handles.selClassifyAlg, 'Value');
    if handles.classifyAlg == 2
        if (~isfield(handles, 'softmaxModel'))
            errordlg('Please compute softmaxModel first!');
            return;
        end
    end

	disp('creating db...');
	
	handles.retrievalData = load_it(handles.retrievalDir, handles.options, false);
	
	numImages = numel(handles.retrievalData.fns);

	if (numImages > 0)
		imgData = cell2mat4d(handles.retrievalData.img_resized);
		disp('computing features for retrieval iamges')
		featureSet = cnnComputeFeature(handles.model, imgData, handles.options);
		
        predSet = [];
		if handles.classifyAlg == 2
            disp('predicting for retrieval features with softmax')
            predSet = softmaxPredict(handles.model.softmaxModel, featureSet);
            handles.out.predSet = predSet;
        elseif handles.classifyAlg == 3
            error('predicting for retrieval features with svm not supported')
            %handles.out.predSet = predSet;
		end
		
		handles.out.featureSet = featureSet;
		guidata(hObject, handles);
	end
	
	disp('creating db finished');
end

%% ==========================================================================
% --- Executes on button press in btnTrainClassifier.
function btnTrainClassifier_Callback(hObject, eventdata, handles)
    handles.classifyAlg = get(handles.selClassifyAlg, 'Value');
    if handles.classifyAlg == 2
        handles.labeledData = load_it(handles.labeledDir, handles.options, true);

		handles.sampleOut = sampleData4d(handles.labeledData.img_resized, handles.labeledData.labels);
		handles.trainFeatures = cnnComputeFeature(handles.model, handles.sampleOut.trainData, handles.options);
		handles.model.softmaxModel = trainSoftmax(handles.trainFeatures, handles.sampleOut.trainLabels, handles.options);
        %[handles.model.softmaxModel, handles.sampleOut] = trainSoftmax(handles.model, handles.labeledData.img_resized, handles.labeledData.labels, handles.options);
        guidata(hObject, handles);
    elseif handles.classifyAlg == 3
        error('predicting for retrieval features with svm not supported')
    end
end

% --- Executes on button press in btnTestClassifier.
function btnTestClassifier_Callback(hObject, eventdata, handles)
	% test classifier
    disp('computing features for test data')
    handles.testFeatures = cnnComputeFeature(handles.model, handles.sampleOut.testData, handles.options);

	disp('predicting for test data')
    [accTest, predTest] = testSoftmax(handles.model.softmaxModel, handles.testFeatures, handles.sampleOut.testLabels);

	handles.accTest = accTest;
	handles.predTest = predTest;
end

% --- Executes on selection change in selClassifyAlg.
function selClassifyAlg_Callback(hObject, eventdata, handles)
    handles.classifyAlg = get(handles.selClassifyAlg, 'Value');
	guidata(hObject, handles);

    if handles.classifyAlg ~= 1
        set(handles.btnSelLabeledDir, 'Enable', 'on');
        set(handles.btnTrainClassifier, 'Enable', 'on');
        set(handles.btnTestClassifier, 'Enable', 'on');
    else
        set(handles.btnSelLabeledDir, 'Enable', 'off');
        set(handles.btnTrainClassifier, 'Enable', 'off');
        set(handles.btnTestClassifier, 'Enable', 'off');
    end
end

% --- Executes during object creation, after setting all properties.
function selClassifyAlg_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on button press in btnComputeFeatures.
% just compute linear AE
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
end

% --- Executes on button press in btnSaveModel.
function btnSaveModel_Callback(hObject, eventdata, handles)
    fprintf('Saving model...\n');
    model = handles.model;
	save(handles.modelFilename, 'model');
	fprintf('model Saved\n');
	
	fprintf('Saving options...\n');
    options = handles.options;
	save(handles.optionsFilename, 'options');
	fprintf('options Saved\n');

    fprintf('Saving retrievalData...\n');
    retrievalData = handles.retrievalData;
	save(handles.retrievalDataFilename, 'retrievalData');
	fprintf('retrievalData Saved\n');
end

% --- Executes on button press in btnSaveFeaSet.
function btnSaveFeaSet_Callback(hObject, eventdata, handles)
    fprintf('Saving feature set...\n');
    out = handles.out;
	save(handles.outFilename, 'out');
	fprintf('out set saved\n');
end

% --- Executes on button press in btnLoadModel.
function btnLoadModel_Callback(hObject, eventdata, handles)
    disp('loading model...');
    t = load(handles.modelFilename);
	handles.model = t.model;
    
    disp('loading retrievalData...');
    t = load(handles.retrievalDataFilename);
	handles.retrievalData = t.retrievalData;
    
    disp('loading options...');
    t = load(handles.optionsFilename);
	handles.options = t.options;
	
	guidata(hObject, handles);	
	assignin('base', 'model', handles.model);
    assignin('base', 'options', handles.options);
    assignin('base', 'retrievalData', handles.retrievalData);
    
	helpdlg('model loaded successfuly!');
end


% --- Executes on button press in btnLoadFeaSet.
function btnLoadFeaSet_Callback(hObject, eventdata, handles)
    disp('loading dataset');
    t = load(handles.outFilename);
	handles.out = t.out;
	guidata(hObject, handles);
	
	%make dataset visible from workspace
	assignin('base', 'out', handles.out);
	helpdlg('Dataset loaded successfuly!');
end

function info_Callback(hObject, eventdata, handles)
end

% --- Executes during object creation, after setting all properties.
function info_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
end

function editNumOfReturnedImages_Callback(hObject, eventdata, handles)
    getNumOfReturnedImages(hObject, handles);
end

function getNumOfReturnedImages(hObject, handles)
    s = get(handles.editNumOfReturnedImages,'String');
    handles.numOfReturnedImages = str2double(s);
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function editNumOfReturnedImages_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function btnQuery_Callback(hObject, eventdata, handles)
    executeQuery(hObject, eventdata, handles);
end
