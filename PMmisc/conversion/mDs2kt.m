% MDS2KT convert meter/second to knots
%
%   MDS2KT() returns 1.9438
%   MDS2KT(kt) returns kt*1.9438
%
%   see also MDS2KT


function kt=mDs2kt(varargin)

narginchk(0,1);

kt=1.9438;
if nargin==1
    kt=varargin{1}*kt;
end