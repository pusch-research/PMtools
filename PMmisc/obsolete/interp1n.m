% INTERP1N interpolate n-dimensional array along highest dimension
%   
%   VOUT=INTERP1N(...) is an extension of INTERP1 for n-dimensional arrays.
%   The interpolation is performed along the highest dimension (n) of the 
%   input data. For descreption of the interface see INTERP1. The function
%   may be used for element-wise matrix interpolation.
%       
%   See also INTERP1

% REVISIONS:    2016-10-20 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function  Vout = interp1n(varargin)

% find data to be interpolated (depends on type of input data, see INTERP1.m)
if nargin==2 || (nargin>2 && ischar(varargin{3}))
    i_v=1;
else
    i_v=2;
end
n_xq=numel(varargin{i_v+1});

% get data to be interpolated
v=varargin{i_v};


% reshape data to vector format
v_size=size(v);
n_row=prod(v_size(1:end-1)); 
n_col=v_size(end);
v=reshape(v,n_row,n_col)';
varargin{i_v}=v;

% run interpolation
Vout=interp1(varargin{:});

% reshape interpolated data back to original format
Vout=reshape(Vout',[v_size(1:end-1) n_xq]);

