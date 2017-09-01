function skewTlogP_plot(pz, tz, rhz, wdir, wsp, Filter)
% Generate Skew-T Log-P Diagrams through sounding data.
% ======================================================================= %
% Input
%   pz: pressure, hPa
%   tz: Temperature, degC
%   rhz: Relative Humidity, % (0-1).
%   wdir: Wind Direction, deg (0-360)
%   wsp: Wind Speed, m/s
%   Filter: Apply 1-D digital filter to smooth the wind obs., 1 = do;
%       0 = not do, 0 is default. See MATLAB function "filter.m".
% ======================================================================= %
% Note:
%   Range of the plot is [-48 - 50 degC, 1050 - 100 hPa].
%   Function "windbarb_profile.m" is applied here to produce wind profile.
%   ("windbarb_profile.m" is not written by me, but I cannot find the author)
% ======================================================================= %
% The code was modified from program in MIT Open Course Ware(OCW): Tropical
% Meteorology[1].
% ======================================================================= %
% Reference
% [1] http://ocw.mit.edu/courses/earth-atmospheric-and-planetary-sciences/12-811-tropical-meteorology-spring-2011/tools/skewt.m
% External Link
% [1] Sounding Data via U. Wyoming[http://weather.uwyo.edu/upperair/sounding.html]
% [2] Wikipedia, Skew-T log-P diagram[http://en.wikipedia.org/wiki/Skew-T_log-P_diagram]
% ======================================================================= %
%   Yingkai Sha
%       yingkaisha@gmail.com
% 2014/7/26
%   Xiao-yong Zhuge
%       zgxy_nju@126.com
% 2014/7/30 & 2014/8/6
%% 
%   Modified
%   2016/9/21 
%       Yang Li
%       libravo@foxmail.com
% ======================================================================= %
if nargin==5
    Filter=0;
end
%% Initialization
Pressure_Lim=[1050 100];
Temperature_Lim=[-36 46];
synopPress=[100:50:300,400,500,700,850,1000];
synopTemperature=-30:10:40;

% remove data out of the plot
tz(pz<Pressure_Lim(2))=[];
rhz(pz<Pressure_Lim(2))=[];
wdir(pz<Pressure_Lim(2))=[];
wsp(pz<Pressure_Lim(2))=[];
pz(pz<Pressure_Lim(2))=[];
% count the number of element
N=length(pz);
% Calculate Dew-point Temperature
ez=6.112.*exp(17.67.*tz./(243.5+tz));
qz=rhz.*0.622.*ez./(pz-ez);
chi=log(pz.*qz./(6.112.*(0.622+qz)));
tdz=243.5.*chi./(17.67-chi);

% %model:tropical
% atm=[0,1,2,3,4,5,6,7,8.9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,30,35,40,45,50,70,100;...
%     1.013e+03,9.040e+02,8.050e+02,7.150e+02,6.330e+02,5.590e+02,4.920e+02,4.320e+02,3.780e+02,3.290e+02,2.860e+02,2.470e+02,...
%     2.130e+02,1.820e+02,1.560e+02,1.320e+02,1.110e+02,9.370e+01,7.890e+01,6.660e+01,5.650e+01,4.800e+01,4.090e+01,3.500e+01,...
%     3.000e+01,2.570e+01,1.220e+01,6.000e+00,3.050e+00,1.590e+00,8.540e-01,5.790e-02,3.000e-04];

%model:usstandard62
atm=[ 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,30, 35,40,45,50,70,100;...
    1.013e+03,8.986e+02,7.950e+02,7.012e+02,6.166e+02,5.405e+02,4.722e+02,4.111e+02,3.565e+02,3.080e+02,2.650e+02,2.270e+02,...
    1.940e+02,1.658e+02,1.417e+02,1.211e+02,1.035e+02,8.850e+01,7.565e+01,6.467e+01,5.529e+01,4.729e+01,4.047e+01,3.467e+01,...
    2.972e+01,2.549e+01,1.197e+01,5.746e+00,2.871e+00,1.491e+00,7.978e-01,5.520e-02,3.008e-04];

%% Calculate new x(temperature)
tzm=tz-30.*log(pz./Pressure_Lim(1));
tdzm=tdz-30.*log(pz./Pressure_Lim(1));

%% Wind Direction and Speed
% filter wind velocity and direction
if(Filter==1)
    wsp=filter(ones(round(size(wsp, 1)/20), 1)/round(size(wsp, 1)/20), 1, wsp);
    wdir=filter(ones(round(size(wdir, 1)/20), 1)/round(size(wdir, 1)/20), 1, wdir);
    pzf=filter(ones(round(size(pz, 1)/20), 1)/round(size(pz, 1)/20), 1, pz);
    pzff=flipud(pzf(1:round(size(pzf, 1)/20):size(pzf, 1)));
    wspf=wsp(1:round(size(wsp, 1)/20):size(wsp, 1));
    wdirf=wdir(1:round(size(wdir, 1)/20):size(wdir, 1));
else
    if round(N/20)
        ns = round(N/20);
    else
        ns = 1;
    end
    Series=1:round(N/20):N;
    pzff=pz(Series);
    wspf=wsp(Series);
    wdirf=wdir(Series);
end
latx=ones(size(wspf, 1),1);
x_loc=Temperature_Lim(2)+5; % plot the windbarb at x_loc degC on x-axis

%% parcel curve
% startp
[pzmax,pzmaxi]=max(pz);
Pprof(1)=pzmax;Tprof(1)=tz(pzmaxi)-30.*log(pzmax./Pressure_Lim(1));
% Calculate LCL
Zc=1.23*(tz(pzmaxi)-tdz(pzmaxi));Tc=tz(pzmaxi)-0.98*Zc;Pc=pzmax*((Tc+273.15)/(tz(pzmaxi)+273.15))^(1004/287);
temp=Tc;pres=Pc;delp=10;
Pprof(2)=Pc;Tprof(2)=Tc-30.*log(Pc./Pressure_Lim(1));
% Lift a parcel moist adiabatically from LCL to endp.
k=1;
while(pres >= 150 &&Tprof(k+1)>=Temperature_Lim(1))
    temp=temp-100*delp*gammaw(temp,pres-delp/2,100);
    pres=pres-delp;
    Pprof(k+2)=pres;
    Tprof(k+2)=temp-30.*log(pres./Pressure_Lim(1));
    k=k+1;
end

%% Generate Skew-T, Log-P Grid
yyyy=Pressure_Lim(1):-25:Pressure_Lim(2); % Pressure Measurements
xxxx=Temperature_Lim(1):2:Temperature_Lim(2); % Temperature Measurements
ps=length(yyyy);
ts=length(xxxx);
% allocate
temperature_log=zeros([ps ts]);
theta=zeros([ps ts]);theta2=zeros([ps ts]);
qs=zeros([ps ts]);
theta_e=zeros([ps ts]);
for kk=1:ps,
    for jj=1:ts,
        temperature_log(kk, jj)=xxxx(jj)+30.*log(yyyy(kk)./Pressure_Lim(1));
        theta(kk, jj)=(273.15+temperature_log(kk, jj)).*(1000./yyyy(kk)).^0.2859;%K
        es=6.112.*exp(17.67.*temperature_log(kk, jj)./(243.5+temperature_log(kk, jj)));%hpa
        qs(kk, jj)=622.*es./(yyyy(kk)-es);%g/kg
        theta2(kk, jj)=(273.15+temperature_log(kk, jj)).*(1000./yyyy(kk)).^(0.2854.*(1.0-0.00028.*qs(kk, jj)));%K
        theta_e(kk, jj)=theta2(kk, jj).*exp((3.376./(temperature_log(kk, jj)+273.15)-0.00254).*qs(kk, jj).*(1.0+0.00081*qs(kk, jj)));
    end
end
%% Plot Skew-T
LineColor=[
    0.85 0.85 0.85 % temperature
    0.75 0.55 0.55 % Dry Adiabate Line
    0.75 0.75 0.35 % Constant Mixing Ratio Line
    0.20 0.60 0.60]; % Moist Adiabate Line
isotherm= -100:10:50;
Nisotherm=length(isotherm);
colortable=repmat([LineColor(1, :);1,1,1],Nisotherm/2,1);

hold on
contourf(xxxx, yyyy, temperature_log, isotherm, 'LineStyle', '-', 'LineWidth', 0.5, 'Color', LineColor(1, :));% temperature
colormap(colortable);caxis([isotherm(1),isotherm(end)]);
contour(xxxx, yyyy, theta-273.15, -50:10:200, 'LineStyle', '-', 'LineWidth', 0.5, 'Color', LineColor(2, :)); % Dry Adiabate Line
contour(xxxx, yyyy(1:27), qs(1:27,:), [0.5 1 2 3 4 6 8 10 15 20 25 30 40], 'LineStyle', '-', 'LineWidth', 0.5, 'Color', LineColor(3, :)); % Constant Mixing Ratio Line
contour(xxxx, yyyy(1:34), theta_e(1:34,:)-273.15, -20:10:130, 'LineStyle', '-', 'LineWidth', 0.5, 'Color', LineColor(4, :)); % Moist Adiabate Line
mrx=[-24 -16 -7 -2 3 8 12 17 22 26 30 33 38];mry=yyyy(1)+55;mrv=[0.5 1 2 3 4 6 8 10 15 20 25 30 40];
thetx=[-35:5:15,20:6:40];thety=105;thetv=50:10:180;
for ii=1:14
    text(thetx(ii),thety,num2str(thetv(ii)),'color', LineColor(2, :),'FontWeight', 'bold','FontSize', 10);
end
for ii=1:13
    text(mrx(ii),mry,num2str(mrv(ii)),'color', LineColor(3, :),'FontSize', 9,'rotation',45,'HorizontalAlignment','right','VerticalAlignment','bottom');
end
theex=[-38,-32,-25,-18,-12,-5,0,5,10,15,20,25];theey=yyyy(34)-10;theev=20:10:130;
for ii=1:12
    text(theex(ii),theey,num2str(theev(ii)),'color', LineColor(4, :),'FontWeight', 'bold','FontSize', 10);
end
% ygrid
for kk=2:length(synopPress)
    line(Temperature_Lim,[synopPress(kk),synopPress(kk)], 'LineStyle', '-', 'LineWidth', 0.5, 'Color', [0.7,0.7,0.7]);
end
Handle(1)=plot(tzm, pz);
Handle(2)=plot(tdzm, pz);
Handle(3)=plot(Tprof,Pprof);
Handle_line(1)=line([Temperature_Lim(2) Temperature_Lim(2)], [Pressure_Lim(2) Pressure_Lim(1)]);
Handle_line(2)=line([x_loc x_loc], [Pressure_Lim(2) Pressure_Lim(1)]);
Handle_line(3)=line(Temperature_Lim,[Pressure_Lim(2),Pressure_Lim(2)]);
Handle_line(4)=plot(x_loc.*ones(size(pzff)), pzff);
% Wind Profile
for kk=1:length(wspf)
    windbarb_profile(latx(kk)*x_loc, pzff(kk), wspf(kk), wdirf(kk), 0.03, 1.0, 'k');
end
hold off
% %% Legend
% LHandle=legend([Handle(1) Handle(2) Handle(3)],...
%     'Temperature Obs.', 'Dew-point Obs.','');
% set(LHandle, 'Location', 'NorthEast', 'LineWidth', EdgeWidth, 'FontSize', 10)
%% Handles & Options
axis([Temperature_Lim(1) Temperature_Lim(2)+10 Pressure_Lim(2) Pressure_Lim(1)]); box off;
set(gca, 'YScale', 'log', 'YDir', 'reverse','YTick', synopPress, 'YGrid', 'off', ...
    'xtick',synopTemperature,'tickdir','out');
set(Handle(1), 'LineWidth', 2.5, 'Color', 'k', 'LineStyle', '-')
set(Handle(2), 'LineWidth', 2.5, 'Color',[0.2,0.2,0.8], 'LineStyle', '-')
set(Handle(3), 'LineWidth', 2.5, 'Color','r', 'LineStyle', '--')
set(Handle_line(1), 'LineWidth', 1.5, 'Color', 'k')
set(Handle_line(2), 'LineWidth', 0.5, 'Color', [0.5 0.5 0.5], 'LineStyle', '-')
set(Handle_line(3), 'LineWidth', 3, 'Color', 'k')
set(Handle_line(4), 'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', 3,...
    'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k')

title({'\bf\fontsize{12}Skew-T / log-P Diagram',...
    ['\color{magenta}\fontsize{10}Plcl=',num2str(round(Pc),'%d'),'hPa  ', ...
    '\color{magenta}\fontsize{10}Tlcl=',num2str(round(Tc),'%d'),'^\circC']})
xlabel('Temperature ( ^\circC )', 'FontWeight', 'bold')
ylabel('Pressure ( hPa )', 'FontWeight', 'bold')
% Altitude scale on the left
axesPosition=get(gca, 'Position');
hNewAxes=axes('Position', axesPosition, 'Color', 'none',...
    'YLim', [-log(Pressure_Lim(1)) -log(Pressure_Lim(2))],...
    'ytick',-log(atm(2,:)),'yticklabel',atm(1,:),'YAxisLocation', 'right',...
    'XTick', [], 'Box', 'off', 'FontWeight', 'bold',...
    'FontSize', 8, 'LineWidth', 1.5);
ylabel(hNewAxes, 'Altitude ( km )', 'FontWeight', 'bold');


%% calculate the moist adiabatic lapse rate (deg C/Pa)
    function lapse=gammaw(tempc,pres,rh)
        
        es0=6.112.*exp(17.67.*tempc./(243.5+tempc));
        ws=0.622*es0/(pres-es0);%g/g
        w=rh*ws/100;%w=ws£¬when rh=100;
        latent=(2502.2-2.43089*tempc)*1000;
        
        tempk=tempc+273.15;
        tempv=tempk*(1.0+0.6*w);
        
        A=1.0+latent*ws/(287*tempk);
        B=1.0+0.622*latent*latent*ws/(1005*287*tempk*tempk);% code in grads with coef 0.622 because Rd=0.622Rv
        Density=100*pres/(287*tempv);
        lapse=(A/B)/(1005*Density);
    end

end