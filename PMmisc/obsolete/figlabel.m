% FIGLABEL 
%   FIGLABEL() 
%   
%   Example
%       
%   
%   See also 


function []=figlabel(str)

annotation(gcf,'textbox',[0 0 1 0.05],'String',str,...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Interpreter','none',...
    'VerticalAlignment','top',...
    'HorizontalAlignment','center');