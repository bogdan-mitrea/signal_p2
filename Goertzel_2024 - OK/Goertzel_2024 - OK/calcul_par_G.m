%calcul parametri Goertzel

% k/N = f/fs
% coefk = 2*cos(2*pi*k/N)
N= 200;
fs=8000;

f = zeros(4,8);
k = zeros(4,8);
coefs = zeros(4,8);
coefsh = cell(4,8);
for i=1:4
  for j=1:8
    coefsh{i,j}='';
  end
end

coefs1 = zeros(4,8);
err = zeros(4,8);

f(1,:) = [ 200, 360, 520, 680, 1240, 1400, 1560, 1720];
f(2,:) = [ 280, 440, 600, 760, 1160, 1320, 1480, 1640];
f(3,:) = [ 200, 360, 520, 680, 1160, 1320, 1480, 1640];
f(4,:) = [ 280, 440, 600, 760, 1240, 1400, 1560, 1720];

for i=1:4
    for j = 1:8
        k(i,j) = f(i,j)*N/fs;
    end
end

for i=1:4
    for j = 1:8
        coefs(i,j) = 2*cos(2*pi*k(i,j)/N);
    end
end

% conversie coeff in format 2.14
% coefs = (-1)S2^1 + x0 2^0 + x1 2^-1 + x14 2^-14
% coefsh = S x0 x1 ... x14

% exemplu coefs =1.5 >0
% S = 0
% x0 = 1, x1 = 1, x2 = x3 = ... x14 =0
% coefsh = '0110000000000000' = 6000

% echivalent
% inmultire coefs cu 2^14 (scalare de la [-2,2) la (-32768,32768)
% reprezentare in hexa
% in matlab, functiile dec2bin, bin2dec, dec2hex functioneaza pentru numere pozitive

for i=1:4
  for j=1:8
      coefsh{i,j}= dec2bin(uint16(coefs(i,j)*16384));
      coefsh{i,j} = dec2hex(bin2dec(coefsh{i,j}));
end
end

% verificare
for i=1:4
  for j=1:8
  coefs1(i,j) = hex2dec(coefsh{i,j}) / 16384;
  err(i,j) = coefs(i,j) - coefs1(i,j);
  end
end


% scriere in fisiere
fis=fopen('param_Goertzel.dat','wt');
fprintf(fis,'Parametrii Goertzel\n');
fprintf(fis,'==============================================================\n');
fprintf(fis,'frecventa de esantionare %s\n',int2str(fs));
fprintf(fis,'numar de esantioane %s\n',int2str(N));
fprintf(fis,'==============================================================\n');

for i=1:4
fprintf(fis,'\n--------------------------------------------------------------');
fprintf(fis,'\nsetul %s\n',int2str(i));
fprintf(fis,'--------------------------------------------------------------\n');
fprintf(fis,'frecvente\n');
  for j=1:8
  fprintf(fis,'%d\t',f(i,j));
  end
fprintf(fis,'\nparametrul k\n');
for j=1:8
  fprintf(fis,'%d\t',k(i,j));
  end
fprintf(fis,'\ncoeficientii (float)\n');
for j=1:8
  fprintf(fis,'%f\t',coefs(i,j));
  end
fprintf(fis,'\ncoeficientii (2.14)\n');
for j=1:8
  fprintf(fis,'%s\t',coefsh{i,j});
  end
end



fclose(fis);


