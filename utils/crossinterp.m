function [var, varargout] = crossinterp(vard, interptype, varargin)
% 用于对所选WRF模式输出变量进行垂直剖面插值，然后返回插值后的变量用于绘制垂直剖面图
%  理论上适用于对任何三维变量进行插值。插值结果已和NCL所绘制结果对比，基本一致。
%  输入参数：
%          vard : 所选变量，类型为数值型。 维度为三维数组，分别是X方向，Y方向和Z方向
%                  时间维度应在传入时选定。
%    interptype : 指定剖面方式，为字符型变量。
%                'se'  : 表示可以选定起始坐标和终点坐标，用于指定剖面线。
%                    'stapos' : 起始坐标点，二元素向量。分别为x和y的起始点，
%                               第一个值为x的起始点，第二个值为y的起始点。
%                    'endpos' : 终点坐标，二元素向量。分别为x和y的终点，
%                               第一个值为x的终点，第二个值为y的终点。
%                'md'  : 表示可以通过指定中点坐标和倾斜角度选择剖面线。
%                    'midpos' : 中点坐标，二元素向量。
%                               第一个值为x的中点坐标，第二个值为y的中点坐标。
%                    'angle'  : 用于指定倾斜角度，即直线斜率。 默认值为45度。
%                               取值范围应在 -90 到 90 之间。
%                  两种选择剖面线的模式都有一个 step 参数，用于控制插值的间隔。
%                   'step'  :  用于控制插值的间隔，即网格密度。默认值为 1
%                           一般情况下采用默认值即可，当所选的网格数较少时可以
%                           适当减小此值，但应保证大于0，否则会报错。
%                           而且此值越小插值得到的网格越密，绘制的图可能更像pcolor
%                           绘制的图形。如果取值大于1（会引发警告，但不报错），
%                           会导致插值的网格稀疏，所绘制图形可能不容易分辨细微的差别。
%                           因此不建议取值过大，同样不建议取值太小，最佳取值范围在0.5-1
%                           之间。根据具体情况可适当调节。
%  输出变量：
%       var  : 插值后用于绘制垂直剖面图的变量
%     可选输出变量：
%       croline  ： 结构体变量。用于绘制剖面线。
%           x 域存储的是 剖面线的 x轴坐标
%           y 域存储的是 剖面线的 y轴坐标
%%  可不用croline返回的x,y坐标绘制剖面线，直接通过剖面线起止点进行绘制
%   注意： 如果读取所选变量所有维度的全部数据提示数组太大，无法读取的话可读取部分数据
%% 示例
%   [var, croline] = CrossInterp(vard, 'se', 'stapos', [1 81], 'step', 0.8, 'endpos', [85 1]);
%   [var, croline] = CrossInterp(vard, 'md', 'midpos', [40 35], 'angle', -45);
%%
p = inputParser;
validVard = @(x) ndims(x)==3;
validAngle = @(x) isnumeric(x) && x >= -90 && x <= 90;
validValue = @(x) isvector(x) && min(x) >=0 && ~isempty(x);
validStep  = @(x) isnumeric(x) && x>=0;
defaultStep  =  1;   % 默认插值步长
defaultAngle = 45;   % 默认剖面角度
addRequired(p, 'vard', validVard)
addRequired(p, 'interptype', @isstr)
addParameter(p, 'stapos', validValue)
addParameter(p, 'step', defaultStep, validStep)
addParameter(p, 'endpos', validValue)
addParameter(p, 'midpos', validValue)
addParameter(p, 'angle', defaultAngle, validAngle)
parse(p, vard, interptype, varargin{:})
% 错误信息
errstr1 = 'The max value must be lesser than %d.';
errstr2 = [errstr1, 'and the best value range is [%d %d].'];
errstr3 = 'Are you want to test the program? If yes, another way could be a good idea!';
% 获取每一维度的大小
if ndims(vard) == 3
    [xv, yv, zv] = size(vard);
else
    error('The dimensions of the variable is %d!Must be 4D!Please check it!', ndims(vard))
end
step   = p.Results.step;
if  step >1
    warning('The value of input arguments %s is %d and should be lesser than 1!', 'step', step)
end
% 判断选择哪种垂直剖面方式并求出直线方程
if strcmp(p.Results.interptype, 'se')
    stapos = p.Results.stapos;
    endpos = p.Results.endpos;
    if ~islogical(stapos(1)) && ~islogical(endpos(1))
        if stapos(1) > xv || endpos(1) > xv
            error(errstr1, xv)
        elseif stapos(2) > yv || endpos(2) > yv
            error(errstr1, yv)
        end
    elseif ~islogical(p.Results.midpos(1))
        error(errstr3)
    else
        error('Input arguments %s and %s must be vector with two elements!', 'stapos', 'endpos')
    end
    %  计算满足起始和终点坐标的直线方程，通过x轴点求出在直线方程上的y轴的点
    x = stapos(1):step:endpos(1);
    y = ((endpos(2)-stapos(2))/(endpos(1)-stapos(1))).*(x - endpos(1)) + endpos(2);
elseif strcmp(p.Results.interptype, 'md')
    midpos = p.Results.midpos;
    if ~islogical(midpos(1))
        if midpos(1) > xv
            error(errstr2, xv, xv/4, 3*xv/4)
        elseif midpos(2) > yv
            error(errstr2, yv, yv/4, 3*yv/4)
        end
    elseif ~islogical(p.Results.stapos(1)) || ~islogical(p.Results.endpos(1))
        error(errstr3)
    else
        error('Variable %s must be vertor with two elements!', 'midpos')
    end
    angle  = p.Results.angle;
%  求出x轴点满足斜率为 tan(angle)及midpos点坐标的直线上的y轴的点
%  由于选定的中点坐标和直线斜率，因此所得方程计算出的y轴坐标会出现超出范围的
    x = [1:step:midpos(1),midpos(1)+step:step:xv];
    y = tan((angle*3.1415926)/180)*(x - midpos(1)) + midpos(2);
    yind = y >=0 & y <= yv;
    x = x(yind);
    y = y(yind);
end
xl = length(x);
intevar = zeros(xl, xl, zv);
[X, Y] = ndgrid(x,y);
for i = 1:zv
    F = griddedInterpolant(vard(:,:,i), 'nearest');
    intevar(:,:,i)  =  F(X, Y);
end
var = zeros(xl, zv);
% 获取在直线上的每一层高度的点
for i = 1:zv
    var(:,i) = diag(intevar(:,:,i));
end
crossline.x = x;
crossline.y = y;
varargout{1} = crossline;
end