function wdir = wind_direction(u, v, fillvalue)
%  根据 u, v 计算 wspd, wdir
%  参数声明：
%     输入参数： 
%        u,v    ： 均为风速. 单位 : m/s.
%     fillvalue ： 缺省值设置.  默认为 0.
%                可为 标量 或 NaN
%     输出参数：
%        wdir  ：  风向. 
%  ================================================================
%    date  :  2017.1.8
%    by    :  ly
%    email :  libravo@foxmail.com
%%  参考 NCL 中 wind_direction 函数
% 常数定义
if nargin == 2
    fillvalue = 0;
end
zero = 0;
con = 180.0;
wcrit = 360 - 0.00002;
radi = 1.0/0.01745329;

wdir = atan2(u, v)*radi + con;
wdir(wdir >= wcrit) = zero;  % force 360 "north winds"
wdir(u == 0 & v == 0) = fillvalue; 
end