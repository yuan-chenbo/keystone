clear all
clc

x = 0:pi/180 :pi*2;
 
 y1=fix ( 2^8 *sin(x) );
 y2=fix ( 2^8 *cos(x) );
 
 
 fid=fopen('sin.txt','w');
  fid2=fopen('cos.txt','w');
  
  fprintf(fid,"�Ƕ�x����λ���ȣ�\t:\t ����ֵ��sin��x����\n");
   fprintf(fid2,"�Ƕ�x����λ���ȣ�\t:\t ����ֵ��cos��x����\n");
 
 for i = 1:360 
     fprintf(fid,"%d\t:\t %d\n",i-1,y1(i));
     fprintf(fid2,"%d\t:\t %d\n",i-1,y2(i));
 end
 
 
%  figure;
%  plot(x,y1);
% %  
%  
%   figure;
%  plot(x,y2);