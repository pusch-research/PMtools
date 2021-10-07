% MAXERR max error of 2 arrays
%   
%   ERR=MAXERR(A,B)
%   ERR=MAXERR(A,B,TYPE)
%   
%   Example: maxErr(2,2.3,'rel')
%       
%   See also MAX

% REVISIONS:    2016-07-11 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function err=maxErr(a,b,type,tol)

if nargin<=2
    type='rel';
end
if nargin<=3
    tol=sqrt(eps);
end

a=a(:);
b=b(:);
err=abs(a-b);

if strcmp(type,'rel') 
    denum=full(a);
    denum(abs(denum)<tol)=1;
    err=full(err)./denum; 
elseif ~strcmp(type,'abs')
    error('not implemented.');
end

err=max(err);