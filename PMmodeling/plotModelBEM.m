function plotModelBEM(modelBEM)


struct2ws(modelBEM);




%% plot cp surface 1
figure('name','cp surface','numbertitle','off')
contourf(CpCtCq.BldPitch, CpCtCq.TSR, CpCtCq.Cp,15);
hold on;
plot(BldPitch_opt_deg, TSR_opt, 'rx'); % Max point
hLine=plot(BldPitch_deg_arr,TSR_arr,'r-','LineWidth',3);
xlabel('blade pitch [deg]');
ylabel('tip speed ratio [-]');
title('cp surface')
legend(hLine,'steady state operation','Location','north')
xlim([min(CpCtCq.BldPitch) max(BldPitch_deg_arr)])
grid on
garyfyFigure
set(gcf,'Position',[680  730  301  248])

%% plot ct surface 1
figure('name','ct surface','numbertitle','off')
contourf(CpCtCq.BldPitch, CpCtCq.TSR, CpCtCq.Ct,15);
hold on;
plot(BldPitch_opt_deg, TSR_opt, 'rx'); % Max point
plot(BldPitch_deg_arr,TSR_arr,'r-','LineWidth',3)
xlabel('blade pitch [deg]');
ylabel('tip speed ratio [-]');
title('ct surface')
xlim([min(CpCtCq.BldPitch) max(BldPitch_deg_arr)])
grid on
garyfyFigure
set(gcf,'Position',[680  730  301  248])



%% plot cq surface 1
figure('name','cq surface','numbertitle','off')
contourf(CpCtCq.BldPitch, CpCtCq.TSR, CpCtCq.Cq,15);
hold on;
plot(BldPitch_opt_deg, TSR_opt, 'rx'); % Max point
plot(BldPitch_deg_arr,TSR_arr,'r-','LineWidth',3)
xlabel('blade pitch [deg]');
ylabel('tip speed ratio [-]');
title('cq surface')
xlim([min(CpCtCq.BldPitch) max(BldPitch_deg_arr)])
grid on
garyfyFigure
set(gcf,'Position',[680  730  301  248])


%% pitch schedule
figure('Name','bladePitchSchedule')

plot(v_mDs_arr,BldPitch_deg_arr);
grid on
xlabel('wind speed (m/s)')
ylabel('BldPitch (deg)')
title('BldPitch schedule')
garyfyFigure
xlim(minmax(v_mDs_arr))
set(gcf,'Position',[680  797  267  181])
% set(legend,'Position',[0.59922     0.35731     0.33708     0.23481])



%% GenTq schedule
figure('Name','GenTqSchedule')

plot(v_mDs_arr,GenTq_Nm_arr);
grid on
xlabel('wind speed (m/s)')
ylabel('GenTq (Nm)')
title('GenTq schedule')
garyfyFigure
xlim(minmax(v_mDs_arr))
set(gcf,'Position',[680  797  267  181])
% set(legend,'Position',[0.59922     0.35731     0.33708     0.23481])
return


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



