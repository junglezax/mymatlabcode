% test parallel
matlabpool local 2
testParfor
matlabpool close
