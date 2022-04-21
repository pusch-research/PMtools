function varargout = xmf_subplot(varargin)
%XMF_SUBPLOT An extension of the standard subplot command for use with xmf_export
% 
%   XMF_SUBPLOT is the same function like the default SUBPLOT commmand, but it 
%   computes the positions of the axis in a different way. 
% 
%   Possible calls:
%      1.)  XMF_SUBPLOT([Nrow, Ncol, IdPlot])
%      2.)  XMF_SUBPLOT(Nrow, Ncol, IdPlot, 'Property1', Value1, ...)
%      3.)  XMF_SUBPLOT('position', [left bottom width height], 'Property1', Value1, ...)
%
%   In addition to the common subplot properties, margins to the figure boundaries
%   and spaces between several subplots can be easily defined. Therefore the
%   following property keywords are introduced:
%         - leftmargin
%         - rightmargin
%         - topmargin
%         - bottommargin
%         - hspace
%         - vspace
%   Default values from xmf_init are used, if the values are not given explicitly.
%   Note: In the case that XMF_SUBPLOT is called by the 3rd possibility, these additional
%         options are ignored, since the position is explicitly given.
%
%   In the case of 2D plots it is further possible, to define default positions for
%   the x-/y-axis and the title location using the keywords
%         - xlabelspace
%         - ylabelspace
%         - titlespace
%   Default values from xmf_init are used, if the values are not given explicitly.
%   If valuse are [], the standard matlab positions are used.
%  
%   Note: - In contrast to the standard subplot command 
%               xmf_subplot(111)
%           is identical to 
%               xmf_subplot(1, 1, 1).
%         - If the specified subplot allready exists (i.e. there is a axis
%           at exactly the same position), any standard  property change
%           will be ignored. This behavior is idenitcal to the standard 
%           subplot command. The additonally introduced propterties work 
%           anyway.
%         - In order to avoid unexpected behaviour, if 
%               xmf_figure
%               xmf_subplot(1, 1, 1, ...)
%           is executed, there is an exception of the last rule:
%               If xmf_subplot(1, 1, 1, ...) is called and the axis at this
%               position is empty all propterty changes will be aplied, 
%               even there is allready an axis at this positon.
%
%   See also: SUBPLOT, XMF_INIT

% REVISIONS:    2011-07-07 First version (knob_an)
%               2011-07-08 Label positioning added (knob_an)
%               2011-12-19 Bugfix if the same subplot is called again (knob_an)
%               2012-07-11 Titel positioning added (M.A.)    
%               2012-09-09 Improvements in parameter parsing (knob_an)          
%
% Contact       Andreas Knoblach,  Andreas.Knoblach@dlr.de
% Copyright (C) 2008-2011 DLR Robotics and Mechatronics         __/|__
%                                                              /_/_/_/
%                                                                |/ DLR



%% Check inputs
if isequal(lower(varargin{1}), 'position')
    %% CASE: xmf_subplot('position', [left, bottom, width, heigth], varargin)
    % Get position
    pos = varargin{2};
    
    % Parse other options
    varargin(1:2) = [];
    [spl_settings, xmf_settings] = parseInput(varargin{:});

elseif nargin == 1
    %% CASE: xmf_subplot([m, n, P])
    % Get nrow, ncol, iplot
    mnP = varargin{1};
    if mnP<100 || mnP>999 || mnP~=round(mnP)
        error('If only one argument is provied it must be three digits integer')
    end
    iplot = mnP -  10*round(mnP/10);
    mnP   = round(mnP/10);
    ncol  = mnP - 10*round(mnP/10);
    nrow  = round(mnP/10);
    
    % Get options
    varargin(1) = [];
    [spl_settings, xmf_settings] = parseInput(varargin{:});
    
    % Compute pos
    pos = xmf_subplot_computePos(nrow, ncol, iplot, xmf_settings);

elseif all(cellfun(@(C) isnumeric(C) & isequal(C, round(C)), varargin(1:3)))
    %% CASE: xmf_subplot(m, n, P, varargin)
    % Get nrow, ncol, iplot
    nrow  = varargin{1};
    ncol  = varargin{2};
    iplot = varargin{3};
    
    % Get options
    varargin(1:3) = [];
    [spl_settings, xmf_settings] = parseInput(varargin{:});
    
    % Compute pos
    pos = xmf_subplot_computePos(nrow, ncol, iplot, xmf_settings);
else
    %% CASE: Unknown command option
    error('Invalid syntax. For valid function calls, type ''help xmf_subplot''.')
end


