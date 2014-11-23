function newPred = confirmPred(queryImage, pred)
	labelRef = '';
	ask = 'Is it corrent? If not, please input a new label.';
	prompt = {sprintf('Predicted label for the query image by me is %d: %s. %s %s', pred, 'some chair...', ask, labelRef)};
	dlg_title = 'confirm classify result';
	num_lines = 1;
	def = {num2str(pred)};
	newPred = inputdlg(prompt, dlg_title, num_lines, def);
end
