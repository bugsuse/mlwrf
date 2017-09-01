function pressure = height2pre(height)
% 计算给定位势高度所对应的压力
%   输入参数：
%        height   ： 位势高度，单位： m
%   输出参数：
%        pressure  : 压力层值
%                    类型为： 数值数组
%                    单  位： hPa
%  如果给定位势高度超过 20km 则返回 NaN
%%
if nargin==1
    if isvector(height)
        grearr = height < 11000;
        lesarr = height <= 20000 & height>= 11000;
        nonarr = height > 20000;
        pressure = zeros(1,length(height));
        pressure(grearr) = exp((log(1-height(grearr)/44331))/0.1903)*1013.25;
        pressure(lesarr) = 226.4./exp((height(lesarr)-11000)/6340);     
        pressure(nonarr) = NaN;
    else
        error('Input arguments should be vector!')
    end
else
    error('The number of input arguments is wrong!')
end
end