%% Create axis
% Call subplot
ah = subplot('Position', pos, spl_settings{:}, 'Unit', xmf_settings.unit);

% Workaround for subplot 111
if isequal([nrow, ncol, iplot], [1,1,1]) && isempty(get(ah, 'Children')) 
    set(ah, spl_settings{:}, 'Unit', xmf_settings.unit);
end
  
% Get pos
pos = get(ah, 'Position');

%% Modify label and title positions
% xlabel
if ~isempty(xmf_settings.xlabelspace)
    hxl = get(ah, 'xLabel');
    set(hxl, 'unit', xmf_settings.unit);
    posxl = [pos(3)/2, -xmf_settings.xlabelspace, 0];
    set(hxl, 'position', posxl)
end

% ylabel
if ~isempty(xmf_settings.ylabelspace)
    hyl = get(ah, 'yLabel');
    set(hyl, 'unit', xmf_settings.unit);
    posyl = [-xmf_settings.ylabelspace, pos(4)/2, 0];
    set(hyl, 'position', posyl)
end

% title
if ~isempty(xmf_settings.titlespace)
   ht = get(ah, 'title');
   set(ht, 'unit', xmf_settings.unit);
   post = [pos(3)/2, xmf_settings.titlespace+pos(4), 0];
   set(ht, 'position', post)
end

%% Create Output
if nargout >0
    varargout{1} = ah;
end
end

%% Function: parseInput
function [spl_settings, xmf_settings] = parseInput(varargin)
    % Check input
    if mod(length(varargin),2)
        error('Options must be specified in key value pairs')
    end
    
    % Make keys lower
    varargin(1:2:end) = cellfun(@(C) lower(C), varargin(1:2:end), 'UniformOutput', false);
    
    % Initiate xmf_keys and get key names
    xmf_settings = xmf_init();                  % Get xmf_setting
    xmf_settings = xmf_settings.xmf_subplot;    % Extract for subplot
    xmf_key      = fieldnames(xmf_settings);    % Get key names
    
    % Get user specifi values
    for ii_key = 1:length(xmf_key)
        ii_opt = find(ismember(varargin(1:2:end), xmf_key(ii_key)));
        
        if ~isempty(ii_opt)
            % Copty data to xmf_settings
            xmf_settings.(xmf_key{ii_key}) = varargin{2*ii_opt(end)};
            
            % Remove data from varargin (if not unit)
            if ~isequal(xmf_key{ii_key}, 'unit')
                varargin([2*ii_opt-1, 2*ii_opt]) = [];
            end
        end
    end

    % Copy remaining options to subplot options
    spl_settings = varargin;
    
end

%% Function: xmf_subplot_computePos
function pos = xmf_subplot_computePos(nrow, ncol, iplot, xmf_settings)
    % Get indices
    [icol irow] = ind2sub([ncol nrow], iplot);
    % Count from bottom
    irow = nrow-irow+1;
    % Get min and max entries
    icol=[min(icol), max(icol)];
    irow=[min(irow), max(irow)];

    % Get size of figure
    FigUnit    = get(gcf, 'Unit');         % Get current unit of figure
    set(gcf, 'Unit', xmf_settings.unit)    % Change to unit of xmf_export
    fig_width  = get(gcf, 'Position');     % Get figure postion
    set(gcf, 'Unit', FigUnit)              % Unchagen unit
    fig_height = fig_width(4);             % Extract height
    fig_width  = fig_width(3);             % and width

    % Get size of one subplot
    sub_height = (fig_height - xmf_settings.topmargin  - xmf_settings.bottommargin  - (nrow-1)*xmf_settings.vspace)/nrow;
    sub_width  = (fig_width  - xmf_settings.leftmargin - xmf_settings.rightmargin   - (ncol-1)*xmf_settings.hspace)/ncol;

    % Compute offset
    offset_y  = xmf_settings.bottommargin + (irow(1)-1)*(xmf_settings.vspace+sub_height);
    offset_x  = xmf_settings.leftmargin   + (icol(1)-1)*(xmf_settings.hspace+sub_width);

    % Get size of this subplot
    sub_height = (irow(2)-irow(1)+1)*sub_height + (irow(2)-irow(1))*xmf_settings.vspace;
    sub_width  = (icol(2)-icol(1)+1)*sub_width  + (icol(2)-icol(1))*xmf_settings.hspace;

    % Compute position
    pos = [offset_x offset_y sub_width sub_height]./[fig_width, fig_height, fig_width, fig_height];  % Position in percent unit, since this is the only accepted unit with no row, col, ind

end



%% eof