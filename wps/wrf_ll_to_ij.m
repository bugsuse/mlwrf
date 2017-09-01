function ij = wrf_ll_to_ij(filename, lat, lon, varargin)
% 转换指定经纬度点坐标为模拟域中的对应坐标点。
% 参数声明：
%   输入参数：
%      filename : 输入文件名
%        lat    : 指定纬度。标量或向量。
%        lon    : 指定经度。标量或向量。
%           当 lat 和 lon 为向量时，两向量大小应一致。
%     可选参数：
%       debug   :  debugging 信息， 单元素数值。默认为0.
%       如果对应的参数名不一致，则表明WRF输出结果的属性名称顺序出现更改，
%       使用ncinfo查看数据属性并更改程序内相应变量顺序。
%   输出参数：
%      ij   : 转换后的模拟域坐标。
%         当 lat 和 lon 为向量时，输出为2 X N 数组，每一列代表一组经纬度对应的
%         模拟域坐标点。
%         第一行为 经度方向点， 第二行为纬度方向点。
%%  计算方法取自：https://github.com/cwebster2/pyMeteo 中wrf模块 
%    ll_to_ij 方法     
%%
try
    info = ncinfo(filename);
catch
    error('Fail to open the file: %s', filename)
end

if isempty(varargin)
    debug = 0;
elseif length(varargin) == 1 && isnumeric(varargin{1})
    debug = varargin{1};
else
    error('可选参数只能是一个！')
end
%  获取WRF输出结果中的相应属性
map_proj       = info.Attributes(79).Value;
map_proj_name  = info.Attributes(79).Name;
dx             = info.Attributes(7).Value;
dx_name        = info.Attributes(7).Name;
dy             = info.Attributes(8).Value;
dy_name        = info.Attributes(8).Name;
truelat1       = info.Attributes(70).Value;
truelat1_name  = info.Attributes(70).Name;
truelat2       = info.Attributes(71).Value;
truelat2_name  = info.Attributes(71).Name;
stand_lon      = info.Attributes(73).Value;
stand_lon_name = info.Attributes(73).Name;
e_wen          = info.Attributes(4).Value;
e_wen_name     = info.Attributes(4).Name;
e_snn          = info.Attributes(5).Value;
e_snn_name     = info.Attributes(5).Name;
% 读取 LAT 和  LONG 
ref_lat = ncread(filename, 'XLAT', [1 1 1], [1 1 1]);
ref_lon = ncread(filename, 'XLONG', [1 1 1], [1 1 1]);

re = 6.37e6;
pi = 3.141592653589793;
rebydx = re / dx;
radperdeg = pi/180.0;
degperrad = 180.0/pi;
hemi = 1.0;

if truelat1 < 0.0
    hemi = -1.0;
end

if map_proj == 3 % mercator
    clain = cos(radperdeg * truelat1);
    dlon = dx / ( re * clain);
    rsw = 0.0;
    if (ref_lat ~= 0)
        rsw = log(tan(0.5*((ref_lat+90.0) * radperdeg))) / dlon;
    end
    deltalon = lon - ref_lon;
    if (deltalon < -180.0)
        deltalon = deltalon + 360.0;
    end
    if (deltalon > 180.0)
        deltalon = deltalon - 360.0;
    end
    i = 0 + (deltalon / (dlon * degperrad));
    j = 0 + log(tan(0.5*((lat+90.0)*radperdeg)))/dlon - rsw;
    
elseif map_proj == 2  % polar-stereo
    reflon = stand_lon + 90.0;
    scale_top = 1.0 + hemi*sin(truelat1*radperdeg);
    ala1 = ref_lat*radperdeg;
    rsw = rebydx*cos(ala1)*scale_top/(1.0+hemi*sin(ala1));
    alo1 = (ref_lon - reflon)*radperdeg;
    polei = 1.0 - rsw * cos(alo1);
    polej = 1.0 - hemi*rsw*sin(alo1);
    ala = lat*radperdeg;
    rm = rebydx*cos(ala)*scale_top / (1.0+hemi*sin(ala));
    alo = (lon-reflon)*radperdeg;
    i = polei + rm.*cos(alo);
    j = polej + hemi*rm.*sin(alo);
    
elseif map_proj == 1  % lambert
    if (abs(truelat2) > 90.0)
        truelat2 = truelat1;
    end
    if (abs(truelat1-truelat2) > 0.1)
        cone = (log(cos(truelat1*radperdeg))- ...
            log(cos(truelat2*radperdeg))) / ...
            (log(tan((90.0-abs(truelat1))*radperdeg*0.50))- ...
            log(tan((90.0-abs(truelat2))*radperdeg*0.50)));
    else
        cone = sin(abs(truelat1)*radperdeg);
    end
    
    deltalon1 = ref_lon - stand_lon;
    if (deltalon1 > 180.0)
        deltalon1 = deltalon1 - 360.0;
    end
    if (deltalon1 < -180.0)
        deltalon1 = deltalon1 + 360.0;
    end
    tl1r = truelat1*radperdeg;
    ctl1r = cos(tl1r);
    
    rsw = rebydx*ctl1r/cone* (tan((90.0*hemi-ref_lat)*radperdeg/2.0) / ...
        tan((90.0*hemi-truelat1)*radperdeg/2.0)).^cone;
    
    arg = cone * (deltalon1*radperdeg);
    polei = hemi*1.0 - hemi*rsw.*sin(arg);
    polej = hemi*1.0 + rsw.*cos(arg);
    
    deltalon = lon - stand_lon;
    if (deltalon > 180.0)
        deltalon = deltalon - 360.0;
    end
    if (deltalon < -180.0)
        deltalon = deltalon + 360.0;
    end
    
    rm = rebydx*ctl1r/cone* (tan((90.0*hemi-lat)*radperdeg/2.0)/ ...
        tan((90.0*hemi-truelat1)*radperdeg/2.0)).^cone;
    arg = cone * (deltalon*radperdeg);
    i = polei + hemi*rm.*sin(arg);
    j = polej - rm.*cos(arg);
    
    i = hemi*i;
    j = hemi*j;
else
    error('不支持的投影方式！')
end
if debug > 0
    fprintf('Debugging info as follows:\n')
    fprintf(' map_proj  : %s\n dx        : %s\n dy        : %s\n', map_proj_name, dx_name, dy_name);
    fprintf(' truelat1  : %s\n truelat2  : %s\n stand_lon : %s\n', truelat1_name, truelat2_name, stand_lon_name);
    fprintf(' e_wen     : %s\n e_sn      : %s\n', e_wen_name, e_snn_name);
    fprintf(' map_proj  = %d\n dx        = %f\n dy        = %f\n', map_proj, dx, dy);
    fprintf(' truelat1  = %f\n truelat2  = %f\n stand_lon = %f\n', truelat1, truelat2, stand_lon);
    fprintf(' e_wen     = %f\n e_snn     = %f\n', e_wen, e_snn);
end
i = floor(i+0.5);
j = floor(j+0.5);
ij = [i;j];

end