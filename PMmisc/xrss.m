% XRSS build random state space model with predefined poles
%   
%   XRSS(N_X,N_Y,N_U,'parameter',value) 
%   
%   Example:
%       
%   See also 

% REVISIONS:    2017-05-08 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function sys=xrss(n_x,n_y,n_u,varargin)


p=inputParser();
p.addOptional('realPole',false); % real poles
p.addOptional('unstPole',false); % unstable poles
p.addOptional('density',1); % density of input/output/feedthrough matrix
p.addOptional('ord',0); % order of numbers (10^ord)
p.addOptional('repPole',1,@(x) x>=1); % repeat pole
p.addOptional('hasFeedthrough',false,@(x) islogical(x)); % with feedthrough
p.addOptional('realizable',false,@(x) islogical(x)); % realizable (real valued A,B,C,D)
p.addOptional('poleImagWeight',10,@(x) x>=0);
p.parse(varargin{:});
realPole=p.Results.realPole(:);
unstPole=p.Results.unstPole(:);
repPole=p.Results.repPole(:);
density=p.Results.density;
ord=p.Results.ord;
hasFeedthrough=p.Results.hasFeedthrough;
realizable=p.Results.realizable;
poleImagWeight=p.Results.poleImagWeight;
% defaults
if nargin<1
    n_x=1;
end
if nargin<2
    n_y=1;
end
if nargin<3
    n_u=1;
end

% real poles
if numel(realPole)==1 
    if realPole
        n_pC=0;
        n_pR=n_x;
    else
        n_pC=floor(n_x/2);
        n_pR=mod(n_x,2);
    end
    
    realPole=[true(n_pR,1); false(n_pC,1)];
else
    n_pC=sum(realPole);
    n_pR=numel(realPole)-n_pC;
end
n_p=n_pC+n_pR; % number of pole(pairs)

% unstable poles
if numel(unstPole)==1
    unstPole=repmat(unstPole,n_p,1);
elseif numel(unstPole)~=n_p
    error('wrong size of unstPole.');
end

% repeated poles
if numel(repPole)==1
    repPole=repmat(repPole,n_p,1);
elseif numel(repPole)~=n_p
    error('wrong size of repPole.');
end


% check n_x
n_xNew=sum(~realPole.*repPole)*2+sum(realPole.*repPole);
if n_x~=n_xNew
    warning('n_x is ignored.');
end



%% make matrices

a=zeros(n_xNew,n_xNew);
b=nan(n_xNew,n_u);
c=nan(n_y,n_xNew);

if density<1
    fRand=@(x,y) full(sprandn(x,y,density));
else
    fRand=@(x,y) full(randn(x,y));
end

i_p=1;
i_x=1;
while true
    
    if i_x>n_xNew
        break;
    end
    
    % define sign of real part of pole
    if unstPole(i_p)
        vzReal_act=1;
    else
        vzReal_act=-1;
    end
    
    % generate pole(pair)
    n_rep=repPole(i_p);
    if realPole(i_p)
        a_act=vzReal_act*abs(randn(1));
        b_act=fRand(n_rep,n_u);
        c_act=fRand(n_y,n_rep);
    elseif realizable
        pR=vzReal_act*rand(1);
        pI=vzReal_act*randn(1)*poleImagWeight;
        a_act=[pR pI;-pI pR];
        b_act=fRand(2*n_rep,n_u);
        c_act=fRand(n_y,2*n_rep);
    else
        a_act=vzReal_act*abs(randn(1))+1j*randn(1)*poleImagWeight;
        b_act=fRand(n_rep,n_u)+1i*fRand(n_rep,n_u);
        c_act=fRand(n_y,n_rep)+1i*fRand(n_y,n_rep);
        a_act(2,1)=conj(a_act);
        b_act([1:2:n_rep*2 2:2:n_rep*2],:)=[b_act;conj(b_act)];
        c_act(:,[1:2:n_rep*2 2:2:n_rep*2])=[c_act conj(c_act)];
        a_act=diag(a_act);
    end
    
    % repeat pole(pair) with different IO directions
    if n_rep>1
        a_act=repmat({a_act},n_rep,1);
        a_act=blkdiag(a_act{:});
    end
    
    % insert
    nx_act=length(a_act);
    x_iArr=i_x:i_x+nx_act-1;
    a(x_iArr,x_iArr)=a_act;
    b(x_iArr,:)=b_act;
    c(:,x_iArr)=c_act;
    
    % continue loop
    i_p=i_p+1;
    i_x=i_x+nx_act;
        
end
    
if hasFeedthrough
    d=randn(n_y,n_u);
else
    d=0;
end



%% build system
sys=ss(a*10^ord,b*10^ord,c*10^ord,d*10^ord);


if any(~any(b,1)) || any(~any(c,2))
    warning('zero inputs/outputs.');
end
