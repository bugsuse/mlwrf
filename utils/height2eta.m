function  eta = height2eta(height, ptop)
%  将WRF模式中eta层相应值转换为相对应层的高度值
%   输入参数:
%        height  :  高度值
%                向量或标量
%       ptop  :  模式顶气压值，单位: hPa
%   输出参数:
%        eta  :  相应高度值对应的eta层
%%
pbot = 1013.1;
if isvector(height)
    pre = height2pre(height);
    eta = (pre - ptop)/(pbot - ptop);
else
    error('Input arguments must be vector!')
end
end