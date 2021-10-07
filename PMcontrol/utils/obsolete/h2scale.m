% H2SCALE scale inputs and outputs according to H2 norm
%   
%   SYS=H2SCALE(SYS,OPT) scale inputs and outputs of dynamical system SYS 
%   so maximum H2 norm of each individual channel is 1. Define in OPT if 
%   inputs ('IN') or outputs ('OUT') should be scaled first. Default  OPT 
%   is 'IN'.
%       
%   See also IOSCALE,NORM,SINGLENORM

% REVISIONS:    2017-02-01 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function [sys,s_in,s_out]=h2scale(sys,opt)

s=singleNorm(sys,2);

if nargin<2 || strcmp(opt,'in')
    s_in=max(s,[],1);
    s_out=max(bsxfun(@rdivide,s,s_in),[],2);
else
    s_out=max(s,[],2);
    s_in=max(bsxfun(@rdivide,s,s_out),[],1);
end

sys=ioscale(sys,1./s_in,1./s_out);