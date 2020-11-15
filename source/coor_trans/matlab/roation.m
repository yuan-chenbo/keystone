clear all
clc

% ����ͼƬ
im = imread('1.jpg');

figure;
imshow(im); 

% �����ת����
a = 20 / 180 * pi;
R = [cos(a), sin(a); -sin(a), cos(a)];
 
% ���ͼƬ��С chΪͨ���� hΪ�߶� wΪ���
sz = size(im);
h = sz(1);
w = sz(2);
ch = sz(3);
c = [w;h] /2;

%  fid=fopen('coordinate_30.txt','w');
%  fprintf(fid,"x1\t\ty1\t\tx0\t\t\tyo\n");
 
% ��ʼ�����ͼ��
im2 = uint8(zeros(h, w, 3));
for k = 1:ch                    %�������ͼ������λ�õ�����
    for i = 1:h
       for j = 1:w  
          p = [j; i];           % p :���ͼ�����������
          % roundΪ��������
          pp = round(R*(p-c)+c);    %pp ����Ӧ������ͼ�����������
          %����������صĲ��� 
%             if(k==1)
%                 fprintf(fid,"%d,\t\t%d,\t\t%d,\t\t%d\t\n",i,j,pp(1),pp(2));
%             end          
            if (pp(1) >= 1 && pp(1) <= w && pp(2) >= 1 && pp(2) <= h)
                im2(i, j, k) = im(pp(2), pp(1), k);  
            end
       end
    end
end
 
% ��ʾͼ��
figure;
imshow(im2);