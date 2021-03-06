function [IMGset,y]=DataAugmentation(IMGset,metodo,IsTrain,y,NumberEigen)
%IsTrain=1 if IMGset is the training set
append=size(IMGset,4)+1;
QuanteIMG=size(IMGset,4);%number of images of the dataset

if isequal(metodo,'PCA')
    %PCA
    %build projection matrix using training data
    [IMGset,y]=PCA_DataAUG(IMGset,y,append,NumberEigen);
    
    
elseif  isequal(metodo,'DCT')
    for img=1:QuanteIMG %number of images of the dataset
        I=IMGset(:,:,:,img); %given image
        for banda=1:3 %one the three bands (RGB)
            totNewImage=0;
            
            %%%%%%%%%  DCT
            d=dct2(I(:,:,banda));
            
            %reset some random dct coefficients
            K=d;
            K(randi([0 1], size(K,1),size(K,2))==0)=0;
            K(1,1)=d(1,1);
            IMGset(:,:,banda,append)=idct2(K);
            y(append)=y(img);
            append=append+1;
            totNewImage=totNewImage+1;
            
            %random noise
            noise=std(d(:))/2;
            K=d;
            K=K+(rand(size(K))-0.5).*noise;
            K(1,1)=d(1,1);
            IMGset(:,:,banda,append)=idct2(K);
            y(append)=y(img);
            append=append+1;
            totNewImage=totNewImage+1;
            
            %random coefficients from other 5 images of the same class
            label=y(img);
            SameLabel=find(y(1:QuanteIMG)==label);
            OtherIMG=randperm(length(SameLabel));
            OtherIMG=OtherIMG(1:5);
            K=d;
            for other=1:5
                newDCT=dct2(IMGset(:,:,banda,OtherIMG(other)));
                RandomCoef=rand(size(K));
                RandomCoef(RandomCoef<0.95)=0;
                RandomCoef(RandomCoef>=0.95)=1;
                K(RandomCoef==1)=newDCT(RandomCoef==1);
            end
            IMGset(:,:,banda,append)=idct2(K);
            y(append)=y(img);
            append=append+1;
            totNewImage=totNewImage+1;
            
            if banda<3
                append=append-totNewImage;
            end
        end
    end
end
    
