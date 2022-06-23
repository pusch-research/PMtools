function [y,spike_iArr]=removeSpikes(u,thresh,method,n_iter,t)


if nargin<2 || isempty(thresh)
    thresh=1;
end
if nargin<3 || isempty(method)
    method='linear';
end
if nargin<4 || isempty(n_iter)
    n_iter=1;
end
if nargin<5 || isempty(t)
    t=0:length(u)-1;
end

% scale signal
u_mean=mean(u);
if u_mean==0
    u_mean=1;
end
u=u-u_mean;
u_rms=rms(u);
if u_rms==0
    u_rms=1;
end
u=u/u_rms;


% identify spikes
du=diff(u);
du=du/rms(u);
du=du(1:end-1)-du(2:end);
spike_iArr=find(abs(du)>thresh)+1;

% interpolation
ii=1;
while ii<numel(spike_iArr)
    spikeWidth=1;
    for jj=ii+1:numel(spike_iArr)
        if spike_iArr(jj)-spike_iArr(jj-1)>1
            break;
        end
        spikeWidth=spikeWidth+1;
    end

    if spike_iArr(ii)+spikeWidth-1==length(u)
        % spike is at the end of time series - use last valid value
        u(spike_iArr(ii):end)=u(spike_iArr(ii)-1);
    elseif spike_iArr(ii)==1
        % spike is at the beginning of time series - use first valid value
        u(1:spikeWidth)=u(spikeWidth+1);
    else
        % linearely interpolate spikes
        u(spike_iArr(ii)+(0:spikeWidth-1))=interp1(...
            t(spike_iArr(ii+[0 spikeWidth-1])+[-1;1]),...
            u(spike_iArr(ii+[0 spikeWidth-1])+[-1;1]),...
            t(spike_iArr(ii+(0:spikeWidth-1))),method);
    end
    ii=ii+spikeWidth;
end

% return
y=u*u_rms+u_mean;


% run iterative if desired
if n_iter>1
    y=removeSpikes(y,thresh,method,n_iter-1,t);
end
