clc;
clear all;
III=imread('RL.JPG');
II= imresize(III, [676 1200]);

imtool(II)
JJ=imread('RL1.JPG');
J= imresize(JJ, [676 1200]);






b=ref_point_find(II);
h=b(2)
g=b(1)




I= imresize(II, [360 640]);
  I1=line_det(I);
  imtool(I1)

 
[theta,d]=find_theta_d(I)


s1=0;
s2=0;
[y,x,cha]=size(J);

k=abs((x-h)/h);
l=abs((y-g)/g);
count=0

for i=0:5:100
    count=count+1;
    if(count>15)
        break;
    end
  x1=((100-i)*s1+i*h)/(100);
  y1=((100-i)*s2+i*g)/(100);
  x2=(h-x1)*k+h;
  y2=(g-y1)*l+g;
 I2=imcrop(J,[x1 y1 x2-x1 y2-y1]);
 I3= imresize(I2, [360 640]);
 filename = sprintf('/home/cvrlab/Desktop/data/%d.png', i);
 imwrite(I3, filename)
 imshow(I3);
 mmm=input('dhtd');  
    
    
    
end