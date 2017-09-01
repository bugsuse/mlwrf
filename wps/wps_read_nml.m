function nml = wps_read_nml(filename)
%  从namelist.wps 中获取参数用于确定各模拟域边界
%  参数声明：
%     输入参数：  
%       filename  ：  字符串。绝对路径下的namelist.wps
%     输出参数：
%          nml  ：  结构体。 包含namelist.wps中用于确定模拟域边界的参数。
%  ------------------------------------------------------------------------
%   date : 2017.1.6
%    by  :  ly
%  email : libravo@foxmail.com
%  ------------------------------------------------------------------------
%%
try
    fid = fopen(filename);
catch
    error('Fail to open the file %s!', filename)
end
while ~feof(fid)
    lines = fgetl(fid);
    if strfind(lines, '=')
        nmlfs = strsplit(strrep(strtrim(lines), '=', ','), ',');
        if isempty(nmlfs{end})
            regin = regexp(nmlfs(2:end-1), '[a-zA-Z-_:]', 'once');
            if isempty(regin{1})
                nml.(strtrim(nmlfs{1})) = str2double(nmlfs(2:end-1));
            else
                nml.(strtrim(nmlfs{1})) = strtrim(strrep(nmlfs(2:end-1), '''',''));
            end
        else
            regin = regexp(nmlfs(2:end), '[a-zA-Z-_:]', 'once');
            if isempty(regin{1})
                nml.(strtrim(nmlfs{1})) = str2double(nmlfs(2:end));
            else
                nml.(strtrim(nmlfs{1})) = strtrim(strrep(nmlfs(2:end), '''',''));
            end
        end
    end
end
fclose(fid);
map_proj = nml.map_proj{1};
if strcmp(map_proj,'lambert')
    nml.map_proj = 1;
elseif strcmp(map_proj, 'mercator')
    nml.map_proj = 3;
elseif strcmp(map_proj, 'pole_lat')
    nml.map_proj = 2;
elseif strcmp(map_proj, 'polar')
    nml.map_proj = 6;
else
    error('No the projection map_proj = %s!', map_proj);
end
end