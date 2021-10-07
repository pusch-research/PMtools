% TINTCOLOR return tint(s) of color
%   
%   C=TINTCOLOR(C,TINTOPT)
%   For the input color array C [n_color x 3] different tints 
%   are returned depending on the input TINTOPT:
%   - integer: number of tints per color 
%     CT=[n_color*TINTOPT x 3] 
%     TINTOPT>0: dark to light, TINTOPT<0: light to dark
%   - numeric value(s) between [-1 1]: single tints is returned 
%     CT=[n_color*numel(TINTOPT) x 3]  
%     TINTOPT>0:lighter, TINTOPT<0: darker, TINTOPT=0: original color(s)
%   where each given color is followed by its tints.  
%
%   Example:
%       
%   See also 

% REVISIONS:    2018-03-28 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function ct=tintColor(c,tintOpt)
% gets color(s) c=[n_color x 3]
% returns tint color(s) c=[n_color*n_tint x 3] (grouped by colors: first block first color+tints etc.)
if tintOpt==0
    ct=c; % don't tint
    return;
end
n_color=size(c,1);
whiteShift=2; % integer

isInteger=~any(mod(tintOpt,1));
if isInteger
    % number of tints given
    doFlip=tintOpt<0; % for flipping (light colors first) all numbers negative
    tintOpt=abs(tintOpt);
    if tintOpt<5
        n_tint=tintOpt;
        ct=bsxfun(@plus,(1-c(:))*(0:n_tint-1)/(n_tint),c(:))'; % n_tint different tints (lighter for higher index)
    elseif tintOpt>=5
        n_tint=tintOpt;
        ct=bsxfun(@plus,(1-c(:))*(0:n_tint-1)/(n_tint*1.5),c(:))'; % n_tint different tints (lighter for higher index)
    end
    if doFlip
        ct=flip(ct,1);
    end
    n_line=n_color*n_tint;
    ct=[ct(1:n_line)' ct(n_line+1:2*n_line)' ct(2*n_line+1:end)']; % back-order
else
    % tint given +- percent
    n_tint=numel(tintOpt);
    tintOpt=repmat(tintOpt(:),n_color,1);
    ct=kron(c,ones(n_tint,1));
    if any(tintOpt>0)
        ct(tintOpt>0,:)=ct(tintOpt>0,:)+(1-ct(tintOpt>0,:)).*tintOpt(tintOpt>0);
    end
    if any(tintOpt<0)
        ct(tintOpt<0,:)=ct(tintOpt<0,:)+ct(tintOpt<0,:).*tintOpt(tintOpt<0);
    end
end












