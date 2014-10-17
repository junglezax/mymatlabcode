function [F1, prec, rec] = f1_score(y, p)
levels = unique(y);
nlevels = length(levels);
nlevelsNotZero = 0;
total = 0;
for i = 1:nlevels
	level = levels(i);
	fp = sum(p == level & y ~= level);
	tp = sum(p == level & y == level);
	fn = sum(p ~= level & y == level);
    
    prec = 0;
    if tp + fp ~= 0
        prec = tp / (tp + fp);
    end
    
    rec = 0;
    if tp + fn ~= 0
        rec = tp / (tp + fn);
    end
    
    F1 = 0;
    if prec + rec ~= 0
        F1 = 2 * prec * rec / (prec + rec);
    end
    
    if F1 ~= 0
         nlevelsNotZero = nlevelsNotZero + 1;
    end
	
	if nlevels <= 2
		return;
	end
	
	total = total + F1;
end

F1 = total ./ nlevelsNotZero;

