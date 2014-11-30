global h_axes1  
global h_axes2  
global edit2  
load('recognize.mat');  
set(edit2,'string','reading test data......')  
drawnow  
disp('reading test data...')  
disp('.................................................')  
img=getimage(h_axes1);%获得之前选中的照片的信息  
if isempty(img)  
    msgbox('please select an image')  
    break  
end  
testface=img(:)';  
set(edit2,'string','test data reducing......')  
drawnow  
disp('test data reducing...')  
disp('.................................................')  
Z=double(testface)-mA;  
pcatestface=Z*V;  
set(edit2,'string','test data normalization......')  
drawnow  
disp('test data normalization...')  
disp('.................................................')  
scaledtestface=-1+(pcatestface-lowvec)./(upvec-lowvec)*2;  
set(edit2,'string','SVM recognition......')  
drawnow  
disp('SVM recogition...')  
disp('.................................................')  
voting=zeros(1,npersons);  
for i=1:npersons-1  
    for j=i+1:npersons  
        class=svmclassify(multiSVMstruct{i}{j},scaledtestface);  
        voting(i)=voting(i)+(class==1);  
        voting(j)=voting(j)+(class==0);  
    end  
end  
[~,class]=max(voting);  
set(edit2,'string','done')  
drawnow  
axes(h_axes2);  
imshow(imread(['../../images/orl_faces/s',num2str(class),'\1.pgm']));  
msgbox(['result:',num2str(class)])  
