%Demonstratates the figure size and subplot positioning features of xmf_export
ccc

%% Initiation
% Reste xmf_paramters
xmf_init('reset');

% Figure Poroperties
xmf_init('height', 12, 'width', 12);
xmf_init('leftmargin', 1.2, 'rightmargin', 0.3, 'bottommargin', 1.1, 'topmargin', .8);
xmf_init('hspace', 2, 'vspace', 2.5);
xmf_init('xlabelspace', .7, 'ylabelspace', .7, 'titlespace', .2);
xmf_init('fontsize', 12);

% Matlab visualisation
xmf_init('interpreter', 'latex') 

%% Plot
    %% Create Figure
    xmf_figure()

    %% Subplot 221
    xmf_subplot(2,2,1, 'NextPlot', 'Add', 'box', 'on')

    fplot(@(x) sin(x), [0, 2*pi])

    xlabel('$x$'), ylabel('$y$')
    title('Sinus')
    
    set(gca,    'xLim',         [0 2*pi], ...
                'xTick',        [0 pi 2*pi], ...
                'xTickLabel',   {'$0$' '$\pi$' '$2\pi$'},  'yTick',        [-1 0 1])
            
    %% Subplot 221
    xmf_subplot(2,2,2, 'NextPlot', 'Add', 'box', 'on')

    fplot(@(x) cos(x), [0, 2*pi], 'g')

    xlabel('$x$'), ylabel('$y$')
    title('Kosinus')
    
    set(gca,    'xLim',         [0 2*pi], ...
                'xTick',        [0 pi 2*pi], ...
                'xTickLabel',   {'$0$' '$\pi$' '$2\pi$'},  'yTick',        [-1 0 1])
            
    %% Subplot 22[3,4]
    xmf_subplot(2,2,[3 4], 'NextPlot', 'Add', 'box', 'on')

    fplot(@(x) asin(x), [-1 1], 'b')
    fplot(@(x) acos(x), [-1 1], 'g')

    xlabel('$x$'), ylabel('$y$')
    title('Arcussinus und Arccuscosinus')
    legend('$\arcsin(x)$', '$\arccos(x)$')
    
    set(gca,    'yLim',         [-pi pi], ...
                'yTick',        [-pi 0 pi], ...
                'yTickLabel',   {'$-\pi$' '$0$'  '$\pi$'})

%% Preparation
xmf_prepare()
        
%% Run matlabfrag
xmf_export(mfilename)

%% eof
