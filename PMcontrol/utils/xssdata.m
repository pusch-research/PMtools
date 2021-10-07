% XSSDATA ssdata for model arrays with different number of states
%   
%   XSSDATA() 
%   
%   Example:
%       
%   See also SSDATA

% REVISIONS:    2018-05-27 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function [a,b,c,d]=xssdata(sys)


% init
n_x=order(sys);
[n_y,n_u,sysSize]=sssize(sys);
n_xmax=max(n_x(:));
a=zeros([n_xmax n_xmax sysSize]);
b=zeros([n_xmax n_u sysSize]);
c=zeros([n_y n_xmax sysSize]);
d=zeros([n_y n_u sysSize]);


% copy
[aC,bC,cC,dC]=ssdata(sys,'cell');
for i_sys=1:prod(sysSize)
    n=n_x(i_sys);
    a(1:n,1:n,i_sys)=aC{i_sys};
    b(1:n,:,i_sys)=bC{i_sys};
    c(:,1:n,i_sys)=cC{i_sys};
    d(:,:,i_sys)=dC{i_sys};
end





























