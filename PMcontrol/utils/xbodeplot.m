% XBODEPLOT plot bode phase & magnitude of ss (array) in seperate figures
%   
%   XBODEPLOT(SYS,VARARGIN) plot bode phase and magnitude of
%   ss-array SYS with respective names SYSNAME in seperate figures.
%   Additional customization parameters see first section below.
%       
%   See also BODEPLOT

% REVISIONS:    2014-04-28 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function []=xbodeplot(sys,varargin)

size_sysArr=size(sys);
if length(size_sysArr)>2 % array of systems (e.g. several reduced order systems)
    n_sys=prod(size_sysArr(3:end)); 
else % single system
    n_sys=1;
end

%% parse input
p=inputParser;
addOptional(p,'sysName',arrayfun(@(x) num2str(x),1:n_sys,'UniformOutput',false),@(x) numel(x)==n_sys);
addParamValue(p,'figTitle','bode',@(x) ischar(x)); % title of figure and plot
addParamValue(p,'w',{1e-1 2*pi*1e2},@(x) all(cellfun(@(x) x>0,x))); % specified frequencies [rad/s]
addParamValue(p,'plotPhase',false,@(x) islogical(x)); % plot phase
addParamValue(p,'plotMag',true,@(x) islogical(x)); % plot magnitude
addParamValue(p,'figMaximize',0,@(x) x>=0); % screen where to maximize figure(s) (0: original size)
parse(p,varargin{:});
figTitle=p.Results.figTitle;
w=p.Results.w;
plotPhase=p.Results.plotPhase;
plotMag=p.Results.plotMag;
figMaximize=p.Results.figMaximize;
sysName=p.Results.sysName;

%% plot phase
if plotPhase
    figure('NumberTitle','off','Name',['phase ' figTitle]);
    for i=1:n_sys
        bodeplot(sys(:,:,i),w,xbodeoptions('MagVisible', 'off','PhaseMatching','on'));
        hold on
    end
    grid on
    h=get(gcf,'Children');
    legend(h(end-2),sysName);
    title(['phase ' figTitle]);
    addDoubleClickZoom(gcf,1,1);
    if figMaximize>0, maximize(figMaximize);end
end


%% plot magnitude
if plotMag
    figure('NumberTitle','off','Name',['mag ' figTitle]);
    for i=1:n_sys
        bodeplot(sys(:,:,i),w,xbodeoptions('PhaseVisible', 'off'));
        hold on
    end
    grid on
    h=get(gcf,'Children');
    %legend(h(end),sysName);
    title(['magnitude ' figTitle]);
    addDoubleClickZoom(gcf,1,1);
    if figMaximize>0, maximize(figMaximize);end
end
    