function [GS,GNS]=xstabsep(sys,varargin)

n_sys=size(sys(:,:,:),3);

% loop (multimodel)
warning('off','Control:general:SamplingGrid7')
samplingGrid=sys.SamplingGrid;
userData=sys.UserData;
for ii=n_sys:-1:1
    [GS(:,:,ii),GNS(:,:,ii)]=stabsep(sys(:,:,ii),varargin{:});  
end
GS.SamplingGrid=samplingGrid;
GNS.UserData=userData;
warning('on','Control:general:SamplingGrid7')