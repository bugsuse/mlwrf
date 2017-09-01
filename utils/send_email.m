function send_email(address, passwd, rece, varargin)
% 发送e-mail到指定邮箱
% 输入参数：
%      address  :  用于发送邮件的邮箱地址。   类型：string
%      passwd   :  发送邮件的邮箱密码。  类型：string
%      rece     :  接收邮件的邮箱。  类型：string
% 可选输入参数：
%      subject  :  e-mail主题。  类型：string
%                  默认值：  Hello
%      contents :  e-mail内容。  类型：string
%                  默认为From MATLAB on 系统名 platform  
%      attach   :  附件。 默认为空。 类型：struct 或 cell.
%      smtp     :  邮箱smtp服务器设置。 类型： string
%                  默认使用qq邮箱发送邮件，因此smtp服务器设置为 smtp.qq.com
%                  需根据所使用邮箱进行设置，如不知道可查询使用邮箱的信息。    
%   目前已测试了qq（包括foxmail）,126,163,139以及gmail邮箱。
%      example:  smtp = 'smtp.126.com'
%% set input arguments and check validation of all of arguments
p = inputParser;

subjectDefault = 'Hello';
contentsDefault = sprintf('From MATLAB on %s platform.',computer('arch'));
attachDefault = {};
smtpDefault = 'smtp.qq.com';
attachValidFcn = @(x) iscell(x) || isstruct(x);

addRequired(p, 'address', @ischar);
addRequired(p, 'passwd', @ischar);
addRequired(p, 'rece', @ischar);
addParameter(p, 'subject', subjectDefault, @ischar,'PartialMatchPriority', 3);
addParameter(p, 'contents', contentsDefault, @ischar);
addParameter(p, 'attach', attachDefault, attachValidFcn);
addParameter(p, 'smtp', smtpDefault, @ischar, 'PartialMatchPriority',2);

parse(p, address, passwd, rece, varargin{:});
%% assign arguments to variables
mail_attach   = p.Results.attach;

attachCheck = {'.','..'};
setpref('Internet', 'E_mail', p.Results.address);
setpref('Internet', 'SMTP_Server', p.Results.smtp);
setpref('Internet', 'SMTP_Username', p.Results.address);
setpref('Internet', 'SMTP_Password', p.Results.passwd);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class','javax.net.ssl.SSLSocketFactory');
% 改变smtp服务器后，以下语句使用的端口号可能需要改变，具体端口号请查询所使用邮箱
props.setProperty('mail.smtp.socketFactory.port','465'); 

% send email
if isempty(p.Results.attach)
    sendmail(p.Results.rece, p.Results.subject, p.Results.contents);
else
    if isstruct(p.Results.attach)
        mail_attach = struct2cell(mail_attach);
    end
    if size(mail_attach,2) >=2 && (ismember(mail_attach(1,1), attachCheck) || ismember(mail_attach(1,2), attachCheck))
        mail_attach = mail_attach(:,3:end);
    end
    sendmail(p.Results.rece, p.Results.subject, p.Results.contents, mail_attach(1,:));
end

end
