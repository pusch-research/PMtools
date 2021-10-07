% XBLKDIAG create block diagonal matrix from array
%   
%   XBLKDIAG(ARR) create block diagonal matrix from array ARR which is 
%   either a cell array of matrices or a matrix whose columns are used as
%   blocks.
%   
%   Example: xblkdiag([1 2;3 4;5 6]')'
%       
%   See also BLKDIAG

% REVISIONS:    2015-01-19 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function y=xblkdiag(arr)

if iscell(arr)
    y=blkdiag(arr{:});
else
    y=xblkdiag(mat2cell(arr,size(arr,1),ones(size(arr,2),1)));
end
    