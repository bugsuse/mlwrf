clear,clc

dbstop if error

fn = 'E:\MATLAB\test.txt';
getuwyo(2003, 8, 13, 0, 55299, fn)

fid = fopen(fn);
data = textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f', ...
    'headerlines', 6, 'delimiter', ' ', 'MultipleDelimsAsOne', true);

pres = data{1,1};
z    = data{1,2};
temp = data{1,3};
dwpt = data{1,4};
relh = data{1,5};
wdir = data{1,7};
wspd = data{1,8};

p200 = find(pres == 200);

figure
skewTlogP_plot(pres(1:p200), temp(1:p200), relh(1:p200)/100, ...
    wdir(1:p200), wspd(1:p200)*1.852*0.278);