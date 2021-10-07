% IOSCALE input/output scaling of ss object (array)
%   
%   SYS=IOSCALE(SYS,INSCALE,OUTSCALE) input and output of state space 
%   system are scaled by scalar or vector INSCALE and OUTSCALE. Input/output
%   name/group are preserved while input/output unit is reset.
%
%   SYS=IOSCALE(SYS,INSCALE,OUTSCALE,INVAL,OUTVAL) scale only the selected
%   inputs INSCALE and outputs OUTSCALE which are given as input/output
%   groups/names/indices by INVAL and OUTVAL.
%   
%   Example: IOSCALE(rss(2,3,4),[1 10 100 1000],[200 20 2])
%       
%   See also PRESCALE, SS

% REVISIONS:    2014-06-03 first implementation (MP)
%               2017-11-23 add inVal/outVal (MP)
% 
% Contact       pusch.research@gmail.com
%
function sys=ioscale(sys,inScale,outScale,inVal,outVal)

%% input handling

if nargin<=3

    % only inSCale/outScale given as factors
    if ~exist('inScale','var') || isempty(inScale)
        inScale=ones(size(sys,2),1);
    end
    if ~exist('outScale','var') || isempty(outScale)
        outScale=ones(size(sys,1),1); 
    end
    
else
    
    % inScale/outScale given as indices + values
    in_iArr=xname2index(sys,inScale,2);
    out_iArr=xname2index(sys,outScale,1);
    n_in=numel(in_iArr);
    n_out=numel(out_iArr);
   
    % check inVal
    if numel(inVal)==1
        inVal=repmat(inVal,n_in,1);
    elseif numel(inVal)~=n_in
        error('inVal and in_iArr must be of equal length');
    end
    
    % check outVal
    if nargin<5
        outVal=ones(n_out,1);
    elseif numel(outVal)==1
        outVal=repmat(outVal,n_out,1);
    elseif n_out~=numel(outVal)
        error('outVal and out_iArr must be of equal length');
    end
    
    [n_y,n_u]=size(sys);
    inScale=ones(n_u,1);
    outScale=ones(n_y,1);
    inScale(in_iArr)=inVal;
    outScale(out_iArr)=outVal;
    
end


%% do scaling

if ~iscell(inScale) && ~iscell(outScale)
    % weights are vectors
    if numel(unique(order(sys(:,:,:))))==1
        sys.b=bsxfun(@times,sys.b,inScale(:)');
        sys.d=bsxfun(@times,sys.d,inScale(:)');
        sys.c=bsxfun(@times,sys.c,outScale(:));
        sys.d=bsxfun(@times,sys.d,outScale(:));
    else
        % varying number of states
        for i_sys=1:size(sys(:,:,:),3)
            sys(:,:,i_sys).b=bsxfun(@times,sys(:,:,i_sys).b,inScale(:)');
            sys(:,:,i_sys).d=bsxfun(@times,sys(:,:,i_sys).d,inScale(:)');
            sys(:,:,i_sys).c=bsxfun(@times,sys(:,:,i_sys).c,outScale(:));
            sys(:,:,i_sys).d=bsxfun(@times,sys(:,:,i_sys).d,outScale(:));
        end
    end
    sys.InputUnit=[];
    sys.OutputUnit=[];
elseif iscell(inScale) && iscell(outScale)
    % weights are filters (stored in cells)
    inName_arr=sys.InputName;
    outName_arr=sys.OutputName;
    inGroup=sys.InputGroup;
    outGroup=sys.OutputGroup;
    name=sys.Name;
    
    sys=blkdiag(inScale{:})*sys*blkdiag(outScale{:});
    
    sys.Name=name;
    sys.InputName=inName_arr;
    sys.OutputName=outName_arr;
    sys.InputGroup=inGroup;
    sys.OutputGroup=outGroup;
else
    error('not implemented.');
end
