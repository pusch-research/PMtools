% XIOPZMAP poles and zeros for single IO channels
%   
%   [P,Z]=XIOPZMAP(SYS)
%   [P,Z]=XIOPZMAP(SYS,FPRE)
%   returns cell arrays P and Z of size [n_out n_in] of poles and zeros for
%   all individual input-output channels of system SYS. Optionally, a
%   function handle FPRE can be given to perform a reduction method on the 
%   transfer function of the individual channel (e.g. MINREAL for state
%   space respresentations).
%       
%   See also PZMAP,IOPZMAP 

% REVISIONS:    2016-09-09 first implementation (MP)
% 
% Contact       pusch.research@gmail.com
%
function [p,z]=xiopzmap(sys,fPre)
% return poles and zeros for single IO channels (see also io


sys_size=size(sys);
sys_size=[sys_size 1];
p=cell([sys_size 1]);
z=cell([sys_size 1]);

sys=prescale(sys);

for i_sys=1:prod(sys_size(3:end))
for i_in=1:sys_size(2)
for i_out=1:sys_size(1)

    sys_act=sys(i_out,i_in,i_sys);
    if nargin>1
        [~,sys_act]=evalc('fPre(sys_act)'); % make evalc to suppress output for "minreal"        
    end
    
    p{i_out,i_in,i_sys}=eig(sys_act);
    z{i_out,i_in,i_sys}=zero(sys_act);

end
end
end
