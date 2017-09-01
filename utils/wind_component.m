function uv = wind_component(wspd, wdir)
% 由 风向和风速 计算 u, v
% 参数声明：
%    输入参数： 
%        wspd  ：  风速.  单位： m/s
%        wdir  ：  风向.  单位： °
%    输出参数：
%        uv  ： 包含 u , v.  单位： m/s
%  =========================================================
%    date  :  2017.1.8
%    by    :  ly
%    email :  libravo@foxmail.com
%%  参考 NCL 中 wind_component  函数

rad = vpa(0.17452925199433);
uvmsg = 1e20;
uveps = 1e-5;
uvzero = 0.0;

u = -wspd*sin(wdir*rad);
v = -wspd*cos(wdir*rad);

uv = [u;v];
uv(uv <= uveps) = uvzero;

end