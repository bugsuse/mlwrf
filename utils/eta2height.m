function  height = eta2height(eta, ptop)
%  将WRF模式中eta层相应值转换为相对应层的高度值
%   输入参数:
%        eta  :  对应的 eta 层值
%                向量或标量
%       ptop  :  模式顶气压值，单位: hPa
%   输出参数:
%       height :  eta 层对应的高度值
%%
pbot = 1013.1;
if isvector(eta)
    p = eta.*(pbot - ptop) + ptop;
    height = pre2height(p);
else
    error('Input arguments must be vector!')
end
end