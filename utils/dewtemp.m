function td = dewtemp(t, rh)
% 通过温度及相对湿度计算露点温度
% 参数声明：
%   输入参数：
%      t  ： 温度.  标量或向量. 单位： 摄氏度
%      rh ： 相对湿度. 标量或向量. 无单位,介于[0 100]之间
%   输出参数：
%      td ： 露点温度. 维度与 t 和 rh 一致. 单位： 同 t
%% 函数参考 NCL 内置函数 dewtemp_trh 
%%
% 常数声明
t00 = 273.15;
gc = 461.5;
gcx = gc/(1000*4.186);

tk = t + t00;
lhv = (597.3 - 0.57*(tk - 273))/gcx;
tdk = vpa(tk.*lhv./(lhv-tk.*log(rh*0.01)));
td = tdk - t00;
end