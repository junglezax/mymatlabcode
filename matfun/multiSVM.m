function [class] = multiSVM(testData, multiSVMstruct, nclass)  
	%对测试数据进行分类  
	m=size(testData,1);  
	voting=zeros(m,nclass);  
	for i=1:nclass-1  
		for j=i+1:nclass  
			class=svmclassify(multiSVMstruct{i}{j},testData);  
			voting(:,i)=voting(:,i)+(class==1);  
			voting(:,j)=voting(:,j)+(class==0);  
		end  
	end  
	[~,class]=max(voting,[],2);  
end  