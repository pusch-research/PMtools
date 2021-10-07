% XMIN largest component with indices depending on relative tolerance
%   
%   M=XMIN(X)
%   M=XMIN(X,Y) -> NOT (YET) IMPLEMENTED!
%   M=XMIN(X,[],DIM)
%   M=XMIN(X,[],DIM,TOL)
%   [M,I]=XMIN(..)
%   M is computed the same way as in MIN. The logical index array I has
%   the same size as X and is true if the relative distance of X from M
%   is smaller than TOL. If all values are equal in dimension DIM, the 
%   respective entries are set to false.
%       
%   See also XMAX,MIN

% REVISIONS:    2015-11-04 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function [m,i]=xmin(varargin)

%% input
val=varargin{1};

if nargin>=2 && ~isempty(varargin{2})
   error('not implemented.'); 
end

if nargin<3 || isempty(varargin{3})
   dim = find(size(val)~=1,1,'first');
   if isempty(dim), dim = 1; end
else
   dim=varargin{3}; 
end

if nargin<4
    tol_rel=0.0005;
else
    tol_rel=varargin{4};
end


%% compute
m=min(val,[],dim);
i=abs(bsxfun(@rdivide,bsxfun(@minus,val,m),m))<tol_rel;

% size to creat rep idx
repSize=ones(1,ndims(val));
repSize(dim)=size(val,dim);

% zero divisions: set to true (peak) if it is 0/0, otherwise false (no peak)
isZero_iArr=repmat(m==0,repSize);
i(isZero_iArr)=val(isZero_iArr)==0;

% all values equal: set to false (no peak)
allEqual_iArr=repmat(all(i,dim),repSize);
i(allEqual_iArr)=0;
