function uv = wind_component(wspd, wdir)
% 根据风速和风向计算x和y方向水平风
%% 参数说明:
%  输入参数:
%   wspd :  风速. 一维向量.  单位: m/s
%   wdir :  风向. 一维向量.  单位: 度. 范围应在 0-360
%  输出参数:
%    uv : x和y 方向水平风大小
%      uv(1, :) 表示 u 分量, 单位: m/s
%      uv(2, :) 表示 v 分量, 单位: m/s
%% 
%    date  :  2017.1.8
%    by    :  ly
%    email :  libravo@foxmail.com
%%

uveps = 1e-5;
uvzero = 0.0;

u = -wspd.*sin(wdir*pi/180);
v = -wspd.*cos(wdir*pi/180);

uv = [u; v];
uv(abs(uv) <= uveps) = uvzero;

end