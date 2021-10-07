% ISARRMEMBER find array elements
%   
%   [LIA]=ISARRMEMBER(A,B)
%   [LIA,LOCB]=ISARRMEMBER(A,B)
%   LIA is a logical array of the same size as array A which is true when
%   the respective element of A is found in array B. Array LOCB containing
%   the lowest absolute index in B for each element in A which is a member
%   of B and 0 if there is no such index. A and B might be any array with
%   '()' subsref-type.
%   
%   Example: isarrmember([1 2 3],[1 1])
%       
%   See also ISMEMBER, SUBSREF, ISEQUAL

% REVISIONS:    2014-10-22 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function [lia,locb]=isarrmember(A,B)

lia=false(size(A));
locb=false(size(B));

for i_A=1:numel(A)
    for i_B=1:numel(B)
        if isequal(A(i_A),B(i_B))
            locb(i_A)=i_B;
            lia(i_A)=true;
            break
        end
    end
end