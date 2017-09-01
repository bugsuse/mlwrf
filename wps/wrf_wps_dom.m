function [domains, proj, parentd] = wrf_wps_dom(nml)
% 确定WRF模拟区域的各层格点经纬度坐标
% 参数声明：
%   输入参数：
%       nml  :  结构体变量. 包含确定模拟域所需的参数. 见namelist.wps
%   输出参数：
%       domains ： 元胞数组. 每一个元胞为一层的边界点坐标
%                 第一个元胞为D01, 第二个元胞为D02，以此类推
%        proj   ： 结构体. 包含地图投影方式及相应的参数.
%       parentd ： 2 X 2 数组，D01区域边界经纬度坐标.
%                 仅包含两对经纬度坐标，一般用不到.
% ----------------------------------------------------------------------
%  程序由 ncl 中相应程序移植而来
% ----------------------------------------------------------------------
%    date : 2017.1.6
%     by  :   ly
%   email : libravo@foxmail.com
%% 获取 namelist.wps 中设置的参数
max_dom = nml.max_dom;
parent_id = nml.parent_id;
parent_grid_ratio = nml.parent_grid_ratio;
i_parent_start = nml.i_parent_start;
j_parent_start = nml.j_parent_start;
e_we = nml.e_we;
e_sn = nml.e_sn;
map_proj = nml.map_proj;
dx = nml.dx;
dy = nml.dy;
latinc = 0;
loninc = 0;
if map_proj == 6
    latinc = dx;
    loninc = dy;
end
if map_proj == 2 && isfield(nml, 'pole_lat') && ~isempty(nml.pole_lat)
    pole_lat = nml.pole_lat;
    pole_lon = nml.pole_lon;
else
    pole_lat = 90;
    pole_lon = 0;
end
truelat1 = nml.truelat1;
truelat2 = nml.truelat2;
standlon = nml.stand_lon;
ref_lat = nml.ref_lat;
ref_lon = nml.ref_lon;

knowni = e_we(1)/2;
knownj = e_sn(1)/2;

%% 确定模拟区域是否合适
if max_dom > 1
    for i = 2:max_dom
        if i_parent_start(i) < 5
            warning('Western edge of grid must be at least 5 grid points from mother domain!')
        end
        if j_parent_start(i) < 5
            warning('Southern edge of grid must be at least 5 grid points from mother domain!')
        end
        pointwe = (e_we(i) - 1)/parent_grid_ratio(i);
        pointsn = (e_sn(i) - 1)/parent_grid_ratio(i);
        gridwe = e_we(parent_id(i)) - (pointwe + i_parent_start(i));
        gridsn = e_sn(parent_id(i)) - (pointsn + j_parent_start(i));
        if gridwe < 5
            warning('Eastern edge of grid must be at least 5 grid points from mother domain!')
        end
        if gridsn < 5
            warning('Northern edge of grid must be at least 5 grid points from mother domain!')
        end
        % Making sure nested grid is fully contained in mother domain
        gridsizewe = (((e_we(parent_id(i))-4)-i_parent_start(i))*parent_grid_ratio(i))-(parent_grid_ratio(i)-1);
        gridsizesn = (((e_sn(parent_id(i))-4)-j_parent_start(i))*parent_grid_ratio(i))-(parent_grid_ratio(i)-1);
        if gridwe < 5
            warning('Inner nest (domain = %d) is not fully contained in mother nest (domain = %d)!', i+1, parent_id(i))
            error('For the current setup of mother domain = %d, you can only have a nest of size %d X %d.Stopping', ...
                parent_id(i), gridsizewe, gridsizesn);
        end
        if gridsn < 5
            warning('Inner nest (domain = %d) is not fully contained in mother nest (domain = %d)!', i+1, parent_id(i))
            error('For the current setup of mother domain = %d, you can only have a nest of size %d X %d.Stopping', ...
                parent_id(i), gridsizewe, gridsizesn);
        end
        %Making sure the nest ends at a mother grid domain point
        pointwetrunc = floor(pointwe);
        pointsntrunc = floor(pointsn);
        if (pointwe - pointwetrunc) ~= 0
            nest_we_up = (ceil(pointwe)*parent_grid_ratio(i)) + 1;
            nest_we_dn = (floor(pointwe)*parent_grid_ratio(i)) + 1;
            fprintf('Nest does not end on mother grid domain point.\n Try %d or %d.\n', ...
                nest_we_up, nest_we_dn);
        end
        if (pointsn - pointsntrunc) ~= 0
            nest_sn_up = (ceil(pointsn)*parent_grid_ratio(i)) + 1;
            nest_sn_dn = (floor(pointsn)*parent_grid_ratio(i)) + 1;
            fprintf('Nest does not end on mother grid domain point.\n Try %d or %d.\n', ...
                nest_sn_up, nest_sn_dn);
        end
    end
