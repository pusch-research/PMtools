% FT2M convert feet to meters
%
%   M2FT() returns 0.3048
%   M2FT(ft) returns m*0.3048
%
%   see also M2FT


function m=ft2m(varargin)

narginchk(0,1);

m=0.3048;
if nargin==1
    m=varargin{1}*m;
end
 