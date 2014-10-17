%%======================================================================
%% STEP 6: Test 

[pred] = stackedAEPredict(stackedAETheta, inputSize, hiddenSizeL2, ...
                          numClasses, netconfig, testData, classMethod, multiSVMmodels, usedLabels);

acc = mean(testLabels(:) == pred(:));
fprintf('Before Finetuning Test Accuracy: %0.3f%%\n', acc * 100);

[pred] = stackedAEPredict(stackedAEOptTheta, inputSize, hiddenSizeL2, ...
                          numClasses, netconfig, testData, classMethod, multiSVMmodels, usedLabels);

acc = mean(testLabels(:) == pred(:));
fprintf('After Finetuning Test Accuracy: %0.3f%%\n', acc * 100);

%% -----------------------------------------------------
% test all examples
[pred1] = stackedAEPredict(stackedAEOptTheta, inputSize, hiddenSizeL2, ...
                          numClasses, netconfig, labeledData, classMethod, multiSVMmodels, usedLabels);
						  
pp = sum(pred1(:) == allLabels(:));
tt = numel(allLabels);
fprintf('Test Accuracy on all examples: %d/%d = %f%%\n', pp, tt, 100*pp/tt);

pr1 = pred1(:);
lb1 = allLabels(:);

levels = unique(lb1);
for i = 1:numel(levels)
	pp = sum(pr1 == lb1 & lb1 == levels(i));
	tt = sum(lb1 == levels(i));
	fprintf('Test Accuracy of class #%d: %d/%d = %f%%\n', levels(i), pp, tt, 100 * pp./ tt);
end

[F1, prec, rec] = f1_score(lb1, pr1);
fprintf('F1 score: %f%%\n', 100 * F1);
