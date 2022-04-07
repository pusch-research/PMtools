function plotSimpleModel(simpleModel)


struct2ws(simpleModel);

%% Aomega
figure('name','Aomega','numbertitle','off')
plot(v_mDs_arr,A)
xlim(minmax(v_mDs_arr(1:end)'));
xlabel('wind speed [m/s]');
% ylabel('A_\omega');
legend('$A_\omega=\frac{1}{J_r} \frac{\partial\tau_a}{\partial\omega_g}$','Interpreter','latex',...
       'Location','southwest')
grid on
garyfyFigure
set(gcf,'Position',[680  833  238  145])

%% BvBbeta
figure('name','BvBbeta','numbertitle','off')
plot(v_mDs_arr,-B_v./B_beta)
xlim(minmax(v_mDs_arr(2:end)'));
xlabel('wind speed [m/s]');
% ylabel('-B_v / B_\beta');
% title('- B_v / B_\beta');
hL=legend('$-\frac{B_{\omega,v}}{B_{\omega,\beta}}$','Interpreter','latex');
hL.FontSize=16;
grid on
garyfyFigure
set(gcf,'Position',[680  829  210  149])



%% plot cp surface 1
figure('name','cp surface','numbertitle','off')
contourf(CpCtCq.BldPitch, CpCtCq.RtTSR, CpCtCq.Cp,15);
hold on;
plot(BldPitch_opt_deg, TSR_opt, 'rx'); % Max point
hLine=plot(BldPitch_deg_arr,TSR_arr,'r-','LineWidth',3);
xlabel('blade pitch [deg]');
ylabel('tip speed ratio [-]');
title('cp surface')
legend(hLine,'steady state operation','Location','north')
% xlim([-1 23])
grid on
garyfyFigure
set(gcf,'Position',[680  730  301  248])

%% plot ct surface 1
figure('name','ct surface','numbertitle','off')
contourf(CpCtCq.BldPitch, CpCtCq.RtTSR, CpCtCq.Ct,15);
hold on;
plot(BldPitch_opt_deg, TSR_opt, 'rx'); % Max point
plot(BldPitch_deg_arr,TSR_arr,'r-','LineWidth',3)
xlabel('blade pitch [deg]');
ylabel('tip speed ratio [-]');
title('ct surface')
% xlim([-1 23])
grid on
garyfyFigure
set(gcf,'Position',[680  730  301  248])



%% pitch schedule
figure('Name','bladePitchSchedule')

plot([0;v_mDs_arr],[BldPitch_deg_arr(1);BldPitch_deg_arr]);
grid on
xlabel('wind speed (m/s)')
ylabel('blade pitch schedule')
title('blade pitch schedule')
garyfyFigure
xlim([0 v_mDs_arr(end)])
set(gcf,'Position',[680  797  267  181])
% set(legend,'Position',[0.59922     0.35731     0.33708     0.23481])

%% pitch schedule derivative
figure('Name','bladePitchSchedule derivative')

plot([0;v_mDs_arr(1);v_mDs_arr(1:end-1)],[0;0;diff(BldPitch_deg_arr)./diff(v_mDs_arr)]);
grid on
xlabel('wind speed (m/s)')
% ylabel('blade pitch schedule')
% title('blade pitch schedule')
xlim([0 v_mDs_arr(end)])
garyfyFigure
% xlim(minmax(specs.refSchedule.windSpeed))
hL=legend('$\frac{\partial\beta}{\partial V}$','Interpreter','latex');
hL.FontSize=16;
set(gcf,'Position',[680  797  267  181])
% set(legend,'Position',[0.59922     0.35731     0.33708     0.23481])



%% plot cp surface 2 (lower & upper)
figure('name','cp surface','numbertitle','off')
contourf(CpCtCq.BldPitch, CpCtCq.RtTSR, CpCtCq.Cp,15);
hold on;
plot(BldPitch_opt_deg, TSR_opt, '+'); % Max point
plot(BldPitch_deg_arr,TSR_arr,'r.-','MarkerSize',6)
plot(BldPitch_upper_deg_arr,TSR_upper_arr,'r.-','MarkerSize',6)
plot(BldPitch_lower_deg_arr,TSR_lower_arr,'r.-','MarkerSize',6)
xlabel('blade pitch [deg]');
ylabel('tip speed ratio [-]');
title('cp surface')




%% plot ct surface 2 (lower & upper)
figure('name','ct surface','numbertitle','off')
contourf(CpCtCq.BldPitch, CpCtCq.RtTSR, CpCtCq.Ct,15);
hold on;
plot(BldPitch_opt_deg, TSR_opt, '+'); % Max point
plot(BldPitch_deg_arr,TSR_arr,'r.-','MarkerSize',6)
plot(BldPitch_upper_deg_arr,TSR_upper_arr,'r.-','MarkerSize',6)
plot(BldPitch_lower_deg_arr,TSR_lower_arr,'r.-','MarkerSize',6)
xlabel('blade pitch [deg]');
ylabel('tip speed ratio [-]');
title('ct surface')



