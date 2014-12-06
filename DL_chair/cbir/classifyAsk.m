function varargout = classifyAsk(varargin)
	% classifyAsk MATLAB code for classifyAsk.fig
	%      classifyAsk, by itself, creates a new classifyAsk or raises the existing
	%      singleton*.
	%
	%      H = classifyAsk returns the handle to a new classifyAsk or the handle to
	%      the existing singleton*.
	%
	%      classifyAsk('CALLBACK',hObject,eventData,handles,...) calls the local
	%      function named CALLBACK in classifyAsk.M with the given input arguments.
	%
	%      classifyAsk('Property','Value',...) creates a new classifyAsk or raises the
	%      existing singleton*.  Starting from the left, property value pairs are
	%      applied to the GUI before classifyAsk_OpeningFcn gets called.  An
	%      unrecognized property name or invalid value makes property application
	%      stop.  All inputs are passed to classifyAsk_OpeningFcn via varargin.
	%
	%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
	%      instance to run (singleton)".
	%
	% See also: GUIDE, GUIDATA, GUIHANDLES

	% Edit the above text to modify the response to help classifyAsk

	% Last Modified by GUIDE v2.5 30-Nov-2014 14:34:07

	% Begin initialization code - DO NOT EDIT
	gui_Singleton = 1;
	gui_State = struct('gui_Name',       mfilename, ...
		'gui_Singleton',  gui_Singleton, ...
		'gui_OpeningFcn', @classifyAsk_OpeningFcn, ...
		'gui_OutputFcn',  @classifyAsk_OutputFcn, ...
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

% --- Executes just before classifyAsk is made visible.
function classifyAsk_OpeningFcn(hObject, eventdata, handles, varargin)
	handles.modelput = hObject;

	handles.options = cnnOptions();
	
	handles.options.dataDir = [handles.options.dataDir, 'cbir/'];
    handles.modelFilename = [handles.options.dataDir, 'model.mat'];
    handles.optionsDataFilename = [handles.options.dataDir, 'options.mat'];

    handles.retrievalDir = handles.options.imgDir;
	
    set(handles.info, 'String', ['retrieval dir: ', handles.retrievalDir]);

	fnames = dirRecursive(handles.retrievalDir);
    acceptExts = {'png', 'jpg', 'gif', 'bmp', 'jpeg'};
    [handles.dirFileCnt, handles.fnames] = cntByDir(fnames, acceptExts);
	handles.current = 1;
	guidata(hObject, handles);
	
    set(handles.selClassifyAlg, 'Value', 1);
    
    loadModel(hObject, handles);

	% UIWAIT makes classifyAsk wait for user response (see UIRESUME)
	% uiwait(handles.figure1);
	
end

% --- Outputs from this function are returned to the command line.
function varargout = classifyAsk_OutputFcn(hObject, eventdata, handles)
	varargout{1} = handles.modelput;
end

%% ==========================================================================
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

%% ==========================================================================
% --- Executes on button press in btnLoadModel.
function btnLoadModel_Callback(hObject, eventdata, handles)
    loadModel(hObject, handles);
end

function loadModel(hObject, handles)
    disp('loading model...');
    t = load(handles.modelFilename);
	handles.model = t.model;
    disp('finish loading model...');
    
    disp('loading options...');
    t = load(handles.optionsDataFilename);
	handles.options = t.options;
    disp('finish loading options...');
    
	guidata(hObject, handles);
	
	assignin('base', 'model', handles.model);
    assignin('base', 'options', handles.options);
end

%% ==========================================================================
function btnCorrect_Callback(hObject, eventdata, handles)
    handles.current = handles.current + 1;
	if handles.current > handles.dirFileCnt
		errordlg('finished');
		handles.current = 1;
    end
    guidata(hObject, handles);
	
    classifyImg(handles, handles.current);	
end

%% ==========================================================================
function btnStart_Callback(hObject, eventdata, handles)
    handles.current = 1;
    guidata(hObject, handles);
	classifyImg(handles, handles.current);
end

%% ==========================================================================
function classifyImg(handles, idx)
	if (~isfield(handles, 'model'))
		errordlg('Please load model first!');
		return;
    end
	
	fprintf('classify image #%d\n', idx);
	
			fn = handles.fnames{idx};
            
            queryImage = imread(fn);
            plotQueryImage(queryImage);
            
            queryImage = preprocessImage1(queryImage, handles.options.imageDim);
            imgData = cell2mat4d({queryImage});
            queryImageFeature = cnnComputeFeature(handles.model, imgData, handles.options);
            
            handles.classifyAlg = get(handles.selClassifyAlg, 'Value');
            
            % do classify
            % classification
            disp('predicting for query iamge...');
            
            pred = 0;
            if handles.classifyAlg == 2
                pred = softmaxPredict(handles.softmaxModel, queryImageFeature);
            elseif handles.classifyAlg == 3
                error('predicting for retrieval features with svm not supported')
            end

            fprintf('predicting result %d\n', pred);
            disp(handles.classifyAlg)
            
            if handles.classifyAlg ~= 1
                set(handles.textClassifyResult, 'String', ['classify result£º', num2str(pred)]);
            end
end

