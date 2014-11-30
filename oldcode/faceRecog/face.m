clc,clear  
npersons=40;%选取40个人的脸  
global imgrow;  
global imgcol;  
imgrow=112;  
imgcol=92;  
  
disp('reading train data...')  
f_matrix=ReadFace(npersons,0);%读取训练数据  
nfaces=size(f_matrix,1);%样本人脸的数�? 
disp('.................................................')  
%低维空间的图像是(nperson*5)*k的矩阵，每行代表�?��主成分脸，每个脸20维特�? 
  
disp('train data PCAing...')  
mA=mean(f_matrix);  
k=20;%降维�?0�? 
[pcaface,V]=fastPCA(f_matrix,k,mA);%主成分分析法特征提取  
disp('.................................................')  
  
disp('display PC face...')  
visualize(V)%显示主分量脸  
disp('.................................................')  
  
disp('normalizing...')  
disp('.................................................')  
lowvec=min(pcaface);  
upvec=max(pcaface);  
scaledface = scaling( pcaface,lowvec,upvec);  
  
disp('SVM training...')  
disp('.................................................')  
gamma=0.0078;  
c=128;  
multiSVMstruct=multiSVMtrain( scaledface,npersons,gamma,c);  
  
disp('reading test data...')  
disp('.................................................')  
[testface,realclass]=ReadFace(npersons,1);  
  
disp('test data reducing...')  
disp('.................................................')  
m=size(testface,1);  
for i=1:m  
    testface(i,:)=testface(i,:)-mA;  
end  
pcatestface=testface*V;  
  
disp('test data normalizing...')  
disp('.................................................')  
scaledtestface = scaling( pcatestface,lowvec,upvec);  
  
disp('SVM classification...')  
disp('.................................................')  
class= multiSVM(scaledtestface,multiSVMstruct,npersons);  
  
accuracy=sum(class==realclass)/length(class);  
display(['accurcy: ',num2str(accuracy)])  
