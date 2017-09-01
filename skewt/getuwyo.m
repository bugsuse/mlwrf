function  getuwyo(year, mo, day, hour, station, filename)
% 从 http://weather.uwyo.edu/upperair/sounding.html  网站
% 获取探空数据
%   参数说明：
%     输入参数：
%        year  ： 年.  标量.
%         mo   ： 月.  标量.
%        day   ： 日.  标量.
%        hour  ： 时.  标量.
%      station ： 站点.  标量.
%     filename ： 输出文件名，如不包括路径则为当前路径.
% ----------------------------------------------------------------------
%    date : 2017.1.9
% modified: 2017.2.13
%     by  :   ly
%   email : libravo@foxmail.com
%% 获取探空数据页
[str,status] = urlread(sprintf('http://www.weather.uwyo.edu/cgi-bin/sounding?region=seasia&TYPE=TEXT%%3ALIST&YEAR=%4d&MONTH=%02d&FROM=%02d%02d&TO=%02d%02d&STNM=%d',...
    year,mo,day,hour,day,hour,station));

if status == 0
    error('Fail to scrapy sounding data!\n str = %s', str);
end
h2ind  = strfind(str, '<H2>');
h3ind  = strfind(str, '<H3>');
preind = strfind(str, '</PRE>');

substr  = regexprep(str(h2ind(1):h3ind(1)-1), '<H2>|</H2>|<H3>|</H3>|<PRE>|</PRE>','');
infostr = regexprep(str(preind(1)-1:preind(2)-1), '<H3>|</H3>|<PRE>|</PRE>','');
% 显示相应探空数据页的参数信息
disp(infostr)
dlmwrite(filename, substr, 'delimiter', '')
end