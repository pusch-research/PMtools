function varargout = xmf_init(varargin)
% XMF_INIT Defines a configuration for the XMF tool chain
%
%   Use this function to centrally set options for the functions of the XMF
%   toolchain. The options defined with this function will be used as
%   defaults by the following function calls. They can be overwritten for
%   each call. Please refer to the specific function for a reference on the
%   possible keys and values.
%
%   XMF_INIT(KEY, VALUE, ...) sets the specified KEY/VALUE pairs.
%
%   XMF_INIT(KEY, [], ...) resets the specified KEY to its default.
%
%   XMF_INIT('reset') resets all keys to their defaults.
%
%   XMF_INIT('defaults') displays the possible keys and default values.
%
%   SETTINGS = XMF_INIT(...) outputs the current SETTINGS structure.
%
%   XMF_INIT() forces the output of the SETTINGS structure.
%
%   Please note: The settings passed to this function are only checked once
%   they are processed by the following commands.
%
%   See also: XMF_FIGURE, XMF_SUBPLOT, XMF_PREPARE, XMF_EXPORT


%% Define Default values
% Define default values for xmf_figure function
default.xmf_figure.unit    = 'centimeter';
default.xmf_figure.width   = 12;
default.xmf_figure.height  = 8;

% Define default values for xmf_subplot function
default.xmf_subplot.unit         = 'centimeter';
default.xmf_subplot.leftmargin   = 1.5;
default.xmf_subplot.rightmargin  = 0.5;
default.xmf_subplot.topmargin    = 1.0;
default.xmf_subplot.bottommargin = 1.0;
default.xmf_subplot.hspace       = 1.5;
default.xmf_subplot.vspace       = 2.0;
default.xmf_subplot.xlabelspace  = [];
default.xmf_subplot.ylabelspace  = [];
default.xmf_subplot.titlespace   = [];


% Define default values for prepare function
default.xmf_prepare.escape      = true; % Escape special characters
default.xmf_prepare.protectspace= true; % Protect whitespace chracters
default.xmf_prepare.ensuremath  = true; % Ensuremath of special strings
default.xmf_prepare.fontsize    = [];   % Do not change font size
default.xmf_prepare.fontname    = [];   % Do not change font name
default.xmf_prepare.interpreter = [];   % Do not change interpreter

% Define default values for export function
default.xmf_export.source      = @gcf;
default.xmf_export.compiler    = 'pdflatex';
default.xmf_export.output      = 'both';
default.xmf_export.preview     = 'none';
default.xmf_export.header      = [];
default.xmf_export.fixline     = false;
default.xmf_export.del_files   = true;

%% Collect valid keys
groups  = fieldnames(default);
keys    = {};
i_group = length(groups);

while i_group > 0
    keys_new = fieldnames(default.(groups{i_group}));
    keys     = vertcat(                               keys_new,      keys);    %#ok<AGROW>
    groups   = vertcat(groups(1:i_group-1), repmat(groups(i_group), length(keys_new), 1), groups(i_group+1:end));
    i_group  = i_group-1;    
end
clear i_group keys_new

%% Define THE persistent variables
persistent settings
if isempty(settings)
    settings = default;
end

%% Force output of the current configuration, if no argument passed
if     nargin < 1
    varargout{1} = settings;
    
%% Special commands, if one argument passed
elseif nargin < 2
    
    % Reset all key/value pairs
    if     strcmpi(varargin{1}, 'reset')
        settings = default;
        
    % Output default values
    elseif strcmpi(varargin{1}, 'defaults')
        disp('Possible keys and their default values:')
        values = arrayfun(@(i) default.(groups{i}).(keys{i}), (1:length(keys))', 'UniformOutput', false);
        display_table(horzcat(groups, keys, values), {'affects:' 'key:' 'default:'})
        disp('For explanantion on their effect, please see the documentation for related functions.')
        
    % Issue warning for bad command
    else
        warning('xmf_init:BadCommand', 'Bad command used for xmf_init: ''%s''.', varargin{1});
    end

%% Loop all settings passed to here
else
    for i_arg = 1:2:nargin-1
        key = varargin{i_arg};
        val = varargin{i_arg+1};
        
        % If valid key...
        pos = find(strcmpi(keys, key));
        if ~isempty(pos)
            
            % ... set actual value
            if ~isempty(val)
                settings.(groups{pos}).(keys{pos}) = val;
                
            % ... or set default value
            else
                settings.(groups{pos}).(keys{pos}) = default.(groups{pos}).(keys{pos});
            end
            
        % ... else issue warning
        else
           warning('xmf_init:BadKey', 'Bad key used for xmf_init: ''%s''.', key);
        end
    end
end

%% Output the settings, if output is requested
if nargout > 0
    varargout{1} = settings;
end





