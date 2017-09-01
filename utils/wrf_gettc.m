function tc = wrf_gettc(filename, staind, endind)
%   计算每个网格对应的温度值
%  输入参数：
%       filename  :  含有绝对路径的文件名。字符串型
%       staind    :  起始点索引。四元素向量。
%                  每一个元素分别为经度，纬度，高度，时间
%       endind    :  终点索引。同 staind
%  输出参数：
%      tc  : 温度。单位：℃
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

T  =  squeeze(ncread(filename, 'T',[lons lats hs ts ], [lonn latn hn tn]));
P  =  squeeze(ncread(filename, 'P',[lons lats hs ts ], [lonn latn hn tn]));
PB =  squeeze(ncread(filename, 'PB',[lons lats hs ts ], [lonn latn hn tn]));

tc = ((P+PB)/100000).^(0.285714).*(T+300)-273.16;

end