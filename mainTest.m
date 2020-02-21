clc;
clear all;
close all;

%% Read panchromatic Image
[file, path]=uigetfile('*','Select PAN Image');
I1=imresize(imread(strcat(path,file)),[512 512]);
if(numel(size(I1))>=3)
  I1=rgb2gray(I1);  
end
%% Read Multi spectral Image
[file, path]=uigetfile('*','Select Multi-Spectral Image');
I2=imresize(imread(strcat(path,file)),[256 256]);
figure,
subplot(1,2,1),imshow(I1);title('pan Image')
subplot(1,2,2),imshow(I2);title('Spectral Image')
%% Upsampling
I2=imresize(I2,2);
%% UDWT
Ia1=im2double(I1);
Ia2=im2double(I2);
% Pan
[ca1,chd1,cvd1,cdd1] = swt2(Ia1,1,'sym4');
dec1 = [ca1,chd1;cvd1,cdd1];
enc1=iswt2(ca1,chd1,cvd1,cdd1,'sym4');
 figure,
 imshow(abs(dec1))
 title('UDWT PAN')
 
 figure,
 imshow(abs(enc1))
 title('Decode UDWT PAN')
 
% MS
 [ca2,chd2,cvd2,cdd2] = swt2(Ia2,1,'sym4');
 dec2 = [ca2,chd2;cvd2,cdd2];
 
 figure,
 subplot(1,3,1)
 imshow(dec2(:,:,1))
 title('UDWT MS Red')
 subplot(1,3,2)
 imshow(dec2(:,:,2))
 title('UDWT MS Green')
 subplot(1,3,3)
 imshow(dec2(:,:,3))
 title('UDWT MS Blue')
 
 %% Injection model 
 for ik=1:3
 s=ca2(:,:,ik);
 gk(ik)= cov([s(:)' ca1(:)'])./var(ca1(:));
 end
 
 figure,
 bar(gk)
 xlabel('Bins')
 ylabel('Weight Gain')
  
%%  Fusion
% LL
y=0.3.*ca2(:,:,1)+0.4.*ca2(:,:,2)+0.3.*ca2(:,:,3);
G1=(1-gk);
Ims2LL=ca2;
Ims2LL(:,:,1)=ca2(:,:,1)+gk(1).*(ca1-y);
Ims2LL(:,:,2)=ca2(:,:,2)+gk(2).*(ca1-y);
Ims2LL(:,:,3)=ca2(:,:,3)+gk(3).*(ca1-y);
figure,
imshow((Ims2LL),[])
title('Enh LL Image')

 Ims2LH=chd2;
 Ims2LH(:,:,1)=chd1+chd2(:,:,1);
 Ims2LH(:,:,2)=chd1+chd2(:,:,2);
 Ims2LH(:,:,3)=chd1+chd2(:,:,3);
 
 Ims2HL(:,:,1)=cvd1+cvd2(:,:,1);
 Ims2HL(:,:,2)=cvd1+cvd2(:,:,2);
 Ims2HL(:,:,3)=cvd1+cvd2(:,:,3);
 
 
 Ims2HH(:,:,1)=cdd1+cdd2(:,:,1);
 Ims2HH(:,:,2)=cdd1+cdd2(:,:,2);
 Ims2HH(:,:,3)=cdd1+cdd2(:,:,3);
 
 
 %% Inverse conversion
 
  X(:,:,1) = iswt2(Ims2LL(:,:,1),Ims2LH(:,:,1),Ims2HL(:,:,1),Ims2HH(:,:,1),'sym4');  
  X(:,:,2) = iswt2(Ims2LL(:,:,2),Ims2LH(:,:,2),Ims2HL(:,:,2),Ims2HH(:,:,2),'sym4');  
  X(:,:,3) = iswt2(Ims2LL(:,:,3),Ims2LH(:,:,3),Ims2HL(:,:,3),Ims2HH(:,:,3),'sym4');  
  
  figure,
  imshow(X,[])
  title('Enhanced image')
  
%% Performance
figure,
subplot(1,3,1),imshow(I1);title('pan Image')
subplot(1,3,2),imshow(I2);title('Spectral Image')
subplot(1,3,3),imshow(X,[]);title('Enhanced Image')

