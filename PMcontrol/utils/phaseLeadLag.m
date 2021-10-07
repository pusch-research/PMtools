% PHASELEADLAG lead/lag compensator (SISO) 
%   
%   C=PHASELEADLAG(W,P)
%   C=PHASELEADLAG(W,P,N) compute SISO lead/lag compensator with 
%   phase P (rad) and gain 1 at frequency W (rad/s) of order N. 
%   P>0: phase lead
%   P<0: phase lag
%   
%   Example: phaseLeadLag(10,45*pi/180)
%       
%   See also TF

% REVISIONS:    2017-11-16 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function c=phaseLeadLag(w,p,n)

%% inputs

% order
if nargin<3
    n=1;
elseif n>1
    error('not implemented.')
end


% phase
if p>=pi/2 || p<=-pi/2
    warning('for order 1, phase is must be ]-pi/2 pi/2[')
end


% frequency 
if w<0
    error('w must be >0');
end

% check size
if numel(w)~=numel(p) || numel(w)~=1
    error('w and p must be of same size 1.');
end



%% design compensator
% see http://ctms.engin.umich.edu/CTMS/index.php?aux=Extras_Leadlag




a=(1+sin(p))/(1-sin(p));
w1=w/sqrt(a);
w2=w*sqrt(a);
k=(1+1/sqrt(a))/(1+sqrt(a));


c=1/k*tf([1 w1],[1 w2]);
































