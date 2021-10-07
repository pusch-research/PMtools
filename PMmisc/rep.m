% REP repeat scalar number or reshape vector
%   
%   A=REP(A,N) 
%   A=REP(A,N,DIM) repeat scalar A by N times in dimension DIM. If A has 
%   already N elements, it is only reshaped according to DIM.
%   
%   Example: a=rep(10,2,2);
%       
%   See also REPMAT,RESHAPE,REPDIAG

% REVISIONS:    2017-01-31 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function a=rep(a,n,dim)

n_a=numel(a);
if nargin<=2
    dim=1;
end


if n_a~=1 && n_a~=n
    error('wrong size.');
else
    d=ones(1,max(dim,2));
    d(dim)=n;
    
    if n_a==1
        a=repmat(a,d);
    else
        a=reshape(a,d);
    end
end