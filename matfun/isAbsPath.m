function b = isAbsPath(p)
	b = length(p) > 0 && (p(1) == '/' || p(1) == '\' || (length(p) > 1 & p(2) == ':'));
end
