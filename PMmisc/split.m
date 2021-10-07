% SPLIT split array
%   
%   [B1,B2,..,Bn]=SPLIT(A)
%   [B1,B2,..,Bn]=SPLIT(A,DIST)
%   [B1,B2,..,Bn]=SPLIT(A,DIST,DIM) split array along dimension DIM into 
%   blocks B1,B2,..,Bn of size(Bi,DIM)=DIST(i) with i=1,2,..n. The number 
%   of outputs is equal to the length of DIST. If not defined, DIM is set 
%   to the first non-singelton dimension of A and DIST is set to size(A,DIM).
%   
%   Example: [a,b]=split(rand(3),[2 1],1)
%       
%   See also CELL2MAT

% REVISIONS:    2015-03-12 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function varargout=split(A,dist,dim)

if nargin<=2
   dim=find(size(A)~=1,1);
   if isempty(dim)
       dim=1;
   end 
end
if nargin<=1
    dist=size(A,dim);
end
if size(A,dim)~=sum(dist)
    error('sum of dist elements must be equal to array size in the respective dimension.');
end

S.type='()';
varargout=cell(1,numel(dist));
i_start=0;
for ii=1:numel(dist)
    if ii>1, i_start=i_start+dist(ii-1); end
    S.subs=repmat({':'},1,ndims(A));
    S.subs{dim}=i_start+(1:dist(ii));
    varargout{ii}=subsref(A,S);
end
