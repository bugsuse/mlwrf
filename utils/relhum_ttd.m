function rh = relhum_ttd(tk, td)
%  根据温度和露点温度计算相对湿度
%   参数声明：
%     输入参数：
%        tk  ：  温度.  单位： K
%        td  ：  露点温度.  单位： K
%     输出参数 ：
%        rh  ： 相对湿度. 介于[0 1]
%  ================================================================
%    date  :  2017.1.8
%    by    :  ly
%    email :  libravo@foxmail.com
%%  参考 NCL 中 rhlhum_ttd 函数
gc = 461.5; % J/{kg-k}  gas constant water vapor
gc = gc/(1000*4.186);
lhv = vpa((597.3 - 0.57*(tk - 273))); % latent heat vap

rh = exp( (lhv/gc).*(1.0./tk - 1.0./td) );
end