function HarrisExplanation
       
    im = imread('1154.png');
    figure();
    a1 = subplot(1,2,1);
    a2 = subplot(1,2,2);
    xlim(a2,[-100 100]);
    ylim(a2,[-100 100]);
 
    imshow(im,'Parent',a1);
    initialPosition = [10 10 100 100];
    rectHandle = imrect(a1,initialPosition);
 
    scatterHandle = scatter([],[]);
    hold(a2,'on');
    v1 = plot(a2,0,0,'r');
    v2 = plot(a2,0,0,'r');
 
    rectHandle.addNewPositionCallback( @(pos)Callback(pos,scatterHandle,a2,v1,v2,im));
end
 
function Callback(position,scatterHandle,a2,v1,v2,im)
    x1 = position(1);
    y1 = position(2);
    x2 = position(1) + position(3);
    y2 = position(2) + position(4);
 
    thumbnail = double(im( round(y1:y2),round(x1:x2),2));
    dx = [-1 0 1;
          -1 0 1;
          -1 0 1];
    dy = dx';
    Ix = conv2(thumbnail,dx,'valid');
    Iy = conv2(thumbnail,dy,'valid');
    set(scatterHandle,'XData',Ix(:),'YData',Iy(:));
    A = [ sum(Ix(:).*Ix(:)) sum(Ix(:).*Iy(:)); sum(Ix(:).*Iy(:)) sum(Iy(:).*Iy(:)) ];
    [V,vals] = eig(A);
 
    lambda(1) = vals(1,1);
    lambda(2) = vals(2,2);
     
    lambda = lambda./max(lambda);
 
    set(v1,'XData',[0 V(1,1)*100*lambda(1)],'YData',[0 V(1,2)*100*lambda(1)]);
    set(v2,'XData',[0 V(2,1)*100*lambda(2)],'YData',[0 V(2,2)*100*lambda(2)]);
 
    xlim(a2,[-200 200]);
    ylim(a2,[-200 200]);
    axis(a2,'equal');
    c = cornermetric(im(:,:,2),'MinimumEigenvalue','FilterCoefficients', fspecial('gaussian',[1 31],1.5));
figure;imagesc(c);
th = 0.1;
largeEnoughCorners = c > th * max(c(:));
centroids = regionprops(largeEnoughCorners,'Centroid');
centers = cat(1,centroids.Centroid);
figure;imshow(im);hold('on');scatter(centers(:,1),centers(:,2),'SizeData',60,'MarkerFaceColor','g');
end
