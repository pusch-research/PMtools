function varargout = xmf_title(varargin)
% XMF_TITLE Allows to create titles about several plots.
% 
%   Usage:
%     XMF_TITLE('text')
%           same like TITLE('text')
%     XMF_TITLE('text', 'Key1', Value1,...)
%           same like TITLE('text', 'Key1', Value1,...)
%     XMF_TITLE(AX,...)
%           adds the title to the specified axes. If AX is a vector of
%           handels. One title covering all subplots is created.
%     [TH, AH_T] = title(...)
%           returns the handle to the text object used as the title.
%           Moreover, AH_T is the (possible invissible) axis, for which the
%           title is acutally created.
% 
%   Example:
%         figure% 
%         subplot(211)
%             plot(1:10, randn(1,10))
%             xmf_title('Normal title')
%         ah(1) = subplot(223);
%             plot(1:10, randn(1,10))
%         ah(2) = subplot(224);
%             plot(1:10, randn(1,10))% 
%             xmf_title(ah, 'Title about 2 subplots')   
% 
%   See also: title

% REVISIONS:    2013-05-07 First version (knob_an)
%

%% If mulitple handles
if any(ishandle(varargin{1})) && numel(varargin{1})>1
    % Check if all are handels
    if any(~ishandle(varargin{1})) || any(~ismember(get(varargin{1}, 'type'), 'axes'))
        error('All handels must be axis handels.')
    end    
    ah = varargin{1};
    
    % Copy current axis    
    curax = gca;
    
    % Get and recompue position and unit    
    pos  = cell2mat(get(ah, 'position'));
    pos = [min(pos(:,1:2)), max(pos(:,1:2)+pos(:,3:4))-min(pos(:,1:2))];
    
    % Check unit
    unit = unique(get(ah, 'Unit'));
    if numel(unit)>1
        error('Unit of all subplots must be equal.')
    end
    
    % Create axis and title
    ah_title    = axes('Unit', unit{1}, 'Position', pos, 'visible', 'off');
    varargin{1} = ah_title;    
    th          = title(varargin{1:2}, 'visible', 'on', varargin{3:end});   
    
    % Make old gca current
    axes(curax); %#ok<MAXES>
    
%% If none or only one ah
else
    if ~ischar(varargin{1}) && ishandle(varargin{1}) && isequal(get(varargin{1}, 'type'), 'axes')
        ah_title = varargin{1};
    else
        ah_title = gca;
    end
    
    % Call normal title
    th = title(varargin{:});
end

%% Create output
if nargout
    varargout{1} = th;
    varargout{2} = ah_title;
end

%% eof
