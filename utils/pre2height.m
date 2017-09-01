function height = pre2height(pressure)
% 计算给定压力层所对应位势高度
%   输入参数：
%        pressure  : 压力层值
%                    类型为： 数值数组
%                    单  位： hPa
%   输出参数：
%        height   ： 位势高度，单位： m
% 如果给定压力层小于54.75 hPa 则返回 NaN
%%
if nargin==1
    if isvector(pressure)
        grearr = pressure > 226.4;
        lesarr = pressure >= 54.75 & pressure<= 226.4;
        nonarr = pressure < 54.75;
        height = zeros(1,length(pressure));
        height(grearr) = 44331*(1-(pressure(grearr)/1013.25).^0.1903);
        height(lesarr) = 11000 + 6340*log(226.4./pressure(lesarr));     
        height(nonarr) = NaN;
    else
        error('Input arguments should be vector!')
    end
else
    error('The number of input arguments is wrong!')
end
end