function loc = dijtoll(map_proj, trueref_lat, truelat2, stdlon, ref_lat, ref_lon, pole_lat,...
    pole_lon, knowni, knownj, dx, dy, latinc, loninc, ai, aj)
%  用于转换模拟域坐标点为经纬度坐标
%  参数声明：
%    输入参数：
%      map_proj  ： 投影方式。  单元素数值。 
%     ref_lat    : ref_lat
%     ref_lon    : ref_lon
%       dx       : Grid spacing in meters at truelats
%       stdlon   : Longitude parallel to y-axis (-180->180E)
%      truelat1  : First true latitude (all projections)
%      truelat2  : Second true lat (LC only)
%       hemi     : 1 for NH, -1 for SH
%       cone     : Cone factor for LC projections
%       polei    : Computed i-location of pole point
%       polej    : Computed j-location of pole point
%       knowni   : X-location of known lat/lon
%       knownj   : Y-location of known lat/lon
%       latinc   :  
%       loninc   :
%       pole_lat :
%       pole_lon :
%         ai     ：  模拟域X方向坐标。 单元素数值。
%         aj     ：  模拟域Y方向坐标。 单元素数值。
%    输出参数： 
%       loc  ： 二元素向量。 包含转换后的经纬度坐标。
%%  程序参考 NCL 中转换模拟域坐标为经纬度坐标的源程序
%   date  :  2017.1.6
%     by  :   ly
%   email :  libravo@foxmail.com
%% main program
pi = vpa(3.141592653589793,20);
rad_per_deg = pi/180.0;
deg_per_rad = 180.0/pi;
re_m = 6370000;
rebydx = re_m/dx;

hemi = 1.0;  %  表示北半球
if trueref_lat < 0.0
    hemi = -1.0; % 表示南半球
end

%% mercator
if map_proj == 3
    clain = cos(rad_per_deg*trueref_lat);
    dlon = dx / (re_m*clain);
    
    rsw = 0.0;
    if ref_lat ~= 0.
        rsw = log(tan(0.5*((ref_lat + 90)*rad_per_deg)))/dlon;
    end
    lat = 2.0*atan(exp(dlon*(rsw + aj - knownj))) * deg_per_rad - 90.0;
    lon = (ai - knowni)*dlon*deg_per_rad + ref_lon;
    
    if lon > 180
        lon = lon - 360;
    end
    if lon < -180
        lon = lon + 360;
    end
    
elseif map_proj == 2
    % compute the reference longitude by rotating 90 degrees to the east to
    % find the longitude line parallel to the positive x-axis
    reflon = stdlon + 90;
    scale_top = 1.0 + hemi*sin(trueref_lat * rad_per_deg);
    % compute radius to known point
    ala1 = ref_lat * rad_per_deg;
    rsw = rebydx*cos(alt1)*scale_top/(1.0 + hemi*sin(ala1));
    % find the pole point
    alo1 = (ref_lon - refllon)*rad_per_deg;
    polei = knowni - rsw*cos(alo1);
    polej = knownj - hemi*rsw*sin(alo1);
    % compute radius to point of interest
    xx = ai - polei;
    yy = (aj - polej)*hemi;
    r2 = xx^2 + yy^2;
    
    if r2 == 0
        lat = hemi*90.0;
        lon = reflon;
    else
        gi2 = (rebydx * scale_top)^2;
        lat = deg_per_rad*hemi*asin((gi2 - r2)/(gi2 + r2));
        arccos = acos(xx/sqrt(r2));
        if yy > 0
            lon = reflon + deg_per_rad * arccos;
        else
            lon = reflon - deg_per_rad * arccos;
        end
    end
    % convert to a - 180 -> 180 east convention
    if lon > 180
        lon = lon - 360;
    end
    if lon < -180
        lon = lon + 360;
    end
    
