function varargout = xmf_figure(varargin)
%XMF_FIGURE An extension of the standard figure command.
%
%   In addition to the common figure properties, the properties height and width
%   can be used, in order to define the figure format simpler. Further, default
%   values from xmf_init are used.
% 
%   In contrast to the standard figure command, an axis will be created in
%   any empty figure by executing xmf_subplot(111).
%
%   If the first argument is numeric, it will be used as the figure handle.
%   In this way you can also reformat an existing figure.
%
%   See also: FIGURE, XMF_INIT



%% Get defaults
settings = xmf_init();
settings = settings.xmf_figure;


%% Get figure handle, if passed
if nargin > 0 && isnumeric(varargin{1})
    fh = varargin{1};
    varargin = varargin(2:end);
else
    fh = [];
end


%% Check inputs
% Make lower
for i_opt = 1:2:length(varargin)-1
    varargin{i_opt} = lower(varargin{i_opt});
end

% unit
ii_opt = find(ismember(varargin(1:2:end), {'unit'}));
if ~isempty(ii_opt)
    settings.unit = varargin{2*ii_opt};
end

% height
ii_opt = find(ismember(varargin(1:2:end), {'height'}));
if ~isempty(ii_opt)
    settings.height = varargin{2*ii_opt};
    varargin(2*ii_opt-[1 0]) = [];
end

% width
ii_opt = find(ismember(varargin(1:2:end), {'width'}));
if ~isempty(ii_opt)
    settings.width = varargin{2*ii_opt};
    varargin(2*ii_opt-[1 0]) = [];
end


%% Create figure
if ~isempty(fh)
    figure(fh);
else
    fh = figure();
end

set(fh, 'unit', settings.unit, varargin{:}, 'resize', 'off');

%% Apply changes
if isempty(varargin) || ~ismember({'position'}, varargin(1:2:end))
    pos = get(fh, 'position');
    pos(2) = pos(2)+pos(4)-settings.height;
    pos(3) = settings.width;
    pos(4) = settings.height;
    set(fh, 'position', pos);
    
    % Hack to ensure, that the correct position is set
    get(fh, 'position');
    set(fh, 'position', pos);
end


%% Creat figure, if plot is empty
if isempty(get(fh, 'Children'))
    xmf_subplot(111)
end

%% Create Output
if nargout >0
    varargout{1} = fh;
end

end