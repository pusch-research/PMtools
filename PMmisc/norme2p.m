% NORME2P maximum energy-to-peak gain
%   
%   NORME2P(SYS) compute maximum enerty-to-peak gain of linear system
%   using controlability gramian.
%   
%   Example: norme2p(rss(2))
%       
%   See also NORM,SS

% REVISIONS:    2016-04-25 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function e2p=norme2p(sys,opt)

if nargin>1
    error('not implemented');
end
if any(sys.d>0)
    warning('The energy-to-peak norm is infinite because the system has nonzero feedthrough.');
    e2p=inf;
    return;
end

Wc=gram(sys,'c');
e2p=sqrt(max(eig(sys.c*Wc*sys.c')));
