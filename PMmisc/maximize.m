% MAXIMIZE maximize figure
%   
%   MAXIMIZE() maximizes current figure on monitor number one
%
%   MAXIMIZE(IMONITOR) maximizes current figure on given monitor IMONITOR
%
%   MAXIMIZE(IMONITOR,FIGURE_HANDLE)
%   maximizes figure with handle FIGURE_HANDLE on given monitor IMONITOR
%   
%   Example: maximize
%       
%   See also DRAWNOW, GCF

% REVISIONS:    2014-12-02 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function []=maximize(iMonitor,figure_handle)

if nargin<=1
    figure_handle=gcf;
    if nargin==0
        iMonitor=1;
    end
end

monitorPositions=get(0,'monitorPositions');
if size(monitorPositions,1)<iMonitor
    iMonitor=1;
end
iMonitor=size(monitorPositions,1)+1-iMonitor;

h=monitorPositions(iMonitor,4)-monitorPositions(iMonitor,2);
w=monitorPositions(iMonitor,3)-monitorPositions(iMonitor,1);
bottom=max(monitorPositions(:,4))-monitorPositions(iMonitor,4);
left=monitorPositions(iMonitor,1);
set(figure_handle,'Position',[left bottom w h]);


drawnow;
%pause(0.01);
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jFrame = get(handle(gcf),'JavaFrame');
jFrame.setMaximized(true);   % to maximize the figure
