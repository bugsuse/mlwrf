function loc = dlltoij(map_proj, truelat1, truelat2, stdlon, lat1, lon1, pole_lat,...
    pole_lon, knowni, knownj, dx, dy, latinc, loninc, lat, lon)

%      lat1     ! sw latitude (1,1) in degrees (-90->90n)
%      lon1     ! sw longitude (1,1) in degrees (-180->180e)
%      dx       ! grid spacing in meters at truelats
%      dlat     ! lat increment for lat/lon grids
%      dlon     ! lon increment for lat/lon grids
%      stdlon   ! longitude parallel to y-axis (-180->180e)
%      truelat1 ! first true latitude (all projections)
%      truelat2 ! second true lat (lc only)
%      hemi     ! 1 for nh, -1 for sh
%      cone     ! cone factor for lc projections
%      polei    ! computed i-location of pole point
%      polej    ! computed j-location of pole point
%      rsw      ! computed radius to sw corner
%      knowni   ! x-location of known lat/lon
%      knownj   ! y-location of known lat/lon
%      re_m     ! radius of spherical earth, meters
%      rebydx   ! earth radius divided by dx
%%
pi = vpa(3.141592653589793, 20);
rad_per_deg = vpa(pi/180.0) ;
deg_per_rad = vpa(180.0/pi) ;
% radius of spherical earth, meters
re_m = 6370000.;
rebydx = re_m/dx;

hemi = 1.0;
if (truelat1 < 0)
    hemi = -1.0;
end

%      !mercator
if (map_proj == 3)
    %         !  preliminary variables
    clain = cos(rad_per_deg*truelat1);
    dlon = dx/ (re_m*clain);
    
    %         ! compute distance from equator to origin, and store in
    %         ! the rsw tag.
    rsw = 0.0;
    if (lat1 ~= 0.)
        rsw = (log(tan(0.5* ((lat1+90.)*rad_per_deg))))/dlon;
    end
    
    deltalon = lon - lon1;
    if (deltalon < -180.0)
        deltalon = deltalon + 360.;
    end
    if (deltalon > 180.0)
        deltalon = deltalon - 360.;
    end
    i = knowni + (deltalon/ (dlon*deg_per_rad));
    j = knownj + (log(tan(0.5* ((lat+90.0)*rad_per_deg))))/dlon - rsw;
    
elseif (map_proj == 2)
    reflon = stdlon + 90.;
    %         ! compute numerator term of map scale factor
    scale_top = 1. + hemi*sin(truelat1*rad_per_deg);
    %         ! compute radius to lower-left (sw) corner
    ala1 = lat1*rad_per_deg;
    rsw = rebydx*cos(ala1)*scale_top/ (1.0+hemi*sin(ala1));   
    %         ! find the pole point
    alo1 = (lon1-reflon)*rad_per_deg;
    polei = knowni - rsw*cos(alo1);
    polej = knownj - hemi*rsw*sin(alo1);   
    %         ! find radius to desired point
    ala = lat*rad_per_deg;
    rm = rebydx*cos(ala)*scale_top/ (1.0+hemi*sin(ala));
    alo = (lon-reflon)*rad_per_deg;
    i = polei + rm*cos(alo);
    j = polej + hemi*rm*sin(alo);
    %      !lambert
elseif (map_proj == 1)
    if (abs(truelat2) > 90.)
        truelat2 = truelat1;
    end
    
    if (abs(truelat1-truelat2) > 0.1)
        cone = (log(cos(truelat1*rad_per_deg))- ...
            log(cos(truelat2*rad_per_deg)))/ ...
            (log(tan((90-abs(truelat1))*rad_per_deg* ...
            0.5))-log(tan((90-abs(truelat2))*rad_per_deg* ...
            0.5)));
    else
        cone = sin(abs(truelat1)*rad_per_deg);
    end    
    %         ! compute longitude differences and ensure we stay
    %         ! out of the forbidden "cut zone"
    deltalon1 = lon1 - stdlon;
    if (deltalon1 > 180.)
        deltalon1 = deltalon1 - 360.;
    end
    if (deltalon1 < -180.)
        deltalon1 = deltalon1 + 360.;
    end   
    %         ! convert truelat1 to radian and compute cos for later use
    tl1r = truelat1*rad_per_deg;
    ctl1r = cos(tl1r);   
    %         ! compute the radius to our known lower-left (sw) corner
    rsw = rebydx*ctl1r/cone* (tan((90.0 *hemi- ...
        lat1)*rad_per_deg/2)/tan((90.0 *hemi- ...
        truelat1)*rad_per_deg/2))^cone; 
    %         ! find pole point
    arg = cone* (deltalon1*rad_per_deg);
    polei = hemi*knowni - hemi*rsw*sin(arg);
    polej = hemi*knownj + rsw*cos(arg);
    %         ! compute deltalon between known longitude and standard
    %         ! lon and ensure it is not in the cut zone
    deltalon = lon - stdlon;
    if (deltalon > 180.)
        deltalon = deltalon - 360.;
    end
    if (deltalon < -180.)
        deltalon = deltalon + 360.;
    end  
    %         ! radius to desired point
    rm = rebydx*ctl1r/cone* (tan((90.0*hemi- ...
        lat)*rad_per_deg/2)/tan((90.0*hemi- ...
        truelat1)*rad_per_deg/2))^cone;
    
    arg = cone* (deltalon*rad_per_deg);
    i = polei + hemi*rm*sin(arg);
    j = polej - rm*cos(arg);    
    %         ! finally, if we are in the southern hemisphere, flip the
    %         ! i/j values to a coordinate system where (1,1) is the sw
    %         ! corner (what we assume) which is different than the
    %         ! original ncep algorithms which used the ne corner as
    %         ! the origin in the southern hemisphere (left-hand vs.
    %         ! right-hand coordinate?)
    i = hemi*i;
    j = hemi*j;
    
    %     !lat-lon
elseif (map_proj == 6)
    
    if (pole_lat ~= 90.0)
        [olat, olon] =  rotatecoords(lat,lon,pole_lat,pole_lon,stdlon,-1);
        lat = olat;
        lon = olon + stdlon;
    end
    
    %         ! make sure center lat/lon is good
    if (pole_lat ~= 90.0)
        [olat, olon] = rotatecoords(lat1,lon1,pole_lat,pole_lon,stdlon,-1);
        lat1n = olat;
        lon1n = olon + stdlon;
        deltalat = lat - lat1n;
        deltalon = lon - lon1n;
    else
        deltalat = lat - lat1;
        deltalon = lon - lon1;
    end
    %         ! compute i/j
    i = deltalon/loninc;
    j = deltalat/latinc;
    
    i = i + knowni;
    j = j + knownj;
    
else
    error('error: do not know map projection');
    
end

loc(1) = i;
loc(2) = j;
end