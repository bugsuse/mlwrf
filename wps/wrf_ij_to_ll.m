function ll = wrf_ij_to_ll(filename, i, j, varargin)
% 转换指定经纬度点坐标为模拟域中的对应坐标点。
% 参数声明：
%   输入参数：
%      filename : 输入文件名
%         i     : 指定经向模拟域格点坐标。单元素数值。
%         j     : 指定纬向模拟域格点坐标。单元素数值。
%     可选参数：
%       debug   :  debugging 信息， 单元素数值。默认为0.
%       如果对应的参数名不一致，则表明WRF输出结果的属性名称顺序出现更改，
%       使用ncinfo查看数据属性并更改程序内相应变量顺序。
%   输出参数：
%      ll    : 转换后的经纬度坐标。
%%  计算方法取自：https://github.com/cwebster2/pyMeteo 中wrf模块 
%    ll_to_ij 方法反推而来，仅测试了 map_proj = 1时的情况，其余情况未测试     
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
    error('可选参数输入错误！')
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

if i > e_wen
    error('The total number of eastern grid points must be lesser than %d!', e_wen)
elseif i <=0 
    error('The total number of eastern grid points must be larger than %d!', 0)
end
if j > e_snn
    error('The total number of southern grid points must be lesser than %d!', e_snn)
elseif j <= 0
    error('The total number of eastern grid points must be larger than %d!', 0)
end
% 读取 LAT 和  LONG 
ref_lat = ncread(filename, 'XLAT', [1, 1, 1], [1, 1, 1]);
ref_lon = ncread(filename, 'XLONG', [1, 1, 1], [1, 1, 1]);

re = 6.37e6;
pi = 3.141592653589793;
rebydx = re / dx;
radperdeg = pi/180.0;
degperrad = 180.0/pi;
hemi = 1.0;

if truelat1 < 0.0
    hemi = -1.0;
end

if map_proj == 3
    clain = cos(radperdeg * truelat1);
    dlon  = dx / ( re * clain);
    rsw = 0.0;
    if ref_lat ~= 0
        rsw = log(tan(0.5*((ref_lat + 90.0)* radperdeg))) / dlon;
    end
    deltalon = i * dlon * degperrad;
    if deltalon < 180
        deltalon = deltatlon -360;
    elseif deltalon > -180
        deltalon = deltalon + 360;
    end
    lat = atan(exp((j + rsw)*dlon))*2/radperdeg - 90;
    lon = deltalon + ref_lon;
    
elseif map_proj == 2
    reflon = stand_lon + 90.0;
    scale_top = 1.0 + hemi*sin(truelat1*radperdeg);
    ala1 = ref_lat*radperdeg;
    rsw = rebydx*cos(ala1)*scale_top/(1.0+hemi*sin(ala1));
    alo1 = (ref_lon - reflon)*radperdeg;
    polei = 1.0 - rsw * cos(alo1);
    polej = 1.0 - hemi*rsw*sin(alo1);
    alo = atan((j - polej)/hemi/(i - polei));
    rm = (i - polei)./cos(alo);
    lon = alo/radperdeg + reflon;
    syms ala;
    eqn = rebydx*cos(ala)*scale_top / (1.0 + hemi*sin(ala)) == rm;
    alax = solve(eqn, ala);
    lat = double(alax/radperdeg);
elseif map_proj == 1
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
    syms arg rm
    ar = solve([polei + hemi*rm.*sin(arg) == i, polej - rm.*cos(arg) == j], [arg, rm]);
    arg = double(ar.arg(ar.arg>=0));
    rm  = double(ar.rm(ar.rm>=0)); 
    deltalon = arg/cone/radperdeg;
    lat = 90.0*hemi - atan(exp(log((rm/(rebydx*ctl1r/cone)))/cone)*tan((90.0*hemi - truelat1)*...
        radperdeg/2.0))*2/radperdeg;       
    if deltalon < -180 && deltalon > 180
        warning('No idea!')
    end
    lon = deltalon + stand_lon;
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
ll = [lon; lat];
end