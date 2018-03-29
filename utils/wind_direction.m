function wdir = wind_direction(u, v, fillvalue)
%  根据 u, v 分量计算风向
%% 参数说明:
%    输入参数:
%      u  :  风速u分量. 一维数值向量.  单位: m/s
%      v  :  风速v分量. 一维数值向量.  单位: m/s
%         u 和 v向量大小相同.
%   fillvalue : 用于填充无效值. 标量. 
%     输出参数:
%        wdir : 风向.  一维向量. 大小和 u, v 大小相同. 单位: 度. 正北方向为0度. 
%% 
%    date  :  2017.1.8
%    by    :  ly
%    email :  libravo@foxmail.com
%%

if nargin == 2
    fillvalue = 0;
end

zero = 0;
con = 180.0;
wcrit = 360 - 0.00002;
radi = 1.0/0.01745329;

wdir = atan2(u, v)*radi + con;
wdir(wdir >= wcrit) = zero;  % 强制大于 360 的为正北方向
wdir(u == 0 & v == 0) = fillvalue; 
end