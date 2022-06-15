function varargout = xsystem(varargin)
% XSYSTEM Extension to the Matlab system command
%
%   XSYSTEM behaves exactly like the standard Matlab SYSTEM command.
%   In addition, it provides support for UNC paths on windows systems by
%   changing the path using 'pushd pwd'. The normal warning is disabled in
%   such cases.
%
%   See also: SYSTEM

% Save old warning state
w = warning;

% Disable UNC warning
warning off MATLAB:UIW_DOSUNC

% Prepend pushd command to user command
if nargin > 0
	varargin{1} = ['pushd ' pwd '&' varargin{1}];
end

% Call the original command
[varargout{1:nargout}] = system(varargin{:});

% Restore warning state
warning(w);
