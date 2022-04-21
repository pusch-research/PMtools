%Demonstratates how a user specific LaTeX preamble can be used
ccc
tex_warn_state = warning('query', 'MATLAB:tex');
warning('off', 'MATLAB:tex');

%% Parameters
% Reste xmf_paramters
xmf_init('reset');

% Define export parameter
xmf_init('header', 'FigHeader.tex');

% Define figure properties
xmf_init('leftmargin', 1.8, 'rightmargin', 0.3, 'bottommargin', 1, 'topmargin', .3);

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
    ax(1)  = xmf_subplot(111);
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
    
    % Legend
    hlri = legend(hpri([1 2 1 3]), '$\Re (\hat C (i k))$', '$\Im (\hat C (i k))$', 'Exact', 'Approx.', 'Location', 'East');  
    hllsc = findobj(hlri, 'Color', 'b');    
    set(hllsc([4 6]), 'Color', 'k') 
    set(findobj(hlri,'string','$\Re (\hat C (i k))$'), 'userdata', 'matlabfrag:$\Re (\modtheo(\ci k))$');
    set(findobj(hlri,'string','$\Im (\hat C (i k))$'), 'userdata', 'matlabfrag:$\Im (\modtheo(\ci k))$');

%% XMF Preperation
xmf_prepare();
 
%% Run MatlabFrag and create preview
xmf_export(mfilename)

%% Restet warn_state
warning(tex_warn_state.state, 'MATLAB:tex');

%% eof