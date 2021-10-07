% XCELL2MAT overwrite cell2mat for noncell values
%   
%   M=XCELL2MAT(C) works like CELL2MAT and returns M=C if C is not a cell.
%   
%   Example: cell2mat(10)
%       
%   See also CELL2MAT

% REVISIONS:    2017-04-12 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function m=xcell2mat(c)

if ~iscell(c)
    m=c;
else
    m=cell2mat(c);
end


