% M2FT convert meter to feet
%
%   M2FT() returns 3.28084
%   M2FT(m) returns m*3.28084
%
%   see also FT2M

function ft=m2ft(varargin)

narginchk(0,1);

ft=3.28084;
if nargin==1
    ft=varargin{1}*ft;
end
 