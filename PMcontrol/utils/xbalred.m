% XBALRED balred with suppresed cmd-line output and multi model capable
%   
%   SYS=XBALRED(SYS)
%   SYS=XBALRED(SYS,N)
%   SYS=XBALRED(SYS,N,OPT)
%       
%   See also BALRED

% REVISIONS:    2018-05-22 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function sys=xbalred(sys,varargin)

n_sys=size(sys(:,:,:),3);

% n_xred
n_xsys=order(sys);
if ~isempty(varargin)
    n_xred=varargin{1};
    if numel(n_xred)==1
        n_xred=repmat(n_xred,n_sys,1);
    elseif numel(n_xred)~=n_sys
        error('wrong size n_xred');
    end
    
    isTooLarge=n_xred>n_xsys;
    n_xred(isTooLarge)=n_xsys(isTooLarge);
else
    % do not reduce but make a minimal realization
    n_xred=order(sys);
end

% balred options
if numel(varargin)>1 
    if isa(varargin(2),'ltioptions.balred')
        balredOpt=varargin{end};
    else
        error('not implemented.'); % with blareddata given (see balred.m)
    end
else
    % do truncation per default
    balredOpt=balredOptions('StateElimMethod','Truncate');
end




% loop (multimodel)
for ii=1:n_sys
    evalc('sys(:,:,ii)=balred(sys(:,:,ii),n_xred(ii),balredOpt);'); % suppress output  
end











