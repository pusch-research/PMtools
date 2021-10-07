% XRMS compute rms value of (sampled) signal
%   
%   XRMS(Y)
%   XRMS(T,Y) 
%   XRMS(__,DIM)
%   computes the root mean square (rms) of a sampeled time signal using
%   trapezoidal numerical integration. 
%       
%   See also RMS, TRAPZ

% REVISIONS:    2015-08-19 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function v = xrms(varargin)

if nargin==1
    y=varargin{1};
    v=sqrt(trapz(y.^2)/(length(y)-1)); % unity time step
elseif nargin==2
    if isscalar(varargin{2}) && mod(varargin{2},2)==0
        y=varargin{1};
        dim=varargin{2};
        v=sqrt(trapz(y.^2,dim)/(size(y,dim)-1)); % unity time step
    else
        t=varargin{1};
        y=varargin{2};
        v=sqrt(trapz(t,y.^2)/(max(t)-min(t)));
    end
elseif nargin==3   
    t=varargin{1};
    y=varargin{2};
    dim=varargin{3};
    v = sqrt(trapz(t,y.^2,dim)/(max(t)-min(t)));
else
    error('too many input arguments.');
end


