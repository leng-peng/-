close all
clc;

f0=10;
f1=40;
fs=100;
t=0:1/fs:1;
input=sin(2*pi*f0*t)+sin(2*pi*f1*t);

fid = fopen('sinInput.dat','w');
fprintf(fid,'%15.10e,\n',input);
fclose(fid);

output=conv(input,Num);
output2=conv(input,Num1);


