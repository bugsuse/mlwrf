clear, clc

dbstop if error

filename = 'fnl_20160623_06_00.grib2';
%  指定经纬度坐标
longitudes = 120;
latitudes  = 33;

setup_nctoolbox();  % 加载 nctoolbox工具箱
data = ncdataset(filename);

pres = squeeze(data.data('isobaric2'));  % 压力层
lon  = squeeze(data.data('lon'));
lat  = squeeze(data.data('lat'));

num = length(pres);
latind = find(lat == round(latitudes));
lonind = find(lon == round(180 + longitudes));

tk = data.data('Temperature_isobaric', [1 1 latind lonind], [1 num latind lonind])';  % 温度  单位： K
rh = data.data('Relative_humidity_isobaric', [1 1 latind lonind], [1 num latind lonind])';  % 相对湿度
u  = data.data('u-component_of_wind_isobaric', [1 1 latind lonind], [1 num latind lonind])'; 
v  = data.data('v-component_of_wind_isobaric', [1 1 latind lonind], [1 num latind lonind])';

wdir = wind_direction(u, v, 0);  % 计算风向
wspd = sqrt(u.^2 + v.^2);   % 计算风速

skewTlogP_plot(pres/100, tk - 273.15, rh*0.01, wdir, wspd);