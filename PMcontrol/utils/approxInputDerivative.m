% APPROXINPUTDERIVATIVE approximate derivative input
%   
%   SYS=APPROXINPUTDERIVATIVE(SYS,OPT,UIDXARR,DUIDXARR)
%   Approximates input-derivatives DUIDXARR in order to combine them 
%   with the original inputs UIDXARR. The option OPT may be
%   a) numeric: corner frequency(s) of DT1 filter
%   b) 'shift': only possible if corresponding D is zero
%   c) 'ignore': ignore (delete) the derivative-input channel(s)
%   d) 'none': no approximation
%   e) ss: custom filter given in state space form (not implemented)
%
%   Example: approxInputDerivative(rss(10,2,5,1000,1:2,3:4)
%       
%   See also SS,BUILDLTI

% REVISIONS:    2016-12-15 first implementation (MP)
% 
function sys=approxInputDerivative(sys,opt,uIdxArr,duIdxArr)

n_in=size(sys,2);
n_u=numel(uIdxArr);
if n_u~=numel(duIdxArr)
    error('uIdxArr and duIdxArr must be of equal length.');
end


if isnumeric(opt)
    
    % DT1-FILTER
    % with inputs u and outputs 
    % a) u (original input)
    % b) du (1st derivative of orignal input)
    % =[1;s/(s*1/wc+1)]=ss(-wc,wc,[0;-wc],[1;wc])
    
    % corner frequency [rad/s]
    wc=opt;
    wc=repmat(wc,n_u,1);
    
    % input filter matrices
    A=diag(-wc);
    B=zeros(n_u,n_in);
    B(:,uIdxArr)=diag(wc);      
    B(:,duIdxArr)=[];              
    C=zeros(n_in,n_u);
    C(duIdxArr,:)=-diag(wc);
    D=eye(n_in);
    D(duIdxArr,uIdxArr)=diag(wc);
    D(:,duIdxArr)=[];
    
    sys=sys*ss(A,B,C,D);
    

elseif strcmpi(opt,'shift')
    
    % SHIFTING
    % shift derivative of individual inputs to feedthrough matrix D
    % Y=C*(sI-A)^(-1)*B*sU -> Y=(C*(sI-A)^(-1)*AB+CB)*U
    % leading to B -> AB and D -> CB
    % which is only possible if D is zero for the corresponding 
    % input derivative (strictly proper)
    
    % get ssdata
    if hasdelay(ss)
        error('not implemented.');
    end
    [A,B,C,D]=ssdata(sys);

    % check if corresponding D entries are zero
    if any(any(D(:,duIdxArr)))
        error('inputs can not be shifted as feedthrough matrix is not zero.');
    end

    % shift inputs
    B(:,uIdxArr)=B(:,uIdxArr)+A*B(:,duIdxArr);   
    D(:,uIdxArr)=D(:,uIdxArr)+C*B(:,duIdxArr);

    % delete derivative inputs
    B(:,duIdxArr)=[];
    D(:,duIdxArr)=[];
    
    % re-assamble system
    sys=ss(A,B,C,D);

    
elseif isa(opt,'ss')
    
    % CUSTOM-FILTER
    [a,b,c,d]=ssdata(opt);
    [n_yf,n_uf]=size(opt);
        
    if  n_uf~=1
        error('wrong input size of filter.');
    elseif n_yf==1 && d==0 
        % add derivative row
        d(2,:)=c*b;
        c(2,:)=c*a;
    elseif n_yf~=2
        error('wrong output size of filter.');
    end
    if max(abs(c(2,:)-c(1,:)*a))>sqrt(eps) || max(abs(d(2,:)-c(1,:)*b))>sqrt(eps) || d(1,:)~=0
        warning('second output seems not to be the derivative of first output.');
    end
    
    A=kron(eye(n_u),a);
    B=zeros(length(A),n_in);
    B(:,uIdxArr)=kron(eye(n_u),b);
    B(:,duIdxArr)=[];   
    C=zeros(n_in,length(A));
    C(uIdxArr,:)=kron(eye(n_u),c(1,:)); % assume first output is u
    C(duIdxArr,:)=kron(eye(n_u),c(2,:)); % assume second output is du
    D=eye(n_in);
    D(uIdxArr,uIdxArr)=kron(eye(n_u),d(1,:)); % should be zero anyways
    D(duIdxArr,uIdxArr)=kron(eye(n_u),d(2,:));
    D(:,duIdxArr)=[];
    
    sys=sys*ss(A,B,C,D);
    
elseif strcmpi(opt,'ignore')
    
    % IGNORE derivative input
    sel_iArr=true(n_in,1);
    sel_iArr(duIdxArr)=false;
    sys=sys(:,sel_iArr);
 
elseif ~strcmpi(opt,'none')
    
    error('not implemented.');
    
end







% 




