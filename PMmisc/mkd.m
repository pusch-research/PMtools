% MKD returns mass-spring state space system
%   
%   SYS=MKD()
%   SYS=MKD(M,K,D,IN,OUT) returns a mass-spring state space system with 
%   mass M, stiffness K and damping D, where all three inputs may be
%   scalar, vectors or (square) matrices of same size. The desired inputs
%   are defined in IN ('F','du','ddu') and the desired outputs are defined 
%   in OUT ('u','du','ddu').
%     
%   Example: mkd(1,1,1)
%       
%   See also SS

% REVISIONS:    2016-12-12 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function sys=mkd(m,k,d,in,out)


%% input handling
if nargin<1
    m=1;
end
if nargin<2
    k=1;
end
if nargin<3
    d=0.1;
end
if nargin<4
    in='F';
end
if nargin<5
    out='u';
end

n_m=numel(m);
n_k=numel(k);
n_d=numel(d);
n_modes=max([n_m n_k n_d]);

if n_m~=n_modes
    m=repmat(n_m,n_modes,1); 
end
if n_k~=n_modes
    k=repmat(k,n_modes,1);
end
if n_d~=n_modes
    d=repmat(d,n_modes,1);
end

if isvector(m)
    m=diag(m);
end
if isvector(k)
    k=diag(k);
end
if isvector(d)
    d=diag(d);
end


%% assemble system
a=[zeros(n_modes) eye(n_modes)
   -m\k           -m\d         ];

switch in
    case 'F'
        b=[zeros(n_modes)
           m\eye(n_modes)];
    case 'ddu'
        b=[zeros(n_modes)
           eye(n_modes)];
    case 'du'
        b=[eye(n_modes)
           zeros(n_modes)];
    otherwise
        error('not implemented.');
end
   
switch out
    case 'u'
        c=[eye(n_modes) zeros(n_modes)];
        d=0;
    case 'du'
        c=[zeros(n_modes) eye(n_modes)];
        d=0;
    case 'ddu'
        c=[zeros(n_modes) eye(n_modes)]*a;
        d=[zeros(n_modes) eye(n_modes)]*b;
    otherwise
        error('not implemented.');
end

sys=ss(a,b,c,d);

