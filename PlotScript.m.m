a=csvread('caract_stt_0.5hz.csv');
a2=csvread('car_din.csv');
b=size(a);
b2=size(a2);
t=1:b(1);
t2=1:b2(1);
temp=a(:,1);
temp2=a2(:,1);

cmd=unique(a(:,3));

filter_temp=zeros(size(cmd));
time=zeros(size(cmd));
aux=0;
j=1;
aux=cmd(1);
for i=1:size(temp)
    if(aux<a(i,3))
        filter_temp(j)=temp(i-1);
        time(j)=i-1;
        j=j+1;
        aux=cmd(j);
    end
end
filter_temp(end)=temp(end);
[a,b]=size(temp);
time(end)=a;
%time2=time(1:end-1)
%plot((501:1841)*(1/30),temp(501:1841)/100)
subplot(2,1,1)
plot(cmd,filter_temp/100);
title('Caracteristica staticã a procesului cu elementul de încãlzire','FontSize',12);
xlabel('Comanda U [%]','FontSize',12);
ylabel('Temperaturã [°C]','FontSize',12);
subplot(2,1,2)
plot(t2*(1/30),temp2/100)
title('Caracteristica dinamicã a procesului cu elementul de încãlzire','FontSize',12);
xlabel('Timp [s]','FontSize',12);
ylabel('Temperaturã [°C]','FontSize',12);
