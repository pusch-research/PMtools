function varargout = xmf_legend (varargin)
%XMF_LEGEND An extension of the standard legend command.
%
% XMF_LEGEND accepts all inputs like the standard legend command, but provides
% two extra features:
%   - In addition to the standard Location properties it is possible to place 
%     the legend at the position of an xmf_subplot, using
%           XMF_LEGEND( ..., 'location', {nrow ncol [iplot1 iplot2 ...]}, ...).
%   - It is further possible to use the matlafrag userdata interface, by
%           XMF_LEGEND( ..., 'userdata', {'string1', 'string2', ...}, ...).
%     Empty strings will not be written to the UserData.
%
% See also: LEGEND, XMF_EXPORT, XMF_SUBPLOT


%% Check input
options = varargin;
options(~cellfun(@ischar, varargin)) = {''};
options = lower(options);

% Remove userdate from varagin
ii_ud = find(ismember(options, 'userdata'));
if ~isempty(ii_ud)
    userdata = varargin{ii_ud+1};
    varargin([ii_ud, ii_ud+1]) = [];
    options( [ii_ud, ii_ud+1]) = [];
else
    userdata = [];
end

% Remove Location subplot
ii_loc = find(ismember(options, 'location'));
if ~isempty(ii_loc) && iscell(varargin{ii_loc+1})
    sub_plot_loc = varargin{ii_loc+1};
    varargin([ii_loc, ii_loc+1]) = [];
    options( [ii_loc, ii_loc+1]) = []; %#ok<NASGU>
else
    sub_plot_loc = [];
end

%% Run legend
[legh, objh, linh, text] = legend(varargin{:});

%% Apply Subplot
if ~isempty(sub_plot_loc)
    if length(sub_plot_loc) ~=3 && ~iscell(sub_plot_loc)
        error('The legend location must be specified by a 3 element cell array!')
    end
    ah = xmf_subplot(sub_plot_loc{1},sub_plot_loc{2},sub_plot_loc{3});
    unit = get(ah, 'unit');
    pos  = get(ah, 'position');
    delete(ah)
    set(legh, 'unit', unit, 'position', pos);
end

%% Apply Userdata
if ~isempty(userdata)
    if ~isequal(size(userdata), size(text))
        error('Userdata must be of the same size as there are legend entries.')
    end
    for ii_ud = 1:length(userdata)
        if ~isempty(userdata{ii_ud})
            set(objh(ii_ud), 'userdata', ['matlabfrag:' userdata{ii_ud}])
        end
    end
end

%% Create output
if nargout >=1
    varargout{1} = legh;
end
if nargout >=2
    varargout{2} = objh;
end
if nargout >=3
    varargout{3} = linh;
end
if nargout ==4
    varargout{4} = text;
end

end