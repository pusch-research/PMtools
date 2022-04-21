%Demonstratates the features of xmf_export using a simple example
ccc

%% Initiation
% Restet default xmf_paramters
xmf_init('reset');

%% Plot
t = linspace(0,2*pi,100);
plot(t, 10000*sin(t), t, 10000*cos(t))

legend('Sinus', 'Cosinus')
xlabel('Zeit')
ylabel('Funktionswert')
title('Sinus und Cosinus zwischen 0 und 2\cdot\pi')

set(gca,    'xLim',         [0 2*pi], ...
            'xTick',        [0 pi 2*pi])

%% Preparation
xmf_prepare()
        
%% Run matlabfrag
xmf_export(mfilename)

%% eof
