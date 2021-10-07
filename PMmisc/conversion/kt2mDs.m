% KT2MDS convert knots to meter/second
%
%   KT2MDS() returns 0.5144
%   KT2MDS(kt) returns kt*0.5144
%
%   see also MDS2KT



function mDs=kt2mDs(varargin)

narginchk(0,1);

mDs=0.5144;
if nargin==1
    mDs=varargin{1}*mDs;
end