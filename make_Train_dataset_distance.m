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

  if ~(85<=theta & theta<=95)
      continue;
  end

perc=75;
no_frame=100;
frame=(no_frame*100)/perc;



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
                ytrain(1,1,TrainImgNo) = theta*(pi/180);
                ytrain(1,2,TrainImgNo) = xh/1200;
               
               
               
               %filename = sprintf('./TrainResults/%d.png', TrainImgNo);
               %imwrite(I3, filename);
                
               flip_I3 = fliplr(I3);
          
               TrainImgNo = TrainImgNo+1;
               xtrain(:,:,:,TrainImgNo) = permute(flip_I3,[2 1 3]);
               ytrain(1,1,TrainImgNo) = pi- theta*(pi/180);
               ytrain(1,2,TrainImgNo) = 1-xh/1200;
               
               %filename = sprintf('./TrainResults/%d.png', TrainImgNo);
               %imwrite(flip_I3, filename);
            
        end        
    end
end


[ss1,ss2,ss3,ss4]=size( xtrain);
rand_row=randperm(ss4);
for i=1:21000
    xtrain1(:,:,:,i)= xtrain(:,:,:,rand_row(i));
     ytrain1(1,1,i) = ytrain(1,1,rand_row(i));
     ytrain1(1,2,i) =  ytrain(1,2,rand_row(i));
              
    
     I3=permute( xtrain1(:,:,:,i),[2 1 3]);
     filename = sprintf('./TrainResults_distance/%d.png', i);
     imwrite(I3, filename);
       
    
end

hdf5write('NewTrainData_21000_distance.h5','xtrain',xtrain1,'ytrain',ytrain1);

