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
    
   
%     
%     for idx=1:9
%         %Line Image
%         PaintedImage = imread([PaintedImageDir,'/',num2str(idx,'%d'),'.JPG']);
%         PaintedImage = imresize(PaintedImage, [676 1200]);
%         %imshow(II);
%         NormalImage = imread([NormalImageDir,'/',num2str(idx,'%d'),'.JPG']);
%         NormalImage = imresize(NormalImage, [676 1200]);
%         
         
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
        %Line Image
        %PaintedImage = imread([PaintedImageDir,'/',num2str(idx,'%d'),'.jpg']);
	PaintedImage = imread([PaintedImageDir,'/',img_paint]);
        PaintedImage = imresize(PaintedImage, [676 1200]);
        %imshow(II);
        %NormalImage = imread([NormalImageDir,'/',num2str(idx,'%d'),'.JPG']);
	NormalImage = imread([NormalImageDir,'/',img_normal]);
        NormalImage = imresize(NormalImage, [676 1200]);
        
         
        [Center_x,Center_y] =ref_point_find1(PaintedImage);
%         Center_x = RefPoint(2);
%         Center_y = RefPoint(1);
        
        PaintedImage = imresize(PaintedImage, [360 640]);
        %PaintedImage = imresize(PaintedImage, [180 320]);
        [angle,dist] = find_theta_d(PaintedImage);  %angle in degrees
        dist = dist/2;
        
        angle=angle*(pi/180);
        %dist = dist/640;
        dist = dist/320;
        
        s1=0;
        s2=0;
        [y,x,chan]=size(NormalImage);

        k=abs((x-Center_x)/Center_x);
        l=abs((y-Center_y)/Center_y);
        count=0;
        C_l=66;
        C_l1=45;
        for i=0:1:C_l
            count=count+1;
            if(count>C_l1)
                break;
            end
            x1=((C_l-i)*s1+i*Center_x)/(C_l);
            y1=((C_l-i)*s2+i*Center_y)/(C_l);
            x2=(Center_x-x1)*k+Center_x;
            y2=(Center_y-y1)*l+Center_y;
            I2=imcrop(NormalImage,[x1 y1 x2-x1 y2-y1]);
            %I3= imresize(I2, [360 640]);
            I3= imresize(I2, [180 320]);
            ran = rand();
            if(ran<=1)
                TrainImgNo = TrainImgNo+1;
                xtrain(:,:,:,TrainImgNo) = permute(I3,[2 1 3]);
                ytrain(1,TrainImgNo) = angle;
                ytrain(2,TrainImgNo) = dist;
                filename = sprintf('./TrainResults/%d.png', TrainImgNo);
                imwrite(I3, filename)
            else
                TestImgNo = TestImgNo+1;
                xtest(:,:,:,TestImgNo) = permute(I3,[2 1 3]);
                ytest(1,TestImgNo) = angle;
                ytest(2,TestImgNo) = dist;
                filename = sprintf('./TestResults/%d.png', TestImgNo);
                imwrite(I3, filename)
            end

            flip_I3 = fliplr(I3);
            ran = rand();
            if(ran<=1)
                TrainImgNo = TrainImgNo+1;
                xtrain(:,:,:,TrainImgNo) = permute(flip_I3,[2 1 3]);
                %ytrain(1,TrainImgNo) = 180 - angle;
                ytrain(1,TrainImgNo) = pi - angle;
                ytrain(2,TrainImgNo) = 1.0 - dist;
                filename = sprintf('./TrainResults/%d.png', TrainImgNo);
                imwrite(flip_I3, filename);
            else
                TestImgNo = TestImgNo+1;
                xtest(:,:,:,TestImgNo) = permute(flip_I3,[2 1 3]);
                %ytest(1,TestImgNo) = 180 - angle;
                ytest(1,TestImgNo) = pi - angle;
                ytest(2,TestImgNo) = 1.0 - dist;
                filename = sprintf('./TestResults/%d.png', TestImgNo);
                imwrite(flip_I3, filename);
            end   
        end        
    end
end
hdf5write('NewTrainData.h5','xtrain',xtrain,'ytrain',ytrain);
%hdf5write('NewTestData.h5','xtest',xtest,'ytest',ytest);


