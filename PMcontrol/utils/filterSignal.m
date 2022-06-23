function y=filterSignal(u,wc,type,order,t)
% filter a signal using Butterworth filter


if nargin<3
    type='low';
end
if nargin<4
    order=2;
end
if nargin<5
    t=0:length(u)-1; % assume equidistant time samples
end

% warning('off', 'Control:analysis:LsimStartTime')
W=xbutter(order,wc,type,'s');


% set correct initial value
if order==1
    x0=u(1);
elseif order==2
    W=xcanon(W,'control');
    x0=[u(1)/W.C(1,1) 0];
else
    x0=zeros(order,1);
    warning('initial state for higher order filters not implemented.')
end


if nargout==0
    % plot filter
    figure;
    bode(W);
    grid on
else
    % do filtering
    y=lsim(W,u,t,x0);
end