end

if dx < 1e-10 && dy < 1e-10
    dx = 360.0/(e_we(1) - 1);
    dy = 180/(e_sn(1) - 1);
    ref_lat = 0.0;
    ref_lon = 180;
end
%% 确定各模拟域边界线
%  grid_to_plot = 0 => plot using the corner mass grid points
%  grid_to_plot = 1 => plot using the edges of the corner grid cells
grid_to_plot = 0;
domains = cell(1, max_dom);

if grid_to_plot == 0
    adjust_grid = 0.0;
elseif grid_to_plot == 1
    adjust_grid = 0.5;
else
    warning('Invalid value for grid_to_plot = %f.', grid_to_plot)
    adjust_grid = 0.0;
end
xxs = 1.0 - adjust_grid;
yys = 1.0 - adjust_grid;

loc = dijtoll(map_proj, truelat1, truelat2, standlon, ref_lat, ref_lon, ...
    pole_lat, pole_lon, knowni, knownj, dx, dy, latinc, loninc, xxs, yys);
% bpr begin
start_lon = double(loc(1));
start_lat = double(loc(2));
xxe = e_we(1) - 1 + adjust_grid;
yye = e_sn(1) - 1 + adjust_grid;
% bpr end
loc = dijtoll(map_proj, truelat1, truelat2, standlon, ref_lat, ref_lon, ...
    pole_lat, pole_lon, knowni, knownj, dx, dy, latinc, loninc, xxe, yye);
end_lon = double(loc(1));
end_lat = double(loc(2));
parentd = [start_lat, end_lat; start_lon, end_lon];
% get four corners in domain 1, namely, parent domain
domain = get_corners(map_proj, truelat1, truelat2, standlon, ref_lat, ...
    ref_lon, pole_lat,pole_lon, knowni, knownj, dx, dy, latinc, loninc,...
    xxs, yys, xxe, yye, adjust_grid);
domains{1} = double(domain);

%% 确定投影方式
if map_proj == 1  % LambertConformal
    proj.map_proj = 'lambert';
    proj.parall1  = truelat1;
    proj.parall2  = truelat2;
    proj.meridan  = standlon;
elseif map_proj == 2  % Steregraphic
    proj.map_proj   = 'gstereo';
    proj.cenlat = ref_lat;
    proj.cenlon = ref_lon;
elseif map_proj == 3 % Mercator
    proj.map_proj   = 'Mercator';
    proj.cenlat = 0.0;
    proj.cenlon = standlon;
elseif map_proj == 6  %lat-lon
    warning('暂不支持！');
elseif map_proj == 0  % CylindicalEquidistant
    proj.map_proj    = 'eqdcylin';
    proj.gridsf  = 45;
    proj.cenlat  = 0;
    proj.cenlon  = stdlon;
else
    error('Noooooo the projection, map_proj = %d!', map_proj)
end

