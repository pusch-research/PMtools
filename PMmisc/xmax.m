% XMAX largest component with indices depending on relative tolerance
%   
%   M=XMAX(X)
%   M=XMAX(X,Y) -> NOT (YET) IMPLEMENTED!
%   M=XMAX(X,[],DIM)
%   M=XMAX(X,[],DIM,TOL)
%   [M,I]=XMAX(..)
%   M is computed the same way as in MAX. The logical index array I has
%   the same size as X and is true if the relative distance of X from M
%   is smaller than TOL. If all values are equal in dimension DIM, the 
%   respective entries are set to false.
%       
%   See also XMIN,MAX

% REVISIONS:    2015-11-04 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function [m,i]=xmax(varargin)

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
m=max(val,[],dim);
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
