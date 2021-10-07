% ADDDOUBLECLICKZOOM allows to zoom in on double click on axes object
%
%   ADDDOUBLECLICKZOOM() is the same as ADDDOUBLECLICKZOOM(GCF)
%
%   ADDDOUBLECLICKZOOM(HANDLE,FULLSCREEN,AUTOLABEL) if HANDLE is from a figure, double-click 
%   handles are added to all axes childs. If HANDLE is axes, double-click
%   is added to this axes object. On double-click a new window with only 
%   the respective axes object will be opened in a new figure for zooming.
%   FULLSCREEN defines the screen number on which the window is maximized
%   or is left empty/set to zero if default window size is preferred.
%   AUTOLABEL automatically labels the plot if set to true (default: false)
%   (useful for zoom into bode plots)
%       
%   See also AXES, FIGURE

% REVISIONS:    2014-03-31 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function []=addDoubleClickZoom(handle,fullscreen,autolabel)

if ~exist('handle','var')
    handle=gcf;
end
if ~exist('fullscreen','var')
    fullscreen=0;
end
if ~exist('autolabel','var')
    autolabel=0;
end

if strcmp('axes',get(handle,'type'))
    hAxes_arr=handle;
elseif strcmp('figure',get(handle,'type'))
    hAxes_arr = findall(handle,'type','axes');
else
   error('addAxesDoubleClickZoom:wrongInput','handle type unkown.');
end

for hAxes_act=hAxes_arr
   set(hAxes_act, 'ButtonDownFcn', @(h,arg) buttonDownFcn(h,fullscreen,autolabel));  
end


function buttonDownFcn(handle,fullscreen,autolabel)

persistent hAxes_act;

if isempty(hAxes_act) || hAxes_act~=handle
    % single click
    hAxes_act = handle;
    pause(0.3);
    if hAxes_act==handle
      hAxes_act = [];
    end
else
    % double click -> open new window with current axes only
    title_act=get(get(hAxes_act,'Title'),'String');
    if iscell(title_act)
       title_act=[title_act{:}]; 
    end
    if isempty(title_act)
       title_act=get(get(hAxes_act,'YLabel'),'String'); 
    end
    title_act=[title_act ' >>' get(gcf,'Name')];
    hAxes_new=copyobj(hAxes_act,figure('Name',['Zoom: ' title_act],'NumberTitle','off'));
    set(hAxes_new,'OuterPosition',[0 0 1 1]);
    set(hAxes_new,'Position',[0.13 0.11 0.775 0.815]);
    hAxes_act = [];
    
    if autolabel
        set(hAxes_new,'XTickLabelMode','auto')
        set(hAxes_new,'YTickLabelMode','auto')
        set(hAxes_new,'ZTickLabelMode','auto')
    end
    
    if fullscreen>0
       maximize(fullscreen);
    end
    
end




