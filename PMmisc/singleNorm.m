function norm_arr=singleNorm(sys,p,wband)

if ~exist('p','var'), p=2; end
if ~exist('wband','var'), wband=[0 inf]; end
tol=0.01; % for hinf norm

[n_out,n_in,sysArr_size]=sssize(sys);
n_sys=prod(sysArr_size);
norm_arr=nan([n_out n_in sysArr_size]);
switch p
    case 2
        for i_sys=1:n_sys
        for i_in=1:n_in
            norm_arr(:,i_in,i_sys)=singleH2NormLOCAL(sys(:,i_in,i_sys));
        end
        end
    case inf
        %warning('fast computation not implemented!');
        for i_in=1:n_in
        for i_out=1:n_out
        for i_sys=1:n_sys
            norm_arr(i_out,i_in,i_sys)=getPeakGain(sys(i_out,i_in,i_sys),tol,wband);
        end
        end
        end
    otherwise
        error('not implemented.');
end

end

function norm_arr=singleH2NormLOCAL(simo_sys)

simo_sys   = ssbal(sminreal(simo_sys)); % scale system for numerical stability

    
[A,B,C,D] = ssdata(simo_sys);

% try to compute gramian with different algorithms
Q=[];
if isempty(Q)
    try
        R = lyapchol(A,B,[],'noscale'); 
        Q = R'*R;
    catch
    end
end
if isempty(Q)
    try
        R = lyapchol(A,B,[],'noscale'); 
        Q = R'*R;
    catch
    end
end
if isempty(Q)
    try
        Q = lyap(A,B*B'); 
    catch
    end
end


if isempty(Q)
    % gramian could not be computed
    norm_arr=inf(size(simo_sys,1),1); 
else
    for i_out=size(simo_sys,1):-1:1
        norm_arr(i_out,1) = sqrt(trace(C(i_out,:)*Q*C(i_out,:)')) ; % OLD: norm(R*C(i_out,:).')
    end
    norm_arr(D~=0)=inf; % non-zero D leads to inf H2-norm
end
    

%% IMPORTANT: SYSTEM SHOULD BE A BALANCED FORM. USE BALREAL to REDUCE NUMERICAL ERRORS!
% Q=gram(simo_sys,'c');
% norm_arr=sqrt(diag(simo_sys.c*Q*simo_sys.c'));

end

% 
% function norm_arr=singleHinfNormLOCAL(simo_sys)
% 
% error('notImplemented.');
% 
% end