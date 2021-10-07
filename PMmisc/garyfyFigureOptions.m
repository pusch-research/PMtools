function opts=garyfyFigureOptions(varargin)
% function opts=garyfyFigureOptions()
%
% Function that contains defaults plot options for the garyfyFigure()
% function. It cna also be called separately to return an options structure
% that can be later modified and used with garyfyFigure().
%
% The options structure contains the following fields:
%   .TickMarkFontSize
%   .AxesLabelFontSize
%   .LegendFontSize
%   .LegendLocation
%   .LineWidth
%
% AAO 09/14/2011 -Initial coding
opts.TickMarkFontSize=12;
opts.AxesLabelFontSize=12;
opts.LegendFontSize=12;
opts.LegendLocation = 'Best';
opts.LineWidth=1.5;


for ii=1:2:numel(varargin)
    if isequal(varargin{ii},'FontSize')
        opts.TickMarkFontSize=varargin{ii+1};
        opts.AxesLabelFontSize=varargin{ii+1};
        opts.LegendFontSize=varargin{ii+1};
    elseif ~isfield(opts,varargin{ii})
        error('opts not given.');
    end
    opts.(varargin{ii})=varargin{ii+1};
end
