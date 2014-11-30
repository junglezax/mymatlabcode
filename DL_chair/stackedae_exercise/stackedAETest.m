function [acc, accFine, accAll, F1, pred, predFine, predAll] = stackedAETest(data, out, model, options)

%%======================================================================
%% STEP 6: Test 

[pred] = stackedAEPredict(model.stackedAETheta, options.inputSize, options.hiddenSizeL2, ...
                          options.numClasses, model.netconfig, out.testData, options.classMethod, model.multiSVMmodels, model.usedLabels);

acc = mean(out.testLabels(:) == pred(:));
fprintf('Before Finetuning Test Accuracy: %0.3f%%\n', acc * 100);

[predFine] = stackedAEPredict(model.stackedAEOptTheta, options.inputSize, options.hiddenSizeL2, ...
                          options.numClasses, model.netconfig, out.testData, options.classMethod, model.multiSVMmodels, model.usedLabels);

accFine = mean(out.testLabels(:) == predFine(:));
fprintf('After Finetuning Test Accuracy: %0.3f%%\n', accFine * 100);

%% -----------------------------------------------------
% test all examples
[predAll] = stackedAEPredict(model.stackedAEOptTheta, options.inputSize, options.hiddenSizeL2, ...
                          options.numClasses, model.netconfig, data.labeledData, options.classMethod, model.multiSVMmodels, model.usedLabels);
						  
pp = sum(predAll(:) == data.labels(:));
tt = numel(data.labels);
accAll = pp/tt;
fprintf('Test Accuracy on all examples: %d/%d = %f%%\n', pp, tt, 100*pp/tt);

pr1 = predAll(:);
lb1 = data.labels(:);

levels = unique(lb1);
for i = 1:numel(levels)
	pp = sum(pr1 == lb1 & lb1 == levels(i));
	tt = sum(lb1 == levels(i));
	fprintf('Test Accuracy of class #%d: %d/%d = %f%%\n', levels(i), pp, tt, 100 * pp./ tt);
end

[F1, prec, rec] = f1_score(lb1, pr1);
fprintf('F1 score: %f%%\n', 100 * F1);

end