if max_dom > 1
    for idom = 2: max_dom
        % nest start and end points in large domain space
        if parent_id(idom) == 1
            % corner value
            %BPR BEGIN
            %Due to the alignment of nests we need goffset in order to
            %find the location of (1,1) in the fine domain in coarse domain
            %coordinates
            goffset = 0.5*(1-1.0/parent_grid_ratio(idom));
            i_start = i_parent_start(idom) - goffset;
            j_start = j_parent_start(idom) - goffset;
            % end point
            % change to mass point
            i_end = (e_we(idom) - 2)/(1.0*parent_grid_ratio(idom)) + i_start;
            j_end = (e_sn(idom) - 2)/(1.0*parent_grid_ratio(idom)) + j_start;
            if grid_to_plot == 0
                adjust_grid = 0;
            elseif grid_to_plot == 1
                adjust_grid = vpa(0.5/(1.0*parent_grid_ratio(idom)), 10);
            else
                warning('Invalid value for grid_to_plot = %f.', grid_to_plot)
                adjust_grid = 0.0;
            end
        end
        %%
        if parent_id(idom) >= 2
            nd = idom;
            
            i_points = ((e_we(idom)-2)/(1.0*parent_grid_ratio(idom)));
            j_points = ((e_sn(idom)-2)/(1.0*parent_grid_ratio(idom)));
            goffset = 0.5*(1-(1.0/(1.0*parent_grid_ratio(idom))));
            ai_start = i_parent_start(idom)*1.0-goffset;
            aj_start = j_parent_start(idom)*1.0-goffset;
            
            while nd >= 2
                goffset = 0.5*(1-(1.0/(1.0*parent_grid_ratio(nd-1))));                
                ai_start = (ai_start-1)/(1.0*parent_grid_ratio(nd-1)) + i_parent_start(nd-1)-goffset;
                aj_start = (aj_start-1)/(1.0*parent_grid_ratio(nd-1)) + j_parent_start(nd-1)-goffset;                
                i_points = (i_points/(1.0*parent_grid_ratio(nd-1)));
                j_points = (j_points/(1.0*parent_grid_ratio(nd-1)));
                nd = nd - 1;
            end
            i_start = ai_start;
            j_start = aj_start;
            % end point
            i_end = i_points + i_start;
            j_end = j_points + j_start;
            %BPR END
        end
        % get four corners
        domain = get_corners(map_proj, truelat1, truelat2, standlon, ...
            ref_lat, ref_lon, pole_lat,pole_lon, knowni, knownj, dx, ...
            dy, latinc, loninc, i_start, j_start, i_end, j_end, adjust_grid);
        domains{idom} = double(domain);
    end
end
end

function domain = get_corners(map_proj, truelat1, truelat2, standlon, ...
    ref_lat, ref_lon, pole_lat,pole_lon, knowni, knownj, dx, ...
    dy, latinc, loninc, i_start, j_start, i_end, j_end, adjust_grid)
%% 获取每一模拟域四角经纬度坐标
xx = i_start - adjust_grid;
yy = j_start - adjust_grid;
loc = dijtoll(map_proj, truelat1, truelat2, standlon, ref_lat, ref_lon, pole_lat,...
    pole_lon, knowni, knownj, dx, dy, latinc, loninc, xx, yy);
lon_sw = loc(1);
lat_sw = loc(2);

xx = i_end + adjust_grid;
yy = j_start - adjust_grid;
loc = dijtoll(map_proj, truelat1, truelat2, standlon, ref_lat, ref_lon, pole_lat,...
    pole_lon, knowni, knownj, dx, dy, latinc, loninc, xx, yy);
lon_se = loc(1);
lat_se = loc(2);

xx = i_start - adjust_grid;
yy = j_end + adjust_grid;
loc = dijtoll(map_proj, truelat1, truelat2, standlon, ref_lat, ref_lon, pole_lat,...
    pole_lon, knowni, knownj, dx, dy, latinc, loninc, xx, yy);
lon_nw = loc(1);
lat_nw = loc(2);

xx = i_end + adjust_grid;
yy = j_end + adjust_grid;
loc = dijtoll(map_proj, truelat1, truelat2, standlon, ref_lat, ref_lon, pole_lat,...
    pole_lon, knowni, knownj, dx, dy, latinc, loninc, xx, yy);
lon_ne = loc(1);
lat_ne = loc(2);
domain = [lon_sw lon_nw lon_ne lon_se lon_sw;lat_sw lat_nw lat_ne lat_se lat_sw];
end