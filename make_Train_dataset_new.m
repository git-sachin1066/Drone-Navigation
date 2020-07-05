clc;
clear all;

Data_dir = ['../FINALDATASET_train'];
MyFolderInfo = dir(Data_dir);
pwd
len = length(MyFolderInfo)
TrainImgNo = 0;
TestImgNo = 0;
for cor=1:len
    corridor_name = MyFolderInfo(cor).name;
    if strcmp(corridor_name,'.') || strcmp(corridor_name,'..')        
        continue;
    end
    display([num2str(cor,'%d'),' ',corridor_name]);
    %CorridorInfo = dir([Data_dir,'/',corridor_name]);
    NormalImageDir = [Data_dir,'/',corridor_name,'/CONJIMAGE'];
    PaintedImageDir = [Data_dir,'/',corridor_name,'/IMAGE'];
    

         
    FolderPainted = dir(PaintedImageDir); 
    FolderNormal = dir(NormalImageDir);
    lenNormal = length(FolderNormal);
    lenPainted = length(FolderPainted);
    if lenNormal ~= lenPainted
	   continue;
    end
    for idx=1:lenNormal
	img1 = FolderNormal(idx).name;
	if strcmp(img1,'.') || strcmp(img1,'..')        
		continue;
	end
	img_paint = FolderPainted(idx).name;
	img_normal = FolderNormal(idx).name;
        
	    PaintedImage = imread([PaintedImageDir,'/',img_paint]);
        PaintedImage = imresize(PaintedImage, [676 1200]);        
        
 [ xl,yl,xh,yh,Center_x,Center_y,theta,x_comp ] = find_theta_d_coor(PaintedImage);
 sfx=(180/676);
 sfy=(320/1200);
 x_comp=abs(x_comp)*sfx;

perc=70;
no_frame=50;
t=100;
frame=(no_frame*100)/perc;
del_x=(x_comp*(perc/100))/no_frame;
lebel=zeros(no_frame,6);


for i=0:(no_frame-1)
    if(theta>93)
        lebel(i+1,1)=(i*del_x+xh)*sfx;
        lebel(i+1,2)=yh*sfy;
        
        lebel(i+1,3)=t*cosd(180-theta)+ lebel(i+1,1);
        lebel(i+1,4)=-t*sind(180-theta)+lebel(i+1,2);
        lebel(i+1,5)=angle( lebel(i+1,1), lebel(i+1,2), lebel(i+1,3), lebel(i+1,4) );
        lebel(i+1,6)=theta;
     end
     if(theta<88)
        lebel(i+1,1)=(-i*del_x+xh)*sfx;
        lebel(i+1,2)=yh*sfy;
      
        lebel(i+1,3)=-t*cosd(theta)+ lebel(i+1,1);
        lebel(i+1,4)=-t*sind(theta)+lebel(i+1,2);
        lebel(i+1,5)=angle( lebel(i+1,1), lebel(i+1,2), lebel(i+1,3), lebel(i+1,4) );
        lebel(i+1,6)=theta;
        
        end
     if(88<=theta & theta<=93)
        lebel(i+1,1)=(xh)*sfx;
        lebel(i+1,2)=yh*sfy;
        lebel(i+1,3)=lebel(i+1,1);
        lebel(i+1,4)=-t+lebel(i+1,2);
        lebel(i+1,5)=angle( lebel(i+1,1), lebel(i+1,2), lebel(i+1,3), lebel(i+1,4) );
        lebel(i+1,6)=theta;
     end
    
end
        NormalImage = imread([NormalImageDir,'/',img_normal]);
        NormalImage = imresize(NormalImage, [676 1200]);
        
         
        %[Center_x,Center_y] =ref_point_find1(PaintedImage);

        
        PaintedImage = imresize(PaintedImage, [360 640]);
        %PaintedImage = imresize(PaintedImage, [180 320]);
       % [angle,dist] = find_theta_d(PaintedImage);  %angle in degrees
       
        
        %angle=angle*(pi/180);
        %dist = dist/640;
       
        
        s1=0;
        s2=0;
        [y,x,chan]=size(NormalImage);

        k=abs((x-Center_x)/Center_x);
        l=abs((y-Center_y)/Center_y);
        count=0;
       
        for i=0:1:frame
         count=count+1;
         if(count>no_frame)
           break;
         end
       x1=((frame-i)*s1+i*Center_x)/(frame);
       y1=((frame-i)*s2+i*Center_y)/(frame);
       x2=(Center_x-x1)*k+Center_x;
       y2=(Center_y-y1)*l+Center_y;
        I2=imcrop(NormalImage,[x1 y1 x2-x1 y2-y1]);
        I3= imresize(I2, [180 320]);
        TrainImgNo = TrainImgNo+1;
                 xtrain(:,:,:,TrainImgNo) = permute(I3,[2 1 3]);
                ytrain(1,1,TrainImgNo) = lebel(i+1,1);
                ytrain(1,2,TrainImgNo) = lebel(i+1,2);
                ytrain(2,1,TrainImgNo) = lebel(i+1,3);
                ytrain(2,2,TrainImgNo) = lebel(i+1,4);
                ytrain(3,1,TrainImgNo) = lebel(i+1,6)*(pi/180);
                ytrain(3,2,TrainImgNo) = lebel(i+1,1)/320;
               
               
               filename = sprintf('./TrainResults/%d.png', TrainImgNo);
                imwrite(I3, filename);
                
               flip_I3 = fliplr(I3);
          
                TrainImgNo = TrainImgNo+1;
                xtrain(:,:,:,TrainImgNo) = permute(flip_I3,[2 1 3]);
                ytrain(1,1,TrainImgNo) = 320-lebel(i+1,1);
                ytrain(1,2,TrainImgNo) = lebel(i+1,2);
                ytrain(2,1,TrainImgNo) = 320-lebel(i+1,3);
                ytrain(2,2,TrainImgNo) = lebel(i+1,4);
                ytrain(3,1,TrainImgNo) = pi-lebel(i+1,6)*(pi/180);
                ytrain(3,2,TrainImgNo) = 1-lebel(i+1,1)/320;
             
                

                filename = sprintf('./TrainResults/%d.png', TrainImgNo);
                imwrite(flip_I3, filename);
            
        end        
    end
end
hdf5write('NewTrainData.h5','xtrain',xtrain,'ytrain',ytrain);

