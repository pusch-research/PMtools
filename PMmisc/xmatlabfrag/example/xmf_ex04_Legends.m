%Demonstrates the features of xmf_legend
ccc
tex_warn_state = warning('query', 'MATLAB:tex');
warning('off', 'MATLAB:tex');

%% Parameters
% Reset xmf_paramters
xmf_init('reset');

% Export options
xmf_init('output', 'pdf', 'header', 'FigHeader.tex', 'fixline', 1);

% Figure Poroperties
xmf_init('width', 14, 'height', 8, 'leftmargin', 1.9, 'rightmargin', .1, 'bottommargin', 1.2, 'topmargin', .3, 'hspace', .5, 'vspace', 1.6,'fontsize', 12);

% Matlab visualisation
xmf_init('interpreter', 'latex') 

%% Define Theodorsen and k
k         = [0 logspace(-2, 1, 100)];
mth       = - besselk(0, 1i*k)./(besselk(0, 1i*k) + besselk(1, 1i*k));
mth(k==0) = 0;

mtha      =  -0.165i*k./(1i*k + 0.0455) - 0.335i*k./(1i*k + 0.3);


%% Create figure
fig = xmf_figure();

    %% Real and Imag
    % Settings
    ax = xmf_subplot(121);
    set(gca,  'NextPlot', 'Add',...
              'box', 'on',...
              'xLim', [0 5],...
              'yLim', [-.5 0],...
              'xTick', [0 2.5 5],...
              'yTick', [-.5 -.25 0],...
              'xGrid', 'on',...
              'yGrid', 'on')
    
    % Plot
    hpri(1) = plot(k, real(mth),  'b');
    hpri(2) = plot(k, imag(mth),  'b--');
    hpri(3) = plot(k, real(mtha), 'r');
    hpri(4) = plot(k, imag(mtha), 'r--');
    
    % Label
    xlabel('$k$');  
    ylabel('$\hat C (i k)$', 'UserData', 'matlabfrag:$\modtheo (\ci k)$')
    
    %% Create legend
    [hleg, hobj, hlines, htext] = xmf_legend(hpri([1 2 1 3]), '$\Re (\hat C (i k))$', '$\Im (\hat C (i k))$', 'Exact', 'Approx.', 'Location', {2 2 [2 4]}, ...
                'Userdata', {'$\Re (\modtheo(\ci k))$', '$\Im (\modtheo(\ci k))$', '', ''});
    set(hobj([5,7]), 'Color', 'k')
    
    
%% XMF Preperation
xmf_prepare();
 
%% Run MatlabFrag and create preview
xmf_export(mfilename)

%% Restet warn_state
warning(tex_warn_state.state, 'MATLAB:tex');

%% eof