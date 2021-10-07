% ADDINPUTINTEGRATOR 
%   
%   ADDINPUTINTEGRATOR() 
%   
%   Example:
%       
%   See also APPROXINPUTDERIVATIVE,BUILDLTI

% REVISIONS:    2016-12-15 first implementation (MP)
% 
function sys=addInputIntegrator(sys,uIdxArr,duIdxArr,wc)


n_in=size(sys,2);
n_u=numel(duIdxArr);
if n_u~=numel(uIdxArr)
	error('uIdxArr and duIdxArr must be of equal length.');
end

if nargin<4
    wc=zeros(n_u,1);
end
if numel(wc)~=n_u
    wc=repmat(wc,n_u,1);
end


% PT1-FILTER
% with original inputs du and outputs 
% a) u  (integrated input)
% b) du (original input)
% =[1/(s+wc);1]=ss(-wc,1,[1;0],[0;1])
A=diag(-wc);
B=zeros(n_u,n_in);
B(1:n_u,duIdxArr)=eye(n_u);
B(:,uIdxArr)=[];
C=zeros(n_in,n_u);
C(uIdxArr,:)=eye(n_u);
D=eye(n_in);
D(:,uIdxArr)=[];

sys=sys*ss(A,B,C,D);
