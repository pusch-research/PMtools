% SSINTERP1 interpolate 1D state space system array
%   
%   SSINTERP1(SYS,PQ)
%   SSINTERP1(SYS,PQ,P,..)
%   
%   Example: ssinterp1(rss(1,2,3,4),[1.4],[1 2 3 4])
%       
%   See also INTERP1,INTERP1N

% REVISIONS:    2018-06-05 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function sys=ssinterp1(sys,pq,p,varargin)

pName=fieldnames(sys.SamplingGrid);
if numel(pName)==1
    pName=pName{:};
    p=sys.SamplingGrid.(pName);
else
    if ~exist('p','var') || isempty(p)
        error('no interpolation grid.');
    else
        pName='';
    end
end
if numel(varargin)<2
    varargin{2}='extrap'; % do extrapolation to avoid error
end


[~,~,sysSize]=sssize(sys);
if any(sysSize(2:end)~=1)
    error('not implemented.');
end
[a,b,c,d]=ssdata(sys(:,:,:));

if prod(sysSize)==1 && isequal(varargin{2},'extrap')
    % repeat matrices
    n_pq=numel(pq);
    a=repmat(a,[1 1 n_pq]);
    b=repmat(b,[1 1 n_pq]);
    c=repmat(c,[1 1 n_pq]);
    d=repmat(d,[1 1 n_pq]);
else
    % interpolate matrices
    a=interp1n(p,a,pq,varargin{:});
    b=interp1n(p,b,pq,varargin{:});
    c=interp1n(p,c,pq,varargin{:});
    d=interp1n(p,d,pq,varargin{:});
end

sys1=ss(a,b,c,d);
sys1.InputName=sys.InputName;
sys1.OutputName=sys.OutputName;
sys1.InputGroup=sys.InputGroup;
sys1.OutputGroup=sys.OutputGroup;

if ~isempty(pName)
    sys1.SamplingGrid.(pName)=pq;
end

% return
sys=sys1;


