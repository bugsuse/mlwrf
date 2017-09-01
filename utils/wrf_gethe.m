function height = wrf_gethe(filename, staind, endind)
%   计算每个网格对应的高度
%  输入参数：
%       filename  :  含有绝对路径的文件名。字符串型
%       staind    :  起始点索引。四元素向量。
%                  每一个元素分别为经度，纬度，高度，时间
%       endind    :  终点索引。同 staind
%  输出参数：
%      height  : 高度。 单位：m
%%
%  Date : 16.11.3
%%
ts    = staind(4);
hs    = staind(3);
lats  = staind(2);
lons  = staind(1);
tn    = endind(4) - ts + 1;
hn    = endind(3) - hs + 1;
latn  = endind(2) - lats;
lonn  = endind(1) - lons;

PH  =  squeeze(ncread(filename, 'PH',[lons lats hs ts ], [lonn latn hn tn]));
PHB =  squeeze(ncread(filename, 'PHB',[lons lats hs ts ], [lonn latn hn tn]));
PH  =  PH + PHB;

dims = size(PH);
dimh = dims(3);
PH  = 0.5*(PH(:,:,1:dimh-1) + PH(:,:,2:dimh)); % unstagger
height = PH/9.81 ;  % height (m)

end