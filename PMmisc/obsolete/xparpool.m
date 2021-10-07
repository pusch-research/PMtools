function [varargout]=xparpool(numWorkers,reCreate)

if nargin<1
    numWorkers=inf;
end
if nargin<2
    reCreate=false;
end

% n_worker_max=str2double(getenv('NUMBER_OF_PROCESSORS')); % increase max number of workers (might cause crash)
% n_worker_max=feature('numCores');


% get current pool
hPool=gcp('nocreate');

% close existing pool if desired
if ~isempty(hPool) && hPool.NumWorkers~=numWorkers && reCreate
    delete(hPool);
    hPool=[];
end

% open new pool
if isempty(hPool)
    myCluster=parcluster;
    if numWorkers<0
        hPool=parpool(min(myCluster.NumWorkers+numWorkers));
    else
        hPool=parpool(min(myCluster.NumWorkers,numWorkers));
    end
end

% output
if nargout==1
    varargout{1}=hPool;
end