elseif map_proj == 1
    hemi = 1.0;
    if (trueref_lat < 0.0)
        hemi = -1.00;
    end
    
    if (abs(truelat2)>90.0) %
        truelat2 = trueref_lat;
    end
    
    if (abs(trueref_lat-truelat2) > 0.10) %
        cone = (log(cos(trueref_lat*rad_per_deg))- ...
            log(cos(truelat2*rad_per_deg)))/ ...
            (log(tan((90.0-abs(trueref_lat))*rad_per_deg* ...
            0.50))-log(tan((90.0-abs(truelat2))*rad_per_deg* ...
            0.50)));
    else
        cone = sin(abs(trueref_lat)*rad_per_deg);
    end
    
    %   compute longitude differences and ensure we stay out of the
    %   forbidden "cut zone"
    deltaref_lon = ref_lon - stdlon;
    if (deltaref_lon>180.0)
        deltaref_lon = deltaref_lon - 360.0;
    end
    if (deltaref_lon<-180.0)
        deltaref_lon = deltaref_lon + 360.0;
    end
    %   convert trueref_lat to radian and compute cos for later use
    tl1r = trueref_lat*rad_per_deg;
    ctl1r = cos(tl1r);
    
    %   compute the radius to our known point
    rsw = rebydx*ctl1r/cone*(tan((90.0*hemi- ...
        ref_lat)*rad_per_deg/2.0)/tan((90.0*hemi- ...
        trueref_lat)*rad_per_deg/2.0))^cone;
    
    %   find pole point
    alo1 = cone* (deltaref_lon*rad_per_deg);
    polei = hemi*knowni - hemi*rsw*sin(alo1);
    polej = hemi*knownj + rsw*cos(alo1);
    
    chi1 = (90.0-hemi*trueref_lat)*rad_per_deg;
    chi2 = (90.0-hemi*truelat2)*rad_per_deg;
    
    inew = hemi*ai;
    jnew = hemi*aj;
    
    %   compute radius**2 to i/j location
    reflon = stdlon + 90.0;
    xx = inew - polei;
    yy = polej - jnew;
    r2 = (xx*xx+yy*yy);
    r = sqrt(r2)/rebydx;
    
    %  convert to lat/lon
    if (r2 == 0.0) 
        lat = hemi*90.0;
        lon = stdlon;
    else
        lon = stdlon + deg_per_rad*atan2(hemi*xx,yy)/cone;
        lon = mod(lon+360.0,360.0);
        if (chi1 == chi2) 
            chi = 2.00*atan((r/tan(chi1))^(1.0/cone)*  tan(chi1*0.50));
        else
            chi = 2.00*atan((r*cone/sin(chi1))^ (1.0/cone)* tan(chi1*0.50));
        end
        lat = (90.00-chi*deg_per_rad)*hemi;
    end
    
    if (lon > 180.0)
        lon = lon - 360.0;
    end
    if (lon < -180.0)
        lon = lon + 360.0;
    end
    
elseif map_proj == 6
    inew = ai - knowni;
    jnew = aj - knownj;
    
    if inew < 0
        inew = inew + 360/loninc;
    end
    if inew >= 360/dx
        inew = inew - 360/loninc;
    end
    deltalat = jnew*latinc;
    deltalon = inew*loninc;
    
    if pole_lat ~= 90.0
        [olat, olon] = rotatecoords(ref_lat, ref_lon, pole_lat, pole_lon, stdlon, -1);
        ref_latn = olat;
        ref_lonn = olon + stdlon;
        lat = deltalat + ref_latn;
        lon = deltalon + ref_lonn;
    else
        lat = deltalat + ref_lat;
        lon = deltalon + ref_lon;
    end
    
    if pole_lat ~= 90.0
        lon = lon - stdlon;
        [olat, olon] = rotatecoords(lat, lon, pole_lat, pole_lon, stdlon, 1);
        lat = olat;
        lon = olon;
    end
    
    if lon < -180
        lon = lon + 360;
    end
    if lon > 180
        lon = lon - 360;
    end
    
else
    error('Dont know map projection!')
end
loc = [lon , lat];
end

function [olat, olon] = rotatecoords(ilat, ilon, lat_np, lon_np, lon_0, direction)

pi = 3.141592653589793;
rad_per_deg = pi/180.0;
deg_per_rad = 180/pi;

% convert all angles to radians
phi_np = lat_np * rad_per_deg;
lam_np = lon_np * rad_per_deg;
lam_0 = lon_0 * rad_per_deg;
rlat = ilat * rad_per_deg;
rlon = ilon * rad_per_deg;

if direction < 0
    dlam = pi - lam_0;
else
    dlam = lam_np;
end
sinphi = cos(phi_np) * cos(rlat) * cos(rlon - dlam) + sin(phi_np) * sin(rlat);
cosphi = sqrt(1.0 - sinphi*sinphi);
coslam = sin(phi_np) * cos(rlat) * cos(rlon - dlam) - cos(phi_np) * sin(rlat);
sinlam = cos(rlat) * sin(rlon - dlam);

if cosphi ~= 0
    coslam = coslam/ cosphi;
    sinlam = sinlam/ cosphi;
end

olat = deg_per_rad*asin(sinphi);
olon = deg_per_rad(atan2(sinlam, coslam) - dlam - lam_0 + lam_np);
end
