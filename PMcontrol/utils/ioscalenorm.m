function [sys,inScale,outScale]=ioscalenorm(sys,p,opt)
% scale inputs or ouputs such that Hinf or H2 norm is identical for all
% channels

s=singleNorm(sys,p);

if nargin<3 || strcmp(opt,'in')
    inScale=max(s,[],1);
    outScale=max(bsxfun(@rdivide,s,inScale),[],2);
else
    outScale=max(s,[],2);
    inScale=max(bsxfun(@rdivide,s,outScale),[],1);
end

sys=ioscale(sys,1./inScale,1./outScale);