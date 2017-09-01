clear, clc
filename = '58150.txt';

fid = fopen(filename);

data = textscan(fid, '%f %f %f %f %f %f', 'delimiter', ' ', ...
                'headerlines', 1, 'MultipleDelimsAsOne', 1);

fillva = 9999;

pres = data{1,1};
z    = data{1,2};
t    = data{1,3};
td   = data{1,4};
wdir = data{1,5};
wspd = data{1,6};

rh = double(relhum_ttd(t + 273.15, td + 273.15));
indx = z ~= fillva & t ~= fillva & td ~= fillva & wdir ~= fillva & wspd ~= fillva;
p200 = find(pres == 200);

% 忽略缺省值
figure
skewTlogP_plot(pres(indx), t(indx), rh(indx), wdir(indx), wspd(indx));
% 不处理缺省值
figure
skewTlogP_plot(pres(1:p200), t(1:p200), rh(1:p200), wdir(1:p200), wspd(1:p200));