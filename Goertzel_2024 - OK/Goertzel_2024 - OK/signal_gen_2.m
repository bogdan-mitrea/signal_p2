M=1000;

fs=8000;

A =0.9;
%
% frecvente: 200	360	520	680	1240	1400	1560	1720

fd=200;
for i=1:M
   x(i)=A*sin(2*pi*i*fd/fs);
end

fis=fopen('200.dat','wt');
fprintf(fis,'%1.14f\n' ,x);
fclose(fis);

fd=360;
for i=1:M
   x(i)=A*sin(2*pi*i*fd/fs);
end

fis=fopen('360.dat','wt');
fprintf(fis,'%1.14f\n' ,x);
fclose(fis);

fd=520;
for i=1:M
   x(i)=A*sin(2*pi*i*fd/fs);
end

fis=fopen('520.dat','wt');
fprintf(fis,'%1.14f\n' ,x);
fclose(fis);

fd=680;
for i=1:M
   x(i)=A*sin(2*pi*i*fd/fs);
end

fis=fopen('680.dat','wt');
fprintf(fis,'%1.14f\n' ,x);
fclose(fis);

fd=1240;
for i=1:M
   x(i)=A*sin(2*pi*i*fd/fs);
end

fis=fopen('1240.dat','wt');
fprintf(fis,'%1.14f\n' ,x);
fclose(fis);

fd=1400;
for i=1:M
   x(i)=A*sin(2*pi*i*fd/fs);
end

fis=fopen('1400.dat','wt');
fprintf(fis,'%1.14f\n' ,x);
fclose(fis);

fd=1560;
for i=1:M
   x(i)=A*sin(2*pi*i*fd/fs);
end

fis=fopen('1560.dat','wt');
fprintf(fis,'%1.14f\n' ,x);
fclose(fis);

fd=1720;
for i=1:M
   x(i)=A*sin(2*pi*i*fd/fs);
end

fis=fopen('1720.dat','wt');
fprintf(fis,'%1.14f\n' ,x);
fclose(fis);

fx = zeros(4,8);
fx(1,:) = [ 200, 360, 520, 680, 1240, 1400, 1560, 1720];
fx(2,:) = [ 280, 440, 600, 760, 1160, 1320, 1480, 1640];
fx(3,:) = [ 200, 360, 520, 680, 1160, 1320, 1480, 1640];
fx(4,:) = [ 280, 440, 600, 760, 1240, 1400, 1560, 1720];

for i=1:4
    for j=1:4
        for l=5:8
            for k=1:M
                x(k)=A/2*sin(2*pi*k*fx(i,j)/fs)+A/2*sin(2*pi*k*fx(i,l)/fs);
            end
            filename = sprintf('%d_%d.dat', fx(i, j), fx(i, l));
            fis=fopen(filename,'wt');
            fprintf(fis,'%1.14f\n' ,x);
            fclose(fis);
        end
    end
end


%fx1=200;
%fx2=1240;
%for k=1:M
%   x(i)=A/2*sin(2*pi*k*fd1/fs)+A/2*sin(2*pi*k*fd2/fs);
%end

%fis=fopen('200_1240.dat','wt');
%fprintf(fis,'%1.14f\n' ,x);
%fclose(fis);
