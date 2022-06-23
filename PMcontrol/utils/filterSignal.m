function y=filterSignal(u,wc,varargin)
% filter a signal using Butterworth filter

p=inputParser();
p.addParameter('type','low');
p.addParameter('order',2);
p.addParameter('t',0:length(u)-1);
p.addParameter('thresh',0.1);
p.parse(varargin{:});
p=p.Results;

if nargin<3
    p.type='low';
end
if nargin<4
    p.order=2;
end
% if nargin<5
%     t=0:length(u)-1; % assume equidistant time samples
% end

if strcmp(p.type,'spikes')
    p.type='low';
    removeSpikes=true;
else
    removeSpikes=false;
end

warning('off', 'Control:analysis:LsimStartTime')
W=xbutter(p.order,wc,p.type,'s');

% set correct initial value
if p.order==1
    x0=u(1);
elseif p.order==2
    W=xcanon(W,'control');
    x0=[u(1)/W.C(1,1) 0];
else
    error('not implemented.')
end

% do filtering
y=lsim(W,u,p.t,x0);

if removeSpikes
    spike_iArr=find(abs(y-u)/rms(u)>p.thresh); % detect spikes
    ii=1;
    while ii<numel(spike_iArr)
        spikeWidth=1;
        for jj=ii+1:numel(spike_iArr)
            if spike_iArr(jj)-spike_iArr(jj-1)>1
%                 spikeWidth=jj-ii;
                break;
            end
            spikeWidth=spikeWidth+1;
        end

        if spike_iArr(ii)+spikeWidth-1==length(y)
            % spike is at the end of time series - use last valid value
            u(spike_iArr(ii):end)=u(spike_iArr(ii)-1);
        elseif spike_iArr(ii)==1
            % spike is at the beginning of time series - use first valid value
            u(1:spikeWidth)=u(spikeWidth+1);
        else
            % linearely interpolate spikes
            u(spike_iArr(ii)+(0:spikeWidth-1))=interp1(...
                p.t(spike_iArr(ii+[0 spikeWidth-1])+[-1;1]),...
                u(spike_iArr(ii+[0 spikeWidth-1])+[-1;1]),...
                p.t(spike_iArr(ii+(0:spikeWidth-1))));
        end
        ii=ii+spikeWidth;
    end
    y=u;
end
    


end

